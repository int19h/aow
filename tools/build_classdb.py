"""Build data/classes.json: every Delphi class in every game module, with parent, size, VMT slot names,
and known fields. tools/ghidra/ApplyDelphiClasses.java turns this into Ghidra structs.

Usage: build_classdb.py <game dir> <out.json> [layout.md ...]

The layout files are the markdown tables written by readwrite_table.py and field_names.py; they add
field names and types. Classes are keyed by name. When two modules define the same class name, the
first module in the scan order wins and the duplicate is listed under "duplicates".
"""
import json, os, re, sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import delphi_rtti as rtti

FIXED = [(-20, 'SafeCallException'), (-16, 'DefaultHandler'), (-12, 'NewInstance'), (-8, 'FreeInstance'), (-4, 'Destroy')]
RW_TYPES = {'rwInteger': ('int', 4), 'rwIntegerEx': ('int', 4), 'rwWord': ('word', 2), 'rwWordEx': ('word', 2),
            'rwByte': ('byte', 1), 'rwByteEx': ('byte', 1), 'rwBool': ('bool', 1), 'rwShortint': ('char', 1),
            'rwShortintEx': ('char', 1), 'rwString': ('AnsiString', 4), 'rwStrings': ('pointer', 4),
            'rwStringsEx': ('pointer', 4), 'rwEObject': ('pointer', 4), 'rwCreateEObject': ('pointer', 4)}
C_TYPES = {'byte': ('byte', 1), 'char': ('char', 1), 'undefined1': ('byte', 1), 'bool': ('bool', 1),
           'short': ('short', 2), 'ushort': ('word', 2), 'undefined2': ('word', 2), 'int': ('int', 4),
           'uint': ('uint', 4), 'undefined4': ('int', 4), 'float': ('float', 4), 'String': ('AnsiString', 4),
           'int *': ('pointer', 4), 'undefined4 *': ('pointer', 4), 'double': ('double', 8)}

MODULE_ORDER = ['vcl30.dpl', 'VCLX30.DPL', 'Enginep.dpl', 'Ilpack.dpl', 'Gfxepack.dpl', 'Dcpack.dpl', 'HSEPack.dpl',
                'Network.dpl', 'SoundP.dpl', 'AoWEPACK.dpl', 'AoWTCPCK.dpl', 'aowInt.dpl', 'AoWInterface.dpl',
                'aowDPlay.dpl', 'VideoP.dpl', 'AOWTools.dpl', 'ILToolsP.dpl', 'AbilityP.dpl', 'Adcpack.dpl',
                'aowFXpck.dpl', 'Localize.dpl', 'ims.dpl', 'Vcladdon.dpl', 'VCLDB30.DPL', 'AoW.exe', 'AoWEd.exe']


def symbol_at(img, exports, target):
    """Name of the code at target: export name, imported thunk name, or None."""
    if target in exports:
        return exports[target].split('@')[0]
    if img.ok(target, 6) and img.data[target - img.base: target - img.base + 2] == b'\xff\x25':
        n = img.imports.get(img.u32(target + 2))
        if n:
            return n.split('!', 1)[1].split('@')[0]
    return None


def short_method(sym):
    """'AoWE.THero.GetExperience' -> 'GetExperience'; 'System.TObject.Destroy' -> 'Destroy'.
    'System.' (the @AbstractError stub, whose name was cut at the '@') -> None."""
    if not sym:
        return None
    s = sym.rsplit('.', 1)[-1]
    return s or None


def inherit_slot_names(db):
    """An abstract slot has no symbol of its own; take its name from the first subclass that implements it."""
    children = {}
    for name, e in db.items():
        children.setdefault(e['parent'], []).append(name)

    def descendants(name):
        out, stack = [], list(children.get(name, []))
        while stack:
            n = stack.pop(); out.append(n); stack.extend(children.get(n, []))
        return out

    for name, e in db.items():
        for slot in e['vmt']:
            if slot['name']:
                continue
            for d in descendants(name):
                de = db[d]
                if slot['offset'] // 4 < len(de['vmt']):
                    cand = de['vmt'][slot['offset'] // 4]
                    if cand['name']:
                        slot['name'] = cand['name']; slot['inherited_from_subclass'] = d
                        break


def scan_module(path, modname, db, dups):
    img = rtti.Image(path)
    exports = img.exports()
    vmts = rtti.find_vmts(img, exports)
    names = {va: img.sstr(img.u32(va + rtti.VMT['ClassName']))[0] for va in vmts}
    for va in vmts:
        name = names[va]
        if name in db:
            dups.append('%s in %s (kept %s)' % (name, modname, db[name]['module']))
            continue
        parent_p = img.u32(va + rtti.VMT['Parent'])
        parent = None
        if parent_p:
            parent = img.import_name(parent_p)
            if not parent and img.ok(parent_p):
                pv = img.u32(parent_p)
                parent = names.get(pv)
                if not parent and img.ok(pv + rtti.VMT['ClassName']) and img.ok(img.u32(pv + rtti.VMT['ClassName'])):
                    # a parent VMT that is not exported under "Unit..TClass": read its name directly
                    parent = img.sstr(img.u32(pv + rtti.VMT['ClassName']))[0]
        entry = dict(module=modname, parent=parent, size=img.u32(va + rtti.VMT['InstanceSize']),
                     vmt_va='%08X' % va, fixed={}, vmt=[], fields={})
        for off, fname in FIXED:
            t = img.u32(va + off)
            entry['fixed'][fname] = dict(target='%08X' % t, symbol=symbol_at(img, exports, t))
        idx = 0
        while idx < 512:
            t = img.u32(va + 4 * idx)
            if not img.in_code(t):
                break
            sym = symbol_at(img, exports, t)
            entry['vmt'].append(dict(offset=4 * idx, symbol=sym, name=short_method(sym), target='%08X' % t,
                                     own=bool(sym and sym.split('.')[-2:-1] == [name])))
            idx += 1
        # published fields of forms (name, offset, class type)
        ft = img.u32(va + rtti.VMT['FieldTable'])
        if ft and img.ok(ft):
            count = img.u16(ft); classtab = img.u32(ft + 2); p = ft + 6
            for _ in range(min(count, 2000)):
                off = img.u32(p); ti = img.u16(p + 4); fname, p = img.sstr(p + 6)
                tname = 'pointer'
                if classtab and img.ok(classtab + 2 + 4 * ti):
                    cref = img.u32(classtab + 2 + 4 * ti)
                    tname = img.import_name(cref) or tname
                    if tname == 'pointer' and img.ok(cref):
                        cv = img.u32(cref)
                        if cv in names: tname = names[cv]
                entry['fields'][str(off)] = dict(name=fname, type=tname, size=4, src='rtti')
        # published properties backed by fields
        ti = img.u32(va + rtti.VMT['TypeInfo'])
        if ti and img.ok(ti) and img.u8(ti) == 7:
            _, p = img.sstr(ti + 1)
            unit, p = img.sstr(p + 10)
            entry['unit'] = unit
            n = img.u16(p); p += 2
            for _ in range(min(n, 2000)):
                ptype = img.u32(p); getp = img.u32(p + 4)
                pname, p = img.sstr(p + 26)
                if (getp >> 24) == 0xFF:
                    off = getp & 0xFFFFFF
                    tname = rtti.type_name(img, ptype)
                    entry['fields'].setdefault(str(off), dict(name='F' + pname, type=tname, size=0, src='rtti-prop'))
        db[name] = entry


def add_layouts(db, paths):
    """Merge readwrite_table.py and field_names.py tables (keyed by class name)."""
    for path in paths:
        cur = None
        for line in open(path, encoding='utf-8'):
            m = re.match(r'## \w+\.(T\w+)', line)
            if m:
                cur = m.group(1) if m.group(1) in db else None
                continue
            if not cur or not line.startswith('| ') or line.startswith('| id') or line.startswith('| offset') or line.startswith('|---'):
                continue
            cells = [c.strip() for c in line.strip().strip('|').split('|')]
            fields = db[cur]['fields']
            if cells[0].startswith('+$') and len(cells) >= 3 and cells[1].startswith('F'):
                # field_names.py: offset | field | c type | from
                off, name, ctype = cells[0][2:], cells[1], cells[2]
                t, size = C_TYPES.get(ctype, (ctype if ctype.startswith('T') else 'int', 4))
                f = fields.setdefault(str(int(off, 16)), {})
                f.update(name=name, type=f.get('type') if f.get('type') not in (None, 'int', 'pointer') else t,
                         size=f.get('size') or size, src=f.get('src', 'accessor'))
            elif len(cells) >= 3 and cells[2].startswith('+$'):
                # readwrite_table.py: id | rw | offset | size | note
                pid, rw, off, size = cells[0], cells[1], cells[2][2:], cells[3] if len(cells) > 3 else ''
                t, sz = RW_TYPES.get(rw, ('byte', 1))
                if rw == 'rwData':
                    sz = int(size) if size.isdigit() else 1
                    t = 'byte' if sz == 1 else 'byte[%d]' % sz
                f = fields.setdefault(str(int(off, 16)), {})
                # decimal id in the name: ids 10 and 0x10 must not both become prop_10
                try:
                    pid_dec = str(int(pid, 0)) if pid else ''
                except ValueError:
                    pid_dec = pid
                f.setdefault('name', ('prop%s' % pid_dec) if pid_dec else 'field_%X' % int(off, 16))
                f.update(type=t, size=sz, src=f.get('src', 'readwrite'), rw=rw, id=pid)


def main():
    gamedir, out = sys.argv[1], sys.argv[2]
    db, dups = {}, []
    for mod in MODULE_ORDER:
        p = os.path.join(gamedir, mod)
        if os.path.exists(p):
            scan_module(p, mod, db, dups)
    inherit_slot_names(db)
    add_layouts(db, sys.argv[3:])
    # field names must be unique within a class (and against its parents), or two fields print alike
    for name, e in db.items():
        taken = set()
        p = e['parent']
        while p in db:
            taken.update(fd.get('name', '').lower() for fd in db[p]['fields'].values())
            p = db[p]['parent']
        for off in sorted(e['fields'], key=int):
            fd = e['fields'][off]
            base = fd.get('name') or ('field_%X' % int(off))
            cand, k = base, 2
            while cand.lower() in taken:
                cand = '%s_%d' % (base, k); k += 1
            fd['name'] = cand
            taken.add(cand.lower())
    # resolve parents that name a class we have not scanned to None, keep the name for information
    for name, e in db.items():
        e['parent_known'] = e['parent'] in db
    json.dump(dict(classes=db, duplicates=dups), open(out, 'w', encoding='utf-8'), indent=1)
    nfields = sum(len(e['fields']) for e in db.values())
    print('%d classes, %d fields, %d duplicate names -> %s' % (len(db), nfields, len(dups), out))


if __name__ == '__main__':
    main()
