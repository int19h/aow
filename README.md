# aow

Reverse-engineering notes and tools for Age of Wonders (1999, v1.36), with the goal of a source port.
This repository holds no game files. The tools read an installed copy of the game.

- `notes/binary-inventory.md`: what the binaries are and what metadata they carry.
- `notes/symbols/`: exported units, classes, and methods per package (from `tools/pescan.py` and `tools/symtab.py`).
- `notes/rtti/`: class layouts recovered from Delphi RTTI (from `tools/delphi_rtti.py`).
- `notes/samples/`: hand-reconstructed Pascal, as examples of the target output.
- `notes/persistence.md`: how objects are saved (`ReadWrite` on a storage stream) and the save container.
- `notes/persisted-fields.md`, `notes/field-names.md`, `notes/field-overrides.md`: field tables per class
  (generated, generated, hand-written). `notes/engine-classes.md` merges them with the RTTI sizes.
- `notes/classes.json`: the class database (1,785 classes across all modules) that the Ghidra typing script consumes.
- `tools/ghidra/`: headless Ghidra scripts; `ghidra.ps1` wraps `analyzeHeadless` with the local paths.

## Workflow

1. Import: `ghidra.ps1 -Import <module>` (Delphi compiler spec, `CreateDelphiFunctions.java` as pre-script).
2. `ghidra.ps1 -Process '*' -Script FixDelphiFinally.java` repairs the try/finally epilogs.
3. `python tools/build_classdb.py <gamedir> notes/classes.json notes/persisted-fields.md notes/field-names.md notes/field-overrides.md`
4. `ghidra.ps1 -Process '*' -Script ApplyDelphiClasses.java -ScriptArgs notes/classes.json` creates a struct and a
   vtable per class and types `Self`; the decompiler then prints `this->FExperience` and `(*stream->vtbl->rwByte)(...)`.
5. `ghidra.ps1 -Process AoWEPACK.dpl -Script DecompileFunctions.java -ScriptArgs <outdir>` dumps the package.
6. `python tools/readwrite_table.py <outdir> notes/persisted-fields.md notes/classes.json` and
   `python tools/field_names.py <outdir> notes/field-names.md notes/classes.json` refresh the field tables;
   add verified names to `notes/field-overrides.md` and go back to step 3.

7. `ghidra.ps1 -Process '*' -Script ExportSignatures.java -ScriptArgs notes/signatures` exports every method's
   parameters, then `python tools/emit_pascal.py notes/classes.json notes/signatures src/skeleton` writes one
   Pascal unit per module (`src/skeleton/`): all classes with fields at their offsets, padding for the unknown
   bytes, virtual methods in VMT order, and stub bodies. Every unit compiles with Free Pascal:
   `fpc -Mdelphi -Sh -Fu src\skeleton -FU <tmp> src\skeleton\AoWEPACK.pas`.
8. `python tools/asg_dump.py <save.asg> notes/classes.json notes/decomp/AoWEPACK-typed` walks a save or map
   file with the recovered schema and reports what it cannot explain.

## Original toolchain

Delphi 3.02 Professional (the compiler the game was built with) is unpacked at `C:\Tools\Delphi3`:
`BIN\DCC32.EXE` with `DCC32.CFG` pointing at `LIB`, the RTL and VCL sources under `SOURCE`, and the runtime
packages under `WINDOWS\SYSTEM`. After the 3.02 patch, `vcl30.dpl`, `vcldb30.dpl` and `vclx30.dpl` there are
byte-identical to the game's copies. Recovered units can therefore be compiled with the original compiler and
compared with the original code byte for byte.

## Byte-matching the Engine unit

`src/delphi3/` is the `Engine` unit written for Delphi 3.02 and compared with `Enginep.dpl` method by
method: `tools/match.py` disassembles both and reports every instruction that differs. Every unit of
Enginep.dpl is written; 865 of 892 functions compile to identical code, the rest differ in one register
choice or an `Assert` line number (`notes/match.md` lists them). `notes/modules.md` gives the order for
the other packages. `notes/match.md` has the workflow,
the state table and what the comparisons taught about the compiler. Build and compare:

```bash
cd src\delphi3 && C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B "-UIlpack;Gfxepack" matchtest.dpr
```

```bash
python tools/match.py --quiet --alias src/delphi3/match-aliases.json src/delphi3/matchtest.exe src/delphi3/matchtest.map "D:\Games\GOG\Age of Wonders\Enginep.dpl" notes/signatures/Enginep.dpl.json TEngine TEObject TENode
```

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

Decompiler output goes to `notes/decomp/`, which is ignored by git.
