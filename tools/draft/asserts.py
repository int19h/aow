"""Global line numbers of the Assert calls in HSEngine.pas with its {$I} includes, as DCC32 counts
them (an include's lines take the place of the directive line), against the original's."""
import os, re
D = 'C:/git/int19h/aow/src/delphi3/HSEPack'
ORIG = {('HXSPRITE.PAS', 1): 2475, ('HXSPRITE.PAS', 2): 2681, ('MAPOBJ.PAS', 1): 4328,
        ('MAPOBJ.PAS', 2): 4334, ('MAPOBJ.PAS', 3): 4340, ('HSMAP.PAS', 1): 5989, ('LibImgHS.PAS', 1): 6626}
main = open(D + '/HSEngine.pas', encoding='latin1').read().split('\n')
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
