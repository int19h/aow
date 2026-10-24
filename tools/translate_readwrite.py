"""Generate a Pascal object model whose ReadWrite methods replay the original persistence calls.

Usage: translate_readwrite.py <classes.json> <embedded.json> <out.pas> <decomp dir> [<decomp dir> ...]

Input decomp dirs hold typed Ghidra output of *.ReadWrite methods (after ApplyDelphiClasses with the
exact storage stream prototypes) plus a classes.json snapshot. The generated unit builds on
src/recovered/Engine.pas: every class with a ReadWrite becomes a class deriving from the nearest
translated ancestor or from the matching Engine base class, with
  - one field per persisted property (typed by the rw call),
  - fields for embedded objects (rwEObject), created in the constructor with the class recorded in
    embedded.json (what the save walker found) or in classes.json,
  - ClassID from the decompiled constants,
  - a ReadWrite that replays the calls in order; conditions on StorageMode are kept, everything the
    translator does not understand is left as a TODO comment and listed in the report.
The goal is a byte-exact round trip of real save files (tests/roundtrip.pas), which validates the
translation of every class that occurs in them.
"""
import json, os, re, sys, collections

ENGINE_BASES = {'TEObject', 'TECustomNode', 'TENode', 'TEControlStyleNode', 'TEControlStyleObject', 'TEngine'}
LIST_CLASSES = {'TIntegerList', 'TByteList', 'TShortIntList', 'TWordList', 'TBitList'}   # EngineLists.pas, not TEObjects
RW_FIELD_TYPE = {'rwInteger': 'Integer', 'rwIntegerEx': 'Integer', 'rwByte': 'Byte', 'rwByteEx': 'Byte',
                 'rwWord': 'Word', 'rwWordEx': 'Word', 'rwBool': 'Boolean', 'rwShortint': 'Shortint',
                 'rwShortintEx': 'Shortint', 'rwString': 'string', 'rwStrings': 'TStringList',
                 'rwStringsEx': 'TStringList'}
CALL_RE = re.compile(r'\(\*stream->vtbl->(\w+)\)\s*\((.*)\)$', re.S)
PAS_KEYWORDS = set('and array as asm begin case class const constructor destructor div do downto else end except '
                   'exports file finalization finally for function goto if implementation in inherited initialization '
                   'inline interface is label library mod nil not object of or out packed procedure program property '
                   'raise record repeat resourcestring set shl shr string then threadvar to try type unit until uses var '
                   'while with xor name index read write default message result self'.split())


def ident(s):
    s = re.sub(r'[^A-Za-z0-9_]', '_', s or '')
    if not s or s[0].isdigit():
        s = '_' + s
    if s.lower() in PAS_KEYWORDS:
        s += '_'
    return s


# ---------------------------------------------------------------- C statement parsing

def split_args(s):
    depth, cur, out = 0, '', []
    for ch in s:
        if ch == ',' and depth == 0:
            out.append(cur.strip()); cur = ''
        else:
            cur += ch
            if ch in '([': depth += 1
            if ch in ')]': depth -= 1
    if cur.strip():
        out.append(cur.strip())
    return out


def parse_block(text, i, n):
    """Parse statements from text[i:] until the matching '}' (or end). Returns (stmts, index)."""
    stmts = []
    while i < n:
        while i < n and text[i] in ' \t\r\n':
            i += 1
        if i >= n:
            break
        if text[i] == '}':
            return stmts, i + 1
        if text.startswith('/*', i):
            j = text.find('*/', i)
            i = j + 2 if j >= 0 else n
            continue
        if text.startswith('if', i) and re.match(r'if\s*\(', text[i:]):
            j = text.index('(', i)
            depth, k = 0, j
            while k < n:
                if text[k] == '(': depth += 1
                elif text[k] == ')':
                    depth -= 1
                    if depth == 0: break
                k += 1
            cond = text[j + 1:k].strip()
            k += 1
            while text[k] in ' \t\r\n': k += 1
            if text[k] == '{':
                body, k = parse_block(text, k + 1, n)
            else:
                body, k = parse_block_one(text, k, n)
            els = None
            m = re.match(r'\s*else\s*', text[k:])
            if m:
                k += m.end()
                if text.startswith('if', k) and re.match(r'if\s*\(', text[k:]):
                    els, k = parse_block_one(text, k, n)
                elif text[k] == '{':
                    els, k = parse_block(text, k + 1, n)
                else:
                    els, k = parse_block_one(text, k, n)
            stmts.append(('if', cond, body, els))
            i = k
            continue
        if re.match(r'(do|while|for|switch)\b', text[i:]):
            # opaque: swallow the whole construct including its block(s)
            k = i
            brace = text.find('{', k)
            semi = text.find(';', k)
            if brace == -1 or (semi != -1 and semi < brace):
                k = semi + 1
            else:
                depth, k = 0, brace
                while k < n:
                    if text[k] == '{': depth += 1
                    elif text[k] == '}':
                        depth -= 1
                        if depth == 0: break
                    k += 1
                k += 1
                m = re.match(r'\s*while\s*\((.*?)\)\s*;', text[k:], re.S)   # do { } while (...);
                if m: k += m.end()
            stmts.append(('opaque', text[i:k].strip()))
            i = k
            continue
        if text.startswith('goto', i) or re.match(r'LAB_[0-9a-f]+:', text[i:]):
            j = text.find('\n', i)
            stmts.append(('opaque', text[i:j].strip()))
            i = j + 1
            continue
        if text[i] == '{':
            body, i = parse_block(text, i + 1, n)
            stmts.extend(body)
            continue
        j = text.find(';', i)
        if j == -1:
            break
        stmt = text[i:j].strip()
        # a call's argument list may contain ';'-free newlines; collapse whitespace
        stmts.append(('stmt', re.sub(r'\s+', ' ', stmt)))
        i = j + 1
    return stmts, i


def parse_block_one(text, i, n):
    """A single statement (possibly an if) used as an if/else body without braces."""
    stmts, k = parse_block(text + '}', i, n + 1) if False else (None, None)
    # parse exactly one statement: reuse parse_block on a slice ending at the first ';' at depth 0
    sub, k = _one(text, i, n)
    return sub, k


def _one(text, i, n):
    while text[i] in ' \t\r\n': i += 1
    if text.startswith('if', i):
        stmts, k = parse_block(text[:n], i, n)   # parse_block will stop at '}' which is not there...
    # simple approach: find end of this statement
    if text[i] == '{':
        return parse_block(text, i + 1, n)
    if re.match(r'if\s*\(', text[i:]):
        # delegate: wrap in braces virtually by parsing until the if is complete
        depth = 0; k = i
        # find the end: after the if's body (block or ;) and optional else chain
        k = text.index('(', i)
        d = 0
        while True:
            if text[k] == '(': d += 1
            elif text[k] == ')':
                d -= 1
                if d == 0: break
            k += 1
        k += 1
        while text[k] in ' \t\r\n': k += 1
        if text[k] == '{':
            d = 0
            while True:
                if text[k] == '{': d += 1
                elif text[k] == '}':
                    d -= 1
                    if d == 0: break
                k += 1
            k += 1
        else:
            k = text.index(';', k) + 1
        m = re.match(r'\s*else\s*', text[k:])
        if m:
            k2 = k + m.end()
            sub, k3 = _one(text, k2, n)
            end = k3
        else:
            end = k
        stmts, _ = parse_block(text[:end] + '}', i, end + 1)
        return stmts, end
    j = text.index(';', i)
    return [('stmt', re.sub(r'\s+', ' ', text[i:j].strip()))], j + 1


# ---------------------------------------------------------------- translation

class ClassModel:
    def __init__(self, name):
        self.name = name
        self.parent = None
        self.fields = collections.OrderedDict()   # name -> (pastype, init_class or None)
        self.body = []
        self.todos = []
        self.locals = collections.OrderedDict()


class Translator:
    def __init__(self, cdb, embedded, snapshot_names):
        self.cdb = cdb
        self.embedded = embedded
        self.names = snapshot_names      # cls -> field name -> offset (from the dump's classes.json)
        self.models = {}

    def thunk_class(self, m, addr):
        """An import thunk address (jmp [IAT]) in the class's module -> the class of the imported
        LoadFromStream/SaveToStream, e.g. 0x55702f4c -> TByteList."""
        module = self.cdb.get(m.name, {}).get('module')
        if not module:
            return None
        if not hasattr(self, '_thunks'):
            self._thunks = {}
        if module not in self._thunks:
            table = {}
            try:
                import pefile
                game = os.environ.get('AOW_GAME_DIR', r'D:\Games\GOG\Age of Wonders')
                pe = pefile.PE(os.path.join(game, module), fast_load=True)
                pe.parse_data_directories(directories=[pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT']])
                base = pe.OPTIONAL_HEADER.ImageBase
                data = pe.get_memory_mapped_image()
                iat = {}
                for entry in getattr(pe, 'DIRECTORY_ENTRY_IMPORT', []):
                    for imp in entry.imports:
                        if imp.name:
                            iat[imp.address] = imp.name.decode('latin1')
                import struct
                i = data.find(b'\xff\x25')
                while i != -1:
                    target = struct.unpack_from('<I', data, i + 2)[0]
                    if target in iat:
                        table[base + i] = iat[target]
                    i = data.find(b'\xff\x25', i + 1)
            except Exception:
                pass
            self._thunks[module] = table
        name = self._thunks[module].get(addr)
        mm = re.match(r'\w+\.(T\w+)\.(?:LoadFromStream|SaveToStream)@', name or '')
        return mm.group(1) if mm else None

    def field_for(self, m, expr, rw):
        """Map a C argument expression to a model field name; declare the field. Returns Pascal expr or None."""
        e = expr.strip()
        e = re.sub(r'^\((?:void|int|undefined\d?|char|byte|short|ushort|uint) \*?\)', '', e).strip()
        mm = re.match(r'^&?this->(\w+)$', e)
        if mm:
            fname = ident(mm.group(1))
            ftype = RW_FIELD_TYPE.get(rw, 'Integer')
            if rw == 'rwData':
                ftype = None          # set by caller with the size
            m.fields.setdefault(fname, [ftype, None])
            return fname
        mm = re.match(r'^\*\((\w+(?: \*)?) \*\*?\)&this->(\w+)$', e)
        if mm:
            fname = ident(mm.group(2))
            m.fields.setdefault(fname, [RW_FIELD_TYPE.get(rw, 'Integer'), None])
            return fname
        mm = re.match(r'^&?(\w+)$', e)
        if mm and not mm.group(1).startswith('this'):
            # a local in the original: keep it as a model field so that the value survives read -> write
            fname = 'L_' + ident(mm.group(1))
            m.fields.setdefault(fname, [RW_FIELD_TYPE.get(rw, 'Integer'), None])
            return fname
        mm = re.match(r'^\(?\(int\)&(\w+) \+ (\d+)\)?$', e)        # part of a local: ((int)&uStack_8 + 2)
        if mm:
            fname = 'L_' + ident(mm.group(1)) + '_' + mm.group(2)
            m.fields.setdefault(fname, [RW_FIELD_TYPE.get(rw, 'Integer'), None])
            return fname
        return None

    def translate_call(self, m, rw, args, indent):
        a = args[1:]                      # drop the stream
        out = []
        if rw == 'StorageMode':
            return out
        if rw in ('rwInteger', 'rwByte', 'rwWord', 'rwBool', 'rwShortint', 'rwString', 'rwStrings', 'rwStringsEx'):
            if len(a) != 2: return None
            f = self.field_for(m, a[0], rw)
            if f is None: return None
            out.append('%sStream.%s(%s, %s);' % (indent, rw, f, a[1]))
        elif rw in ('rwIntegerEx', 'rwByteEx', 'rwWordEx', 'rwShortintEx'):
            if len(a) != 3: return None
            f = self.field_for(m, a[0], rw)
            if f is None: return None
            out.append('%sStream.%s(%s, %s, %s);' % (indent, rw, f, a[1], a[2]))
        elif rw == 'rwData':
            if len(a) != 3: return None
            f = self.field_for(m, a[0], rw)
            if f is None: return None
            try:
                n = int(a[1], 0)
            except ValueError:
                return None
            m.fields[f][0] = 'Byte' if n == 1 else 'array[0..%d] of Byte' % (n - 1)
            out.append('%sStream.rwData(%s, %d, %s);' % (indent, f, n, a[2]))
        elif rw == 'rwEObject':
            if len(a) != 2: return None
            mm = re.match(r'^(?:\(\w+ \*\))?this->(\w+)$', a[0].strip()) or \
                 re.match(r'^\*\((?:void|int|undefined4) \*\*?\)&this->(\w+)$', a[0].strip())
            if not mm: return None
            f = ident(mm.group(1))
            pid = a[1]
            try:
                pid_dec = str(int(pid, 0))
            except ValueError:
                pid_dec = pid
            cls = self.embedded.get(m.name, {}).get(pid_dec)
            if not cls:
                # classes.json may know the type of the field
                for off, fd in self.cdb.get(m.name, {}).get('fields', {}).items():
                    if fd.get('name') == mm.group(1) and fd.get('type', '').startswith('T'):
                        cls = fd['type']
            if f in getattr(m, 'created', set()):
                m.fields[f] = ['TEObject', None]   # also passed by var to rwCreateEObject elsewhere
            else:
                m.fields[f] = [cls or 'TEObject', cls or 'TEObject']
            out.append('%sStream.rwEObject(%s, %s);' % (indent, f, pid))
        elif rw == 'rwCreateEObject':
            if len(a) != 3: return None
            mm = re.match(r'^&this->(\w+)$', a[0].strip())
            if not mm: return None
            f = ident(mm.group(1))
            m.fields[f] = ['TEObject', None]      # var parameter: the field must be exactly TEObject
            if not hasattr(m, 'created'):
                m.created = set()
            m.created.add(f)
            owner = 'Self' if a[1].strip() in ('this', '(TEObject *)this') else 'nil'
            out.append('%sStream.rwCreateEObject(%s, %s, %s);' % (indent, f, owner, a[2]))
        elif rw == 'rwChildren':
            if len(a) != 2: return None
            out.append('%sStream.rwChildren(Self, %s);' % (indent, a[1]))
        elif rw == 'rwStreamProc':
            # the decompiler shuffles the argument order of this call; find the pieces by shape:
            # the id is a[0], the object is the this-> expression, the class comes from a named
            # LoadFromStream/SaveToStream or from an import thunk address
            if len(a) < 2: return None
            fname, lcls = None, None
            for arg in a[1:]:
                s = arg.strip()
                mm = re.match(r'^(?:\(\w+ \*\))?this->(\w+)$', s)
                if mm:
                    fname = mm.group(1); continue
                mo = re.match(r'^\*\((?:\w+) \*\*?\)&this->field_0x([0-9a-f]+)$', s) or \
                     re.match(r'^\*\((?:\w+) \*\*?\)\(\(int\)this \+ (0x[0-9a-f]+)\)$', s)
                if mo:
                    fname = 'field_%X' % int(mo.group(1), 16); continue
                mo = re.match(r'^\*\((?:\w+) \*\*?\)&this->(\w+)$', s)
                if mo:
                    fname = mo.group(1); continue
                lm = re.match(r'(\w+?)_(T\w+?)_(?:LoadFromStream|SaveToStream)_', s)
                if lm:
                    lcls = lm.group(2); continue
                ma = re.match(r'^(?:\(void \*\))?(0x[0-9a-f]+)$', s)
                if ma and not lcls:
                    lcls = self.thunk_class(m, int(ma.group(1), 16))
            if not fname: return None
            if not lcls:
                for off, fd in self.cdb.get(m.name, {}).get('fields', {}).items():
                    if fd.get('name') == fname and re.match(r'T\w+List$', fd.get('type', '')):
                        lcls = fd['type']
            if lcls not in LIST_CLASSES:
                return None               # other stream classes (TXYLList, TImageSequenceList, ...) are not translated yet
            f = ident(fname)
            m.fields[f] = [lcls, lcls]
            out.append('%sStream.rwStreamProc(%s, %s.LoadFromStream, %s.SaveToStream);' % (indent, a[0], f, f))
        else:
            return None
        return out

    def translate_cond(self, cond, modes, m=None):
        """Translate an if-condition made of StorageMode tests and simple field tests joined by && / ||.
        Field tests ("this->prop31 != 1", "(this->field_0x5d & 1) == 0", "this->FLeader == (T *)0x0")
        become tests on model fields; unknown fields are declared as Integer so that the shape of the
        original logic survives (their value is 0 in the model unless a rw call fills them)."""
        c = cond.strip()
        return self._cond(c, modes, m)

    def _strip_parens(self, s):
        s = s.strip()
        while s.startswith('(') and s.endswith(')'):
            depth = 0
            ok = True
            for i, ch in enumerate(s):
                if ch == '(': depth += 1
                elif ch == ')':
                    depth -= 1
                    if depth == 0 and i != len(s) - 1:
                        ok = False; break
            if not ok: break
            s = s[1:-1].strip()
        return s

    def _split_top(self, s, op):
        depth, parts, cur, i = 0, [], '', 0
        while i < len(s):
            ch = s[i]
            if ch == '(': depth += 1
            elif ch == ')': depth -= 1
            if depth == 0 and s.startswith(op, i):
                parts.append(cur); cur = ''; i += len(op); continue
            cur += ch; i += 1
        parts.append(cur)
        return parts

    def _cond(self, s, modes, m):
        s = self._strip_parens(s)
        for op, pas in (('||', 'or'), ('&&', 'and')):
            parts = self._split_top(s, op)
            if len(parts) > 1:
                sub = [self._cond(p, modes, m) for p in parts]
                if any(x is None for x in sub):
                    return None
                return ' %s ' % pas + ''.join(())  if False else (' %s ' % pas).join('(%s)' % x for x in sub)
        # atoms
        mm = re.fullmatch(r'\(?(\w+) & (0x[0-9a-fA-F]+|\d+)\)? (==|!=) (0x[0-9a-fA-F]+|\d+)', s)
        if mm and mm.group(1) in modes:
            op = '=' if mm.group(3) == '==' else '<>'
            return '(Stream.StorageMode and %s) %s %s' % (pas_num(mm.group(2)), op, pas_num(mm.group(4)))
        mm = re.fullmatch(r'(\w+) (==|!=) (0x[0-9a-fA-F]+|\d+)', s)
        if mm and mm.group(1) in modes:
            op = '=' if mm.group(2) == '==' else '<>'
            return 'Stream.StorageMode %s %s' % (op, pas_num(mm.group(3)))
        if m is None:
            return None
        # field tests
        mm = re.fullmatch(r'\(?this->(\w+) & (0x[0-9a-fA-F]+|\d+)\)? (==|!=) (0x[0-9a-fA-F]+|\d+)', s)
        if mm:
            f = self.model_field(m, mm.group(1), 'Integer')
            op = '=' if mm.group(3) == '==' else '<>'
            return '(%s and %s) %s %s' % (f, pas_num(mm.group(2)), op, pas_num(mm.group(4)))
        mm = re.fullmatch(r'this->(\w+) (==|!=) (?:\((?:T\w+|void|char|int) \*\))?(0x[0-9a-fA-F]+|\d+)', s)
        if mm:
            f = self.model_field(m, mm.group(1), None)
            op = '=' if mm.group(2) == '==' else '<>'
            val = pas_num(mm.group(3))
            is_zero = int(mm.group(3), 0) == 0
            ftype = m.fields.get(f, ['Integer'])[0] or 'Integer'
            if (ftype.startswith('T') or ftype == 'Pointer') and is_zero:
                val = 'nil'
            elif ftype == 'string' and is_zero:
                val = "''"                # a nil string pointer is the empty string
            elif ftype == 'Boolean':
                val = 'False' if is_zero else 'True'
            return '%s %s %s' % (f, op, val)
        mm = re.fullmatch(r'this->(\w+)', s)
        if mm:
            f = self.model_field(m, mm.group(1), 'Boolean')
            return '%s' % f
        mm = re.fullmatch(r'!this->(\w+)', s)
        if mm:
            f = self.model_field(m, mm.group(1), 'Boolean')
            return 'not %s' % f
        return None

    def model_field(self, m, cname, default_type):
        """Model field for a decompiled field name; declares it when a rw call has not already."""
        f = ident(cname)
        if f not in m.fields:
            m.fields[f] = [default_type or 'Integer', None]
        return f

    def translate_stmts(self, m, stmts, indent, modes):
        out = []
        for st in stmts:
            kind = st[0]
            if kind == 'stmt':
                s = st[1]
                # X = (*stream->vtbl->StorageMode)(stream);
                mm = re.match(r'^(\w+) = \(\*stream->vtbl->StorageMode\)\(stream\)$', s)
                if mm:
                    modes.add(mm.group(1)); continue
                mm = CALL_RE.match(s)
                if mm:
                    res = self.translate_call(m, mm.group(1), split_args(mm.group(2)), indent)
                    if res is None:
                        out.append('%s{ TODO: %s }' % (indent, safe(s))); m.todos.append(s)
                    else:
                        out.extend(re.sub(r'\b0x([0-9a-fA-F]+)\b', lambda h: '$' + h.group(1).upper(), r) for r in res)
                    continue
                mm = re.match(r'^(\w+?)_(T\w+?)_ReadWrite_[0-9A-F]{8}\(', s)
                if mm:
                    # the call names the ancestor whose ReadWrite runs; "inherited" is only right when
                    # that is the model parent. TEObject.ReadWrite is empty, so a direct call to it
                    # (skipping e.g. TEControlStyleNode.ReadWrite) translates to nothing.
                    m.parent_hint = mm.group(2)
                    out.append(('INHERITED', indent, mm.group(2)))
                    continue
                if re.match(r'^(uStack|local|puStack|pcStack|iStack|in_stack)\w* = ', s) or s.startswith('return'):
                    continue
                if re.match(r'^(undefined|u?int|char|code|short|byte|float|double|long|bool|ushort|ulong|void|T\w+)[0-9]* \*?\*?\w+(\s*\[\d+\])?$', s):
                    continue                  # local variable declaration
                out.append('%s{ TODO: %s }' % (indent, safe(s))); m.todos.append(s)
            elif kind == 'if':
                cond = self.translate_cond(st[1], modes, m)
                body = self.translate_stmts(m, st[2], indent + '  ', set(modes))
                els = self.translate_stmts(m, st[3], indent + '  ', set(modes)) if st[3] else None
                if cond is None:
                    out.append('%s{ TODO condition: %s }' % (indent, safe(re.sub(r'\s+', ' ', st[1]))))
                    m.todos.append('if ' + st[1])
                    out.append('%sif True then' % indent)
                else:
                    out.append('%sif %s then' % (indent, cond))
                out.append('%sbegin' % indent)
                out.extend(body or ['%s  { empty }' % indent])
                if els:
                    out.append('%send' % indent)
                    out.append('%selse' % indent)
                    out.append('%sbegin' % indent)
                    out.extend(els)
                out.append('%send;' % indent)
            else:
                text = re.sub(r'\s+', ' ', st[1])
                out.append('%s{ TODO: %s }' % (indent, safe(text[:200])))
                m.todos.append(text[:200])
        return out

    def translate_file(self, path):
        text = open(path, encoding='utf-8', errors='replace').read()
        mm = re.search(r'(\w+?)_(T\w+?)_ReadWrite_[0-9A-F]{8}\s*\(\s*(T\w+) \*this', text)
        if not mm:
            return None
        unit, cls = mm.group(1), mm.group(2)
        if cls in ENGINE_BASES:
            return None                   # hand-written in src/recovered/Engine.pas
        body_start = text.index('{', text.index('_ReadWrite_'))
        stmts, _ = parse_block(text, body_start + 1, len(text))
        m = ClassModel(cls)
        m.unit = unit
        m.parent_hint = None
        m.body = self.translate_stmts(m, stmts, '  ', set())
        self.models[cls] = m
        return m


def safe(s):
    """Text that may go inside a Pascal brace comment."""
    return s.replace('{', '[').replace('}', ']').replace('*)', '* )')


def pas_num(s):
    return '$' + s[2:].upper() if s.startswith('0x') else s


def classid_map(dirs):
    ids = {}
    for d in dirs:
        for f in os.listdir(d):
            mm = re.match(r'[0-9a-f]+_(\w+?)\.(T\w+)\.ClassID_', f)
            if not mm: continue
            r = re.search(r'return (0x[0-9a-fA-F]+|-?\d+);', open(os.path.join(d, f), encoding='utf-8', errors='replace').read())
            if r: ids[mm.group(2)] = int(r.group(1), 0)
    return ids


def main():
    cdb = json.load(open(sys.argv[1], encoding='utf-8'))['classes']
    embedded = json.load(open(sys.argv[2], encoding='utf-8')) if os.path.exists(sys.argv[2]) else {}
    overrides = os.path.join(os.path.dirname(sys.argv[2]), 'embedded-overrides.json')
    if os.path.exists(overrides):
        for cls, m in json.load(open(overrides, encoding='utf-8')).items():
            if not cls.startswith('_'):
                embedded.setdefault(cls, {}).update(m)
    # the walker records guesses under the concrete class (TDeathNode); the rwEObject call lives in an
    # ancestor's ReadWrite (TProductionPlace): make the guesses visible to every ancestor
    cdb_tmp = json.load(open(sys.argv[1], encoding='utf-8'))['classes']
    for cls in list(embedded):
        p = cdb_tmp.get(cls, {}).get('parent')
        while p:
            for pid, sub in embedded[cls].items():
                embedded.setdefault(p, {}).setdefault(pid, sub)
            p = cdb_tmp.get(p, {}).get('parent')
    out_path = sys.argv[3]
    dirs = sys.argv[4:]
    tr = Translator(cdb, embedded, {})
    for d in dirs:
        for f in sorted(os.listdir(d)):
            if '.ReadWrite_' in f and f.endswith('.c'):
                tr.translate_file(os.path.join(d, f))
    # class ids from every typed dump next to the ReadWrite dumps
    id_dirs = [p for p in ('data/decomp/AoWEPACK-typed-all', 'data/decomp/Enginep-typed-all', 'data/decomp/HSEPack-typed-all')
               if os.path.isdir(p)]
    ids = classid_map(id_dirs)

    # Every class with a class id must exist, or rwCreateEObject cannot instantiate it; the same holds
    # for classes used as embedded fields. Classes without a ReadWrite become empty subclasses.
    def is_eobject(cls):
        p = cls
        for _ in range(64):
            if p == 'TEObject': return True
            p = cdb.get(p, {}).get('parent')
            if not p: return False
        return False
    def descends(cls, base):
        p = cls
        for _ in range(64):
            if p == base: return True
            p = cdb.get(p, {}).get('parent')
            if not p: return False
        return False
    # every class with a class id is an engine object by construction (ClassID is a TEObject method);
    # a broken parent chain in classes.json (duplicate names) must not drop it from the model
    needed = set(ids)
    for m in list(tr.models.values()):
        for fname, (ftype, init_cls) in m.fields.items():
            if init_cls and init_cls in cdb and is_eobject(init_cls):
                needed.add(init_cls)
    for c in sorted(needed):
        if c not in tr.models and c not in ENGINE_BASES:
            stub = ClassModel(c)
            stub.unit = cdb.get(c, {}).get('module', '?')
            stub.parent_hint = None
            stub.body = []
            stub.stub = True
            tr.models[c] = stub
    hand_dir = os.path.join(os.path.dirname(out_path), 'hand')

    # resolve parents: nearest ancestor that is a model or an Engine base
    def model_parent(cls):
        p = cdb.get(cls, {}).get('parent')
        while p:
            if p in tr.models or p in ENGINE_BASES:
                return p
            p = cdb.get(p, {}).get('parent')
        return 'TEObject'
    for m in tr.models.values():
        m.parent = model_parent(m.name)
        if m.parent == m.name:
            m.parent = 'TEObject'
        if m.parent == 'TECustomNode':
            m.parent = 'TENode'           # TECustomNode's list interface is abstract; TENode implements it
    # resolve the deferred "inherited" markers now that parents are known
    def chain_of(cls):
        out, p = [], cdb.get(cls, {}).get('parent')
        while p and len(out) < 64:
            out.append(p); p = cdb.get(p, {}).get('parent')
        return out
    for m in tr.models.values():
        resolved = []
        for line in m.body:
            if isinstance(line, tuple) and line[0] == 'INHERITED':
                _, indent, called = line
                if called == m.parent or called not in chain_of(m.name):
                    resolved.append('%sinherited ReadWrite(Stream);' % indent)
                elif called == 'TEObject' or (called == 'TECustomNode' and m.parent == 'TENode'):
                    resolved.append('%s{ the original calls %s.ReadWrite here, skipping %s.ReadWrite }' % (indent, called, m.parent))
                else:
                    resolved.append('%s{ TODO: the original calls %s.ReadWrite directly, not %s.ReadWrite }' % (indent, called, m.parent))
                    resolved.append('%sinherited ReadWrite(Stream);' % indent)
                    m.todos.append('calls %s.ReadWrite directly' % called)
            else:
                resolved.append(line)
        m.body = resolved
    # emit in parent-first order; a cycle (duplicate class names across modules) is cut at TEObject
    order, seen, visiting = [], set(), set()
    def visit(c):
        if c in seen or c not in tr.models: return
        if c in visiting:
            tr.models[c].parent = 'TEObject'
            return
        visiting.add(c)
        visit(tr.models[c].parent)
        visiting.discard(c)
        seen.add(c); order.append(c)
    for c in sorted(tr.models): visit(c)

    L = []
    L.append('unit AoWModel;')
    L.append('')
    L.append('{ Generated by tools/translate_readwrite.py. Object model whose ReadWrite methods replay the original')
    L.append('  persistence calls of every class with a ReadWrite in the decompiled packages. Do not edit; fix the')
    L.append('  translator or add a hand-written override in AoWModelOverrides.inc. }')
    L.append('')
    L.append('{$MODE DELPHI}{$H+}{$WARNINGS OFF}{$HINTS OFF}')
    L.append('')
    L.append('interface')
    L.append('')
    L.append('uses SysUtils, Classes, Engine, EngineLists;')
    L.append('')
    L.append('type')
    for c in order:
        L.append('  %s = class;' % c)
    L.append('')
    impl = []
    for c in order:
        m = tr.models[c]
        hand_decl = os.path.join(hand_dir, c + '.decl.inc')
        hand_impl = os.path.join(hand_dir, c + '.impl.inc')
        if os.path.exists(hand_decl):
            # hand-written class: the include files carry the declaration body and the implementation
            L.append('  { %s.%s: hand-written in hand/%s.decl.inc }' % (m.unit, c, c))
            L.append('  %s = class(%s)' % (c, m.parent))
            L.append('  {$I hand/%s.decl.inc}' % c)
            if c in ids:
                L.append('    function ClassID: Integer; override;')
                impl.append('function %s.ClassID: Integer;\nbegin\n  Result := %d;\nend;\n' % (c, ids[c]))
            L.append('  end;')
            L.append('')
            impl.append('{$I hand/%s.impl.inc}\n' % c)
            continue
        if getattr(m, 'stub', False):
            L.append('  { %s.%s: no ReadWrite of its own }' % (m.unit, c))
            L.append('  %s = class(%s)' % (c, m.parent))
            if c in ids:
                L.append('    function ClassID: Integer; override;')
                impl.append('function %s.ClassID: Integer;\nbegin\n  Result := %d;\nend;\n' % (c, ids[c]))
            L.append('  end;')
            L.append('')
            continue
        L.append('  { %s.%s%s }' % (m.unit, c, ('  (%d TODO)' % len(m.todos)) if m.todos else ''))
        L.append('  %s = class(%s)' % (c, m.parent))
        L.append('  public')
        ctor = []
        for fname, (ftype, init_cls) in m.fields.items():
            L.append('    %s: %s;' % (fname, ftype or 'Byte'))
            if init_cls in LIST_CLASSES:
                ctor.append('  %s := %s.Create;' % (fname, init_cls))
            elif init_cls:
                ctor.append('  %s := %s.Create(Self);' % (fname, init_cls))
                # an embedded object must survive the owner's Clear and must not be written as a child
                ctor.append('  %s.EmbeddedShared := True;' % fname)
                if descends(init_cls, 'TEControlStyleNode'):
                    ctor.append('  TEControlStyleNode(%s).SetControlStyle(csStored or csShared);' % fname)
            elif ftype == 'TStringList':
                ctor.append('  %s := TStringList.Create;' % fname)
        if ctor:
            L.append('    constructor Create(AOwner: TEObject); override;')
            impl.append('constructor %s.Create(AOwner: TEObject);\nbegin\n  inherited Create(AOwner);\n%s\nend;\n' % (c, '\n'.join(ctor)))
        if c in ids:
            L.append('    function ClassID: Integer; override;')
            impl.append('function %s.ClassID: Integer;\nbegin\n  Result := %d;\nend;\n' % (c, ids[c]))
        L.append('    procedure ReadWrite(Stream: TEStorageStream); override;')
        L.append('  end;')
        L.append('')
        impl.append('procedure %s.ReadWrite(Stream: TEStorageStream);\nbegin\n%s\nend;\n' % (c, '\n'.join(m.body) if m.body else '  inherited ReadWrite(Stream);'))
    L.append('')
    L.append('{ class id -> class, for TEngine.CreateEObject }')
    L.append('function ModelClassByID(AClassID: Integer): TEObjectClass;')
    L.append('')
    L.append('implementation')
    L.append('')
    L.extend(impl)
    L.append('function ModelClassByID(AClassID: Integer): TEObjectClass;')
    L.append('begin')
    L.append('  case AClassID of')
    by_id = {}
    for c in order:
        if c in ids:
            cur = by_id.get(ids[c])
            # two classes may report the same id (an abstract base and its concrete child, or duplicate
            # names across modules): prefer a class with a translated ReadWrite over a stub
            if cur is None or (getattr(tr.models[cur], 'stub', False) and not getattr(tr.models[c], 'stub', False)):
                by_id[ids[c]] = c
    for cid in sorted(by_id):
        L.append('    %d: Result := %s;' % (cid, by_id[cid]))
    L.append('  else')
    L.append('    Result := nil;')
    L.append('  end;')
    L.append('end;')
    L.append('')
    L.append('end.')
    os.makedirs(os.path.dirname(out_path), exist_ok=True)
    open(out_path, 'w', encoding='latin1', errors='replace').write('\n'.join(L) + '\n')
    rep = [out_path, '%d classes, %d with TODOs' % (len(order), sum(1 for c in order if tr.models[c].todos)), '']
    for c in order:
        m = tr.models[c]
        if m.todos:
            rep.append('## %s (%d)' % (c, len(m.todos)))
            rep.extend('  ' + t for t in m.todos[:12])
    open(out_path + '.report.txt', 'w', encoding='utf-8').write('\n'.join(rep) + '\n')
    print('\n'.join(rep[:2]))


if __name__ == '__main__':
    main()
