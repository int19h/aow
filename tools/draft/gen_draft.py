"""Generate class declarations from layouts and entry analysis; used by gen_unit.py."""
import json, re, sys, collections
from pathlib import Path
from config import parser, configure
opts = parser(__doc__).parse_args()
configure(opts)
from entry import analyze, sigs
classes = json.load(open(opts.classes))['classes']
UNIT = opts.unit
MOD = opts.module.name
# base declarations from Engine.pas (and a few VCL ones)
base_decl = {}
base_unit = {}
type_unit = {}
source_types = {}
source_uses = {}
def parse_pas(path):
    txt = open(path, encoding='latin1').read()
    unit = re.search(r'\bunit\s+(\w+)', txt, re.I)
    if not unit: return
    unit = unit.group(1)
    txt = re.split(r'^\s*implementation\b', txt, flags=re.I|re.M)[0]
    txt = re.sub(r'\{[^}]*\}|\(\*.*?\*\)|//[^\n]*', '', txt, flags=re.S)
    source_uses[unit] = re.findall(r'\w+', (re.search(r'\buses\s+(.*?);',txt,re.S|re.I).group(1) if re.search(r'\buses\s+(.*?);',txt,re.S|re.I) else ''))
    source_types[unit] = set()
    for name in re.findall(r'^\s*(\w+)\s*=\s*(?!class;)', txt, re.M):
        type_unit.setdefault(name.lower(), unit)
        source_types[unit].add(name.lower())
    for m in re.finditer(r'\b(\w+)\s*=\s*class\s*(?:\(\w+\))?\s+(.*?)(?=\bend\s*;)', txt, re.S|re.I):
        cur, body = m.groups()
        for d in re.finditer(r'\b((?:class\s+)?(?:procedure|function|constructor|destructor))\s+(\w+)\s*((?:\([^)]*\))?[^;]*;\s*(?:(?:virtual|override|dynamic|abstract|reintroduce|stdcall|cdecl|register)\s*;\s*)*)', body, re.S|re.I):
            key = (cur.lower(), d.group(2).lower())
            base_decl[key] = re.sub(r'\s+', ' ', d.group(0)).strip()
            base_unit[key] = unit
for path in sorted(opts.source_root.rglob('*.pas')):
    if path.parent.name.lower() == opts.module.stem.lower(): continue
    parse_pas(path)
if opts.vcl_source:
    for path in sorted(opts.vcl_source.rglob('*.pas')): parse_pas(path)
import pefile
pe = pefile.PE(str(opts.module))
owners = {}
for e in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if not e.name: continue
    m = re.match(r'(\w+)\.\.(\w+)@', e.name.decode())
    if m and m.group(2) in classes: owners[m.group(2)] = m.group(1)
for n,c in classes.items():
    if c['module'].lower() != MOD.lower(): continue
    for v in list(c['fixed'].values()) + c['vmt']:
        parts = (v.get('symbol') or '').split('.')
        if len(parts) == 3 and parts[1] == n: owners.setdefault(n, parts[0])
# Recovered signature names fill gaps in the original export-derived layout metadata.
module_sigs = sigs(MOD)
for va,fn in module_sigs.items():
    parts = fn['name'].split('@')[0].split('.')
    if len(parts) >= 2 and parts[1] in classes: owners[parts[1]] = parts[0]
for n,c in classes.items():
    if c['module'].lower() != MOD.lower(): continue
    for v in list(c['fixed'].values()) + c['vmt']:
        fn = module_sigs.get(int(v['target'],16))
        if fn and fn['name'].count('.') == 2:
            v['symbol'] = fn['name'].split('@')[0]
            if 'own' in v:
                v['name'] = v['symbol'].split('.')[-1]
                v['own'] = v['symbol'].split('.')[1] == n
# Methodless classes follow their unit's neighboring VMTs.
previous = None
for n,c in sorted(classes.items(), key=lambda kv: kv[1].get('vmt_va','')):
    if c['module'].lower() != MOD.lower(): continue
    if n in owners: previous = owners[n]
    elif previous: owners[n] = previous
if MOD.lower() == 'aowepack.dpl': owners['TRegistrator'] = 'City'
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
        key = (c.lower(), name.lower())
        if key in base_decl:
            decl = base_decl[key]
            unit = base_unit.get(key)
            if unit:
                visible = source_uses.get(unit,[]) + [unit]
                def qualify(m):
                    token = m.group(0)
                    for u in reversed(visible):
                        if token.lower() in source_types.get(u,set()): return u+'.'+token
                    return token
                decl = re.sub(r'\b[TP][A-Z]\w*\b', qualify, decl)
            return decl
        c = classes[c]['parent'] if c in classes else None
    return None
children = collections.defaultdict(list)
for n, c in classes.items(): children[c['parent']].append(n)
def desc(n):
    out = []
    for ch in children[n]: out += [ch] + desc(ch)
    return out
for n,c in classes.items():
    for i,v in enumerate(c['vmt']):
        if not v['name']:
            names = [classes[d]['vmt'][i]['name'] for d in desc(n) if i < len(classes[d]['vmt']) and classes[d]['vmt'][i]['name']]
            v['name'] = names[0] if names else 'VMT_%03X' % v['offset']
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
own_unit_classes = [n for n,c in sorted(classes.items(), key=lambda kv: kv[1].get('vmt_va', ''))
                    if c['module'].lower() == MOD.lower() and n in owners]
ordered = []
def order(n):
    if n in ordered: return
    p = classes[n]['parent']
    if p in own_unit_classes: order(p)
    ordered.append(n)
for n in own_unit_classes: order(n)
own_unit_classes = ordered
hse = {s['name'].split('@')[0]: (a,s) for a,s in sigs(MOD).items()}
out = []
for n in own_unit_classes:
    c = classes[n]; p = c['parent']; ps_ = nslots(p)
    UNIT = owners[n]
    vnames = {v['name'].lower() for v in c['vmt']} | {k.lower() for k in c['fixed']}
    lines = []
    for k, v in c['fixed'].items():
        if (v.get('symbol') or '').lower() == ('%s.%s.%s' % (UNIT, n, k)).lower():
            b = find_base(p, k) or {'Destroy': 'destructor Destroy;', 'NewInstance': 'class function NewInstance: TObject;', 'FreeInstance': 'procedure FreeInstance;'}.get(k)
            lines.append(strip_dir(b) + '; override;')
    for i, v in enumerate(c['vmt']):
        intro = i >= ps_
        if not intro:
            if not v['own'] or not (v.get('symbol') or '').startswith(UNIT + '.' + n + '.'): continue
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
                s = sigs(mod_of(d)).get(int(vv['target'], 16)) if (Path(opts.signatures).parent / (mod_of(d) + '.json')).exists() else None
                if s: impls.append((mod_of(d), int(vv['target'], 16), s))
        abstract = not v['own']
        ps, ret = draft_sig(impls)
        args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
        kw = 'function' if ret else 'procedure'
        d = '%s %s%s%s;' % (kw, v['name'], args, (': ' + ret) if ret else '')
        lines.append('%s virtual;%s  { +%03X draft }' % (d, ' abstract;' if abstract else '', v['offset']))
        base_decl[(n.lower(), v['name'].lower())] = d + ' virtual;'
    for name, (va, s) in sorted(hse.items(), key=lambda kv: kv[1][0]):
        parts = name.split('.')
        if len(parts) != 3 or parts[0] != UNIT or parts[1] != n or parts[2].lower() in vnames: continue
        ctor = parts[2] == 'Create' and p in ('TObject', 'TPersistent', 'TComponent', 'TEComponent')
        ps, ret = draft_sig([(MOD, va, s)], ctor=ctor)
        args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
        if ctor: kw = 'constructor'; ret = None
        else: kw = 'function' if ret else 'procedure'
        lines.append('%s %s%s%s;  { draft }' % (kw, parts[2], args, (': ' + ret) if ret else ''))
    out.append((n, p, c['size'], c['vmt_va'], lines))
UNIT = opts.unit
for n, p, size, vmt, lines in out:
    if owners[n] != UNIT: continue
    print('  { %s (instance size %d, VMT %s) }' % (n, size, vmt))
    print('  %s = class(%s)' % (n, p))
    print('  public')
    for l in lines: print('    ' + l)
    print('  end;')
    print()
