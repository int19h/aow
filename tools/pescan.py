"""Dump imports and exports of the PE files in a directory. Usage: pescan.py <dir> <outdir>"""
import os, struct, sys, re, collections

def rd(b, off, fmt):
    return struct.unpack_from(fmt, b, off)

def parse(path):
    b = open(path, 'rb').read()
    pe = rd(b, 0x3C, '<I')[0]
    if b[pe:pe+4] != b'PE\0\0':
        return None
    nsec = rd(b, pe+6, '<H')[0]
    optsz = rd(b, pe+20, '<H')[0]
    opt = pe + 24
    ndd = rd(b, opt+92, '<I')[0]
    dd = [rd(b, opt+96+8*i, '<II') for i in range(ndd)]
    secs = []
    sh = opt + optsz
    for i in range(nsec):
        o = sh + 40*i
        name = b[o:o+8].rstrip(b'\0').decode('ascii', 'replace')
        vsize, va, rsize, raw = rd(b, o+8, '<IIII')
        secs.append((name, va, vsize, raw, rsize))
    def rva2off(rva):
        for name, va, vsize, raw, rsize in secs:
            if va <= rva < va + max(vsize, rsize):
                return raw + (rva - va)
        return None
    def cstr(rva):
        o = rva2off(rva)
        if o is None: return '?'
        e = b.index(b'\0', o)
        return b[o:e].decode('latin1')
    # exports
    exports = []
    if ndd > 0 and dd[0][0]:
        o = rva2off(dd[0][0])
        nnames = rd(b, o+24, '<I')[0]
        names_rva = rd(b, o+32, '<I')[0]
        no = rva2off(names_rva)
        for i in range(nnames):
            exports.append(cstr(rd(b, no+4*i, '<I')[0]))
    # imports
    imports = collections.OrderedDict()
    if ndd > 1 and dd[1][0]:
        o = rva2off(dd[1][0])
        while True:
            ilt, ts, fc, name_rva, iat = rd(b, o, '<IIIII')
            if name_rva == 0: break
            dll = cstr(name_rva)
            funcs = []
            t = rva2off(ilt or iat)
            while True:
                v = rd(b, t, '<I')[0]
                if v == 0: break
                if v & 0x80000000:
                    funcs.append('#%d' % (v & 0xFFFF))
                else:
                    funcs.append(cstr(v + 2))
                t += 4
            imports[dll] = funcs
            o += 20
    return dict(secs=secs, exports=exports, imports=imports, size=len(b))

def main():
    d, out = sys.argv[1], sys.argv[2]
    os.makedirs(out, exist_ok=True)
    summary = []
    for f in sorted(os.listdir(d)):
        if not f.lower().endswith(('.exe', '.dpl', '.dll')): continue
        try:
            r = parse(os.path.join(d, f))
        except Exception as e:
            summary.append('%-20s ERROR %s' % (f, e)); continue
        if r is None: continue
        code = sum(s[2] for s in r['secs'] if s[0] == 'CODE' or s[0] == '.text')
        units = collections.Counter()
        classes = set()
        for e in r['exports']:
            m = re.match(r'@([A-Za-z0-9_]+)@', e)
            if m:
                units[m.group(1)] += 1
                m2 = re.match(r'@[A-Za-z0-9_]+@(T[A-Za-z0-9_]+)@', e)
                if m2: classes.add((m.group(1), m2.group(1)))
        summary.append('%-20s size=%8d code=%8d exports=%6d units=%3d classes=%4d imports=%s' % (
            f, r['size'], code, len(r['exports']), len(units), len(classes),
            ','.join('%s(%d)' % (k, len(v)) for k, v in r['imports'].items())))
        with open(os.path.join(out, f + '.txt'), 'w', encoding='utf-8') as fh:
            fh.write('# sections\n')
            for s in r['secs']: fh.write('%s va=%08X vsize=%d raw=%08X rsize=%d\n' % s)
            fh.write('\n# imports\n')
            for k, v in r['imports'].items():
                fh.write('%s: %s\n' % (k, ' '.join(v)))
            fh.write('\n# units (export counts)\n')
            for k, v in units.most_common(): fh.write('%s %d\n' % (k, v))
            fh.write('\n# classes\n')
            for u, c in sorted(classes): fh.write('%s.%s\n' % (u, c))
            fh.write('\n# exports\n')
            for e in r['exports']: fh.write(e + '\n')
    print('\n'.join(summary))

main()
