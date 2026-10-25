"""Delphi 3 declaration model of src/delphi3 for layout-view surveys.

Lexes every unit with {$I} includes inlined, parses type/var/const sections,
class/record bodies (with offset comments), routine headers, locals and body
extents, computes record/class layouts, and types simple designators.
Deterministic: files are processed in sorted order; no time or randomness.
"""
import os, re, json, glob

ROOT = os.environ.get('AOW_ROOT', r'C:\git\int19h\aow')
SRC = os.path.join(ROOT, 'src', 'delphi3')
EXTS = ('.pas', '.inc', '.dpr', '.dpk')


def rel(p):
    return os.path.relpath(p, ROOT).replace('\\', '/')


# ---------------------------------------------------------------- lexer
class Tok:
    __slots__ = ('k', 'v', 'lv', 'f', 'ln', 'pos', 'idx')

    def __init__(s, k, v, f, ln, pos):
        s.k, s.v, s.f, s.ln, s.pos = k, v, f, ln, pos
        s.lv = v.lower()

    def __repr__(s):
        return '%s:%s' % (s.k, s.v)


SYMS = [':=', '..', '<=', '>=', '<>', '(.', '.)']
_inc_re = re.compile(r'^\{\$(?:I|INCLUDE)\s+([^}\s]+)\s*\}$', re.I)


def find_file(path):
    if os.path.exists(path):
        return path
    d, b = os.path.split(path)
    if os.path.isdir(d):
        for n in os.listdir(d):
            if n.lower() == b.lower():
                return os.path.join(d, n)
    return None


class Lexed:
    def __init__(s):
        s.toks = []
        s.comments = {}   # (file, line) -> [comment text]
        s.files = []
        s.texts = {}      # file -> list of lines


def lex_file(path, out, stack=()):
    path = os.path.normpath(path)
    out.files.append(path)
    txt = open(path, encoding='latin1').read()
    out.texts[path] = txt.split('\n')
    i, n, ln = 0, len(txt), 1
    while i < n:
        c = txt[i]
        if c == '\n':
            ln += 1; i += 1; continue
        if c in ' \t\r\f\x1a':
            i += 1; continue
        if c == '{':
            j = txt.find('}', i)
            j = n if j < 0 else j
            body = txt[i:j + 1]
            m = _inc_re.match(body)
            if m:
                inc = find_file(os.path.join(os.path.dirname(path), m.group(1)))
                if inc and inc not in stack:
                    lex_file(inc, out, stack + (path,))
            elif not body.startswith('{$'):
                out.comments.setdefault((path, ln), []).append((i, body[1:-1]))
            ln += body.count('\n'); i = j + 1; continue
        if txt.startswith('(*', i):
            j = txt.find('*)', i)
            j = n if j < 0 else j
            body = txt[i:j + 2]
            out.comments.setdefault((path, ln), []).append((i, body[2:-2]))
            ln += body.count('\n'); i = j + 2; continue
        if txt.startswith('//', i):
            j = txt.find('\n', i)
            j = n if j < 0 else j
            out.comments.setdefault((path, ln), []).append((i, txt[i + 2:j]))
            i = j; continue
        if c.isalpha() or c == '_':
            j = i
            while j < n and (txt[j].isalnum() or txt[j] == '_'):
                j += 1
            out.toks.append(Tok('id', txt[i:j], path, ln, i)); i = j; continue
        if c.isdigit() or (c == '$' and i + 1 < n and txt[i + 1] in '0123456789abcdefABCDEF'):
            j = i + 1
            if c == '$':
                while j < n and txt[j] in '0123456789abcdefABCDEF':
                    j += 1
            else:
                while j < n and txt[j].isdigit():
                    j += 1
                if j + 1 < n and txt[j] == '.' and txt[j + 1].isdigit():
                    j += 1
                    while j < n and (txt[j].isdigit() or txt[j] in 'eE'):
                        j += 1
            out.toks.append(Tok('num', txt[i:j], path, ln, i)); i = j; continue
        if c == "'" or c == '#':
            j = i
            while j < n and (txt[j] == "'" or txt[j] == '#'):
                if txt[j] == "'":
                    j += 1
                    while j < n:
                        if txt[j] == "'":
                            if j + 1 < n and txt[j + 1] == "'":
                                j += 2; continue
                            break
                        j += 1
                    j += 1
                else:
                    j += 1
                    if j < n and txt[j] == '$':
                        j += 1
                    while j < n and txt[j].isalnum():
                        j += 1
            out.toks.append(Tok('str', txt[i:j], path, ln, i)); i = j; continue
        two = txt[i:i + 2]
        if two in SYMS:
            v = {'(.': '[', '.)': ']'}.get(two, two)
            out.toks.append(Tok('sym', v, path, ln, i)); i += 2; continue
        out.toks.append(Tok('sym', c, path, ln, i)); i += 1


# ---------------------------------------------------------------- model
class TI:
    """Type info. kind: prim, enum, sub, set, ptr, class, classref, intf,
    record, array, sstr, proc, method, alias, file, ext, unknown."""
    _n = 0

    def __init__(s, kind, name=None, **kw):
        s.kind, s.name = kind, name
        s.file = s.line = s.unit = None
        s.__dict__.update(kw)
        TI._n += 1
        s.id = TI._n

    def __repr__(s):
        return '<%s %s>' % (s.kind, s.name)


PRIM = {
    'byte': (1, 1), 'shortint': (1, 1), 'char': (1, 1), 'ansichar': (1, 1), 'boolean': (1, 1),
    'bytebool': (1, 1), 'word': (2, 2), 'smallint': (2, 2), 'wordbool': (2, 2), 'widechar': (2, 2),
    'integer': (4, 4), 'longint': (4, 4), 'cardinal': (4, 4), 'longword': (4, 4), 'dword': (4, 4),
    'longbool': (4, 4), 'bool': (4, 4), 'single': (4, 4), 'pointer': (4, 4), 'string': (4, 4),
    'ansistring': (4, 4), 'pchar': (4, 4), 'widestring': (4, 4), 'tclass': (4, 4),
    'double': (8, 4), 'comp': (8, 4), 'currency': (8, 4), 'extended': (10, 4), 'real': (6, 2),
    'variant': (16, 4), 'olevariant': (16, 4), 'shortstring': (256, 1), 'hwnd': (4, 4),
    'thandle': (4, 4), 'hdc': (4, 4), 'hbitmap': (4, 4), 'hpalette': (4, 4), 'hfont': (4, 4),
    'hbrush': (4, 4), 'hpen': (4, 4), 'hicon': (4, 4), 'hcursor': (4, 4), 'hmenu': (4, 4),
    'hrgn': (4, 4), 'hinst': (4, 4), 'hmodule': (4, 4), 'tcolor': (4, 4), 'uint': (4, 4),
    'wparam': (4, 4), 'lparam': (4, 4), 'lresult': (4, 4), 'tdatetime': (8, 4), 'hresult': (4, 4),
    'colorref': (4, 4), 'tcursor': (2, 2), 'hglobal': (4, 4), 'hkey': (4, 4), 'pinteger': (4, 4),
    'tnotifyevent': (8, 4), 'tmodalresult': (4, 4), 'tcaption': (4, 4), 'thelpcontext': (4, 4),
    'tshortcut': (2, 2), 'tfilename': (4, 4), 'tbytearray': (32768, 1), 'tthreadmethod': (8, 4),
    'tshiftstate': (1, 1), 'tmousebutton': (1, 1), 'talign': (1, 1), 'tfontstyles': (1, 1),
    'tborderstyle': (1, 1), 'tformborderstyle': (1, 1), 'tpencolor': (4, 4), 'tkeyevent': (8, 4),
    'tmouseevent': (8, 4), 'tmousemoveevent': (8, 4), 'tkeypressevent': (8, 4),
    'tdrawitemevent': (8, 4), 'tmeasureitemevent': (8, 4), 'tcloseevent': (8, 4),
    'tclosequeryevent': (8, 4), 'tcontrolstate': (2, 2), 'tcontrolstyle': (2, 2),
    'tcomponentstate': (2, 2), 'trtlcriticalsection': (24, 4), 'tlargeinteger': (8, 4),
    'int64': (8, 4),
}
# well-known external records (VCL/RTL/Windows) by size
EXTREC = {'trect': (16, 4), 'tpoint': (8, 4), 'tsize': (8, 4), 'tsmallpoint': (4, 2),
          'trgbquad': (4, 1), 'tpaletteentry': (4, 1), 'tbitmapinfoheader': (40, 4),
          'tmessage': (16, 4), 'tsearchrec': (296, 4), 'tsystemtime': (16, 2),
          'tfiletime': (8, 4), 'tguid': (16, 4), 'tvardata': (16, 4), 'tmsg': (28, 4),
          'tlogfont': (60, 4), 'ttextmetric': (53, 4), 'tlogpalette': (8, 2),
          'trgbtriple': (3, 1), 'tbitmapinfo': (44, 4), 'tmethod': (8, 4),
          'twindowplacement': (44, 4), 'twaveformatex': (18, 1), 'tpcmwaveformat': (16, 1),
          'teditcharcase': (1, 1)}


class Member:
    __slots__ = ('kind', 'name', 'type', 'off', 'off_src', 'vis', 'file', 'line', 'size',
                 'indexed', 'is_default', 'cls', 'comment_off', 'computed_off', 'tag', 'arms', 'owner')

    def __init__(s, **kw):
        for k in s.__slots__:
            setattr(s, k, kw.get(k))


class Routine:
    def __init__(s, name, cls, file, line):
        s.name, s.cls, s.file, s.line = name, cls, file, line
        s.params = {}   # lname -> (name, typeexpr)
        s.locals = {}
        s.result = None
        s.start = s.end = None   # token indices of whole routine
        s.end_line = None
        s.parent = None
        s.withs = []    # (tok_start, tok_end, expr tokens)
        s.unit = None


DIRECTIVES = {'virtual', 'abstract', 'override', 'dynamic', 'message', 'reintroduce', 'overload',
              'stdcall', 'cdecl', 'register', 'safecall', 'pascal', 'assembler', 'forward',
              'external', 'export', 'far', 'near', 'resident', 'default', 'dispid', 'inline'}
SECTION_END = {'type', 'var', 'const', 'resourcestring', 'threadvar', 'procedure', 'function',
               'constructor', 'destructor', 'implementation', 'interface', 'begin', 'initialization',
               'finalization', 'end', 'uses', 'exports', 'label', 'asm', 'contains', 'requires',
               'property', 'private', 'protected', 'public', 'published', 'class'}


class Model:
    def __init__(s):
        s.units = {}        # unit lname -> Lexed (top file)
        s.unit_of_file = {} # file -> unit lname
        s.types = {}        # lname -> [TI]
        s.globals = {}      # lname -> [(name, typeexpr|TI, unit, file, line, kind)]
        s.consts = {}       # lname -> [(tokens, unit)]
        s.typedconsts = []  # (name, typeTI, init tokens, unit, file, line)
        s.absolutes = []
        s.funcs = {}        # lname -> [(result typeexpr, unit)]
        s.routines = []     # implementation routines
        s.cj = {}
        s.diag = []
        cjp = os.path.join(ROOT, 'data', 'classes.json')
        if os.path.exists(cjp):
            s.cj = json.load(open(cjp))['classes']
        s.cjl = {k.lower(): k for k in s.cj}

    # ------------------------------------------------------------ loading
    def load(s):
        files = sorted(f for e in EXTS for f in glob.glob(os.path.join(SRC, '**', '*' + e), recursive=True))
        files = sorted(set(os.path.normpath(f) for f in files), key=lambda p: p.lower())
        included = set()
        lexed = {}
        for f in files:
            L = Lexed()
            lex_file(f, L)
            lexed[f] = L
            included.update(L.files[1:])
        for f in files:
            if f in included:
                continue
            L = lexed[f]
            uname = os.path.splitext(os.path.basename(f))[0].lower()
            key = uname
            if key in s.units:   # same unit name in several dirs: qualify
                key = rel(f).lower()
            for t in L.toks:
                t.idx = None
            for k, t in enumerate(L.toks):
                t.idx = k
            L.unit = key
            L.top = f
            s.units[key] = L
            for g in L.files:
                s.unit_of_file.setdefault(g, key)
        for key in sorted(s.units):
            P = Parser(s, s.units[key])
            P.parse_unit()

    def add_type(s, ti):
        s.types.setdefault(ti.name.lower(), []).append(ti)

    # ------------------------------------------------------------ lookup
    def lookup_type(s, name, unit=None):
        if name is None:
            return None
        ln = name.lower()
        if '.' in ln:
            u, _, nm = ln.rpartition('.')
            lst = [t for t in s.types.get(nm, []) if t.unit == u or (t.unit or '').endswith(u)]
            if lst:
                return s._best(lst)
            ln = nm
        lst = s.types.get(ln, [])
        if not lst:
            return None
        if unit:
            mine = [t for t in lst if t.unit == unit]
            if mine:
                return s._best(mine)
            vis = [t for t in lst if not getattr(t, 'impl', False)]
            if vis:
                return s._best(vis)
        return s._best(lst)

    def _best(s, lst):
        full = [t for t in lst if not getattr(t, 'forward', False)]
        lst = full or lst
        def rank(t):
            mt = 1 if 'matchtest' in (t.file or '').lower() or '/hosts/' in rel(t.file or '').lower() else 0
            imp = 1 if '/imports/' in rel(t.file or '').lower() else 0
            return (mt, imp, rel(t.file or ''), t.line or 0)
        return sorted(lst, key=rank)[0]

    def resolve(s, t, unit=None, depth=0):
        """follow aliases; returns TI or ext/unknown TI"""
        if t is None or depth > 30:
            return None
        if isinstance(t, str):
            ln = t.lower().split('.')[-1]
            u = unit
            found = s.lookup_type(t, unit)
            if found is None:
                if ln == 'tobject':
                    return TI('class', 'TObject', ext=True, parent=None)
                if ln in PRIM:
                    return TI('prim', ln, size=PRIM[ln][0], align=PRIM[ln][1])
                if ln in EXTREC:
                    return TI('ext', ln, size=EXTREC[ln][0], align=EXTREC[ln][1], extkind='record')
                if ln in s.cjl:
                    return TI('class', s.cjl[ln], ext=True, parent=s.cj[s.cjl[ln]].get('parent'))
                nm = t.split('.')[-1]
                if len(nm) > 1 and nm[0] in 'P' and nm[1].isupper():
                    return TI('ptr', nm, target=None, ext=True)
                if nm.endswith('Event') and nm[0] == 'T':
                    return TI('method', nm, ext=True)
                return TI('unknown', t)
            t = found
        if t.kind == 'alias':
            r = s.resolve(t.target, t.unit or unit, depth + 1)
            return r
        return t

    # ------------------------------------------------------------ layout
    def const_eval(s, toks, unit):
        expr = ''
        for t in toks:
            if t.k == 'num':
                expr += str(int(t.v[1:], 16) if t.v.startswith('$') else (int(t.v) if t.v.isdigit() else 0))
            elif t.k == 'str':
                v = t.v
                if v.startswith('#'):
                    expr += str(int(v[2:], 16) if v[1] == '$' else int(v[1:]))
                elif len(v) == 3:
                    expr += str(ord(v[1]))
                else:
                    return None
            elif t.k == 'id':
                lv = t.lv
                ops = {'div': '//', 'mod': '%', 'shl': '<<', 'shr': '>>', 'and': '&', 'or': '|', 'xor': '^'}
                if lv in ops:
                    expr += ops[lv]
                elif lv in ('ord', 'integer', 'byte', 'longint'):
                    expr += ''
                elif lv in ('true',):
                    expr += '1'
                elif lv in ('false',):
                    expr += '0'
                else:
                    v = s.const_value(t.v, unit)
                    if v is None:
                        return None
                    expr += str(v)
            elif t.k == 'sym' and t.v in '+-*()':
                expr += t.v
            else:
                return None
        try:
            return int(eval(expr, {'__builtins__': {}}))
        except Exception:
            return None

    def const_value(s, name, unit):
        ln = name.lower()
        lst = s.consts.get(ln)
        if lst:
            mine = [c for c in lst if c[1] == unit] or lst
            v = s.const_eval(mine[0][0], mine[0][1])
            if v is not None:
                return v
        # enum member ordinal
        e = s.enum_members.get(ln) if hasattr(s, 'enum_members') else None
        if e is not None:
            return e
        return None

    def ordinal_range(s, ti, unit):
        ti = s.resolve(ti, unit)
        if ti is None:
            return None
        if ti.kind == 'enum':
            return (0, len(ti.members) - 1)
        if ti.kind == 'sub':
            lo = s.const_eval(ti.lo, ti.unit or unit)
            hi = s.const_eval(ti.hi, ti.unit or unit)
            if lo is None or hi is None:
                return None
            return (lo, hi)
        if ti.kind == 'prim':
            return {'byte': (0, 255), 'char': (0, 255), 'ansichar': (0, 255), 'boolean': (0, 1),
                    'shortint': (-128, 127), 'word': (0, 65535), 'smallint': (-32768, 32767)}.get(ti.name)
        return None

    def size_align(s, ti, unit=None, depth=0):
        """(size, align) or (None, None)"""
        if depth > 40:
            return (None, None)
        ti = s.resolve(ti, unit)
        if ti is None:
            return (None, None)
        k = ti.kind
        if hasattr(ti, '_sa'):
            return ti._sa
        r = (None, None)
        if k in ('prim', 'ext'):
            r = (ti.size, ti.align)
        elif k == 'enum':
            n = len(ti.members)
            r = (1, 1) if n <= 256 else ((2, 2) if n <= 65536 else (4, 4))
        elif k == 'sub':
            rg = s.ordinal_range(ti, unit)
            if rg is None:
                r = (None, None)
            else:
                lo, hi = rg
                if -128 <= lo and hi <= 255:
                    r = (1, 1)
                elif -32768 <= lo and hi <= 65535:
                    r = (2, 2)
                else:
                    r = (4, 4)
        elif k == 'set':
            rg = s.ordinal_range(ti.base, ti.unit or unit)
            if rg is None:
                r = (None, None)
            else:
                lo, hi = rg
                n = hi // 8 - lo // 8 + 1
                if n == 3:
                    n = 4
                r = (n, n if n in (1, 2, 4) else 1)
        elif k in ('ptr', 'class', 'classref', 'intf', 'proc'):
            r = (4, 4)
        elif k == 'method':
            r = (8, 4)
        elif k == 'sstr':
            r = (ti.n + 1, 1)
        elif k == 'file':
            r = (None, None)
        elif k == 'array':
            es, ea = s.size_align(ti.elem, ti.unit or unit, depth + 1)
            cnt = 1
            for idx in ti.dims:
                if isinstance(idx, tuple):
                    lo = s.const_eval(idx[0], ti.unit or unit)
                    hi = s.const_eval(idx[1], ti.unit or unit)
                    if lo is None or hi is None:
                        cnt = None; break
                    cnt *= hi - lo + 1
                else:
                    rg = s.ordinal_range(idx, ti.unit or unit)
                    if rg is None:
                        cnt = None; break
                    cnt *= rg[1] - rg[0] + 1
            if es is None or cnt is None:
                r = (None, None)
            else:
                r = (es * cnt, 1 if ti.packed else ea)
        elif k == 'record':
            s.layout_record(ti)
            r = (ti.size, ti.align)
        ti._sa = r
        return r

    def first_lo(s, ti, unit):
        """lower bound of first array dimension"""
        idx = ti.dims[0]
        if isinstance(idx, tuple):
            return s.const_eval(idx[0], ti.unit or unit)
        rg = s.ordinal_range(idx, ti.unit or unit)
        return rg[0] if rg else None

    def _layout_fields(s, flist, start, packed, unit, owner):
        off = start
        maxal = 1
        for f in flist:
            if f.kind == 'variant':
                vstart = off
                if f.tag is not None:
                    ts, ta = s.size_align(f.tag.type, unit)
                    if ts is None:
                        return None, maxal
                    al = 1 if packed else ta
                    vstart = (vstart + al - 1) // al * al
                    f.tag.off = vstart; f.tag.size = ts
                    vstart += ts
                    maxal = max(maxal, al)
                end = vstart
                for arm in f.arms:
                    e, al = s._layout_fields(arm, vstart, packed, unit, owner)
                    if e is None:
                        return None, maxal
                    end = max(end, e); maxal = max(maxal, al)
                off = end
                continue
            sz, al = s.size_align(f.type, unit)
            if sz is None:
                f.off = None
                return None, maxal
            al = 1 if packed else min(al, 4)
            maxal = max(maxal, al)
            off = (off + al - 1) // al * al
            f.computed_off = off
            f.off = off
            f.size = sz
            if f.comment_off is not None and f.comment_off != off:
                s.diag.append('record %s.%s: comment $%X computed $%X (%s:%s)' % (
                    owner.name, f.name, f.comment_off, off, rel(f.file), f.line))
            off += sz
        return off, maxal

    def layout_record(s, ti):
        if getattr(ti, '_laid', False):
            return
        ti._laid = True
        end, al = s._layout_fields(ti.fields, 0, ti.packed, ti.unit, ti)
        if end is None:
            ti.size = ti.align = None
            return
        if ti.packed:
            al = 1
        ti.size = (end + al - 1) // al * al
        ti.align = al

    def all_record_fields(s, ti):
        out = []
        def walk(fl):
            for f in fl:
                if f.kind == 'variant':
                    if f.tag is not None:
                        out.append(f.tag)
                    for a in f.arms:
                        walk(a)
                else:
                    out.append(f)
        walk(ti.fields)
        return out

    def cj_entry(s, ti):
        """classes.json entry for this class when its module matches the source package"""
        if ti is None or not ti.name or ti.name.lower() not in s.cjl:
            return None
        e = s.cj[s.cjl[ti.name.lower()]]
        if getattr(ti, 'ext', False) or not ti.file:
            return e
        parts = rel(ti.file).split('/')[2:]
        if parts and parts[0].lower() == 'imports':
            parts = parts[1:]
        pkg = parts[0].lower() if len(parts) > 1 else 'enginep'
        mod = os.path.splitext(e.get('module', ''))[0].lower()
        alias = {'aowint': 'aowinterface'}
        if mod in (pkg, alias.get(pkg, pkg)) or len(parts) <= 1:
            return e
        return None

    def class_size(s, ti):
        """instance size: classes.json when known, else computed"""
        if ti is None:
            return None
        name = ti.name
        e = s.cj_entry(ti)
        if e is not None and e.get('size') is not None:
            return e.get('size')
        if ti.kind == 'class' and not getattr(ti, 'ext', False):
            s.layout_class(ti)
            return ti.size
        if name and name.lower() == 'tobject':
            return 4
        return None

    def parent_of(s, ti):
        if ti is None:
            return None
        if getattr(ti, 'ext', False):
            p = ti.parent
        else:
            p = ti.parent
            if p is None and ti.name.lower() != 'tobject':
                p = 'TObject'
        if p is None:
            return None
        r = s.resolve(p, ti.unit)
        if r is None or r.kind != 'class':
            if p and p.lower() in s.cjl:
                return TI('class', s.cjl[p.lower()], ext=True, parent=s.cj[s.cjl[p.lower()]].get('parent'))
            if p and p.lower() == 'tobject':
                return TI('class', 'TObject', ext=True, parent=None)
            return None
        return r

    def chain(s, ti):
        out, seen = [], set()
        while ti is not None and ti.name.lower() not in seen:
            seen.add(ti.name.lower()); out.append(ti)
            ti = s.parent_of(ti)
        return out

    def layout_class(s, ti):
        if getattr(ti, '_laid', False) or getattr(ti, 'ext', False):
            return
        ti._laid = True
        par = s.parent_of(ti)
        if par is None:
            start = 4 if ti.name.lower() != 'tobject' else 0
        else:
            if not getattr(par, 'ext', False):
                s.layout_class(par)
            start = s.class_size(par)
        cur = start
        ti.start = start
        for val, grp in getattr(ti, 'line_groups', []):
            if any(g.comment_off is not None and not g.name.startswith('F_') for g in grp):
                continue
            # simulate from the first group member using comments seen so far
            pos = None
            c2 = start
            chosen = None
            for f in ti.fields:
                sz, al = s.size_align(f.type, ti.unit)
                if c2 is None or sz is None:
                    c2 = None
                else:
                    a = min(al, 4)
                    o = f.comment_off if f.comment_off is not None else (c2 + a - 1) // a * a
                    if f in grp and o == val and chosen is None:
                        chosen = f
                    c2 = o + sz
                if f is grp[-1]:
                    break
            (chosen or grp[-1]).comment_off = val
        for f in ti.fields:
            sz, al = s.size_align(f.type, ti.unit)
            f.size = sz
            comp = None
            if cur is not None and sz is not None:
                a = min(al, 4)
                comp = (cur + a - 1) // a * a
            f.computed_off = comp
            if f.comment_off is not None:
                f.off, f.off_src = f.comment_off, 'comment'
                if comp is not None and comp != f.comment_off:
                    s.diag.append('class %s.%s: comment $%X computed $%X (%s:%s)' % (
                        ti.name, f.name, f.comment_off, comp, rel(f.file), f.line))
            elif comp is not None:
                f.off, f.off_src = comp, 'computed'
            else:
                f.off, f.off_src = None, None
            cur = f.off + sz if (f.off is not None and sz is not None) else None
        ti.size = ((cur + 3) // 4 * 4) if cur is not None else None
        e = s.cj_entry(ti)
        if ti.size is not None and e is not None:
            want = e.get('size')
            if want is not None and want != ti.size and ti.fields:
                s.diag.append('class %s: computed size $%X, classes.json $%X (%s:%s)' % (
                    ti.name, ti.size, want, rel(ti.file), ti.line))
            ti.size_mismatch = (want is not None and want != ti.size)

    def field_at(s, cls, off):
        """walk class chain; return dict describing the field covering off"""
        for c in s.chain(cls):
            if getattr(c, 'ext', False):
                size = s.class_size(c)
                if size is not None and off < size:
                    return {'status': 'external', 'class': c.name,
                            'reason': 'offset $%X lies inside %s (instance size $%X), which has no recovered source declaration' % (off, c.name, size)}
                continue
            s.layout_class(c)
            for f in c.fields:
                if f.off is None or f.size is None:
                    continue
                if f.off <= off < f.off + f.size:
                    return {'status': 'ok', 'class': c.name, 'member': f, 'sub': off - f.off}
            if c.start is not None and off >= c.start and (c.size is None or off < c.size):
                return {'status': 'gap', 'class': c.name,
                        'reason': 'offset $%X falls in %s range [$%X,$%X) but no field with a known offset covers it' % (off, c.name, c.start, c.size or 0)}
        return None

    def find_member(s, ti, name):
        """field/property/method of class (walk parents) or record"""
        ln = name.lower()
        ti = s.resolve(ti)
        if ti is None:
            return None
        if ti.kind == 'ptr':
            tgt = s.resolve(ti.target, ti.unit)
            if tgt is not None and tgt.kind == 'record':
                ti = tgt
        if ti.kind == 'record':
            for f in s.all_record_fields(ti):
                if f.name.lower() == ln:
                    return f
            return None
        if ti.kind not in ('class',):
            return None
        for c in s.chain(ti):
            if getattr(c, 'ext', False):
                continue
            for m in c.members_by_name.get(ln, []):
                if m.kind == 'property' and m.type is None:
                    continue   # redeclaration; keep walking
                return m
        return None

    def default_prop(s, ti):
        ti = s.resolve(ti)
        if ti is None or ti.kind != 'class':
            return None
        for c in s.chain(ti):
            if getattr(c, 'ext', False):
                continue
            for m in c.members:
                if m.kind == 'property' and m.is_default:
                    return m
        return None


def is_persistent(model, ti):
    return any(c.name.lower() == 'tpersistent' for c in model.chain(ti))


# ---------------------------------------------------------------- parser
class Parser:
    def __init__(s, model, L):
        s.m, s.L, s.t = model, L, L.toks
        s.unit = L.unit
        s.i = 0
        s.impl = False

    def peek(s, k=0):
        j = s.i + k
        return s.t[j] if j < len(s.t) else None

    def lv(s, k=0):
        t = s.peek(k)
        return t.lv if t else None

    def v(s, k=0):
        t = s.peek(k)
        return t.v if t else None

    def adv(s):
        t = s.t[s.i]; s.i += 1; return t

    def accept(s, v):
        if s.lv() == v:
            s.i += 1; return True
        return False

    def offset_comment(s, k):
        """offsets in the comment directly after token index k (same line, before the next
        token): list of ints for '$A', '$A, $B, ...' (leading part before ';'); [] if none
        or if it is a range '$A..$B'"""
        if k is None or k >= len(s.t):
            return []
        tok = s.t[k]
        nxt = s.t[k + 1] if k + 1 < len(s.t) else None
        for pos, c in s.L.comments.get((tok.f, tok.ln), []):
            if pos <= tok.pos:
                continue
            if nxt is not None and nxt.f == tok.f and pos > nxt.pos:
                continue
            head = c.split(';')[0].strip()
            if not re.match(r'^\+?\$[0-9A-Fa-f]+\b', head):
                continue
            if '..' in head:
                return []
            parts = [x.strip() for x in head.split(',')]
            vals = []
            for x in parts:
                mm = re.match(r'^\+?\$([0-9A-Fa-f]+)\b', x)
                if not mm:
                    break
                vals.append(int(mm.group(1), 16))
            return vals
        return []

    def assign_comments(s, names, semi, line_fields):
        """offset per declared name: single offset -> first name; N offsets -> the N names
        of this statement, or the N fields declared on this source line"""
        vals = s.offset_comment(semi)
        out = {}
        lf = line_fields.get((names[-1].f, names[-1].ln), [])
        cur = set((nt.v, nt.ln) for nt in names)
        prior = [f for f in lf if (f.name, f.line) not in cur]
        if len(vals) == 1 and prior:
            # one trailing comment after several statements on a line: it names the offset of
            # one field on the line; the layout picks the field whose computed offset agrees,
            # else the last statement's field
            out[id(names[0])] = ('group', vals[0], prior)
        elif len(vals) == 1:
            out[id(names[0])] = vals[0]
        elif len(vals) > 1:
            if len(vals) == len(names):
                for nt, v in zip(names, vals):
                    out[id(nt)] = v
            else:
                lf = line_fields.get((names[-1].f, names[-1].ln), [])
                if len(vals) == len(lf):
                    for mem, v in zip(lf, vals):
                        if mem.comment_off is None or mem.name.startswith('F_'):
                            mem.comment_off = v
        return out

    def skip_to_semicolon(s):
        d = 0
        while s.i < len(s.t):
            t = s.adv()
            if t.v in ('(', '['):
                d += 1
            elif t.v in (')', ']'):
                d -= 1
            elif t.v == ';' and d <= 0:
                return

    # ---------------------------------------------------- top level
    def parse_unit(s):
        mode = None
        impl = False
        n = len(s.t)
        while s.i < n:
            t = s.peek(); lv = t.lv
            if t.k == 'id':
                if lv in ('unit', 'program', 'library', 'package', 'uses', 'contains', 'requires', 'exports', 'label'):
                    s.skip_to_semicolon(); mode = None; continue
                if lv == 'interface':
                    s.i += 1; mode = None; continue
                if lv == 'implementation':
                    s.i += 1; mode = None; impl = True; s.impl = True; continue
                if lv == 'type':
                    s.i += 1; mode = 'type'; continue
                if lv in ('var', 'threadvar'):
                    s.i += 1; mode = 'var'; continue
                if lv in ('const', 'resourcestring'):
                    s.i += 1; mode = 'const' if lv == 'const' else 'rstr'; continue
                if lv in ('procedure', 'function', 'constructor', 'destructor') or (
                        lv == 'class' and s.lv(1) in ('procedure', 'function')):
                    mode = None
                    s.parse_routine(None, impl)
                    continue
                if lv in ('begin', 'initialization', 'finalization'):
                    # main block: treat as routine body for scanning purposes
                    r = Routine('<main>', None, t.f, t.ln); r.unit = s.unit
                    r.start = s.i
                    s.skip_block_to_end(main=True)
                    r.end = s.i; r.end_line = s.t[s.i - 1].ln if s.i else t.ln
                    s.m.routines.append(r)
                    mode = None; continue
                if mode == 'type' and s.v(1) == '=':
                    s.parse_type_decl(); continue
                if mode == 'var' and s.v(1) in (',', ':'):
                    s.parse_var_decl(s.m.globals, kind='var'); continue
                if mode in ('const', 'rstr') and s.v(1) in ('=', ':'):
                    s.parse_const_decl(mode); continue
            s.i += 1

    def skip_block_to_end(s, main=False):
        d = 0
        while s.i < len(s.t):
            t = s.adv(); lv = t.lv
            if t.k != 'id':
                continue
            if lv in ('begin', 'case', 'try', 'asm', 'initialization') and not (lv == 'initialization' and d > 0):
                if lv == 'initialization':
                    d = max(d, 1); continue
                d += 1
            elif lv == 'record':
                d += 1
            elif lv == 'finalization':
                continue
            elif lv == 'end':
                d -= 1
                if d <= 0:
                    if s.lv() in (';', '.'):
                        s.i += 1
                    return

    # ---------------------------------------------------- declarations
    def parse_type_decl(s):
        nt = s.adv(); s.adv()  # name '='
        ti = s.parse_type(nt.v, nt)
        if ti is None:
            return
        if ti.name is None or ti.name != nt.v:
            if ti.kind in ('alias',) or ti.name is None:
                ti.name = nt.v
            else:
                ti = TI('alias', nt.v, target=ti)
        ti.file, ti.line, ti.unit = nt.f, nt.ln, s.unit
        ti.impl = s.impl
        s.m.add_type(ti)
        # trailing ; and calling conventions
        while s.lv() == ';':
            s.i += 1
            if s.lv() in ('stdcall', 'cdecl', 'register', 'pascal', 'safecall', 'far'):
                s.i += 1; continue
            break

    def type_tokens_until(s, stops):
        start = s.i; d = 0
        while s.i < len(s.t):
            t = s.peek()
            if d == 0 and (t.v in stops or t.lv in stops):
                break
            if t.v in ('(', '['):
                d += 1
            elif t.v in (')', ']'):
                if d == 0:
                    break
                d -= 1
            s.i += 1
        return s.t[start:s.i]

    def parse_type(s, name=None, ntok=None, stops=(';',)):
        packed = False
        if s.lv() == 'packed':
            packed = True; s.i += 1
        lv = s.lv()
        if lv == 'class' or lv == 'object':
            s.i += 1
            if s.lv() == 'of':
                s.i += 1
                tgt = s.adv().v
                while s.v() == '.':
                    s.i += 1; tgt = s.adv().v
                return TI('classref', name, target=tgt)
            parents = []
            if s.v() == '(':
                s.i += 1
                while s.v() != ')':
                    t = s.adv()
                    if t.k == 'id':
                        if parents and s.t[s.i - 2].v == '.':
                            parents[-1] = t.v
                        else:
                            parents.append(t.v)
                s.i += 1
            ti = TI('class', name, parent=parents[0] if parents else None, fields=[], members=[],
                    members_by_name={}, packed=False)
            ti.file, ti.line, ti.unit = ntok.f, ntok.ln, s.unit
            if s.v() == ';':
                if not parents:
                    ti.forward = True
                return ti
            s.parse_class_body(ti)
            return ti
        if lv in ('interface', 'dispinterface'):
            s.i += 1
            if s.v() == ';':
                return TI('intf', name, forward=True)
            if s.v() == '(':
                s.i += 1; s.type_tokens_until((')',)); s.i += 1
            if s.v() == '[':
                s.i += 1; s.type_tokens_until((']',)); s.i += 1
            s.skip_to_end_kw()
            return TI('intf', name)
        if lv == 'record':
            s.i += 1
            ti = TI('record', name, packed=packed, fields=[])
            ti.unit = s.unit
            if ntok is not None:
                ti.file, ti.line = ntok.f, ntok.ln
            ti.fields = s.parse_field_list(('end',), ti)
            s.accept('end')
            return ti
        if s.v() == '(':
            s.i += 1
            mem = []
            while s.v() != ')':
                t = s.adv()
                if t.k == 'id':
                    mem.append(t.v)
                elif t.v == '=':
                    s.type_tokens_until((',', ')'))
            s.i += 1
            ti = TI('enum', name, members=mem)
            if not hasattr(s.m, 'enum_members'):
                s.m.enum_members = {}
            for k, mname in enumerate(mem):
                s.m.enum_members.setdefault(mname.lower(), k)
            return ti
        if lv == 'set':
            s.i += 2  # set of
            base = s.parse_type(None, ntok, stops)
            return TI('set', name, base=base, unit=s.unit)
        if s.v() == '^':
            s.i += 1
            tgt = s.adv().v
            while s.v() == '.':
                s.i += 1; tgt = s.adv().v
            return TI('ptr', name, target=tgt, unit=s.unit)
        if lv == 'array':
            s.i += 1
            dims = []
            if s.v() == '[':
                s.i += 1
                while True:
                    toks = s.type_tokens_until((',', ']'))
                    dims.append(s.dim_of(toks))
                    if s.v() == ',':
                        s.i += 1; continue
                    break
                s.i += 1
            s.accept('of')
            if s.lv() == 'const':
                s.i += 1
                return TI('array', name, dims=[], elem='pointer', packed=packed, open=True, unit=s.unit)
            elem = s.parse_type(None, ntok, stops)
            ti = TI('array', name, dims=dims, elem=elem, packed=packed, unit=s.unit)
            if not dims:
                ti.open = True
            return ti
        if lv == 'string' and s.v(1) == '[':
            s.i += 2
            toks = s.type_tokens_until((']',)); s.i += 1
            n = s.m.const_eval(toks, s.unit)
            return TI('sstr', name, n=n if n is not None else 255)
        if lv in ('procedure', 'function'):
            s.i += 1
            if s.v() == '(':
                s.i += 1
                s.type_tokens_until((')',)); s.i += 1
            res = None
            if s.v() == ':':
                s.i += 1
                res = s.adv().v
            if s.lv() == 'of':
                s.i += 2
                return TI('method', name, result=res)
            return TI('proc', name, result=res)
        if lv == 'file':
            s.i += 1
            if s.lv() == 'of':
                s.i += 1; s.parse_type(None, ntok, stops)
            return TI('file', name)
        if lv == 'type':
            s.i += 1
            return s.parse_type(name, ntok, stops)
        # alias or subrange
        toks = s.type_tokens_until(tuple(stops) + (';', 'end', 'read', 'write', 'absolute', '='))
        if any(t.v == '..' for t in toks):
            k = [j for j, t in enumerate(toks) if t.v == '..'][0]
            ti = TI('sub', name, lo=toks[:k], hi=toks[k + 1:], unit=s.unit)
            # enum subrange: size 1 even when not evaluable numerically
            return ti
        ids = [t.v for t in toks if t.k == 'id']
        if not ids:
            return TI('unknown', name)
        tgt = '.'.join(ids) if len(ids) > 1 and all(t.k == 'id' or t.v == '.' for t in toks) else ids[-1]
        return TI('alias', name, target=tgt, unit=s.unit)

    def dim_of(s, toks):
        if any(t.v == '..' for t in toks):
            k = [j for j, t in enumerate(toks) if t.v == '..'][0]
            return (toks[:k], toks[k + 1:])
        ids = [t.v for t in toks if t.k == 'id']
        return ids[-1] if ids else 'byte'

    def skip_to_end_kw(s):
        d = 1
        while s.i < len(s.t):
            t = s.adv()
            if t.lv in ('record', 'case') and t.k == 'id':
                if t.lv == 'record':
                    d += 1
            elif t.lv == 'end':
                d -= 1
                if d == 0:
                    return

    def parse_field_list(s, stops, owner):
        out = []
        while s.i < len(s.t):
            lv = s.lv()
            if lv in stops or s.v() == ')':
                break
            if s.v() == ';':
                s.i += 1; continue
            if lv == 'case':
                s.i += 1
                tag = None
                if s.v(1) == ':':
                    nt = s.adv(); s.i += 1
                    ty = s.parse_type(None, nt, ('of',))
                    tag = Member(kind='field', name=nt.v, type=ty, file=nt.f, line=nt.ln)
                else:
                    s.type_tokens_until(('of',))
                s.accept('of')
                arms = []
                while s.i < len(s.t) and s.lv() not in stops:
                    s.type_tokens_until((':',)); s.i += 1   # labels
                    if s.v() == '(':
                        s.i += 1
                        arms.append(s.parse_field_list((')',), owner))
                        if s.v() == ')':
                            s.i += 1
                    if s.v() == ';':
                        s.i += 1
                v = Member(kind='variant', name='<case>')
                v.tag = tag; v.arms = arms
                out.append(v)
                continue
            if s.peek().k != 'id':
                s.i += 1; continue
            names = []
            while True:
                t = s.adv(); names.append(t)
                if s.v() == ',':
                    s.i += 1; continue
                break
            if s.v() != ':':
                continue
            s.i += 1
            ty = s.parse_type(None, names[-1], (';', 'end', ')'))
            semi = s.i if s.v() == ';' else s.i - 1
            line_fields = {}
            for f in out:
                line_fields.setdefault((f.file, f.line), []).append(f)
            cm = s.assign_comments(names, semi, line_fields)
            for nt in names:
                c = cm.get(id(nt))
                if isinstance(c, tuple):
                    c = c[1]
                out.append(Member(kind='field', name=nt.v, type=ty, file=nt.f, line=nt.ln, comment_off=c))
            if s.v() == ';':
                s.i += 1
        return out

    def parse_class_body(s, ti):
        vis = None
        while s.i < len(s.t):
            t = s.peek(); lv = t.lv
            if lv == 'end':
                s.i += 1; return
            if lv in ('private', 'protected', 'public', 'published', 'automated') and t.k == 'id':
                vis = lv; s.i += 1; continue
            if lv == 'property':
                s.i += 1
                nt = s.adv()
                indexed = False
                ptype = None
                if s.v() == '[':
                    indexed = True
                    s.i += 1; s.type_tokens_until((']',)); s.i += 1
                if s.v() == ':':
                    s.i += 1
                    ids = []
                    while s.peek().k == 'id' or s.v() == '.':
                        if s.peek().lv in ('read', 'write', 'index', 'default', 'stored', 'nodefault', 'implements'):
                            break
                        if s.peek().k == 'id':
                            ids.append(s.peek().v)
                        s.i += 1
                    ptype = ids[-1] if ids else None
                s.skip_to_semicolon()
                isdef = False
                if s.lv() == 'default' and s.v(1) == ';':
                    isdef = True; s.i += 2
                m = Member(kind='property', name=nt.v, type=ptype, vis=vis, file=nt.f, line=nt.ln,
                           indexed=indexed, is_default=isdef, cls=ti.name, owner=ti)
                ti.members.append(m); ti.members_by_name.setdefault(nt.v.lower(), []).append(m)
                continue
            if lv in ('procedure', 'function', 'constructor', 'destructor') or (
                    lv == 'class' and s.lv(1) in ('procedure', 'function')):
                if lv == 'class':
                    s.i += 1
                s.i += 1
                nt = s.adv()
                while s.v() == '.':
                    s.i += 1; nt = s.adv()
                if s.v() == '=':   # method resolution clause
                    s.skip_to_semicolon(); continue
                if s.v() == '(':
                    s.i += 1; s.type_tokens_until((')',)); s.i += 1
                res = None
                if s.v() == ':':
                    s.i += 1
                    ids = []
                    while s.v() != ';':
                        if s.peek().k == 'id':
                            ids.append(s.peek().v)
                        s.i += 1
                    res = ids[-1] if ids else None
                s.skip_to_semicolon()
                s.skip_directives()
                m = Member(kind='method', name=nt.v, type=res, vis=vis, file=nt.f, line=nt.ln, cls=ti.name, owner=ti)
                ti.members.append(m); ti.members_by_name.setdefault(nt.v.lower(), []).append(m)
                continue
            if t.k == 'id' and s.v(1) in (',', ':'):
                names = []
                while True:
                    nt = s.adv(); names.append(nt)
                    if s.v() == ',':
                        s.i += 1; continue
                    break
                s.i += 1
                ty = s.parse_type(None, names[-1], (';', 'end'))
                semi = s.i if s.v() == ';' else s.i - 1
                line_fields = {}
                for f in ti.fields + [Member(kind='field', name=nt.v, file=nt.f, line=nt.ln) for nt in names]:
                    line_fields.setdefault((f.file, f.line), []).append(f)
                new = line_fields[(names[-1].f, names[-1].ln)][-len(names):]
                cm = s.assign_comments(names, semi, line_fields)
                for nt, ph in zip(names, new):
                    c = cm.get(id(nt), ph.comment_off)
                    grp = None
                    if isinstance(c, tuple):
                        grp = (c[1], [x for x in c[2] if x in ti.fields])
                        c = None
                    mm = re.match(r'^F_\w+_([0-9A-Fa-f]+)$', nt.v)
                    if c is None and mm:
                        c = int(mm.group(1), 16)
                    m = Member(kind='field', name=nt.v, type=ty, vis=vis, file=nt.f, line=nt.ln,
                               comment_off=c, cls=ti.name, owner=ti)
                    if grp is not None:
                        ti.line_groups = getattr(ti, 'line_groups', [])
                        ti.line_groups.append((grp[0], grp[1] + [m]))
                    ti.fields.append(m); ti.members.append(m)
                    ti.members_by_name.setdefault(nt.v.lower(), []).append(m)
                if s.v() == ';':
                    s.i += 1
                continue
            s.i += 1

    def skip_directives(s):
        while s.lv() in DIRECTIVES:
            if s.lv() == 'default' and s.v(1) != ';':
                break
            s.skip_to_semicolon()

    def parse_var_decl(s, table, kind='var', routine=None):
        names = []
        while True:
            nt = s.adv(); names.append(nt)
            if s.v() == ',':
                s.i += 1; continue
            break
        s.i += 1  # ':'
        ty = s.parse_type(None, names[-1], (';', '=', 'absolute'))
        if isinstance(ty, TI) and ty.kind == 'alias':
            ty = ty.target
        absolute = None
        if s.lv() == 'absolute':
            s.i += 1
            absolute = s.type_tokens_until((';',))
        elif s.v() == '=':
            s.i += 1
            s.type_tokens_until((';',))
        for nt in names:
            entry = (nt.v, ty, s.unit, nt.f, nt.ln, kind, s.impl)
            if routine is not None:
                table[nt.lv] = entry
            else:
                table.setdefault(nt.lv, []).append(entry)
            if absolute is not None:
                s.m.absolutes.append({'name': nt.v, 'type': ty if isinstance(ty, str) else getattr(ty, 'name', None),
                                      'target': ''.join(t.v for t in absolute), 'file': nt.f, 'line': nt.ln,
                                      'unit': s.unit, 'local': routine is not None})
        s.accept(';')

    def parse_const_decl(s, mode, routine=None):
        nt = s.adv()
        if s.v() == ':':
            s.i += 1
            ty = s.parse_type(None, nt, ('=',))
            s.accept('=')
            init = s.type_tokens_until((';',))
            tyname = ty.target if isinstance(ty, TI) and ty.kind == 'alias' else ty
            s.m.typedconsts.append({'name': nt.v, 'type': tyname, 'init': init, 'unit': s.unit,
                                    'file': nt.f, 'line': nt.ln, 'local': routine is not None})
            entry = (nt.v, tyname, s.unit, nt.f, nt.ln, 'typedconst', s.impl)
            if routine is not None:
                routine.locals[nt.lv] = entry
            else:
                s.m.globals.setdefault(nt.lv, []).append(entry)
        else:
            s.i += 1
            init = s.type_tokens_until((';',))
            if mode == 'rstr':
                entry = (nt.v, 'string', s.unit, nt.f, nt.ln, 'resourcestring', s.impl)
                s.m.globals.setdefault(nt.lv, []).append(entry)
            else:
                s.m.consts.setdefault(nt.lv, []).append((init, s.unit))
        s.accept(';')

    def parse_params(s, r):
        if s.v() != '(':
            return
        s.i += 1
        while s.v() != ')' and s.i < len(s.t):
            if s.lv() in ('var', 'const', 'out'):
                s.i += 1
            names = []
            while s.peek().k == 'id':
                names.append(s.adv())
                if s.v() == ',':
                    s.i += 1; continue
                break
            ty = None
            if s.v() == ':':
                s.i += 1
                if s.lv() == 'array':
                    s.i += 1
                    s.accept('of')
                    el = s.adv().v
                    ty = TI('array', None, dims=[], elem=el, packed=False, open=True, unit=s.unit)
                else:
                    ids = []
                    while s.v() not in (';', ')', '='):
                        if s.peek().k == 'id':
                            ids.append(s.peek().v)
                        s.i += 1
                    ty = ids[-1] if ids else None
            if s.v() == '=':
                s.i += 1; s.type_tokens_until((';', ')'))
            for nt in names:
                r.params[nt.lv] = (nt.v, ty, s.unit, nt.f, nt.ln, 'param')
            if s.v() == ';':
                s.i += 1
        s.i += 1

    def parse_routine(s, parent, impl):
        st = s.i
        if s.lv() == 'class':
            s.i += 1
        kind = s.adv().lv
        nt = s.adv()
        cls = None
        name = nt.v
        while s.v() == '.':
            s.i += 1
            cls = name if cls is None else cls
            nt2 = s.adv()
            cls = name
            name = nt2.v
        r = Routine(name, cls, nt.f, nt.ln)
        r.unit = s.unit
        r.parent = parent
        r.kind = kind
        r.start = st
        s.parse_params(r)
        if s.v() == ':':
            s.i += 1
            ids = []
            while s.v() != ';':
                if s.peek().k == 'id':
                    ids.append(s.peek().v)
                s.i += 1
            r.result = ids[-1] if ids else None
        s.accept(';')
        body = True
        while s.lv() in DIRECTIVES:
            if s.lv() in ('forward', 'external'):
                body = False
            s.skip_to_semicolon()
        if parent is None and r.cls is None:
            s.m.funcs.setdefault(name.lower(), []).append((r.result, s.unit))
        if not impl or not body:
            return r
        if r.cls is None and parent is None and kind in ('procedure', 'function'):
            pass
        # local declarations
        mode = None
        while s.i < len(s.t):
            lv = s.lv()
            if lv in ('begin', 'asm'):
                break
            if lv == 'type':
                s.i += 1; mode = 'type'; continue
            if lv == 'var':
                s.i += 1; mode = 'var'; continue
            if lv in ('const', 'resourcestring'):
                s.i += 1; mode = 'const'; continue
            if lv == 'label':
                s.skip_to_semicolon(); continue
            if lv in ('procedure', 'function', 'constructor', 'destructor') or (
                    lv == 'class' and s.lv(1) in ('procedure', 'function')):
                s.parse_routine(r, impl); mode = None; continue
            if mode == 'type' and s.v(1) == '=':
                s.parse_type_decl(); continue
            if mode == 'var' and s.v(1) in (',', ':'):
                s.parse_var_decl(r.locals, routine=r); continue
            if mode == 'const' and s.v(1) in ('=', ':'):
                s.parse_const_decl('const', routine=r); continue
            if lv in ('implementation', 'end', 'initialization'):
                return r
            s.i += 1
        r.body = s.i
        s.parse_body(r)
        r.end = s.i
        r.end_line = s.t[s.i - 1].ln
        r.end_file = s.t[s.i - 1].f
        s.m.routines.append(r)
        return r

    def parse_body(s, r):
        d = 0
        stack = []   # pending with: (start_idx, expr toks, depth at do, single?)
        while s.i < len(s.t):
            t = s.adv(); lv = t.lv
            if t.k != 'id':
                if t.v == ';' and stack:
                    # close single-statement withs at this depth
                    while stack and stack[-1][3] and stack[-1][2] == d:
                        w = stack.pop(); r.withs.append((w[0], s.i, w[1]))
                continue
            if lv == 'with':
                st = s.i
                d2 = 0
                while s.i < len(s.t):
                    if s.lv() == 'do' and d2 == 0:
                        break
                    if s.v() in ('(', '['):
                        d2 += 1
                    elif s.v() in (')', ']'):
                        d2 -= 1
                    s.i += 1
                expr = s.t[st:s.i]
                s.i += 1
                single = s.lv() != 'begin'
                stack.append((s.i, expr, d + (0 if single else 1), single))
                continue
            if lv in ('begin', 'case', 'try', 'asm'):
                d += 1
                if lv == 'asm':
                    while s.i < len(s.t) and s.lv() != 'end':
                        s.i += 1
            elif lv == 'end':
                while stack and not stack[-1][3] and stack[-1][2] == d:
                    w = stack.pop(); r.withs.append((w[0], s.i, w[1]))
                d -= 1
                while stack and stack[-1][3] and stack[-1][2] > d:
                    w = stack.pop(); r.withs.append((w[0], s.i, w[1]))
                if d <= 0:
                    s.accept(';')
                    while stack:
                        w = stack.pop(); r.withs.append((w[0], s.i, w[1]))
                    return
            elif lv == 'else' and stack:
                while stack and stack[-1][3] and stack[-1][2] == d:
                    w = stack.pop(); r.withs.append((w[0], s.i, w[1]))


# ---------------------------------------------------------------- typing
class Scope:
    def __init__(s, model, unit, routine, tokidx):
        s.m, s.unit, s.r, s.tokidx = model, unit, routine, tokidx

    def self_class(s):
        r = s.r
        while r is not None:
            if r.cls:
                return s.m.resolve(r.cls, r.unit)
            r = r.parent
        return None

    def withs(s):
        out = []
        r = s.r
        while r is not None:
            for (a, b, expr) in r.withs:
                if a <= s.tokidx < b:
                    out.append((a, expr))
            r = r.parent
        out.sort(key=lambda x: -x[0])
        return [e for _, e in out]


class TypeEval:
    """types a designator token list; returns (TI|None, decl_info)"""

    def __init__(s, model):
        s.m = model

    def global_lookup(s, name, unit):
        lst = s.m.globals.get(name.lower())
        if not lst:
            return None
        mine = [g for g in lst if g[2] == unit]
        vis = [g for g in lst if not (len(g) > 6 and g[6])]
        return (mine or sorted(vis or lst, key=lambda g: (rel(g[3]), g[4])))[0]

    def ident(s, tok, scope):
        """returns (TI, info) for a bare identifier"""
        ln = tok.lv
        m = s.m
        if ln == 'self':
            c = scope.self_class()
            return c, {'decl': 'Self', 'type': c.name if c else None}
        # with scopes
        for expr in scope.withs():
            if not expr:
                continue
            wt, _ = s.expr(expr, Scope(s.m, scope.unit, scope.r, expr[0].idx if expr[0].idx is not None else -1))
            if wt is not None:
                mem = m.find_member(wt, tok.v)
                if mem is not None:
                    return s.member_type(mem, wt), {'decl': 'with-member', 'class': mem.cls, 'name': mem.name,
                                                    'type': s.tname(mem.type), 'member': mem}
        r = scope.r
        while r is not None:
            if ln == 'result' and r.result:
                return m.resolve(r.result, r.unit), {'decl': 'result', 'type': r.result}
            if ln in r.params:
                e = r.params[ln]
                return m.resolve(e[1], r.unit), {'decl': 'param', 'routine': s.rname(r), 'type': s.tname(e[1]),
                                                 'file': rel(e[3]), 'line': e[4]}
            if ln in r.locals:
                e = r.locals[ln]
                return m.resolve(e[1], r.unit), {'decl': 'local', 'routine': s.rname(r), 'type': s.tname(e[1]),
                                                 'file': rel(e[3]), 'line': e[4]}
            if ln == r.name.lower() and r.result:
                return m.resolve(r.result, r.unit), {'decl': 'result', 'type': r.result}
            r = r.parent
        sc = scope.self_class()
        if sc is not None:
            mem = m.find_member(sc, tok.v)
            if mem is not None:
                return s.member_type(mem, sc), {'decl': 'self-member', 'class': mem.cls, 'name': mem.name,
                                                'type': s.tname(mem.type), 'member': mem}
        g = s.global_lookup(tok.v, scope.unit)
        if g is not None:
            return m.resolve(g[1], g[2]), {'decl': 'global', 'unit': g[2], 'type': s.tname(g[1]),
                                           'file': rel(g[3]), 'line': g[4]}
        f = m.funcs.get(ln)
        if f:
            mine = [x for x in f if x[1] == scope.unit] or f
            return m.resolve(mine[0][0], mine[0][1]) if mine[0][0] else None, {'decl': 'function', 'type': mine[0][0]}
        if ln in m.units:
            return TI('unit', ln), {'decl': 'unit'}
        t = m.lookup_type(tok.v, scope.unit)
        if t is not None or ln in PRIM:
            return TI('typeref', tok.v, ref=tok.v), {'decl': 'type'}
        if ln in m.cjl:
            return TI('typeref', tok.v, ref=tok.v), {'decl': 'type'}
        return None, {'decl': 'unknown'}

    def rname(s, r):
        return (r.cls + '.' if r.cls else '') + r.name

    def tname(s, t):
        if t is None:
            return None
        if isinstance(t, str):
            return t
        if t.name:
            return t.name
        if t.kind == 'alias':
            return t.target if isinstance(t.target, str) else s.tname(t.target)
        if t.kind == 'array':
            return 'array of %s' % s.tname(t.elem)
        if t.kind == 'ptr':
            return '^%s' % t.target
        if t.kind == 'set':
            return 'set of %s' % s.tname(t.base)
        return t.kind

    def member_type(s, mem, owner):
        u = mem.owner.unit if mem.owner is not None else (owner.unit if owner is not None else None)
        if mem.kind == 'method':
            return s.m.resolve(mem.type, u) if mem.type else None
        return s.m.resolve(mem.type, u)

    def split_args(s, toks):
        out, cur, d = [], [], 0
        for t in toks:
            if t.v in ('(', '[') :
                d += 1
            elif t.v in (')', ']'):
                d -= 1
            if t.v == ',' and d == 0:
                out.append(cur); cur = []
            else:
                cur.append(t)
        if cur:
            out.append(cur)
        return out

    def match(s, toks, i):
        d = 0
        for j in range(i, len(toks)):
            if toks[j].v in ('(', '['):
                d += 1
            elif toks[j].v in (')', ']'):
                d -= 1
                if d == 0:
                    return j
        return len(toks) - 1

    def expr(s, toks, scope):
        """type of a designator expression; None if unknown"""
        toks = [t for t in toks]
        if not toks:
            return None, {}
        if toks[0].v == '@':
            return TI('prim', 'pointer', size=4, align=4), {'decl': 'address'}
        if toks[0].v == '(':
            j = s.match(toks, 0)
            cur, info = s.expr(toks[1:j], scope)
            i = j + 1
        elif toks[0].k == 'id':
            cur, info = s.ident(toks[0], scope)
            i = 1
        else:
            return None, {'decl': 'non-designator'}
        last_mem = info.get('member')
        while i < len(toks):
            t = toks[i]
            if cur is None:
                return None, info
            if t.v == '.':
                nm = toks[i + 1]
                if cur.kind == 'unit':
                    g = s.m.globals.get(nm.lv)
                    g = [x for x in (g or []) if x[2] == cur.name]
                    if g:
                        cur = s.m.resolve(g[0][1], g[0][2])
                        info = {'decl': 'global', 'unit': g[0][2], 'type': s.tname(g[0][1]),
                                'file': rel(g[0][3]), 'line': g[0][4]}
                    else:
                        f = [x for x in s.m.funcs.get(nm.lv, []) if x[1] == cur.name]
                        if f:
                            cur = s.m.resolve(f[0][0], f[0][1]) if f[0][0] else None
                            info = {'decl': 'function', 'type': f[0][0]}
                        else:
                            t2 = s.m.lookup_type(cur.name + '.' + nm.v)
                            cur = TI('typeref', nm.v, ref=cur.name + '.' + nm.v) if t2 else None
                            info = {'decl': 'type'}
                    i += 2; continue
                if cur.kind == 'typeref':
                    return None, {'decl': 'type-member'}
                mem = s.m.find_member(cur, nm.v)
                if mem is None:
                    return None, {'decl': 'member-not-found', 'owner': cur.name, 'name': nm.v}
                info = {'decl': 'member', 'class': mem.cls if mem.cls else cur.name, 'name': mem.name,
                        'kind': mem.kind, 'type': s.tname(mem.type), 'member': mem}
                last_mem = mem
                cur = s.member_type(mem, cur)
                i += 2
                if mem.kind == 'property' and mem.indexed and i < len(toks) and toks[i].v == '[':
                    i = s.match(toks, i) + 1
                if mem.kind == 'method' and i < len(toks) and toks[i].v == '(':
                    i = s.match(toks, i) + 1
                continue
            if t.v == '(':
                j = s.match(toks, i)
                if cur.kind == 'typeref':
                    tt = s.m.resolve(cur.ref, scope.unit)
                    info = {'decl': 'cast', 'type': cur.ref}
                    cur = tt
                # call: type already the result
                i = j + 1; continue
            if t.v == '[':
                j = s.match(toks, i)
                c = s.m.resolve(cur)
                if c.kind == 'array':
                    cur = s.m.resolve(c.elem, c.unit)
                elif c.kind == 'ptr':
                    tg = s.m.resolve(c.target, c.unit)
                    cur = s.m.resolve(tg.elem, tg.unit) if tg is not None and tg.kind == 'array' else None
                elif c.kind == 'prim' and c.name in ('string', 'ansistring', 'shortstring', 'pchar'):
                    cur = s.m.resolve('char')
                elif c.kind == 'class':
                    dp = s.m.default_prop(c)
                    cur = s.m.resolve(dp.type) if dp else None
                    info = {'decl': 'default-property', 'name': dp.name if dp else None,
                            'type': dp.type if dp else None}
                else:
                    cur = None
                i = j + 1; continue
            if t.v == '^':
                c = s.m.resolve(cur)
                if c.kind == 'ptr':
                    cur = s.m.resolve(c.target, c.unit)
                elif c.kind == 'prim' and c.name == 'pointer':
                    cur = TI('untyped', 'untyped-deref')
                else:
                    cur = None
                i += 1; continue
            return None, info
        return cur, info


def find_routine(model, unit, tokidx):
    best = None
    for r in model.routines:
        if r.unit != unit or r.start is None or r.end is None:
            continue
        if r.start <= tokidx < r.end:
            if best is None or (r.end - r.start) < (best.end - best.start):
                best = r
    return best
