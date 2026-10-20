"""Write matchtest.dpr for HSEPack: every class of the listed units referenced as a class value, every
non-virtual method and unit routine by address (@TClass.Method), so the host does not depend on the
parameter lists. Usage: gen_host.py <dir> Unit1 Unit2 ..."""
import re, sys, os, glob
d = sys.argv[1]; units = sys.argv[2:]
classes = []; methods = []
def scan(text):
    intf = text.split('\nimplementation')[0]
    cur = None; vis = 'public'
    for l in intf.split('\n'):
        m = re.match(r'\s*(\w+) = class\((\w+)\)', l)
        if m: cur = m.group(1); classes.append(cur); vis = 'public'; continue
        if cur and re.match(r'\s*end;', l): cur = None; continue
        m = re.match(r'\s*(private|protected|public|published)\s*$', l)
        if m: vis = m.group(1); continue
        if cur and vis in ('private', 'protected'): continue
        m = re.match(r'\s*(?:class )?(procedure|function|constructor|destructor) (\w+)', l)
        if not m: continue
        if cur and ('virtual' in l or 'override' in l or 'dynamic' in l or 'message' in l): continue
        if cur: methods.append(cur + '.' + m.group(2))
        elif m.group(2) != 'Register': methods.append(m.group(2))
        else: methods.append(UNIT[0] + '.Register')
def expand(path):
    text = open(path, encoding='latin1').read()
    def inc(m):
        p = os.path.join(os.path.dirname(path), m.group(1))
        return open(p, encoding='latin1').read() if os.path.exists(p) else ''
    return re.sub(r'\{\$I ([^}]+)\}', inc, text)
UNIT = ['']
for u in units:
    UNIT[0] = u
    scan(expand(os.path.join(d, u + '.pas')))
o = ['program matchtest;', '',
     '{ Host program for the byte-matching of HSEPack.dpl: it references every class and every',
     '  non-virtual method so that the linker keeps them; it is linked, never run. Build from this',
     '  directory with the original compiler into a directory with a short path (DCC32 crashes on',
     '  long paths):',
     '    C:\\Tools\\Delphi3\\BIN\\DCC32.EXE -GD -B -Q "-U..;..\\Dcpack;..\\Gfxepack;..\\Ilpack;..\\Ilpack\\stubs;..\\SoundP"',
     '      -O.. -E<outdir> -N<outdir> matchtest.dpr',
     '  -GD writes matchtest.map with the address of every method; tools/match.py reads it. }', '',
     '{$APPTYPE CONSOLE}', '', 'uses', '  SysUtils, Classes,']
o.append(',\n'.join("  %s in '%s.pas'" % (u, u) for u in units) + ';')
o += ['', 'var', '  C: TClass;', '  P: Pointer;', '', 'procedure Use(C: TClass; P: Pointer);', 'begin',
      '  Writeln(Integer(C), Integer(P));', 'end;', '', 'begin']
for c in classes: o.append('  Use(%s, nil);' % c)
for m in methods: o.append('  Use(nil, @%s);' % m)
ex = os.path.join(d, 'matchtest.extra')
if os.path.exists(ex):
    NL = chr(10)
    decl, calls = open(ex).read().split('---' + NL)
    i = o.index('begin', o.index("procedure Use(C: TClass; P: Pointer);") + 2)
    o[i:i] = decl.rstrip(NL).split(NL) + ['']
    o += calls.rstrip(NL).split(NL)
o.append('end.')
open(os.path.join(d, 'matchtest.dpr'), 'w', newline='').write('\r\n'.join(o).replace('\n', '\r\n').replace('\r\r\n', '\r\n') + '\r\n')
print(len(classes), 'classes', len(methods), 'methods')
