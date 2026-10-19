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
| TEObject, TEObjectEditorList.FindEditor | 23 | 23 |
| TECustomNode, TENode | 29 | 28 |
| TEStorageStream, TEReadStorageStream, TEWriteStorageStream, string stream helpers | 72 | 67 |
| TEngine (35 methods), TEObjectClassList, TEControlStyleObject, TEControlStyleNode, TECustomOwner, TEResourceEditSettings | 67 | 66 |
| THashList, TIntegerHashList, TIntegerHashTable256 (`inc/HashTab.PAS`) | 16 | 13 |
| InitMsg, InitMsgEx, GetCRC32, BuildCRC32Table, GetFileCRC32, ReleaseCRC32Table, GetEngine, FindEngine | 8 | 7 |

483 functions, 472 identical (33,450 of 35,287 bytes). Three of the eleven that differ are the
`Assert` line numbers in `inc/HashTab.PAS` (the original counts them from the start of its
Engine.pas: 7127, 7137 and 7155); the other eight differ in one register choice each (below).
`src/delphi3/matchpkg.dpk` builds the same units as a package, the way the original was built; the
package code is identical to the program code, so the compile mode is not what decides those
registers.

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

- A sub-expression that recurs in a statement is computed once and kept in a callee-saved
  register: `FLists[Key and $FF].Find(Key)` followed by `FLists[Key and $FF].Delete(Key)` computes
  `Key and $FF` once (writing it to a local gives a different register order). The same reuse shows
  up for `AClasses[I]` in `TEngine.RegisterEClasses`.
- Two locals whose live ranges do not overlap share a register: `I := IndexOf(Name); if I <> -1
  then Result := Objects[I] else Result := ...` keeps I and Result in one register, and the source
  with `Result` used as the index compiles differently.
- A function result that is also the search index (`TEResourceEditSettings.RemoveEditor` returns
  the index it deleted) keeps the index in a callee-saved register; a procedure with a local keeps
  it in eax.
- A nested call `GetEClass(AClassID).Create(AOwner)` moves all parameters to callee-saved
  registers; `C := GetEClass(AClassID); Result := C.Create(AOwner)` leaves them where they arrive.
  Likewise `L := TList.Create; ...; Result := L` keeps the list in a register where using `Result`
  in the loop spills it.
- `Assert` compiles to a compare, a jump and a call with the message, the file name and the line
  number; the line number counts from the start of the unit through `{$I}` includes, so the
  include file's Asserts tell where it sat in the original unit.
- `Result := Result xor $FFFFFFFF` is `xor eax,-1`; `not Result` is `not eax`.
- `GetHeapStatus.TotalAllocated` in an expression calls into a temp record each time; a ShortString
  `ClassName + '...'` concatenation runs `PStrCat` before the long-string concatenation.
- Package compilation (`-Z` style, a `.dpk` requiring vcl30) produces the same method code as a
  program: class references are read through the VMT self pointer in both.

## Open items

- `TECustomNode.DestroyAllChildren`, `TEReadStorageStream.rwBool`, the `try` frame register in
  `TEReadStorageStream.rwCreateEObject`, `TEWriteStorageStream.rwCreateEObject`, `rwEObject`,
  `rwEObjectStream`, `TEngine.GetEClass` (Self stays in eax in the original, mine moves it to ebx
  before a field read) and `GetEngine` (the Index parameter stays in eax): same code apart from
  register choice. Tried for GetEClass: locals for the table and the result, `with`, a property,
  `Assigned`, `Exit` forms, parameter names; none changes the allocation.
- The three `Assert` line numbers in `inc/HashTab.PAS` settle only when the whole unit is laid out
  as the original (THashList.SetCapacity's Assert at line 7127).
- Next classes: `TCompressStream` and the zlib unit, `TCompareStorageStream`, the text storage
  streams (`TEReadTextStorageStream`, `TEWriteTextStorageStream`), `TStringHashList` and
  `TStringHashTable256` (also from `inc/HashTab.PAS`), `TEChangeNotifyNode`, `TETimerNode`,
  `TESortNode`, the plug-in loader and the unit initialization; then the game units.
