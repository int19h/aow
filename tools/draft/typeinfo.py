"""Read exact enum, set and method-pointer RTTI. Usage: typeinfo.py <module.dpl> [Unit]"""
try:
    import pefile
except ImportError:  # the Codex sandbox cannot see the user's site-packages
    import sys as _s; _s.path.append(r'C:\Tools\pylib'); import pefile
import struct, sys
path = sys.argv[1]; unit = sys.argv[2] if len(sys.argv) > 2 else None
pe = globals().get('_pe') or pefile.PE(path)
base = pe.OPTIONAL_HEADER.ImageBase
img = pe.get_memory_mapped_image()
imports = {}
for entry in getattr(pe, 'DIRECTORY_ENTRY_IMPORT', []):
    for imp in entry.imports:
        if imp.name: imports[imp.address] = imp.name.decode()
def u8(va): return img[va-base]
def u32(va): return struct.unpack_from('<I', img, va-base)[0]
def i32(va): return struct.unpack_from('<i', img, va-base)[0]
def ss(va):
    n = u8(va); return img[va-base+1:va-base+1+n].decode('latin1'), va+1+n
TK = ['tkUnknown','tkInteger','tkChar','tkEnumeration','tkFloat','tkString','tkSet','tkClass','tkMethod','tkWChar','tkLString','tkWString','tkVariant','tkArray','tkRecord','tkInterface']
def tname(pp):
    if pp == 0: return 'nil'
    if pp in imports: return '<imp %s>' % imports[pp]
    try:
        p = u32(pp)
        if p in imports: return '<imp %s>'%imports[p]
        return ss(p+1)[0]
    except Exception: return '?%x' % pp
def enum_values(va):
    nm, p = ss(va+1)
    mn, mx = i32(p+1), i32(p+5)
    q = p+13; vals = []
    for i in range(mx-mn+1):
        v,q = ss(q); vals.append(v)
    return '(' + ', '.join(vals) + ')'
for e in sorted(getattr(getattr(pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []), key=lambda e: e.address):
    if not e.name: continue
    s = e.name.decode()
    if s.endswith('@23EDC2EF'): continue
    name = s.split('@')[0]
    if unit and not name.startswith(unit + '.'): continue
    va = base + e.address
    parts = name.split('.')
    if len(parts) != 2 or not parts[1].startswith('T'): continue
    k = u8(va)
    if k >= len(TK): continue
    nm, p = ss(va+1)
    if nm != parts[1]: continue
    kind = TK[k]
    if kind == 'tkEnumeration':
        ot = u8(p); mn = i32(p+1); mx = i32(p+5); bt = u32(p+9); q = p+13; vals=[]
        for i in range(mx-mn+1):
            v, q = ss(q); vals.append(v)
        print('%s = (%s);  { ot=%d }' % (nm, ', '.join(vals), ot))
    elif kind == 'tkSet':
        tn = tname(u32(p+1))
        if tn.startswith('.'): tn = enum_values(u32(u32(p+1)))
        print('%s = set of %s; { ot=%d }' % (nm, tn, u8(p)))
    elif kind == 'tkMethod':
        mk = u8(p); pc = u8(p+1); q = p+2; ps = []
        for i in range(pc):
            fl = u8(q); pn, q = ss(q+1); tn, q = ss(q)
            pre = ['var ' if fl & 1 else '', 'const ' if fl & 2 else '', 'array of ' if fl & 4 else '', 'addr ' if fl&8 else '', 'ref ' if fl & 16 else '', 'out ' if fl & 32 else '']
            pre = ''.join(x for x in pre[:2] + [pre[5]])
            arr = 'array of ' if fl & 4 else ''
            ps.append('%s%s: %s%s' % (pre, pn, arr, tn))
        res = ''
        if mk == 1: res, q = ss(q); res = ': ' + res
        print('%s = %s(%s)%s of object;' % (nm, ['procedure','function','constructor','destructor','class procedure','class function','safe procedure','safe function'][mk], '; '.join(ps), res))
    elif kind == 'tkClass':
        pass
    else:
        print('%s: %s' % (nm, kind))
