"""Step 2a: identities cannot come from the comparison being certified."""
import dataclasses
import unittest
import equiv as e
from .support import build, p32

class Addresses(unittest.TestCase):
    def test_dynamic_local_cfg_consultation_blocks_other_routes(self):
        from unittest.mock import patch
        for route in ('verify','verify_fast'):
            checker,fn = build('b801000000c3','b801000000c3')
            def failure(*args,**kwargs):
                checker.inp.addresses.consulted.add((0x401001,0x401001,'local-cfg'))
                raise e.NotProven('dynamically consulted identity')
            with patch.object(checker,route,side_effect=failure), \
                 patch.object(e,'verify_frames',return_value=('PROVEN','')) as frames, \
                 patch.object(checker,'houdini',return_value=('PROVEN','')) as inference:
                self.assertEqual('NOT PROVEN',checker.check(fn)[0])
                frames.assert_not_called()
                inference.assert_not_called()

    def test_local_cfg_is_checked_scoped_and_explained(self):
        from .synthetic import finally_program
        a, ar = finally_program()
        for changed in (False, True):
            b, br = finally_program(True, changed)
            checker, fn = build(a,b,relocs=(ar,br),names=[(0x401300,'System.@HandleFinally')])
            addr = checker.inp.addresses
            saved = dict(addr.forward), dict(addr.reverse), dict(addr.provenance)
            status, _ = checker.check(fn)
            self.assertEqual('NOT PROVEN' if changed else 'PROVEN under H3', status)
            self.assertIn('local-cfg', {p for _,_,p in addr.consulted})
            self.assertEqual(saved, (addr.forward,addr.reverse,addr.provenance))
            if not changed:
                import contextlib, io, json
                from unittest.mock import patch
                checker.inp.explain, checker.inp.mutate = True, 0
                output = io.StringIO()
                with patch.object(e, 'Inputs', return_value=checker.inp), contextlib.redirect_stdout(output):
                    e.main([])
                records = [json.loads(line[8:]) for line in output.getvalue().splitlines() if line.startswith('EXPLAIN ')]
                proof = next(r for r in records if r.get('function') == fn.name and 'consulted' in r)
                self.assertEqual({(hex(a),hex(b),p) for a,b,p in addr.consulted},
                                 {(r['original'],r['compiled'],r['source']) for r in proof['consulted']})
                with patch.object(checker,'verify_fast',side_effect=e.NotProven('route guard')), \
                     patch.object(e,'verify_frames',return_value=('PROVEN','')):
                    self.assertEqual('NOT PROVEN',checker.check(fn)[0])

    def test_relocated_displacements(self):
        for opcode in (bytes.fromhex('8b83'), bytes.fromhex('8b048d'), bytes.fromhex('8b848b')):
            a, b = opcode + p32(0x402000) + b'\xc3', opcode + p32(0x402010) + b'\xc3'
            site = 0x401000 + len(opcode)
            checker, fn = build(a, b, bindings=[(0x402000, 0x402010)], relocs=([site], [site]))
            self.assertEqual('PROVEN', checker.check(fn)[0])
            checker, fn = build(a, b, bindings=[(0x402000, 0x402010)])
            self.assertNotEqual('PROVEN', checker.check(fn)[0], 'unrelocated offset must stay literal')
            checker, fn = build(a, b, relocs=([site], [site]))
            self.assertEqual('UNSUPPORTED', checker.check(fn)[0])
            self.assertTrue(checker.inp.addresses.unresolved)

    def test_image_sized_numeric_immediate_stays_literal(self):
        checker, fn = build(b'\xb8' + p32(0x402000) + b'\xc3',
                            b'\xb8' + p32(0x402010) + b'\xc3', bindings=[(0x402000, 0x402010)])
        self.assertEqual('NOT PROVEN', checker.check(fn)[0])

    def test_fixture_relinking_proposes_no_identity(self):
        from .game import refreshed_reference
        checker, fn = build(b'\xa1' + p32(0x402000) + b'\xc3', b'\xa1' + p32(0x402010) + b'\xc3')
        before = dict(checker.inp.addresses.forward)
        self.assertEqual(0x402010, refreshed_reference(checker, fn, 0x402000))
        self.assertEqual(before, checker.inp.addresses.forward)

    def test_constant_folding_cannot_bypass_global_identity(self):
        checker, fn = build(b'\xa1' + p32(0x402000) + b'\xc3', b'\xa1' + p32(0x402010) + b'\xc3',
            readonly=True, extras_a=[(0x2000,p32(1))], extras_b=[(0x2010,p32(1))])
        self.assertEqual('UNSUPPORTED', checker.check(fn)[0])

    def test_match_positions_cannot_bind(self):
        a, b = b'\xa1' + p32(0x402000) + b'\xc3', b'\xa1' + p32(0x402010) + b'\xc3'
        checker, fn = build(a, b)
        inp = checker.inp
        inp.module_matches = [(fn.ova, fn.osize, fn.nva, fn.nsize, 2)]
        inp.addresses = e.Addresses(inp)
        self.assertNotIn(0x402000, inp.addresses.forward)
        self.assertEqual('UNSUPPORTED', checker.check(fn)[0])

    def test_exception_classes_cannot_bind_from_table_positions(self):
        from .synthetic import on_exception_program
        checker, fn = build(on_exception_program(False), on_exception_program(True),
                            names=[(0x401300, 'System.@HandleOnException')])
        # Supply the fixture's identical local code identities independently;
        # the external class swap must still fail without a reviewed identity.
        a, _ = checker.instructions(fn)
        for ins in a:
            if ins.address < fn.ova + fn.osize:
                checker.inp.addresses.bind(ins.address, ins.address, 'fixture-local-code')
        status, reason = checker.check(fn)
        self.assertEqual('UNSUPPORTED', status)
        self.assertIn('0x402000', reason)
        self.assertNotIn(0x402000, checker.inp.addresses.forward)

    def test_proof_order_leaves_bindings_unchanged(self):
        a, b = b'\xa1' + p32(0x402000) + b'\xc3', b'\xa1' + p32(0x402010) + b'\xc3'
        checker, fn = build('b801000000c3', 'b801000000c3', extras_a=[(0x1100,a)], extras_b=[(0x1100,b)])
        other = dataclasses.replace(fn, name='other', ova=0x401100, nva=0x401100)
        addr = checker.inp.addresses
        before = dict(addr.forward), dict(addr.reverse), dict(addr.provenance)
        statuses = [checker.check(f)[0] for f in (fn, other, other, fn)]
        self.assertEqual(['PROVEN', 'UNSUPPORTED', 'UNSUPPORTED', 'PROVEN'], statuses)
        self.assertEqual(before, (addr.forward, addr.reverse, addr.provenance))
