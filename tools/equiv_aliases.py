"""Schema 2 reviewed aliases: resolve recipes atomically against each build."""
import copy
import hashlib
import sys
import re
from equiv_records import digest,load_aliases

def cell_address(inp,addresses,cell):
    if 'cell_scope' not in cell: return addresses.map_addresses.get(cell['cell_symbol'])
    if not hasattr(inp,'_alias_units'):
        inp._alias_units=[]
        for line in inp.map_path.read_text(encoding='latin1').splitlines():
            m=re.match(r'\s*(\d{4}):([\da-fA-F]{8})\s+([\da-fA-F]{8})\s+C=\S+\s+S=\S+\s+G=\S+\s+M=(\S+)',line)
            if m: inp._alias_units.append((m[1],int(m[2],16),int(m[3],16),m[4]))
    data=next(s for s in inp.new.pe.sections if s.Name.rstrip(b'\0') in (b'DATA',b'.data'))
    values={inp.new.base+data.VirtualAddress+off for seg,off in inp.syms.get(cell['cell_symbol'],()) if seg=='0002' and any(seg==s and lo<=off<lo+size and unit==cell['cell_scope'] for s,lo,size,unit in inp._alias_units)}
    return next(iter(values)) if len(values)==1 else None

def original_hash(image,address,size,expected):
    data=image.bytes_at(int(address,16),size)
    if len(data)!=size or hashlib.sha256(data).hexdigest()!=expected:
        raise ValueError('original extent content hash differs')

def absolute_loads(inp,addresses,symbol):
    e=sys.modules[type(addresses).__module__]
    if symbol not in addresses.map_addresses: raise ValueError('unresolved/ambiguous function MAP symbol: '+symbol)
    locs={inp.text+off for seg,off in inp.syms.get(symbol,()) if seg=='0001'}
    if len(locs)!=1: raise ValueError('unresolved/ambiguous code MAP symbol: '+symbol)
    start=next(iter(locs));ends=[inp.text+a for a in getattr(inp,'code_offsets',()) if inp.text+a>start]
    code=e.decode(inp.new,start,min([4096]+[a-start for a in ends]))
    return [(ins.address,op.mem.disp & 0xffffffff) for ins in code if ins.mnemonic!='lea'
            for k,op in enumerate(ins.operands) if op.type==e.X.X86_OP_MEM and op.size==4
            and not (op.mem.base or op.mem.index or op.mem.segment)
            and ins.raw.operands[k].access & e.CS.CS_AC_READ]

def resolve(entry,inp,addresses):
    entry=copy.deepcopy(entry);size=entry['extent']['size']
    old,new=entry['original'],entry['compiled']
    if entry['kind']=='pointer-cell':
        for cell in old['cells']: original_hash(inp.old,cell['address'],size,cell['content_sha256'])
        for cell in new['cells']:
            symbol=cell['pointee_symbol']
            if symbol!=new['pointee']['symbol']: raise ValueError('different recipe/pointee symbols')
            point=addresses.map_addresses.get(symbol)
            if point is None: raise ValueError('unresolved/ambiguous pointee MAP symbol: '+symbol)
            loads=absolute_loads(inp,addresses,cell['function_symbol']);index=cell['occurrence']
            candidates={a for _,a in loads if a in addresses.relocs[1] and addresses.u32(inp.new,a)==point}
            if 'cell_symbol' in cell:
                named=cell_address(inp,addresses,cell)
                if named is None: raise ValueError('unresolved/ambiguous cell MAP symbol')
                candidates.intersection_update((named,))
            if len(candidates)!=1: raise ValueError('expected one relocated pointee cell; got '+str(len(candidates)))
            if type(index) is not int or not 0<=index<len(loads) or loads[index][1] not in candidates:
                raise ValueError('absolute-load occurrence does not identify the unique pointee cell')
            cell['address']=hex(next(iter(candidates)))
    elif entry['kind'] in ('immutable-data','mutable-data','bss'):
        original_hash(inp.old,old['address'],size,old['content_sha256'])
        if 'map_symbol' in new:
            address=addresses.map_addresses.get(new['map_symbol'])
            if address is None: raise ValueError('unresolved/ambiguous immutable MAP symbol')
        else:
            # Anonymous relocation-free literals use the reviewed operand in a named function.
            if entry['kind']!='immutable-data' or entry['identity']['class']!='reviewed-source': raise ValueError('literal recipe requires reviewed immutable data')
            e=sys.modules[type(addresses).__module__];symbol=new['function_symbol']
            start=addresses.map_addresses.get(symbol)
            if start is None: raise ValueError('unresolved/ambiguous literal function MAP symbol')
            ends=[inp.text+a for a in getattr(inp,'code_offsets',()) if inp.text+a>start]
            code=e.decode(inp.new,start,min([4096]+[a-start for a in ends]))
            operands=[(op.imm if op.type==e.X.X86_OP_IMM else op.mem.disp) & 0xffffffff for ins in code for op in ins.operands if op.type==e.X.X86_OP_IMM or (op.type==e.X.X86_OP_MEM and not (op.mem.base or op.mem.index or op.mem.segment))]
            address=operands[new['operand_occurrence']]
            if any(address-3<=r<address+size for r in addresses.relocs[1]): raise ValueError('literal recipe has relocations')
            original_hash(inp.new,hex(address),size,new['content_sha256'])
        new['address']=hex(address)
    else: raise ValueError('schema 2 requires a supported reviewed identity recipe')
    return entry

def load_v2(path,inp,addresses,document):
    if set(document)!={'schema_version','module','entries'} or set(document['module'])!={'original_sha256'}:
        raise ValueError('malformed schema 2 alias document')
    accepted=[];ids=set();hashes=[digest(p) for p in inp.image_paths]
    results=getattr(addresses,'alias_resolutions',[]);addresses.alias_resolutions=results
    fields=('forward','reverse','conflicts','provenance','pointer_cells','pointee_symbols','immutable_data','reviewed_names','storage_objects')
    for source in document['entries']:
        if not isinstance(source.get('id'),str) or not source['id'] or source['id'] in ids:
            raise ValueError('duplicate/invalid alias id')
        ids.add(source['id'])
        if source['disposition'] not in ('accepted','pending','rejected'): raise ValueError('invalid review disposition')
        if source['disposition']!='accepted':
            results.append(dict(id=source['id'],status=source['disposition'],reason='not accepted by review'));continue
        state={k:copy.deepcopy(getattr(addresses,k)) for k in fields if hasattr(addresses,k)}
        try:
            if document['module']['original_sha256']!=hashes[0]: raise ValueError('original module hash differs')
            entry=resolve(source,inp,addresses)
            current=dict(schema_version=1,module=dict(original_sha256=hashes[0],compiled_sha256=hashes[1]),entries=[entry])
            rows=load_aliases(path,inp,addresses,current)
            for a,b,size,_ in rows:
                if any(addresses.forward.get(a+k,b+k)!=b+k or addresses.reverse.get(b+k,a+k)!=a+k for k in range(size)):
                    raise ValueError('resolved alias conflicts with existing independent binding')
                if any((max(a,x)<min(a+size,x+length) or max(b,y)<min(b+size,y+length)) and b-a!=y-x for x,y,length,_ in accepted):
                    raise ValueError('overlapping aliases have inconsistent byte offsets')
            accepted.extend(rows)
            locations=([c['address'] for c in entry['compiled']['cells']] if entry['kind']=='pointer-cell' else [entry['compiled']['address']])
            results.append(dict(id=source['id'],status='accepted',compiled=locations,compiled_sha256=hashes[1]))
        except (ValueError,KeyError,TypeError,IndexError) as error:
            for key in fields:
                if key in state: setattr(addresses,key,state[key])
                elif hasattr(addresses,key): delattr(addresses,key)
            results.append(dict(id=source['id'],status='pending',reason=str(error)))
    return accepted
