# Modules of the game and the order to recover them

The import tables of the shipped modules give the dependency order (bottom first). Function counts
and code sizes come from `notes/signatures/*.json`; third-party packages are marked.

| module | units (functions) | depends on | note |
|---|---|---|---|
| Gfxepack.dpl | GFXE (236), GFXDiag (3) | VCL | surfaces, blitters, DirectDraw; 40 KB |
| Dcpack.dpl | DisplayC (165), TWindows08DIBSurface (10) | Gfxepack | display/DIB layer; 18 KB |
| Ilpack.dpl | ImageLib (470), ILSpin, HashTabU, SubImgEd, SImgSEd, ILEdGrid, ILEdForm, PerfDlg, ImgSetEd | Gfxepack | image library + editors; 78 KB |
| Enginep.dpl | Engine (680), ImgLComp (66), EResGrid (45), zlib (17), FMemStr (13), EList (11), DebMDlg (11), PlugInM (8) | Ilpack, Gfxepack | object model, persistence; done except the small units |
| SoundP.dpl | Sound (101), GalSndS (42), SFXEdDlg (17), Galaxy (5), DSound (5) | Enginep, Ilpack, Gfxepack, Vcladdon | 17 KB |
| Network.dpl | NetworkE (149) | Enginep, Ilpack, Gfxepack | 7 KB |
| aowFXpck.dpl | aowFX (17) | Ilpack, Gfxepack | 2 KB |
| VideoP.dpl | Video (30), VFW (4) | Gfxepack | 6 KB |
| aowDPlay.dpl | aowDPlayComp (35) | VCL, DirectPlay | 15 KB |
| HSEPack.dpl | HSEngine (547), HSMEdit (78), IsoHex (42), ILTer (31), HSLib (25), Terrain (20), HSSEdit (19), Hexagon, Bridge, Road, BorderHx, TerCBox, RndHex, ProgDlg | Enginep, Ilpack, Gfxepack, Dcpack, SoundP | hex map engine; 73 KB |
| aowInt.dpl, AoWInterface.dpl | the AoW UI controls (AoWComp, AoWWindow, AoWMenu, ...) (476 / 375) | Dcpack, Ilpack, Gfxepack | two versions of the same library; 105 KB each |
| Vcladdon.dpl | TB97 (114), SpinEdit (52), EStrGrid, FilCtl95 | VCL | third party (Toolbar97, SpinEdit) |
| Localize.dpl | Iv* units (1096) | VCL | third party (Multilizer); 150 KB |
| ims.dpl | ag*/ms* units (605) | VCL | third party (Internet suite); 83 KB |
| AoWEPACK.dpl | AoWE (4042), City (191), spells, abilities, events, AoWReg, AoWSetup, ... (6872) | HSEPack, Enginep, Ilpack, Gfxepack, SoundP, Network, Localize, aowFXpck | the game logic; 734 KB |
| AoWTCPCK.dpl | AoWTC (174), CombatTE (38), combat map units (565) | AoWEPACK and the above | tactical combat; 174 KB |
| AbilityP.dpl | MoveAb, ImmAb, StrikeAb, ShootAb, UnitAb, AbilPack (44) | AoWEPACK | 8 KB |
| Adcpack.dpl | ZoomControl, AdvancedDisplay (34) | Gfxepack | 3 KB |
| AOWTools.dpl | Scanner (42), AoWBookWindow, TurnButton, lines, StartMenu (109) | AoWEPACK, aowInt, Dcpack | 14 KB |
| ILToolsP.dpl | ILTools, ILSeqEd, Str2Clip (68) | Dcpack, Ilpack, Vcladdon | 7 KB |
| AoW.exe | the game's forms and main program (1371) | everything | 249 KB |
| AoWEd.exe | the map editor's forms (892) | everything | 91 KB |

## Layout of the recovered source

- `src/delphi3/` holds the units of Enginep.dpl (Engine.pas with `inc/HashTab.PAS`, EngineLists.pas,
  FMemStr.pas, zlib.pas, EList.pas, PlugInM.pas, DebMDlg.pas, ImgLComp.pas, EResGrid.pas) and the
  stub `ImageLib.pas` for what the Engine unit calls in Ilpack.dpl.
- Every other package gets a directory `src/delphi3/<Package>/` with its units, its own host program
  `matchtest.dpr` and its own `match-aliases.json`. Units of other packages are found through
  `-U` paths at build time.
- A host program only has to reference every class and every non-virtual method; it is linked, never
  run. Build with `DCC32 -GD -B -E<outdir> -N<outdir> matchtest.dpr` into a directory outside the
  repository, then compare with `tools/match.py` against the module.
- Third-party packages (Vcladdon, Localize, ims) are out of scope for recovery unless the game's own
  code needs their declarations; the source port will replace them.
