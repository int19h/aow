"""Named H coverage and omission rejection, not a Lean refinement bridge."""
import copy
import unittest
import equiv_replay as replay
from equiv_certificate import check_claims
from .support import build
from .test_replay import ROUTES,force

# Independent of replay.POLICY: deleting a producer/validator row cannot weaken this test.
NAMED = dict(H1='EntrySeparation',H2='CreatedPointerOwnership',H3='CalleeContract',
             H3c='Explicit register convention and concrete cleanup instances',
             H4='IndependentFrameGarbage',H5='ImageRelation',H6='AccessAndFaultModel',
             H7='SegmentRelation',H8='EnvironmentInterference',H9='FPObservation')


class HypothesisCoverage(unittest.TestCase):
    def test_every_route_emits_and_cannot_omit_any_named_condition(self):
        for route in ROUTES:
            c,f=build('83ec08c704240100000083c408c3','83ec08c704240100000083c408c3')
            force(c,route);status,reason=c.check(f)
            with self.subTest(route=route):
                self.assertTrue(status.startswith('PROVEN'),reason)
                cert=c.last_certificate;hypotheses=cert['hypotheses']
                self.assertEqual(set(NAMED),set(hypotheses))
                self.assertTrue({'H1','H6'}<={h for h,v in hypotheses.items() if v['status']=='assumed'})
                for h,name in NAMED.items():
                    self.assertEqual(name,hypotheses[h]['predicate'])
                    self.assertIn(hypotheses[h]['status'],('assumed','discharged'))
                    for change in ('omit','predicate','status'):
                        bad=copy.deepcopy(cert)
                        if change=='omit':del bad['hypotheses'][h]
                        else:bad['hypotheses'][h][change]='True' if change=='predicate' else 'unsupported'
                        with self.subTest(h=h,change=change),self.assertRaises(ValueError):
                            replay.validate(bad,c.inp)
                assumed={h for h,v in hypotheses.items() if v['status']=='assumed'}
                for h in assumed:
                    claim='PROVEN under '+','.join(sorted(assumed-{h})) if assumed-{h} else 'PROVEN'
                    with self.assertRaises(ValueError):check_claims(claim,cert)

    def test_load_bearing_instances_are_assumed_with_evidence(self):
        from .test_public_events import ordered_pointer_cell
        from .test_image_relation import setup
        from .test_calls import Calls
        cases=[('direct-call',lambda:Calls().caller('','','b801000000c3'),{'H3'}),
               ('indirect-call',lambda:build('ff10c3','ff10c3'),{'H3c'}),
               ('image',setup,{'H5'}),('cell',ordered_pointer_cell,{'H5'}),
               ('repeat',lambda:build('8b0a8b0ac3','8b0ac3'),{'H8'}),
               ('fp',lambda:build('83ec08d9eed95c2400c704240100000083c408c3',
                                  '83ec08d9eed95c2400c704240200000083c408c3'),{'H9'})]
        for name,fixture,required in cases:
            with self.subTest(fixture=name):
                c,f=fixture();status,reason=c.check(f)
                self.assertTrue(status.startswith('PROVEN'),reason)
                hyp=c.last_certificate['hypotheses']
                for h in required:
                    self.assertEqual('assumed',hyp[h]['status'])
                    self.assertTrue(hyp[h]['evidence'])
                    bad=copy.deepcopy(c.last_certificate);bad['hypotheses'][h]['status']='discharged'
                    with self.assertRaises(ValueError):replay.validate(bad,c.inp)
