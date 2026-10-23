"""Conservative relational translation validation for tools/match.py.

The input selection and MATCH/differ classification are the matcher's. Proofs
use unmasked instructions. Basic-block entries are cut points (including entry
and every loop head), and a Houdini fixed point discovers register equalities.
Each edge is then checked with arbitrary states satisfying its
invariant, rather than with a bounded execution of a loop.

Memory is a byte array. The fast proof relates the whole array. A second
inductive proof projects private frame bytes and infers byte-slot/register
correspondences, constants and frame-address facts with Houdini. A permanent
entry ESP and incoming nonvolatile-register values check save/restore pairs.
Caller-visible memory remains equal at cut points, calls and returns. Escaped
frame addresses require the whole-memory proof; possible aliases through
symbolic arguments expose private bytes and prevent their preservation.
Calls check targets, arguments, outgoing stack bytes, memory and x87 state,
then havoc public memory, volatile registers, flags and x87 state in common.
For call-free acyclic functions an exact finite-path alternative projects out
private stack bytes while retaining arbitrary aliases in the unified array.

Reads and writes update the arrays; they are not ordered observable events.
Array equality is checked at calls, returns and inductive block boundaries.
PE relocation is by independent names, reviewed aliases,
checked local CFG correspondences and typed constant objects. The
comparison is in this common address space, as for a relocated executable.
Unresolved addresses, instruction forms and control flow fail closed.
"""

import collections
import bisect
import dataclasses
import json
import pathlib
import random
import re
import struct
import sys
import time

sys.dont_write_bytecode = True
import match
import equiv_limits as limits
import equiv_cache as verdict_cache
import equiv_image as image_relation
from equiv_ownership import Ownership, outside, guarded, premise as ownership_premise, clone_ownership

try:
    import z3
except ImportError:
    sys.path.append(r'C:\Tools\pylib')
    import z3

z3.set_param('smt.random_seed', 0)
z3.set_param('sat.random_seed', 0)
z3.set_param('smt.arith.random_initial_value', False)
z3.set_param('parallel.enable', False)
z3.set_param('smt.threads', 1)

CS = match.capstone
X = CS.x86_const
REGS = ('eax', 'edx', 'ecx', 'ebx', 'esi', 'edi', 'ebp', 'esp')
FLAGS = ('cf', 'pf', 'af', 'zf', 'sf', 'of', 'df')
FP_OPS = frozenset(('fld fild fst fstp fist fistp fadd faddp fsub fsubp fsubr fsubrp '
                    'fmul fmulp fdiv fdivp fdivr fdivrp fxch fchs fabs fsqrt fld1 fldz '
                    'fldln2 fyl2x fcom fcomp fcompp fnstsw fnstcw fldcw wait').split())
INTEGER_OPS = frozenset(('nop mov movsx movzx lea xchg add adc sub sbb cmp inc dec and or xor test '
                         'not neg shl sal shr sar imul mul idiv div bound bt bts btr btc '
                         'push pop leave cdq cwde clc stc cld std sahf lahf call ret jmp').split())
STRING_OPS = frozenset(('rep movsd', 'rep movsb', 'rep stosd', 'rep stosb'))
BV32 = z3.BitVecSort(32)
BYTE = z3.BitVecSort(8)
MEM = z3.ArraySort(BV32, BYTE)
FP_BITS = 80 * 8 + 64
ALL = frozenset((a, b, lane) for a in REGS for b in REGS for lane in range(4))
DIAG = frozenset((a, a, lane) for a in REGS for lane in range(4))


def register_byte(state, reg, lane):
    return simp(z3.Extract(lane * 8 + 7, lane * 8, state.regs[reg]))


class Unsupported(Exception):
    pass


class NotProven(Exception):
    pass


def bv(v, bits=32):
    if z3.is_bv(v):
        return v if v.size() == bits else z3.Extract(bits-1, 0, v) if v.size() > bits else z3.ZeroExt(bits-v.size(), v)
    return z3.BitVecVal(v % (1 << bits), bits)


def simp(v):
    return z3.simplify(v)


def equal(a, b):
    return a.sort() == b.sort() and (z3.eq(a, b) or z3.is_true(simp(a == b)))


def equality(a, b):
    return a == b if a.sort() == b.sort() else z3.BoolVal(False)


def unhash(name):
    return re.sub(r'@[0-9A-Fa-f]{8}$', '', name)


def content_key(value):
    if not z3.is_expr(value):
        return repr(value)
    if not hasattr(value, '_order_key'):
        value._order_key = value.sexpr()
    return value._order_key

def ordered(values):
    values = list(values)
    return values if len(values) < 2 else sorted(values, key=content_key)

def conjunction(values):
    return z3.And(ordered(values))

def prove(expressions):
    expressions = [e for e in ordered(expressions) if not z3.is_true(simp(e))]
    if not expressions:
        return True
    s = z3.Solver()
    s.add(z3.Not(z3.And(expressions)))
    return limits.check(s, 'prove') == z3.unsat


def correspondence_failure(states, memories, tails, relations):
    """One bounded diagnostic query; no proof goals or premises are changed."""
    budget=limits.WorkBudget(1000,'diagnostic')
    items=[('H2 %s obligation fails at %s'%(kind,hex(pc)),goal,None) for st in states for pc,kind,goal in st.ownership.obligations]
    guard=ownership_premise(states)
    for n,(x,y) in enumerate(zip(states[0].events,states[1].events)):
        names = (['target','callee inputs/cleanup','context','context','ESP','memory','FS','FP'] if x[0]=='call' else
                 ['target','EAX','EDX','ESP','EBX','ESI','EDI','EBP','DF'] if x[0]=='return' else [])
        pc=getattr(states[0],'event_pcs',tails)[n]
        for k,(u,v) in enumerate(zip(x[1:],y[1:])):
            name=names[k] if k<len(names) else 'component %d'%(k+1)
            items.append(('%s event at %s differs: %s'%(x[0],hex(pc),name),z3.Implies(guard,equality(u,v)),(u,v)))
    for name,u,v in [('memory',*memories),('FS',states[0].fs,states[1].fs),('FP',states[0].fp,states[1].fp),('branch condition',states[0].condition,states[1].condition)]:
        items.append(('exit at %s differs: %s'%(hex(tails[0]),name),z3.Implies(guard,equality(u,v)),(u,v)))
    items += [('successor at %s differs: %s'%(hex(tails[0]),name),z3.Implies(guard,goal),None) for name,goal in relations]
    solver=z3.Solver();solver.add(z3.Not(conjunction([goal for _,goal,_ in items])))
    if limits.check(solver,'diagnostic')==z3.sat:
        witness=solver.model()
        for label,goal,pair in items:
            budget.step()
            if not z3.is_false(witness.eval(goal,model_completion=True)):continue
            if pair and all(z3.is_array(v) for v in pair):
                address=z3.FreshConst(BV32,'differing_address');solver.push()
                solver.add(guard,z3.Select(pair[0],address)!=z3.Select(pair[1],address))
                if limits.check(solver,'diagnostic_address')==z3.sat:label+=' at '+hex(solver.model().eval(address,model_completion=True).as_long())
            return label
    return 'diagnostic budget at %s: failed transition; no differing component established'%hex(tails[0])


def conditional_facts(guard, equations):
    """Houdini's candidate filter, with one solver model removing many facts.

    Timeouts and the model budget discard unproved candidates. They never
    turn a satisfiable/unknown result into a proof.
    """
    if z3.is_false(simp(guard)):
        return set(equations)
    if not equations:
        return set()
    remaining = {key: equations[key] for key in sorted(equations,key=repr)}
    solver = z3.Solver()
    solver.add(guard)
    for _ in range(4):
        solver.push()
        solver.add(z3.Not(z3.And([remaining[k] for k in ordered(remaining)])))
        answer = limits.check(solver, 'filter')
        if answer == z3.unsat:
            solver.pop()
            return set(remaining)
        if answer != z3.sat:
            solver.pop()
            return set()
        model = solver.model()
        removed = [key for key, expr in remaining.items() if z3.is_false(model.eval(expr, model_completion=True))]
        solver.pop()
        if not removed:
            return set()
        for key in removed:
            del remaining[key]
        if not remaining:
            return set()
    return set()


@dataclasses.dataclass
class Function:
    name: str
    original_name: str
    ova: int
    osize: int
    nva: int
    nsize: int
    a: list
    b: list

    @property
    def differs(self):
        return match.compare(self.a, self.b) != -1


class Inputs:
    """Keep match.py's function selection, truncation and normalization intact."""
    def __init__(self, argv):
        argv = list(argv)
        self.cache_dir = None; self.cache_files = set()
        aliases = {}
        alias_dirs = set()
        units = []
        self.mutate = 0
        self.show = None
        self.explain = False
        self.data_aliases = []
        while argv and argv[0].startswith('--'):
            opt = argv.pop(0)
            if opt == '--quiet':
                continue
            elif opt == '--cache':
                self.cache_dir = pathlib.Path(argv.pop(0))
            elif opt == '--mutate':
                self.mutate = int(argv.pop(0))
                if self.mutate < 0:
                    raise ValueError('--mutate must be nonnegative')
            elif opt == '--explain':
                self.explain = True
            elif opt == '--data-alias':
                self.data_aliases.append(pathlib.Path(argv.pop(0)))
                self.cache_files.add(self.data_aliases[-1])
            elif opt == '--show':
                self.show = argv.pop(0)
            elif opt == '--alias':
                alias_path = pathlib.Path(argv.pop(0))
                self.cache_files.add(alias_path)
                alias_dirs.add(alias_path.parent)
                with open(alias_path, encoding='utf-8') as f:
                    aliases.update(json.load(f))
            elif opt == '--units':
                units += argv.pop(0).split(',')
            else:
                raise ValueError('unknown option ' + opt)
        if len(argv) < 4:
            raise ValueError('usage: equiv.py [match options] [--mutate N] exe map original signatures [classes ...]')
        exe, mapf, orig, sigf, *classes = argv
        self.cache_files.update(map(pathlib.Path,(mapf,sigf)))
        self.original_path = pathlib.Path(orig)
        self.old, self.new = match.Image(orig), match.Image(exe)
        self.image_paths = (pathlib.Path(orig), pathlib.Path(exe))
        self.syms, _ = match.map_symbols(mapf)
        # Only an explicit per-symbol length is a size; never the next public.
        self.map_sizes = image_relation.map_sizes(pathlib.Path(mapf).read_text(encoding='latin1'),self.syms)
        with open(sigf, encoding='utf-8') as f:
            self.sigs = {fn['name'].split('@')[0]: (int(fn['addr'], 16), fn['size']) for fn in json.load(f)}
        self.text = self.new.base + self.new.pe.sections[0].VirtualAddress
        self.code_syms = sorted((off, n) for n, locs in self.syms.items() for seg, off in locs if seg == '0001')
        self.code_offsets = sorted(set(o for o, _ in self.code_syms))
        pairs = []
        aliased = set(aliases.values())
        alias_addrs = {int(k.split(':')[0], 16) for k in aliases if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', k)}
        for spec in classes:
            oc, _, nc = spec.partition('=')
            nc = nc or oc
            for off, name in self.code_syms:
                if not name.startswith(nc + '.') or name in aliased:
                    continue
                method = name[len(nc) + 1:]
                on = None
                for k in self.sigs:
                    if k == oc + '.' + method or k.endswith('.' + oc + '.' + method):
                        on = k
                if on is not None and self.sigs[on][0] in alias_addrs:
                    continue
                pairs.append((name, on))
        for unit in units:
            for k in sorted(self.sigs, key=lambda k: self.sigs[k][0]):
                ps = k.split('.')
                if (len(ps) == 2 and ps[0] == unit and ps[1] in self.syms
                        and ps[1] not in aliased and k not in aliases
                        and ps[1] not in (unit, 'Finalization')):
                    pairs.append((ps[1], k))
        for on, name in aliases.items():
            if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', on):
                addr, size = on.split(':')
                self.sigs[on] = (int(addr, 16), int(size))
            pairs.append((name, on if on in self.sigs else None))
        self.pairs = pairs
        md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
        oe = match.find_import_thunk(self.old, 'System.@HandleOnException')
        ne = self.text + self.syms['@HandleOnException'][0][1] if '@HandleOnException' in self.syms else None
        self.functions = []
        for name, on in pairs:
            loc = match.resolve(self.syms, name)
            if on is None or loc is None:
                continue
            ova, osize = self.sigs[on]
            seg, off = loc
            nva = self.text + off
            nxt = min((o for o in self.code_offsets if o > off), default=off + osize + 64)
            nsize = nxt - off
            a = match.disasm_skipping_tables(md, self.old, ova, osize, oe)
            b = match.disasm_skipping_tables(md, self.new, nva, min(nsize, osize + 32), ne)[:len(a)]
            self.functions.append(Function(name, on, ova, osize, nva, nsize, a, b))
        # Address evidence belongs to the module, not to the selected report
        # group. Include all resolvable signatures and all module alias files.
        module_aliases = {}
        for directory in sorted(alias_dirs):
            for path in sorted(directory.glob('*.json')):
                self.cache_files.add(path)
                with open(path, encoding='utf-8') as f:
                    module_aliases.update(json.load(f))
        module_aliases.update(aliases)
        module_pairs = set(pairs)
        for on in self.sigs:
            name = on.split('.', 1)[-1]
            if name in self.syms and on not in module_aliases:
                module_pairs.add((name, on))
        for on, name in module_aliases.items():
            if re.fullmatch(r'[0-9a-fA-F]{8}:\d+', on):
                addr, size = on.split(':')
                self.sigs.setdefault(on, (int(addr, 16), int(size)))
            if on in self.sigs:
                module_pairs.add((name, on))
        self.module_matches = []  # MATCH positions are not identity evidence.
        self.addresses = Addresses(self)


class Addresses:
    """A partial, injective relocation, anchored in independent symbol names."""
    def __init__(self, inp):
        self.inp = inp
        self.routes = []
        self.old, self.new = inp.old, inp.new
        self.forward = {}
        self.provenance = {}
        self.consulted = set()
        self.pointer_cells = [{}, {}]
        self.immutable_data = [{}, {}]
        self.storage_objects = []
        self.pointee_symbols = [{}, {}]
        self.allow_local_cfg = True
        self.unresolved = set()
        self.binding_source = 'independent-name'
        self.reverse = {}
        self.conflicts = set()
        self.names = [{}, {}]
        self.relocs = []
        self.sorted_relocs = []
        self.imports = []
        self.import_bytes = []
        self.import_locations = []
        self.vmts = []
        for side, img in enumerate((self.old, self.new)):
            match.parse_imports_once(img)
            img.pe.parse_data_directories(directories=[
                match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT'],
                match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_BASERELOC']])
            imps = {}
            identities = {}
            for e in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
                for i in e.imports:
                    identities[i.address] = (e.dll.lower(), ('name', bytes(i.name)) if i.name else ('ordinal', i.ordinal))
                    if i.name:
                        name = unhash(i.name.decode('latin1'))
                        imps[i.address] = name
                        self.names[side][i.address] = 'iat:' + name
            self.imports.append(imps)
            self.import_bytes.append({a + k for a in identities for k in range(4)})
            self.import_locations.append(identities)
            for e in getattr(getattr(img.pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []):
                if e.name:
                    self.names[side][img.base + e.address] = unhash(e.name.decode('latin1'))
            rel = {img.base + e.rva for b in getattr(img.pe, 'DIRECTORY_ENTRY_BASERELOC', []) for e in b.entries if e.type == 3}
            self.relocs.append(rel)
            self.sorted_relocs.append(sorted(rel))
            # Import thunks are named code, not arbitrary masked call addresses.
            for cell, name in imps.items():
                pat = b'\xff\x25' + struct.pack('<I', cell)
                start = 0
                while True:
                    pos = img.data.find(pat, start)
                    if pos < 0:
                        break
                    self.names[side][img.base + pos] = name
                    identities[img.base + pos] = identities[cell]
                    start = pos + 1
            vmts = {}
            for pos in sorted(rel):
                v = self.u32(img, pos)
                if v != pos + 64 or not img.contains(v):
                    continue
                cn = self.u32(img, v - 32)
                if not img.contains(cn):
                    continue
                data = img.bytes_at(cn, 65)
                if data and 0 < data[0] <= 64:
                    name = data[1:1 + data[0]]
                    if re.fullmatch(rb'[A-Za-z_]\w*', name):
                        vmts[v] = name.decode('ascii')
                        self.names[side][v] = 'vmt:' + name.decode('ascii')
                        self.names[side][v - 64] = 'vmtref:' + name.decode('ascii')
            self.vmts.append(vmts)
        # MAP segment 2 is relative to DATA (including its aligned BSS offsets).
        data = next((s for s in self.new.pe.sections if s.Name.rstrip(b'\0') in (b'DATA', b'.data')), None)
        self.map_addresses = {}
        for name, locs in inp.syms.items():
            addresses = []
            for seg, off in locs:
                if seg == '0001':
                    addresses.append(inp.text + off)
                elif seg == '0002' and data is not None:
                    addresses.append(self.new.base + data.VirtualAddress + off)
            if len(set(addresses)) == 1:
                self.map_addresses[name] = addresses[0]
        # Original signatures and PE exports carry unit-qualified names; MAP
        # symbols usually omit the unit.  Ambiguous short names are rejected.
        old_names = dict(self.names[0])
        old_names.update({a: n for n, (a, _) in inp.sigs.items() if not n.startswith('FUN_')})
        for addr, name in old_names.items():
            if name.startswith('iat:'):
                continue
            candidates = []
            for key in (name, name.split('.', 1)[-1], name.rsplit('.', 1)[-1]):
                if key in self.map_addresses:
                    candidates.append(self.map_addresses[key])
                    break
            if len(set(candidates)) == 1:
                self.bind(addr, candidates[0])
        self.binding_source = 'declared-function-pair'
        for f in inp.functions:
            self.bind(f.ova, f.nva)
        self.binding_source = 'independent-name'
        by_name = collections.defaultdict(list)
        for a, n in self.names[1].items():
            by_name[n].append(a)
        for a, n in self.names[0].items():
            if len(by_name[n]) == 1:
                self.bind(a, by_name[n][0])
        # Relocated pointer cells can be independently identified by the named
        # object they refer to.  Do not collapse multiple cells with one value.
        self.binding_source = 'unique-relocated-cell'
        for _ in range(3):
            old_cells, new_cells = collections.defaultdict(list), collections.defaultdict(list)
            for side, img, cells in ((0, self.old, old_cells), (1, self.new, new_cells)):
                for a in self.relocs[side]:
                    v = self.u32(img, a)
                    if side == 1:
                        v = self.reverse.get(v)
                    elif v not in self.forward:
                        v = None
                    if v is not None:
                        cells[v].append(a)
            for key, aa in old_cells.items():
                bb = new_cells.get(key, [])
                if len(aa) == len(bb) == 1:
                    self.bind(aa[0], bb[0])
        self.install_content()
        for name,size in sorted(getattr(inp,'map_sizes',{}).items()):
            b = self.map_addresses.get(name); a = self.reverse.get(b)
            if a is not None and 0 < size <= 65536 and self.readonly(1,b,size):
                self.storage_objects.append((a,b,size,'immutable-data','explicit MAP symbol size:'+name))
        from equiv_records import load_aliases
        for path in getattr(inp, 'data_aliases', ()):
            for a, b, size, record in load_aliases(path, inp, self):
                for offset in range(size):
                    if not self.bind(a + offset, b + offset, 'reviewed-data:' + record):
                        raise ValueError('reviewed alias conflicts with existing binding')

    def content_records(self, side):
        """Typed immutable objects and loader identities, indexed by contents.

        Class identities follow Delphi 3's documented VMT / TTypeInfo layout.
        Literal bytes must have the immutable AnsiString header and contain no
        relocations. An object with duplicate identities is never guessed.
        """
        img = (self.old, self.new)[side]
        records = collections.defaultdict(set)
        for section in img.pe.sections:
            if section.Characteristics & 0x80000000:
                continue
            lo = img.base + section.VirtualAddress
            data = img.bytes_at(lo, section.Misc_VirtualSize)
            pos = 0
            while True:
                pos = data.find(b'\xff\xff\xff\xff', pos)
                if pos < 0:
                    break
                address = lo + pos + 8
                payload = self.string_object(side, address)
                if payload is not None:
                    records['string', payload].add(address)
                pos += 1
        for vmt, name in self.vmts[side].items():
            # An independently established VMT pair disambiguates duplicate
            # short class names. Do not invent an owner from address order.
            other = self.forward.get(vmt) if side == 0 else self.reverse.get(vmt)
            identity = ('paired-class', vmt if side == 0 else other) if other is not None and self.vmts[1-side].get(other) == name else ('class-name', name)
            # All fixed VMT header fields denote locations in the same named
            # record; their values are still interpreted and compared normally.
            for off in range(-64, 1, 4):
                records['vmt-field', identity, off].add(vmt + off)
            cn = self.u32(img, vmt - 32)
            data = img.bytes_at(cn, len(name) + 1)
            if data == bytes((len(name),)) + name.encode('ascii'):
                for off in range(len(data)):
                    records['class-name', identity, off].add(cn + off)
            info = self.u32(img, vmt - 48)
            n = len(name)
            if not self.readonly(side, info, 2 + n + 4):
                continue
            data = img.bytes_at(info, n + 2)
            # tkClass = 7; TypeData immediately follows the short type name,
            # and its first field is the owning class reference.
            if data != bytes((7, n)) + name.encode('ascii') or self.u32(img, info + n + 2) != vmt:
                continue
            for off in range(n + 2):
                records['class-typeinfo', identity, off].add(info + off)
            for off in (n + 2, n + 6, n + 10, n + 12):
                records['class-typeinfo-field', identity, off].add(info + off)
        for entry in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
            for imp in entry.imports:
                name = (entry.dll.lower(), ('name', bytes(imp.name)) if imp.name else ('ordinal', imp.ordinal))
                for off in range(4):
                    records['import-cell', name, off].add(imp.address + off)
                pattern = b'\xff\x25' + struct.pack('<I', imp.address)
                for section in img.pe.sections:
                    if not section.Characteristics & 0x20000000:
                        continue
                    lo = img.base + section.VirtualAddress
                    data = img.bytes_at(lo, section.Misc_VirtualSize)
                    pos = 0
                    while True:
                        pos = data.find(pattern, pos)
                        if pos < 0:
                            break
                        records['import-thunk', name].add(lo + pos)
                        if hasattr(self, 'import_locations'):
                            self.import_locations[side][lo + pos] = name
                        pos += 1
        from equiv_metadata import records as metadata_records
        metadata_records(self, side, records)
        return records

    def install_content(self):
        records = [self.content_records(s) for s in (0, 1)]
        for _ in range(3):
            evidence = []
            for key, aa in records[0].items():
                bb = records[1].get(key, set())
                established = {(a, self.forward[a]) for a in aa if a in self.forward and self.forward[a] in bb and self.reverse.get(self.forward[a]) == a}
                left = aa - {a for a, _ in established}
                right = set(bb) - {b for _, b in established}
                if len(left) == len(right) == 1:
                    established.add((next(iter(left)), next(iter(right))))
                evidence.extend(established)
                if key[0] == 'vmt-field' and key[2] == -64:
                    for a,b in established:self.storage_objects.append((a,b,64,'immutable-data','Delphi VMT fixed header'))
                if key[0] == 'class-name' and key[2] == 0:
                    for a,b in established:
                        n = self.old.bytes_at(a,1)[0]+1
                        self.storage_objects.append((a,b,n,'immutable-data','Delphi class short string'))
                if key[0] == 'class-typeinfo' and key[2] == 0:
                    for a,b in established:
                        n = self.old.bytes_at(a+1,1)[0]+12
                        self.storage_objects.append((a,b,n,'immutable-data','Delphi class typeinfo fixed header'))
                if key[0] == 'primitive-typeinfo':
                    for a,b in established:self.storage_objects.append((a,b,key[2],'immutable-data','primitive typeinfo:'+key[1]))
                if key[0] == 'named-typeinfo-cell':
                    for a,b in established:self.storage_objects.append((a,b,4,'immutable-data','named typeinfo cell:'+key[1]))
                if key[0] == 'class-slot':
                    for a,b in established:
                        if key[3] > 0:self.storage_objects.append((a,b,key[3],'immutable-data','class %s, slot %s' % (key[1],key[2])))
                if key[0] == 'string':
                    # Preserve offsets, including interior / header pointers.
                    for a, b in established:
                        self.storage_objects.append((a-8,b-8,len(key[1])+8,'immutable-data','AnsiString header'))
                        evidence.extend((a + off, b + off) for off in range(-8, len(key[1])))
            before = len(self.forward)
            self.install_consistent(evidence, 'typed-content-record')
            if len(self.forward) == before:
                break
        # A newly identified class/type/string can also identify a unique
        # relocated cell pointing to it. Reject duplicates on both sides.
        for _ in range(3):
            cells = [collections.defaultdict(set), collections.defaultdict(set)]
            for side, img in enumerate((self.old, self.new)):
                for address in self.relocs[side]:
                    value = self.u32(img, address)
                    identity = value if side == 0 and value in self.forward else self.reverse.get(value) if side == 1 else None
                    if identity is not None:
                        cells[side][identity].add(address)
            self.install_consistent(((next(iter(aa)), next(iter(cells[1][key])))
                                    for key, aa in cells[0].items()
                                    if len(aa) == len(cells[1].get(key, ())) == 1), source='unique-relocated-cell')

    def absolute(self, side, ins, op):
        if op.type == X.X86_OP_IMM:
            relocated = ins.address + ins.raw.imm_offset in self.relocs[side]
            if not relocated and not (ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j')):
                return None
            v = op.imm & 0xffffffff
        elif op.type == X.X86_OP_MEM and not op.mem.segment:
            relocated = ins.address + ins.raw.disp_offset in self.relocs[side]
            if not relocated and (op.mem.base or op.mem.index):
                return None
            v = op.mem.disp & 0xffffffff
        else:
            return None
        return v if (self.old, self.new)[side].contains(v) else None

    def install_consistent(self, pairs, source=None):
        forward, reverse = collections.defaultdict(set), collections.defaultdict(set)
        for a, b in pairs:
            forward[a].add(b)
            reverse[b].add(a)
        for a, bs in forward.items():
            if len(bs) != 1:
                continue
            b = next(iter(bs))
            if len(reverse[b]) != 1:
                continue
            if a in self.forward and self.forward[a] != b or b in self.reverse and self.reverse[b] != a:
                continue
            self.bind(a, b, source)

    @staticmethod
    def u32(img, a):
        b = img.bytes_at(a, 4)
        return struct.unpack('<I', b)[0] if len(b) == 4 else 0

    def bind(self, a, b, source=None):
        imports = getattr(self, 'import_locations', ({}, {}))
        if a in imports[0] and b in imports[1] and imports[0][a] != imports[1][b]:
            return False
        if (a in self.forward and self.forward[a] != b) or (b in self.reverse and self.reverse[b] != a):
            self.conflicts.add(a)
            self.conflicts.add(b)
            return False
        self.forward[a] = b
        self.reverse[b] = a
        self.provenance.setdefault((a, b), source or self.binding_source)
        return True

    def protected(self, side):
        return {**{a:4 for a in self.pointer_cells[side]}, **self.immutable_data[side]}

    def import_pointee(self, anchor, target, original_cell):
        # The disk IAT word is an RVA, never the runtime address of the global.
        # A scoped loader symbol is a shared symbolic address, not cell storage.
        import hashlib
        symbol = z3.BitVec('import_pointee_' + hashlib.sha256(repr(anchor).encode()).hexdigest(),32)
        if target in self.reverse:
            raise ValueError('import pointee conflicts with an existing storage identity')
        evidence = (original_cell,target,'independent-name:pointee:' + anchor[1] + ':' + anchor[2])
        for side,key in ((0,anchor),(1,target)):
            previous = self.pointee_symbols[side].get(key)
            if previous is not None and not z3.eq(previous[0],symbol):
                raise ValueError('conflicting named import pointee')
            self.pointee_symbols[side][key] = symbol,evidence

    def canonical(self, side, value, local):
        if value in self.pointee_symbols[side]:
            symbol, evidence = self.pointee_symbols[side][value]
            self.consulted.add(evidence)
            return symbol
        value &= 0xffffffff
        img = (self.old, self.new)[side]
        if not img.contains(value):
            return value
        if value in self.conflicts:
            raise Unsupported('ambiguous relocation')
        if side == 0 and value in self.forward:
            self.consulted.add((value, self.forward[value], self.provenance[value, self.forward[value]]))
            if not self.allow_local_cfg and self.provenance[value,self.forward[value]] == 'local-cfg':
                raise Unsupported('local-cfg identity requires its structural proof route')
            return value
        if side == 1 and value in self.reverse:
            a = self.reverse[value]
            self.consulted.add((a, value, self.provenance[a, value]))
            if not self.allow_local_cfg and self.provenance[a,value] == 'local-cfg':
                raise Unsupported('local-cfg identity requires its structural proof route')
            return self.reverse[value]
        self.unresolved.add((side, value))
        raise Unsupported('unresolved image address 0x%x (no independent identity)' % value)

    def readonly(self, side, addr, size):
        if any(a <= addr and addr+size <= a+n for a,n in self.immutable_data[side].items()):
            return True
        img = (self.old, self.new)[side]
        for sec in img.pe.sections:
            lo = img.base + sec.VirtualAddress
            hi = lo + sec.Misc_VirtualSize
            if lo <= addr and addr + size <= hi:
                return not sec.Characteristics & 0x80000000
        return False

    def read_constant(self, side, addr, size, local):
        if not self.readonly(side, addr, size):
            return None
        self.canonical(side, addr, local)  # Folding bytes must not bypass identity.
        relocations = self.sorted_relocs[side]
        overlap = relocations[bisect.bisect_left(relocations, addr - 3):bisect.bisect_left(relocations, addr + size)]
        img = (self.old, self.new)[side]
        if not overlap:
            data = img.bytes_at(addr, size)
            return bv(int.from_bytes(data, 'little'), size * 8)
        if size == 4 and overlap == [addr]:
            return bv(self.canonical(side, self.u32(img, addr), local))
        raise Unsupported('partial relocated constant')

    def pointer_identity(self, side, addr):
        if addr not in self.relocs[side]:
            return None
        img = (self.old, self.new)[side]
        target = self.u32(img, addr)
        if side == 0 and target in self.forward:
            return ('pointer', target)
        if side == 1 and target in self.reverse:
            return ('pointer', self.reverse[target])
        return None

    def string_object(self, side, addr):
        img = (self.old, self.new)[side]
        if not self.readonly(side, addr - 8, 8):
            return None
        refcount, length = struct.unpack('<II', img.bytes_at(addr - 8, 8))
        if refcount != 0xffffffff or length > 65536 or not self.readonly(side, addr, length + 1):
            return None
        data = img.bytes_at(addr, length + 1)
        if len(data) != length + 1 or data[-1] != 0:
            return None
        rel = self.sorted_relocs[side]
        index = bisect.bisect_left(rel, addr - 8)
        if index < len(rel) and rel[index] < addr + length + 1:
            return None
        return data


@dataclasses.dataclass
class MemoryOperand:
    base: int
    index: int
    scale: int
    disp: int
    segment: int


@dataclasses.dataclass
class Operand:
    type: int
    size: int
    reg: int
    imm: int
    mem: MemoryOperand

    @classmethod
    def from_capstone(cls, op):
        m = op.mem
        return cls(op.type, op.size, op.reg, op.imm, MemoryOperand(m.base, m.index, m.scale, m.disp, m.segment))


@dataclasses.dataclass
class Insn:
    address: int
    size: int
    mnemonic: str
    op_str: str
    operands: list
    raw: object
    mutation: str = ''
    flow: object = None
    eh: tuple = ()
    handler_return: bool = False

    def reg_name(self, reg):
        return self.raw.reg_name(reg)


def decode(img, start, size, on_exception=None):
    md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
    md.detail = True
    result, pos = [], start
    end = start + size
    while pos < end:
        for i in md.disasm(verdict_cache.raw(img,pos,end-pos), pos):
            result.append(Insn(i.address, i.size, i.mnemonic, i.op_str, [Operand.from_capstone(o) for o in i.operands], i))
            pos = i.address + i.size
            if i.mnemonic == 'jmp' and i.operands[0].type == X.X86_OP_IMM and i.operands[0].imm == on_exception:
                if pos + 4 > end:
                    raise Unsupported('truncated exception table')
                n = Addresses.u32(img, pos)
                if not 0 < n < 16 or pos + 4 + 8 * n > end:
                    raise Unsupported('invalid / truncated exception table')
                pos += 4 + 8 * n
                break
        else:
            break
    return result


ALIASES = {}
for root in REGS:
    names = (root, root[1:])
    for name, bits in zip(names, (32, 16)):
        ALIASES[name] = (root, bits, 0)
for root in ('eax', 'ebx', 'ecx', 'edx'):
    ALIASES[root[1] + 'l'] = (root, 8, 0)
    ALIASES[root[1] + 'h'] = (root, 8, 8)


class State:
    @property
    def memory(self):
        relation = image_relation.ACTIVE
        return relation.overlay(self._memory) if relation is not None else self._memory

    @memory.setter
    def memory(self, value):
        self._memory = value

    def __init__(self, regs, flags, memory, fs, fp):
        self.regs, self.flags, self.memory, self.fs, self.fp = regs, flags, memory, fs, fp
        self.events = []
        self.condition = z3.BoolVal(True)

    def reg(self, name):
        if name not in ALIASES:
            raise Unsupported('register ' + name)
        root, bits, off = ALIASES[name]
        v = self.regs[root]
        return v if bits == 32 else z3.Extract(off + bits - 1, off, v)

    def putreg(self, name, value):
        if name not in ALIASES:
            raise Unsupported('register ' + name)
        root, bits, off = ALIASES[name]
        if value.size() != bits:
            raise Unsupported('register width')
        if bits == 32:
            self.regs[root] = simp(value)
        else:
            v = self.regs[root]
            parts = []
            if off + bits < 32:
                parts.append(z3.Extract(31, off + bits, v))
            parts.append(value)
            if off:
                parts.append(z3.Extract(off - 1, 0, v))
            self.regs[root] = simp(z3.Concat(parts))

    def load(self, addr, size, fs=False):
        mem = self.fs if fs else self.memory
        value = simp(z3.Concat([z3.Select(mem, addr + bv(i)) for i in reversed(range(size))])) if size > 1 else z3.Select(mem, addr)
        if hasattr(self, "ownership") and not fs:self.ownership.load(self,addr,size,value)
        return value

    def store(self, addr, value, fs=False):
        if hasattr(self, 'cell_guard'):
            self.cell_guard(addr, value.size() // 8, fs)
        if hasattr(self, 'ownership') and not getattr(self,'ownership_internal',False):
            self.ownership.store(self,addr,value)
        mem = self.fs if fs else self.memory
        for i in range(value.size() // 8):
            mem = z3.Store(mem, simp(addr + bv(i)), z3.Extract(i * 8 + 7, i * 8, value))
        if fs:
            self.fs = simp(mem)
        else:
            self.memory = simp(mem)


def arbitrary(candidates, flag_candidates):
    parent = {(s, r, lane): (s, r, lane) for s in (0, 1) for r in REGS for lane in range(4)}

    def find(x):
        while parent[x] != x:
            x = parent[x]
        return x

    for a, b, lane in sorted(candidates):
        parent[find((1, b, lane))] = find((0, a, lane))
    values = {}
    regs = []
    for s in (0, 1):
        rr = {}
        for r in REGS:
            parts = []
            for lane in reversed(range(4)):
                key = find((s, r, lane))
                parts.append(values.setdefault(key, z3.BitVec('r_%s_%s_%s' % key, 8)))
            rr[r] = z3.Concat(parts)
        regs.append(rr)
    ff = []
    for s in (0, 1):
        ff.append({f: z3.Bool('f_%d_%s' % (0 if f in flag_candidates else s, f)) for f in FLAGS})
        ff[-1]['df'] = z3.BoolVal(False)  # Ordinary entry; ABI gate rejects all DF-setting code.
    memory = z3.Array('memory', BV32, BYTE)
    fs = z3.Array('fs_memory', BV32, BYTE)
    # An opaque x87 machine includes the 80-bit stack and control/status state.
    fp = z3.BitVec('x87_machine', 80 * 8 + 64)
    return [State(regs[s], ff[s], memory, fs, fp) for s in (0, 1)]


class Machine:
    def guard_pointer_cells(self, address, size, fs=False):
        concrete = simp(address)
        if not fs and z3.is_bv_value(concrete):
            for cell,width in self.addresses.protected(self.side).items():
                canonical_cell = cell if self.side == 0 else self.addresses.reverse.get(cell,cell)
                if any((concrete.as_long()+i) & 0xffffffff == (canonical_cell+k) & 0xffffffff
                       for i in range(size) for k in range(width)):
                    raise Unsupported('write to accepted pointer cell 0x%x' % cell)
        if fs and getattr(self.addresses, 'active_cells', ((),()))[self.side]:
            raise Unsupported('FS write may alias accepted pointer cell (segment relation unproved)')
        for cell in sorted(getattr(self.addresses, 'active_cells', ((),()))[self.side]):
            canonical_cell = cell if self.side == 0 else self.addresses.reverse.get(cell, cell)
            if not prove([z3.And(*(address+bv(i) != bv(canonical_cell+k)
                                  for i in range(size) for k in range(self.addresses.protected(self.side)[cell])))]):
                contracts = getattr(self.addresses,'call_contracts',None)
                if contracts is None:
                    raise Unsupported('immutable storage separation contract not prepared')
                contracts.h5.add((self.side,hex(getattr(self,'current_pc',0)),hex(cell),
                                  self.addresses.protected(self.side)[cell],size,address.sexpr()))

    def __init__(self, addresses, side, local):
        self.addresses, self.side, self.local = addresses, side, local
        if not hasattr(addresses, '_dynamic_targets'):
            def dynamic(name):
                return name.rsplit('.', 1)[-1].lower().startswith(('@calldyna', '@finddyna'))
            names = getattr(addresses, 'names', ({}, {}))
            addresses._dynamic_targets = [{a for a, n in names[s].items() if dynamic(n)} for s in (0, 1)]
            addresses._dynamic_targets[1].update(a for n, a in getattr(addresses, 'map_addresses', {}).items() if dynamic(n))
            imports = getattr(addresses, 'imports', ({}, {}))
            addresses._dynamic_cells = [{a for a, n in imports[s].items() if dynamic(n)} for s in (0, 1)]
        self.dynamic_targets = addresses._dynamic_targets[side]
        self.dynamic_cells = addresses._dynamic_cells[side]

    def constant(self, v, bits=32):
        return bv(self.addresses.canonical(self.side, v, self.local), bits)

    def address(self, st, ins, op):
        m = op.mem
        if m.segment and ins.reg_name(m.segment) != 'fs' and not (ins.mnemonic in STRING_OPS and ins.reg_name(m.segment) == 'es'):
            raise Unsupported('segment override ' + ins.reg_name(m.segment))
        addr = bv(0)
        if m.base:
            addr += st.reg(ins.reg_name(m.base))
        if m.index:
            addr += st.reg(ins.reg_name(m.index)) * bv(m.scale)
        # PE relocation metadata, not numerical magnitude, distinguishes
        # relocated globals in [base+disp]/[index*scale+disp] from field offsets.
        if self.addresses.absolute(self.side, ins, op) is not None:
            addr += self.constant(m.disp)
        else:
            addr += bv(m.disp)
        addr=simp(addr)
        relation = image_relation.ACTIVE
        if relation is not None and not m.segment and ins.mnemonic != 'lea':
            roots = set()
            for reg in (m.base,m.index):
                if reg: roots.update(getattr(st,'image_origins',{}).get(ins.reg_name(reg),()))
            v = self.addresses.absolute(self.side,ins,op)
            if v is not None and not relation.code(self.side,v):
                row = relation.root(self.side,v)
                if row: roots.add(row)
            relation.access(st,self.side,addr,op.size,roots)
        if hasattr(st,"ownership"):st.ownership.address(addr)
        return addr

    def read(self, st, ins, op):
        if op.type == X.X86_OP_REG:
            return st.reg(ins.reg_name(op.reg))
        if op.type == X.X86_OP_IMM:
            relocated = ins.address + ins.raw.imm_offset in self.addresses.relocs[self.side]
            if relocated or ins.mnemonic in ('call', 'jmp') or ins.mnemonic.startswith('j'):
                return self.constant(op.imm, op.size * 8)
            return bv(op.imm, op.size * 8)
        if op.type == X.X86_OP_MEM:
            if not op.mem.base and not op.mem.index and not op.mem.segment:
                cells = self.addresses.pointer_cells[self.side]
                if op.mem.disp in cells and op.size == 4:
                    pointee, record = cells[op.mem.disp]
                    self.addresses.consulted.add((op.mem.disp, op.mem.disp, 'pointer-cell:' + record))
                    return self.constant(pointee)
                imports = getattr(self.addresses, 'import_bytes', ((), ()))[self.side]
                # On-disk IAT words are loader RVAs, not the runtime function
                # pointers. Read the paired symbolic cell, so intervening or
                # aliased writes also remain visible to indirect calls.
                if image_relation.ACTIVE is None and not any(op.mem.disp + k in imports for k in range(op.size)):
                    constant = self.addresses.read_constant(self.side, op.mem.disp, op.size, self.local)
                    if constant is not None:
                        return constant
            return st.load(self.address(st, ins, op), op.size, bool(op.mem.segment and ins.reg_name(op.mem.segment) == 'fs'))
        raise Unsupported('operand form')

    def write(self, st, ins, op, value):
        if op.type == X.X86_OP_REG:
            st.putreg(ins.reg_name(op.reg), value)
        elif op.type == X.X86_OP_MEM:
            if not (op.mem.segment or op.mem.base or op.mem.index) and self.addresses.readonly(self.side, op.mem.disp, op.size):
                raise Unsupported('write to executable / read-only image')
            st.store(self.address(st, ins, op), value, bool(op.mem.segment and ins.reg_name(op.mem.segment) == 'fs'))
            if ins.eh:
                st.events.append(('frame-install', *(self.constant(v) for v in ins.eh)))
        else:
            raise Unsupported('destination form')

    @staticmethod
    def common_flags(st, result):
        bits = result.size()
        st.flags['zf'] = result == bv(0, bits)
        st.flags['sf'] = z3.Extract(bits - 1, bits - 1, result) == bv(1, 1)
        byte = z3.Extract(7, 0, result)
        parity = z3.BoolVal(False)
        for i in range(8):
            parity = z3.Xor(parity, z3.Extract(i, i, byte) == bv(1, 1))
        st.flags['pf'] = z3.Not(parity)

    def arithmetic(self, st, op, a, b):
        bits = a.size()
        if op in ('add', 'adc', 'inc'):
            carry = z3.If(st.flags['cf'], bv(1, bits), bv(0, bits)) if op == 'adc' else bv(0, bits)
            r = a + b + carry
            ext = z3.ZeroExt(1, a) + z3.ZeroExt(1, b) + z3.ZeroExt(1, carry)
            cf = z3.Extract(bits, bits, ext) == bv(1, 1)
            of = z3.Extract(bits - 1, bits - 1, (~(a ^ b)) & (a ^ r)) == bv(1, 1)
        else:
            carry = z3.If(st.flags['cf'], bv(1, bits), bv(0, bits)) if op == 'sbb' else bv(0, bits)
            r = a - b - carry
            cf = z3.ULT(z3.ZeroExt(1, a), z3.ZeroExt(1, b) + z3.ZeroExt(1, carry))
            of = z3.Extract(bits - 1, bits - 1, (a ^ b) & (a ^ r)) == bv(1, 1)
        self.common_flags(st, r)
        st.flags['of'] = of
        st.flags['af'] = z3.Extract(4, 4, a ^ b ^ r) == bv(1, 1)
        if op not in ('inc', 'dec'):
            st.flags['cf'] = cf
        return simp(r)

    @staticmethod
    def condition(st, suffix):
        f = st.flags
        conditions = {
            'e': f['zf'], 'z': f['zf'], 'ne': z3.Not(f['zf']), 'nz': z3.Not(f['zf']),
            'b': f['cf'], 'c': f['cf'], 'nae': f['cf'],
            'ae': z3.Not(f['cf']), 'nb': z3.Not(f['cf']), 'nc': z3.Not(f['cf']),
            'be': z3.Or(f['cf'], f['zf']), 'a': z3.And(z3.Not(f['cf']), z3.Not(f['zf'])),
            'l': f['sf'] != f['of'], 'ge': f['sf'] == f['of'],
            'le': z3.Or(f['zf'], f['sf'] != f['of']), 'g': z3.And(z3.Not(f['zf']), f['sf'] == f['of']),
            'o': f['of'], 'no': z3.Not(f['of']), 's': f['sf'], 'ns': z3.Not(f['sf']),
            'p': f['pf'], 'pe': f['pf'], 'np': z3.Not(f['pf']), 'po': z3.Not(f['pf'])}
        if suffix not in conditions:
            raise Unsupported('condition ' + suffix)
        return conditions[suffix]

    def step(self, st, ins):
        relation = image_relation.ACTIVE
        return relation.step(self,st,ins,self._step) if relation is not None else self._step(st,ins)

    def _step(self, st, ins):
        self.current_pc = ins.address
        if hasattr(st,"ownership"):st.ownership.pc=ins.address;st.ownership.kind=ins.mnemonic
        st.cell_guard = self.guard_pointer_cells
        m, oo = ins.mnemonic, ins.operands
        if ins.raw.addr_size != 4:
            raise Unsupported('16-bit address size')
        if m in ('ret', 'leave', 'call', 'jmp') and 0x66 in ins.raw.prefix:
            raise Unsupported('16-bit control / stack operand size')
        undef = lambda flag: z3.Bool('undefined_%d_%x_%s' % (self.side, ins.address, flag))
        rd = lambda i: self.read(st, ins, oo[i])
        wr = lambda i, v: self.write(st, ins, oo[i], v)
        if ins.mutation == 'drop store':
            return
        if m in STRING_OPS:
            width = 4 if m.endswith('d') else 1
            for op in oo:
                if op.type == X.X86_OP_MEM and op.mem.segment and ins.reg_name(op.mem.segment) not in ('es', 'ds'):
                    raise Unsupported('segment override on REP')
            if (len(oo) != 2 or oo[0].type != X.X86_OP_MEM
                    or ins.reg_name(oo[0].mem.base) != 'edi' or oo[0].mem.index or oo[0].mem.disp
                    or oo[0].size != width):
                raise Unsupported('REP destination addressing form')
            if 'movs' in m:
                if (oo[1].type != X.X86_OP_MEM or ins.reg_name(oo[1].mem.base) != 'esi'
                        or oo[1].mem.index or oo[1].mem.disp or oo[1].size != width):
                    raise Unsupported('REP source addressing form')
            elif oo[1].type != X.X86_OP_REG or ins.reg_name(oo[1].reg) != ('eax' if width == 4 else 'al'):
                raise Unsupported('REP accumulator form')
            count = simp(st.regs['ecx'])
            if not z3.is_bv_value(count):
                raise Unsupported('nonconstant REP count')
            count = count.as_long() + (1 if ins.mutation == 'rep count +1' else 0)
            if count > 1024:
                raise Unsupported('REP count exceeds expansion budget')
            width = 4 if m.endswith('d') else 1
            delta = z3.If(st.flags['df'], bv(-width), bv(width))
            for _ in range(count):
                value = st.load(st.regs['esi'], width) if 'movs' in m else st.reg('eax' if width == 4 else 'al')
                st.store(st.regs['edi'], value)
                st.regs['edi'] = simp(st.regs['edi'] + delta)
                if 'movs' in m:
                    st.regs['esi'] = simp(st.regs['esi'] + delta)
            st.regs['ecx'] = bv(0)
            return
        if m == 'nop':
            return
        if m == 'mov':
            wr(0, rd(1))
        elif m in ('movsx', 'movzx'):
            v = rd(1)
            wr(0, (z3.SignExt if m == 'movsx' else z3.ZeroExt)(oo[0].size * 8 - v.size(), v))
        elif m == 'lea':
            wr(0, self.address(st, ins, oo[1]))
        elif m == 'xchg':
            if any(op.type != X.X86_OP_REG for op in oo):
                raise Unsupported('memory xchg')
            a, b = rd(0), rd(1)
            wr(0, b)
            wr(1, a)
        elif m in ('add', 'adc', 'sub', 'sbb', 'cmp', 'inc', 'dec'):
            a = rd(0)
            b = bv(1, a.size()) if m in ('inc', 'dec') else rd(1)
            v = self.arithmetic(st, m, a, b)
            if m != 'cmp':
                wr(0, v)
        elif m in ('and', 'or', 'xor', 'test'):
            a, b = rd(0), rd(1)
            v = (a & b) if m in ('and', 'test') else (a | b) if m == 'or' else (a ^ b)
            self.common_flags(st, v)
            st.flags['cf'] = st.flags['of'] = z3.BoolVal(False)
            st.flags['af'] = undef('af')
            if m != 'test':
                wr(0, v)
        elif m == 'not':
            wr(0, ~rd(0))
        elif m == 'neg':
            a = rd(0)
            v = self.arithmetic(st, 'sub', bv(0, a.size()), a)
            wr(0, v)
        elif m in ('shl', 'sal', 'shr', 'sar'):
            a, count = rd(0), rd(1)
            bits = a.size()
            count = z3.ZeroExt(bits - count.size(), count) if count.size() < bits else count
            count = count & bv(31, bits)
            v = (a << count) if m in ('shl', 'sal') else z3.LShR(a, count) if m == 'shr' else a >> count
            prior = dict(st.flags)
            self.common_flags(st, v)
            cf = z3.Extract(0, 0, z3.LShR(a, bv(bits, bits) - count)) == bv(1, 1) if m in ('shl', 'sal') else z3.Extract(0, 0, z3.LShR(a, count - bv(1, bits))) == bv(1, 1)
            of = ((z3.Extract(bits - 1, bits - 1, v) == bv(1, 1)) != cf) if m in ('shl', 'sal') else (z3.Extract(bits - 1, bits - 1, a) == bv(1, 1)) if m == 'shr' else z3.BoolVal(False)
            if m == 'sar':
                st.flags['cf'] = z3.If(z3.ULT(count, bv(bits, bits)), cf, z3.Extract(bits - 1, bits - 1, a) == bv(1, 1))
            else:
                st.flags['cf'] = z3.If(z3.ULT(count, bv(bits, bits)), cf, undef('cf'))
            st.flags['of'] = z3.If(count == bv(1, bits), of, undef('of'))
            st.flags['af'] = undef('af')
            for f in ('cf', 'of', 'af', 'sf', 'zf', 'pf'):
                st.flags[f] = z3.If(count == bv(0, bits), prior[f], st.flags[f])
            wr(0, v)
        elif m == 'imul' and len(oo) in (2, 3):
            aa, bb = (rd(0), rd(1)) if len(oo) == 2 else (rd(1), rd(2))
            bits = aa.size()
            full = z3.SignExt(bits, aa) * z3.SignExt(bits, bb)
            v = z3.Extract(bits - 1, 0, full)
            st.flags['cf'] = st.flags['of'] = full != z3.SignExt(bits, v)
            for f in ('sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
            wr(0, v)
        elif m in ('imul', 'mul') and len(oo) == 1 and oo[0].size == 4:
            a, b = st.regs['eax'], rd(0)
            ext = z3.SignExt if m == 'imul' else z3.ZeroExt
            full = ext(32, a) * ext(32, b)
            st.regs['eax'] = simp(z3.Extract(31, 0, full))
            st.regs['edx'] = simp(z3.Extract(63, 32, full))
            overflow = full != ext(32, st.regs['eax'])
            st.flags['cf'] = st.flags['of'] = overflow
            for f in ('sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m in ('idiv', 'div') and len(oo) == 1 and oo[0].size == 4:
            divisor = rd(0)
            dividend = z3.Concat(st.regs['edx'], st.regs['eax'])
            ext = z3.SignExt(32, divisor) if m == 'idiv' else z3.ZeroExt(32, divisor)
            quotient = dividend / ext if m == 'idiv' else z3.UDiv(dividend, ext)
            remainder = z3.SRem(dividend, ext) if m == 'idiv' else z3.URem(dividend, ext)
            q = z3.Extract(31, 0, quotient)
            overflow = quotient != (z3.SignExt(32, q) if m == 'idiv' else z3.ZeroExt(32, q))
            fault = z3.Or(divisor == bv(0), overflow)
            st.events.append(('divide-exception', fault, st.memory, st.fs, st.fp))
            st.regs['eax'], st.regs['edx'] = simp(q), simp(z3.Extract(31, 0, remainder))
            for f in ('cf', 'of', 'sf', 'zf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m == 'bound' and len(oo) == 2 and oo[0].size == 4 and oo[1].type == X.X86_OP_MEM:
            value = rd(0)
            addr = self.address(st, ins, oo[1])
            low, high = st.load(addr, 4), st.load(addr + bv(4), 4)
            st.events.append(('bound-exception', z3.Or(value < low, value > high), st.memory, st.fs, st.fp))
        elif m in ('bt', 'bts', 'btr', 'btc') and len(oo) == 2 and oo[0].type == X.X86_OP_REG:
            a, index = rd(0), rd(1)
            bits = a.size()
            index = z3.ZeroExt(bits - index.size(), index) if index.size() < bits else index
            index = index & bv(bits - 1, bits)
            st.flags['cf'] = (z3.LShR(a, index) & bv(1, bits)) == bv(1, bits)
            if m != 'bt':
                mask = bv(1, bits) << index
                wr(0, a | mask if m == 'bts' else a & ~mask if m == 'btr' else a ^ mask)
            for f in ('of', 'sf', 'af', 'pf'):
                st.flags[f] = undef(f)
        elif m == 'push':
            if oo[0].size != 4:
                raise Unsupported('non-dword push')
            v = rd(0)
            st.regs['esp'] = simp(st.regs['esp'] - bv(4))
            st.store(st.regs['esp'], v)
        elif m == 'pop':
            if oo[0].type != X.X86_OP_REG or oo[0].size != 4 or ins.reg_name(oo[0].reg) == 'esp':
                raise Unsupported('pop addressing form')
            v = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4))
            wr(0, v)
        elif m == 'leave':
            st.regs['esp'] = st.regs['ebp']
            st.regs['ebp'] = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4))
        elif m == 'cdq':
            st.regs['edx'] = simp(z3.If(st.regs['eax'] < bv(0), bv(-1), bv(0)))
        elif m == 'cwde':
            st.regs['eax'] = z3.SignExt(16, st.reg('ax'))
        elif m in ('clc', 'stc', 'cld', 'std'):
            st.flags['cf' if m in ('clc', 'stc') else 'df'] = z3.BoolVal(m in ('stc', 'std'))
        elif m == 'sahf':
            ah = st.reg('ah')
            for f, bit in (('sf', 7), ('zf', 6), ('af', 4), ('pf', 2), ('cf', 0)):
                st.flags[f] = z3.Extract(bit, bit, ah) == bv(1, 1)
        elif m == 'lahf':
            value = bv(2, 8)
            for f, bit in (('sf', 7), ('zf', 6), ('af', 4), ('pf', 2), ('cf', 0)):
                value |= z3.If(st.flags[f], bv(1 << bit, 8), bv(0, 8))
            st.putreg('ah', value)
        elif m.startswith('set'):
            wr(0, z3.If(self.condition(st, m[3:]), bv(1, 8), bv(0, 8)))
        elif m == 'jmp':
            if oo[0].type != X.X86_OP_IMM:
                raise Unsupported('indirect jump / jump table')
        elif m.startswith('j'):
            st.condition = self.condition(st, m[1:])
        elif m == 'call':
            contracts = getattr(self.addresses,'call_contracts',None)
            if contracts is None or (self.side,ins.address) not in contracts.sites:
                raise Unsupported('call contract was not prepared')
            inputs,cleanup,contract = contracts.sites[self.side,ins.address]
            for cell in sorted(getattr(self.addresses,'active_cells',((),()))[self.side]):
                contracts.h5.add((self.side,hex(ins.address),hex(cell),self.addresses.protected(self.side)[cell],0,'All callee memory effects preserve this immutable storage range'))
            op = oo[0]
            if ((op.type == X.X86_OP_IMM and op.imm in self.dynamic_targets)
                    or (op.type == X.X86_OP_MEM and not (op.mem.base or op.mem.index or op.mem.segment)
                        and op.mem.disp in self.dynamic_cells)):
                # These runtime helpers select a method using implicit BX/SI
                # arguments. The ordinary EAX/EDX/ECX call contract cannot
                # prove them, even when the helper's own address agrees.
                raise Unsupported('Delphi dynamic dispatch: implicit register arguments')
            target = rd(0)
            canonical_dynamic = self.addresses._dynamic_targets[0] | {
                self.addresses.reverse[a] for a in self.addresses._dynamic_targets[1]
                if a in getattr(self.addresses, 'reverse', {})}
            if z3.is_bv_value(simp(target)) and simp(target).as_long() in canonical_dynamic:
                raise Unsupported('Delphi dynamic dispatch: implicit register arguments')
            packed = [register_byte(st,r,k) if ('r',r,k) in inputs else bv(0,8) for r in REGS if r != 'esp' for k in range(4)]
            packed += [z3.If(st.flags[f],bv(1,1),bv(0,1)) if ('f',f) in inputs else bv(0,1) for f in FLAGS]
            tag = str(self.local[self.side].get(ins.address, ins.address))
            delta = bv(cleanup) if cleanup is not None else z3.BitVec('call_stack_cleanup_' + tag,32)
            st.events.append(('call', target, z3.Concat(packed+[delta]), bv(0), bv(0), st.regs['esp'], st.memory, st.fs, st.fp))
            for r in ('eax', 'edx', 'ecx'):
                st.regs[r] = z3.BitVec('call_' + tag + '_' + r, 32)
            for f in FLAGS:
                st.flags[f] = z3.Bool('call_' + tag + '_' + f)
            st.flags['df'] = z3.BoolVal(False)  # Explicit H3 postcondition.
            st.memory = z3.Array('call_memory_' + tag, BV32, BYTE)
            st.fs = z3.Array('call_fs_' + tag, BV32, BYTE)
            st.fp = z3.BitVec('call_x87_' + tag, 80 * 8 + 64)
            # R1/R2 use the ABI pass's concrete count; only R3 stays symbolic.
            contract['cleanup_symbol'] = str(delta)
            st.regs['esp'] = simp(st.regs['esp'] + delta)
        elif m == 'eh-enter':
            st.events.append(('exception-helper', *(self.constant(v) for v in ins.eh)))
        elif m == 'ret':
            amount = oo[0].imm if oo else 0
            target = st.load(st.regs['esp'], 4)
            st.regs['esp'] = simp(st.regs['esp'] + bv(4 + amount))
            if ins.handler_return:
                # @HandleFinally discards the cleanup's register results and
                # restores its own saved nonvolatile registers after CALL ECX.
                st.events.append(('finally-return', target, st.regs['esp']))
            else:
                st.events.append(('return', target, *(st.regs[r] for r in ('eax', 'edx', 'esp', 'ebx', 'esi', 'edi', 'ebp')), st.flags['df']))
        elif m in FP_OPS:
            # The brief permits ordered uninterpreted x87 operations. The
            # state contains all eight 80-bit registers and control/status bits.
            # Equality of the complete input state also covers x87 exceptions.
            args = [st.fp]
            store = m in ('fst', 'fstp', 'fist', 'fistp', 'fnstsw', 'fnstcw')
            shape = []
            for op in oo:
                if op.type == X.X86_OP_REG and ins.reg_name(op.reg).startswith('st('):
                    shape.append(ins.reg_name(op.reg))
                elif op.type == X.X86_OP_MEM:
                    shape.append('mem%d' % op.size)
                    if not store:
                        args.append(self.read(st, ins, op))
                elif store and op.type == X.X86_OP_REG:
                    shape.append('reg%d' % op.size)
                else:
                    raise Unsupported('x87 operand ' + ins.op_str)
            site = self.local[self.side].get(ins.address, ins.address)
            key = m + '_' + '_'.join(shape)
            st.events.append(('x87:' + key, *args))
            key += '_site_%x' % site
            if store:
                if len(oo) != 1 or oo[0].type not in (X.X86_OP_REG, X.X86_OP_MEM):
                    raise Unsupported('x87 store form')
                bits = oo[0].size * 8
                value = z3.Function('x87_value_' + key, z3.BitVecSort(FP_BITS), z3.BitVecSort(bits))(st.fp)
                self.write(st, ins, oo[0], value)
            sorts = [v.sort() for v in args]
            st.fp = z3.Function('x87_step_' + key, *sorts, z3.BitVecSort(FP_BITS))(*args)
        else:
            raise Unsupported(m)


def successors(insns, index):
    ins = insns[index]
    m = ins.mnemonic
    by_addr = {i.address: j for j, i in enumerate(insns)}
    if ins.flow is not None:
        if any(t not in by_addr for t in ins.flow):
            raise Unsupported('incomplete exception continuation')
        return tuple(by_addr[t] for t in ins.flow)
    fall = index + 1
    if m == 'ret':
        return ()
    if m == 'jmp' or m.startswith('j'):
        if not ins.operands or ins.operands[0].type != X.X86_OP_IMM:
            raise Unsupported('indirect jump / jump table')
        target = ins.operands[0].imm
        if target not in by_addr:
            raise Unsupported('external jump')
        return (by_addr[target],) if m == 'jmp' else (by_addr[target], fall)
    if fall >= len(insns):
        raise Unsupported('incomplete function / fallthrough')
    return (fall,)


def blocks(insns, entry=0, preserve=False):
    reachable = {}
    todo = [entry]
    while todo:
        i = todo.pop()
        if i in reachable:
            continue
        if not 0 <= i < len(insns):
            raise Unsupported('incomplete function')
        reachable[i] = successors(insns, i)
        todo.extend(reachable[i])
    starts = {entry}
    for i, edges in reachable.items():
        if insns[i].mnemonic.startswith('j') or insns[i].flow is not None:
            starts.update(edges)
    result = {}
    for i in sorted(starts):
        seq = [i]
        while len(reachable[seq[-1]]) == 1:
            nxt = reachable[seq[-1]][0]
            if nxt in starts or insns[seq[-1]].mnemonic.startswith('j') or insns[seq[-1]].flow is not None:
                break
            seq.append(nxt)
        result[i] = (seq, reachable[seq[-1]])
    # Layout-only trampolines are epsilon transitions. Keep self loops, and
    # never remove instructions whose prefixes / operand sizes need modeling.
    changed = not preserve
    while changed:
        changed = False
        for h, (seq, edges) in list(result.items()):
            if h == entry or len(edges) != 1 or edges[0] == h:
                continue
            if all(insns[k].mnemonic in ('nop', 'jmp') and insns[k].raw.addr_size == 4
                   and not any(insns[k].raw.prefix) for k in seq):
                target = edges[0]
                for p, (body, successors_) in list(result.items()):
                    result[p] = (body, tuple(target if x == h else x for x in successors_))
                del result[h]
                changed = True
                break
        if changed:
            continue
        incoming = collections.Counter(j for _, edges in result.values() for j in edges)
        for h, (seq, edges) in list(result.items()):
            if len(edges) == 1:
                target = edges[0]
                if target != entry and target != h and incoming[target] == 1:
                    following, out = result[target]
                    result[h] = (seq + following, out)
                    del result[target]
                    changed = True
                    break
    return result


def edge_guard(state, terminal, count, edge):
    # A handler table is nondeterministic in this overapproximation. Two
    # entries are not a Jcc: neither entry may get a vacuous false premise.
    conditional = (count == 2 and terminal.mnemonic.startswith('j') and terminal.mnemonic != 'jmp')
    if not conditional:
        return z3.BoolVal(True)
    return state.condition if edge == 0 else z3.Not(state.condition)


INVERSE_JUMP = dict(pair for a, b in (('je', 'jne'), ('jz', 'jnz'), ('jg', 'jle'),
                                    ('jge', 'jl'), ('ja', 'jbe'), ('jae', 'jb'),
                                    ('jo', 'jno'), ('js', 'jns'), ('jp', 'jnp'))
                    for pair in ((a, b), (b, a)))


def cfg_variants(a, b, graphs, entry, addresses):
    """Propose graph bijections by events and successor colors, not addresses.

    A flipped Jcc is represented by both its complementary predicate and its
    exchanged successors. This is an exact control-flow rewrite. Every
    proposed graph still needs a full state/event/condition proof afterwards.
    """
    def target_key(side, value):
        if side == 0 and value in addresses.forward:
            return value
        if side == 1 and value in addresses.reverse:
            return addresses.reverse[value]
        if not (addresses.old, addresses.new)[side].contains(value):
            return value
        return '?'
    base = {}
    for side, (code, graph) in enumerate(zip((a, b), graphs)):
        for head, (seq, edges) in graph.items():
            events = []
            for k in seq:
                ins = code[k]
                if ins.mnemonic == 'call':
                    op = ins.operands[0]
                    events.append(('call', target_key(side, op.imm) if op.type == X.X86_OP_IMM else ('indirect', op.size)))
                elif ins.mnemonic == 'ret':
                    events.append(('finally-return' if ins.handler_return else 'return',))
                elif ins.mnemonic in FP_OPS or ins.mnemonic in ('bound', 'div', 'idiv', 'eh-enter'):
                    events.append((ins.mnemonic,))
                if ins.eh and ins.mnemonic != 'eh-enter':
                    events.append(('frame-install',))
            base[side, head] = (len(edges), tuple(events))
    def color(keys):
        table = {}
        return {k: table.setdefault(v, len(table)) for k, v in keys.items()}
    colors = color(base)
    for _ in range(len(base)):
        refined = color({(s, h): (base[s, h], tuple(sorted(colors[s, j] for j in edges)))
                         for s, graph in enumerate(graphs) for h, (_, edges) in graph.items()})
        if refined == colors:
            break
        colors = refined
    pending = [({}, {}, {}, [(entry[0], entry[1])])]
    explored, yielded = 0, 0
    while pending and explored < 256 and yielded < 2:
        pairing, reverse, flips, todo = pending.pop()
        explored += 1
        valid = True
        while todo and valid:
            i, j = todo.pop()
            if i in pairing:
                valid = pairing[i] == j
                continue
            if j in reverse or colors[0, i] != colors[1, j]:
                valid = False
                break
            pairing[i], reverse[j] = j, i
            aa, bb = graphs[0][i][1], graphs[1][j][1]
            x, y = a[graphs[0][i][0][-1]], b[graphs[1][j][0][-1]]
            options = [False]
            if len(aa) == len(bb) == 2 and x.mnemonic in INVERSE_JUMP and y.mnemonic in INVERSE_JUMP:
                options = [True, False] if x.mnemonic == INVERSE_JUMP[y.mnemonic] else [False, True]
            options = [flip for flip in options
                       if all(colors[0, p] == colors[1, q] for p, q in zip(aa, bb[::-1] if flip else bb))]
            if not options:
                valid = False
                break
            for flip in reversed(options[1:]):
                following = bb[::-1] if flip else bb
                branch_flips = dict(flips)
                if flip:
                    branch_flips[j] = True
                pending.append((dict(pairing), dict(reverse), branch_flips, todo + list(zip(aa, following))))
            if options[0]:
                flips[j] = True
            todo.extend(zip(aa, bb[::-1] if options[0] else bb))
        if valid and flips:
            code = [dataclasses.replace(ins) for ins in b]
            for head in flips:
                seq, edges = graphs[1][head]
                terminal = code[seq[-1]]
                terminal.mnemonic = INVERSE_JUMP[terminal.mnemonic]
                terminal.flow = tuple(b[k].address for k in reversed(edges))
            yielded += 1
            yield code


def frame_bytes(code):
    return {o.mem.disp + k for ins in code for o in ins.operands
            if o.type == X.X86_OP_MEM and not (o.mem.segment or o.mem.index)
            and ins.reg_name(o.mem.base) == 'ebp' and -4096 <= o.mem.disp < 0
            for k in range(o.size)}


def location_value(st, loc):
    if loc[0] == 'r':
        return register_byte(st, loc[1], loc[2])
    if loc[0] == 'f':
        return st.flags[loc[1]]
    return simp(z3.Select(st.memory, st.regs['ebp'] + bv(loc[1])))


def live_locations(code, graph):
    """Backward may-liveness, including partial registers and CPU flags.

    Indirect stores never kill a possibly aliased frame byte. Calls expose all
    known frame bytes (a conservative treatment of var arguments) and havoc
    them. The memory arrays themselves remain part of every cut invariant.
    """
    slots = {('m', k) for k in frame_bytes(code)}
    uses, definitions = {}, {}
    def regloc(reg):
        name = code[0].reg_name(reg)
        if name not in ALIASES:
            return set()
        root, bits, off = ALIASES[name]
        return {('r', root, k) for k in range(off // 8, (off + bits) // 8)}
    for head, (seq, _) in graph.items():
        use, killed = set(), set()
        for k in seq:
            ins = code[k]
            rr, ww = ins.raw.regs_access()
            read = set().union(*(regloc(r) for r in rr)) if rr else set()
            write = set().union(*(regloc(r) for r in ww)) if ww else set()
            for flag in FLAGS:
                readmask = sum(getattr(X, 'X86_EFLAGS_' + p + '_' + flag.upper(), 0) for p in ('TEST', 'PRIOR'))
                writemask = sum(getattr(X, 'X86_EFLAGS_' + p + '_' + flag.upper(), 0) for p in ('MODIFY', 'RESET', 'SET', 'UNDEFINED'))
                if ins.raw.eflags & readmask:
                    read.add(('f', flag))
                if ins.raw.eflags & writemask:
                    write.add(('f', flag))
            for n, op in enumerate(ins.operands):
                if op.type != X.X86_OP_MEM or op.mem.segment or op.mem.index or ins.reg_name(op.mem.base) != 'ebp':
                    continue
                locs = {('m', op.mem.disp + j) for j in range(op.size)} & slots
                # Capstone access bits are unavailable in some releases;
                # classify only definite plain MOV stores as must-definitions.
                if n == 0 and ins.mnemonic == 'mov':
                    write |= locs
                elif ins.mnemonic != 'lea':
                    read |= locs
            if ins.mnemonic == 'call':
                read |= slots | {('r', r, k) for r in ('eax', 'edx', 'ecx', 'esp') for k in range(4)}
                write |= slots | {('r', r, k) for r in ('eax', 'edx', 'ecx', 'esp') for k in range(4)} | {('f', f) for f in FLAGS}
            if ins.mnemonic == 'ret':
                regs = ('esp',) if ins.handler_return else ('eax', 'edx', 'esp', 'ebx', 'esi', 'edi', 'ebp')
                read |= slots | {('r', r, k) for r in regs for k in range(4)}
            use |= read - killed
            killed |= write
        uses[head], definitions[head] = use, killed
    live = {h: set(u) for h, u in uses.items()}
    changed = True
    while changed:
        changed = False
        for h, (_, edges) in graph.items():
            after = set().union(*(live[j] for j in edges)) if edges else set()
            value = uses[h] | (after - definitions[h])
            if any(l[0] == 'm' for l in value):
                value |= {('r', 'ebp', k) for k in range(4)}
            if not value <= live[h]:
                live[h] |= value
                changed = True
    return live


def fact_expression(states, fact):
    if fact[0] == 'eq':
        return location_value(states[0], fact[1]) == location_value(states[1], fact[2])
    if fact[0] == 'const':
        _, side, loc, value = fact
        expr = location_value(states[side], loc)
        return expr == (z3.BoolVal(value) if z3.is_bool(expr) else bv(value, expr.size()))
    _, side, reg, base, delta = fact
    return states[side].regs[reg] == states[side].regs[base] + bv(delta)


def relation_states(facts):
    registers, flags = [], []
    for f in sorted(facts,key=repr):
        if f[0] != 'eq':
            continue
        a, b = f[1:]
        if a[0] == b[0] == 'r' and a[2] == b[2]:
            registers.append((a[1], b[1], a[2]))
        if a[0] == b[0] == 'f' and a[1] == b[1]:
            flags.append(a[1])
    states = arbitrary(registers, flags)
    premise = simp(z3.And([fact_expression(states, f) for f in sorted(facts,key=repr)]))
    return states, premise


def callee_cleanup(checker, side, target, own_ret_only=False):
    """Read a callee's stack convention, proving its ESP at each normal RET.

    This is an abstract interpretation of stack offsets, not a guess from an
    argument count. Unknown instructions, inconsistent joins and tail calls
    fail closed. Calls preserve EBP but may have unknown stack cleanup.
    """
    if not hasattr(checker, '_cleanup_cache'):
        checker._cleanup_cache = {}
        checker._cleanup_images = {}
    if not hasattr(checker, '_cleanup_unreadable'): checker._cleanup_unreadable = set()
    root = (checker.inp.old, checker.inp.new)[side]
    def analyze(img, address, depth):
        key = (id(img), address, own_ret_only)
        if key in checker._cleanup_cache:
            return checker._cleanup_cache[key]
        if depth > 5 or not img.contains(address):
            if not img.contains(address): checker._cleanup_unreadable.add(key)
            return None
        checker._cleanup_cache[key] = None
        md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
        md.detail = True
        states, todo, returns = {}, [(address, 0, None)], set()
        visits = 0
        def imported(cell):
            match.parse_imports_once(img)
            for module in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', ()):
                for imp in module.imports:
                    if imp.address != cell or not imp.name:
                        continue
                    path = checker.inp.original_path.parent / module.dll.decode('latin1')
                    verdict_cache.imported(img,cell,path,imp.name)
                    if not path.is_file():
                        checker._cleanup_unreadable.add(key)
                        return None
                    if path not in checker._cleanup_images:
                        other = match.Image(path)
                        other.pe.parse_data_directories(directories=[match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
                        checker._cleanup_images[path] = other
                    other = checker._cleanup_images[path]
                    for exp in getattr(getattr(other.pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', ()):
                        if exp.name == imp.name and not exp.forwarder:
                            result = analyze(other, other.base + exp.address, depth + 1)
                            if (id(other),other.base+exp.address,own_ret_only) in checker._cleanup_unreadable: checker._cleanup_unreadable.add(key)
                            return result
            checker._cleanup_unreadable.add(key)
            return None
        while todo:
            pc, sp, bp = todo.pop()
            visits += 1
            if visits > 1500 or abs(pc - address) > 8192:
                return None
            if pc in states:
                old = states[pc]
                merged = tuple(x if x == y else None for x, y in zip(old, (sp, bp)))
                if old == merged:
                    continue
                sp, bp = merged
            states[pc] = (sp, bp)
            ins = next(md.disasm(verdict_cache.raw(img,pc,15), pc, count=1), None)
            verdict_cache.note(img,pc,ins.size if ins else 15)
            if ins is None or ins.addr_size != 4:
                if ins is None: checker._cleanup_unreadable.add(key)
                return None
            m, oo = ins.mnemonic, ins.operands
            if m == 'ret':
                if (sp != 0 and not own_ret_only) or 0x66 in ins.prefix:
                    return None
                returns.add(oo[0].imm if oo else 0)
                continue
            if m == 'push':
                if oo[0].size != 4:
                    return None
                sp = sp - 4 if sp is not None else None
            elif m == 'pop':
                if oo[0].type != X.X86_OP_REG or oo[0].size != 4 or ins.reg_name(oo[0].reg) == 'esp':
                    return None
                sp = sp + 4 if sp is not None else None
                if ins.reg_name(oo[0].reg) == 'ebp':
                    bp = None
            elif m == 'leave':
                sp, bp = (bp + 4 if bp is not None else None), None
            elif m == 'mov' and all(o.type == X.X86_OP_REG for o in oo) and len(oo) == 2:
                dst, src = (ins.reg_name(o.reg) for o in oo)
                value = sp if src == 'esp' else bp if src == 'ebp' else None
                if dst == 'esp':
                    sp = value
                if dst == 'ebp':
                    bp = value
            elif m in ('add', 'sub') and oo[0].type == X.X86_OP_REG and ins.reg_name(oo[0].reg) in ('esp', 'ebp'):
                name = ins.reg_name(oo[0].reg)
                value = sp if name == 'esp' else bp
                delta = oo[1].imm * (-1 if m == 'sub' else 1) if oo[1].type == X.X86_OP_IMM else None
                value = value + delta if value is not None and delta is not None else None
                if name == 'esp':
                    sp = value
                else:
                    bp = value
            elif m == 'call':
                cleanup = 0 if own_ret_only else analyze(img, oo[0].imm, depth + 1) if oo[0].type == X.X86_OP_IMM else None
                sp = sp + cleanup if sp is not None and cleanup is not None else None
            elif m == 'jmp' and oo[0].type == X.X86_OP_MEM and not (oo[0].mem.base or oo[0].mem.index or oo[0].mem.segment):
                cleanup = imported(oo[0].mem.disp)
                if (sp != 0 and not own_ret_only) or cleanup is None:
                    return None
                returns.add(cleanup)
                continue
            else:
                _, written = ins.regs_access()
                for r in written:
                    name = ins.reg_name(r)
                    if name in ('esp', 'sp'):
                        sp = None
                    if name in ('ebp', 'bp'):
                        bp = None
            if m == 'jmp' or m.startswith('j'):
                if not oo or oo[0].type != X.X86_OP_IMM:
                    return None
                todo.append((oo[0].imm, sp, bp))
                if m == 'jmp':
                    continue
            todo.append((pc + ins.size, sp, bp))
        answer = next(iter(returns)) if len(returns) == 1 else None
        checker._cleanup_cache[key] = answer
        return answer
    return analyze(root, target, 0)


def stack_insensitive_leaf(checker, side, target):
    """A sufficient contract for preserving unescaped caller-private bytes.

    Unknown callees keep the whole-memory/absolute-ESP obligation. Only a
    checked leaf with no explicit memory operands, calls, segment accesses or
    uses of its stack address gets the smaller private-frame call relation.
    Its net stack effect is independently checked by callee_cleanup.
    """
    if not hasattr(checker, '_private_call_cache'):
        checker._private_call_cache = {}
    key = side, target
    if key in checker._private_call_cache:
        return checker._private_call_cache[key]
    checker._private_call_cache[key] = False
    img = (checker.inp.old, checker.inp.new)[side]
    if not img.contains(target):
        return False
    md = CS.Cs(CS.CS_ARCH_X86, CS.CS_MODE_32)
    md.detail = True
    pc = target
    flag_reads = sum(getattr(X, 'X86_EFLAGS_' + kind + '_' + flag.upper(), 0)
                     for kind in ('TEST', 'PRIOR') for flag in FLAGS)
    for _ in range(128):
        ins = next(md.disasm(verdict_cache.raw(img,pc,15), pc, count=1), None)
        verdict_cache.note(img,pc,ins.size if ins else 15)
        if ins is None or ins.addr_size != 4:
            return False
        if ins.mnemonic == 'ret':
            if 0x66 in ins.prefix:
                return False
            checker._private_call_cache[key] = True
            return True
        # Prologue/epilogue instructions need more than a register-access
        # test: PUSH ESP / POP EAX can export the callee's stack address.
        # Qualify only straight-line register-only leaves. Other callees
        # retain the whole-memory and absolute-ESP call obligation.
        if (ins.mnemonic not in INTEGER_OPS or ins.mnemonic in
                ('push', 'pop', 'leave', 'call', 'jmp', 'adc', 'sbb', 'sahf', 'lahf')):
            return False
        if any(o.type == X.X86_OP_MEM for o in ins.operands) or ins.eflags & flag_reads:
            return False
        read, written = ins.regs_access()
        if any(ins.reg_name(r) != 'eflags' and ALIASES.get(ins.reg_name(r), (None,))[0]
               not in ('eax', 'edx', 'ecx') for r in set(read) | set(written)):
            return False
        pc += ins.size
    return False



from equiv_garbage import private_extent, independent_private, check_initialized, CutGarbage


class Frames:
    """An inductive relation over private bytes, with a common public array.

    The entry stack pointer and incoming nonvolatile values are ghost constants.
    They are never reset at a cut point. All inferred equalities, including
    save/restore and stack-address facts, are initialized and checked on every
    incoming edge. Execution still uses unified byte arrays, retaining aliases.
    Escaping private addresses require the ordinary whole-memory proof instead.
    """
    def __init__(self, codes):
        self.stack = z3.BitVec('frame_entry_esp', 32)
        self.public = z3.Array('memory', BV32, BYTE)
        self.saved = {r: z3.BitVec('frame_entry_' + r, 32) for r in REGS}
        self.saved['esp'] = self.stack
        self.lows = []
        for code in codes:
            off = private_extent(code)
            self.lows.append(off)
        self.low = min(self.lows)
        self.locations = [{('r', r, k) for r in REGS for k in range(4)} |
                          {('s', off) for off in range(low, 0)} for low in self.lows]

    def offset(self, value):
        delta = simp(value - self.stack)
        if z3.is_bv_value(delta):
            n = delta.as_long()
            return n - 0x100000000 if n >= 0x80000000 else n
        return None

    def project(self, memory, side, preserve=()):
        # Mask only this side's allocation, using the common public bytes.
        # Masking the union with zero could hide a write outside the smaller
        # frame that happens to fall inside the other side's larger frame.
        for off in range(self.lows[side], 0):
            if off in preserve:continue
            addr = self.stack + bv(off)
            memory = z3.Store(memory, addr, z3.Select(self.public, addr))
        return simp(memory)

    def value(self, st, loc):
        if loc[0] == 'word':
            return st.regs[loc[1]] if isinstance(loc[1], str) else st.load(self.stack + bv(loc[1]), 4)
        if loc[0] == 's':
            return st.load(self.stack + bv(loc[1]), 1)
        return location_value(st, loc)

    def fact(self, states, f):
        if f[0] == 'eq':
            return self.value(states[0], f[1]) == self.value(states[1], f[2])
        if f[0] == 'flag':
            return states[0].flags[f[1]] == states[1].flags[f[1]]
        if f[0] == 'flagvalue':
            return states[f[1]].flags[f[2]] == z3.BoolVal(f[3])
        if f[0] == 'affine':
            return self.value(states[0], f[1]) - self.value(states[1], f[2]) == bv(f[3])
        if f[0] == 'ptr':
            return states[f[1]].regs[f[2]] == self.stack + bv(f[3])
        if f[0] == 'imm':
            return states[f[1]].regs[f[2]] == bv(f[3])
        if f[0] == 'difference':
            return states[0].regs['esp'] - states[1].regs['esp'] == bv(f[1])
        if f[0] == 'saved':
            return self.value(states[f[1]], f[2]) == z3.Extract(f[4]*8+7, f[4]*8, self.saved[f[3]])
        if f[0] == 'byte':
            return self.value(states[f[1]], f[2]) == bv(f[3], 8)
        raise AssertionError(f)

    def states(self, facts=(), initial=False):
        if initial:
            states = arbitrary(DIAG, FLAGS)
            for st in states:
                st.regs = dict(self.saved)
            independent_private(states, self.lows, self.stack)
            return states, z3.BoolVal(True)
        # Build byte equalities into the arbitrary state. This is the same
        # union-find construction as the fast register proof, extended to
        # private slots and immutable incoming-register ghost values.
        locations = {('r', r, k) for r in REGS for k in range(4)} | {('s', k) for k in range(self.low, 0)}
        parent = {(side, loc): (side, loc) for side in (0, 1) for loc in sorted(locations,key=repr)}
        def find(node):
            parent.setdefault(node, node)
            while parent[node] != node:
                node = parent[node]
            return node
        def join(x, y):
            parent[find(y)] = find(x)
        for f in sorted(facts,key=repr):
            if f[0] == 'eq':
                join((0, f[1]), (1, f[2]))
            elif f[0] == 'saved':
                join((f[1], f[2]), ('ghost', f[3], f[4]))
            elif f[0] == 'byte':
                join((f[1], f[2]), ('constant', f[3]))
        values = {}
        for node in list(parent):
            if node[0] == 'ghost':
                values[find(node)] = z3.Extract(node[2]*8+7, node[2]*8, self.saved[node[1]])
            elif node[0] == 'constant':
                values[find(node)] = bv(node[1], 8)
        def value(side, loc):
            root = find((side, loc))
            if root not in values:
                values[root] = z3.BitVec('frame_byte_' + str(len(values)), 8)
            return values[root]
        states = arbitrary((), [f[1] for f in sorted(facts,key=repr) if f[0] == 'flag'])
        for side, st in enumerate(states):
            st.regs = {r: z3.Concat([value(side, ('r', r, k)) for k in reversed(range(4))]) for r in REGS}
            for off in range(self.lows[side], 0):
                st.store(self.stack + bv(off), value(side, ('s', off)))
        # Substitute proven full-register constants before executing REP and
        # stack operations. The complete relation remains an explicit premise.
        for f in sorted(facts,key=repr):
            if f[0] == 'ptr':
                states[f[1]].regs[f[2]] = simp(self.stack + bv(f[3]))
            elif f[0] == 'imm':
                states[f[1]].regs[f[2]] = bv(f[3])
            elif f[0] == 'flagvalue':
                states[f[1]].flags[f[2]] = z3.BoolVal(f[3])
        for f in sorted(facts,key=repr):
            if f[0] == 'difference':
                states[1].regs['esp'] = simp(states[0].regs['esp'] - bv(f[1]))
        return states, simp(z3.And([self.fact(states, f) for f in sorted(facts,key=repr)]))

    @staticmethod
    def clone(states):
        clones = [State(dict(s.regs), dict(s.flags), s.memory, s.fs, s.fp) for s in states]
        for source,target in zip(states,clones):target.image_origins={k:set(v) for k,v in getattr(source,'image_origins',{}).items()}
        for st, clone in zip(states, clones):
            clone.outgoing = list(getattr(st, 'outgoing', []))
            clone_ownership(st,clone)
        return clones

    def candidates(self, states):
        values = [{loc: simp(self.value(st, loc)) for loc in sorted(locs,key=repr)}
                  for st, locs in zip(states, self.locations)]
        facts = set()
        delta = simp(states[0].regs['esp'] - states[1].regs['esp'])
        if z3.is_bv_value(delta):
            facts.add(('difference', delta.as_long()))
        right = collections.defaultdict(list)
        for loc, value in values[1].items():
            if not z3.is_bv_value(value):
                right[value.hash()].append((loc, value))
        for loc, value in values[0].items():
            for other, v in right[value.hash()]:
                if equal(value, v):
                    facts.add(('eq', loc, other))
        for flag in FLAGS:
            if equal(states[0].flags[flag], states[1].flags[flag]):
                facts.add(('flag', flag))
        words = [{('word', r): st.regs[r] for r in REGS} |
                 {('word', off): st.load(self.stack + bv(off), 4) for off in range(low, -3) if off % 4 == 0}
                 for st, low in zip(states, self.lows)]
        roots_cache = {}
        def roots(expr):
            # Array stores can form expressions deeper than Python's call
            # stack. Walk the DAG iteratively, retaining the same leaf sets.
            pending = [(expr, False)]
            visits = 0
            while pending:
                node, ready = pending.pop()
                key = node.get_id()
                if key in roots_cache:
                    continue
                visits += 1
                if visits % 128 == 0:self.budget.step()
                if z3.is_const(node) and node.decl().kind() == z3.Z3_OP_UNINTERPRETED:
                    roots_cache[key] = frozenset((key,))
                elif ready:
                    roots_cache[key] = frozenset().union(*(roots_cache[c.get_id()] for c in node.children()))
                else:
                    pending.append((node, True))
                    pending.extend((c, False) for c in node.children())
            return roots_cache[expr.get_id()]
        proposal_model = z3.Model()
        for x, value in words[0].items():
            self.budget.step()
            if z3.is_bv_value(simp(value)):
                continue
            for y, other in words[1].items():
                delta = simp(value - other)
                if not z3.is_bv_value(delta) and roots(value) and roots(value) == roots(other):
                    # A model only proposes the offset. Initialization and
                    # every edge still have to prove it universally.
                    delta = proposal_model.eval(delta, model_completion=True)
                if z3.is_bv_value(delta) and 0 < min(delta.as_long(), (-delta.as_long()) % 0x100000000) <= 4096:
                    facts.add(('affine', x, y, delta.as_long()))
        for side, st in enumerate(states):
            for flag in FLAGS:
                value = simp(st.flags[flag])
                if z3.is_true(value) or z3.is_false(value):
                    facts.add(('flagvalue', side, flag, z3.is_true(value)))
            for r in REGS:
                off = self.offset(st.regs[r])
                if off is not None:
                    facts.add(('ptr', side, r, off))
                value = simp(st.regs[r])
                if z3.is_bv_value(value):
                    facts.add(('imm', side, r, value.as_long()))
            for loc, value in values[side].items():
                if z3.is_bv_value(value):
                    facts.add(('byte', side, loc, value.as_long()))
                for r in REGS[:-1]:
                    for lane in range(4):
                        if equal(value, z3.Extract(lane*8+7, lane*8, self.saved[r])):
                            facts.add(('saved', side, loc, r, lane))
        if len(facts) > 12000:
            raise NotProven('frame-slot candidate budget')
        return facts


class FrameMachine(Machine):
    def __init__(self, addresses, side, local, frames):
        super().__init__(addresses, side, local)
        self.frames = frames
        self.cleanups = {}
        self.private_calls = set()

    def step(self, st, ins):
        if ins.mnemonic=='ret':st.ownership.result(st)
        if ins.mnemonic != 'call':
            super().step(st, ins)
            if ins.mnemonic == 'push':
                off = self.frames.offset(st.regs['esp'])
                if off is None or off < self.frames.lows[self.side]:
                    if not hasattr(st, 'outgoing'):
                        st.outgoing = []
                    st.outgoing.append(st.regs['esp'])
            return
        frames = self.frames
        args = [st.regs[r] for r in ('eax', 'edx', 'ecx')]
        off = frames.offset(st.regs['esp'])
        if off is None:
            outgoing = getattr(st, 'outgoing', [])
            if not all(equal(addr, st.regs['esp'] + bv(4*k)) for k, addr in enumerate(reversed(outgoing))):
                raise NotProven('noncontiguous outgoing stack arguments')
            size = len(outgoing) * 4
        else:
            size = frames.lows[self.side] - off
        st.outgoing = []
        if ins.address in self.cleanups and self.cleanups[ins.address] > size:
            raise NotProven('callee arguments overlap the private frame')
        if not 0 <= size <= 128:
            raise NotProven('outgoing stack extent exceeds budget')
        stack_args = [st.load(st.regs['esp'] + bv(k), 1) for k in range(size)]
        memory = st.memory
        sp = st.regs['esp']
        observed=self.addresses.call_contracts.sites[self.side,ins.address][0]
        passed = [st.regs[r] for r in REGS if r!='esp' and any(('r',r,lane) in observed for lane in range(4))] + [st.load(sp + bv(k), 4) for k in range(0, size - 3, 4)]
        escaped = z3.BoolVal(True) if ins.address not in self.private_calls else (z3.Or([z3.ULT(v - (frames.stack + bv(frames.low)), bv(-frames.low)) for v in passed]) if frames.low else z3.BoolVal(False))
        from equiv_summaries import frame_writes
        info=st.ownership.info;k=next(k for k,i in enumerate(info['code']) if i.address==ins.address)
        allowed=frame_writes(st.ownership.checker,info,k)
        st.ownership.passed(st,passed,allowed,len(passed)-len(range(0,size-3,4)))
        super().step(st, ins)
        if ins.address in self.cleanups:
            st.regs['esp'] = simp(sp + bv(self.cleanups[ins.address]))
        event = st.events.pop()
        # Absolute ESP can differ by the private-frame size. Outgoing bytes
        # are compared relative to ESP, and all other public memory is equal.
        st.events.append(('frame-call', event[1], *event[2:5], sp - bv(frames.lows[self.side]) if ins.address in self.private_calls else sp, bv(size), memory, event[-2], event[-1], escaped, sp, *stack_args))
        # Calls may change public memory. Unescaped private bytes survive.
        st.ownership_internal=True
        for k in range(frames.lows[self.side], 0):
            st.store(frames.stack + bv(k), z3.If(escaped, z3.Select(st.memory, frames.stack + bv(k)), z3.Select(memory, frames.stack + bv(k))))
        st.ownership_internal=False


def frame_goals(frames, states):
    old, new = states
    preserve=set()
    if any(e[0]=='return' for e in old.events):
        asymmetric=getattr(old,'frame_defined',set()) ^ getattr(new,'frame_defined',set())
        numeric=[z3.Implies(st.ownership.guard(st),outside(st.regs[r],frames.stack,frames.lows[side])) for side,st in enumerate(states) for r in ('eax','edx')]
        if asymmetric and not prove(numeric):preserve=asymmetric
    goals = [frames.project(old.memory, 0,preserve) == frames.project(new.memory, 1,preserve), old.fs == new.fs,
             old.fp == new.fp, old.condition == new.condition]
    if len(old.events) != len(new.events):
        raise NotProven('different observable events with private frames')
    for x, y in zip(old.events, new.events):
        if x[0] != y[0] or len(x) != len(y):
            raise NotProven('different observable events with private frames')
        if x[0] == 'frame-call':
            goals += [equality(x[k], y[k]) for k in range(1, len(x)) if k not in (7, 11)]
            memories = [x[7], y[7]]
            exposed = z3.Or(x[10], y[10])
            for side in (0, 1):
                for off in range(frames.lows[side], 0):
                    addr = frames.stack + bv(off)
                    memories[side] = z3.Store(memories[side], addr, z3.If(exposed, z3.Select(memories[side], addr), z3.Select(frames.public, addr)))
            size = x[6].as_long()
            for side, event in enumerate((x, y)):
                actual_sp = event[11]
                for k in range(size):
                    memories = [z3.Store(m, actual_sp + bv(k), bv(0, 8)) for m in memories]
            goals.append(memories[0] == memories[1])
        else:
            goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
    for st in states:
        if any(e[0] == 'return' for e in st.events):
            goals += [st.regs[r] == frames.saved[r] for r in ('ebx', 'esi', 'edi', 'ebp')]
    for st in states:
        if hasattr(st,"ownership"):goals+=st.ownership.goals(st)
    return guarded(states,goals)


def verify_frames(checker, a, b, finite=False):
    from equiv_calls import ensure
    ensure(checker,a,b)
    if getattr(checker, "exception_whole_only", False):
        raise Unsupported("exception region requires compatible whole-memory route")
    graphs = [blocks(a), blocks(b)]
    pairing, reverse, todo = {0: 0}, {0: 0}, [0]
    while todo:
        i = todo.pop()
        aa, bb = graphs[0][i][1], graphs[1][pairing[i]][1]
        if len(aa) != len(bb):
            raise NotProven('control-flow graphs do not pair')
        for x, y in zip(aa, bb):
            if (x in pairing and pairing[x] != y) or (y in reverse and reverse[y] != x):
                raise NotProven('control-flow graphs do not pair')
            if x not in pairing:
                pairing[x], reverse[y] = y, x
                todo.append(x)
    frames = Frames((a, b))
    checker.routes.append("frames-finite" if finite else "frames")
    for side,code in enumerate((a,b)):
        check_initialized(checker,code,side,frames.lows[side])
    local = [{}, {}]
    for i, j in pairing.items():
        for pred in (lambda x: x.mnemonic == 'call', lambda x: x.mnemonic in FP_OPS):
            aa = [a[k] for k in graphs[0][i][0] if pred(a[k])]
            bb = [b[k] for k in graphs[1][j][0] if pred(b[k])]
            for x, y in zip(aa, bb):
                local[0][x.address] = local[1][y.address] = x.address
    machines = [FrameMachine(checker.inp.addresses, side, local, frames) for side in (0, 1)]
    for i, j in pairing.items():
        aa = [a[k] for k in graphs[0][i][0] if a[k].mnemonic == 'call']
        bb = [b[k] for k in graphs[1][j][0] if b[k].mnemonic == 'call']
        for x, y in zip(aa, bb):
            if x.operands[0].type == y.operands[0].type == X.X86_OP_IMM:
                old = callee_cleanup(checker, 0, x.operands[0].imm)
                new = callee_cleanup(checker, 1, y.operands[0].imm)
                if old is not None and old == new:
                    machines[0].cleanups[x.address] = old
                    machines[1].cleanups[y.address] = new
                    if stack_insensitive_leaf(checker, 0, x.operands[0].imm) and stack_insensitive_leaf(checker, 1, y.operands[0].imm):
                        machines[0].private_calls.add(x.address)
                        machines[1].private_calls.add(y.address)
    frames.budget = limits.WorkBudget(8000,'frame relation inference budget')
    budget = frames.budget.step
    infos=[check_initialized(checker,c,s,frames.lows[s]) for s,c in enumerate((a,b))]
    def execute(i, states):
        for side,st in enumerate(states):
            if not hasattr(st,'ownership'):Ownership(checker,infos[side],frames.stack,(i,pairing[i])[side]).prepare(st)
        for side, code in enumerate((a, b)):
            for k in graphs[side][(i, pairing[i])[side]][0]:
                machines[side].step(states[side], code[k])
            tail=graphs[side][(i,pairing[i])[side]][0][-1]
            states[side].frame_defined=infos[side]['after'][tail][1]
        return states
    initial, _ = frames.states(initial=True)
    if finite:
        pending = [(0, initial, z3.BoolVal(True), frozenset())]
        visits = 0
        while pending:
            budget()
            i, states, guard, seen = pending.pop()
            if i in seen:
                raise NotProven('loop requires an inductive frame relation')
            visits += 1
            if visits > 6000 or len(pending) > 128:
                raise NotProven('finite frame path budget')
            for st in states:st.path=guard
            execute(i, states)
            if not prove([z3.Implies(guard, conjunction(frame_goals(frames, states)))]):
                raise NotProven('finite frame paths differ')
            edges = graphs[0][i][1]
            for edge, target in enumerate(edges):
                branch = edge_guard(states[0], a[graphs[0][i][0][-1]], len(edges), edge)
                next_guard = simp(z3.And(guard, branch))
                if not z3.is_false(next_guard):
                    pending.append((target, frames.clone(states), next_guard, seen | {i}))
        return 'PROVEN', ''
    samples, todo = {}, [(0, frames.clone(initial))]
    while todo:
        budget()
        i, states = todo.pop()
        if i in samples:
            continue
        samples[i] = frames.clone(states)
        execute(i, states)
        todo.extend((j, frames.clone(states)) for j in graphs[0][i][1] if j not in samples)
    candidates = {i: frames.candidates(samples[i]) for i in pairing}
    def held(guard, facts, states):
        budget()
        established, pending = set(), {}
        for f in sorted(facts,key=repr):
            expr = simp(frames.fact(states, f))
            if z3.is_true(expr):
                established.add(f)
            elif not z3.is_false(expr):
                pending[f] = expr
        retained = established | conditional_facts(guard, pending)
        # A few false byte proposals can exhaust the batch model budget. Keep
        # a proved affine word relation even when that conservative filter
        # discards the remainder of the batch.
        affine = [f for f in pending if f[0] == 'affine' and f not in retained]
        affine.sort(key=lambda f: isinstance(f[1][1], str) and isinstance(f[2][1], str))
        for f in affine[:32]:
            budget()
            if prove([z3.Implies(guard, pending[f])]):
                retained.add(f)
        return retained
    candidates[0] &= held(z3.BoolVal(True), candidates[0], initial)
    queue, queued, visited = collections.deque([0]), {0}, set()
    while queue:
        budget()
        i = queue.popleft()
        queued.discard(i)
        states, premise = frames.states(candidates[i])
        for st in states:st.path=premise
        execute(i, states)
        edges = graphs[0][i][1]
        for edge, target in enumerate(edges):
            guard = z3.And(premise, edge_guard(states[0], a[graphs[0][i][0][-1]], len(edges), edge))
            kept = held(guard, candidates[target], states)
            changed = kept != candidates[target]
            candidates[target] &= kept
            if (target not in visited or changed) and target not in queued:
                queue.append(target)
                queued.add(target)
        visited.add(i)
    if not prove([frames.fact(initial, f) for f in sorted(candidates[0],key=repr)]):
        raise NotProven('frame relation is not initialized')
    for i, j in pairing.items():
        budget()
        states, premise = frames.states(candidates[i])
        for st in states:st.path=premise
        execute(i, states)
        old, new = states
        goals = frame_goals(frames, states)
        edges = graphs[0][i][1]
        for edge, target in enumerate(edges):
            guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges), edge)
            goals += [z3.Implies(guard, frames.fact(states, f)) for f in sorted(candidates[target],key=repr)]
        if not prove([z3.Implies(premise, conjunction(goals))]):
            raise NotProven('private frame relation does not prove the transition')
    return 'PROVEN', ''


class Checker:
    def __init__(self, inp):
        self.inp = inp
        self.routes = []
        self.cache = verdict_cache.Cache(self,inp.cache_dir) if getattr(inp,'cache_dir',None) else None

    def instructions(self, fn):
        # Retain full instructions for proof; never use match.py's truncated
        # compiled stream as evidence that the function ended.
        oe = match.find_import_thunk(self.inp.old, 'System.@HandleOnException')
        ne = self.inp.addresses.map_addresses.get('@HandleOnException')
        verdict_cache.handles(oe,ne)
        verdict_cache.note(self.inp.old,fn.ova,fn.osize)
        a = decode(self.inp.old, fn.ova, fn.osize)
        size = fn.osize
        if any('fs:' in i.op_str for i in a):
            # Ghidra signatures often stop at the handler descriptor, omitting
            # the continuation and epilogue. Bound extension by the next known
            # function as well as a small decoding limit; reachability decides
            # which bytes are code, never the matcher truncation.
            end = min((p for p, _ in self.inp.sigs.values() if p > fn.ova), default=fn.ova + fn.osize + 128)
            size = min(end - fn.ova, fn.osize + 128)
        verdict_cache.note(self.inp.old,fn.ova,size);verdict_cache.note(self.inp.new,fn.nva,fn.nsize)
        a = decode(self.inp.old, fn.ova, size, oe)
        b = decode(self.inp.new, fn.nva, fn.nsize, ne)
        # Ordinary trailing alignment is unreachable, and is excluded by CFG
        # reachability, rather than interpreted as executable data.
        return a, b

    def exception_regions(self, code, side):
        """Recognize Delphi's three-word FS chain record and handler descriptor.

        A handler is a separate, universally quantified region, not dead code.
        Its private incoming nonvolatile registers are independent. Only the
        saved frame / runtime stack and runtime-produced volatile registers
        correspond. This deliberately loses proofs that need try-body facts.
        """
        code = [dataclasses.replace(i) for i in code]
        by_addr = {i.address: j for j, i in enumerate(code)}
        regions = []
        allowed_fs = set()
        for k, ins in enumerate(code):
            if not (ins.mnemonic == 'mov' and len(ins.operands) == 2
                    and ins.operands[0].type == X.X86_OP_MEM
                    and ins.reg_name(ins.operands[0].mem.segment) == 'fs'
                    and ins.operands[1].type == X.X86_OP_REG
                    and ins.reg_name(ins.operands[1].reg) == 'esp'):
                continue
            if k < 3 or any(code[k-d].mnemonic != 'push' for d in (1, 2, 3)):
                raise Unsupported('unrecognized Delphi exception frame')
            previous, descriptor, saved = (code[k-d].operands[0] for d in (1, 2, 3))
            if not (previous.type == X.X86_OP_MEM and ins.reg_name(previous.mem.segment) == 'fs'
                    and descriptor.type == X.X86_OP_IMM and saved.type == X.X86_OP_REG
                    and ins.reg_name(saved.reg) == 'ebp'):
                raise Unsupported('unrecognized Delphi exception frame')
            d = by_addr.get(descriptor.imm)
            if d is None or code[d].mnemonic != 'jmp' or code[d].operands[0].type != X.X86_OP_IMM or code[d].size != 5:
                raise Unsupported('unrecognized Delphi handler descriptor')
            target = code[d].operands[0].imm
            name = verdict_cache.handler_name(self.inp.addresses,side,target)
            kind = name.rsplit('.', 1)[-1]
            if kind not in ('@HandleFinally', '@HandleAnyException', '@HandleOnException', '@HandleAutoException'):
                raise Unsupported('unknown Delphi exception helper')
            metadata = [target, descriptor.imm]
            roots = [code[d].address + 5]
            if kind == '@HandleOnException':
                img = (self.inp.old, self.inp.new)[side]
                table = code[d].address + 5
                n = Addresses.u32(img, table)
                if not 0 < n < 16:
                    raise Unsupported('exception handler table')
                roots = []
                for t in range(n):
                    cls, handler = struct.unpack('<II', img.bytes_at(table + 4 + t * 8, 8))
                    metadata.extend((cls, handler))
                    roots.append(handler)
            ret = None
            if kind == '@HandleFinally':
                if d + 1 >= len(code) or code[d+1].mnemonic != 'jmp' or code[d+1].operands[0].type != X.X86_OP_IMM:
                    raise Unsupported('finally cleanup entry')
                body = by_addr.get(code[d+1].operands[0].imm)
                if body is None or body == 0 or code[body-1].mnemonic != 'push' or code[body-1].operands[0].type != X.X86_OP_IMM or code[d-1].mnemonic != 'ret':
                    raise Unsupported('finally continuation shape')
                continuation = code[body-1].operands[0].imm
                if continuation not in by_addr:
                    raise Unsupported('incomplete finally continuation')
                ret = d - 1
                # Also compare the return as an observable exit. Following its
                # paired continuation unconditionally is an overapproximation:
                # a havoced stack target must never hide the real epilogue.
                code[ret].flow = (continuation,)
                metadata.extend((code[d+1].operands[0].imm, continuation))
            allowed_fs.update((k - 1, k))
            ins.eh = tuple(metadata)
            regions.append((d, roots, ret, tuple(metadata)))
        for k, ins in enumerate(code):
            fs = [o for o in ins.operands if o.type == X.X86_OP_MEM and ins.reg_name(o.mem.segment) == 'fs']
            if not fs or k in allowed_fs:
                continue
            # The ordinary uninstall pops the old FS chain and the other
            # two record words, then writes the old chain back to FS:[0].
            if (regions and ins.mnemonic == 'mov' and len(ins.operands) == 2
                    and ins.operands[0] in fs and ins.operands[1].type == X.X86_OP_REG
                    and k >= 3 and all(code[j].mnemonic == 'pop' and code[j].operands[0].type == X.X86_OP_REG for j in range(k-3, k))
                    and code[k-3].operands[0].reg == ins.operands[1].reg
                    and not fs[0].mem.disp and not fs[0].mem.index):
                allowed_fs.add(k)
            else:
                raise Unsupported('FS access outside a modeled exception frame')
        # FS is modeled as a separate byte array. An FS access without a
        # recognized installation must fail closed rather than skip a handler.
        if any('fs:' in i.op_str for i in code) and not regions:
            raise Unsupported('unrecognized Delphi exception frame')
        return code, regions

    def verify_regions(self, a, b, ar, br):
        if len(ar) != len(br):
            raise NotProven('exception frames do not pair')
        for (d, roots, ret, meta), (e, other, oret, ometa) in zip(ar, br):
            if len(roots) != len(other) or len(meta) != len(ometa):
                raise NotProven('exception handlers do not pair')
            aa = [dataclasses.replace(i) for i in a]
            bb = [dataclasses.replace(i) for i in b]
            for code, entry, targets, cleanup, metadata in ((aa, d, roots, ret, meta), (bb, e, other, oret, ometa)):
                code[entry].mnemonic = 'eh-enter'
                code[entry].eh = metadata
                code[entry].flow = tuple(targets)
                if cleanup is not None:
                    code[cleanup].flow = ()
                    code[cleanup].handler_return = True
            # The helper can choose any matching table entry. Each path is
            # checked, and the ordered class/handler table is an input event.
            self.verify(aa, bb, (d, e), frozenset((r, r, lane) for r in ('eax', 'edx', 'ecx', 'ebp', 'esp') for lane in range(4)), ())

    def local_cfg(self, a, b, ar, br):
        """Propose only local block identities; all regions still need proof.

        A single bijection covers ordinary and exceptional roots. In particular
        continuation targets must agree with the ordinary CFG, not push positions.
        No external address or arbitrary instruction interior enters this map.
        """
        if len(ar) != len(br):
            raise NotProven('exception frames do not pair')
        variants = [(a, b, 0, 0)]
        for (d, roots, ret, meta), (e, other, oret, ometa) in zip(ar, br):
            if len(roots) != len(other) or len(meta) != len(ometa):
                raise NotProven('exception handlers do not pair')
            aa, bb = [[dataclasses.replace(i) for i in code] for code in (a, b)]
            for code, entry, targets, cleanup in ((aa,d,roots,ret),(bb,e,other,oret)):
                code[entry].flow = tuple(targets)
                if cleanup is not None:
                    code[cleanup].flow = ()
            variants.append((aa, bb, d, e))
        pairs, reverse = {}, {}
        for aa, bb, d, e in variants:
            graphs = blocks(aa, d, preserve=True), blocks(bb, e, preserve=True)
            todo, seen = [(d, e)], set()
            while todo:
                i, j = todo.pop()
                if (i,j) in seen:
                    continue
                seen.add((i,j))
                x, y = aa[i].address, bb[j].address
                if pairs.get(x,y) != y or reverse.get(y,x) != x:
                    raise NotProven('local CFG identities conflict')
                pairs[x], reverse[y] = y, x
                left, right = graphs[0][i][1], graphs[1][j][1]
                if len(left) != len(right):
                    raise NotProven('local CFG edges do not pair')
                todo.extend(zip(left, right))
        return pairs

    def check(self, fn, mutated=None, matched=False):
        verdict_cache.prepare(self)
        self.cache_hit=None
        def run():
            if matched:return 'MATCH',''
            with verdict_cache.proof_context(self):return self._check(fn,mutated)
        return self.cache.run(fn,run,matched) if self.cache is not None and mutated is None else run()

    def _check(self, fn, mutated=None):
        self.image_relation = None
        self.contracts = None
        self.garbage_witness = None
        self.pending_diagnostic = None
        self.garbage_cache = {}
        self.frame_lows = None
        self.exception_whole_only = False
        self.routes = []
        try:
            result = self.check_raw(fn,mutated)
        except limits.SafetyCap as error:
            self.garbage_witness = None
            self.pending_diagnostic = None
            result = 'NOT PROVEN',str(error)
        except (NotProven,Unsupported) as error:
            result = ('UNSUPPORTED' if isinstance(error,Unsupported) else 'NOT PROVEN'),str(error)
        self.last_contracts = dict(hypotheses={h:[r for _,_,r in self.contracts.sites.values() if h in r.get('premises',[r.get('premise','H3')])] for h in ('H3','H3c') if any(h in r.get('premises',[r.get('premise','H3')]) for _,_,r in self.contracts.sites.values())} if self.contracts else {},
                                   dependencies=sorted(self.contracts.dependencies) if self.contracts else [],
                                   alias_resolutions=getattr(self.inp.addresses,'alias_resolutions',[]))
        if result[0]=='NOT PROVEN' and self.pending_diagnostic and not self.garbage_witness:
            try:result=('NOT PROVEN',correspondence_failure(*self.pending_diagnostic))
            except limits.SafetyCap as error:result=('NOT PROVEN',str(error))
            except NotProven as error:result=('NOT PROVEN',str(error))
        self.pending_diagnostic=None
        self.last_contracts['solver_limits'] = dict(rlimit=limits.RLIMIT, expected_ms=limits.EXPECTED_MS, safety_factor=10,
                                                  work_units_per_ms=limits.UNITS_PER_MS, inference_expected_ms=limits.INFERENCE_EXPECTED_MS, max_steps=limits.MAX_STEPS)
        if result[0]=='NOT PROVEN' and self.garbage_witness:
            w=self.garbage_witness
            reason=('uninitialized local passed to callee at %s (callee write not checked)'%w['pc'] if w['kind']=='callee' else
                    'reads uninitialized private slot (side %d, %s, offset %d)'%(w['side'],w['pc'],w['offset']))
            if w.get('callee_read'):reason+='; callee read at '+w['callee_read']['pc']+' ('+w['callee_read']['instruction']+')'
            if w.get('callee_scan'):reason+='; callee scan at '+w['callee_scan']['pc']+' ('+w['callee_scan']['instruction']+'; '+w['callee_scan'].get('reason','no checked must-write summary')+')'
            result=('NOT PROVEN',reason)
        if result[0].startswith('PROVEN'):self.garbage_witness=None
        self.last_contracts['entry_separation'] = sorted(getattr(self.contracts,'entry_separation',{}).values(),key=str) if self.contracts else []
        self.last_contracts['routes'] = self.routes
        self.last_contracts['summary_budgets'] = sorted(self.contracts.summary_budgets.values(),key=lambda r:(r['side'],r['image'],r['hop'],r['target'])) if self.contracts else []
        self.last_contracts['frame_garbage'] = dict(independent=True, extents=getattr(self,'frame_lows',None), witness=self.garbage_witness, exception_whole_only=getattr(self,'exception_whole_only',False))
        if self.contracts and self.contracts.h1:
            self.last_contracts['hypotheses']['H1'] = dict(predicate='EntrySeparation: ESP_entry is in [0x10000+extent,0x80000000); incoming EAX/EDX/ECX, stack-argument words and guarded public four-byte loads lie outside each side [ESP_entry+low,ESP_entry). Explicit solver predicates and proven origin locations are in entry_separation. Array reasoning retains aliases.',instances=sorted(self.contracts.h1))
        if self.contracts and self.contracts.h5:
            self.last_contracts['hypotheses']['H5'] = dict(predicate='All ordinary data/stack writes in this function and its callees are disjoint from these reviewed immutable storage ranges; no concrete overlapping write is admitted.',
                                                         instances=sorted(self.contracts.h5))
        if self.image_relation is not None:
            self.last_contracts['image_relation'] = self.image_relation.summary()
            if self.image_relation.checked:
                self.last_contracts['hypotheses'].setdefault('H5',dict(instances=[]))['image_relation'] = self.image_relation.summary()
                self.last_contracts['hypotheses']['H5']['predicate'] = 'Checked storage has equal normalized startup contents and justified coverage; mutable runtime values remain arbitrary. Remaining module-wide initial/alias relation and preservation of immutable storage by external effects are assumed.'
        if result[0] == 'PROVEN' and self.last_contracts['hypotheses']:
            result = 'PROVEN under '+','.join(sorted(self.last_contracts['hypotheses'])),'see --explain for instantiated contracts'
        return result

    def check_raw(self, fn, mutated=None):
        addresses = self.inp.addresses
        saved = addresses.forward, addresses.reverse, addresses.conflicts, addresses.provenance, [dict(v) for v in addresses.immutable_data]
        addresses.consulted.clear()
        addresses.unresolved.clear()
        # Proof attempts use snapshots of independently established bindings.
        # No proof route may teach the next proof an identity.
        addresses.forward = dict(addresses.forward)
        addresses.reverse = dict(addresses.reverse)
        addresses.conflicts = set(addresses.conflicts)
        addresses.provenance = dict(addresses.provenance)
        self.local_cfg_only = False
        try:
            a, b = self.instructions(fn)
            a, ar = self.exception_regions(a, 0)
            b, br = self.exception_regions(b, 1)
            if mutated is not None:
                b, br = self.exception_regions(mutated, 1)
            from equiv_calls import ensure
            ensure(self,a,b)
            addresses.active_cells = [set(), set()]
            relation = image_relation.Relation.__new__(image_relation.Relation)
            self.image_relation = relation
            relation.__init__(self,(a,b))
            image_relation.ACTIVE = relation
            for side, code in enumerate((a,b)):
                for ins in code:  # Include unreachable suffixes, not only the chosen proof path.
                    for index, op in enumerate(ins.operands):
                        if op.type != X.X86_OP_MEM or op.mem.segment:
                            continue
                        overlaps = {cell for cell,width in addresses.protected(side).items()
                                    if max(cell,op.mem.disp) < min(cell+width,op.mem.disp+op.size)}
                        if overlaps and ins.raw.operands[index].access & CS.CS_AC_WRITE:
                            raise Unsupported('write to accepted pointer cell')
                        addresses.active_cells[side].update(overlaps)
            try:
                local = self.local_cfg(a, b, ar, br)
            except (NotProven, Unsupported):
                local = {}  # Other routes may prove code needing no local identity.
            for x, y in local.items():
                if a[0].address <= x < max(i.address+i.size for i in a) and b[0].address <= y < fn.nva+fn.nsize:
                    if not addresses.bind(x, y, 'local-cfg'):
                        raise NotProven('local CFG binding conflicts')
            self.local_cfg_only = any(addresses.provenance.get((v,addresses.forward.get(v)) if side == 0
                                      else (addresses.reverse.get(v),v)) == 'local-cfg'
                                      for side,code in enumerate((a,b)) for ins in code
                                      if not ins.mnemonic.startswith('j')
                                      for v in (*ins.eh, *(addresses.absolute(side, ins, op) for op in ins.operands)) if v is not None)
            # Resolve metadata before any route gate; class positions cannot bind identities.
            for side,regions in enumerate((ar,br)):
                for _,_,_,meta in regions:
                    for value in meta:
                        addresses.canonical(side,value,[{},{}])
            self.exception_whole_only = bool(ar or br)
            self.frame_lows = [private_extent(code) for code in (a,b)]
            for side,code in enumerate((a,b)):
                check_initialized(self,code,side,self.frame_lows[side])
            if self.exception_whole_only and any(self.frame_lows):
                raise Unsupported('exception region requires linked private-entry relation')
            self.verify_regions(a, b, ar, br)
            if self.local_cfg_only:
                return self.verify_fast(a, b)  # No alternate pairing may reuse these identities.
            try:
                return self.verify(a, b)
            except (NotProven, Unsupported) as first:
                if self.exception_whole_only:
                    raise first
                if any(p == 'local-cfg' for _,_,p in addresses.consulted):
                    raise first
                addresses.allow_local_cfg = False
                try:
                    return verify_frames(self, a, b)
                except (NotProven, Unsupported):
                    pass
                try:
                    return verify_frames(self, a, b, finite=True)
                except (NotProven, Unsupported):
                    pass
                try:
                    graphs = [blocks(a), blocks(b)]
                    for aligned in cfg_variants(a, b, graphs, (0, 0), self.inp.addresses):
                        try:
                            return verify_frames(self, a, aligned)
                        except (NotProven, Unsupported):
                            pass
                except (NotProven, Unsupported):
                    pass
                if str(first) == 'control-flow graphs do not pair':
                    raise first
                try:
                    return self.acyclic(a, b)
                except (Unsupported, NotProven):
                    raise first
        except Unsupported as e:
            return 'UNSUPPORTED', str(e)
        except NotProven as e:
            self.pending_diagnostic=getattr(e,'diagnostic',None)
            return 'NOT PROVEN', str(e)[:80]
        finally:
            image_relation.ACTIVE = None
            addresses.allow_local_cfg = True
            addresses.active_cells = [set(),set()]
            self.local_cfg_only = False
            addresses.forward, addresses.reverse, addresses.conflicts, addresses.provenance, addresses.immutable_data = saved

    def verify(self, a, b, entry=(0, 0), entry_candidates=DIAG, entry_flags=FLAGS):
        saved = self.inp.addresses.allow_local_cfg
        try:
            return self.verify_paired(a,b,entry,entry_candidates,entry_flags)
        finally:
            self.inp.addresses.allow_local_cfg = saved

    def verify_paired(self, a, b, entry, entry_candidates, entry_flags):
        if getattr(self, 'local_cfg_only', False):
            return self.verify_fast(a, b, entry, entry_candidates, entry_flags)
        # Keep the inexpensive structural proof as a sufficient fast path.
        # Liveness is computed before relational candidate discovery.
        graphs = [blocks(a, entry[0]), blocks(b, entry[1])]
        live = [live_locations(code, graph) for code, graph in zip((a, b), graphs)]
        try:
            return self.verify_fast(a, b, entry, entry_candidates, entry_flags)
        except NotProven as first:
            if any(p == 'local-cfg' for _,_,p in self.inp.addresses.consulted):
                raise first
            self.inp.addresses.allow_local_cfg = False
            if str(first) != 'control-flow graphs do not pair':
                try:
                    return self.houdini(a, b, graphs, live, entry, entry_candidates, entry_flags)
                except NotProven:
                    pass
            for aligned in cfg_variants(a, b, graphs, entry, self.inp.addresses):
                try:
                    return self.verify_fast(a, aligned, entry, entry_candidates, entry_flags)
                except NotProven:
                    aligned_graphs = [graphs[0], blocks(aligned, entry[1])]
                    aligned_live = [live[0], live_locations(aligned, aligned_graphs[1])]
                    try:
                        return self.houdini(a, aligned, aligned_graphs, aligned_live, entry, entry_candidates, entry_flags)
                    except NotProven:
                        pass
            raise first

    def houdini(self, a, b, graphs, live, entry, entry_candidates, entry_flags):
        """Infer a live-location relation, then prove initialization and all edges.

        A spanning-tree symbolic execution proposes constants and affine frame
        facts only; it is not a loop proof. Every candidate, including those
        proposals, must survive all predecessors in the Houdini fixed point.
        Solver timeouts discard facts, and a budget expiry never proves code.
        """
        from equiv_calls import ensure
        ensure(self,a,b)
        work = limits.WorkBudget(2500,'relational inference budget')
        budget = work.step
        pairing, reverse, todo = {entry[0]: entry[1]}, {entry[1]: entry[0]}, [entry[0]]
        while todo:
            i = todo.pop()
            aa, bb = graphs[0][i][1], graphs[1][pairing[i]][1]
            if len(aa) != len(bb):
                raise NotProven('control-flow graphs do not pair')
            for x, y in zip(aa, bb):
                if x in pairing:
                    if pairing[x] != y:
                        raise NotProven('control-flow graphs do not pair')
                else:
                    if y in reverse:
                        raise NotProven('control-flow graphs do not pair')
                    pairing[x], reverse[y] = y, x
                    todo.append(x)
        local = [{}, {}]
        for i, j in pairing.items():
            for pred in (lambda ins: ins.mnemonic == 'call', lambda ins: ins.mnemonic in FP_OPS):
                aa = [a[k] for k in graphs[0][i][0] if pred(a[k])]
                bb = [b[k] for k in graphs[1][j][0] if pred(b[k])]
                for x, y in zip(aa, bb):
                    local[0][x.address] = local[1][y.address] = x.address
        machines = [Machine(self.inp.addresses, s, local) for s in (0, 1)]
        garbage = CutGarbage(self,(a,b))
        def execute(i, states, prepare=True):
            if prepare:garbage.prepare(states,(i,pairing[i]))
            for side, code in enumerate((a, b)):
                for k in graphs[side][(i, pairing[i])[side]][0]:
                    garbage.step(machines[side],states[side],side,k)
            return states
        def clone(states):
            clones=[State(dict(s.regs), dict(s.flags), s.memory, s.fs, s.fp) for s in states]
            for source,target in zip(states,clones):target.image_origins={k:set(v) for k,v in getattr(source,'image_origins',{}).items()}
            for st,clone in zip(states,clones):clone_ownership(st,clone)
            return clones
        initial = arbitrary(entry_candidates, entry_flags)
        garbage.prepare(initial,entry)
        samples, todo = {}, [(entry[0], clone(initial))]
        while todo:
            budget()
            i, states = todo.pop()
            if i in samples:
                continue
            samples[i] = clone(states)
            states = execute(i, states)
            todo.extend((j, clone(states)) for j in graphs[0][i][1] if j not in samples)
        candidates = {}
        for i, j in pairing.items():
            budget()
            ll, rr = live[0][i], live[1][j]
            facts = {('eq', x, y) for x in ll for y in rr if (x[0] == 'f') == (y[0] == 'f')}
            if len(facts) > 16000:
                raise NotProven('live-location candidate budget')
            for side, locs in enumerate((ll, rr)):
                st = samples[i][side]
                for loc in sorted(locs,key=repr):
                    value = simp(location_value(st, loc))
                    if z3.is_bv_value(value):
                        facts.add(('const', side, loc, value.as_long()))
                    elif z3.is_true(value) or z3.is_false(value):
                        facts.add(('const', side, loc, z3.is_true(value)))
                regs = {loc[1] for loc in locs if loc[0] == 'r'}
                for reg in sorted(regs):
                    for base in sorted(regs & {'ebp', 'esp'}):
                        if reg != base:
                            delta = simp(st.regs[reg] - st.regs[base])
                            if z3.is_bv_value(delta):
                                facts.add(('delta', side, reg, base, delta.as_long()))
            candidates[i] = facts
        def held(premise, equations):
            budget()
            established, remaining = set(), {}
            for key in ordered(equations):
                expr = equations[key]
                expr = simp(expr)
                if z3.is_true(expr):
                    established.add(key)
                elif not z3.is_false(expr):
                    remaining[key] = expr
            established |= conditional_facts(premise, remaining)
            return established
        root = entry[0]
        candidates[root] &= held(z3.BoolVal(True), {f: fact_expression(initial, f) for f in sorted(candidates[root],key=repr)})
        queue, queued = collections.deque([root]), {root}
        visited = set()
        while queue:
            budget()
            i = queue.popleft()
            queued.discard(i)
            states, _ = relation_states(candidates[i])
            garbage.prepare(states,(i,pairing[i]))
            premise=simp(z3.And([fact_expression(states,f) for f in sorted(candidates[i],key=repr)]))
            states = execute(i, states,False)
            edges = graphs[0][i][1]
            terminal = a[graphs[0][i][0][-1]]
            for edge, target in enumerate(edges):
                guard = z3.And(premise, edge_guard(states[0], terminal, len(edges), edge))
                retained = held(guard, {f: fact_expression(states, f) for f in sorted(candidates[target],key=repr)})
                changed = retained != candidates[target]
                candidates[target] &= retained
                if target not in visited or changed:
                    if target not in queued:
                        queue.append(target)
                        queued.add(target)
            visited.add(i)
        # Initialization and preservation are proof obligations, not assumptions
        # justified by the sampled paths. Memory, events and conditions are
        # checked universally under each retained relation.
        if not prove([fact_expression(initial, f) for f in sorted(candidates[root],key=repr)]):
            raise NotProven('relation is not initialized')
        for i, j in pairing.items():
            budget()
            states, _ = relation_states(candidates[i])
            garbage.prepare(states,(i,pairing[i]))
            premise=simp(z3.And([fact_expression(states,f) for f in sorted(candidates[i],key=repr)]))
            old, new = execute(i, states,False)
            if len(old.events) != len(new.events):
                raise NotProven('different observable events')
            tails=(graphs[0][i][0][-1],graphs[1][pairing[i]][0][-1])
            memories=garbage.memories(states,tails)
            goals = [memories[0] == memories[1], old.fs == new.fs, old.fp == new.fp, old.condition == new.condition]
            for x, y in zip(old.events, new.events):
                if x[0] != y[0] or len(x) != len(y):
                    raise NotProven('different observable events')
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            edges = graphs[0][i][1]
            for edge, target in enumerate(edges):
                guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges), edge)
                goals += [z3.Implies(guard, fact_expression(states, f)) for f in sorted(candidates[target],key=repr)]
            if not prove(guarded(states,[z3.Implies(premise, conjunction(goals))])):
                garbage.failed(tails)
                raise NotProven('live-location relation does not prove the transition')
        return 'PROVEN', ''

    def verify_fast(self, a, b, entry=(0, 0), entry_candidates=DIAG, entry_flags=FLAGS):
        from equiv_calls import ensure
        ensure(self,a,b)
        self.routes = getattr(self,"routes",[])
        self.routes.append("whole-memory")
        if not a or not b:
            raise Unsupported('empty disassembly')
        lows = [private_extent(c) for c in (a,b)]
        for side,code in enumerate((a,b)):
            check_initialized(self,code,side,lows[side])
        graphs = [blocks(a, entry[0]), blocks(b, entry[1])]
        for side, graph in enumerate(graphs):
            for seq, _ in graph.values():
                for k in seq:
                    ins = (a, b)[side][k]
                    if any(o.type == X.X86_OP_MEM and o.mem.segment and ins.reg_name(o.mem.segment) != 'fs' and not (ins.mnemonic in STRING_OPS and ins.reg_name(o.mem.segment) == 'es') for o in ins.operands):
                        raise Unsupported('segment override')
                    if ins.mnemonic not in INTEGER_OPS | FP_OPS | STRING_OPS | {'eh-enter'} and not ins.mnemonic.startswith(('j', 'set')):
                        raise Unsupported(ins.mnemonic)
        pairing = {entry[0]: entry[1]}
        reverse = {entry[1]: entry[0]}
        todo = [entry[0]]
        edges = {}
        while todo:
            i = todo.pop()
            if i in edges:
                continue
            j = pairing[i]
            aa, bb = graphs[0][i][1], graphs[1][j][1]
            if len(aa) != len(bb):
                raise NotProven('control-flow graphs do not pair')
            edges[i] = aa
            for x, y in zip(aa, bb):
                if (x in pairing and pairing[x] != y) or (y in reverse and reverse[y] != x):
                    raise NotProven('control-flow graphs do not pair')
                pairing[x], reverse[y] = y, x
                todo.append(x)
        local = [{}, {}]
        for i, j in pairing.items():
            aa, bb = graphs[0][i][0], graphs[1][j][0]
            local[0][a[i].address] = local[1][b[j].address] = a[i].address
            # Calls in a block correspond by event order, not their byte offsets.
            ac = [k for k in aa if a[k].mnemonic == 'call']
            bc = [k for k in bb if b[k].mnemonic == 'call']
            for x, y in zip(ac, bc):
                local[0][a[x].address] = local[1][b[y].address] = a[x].address
            if len(aa) == len(bb):
                for x, y in zip(aa, bb):
                    local[0].setdefault(a[x].address, a[x].address)
                    local[1].setdefault(b[y].address, a[x].address)
                    # An anonymous import cell is matched only when both PE
                    # relocations name the same already identified object.
                    for u, v in zip(a[x].operands, b[y].operands):
                        if (u.type == v.type == X.X86_OP_IMM and a[x].mnemonic == b[y].mnemonic
                                and a[x].operands[0].type == b[y].operands[0].type == X.X86_OP_REG
                                and a[x].reg_name(a[x].operands[0].reg) == b[y].reg_name(b[y].operands[0].reg)):
                            sx = self.inp.addresses.string_object(0, u.imm)
                            sy = self.inp.addresses.string_object(1, v.imm)
                            if sx is not None and sy is not None:
                                if sx != sy:
                                    raise NotProven('read-only string argument differs')
        machines = [Machine(self.inp.addresses, s, local) for s in (0, 1)]
        garbage = CutGarbage(self,(a,b))
        candidates = {i: set(entry_candidates if i == entry[0] else ALL) for i in edges}
        flag_candidates = {i: set(entry_flags if i == entry[0] else FLAGS) for i in edges}
        queue = collections.deque([entry[0]])
        queued = {entry[0]}
        visited = set()
        while queue:
            i = queue.popleft()
            queued.discard(i)
            states = arbitrary(candidates[i], flag_candidates[i])
            garbage.prepare(states,(i,pairing[i]))
            for s in (0, 1):
                for k in graphs[s][(i, pairing[i])[s]][0]:
                    garbage.step(machines[s],states[s],s,k)
            old, new = states
            old_bytes = {(r, k): register_byte(old, r, k) for r in REGS for k in range(4)}
            new_bytes = {(r, k): register_byte(new, r, k) for r in REGS for k in range(4)}
            after = {(x, y, k) for x in REGS for y in REGS for k in range(4) if equal(old_bytes[x, k], new_bytes[y, k])}
            flags = {f for f in FLAGS if equal(old.flags[f], new.flags[f])}
            for edge, j in enumerate(edges[i]):
                kept = set(after)
                kept_flags = set(flags)
                if len(edges[i]) == 2:
                    guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges[i]), edge)
                    equations = {('r', x, y, k): old_bytes[x, k] == new_bytes[y, k]
                                 for x, y, k in sorted(candidates[j] - after)}
                    equations.update({('f', f): old.flags[f] == new.flags[f] for f in sorted(flag_candidates[j] - flags)})
                    for fact in conditional_facts(guard, equations):
                        if fact[0] == 'r':
                            kept.add(fact[1:])
                        else:
                            kept_flags.add(fact[1])
                changed = False
                if not candidates[j] <= kept:
                    candidates[j] &= kept
                    changed = True
                if not flag_candidates[j] <= kept_flags:
                    flag_candidates[j] &= kept_flags
                    changed = True
                if j not in visited or changed:
                    if j not in queued:
                        queue.append(j)
                        queued.add(j)
            visited.add(i)
        # The fixed point is only a proposal.  Prove every transition and
        # observable event again without entry-path-specific assumptions.
        for i in sorted(edges):
            states = arbitrary(candidates[i], flag_candidates[i])
            garbage.prepare(states,(i,pairing[i]))
            for s in (0, 1):
                for k in graphs[s][(i, pairing[i])[s]][0]:
                    garbage.step(machines[s],states[s],s,k)
            old, new = states
            if len(old.events) != len(new.events):
                raise NotProven('different observable events at instruction %d' % i)
            tails=(graphs[0][i][0][-1],graphs[1][pairing[i]][0][-1])
            memories=garbage.memories(states,tails)
            goals = [memories[0] == memories[1], old.fs == new.fs, old.fp == new.fp, old.condition == new.condition]
            for x, y in zip(old.events, new.events):
                if x[0] != y[0] or len(x) != len(y):
                    raise NotProven('different observable events at instruction %d' % i)
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            relations=[]
            for edge, j in enumerate(edges[i]):
                guard = edge_guard(old, a[graphs[0][i][0][-1]], len(edges[i]), edge)
                related=[('%s[%d]/%s[%d]'%(x,k,y,k),z3.Implies(guard,register_byte(old,x,k)==register_byte(new,y,k))) for x,y,k in sorted(candidates[j])]+[(f,z3.Implies(guard,old.flags[f]==new.flags[f])) for f in sorted(flag_candidates[j])]
                relations+=related;goals += [goal for _,goal in related]
            if not prove(guarded(states,goals)):
                garbage.failed(tails)
                failure=NotProven('symbolic transition differs')
                failure.diagnostic=(states,memories,(a[tails[0]].address,b[tails[1]].address),relations)
                raise failure
        return 'PROVEN', ''

    def acyclic(self, a, b):
        """Exact finite-path proof, with private stack bytes projected out.

        Only call-free DAGs use this alternative. The memory array remains
        unified, so an arbitrary input pointer that aliases a saved register
        is still observed correctly; no heap/stack disjointness is assumed.
        Loops are handled exclusively by the inductive block proof above.
        """
        from equiv_calls import ensure
        ensure(self,a,b)
        if getattr(self, "exception_whole_only", False):
            raise Unsupported("exception region requires compatible whole-memory route")
        graphs = [blocks(a), blocks(b)]
        for side, graph in enumerate(graphs):
            for seq, _ in graph.values():
                if any((a, b)[side][k].mnemonic == 'call' for k in seq):
                    raise NotProven('finite-path alternative requires no calls')
        local = [{}, {}]
        for side, code in enumerate((a, b)):
            for ins in code:
                # Local code addresses have no observable use in call-free
                # ordinary functions. Reject unresolved escaped code pointers.
                local[side][ins.address] = ins.address
        self.routes.append("acyclic")
        for side,code in enumerate((a,b)):
            check_initialized(self,code,side,private_extent(code))
        starts = arbitrary(DIAG, FLAGS)
        stack = z3.BitVec('finite_entry_esp', 32)
        entry_memory = starts[0].memory
        for st in starts:
            st.regs['esp'] = stack
        independent_private(starts, [private_extent(c) for c in (a,b)], stack)
        for side,st in enumerate(starts):
            info=check_initialized(self,(a,b)[side],side,private_extent((a,b)[side]))
            Ownership(self,info,stack).prepare(st)

        def offset(expr):
            value = simp(expr - stack)
            if z3.is_bv_value(value):
                n = value.as_long()
                return n - 0x100000000 if n >= 0x80000000 else n
            return None

        def paths(side, code):
            machine = Machine(self.inp.addresses, side, local)
            result = []
            todo = [(0, starts[side], z3.BoolVal(True), frozenset(), 0)]
            visits = 0
            while todo:
                index, st, guard, seen, low = todo.pop()
                if index in seen:
                    raise NotProven('loop requires an inductive correspondence')
                visits += 1
                if visits > 6000 or len(result) + len(todo) > 128:
                    raise NotProven('finite path budget')
                seen = seen | {index}
                ins = code[index]
                st.path=guard
                machine.step(st, ins)
                sp = offset(st.regs['esp'])
                if sp is None:
                    raise NotProven('dynamic stack extent')
                low = min(low, sp)
                if low < -4096:
                    raise NotProven('private stack extent exceeds budget')
                edges = successors(code, index)
                if not edges:
                    st.frame_defined=check_initialized(self,code,side,private_extent(code))['after'][index][1]
                    result.append((guard, st, low))
                    continue
                for edge, target in enumerate(edges):
                    cond = edge_guard(st, ins, len(edges), edge)
                    next_guard = simp(z3.And(guard, cond))
                    if z3.is_false(next_guard):
                        continue
                    clone = State(dict(st.regs), dict(st.flags), st.memory, st.fs, st.fp)
                    clone.image_origins={k:set(v) for k,v in getattr(st,'image_origins',{}).items()}
                    clone.events = list(st.events)
                    clone.condition = st.condition
                    clone_ownership(st,clone)
                    todo.append((target, clone, next_guard, seen, low))
            return result

        old, new = paths(0, a), paths(1, b)
        if not old or not new:
            raise NotProven('no finite return paths')
        lows = [min(p[2] for p in old), min(p[2] for p in new)]

        asymmetric=set().union(*(x[1].frame_defined ^ y[1].frame_defined for x in old for y in new))
        def visible(st, low):
            st.ownership.result(st)
            if not prove(st.ownership.goals(st)):
                return st.events, st.memory
            numeric=prove([z3.Implies(st.ownership.guard(st),outside(st.regs[r],stack,low)) for r in ('eax','edx')])
            memory = st.memory
            for off in range(low, 0):
                if off in asymmetric and not numeric:continue
                addr = stack + bv(off)
                memory = z3.Store(memory, addr, z3.Select(entry_memory, addr))
            return st.events, memory

        projected = [[(guard, st, *visible(st, low)) for guard, st, low in pp] for pp in (old, new)]

        def same(p, q):
            _, st, events, memory = p
            _, other, other_events, other_memory = q
            if len(events) != len(other_events):
                return z3.BoolVal(False)
            goals = [memory == other_memory, st.fs == other.fs, st.fp == other.fp]
            for x, y in zip(events, other_events):
                if x[0] != y[0] or len(x) != len(y):
                    return z3.BoolVal(False)
                goals += [equality(u, v) for u, v in zip(x[1:], y[1:])]
            return conjunction(goals)

        for source, target in (projected, projected[::-1]):
            for p in source:
                choices = [z3.And(q[0], same(p, q)) for q in target]
                if not prove(guarded([p[1]]+[q[1] for q in target],[z3.Implies(p[0], z3.Or(choices))])):
                    raise NotProven('finite-path traces differ')
        return 'PROVEN', ''


def rep_destination_is_frame(insns, index):
    reg = 'edi'
    for ins in reversed(insns[:index]):
        if not ins.operands or ins.operands[0].type != X.X86_OP_REG:
            continue
        if ALIASES.get(ins.reg_name(ins.operands[0].reg), (None,))[0] != reg:
            continue
        if ins.mnemonic == 'lea':
            m = ins.operands[1].mem
            if ins.reg_name(m.base) in ('esp', 'ebp'):
                return True
            if m.base and not m.index:
                reg = ins.reg_name(m.base)
                continue
            return False
        if ins.mnemonic == 'mov' and ins.operands[1].type == X.X86_OP_REG:
            reg = ins.reg_name(ins.operands[1].reg)
            if reg in ('esp', 'ebp'):
                return True
            continue
        if ins.mnemonic in ('add', 'sub', 'inc', 'dec'):
            continue
        return False
    return reg in ('esp', 'ebp')


def observed_frame_store(insns, index):
    ins = insns[index]
    dst, src = ins.operands
    if (dst.size != 4 or dst.mem.index or dst.mem.segment or dst.mem.disp >= 0
            or ins.reg_name(dst.mem.base) != 'ebp' or src.type != X.X86_OP_REG
            or ins.reg_name(src.reg) not in ('eax', 'edx', 'ecx')):
        return False
    name = ins.reg_name(src.reg)
    for previous in insns[:index]:
        _, writes = previous.raw.regs_access()
        if any(ALIASES.get(previous.reg_name(r), (None,))[0] == name for r in writes):
            return False
        if any(o.type == X.X86_OP_MEM and o.mem.base == dst.mem.base and o.mem.disp == dst.mem.disp for o in previous.operands):
            return False
    found = None
    for following in insns[index+1:]:
        if following.mnemonic in ('ret', 'call'):
            return found in (('eax', 'edx') if following.mnemonic == 'ret' else ('eax', 'edx', 'ecx'))
        if following.mnemonic.startswith('j'):
            return False
        if (following.mnemonic == 'mov' and len(following.operands) == 2
                and following.operands[0].type == X.X86_OP_REG
                and following.reg_name(following.operands[0].reg) in ('eax', 'edx', 'ecx')
                and following.operands[1].type == X.X86_OP_MEM
                and following.operands[1].size == 4 and following.operands[1].mem == dst.mem):
            found = following.reg_name(following.operands[0].reg)
            continue
        if any(o.type == X.X86_OP_MEM and o.mem.base == dst.mem.base and o.mem.disp == dst.mem.disp for o in following.operands):
            return False
        if found:
            _, writes = following.raw.regs_access()
            if any(ALIASES.get(following.reg_name(r), (None,))[0] == found for r in writes):
                return False
    return False


def mutate(insns, rng, only_kind=None):
    """One in-memory instruction edit, fixed-seed selection, no binary writes."""
    choices = []
    reachable = set()
    todo = [0]
    while todo:
        index = todo.pop()
        if index in reachable or not 0 <= index < len(insns):
            continue
        reachable.add(index)
        try:
            todo.extend(successors(insns, index))
        except Unsupported:
            pass
    for index in sorted(reachable):
        ins = insns[index]
        for j, op in enumerate(ins.operands):
            if op.type == X.X86_OP_IMM and ins.mnemonic not in ('call', 'jmp', 'ret') and not ins.mnemonic.startswith('j'):
                choices.append((index, 'constant +1', j))
            if op.type == X.X86_OP_MEM and (op.mem.base or op.mem.index) and not op.mem.segment:
                choices.append((index, 'field offset +4', j))
        if (ins.mnemonic == 'cmp' and len(ins.operands) == 2
                and all(o.type == X.X86_OP_REG for o in ins.operands)
                and ins.operands[0].reg != ins.operands[1].reg):
            choices.append((index, 'swapped compare operands', 0))
        if ins.mnemonic == 'mov' and ins.operands[0].type == X.X86_OP_MEM:
            choices.append((index, 'drop store', 0))
        if ins.mnemonic == 'jle':
            choices.append((index, 'jl for jle', 0))
        if (ins.mnemonic == 'mov' and ins.operands[0].type == X.X86_OP_MEM
                and not ins.operands[0].mem.segment and not ins.operands[0].mem.index
                and ins.reg_name(ins.operands[0].mem.base) in ('ebp', 'esp')):
            if observed_frame_store(insns, index):
                choices.append((index, 'frame store offset +4', 0))
        if (ins.mnemonic == 'pop' and ins.operands[0].type == X.X86_OP_REG
                and ins.reg_name(ins.operands[0].reg) in ('ebx', 'esi', 'edi', 'ebp')):
            restored = ins.reg_name(ins.operands[0].reg)
            changed_register = any(previous.mnemonic not in ('push', 'pop') and
                                   any(ALIASES.get(previous.reg_name(r), (None,))[0] == restored
                                       for r in previous.raw.regs_access()[1]) for previous in insns[:index])
            if changed_register:
                choices.append((index, 'drop restore pop', 0))
        if ins.mnemonic == 'rep movsd' and not rep_destination_is_frame(insns, index):
            overwritten = False
            for following in insns[index+1:]:
                if following.mnemonic in ('call', 'ret') or following.mnemonic.startswith('j'):
                    break
                if following.operands and following.operands[0].type == X.X86_OP_MEM:
                    overwritten = True
                    break
            if not overwritten:
                choices.append((index, 'rep count +1', 0))
    if only_kind is not None:
        choices = [c for c in choices if c[1] == only_kind]
    if not choices:
        return None
    index, kind, operand = rng.choice(choices)
    changed = [dataclasses.replace(i, operands=list(i.operands)) for i in insns]
    ins = changed[index]
    # Copy our mutable operand records, keeping the baseline unmodified.
    import copy
    ins.operands = [copy.deepcopy(o) for o in ins.operands]
    if kind == 'constant +1':
        ins.operands[operand].imm += 1
    elif kind in ('field offset +4', 'frame store offset +4'):
        ins.operands[operand].mem.disp += 4
    elif kind == 'swapped compare operands':
        ins.operands.reverse()
    elif kind == 'jl for jle':
        ins.mnemonic = 'jl'
    elif kind == 'drop restore pop':
        ins.mnemonic = 'nop'
    else:
        ins.mutation = kind
    return changed, index, kind


def mutation_explanation(insns, index, kind):
    if kind == 'swapped compare operands':
        observed = set()
        todo = [(j, frozenset(FLAGS) - {'df'}) for j in successors(insns, index)]
        seen = set()
        while todo:
            i, live = todo.pop()
            if (i, live) in seen or not 0 <= i < len(insns):
                continue
            seen.add((i, live))
            ins = insns[i]
            if ins.mnemonic in ('call', 'ret'):
                continue  # flags are not call arguments or return values
            bits = ins.raw.eflags
            for flag in live:
                uses = getattr(X, 'X86_EFLAGS_TEST_' + flag.upper(), 0) | getattr(X, 'X86_EFLAGS_PRIOR_' + flag.upper(), 0)
                if bits & uses:
                    observed.add(flag)
            killed = set()
            if ins.mnemonic not in ('shl', 'sal', 'shr', 'sar'):
                for flag in live:
                    mask = 0
                    for effect in ('MODIFY', 'RESET', 'SET', 'UNDEFINED'):
                        mask |= getattr(X, 'X86_EFLAGS_' + effect + '_' + flag.upper(), 0)
                    if bits & mask:
                        killed.add(flag)
            try:
                todo += [(j, live - killed) for j in successors(insns, i)]
            except Unsupported:
                return 'comparison predicates are unchanged under the proved invariants'
        if not observed:
            return 'comparison flags are overwritten or unused'
        if observed <= {'zf'}:
            return 'only ZF is observed; swapping comparison operands preserves ZF'
        return 'comparison predicates are unchanged under the proved invariants'
    if kind == 'frame store offset +4':
        return 'changed frame store has no observable effect on the proved paths'
    if kind == 'drop restore pop':
        return 'register and stack values are restored independently of this pop'
    if kind == 'rep count +1':
        return 'extra copied bytes are overwritten or private and unobserved'
    if kind == 'drop store':
        return 'store is redundant, overwritten, or unobserved at every call and return'
    if kind == 'field offset +4':
        if insns[index].mnemonic == 'lea':
            return 'computed address has no observable use'
        return 'changed access has no observable effect before any call or return'
    if kind == 'jl for jle':
        return 'strict/non-strict boundary has the same reachable observable traces'
    return 'changed constant has no observable effect on any proved path'


def main(argv=None):
    argv = sys.argv[1:] if argv is None else argv
    if argv and argv[0] == '--selftest':
        from equiv_tests.__main__ import main as selftest
        raise SystemExit(selftest(argv[1:]))
    try:
        inp = Inputs(argv)
    except (ValueError, IndexError) as e:
        sys.exit(str(e))
    checker = Checker(inp)
    counts = collections.Counter()
    if inp.explain:
        print('EXPLAIN ' + json.dumps(dict(bindings=[dict(original=hex(a), compiled=hex(b), source=p) for (a,b),p in sorted(inp.addresses.provenance.items())])), flush=True)
    for fn in inp.functions:
        if fn.differs:
            inp.addresses.unresolved.clear()
            status, reason = checker.check(fn)
            if checker.cache_hit:print('cached '+fn.name+' '+checker.cache_hit,flush=True)
            if inp.explain:
                print('EXPLAIN ' + json.dumps(dict(function=fn.name,**checker.last_contracts)),flush=True)
                print('EXPLAIN ' + json.dumps(dict(function=fn.name, consulted=[dict(original=hex(a), compiled=hex(b), source=p) for a,b,p in sorted(inp.addresses.consulted)], unresolved=[dict(side=s, address=hex(a)) for s,a in sorted(inp.addresses.unresolved)])), flush=True)
            counts[status] += 1
            print(fn.name + ' ' + status + (' ' + reason if reason else ''), flush=True)
    if inp.mutate:
        rng = random.Random(0xA0E2026)
        matches = [f for f in inp.functions if not f.differs]
        rng.shuffle(matches)
        # Reserve coverage for each new kind when the module contains an
        # eligible function, retaining the --mutate cap and one edit per test.
        selected = []
        remaining = list(matches)
        for wanted in ('frame store offset +4', 'drop restore pop', 'rep count +1'):
            if len(selected) >= inp.mutate:
                break
            for fn in remaining:
                try:
                    _, code = checker.instructions(fn)
                except Unsupported:
                    continue
                edit = mutate(code, rng, wanted)
                if edit is not None:
                    selected.append((fn, code, edit))
                    remaining.remove(fn)
                    break
        tested = 0
        for fn, code, edit in selected + [(f, None, None) for f in remaining]:
            if tested >= inp.mutate:
                break
            try:
                if code is None:
                    _, code = checker.instructions(fn)
            except Unsupported:
                continue
            b = code
            mutation = edit if edit is not None else mutate(b, rng)
            if mutation is None:
                continue
            insns, index, kind = mutation
            status, reason = checker.check(fn, insns)
            tested += 1
            # A mutant is equivalent only if the same verifier proves it; the
            # reason includes the edit so dead/ineffective changes are auditable.
            if status == 'PROVEN':
                reason = mutation_explanation(b, index, kind)
            print('%s MUTANT %s %s [%s at %d]' % (fn.name, status, reason, kind, index), flush=True)
    n = sum(counts.values())
    print('%d differ: %d proven, %d not proven, %d unsupported' % (n, counts['PROVEN'], counts['NOT PROVEN'], counts['UNSUPPORTED']))
    print('Conditional proofs: ' + json.dumps({k:v for k,v in counts.items() if k.startswith('PROVEN under ')}))


if __name__ == '__main__':
    main()
