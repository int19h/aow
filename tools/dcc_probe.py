"""Compile a Delphi 3 unit body and print named routines; never runs the package.

Example: python -B tools/dcc_probe.py body.pas --out D:\\Build\\tmp\\probe \
    --switch O- -- TThing.Run Helper
The body contains interface ... implementation ... end. (a full unit also works).
Each output directory is disposable: ProbeHost.* and the copied unit are replaced.
"""
import argparse
from bisect import bisect_right
from pathlib import Path
import os
import re
import subprocess
import sys

sys.dont_write_bytecode = True
import match
from match_flow import graph

# DCC3's numeric CLI Z1 corrupts enum size; Z- matches valid source {$Z1}.
DEFAULTS = 'O+ W- B- G+ A+ R- Q- Z- L+'.split()


def build(source, out, switches=(), compiler=r'C:\Tools\Delphi3\BIN\DCC32.EXE'):
    source, out = Path(source).resolve(), Path(out).resolve()
    if source.parent == out:
        raise ValueError('keep the input outside the generated output directory')
    out.mkdir(parents=True, exist_ok=True)
    body = source.read_text(encoding='utf-8-sig')
    unit = re.search(r'(?im)^\s*unit\s+(\w+)\s*;', body)
    name = unit.group(1) if unit else 'ProbeUnit'
    if name.lower() == 'probehost':
        raise ValueError('ProbeHost is reserved for the generated package')
    if not unit:
        body = 'unit ProbeUnit;\n' + body
    (out / (name + '.pas')).write_text(body, encoding='ascii', newline='\r\n')
    host = 'package ProbeHost;\nrequires vcl30;\ncontains %s;\nend.\n' % name
    (out / 'ProbeHost.dpk').write_text(host, encoding='ascii', newline='\r\n')
    lib = Path(compiler).parent.parent / 'LIB'
    cmd = [compiler, '-B', '-GD', '-E' + str(out), '-N' + str(out),
           '-LE' + str(out), '-LN' + str(out), '-U' + str(lib),
           '-I' + str(source.parent), '-R' + str(lib), '-O' + str(lib)]
    cmd += ['-$' + s for s in DEFAULTS + list(switches)]
    env = dict(os.environ, TMP=str(out), TEMP=str(out))
    result = subprocess.run(cmd + ['ProbeHost.dpk'], cwd=out, env=env, capture_output=True)
    log = result.stdout.decode('latin1') + result.stderr.decode('latin1')
    (out / 'compile.log').write_text(log, encoding='utf-8')
    if result.returncode or 'Error:' in log or 'Fatal:' in log:
        raise RuntimeError(log)
    return out / 'ProbeHost.dpl', out / 'ProbeHost.map'


def routines(binary, mapfile, names):
    img = match.Image(str(binary))
    syms, _ = match.map_symbols(str(mapfile))
    base = img.base + img.pe.sections[0].VirtualAddress
    starts = sorted({off for locs in syms.values() for seg, off in locs if seg == '0001'})
    symbols = {base + off: n for n, locs in syms.items() for seg, off in locs if seg == '0001'}
    match.parse_imports_once(img)
    for entry in getattr(img.pe, 'DIRECTORY_ENTRY_IMPORT', []):
        for imp in entry.imports:
            if imp.name:
                n = imp.name.decode('latin1').split('@', 2)
                n = '@'.join(n[:2]) if len(n) > 1 else n[0]
                thunk = match.find_import_thunk(img, n)
                if thunk is not None:
                    symbols[thunk] = n
    md = match.capstone.Cs(match.capstone.CS_ARCH_X86, match.capstone.CS_MODE_32)
    md.detail = True
    on_exc = match.find_import_thunk(img, 'System.@HandleOnException')
    for name in names:
        loc = match.resolve(syms, name)
        if loc is None or loc[0] != '0001':
            raise ValueError('routine not in code map: ' + name)
        off = loc[1]
        k = bisect_right(starts, off)
        end = starts[k] if k < len(starts) else img.pe.sections[0].Misc_VirtualSize
        va, size = base + off, end - off

        def address(m):
            v = int(m.group(), 16)
            if va <= v < va + size:
                return '+0x%x' % (v - va)
            return symbols.get(v, 'image+0x%x' % (v - img.base) if img.contains(v) else m.group())

        stream = match.decode_stream(md, img, va, size, on_exc)
        handlers = {v: n.split('.')[-1] for v, n in symbols.items()}
        reached = graph(stream, va, size, img, handlers)[0]
        rows = []
        for norm, ins in stream:
            if ins is None:
                rows.append('       %s %s' % norm)
            elif ins.address in reached:
                operands = re.sub(r'0x[0-9a-f]+', address, ins.op_str)
                rows.append('%04x:  %-8s %s' % (ins.address - va, ins.mnemonic, operands))
        yield name, rows


def main():
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument('source', type=Path)
    ap.add_argument('--out', type=Path, required=True)
    ap.add_argument('--switch', action='append', default=[], help='e.g. O-, Q+, R+ (repeatable)')
    ap.add_argument('--compiler', default=r'C:\Tools\Delphi3\BIN\DCC32.EXE')
    ap.add_argument('names', nargs='+', help='map symbols, including Nested<Owner')
    args = ap.parse_args()
    try:
        binary, mapfile = build(args.source, args.out, args.switch, args.compiler)
        for name, rows in routines(binary, mapfile, args.names):
            print('\n' + name + ':\n' + '\n'.join(rows))
    except (OSError, ValueError, RuntimeError) as exc:
        ap.exit(1, str(exc) + '\n')


if __name__ == '__main__':
    main()
