"""Untrusted proof recipes; only equiv_replay can complete a certificate."""
import hashlib,json,pathlib,time
from equiv_certificate import pack,unpack,code,versions,image_hash,check_claims

def capture(c,route,codes,**recipe):
    if hasattr(c,'_certificate_recipes'):
        c._certificate_recipes.append(dict(route=route,codes=[code(a) for a in codes],recipe=pack(recipe)))

def nodes(c):
    graph=getattr(c.inp,'call_summaries',None)
    if graph is None:return []
    selected=set(getattr(c.contracts,'summary_budgets',{}));todo=list(selected)
    while todo:
        for child,_ in graph.nodes[todo.pop()]['edges'].values():
            if child not in selected:selected.add(child);todo.append(child)
    keys=sorted(selected,key=lambda k:(k[0],graph.image_labels[k[1]],k[3],k[2]));ids={k:n for n,k in enumerate(keys)};out=[]
    for k in keys:
        n=graph.nodes[k];im=n['image'];side=n['side']
        ref=str(side) if im is (c.inp.old,c.inp.new)[side] else graph.image_labels[id(im)]
        fields={v:n.get(v) for v in ('value','valid','writes','write_reads','write_reason','h1','hazard','reason','cleanup','budget_outcomes','decoded_bytes','work','read_iterations','write_iterations')}
        out.append(dict(side=side,image=ref,image_hash=image_hash(im),target=n['target'],hop=n['hop'],
                        ranges=[[a,size,hashlib.sha256(im.bytes_at(a,size)).hexdigest()] for a,size in n['ranges']],
                        code=code(n['code']) if n.get('code') is not None else None,fields=pack(fields),
                        edges=[[pc,ids[child],kind] for pc,(child,kind) in sorted(n['edges'].items())],
                        alias=ids[n['alias']] if n['alias'] is not None else None))
    return out

def finish(c,fn,status):
    import equiv_replay
    inputs=getattr(c.inp,'replay_inputs',None)
    if inputs is None:inputs={str(f):hashlib.sha256(pathlib.Path(f).read_bytes()).hexdigest() for f in sorted(getattr(c.inp,'cache_files',()),key=str)}
    proposal=dict(schema_version=2,versions=versions(),inputs=inputs,
                  images=[image_hash(c.inp.old),image_hash(c.inp.new)],argv=getattr(c.inp,'replay_argv',None),
                  function={k:v for k,v in vars(fn).items() if k not in ('a','b')},
                  full_events=c.full_events,recipes=c._certificate_recipes,local_bindings=sorted(c._certificate_local.items()),
                  bindings=[list(v) for v in sorted(c.inp.addresses.consulted)],callees=nodes(c),
                  rlimit=c.last_contracts['solver_limits'])
    start=time.monotonic()
    try:certificate=equiv_replay.validate(proposal,c.inp,produce=True)
    finally:c.replay_seconds=time.monotonic()-start
    check_claims(status,certificate)
    c.last_certificate=certificate
    c.last_contracts['replay']=dict(schema_version=2,validated=True,
                                  recipes=len(certificate['recipes']),obligations=certificate['proof_results'],hypotheses=certificate['hypotheses'])
    return certificate

def save(c,fn):
    directory=getattr(c.inp,'certificate_dir',None)
    if directory is not None and getattr(c,'last_certificate',None) is not None:
        directory.mkdir(parents=True,exist_ok=True)
        name=hashlib.sha256(f'{fn.name}:{fn.ova:x}:{fn.nva:x}'.encode()).hexdigest()+'.json'
        (directory/name).write_text(json.dumps(c.last_certificate,sort_keys=True),encoding='utf8')
