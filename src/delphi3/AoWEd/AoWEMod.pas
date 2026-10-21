unit AoWEMod;

{ Draft declarations of AoWEMod, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWEngineModule = class;


  { TAoWEngineModule (instance size 68, VMT 0041FDB4) }
  TAoWEngineModule = class(TDataModule)
  public
    procedure AoWEngineModuleCreate;  { draft }
  end;


implementation

procedure TAoWEngineModule.AoWEngineModuleCreate;
begin end;


end.
