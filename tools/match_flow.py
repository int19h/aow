"""Shared conservative MATCH control-flow/table checks; external identities are separate."""
import bisect
import re
import struct
import capstone


def u32(image, address):
    data = image.bytes_at(address, 4)
    return struct.unpack('<I', data)[0] if len(data) == 4 else None


def original_extent(signatures, va, size):
    starts = sorted({address for address, _ in signatures.values()})
    pos = bisect.bisect_right(starts, va)
    limit = starts[pos] if pos < len(starts) else va + size + 128
    return max(0, min(limit-va, size+128))

def decode(md, img, va, size, on_exception, normalize):
    """match.disasm_skipping_tables, retaining raw instructions for operands."""
    out = []
    code = img.bytes_at(va, size)
    pos = 0
    while pos < size:
        insns = list(md.disasm(code[pos:], va + pos))
        if not insns:
            break
        for ins in insns:
            out.append((normalize(ins, img), ins))
            pos = ins.address - va + ins.size
            m = re.fullmatch(r'dword ptr \[(?:e[a-z]{2})\*4 \+ (0x[0-9a-f]+)\]', ins.op_str) if ins.mnemonic == 'jmp' else None
            if m and va <= int(m.group(1), 16) < va + size:
                tpos = int(m.group(1), 16) - va
                skip = 0
                while (skip < 8 and tpos + 4 <= len(code) and
                       not va <= struct.unpack_from('<I', code, tpos)[0] < va + size):
                    tpos += 4
                    skip += 1
                entries = []
                while tpos + 4 <= len(code):
                    target = struct.unpack_from('<I', code, tpos)[0]
                    if not va <= target < va + size:
                        break
                    entries.append(target - va)
                    tpos += 4
                if entries and tpos > pos:
                    out.append((('.table', ' '.join('%x' % e for e in entries)), None))
                    pos = tpos
                    break
            if ins.mnemonic == 'jmp' and on_exception is not None:
                try:
                    target = int(ins.op_str, 16)
                except ValueError:
                    target = None
                if target == on_exception:
                    if pos + 4 > len(code):
                        out.append((('.handlers', 'INCOMPLETE'), None))
                        return out
                    n = struct.unpack_from('<I', code, pos)[0]
                    if 0 < n < 16 and pos + 4 + 8*n <= len(code):
                        entries = []
                        for j in range(n):
                            cls, handler = struct.unpack_from('<II', code, pos + 4 + 8*j)
                            entries.append('%s:%x' % ('ADDR' if img.contains(cls) else hex(cls), handler-va))
                        out.append((('.handlers', ' '.join(entries)), None))
                        pos += 4 + 8 * n
                        if pos >= size:
                            return out
                        break
                    out.append((('.handlers', 'INCOMPLETE'), None))
                    return out
        else:
            break
    return out


X = capstone.x86_const


def issue(kind, **fields):
    return dict(classification=kind, **fields)


def handler_pointer(stream, k, pcs, handlers):
    """Recognize descriptor/normal-finally PUSHes; literal pools are not code roots."""
    ins = stream[k][1]
    if ins is None or ins.mnemonic != 'push' or not ins.operands:
        return False
    op = ins.operands[0]
    if op.type != X.X86_OP_IMM:
        return False
    target = stream[pcs[op.imm]][1] if op.imm in pcs else None
    if (target is not None and target.mnemonic == 'jmp' and target.operands
            and target.operands[0].type == X.X86_OP_IMM
            and target.operands[0].imm in (handlers or {})):
        return True
    following = [i for _, i in stream[k+1:k+3]]
    if len(following) == 2 and all(i is not None for i in following) and following[0].mnemonic == 'push' and following[1].mnemonic == 'mov' and 'fs:' in following[1].op_str:
        return True
    previous = stream[k - 1][1] if k else None
    return bool(previous is not None and previous.mnemonic == 'mov' and len(previous.operands) == 2
                and previous.operands[0].type == X.X86_OP_MEM
                and previous.reg_name(previous.operands[0].mem.segment) == 'fs'
                and previous.operands[1].type == X.X86_OP_REG
                and previous.reg_name(previous.operands[1].reg) != 'esp')


def graph(stream, start, size, image=None, handlers=None):
    """Reachability, including case tables and referenced local handler roots.

    Calls to other functions fall through; external jumps are terminal. No
    identity claim is made for them. PUSHed local code pointers are roots so
    finally continuations cannot disappear behind an intermediate RET.
    """
    pcs = {ins.address: k for k, (_, ins) in enumerate(stream) if ins is not None}
    tables = {}
    for k, (norm, ins) in enumerate(stream):
        if norm[0] == '.table' and k and stream[k - 1][1] is not None:
            tables[stream[k - 1][1].address] = [start + int(v, 16) for v in norm[1].split()]
    todo, seen, edges, problems, code_pushes = [start], set(), {}, [], set()
    while todo:
        pc = todo.pop()
        if pc in seen:
            continue
        if pc not in pcs:
            problems.append(issue('coverage_gap', pc=hex(pc), offset=pc - start,
                                  reason='outside_extent' if not start <= pc < start + size else 'decode_gap'))
            continue
        k = pcs[pc]
        _, ins = stream[k]
        seen.add(pc)
        op = ins.operands[0] if ins.operands else None
        mnemonic = ins.mnemonic
        outgoing = []
        if mnemonic.startswith('ret'):
            pass
        elif mnemonic == 'jmp' or mnemonic.startswith('j') or mnemonic.startswith('loop'):
            if op is not None and op.type == X.X86_OP_IMM:
                target = op.imm
                if start <= target < start + size:
                    outgoing.append(target)
                elif handlers and target in handlers and image is not None:
                    kind = handlers[target]
                    if kind == '@HandleOnException':
                        table = ins.address + ins.size
                        n = u32(image, table)
                        if n is None or not 0 < n < 16 or table + 4 + 8 * n > start + size:
                            problems.append(issue('incomplete_exception_table', pc=hex(pc)))
                        else:
                            outgoing += [u32(image, table + 8 + 8 * j) for j in range(n)]
                    else:
                        outgoing.append(ins.address + ins.size)
            elif pc in tables:
                outgoing += tables[pc]
            else:
                problems.append(issue('unresolved_indirect_jump', pc=hex(pc)))
            if mnemonic != 'jmp':
                outgoing.append(ins.address + ins.size)
        else:
            outgoing.append(ins.address + ins.size)
        # Exception descriptors, normal finally continuations and nested callbacks.
        if handler_pointer(stream, k, pcs, handlers):
            code_pushes.add(k)
            todo.append(op.imm)
        if mnemonic == 'call' and op is not None and op.type == X.X86_OP_IMM and start <= op.imm < start + size:
            todo.append(op.imm)
        edges[k] = outgoing
        todo.extend(outgoing)
    return seen, edges, problems, pcs, code_pushes


def exception_tables(stream, start, size, image, handlers):
    """Class addresses are masked: their identities remain address-layer obligations."""
    tables, problems = {}, []
    pcs = {ins.address for _, ins in stream if ins is not None}
    if image is None:
        return tables, problems
    for k, (_, ins) in enumerate(stream):
        if (ins is None or ins.mnemonic != 'jmp' or not ins.operands
                or ins.operands[0].type != X.X86_OP_IMM
                or (handlers or {}).get(ins.operands[0].imm) != '@HandleOnException'):
            continue
        table = ins.address + ins.size
        n = u32(image, table)
        if n is None or not 0 < n < 16 or table + 4 + 8*n > start + size:
            problems.append(issue('incomplete_exception_table', index=k))
            continue
        entries = []
        for j in range(n):
            cls, target = (u32(image, table + 4 + 8*j),
                           u32(image, table + 8 + 8*j))
            entries.append(('ADDR' if image.contains(cls) else hex(cls), target - start))
            if target not in pcs or not start <= target < start + size:
                problems.append(issue('invalid_target_boundary', index=k, handler=j, offset=target-start))
        tables[k] = entries
    return tables, problems


def compare_cfg(a, b, ova, nva, osize, nsize, old=None, new=None, handlers=(None, None)):
    """Strict relative-offset comparison with classifications for benign layout.

    The instruction-index mapping is only the old MATCH's positional mapping;
    changes outside its prefix must also agree on all reached instruction shapes.
    This fails closed on layout differences; it is not graph isomorphism.
    """
    at, ap = exception_tables(a, ova, osize, old, handlers[0])
    bt, bp = exception_tables(b, nva, nsize, new, handlers[1])
    ga = graph(a, ova, osize, old, handlers[0])
    gb = graph(b, nva, nsize, new, handlers[1])
    problems = [dict(side=side, **p) for side, g in enumerate((ga, gb)) for p in g[2]]
    problems += [dict(side=side, **p) for side, ps in enumerate((ap, bp)) for p in ps]
    jump_tables = [[norm for norm, _ in stream if norm[0] == '.table'] for stream in (a, b)]
    if jump_tables[0] != jump_tables[1]:
        problems.append(issue('changed_edge', original_tables=jump_tables[0], compiled_tables=jump_tables[1]))
    if at != bt:
        problems.append(issue('changed_exception_table', original=at, compiled=bt,
                              class_identity='address-layer obligation'))
    reached = [{g[3][pc] for pc in g[0]} for g in (ga, gb)]
    for k in sorted(reached[0] | reached[1]):
        if k not in reached[0] or k not in reached[1]:
            problems.append(issue('changed_reachability', index=k,
                                  original=k in reached[0], compiled=k in reached[1]))
            continue
        (an, ai), (bn, bi) = a[k], b[k]
        if an != bn:
            problems.append(issue('reachable_suffix_shape', index=k, original=an, compiled=bn))
        if ai is None or bi is None:
            continue
        if ai.mnemonic in ('call', 'jmp', 'ret') or (ai.mnemonic.startswith('j') or ai.mnemonic.startswith('loop')):
            if ai.addr_size != bi.addr_size or (0x66 in ai.prefix) != (0x66 in bi.prefix):
                problems.append(issue('control_operand_size', index=k))
        for j, (x, y) in enumerate(zip(ai.operands, bi.operands)):
            transfer = ai.mnemonic in ('call', 'jmp') or (ai.mnemonic.startswith('j') or ai.mnemonic.startswith('loop'))
            if not transfer and k not in ga[4] and k not in gb[4]:
                continue
            if x.type != X.X86_OP_IMM or y.type != X.X86_OP_IMM:
                continue
            ax, bx = ova <= x.imm < ova + osize, nva <= y.imm < nva + nsize
            if not ax and not bx:
                continue  # External target identity is a separate address-layer obligation.
            ta, tb = ga[3].get(x.imm), gb[3].get(y.imm)
            if not ax or not bx:
                kind = 'changed_target_locality'
            elif ta is None or tb is None:
                kind = 'invalid_target_boundary'
            elif ta != tb:
                kind = 'changed_edge'
            elif x.imm - ova != y.imm - nva:
                kind = 'layout_only'
            else:
                continue
            problems.append(issue(kind, index=k, operand=j, old_offset=x.imm - ova,
                                  new_offset=y.imm - nva, old_target_index=ta, new_target_index=tb))
        ae, be = ga[1][k], gb[1][k]
        if len(ae) != len(be):
            problems.append(issue('changed_successor_count', index=k, original=len(ae), compiled=len(be)))
    # Bound verbose diagnostics while retaining distinct classes for every function.
    classes = sorted({p['classification'] for p in problems})
    return classes, problems[:40]


def helper_addresses(inp):
    import match
    names = ('@HandleFinally', '@HandleAnyException', '@HandleOnException', '@HandleAutoException')
    old, new = {}, {}
    for name in names:
        address = match.find_import_thunk(inp.old, 'System.' + name)
        if address is not None:
            old[address] = name
        loc = match.resolve(inp.syms, name)
        if loc and loc[0] == '0001':
            new[inp.text + loc[1]] = name
    return old, new


def primary_classification(classes):
    if 'coverage_gap' in classes or 'incomplete_exception_table' in classes:
        return 'incomplete_decode_or_extent'
    if 'unresolved_indirect_jump' in classes:
        return 'unresolved_indirect_flow'
    if 'invalid_target_boundary' in classes:
        return 'invalid_target_boundary'
    if any(c in classes for c in ('changed_edge', 'changed_target_locality', 'changed_successor_count',
                                  'changed_reachability', 'reachable_suffix_shape', 'control_operand_size', 'changed_exception_table')):
        return 'changed_control_flow'
    return 'layout_only' if classes else 'retained'

