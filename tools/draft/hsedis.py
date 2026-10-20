"""Disassemble HSEPack.dpl functions with call targets resolved: local functions by name, import
thunks (jmp [IAT]) by the imported name, VMT calls annotated with the slot offset.
Usage: hsedis.py [--module=X.dpl] name-substring... (a trailing dot lists a whole class)"""
import json, sys, struct, re
import pefile, capstone
def strip(n):
    return re.sub(r'@[0-9A-F]{8}$', '', n)
G = 'D:/Games/GOG/Age of Wonders/'
mod = 'HSEPack.dpl'
args = []
for a in sys.argv[1:]:
    if a.startswith('--module='): mod = a.split('=', 1)[1]
    else: args.append(a)
pe = pefile.PE(G + mod)
base = pe.OPTIONAL_HEADER.ImageBase
data = pe.get_memory_mapped_image()
sigs = json.load(open('C:/git/int19h/aow/notes/signatures/%s.json' % mod))
names = {int(f['addr'], 16): strip(f['name']) for f in sigs}
iat = {}
for e in getattr(pe, 'DIRECTORY_ENTRY_IMPORT', []):
    for imp in e.imports:
        if imp.name: iat[imp.address] = strip(imp.name.decode())
        else: iat[imp.address] = '%s#%d' % (e.dll.decode(), imp.ordinal)
exp = {}
for e in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if e.name: exp[base + e.address] = strip(e.name.decode())
md = capstone.Cs(capstone.CS_ARCH_X86, capstone.CS_MODE_32)
def thunk(t):
    try:
        b = data[t - base:t - base + 6]
        if b[0] == 0xFF and b[1] == 0x25:
            slot = struct.unpack('<I', b[2:6])[0]
            return iat.get(slot)
    except Exception: pass
    return None
def sstr(va):
    # long string constant: length at va-4
    try:
        n = struct.unpack('<i', data[va - base - 4:va - base])[0]
        if 0 < n < 200:
            s = data[va - base:va - base + n]
            if all(32 <= c < 127 for c in s): return repr(s.decode())
    except Exception: pass
    return None
for fn in sigs:
    name = strip(fn['name'])
    if not any((name.endswith(w[:-1]) and name[:-len(w)+1][-1:] in ('.','')) if w.endswith('$') else (w in name) for w in args) and not any(re.fullmatch(w, fn['addr']) for w in args):
        continue
    va, size = int(fn['addr'], 16), fn['size']
    print('==== %s  %08x  %d bytes' % (name, va, size))
    for ins in md.disasm(bytes(data[va - base:va - base + size]), va):
        note = ''
        ops = ins.op_str
        m = re.search(r'0x([0-9a-f]{8})', ops)
        if m:
            t = int(m.group(1), 16)
            if t in names and t != va: note = names[t]
            elif ins.mnemonic in ('call', 'jmp') and thunk(t): note = thunk(t)
            elif va <= t < va + size: note = '+%x' % (t - va)
            elif t in exp: note = exp[t]
            elif t + 0x40 in exp and '..' in exp[t + 0x40]: note = 'class ' + exp[t + 0x40].replace('..', '.')
            elif t in iat: note = '[%s]' % iat[t]
            else:
                s = sstr(t)
                if s: note = s
        elif ins.mnemonic == 'call' and re.match(r'dword ptr \[e[a-ds][xi] \+ (0x[0-9a-f]+)\]', ops):
            note = 'vmt +%X' % int(re.match(r'dword ptr \[\w+ \+ (0x[0-9a-f]+)\]', ops).group(1), 16)
        print('  %08x  %-6s %s%s' % (ins.address, ins.mnemonic, ops, ('  ; ' + note) if note else ''))
    print()
