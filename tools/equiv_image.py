"""Bounded H5 image validation. An identity is never an extent or a content proof."""
import hashlib
import sys
import re
ACTIVE = None  # Scoped by equiv_cache.proof_context, never retained across verdicts.
def map_sizes(text, symbols):
    sizes = {}
    for line in text.splitlines():
        m = re.match(r'\s*(\d{4}):([0-9A-F]{8})\s+([0-9A-F]{8})H?\s+(\S+)',line)
        if m and symbols.get(m[4]) == [(m[1],int(m[2],16))]:sizes[m[4]] = int(m[3],16)
    return sizes

class Relation:
    def __init__(self, checker, codes):
        self.e = sys.modules[type(checker).__module__]
        self.d = checker.inp.addresses
        self.rows = sorted(set(getattr(self.d, 'storage_objects', ())))
        self.checked, self.values, self.memo, self.roots, self.pointer_targets, self.contents = {}, {}, {}, {}, {}, {}
        self.fields = {}; self.opaque = set()
        self.activated = set()
        self.pointers = 0
        self.pc = 0; self.side = 0
        self.checker = checker
        self.local_code = [{i.address for i in code} for code in codes]
        self.read_after = [{ins.address:any(op.type == self.e.X.X86_OP_MEM and later.raw.operands[k].access & self.e.CS.CS_AC_READ for later in code[j+1:] for k,op in enumerate(later.operands)) for j,ins in enumerate(code)} for code in codes]
        # May-origins at reachable instruction heads survive symbolic cut points.
        self.seeds = [{},{}]
        for side,code in enumerate(codes):
            incoming={0:{}};todo=[0]
            while todo:
                k=todo.pop(0);ins=code[k];self.pc=ins.address;self.side=side
                before=incoming[k];after={r:set(v) for r,v in before.items()};origins=set();loaded=set()
                for j,op in enumerate(ins.operands):
                    regs=([op.reg] if op.type==self.e.X.X86_OP_REG and ins.raw.operands[j].access & self.e.CS.CS_AC_READ else [op.mem.base,op.mem.index] if op.type==self.e.X.X86_OP_MEM else [])
                    for reg in regs:origins.update(before.get(ins.reg_name(reg),()))
                    v=self.d.absolute(side,ins,op)
                    if v is not None and op.type==self.e.X.X86_OP_IMM and ins.mnemonic!='call' and not ins.mnemonic.startswith('j') and self.code(side,v):origins.add((v if side==0 else self.d.reverse.get(v,v),v,0,'code-address','code identity does not authorize byte reach'))
                    if v is not None and ins.mnemonic not in ('call','jmp') and not ins.mnemonic.startswith('j') and v not in self.d.pointer_cells[side] and not self.code(side,v):origins.add(self.root(side,v,observe=False))
                if ins.mnemonic!='lea' and any(op.type==self.e.X.X86_OP_MEM and ins.raw.operands[j].access & self.e.CS.CS_AC_READ for j,op in enumerate(ins.operands)):
                    for row in origins:
                        if row and row[3]!='mutable-data':self.root(0,row[0]);loaded.update(self.targets(row,side,v))
                for j,op in enumerate(ins.operands):
                    if op.type==self.e.X.X86_OP_REG and ins.raw.operands[j].access & self.e.CS.CS_AC_WRITE:after[ins.reg_name(op.reg)]=set(loaded if ins.mnemonic in ('mov','movzx','movsx') and ins.operands[-1].type==self.e.X.X86_OP_MEM else origins)
                if ins.mnemonic=='call':
                    for r in ('eax','edx','ecx'):after.pop(r,None)
                self.seeds[side][ins.address]=before
                for nxt in self.e.successors(code,k):
                    merged={r:incoming.get(nxt,{}).get(r,set())|after.get(r,set()) for r in set(incoming.get(nxt,{}))|set(after)}
                    if nxt not in incoming or merged!=incoming[nxt]:incoming[nxt]=merged;todo.append(nxt)
        self.pc=0
    def targets(self,row,side,address=None):
        if address is not None and (row,address-row[side]) in self.fields:return self.fields[row,address-row[side]]
        return self.pointer_targets.get(row,())
    def fail(self, reason):
        self.failure = dict(pc=hex(self.pc),side=self.side,reason=reason)
        for r in self.checked.values():
            if r['status']=='validating':r.update(status='failed',reason=reason)
        raise self.e.Unsupported('H5 ImageRelation at 0x%x: %s' % (self.pc,reason))
    def metadata(self,row):
        return row[4].startswith(('Delphi VMT','Delphi class','class ','named typeinfo','primitive typeinfo','Delphi resourcestring'))
    def class_data(self,side,address):
        return self.d.names[side].get(address,'').startswith(('vmt:','vmtref:')) or any(self.metadata(r) and r[side]<=address<r[side]+r[2] for r in self.rows)
    def code(self, side, address):
        if self.class_data(side,address):return False
        if address in self.local_code[side]: return True
        img = (self.d.old,self.d.new)[side]
        executable = any(s.Characteristics & 0x20000000 and img.base+s.VirtualAddress <= address < img.base+s.VirtualAddress+s.Misc_VirtualSize for s in img.pe.sections)
        if not executable: return False
        if any(r[side]<=address<r[side]+r[2] for r in self.rows): return False
        pair = (address,self.d.forward.get(address)) if side == 0 else (self.d.reverse.get(address),address)
        if self.d.provenance.get(pair) in ('independent-name','declared-function'): return True
        inp = self.d.inp
        if side == 0:
            return address in {a for a,n in inp.sigs.values()} or address in self.d.names[0]
        return address in {inp.text+off for locs in inp.syms.values() for seg,off in locs if seg == '0001'} or address in self.d.names[1]
    def pointee(self,side,address,depth=0):
        if depth>2:return None
        d=self.d;img=(d.old,d.new)[side];imp=d.import_locations[side].get(address)
        if address in d.import_bytes[side] and imp and imp[1][0]=='name':
            symbol=imp[1][1].decode('latin1').split('@')[0];parts=symbol.replace('..','.').rsplit('.',1)
            return (parts[0],parts[1],imp[0].decode('latin1'),address) if len(parts)==2 else None
        name=d.vmts[side].get(address)
        if name:
            if list(d.vmts[side].values()).count(name)!=1:return None
            if img.bytes_at(d.u32(img,address-32),len(name)+1)!=bytes((len(name),))+name.encode():return None
            ti=d.u32(img,address-48)
            unit=''
            if ti and img.bytes_at(ti,2)==bytes((7,len(name))):
                at=ti+len(name)+12;raw=img.bytes_at(at,1)
                if raw:unit=img.bytes_at(at+1,raw[0]).decode('ascii',errors='replace')
            return unit,name,'',address
        header=img.bytes_at(address,2)
        if len(header)==2 and header[0] in (7,10,11,12) and 0<header[1]<=64:
            name=img.bytes_at(address+2,header[1]).decode('ascii',errors='replace')
            if header[0]==7:
                vmt=d.u32(img,address+2+header[1])
                if d.vmts[side].get(vmt)==name:return self.pointee(side,vmt,depth+1)
            elif name.isidentifier():return 'System',name,'',address
        if address in d.relocs[side] and d.readonly(side,address,4):return self.pointee(side,d.u32(img,address),depth+1)
        return None
    def pointees(self,p,q):
        left,right=self.pointee(0,p),self.pointee(1,q)
        if left is None or right is None:return None
        if left[1]!=right[1] or left[0] and right[0] and left[0]!=right[0] or left[2] and right[2] and left[2]!=right[2]:self.fail('relocated metadata pointee differs: %r / %r'%(left,right))
        import hashlib
        key=(left[0] or right[0],left[1],left[2] or right[2])
        self.d.consulted.add((p,q,'typed-content-record:pointee:'+repr(key)))
        self.d.consulted.add((left[3],right[3],'typed-content-record:pointee-anchor:'+repr(key)))
        return self.e.z3.BitVec('metadata_pointee_'+hashlib.sha256(repr(key).encode()).hexdigest(),32)
    def canonical(self, side, address):
        try: return self.d.canonical(side,address,[{},{}])
        except self.e.Unsupported as error: self.fail('identity: '+str(error))
    def root(self, side, address, activate=True, observe=True):
        self.canonical(side,address)
        if address in self.d.import_bytes[side]: return None  # Loader-scoped runtime cells.
        candidates = [r for r in self.rows if r[side] <= address < r[side]+r[2] or self.d.names[side].get(address,'').startswith('vmt:') and r[side]+r[2]==address and r[4]=='Delphi VMT fixed header']
        if not candidates or all(r[3] in ('mutable-data','bss') for r in candidates):
            named = bool(candidates) or address in self.d.names[side] or (self.d.forward.get(address) if side==0 else self.d.reverse.get(address)) in self.d.names[1-side] or (address if side else self.d.forward.get(address)) in self.d.map_addresses.values()
            if not self.d.readonly(side,address,1) and named:
                original = address if side == 0 else self.d.reverse.get(address,address)
                return (original,original,0,'mutable-data','independent identity and accessed width')
            if not observe:return (address if side == 0 else self.d.reverse.get(address,address),self.d.forward.get(address,address) if side == 0 else address,0,'immutable-data','unknown initialized extent')
            self.fail('unknown justified extent for initialized object %s at 0x%x (side %d), bytes %s' % (self.d.names[side].get(address,'unnamed'),address,side,(self.d.old,self.d.new)[side].bytes_at(address,4).hex()))
        row = min(candidates,key=lambda r:(r[2],r))
        if not observe:return row
        self.validate(row)
        if activate:self.activate(row)
        return row
    def read(self,address,size):
        e=self.e;address=e.simp(address)
        if not e.z3.is_bv_value(address):return None
        a=address.as_long()
        for row in sorted(self.activated):
            if not self.metadata(row) or not row[0]<=a<=row[0]+row[2]-size:continue
            if any(max(a,p)<min(a+size,p+n) for p,n in self.opaque):self.fail('metadata cell address observed; pointee identity does not pair storage')
            data=self.contents[row];parts=[]
            for k in reversed(range(a-row[0],a-row[0]+size)):
                v=data[k]
                parts.append(e.bv(v,8) if isinstance(v,int) else e.z3.Extract(v[1]*8+7,v[1]*8,v[0].translate(e.z3.main_ctx()) if v[0].ctx!=e.z3.main_ctx() else v[0]))
            return e.simp(e.z3.Concat(parts)) if len(parts)>1 else parts[0]
        return None
    def activate(self, row):
        if row in self.activated:return
        self.activated.add(row)
        if row[3] == 'immutable-data':
            for side,start in enumerate(row[:2]):
                self.d.immutable_data[side][start] = row[2]
                self.d.active_cells[side].add(start)
            if not self.metadata(row):self.values.update((row[0]+k,v) for k,v in self.contents[row].items())
            self.memo.clear()
            for child in sorted(self.pointer_targets.get(row,())):self.activate(child)
    def validate(self, row):
        if row in self.checked:
            if self.checked[row]['status']=='failed':self.fail(self.checked[row]['reason'])
            return
        if sum(v['status']=='validating' for v in self.checked.values()) >= 8:self.fail('metadata recursion depth 8 exceeded')
        a,b,n,kind,evidence = row
        if len(self.checked) >= 256 or sum(r[2] for r in self.checked)+n > 65536:
            self.fail('object-validation budget; extent is not inferred from the cap')
        for other in self.rows:
            x,y,m,_,_ = other
            if (max(a,x)<min(a+n,x+m) or max(b,y)<min(b+n,y+m)) and b-a != y-x:
                self.fail('inconsistent overlapping object offsets at 0x%x' % a)
        for k in range(n):
            if a+k in self.d.conflicts or b+k in self.d.conflicts or self.d.forward.get(a+k,b+k) != b+k or self.d.reverse.get(b+k,a+k) != a+k:
                self.fail('contradictory interior identity at 0x%x' % (a+k))
        for img,start in ((self.d.old,a),(self.d.new,b)):
            if not any(img.base+s.VirtualAddress<=start and start+n<=img.base+s.VirtualAddress+s.Misc_VirtualSize for s in img.pe.sections):
                self.fail('extent outside one storage section at '+hex(start))
        data = [(img.bytes_at(start,n)) for img,start in ((self.d.old,a),(self.d.new,b))]
        if any(len(v)!=n for v in data): self.fail('extent outside mapped storage at 0x%x' % a)
        if evidence == 'AnsiString header' and any(n<9 or v[:4]!=bytes.fromhex('ffffffff') or int.from_bytes(v[4:8],'little')!=n-9 or v[-1]!=0 for v in data):
            self.fail('self-describing AnsiString extent changed')
        offsets = [{r-start for r in self.d.relocs[s] if start-3 <= r < start+n} for s,start in enumerate((a,b))]
        if offsets[0] != offsets[1] or any(k<0 or k+4>n for k in offsets[0]) or any(y<x+4 for x,y in zip(sorted(offsets[0]),sorted(offsets[0])[1:])):
            self.fail('relocation coverage differs or is partial at 0x%x' % a)
        # Mark before recursion: cycles have finite, independently justified ranges.
        self.checked[row] = dict(status='validating',original=hex(a),compiled=hex(b),size=n,kind=kind,evidence=evidence,
                                 sha256=[hashlib.sha256(v).hexdigest() for v in data])
        if evidence.startswith('class '):
            name=evidence.split(', slot ')[0][6:]
            for vmt,owner in sorted(self.d.vmts[0].items()):
                if owner==name:self.root(0,vmt-64,False)
        values = {}
        if evidence == 'Delphi resourcestring record':
            from equiv_resources import validate,write_witness
            values.update(validate(self,row))
            for side,start in enumerate((a,b)):
                witness=write_witness(self.d,side,start)
                if witness:self.fail('resourcestring record written at 0x%x %s (side %d)' % (*witness,side))
        self.pointer_targets[row] = set()
        for k in sorted(offsets[0]):
            p,q = (int.from_bytes(v[k:k+4],'little') for v in data)
            nominal = self.pointees(p,q) if p in self.d.import_bytes[0] or q in self.d.import_bytes[1] else None
            try:left,right = (nominal,nominal) if nominal is not None else (self.d.canonical(0,p,[{},{}]),self.d.canonical(1,q,[{},{}]))
            except self.e.Unsupported as error:self.fail('initialized object %s (%s), pointer field 0x%x / 0x%x bytes %s / %s: content equality unresolved: %s' % (self.d.names[0].get(a,hex(a)),evidence,a+k,b+k,data[0][k:k+4].hex(),data[1][k:k+4].hex(),error))
            if not (left == right if isinstance(left,int) and isinstance(right,int) else self.e.bv(left).eq(self.e.bv(right))):
                self.fail('relocated pointer target differs at 0x%x' % (a+k))
            if nominal is not None:self.opaque.add((a+k,4))
            targets = set()
            for side,target in enumerate((p,q)):
                if nominal is not None:continue
                if self.code(side,target):
                    original = p if isinstance(left,int) else target
                    targets.add((original,original,0,'code-address','code identity does not authorize byte reach'))
                elif p in self.d.import_bytes[0] or q in self.d.import_bytes[1]:
                    pass  # Named loader cell versus local class-reference cell; no disk IAT content.
                elif evidence == 'Delphi resourcestring record':
                    pass  # Mutable HInstance pointee: canonical identity, never startup value.
                else:
                    child = self.root(side,target,False)
                    if child is not None:targets.add(child)
            self.fields[row,k] = targets
            self.pointer_targets[row].update(targets)
            self.pointers += 1
            value = nominal if nominal is not None else self.canonical(0,p)
            for j in range(4): values[k+j] = (value>>(j*8)) & 255 if isinstance(value,int) else (value,j)
        for k in range(n):
            if k not in values:
                if data[0][k] != data[1][k]: self.fail('initialized byte differs at 0x%x / 0x%x: %02x != %02x; object %s (%s)' % (a+k,b+k,data[0][k],data[1][k],self.d.names[0].get(a,hex(a)),evidence))
                values[k] = data[0][k]
            self.d.bind(a+k,b+k,'validated-storage:'+evidence)
        self.contents[row] = values
        # Startup equality for mutable objects is evidence, never a runtime constraint.
        self.roots[a] = row
        self.checked[row]['status'] = 'validated'
    def overlay(self, memory):
        if not self.values: return memory
        key = memory.get_id()
        if key in self.memo and self.memo[key][0].eq(memory): return self.memo[key][1]
        result = memory
        for a,v in sorted(self.values.items()):
            byte = self.e.bv(v,8) if isinstance(v,int) else self.e.z3.Extract(v[1]*8+7,v[1]*8,v[0].translate(memory.ctx) if v[0].ctx != memory.ctx else v[0])
            result = self.e.z3.Store(result,self.e.bv(a),byte)
        self.memo[key] = memory,result
        return result
    def access(self, state, side, address, size, roots=()):
        e = self.e; concrete = e.simp(address)
        rows = set(roots)
        if e.z3.is_bv_value(concrete):
            v = concrete.as_long()
            # Numerical range is not evidence that an integer was relocated.
            if not rows and any(img.contains(v) for img in (self.d.old,self.d.new)):
                self.fail('integer-derived image reach has no checked pointer provenance (side %d)' % side)
            if not rows and self.d.old.contains(v) and v not in self.d.import_bytes[0]: rows.add(self.root(0,v))
        for row in sorted(r for r in rows if r is not None):
            a,b,n,kind,_ = row
            if kind == 'mutable-data': continue
            row = self.root(0,a)
            for field,width in sorted(self.opaque):
                if a<=field<a+n and not e.prove([e.z3.Implies(getattr(state,'path',e.z3.BoolVal(True)),e.z3.Or(e.z3.ULT(address+e.bv(size-1),e.bv(field)),e.z3.UGT(address,e.bv(field+width-1))))]):self.fail('metadata cell address observed; pointee identity does not pair storage')
            valid = e.z3.And(e.z3.UGE(address,e.bv(a)),e.z3.ULE(address,e.bv(a+n-size))) if n>=size else e.z3.BoolVal(False)
            if not e.prove([e.z3.Implies(getattr(state,'path',e.z3.BoolVal(True)),valid)]):
                self.fail('access width %d exceeds justified extent %s+%d (side %d), object %s (%s)' % (size,hex(a),n,side,self.d.names[0].get(a,hex(a)),row[4]))
    def summary(self):
        valid = [r for r in sorted(self.checked) if self.checked[r]['status']=='validated']
        return dict(objects=len(valid),bytes=sum(r[2] for r in valid),pointers=self.pointers,
                    storage_ranges=[self.checked[r] for r in valid],failure=getattr(self,'failure',None),
                    remaining_assumed='Module-wide reach/initial relation outside validated storage; mutable runtime bytes remain arbitrary. Unvalidated module-wide facts remain explicit H5 assumptions.')
    def step(self, machine, state, ins, execute):
        self.pc = ins.address; self.side = machine.side
        e = self.e; tags = dict(self.seeds[machine.side].get(ins.address,{}));tags.update(getattr(state,'image_origins',{}))
        cell_origins, loaded_origins = set(), set()
        origins = set()
        for index,op in enumerate(ins.operands):
            if op.type == e.X.X86_OP_MEM:
                for reg in (op.mem.base,op.mem.index):
                    if reg:
                        source = tags.get(ins.reg_name(reg),())
                        origins.update(source)
                        for row in source:loaded_origins.update(self.pointer_targets.get(row,()))
            if op.type == e.X.X86_OP_REG and ins.raw.operands[index].access & e.CS.CS_AC_READ:
                origins.update(tags.get(ins.reg_name(op.reg),()))
            v = self.d.absolute(machine.side,ins,op)
            if v is not None and op.type == e.X.X86_OP_IMM and ins.mnemonic != 'call' and not ins.mnemonic.startswith('j') and self.code(machine.side,v):
                original = v if machine.side == 0 else self.d.reverse.get(v,v)
                origins.add((original,original,0,'code-address','code identity does not authorize byte reach'))
            if v in self.d.pointer_cells[machine.side]:
                point,record = self.d.pointer_cells[machine.side][v]
                cell_origins.add((v,v,0,'mutable-data',record))
            if v is not None and not (op.type == e.X.X86_OP_IMM and (ins.mnemonic == 'call' or ins.mnemonic.startswith('j'))) and not self.code(machine.side,v) and v not in self.d.pointer_cells[machine.side]:
                row = self.root(machine.side,v,observe=op.type == e.X.X86_OP_MEM and ins.mnemonic != 'lea')
                if row:
                    origins.add(row)
                    if op.type == e.X.X86_OP_MEM:loaded_origins.update(self.targets(row,machine.side,v))
        restricted = {r for r in origins if r[3] != 'mutable-data'}
        if restricted and any(op.type == e.X.X86_OP_MEM and ins.raw.operands[k].access & e.CS.CS_AC_WRITE for k,op in enumerate(ins.operands)) and any(tags.get(ins.reg_name(op.reg)) for op in ins.operands if op.type == e.X.X86_OP_REG) and self.read_after[machine.side].get(ins.address,True):
            self.fail('stored image-pointer reach not checked')
        if ins.mnemonic in ('push','call'):
            passed = origins | set().union(*(tags.get(r,set()) for r in e.REGS if r not in ('esp','ebp'))) if ins.mnemonic != 'push' else origins
            passed = {r for r in passed if r[3] != 'mutable-data'}
            for row in sorted(passed):
                if row[3] != 'code-address':self.root(0,row[0])
            resources = {r for r in passed if r[4]=='Delphi resourcestring record'}
            if resources and ins.mnemonic=='call':
                target=ins.operands[0].imm if ins.operands[0].type==e.X.X86_OP_IMM else None
                name=self.d.names[machine.side].get(target,'')
                if machine.side==1 and target is not None:
                    name=next((n for n,p in self.d.map_addresses.items() if p==target and n=='LoadResString'),name)
                if name not in ('System.LoadResString','LoadResString'):
                    self.fail('resourcestring descriptor passed to non-LoadResString callee at '+hex(ins.address))
                if not e.prove([e.z3.Implies(getattr(state,'path',e.z3.BoolVal(True)),e.z3.Or(*[state.regs['eax']==e.bv(r[0]) for r in sorted(resources)]))]):
                    self.fail('resourcestring descriptor argument is not a validated record base at '+hex(ins.address))
            passed = {r for r in passed if not self.metadata(r)}
            if passed:
                from equiv_summaries import write_body
                graph = getattr(self.checker.inp,'call_summaries',None)
                node = graph.nodes.get((machine.side,id((self.d.old,self.d.new)[machine.side]),ins.operands[0].imm,0)) if graph and ins.mnemonic == 'call' and ins.operands[0].type == e.X.X86_OP_IMM else None
                node = write_body(graph,node) if node else None
                site = self.checker.contracts.sites.get((machine.side,ins.address))
                if not node or not node['valid'] or node['value'][3] or node.get('write_reason') or node['writes'] is None or not site or 'H3c' in site[2]['premises'] or any(r[3]=='code-address' for r in passed):
                    self.fail('unknown callee/escaping reach for image object at '+hex(min(passed)[0]))
                for arg,bits,_,pc,text in node['write_reads']:
                    if not isinstance(arg,str) or arg not in state.regs:self.fail('unknown passed-pointer read extent at callee '+hex(pc)+' '+text)
                    for row in tags.get(arg,()):
                        for k in range(64):
                            if bits>>k&1:self.access(state,machine.side,state.regs[arg]+e.bv(k),1,[row])
        result = execute(state,ins)
        for index,op in enumerate(ins.operands):
            if op.type == e.X.X86_OP_REG and ins.raw.operands[index].access & e.CS.CS_AC_WRITE:
                name = ins.reg_name(op.reg)
                if name not in e.ALIASES or e.ALIASES[name][1] != 32:
                    if restricted: self.fail('partial-register image-pointer transformation')
                tags[name] = (set(origins) if ins.mnemonic not in ('mov','movzx','movsx') or ins.operands[-1].type != e.X.X86_OP_MEM else set(cell_origins)|set(loaded_origins))
        if ins.mnemonic=='call':
            for r in ('eax','edx','ecx'):tags[r]=set()
        state.image_origins = tags
        return result
