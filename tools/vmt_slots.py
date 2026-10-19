"""Print the virtual method table of a Delphi 3 class with the name behind each slot.

Usage: vmt_slots.py <module> <ClassName> [<ClassName> ...]

Slot targets are named through the module's export table, or through its import table when the
method is inherited from another package. Use it to read decompiler output such as
``(**(code **)(*obj + 0x30))(...)``: slot 0x30 of the object's class is the method being called.
"""
import importlib.util, os, sys

spec = importlib.util.spec_from_file_location('delphi_rtti', os.path.join(os.path.dirname(__file__), 'delphi_rtti.py'))
rtti = importlib.util.module_from_spec(spec)
src = open(spec.origin, encoding='utf-8').read().replace('\nmain()\n', '\n')
exec(compile(src, spec.origin, 'exec'), rtti.__dict__)


def main():
    img = rtti.Image(sys.argv[1])
    exports = img.exports()
    vmts = rtti.find_vmts(img, exports)
    byname = {}
    for va in vmts:
        byname[img.sstr(img.u32(va + rtti.VMT['ClassName']))[0]] = va

    def symbol(target):
        if target in exports:
            return exports[target].split('@')[0]
        # imported thunk: "jmp [iat]" = FF 25 <addr>
        if img.ok(target, 6) and img.data[target - img.base: target - img.base + 2] == b'\xff\x25':
            iat = img.u32(target + 2)
            n = img.imports.get(iat)
            if n:
                return n.split('!', 1)[1].split('@')[0]
        if img.in_code(target):
            return 'FUN_%08X' % target
        return '%08X' % target

    for cls in sys.argv[2:]:
        va = byname.get(cls)
        if va is None:
            print('%s: not found in this module' % cls)
            continue
        parent = img.u32(va + rtti.VMT['Parent'])
        pname = img.import_name(parent) if parent else None
        if parent and not pname and img.ok(parent):
            pv = img.u32(parent)
            if img.ok(pv + rtti.VMT['ClassName']):
                pname = img.sstr(img.u32(pv + rtti.VMT['ClassName']))[0]
        print('== %s (parent %s) size=%d' % (cls, pname, img.u32(va + rtti.VMT['InstanceSize'])))
        for off, name in ((-20, 'SafeCallException'), (-16, 'DefaultHandler'), (-12, 'NewInstance'),
                          (-8, 'FreeInstance'), (-4, 'Destroy')):
            print('  %+5d  %-18s -> %s' % (off, name, symbol(img.u32(va + off))))
        idx = 0
        while idx < 512:
            t = img.u32(va + 4 * idx)
            if not img.in_code(t):
                break
            print('  +0x%03X -> %s' % (4 * idx, symbol(t)))
            idx += 1


main()
