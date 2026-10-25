"""Survey shape-only casts over src/delphi3 -> shape-casts.json.

Usage: python shape_casts.py [out.json]
Kinds (doc/delphi3-codegen.md):
  pointer-class-cast   T(Pointer(X)) with T a class and X a parameter/variable/field
                       designator (K44/K69/e10: changes member-load order or registers)
  global-cell-view     T(Pointer(@G)^) (K45: re-reads the cell instead of reusing it);
                       subkind says whether G is a global, a parameter or a local
  k58-self-assignment  X := T(Pointer(X)) (K58: exchanges Self/Sender registers)
  pointer-view-constant  typed constant  Name: PType = @Target  (a constant cell pointer)
  absolute-alias       var Name: T absolute Target (extra: same-cell aliasing)
Counts per kind are reported for the whole tree and for AoWEPACK.
"""
import os, sys, json, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pasdecl as P

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), 'shape-casts.json')
m = P.Model()
m.load()
TE = P.TypeEval(m)


def match(toks, i):
    d = 0
    for j in range(i, len(toks)):
        if toks[j].v in ('(', '['):
            d += 1
        elif toks[j].v in (')', ']'):
            d -= 1
            if d == 0:
                return j
    return None


def text(toks):
    out, prev = '', None
    for t in toks:
        if prev is not None and ((prev.k == 'id' and t.k in ('id', 'num')) or t.v == ':=' or prev.v in (':=', ',')):
            out += ' '
        out += t.v
        prev = t
    return out


def is_designator(toks):
    """ident{.ident} possibly with ^ -- a variable, parameter or field, no calls/indexing"""
    if not toks or toks[0].k != 'id':
        return False
    expect_id = False
    for t in toks[1:]:
        if expect_id:
            if t.k != 'id':
                return False
            expect_id = False
        elif t.v == '.':
            expect_id = True
        elif t.v == '^':
            continue
        else:
            return False
    return not expect_id


def decl_of(toks, unit, routine, k):
    scope = P.Scope(m, unit, routine, k)
    ty, info = TE.expr(toks, scope)
    d = {kk: vv for kk, vv in info.items() if kk != 'member'}
    if info.get('member') is not None:
        mem = info['member']
        d['declared_at'] = '%s:%s' % (P.rel(mem.file), mem.line)
    return ty, d


def line_text(f, ln):
    for L in m.units.values():
        if f in L.texts:
            return L.texts[f][ln - 1].strip()
    return None


entries = []
for key in sorted(m.units):
    L = m.units[key]
    toks = L.toks
    n = len(toks)
    for k in range(n - 4):
        t = toks[k]
        if t.k != 'id' or toks[k + 1].v != '(' or toks[k + 2].lv != 'pointer' or toks[k + 3].v != '(':
            continue
        if k > 0 and toks[k - 1].v == '.':
            continue
        ti = m.lookup_type(t.v, key)
        tr = m.resolve(ti if ti is not None else t.v, key)
        if tr is None or tr.kind == 'unknown':
            continue
        j = match(toks, k + 1)
        p = match(toks, k + 3)
        if j is None or p is None:
            continue
        inner = toks[k + 4:p]
        routine = P.find_routine(m, key, k)
        base = {'file': P.rel(t.f), 'line': t.ln, 'cast_type': t.v,
                'cast_type_kind': tr.kind if tr is not None else None,
                'routine': TE.rname(routine) if routine else None, 'source_line': line_text(t.f, t.ln)}
        # T(Pointer(@G)^)
        if p + 2 == j and toks[p + 1].v == '^' and inner and inner[0].v == '@':
            g = inner[1:]
            ty, d = decl_of(g, key, routine, k)
            sub = {'global': 'global', 'param': 'parameter', 'local': 'local', 'self-member': 'field of Self',
                   'with-member': 'field (with)', 'member': 'field'}.get(d.get('decl'), d.get('decl'))
            e = dict(base, kind='global-cell-view', subkind=sub, expression=text(toks[k:j + 1]), cell=text(g),
                     cell_decl=d, cell_type=TE.tname(ty) if ty is not None else None)
            entries.append(e)
            continue
        if p + 1 != j or tr is None or tr.kind != 'class':
            continue
        if not is_designator(inner):
            continue
        ty, d = decl_of(inner, key, routine, k)
        # K58: X := T(Pointer(X))
        if k >= 2 and toks[k - 1].v == ':=':
            lhs_end = k - 1
            s0 = lhs_end - 1
            while s0 - 2 >= 0 and toks[s0 - 1].v == '.' and toks[s0 - 2].k == 'id':
                s0 -= 2
            lhs = toks[s0:lhs_end]
            if text(lhs).lower() == text(inner).lower() and j + 1 < n and toks[j + 1].lv in (';', 'end', 'else'):
                vk = 'Self' if text(inner).lower() == 'self' else {'param': 'parameter', 'local': 'local'}.get(d.get('decl'), d.get('decl'))
                e = dict(base, kind='k58-self-assignment', subkind=vk, expression=text(toks[s0:j + 1]), variable=text(inner),
                         variable_decl=d, variable_type=TE.tname(ty) if ty is not None else None)
                entries.append(e)
                continue
        member = None
        if j + 2 < n and toks[j + 1].v == '.' and toks[j + 2].k == 'id':
            member = toks[j + 2].v
        e = dict(base, kind='pointer-class-cast', expression=text(toks[k:j + 1]) + ('.' + member if member else ''),
                 operand=text(inner), operand_decl=d, operand_type=TE.tname(ty) if ty is not None else None,
                 member=member)
        if ty is not None:
            tyr = m.resolve(ty)
            e['same_class'] = bool(tyr is not None and tyr.name and tyr.name.lower() == t.lv)
        entries.append(e)

# typed constants  Name: PType = @Target
for c in m.typedconsts:
    init = c['init']
    if not init or init[0].v != '@':
        continue
    ty = m.resolve(c['type'], c['unit']) if c['type'] is not None else None
    tgt_type = None; sub = 'value-cell'
    if ty is not None and ty.kind == 'ptr':
        tt = m.resolve(ty.target, ty.unit) if ty.target else None
        tgt_type = tt.name if tt is not None else ty.target
        if tt is not None and tt.kind == 'class':
            sub = 'object-cell'
        elif tt is not None and tt.kind == 'record' and tt.name and tt.name.lower() == 'tresstringrec':
            sub = 'resourcestring'
        elif tt is not None and tt.kind in ('record', 'array'):
            sub = 'data'
    tn = c['type'] if isinstance(c['type'], str) else TE.tname(c['type'])
    if tn and tn.lower() == 'presstringrec':
        sub = 'resourcestring'
    entries.append({'file': P.rel(c['file']), 'line': c['line'], 'kind': 'pointer-view-constant', 'subkind': sub,
                    'name': c['name'], 'type': tn, 'points_to_type': tgt_type, 'target': text(init[1:]),
                    'local': c['local'], 'expression': '%s: %s = %s' % (c['name'], tn, text(init)),
                    'source_line': line_text(c['file'], c['line'])})
for a in m.absolutes:
    entries.append({'file': P.rel(a['file']), 'line': a['line'], 'kind': 'absolute-alias', 'name': a['name'],
                    'type': a['type'] if isinstance(a['type'], str) else None, 'target': a['target'],
                    'local': a['local'], 'expression': '%s: %s absolute %s' % (a['name'], a['type'], a['target']),
                    'source_line': line_text(a['file'], a['line'])})

entries.sort(key=lambda e: (e['file'].lower(), e['line'], e['kind'], e['expression']))
cnt = collections.Counter(e['kind'] for e in entries)
cnt_aowe = collections.Counter(e['kind'] for e in entries if e['file'].startswith('src/delphi3/AoWEPACK/'))
sub = collections.Counter('%s/%s' % (e['kind'], e.get('subkind')) for e in entries if e.get('subkind'))
out = {'generator': 'shape_casts.py (tools/portdata)',
       'counts': dict(sorted(cnt.items())), 'counts_AoWEPACK': dict(sorted(cnt_aowe.items())),
       'counts_by_subkind': dict(sorted(sub.items())), 'entries': entries}
json.dump(out, open(OUT, 'w', newline='\n'), indent=1)
print(json.dumps({k: out[k] for k in ('counts', 'counts_AoWEPACK', 'counts_by_subkind')}, indent=1))
