# Modules of the game and the order to recover them

The dependencies come from the import tables of the shipped modules, counting only imported code
and data: every package also imports the initialization and finalization of each unit of every
package it `requires`, which says nothing about real use. Function counts and sizes come from
`notes/signatures/*.json`.

| module | units (functions) | uses code of | state |
|---|---|---|---|
| Gfxepack.dpl | GFXE (236), GFXDiag (3) | - | done, 252/262 |
| Dcpack.dpl | DisplayC (165), TWindows08DIBSurface (10) | GFXE | done, 169/174 |
| Ilpack.dpl | ImageLib (470), HashTabU (25), the editors ILSpin, SubImgEd, SImgSEd, ILEdGrid, ILEdForm, PerfDlg, ImgSetEd | GFXE | ImageLib + HashTabU done, 513/536; editors to do (stubs in Ilpack/stubs) |
| Enginep.dpl | Engine (680), ImgLComp (66), EResGrid (45), zlib (17), FMemStr (13), EList (11), DebMDlg (11), PlugInM (8) | ImageLib | done, 865/892 |
| aowDPlay.dpl | aowDPlayComp (35), DPlay, DPLobby | - | done, 39/39 |
| VideoP.dpl | Video (30), VFW (4) | GFXE | done, 35/35 |
| Network.dpl | NetworkE (149) | Engine | done, 148/148 |
| SoundP.dpl | Sound (101), GalSndS (42), SFXEdDlg (17), Galaxy (5), DSound (5) | Engine, SpinEdit | in progress |
| Adcpack.dpl | ZoomControl (13), AdvancedDisplay (12) | GFXE | done, 25/25 |
| aowFXpck.dpl | aowFX (17) | - | done, 18/18 |
| HSEPack.dpl | HSEngine (547), HSMEdit (78), IsoHex (42), ILTer (31), HSLib (25), Terrain (20), HSSEdit (19), Hexagon, Bridge, Road, BorderHx, TerCBox, RndHex, ProgDlg, HSEdMod, HSEdData | DisplayC, Engine, GFXE, ImageLib, Sound | next after ImageLib |
| aowInt.dpl | the AoW UI controls (AoWComp, AoWWindow, AoWMenu, ... 476) | DisplayC, GFXE, ImageLib | after ImageLib |
| AoWInterface.dpl | an older version of the same controls (375) | DisplayC, GFXE, ImageLib | not used by AoW.exe or AoWEd.exe |
| Vcladdon.dpl | TB97 (114), SpinEdit (52), EStrGrid, FilCtl95 | - | third party (Toolbar97, SpinEdit) |
| Localize.dpl | Iv* units (1096) | - | third party (Multilizer) |
| ims.dpl | ag*/ms* units (605) | - | third party (an internet suite) |
| AoWEPACK.dpl | AoWE (4042), City (191), spells, abilities, events, AoWReg, AoWSetup, ... (6872) | Engine, GFXE, HSEPack units, ImageLib, Localize, NetworkE, Sound, aowFX | the game logic, 734 KB |
| AoWTCPCK.dpl | AoWTC (174), CombatTE (38), combat map units (565) | AoWEPACK units, Engine, GFXE, HSEPack units, ImageLib, NetworkE, Sound, aowFX | tactical combat |
| AbilityP.dpl | MoveAb, ImmAb, StrikeAb, ShootAb, UnitAb, AbilPack (44) | AoWE, Engine | |
| AOWTools.dpl | Scanner (42), AoWBookWindow, TurnButton, lines, StartMenu (109) | AoWE, PageTurnCtrl, GFXE, HSEngine, ImageLib, aowInt units | |
| ILToolsP.dpl | ILTools, ILSeqEd, Str2Clip (68) | DisplayC, ImageLib, SpinEdit | editor tools |
| AoW.exe | the game's forms and main program (1371) | everything above except AoWInterface, ILToolsP | |
| AoWEd.exe | the map editor's forms (892) | the above plus ILToolsP, Vcladdon | |

## Layout of the recovered source

- `src/delphi3/` holds the units of Enginep.dpl (Engine.pas with `inc/HashTab.PAS`, EngineLists.pas,
  FMemStr.pas, zlib.pas with the zlib object files in `obj/`, EList.pas, PlugInM.pas, DebMDlg.pas,
  ImgLComp.pas, EResGrid.pas), built against the recovered ImageLib in `src/delphi3/Ilpack`.
- Every other package gets a directory `src/delphi3/<Package>/` with its units, its own host program
  `matchtest.dpr` and its own `match-aliases.json`. Units of other packages are found through
  `-U` paths at build time.
- A host program only has to reference every class and every non-virtual method; it is linked, never
  run. Build with `DCC32 -GD -B -E<outdir> -N<outdir> matchtest.dpr` into a directory outside the
  repository, then compare with `tools/match.py` against the module.
- Third-party packages (Vcladdon, Localize, ims) are out of scope for recovery unless the game's own
  code needs their declarations; the source port will replace them.
