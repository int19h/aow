import sys, itertools, subprocess
def nh(s):
    h = 0
    for c in s: h = (h * 17 + ord(c)) & 0xffffffff
    return h
M = 2**32
target = int(sys.argv[2], 16); w = int(sys.argv[3])
d = {}
for l in open(sys.argv[1]):
    n, h = l.split()[:2]; d[n] = int(h, 16)
inv = pow(w, -1, M)
S = sorted([k for k in d if '_s' in k], key=lambda k: int(k.split('_s')[1]))
P = sorted([k for k in d if '_p' in k])
tg = {}
for s in S:
    for p in P:
        H = (d[s] + d[p] - d[P[0]]) % M
        name = 'TS' + s.split('_s')[1]
        t = (nh(name) + (target - H) * inv) % M
        tg[t] = (s, p)
words = open('C:/Users/int19h/AppData/Local/Temp/hse_A/tools/words.txt').read().split()
pre = ['T', 'P', '', 'TPacked', 'THS', 'TMap', 'THex', 'TH']
for p in pre:
    for n in range(1, 4):
        for combo in itertools.product(words, repeat=n):
            s = p + ''.join(combo)
            if nh(s) in tg: print('FOUND', s, tg[nh(s)])
for t, v in tg.items():
    if t < 2**32:
        r = subprocess.run([sys.executable, 'C:/Users/int19h/AppData/Local/Temp/hse_A/tools/inv.py', str(t), '8'], capture_output=True, text=True).stdout.split()
        if r[-1] != '0': print('DFS', v, r[:10])
print('done')
