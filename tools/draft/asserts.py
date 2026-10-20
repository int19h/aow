"""Global line numbers of the Assert calls in a unit with its {$I} includes, as DCC32 counts
them. Usage: asserts.py <unit.pas> [original-lines.json]. (An include's lines take the place of the directive line), against the original's."""
import os, re, sys, json
D = os.path.dirname(os.path.abspath(sys.argv[1]))
ORIG = {}
if len(sys.argv)>2:
    ORIG = {(f, int(n)): line for f,n,line in json.load(open(sys.argv[2]))}
main = open(sys.argv[1], encoding='latin1').read().split('\n')
g = 0
prev = None
for i, l in enumerate(main, 1):
    m = re.match(r'\{\$I inc\\(\w+\.PAS)\}', l)
    if not m:
        g += 1
        continue
    f = m.group(1)
    inc = open(D + '/inc/' + f, encoding='latin1').read().split('\n')
    if inc and inc[-1] == '': inc = inc[:-1]
    n = 0
    for j, il in enumerate(inc, 1):
        if 'Assert(' in il:
            n += 1
            o = ORIG.get((f, n))
            print('%-13s line %4d  global %5d  original %s  %s' % (f, j, g + j, o, '' if o is None else '%+d' % (g + j - o)))
    g += len(inc) + 1  # the directive line counts too after the include
