"""Bounded certificate replay. No discovery, Houdini or alignment is executed."""
import ast,copy,hashlib,json,pathlib,sys,time,types
from contextlib import contextmanager
from equiv_certificate import pack,unpack,versions,image_hash,code as encode_code

POLICY=dict(H1='EntrySeparation',H2='CreatedPointerOwnership',H3='CalleeContract',H3c='Explicit register convention and concrete cleanup instances',
            H4='IndependentFrameGarbage',H5='ImageRelation',H6='AccessAndFaultModel',
            H7='SegmentRelation',H8='EnvironmentInterference',H9='FPObservation')

def require(test,message):
    if not test:raise ValueError(message)

def rules():
    """Load the shared model/rule definitions, never the producer's proof engine.

    The allowlist is the trust boundary: no Checker proof/discovery methods,
    candidate generation, alignment, SCC solver or summary discovery is loaded.
    """
    name='_equiv_replay_model'
    if name in sys.modules:return sys.modules[name]
    p=pathlib.Path(__file__).parent;m=types.ModuleType(name);sys.modules[name]=m
    allowed={'register_byte','bv','simp','equal','equality','unhash','content_key','ordered','conjunction','prove',
             'decode','arbitrary','successors','edge_guard','frame_bytes','location_value','live_locations',
             'fact_expression','relation_states','callee_cleanup','stack_insensitive_leaf'}
    tree=ast.parse((p/'equiv.py').read_text());nodes=[]
    for n in tree.body:
        if isinstance(n,ast.FunctionDef) and n.name not in allowed:continue
        if isinstance(n,ast.ClassDef) and n.name=='Checker':
            n.body=[x for x in n.body if isinstance(x,ast.FunctionDef) and x.name in ('__init__','instructions','exception_regions')]
        if isinstance(n,ast.ClassDef) and n.name=='Frames':n.body=[x for x in n.body if getattr(x,'name','')!='candidates']
        if isinstance(n,ast.If) and '__name__' in ast.unparse(n.test):continue
        if isinstance(n,ast.Import) and any(x.name=='equiv_emit' for x in n.names):continue
        nodes.append(n)
    m.__file__=str(p/'equiv.py');exec(compile(ast.Module(nodes,type_ignores=[]),m.__file__,'exec'),m.__dict__)
    tree=ast.parse((p/'equiv_calls.py').read_text());cls=next(x for x in tree.body if isinstance(x,ast.ClassDef))
    cls.body=[x for x in cls.body if isinstance(x,ast.FunctionDef) and x.name!='scan']
    # prepare/abi/_scan construct/check H3 obligations; scan is replaced by a
    # lookup of certificate nodes whose local transfer obligations are checked.
    exec(compile(ast.Module([cls],type_ignores=[]),str(p/'equiv_calls.py'),'exec'),m.__dict__)
    tree=ast.parse((p/'equiv_summaries.py').read_text());cls=next(x for x in tree.body if isinstance(x,ast.ClassDef))
    cls.body=[x for x in cls.body if isinstance(x,ast.FunctionDef) and x.name=='must_write']
    exec(compile(ast.Module([cls],type_ignores=[]),str(p/'equiv_summaries.py'),'exec'),m.__dict__)
    return m

def clone(x):
    if isinstance(x,dict):return {clone(k):clone(v) for k,v in x.items()}
    if isinstance(x,list):return list(map(clone,x))
    if isinstance(x,tuple):return tuple(map(clone,x))
    if isinstance(x,(set,frozenset)):return type(x)(map(clone,x))
    return x

@contextmanager
def context(inp):
    import equiv_garbage as garbage
    e=rules();i=copy.copy(inp)
    if getattr(inp,'replay_argv',None) is not None and type(inp).__module__!=e.__name__:
        i.old=copy.copy(inp.old);i.new=copy.copy(inp.new)
        i.old.data=bytes(inp.old.data);i.new.data=bytes(inp.new.data)
        record=e.verdict_cache.recorder();e.verdict_cache.ACTIVE.record=None
        try:i.addresses=e.Addresses(i)  # Input loading is keyed by the resulting consulted identities.
        finally:e.verdict_cache.ACTIVE.record=record
    i.cache_dir=None;i.addresses=copy.copy(i.addresses)
    i._replay_input_images={str(p):im for p,im in getattr(getattr(inp,'call_summaries',None),'images',{}).items()}
    for k,v in list(vars(i.addresses).items()):setattr(i.addresses,k,clone(v))
    i.addresses.consulted.clear();i.addresses.unresolved.clear()
    if hasattr(i,'call_summaries'):del i.call_summaries
    c=e.Checker(i);old=garbage.ACTIVE_MODEL;relation=e.image_relation.ACTIVE
    garbage.ACTIVE_MODEL=e
    try:
        with e.verdict_cache.proof_context(c):yield e,c
    finally:garbage.ACTIVE_MODEL=old;e.image_relation.ACTIVE=relation

def instructions(e,rows,image):
    md=e.CS.Cs(e.CS.CS_ARCH_X86,e.CS.CS_MODE_32);md.detail=True;result=[]
    for r in rows:
        raw=bytes.fromhex(r['raw']);pc=r['pc']
        require(raw and len(raw)<=15 and image.bytes_at(pc,len(raw))==raw,'stale instruction at '+hex(pc))
        ins=next(md.disasm(raw,pc,count=1),None)
        require(ins is not None and ins.size==len(raw),'incomplete decoding at '+hex(pc))
        i=e.Insn(pc,ins.size,ins.mnemonic,ins.op_str,[e.Operand.from_capstone(o) for o in ins.operands],ins)
        require(encode_code([i])[0]['operands']==r['operands'] and not r['mutation'],'forged operands at '+hex(pc))
        result.append(i)
    require(len({i.address for i in result})==len(result),'duplicate instruction')
    return result

def reach(e,code,root):
    seen=set();todo=[root]
    while todo:
        i=todo.pop();require(0<=i<len(code),'incomplete reachable suffix')
        if i not in seen:seen.add(i);todo.extend(e.successors(code,i))
        require(len(seen)<=16384,'CFG replay budget')
    return seen

def check_graph(e,code,graph,root):
    require(root in graph,'missing entry block');seen=reach(e,code,root);heads=set(graph);covered=set()
    require(heads<=seen,'unreachable/forged block head')
    def skip(i):
        visited=set()
        while i not in heads:
            require(i not in visited and i in seen,'missing edge/block');visited.add(i);ins=code[i]
            require(ins.mnemonic in ('nop','jmp') and ins.raw.addr_size==4 and not any(ins.raw.prefix),'omitted instruction at '+hex(ins.address))
            out=e.successors(code,i);require(len(out)==1,'omitted branch');i=out[0]
        covered.update(visited);return i
    for head,(body,edges) in graph.items():
        require(body and body[0]==head and len(body)==len(set(body)),'malformed block')
        for k,j in zip(body,body[1:]):
            out=e.successors(code,k);require(len(out)==1,'branch inside block')
            i=out[0];vis=set()
            while i!=j:
                require(i not in vis and i not in heads and i in seen,'invalid block continuation');vis.add(i)
                require(code[i].mnemonic in ('nop','jmp') and not any(code[i].raw.prefix),'omitted instruction')
                out=e.successors(code,i);require(len(out)==1,'omitted branch');i=out[0]
            covered.update(vis)
        require(list(edges)==[skip(j) for j in e.successors(code,body[-1])],'missing/forged CFG edge at '+hex(code[body[-1]].address))
        require(not (set(body)&covered),'overlapping blocks');covered.update(body)
    require(covered==seen,'missing reachable instructions')

def local_identities(e,c,codes,regions,pairs):
    mapping=dict(pairs);require(len(mapping)==len(pairs) and len(set(mapping.values()))==len(mapping),'non-bijective local binding')
    if not pairs:return
    variants=[(codes,(0,0))]
    for a,b in zip(*regions):
        require(len(a[1])==len(b[1]) and len(a[3])==len(b[3]),'exception table shape')
        other=[[e.dataclasses.replace(i) for i in code] for code in codes]
        for side,r in enumerate((a,b)):
            other[side][r[0]].flow=tuple(r[1])
            if r[2] is not None:other[side][r[2]].flow=()
        variants.append((other,(a[0],b[0])))
    indexes=[{i.address:k for k,i in enumerate(code)} for code in codes]
    for a,b in pairs:require(a in indexes[0] and b in indexes[1],'local binding is not an instruction boundary')
    # A binding must relate block heads, with all outgoing heads accounted for.
    all_heads=set();allowed=[set(),set()]
    for codes,(root,other) in variants:
        for side,start in enumerate((root,other)):
            allowed[side].add(codes[side][start].address)
            for k in reach(e,codes[side],start):
                if codes[side][k].mnemonic.startswith('j') or codes[side][k].flow is not None:allowed[side].update(codes[side][j].address for j in e.successors(codes[side],k))
        todo=[(root,other)];visited=set()
        while todo:
            a,b=todo.pop()
            if (a,b) in visited:continue
            visited.add((a,b));require(mapping.get(codes[0][a].address)==codes[1][b].address,'missing local CFG binding')
            all_heads.add(codes[0][a].address)
            ends=[]
            for side,start in enumerate((a,b)):
                code=codes[side];k=start
                for _ in range(len(code)+1):
                    out=e.successors(code,k)
                    if len(out)!=1 or code[k].mnemonic.startswith('j') or code[k].flow is not None or code[out[0]].address in (mapping if side==0 else set(mapping.values())):break
                    k=out[0]
                else:raise ValueError('local CFG traversal budget')
                ends.append(out)
            require(len(ends[0])==len(ends[1]),'local CFG successor count')
            todo.extend(zip(*ends))
    require(set(mapping)==all_heads,'unjustified local CFG binding')
    require(set(mapping)==allowed[0] and set(mapping.values())==allowed[1],'local identities require actual CFG heads')
    for a,b in pairs:
        existing=c.inp.addresses.forward.get(a)
        if existing is None:require(c.inp.addresses.bind(a,b,'local-cfg'),'conflicting local binding')
        else:require(existing==b,'conflicting local binding')

def callee_graph(e,c,records):
    graph=e.ModuleSummaries.__new__(e.ModuleSummaries);graph.e=e;graph.inp=c.inp;graph.nodes={};graph.active=None
    graph.charge=lambda:None
    graph.budget=lambda message:(_ for _ in ()).throw(ValueError('callee replay budget: '+message))
    images={'0':c.inp.old,'1':c.inp.new}|c.inp._replay_input_images;keys=[]
    for r in records:
        ref=r['image']
        if ref not in images:images[ref]=e.match.Image(ref)
        image=images[ref];require(image_hash(image)==r['image_hash'],'stale callee image')
        require(r['side'] in (0,1) and r['hop'] in (0,1),'invalid callee side/hop')
        key=(r['side'],id(image),r['target'],r['hop']);require(key not in graph.nodes,'duplicate callee');keys.append(key)
        n=unpack(r['fields']);n.update(side=r['side'],image=image,target=r['target'],hop=r['hop'])
        n['code']=instructions(e,r['code'],image) if r['code'] is not None else None
        if r['code'] is not None:require(all(row['mnemonic']==ins.mnemonic and row['flow'] is None and not row['eh'] and not row['handler_return'] for row,ins in zip(r['code'],n['code'])),'forged callee annotations')
        n['replay_body']=callee_body(e,c,n,r)
        if n['code'] is not None:require([i.address for i in n['code']]==[i.address for i in n['replay_body'] or []],'callee coverage differs')
        for a,size,h in r['ranges']:require(size>0 and hashlib.sha256(image.bytes_at(a,size)).hexdigest()==h,'stale callee range')
        n['ranges']=[(a,size) for a,size,_ in r['ranges']];graph.nodes[key]=n
    for key,r in zip(keys,records):
        n=graph.nodes[key];n['edges']={pc:(keys[j],kind) for pc,j,kind in r['edges']};n['alias']=keys[r['alias']] if r['alias'] is not None else None
        body=n['code'] or n['replay_body']
        if body:
            require(body[0].address==n['target'] and sum(i.size for i in body)<=4096,'callee extent')
            if n['alias'] is None:require(reach(e,body,0)==set(range(len(body))),'callee missing CFG edge')
            else:require(len(body)==1 and body[0].mnemonic=='jmp','malformed callee thunk')
            require(set(n['edges'])<={i.address for i in body if i.mnemonic=='call' or i.address==n['target'] and i.mnemonic=='jmp'},'forged callee edge')
            for i in body:
                if i.mnemonic=='call' and i.operands[0].type==e.X.X86_OP_IMM:
                    require(i.address in n['edges'],'missing direct callee dependency')
                if i.address in n['edges']:
                    child,kind=n['edges'][i.address];target=graph.nodes[child]
                    if kind=='import-thunk':
                        image=n['image'];e.match.parse_imports_once(image);matches=[]
                        for mod in getattr(image.pe,'DIRECTORY_ENTRY_IMPORT',()):
                            for imp in mod.imports:
                                if imp.address==i.operands[0].mem.disp and imp.name:
                                    path=c.inp.original_path.parent/mod.dll.decode('latin1');other=images.get(str(path))
                                    if other is None:other=e.match.Image(path);images[str(path)]=other
                                    other.pe.parse_data_directories(directories=[e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
                                    matches += [(str(path),other.base+x.address) for x in getattr(other.pe.DIRECTORY_ENTRY_EXPORT,'symbols',()) if x.name==imp.name and not x.forwarder]
                        require((r['image'] if target['image'] is n['image'] else next(ref for ref,im in images.items() if im is target['image']),target['target']) in matches and target['hop']==n['hop']+1,'forged import hop')
                    else:require(i.operands[0].type==e.X.X86_OP_IMM and i.operands[0].imm==target['target'] and n['image'] is target['image'],'wrong direct callee')
        elif n['valid']:raise ValueError('valid callee without decoded body')
    c.inp.call_summaries=graph;owner=c.contracts
    def scan(self,side,target,depth=0):
        key=side,id((c.inp.old,c.inp.new)[side]),target,0
        if target is None or key not in graph.nodes:return None
        node=graph.nodes[key]
        require(not node['hazard'],'callee context hazard')
        return node['value'] if node['valid'] else None
    owner.scan=types.MethodType(scan,owner)
    for key in keys:
        n=graph.active=graph.nodes[key]
        if not n['valid']:require(not n['writes'],'opaque callee claims must-writes')
        if n['alias'] is not None:
            child=graph.nodes[n['alias']];require(n['value']==child['value'] and n['writes']==child['writes'] and (not n['valid'] or child['valid']),'forged thunk summary')
            if n['valid']:
                seen={key};p=n
                while p['alias'] is not None:
                    require(p['alias'] not in seen,'cyclic thunk has no RET evidence');seen.add(p['alias']);p=graph.nodes[p['alias']]
            continue
        body=n['code'] or n['replay_body']
        if body is None:continue
        def child_value(ins):
            child=graph.nodes[n['edges'][ins.address][0]] if ins.address in n['edges'] else None
            if child and (child['valid'] or not n['value'][3]):
                if not child['valid']:require(owner.full<=(child['value'][0]-{('r','esp',k) for k in range(4)}) and {('f',f) for f in e.FLAGS}<=child['value'][2],'opaque child narrowed without H3c')
                return child['value']
            return frozenset([('r',r,k) for r in ('eax','edx','ecx') for k in range(4)]+[('f','df')]),child['value'][1] if child else None,frozenset(),True
        nested={i.address:child_value(i) for i in body if i.mnemonic=='call'}
        result=owner._scan(n['side'],n['target'],code=body,nested=nested);n['replay_read']=result
        if not n['valid']:continue
        require(result is not None and result[0]<=n['value'][0] and result[1]==n['value'][1] and result[2]<=n['value'][2],'callee read/cleanup summary obligation')
        require(not any(v[3] for v in nested.values()) or n['value'][3],'missing H3c taint')
        if n['writes'] and not n.get('write_reason'):
            writes,reads=graph.must_write(n)
            require(all(bits & ~writes.get(arg,0)==0 for arg,bits in n['writes'].items()) and reads==n['write_reads'],'callee must-write/read-first obligation')
    return graph

def callee_body(e,c,node,record):
    image=node['image'];start=node['target']
    if not image.contains(start):return None
    ends=([a for a,_ in c.inp.sigs.values()] if node['side']==0 else [c.inp.text+a for a in getattr(c.inp,'code_offsets',())]) if not node['hop'] else []
    end=start+min([4096]+[a-start for a in ends if a>start]);decoded={};todo=[start];occupied=set()
    md=e.CS.Cs(e.CS.CS_ARCH_X86,e.CS.CS_MODE_32);md.detail=True
    while todo:
        pc=todo.pop()
        if pc in decoded:continue
        if not start<=pc<end:return None
        ins=next(md.disasm(image.bytes_at(pc,min(15,end-pc)),pc,count=1),None)
        e.verdict_cache.note(image,pc,ins.size if ins else min(15,end-pc))
        if ins is None:return None
        if ins.mnemonic in ('fnstenv','fstenv','fnsave','fsave','fldenv','frstor') or ins.mnemonic=='call' and ins.operands[0].type==e.X.X86_OP_IMM and ins.operands[0].imm==pc+ins.size:raise ValueError('callee context observation at '+hex(pc))
        span=set(range(pc,pc+ins.size))
        if occupied&span:return None
        occupied.update(span);decoded[pc]=e.Insn(pc,ins.size,ins.mnemonic,ins.op_str,[e.Operand.from_capstone(o) for o in ins.operands],ins)
        if pc==start and ins.mnemonic=='jmp':
            # A readable entry thunk cannot be downgraded to an opaque target.
            if ins.operands[0].type!=e.X.X86_OP_IMM and record['alias'] is None:
                op=ins.operands[0]
                if op.type!=e.X.X86_OP_MEM or op.mem.base or op.mem.index or op.mem.segment:return None
                e.match.parse_imports_once(image)
                for mod in getattr(image.pe,'DIRECTORY_ENTRY_IMPORT',()):
                    for imp in mod.imports:
                        path=c.inp.original_path.parent/mod.dll.decode('latin1')
                        if not node['hop'] and imp.address==op.mem.disp and imp.name and path.is_file():
                            other=c.inp._replay_input_images.get(str(path)) or e.match.Image(path)
                            other.pe.parse_data_directories(directories=[e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
                            if any(x.name==imp.name and not x.forwarder for x in getattr(other.pe.DIRECTORY_ENTRY_EXPORT,'symbols',())):raise ValueError('missing known import dependency at '+hex(pc))
                return None
            require(record['alias'] is not None and len(record['edges'])==1,'missing forwarding/import dependency')
            break
        if ins.mnemonic=='ret':continue
        if ins.mnemonic.startswith('j'):
            if not ins.operands or ins.operands[0].type!=e.X.X86_OP_IMM:return None
            todo.append(ins.operands[0].imm)
            if ins.mnemonic=='jmp':continue
        todo.append(pc+ins.size)
    return [decoded[pc] for pc in sorted(decoded)]

def event_shape(states):
    return [[(event[0],len(event)) for event in st.events] for st in states]

def obligations(e,states,memories):
    a,b=e.public_events.paired(states)
    require(len(a)==len(b),'missing observable event')
    goals=[memories[0]==memories[1],states[0].fs==states[1].fs,states[0].fp==states[1].fp,states[0].condition==states[1].condition]
    for x,y in zip(a,b):
        require(x[0]==y[0] and len(x)==len(y),'different observable event kind/arity')
        goals.extend(e.equality(u,v) for u,v in zip(x[1:],y[1:]))
    return goals

def frame_obligations(e,frames,states):
    preserve=set()
    if any(event[0]=='return' for event in states[0].events):
        asymmetric=set(getattr(states[0],'frame_defined',()))^set(getattr(states[1],'frame_defined',()))
        numeric=[e.z3.Implies(st.ownership.guard(st),e.outside(st.regs[r],frames.stack,frames.lows[s])) for s,st in enumerate(states) for r in ('eax','edx')]
        if asymmetric and not e.prove(numeric):preserve=asymmetric
    def project(memory,side):
        for off in range(frames.lows[side],0):
            if off not in preserve:memory=e.z3.Store(memory,frames.stack+e.bv(off),e.z3.Select(frames.public,frames.stack+e.bv(off)))
        return memory
    goals=[project(states[0].memory,0)==project(states[1].memory,1),states[0].fs==states[1].fs,states[0].fp==states[1].fp,states[0].condition==states[1].condition]
    a,b=e.public_events.paired(states);require(len(a)==len(b),'frame event count')
    for x,y in zip(a,b):
        require(x[0]==y[0] and len(x)==len(y),'frame event kind/arity')
        if x[0]!='frame-call':goals.extend(e.equality(u,v) for u,v in zip(x[1:],y[1:]));continue
        goals.extend(e.equality(x[k],y[k]) for k in range(1,len(x)) if k not in (7,11))
        memories=[x[7],y[7]];exposed=e.z3.Or(x[10],y[10])
        for side in (0,1):
            for off in range(frames.lows[side],0):
                addr=frames.stack+e.bv(off);memories[side]=e.z3.Store(memories[side],addr,e.z3.If(exposed,e.z3.Select(memories[side],addr),e.z3.Select(frames.public,addr)))
        for event in (x,y):
            for k in range(x[6].as_long()):memories=[e.z3.Store(m,event[11]+e.bv(k),e.bv(0,8)) for m in memories]
        goals.append(memories[0]==memories[1])
    for st in states:
        goals.extend(st.ownership.goals(st))
        if any(event[0]=='return' for event in st.events):goals.extend(st.regs[r]==frames.saved[r] for r in ('ebx','esi','edi','ebp'))
    return e.guarded(states,goals)

def checked(e,goals,label):
    require(e.prove(goals),'replay obligation failed/unknown: '+label)

def replay_recipe(e,c,record,base,regions):
    spec=unpack(record['recipe']);codes=[];entry=tuple(spec.get('entry',(0,0)));route=record['route']
    require(route in ('fast','relation','frames','frames-finite','acyclic'),'unknown proof route')
    expected=[[e.dataclasses.replace(i) for i in code] for code in base]
    if entry!=(0,0):
        matches=[(x,y) for x,y in zip(*regions) if (x[0],y[0])==entry];require(len(matches)==1,'forged exception root')
        for side,region in enumerate(matches[0]):
            d,roots,ret,meta=region;expected[side][d].mnemonic='eh-enter';expected[side][d].eh=meta;expected[side][d].flow=tuple(roots)
            if ret is not None:expected[side][ret].flow=();expected[side][ret].handler_return=True
    for side,rows in enumerate(record['codes']):
        code=instructions(e,rows,(c.inp.old,c.inp.new)[side]);require(len(code)==len(expected[side]),'truncated decoded range')
        for i,row,want in zip(code,rows,expected[side]):
            require(i.address==want.address and bytes(i.raw.bytes)==bytes(want.raw.bytes),'wrong decoded range')
            if row['mnemonic']!=want.mnemonic:
                require(side==1 and row['mnemonic']==e.INVERSE_JUMP.get(want.mnemonic) and tuple(row['flow'] or ())==tuple(expected[side][j].address for j in reversed(e.successors(expected[side],expected[side].index(want)))),'forged semantic rewrite')
            else:require((tuple(row['flow']) if row['flow'] is not None else None)==want.flow,'forged flow')
            require(tuple(row['eh'])==want.eh and row['handler_return']==want.handler_return,'forged exception annotation')
            i.mnemonic=row['mnemonic'];i.flow=None if row['flow'] is None else tuple(row['flow']);i.eh=tuple(row['eh']);i.handler_return=row['handler_return']
        codes.append(code)
    if route=='acyclic':return replay_paths(e,c,codes),entry
    graphs=spec['graphs'];pairing=spec['pairing'];local=[{},{}];require(len(graphs)==2,'two sides required')
    for side in (0,1):check_graph(e,codes[side],graphs[side],entry[side])
    require(set(pairing)==set(graphs[0]) and set(pairing.values())==set(graphs[1]) and len(pairing)==len(set(pairing.values())) and pairing[entry[0]]==entry[1],'missing/forged CFG pairing')
    for a,b in pairing.items():require([pairing[j] for j in graphs[0][a][1]]==list(graphs[1][b][1]),'paired edge mismatch')
    calls=[[i for i in code if i.mnemonic=='call'] for code in codes]
    for a,b in sorted(pairing.items()):
        aa,bb=graphs[0][a][0],graphs[1][b][0]
        if route=='fast':local[0][codes[0][a].address]=local[1][codes[1][b].address]=codes[0][a].address
        # Fast also maps equal-length blocks positionally; other routes pair FP ops by order.
        for kind in (('call',) if route=='fast' else ('call','fp')):
            pred=lambda i:i.mnemonic=='call' if kind=='call' else i.mnemonic in e.FP_OPS
            xs=[codes[0][k] for k in aa if pred(codes[0][k])];ys=[codes[1][k] for k in bb if pred(codes[1][k])]
            require(kind!='call' or len(xs)==len(ys),'call context pairing')
            for x,y in zip(xs,ys):local[0][x.address]=local[1][y.address]=x.address
        if route=='fast' and len(aa)==len(bb):
            for x,y in zip(aa,bb):
                local[0].setdefault(codes[0][x].address,codes[0][x].address);local[1].setdefault(codes[1][y].address,codes[0][x].address)
    require(spec['local']==local,'forged local site map')
    frames=e.Frames(codes) if route.startswith('frames') else None;garbage=None if frames else e.CutGarbage(c,codes)
    machines=[(e.FrameMachine(c.inp.addresses,s,local,frames) if frames else e.Machine(c.inp.addresses,s,local)) for s in (0,1)]
    if frames:
        require(not any(regions) and not c.full_events,'incompatible exception/full-memory frame route')
        infos=[e.check_initialized(c,code,s,frames.lows[s]) for s,code in enumerate(codes)]
        for side,machine in enumerate(machines):
            for ins in calls[side]:
                if ins.operands[0].type==e.X.X86_OP_IMM:
                    a=e.callee_cleanup(c,0,ins.operands[0].imm if side==0 else c.inp.addresses.reverse.get(ins.operands[0].imm,0));b=e.callee_cleanup(c,1,c.inp.addresses.forward.get(ins.operands[0].imm,0) if side==0 else ins.operands[0].imm)
                    if a is not None and a==b:machine.cleanups[ins.address]=a
                    if a is not None and a==b and all(e.stack_insensitive_leaf(c,s,t) for s,t in enumerate((ins.operands[0].imm if side==0 else c.inp.addresses.reverse.get(ins.operands[0].imm,0),c.inp.addresses.forward.get(ins.operands[0].imm,0) if side==0 else ins.operands[0].imm))):machine.private_calls.add(ins.address)
    def execute(head,states):
        heads=(head,pairing[head])
        if garbage and not all(hasattr(st,'ownership') for st in states):garbage.prepare(states,heads)
        for side,st in enumerate(states):
            if frames and not hasattr(st,'ownership'):e.Ownership(c,infos[side],frames.stack,heads[side]).prepare(st)
            for k in graphs[side][heads[side]][0]:
                if garbage:garbage.step(machines[side],st,side,k)
                else:machines[side].step(st,codes[side][k])
            if frames:st.frame_defined=infos[side]['after'][graphs[side][heads[side]][0][-1]][1]
        return states
    events=[];count=0
    if route=='frames-finite':
        initial,_=frames.states(initial=True);todo=[(entry[0],initial,e.z3.BoolVal(True),frozenset())]
        while todo:
            head,states,guard,seen=todo.pop();count+=1;require(head not in seen and count<=6000 and len(todo)<=128,'finite frame replay budget/loop')
            for st in states:st.path=guard
            execute(head,states);checked(e,[e.z3.Implies(guard,e.conjunction(frame_obligations(e,frames,states)))],'finite frame transition');events.append(event_shape(states))
            for edge,j in enumerate(graphs[0][head][1]):todo.append((j,frames.clone(states),e.simp(e.z3.And(guard,e.edge_guard(states[0],codes[0][graphs[0][head][0][-1]],len(graphs[0][head][1]),edge))),seen|{head}))
        return dict(route=route,transitions=count,events=events),entry
    candidates=spec['candidates'];require(set(candidates)==set(pairing),'missing invariant')
    if route=='fast':require(all(set(v)<=e.ALL for v in candidates.values()) and all(set(v)<=set(e.FLAGS) for v in spec['flag_candidates'].values()),'unknown fast invariant')
    if route=='relation':require(all(f[0] in ('eq','const','delta') for facts in candidates.values() for f in facts),'unknown relation invariant')
    if frames:
        initial,_=frames.states(initial=True);checked(e,[frames.fact(initial,f) for f in sorted(candidates[entry[0]],key=repr)],'frame initialization')
    else:
        allowed=e.DIAG if entry==(0,0) else frozenset((r,r,k) for r in ('eax','edx','ecx','ebp','esp') for k in range(4))
        flags=e.FLAGS if entry==(0,0) else ()
        require(spec['entry_candidates']==allowed and set(spec['entry_flags'])==set(flags),'weakened entry relation')
        if route=='fast':require(candidates[entry[0]]<=allowed and spec['flag_candidates'][entry[0]]<=set(flags),'uninitialized fast invariant')
        else:
            initial=e.arbitrary(allowed,flags);garbage.prepare(initial,entry);checked(e,[e.fact_expression(initial,f) for f in sorted(candidates[entry[0]],key=repr)],'relation initialization')
    for head in sorted(pairing):
        premise=e.z3.BoolVal(True)
        if frames:states,premise=frames.states(candidates[head])
        elif route=='fast':states=e.arbitrary(candidates[head],spec['flag_candidates'][head])
        else:
            states,_=e.relation_states(candidates[head]);garbage.prepare(states,(head,pairing[head]))
            premise=e.simp(e.z3.And([e.fact_expression(states,f) for f in sorted(candidates[head],key=repr)]))
        if frames:
            for st in states:st.path=premise
        execute(head,states)
        tails=tuple(graphs[s][(head,pairing[head])[s]][0][-1] for s in (0,1))
        goals=frame_obligations(e,frames,states) if frames else obligations(e,states,garbage.memories(states,tails))
        for edge,target in enumerate(graphs[0][head][1]):
            guard=e.edge_guard(states[0],codes[0][tails[0]],len(graphs[0][head][1]),edge)
            if frames:next_goals=[frames.fact(states,f) for f in sorted(candidates[target],key=repr)]
            elif route=='relation':next_goals=[e.fact_expression(states,f) for f in sorted(candidates[target],key=repr)]
            else:next_goals=[e.register_byte(states[0],a,k)==e.register_byte(states[1],b,k) for a,b,k in sorted(candidates[target])]+[states[0].flags[f]==states[1].flags[f] for f in sorted(spec['flag_candidates'][target])]
            goals.extend(e.z3.Implies(guard,g) for g in next_goals)
        checked(e,e.guarded(states,[e.z3.Implies(premise,e.conjunction(goals))]),'transition at '+hex(codes[0][graphs[0][head][0][-1]].address));count+=1;events.append(event_shape(states))
    return dict(route=route,transitions=count,events=events),entry

def replay_paths(e,c,codes):
    require(not any(i.mnemonic=='call' for code in codes for i in code),'acyclic call')
    starts=e.arbitrary(e.DIAG,e.FLAGS);stack=e.z3.BitVec('finite_entry_esp',32);entry_memory=starts[0].memory;lows=[e.private_extent(code) for code in codes]
    for st in starts:st.regs['esp']=stack
    e.independent_private(starts,lows,stack);paths=[]
    for side,start in enumerate(starts):
        info=e.check_initialized(c,codes[side],side,lows[side]);e.Ownership(c,info,stack).prepare(start)
        machine=e.Machine(c.inp.addresses,side,[{},{}]);todo=[(0,start,e.z3.BoolVal(True),frozenset(),0)];out=[];visits=0
        while todo:
            k,st,guard,seen,low=todo.pop();visits+=1;require(k not in seen and visits<=6000 and len(out)+len(todo)<=128,'acyclic replay budget/loop')
            ins=codes[side][k];st.path=guard;machine.step(st,ins);off=e.simp(st.regs['esp']-stack);require(e.z3.is_bv_value(off),'unknown path ESP')
            off=off.as_long();off=off-2**32 if off>=2**31 else off;low=min(low,off);require(low>=-4096,'path private extent')
            edges=e.successors(codes[side],k)
            if not edges:st.frame_defined=info['after'][k][1];out.append((guard,st,low));continue
            for edge,j in enumerate(edges):
                g=e.simp(e.z3.And(guard,e.edge_guard(st,ins,len(edges),edge)))
                if e.z3.is_false(g):continue
                clone_st=e.Frames.clone([st])[0]
                for attr in ('events','faults','access_pcs','private_indices','condition'):setattr(clone_st,attr,clone(getattr(st,attr,set() if attr=='private_indices' else {})))
                todo.append((j,clone_st,g,seen|{k},low))
        require(out,'no finite path');paths.append(out)
    asymmetric=set().union(*(x[1].frame_defined^y[1].frame_defined for x in paths[0] for y in paths[1]))
    projected=[]
    for pp in paths:
        side=[]
        for guard,st,low in pp:
            st.ownership.result(st);memory=st.memory
            if not c.full_events and e.prove(st.ownership.goals(st)):
                numeric=e.prove([e.z3.Implies(st.ownership.guard(st),e.outside(st.regs[r],stack,low)) for r in ('eax','edx')])
                for off in range(low,0):
                    if off not in asymmetric or numeric:memory=e.z3.Store(memory,stack+e.bv(off),e.z3.Select(entry_memory,stack+e.bv(off)))
            side.append((guard,st,memory))
        projected.append(side)
    for left,right in (projected,projected[::-1]):
        for guard,st,memory in left:
            choices=[]
            for other_guard,other,other_memory in right:
                try:goals=obligations(e,[st,other],[memory,other_memory])
                except ValueError:goals=[e.z3.BoolVal(False)]
                choices.append(e.z3.And(other_guard,e.conjunction(goals)))
            checked(e,e.guarded([st]+[q[1] for q in right],[e.z3.Implies(guard,e.z3.Or(choices))]),'finite paths')
    return dict(route='acyclic',transitions=sum(map(len,paths)),events=[event_shape([p[1]]) for pp in paths for p in pp])

def _validate(cert,inp=None,produce=False):
    require(type(cert) is dict and cert.get('schema_version')==2,'certificate schema')
    headers={'schema_version','versions','inputs','images','argv','function','full_events','recipes','local_bindings','bindings','callees','rlimit'}
    outputs={'stage','hypotheses','proof_results','event_rules','roots','decoded_ranges','storage_ranges'}
    require(set(cert)==headers|(set() if produce else outputs),'malformed certificate fields')
    require(cert.get('versions')==versions(),'stale checker/semantics version')
    require(all(pathlib.Path(f).is_file() and hashlib.sha256(pathlib.Path(f).read_bytes()).hexdigest()==h for f,h in cert['inputs'].items()),'stale input hash')
    e=rules()
    if inp is None:require(cert.get('argv') is not None,'certificate has no image arguments');inp=e.Inputs(cert['argv'])
    require(set(cert['inputs'])=={str(f) for f in getattr(inp,'cache_files',())},'missing input hashes')
    require(cert['inputs']==getattr(inp,'replay_inputs',cert['inputs']),'input tables changed after loading')
    require(cert['images']==[image_hash(inp.old),image_hash(inp.new)],'stale image hash')
    require(type(cert['full_events']) is bool and cert['recipes'],'missing proof recipes')
    require(cert['rlimit']==dict(rlimit=e.limits.RLIMIT,expected_ms=e.limits.EXPECTED_MS,safety_factor=10,work_units_per_ms=e.limits.UNITS_PER_MS,inference_expected_ms=e.limits.INFERENCE_EXPECTED_MS,max_steps=e.limits.MAX_STEPS),'solver limits changed')
    with context(inp) as (e,c):
        fn=next((f for f in inp.functions if {k:v for k,v in vars(f).items() if k not in ('a','b')}==cert['function']),None);require(fn is not None,'unknown function/extent')
        for k,v in dict(full_events=cert['full_events'],garbage_cache={},h8_reads={},fault_private={},fault_emitted=False,ownership_failure=None,access_failure=None).items():setattr(c,k,v)
        base=[];regions=[]
        for side,code in enumerate(c.instructions(fn)):
            code,rr=c.exception_regions(code,side);base.append(code);regions.append(rr)
        require(len(regions[0])==len(regions[1]),'exception roots differ')
        local_identities(e,c,base,regions,cert['local_bindings'])
        if any(p=='local-cfg' for _,_,p in cert['bindings']):require(all(r['route']=='fast' for r in cert['recipes']),'local-cfg identities require their structural proof route')
        deferred=set()
        for a,b,p in cert['bindings']:
            if p.startswith('pointer-cell:'):
                require(a==b and any(a in cells and cells[a][1]==p[len('pointer-cell:'):] for cells in c.inp.addresses.pointer_cells),'forged pointer-cell record')
            elif any(v[1]==(a,b,p) for points in c.inp.addresses.pointee_symbols for v in points.values()):pass
            elif p.startswith('typed-content-record:pointee'):deferred.add((a,b,p))
            else:require(c.inp.addresses.forward.get(a)==b and c.inp.addresses.provenance.get((a,b))==p,'forged binding/provenance')
        c.contracts=e.CallContracts(c);c.inp.addresses.call_contracts=c.contracts
        for side,cells in enumerate(c.inp.addresses.pointer_cells):
            for cell,(pointee,record) in cells.items():
                if [cell,cell,'pointer-cell:'+record] in cert['bindings'] and cell not in c.inp.addresses.import_locations[side]:require(c.inp.addresses.u32((c.inp.old,c.inp.new)[side],cell)==pointee,'changed accepted pointer cell '+hex(cell))
        graph=callee_graph(e,c,cert['callees']);c.contracts.prepare(*base);c.contracts.ready=True
        for (side,pc),(inputs,_,site) in c.contracts.sites.items():
            if 'H3c' not in site.get('premises',[]) or site.get('kind')!='direct':continue
            node=graph.nodes.get((side,id((c.inp.old,c.inp.new)[side]),int(site['target'],16),0));seen=set()
            while node and node.get('alias') is not None:
                key=node['alias'];require(key not in seen,'recursive thunk');seen.add(key);node=graph.nodes[key]
            if node and node.get('replay_read'):
                required,_,passed=node['replay_read'];ins=next(i for i in base[side] if i.address==pc)
                needed=required|(passed & c.contracts.observed_flags.get(c.contracts.flag_key(side,ins),set()))
                missing=needed-inputs-{('r','esp',k) for k in range(4)}
                require(not missing,'H3c violated at call '+hex(pc)+' to '+hex(node['target'])+': '+repr(sorted(missing)))
        c.frame_lows=[e.private_extent(code) for code in base]
        require(not any(regions) or not any(c.frame_lows),'exception/private frame relation unavailable')
        c.inp.addresses.active_cells=[set(),set()]
        c.image_relation=e.image_relation.Relation(c,base);e.image_relation.ACTIVE=c.image_relation
        for s in (0,1):c.inp.addresses.active_cells[s].update(cell for i in base[s] for op in i.operands if op.type==e.X.X86_OP_MEM and not op.mem.segment for cell,width in c.inp.addresses.protected(s).items() if max(cell,op.mem.disp)<min(cell+width,op.mem.disp+op.size))
        results=[];roots=set()
        for record in cert['recipes']:
            result,root=replay_recipe(e,c,record,base,regions);results.append(result);roots.add(root)
        expected_roots={(0,0)}|{(a[0],b[0]) for a,b in zip(*regions)};require(roots==expected_roots,'missing exception/ordinary root')
        require(deferred<=c.inp.addresses.consulted,'unjustified typed pointee identity')
        require(c.inp.addresses.consulted<={tuple(v) for v in cert['bindings']},'missing consulted binding')
        assumed=set()
        if c.contracts.h1:assumed.add('H1')
        for h in ('H3','H3c'):
            if any(h in v[2].get('premises',[v[2].get('premise','H3')]) for v in c.contracts.sites.values()):assumed.add(h)
        if c.contracts.h5 or c.image_relation.checked:assumed.add('H5')
        if c.fault_emitted:assumed.add('H6')
        if c.h8_reads:assumed.add('H8')
        if c.contracts.h9:assumed.add('H9')
        hypotheses={h:dict(status='assumed' if h in assumed else 'discharged',predicate=predicate,evidence=[]) for h,predicate in POLICY.items()}
        # H1 formulae are regenerated above; certify source locations, not allocation-dependent SMT printouts.
        hypotheses['H1']['evidence']=pack(dict(entry=sorted((v|dict(predicate='regenerated EntrySeparation') for v in getattr(c.contracts,'entry_separation',{}).values()),key=str),abi_instances=sorted(c.contracts.h1)))
        hypotheses['H3']['evidence']=pack([v[2] for _,v in sorted(c.contracts.sites.items())])
        hypotheses['H3c']['evidence']=pack([v[2] for _,v in sorted(c.contracts.sites.items()) if 'H3c' in v[2].get('premises',[])])
        hypotheses['H5']['evidence']=pack(c.image_relation.summary());hypotheses['H6']['evidence']=pack([v for _,v in sorted(c.fault_private.items())])
        hypotheses['H8']['evidence']=pack(sorted(c.h8_reads.values(),key=repr));hypotheses['H9']['evidence']=pack([v for _,v in sorted(c.contracts.h9.items())])
        derived=dict(stage='replayed',hypotheses=hypotheses,proof_results=results,event_rules=[r['events'] for r in results],roots=sorted(map(list,roots)),
                     decoded_ranges=[[code[0].address,max(i.address+i.size for i in code)] for code in base],storage_ranges=pack(c.image_relation.summary()))
        derived=json.loads(json.dumps(derived))
        if produce:return cert|derived
        for key,value in derived.items():require(cert.get(key)==value,'missing/weakened/stale '+key)
    return True

def validate(cert,inp=None,produce=False):
    try:return _validate(cert,inp,produce)
    except rules().limits.SafetyCap:raise
    except Exception as error:raise ValueError(str(error)) from error

def main():
    try:
        require(len(sys.argv)==2,'usage: equiv_replay.py certificate.json')
        cert=json.loads(pathlib.Path(sys.argv[1]).read_text());start=time.monotonic();validate(cert)
        print(json.dumps(dict(status='REPLAYED',seconds=time.monotonic()-start)));return 0
    except Exception as error:
        print(json.dumps(dict(status='REJECTED',reason=str(error))));return 1

if __name__=='__main__':raise SystemExit(main())
