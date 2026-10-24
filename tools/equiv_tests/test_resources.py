"""Hand-authored RT_STRING directories and descriptors; no game bytes."""
import struct
import unittest
from unittest.mock import patch
from types import SimpleNamespace as NS
import equiv_resources as resources
from .support import build,p32,call


def table(image,identifier,value):
    data=bytearray(128)
    for offset,key,target in ((0,6,24),(24,(identifier>>4)+1,48),(48,1033,72)):
        struct.pack_into('<HHII',data,offset+12,0,1,key,target|(0x80000000 if offset<48 else 0))
    block=b''.join(struct.pack('<H',len(value)//2)+value if i==identifier&15 else b'\0\0' for i in range(16))
    struct.pack_into('<IIII',data,72,0x3100,len(block),1200,0)
    image.data[0x3000:0x3080]=data;image.data[0x3100:0x3100+len(block)]=block
    image.pe.OPTIONAL_HEADER=NS(DATA_DIRECTORY=[None,None,NS(VirtualAddress=0x3000,Size=1024)])


def fixture(value='same',missing=False,writer=False,raw=False):
    a,b=0x402000,0x402010
    code=lambda p: b'\xb8'+p32(p)+(b'\x8b\x40\x04' if raw else call(5))+b'\xc3'
    c,f=build(code(a),code(b),extras_a=[(0x2000,p32(0x402080)+p32(21)),(0x1100,b'\xc3')],
              extras_b=[(0x2010,p32(0x402090)+p32(47)),(0x1100,b'\xc3')],
              relocs=([0x401001,a],[0x401001,b]),bindings=[(a,b),(0x402080,0x402090),(0x401100,0x401100)],
              names=[(0x401100,'System.LoadResString')])
    d=c.inp.addresses;d.storage_objects=[(a,b,8,'immutable-data','Delphi resourcestring record')]
    table(d.old,21,'same'.encode('utf-16le'));table(d.new,48 if missing else 47,value.encode('utf-16le'))
    if writer:d.new.data[0x1200:0x120a]=b'\xc7\x05'+p32(b+4)+p32(99)
    return c,f


class Resources(unittest.TestCase):
    def test_equal_text_different_ids(self):
        c,f=fixture();result=c.check(f);self.assertTrue(result[0].startswith('PROVEN'),result)
    def test_different_text(self):
        c,f=fixture('different');self.assertIn('RT_STRING text differs',c.check(f)[1])
    def test_unresolved_id(self):
        c,f=fixture(missing=True);self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_id_write_in_unselected_function(self):
        c,f=fixture(writer=True);self.assertIn('resourcestring record written',c.check(f)[1])
    def test_numeric_id_observation_rejected(self):
        c,f=fixture(raw=True);self.assertFalse(c.check(f)[0].startswith('PROVEN'))
    def test_indirect_id_write_outside_selection(self):
        for prefix in (b'\xb8',b'\x8d\x05'):
            c,f=fixture();data=prefix+p32(0x402014)+b'\xc7\x00'+p32(99)+b'\xc3'
            c.inp.new.data[0x1200:0x1200+len(data)]=data
            self.assertIn('resourcestring record written',c.check(f)[1])
    def test_malformed_table(self):
        c,f=fixture();c.inp.new.data[0x3100:0x3102]=b'\xff\xff'
        self.assertIn('truncated RT_STRING',c.check(f)[1])
    def test_published_descriptor_outside_selection_rejected(self):
        c,f=fixture();data=b'\xb8'+p32(0x402010)+b'\xa3'+p32(0x402100)+call(10,0x401100)+b'\xc3'
        c.inp.new.data[0x1200:0x1200+len(data)]=data
        self.assertIn('resourcestring pointer has unchecked use',c.check(f)[1])
    def test_language_difference_rejected(self):
        c,f=fixture();struct.pack_into('<I',c.inp.new.data,0x3000+64,1031)
        self.assertIn('RT_STRING text differs',c.check(f)[1])
    def test_loader_argument_must_be_record_base(self):
        c,f=fixture();d=c.inp.addresses;d.bind(0x402004,0x402014)
        c.inp.old.data[0x1001:0x1005]=p32(0x402004)
        c.inp.new.data[0x1001:0x1005]=p32(0x402014)
        # Isolate the call-bound check from the independent module-use audit.
        with patch('equiv_resources.write_witness',return_value=None):
            self.assertIn('descriptor argument is not a validated record base',c.check(f)[1])
