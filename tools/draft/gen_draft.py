import json, re, sys, collections
sys.path.insert(0, 'C:/Users/int19h/AppData/Local/Temp/hse_tools')
from entry import analyze, sigs
R = 'C:/git/int19h/aow/'
classes = json.load(open(R + 'notes/classes.json'))['classes']
UNIT = sys.argv[1]
# base declarations from Engine.pas (and a few VCL ones)
base_decl = {}
def parse_pas(path):
    cur = None
    txt = open(path, encoding='latin1').read().split('\nimplementation')[0]
    lines = txt.split('\n')
    i = 0
    while i < len(lines):
        l = lines[i]
        m = re.match(r'\s*(T\w+) = class\((\w+)\)', l)
        if m: cur = m.group(1)
        m = re.match(r'\s*((?:class )?(?:procedure|function|constructor|destructor)) (\w+)(.*)', l)
        if m and cur:
            decl = l.strip()
            while not re.search(r';\s*$', decl) or decl.count('(') > decl.count(')'):
                i += 1; decl += ' ' + lines[i].strip()
            base_decl[(cur, m.group(2))] = decl
        i += 1
parse_pas(R + 'src/delphi3/Engine.pas')
parse_pas(R + 'src/delphi3/Ilpack/ImageLib.pas')
parse_pas(R + 'src/delphi3/Dcpack/DisplayC.pas')
VCL = {
 'Loaded': 'procedure Loaded; override;',
 'Notification': 'procedure Notification(AComponent: TComponent; Operation: TOperation); override;',
 'Create': 'constructor Create(AOwner: TComponent); override;',
 'Assign': 'procedure Assign(Source: TPersistent); override;',
 'AssignTo': 'procedure AssignTo(Dest: TPersistent); override;',
 'DefineProperties': 'procedure DefineProperties(Filer: TFiler); override;',
 'SetName': 'procedure SetName(const NewName: TComponentName); override;',
}
def find_base(cls, name):
    c = cls
    while c:
        if (c, name) in base_decl: return base_decl[(c, name)]
        c = classes[c]['parent'] if c in classes else None
    return None
children = collections.defaultdict(list)
for n, c in classes.items(): children[c['parent']].append(n)
def desc(n):
    out = []
    for ch in children[n]: out += [ch] + desc(ch)
    return out
def mod_of(n): return classes[n]['module']
def nslots(n): return len(classes[n]['vmt']) if n in classes else 0
W = {1: 'Byte', 2: 'Word', 4: 'Integer', '?': 'Integer'}
def ret_of(s):
    r = s['ret'] if s else 'undefined'
    if r in ('undefined', 'void'): return None
    if r in ('undefined1', 'char', 'byte', 'bool'): return 'Byte'
    if r in ('undefined2', 'short', 'ushort'): return 'Word'
    return 'Integer'
def draft_sig(impls, ctor=False):
    edx = ecx = 0; stk = 0; ret = None
    for mod, va, s in impls:
        used, rn = analyze(mod, va, s['size'])
        edx = max(edx, used.get('edx', 0)); ecx = max(ecx, used.get('ecx', 0))
        stk = max(stk, rn or 0)
        r = ret_of(s)
        if r and not ret: ret = r
    ps = []
    if ctor:
        if ecx: ps.append(W[ecx])
    else:
        if edx or ecx or stk: ps.append(W[edx or 4])
        if ecx or stk: ps.append(W[ecx or 4])
    ps += ['Integer'] * (stk // 4)
    return ps, ret
def strip_dir(b):
    b = re.sub(r'\s*(virtual|override|dynamic)\s*;(\s*abstract\s*;)?.*$', '', b)
    return b.rstrip(';').rstrip()
own_unit_classes = []
for n, c in sorted(classes.items(), key=lambda kv: kv[1].get('vmt_va', '')):
    if c['module'] != 'HSEPack.dpl': continue
    syms = [v['symbol'] for v in c['vmt'] if v['own']] + [v['symbol'] for v in c['fixed'].values()]
    us = {s.split('.')[0] for s in syms if s.split('.')[1] == n}
    if us == {UNIT} or (not us and UNIT == 'HSEngine'): own_unit_classes.append(n)
own_unit_classes = [x for x in own_unit_classes if x not in ('TProgressDlg', 'THSEditModule')]
if len(sys.argv) > 2: own_unit_classes = [x for x in own_unit_classes if x in sys.argv[2].split(',')]
hse = {s['name'].split('@')[0]: (a, s) for a, s in sigs('HSEPack.dpl').items()}
out = []
for n in own_unit_classes:
    c = classes[n]; p = c['parent']; ps_ = nslots(p)
    vnames = {v['name'] for v in c['vmt']} | set(c['fixed'])
    lines = []
    for k, v in c['fixed'].items():
        if v['symbol'] == '%s.%s.%s' % (UNIT, n, k):
            b = find_base(p, k) or {'Destroy': 'destructor Destroy;', 'NewInstance': 'class function NewInstance: TObject;', 'FreeInstance': 'procedure FreeInstance;'}.get(k)
            lines.append(strip_dir(b) + '; override;')
    for i, v in enumerate(c['vmt']):
        intro = i >= ps_
        if not intro:
            if not v['own']: continue
            b = find_base(p, v['name']) or VCL.get(v['name'])
            if b:
                lines.append('%s; override;' % strip_dir(b))
            else:
                lines.append('procedure %s; override; { ?base }' % v['name'])
            continue
        impls = []
        for d in [n] + desc(n):
            if d not in classes or i >= len(classes[d]['vmt']): continue
            vv = classes[d]['vmt'][i]
            if vv['own']:
                s = sigs(mod_of(d)).get(int(vv['target'], 16))
                if s: impls.append((mod_of(d), int(vv['target'], 16), s))
        abstract = not v['own']
        ps, ret = draft_sig(impls)
        args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
        kw = 'function' if ret else 'procedure'
        d = '%s %s%s%s;' % (kw, v['name'], args, (': ' + ret) if ret else '')
        lines.append('%s virtual;%s  { +%03X draft }' % (d, ' abstract;' if abstract else '', v['offset']))
        base_decl[(n, v['name'])] = d + ' virtual;'
    for name, (va, s) in sorted(hse.items(), key=lambda kv: kv[1][0]):
        parts = name.split('.')
        if len(parts) != 3 or parts[0] != UNIT or parts[1] != n or parts[2] in vnames: continue
        ctor = parts[2] == 'Create' and p in ('TObject', 'TPersistent', 'TComponent', 'TEComponent')
        ps, ret = draft_sig([('HSEPack.dpl', va, s)], ctor=ctor)
        args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
        if ctor: kw = 'constructor'; ret = None
        else: kw = 'function' if ret else 'procedure'
        lines.append('%s %s%s%s;  { draft }' % (kw, parts[2], args, (': ' + ret) if ret else ''))
    out.append((n, p, c['size'], c['vmt_va'], lines))
for n, p, size, vmt, lines in out:
    print('  { %s (instance size %d, VMT %s) }' % (n, size, vmt))
    print('  %s = class(%s)' % (n, p))
    print('  public')
    for l in lines: print('    ' + l)
    print('  end;')
    print()
