"""Shared path arguments for the draft tools; defaults are relative to the repository."""
import argparse
from pathlib import Path
ROOT = Path(__file__).resolve().parents[2]
def parser(description):
    p = argparse.ArgumentParser(description=description)
    p.add_argument('module', type=Path)
    p.add_argument('signatures', type=Path)
    p.add_argument('unit')
    p.add_argument('--classes', type=Path, default=ROOT / 'notes/classes.json')
    p.add_argument('--source-root', type=Path, default=ROOT / 'src/delphi3')
    p.add_argument('--decomp', type=Path)
    p.add_argument('--vcl-source', type=Path)
    return p
def configure(args):
    import entry
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
