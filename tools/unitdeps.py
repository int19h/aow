"""Count direct, named call sites between units; usage: unitdeps.py signatures.json decomp-dir.

Comments, literals and function headers are excluded. Indirect/VMT calls are not
resolved. Hashes and Ghidra's C identifier spelling are accepted. Anonymous and
class-only symbols inherit the preceding named unit in address order; leading
helpers belong to the module. A sibling symbols/<module>.units.txt, if present,
provides the full unit inventory and class owners (including zero-code units).
"""
import collections
import json
import re
import sys
from pathlib import Path


def identifier(name):
    return re.sub(r'[^a-zA-Z0-9_]', '_', name)


def analyze(signatures, directory):
    path = Path(signatures)
    functions = sorted(json.loads(path.read_text()), key=lambda f: int(f['addr'], 16))
    module = path.stem.split('.')[0]
    inventory = path.parent.parent / 'symbols' / (path.stem + '.units.txt')
    units, classes = set(), {}
    if inventory.exists():
        unit = None
        for line in inventory.read_text().splitlines():
            if line.startswith('== '):
                unit = line.split()[1]
                units.add(unit)
            match = re.match(r'   (\w+) \(\d+\):', line)
            if match and unit:
                classes[match[1]] = unit
    for f in functions:
        parts = f['name'].split('@')[0].split('.')
        if len(parts) >= 3 and parts[0]:
            units.add(parts[0])
            classes[parts[1]] = parts[0]
    for f in functions:
        parts = f['name'].split('@')[0].split('.')
        if (not inventory.exists() and len(parts) == 2
                and parts[0] not in classes and not re.match(r'T[A-Z]', parts[0])):
            units.add(parts[0])
    owners, previous = [], module
    for f in functions:
        prefix = f['name'].split('.')[0]
        owner = prefix if prefix in units else classes.get(prefix)
        if owner:
            previous = owner
        owners.append(owner or previous)
    units.update(owners)
    aliases = collections.defaultdict(set)
    for i, f in enumerate(functions):
        for name in (f['name'], f['name'].split('@')[0], 'FUN_' + f['addr']):
            aliases[identifier(name)].add(i)
    files = {}
    for file in Path(directory).glob('*.c'):
        address = file.name.split('_', 1)[0].lower()
        if re.fullmatch(r'[0-9a-f]+', address):
            if address in files:
                raise ValueError('Duplicate decompile address: ' + address)
            files[address] = file
    matrix = {unit: collections.Counter() for unit in sorted(units)}
    totals = {unit: [0, 0] for unit in sorted(units)}
    edges = collections.Counter()
    strip = re.compile(r'/\*.*?\*/|//[^\n]*|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'', re.S)
    calls = re.compile(r'\b([a-zA-Z_][a-zA-Z0-9_]*)\s*\(')
    for i, f in enumerate(functions):
        unit = owners[i]
        totals[unit][0] += 1
        totals[unit][1] += f['size']
        file = files.get(f['addr'].lower())
        if file is None:
            raise ValueError('Missing decompile: ' + f['addr'])
        body = strip.sub(' ', file.read_text(encoding='utf-8', errors='replace'))
        body = body.partition('{')[2]
        for name in calls.findall(body):
            targets = aliases.get(name, ())
            if len(targets) != 1:
                continue
            j = next(iter(targets))
            edges[i, j] += 1
            if unit != owners[j]:
                matrix[unit][owners[j]] += 1
    return functions, owners, matrix, totals, edges


def main():
    if len(sys.argv) != 3:
        raise SystemExit('Usage: unitdeps.py signatures.json decomp-dir')
    functions, owners, matrix, totals, edges = analyze(*sys.argv[1:])
    units = list(matrix)
    width = max(5, max(map(len, units)))
    print('Caller'.ljust(width) + ' ' + ' '.join(u.rjust(width) for u in units))
    for unit in units:
        print(unit.ljust(width) + ' ' + ' '.join(str(matrix[unit][v]).rjust(width) for v in units))
    print('\nUnit functions code_bytes')
    for unit, (count, size) in totals.items():
        print(unit, count, size)
    print('TOTAL', len(functions), sum(f['size'] for f in functions))


if __name__ == '__main__':
    main()
