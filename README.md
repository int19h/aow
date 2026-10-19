# aow

Reverse-engineering notes and tools for Age of Wonders (1999, v1.36), with the goal of a source port.
This repository holds no game files. The tools read an installed copy of the game.

- `notes/binary-inventory.md`: what the binaries are and what metadata they carry.
- `notes/symbols/`: exported units, classes, and methods per package (from `tools/pescan.py` and `tools/symtab.py`).
- `notes/rtti/`: class layouts recovered from Delphi RTTI (from `tools/delphi_rtti.py`).
- `notes/samples/`: hand-reconstructed Pascal, as examples of the target output.
- `tools/ghidra/`: headless Ghidra scripts. Import a module with
  `analyzeHeadless <projects> aow -import <file> -processor x86:LE:32:default -cspec borlanddelphi -preScript CreateDelphiFunctions.java -postScript FixDelphiFinally.java`.

Decompiler output goes to `notes/decomp/`, which is ignored by git.
