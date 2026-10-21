unit CombatHex;

{ Combat terrain hexagons from AoWTCPCK.dpl, with checked arithmetic and indices. }

{$O-,R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWHex, AoWE, AoWTC;

type
  TCombatHexagon = class;
  TCombatHexagonResource = class;
  TWaterCombatHexagon = class;
  TWaterCombatHexagonResource = class;


  { TCombatHexagon (instance size 20, VMT 0040340C) }
  TCombatHexagon = class(TAbstractHexagon)
  public
    FImageVariant: Byte; { $10 }
    FTransitions: array[1..3] of Byte; { $11..$13 }
    class function ClassID: Integer; override;
    procedure TerrainChanged(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    procedure UpdateTransitions; override;
    procedure UpdateTransition(Side: Byte);
  end;

  { TCombatHexagonResource (instance size 56, VMT 004035A8) }
  TCombatHexagonResource = class(TAbstractHexagonResource)
  public
    FTransitionLibrary: TCustomImageLibrary; { $34 }
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

  { TWaterCombatHexagon (instance size 32, VMT 004036A8) }
  TWaterCombatHexagon = class(TAoWWaterHexagon)
  public
    class function ClassID: Integer; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
  end;

  { TWaterCombatHexagonResource (instance size 56, VMT 00403854) }
  TWaterCombatHexagonResource = class(TAoWWaterHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetHexagonControl: HSEngine.THexagonControl; override;
  end;

procedure RegisterCombatHexagon(AEngine: TEngine);

implementation

const
  TransitionNeighbours: array[1..3] of Byte = (6, 1, 2);

class function TCombatHexagon.ClassID: Integer;
begin Result := $220500; end;

function TCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

procedure TCombatHexagon.UpdateTransition(Side: Byte);
var
  MapLevel: TMapLevel;
  ImageIndex: Integer;
  NeighbourTerrain, TerrainType: ShortInt;
  X, Y: Integer;
begin
  MapLevel := TMapLevel(Owner.Owner);
  CenterHNtoHX(TMapField(Owner).Xhx, TMapField(Owner).Yhx,
    TransitionNeighbours[Side], X, Y);
  if (X >= 0) and (Y >= 0) and (X < MapLevel.Width) and (Y < MapLevel.Height) then
  begin
    NeighbourTerrain := MapLevel.GetField(X, Y).TerrainType;
    TerrainType := FResource.TerrainList.GetTerrain(0);
    ImageIndex := -1;
    if (NeighbourTerrain <> TerrainType) and (NeighbourTerrain <> 7) then
    begin
      if TerrainType = 0 then
      begin
        if NeighbourTerrain = 6 then ImageIndex := 10
        else ImageIndex := NeighbourTerrain + 4;
      end
      else if TerrainType = 6 then
      begin
        if NeighbourTerrain = 0 then ImageIndex := 16
        else ImageIndex := NeighbourTerrain + 10;
      end
      else if TerrainType = 12 then ImageIndex := 17
      else if TerrainType = 10 then
      begin
        if NeighbourTerrain = 12 then ImageIndex := 18
        else if NeighbourTerrain = 13 then ImageIndex := 19
        else if NeighbourTerrain = 9 then ImageIndex := 20;
      end
      else if TerrainType = 13 then
      begin
        if NeighbourTerrain = 12 then ImageIndex := 21
        else if NeighbourTerrain = 10 then ImageIndex := 22
        else if NeighbourTerrain = 9 then ImageIndex := 23;
      end
      else if TerrainType = 9 then
      begin
        if NeighbourTerrain = 12 then ImageIndex := 24
        else ImageIndex := 25;
      end
      else ImageIndex := TerrainType - 1;
    end;
    if ImageIndex <> -1 then
    begin
      ImageIndex := Random(2) * 3 + ImageIndex * 6 + (Side - 1);
      if TCombatHexagonResource(FResource).FTransitionLibrary.GetSafe(ImageIndex) <> nil then
        FTransitions[Side] := ImageIndex
      else FTransitions[Side] := 255;
    end
    else FTransitions[Side] := 255;
  end;
end;

procedure TCombatHexagon.UpdateTransitions;
var Side: Integer;
begin for Side := 1 to 3 do UpdateTransition(Side); end;

procedure TCombatHexagon.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin
  if HN = 0 then
    case Info.HN of
      6: UpdateTransition(1);
      1: UpdateTransition(2);
      2: UpdateTransition(3);
    end;
end;

procedure TCombatHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
  Images: TCustomImageLibrary;
  Side: Integer;
begin
  if TMapField(Owner).OverlayType <> 4 then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    Xhp := Xhp - XhpSurf - 8;
    Yhp := Yhp - YhpSurf;
    Images := FResource.ImageSequenceList.GetImageSequence(0).ImageLibrary;
    Images[FImageVariant].Show(Xhp, Yhp, SurfaceDesc);
    Images := TCombatHexagonResource(FResource).FTransitionLibrary;
    for Side := 1 to 3 do
      if FTransitions[Side] <> 255 then
        Images[FTransitions[Side]].Show(Xhp - 8, Yhp - 16, SurfaceDesc);
  end;
end;

procedure TCombatHexagon.Activate;
begin
  inherited Activate;
  FImageVariant := Random(12);
end;

procedure TCombatHexagon.TerrainChanged(const Msg: HSEngine.THSTerrainInfo);
begin
  if Msg.TerrainType in [0, 6, 14] then
      if Msg.TerrainType <> 14 then
        TAoWHSSet(FResource.Engine.HSSet).FCombatHexagons.Place(
          AoWCombatMap.MapContainer, GetXhx, GetYhx, GetLhx, Msg.TerrainType)
      else
        TAoWHSSet(FResource.Engine.HSSet).FCombatHexagons.Place(
          AoWCombatMap.MapContainer, GetXhx, GetYhx, GetLhx, 0);
end;

class function TCombatHexagonResource.ClassID: Integer;
begin Result := $220501; end;

class function TCombatHexagonResource.ResourceEditName: string;
begin Result := 'Combat Hexagon'; end;

function TCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin Result := TAoWHSSet(Engine.HSSet).FCombatHexagons; end;

procedure TCombatHexagonResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  if (Msg.MsgID <> $10014) or not (TerrainList.GetTerrain(0) in [0, 6]) then
    inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10055 then Msg.Result := 5;
  if Msg.MsgID = $20000008 then
    FTransitionLibrary := AoWHSSet.ImageLibraryManager.LinkToIL(
      [icDisk], 'TCombat\Base_Hex\CTransHx.ILB');
end;

function TCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := $220500; end;

function TCombatHexagonResource.GetCellImage: ImageLib.TLibraryImage;
begin
  Result := nil;
  if (ImageSequenceList <> nil) and (ImageSequenceList.Count > 0) and
    (ImageSequenceList.GetImageSequence(0) <> nil) then
    Result := ImageSequenceList.GetImageSequence(0).ImageLibrary[10];
  if Result = nil then Result := inherited GetCellImage;
end;

function TWaterCombatHexagon.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

class function TWaterCombatHexagon.ClassID: Integer;
begin Result := $220597; end;

class function TWaterCombatHexagonResource.ClassID: Integer;
begin Result := $220598; end;

class function TWaterCombatHexagonResource.ResourceEditName: string;
begin Result := 'Combat Water/Ice hex'; end;

function TWaterCombatHexagonResource.ResourceUserClassID: Integer;
begin Result := $220597; end;

function TWaterCombatHexagonResource.GetHexagonControl: HSEngine.THexagonControl;
begin Result := TAoWHSSet(Engine.HSSet).FCombatHexagons; end;

procedure RegisterCombatHexagon(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatHexagonResource, TCombatHexagon,
    TWaterCombatHexagon, TWaterCombatHexagonResource]);
end;

initialization
finalization

end.
