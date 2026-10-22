"""Reviewed identities fail closed before later content/proof validation."""
import copy
import json
from pathlib import Path
import tempfile
import unittest
from equiv_records import certificate, digest, load_aliases
from .support import build


class Records(unittest.TestCase):
    def test_manifest_gate_and_byte_overlap(self):
        checker, _ = build('c3','c3')
        inp = checker.inp
        with tempfile.TemporaryDirectory() as directory:
            paths = tuple(Path(directory)/n for n in ('old','new'))
            for p in paths:
                p.write_bytes(b'fixture')
            inp.image_paths = paths
            endpoint = dict(address='0x402000',scope='fixture.Unit',symbol='global',section='DATA')
            entry = dict(id='a',kind='mutable-data',disposition='pending',origin='MATCH proposal',original=endpoint,
                         compiled=dict(endpoint,address='0x402010'),
                         review=dict(reviewer='Fable',reason='independent source review'),
                         identity=dict(class_='reviewed-source',evidence='fixture source'),
                         extent=dict(size=8,basis='reviewed-annotation',evidence='fixture type'))
            entry['identity']['class'] = entry['identity'].pop('class_')
            doc = dict(schema_version=1,module=dict(original_sha256=digest(paths[0]),compiled_sha256=digest(paths[1])),entries=[entry])
            path = Path(directory)/'aliases.json'
            def load(value):
                inp.addresses.reviewed_names = (set(),set())
                path.write_text(json.dumps(value))
                return load_aliases(path,inp,inp.addresses)
            self.assertEqual([],load(doc))
            entry['disposition'] = 'rejected'
            self.assertEqual([],load(doc))
            entry['disposition'] = 'accepted'
            self.assertEqual((0x402000,0x402010,8),load(doc)[0][:3])
            for change in ('evidence','extent','hash','name','overlap','class','dll'):
                bad = copy.deepcopy(doc)
                e = bad['entries'][0]
                if change == 'evidence': e['identity']['evidence'] = ''
                if change == 'extent': e['extent']['size'] = None
                if change == 'hash': bad['module']['compiled_sha256'] = '0'*64
                if change == 'name':
                    duplicate = copy.deepcopy(e); duplicate['id'] = 'duplicate'
                    bad['entries'].append(duplicate)
                if change == 'overlap':
                    other = copy.deepcopy(e); other['id'] = 'interior'
                    other['original'].update(address='0x402004',symbol='interior')
                    other['compiled'].update(address='0x402012',symbol='interior')
                    bad['entries'].append(other)
                if change in ('class','dll'):
                    e['identity']['class'] = 'reviewed-layout' if change == 'class' else 'import'
                    e['compiled']['scope'] = 'wrong.UnitOrDLL'
                with self.subTest(change=change), self.assertRaises(ValueError): load(bad)
                if change == 'overlap':
                    bad['entries'][1]['compiled']['address'] = '0x402014'
                    self.assertEqual(2,len(load(bad)))
            entry['kind'] = 'immutable-data'
            inp.old.data[0x2000],inp.new.data[0x2010] = 1,2
            with self.assertRaisesRegex(ValueError,'immutable bytes'): load(doc)
            inp.new.data[0x2010] = 1
            self.assertEqual(1,len(load(doc)))
            self.assertTrue(inp.addresses.readonly(1,0x402010,8))
            self.assertFalse(inp.addresses.readonly(1,0x402010,9))

    def test_certificate_is_incomplete_and_names_all_obligations(self):
        record = certificate({}, {'name':'fixture'})
        self.assertEqual('incomplete', record['stage'])
        self.assertEqual({'H%d'%i for i in range(1,10)}|{'H3c'},set(record['hypotheses']))
        self.assertTrue(all(h['status']=='unsupported' for h in record['hypotheses'].values()))
