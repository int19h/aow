"""Resource exhaustion is deterministic; elapsed-time exhaustion is explicit."""
import unittest
from unittest.mock import patch
import equiv as e
from equiv_tests.support import build


class Limits(unittest.TestCase):
    def test_query_budget_is_reset_per_check(self):
        solver = e.z3.Solver()
        solver.add(e.z3.BoolVal(False))
        with patch.object(solver, 'set', wraps=solver.set) as settings:
            self.assertEqual(e.limits.check(solver, 'prove'), e.z3.unsat)
            self.assertEqual(e.limits.check(solver, 'prove'), e.z3.unsat)
        self.assertEqual(settings.call_args_list[0], settings.call_args_list[1])
        self.assertEqual(settings.call_args.kwargs['rlimit'], e.limits.RLIMIT['prove'])
        self.assertEqual(settings.call_args.kwargs['timeout'], 10*e.limits.EXPECTED_MS['prove'])
        self.assertEqual(settings.call_args.kwargs['threads'], 1)

    def test_resource_exhaustion_does_not_claim_safety_timeout(self):
        solver = e.z3.Solver()
        x = e.z3.BitVec('limit_test_x', 32)
        solver.add(x*x == 17)
        with patch.dict(e.limits.RLIMIT, prove=1):
            self.assertEqual(e.limits.check(solver, 'prove'), e.z3.unknown)

    def test_safety_timeout_is_visible_in_checker_reason(self):
        checker, fn = build('c3', 'c3')
        with patch.object(checker, 'check_raw', side_effect=e.limits.SafetyCap('solver safety cap: prove')):
            self.assertEqual(checker.check(fn), ('NOT PROVEN', 'solver safety cap: prove'))

    def test_canceled_at_resource_limit_is_not_a_safety_timeout(self):
        solver = unittest.mock.Mock()
        solver.check.return_value = e.z3.unknown
        solver.reason_unknown.return_value = 'canceled'
        with patch.object(e.limits, 'resources', side_effect=[0, e.limits.RLIMIT['prove']]):
            self.assertEqual(e.limits.check(solver, 'prove'), e.z3.unknown)

    def test_elapsed_timeout_is_labelled(self):
        solver = unittest.mock.Mock()
        solver.check.return_value = e.z3.unknown
        solver.reason_unknown.return_value = 'timeout'
        with patch.object(e.limits, 'resources', side_effect=[0, 123]):
            with self.assertRaisesRegex(e.limits.SafetyCap, 'solver safety cap: prove'):
                e.limits.check(solver, 'prove')

    def test_work_budget_is_per_search(self):
        first = e.limits.WorkBudget(1, 'test')
        with patch.object(e.limits, 'used', first.start + first.limit + 1):
            second = e.limits.WorkBudget(1, 'test')
            second.step()
            with self.assertRaisesRegex(e.NotProven, 'deterministic work limit'):
                first.step()

    def test_fact_order_does_not_depend_on_set_order(self):
        equations = {key: e.z3.BoolVal(True) for key in ('b', 'a')}
        self.assertEqual(e.conditional_facts(e.z3.BoolVal(True), equations), {'a', 'b'})

    def test_goal_order_is_content_based(self):
        goals = [e.z3.Bool(n) for n in ('z', 'a', 'm')]
        self.assertEqual(e.conjunction(goals).sexpr(), e.conjunction(reversed(goals)).sexpr())

    def test_global_solver_seeds_and_threads(self):
        for name, value in (('smt.random_seed', '0'), ('sat.random_seed', '0'), ('smt.arith.random_initial_value', 'false'), ('smt.threads', '1'), ('parallel.enable', 'false')):
            self.assertEqual(e.z3.get_param(name), value)

    def test_filter_insertion_order_preserves_queries(self):
        x = e.z3.BitVec('ordered_filter_x', 8)
        equations = {'b': x == 0, 'a': x == 1, 'c': e.z3.BoolVal(True)}
        traces = []
        for keys in (list(equations), list(reversed(equations))):
            trace = []
            original = e.limits.check
            def query(solver, kind):
                trace.append((kind, solver.sexpr()))
                return original(solver, kind)
            with patch.object(e.limits, 'check', query):
                self.assertEqual(e.conditional_facts(e.z3.BoolVal(True), {k: equations[k] for k in keys}), {'c'})
            traces.append(trace)
        self.assertEqual(*traces)
