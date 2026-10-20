"""Compare the export names of a package built from the recovered source with the original module.

Usage: exports.py [--units U1,U2] [--show] <built.dpl> <original.dpl>

Delphi packages export every interface symbol as Unit.Name@XXXXXXXX (classes as Unit..Name, methods as
Unit.Class.Method@XXXXXXXX). The suffix is a hash of the declaration: parameter and result types,
calling convention, and for classes the layout, visibility and properties; it does not depend on
parameter names. So a symbol whose suffix differs has a declaration that differs from the original
even if the code matches, and a symbol that exists on one side only is missing or extra.

Prints, per unit, the number of exports with the same hash, a different hash, only in the original
and only in the build; --show lists the names of the differing and missing ones.
"""
import collections, sys
try:
    import pefile
except ImportError:  # the Codex sandbox cannot see the user's site-packages
    import sys as _s; _s.path.append(r'C:\Tools\pylib'); import pefile


def exports(path):
    pe = pefile.PE(path, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
    out = {}
    for e in getattr(pe, 'DIRECTORY_ENTRY_EXPORT', None).symbols if hasattr(pe, 'DIRECTORY_ENTRY_EXPORT') else []:
        if not e.name:
            continue
        n = e.name.decode('latin-1')
        name, _, h = n.partition('@')
        out[name] = h
    return out


def main():
    argv = sys.argv[1:]
    units = None
    show = False
    while argv and argv[0].startswith('--'):
        opt = argv.pop(0)
        if opt == '--units':
            units = set(argv.pop(0).split(','))
        elif opt == '--show':
            show = True
        else:
            sys.exit('unknown option ' + opt)
    built, orig = exports(argv[0]), exports(argv[1])

    def unit_of(n):
        return n.split('.')[0]

    names = set(built) | set(orig)
    if units:
        names = {n for n in names if unit_of(n) in units}
    else:
        names = {n for n in names if unit_of(n) in {unit_of(m) for m in built}}
    stats = collections.defaultdict(lambda: collections.Counter())
    lists = collections.defaultdict(list)
    for n in sorted(names):
        u = unit_of(n)
        if n in built and n in orig:
            if built[n] == orig[n]:
                stats[u]['same'] += 1
            else:
                stats[u]['different'] += 1
                lists[u].append('  differs   %s  (original %s, built %s)' % (n, orig[n], built[n]))
        elif n in orig:
            stats[u]['missing'] += 1
            lists[u].append('  missing   %s' % n)
        else:
            stats[u]['extra'] += 1
            lists[u].append('  extra     %s' % n)
    total = collections.Counter()
    for u in sorted(stats):
        c = stats[u]
        total += c
        print('%-20s same %4d  different %4d  missing %4d  extra %4d' % (u, c['same'], c['different'], c['missing'], c['extra']))
        if show:
            for l in lists[u]:
                print(l)
    print('%-20s same %4d  different %4d  missing %4d  extra %4d' % ('total', total['same'], total['different'], total['missing'], total['extra']))


main()
