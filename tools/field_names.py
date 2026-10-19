"""Derive field names from getters and setters in decompiled output.

Usage: field_names.py <decomp dir> [out.md]

Recognized shapes (Ghidra output, Delphi register convention, param_1 = Self):
    return *(undefined4 *)(param_1 + 0x48);                 getter          -> FExperience
    return (uint)*(byte *)(param_1 + 0x26);                 getter, cast
    return param_1[0x12];                                    getter, dword index
    System__LStrLAsg_...(param_2, *(undefined4 *)(param_1 + 0x60));   string getter -> FName: String
    *(byte *)(param_1 + 0x26) = param_2;   /  param_1[0x12] = param_2;   setter (first statement)
    return AoWE_TUnitResource_GetDamage_...(*(int *)(param_1 + 0x40));  delegation -> FUnitResource: TUnitResource
The script collects (class, offset, name, type) and prints one table per class.
"""
import os, re, sys, collections

FILE = re.compile(r'^[0-9a-f]+_(\w+?)\.(T\w+)\.(Get|Set)(\w+?)_[0-9A-F]{8}\.c$')
OFF = r'(?:\(int\))?param_1 \+ (0x[0-9a-f]+|\d+)'
GET = re.compile(r'return (?:\((?:u?int|byte|char|short|ushort)\))?\*\((\w+(?: \*)?) \*\)\(' + OFF + r'\);')
GET_IDX = re.compile(r'return (?:\(\w+\))?param_1\[(0x[0-9a-f]+|\d+)\];')
GET_STR = re.compile(r'System__LStr(?:L)?Asg_\w+\(param_2,\*\(undefined4 \*\)\(' + OFF + r'\)\);')
GET_DELEG = re.compile(r'(?:return |\w+ = )?(\w+?)_(T\w+?)_Get\w+_[0-9A-F]{8}\s*\(\*\((?:int|undefined4) \*\)\(' + OFF + r'\)')
SET = re.compile(r'\*\((\w+(?: \*)?) \*\)\(' + OFF + r'\) = (?:\(\w+\))?param_2;')
SET_IDX = re.compile(r'param_1\[(0x[0-9a-f]+|\d+)\] = (?:\(\w+\))?param_2;')
SET_STR = re.compile(r'System__LStr(?:L)?Asg_\w+\(' + OFF + r',param_2\);')

SIZE = {'byte': 1, 'char': 1, 'undefined1': 1, 'bool': 1, 'short': 2, 'ushort': 2, 'undefined2': 2}


def body_statements(text):
    body = text.split('{', 1)[-1]
    stmts = [s.strip() for s in body.split(';') if s.strip() and not s.strip().startswith('/*')]
    # drop local declarations
    return [s for s in stmts if not re.match(r'^(undefined|u?int|char|code|short|byte|float|double|long|bool|ushort|ulong)[0-9 \*]*\s+\w+(\s*\[\d+\])?$', s)
            and not s.startswith('/*')]


def main():
    d = sys.argv[1]
    fields = collections.defaultdict(dict)   # (unit, cls) -> off -> (name, type, via, rank)
    for f in os.listdir(d):
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
                g = GET.search(text)
                if g: hits.append((int(g.group(2), 0), 'F' + name, g.group(1), 0))
                g = GET_IDX.search(text)
                if g: hits.append((int(g.group(1), 0) * 4, 'F' + name, 'int', 0))
                g = GET_STR.search(text)
                if g: hits.append((int(g.group(1), 0), 'F' + name, 'String', 0))
            g = GET_DELEG.search(text)
            if g:
                hits.append((int(g.group(3), 0), 'F' + g.group(2)[1:], g.group(2), 2))
        else:
            first = stmts[0]
            s = SET.search(first + ';')
            if s: hits.append((int(s.group(2), 0), 'F' + name, s.group(1), 1))
            s = SET_IDX.search(first + ';')
            if s: hits.append((int(s.group(1), 0) * 4, 'F' + name, 'int', 1))
            s = SET_STR.search(first + ';')
            if s: hits.append((int(s.group(1), 0), 'F' + name, 'String', 1))
        for off, fname, ctype, rank in hits:
            cur = fields[(unit, cls)].get(off)
            if cur is None or rank < cur[3]:
                fields[(unit, cls)][off] = (fname, ctype, prefix, rank)
    out = []
    for (unit, cls), offs in sorted(fields.items()):
        out.append('## %s.%s' % (unit, cls))
        out.append('')
        out.append('| offset | field | c type | from |')
        out.append('|---|---|---|---|')
        for off in sorted(offs):
            fname, ctype, via, rank = offs[off]
            out.append('| +$%02X | %s | %s | %s |' % (off, fname, ctype, {0: 'getter', 1: 'setter', 2: 'delegation'}[rank]))
        out.append('')
    text = '\n'.join(out)
    if len(sys.argv) > 2:
        open(sys.argv[2], 'w', encoding='utf-8').write(text)
        print('%d classes, %d fields -> %s' % (len(fields), sum(len(v) for v in fields.values()), sys.argv[2]))
    else:
        print(text)


main()
