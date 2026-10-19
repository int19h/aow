# Byte-matching the original compiler

The game modules were built with Delphi 3.02 (`notes/binary-inventory.md`). With the same compiler
installed (`C:\Tools\Delphi3`, see the README), a recovered method can be compiled and its machine
code compared with the code in the game's module. When the instruction streams are identical, the
source is right in every detail the compiler can see: field layout, VMT order, evaluation order,
local variable order, loop shape.

## Workflow

1. Read the original: `tools/disasm.py <module> <signatures.json> <names...>` prints functions by
   name with capstone, `--range=lo-hi` prints raw bytes (exception handlers that Ghidra left out of
   a function). The decompiled C in `notes/decomp/` gives the logic; the disassembly gives the shape.
2. Write the method in `src/delphi3/*.pas` (Delphi 3 syntax, CRLF line endings, `uses Consts` for the
   list error strings). Keep the original instance layout and VMT order from `notes/classes.json`.
3. Build: `C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B matchtest.dpr` in `src/delphi3`. The host program
   references every class so that smart linking keeps the methods; a method that is not referenced
   shows up as "not in map".
4. Compare: `python tools/match.py --quiet --alias src/delphi3/match-aliases.json
   src/delphi3/matchtest.exe src/delphi3/matchtest.map "<game dir>\Enginep.dpl"
   notes/signatures/Enginep.dpl.json TPropertyTable TIntegerList ...`. Call, jump and absolute
   addresses are masked; on-exception tables after `jmp @HandleOnException` are skipped. `--show
   Method` prints both streams side by side. The alias file maps nested functions and unit
   procedures that Ghidra named `FUN_xxxxxxxx` to map symbols (`"DefaultRun<TByteList.SaveToStream"`
   picks the nested function emitted right before that method; `"5551761c:5"` names a function
   Ghidra did not create).
5. When a method differs, try source variants. `scratchpad/var/inplace.py` appends variant copies of
   one method to its class, builds, and compares each one against the original.

## State (2026-10-19)

| unit / class | functions | matched |
|---|---|---|
| TPropertyTable | 10 | 10 |
| TIntegerList, TByteList, TShortIntList, TWordList, TBitList, TEventList, TDoubleItemList, TQuadItemList (with QuickSort, DefaultRun, ReturnAddr, Fill* and the sort comparison helpers) | 268 | 268 |
| TEObject, TEObjectEditorList.FindEditor, TEngine.ReadEObject/WriteEObject | 25 | 25 |
| TECustomNode, TENode | 29 | 28 |
| TEStorageStream, TEReadStorageStream, TEWriteStorageStream, string stream helpers | 72 | 67 |

The six that differ are identical except for one register choice each (`notes/match.md`, below).

## What the compiler does (learned from the matches)

- Locals are register candidates in an order that depends on declaration order, use counts and
  whether the live range crosses a call; a local whose value is only needed between two calls can
  live in eax, ecx or edx. Reordering a `var` block or splitting one variable into two changes the
  code. `C := Children[I]; if (C <> nil) and ...` keeps C in a scratch register when nothing is
  called before its last use.
- A value just stored to a field stays tracked in the register, so `FCapacity := NewCapacity; if
  FCapacity < FCount then` reads the register, not the field. A value loaded for a comparison is
  reused for a following loop bound (`if NewCount > FCount then begin OldCount := FCount; ...`).
- `for` loops whose control variable is unused in the body count a register up to zero; `downto`
  evaluates the start value before the end value; `for I := 0 to N - 1` with a `Word` variable gives
  the `dec/test bx,bx/jb` shape; `while` loops are rotated (test at the bottom) and a method pointer
  operand of the condition is copied to a temp before the loop.
- `@A <> @B` compares only the code pointers of method pointers; the original compares both halves
  through `TMethod` casts and copies the right operand into a `TMethod` local.
- `Assigned(E)` on a method pointer tests the high word of the code address (`cmp word ptr [..+2],0`).
- Records of 8 bytes passed by value arrive by reference and are copied by the callee; `const`
  records arrive by reference without a copy; a by-value record parameter of an `assembler`
  procedure changes the caller's argument evaluation order (FillLargeInteger).
- `Comp(Item) = Comp(FDefault)` compares two 8-byte records with `fild/fcompp`.
- Set-typed results (`TStorageModes`, `TEControlStyles`) are bytes loaded from constants placed
  after the function; `StorageMode * [smRead, smCompare, smTranslate] = [smRead]` is an `and` with a
  constant and a byte compare.
- Delphi 3 has no `TMethod` in `Classes` (it is in `SysUtils`), no `resourcestring`-less way to get
  the `LoadResString` shape, and `Free` versus `Destroy` compile differently (static call versus
  VMT -4); the original uses `Destroy` on children it owns and `Free` on its own helper objects.
- The register used for a `try` frame (`xor eax,eax` or `xor edx,edx`) and a few operand register
  orders depend on state the source does not show; the same text compiles differently depending on
  how many methods the class declares (`TECustomNode.DestroyAllChildren` matched with three extra
  methods declared and not with two). These will settle only when the whole unit is assembled with
  the original's declarations.

## Open items

- `TECustomNode.DestroyAllChildren`, `TEReadStorageStream.rwBool`, and the `try` frame register in
  `TEReadStorageStream.rwCreateEObject`, `TEWriteStorageStream.rwCreateEObject`, `rwEObject`,
  `rwEObjectStream`: same code apart from register choice.
- Next classes: `TEngine` (35 methods), `TCompressStream` and the zlib unit, `TCompareStorageStream`,
  the text storage streams, `TEChangeNotifyNode`, `TETimerNode`, `TESortNode`; then the game units.
