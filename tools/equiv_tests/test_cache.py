import json,unittest
from pathlib import Path
from types import SimpleNamespace as NS
from unittest.mock import patch
import equiv as e
from equiv_cache import Cache
from .support import build,call,p32,Image
class VerdictCache(unittest.TestCase):
    def setUp(self):
        self.disk={};self.shared=Path('D:/Build/tmp/cx_rva/cache8a/shared.dpl')
        self.dll=Image(''.encode(),[(0x1100,bytes.fromhex('b801000000c3'))]);self.dll.path=str(self.shared)
        self.dll.pe.DIRECTORY_ENTRY_EXPORT=NS(symbols=[NS(name=b'leaf',address=0x1100,forwarder=None)])
        def load(p):
            if str(p) not in self.disk:raise FileNotFoundError(str(p))
            return json.loads(self.disk[str(p)])
        original=Path.is_file
        for item in (patch.object(Path,'mkdir'),patch.object(Cache,'load',staticmethod(load)),
                     patch.object(Cache,'save',staticmethod(lambda p,v:self.disk.__setitem__(str(p),json.dumps(v)))),
                     patch.object(Path,'is_file',lambda p:p==self.shared or original(p)),patch.object(e.match,'Image',return_value=self.dll)):
            item.start();self.addCleanup(item.stop)
    def fixture(self,label):
        body=call(0,0x401200)+b'\xc3' if label in ('A','B') else b'\xc3'
        extra=[(0x1200,b'\xff\x25'+p32(0x402100))]
        c,f=build(body,body,extras_a=extra,extras_b=extra,bindings=[(0x401200,0x401200)])
        c.inp.original_path=self.shared.parent/(label+'.exe')
        if label in ('A','B'):
            for im in (c.inp.old,c.inp.new):im.pe.DIRECTORY_ENTRY_IMPORT=[NS(dll=b'shared.dpl',imports=[NS(address=0x402100,name=b'leaf',ordinal=None)])]
        if label=='C':
            c.inp.old.data[0x1100:0x1106]=self.dll.data[0x1100:0x1106];c.inp.new.data[0x1100:0x1106]=bytes.fromhex('b801000000c3')
            f.ova=f.nva=0x401100;f.osize=f.nsize=6
        f.name=label;c.cache=Cache(c,self.shared.parent/'entries');return c,f
    def run_set(self):
        result={}
        for name in ('A','B','C','independent'):
            c,f=self.fixture(name);v=c.check(f);result[name]=(bool(c.cache_hit),v,json.dumps(c.last_contracts))
        return result
    def test_shared_callee_exact_invalidation_and_zero_solver_replay(self):
        cold=self.run_set();self.assertTrue(all(v[1][0].startswith('PROVEN') for v in cold.values()),cold)
        with patch.object(e.limits,'check',side_effect=AssertionError('warm solver call')):warm=self.run_set()
        self.assertTrue(all(v[0] for v in warm.values()));self.assertEqual({k:v[1:] for k,v in cold.items()},{k:v[1:] for k,v in warm.items()})
        self.dll.pe.DIRECTORY_ENTRY_EXPORT.symbols[0].address=0x1180;self.assertEqual({'A','B'},{k for k,v in self.run_set().items() if not v[0]});self.dll.pe.DIRECTORY_ENTRY_EXPORT.symbols[0].address=0x1100
        self.dll.data[0x1101]=2;changed=self.run_set()
        self.assertEqual({'A','B','C'},{k for k,v in changed.items() if not v[0]})
    def test_corruption_schema_limits_identities_and_version(self):
        self.run_set()
        for kind in ('corrupt','schema','limits','version','alias','map','signature','identity','unconsulted'):
            c,f=self.fixture('A');before=dict(self.disk)
            if kind in ('corrupt','schema'):
                for p,text in list(self.disk.items()):
                    d=json.loads(text);d['schema']=99 if kind=='schema' else d['schema'];d['key']='bad' if kind=='corrupt' else d['key'];self.disk[p]=json.dumps(d)
            if kind=='version':c.cache.version['equiv.py']='changed'
            if kind in ('alias','map','signature'):c.cache.files[kind]='changed'
            if kind=='identity':c.inp.addresses.provenance[0x401200,0x401200]='changed'
            if kind=='unconsulted':c.inp.addresses.forward[0x403000]=0x403004
            with patch.dict(e.limits.RLIMIT,prove=e.limits.RLIMIT['prove']+(kind=='limits')):c.check(f)
            self.assertEqual(kind=='unconsulted',bool(c.cache_hit),kind);self.disk=before
    def test_reviewed_contents_are_dependencies(self):
        for pointer in (False,True):
            c,f=build('a100204000c3','a100204000c3',bindings=[(0x402000,0x402000),(0x402100,0x402100)])
            for side,im in enumerate((c.inp.old,c.inp.new)):
                im.data[0x2000:0x2004]=p32(0x402100)
                if pointer:c.inp.addresses.pointer_cells[side][0x402000]=(0x402100,'reviewed')
                else:c.inp.addresses.immutable_data[side][0x402000]=4
            c.cache=Cache(c,self.shared.parent/str(pointer));self.assertTrue(c.check(f)[0].startswith('PROVEN'))
            c.check(f);self.assertTrue(c.cache_hit);c.inp.old.data[0x2000]^=1;c.check(f);self.assertIsNone(c.cache_hit)
