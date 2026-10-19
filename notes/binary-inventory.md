# Age of Wonders 1.36: binary inventory

Date: 2026-10-19. Source: the GOG installation in `D:\Games\GOG\Age of Wonders`.
The scripts in `tools/` produced the symbol tables in `notes/symbols/`.

## Compiler

The game is built with Delphi 3, not C++Builder. The evidence:

- The runtime package is `vcl30.dpl`. The `.dpl` extension exists only in Delphi 3. Delphi 4 renamed packages to `.bpl`.
- The binaries contain Pascal source names from `Assert` calls, for example `Combat.pas`, `AI.pas`, `Engine.pas`, `GFXE.pas`, `Diplomacy.pas`. They contain no `.cpp` names.
- Package exports use the Delphi 3 format `Unit.Class.Method@hash`, not the C++ `@Unit@Class@Method$qqr...` mangling.
- All PE headers show linker version 2.25 and the fixed Borland timestamp 1992-06-19.

All modules are 32-bit x86 (machine 0x014C), GUI subsystem.

## Symbol coverage

A Delphi package exports every unit-level symbol, because other packages must link against it.
As a result, the 21 game packages carry names for 338 units, 1,378 classes, and about 16,100 methods and functions.
This is the same information as a linker map file. In addition, the binaries hold RTTI (class names, published property names and offsets, enumeration element names) and binary DFM form resources.

The two executables export nothing. `AoW.exe` has 364 KB of code and `AoWEd.exe` has 188 KB. Their code is mostly dialogs and the map viewer. Their RTTI and form resources still give class and property names.

## Modules

| Module | Code (KB) | Units | Classes | Named functions | Role |
|---|---|---|---|---|---|
| AoWEPACK.dpl | 1,993 | 93 | 835 | 8,917 | Game engine: units, armies, cities, spells, abilities, structures, combat, AI, diplomacy, campaign |
| AoW.exe | 364 | ? | ? | 0 exported | Main program: map viewer, dialogs, fast combat window |
| AoWTCPCK.dpl | 417 | 22 | 73 | 613 | Tactical combat map: combat hexes, terrain, walls, structures |
| Localize.dpl | 309 | 48 | 82 | 1,053 | Third-party localization components (Polyhedron `Iv*` units) |
| aowInt.dpl | 246 | 30 | 31 | 460 | Game UI controls |
| AoWInterface.dpl | 242 | 27 | 25 | 359 | Game UI controls |
| Enginep.dpl | 188 | 9 | 68 | 933 | Generic engine base: lists, streams, zlib, plug-in manager |
| AoWEd.exe | 188 | ? | ? | 0 exported | Map editor |
| HSEPack.dpl | 182 | 17 | 63 | 927 | Hex map engine: hexagons, terrain, roads, bridges, map editing |
| Ilpack.dpl | 178 | 10 | 46 | 703 | Image library (`.ILB` files), hash tables. Holds the known `MapViewer.ShowScene` bug |
| ims.dpl | 175 | 33 | 49 | 565 | Third-party internet suite: SMTP, POP3, MIME, FTP, HTTP. Used for play by email |
| Vcladdon.dpl | 80 | 5 | 11 | 188 | Third-party VCL add-ons |
| Gfxepack.dpl | 74 | 3 | 20 | 288 | DirectDraw layer (`GFXE` unit) |
| Dcpack.dpl | 54 | 2 | 18 | 197 | Display controls drawn on DirectDraw surfaces |
| SoundP.dpl | 41 | 6 | 15 | 306 | DirectSound and Galaxy Sound System bindings |
| AOWTools.dpl | 41 | 8 | 7 | 97 | Tools |
| aowDPlay.dpl | 25 | 4 | 3 | 113 | DirectPlay 4 and DirectPlay Lobby bindings |
| Network.dpl | 21 | 2 | 17 | 174 | Abstract network layer (`NetworkE` unit) |
| ILToolsP.dpl | 19 | 4 | 4 | 61 | Image library tools |
| AbilityP.dpl | 15 | 7 | 6 | 30 | Ability plug-ins |
| VideoP.dpl | 15 | 3 | 1 | 95 | Video for Windows bindings, intro movie |
| Adcpack.dpl | 10 | 3 | 2 | 27 | Small display controls |
| aowFXpck.dpl | 6 | 2 | 2 | 23 | Effects |

Game code without the VCL: about 4.9 MB of x86. Third-party code (Localize, ims, Vcladdon, zlib) is about 0.6 MB of that and can be replaced by libraries instead of decompiled.

Borland runtime packages, no decompilation needed: `vcl30.dpl`, `VCLX30.DPL`, `VCLDB30.DPL`, `VCLDBX30.DPL`, `VCLSMP30.DPL`, `QRPT30.DPL`, `TEE30.DPL`, `TEEDB30.DPL`, `TEEUI30.DPL`, `IBEVNT30.DPL`.

Other files: `Galaxy.dll` is the Galaxy Sound System (exports `glx*`), which plays the Impulse Tracker (`.IT`) music. It is not GOG Galaxy. `Launcher.exe`, `AoWCompat.exe` (identical to `AoW.exe`), and the `Microsoft.VC80.CRT` folder come from GOG.

## Platform dependencies

The platform code is isolated in small packages, which is the main reason a port is practical:

- Graphics: `Gfxepack.dpl` (DirectDraw 1 through 3, palettes, clippers) and `Dcpack.dpl`.
- Sound: `SoundP.dpl` (DirectSound, Galaxy).
- Network: `aowDPlay.dpl` (DirectPlay 4, lobby) behind the abstract `Network.dpl`.
- Video: `VideoP.dpl` (Video for Windows).
- Email: `ims.dpl` (Winsock).

The engine package `AoWEPACK.dpl` imports only kernel32, user32, gdi32, and other game packages. It has no direct DirectX imports.

## Why the known bug was possible

The 16 bytes patched in `Ilpack.dpl` decode to a loop that aligns a pointer with `and esi, 0x0FFFFFFC`.
The mask also clears the top four address bits, so any buffer above address 0x10000000 breaks.
The game packages load at image bases 0x55200000 and up, and modern heaps also live high.
The 2022 fix changes the mask to 0xFFFFFFFC.

## Hooking

Because every engine function is exported by name, a replacement DLL can find any function with `GetProcAddress`.
No address tables and no version checks are needed. This makes incremental replacement (one function at a time, inside the running game) much simpler than in projects such as OpenRCT2.
Delphi 3 uses the `register` calling convention: the first three arguments go in EAX, EDX, ECX.

## Delphi 3 metadata recovered by `tools/delphi_rtti.py`

Every class has a VMT (virtual method table). In Delphi 3 the fields before the first virtual slot are:
SelfPtr at -64, IntfTable -60, AutoTable -56, InitTable -52, TypeInfo -48, FieldTable -44, MethodTable -40,
DynamicTable -36, ClassName -32, InstanceSize -28, Parent -24, then SafeCallException, DefaultHandler,
NewInstance, FreeInstance, Destroy at -20 through -4. User virtual methods start at offset 0.

In a package, the export `Unit..TClass@hash` is the VMT address. From the VMTs the script recovers,
for all 1,438 classes in the game modules: the class name, the parent class (also across packages, through
the import table), the instance size, the count of virtual methods, the published fields of forms,
the published methods (event handlers), and the published properties with their types and the field
offsets or accessor methods behind them. The output is in `notes/rtti/`.

For the two executables, which export nothing, the RTTI is the main source of names. `AoW.exe` holds 84 classes,
of which 78 are forms (`TDataModule` descendants drawn on DirectDraw). Their field tables name 2,862 UI components
with their offsets and types (`TAOWButton`, `TAOWListBox`, and so on), and their method tables name 950 event
handlers with their addresses. `tools/ghidra/CreateDelphiFunctions.java` applies those names in Ghidra and also
creates a function for every VMT slot, which call-following analysis never reaches.

Engine classes such as `TAbstractUnit` (60 bytes, 110 virtual methods), `TUnit`, `THero` (156 bytes),
`TArmy`, `TStructure` (124 virtuals), and `TPlayer` have no published properties, so their field names
must come from the decompiled code, mostly from their `LoadFromStream` and `SaveToStream` methods.

## Ghidra

Project: `C:\Tools\ghidra-projects\aow`. Import options: `-processor x86:LE:32:default -cspec borlanddelphi`.
The PE loader applies the export names, so package functions appear under their Delphi names.

Delphi compiles the end of a `try/finally` block as `push <continue>; <finally body>; ret`.
Ghidra reads that `ret` as a return and drops the rest of the function. `tools/ghidra/FixDelphiFinally.java`
turns those returns into branches (114 sites in Ilpack.dpl alone) and the decompiler then shows the full function.

Decompiler quality on compiled Pascal is good: calls resolve to named methods, virtual calls show as VMT
offsets, loops and conditions survive. Hand-written assembly (the blitters in `ImageLib`) decompiles to
correct but hard-to-read pointer code; those routines are better rewritten from their purpose than translated.
A reconstruction sample is in `notes/samples/ImageLib_LoadFromStream.pas`.

## Installation state

`Ilpack.dpl` in this installation is unpatched: it contains the original byte sequence three times.
