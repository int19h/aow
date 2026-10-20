"""Minimize forward declarations from compiler diagnostics. Usage: fwd.py <unit.pas> -- <build command...>"""
import re, subprocess, sys
f = sys.argv[1]
command = sys.argv[sys.argv.index('--')+1:]
s = open(f, encoding='latin1', newline='').read()
fw = re.findall(r'  (\w+) = class;\r\n', s)
def build(keep):
    t = s
    for n in fw:
        if n not in keep: t = t.replace('  %s = class;\r\n' % n, '', 1)
    open(f, 'w', encoding='latin1', newline='').write(t)
    r = subprocess.run(command, capture_output=True, text=True)
    return r.stdout
keep = set()
for it in range(60):
    out = build(keep)
    if not re.search(r'Error|Fatal|not yet completely defined', out): break
    m = re.findall(r"(?:Undeclared identifier|Type '(?:\w+)' is not yet completely defined): '(\w+)'", out)
    m += re.findall(r"Type '(\w+)' is not yet completely defined", out)
    m = [x for x in m if x in fw and x not in keep]
    if not m: print(out[:2000]); break
    keep.add(m[0])
print(sorted(keep), len(keep), 'of', len(fw))
