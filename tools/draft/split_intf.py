import re
import subprocess
from pathlib import Path

root = Path(__file__).resolve().parents[2]
unit = root / 'src/delphi3/AoWEPACK/AoWE.pas'
inc = unit.parent / 'inc'
original = subprocess.check_output(['git', 'show', 'HEAD:src/delphi3/AoWEPACK/AoWE.pas'], cwd=root).decode('cp1252')
original = original.replace('\r\n', '\n').replace('\n', '\r\n')
start, end = original.index('\r\ntype\r\n') + 2, original.index('implementation\r\n')
body = original[start:end]
owners, methods = {}, {}
for n in range(1, 6):
    methods[n] = set(re.findall(r'^(?:class )?(?:procedure|function|constructor|destructor) (\w+)\.', (inc / f'P{n}.inc').read_text(), re.M | re.I))
    for name in methods[n]:
        assert name not in owners, name
        owners[name] = n
blocks = list(re.finditer(r'^  \{ (\w+) [^\r\n]*\}\r\n  \1 = class(?:\([^\r\n]*\))?\r\n.*?^  end;\r\n', body, re.M | re.S))
assert len(blocks) == len(re.findall(r'^  \w+ = class(?:\(|\r?$)', body, re.M))
runs, pos, previous = [], 0, 1
classes = {n: set() for n in range(1, 6)}
def append(owner, text):
    if text and runs and runs[-1][0] == owner:
        runs[-1][1] += text
    elif text:
        runs.append([owner, text])
for block in blocks:
    append(previous, body[pos:block.start()])
    previous = owners.get(block[1], previous)
    classes[previous].add(block[1])
    append(previous, block[0])
    pos = block.end()
append(previous, body[pos:])
assert ''.join(text for _, text in runs) == body
def write(path, text):
    with open(path, 'w', encoding='cp1252', newline='') as f:
        f.write(text)
counts, files = {n: 0 for n in range(1, 6)}, []
for n, text in runs:
    counts[n] += 1
    name = f'intf_P{n}_{counts[n]:02}.inc'
    write(inc / name, f'{{ Interface declaration run owned by P{n}. }}\r\n' + text)
    files.append(name)
for name in ['types.inc'] + [f'intf_P{n}.inc' for n in range(1, 6)]:
    (inc / name).unlink(missing_ok=True)
write(unit, original[:start] + ''.join('{$I inc\\' + name + '}\r\n' for name in files) + '\r\n' + original[end:])
host = unit.parent / 'matchtest.dpr'
text = host.read_bytes().decode('cp1252')
text = re.sub(r'^  \{ per-package host additions:.*?\}\r?$', r'  { per-package host additions: one include line per package (hosts\\Pkg.inc), nothing else here }\r', text, flags=re.M)
write(host, text)
old = sorted(line for line in body.splitlines() if line.strip())
new = sorted(line for name in files for line in (inc / name).read_text(encoding='cp1252').splitlines()[1:] if line.strip())
assert old == new
print(f'Nonblank line counts: {len(old)} original, {len(new)} split; original order identical')
for n in counts:
    assert methods[n] <= classes[n]
    print(f'P{n}: {len(classes[n])} classes ({len(methods[n])} implemented), {counts[n]} runs')
