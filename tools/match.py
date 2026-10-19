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
{"FUN_555140bc": "QuickSort", "Engine.FillInteger": "FillInteger"}.

--show Method prints the two instruction streams side by side for that method.
--quiet prints only the methods that differ and the totals.
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
            syms.setdefault(m.group(3), (m.group(1), int(m.group(2), 16)))
    return syms, seg_base


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
    argv = sys.argv[1:]
    while argv and argv[0].startswith('--'):
        opt = argv.pop(0)
        if opt == '--show':
            show = argv.pop(0)
        elif opt == '--alias':
            aliases.update(json.load(open(argv.pop(0), encoding='utf-8')))
        elif opt == '--quiet':
            quiet = True
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
    code_syms = sorted(((off, name) for name, (seg, off) in syms.items() if seg == '0001'))

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
    for orig_name, name in aliases.items():
        pairs.append((name, orig_name if orig_name in sigs else None))

    total = ident = 0
    total_bytes = ident_bytes = 0
    for name, orig_name in pairs:
        if orig_name is None:
            print('%-40s no original' % name)
            continue
        if name not in syms:
            print('%-40s not in map (unreferenced, smart-linked out?)' % name)
            continue
        ova, osize = sigs[orig_name]
        seg, off = syms[name]
        nva = text_va + off
        # the new function's size: up to the next symbol in the map
        nxt = min((o for (o, n) in code_syms if o > off), default=off + osize + 64)
        nsize = nxt - off
        a = [normalize(i, old) for i in md.disasm(old.bytes_at(ova, osize), ova)]
        b = [normalize(i, new) for i in md.disasm(new.bytes_at(nva, min(nsize, osize + 32)), nva)][:len(a)]
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
