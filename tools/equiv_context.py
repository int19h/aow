"""Unified FS.base/linear storage and explicit x87 environment fields."""
from equiv_garbage import model

CORE_BITS=704
FP_BITS=CORE_BITS+80  # IP32, opcode16, data pointer32, arithmetic/control/tag core.
FS_BITS=96  # Base32 plus opaque selector/limit/type/permission context64.
SEGMENT=dict(status='discharged',memory='one linear byte array; FS:[offset] = memory[FS.base+offset]',
             entry='shared symbolic FS context (base32 plus selector/descriptor64); H3 calls may replace it; flat ordinary segments',
             unsupported='other segment overrides and writes to segment registers')
FP=dict(core='opaque 8x80 stack plus 64 control/status/tag bits',
        environment='explicit IP32, opcode16, data pointer32; full state at boundaries/faults',
        flat_data_context='shared symbolic constant for the flat ordinary-segment ABI',
        ip_identity='existing independent/local-CFG bindings only; otherwise literal PC',
        unsupported='FNSTENV/FSTENV/FNSAVE/FSAVE/FLDENV/FRSTOR and unmodeled forms')


def linear(st,address,fs):
    e=model()
    return e.simp(e.z3.Extract(31,0,st.fs)+address) if fs else address


def update(machine,st,ins,key,args,addresses):
    e=model();m=ins.mnemonic
    if m in ('fnstcw','fnstsw'):return  # No architectural x87 state change.
    core=e.z3.Function('x87_step_'+key,*[v.sort() for v in args],e.z3.BitVecSort(CORE_BITS))(*args)
    if m=='fldcw':
        st.fp=e.z3.Concat(e.z3.Extract(FP_BITS-1,CORE_BITS,st.fp),core)
        return
    known=machine.addresses.forward if machine.side==0 else machine.addresses.reverse
    ip=machine.constant(ins.address) if ins.address in known else e.bv(ins.address)
    data=addresses[-1] if addresses else e.z3.Extract(CORE_BITS+31,CORE_BITS,st.fp)
    raw=bytes(ins.raw.bytes);start=next(n for n,v in enumerate(raw) if 0xd8<=v<=0xdf)
    opcode=((raw[start] & 7)<<8)|raw[start+1]
    st.fp=e.z3.Concat(ip,e.bv(opcode,16),data,core)
    if addresses and hasattr(st,'ownership'):st.ownership.fdp_source=(ins.address,m+' '+ins.op_str)


def boundary(st):
    from equiv_ownership import outside
    owner=getattr(st,'ownership',None)
    if owner is None or not owner.lowest or getattr(owner.checker,'full_events',False):return
    e=model();fdp=e.simp(e.z3.Extract(CORE_BITS+31,CORE_BITS,st.fp))
    if not owner.derived(fdp):return  # Incoming/call-result FDP, as for H2 register words.
    goal=e.z3.Implies(owner.guard(st),outside(fdp,owner.base,owner.lowest))
    if e.prove([goal]):return
    owner.consult()
    pc,instruction=getattr(owner,'fdp_source',(owner.pc,'FDP boundary value'))
    owner.checker.contracts.h9[owner.side,pc,owner.pc]=dict(side=owner.side,pc=hex(pc),
        instruction=instruction,boundary_pc=hex(owner.pc),kind='private-frame-observation',
        low=owner.lowest,entry_esp=owner.base.sexpr(),fdp=fdp.sexpr(),obligation=goal.sexpr(),status='assumed',
        predicate='Callers, callees and handlers do not dereference this derived x87 FDP into hidden private bytes [ESP_entry+low,ESP_entry). Pointer values remain observable.')
