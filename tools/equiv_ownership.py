"""Explicit H1 predicates and guarded H2 obligations; guarded semantic escape with the reviewed H2 derivation fallback."""
from equiv_garbage import model


def outside(value, base, low):
    e=model()
    return e.z3.UGE(e.bv(value)-base-e.bv(low),e.bv(-low)) if low else e.z3.BoolVal(True)


def argument_words(info):
    e=model();sizes={i.operands[0].imm if i.operands else 0 for i in info['code'] if i.mnemonic=='ret'}
    size=max(sizes,default=0)
    if size>128 or size%4:raise e.Unsupported('H1 stack argument extent exceeds budget')
    return range(4,size+1,4)


def origins(checker, info):
    """Must be an unchanged entry word. Unknown stores/calls kill saved origins."""
    e=model();code=info['code'];X=e.X
    incoming={0:({r:r for r in ('eax','edx','ecx')},{off:'stack argument +%d'%off for off in argument_words(info)})};todo=[0];steps=0
    while todo:
        i=todo.pop();steps+=1
        if steps>8192:raise e.Unsupported('H1 origin fixed point budget')
        regs,slots=incoming[i];rr=dict(regs);ss=dict(slots);ins=code[i];oo=ins.operands;m=ins.mnemonic
        known=info['before'].get(i,({},))[0]
        def addr(op):
            base=ins.reg_name(op.mem.base)
            return known[base]+op.mem.disp if base in known and not op.mem.index and not op.mem.segment else None
        source=None
        if m=='mov' and len(oo)==2 and oo[0].size==oo[1].size==4:
            if oo[1].type==X.X86_OP_REG:source=regs.get(ins.reg_name(oo[1].reg))
            elif oo[1].type==X.X86_OP_MEM:source=slots.get(addr(oo[1]))
        for reg in ins.raw.regs_access()[1]:rr.pop(e.ALIASES.get(ins.reg_name(reg),(ins.reg_name(reg),))[0],None)
        for k,op in enumerate(oo):
            if op.type==X.X86_OP_MEM and ins.raw.operands[k].access&e.CS.CS_AC_WRITE:
                at=addr(op)
                if at is None:ss={}
                else:ss={n:v for n,v in ss.items() if not max(n,at)<min(n+4,at+op.size)}
                if source and at is not None and m=='mov' and k==0:ss[at]=source
        if m=='mov' and source and oo[0].type==X.X86_OP_REG:rr[ins.reg_name(oo[0].reg)]=source
        if m=='push':
            at=known.get('esp',10**9)-4;ss.pop(at,None)
            if oo[0].type==X.X86_OP_REG and ins.reg_name(oo[0].reg) in regs:ss[at]=regs[ins.reg_name(oo[0].reg)]
        if m=='pop' and oo[0].type==X.X86_OP_REG:
            source=slots.get(known.get('esp'))
            if source:rr[ins.reg_name(oo[0].reg)]=source
        if m=='call':
            ss={}
            for r in ('eax','edx','ecx'):rr.pop(r,None)
        after=(rr,ss)
        for j in e.successors(code,i):
            old=incoming.get(j)
            merged=after if old is None else tuple({k:v for k,v in a.items() if b.get(k)==v} for a,b in zip(old,after))
            if old!=merged:incoming[j]=merged;todo.append(j)
    return incoming


class Ownership:
    def __init__(self,checker,info,base,head=0):
        e=model();self.e=e;self.checker=checker;self.info=info;self.base=base
        self.low=info['low'];self.side=info['side'];self.head=head
        self.premises=[];self.records=[];self.instances=[];self.loaded=[];self.pushes=[];self.obligations=[];self.pc=info['code'][head].address
    def assume(self,predicate,description):
        e=self.e;predicate=e.simp(predicate)
        if e.z3.is_true(predicate):return
        self.premises.append(predicate)
        self.records.append(dict(side=self.side,pc=hex(self.pc),head=self.head,low=self.low,entry_esp=self.base.sexpr(),source=description,predicate=predicate.sexpr(),status='assumed'))
        self.instances.append((self.side,hex(self.pc),self.low,0,description,'entry-separation'))
    def consult(self):
        self.checker.contracts.h1.update(self.instances)
        records=getattr(self.checker.contracts,'entry_separation',{});self.checker.contracts.entry_separation=records
        for record in self.records:records[str(record)]=record
    def prepare(self,st):
        info=self.info
        self.assume(self.e.z3.And(self.e.z3.UGE(self.base,self.e.bv(0x10000-self.low)),self.e.z3.ULT(self.base,self.e.bv(0x80000000))),'user-mode stack range')
        if 'origins' not in info:info['origins']=origins(self.checker,info)
        for r,origin in sorted(info['origins'].get(self.head,({},{}))[0].items()):
            self.assume(outside(st.regs[r],self.base,self.low),'incoming '+origin+' via '+r)
        for off,origin in sorted(info['origins'].get(self.head,({},{}))[1].items()):
            if off>=4:self.assume(outside(st.load(self.base+self.e.bv(off),4),self.base,self.low),origin)
        st.ownership=self
    def copy(self):
        other=Ownership(self.checker,self.info,self.base,self.head)
        other.premises=list(self.premises);other.records=list(self.records);other.instances=list(self.instances);other.loaded=list(self.loaded);other.obligations=list(self.obligations);other.pc=self.pc;other.pushes=list(self.pushes)
        return other
    def load(self,st,addr,size,value):
        if size==4:
            e=self.e
            public=e.z3.And([outside(addr+e.bv(k),self.base,self.low) for k in range(4)])
            self.assume(e.z3.Implies(public,outside(value,self.base,self.low)),'public-loaded address word')
    def address(self,value):
        pass  # H1 is admitted when the word is loaded, before any use.
    def derived(self,value):
        e=self.e;todo=[value];seen=set()
        while todo:
            node=todo.pop()
            if node.get_id() in seen:continue
            seen.add(node.get_id())
            if e.z3.eq(node,self.base):return True
            if not e.z3.is_select(node):todo.extend(node.children()[1:] if e.z3.is_app_of(node,e.z3.Z3_OP_ITE) else node.children())
        return False
    def guard(self,st):
        return self.e.conjunction([getattr(st,'path',self.e.z3.BoolVal(True)),*self.premises])
    def safe(self,st,value):
        e=self.e;goal=outside(value,self.base,self.low)
        if e.prove([e.z3.Implies(getattr(st,'path',e.z3.BoolVal(True)),goal)]):return True
        self.consult()
        return e.prove([e.z3.Implies(self.guard(st),goal)])
    def store(self,st,addr,value):
        e=self.e
        # Private temporary copies are checked at the public boundary, not hidden
        # as a consequence of the expression that happened to produce them.
        private=e.z3.And([e.z3.Not(outside(addr+e.bv(k),self.base,self.low)) for k in range(value.size()//8)])
        size=value.size()//8
        words=[e.z3.Concat([e.z3.Extract((off+j)*8+7,(off+j)*8,value) if 0<=off+j<size else st.load(addr+e.bv(off+j),1) for j in reversed(range(4))]) for off in range(-3,size)]
        safe=e.z3.And([outside(word,self.base,self.low) for word in words])
        if getattr(self,'kind','')=='push' and not e.z3.is_true(e.simp(private)):self.pushes.append((len(self.obligations),value))
        self.obligations.append((self.pc,'stored word',e.z3.Implies(self.guard(st),e.z3.Or(private,safe))))
    def result(self,st):
        if self.low:self.consult()  # The derivation fallback is conditional on entry separation.
        for r in ('eax','edx'):self.obligations.append((self.pc,'returned '+r,self.e.z3.Implies(self.guard(st),self.e.z3.Or(outside(st.regs[r],self.base,self.low),self.e.z3.BoolVal(not self.derived(st.regs[r]))))))
    def passed(self,st,values,allowed,register_count=0):
        e=self.e
        if self.low and register_count:self.consult()
        for index,value in self.pushes:
            covered=e.z3.Or([value==self.base+e.bv(k) for k in sorted(allowed)])
            self.obligations[index]=(self.obligations[index][0],'pushed word',e.z3.Implies(self.guard(st),e.z3.Or(outside(value,self.base,self.low),covered)))
        self.pushes=[]
        for index,value in enumerate(values):
            covered=e.z3.Or([value==self.base+e.bv(k) for k in sorted(allowed)])
            self.obligations.append((self.pc,'passed word',e.z3.Implies(self.guard(st),e.z3.Or(outside(value,self.base,self.low),covered,e.z3.BoolVal(index<register_count and not self.derived(value))))))
    def goals(self,st):
        e=self.e
        if any(not e.z3.is_true(e.simp(goal)) for _,_,goal in self.obligations):self.consult()
        return [goal for _,_,goal in self.obligations]


def premise(states):
    e=model()
    return e.conjunction([p for st in states for p in getattr(getattr(st,'ownership',None),'premises',[])])


def guarded(states,goals):
    e=model()
    if e.prove(goals):return goals
    for st in states:
        if hasattr(st,'ownership'):st.ownership.consult()
    obligations=[g for st in states if hasattr(st,'ownership') for g in st.ownership.goals(st)]
    return obligations+[e.z3.Implies(premise(states),e.conjunction(goals))]


def clone_ownership(source,dest):
    if hasattr(source,'ownership'):dest.ownership=source.ownership.copy()
    if hasattr(source,'path'):dest.path=source.path
