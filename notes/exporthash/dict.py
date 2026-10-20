# dict.py target weight name=hash ... : dictionary attack on the type name
import sys, itertools
def nh(s):
    h = 0
    for c in s: h = (h * 17 + ord(c)) & 0xffffffff
    return h
M = 2**32
target = int(sys.argv[1], 16); w = int(sys.argv[2])
inv = pow(w, -1, M)
tg = {}
for a in sys.argv[3:]:
    n, h = a.split('=')
    tg[(nh(n) + (target - int(h, 16)) * inv) % M] = a
words = open('C:/Users/int19h/AppData/Local/Temp/hse_A/tools/words.txt').read().split()
pre = ['T', 'P', '', 'TPacked', 'THS', 'TMap', 'THex']
found = 0
for p in pre:
    for n in range(1, 4):
        for combo in itertools.product(words, repeat=n):
            s = p + ''.join(combo)
            if nh(s) in tg: print('FOUND', s, tg[nh(s)]); found += 1
print('done', found)
