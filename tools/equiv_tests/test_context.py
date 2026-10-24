"""FS aliases ordinary memory; x87 environment addresses remain observable."""
import unittest
import equiv as e
import equiv_context as context
from .support import build


def execute(code,st=None):
    c,f=build(code,code);a,_=c.instructions(f)
    st=st or e.arbitrary(e.DIAG,e.FLAGS)[0]
    machine=e.Machine(c.inp.addresses,0,[{},{}])
    for ins in a:
        if ins.address>=a[0].address+len(bytes.fromhex(code)):break
        machine.step(st,ins)
    return st


class Context(unittest.TestCase):
    def test_public_only_load_names_H6(self):
        c,f=build('8b01c3','8b01c3')
        self.assertEqual('PROVEN under H6',c.check(f)[0])
        self.assertEqual([],c.last_contracts['hypotheses']['H6']['instances'])

    def test_FS_and_linear_accesses_alias_in_both_directions(self):
        st=e.arbitrary(e.DIAG,e.FLAGS)[0];st.fs=e.bv(0x10000)
        st.store(e.bv(0x10000),e.bv(7))
        self.assertTrue(e.equal(st.load(e.bv(0),4,True),e.bv(7)))
        st.store(e.bv(0),e.bv(9),True)
        self.assertTrue(e.equal(st.load(e.bv(0x10000),4),e.bv(9)))

    def test_FS_faults_depend_on_descriptor_not_only_linear_address(self):
        a,b=e.arbitrary(e.DIAG,e.FLAGS)
        for n,st in enumerate((a,b)):st.fs=e.z3.Concat(e.bv(n,64),e.bv(0x10000))
        a,b=execute('64a100000000',a),execute('64a100000000',b)
        self.assertTrue(e.equal(a.events[0][1],b.events[0][1]))
        self.assertFalse(e.prove([a.faults[0][0]==b.faults[0][0]]))

    def test_x87_memory_operation_retains_segment_context(self):
        a,b=e.arbitrary(e.DIAG,e.FLAGS)
        for n,st in enumerate((a,b)):st.fs=e.z3.Concat(e.bv(n,64),e.bv(0x10000))
        a,b=execute('64d90500000000',a),execute('64d90500000000',b)
        self.assertFalse(e.prove([a.fp==b.fp]))

    def test_TIB_alias_distinguishes_reordered_store(self):
        states=e.arbitrary(e.DIAG,e.FLAGS)
        for st in states:st.fs=e.bv(0x10000)
        a=execute('ba0700000089150000010064a100000000',states[0])
        b=execute('64a100000000ba07000000891500000100',states[1])
        self.assertFalse(e.prove([a.regs['eax']==b.regs['eax']]))
        self.assertTrue(e.equal(a.regs['eax'],e.bv(7)))

    def test_x87_tracks_effective_pointer_even_with_equal_values(self):
        states=e.arbitrary(e.DIAG,e.FLAGS)
        for st in states:
            st.regs['ecx']=e.bv(0x10000);st.regs['edx']=e.bv(0x20000)
            for address in (0x10000,0x20000):st.store(e.bv(address),e.bv(0))
        a,b=execute('d901',states[0]),execute('d902',states[1])
        dp=lambda st:e.simp(e.z3.Extract(context.CORE_BITS+31,context.CORE_BITS,st.fp))
        self.assertTrue(e.equal(dp(a),e.bv(0x10000)))
        self.assertTrue(e.equal(dp(b),e.bv(0x20000)))
        self.assertFalse(e.prove([a.fp==b.fp]))

    def test_register_operation_preserves_DP_and_updates_IP_opcode(self):
        a=execute('d9e0');b=execute('90d9e0')
        ip=lambda st:e.simp(e.z3.Extract(e.FP_BITS-1,e.FP_BITS-32,st.fp))
        self.assertTrue(e.equal(ip(a),e.bv(0x401000)))
        self.assertTrue(e.equal(ip(b),e.bv(0x401001)))
        for st in (a,b):self.assertTrue(e.equal(e.z3.Extract(735,704,st.fp),e.z3.Extract(735,704,e.z3.BitVec('x87_machine',e.FP_BITS))))

    def test_control_status_stores_and_WAIT_preserve_environment(self):
        initial=e.z3.BitVec('x87_machine',e.FP_BITS)
        for code in ('d939','dfe0','9b'):
            self.assertTrue(e.equal(execute(code).fp,initial))
        st=execute('d929')  # FLDCW changes control, not instruction/data pointers.
        self.assertTrue(e.equal(e.z3.Extract(e.FP_BITS-1,704,st.fp),e.z3.Extract(e.FP_BITS-1,704,initial)))

    def test_store_destination_becomes_FP_data_pointer(self):
        st=e.arbitrary(e.DIAG,e.FLAGS)[0];st.regs['ecx']=e.bv(0x10000)
        st=execute('d919',st)
        self.assertTrue(e.equal(e.z3.Extract(735,704,st.fp),e.bv(0x10000)))

    def test_private_store_pointer_remains_observable(self):
        a='83ec08d9eed95c240083c408c3';b='83ec08d9eed95c240483c408c3'
        c,f=build(a,a);self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        c,f=build(a,b);self.assertEqual('NOT PROVEN',c.check(f)[0])
        states=e.arbitrary(e.DIAG,e.FLAGS)
        for st in states:st.regs['esp']=e.bv(0x10010)
        values=[e.simp(e.z3.Extract(735,704,execute(code,st).fp)).as_long() for code,st in zip((a,b),states)]
        self.assertEqual([0x10008,0x1000c],values)

    def test_FP_pointer_dereference_restriction_is_explicit(self):
        pre='83ec08d9eed95c2400';tail='83c408c3'
        c,f=build(pre+'c7042401000000'+tail,pre+'c7042402000000'+tail)
        self.assertTrue(c.check(f)[0].startswith('PROVEN under'),c.check(f))
        self.assertTrue(any(v.get('low')==-8 and 'do not dereference' in v['predicate'] and 'Pointer values remain observable' in v['predicate'] for v in c.last_contracts['hypotheses']['H9']))
        self.assertTrue(all(v['pc']=='0x401005' and v['instruction']=='fstp dword ptr [esp]' and v['obligation'] for v in c.last_contracts['hypotheses']['H9']))

    def test_incoming_FDP_and_derived_public_FDP_need_no_H9(self):
        for body in ('83ec08c704240100000083c408c3','83ec08d944240c83c408c3'):
            c,f=build(body,body);self.assertTrue(c.check(f)[0].startswith('PROVEN'))
            self.assertNotIn('H9',c.last_contracts['hypotheses'])

    def test_derived_FDP_is_checked_before_a_proof_cut_point(self):
        pre='83ec08d9eed95c2400eb00';tail='83c408c3'
        c,f=build(pre+'c7042401000000'+tail,pre+'c7042402000000'+tail)
        self.assertTrue(c.check(f)[0].startswith('PROVEN under'))
        self.assertTrue(any(v['pc']=='0x401005' and v['low']==-8 for v in c.last_contracts['hypotheses']['H9']))

    def test_unmodeled_environment_and_segment_forms_fail_closed(self):
        for code in ('d930','dd30','d920','dd20','8ee0','0fb400','658b00'):
            c,f=build(code+'c3',code+'c3')
            self.assertEqual('UNSUPPORTED',c.check(f)[0],code)

    def test_calls_havoc_FSbase_without_observation_restriction(self):
        c,f=build('ff10c3','ff10c3');self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertNotIn('H9',c.last_contracts['hypotheses'])
        st=e.arbitrary(e.DIAG,e.FLAGS)[0];old=st.fs
        e.Machine(c.inp.addresses,0,[{},{}]).step(st,c.instructions(f)[0][0])
        self.assertFalse(e.equal(st.fs,old))
        from .test_calls import Calls
        c,f=Calls().caller('','','d930c3')
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
