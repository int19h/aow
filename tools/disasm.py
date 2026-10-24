"""Print the disassembly of original functions from a game module, by name.

Usage: disasm.py <module.dpl> <signatures.json> <name substring> [...]

Example:
  disasm.py "D:\\Games\\GOG\\Age of Wonders\\Enginep.dpl" data/signatures/Enginep.dpl.json \
            TIntegerList.SaveToStream FUN_55514218

Every function whose exported name contains one of the substrings is printed with capstone. Call and jump
targets that resolve to a named function are annotated. Used to read the original's exact shape while
writing Delphi 3 source for it (see tools/match.py).
"""
import json, sys
try:
    import pefile
except ImportError:  # the Codex sandbox cannot see the user's site-packages
    import sys as _s; _s.path.append(r'C:\Tools\pylib'); import pefile
import capstone


def main():
    module, sigf = sys.argv[1:3]
    wanted = sys.argv[3:]
    # --range lo-hi (hex) disassembles raw bytes, for handler code Ghidra left out of a function
    ranges = [w for w in wanted if w.startswith('--range=')]
    wanted = [w for w in wanted if not w.startswith('--range=')]
    pe = pefile.PE(module, fast_load=True)
    base = pe.OPTIONAL_HEADER.ImageBase
    data = pe.get_memory_mapped_image()
    sigs = json.load(open(sigf, encoding='utf-8'))
    by_addr = {}
    for fn in sigs:
        by_addr[int(fn['addr'], 16)] = fn['name'].split('@')[0]
    md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
    for r in ranges:
        lo, hi = (int(x, 16) for x in r[len('--range='):].split('-'))
        print('==== range %08x-%08x' % (lo, hi))
        for ins in md.disasm(bytes(data[lo - base:hi - base]), lo):
            note = ''
            if ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
                try:
                    t = int(ins.op_str, 16)
                    if t in by_addr:
                        note = '  ; ' + by_addr[t]
                except ValueError:
                    pass
            print('  %08x  %-6s %s%s' % (ins.address, ins.mnemonic, ins.op_str, note))
        print()
    for fn in sigs:
        name = fn['name'].split('@')[0]
        if not any(w in name for w in wanted):
            continue
        va, size = int(fn['addr'], 16), fn['size']
        print('==== %s  %08x  %d bytes' % (name, va, size))
        code = bytes(data[va - base: va - base + size])
        for ins in md.disasm(code, va):
            note = ''
            if ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
                try:
                    t = int(ins.op_str, 16)
                    if t in by_addr:
                        note = '  ; ' + by_addr[t]
                    elif va <= t < va + size:
                        note = '  ; +%x' % (t - va)
                except ValueError:
                    pass
            print('  %08x  %-6s %s%s' % (ins.address, ins.mnemonic, ins.op_str, note))
        print()


main()
