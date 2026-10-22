"""Synthetic images and fixture records. All machine bytes here are hand-authored."""
from dataclasses import dataclass
from pathlib import Path
import struct
from types import SimpleNamespace as NS

import equiv as e


@dataclass
class Case:
    name: str
    run: object
    expected: str
    why: str


def p32(value):
    return struct.pack('<I', value & 0xffffffff)


class Image:
    def __init__(self, code, extras=(), readonly=False):
        self.base = self.lo = 0x400000
        self.hi = self.base + 0x4000
        self.data = bytearray(0x4000)
        self.data[0x1000:0x1000 + len(code)] = code
        for offset, data in extras:
            self.data[offset:offset + len(data)] = data
        self.pe = NS(sections=[
            NS(Name=b'CODE', VirtualAddress=0x1000, Misc_VirtualSize=0x1000,
               Characteristics=0x60000020),
            NS(Name=b'DATA', VirtualAddress=0x2000, Misc_VirtualSize=0x1000,
               Characteristics=0x40000040 if readonly else 0xc0000040),
        ], parse_data_directories=lambda **kwargs: None)

    def contains(self, address):
        return self.lo <= address < self.hi

    def bytes_at(self, address, size):
        if not self.contains(address):
            return b''
        return bytes(self.data[address - self.base:address - self.base + size])


def build(a, b, extras_a=(), extras_b=(), readonly=False, bindings=(),
          relocs=((), ()), names=()):
    a = bytes.fromhex(a) if isinstance(a, str) else a
    b = bytes.fromhex(b) if isinstance(b, str) else b
    old, new = Image(a, extras_a, readonly), Image(b, extras_b, readonly)
    fn = e.Function('fixture', 'fixture', 0x401000, len(a), 0x401000, len(b), [], [])
    inp = NS(old=old, new=new, syms={'fixture': [('0001', 0)]},
             sigs={'fixture': (fn.ova, fn.osize)}, text=fn.ova,
             functions=[fn], module_matches=[], original_path=Path('fixture.exe'))
    addr = inp.addresses = e.Addresses(inp)
    for x, y in bindings:
        addr.bind(x, y)
    for side in (0, 1):
        addr.relocs[side].update(relocs[side])
        addr.sorted_relocs[side] = sorted(addr.relocs[side])
    for address, symbol in names:
        if symbol == 'System.@HandleOnException':
            old.pe.DIRECTORY_ENTRY_IMPORT = [NS(imports=[NS(name=(symbol + '@fixture').encode(), address=0x402100)])]
            old.data[address-old.base:address-old.base+6] = b'\xff\x25' + p32(0x402100)
        for side in (0, 1):
            addr.names[side][address] = symbol
        addr.map_addresses[symbol.rsplit('.', 1)[-1]] = address
        addr.bind(address, address)
    checker = e.Checker(inp)
    aa, bb = checker.instructions(fn)
    fn.a = [e.match.normalize(i.raw, old) for i in aa]
    fn.b = [e.match.normalize(i.raw, new) for i in bb]
    return checker, fn


def fixture(name, a, b, why, expected='reject', **kwargs):
    def run():
        checker, fn = build(a, b, **kwargs)
        return checker.check(fn)
    return Case(name, run, expected, why)


def call(position, target=0x401100):
    return b'\xe8' + p32(target - (0x401000 + position + 5))
