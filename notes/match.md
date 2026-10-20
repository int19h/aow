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
3. Build: `C:\Tools\Delphi3\BIN\DCC32.EXE -GD -B "-UIlpack;Gfxepack" matchtest.dpr` in `src/delphi3` (ImageLib comes from the Ilpack sources). The host program
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
| TEObject, TEObjectEditor, TEObjectEditorList, TEObjectList | 33 | 32 |
| TECustomNode, TENode, TEChangeNotifyNode, TEChangeNotifyEventList, TETimerNode, TEReferenceNode, TESortNode and the sort node variants, TEUser | 115 | 114 |
| TEStorageStream, TEReadStorageStream, TEWriteStorageStream, TDebugWriteStream, the text streams, TTranslateStorageStream, TSetupCompareStorageStream, TCompareStorageStream, string stream helpers | 149 | 141 |
| TEngine, TEObjectClassList, TEControlStyleObject, TEControlStyleNode, TECustomOwner, TEResource, TEResourceList, TEResourceEditSettings, TEComponent, TECopyComponent, TPlugIn, TPlugInControl, TCallBackEventList, TCompressStream | 121 | 117 |
| THashList, TIntegerHashList, TIntegerHashTable256, TStringHashList, TStringHashTable256 (`inc/HashTab.PAS`) | 30 | 26 |
| FMemStr.TFastMemoryStream | 11 | 11 |
| unit functions: InitMsg, CRC32, engine and plug-in lookups, string sorting, ReplaceText, HexToInt, clipboard streams, external plug-in loading | 42 | 37 |
| zlib (Borland's unit from the Delphi 3 CD, with the CD's zlib 1.0.4 object files), EList, PlugInM, DebMDlg | 46 | 46 |
| ImgLComp (image grids and panels), EResGrid (resource grid) | 112 | 108 |
| Gfxepack.dpl: GFXE (surfaces, blitters, DirectDraw, blend tables), GFXDiag (`src/delphi3/Gfxepack/`) | 262 | 252 |
| aowDPlay.dpl: aowDPlayComp (DirectPlay component), DPlay, DPLobby; VideoP.dpl: Video, VFW | 74 | 74 |
| Dcpack.dpl: DisplayC (windowed and full-screen DirectDraw display controllers, frame thread), TWindows08DIBSurface | 174 | 169 |
| Adcpack.dpl: ZoomControl, AdvancedDisplay (`{$O-,Q+}`); aowFXpck.dpl: aowFX (particle paths) | 43 | 43 |
| Ilpack.dpl: ImageLib, HashTabU, the editors ILSpin, PerfDlg, ILEdGrid, ImgSetEd, SImgSEd, SubImgEd, ILEdForm (`src/delphi3/Ilpack/`) | 709 | 684 |
| Network.dpl: NetworkE | 148 | 148 |
| SoundP.dpl: Sound, GalSndS, SFXEdDlg, Galaxy, DSound | 176 | 176 |
| aowInt.dpl: the 29 UI control units (`src/delphi3/aowInt/`) | 409 | 383 |

Enginep.dpl as a whole: 892 functions, 865 identical. The Engine unit alone: 734 functions, 711
identical (50,949 of 54,811 bytes): every method of every class of the original Engine unit is
written, plus the FMemStr unit. Five of the 23 that differ are `Assert`
line numbers (the original counts them from the start of its Engine.pas: THashList.SetCapacity 7127,
THashList.Delete 7137, TIntegerHashList.Add 7155, TStringHashList.Add 7282, TEChangeNotifyNode.
EndUpdate 8215). The other 18 differ in one register choice each (below). `src/delphi3/matchpkg.dpk`
builds the same units as a package, the way the original was built; the package code is identical
to the program code. The Delphi 3.0 compiler from the original release CD (March 1997) gives worse
results (argument evaluation order differs in 20 more functions), and the 3.02 patch does not change
DCC32.EXE, so the installed compiler is the right one.

Every unit of Enginep.dpl is written. They build against the recovered ImageLib of Ilpack.dpl
(`src/delphi3/Ilpack`), which uses GFXE (`src/delphi3/Gfxepack`). The small units have their own host
programs (`hosts/misc.dpr`, `hosts/ui.dpr`) and alias files (`aliases/*.json`); build them from
`src/delphi3/hosts` with `"-U..;..\Ilpack;..\Gfxepack" -O..`.

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

- A `while` whose condition is one comparison of a register variable is compiled with the test at
  the top and again at the bottom (`GetCRC32`); a condition with `and`/`or` or a memory operand gets
  a `jmp` to the test at the bottom.
- `for I := 7 downto 0` with I unused counts a register up from -8; `for I := 0 to 7` counts down.
- Small sets of chars (`P^ in [#0, #10, #13]`) are tested with a chain of `sub/je`.
- `Dispose(P)` passes the record size to FreeMem; `FreeMem(P, Size)` does not.
- A chain of `if Count = 4 ... else if Count = 1 ... else if Count = 2` keeps the order of the
  compares; a `case` sorts them into a decrement chain.
- An `except` block without `on` is `HandleAnyException` + `DoneExcept`; `raise` inside it is
  `RaiseAgain`.
- A `Byte` parameter passed to an enumerated parameter is loaded into `al` and copied through `eax`
  (`TCompressStream.SaveToStreamEx`); no cast tried reproduces it.
- Passing a parameter straight to a method pointer that mimics a constructor
  (`TEditorConstructor = procedure(Alloc: Boolean; Obj: TEObject) of object`) is how
  `TEObjectEditor.Edit` calls an editor class constructor.
- Stack parameters are pushed left to right (`pushtest`): the first stack parameter has the highest
  address.

- Dynamic methods are numbered per class hierarchy, counting down from one below the lowest index
  of the ancestors; declaration order fixes the numbers, and calls go through `@CallDynaInst` with
  the index in bx.
- A `case` on a Word compiles to an ascending `sub ax,n / je` chain, but the branch bodies are laid
  out in source order.
- Stack slots of locals: in ImgLComp the first declared spilled local got the lower address, in
  aowFX (MakeArcPath) the first declared got the higher address, as under `$O-`; locals that get a
  register take no slot, and which local gets the register moves the others. Try both orders.
- `(FMin <> 0) and (Value < FMin)` gives `cmp ecx,edx / jle`; `FMin > Value` gives `cmp edx,ecx / jge`.
- A nil test `mov eax,[field] / test eax,eax` comes from a local or a `with`; `if F <> nil`,
  `Assigned(F)` and casts all give `cmp dword ptr [..],0`.
- A method pointer passed by value is pushed data first, then code. An empty method with a stack
  parameter still gets a frame (`push ebp / mov ebp,esp / pop ebp / ret n`).
- `if not Cancel then <big block> else R.Free` lays the big block out first.
- A dead store to a parameter is dropped, but its condition is still compiled.
- A record reached through a typecast of a dereferenced pointer (`TRec(Pointer(P)^).Field`) reloads
  the pointer for every field and evaluates the fields before the call's object expression; `with
  PRec(P)^ do` evaluates the object expression first.
- A field-backed property (`TList.Count`) can be passed to an untyped `const` parameter, giving
  `lea edx,[Self+8]`.
- A Boolean loop flag set from `FindFirst(...) = 0` lives in al through the loop.
- A loop body with its own `try...except` keeps Self, the loop variable and the loop count in memory.
- Every unit gets the init/fini pair that counts a per-unit counter inside an empty try/finally, with
  or without an `initialization` section.
- Delphi 3 ignores a missing `{$L file.obj}` silently: the error is an unsatisfied external.
- A `case` jump table follows `jmp dword ptr [reg*4 + table]`, with a byte index table in front when
  the case values are sparse; the table base is entry 0 even if the lowest value is higher.
  `match.py` compares the tables as lists of offsets into the function.

- A multi-line `Assert` records the line where the statement ends.
- A `TLargeInteger(C)` typecast of a local forces an EBP frame; `PLargeInteger(@C)^` keeps the
  frame-less form.
- A pure-asm function that names `Result` gets an extra `mov al,Result` at the end; using a local
  in the asm avoids it.
- `Result := TClass(Items[I])` saves and restores the arguments; `P := Items[I]; Result :=
  TClass(P)` compiles to `call; ret`.
- Register-convention arguments: deferred simple arguments are loaded right to left; a field
  reached through a pointer is evaluated at once, a field of Self is deferred; an untyped `var`
  argument is loaded before the other deferred ones.
- `if F(...) = X then` uses eax for temporaries while pushing stdcall arguments; `Result := F(...);
  if Result = X` uses ecx.
- `for J := 0 to 255 do ... Pal[J].rgbRed` steps a pointer through the local array.
- With tied weights the first declared local gets eax; `Inc(P)` versus `P := Pointer(Integer(P) +
  n)` changes which local gets edx or ecx.
- A `const R: TRect` parameter copied into a local spills the pointer first; a by-value TRect is
  copied at entry.
- `2 * (A - B)`, `(A - B) * 2` and `shl 1` all compile to `add r,r`.
- Inline assembler compiles verbatim; Delphi 3's assembler has no MMX or CPUID mnemonics, so the
  original encodes them with `DB`.

- Under `$O-` the stack frame holds the parameters, then Result, then the locals, in declaration
  order going down; a parameter that is never read comes after the locals, and a local used in an
  `asm` block gets the first slot.
- Under `$O-` a nil test of a `const` record parameter's address gives `mov eax,[ebp+8]; test eax,eax`,
  while `P = nil` and `Assigned(P)` on a pointer give `cmp [ebp+8],0`.
- A one-label `case` on an enumeration gives `sub al,n / jne`, an `if` gives `cmp`. An empty case
  branch gets a jump table entry to the end of the statement.
- `@S[1]` on a global string calls UniqueString; `Char + Char` builds short string temporaries.
- Under `Q+`, `Inc(X)` gives `add [mem],1 / jno`.

- `while Target - T > 0` compiles with the test only at the bottom; `D := Target - T; while D > 0
  do ... D := Target - T` gives a test at the top and the bottom.
- The order in which parameters move into registers at entry follows their uses.
- A local that the optimizer removes still takes a callee-saved register (`D := GetDisplay;
  D.ShowError(...)`).
- A typecast of Self (`TX(Self).F`, `with TX(Self)`) gets its own register, so cracker classes
  change the code: the original reached protected fields directly.
- An `out` interface argument is cleared by the caller before the call, a `var` one is not, so the
  call sites tell which one the declaration used.
- A field used twice in a condition that contains a call goes into a callee-saved register.
- Consecutive managed locals of one type are finalized together with one `FinalizeArray` or
  `LStrArrayClr`.

- When both operands of a comparison or an addition are register variables, the right operand is
  emitted first: `X1 = X2` gives `cmp X2,X1`, `Dist + Seg` gives `lea [right+left]`.
- Under `$O-` a declared but unused local still takes a stack slot.
- `case B of 0..89: ... else` compiles to `sub eax,90 / jae else`; a case on a two-value enumeration
  to `sub al,1 / jb / je`.
- Division of a real by a constant becomes a multiplication by the reciprocal.

## Checking declarations with export hashes

A package exports every interface symbol as `Unit.Name@XXXXXXXX`; the suffix is a hash of the
declaration (parameter and result types, calling convention, class layout, visibility and
properties, not parameter names). `tools/exports.py <built.dpl> <original.dpl>` compares the
exports of a package built from the recovered source with the original: equal hashes confirm a
declaration the machine code cannot show (types, visibility, published properties), different ones
point at a declaration to fix. Build the package with the `.dpk` of the package directory and
`-LE<dir> -LN<dir>` (Windows paths). Enginep.dpl, first run (2026-10-19): 645 exports equal, 127
different, 257 missing; the missing ones are the value lists, which the original declares in the
Engine unit and Engine.pas keeps in EngineLists.pas.

## Compiler switches (sweep, 2026-10-19)

Every `-$` switch of DCC32 was flipped one at a time against the whole Engine unit (734 functions,
711 identical with the defaults):

| switch | identical | effect |
|---|---|---|
| defaults (`O+ W- B- G+ A+ R- Q- Z1 ...`) | 711 | |
| `O-` | 8 | no register variables at all |
| `W+` | 344 | stack frames everywhere |
| `Q+` / `R+` | 406 / 534 | overflow and range checks |
| `B+` | 570 | full boolean evaluation |
| `A-` | 613 | packed records change field offsets |
| `G-` | 654 | imported data through the import table |
| `D-`, `L-`, `Y+`, `U+`, `I-`, `C-`, `T+`, `P-`, `V-`, `J-` | 711 | code byte-identical to the default build |
| `Z2`, `Z4` | build fails | internal error C4436 |

So Enginep.dpl was compiled with the default switches, and no switch explains the 18 register-choice
leftovers. The switches differ per package, though: aowDPlay.dpl's aowDPlayComp was compiled with
`{$O-,R+,Q+}` (range and overflow checks in the code) and VideoP.dpl with `{$O-}`; their units
carry those directives. Check the switches of every new package first: no register variables means
`$O-`, `bound` and `jno @IntOver` mean `R+` and `Q+`. Delphi 3 has no optimization levels: `$O` is only on or off. `$L-` also drops private
methods and implementation-only routines from the `-GD` map, so a build with it hides functions
from `match.py` instead of matching them. Not tested: the IDE's compiler (`BIN\DCC.DLL`, the same
date and version as `DCC32.EXE`), and Delphi 3 builds other than 3.0 and 3.01.

## Open items

- 18 functions differ in one register choice: `TEReadStorageStream.rwBool`, the `try` frame
  register after a call whose result was just tested or stored (`TEReadStorageStream.rwCreateEObject`,
  `TEWriteStorageStream.rwCreateEObject`, `rwEObject`, `rwEObjectStream`, `CopyStreamToClipboard`,
  `PasteStreamFromClipboard`), a parameter or `Self` left in eax by the original where this compiler
  moves it to a callee-saved register (`TEngine.GetEClass`, `GetEngine`, `TECopyComponent.GetEObject`,
  the three text stream `rwCreateEObject`s, `TCompareStorageStream.rwCreateEObject`,
  `TDebugWriteStream.rwCreateEObject`), a loop variable kept in memory
  (`TPlugInControl.InitializePlugIns`), an unsigned branch (`SortStringsEx`) and the enum conversion in
  `TCompressStream.SaveToStreamEx`. All variants tried compile to the same code, so they look like a
  difference in the compiler build rather than in the source; the original keeps value tracking
  across a `try` frame and does not allocate single-use parameters, this DCC32 (10.0, 4 Aug 1997,
  identical on the 3.01 CD and after the 3.02 patch) does the opposite.
- The five `Assert` line numbers settle only when the whole unit is laid out as the original.
- `GetEngine`, `GetPlugIn`: the same source compiles with Index in ebx for one and in eax for the
  other in the original.
- Next: the remaining units of Enginep.dpl (`zlib`, `EList`, `PlugInM`, `DebMDlg`, `EResGrid`,
  `ImgLComp`, `EngineP`), then the game units (AoWEPACK.dpl and the others).
