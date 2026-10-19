"""Tabulate Delphi 3 package exports (Unit.Class.Method@hash) from the pescan output. Usage: symtab.py <pedir>"""
import os, sys, re, collections

GAME = ['AoWEPACK.dpl','Ilpack.dpl','Enginep.dpl','HSEPack.dpl','AoWTCPCK.dpl','Localize.dpl','aowInt.dpl',
        'AoWInterface.dpl','ims.dpl','Gfxepack.dpl','Dcpack.dpl','SoundP.dpl','AOWTools.dpl','ILToolsP.dpl',
        'Network.dpl','aowDPlay.dpl','AbilityP.dpl','VideoP.dpl','Adcpack.dpl','aowFXpck.dpl','Vcladdon.dpl']

def main():
    d = sys.argv[1]
    grand_units = 0; grand_classes = 0; grand_methods = 0
    for f in GAME:
        lines = open(os.path.join(d, f + '.txt'), encoding='utf-8').read().split('\n')
        i = lines.index('# exports')
        units = collections.OrderedDict()
        for e in lines[i+1:]:
            m = re.match(r'^([A-Za-z0-9_]+)\.(.*)@([0-9A-F]{8})$', e)
            if not m: continue
            unit, sym, h = m.groups()
            u = units.setdefault(unit, dict(classes=collections.defaultdict(set), funcs=set(), types=set()))
            if sym.startswith('.'):
                u['types'].add(sym[1:])
            elif '.' in sym:
                cls, meth = sym.split('.', 1)
                u['classes'][cls].add(meth)
            elif sym not in (unit, 'Finalization', '@PackageLoad', '@PackageUnload'):
                u['funcs'].add(sym)
        ncls = sum(len(u['classes']) for u in units.values())
        nmeth = sum(len(ms) for u in units.values() for ms in u['classes'].values())
        nfun = sum(len(u['funcs']) for u in units.values())
        grand_units += len(units); grand_classes += ncls; grand_methods += nmeth + nfun
        print('%-18s units=%3d classes=%4d methods=%5d plain-funcs=%4d' % (f, len(units), ncls, nmeth, nfun))
        with open(os.path.join(d, f + '.units.txt'), 'w', encoding='utf-8') as fh:
            for unit, u in units.items():
                fh.write('== %s  (%d classes, %d funcs, %d types)\n' % (unit, len(u['classes']), len(u['funcs']), len(u['types'])))
                for cls, ms in sorted(u['classes'].items()):
                    fh.write('   %s (%d): %s\n' % (cls, len(ms), ' '.join(sorted(ms))))
                if u['funcs']: fh.write('   funcs: %s\n' % ' '.join(sorted(u['funcs'])))
    print('TOTAL              units=%3d classes=%4d methods+funcs=%5d' % (grand_units, grand_classes, grand_methods))

main()
