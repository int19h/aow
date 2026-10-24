unit aowIntGfxMod;

{ Draft declarations of aowIntGfxMod, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AOWInterfaceImgLib;

type
  TIntGfxMod = class;


  { TIntGfxMod (instance size 252, VMT 004039E8) }
  TIntGfxMod = class(TDataModule)
  public
    published
    GenericT: TInterfaceIL; { +0044 }
    GenericF: TInterfaceIL; { +0048 }
    CeltDeco: TInterfaceIL; { +004C }
    Cursors: TInterfaceIL; { +0050 }
    ScanTiles: TInterfaceIL; { +0054 }
    ScanFog: TInterfaceIL; { +0058 }
    ScanHiLites: TInterfaceIL; { +005C }
    PyreAnim: TInterfaceIL; { +0060 }
    UnitBGs: TInterfaceIL; { +0064 }
    FCWin: TInterfaceIL; { +0068 }
    Menus: TInterfaceIL; { +006C }
    DragonMenu: TInterfaceIL; { +0070 }
    ScanWin: TInterfaceIL; { +0074 }
    GenericI: TInterfaceIL; { +0078 }
    UnitWin: TInterfaceIL; { +007C }
    UnitIcons: TInterfaceIL; { +0080 }
    TurnButton: TInterfaceIL; { +0084 }
    TBWin: TInterfaceIL; { +0088 }
    BookPL: TInterfaceIL; { +008C }
    BookPR: TInterfaceIL; { +0090 }
    FactionWin: TInterfaceIL; { +0094 }
    RelWin: TInterfaceIL; { +0098 }
    WorldMap: TInterfaceIL; { +009C }
    BookWin: TInterfaceIL; { +00A0 }
    TitleScreen: TInterfaceIL; { +00A4 }
    Shields: TInterfaceIL; { +00A8 }
    ProdWin: TInterfaceIL; { +00AC }
    FireLg: TInterfaceIL; { +00B0 }
    MiscArt: TInterfaceIL; { +00B4 }
    Units: TInterfaceIL; { +00B8 }
    SoundWin: TInterfaceIL; { +00BC }
    TitleIcons: TInterfaceIL; { +00C0 }
    MoveIcons: TInterfaceIL; { +00C4 }
    LBIcons: TInterfaceIL; { +00C8 }
    EventIcons: TInterfaceIL; { +00CC }
    ProdIcons: TInterfaceIL; { +00D0 }
    GenericB: TInterfaceIL; { +00D4 }
    GenericE: TInterfaceIL; { +00D8 }
    GenericS: TInterfaceIL; { +00DC }
    VictoryFrames: TInterfaceIL; { +00E0 }
    EndScene: TInterfaceIL; { +00E4 }
    PyreFrames: TInterfaceIL; { +00E8 }
    CityWin: TInterfaceIL; { +00EC }
    CampaignTrans: TInterfaceIL; { +00F0 }
    ScanObj: TImageLibrary; { +00F4 }
    PlyrIcns: TInterfaceIL; { +00F8 }
    public
  end;


var
  IntGfxMod: TIntGfxMod;

implementation


end.
