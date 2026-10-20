import sys
t = int(sys.argv[1], 0)
maxlen = int(sys.argv[2]) if len(sys.argv) > 2 else 12
upper = len(sys.argv) > 3
cs = [ord(c) for c in ('ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_' if upper else 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_')]
res = []
def dfs(t, suffix):
    # t = nh(prefix)*17 + c  ; exact integers (no wrap)
    if len(suffix) > maxlen: return
    for c in cs:
        r = t - c
        if r < 0: continue
        if r == 0:
            s = chr(c) + suffix
            if s[0] == 'T' or s[0] == 'P': res.append(s)
            continue
        if r % 17: continue
        dfs(r // 17, chr(c) + suffix)
dfs(t, '')
for s in sorted(res, key=len)[:200]: print(s)
print(len(res))
