# aow

Recovered source, documentation, data and tools for Age of Wonders (1999, v1.36), with the goal of a source port.
This repository holds no game files. The tools read an installed copy of the game, and the build
script copies it before it replaces anything.

## State

All modules that v1.36 loads are recovered as Delphi 3.02 source under `src/delphi3/` and compile
with the original compiler. Over those modules, 12,922 of 13,303 functions (97.1 percent, as of
2026-10-24) compile to the same instructions as the original, with the same control flow and the
same referenced routines and globals. Of the 381 that differ, some are proven equivalent by a
checker under named premises, and most of the others have a manual verdict with a written argument
(`data/equiv-review/`). From this source, `tools/buildgame.py` builds all game packages, `AoW.exe` and `AoWEd.exe`;
the rebuilt game plays identically to the original in seeded computer-only games (equal save files
after every turn: seven scenarios for 20 turns, one for 50). `doc/modules.md` has the per-module
numbers, and `doc/open-items.md` the work that is known to be open.

## Repository layout

- `doc/`: documentation of the effort as a whole. `doc/match.md` is the byte-matching workflow and
  what a match proves. `doc/delphi3-codegen.md` catalogs the source forms that change the code that
  Delphi 3.02 generates. `doc/checker-plan.md` is the design of the equivalence checker.
- `data/`: data that the tools read and write: the class database, function signatures, symbols,
  RTTI, forms, field tables and the per-function review verdicts.
- `src/`, `tools/`, `tests/`: the recovered source, the tools and the tests.

Prompts and briefs for the coding agents are not part of the repository.

## Documentation, data and early tools

- `doc/binary-inventory.md`: what the binaries are and what metadata they carry.
- `data/symbols/`: exported units, classes, and methods per package (from `tools/pescan.py` and `tools/symtab.py`).
- `data/rtti/`: class layouts recovered from Delphi RTTI (from `tools/delphi_rtti.py`).
- `doc/samples/`: hand-reconstructed Pascal, as examples of the target output.
- `doc/persistence.md`: how objects are saved (`ReadWrite` on a storage stream) and the save container.
- `data/persisted-fields.md`, `data/field-names.md`, `data/field-overrides.md`: field tables per class
  (generated, generated, hand-written). `doc/engine-classes.md` merges them with the RTTI sizes.
- `data/classes.json`: the class database (1,785 classes across all modules) that the Ghidra typing script consumes.
- `tools/ghidra/`: headless Ghidra scripts; `ghidra.ps1` wraps `analyzeHeadless` with the local paths.

## Workflow

1. Import: `ghidra.ps1 -Import <module>` (Delphi compiler spec, `CreateDelphiFunctions.java` as pre-script).
2. `ghidra.ps1 -Process '*' -Script FixDelphiFinally.java` repairs the try/finally epilogs.
3. `python tools/build_classdb.py <gamedir> data/classes.json data/persisted-fields.md data/field-names.md data/field-overrides.md`
4. `ghidra.ps1 -Process '*' -Script ApplyDelphiClasses.java -ScriptArgs data/classes.json` creates a struct and a
   vtable per class and types `Self`; the decompiler then prints `this->FExperience` and `(*stream->vtbl->rwByte)(...)`.
5. `ghidra.ps1 -Process AoWEPACK.dpl -Script DecompileFunctions.java -ScriptArgs <outdir>` dumps the package.
6. `python tools/readwrite_table.py <outdir> data/persisted-fields.md data/classes.json` and
   `python tools/field_names.py <outdir> data/field-names.md data/classes.json` refresh the field tables;
   add verified names to `data/field-overrides.md` and go back to step 3.

7. `ghidra.ps1 -Process '*' -Script ExportSignatures.java -ScriptArgs data/signatures` exports every method's
   parameters, then `python tools/emit_pascal.py data/classes.json data/signatures src/skeleton` writes one
   Pascal unit per module (`src/skeleton/`): all classes with fields at their offsets, padding for the unknown
   bytes, virtual methods in VMT order, and stub bodies. Every unit compiles with Free Pascal:
   `fpc -Mdelphi -Sh -Fu src\skeleton -FU <tmp> src\skeleton\AoWEPACK.pas`.
8. `python tools/asg_dump.py <save.asg> data/classes.json data/decomp/AoWEPACK-typed` walks a save or map
   file with the recovered schema and reports what it cannot explain.

## Original toolchain

Delphi 3.02 Professional (the compiler the game was built with) is unpacked at `C:\Tools\Delphi3`:
`BIN\DCC32.EXE` with `DCC32.CFG` pointing at `LIB`, the RTL and VCL sources under `SOURCE`, and the runtime
packages under `WINDOWS\SYSTEM`. After the 3.02 patch, `vcl30.dpl`, `vcldb30.dpl` and `vclx30.dpl` there are
byte-identical to the game's copies. Recovered units can therefore be compiled with the original compiler and
compared with the original code byte for byte.

## Byte-matching

`src/delphi3/` holds one directory per package (the `Engine` unit sits in `src/delphi3/` itself);
each has a test host `matchtest.dpr` that links its units statically. `tools/match.py` disassembles
the host and the original module and compares them function by function, with addresses masked
and branch targets and exception tables compared as offsets inside the function (shared code in
`tools/match_flow.py`). Because addresses are masked, `tools/addrcheck.py` checks separately that a
matched function references the same routines and globals. `sh tools/checkall.sh` rebuilds and
compares the earlier packages from a clean copy. `doc/match.md` has the workflow, what the
compiler does, and what a match does and does not prove. Example for the Engine unit:

```bash
cd src\delphi3 && C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B "-UIlpack;Gfxepack" matchtest.dpr
```

```bash
python tools/match.py --quiet --alias src/delphi3/match-aliases.json src/delphi3/matchtest.exe src/delphi3/matchtest.map "D:\Games\GOG\Age of Wonders\Enginep.dpl" data/signatures/Enginep.dpl.json TEngine TEObject TENode
```

## Proving the differing functions

`tools/equiv.py` takes the arguments of `tools/match.py` and tries to prove each differing function
equivalent to the original with z3 (relational translation validation). A verdict is PROVEN,
"PROVEN under H...", which names the premises it relies on, NOT PROVEN or UNSUPPORTED; anything the
checker does not model fails closed. `doc/checker-plan.md` defines the premises H1 to H9, the
observation contract and the steps of its repair plan, written and reviewed by two independent
reviewers. `tools/equiv_tests/` holds its regression fixtures:

```bash
python -B tools/equiv.py --selftest --synthetic-only
python -B -m unittest discover -s tools -t tools -p "test_*.py"
```

`data/equiv-review/<Module>.tsv` records a manual verdict for every differing function the checker
does not prove, with the argument for it.

## Building and playing the rebuilt game

```bash
python tools/buildgame.py build <build dir>
python tools/buildgame.py install <build dir> <game copy dir>
```

The first builds every recovered package and both executables (the package and program projects
are the `.dpk` and `.dpr` files in `src/delphi3/`; `src/delphi3/imports/` holds interface units for
the third-party packages that stay original at run time). The second copies the installed game and
replaces the recovered modules in the copy. The forms are built from `data/forms/` at build time.
The game reads its settings, including its root directory, from
`HKEY_CURRENT_USER\Software\Triumph Studios\Age of Wonders`; point `General\Root Directory` at the
copy before you run it there. `tools/playtest.py` runs seeded computer-only games in the original
and the rebuilt copy on a hidden desktop and compares their saves turn by turn.

## Working method

The work is done by coding agents, one brief per kind of task, each with the measure that says when
it is done. The briefs are kept outside the repository. Merges keep every existing match and do not raise the
address-check findings.

## Recovered source

`src/recovered/` holds hand-translated units, as opposed to the generated skeletons. `Engine.pas` is the
persistence part of the original `Engine` unit (property tables, the storage streams, the compressed
container). `tests/asgread.pas` reads a save with it and prints what `tools/asg_dump.py` prints:

```bash
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -Mdelphi -Fusrc\recovered -FU%TEMP% -FE%TEMP% tests\asgread.pas
```

## Generated object model and the round trip

`tools/translate_readwrite.py` turns the typed `ReadWrite` decompiles into `src/model/AoWModel.pas`: one class
per persisted class, fields typed by the `rw*` calls, embedded objects created in the constructors, class ids,
and a `ReadWrite` that replays the original calls (what it cannot translate is left as a `TODO` comment and
listed in `AoWModel.pas.report.txt`). Hand-written classes go in `src/model/hand/<Class>.decl.inc` and
`.impl.inc` and replace the generated ones. `tests/roundtrip.pas` loads a save through the model, writes it
back with `TEWriteStorageStream`, and compares the bytes:

```bash
C:\lazarus\fpc\3.2.2\bin\x86_64-win64\fpc.exe -Mdelphi -Fusrc\recovered -Fusrc\model -Fisrc\model -FU%TEMP% -FE%TEMP% tests\roundtrip.pas
```

Decompiler output goes to `data/decomp/`, which is ignored by git.
