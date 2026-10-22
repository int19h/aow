"""Hand-authored var/out callees; no game bytes are stored here."""
import unittest
from .support import build,call,p32,Case

def program(helper,extra=(),stack=False):
    prefix=bytes.fromhex('83ec0489e0'+('50' if stack else ''))
    body=prefix+call(len(prefix))+bytes.fromhex('8b042483c404c3')
    extras=[(0x1100,bytes.fromhex(helper) if isinstance(helper,str) else helper)]+list(extra)
    return build(body,body,extras_a=extras,extras_b=extras,bindings=[(0x401100,0x401100)])

def cases():
    nested=b'\xe8'+p32(0x401180-0x401105)+b'\xc3'
    specs=[('var_out_writes_then_reads','c700010000008b00c3',(),True),
           ('var_out_reads_first','8b08c7000100000089c8c3',(),False),
           ('var_out_forwarded_writer',nested,[(0x1180,bytes.fromhex('c70001000000c3'))],True),
           ('var_out_forwarded_indirect',nested,[(0x1180,bytes.fromhex('ff10c3'))],False)]
    return [Case(name,lambda h=h,x=x: (lambda c,f:c.check(f))(*program(h,x)),
                 'prove:H1,H3' if yes else 'reject','Checked pointer must-write before read') for name,h,x,yes in specs]

class MustWrite(unittest.TestCase):
    def test_four_acceptance_fixtures(self):
        for case in cases():
            with self.subTest(case=case.name):
                result=case.run();self.assertEqual(case.expected.startswith('prove:'),result[0].startswith('PROVEN'),result)
                if case.name=='var_out_reads_first':self.assertIn('callee read at 0x401100',result[1])
    def test_stack_argument(self):
        c,f=program('8b442404c700010000008b00c20400',stack=True)
        self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_partial_and_conditional_writes_do_not_mask_dword(self):
        for h in ('c60001c3','85c97406c70001000000c3','f3abc3'):
            c,f=program(h);self.assertFalse(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_other_pointer_may_alias_before_write(self):
        c,f=program('8b0ac7000100000089c8c3')
        self.assertFalse(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_forwarding_stack_pointer_unchanged(self):
        h=b'\x50\xe8'+p32(0x401180-0x401106)+b'\xc3'
        c,f=program(h,[(0x1180,bytes.fromhex('8b442404c70001000000c20400'))])
        self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_overwritten_stack_argument_is_not_original_pointer(self):
        from equiv_calls import CallContracts
        # Overwriting the incoming cell destroys its pointer identity.
        c,f=program('c7442404000000008b442404c70001000000c20400',stack=True)
        owner=CallContracts(c);owner.scan(0,0x401100)
        node=c.inp.call_summaries.nodes[0,id(c.inp.old),0x401100,0]
        self.assertEqual({},node['writes'])
    def test_budget_publishes_no_partial_must_write(self):
        from equiv_calls import CallContracts
        from equiv_summaries import ModuleSummaries
        c,f=program('c70001000000c3');owner=CallContracts(c)
        g=c.inp.call_summaries=ModuleSummaries(owner);g.INSTRUCTION_LIMIT=1
        owner.scan(0,0x401100)
        self.assertTrue(all(n['writes']=={} for n in g.nodes.values()))
    def test_wrapping_pointer_read_is_not_outside_the_object(self):
        c,f=program('050000008005000000808b08c7000100000089c8c3')
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_caller_alias_read_is_not_discharged_by_later_callee_write(self):
        prefix=bytes.fromhex('83ec048b0089e1');body=prefix+call(len(prefix))+bytes.fromhex('83c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('8901c3'))],extras_b=[(0x1100,bytes.fromhex('8901c3'))],bindings=[(0x401100,0x401100)])
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_incoming_stack_read_can_alias_the_output_pointer(self):
        c,f=program('8b4c2404c7000100000089c8c3')
        result=c.check(f);self.assertEqual('NOT PROVEN',result[0]);self.assertIn('callee read at 0x401100',result[1])
        c,f=program('c700010000008b4c240489c8c3')
        self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_published_private_pointer_is_not_hidden_by_a_later_writer(self):
        prefix=bytes.fromhex('83ec0489e0a300204000');body=prefix+call(len(prefix))+bytes.fromhex('83c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('c70001000000c3'))],extras_b=[(0x1100,bytes.fromhex('c70001000000c3'))],bindings=[(0x401100,0x401100),(0x402000,0x402000)])
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
