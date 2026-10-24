from .support import *
import ctypes, random, sys, struct
if sys.platform != "win32" or struct.calcsize("P") != 8:
    raise RuntimeError("Native fixture requires Windows x64")
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=(ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong);k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualFree.argtypes=(ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong)
checker,_=build('c3','c3')
m=e.Machine(checker.inp.addresses,0,[{},{}]); rng=random.Random(121)
count=normal=0
for signed,op in [(False,bytes.fromhex('f7f1')),(True,bytes.fromhex('f7f9'))]:
    code=bytes.fromhex('89c8 4489c1')+op+bytes.fromhex('418901 41895104 c3')
    ptr=k.VirtualAlloc(None,len(code),0x3000,0x40);ctypes.memmove(ptr,code,len(code))
    f=ctypes.CFUNCTYPE(None,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_uint32,ctypes.POINTER(ctypes.c_uint32))(ptr)
    ins=e.decode(Image(op),0x401000,len(op))[0]
    vals=[0,1,2,0x7fffffff,0x80000000,0xffffffff]
    cases=[(a,d,v) for a in vals for d in vals for v in vals]+[(rng.getrandbits(32),rng.getrandbits(32),rng.getrandbits(32)) for _ in range(250)]
    for a,d,v in cases:
        dividend=(d<<32)|a; divisor=v
        if signed:
            if dividend>>63:dividend-=1<<64
            if divisor>>31:divisor-=1<<32
        if divisor:
            q=(abs(dividend)//abs(divisor))*(-1 if (dividend<0)!=(divisor<0) else 1)
            fault=not (-(1<<31)<=q<(1<<31) if signed else 0<=q<(1<<32))
        else:fault=True
        st=e.State({r:e.bv(a if r=='eax' else d if r=='edx' else v if r=='ecx' else 0) for r in e.REGS},{f:e.z3.BoolVal(False) for f in e.FLAGS},e.z3.Array('m',e.BV32,e.BYTE),e.bv(0),e.bv(0,e.FP_BITS))
        m.step(st,ins)
        assert e.z3.is_true(e.simp(st.events[0][1]))==fault,(signed,a,d,v,'fault')
        if not fault:
            out=(ctypes.c_uint32*2)();f(a,d,v,out)
            assert out[0]==e.simp(st.regs['eax']).as_long() and out[1]==e.simp(st.regs['edx']).as_long(),(signed,a,d,v,list(out))
            normal+=1
        count+=1
    k.VirtualFree(ptr,0,0x8000)
print('DIVISION CHECKS PASSED',count,'fault predicates;',normal,'native normal executions')
