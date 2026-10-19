"""Compare the machine code of methods compiled with Delphi 3 against the originals in a game module.

Usage: match.py <compiled.exe> <compiled.map> <original module> <signatures.json> <OrigClass>[=NewClass] ...

Example:
  match.py src/delphi3/matchtest.exe src/delphi3/matchtest.map "D:\\Games\\GOG\\Age of Wonders\\Enginep.dpl" \
           notes/signatures/Enginep.dpl.json TPropertyTable

For every method of the class found in the .map file, the original function with the same short name is
looked up in the Ghidra signature export, both byte ranges are disassembled with capstone, and the
instruction streams are compared with address-like operands masked (calls, jumps, absolute memory
references, immediates inside either image). The result per method: identical, same-length-with-operand-
differences, or the first differing instruction.
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


def disasm(md, code, va):
    out = []
    for ins in md.disasm(code, va):
        out.append(ins)
    return out


def normalize(ins, img):
    """Operand text with addresses masked, so that relocated code compares equal."""
    op = ins.op_str
    # hex immediates / displacements that fall inside the image are addresses
    def mask(m):
        v = int(m.group(0), 16)
        return 'ADDR' if img.contains(v) else m.group(0)
    op = re.sub(r'0x[0-9a-fA-F]+', mask, op)
    if ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
        op = 'TARGET' if re.fullmatch(r'(0x[0-9a-f]+|ADDR)', op) else op
    return ins.mnemonic, op


def function_end(insns):
    """Delphi 3 pads functions with 0x90/0xCC; stop at the first ret followed by padding or at the size limit."""
    return insns


def compare(a, b):
    n = min(len(a), len(b))
    for i in range(n):
        if a[i][0] != b[i][0] or a[i][1] != b[i][1]:
            return i
    return -1 if len(a) == len(b) else n


def main():
    show = None
    if '--show' in sys.argv:
        i = sys.argv.index('--show')
        show = sys.argv[i + 1]
        del sys.argv[i:i + 2]
    exe, mapf, orig, sigf = sys.argv[1:5]
    classes = sys.argv[5:]
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
    total = ident = 0
    for spec in classes:
        oc, _, nc = spec.partition('=')
        nc = nc or oc
        for name, (seg, off) in sorted(syms.items(), key=lambda kv: kv[1][1]):
            if not name.startswith(nc + '.') or seg != '0001':
                continue
            method = name[len(nc) + 1:]
            orig_name = None
            for k in sigs:
                if k.endswith('.' + oc + '.' + method):
                    orig_name = k
            if orig_name is None:
                print('%-40s no original' % name)
                continue
            ova, osize = sigs[orig_name]
            nva = text_va + off
            # the new function's size: up to the next symbol in the map
            nxt = min((o for (s, o) in syms.values() if s == '0001' and o > off), default=off + osize + 64)
            nsize = nxt - off
            a = [normalize(i, old) for i in disasm(md, old.bytes_at(ova, osize), ova)]
            b = [normalize(i, new) for i in disasm(md, new.bytes_at(nva, min(nsize, osize + 32)), nva)][:len(a)]
            # trim trailing padding (int3/nop) from the new side
            while b and b[-1][0] in ('int3', 'nop') and len(b) > len(a):
                b.pop()
            d = compare(a, b)
            total += 1
            if show and name.endswith('.' + show):
                print('==== %s: original (%s) | compiled' % (name, orig_name))
                for i in range(max(len(a), len(b))):
                    l = '%-8s %-34s' % a[i] if i < len(a) else ' ' * 43
                    r = '%-8s %s' % b[i] if i < len(b) else ''
                    print('  %3d  %s | %s' % (i, l, r))
            if d == -1:
                ident += 1
                print('%-40s MATCH  %d instructions, %d bytes' % (name, len(a), osize))
            else:
                print('%-40s differs at instruction %d of %d/%d' % (name, d, len(a), len(b)))
                for i in range(max(0, d - 2), min(len(a), len(b), d + 3)):
                    print('    %3d  old: %-8s %-30s new: %-8s %s' % (i, a[i][0], a[i][1], b[i][0], b[i][1]))
    print('%d of %d methods match' % (ident, total))


main()
