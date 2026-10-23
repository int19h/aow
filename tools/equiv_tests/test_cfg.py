"""Focused regressions for the measurement overlay, not the proof semantics."""
import unittest
from unittest.mock import patch

import addrcheck
import match
from match_cfg import compare_cfg
from .support import Image, p32
from .synthetic import on_exception_program
from match_flow import original_extent


def stream(hexcode, address=0x401000):
    md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
    md.detail = True
    image = Image(bytes.fromhex(hexcode))
    return [(match.normalize(i, image), i) for i in md.disasm(bytes.fromhex(hexcode), address)]


class CFGTests(unittest.TestCase):
    def compare(self, old, new):
        return compare_cfg(stream(old), stream(new), 0x401000, 0x401000,
                           len(bytes.fromhex(old)), len(bytes.fromhex(new)))[0]

    def test_retargeted_branch(self):
        a, b = '85c97405b801000000c3', '85c97400b801000000c3'
        self.assertEqual(-1, match.compare([n for n, _ in stream(a)], [n for n, _ in stream(b)]))
        self.assertIn('changed_edge', self.compare(a, b))

    def test_middle_of_instruction(self):
        self.assertIn('invalid_target_boundary', self.compare('85c97405b801000000c3', '85c97401b801000000c3'))

    def test_reachable_suffix(self):
        self.assertIn('coverage_gap', self.compare('90', '90b801000000c3'))
        self.assertIn('changed_reachability', self.compare('90', '90b801000000c3'))

    def test_unreachable_padding(self):
        self.assertEqual([], self.compare('c3', 'c3909090'))

    def test_layout_only(self):
        self.assertEqual(['layout_only'], self.compare('85c974029090c3', '85c90f84020000009090c3'))

    def test_relocated_entry(self):
        a, b = stream('85c97400c3'), stream('85c97400c3', 0x501000)
        self.assertEqual([], compare_cfg(a, b, 0x401000, 0x501000, 5, 5)[0])

    def test_literal_push_is_not_code_root(self):
        # The pushed literal is inside the range but points at undecodable data.
        self.assertEqual([], self.compare('6807104000c3900f', '6807104000c3900f'))

    def test_case_table(self):
        code = bytes.fromhex('ff24850810400090') + p32(0x401010) + p32(0x401016)
        code += bytes.fromhex('b801000000c3b802000000c3')
        image = Image(code)
        md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
        md.detail = True
        table_stream = addrcheck.decode(md, image, 0x401000, len(code), None)
        self.assertTrue(any(n[0] == '.table' for n, _ in table_stream))
        self.assertEqual([], compare_cfg(table_stream, table_stream, 0x401000, 0x401000,
                                         len(code), len(code))[0])
        with patch.object(image, 'bytes_at', return_value=code), patch.object(image, 'data', None): self.assertEqual([], match.control_flow(md, image, image, 0x401000, 0x401000, len(code), len(code), {'next': (0x401000 + len(code), 1)}, ({}, {}))[2])

    def test_control_size_prefix(self):
        self.assertIn('control_operand_size', self.compare('c3', '66c3'))

    def exception_compare(self, old, new):
        images = [Image(old), Image(new)]
        md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
        md.detail = True
        streams = [addrcheck.decode(md, img, 0x401000, len(code), 0x401300)
                   for img, code in zip(images, (old, new))]
        self.assertTrue(any(n[0] == '.handlers' for n, _ in streams[0]))
        return compare_cfg(*streams, 0x401000, 0x401000, len(old), len(new), *images,
                           ({0x401300: '@HandleOnException'},)*2)[0]

    def test_exception_handler_target(self):
        a = on_exception_program(False)
        b = bytearray(a)
        marker = a.index(p32(2) + p32(0x402000))
        b[marker+8:marker+12], b[marker+16:marker+20] = b[marker+16:marker+20], b[marker+8:marker+12]
        self.assertIn('changed_exception_table', self.exception_compare(a, b))
        b[marker+8:marker+12] = p32(0x401002)
        self.assertIn('invalid_target_boundary', self.exception_compare(a, b))

    def test_classes_are_address_obligations(self):
        self.assertEqual([], self.exception_compare(on_exception_program(False), on_exception_program(True)))

    def test_truncated_exception_table(self):
        code = on_exception_program(False)
        cut = code.index(p32(2) + p32(0x402000)) + 6
        self.assertIn('incomplete_exception_table', self.exception_compare(code[:cut], code[:cut]))

    def test_repeated_names_in_measurement(self):
        from match_cfg import function_lines
        lines = function_lines('Register differs at instruction 0\nRegister MATCH 9 instructions, 25 bytes\n')
        self.assertIn('differs', lines['Register'].popleft())
        self.assertIn('MATCH', lines['Register'].popleft())

    def test_overlapping_signature_is_logged(self):
        md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
        md.detail = True
        image = Image(bytes.fromhex('90c3'))
        _, _, classes, details, ra, rb = match.control_flow(md, image, image, 0x401000, 0x401000,
            2, 2, {'f': (0x401000, 2), 'next': (0x401001, 1)}, ({}, {}), include_reached=True)
        self.assertIn('extent_truncated_by_next_signature', classes)
        self.assertTrue(ra and rb)

    def test_extent_bound(self):
        self.assertEqual(20, original_extent({'f': (100, 5), 'g': (120, 1)}, 100, 5))
        self.assertEqual(133, original_extent({'f': (100, 5)}, 100, 5))

    def test_loop_target(self):
        self.assertIn('changed_edge', self.compare('e20090c3', 'e20190c3'))

    def test_ordered_case_entries(self):
        a = bytes.fromhex('ff24850810400090') + p32(0x401010) + p32(0x401016)
        a += bytes.fromhex('b801000000c3b802000000c3')
        b = a[:8] + a[12:16] + a[8:12] + a[16:]
        md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
        md.detail = True
        streams = [addrcheck.decode(md, Image(c), 0x401000, len(c), None) for c in (a, b)]
        self.assertIn('changed_edge', compare_cfg(*streams, 0x401000, 0x401000, len(a), len(b))[0])

    def address_evidence(self, a, b, exception=False):
        from types import SimpleNamespace as NS
        from .support import build
        names = [(0x401300, 'System.@HandleOnException')] if exception else []
        checker, _ = build(a, b, names=names)
        inp = checker.inp
        inp.show = None
        if exception:
            inp.syms['@HandleOnException'] = [('0001', 0x300)]
        naming = NS(read_sites=set(), check_constants=lambda *args: None,
                    reference_pair=lambda inp, o, n, kind: (o, n), get=lambda *args: [], same=lambda *args: False)
        self.last_read_sites = naming.read_sites
        return addrcheck.collect(inp, naming), inp.flow_rejections

    def test_unreachable_tail_has_no_address_evidence(self):
        evidence, rejected = self.address_evidence('c3 a100204000', 'c3 a110204000')
        self.assertFalse(rejected)
        self.assertFalse(evidence)
        self.assertFalse(self.last_read_sites)

    def test_addrcheck_rejects_changed_flow(self):
        evidence, rejected = self.address_evidence('85c97405b801000000c3', '85c97400b801000000c3')
        self.assertFalse(evidence)
        self.assertIn('changed_edge', rejected['fixture'])

    def test_addrcheck_collects_class_identities(self):
        evidence, rejected = self.address_evidence(on_exception_program(False), on_exception_program(True), True)
        self.assertFalse(rejected)
        self.assertIn((0x402000, 0x402010), evidence)
        self.assertIn((0x402010, 0x402000), evidence)


if __name__ == '__main__':
    unittest.main()


