"""Build the recovered Delphi 3 runtime, install a separate game copy, and smoke test it.

All compiler products and extracted resources go beneath the supplied build directory.
The installed GOG game is read only. Third party import DPLs are never installed.
"""
import argparse
import ctypes
from contextlib import contextmanager
from functools import lru_cache
import hashlib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import time

try:
    import pefile
except ImportError:
    sys.path.append(r'C:\Tools\pylib')
    import pefile

REPO = Path(__file__).resolve().parents[1]
SOURCE = REPO / 'src' / 'delphi3'
GAME = Path(r'D:\Games\GOG\Age of Wonders')
DELPHI = Path(r'C:\Tools\Delphi3')
PACKAGES = ['Gfxepack', 'Dcpack', 'Ilpack', 'Enginep', 'aowDPlay', 'VideoP',
            'Network', 'SoundP', 'Adcpack', 'aowFXpck', 'aowInt', 'HSEPack',
            'AoWEPACK', 'AoWTCPCK', 'AOWTools', 'ILToolsP']
IMPORTS = ['Vcladdon', 'Localize', 'ims']
PROGRAMS = ['AoW', 'AoWEd']


def resources(path):
    with pefile.PE(str(path), fast_load=True) as pe:
        pe.parse_data_directories(directories=[2])
        for kind in pe.DIRECTORY_ENTRY_RESOURCE.entries:
            for name in kind.directory.entries:
                for lang in name.directory.entries:
                    info = lang.data.struct
                    yield (str(kind.name) if kind.name else kind.id,
                           str(name.name) if name.name else name.id, lang.id,
                           pe.get_data(info.OffsetToData, info.Size))


def package_info(path):
    data = next(d for t, n, l, d in resources(path) if n == 'PACKAGEINFO')
    flags, count = struct.unpack_from('<II', data)
    pos, required, units = 8, [], []
    for _ in range(count):
        end = data.index(b'\0', pos + 1)
        required.append(data[pos + 1:end].decode('ascii'))
        pos = end + 1
    count, = struct.unpack_from('<I', data, pos)
    pos += 4
    for _ in range(count):
        end = data.index(b'\0', pos + 2)
        units.append((data[pos + 2:end].decode('ascii'), data[pos]))
        pos = end + 1
    return flags, required, units


def export_names(path):
    with pefile.PE(str(path), fast_load=True, max_symbol_exports=65536) as pe:
        pe.parse_data_directories(directories=[0])
        return {s.name.decode('latin1') for s in pe.DIRECTORY_ENTRY_EXPORT.symbols if s.name}


def write_text(path, text):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open('w', encoding='ascii', newline='') as out:
        out.write(text.replace('\r\n', '\n').replace('\n', '\r\n'))


def resource_id(value):
    return (struct.pack('<HH', 0xffff, value) if isinstance(value, int)
            else value.encode('utf-16le') + b'\0\0')


def write_res(path, entries):
    result = bytearray(struct.pack('<IIHHHHIHHII', 0, 32, 0xffff, 0,
                                   0xffff, 0, 0, 0, 0, 0, 0))
    for kind, name, language, data in entries:
        header = resource_id(kind) + resource_id(name)
        header += b'\0' * (-len(header) % 4)
        header += struct.pack('<IHHII', 0, 0x1030, language, 0, 0)
        result += struct.pack('<II', len(data), len(header) + 8) + header + data
        result += b'\0' * (-len(data) % 4)
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_bytes(result)


def run(command, cwd, log):
    proc = subprocess.run([str(c) for c in command], cwd=cwd,
                          stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    output = proc.stdout.decode('cp1252', errors='replace').replace('\r\r\n', '\n')
    log.parent.mkdir(parents=True, exist_ok=True)
    log.write_text(output, encoding='utf-8')
    errors = [line for line in output.splitlines()
              if re.search(r'\b(?:Error|Fatal)\b', line, re.I)]
    if proc.returncode or errors:
        raise RuntimeError(errors[0] if errors else output.strip().splitlines()[-1])
    return output


def prepare_resources(name, build):
    extension = '.exe' if name in PROGRAMS else '.dpl'
    entries = list(resources(GAME / (name + extension)))
    entries = [r for r in entries if r[1] not in ('PACKAGEINFO', 'DESCRIPTION')
               and r[0] != 6]  # String tables are generated from the recovered units.
    if name in PROGRAMS:
        forms = build / 'forms' / name
        forms.mkdir(parents=True, exist_ok=True)
        compiled = {}
        for source in sorted((REPO / 'data' / 'forms' / name).glob('*.txt')):
            target = forms / source.name
            shutil.copy2(source, target)
            dfm = target.with_suffix('.dfm')
            dfm.unlink(missing_ok=True)
            run([DELPHI / 'BIN' / 'convert.exe', target.name], forms,
                build / 'logs' / ('convert-' + name + '-' + source.stem + '.log'))
            data = dfm.read_bytes()
            # Delphi 3 CONVERT writes a legacy resource header before the TPF0 stream.
            start = data.find(b'TPF0')
            if start >= 0:
                data = data[start:]
                dfm.write_bytes(data)
            if data[:4] != b'TPF0':
                raise RuntimeError('convert did not produce binary DFM: ' + source.name)
            offset = 5 if data[4] & 0xf0 == 0xf0 else 4
            cls = data[offset + 1:offset + 1 + data[offset]].decode('ascii')
            compiled[cls.upper()] = data
        found = set()
        for index, (kind, resource, language, data) in enumerate(entries):
            if kind == 10 and data.startswith(b'TPF0'):
                if resource not in compiled:
                    raise RuntimeError('missing text form: ' + str(resource))
                entries[index] = (kind, resource, language, compiled[resource])
                found.add(resource)
        if found != set(compiled):
            raise RuntimeError('text forms absent from original: ' + str(set(compiled) - found))
    write_res(build / 'res' / (name + '.res'), entries)


def source_dir(name, root):
    return root if name == 'Enginep' else root / name


def compile_module(name, build, imported=False):
    root = build / 'src'
    directory = root / 'imports' / name if imported else source_dir(name, root)
    project = directory / (name + ('.dpr' if name in PROGRAMS else '.dpk'))
    out = build / 'imports' if imported else build
    dcu = build / 'dcu' / name
    out.mkdir(parents=True, exist_ok=True)
    dcu.mkdir(parents=True, exist_ok=True)
    paths = [out, build / 'imports', root / 'imports' / 'Vcladdon',
             root / 'imports' / 'Localize', root / 'imports' / 'ims', root]
    paths += [source_dir(p, root) for p in PACKAGES if p != name]
    rel = lambda p: os.path.relpath(p, directory)
    command = [DELPHI / 'BIN' / 'DCC32.EXE', '-GD', '-B', '-Q',
               '-DRUNTIME_PACKAGES', '-U' + ';'.join(rel(p) for p in paths), '-O' + rel(root),
               '-E' + rel(out), '-N' + rel(dcu), '-LE' + rel(out), '-LN' + rel(out)]
    original = GAME / (name + ('.exe' if name in PROGRAMS else '.dpl'))
    with pefile.PE(str(original), fast_load=True) as pe:
        command.append('-K%X' % pe.OPTIONAL_HEADER.ImageBase)
    if name not in PROGRAMS and package_info(original)[0] & 1:
        command.append('-Z')
    if name in PROGRAMS:
        with pefile.PE(str(GAME / (name + '.exe'))) as pe:
            packages = list(dict.fromkeys(i.dll.decode('ascii')[:-4]
                            for i in pe.DIRECTORY_ENTRY_IMPORT if i.dll.lower().endswith(b'.dpl')))
        command.append('-LU' + ';'.join(packages))
    run(command + [project.name], directory, build / 'logs' / (name + '.log'))


def bind_import_package(name, build):
    """Bind link-only declarations to the vendor's decorated export names.

    DCPs store the linker names separately from their Pascal type information.
    Preserve the recovered layouts and virtual slots, but use the vendor's type
    fingerprints in that import-name table. No stub implementation is installed.
    This is deliberately restricted to third party import packages; recovered
    game packages are compared without rewriting any exports.
    """
    key = lambda n: re.sub(r'@[0-9A-F]{8}$', '', n)
    original = {key(n): n for n in export_names(GAME / (name + '.dpl'))}
    generated = export_names(build / 'imports' / (name + '.dpl'))
    bindings = {}
    for symbol in generated:
        target = original.get(key(symbol))
        if target and symbol != target:
            if len(symbol) != len(target):
                raise RuntimeError('import name length differs: ' + symbol)
            bindings[symbol] = target
    for suffix in ('.dcp', '.dpl'):
        path = build / 'imports' / (name + suffix)
        data = path.read_bytes()
        for source, target in bindings.items():
            data = data.replace(source.encode('ascii') + b'\0', target.encode('ascii') + b'\0')
        path.write_bytes(data)
    (build / 'exports' / (name + '-imports.json')).write_text(json.dumps(bindings, indent=2))


def compare_exports(build, name):
    original = export_names(GAME / (name + '.dpl'))
    actual = export_names(build / (name + '.dpl'))
    missing, extra = sorted(original - actual), sorted(actual - original)
    report = {'same': len(original & actual), 'missing': missing, 'extra': extra}
    key = lambda n: re.sub(r'@[0-9A-F]{8}$', '', n)
    old = {key(n): n for n in original}
    new = {key(n): n for n in actual}
    report['different_hashes'] = [
        {'name': n, 'original': old[n], 'built': new[n]}
        for n in sorted(old.keys() & new.keys()) if old[n] != new[n]]
    report['missing_names'] = sorted(old.keys() - new.keys())
    report['extra_names'] = sorted(new.keys() - old.keys())
    (build / 'exports' / (name + '.json')).write_text(json.dumps(report, indent=2))
    lines = [name, 'Same: %d; different hashes: %d; missing names: %d; extra names: %d' %
             (report['same'], len(report['different_hashes']), len(report['missing_names']),
              len(report['extra_names']))]
    lines += ['differs  %s -> %s' % (x['original'], x['built']) for x in report['different_hashes']]
    lines += ['missing  ' + old[n] for n in report['missing_names']]
    lines += ['extra    ' + new[n] for n in report['extra_names']]
    (build / 'exports' / (name + '.txt')).write_text('\n'.join(lines) + '\n')
    return report


@lru_cache(maxsize=None)
def original_exports(path):
    with pefile.PE(str(path), fast_load=True, max_symbol_exports=65536) as pe:
        pe.parse_data_directories(directories=[0])
        return ({s.name.decode('latin1') for s in pe.DIRECTORY_ENTRY_EXPORT.symbols if s.name},
                {s.ordinal for s in pe.DIRECTORY_ENTRY_EXPORT.symbols})


def check_imports(path, build, rebuilt_exports=None):
    missing, checked = [], []
    recovered = {p.lower() + '.dpl' for p in PACKAGES}
    with pefile.PE(str(path), fast_load=True) as pe:
        pe.parse_data_directories(directories=[1])
        for dependency in pe.DIRECTORY_ENTRY_IMPORT:
            name = dependency.dll.decode('ascii')
            kind = 'rebuilt' if name.lower() in recovered else 'original'
            target = (build if kind == 'rebuilt' else GAME) / name
            if not target.is_file() and name.lower().endswith('.dll'):
                target = Path(os.environ['WINDIR']) / 'SysWOW64' / name
                kind = 'system'
            if not target.is_file():
                raise RuntimeError('runtime dependency absent: ' + name)
            if kind == 'rebuilt':
                if rebuilt_exports is None:
                    available, ordinals = original_exports.__wrapped__(target)
                else:
                    if target not in rebuilt_exports:
                        rebuilt_exports[target] = original_exports.__wrapped__(target)
                    available, ordinals = rebuilt_exports[target]
            else:
                available, ordinals = original_exports(target)
            for symbol in dependency.imports:
                imported = symbol.name.decode('ascii') if symbol.name else '#' + str(symbol.ordinal)
                found = imported in available if symbol.name else symbol.ordinal in ordinals
                checked.append({'dependency': name, 'name': imported, 'kind': kind, 'found': found})
                if not found:
                    missing.append(name + '!' + imported)
    if missing:
        raise RuntimeError('unresolved import: ' + missing[0])
    return checked



def initialization_table(path):
    """Read the compiler's actual unit-init table; resolve import thunks and exports."""
    with pefile.PE(str(path), fast_load=True, max_symbol_exports=65536) as pe:
        pe.parse_data_directories(directories=[0, 1])
        base = pe.OPTIONAL_HEADER.ImageBase
        exports = {e.address + base: e.name.decode('latin1')
                   for e in getattr(getattr(pe, 'DIRECTORY_ENTRY_EXPORT', None), 'symbols', []) if e.name}
        imports = {i.address: d.dll.decode('ascii') + '!' + i.name.decode('latin1')
                   for d in getattr(pe, 'DIRECTORY_ENTRY_IMPORT', []) for i in d.imports if i.name}
        if path.suffix.lower() == '.dpl':
            address = base + next(e.address for e in pe.DIRECTORY_ENTRY_EXPORT.symbols
                                  if e.name == b'@GetPackageInfoTable')
            code = pe.get_data(address - base, 6)
            if code[0] != 0xb8:
                raise RuntimeError('unexpected package table accessor: ' + str(path))
            table, = struct.unpack_from('<I', code, 1)
        else:
            code = pe.get_data(pe.OPTIONAL_HEADER.AddressOfEntryPoint, 128)
            candidates = []
            for i in range(len(code) - 10):
                if code[i] == 0xb8 and code[i + 5] == 0xe8:
                    pointer, = struct.unpack_from('<I', code, i + 1)
                    if base <= pointer < base + pe.OPTIONAL_HEADER.SizeOfImage:
                        count, entries = struct.unpack('<II', pe.get_data(pointer - base, 8))
                        if 0 < count < 2000 and entries == pointer + 8:
                            candidates.append(pointer)
            if len(candidates) != 1:
                raise RuntimeError('cannot identify executable unit table: ' + str(path))
            table = candidates[0]
        count, pointer = struct.unpack('<II', pe.get_data(table - base, 8))
        records = list(struct.iter_unpack('<II', pe.get_data(pointer - base, count * 8)))
        symbols = {}
        map_path = path.with_suffix('.map')
        if map_path.is_file():
            for match in re.finditer(r'^\s+0001:([0-9A-Fa-f]+)\s+(\S+)\s*$', map_path.read_text(), re.M):
                symbols[base + 0x1000 + int(match[1], 16)] = match[2]

        def describe(address):
            raw = pe.get_data(address - base, 6)
            if raw[:2] == b'\xff\x25':
                slot, = struct.unpack_from('<I', raw, 2)
                if slot in imports:
                    return imports[slot]
            return exports.get(address) or symbols.get(address)
        result = []
        for index, (init, final) in enumerate(records):
            symbol = describe(init) if init else None
            result.append({'index': index, 'init_rva': hex(init - base) if init else None,
                           'final_rva': hex(final - base) if final else None,
                           'init_symbol': symbol})
        return result


def write_reports(build):
    imports, rebuilt_exports = {}, {}
    for name in PACKAGES + PROGRAMS:
        imports[name] = check_imports(build / (name + ('.exe' if name in PROGRAMS else '.dpl')), build, rebuilt_exports)
    summary = {}
    for kind in ('original', 'system', 'rebuilt'):
        entries = [i for items in imports.values() for i in items if i['kind'] == kind]
        summary[kind] = {'import_sites': len(entries),
                         'unique_names': len({(i['dependency'].lower(), i['name']) for i in entries}),
                         'missing': sum(not i['found'] for i in entries)}
    (build / 'runtime-imports.json').write_text(json.dumps({'summary': summary, 'modules': imports}, indent=2))
    totals = dict(same=0, different_hashes=0, missing_names=0, extra_names=0)
    metadata, text = [], []
    for name in PACKAGES:
        report = json.loads((build / 'exports' / (name + '.json')).read_text())
        for key in totals:
            totals[key] += report[key] if key == 'same' else len(report[key])
        text.append((build / 'exports' / (name + '.txt')).read_text())
        old, new = package_info(GAME / (name + '.dpl')), package_info(build / (name + '.dpl'))
        old_units = [u.lower() for u, flags in old[2]]
        new_units = [u.lower() for u, flags in new[2]]
        metadata.append({'module': name, 'flags': old[0] == new[0],
                         'requires_order': old[1] == new[1],
                         'units': set(old_units) == set(new_units),
                         'unit_order': old_units == new_units,
                         'original_unit_order': old_units, 'built_unit_order': new_units})
    (build / 'exports' / 'summary.json').write_text(json.dumps(totals, indent=2))
    (build / 'exports' / 'all.txt').write_text('\n'.join(text))
    for name in PROGRAMS:
        old = package_info(GAME / (name + '.exe'))
        new = package_info(build / (name + '.exe'))
        old_units, new_units = [u.lower() for u, f in old[2]], [u.lower() for u, f in new[2]]
        metadata.append({'module': name, 'flags': old[0] == new[0],
            'requires_order': old[1] == new[1], 'units': set(old_units) == set(new_units),
            'unit_order': old_units == new_units, 'original_unit_order': old_units,
            'built_unit_order': new_units,
            'missing_units': sorted(set(old_units) - set(new_units)),
            'extra_units': sorted(set(new_units) - set(old_units))})
    (build / 'package-metadata.json').write_text(json.dumps(metadata, indent=2))
    initialization = []
    for name in PACKAGES + PROGRAMS:
        suffix = '.exe' if name in PROGRAMS else '.dpl'
        original = initialization_table(GAME / (name + suffix))
        actual = initialization_table(build / (name + suffix))
        def imported_units(records):
            return [x['init_symbol'].lower().split('@')[0] for x in records
                    if x['init_symbol'] and '!' in x['init_symbol']]
        def owned_units(records):
            return [x['init_symbol'].split('.')[0].lower() for x in records
                    if x['init_symbol'] and '!' not in x['init_symbol']
                    and x['init_symbol'].endswith('@00000000')]
        initialization.append({'module': name, 'original_count': len(original),
            'built_count': len(actual),
            'imported_unit_order': imported_units(original) == imported_units(actual),
            'exported_owned_unit_order': owned_units(original) == owned_units(actual) if name in PACKAGES else None,
            'original': original, 'built': actual})
    (build / 'initialization-order.json').write_text(json.dumps(initialization, indent=2))



def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def diagnose_game(build, target, name):
    """Capture the first real Win32/Delphi exception, including its message."""
    from ctypes import wintypes as w
    kernel = ctypes.WinDLL('kernel32', use_last_error=True)
    kernel.WaitForDebugEvent.argtypes = [ctypes.c_void_p, w.DWORD]
    kernel.ContinueDebugEvent.argtypes = [w.DWORD, w.DWORD, w.DWORD]
    kernel.GetFinalPathNameByHandleW.argtypes = [w.HANDLE, w.LPWSTR, w.DWORD, w.DWORD]
    kernel.ReadProcessMemory.argtypes = [w.HANDLE, ctypes.c_void_p, ctypes.c_void_p,
                                         ctypes.c_size_t, ctypes.POINTER(ctypes.c_size_t)]
    kernel.CloseHandle.argtypes = [w.HANDLE]
    kernel.OpenThread.argtypes = [w.DWORD, w.BOOL, w.DWORD]
    kernel.OpenThread.restype = w.HANDLE
    kernel.Wow64GetThreadContext.argtypes = [w.HANDLE, ctypes.c_void_p]
    pointer_size = ctypes.sizeof(ctypes.c_void_p)
    pointer = '<Q' if pointer_size == 8 else '<I'
    union_offset = 16 if pointer_size == 8 else 12
    process = HiddenProcess(target / (name + '.exe'), target, 2)  # DEBUG_ONLY_THIS_PROCESS
    modules, module_sizes, module_code = {}, {}, {}
    result = {'module': name, 'exception': None}
    event_handles = []
    stopping = False
    deadline = time.monotonic() + 30

    def read(address, length):
        buffer = ctypes.create_string_buffer(length)
        received = ctypes.c_size_t()
        kernel.ReadProcessMemory(int(process._handle), address, buffer, length, ctypes.byref(received))
        return buffer.raw[:received.value]

    def module_at(address):
        candidates = [base for base in modules if base <= address < base + module_sizes.get(base, 0)]
        if not candidates:
            return None
        base = max(candidates)
        return {'file': modules[base], 'offset': '0x%X' % (address - base)}

    try:
        while time.monotonic() < deadline:
            event = ctypes.create_string_buffer(1024)
            if not kernel.WaitForDebugEvent(event, 250):
                continue
            kind, pid, tid = struct.unpack_from('<III', event.raw)
            info = event.raw[union_offset:]
            status = 0x10002  # DBG_CONTINUE
            if kind in (3, 6):  # CREATE_PROCESS / LOAD_DLL
                handle, = struct.unpack_from(pointer, info)
                base, = struct.unpack_from(pointer, info, pointer_size * (3 if kind == 3 else 1))
                filename = ctypes.create_unicode_buffer(32768)
                kernel.GetFinalPathNameByHandleW(handle, filename, len(filename), 0)
                modules[base] = filename.value
                try:
                    with pefile.PE(filename.value, fast_load=True) as loaded:
                        module_sizes[base] = loaded.OPTIONAL_HEADER.SizeOfImage
                        module_code[base] = [(base + s.VirtualAddress,
                                              base + s.VirtualAddress + s.Misc_VirtualSize)
                                             for s in loaded.sections if s.Characteristics & 0x20000000]
                except OSError:
                    module_sizes[base] = 0
                if handle:
                    kernel.CloseHandle(handle)
                if kind == 3:
                    for offset in (pointer_size, pointer_size * 2):
                        handle, = struct.unpack_from(pointer, info, offset)
                        event_handles.append(handle)
            elif kind == 7:  # UNLOAD_DLL
                modules.pop(struct.unpack_from(pointer, info)[0], None)
            elif kind == 1:  # EXCEPTION_DEBUG_EVENT
                code, = struct.unpack_from('<I', info)
                address, = struct.unpack_from(pointer, info, 16 if pointer_size == 8 else 12)
                if code not in (0x80000003, 0x80000004, 0x4000001f) and not stopping:
                    exception = {'code': '0x%08X' % code, 'address': '0x%X' % address,
                                 'location': module_at(address)}
                    thread = kernel.OpenThread(0x48, False, tid)
                    if thread:
                        context = ctypes.create_string_buffer(716)
                        struct.pack_into('<I', context, 0, 0x10007)
                        if kernel.Wow64GetThreadContext(thread, context):
                            esp, = struct.unpack_from('<I', context.raw, 196)
                            stack = read(esp, 4096)
                            frames = []
                            for offset in range(0, len(stack) - 3, 4):
                                value, = struct.unpack_from('<I', stack, offset)
                                location = module_at(value)
                                is_code = any(lo <= value < hi for ranges in module_code.values() for lo, hi in ranges)
                                if is_code and location and location['file'].removeprefix('\\\\?\\').lower().startswith(str(target).lower()):
                                    location['stack_offset'] = offset
                                    frames.append(location)
                            exception['stack'] = frames[:48]
                        kernel.CloseHandle(thread)
                    if code == 0xeedfade:
                        count, = struct.unpack_from('<I', info, 24 if pointer_size == 8 else 16)
                        params = struct.unpack_from('<' + ('Q' if pointer_size == 8 else 'I') * count,
                                                    info, 32 if pointer_size == 8 else 20)
                        if len(params) >= 2:
                            exception['raised_at'] = module_at(params[0])
                            obj = read(params[1], 8)
                            if len(obj) == 8:
                                message, = struct.unpack_from('<I', obj, 4)
                                length = read(message - 4, 4)
                                if len(length) == 4:
                                    length, = struct.unpack('<I', length)
                                    if length < 65536:
                                        exception['message'] = read(message, length).decode('cp1252', errors='replace')
                    result['exception'] = exception
                    process.terminate()
                    stopping = True
                    deadline = min(deadline, time.monotonic() + 5)
                if code not in (0x80000003, 0x80000004):
                    status = 0x80010001  # DBG_EXCEPTION_NOT_HANDLED
            elif kind == 5:  # EXIT_PROCESS
                result['exit_code'], = struct.unpack_from('<I', info)
                kernel.ContinueDebugEvent(pid, tid, status)
                break
            kernel.ContinueDebugEvent(pid, tid, status)
    finally:
        if process.poll() is None:
            process.terminate()
        for handle in set(event_handles):
            if handle != int(process._handle):
                kernel.CloseHandle(handle)
        process.close()
        (build / (name + '-exception.json')).write_text(json.dumps(result, indent=2))
    summary = {key: value for key, value in (result['exception'] or {}).items() if key != 'stack'}
    print(name + ': first exception ' + json.dumps(summary), flush=True)
    return result


def build_game(build):
    if (build == GAME.resolve() or build.is_relative_to(GAME.resolve())
            or GAME.resolve().is_relative_to(build) or build.is_relative_to(REPO)
            or REPO.is_relative_to(build)):
        raise ValueError('build directory must be outside the repository and original install')
    build.mkdir(parents=True, exist_ok=True)
    root = build / 'src'
    shutil.copytree(SOURCE, root, dirs_exist_ok=True,
                    ignore=shutil.ignore_patterns('*.dcu', '*.exe', '*.dpl', '*.dcp', '*.map', '*.drc'))
    (build / 'exports').mkdir(exist_ok=True)
    manifest = {'complete': False, 'modules': {}, 'original_modules': {}}
    manifest_path = build / 'build.json'
    manifest_path.write_text(json.dumps(manifest, indent=2))
    for name in IMPORTS + PACKAGES + PROGRAMS:
        try:
            if name not in IMPORTS:
                prepare_resources(name, build)
            compile_module(name, build, name in IMPORTS)
            if name in IMPORTS:
                bind_import_package(name, build)
            else:
                extension = '.exe' if name in PROGRAMS else '.dpl'
                product = build / (name + extension)
                check_imports(product, build)
                manifest['modules'][product.name] = digest(product)
                manifest['original_modules'][product.name] = digest(GAME / product.name)
                manifest_path.write_text(json.dumps(manifest, indent=2))
            report = compare_exports(build, name) if name in PACKAGES else None
            suffix = (' (exports: %d same, %d missing, %d extra)' %
                      (report['same'], len(report['missing']), len(report['extra']))) if report else ''
            print(name + ': OK' + suffix, flush=True)
        except Exception as error:
            print(name + ': ERROR ' + str(error), flush=True)
            raise
    manifest['complete'] = True
    write_reports(build)
    manifest_path.write_text(json.dumps(manifest, indent=2))


def install_game(build, target):
    original = GAME.resolve()
    if target == original or target.is_relative_to(original) or original.is_relative_to(target):
        raise ValueError('game copy must be separate from original install')
    if target == REPO or target.is_relative_to(REPO) or REPO.is_relative_to(target):
        raise ValueError('game copy must be outside the repository')
    if target == build or build.is_relative_to(target):
        raise ValueError('game copy must not contain the build directory')
    manifest = json.loads((build / 'build.json').read_text())
    if not manifest.get('complete'):
        raise RuntimeError('build did not complete; see build.json and logs')
    modules = [(name, '.dpl') for name in PACKAGES] + [(name, '.exe') for name in PROGRAMS]
    for name, suffix in modules:
        if not (build / (name + suffix)).is_file():
            raise RuntimeError('missing build product: ' + name + suffix)
        if manifest['modules'].get(name + suffix) != digest(build / (name + suffix)):
            raise RuntimeError('build product changed since compilation: ' + name + suffix)
    shutil.copytree(original, target, dirs_exist_ok=True)
    for name, suffix in modules:
        shutil.copy2(build / (name + suffix), target / (name + suffix))
        print(name + ': OK installed', flush=True)


def verify_exports(build):
    for name in PACKAGES:
        report = compare_exports(build, name)
        differs = bool(report['missing'] or report['extra'])
        print('%s: %s exports (%d same, %d hashes differ, %d missing names, %d extra names)' %
              (name, 'DIFF' if differs else 'OK', report['same'],
               len(report['different_hashes']), len(report['missing_names']),
               len(report['extra_names'])), flush=True)
    write_reports(build)
    print('Runtime imports: OK; counts in ' + str(build / 'runtime-imports.json'), flush=True)


def window_list(pid):
    from ctypes import wintypes as w
    user = ctypes.WinDLL('user32', use_last_error=True)
    user.IsWindowVisible.argtypes = [w.HWND]
    user.GetWindowThreadProcessId.argtypes = [w.HWND, ctypes.POINTER(w.DWORD)]
    user.GetWindowTextW.argtypes = [w.HWND, w.LPWSTR, ctypes.c_int]
    user.GetClassNameW.argtypes = [w.HWND, w.LPWSTR, ctypes.c_int]
    result = []
    callback = ctypes.WINFUNCTYPE(w.BOOL, w.HWND, w.LPARAM)

    def describe(hwnd):
        title, cls = ctypes.create_unicode_buffer(2048), ctypes.create_unicode_buffer(256)
        user.GetWindowTextW(hwnd, title, len(title))
        user.GetClassNameW(hwnd, cls, len(cls))
        return {'handle': int(hwnd), 'title': title.value, 'class': cls.value,
                'visible': bool(user.IsWindowVisible(hwnd))}

    @callback
    def visit(hwnd, param):
        owner = w.DWORD()
        user.GetWindowThreadProcessId(hwnd, ctypes.byref(owner))
        if owner.value == pid:
            item = describe(hwnd)
            children = []

            @callback
            def child(child_hwnd, param):
                children.append(describe(child_hwnd))
                return True
            user.EnumChildWindows(hwnd, child, 0)
            item['children'] = children
            result.append(item)
        return True
    if _TEST_DESKTOP_HANDLE is None:
        raise RuntimeError('window enumeration requires WinSta0\\AoWTest')
    user.EnumDesktopWindows.argtypes = [w.HANDLE, callback, w.LPARAM]
    ctypes.set_last_error(0)
    if not user.EnumDesktopWindows(_TEST_DESKTOP_HANDLE, visit, 0):
        error = ctypes.get_last_error()
        if error:
            raise ctypes.WinError(error)
    return result



_TEST_DESKTOP = None
_TEST_DESKTOP_HANDLE = None
_TEST_PROCESSES = []


class HiddenProcess:
    """Create a GUI child explicitly on the test desktop, without switching desktops."""
    def __init__(self, executable, directory, flags=0, arguments=()):
        from ctypes import wintypes as w
        if _TEST_DESKTOP is None:
            raise RuntimeError('GUI startup requires the isolated test desktop')
        class Startup(ctypes.Structure):
            _fields_ = [('cb', w.DWORD), ('reserved', w.LPWSTR), ('desktop', w.LPWSTR),
                        ('title', w.LPWSTR), ('x', w.DWORD), ('y', w.DWORD),
                        ('width', w.DWORD), ('height', w.DWORD), ('chars_x', w.DWORD),
                        ('chars_y', w.DWORD), ('fill', w.DWORD), ('flags', w.DWORD),
                        ('show', w.WORD), ('reserved_size', w.WORD),
                        ('reserved_bytes', ctypes.c_void_p), ('stdin', w.HANDLE),
                        ('stdout', w.HANDLE), ('stderr', w.HANDLE)]
        class ProcessInfo(ctypes.Structure):
            _fields_ = [('process', w.HANDLE), ('thread', w.HANDLE),
                        ('pid', w.DWORD), ('tid', w.DWORD)]
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.CreateProcessW.argtypes = [w.LPCWSTR, w.LPWSTR, ctypes.c_void_p,
            ctypes.c_void_p, w.BOOL, w.DWORD, ctypes.c_void_p, w.LPCWSTR,
            ctypes.POINTER(Startup), ctypes.POINTER(ProcessInfo)]
        kernel.CloseHandle.argtypes = [w.HANDLE]
        startup, info = Startup(), ProcessInfo()
        startup.cb, startup.desktop = ctypes.sizeof(startup), _TEST_DESKTOP
        command = ctypes.create_unicode_buffer(subprocess.list2cmdline([str(executable), *map(str, arguments)]))
        if not kernel.CreateProcessW(str(executable), command, None, None, False,
                                     flags, None, str(directory), ctypes.byref(startup), ctypes.byref(info)):
            raise ctypes.WinError(ctypes.get_last_error())
        kernel.CloseHandle(info.thread)
        self._handle, self.pid = info.process, info.pid
        self.returncode = None
        _TEST_PROCESSES.append(self)

    def poll(self):
        if self._handle is None:
            return self.returncode
        from ctypes import wintypes as w
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.GetExitCodeProcess.argtypes = [w.HANDLE, ctypes.POINTER(w.DWORD)]
        result = w.DWORD()
        if not kernel.GetExitCodeProcess(self._handle, ctypes.byref(result)):
            raise ctypes.WinError(ctypes.get_last_error())
        self.returncode = None if result.value == 259 else result.value
        return self.returncode

    def wait(self, timeout=None):
        deadline = time.monotonic() + timeout if timeout is not None else float('inf')
        while self.poll() is None:
            if time.monotonic() >= deadline:
                raise subprocess.TimeoutExpired(str(self.pid), timeout)
            time.sleep(.05)
        return self.returncode

    def terminate(self):
        from ctypes import wintypes as w
        kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        kernel.TerminateProcess.argtypes = [w.HANDLE, w.UINT]
        if self.poll() is None and not kernel.TerminateProcess(self._handle, 1):
            raise ctypes.WinError(ctypes.get_last_error())

    def close(self):
        from ctypes import wintypes as w
        kernel = ctypes.WinDLL('kernel32')
        kernel.CloseHandle.argtypes = [w.HANDLE]
        if self._handle is not None:
            kernel.CloseHandle(self._handle)
            self._handle = None
        if self in _TEST_PROCESSES:
            _TEST_PROCESSES.remove(self)


@contextmanager
def isolated_test_environment(build):
    """Keep GUI tests off the user's desktop and restore the game's user settings."""
    import winreg
    import base64
    from ctypes import wintypes as w
    global _TEST_DESKTOP, _TEST_DESKTOP_HANDLE
    key_path = r'Software\Triumph Studios\Age of Wonders'
    access = winreg.KEY_READ | winreg.KEY_WOW64_32KEY

    def snapshot(path):
        try:
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, path, 0, access) as key:
                values = [winreg.EnumValue(key, i) for i in range(winreg.QueryInfoKey(key)[1])]
                children = {winreg.EnumKey(key, i): snapshot(path + '\\' + winreg.EnumKey(key, i))
                            for i in range(winreg.QueryInfoKey(key)[0])}
                return {'values': values, 'children': children}
        except FileNotFoundError:
            return None

    def remove(path):
        current = snapshot(path)
        if current is None:
            return
        for child in current['children']:
            remove(path + '\\' + child)
        winreg.DeleteKeyEx(winreg.HKEY_CURRENT_USER, path, winreg.KEY_WOW64_32KEY)

    def restore(path, original):
        current = snapshot(path)
        if current == original:
            return
        if original is None:
            remove(path)
            return
        with winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, path, 0,
                winreg.KEY_WRITE | winreg.KEY_WOW64_32KEY) as key:
            wanted = {name for name, value, kind in original['values']}
            for name, value, kind in (current or {}).get('values', []):
                if name not in wanted:
                    winreg.DeleteValue(key, name)
            for name, value, kind in original['values']:
                winreg.SetValueEx(key, name, 0, kind, value)
        for child in (current or {}).get('children', {}):
            if child not in original['children']:
                remove(path + '\\' + child)
        for child, content in original['children'].items():
            restore(path + '\\' + child, content)

    machine_paths = [r'Software\Microsoft\DirectPlay\Applications\Age Of Wonders',
                     r'Software\Classes\.hsm', r'Software\Classes\AOWMAP']
    def machine_snapshot():
        def read(path, view):
            try:
                with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, path, 0, winreg.KEY_READ | view) as key:
                    return {'values': [winreg.EnumValue(key, i) for i in range(winreg.QueryInfoKey(key)[1])],
                            'children': {winreg.EnumKey(key, i): read(path + '\\' + winreg.EnumKey(key, i), view)
                                         for i in range(winreg.QueryInfoKey(key)[0])}}
            except FileNotFoundError:
                return None
        return {str(view) + ':' + path: read(path, view) for view in
                (winreg.KEY_WOW64_32KEY, winreg.KEY_WOW64_64KEY) for path in machine_paths}
    machine_before = machine_snapshot()
    original = snapshot(key_path)
    (build / 'registry-before.json').write_text(json.dumps(original,
        default=lambda value: {'bytes_base64': base64.b64encode(value).decode()}, indent=2))
    user, kernel = ctypes.WinDLL('user32', use_last_error=True), ctypes.WinDLL('kernel32')
    user.CreateDesktopW.argtypes = [w.LPCWSTR, w.LPCWSTR, ctypes.c_void_p, w.DWORD, w.DWORD, ctypes.c_void_p]
    user.CreateDesktopW.restype = w.HANDLE
    user.GetProcessWindowStation.restype = w.HANDLE
    user.GetUserObjectInformationW.argtypes = [w.HANDLE, ctypes.c_int, ctypes.c_void_p,
                                             w.DWORD, ctypes.POINTER(w.DWORD)]
    user.CloseDesktop.argtypes = [w.HANDLE]
    station = ctypes.create_unicode_buffer(256)
    needed = w.DWORD()
    if not user.GetUserObjectInformationW(user.GetProcessWindowStation(), 2, station,
                                         ctypes.sizeof(station), ctypes.byref(needed)):
        raise ctypes.WinError(ctypes.get_last_error())
    if station.value.lower() != 'winsta0':
        raise RuntimeError('startup test requires WinSta0; found ' + station.value)
    name = r'WinSta0\AoWTest'
    desktop = user.CreateDesktopW('AoWTest', None, None, 0, 0x01ff, None)
    if not desktop:
        raise ctypes.WinError(ctypes.get_last_error())
    try:
        _TEST_DESKTOP, _TEST_DESKTOP_HANDLE = name, desktop
        yield
    finally:
        for process in list(_TEST_PROCESSES):
            try:
                process.terminate()
                process.wait(timeout=5)
            finally:
                process.close()
        _TEST_DESKTOP, _TEST_DESKTOP_HANDLE = None, None
        user.CloseDesktop(desktop)
        restore(key_path, original)
        restored = snapshot(key_path) == original
        machine_unchanged = machine_snapshot() == machine_before
        (build / 'test-isolation.json').write_text(json.dumps({
            'hidden_desktop': name, 'switched_input_desktop': False,
            'registry_key': 'HKCU\\' + key_path, 'registry_restored': restored,
            'machine_registry_unchanged': machine_unchanged}, indent=2))
        if not restored or not machine_unchanged:
            raise RuntimeError('game registry preservation check failed')


def smoke_test(build, target):
    with isolated_test_environment(build):
        _smoke_test(build, target)


def _smoke_test(build, target):
    """Check only the hidden desktop; stop all launches after the first failure."""
    from ctypes import wintypes as w
    user = ctypes.WinDLL('user32', use_last_error=True)
    user.PostMessageW.argtypes = [w.HWND, w.UINT, w.WPARAM, w.LPARAM]
    results = {}
    for name in PROGRAMS:
        started = time.monotonic()
        process = HiddenProcess(target / (name + '.exe'), target)
        visible = []
        try:
            history = []
            while time.monotonic() - started < 30:
                windows = window_list(process.pid)
                visible = [x for x in windows if x['visible']]
                errors = [x for x in visible if x['class'] == '#32770'
                          or x['class'].lower() in ('tmessageform', 'texceptiondialog')]
                if not history or history[-1]['windows'] != windows:
                    history.append({'seconds': round(time.monotonic() - started, 2), 'windows': windows})
                if process.poll() is not None or errors:
                    break
                time.sleep(0.25)
            windows = window_list(process.pid)
            visible = [x for x in windows if x['visible']]
            errors = [x for x in visible if x['class'] == '#32770'
                      or x['class'].lower() in ('tmessageform', 'texceptiondialog')]
            main = [x for x in visible if x['class'].lower() == 'tmainform']
            passed = process.poll() is None and bool(main) and not errors and time.monotonic() - started >= 30
            result = {'pid': process.pid, 'desktop': _TEST_DESKTOP,
                      'seconds': round(time.monotonic() - started, 2),
                      'exit_code': process.poll(), 'passed': passed, 'windows': windows, 'history': history}
            results[name] = result
            (build / 'startup.json').write_text(json.dumps(results, indent=2))
            print(name + ': ' + ('OK' if passed else 'ERROR') + ' startup ' +
                  json.dumps({'exit_code': result['exit_code'], 'desktop': _TEST_DESKTOP,
                              'windows': visible if not passed else
                                  [{k: v for k, v in item.items() if k != 'children'} for item in visible]}), flush=True)
        finally:
            for window in visible:
                user.PostMessageW(window['handle'], 0x10, 0, 0)
            try:
                process.wait(timeout=5)
            except subprocess.TimeoutExpired:
                process.terminate()
                process.wait(timeout=5)
            finally:
                process.close()
        if not passed:
            raise RuntimeError('hidden-desktop startup failed; stopping all launches; see ' + str(build / 'startup.json'))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    commands = parser.add_subparsers(dest='command', required=True)
    commands.add_parser('build').add_argument('directory', type=Path)
    commands.add_parser('verify').add_argument('directory', type=Path)
    install = commands.add_parser('install')
    install.add_argument('directory', type=Path)
    install.add_argument('game_copy', type=Path)
    smoke = commands.add_parser('test')
    smoke.add_argument('directory', type=Path)
    smoke.add_argument('game_copy', type=Path)
    args = parser.parse_args()
    try:
        if args.command == 'build':
            build_game(args.directory.resolve())
        elif args.command == 'verify':
            verify_exports(args.directory.resolve())
        elif args.command == 'install':
            install_game(args.directory.resolve(), args.game_copy.resolve())
        else:
            smoke_test(args.directory.resolve(), args.game_copy.resolve())
    except (OSError, RuntimeError, ValueError) as error:
        parser.exit(1, str(error) + '\n')


if __name__ == '__main__':
    main()
