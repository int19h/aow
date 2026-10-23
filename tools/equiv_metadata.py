"""Delphi 3 System/TypInfo layouts; bounds are rejection limits, never extents."""
def extent(img, address, kind):
    def read(p,n):
        b=img.bytes_at(p,n)
        if len(b)!=n:raise ValueError('truncated metadata')
        return int.from_bytes(b,'little')
    n=read(address,2);p=address
    if kind=='dynamic':p+=2+6*n
    elif kind=='method':
        p+=2
        for _ in range(min(n,1025)):
            size=read(p,2)
            if size!=7+read(p+6,1):raise ValueError('method entry size')
            p+=size
    elif kind=='field':
        p+=6
        for _ in range(min(n,1025)):p+=7+read(p+6,1)
    elif kind=='classes':p+=2+4*n
    elif kind=='interface':n=read(p,4);p+=4+24*n
    elif kind=='init':
        # InitTable is tkRecord TypeInfo, then record size/count and pointer/offset pairs.
        if read(p,1)!=14:raise ValueError('not record init typeinfo')
        p+=2+read(p+1,1);n=read(p+4,4);p+=8+8*n
    else:raise ValueError('unsupported table layout')
    if n>1024 or not 0<p-address<=16384:raise ValueError('metadata extent budget')
    read(address,p-address)
    return p-address

def records(d, side, records):
    img=(d.old,d.new)[side]
    cells={}
    for cell in sorted(d.relocs[side]):cells.setdefault(d.u32(img,cell),set()).add(cell)
    for vmt,name in sorted(d.vmts[side].items()):
        if len([v for v,n in d.vmts[side].items() if n==name])!=1:continue
        # Parent class/typeinfo cells have named pointees, not positional identities.
        records['named-vmt-cell',name].add(vmt-64)
        ti=d.u32(img,vmt-48)
        if ti and img.bytes_at(ti,2)==bytes((7,len(name))):
            records['named-typeinfo-cell',name].update(cells.get(ti,()))
        for slot,kind in ((-60,'interface'),(-52,'init'),(-44,'field'),(-40,'method'),(-36,'dynamic')):
            address=d.u32(img,vmt+slot)
            if not address:continue
            try:
                n=extent(img,address,kind)
                if not d.readonly(side,address,n):continue
                records['class-slot',name,slot,n].add(address)
                if kind=='field':
                    child=d.u32(img,address+2)
                    if child:
                        m=extent(img,child,'classes')
                        if d.readonly(side,child,m):records['class-slot',name,'field-classes',m].add(child)
            except (ValueError,IndexError):continue
    for ti,locations in sorted(cells.items()):
        header=img.bytes_at(ti,2)
        if len(header)!=2 or header[0] not in (10,11,12) or not 0<header[1]<=64:continue
        data=img.bytes_at(ti+2,header[1])
        if not data.isalpha() or not d.readonly(side,ti,2+len(data)):continue
        name=data.decode('ascii');records['primitive-typeinfo',name,len(data)+2].add(ti)
        records['named-typeinfo-cell',name].update(locations)
    for address,imp in sorted(d.import_locations[side].items()):
        if imp[1][0]!='name':continue
        symbol=imp[1][1].decode('latin1').split('@')[0]
        if '.' in symbol:records['named-vmt-cell' if '..' in symbol else 'named-typeinfo-cell',symbol.rsplit('.',1)[1]].add(address)
