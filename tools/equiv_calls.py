"""Bounded call input discovery and uniform ordinary-Pascal ABI obligations.
Discovery never proves a callee equivalent. All calls retain explicit H3 contracts
until linked callee proofs close their effects, preservation and cleanup premises.
"""
import sys
class CallContracts:
    def __init__(self, checker):
        self.checker = checker
        self.e = sys.modules[type(checker).__module__]
        self.addresses = checker.inp.addresses
        self.full = frozenset([('r',r,k) for r in self.e.REGS if r != 'esp' for k in range(4)]
                              + [('f',f) for f in self.e.FLAGS])
        self.cache, self.sites, self.dependencies = {}, {}, set()
        self.h5, self.h1 = set(), set()
        self.ready = False
        self.observed_flags = {}
    def lanes(self, ins, reg):
        name = ins.reg_name(reg)
        if name in ('eflags','cs','ds','es','ss','fs','gs'):
            return set()
        root,bits,offset = self.e.ALIASES.get(name,(None,0,0))
        if root is None:
            raise self.e.Unsupported('callee register outside bounded read-set model: '+name)
        return {('r',root,k) for k in range(offset//8,(offset+bits)//8)}
    def scan(self, side, target, depth=0):
        from equiv_summaries import ModuleSummaries
        if not hasattr(self.checker.inp,'call_summaries'):
            self.checker.inp.call_summaries = ModuleSummaries(self)
        return self.checker.inp.call_summaries.query(self,side,target)
    def _scan(self, side, target, depth=0, code=None, nested=None):
        key = side,target,depth
        if nested is None and key in self.cache:
            return self.cache[key]
        self.cache[key] = None
        image = (self.checker.inp.old,self.checker.inp.new)[side]
        if code is None and not image.contains(target):
            return None
        ends = ([a for a,_ in self.checker.inp.sigs.values()] if side == 0 else
                [self.checker.inp.text+a for a in getattr(self.checker.inp,'code_offsets',())])
        size = min([4096]+[a-target for a in ends if a>target])
        try:
            if code is None: code = self.e.decode(image,target,size)
            if code and code[0].mnemonic == 'jmp' and code[0].operands[0].type == self.e.X.X86_OP_IMM:
                if depth:
                    return None
                other = code[0].operands[0].imm
                self.dependencies.add((side,hex(target),hex(other),'forwarding-thunk'))
                self.cache[key] = self.scan(side,other,depth+1)
                return self.cache[key]
            if not code:
                return None
            save_only = self.abi(code,side,callee=True,summaries=nested)
            todo, definitions, required, visits, returns = [0],{0:frozenset()},set(),0,set()
            passed = set()
            while todo:
                i = todo.pop(); visits += 1
                if nested is not None: self.checker.inp.call_summaries.charge()
                if visits > 512 or not 0 <= i < len(code):
                    return None
                ins = code[i]
                # REP is outside this bounded input scan; its default ES/DS
                # operands are ordinary string storage, not a new context read.
                if ins.mnemonic in self.e.STRING_OPS: return None
                read,written = ins.raw.regs_access()
                if any(ins.reg_name(r) not in self.e.ALIASES and ins.reg_name(r) not in ('eflags','fpsw','eip','cs','ds','es','ss','fs','gs') and not ins.reg_name(r).startswith('st') for r in set(read)|set(written)):
                    raise self.e.Unsupported('callee unmodeled register/context input')
                if ins.mnemonic in ('fstenv','fnstenv','fsave','fnsave') or (ins.mnemonic == 'call' and ins.operands[0].type == self.e.X.X86_OP_IMM and ins.operands[0].imm == ins.address+ins.size):
                    raise self.e.Unsupported('callee unmodeled instruction-location observation')
                if (ins.mnemonic not in self.e.INTEGER_OPS and not ins.mnemonic.startswith(('j','set'))
                        or (ins.mnemonic == 'call' and nested is None) or ins.raw.addr_size != 4 or any(ins.raw.prefix)):
                    return None
                reads = set() if ins.mnemonic=='call' else set().union(*(self.lanes(ins,r) for r in read))
                if i in save_only:
                    reads.difference_update(('r',ins.reg_name(ins.operands[0].reg),k) for k in range(4))
                writes = set() if ins.mnemonic=='call' else set().union(*(self.lanes(ins,r) for r in written))
                for flag in self.e.FLAGS:
                    if ins.raw.eflags & sum(getattr(self.e.X,'X86_EFLAGS_'+k+'_'+flag.upper(),0) for k in ('TEST','PRIOR')):
                        reads.add(('f',flag))
                    if ins.raw.eflags & sum(getattr(self.e.X,'X86_EFLAGS_'+k+'_'+flag.upper(),0) for k in ('MODIFY','RESET','SET','UNDEFINED')):
                        writes.add(('f',flag))
                if ins.mnemonic=='call':
                    child = nested[ins.address]
                    reads.update(child[0])
                    writes.update(('r',r,k) for r in ('eax','edx','ecx') for k in range(4))
                    writes.update({('f',f) for f in self.e.FLAGS}-child[2])
                # Return values and preserved volatile/flag outputs can expose
                # incoming bytes even if no instruction explicitly reads them.
                if ins.mnemonic == 'ret':
                    reads.update(('r',r,k) for r in ('eax','edx','ecx') for k in range(4))
                    passed.update({('f',f) for f in self.e.FLAGS}-definitions[i])
                    returns.add(ins.operands[0].imm if ins.operands else 0)
                required.update(reads-definitions[i])
                after = definitions[i] | writes
                for j in self.e.successors(code,i):
                    merged = after if j not in definitions else definitions[j] & after
                    if j not in definitions or merged != definitions[j]:
                        definitions[j] = merged; todo.append(j)
            if len(returns) != 1:
                return None
            # Do not assume an ABI contract contradicted by a checked leaf.
            self.cache[key] = frozenset(required),next(iter(returns)),frozenset(passed)
            return self.cache[key]
        except self.e.Unsupported as error:
            if str(error).startswith('callee unmodeled'): raise
            return None
        except self.e.NotProven as error:
            if 'observes return address' in str(error): raise
            return None
    def cleanup(self, side, target):
        """R1 reads the callee's own RET, independently of its input summary."""
        if target is None: return None,False
        e = self.e; image = (self.checker.inp.old,self.checker.inp.new)[side]
        readable = image.contains(target)
        if readable:
            ends = ([a for a,_ in self.checker.inp.sigs.values()] if side == 0 else [self.checker.inp.text+a for a in getattr(self.checker.inp,'code_offsets',())])
            try:
                code = e.decode(image,target,min([4096]+[a-target for a in ends if a>target]))
                todo,seen,returns = [0],set(),set()
                while todo:
                    i = todo.pop()
                    if i in seen: continue
                    if len(seen)>=512 or not 0<=i<len(code): raise e.Unsupported('callee RET scan incomplete')
                    seen.add(i); ins = code[i]
                    if ins.mnemonic == 'ret': returns.add(ins.operands[0].imm if ins.operands else 0)
                    todo.extend(e.successors(code,i))
                if len(returns)>1: raise e.NotProven('callee has inconsistent RET cleanup counts')
                if returns: return next(iter(returns)),True
            except e.Unsupported: pass
            except e.NotProven as error: raise e.Unsupported(str(error))
        count = e.callee_cleanup(self.checker,side,target,own_ret_only=True)
        return count,readable and (id(image),target,True) not in self.checker._cleanup_unreadable
    def site(self, side, ins, sp, floor):
        e = self.e; op = ins.operands[0]
        key = side,ins.address
        if key in self.sites:
            if self.sites[key][2]['cleanup_rule']=='R2' and (sp[1] or self.sites[key][1]!=max(0,floor-sp[0])): raise e.Unsupported('R2 cleanup differs across paths')
            return self.sites[key]
        target = op.imm if op.type == e.X.X86_OP_IMM else None
        image = (self.checker.inp.old,self.checker.inp.new)[side]
        if target is not None and image.contains(target) and not any(image.base+s.VirtualAddress <= target < image.base+s.VirtualAddress+s.Misc_VirtualSize and s.Characteristics & 0x20000000 for s in image.pe.sections):
            raise e.Unsupported('direct callee is not in executable storage')
        old = target if side == 0 else self.addresses.reverse.get(target)
        new = self.addresses.forward.get(target) if side == 0 else target
        summaries = [self.scan(s,t) if t is not None else None for s,t in enumerate((old,new))]
        tainted = all(summaries) and any(s[3] for s in summaries)
        live = self.observed_flags.get(self.flag_key(side,ins),frozenset())
        inputs = summaries[0][0] | summaries[1][0] | ((summaries[0][2] | summaries[1][2]) & live) if all(summaries) else frozenset([('r',r,k) for r in ('eax','edx','ecx') for k in range(4)]+[('f','df')])
        cleanups = [(s[1],True) if s else self.cleanup(n,t) for n,(s,t) in enumerate(zip(summaries,(old,new)))]
        if all(c[0] is not None for c in cleanups) and cleanups[0][0] != cleanups[1][0]:
            raise e.Unsupported('callee cleanup contracts disagree')
        cleanup = cleanups[side][0]
        rule = 'R1' if all(c[0] is not None for c in cleanups) else 'R3'
        if rule!='R1' and target is not None and all(c[1] for c in cleanups): raise e.Unsupported('R1 readable direct callee has no agreed RET cleanup')
        if rule!='R1' and not all(summaries) and not sp[1]:
            rule,cleanup = 'R2',max(0,floor-sp[0])
            if any(c[0] is not None and c[0]!=cleanup for c in cleanups): raise e.Unsupported('R2 cleanup disagrees with readable callee RET')
        if rule=='R3': cleanup = None
        record = dict(side=side,pc=hex(ins.address),target=hex(target) if target is not None else ins.op_str,
                      kind='direct' if target is not None else 'indirect',cleanup=cleanup,
                      cleanup_rule=rule,assumed_cleanup_bytes=cleanup if rule=='R2' else None,
                      raw_floor_minus_ESP=floor-sp[0] if rule=='R2' else None,
                      cleanup_contract='R1: own RET counts agree on both sides' if rule=='R1' else 'R2 H3c: callee removes max(0, floor - ESP) bytes pushed below the corrected post-prologue frame level' if rule=='R2' else 'R3 shared symbolic cleanup; incompatible multiset joins become unknown',
                      preserved=['ebx','esi','edi','ebp'],DF_entry=0,DF_exit=0,caller_private_range_relative_to_entry_ESP=[floor,0],
                      summary_kind=('summarized/H3c' if tainted else 'summarized') if all(summaries) else 'H3c',
                      premises=['H3','H3c'] if tainted else ['H3' if all(summaries) else 'H3c'],
                      mode='two-callee-def-before-use' if all(summaries) else 'H3c-register-convention',
                      premise='H3' if all(summaries) else 'H3c',
                      read_contract='Checked union of both callee read sets; passed-through flags restricted by caller live_locations after calls (union for repeated same-target calls)' if all(summaries) else 'Assumed: callee reads only EAX, EDX, ECX, stack arguments and DF=0; no other incoming GPR or flag is observed.',
                      inputs=[list(v) for v in sorted(inputs)],
                      H3='Same identified callee transformer on these inputs, memory, FS and FP; preserves EBX/ESI/EDI/EBP and caller private save slots; returns DF=0; stated cleanup; matching FP/exception effects; flags the callee leaves undefined are not observed; no observation of caller return-address or instruction-location context or its own private save slots (callee H1).')
        self.sites[key] = inputs,cleanup,record
        return self.sites[key]
    def abi(self, code, side, callee=False, summaries=None):
        """Finite-height must analysis; unsupported ownership never proves saves."""
        e = self.e; saved = ('ebx','esi','edi','ebp')
        initial = {r:('entry',r) for r in e.REGS}; initial['esp'] = ('stack',(0,()))
        states = {0:(initial,{},0)}; todo = [0]; visits = 0; floor = 0
        saves, observed = {}, set(); uncertain=set()
        for ins in code:
            if ins.mnemonic == 'push' and ins.operands[0].type in (e.X.X86_OP_REG,e.X.X86_OP_IMM):
                floor -= 4
                if ins.operands[0].type == e.X.X86_OP_REG and ins.reg_name(ins.operands[0].reg) in saved: saves[floor] = (code.index(ins),ins.reg_name(ins.operands[0].reg))
            elif ins.mnemonic == 'mov' and ins.op_str.replace(' ','') == 'ebp,esp':
                pass
            elif ins.mnemonic in ('sub','add') and ins.op_str.startswith('esp,') and ins.operands[1].type == e.X.X86_OP_IMM and (ins.mnemonic == 'sub' or ins.operands[1].imm < 0):
                floor += ins.operands[1].imm*(1 if ins.mnemonic == 'add' else -1)
            else:
                break
        while todo:
            i = todo.pop(); visits += 1
            if callee and summaries is not None: self.checker.inp.call_summaries.charge()
            if visits > 1024 or not 0 <= i < len(code):
                raise e.Unsupported('ABI fixed-point budget/incomplete CFG')
            before,slots,df = states[i]; regs,slots = dict(before),dict(slots)
            ins = code[i]; oo = ins.operands; m = ins.mnemonic
            def offset(value):
                return value[1] if value is not None and value[0] == 'stack' else None
            def shift(a,n):
                return None if a is None else (a[0]+n,a[1])
            def address(op):
                if op.mem.index or op.mem.segment or not op.mem.base:
                    return None
                n = offset(before.get(ins.reg_name(op.mem.base)))
                return shift(n,op.mem.disp)
            def load(a):
                return slots.get(a,('slot',a) if a is not None and a[1] else None)
            def value(op):
                if op.type == e.X.X86_OP_IMM: return ('constant',op.imm & 0xffffffff)
                if op.type == e.X.X86_OP_REG and op.size == 4:
                    return before.get(ins.reg_name(op.reg))
                return load(address(op)) if op.type == e.X.X86_OP_MEM and op.size == 4 else None
            for r in ins.raw.regs_access()[1]:
                name = ins.reg_name(r)
                if name in e.ALIASES: regs[e.ALIASES[name][0]] = None
            for k,op in enumerate(oo):
                if m!='lea' and op.type == e.X.X86_OP_MEM and ins.raw.operands[k].access & e.CS.CS_AC_READ:
                    a = address(op)
                    observed.update(n for n in saves if a is not None and (a[1] or max(n,a[0])<min(n+4,a[0]+op.size)))
                if callee and m!='lea' and op.type == e.X.X86_OP_MEM and address(op) == (0,()) and ins.raw.operands[k].access & e.CS.CS_AC_READ:
                    if i in uncertain: raise e.Unsupported('callee save scan incomplete after assumed cleanup')
                    raise e.NotProven('callee observes return address; call-context contract invalid')
                if m not in e.STRING_OPS and op.type == e.X.X86_OP_MEM and not op.mem.segment and ins.raw.operands[k].access & e.CS.CS_AC_WRITE:
                    a = address(op)
                    if a is None:
                        if any(v==('entry',r) for n,v in slots.items() if floor<=n[0]<0 for r in saved): self.h1.add((side,hex(ins.address),floor,0,ins.op_str,'callee' if callee else 'caller'))
                    else:
                        slots = {n:v for n,v in slots.items() if n[1]!=a[1] or n[0]+4<=a[0] or a[0]+op.size<=n[0]}
                        if op.size == 4: slots[a] = value(oo[1]) if m == 'mov' else None
            sp = offset(before.get('esp'))
            if m == 'std' or ins.raw.eflags & getattr(e.X,'X86_EFLAGS_MODIFY_DF',0):
                raise e.NotProven('ordinary Pascal DF must remain zero')
            if m == 'cld': df = 0
            if m == 'mov' and oo[0].type == e.X.X86_OP_REG and oo[0].size == 4:
                regs[ins.reg_name(oo[0].reg)] = value(oo[1])
            if m == 'lea' and oo[0].type == e.X.X86_OP_REG:
                a = address(oo[1]); regs[ins.reg_name(oo[0].reg)] = None if a is None else ('stack',a)
            if m == 'push' and sp is not None:
                slots[shift(sp,-4)] = value(oo[0]); regs['esp'] = ('stack',shift(sp,-4))
            if m == 'pop' and sp is not None:
                if callee and sp==(0,()):
                    if i in uncertain: raise e.Unsupported('callee save scan incomplete after assumed cleanup')
                    raise e.NotProven('callee observes return address; call-context contract invalid')
                if sp[0] in saves and (sp[1] or oo[0].type != e.X.X86_OP_REG or ins.reg_name(oo[0].reg) != saves[sp[0]][1]): observed.add(sp[0])
                if oo[0].type==e.X.X86_OP_REG and ins.reg_name(oo[0].reg) in regs: regs[ins.reg_name(oo[0].reg)] = load(sp)
                regs['esp'] = ('stack',shift(sp,4))
            if m in ('add','sub') and oo[0].type == e.X.X86_OP_REG and ins.reg_name(oo[0].reg) == 'esp' and oo[1].type == e.X.X86_OP_IMM and sp is not None:
                regs['esp'] = ('stack',shift(sp,oo[1].imm*(1 if m=='add' else -1)))
            if m == 'leave':
                bp = offset(before.get('ebp')); regs['esp'] = None if bp is None else ('stack',shift(bp,4)); regs['ebp'] = load(bp)
            if m == 'call':
                if callee and summaries is None: raise e.Unsupported('nested callee cleanup not summarized')
                if sp is None or df != 0: raise e.Unsupported('call ESP/DF contract unestablished')
                if callee:
                    cleanup = summaries[ins.address][1]
                    if cleanup is None: cleanup = max(0,floor-sp[0]) if not sp[1] else None
                else: _,cleanup,contract = self.site(side,ins,sp,floor)
                regs['esp'] = ('stack',shift(sp,cleanup) if cleanup is not None else (sp[0],tuple(sorted(sp[1]+(ins.address,)))))
                for r in ('eax','edx','ecx'): regs[r] = None
                for r in saved: regs[r] = before[r]
                df = 0
            if m in e.STRING_OPS:
                start = offset(before.get('edi')); count = before.get('ecx')
                if start is not None and count is not None and count[0]=='constant':
                    size = count[1]*(4 if m.endswith('d') else 1)
                    slots = {n:v for n,v in slots.items() if size==0 or n[1]!=start[1] or n[0]+4<=start[0] or start[0]+size<=n[0]}
                    regs['edi'] = ('stack',shift(start,size)); regs['ecx'] = ('constant',0)
                    if 'movs' in m:
                        src = offset(before.get('esi')); regs['esi'] = None if src is None else ('stack',shift(src,size))
                elif any(v==('entry',r) for n,v in slots.items() if floor<=n[0]<0 for r in saved):
                    self.h1.add((side,hex(ins.address),floor,0,ins.op_str,'callee' if callee else 'caller'))
            if m == 'ret':
                if ins.flow: regs['esp'] = None if sp is None else ('stack',shift(sp,4))
                elif not ins.handler_return:
                    if sp is None or df != 0 or (not sp[1] and sp[0] != 0):
                        raise e.NotProven('callee-saved registers/ESP/DF not restored')
                    conditions, symbols = [], set(sp[1])
                    def expression(a):
                        symbols.update(a[1]); return a[0]+sum(e.z3.Int('ABI_cleanup_'+str(n)) for n in a[1])
                    conditions.append(expression(sp)==0)
                    for r in saved:
                        if regs[r] == initial[r]: continue
                        v = regs[r]
                        candidates = [a for a,value in slots.items() if value == initial[r]]
                        if v is None or v[0]!='slot' or not candidates: raise e.NotProven('callee-saved registers/ESP/DF not restored')
                        conditions.append(e.z3.Or([expression(v[1])==expression(a) for a in candidates]))
                    if symbols:
                        conditions += [e.z3.Int('ABI_cleanup_'+str(n))>=0 for n in symbols]
                        solver = e.z3.Solver(); solver.set(timeout=100); solver.add(*conditions)
                        if solver.check()!=e.z3.sat: raise e.NotProven('inconsistent/unknown cleanup restoration contract')
                        obligation = dict(return_pc=hex(ins.address),ESP_offset=sp[0],sites=[hex(n) for n in sorted(symbols)],predicate='ESP and save-slot restoration assume the stated cleanup of sites',constraints=[str(c) for c in conditions])
                        for n in symbols:
                            records = self.sites[side,n][2].setdefault('H3_restoration',[])
                            if obligation not in records: records.append(obligation)
            for j in e.successors(code,i):
                tainted_offset = callee and (i in uncertain or (m=='call' and summaries[ins.address][1] is None))
                newly_uncertain = tainted_offset and j not in uncertain
                if tainted_offset: uncertain.add(j)
                state = regs,slots,df
                if j in states:
                    rr,ss,dd = states[j]
                    state = ({r:v if rr[r]==v else None for r,v in regs.items()},
                             {a:v for a,v in slots.items() if a in ss and ss[a]==v},df if dd==df else None)
                if j not in states or state != states[j] or newly_uncertain: states[j] = state; todo.append(j)
        return {i for n,(i,_) in saves.items() if n not in observed}
    def flag_key(self, side, ins):
        op = ins.operands[0]
        if op.type != self.e.X.X86_OP_IMM: return ('indirect',)
        target = op.imm if side == 0 else self.addresses.reverse.get(op.imm,('new',op.imm))
        return ('direct',target)
    def prepare(self, a, b):
        # Singleton blocks expose exactly the existing liveness at each successor.
        # Union same-target sites across both callers to keep masks symmetric;
        # this may retain extra inputs, never remove an observed input.
        for side,code in enumerate((a,b)):
            graph = {}
            for i in range(len(code)):
                try: edges = self.e.successors(code,i)
                except (self.e.Unsupported,self.e.NotProven): edges = []
                # Unreachable padding must not poison all caller flag liveness.
                # The ABI/checker still rejects any reached incomplete edge.
                graph[i] = ([i],edges)
            live = self.e.live_locations(code,graph)
            for i,ins in enumerate(code):
                if ins.mnemonic == 'call':
                    flags = {loc for j in graph[i][1] for loc in live[j] if loc[0]=='f'}
                    key = self.flag_key(side,ins)
                    self.observed_flags.setdefault(key,set()).update(flags)
        for side,code in enumerate((a,b)): self.abi(code,side)
        for side,code in enumerate((a,b)):
            for ins in code:
                if ins.eh:
                    self.sites[side,ins.address] = self.full,0,dict(side=side,pc=hex(ins.address),target=hex(ins.eh[0]),kind='exception-helper',mode='modeled-handler',inputs=[],cleanup=0,H3='Named Delphi exception runtime implements the recognized handler/continuation contract; FP, FS, preservation and exceptional effects as modeled; not independently discharged.')
def ensure(checker,a,b):
    if getattr(checker,'contracts',None) is None:
        checker.contracts = CallContracts(checker)
        checker.inp.addresses.call_contracts = checker.contracts
        checker.contracts.prepare(a,b)
        checker.contracts.ready = True
    elif not checker.contracts.ready:
        raise checker.contracts.e.Unsupported('ABI validation did not complete')
