"""Shared path arguments for the draft tools; defaults are relative to the repository."""
import argparse, re
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def parser(description):
    p = argparse.ArgumentParser(description=description)
    p.add_argument('module', type=Path)
    p.add_argument('signatures', type=Path)
    p.add_argument('unit')
    p.add_argument('--classes', type=Path, default=ROOT / 'data/classes.json')
    p.add_argument('--source-root', type=Path, default=ROOT / 'src/delphi3')
    p.add_argument('--decomp', type=Path)
    p.add_argument('--vcl-source', type=Path)
    p.add_argument('--rtti', type=Path, help='class-to-unit RTTI dump (defaults to data/rtti/<module>.txt)')
    return p
def class_layouts(args):
    """Use module-local layouts for executables with duplicate, unexported class names."""
    import json, re, sys
    layouts = json.load(open(args.classes))['classes']
    args.rtti_units = {}
    if args.module.suffix.lower() == '.exe':
        sys.path.insert(0, str(ROOT / 'tools'))
        from build_classdb import scan_module
        local = {}
        scan_module(str(args.module), args.module.name, local, [])
        layouts.update(local)
        dump = args.rtti or ROOT / 'data/rtti' / (args.module.name + '.txt')
        current = None
        for line in dump.read_text(encoding='latin1').splitlines():
            m = re.match(r'class (\w+)', line)
            if m: current = m.group(1)
            m = re.match(r'  unit (\w+)', line)
            if m and current:
                args.rtti_units[current] = m.group(1)
    return layouts


def inherited_slot(layouts, cls, offset):
    """Find a named VMT slot at the same offset in the nearest ancestor."""
    parent = layouts.get(cls, {}).get('parent')
    while parent in layouts:
        slot = next((v for v in layouts[parent]['vmt'] if v['offset'] == offset), None)
        if slot and slot['name'] and not re.fullmatch(r'(?:vmt|VMT_)[0-9A-Fa-f]+', slot['name']):
            return slot['name']
        parent = layouts[parent]['parent']
    return None


def configure(args):
    import entry
    args.layouts = class_layouts(args)
    entry.G = str(args.module.resolve().parent) + '/'
    entry.R = str(args.signatures.resolve().parent) + '/'
    entry._sigs[args.module.name] = {int(s['addr'], 16): s for s in __import__('json').load(open(args.signatures))}

    if args.module.name.lower() == 'aowepack.dpl':
        for fn in entry._sigs[args.module.name].values():
            if fn['name'].split('.')[0] in ('TBuildRoadsControl','TRebuildConstructionControl',
                                          'TUnitResourceAbilityOwner','THeroResourceAbilityOwner'):
                fn['name'] = 'AoWE.' + fn['name']

        import json, re
        layouts = json.load(open(args.classes))['classes']
        for fn in entry._sigs[args.module.name].values():
            parts = fn['name'].split('@')[0].split('.')
            if len(parts)==3 and re.fullmatch(r'vmt[0-9A-Fa-f]+',parts[2]):
                parent = layouts[layouts[parts[1]]['parent']]
                name = parent['vmt'][int(parts[2][3:],16)//4]['name']
                if name: fn['name'] = fn['name'].replace(parts[2],name)

    if args.module.suffix.lower() == '.exe':
        import re
        for fn in entry._sigs[args.module.name].values():
            parts = fn['name'].split('@')[0].split('.')
            if len(parts) != 2 or parts[0] not in args.layouts: continue
            cls, name = parts
            if re.fullmatch(r'vmt[0-9A-Fa-f]+', name):
                name = inherited_slot(args.layouts, cls, int(name[3:], 16)) or name
            unit = args.rtti_units.get(cls)
            if unit: fn['name'] = unit + '.' + cls + '.' + name
            else: fn['name'] = cls + '.' + name
