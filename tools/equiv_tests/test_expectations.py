import unittest
from .__main__ import classify

class Expectations(unittest.TestCase):
    def test_H3c_is_separate_from_H3(self):
        self.assertEqual('KNOWN_FALSE_ACCEPT',classify('conditional:H3','PROVEN under H3c'))
        self.assertEqual('FIXED_OR_REJECTED',classify('conditional:H3c','PROVEN under H3c'))
    def test_conditional_premises(self):
        for status in ('PROVEN under H1', 'PROVEN under {H1}'):
            self.assertEqual('FIXED_OR_REJECTED', classify('conditional:H1', status))
        for status in ('PROVEN', 'PROVEN under H9', 'PROVEN under {H1,H8}', 'PROVEN under banana', 'PROVEN under {}'):
            self.assertEqual('KNOWN_FALSE_ACCEPT', classify('conditional:H1', status))
        self.assertEqual('KNOWN_FALSE_ACCEPT', classify('reject', 'PROVEN under H1'))
        self.assertEqual('KNOWN_FALSE_ACCEPT', classify('prove', 'PROVEN under H1'))
        self.assertEqual('FIXED_OR_REJECTED', classify('conditional:H9', 'NOT PROVEN'))

    def test_pending_coverage_is_distinct(self):
        self.assertEqual('PENDING_COVERAGE', classify('pending_coverage', 'UNSUPPORTED'))
        self.assertEqual('CONTROL_PASS', classify('pending_coverage', 'PROVEN'))
