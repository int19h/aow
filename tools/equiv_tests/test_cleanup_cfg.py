"""4c: bounded RET discovery and narrowly recognized R2 exclusions."""
import unittest
import equiv as e
from types import SimpleNamespace as NS
from equiv_calls import CallContracts
from .support import build,p32
from .synthetic import Assembler,finally_program
class CleanupCFG(unittest.TestCase):
    def test_distant_direct_tail_and_inconsistent_returns(self):
        c,f=build('c3','c3',extras_a=[(0x1100,b'\xe9'+p32(0x403200-0x401105)),(0x3200,b'\xc3')])
        self.assertEqual((0,True),CallContracts(c).cleanup(0,0x401100))
        for helper in ('85c07401c3c20400','ffe0','e201c3c20400','cb90c3','e9fbef0f00','64a100000000c3','648f0500000000c3'):
            c,f=build('c3','c3',extras_a=[(0x1100,bytes.fromhex(helper))])
            self.assertEqual((None,True),CallContracts(c).cleanup(0,0x401100))
        c,f=build('c3','c3',extras_a=[(0x1100,bytes.fromhex('648f050000000083c40cc3'))])
        self.assertEqual(0,CallContracts(c).cleanup(0,0x401100)[0])
    def test_finally_ret_is_not_the_function_ret_and_handler_is_not_a_root(self):
        body,rel=finally_program();body=body.replace(bytes.fromhex('31d2c9c3'),bytes.fromhex('31d2c9c20400'))
        c,f=build(body,body,names=[(0x401300,'System.@HandleFinally')])
        self.assertEqual(4,CallContracts(c).cleanup(0,0x401000)[0])
    def test_EH_optional_call_and_continuation(self):
        p=Assembler();p.put(bytes.fromhex('5589e531c055'));p.reference(b'\x68','descriptor')
        p.put(bytes.fromhex('64ff3064892085c0'));p.reference(bytes.fromhex('0f84'),'skip',True)
        p.put(bytes.fromhex('ff16'));p.label('skip');p.put(bytes.fromhex('5a595964891500000000'))
        p.reference(b'\x68','done');p.label('cleanup');p.put(bytes.fromhex('ff16c3'))
        p.label('descriptor');p.put(b'\xe9'+p32(0x401300-(0x401000+p.size+5)));p.reference(b'\xe9','cleanup',True)
        p.label('done');p.put(bytes.fromhex('c9c3'));body=p.finish()
        c,f=build(body,body,names=[(0x401300,'System.@HandleFinally')]);code,_=c.exception_regions(c.instructions(f)[0],0)
        cc=CallContracts(c);cc.abi(code,0)
        self.assertEqual([0,0],[cleanup for _,cleanup,_ in cc.sites.values()])
        self.assertTrue(all('exception records' in r['cleanup_contract'] and 'temporaries' in r['cleanup_contract'] for _,_,r in cc.sites.values()))
    def test_saved_temporary_requires_a_pop_before_the_next_call(self):
        for body,good in [('539050ff16595bc3',True),('539050ff16ff16595bc3',False)]:
            c,f=build(body,body);cc=CallContracts(c)
            if good:
                cc.abi(c.instructions(f)[0],0);self.assertEqual(0,next(iter(cc.sites.values()))[1])
            else:
                with self.assertRaises(e.NotProven):cc.abi(c.instructions(f)[0],0)
    def test_R1_byte_budget(self):
        c,f=build('c3','c3');c.inp.old.data[0x1100:0x2202]=b'\x90'*0x1101+b'\xc3'
        self.assertIsNone(CallContracts(c).cleanup(0,0x401100)[0])
    def test_imported_exception_helper_names_are_image_local(self):
        body,_=finally_program();c,f=build(body,body,names=[(0x401300,'System.@HandleFinally')])
        c.inp.addresses.names[0].pop(0x401300)
        code,regions=c.exception_regions(c.instructions(f)[0],0,c.inp.old,{0x401300:'System.@HandleFinally'})
        self.assertEqual(1,len(regions));self.assertTrue(any(i.flow for i in code))
    def test_imported_callee_can_use_a_named_handler_import_thunk(self):
        body,_=finally_program();c,f=build(body,body);image=c.inp.old
        image.data[0x1300:0x1306]=b'\xff\x25'+p32(0x402100)
        image.pe.DIRECTORY_ENTRY_IMPORT=[NS(dll=b'VCL30.dpl',imports=[NS(address=0x402100,name=b'System.@HandleFinally@12345678')])]
        code,regions=c.exception_regions(c.instructions(f)[0],0,image,{})
        self.assertEqual(1,len(regions));self.assertNotIn(0x401300,c.inp.addresses.names[0])
    def test_constructor_uninstall_ret_discovery_only(self):
        body,_=finally_program();c,f=build(body,body,names=[(0x401300,'System.@HandleFinally')])
        code=c.instructions(f)[0];k=next(k for k,i in enumerate(code) if i.mnemonic=='mov' and 'fs:' in i.op_str)
        # Preserve the installed frame; replace its ordinary uninstall only.
        end=next(j for j in range(k+1,len(code)) if code[j].mnemonic=='mov' and 'fs:' in code[j].op_str)
        a,b=code[end-3].address,code[end].address+code[end].size
        c.inp.old.data[a-0x400000:b-0x400000]=bytes.fromhex('648f050000000083c40c')+b'\x90'*(b-a-10)
        self.assertEqual(0,CallContracts(c).cleanup(0,0x401000)[0])
    def test_different_handler_ret_never_certifies_the_callee(self):
        body,_=finally_program()
        changed=body.replace(bytes.fromhex('31c0c3'),bytes.fromhex('c20400'),1)
        c,f=build(body,changed,names=[(0x401300,'System.@HandleFinally')])
        # Equal-length mutation preserves the descriptor/continuation addresses.
        self.assertEqual(1,len(c.exception_regions(c.instructions(f)[1],1)[1]))
        self.assertEqual((0,True),CallContracts(c).cleanup(1,0x401000))
        # Normal RET discovery is not a proof of the handler's returning ABI.
        status,reason=c.check(f)
        self.assertEqual('UNSUPPORTED',status)
        self.assertIn('exception region requires linked private-entry relation',reason)
