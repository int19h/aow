"""Walk an Age of Wonders save (.asg) or map (.hsm) with the recovered schema and print what it finds.

Usage: asg_dump.py <file.asg|hsm> <classes.json> <typed decomp dir> [--depth N] [--class TAoWHSMap]

The decomp dir is used for the ClassID -> class name map (every TEObject.ClassID method returns a constant).
The schema is the set of persisted fields (rw + id) of each class chain in classes.json.
The point of this tool is validation: every property id found in a file should be explained by the schema,
and every value read should make sense. Unknown ids are reported per class.

Container: 'CFS\\0', version byte, zlib stream. Inflated: a 16-byte header record (Integer 16 = its size,
'HSM\\0', Integer 0, Integer ClassID), then a root property table with one entry (id 0) that points at the
map object (see notes/persistence.md).
"""
import json, os, re, struct, sys, zlib, collections


class Reader:
    def __init__(self, data):
        self.d = data

    def u8(self, p): return self.d[p]
    def u16(self, p): return struct.unpack_from('<H', self.d, p)[0]
    def i32(self, p): return struct.unpack_from('<i', self.d, p)[0]

    def table(self, p):
        """Parse a property table at p. Returns (entries as ordered list of (id, offset), data base).
        Raises ValueError when the bytes cannot be a table (used to reject false object guesses)."""
        size = len(self.d)
        if p < 0 or p >= size:
            raise ValueError('table start outside data')
        n = self.d[p]; p += 1
        long_n = 0
        if n & 0x80:
            n &= 0x7F
            if p + 4 > size: raise ValueError('truncated table')
            long_n = self.i32(p); p += 4
            if long_n < 0 or long_n > 100000: raise ValueError('bad long count %d' % long_n)
        if p + 2 * n + 8 * long_n > size:
            raise ValueError('table runs past the data')
        entries = []
        for _ in range(n):
            entries.append((self.d[p], self.d[p + 1])); p += 2
        for _ in range(long_n):
            entries.append((self.i32(p), self.i32(p + 4))); p += 8
        for pid, off in entries:
            if off < 0 or pid < 0 or p + off > size:
                raise ValueError('entry offset outside data')
        return entries, p

    def string(self, p):
        """Engine string: one length byte, or $FF followed by an Integer length, then the bytes."""
        n = self.d[p]; p += 1
        if n == 0xFF:
            n = self.i32(p); p += 4
        if 0 <= n < 1000000:
            return self.d[p: p + n].decode('latin1')
        return '<bad string length %d>' % n


def classid_map(decomp_dir):
    m = {}
    for f in os.listdir(decomp_dir):
        mm = re.match(r'[0-9a-f]+_(\w+?)\.(T\w+)\.ClassID_', f)
        if not mm:
            continue
        txt = open(os.path.join(decomp_dir, f), encoding='utf-8', errors='replace').read()
        r = re.search(r'return (0x[0-9a-fA-F]+|-?\d+);', txt)
        if r:
            m[int(r.group(1), 0)] = mm.group(2)
    return m


def schema_for(cdb, cls):
    """{id: (name, rw, size, type, owner class)} over the class chain; a subclass overrides nothing here."""
    out = {}
    chain, p = [], cls
    while p in cdb and len(chain) < 64:
        chain.append(p); p = cdb[p]['parent']
    for c in reversed(chain):
        for off, fd in cdb[c]['fields'].items():
            if 'rw' in fd and fd.get('id'):
                try:
                    pid = int(fd['id'], 0)
                except ValueError:
                    continue
                out[pid] = (fd.get('name', '?'), fd['rw'], fd.get('size', 0), fd.get('type', ''), c)
    # TECustomNode.MainReadWrite calls ReadWriteChildren after ReadWrite: rwChildren(Self, 1).
    # Every node therefore has its child list under id 1, outside its own ReadWrite.
    if 'TECustomNode' in chain and 1 not in out:
        out[1] = ('Children', 'rwChildren', 0, '', 'TECustomNode')
    return out


class Walker:
    def __init__(self, rd, cdb, ids, max_depth):
        self.rd, self.cdb, self.ids, self.max_depth = rd, cdb, ids, max_depth
        self.unknown = collections.defaultdict(collections.Counter)
        self.seen = collections.Counter()

    def guess_class(self, p):
        """Pick the class whose persisted ids best cover the property table at p (ties: smallest schema)."""
        entries, _ = self.rd.table(p)
        ids = set(e[0] for e in entries)
        if not ids:
            return None
        best, best_key = None, None
        for cls in self.cdb:
            sch = schema_for(self.cdb, cls)
            if not sch:
                continue
            covered = len(ids & set(sch))
            if covered == 0:
                continue
            key = (covered, -len(sch))
            if best_key is None or key > best_key:
                best, best_key = cls, key
        if best is not None and best_key[0] >= max(1, len(ids) // 2):
            return best
        return None

    def value(self, rw, p, size):
        rd = self.rd
        if rw in ('rwInteger', 'rwIntegerEx'): return rd.i32(p)
        if rw in ('rwByte', 'rwByteEx', 'rwBool'): return rd.u8(p)
        if rw in ('rwWord', 'rwWordEx'): return rd.u16(p)
        if rw in ('rwShortint', 'rwShortintEx'): return struct.unpack_from('<b', rd.d, p)[0]
        if rw == 'rwString': return repr(rd.string(p))
        if rw == 'rwData': return rd.d[p:p + max(1, size or 1)].hex(' ')
        return None

    def obj(self, cls, p, depth, indent):
        """p points at the object's property table."""
        rd = self.rd
        pad = '  ' * indent
        try:
            entries, base = rd.table(p)
        except ValueError as e:
            print('%s%s  (no property table at %d: %s)' % (pad, cls, p, e))
            return
        self.seen[cls] += 1
        schema = schema_for(self.cdb, cls)
        print('%s%s  (%d props, table @%d, size %d)' % (pad, cls, len(entries), p, self.cdb.get(cls, {}).get('size', 0)))
        if depth >= self.max_depth:
            return
        for pid, off in entries:
            at = base + off
            if pid not in schema:
                # Lists store their items under computed ids (base + index) with rwCreateEObject, which the
                # static schema cannot know. Recognize them by the class id that starts such an entry.
                cid = rd.i32(at) if at + 4 <= len(rd.d) else 0
                if cid in self.ids:
                    try:
                        rd.table(at + 4)
                        valid = True
                    except ValueError:
                        valid = False
                    if valid:
                        print('%s  item id %-4d classid=%d %s' % (pad, pid, cid, self.ids[cid]))
                        if depth + 1 < self.max_depth:
                            self.obj(self.ids[cid], at + 4, depth + 1, indent + 2)
                        continue
                self.unknown[cls][pid] += 1
                print('%s  ? id %-4d @+%-6d %s' % (pad, pid, off, rd.d[at:at + 8].hex(' ')))
                continue
            name, rw, size, typ, owner = schema[pid]
            if rw in ('rwEObject',):
                sub = typ if typ in self.cdb else None
                guessed = ''
                if not sub:
                    sub = self.guess_class(at)
                    guessed = ' (guessed from property ids)' if sub else ''
                print('%s  %-28s %s%s' % (pad, name, rw, guessed))
                if sub:
                    self.obj(sub, at, depth + 1, indent + 2)
                else:
                    sub_entries, _ = rd.table(at)
                    print('%s    (object of unknown class, %d props: %s)' % (pad, len(sub_entries), [e[0] for e in sub_entries]))
            elif rw == 'rwCreateEObject':
                cid = rd.i32(at)
                sub = self.ids.get(cid)
                print('%s  %-28s %s classid=%d %s' % (pad, name, rw, cid, sub or '?'))
                if cid and sub:
                    self.obj(sub, at + 4, depth + 1, indent + 2)
            elif rw == 'rwChildren':
                try:
                    kids, kbase = rd.table(at)
                except ValueError as e:
                    print('%s  %-28s children table unreadable: %s' % (pad, name, e))
                    continue
                print('%s  %-28s %d children' % (pad, name, len(kids)))
                for kid, koff in kids:
                    if kbase + koff + 4 > len(rd.d):
                        continue
                    cid = rd.i32(kbase + koff)
                    sub = self.ids.get(cid)
                    print('%s    child id %d classid=%d %s' % (pad, kid, cid, sub or '?'))
                    if cid and sub and depth + 1 < self.max_depth:
                        self.obj(sub, kbase + koff + 4, depth + 2, indent + 3)
            elif rw == 'rwStreamProc':
                print('%s  %-28s %s @+%d' % (pad, name, rw, off))
            else:
                print('%s  %-28s = %s' % (pad, name, self.value(rw, at, size)))


def main():
    args = [a for a in sys.argv[1:] if not a.startswith('--')]
    opts = dict(zip(sys.argv[1:], sys.argv[2:]))
    depth = int(opts.get('--depth', 2))
    root_cls = opts.get('--class', 'TAoWHSMap')
    raw = open(args[0], 'rb').read()
    assert raw[:4] == b'CFS\0', 'not a CFS container'
    data = zlib.decompress(raw[5:])
    rd = Reader(data)
    print('container version %d, inflated %d bytes' % (raw[4], len(data)))
    hdr_len = rd.i32(0)
    print('header: len=%d sig=%r reserved=%d classid=%d' % (hdr_len, data[4:8], rd.i32(8), rd.i32(12)))
    cdb = json.load(open(args[1], encoding='utf-8'))['classes']
    ids = classid_map(args[2])
    print('class ids known: %d; root class id %d -> %s' % (len(ids), rd.i32(12), ids.get(rd.i32(12))))
    # the header record is hdr_len bytes including its own length field; the loader seeks to hdr_len
    root_entries, root_base = rd.table(hdr_len)
    print('root table: %s' % root_entries)
    w = Walker(rd, cdb, ids, depth)
    for pid, off in root_entries:
        w.obj(ids.get(rd.i32(12), root_cls), root_base + off, 0, 0)
    print()
    print('objects seen:', dict(w.seen))
    for cls, c in w.unknown.items():
        print('unknown ids in %s: %s' % (cls, dict(c)))


main()
