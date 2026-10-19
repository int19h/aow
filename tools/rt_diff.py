"""Compare two --flat walks (original file and round-trip output) object by object.

Usage: rt_diff.py <orig.txt> <mine.txt>

Objects are matched in walk order. For every class the script counts the property ids that the
original has and the round trip lacks (missing) or adds (extra), and reports where the two walks
first diverge in class sequence. Missing ids point at ReadWrite statements the model does not
reproduce (usually TODOs in AoWModel.pas.report.txt).
"""
import re, sys, collections


def objects(path):
    out = []
    for line in open(path, encoding='utf-8'):
        m = re.match(r'\s*OBJ (\w+) ids=(.*)$', line)
        if m:
            ids = [int(x) for x in m.group(2).split(',') if x]
            out.append((m.group(1), ids))
    return out


def main():
    a, b = objects(sys.argv[1]), objects(sys.argv[2])
    print('objects: original %d, round trip %d' % (len(a), len(b)))
    missing = collections.defaultdict(collections.Counter)
    extra = collections.defaultdict(collections.Counter)
    classes = collections.Counter()
    diverge = None
    for i in range(min(len(a), len(b))):
        (ca, ia), (cb, ib) = a[i], b[i]
        if ca != cb:
            diverge = (i, ca, cb)
            break
        classes[ca] += 1
        for pid in set(ia) - set(ib):
            missing[ca][pid] += 1
        for pid in set(ib) - set(ia):
            extra[ca][pid] += 1
    if diverge:
        print('class sequence diverges at object %d: original %s, round trip %s' % diverge)
    rows = []
    for cls in set(missing) | set(extra):
        rows.append((sum(missing[cls].values()) + sum(extra[cls].values()), cls))
    for total, cls in sorted(rows, reverse=True)[:25]:
        print('%-28s x%-5d missing %s  extra %s' % (cls, classes[cls],
              dict(sorted(missing[cls].items())) or '-', dict(sorted(extra[cls].items())) or '-'))


main()
