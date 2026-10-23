"""3c: class references, fresh call results and nominal imported metadata."""
import unittest
from .support import build,p32,call

class ClassReferences(unittest.TestCase):
    def fixture(self,wrong_class=False,load_result=False,parent=False,wrong_parent=False):
        a,b,x,y=0x402000,0x402100,0x402200,0x402300
        def header(base,name):return p32(base+64)+bytes(28)+p32(base+96)+bytes(28)
        old=b'\xb8'+p32(a+64)+call(5)+b'\xc3'
        new=b'\xb8'+p32((y if wrong_class else b)+64)+call(5)+b'\xc3'
        if load_result:
            old=old[:-1]+bytes.fromhex('8b4010c3');new=new[:-1]+bytes.fromhex('8b4010c3')
        extras=lambda v,w:[(0x1100,bytes.fromhex('8b40e4c3')),(v-0x400000,header(v,'First')),
            (v+96-0x400000,b'\x05First'),(w-0x400000,header(w,'Second')),(w+96-0x400000,b'\x06Second')]
        c,f=build(old,new,extras_a=extras(a,x),extras_b=extras(b,y),readonly=True,
            names=[(0x401100,'Fixture.Create')],relocs=([0x401001,a,a+32,x,x+32],[0x401001,b,b+32,y,y+32]))
        d=c.inp.addresses
        d.vmts=[{a+64:'First',x+64:'Second'},{b+64:'First',y+64:'Second'}]
        for side,img in enumerate((c.inp.old,c.inp.new)):
            img.pe.sections[1].Characteristics |= 0x20000000
            for vmt,name in d.vmts[side].items():d.names[side][vmt]='vmt:'+name;d.names[side][vmt-64]='vmtref:'+name
        if parent:
            c.inp.old.data[a-0x400000+40:a-0x400000+44]=p32(0x402800)
            c.inp.new.data[b-0x400000+40:b-0x400000+44]=p32(0x402880)
            c.inp.new.data[0x2880:0x2884]=p32((y if wrong_parent else b)+64)
            d.relocs[0].add(a+40);d.relocs[1].update((b+40,0x402880))
            d.import_locations[0][0x402800]=(b'vcl30.dpl',('name',b'Forms.First@fixture'))
            d.import_bytes[0].update(range(0x402800,0x402804))
        d.install_content()
        return c,f
    def test_class_data_constructor_and_mutant(self):
        c,f=self.fixture();self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
        c,f=self.fixture(wrong_class=True);self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_call_results_have_no_image_origins(self):
        c,f=self.fixture(load_result=True);self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
        for side in (0,1):self.assertFalse(c.image_relation.seeds[side][0x40100a].get('eax'))
    def test_imported_parent_pointee_without_cell_identity(self):
        c,f=self.fixture(parent=True);self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
        self.assertNotIn(0x402800,c.inp.addresses.forward);self.assertNotIn(0x402880,c.inp.addresses.reverse)
        c,f=self.fixture(parent=True,wrong_parent=True)
        self.assertIn('metadata pointee differs',c.check(f)[1])
    def test_cell_address_is_not_folded_to_pointee(self):
        c,f=self.fixture(parent=True)
        for img,address in ((c.inp.old,0x402028),(c.inp.new,0x402128)):
            img.data[0x1000:0x1006]=b'\xa1'+p32(address)+b'\xc3'
        self.assertIn('pointee identity does not pair storage',c.check(f)[1])
    def test_cache_records_anonymous_cell_pointee_anchor(self):
        import tempfile
        from equiv_cache import Cache
        c,f=self.fixture(parent=True);d=c.inp.addresses
        d.import_locations[0][0x402800]=(b'vcl30.dpl',('name',b'Forms.External@fixture'))
        c.inp.new.data[0x2880:0x2884]=p32(0x402640)
        c.inp.new.data[0x2600:0x2640]=p32(0x402640)+bytes(28)+p32(0x402660)+bytes(28)
        c.inp.new.data[0x2660:0x2669]=b'\x08External'
        d.vmts[1][0x402640]='External';d.names[1][0x402640]='vmt:External'
        d.names[1][0x402600]='vmtref:External';d.relocs[1].update((0x402600,0x402620))
        with tempfile.TemporaryDirectory(dir=r'D:\Build\tmp') as directory:
            c.cache=Cache(c,directory)
            self.assertTrue(c.check(f)[0].startswith('PROVEN'));self.assertIsNone(c.cache_hit)
            self.assertTrue(c.check(f)[0].startswith('PROVEN'));self.assertTrue(c.cache_hit)
            self.assertTrue(any(b==0x402640 and 'pointee-anchor' in p for a,b,p in d.consulted))
            del d.vmts[1][0x402640];del d.names[1][0x402640];del d.names[1][0x402600]
            self.assertEqual('UNSUPPORTED',c.check(f)[0]);self.assertIsNone(c.cache_hit)
