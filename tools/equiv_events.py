"""Ordered public accesses; H8 permits only exact repeated-load elimination."""
from equiv_garbage import model
from itertools import zip_longest


def record(st, kind, address, width, value, fs=False, raw_address=None):
    if not getattr(st, 'record_access', False): return
    e = model(); owner = getattr(st, 'ownership', None)
    tag = kind + ('-fs' if fs else '')
    witness = dict(pc=hex(st.access_ins.address), instruction=st.access_ins.mnemonic+' '+st.access_ins.op_str,
                   kind=tag, address=e.simp(address).sexpr(), width=width)
    if owner is not None:
        addresses=owner.checker.inp.addresses
        concrete=e.simp(address)
        raw=raw_address
        if raw is None and e.z3.is_bv_value(concrete):
            raw=concrete.as_long()
        if kind=='read' and not fs and raw is not None:
            if (width==4 and raw in addresses.pointer_cells[owner.side]) or any(
                    start<=raw and raw+width<=start+size
                    for start,size in addresses.immutable_data[owner.side].items()):return
        if not fs:
            offset=e.simp(address-owner.base);current=e.simp(st.regs['esp']-owner.base)
            if e.z3.is_bv_value(offset) and e.z3.is_bv_value(current):
                signed=lambda n:n.as_long() if n.as_long()<2**31 else n.as_long()-2**32
                off,low=signed(offset),signed(current)
                if max(low,owner.lowest)<=off and off+width<=0:
                    st.private_indices=getattr(st,'private_indices',set());st.private_indices.add(len(st.events))
    st.access_pcs=getattr(st,'access_pcs',{})
    st.access_pcs[len(st.events)]=dict(**witness,value=e.simp(value).sexpr())
    event=(tag,e.simp(address),e.bv(width),value)
    st.events.append(event+(st.memory,st.fs) if owner is not None and getattr(owner.checker,'full_events',False) and kind=='write' and len(st.events) not in getattr(st,'private_indices',()) else event)



def paired(states):
    e = model(); sequences = [st.events for st in states]
    for st in states:
        owner=getattr(st,'ownership',None)
        if owner is None or getattr(owner.checker,'full_events',False):continue
        pending=[(pc,kind,g) for pc,kind,g in owner.obligations if not e.z3.is_true(e.simp(g))] if getattr(owner,'lowest',0) else []
        if pending:
            solver=e.z3.Solver();solver.add(e.z3.Not(e.conjunction([g for _,_,g in pending])));answer=e.limits.check(solver,'prove')
            if answer!=e.z3.unsat:
                m=solver.model() if answer==e.z3.sat else None
                pc,kind,g=next((x for x in pending if m is not None and e.z3.is_false(m.eval(x[2],model_completion=True))),pending[0])
                ins=next(i for i in owner.info['code'] if i.address==pc)
                owner.checker.ownership_failure=dict(side=owner.side,pc=hex(pc),kind=kind,instruction=ins.mnemonic+' '+ins.op_str,goal=g.sexpr(),model={d.name():str(m[d]) for d in sorted(m.decls(),key=lambda d:d.name())} if m is not None else None,result=str(answer))
                raise e.NotProven('H2 private-event ownership unestablished at '+hex(pc)+' ('+kind+')')
    if not any(getattr(getattr(st,'ownership',None),'checker',None) and getattr(st.ownership.checker,'full_events',False) for st in states):
        sequences=[[event for i,event in enumerate(st.events) if i not in getattr(st,'private_indices',())] for st in states]
    def identical(a, b):
        return len(a) == len(b) and all(x[0] == y[0] and len(x) == len(y)
            and (not x[0].startswith('read') or all(e.equal(u,v) for u,v in zip(x[1:],y[1:]))) for x,y in zip(a,b))
    filtered = []; removed = []
    for side, st in enumerate(states):
        out = []; seen = {};kept={id(event) for event in sequences[side]}
        for index, event in enumerate(st.events):
            if id(event) not in kept:continue
            if event[0] in ('read','read-fs'):
                key = (event[0], e.simp(event[1]).sexpr(), event[2].as_long())
                if key in seen and e.equal(event[3],seen[key]):
                    removed.append((getattr(getattr(st,'ownership',None),'side',side), index, st.access_pcs.get(index, {})))
                    continue
                seen[key] = event[3]
            else: seen.clear()  # Writes and all existing boundary/fault events.
            out.append(event)
        filtered.append(out)
    if removed and identical(*sequences): return sequences
    # Do not assume H8 when eliminating reads cannot even align event kinds.
    if removed and [x[0] for x in filtered[0]] == [x[0] for x in filtered[1]]:
        owners = [getattr(st,'ownership',None) for st in states]
        for owner in owners:
            if owner is not None:
                records = getattr(owner.checker,'h8_reads',{})
                owner.checker.h8_reads = records
                for side, index, witness in removed:
                    records[repr((side,index,witness))] = dict(side=side, event=index, **witness)
        return filtered
    if [x[0] for x in sequences[0]] != [x[0] for x in sequences[1]]:
        index=next(i for i,(x,y) in enumerate(zip_longest(*sequences)) if x is None or y is None or x[0]!=y[0])
        witnesses=[getattr(st,'access_pcs',{}).get(next((k for k,event in enumerate(st.events) if index<len(seq) and event is seq[index]),-1),dict(kind=seq[index][0] if index<len(seq) else 'end')) for st,seq in zip(states,sequences)]
        for st in states:
            owner = getattr(st,'ownership',None)
            if owner is not None:
                owner.checker.access_failure = dict(event=index, sides=[getattr(getattr(s,'ownership',None),'side',None) for s in states], witnesses=witnesses, traces=[list(getattr(s,'access_pcs',{}).values()) for s in states])
    return sequences
