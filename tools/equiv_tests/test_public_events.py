"""Public accesses are ordered; only exact repeated reads may use H8."""
import unittest
from types import SimpleNamespace as NS
import equiv as e
import equiv_events as events
from .support import build


def published_private_writes(mutant=True,frame=4):
    pre='83ec'+format(frame,'02x')+'c7042400000000'+('c744240400000000' if frame==8 else '')+'89e0a300204000'
    x='c7042401000000';y='c7042402000000';tail='31c083c4'+format(frame,'02x')+'c3'
    c,f=build(pre+x+y+tail,pre+(y if mutant else x+y)+tail,bindings=[(0x402000,0x402000)])
    for side in (0,1):c.inp.addresses.names[side][0x402000]='Fixture.Published'
    return c,f


def ordered_pointer_cell():
    from .test_pointer_cells import PointerCells
    fixture=PointerCells();c,f,entry=fixture.fixture(bytes.fromhex('8901'))
    fixture.install(c,[entry])
    return c,f


def temporary_below_prologue():
    return build('31c051595159c3','31c05159c3')


class PublicEvents(unittest.TestCase):
    def test_published_frame_requires_full_access_and_memory_checks(self):
        for mutant,frame in ((True,4),(False,4),(False,8)):
            c,f=published_private_writes(mutant,frame);self.assertEqual(not mutant,c.check(f)[0].startswith('PROVEN'))
            self.assertTrue(c.last_contracts['public_events']['full_accesses'])
    def test_reordered_writes_reject_despite_equal_boundary_memory(self):
        c,f=build('8908890ac3','890a8908c3')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_extra_identical_write_rejects(self):
        c,f=build('8908c3','89088908c3')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_duplicate_load_requires_H8(self):
        c,f=build('8b0a8b0ac3','8b0ac3')
        result=c.check(f)
        self.assertTrue(result[0].startswith('PROVEN'),result)
        self.assertIn('H8',c.last_contracts['hypotheses'])
        self.assertTrue(c.last_contracts['hypotheses']['H8']['coarsened_loads'])
    def test_equal_duplicate_loads_need_no_coarsening(self):
        c,f=build('8b0a8b0ac3','8b0a8b0ac3')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertNotIn('H8',c.last_contracts['hypotheses'])
    def test_equal_ordered_reads_need_no_coarsening(self):
        c,f=build('8b088b1089c831d2c3','8b088b1089d031d2c3')
        self.assertEqual('PROVEN under H6',c.check(f)[0])
        self.assertNotIn('H8',c.last_contracts['hypotheses'])
    def test_intervening_write_prevents_coarsening(self):
        c,f=build('8b0a890a8b0ac3','8b0a890ac3')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_ghost_load_store_is_not_an_event(self):
        st=e.arbitrary(e.DIAG,e.FLAGS)[0]
        st.store(e.bv(0x1000),e.bv(1));st.load(e.bv(0x1000),4)
        self.assertEqual([],st.events)
    def test_ownership_fringe_reads_are_not_machine_reads(self):
        from equiv_calls import ensure
        from equiv_garbage import check_initialized
        c,f=build('8908c3','8908c3');a,b=c.instructions(f);ensure(c,a,b)
        st=e.arbitrary(e.DIAG,e.FLAGS)[0]
        e.Ownership(c,check_initialized(c,a,0,0),st.regs['esp']).prepare(st)
        e.Machine(c.inp.addresses,0,[{},{}]).step(st,a[0])
        self.assertEqual(['write'],[x[0] for x in st.events])
    def test_private_writes_remain_unordered(self):
        x='c7042401000000';y='c744240402000000'
        c,f=build('83ec08'+x+y+'83c408c3','83ec08'+y+x+'83c408c3')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_reordered_reads_and_changed_width_reject(self):
        for a,b in [('8b018b17c3','8b178b01c3'),('8b01c3','0fb601c3')]:
            c,f=build(a,b);self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_private_write_cannot_hide_a_changed_repeat_value(self):
        r=('read',e.bv(1),e.bv(4),e.bv(2))
        a,b=e.arbitrary(e.DIAG,e.FLAGS)
        a.events=[r,(*r[:3],e.bv(3))];b.events=[r]
        self.assertEqual([2,1],[len(x) for x in events.paired((a,b))])

    def test_reverse_path_comparison_keeps_image_sides(self):
        checker=NS(h8_reads={});a,b=e.arbitrary(e.DIAG,e.FLAGS)
        a.ownership=NS(side=0,checker=checker);b.ownership=NS(side=1,checker=checker)
        r=('read',e.bv(1),e.bv(4),e.bv(2))
        a.events=[r,r];b.events=[r];a.access_pcs={1:dict(pc='0x100')};b.access_pcs={}
        events.paired((b,a))
        self.assertEqual([0],[v['side'] for v in checker.h8_reads.values()])
        b.events=[('write',*r[1:])];events.paired((b,a))
        self.assertEqual([1,0],checker.access_failure['sides'])

    def test_boundaries_widths_and_fs_are_not_coarsened(self):
        r=('read',e.bv(1),e.bv(4),e.bv(2))
        boundary=('call',e.bv(1))
        for middle in (boundary,('write',*r[1:])):
            a,b=e.arbitrary(e.DIAG,e.FLAGS);a.events=[r,middle,r];b.events=[r,middle]
            self.assertEqual([3,2],[len(x) for x in events.paired((a,b))])
        a,b=e.arbitrary(e.DIAG,e.FLAGS);a.events=[r,('read-fs',*r[1:])];b.events=[r]
        self.assertEqual([2,1],[len(x) for x in events.paired((a,b))])

    def test_rep_records_each_element(self):
        from equiv_calls import ensure
        from equiv_garbage import check_initialized
        c,f=build('5657b902000000f3a55f5ec3','5657b902000000f3a55f5ec3');a,b=c.instructions(f)
        ensure(c,a,b)
        states=e.arbitrary(e.DIAG,e.FLAGS);m=e.Machine(c.inp.addresses,0,[{},{}])
        e.Ownership(c,check_initialized(c,a,0,-8),states[0].regs['esp']).prepare(states[0])
        for ins in a[:4]:m.step(states[0],ins)
        self.assertEqual(['read','write','read','write'],[x[0] for i,x in enumerate(states[0].events) if i not in states[0].private_indices])
        self.assertEqual(4,sum(v['pc']==hex(a[3].address) for v in states[0].access_pcs.values()))

    def test_pointer_cell_is_constant_among_ordered_public_writes(self):
        c,f=ordered_pointer_cell()
        self.assertEqual('PROVEN under H5,H6',c.check(f)[0])
        self.assertNotIn('H8',c.last_contracts['hypotheses'])
        self.assertNotIn(0x402000,c.inp.addresses.forward)

    def test_temporary_below_prologue_extent_is_private(self):
        c,f=temporary_below_prologue()
        from equiv_garbage import private_extent
        self.assertEqual(0,private_extent(c.instructions(f)[0]))
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertEqual({-4},{r['low'] for r in c.last_contracts['entry_separation']})
        self.assertTrue(any(r['source']=='incoming ecx via ecx' for r in c.last_contracts['entry_separation']))

    def test_immutable_range_read_is_constant(self):
        from .test_image_relation import setup,A,B
        from .support import p32
        for code,other in [(b'\xa1'+p32(A)+bytes.fromhex('8901c3'),bytes.fromhex('b8010000008901c3')),
                           (bytes.fromhex('b8010000008901c3'),b'\xa1'+p32(B)+bytes.fromhex('8901c3'))]:
            c,f=setup(code,other)
            self.assertEqual('PROVEN under H5,H6',c.check(f)[0])
            self.assertNotIn('H8',c.last_contracts['hypotheses'])
