"""Derive field names from getters and setters in decompiled output.

Usage: field_names.py <decomp dir> [out.md] [classes.json]

Works on raw output (Self is "int param_1") and on typed output (Self is "TClass *this", after
tools/ghidra/ApplyDelphiClasses.java). Recognized shapes:
    return *(undefined4 *)(param_1 + 0x48);            return *(int *)&this->field_0x48;
    return (uint)*(byte *)(param_1 + 0x26);            return this->prop_c;        (name resolved via classes.json)
    return param_1[0x12];
    System__LStrLAsg_...(param_2, <field>);            string getter -> FName: String
    <field> = param_2;  as the first statement          setter
    return Unit_TClass_GetX_...(<field of class type>); delegation -> F<Class>: TClass
The script collects (class, offset, name, type) and prints one table per class.
"""
import json, os, re, sys, collections

FILE = re.compile(r'^[0-9a-f]+_(\w+?)\.(T\w+)\.(Get|Set)(\w+?)_[0-9A-F]{8}\.c$')
CTOR_FILE = re.compile(r'^[0-9a-f]+_(\w+?)\.(T\w+)\.Create_[0-9A-F]{8}\.c$')
# In a constructor, "VAR = <ctor call>(...)" followed by "FIELD = VAR" (or "FIELD = <ctor call>" directly)
# gives the class of an embedded object. Three call shapes occur:
#   AoWE_TItemControl_Create_HASH(...)                         own constructor of the class
#   Engine_TEObject_Create_HASH(&AoWE__TAoWHSMapKeyboard_HASH,1,0)   inherited constructor, class passed first
#   System_TObject_Create_HASH(Classes__TList_HASH_exref,1)   plain TObject.Create with the class
CTOR_CALL = re.compile(r'(?:(?P<unit>\w+?)_(?P<cls>T\w+?)_Create_[0-9A-F]{8}\s*\((?!\s*&?\w+__T)'
                       r'|\w+_Create_[0-9A-F]{8}\s*\(\s*(?:\(\w+ \*\))?&?(?P<unit2>\w+?)__(?P<cls2>T\w+?)_[0-9A-F]{8})')
ASSIGN = re.compile(r'^(?P<lhs>.+?) = (?:\((?:\w+ \*?)\))?\s*(?P<rhs>.+)$', re.S)
RAW_OFF = r'(?:\(int\))?param_1 \+ (0x[0-9a-f]+|\d+)'
# a field access, raw or typed; group 'type' = C type when visible, 'off' = hex offset, 'name' = struct field name
FIELD = (r'(?:\*\((?P<type>\w+(?: \*)?) \*\)\(' + RAW_OFF.replace('(0x', '(?P<off>0x') + r'\)'
         r'|\*\((?P<type2>\w+(?: \*)?) \*\)&this->field_0x(?P<off2>[0-9a-f]+)'
         r'|this->field_0x(?P<off3>[0-9a-f]+)'
         r'|this->(?P<name>[A-Za-z]\w*)'
         r'|param_1\[(?P<idx>0x[0-9a-f]+|\d+)\])')
CAST = r'(?:\((?:u?int|byte|char|short|ushort|uint|undefined4)\))?'
GET = re.compile(r'return ' + CAST + FIELD + r';')
GET_STR = re.compile(r'System__LStr(?:L)?Asg_\w+\(param_2,' + FIELD + r'\);')
GET_DELEG = re.compile(r'(?:return |\w+ = )?(?P<unit>\w+?)_(?P<cls>T\w+?)_Get\w+_[0-9A-F]{8}\s*\(' + CAST + FIELD)
SET = re.compile(r'^' + FIELD + r' = ' + CAST + r'param_2;')
SET_STR = re.compile(r'System__LStr(?:L)?Asg_\w+\(&?' + FIELD + r',param_2\);')


def body_statements(text):
    body = re.sub(r'/\*.*?\*/', '', text.split('{', 1)[-1], flags=re.S)
    stmts = [s.strip().strip('}').strip() for s in body.split(';')]
    stmts = [s for s in stmts if s]
    return [s for s in stmts if not re.match(r'^(undefined|u?int|char|code|short|byte|float|double|long|bool|ushort|ulong|T\w+ \*)[0-9 \*]*\s+\w+(\s*\[\d+\])?$', s)]


def main():
    d = sys.argv[1]
    out_path = sys.argv[2] if len(sys.argv) > 2 else None
    name_to_off = collections.defaultdict(dict)   # cls -> field name -> offset (for "this->prop_c")
    # prefer the classes.json snapshot stored next to the dump (the names the structs had when typed)
    snapshot = os.path.join(d, 'classes.json')
    cdb_path = snapshot if os.path.exists(snapshot) else (sys.argv[3] if len(sys.argv) > 3 else None)
    if cdb_path:
        cdb = json.load(open(cdb_path, encoding='utf-8'))['classes']
        for cls, e in cdb.items():
            chain = []
            p = cls
            while p in cdb and len(chain) < 64:
                chain.append(p); p = cdb[p]['parent']
            for c in reversed(chain):
                for off, fd in cdb[c]['fields'].items():
                    if 'name' in fd: name_to_off[cls][fd['name']] = int(off)

    def resolve(m, cls):
        """offset and C type of a FIELD match, or None."""
        g = m.groupdict()
        if g.get('off'): return int(g['off'], 0), g.get('type') or ''
        if g.get('off2'): return int(g['off2'], 16), g.get('type2') or ''
        if g.get('off3'): return int(g['off3'], 16), ''
        if g.get('idx'): return int(g['idx'], 0) * 4, 'int'
        if g.get('name'):
            off = name_to_off.get(cls, {}).get(g['name'])
            return (off, '') if off is not None else None
        return None

    fields = collections.defaultdict(dict)   # (unit, cls) -> off -> (name, type, rank)
    for f in os.listdir(d):
        cm = CTOR_FILE.match(f)
        if cm:
            unit, cls = cm.groups()
            text = open(os.path.join(d, f), encoding='utf-8', errors='replace').read()
            var_class = {}
            for st in body_statements(text):
                a = ASSIGN.match(st)
                if not a:
                    continue
                lhs, rhs = a.group('lhs').strip(), a.group('rhs').strip()
                c = CTOR_CALL.search(rhs)
                tcls = (c.group('cls') or c.group('cls2')) if c else var_class.get(rhs)
                if not tcls:
                    continue
                fm = re.match(r'^(?:' + FIELD + r')$', lhs)
                if fm is None:
                    if re.fullmatch(r'\w+', lhs):
                        var_class[lhs] = tcls      # temp variable holding the new object
                    continue
                r = resolve(fm, cls)
                if not r:
                    continue
                existing = fields[(unit, cls)].get(r[0])
                # rank 3 is the weakest: a getter or setter name wins, the class type is still useful
                name = existing[0] if existing else 'F' + tcls[1:]
                if existing is None:
                    fields[(unit, cls)][r[0]] = (name, tcls, 3)
                elif not existing[1] or existing[1] in ('int', 'undefined4', 'pointer'):
                    fields[(unit, cls)][r[0]] = (existing[0], tcls, existing[2])
            continue
        m = FILE.match(f)
        if not m:
            continue
        unit, cls, prefix, name = m.groups()
        text = open(os.path.join(d, f), encoding='utf-8', errors='replace').read()
        stmts = body_statements(text)
        if not stmts:
            continue
        hits = []   # (off, fieldname, type, rank) lower rank wins
        if prefix == 'Get':
            if len(stmts) <= 2:
                for rx, t in ((GET, None), (GET_STR, 'String')):
                    g = rx.search(text)
                    if g:
                        r = resolve(g, cls)
                        if r: hits.append((r[0], 'F' + name, t or r[1], 0))
            g = GET_DELEG.search(text)
            if g:
                r = resolve(g, cls)
                if r: hits.append((r[0], 'F' + g.group('cls')[1:], g.group('cls'), 2))
        else:
            first = stmts[0] + ';'
            for rx, t in ((SET, None), (SET_STR, 'String')):
                s = rx.search(first)
                if s:
                    r = resolve(s, cls)
                    if r: hits.append((r[0], 'F' + name, t or r[1], 1))
        for off, fname, ctype, rank in hits:
            cur = fields[(unit, cls)].get(off)
            if cur is None or rank < cur[2]:
                fields[(unit, cls)][off] = (fname, ctype, rank)
    out = []
    for (unit, cls), offs in sorted(fields.items()):
        out.append('## %s.%s' % (unit, cls))
        out.append('')
        out.append('| offset | field | c type | from |')
        out.append('|---|---|---|---|')
        for off in sorted(offs):
            fname, ctype, rank = offs[off]
            out.append('| +$%02X | %s | %s | %s |' % (off, fname, ctype, {0: 'getter', 1: 'setter', 2: 'delegation', 3: 'constructor'}[rank]))
        out.append('')
    text = '\n'.join(out)
    if out_path:
        open(out_path, 'w', encoding='utf-8').write(text)
        print('%d classes, %d fields -> %s' % (len(fields), sum(len(v) for v in fields.values()), out_path))
    else:
        print(text)


main()
