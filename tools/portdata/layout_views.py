"""Survey raw layout views over src/delphi3 -> layout-views.json.

Usage: python layout_views.py [out.json]
Kinds:
  fields-index  VIEW(Pointer(B)^).Fields[$N div 4] (or PVIEW(B)^.Fields[..]) where VIEW is a
                record whose only field is an array of Pointer
  view-record   VIEW(Pointer(B)^).F / PVIEW(B)^.F / PVIEW(Pointer(B))^.F on a padding record
  other         view-class casts (fake classes whose fields mirror another class's layout),
                view values used without a member selector, with-statements over a view,
                non-constant indexes
"""
import os, re, sys, json, collections
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import pasdecl as P
from hints import hint_for, EXTERNAL_FIELDS

OUT = sys.argv[1] if len(sys.argv) > 1 else os.path.join(os.path.dirname(os.path.abspath(__file__)), 'layout-views.json')

m = P.Model()
m.load()
TE = P.TypeEval(m)

PAD = re.compile(r'^(F?Reserved|Padding|Pad|Unknown|Gap|Fill)', re.I)
VIEWCLS = re.compile(r'(View|Fields|Calls|ABI|Access)$')


def fields_array(ti):
    """record whose only field is an array of Pointer -> (member, elemsize)"""
    fl = [f for f in ti.fields]
    if len(fl) == 1 and fl[0].kind == 'field':
        t = m.resolve(fl[0].type, ti.unit)
        if t is not None and t.kind == 'array':
            e = m.resolve(t.elem, t.unit)
            if e is not None and e.kind == 'prim' and e.name == 'pointer':
                return fl[0]
    return None


def is_view_record(ti):
    if ti is None or ti.kind != 'record':
        return False
    if fields_array(ti) is not None:
        return True
    return any(f.kind == 'field' and PAD.match(f.name) for f in m.all_record_fields(ti))


def is_view_class(ti):
    if ti is None or ti.kind != 'class' or getattr(ti, 'ext', False) or getattr(ti, 'forward', False):
        return False
    if ti.name.lower() in m.cjl or '/imports/' in P.rel(ti.file or ''):
        return False
    if not ti.fields:
        return bool(re.search(r'(Calls|ABI)$', ti.name))
    return bool(VIEWCLS.search(ti.name)) or any(PAD.match(f.name) for f in ti.fields)


def text(toks):
    out = ''
    prev = None
    for t in toks:
        if prev is not None:
            if (prev.k == 'id' and t.k in ('id', 'num')) or (prev.k == 'num' and t.k == 'id') or \
               (t.v in (':=', '=', '<>', '<=', '>=', '+', '-', '*', '/') or prev.v in (':=', '=', '<>', '<=', '>=', '+', '-', '*', '/', ',')):
                out += ' '
        out += t.v
        prev = t
    return out


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


def fmt_off(o):
    return None if o is None else '$%X' % o


def member_desc(mem, sub=0):
    t = m.resolve(mem.type, mem.owner.unit if mem.owner is not None else None)
    d = {'class': mem.cls, 'name': mem.name, 'type': TE.tname(mem.type),
         'visibility': mem.vis or 'default', 'offset': fmt_off(mem.off),
         'offset_source': mem.off_src, 'size': mem.size,
         'declared_at': '%s:%s' % (P.rel(mem.file), mem.line)}
    if mem.vis is None:
        c = mem.owner
        d['visibility'] = 'published (default, TPersistent descendant)' if c is not None and P.is_persistent(m, c) else 'public (default)'
    if mem.name.startswith('F_') or PAD.match(mem.name):
        d['placeholder'] = True
    if sub:
        d['sub_offset'] = fmt_off(sub)
        path = sub_path(t, sub)
        if path:
            d['sub_path'] = path
    return d


def sub_path(t, sub):
    if t is None:
        return None
    if t.kind == 'record':
        m.layout_record(t)
        for f in m.all_record_fields(t):
            if f.off is not None and f.size and f.off <= sub < f.off + f.size:
                rest = sub_path(m.resolve(f.type, t.unit), sub - f.off) if sub - f.off else None
                return '.' + f.name + (rest or '')
    if t.kind == 'array':
        es, _ = m.size_align(t.elem, t.unit)
        if not es:
            return None
        bounds = []
        for d in t.dims:
            if isinstance(d, tuple):
                lo, hi = m.const_eval(d[0], t.unit), m.const_eval(d[1], t.unit)
            else:
                rg = m.ordinal_range(d, t.unit)
                lo, hi = rg if rg else (None, None)
            if lo is None or hi is None:
                return None
            bounds.append((lo, hi))
        if not bounds:
            bounds = [(0, 0)]
        idx = []
        rem = sub // es
        for n, (lo, hi) in enumerate(bounds):
            stride = 1
            for lo2, hi2 in bounds[n + 1:]:
                stride *= hi2 - lo2 + 1
            idx.append(lo + rem // stride)
            rem %= stride
        rest = sub % es
        tail = sub_path(m.resolve(t.elem, t.unit), rest) if rest else ''
        return '[%s]%s' % (', '.join(str(i) for i in idx), tail if tail is not None else '+$%X' % rest)
    return None


def unit_of(mem):
    return mem.owner.unit if mem.owner is not None else None


def accessible(mem, use_unit, base_cls):
    vis = mem.vis or 'public'
    if vis in ('public', 'published', 'automated'):
        return True, None
    if unit_of(mem) == use_unit:
        return True, None
    if vis == 'protected':
        return False, 'protected field of %s (unit %s); not visible here without a descendant or the protected-access cast idiom' % (mem.cls, unit_of(mem))
    return False, 'private field of %s (unit %s); not visible from unit %s' % (mem.cls, unit_of(mem), use_unit)


def strip_casts(toks):
    """T(X) -> X repeatedly (for inner view detection)"""
    while len(toks) >= 4 and toks[0].k == 'id' and toks[1].v == '(' and match(toks, 1) == len(toks) - 1:
        t = m.resolve(toks[0].v)
        if t is None or t.kind == 'unknown':
            break
        toks = toks[2:-1]
    return toks


# ------------------------------------------------------------ scanning
uses = []
excluded = []
view_types_used = collections.Counter()


def classify_base(btoks, unit, routine, k, cache):
    """returns dict: typed type/class, decl info, inferred class (nested view)"""
    scope = P.Scope(m, unit, routine, k)
    ty, info = TE.expr(btoks, scope)
    out = {'base': text(btoks)}
    tyr = m.resolve(ty) if ty is not None else None
    out['base_type'] = (tyr.name if tyr is not None and tyr.name else (tyr.kind if tyr is not None else None))
    out['base_class'] = tyr.name if tyr is not None and tyr.kind == 'class' and tyr.name.lower() not in ('tobject',) else None
    if tyr is not None and tyr.kind == 'class' and tyr.name.lower() == 'tobject':
        out['base_class'] = None
        out['base_untyped'] = 'TObject'
    elif tyr is None or tyr.kind != 'class':
        out['base_untyped'] = out['base_type'] or 'unknown'
    d = {kk: vv for kk, vv in info.items() if kk != 'member'}
    if 'member' in info and info['member'] is not None:
        mem = info['member']
        d['declared_at'] = '%s:%s' % (P.rel(mem.file), mem.line)
    out['base_decl'] = d
    out['_cls'] = tyr if out['base_class'] else None
    return out


def resolve_field(cls, off):
    r = m.field_at(cls, off)
    if r is None:
        size = m.class_size(cls)
        return None, 'offset $%X is beyond the instance size of %s ($%s); the object at run time is a descendant' % (
            off, cls.name, '%X' % size if size is not None else '?')
    if r['status'] == 'ok':
        return r, None
    return None, r['reason']


VIEWNAMES = set()
for _lst in m.types.values():
    for _t in _lst:
        if _t.kind == 'record' and fields_array(_t) is not None:
            VIEWNAMES.add(_t.name.lower())


def scan_unit(L):
    toks = L.toks
    unit = L.unit
    n = len(toks)
    rcache = {}

    def routine_at(k):
        return P.find_routine(m, unit, k)

    k = 0
    while k < n:
        t = toks[k]
        if t.k != 'id' or k + 1 >= n or toks[k + 1].v != '(':
            k += 1; continue
        if k > 0 and toks[k - 1].v == '.':
            k += 1; continue
        ti = m.lookup_type(t.v, unit)
        if ti is None:
            k += 1; continue
        tr = m.resolve(ti, unit)
        rec = None; deref = False; through_ptr = False
        j = match(toks, k + 1)
        if j is None:
            k += 1; continue
        inner = toks[k + 2:j]
        after = j + 1
        if tr is not None and tr.kind == 'record':
            # R(Pointer(B)^)
            if len(inner) >= 5 and inner[0].lv == 'pointer' and inner[1].v == '(' and match(inner, 1) == len(inner) - 2 and inner[-1].v == '^':
                rec = tr; btoks = inner[2:-2]; deref = True; through_ptr = True
            else:
                k += 1; continue
        elif tr is not None and tr.kind == 'ptr':
            tgt = m.resolve(tr.target, tr.unit) if tr.target else None
            if tgt is None or tgt.kind != 'record':
                k += 1; continue
            rec = tgt
            btoks = inner
            if len(inner) >= 4 and inner[0].lv == 'pointer' and inner[1].v == '(' and match(inner, 1) == len(inner) - 1:
                btoks = inner[2:-1]; through_ptr = True
            if after < n and toks[after].v == '^':
                deref = True; after += 1
        elif is_view_class(tr):
            rec = tr
            btoks = inner
            if len(inner) >= 4 and inner[0].lv == 'pointer' and inner[1].v == '(' and match(inner, 1) == len(inner) - 1:
                btoks = inner[2:-1]; through_ptr = True
        else:
            k += 1; continue
        if not btoks:
            k += 1; continue
        if btoks[0].v == '@':
            k += 1; continue     # cell view: shape-casts survey
        routine = routine_at(k)
        base = classify_base(btoks, unit, routine, k, rcache)
        fa = fields_array(rec) if rec.kind == 'record' else None
        isview = rec.kind == 'class' or is_view_record(rec)
        bt_ = m.resolve(base['base_type']) if base['base_type'] else None
        ordinal = bt_ is not None and bt_.kind in ('prim', 'sub', 'enum') and bt_.name not in ('pointer', 'untyped-deref')
        if rec.kind == 'record' and fa is None and ordinal and not re.search(r'(View|Fields|State|Flags)$', rec.name):
            excluded.append({'file': P.rel(t.f), 'line': t.ln, 'expression': text(toks[k:after]),
                             'view_type': rec.name, 'base': base['base'], 'base_type': base['base_type'],
                             'reason': 'record pointer carried in an ordinal value (message parameter); a record, not an object layout view'})
            k += 1; continue
        if isview and rec.kind == 'record' and fa is None and base['base_class'] is None and base.get('base_untyped') not in ('TObject',)                 and not ordinal and not re.search(r'(View|Fields|State|Flags)$', rec.name) and not strip_casts(btoks)[0].lv in VIEWNAMES:
            isview = False
        if not isview and base['base_class'] is None:
            excluded.append({'file': P.rel(t.f), 'line': t.ln, 'expression': text(toks[k:after]),
                             'view_type': rec.name, 'base': base['base'], 'base_type': base['base_type'],
                             'reason': 'cast of a non-object pointer to an ordinary record (not a layout view)'})
            k += 1; continue
        # member selector
        sel = None; idx = None; endk = after
        if after + 1 < n and toks[after].v == '.' and toks[after + 1].k == 'id':
            sel = toks[after + 1]; endk = after + 2
            if endk < n and toks[endk].v == '[':
                e2 = match(toks, endk)
                idx = toks[endk + 1:e2]; endk = e2 + 1
        entry = {'file': P.rel(t.f), 'line': t.ln, 'expression': text(toks[k:endk]),
                 'view_type': rec.name, 'view_type_declared_at': '%s:%s' % (P.rel(rec.file), rec.line) if rec.file else None,
                 'through_pointer': through_ptr, 'routine': TE.rname(routine) if routine else None}
        entry.update({kk: vv for kk, vv in base.items() if not kk.startswith('_')})
        off = None
        if rec.kind == 'class':
            m.layout_class(rec)
            entry['kind'] = 'other'
            entry['subkind'] = 'view-class'
            if sel is not None:
                mem = m.find_member(rec, sel.v)
                if mem is None:
                    entry['view_member'] = sel.v
                    entry['resolution'] = 'unresolved'; entry['reason'] = 'member %s not found in view class %s' % (sel.v, rec.name)
                elif mem.kind != 'field':
                    entry['view_member'] = mem.name
                    entry['view_member_kind'] = mem.kind
                    entry['resolution'] = 'not-a-field'
                    entry['reason'] = '%s %s.%s of a call-shape view (VMT slot use, no field offset)' % (mem.kind, mem.cls, mem.name)
                else:
                    entry['view_member'] = mem.name
                    off = mem.off
            else:
                entry['resolution'] = 'unresolved'; entry['reason'] = 'view value used without a member selector'
                if k >= 2 and toks[k - 1].v == ':=':
                    entry['subkind'] = 'view-class-assignment'
                    entry['reason'] = 'view value assigned to %s; its member uses are listed as view-class variable entries' % toks[k - 2].v
        else:
            m.layout_record(rec)
            if not deref:
                entry['kind'] = 'other'; entry['subkind'] = 'pointer-view-value'
                entry['resolution'] = 'unresolved'; entry['reason'] = 'view pointer value used without dereference/selector'
            elif sel is None:
                entry['kind'] = 'other'; entry['subkind'] = 'whole-view'
                entry['resolution'] = 'unresolved'; entry['reason'] = 'view used without a member selector'
                if k >= 1 and toks[k - 1].lv == 'with':
                    entry['subkind'] = 'with-view'
                    entry['reason'] = 'with-statement over the view; members are selected implicitly in the body'
            else:
                fm = None
                for f in m.all_record_fields(rec):
                    if f.name.lower() == sel.lv:
                        fm = f
                if fm is None:
                    entry['kind'] = 'other'; entry['resolution'] = 'unresolved'
                    entry['reason'] = 'field %s not in view record' % sel.v
                elif fa is not None and fm is fa:
                    entry['kind'] = 'fields-index'
                    if idx is None:
                        entry['kind'] = 'other'; entry['subkind'] = 'fields-no-index'
                        entry['resolution'] = 'unresolved'; entry['reason'] = 'Fields array used without index'
                    else:
                        iv = m.const_eval(idx, unit)
                        entry['index'] = text(idx)
                        if iv is None:
                            entry['kind'] = 'other'; entry['subkind'] = 'fields-variable-index'
                            entry['resolution'] = 'unresolved'; entry['reason'] = 'non-constant Fields index'
                        else:
                            arr = m.resolve(fm.type, rec.unit)
                            es, _ = m.size_align(arr.elem, arr.unit)
                            off = (fm.off or 0) + (iv - (m.first_lo(arr, arr.unit) or 0)) * es
                else:
                    entry['kind'] = 'view-record'
                    entry['view_member'] = fm.name
                    off = fm.off
                    if idx is not None:
                        entry['index'] = text(idx)
                        arr = m.resolve(fm.type, rec.unit)
                        iv = m.const_eval([x for x in idx if x.v != ','] if len(arr.dims if arr.kind == 'array' else []) == 1 else idx, unit) if arr is not None and arr.kind == 'array' else None
                        if iv is not None and off is not None:
                            es, _ = m.size_align(arr.elem, arr.unit)
                            off = off + (iv - (m.first_lo(arr, arr.unit) or 0)) * es
                        else:
                            entry['variable_index'] = True
                            entry['offset_note'] = 'non-constant index; offset is the start of view field %s' % fm.name
        entry['offset'] = fmt_off(off)
        entry['_off'] = off
        entry['_cls'] = base['_cls']
        entry['_btoks'] = btoks
        entry['_unit'] = unit
        entry['_k'] = k
        entry['_routine'] = routine
        if 'kind' not in entry:
            entry['kind'] = 'other'
        uses.append(entry)
        view_types_used[(rec.name, P.rel(rec.file) if rec.file else None, rec.line)] += 1
        k += 1


for key in sorted(m.units):
    scan_unit(m.units[key])


def view_type_of_var(tyexpr, unit):
    """(view TI, through) when a variable's declared type is a view class, view record or a
    pointer to a view record"""
    t = m.resolve(tyexpr, unit) if tyexpr is not None else None
    if t is None:
        return None, None
    if t.kind == 'class' and is_view_class(t):
        return t, 'view-class variable'
    if t.kind == 'ptr' and t.target:
        tg = m.resolve(t.target, t.unit)
        if tg is not None and tg.kind == 'record' and tg.id in CONFIRMED:
            return tg, 'view-record pointer variable'
    return None, None


CONFIRMED = set()
_tmap = {}
for _lst in m.types.values():
    for _t in _lst:
        if _t.kind == 'record':
            _tmap[(_t.name, P.rel(_t.file) if _t.file else None, _t.line)] = _t
for (_n, _f, _l), _c in view_types_used.items():
    if (_n, _f, _l) in _tmap:
        CONFIRMED.add(_tmap[(_n, _f, _l)].id)


def scan_view_variables():
    for r in sorted(m.routines, key=lambda r: (r.unit or '', r.start or 0)):
        if r.start is None or r.end is None or getattr(r, 'body', None) is None:
            continue
        L = m.units[r.unit]
        toks = L.toks
        vars_ = {}
        for ln, e in list(r.params.items()) + list(r.locals.items()):
            vt, how = view_type_of_var(e[1], r.unit)
            if vt is not None:
                vars_[ln] = (e, vt, how)
        if not vars_:
            continue
        inner_ranges = [(x.start, x.end) for x in m.routines if x.parent is r and x.start is not None]
        assigned = collections.defaultdict(list)
        for k in range(r.body, r.end):
            if any(a <= k < b for a, b in inner_ranges):
                continue
            t = toks[k]
            if t.k != 'id' or t.lv not in vars_ or (k > 0 and toks[k - 1].v == '.'):
                continue
            if k + 1 < len(toks) and toks[k + 1].v == ':=':
                e = k + 2
                d = 0
                while e < len(toks) and not (d == 0 and (toks[e].v == ';' or toks[e].lv in ('end', 'else'))):
                    if toks[e].v in ('(', '['):
                        d += 1
                    elif toks[e].v in (')', ']'):
                        d -= 1
                    e += 1
                rhs = toks[k + 2:e]
                src = rhs
                if len(rhs) >= 4 and rhs[0].k == 'id' and rhs[1].v == '(' and match(rhs, 1) == len(rhs) - 1:
                    src = rhs[2:-1]
                    if len(src) >= 4 and src[0].lv == 'pointer' and src[1].v == '(' and match(src, 1) == len(src) - 1:
                        src = src[2:-1]
                b = classify_base(src, r.unit, r, k, None)
                assigned[t.lv].append({'line': t.ln, 'rhs': text(rhs), 'source': b['base'], 'source_type': b['base_type'],
                                       'source_class': b['base_class'], '_cls': b['_cls']})
        for k in range(r.body, r.end):
            if any(a <= k < b for a, b in inner_ranges):
                continue
            t = toks[k]
            if t.k != 'id' or t.lv not in vars_ or (k > 0 and toks[k - 1].v == '.'):
                continue
            j = k + 1
            if j < len(toks) and toks[j].v == '^':
                j += 1
            if not (j + 1 < len(toks) and toks[j].v == '.' and toks[j + 1].k == 'id'):
                continue
            e, vt, how = vars_[t.lv]
            sel = toks[j + 1]
            mem = m.find_member(vt, sel.v)
            entry = {'file': P.rel(t.f), 'line': t.ln, 'expression': text(toks[k:j + 2]), 'kind': 'other',
                     'subkind': how, 'view_type': vt.name,
                     'view_type_declared_at': '%s:%s' % (P.rel(vt.file), vt.line) if vt.file else None,
                     'through_pointer': False, 'routine': TE.rname(r), 'base': t.v,
                     'base_type': vt.name, 'base_class': None,
                     'base_decl': {'decl': e[5], 'type': TE.tname(e[1]), 'file': P.rel(e[3]), 'line': e[4]},
                     'view_member': sel.v}
            srcs = [dict((kk, vv) for kk, vv in a.items() if kk != '_cls') for a in assigned.get(t.lv, [])]
            entry['assigned_from'] = srcs
            off = None
            if mem is None:
                entry['resolution'] = 'unresolved'; entry['reason'] = 'member %s not in %s' % (sel.v, vt.name)
            elif mem.kind != 'field':
                entry['view_member_kind'] = mem.kind
                entry['resolution'] = 'not-a-field'
                entry['reason'] = '%s %s.%s of a call-shape view (VMT slot use, no field offset)' % (mem.kind, mem.cls, mem.name)
            else:
                if vt.kind == 'class':
                    m.layout_class(vt)
                else:
                    m.layout_record(vt)
                off = mem.off
            entry['offset'] = fmt_off(off)
            cmap = {a['_cls'].name: a['_cls'] for a in assigned.get(t.lv, []) if a['_cls'] is not None}
            classes = sorted(cmap)
            entry['_off'] = off
            entry['_cls'] = cmap[classes[0]] if len(classes) == 1 else None
            if len(classes) == 1:
                entry['base_class_inferred'] = classes[0]
                entry['inferred_from'] = 'assignment(s) to %s in %s' % (t.v, TE.rname(r))
            entry['_btoks'] = [t]
            entry['_unit'] = r.unit
            entry['_k'] = k
            entry['_routine'] = r
            entry['_varview'] = True
            uses.append(entry)


scan_view_variables()

# index uses by (file, token idx) to resolve nested views
by_pos = {}
for u in uses:
    by_pos[(u['_unit'], u['_k'])] = u


def runtime_class_of(u):
    h = hint_for(u['file'], u['base'])
    if not h:
        return None, None
    cls, why = h
    if isinstance(cls, tuple):
        owner = m.lookup_type(cls[1], u['_unit'])
        r = m.field_at(owner, cls[2])
        if r is None or r.get('status') != 'ok':
            return None, why
        t = m.resolve(r['member'].type, owner.unit)
        why = '%s (%s.%s: %s)' % (why, r['class'], r['member'].name, t.name if t is not None else '?')
        return t, why
    return m.lookup_type(cls, u['_unit']), why


def field_lookup(cls, off):
    """(member-desc dict, member or None, path, reason)"""
    r = m.field_at(cls, off)
    if r is not None and r['status'] == 'external':
        ext = EXTERNAL_FIELDS.get(r['class'])
        if ext and off in ext:
            nm, ty, vis = ext[off]
            d = {'class': r['class'], 'name': nm, 'type': ty, 'visibility': vis, 'offset': fmt_off(off),
                 'offset_source': 'external VCL layout (hints.EXTERNAL_FIELDS)', 'external': True}
            return d, None, nm, None
        return None, None, None, r['reason']
    if r is None:
        size = m.class_size(cls)
        return None, None, None, 'offset $%X is beyond the instance size of %s ($%s); the object at run time is a descendant' % (
            off, cls.name, '%X' % size if size is not None else '?')
    if r['status'] != 'ok':
        return None, None, None, r['reason']
    mem = r['member']
    path = mem.name + ((sub_path(m.resolve(mem.type), r['sub']) or '') if r['sub'] else '')
    return member_desc(mem, r['sub']), mem, path, None


def base_text_for_recommendation(u):
    inner = u.get('_inner')
    if inner is not None and inner.get('recommended', {}).get('cast') and inner['expression'] in u['base']:
        b = u['base'].replace(inner['expression'], inner['recommended']['cast'], 1)
        return b, (inner if b == inner['recommended']['cast'] else None)
    return u['base'], None


def resolve_use(u, depth=0):
    if u.get('_done'):
        return
    u['_done'] = True
    off = u['_off']
    # nested raw view as base?  B = [casts](VIEW(...)...)
    bt = strip_casts(u['_btoks'])
    inner = by_pos.get((u['_unit'], bt[0].idx)) if bt and bt[0].idx is not None else None
    if inner is not None and inner is not u:
        resolve_use(inner, depth + 1)
        u['_inner'] = inner
    if off is None:
        if 'resolution' not in u:
            u['resolution'] = 'unresolved'; u['reason'] = 'no byte offset'
        return
    cls = u['_cls']
    basis = 'declared type of base'
    if u.get('_varview'):
        basis = 'declared type of the expression assigned to the view variable'
    inferred_recommended = False
    if cls is None and inner is not None:
        fdesc = inner.get('field') if inner.get('resolution') == 'resolved' else (inner.get('recommended') or {}).get('field')
        ft = fdesc.get('type') if fdesc else None
        ftr = m.resolve(ft) if ft else None
        if ftr is not None and ftr.kind == 'class' and ftr.name.lower() != 'tobject':
            cls = ftr
            if inner.get('resolution') == 'resolved':
                basis = 'declared type of the field read by the inner view (%s.%s)' % (fdesc['class'], fdesc['name'])
            else:
                basis = 'declared type of the field the inner view reads under its run-time class hint (%s.%s)' % (fdesc['class'], fdesc['name'])
                inferred_recommended = True
            u['base_class_inferred'] = ftr.name
            u['inferred_from'] = 'inner view at %s:%s' % (inner['file'], inner['line'])
    hcls, why = runtime_class_of(u)
    btext, binner = base_text_for_recommendation(u)

    def rec_from(c, evidence):
        d, mem, path, reason = field_lookup(c, off)
        if d is None:
            return {'runtime_class': c.name, 'why': evidence, 'unresolved': reason}
        out = {'runtime_class': c.name, 'why': evidence, 'field': d, 'cast': '%s(%s).%s' % (c.name, btext, path)}
        if u.get('_varview'):
            out['retype_variable'] = '%s: %s' % (u['base'], c.name)
        if mem is not None:
            ok, note = accessible(mem, u['_unit'], c)
            if not ok:
                out['note'] = note
        return out

    if cls is None or inferred_recommended:
        u['resolution'] = 'unresolved'
        u['reason'] = 'untyped base: %s is typed %s' % (u['base'], u.get('base_untyped') or u.get('base_type'))
        if inferred_recommended:
            u['recommended'] = rec_from(cls, basis)
            # the inner recommendation already yields the field's declared class: no outer cast
            if 'cast' in u['recommended'] and binner is not None:
                u['recommended']['cast'] = u['recommended']['cast'].replace('%s(%s)' % (cls.name, btext), btext, 1)
        elif hcls is not None:
            u['recommended'] = rec_from(hcls, why)
        return
    d, mem, path, reason = field_lookup(cls, off)
    if d is None:
        u['resolution'] = 'unresolved'; u['reason'] = reason
        if hcls is not None:
            u['recommended'] = rec_from(hcls, why)
        return
    u['resolution'] = 'resolved'
    u['resolution_basis'] = basis
    u['field'] = d
    if 'base_class_inferred' in u:
        cast = '%s.%s' % (btext, path) if binner is not None else '%s(%s).%s' % (cls.name, btext, path)
    else:
        cast = '%s.%s' % (btext, path)
    u['recommended'] = {'cast': cast}
    if u.get('_varview'):
        u['recommended'] = {'retype_variable': '%s: %s' % (u['base'], cls.name), 'cast': '%s.%s' % (u['base'], path)}
    if mem is not None:
        ok, note = accessible(mem, u['_unit'], cls)
        if not ok:
            u['recommended']['note'] = note
    if hcls is not None:
        u['recommended']['runtime_class_hint'] = hcls.name


for u in uses:
    resolve_use(u)

def norm(n):
    n = n.lower()
    return n[1:] if n.startswith('f') and len(n) > 1 else n


by_line = collections.defaultdict(list)
for u in uses:
    by_line[(u['file'], u['line'])].append(u)
for u in uses:
    rec = u.get('recommended')
    if not rec or 'cast' not in rec:
        continue
    others = sorted((o for o in by_line[(u['file'], u['line'])] if o is not u and o.get('recommended', {}).get('cast')),
                    key=lambda o: -len(o['expression']))
    cast = rec['cast']
    for _ in range(4):
        before = cast
        for o in others:
            if o['expression'] in cast and o['expression'] not in u['expression'][:0]:
                cast = cast.replace(o['expression'], o['recommended']['cast'])
        if cast == before:
            break
    if cast != rec['cast']:
        rec['cast_raw'] = rec['cast']
        rec['cast'] = cast
for u in uses:
    f = u.get('field') or (u.get('recommended') or {}).get('field')
    if f and u.get('view_member') and norm(u['view_member']) != norm(f['name']) and not f.get('placeholder'):
        u['view_member_differs'] = '%s (view) vs %s.%s (source)' % (u['view_member'], f['class'], f['name'])

# hints that apply to a typed base whose offset lies beyond its class (TArmyHS.FArmy)
DEBUG = bool(os.environ.get('LV_DEBUG'))
debug_uses = [dict(u) for u in uses] if DEBUG else None
for u in uses:
    for kk in [x for x in u if x.startswith('_')]:
        del u[kk]

uses.sort(key=lambda u: (u['file'].lower(), u['line'], u['expression']))

# ------------------------------------------------------------ view type declarations
decls = []
not_views = []
seen = set()
use_count = collections.Counter((u['view_type'], u.get('view_type_declared_at')) for u in uses)
for lst in m.types.values():
    for ti in lst:
        if ti.kind == 'record' and is_view_record(ti):
            kind = 'fields-array' if fields_array(ti) else 'padding-record'
        elif is_view_class(ti):
            kind = 'view-class'
        else:
            continue
        key = (P.rel(ti.file), ti.line, ti.name)
        uc = use_count[(ti.name, '%s:%s' % key[:2])]
        if kind == 'padding-record' and uc == 0 and not re.search(r'(View|Fields|State|Flags)$', ti.name):
            if key not in seen:
                seen.add(key)
                not_views.append({'name': ti.name, 'file': key[0], 'line': ti.line,
                                  'why': 'record with Reserved/padding members but no use as a view over an object'})
            continue
        if key in seen:
            continue
        seen.add(key)
        if ti.kind == 'record':
            m.layout_record(ti)
            flds = [{'name': f.name, 'type': TE.tname(f.type), 'offset': fmt_off(f.off), 'size': f.size,
                     'comment_offset': fmt_off(f.comment_off)} for f in m.all_record_fields(ti)]
            size = ti.size
            packed = ti.packed
        else:
            m.layout_class(ti)
            flds = [{'name': f.name, 'type': TE.tname(f.type), 'offset': fmt_off(f.off), 'size': f.size,
                     'offset_source': f.off_src} for f in ti.fields]
            flds += [{'name': x.name, 'member_kind': x.kind} for x in ti.members if x.kind != 'field']
            size = ti.size
            packed = False
        decls.append({'name': ti.name, 'file': key[0], 'line': ti.line, 'kind': kind, 'packed': packed,
                      'section': 'implementation' if getattr(ti, 'impl', False) else 'interface',
                      'size': size, 'parent': getattr(ti, 'parent', None) if ti.kind == 'class' else None,
                      'uses': uc, 'fields': flds})
decls.sort(key=lambda d: (d['file'].lower(), d['line']))
not_views.sort(key=lambda d: (d['file'].lower(), d['line']))

summary = collections.Counter()
for u in uses:
    summary['%s/%s' % (u['kind'], u.get('resolution'))] += 1
out = {
    'generator': 'layout_views.py (tools/portdata), src root %s' % P.rel(P.SRC),
    'summary': dict(sorted(summary.items())),
    'uses': uses,
    'view_types': decls,
    'padding_records_not_views': not_views,
    'excluded_record_casts': sorted(excluded, key=lambda e: (e['file'].lower(), e['line'])),
    'layout_diagnostics': sorted(set(m.diag)),
}
json.dump(out, open(OUT, 'w', newline='\n'), indent=1, sort_keys=False)
print(json.dumps(out['summary'], indent=1))
print('uses', len(uses), 'view types', len(decls), collections.Counter(d['kind'] for d in decls),
      'unused', sum(1 for d in decls if not d['uses']), 'not views', len(not_views), 'excluded', len(excluded))
