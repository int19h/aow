"""Schema 2 movement, ambiguity and pending-entry isolation."""
import hashlib,json,tempfile,unittest
from pathlib import Path
from equiv_records import load_aliases,digest
from . import test_pointer_cells as fixtures
from .support import p32
class AliasesV2(unittest.TestCase):
    def fixture(self,two=False):
        checker,_,entry=fixtures.PointerCells().fixture();inp=checker.inp;a=inp.addresses
        entry['original']['cells'][0]['content_sha256']=hashlib.sha256(inp.old.bytes_at(0x402000,4)).hexdigest()
        entry['compiled']['cells']=[dict(section='DATA',pointee_symbol='Value',function_symbol='CellReader',occurrence=0)]
        body=b'\xa1'+p32(0x402020)+(b'\x8b\x15'+p32(0x402030) if two else b'')+b'\xc3'
        inp.new.data[0x1020:0x1020+len(body)]=body;inp.new.data[0x2020:0x2024]=p32(0x402120)
        inp.new.data[0x2030:0x2034]=p32(0x402120);a.relocs[1].update((0x402020,0x402030))
        inp.syms['CellReader']=[('0001',32)];inp.code_offsets=[32,32+len(body)];a.map_addresses['CellReader']=0x401020
        return checker,entry
    def load(self,checker,entry):
        with tempfile.TemporaryDirectory() as temp:
            inp=checker.inp;inp.image_paths=tuple(Path(temp)/n for n in ('old','new'))
            for p in inp.image_paths:p.write_bytes(b'fixture')
            doc=dict(schema_version=2,module=dict(original_sha256=digest(inp.image_paths[0])),entries=[entry])
            path=Path(temp)/'aliases.json';path.write_text(json.dumps(doc))
            return load_aliases(path,inp,inp.addresses)
    def test_cell_moves_16_function_moves_32(self):
        checker,entry=self.fixture();self.load(checker,entry)
        self.assertIn(0x402020,checker.inp.addresses.pointer_cells[1])
        self.assertNotIn(0x402010,checker.inp.addresses.pointer_cells[1])
        self.assertEqual('accepted',checker.inp.addresses.alias_resolutions[0]['status'])
    def test_two_candidate_cells_are_pending_without_partial_bindings(self):
        checker,entry=self.fixture(True);self.assertEqual([],self.load(checker,entry))
        self.assertEqual({},checker.inp.addresses.pointer_cells[1])
        result=checker.inp.addresses.alias_resolutions[0]
        self.assertEqual('pending',result['status']);self.assertIn('got 2',result['reason'])
    def test_original_content_mismatch_is_pending(self):
        checker,entry=self.fixture();entry['original']['cells'][0]['content_sha256']='0'*64
        self.assertEqual([],self.load(checker,entry));self.assertIn('content hash',checker.inp.addresses.alias_resolutions[0]['reason'])
