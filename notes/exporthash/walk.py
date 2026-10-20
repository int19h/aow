import itertools, subprocess, sys
from th import *
THp = 0x15BD5587
THrec2 = rec(['Integer','Integer'])
THarr2 = 0x0D1D4325
target_th = ((0x77BE26A7-0x810e00d5)*inv5)%M
# structures: 8 ints, pairs grouped
cands = {}
def gen(i, cur):
    if i == 8:
        yield list(cur); return
    yield from gen(i+1, cur+[('Integer',V['Integer'],4)])
    if i <= 6:
        for nm,t in [('TPoint',THp),('rec2',THrec2),('arr2',THarr2)]:
            yield from gen(i+2, cur+[(nm,t,8)])
for st in gen(0, []):
    h=0x0B17B67F; off=0
    for nm,t,sz in st:
        h=(5*h+0x73336EA7+5*(t+off))%M; off+=sz
    cands[(target_th-h)%M]=[s[0] for s in st]
words=open('words.txt').read().split()
for p in ['T','P','','TH','THN','THX','THS','THex']:
  for n in range(1,4):
    for combo in itertools.product(words,repeat=n):
      s=p+''.join(combo)
      if nh(s) in cands: print('FOUND',s,cands[nh(s)])
print(len(cands))
