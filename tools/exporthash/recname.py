import sys, subprocess, itertools
M=2**32;C=0x579778F0;THi=0xB585C686
THr=(0x65CA2709-C)%M
Bb=(0xA49E7BC7-THi)%M
def nh(s):
  h=0
  for c in s: h=(h*17+ord(c))%M
  return h
d=lambda lo,hi:(943*(17*lo+hi)+C)%M
target=int(sys.argv[1],16)
cands={}
for n1,v1 in [('Boolean',Bb),('0..1',d(0,1))]:
  for lo,hi in [(0,7),(1,8),(0,6),(-1,6)]:
    t=(target - v1 - d(lo,hi) - THr)%M
    cands[t]=(n1,lo,hi)
words=open('words.txt').read().split()
for p in ['T','P','','TH','THX','THN','THS']:
  for n in range(1,4):
    for combo in itertools.product(words,repeat=n):
      s=p+''.join(combo)
      if nh(s) in cands: print('FOUND',s,cands[nh(s)])
for t,v in cands.items():
  r=subprocess.run([sys.executable,'inv.py',str(t),'8'],capture_output=True,text=True).stdout.split()
  print(v, t, r[:8], r[-1])
