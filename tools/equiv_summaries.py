"""Step 4b: bounded, module-cached descending call-graph summaries.
Top means every modeled input; opaque nested calls carry an explicit H3c taint.
Effects/ABI remain H3 premises; these summaries are not callee equivalence proofs.
"""
class ModuleSummaries:
    BYTE_LIMIT = 4096
    INSTRUCTION_LIMIT = 50000
    def __init__(self, owner):
        self.inp = owner.checker.inp; self.e = owner.e
        self.full = owner.full | {('r','esp',k) for k in range(4)}
        self.flags = frozenset(('f',f) for f in self.e.FLAGS)
        self.convention = frozenset([('r',r,k) for r in ('eax','edx','ecx') for k in range(4)]+[('f','df')])
        self.nodes, self.images, self.imports = {}, {}, {}
        self.instructions = self.work = self.iterations = 0
        self.over_budget = 0
    def charge(self):
        if self.work>=self.INSTRUCTION_LIMIT:
            raise self.e.Unsupported('module summary instruction budget')
        self.work+=1
    def imported(self, image, cell, hop):
        key = id(image),cell,hop
        if key in self.imports: return self.imports[key]
        self.imports[key] = None
        if hop: return None
        e = self.e
        image.pe.parse_data_directories(directories=[e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT']])
        for module in getattr(image.pe,'DIRECTORY_ENTRY_IMPORT',()):
            for imp in module.imports:
                if imp.address!=cell or not imp.name: continue
                path = self.inp.original_path.parent/module.dll.decode('latin1')
                if not path.is_file(): return None
                if path not in self.images:
                    other = e.match.Image(path)
                    other.pe.parse_data_directories(directories=[e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
                    self.images[path] = other
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
                        value=(self.full,None,self.flags,False),valid=False,h1=set(),hazard=None,reason='unknown target')
            self.nodes[key] = node; added.append(key)
            if not img.contains(start): continue
            if self.work>=self.INSTRUCTION_LIMIT:
                node['reason']='module instruction budget'; self.over_budget+=1; continue
            try:
                ends = ([a for a,_ in self.inp.sigs.values()] if side==0 else
                        [self.inp.text+a for a in getattr(self.inp,'code_offsets',())]) if not depth else []
                end=start+min([self.BYTE_LIMIT]+[a-start for a in ends if a>start])
                decoder=e.CS.Cs(e.CS.CS_ARCH_X86,e.CS.CS_MODE_32);decoder.detail=True
                decoded={};occupied=set();pending=[start];returns=set()
                while pending:
                    pc=pending.pop()
                    if pc in decoded: continue
                    if not start<=pc<end: raise e.Unsupported('incomplete summary CFG / byte budget')
                    self.charge();self.instructions+=1
                    raw=next(decoder.disasm(img.bytes_at(pc,min(15,end-pc)),pc,count=1),None)
                    if raw is None: raise e.Unsupported('incomplete summary decoding')
                    ins=e.Insn(raw.address,raw.size,raw.mnemonic,raw.op_str,[e.Operand.from_capstone(o) for o in raw.operands],raw)
                    span=set(range(pc,pc+ins.size))
                    if span & occupied: raise e.Unsupported('overlapping summary decoding')
                    occupied.update(span)
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
        for root in added:
            stack=[(root,False)]
            while stack:
                key,done=stack.pop()
                if done: finish.append(key);continue
                if key in seen: continue
                seen.add(key);stack.append((key,True))
                stack.extend((v,False) for v,_ in self.nodes[key]['edges'].values() if v in selected and v not in seen)
        seen=set();parts=[]
        for root in reversed(finish):
            if root in seen: continue
            part=[];todo=[root]
            while todo:
                key=todo.pop()
                if key in seen: continue
                seen.add(key);part.append(key);todo.extend(back[key])
            parts.append(part)
        return reversed(parts)
    def solve(self, owner, added):
        e=self.e
        for part in self.components(added):
            inside=set(part)
            changed=True
            while changed:
                changed=False;self.iterations+=1
                for key in part:
                    n=self.nodes[key];code=n.get('code');result=None;valid=False
                    old=(n['value'],n['valid'],n['hazard'])
                    for child,_ in n['edges'].values():
                        if self.nodes[child]['hazard']: n['hazard']=self.nodes[child]['hazard']
                    if code is not None and self.work<self.INSTRUCTION_LIMIT:
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
                            n['h1'].update(owner.h1);owner.h1=before;owner.h1.update(n['h1'])
                    elif code is not None:
                        self.over_budget+=1;n['reason']='fixed-point instruction budget'
                    value=result or (self.full,n.get('cleanup'),self.flags,False)
                    if self.work>=self.INSTRUCTION_LIMIT:
                        # Incomplete SCC iteration cannot publish a narrowed result.
                        for member in part:
                            m=self.nodes[member];m['value']=(self.full,None,self.flags,False);m['valid']=False
                            m['reason']='fixed-point instruction budget'
                        changed=False;break
                    # All components start at top; no result may widen a read set.
                    assert value[0]<=n['value'][0] and value[2]<=n['value'][2]
                    n['value']=value;n['valid']=valid and n['hazard'] is None
                    if old!=(n['value'],n['valid'],n['hazard']): changed=True
    def query(self, owner, side, target):
        image=(self.inp.old,self.inp.new)[side]
        key,added=self.discover(side,image,target,0)
        if added: self.solve(owner,added)
        todo=[key];seen=set()
        while todo:
            k=todo.pop()
            if k in seen: continue
            seen.add(k);n=self.nodes[k];owner.h1.update(n['h1'])
            for pc,(child,kind) in n['edges'].items():
                owner.dependencies.add((side,hex(pc),hex(self.nodes[child]['target']),kind));todo.append(child)
        n=self.nodes[key]
        if n['hazard']:
            failure,message=n['hazard'];raise (self.e.NotProven if failure else self.e.Unsupported)(message)
        return n['value'] if n['valid'] else None
