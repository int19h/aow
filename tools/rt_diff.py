"""Compare two --flat walks (original file and round-trip output) object by object.

Usage: rt_diff.py <orig.txt> <mine.txt> [--values]

Objects are matched in walk order. For every class the script counts the property ids that the
original has and the round trip lacks (missing) or adds (extra), reports where the two walks first
diverge in class sequence, and with --values also counts properties whose printed value differs
(table positions are ignored). Missing ids point at ReadWrite statements the model does not
reproduce; value differences point at wrong field types or sizes.
"""
import re, sys, collections


def objects(path):
    """[(class, ids, {propline...})] in walk order; prop lines belong to the most recent OBJ line."""
    out = []
    for line in open(path, encoding='utf-8'):
        m = re.match(r'\s*OBJ (\w+) ids=(.*)$', line)
        if m:
            ids = [int(x) for x in m.group(2).split(',') if x]
            out.append((m.group(1), ids, []))
            continue
        m = re.match(r'\s*(\w+)\s+= (.*)$', line)
        if m and out:
            out[-1][2].append((m.group(1), m.group(2).strip()))
    return out


def main():
    want_values = '--values' in sys.argv
    paths = [a for a in sys.argv[1:] if not a.startswith('--')]
    a, b = objects(paths[0]), objects(paths[1])
    print('objects: original %d, round trip %d' % (len(a), len(b)))
    missing = collections.defaultdict(collections.Counter)
    extra = collections.defaultdict(collections.Counter)
    values = collections.defaultdict(collections.Counter)
    examples = {}
    classes = collections.Counter()
    diverge = None
    for i in range(min(len(a), len(b))):
        (ca, ia, va), (cb, ib, vb) = a[i], b[i]
        if ca != cb:
            diverge = (i, ca, cb)
            break
        classes[ca] += 1
        for pid in set(ia) - set(ib):
            missing[ca][pid] += 1
        for pid in set(ib) - set(ia):
            extra[ca][pid] += 1
        if want_values:
            # positional: nested objects print their own lines first, so a dict would merge duplicates
            for k in range(min(len(va), len(vb))):
                (name, val), (name2, val2) = va[k], vb[k]
                if name == name2 and val != val2:
                    values[ca][name] += 1
                    examples.setdefault((ca, name), (val, val2))
    if diverge:
        print('class sequence diverges at object %d: original %s, round trip %s' % diverge)
    rows = []
    for cls in set(missing) | set(extra):
        rows.append((sum(missing[cls].values()) + sum(extra[cls].values()), cls))
    for total, cls in sorted(rows, reverse=True)[:25]:
        print('%-28s x%-5d missing %s  extra %s' % (cls, classes[cls],
              dict(sorted(missing[cls].items())) or '-', dict(sorted(extra[cls].items())) or '-'))
    if want_values:
        rows = [(sum(c.values()), cls) for cls, c in values.items()]
        for total, cls in sorted(rows, reverse=True)[:20]:
            for name, n in values[cls].most_common(4):
                o, m = examples[(cls, name)]
                print('%-28s %-26s differs x%-5d e.g. %s -> %s' % (cls, name, n, o[:40], m[:40]))


main()
