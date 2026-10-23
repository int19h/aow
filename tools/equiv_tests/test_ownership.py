"""H1 is explicit on every route; created addresses never gain H1."""
import unittest
import equiv as e
from equiv_garbage import check_initialized
from equiv_ownership import Ownership,outside,origins
from .support import build
from .synthetic import alias_route
class EntryOwnership(unittest.TestCase):
    def test_aliases_are_conditional_on_every_route(self):
        for route in ('inductive_frames','finite_frames','acyclic'):
            self.assertEqual('PROVEN under H1',alias_route(route)[0])
    def test_public_loaded_address_word_has_explicit_predicate(self):
        c,f=build('83ec048b088b0983c404c3','83ec048b088b0983c404c3')
        a,b=c.instructions(f)
        from equiv_calls import ensure
        ensure(c,a,b);st=e.arbitrary(e.DIAG,e.FLAGS)[0];base=st.regs['esp']
        o=Ownership(c,check_initialized(c,a,0,-4),base);o.prepare(st)
        value=st.load(base+e.bv(4),4);o.address(value)
        self.assertTrue(e.prove([e.z3.Implies(e.z3.And(o.premises),outside(value,base,-4))]))
        self.assertTrue(any(r['source']=='public-loaded address word' for r in o.records))
        o.consult();self.assertTrue(c.contracts.entry_separation)
    def test_private_garbage_is_not_a_public_word(self):
        c,f=build('83ec048b042483c404c3','83ec048b042483c404c3')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_created_pointer_published_or_returned_still_rejects(self):
        for tail in ('a300204000','a3002040008b0d002040008901',''):
            c,f=build('83ec0489e0'+tail+'83c404c3','83ec0889e0'+tail+'83c408c3',bindings=[(0x402000,0x402000)])
            self.assertFalse(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_unknown_store_kills_saved_input_origin(self):
        body='51508b1089025859c3'
        c,f=build(body,body);a,b=c.instructions(f)
        from equiv_calls import ensure
        ensure(c,a,b);info=check_initialized(c,a,0,e.private_extent(a))
        result=origins(c,info)
        # mov [edx],eax is an unknown alias; saved ECX cannot become an axiom.
        self.assertNotIn('ecx',result[6][0])
    def test_stack_argument_is_an_entry_predicate(self):
        c,f=build('83ec048b44240883c404c20400','83ec048b44240883c404c20400')
        a,b=c.instructions(f)
        from equiv_calls import ensure
        ensure(c,a,b);st=e.arbitrary(e.DIAG,e.FLAGS)[0]
        o=Ownership(c,check_initialized(c,a,0,-4),st.regs['esp']);o.prepare(st)
        self.assertTrue(any(r['source']=='stack argument +4' for r in o.records))
    def test_observed_EBX_is_not_covered_by_H1(self):
        from .support import call
        pre=bytes.fromhex('83ec04');body=pre+call(len(pre))+bytes.fromhex('83c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('8b03c3'))],extras_b=[(0x1100,bytes.fromhex('8b03c3'))],bindings=[(0x401100,0x401100)])
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_split_pointer_stores_do_not_evade_escape(self):
        c,f=build('83ec0483c404c3','83ec0483c404c3');a,b=c.instructions(f)
        from equiv_calls import ensure
        ensure(c,a,b);st=e.arbitrary(e.DIAG,e.FLAGS)[0];base=st.regs['esp']
        o=Ownership(c,check_initialized(c,a,0,-4),base);o.prepare(st)
        st.path=e.z3.And(e.z3.UGE(base,e.bv(0x10004)),e.z3.ULE(base,e.bv(0xfffffff0)))
        pointer=base-e.bv(4);st.store(e.bv(0x402000),e.z3.Extract(15,0,pointer));st.store(e.bv(0x402002),e.z3.Extract(31,16,pointer))
        self.assertFalse(e.prove(o.goals(st)))
    def test_partial_boolean_return_cannot_hide_an_initialization_mismatch(self):
        a='5589e583ec048945fcb001c9c3';b='5589e583ec04909090b001c9c3'
        c,f=build(a,b);self.assertEqual('NOT PROVEN',c.check(f)[0])
        c,f=build(a,a);self.assertTrue(c.check(f)[0].startswith('PROVEN'))
    def test_public_load_pass_then_dereference(self):
        c,f=public_load_fixture();result=c.check(f)
        self.assertTrue(result[0].startswith('PROVEN under H1'),result)
    def test_published_frame_pointer_reload_is_not_a_vacuous_H1_proof(self):
        c,f=published_frame_fixture();self.assertEqual('NOT PROVEN',c.check(f)[0])


def public_load_fixture():
    from .support import call
    prefix=bytes.fromhex('5683ec048b74240c89f0');body=prefix+call(len(prefix))+bytes.fromhex('0fb60683c4045ec20400')
    return build(body,body,extras_a=[(0x1100,bytes.fromhex('8a00c3'))],extras_b=[(0x1100,bytes.fromhex('8a00c3'))],bindings=[(0x401100,0x401100)])


def published_frame_fixture():
    tail='89e0a300204000a1002040008b0083c404c3'
    checker,fn=build('83ec04c7042401000000'+tail,'83ec04c7042402000000'+tail,bindings=[(0x402000,0x402000)])
    checker.inp.addresses.storage_objects=[(0x402000,0x402000,4,'mutable-data','fixture pointer declaration')]
    return checker,fn


def cases():
    from .support import Case
    for name,factory,expected in [('public_load_pass_then_dereference',public_load_fixture,'prove:H1,H3'),('published_frame_pointer_reload_dereference',published_frame_fixture,'reject')]:
        yield Case(name,lambda factory=factory:(lambda c,f:c.check(f))(*factory()),expected,'Earlier H1 load predicates precede independent escape obligations.')
