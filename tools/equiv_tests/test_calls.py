"""Step 4: input completeness, ABI restoration and visible assumptions."""
import unittest
import equiv as e
from .support import build,call,p32
class Calls(unittest.TestCase):
    def caller(self,a,b,helper,target=0x401100,other=(),post='5bc3'):
        aa,bb = bytes.fromhex(a),bytes.fromhex(b)
        post = bytes.fromhex(post)
        code_a = b'\x53'+aa+call(1+len(aa),target)+post
        code_b = b'\x53'+bb+call(1+len(bb),target)+post
        extra = [(target-0x400000,bytes.fromhex(helper))]+list(other)
        return build(code_a,code_b,extras_a=extra,extras_b=extra,bindings=[(target,target)])
    def test_full_inputs_and_summary_controls(self):
        for helper,a,b in [('89d8c3','bb01000000','bb02000000'),
                           ('b80000000083d000c3','f8','f9'),
                           ('b001c3','b800010000','b800020000')]:
            checker,fn = self.caller(a,b,helper); self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))
    def test_def_before_use_can_omit_dead_ebx_and_carry_inputs(self):
        helper = 'b800000000ba00000000b90000000039c0c3'
        checker,fn = self.caller('bb01000000f8','bb02000000f9',helper); self.assertEqual('PROVEN under H1,H3',checker.check(fn)[0])
        contracts = checker.last_contracts['hypotheses']['H3']; self.assertTrue(all(c['mode']=='two-callee-def-before-use' for c in contracts)); self.assertNotIn(['r','ebx',0],contracts[0]['inputs']); self.assertNotIn(['f','cf'],contracts[0]['inputs'])
    def test_forwarding_thunk_records_dependency(self):
        thunk = (b'\xe9'+p32(0x401180-0x401105)).hex()
        checker,fn = self.caller('','',thunk,other=[(0x1180,bytes.fromhex('b801000000c3'))]); self.assertEqual('PROVEN under H1,H3',checker.check(fn)[0]); self.assertTrue(checker.last_contracts['dependencies'])
    def test_save_restore_pairs_are_not_inputs_but_save_slot_loads_are(self):
        for helper,expected in [('53b800000000ba00000000b90000000039c05bc3',True),
                                ('538b04245bc3',False),('5389d85bc3',False)]:
            checker,fn = self.caller('bb01000000','bb02000000',helper)
            status,_ = checker.check(fn); self.assertEqual(status.startswith('PROVEN'),expected)
            if expected: self.assertNotIn(['r','ebx',0],checker.last_contracts['hypotheses']['H3'][0]['inputs'])
    def test_unknown_indirect_uses_explicit_H3c_and_concrete_R2_cleanup(self):
        checker,fn = build('ff10c3','ff10c3'); self.assertEqual('PROVEN under H3c',checker.check(fn)[0])
        c = checker.last_contracts['hypotheses']['H3c'][0]; self.assertEqual('H3c-register-convention',c['mode']); self.assertNotIn(['r','ebx',0],c['inputs']); self.assertNotIn(['f','cf'],c['inputs']); self.assertEqual(0,c['cleanup']); self.assertEqual('R2',c['cleanup_rule']); self.assertEqual('0',c['cleanup_symbol'])
    def test_restore_and_df_are_individual_obligations_on_all_routes(self):
        for a,b in [('bb01000000c3','bb01000000c3'),('fdc3','fdc3'),
                    ('53bb010000005bc3','53bb01000000c3')]:
            checker,fn = build(a,b); self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))
            aa,bb = checker.instructions(fn)
            for route in (lambda:e.verify_frames(checker,aa,bb),lambda:checker.acyclic(aa,bb),
                          lambda:checker.houdini(aa,bb,[e.blocks(aa),e.blocks(bb)],[e.live_locations(aa,e.blocks(aa)),e.live_locations(bb,e.blocks(bb))],(0,0),e.DIAG,e.FLAGS)):
                checker.contracts = None
                with self.assertRaises((e.NotProven,e.Unsupported)): route()
        checker,fn = build('53bb010000005bc3','53bb010000005bc3'); self.assertEqual('PROVEN under H1',checker.check(fn)[0])
    def test_cfg_join_and_partial_read_cannot_omit_input(self):
        helper = '85c97405b80000000083d000c3'  # One path leaves EAX undefined; ADC reads CF.
        checker,fn = self.caller('b801000000f8','b802000000f9',helper); self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))
    def test_nested_known_callee_no_longer_needs_H3c(self):
        helper = (b'\xe8'+p32(0x401180-0x401105)+b'\xc3').hex()
        checker,fn = self.caller('','',helper,other=[(0x1180,b'\xc3')])
        status,_ = checker.check(fn); self.assertEqual('PROVEN under H1,H3',status); self.assertTrue(all(c['mode']=='two-callee-def-before-use' for c in checker.last_contracts['hypotheses']['H3']))
    def test_callee_ABI_failure_is_fallback_not_caller_restore_failure(self):
        checker,fn = self.caller('','','bb01000000c3'); self.assertEqual('PROVEN under H1,H3c',checker.check(fn)[0])
    def test_unknown_store_records_H1_without_erasing_save_slot(self):
        for body,status in [('5389105bc3','PROVEN under H1'),('538910ff105bc3','PROVEN under H1,H3c')]:
            checker,fn = build(body,body); self.assertEqual(status,checker.check(fn)[0]); self.assertTrue(checker.last_contracts['hypotheses']['H1']['instances'])
    def test_R2_cleanup_with_outgoing_argument_and_push_ecx_frame(self):
        for body,expected in [('53906a01ff105bc3',4),('5351ff10595bc3',0)]:
            checker,fn = build(body,body); self.assertEqual('PROVEN under H1,H3c',checker.check(fn)[0])
            c = checker.last_contracts['hypotheses']['H3c'][0]; self.assertEqual(expected,c['cleanup']); self.assertEqual(expected,c['assumed_cleanup_bytes']); self.assertNotIn('H3_restoration',c)
    def test_BookWinUpdate_allocation_and_known_then_unknown_cleanup(self):
        from equiv_calls import CallContracts
        prefix = bytes.fromhex('53565783c4f06a006a00')
        body = prefix+call(len(prefix),0x401100)+bytes.fromhex('85c07402ff1683c4105f5e5bc3')
        checker,fn = build(body,body,extras_a=[(0x1100,bytes.fromhex('c20800'))],extras_b=[(0x1100,bytes.fromhex('c20800'))],bindings=[(0x401100,0x401100)])
        cc = CallContracts(checker); cc.abi(checker.instructions(fn)[0],0)
        indirect = [c for _,_,c in cc.sites.values() if c['kind']=='indirect']
        self.assertFalse(cc.h1); self.assertEqual([-36,0],indirect[0]['caller_private_range_relative_to_entry_ESP']); self.assertEqual(0,indirect[0]['cleanup']); self.assertNotIn('H3_restoration',indirect[0])
        self.assertFalse(any(c.get('H3_restoration') for _,_,c in cc.sites.values() if c['kind']=='direct'))
    def test_Select_keeps_temporary_below_floor_across_R1_RET_zero_call(self):
        from equiv_calls import CallContracts
        prefix = bytes.fromhex('5356576a00'); body = prefix+call(len(prefix),0x401100)+bytes.fromhex('595f5e5bc3')
        checker,fn = build(body,body,extras_a=[(0x1100,bytes.fromhex('c3'))],extras_b=[(0x1100,bytes.fromhex('c3'))],bindings=[(0x401100,0x401100)])
        cc = CallContracts(checker); cc.abi(checker.instructions(fn)[0],0)
        record = next(iter(cc.sites.values()))[2]
        self.assertFalse(cc.h1); self.assertEqual([-16,0],record['caller_private_range_relative_to_entry_ESP']); self.assertEqual(0,record['cleanup']); self.assertNotIn('H3_restoration',record)
    def test_Select_indirect_temporary_uses_zero_cleanup(self):
        from equiv_calls import CallContracts
        checker,fn = build('5356576a00ff16595f5e5bc3','5356576a00ff16595f5e5bc3'); cc = CallContracts(checker)
        cc.abi(checker.instructions(fn)[0],0)
        self.assertEqual(0,next(iter(cc.sites.values()))[1])
    def test_real_off_by_four_is_not_hidden_by_unknown_cleanup(self):
        from equiv_calls import CallContracts
        for body in ('53565783c4f0ff1683c4145f5e5bc3','5383c40483c404c3'):
            checker,fn = build(body,body)
            with self.assertRaises(e.NotProven): CallContracts(checker).abi(checker.instructions(fn)[0],0)
    def test_known_return_address_observer_cannot_assume_context_independence(self):
        checker,fn = self.caller('','','8b0424c3'); self.assertEqual('NOT PROVEN',checker.check(fn)[0])
    def test_R1_agrees_on_own_RET_even_without_input_summary(self):
        checker,fn = self.caller('','','c20000'); checker.inp.new.data[0x1100:0x1103] = bytes.fromhex('c20400')
        self.assertEqual('UNSUPPORTED',checker.check(fn)[0])
        checker,fn = self.caller('','','ffe0'); self.assertEqual('UNSUPPORTED',checker.check(fn)[0])
    def test_R1_own_RET_reader_keeps_strict_cleanup_cache_separate(self):
        checker,fn = self.caller('','','53ff105bc20800')
        self.assertIsNone(e.callee_cleanup(checker,0,0x401100))
        self.assertEqual(8,e.callee_cleanup(checker,0,0x401100,own_ret_only=True))
        self.assertIsNone(e.callee_cleanup(checker,0,0x401100))
    def test_R2_unreadable_direct_callee_and_negative_count(self):
        body = call(0,0x500000)+bytes.fromhex('c3')
        checker,fn = build(body,body,bindings=[(0x500000,0x500000)]); self.assertEqual('PROVEN under H3c',checker.check(fn)[0])
        self.assertEqual('R2',checker.last_contracts['hypotheses']['H3c'][0]['cleanup_rule'])
        checker,fn = build('535159ff105bc3','535159ff105bc3'); self.assertEqual('PROVEN under H1,H3c',checker.check(fn)[0])
        c = checker.last_contracts['hypotheses']['H3c'][0]
        self.assertEqual(-4,c['raw_floor_minus_ESP']); self.assertEqual(0,c['assumed_cleanup_bytes'])
    def test_known_nonexecutable_target_cannot_receive_an_assumed_contract(self):
        checker,fn = self.caller('','','c3',target=0x402000); self.assertEqual('UNSUPPORTED',checker.check(fn)[0])
    def test_unmodeled_assembly_input_does_not_hide_behind_full_gpr_inputs(self):
        checker,fn = self.caller('','','660f7ec0c3'); self.assertEqual('UNSUPPORTED',checker.check(fn)[0])  # MOVD EAX,XMM0.

    def test_passed_through_flag_live_after_call_remains_input(self):
        checker,fn = self.caller('f8','f9','b800000000ba00000000b900000000c3',post='83d0005bc3')
        self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))
        self.assertIn(['f','cf'],next(iter(checker.contracts.sites.values()))[2]['inputs'])
    def test_callee_undefined_AF_is_definition_under_H3(self):
        checker,fn = self.caller('31c0','29c0','31c0ba00000000b900000000c3')
        self.assertEqual('PROVEN under H1,H3',checker.check(fn)[0])
        c = checker.last_contracts['hypotheses']['H3'][0]
        self.assertNotIn(['f','af'],c['inputs'])
        self.assertIn('flags the callee leaves undefined are not observed',c['H3'])

    def test_REP_known_stack_range_and_unknown_ownership(self):
        from equiv_calls import CallContracts
        for body,expected_h1 in [('53578d7c24f8b901000000f3ab5f5bc3',False),
                                  ('53578d3c24b900000000f3ab5f5bc3',False),
                                  ('5357b901000000f3ab5f5bc3',True)]:
            checker,fn = build(body,body);cc=CallContracts(checker)
            cc.abi(checker.instructions(fn)[0],0)
            self.assertEqual(expected_h1,bool(cc.h1))
        body='53578d3c24b901000000f3ab5f5bc3'
        checker,fn=build(body,body)
        with self.assertRaises(e.NotProven):CallContracts(checker).abi(checker.instructions(fn)[0],0)

    def test_REP_callee_is_H3c_not_unmodeled_default_ES(self):
        checker,fn = self.caller('','','57b901000000f3aa5fc3')
        self.assertEqual('PROVEN under H1,H3c',checker.check(fn)[0])
