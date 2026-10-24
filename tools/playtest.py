"""Deterministic original/rebuilt AoW runs, exclusively on WinSta0\\AoWTest.

All products, copies, saves and debugger transcripts live below the build directory.
The installed game is only read. After tools/buildgame.py build BUILD, run:
    tools/playtest.py BUILD prepare
    tools/playtest.py BUILD check checks-before
    tools/playtest.py BUILD suite small large underground --timeout 3600
prepare selects Mountain Clash (48x48, surface), After the Fall (127x127,
two levels), Mine All Mine (48x48, three levels), and Igor's Folly (96x96,
two levels), plus Love thy Neighbor (heroes), Rocky Hollow (magic), and Blood
Isles (water). The default seed is 123456789. Use seed-map --cpu 3 for harder AI.
editor VARIANT SCENARIO LABEL invokes File > Save on an unchanged map copy;
editor-compare LEFT RIGHT compares its exact bytes and asg_dump output.
run --coverage records native feature calls; --tactical selects the tactical
resolver and a local host identity in both variants for an all-CPU test.
--exercise-items uses the loaded item pool to equip each starting hero, move
equipment through inventory, swap rings, and use scrolls when available.
--global-spell researches a global enchantment and submits native casting inputs
on the caster's turn, including the AI start-casting method for CPU players.
Day 1 is the initialized state; day 21 follows twenty completed world turns.
Use --help for the individual operations. Runs are serial because the registry
paths belong to the user session; never launch two driver processes together.
"""
import argparse
import ast
import contextlib
import ctypes
from ctypes import wintypes as w
import difflib
import json
import os
from pathlib import Path
import re
import shutil
import struct
import subprocess
import sys
import time
import winreg
import zlib

sys.dont_write_bytecode = True
import buildgame

REPO = Path(__file__).resolve().parents[1]
CDB = Path(r'C:\Tools\cdb_x86\cdb.exe')
GAME_KEY = r'Software\Triumph Studios\Age of Wonders'
DP_KEY = (r'Software\Classes\VirtualStore\MACHINE\SOFTWARE\WOW6432Node'
          r'\Microsoft\DirectPlay\Applications\Age Of Wonders')
VIEW = winreg.KEY_WOW64_32KEY
SCENARIOS = {'small': 'Mountain Clash.hsm', 'large': 'After the Fall.HSM',
             'underground': 'Mine All Mine.hsm', 'large_igor': "Igor's Folly.hsm",
             'heroes': 'Love thy Neighbor.hsm', 'magic': 'Rocky Hollow.hsm',
             'water': 'Blood Isles.hsm'}


def reader_module():
    # asg_dump has an unconditional CLI entry point; load its definitions only.
    tree = ast.parse((REPO / 'tools/asg_dump.py').read_text())
    tree.body = [n for n in tree.body if not (isinstance(n, ast.Expr)
                 and isinstance(n.value, ast.Call)
                 and isinstance(n.value.func, ast.Name) and n.value.func.id == 'main')]
    module = type(sys)('asg_reader')
    exec(compile(tree, str(REPO / 'tools/asg_dump.py'), 'exec'), module.__dict__)
    return module


ASG = reader_module()


def inflate(path):
    raw = Path(path).read_bytes()
    return zlib.decompress(raw[5:]) if raw[:4] == b'CFS\0' else raw


def table(data, at):
    entries, base = ASG.Reader(data).table(at)
    return {pid: base + off for pid, off in entries}


def root(data):
    return table(data, struct.unpack_from('<i', data)[0])[0]


def map_info(path):
    data = inflate(path)
    props = table(data, root(data))
    kids = table(data, props[1])
    container = next(at + 4 for at in kids.values()
                     if struct.unpack_from('<I', data, at)[0] == 0x10103)
    cp = table(data, container)
    return {'file': str(path), 'width': data[cp[3]], 'height': data[cp[4]],
            'levels': data[cp[5]], 'day': struct.unpack_from('<i', data, props[0x13])[0] if 0x13 in props else 0,
            'name': ASG.Reader(data).string(props[0x19]) if 0x19 in props else path.stem}


def unpack_table(blob):
    entries, base = ASG.Reader(blob).table(0)
    offsets = sorted({off for pid, off in entries} | {len(blob) - base})
    return {pid: blob[base + off:base + offsets[offsets.index(off) + 1]]
            for pid, off in entries}


def pack_table(items):
    header = b'\x80' + struct.pack('<i', len(items))
    body = bytearray()
    for pid, blob in items.items():
        header += struct.pack('<ii', pid, len(body))
        body += blob
    return header + body


def seed_map(path, target, seed, simultaneous=False, cpu=1):
    data = inflate(path)
    header = struct.unpack_from('<i', data)[0]
    top = unpack_table(data[header:])
    props = unpack_table(top[0])
    players = unpack_table(props[0x15])
    kids = unpack_table(players[1])
    for pid, blob in kids.items():
        player = unpack_table(blob[4:])
        if pid != 0:
            player[3] = bytes([cpu])  # independent player stays independent.
        kids[pid] = blob[:4] + pack_table(player)
    players[1] = pack_table(kids)
    props[0x15] = pack_table(players)
    props[0x1c] = props[0x24] = struct.pack('<I', seed)
    props[0x27] = bytes([2 if simultaneous else 1])
    top[0] = pack_table(props)
    target.parent.mkdir(parents=True, exist_ok=True)
    target.write_bytes(b'CFS\0\x02' + zlib.compress(data[:header] + pack_table(top)))
    print('Prepared', target, map_info(target), flush=True)


def registry_snapshot(path):
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, path, 0, winreg.KEY_READ | VIEW) as key:
            return {'values': [winreg.EnumValue(key, i) for i in range(winreg.QueryInfoKey(key)[1])],
                    'children': {winreg.EnumKey(key, i): registry_snapshot(path + '\\' + winreg.EnumKey(key, i))
                                 for i in range(winreg.QueryInfoKey(key)[0])}}
    except FileNotFoundError:
        return None


def registry_restore(path, saved):
    current = registry_snapshot(path)
    if current == saved:
        return
    for name in (current or {}).get('children', {}):
        if saved is None or name not in saved['children']:
            registry_restore(path + '\\' + name, None)
    if saved is None:
        if current is not None:
            winreg.DeleteKeyEx(winreg.HKEY_CURRENT_USER, path, VIEW)
        return
    with winreg.CreateKeyEx(winreg.HKEY_CURRENT_USER, path, 0, winreg.KEY_WRITE | VIEW) as key:
        wanted = {name for name, value, kind in saved['values']}
        for name, value, kind in (current or {}).get('values', []):
            if name not in wanted:
                winreg.DeleteValue(key, name)
        for name, value, kind in saved['values']:
            winreg.SetValueEx(key, name, 0, kind, value)
    for name, child in saved['children'].items():
        registry_restore(path + '\\' + name, child)


@contextlib.contextmanager
def environment(copy, output):
    """Snapshot before mutation; restore even when launching or debugging fails."""
    user = ctypes.WinDLL('user32', use_last_error=True)
    user.GetProcessWindowStation.restype = w.HANDLE
    user.GetUserObjectInformationW.argtypes = [w.HANDLE, ctypes.c_int, ctypes.c_void_p,
                                             w.DWORD, ctypes.POINTER(w.DWORD)]
    name, needed = ctypes.create_unicode_buffer(256), w.DWORD()
    if not user.GetUserObjectInformationW(user.GetProcessWindowStation(), 2, name,
                                         ctypes.sizeof(name), ctypes.byref(needed)):
        raise ctypes.WinError(ctypes.get_last_error())
    if name.value.lower() != 'winsta0':
        raise RuntimeError('requires the user session (WinSta0), found ' + name.value)
    with winreg.OpenKey(winreg.HKEY_CURRENT_USER, GAME_KEY + r'\Video', 0, winreg.KEY_READ | VIEW) as key:
        if winreg.QueryValueEx(key, 'Display Mode')[0] != 0:
            raise RuntimeError('the existing game settings must select windowed mode')
        if winreg.QueryValueEx(key, 'Allow Resolution Switches')[0] != 0:
            raise RuntimeError('the existing game settings must disable resolution switches')
    saved = {key: registry_snapshot(key) for key in (GAME_KEY, DP_KEY)}
    output.mkdir(parents=True, exist_ok=True)
    (output / 'registry-before.json').write_text(json.dumps(saved, indent=2,
        default=lambda b: {'hex': b.hex()}))
    user.CreateDesktopW.argtypes = [w.LPCWSTR, w.LPCWSTR, ctypes.c_void_p, w.DWORD, w.DWORD, ctypes.c_void_p]
    user.CreateDesktopW.restype = w.HANDLE
    user.CloseDesktop.argtypes = [w.HANDLE]
    desktop = user.CreateDesktopW('AoWTest', None, None, 0, 0x1ff, None)
    if not desktop:
        raise ctypes.WinError(ctypes.get_last_error())
    buildgame._TEST_DESKTOP, buildgame._TEST_DESKTOP_HANDLE = r'WinSta0\AoWTest', desktop
    try:
        with winreg.OpenKey(winreg.HKEY_CURRENT_USER, GAME_KEY + r'\General', 0, winreg.KEY_SET_VALUE | VIEW) as key:
            for value in ('Root Directory', 'Startup Directory'):
                winreg.SetValueEx(key, value, 0, winreg.REG_SZ, str(copy.resolve()) + '\\')
        yield
    finally:
        for process in list(buildgame._TEST_PROCESSES):
            try:
                process.terminate()
                process.wait(timeout=5)
            finally:
                process.close()
        buildgame._TEST_DESKTOP, buildgame._TEST_DESKTOP_HANDLE = None, None
        user.CloseDesktop(desktop)
        for key, before in saved.items():
            registry_restore(key, before)
        restored = all(registry_snapshot(key) == before for key, before in saved.items())
        (output / 'isolation.json').write_text(json.dumps({'desktop': r'WinSta0\AoWTest',
            'registry_restored': restored, 'switched_desktop': False, 'changed_display_mode': False}, indent=2))
        if not restored:
            raise RuntimeError('registry restoration failed')


class Debugger:
    """CDB with a private stdin pipe, file transcript and kill-on-close job."""
    def __init__(self, copy, output, arguments=(), commands=''):
        import msvcrt
        kernel = self.kernel = ctypes.WinDLL('kernel32', use_last_error=True)
        class SA(ctypes.Structure):
            _fields_ = [('size', w.DWORD), ('descriptor', ctypes.c_void_p), ('inherit', w.BOOL)]
        class SI(ctypes.Structure):
            _fields_ = [('cb', w.DWORD), ('reserved', w.LPWSTR), ('desktop', w.LPWSTR),
                        ('title', w.LPWSTR), ('x', w.DWORD), ('y', w.DWORD),
                        ('width', w.DWORD), ('height', w.DWORD), ('chars_x', w.DWORD),
                        ('chars_y', w.DWORD), ('fill', w.DWORD), ('flags', w.DWORD),
                        ('show', w.WORD), ('reserved_size', w.WORD),
                        ('reserved_bytes', ctypes.c_void_p), ('stdin', w.HANDLE),
                        ('stdout', w.HANDLE), ('stderr', w.HANDLE)]
        class PI(ctypes.Structure):
            _fields_ = [('process', w.HANDLE), ('thread', w.HANDLE), ('pid', w.DWORD), ('tid', w.DWORD)]
        kernel.CreatePipe.argtypes = [ctypes.POINTER(w.HANDLE), ctypes.POINTER(w.HANDLE), ctypes.POINTER(SA), w.DWORD]
        kernel.SetHandleInformation.argtypes = [w.HANDLE, w.DWORD, w.DWORD]
        kernel.CreateProcessW.argtypes = [w.LPCWSTR, w.LPWSTR, ctypes.c_void_p, ctypes.c_void_p,
            w.BOOL, w.DWORD, ctypes.c_void_p, w.LPCWSTR, ctypes.POINTER(SI), ctypes.POINTER(PI)]
        kernel.CreateJobObjectW.argtypes = [ctypes.c_void_p, w.LPCWSTR]
        kernel.CreateJobObjectW.restype = w.HANDLE
        kernel.SetInformationJobObject.argtypes = [w.HANDLE, ctypes.c_int, ctypes.c_void_p, w.DWORD]
        kernel.AssignProcessToJobObject.argtypes = [w.HANDLE, w.HANDLE]
        kernel.TerminateJobObject.argtypes = [w.HANDLE, w.UINT]
        kernel.CloseHandle.argtypes = [w.HANDLE]
        kernel.ResumeThread.argtypes = [w.HANDLE]
        kernel.ResumeThread.restype = w.DWORD
        kernel.TerminateProcess.argtypes = [w.HANDLE, w.UINT]
        kernel.WaitForSingleObject.argtypes = [w.HANDLE, w.DWORD]
        kernel.GetExitCodeProcess.argtypes = [w.HANDLE, ctypes.POINTER(w.DWORD)]
        kernel.WriteFile.argtypes = [w.HANDLE, ctypes.c_void_p, w.DWORD, ctypes.POINTER(w.DWORD), ctypes.c_void_p]
        self.transcript = output / 'cdb.log'
        self.output = output
        self.file = self.transcript.open('wb', buffering=0)
        oh = msvcrt.get_osfhandle(self.file.fileno())
        os.set_handle_inheritable(oh, True)
        read, self.input = w.HANDLE(), w.HANDLE()
        self.job, self.handle = None, None
        info = PI()
        security = SA(ctypes.sizeof(SA), None, True)
        try:
            if not kernel.CreatePipe(ctypes.byref(read), ctypes.byref(self.input), ctypes.byref(security), 0):
                raise ctypes.WinError(ctypes.get_last_error())
            if not kernel.SetHandleInformation(self.input, 1, 0):
                raise ctypes.WinError(ctypes.get_last_error())
            self.job = kernel.CreateJobObjectW(None, None)
            if not self.job:
                raise ctypes.WinError(ctypes.get_last_error())
            limits = ctypes.create_string_buffer(144)
            struct.pack_into('<I', limits, 16, 0x2000)  # JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
            if not kernel.SetInformationJobObject(self.job, 9, limits, len(limits)):
                raise ctypes.WinError(ctypes.get_last_error())
            script = output / 'startup.cdb'
            script.write_text(commands + '\n')
            command = ctypes.create_unicode_buffer(subprocess.list2cmdline(
                [str(CDB), '-y', str(copy), '-o', '-cf', str(script), str(copy / 'AoW.exe'), *map(str, arguments)]))
            startup = SI()
            startup.cb, startup.desktop = ctypes.sizeof(startup), r'WinSta0\AoWTest'
            startup.flags, startup.stdin, startup.stdout, startup.stderr = 0x101, read, oh, oh
            startup.show = 0
            if not kernel.CreateProcessW(str(CDB), command, None, None, True, 4 | 0x08000000,
                                         None, str(copy), ctypes.byref(startup), ctypes.byref(info)):
                raise ctypes.WinError(ctypes.get_last_error())
            self.handle, self.pid = info.process, info.pid
            if not kernel.AssignProcessToJobObject(self.job, self.handle):
                raise ctypes.WinError(ctypes.get_last_error())
            if kernel.ResumeThread(info.thread) == 0xffffffff:
                raise ctypes.WinError(ctypes.get_last_error())
        except BaseException:
            if self.handle:
                # Assignment can fail while CDB is still suspended and outside
                # the job; terminate that process explicitly as well.
                kernel.TerminateProcess(self.handle, 1)
                kernel.WaitForSingleObject(self.handle, 5000)
            for handle in (self.input, self.handle, self.job):
                if handle:
                    kernel.CloseHandle(handle)
            self.file.close()
            raise
        finally:
            for handle in (info.thread, read):
                if handle:
                    kernel.CloseHandle(handle)

    def send(self, command):
        data = (command + '\r\n').encode('ascii')
        written = w.DWORD()
        if not self.kernel.WriteFile(self.input, data, len(data), ctypes.byref(written), None):
            raise ctypes.WinError(ctypes.get_last_error())

    def text(self):
        return self.transcript.read_text(encoding='cp1252', errors='replace')

    def poll(self):
        code = w.DWORD()
        self.kernel.GetExitCodeProcess(self.handle, ctypes.byref(code))
        return None if code.value == 259 else code.value

    def wait_stop(self, offset=0, timeout=120):
        deadline = min(time.monotonic() + timeout, getattr(self, 'deadline', float('inf')))
        while time.monotonic() < deadline:
            text = self.text()[offset:]
            if re.search(r'(?:^|\s)\d+:\d+>\s*$', text):
                # Auto-continuing breakpoint commands can briefly print a prompt.
                # Accept it only after the transcript has settled.
                time.sleep(.15)
                if self.text()[offset:] == text:
                    return text
            if self.poll() is not None:
                raise RuntimeError('debugger exited: ' + text[-3000:])
            time.sleep(.05)
        raise TimeoutError('debugger did not stop: ' + self.text()[-3000:])

    def command(self, command, timeout=120):
        offset = len(self.text())
        self.send(command)
        return self.wait_stop(offset, timeout)

    def close(self):
        self.kernel.TerminateJobObject(self.job, 1)
        self.kernel.WaitForSingleObject.argtypes = [w.HANDLE, w.DWORD]
        self.kernel.WaitForSingleObject(self.handle, 5000)
        self.kernel.QueryInformationJobObject.argtypes = [w.HANDLE, ctypes.c_int, ctypes.c_void_p,
                                                        w.DWORD, ctypes.POINTER(w.DWORD)]
        accounting, needed = ctypes.create_string_buffer(48), w.DWORD()
        deadline = time.monotonic() + 5
        while time.monotonic() < deadline:
            if not self.kernel.QueryInformationJobObject(self.job, 1, accounting, len(accounting), ctypes.byref(needed)):
                raise ctypes.WinError(ctypes.get_last_error())
            if struct.unpack_from('<I', accounting, 40)[0] == 0:
                break
            time.sleep(.05)
        else:
            raise RuntimeError('test processes did not terminate')
        (self.output / 'processes.json').write_text(json.dumps(
            {'cdb_pid': self.pid, 'active_processes_after_termination': 0}, indent=2))
        for handle in (self.input, self.handle, self.job):
            self.kernel.CloseHandle(handle)
        self.file.close()


def original_address(module, name):
    functions = json.loads((REPO / 'data/signatures' / (module + '.json')).read_text())
    return int(next(f['addr'] for f in functions if f['name'].split('@')[0] == name), 16)


def inventory(build):
    for path in sorted((buildgame.GAME / 'Scenario/Custom').glob('*.hsm')):
        print(json.dumps(map_info(path)))


def prepare(build):
    original, rebuilt = build / 'original', build / 'rebuilt'
    shutil.copytree(buildgame.GAME, original, dirs_exist_ok=True)
    buildgame.install_game(build, rebuilt)
    for name, filename in SCENARIOS.items():
        seed_map(original / 'Scenario/Custom' / filename,
                 build / 'inputs' / (name + '.asg'), 123456789)
    print('Original and rebuilt copies ready', flush=True)


def seed_commands(seed):
    return ('sxi e06d7363; sxe av; sxe eedfade; '
            'ed vcl30+e3044 %x; bp vcl30+30a0 "ed vcl30+e3044 %x; '
            'r eip=poi(@esp); r esp=@esp+4; gc"; ' % (seed, seed))


def expression(build, variant, module, name):
    if variant == 'original':
        with buildgame.pefile.PE(str(build / variant / module), fast_load=True) as pe:
            rva = original_address(module, name) - pe.OPTIONAL_HEADER.ImageBase
    else:
        symbol = '.'.join(name.split('.')[1:])
        mapping = (build / module).with_suffix('.map').read_text()
        matches = sorted(set(re.findall(r'^\s+0001:([0-9A-F]+)\s+' + re.escape(symbol) + r'\s*$', mapping, re.M)))
        if len(matches) != 1:
            raise RuntimeError('cannot find map symbol ' + name)
        rva = 0x1000 + int(matches[0], 16)
    return Path(module).stem + '+%x' % rva


def registers(text):
    result = {k: int(v, 16) for k, v in re.findall(
        r'\b(eax|ebx|ecx|edx|esi|edi|eip|esp|ebp|efl)=([0-9a-f]{8})', text, re.I)}
    if len(result) != 10:
        raise RuntimeError('incomplete register dump: ' + text[-3000:])
    return result


def module_bases(text):
    bases = {}
    for address, name in re.findall(r'^([0-9a-f]{8})\s+[0-9a-f]{8}\s+(\S+)\s+', text, re.I | re.M):
        base, name = int(address, 16), name.lower()
        prefix, separator, suffix = name.rpartition('_')
        if separator and re.fullmatch(r'[0-9a-f]+', suffix) and int(suffix, 16) == base:
            name = prefix
        bases[name] = base
    return bases


def run_game(build, variant, save, label, turns=20, seed=123456789, timeout=3600, initial_only=False, tactical=False, coverage=False, tactical_battles=0, exercise_items=False, global_spell=0):
    if not re.fullmatch(r'[A-Za-z0-9_-]+', label):
        raise ValueError('run label must contain only letters, digits, underscores and hyphens')
    if not save.resolve().is_relative_to(build):
        raise ValueError('run input must be a prepared save below the build directory')
    copy = build / variant
    output = build / 'playtest' / label
    if output.exists():
        raise ValueError('run label already exists: ' + label)
    newday = expression(build, variant, 'AoWEPACK.dpl', 'AoWE.TPlayerControl.NewDay')
    autosave = expression(build, variant, 'AoWEPACK.dpl', 'AoWE.TPlayerControl.AutoSave')
    gameend = expression(build, variant, 'AoWEPACK.dpl', 'AoWE.TAoWHSMap.TriggerGameTerminatedEvent')
    commands = seed_commands(seed) + (
        'bp vcl30+3fe4 "da poi(@eax+4); kb; .echo PT_EXCEPTION"; '
        '.dvalloc 1000; bp ' + newday + ' ".echo PT_DAY"; bp ' + gameend + ' ".echo PT_END"; g')
    if tactical:
        # Select the native tactical resolver at the same combat boundary in
        # both copies; all players remain CPU controlled. No game code changes.
        select = 'eb @eax+39 2; .echo PT_FEATURE tactical_selected'
        if tactical_battles:
            select = '.if (@$t19 < %x) { r @$t19=@$t19+1; ' % tactical_battles + select + ' }'
        commands = commands[:-1] + 'r @$t19=0; bp ' + expression(build, variant, 'AoWEPACK.dpl',
            'AoWE.TArmyCombatMoveTE.ExecuteCombat') + ' "' + select + '; gc"; g'
        # The stock tactical initializer selects a human as host, leaving -1
        # in all-CPU games. Supply the local independent player's PCC identity
        # as the host input, preserving CPU control of every combatant.
        commands = commands[:-1] + 'bp ' + expression(build, variant, 'AoWTCPCK.dpl',
            'AoWTC.TTacticalCombat.Execute') + ' "eb @eax+4c 0; .echo PT_FEATURE tactical_host; gc"; g'
    if coverage:
        features = [('hero_spell', 'AoWEPACK.dpl', 'AoWE.THero.CastSpell'),
                    ('spell_event', 'AoWEPACK.dpl', 'AoWE.TSpellTE.Execute'),
                    ('hero_item_place', 'AoWEPACK.dpl', 'AoWE.THero.ExecutePlaceItem'),
                    ('item_equipped', 'AoWEPACK.dpl', 'AoWE.THeroItems.PlaceItem'),
                    ('item_action', 'AoWEPACK.dpl', 'AoWE.TItemTE.Execute'),
                    ('item_use', 'AoWEPACK.dpl', 'AoWE.TItem.ExecuteUse'),
                    ('global_cast', 'AoWEPACK.dpl', 'AoWE.TGlobalEnchantment.Cast'),
                    ('combat', 'AoWEPACK.dpl', 'AoWE.TArmyCombatMoveTE.ExecuteCombat'),
                    ('tactical_ai', 'AoWTCPCK.dpl', 'AoWTC.TCAI.BeginTurn')]
        for feature, module, name in features:
            # The tactical selector already owns the ExecuteCombat breakpoint.
            if tactical and feature == 'combat':
                continue
            commands = commands[:-1] + 'bp ' + expression(build, variant, module, name) + (
                ' ".echo PT_FEATURE ' + feature + '; gc"; g')
    started, collected = time.monotonic(), []
    status = {'variant': variant, 'input': str(save), 'seed': seed,
              'input_sha256': buildgame.digest(save),
              'modules': {p.name: buildgame.digest(p) for p in sorted(copy.iterdir())
                          if p.suffix.lower() in ('.exe', '.dpl', '.dll')},
              'requested_turns': turns, 'tactical': tactical, 'tactical_battles': tactical_battles, 'coverage_enabled': coverage,
              'exercise_items': exercise_items, 'global_spell': global_spell, 'saves': collected, 'complete': False}
    try:
        with environment(copy, output):
            debugger = Debugger(copy, output, [save], 'lm')
            debugger.deadline = started + timeout
            try:
                modules = debugger.wait_stop(timeout=timeout)
                bases = module_bases(modules)
                if not {'vcl30', 'aowepack'} <= bases.keys():
                    bases = module_bases(debugger.command('lm', timeout))
                def resolve(text):
                    return re.sub(r'\b(vcl30|AoWEPACK|AoWTCPCK)\+',
                                  lambda m: '%x+' % bases[m[1].lower()], text, flags=re.I)
                commands, autosave = resolve(commands), resolve(autosave)
                (output / 'run-commands.cdb').write_text(commands + '\n')
                (output / 'modules.json').write_text(json.dumps(bases, indent=2))
                stopped = debugger.command(commands, timeout)
                scratch = int(re.findall(r'Allocated .*? starting at ([0-9a-f]+)', debugger.text(), re.I)[0], 16)
                debugger.command('eb %x cc' % scratch)
                control = None
                while time.monotonic() - started < timeout:
                    if re.search(r'\bPT_GLOBAL_TURN\s*$', stopped, re.M):
                        status['global_exercise'] = cast_test_global(build, variant, save, debugger, scratch, resolve, timeout, global_spell, status['global_exercise'])
                        stopped = debugger.command('g', timeout)
                        continue
                    ended = bool(re.search(r'\bPT_END\s*$', stopped, re.M))
                    if not ended and not re.search(r'\bPT_DAY\s*$', stopped, re.M):
                        raise RuntimeError('unexpected game stop: ' + stopped[-3500:] + debugger.command('.lastevent; kb; dds @esp L20'))
                    entry = registers(debugger.command('r'))
                    if not ended:
                        control = entry['eax']
                        stopped = debugger.command('gu', timeout) if not initial_only else stopped
                        if 'PT_EXCEPTION' in stopped or 'Access violation' in stopped:
                            raise RuntimeError('exception during NewDay: ' + stopped[-3500:])
                    if control is None:
                        raise RuntimeError('game ended before the first day')
                    if exercise_items and not collected:
                        status['item_exercise'] = equip_test_items(build, variant, save, debugger, scratch, resolve, timeout)
                    if global_spell and not collected:
                        status['global_exercise'] = cast_test_global(build, variant, save, debugger, scratch, resolve, timeout, global_spell, status.get('global_exercise'))
                        # Submit further requests only on the caster's own turn;
                        # native spell validation rejects off-turn activation.
                        map_pointer = resolve(export_expression(copy, 'AoWEPACK.dpl', 'AoWE.AoWHSMap'))
                        ai_process = resolve(expression(build, variant, 'AoWEPACK.dpl', 'AoWE.TAIPlayerControl.Process'))
                        debugger.command('r @$t18=0; bp %s ".if ((@$t18 != 0) & (by(poi(%s)+a4)==%x)) { r @$t18=0; .echo PT_GLOBAL_TURN } .else { gc }"' %
                                         (ai_process, map_pointer, status['global_exercise']['player']))
                    context = registers(debugger.command('r'))
                    # Call the game's unmodified AutoSave with Delphi's register ABI.
                    # The scratch INT3 is its return address. Restore the entire CPU
                    # context before continuing the day-boundary caller.
                    stopped = debugger.command('ed %x %x; r esp=%x; r eax=%x; r eip=%s; g' %
                        (context['esp'] - 4, scratch, context['esp'] - 4, control, autosave), timeout)
                    returned = registers(debugger.command('r'))
                    if returned['eip'] not in (scratch, scratch + 1):
                        raise RuntimeError('save did not return: ' + stopped[-3500:])
                    path = copy / 'Save/autosave.asg'
                    info = map_info(path)
                    day = info['day']
                    if collected and not ended and day != collected[-1]['day'] + 1:
                        raise RuntimeError('missed or repeated world-day boundary: %s -> %s' %
                                           (collected[-1]['day'], day))
                    destination = output / (('final-day-' if ended else 'day-') + '%02d.asg' % day)
                    shutil.copy2(path, destination)
                    collected.append({'day': day, 'file': destination.name,
                                      'bytes': destination.stat().st_size,
                                      'seconds': round(time.monotonic() - started, 2)})
                    print('%s: saved day %d (%.1fs)' % (label, day, time.monotonic() - started), flush=True)
                    (output / 'run.json').write_text(json.dumps(status, indent=2))
                    if initial_only or ended or len(collected) >= turns + 1:
                        status['complete'] = True
                        status['game_ended'] = ended
                        break
                    restore = '; '.join('r %s=%x' % item for item in context.items())
                    if global_spell:
                        restore += '; r @$t18=1'
                    stopped = debugger.command(restore + '; g', timeout)
                else:
                    raise TimeoutError('run exceeded time limit')
            finally:
                status['coverage'] = {feature: len(re.findall(r'(?:^|> )PT_FEATURE ' + feature + r'\s*$', debugger.text(), re.M))
                                      for feature in re.findall(r'(?:^|> )PT_FEATURE (\w+)\s*$', debugger.text(), re.M)}
                debugger.close()
    except Exception as exc:
        status['error'] = str(exc)
        raise
    finally:
        status['seconds'] = round(time.monotonic() - started, 2)
        if output.exists():
            (output / 'run.json').write_text(json.dumps(status, indent=2))
    return status



def export_expression(copy, module, name):
    with buildgame.pefile.PE(str(copy / module)) as pe:
        addresses = [e.address for e in pe.DIRECTORY_ENTRY_EXPORT.symbols
                     if e.name and e.name.decode().rsplit('@', 1)[0] == name]
    if len(addresses) != 1:
        raise ValueError('expected one export for ' + name)
    return Path(module).stem + '+%x' % addresses[0]


def native_input_helpers(build, variant, debugger, scratch, resolve, timeout):
    def value(expr):
        reply = debugger.command('.printf "PT_VALUE %x\\n", ' + expr)
        found = re.search(r'PT_VALUE ([0-9a-f]+)', reply, re.I)
        if not found:
            raise RuntimeError('cannot read native value: ' + reply)
        return int(found[1], 16)
    def call(name, self, edx=0, ecx=0, stack=(), entry=None):
        saved = registers(debugger.command('r'))
        sp = saved['esp'] - 4 * (1 + len(stack))
        words = ' '.join('%x' % x for x in (scratch, *stack))
        if entry is None:
            entry = resolve(expression(build, variant, 'AoWEPACK.dpl', name))
        reply = debugger.command('ed %x %s; r esp=%x; r eax=%x; r edx=%x; r ecx=%x; r eip=%s; g' %
                                 (sp, words, sp, self, edx, ecx, entry), timeout)
        result = registers(debugger.command('r'))
        if result['eip'] not in (scratch, scratch + 1) or result['esp'] != saved['esp']:
            raise RuntimeError('native input did not return from ' + name + ': ' + reply[-3000:])
        debugger.command('; '.join('r %s=%x' % item for item in saved.items()))
        return result['eax']
    return value, call


def equip_test_items(build, variant, save, debugger, scratch, resolve, timeout):
    """Directed native inputs: generate, equip, store, and re-equip map items.

    Uses the same Delphi register ABI and scratch-return technique as AutoSave.
    Item data comes from the loaded scenario's own item pool. No code is patched.
    """
    value, call = native_input_helpers(build, variant, debugger, scratch, resolve, timeout)
    map_expr = resolve(export_expression(build / variant, 'AoWEPACK.dpl', 'AoWE.AoWHSMap'))
    game = value('poi(' + map_expr + ')')
    players, items = value('poi(%x+140)' % game), value('poi(%x+f4)' % game)
    data = inflate(save)
    props = table(data, root(data))
    indices = sorted(table(data, table(data, props[0x15])[1]))
    actions = []
    for index in indices:
        if index == 0:
            continue
        player = call('AoWE.TPlayerList.GetPlayers', players, index)
        hero = value('poi(%x+d4)' % player)
        if not hero:
            continue
        first_ring = None
        # The standard seven item types cover five equipment types and two
        # consumable types; a second ring also exercises inventory placement.
        for kind in (0, 1, 2, 3, 4, 4, 5, 6):
            item = call('AoWE.TItemControl.GenerateItem', items, 1 << kind, 1, (100000,))
            if not item:
                actions.append({'player': index, 'type': kind, 'available': False})
                continue
            item_id = value('poi(%x+14)' % item)
            placed = bool(call('AoWE.THero.AutoPlaceItem', hero, item) & 255)
            action = {'player': index, 'type': kind, 'item_id': item_id, 'placed': placed}
            if placed and kind <= 3:
                action['stored'] = bool(call('AoWE.THero.ExecutePlaceItem', hero, item_id, 6) & 255)
                action['reequipped'] = bool(call('AoWE.THero.AutoPlaceItem', hero, item) & 255)
            if placed and kind == 4:
                if first_ring is None:
                    first_ring = item_id
                else:
                    action['swapped'] = bool(call('AoWE.THero.ExecuteSwapItem', hero, first_ring, item_id) & 255)
            if placed and kind == 5:
                action['use_queued'] = bool(call('AoWE.TItem.Use', item, hero) & 255)
                if not action['use_queued']:
                    action['use_executed'] = bool(call('AoWE.TItem.ExecuteUse', item, hero) & 255)
                    action['consumed'] = call('AoWE.TItemControl.FindItem', items, item_id) == 0
            actions.append(action)
    print('Native item exercise: %d generated, %d placed' %
          (sum('item_id' in a for a in actions), sum(a.get('placed', False) for a in actions)), flush=True)
    return actions



def cast_test_global(build, variant, save, debugger, scratch, resolve, timeout, spell_id, previous):
    """A directed research/cast input, repeated on the caster's turn until ready.

    Choose the highest-level starting leader. Research and casting use the native
    game methods, including mana, casting progress, and token-event validation.
    """
    value, call = native_input_helpers(build, variant, debugger, scratch, resolve, timeout)
    game = value('poi(' + resolve(export_expression(build / variant, 'AoWEPACK.dpl', 'AoWE.AoWHSMap')) + ')')
    players = value('poi(%x+140)' % game)
    state = previous or {'spell_id': spell_id, 'requests': []}
    if previous is None:
        data = inflate(save)
        indices = sorted(table(data, table(data, table(data, root(data))[0x15])[1]))
        candidates = []
        for index in indices:
            if index == 0:
                continue
            player = call('AoWE.TPlayerList.GetPlayers', players, index)
            hero = value('poi(%x+d4)' % player)
            if hero:
                candidates.append((value('by(%x+4c)' % hero), index))
        state['level'], state['player'] = max(candidates)
    player = call('AoWE.TPlayerList.GetPlayers', players, state['player'])
    hero = value('poi(%x+d4)' % player)
    if not hero or value('by(%x+55)' % hero) & 1:
        state['requests'].append({'dead': True})
        return state
    if previous is None:
        magic = value('poi(%x+54)' % player)
        call('AoWE.TPlayerMagicControl.ExecuteSpellResearched', magic, spell_id)
    reason = scratch + 0x100
    debugger.command('ed %x 0' % reason)
    before = value('poi(%x+84)' % hero)
    required = value('poi(%x+8c)' % hero)
    accepted = bool(call('AoWE.THero.CastSpell', hero, spell_id, reason) & 255)
    has_reason = bool(value('poi(%x)' % reason))
    started = False
    if not accepted and not has_reason and before == 0:
        # CPU players are busy; use the same start-casting method the AI uses.
        started = bool(call('AoWE.THero.ExecuteStartCasting', hero, spell_id) & 255)
    if has_reason:
        debugger.command('da poi(%x)' % reason)
    clear = resolve(export_expression(build / variant, 'vcl30.dpl', 'System.@LStrClr'))
    call('System.@LStrClr', reason, entry=clear)
    request = {'accepted': accepted, 'started': started, 'reason': has_reason,
               'player_busy': bool(call('AoWE.TPlayer.GetBusy', player) & 255),
               'current_player': value('by(%x+a4)' % game),
               'casting_points': value('by(%x+80)' % hero),
               'casting_max': call('AoWE.THero.GetCastingPointsMax', hero),
               'casting_before': before, 'required_before': required,
               'casting_after': value('poi(%x+84)' % hero),
               'required_after': value('poi(%x+8c)' % hero),
               'casting_mana': value('poi(%x+88)' % hero)}
    state['requests'].append(request)
    print('Native global input player %d spell %d: %s' %
          (state['player'], spell_id, request), flush=True)
    return state


def normalized_save(path):
    data = inflate(path)
    header = struct.unpack_from('<i', data)[0]
    top = unpack_table(data[header:])
    props = unpack_table(top[0])
    # These two counters are wall-clock turn timer bookkeeping, not the turn
    # limit or game day. Their identities come from TAoWHSMap.ReadWrite.
    for pid in (0x37, 0x3a):
        props.pop(pid, None)
    top[0] = pack_table(props)
    return data[:header] + pack_table(top)


def dump_save(path, output, decomp):
    with output.open('w', encoding='utf-8') as stream:
        result = subprocess.run([sys.executable, str(REPO / 'tools/asg_dump.py'), str(path),
            str(REPO / 'data/classes.json'), str(decomp), '--depth', '256'],
            stdout=stream, stderr=subprocess.PIPE, text=True)
    if result.returncode:
        raise RuntimeError('asg_dump failed: ' + result.stderr)


def state_fields(path, decomp, ignore_timers=True):
    """Lossless leaf paths to locate a binary difference, alongside asg_dump."""
    classes = json.loads((REPO / 'data/classes.json').read_text())['classes']
    ids = {}
    for directory in decomp.split(';'):
        if Path(directory).is_dir():
            ids.update(ASG.classid_map(directory))
    values = {}

    def walk(blob, cls, prefix, depth=0):
        if depth > 128:
            values[prefix] = blob.hex()
            return
        try:
            props = unpack_table(blob)
        except (ValueError, IndexError, struct.error):
            values[prefix] = blob.hex()
            return
        schema = ASG.schema_for(classes, cls)
        for pid, value in props.items():
            name, rw, size, typ, owner = schema.get(pid, ('id%d' % pid, '', 0, '', cls))
            key = prefix + '/' + name + '[%d]' % pid
            if ignore_timers and cls == 'TAoWHSMap' and pid in (0x37, 0x3a):
                continue
            try:
                if rw == 'rwChildren':
                    for index, child in unpack_table(value).items():
                        cid = struct.unpack_from('<I', child)[0]
                        sub = ids.get(cid, 'classid_%x' % cid)
                        walk(child[4:], sub, key + '/%d:%s' % (index, sub), depth + 1)
                    continue
                if rw == 'fieldstream':
                    at, index = 0, 0
                    while at < len(value):
                        length = struct.unpack_from('<I', value, at)[0]
                        if length == 0 or at + 4 + length > len(value):
                            raise ValueError('invalid field record')
                        walk(value[at + 4:at + 4 + length], 'TAoWMapField', key + '/%d' % index, depth + 1)
                        at, index = at + 4 + length, index + 1
                    continue
                if rw == 'rwEObject' and typ in classes:
                    walk(value, typ, key + ':' + typ, depth + 1)
                    continue
                cid = struct.unpack_from('<I', value)[0] if len(value) >= 4 else 0
                if cid in ids and (rw == 'rwCreateEObject' or pid not in schema):
                    walk(value[4:], ids[cid], key + ':' + ids[cid], depth + 1)
                    continue
            except (ValueError, IndexError, struct.error):
                pass
            values[key] = value.hex()

    data = inflate(path)
    walk(data[root(data):], 'TAoWHSMap', 'TAoWHSMap')
    return values


def compare_runs(build, left, right):
    left, right = build / 'playtest' / left, build / 'playtest' / right
    output = build / 'playtest' / ('compare-' + left.name + '-' + right.name)
    output.mkdir(parents=True, exist_ok=True)
    decomp = Path(r'C:\git\int19h\aow\data\decomp')
    paths = ';'.join(str(decomp / name) for name in
                     ('Enginep-typed-all', 'HSEPack-typed-all', 'AoWEPACK-typed-all', 'AoWTCPCK-typed-all'))
    a, b = {p.name: p for p in left.glob('*day-*.asg')}, {p.name: p for p in right.glob('*day-*.asg')}
    manifests = [json.loads((directory / 'run.json').read_text()) for directory in (left, right)]
    complete = all(manifest.get('complete') and (manifest.get('game_ended') or
                   len(manifest.get('saves', [])) >= manifest['requested_turns'] + 1)
                   for manifest in manifests)
    result = {'left': left.name, 'right': right.name, 'days': [], 'first_difference': None,
              'complete': complete,
              'missing_left': sorted(b.keys() - a.keys()), 'missing_right': sorted(a.keys() - b.keys()),
              'ignored': ['TAoWHSMap.FTurnTimeElapsed (id 0x37)', 'TAoWHSMap.FTurnTimeBeep (id 0x3a)']}
    for name in sorted(a.keys() & b.keys()):
        same = normalized_save(a[name]) == normalized_save(b[name])
        day = int(re.search(r'\d+', name)[0])
        result['days'].append({'day': day, 'equal': same,
                               'raw_equal': inflate(a[name]) == inflate(b[name])})
        dump_save(a[name], output / (name + '-left.txt'), paths)
        dump_save(b[name], output / (name + '-right.txt'), paths)
        if not same and result['first_difference'] is None:
            result['first_difference'] = day
            diff = difflib.unified_diff((output / (name + '-left.txt')).read_text().splitlines(True),
                                       (output / (name + '-right.txt')).read_text().splitlines(True),
                                       fromfile=str(a[name]), tofile=str(b[name]))
            (output / 'first-difference.diff').write_text(''.join(diff))
            old, new = state_fields(a[name], paths), state_fields(b[name], paths)
            changes = [{'path': key, 'left': old.get(key), 'right': new.get(key)}
                       for key in sorted(old.keys() | new.keys()) if old.get(key) != new.get(key)]
            (output / 'first-fields.json').write_text(json.dumps(changes, indent=2))
        print('%s vs %s: day %d %s' % (left.name, right.name, day, 'EQUAL' if same else 'DIFF'), flush=True)
    result['equal'] = (complete and bool(result['days']) and not result['missing_left'] and not result['missing_right']
                       and result['first_difference'] is None)
    missing_days = [int(re.search(r'\d+', name)[0])
                    for name in result['missing_left'] + result['missing_right']]
    result['first_missing_day'] = min(missing_days, default=None)
    (output / 'comparison.json').write_text(json.dumps(result, indent=2))
    return result


def check_modules(build, label, modules=None):
    """Keep complete matcher/address-check transcripts outside the repository."""
    output = build / 'playtest' / label
    output.mkdir(parents=True, exist_ok=True)
    results = {}
    for module in modules or buildgame.PACKAGES + buildgame.PROGRAMS:
        suffix = '.exe' if module in buildgame.PROGRAMS else '.dpl'
        signature = REPO / 'data/signatures' / (module + suffix + '.json')
        functions = json.loads(signature.read_text())
        owned = {unit.lower() for unit, flags in buildgame.package_info(buildgame.GAME / (module + suffix))[2]}
        units = sorted({f['name'].split('.')[0] for f in functions
                        if f['name'].split('.')[0].lower() in owned})
        classes = sorted({f['name'].split('@')[0].split('.')[1] for f in functions
                          if f['name'].count('.') == 2 and f['name'].split('.')[0] in units})
        source = buildgame.source_dir(module, buildgame.SOURCE)
        aliases = list(source.glob('*aliases*.json')) + sorted(source.glob('aliases/*.json'))
        arguments = ['--quiet', '--units', ','.join(units)]
        for alias in aliases:
            arguments += ['--alias', str(alias)]
        arguments += [str(build / (module + suffix)), str(build / (module + '.map')),
                      str(buildgame.GAME / (module + suffix)), str(signature), *classes]
        results[module] = {}
        for tool in ('match', 'addrcheck'):
            result = subprocess.run([sys.executable, str(REPO / 'tools' / (tool + '.py')), *arguments],
                                    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
            (output / (module + '-' + tool + '.txt')).write_text(result.stdout)
            summary = result.stdout.strip().splitlines()[-1] if result.stdout.strip() else ''
            results[module][tool] = {'exit_code': result.returncode, 'summary': summary}
            print(module, tool, summary, flush=True)
            if result.returncode:
                raise RuntimeError('%s %s failed; see %s' % (module, tool, output))
        (output / 'checks.json').write_text(json.dumps(results, indent=2))
    return results


def suite(build, scenarios, turns, timeout, rebuilt_label='rebuilt-after'):
    for scenario in scenarios:
        save = build / 'inputs' / (scenario + '.asg')
        for variant, suffix in (('original', 'original-a'), ('original', 'original-b'), ('rebuilt', rebuilt_label)):
            label = scenario + '-' + suffix
            manifest = build / 'playtest' / label / 'run.json'
            if not manifest.exists() or not json.loads(manifest.read_text()).get('complete'):
                run_game(build, variant, save, label, turns, timeout=timeout)
            if suffix == 'original-b':
                comparison = compare_runs(build, scenario + '-original-a', label)
                if not comparison['equal']:
                    raise RuntimeError('original is not repeatable: ' + scenario)
            elif variant == 'rebuilt':
                comparison = compare_runs(build, scenario + '-original-a', label)
                if not comparison['equal']:
                    raise RuntimeError('rebuilt state differs: ' + scenario)


def probe(build, variant, seconds, save=None, commands=''):
    copy = build / variant
    output = build / 'playtest' / (variant + '-probe-' + str(int(time.time())))
    with environment(copy, output):
        debugger = Debugger(copy, output, [save] if save else [], commands or '.echo PLAYTEST_READY; g')
        try:
            deadline = time.monotonic() + seconds
            while time.monotonic() < deadline and debugger.poll() is None:
                time.sleep(.25)
            if re.search(r'(?:^|\s)\d+:\d+>\s*$', debugger.text()):
                debugger.command('kb; dds @esp L40')
            print(debugger.text()[-14000:])
            pids = re.findall(r'\(([0-9a-f]+)\.[0-9a-f]+\):', debugger.text(), re.I)
            print('Windows:', json.dumps(buildgame.window_list(int(pids[0], 16) if pids else 0)))
        finally:
            debugger.close()
    print('Transcript:', output)



def decomp_paths():
    base = Path(r'C:\git\int19h\aow\data\decomp')
    return ';'.join(str(base / name) for name in
                    ('Enginep-typed-all', 'HSEPack-typed-all', 'AoWEPACK-typed-all', 'AoWTCPCK-typed-all'))


def editor_roundtrip(build, variant, scenario, label, timeout=120):
    """Open a disposable HSM and post its observed File > Save menu command."""
    if not re.fullmatch(r'[A-Za-z0-9_-]+', label):
        raise ValueError('invalid editor label')
    copy = build / variant
    output = build / 'editor' / label
    if output.exists():
        raise ValueError('editor label already exists: ' + label)
    output.mkdir(parents=True)
    source = build / 'original/Scenario/Custom' / SCENARIOS[scenario]
    target = output / source.name
    shutil.copy2(source, target)
    before = target.stat().st_mtime_ns
    status = {'variant': variant, 'scenario': scenario, 'input': str(source),
              'input_sha256': buildgame.digest(source), 'output': str(target),
              'complete': False, 'method': 'WM_COMMAND to observed File > Save menu ID'}
    user = ctypes.WinDLL('user32', use_last_error=True)
    user.GetMenu.argtypes = [w.HWND]
    user.GetMenu.restype = w.HANDLE
    user.GetSubMenu.argtypes = [w.HANDLE, ctypes.c_int]
    user.GetSubMenu.restype = w.HANDLE
    user.GetMenuItemCount.argtypes = [w.HANDLE]
    user.GetMenuItemID.argtypes = [w.HANDLE, ctypes.c_int]
    user.GetMenuItemID.restype = w.UINT
    user.GetMenuState.argtypes = [w.HANDLE, w.UINT, w.UINT]
    user.GetMenuState.restype = w.UINT
    user.GetMenuStringW.argtypes = [w.HANDLE, w.UINT, w.LPWSTR, ctypes.c_int, w.UINT]
    user.PostMessageW.argtypes = [w.HWND, w.UINT, w.WPARAM, w.LPARAM]
    def menu_items(menu):
        items = []
        for index in range(user.GetMenuItemCount(menu)):
            name = ctypes.create_unicode_buffer(512)
            user.GetMenuStringW(menu, index, name, len(name), 0x400)
            sub = user.GetSubMenu(menu, index)
            item = {'text': name.value, 'id': user.GetMenuItemID(menu, index),
                    'state': user.GetMenuState(menu, index, 0x400)}
            items.append(item)
            if sub:
                item['children'] = menu_items(sub)
        return items
    try:
        with environment(copy, output):
            process = buildgame.HiddenProcess(copy / 'AoWEd.exe', copy, arguments=[target])
            try:
                deadline = time.monotonic() + timeout
                while time.monotonic() < deadline:
                    if process.poll() is not None:
                        raise RuntimeError('editor exited: ' + str(process.returncode))
                    windows = buildgame.window_list(process.pid)
                    main = [item for item in windows if item['class'] == 'TMainForm' and item['visible']]
                    dialogs = [item for item in windows if item['visible'] and item['class'] in ('#32770', 'TPasswordDlg')]
                    (output / 'windows.json').write_text(json.dumps(windows, indent=2))
                    if dialogs:
                        raise RuntimeError('editor dialog: ' + json.dumps(dialogs))
                    if len(main) == 1 and target.stem.lower() in main[0]['title'].lower():
                        break
                    time.sleep(.2)
                else:
                    raise TimeoutError('map did not open in editor; see windows.json')
                time.sleep(.5)
                menu = menu_items(user.GetMenu(main[0]['handle']))
                (output / 'menu.json').write_text(json.dumps(menu, indent=2))
                def saves(items):
                    for item in items:
                        if item['text'].replace('&', '').split('\t')[0].strip().lower() == 'save':
                            yield item
                        yield from saves(item.get('children', []))
                choices = list(saves(menu))
                if len(choices) != 1 or choices[0]['state'] & 3:
                    raise RuntimeError('expected one enabled Save menu item: ' + str(choices))
                status['command_id'] = choices[0]['id']
                if not user.PostMessageW(main[0]['handle'], 0x111, choices[0]['id'], 0):
                    raise ctypes.WinError(ctypes.get_last_error())
                deadline = time.monotonic() + timeout
                while time.monotonic() < deadline:
                    if target.stat().st_mtime_ns != before:
                        time.sleep(.5)
                        try:
                            map_info(target)
                            break
                        except (OSError, ValueError, zlib.error, struct.error):
                            pass
                    if process.poll() is not None:
                        raise RuntimeError('editor exited during Save')
                    time.sleep(.2)
                else:
                    raise TimeoutError('Save command did not write the map')
                status['complete'] = True
                status['output_sha256'] = buildgame.digest(target)
                status['bytes'] = target.stat().st_size
                status['changed_from_input'] = target.read_bytes() != source.read_bytes()
                dump_save(target, output / 'saved-dump.txt', decomp_paths())
                print(label + ': saved ' + target.name, flush=True)
            finally:
                process.terminate()
                process.wait(timeout=5)
                status['process_exit_code'] = process.returncode
                process.close()
    except Exception as exc:
        status['error'] = str(exc)
        raise
    finally:
        (output / 'run.json').write_text(json.dumps(status, indent=2))
    return status


def compare_editor(build, left, right):
    dirs = [build / 'editor' / name for name in (left, right)]
    runs = [json.loads((d / 'run.json').read_text()) for d in dirs]
    files = [Path(run['output']) for run in runs]
    blobs = [f.read_bytes() for f in files]
    def first(a, b):
        return next((i for i, pair in enumerate(zip(a, b)) if pair[0] != pair[1]),
                    min(len(a), len(b)) if len(a) != len(b) else None)
    result = {'left': left, 'right': right, 'complete': all(run['complete'] for run in runs),
              'byte_equal': blobs[0] == blobs[1], 'first_offset': first(*blobs)}
    inflated = [inflate(f) for f in files]
    result['inflated_equal'] = inflated[0] == inflated[1]
    result['first_inflated_offset'] = first(*inflated)
    fields = [state_fields(f, decomp_paths(), ignore_timers=False) for f in files]
    changes = [{'path': k, 'left': fields[0].get(k), 'right': fields[1].get(k)}
               for k in sorted(fields[0].keys() | fields[1].keys()) if fields[0].get(k) != fields[1].get(k)]
    result['first_field'] = changes[0] if changes else None
    result['field_differences'] = len(changes)
    result['dump_equal'] = (dirs[0] / 'saved-dump.txt').read_bytes() == (dirs[1] / 'saved-dump.txt').read_bytes()
    result['equal'] = result['complete'] and result['byte_equal'] and result['dump_equal']
    out = build / 'editor' / ('compare-' + left + '-' + right)
    out.mkdir(exist_ok=True)
    (out / 'comparison.json').write_text(json.dumps(result, indent=2))
    (out / 'fields.json').write_text(json.dumps(changes, indent=2))
    print(json.dumps(result, indent=2), flush=True)
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('build', type=Path)
    sub = parser.add_subparsers(dest='command', required=True)
    sub.add_parser('inventory')
    sub.add_parser('prepare')
    seed_parser = sub.add_parser('seed-map')
    seed_parser.add_argument('map', type=Path)
    seed_parser.add_argument('target', type=Path)
    seed_parser.add_argument('--cpu', type=int, choices=(1, 2, 3, 6, 7), default=1)
    seed_parser.add_argument('--seed', type=lambda s: int(s, 0), default=123456789)
    run_parser = sub.add_parser('run')
    run_parser.add_argument('variant', choices=('original', 'rebuilt'))
    run_parser.add_argument('save', type=Path)
    run_parser.add_argument('label')
    run_parser.add_argument('--turns', type=int, default=20)
    run_parser.add_argument('--seed', type=lambda s: int(s, 0), default=123456789)
    run_parser.add_argument('--timeout', type=float, default=3600)
    run_parser.add_argument('--initial-only', action='store_true')
    run_parser.add_argument('--tactical', action='store_true')
    run_parser.add_argument('--coverage', action='store_true')
    run_parser.add_argument('--exercise-items', action='store_true')
    run_parser.add_argument('--global-spell', type=int, default=0,
                            choices=(0, 44, 45, 46, 47, 48, 50, 60, 61, 62, 63, 64, 65))
    run_parser.add_argument('--tactical-battles', type=int, default=0,
                            help='select tactical combat for only the first N battles (0: all)')
    compare_parser = sub.add_parser('compare')
    compare_parser.add_argument('left')
    compare_parser.add_argument('right')
    check_parser = sub.add_parser('check')
    check_parser.add_argument('label')
    check_parser.add_argument('--modules', nargs='+', choices=buildgame.PACKAGES + buildgame.PROGRAMS)
    suite_parser = sub.add_parser('suite')
    suite_parser.add_argument('scenarios', nargs='+', choices=tuple(SCENARIOS))
    suite_parser.add_argument('--turns', type=int, default=20)
    suite_parser.add_argument('--timeout', type=float, default=3600)
    suite_parser.add_argument('--rebuilt-label', default='rebuilt-after')
    editor_parser = sub.add_parser('editor')
    editor_parser.add_argument('variant', choices=('original', 'rebuilt'))
    editor_parser.add_argument('scenario', choices=tuple(SCENARIOS))
    editor_parser.add_argument('label')
    editor_compare_parser = sub.add_parser('editor-compare')
    editor_compare_parser.add_argument('left')
    editor_compare_parser.add_argument('right')
    probe_parser = sub.add_parser('probe')
    probe_parser.add_argument('--variant', choices=('original', 'rebuilt'), default='original')
    probe_parser.add_argument('--seconds', type=float, default=30)
    probe_parser.add_argument('--save', type=Path)
    probe_parser.add_argument('--commands', default='')
    probe_parser.add_argument('--commands-file', type=Path)
    args = parser.parse_args()
    build = args.build.resolve()
    if build.is_relative_to(REPO) or build == buildgame.GAME.resolve() or build.is_relative_to(buildgame.GAME.resolve()):
        parser.error('build directory must be outside the repository and original installation')
    if args.command == 'inventory':
        inventory(build)
    elif args.command == 'prepare':
        prepare(build)
    elif args.command == 'seed-map':
        if not args.target.resolve().is_relative_to(build):
            parser.error('prepared saves must be below the build directory')
        seed_map(args.map, args.target, args.seed, cpu=args.cpu)
    elif args.command == 'run':
        run_game(build, args.variant, args.save.resolve(), args.label, args.turns, args.seed, args.timeout, args.initial_only, args.tactical, args.coverage, args.tactical_battles, args.exercise_items, args.global_spell)
    elif args.command == 'compare':
        print(json.dumps(compare_runs(build, args.left, args.right), indent=2))
    elif args.command == 'check':
        check_modules(build, args.label, args.modules)
    elif args.command == 'editor':
        editor_roundtrip(build, args.variant, args.scenario, args.label)
    elif args.command == 'editor-compare':
        compare_editor(build, args.left, args.right)
    elif args.command == 'suite':
        suite(build, args.scenarios, args.turns, args.timeout, args.rebuilt_label)
    else:
        probe(build, args.variant, args.seconds, args.save,
              args.commands_file.read_text() if args.commands_file else args.commands)


if __name__ == '__main__':
    main()
