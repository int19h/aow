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
            if at < -512: raise e.Unsupported('private initialization extent exceeds budget')
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
            for reg,off in regs.items():st.regs[reg]=e.simp(st.h4_base+e.bv(off))
            for off in set(range(info['low'],0))-defined:
                st.memory=e.z3.Store(st.memory,st.h4_base+e.bv(off),e.z3.FreshConst(e.BYTE,'private_garbage'))
            from equiv_ownership import Ownership
            Ownership(self.checker,info,st.h4_base,head).prepare(st)
    def mask(self,memory,base,info,state,allowed=(),st=None):
        e=self.e
        if state[2] and not allowed:return memory
        if st is not None and not e.prove(st.ownership.goals(st)+getattr(st,'call_access_goals',[])):return memory
        public=e.z3.Array('memory',e.BV32,e.BYTE)
        for off in set(range(info['low'],0))-state[1]:
            if state[2] and off not in allowed:continue
            address=base+e.bv(off);memory=e.z3.Store(memory,address,e.z3.Select(public,address))
        return e.simp(memory)
    def step(self,machine,st,side,k):
        info=self.infos[side];ins=info['code'][k];before=len(st.events)
        if ins.mnemonic=='call':
            from equiv_summaries import frame_writes
            regs,_,_,stack=info['before'][k];sp=regs['esp']
            observed=self.checker.contracts.sites[side,ins.address][0]
            values=[st.regs[r] for r in self.e.REGS if r!='esp' and any(('r',r,lane) in observed for lane in range(4))]+[st.load(st.regs['esp']+self.e.bv(at-sp),4) for at in stack if at>=sp]
            st.call_access_goals=[self.e.z3.Implies(st.ownership.guard(st),self.e.outside(st.regs[r],st.h4_base,info['low'])) for r in ('ebx','esi','edi','ebp') if any(('r',r,lane) in observed for lane in range(4))]
            st.ownership.passed(st,values,frame_writes(self.checker,info,k),sum(r!='esp' and any(('r',r,lane) in observed for lane in range(4)) for r in self.e.REGS))
        machine.step(st,ins)
        if ins.mnemonic=='ret':st.ownership.result(st)
        for j in range(before,len(st.events)):
            event=st.events[j]
            if event[0]=='call':
                from equiv_summaries import frame_writes
                event=list(event);event[6]=self.mask(event[6],st.h4_base,info,info['before'][k],frame_writes(self.checker,info,k),st);st.events[j]=tuple(event)
    def memories(self,states,tails):
        return [self.mask(st.memory,st.h4_base,info,info['after'][tail],st=st) for st,info,tail in zip(states,self.infos,tails)]
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
                        return
                    if i not in seen:
                        seen.add(i);todo.extend(self.e.successors(info['code'],i))
