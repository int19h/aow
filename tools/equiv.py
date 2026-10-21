"""Conservative relational translation validation for tools/match.py.

The input selection and MATCH/differ classification are the matcher's. Proofs
use unmasked instructions. Basic-block entries are cut points (including entry
and every loop head), and a Houdini fixed point discovers register equalities.
Each edge is then checked with arbitrary states satisfying its
invariant, rather than with a bounded execution of a loop.

Memory is a byte array. The inductive, deliberately strong invariant requires
the *whole* memory to correspond, including private stack bytes.  Consequently
aliasing, outgoing stack arguments and addresses passed to callees need no
disjoint-stack assumption.  Calls check the target, EAX/EDX/ECX, ESP and memory,
then havoc memory, volatile registers, flags and x87 state in common.  Havocing
even private bytes is a sound overapproximation of the requested call model.
It can lose proofs, but cannot hide a difference in a visible local.
For call-free acyclic functions an exact finite-path alternative projects out
private stack bytes while retaining arbitrary aliases in the unified array.

Reads and writes update the arrays; they are not ordered observable events.
Array equality is checked at calls, returns and inductive block boundaries.
PE relocation is by named symbols, consistent MATCH instruction positions,
function-local bijections and checked constant objects. The
comparison is in this common address space, as for a relocated executable.
Unresolved addresses, instruction forms and control flow fail closed.
"""

import collections
import bisect
import dataclasses
import json
import pathlib
import random
import re
import struct
import sys
import time

sys.dont_write_bytecode = True
import match

try:
    import z3
except ImportError:
    sys.path.append(r'C:\Tools\pylib')
    import z3

CS = match.capstone
X = CS.x86_const
REGS = ('eax', 'edx', 'ecx', 'ebx', 'esi', 'edi', 'ebp', 'esp')
FLAGS = ('cf', 'pf', 'af', 'zf', 'sf', 'of', 'df')
FP_OPS = frozenset(('fld fild fst fstp fist fistp fadd faddp fsub fsubp fsubr fsubrp '
                    'fmul fmulp fdiv fdivp fdivr fdivrp fxch fchs fabs fsqrt fld1 fldz '
                    'fldln2 fyl2x fcom fcomp fcompp fnstsw fnstcw fldcw wait').split())
INTEGER_OPS = frozenset(('nop mov movsx movzx lea xchg add adc sub sbb cmp inc dec and or xor test '
                         'not neg shl sal shr sar imul mul idiv div bound bt bts btr btc '
                         'push pop leave cdq cwde clc stc cld std sahf lahf call ret jmp').split())
BV32 = z3.BitVecSort(32)
BYTE = z3.BitVecSort(8)
MEM = z3.ArraySort(BV32, BYTE)
FP_BITS = 80 * 8 + 64
ALL = frozenset((a, b, lane) for a in REGS for b in REGS for lane in range(4))
DIAG = frozenset((a, a, lane) for a in REGS for lane in range(4))


def register_byte(state, reg, lane):
    return simp(z3.Extract(lane * 8 + 7, lane * 8, state.regs[reg]))


class Unsupported(Exception):
    pass


class NotProven(Exception):
    pass


def bv(v, bits=32):
    return z3.BitVecVal(v % (1 << bits), bits)


def simp(v):
    return z3.simplify(v)


def equal(a, b):
    return a.sort() == b.sort() and (z3.eq(a, b) or z3.is_true(simp(a == b)))


def equality(a, b):
    return a == b if a.sort() == b.sort() else z3.BoolVal(False)


def unhash(name):
    return re.sub(r'@[0-9A-Fa-f]{8}$', '', name)


def prove(expressions):
    expressions = [e for e in expressions if not z3.is_true(simp(e))]
    if not expressions:
        return True
    s = z3.Solver()
    s.set(timeout=1500)
    s.add(z3.Not(z3.And(expressions)))
    return s.check() == z3.unsat


def conditional_facts(guard, equations):
    """Houdini's candidate filter, with one solver model removing many facts.

    Timeouts and the model budget discard unproved candidates. They never
    turn a satisfiable/unknown result into a proof.
    """
    if z3.is_false(simp(guard)):
        return set(equations)
    if not equations:
        return set()
    remaining = dict(equations)
    solver = z3.Solver()
    solver.set(timeout=50)
    solver.add(guard)
    for _ in range(4):
        solver.push()
        solver.add(z3.Not(z3.And(list(remaining.values()))))
        answer = solver.check()
        if answer == z3.unsat:
            solver.pop()
            return set(remaining)
        if answer != z3.sat:
            solver.pop()
            return set()
        model = solver.model()
        removed = [key for key, expr in remaining.items() if z3.is_false(model.eval(expr, model_completion=True))]
        solver.pop()
        if not removed:
            return set()
        for key in removed:
            del remaining[key]
        if not remaining:
            return set()
    return set()


@dataclasses.dataclass
class Function:
    name: str
    original_name: str
    ova: int
    osize: int
    nva: int
    nsize: int
    a: list
    b: list

    @property
    def differs(self):
        return match.compare(self.a, self.b) != -1


class Inputs:
    """Keep match.py's function selection, truncation and normalization intact."""
    def __init__(self, argv):
        argv = list(argv)
        aliases = {}
        alias_dirs = set()
        units = []
        self.mutate = 0
        self.show = None
        while argv and argv[0].startswith('--'):
            opt = argv.pop(0)
            if opt == '--quiet':
                continue
            if opt == '--mutate':
                self.mutate = int(argv.pop(0))
                if self.mutate < 0:
                    raise ValueError('--mutate must be nonnegative')
            elif opt == '--show':
                self.show = argv.pop(0)
            elif opt == '--alias':
                alias_path = pathlib.Path(argv.pop(0))
                alias_dirs.add(alias_path.parent)
                with open(alias_path, encoding='utf-8') as f:
                    aliases.update(json.load(f))
            elif opt == '--units':
                units += argv.pop(0).split(',')
            else:
                raise ValueError('unknown option ' + opt)
        if len(argv) < 4:
            raise ValueError('usage: equiv.py [match options] [--mutate N] exe map original signatures [classes ...]')
        exe, mapf, orig, sigf, *classes = argv
        self.old, self.new = match.Image(orig), match.Image(exe)
        self.syms, _ = match.map_symbols(mapf)
        with open(sigf, encoding='utf-8') as f:
            self.sigs = {fn['name'].split('@')[0]: (int(fn['addr'], 16), fn['size']) for fn in json.load(f)}
        self.text = self.new.base + self.new.pe.sections[0].VirtualAddress
        self.code_syms = sorted((off, n) for n, locs in self.syms.items() for seg, off in locs if seg == '0001')
        self.code_offsets = sorted(set(o for o, _ in self.code_syms))
        pairs = []
        aliased = set(aliases.values())
        alias_addrs = {int(k.split(':')[0], 16) for k in aliases if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', k)}
        for spec in classes:
            oc, _, nc = spec.partition('=')
            nc = nc or oc
            for off, name in self.code_syms:
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
                ps = k.split('.')
                if (len(ps) == 2 and ps[0] == unit and ps[1] in self.syms
                        and ps[1] not in aliased and k not in aliases
                        and ps[1] not in (unit, 'Finalization')):
                    pairs.append((ps[1], k))
        for on, name in aliases.items():
            if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', on):
                addr, size = on.split(':')
                self.sigs[on] = (int(addr, 16), int(size))
            pairs.append((name, on if on in self.sigs else None))
        self.pairs = pairs
        md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
        oe = match.find_import_thunk(self.old, 'System.@HandleOnException')
        ne = self.text + self.syms['@HandleOnException'][0][1] if '@HandleOnException' in self.syms else None
        self.functions = []
        for name, on in pairs:
            loc = match.resolve(self.syms, name)
            if on is None or loc is None:
                continue
            ova, osize = self.sigs[on]
            seg, off = loc
            nva = self.text + off
            nxt = min((o for o in self.code_offsets if o > off), default=off + osize + 64)
            nsize = nxt - off
            a = match.disasm_skipping_tables(md, self.old, ova, osize, oe)
            b = match.disasm_skipping_tables(md, self.new, nva, min(nsize, osize + 32), ne)[:len(a)]
            self.functions.append(Function(name, on, ova, osize, nva, nsize, a, b))
        # Address evidence belongs to the module, not to the selected report
        # group. Include all resolvable signatures and all module alias files.
        module_aliases = {}
        for directory in sorted(alias_dirs):
            for path in sorted(directory.glob('*.json')):
                with open(path, encoding='utf-8') as f:
                    module_aliases.update(json.load(f))
        module_aliases.update(aliases)
        module_pairs = set(pairs)
        for on in self.sigs:
            name = on.split('.', 1)[-1]
            if name in self.syms and on not in module_aliases:
                module_pairs.add((name, on))
        for on, name in module_aliases.items():
            if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', on):
                addr, size = on.split(':')
                self.sigs.setdefault(on, (int(addr, 16), int(size)))
            if on in self.sigs:
                module_pairs.add((name, on))
        self.module_matches = []
        for name, on in sorted(module_pairs, key=lambda p: (p[0], p[1] or '')):
            loc = match.resolve(self.syms, name)
            if on is None or loc is None or loc[0] != '0001':
                continue
            ova, osize = self.sigs[on]
            nva = self.text + loc[1]
            nxt = min((o for o in self.code_offsets if o > loc[1]), default=loc[1] + osize + 64)
            aa = match.disasm_skipping_tables(md, self.old, ova, osize, oe)
            bb = match.disasm_skipping_tables(md, self.new, nva, min(nxt - loc[1], osize + 32), ne)[:len(aa)]
            if match.compare(aa, bb) == -1:
                self.module_matches.append((ova, osize, nva, min(nxt - loc[1], osize + 32), len(aa)))
        self.addresses = Addresses(self)


class Addresses:
    """A partial, injective relocation, anchored in independent symbol names."""
    def __init__(self, inp):
        self.inp = inp
        self.old, self.new = inp.old, inp.new
        self.forward = {}
        self.reverse = {}
        self.conflicts = set()
        self.names = [{}, {}]
        self.relocs = []
        self.sorted_relocs = []
        self.imports = []
        self.import_bytes = []
        self.import_locations = []
        self.vmts = []
        for side, img in enumerate((self.old, self.new)):
            img.pe.parse_data_directories(directories=[
                match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT'],
                match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT'],
                match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_BASERELOC']])
            imps = {}
            identities = {}
            for e in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
                for i in e.imports:
                    identities[i.address] = (e.dll.lower(), ('name', bytes(i.name)) if i.name else ('ordinal', i.ordinal))
                    if i.name:
                        name = unhash(i.name.decode('latin1'))
                        imps[i.address] = name
                        self.names[side][i.address] = 'iat:' + name
            self.imports.append(imps)
            self.import_bytes.append({a + k for a in identities for k in range(4)})
            self.import_locations.append(identities)
            for e in getattr(getattr(img.pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []):
                if e.name:
                    self.names[side][img.base + e.address] = unhash(e.name.decode('latin1'))
            rel = {img.base + e.rva for b in getattr(img.pe, 'DIRECTORY_ENTRY_BASERELOC', []) for e in b.entries if e.type == 3}
            self.relocs.append(rel)
            self.sorted_relocs.append(sorted(rel))
            # Import thunks are named code, not arbitrary masked call addresses.
            for cell, name in imps.items():
                pat = b'\xff\x25' + struct.pack('<I', cell)
                start = 0
                while True:
                    pos = img.data.find(pat, start)
                    if pos < 0:
                        break
                    self.names[side][img.base + pos] = name
                    identities[img.base + pos] = identities[cell]
                    start = pos + 1
            vmts = {}
            for pos in sorted(rel):
                v = self.u32(img, pos)
                if v != pos + 64 or not img.contains(v):
                    continue
                cn = self.u32(img, v - 32)
                if not img.contains(cn):
                    continue
                data = img.bytes_at(cn, 65)
                if data and 0 < data[0] <= 64:
                    name = data[1:1 + data[0]]
                    if re.fullmatch(rb'[A-Za-z_]\w*', name):
                        vmts[v] = name.decode('ascii')
                        self.names[side][v] = 'vmt:' + name.decode('ascii')
                        self.names[side][v - 64] = 'vmtref:' + name.decode('ascii')
            self.vmts.append(vmts)
        # MAP segment 2 is relative to DATA (including its aligned BSS offsets).
        data = next((s for s in self.new.pe.sections if s.Name.rstrip(b'\0') in (b'DATA', b'.data')), None)
        self.map_addresses = {}
        for name, locs in inp.syms.items():
            addresses = []
            for seg, off in locs:
                if seg == '0001':
                    addresses.append(inp.text + off)
                elif seg == '0002' and data is not None:
                    addresses.append(self.new.base + data.VirtualAddress + off)
            if len(set(addresses)) == 1:
                self.map_addresses[name] = addresses[0]
        # Original signatures and PE exports carry unit-qualified names; MAP
        # symbols usually omit the unit.  Ambiguous short names are rejected.
        old_names = dict(self.names[0])
        old_names.update({a: n for n, (a, _) in inp.sigs.items() if not n.startswith('FUN_')})
        for addr, name in old_names.items():
            if name.startswith('iat:'):
                continue
            candidates = []
            for key in (name, name.split('.', 1)[-1], name.rsplit('.', 1)[-1]):
                if key in self.map_addresses:
                    candidates.append(self.map_addresses[key])
                    break
            if len(set(candidates)) == 1:
                self.bind(addr, candidates[0])
        for f in inp.functions:
            self.bind(f.ova, f.nva)
        by_name = collections.defaultdict(list)
        for a, n in self.names[1].items():
            by_name[n].append(a)
        for a, n in self.names[0].items():
            if len(by_name[n]) == 1:
                self.bind(a, by_name[n][0])
        # Relocated pointer cells can be independently identified by the named
        # object they refer to.  Do not collapse multiple cells with one value.
        for _ in range(3):
            old_cells, new_cells = collections.defaultdict(list), collections.defaultdict(list)
            for side, img, cells in ((0, self.old, old_cells), (1, self.new, new_cells)):
                for a in self.relocs[side]:
                    v = self.u32(img, a)
                    if side == 1:
                        v = self.reverse.get(v)
                    elif v not in self.forward:
                        v = None
                    if v is not None:
                        cells[v].append(a)
            for key, aa in old_cells.items():
                bb = new_cells.get(key, [])
                if len(aa) == len(bb) == 1:
                    self.bind(aa[0], bb[0])
        evidence = []
        for ova, osize, nva, nsize, count in inp.module_matches:
            aa, bb = decode(self.old, ova, osize), decode(self.new, nva, nsize)[:count]
            # Embedded tables are not instruction evidence. The normalized
            # raw streams must themselves agree before using their positions.
            if len(aa) == len(bb) and all(match.normalize(x.raw, self.old) == match.normalize(y.raw, self.new) for x, y in zip(aa, bb)):
                evidence.extend(self.aligned_addresses(aa, bb))
        self.install_consistent(evidence)
        self.install_content()

    def content_records(self, side):
        """Typed immutable objects and loader identities, indexed by contents.

        Class identities follow Delphi 3's documented VMT / TTypeInfo layout.
        Literal bytes must have the immutable AnsiString header and contain no
        relocations. An object with duplicate identities is never guessed.
        """
        img = (self.old, self.new)[side]
        records = collections.defaultdict(set)
        for section in img.pe.sections:
            if section.Characteristics & 0x80000000:
                continue
            lo = img.base + section.VirtualAddress
            data = img.bytes_at(lo, section.Misc_VirtualSize)
            pos = 0
            while True:
                pos = data.find(b'\xff\xff\xff\xff', pos)
                if pos < 0:
                    break
                address = lo + pos + 8
                payload = self.string_object(side, address)
                if payload is not None:
                    records['string', payload].add(address)
                pos += 1
        for vmt, name in self.vmts[side].items():
            # An independently established VMT pair disambiguates duplicate
            # short class names. Do not invent an owner from address order.
            other = self.forward.get(vmt) if side == 0 else self.reverse.get(vmt)
            identity = ('paired-class', vmt if side == 0 else other) if other is not None and self.vmts[1-side].get(other) == name else ('class-name', name)
            # All fixed VMT header fields denote locations in the same named
            # record; their values are still interpreted and compared normally.
            for off in range(-64, 1, 4):
                records['vmt-field', identity, off].add(vmt + off)
            cn = self.u32(img, vmt - 32)
            data = img.bytes_at(cn, len(name) + 1)
            if data == bytes((len(name),)) + name.encode('ascii'):
                for off in range(len(data)):
                    records['class-name', identity, off].add(cn + off)
            info = self.u32(img, vmt - 48)
            n = len(name)
            if not self.readonly(side, info, 2 + n + 4):
                continue
            data = img.bytes_at(info, n + 2)
            # tkClass = 7; TypeData immediately follows the short type name,
            # and its first field is the owning class reference.
            if data != bytes((7, n)) + name.encode('ascii') or self.u32(img, info + n + 2) != vmt:
                continue
            for off in range(n + 2):
                records['class-typeinfo', identity, off].add(info + off)
            for off in (n + 2, n + 6, n + 10, n + 12):
                records['class-typeinfo-field', identity, off].add(info + off)
        for entry in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
            for imp in entry.imports:
                name = (entry.dll.lower(), ('name', bytes(imp.name)) if imp.name else ('ordinal', imp.ordinal))
                for off in range(4):
                    records['import-cell', name, off].add(imp.address + off)
                pattern = b'\xff\x25' + struct.pack('<I', imp.address)
                for section in img.pe.sections:
                    if not section.Characteristics & 0x20000000:
                        continue
                    lo = img.base + section.VirtualAddress
                    data = img.bytes_at(lo, section.Misc_VirtualSize)
                    pos = 0
                    while True:
                        pos = data.find(pattern, pos)
                        if pos < 0:
                            break
                        records['import-thunk', name].add(lo + pos)
                        if hasattr(self, 'import_locations'):
                            self.import_locations[side][lo + pos] = name
                        pos += 1
        return records

    def install_content(self):
        records = [self.content_records(s) for s in (0, 1)]
        for _ in range(3):
            evidence = []
            for key, aa in records[0].items():
                bb = records[1].get(key, set())
                established = {(a, self.forward[a]) for a in aa if a in self.forward and self.forward[a] in bb and self.reverse.get(self.forward[a]) == a}
                left = aa - {a for a, _ in established}
                right = set(bb) - {b for _, b in established}
                if len(left) == len(right) == 1:
                    established.add((next(iter(left)), next(iter(right))))
                evidence.extend(established)
                if key[0] == 'string':
                    # Preserve offsets, including interior / header pointers.
                    for a, b in established:
                        evidence.extend((a + off, b + off) for off in range(-8, len(key[1])))
            before = len(self.forward)
            self.install_consistent(evidence)
            if len(self.forward) == before:
                break
        # A newly identified class/type/string can also identify a unique
        # relocated cell pointing to it. Reject duplicates on both sides.
        for _ in range(3):
            cells = [collections.defaultdict(set), collections.defaultdict(set)]
            for side, img in enumerate((self.old, self.new)):
                for address in self.relocs[side]:
                    value = self.u32(img, address)
                    identity = value if side == 0 and value in self.forward else self.reverse.get(value) if side == 1 else None
                    if identity is not None:
                        cells[side][identity].add(address)
            self.install_consistent((next(iter(aa)), next(iter(cells[1][key])))
                                    for key, aa in cells[0].items()
                                    if len(aa) == len(cells[1].get(key, ())) == 1)

    def absolute(self, side, ins, op):
        if op.type == X.X86_OP_IMM:
            v = op.imm & 0xffffffff
        elif op.type == X.X86_OP_MEM and not op.mem.segment and not op.mem.base and (not op.mem.index or abs(op.mem.disp) > 0x10000):
            v = op.mem.disp & 0xffffffff
        else:
            return None
        return v if (self.old, self.new)[side].contains(v) else None

    def aligned_addresses(self, aa, bb):
        pairs = []
        for x, y in zip(aa, bb):
            for u, v in zip(x.operands, y.operands):
                if u.type != v.type:
                    continue
                a, b = self.absolute(0, x, u), self.absolute(1, y, v)
                if a is None or b is None:
                    continue
                sx, sy = self.string_object(0, a), self.string_object(1, b)
                if sx is not None and sy is not None and sx != sy:
                    # Contents are observable even when pointer positions match.
                    continue
                pairs.append((a, b))
        return pairs

    def install_consistent(self, pairs):
        forward, reverse = collections.defaultdict(set), collections.defaultdict(set)
        for a, b in pairs:
            forward[a].add(b)
            reverse[b].add(a)
        for a, bs in forward.items():
            if len(bs) != 1:
                continue
            b = next(iter(bs))
            if len(reverse[b]) != 1:
                continue
            if a in self.forward and self.forward[a] != b or b in self.reverse and self.reverse[b] != a:
                continue
            self.bind(a, b)

    @staticmethod
    def u32(img, a):
        b = img.bytes_at(a, 4)
        return struct.unpack('<I', b)[0] if len(b) == 4 else 0

    def bind(self, a, b):
        imports = getattr(self, 'import_locations', ({}, {}))
        if a in imports[0] and b in imports[1] and imports[0][a] != imports[1][b]:
            return False
        if (a in self.forward and self.forward[a] != b) or (b in self.reverse and self.reverse[b] != a):
            self.conflicts.add(a)
            self.conflicts.add(b)
            return False
        self.forward[a] = b
        self.reverse[b] = a
        return True

    def canonical(self, side, value, local):
        value &= 0xffffffff
        img = (self.old, self.new)[side]
        if not img.contains(value):
            return value
        if value in self.conflicts:
            raise Unsupported('ambiguous relocation')
        if side == 0 and value in self.forward:
            return value
        if side == 1 and value in self.reverse:
            return self.reverse[value]
        raise Unsupported('unresolved image address 0x%x' % value)

    def readonly(self, side, addr, size):
        img = (self.old, self.new)[side]
        for sec in img.pe.sections:
            lo = img.base + sec.VirtualAddress
            hi = lo + sec.Misc_VirtualSize
            if lo <= addr and addr + size <= hi:
                return not sec.Characteristics & 0x80000000
        return False

    def read_constant(self, side, addr, size, local):
        if not self.readonly(side, addr, size):
            return None
        relocations = self.sorted_relocs[side]
        overlap = relocations[bisect.bisect_left(relocations, addr - 3):bisect.bisect_left(relocations, addr + size)]
        img = (self.old, self.new)[side]
        if not overlap:
            data = img.bytes_at(addr, size)
            return bv(int.from_bytes(data, 'little'), size * 8)
        if size == 4 and overlap == [addr]:
            return bv(self.canonical(side, self.u32(img, addr), local))
        raise Unsupported('partial relocated constant')

    def pointer_identity(self, side, addr):
        if addr not in self.relocs[side]:
            return None
        img = (self.old, self.new)[side]
        target = self.u32(img, addr)
        if side == 0 and target in self.forward:
            return ('pointer', target)
        if side == 1 and target in self.reverse:
            return ('pointer', self.reverse[target])
        return None

    def string_object(self, side, addr):
        img = (self.old, self.new)[side]
        if not self.readonly(side, addr - 8, 8):
            return None
        refcount, length = struct.unpack('<II', img.bytes_at(addr - 8, 8))
        if refcount != 0xffffffff or length > 65536 or not self.readonly(side, addr, length + 1):
            return None
        data = img.bytes_at(addr, length + 1)
        if len(data) != length + 1 or data[-1] != 0:
            return None
        rel = self.sorted_relocs[side]
        index = bisect.bisect_left(rel, addr - 8)
        if index < len(rel) and rel[index] < addr + length + 1:
            return None
        return data


@dataclasses.dataclass
class MemoryOperand:
    base: int
    index: int
    scale: int
    disp: int
    segment: int


@dataclasses.dataclass
class Operand:
    type: int
    size: int
    reg: int
    imm: int
    mem: MemoryOperand

    @classmethod
    def from_capstone(cls, op):
        m = op.mem
        return cls(op.type, op.size, op.reg, op.imm, MemoryOperand(m.base, m.index, m.scale, m.disp, m.segment))


@dataclasses.dataclass
class Insn:
    address: int
    size: int
    mnemonic: str
    op_str: str
    operands: list
    raw: object
    mutation: str = ''
    flow: object = None
    eh: tuple = ()
    handler_return: bool = False

    def reg_name(self, reg):
        return self.raw.reg_name(reg)


def decode(img, start, size, on_exception=None):
    md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
    md.detail = True
    result, pos = [], start
    end = start + size
    while pos < end:
        for i in md.disasm(img.bytes_at(pos, end - pos), pos):
            result.append(Insn(i.address, i.size, i.mnemonic, i.op_str, [Operand.from_capstone(o) for o in i.operands], i))
            pos = i.address + i.size
            if i.mnemonic == 'jmp' and i.operands[0].type == X.X86_OP_IMM and i.operands[0].imm == on_exception:
                if pos + 4 > end:
                    raise Unsupported('truncated exception table')
                n = Addresses.u32(img, pos)
                if not 0 < n < 16 or pos + 4 + 8 * n > end:
                    raise Unsupported('invalid / truncated exception table')
                pos += 4 + 8 * n
                break
        else:
            break
    return result


ALIASES = {}
for root in REGS:
    names = (root, root[1:])
    for name, bits in zip(names, (32, 16)):
        ALIASES[name] = (root, bits, 0)
for root in ('eax', 'ebx', 'ecx', 'edx'):
    ALIASES[root[1] + 'l'] = (root, 8, 0)
    ALIASES[root[1] + 'h'] = (root, 8, 8)


class State:
    def __init__(self, regs, flags, memory, fs, fp):
        self.regs, self.flags, self.memory, self.fs, self.fp = regs, flags, memory, fs, fp
        self.events = []
        self.condition = z3.BoolVal(True)

    def reg(self, name):
        if name not in ALIASES:
            raise Unsupported('register ' + name)
        root, bits, off = ALIASES[name]
        v = self.regs[root]
        return v if bits == 32 else z3.Extract(off + bits - 1, off, v)

    def putreg(self, name, value):
        if name not in ALIASES:
            raise Unsupported('register ' + name)
        root, bits, off = ALIASES[name]
        if value.size() != bits:
            raise Unsupported('register width')
        if bits == 32:
            self.regs[root] = simp(value)
        else:
            v = self.regs[root]
            parts = []
            if off + bits < 32:
                parts.append(z3.Extract(31, off + bits, v))
            parts.append(value)
            if off:
                parts.append(z3.Extract(off - 1, 0, v))
            self.regs[root] = simp(z3.Concat(parts))

    def load(self, addr, size, fs=False):
        mem = self.fs if fs else self.memory
        value = simp(z3.Concat([z3.Select(mem, addr + bv(i)) for i in reversed(range(size))])) if size > 1 else z3.Select(mem, addr)
        return value

    def store(self, addr, value, fs=False):
        mem = self.fs if fs else self.memory
        for i in range(value.size() // 8):
            mem = z3.Store(mem, simp(addr + bv(i)), z3.Extract(i * 8 + 7, i * 8, value))
        if fs:
            self.fs = simp(mem)
        else:
            self.memory = simp(mem)


def arbitrary(candidates, flag_candidates):
    parent = {(s, r, lane): (s, r, lane) for s in (0, 1) for r in REGS for lane in range(4)}

    def find(x):
        while parent[x] != x:
            x = parent[x]
        return x

    for a, b, lane in candidates:
        parent[find((1, b, lane))] = find((0, a, lane))
    values = {}
    regs = []
    for s in (0, 1):
        rr = {}
        for r in REGS:
            parts = []
            for lane in reversed(range(4)):
                key = find((s, r, lane))
                parts.append(values.setdefault(key, z3.BitVec('r_%s_%s_%s' % key, 8)))
            rr[r] = z3.Concat(parts)
        regs.append(rr)
    ff = []
    for s in (0, 1):
        ff.append({f: z3.Bool('f_%d_%s' % (0 if f in flag_candidates else s, f)) for f in FLAGS})
    memory = z3.Array('memory', BV32, BYTE)
    fs = z3.Array('fs_memory', BV32, BYTE)
    # An opaque x87 machine includes the 80-bit stack and control/status state.
    fp = z3.BitVec('x87_machine', 80 * 8 + 64)
    return [State(regs[s], ff[s], memory, fs, fp) for s in (0, 1)]


class Machine:
    def __init__(self, addresses, side, local):
        self.addresses, self.side, self.local = addresses, side, local

    def constant(self, v, bits=32):
        return bv(self.addresses.canonical(self.side, v, self.local), bits)

    def address(self, st, ins, op):
        m = op.mem
        if m.segment and ins.reg_name(m.segment) != 'fs':
            raise Unsupported('segment override ' + ins.reg_name(m.segment))
        addr = bv(0)
        if m.base:
            addr += st.reg(ins.reg_name(m.base))
        if m.index:
            addr += st.reg(ins.reg_name(m.index)) * bv(m.scale)
        # Only an absolute displacement is an image address.  Object field
        # offsets stay literal, including a mutant offset that resembles one.
        if not m.segment and not m.base and (not m.index or abs(m.disp) > 0x10000):
            addr += self.constant(m.disp)
        else:
            addr += bv(m.disp)
        return simp(addr)

    def read(self, st, ins, op):
        if op.type == X.X86_OP_REG:
            return st.reg(ins.reg_name(op.reg))
        if op.type == X.X86_OP_IMM:
            relocated = ins.address + ins.raw.imm_offset in self.addresses.relocs[self.side]
            if relocated or ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
                return self.constant(op.imm, op.size * 8)
            return bv(op.imm, op.size * 8)
        if op.type == X.X86_OP_MEM:
            if not op.mem.base and not op.mem.index and not op.mem.segment:
                imports = getattr(self.addresses, 'import_bytes', ((), ()))[self.side]
                # On-disk IAT words are loader RVAs, not the runtime function
                # pointers. Read the paired symbolic cell, so intervening or
                # aliased writes also remain visible to indirect calls.
                if not any(op.mem.disp + k in imports for k in range(op.size)):
                    constant = self.addresses.read_constant(self.side, op.mem.disp, op.size, self.local)
                    if constant is not None:
                        return constant
            return st.load(self.address(st, ins, op), op.size, bool(op.mem.segment))
        raise Unsupported('operand form')

    def write(self, st, ins, op, value):
        if op.type == X.X86_OP_REG:
            st.putreg(ins.reg_name(op.reg), value)
        elif op.type == X.X86_OP_MEM:
            if not (op.mem.segment or op.mem.base or op.mem.index) and self.addresses.readonly(self.side, op.mem.disp, op.size):
                raise Unsupported('write to executable / read-only image')
            st.store(self.address(st, ins, op), value, bool(op.mem.segment))
            if ins.eh:
                st.events.append(('frame-install', *(self.constant(v) for v in ins.eh)))
        else:
            raise Unsupported('destination form')

    @staticmethod
    def common_flags(st, result):
        bits = result.size()
        st.flags['zf'] = result == bv(0, bits)
        st.flags['sf'] = z3.Extract(bits - 1, bits - 1, result) == bv(1, 1)
        byte = z3.Extract(7, 0, result)
        parity = z3.BoolVal(False)
        for i in range(8):
            parity = z3.Xor(parity, z3.Extract(i, i, byte) == bv(1, 1))
        st.flags['pf'] = z3.Not(parity)

    def arithmetic(self, st, op, a, b):
        bits = a.size()
        if op in ('add', 'adc', 'inc'):
            carry = z3.If(st.flags['cf'], bv(1, bits), bv(0, bits)) if op == 'adc' else bv(0, bits)
            r = a + b + carry
            ext = z3.ZeroExt(1, a) + z3.ZeroExt(1, b) + z3.ZeroExt(1, carry)
            cf = z3.Extract(bits, bits, ext) == bv(1, 1)
            of = z3.Extract(bits - 1, bits - 1, (~(a ^ b)) & (a ^ r)) == bv(1, 1)
        else:
            carry = z3.If(st.flags['cf'], bv(1, bits), bv(0, bits)) if op == 'sbb' else bv(0, bits)
            r = a - b - carry
            cf = z3.ULT(z3.ZeroExt(1, a), z3.ZeroExt(1, b) + z3.ZeroExt(1, carry))
            of = z3.Extract(bits - 1, bits - 1, (a ^ b) & (a ^ r)) == bv(1, 1)
        self.common_flags(st, r)
        st.flags['of'] = of
        st.flags['af'] = z3.Extract(4, 4, a ^ b ^ r) == bv(1, 1)
        if op not in ('inc', 'dec'):
            st.flags['cf'] = cf
        return simp(r)

    @staticmethod
    def condition(st, suffix):
        f = st.flags
        conditions = {
            'e': f['zf'], 'z': f['zf'], 'ne': z3.Not(f['zf']), 'nz': z3.Not(f['zf']),
            'b': f['cf'], 'c': f['cf'], 'nae': f['cf'],
            'ae': z3.Not(f['cf']), 'nb': z3.Not(f['cf']), 'nc': z3.Not(f['cf']),
            'be': z3.Or(f['cf'], f['zf']), 'a': z3.And(z3.Not(f['cf']), z3.Not(f['zf'])),
            'l': f['sf'] != f['of'], 'ge': f['sf'] == f['of'],
            'le': z3.Or(f['zf'], f['sf'] != f['of']), 'g': z3.And(z3.Not(f['zf']), f['sf'] == f['of']),
            'o': f['of'], 'no': z3.Not(f['of']), 's': f['sf'], 'ns': z3.Not(f['sf']),
            'p': f['pf'], 'pe': f['pf'], 'np': z3.Not(f['pf']), 'po': z3.Not(f['pf'])}
        if suffix not in conditions:
            raise Unsupported('condition ' + suffix)
        return conditions[suffix]

    def step(self, st, ins):
        m, oo = ins.mnemonic, ins.operands
        if ins.raw.addr_size != 4:
            raise Unsupported('16-bit address size')
        if m in ('ret', 'leave', 'call', 'jmp') and 0x66 in ins.raw.prefix:
            raise Unsupported('16-bit control / stack operand size')
        undef = lambda flag: z3.Bool('undefined_%d_%x_%s' % (self.side, ins.address, flag))
        rd = lambda i: self.read(st, ins, oo[i])
        wr = lambda i, v: self.write(st, ins, oo[i], v)
        if ins.mutation == 'drop store':
            return
        if m == 'nop':
            return
        if m == 'mov':
            wr(0, rd(1))
        elif m in ('movsx', 'movzx'):
            v = rd(1)
            wr(0, (z3.SignExt if m == 'movsx' else z3.ZeroExt)(oo[0].size * 8 - v.size(), v))
        elif m == 'lea':
            wr(0, self.address(st, ins, oo[1]))
        elif m == 'xchg':
            if any(op.type != X.X86_OP_REG for op in oo):
                raise Unsupported('memory xchg')
            a, b = rd(0), rd(1)
            wr(0, b)
            wr(1, a)
        elif m in ('add', 'adc', 'sub', 'sbb', 'cmp', 'inc', 'dec'):
            a = rd(0)
            b = bv(1, a.size()) if m in ('inc', 'dec') else rd(1)
            v = self.arithmetic(st, m, a, b)
            if m != 'cmp':
                wr(0, v)
        elif m in ('and', 'or', 'xor', 'test'):
            a, b = rd(0), rd(1)
            v = (a & b) if m in ('and', 'test') else (a | b) if m == 'or' else (a ^ b)
            self.common_flags(st, v)
            st.flags['cf'] = st.flags['of'] = z3.BoolVal(False)
            st.flags['af'] = undef('af')
            if m != 'test':
                wr(0, v)
        elif m == 'not':
            wr(0, ~rd(0))
        elif m == 'neg':
            a = rd(0)
            v = self.arithmetic(st, 'sub', bv(0, a.size()), a)
            wr(0, v)
        elif m in ('shl', 'sal', 'shr', 'sar'):
            a, count = rd(0), rd(1)
            bits = a.size()
            count = z3.ZeroExt(bits - count.size(), count) if count.size() < bits else count
            count = count & bv(31, bits)
            v = (a << count) if m in ('shl', 'sal') else z3.LShR(a, count) if m == 'shr' else a >> count
            prior = dict(st.flags)
            self.common_flags(st, v)
            cf = z3.Extract(0, 0, z3.LShR(a, bv(bits, bits) - count)) == bv(1, 1) if m in ('shl', 'sal') else z3.Extract(0, 0, z3.LShR(a, count - bv(1, bits))) == bv(1, 1)
            of = ((z3.Extract(bits - 1, bits - 1, v) == bv(1, 1)) != cf) if m in ('shl', 'sal') else (z3.Extract(bits - 1, bits - 1, a) == bv(1, 1)) if m == 'shr' else z3.BoolVal(False)
            if m == 'sar':
                st.flags['cf'] = z3.If(z3.ULT(count, bv(bits, bits)), cf, z3.Extract(bits - 1, bits - 1, a) == bv(1, 1))
            else:
                st.flags['cf'] = z3.If(z3.ULT(count, bv(bits, bits)), cf, undef('cf'))
            st.flags['of'] = z3.If(count == bv(1, bits), of, undef('of'))
            st.flags['af'] = undef('af')
            for f in ('cf', 'of', 'af', 'sf', 'zf', 'pf'):
                st.flags[f] = z3.If(count == bv(0, bits), prior[f], st.flags[f])
            wr(0, v)
        elif m == 'imul' and len(oo) in (2, 3):
            aa, bb = (rd(0), rd(1)) if len(oo) == 2 else (rd(1), rd(2))
            bits = aa.size()
            full = z3.SignExt(bits, aa) * z3.SignExt(bits, bb)
            v = z3.Extract(bits - 1, 0, full)
            st.flags['cf'] = st.flags['of'] = full != z3.SignExt(bits, v)
            for f in ('sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
            wr(0, v)
        elif m in ('imul', 'mul') and len(oo) == 1 and oo[0].size == 4:
            a, b = st.regs['eax'], rd(0)
            ext = z3.SignExt if m == 'imul' else z3.ZeroExt
            full = ext(32, a) * ext(32, b)
            st.regs['eax'] = simp(z3.Extract(31, 0, full))
            st.regs['edx'] = simp(z3.Extract(63, 32, full))
            overflow = full != ext(32, st.regs['eax'])
            st.flags['cf'] = st.flags['of'] = overflow
            for f in ('sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m in ('idiv', 'div') and len(oo) == 1 and oo[0].size == 4:
            divisor = rd(0)
            dividend = z3.Concat(st.regs['edx'], st.regs['eax'])
            ext = z3.SignExt(32, divisor) if m == 'idiv' else z3.ZeroExt(32, divisor)
            quotient = dividend / ext if m == 'idiv' else z3.UDiv(dividend, ext)
            remainder = z3.SRem(dividend, ext) if m == 'idiv' else z3.URem(dividend, ext)
            q = z3.Extract(31, 0, quotient)
            overflow = quotient != (z3.SignExt(32, q) if m == 'idiv' else z3.ZeroExt(32, q))
            fault = z3.Or(divisor == bv(0), overflow)
            st.events.append(('divide-exception', fault, st.memory, st.fs, st.fp))
            st.regs['eax'], st.regs['edx'] = simp(q), simp(z3.Extract(31, 0, remainder))
            for f in ('cf', 'of', 'sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m == 'bound' and len(oo) == 2 and oo[0].size == 4 and oo[1].type == X.X86_OP_MEM:
            value = rd(0)
            addr = self.address(st, ins, oo[1])
            low, high = st.load(addr, 4), st.load(addr + bv(4), 4)
            st.events.append(('bound-exception', z3.Or(value < low, value > high), st.memory, st.fs, st.fp))
        elif m in ('bt', 'bts', 'btr', 'btc') and len(oo) == 2 and oo[0].type == X.X86_OP_REG:
            a, index = rd(0), rd(1)
            bits = a.size()
            index = z3.ZeroExt(bits - index.size(), index) if index.size() < bits else index
            index = index & bv(bits - 1, bits)
            st.flags['cf'] = (z3.LShR(a, index) & bv(1, bits)) == bv(1, bits)
            if m != 'bt':
                mask = bv(1, bits) << index
                wr(0, a | mask if m == 'bts' else a & ~mask if m == 'btr' else a ^ mask)
            for f in ('of', 'sf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m == 'push':
            if oo[0].size != 4:
                raise Unsupported('non-dword push')
            v = rd(0)
            st.regs['esp'] = simp(st.regs['esp'] - bv(4))
            st.store(st.regs['esp'], v)
        elif m == 'pop':
            if oo[0].type != X.X86_OP_REG or oo[0].size != 4 or ins.reg_name(oo[0].reg) == 'esp':
                raise Unsupported('pop addressing form')
            v = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4))
            wr(0, v)
        elif m == 'leave':
            st.regs['esp'] = st.regs['ebp']
            st.regs['ebp'] = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4))
        elif m == 'cdq':
            st.regs['edx'] = simp(z3.If(st.regs['eax'] < bv(0), bv(-1), bv(0)))
        elif m == 'cwde':
            st.regs['eax'] = z3.SignExt(16, st.reg('ax'))
        elif m in ('clc', 'stc', 'cld', 'std'):
            st.flags['cf' if m in ('clc', 'stc') else 'df'] = z3.BoolVal(m in ('stc', 'std'))
        elif m == 'sahf':
            ah = st.reg('ah')
            for f, bit in (('sf', 7), ('zf', 6), ('af', 4), ('pf', 2), ('cf', 0)):
                st.flags[f] = z3.Extract(bit, bit, ah) == bv(1, 1)
        elif m == 'lahf':
            value = bv(2, 8)
            for f, bit in (('sf', 7), ('zf', 6), ('af', 4), ('pf', 2), ('cf', 0)):
                value |= z3.If(st.flags[f], bv(1 << bit, 8), bv(0, 8))
            st.putreg('ah', value)
        elif m.startswith('set'):
            wr(0, z3.If(self.condition(st, m[3:]), bv(1, 8), bv(0, 8)))
        elif m == 'jmp':
            if oo[0].type != X.X86_OP_IMM:
                raise Unsupported('indirect jump / jump table')
        elif m.startswith('j'):
            st.condition = self.condition(st, m[1:])
        elif m == 'call':
            target = rd(0)
            st.events.append(('call', target, st.regs['eax'], st.regs['edx'], st.regs['ecx'], st.regs['esp'], st.memory, st.fs, st.fp))
            tag = str(self.local[self.side].get(ins.address, ins.address))
            for r in ('eax', 'edx', 'ecx'):
                st.regs[r] = z3.BitVec('call_' + tag + '_' + r, 32)
            for f in FLAGS:
                st.flags[f] = z3.Bool('call_' + tag + '_' + f)
            st.memory = z3.Array('call_memory_' + tag, BV32, BYTE)
            st.fs = z3.Array('call_fs_' + tag, BV32, BYTE)
            st.fp = z3.BitVec('call_x87_' + tag, 80 * 8 + 64)
            # The same callee has the same stack cleanup.  Leaving it symbolic
            # avoids guessing an unknown virtual routine's parameter count.
            st.regs['esp'] = simp(st.regs['esp'] + z3.BitVec('call_stack_cleanup_' + tag, 32))
        elif m == 'eh-enter':
            st.events.append(('exception-helper', *(self.constant(v) for v in ins.eh)))
        elif m == 'ret':
            amount = oo[0].imm if oo else 0
            target = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4 + amount))
            if ins.handler_return:
                # @HandleFinally discards the cleanup's register results and
                # restores its own saved nonvolatile registers after CALL ECX.
                st.events.append(('finally-return', target, st.regs['esp']))
            else:
                st.events.append(('return', target, *(st.regs[r] for r in ('eax', 'edx', 'esp', 'ebx', 'esi', 'edi', 'ebp'))))
        elif m in FP_OPS:
            # The brief permits ordered uninterpreted x87 operations. The
            # state contains all eight 80-bit registers and control/status bits.
            # Equality of the complete input state also covers x87 exceptions.
            args = [st.fp]
            store = m in ('fst', 'fstp', 'fist', 'fistp', 'fnstsw', 'fnstcw')
            shape = []
            for op in oo:
                if op.type == X.X86_OP_REG and ins.reg_name(op.reg).startswith('st('):
                    shape.append(ins.reg_name(op.reg))
                elif op.type == X.X86_OP_MEM:
                    shape.append('mem%d' % op.size)
                    if not store:
                        args.append(self.read(st, ins, op))
                elif store and op.type == X.X86_OP_REG:
                    shape.append('reg%d' % op.size)
                else:
                    raise Unsupported('x87 operand ' + ins.op_str)
            site = self.local[self.side].get(ins.address, ins.address)
            key = m + '_' + '_'.join(shape)
            st.events.append(('x87:' + key, *args))
            key += '_site_%x' % site
            if store:
                if len(oo) != 1 or oo[0].type not in (X.X86_OP_REG, X.X86_OP_MEM):
                    raise Unsupported('x87 store form')
                bits = oo[0].size * 8
                value = z3.Function('x87_value_' + key, z3.BitVecSort(FP_BITS), z3.BitVecSort(bits))(st.fp)
                self.write(st, ins, oo[0], value)
            sorts = [v.sort() for v in args]
            st.fp = z3.Function('x87_step_' + key, *sorts, z3.BitVecSort(FP_BITS))(*args)
        else:
            raise Unsupported(m)


def successors(insns, index):
    ins = insns[index]
    m = ins.mnemonic
    by_addr = {i.address: j for j, i in enumerate(insns)}
    if ins.flow is not None:
        if any(t not in by_addr for t in ins.flow):
            raise Unsupported('incomplete exception continuation')
        return tuple(by_addr[t] for t in ins.flow)
    fall = index + 1
    if m == 'ret':
        return ()
    if m == 'jmp' or m.startswith('j'):
        if not ins.operands or ins.operands[0].type != X.X86_OP_IMM:
            raise Unsupported('indirect jump / jump table')
        target = ins.operands[0].imm
        if target not in by_addr:
            raise Unsupported('external jump')
        return (by_addr[target],) if m == 'jmp' else (by_addr[target], fall)
    if fall >= len(insns):
        raise Unsupported('incomplete function / fallthrough')
    return (fall,)


def blocks(insns, entry=0):
    reachable = {}
    todo = [entry]
    while todo:
        i = todo.pop()
        if i in reachable:
            continue
        if not 0 <= i < len(insns):
            raise Unsupported('incomplete function')
        reachable[i] = successors(insns, i)
        todo.extend(reachable[i])
    starts = {entry}
    for i, edges in reachable.items():
        if insns[i].mnemonic.startswith('j') or insns[i].flow is not None:
            starts.update(edges)
    result = {}
    for i in starts:
        seq = [i]
        while len(reachable[seq[-1]]) == 1:
            nxt = reachable[seq[-1]][0]
            if nxt in starts or insns[seq[-1]].mnemonic.startswith('j') or insns[seq[-1]].flow is not None:
                break
            seq.append(nxt)
        result[i] = (seq, reachable[seq[-1]])
    # Layout-only trampolines are epsilon transitions. Keep self loops, and
    # never remove instructions whose prefixes / operand sizes need modeling.
    changed = True
    while changed:
        changed = False
        for h, (seq, edges) in list(result.items()):
            if h == entry or len(edges) != 1 or edges[0] == h:
                continue
            if all(insns[k].mnemonic in ('nop', 'jmp') and insns[k].raw.addr_size == 4
                   and not any(insns[k].raw.prefix) for k in seq):
                target = edges[0]
                for p, (body, successors_) in list(result.items()):
                    result[p] = (body, tuple(target if x == h else x for x in successors_))
                del result[h]
                changed = True
                break
        if changed:
            continue
        incoming = collections.Counter(j for _, edges in result.values() for j in edges)
        for h, (seq, edges) in list(result.items()):
            if len(edges) == 1:
                target = edges[0]
                if target != entry and target != h and incoming[target] == 1:
                    following, out = result[target]
                    result[h] = (seq + following, out)
                    del result[target]
                    changed = True
                    break
    return result


def edge_guard(state, terminal, count, edge):
    # A handler table is nondeterministic in this overapproximation. Two
    # entries are not a Jcc: neither entry may get a vacuous false premise.
    conditional = (count == 2 and terminal.mnemonic.startswith('j') and terminal.mnemonic != 'jmp')
    if not conditional:
        return z3.BoolVal(True)
    return state.condition if edge == 0 else z3.Not(state.condition)


INVERSE_JUMP = dict(pair for a, b in (('je', 'jne'), ('jz', 'jnz'), ('jg', 'jle'),
                                    ('jge', 'jl'), ('ja', 'jbe'), ('jae', 'jb'),
                                    ('jo', 'jno'), ('js', 'jns'), ('jp', 'jnp'))
                    for pair in ((a, b), (b, a)))


def cfg_variants(a, b, graphs, entry, addresses):
    """Propose graph bijections by events and successor colors, not addresses.

    A flipped Jcc is represented by both its complementary predicate and its
    exchanged successors. This is an exact control-flow rewrite. Every
    proposed graph still needs a full state/event/condition proof afterwards.
    """
    def target_key(side, value):
        if side == 0 and value in addresses.forward:
            return value
        if side == 1 and value in addresses.reverse:
            return addresses.reverse[value]
        if not (addresses.old, addresses.new)[side].contains(value):
            return value
        return '?'
    base = {}
    for side, (code, graph) in enumerate(zip((a, b), graphs)):
        for head, (seq, edges) in graph.items():
            events = []
            for k in seq:
                ins = code[k]
                if ins.mnemonic == 'call':
                    op = ins.operands[0]
                    events.append(('call', target_key(side, op.imm) if op.type == X.X86_OP_IMM else ('indirect', op.size)))
                elif ins.mnemonic == 'ret':
                    events.append(('finally-return' if ins.handler_return else 'return',))
                elif ins.mnemonic in FP_OPS or ins.mnemonic in ('bound', 'div', 'idiv', 'eh-enter'):
                    events.append((ins.mnemonic,))
                if ins.eh and ins.mnemonic != 'eh-enter':
                    events.append(('frame-install',))
            base[side, head] = (len(edges), tuple(events))
    def color(keys):
        table = {}
        return {k: table.setdefault(v, len(table)) for k, v in keys.items()}
    colors = color(base)
    for _ in range(len(base)):
        refined = color({(s, h): (base[s, h], tuple(sorted(colors[s, j] for j in edges)))
                         for s, graph in enumerate(graphs) for h, (_, edges) in graph.items()})
        if refined == colors:
            break
        colors = refined
    pending = [({}, {}, {}, [(entry[0], entry[1])])]
    explored, yielded = 0, 0
    while pending and explored < 256 and yielded < 2:
        pairing, reverse, flips, todo = pending.pop()
        explored += 1
        valid = True
        while todo and valid:
            i, j = todo.pop()
            if i in pairing:
                valid = pairing[i] == j
                continue
            if j in reverse or colors[0, i] != colors[1, j]:
                valid = False
                break
            pairing[i], reverse[j] = j, i
            aa, bb = graphs[0][i][1], graphs[1][j][1]
            x, y = a[graphs[0][i][0][-1]], b[graphs[1][j][0][-1]]
            options = [False]
            if len(aa) == len(bb) == 2 and x.mnemonic in INVERSE_JUMP and y.mnemonic in INVERSE_JUMP:
                options = [True, False] if x.mnemonic == INVERSE_JUMP[y.mnemonic] else [False, True]
            options = [flip for flip in options
                       if all(colors[0, p] == colors[1, q] for p, q in zip(aa, bb[::-1] if flip else bb))]
            if not options:
                valid = False
                break
            for flip in reversed(options[1:]):
                following = bb[::-1] if flip else bb
                branch_flips = dict(flips)
                if flip:
                    branch_flips[j] = True
                pending.append((dict(pairing), dict(reverse), branch_flips, todo + list(zip(aa, following))))
            if options[0]:
                flips[j] = True
            todo.extend(zip(aa, bb[::-1] if options[0] else bb))
        if valid and flips:
            code = [dataclasses.replace(ins) for ins in b]
            for head in flips:
                seq, edges = graphs[1][head]
                terminal = code[seq[-1]]
                terminal.mnemonic = INVERSE_JUMP[terminal.mnemonic]
                terminal.flow = tuple(b[k].address for k in reversed(edges))
            yielded += 1
            yield code


def frame_bytes(code):
    return {o.mem.disp + k for ins in code for o in ins.operands
            if o.type == X.X86_OP_MEM and not (o.mem.segment or o.mem.index)
            and ins.reg_name(o.mem.base) == 'ebp' and -4096 <= o.mem.disp < 0
            for k in range(o.size)}


def location_value(st, loc):
    if loc[0] == 'r':
        return register_byte(st, loc[1], loc[2])
    if loc[0] == 'f':
        return st.flags[loc[1]]
    return simp(z3.Select(st.memory, st.regs['ebp'] + bv(loc[1])))


def live_locations(code, graph):
    """Backward may-liveness, including partial registers and CPU flags.

    Indirect stores never kill a possibly aliased frame byte. Calls expose all
    known frame bytes (a conservative treatment of var arguments) and havoc
    them. The memory arrays themselves remain part of every cut invariant.
    """
    slots = {('m', k) for k in frame_bytes(code)}
    uses, definitions = {}, {}
    def regloc(reg):
        name = code[0].reg_name(reg)
        if name not in ALIASES:
            return set()
        root, bits, off = ALIASES[name]
        return {('r', root, k) for k in range(off // 8, (off + bits) // 8)}
    for head, (seq, _) in graph.items():
        use, killed = set(), set()
        for k in seq:
            ins = code[k]
            rr, ww = ins.raw.regs_access()
            read = set().union(*(regloc(r) for r in rr)) if rr else set()
            write = set().union(*(regloc(r) for r in ww)) if ww else set()
            for flag in FLAGS:
                readmask = sum(getattr(X, 'X86_EFLAGS_' + p + '_' + flag.upper(), 0) for p in ('TEST', 'PRIOR'))
                writemask = sum(getattr(X, 'X86_EFLAGS_' + p + '_' + flag.upper(), 0) for p in ('MODIFY', 'RESET', 'SET', 'UNDEFINED'))
                if ins.raw.eflags & readmask:
                    read.add(('f', flag))
                if ins.raw.eflags & writemask:
                    write.add(('f', flag))
            for n, op in enumerate(ins.operands):
                if op.type != X.X86_OP_MEM or op.mem.segment or op.mem.index or ins.reg_name(op.mem.base) != 'ebp':
                    continue
                locs = {('m', op.mem.disp + j) for j in range(op.size)} & slots
                # Capstone access bits are unavailable in some releases;
                # classify only definite plain MOV stores as must-definitions.
                if n == 0 and ins.mnemonic == 'mov':
                    write |= locs
                elif ins.mnemonic != 'lea':
                    read |= locs
            if ins.mnemonic == 'call':
                read |= slots | {('r', r, k) for r in ('eax', 'edx', 'ecx', 'esp') for k in range(4)}
                write |= slots | {('r', r, k) for r in ('eax', 'edx', 'ecx', 'esp') for k in range(4)} | {('f', f) for f in FLAGS}
            if ins.mnemonic == 'ret':
                regs = ('esp',) if ins.handler_return else ('eax', 'edx', 'esp', 'ebx', 'esi', 'edi', 'ebp')
                read |= slots | {('r', r, k) for r in regs for k in range(4)}
            use |= read - killed
            killed |= write
        uses[head], definitions[head] = use, killed
    live = {h: set(u) for h, u in uses.items()}
    changed = True
    while changed:
        changed = False
        for h, (_, edges) in graph.items():
            after = set().union(*(live[j] for j in edges)) if edges else set()
            value = uses[h] | (after - definitions[h])
            if any(l[0] == 'm' for l in value):
                value |= {('r', 'ebp', k) for k in range(4)}
            if not value <= live[h]:
                live[h] |= value
                changed = True
    return live


def fact_expression(states, fact):
    if fact[0] == 'eq':
        return location_value(states[0], fact[1]) == location_value(states[1], fact[2])
    if fact[0] == 'const':
        _, side, loc, value = fact
        expr = location_value(states[side], loc)
        return expr == (z3.BoolVal(value) if z3.is_bool(expr) else bv(value, expr.size()))
    _, side, reg, base, delta = fact
    return states[side].regs[reg] == states[side].regs[base] + bv(delta)


def relation_states(facts):
    registers, flags = [], []
    for f in facts:
        if f[0] != 'eq':
            continue
        a, b = f[1:]
        if a[0] == b[0] == 'r' and a[2] == b[2]:
            registers.append((a[1], b[1], a[2]))
        if a[0] == b[0] == 'f' and a[1] == b[1]:
            flags.append(a[1])
    states = arbitrary(registers, flags)
    premise = simp(z3.And([fact_expression(states, f) for f in facts]))
    return states, premise


class Checker:
    def __init__(self, inp):
        self.inp = inp

    def instructions(self, fn):
        # Retain full instructions for proof; never use match.py's truncated
        # compiled stream as evidence that the function ended.
        oe = match.find_import_thunk(self.inp.old, 'System.@HandleOnException')
        ne = self.inp.addresses.map_addresses.get('@HandleOnException')
        a = decode(self.inp.old, fn.ova, fn.osize)
        size = fn.osize
        if any('fs:' in i.op_str for i in a):
            # Ghidra signatures often stop at the handler descriptor, omitting
            # the continuation and epilogue. Bound extension by the next known
            # function as well as a small decoding limit; reachability decides
            # which bytes are code, never the matcher truncation.
            end = min((p for p, _ in self.inp.sigs.values() if p > fn.ova), default=fn.ova + fn.osize + 128)
            size = min(end - fn.ova, fn.osize + 128)
        a = decode(self.inp.old, fn.ova, size, oe)
        b = decode(self.inp.new, fn.nva, fn.nsize, ne)
        # Ordinary trailing alignment is unreachable, and is excluded by CFG
        # reachability, rather than interpreted as executable data.
        return a, b

    def exception_regions(self, code, side):
        """Recognize Delphi's three-word FS chain record and handler descriptor.

        A handler is a separate, universally quantified region, not dead code.
        Its private incoming nonvolatile registers are independent. Only the
        saved frame / runtime stack and runtime-produced volatile registers
        correspond. This deliberately loses proofs that need try-body facts.
        """
        code = [dataclasses.replace(i) for i in code]
        by_addr = {i.address: j for j, i in enumerate(code)}
        regions = []
        for k, ins in enumerate(code):
            if not (ins.mnemonic == 'mov' and len(ins.operands) == 2
                    and ins.operands[0].type == X.X86_OP_MEM
                    and ins.reg_name(ins.operands[0].mem.segment) == 'fs'
                    and ins.operands[1].type == X.X86_OP_REG
                    and ins.reg_name(ins.operands[1].reg) == 'esp'):
                continue
            if k < 3 or any(code[k-d].mnemonic != 'push' for d in (1, 2, 3)):
                raise Unsupported('unrecognized Delphi exception frame')
            previous, descriptor, saved = (code[k-d].operands[0] for d in (1, 2, 3))
            if not (previous.type == X.X86_OP_MEM and ins.reg_name(previous.mem.segment) == 'fs'
                    and descriptor.type == X.X86_OP_IMM and saved.type == X.X86_OP_REG
                    and ins.reg_name(saved.reg) == 'ebp'):
                raise Unsupported('unrecognized Delphi exception frame')
            d = by_addr.get(descriptor.imm)
            if d is None or code[d].mnemonic != 'jmp' or code[d].operands[0].type != X.X86_OP_IMM or code[d].size != 5:
                raise Unsupported('unrecognized Delphi handler descriptor')
            target = code[d].operands[0].imm
            name = self.inp.addresses.names[side].get(target, '')
            if side == 1:
                name = next((n for n, a in self.inp.addresses.map_addresses.items() if a == target and n.startswith('@Handle')), name)
            kind = name.rsplit('.', 1)[-1]
            if kind not in ('@HandleFinally', '@HandleAnyException', '@HandleOnException', '@HandleAutoException'):
                raise Unsupported('unknown Delphi exception helper')
            metadata = [target, descriptor.imm]
            roots = [code[d].address + 5]
            if kind == '@HandleOnException':
                img = (self.inp.old, self.inp.new)[side]
                table = code[d].address + 5
                n = Addresses.u32(img, table)
                if not 0 < n < 16:
                    raise Unsupported('exception handler table')
                roots = []
                for t in range(n):
                    cls, handler = struct.unpack('<II', img.bytes_at(table + 4 + t * 8, 8))
                    metadata.extend((cls, handler))
                    roots.append(handler)
            ret = None
            if kind == '@HandleFinally':
                if d + 1 >= len(code) or code[d+1].mnemonic != 'jmp' or code[d+1].operands[0].type != X.X86_OP_IMM:
                    raise Unsupported('finally cleanup entry')
                body = by_addr.get(code[d+1].operands[0].imm)
                if body is None or body == 0 or code[body-1].mnemonic != 'push' or code[body-1].operands[0].type != X.X86_OP_IMM or code[d-1].mnemonic != 'ret':
                    raise Unsupported('finally continuation shape')
                continuation = code[body-1].operands[0].imm
                if continuation not in by_addr:
                    raise Unsupported('incomplete finally continuation')
                ret = d - 1
                # Also compare the return as an observable exit. Following its
                # paired continuation unconditionally is an overapproximation:
                # a havoced stack target must never hide the real epilogue.
                code[ret].flow = (continuation,)
                metadata.extend((code[d+1].operands[0].imm, continuation))
            ins.eh = tuple(metadata)
            regions.append((d, roots, ret, tuple(metadata)))
        # FS is modeled as a separate byte array. An FS access without a
        # recognized installation must fail closed rather than skip a handler.
        if any('fs:' in i.op_str for i in code) and not regions:
            raise Unsupported('unrecognized Delphi exception frame')
        return code, regions

    def verify_regions(self, a, b, ar, br):
        if len(ar) != len(br):
            raise NotProven('exception frames do not pair')
        for (d, roots, ret, meta), (e, other, oret, ometa) in zip(ar, br):
            if len(roots) != len(other) or len(meta) != len(ometa):
                raise NotProven('exception handlers do not pair')
            aa = [dataclasses.replace(i) for i in a]
            bb = [dataclasses.replace(i) for i in b]
            for code, entry, targets, cleanup, metadata in ((aa, d, roots, ret, meta), (bb, e, other, oret, ometa)):
                code[entry].mnemonic = 'eh-enter'
                code[entry].eh = metadata
                code[entry].flow = tuple(targets)
                if cleanup is not None:
                    code[cleanup].flow = ()
                    code[cleanup].handler_return = True
            # The helper can choose any matching table entry. Each path is
            # checked, and the ordered class/handler table is an input event.
            self.verify(aa, bb, (d, e), frozenset((r, r, lane) for r in ('eax', 'edx', 'ecx', 'ebp', 'esp') for lane in range(4)), ())

    def check(self, fn, mutated=None):
        addresses = self.inp.addresses
        saved = addresses.forward, addresses.reverse, addresses.conflicts
        # Alignment proposes function-local anonymous-object correspondences.
        # An unsuccessful proof (or a mutant) must not change another proof's
        # premises or poison its relocation table.
        addresses.forward = dict(addresses.forward)
        addresses.reverse = dict(addresses.reverse)
        addresses.conflicts = set(addresses.conflicts)
        try:
            a, b = self.instructions(fn)
            a, ar = self.exception_regions(a, 0)
            b, br = self.exception_regions(b, 1)
            # Infer only from the unmodified program. In particular, never
            # learn a new address from a +1/+4 mutation being checked.
            self.prepare_addresses(a, b)
            # Descriptor, class-table and continuation correspondences are
            # inferred from the baseline installations only, never mutants.
            if len(ar) == len(br):
                evidence = []
                for x, y in zip(ar, br):
                    if len(x[3]) == len(y[3]):
                        evidence.extend((u, v) for u, v in zip(x[3], y[3]) if self.inp.old.contains(u) and self.inp.new.contains(v))
                addresses.install_consistent(evidence)
            if mutated is not None:
                b, br = self.exception_regions(mutated, 1)
            self.verify_regions(a, b, ar, br)
            try:
                return self.verify(a, b)
            except NotProven as first:
                if str(first) == 'control-flow graphs do not pair':
                    raise
                try:
                    return self.acyclic(a, b)
                except (Unsupported, NotProven):
                    raise first
        except Unsupported as e:
            return 'UNSUPPORTED', str(e)
        except NotProven as e:
            return 'NOT PROVEN', str(e)[:80]
        finally:
            addresses.forward, addresses.reverse, addresses.conflicts = saved

    def prepare_addresses(self, a, b):
        # Instruction scheduling can exchange literal loads. Match immutable
        # strings by contents when each side references one unique object for
        # those contents, rather than pairing different strings by position.
        strings = [collections.defaultdict(set), collections.defaultdict(set)]
        for side, code in enumerate((a, b)):
            for ins in code:
                for op in ins.operands:
                    if op.type == X.X86_OP_IMM:
                        data = self.inp.addresses.string_object(side, op.imm)
                        if data is not None:
                            strings[side][data].add(op.imm)
        evidence = [(next(iter(aa)), next(iter(strings[1][data]))) for data, aa in strings[0].items()
                    if len(aa) == len(strings[1].get(data, ())) == 1]
        self.inp.addresses.install_consistent(evidence)
        try:
            ga, gb = blocks(a), blocks(b)
            todo, paired, reverse = [(0, 0)], {}, {}
            evidence = []
            while todo:
                i, j = todo.pop()
                if i in paired:
                    if paired[i] != j:
                        return
                    continue
                if j in reverse and reverse[j] != i:
                    return
                paired[i], reverse[j] = j, i
                aa, ae = ga[i]
                bb, be = gb[j]
                if len(ae) != len(be):
                    return
                todo.extend(zip(ae, be))
                if len(aa) == len(bb):
                    evidence.extend(self.inp.addresses.aligned_addresses([a[k] for k in aa], [b[k] for k in bb]))
            self.inp.addresses.install_consistent(evidence)
        except Unsupported:
            return

    def verify(self, a, b, entry=(0, 0), entry_candidates=DIAG, entry_flags=FLAGS):
        # Keep the inexpensive structural proof as a sufficient fast path.
        # Liveness is computed before relational candidate discovery.
        graphs = [blocks(a, entry[0]), blocks(b, entry[1])]
        live = [live_locations(code, graph) for code, graph in zip((a, b), graphs)]
        try:
            return self.verify_fast(a, b, entry, entry_candidates, entry_flags)
        except NotProven as first:
            if str(first) != 'control-flow graphs do not pair':
                try:
                    return self.houdini(a, b, graphs, live, entry, entry_candidates, entry_flags)
                except NotProven:
                    pass
            for aligned in cfg_variants(a, b, graphs, entry, self.inp.addresses):
                try:
                    return self.verify_fast(a, aligned, entry, entry_candidates, entry_flags)
                except NotProven:
                    aligned_graphs = [graphs[0], blocks(aligned, entry[1])]
                    aligned_live = [live[0], live_locations(aligned, aligned_graphs[1])]
                    try:
                        return self.houdini(a, aligned, aligned_graphs, aligned_live, entry, entry_candidates, entry_flags)
                    except NotProven:
                        pass
            raise first

    def houdini(self, a, b, graphs, live, entry, entry_candidates, entry_flags):
        """Infer a live-location relation, then prove initialization and all edges.

        A spanning-tree symbolic execution proposes constants and affine frame
        facts only; it is not a loop proof. Every candidate, including those
        proposals, must survive all predecessors in the Houdini fixed point.
        Solver timeouts discard facts, and a budget expiry never proves code.
        """
        deadline = time.monotonic() + 2.5
        def budget():
            if time.monotonic() > deadline:
                raise NotProven('relational inference budget')
        pairing, reverse, todo = {entry[0]: entry[1]}, {entry[1]: entry[0]}, [entry[0]]
        while todo:
            i = todo.pop()
            aa, bb = graphs[0][i][1], graphs[1][pairing[i]][1]
            if len(aa) != len(bb):
                raise NotProven('control-flow graphs do not pair')
            for x, y in zip(aa, bb):
                if x in pairing:
                    if pairing[x] != y:
                        raise NotProven('control-flow graphs do not pair')
                else:
                    if y in reverse:
                        raise NotProven('control-flow graphs do not pair')
                    pairing[x], reverse[y] = y, x
                    todo.append(x)
        local = [{}, {}]
        for i, j in pairing.items():
            for pred in (lambda ins: ins.mnemonic == 'call', lambda ins: ins.mnemonic in FP_OPS):
                aa = [a[k] for k in graphs[0][i][0] if pred(a[k])]
                bb = [b[k] for k in graphs[1][j][0] if pred(b[k])]
                for x, y in zip(aa, bb):
                    local[0][x.address] = local[1][y.address] = x.address
        machines = [Machine(self.inp.addresses, s, local) for s in (0, 1)]
        def execute(i, states):
            for side, code in enumerate((a, b)):
                for k in graphs[side][(i, pairing[i])[side]][0]:
                    machines[side].step(states[side], code[k])
            return states
        def clone(states):
            return [State(dict(s.regs), dict(s.flags), s.memory, s.fs, s.fp) for s in states]
        initial = arbitrary(entry_candidates, entry_flags)
        samples, todo = {}, [(entry[0], clone(initial))]
        while todo:
            budget()
            i, states = todo.pop()
            if i in samples:
                continue
            samples[i] = clone(states)
            states = execute(i, states)
            todo.extend((j, clone(states)) for j in graphs[0][i][1] if j not in samples)
        candidates = {}
        for i, j in pairing.items():
            budget()
            ll, rr = live[0][i], live[1][j]
            facts = {('eq', x, y) for x in ll for y in rr if (x[0] == 'f') == (y[0] == 'f')}
            if len(facts) > 16000:
                raise NotProven('live-location candidate budget')
            for side, locs in enumerate((ll, rr)):
                st = samples[i][side]
                for loc in locs:
                    value = simp(location_value(st, loc))
                    if z3.is_bv_value(value):
                        facts.add(('const', side, loc, value.as_long()))
                    elif z3.is_true(value) or z3.is_false(value):
                        facts.add(('const', side, loc, z3.is_true(value)))
                regs = {loc[1] for loc in locs if loc[0] == 'r'}
                for reg in regs:
                    for base in regs & {'ebp', 'esp'}:
                        if reg != base:
                            delta = simp(st.regs[reg] - st.regs[base])
                            if z3.is_bv_value(delta):
                                facts.add(('delta', side, reg, base, delta.as_long()))
            candidates[i] = facts
        def held(premise, equations):
            budget()
            established, remaining = set(), {}
            for key, expr in equations.items():
                expr = simp(expr)
                if z3.is_true(expr):
                    established.add(key)
                elif not z3.is_false(expr):
                    remaining[key] = expr
            established |= conditional_facts(premise, remaining)
            return established
        root = entry[0]
        candidates[root] &= held(z3.BoolVal(True), {f: fact_expression(initial, f) for f in candidates[root]})
        queue, queued = collections.deque([root]), {root}
        visited = set()
        while queue:
            budget()
            i = queue.popleft()
            queued.discard(i)
            states, premise = relation_states(candidates[i])
            states = execute(i, states)
            edges = graphs[0][i][1]
            terminal = a[graphs[0][i][0][-1]]
            for edge, target in enumerate(edges):
                guard = z3.And(premise, edge_guard(states[0], terminal, len(edges), edge))
                retained = held(guard, {f: fact_expression(states, f) for f in candidates[target]})
                changed = retained != candidates[target]
                candidates[target] &= retained
                if target not in visited or changed:
                    if target not in queued:
                        queue.append(target)
                        queued.add(target)
            visited.add(i)
        # Initialization and preservation are proof obligations, not assumptions
        # justified by the sampled paths. Memory, events and conditions are
        # checked universally under each retained relation.
        if not prove([fact_expression(initial, f) for f in candidates[root]]):
            raise NotProven('relation is not initialized')
        for i, j in pairing.items():
            budget()
            states, premise = relation_states(candidates[i])
            old, new = execute(i, states)
            if len(old.events) != len(new.events):
                raise NotProven('different observable events')
            goals = [old.memory == new.memory, old.fs == new.fs, old.fp == new.fp, old.condition == new.condition]
            for x, y in zip(old.events, new.events):
                if x[0] != y[0] or len(x) != len(y):
                    raise NotProven('different observable events')
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            edges = graphs[0][i][1]
            for edge, target in enumerate(edges):
                guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges), edge)
                goals += [z3.Implies(guard, fact_expression(states, f)) for f in candidates[target]]
            if not prove([z3.Implies(premise, z3.And(goals))]):
                raise NotProven('live-location relation does not prove the transition')
        return 'PROVEN', ''

    def verify_fast(self, a, b, entry=(0, 0), entry_candidates=DIAG, entry_flags=FLAGS):
        if not a or not b:
            raise Unsupported('empty disassembly')
        graphs = [blocks(a, entry[0]), blocks(b, entry[1])]
        for side, graph in enumerate(graphs):
            for seq, _ in graph.values():
                for k in seq:
                    ins = (a, b)[side][k]
                    if any(o.type == X.X86_OP_MEM and o.mem.segment and ins.reg_name(o.mem.segment) != 'fs' for o in ins.operands):
                        raise Unsupported('segment override')
                    if ins.mnemonic not in INTEGER_OPS | FP_OPS | {'eh-enter'} and not ins.mnemonic.startswith(('j', 'set')):
                        raise Unsupported(ins.mnemonic)
        pairing = {entry[0]: entry[1]}
        reverse = {entry[1]: entry[0]}
        todo = [entry[0]]
        edges = {}
        while todo:
            i = todo.pop()
            if i in edges:
                continue
            j = pairing[i]
            aa, bb = graphs[0][i][1], graphs[1][j][1]
            if len(aa) != len(bb):
                raise NotProven('control-flow graphs do not pair')
            edges[i] = aa
            for x, y in zip(aa, bb):
                if (x in pairing and pairing[x] != y) or (y in reverse and reverse[y] != x):
                    raise NotProven('control-flow graphs do not pair')
                pairing[x], reverse[y] = y, x
                todo.append(x)
        local = [{}, {}]
        for i, j in pairing.items():
            aa, bb = graphs[0][i][0], graphs[1][j][0]
            local[0][a[i].address] = local[1][b[j].address] = a[i].address
            # Calls in a block correspond by event order, not their byte offsets.
            ac = [k for k in aa if a[k].mnemonic == 'call']
            bc = [k for k in bb if b[k].mnemonic == 'call']
            for x, y in zip(ac, bc):
                local[0][a[x].address] = local[1][b[y].address] = a[x].address
            if len(aa) == len(bb):
                for x, y in zip(aa, bb):
                    local[0].setdefault(a[x].address, a[x].address)
                    local[1].setdefault(b[y].address, a[x].address)
                    # An anonymous import cell is matched only when both PE
                    # relocations name the same already identified object.
                    for u, v in zip(a[x].operands, b[y].operands):
                        if (u.type == v.type == X.X86_OP_IMM and a[x].mnemonic == b[y].mnemonic
                                and a[x].operands[0].type == b[y].operands[0].type == X.X86_OP_REG
                                and a[x].reg_name(a[x].operands[0].reg) == b[y].reg_name(b[y].operands[0].reg)):
                            sx = self.inp.addresses.string_object(0, u.imm)
                            sy = self.inp.addresses.string_object(1, v.imm)
                            if sx is not None and sy is not None:
                                if sx != sy:
                                    raise NotProven('read-only string argument differs')
        machines = [Machine(self.inp.addresses, s, local) for s in (0, 1)]
        candidates = {i: set(entry_candidates if i == entry[0] else ALL) for i in edges}
        flag_candidates = {i: set(entry_flags if i == entry[0] else FLAGS) for i in edges}
        queue = collections.deque([entry[0]])
        queued = {entry[0]}
        visited = set()
        while queue:
            i = queue.popleft()
            queued.discard(i)
            states = arbitrary(candidates[i], flag_candidates[i])
            for s in (0, 1):
                for k in graphs[s][(i, pairing[i])[s]][0]:
                    machines[s].step(states[s], (a, b)[s][k])
            old, new = states
            old_bytes = {(r, k): register_byte(old, r, k) for r in REGS for k in range(4)}
            new_bytes = {(r, k): register_byte(new, r, k) for r in REGS for k in range(4)}
            after = {(x, y, k) for x in REGS for y in REGS for k in range(4) if equal(old_bytes[x, k], new_bytes[y, k])}
            flags = {f for f in FLAGS if equal(old.flags[f], new.flags[f])}
            for edge, j in enumerate(edges[i]):
                kept = set(after)
                kept_flags = set(flags)
                if len(edges[i]) == 2:
                    guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges[i]), edge)
                    equations = {('r', x, y, k): old_bytes[x, k] == new_bytes[y, k]
                                 for x, y, k in candidates[j] - after}
                    equations.update({('f', f): old.flags[f] == new.flags[f] for f in flag_candidates[j] - flags})
                    for fact in conditional_facts(guard, equations):
                        if fact[0] == 'r':
                            kept.add(fact[1:])
                        else:
                            kept_flags.add(fact[1])
                changed = False
                if not candidates[j] <= kept:
                    candidates[j] &= kept
                    changed = True
                if not flag_candidates[j] <= kept_flags:
                    flag_candidates[j] &= kept_flags
                    changed = True
                if j not in visited or changed:
                    if j not in queued:
                        queue.append(j)
                        queued.add(j)
            visited.add(i)
        # The fixed point is only a proposal.  Prove every transition and
        # observable event again without entry-path-specific assumptions.
        for i in sorted(edges):
            states = arbitrary(candidates[i], flag_candidates[i])
            for s in (0, 1):
                for k in graphs[s][(i, pairing[i])[s]][0]:
                    machines[s].step(states[s], (a, b)[s][k])
            old, new = states
            if len(old.events) != len(new.events):
                raise NotProven('different observable events at instruction %d' % i)
            goals = [old.memory == new.memory, old.fs == new.fs, old.fp == new.fp, old.condition == new.condition]
            for x, y in zip(old.events, new.events):
                if x[0] != y[0] or len(x) != len(y):
                    raise NotProven('different observable events at instruction %d' % i)
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            for edge, j in enumerate(edges[i]):
                guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges[i]), edge)
                goals += [z3.Implies(guard, register_byte(old, x, k) == register_byte(new, y, k)) for x, y, k in candidates[j]]
                goals += [z3.Implies(guard, old.flags[f] == new.flags[f]) for f in flag_candidates[j]]
            if not prove(goals):
                raise NotProven('state / event correspondence fails at instruction %d' % i)
        return 'PROVEN', ''

    def acyclic(self, a, b):
        """Exact finite-path proof, with private stack bytes projected out.

        Only call-free DAGs use this alternative. The memory array remains
        unified, so an arbitrary input pointer that aliases a saved register
        is still observed correctly; no heap/stack disjointness is assumed.
        Loops are handled exclusively by the inductive block proof above.
        """
        graphs = [blocks(a), blocks(b)]
        for side, graph in enumerate(graphs):
            for seq, _ in graph.values():
                if any((a, b)[side][k].mnemonic == 'call' for k in seq):
                    raise NotProven('finite-path alternative requires no calls')
        local = [{}, {}]
        for side, code in enumerate((a, b)):
            for ins in code:
                # Local code addresses have no observable use in call-free
                # ordinary functions. Reject unresolved escaped code pointers.
                local[side][ins.address] = ins.address
        starts = arbitrary(DIAG, FLAGS)
        stack = starts[0].regs['esp']

        def offset(expr):
            value = simp(expr - stack)
            if z3.is_bv_value(value):
                n = value.as_long()
                return n - 0x100000000 if n >= 0x80000000 else n
            return None

        def paths(side, code):
            machine = Machine(self.inp.addresses, side, local)
            result = []
            todo = [(0, starts[side], z3.BoolVal(True), frozenset(), 0)]
            visits = 0
            while todo:
                index, st, guard, seen, low = todo.pop()
                if index in seen:
                    raise NotProven('loop requires an inductive correspondence')
                visits += 1
                if visits > 6000 or len(result) + len(todo) > 128:
                    raise NotProven('finite path budget')
                seen = seen | {index}
                ins = code[index]
                machine.step(st, ins)
                sp = offset(st.regs['esp'])
                if sp is None:
                    raise NotProven('dynamic stack extent')
                low = min(low, sp)
                if low < -4096:
                    raise NotProven('private stack extent exceeds budget')
                edges = successors(code, index)
                if not edges:
                    result.append((guard, st, low))
                    continue
                for edge, target in enumerate(edges):
                    cond = edge_guard(st, ins, len(edges), edge)
                    next_guard = simp(z3.And(guard, cond))
                    if z3.is_false(next_guard):
                        continue
                    clone = State(dict(st.regs), dict(st.flags), st.memory, st.fs, st.fp)
                    clone.events = list(st.events)
                    clone.condition = st.condition
                    todo.append((target, clone, next_guard, seen, low))
            return result

        old, new = paths(0, a), paths(1, b)
        if not old or not new:
            raise NotProven('no finite return paths')
        lows = [min(p[2] for p in old), min(p[2] for p in new)]

        def visible(st, low):
            memory = st.memory
            for off in range(min(lows), 0):
                memory = z3.Store(memory, stack + bv(off), bv(0, 8))
            return st.events, memory

        projected = [[(guard, st, *visible(st, low)) for guard, st, low in pp] for pp in (old, new)]

        def same(p, q):
            _, st, events, memory = p
            _, other, other_events, other_memory = q
            if len(events) != len(other_events):
                return z3.BoolVal(False)
            goals = [memory == other_memory, st.fs == other.fs, st.fp == other.fp]
            for x, y in zip(events, other_events):
                if x[0] != y[0] or len(x) != len(y):
                    return z3.BoolVal(False)
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            return z3.And(goals)

        for source, target in (projected, projected[::-1]):
            for p in source:
                choices = [z3.And(q[0], same(p, q)) for q in target]
                if not prove([z3.Implies(p[0], z3.Or(choices))]):
                    raise NotProven('finite-path traces differ')
        return 'PROVEN', ''


def mutate(insns, rng):
    """One in-memory instruction edit, fixed-seed selection, no binary writes."""
    choices = []
    reachable = set()
    todo = [0]
    while todo:
        index = todo.pop()
        if index in reachable or not 0 <= index < len(insns):
            continue
        reachable.add(index)
        try:
            todo.extend(successors(insns, index))
        except Unsupported:
            pass
    for index in sorted(reachable):
        ins = insns[index]
        for j, op in enumerate(ins.operands):
            if op.type == X.X86_OP_IMM and ins.mnemonic not in ('call', 'jmp', 'ret') and not ins.mnemonic.startswith('j'):
                choices.append((index, 'constant +1', j))
            if op.type == X.X86_OP_MEM and (op.mem.base or op.mem.index) and not op.mem.segment:
                choices.append((index, 'field offset +4', j))
        if (ins.mnemonic == 'cmp' and len(ins.operands) == 2
                and all(o.type == X.X86_OP_REG for o in ins.operands)
                and ins.operands[0].reg != ins.operands[1].reg):
            choices.append((index, 'swapped compare operands', 0))
        if ins.mnemonic == 'mov' and ins.operands[0].type == X.X86_OP_MEM:
            choices.append((index, 'drop store', 0))
        if ins.mnemonic == 'jle':
            choices.append((index, 'jl for jle', 0))
    if not choices:
        return None
    index, kind, operand = rng.choice(choices)
    changed = [dataclasses.replace(i, operands=list(i.operands)) for i in insns]
    ins = changed[index]
    # Copy our mutable operand records, keeping the baseline unmodified.
    import copy
    ins.operands = [copy.deepcopy(o) for o in ins.operands]
    if kind == 'constant +1':
        ins.operands[operand].imm += 1
    elif kind == 'field offset +4':
        ins.operands[operand].mem.disp += 4
    elif kind == 'swapped compare operands':
        ins.operands.reverse()
    elif kind == 'jl for jle':
        ins.mnemonic = 'jl'
    else:
        ins.mutation = kind
    return changed, index, kind


def mutation_explanation(insns, index, kind):
    if kind == 'swapped compare operands':
        observed = set()
        todo = [(j, frozenset(FLAGS) - {'df'}) for j in successors(insns, index)]
        seen = set()
        while todo:
            i, live = todo.pop()
            if (i, live) in seen or not 0 <= i < len(insns):
                continue
            seen.add((i, live))
            ins = insns[i]
            if ins.mnemonic in ('call', 'ret'):
                continue  # flags are not call arguments or return values
            bits = ins.raw.eflags
            for flag in live:
                uses = getattr(X, 'X86_EFLAGS_TEST_' + flag.upper(), 0) | getattr(X, 'X86_EFLAGS_PRIOR_' + flag.upper(), 0)
                if bits & uses:
                    observed.add(flag)
            killed = set()
            if ins.mnemonic not in ('shl', 'sal', 'shr', 'sar'):
                for flag in live:
                    mask = 0
                    for effect in ('MODIFY', 'RESET', 'SET', 'UNDEFINED'):
                        mask |= getattr(X, 'X86_EFLAGS_' + effect + '_' + flag.upper(), 0)
                    if bits & mask:
                        killed.add(flag)
            try:
                todo += [(j, live - killed) for j in successors(insns, i)]
            except Unsupported:
                return 'comparison predicates are unchanged under the proved invariants'
        if not observed:
            return 'comparison flags are overwritten or unused'
        if observed <= {'zf'}:
            return 'only ZF is observed; swapping comparison operands preserves ZF'
        return 'comparison predicates are unchanged under the proved invariants'
    if kind == 'drop store':
        return 'store is redundant, overwritten, or unobserved at every call and return'
    if kind == 'field offset +4':
        if insns[index].mnemonic == 'lea':
            return 'computed address has no observable use'
        return 'changed access has no observable effect before any call or return'
    if kind == 'jl for jle':
        return 'strict/non-strict boundary has the same reachable observable traces'
    return 'changed constant has no observable effect on any proved path'


def main(argv=None):
    try:
        inp = Inputs(sys.argv[1:] if argv is None else argv)
    except (ValueError, IndexError) as e:
        sys.exit(str(e))
    checker = Checker(inp)
    counts = collections.Counter()
    for fn in inp.functions:
        if fn.differs:
            status, reason = checker.check(fn)
            counts[status] += 1
            print(fn.name + ' ' + status + (' ' + reason if reason else ''), flush=True)
    if inp.mutate:
        rng = random.Random(0xA0E2026)
        matches = [f for f in inp.functions if not f.differs]
        rng.shuffle(matches)
        tested = 0
        for fn in matches:
            if tested >= inp.mutate:
                break
            try:
                a, b = checker.instructions(fn)
            except Unsupported:
                # There is no complete instruction stream in which to make
                # a single edit; continue to another eligible MATCH function.
                continue
            mutation = mutate(b, rng)
            if mutation is None:
                continue
            insns, index, kind = mutation
            status, reason = checker.check(fn, insns)
            tested += 1
            # A mutant is equivalent only if the same verifier proves it; the
            # reason includes the edit so dead/ineffective changes are auditable.
            if status == 'PROVEN':
                reason = mutation_explanation(b, index, kind)
            print('%s MUTANT %s %s [%s at %d]' % (fn.name, status, reason, kind, index), flush=True)
    n = sum(counts.values())
    print('%d differ: %d proven, %d not proven, %d unsupported' % (n, counts['PROVEN'], counts['NOT PROVEN'], counts['UNSUPPORTED']))


if __name__ == '__main__':
    main()
