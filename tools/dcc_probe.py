"""Compile a Delphi 3 unit/body on a scratch drive and print named routines.

Example (body contains interface ... implementation ... end.):
  python tools/dcc_probe.py D:\\Build\\tmp\\forms.pas --out D:\\Build\\tmp\\probe A B
  python tools/dcc_probe.py forms.pas --out D:\\Build\\tmp\\probe --switch O- A B
The package is compiled, never loaded or executed. Full units are accepted too.
"""
import argparse
from pathlib import Path
import re
import subprocess
import sys

sys.dont_write_bytecode = True
import match
from match_flow import graph


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('source', type=Path)
    p.add_argument('routines', nargs='*', help='map names; nested: Name<Owner')
    p.add_argument('--out', required=True, type=Path)
    p.add_argument('--switch', action='append', default=[], metavar='O-')
    p.add_argument('--dcc', default=r'C:\Tools\Delphi3\BIN\DCC32.EXE')
    p.add_argument('--unit-path', action='append', default=[])
    a, extra = p.parse_known_args()
    if any(x.startswith('-') for x in extra):
        p.error('unknown options: ' + ' '.join(extra))
    a.routines += extra
    out = a.out.resolve()
    if out.drive.upper() == 'C:':
        p.error('build output must be outside C:')
    out.mkdir(parents=True, exist_ok=True)
    source = a.source.read_text(encoding='utf-8-sig')
    unit = re.search(r'^\s*unit\s+(\w+)\s*;', source, re.I | re.M)
    name = unit.group(1) if unit else 'Probe'
    if not unit:
        source = 'unit Probe;\n' + source
    switches = ['O+', 'W-', 'B-', 'G+', 'A+', 'R-', 'Q-', 'D+', 'L+'] + a.switch
    if any(not re.fullmatch(r'[A-Za-z](?:[+-]|[124])', s) for s in switches):
        p.error('switches must look like O-, Q+, or Z1')
    # DCC32's numeric -$Z arguments can corrupt enum sizes; source directives work.
    numeric = [s for s in switches if s[1:].isdigit()]
    if any(s[0].upper() != 'Z' for s in numeric):
        p.error('only Z accepts a numeric switch')
    unit_end = re.search(r'^\s*unit\s+\w+\s*;', source, re.I | re.M).end()
    if numeric:
        source = source[:unit_end] + '\n' + ''.join('{$' + s + '}\n' for s in numeric) + source[unit_end:]
    (out / (name + '.pas')).write_bytes(source.replace('\r\n', '\n').replace('\n', '\r\n').encode('latin1'))
    package = 'ProbeHost'
    if name.lower() == package.lower():
        p.error('ProbeHost is reserved for the generated package')
    (out / (package + '.dpk')).write_text(
        'package ProbeHost;\nrequires vcl30;\ncontains ' + name + ';\nend.\n', encoding='ascii')
    lib = str(Path(a.dcc).resolve().parent.parent / 'LIB')
    cmd = [a.dcc, '-B', '-GD', '-E' + str(out), '-N' + str(out),
           '-LE' + str(out), '-LN' + str(out), '-U' + ';'.join([lib] + [str(Path(v).resolve()) for v in a.unit_path]),
           '-R' + lib, '-O' + lib] + ['-$' + s for s in switches if s not in numeric] + [package + '.dpk']
    run = subprocess.run(cmd, cwd=out, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    log = run.stdout.decode('latin1')
    (out / 'compile.log').write_text(log, encoding='utf-8')
    if run.returncode or 'Error:' in log or 'Fatal:' in log:
        sys.exit(log)
    print('Switches: ' + ' '.join(switches) + ' (default Z1); source directives may override these')
    img = match.Image(str(out / (package + '.dpl')))
    syms, _ = match.map_symbols(out / (package + '.map'))
    text = img.base + img.pe.sections[0].VirtualAddress
    addresses = {text + off: n for n, locs in syms.items() for seg, off in locs if seg == '0001'}
    # Package RTL calls go through import thunks, absent from map publics.
    match.parse_imports_once(img)
    for entry in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
        for imp in entry.imports:
            if imp.name:
                symbol = imp.name.decode().split('@')
                symbol = '@'.join(symbol[:-1])
                thunk = match.find_import_thunk(img, symbol)
                if thunk:
                    addresses[thunk] = symbol
    handler = next((addr for addr, n in addresses.items() if n.endswith('@HandleOnException')), None)
    md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
    md.detail = True
    names = a.routines or sorted(n for n, locs in syms.items()
                                if any(s == '0001' for s, _ in locs) and not n.startswith(('@', 'System.')))
    missing = False
    for routine in names:
        loc = match.resolve(syms, routine)
        if not loc or loc[0] != '0001':
            print(routine + ': not in code map (declare it in interface; keep L+)')
            missing = True
            continue
        start = text + loc[1]
        end = min((v for v in addresses if v > start), default=start + 1024)
        print('\n' + routine + ':')
        stream = match.decode_stream(md, img, start, end - start, handler)
        helpers = {v: n.split('.')[-1] for v, n in addresses.items() if n.split('.')[-1].startswith('@')}
        reached, _, problems, _, _ = graph(stream, start, end - start, img, helpers)
        if problems:
            print('  [flow incomplete: ' + repr(problems) + ']')
            reached = {ins.address for _, ins in stream if ins is not None}
        for norm, ins in stream:
            if ins is None:
                print('       ' + ' '.join(norm))
                continue
            if ins.address not in reached:
                continue
            op = ins.op_str
            def label(m):
                addr = int(m.group(), 16)
                if start <= addr < end:
                    return 'L%04x' % (addr - start)
                return addresses.get(addr, m.group())
            op = re.sub(r'0x[0-9a-f]+', label, op)
            print('  %04x %-8s %s' % (ins.address - start, ins.mnemonic, op))
    if missing:
        sys.exit(1)


if __name__ == '__main__':
    main()
