unit AoWTer;

{ Draft declarations of AoWTer, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWTerrain = class;
  TAoWTerrainResource = class;


  { TAoWTerrain (instance size 20, VMT 5579BA1C) }
  TAoWTerrain = class(TTerrainMO)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure ValidateDenseVegetationBurned(A1: Integer);  { draft }
    procedure ValidateDeadTreeRegrow;  { draft }
  end;

  { TAoWTerrainResource (instance size 76, VMT 5579BBC0) }
  TAoWTerrainResource = class(TTerrainMOR)
  public
    F_AoWTerrainResource_48: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
  end;

procedure RegisterAoWTerrain;  { draft }

implementation

procedure TAoWTerrain.ValidateDenseVegetationBurned(A1: Integer);
begin end;

procedure TAoWTerrain.ValidateDeadTreeRegrow;
begin end;

procedure TAoWTerrain.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TAoWTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure RegisterAoWTerrain;
begin end;


initialization
finalization

end.
