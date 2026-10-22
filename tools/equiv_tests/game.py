"""Fable's wrong2.py/unbound.py experiments, without embedded game bytes."""
import copy
import dataclasses
import time

import equiv as e
from .suite import suite
from .support import Case


SUBSTITUTIONS = (
    ('TWorldMap.PPawnMouseMove', 0x61e9b4, 0x45a200),
    ('TWorldMap.BookWinUpdate', 0x633504, 0x45b0fc),
    ('ShowProductionInfo', 0x61f49c, 0x45e210),
)
DELTAS = (4, 8, -4, 0x10, 0x40, 0x100)


def find(inp, name):
    matches = [f for f in inp.functions if f.name == name or f.name.endswith('.' + name)]
    if len(matches) != 1:
        raise ValueError('%s: expected one function, got %d' % (name, len(matches)))
    return matches[0]


def unbound_references(checker, fn):
    """Same survey as unbound.py; annotate image references absent from the global map."""
    refs = []
    addr = checker.inp.addresses
    for side, code in enumerate(checker.instructions(fn)):
        for ins in code:
            for op in ins.operands:
                value = addr.absolute(side, ins, op)
                mapping = addr.forward if side == 0 else addr.reverse
                if value is not None and value not in mapping:
                    record = (side, value, ins.mnemonic)
                    if record not in refs:
                        refs.append(record)
    return refs


def substitute(checker, fn, address, replacement):
    """Patch the baseline stream before verification, not check(mutated=...)."""
    original = checker.instructions

    def instructions(function):
        a, b = original(function)
        if function is not fn:
            return a, b
        b = [dataclasses.replace(i, operands=copy.deepcopy(i.operands)) for i in b]
        changed = 0
        for ins in b:
            for op in ins.operands:
                if op.type == e.X.X86_OP_MEM and op.mem.disp & 0xffffffff == address:
                    op.mem.disp = replacement - (1 << 32 if replacement >= 1 << 31 else 0)
                    changed += 1
        if not changed:
            raise ValueError('baseline operand %08x absent in %s' % (address, fn.name))
        return a, b

    checker.instructions = instructions
    try:
        return checker.check(fn)
    finally:
        checker.instructions = original


def refreshed_reference(checker, fn, original):
    """Locate the same fixture operand after relinking; never installs a binding."""
    import addrcheck
    inp = checker.inp
    streams = [[(e.match.normalize(i.raw, image), i.raw) for i in code]
               for code, image in zip(checker.instructions(fn), (inp.old, inp.new))]
    candidates = set()
    for (_, a), (_, b) in addrcheck.aligned(*streams):
        if a is None or b is None:
            continue
        for x, y in zip(a.operands, b.operands):
            if (x.type == y.type == e.X.X86_OP_MEM and x.mem.disp & 0xffffffff == original
                    and not (x.mem.base or x.mem.index or y.mem.base or y.mem.index)):
                candidates.add(y.mem.disp & 0xffffffff)
    if len(candidates) != 1:
        raise ValueError('fixture reference %08x in %s is missing or ambiguous' % (original, fn.name))
    return candidates.pop()


def cases(build_root=None, game_root=None, evidence=None):
    argv = dict(suite(build_root, game_root))['AoW']
    started = time.monotonic()
    inp = e.Inputs(argv)
    checker = e.Checker(inp)
    if evidence is not None:
        evidence['game_load_seconds'] = time.monotonic() - started
        evidence['unbound'] = {}
        evidence['skipped_already_bound'] = []
    for name, previous_address, original in SUBSTITUTIONS:
        fn = find(inp, name)
        address = refreshed_reference(checker, fn, original)
        if evidence is not None:
            evidence.setdefault('fixture_references', []).append(dict(function=name, original=hex(original), previous=hex(previous_address), current=hex(address)))
        refs = unbound_references(checker, fn)
        if evidence is not None:
            evidence['unbound'][name] = [dict(side=s, address=hex(a), mnemonic=m) for s, a, m in refs]
        yield Case('game_baseline/' + name, lambda fn=fn, checker=checker: checker.check(fn), 'pending_coverage',
                   'Unmodified installed game/reconstruction pair; baseline control.')
        for delta in DELTAS:
            replacement = address + delta
            if replacement in inp.addresses.reverse or not inp.new.contains(replacement):
                if evidence is not None:
                    evidence['skipped_already_bound'].append([name, hex(replacement)])
                continue
            yield Case('game_wrong_global/%s/%+d' % (name, delta),
                       lambda fn=fn, address=address, replacement=replacement, checker=checker:
                           substitute(checker, fn, address, replacement),
                       'reject', 'An unbound replacement is verified without a positional identity.')
    # Fable finding 3: the dropped private store exposes noncompositional garbage handling.
    inp = e.Inputs(dict(suite(build_root, game_root))['AoWTCPCK'])
    checker = e.Checker(inp)
    fn = find(inp, 'TCenterViewLocation.CanPlace')
    yield Case('game_baseline/' + fn.name, lambda fn=fn, checker=checker: checker.check(fn),
               'pending_coverage', 'Unmodified baseline for the private-frame mutation.')
    yield Case('game_drop_private_store/' + fn.name,
               lambda fn=fn, checker=checker: drop_private_store(checker, fn), 'reject',
               'Dropping [ebp-4]:=eax is accepted despite the independent-garbage/composition obligation.')


def drop_private_store(checker, fn):
    _, b = checker.instructions(fn)
    indices = [k for k, ins in enumerate(b)
               if ins.mnemonic == 'mov' and len(ins.operands) == 2
               and ins.operands[0].type == e.X.X86_OP_MEM
               and ins.reg_name(ins.operands[0].mem.base) == 'ebp'
               and ins.operands[0].mem.disp == -4
               and ins.operands[1].type == e.X.X86_OP_REG
               and ins.reg_name(ins.operands[1].reg) == 'eax']
    if len(indices) != 1:
        raise ValueError('expected exactly one [ebp-4]:=eax in ' + fn.name)
    edited = [dataclasses.replace(ins, mutation='drop store') if k == indices[0] else ins
              for k, ins in enumerate(b)]
    return checker.check(fn, edited)


def survey(groups, build_root=None, game_root=None):
    """Optional complete Fable-style survey; only metadata is returned."""
    result = []
    for group, argv in suite(build_root, game_root):
        if group not in groups:
            continue
        inp = e.Inputs(argv)
        checker = e.Checker(inp)
        for fn in inp.functions:
            if not fn.differs:
                continue
            try:
                refs = unbound_references(checker, fn)
            except e.Unsupported:
                continue
            if refs and checker.check(fn)[0] == 'PROVEN':
                result.append(dict(group=group, function=fn.name,
                                   references=[(s, hex(a), m) for s, a, m in refs]))
    return result
