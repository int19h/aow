# hh.py decls.txt : test declarations in a scratch HSEngine unit (package), print export hashes
# decls.txt: lines; a section "#types" (raw type decls), "#routines" (one per line), "#consts", "#vars"
# prints every export of HSEngine with its hash, plus for each routine the original hashes it equals
import sys, re, subprocess, os, pefile
D = 'C:/Users/int19h/AppData/Local/Temp/hse_A/t/h'
src = open(sys.argv[1]).read().replace('\r\n', '\n')
sec = {'types': [], 'routines': [], 'consts': [], 'vars': [], 'uses': [], 'impl': []}
cur = None
for l in src.split('\n'):
    m = re.match(r'#(\w+)', l)
    if m: cur = m.group(1); continue
    if cur: sec[cur].append(l)
uses = ' '.join(sec['uses']).strip() or 'Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Engine, EngineLists, GFXE'
o = ['unit HSEngine;', '', 'interface', '', 'uses', '  ' + uses + ';', '']
if any(x.strip() for x in sec['types']): o += ['type'] + sec['types']
o += [r for r in sec['routines'] if r.strip()]
if any(x.strip() for x in sec['consts']): o += ['const'] + sec['consts']
if any(x.strip() for x in sec['vars']): o += ['var'] + sec['vars']
o += ['', 'implementation', '']
for r in sec['routines']:
    if r.strip(): o += [r.strip(), 'begin', 'end;', '']
o += sec['impl']
o += ['end.']
open(D + '/HSEngine.pas', 'w', newline='').write('\r\n'.join(o) + '\r\n')
open(D + '/hp.dpk', 'w', newline='').write('package hp;\r\n\r\nrequires\r\n  vcl30;\r\n\r\ncontains\r\n  HSEngine;\r\n\r\nend.\r\n')
U = r'C:\git\int19h\aow\src\delphi3;C:\git\int19h\aow\src\delphi3\Dcpack;C:\git\int19h\aow\src\delphi3\Gfxepack;C:\git\int19h\aow\src\delphi3\Ilpack;C:\git\int19h\aow\src\delphi3\Ilpack\stubs;C:\git\int19h\aow\src\delphi3\SoundP'
out = D.replace('/', chr(92)) + chr(92) + 'o'
os.makedirs(out, exist_ok=True)
r = subprocess.run([r'C:\Tools\Delphi3\BIN\DCC32.EXE', '-B', '-Q', '-U' + U, r'-OC:\git\int19h\aow\src\delphi3', '-E' + out, '-N' + out, '-LE' + out, '-LN' + out, 'hp.dpk'], cwd=D, capture_output=True, text=True)
for f in os.listdir(D):
    if f.endswith('.drc'): os.remove(os.path.join(D, f))
msgs = [l for l in r.stdout.splitlines() if 'Error' in l or 'Fatal' in l]
if msgs: print('\n'.join(msgs)); sys.exit(1)
def exps(p):
    pe = pefile.PE(p, fast_load=True)
    pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
    return {e.name.decode().split('@')[0]: e.name.decode().split('@')[1] for e in pe.DIRECTORY_ENTRY_EXPORT.symbols if e.name and '@' in e.name.decode()}
b = exps(out + chr(92) + 'hp.dpl'); o2 = exps('D:/Games/GOG/Age of Wonders/HSEPack.dpl')
inv = {}
for k, v in o2.items():
    if k.startswith('HSEngine.') and (k.count('.') == 1 or k.startswith('HSEngine..')): inv.setdefault(v, []).append(k[9:])
for k in sorted(b):
    if not k.startswith('HSEngine.') or (k.count('.') != 1 and not k.startswith('HSEngine..')): continue
    n = k[9:]
    base = re.sub(r'_\w+$', '', n)
    tag = 'SAME' if o2.get('HSEngine.' + base) == b[k] else ''
    print('%-32s %s %-5s %s' % (n, b[k], tag, ','.join(inv.get(b[k], []))))
