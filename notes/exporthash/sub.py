# sub.py file < pairs: OLD\n====\nNEW, pairs separated by lines %%%%
import sys
p = sys.argv[1]
s = open(p, newline='').read().replace('\r\n', '\n')
for pair in sys.stdin.read().replace('\r\n', '\n').split('\n%%%%\n'):
    old, new = pair.split('\n====\n')
    new = new.rstrip('\n') if not old.endswith('\n') else new
    if old not in s:
        print('NOT FOUND:', old[:70]); continue
    s = s.replace(old, new)
open(p, 'w', newline='').write(s.replace('\n', '\r\n'))
