"""Bounded frame-entry extent and definite-initialization obligations (H4)."""
import sys

def model():
    return sys.modules.get('equiv') or sys.modules['__main__']

def private_extent(code):
    e=model();off=0
    restores={ins.reg_name(ins.operands[0].reg) for ins in code
              if ins.mnemonic=='pop' and ins.operands[0].type==e.X.X86_OP_REG}
    if any(ins.mnemonic=='leave' for ins in code): restores.add('ebp')
    for ins in code:
        oo=ins.operands;m=ins.mnemonic
        if (m=='push' and oo[0].type==e.X.X86_OP_REG and oo[0].size==4
            and ins.reg_name(oo[0].reg) in {'ebx','esi','edi','ebp','ecx'} & restores): off-=4
        elif (m=='mov' and len(oo)==2 and all(o.type==e.X.X86_OP_REG for o in oo)
              and [ins.reg_name(o.reg) for o in oo]==['ebp','esp']): pass
        elif (m in ('add','sub') and oo[0].type==e.X.X86_OP_REG
              and ins.reg_name(oo[0].reg)=='esp' and oo[1].type==e.X.X86_OP_IMM):
            delta=oo[1].imm*(-1 if m=='sub' else 1)
            if delta>0: break
            off+=delta
        else: break
        if not -512<=off<=0: raise e.Unsupported('private frame extent exceeds budget')
    return off

def independent_private(states,lows,stack=None):
    e=model()
    for side,st in enumerate(states):
        base=st.regs['esp'] if stack is None else stack
        for off in range(lows[side],0):
            st.memory=e.z3.Store(st.memory,base+e.bv(off),e.z3.BitVec('entry_private_%d_%d'%(side,off),8))

def check_initialized(checker,code,side,low):
    """Must-defined bytes, pointer offsets and concrete cleanup; intersect at joins.
    Reads are checked only after convergence, so worklist order cannot hide a path.
    Unknown address aliases remain in the independent unified-array proof.
    """
    e=model();X=e.X
    key=(side,low,tuple((i.address,i.mnemonic,i.op_str,i.flow,i.mutation) for i in code))
    cache=getattr(checker,'garbage_cache',{});checker.garbage_cache=cache
    if key in cache:return cache[key]
    reads=[];public_writes=set()
    entry=({'esp':0},frozenset(),False,{});incoming={0:entry};todo=[0];steps=0
    def transfer(i,state,check=False):
        regs,defined,escaped,stack=state;regs=dict(regs);defined=set(defined);stack=dict(stack)
        ins=code[i];oo=ins.operands;m=ins.mnemonic;sp=regs.get('esp')
        if ins.mutation=='drop store':return state
        def address(op):
            if op.mem.segment or op.mem.index: return None
            base=ins.reg_name(op.mem.base)
            return regs[base]+op.mem.disp if base in regs else None
        def access(at,size,write=False):
            if at is None: return
            if at < -512: raise e.Unsupported('private initialization extent exceeds budget at '+hex(ins.address)+' ('+ins.mnemonic+' '+ins.op_str+')')
            slots=set(range(at,min(0,at+size)))
            if check and not write and slots-defined:
                if min(slots-defined)<low: raise e.Unsupported('private allocation outside fixed prologue extent')
                reads.append((i,min(slots-defined)))
            if write: defined.update(slots)
        # Capstone marks x87 store operands as reads; follow Machine semantics.
        fp_store=m in ('fst','fstp','fist','fistp','fnstcw','fnstsw')
        # Source operands are read before any destination writes.
        if m!='lea' and not fp_store:
            for k,op in enumerate(oo):
                if op.type==X.X86_OP_MEM and ins.raw.operands[k].access & e.CS.CS_AC_READ:
                    access(address(op),op.size)
        if m in ('pop','ret','leave'):
            access(regs.get('ebp') if m=='leave' else sp,4)
        pointer=None
        if len(oo)>1 and oo[0].type==X.X86_OP_REG:
            if m=='mov' and oo[1].type==X.X86_OP_REG: pointer=regs.get(ins.reg_name(oo[1].reg))
            if m=='lea' and oo[1].type==X.X86_OP_MEM: pointer=address(oo[1])
            if m in ('add','sub') and oo[1].type==X.X86_OP_IMM:
                old=regs.get(ins.reg_name(oo[0].reg))
                if old is not None: pointer=old+oo[1].imm*(-1 if m=='sub' else 1)
        for k,op in enumerate(oo):
            if op.type==X.X86_OP_MEM and (fp_store or ins.raw.operands[k].access & e.CS.CS_AC_WRITE):
                at=address(op);access(at,op.size,True)
                if at is None or at>=0:public_writes.add(ins.address)
                stack={k:v for k,v in stack.items() if at is not None and not max(k,at)<min(k+4,at+op.size)}
                if at is not None and m=='mov' and op.size==4 and oo[1].type==X.X86_OP_REG and ins.reg_name(oo[1].reg) in state[0]:stack[at]=state[0][ins.reg_name(oo[1].reg)]
        for reg in ins.raw.regs_access()[1]:
            name=ins.reg_name(reg);root=e.ALIASES.get(name,(name,))[0];regs.pop(root,None)
        if oo and oo[0].type==X.X86_OP_REG and pointer is not None:
            name=ins.reg_name(oo[0].reg);regs[name]=pointer
            if pointer<0 and name not in ('esp','ebp'):escaped=True
        if any(o.type==X.X86_OP_MEM for o in oo) and len(oo)>1 and oo[1].type==X.X86_OP_REG and state[0].get(ins.reg_name(oo[1].reg),0)<0:escaped=True
        if m=='push':
            if oo[0].type==X.X86_OP_REG and state[0].get(ins.reg_name(oo[0].reg),0)<0: escaped=True
            if sp is None: raise e.Unsupported('private initialization has unknown ESP')
            regs['esp']=sp-4;access(sp-4,4,True)
            stack.pop(sp-4,None)
            if oo[0].type==X.X86_OP_REG and ins.reg_name(oo[0].reg) in state[0]:stack[sp-4]=state[0][ins.reg_name(oo[0].reg)]
        elif m=='pop':
            if oo[0].type==X.X86_OP_REG and ins.reg_name(oo[0].reg)=='esp': raise e.Unsupported('private initialization has unknown ESP')
            if sp is None: raise e.Unsupported('private initialization has unknown ESP')
            regs['esp']=sp+4
        elif m=='leave':
            if 'ebp' not in state[0]: raise e.Unsupported('private initialization has unknown EBP')
            regs['esp']=state[0]['ebp']+4
        elif m=='ret':
            if sp is not None: regs['esp']=sp+4+(oo[0].imm if oo else 0)
        elif m=='call':
            site=checker.contracts.sites.get((side,ins.address))
            if sp is None or site is None: raise e.Unsupported('private initialization has unknown cleanup')
            if check and escaped and set(range(low,0))-defined:reads.append((i,min(set(range(low,0))-defined)))
            defined.update(range(low,0))  # Machine.call's common memory havoc.
            stack={}
            regs['esp']=sp+site[1]
            for r in ('eax','edx','ecx'): regs.pop(r,None)
        if m in ('add','sub','mov','lea') and oo[0].type==X.X86_OP_REG and ins.reg_name(oo[0].reg)=='esp' and regs.get('esp',0)<low:
            raise e.Unsupported('private allocation outside fixed prologue extent')
        if 'esp' not in regs and m!='ret': raise e.Unsupported('private initialization has unknown ESP')
        return regs,frozenset(defined),escaped,stack
    while todo:
        i=todo.pop();steps+=1
        if steps>8192: raise e.Unsupported('private initialization fixed point budget')
        after=transfer(i,incoming[i])
        for j in e.successors(code,i):
            old=incoming.get(j)
            merged=after if old is None else ({r:v for r,v in old[0].items() if after[0].get(r)==v},old[1]&after[1],old[2] or after[2],{a:p for a,p in old[3].items() if after[3].get(a)==p})
            if old!=merged: incoming[j]=merged;todo.append(j)
    after={i:transfer(i,state,True) for i,state in incoming.items()}
    info=dict(code=code,side=side,low=low,before=incoming,after=after,reads=reads,public_writes=sorted(public_writes))
    cache[key]=info
    return info


class CutGarbage:
    """H4 at arbitrary cut points; mask only undefined, unescaped bytes."""
    def __init__(self,checker,codes):
        self.e=model();self.checker=checker
        self.infos=[check_initialized(checker,c,s,private_extent(c)) for s,c in enumerate(codes)]
    def prepare(self,states,heads):
        e=self.e
        for st,info,head in zip(states,self.infos,heads):
            if head not in info['before']:raise e.Unsupported('exception region requires linked private-entry relation')
            regs,defined,_,_=info['before'][head]
            st.h4_base=e.simp(st.regs['esp']-e.bv(regs['esp']))
            # These pointer offsets are established by the same must fixed point.
            for reg,off in sorted(regs.items()):st.regs[reg]=e.simp(st.h4_base+e.bv(off))
            for off in sorted(set(range(info['low'],0))-defined):
                st.memory=e.z3.Store(st.memory,st.h4_base+e.bv(off),e.z3.FreshConst(e.BYTE,'private_garbage'))
            from equiv_ownership import Ownership
            Ownership(self.checker,info,st.h4_base,head).prepare(st)
    def mask(self,memory,base,info,state,allowed=(),st=None):
        e=self.e
        if st is not None and not e.prove(st.ownership.goals(st)):return memory
        public=e.z3.Array('memory',e.BV32,e.BYTE)
        for off in sorted(set(range(info['low'],0))-state[1]):
            address=base+e.bv(off)
            exposed=getattr(st,'call_exposed',{}).get(off,e.z3.BoolVal(False))
            memory=e.z3.Store(memory,address,e.z3.If(exposed,e.z3.Select(memory,address),e.z3.Select(public,address)))
        return e.simp(memory)
    def step(self,machine,st,side,k):
        info=self.infos[side];ins=info['code'][k];before=len(st.events)
        if ins.mnemonic=='call':
            from equiv_summaries import frame_writes,write_body
            regs,_,_,stack=info['before'][k];sp=regs['esp']
            observed=self.checker.contracts.sites[side,ins.address][0]
            arguments={r:st.regs[r] for r in self.e.REGS if r!='esp' and any(('r',r,lane) in observed for lane in range(4))}
            extent=max(0,info['low']-sp,self.checker.contracts.sites[side,ins.address][1])
            if extent>128 or extent%4:raise self.e.Unsupported('per-call stack argument extent exceeds budget')
            # Inspect modeled arguments without manufacturing an executed H1 load.
            arguments.update({at+4:self.e.z3.Concat([self.e.z3.Select(st.memory,st.regs['esp']+self.e.bv(at+j)) for j in reversed(range(4))]) for at in range(0,extent,4)})
            values=list(arguments.values())
            allowed=frame_writes(self.checker,info,k)
            graph=getattr(self.checker.inp,'call_summaries',None);site=self.checker.contracts.sites[side,ins.address][2]
            node=graph.nodes.get((side,id((self.checker.inp.old,self.checker.inp.new)[side]),ins.operands[0].imm,0)) if graph and ins.operands[0].type==self.e.X.X86_OP_IMM else None
            node=write_body(graph,node) if graph else None
            reads=None
            closed=False
            if node and node['valid'] and node['writes'] is not None and not node.get('write_reason') and 'H3c' not in site['premises']:
                try:
                    if 'closed_pointer_reads' not in node:
                        node['closed_pointer_reads']=all(i.mnemonic=='ret' for n,i in enumerate(node['code']) if not self.e.successors(node['code'],n))
                    closed=node['closed_pointer_reads']
                except self.e.Unsupported:pass  # Refinement unavailable; retain the full reach.
            if closed:
                if all(arg is not None and not isinstance(arg,tuple) for arg,_,_,_,_ in node['write_reads']):
                    reads={arg:0 for arg in arguments}
                    for arg,bits,_,_,_ in node['write_reads']:reads[arg]=reads.get(arg,0)|bits
            points={r:p for r,p in regs.items() if r in arguments}
            points.update({at-sp+4:p for at,p in stack.items() if at>=sp})
            fixed=set()
            for arg,p in points.items():
                if info['low']<=p<0 or reads is None:fixed.update(range(max(info['low'],p),0))
                else:fixed.update(p+j for j in range(64) if reads.get(arg,0)>>j&1 and info['low']<=p+j<0)
            symbolic={arg:v for arg,v in arguments.items() if arg not in points}
            # For p inside the frame, extent covers every byte from p to top.
            # Keep the draft's conservative outside-frame fringe as a minimum,
            # never a cap on the private extent; constant bounds avoid SMT ranges.
            reach_extent=max(64,-info['low'])
            def reaches(off,arg,v):
                delta=st.h4_base+self.e.bv(off)-v
                full=self.e.z3.ULT(delta,self.e.bv(reach_extent))
                if reads is None:return full
                precise=self.e.z3.Or([delta==self.e.bv(j) for j in range(64) if reads.get(arg,0)>>j&1])
                return self.e.z3.If(self.e.outside(v,st.h4_base,info['low']),precise,full)
            st.call_exposed={off:(self.e.z3.BoolVal(True) if off in fixed else self.e.simp(self.e.z3.Or([reaches(off,arg,v) for arg,v in sorted(symbolic.items(),key=lambda kv:repr(kv[0]))]))) for off in range(info['low'],0) if off not in allowed}
            # Passing is safe because uncovered reachable bytes remain visible;
            # H3 forbids retaining the pointer after this particular call.
            st.ownership.passed(st,values,range(info['low'],0),sum(isinstance(arg,str) for arg in arguments))
        machine.step(st,ins)
        st.event_pcs=getattr(st,'event_pcs',[])+[ins.address]*(len(st.events)-before)
        if ins.mnemonic=='ret':st.ownership.result(st)
        for j in range(before,len(st.events)):
            event=st.events[j]
            if event[0]=='call':
                from equiv_summaries import frame_writes
                event=list(event);event[6]=self.mask(event[6],st.h4_base,info,info['before'][k],frame_writes(self.checker,info,k),st);st.events[j]=tuple(event)
    def memories(self,states,tails):
        memories=[]
        for st,info,tail in zip(states,self.infos,tails):
            st.call_exposed={}  # H3 excludes retention/publication beyond the call.
            memories.append(self.mask(st.memory,st.h4_base,info,info['after'][tail],st=st))
        return memories
    def failed(self,tails):
        # A diagnostic is attached only after a failed symbolic transition.
        for info,tail in zip(self.infos,tails):
            for index,offset in info['reads']:
                todo=[index];seen=set()
                while todo:
                    i=todo.pop()
                    if i==tail:
                        self.checker.garbage_witness=dict(side=info['side'],pc=hex(info['code'][index].address),offset=offset,kind='callee' if info['code'][index].mnemonic=='call' else 'direct-read')
                        site=self.checker.contracts.sites.get((info['side'],info['code'][index].address))
                        if site and site[2].get('callee_read_first'):self.checker.garbage_witness['callee_read']=site[2]['callee_read_first']
                        elif site and info['code'][index].mnemonic=='call':
                            target=site[2].get('target');graph=getattr(self.checker.inp,'call_summaries',None)
                            todo=[(info['side'],id((self.checker.inp.old,self.checker.inp.new)[info['side']]),int(target,16),0)] if graph and target and target.startswith('0x') else [];visited=set()
                            detail=dict(pc=target or 'unknown target',instruction='no checked must-write summary')
                            while todo and len(visited)<256:
                                key=todo.pop()
                                if key in visited or key not in graph.nodes:continue
                                visited.add(key);node=graph.nodes[key]
                                if node.get('alias') is not None:todo.append(node['alias'])
                                todo.extend(child for child,_ in node['edges'].values())
                                opaque=next((ins for ins in node['code'] if (ins.mnemonic=='call' and ins.address not in node['edges']) or (ins.mnemonic=='jmp' and ins.operands[0].type!=self.e.X.X86_OP_IMM)),None)
                                if opaque or node.get('write_reason'):
                                    ins=opaque or node['code'][0];detail=dict(pc=hex(ins.address),instruction=ins.mnemonic+' '+ins.op_str,reason=node.get('write_reason') or 'opaque call: no must-write summary');break
                            self.checker.garbage_witness['callee_scan']=detail
                        return
                    if i not in seen:
                        seen.add(i);todo.extend(self.e.successors(info['code'],i))
