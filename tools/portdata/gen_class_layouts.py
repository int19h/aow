"""Generate class-layouts.json from the recovered Delphi 3 source class declarations.

Usage: python gen_class_layouts.py [repo_root] [out.json]
  repo_root defaults to C:\\git\\int19h\\aow, out.json to class-layouts.json next to this script.

Layout rules (Delphi 3, defaults; the source sets no $A/$Z/$M switches): VMT pointer at +0, own fields
start at the parent's instance size (classes.json size when known, else the computed parent size), each
field aligned to its type's alignment (min(size,4) for scalars, record = max field alignment, array =
element alignment, packed = 1), instance size rounded up to 4. Enumerations are 1 byte up to 256 values.
Visibility before the first section keyword is published when TPersistent is an ancestor ($M+), else public.
"""
import json, os, re, sys, collections

ROOT = sys.argv[1] if len(sys.argv) > 1 else r'C:\git\int19h\aow'
OUT = sys.argv[2] if len(sys.argv) > 2 else os.path.join(os.path.dirname(os.path.abspath(__file__)), 'class-layouts.json')
SRC = os.path.join(ROOT, 'src', 'delphi3')

TARGETS = collections.OrderedDict([
    ('Engine', ('', 'Enginep.dpl')), ('HSEPack', ('HSEPack', 'HSEPack.dpl')),
    ('AoWEPACK', ('AoWEPACK', 'AoWEPACK.dpl')), ('AoWTCPCK', ('AoWTCPCK', 'AoWTCPCK.dpl')),
    ('aowInt', ('aowInt', 'aowInt.dpl')), ('AOWTools', ('AOWTools', 'AOWTools.dpl')),
    ('Ilpack', ('Ilpack', 'Ilpack.dpl')), ('SoundP', ('SoundP', 'SoundP.dpl')),
    ('Network', ('Network', 'Network.dpl')), ('aowFXpck', ('aowFXpck', 'aowFXpck.dpl')),
    ('AoW', ('AoW', 'AoW.exe')),
])
SKIP_DIRS = {'hosts', 'aliases', 'obj'}

# ---------------------------------------------------------------- tokenizer
TOK = re.compile(r"""
  (?P<ws>\s+)
 |(?P<c1>\{[^}]*\})
 |(?P<c2>\(\*.*?\*\))
 |(?P<c3>//[^\n]*)
 |(?P<str>(?:'(?:[^']|'')*'|\#\$?[0-9A-Fa-f]+)+)
 |(?P<num>\$[0-9A-Fa-f]+|\d+(?:\.\d+)?(?:[eE][+-]?\d+)?)
 |(?P<id>[A-Za-z_][A-Za-z0-9_]*)
 |(?P<sym>\.\.|:=|<=|>=|<>|[^\s])
""", re.S | re.X)


class Tok:
    __slots__ = ('k', 't', 'f', 'l')

    def __init__(self, k, t, f, l):
        self.k, self.t, self.f, self.l = k, t, f, l

    def __repr__(self):
        return '%s:%r@%d' % (self.k, self.t, self.l)


def tokenize(path, defines=frozenset(), depth=0):
    text = open(path, encoding='latin-1').read()
    out = []
    line = 1
    cond = []  # stack of (active_parent, this_active)
    active = True
    rel = os.path.relpath(path, ROOT).replace('\\', '/')
    pos = 0
    for m in TOK.finditer(text):
        k = m.lastgroup
        t = m.group(0)
        l = line
        line += t.count('\n')
        if k == 'ws':
            continue
        if k in ('c1', 'c2') and t[1:2] == '$' or (k == 'c2' and t[2:3] == '$'):
            body = t[2:-1] if k == 'c1' else t[3:-2]
            dm = re.match(r'([A-Za-z]+)\s*(.*)', body.strip(), re.S)
            d = dm.group(1).upper() if dm else ''
            arg = dm.group(2).strip() if dm else ''
            if d in ('IFDEF', 'IFNDEF', 'IFOPT'):
                if d == 'IFDEF':
                    v = arg.split()[0].upper() in defines
                elif d == 'IFNDEF':
                    v = arg.split()[0].upper() not in defines
                else:
                    v = True
                cond.append((active, v))
                active = active and v
            elif d == 'ELSE' and cond:
                pa, v = cond[-1]
                cond[-1] = (pa, not v)
                active = pa and not v
            elif d == 'ENDIF' and cond:
                pa, v = cond.pop()
                active = pa
            elif d in ('I', 'INCLUDE') and active and not arg.startswith(('+', '-')):
                ip = os.path.join(os.path.dirname(path), arg.strip("'\""))
                if os.path.exists(ip) and depth < 8:
                    out.extend(tokenize(ip, defines, depth + 1))
            continue
        if not active:
            continue
        if k in ('c1', 'c2', 'c3'):
            out.append(Tok('cm', t, rel, l))
        else:
            out.append(Tok(k, t, rel, l))
    return out


# ---------------------------------------------------------------- parser
SECTION_KW = {'var', 'const', 'resourcestring', 'implementation', 'begin', 'procedure', 'function',
              'constructor', 'destructor', 'type', 'threadvar', 'initialization', 'finalization',
              'uses', 'exports', 'label', 'interface', 'end'}
VIS = {'private', 'protected', 'public', 'published', 'automated'}
METHOD_KW = {'procedure', 'function', 'constructor', 'destructor'}
DIRECTIVES = {'virtual', 'abstract', 'override', 'dynamic', 'overload', 'stdcall', 'cdecl', 'register',
              'pascal', 'safecall', 'reintroduce', 'export', 'far', 'near', 'assembler', 'message'}


class Parser:
    def __init__(self, toks):
        self.all = toks
        self.code = [t for t in toks if t.k != 'cm']
        # map from code index to the preceding comments and the trailing comments on the same line
        self.pre = collections.defaultdict(list)
        self.post = collections.defaultdict(list)
        ci = -1
        pending = []
        for t in toks:
            if t.k == 'cm':
                if ci >= 0 and self.code[ci].l == t.l and self.code[ci].f == t.f:
                    self.post[ci].append(t)
                pending.append(t)
            else:
                ci += 1
                self.pre[ci] = pending
                pending = []
        self.i = 0

    def peek(self, o=0):
        j = self.i + o
        return self.code[j] if j < len(self.code) else Tok('eof', '', '', 0)

    def lw(self, o=0):
        return self.peek(o).t.lower()

    def next(self):
        t = self.peek()
        self.i += 1
        return t

    def expect(self, s):
        if self.lw() == s:
            self.i += 1
            return True
        return False

    def text(self, a, b):
        s = ''
        prev = None
        for t in self.code[a:b]:
            if prev is not None and (prev.k == 'id' or prev.k == 'num') and (t.k == 'id' or t.k == 'num'):
                s += ' '
            elif prev is not None and t.t in ('of', 'record', 'end') :
                s += ' '
            s += t.t
            prev = t
        s = re.sub(r'(?<=\w)(of|record|end)\b', r' \1', s)
        return s

    # ---- type expressions
    def parse_type(self, stop=(';',)):
        start = self.i
        w = self.lw()
        packed = False
        if w == 'packed':
            packed = True
            self.next()
            w = self.lw()
        if w == 'type' :
            self.next()
            return self.parse_type(stop)
        if w == '(':
            self.next()
            members = []
            while self.lw() not in (')', ''):
                t = self.next()
                if t.k == 'id':
                    members.append(t.t)
                if self.lw() == ',':
                    self.next()
            self.expect(')')
            return {'k': 'enum', 'members': members, 'text': self.text(start, self.i)}
        if w == 'set':
            self.next()
            self.expect('of')
            base = self.parse_type(stop)
            return {'k': 'set', 'of': base, 'text': self.text(start, self.i)}
        if w == 'array':
            self.next()
            dims = []
            if self.expect('['):
                while True:
                    dims.append(self.parse_type(stop=(',', ']')))
                    if self.expect(','):
                        continue
                    self.expect(']')
                    break
            self.expect('of')
            if self.lw() == 'const':
                self.next()
                el = {'k': 'named', 'name': 'TVarRec', 'text': 'const'}
            else:
                el = self.parse_type(stop)
            return {'k': 'array', 'dims': dims, 'of': el, 'packed': packed, 'text': self.text(start, self.i)}
        if w == 'record':
            self.next()
            fields, variant = self.parse_fieldlist()
            self.expect('end')
            return {'k': 'record', 'fields': fields, 'variant': variant, 'packed': packed,
                    'text': self.text(start, self.i)}
        if w in ('class', 'object', 'interface', 'dispinterface'):
            return self.parse_class(start, w)
        if w == '^':
            self.next()
            self.next()
            return {'k': 'ptr', 'text': self.text(start, self.i)}
        if w in ('procedure', 'function'):
            self.next()
            depth = 0
            while True:
                t = self.peek()
                if t.k == 'eof':
                    break
                if t.t == '(':
                    depth += 1
                elif t.t == ')':
                    depth -= 1
                elif depth == 0 and (t.t in stop or t.t.lower() in ('end',) or t.t == '='):
                    break
                elif depth == 0 and t.t.lower() == 'of' and self.lw(1) == 'object':
                    self.i += 2
                    return {'k': 'proc', 'obj': True, 'text': self.text(start, self.i)}
                self.i += 1
            # calling convention directives: "; stdcall" in a type declaration
            while self.lw() == ';' and self.lw(1) in ('stdcall', 'cdecl', 'pascal', 'register', 'safecall') :
                self.i += 2
            return {'k': 'proc', 'obj': False, 'text': self.text(start, self.i)}
        if w in ('file', 'text'):
            self.next()
            if self.lw() == 'of':
                self.next()
                self.parse_type(stop)
            return {'k': 'named', 'name': 'TextFile' if w == 'text' else 'File', 'text': self.text(start, self.i)}
        if w == 'string':
            self.next()
            if self.expect('['):
                a = self.i
                while self.lw() not in (']', ''):
                    self.next()
                n = self.code[a:self.i]
                self.expect(']')
                return {'k': 'shortstr', 'len': n, 'text': self.text(start, self.i)}
            return {'k': 'named', 'name': 'string', 'text': 'string'}
        # expression: named type or subrange
        a = self.i
        depth = 0
        rng = None
        while True:
            t = self.peek()
            if t.k == 'eof':
                break
            tl = t.t.lower()
            if t.t in ('(', '['):
                depth += 1
            elif t.t in (')', ']'):
                if depth == 0:
                    break
                depth -= 1
            elif depth == 0 and (t.t in stop or t.t in (';', '=', ',') or tl in ('of', 'end', 'read', 'write',
                                                                                 'default', 'stored', 'index')):
                break
            elif depth == 0 and t.t == '..':
                rng = self.i
            self.i += 1
        toks = self.code[a:self.i]
        if rng is not None:
            return {'k': 'subrange', 'lo': self.code[a:rng], 'hi': self.code[rng + 1:self.i],
                    'text': self.text(start, self.i)}
        ids = [t.t for t in toks if t.k == 'id']
        name = ids[-1] if ids and all(t.k == 'id' or t.t == '.' for t in toks) else None
        if name:
            return {'k': 'named', 'name': name, 'text': self.text(start, self.i)}
        return {'k': 'unknown', 'text': self.text(start, self.i)}

    def parse_fieldlist(self, end=('end',)):
        fields = []
        variant = None
        while self.lw() not in end and self.lw() not in ('', ')'):
            if self.lw() == 'case':
                self.next()
                tagname = None
                if self.lw(1) == ':':
                    tagname = self.next().t
                    self.next()
                tagtype = self.parse_type(stop=('of',))
                self.expect('of')
                branches = []
                if tagname:
                    fields.append(([tagname], tagtype, None))
                while self.lw() not in end and self.lw() not in ('', ')'):
                    while self.lw() not in (':', ''):
                        self.next()
                    self.expect(':')
                    self.expect('(')
                    bf, bv = self.parse_fieldlist(end=(')',))
                    self.expect(')')
                    branches.append((bf, bv))
                    self.expect(';')
                variant = branches
                break
            names = []
            first = self.i
            while self.peek().k == 'id':
                names.append(self.next().t)
                if not self.expect(','):
                    break
            if not self.expect(':'):
                self.next()
                continue
            ty = self.parse_type()
            fields.append((names, ty, first))
            self.expect(';')
        return fields, variant

    def skip_to_semicolon(self):
        depth = 0
        while True:
            t = self.peek()
            if t.k == 'eof':
                return
            if t.t in ('(', '['):
                depth += 1
            elif t.t in (')', ']'):
                depth -= 1
            elif t.t == ';' and depth <= 0:
                self.i += 1
                return
            elif depth <= 0 and t.t.lower() == 'end':
                return
            self.i += 1

    def parse_class(self, start, kw):
        self.next()
        if kw == 'class' and self.lw() == 'of':
            self.next()
            self.next()
            return {'k': 'classref', 'text': self.text(start, self.i)}
        if kw in ('interface', 'dispinterface'):
            if self.lw() == ';':
                return {'k': 'intf', 'forward': True, 'text': 'interface'}
            depth = 0
            while self.lw() not in ('',):
                if self.lw() == 'end' and depth == 0:
                    self.next()
                    break
                self.next()
            return {'k': 'intf', 'text': 'interface'}
        parents = []
        if self.expect('('):
            while self.lw() not in (')', ''):
                t = self.next()
                if t.k == 'id' and self.lw() != '.':
                    parents.append(t.t)
            self.expect(')')
        if self.lw() == ';':
            return {'k': 'class', 'kind': kw, 'parents': parents, 'forward': not parents, 'fields': [],
                    'text': 'class'}
        fields = []
        vis = None
        while self.lw() not in ('end', ''):
            w = self.lw()
            if w in VIS:
                vis = w
                self.next()
                continue
            if w == 'class' and self.lw(1) in METHOD_KW:
                self.next()
                w = self.lw()
            if w in METHOD_KW:
                self.next()
                self.skip_to_semicolon()
                while self.lw() in DIRECTIVES:
                    self.skip_to_semicolon()
                continue
            if w == 'property':
                self.next()
                self.skip_to_semicolon()
                if self.lw() == 'default' and self.lw(1) == ';':
                    self.i += 2
                continue
            if self.peek().k == 'id':
                names = []
                ntoks = []
                while self.peek().k == 'id':
                    ntoks.append(self.i)
                    names.append(self.next().t)
                    if not self.expect(','):
                        break
                if not self.expect(':'):
                    self.skip_to_semicolon()
                    continue
                ty = self.parse_type()
                semi = self.i
                self.expect(';')
                # offset comment: the first comment on the line of the ';' (after any visibility keyword)
                cms = list(self.post.get(semi, []))
                j = semi + 1
                while j < len(self.code) and self.code[j].t.lower() in VIS and self.code[j].l == self.code[semi].l:
                    cms += self.post.get(j, [])
                    j += 1
                fields.append({'names': names, 'type': ty, 'vis': vis, 'tok': ntoks[0], 'comments': cms})
                continue
            self.next()
        self.expect('end')
        return {'k': 'class', 'kind': kw, 'parents': parents, 'forward': False, 'fields': fields, 'text': 'class'}

    # ---- unit
    def parse_unit(self):
        unit = None
        if self.lw() in ('unit', 'program', 'library', 'package'):
            self.next()
            unit = self.next().t
        types = []   # (name, typeobj, tokindex)
        consts = []  # (name, tokens)
        sect = None
        while self.peek().k != 'eof':
            w = self.lw()
            if w in ('type', 'const', 'var', 'resourcestring', 'threadvar'):
                sect = w
                self.next()
                continue
            if w in ('procedure', 'function', 'constructor', 'destructor', 'begin', 'implementation',
                     'interface', 'uses', 'initialization', 'finalization', 'exports', 'label', 'asm'):
                if w in ('procedure', 'function', 'constructor', 'destructor') and sect == 'type':
                    pass
                sect = None
                if w == 'uses':
                    self.skip_to_semicolon()
                    continue
                self.next()
                continue
            if sect == 'type' and self.peek().k == 'id' and self.lw(1) == '=':
                name = self.peek().t
                ti = self.i
                self.i += 2
                try:
                    ty = self.parse_type()
                except Exception:
                    ty = {'k': 'unknown', 'text': '?'}
                types.append((name, ty, ti))
                self.expect(';')
                continue
            if sect == 'const' and self.peek().k == 'id' and self.lw(1) == '=':
                name = self.peek().t
                self.i += 2
                a = self.i
                self.skip_to_semicolon()
                consts.append((name, self.code[a:self.i - 1]))
                continue
            if sect in ('const', 'var') and self.peek().k == 'id' and self.lw(1) in (':', ','):
                self.skip_to_semicolon()
                continue
            self.next()
        return unit, types, consts


# ---------------------------------------------------------------- type table
BUILTIN = {
    'integer': (4, 4), 'cardinal': (4, 4), 'longint': (4, 4), 'longword': (4, 4), 'dword': (4, 4),
    'uint': (4, 4), 'bool': (4, 4), 'longbool': (4, 4), 'wordbool': (2, 2), 'bytebool': (1, 1),
    'smallint': (2, 2), 'shortint': (1, 1), 'byte': (1, 1), 'word': (2, 2), 'char': (1, 1),
    'ansichar': (1, 1), 'widechar': (2, 2), 'boolean': (1, 1), 'string': (4, 4), 'ansistring': (4, 4),
    'widestring': (4, 4), 'pchar': (4, 4), 'pansichar': (4, 4), 'pwidechar': (4, 4), 'pointer': (4, 4),
    'shortstring': (256, 1), 'real': (6, 2), 'double': (8, 4), 'extended': (10, 4), 'single': (4, 4),
    'comp': (8, 4), 'currency': (8, 4), 'variant': (16, 4), 'olevariant': (16, 4), 'tdatetime': (8, 4),
    'tpoint': (8, 4), 'trect': (16, 4), 'tsize': (8, 4), 'tsmallpoint': (4, 2), 'tcolor': (4, 4),
    'tcolorref': (4, 4), 'thandle': (4, 4), 'tnotifyevent': (8, 4), 'tmessage': (16, 4),
    'tfilename': (4, 4), 'tcaption': (4, 4), 'tcursor': (2, 2), 'timageindex': (4, 4),
    'tshiftstate': (1, 1), 'talign': (1, 1), 'tmousebutton': (1, 1), 'tguid': (16, 4), 'tclsid': (16, 4),
    'trtlcriticalsection': (24, 4), 'tfiletime': (8, 4), 'tsystemtime': (16, 2), 'trgbquad': (4, 1),
    'tpaletteentry': (4, 1), 'tbitmapinfoheader': (40, 4), 'tlogfont': (60, 4), 'tvarrec': (8, 4),
    'tsearchrec': (344, 4), 'twin32finddata': (320, 4), 'tmsg': (28, 4), 'textfile': (460, 4),
    'file': (332, 4), 'hresult': (4, 4), 'wparam': (4, 4), 'lparam': (4, 4), 'lresult': (4, 4),
    'tclass': (4, 4), 'tobject': (4, 4), 'iunknown': (4, 4), 'idispatch': (4, 4), 'tpersistentclass': (4, 4),
    'tcomponentclass': (4, 4), 'tformborderstyle': (1, 1), 'tbordericons': (1, 1), 'tfontstyles': (1, 1),
    'tanchors': (1, 1), 'tbrushstyle': (1, 1), 'tpenstyle': (1, 1), 'tpenmode': (1, 1), 'tfontname': (4, 4),
    'tcopymode': (4, 4), 'tfontpitch': (1, 1), 'tfontcharset': (1, 1), 'tmodalresult': (4, 4),
    'tscrollcode': (1, 1), 'tscrollbarkind': (1, 1), 'tbevelcut': (1, 1), 'tbevelwidth': (4, 4),
    'tborderstyle': (1, 1), 'tborderwidth': (4, 4), 'tcolordepth': (1, 1), 'tlargeinteger': (8, 4),
    'tthreadpriority': (1, 1), 'tdragmode': (1, 1), 'tdragstate': (1, 1), 'tkeypressevent': (8, 4),
    'tkeyevent': (8, 4), 'tmouseevent': (8, 4), 'tmousemoveevent': (8, 4), 'tcloseevent': (8, 4),
    'tclosequeryevent': (8, 4), 'tdrawcellevent': (8, 4), 'tthreadmethod': (8, 4), 'thelpevent': (8, 4),
    'tgetstrproc': (4, 4), 'tlistsortcompare': (4, 4), 'tstringlistsortcompare': (4, 4),
    'tduplicates': (1, 1), 'tseekorigin': (1, 1), 'tgridoptions': (2, 2), 'tgriddrawstate': (1, 1),
    'tgridrect': (16, 4), 'tgridcoord': (8, 4), 'tlistboxstyle': (1, 1), 'towndrawstate': (1, 1),
    'ttimerevent': (8, 4), 'tdrawitemevent': (8, 4), 'tmeasureitemevent': (8, 4),
    'tscrollevent': (8, 4), 'tchangingevent': (8, 4), 'ttabchangingevent': (8, 4),
    'tsetediteven': (8, 4), 'tdatetimecolors': (4, 4), 'teditcharcase': (1, 1), 'tselectcellevent': (8, 4),
}
HANDLE_RE = re.compile(r'^H[A-Z0-9]+$|^HINST$|^HMODULE$|^MMRESULT$|^HMMIO$')


class Types:
    def __init__(self, cdb):
        self.by = collections.defaultdict(list)  # lname -> [(unit, module, typeobj)]
        self.consts = {}
        self.enum_val = {}
        self.cdb = cdb
        self.cdb_lower = {k.lower(): k for k in cdb}

    def add(self, unit, module, name, ty):
        self.by[name.lower()].append((unit, module, ty))
        if ty['k'] == 'enum':
            for n, m in enumerate(ty['members']):
                self.enum_val.setdefault(m.lower(), (n, name))

    def lookup(self, name, unit=None, module=None):
        c = self.by.get(name.lower())
        if not c:
            return None
        for u, m, t in c:
            if u == unit and not (t['k'] == 'class' and t.get('forward')):
                return t
        for pred in (lambda u, m: m == module, lambda u, m: m == 'Engine', lambda u, m: True):
            for u, m, t in c:
                if pred(u, m) and not (t['k'] == 'class' and t.get('forward')):
                    return t
        return c[0][2]

    # constant expressions
    def ev(self, toks, ctx, guard=0):
        if guard > 20:
            raise ValueError
        s = []
        i = 0
        while i < len(toks):
            t = toks[i]
            tl = t.t.lower()
            if t.k == 'num':
                s.append(str(int(t.t[1:], 16)) if t.t.startswith('$') else t.t)
            elif t.k == 'str':
                m = re.fullmatch(r"'(.)'", t.t)
                if m:
                    s.append(str(ord(m.group(1))))
                elif re.fullmatch(r'#\d+', t.t):
                    s.append(t.t[1:])
                else:
                    raise ValueError
            elif t.k == 'id':
                if tl in ('div',):
                    s.append('//')
                elif tl in ('mod', 'and', 'or', 'xor', 'shl', 'shr', 'not'):
                    s.append({'mod': '%', 'and': '&', 'or': '|', 'xor': '^', 'shl': '<<', 'shr': '>>', 'not': '~'}[tl])
                elif tl in ('high', 'low', 'sizeof', 'ord', 'succ', 'pred', 'chr') and i + 1 < len(toks) and toks[i + 1].t == '(':
                    depth = 0
                    j = i + 1
                    while j < len(toks):
                        if toks[j].t == '(':
                            depth += 1
                        elif toks[j].t == ')':
                            depth -= 1
                            if depth == 0:
                                break
                        j += 1
                    inner = toks[i + 2:j]
                    if tl in ('high', 'low'):
                        nm = inner[-1].t if inner else ''
                        ty = BUILTIN_ORD.get(nm.lower())
                        if ty is None:
                            tt = self.lookup(nm, *ctx)
                            r = self.ordrange(tt, ctx) if tt else None
                        else:
                            r = ty
                        if r is None:
                            raise ValueError
                        s.append(str(r[1] if tl == 'high' else r[0]))
                    elif tl == 'sizeof':
                        nm = inner[-1].t
                        r = self.size({'k': 'named', 'name': nm}, ctx)
                        if not r:
                            raise ValueError
                        s.append(str(r[0]))
                    else:
                        v = self.ev(inner, ctx, guard + 1)
                        s.append(str(v + (1 if tl == 'succ' else -1 if tl == 'pred' else 0)))
                    i = j + 1
                    continue
                elif tl in self.enum_val:
                    s.append(str(self.enum_val[tl][0]))
                elif tl in ('true', 'false'):
                    s.append('1' if tl == 'true' else '0')
                elif tl in self.consts:
                    s.append(str(self.ev(self.consts[tl], ctx, guard + 1)))
                else:
                    raise ValueError
            elif t.t in '+-*()':
                s.append(t.t)
            elif t.t == '/':
                s.append('//')
            else:
                raise ValueError
            i += 1
        return int(eval(' '.join(s), {'__builtins__': {}}))

    def ordrange(self, ty, ctx, guard=0):
        if ty is None or guard > 20:
            return None
        k = ty['k']
        if k == 'enum':
            return (0, len(ty['members']) - 1)
        if k == 'subrange':
            try:
                return (self.ev(ty['lo'], ctx), self.ev(ty['hi'], ctx))
            except Exception:
                return None
        if k == 'named':
            b = BUILTIN_ORD.get(ty['name'].lower())
            if b:
                return b
            t = self.lookup(ty['name'], *ctx)
            return self.ordrange(t, ctx, guard + 1)
        return None

    def size(self, ty, ctx, guard=0):
        """(size, align) or None"""
        if ty is None or guard > 30:
            return None
        k = ty['k']
        if k == 'enum':
            n = len(ty['members'])
            return (1, 1) if n <= 256 else (2, 2) if n <= 65536 else (4, 4)
        if k == 'subrange':
            lo_t = ty['lo']
            if lo_t and lo_t[0].k == 'id' and lo_t[0].t.lower() in self.enum_val and len(lo_t) == 1:
                base = self.lookup(self.enum_val[lo_t[0].t.lower()][1], *ctx)
                if base:
                    return self.size(base, ctx, guard + 1)
            r = self.ordrange(ty, ctx)
            if not r:
                return None
            lo, hi = r
            if lo >= 0:
                s = 1 if hi <= 255 else 2 if hi <= 65535 else 4
            else:
                s = 1 if lo >= -128 and hi <= 127 else 2 if lo >= -32768 and hi <= 32767 else 4
            return (s, s)
        if k == 'set':
            r = self.ordrange(ty['of'], ctx)
            if not r:
                return None
            lo, hi = r
            n = hi // 8 - lo // 8 + 1
            if n == 3:
                n = 4
            return (n, 1)  # sets are byte-aligned (TDamageTypes, 2 bytes, sits at odd offsets)
        if k == 'array':
            el = self.size(ty['of'], ctx, guard + 1)
            if not el:
                return None
            cnt = 1
            for d in ty['dims']:
                r = self.ordrange(d, ctx)
                if not r:
                    return None
                cnt *= r[1] - r[0] + 1
            return (el[0] * cnt, 1 if ty.get('packed') else el[1])
        if k == 'record':
            return self.record_layout(ty, ctx, guard)[0]
        if k in ('classref', 'ptr', 'intf'):
            return (4, 4)
        if k == 'class':
            return (4, 4)
        if k == 'proc':
            return (8, 4) if ty['obj'] else (4, 4)
        if k == 'shortstr':
            try:
                n = self.ev(ty['len'], ctx)
            except Exception:
                return None
            return (n + 1, 1)
        if k == 'named':
            nm = ty['name'].lower()
            t = self.lookup(ty['name'], *ctx)
            if t is not None and t is not ty:
                if t['k'] == 'named' and t['name'].lower() == nm:
                    pass
                else:
                    r = self.size(t, ctx, guard + 1)
                    if r:
                        return r
            if nm in BUILTIN:
                return BUILTIN[nm]
            if nm in self.cdb_lower:
                return (4, 4)
            if HANDLE_RE.match(ty['name']):
                return (4, 4)
            return None
        return None

    def record_layout(self, ty, ctx, guard=0):
        packed = ty.get('packed')
        off = 0
        al = 1
        rows = []
        ok = True

        def place(fields, off):
            nonlocal al, ok
            for names, ft, _ in fields:
                r = self.size(ft, ctx, guard + 1)
                for n in names:
                    if not r:
                        ok = False
                        rows.append((n, None, None))
                        continue
                    a = 1 if packed else r[1]
                    off = (off + a - 1) // a * a
                    rows.append((n, off, r[0]))
                    off += r[0]
                    al = max(al, a)
            return off

        off = place(ty['fields'], off)
        if ty.get('variant'):
            mx = off
            for bf, bv in ty['variant']:
                end = place(bf, off)
                mx = max(mx, end)
            off = mx
        if not ok:
            return None, rows
        size = (off + al - 1) // al * al
        return (size, al), rows


BUILTIN_ORD = {'boolean': (0, 1), 'byte': (0, 255), 'char': (0, 255), 'ansichar': (0, 255),
               'shortint': (-128, 127), 'word': (0, 65535), 'smallint': (-32768, 32767),
               'widechar': (0, 65535), 'bytebool': (0, 1), 'integer': (-2 ** 31, 2 ** 31 - 1)}


# ---------------------------------------------------------------- offsets from comments
INLINE_RE = re.compile(r'^\s*(?:\+?\$|\+)([0-9A-Fa-f]+)\b(\s*(?:\.\.|[,/])\s*\+?\$?([0-9A-Fa-f]+)\b)?')
HEADER_RE = re.compile(r'(?<![\w$])\+(\$[0-9A-Fa-f]+|[0-9A-Fa-f]+)\s+(?:the\s+)?([A-Za-z_]\w*)')
SIZE_RE = re.compile(r'(?:instance size|^\s*\w+\.\w+\s*\()\s*(\$[0-9A-Fa-f]+|\d+)|\((\$[0-9A-Fa-f]+|\d+) bytes\)', re.I)


def comment_body(t):
    s = t.t
    if s.startswith('{'):
        return s[1:-1]
    if s.startswith('(*'):
        return s[2:-2]
    return s[2:]


def inline_offset(cms, size):
    """The offset a trailing comment gives: '{ $1C }', '{ +001C }', '{ $34..$44 }' (an array whose
    elements span the range). Lists ('$54, $58') and slashes name several fields: no single offset."""
    for c in cms:
        body = comment_body(c)
        m = INLINE_RE.match(body)
        if not m:
            return None, None
        v = int(m.group(1), 16)
        if v >= 0x10000:
            return None, body.strip()
        if m.group(2):
            if '..' not in m.group(2):
                return None, body.strip()
            hi = int(m.group(3), 16)
            if size is None or not (v <= hi < v + size):
                return None, body.strip()
        return v, body.strip()
    return None, None


def num(s):
    return int(s[1:], 16) if s.startswith('$') else int(s)


# ---------------------------------------------------------------- main
def module_of(rel):
    parts = rel.replace('\\', '/').split('/')
    return 'Engine' if len(parts) == 1 or parts[0] == 'inc' else parts[0]


def main():
    cdb = json.load(open(os.path.join(ROOT, 'data', 'classes.json'), encoding='utf-8'))['classes']
    types = Types(cdb)
    units = []
    included = set()
    files = []
    for dp, dn, fn in os.walk(SRC):
        dn[:] = sorted(d for d in dn if d not in SKIP_DIRS)
        for f in sorted(fn):
            if f.lower().endswith(('.pas', '.dpr')) and f.lower() != 'matchtest.dpr':
                files.append(os.path.join(dp, f))
    parsed = []
    for p in files:
        toks = tokenize(p)
        for t in toks:
            if t.f != os.path.relpath(p, ROOT).replace('\\', '/'):
                included.add(t.f)
        parsed.append((p, toks))
    for p, toks in parsed:
        rel = os.path.relpath(p, SRC).replace('\\', '/')
        if os.path.relpath(p, ROOT).replace('\\', '/') in included:
            continue  # an include file: parsed through its host unit
        mod = module_of(rel)
        ps = Parser(toks)
        unit, tys, consts = ps.parse_unit()
        if unit is None:
            continue
        for n, toks_ in consts:
            types.consts.setdefault(n.lower(), toks_)
        for n, ty, ti in tys:
            types.add(unit, mod, n, ty)
        units.append((unit, mod, rel, ps, tys))

    # classes
    srccls = {}
    for unit, mod, rel, ps, tys in units:
        for n, ty, ti in tys:
            if ty['k'] == 'class' and not ty.get('forward') and ty['kind'] == 'class':
                srccls.setdefault(n.lower(), []).append((unit, mod, rel, ps, n, ty, ti))

    def src_class(name, mod):
        c = srccls.get(name.lower())
        if not c:
            return None
        for x in c:
            if x[1] == mod:
                return x
        for x in c:
            if x[1] == 'Engine':
                return x
        return c[0]

    def cdb_entry(name, modfile):
        e = cdb.get(name)
        if e and (modfile is None or e.get('module', '').lower() == modfile.lower()):
            return e
        return None

    memo = {}

    def ancestry(name, mod, guard=0):
        chain = []
        cur, m = name, mod
        while cur and guard < 60:
            chain.append(cur)
            s = src_class(cur, m)
            if s:
                cur = s[5]['parents'][0] if s[5]['parents'] else ('TObject' if cur.lower() != 'tobject' else None)
                m = s[1]
            else:
                e = cdb.get(cur)
                cur = e.get('parent') if e else None
            guard += 1
        return chain

    def layout(x):
        unit, mod, rel, ps, name, ty, ti = x
        key = (mod, name.lower())
        if key in memo:
            return memo[key]
        memo[key] = None  # recursion guard
        modfile = TARGETS.get(mod, (None, None))[1]
        parent = ty['parents'][0] if ty['parents'] else 'TObject'
        ctx = (unit, mod)
        # base offset
        pe = cdb.get(parent)
        ps_ = src_class(parent, mod)
        base, base_src = None, None
        if pe and pe.get('size') is not None and (ps_ is None or pe.get('module', '').lower() in
                                                  (TARGETS.get(ps_[1], (0, ''))[1].lower(), 'vcl30.dpl')
                                                  or True):
            base, base_src = pe['size'], 'classes.json'
        elif ps_:
            pl = layout(ps_)
            if pl and pl['computed_size'] is not None:
                base, base_src = pl['computed_size'], 'computed'
        if base is None and parent.lower() == 'tobject':
            base, base_src = 4, 'TObject'
        chain = ancestry(name, mod)
        published_default = any(c.lower() == 'tpersistent' for c in chain[1:])
        # header comment
        pre = ps.pre.get(ti, [])
        hdr = ' '.join(comment_body(c) for c in pre[-2:])
        hdr_off = {}
        hexdefault = '+$' not in hdr  # '+18 FName' (AoWE style) is hex; '+8 FSender, +$C ...' is decimal
        for m in HEADER_RE.finditer(hdr):
            g = m.group(1)
            try:
                v = num(g) if g.startswith('$') else int(g, 16 if hexdefault else 10)
            except ValueError:
                continue
            hdr_off.setdefault(m.group(2), v)
        msz = SIZE_RE.search(hdr)
        comment_size = None
        if msz:
            comment_size = num(msz.group(1) or msz.group(2))
        off = base
        maxal = 1
        fields = []
        # a trailing comment documents the field right before it, except when that field is padding
        # ('FStatus: T; F_X_1D: array[0..2] of Byte; { $1C }'): then it documents the field before the pad
        fl = ty['fields']
        for k in range(1, len(fl)):
            f, pv = fl[k], fl[k - 1]
            nm = f['names'][-1]
            pm = re.search(r'^(?:F_\w+_|FReserved|FPad|F\w*Pad)([0-9A-Fa-f]*)$', nm)
            if not pm or not f['comments'] or pv['comments']:
                continue
            if ps.code[pv['tok']].l != ps.code[f['tok']].l:
                continue
            v, _ = inline_offset(f['comments'], None)
            if v is not None and (not pm.group(1) or v != int(pm.group(1), 16)):
                pv['comments'], f['comments'] = f['comments'], []
        for f in ty['fields']:
            r = types.size(f['type'], ctx)
            ioff, itext = inline_offset(f['comments'], r[0] if r else None)
            vis = f['vis'] or ('published' if published_default else 'public')
            for k, n in enumerate(f['names']):
                co = ioff if k == 0 else None
                ct = itext if k == 0 else None
                if co is None and n in hdr_off:
                    co, ct = hdr_off[n], 'class comment'
                comp = None
                if r and off is not None:
                    a = r[1]
                    comp = (off + a - 1) // a * a
                    off = comp + r[0]
                    maxal = max(maxal, a)
                else:
                    off = None
                    # resync from the source comment so later fields are still computed
                    if co is not None and r:
                        off = co + r[0]
                tok = ps.code[f['tok']]
                if comp is not None and co is not None:
                    src = 'both-agree' if comp == co else 'both-disagree'
                elif comp is not None:
                    src = 'computed'
                elif co is not None:
                    src = 'comment'
                else:
                    src = None
                fields.append(collections.OrderedDict([
                    ('name', n), ('offset', co if co is not None else comp), ('size', r[0] if r else None),
                    ('type', f['type'].get('text') or f['type'].get('name')), ('visibility', vis),
                    ('offset_source', src), ('computed_offset', comp), ('comment_offset', co),
                    ('comment', ct), ('line', tok.l)] + ([('file', tok.f)] if tok.f != 'src/delphi3/' + rel else [])))
        csize = None
        if off is not None:
            csize = (off + 3) // 4 * 4
        e = cdb_entry(name, modfile)
        tok = ps.code[ti]
        res = collections.OrderedDict([
            ('name', name), ('module', mod), ('unit', unit), ('file', tok.f), ('line', tok.l),
            ('parent', parent), ('size', e['size'] if e and e.get('size') is not None else csize),
            ('size_source', 'classes.json' if e and e.get('size') is not None else ('computed' if csize is not None else None)),
            ('classes_json_size', e.get('size') if e else None), ('computed_size', csize),
            ('comment_size', comment_size), ('base_offset', base), ('base_offset_source', base_src),
            ('default_visibility', 'published' if published_default else 'public'),
            ('fields', fields)])
        if not e and name in cdb:
            res['classes_json_module'] = cdb[name].get('module')
        memo[key] = res
        return res

    out = collections.OrderedDict()
    summary = collections.OrderedDict()
    for mod in TARGETS:
        lst = []
        for unit, m, rel, ps, tys in units:
            if m != mod:
                continue
            for n, ty, ti in tys:
                if ty['k'] == 'class' and not ty.get('forward') and ty['kind'] == 'class':
                    lst.append(layout((unit, m, rel, ps, n, ty, ti)))
        lst = [x for x in lst if x]
        out[mod] = lst
    doc = collections.OrderedDict([
        ('generator', 'gen_class_layouts.py'),
        ('rules', 'Delphi 3 defaults ($A+, $Z1, $H+, $M- except TPersistent descendants); fields aligned to '
                  'min(size,4) (record: largest field, array: element, packed: 1); own fields start at the '
                  'parent instance size (classes.json, else computed); instance size rounded up to 4'),
        ('modules', out)])
    with open(OUT, 'w', encoding='utf-8', newline='\n') as fh:
        json.dump(doc, fh, indent=1)
        fh.write('\n')
    # summary to stdout
    for mod, lst in out.items():
        nf = sum(len(c['fields']) for c in lst)
        unk = sum(1 for c in lst for f in c['fields'] if f['size'] is None)
        agree = sum(1 for c in lst if c['classes_json_size'] is not None and c['computed_size'] == c['classes_json_size'])
        mism = [c for c in lst if c['classes_json_size'] is not None and c['computed_size'] is not None
                and c['computed_size'] != c['classes_json_size']]
        nocomp = sum(1 for c in lst if c['classes_json_size'] is not None and c['computed_size'] is None)
        nocdb = sum(1 for c in lst if c['classes_json_size'] is None)
        dis = [(c['name'], f['name'], f['computed_offset'], f['comment_offset']) for c in lst for f in c['fields']
               if f['offset_source'] == 'both-disagree']
        both = sum(1 for c in lst for f in c['fields'] if f['offset_source'] in ('both-agree', 'both-disagree'))
        print('%-9s classes=%d fields=%d unsized=%d size_agree=%d size_mismatch=%d size_uncomputed=%d '
              'not_in_classes.json=%d offset_both=%d offset_disagree=%d' %
              (mod, len(lst), nf, unk, agree, len(mism), nocomp, nocdb, both, len(dis)))
        for c in mism:
            print('   SIZE', c['name'], 'computed', c['computed_size'], 'classes.json', c['classes_json_size'])
        for d in dis:
            print('   OFF ', *d)


if __name__ == '__main__':
    main()
