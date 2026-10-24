"""Untrusted-certificate tampering and actual-byte mutation adjudication."""
import copy,json,pathlib,tempfile,unittest
from unittest.mock import patch
import equiv as e
import equiv_replay as replay
from equiv_emit import pack,unpack
from .support import build

ROUTES=('fast','relation','frames','frames-finite','acyclic')


def force(c,route):
    def verify(a,b,entry=(0,0),entry_candidates=e.DIAG,entry_flags=e.FLAGS):
        if route=='fast':return c.verify_fast(a,b,entry,entry_candidates,entry_flags)
        if route=='acyclic':return c.acyclic(a,b)
        if route.startswith('frames'):return e.verify_frames(c,a,b,finite=route=='frames-finite')
        graphs=[e.blocks(a,entry[0]),e.blocks(b,entry[1])]
        return c.houdini(a,b,graphs,[e.live_locations(x,g) for x,g in zip((a,b),graphs)],entry,entry_candidates,entry_flags)
    c.verify=verify


def mutations():
    """Each change is actual input bytes, not a producer-only instruction edit."""
    return [
        ('constant','b801000000c3','b802000000c3','0x401000 mov eax,1 -> mov eax,2'),
        ('global','a100204000c3','a104204000c3','0x401000 mov eax,[0x402000] -> [0x402004]'),
        ('relocation-target','8b8100204000c3','8b8104204000c3','0x401000 mov eax,[ecx+0x402000] -> +0x402004'),
        ('branch','31c07405b801000000c3','31c07505b801000000c3','0x401002 je -> jne'),
        ('suffix','b801000000c3','b80100000040c3','0x401005 ret -> inc eax; ret'),
        ('table','8b048d00204000c3','8b048d04204000c3','0x401000 indexed table 0x402000 -> 0x402004'),
        ('callee','e8fb000000c3','e8fb010000c3','0x401000 call 0x401100 -> 0x401200'),
        ('class','b800204000c3','b804204000c3','0x401000 class argument 0x402000 -> 0x402004'),
        ('register-immediate','b801000000b901000000c3','b801000000b902000000c3','0x401005 mov ecx,1 -> mov ecx,2'),
        ('typed-bytes','a100204000c3','a100204000c3','0x401000 read immutable dword: initial 1 -> 2'),
        ('named-class','','','0x401000 constructor class First -> Second'),
    ]


def adjudicate():
    rows=[]
    for route in ROUTES:
        for kind,a,b,change in mutations():
            extras=[(0x1100,bytes.fromhex('b801000000c3')),(0x1200,bytes.fromhex('b802000000c3'))]
            def fixture(mutant):
                if kind=='named-class':
                    from .test_class_references import ClassReferences
                    return ClassReferences().fixture(wrong_class=mutant)
                aa=extras+([(0x2000,(1).to_bytes(4,'little'))] if kind=='typed-bytes' else [])
                bb=extras+([(0x2000,(2 if mutant else 1).to_bytes(4,'little'))] if kind=='typed-bytes' else [])
                c,f=build(a,b if mutant else a,extras_a=aa,extras_b=bb,readonly=kind=='typed-bytes',bindings=[(v,v) for v in (0x402000,0x402004,0x401100,0x401200)])
                for s in (0,1):
                    for address,name in ((0x402000,'Fixture.First'),(0x402004,'Fixture.Second')):c.inp.addresses.names[s][address]=name
                if kind=='typed-bytes':
                    c.inp.addresses.storage_objects=[(0x402000,0x402000,4,'immutable-data','reviewed fixture layout')]
                    for s in (0,1):c.inp.addresses.immutable_data[s][0x402000]=4
                if kind=='relocation-target':
                    for s in (0,1):c.inp.addresses.relocs[s].add(0x401002)
                return c,f
            baseline,fn=fixture(False);force(baseline,route);control=baseline.check(fn)
            c,f=fixture(True)
            force(c,route);status,reason=c.check(f)
            rows.append(dict(route=route,kind=kind,status=status,reason=reason,baseline=control,differing_instruction=change,
                             adjudication=('equivalent: dead volatile-register write' if kind=='register-immediate' else 'unresolved; Fable review required') if status.startswith('PROVEN') else 'rejected'))
    return rows


class Replay(unittest.TestCase):
    def certificate(self,body='5389105bc3',other=None):
        c,f=build(body,other or body);self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        return c,json.loads(json.dumps(c.last_certificate))
    def test_disk_roundtrip_and_no_discovery(self):
        c,cert=self.certificate();root=pathlib.Path('D:/Build/tmp/cx_rva/step9');root.mkdir(parents=True,exist_ok=True)
        with tempfile.TemporaryDirectory(dir=root) as d:
            path=pathlib.Path(d)/'certificate.json';path.write_text(json.dumps(cert));cert=json.loads(path.read_text())
        with patch.object(e.Checker,'check',side_effect=AssertionError('producer called')),patch.object(e,'cfg_variants',side_effect=AssertionError('alignment called')),patch.object(e,'conditional_facts',side_effect=AssertionError('inference called')):
            self.assertTrue(replay.validate(cert,c.inp))
        for name in ('blocks','cfg_variants','conditional_facts','verify_frames'):
            self.assertFalse(hasattr(replay.rules(),name))
        self.assertFalse(hasattr(replay.rules().Checker,'verify'))
    def test_every_route_has_replay(self):
        for route in ROUTES:
            c,f=build('b801000000c3','b801000000c3');force(c,route)
            self.assertTrue(c.check(f)[0].startswith('PROVEN'),(route,c.check(f)))
            self.assertEqual(route,c.last_certificate['recipes'][-1]['route'])
            self.assertTrue(replay.validate(json.loads(json.dumps(c.last_certificate)),c.inp))
    def test_tampering_fails_closed(self):
        c,cert=self.certificate('83ec08c704240100000083c408c3')
        for kind in ('schema','version','image','binding','edge','event','hypothesis','status','root','range','invariant','operand','flow','unknown-route'):
            bad=copy.deepcopy(cert);recipe=bad['recipes'][0]
            if kind=='schema':bad['schema_version']=99
            if kind=='version':bad['versions']['equiv.py']='0'*64
            if kind=='image':bad['images'][0]='0'*64
            if kind=='binding':bad['bindings'].append([0x402000,0x402004,'forged'])
            if kind=='edge':
                x=unpack(recipe['recipe']);body,edges=x['graphs'][0][0];x['graphs'][0][0]=(body,tuple(edges)+(0,));recipe['recipe']=pack(x)
            if kind=='event':bad['event_rules']=[]
            if kind=='hypothesis':bad['hypotheses']['H1']['predicate']='True'
            if kind=='status':bad['hypotheses']['H1']['status']='discharged'
            if kind=='root':bad['roots']=[]
            if kind=='range':recipe['codes'][0].pop()
            if kind=='invariant':
                x=unpack(recipe['recipe']);x['candidates'].clear();recipe['recipe']=pack(x)
            if kind=='operand':recipe['codes'][0][0]['operands'][0]=pack({'reg':0})
            if kind=='flow':recipe['codes'][0][0]['flow']=[0x401000]
            if kind=='unknown-route':recipe['route']='trusted'
            with self.subTest(kind=kind),self.assertRaises((ValueError,KeyError,TypeError,IndexError)):replay.validate(bad,c.inp)
    def test_unknown_and_safety_timeout_reject(self):
        c,cert=self.certificate('83ec0439e17507c704240100000089c883c404c3','83ec0439e17507c704240200000089c883c404c3')
        with patch.object(e.limits,'check',return_value=e.z3.unknown),self.assertRaises((ValueError,e.Unsupported,e.NotProven)):replay.validate(cert,c.inp)
        with patch.object(e.limits,'check',side_effect=e.limits.SafetyCap('solver safety cap')),self.assertRaises(e.limits.SafetyCap):replay.validate(cert,c.inp)
    def test_mutants_are_rejected_or_listed_for_Fable(self):
        rows=adjudicate()
        self.assertEqual(55,len(rows))
        self.assertTrue(all(r['baseline'][0].startswith('PROVEN') for r in rows))
        self.assertTrue(all(r['adjudication']=='rejected' for r in rows if r['kind']!='register-immediate'))
        self.assertTrue(all(r['differing_instruction'] and r['adjudication']=='equivalent: dead volatile-register write' for r in rows if r['status'].startswith('PROVEN')))
    def test_callee_read_mask_and_opaque_downgrade_cannot_be_forged(self):
        from .test_calls import Calls
        c,f=Calls().caller('','','89d8c3');self.assertTrue(c.check(f)[0].startswith('PROVEN'))
        for opaque in (False,True):
            cert=json.loads(json.dumps(c.last_certificate));node=next(n for n in cert['callees'] if unpack(n['fields'])['valid'])
            fields=unpack(node['fields'])
            if opaque:fields['valid']=False;fields['writes']={}
            else:fields['value']=(frozenset(),*fields['value'][1:])
            node['fields']=pack(fields)
            with self.assertRaises(ValueError):replay.validate(cert,c.inp)
        cert=json.loads(json.dumps(c.last_certificate));cert['bindings']=[]
        with self.assertRaises(ValueError):replay.validate(cert,c.inp)
    def test_collapsed_call_havocs_forge3_rejected(self):
        from equiv_certificate import code,refresh
        old='53e8fa00000089c3e8f300000029d85bc3';new='53e8fa00000089c3e8f300000031c05bc3'
        args=dict(extras_a=[(0x1100,bytes.fromhex('b801000000c3'))],extras_b=[(0x1100,bytes.fromhex('b801000000c3'))],bindings=[(0x401100,0x401100)])
        ctl,f=build(old,old,**args);self.assertTrue(ctl.check(f)[0].startswith('PROVEN'));cert=copy.deepcopy(ctl.last_certificate)
        mut,f=build(old,new,**args);self.assertFalse(mut.check(f)[0].startswith('PROVEN'))
        r=cert['recipes'][0];x=unpack(r['recipe']);x['local']=[{0x401001:0x401001,0x401008:0x401001} for _ in (0,1)]
        r['recipe']=pack(x);r['codes'][1]=code(mut.instructions(f)[1]);cert=refresh(cert,lambda ref:{'0':mut.inp.old,'1':mut.inp.new}[ref])
        with self.assertRaisesRegex(ValueError,'forged local site map'):replay.validate(cert,mut.inp)
    def test_forged_cache_cannot_bypass_replay(self):
        from equiv_cache import Cache,packed,digest
        from equiv_certificate import code
        good,f=build('b801000000c3','b801000000c3');good.check(f)
        bad,f=build('b801000000c3','b802000000c3')
        with tempfile.TemporaryDirectory(dir='D:/Build/tmp') as folder:
            bad.cache=Cache(bad,folder);bad.check(f);path=next(pathlib.Path(folder).glob('*.json'));entry=json.loads(path.read_text())
            cert=copy.deepcopy(good.last_certificate);cert['recipes'][0]['codes'][1]=code(bad.instructions(f)[1])
            entry['payload']['result']=['PROVEN under H6','forged'];entry['payload']['certificate']=cert;entry['key']=digest(packed(entry['payload']).encode());path.write_text(json.dumps(entry))
            self.assertEqual('NOT PROVEN',bad.check(f)[0]);self.assertIsNone(bad.cache_hit)
