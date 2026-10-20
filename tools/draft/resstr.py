"""Read exported resource strings. Usage: resstr.py <module.dpl> [Unit]"""
import pefile, struct, sys
pe = globals().get('_pe') or pefile.PE(sys.argv[1]); base = pe.OPTIONAL_HEADER.ImageBase; img = pe.get_memory_mapped_image()
strings = {}
for t in getattr(getattr(pe, 'DIRECTORY_ENTRY_RESOURCE', None), 'entries', []):
    if t.id != 6: continue
    for b in t.directory.entries:
        for l in b.directory.entries:
            d = l.data.struct; raw = pe.get_data(d.OffsetToData, d.Size); p = 0
            for i in range(16):
                n = struct.unpack_from('<H', raw, p)[0]; p += 2
                strings[(b.id - 1) * 16 + i] = raw[p:p + 2 * n].decode('utf-16-le'); p += 2 * n
for e in pe.DIRECTORY_ENTRY_EXPORT.symbols:
    if e.name and e.name.decode().endswith('@04ECFCC5') and (len(sys.argv)<3 or e.name.decode().startswith(sys.argv[2]+'.')):
        va = base + e.address
        ident = struct.unpack_from('<i', img, va - base + 4)[0]
        print('%x %s = %r; { id %d }' % (va, e.name.decode().split('@')[0], strings.get(ident), ident))
