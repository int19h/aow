"""Turn decompiled TEObject.ReadWrite methods into a table of persisted fields.

Usage: readwrite_table.py <decomp dir> [out.md]

Each ReadWrite calls the storage stream through its VMT:
    (**(code **)(*param_2 + 0x30))(param_2, param_1 + 0x26, 6)   ->  rwByte(Self+$26, id 6)
The slot number names the rw method (TEStorageStream VMT, see notes/persistence.md), the second
argument is the field, the last one is the property id. Calls that go through a local variable or a
nested object are listed as "indirect" so that nothing is silently dropped.
"""
import os, re, sys, collections

SLOTS = {0x00: 'StorageMode', 0x04: 'OpenPropertyStream', 0x08: 'rwCreateEObject', 0x0C: 'rwEObject',
         0x10: 'rwEObjectStream', 0x14: 'rwChildren', 0x18: 'rwStreamProc', 0x1C: 'rwData', 0x20: 'rwString',
         0x24: 'rwStrings', 0x28: 'rwStringsEx', 0x2C: 'rwInteger', 0x30: 'rwByte', 0x34: 'rwWord',
         0x38: 'rwBool', 0x3C: 'rwShortint', 0x40: 'rwIntegerEx', 0x44: 'rwByteEx', 0x48: 'rwWordEx',
         0x4C: 'rwShortintEx'}
SIZES = {'rwInteger': 4, 'rwIntegerEx': 4, 'rwByte': 1, 'rwByteEx': 1, 'rwWord': 2, 'rwWordEx': 2,
         'rwBool': 1, 'rwShortint': 1, 'rwShortintEx': 1, 'rwString': 4, 'rwStrings': 4, 'rwStringsEx': 4,
         'rwEObject': 4, 'rwCreateEObject': 4}

CALL = re.compile(r'\(\*\*\(code \*\*\)\(\*(\w+) \+ (0x[0-9a-f]+)\)\)\s*\(([^;]*?)\);', re.S)
PARENT = re.compile(r'^\s+(\w+_T\w+_ReadWrite)_[0-9A-F]{8}\((\w+),(\w+)\);', re.M)


def parse_args(s):
    depth = 0; cur = ''; out = []
    for ch in s:
        if ch == ',' and depth == 0:
            out.append(cur.strip()); cur = ''
        else:
            cur += ch
            if ch in '([': depth += 1
            if ch in ')]': depth -= 1
    if cur.strip(): out.append(cur.strip())
    return out


def field_expr(e, self_name, self_scale=1):
    """Return the byte offset for 'param_1 + 0x26', '(int)param_1 + 0x47', 'param_1[3]', or None.

    When Ghidra declared Self as 'int *', 'param_1 + 3' is pointer arithmetic (offset 12) while
    '(int)param_1 + 3' is a byte offset; self_scale carries the element size (4) in that case."""
    e = e.strip()
    byte_cast = e.startswith('(int)')
    e = e.replace('(int)', '').strip()
    m = re.fullmatch(re.escape(self_name) + r'\s*\+\s*(0x[0-9a-f]+|\d+)', e)
    if m:
        return int(m.group(1), 0) * (1 if byte_cast else self_scale)
    m = re.fullmatch(re.escape(self_name) + r'\[(0x[0-9a-f]+|\d+)\]', e)
    if m:
        return int(m.group(1), 0) * 4
    if e == self_name:
        return 0
    # an object field passed by value: *(undefined4 *)(param_1 + 0x74)
    m = re.fullmatch(r'\*\((?:undefined4|int|uint) \*\*?\)\(' + re.escape(self_name) + r'\s*\+\s*(0x[0-9a-f]+|\d+)\)', e)
    if m:
        return int(m.group(1), 0)
    return None


def analyze(path):
    text = open(path, encoding='utf-8', errors='replace').read()
    m = re.search(r'^\w[\w \*]*?(\w+)\((\w+ \*?\*?)?(\w+),(?:\w+ \*?\*?)?(\w+)', text, re.M)
    if not m:
        return None
    self_name, stream_name = m.group(3), m.group(4)
    self_scale = 4 if (m.group(2) or '').strip().endswith('*') else 1
    parent = PARENT.search(text)
    rows = []
    for call in CALL.finditer(text):
        obj, slot, args = call.group(1), int(call.group(2), 16), parse_args(call.group(3))
        if obj != stream_name:
            continue
        name = SLOTS.get(slot, 'slot%X' % slot)
        if name in ('StorageMode',):
            continue
        a = args[1:]  # drop the stream itself
        if name == 'rwStreamProc' and len(a) >= 2:
            # rwStreamProc(id, obj, loadproc, saveproc): the id comes first
            a = [a[1], a[0]] + a[2:]
        off = field_expr(a[0], self_name, self_scale) if a else None
        pid = a[-1] if len(a) >= 2 else ''
        if name == 'rwStreamProc' and len(a) >= 2:
            pid = a[1]
        extra = ''
        if name in ('rwData', 'rwIntegerEx', 'rwByteEx', 'rwWordEx', 'rwShortintEx'):
            if len(a) >= 3:
                extra = a[1]
            elif len(a) == 2:
                # Ghidra dropped the trailing id argument; what is left is the size or default
                extra, pid = a[1], ''
        rows.append((name, off, pid, extra, a[0] if off is None else ''))
    return self_name, parent.group(1) if parent else None, rows


def main():
    d = sys.argv[1]
    out = []
    files = sorted(f for f in os.listdir(d) if f.endswith('.c'))
    for f in files:
        m = re.match(r'[0-9a-f]+_(\w+?)\.(T\w+)\.ReadWrite_', f)
        if not m:
            continue
        unit, cls = m.groups()
        r = analyze(os.path.join(d, f))
        if r is None:
            continue
        _, parent, rows = r
        ptxt = (' : ' + parent.replace('_ReadWrite', '').replace('_', '.', 1).replace('_', '.')) if parent else ''
        out.append('## %s.%s%s' % (unit, cls, ptxt))
        out.append('')
        out.append('| id | rw | offset | size | note |')
        out.append('|---|---|---|---|---|')
        for name, off, pid, extra, raw in rows:
            size = SIZES.get(name, '')
            if name == 'rwData' and extra:
                size = extra
            note = ''
            if name in ('rwIntegerEx', 'rwByteEx', 'rwWordEx', 'rwShortintEx') and extra:
                note = 'default ' + extra
            if raw:
                note = ('indirect: ' + raw[:60]).replace('|', '\\|')
            out.append('| %s | %s | %s | %s | %s |' % (pid, name, ('+$%02X' % off) if off is not None else '', size, note))
        out.append('')
    text = '\n'.join(out)
    if len(sys.argv) > 2:
        open(sys.argv[2], 'w', encoding='utf-8').write(text)
        print('%d classes -> %s' % (text.count('\n## '), sys.argv[2]))
    else:
        print(text)


main()
