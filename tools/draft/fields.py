"""Inspect field accesses in Ghidra output. Usage: fields.py <decomp-dir> Class..."""
import re, os, sys, collections, glob
D = sys.argv[1]
acc = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
users = collections.defaultdict(lambda: collections.defaultdict(set))
for f in glob.glob(D + '/*.c'):
    src = open(f, encoding='latin1').read()
    fn = os.path.basename(f)[9:].rsplit('_', 1)[0]
    types = {}
    m = re.match(r'[^(]*\(([^)]*)\)', src.split('\n\n', 1)[-1].strip())
    decls = re.findall(r'\b(T\w+) \*(\w+)\b', src)
    for t, v in decls: types[v] = t
    for m in re.finditer(r'(?:\*\((\w+(?: \w+)?) \*\)&)?(?:\(\((T\w+) \*\)(\w+)\)|(\w+))->field_0x([0-9a-f]+)', src):
        cast, ct, cv, v, off = m.groups()
        t = ct or types.get(v)
        if not t: continue
        acc[t][int(off, 16)][cast or 'byte?'] += 1
        users[t][int(off, 16)].add(fn.split('.')[-2] + '.' + fn.split('.')[-1] if fn.count('.') >= 2 else fn)
cls = sys.argv[2:]
for t in cls:
    print('==', t)
    for off in sorted(acc[t]):
        u = sorted(users[t][off])
        print('  +%03X %-40s %s' % (off, dict(acc[t][off]), ' '.join(u[:6]) + (' ...%d' % len(u) if len(u) > 6 else '')))
