import sys
for p in sys.argv[1:]:
    d = open(p, newline='').read().replace('\r\n', '\n').replace('\n', '\r\n')
    open(p, 'w', newline='').write(d)
