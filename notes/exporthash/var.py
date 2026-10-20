# var.py file func variants.txt : variants separated by %%%% ; each "OLD\n====\nNEW" (multiple pairs joined by &&&&)
import sys, subprocess, re
p, func, vf = sys.argv[1:4]
orig = open(p, newline='').read()
txt = open(vf).read().replace('\r\n', '\n')
S = 'C:/Users/int19h/AppData/Local/Temp/hse_A/src'
try:
    for k, var in enumerate(txt.split('\n%%%%\n')):
        s = orig.replace('\r\n', '\n')
        ok = True
        for pair in var.split('\n&&&&\n'):
            old, new = pair.split('\n====\n')
            if old not in s: print(k, 'NOT FOUND', old[:50]); ok = False
            s = s.replace(old, new)
        if not ok: continue
        open(p, 'w', newline='').write(s.replace('\n', '\r\n'))
        r = subprocess.run([sys.executable, 'C:/Users/int19h/AppData/Local/Temp/hse_tools/check.py', S, 'C:/Users/int19h/AppData/Local/Temp/hse_A/o', '--units', 'HSEngine', 'TNewHSMapSettings', 'TTerrainList', 'TXYLList'], capture_output=True, text=True)
        if 'functions match' not in r.stdout: print(k, r.stdout[-300:]); continue
        for f in func.split(','):
            lines = [l for l in r.stdout.splitlines() if l.startswith(f + ' ') and ('differs' in l or 'not in map' in l)]
            print(k, f, lines[0].split(None, 1)[1].strip() if lines else 'MATCH')
finally:
    open(p, 'w', newline='').write(orig)
