import re, subprocess
f = 'C:/git/int19h/aow/src/delphi3/HSEPack/HSEngine.pas'
s = open(f, encoding='latin1', newline='').read()
fw = re.findall(r'  (\w+) = class;\r\n', s)
def build(keep):
    t = s
    for n in fw:
        if n not in keep: t = t.replace('  %s = class;\r\n' % n, '', 1)
    open(f, 'w', encoding='latin1', newline='').write(t)
    r = subprocess.run(['python', 'C:/Users/int19h/AppData/Local/Temp/hse_tools/check.py',
                        'C:/git/int19h/aow/src/delphi3/HSEPack', r'C:\Users\int19h\AppData\Local\Temp\hse'],
                       capture_output=True, text=True)
    return r.stdout
keep = set()
for it in range(60):
    out = build(keep)
    if 'built' in out: break
    m = re.findall(r"(?:Undeclared identifier|Type '(?:\w+)' is not yet completely defined): '(\w+)'", out)
    m += re.findall(r"Type '(\w+)' is not yet completely defined", out)
    m = [x for x in m if x in fw and x not in keep]
    if not m: print(out[:2000]); break
    keep.add(m[0])
print(sorted(keep), len(keep), 'of', len(fw))
