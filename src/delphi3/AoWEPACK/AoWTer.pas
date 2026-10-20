unit AoWTer;

{ AoWTer of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TAoWTerrain = class;
  TAoWTerrainResource = class;


  { TAoWTerrain (instance size 20, VMT 5579BA1C) }
  TAoWTerrain = class(TTerrainMO)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure ValidateDenseVegetationBurned(Info: Pointer);
    procedure ValidateDeadTreeRegrow;
  end;

  { TAoWTerrainResource (instance size 76, VMT 5579BBC0): +$48 FMapFieldResponse (stream id 20). }
  TAoWTerrainResource = class(TTerrainMOR)
  public
    FMapFieldResponse: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
  end;

procedure RegisterAoWTerrain(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  TBurnInfo = packed record
    Reserved: array[0..29] of Byte;
    Severity: Byte;
  end;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;

{ needs: AoWE.TAoWHSMap.Random must return Integer; EAX is tested at $5579BD4E. }
function TerrainRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
asm
  JMP TAoWHSMap.Random
end;

procedure TAoWTerrain.ValidateDenseVegetationBurned(Info: Pointer);
var
  R: TTerrainMOR;
  OldOwner: TECustomNode;
begin
  if (TBurnInfo(Info^).Severity >= 2) and (Smallint(FResource.TerrainList.Overlay[0]) = 1) then
  begin
    R := FindCompatibleResource(TTerrainMOR(FResource).TerrainType, 3, 3);
    if R <> nil then
    begin
      UpdateTerrain(TMapLevel(Owner.Owner), GetXhx, GetYhx);
      OldOwner := Owner;
      RemoveFromMap;
      SetResource(R);
      Owner := OldOwner;
      PlaceOnMap;
      if FResource.Level <= 15 then FResource.Engine.HSMap.StaticSceneInvalid := True;
      OverrideTerrain;
    end;
  end;
end;

procedure TAoWTerrain.ValidateDeadTreeRegrow;
var
  R: TTerrainMOR;
  OldOwner: TECustomNode;
begin
  if Owner.FindOwnedChild($2077E) = nil then
    if TerrainRandom(WorldMap^, 20) = 0 then
    begin
      R := FindCompatibleResource(TTerrainMOR(FResource).TerrainType, 1, 0);
      if R <> nil then
      begin
        OldOwner := Owner;
        RemoveFromMap;
        SetResource(R);
        Owner := OldOwner;
        PlaceOnMap;
        if FResource.Level <= 15 then FResource.Engine.HSMap.StaticSceneInvalid := True;
        OverrideTerrain;
      end;
    end;
end;

procedure TAoWTerrain.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then
    try
      if Smallint(TTerrainMOR(FResource).DecorationType) = 3 then ValidateDeadTreeRegrow;
    except
      { Original ignores regrowth failures. }
    end;
end;

procedure TAoWTerrain.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1122 then
  begin
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
    begin
      Msg.Result := TAoWTerrainResource(FResource).FMapFieldResponse;
      Exit;
    end;
  end
  else if Msg.MsgID = $1105 then
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
      ValidateDenseVegetationBurned(Pointer(Msg.Param[0]));
end;

procedure TAoWTerrainResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FMapFieldResponse, 20);
end;

procedure RegisterAoWTerrain(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAoWTerrain, TAoWTerrainResource]);
end;


initialization
finalization

end.
