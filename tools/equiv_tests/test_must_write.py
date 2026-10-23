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
                 'prove:H1,H3' if yes else 'reject','Checked pointer must-write before read') for name,h,x,yes in specs]+per_call_cases()

def per_call_cases():
    def run(read_first):
        prefix=bytes.fromhex('83ec0c8d0c24b90000000031d28d442408')
        body=prefix+call(len(prefix))+bytes.fromhex('8b44240883c40cc3')
        helper=bytes.fromhex('8b08c7000100000089c8c3' if read_first else 'c700010000008b00c3')
        c,f=build(body,body,extras_a=[(0x1100,helper)],extras_b=[(0x1100,helper)],bindings=[(0x401100,0x401100)])
        return c.check(f)
    return [Case('per_call_earlier_escape_'+('read_first' if read else 'must_write'),lambda read=read:run(read),
                 'reject' if read else 'prove:H1,H3','Only frame bytes reachable at this call require must-write coverage') for read in (False,True)]

class MustWrite(unittest.TestCase):
    def test_four_acceptance_fixtures(self):
        for case in cases():
            with self.subTest(case=case.name):
                result=case.run();self.assertEqual(case.expected.startswith('prove:'),result[0].startswith('PROVEN'),result)
                if case.name.endswith('read_first') or case.name=='var_out_reads_first':self.assertIn('callee read at 0x401100',result[1])
    def test_failed_call_names_event_and_component(self):
        prefix=bytes.fromhex('b801000000');a=prefix+call(len(prefix))+b'\xc3'
        b=bytes.fromhex('b802000000')+a[5:];helper=bytes.fromhex('83c001c3')
        c,f=build(a,b,extras_a=[(0x1100,helper)],extras_b=[(0x1100,helper)],bindings=[(0x401100,0x401100)])
        result=c.check(f);self.assertEqual('NOT PROVEN',result[0]);self.assertIn('call event at 0x401005 differs: callee inputs/cleanup',result[1])
    def test_callee_indirect_tail_diagnostic(self):
        import equiv as e
        from equiv_garbage import CutGarbage
        from types import SimpleNamespace as NS
        c,f=build('ff2500204000','ff2500204000');code=c.instructions(f)[0]
        site=dict(target='0x401000');c.contracts=NS(sites={(0,0x401000):(None,None,site)})
        key=(0,id(c.inp.old),0x401000,0)
        c.inp.call_summaries=NS(nodes={key:dict(code=code,edges={},alias=None)})
        g=CutGarbage.__new__(CutGarbage);g.e=e;g.checker=c
        # A caller's call is represented separately from this callee tail.
        caller=NS(address=0x401000,mnemonic='call');g.infos=[dict(code=[caller],side=0,reads=[(0,-4)])]
        g.failed([0]);self.assertEqual('0x401000',c.garbage_witness['callee_scan']['pc'])
        self.assertTrue(c.garbage_witness['callee_scan']['instruction'].startswith('jmp '))
    def test_outside_pointer_read_offset_can_still_reach_garbage(self):
        from .test_ownership import public_load_fixture
        c,f=public_load_fixture()
        for image in (c.inp.old,c.inp.new):image.data[0x1100:0x1104]=bytes.fromhex('8a4008c3')
        self.assertEqual('NOT PROVEN',c.check(f)[0])
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

    def test_unknown_frame_reach_has_no_64_byte_cap(self):
        from unittest.mock import patch
        from equiv_garbage import CutGarbage
        import equiv as e
        prefix=bytes.fromhex('83ec6089e0');body=prefix+call(len(prefix))+bytes.fromhex('31c083c460c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('ff10c3'))],extras_b=[(0x1100,bytes.fromhex('ff10c3'))],bindings=[(0x401100,0x401100)])
        observed=[];original=CutGarbage.mask
        def mask(obj,memory,base,info,state,allowed=(),st=None):
            if st is not None and getattr(st,'call_exposed',{}):observed.append(e.simp(st.call_exposed[-1]))
            return original(obj,memory,base,info,state,allowed,st)
        with patch.object(CutGarbage,'mask',mask):result=c.check(f)
        self.assertEqual('NOT PROVEN',result[0]);self.assertTrue(observed);self.assertTrue(all(e.z3.is_true(v) for v in observed))

    def test_imported_writer_uses_one_hop_and_cached_body(self):
        from unittest.mock import patch
        from types import SimpleNamespace as NS
        from pathlib import Path
        import tempfile
        import equiv as e
        from .support import Image
        from equiv_summaries import write_body
        helper=b'\xff\x25'+p32(0x402100)
        c,f=program(helper)
        other=Image(b'',extras=[(0x1100,bytes.fromhex('c700010000008b00c3'))])
        other.pe.DIRECTORY_ENTRY_EXPORT=NS(symbols=[NS(name=b'writer',address=0x1100,forwarder=None)])
        for image in (c.inp.old,c.inp.new):image.pe.DIRECTORY_ENTRY_IMPORT=[NS(dll=b'writer.dpl',imports=[NS(address=0x402100,name=b'writer')])]
        with tempfile.TemporaryDirectory() as folder:
            c.inp.original_path=Path(folder)/'fixture.exe';(Path(folder)/'writer.dpl').touch()
            with patch.object(e.match,'Image',return_value=other) as load:
                result=c.check(f);self.assertTrue(result[0].startswith('PROVEN'),result);self.assertEqual(1,load.call_count)
            graph=c.inp.call_summaries;root=graph.nodes[0,id(c.inp.old),0x401100,0]
            leaf=write_body(graph,root);self.assertEqual(1,leaf['hop']);self.assertEqual(15,leaf['writes']['eax'])
            self.assertIsNone(graph.imported(other,0x402100,1))

    def test_diagnostic_runs_once_after_all_failed_routes(self):
        from unittest.mock import patch
        import equiv as e
        prefix=bytes.fromhex('b801000000');a=prefix+call(len(prefix))+b'\xc3';b=bytes.fromhex('b802000000')+a[5:]
        c,f=build(a,b,extras_a=[(0x1100,bytes.fromhex('83c001c3'))],extras_b=[(0x1100,bytes.fromhex('83c001c3'))],bindings=[(0x401100,0x401100)])
        with patch.object(e,'correspondence_failure',wraps=e.correspondence_failure) as diagnostic:
            self.assertEqual('NOT PROVEN',c.check(f)[0]);self.assertEqual(1,diagnostic.call_count)
