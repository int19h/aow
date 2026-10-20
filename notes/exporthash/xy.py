import sys, subprocess, itertools
M=2**32;C=0x579778F0;C0=0x6A433DA2;THi=0xB585C686;THp=0x15BD5587
THr=(0x65CA2709-C)%M
inv41=pow(41,-1,M)
Ks=((C-C0)*inv41)%M
Ke=0x7E350812 - 23*1
THbool=0xBE8E9287
def nh(s):
  h=0
  for c in s: h=(h*17+ord(c))%M
  return h
arr=lambda e,i:(e+41*i+C0)%M
sub=lambda lo,hi:(Ks+23*(17*lo+hi))%M
target=int(sys.argv[1],16)
cands={}
Es={'TPoint':THp,'anonrec':THr,'int2':arr(THi,sub(0,1))}
I1s={'Boolean':THbool,'0..1':sub(0,1)}
for en,e in Es.items():
  for i1n,i1 in I1s.items():
    # target = arr(arr(e, I2), i1) = e + 41*I2 + C0 + 41*i1 + C0
    I2=((target - e - 2*C0 - 41*i1)*inv41)%M
    for lo,hi in [(0,7),(1,8),(0,6),(1,6),(-1,6),(0,5)]:
      cands[(I2-sub(lo,hi))%M]=(en,i1n,'sub',lo,hi)
    for n in range(2,10):
      cands[(I2-(Ke+23*(n-1)))%M]=(en,i1n,'enum',n)
    # also 2nd dim first (I2 outer) 
words=open('words.txt').read().split()+['Dir','Direction','Directions','Neighbour','Neighbor','Side','Sides','Number','Num','N','HN','HT','HNs','Ring','Range','Rad','Radius','Count','Idx','Six','Seven','Hexes']
for p in ['T','','TH','THX','THN','THS','THex']:
  for n in range(1,4):
    for combo in itertools.product(words,repeat=n):
      s=p+''.join(combo)
      if nh(s) in cands: print('FOUND',s,cands[nh(s)])
for t,v in cands.items():
  r=subprocess.run([sys.executable,'inv.py',str(t),'7'],capture_output=True,text=True).stdout.split()
  if r[-1]!='0': print(v, r[:8])
print('done')
