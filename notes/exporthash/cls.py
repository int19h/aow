# cls.py variants.txt ClassName : each variant (separated by %%%%) is the full type section; prints hash of ClassName
import sys, subprocess
vs = open(sys.argv[1]).read().replace('\r\n','\n').split('\n%%%%\n')
cn = sys.argv[2]
impl = ''
if '\n####\n' in vs[0]:
    pass
for k, v in enumerate(vs):
    t, _, im = v.partition('\n####\n')
    open('../t/_c.txt', 'w').write('#types\n' + t + '\n#impl\n' + im + '\n')
    r = subprocess.run([sys.executable, 'hh.py', '../t/_c.txt'], capture_output=True, text=True).stdout
    l = [x for x in r.splitlines() if x.split() and x.split()[0] in (cn, '.' + cn)]
    print(k, ' | '.join(l) if l else r[-300:])
