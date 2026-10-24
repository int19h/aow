"""Certificate values and fingerprints; no producer or proof engine imports."""
import dataclasses,hashlib,pathlib

def pack(x):
    if isinstance(x,dict):return {'dict':[[pack(k),pack(v)] for k,v in sorted(x.items(),key=lambda r:repr(r[0]))]}
    if isinstance(x,(set,frozenset)):return {'set':[pack(v) for v in sorted(x,key=repr)]}
    if isinstance(x,tuple):return {'tuple':[pack(v) for v in x]}
    if isinstance(x,list):return [pack(v) for v in x]
    return x

def unpack(x):
    if isinstance(x,list):return [unpack(v) for v in x]
    if isinstance(x,dict):
        if set(x)=={'dict'}:return {unpack(k):unpack(v) for k,v in x['dict']}
        if set(x)=={'set'}:return set(map(unpack,x['set']))
        if set(x)=={'tuple'}:return tuple(map(unpack,x['tuple']))
        raise ValueError('malformed recipe value')
    return x

def code(c):
    return [dict(pc=i.address,raw=bytes(i.raw.bytes).hex(),mnemonic=i.mnemonic,
                 flow=i.flow,eh=i.eh,handler_return=i.handler_return,
                 operands=[pack(dataclasses.asdict(o)) for o in i.operands],mutation=i.mutation) for i in c]

def versions():
    p=pathlib.Path(__file__).parent
    return {f.name:hashlib.sha256(f.read_bytes()).hexdigest() for f in
            [p/'equiv.py',p/'match.py',p/'match_flow.py',p/'equiv_certificate.schema.json',*sorted(p.glob('equiv_*.py'))]}

def image_hash(image):
    return hashlib.sha256(bytes(image.data)).hexdigest()

def refresh(cert,image):
    """Reuse checked part dependencies; update only redundant whole-image seals."""
    import copy
    cert=copy.deepcopy(cert);hashes={}
    def current(ref):
        if ref not in hashes:hashes[ref]=image_hash(image(ref))
        return hashes[ref]
    cert['images']=[current('0'),current('1')]
    for node in cert['callees']:node['image_hash']=current(node['image'])
    return cert

def check_claims(status,cert):
    declared=set() if status=='PROVEN' else set(status.removeprefix('PROVEN under ').split(','))
    required={h for h,v in cert['hypotheses'].items() if v['status']=='assumed'}
    if not status.startswith('PROVEN') or not required<=declared<=set(cert['hypotheses']):raise ValueError('undeclared/unknown certificate premises')
