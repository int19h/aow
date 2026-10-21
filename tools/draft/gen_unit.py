"""Write a draft unit, preserving entry/field/VMT inference from the HSEPack tools.
Usage: gen_unit.py <module.dpl> <signatures.json> <Unit> <out.pas>
Optional --decomp supplies Ghidra field accesses; --vcl-source supplies Delphi source.
For AoWE, implementation fragments follow notes/aowepack-plan.md P1 through P5.
"""
import sys, io, re, os, glob, collections, contextlib, runpy
from pathlib import Path
from types import SimpleNamespace
from config import parser
parser_ = parser(__doc__)
parser_.add_argument('output', type=Path)
parser_.add_argument('--all', action='store_true', help='write all module units beside output')
args = parser_.parse_args()
argv = [str(Path(__file__).with_name('gen_draft.py')), str(args.module), str(args.signatures), args.unit,
        '--classes', str(args.classes), '--source-root', str(args.source_root)]
for flag, value in (('--decomp',args.decomp),('--vcl-source',args.vcl_source),('--rtti',args.rtti)):
    if value: argv += [flag,str(value)]
saved = sys.argv
sys.argv = argv
with contextlib.redirect_stdout(io.StringIO()):
    G = SimpleNamespace(**runpy.run_path(argv[0]))
sys.argv = saved
from entry import analyze, sigs
CRLF = '\r\n'
D = args.decomp
acc = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
for f in glob.glob(str(D / '*.c')) if D else []:
    src = open(f, encoding='latin1').read()
    types = {v: t for t, v in re.findall(r'\b(T\w+) \*(\w+)\b', src)}
    for m in re.finditer(r'(?:\*\((\w+(?: \w+)?) \*\)&)?(?:\(\((T\w+) \*\)(\w+)\)|(\w+))->field_0x([0-9a-f]+)', src):
        cast, ct, cv, v, off = m.groups()
        t = ct or types.get(v)
        if t: acc[t][int(off, 16)][cast or 'byte'] += 1
def width(c):
    if any(k in c for k in ('int', 'undefined4', 'uint', 'pointer')) or any('*' in k for k in c): return 4
    if any(k in c for k in ('short', 'ushort', 'undefined2', 'word')): return 2
    return 1
def size_of(n):
    return G.classes[n]['size'] if n in G.classes else {'TObject': 4, 'TPersistent': 4, 'TComponent': 36}.get(n, 4)
def fields_for(n):
    lo = size_of(G.classes[n]['parent']); hi = G.classes[n]['size']
    # collect accesses from the class and descendants
    offs = {int(off): f['size'] for off,f in G.classes[n].get('fields', {}).items() if lo <= int(off) < hi and f.get('size') in (1,2,4)}
    for t in [n] + G.desc(n):
        for off, c in acc[t].items():
            if lo <= off < hi:
                w = width(c)
                offs[off] = max(offs.get(off, 0), w)
    res = []; pos = lo; short = n[1:]
    for off in sorted(offs):
        w = offs[off]
        if off < pos: continue
        if off % w: w = 1
        if off + w > hi: w = 1
        if off > pos: res.append('F_%s_%02X: array[0..%d] of Byte;' % (short, pos, off - pos - 1))
        field = G.classes[n].get('fields', {}).get(str(off), {})
        if G.MOD.lower().endswith('.exe') and field.get('src') == 'rtti':
            res += ['published', '%s: %s; { +%04X }' % (field['name'], field['type'], off), 'public']
        else:
            res.append('F_%s_%02X: %s;' % (short, off, {1: 'Byte', 2: 'Word', 4: 'Integer'}[w]))
        pos = off + w
    if pos < hi:
        res.append('F_%s_%02X: array[0..%d] of Byte;' % (short, pos, hi - pos - 1))
    if G.MOD.lower().endswith('.exe'):
        text = '\n'.join(res).replace('public\npublished\n', '')
        return text.splitlines()
    return res

def impl_header(cls, decl):
    d = re.sub(r'\s*\{[^}]*\}\s*$', '', decl).strip()
    d = re.sub(r'\s*(virtual|override|dynamic|abstract|reintroduce)\s*;', '', d).strip()
    m = re.match(r'((?:class )?(?:procedure|function|constructor|destructor)) (\w+)(.*)$', d)
    return '%s %s.%s%s' % (m.group(1), cls, m.group(2), m.group(3))

def capture(tool, unit):
    saved = sys.argv
    sys.argv = [tool, str(args.module), unit]
    buf = io.StringIO()
    with contextlib.redirect_stdout(buf):
        runpy.run_path(str(Path(__file__).with_name(tool)), init_globals={'_pe':G.pe})
    sys.argv = saved
    return buf.getvalue().splitlines()

def stub(decl):
    if not re.match(r'(?:class )?function ', decl): return 'begin end;'
    ret = re.search(r':\s*([\w.]+)\s*;\s*$', decl)
    typ = next((x for x in ret.groups() if x), 'Integer') if ret else 'Integer'
    if typ.lower() in ('string','ansistring','widestring','shortstring'): value = "''"
    elif typ.lower() in ('boolean','bool','longbool','wordbool','bytebool'): value = 'False'
    elif typ.lower() in ('integer','cardinal','longint','longword','byte','word','smallint','shortint','single','double','extended','currency','int64'): value = '0'
    elif typ.lower() == 'pointer' or typ.startswith('P') or typ in G.classes: value = 'nil'
    else: return 'begin FillChar(Result, SizeOf(Result), 0); end;'
    return 'begin Result := %s; end;' % value

first_address = {}
for name,(va,_) in G.hse.items():
    parts = name.split('.')
    if len(parts)==3:
        first_address[parts[1]] = min(first_address.get(parts[1],va),va)
aowe_order = sorted((first_address[cn],cn) for cn in G.own_unit_classes if G.owners[cn]=='AoWE' and cn in first_address)
aowe_seq = [cn for va,cn in aowe_order]
def owner_part(n):
    if G.MOD.lower() != 'aowepack.dpl' or G.owners[n] != 'AoWE': return 'P1'
    if n in ('TUnitResourceAbilityOwner','THeroResourceAbilityOwner'): return 'P2'
    if n in ('TRebuildConstructionControl','TBuildRoadsControl'): return 'P4'
    seq = aowe_seq
    if n not in seq: return 'P1'
    for part,first,last in [('P1','TAoWHSSet','TFrozenWaterHS'),('P1','TTutorialControl','TAoWHSMap'),
                            ('P2','TUnitControl','TAgeOfWondersEngine'),('P3','TCombatUnit','TCombatPredictor'),
                            ('P4','TAdjustableAbility','TAbilityPlugIn'),('P4','TSpellCC','TChangeGlobalMagicTE'),
                            ('P5','TJoinEventLog','TPadControl')]:
        if seq.index(first) <= seq.index(n) <= seq.index(last): return part
    raise ValueError('No work package for '+n)

def write(path, lines):
    path.parent.mkdir(parents=True,exist_ok=True)
    with open(path,'w',newline='',encoding='latin1') as f: f.write(CRLF.join(lines)+CRLF)

def generate(unit, output):
    own = [row for row in G.out if G.owners[row[0]] == unit]
    if G.MOD.lower() == 'localize.dpl':
        wanted = {'IvDictio': {'TIvDictionary','TIvCustomTranslator'}, 'IvAMulti': {'TIvCustomFileDictionary'},
                  'IvBinDic': {'TIvBinaryDictionary'}, 'IvMulti': {'TIvCustomTranslator','TIvTranslator'}}
        own = [row for row in own if row[0] in wanted.get(unit,set())]
        needed = {'Create','Destroy','DefineProperties','CanBeOpened','LanguageChanged',
                  'TranslateContextString','TranslateString','GetLanguageCount','GetLanguageData',
                  'GetLanguageDatas','GetLocaleCount','GetLocaleData','GetLocaleDatas','GetTranslationCount',
                  'LoadTranslation','ReadLanguages','ReadLocales','ReadTranslations','Close','GetPrimaryLanguages',
                  'GetTranslationMode','IsLocaleSupported','Open','SetDictionaryName','SetLanguage',
                  'SynchronizeLanguage','SynchronizeLocale','Translate','TranslateStrings'}
        filtered = []
        for n,p,size,vmt,lines in own:
            kept = []
            for l in lines:
                name = re.search(r'(?:procedure|function|constructor|destructor) (\w+)',l).group(1)
                if name in needed and n not in ('TIvTranslator','TIvCustomTranslator'): kept.append(l)
                elif 'virtual;' in l:
                    slot = next(v['offset'] for v in G.classes[n]['vmt'] if v['name']==name)
                    kept.append('procedure Reserved_%03X; virtual; abstract; { unused slot }' % slot)
            filtered.append((n,p,size,vmt,kept))
        own = filtered
    imports = set()
    # Recovered types in base declarations are available through these units.
    uses = ['Windows','Messages','SysUtils','Classes','Graphics','Controls','Forms','Dialogs','Menus',
            'StdCtrls','ExtCtrls','ComCtrls','Grids','Registry','Engine','PlugInM',
            'GFXE','ImageLib','DisplayC','Sound','NetworkE','aowFX','HSEngine','IsoHex','ILTer',
            'Terrain','Hexagon','Road','BorderHx','IvDictio','IvAMulti','IvBinDic','IvMulti']
    if G.MOD.lower() == 'localize.dpl':
        uses = ['Windows','Messages','SysUtils','Classes','Graphics','Controls','Forms']
    for n,p,*_ in own:
        owner = G.owners.get(p) or G.type_unit.get(p.lower())
        if owner and owner != unit: imports.add(owner)
    if G.MOD.lower().endswith('.exe'):
        for n, *_ in own:
            for field in G.classes[n]['fields'].values():
                if field.get('src') == 'rtti':
                    owner = G.owners.get(field['type']) or G.type_unit.get(field['type'].lower())
                    if owner and owner != unit: imports.add(owner)
    for row in own:
        for decl in row[-1]:
            imports.update(re.findall(r'\b(\w+)\.\w+', decl))
    imports.discard(unit)
    uses = [u for u in uses if u != unit]
    uses += sorted(imports-set(uses))
    types = [l for l in capture('typeinfo.py',unit) if ' = ' in l]
    if G.MOD.lower() == 'localize.dpl': types = []
    # RTTI is in declaration order. Class forwards precede callbacks that use them.
    declarations = []
    if G.MOD.lower().endswith('.exe'):
        # Unrecovered third-party components need their type and size for published fields.
        missing = {f['type'] for n, *_ in own for f in G.classes[n]['fields'].values()
                   if f.get('src') == 'rtti' and f['type'] not in G.owners
                   and f['type'].lower() not in G.type_unit}
        for typ in sorted(missing):
            layout = G.classes[typ]
            parent = layout['parent']
            while parent in G.classes and parent.lower() not in G.type_unit:
                parent = G.classes[parent]['parent']
            parent = parent or 'TComponent'
            padding = layout['size'] - size_of(parent)
            declarations += ['  { Declaration-only field type from %s (instance size %d). }' %
                             (layout['module'], layout['size']), '  %s = class(%s)' % (typ, parent)]
            if padding: declarations += ['  private', '    F_External: array[0..%d] of Byte;' % (padding - 1)]
            declarations += ['  end;', '']
    implementations = collections.defaultdict(list)
    for n in [r[0] for r in own]: declarations.append('  %s = class;' % n)
    declarations += [''] + ['  '+t for t in types] + ['']
    for n,p,size,vmt,lines in own:
        declarations += ['  { %s (instance size %d, VMT %s) }' % (n,size,vmt),
                         '  %s = class(%s)' % (n,p), '  public']
        declarations += ['    '+f for f in fields_for(n)]
        for l in lines:
            declarations.append('    '+l)
        declarations += ['  end;','']
    # Bodies follow first original method address, with methods in address order.
    for n,p,size,vmt,lines in sorted(own,key=lambda r:min((a for k,(a,s) in G.hse.items() if k.startswith(unit+'.'+r[0]+'.')), default=0)):
        for l in sorted(lines,key=lambda l:G.hse.get(unit+'.'+n+'.'+re.search(r'(?:procedure|function|constructor|destructor) (\w+)',l).group(1),(0,None))[0]):
            if 'abstract;' in l: continue
            d = impl_header(n,l)
            implementations[owner_part(n)].extend([d,stub(d),''])
    W = {1: 'Byte', 2: 'Word', 4: 'Integer'}
    for va, s in sorted(sigs(G.MOD).items()):
        nm = s['name'].split('@')[0]
        if not nm.startswith(unit + '.') or nm.count('.') != 1: continue
        r = nm.split('.')[1]
        if not r or r in ('Finalization', unit) or r in G.classes or G.MOD.lower() == 'localize.dpl': continue
        used, rn = analyze(G.MOD, va, s['size'])
        ps = []
        regs = [x for x in ('eax', 'edx', 'ecx') if x in used]
        nreg = {'eax': 1, 'edx': 2, 'ecx': 3}[regs[-1]] if regs else 0
        if rn: nreg = 3
        for x in ('eax', 'edx', 'ecx')[:nreg]: ps.append(W[used.get(x, 4)])
        ps += ['Integer'] * ((rn or 0) // 4)
        ret = G.ret_of(s)
        args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
        d = '%s %s%s%s;' % ('function' if ret else 'procedure', r, args, (': ' + ret) if ret else '')
        declarations.append(d + '  { draft }')
        implementations['P1'].extend([d, stub(d), ''])

    resources = []
    for l in capture('resstr.py',unit):
        m = re.match(r'\w+ \w+\.(\w+) = (.*); \{ id (\d+) \}',l)
        if not m: continue
        import ast
        val = ast.literal_eval(m.group(2))
        if val is None: continue
        text = "'" + val.replace("'", "''").replace('\r', "'#13'").replace('\n', "'#10'") + "'"
        resources.append('  %s = %s;' % (m.group(1),text))
    src = ['unit %s;' % unit,'','{ Draft declarations of %s, from %s.' % (unit,G.MOD),
           '  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.',
           '  Stub bodies are placeholders for source recovery. }','','interface','',
           'uses','  '+', '.join(uses)+';',''] + (['type'] if own or types else []) + declarations
    if resources: src += ['','resourcestring']+resources
    src += ['','implementation','']
    if G.MOD.lower() == 'aowepack.dpl' and unit == 'AoWE':
        for part in ('P1','P2','P3','P4','P5'):
            write(output.parent/'inc'/(part+'.inc'), implementations[part])
            src.append('{$I inc\\%s.inc}' % part)
    else:
        src += implementations['P1']
    if any(x['name'].split('@')[0] == unit+'.'+unit for x in sigs(G.MOD).values()):
        src += ['', 'initialization']
    if any(x['name'].split('@')[0] == unit+'.Finalization' for x in sigs(G.MOD).values()):
        src += ['finalization']
    src += ['','end.']
    write(output,src)

if args.all:
    units = sorted(set(G.owners.values()) if G.MOD.lower().endswith('.exe') else {s['name'].split('.')[0] for s in sigs(G.MOD).values() if '.' in s['name']})
    if G.MOD.lower() == 'localize.dpl': units = ['IvDictio','IvAMulti','IvBinDic','IvMulti']
    for unit in units: generate(unit,args.output.parent/(unit+'.pas'))
    print('written %d units' % len(units))
else:
    generate(args.unit,args.output)
    print('written', args.output)
