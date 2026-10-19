"""Compare the machine code of methods compiled with Delphi 3 against the originals in a game module.

Usage: match.py [--show Method] [--alias aliases.json] [--quiet] <compiled.exe> <compiled.map>
                <original module> <signatures.json> <OrigClass>[=NewClass] ...

Example:
  match.py src/delphi3/matchtest.exe src/delphi3/matchtest.map "D:\\Games\\GOG\\Age of Wonders\\Enginep.dpl" \
           notes/signatures/Enginep.dpl.json TPropertyTable TIntegerList

For every method of each class found in the .map file, the original function with the same short name is
looked up in the Ghidra signature export, both byte ranges are disassembled with capstone, and the
instruction streams are compared with address-like operands masked (calls, jumps, absolute memory
references, immediates inside either image). The result per method: identical, or the first differing
instruction.

An alias file maps original function names that are not class methods (unit procedures, nested functions
that Ghidra named FUN_xxxxxxxx) to the symbol name the .map file gives them, for example
{"FUN_555140bc": "QuickSort", "Engine.FillInteger": "FillInteger"}. A value "Name<Owner" picks the occurrence of a
repeated name (nested functions) that the compiler emitted right before Owner. A key "address:size" names a
function that Ghidra did not create (for example the tiny sort comparison functions).

--show Method prints the two instruction streams side by side for that method.
--quiet prints only the methods that differ and the totals.
A case jump table after 'jmp dword ptr [reg*4 + table]' is compared as one pseudo-instruction that
lists the entries as offsets into the function.
--units Unit1,Unit2 also compares every unit-level function of those units (original name "Unit.Name")
whose bare name is a symbol of the map file, so only nested and unnamed functions need aliases.
"""
import json, os, re, struct, sys
import pefile
import capstone


class Image:
    def __init__(self, path):
        self.pe = pefile.PE(path, fast_load=True)
        self.base = self.pe.OPTIONAL_HEADER.ImageBase
        self.data = self.pe.get_memory_mapped_image()
        self.lo = self.base
        self.hi = self.base + len(self.data)

    def bytes_at(self, va, n):
        return bytes(self.data[va - self.base: va - self.base + n])

    def contains(self, v):
        return self.lo <= v < self.hi


def find_import_thunk(img, name):
    """Address of the 'jmp [iat]' thunk for an imported symbol (the name without its @hash suffix)."""
    img.pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT']])
    iat = None
    for e in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
        for imp in e.imports:
            if imp.name and imp.name.decode().split('@')[:2] == name.split('@')[:2]:
                iat = imp.address
    if iat is None:
        return None
    pat = bytes([0xFF, 0x25]) + struct.pack('<I', iat)
    off = bytes(img.data).find(pat)
    return img.base + off if off >= 0 else None


def map_symbols(map_path):
    """Delphi .map: 'Address  Publics by Value' lines like '0001:000099FC  TPropertyTable.Add'."""
    syms = {}
    seg_base = {}
    for line in open(map_path, encoding='latin1'):
        m = re.match(r'\s*(\d{4}):([0-9A-F]{8})\s+([0-9A-F]{8})H\s+(\S+)\s+(CODE|ICODE|DATA|BSS)', line)
        if m:
            seg_base[m.group(1)] = (int(m.group(2), 16), int(m.group(3), 16))
        m = re.match(r'\s*(\d{4}):([0-9A-F]{8})\s+(\S+)\s*$', line)
        if m:
            # nested functions and helpers may repeat a name (DefaultRun, ReturnAddr): keep every address
            loc = (m.group(1), int(m.group(2), 16))
            if loc not in syms.setdefault(m.group(3), []):   # the map lists each symbol by name and by value
                syms[m.group(3)].append(loc)
    return syms, seg_base


def resolve(syms, name):
    """A map symbol: 'Name' (first occurrence) or 'Name<Owner' (the occurrence of Name with the highest address
    below Owner, for a nested function or helper that the compiler emits right before the function using it)."""
    if '<' in name:
        n, owner = name.split('<')
        if n not in syms or owner not in syms:
            return None
        oseg, ooff = syms[owner][0]
        cands = [off for seg, off in syms[n] if seg == oseg and off < ooff]
        return (oseg, max(cands)) if cands else None
    return syms[name][0] if name in syms else None


def normalize(ins, img):
    """Operand text with addresses masked, so that relocated code compares equal."""
    op = ins.op_str

    def mask(m):
        v = int(m.group(0), 16)
        return 'ADDR' if img.contains(v) else m.group(0)
    op = re.sub(r'0x[0-9a-fA-F]+', mask, op)
    if ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
        op = 'TARGET' if re.fullmatch(r'(0x[0-9a-f]+|ADDR)', op) else op
    return ins.mnemonic, op


def disasm_skipping_tables(md, img, va, size, on_exception):
    """Disassemble, but after 'jmp @HandleOnException' skip the table that follows it (a count and
    count pairs of class pointer and handler address): data that must not be compared as code."""
    out = []
    code = img.bytes_at(va, size)
    pos = 0
    while pos < size:
        insns = list(md.disasm(code[pos:], va + pos))
        if not insns:
            break
        for ins in insns:
            out.append(normalize(ins, img))
            pos = ins.address - va + ins.size
            m = None
            if ins.mnemonic == 'jmp':
                m = re.fullmatch(r'dword ptr \[(?:e[a-z]{2})\*4 \+ (0x[0-9a-f]+)\]', ins.op_str)
            if m and va <= int(m.group(1), 16) < va + size:
                # a case jump table: dwords pointing into this function, after alignment padding;
                # compared as one pseudo-instruction holding the entries' offsets in the function.
                # The base is entry 0; with a byte index table in front the first slots can be unused.
                tpos = int(m.group(1), 16) - va
                skip = 0
                while skip < 8 and tpos + 4 <= size and \
                        not va <= struct.unpack('<I', code[tpos:tpos + 4])[0] < va + size:
                    tpos += 4
                    skip += 1
                entries = []
                while tpos + 4 <= size:
                    t = struct.unpack('<I', code[tpos:tpos + 4])[0]
                    if not va <= t < va + size:
                        break
                    entries.append(t - va)
                    tpos += 4
                if entries and tpos > pos:
                    out.append(('.table', ' '.join('%x' % e for e in entries)))
                    pos = tpos
                    break
            if ins.mnemonic == 'jmp' and on_exception is not None:
                try:
                    if int(ins.op_str, 16) == on_exception:
                        if pos + 4 > size:
                            return out          # the table is cut off by the function size
                        n = struct.unpack('<I', code[pos:pos + 4])[0]
                        if n < 16:
                            pos += 4 + 8 * n
                            if pos >= size:
                                return out
                            break
                except ValueError:
                    pass
        else:
            break
    return out


def compare(a, b):
    n = min(len(a), len(b))
    for i in range(n):
        if a[i][0] != b[i][0] or a[i][1] != b[i][1]:
            return i
    return -1 if len(a) == len(b) else n


def main():
    show = None
    aliases = {}
    quiet = False
    units = []
    argv = sys.argv[1:]
    while argv and argv[0].startswith('--'):
        opt = argv.pop(0)
        if opt == '--show':
            show = argv.pop(0)
        elif opt == '--alias':
            aliases.update(json.load(open(argv.pop(0), encoding='utf-8')))
        elif opt == '--quiet':
            quiet = True
        elif opt == '--units':
            units += argv.pop(0).split(',')
        else:
            sys.exit('unknown option ' + opt)
    exe, mapf, orig, sigf = argv[:4]
    classes = argv[4:]
    new = Image(exe)
    old = Image(orig)
    syms, segs = map_symbols(mapf)
    sigs = {}
    for fn in json.load(open(sigf, encoding='utf-8')):
        n = fn['name'].split('@')[0]
        sigs[n] = (int(fn['addr'], 16), fn['size'])
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    # code segment 0001 starts at the first section's VA
    text_va = new.base + new.pe.sections[0].VirtualAddress
    # the on-exception handler entry: an import thunk in the original module, a symbol in the map here
    old_on_exc = find_import_thunk(old, 'System.@HandleOnException')
    new_on_exc = None
    if '@HandleOnException' in syms:
        new_on_exc = text_va + syms['@HandleOnException'][0][1]
    code_syms = sorted((off, name) for name, locs in syms.items() for seg, off in locs if seg == '0001')

    # (map name, original name) pairs to compare
    pairs = []
    for spec in classes:
        oc, _, nc = spec.partition('=')
        nc = nc or oc
        for off, name in code_syms:
            if not name.startswith(nc + '.'):
                continue
            method = name[len(nc) + 1:]
            orig_name = None
            for k in sigs:
                if k.endswith('.' + oc + '.' + method):
                    orig_name = k
            pairs.append((name, orig_name))
    aliased = set(aliases.values())
    for unit in units:
        for k in sorted(sigs, key=lambda k: sigs[k][0]):
            parts = k.split('.')
            if len(parts) == 2 and parts[0] == unit and parts[1] in syms and parts[1] not in aliased                     and k not in aliases and parts[1] not in (unit, 'Finalization'):
                pairs.append((parts[1], k))
    for orig_name, name in aliases.items():
        if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', orig_name):
            # a function Ghidra did not name: "address:size" in hex and bytes
            addr, size = orig_name.split(':')
            sigs[orig_name] = (int(addr, 16), int(size))
        pairs.append((name, orig_name if orig_name in sigs else None))

    total = ident = 0
    total_bytes = ident_bytes = 0
    for name, orig_name in pairs:
        if orig_name is None:
            print('%-40s no original' % name)
            continue
        loc = resolve(syms, name)
        if loc is None:
            print('%-40s not in map (unreferenced, smart-linked out?)' % name)
            continue
        ova, osize = sigs[orig_name]
        seg, off = loc
        nva = text_va + off
        # the new function's size: up to the next symbol in the map
        nxt = min((o for (o, n) in code_syms if o > off), default=off + osize + 64)
        nsize = nxt - off
        a = disasm_skipping_tables(md, old, ova, osize, old_on_exc)
        b = disasm_skipping_tables(md, new, nva, min(nsize, osize + 32), new_on_exc)[:len(a)]
        while b and b[-1][0] in ('int3', 'nop') and len(b) > len(a):
            b.pop()
        d = compare(a, b)
        total += 1
        total_bytes += osize
        if show and name.endswith(show):
            print('==== %s: original (%s) | compiled' % (name, orig_name))
            for i in range(max(len(a), len(b))):
                l = '%-8s %-34s' % a[i] if i < len(a) else ' ' * 43
                r = '%-8s %s' % b[i] if i < len(b) else ''
                print('  %3d  %s | %s' % (i, l, r))
        if d == -1:
            ident += 1
            ident_bytes += osize
            if not quiet:
                print('%-40s MATCH  %d instructions, %d bytes' % (name, len(a), osize))
        else:
            print('%-40s differs at instruction %d of %d/%d' % (name, d, len(a), len(b)))
            for i in range(max(0, d - 2), min(len(a), len(b), d + 3)):
                print('    %3d  old: %-8s %-30s new: %-8s %s' % (i, a[i][0], a[i][1], b[i][0], b[i][1]))
    print('%d of %d functions match, %d of %d bytes' % (ident, total, ident_bytes, total_bytes))


main()
