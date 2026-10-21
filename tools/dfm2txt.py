"""Convert Delphi 3 TPF0 DFM files, or every DFM RCDATA resource in a PE, to text.
Usage: dfm2txt.py <module.exe|form.dfm> <output-directory>
The decoder follows Classes.TReader/ObjectBinaryToText, without loading components.
"""
import argparse
from decimal import Decimal, localcontext
from pathlib import Path
import struct


def quoted(text):
    parts, run = [], ''
    for ch in text:
        if 32 <= ord(ch) < 127:
            run += ch.replace("'", "''")
        else:
            if run: parts.append("'" + run + "'"); run = ''
            parts.append('#' + str(ord(ch)))
    if run: parts.append("'" + run + "'")
    return ''.join(parts) or "''"


class Reader:
    def __init__(self, data):
        self.data, self.pos = data, 0
        if self.take(4) != b'TPF0': raise ValueError('missing TPF0 signature')

    def take(self, count):
        end = self.pos + count
        if count < 0 or end > len(self.data): raise ValueError('truncated DFM at %x' % self.pos)
        value = self.data[self.pos:end]
        self.pos = end
        return value

    def number(self, fmt):
        return struct.unpack('<' + fmt, self.take(struct.calcsize('<' + fmt)))[0]

    def peek(self):
        if self.pos >= len(self.data): raise ValueError('unexpected end of DFM')
        return self.data[self.pos]

    def short(self):
        return self.take(self.number('B')).decode('latin1')

    def end(self):
        if self.number('B') != 0: raise ValueError('expected list terminator')

    def value(self, depth):
        kind = self.number('B')
        indent = '  ' * depth
        if kind in (2, 3, 4): return str(self.number({2:'b', 3:'h', 4:'i'}[kind]))
        if kind == 5:
            mantissa, exponent = struct.unpack('<QH', self.take(10))
            if exponent & 0x7fff == 0x7fff: raise ValueError('non-finite Extended')
            with localcontext() as ctx:
                ctx.prec = 21
                value = Decimal(mantissa) * Decimal(2) ** ((exponent & 0x7fff or 1) - 16383 - 63)
                if exponent & 0x8000: value = -value
                text = str(value)
            return text if '.' in text or 'E' in text else text + '.0'
        if kind in (6, 7):
            text = self.short()
            return quoted(text) if kind == 6 else text
        if kind in (8, 9, 13): return {8:'False', 9:'True', 13:'nil'}[kind]
        if kind == 12: return quoted(self.take(self.number('i')).decode('latin1'))
        if kind == 11:
            names = []
            while self.peek(): names.append(self.short())
            self.end()
            return '[' + ', '.join(names) + ']'
        if kind == 10:
            data = self.take(self.number('i')).hex().upper()
            return '{' + ''.join('\n' + indent + '  ' + data[i:i+64] for i in range(0, len(data), 64)) + '}'
        if kind == 1:
            values = []
            while self.peek(): values.append(self.value(depth + 1))
            self.end()
            return '(' + ''.join('\n' + indent + '  ' + v for v in values) + ')'
        if kind == 14:
            items = []
            while self.peek():
                order = ' [' + self.value(depth + 1) + ']' if self.peek() in (2,3,4) else ''
                if self.number('B') != 1: raise ValueError('expected collection item')
                props = self.properties(depth + 2)
                items += [indent + '  item' + order] + props + [indent + '  end']
            self.end()
            return '<' + ''.join('\n' + line for line in items) + '>'
        if kind == 0: return 'nil'
        raise ValueError('unknown value tag %d at %x' % (kind, self.pos - 1))

    def properties(self, depth):
        lines = []
        while self.peek():
            name = self.short()
            lines.append('  ' * depth + name + ' = ' + self.value(depth))
        self.end()
        return lines

    def component(self, depth=0):
        flags = self.number('B') & 15 if self.peek() & 240 == 240 else 0
        order = ' [' + self.value(depth) + ']' if flags & 2 else ''
        cls, name = self.short(), self.short()
        header = ('inherited ' if flags & 1 else 'object ') + (name + ': ' if name else '') + cls + order
        lines = ['  ' * depth + header] + self.properties(depth + 1)
        while self.peek():
            _, children = self.component(depth + 1)
            lines += children
        self.end()
        return name, lines + ['  ' * depth + 'end']


def forms(path):
    if path.read_bytes()[:4] == b'TPF0':
        yield path.stem, path.read_bytes()
        return
    try:
        import pefile
    except ImportError:
        import sys
        sys.path.append(r'C:\Tools\pylib')
        import pefile
    pe = pefile.PE(str(path))
    for resource in getattr(getattr(pe, 'DIRECTORY_ENTRY_RESOURCE', None), 'entries', []):
        if resource.id != 10: continue
        for entry in resource.directory.entries:
            for language in entry.directory.entries:
                info = language.data.struct
                data = pe.get_data(info.OffsetToData, info.Size)
                if data.startswith(b'TPF0'): yield str(entry.name or entry.id), data
    pe.close()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('input', type=Path)
    parser.add_argument('output', type=Path)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    found, names = 0, set()
    for resource, data in forms(args.input):
        reader = Reader(data)
        try:
            name, lines = reader.component()
            if reader.pos != len(data): raise ValueError('trailing DFM data')
        except ValueError as error:
            raise ValueError('%s: %s' % (resource, error)) from error
        found += 1
        name = name or resource
        if name.lower() in names: raise ValueError('duplicate form name: ' + name)
        if Path(name).name != name or name in ('.', '..'): raise ValueError('invalid form name')
        names.add(name.lower())
        with (args.output / (name + '.txt')).open('w', encoding='ascii', newline='') as out:
            out.write('\r\n'.join('\n'.join(lines).splitlines()) + '\r\n')
    print('%s: %d DFM resources found, %d converted' % (args.input.name, found, len(names)))


if __name__ == '__main__':
    main()
