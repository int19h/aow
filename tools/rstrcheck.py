"""Compare rebuilt RT_STRING texts with the originals, ignoring resource IDs.

Usage: python -B tools/rstrcheck.py BUILD_DIRECTORY [--original GAME_DIRECTORY]

Counts are multisets of nonempty UTF-16 strings, including duplicate texts and
all languages. Empty slots are string-table padding. Link-only vendor import
packages are reported separately; they are never installed by buildgame.py.
Exit status is 1 when any strings differ, 2 on an input error.
"""
import argparse
from collections import Counter, defaultdict
import json
from pathlib import Path
import re
import struct
import subprocess
import sys

sys.dont_write_bytecode = True
import buildgame


def strings(path):
    result = Counter()
    for kind, block, language, data in buildgame.resources(path):
        if kind != 6:
            continue
        pos = 0
        for slot in range(16):
            if pos + 2 > len(data):
                raise ValueError('%s: truncated RT_STRING %s/%s' % (path, block, language))
            length, = struct.unpack_from('<H', data, pos)
            pos += 2
            end = pos + 2 * length
            if end > len(data):
                raise ValueError('%s: truncated RT_STRING text %s/%s/%s' %
                                 (path, block, language, slot))
            if length:
                result[data[pos:end].decode('utf-16le')] += 1
            pos = end
    return result


TOKEN = re.compile(r"'(?:''|[^'])*'|\{[^}]*\}|\(\*.*?\*\)|//[^\n]*|"
                   r'\#\$[0-9a-f]+|\#\d+|[a-z_]\w*|\S', re.I | re.S)


def source_declarations():
    """Find tracked resource declarations through git grep, including includes."""
    proc = subprocess.run(['git', 'grep', '-l', '-I', '-i', '-w', 'resourcestring',
                           '--', 'src/delphi3'], cwd=buildgame.REPO,
                          stdout=subprocess.PIPE, stderr=subprocess.PIPE, check=False)
    if proc.returncode not in (0, 1):
        raise OSError(proc.stderr.decode('utf-8', errors='replace').strip())
    found = defaultdict(list)
    for filename in proc.stdout.decode('utf-8').splitlines():
        path = buildgame.REPO / filename
        source = path.read_text(encoding='cp1252')
        tokens = [m for m in TOKEN.finditer(source)
                  if not m[0].startswith(('{', '(*', '//'))]
        active = False
        i = 0
        while i < len(tokens):
            value = tokens[i][0]
            if value.lower() == 'resourcestring':
                active = True
                i += 1
                continue
            if not active:
                i += 1
                continue
            if (i + 1 >= len(tokens) or tokens[i + 1][0] != '='
                    or not re.fullmatch(r'[a-z_]\w*', value, re.I)):
                active = False
                continue
            start = tokens[i].start()
            name = value
            i += 2
            parts = []
            valid = True
            while i < len(tokens) and tokens[i][0] != ';':
                part = tokens[i][0]
                if part.startswith("'"):
                    parts.append(part[1:-1].replace("''", "'"))
                elif part.startswith('#'):
                    number = part[1:]
                    parts.append(chr(int(number[1:], 16) if number.startswith('$') else int(number)))
                elif part != '+':
                    valid = False
                i += 1
            end = tokens[i].end() if i < len(tokens) else len(source)
            if valid:
                found[''.join(parts)].append({
                    'file': filename, 'line': source.count('\n', 0, start) + 1,
                    'name': name, 'declaration': source[start:end].strip()})
            i += 1
    return found


def compare(build, original, declarations):
    reports = []
    for name in buildgame.IMPORTS + buildgame.PACKAGES + buildgame.PROGRAMS:
        extension = '.exe' if name in buildgame.PROGRAMS else '.dpl'
        module = name + extension
        imported = name in buildgame.IMPORTS
        old = strings(original / module)
        new = strings(build / 'imports' / module if imported else build / module)
        only_old, only_new = old - new, new - old
        reports.append({
            'module': module, 'link_only': imported,
            'original_count': old.total(), 'rebuilt_count': new.total(),
            'original_only': [{'text': s, 'count': n, 'source': declarations.get(s, [])}
                              for s, n in sorted(only_old.items())],
            'rebuilt_only': [{'text': s, 'count': n, 'source': declarations.get(s, [])}
                             for s, n in sorted(only_new.items())]})
    return reports


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('directory', type=Path)
    parser.add_argument('--original', type=Path, default=buildgame.GAME)
    parser.add_argument('--json', type=Path, help='also write the complete comparison as JSON')
    args = parser.parse_args()
    try:
        reports = compare(args.directory, args.original, source_declarations())
        if args.json:
            args.json.write_text(json.dumps(reports, ensure_ascii=True, indent=2) + '\n', encoding='utf-8')
        for report in reports:
            old = sum(s['count'] for s in report['original_only'])
            new = sum(s['count'] for s in report['rebuilt_only'])
            print('%s%s: %d original, %d rebuilt; %d original-only, %d rebuilt-only' % (
                report['module'], ' (link-only)' if report['link_only'] else '',
                report['original_count'], report['rebuilt_count'], old, new))
            for side in ('original_only', 'rebuilt_only'):
                for entry in report[side]:
                    print('  %s x%d %s' % (side.replace('_', '-'), entry['count'],
                                           json.dumps(entry['text'], ensure_ascii=True)))
                    for source in entry.get('source', []):
                        print('    %s:%d: %s' % (source['file'], source['line'],
                                                source['declaration']))
        return int(any(r['original_only'] or r['rebuilt_only'] for r in reports))
    except (OSError, ValueError, struct.error, UnicodeError) as error:
        parser.exit(2, str(error) + '\n')


if __name__ == '__main__':
    sys.exit(main())
