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
    def test_named_cell_disambiguates_only_the_reviewed_operand(self):
        checker,entry=self.fixture(True);checker.inp.addresses.map_addresses['NamedCell']=0x402020
        entry['compiled']['cells'][0]['cell_symbol']='NamedCell';self.load(checker,entry)
        self.assertIn(0x402020,checker.inp.addresses.pointer_cells[1])
        checker,entry=self.fixture(True);checker.inp.addresses.map_addresses['NamedCell']=0x402030
        entry['compiled']['cells'][0]['cell_symbol']='NamedCell';self.assertEqual([],self.load(checker,entry))
    def test_scoped_named_cell_does_not_guess_between_duplicate_map_names(self):
        checker,entry=self.fixture(True);inp=checker.inp
        inp.syms['SameCell']=[('0002',0x20),('0002',0x30)]
        entry['compiled']['cells'][0].update(cell_symbol='SameCell',cell_scope='FirstUnit')
        with tempfile.TemporaryDirectory() as temp:
            inp.map_path=Path(temp)/'fixture.map'
            inp.map_path.write_text(' 0002:00000020 00000010 C=DATA S=DATA G=DGROUP M=FirstUnit\n 0002:00000030 00000010 C=DATA S=DATA G=DGROUP M=OtherUnit\n')
            self.load(checker,entry)
        self.assertIn(0x402020,inp.addresses.pointer_cells[1]);self.assertNotIn(0x402030,inp.addresses.pointer_cells[1])
    def test_reviewed_source_pointee_requires_reviewed_identity(self):
        checker,entry=self.fixture();entry['identity']['class']='reviewed-source'
        entry['original']['pointee'].update(via='reviewed-source',address='0x402100')
        self.load(checker,entry);self.assertIn(0x402020,checker.inp.addresses.pointer_cells[1])
        checker,other=self.fixture();other['original']['pointee'].update(via='reviewed-source',address='0x402100')
        self.assertEqual([],self.load(checker,other))
    def test_anonymous_literal_recipe_checks_bytes_and_moves(self):
        checker,_=self.fixture();inp=checker.inp
        entry=dict(id='literal',kind='immutable-data',disposition='accepted',origin='reviewed typed operand',
            identity={'class':'reviewed-source','evidence':'typed literal'},review=dict(reviewer='Fable',reason='R-D'),
            extent=dict(size=4,basis='type-layout',evidence='fixture dword'),
            original=dict(address='0x402004',section='DATA',scope='literal',symbol='old',content_sha256=hashlib.sha256(bytes(4)).hexdigest()),
            compiled=dict(section='DATA',scope='literal',symbol='new',function_symbol='CellReader',operand_occurrence=0,content_sha256=hashlib.sha256(bytes(4)).hexdigest()))
        inp.new.data[0x1021:0x1025]=p32(0x402024)
        self.assertEqual(1,len(self.load(checker,entry)))
        checker,_=self.fixture();checker.inp.new.data[0x1021:0x1025]=p32(0x402024)
        checker.inp.new.data[0x2024]=1
        self.assertEqual([],self.load(checker,entry))
