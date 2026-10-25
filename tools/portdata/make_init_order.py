"""Build initialization-order.json from the ORIGINAL Age of Wonders modules.

Usage: python make_init_order.py [output.json]

Reads only: the game directory (read only), tools/buildgame.py (imported for
package_info / initialization_table / export_names), data/signatures/*.json and the
Delphi 3 RTL/VCL sources under C:\\Tools\\Delphi3\\SOURCE (external declarations and
uses clauses, used to name weak-packaged units linked into each client).
"""
import json
import re
import struct
import sys
from collections import defaultdict
from pathlib import Path

REPO = Path(r'C:\git\int19h\aow')
sys.path.insert(0, str(REPO / 'tools'))
sys.path.insert(0, r'C:\Tools\pylib')
import buildgame as bg  # noqa: E402
import pefile  # noqa: E402

GAME = bg.GAME
SIGS = REPO / 'data' / 'signatures'
D3SRC = Path(r'C:\Tools\Delphi3\SOURCE')
ROOTS = ['AoW.exe', 'AoWEd.exe']
STUB_LEN = 0x38  # inc-guarded finalization (0x30) + 'sub [cnt],1; ret' (8)


# ---------------------------------------------------------------- game files
def game_files():
    return {p.name.lower(): p for p in GAME.iterdir() if p.is_file()}


FILES = game_files()


def game_path(name):
    return FILES[name.lower()]


def canonical(name):
    return game_path(name).name


# ---------------------------------------------------------------- Delphi 3 sources
def strip_comments(text):
    text = re.sub(r'\{[^}]*\}', ' ', text)
    text = re.sub(r'\(\*.*?\*\)', ' ', text, flags=re.S)
    text = re.sub(r'//[^\n]*', ' ', text)
    return text


HEADER = re.compile(
    r'\b(?:function|procedure)\s+(\w+)\s*(?:\([^)]*\))?\s*(?::\s*[\w.]+)?\s*;\s*'
    r'(?:(?:stdcall|cdecl|pascal|register|safecall)\s*;\s*)*external\b([^;]*);', re.I | re.S)


def d3_sources():
    externals = defaultdict(set)   # import name -> {unit}
    uses = {}                      # unit lower -> [used unit names]
    names = {}
    for path in D3SRC.rglob('*'):
        if path.suffix.lower() != '.pas':
            continue
        text = strip_comments(path.read_text('latin1'))
        m = re.search(r'^\s*unit\s+(\w+)\s*;', text, re.I | re.M)
        if not m:
            continue
        unit = m[1]
        names[unit.lower()] = unit
        found = []
        for part in re.finditer(r'\b(?:interface|implementation)\b\s*uses\b([^;]*);', text, re.I):
            found += [u.strip().split()[0] for u in part[1].split(',') if u.strip()]
        uses[unit.lower()] = found
        for h in HEADER.finditer(text):
            alias = re.search(r"name\s+'([^']+)'", h[2], re.I)
            externals[alias[1] if alias else h[1]].add(unit)
    return externals, uses, names


EXTERNALS, USES, SRCNAMES = d3_sources()


# ---------------------------------------------------------------- per-module analysis
def required_closure():
    order, owner, queue = [], defaultdict(set), [(r, r) for r in ROOTS]
    while queue:
        name, root = queue.pop(0)
        name = canonical(name)
        owner[name].add(root)
        if name in order:
            continue
        order.append(name)
        deps = []
        with pefile.PE(str(game_path(name)), fast_load=True) as pe:
            pe.parse_data_directories(directories=[1])
            deps += [d.dll.decode('ascii') for d in pe.DIRECTORY_ENTRY_IMPORT
                     if d.dll.lower().endswith(b'.dpl')]
        deps += [r + '.dpl' for r in bg.package_info(game_path(name))[1]]
        queue += [(d, root) for d in deps]
    # propagate root ownership to transitive dependencies
    changed = True
    while changed:
        changed = False
        for name in order:
            with pefile.PE(str(game_path(name)), fast_load=True) as pe:
                pe.parse_data_directories(directories=[1])
                deps = [canonical(d.dll.decode('ascii')) for d in pe.DIRECTORY_ENTRY_IMPORT
                        if d.dll.lower().endswith(b'.dpl')]
            for d in deps:
                if not owner[name] <= owner[d]:
                    owner[d] |= owner[name]
                    changed = True
    return order, owner


class Image:
    def __init__(self, path):
        self.pe = pefile.PE(str(path), fast_load=True)
        self.pe.parse_data_directories(directories=[1])
        self.base = self.pe.OPTIONAL_HEADER.ImageBase
        code = self.pe.sections[0]
        self.c0, self.code = code.VirtualAddress, code.get_data()
        self.imports = {i.address: (d.dll.decode('ascii'),
                                    i.name.decode('latin1') if i.name else '#%d' % i.ordinal)
                        for d in getattr(self.pe, 'DIRECTORY_ENTRY_IMPORT', []) for i in d.imports}
        self.thunks = []   # (rva, dll, name)
        for m in re.finditer(rb'\xff\x25(....)\x8b\xc0', self.code, re.S):
            slot, = struct.unpack('<I', m[1])
            if slot in self.imports:
                self.thunks.append((self.c0 + m.start(),) + self.imports[slot])
        self.classes = self.scan_vmts()

    def u32(self, rva):
        return struct.unpack_from('<I', self.code, rva - self.c0)[0]

    def sstr(self, rva):
        n = self.code[rva - self.c0]
        return self.code[rva - self.c0 + 1:rva - self.c0 + 1 + n].decode('latin1')

    def in_code(self, va):
        return self.base + self.c0 <= va < self.base + self.c0 + len(self.code)

    def scan_vmts(self):
        """Delphi 3 VMT: vmtSelfPtr at -64, vmtTypeInfo at -48, vmtClassName at -32."""
        out = []
        for p in range(0, len(self.code) - 64, 4):
            if struct.unpack_from('<I', self.code, p)[0] != self.base + self.c0 + p + 64:
                continue
            rva = self.c0 + p
            try:
                cname = self.sstr(self.u32(rva + 32) - self.base)
            except (IndexError, struct.error, UnicodeDecodeError):
                continue
            unit, ti = None, self.u32(rva + 16)
            if ti and self.in_code(ti) and self.code[ti - self.base - self.c0] == 7:  # tkClass
                r = ti - self.base
                tname = self.sstr(r + 1)
                unit = self.sstr(r + 2 + len(tname) + 10)  # ClassType, ParentInfo, PropCount
            out.append((rva, cname, unit))
        return out


def signatures(name):
    path = SIGS / (name + '.json')
    if not path.is_file():
        for p in SIGS.iterdir():
            if p.name.lower() == (name + '.json').lower():
                path = p
    if not path.is_file():
        return []
    return [(int(f['addr'], 16), f['name']) for f in json.loads(path.read_text())]


def unit_of_symbol(symbol):
    return symbol.split('!')[-1].split('.')[0]


def analyse(name, weak_units):
    path = game_path(name)
    flags, requires, units = bg.package_info(path)
    table = bg.initialization_table(path)
    img = Image(path)
    contained = {u.lower(): u for u, f in units}
    base = img.base
    sigs = signatures(name)
    entries = []
    for rec in table:
        e = {'position': rec['index'], 'init_rva': rec['init_rva'], 'final_rva': rec['final_rva'],
             'unit': None, 'via_package': None, 'init_symbol': rec['init_symbol']}
        sym = rec['init_symbol']
        if sym and '!' in sym:
            e['unit'] = unit_of_symbol(sym)
            e['via_package'] = canonical(sym.split('!')[0])
            e['method'] = 'import-thunk'
        elif sym:
            e['unit'] = unit_of_symbol(sym)
            e['method'] = 'export-name'
        entries.append(e)

    # local regions: own (non-thunk) entries in address order
    local = [e for e in entries if e['via_package'] is None]
    def start(e):
        vals = [int(v, 16) for v in (e['init_rva'], e['final_rva']) if v]
        return min(vals)
    local.sort(key=start)
    prev = img.c0
    for e in local:
        end = start(e)
        e['_region'] = (prev, end)
        prev = max(int(v, 16) for v in (e['init_rva'], e['final_rva']) if v) + 8
    taken = {e['unit'].lower() for e in entries if e['unit'] and e['via_package'] is None}
    unresolved = [e for e in local if not e['unit']]

    def assign(e, unit, method, evidence):
        e['unit'], e['method'], e['evidence'] = unit, method, evidence
        taken.add(unit.lower())

    # program / package main unit: table entry with no init (exe) is the program block
    main = [u for u, f in units if f & 1]
    for e in unresolved:
        if e['init_rva'] is None and e['position'] == len(entries) - 1 and main:
            assign(e, main[0], 'program-block', 'last table entry has finalization only; '
                   'PACKAGEINFO unit with flag 1 (main unit)')

    # RTTI: tkClass TypeData.UnitName of classes whose VMT lies in the region
    for e in [x for x in unresolved if not x['unit']]:
        lo, hi = e['_region']
        found = sorted({u for a, c, u in img.classes if lo <= a < hi and u})
        own = [u for u in found if u.lower() in contained and u.lower() not in taken]
        if len(own) == 1:
            assign(e, contained[own[0].lower()], 'rtti-unitname',
                   'class RTTI in region names unit: ' + ', '.join(found))

    # externals: import thunks of DLL routines declared in a Delphi 3 source unit
    for e in [x for x in unresolved if not x['unit']]:
        lo, hi = e['_region']
        region = [t for t in img.thunks if lo <= t[0] < hi]
        last_dpl = max([i for i, t in enumerate(region) if t[1].lower().endswith('.dpl')], default=-1)
        ext = [t for t in region[last_dpl + 1:] if not t[1].lower().endswith('.dpl')]
        e['_externals'] = ext
        if not ext:
            continue
        votes = defaultdict(int)
        for t in ext:
            for u in EXTERNALS.get(t[2], ()):
                votes[u] += 1
        cands = [u for u, n in votes.items() if n == len(ext)
                 and (u.lower() in weak_units or u.lower() in contained) and u.lower() not in taken]
        if len(cands) > 1:  # e.g. SysInit vs Windows both declare GetModuleFileNameA
            size = {u: sum(1 for us in EXTERNALS.values() if u in us) for u in cands}
            best = min(size.values())
            cands = [u for u in cands if size[u] == best]
        if len(cands) == 1:
            u = cands[0]
            assign(e, contained.get(u.lower(), weak_units.get(u.lower(), u)), 'externals',
                   '%d DLL import thunk(s) in region (e.g. %s) all declared external in Delphi 3 '
                   'source unit %s' % (len(ext), ', '.join(t[1] + '!' + t[2] for t in ext[:3]), u))

    # VMT class names (no RTTI) or signature class prefixes matching 'T' + contained unit name
    for e in [x for x in unresolved if not x['unit']]:
        lo, hi = e['_region']
        classes = {c for a, c, u in img.classes if lo <= a < hi}
        classes |= {n.split('.')[0] for a, n in sigs if lo <= a - base < hi and '.' in n}
        hits = sorted({u for u in contained if u not in taken and
                       any(c.lower() in (u, 't' + u) for c in classes)})
        if len(hits) == 1:
            assign(e, contained[hits[0]], 'class-name',
                   'classes in region without RTTI unit name: ' + ', '.join(sorted(classes)[:6]))

    # resourcestring-only unit: PResStringRec table (same module pointer, 16-bit ids) in region
    for e in [x for x in unresolved if not x['unit']]:
        lo, hi = e['_region']
        recs = resstring_records(img, lo, hi)
        left = [u for u in contained if u not in taken and u not in weak_units and u.endswith('str')]
        if recs >= 4 and len(left) == 1:
            assign(e, contained[left[0]], 'resourcestring-records',
                   '%d PResStringRec records in region; the only unassigned contained unit named '
                   '*Str (heuristic)' % recs)

    # dependency-order simulation over Delphi 3 / recovered uses clauses
    deps_report = dfs_fill(name, entries, unresolved, taken, assign)

    # elimination among this module's own contained units
    left_units = [u for u in contained if u not in taken and u not in weak_units]
    left = [e for e in unresolved if not e['unit']]
    if len(left_units) == 1 and len(left) == 1:
        assign(left[0], contained[left_units[0]], 'elimination',
               'only contained PACKAGEINFO unit without an entry, only unresolved entry')

    replay_left = [u for u in deps_report.pop('_replay_unnamed') if u not in taken]
    for e in unresolved:
        if not e['unit']:
            e['method'] = None
            e['reason'] = describe_gap(e, img, contained, taken, weak_units)
            # names known from the original PACKAGEINFOs only: this module's unassigned contained
            # units plus weak-packaged units the uses-clause replay reaches but the table lacks
            e['candidates'] = sorted({contained[u] for u in contained if u not in taken and u not in weak_units}
                                     | {weak_units[u] for u in replay_left if u in weak_units},
                                     key=str.lower)
        if '_externals' in e:
            e['region_dll_imports'] = sorted({t[1] + '!' + t[2] for t in e['_externals']})[:8] or None
    for e in entries:
        lo_hi = e.pop('_region', None)
        e.pop('_externals', None)
        if lo_hi:
            e['region_rva'] = [hex(lo_hi[0]), hex(lo_hi[1])]
        if e['unit']:
            u = e['unit'].lower()
            e['kind'] = ('import' if e['via_package'] else
                         'contained' if u in contained else
                         'weak-packaged' if u in weak_units else 'other')
        else:
            e['kind'] = None
        if e.get('region_dll_imports') is None:
            e.pop('region_dll_imports', None)
    return {
        'module': name,
        'loaded_by': None,
        'packageinfo': {'flags': '0x%08x' % flags, 'requires': requires,
                        'contains': [{'unit': u, 'flags': f} for u, f in units]},
        'entry_count': len(entries),
        'dependency_check': deps_report,
        'entries': entries,
    }



def source_index():
    index = defaultdict(list)
    for root in (D3SRC, bg.SOURCE):
        for path in root.rglob('*'):
            if path.suffix.lower() == '.pas' and not {'obj', 'aliases', 'hosts'} & {p.lower() for p in path.parts}:
                index[path.stem.lower()].append(path)
    return index


SOURCES = source_index()
VCL_PACKAGES = {'vcl30.dpl', 'vclx30.dpl', 'vcldb30.dpl'}
_uses_cache = {}


def module_dir(name):
    stem = name.rsplit('.', 1)[0]
    for p in bg.PACKAGES + bg.PROGRAMS:
        if p.lower() == stem.lower():
            return bg.source_dir(p, bg.SOURCE)
    for p in bg.IMPORTS:
        if p.lower() == stem.lower():
            return bg.SOURCE / 'imports' / p
    return D3SRC if name.lower() in VCL_PACKAGES else None


def unit_uses(module, unit):
    key = (module.lower(), unit)
    if key in _uses_cache:
        return _uses_cache[key]
    paths = SOURCES.get(unit, [])
    home = module_dir(module)
    pick = None
    for prefer in ([home] if home else []) + [bg.SOURCE / 'imports', D3SRC, bg.SOURCE]:
        hits = [p for p in paths if str(p).lower().startswith(str(prefer).lower())]
        if hits:
            pick = hits[0]
            break
    result = None
    if pick:
        text = strip_comments(pick.read_text('latin1'))
        result = []
        for part in re.finditer(r'\b(?:interface|implementation)\b\s*uses\b([^;]*);', text, re.I):
            result += [u.strip().split()[0].lower() for u in part[1].split(',') if u.strip()]
    _uses_cache[key] = (result, str(pick) if pick else None)
    return _uses_cache[key]


def dfs_fill(name, entries, unresolved, taken, assign):
    """Delphi initializes a unit after all units it uses (interface, then implementation).

    Replay that rule over the named entries in table order; units that the replay inserts
    and that the table does not name are matched to the unnamed slots between two named
    anchors when the counts agree.
    """
    named = {e['unit'].lower(): e['position'] for e in entries if e['unit']}
    seq, seen, missing = [], set(), set()

    def visit(u):
        if u in seen:
            return
        seen.add(u)
        deps, src = unit_uses(name, u)
        if deps is None:
            missing.add(u)
            deps = []
        for d in deps:
            visit(d)
        seq.append(u)

    violations, cyclic = [], 0
    for e in sorted(entries, key=lambda x: x['position']):
        if e['unit']:
            u = e['unit'].lower()
            deps, src = unit_uses(name, u)
            for d in deps or []:
                if d in named and named[d] > e['position']:
                    back = reaches(name, d, u)
                    if back:
                        cyclic += 1  # mutual uses (one side in implementation): order is free
                    else:
                        violations.append('%s (pos %d) uses %s (pos %d)' % (e['unit'], e['position'], d, named[d]))
    roots, project = project_roots(name)
    if roots is None:
        roots = [e['unit'].lower() for e in sorted(entries, key=lambda x: x['position']) if e['unit']]
        project = 'none (named table entries used as roots)'
    for u in ['sysinit', 'system'] + roots:
        visit(u)
    where = {u: i for i, u in enumerate(seq)}
    # agreement of the replay with every named entry (relative order)
    named_seq = [e['unit'].lower() for e in sorted(entries, key=lambda x: x['position'])
                 if e['unit'] and e['unit'].lower() in where]
    replay_named = sorted(named_seq, key=lambda u: where[u])
    order_agrees = named_seq == replay_named
    mismatched = sum(1 for a, b in zip(named_seq, replay_named) if a != b)
    anchors = [e for e in sorted(entries, key=lambda x: x['position']) if e['unit']
               and e['unit'].lower() in where]
    filled = 0
    bounds = [None] + anchors + [None]
    by_pos = sorted(entries, key=lambda x: x['position'])
    for a, b in zip(bounds, bounds[1:]):
        lo = a['position'] if a else -1
        hi = b['position'] if b else len(entries)
        slots = [e for e in by_pos[lo + 1:hi] if not e['unit']]
        if not slots:
            continue
        s_lo = where[a['unit'].lower()] if a else -1
        s_hi = where[b['unit'].lower()] if b else len(seq)
        if s_lo >= s_hi:
            continue
        between = seq[s_lo + 1:s_hi]
        extra = [u for u in between if u not in named]
        # accept only where the replay agrees locally: the two anchors are adjacent named
        # units in the replay too, and the replay inserts exactly as many unnamed units
        if len(extra) == len(slots) and len(extra) == len(between):
            for e, u in zip(slots, extra):
                proper = SRCNAMES.get(u) or next((p.stem for p in SOURCES.get(u, [])), u)
                assign(e, proper, 'dependency-replay',
                       'uses-clause replay inserts %s between %s and %s' % (
                           proper, a['unit'] if a else 'table start', b['unit'] if b else 'table end'))
                named[u] = e['position']
                filled += 1
    pairs = list(zip(anchors, anchors[1:]))
    replay_unnamed = [u for u in seq if u not in named]
    return {'_replay_unnamed': replay_unnamed,'named_entries_checked': len(anchors),
            'used_unit_later_but_mutual_uses': cyclic,
            'order_violations': violations,
            'replay_adjacent_named_pairs_in_order': '%d/%d' % (
                sum(1 for a, b in pairs if where[a['unit'].lower()] < where[b['unit'].lower()]), len(pairs)),
            'replay_roots_from': project,
            'replay_length': len(seq),
            'replay_matches_named_order': order_agrees,
            'replay_named_positions_differing': mismatched,
            'units_without_source': sorted(missing),
            'slots_filled_by_replay': filled}


def reaches(module, start, target):
    """True when start uses target directly or transitively (any section): a uses cycle."""
    stack, seen = [start], {start}
    while stack:
        u = stack.pop()
        for d in unit_uses(module, u)[0] or []:
            if d == target:
                return True
            if d not in seen:
                seen.add(d)
                stack.append(d)
    return False


def resstring_records(img, lo, hi):
    """Longest run of 8-byte {Module: pointer outside code, Identifier < 0x10000} records."""
    best = 0
    for phase in (0, 4):
        run, prev_ptr = 0, None
        for r in range(lo - lo % 8 + phase, hi - 8, 8):
            ptr, ident = struct.unpack_from('<II', img.code, r - img.c0)
            ok = (img.base <= ptr < img.base + img.pe.OPTIONAL_HEADER.SizeOfImage
                  and 0 < ident < 0x10000 and not img.in_code(ptr))
            if ok and ptr == (prev_ptr or ptr):
                run, prev_ptr = run + 1, ptr
                best = max(best, run)
            else:
                run, prev_ptr = (1, ptr) if ok else (0, None)
    return best


def project_roots(name):
    home = module_dir(name)
    stem = name.rsplit('.', 1)[0].lower()
    if not home or home == D3SRC:
        return None, None
    for path in home.iterdir():
        if path.stem.lower() == stem and path.suffix.lower() in ('.dpr', '.dpk'):
            text = strip_comments(path.read_text('latin1'))
            key = 'uses' if path.suffix.lower() == '.dpr' else 'contains'
            m = re.search(r'\b' + key + r'\b([^;]*);', text, re.I)
            if m:
                return ([u.strip().split()[0].lower() for u in m[1].split(',') if u.strip()],
                        str(path) + ' (recovered project file: ' + key + ' list)')
    return None, None

def solve_weak(entries, unresolved, weak_units, contained, taken, assign):
    """Name weak-packaged stubs whose region has no externals, by Delphi's dependency rule.

    A unit is initialized only after every unit it uses (interface and implementation),
    so a weak unit W cannot sit at a position earlier than any of its used units, and
    it must sit before every unit (with known Delphi 3 source) that uses it.
    """
    pos = {e['unit'].lower(): e['position'] for e in entries if e['unit']}
    changed = True
    while changed:
        changed = False
        open_ = [e for e in unresolved if not e['unit'] and not e.get('_externals')]
        options = {}
        for e in open_:
            p = e['position']
            cands = []
            for w in weak_units:
                if w in taken:
                    continue
                deps = [d.lower() for d in USES.get(w, [])]
                if any(pos.get(d, -1) > p for d in deps):
                    continue
                if any(d not in pos and d in weak_units and d not in ('system', 'sysinit')
                       for d in deps):
                    continue  # its own weak dependencies must already be placed
                users = [u for u, us in USES.items() if w in [x.lower() for x in us]]
                if any(u in pos and pos[u] < p for u in users):
                    continue
                if not any(u in pos and pos[u] > p for u in users):
                    continue  # require a later user with known source
                cands.append(w)
            options[id(e)] = (e, cands)
        for e, cands in options.values():
            if len(cands) == 1:
                w = cands[0]
                assign(e, weak_units[w], 'weak-dependency',
                       'only weak-packaged unit whose used units are all initialized earlier '
                       'and which a later-initialized unit uses (Delphi 3 source uses clauses)')
                pos[w] = e['position']
                changed = True
                break
        else:
            for e, cands in options.values():
                e['_candidates'] = [weak_units[c] for c in cands]


def describe_gap(e, img, contained, taken, weak_units):
    lo, hi = e['_region']
    bits = ['no unit name recoverable from region %#x-%#x' % (lo, hi)]
    if e.get('_externals'):
        bits.append('DLL imports present but not matched to one Delphi 3 source unit')
    left = [contained[u] for u in contained if u not in taken and u not in weak_units]
    if left:
        bits.append('unassigned contained units: ' + ', '.join(left))
    if e.get('_candidates'):
        bits.append('weak-unit candidates: ' + ', '.join(e['_candidates']))
    return '; '.join(bits)


def main():
    out_path = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(__file__).with_name('initialization-order.json')
    order, owner = required_closure()
    weak = {}
    for name in order:
        for u, f in bg.package_info(game_path(name))[2]:
            if f & 4:
                weak[u.lower()] = u
    weak['sysinit'] = 'SysInit'
    modules = []
    for name in order:
        m = analyse(name, weak)
        m['loaded_by'] = sorted(owner[name])
        local = [e for e in m['entries'] if e['via_package'] is None]
        m['summary'] = {
            'entries': m['entry_count'],
            'via_import_thunk': sum(1 for e in m['entries'] if e['via_package']),
            'local': len(local),
            'local_resolved': sum(1 for e in local if e['unit']),
            'local_unresolved': sum(1 for e in local if not e['unit']),
            'by_method': {k: sum(1 for e in local if e.get('method') == k)
                          for k in sorted({str(e.get('method')) for e in local}) if k != 'None'},
        }
        modules.append(m)
    modules.sort(key=lambda m: (m['module'].lower().endswith('.dpl'), m['module'].lower()))
    note = {
        'verified_in_original_binaries': [
            'Each table is the compiler-emitted PackageUnitEntry array {Init, FInit}: for a .dpl the '
            'pointer returned by @GetPackageInfoTable (mov eax, imm32), for an .exe the table pointer '
            'loaded at the entry point before the call to _InitExe; count and records read from the files.',
            'Per-unit counter guard: a unit init starts "sub dword ptr [counter],1; jae <skip>" and its '
            'finalization is a try/finally around "inc dword ptr [counter]; jne <skip>" (disassembled: '
            'AoWEPACK.dpl AoWE.AoWE@00000000 / AoWE.Finalization). A unit with no initialization '
            'section still gets a 0x38-byte stub with the same counter: FInit, then Init = '
            '"sub [counter],1; ret" (AoW.exe 0x401220..0x401257). So the body runs only on the first '
            'Init call and finalization only when the counter returns to zero.',
            'An entry for a unit that lives in a required package is an import thunk (jmp [IAT]) to that '
            "package's exported Unit.Unit@00000000 init; via_package is the thunk's DLL. The exe tables "
            'therefore list every packaged unit the program reaches, in the exe\'s own order.',
            'Weak-packaged units (PACKAGEINFO unit flag 4; all 23 are in VCL30.dpl) and SysInit are '
            'compiled into each client as local entries with their own counter; their DLL externals '
            'are imported directly by the client and the thunks sit in that unit\'s code region.',
            'For the exes, table order differs from both PACKAGEINFO unit order and code (link) order '
            '(e.g. AoW.exe position 211 FontMod has the lowest code address of the contained units).',
            'Table order versus Delphi 3 RTL/VCL source uses clauses: in VCL30/VCLX30/VCLDB30 and the '
            'game packages that do not import AoWEPACK, no named unit precedes a unit it uses except '
            'inside uses cycles (counted in dependency_check.used_unit_later_but_mutual_uses). '
            'Modules that import AoWEPACK do show such cases against the recovered sources '
            '(dependency_check.order_violations, e.g. AoW.exe AoWReg at 65 before Sound at 68), so '
            'the client table is not a strict dependency order for imported package units, or the '
            'recovered uses clauses differ from the originals.',
        ],
        'verified_in_delphi3_source_only': [
            'System.InitUnits (SOURCE/RTL/SYS/SYSTEM.PAS) calls Table[I].Init for I = 0..Count-1, '
            'recording InitCount before each call; FInitUnits calls FInit for InitCount-1 down to 0 '
            '(so only units that were started are finalized, in reverse).',
            'A package DLL entry (_InitPkg in SYSINIT.PAS) does not run its own table; the table runs '
            'only through the exported Initialize (_PackageLoad), i.e. for LoadPackage. For packages '
            'that AoW.exe imports statically, the units are initialized from the exe\'s table via the '
            'import thunks; the counters make a later run of a package table (or a unit listed in '
            'several tables) a no-op for units already initialized.',
        ],
        'assumed': [
            'That the shipped VCL30.dpl and the game binaries behave as the Delphi 3.02 RTL source above '
            '(not traced at run time; the game was not run).',
            'Region boundaries between local entries are approximated by the previous entry\'s stub end. '
            'Methods "externals" and "dependency-replay" use Delphi 3 SOURCE external/uses clauses '
            '(and recovered src/delphi3 uses clauses and project files for the replay); '
            '"dependency-replay" names a slot only where the replay puts the same two named neighbours '
            'adjacent and inserts exactly as many unnamed units. "resourcestring-records" and '
            '"class-name" are name heuristics, noted in evidence.',
        ],
    }
    allmods = [m for m in modules]
    totals = {
        'modules': len(allmods),
        'entries': sum(m['summary']['entries'] for m in allmods),
        'via_import_thunk': sum(m['summary']['via_import_thunk'] for m in allmods),
        'local': sum(m['summary']['local'] for m in allmods),
        'local_unresolved': sum(m['summary']['local_unresolved'] for m in allmods),
    }
    result = {'note': note, 'generated_by': str(Path(__file__).resolve()),
              'command': 'python ' + str(Path(__file__).resolve()), 'totals': totals,
              'modules': modules}
    out_path.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n', encoding='utf-8')
    for m in modules:
        s = m['summary']
        print('%-14s entries=%3d thunk=%3d local=%3d resolved=%3d unresolved=%d %s' % (
            m['module'], s['entries'], s['via_import_thunk'], s['local'], s['local_resolved'],
            s['local_unresolved'], s['by_method']))


if __name__ == '__main__':
    main()
