"""H5 is validated before memory premises: never prove from inconsistent bytes."""
import unittest
import equiv as e
import equiv_image as image
from .support import build,p32,call

A,B = 0x402000,0x402010

def setup(code=None, other=None, kind='immutable-data', size=8, left=None, right=None):
    code = code or b'\xa1'+p32(A)+b'\xc3'
    other = other or b'\xa1'+p32(B)+b'\xc3'
    checker,fn = build(code,other,extras_a=[(0x2000,left or p32(1)+p32(2))],
                       extras_b=[(0x2010,right or p32(1)+p32(2))],bindings=[(A,B)])
    checker.inp.addresses.storage_objects = [(A,B,size,kind,'reviewed fixture layout')]
    return checker,fn

class ImageRelation(unittest.TestCase):
    def test_changed_contents_all_paths(self):
        for tail in (b'\x8b\x00\xc3', b'\x8b\x04\x88\xc3',call(5)+b'\xc3'):
            c,f = setup(b'\xb8'+p32(A)+tail,b'\xb8'+p32(B)+tail,right=p32(9)+p32(2))
            c.inp.addresses.relocs[0].add(0x401001);c.inp.addresses.relocs[1].add(0x401001)
            self.assertEqual('UNSUPPORTED',c.check(f)[0])
            self.assertIn('initialized byte differs',c.check(f)[1])
        c,f=setup(right=p32(9)+p32(2));self.assertIn('initialized byte differs',c.check(f)[1])
    def test_mutable_entry_not_frozen(self):
        c,f=setup(kind='mutable-data')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        relation=c.image_relation
        self.assertEqual({},relation.values)
        self.assertEqual(0,relation.summary()['bytes'])
        c,f=setup(kind='mutable-data',right=p32(9)+p32(2))
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_unknown_and_short_extents(self):
        c,f=setup(size=2)
        self.assertIn('exceeds justified extent',c.check(f)[1])
        c.inp.addresses.storage_objects=[]
        for img in (c.inp.old,c.inp.new):img.pe.sections[1].Characteristics &= ~0x80000000
        self.assertIn('unknown justified extent',c.check(f)[1])
    def test_shifted_overlap_and_contradictory_identity(self):
        c,f=setup();c.inp.addresses.storage_objects.append((A+4,B+2,4,'mutable-data','bad overlap'))
        self.assertIn('overlapping object offsets',c.check(f)[1])
        c,f=setup();c.inp.addresses.forward[A+1]=B+2
        self.assertIn('contradictory interior identity',c.check(f)[1])
    def test_bss_loader_zero(self):
        c,f=setup(kind='bss',left=bytes(8),right=bytes(8))
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        for img in (c.inp.old,c.inp.new):img.pe.sections[1].Characteristics |= 0x80
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        c.inp.new.data[0x2010]=1
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_recursive_pointer_graph_and_wrong_target(self):
        c,f=setup(left=p32(A+4)+p32(7),right=p32(B+4)+p32(7))
        d=c.inp.addresses;d.relocs[0].add(A);d.relocs[1].add(B);d.bind(A+4,B+4)
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertEqual(1,c.image_relation.pointers)
        c.inp.new.data[0x2010:0x2014]=p32(B+5);d.bind(A+5,B+5)
        self.assertIn('pointer target differs',c.check(f)[1])
    def test_partial_relocation_rejects(self):
        c,f=setup();c.inp.addresses.relocs[0].add(A-1)
        self.assertIn('relocation coverage',c.check(f)[1])
    def test_immutable_overlay_is_uniform_and_mutable_write_visible(self):
        c,f=setup();c.check(f);relation=c.image_relation
        memory=e.z3.Array('test_public',e.BV32,e.BYTE)
        state=e.State({}, {}, memory,memory,e.bv(0))
        old=image.ACTIVE;image.ACTIVE=relation
        try:
            self.assertTrue(e.prove([state.load(e.bv(A+4),4)==e.bv(2)]))
            state.store(e.bv(0x30000),e.bv(9))
            self.assertTrue(e.prove([state.load(e.bv(0x30000),4)==e.bv(9)]))
            state.memory=e.z3.Array('havoc',e.BV32,e.BYTE)
            self.assertTrue(e.prove([state.load(e.bv(A),4)==e.bv(1)]))
        finally:image.ACTIVE=old
    def test_unbounded_index_fails_and_bounded_index_proves(self):
        c,f=setup();c.check(f);r=c.image_relation
        index=e.z3.BitVec('index',32);memory=e.z3.Array('index_mem',e.BV32,e.BYTE)
        state=e.State({}, {},memory,memory,e.bv(0));address=e.bv(A)+index*4
        with self.assertRaisesRegex(e.Unsupported,'exceeds justified extent'):r.access(state,0,address,4,r.rows)
        state.path=e.z3.ULT(index,e.bv(2));r.access(state,0,address,4,r.rows)
    def test_callee_internals_are_h3_not_caller_h5(self):
        helper0=b'\xa1'+p32(A)+b'\xc3';helper1=b'\xa1'+p32(B)+b'\xc3'
        c,f=build(call(0)+b'\xc3',call(0)+b'\xc3',
                  extras_a=[(0x1100,helper0),(0x2000,p32(1))],
                  extras_b=[(0x1100,helper1),(0x2010,p32(9))],bindings=[(A,B),(0x401100,0x401100)])
        c.inp.addresses.storage_objects=[(A,B,4,'immutable-data','reviewed fixture layout')]
        status,reason=c.check(f)
        self.assertTrue(status.startswith('PROVEN'),reason)
        self.assertEqual(0,c.image_relation.summary()['objects'])
    def test_runtime_mutation_is_allowed_but_startup_folding_is_not(self):
        old=b'\xc7\x05'+p32(A)+p32(9)+b'\xa1'+p32(A)+b'\xc3'
        new=b'\xb8'+p32(9)+b'\xa3'+p32(B)+b'\xc3'
        c,f=setup(old,new,kind='mutable-data')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        c,f=setup(other=b'\xb8'+p32(1)+b'\xc3',kind='mutable-data')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_file_backed_zero_bytes_are_not_loader_zero_bss(self):
        c,f=setup(kind='bss',left=bytes(8),right=bytes(8))
        for img in (c.inp.old,c.inp.new):
            img.pe.sections[1].Characteristics |= 0x80
            img.pe.sections[1].SizeOfRawData=0x1000
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_stale_branch_condition_does_not_authorize_out_of_bounds(self):
        c,f=setup();c.check(f);r=c.image_relation
        memory=e.z3.Array('guard_mem',e.BV32,e.BYTE);state=e.State({}, {},memory,memory,e.bv(0))
        state.condition=e.z3.BoolVal(False)  # This is a branch result, not a path premise.
        with self.assertRaisesRegex(e.Unsupported,'exceeds justified extent'):r.access(state,0,e.bv(A)+e.z3.BitVec('unbounded_index',32)*4,4,r.rows)
    def test_code_pointer_passed_as_data_does_not_assume_equal_instruction_bytes(self):
        body=b'\xb8'+p32(0x401200)+call(5)+b'\xc3'
        c,f=build(body,body,relocs=([0x401001],[0x401001]),
                  extras_a=[(0x1100,bytes.fromhex('8b00c3')),(0x1200,bytes.fromhex('b801000000c3'))],
                  extras_b=[(0x1100,bytes.fromhex('8b00c3')),(0x1200,bytes.fromhex('b802000000c3'))],
                  bindings=[(0x401100,0x401100),(0x401200,0x401200)],names=[(0x401200,'Fixture.Code')])
        self.assertIn('unknown callee/escaping reach',c.check(f)[1])
    def test_unused_checked_constant_does_not_change_the_solver_model(self):
        from unittest.mock import patch
        c,f=build('8b01c3','8b01c3')
        with patch.object(e.limits,'check',wraps=e.limits.check) as queries:
            before=c.check(f);count=queries.call_count
        c.inp.addresses.storage_objects=[(A,A,48,'immutable-data','reviewed unrelated table')]
        with patch.object(e.limits,'check',wraps=e.limits.check) as queries:
            after=c.check(f);self.assertEqual(count,queries.call_count)
        self.assertTrue(before[0].startswith('PROVEN'));self.assertTrue(after[0].startswith('PROVEN'))
        self.assertEqual(0,c.image_relation.summary()['objects']);self.assertEqual({},c.image_relation.values)
    def test_integer_pointer_is_not_silently_rebased_by_numeric_range(self):
        code=b'\xb8'+p32(A)+bytes.fromhex('8b00c3')
        c,f=setup(code,code)
        self.assertIn('no checked pointer provenance',c.check(f)[1])
        # The actual pointer relocation, with independently reviewed storage, proves.
        c,f=setup(code,b'\xb8'+p32(B)+bytes.fromhex('8b00c3'))
        for side in (0,1):c.inp.addresses.relocs[side].add(0x401001)
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_callee_cannot_hide_code_bytes_behind_an_image_pointer(self):
        for relocated in (False,True):
            helper=b'\xb8'+p32(0x401200)+bytes.fromhex('8b00c3')
            c,f=build(call(0)+b'\xc3',call(0)+b'\xc3',names=[(0x401200,'Fixture.Code')],
                      extras_a=[(0x1100,helper),(0x1200,bytes.fromhex('b801000000c3'))],
                      extras_b=[(0x1100,helper),(0x1200,bytes.fromhex('b802000000c3'))],bindings=[(0x401100,0x401100)])
            if relocated:
                for side in (0,1):c.inp.addresses.relocs[side].add(0x401101)
            status,reason=c.check(f);self.assertTrue(status.startswith('PROVEN'),reason)
    def test_unreachable_body_data_is_not_an_obligation(self):
        c,f=build('c3a100204000c3','c3a110204000c3')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertEqual(0,c.image_relation.summary()['objects'])
    def test_unknown_mutable_extent_and_unequal_startup_bytes(self):
        c,f=setup(size=1,kind='mutable-data',right=p32(99)+p32(2))
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertEqual(0,c.image_relation.summary()['objects'])
    def test_explicit_map_size_never_uses_next_public_or_unit_contribution(self):
        syms={'Table':[('0002',0)],'Next':[('0002',16)]}
        self.assertEqual({'Table':8},image.map_sizes(' 0002:00000000 00000008H Table DATA',syms))
        self.assertEqual({},image.map_sizes(' 0002:00000000 Table\n 0002:00000010 Next\n 0002:00000000 00000100 C=DATA S=.data M=Unit',syms))
    def test_checked_passed_pointer_reach(self):
        for offset in (0,8):
            body=b'\xb8'+p32(A)+call(5)+b'\xc3';other=b'\xb8'+p32(B)+call(5)+b'\xc3'
            c,f=build(body,other,extras_a=[(0x1100,b'\x8b\x40'+bytes([offset])+b'\xc3'),(0x2000,p32(1)+p32(2))],extras_b=[(0x1100,b'\x8b\x40'+bytes([offset])+b'\xc3'),(0x2010,p32(1)+p32(2))],bindings=[(A,B),(0x401100,0x401100)],relocs=([0x401001],[0x401001]))
            c.inp.addresses.storage_objects=[(A,B,8,'immutable-data','reviewed fixture layout')]
            result=c.check(f)
            self.assertTrue(result[0].startswith('PROVEN') if offset==0 else 'exceeds justified extent' in result[1],result)

    def test_changed_contents_through_cut_point(self):
        tail=bytes.fromhex('85c974038b00c38b00c3')
        c,f=setup(b'\xb8'+p32(A)+tail,b'\xb8'+p32(B)+tail,right=p32(9)+p32(2))
        for side in (0,1):c.inp.addresses.relocs[side].add(0x401001)
        self.assertIn('initialized byte differs',c.check(f)[1])

    def test_code_byte_read_through_cut_point_rejects(self):
        body=b'\xb8'+p32(0x401200)+bytes.fromhex('85c974038b00c38b00c3')
        c,f=build(body,body,extras_a=[(0x1200,bytes.fromhex('b801000000c3'))],extras_b=[(0x1200,bytes.fromhex('b802000000c3'))],bindings=[(0x401200,0x401200)],names=[(0x401200,'Fixture.Code')],relocs=([0x401001],[0x401001]))
        self.assertEqual('UNSUPPORTED',c.check(f)[0])
