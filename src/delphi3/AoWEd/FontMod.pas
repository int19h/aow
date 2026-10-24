unit FontMod;

{ Draft declarations of FontMod, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TFontModule = class;


  { TFontModule (instance size 80, VMT 0040360C) }
  TFontModule = class(TDataModule)
  public
    published
    Age10: TImageLibraryFont; { +0044 }
    SmallFont: TImageLibraryFont; { +0048 }
    Age08: TImageLibraryFont; { +004C }
    public
    published procedure FontModuleCreate; public  { draft }
  end;


var
  FontModule: TFontModule;

implementation

uses HSEdMod;

procedure TFontModule.FontModuleCreate;
begin
  HSEditModule.HSEditFont := SmallFont;
end;


end.
