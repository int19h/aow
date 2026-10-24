"""Bounded access validity, fault ordering and pre-fault public state."""
import unittest
import equiv as e
import equiv_faults as faults
import equiv_events as events
from .support import build


class Faults(unittest.TestCase):
    def check_pair(self,a,b,proves):
        c,f=build(a,b);result=c.check(f)
        self.assertEqual(proves,result[0].startswith('PROVEN'),result)
        self.assertIn('fault_model',c.last_contracts)
        return c

    def test_missing_load_and_access_width_kind(self):
        for a,b in [('8b0831c9c3','31c9c3'),('8b0831c9c3','0fb60831c9c3'),
                    ('8b0831c9c3','890831c9c3')]:self.check_pair(a,b,False)

    def test_first_fault_cannot_move_around_public_write(self):
        self.check_pair('8b0a890731c9c3','89078b0a31c9c3',False)

    def test_divide_and_bound_mutants_and_controls(self):
        self.check_pair('31d2f7f1c3','31d290f7f1c3',True)
        self.check_pair('31d2f7f1c3','31d2c3',False)
        self.check_pair('620131c0c3','90620131c0c3',True)
        self.check_pair('620131c0c3','31c0c3',False)
        st=self.execute('6201')
        self.assertEqual(['read','bound-exception'],[v[0] for v in st.events])
        self.assertEqual(8,st.events[0][2].as_long())

    def test_wait_missing_and_reordered_reject(self):
        self.check_pair('9bc3','90c3',False)
        self.check_pair('9b8901c3','89019bc3',False)
        self.check_pair('9b90c3','909bc3',True)

    def execute(self,code):
        c,f=build(code,code);a,_=c.instructions(f)
        st=e.arbitrary(e.DIAG,e.FLAGS)[0]
        machine=e.Machine(c.inp.addresses,0,[{},{}])
        for ins in a:
            if ins.address>=a[0].address+len(bytes.fromhex(code)):break
            machine.step(st,ins)
        return st

    def test_write_fault_sees_memory_before_store(self):
        st=self.execute('8901');predicate,memory,fs,fp=st.faults[0]
        self.assertTrue(e.equal(memory,e.z3.Array('memory',e.BV32,e.BYTE)))
        self.assertFalse(e.equal(memory,st.memory))
        self.assertEqual('H6_valid_write',predicate.arg(0).decl().name())

    def test_memory_at_later_fault_contains_earlier_write(self):
        st=self.execute('89018b07')
        self.assertTrue(e.equal(st.faults[1][1],st.memory))
        left,right=e.arbitrary(e.DIAG,e.FLAGS)
        for state in (left,right):
            state.access_ins=st.access_ins
            faults.explicit(state,'divide-exception',e.z3.BoolVal(True))
        right.faults[0]=(right.faults[0][0],e.z3.Store(right.memory,e.bv(123),e.bv(7,8)),right.fs,right.fp)
        x,y=faults.finish((left,right),(left.events,right.events))
        self.assertFalse(e.prove([e.equality(a,b) for a,b in zip(x[0][1:],y[0][1:])]))

    def test_x87_pending_fault_precedes_operand_read(self):
        st=self.execute('d901')  # FLD dword ptr [ECX].
        self.assertEqual(['fp-pending-exception','read','fp-operation-exception:fld_mem4','x87:fld_mem4'],[x[0] for x in st.events])
        st=self.execute('9b')
        self.assertTrue(e.equal(st.fp,e.z3.BitVec('x87_machine',e.FP_BITS)))
        self.assertEqual(['fp-pending-exception'],[x[0] for x in st.events])
        self.assertNotIn('fp-pending-exception',[x[0] for x in self.execute('d939').events])

    def test_rep_access_faults_keep_element_order(self):
        st=self.execute('b902000000f3a5')
        self.assertEqual(['read','write','read','write'],[x[0] for x in st.events])
        self.assertEqual([0,1,2,3],list(st.faults))
        self.assertEqual([4]*4,[x[2].as_long() for x in st.events])

    def test_validity_distinguishes_width_kind_with_unified_FS(self):
        st=self.execute('8b018a01648b018901')
        names=[value[0].arg(0).decl().name() for value in st.faults.values()]
        self.assertEqual(['H6_valid_read','H6_valid_read','H6_valid_read-fs','H6_valid_write'],names)
        self.assertEqual([4,1,4,4],[v[0].arg(0).arg(1).as_long() for v in st.faults.values()])

    def test_nonfaulting_snapshot_is_unobserved(self):
        a,b=e.arbitrary(e.DIAG,e.FLAGS)
        a.events=b.events=[('divide-exception',e.z3.BoolVal(False))]
        for st in (a,b):faults.remember(st,0,e.z3.BoolVal(False))
        b.faults[0]=(e.z3.BoolVal(False),e.z3.Store(b.memory,e.bv(1),e.bv(7,8)),b.fs,b.fp)
        x,y=faults.finish((a,b),(a.events,b.events))
        self.assertTrue(e.prove([e.equality(u,v) for u,v in zip(x[0][1:],y[0][1:])]))

    def test_hidden_private_access_has_instantiated_H6_premise(self):
        c=self.check_pair('535bc3','535bc3',True)
        h=c.last_contracts['hypotheses']['H6']
        self.assertTrue(h['instances'])
        self.assertTrue(all('H6_valid_' in v['predicate'] and v['pc'] for v in h['instances']))
        c=self.check_pair('8b01c3','908b01c3',True)
        self.assertIn('H6',c.last_contracts['hypotheses'])

    def test_private_rep_records_each_validity_assumption(self):
        code='5783ec0889e7b800000000b902000000f3ab83c4085fc3'
        c=self.check_pair(code,code,True)
        rows=c.last_contracts['hypotheses']['H6']['instances']
        writes=[v for v in rows if v['pc']=='0x401010' and v['kind']=='write' and v['side']==0]
        self.assertEqual(2,len({v['address'] for v in writes}))
