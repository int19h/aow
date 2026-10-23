import unittest
from .support import build,p32
from equiv_metadata import extent

class Metadata(unittest.TestCase):
    def fixture(self,index=7,target=0x401100):
        a,b=0x402000,0x402100;ta,tb=a+128,b+128
        header=lambda v,t:p32(v+64)+bytes(24)+p32(t)+p32(v+96)+bytes(28)
        c,f=build(b'\xa1'+p32(a+28)+b'\xc3',b'\xa1'+p32(b+28)+b'\xc3',readonly=True,
            extras_a=[(a-0x400000,header(a,ta)),(a+96-0x400000,b'\x07Fixture'),(ta-0x400000,b'\x01\x00\x07\x00'+p32(0x401100))],
            extras_b=[(b-0x400000,header(b,tb)),(b+96-0x400000,b'\x07Fixture'),(tb-0x400000,b'\x01\x00'+index.to_bytes(2,'little')+p32(target))],
            names=[(0x401100,'Fixture.Method'),(0x401104,'Fixture.Other')],bindings=[(a,b),(a+28,b+28),(0x401100,0x401100)],relocs=([a,a+28,a+32,ta+4],[b,b+28,b+32,tb+4]))
        for img in (c.inp.old,c.inp.new):img.pe.sections[1].Characteristics |= 0x20000000
        d=c.inp.addresses;d.vmts=[{a+64:'Fixture'},{b+64:'Fixture'}]
        d.names[0][a+64]=d.names[1][b+64]='vmt:Fixture'
        d.install_content()
        return c,f
    def test_dynamic_content_and_mutation(self):
        c,f=self.fixture();self.assertTrue(c.check(f)[0].startswith('PROVEN'),c.check(f))
        c,f=self.fixture(8);self.assertIn('initialized byte differs',c.check(f)[1])
    def test_wrong_method_target(self):
        c,f=self.fixture(target=0x401104)
        self.assertIn('pointer target differs',c.check(f)[1])
    def test_direct_table_requires_valid_header(self):
        c,f=self.fixture()
        for img,address in ((c.inp.old,0x402080),(c.inp.new,0x402180)):img.data[0x1001:0x1005]=p32(address)
        c.inp.new.data[0x2100+36]=1
        self.assertIn('initialized byte differs',c.check(f)[1])
    def test_nil_and_layouts(self):
        c,f=self.fixture();img=c.inp.old
        for data,kind,n in [(b'\0\0','dynamic',2),(b'\0\0','method',2),(bytes(6),'field',6),
                (p32(0),'interface',4),(b'\x0e\0'+p32(4)+p32(0),'init',10)]:
            img.data[0x2300:0x2300+len(data)]=data
            self.assertEqual(n,extent(img,0x402300,kind))
        img.data[0x2300:0x2302]=b'\xff\xff'
        with self.assertRaises(ValueError):extent(img,0x402300,'dynamic')
