"""Entry analysis: which of edx/ecx a function reads before writing, at what width, and how many
stack bytes it pops (ret n). Used for draft method signatures."""
import json, glob, os, re, struct
import pefile, capstone
G = 'D:/Games/GOG/Age of Wonders/'
R = 'C:/git/int19h/aow/notes/'
_pe = {}
def module(mod):
    if mod not in _pe:
        pe = pefile.PE(G + mod, fast_load=True)
        _pe[mod] = (pe.OPTIONAL_HEADER.ImageBase, pe.get_memory_mapped_image())
    return _pe[mod]
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
md.detail = True
REGS = {'eax': ('eax', 4), 'ax': ('eax', 2), 'al': ('eax', 1), 'edx': ('edx', 4), 'dx': ('edx', 2), 'dl': ('edx', 1), 'ecx': ('ecx', 4), 'cx': ('ecx', 2), 'cl': ('ecx', 1)}
def analyze(mod, va, size):
    base, data = module(mod)
    code = bytes(data[va - base:va - base + size])
    used = {}; written = set(); retn = None; first = True
    for ins in md.disasm(code, va):
        if ins.mnemonic == 'ret':
            retn = int(ins.op_str, 16) if ins.op_str else 0
            continue
        if retn is None and ins.mnemonic.startswith('ret'): pass
        r, w = ins.regs_access()
        rn = [ins.reg_name(x) for x in r]; wn = [ins.reg_name(x) for x in w]
        # mov reg, reg: operands
        ops = ins.op_str.replace(' ', '').split(',')
        if ins.mnemonic in ('xor', 'sub') and len(ops) == 2 and ops[0] == ops[1]:
            rn = []
        for x in rn:
            if x in REGS:
                full, width = REGS[x]
                if full not in written and full not in used: used[full] = width
        for x in wn:
            if x in REGS: written.add(REGS[x][0])
        if ins.mnemonic == 'call' and len(written) < 2:
            # registers survive into the callee: count edx/ecx passed unchanged as used args
            for full in ('edx', 'ecx'):
                if full not in written and full not in used: pass
            written |= {'edx', 'ecx'}
    # scan all rets
    rets = set()
    for ins in md.disasm(code, va):
        if ins.mnemonic == 'ret': rets.add(int(ins.op_str, 16) if ins.op_str else 0)
    return used, max(rets) if rets else None
_sigs = {}
def sigs(mod):
    if mod not in _sigs:
        _sigs[mod] = {int(s['addr'], 16): s for s in json.load(open(R + 'signatures/%s.json' % mod))}
    return _sigs[mod]
