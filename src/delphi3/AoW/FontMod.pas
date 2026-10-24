unit FontMod;

{ Draft declarations of FontMod, from AoW.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TFontModule = class;


  { TFontModule (instance size 116, VMT 0040380C) }
  TFontModule = class(TDataModule)
  public
    published
    Age8: TImageLibraryFont; { +0044 }
    Age10: TImageLibraryFont; { +0048 }
    Age16s: TImageLibraryFont; { +004C }
    Age10s: TImageLibraryFont; { +0050 }
    Age8s: TImageLibraryFont; { +0054 }
    Sessis14G: TImageLibraryFont; { +0058 }
    AoW15WhiteGrey: TImageLibraryFont; { +005C }
    AoW15BlackBrown: TImageLibraryFont; { +0060 }
    Age10LB: TImageLibraryFont; { +0064 }
    Age10b: TImageLibraryFont; { +0068 }
    Age10bs: TImageLibraryFont; { +006C }
    TBarNumber: TImageLibraryFont; { +0070 }
    public
  end;


implementation


end.
