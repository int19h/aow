import itertools, subprocess, sys
from th import *
target = 0x733BD49A
K3 = 0x0c49e62c
def fold(fields):  # list of (type, offset)
    h = 0x0B17B67F
    for t, off in fields:
        h = (5*h + 0x73336EA7 + 5*(V[t] + off)) % M
    return h
inv125 = pow(125, -1, M)
cands = {}
T1 = ['Shortint', 'Byte', 'Char', 'Boolean', 'ByteBool']
ov = [[], [('Word',0)], [('Integer',0)], [('Word',0),('Integer',0)], [('Integer',0),('Word',0)], [('Smallint',0)],
      [('Word',0),('Word',2)], [('Smallint',0),('Integer',0)], [('Cardinal',0)], [('Pointer',0)], [('Word',0),('Cardinal',0)]]
for xt in T1:
  for lt in T1:
    for ft in T1:
      for o in ov:
        for pre in (False, True):
          base = [(xt,0),(xt,1),(lt,2),(ft,3)]
          fl = (o + base) if pre else (base + o)
          for pt in [(xt,xt,lt), ('Integer','Integer','Integer'), ('Byte','Byte','Byte'), ('Shortint','Shortint','Shortint')]:
            Hn = (K3 + 125*V[pt[0]] + 25*V[pt[1]] + 5*V[pt[2]]) % M
            th = ((target - Hn) * inv125) % M
            cands[(th - fold(fl)) % M] = (fl, pt)
words = open('words.txt').read().split()
for p in ['T','P','','TH','THN','THX','THS','THex','TMap']:
  for n in range(1,3):
    for combo in itertools.product(words, repeat=n):
      s = p + ''.join(combo)
      if nh(s) in cands: print('FOUND', s, cands[nh(s)])
print(len(cands))
for t,v in ([] if 1 else cands.items()):
    if t < 2**31:
        r = subprocess.run([sys.executable,'inv.py',str(t),'6'],capture_output=True,text=True).stdout.split()
        if r[-1] != '0': print('DFS', r[:5], v)
