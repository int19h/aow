"""Version 2 identity recipes (legacy schema 1 remains readable). This is not the step 9 proof validator.

Review authorizes identity only; storage/content/H5 checks remain outstanding.
Certificate records are explicitly incomplete until later steps populate/replay them.
"""
import hashlib
import json

SCHEMA_VERSION = 1  # Incomplete proof certificates and legacy aliases.
ALIAS_SCHEMA_VERSION = 2
HYPOTHESES = tuple('H%d' % n for n in range(1, 10)) + ('H3c',)


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def install_pointer_cells(entry, inp, addresses, names, record):
    """Validate names and immutable cell payloads, never relate cell storage."""
    if entry['extent']['size'] != 4:
        raise ValueError('pointer cell extent must be four bytes')
    points, cells = [], []
    for side, key in enumerate(('original','compiled')):
        endpoint = entry[key]
        name = endpoint['scope'], endpoint['symbol']
        if not all(isinstance(v,str) and v.strip() for v in name) or name in names[side]:
            raise ValueError('ambiguous scoped pointer-cell record')
        names[side].add(name)
        point = endpoint['pointee']
        qualified = point['scope'] + '.' + point['symbol']
        immutable = endpoint['immutability']
        if (immutable['class'] not in ('loader-iat','typed-pointer-constant')
                or not immutable['evidence'] or not all(isinstance(v,str) and v.strip() for v in immutable['evidence'])):
            raise ValueError('missing pointer-cell immutability evidence')
        image = (inp.old,inp.new)[side]
        locations = []
        for cell in endpoint['cells']:
            address = int(cell['address'],16)
            if not any(s.Name.rstrip(b'\0').decode('ascii') == cell['section']
                       and image.base+s.VirtualAddress <= address
                       and address+4 <= image.base+s.VirtualAddress+s.Misc_VirtualSize for s in image.pe.sections):
                raise ValueError('pointer cell outside declared section')
            locations.append(address)
        if not locations or len(locations) != len(set(locations)):
            raise ValueError('empty or duplicate pointer cells')
        if point['via'] == 'iat' and side == 0:
            anchor = ('import',point['dll'].lower(),qualified)
            for address in locations:
                actual = addresses.import_locations[side].get(address)
                if (actual is None or actual[0].decode('latin1') != anchor[1]
                        or actual[1][0] != 'name' or actual[1][1].decode('latin1').split('@')[0] != qualified
                        or immutable['class'] != 'loader-iat'):
                    raise ValueError('pointer-cell IAT pointee mismatch')
        else:
            if point['via'] == 'export' and side == 0:
                found = {image.base+s.address for s in getattr(getattr(image.pe,'DIRECTORY_ENTRY_EXPORT',None),'symbols',[])
                         if s.name and s.name.decode('latin1').split('@')[0] == qualified and not s.forwarder}
                anchor = next(iter(found)) if len(found) == 1 else None
            elif point['via'] == 'map' and side == 1:
                anchor = addresses.map_addresses.get(point['symbol'])
            elif point['via'] == 'reviewed-source' and side == 0 and entry['identity']['class'] == 'reviewed-source':
                anchor = int(point['address'],16)  # Explicit Fable annotation, cell hash checked by schema 2.
            else:
                anchor = None
            if anchor is None or immutable['class'] != 'typed-pointer-constant':
                raise ValueError('unresolved independent pointee name')
            if any(a not in addresses.relocs[side] or addresses.u32(image,a) != anchor for a in locations):
                raise ValueError('pointer-cell payload differs from named pointee')
        points.append(anchor)
        cells.append(locations)
    if entry['original']['pointee']['scope'] != entry['compiled']['pointee']['scope'] or entry['original']['pointee']['symbol'] != entry['compiled']['pointee']['symbol']:
        raise ValueError('different scoped pointee identity')
    if isinstance(points[0],tuple):
        addresses.import_pointee(points[0],points[1],cells[0][0])
    elif not addresses.bind(points[0],points[1],'independent-name'):
        raise ValueError('independent pointee binding conflicts')
    for side in (0,1):
        for cell in cells[side]:
            if any(max(cell,a)<min(cell+4,a+4) and (cell != a or points[side] != target)
                   for a,(target,_) in addresses.pointer_cells[side].items()):
                raise ValueError('incompatible overlapping pointer cells')
            addresses.pointer_cells[side][cell] = points[side], record


def load_aliases(path, inp, addresses, document=None):
    document = json.loads(path.read_text(encoding='utf-8')) if document is None else document
    if document.get('schema_version') == ALIAS_SCHEMA_VERSION:
        from equiv_aliases import load_v2
        return load_v2(path,inp,addresses,document)
    if set(document) != {'schema_version', 'module', 'entries'} or document['schema_version'] != SCHEMA_VERSION:
        raise ValueError('unknown data-alias schema')
    hashes = [digest(p) for p in inp.image_paths]
    if document['module'] != dict(original_sha256=hashes[0], compiled_sha256=hashes[1]):
        raise ValueError('stale data-alias module hashes')
    accepted, ids = [], set()
    names = [set(s) for s in getattr(addresses, 'reviewed_names', (set(),set()))]
    for entry in document['entries']:
        if entry['id'] in ids or not isinstance(entry['id'], str) or not entry['id']:
            raise ValueError('duplicate/invalid alias id')
        ids.add(entry['id'])
        if entry['disposition'] not in ('pending', 'rejected', 'accepted'):
            raise ValueError('invalid review disposition')
        if entry['disposition'] != 'accepted':
            continue
        if entry.get('kind') not in ('mutable-data','immutable-data','bss','import-cell','pointer-cell'):
            raise ValueError('unknown alias storage kind')
        review, identity, extent = entry['review'], entry['identity'], entry['extent']
        if (review['reviewer'] != 'Fable'
                or not all(isinstance(v,str) and v.strip() for v in
                           (review['reason'],entry['origin'],identity['evidence'],extent['evidence']))
                or identity['class'] not in ('scoped-symbol', 'import', 'reviewed-layout', 'reviewed-source')
                or extent['basis'] not in ('type-layout', 'self-describing', 'reviewed-annotation', 'certified-region')):
            raise ValueError('missing or invalid reviewed provenance')
        size = extent['size']
        if type(size) is not int or not 0 < size <= 65536:
            raise ValueError('unknown/invalid reviewed extent')
        if entry['kind'] == 'pointer-cell':
            install_pointer_cells(entry,inp,addresses,names,entry['id'] + ':' + digest(path))
            continue
        pair = []
        for side, key in enumerate(('original', 'compiled')):
            endpoint = entry[key]
            name = endpoint['scope'], endpoint['symbol']
            if not all(isinstance(v, str) and v.strip() for v in name) or name in names[side]:
                raise ValueError('ambiguous scoped data symbol')
            names[side].add(name)
            address = int(endpoint['address'], 16)
            image = (inp.old, inp.new)[side]
            if not any(s.Name.rstrip(b'\0').decode('ascii') == endpoint['section']
                       and image.base+s.VirtualAddress <= address
                       and address+size <= image.base+s.VirtualAddress+s.Misc_VirtualSize for s in image.pe.sections):
                raise ValueError('alias outside declared storage section')
            pair.append(address)
        if identity['class'] in ('scoped-symbol', 'reviewed-layout', 'import'):
            if any(entry['original'][k] != entry['compiled'][k] for k in ('scope', 'symbol')):
                raise ValueError('different DLL/unit/class identity')
        a, b = pair
        if identity['class'] == 'import':
            old, new = (addresses.import_locations[s].get(pair[s]) for s in (0, 1))
            if old is None or old != new or size != 4:
                raise ValueError('import DLL/symbol mismatch')
            symbol = old[1][1].decode('latin1') if old[1][0] == 'name' else '#' + str(old[1][1])
            if entry['original']['scope'].lower() != old[0].decode('latin1') or entry['original']['symbol'] != symbol:
                raise ValueError('incorrect scoped import name')
        for x, y, length, _ in accepted:
            if ((max(a,x) < min(a+size,x+length) or max(b,y) < min(b+size,y+length))
                    and b-a != y-x):
                raise ValueError('overlapping aliases have inconsistent byte offsets')
        if entry['kind'] == 'immutable-data':
            if (inp.old.bytes_at(a,size) != inp.new.bytes_at(b,size)
                    and not (any(a-3 <= r < a+size for r in addresses.relocs[0])
                             or any(b-3 <= r < b+size for r in addresses.relocs[1]))):
                raise ValueError('immutable bytes differ or need relocated-pointer validation')
            for side,start in enumerate((a,b)):
                addresses.immutable_data[side][start] = size
        addresses.storage_objects.append((a,b,size,entry['kind'],extent['basis']+':'+extent['evidence']))
        accepted.append((a, b, size, entry['id'] + ':' + digest(path)))
    addresses.reviewed_names = [set(s) for s in names]  # Persist across every loaded alias file.
    return accepted


def certificate(inputs, function):
    """Schema skeleton, deliberately incapable of claiming a validated proof."""
    return dict(schema_version=SCHEMA_VERSION, stage='incomplete', versions={}, inputs=inputs,
                function=function, decoded_ranges=[], roots=[], cfg_pairing=[], bindings=[],
                storage_ranges=[], hypotheses={h: dict(status='unsupported', predicate=None, evidence=[])
                                              for h in HYPOTHESES},
                callees=[], dependencies=[], invariants=[], frame_relations=[], event_rules=[],
                proof_results=[], diagnostics=[])
