"""Dependency-validated verdict replay. Cache contents are not proof certificates."""
import hashlib,json,os,tempfile,sys,gc,time
from contextlib import contextmanager
from pathlib import Path
from threading import local
ACTIVE = local()
def recorder():return getattr(ACTIVE,'record',None)
def packed(x): return json.dumps(x,sort_keys=True,separators=(',',':'))
def digest(x): return hashlib.sha256(x).hexdigest()
def frozen(x):
    if isinstance(x,dict): return {repr(k):frozen(v) for k,v in x.items()}
    if isinstance(x,(tuple,list)): return [frozen(v) for v in x]
    if isinstance(x,(set,frozenset)): return sorted(map(frozen,x),key=repr)
    if isinstance(x,bytes): return x.hex()
    return x
def raw(img,a,n): return getattr(img,'_verdict_read',img.bytes_at)(a,n)
def note(img,a,n):
    data=raw(img,a,n)
    r=recorder()
    if r is not None:r.reads[r.ref(img),a,n]=digest(data)
    return data
def imported(img,cell,path,name):
    r=recorder()
    if r is not None:
        key=(r.ref(img),cell,str(path),name.hex());r.imports[key]=r.import_value(key)
def handler_name(d,side,target):
    name=d.names[side].get(target,'')
    if side==1:name=next((n for n,a in d.map_addresses.items() if a==target and n.startswith('@Handle')),name)
    r=recorder()
    if r is not None:r.handlers[side,target]=name
    return name
def handles(old,new):
    r=recorder()
    if r is not None:r.handles=[old,new]

def prepare(checker):
    checker.last_certificate=None;checker.replay_seconds=0.0
    """Each proof starts from the same analysis state, regardless of replay history."""
    for obj,names in ((checker.inp,('call_summaries',)),(checker,('_cleanup_cache','_cleanup_images','_cleanup_unreadable','_private_call_cache'))):
        for name in names:
            if hasattr(obj,name):delattr(obj,name)
    d=checker.inp.addresses
    # Reviewed names are module inputs; only proof-consultation sets are transient.
    d.consulted.clear();d.unresolved.clear();checker.last_contracts={}


@contextmanager
def proof_context(checker):
    # Z3 allocation IDs also affect simplification/search. Isolate them, and keep
    # cyclic collection from changing AST lifetimes during a proof. Restore the
    # caller's default context because the existing model uses default builders.
    e=sys.modules[type(checker).__module__];z=e.z3;d=checker.inp.addresses
    defaults=z.main_ctx.__globals__;old_context=z.main_ctx()
    old_sorts=(e.BV32,e.BYTE,e.MEM);old_points=d.pointee_symbols;collecting=gc.isenabled()
    gc.disable()
    try:
        context=z.Context();defaults['_main_ctx']=context
        e.BV32,e.BYTE=z.BitVecSort(32),z.BitVecSort(8);e.MEM=z.ArraySort(e.BV32,e.BYTE)
        d.pointee_symbols=[{k:(points[k][0].translate(context),points[k][1]) for k in sorted(points,key=repr)} for points in old_points]
        yield
    finally:
        d.pointee_symbols=old_points;e.BV32,e.BYTE,e.MEM=old_sorts
        defaults['_main_ctx']=old_context
        if collecting:gc.enable()


class Cache:
    SCHEMA = 2
    def __init__(self,checker,directory):
        self.c=checker;self.e=sys.modules[type(checker).__module__];self.root=Path(directory)
        self.root.mkdir(parents=True,exist_ok=True);self.images={}
        self.files={str(p):digest(Path(p).read_bytes()) for p in getattr(checker.inp,'cache_files',())}
        tools=Path(__file__).parent
        self.version={p.name:digest(p.read_bytes()) for p in [tools/'equiv.py',tools/'match.py',tools/'match_flow.py',*sorted(tools.glob('equiv_*.py'))]}
        self.semantic=digest(packed(frozen([checker.inp.sigs,checker.inp.syms,getattr(checker.inp,'code_offsets',())])).encode())
        self.classification=digest(packed(frozen([checker.inp.addresses.relocs,checker.inp.addresses.import_bytes])).encode())
    def ref(self,img):
        for s,root in enumerate((self.c.inp.old,self.c.inp.new)):
            if img is root:return str(s)
        return str(img.path)
    def image(self,ref):
        if ref in ('0','1'):return (self.c.inp.old,self.c.inp.new)[int(ref)]
        if ref not in self.images:self.images[ref]=self.e.match.Image(ref)
        return self.images[ref]
    def import_value(self,key):
        ref,cell,path,name=key;img=self.image(ref);self.e.match.parse_imports_once(img)
        descriptors=[(m.dll.hex(),getattr(i,'name',None).hex() if i.name else None,getattr(i,'ordinal',None))
                     for m in getattr(img.pe,'DIRECTORY_ENTRY_IMPORT',()) for i in m.imports if i.address==cell]
        if not Path(path).is_file():return frozen([descriptors,None])
        other=self.image(path);other.pe.parse_data_directories(directories=[self.e.match.pefile.DIRECTORY_ENTRY['IMAGE_DIRECTORY_ENTRY_EXPORT']])
        return frozen([descriptors,other.base,other.hi,[(x.address,x.forwarder) for x in getattr(getattr(other.pe,'DIRECTORY_ENTRY_EXPORT',None),'symbols',()) if x.name and x.name.hex()==name]])
    def identity(self,a,b,p):
        d=self.c.inp.addresses
        storage=[(r, [[(s.VirtualAddress,s.Misc_VirtualSize,getattr(s,'SizeOfRawData',None),s.Characteristics)
                       for s in img.pe.sections if img.base+s.VirtualAddress<=r[side]<img.base+s.VirtualAddress+s.Misc_VirtualSize]
                      for side,img in enumerate((d.old,d.new))] if r[3]=='bss' else [])
                 for r in sorted(set(d.storage_objects)) if r[0]<=a<r[0]+r[2] or b is not None and r[1]<=b<r[1]+r[2]]
        return frozen([storage,d.forward.get(a),d.reverse.get(a),d.reverse.get(b),d.provenance.get((a,b)),a in d.conflicts,b in d.conflicts,
                       [n.get(x) for n,x in zip(d.names,(a,b))],
                       [v.get(x) for v,x in zip(d.import_locations,(a,b))],
                       [v.get(x) for v,x in zip(d.pointer_cells,(a,b))],
                       [(s,str(k),str(v[0]),v[1]) for s,vs in enumerate(d.pointee_symbols) for k,v in vs.items() if v[1]==(a,b,p)]])
    def base(self,fn,matched):
        d=self.c.inp.addresses;from equiv_summaries import ModuleSummaries as S
        return frozen([self.SCHEMA,self.version,self.files,self.e.z3.get_version_string(),self.e.CS.__version__,
                       vars(fn)|{'a':None,'b':None},matched,self.semantic,self.classification,self.e.limits.RLIMIT,self.e.limits.EXPECTED_MS,
                       self.e.limits.UNITS_PER_MS,self.e.limits.MAX_STEPS,self.e.limits.INFERENCE_EXPECTED_MS,
                       [S.BYTE_LIMIT,S.INSTRUCTION_LIMIT,S.SCC_ITERATION_LIMIT],
                       [d.protected(s) for s in (0,1)],
                       [(im.base,im.hi,[(s.VirtualAddress,s.Misc_VirtualSize,s.Characteristics) for s in im.pe.sections]) for im in (self.c.inp.old,self.c.inp.new)]])
    def run(self,fn,callback,matched=False):
        if recorder() is not None:raise self.e.Unsupported('nested verdict-cache check')
        c=self.c;d=c.inp.addresses;c.cache_hit=None;self.images={};base=self.base(fn,matched)
        path=self.root/(digest(packed([str(c.inp.original_path),fn.name,fn.ova,fn.nva,matched]).encode())+'.json')
        entry=None
        try:
            entry=self.load(path);p=entry['payload']
            assert type(entry['schema']) is int and entry['schema']==self.SCHEMA and digest(packed(p).encode())==entry['key'] and p['base']==base
            assert all(digest(raw(self.image(r),a,n))==h for r,a,n,h in p['reads'])
            assert all(self.identity(a,b,src)==v for a,b,src,v in p['identities'])
            assert all(self.import_value(k)==v for k,v in p['imports'])
            assert all(handler_name(d,s,t)==v for s,t,v in p['handlers'])
            assert p['handles'] is None or p['handles']==[self.e.match.find_import_thunk(c.inp.old,'System.@HandleOnException'),d.map_addresses.get('@HandleOnException')]
            c.last_contracts=p['explain'];d.consulted={tuple(v) for v in p['consulted']};d.unresolved={tuple(v) for v in p['unresolved']}
            from equiv_certificate import refresh,check_claims
            c.last_certificate=refresh(p['certificate'],self.image) if p.get('certificate') else None
            if p['result'][0].startswith('PROVEN'):
                from equiv_replay import validate
                assert c.last_certificate is not None
                start=time.monotonic()
                try:validate(c.last_certificate,c.inp);check_claims(p['result'][0],c.last_certificate)
                finally:c.replay_seconds=time.monotonic()-start
                assert p['explain']['replay']['hypotheses']==c.last_certificate['hypotheses']
            c.cache_hit=entry['key'];return tuple(p['result'])
        except self.e.limits.SafetyCap as error:
            c.last_certificate=None;c.last_contracts['replay']=dict(validated=False,reason=str(error))
            return 'NOT PROVEN',str(error)+' during certificate replay at '+hex(fn.ova)
        except (OSError,ValueError,KeyError,TypeError,AssertionError,self.e.match.pefile.PEFormatError):pass
        self.reads={};self.imports={};self.handlers={};self.handles=None;saved=[];ACTIVE.record=self
        try:
            for img in (c.inp.old,c.inp.new):
                old=img.bytes_at;saved.append((img,old));img._verdict_read=old;img.bytes_at=lambda a,n,img=img:note(img,a,n)
            if matched:
                c.last_contracts={};d.consulted.clear();d.unresolved.clear()
                end=min([fn.ova+fn.osize+128]+[a for a,_ in c.inp.sigs.values() if a>fn.ova])
                note(c.inp.old,fn.ova,end-fn.ova);note(c.inp.new,fn.nva,fn.nsize)
            result=callback();graph=getattr(c.inp,'call_summaries',None);nodes=[]
            for k in getattr(c.contracts,'summary_budgets',{}) if not matched else ():
                n=graph.nodes[k]
                for img,cell,path_,name in n.get('imports',()):imported(img,cell,path_,name)
                for a,size in n['ranges']:note(n['image'],a,size)
                nodes.append(dict(side=n['side'],image=self.ref(n['image']),target=n['target'],hop=n['hop'],
                                  bytes=[[a,size,digest(raw(n['image'],a,size))] for a,size in n['ranges']],
                                  summary=frozen([n['value'],n.get('cleanup'),n['writes'],n['write_reads'],n['valid'],n['h1'],n['hazard'],n['reason'],n['budget_outcomes']])))
            identities=[[a,b,src,self.identity(a,b,src)] for a,b,src in sorted(d.consulted)]
            # Pending identities also invalidate a prior unsupported verdict when resolved.
            identities += [[a,d.forward.get(a), 'unresolved',self.identity(a,d.forward.get(a),'unresolved')] for s,x in sorted(d.unresolved) for a in [x if s==0 else d.reverse.get(x,x)]]
            for s,im in enumerate((c.inp.old,c.inp.new)):
                for a,width in d.protected(s).items():
                    if any(a<=x<a+width for x,y,_ in d.consulted for x in ([x] if s==0 else [y])):note(im,a,width)
            p=dict(base=base,reads=[[r,a,n,h] for (r,a,n),h in sorted(self.reads.items())],nodes=nodes,
                   identities=identities,imports=list(self.imports.items()),handlers=[[s,t,v] for (s,t),v in self.handlers.items()],handles=self.handles,result=result,explain=c.last_contracts,
                   consulted=sorted(d.consulted),unresolved=sorted(d.unresolved),certificate=c.last_certificate)
            entry=dict(schema=self.SCHEMA,key=digest(packed(p).encode()),payload=p)
            self.save(path,entry)
            return result
        finally:
            ACTIVE.record=None
            for img,old in saved:img.bytes_at=old;del img._verdict_read
    @staticmethod
    def load(path):return json.loads(path.read_text())
    @staticmethod
    def save(path,entry):
        temporary=None
        try:
            with tempfile.NamedTemporaryFile('w',dir=path.parent,delete=False) as f:temporary=Path(f.name);json.dump(entry,f,separators=(',',':'))
            os.replace(temporary,path)
        except OSError:pass  # Storage failures never create hits.
        finally:
            try:
                if temporary is not None:temporary.unlink(missing_ok=True)
            except OSError:pass
