"""Astra's independently constructed counterexamples and positive/domain controls."""
import random

import equiv as e
from .support import Case, build, call, fixture, p32


def cases():
    for changed in (False, True):
        a, ar = finally_program()
        b, br = finally_program(True, changed)
        yield fixture('local_cfg_continuation/' + str(changed), a, b,
                      'A relocated continuation is checked; retargeting changes the return.',
                      'reject' if changed else 'prove', relocs=(ar,br),
                      names=[(0x401300, 'System.@HandleFinally')])
    yield fixture('DF_return', 'fc c3', 'fd c3', 'Different direction flags at return.')
    yield fixture('missing_read_fault', '8b01 b800000000 c3', '90 b800000000 c3',
                  'ECX may be inaccessible; only the first execution faults.')
    yield fixture('ordered_public_writes', 'c70101000000 c70102000000 c3',
                  'c70102000000 c3', 'An observer can see the extra public write.')
    pre, post = bytes.fromhex('55 89e5'), bytes.fromhex('89ec 5d c3')
    helper = [(0x1100, bytes.fromhex('b800000000 83d000 c3'))]
    yield fixture('callee_carry', pre + b'\xf8' + call(4) + post,
                  pre + b'\xf9' + call(4) + post, 'Helper returns 0 versus 1.',
                  extras_a=helper, extras_b=helper, bindings=[(0x401100, 0x401100)])
    helper = [(0x1100, bytes.fromhex('89d8 c3'))]
    a, b = pre + bytes.fromhex('53 bb01000000'), pre + bytes.fromhex('53 bb02000000')
    tail = bytes.fromhex('8b5dfc 89ec 5d c3')
    yield fixture('callee_EBX', a + call(len(a)) + tail, b + call(len(b)) + tail,
                  'Saved/restored EBX differs at the helper, which returns EBX.',
                  extras_a=helper, extras_b=helper, bindings=[(0x401100, 0x401100)])
    a, b = pre + bytes.fromhex('b800000000'), pre + bytes.fromhex('8d0500000000')
    yield fixture('invented_callee_identity', a + call(len(a)) + post,
                  b + call(len(b), 0x401200) + post, 'Unpaired helpers return 1 versus 2.',
                  extras_a=[(0x1100, bytes.fromhex('b801000000 c3'))],
                  extras_b=[(0x1200, bytes.fromhex('b802000000 c3'))])
    a = b'\xa3' + p32(0x402000) + b'\xa1' + p32(0x402004) + bytes.fromhex('31c9 c3')
    b = b'\xa3' + p32(0x402000) + b'\xa1' + p32(0x402002) + bytes.fromhex('b900000000 c3')
    yield fixture('overlapping_address_mapping', a, b, 'The new read overlaps the preceding store.')
    for name, guard in [('returned_incoming_alias', ''), ('branch_established_alias', '39e1 7507')]:
        yield fixture(name, '83ec04 ' + guard + ' c7042401000000 89c8 83c404 c3',
                      '83ec04 ' + guard + ' c7042402000000 89c8 83c404 c3',
                      'ECX=entry ESP-4 returns a private slot with different contents; needs explicit H1.', expected='conditional:H1')
    yield fixture('independent_stack_garbage', '83ec04 8b0424 83c404 c3',
                  '83ec04 8b0424 83c404 c3', 'Both versions depend on uninitialized private bytes.')
    a, b = bytes.fromhex('8d05') + p32(0x402000), b'\xb8' + p32(0x402010)
    contents = dict(extras_a=[(0x2000, p32(1))], extras_b=[(0x2010, p32(2))],
                    readonly=True, bindings=[(0x402000, 0x402010)])
    yield fixture('indirect_immutable_contents', a + bytes.fromhex('8b00 c3'),
                  b + bytes.fromhex('8b00 c3'), 'Anchored immutable objects return 1 versus 2.',
                  relocs=([], [0x401001]), **contents)
    a, b = pre + a, pre + b
    helper = (0x1100, bytes.fromhex('8b00 c3'))
    contents['extras_a'] += [helper]
    contents['extras_b'] += [helper]
    contents['bindings'] += [(0x401100, 0x401100)]
    yield fixture('callee_immutable_contents', a + call(len(a)) + post,
                  b + call(len(b)) + post, 'A dereferencing helper returns 1 versus 2.',
                  relocs=([], [0x401004]), **contents)
    yield fixture('writable_initial_contents', b'\xa1' + p32(0x402000) + bytes.fromhex('31c9 c3'),
                  b'\xa1' + p32(0x402000) + bytes.fromhex('b900000000 c3'),
                  'Startup globals differ; the program initial-state relation must reject this.',
                  extras_a=[(0x2000, p32(1))], extras_b=[(0x2000, p32(2))],
                  bindings=[(0x402000, 0x402000)])
    yield fixture('WAIT_fault_memory', 'c70101000000 9b c70102000000 c3',
                  'c70103000000 9b c70102000000 c3', 'A pending FP exception sees different public memory.')
    yield fixture('x87_operand_pointer', 'c70100000000 c70200000000 d901 31c0 31d2 c3',
                  'c70100000000 c70200000000 d902 31c0 31d2 c3',
                  'Equal loaded numbers leave different observable FP operand pointers; needs explicit H9.', expected='conditional:H9')
    yield Case('builtin_mutant_EBX', mutant, 'reject', 'Built-in constant mutation changes the helper result.')
    yield fixture('FS_linear_alias', fs_program(True), fs_program(False),
                  'With FS.base=0x10000, moving the store changes the restored exception chain.',
                  names=[(0x401300, 'System.@HandleAnyException')])
    yield fixture('swapped_exception_classes', on_exception_program(False), on_exception_program(True),
                  'Swapping exception classes selects a different returning handler.',
                  names=[(0x401300, 'System.@HandleOnException')])
    yield fixture('positive_identical', '89c8 c3', '89c8 c3', 'Identical initialized behavior.', 'prove')
    yield fixture('positive_equivalent_encoding', 'b800000000 c3', '31c0 c3',
                  'Both return zero; arithmetic flags are not return values.', 'prove')
    yield fixture('positive_changed_return_rejected', 'b801000000 c3', 'b802000000 c3',
                  'A straightforward different return must be rejected.')
    yield fixture('positive_direct_contents_rejected', b'\xa1' + p32(0x402000) + b'\xc3',
                  b'\xa1' + p32(0x402010) + b'\xc3', 'Direct immutable reads already expose changed contents.',
                  extras_a=[(0x2000, p32(1))], extras_b=[(0x2010, p32(2))], readonly=True,
                  bindings=[(0x402000, 0x402010)])
    for route in ('inductive_frames', 'finite_frames', 'acyclic'):
        yield Case('alias_route/' + route, lambda route=route: alias_route(route), 'conditional:H1',
                   'The same branch-established alias must be checked on every proof route.')
    yield fixture('excluded_raw_divide_context',
                  'b901000000 31d2 b801000000 f7f2 b900000000 c3',
                  'b902000000 31d2 b801000000 f7f2 b900000000 c3',
                  'Raw OS ECX snapshots are excluded by the coordinator; this is a domain control.', 'prove')


def alias_route(route):
    checker, fn = build('83ec04 39e1 7507 c7042401000000 89c8 83c404 c3',
                        '83ec04 39e1 7507 c7042402000000 89c8 83c404 c3')
    a, b = checker.instructions(fn)
    try:
        if route == 'acyclic':
            return checker.acyclic(a, b)
        return e.verify_frames(checker, a, b, finite=route == 'finite_frames')
    except (e.NotProven, e.Unsupported) as exc:
        return ('NOT PROVEN' if isinstance(exc, e.NotProven) else 'UNSUPPORTED'), str(exc)


def mutant():
    pre = bytes.fromhex('55 89e5 53 bb01000000')
    code = pre + call(len(pre)) + bytes.fromhex('8b5dfc 89ec 5d c3')
    helper = [(0x1100, bytes.fromhex('89d8 c3'))]
    checker, fn = build(code, code, extras_a=helper, extras_b=helper,
                        bindings=[(0x401100, 0x401100)])
    _, b = checker.instructions(fn)
    edited, _, _ = e.mutate(b, random.Random(1), 'constant +1')
    return checker.check(fn, edited)


class Assembler:
    def __init__(self):
        self.parts, self.labels, self.size = [], {}, 0

    def put(self, data):
        self.parts.append((self.size, data))
        self.size += len(data)

    def label(self, name):
        self.labels[name] = self.size

    def reference(self, opcode, label, relative=False):
        self.parts.append((self.size, (opcode, label, relative)))
        self.size += len(opcode) + 4

    def finish(self):
        out = b''
        for position, item in self.parts:
            if isinstance(item, tuple):
                op, label, relative = item
                target = self.labels[label]
                value = target - (position + len(op) + 4) if relative else 0x401000 + target
                item = op + p32(value)
            out += item
        return out


def finally_program(pad=False, retarget=False):
    p = Assembler()
    p.put(bytes.fromhex('55 89e5 31c0') + (b'\x90' if pad else b''))
    p.put(b'\x55')
    p.reference(b'\x68', 'descriptor')
    p.put(bytes.fromhex('64ff30 648920 5a 59 59 64891500000000'))
    p.reference(b'\x68', 'bad' if retarget else 'good')
    p.label('cleanup')
    p.put(bytes.fromhex('31c0 c3'))
    p.label('descriptor')
    p.put(b'\xe9' + p32(0x401300 - (0x401000 + p.size + 5)))
    p.reference(b'\xe9', 'cleanup', True)
    p.label('good')
    p.put(bytes.fromhex('b801000000 31d2 c9 c3'))
    p.label('bad')
    p.put(bytes.fromhex('b802000000 31d2 c9 c3'))
    data = p.finish()
    relocs = [0x401000+i+1 for i in range(len(data)-4) if data[i] == 0x68
              and int.from_bytes(data[i+1:i+5], 'little') in [0x401000+x for x in p.labels.values()]]
    return data, relocs


def fs_program(before):
    p = Assembler()
    p.put(bytes.fromhex('81fc00000200'))
    p.reference(bytes.fromhex('0f82'), 'skip', True)
    p.put(bytes.fromhex('55 89e5 31c0'))
    store = bytes.fromhex('c7050000010044332211')
    if before:
        p.put(store)
    p.put(b'\x55')
    p.reference(b'\x68', 'descriptor')
    p.put(bytes.fromhex('64ff30 648920'))
    if not before:
        p.put(store)
    p.put(bytes.fromhex('59 58 5a 64890d00000000 31c0 31d2 c9 c3'))
    p.label('skip')
    p.put(bytes.fromhex('31c0 31d2 c3'))
    p.label('descriptor')
    p.put(b'\xe9' + p32(0x401300 - (0x401000 + p.size + 5)))
    p.put(bytes.fromhex('8b5d00 8b7504 8b7d08 31c0 31d2 c3'))
    return p.finish()


def on_exception_program(swapped):
    p = Assembler()
    p.put(bytes.fromhex('55 89e5 31c0 55'))
    p.reference(b'\x68', 'descriptor')
    p.put(bytes.fromhex('64ff30 648920 59 58 5a 64890d00000000 31c0 31d2 c9 c3'))
    p.label('descriptor')
    p.put(b'\xe9' + p32(0x401300 - (0x401000 + p.size + 5)))
    p.put(p32(2))
    for j, cls in enumerate(([0x402010, 0x402000] if swapped else [0x402000, 0x402010])):
        p.put(p32(cls))
        p.reference(b'', 'handler' + str(j))
    for j in range(2):
        p.label('handler' + str(j))
        p.put(bytes.fromhex('8b5d00 8b7504 8b7d08 b8') + p32(j + 1) + bytes.fromhex('31d2 c3'))
    return p.finish()
