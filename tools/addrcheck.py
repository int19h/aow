"""Check the references hidden by match.py's address masking.

Usage: addrcheck.py [--show Method] [--alias aliases.json] [--quiet]
                    [--units Unit1,Unit2] compiled.exe compiled.map
                    original signatures.json [OrigClass[=NewClass] ...]

Function selection, sizes, normalization and embedded-table handling follow
match.py. Equal normalized instruction runs are aligned even in differing
functions. References are compared by unit-qualified names and by their
module-wide, bidirectional usage counts. Unknown names stay unknown: a
majority correspondence is evidence for an inconsistency, never a name.

Detailed Delphi maps supply each public symbol's owning unit and the distinct
DATA/BSS offsets. Import thunks and static pointer cells retain the identity of
their referents. Delphi omits resource-string records from its public symbols;
these are identified independently by their unit and resource text, using the
original package's exports. Ambiguous resource identities are left unnamed.
--show writes the selected function's aligned references to stderr; --quiet
is accepted for compatibility (stdout always contains findings and totals).
"""

import bisect
import collections
import dataclasses
import difflib
import json
import pathlib
import re
import struct
import sys

sys.dont_write_bytecode = True
import match

CS = match.capstone
X = CS.x86_const


def unhash(name):
    name = re.sub(r'@[0-9a-fA-F]{8}$', '', name)
    # Some Ghidra signatures repeat a unit as a namespace (Unit.Unit.Proc).
    parts = name.split('.')
    if len(parts) > 2 and parts[0].casefold() == parts[1].casefold():
        name = '.'.join(parts[1:])
    return name


def known(name):
    return not re.fullmatch(r'FUN_[0-9a-fA-F]+|[0-9a-fA-F]{8}:\d+', name)


@dataclasses.dataclass
class Function:
    name: str
    original_name: str
    ova: int
    osize: int
    nva: int
    nsize: int

    @property
    def decode_size(self):
        return min(self.nsize, self.osize + 32)


class Inputs:
    """The same option parsing and function pairs as match.main()."""

    def __init__(self, argv):
        argv = list(argv)
        self.aliases = {}
        self.show = None
        units = []
        while argv and argv[0].startswith('--'):
            opt = argv.pop(0)
            if opt == '--quiet':
                continue
            if opt not in ('--show', '--alias', '--units'):
                raise ValueError('unknown option ' + opt)
            if not argv:
                raise ValueError('missing value for ' + opt)
            value = argv.pop(0)
            if opt == '--show':
                self.show = value
            elif opt == '--units':
                units += value.split(',')
            else:
                with open(value, encoding='utf-8') as f:
                    self.aliases.update(json.load(f))
        if len(argv) < 4:
            raise ValueError(__doc__.split('\n\n')[1])
        exe, mapf, orig, sigf, *classes = argv
        self.original_path = pathlib.Path(orig)
        self.old, self.new = match.Image(orig), match.Image(exe)
        self.syms, _ = match.map_symbols(mapf)
        self.map_path = mapf
        with open(sigf, encoding='utf-8') as f:
            self.sigs = {fn['name'].split('@')[0]: (int(fn['addr'], 16), fn['size'])
                         for fn in json.load(f)}
        self.text = self.new.base + self.new.pe.sections[0].VirtualAddress
        code_syms = sorted((off, name) for name, locs in self.syms.items()
                           for seg, off in locs if seg == '0001')
        offsets = sorted({off for off, _ in code_syms})
        pairs = []
        aliased = set(self.aliases.values())
        alias_addrs = {int(k.split(':')[0], 16) for k in self.aliases
                       if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', k)}
        for spec in classes:
            oc, _, nc = spec.partition('=')
            nc = nc or oc
            for off, name in code_syms:
                if not name.startswith(nc + '.') or name in aliased:
                    continue
                method = name[len(nc) + 1:]
                on = None
                for k in self.sigs:
                    if k == oc + '.' + method or k.endswith('.' + oc + '.' + method):
                        on = k
                if on is not None and self.sigs[on][0] in alias_addrs:
                    continue
                pairs.append((name, on))
        for unit in units:
            for k in sorted(self.sigs, key=lambda k: self.sigs[k][0]):
                parts = k.split('.')
                if (len(parts) == 2 and parts[0] == unit and parts[1] in self.syms
                        and parts[1] not in aliased and k not in self.aliases
                        and parts[1] not in (unit, 'Finalization')):
                    pairs.append((parts[1], k))
        for on, name in self.aliases.items():
            if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', on):
                address, size = on.split(':')
                self.sigs[on] = (int(address, 16), int(size))
            pairs.append((name, on if on in self.sigs else None))
        self.functions = []
        for name, on in pairs:
            loc = match.resolve(self.syms, name)
            if on is None or loc is None:
                continue
            ova, osize = self.sigs[on]
            seg, off = loc
            idx = bisect.bisect_right(offsets, off)
            nxt = offsets[idx] if idx < len(offsets) else off + osize + 64
            self.functions.append(Function(name, on, ova, osize, self.text + off,
                                           nxt - off))
        self.old_exception = match.find_import_thunk(self.old, 'System.@HandleOnException')
        loc = match.resolve(self.syms, '@HandleOnException')
        self.new_exception = self.text + loc[1] if loc else None


class MapLayout:
    def __init__(self, inp):
        self.parts = collections.defaultdict(list)
        self.units = collections.defaultdict(list)
        sections = inp.new.pe.sections
        for line in open(inp.map_path, encoding='latin1'):
            m = re.match(r'\s*(\d{4}):([\da-fA-F]{8})\s+([\da-fA-F]{8})H\s+(\S+)\s+(CODE|ICODE|DATA|BSS)', line)
            if m:
                seg, off, size, name, kind = m.groups()
                # Delphi's CODE/DATA/BSS PE names differ from .text/.data/.bss.
                sec = next((s for s in sections if s.Name.rstrip(b'\0').decode('latin1').lower()
                            in (name.lower(), kind.lower())), None)
                if sec is not None:
                    va = inp.new.base + sec.VirtualAddress
                    # The map header puts BSS immediately after DATA, but
                    # public offsets include the PE section-alignment gap.
                    start = (self.parts[seg][0][0] + va - self.parts[seg][0][2]
                             if self.parts[seg] else int(off, 16))
                    self.parts[seg].append((start, int(size, 16), va))
            m = re.match(r'\s*(\d{4}):([\da-fA-F]{8})\s+([\da-fA-F]{8})\s+C=\S+\s+S=\S+\s+G=\S+\s+M=(\S+)', line)
            if m:
                seg, off, size, unit = m.groups()
                self.units[seg].append((int(off, 16), int(size, 16), unit))
        for parts in self.parts.values():
            parts.sort()
        for units in self.units.values():
            units.sort()
        self.starts = {seg: [off for off, _, _ in units] for seg, units in self.units.items()}

    def address(self, seg, off):
        for start, size, va in self.parts.get(seg, []):
            if start <= off < start + size:
                return va + off - start
        return None

    def owner(self, seg, off):
        units = self.units.get(seg, [])
        i = bisect.bisect_right(self.starts.get(seg, []), off) - 1
        if i >= 0 and off < units[i][0] + units[i][1]:
            return units[i][2]
        return None

    def owner_at(self, va):
        for seg, parts in self.parts.items():
            for off, size, start in parts:
                if start <= va < start + size:
                    return self.owner(seg, off + va - start)
        return None


def directories(img):
    img.pe.parse_data_directories(directories=[match.pefile.DIRECTORY_ENTRY[key] for key in (
        'IMAGE_DIRECTORY_ENTRY_IMPORT', 'IMAGE_DIRECTORY_ENTRY_EXPORT',
        'IMAGE_DIRECTORY_ENTRY_BASERELOC', 'IMAGE_DIRECTORY_ENTRY_RESOURCE')])


def u32(img, address):
    data = img.bytes_at(address, 4) if img.contains(address) else b''
    return struct.unpack('<I', data)[0] if len(data) == 4 else None


def resource_strings(img):
    out = {}
    for entry in getattr(getattr(img.pe, 'DIRECTORY_ENTRY_RESOURCE', None), 'entries', []):
        if entry.id != 6:  # RT_STRING: sixteen length-prefixed UTF-16 strings per block
            continue
        for block in entry.directory.entries:
            if block.id is None:
                continue
            for lang in block.directory.entries:
                desc = lang.data.struct
                data = img.pe.get_data(desc.OffsetToData, desc.Size)
                pos = 0
                for i in range(16):
                    if pos + 2 > len(data):
                        break
                    length = struct.unpack_from('<H', data, pos)[0]
                    pos += 2
                    end = pos + length * 2
                    if end > len(data):
                        break
                    if length:
                        out.setdefault((block.id - 1) * 16 + i, set()).add(data[pos:end])
                    pos = end
    return out


class Names:
    def __init__(self, inp):
        self.names = [{}, {}]
        self.layout = MapLayout(inp)
        self.relocs = []
        self.imports = []
        self.derived_cells = [set(), set()]
        self.metadata = [set(), set()]
        self.destination_cache = [{}, {}]
        self.read_sites = set()
        self.constant_pairs = set()
        for side, img in enumerate((inp.old, inp.new)):
            directories(img)
            self.relocs.append({img.base + e.rva
                                for block in getattr(img.pe, 'DIRECTORY_ENTRY_BASERELOC', [])
                                for e in block.entries if e.type == 3})
            imps = {}
            for entry in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
                dll = entry.dll.decode('latin1')
                for imp in entry.imports:
                    name = unhash(imp.name.decode('latin1')) if imp.name else '#' + str(imp.ordinal)
                    if '.' not in name:
                        name = pathlib.Path(dll).stem + '.' + name
                    imps[imp.address] = name
                    self.add(side, imp.address, name)
            self.imports.append(imps)
            for export in getattr(getattr(img.pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []):
                if export.name:
                    self.add(side, img.base + export.address, unhash(export.name.decode('latin1')))
        for name, (address, size) in inp.sigs.items():
            if known(name):
                self.add(0, address, name)
        for name, locs in inp.syms.items():
            for seg, off in locs:
                address = self.layout.address(seg, off)
                unit = self.layout.owner(seg, off)
                if address is not None and unit:
                    self.add(1, address, unit + '.' + name)
        # Executable signatures have Class.Method, whereas package exports
        # have Unit.Class.Method. Recover an omitted unit only when the map
        # gives that class one unambiguous owner.
        class_units = collections.defaultdict(set)
        for values in self.names[1].values():
            for name in values:
                parts = name.split('.')
                if len(parts) == 3:
                    class_units[parts[1]].add(parts[0])
        for address, values in self.names[0].items():
            qualified = set()
            for name in values:
                parts = name.split('.')
                units = class_units.get(parts[0], set()) if len(parts) == 2 else set()
                qualified.add(next(iter(units)) + '.' + name if len(units) == 1 else name)
            self.names[0][address] = qualified
        # User aliases give names to otherwise anonymous functions / VMT slots.
        # Meaningful original names are preserved, so an alias cannot mask a
        # conflict between two independently named routines.
        anonymous = {f.ova for f in inp.functions
                     if not self.names[0].get(f.ova) or all(
                         re.search(r'\.vmt[0-9a-fA-F]+$', n) for n in self.names[0][f.ova])}
        for f in inp.functions:
            if f.ova in anonymous:
                names = self.names[1].get(f.nva, set())
                if names:
                    # Several explicit aliases may name the same anonymous
                    # original. Keep all of them rather than the last one.
                    self.names[0].setdefault(f.ova, set()).update(names)
        self.class_names(inp)
        self.resource_names(inp)
        for side, img in enumerate((inp.old, inp.new)):
            # Name all code import thunks, including more than one thunk for
            # the same IAT entry. Restrict scanning to executable sections.
            for sec in img.pe.sections:
                if not sec.Characteristics & 0x20000000:
                    continue
                data = img.bytes_at(img.base + sec.VirtualAddress, sec.Misc_VirtualSize)
                for m in re.finditer(b'\xff\x25(.{4})', data, re.DOTALL):
                    cell = struct.unpack('<I', m.group(1))[0]
                    if cell in self.imports[side]:
                        self.names[side][img.base + sec.VirtualAddress + m.start()] = {self.imports[side][cell]}
            # Static Delphi hosts use private pointer cells to preserve the
            # original package-import indirection. Only loader-relocated
            # pointers with independently named referents acquire a name.
            for _ in range(3):
                pending = []
                for cell in self.relocs[side]:
                    if cell not in self.names[side] and cell not in self.metadata[side]:
                        names = self.names[side].get(u32(img, cell))
                        if names:
                            pending.append((cell, set(names)))
                self.names[side].update(pending)
                self.derived_cells[side].update(cell for cell, _ in pending)
        self.pointer_sites = collections.defaultdict(set)
        for site in self.relocs[1]:
            self.pointer_sites[u32(inp.new, site)].add(site)
        self.sorted_relocs = [sorted(rs) for rs in self.relocs]

    def add(self, side, address, name):
        if known(name):
            self.names[side].setdefault(address, set()).add(unhash(name))

    def class_names(self, inp):
        # Delphi 3's VMT self pointer is 64 bytes before the virtual methods;
        # its class-name pointer is at -32, type information at -52. A static
        # import cell can load this self pointer instead of an IAT entry.
        units = collections.defaultdict(set)
        for values in self.names[0].values():
            for name in values:
                parts = name.split('.')
                if len(parts) == 3:
                    units[parts[1] or parts[2]].add(parts[0])
        for side, image in ((1, inp.new), (0, inp.old)):
            for ref in self.relocs[side]:
                vmt = u32(image, ref)
                if vmt != ref + 64:
                    continue
                ptr = u32(image, vmt - 32)
                if ptr is None or not image.contains(ptr):
                    continue
                data = image.bytes_at(ptr, 256)
                if not data:
                    continue
                short = data[1:1 + data[0]]
                if not re.fullmatch(rb'[A-Za-z_]\w*', short):
                    continue
                self.metadata[side].update((ref, vmt))
                name = short.decode('ascii')
                owners = units.get(name, set())
                unit = self.layout.owner_at(ref) if side == 1 else next(iter(owners)) if len(owners) == 1 else None
                if not unit:
                    continue
                if side == 1:
                    units[name].add(unit)
                self.names[side][ref] = {unit + '..' + name}
                self.names[side][vmt] = {unit + '..' + name}
                typeinfo = u32(image, vmt - 52)
                if typeinfo is not None and image.contains(typeinfo):
                    self.add(side, typeinfo, unit + '.' + name)

    def resource_names(self, inp):
        identities = collections.defaultdict(set)
        paths = {inp.original_path}
        paths.update(inp.original_path.parent / entry.dll.decode('latin1')
                     for entry in getattr(inp.old.pe, 'DIRECTORY_ENTRY_IMPORT', [])
                     if entry.dll.lower().endswith(b'.dpl'))
        for path in sorted(paths):
            if not path.is_file():
                continue
            image = inp.old if path == inp.original_path else match.Image(str(path))
            directories(image)
            strings = resource_strings(image)
            for e in getattr(getattr(image.pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []):
                if not e.name:
                    continue
                name = unhash(e.name.decode('latin1'))
                address = image.base + e.address
                module = u32(image, address)
                ident = u32(image, address + 4)
                if module is None or not image.contains(module) or '.' not in name:
                    continue
                for payload in strings.get(ident, ()):
                    identities[name.split('.')[0].casefold(), payload].add(name)
            if image is not inp.old:
                image.pe.close()
        strings = resource_strings(inp.new)
        for address in self.relocs[1]:
            module = u32(inp.new, address)
            ident = u32(inp.new, address + 4)
            unit = self.layout.owner_at(address)
            if module is None or not inp.new.contains(module) or ident not in strings:
                continue
            # An unnamed resource record is not an alias of HInstance merely
            # because its first field points to the module-handle variable.
            self.metadata[1].add(address)
            if not unit:
                continue
            candidates = set()
            for payload in strings.get(ident, ()):
                candidates.update(identities.get((unit.casefold(), payload), ()))
            if len(candidates) == 1:
                self.add(1, address, next(iter(candidates)))

    def get(self, side, address):
        return self.names[side].get(address, set())

    def same(self, old, new):
        return bool({n.casefold() for n in self.get(0, old)} &
                    {n.casefold() for n in self.get(1, new)})

    def format(self, side, address):
        names = self.get(side, address)
        return '%08X/%s' % (address, '|'.join(sorted(names)) if names else '?')

    def destination(self, side, image, address):
        """Resolve exact jump thunks, retaining names at the destination."""
        initial = address
        if address in self.destination_cache[side]:
            return self.destination_cache[side][address]
        seen = set()
        while image.contains(address) and address not in seen:
            seen.add(address)
            data = image.bytes_at(address, 10)
            if len(data) < 6:
                break
            # Delphi assembler helpers can undo their compiler-inserted
            # frame before tail-jumping: PUSH EBP; MOV EBP,ESP; POP EBP.
            if data[:4] == b'\x55\x8b\xec\x5d' and data[4:5] in (b'\xe9', b'\xeb'):
                address += 4
                continue
            if data[:2] == b'\xff\x25':
                cell = struct.unpack_from('<I', data, 2)[0]
                if cell not in self.imports[side]:
                    break
                # Keep imports in this image's address space. Dependencies
                # may share its preferred base (several are 00400000), and
                # an unbound IAT contains hint/name RVAs, not code pointers.
                address = cell
                break
            elif data[0] in (0xe9, 0xeb):
                length = 5 if data[0] == 0xe9 else 2
                delta = struct.unpack_from('<i' if length == 5 else '<b', data, 1)[0]
                address = (address + length + delta) & 0xffffffff
            else:
                break
        self.destination_cache[side][initial] = address
        return address

    def reference_pair(self, inp, old, new, role):
        if role == 'target':
            return (self.destination(0, inp.old, old), self.destination(1, inp.new, new))
        classref = u32(inp.old, old) == old + 64 and any('..' in n for n in self.get(0, old))
        value = u32(inp.old, old)
        anonymous_cell = (not self.get(0, old) and old in self.relocs[0]
                          and value is not None and any(
                              inp.old.base + s.VirtualAddress <= value < inp.old.base + s.VirtualAddress + s.Misc_VirtualSize
                              for s in inp.old.pe.sections if s.Name.rstrip(b'\0').lower() in (b'bss', b'.bss')))
        if role == 'mem' and (old in self.imports[0] or old in self.derived_cells[0] or classref or anonymous_cell):
            # An IAT load obtains the address of a routine/variable, not the
            # IAT cell's contents as game data. Static hosts replace it with
            # one or several relocated pointer constants. Compare those
            # independently named referents, not the incidental cell labels.
            value = None if old in self.imports[0] else u32(inp.old, old)
            if value is not None:
                old = value
            value = u32(inp.new, new) if new in self.relocs[1] else None
            if value is not None and self.get(1, value):
                new = value
        return old, new

    def check_constants(self, inp, evidence):
        """Recognize pool splitting/merging without guessing mutable globals.

        The original bytes must be in a read-only section, contain no
        relocations, and equal every byte read on the compiled side. Every
        relocated reference to the compiled object must have been decoded
        as a direct memory read: no writes or escaping pointers are allowed.
        These pairs remain recorded, but do not create a pool inconsistency.
        """
        for (old, new), uses in evidence.items():
            if not uses or any(u.operand[1] != 'mem' or not u.width for u in uses):
                continue
            width = max(u.width for u in uses)
            sec = next((s for s in inp.old.pe.sections
                        if inp.old.base + s.VirtualAddress <= old
                        and old + width <= inp.old.base + s.VirtualAddress + s.Misc_VirtualSize), None)
            if sec is None or sec.Characteristics & 0x80000000:
                continue
            def relocated(side, address):
                entries = self.sorted_relocs[side]
                i = bisect.bisect_left(entries, address)
                return i < len(entries) and entries[i] < address + width

            if relocated(0, old):
                continue
            sites = set().union(*(self.pointer_sites.get(new + i, set()) for i in range(width)))
            if not sites or not sites <= self.read_sites:
                continue
            if relocated(1, new):
                continue
            if inp.old.bytes_at(old, width) == inp.new.bytes_at(new, width):
                self.constant_pairs.add((old, new))


def decode(md, img, va, size, on_exception):
    """match.disasm_skipping_tables, retaining raw instructions for operands."""
    out = []
    code = img.bytes_at(va, size)
    pos = 0
    while pos < size:
        insns = list(md.disasm(code[pos:], va + pos))
        if not insns:
            break
        for ins in insns:
            out.append((match.normalize(ins, img), ins))
            pos = ins.address - va + ins.size
            m = re.fullmatch(r'dword ptr \[(?:e[a-z]{2})\*4 \+ (0x[0-9a-f]+)\]', ins.op_str) if ins.mnemonic == 'jmp' else None
            if m and va <= int(m.group(1), 16) < va + size:
                tpos = int(m.group(1), 16) - va
                skip = 0
                while (skip < 8 and tpos + 4 <= size and
                       not va <= struct.unpack_from('<I', code, tpos)[0] < va + size):
                    tpos += 4
                    skip += 1
                entries = []
                while tpos + 4 <= size:
                    target = struct.unpack_from('<I', code, tpos)[0]
                    if not va <= target < va + size:
                        break
                    entries.append(target - va)
                    tpos += 4
                if entries and tpos > pos:
                    out.append((('.table', ' '.join('%x' % e for e in entries)), None))
                    pos = tpos
                    break
            if ins.mnemonic == 'jmp' and on_exception is not None:
                try:
                    target = int(ins.op_str, 16)
                except ValueError:
                    target = None
                if target == on_exception:
                    if pos + 4 > size:
                        return out
                    n = struct.unpack_from('<I', code, pos)[0]
                    if n < 16:
                        pos += 4 + 8 * n
                        if pos >= size:
                            return out
                        break
        else:
            break
    return out


def operands(ins, img):
    """Address operands by operand position and role; never EBP/ESP frame slots."""
    out = {}
    branch = ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j')
    for i, operand in enumerate(ins.operands):
        if operand.type == X.X86_OP_IMM:
            value = operand.imm & 0xffffffff
            if branch or img.contains(value):
                out[i, 'target' if branch else 'imm'] = value
        elif operand.type == X.X86_OP_MEM:
            mem = operand.mem
            if mem.base in (X.X86_REG_EBP, X.X86_REG_ESP):
                continue
            value = mem.disp & 0xffffffff
            if img.contains(value) or (mem.base == 0 and mem.index == 0 and value != 0):
                out[i, 'mem'] = value
    return out


INVERSE = dict(zip(
    'je jne ja jbe jae jb jg jle jge jl jo jno js jns jp jnp'.split(),
    'jne je jbe ja jb jae jle jg jl jge jno jo jns js jnp jp'.split()))


def aligned(a, b):
    """Align instruction shapes on corresponding control-flow paths.

    In differing functions a compiler can invert a condition and exchange its
    two bodies. A flat sequence diff would then claim that both bodies use
    the wrong globals. Traverse those edges by their condition, keeping the
    address names entirely out of alignment. Ambiguous control flow is not
    guessed. Exact MATCH functions use the matcher's instruction positions.
    """
    aa, bb = [x[0] for x in a], [x[0] for x in b]
    if aa == bb:
        yield from zip(a, b)
        return

    def graph(stream):
        by_pc = {ins.address: i for i, (_, ins) in enumerate(stream) if ins is not None}
        leaders = {0}
        tables = {}
        base = next((ins.address for _, ins in stream if ins is not None), 0)
        for i, (norm, ins) in enumerate(stream):
            if ins is None:
                if norm[0] == '.table' and i and stream[i - 1][1] is not None:
                    targets = [by_pc.get(base + int(v, 16)) for v in norm[1].split()]
                    tables[stream[i - 1][1].address] = targets
                    leaders.update(v for v in targets if v is not None)
                continue
            if ins.mnemonic.startswith('j') or ins.mnemonic.startswith('ret'):
                if i + 1 < len(stream):
                    leaders.add(i + 1)
            for op in ins.operands:
                if op.type == X.X86_OP_IMM and op.imm in by_pc:
                    leaders.add(by_pc[op.imm])
        starts = sorted(leaders)
        blocks = {start: stream[start:end] for start, end in
                  zip(starts, starts[1:] + [len(stream)])}
        nexts = dict(zip(starts, starts[1:]))
        return blocks, nexts, by_pc, tables

    ag, an, ap, at = graph(a)
    bg, bn, bp, bt = graph(b)
    queue = collections.deque([(0, 0)])
    forward, reverse = {}, {}
    while queue:
        ai, bi = queue.popleft()
        if ai not in ag or bi not in bg:
            continue
        if ai in forward or bi in reverse:
            continue
        forward[ai], reverse[bi] = bi, ai
        left, right = ag[ai], bg[bi]
        ls, rs = [x[0] for x in left], [x[0] for x in right]
        # A reordered block can fall through where its counterpart jumps to
        # a shared epilog. The transfer itself is not part of its body.
        ln = len(ls) - int(ls[-1][0].startswith(('j', 'ret')))
        rn = len(rs) - int(rs[-1][0].startswith(('j', 'ret')))
        same_body = ln == rn and all(l[0] == r[0] for l, r in zip(ls[:ln], rs[:rn]))
        if same_body:
            # Register-choice differences preserve instruction positions.
            runs = [(i, i, 1) for i, (l, r) in enumerate(zip(ls[:ln], rs[:rn])) if l == r]
            if ln < len(ls) and rn < len(rs) and ls[-1] == rs[-1]:
                runs.append((ln, rn, 1))
        else:
            # A lone masked CALL in substantially rewritten code has no
            # alignment evidence. Require surrounding instruction shapes.
            runs = []
            for x, y, n in difflib.SequenceMatcher(None, ls, rs, autojunk=False).get_matching_blocks():
                endx, endy = x + n, y + n
                if (endx < len(ls) and endy < len(rs)
                        and ls[endx][0] != rs[endy][0]
                        and INVERSE.get(ls[endx][0]) != rs[endy][0]):
                    # A shared load prefix followed by different operations
                    # can obtain different intermediate objects (e.g. Engine
                    # versus Map.Engine). It does not align those globals.
                    n = max(0, n - 2)
                if n >= 3 or n == len(ls) == len(rs):
                    runs.append((x, y, n))
        for x, y, count in runs:
            for old, new in zip(left[x:x + count], right[y:y + count]):
                yield old, new
                if old[1] is not None and new[1] is not None:
                    # Local exception/finally handler addresses are also
                    # control-flow roots, although pushed rather than jumped.
                    for oo, no in zip(old[1].operands, new[1].operands):
                        if (oo.type == no.type == X.X86_OP_IMM
                                and oo.imm in ap and no.imm in bp):
                            queue.append((ap[oo.imm], bp[no.imm]))
        old = next((ins for _, ins in reversed(left) if ins is not None), None)
        new = next((ins for _, ins in reversed(right) if ins is not None), None)
        if old is None or new is None:
            continue

        def target(ins, pcs):
            return pcs.get(ins.operands[0].imm) if ins.operands and ins.operands[0].type == X.X86_OP_IMM else None

        ot, nt = target(old, ap), target(new, bp)
        om, nm = old.mnemonic, new.mnemonic
        oc, nc = om.startswith('j') and om != 'jmp', nm.startswith('j') and nm != 'jmp'
        if oc and nc and (om == nm or INVERSE.get(om) == nm):
            if om == nm:
                queue.extend(((ot, nt), (an.get(ai), bn.get(bi))))
            else:
                queue.extend(((ot, bn.get(bi)), (an.get(ai), nt)))
        elif not oc and not nc:
            if old.address in at and new.address in bt and len(at[old.address]) == len(bt[new.address]):
                queue.extend(zip(at[old.address], bt[new.address]))
            os = ot if om == 'jmp' else None if om.startswith('ret') else an.get(ai)
            ns = nt if nm == 'jmp' else None if nm.startswith('ret') else bn.get(bi)
            queue.append((os, ns))


@dataclasses.dataclass(frozen=True)
class Use:
    function: str
    original_pc: int
    compiled_pc: int
    operand: tuple
    width: int = 0


def collect(inp, names):
    md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
    md.detail = True
    evidence = collections.defaultdict(set)
    for f in inp.functions:
        a = decode(md, inp.old, f.ova, f.osize, inp.old_exception)
        b = decode(md, inp.new, f.nva, f.decode_size, inp.new_exception)[:len(a)]
        for _, ins in b:
            if ins is None:
                continue
            for operand in ins.operands:
                if (operand.type == X.X86_OP_MEM and not operand.mem.base and not operand.mem.index
                        and operand.access & CS.CS_AC_READ and not operand.access & CS.CS_AC_WRITE):
                    names.read_sites.add(ins.address + ins.disp_offset)
        for (_, old), (_, new) in aligned(a, b):
            if old is None or new is None:
                continue
            oa, na = operands(old, inp.old), operands(new, inp.new)
            for key in oa.keys() & na.keys():
                o, n = oa[key], na[key]
                if f.ova <= o < f.ova + f.osize or f.nva <= n < f.nva + f.nsize:
                    continue
                o, n = names.reference_pair(inp, o, n, key[1])
                # Only identically named System helpers are exempt from
                # bijection checks: different helper names remain errors.
                system_helper = (old.mnemonic == 'call' or old.mnemonic.startswith('j')
                                 or any(x.casefold().startswith('system.@') for x in names.get(0, o)))
                if system_helper and names.same(o, n) and any(x.casefold().startswith('system.') for x in names.get(0, o)):
                    continue
                width = old.operands[key[0]].size if key[1] == 'mem' else 0
                use = Use(f.name, old.address, new.address, key, width)
                evidence[o, n].add(use)
                if inp.show and f.name.endswith(inp.show):
                    print('%s %08X %s %s -> %08X %s %s  %s %s' % (
                        f.name, old.address, old.mnemonic, old.op_str,
                        new.address, new.mnemonic, new.op_str,
                        names.format(0, o), names.format(1, n)), file=sys.stderr)
    names.check_constants(inp, evidence)
    return evidence


@dataclasses.dataclass
class Finding:
    function: str
    kind: str
    original: int
    compiled: int
    detail: str

    def line(self, names):
        return '%s %s %s %s%s' % (self.function, self.kind,
                                  names.format(0, self.original), names.format(1, self.compiled),
                                  ' ' + self.detail if self.detail else '')


def findings(evidence, names):
    out = []
    forward, reverse = collections.defaultdict(dict), collections.defaultdict(dict)
    for (old, new), uses in sorted(evidence.items()):
        forward[old][new] = len(uses)
        reverse[new][old] = len(uses)
        if names.get(0, old) and names.get(1, new) and not names.same(old, new):
            users = ','.join(sorted({u.function for u in uses}))
            out.append(Finding(users, 'name-conflict', old, new, 'uses=%d' % len(uses)))
    for direction, groups in (('original', forward), ('compiled', reverse)):
        for anchor, partners in sorted(groups.items()):
            if len(partners) < 2:
                continue
            constants = getattr(names, 'constant_pairs', set())
            if all(((anchor, p) if direction == 'original' else (p, anchor)) in constants for p in partners):
                continue
            majority = max(partners.values())
            # Ties have no majority: report every tied partner and its users.
            tied = len(set(partners.values())) == 1
            partner_side = 1 if direction == 'original' else 0
            minority = [p for p, count in partners.items() if tied or count < majority]

            def pair(partner):
                return (anchor, partner) if direction == 'original' else (partner, anchor)

            def users(partner):
                return sorted({u.function for u in evidence[pair(partner)]})

            detail = '%s-partners=[%s]' % (direction, ', '.join(
                '%s:%d%s' % (names.format(partner_side, p), count,
                              '{' + ','.join(users(p)) + '}' if p in minority else '')
                for p, count in sorted(partners.items(), key=lambda item: (-item[1], item[0]))))
            # One finding per non-bijective address, with every partner's
            # count and every minority caller. Prefer a conflicting name as
            # the displayed example, then an unknown partner, then a match.
            def priority(partner):
                old, new = pair(partner)
                both = bool(names.get(0, old) and names.get(1, new))
                severity = 2 if both and not names.same(old, new) else 0 if both else 1
                return severity, -partners[partner], -partner

            partner = max(minority, key=priority)
            old, new = pair(partner)
            callers = ','.join(sorted({u for p in minority for u in users(p)}))
            out.append(Finding(callers, 'inconsistency', old, new, detail))
    return sorted(out, key=lambda f: (f.function, f.kind, f.original, f.compiled, f.detail))


def run(argv):
    inp = Inputs(argv)
    names = Names(inp)
    evidence = collect(inp, names)
    return inp, names, evidence, findings(evidence, names)


def main(argv=None):
    try:
        inp, names, evidence, result = run(sys.argv[1:] if argv is None else argv)
    except (ValueError, OSError) as exc:
        sys.exit(str(exc))
    for f in result:
        print(f.line(names))
    conflicts = sum(f.kind == 'name-conflict' for f in result)
    print('%d findings in %d functions (%d name conflicts, %d inconsistencies)' % (
        len(result), len({(f.ova, f.nva) for f in inp.functions}), conflicts, len(result) - conflicts))


if __name__ == '__main__':
    main()
