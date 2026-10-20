"""Dump Delphi 3 class metadata (VMT, RTTI) from a package or executable.

Usage: delphi_rtti.py <file.dpl|exe> [out.txt]

For a package, the class VMTs are found through the exports named ``Unit..TClass@hash``.
For an executable, VMTs are found by scanning for the self-pointer at the start of each VMT.
For every class the script prints the parent, the instance size, the number of virtual methods,
the published fields (name, offset, type), the published methods, and the published properties
(name, type, getter and setter field offsets or method addresses).
"""
import re, struct, sys
try:
    import pefile
except ImportError:  # the Codex sandbox cannot see the user's site-packages
    import sys as _s; _s.path.append(r'C:\Tools\pylib'); import pefile

# Delphi 3 VMT layout: offsets relative to the VMT address (first user virtual method slot).
# Confirmed against Ilpack.dpl: the self pointer sits at -64 and the class name pointer at -32.
VMT = dict(SelfPtr=-64, IntfTable=-60, AutoTable=-56, InitTable=-52, TypeInfo=-48, FieldTable=-44,
           MethodTable=-40, DynamicTable=-36, ClassName=-32, InstanceSize=-28, Parent=-24)
FIRST_VIRTUAL = -20   # SafeCallException, DefaultHandler, NewInstance, FreeInstance, Destroy at -20..-4; user slots from 0

TK = ['tkUnknown', 'tkInteger', 'tkChar', 'tkEnumeration', 'tkFloat', 'tkString', 'tkSet', 'tkClass',
      'tkMethod', 'tkWChar', 'tkLString', 'tkWString', 'tkVariant', 'tkArray', 'tkRecord', 'tkInterface']


class Image:
    def __init__(self, path):
        self.pe = pefile.PE(path, fast_load=True)
        self.pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT'],
                                                    pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT']])
        self.base = self.pe.OPTIONAL_HEADER.ImageBase
        self.data = self.pe.get_memory_mapped_image()
        self.code = [(self.base + s.VirtualAddress, self.base + s.VirtualAddress + max(s.Misc_VirtualSize, s.SizeOfRawData))
                     for s in self.pe.sections if s.Name.rstrip(b'\0') in (b'CODE', b'.text')]
        # IAT slot address -> imported symbol name (other packages' classes and type infos arrive this way)
        self.imports = {}
        for entry in getattr(self.pe, 'DIRECTORY_ENTRY_IMPORT', []):
            dll = entry.dll.decode('latin1')
            for imp in entry.imports:
                if imp.name:
                    self.imports[imp.address] = '%s!%s' % (dll, imp.name.decode('latin1'))

    def import_name(self, va):
        """Short name for an imported symbol: 'Unit..TClass@hash' -> 'TClass'."""
        n = self.imports.get(va)
        if not n:
            return None
        n = n.split('!', 1)[1].split('@', 1)[0]
        return n.rsplit('.', 1)[-1] or n

    def ok(self, va, n=4):
        off = va - self.base
        return 0 <= off and off + n <= len(self.data)

    def u8(self, va): return self.data[va - self.base]
    def u16(self, va): return struct.unpack_from('<H', self.data, va - self.base)[0]
    def u32(self, va): return struct.unpack_from('<I', self.data, va - self.base)[0]
    def i32(self, va): return struct.unpack_from('<i', self.data, va - self.base)[0]

    def sstr(self, va):
        n = self.u8(va)
        return self.data[va - self.base + 1: va - self.base + 1 + n].decode('latin1'), va + 1 + n

    def in_code(self, va):
        return any(lo <= va < hi for lo, hi in self.code)

    def exports(self):
        out = {}
        if hasattr(self.pe, 'DIRECTORY_ENTRY_EXPORT'):
            for e in self.pe.DIRECTORY_ENTRY_EXPORT.symbols:
                if e.name:
                    out[self.base + e.address] = e.name.decode('latin1')
        return out


def is_vmt(img, va):
    if not img.ok(va + VMT['SelfPtr']) or not img.ok(va + 4):
        return False
    if img.u32(va + VMT['SelfPtr']) != va:
        return False
    cn = img.u32(va + VMT['ClassName'])
    if not img.ok(cn, 2):
        return False
    n = img.u8(cn)
    if n == 0 or n > 64 or not img.ok(cn + 1, n):
        return False
    name = img.data[cn - img.base + 1: cn - img.base + 1 + n]
    return re.fullmatch(rb'[A-Za-z_][A-Za-z0-9_]*', name) is not None


def find_vmts(img, exports):
    vmts = set()
    for va, name in exports.items():
        if re.match(r'^[A-Za-z0-9_]+\.\.T', name) and is_vmt(img, va):
            vmts.add(va)
    # always scan for self pointers too: some package classes (e.g. the AI groups in IndependentAG)
    # have no "Unit..TClass" export, and executables export nothing
    for lo, hi in img.code:
        for va in range(lo + 76, hi - 4, 4):
            if img.u32(va + VMT['SelfPtr']) == va and is_vmt(img, va):
                vmts.add(va)
    return sorted(vmts)


def type_name(img, typeinfo_pp):
    """typeinfo_pp is a pointer to a pointer to TTypeInfo (Delphi stores PPTypeInfo)."""
    if not typeinfo_pp or not img.ok(typeinfo_pp):
        return '?'
    imp = img.import_name(typeinfo_pp)
    if imp:
        return imp
    ti = img.u32(typeinfo_pp)
    if not img.ok(ti, 2):
        return '?'
    kind = img.u8(ti)
    name, _ = img.sstr(ti + 1)
    return '%s(%s)' % (name, TK[kind] if kind < len(TK) else kind)


def dump_class(img, va, names, out):
    cn = img.u32(va + VMT['ClassName'])
    name, _ = img.sstr(cn)
    parent_p = img.u32(va + VMT['Parent'])
    parent = '-'
    if parent_p and img.ok(parent_p):
        pv = img.u32(parent_p)
        parent = names.get(pv) or img.import_name(parent_p) or \
            (img.sstr(img.u32(pv + VMT['ClassName']))[0] if img.ok(pv + VMT['ClassName']) else '?')
    size = img.u32(va + VMT['InstanceSize'])
    # count user virtual slots: consecutive pointers into code
    nvirt = 0
    while img.ok(va + nvirt * 4) and img.in_code(img.u32(va + nvirt * 4)) and not (nvirt and (va + nvirt * 4) in names):
        nvirt += 1
        if nvirt > 400: break
    out.append('class %s (%s) size=%d virtuals=%d vmt=%08X' % (name, parent, size, nvirt, va))
    # field table: word count; entries: dword offset, word typeindex, shortstring name; then class table pointer first
    ft = img.u32(va + VMT['FieldTable'])
    if ft and img.ok(ft):
        count = img.u16(ft)
        classtab = img.u32(ft + 2)
        p = ft + 6
        for _ in range(min(count, 2000)):
            off = img.u32(p); ti = img.u16(p + 4); fname, p = img.sstr(p + 6)
            tname = '?'
            if classtab and img.ok(classtab + 2 + 4 * ti):
                # the class table holds pointers to TClass variables (pointer to VMT pointer)
                cref = img.u32(classtab + 2 + 4 * ti)
                tname = img.import_name(cref) or '?'
                if tname == '?' and img.ok(cref):
                    cv = img.u32(cref)
                    if img.ok(cv + VMT['ClassName']) and img.ok(img.u32(cv + VMT['ClassName'])):
                        tname = img.sstr(img.u32(cv + VMT['ClassName']))[0]
            out.append('  field  +%04X %-30s %s' % (off, fname, tname))
    # method table: word count; entries: word size, dword address, shortstring name
    mt = img.u32(va + VMT['MethodTable'])
    if mt and img.ok(mt):
        count = img.u16(mt)
        p = mt + 2
        for _ in range(min(count, 2000)):
            sz = img.u16(p); addr = img.u32(p + 2); mname, _ = img.sstr(p + 6)
            out.append('  method %08X %s' % (addr, mname))
            p += sz
    # published properties from TypeInfo (tkClass)
    ti = img.u32(va + VMT['TypeInfo'])
    if ti and img.ok(ti) and img.u8(ti) == 7:
        tname, p = img.sstr(ti + 1)
        classtype = img.u32(p); parentinfo = img.u32(p + 4); propcount = img.u16(p + 8)
        unit, p = img.sstr(p + 10)
        out.append('  unit %s' % unit)
        n = img.u16(p); p += 2
        for _ in range(min(n, 2000)):
            ptype = img.u32(p); getp = img.u32(p + 4); setp = img.u32(p + 8); stored = img.u32(p + 12)
            index = img.i32(p + 16); default = img.i32(p + 20); nameidx = img.u16(p + 24)
            pname, p = img.sstr(p + 26)
            def acc(x):
                if x == 0: return 'none'
                if (x >> 24) == 0xFF: return 'field+%04X' % (x & 0xFFFFFF)
                if (x >> 24) == 0xFE: return 'virt+%04X' % (x & 0xFFFF)
                return 'static %08X' % x
            out.append('  prop   %-30s %-28s get=%s set=%s%s' % (
                pname, type_name(img, ptype), acc(getp), acc(setp),
                '' if default == -2147483648 else ' default=%d' % default))


def main():
    path = sys.argv[1]
    img = Image(path)
    exports = img.exports()
    vmts = find_vmts(img, exports)
    names = {}
    for va in vmts:
        names[va] = img.sstr(img.u32(va + VMT['ClassName']))[0]
    out = ['# %s: %d classes' % (path, len(vmts))]
    for va in vmts:
        try:
            dump_class(img, va, names, out)
        except Exception as e:
            out.append('class @%08X: error %s' % (va, e))
    text = '\n'.join(out)
    if len(sys.argv) > 2:
        open(sys.argv[2], 'w', encoding='utf-8').write(text)
        print(out[0])
    else:
        print(text)


if __name__ == '__main__':
    main()
