"""H4 initialization, composition, fixed points and exception route gates."""
import unittest
from unittest.mock import patch
import equiv as e
from .support import build
from .synthetic import finally_program
class Garbage(unittest.TestCase):
    def test_read_before_write_and_composition(self):
        # A previous function can leave 1 versus 2; the next reads that slot.
        for body in ('83ec048b042483c404c3','5589e583ec048b45fcc9c3'):
            c,f=build(body,body)
            self.assertEqual('NOT PROVEN',c.check(f)[0]);self.assertTrue(c.check(f)[1].startswith('reads uninitialized private slot'))
            self.assertIsNotNone(c.last_contracts['frame_garbage']['witness'])
        for value in (1,2):
            body='83ec04c70424%02x00000083c404c3'%value
            c,f=build(body,body);self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        reader='83ec048b042483c404c3';c,f=build(reader,reader)
        self.assertEqual('NOT PROVEN',c.check(f)[0])
    def test_initialized_save_restore_and_partial_byte(self):
        for body in ('5383ec04c70424010000008b042483c4045bc3',
                     '5589e583ec04c745fc010000008b45fcc9c3'):
            c,f=build(body,body);self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
        body='83ec04c60424018b042483c404c3';c,f=build(body,body)
        self.assertTrue(c.check(f)[1].startswith('reads uninitialized private slot'))
    def test_join_intersects_definitions(self):
        body='83ec0485c97407c70424010000008b042483c404c3'
        c,f=build(body,body);self.assertTrue(c.check(f)[1].startswith('reads uninitialized private slot'))
    def test_independent_bytes_and_shared_extent(self):
        c,f=build('5589e583ec08538b042483c40c5dc3','5589e583ec08538b042483c40c5dc3')
        a,b=c.instructions(f);frames=e.Frames((a,b))
        self.assertEqual([e.private_extent(a),e.private_extent(b)],frames.lows)
        states,_=frames.states(initial=True)
        self.assertFalse(e.equal(states[0].load(frames.stack+e.bv(-8),1),states[1].load(frames.stack+e.bv(-8),1)))
    def test_unknown_stack_fails_closed(self):
        body='83ec0489c48b0424c3';c,f=build(body,body)
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_exception_fallback_cannot_bypass(self):
        a,ar=finally_program();c,f=build(a,a,relocs=(ar,ar),names=[(0x401300,'System.@HandleFinally')])
        with patch.object(c,'verify',side_effect=e.NotProven('whole route failed')),patch.object(e,'verify_frames',return_value=('PROVEN','')) as frames,patch.object(c,'acyclic',return_value=('PROVEN','')) as finite:
            self.assertEqual('UNSUPPORTED',c.check(f)[0]);frames.assert_not_called();finite.assert_not_called()
    def test_two_function_stack_reuse_has_distinguishing_context(self):
        outputs=[]
        for value in (1,2):
            writer='83ec04c70424%02x00000083c404c3'%value
            c,f=build(writer,writer);code=c.instructions(f)[0]
            states=e.arbitrary(e.DIAG,e.FLAGS);st=states[0]
            machine=e.Machine(c.inp.addresses,0,[{},{}])
            for ins in code[:-1]: machine.step(st,ins)
            reader,rf=build('83ec048b042483c404c3','83ec048b042483c404c3')
            for ins in reader.instructions(rf)[0][:-1]: machine.step(st,ins)
            outputs.append(e.simp(st.regs['eax']).as_long())
        self.assertEqual([1,2],outputs)
    def test_nonconvergent_stack_and_late_allocation_fail_closed(self):
        for body in ('83ec0483ec04ebfb','9083ec048b042483c404c3'):
            c,f=build(body,body);self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_opaque_callee_cannot_receive_uninitialized_private_bytes(self):
        from .support import call
        prefix=bytes.fromhex('83ec0489e0')
        body=prefix+call(len(prefix))+bytes.fromhex('8b042483c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('c70001000000c3'))],extras_b=[(0x1100,bytes.fromhex('c70001000000c3'))],bindings=[(0x401100,0x401100)])
        self.assertEqual(('NOT PROVEN','uninitialized local passed to callee at 0x401005 (callee write not checked)'),c.check(f));self.assertIsNotNone(c.last_contracts['frame_garbage']['witness'])
    def test_script_and_import_entry_points_share_model(self):
        import sys
        import equiv_garbage as g
        with patch.dict(sys.modules,{'__main__':e}):
            with patch.dict(sys.modules):
                del sys.modules['equiv']
                self.assertIs(e,g.model())
    def test_late_allocation_cannot_pass_unhavoced_garbage_to_callee(self):
        from .support import call
        prefix=bytes.fromhex('9083ec0489e0')
        body=prefix+call(len(prefix))+bytes.fromhex('83c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('8b00c3'))],extras_b=[(0x1100,bytes.fromhex('8b00c3'))],bindings=[(0x401100,0x401100)])
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_lea_mov_and_pop_cannot_bypass_extent(self):
        for body in ('8d6424fc8b042483c404c3','8d4424fc89c48b042483c404c3','5cc3'):
            c,f=build(body,body);self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_x87_store_initializes_private_bytes(self):
        body='83ec04d9eed91c248b042483c404c3'
        c,f=build(body,body);self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_pop_ecx_discard_and_initialized_multiblock(self):
        for body in ('83ec0459c3','83ec0485c974079090909090909059c3',
                     '83ec04c7042401000000eb008b042483c404c3'):
            c,f=build(body,body);self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
    def test_garbage_passed_to_reading_callee_rejects_with_witness(self):
        from .support import call
        prefix=bytes.fromhex('83ec0489e0');body=prefix+call(len(prefix))+bytes.fromhex('83c404c3')
        c,f=build(body,body,extras_a=[(0x1100,bytes.fromhex('8b00c3'))],extras_b=[(0x1100,bytes.fromhex('8b00c3'))],bindings=[(0x401100,0x401100)])
        self.assertEqual(('NOT PROVEN','uninitialized local passed to callee at 0x401005 (callee write not checked)'),c.check(f));self.assertIsNotNone(c.last_contracts['frame_garbage']['witness'])
    def test_unlinked_exception_head_fails_closed(self):
        from .synthetic import fs_program
        c,f=build(fs_program(True),fs_program(False),names=[(0x401300,'System.@HandleAnyException')])
        self.assertFalse(c.check(f)[0].startswith('PROVEN'))
