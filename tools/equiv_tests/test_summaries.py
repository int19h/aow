"""Step 4b bounded call-graph fixed points, imports and cached obligations."""
import tempfile
import unittest
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import patch
import equiv as e
from equiv_calls import CallContracts
from equiv_summaries import ModuleSummaries
from .support import build,call,p32,Image

def relative(pc,target): return b'\xe8'+p32(target-pc-5)
class Summaries(unittest.TestCase):
    def graph(self,helper,extra=()):
        checker,_=build('c3','c3',extras_a=[(0x1100,helper)]+list(extra))
        owner=CallContracts(checker);graph=checker.inp.call_summaries=ModuleSummaries(owner)
        return owner,graph
    def test_nested_read_set_and_cleanup(self):
        owner,g=self.graph(relative(0x401100,0x401180)+b'\xc2\x04\x00',[(0x1180,bytes.fromhex('89d8c3'))])
        s=g.query(owner,0,0x401100)
        self.assertEqual(4,s[1]);self.assertIn(('r','ebx',0),s[0]);self.assertEqual(2,len(g.nodes))
        used=g.work;g.query(owner,0,0x401100);self.assertEqual(used,g.work)
    def test_SCC_descends_from_top_without_assuming_dead_recursive_inputs(self):
        a=b'\xf8'+relative(0x401101,0x401180)+b'\xc3'
        b=b'\xf8'+relative(0x401181,0x401100)+b'\xc3'
        owner,g=self.graph(a,[(0x1180,b)]);s=g.query(owner,0,0x401100)
        self.assertEqual(0,s[1]);self.assertNotIn(('f','cf'),s[0])
        self.assertIn(('r','ebx',0),s[0]);self.assertGreater(g.iterations,1)
    def test_budget_exhaustion_during_SCC_discards_partial_narrowing(self):
        a=b'\xf8'+relative(0x401101,0x401180)+b'\xc3'
        b=b'\xf8'+relative(0x401181,0x401100)+b'\xc3'
        owner,g=self.graph(a,[(0x1180,b)]);g.INSTRUCTION_LIMIT=8
        self.assertIsNone(g.query(owner,0,0x401100))
        self.assertTrue(all(n['value'][0]==g.full and not n['valid'] for n in g.nodes.values()))
    def test_node_caps_are_not_spent_by_other_queries(self):
        results=[]
        for order in ((0x401100,0x401180),(0x401180,0x401100)):
            owner,g=self.graph(b'\x90'*21+b'\xc3',[(0x1180,bytes.fromhex('b801000000c3'))]);g.INSTRUCTION_LIMIT=20
            answers={}
            for target in order:
                local=CallContracts(owner.checker);answers[target]=g.query(local,0,target)
            results.append((answers,{n['target']:(n['work'],n['budget_outcomes']) for n in g.nodes.values()}))
            self.assertIsNone(answers[0x401100]);self.assertIsNotNone(answers[0x401180]);self.assertGreater(g.work,20)
        self.assertEqual(*results)
    def test_SCC_cap_and_cached_evidence_do_not_depend_on_entry(self):
        results=[]
        for order in ((0x401100,0x401180),(0x401180,0x401100)):
            a=b'\xf8'+relative(0x401101,0x401180)+b'\xc3';b=b'\xf8'+relative(0x401181,0x401100)+b'\xc3'
            owner,g=self.graph(a,[(0x1180,b)]);g.SCC_ITERATION_LIMIT=1
            for target in order:
                local=CallContracts(owner.checker);self.assertIsNone(g.query(local,0,target))
                self.assertTrue(all('read SCC iteration cap' in n['outcomes'] for n in local.summary_budgets.values()))
            results.append({n['target']:(n['work'],n['budget_outcomes'],n['value'],n['h1']) for n in g.nodes.values()})
        self.assertEqual(*results)
    def test_explain_records_per_node_caps(self):
        c,f=build(call(0)+b'\xc3',call(0)+b'\xc3',extras_a=[(0x1100,bytes.fromhex('b801000000c3'))],extras_b=[(0x1100,bytes.fromhex('b801000000c3'))],bindings=[(0x401100,0x401100)])
        self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        self.assertEqual(2,len(c.last_contracts['summary_budgets']))
        for n in c.last_contracts['summary_budgets']:
            self.assertLessEqual(n['instructions'],n['instruction_limit']);self.assertEqual(['within caps'],n['outcomes'])
        owner,g=self.graph(bytes.fromhex('ff10c3'));g.query(owner,0,0x401100)
        self.assertTrue(all(not n['must_write_summary'] for n in owner.summary_budgets.values()))
    def test_unknown_child_uses_explicit_H3c_taint(self):
        owner,g=self.graph(relative(0x401100,0x500000)+b'\xc3')
        self.assertTrue(g.query(owner,0,0x401100)[3])
        unknown=next(n for n in g.nodes.values() if n['target']==0x500000)
        self.assertEqual(g.full,unknown['value'][0]);self.assertIsNone(unknown['value'][1])
    def test_unknown_child_ret_cleanup_still_propagates(self):
        owner,g=self.graph(relative(0x401100,0x401180)+b'\xc3',[(0x1180,bytes.fromhex('ff10c3'))])
        s=g.query(owner,0,0x401100)
        self.assertEqual(0,s[1]);self.assertTrue(s[3]);self.assertNotIn(('r','ebx',0),s[0])
    def test_unsupported_prefix_indirect_and_budgets_are_top(self):
        for body in ('f3c3','f3abc3'):
            owner,g=self.graph(bytes.fromhex(body));self.assertIsNone(g.query(owner,0,0x401100))
            self.assertEqual(g.full,next(iter(g.nodes.values()))['value'][0])
        for size in (3,4097):
            owner,g=self.graph(b'\x90'*size+b'\xc3')
            if size==3:g.INSTRUCTION_LIMIT=2
            self.assertIsNone(g.query(owner,0,0x401100));self.assertLessEqual(g.work,g.INSTRUCTION_LIMIT)
    def test_location_observers_still_reject_transitively(self):
        for body,failure in [('8b0424c3',e.NotProven),('5850c3',e.NotProven),('e80000000058c3',e.Unsupported),('d93424c3',e.Unsupported),('660f7ec0c3',e.Unsupported)]:
            owner,g=self.graph(relative(0x401100,0x401180)+b'\xc3',[(0x1180,bytes.fromhex(body))])
            with self.assertRaises(failure):g.query(owner,0,0x401100)
    def test_cached_H1_facts_replay_into_each_proof(self):
        owner,g=self.graph(bytes.fromhex('5389105bc3'));g.query(owner,0,0x401100)
        facts=set(owner.h1);self.assertTrue(facts)
        other=CallContracts(owner.checker);g.query(other,0,0x401100);self.assertEqual(facts,other.h1)
    def test_imports_follow_exactly_one_module_hop_and_cache_images(self):
        with tempfile.TemporaryDirectory() as temp:
            owner,g=self.graph(b'\xff\x25'+p32(0x402100))
            owner.checker.inp.original_path=Path(temp)/'fixture.exe'
            dll=Path(temp)/'other.dpl';dll.touch()
            image=owner.checker.inp.old
            image.pe.DIRECTORY_ENTRY_IMPORT=[NS(dll=b'other.dpl',imports=[NS(address=0x402100,name=b'leaf')])]
            other=Image(b'\xc3',extras=[(0x1100,bytes.fromhex('b801000000c20400'))])
            other.pe.DIRECTORY_ENTRY_EXPORT=NS(symbols=[NS(name=b'leaf',address=0x1100,forwarder=None)])
            with patch.object(e.match,'Image',return_value=other) as load:
                self.assertEqual(4,g.query(owner,0,0x401100)[1]);g.query(owner,0,0x401100)
                self.assertEqual(1,load.call_count)
            self.assertIsNone(g.imported(other,0x402100,1))
    def test_import_parser_budget_is_not_consumed_again_by_queries(self):
        owner,g=self.graph(b'\xff\x25'+p32(0x402100));image=owner.checker.inp.old
        image.pe.DIRECTORY_ENTRY_IMPORT=[NS(dll=b'other.dpl',imports=[NS(address=0x402100,name=b'leaf')])]
        with patch.object(image.pe,'parse_data_directories',side_effect=AssertionError('reparsed imports')):
            for _ in range(3):
                self.assertEqual(0x401100,e.match.find_import_thunk(image,'leaf'))
                g.imported(image,0x402100,0)
        def metadata_only(*,directories):
            self.assertNotIn(e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_IMPORT'],directories)
        with patch.object(image.pe,'parse_data_directories',side_effect=metadata_only):e.Addresses(owner.checker.inp)
    def test_nested_EBX_and_carry_mutants_reject(self):
        for helper,left,right in [('89d8c3','bb01000000','bb02000000'),('b80000000083d000c3','f8','f9')]:
            a=bytes.fromhex(left);b=bytes.fromhex(right)
            x=b'\x53'+a+call(1+len(a))+bytes.fromhex('5bc3')
            y=b'\x53'+b+call(1+len(b))+bytes.fromhex('5bc3')
            extras=[(0x1100,relative(0x401100,0x401180)+b'\xc3'),(0x1180,bytes.fromhex(helper))]
            checker,fn=build(x,y,extras_a=extras,extras_b=extras,bindings=[(0x401100,0x401100)])
            self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))

    def test_segment_registers_on_RTL_string_shapes_are_not_hazards(self):
        from .test_calls import Calls
        for helper in ('5657a55f5ec3','5657f3a65f5ec3'):
            checker,fn=Calls().caller('','',helper)
            self.assertTrue(checker.check(fn)[0].startswith('PROVEN'))
            self.assertIn('H3c',checker.last_contracts['hypotheses'])
    def test_virtual_callee_taints_summary_without_inventing_EBX_input(self):
        from .test_calls import Calls
        checker,fn=Calls().caller('bb01000000','bb02000000','ff10c3')
        self.assertEqual('PROVEN under H1,H3,H3c,H6',checker.check(fn)[0])
        self.assertEqual('summarized/H3c',checker.last_contracts['hypotheses']['H3c'][0]['summary_kind'])
    def test_virtual_callee_own_EBX_read_remains_a_real_input(self):
        from .test_calls import Calls
        checker,fn=Calls().caller('bb01000000','bb02000000','89daff10c3')
        self.assertFalse(checker.check(fn)[0].startswith('PROVEN'))

    def test_assumed_cleanup_offset_is_not_a_return_address_witness(self):
        owner,g=self.graph(bytes.fromhex('9052ff105ac3'))
        summary=g.query(owner,0,0x401100)  # 4c recognizes the matching POP: concrete zero cleanup, still H3c.
        self.assertIsNotNone(summary);self.assertEqual(0,summary[1]);self.assertTrue(summary[3])
    def test_segment_POP_does_not_enter_GPR_join_state(self):
        owner,g=self.graph(bytes.fromhex('74040fa00fa1c3'))
        g.query(owner,0,0x401100)
    def test_known_return_address_read_before_unknown_call_still_rejects(self):
        owner,g=self.graph(bytes.fromhex('8b0424ff10c3'))
        with self.assertRaises(e.NotProven):g.query(owner,0,0x401100)

    def test_LEA_is_not_a_saved_slot_value_read(self):
        owner,g=self.graph(bytes.fromhex('56518d442402595ec3'))
        summary=g.query(owner,0,0x401100)
        self.assertNotIn(('r','esi',0),summary[0])
