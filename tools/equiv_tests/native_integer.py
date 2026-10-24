from .support import *
import ctypes, random, sys, struct
if sys.platform != "win32" or struct.calcsize("P") != 8:
    raise RuntimeError("Native fixture requires Windows x64")
k=ctypes.WinDLL('kernel32',use_last_error=True)
k.VirtualAlloc.argtypes=(ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong,ctypes.c_ulong);k.VirtualAlloc.restype=ctypes.c_void_p
k.VirtualFree.argtypes=(ctypes.c_void_p,ctypes.c_size_t,ctypes.c_ulong)
flags={'cf':0,'pf':2,'af':4,'zf':6,'sf':7,'of':11,'df':10}
randomizer=random.Random(0xA57A)
operations={
'add8':'00d0','adc8':'10d0','sub8':'28d0','sbb8':'18d0','inc8':'fec0','dec8':'fec8','neg8':'f6d8',
'add16':'6601d0','adc16':'6611d0','sub16':'6629d0','sbb16':'6619d0',
'add32':'01d0','adc32':'11d0','sub32':'29d0','sbb32':'19d0',
'shl8':'d2e0','shr8':'d2e8','sar8':'d2f8','shl16':'66d3e0','shr16':'66d3e8','sar16':'66d3f8','shl32':'d3e0','shr32':'d3e8','sar32':'d3f8',
'movsx8':'0fbec2','movzx8':'0fb6c2','movsx16':'0fbfc2','movzx16':'0fb7c2','movah':'88d4','movax':'6689d0','imul32':'0fafc2','mul32':'f7e2','imul_full32':'f7ea',
'bt32':'0fa3d0','bts32':'0fabd0','btr32':'0fb3d0','btc32':'0fbbd0'}
checker,_=build('c3','c3')
machine=e.Machine(checker.inp.addresses,0,[{},{}]); count=0
for name,h in operations.items():
    op=bytes.fromhex(h); shift=name.startswith(('shl','shr','sar'))
    # Native Windows x64 ABI; operation itself is on 32/16/8-bit operands.
    # EAX=a, EDX=b, ECX=b for shifts; flags set from R8, output buffer in R9.
    code=bytes.fromhex('89c8 89d1 4150 9d')+op+bytes.fromhex('418901 41895104 9c 58 41894108 c3')
    ptr=k.VirtualAlloc(None,len(code),0x3000,0x40)
    if not ptr:raise ctypes.WinError(ctypes.get_last_error())
    ctypes.memmove(ptr,code,len(code))
    fn=ctypes.CFUNCTYPE(None,ctypes.c_uint32,ctypes.c_uint32,ctypes.c_uint32,ctypes.POINTER(ctypes.c_uint32))(ptr)
    ins=e.decode(Image(op),0x401000,len(op))[0]
    vals=[0,1,0x7f,0x80,0xff,0x7fff,0x8000,0xffff,0x7fffffff,0x80000000,0xffffffff]
    pairs=[(a,b) for a in vals for b in (range(34) if shift else vals)]
    pairs +=[(randomizer.getrandbits(32),randomizer.getrandbits(32)) for _ in range(60)]
    for a,b in pairs:
        bits=randomizer.getrandbits(12)&0x8d5 | 2
        out=(ctypes.c_uint32*3)();fn(a,b,bits,out)
        st=e.State({r:e.bv(a if r=='eax' else b if r in ('edx','ecx') else 0) for r in e.REGS},{f:e.z3.BoolVal(bool(bits>>i&1)) for f,i in flags.items()},e.z3.Array('m',e.BV32,e.BYTE),e.bv(0),e.bv(0,e.FP_BITS))
        machine.step(st,ins)
        assert e.simp(st.regs['eax']).as_long()==out[0],(name,a,b,'eax',out[0],st.regs['eax'])
        assert e.simp(st.regs['edx']).as_long()==out[1],(name,a,b,'edx',out[1],st.regs['edx'])
        for f,i in flags.items():
            v=e.simp(st.flags[f])
            if e.z3.is_true(v) or e.z3.is_false(v):
                assert e.z3.is_true(v)==bool(out[2]>>i&1),(name,a,b,bits,f,v,out[2])
        count+=1
    k.VirtualFree(ptr,0,0x8000)
print('NATIVE INTEGER CHECKS PASSED',count,'cases',len(operations),'forms')
