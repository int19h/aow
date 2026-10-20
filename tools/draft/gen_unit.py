CRLF = chr(13) + chr(10)
"""Write the draft HSEngine.pas: types, resourcestrings, classes (draft fields and methods), unit
routines, stub implementations. Usage: gen_unit.py <out.pas>"""
import sys, io, re, os, glob, collections, contextlib
sys.path.insert(0, 'C:/Users/int19h/AppData/Local/Temp/hse_tools')
sys.argv = ['gen_draft.py', 'HSEngine']
buf = io.StringIO()
with contextlib.redirect_stdout(buf):
    import gen_draft as G
from entry import analyze, sigs
out_path = sys.argv[1] if len(sys.argv) > 1 else None
OUT = 'C:/git/int19h/aow/src/delphi3/HSEPack/HSEngine.pas'

# ---- field scan
D = 'C:/git/int19h/aow/notes/decomp/HSEPack-typed-all'
acc = collections.defaultdict(lambda: collections.defaultdict(collections.Counter))
for f in glob.glob(D + '/*.c'):
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
    offs = {}
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
        res.append('F_%s_%02X: %s;' % (short, off, {1: 'Byte', 2: 'Word', 4: 'Integer'}[w]))
        pos = off + w
    if pos < hi:
        res.append('F_%s_%02X: array[0..%d] of Byte;' % (short, pos, hi - pos - 1))
    return res

TYPES_A = '''  PInteger = ^Integer;

  TWalkAroundRouteCallBack = function(X: Integer; Y: Integer; var Cancel: Boolean): Boolean of object;
'''
RES = '''resourcestring
  TerrainStr = 'Terrain';
  BridgeStr = 'Bridge';
  UpperIsometricHexagonStr = 'Upper Isometric Hexagon';
  LowerIsometricHexagonStr = 'Lower Isometric Hexagon';
  InvalidPlaceMentStr = 'Invalid Placement';
  HexagonStr = 'Hexagon';
  SelectedStr = 'selected';
  TransparentStr = 'Transparent';
  LoadingStr = 'Loading';
  ClosingStr = 'Closing';
  SaveChangesToXStr = 'Save changes to %s';
  OneMomentPleaseStr = 'One moment please...';
  CutStr = 'Cu&t';
  PasteStr = '&Paste';
  DeleteStr = '&Delete';
  CopyStr = '&Copy';
  EditStr = '&Edit';
'''
# types that go right before a class (declaration order of the type infos)
BEFORE = {
 'TTerrainList': ['TTerrainCompareMode = set of (cmSameOverlayType, cmSameTerrainType);'],
 'TMapField': ['TMapFieldStatus = set of (msTerrainLocked, msVisible, msLoading, msComparing);'],
 'THSMapMouse': ['TMouseStatus = set of (msChangingCapture);'],
 'THSMap': ['TCenterViewEvent = procedure(Xhx: Integer; Yhx: Integer; Lhx: Integer) of object;',
            'TChangeViewEvent = procedure(Xhp: Integer; Yhp: Integer; Lhp: Integer) of object;',
            'TViewLevelEvent = procedure(Lhx: Integer) of object;',
            'THSMapStatus = set of (msModified, msEditting, msActivated, msDestroying, msPreviewMode);',
            'TMapProgressType = (ptLoading, ptSaving, ptInitializing, ptUpdatingTerrain, ptActivating, ptDestroying);',
            'TChangeTerrainProc = procedure(MapF: TMapField; var TerrainType: Shortint; var OverlayType: Shortint) of object;',
            'TTerrainChangedProc = procedure(MapF: TMapField; OriginalTerrainType: Shortint; OriginalOverlayType: Shortint) of object;'],
 'THSSet': ['THSSetStatus = set of (ssModified, ssEditting, ssActivated, ssDestroying);'],
 'THSEngine': ['THSEngineStatus = set of (esLoadingHSMSettings, esLoadingHSM, esSavingHSM, esLoadingHSS, esSavingHSS);'],
 'THexagonSprite': ['TControlMode = set of (cmMultiSelect, cmShowSelectionSelf);'],
 'TCustomFixedVisibleHS': ['TOnShowHSEvent = procedure(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc) of object;'],
 'TLibraryImageHS': ['TLibraryImageHSStatus = set of (lsVisible, lsEditMode, lsDestroyOnShow, lsMapIsOwner, lsPlacedOnMap);'],
 'TMapObject': ['TMapObjectStatus = set of (moVisible, moResourceLinked, moEditMode, moPlacedOnMap, moSelected, moActivated);'],
}

def impl_header(cls, decl):
    d = re.sub(r'\s*\{[^}]*\}\s*$', '', decl).strip()
    d = re.sub(r'\s*(virtual|override|dynamic|abstract|reintroduce)\s*;', '', d).strip()
    m = re.match(r'((?:class )?(?:procedure|function|constructor|destructor)) (\w+)(.*)$', d)
    return '%s %s.%s%s' % (m.group(1), cls, m.group(2), m.group(3))
INTF = {  # class -> interface include
 'TNewHSMapSettings': 'intf_A1', 'TTerrainList': 'intf_A1',
 'TMapField': 'intf_C', 'TMapLevel': 'intf_C', 'TMapContainer': 'intf_C', 'TVisibilityList': 'intf_C',
 'THexagonSpriteSelection': 'intf_D', 'THSMapMouse': 'intf_D', 'THSMap': 'intf_D', 'THSMapViewer': 'intf_D',
 'TMORTerrainControl': 'intf_E', 'THexagonControl': 'intf_E', 'TRoadControl': 'intf_E', 'THSSet': 'intf_E',
 'THSEngine': 'intf_E', 'THexagonSpriteEngine': 'intf_E',
 'THexagonSprite': 'intf_B', 'TSingleHS': 'intf_B', 'TFixedVisibleHS': 'intf_B', 'TCustomFixedVisibleHS': 'intf_B',
 'TLibraryImageHS': 'intf_B', 'THPBasedHS': 'intf_B',
 'TXYLList': 'intf_A2'}
IMPL = {
 'TTerrainList': 'impl_A1', 'TXYLList': 'impl_A1',
 'THexagonSprite': 'HXSPRITE.PAS', 'THPBasedHS': 'HXSPRITE.PAS', 'TSingleHS': 'HXSPRITE.PAS',
 'TFixedVisibleHS': 'HXSPRITE.PAS', 'TCustomFixedVisibleHS': 'HXSPRITE.PAS',
 'TMapField': 'impl_C1', 'TNewHSMapSettings': 'impl_A2', 'TMapLevel': 'impl_C2', 'TMapContainer': 'impl_C2',
 'THSSet': 'impl_E1', 'THSMapMouse': 'impl_D1', 'THexagonSpriteSelection': 'impl_D1', 'TVisibilityList': 'impl_C3',
 'THSMap': 'HSMAP.PAS', 'TLibraryImageHS': 'LibImgHS.PAS', 'TMORTerrainControl': 'impl_E2',
 'THexagonControl': 'impl_E2', 'TRoadControl': 'impl_E2',
 'THSMapViewer': 'impl_D2', 'THSEngine': 'impl_E3', 'THexagonSpriteEngine': 'impl_E3'}
IMPL_ORDER = ['impl_A1', 'HXSPRITE.PAS', 'impl_C1', 'impl_A2', 'impl_C2', 'impl_E1', 'MAPOBJ.PAS', 'impl_D1',
              'impl_C3', 'HSMAP.PAS', 'LibImgHS.PAS', 'impl_A3', 'impl_E2', 'impl_D2', 'impl_E3', 'impl_A4']
INTF_ORDER = ['intf_A1', 'intf_C', 'intf_D', 'intf_E', 'intf_B', 'intf_F', 'intf_A2']
files = collections.defaultdict(list)
for n, *_ in G.out:
    if n not in INTF: INTF[n] = 'intf_F'
    if n not in IMPL: IMPL[n] = 'MAPOBJ.PAS'
for n, p, size, vmt, lines in G.out:
    for t in BEFORE.get(n, []): files[INTF[n]].append('  ' + t)
    if BEFORE.get(n): files[INTF[n]].append('')
    files[INTF[n]].append('  { %s (instance size %d): draft }' % (n, size))
    files[INTF[n]].append('  %s = class(%s)' % (n, p))
    fs = fields_for(n)
    if fs:
        files[INTF[n]].append('  public')
        for f in fs: files[INTF[n]].append('    ' + f)
    files[INTF[n]].append('  public')
    for l in lines:
        files[INTF[n]].append('    ' + l)
        if 'abstract;' in l: continue
        files[IMPL[n]].append(impl_header(n, l))
        files[IMPL[n]].append('begin')
        files[IMPL[n]].append('end;')
        files[IMPL[n]].append('')
    files[INTF[n]].append('  end;')
    files[INTF[n]].append('')
# unit routines
routines = []
W = {1: 'Byte', 2: 'Word', 4: 'Integer'}
for va, s in sorted(sigs('HSEPack.dpl').items()):
    nm = s['name'].split('@')[0]
    if not nm.startswith('HSEngine.') or nm.count('.') != 1: continue
    r = nm.split('.')[1]
    if r in ('Register', 'Finalization', 'HSEngine'): continue
    used, rn = analyze('HSEPack.dpl', va, s['size'])
    ps = []
    regs = [x for x in ('eax', 'edx', 'ecx') if x in used]
    nreg = {'eax': 1, 'edx': 2, 'ecx': 3}[regs[-1]] if regs else 0
    if rn: nreg = 3
    for x in ('eax', 'edx', 'ecx')[:nreg]: ps.append(W[used.get(x, 4)])
    ps += ['Integer'] * ((rn or 0) // 4)
    ret = G.ret_of(s)
    args = '(%s)' % '; '.join('A%d: %s' % (j + 1, t) for j, t in enumerate(ps)) if ps else ''
    d = '%s %s%s%s;' % ('function' if ret else 'procedure', r, args, (': ' + ret) if ret else '')
    files['intf_A3'].append(d + '  { draft }')
    files['impl_A3'].append(re.sub(r'\s*\{.*$', '', d)); files['impl_A3'].append('begin'); files['impl_A3'].append('end;'); files['impl_A3'].append('')

files['intf_A3'] += ['', 'const', '  HSMID: Integer = 0;  { draft }', '', 'var', '  HSEngineDID: Integer;  { draft }', '', 'procedure Register;']
files['impl_A4'] += ['procedure Register;', 'begin', 'end;', '']
os.makedirs(os.path.dirname(OUT) + '/inc', exist_ok=True)
for k, v in files.items():
    fn = k if k.endswith('.PAS') else k + '.inc'
    open(os.path.dirname(OUT) + '/inc/' + fn, 'w', newline='').write(CRLF.join(v) + CRLF)
src = ['unit HSEngine;', '',
 '{ DRAFT generated from the VMTs, the entry registers and the decompiled field accesses: field',
 '  names F_<Class>_<offset> and parameter lists marked "draft" are placeholders for the owner of',
 '  each class to replace. During the work every group of classes lives in its own include files',
 '  (inc/intf_*.inc for declarations, inc/impl_*.inc and the original include files HXSPRITE.PAS,',
 '  MAPOBJ.PAS, HSMAP.PAS, LibImgHS.PAS for the code); the final unit inlines the inc files. }', '',
 'interface', '', 'uses',
 '  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls,',
 '  ExtCtrls, Engine, GFXE, ImageLib, DisplayC, Sound;', '', 'type', TYPES_A.rstrip(chr(10)), '', RES.rstrip(chr(10)), '', 'type']
for n, *_ in G.out: src.append('  %s = class;' % n)
src.append('')
for k in INTF_ORDER:
    src.append('{$I inc' + chr(92) + '%s.inc}' % k)
src.append('')
src.append('{$I inc' + chr(92) + 'intf_A3.inc}')
src += ['', 'implementation', '']
for k in IMPL_ORDER:
    fn = k if k.endswith('.PAS') else k + '.inc'
    src.append('{$I inc' + chr(92) + '%s}' % fn)
src += ['', 'end.']
open(OUT, 'w', newline='').write(CRLF.join(src) + CRLF)
print('written')
