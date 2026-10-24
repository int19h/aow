"""Reviewed pointer cells denote pointees, never equal cell storage."""
import json
from pathlib import Path
import tempfile
from types import SimpleNamespace as NS
import unittest
import equiv as e
from equiv_records import digest,load_aliases
from .support import build,p32


class PointerCells(unittest.TestCase):
    def fixture(self, tail=b'', bad=False):
        a = b'\xa1'+p32(0x402000)+tail+b'\xc3'
        b = b'\xa1'+p32(0x402010)+tail+b'\xc3'
        checker,fn = build(a,b,extras_a=[(0x2000,p32(0x402100))],
                           extras_b=[(0x2010,p32(0x402124 if bad else 0x402120))],
                           relocs=([0x402000],[0x402010]))
        inp = checker.inp
        inp.old.pe.DIRECTORY_ENTRY_EXPORT = NS(symbols=[NS(name=b'Fixture.Value@123',address=0x2100,forwarder=None)])
        inp.addresses.map_addresses['Value'] = 0x402120
        def endpoint(cell,via):
            return dict(scope='Fixture.Cells',symbol=hex(cell),cells=[dict(address=hex(cell),section='DATA')],
                        pointee=dict(scope='Fixture',symbol='Value',via=via),
                        immutability=dict(class_='typed-pointer-constant',evidence=['reviewed fixture declaration']))
        original,compiled = endpoint(0x402000,'export'),endpoint(0x402010,'map')
        for v in (original,compiled):v['immutability']['class']=v['immutability'].pop('class_')
        entry = dict(id='cell',kind='pointer-cell',disposition='accepted',origin='fixture',
                     original=original,compiled=compiled,identity={'class':'scoped-symbol','evidence':'export and MAP'},
                     extent=dict(size=4,basis='type-layout',evidence='32-bit pointer'),
                     review=dict(reviewer='Fable',reason='fixture evidence'))
        return checker,fn,entry

    def install(self,checker,entries):
        with tempfile.TemporaryDirectory() as directory:
            paths = tuple(Path(directory)/n for n in ('old','new'))
            for p in paths:p.write_bytes(b'fixture')
            inp = checker.inp
            inp.image_paths = paths
            doc = dict(schema_version=1,module=dict(original_sha256=digest(paths[0]),compiled_sha256=digest(paths[1])),entries=entries)
            path = Path(directory)/'cells.json';path.write_text(json.dumps(doc))
            self.assertEqual([],load_aliases(path,inp,inp.addresses))

    def test_folded_pointer_cell_proves_without_cell_binding(self):
        checker,fn,entry = self.fixture()
        # A second compiled cell may point at the very same independently named global.
        checker.inp.new.data[0x2020:0x2024] = p32(0x402120)
        checker.inp.addresses.relocs[1].add(0x402020)
        entry['compiled']['cells'].append(dict(address='0x402020',section='DATA'))
        self.install(checker,[entry])
        self.assertNotIn(0x402000,checker.inp.addresses.forward)
        self.assertEqual('PROVEN under H6',checker.check(fn)[0])
        self.assertEqual(2,len(checker.inp.addresses.pointer_cells[1]))

    def test_wrong_named_pointee_rejects(self):
        checker,fn,entry = self.fixture(bad=True)
        with self.assertRaisesRegex(ValueError,'pointee'):self.install(checker,[entry])

    def test_iat_uses_loader_symbol_not_disk_rva(self):
        checker,fn,entry = self.fixture()
        checker.inp.old.data[0x2000:0x2004] = p32(0x1234)
        checker.inp.addresses.import_locations[0][0x402000] = (b'fixture.dpl',('name',b'Fixture.Value@123'))
        entry['original']['pointee'].update(via='iat',dll='fixture.dpl')
        entry['original']['immutability']['class'] = 'loader-iat'
        self.install(checker,[entry])
        self.assertNotIn(0x402000,checker.inp.addresses.forward)
        self.assertEqual('PROVEN under H6',checker.check(fn)[0])

    def test_any_cell_write_even_unreachable_or_aliased_is_unsupported(self):
        for tail in (b'\xc3\xa3'+p32(0x402000), bytes.fromhex('8901')):
            checker,fn,entry = self.fixture(tail)
            if tail[0] == 0xc3:
                checker.inp.new.data[0x1000:0x1000+fn.nsize] = b'\xa1'+p32(0x402010)+b'\xc3\xa3'+p32(0x402010)+b'\xc3'
            self.install(checker,[entry])
            status,reason = checker.check(fn)
            self.assertEqual('UNSUPPORTED' if tail[0] == 0xc3 else 'PROVEN under H5,H6',status)
            if tail[0] == 0xc3: self.assertIn('pointer cell',reason)
            else: self.assertIn('H5',checker.last_contracts['hypotheses'])

    def test_reviewed_names_accumulate_across_files(self):
        checker,fn,entry = self.fixture()
        self.install(checker,[entry])
        with self.assertRaisesRegex(ValueError,'ambiguous'):self.install(checker,[entry])
