"""Step 4b: bounded, module-cached descending call-graph summaries.
Top means every modeled input; opaque nested calls carry an explicit H3c taint.
Effects/ABI remain H3 premises; these summaries are not callee equivalence proofs.
"""
class ModuleSummaries:
    BYTE_LIMIT = 4096
    INSTRUCTION_LIMIT = 50000
    SCC_ITERATION_LIMIT = 64
    def __init__(self, owner):
        self.inp = owner.checker.inp; self.e = owner.e
        self.full = owner.full | {('r','esp',k) for k in range(4)}
        self.flags = frozenset(('f',f) for f in self.e.FLAGS)
        self.convention = frozenset([('r',r,k) for r in ('eax','edx','ecx') for k in range(4)]+[('f','df')])
        self.nodes, self.images, self.imports = {}, {}, {}
        self.image_labels={id(self.inp.old):'original',id(self.inp.new):'compiled'}
        self.active=None
        self.instructions = self.work = self.iterations = 0
        self.over_budget = 0
    def charge(self):
        n=self.active
        if n['work']>=self.INSTRUCTION_LIMIT:
            self.budget('instruction cap')
            raise self.e.Unsupported('callee summary instruction budget')
        n['work']+=1;self.work+=1
    def budget(self,reason):
        if not self.active['budget_outcomes']:self.over_budget+=1
        self.active['budget_outcomes'].add(reason)
    def ordered(self,keys):
        return sorted(keys,key=lambda k:(k[0],self.image_labels[k[1]],k[3],k[2]))
    def fail_component(self,part,reason,writes_only=False):
        for key in part:
            n=self.active=self.nodes[key];self.budget(reason)
            n.update(writes={},write_reads=[],write_reason=reason)
            if not writes_only:n.update(value=(self.full,None,self.flags,False),valid=False,h1=set(),reason=reason)
    def imported(self, image, cell, hop):
        key = id(image),cell,hop
        if key in self.imports: return self.imports[key]
        self.imports[key] = None
        if hop: return None
        e = self.e
        e.match.parse_imports_once(image)
        for module in getattr(image.pe,'DIRECTORY_ENTRY_IMPORT',()):
            for imp in module.imports:
                if imp.address!=cell or not imp.name: continue
                path = self.inp.original_path.parent/module.dll.decode('latin1')
                if not path.is_file(): return None
                if path not in self.images:
                    other = e.match.Image(path)
                    other.pe.parse_data_directories(directories=[e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
                    self.images[path] = other
                    self.image_labels[id(other)]=str(path)
                other = self.images[path]
                for exp in getattr(getattr(other.pe,'DIRECTORY_ENTRY_EXPORT',None),'symbols',()):
                    if exp.name==imp.name and not exp.forwarder:
                        self.imports[key] = other,other.base+exp.address,hop+1
                        return self.imports[key]
        return None
    def discover(self, side, image, target, hop):
        e = self.e; first = side,id(image),target,hop
        todo = [(first,image,target,hop)]; added = []
        while todo:
            key,img,start,depth = todo.pop()
            if key in self.nodes: continue
            node = dict(side=side,image=img,target=start,hop=depth,edges={},alias=None,
                        work=0,decoded_bytes=0,read_iterations=0,write_iterations=0,budget_outcomes=set(),
                        writes=None,write_reads=[],value=(self.full,None,self.flags,False),valid=False,h1=set(),hazard=None,reason='unknown target')
            self.nodes[key] = node; added.append(key)
            self.active=node
            if not img.contains(start): continue
            try:
                ends = ([a for a,_ in self.inp.sigs.values()] if side==0 else
                        [self.inp.text+a for a in getattr(self.inp,'code_offsets',())]) if not depth else []
                end=start+min([self.BYTE_LIMIT]+[a-start for a in ends if a>start])
                decoder=e.CS.Cs(e.CS.CS_ARCH_X86,e.CS.CS_MODE_32);decoder.detail=True
                decoded={};occupied=set();pending=[start];returns=set()
                while pending:
                    pc=pending.pop()
                    if pc in decoded: continue
                    if not start<=pc<end:
                        if end==start+self.BYTE_LIMIT:self.budget('byte cap')
                        raise e.Unsupported('incomplete summary CFG / byte budget')
                    self.charge();self.instructions+=1
                    raw=next(decoder.disasm(img.bytes_at(pc,min(15,end-pc)),pc,count=1),None)
                    if raw is None:
                        if end==start+self.BYTE_LIMIT and end-pc<15:self.budget('byte cap')
                        raise e.Unsupported('incomplete summary decoding')
                    ins=e.Insn(raw.address,raw.size,raw.mnemonic,raw.op_str,[e.Operand.from_capstone(o) for o in raw.operands],raw)
                    span=set(range(pc,pc+ins.size))
                    if span & occupied: raise e.Unsupported('overlapping summary decoding')
                    occupied.update(span)
                    node['decoded_bytes']=len(occupied)
                    decoded[pc]=ins;op=ins.operands[0] if ins.operands else None
                    if ins.mnemonic in ('fstenv','fnstenv','fsave','fnsave') or (ins.mnemonic=='call' and op.type==e.X.X86_OP_IMM and op.imm==pc+ins.size):
                        node['hazard']=(False,'callee unmodeled instruction-location observation')
                        raise e.Unsupported(node['hazard'][1])
                    dest=None;kind='direct-summary'
                    if pc==start and ins.mnemonic=='jmp':
                        if op.type==e.X.X86_OP_IMM:
                            dest=img,op.imm,depth;kind='forwarding-thunk'
                        elif op.type==e.X.X86_OP_MEM and not (op.mem.base or op.mem.index or op.mem.segment):
                            dest=self.imported(img,op.mem.disp,depth);kind='import-thunk'
                        if dest is None: raise e.Unsupported('unknown forwarding target')
                    elif ins.mnemonic=='call':
                        if op.type==e.X.X86_OP_IMM: dest=img,op.imm,depth
                        else: node['reason']='indirect callee: full inputs'
                    if dest is not None:
                        child=(side,id(dest[0]),dest[1],dest[2]);node['edges'][pc]=(child,kind)
                        todo.append((child,*dest))
                        if pc==start and ins.mnemonic=='jmp': node['alias']=child;break
                    if ins.mnemonic=='ret': returns.add(op.imm if op else 0);continue
                    if ins.mnemonic.startswith('j'):
                        if op is None or op.type!=e.X.X86_OP_IMM: raise e.Unsupported('unknown jump target')
                        pending.append(op.imm)
                        if ins.mnemonic=='jmp': continue
                    pending.append(pc+ins.size)
                code=[decoded[pc] for pc in sorted(decoded)];node['code']=code
                seen=set(range(len(code)))
                node['cleanup']=next(iter(returns)) if len(returns)==1 else None
                node['reachable']=seen;node['reason']='pending fixed point'
            except (e.Unsupported,e.NotProven,OSError,ValueError) as error:
                node['code']=None;node['reason']=str(error)
        return first,added
    def components(self, added):
        # Iterative Kosaraju; reverse the caller-first components for bottom-up use.
        selected=set(added);seen=set();finish=[];back={k:[] for k in added}
        for k in added:
            for child,_ in self.nodes[k]['edges'].values():
                if child in back: back[child].append(k)
        for root in self.ordered(added):
            stack=[(root,False)]
            while stack:
                key,done=stack.pop()
                if done: finish.append(key);continue
                if key in seen: continue
                seen.add(key);stack.append((key,True))
                stack.extend((v,False) for v in self.ordered({v for v,_ in self.nodes[key]['edges'].values() if v in selected and v not in seen}))
        seen=set();parts=[]
        for root in reversed(finish):
            if root in seen: continue
            part=[];todo=[root]
            while todo:
                key=todo.pop()
                if key in seen: continue
                seen.add(key);part.append(key);todo.extend(self.ordered(back[key]))
            parts.append(self.ordered(part))
        return reversed(parts)
    def solve(self, owner, added):
        e=self.e
        for part in self.components(added):
            inside=set(part)
            changed=True;rounds=0
            while changed:
                changed=False;self.iterations+=1;rounds+=1
                if rounds>self.SCC_ITERATION_LIMIT:
                    self.fail_component(part,'read SCC iteration cap');break
                for key in part:
                    n=self.active=self.nodes[key];n['read_iterations']+=1
                    code=n.get('code');result=None;valid=False
                    old=(n['value'],n['valid'],n['hazard'])
                    for child,_ in n['edges'].values():
                        if self.nodes[child]['hazard']: n['hazard']=self.nodes[child]['hazard']
                    if code is not None and n['work']<self.INSTRUCTION_LIMIT:
                        if n['alias'] is not None:
                            child=self.nodes[n['alias']];result=child['value'];valid=child['valid']
                        else:
                            nested={}
                            for i in n.get('reachable',()):
                                pc=code[i].address
                                if code[i].mnemonic!='call': continue
                                child=n['edges'].get(pc,(None,None))[0]
                                target=self.nodes.get(child)
                                nested[pc]=(target['value'] if target and (target['valid'] or child in inside) else
                                            (self.convention,target['value'][1] if target else None,frozenset(),True))
                            before=owner.h1;owner.h1=set()
                            try:
                                result=owner._scan(n['side'],n['target'],code=code,nested=nested)
                                valid=result is not None
                                if valid: result=(*result,any(v[3] for v in nested.values()))
                            except (e.Unsupported,e.NotProven) as error:
                                n['hazard']=(isinstance(error,e.NotProven),str(error));n['reason']=str(error)
                            n['h1'].update(owner.h1);owner.h1=before
                    elif code is not None:
                        self.budget('instruction cap');n['reason']='callee instruction budget'
                    value=result or (self.full,n.get('cleanup'),self.flags,False)
                    if n['budget_outcomes']:
                        # Incomplete SCC iteration cannot publish a narrowed result.
                        self.fail_component(part,'read SCC member cap at '+hex(n['target'])+': '+', '.join(sorted(n['budget_outcomes'])))
                        changed=False;break
                    # All components start at top; no result may widen a read set.
                    assert value[0]<=n['value'][0] and value[2]<=n['value'][2]
                    n['value']=value;n['valid']=valid and n['hazard'] is None
                    if old!=(n['value'],n['valid'],n['hazard']): changed=True
            self.solve_writes(part)
    def solve_writes(self,part):
        # None is top (all offsets for any argument), never published unfinished.
        cyclic=len(part)>1 or any(child==part[0] for child,_ in self.nodes[part[0]]['edges'].values())
        changed=True;rounds=0
        while changed:
            changed=False;rounds+=1
            if rounds>self.SCC_ITERATION_LIMIT:
                self.fail_component(part,'must-write SCC iteration cap',True);return
            for key in part:
                n=self.active=self.nodes[key];n['write_iterations']+=1;old=n['writes']
                try:
                    if not n['valid'] or n['value'][3]: value={};reads=[]
                    elif n['alias'] is not None:
                        child=self.nodes[n['alias']];value=child['writes'];reads=child['write_reads']
                    else:value,reads=self.must_write(n)
                except self.e.Unsupported as error:
                    value,reads={},[];n['write_reason']=str(error)
                    if 'budget' in str(error):self.budget(str(error))
                if 'instruction cap' in n['budget_outcomes'] or 'budget' in n.get('write_reason',''):
                    self.fail_component(part,'must-write SCC member cap at '+hex(n['target']),True)
                    return
                if old is not None:
                    value={a:bits & old.get(a,0) for a,bits in (old if value is None else value).items() if bits & old.get(a,0)}
                n['writes'],n['write_reads']=value,reads
                if old!=value and cyclic:changed=True
    def must_write(self,n):
        e=self.e;X=e.X;full=(1<<64)-1;code=n['code'];barriers=[]
        def bits(off,size):return sum(1<<k for k in range(max(0,off),min(64,off+size)))
        def shift(tag,off):return (*tag[:-1],(tag[-1]+off+0x80000000)%0x100000000-0x80000000) if tag else None
        initial=({r:('p',r,0) for r in ('eax','edx','ecx')}|{'esp':('s',0)}, {}, {})
        incoming={0:initial};todo=[0];visits=0
        def transfer(i,state,record=False):
            self.charge();regs,slots,defined=map(dict,state);ins=code[i];oo=ins.operands;m=ins.mnemonic;sp=regs.get('esp')
            if ins.raw.prefix and any(ins.raw.prefix) or m not in e.INTEGER_OPS and not m.startswith(('j','set')):
                raise e.Unsupported('must-write unsupported instruction/prefix')
            def address(op):
                if op.mem.segment or op.mem.index:return None
                return shift(regs.get(ins.reg_name(op.mem.base)),op.mem.disp)
            def value(op):
                if op.type==X.X86_OP_REG:return regs.get(ins.reg_name(op.reg))
                if op.type==X.X86_OP_MEM and op.size==4:
                    at=address(op)
                    if at and at[0]=='s':return slots.get(at[1],('p',at[1],0) if None not in slots and at[1]>=4 and at[1]%4==0 else None)
                return None
            def read(at,size):
                if record and at and at[0]=='s':
                    for off in range(at[1],at[1]+size):
                        if off>=4 and not defined.get(('s',off)):barriers.append((('stack',off),1,dict(defined),hex(ins.address),m+' '+ins.op_str))
                elif record:
                    barriers.append((at[1] if at else None,bits(at[2],size) if at else full,dict(defined),hex(ins.address),m+' '+ins.op_str))
            for k,op in enumerate(oo):
                if m!='lea' and op.type==X.X86_OP_MEM and ins.raw.operands[k].access & e.CS.CS_AC_READ:read(address(op),op.size)
            tag=value(oo[1]) if m=='mov' and len(oo)==2 and oo[0].size==4 else None
            if m=='lea':tag=address(oo[1])
            if m in ('add','sub') and oo[1].type==X.X86_OP_IMM:tag=shift(regs.get(ins.reg_name(oo[0].reg)),oo[1].imm*(-1 if m=='sub' else 1))
            pushed=value(oo[0]) if m=='push' else None
            if m=='pop':tag=slots.get(sp[1]) if sp and sp[0]=='s' else None
            for k,op in enumerate(oo):
                if op.type!=X.X86_OP_MEM or not ins.raw.operands[k].access & e.CS.CS_AC_WRITE:continue
                at=address(op)
                if at and at[0]=='p':defined[at[1]]=defined.get(at[1],0)|bits(at[2],op.size)
                if at and at[0]=='s':
                    for off in range(max(4,at[1]),at[1]+op.size):defined['s',off]=1
                    slots={k:v for k,v in slots.items() if k is None or not max(k,at[1])<min(k+4,at[1]+op.size)}
                    for k in range(at[1]//4*4,at[1]+op.size,4):slots[k]=None
                    if m=='mov' and op.size==4 and value(oo[1]):slots[at[1]]=value(oo[1])
                else:slots={None:None}  # An aliasing write kills lazy incoming-stack identities.
            for reg in ins.raw.regs_access()[1]:regs.pop(e.ALIASES.get(ins.reg_name(reg),(ins.reg_name(reg),))[0],None)
            if oo and oo[0].type==X.X86_OP_REG and tag:regs[ins.reg_name(oo[0].reg)]=tag
            if m=='push':
                if not sp or sp[0]!='s':raise e.Unsupported('must-write unknown ESP')
                regs['esp']=shift(sp,-4);slots.pop(sp[1]-4,None)
                if pushed:slots[sp[1]-4]=pushed
            elif m=='pop':
                if not sp or sp[0]!='s' or oo[0].type!=X.X86_OP_REG or ins.reg_name(oo[0].reg)=='esp':raise e.Unsupported('must-write unsupported POP')
                regs['esp']=shift(sp,4)
            elif m=='leave':
                if state[0].get('ebp',(None,))[0]!='s':raise e.Unsupported('must-write unknown EBP')
                regs['esp']=shift(state[0]['ebp'],4)
            elif m=='call':
                child=self.nodes[n['edges'][ins.address][0]];writes=child['writes']
                if not sp or sp[0]!='s' or child['value'][1] is None:raise e.Unsupported('must-write unknown cleanup')
                forwarded={r:state[0].get(r) for r in ('eax','edx','ecx')}
                forwarded.update({at-sp[1]+4:t for at,t in state[1].items() if at is not None and at>=sp[1]})
                for arg,t in forwarded.items():
                    if t and t[0]=='p' and t[2]==0:defined[t[1]]=defined.get(t[1],0)|(full if writes is None else writes.get(arg,0))
                if record:
                    for arg,mask,defs,pc,text in child['write_reads']:
                        prior=dict(state[2])
                        for a,p in forwarded.items():
                            if p and p[0]=='p' and p[2]==0:prior[p[1]]=prior.get(p[1],0)|defs.get(a,0)
                        if isinstance(arg,tuple):
                            off=sp[1]+arg[1]-4
                            if off>=4 and not state[2].get(('s',off)):barriers.append((('stack',off),mask,prior,pc,text))
                            continue
                        t=forwarded.get(arg)
                        barriers.append((t[1] if t and t[0]=='p' and t[2]==0 else None,mask,prior,pc,text))
                    barriers.append((None,full,dict(defined),hex(ins.address),'nested call'))
                regs['esp']=shift(sp,child['value'][1]);slots={None:None}
                for r in ('eax','edx','ecx'):regs.pop(r,None)
            if m!='ret' and regs.get('esp',(None,))[0]!='s':raise e.Unsupported('must-write unknown ESP')
            return regs,slots,defined
        while todo:
            i=todo.pop();visits+=1
            if visits>512:raise e.Unsupported('must-write fixed-point budget')
            after=transfer(i,incoming[i])
            for j in e.successors(code,i):
                old=incoming.get(j)
                merged=after if old is None else tuple({k:v for k,v in a.items() if b.get(k)==v} if q<2 else {k:v&b.get(k,0) for k,v in a.items() if v&b.get(k,0)} for q,(a,b) in enumerate(zip(old,after)))
                if old is not None and old[1]!=after[1]:merged[1][None]=None
                if old!=merged:incoming[j]=merged;todo.append(j)
        returns=[]
        for i,state in incoming.items():
            after=transfer(i,state,True)
            if code[i].mnemonic=='ret':returns.append(after[2])
        result=dict(returns[0]) if returns else {}
        for ret in returns[1:]:result={a:v&ret.get(a,0) for a,v in result.items()}
        for arg,mask,defs,_,_ in barriers:
            if isinstance(arg,tuple):continue
            result={a:v & (defs.get(a,0)|(full^mask) if a==arg else defs.get(a,0)) for a,v in result.items()}
        return {a:v for a,v in result.items() if v and not isinstance(a,tuple)},barriers
    def query(self, owner, side, target):
        image=(self.inp.old,self.inp.new)[side]
        key,added=self.discover(side,image,target,0)
        if added: self.solve(owner,added)
        todo=[key];seen=set()
        while todo:
            k=todo.pop()
            if k in seen: continue
            seen.add(k);n=self.nodes[k];owner.h1.update(n['h1'])
            owner.summary_budgets[k]=dict(side=n['side'],image=self.image_labels[k[1]],target=hex(n['target']),hop=n['hop'],
                byte_limit=self.BYTE_LIMIT,instruction_limit=self.INSTRUCTION_LIMIT,scc_iteration_limit=self.SCC_ITERATION_LIMIT,
                decoded_bytes=n['decoded_bytes'],instructions=n['work'],read_iterations=n['read_iterations'],write_iterations=n['write_iterations'],
                outcomes=sorted(n['budget_outcomes']) or ['within caps'],read_summary=n['valid'],must_write_summary=n['valid'] and not n['value'][3] and n['writes'] is not None and not n.get('write_reason'))
            for pc,(child,kind) in n['edges'].items():
                owner.dependencies.add((side,hex(pc),hex(self.nodes[child]['target']),kind));todo.append(child)
        n=self.nodes[key]
        if n['hazard']:
            failure,message=n['hazard'];raise (self.e.NotProven if failure else self.e.Unsupported)(message)
        return n['value'] if n['valid'] else None


def frame_writes(checker,info,k):
    """Only checked, untainted summaries discharge individual caller bytes."""
    side=info['side'];ins=info['code'][k];site=checker.contracts.sites[side,ins.address][2]
    graph=getattr(checker.inp,'call_summaries',None)
    if graph is None or 'H3c' in site['premises'] or ins.operands[0].type!=graph.e.X.X86_OP_IMM:return set()
    image=(checker.inp.old,checker.inp.new)[side];node=graph.nodes.get((side,id(image),ins.operands[0].imm,0))
    if not node or node['writes'] is None:return set()
    regs,_,_,stack=info['before'][k];sp=regs['esp'];passed={r:regs[r] for r in ('eax','edx','ecx') if r in regs}
    passed.update({at-sp+4:p for at,p in stack.items() if at>=sp})
    allowed=set();evidence=[]
    for arg,point in passed.items():
        if not info['low']<=point<0 or point<sp:continue
        mask=node['writes'].get(arg,0)
        offsets=[i for i in range(64) if mask>>i&1 and info['low']<=point+i<0]
        allowed.update(point+i for i in offsets);evidence.append(dict(argument=arg,frame_offset=point,must_write_offsets=offsets))
        for readarg,readmask,defs,pc,text in node['write_reads']:
            if isinstance(readarg,tuple):continue
            blocked=((1<<64)-1)^defs.get(arg,0)
            if readarg==arg:blocked &= readmask
            blocked &= sum(1<<i for i in range(64) if info['low']<=point+i<0 and point+i not in info['before'][k][1]) & ~mask
            if blocked and not site.get('callee_read_first'):site['callee_read_first']=dict(pc=pc,instruction=text,argument=arg,possible_alias=readarg!=arg)
    for arg,_,defs,pc,text in node['write_reads']:
        if isinstance(arg,tuple):
            off=sp+arg[1]-4
            initialized=any(0<=off-p<64 and defs.get(a,0)>>(off-p)&1 for a,p in passed.items())
            if off in allowed and not initialized:
                allowed.remove(off);site['callee_read_first']=dict(pc=pc,instruction=text,argument='stack',frame_offset=off,possible_alias=False)
    for row in evidence:row['must_write_offsets']=[i for i in row['must_write_offsets'] if row['frame_offset']+i in allowed]
    site['must_write_evidence']=evidence;site['must_write_masked_frame_offsets']=sorted(allowed)
    return allowed
