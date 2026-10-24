"""H6 bounded faults: pre-access state, ownership projection, explicit FP faults."""
from equiv_garbage import model


CONTRACT = dict(
    validity='valid(linear address,width,kind); FS kind includes selector/descriptor context; stable between boundaries',
    private_domain='owned stack access validity is an explicit H6 premise; validated constants are H5',
    observations='first fault kind, access information, pre-fault public memory/FS/FP',
    exclusions='page permissions, stack exhaustion, partial progress, raw exception registers',
    fp='uninterpreted operation and pending-exception predicates on modeled FP state')


def remember(st, index, predicate, before=None):
    owner=getattr(st,'ownership',None)
    if owner is not None:owner.checker.fault_emitted=True
    st.faults = getattr(st, 'faults', {})
    st.faults[index] = (predicate, *(before or (st.memory, st.fs, st.fp)))


def access(st, tag, address, width, before=None):
    e=model()
    args=[address,e.bv(width)]+([st.fs] if tag.endswith('-fs') else [])
    valid=e.z3.Function('H6_valid_'+tag,*[v.sort() for v in args],e.z3.BoolSort())
    private=len(st.events) in getattr(st,'private_indices',())
    if private:
        owner=st.ownership;checker=owner.checker
        instances=getattr(checker,'fault_private',{});checker.fault_private=instances
        key=(owner.side,st.access_ins.address,tag,width,e.simp(address).sexpr(),owner.base.sexpr(),owner.lowest)
        instances[key]=dict(side=owner.side,pc=hex(st.access_ins.address),kind=tag,
            width=width,address=e.simp(address).sexpr(),low=owner.lowest,
            entry_esp=owner.base.sexpr(),predicate=valid(*args).sexpr())
    predicate=e.z3.BoolVal(False) if private else e.z3.Not(valid(*args))
    remember(st, len(st.events), predicate, before)


def explicit(st, kind, predicate):
    """The event retains its kind; snapshot comparison is conditional on fault."""
    index=len(st.events)
    st.events.append((kind,predicate))
    remember(st,index,predicate)
    ins=st.access_ins
    st.access_pcs=getattr(st,'access_pcs',{})
    st.access_pcs[index]=dict(pc=hex(ins.address),instruction=ins.mnemonic+' '+ins.op_str,kind=kind)


def pending(st):
    e=model()
    explicit(st,'fp-pending-exception',e.z3.Function('H6_fp_pending',
        e.z3.BitVecSort(e.FP_BITS),e.z3.BoolSort())(st.fp))


def operation(st, key, args):
    e=model()
    explicit(st,'fp-operation-exception:'+key,e.z3.Function('H6_fp_fault_'+key,
        *[v.sort() for v in args],e.z3.BoolSort())(*args))


def finish(states, sequences):
    """Decorate after private hiding/H8, preserving their original access keys."""
    e=model();result=[]
    for st,seq in zip(states,sequences):
        out=[];st.fault_event_indices={};indices={id(v):i for i,v in enumerate(st.events)}
        projected={}
        owner=getattr(st,'ownership',None)
        for event in seq:
            index=indices[id(event)];fault=getattr(st,'faults',{}).get(index)
            if fault is not None:
                predicate,memory,fs,fp=fault
                if owner is not None and not getattr(owner.checker,'full_events',False):
                    # Each side's extent only; never hide the union of both frames.
                    key=memory.get_id()
                    if key not in projected:
                        public=e.z3.Array('memory',e.BV32,e.BYTE)
                        for off in range(owner.lowest,0):
                            address=owner.base+e.bv(off)
                            memory=e.z3.Store(memory,address,e.z3.Select(public,address))
                        projected[key]=e.simp(memory)
                    memory=projected[key]
                zero=e.z3.K(e.BV32,e.bv(0,8))
                event=(*event,predicate,e.z3.If(predicate,e.simp(memory),zero),
                       e.z3.If(predicate,fs,e.bv(0,fs.size())),e.z3.If(predicate,fp,e.bv(0,e.FP_BITS)))
            st.fault_event_indices[id(event)]=index
            out.append(event)
        result.append(out)
    return result
