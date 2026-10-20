unit HxBridge;

{ Hexagon bridges of AoWEPACK.dpl; layouts and VMT order from notes/classes.json. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  THexagonBridge = class;
  THexagonBridgeResource = class;


  { THexagonBridge (instance size 28, VMT 557994E0): +$10 FTerrain,
    +$11 FDirection (-1 invalid), +$14 FSideA, +$18 FSideB. }
  THexagonBridge = class(TAbstractRoad)
  public
    FTerrain: Shortint;
    FDirection: Shortint;
    FReserved: array[0..1] of Byte;
    FSideA: TByteList;
    FSideB: TByteList;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetTerrain(Index: Integer): Shortint; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure ChangeTerrain(const Msg: HSEngine.THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function LinkToResource(AEngine: Engine.TEngine): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; override;
    function DirectionValid(MapField: TMapField; Direction: Shortint): Boolean;
    procedure UpdateExclusiveMoves;
  end;

  { THexagonBridgeResource (instance size 52, VMT 5579967C) }
  THexagonBridgeResource = class(TAbstractRoadResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterHexagonBridge(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  TBridgeMoveData = packed record
    Reserved: array[0..48] of Byte;
    Costs: array[0..15, 0..15] of Shortint;
  end;

const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;

constructor THexagonBridge.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FDirection := -1;
  FSideA := TByteList.Create;
  FSideB := TByteList.Create;
end;

destructor THexagonBridge.Destroy;
begin
  inherited Destroy;
  FSideA.Free;
  FSideB.Free;
end;

class function THexagonBridge.ClassID: Integer;
begin
  Result := $2087A;
end;

function THexagonBridge.GetLevel: Byte;
begin
  Result := 26;
end;

function THexagonBridge.LinkToResource(AEngine: TEngine): Boolean;
begin
  Result := inherited LinkToResource(AEngine);
  FTerrain := FResource.TerrainList.Terrain[0];
end;

function THexagonBridge.GetTerrain(Index: Integer): Shortint;
begin
  if Index = 0 then Result := FTerrain else Result := -2;
end;

function THexagonBridge.GetShowPriority: Integer;
var
  Xhp, Yhp: Integer;
begin
  with TMapField(Owner) do
  begin
    Xhp := Xhx * 32 + 8;
    Yhp := (Xhx and 1) * 16 + Yhx * 32;
  end;
  Result := $68000000 + Yhp shl 13 + (Xhp + 8);
end;

procedure THexagonBridge.Connect;
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 1);
  while Walk.Radius <= 1 do
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Level.GetField(Walk.X, Walk.Y).AddHS(Self, Walk.HN);
      { Original bug: the walk never advances when a neighbour is out of bounds. }
      WalkToNextHN(Walk);
    end;
  inherited Connect;
end;

procedure THexagonBridge.Disconnect;
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 1);
  while Walk.Radius <= 1 do
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Level.GetField(Walk.X, Walk.Y).RemoveHS(Self);
      { Original bug: the walk never advances when a neighbour is out of bounds. }
      WalkToNextHN(Walk);
    end;
  inherited Disconnect;
end;

procedure THexagonBridge.UpdateMapField(const Info: THSMapFieldInfo);
begin
  if Info.HN <> 0 then
    TAoWMapField(Info.MapField).FFieldFlags :=
      TAoWMapField(Info.MapField).FFieldFlags or $8000;
end;

procedure THexagonBridge.MoveExclusive(const Info: THSSenderInfo);
var
  I, Xhx, Yhx: Integer;
  MapField: TMapField;
begin
  if Info.HN <> 0 then
    if FSideA.IndexOf(Info.HN) <> -1 then
    begin
      for I := 0 to FSideB.Count - 1 do
      begin
        CenterHNtoHX(TMapField(Owner).Xhx, TMapField(Owner).Yhx, FSideB[I], Xhx, Yhx);
        MapField := WorldMap^.MapContainer.GetField(Xhx, Yhx, TMapField(Owner).Lhx);
        TMoveControl(Info.Sender).ExecuteExternalMove(Integer(Info.MapField), Integer(MapField),
          TBridgeMoveData(Pointer(Info.Sender)^).Costs[MapField.TerrainType, MapField.OverlayType]);
      end;
    end
    else if FSideB.IndexOf(Info.HN) <> -1 then
      for I := 0 to FSideA.Count - 1 do
      begin
        CenterHNtoHX(TMapField(Owner).Xhx, TMapField(Owner).Yhx, FSideA[I], Xhx, Yhx);
        MapField := WorldMap^.MapContainer.GetField(Xhx, Yhx, TMapField(Owner).Lhx);
        TMoveControl(Info.Sender).ExecuteExternalMove(Integer(Info.MapField), Integer(MapField),
          TBridgeMoveData(Pointer(Info.Sender)^).Costs[MapField.TerrainType, MapField.OverlayType]);
      end;
end;

procedure THexagonBridge.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  FResource.ImageLibrary[FDirection].Show(Xhp - XhpSurf - 23, Yhp - YhpSurf - 20, SurfaceDesc);
end;

procedure THexagonBridge.Activate;
begin
  inherited Activate;
  UpdateExclusiveMoves;
end;

function THexagonBridge.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  MapField: TMapField;
begin
  MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
  Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx) and
    (DirectionValid(MapField, 0) or DirectionValid(MapField, 1) or DirectionValid(MapField, 2));
end;

function THexagonBridge.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  Road: THexagonSprite;
  MapField: TMapField;
begin
  MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
  Road := MapField.FindHS(TAbstractRoad);
  if Road <> nil then Road.Destroy;
  Road := THexagonSprite(Owner);
  Owner := MapField;
  FStatus := FStatus + [moPlacedOnMap];
  FTerrain := MapField.TerrainType;
  { Original bug: refresh the old owner's owner as a map field. }
  if Road <> nil then TMapField(Road.Owner).UpdateOverlayType;
  MapField.UpdateOverlayType;
  MapContainer.Map.InvalidateStaticScene(Xhx, Yhx, Lhx);
  UpdateTransitions;
  Result := FDirection <> -1;
end;

function THexagonBridge.DirectionValid(MapField: TMapField; Direction: Shortint): Boolean;
var
  Level: TMapLevel;
  Xhx, Yhx: Integer;
begin
  Result := False;
  Level := TMapLevel(MapField.Owner);
  CenterHNtoHX(MapField.Xhx, MapField.Yhx, Direction + 1, Xhx, Yhx);
  if (Xhx >= 0) and (Yhx >= 0) and (Xhx < Level.Width) and (Yhx < Level.Height) then
    if Land(Level.GetField(Xhx, Yhx).TerrainType) then
    begin
      CenterHNtoHX(MapField.Xhx, MapField.Yhx, Direction + 4, Xhx, Yhx);
      if (Xhx >= 0) and (Yhx >= 0) and (Xhx < Level.Width) and (Yhx < Level.Height) then
        Result := Land(Level.GetField(Xhx, Yhx).TerrainType);
    end;
end;

procedure THexagonBridge.UpdateExclusiveMoves;
var
  Xhx, Yhx, X, Y: Integer;
  Level: TMapLevel;
begin
  FSideB.Clear;
  FSideA.Clear;
  if FDirection <> -1 then
  begin
    Level := TMapLevel(Owner.Owner);
    Xhx := TMapField(Owner).Xhx;
    Yhx := TMapField(Owner).Yhx;
    { Original bug: the neighbour lookups here have no bounds checks. }
    case FDirection of
      0:
        begin
          CenterHNtoHX(Xhx, Yhx, 2, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(2);
          CenterHNtoHX(Xhx, Yhx, 3, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(3);
          CenterHNtoHX(Xhx, Yhx, 5, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(5);
          CenterHNtoHX(Xhx, Yhx, 6, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(6);
        end;
      1:
        begin
          CenterHNtoHX(Xhx, Yhx, 3, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(3);
          CenterHNtoHX(Xhx, Yhx, 4, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(4);
          CenterHNtoHX(Xhx, Yhx, 6, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(6);
          CenterHNtoHX(Xhx, Yhx, 1, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(1);
        end;
      2:
        begin
          CenterHNtoHX(Xhx, Yhx, 1, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(1);
          CenterHNtoHX(Xhx, Yhx, 2, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideB.Add(2);
          CenterHNtoHX(Xhx, Yhx, 4, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(4);
          CenterHNtoHX(Xhx, Yhx, 5, X, Y);
          if not Land(Level.GetField(X, Y).TerrainType) then
            FSideA.Add(5);
        end;
    end;
  end;
end;

procedure THexagonBridge.UpdateTransitions;
begin
  if (FDirection = -1) or not DirectionValid(TMapField(Owner), FDirection) then
  begin
    if DirectionValid(TMapField(Owner), 1) then FDirection := 1
    else if DirectionValid(TMapField(Owner), 2) then FDirection := 2
    else if DirectionValid(TMapField(Owner), 0) then FDirection := 0
    else if msEditting in WorldMap^.Status then FDirection := -1;
    UpdateExclusiveMoves;
  end;
end;

procedure THexagonBridge.NeighbourTerrainChanged(HN: Integer; const Msg: THSTerrainInfo);
begin
  UpdateTransitions;
  if FDirection = -1 then Destroy;
end;

procedure THexagonBridge.ChangeTerrain(const Msg: THSTerrainInfo);
begin
  inherited ChangeTerrain(Msg);
end;

constructor THexagonBridgeResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  Level := 10;
end;

function THexagonBridgeResource.ResourceUserClassID: Integer;
begin
  Result := $2087A;
end;

class function THexagonBridgeResource.ResourceEditName: string;
begin
  Result := LoadResString(@BridgeStr);
end;

class function THexagonBridgeResource.ClassID: Integer;
begin
  Result := $2087B;
end;

procedure RegisterHexagonBridge(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([THexagonBridge, THexagonBridgeResource]);
end;

initialization
finalization

end.
