unit ReflectingPool;

{ Reflecting pools of AoWEPACK.dpl: shared vision and cycling pool centering. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TReflectingPool = class;
  TReflectingPoolResource = class;


  { TReflectingPool: size $40; $3C FCenterFrame (-1 when inactive). }
  TReflectingPool = class(TPlayerStructure)
  public
    FCenterFrame: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure SetPlayer(Player: Shortint); override;
    function VisibilityRange: Integer; override;
    procedure UpdateUnfog; override;
    procedure UpdateExploration; override;
    function GetDefaultAITargetPriority: Integer; override;
    procedure ListReflectingPools(var List: TPlayerStructureList);
    procedure NewFrame(Sender: TObject);
    procedure ActivatePoolCentering;
    procedure DeactivatePoolCentering;
    procedure UpdateReflectingPoolsExploration;
    function PoolVisionPlayer(Player: Shortint): Boolean;
    procedure NotifyPlayerChanged(MapField: TMapField; Distance: Integer);
  end;

  { TReflectingPoolResource (instance size 116, VMT 557D4B6C) }
  TReflectingPoolResource = class(TPlayerStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterReflectingPool(AEngine: TEngine);

implementation

constructor TReflectingPool.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCenterFrame := -1;
end;

class function TReflectingPool.ClassID: Integer;
begin Result := $2063E; end;

procedure TReflectingPool.ListReflectingPools(var List: TPlayerStructureList);
var P, I: Integer;
begin
  for P := AoWHSMap.FPlayers.Count - 1 downto 0 do
    for I := AoWHSMap.FPlayers.GetPlayers(P).FKnownStructures.Count - 1 downto 0 do
      List.AddChild(AoWHSMap.FPlayers.GetPlayers(P).FKnownStructures.GetStructure(I));
end;

function TReflectingPool.VisibilityRange: Integer;
begin
  Result := 8;
  if (GetLhx <> 0) or ((FPlayer > 0) and
    (Byte(AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments) and 8 <> 0)) then
    Result := (Result + 1) shr 1;
end;

function TReflectingPool.GetDefaultAITargetPriority: Integer;
begin Result := 1; end;

procedure TReflectingPool.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); end;

procedure TReflectingPool.Activate;
begin
  inherited Activate;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FKnownStructures.AddChild(Self);
end;

procedure TReflectingPool.Deactivate;
begin
  inherited Deactivate;
  DeactivatePoolCentering;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FKnownStructures.RemoveChild(Self);
end;

function ComparePools(Item1, Item2: Pointer): Integer;
begin Result := Integer(Item1) - Integer(Item2); end;

procedure TReflectingPool.NewFrame(Sender: TObject); { Near miss: register or temporary allocation differs after three variants. }
var List: TPlayerStructureList; Pool: TPlayerStructure;
begin
  if AoWHSMap.FSeatedPlayer = FPlayer then
  begin
    Inc(FCenterFrame);
    if FCenterFrame mod 8 = 0 then
    begin
      List := TPlayerStructureList.Create(nil);
      ListReflectingPools(List);
      List.RemoveChild(Self);
      List.Sort(ComparePools);
      if FCenterFrame div 8 < List.Count then
      begin
        Pool := List.GetStructure(FCenterFrame div 8);
        AoWHSMap.CenterViewTo(Pool.GetXhx, Pool.GetYhx, Pool.GetLhx);
      end
      else
      begin
        AoWHSMap.CenterViewTo(GetXhx, GetYhx, GetLhx);
        DeactivatePoolCentering;
      end;
      List.Free;
    end;
  end
  else DeactivatePoolCentering;
end;

procedure TReflectingPool.ActivatePoolCentering;
begin
  DeactivatePoolCentering;
  FCenterFrame := 0;
  AoWHSMap.NewFrameEvents.Add(NewFrame);
end;

procedure TReflectingPool.DeactivatePoolCentering;
begin
  if FCenterFrame <> -1 then
  begin
    AoWHSMap.NewFrameEvents.Remove(NewFrame);
    FCenterFrame := -1;
  end;
end;

procedure TReflectingPool.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FKnownStructures.RemoveChild(Self);
    inherited SetPlayer(Player);
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FKnownStructures.AddChild(Self);
    UpdateReflectingPoolsExploration;
    if (FPlayer <> -1) and (FPlayer = AoWHSMap.FSeatedPlayer) and
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FKnownStructures.Count = 1) then
      ActivatePoolCentering;
  end;
end;

procedure TReflectingPool.UpdateExploration;
var P, I, X, Y: Integer;
begin
  if moPlacedOnMap in FStatus then
    for P := 1 to AoWHSMap.FPlayers.Count - 1 do
      if PoolVisionPlayer(P) then
        for I := 0 to FResource.TerrainList.Count - 1 do
          if FResource.TerrainList.GetTerrain(I) >= 0 then
          begin
            CenterHNtoHX(FXhx, FYhx, I, X, Y);
            AoWHSMap.ExploreArea(X, Y, TMapField(Owner).Lhx, P, VisibilityRange);
          end;
end;

procedure TReflectingPool.UpdateReflectingPoolsExploration;
var P, I: Integer; Player: TPlayer;
begin
  for P := AoWHSMap.FPlayers.Count - 1 downto 0 do
  begin
    Player := AoWHSMap.FPlayers.GetPlayers(P);
    for I := Player.FKnownStructures.Count - 1 downto 0 do
    begin
      Player.FKnownStructures.GetStructure(I).UpdateExploration;
      Player.FKnownStructures.GetStructure(I).UpdateUnfog;
    end;
  end;
end;

procedure TReflectingPool.UpdateUnfog;
var Range, I, X, Y: Integer;
begin
  if moPlacedOnMap in FStatus then
  begin
    if (moActivated in FStatus) and (AoWHSMap.FSeatedPlayer <> -1) then
    begin
      if PoolVisionPlayer(AoWHSMap.FSeatedPlayer) then Range := VisibilityRange
      else Range := 0;
    end
    else Range := 0;
    if Range <> FUnfogRange then
    begin
      if FUnfogRange <> 0 then
        for I := 0 to FResource.TerrainList.Count - 1 do
          if FResource.TerrainList.GetTerrain(I) >= 0 then
          begin
            CenterHNtoHX(FXhx, FYhx, I, X, Y);
            AoWHSMap.FogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
          end;
      FUnfogRange := Range;
      if FUnfogRange <> 0 then
        for I := 0 to FResource.TerrainList.Count - 1 do
          if FResource.TerrainList.GetTerrain(I) >= 0 then
          begin
            CenterHNtoHX(FXhx, FYhx, I, X, Y);
            AoWHSMap.UnFogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
          end;
    end;
  end;
end;

function TReflectingPool.PoolVisionPlayer(Player: Shortint): Boolean;
var P: Integer;
begin
  Result := AoWHSMap.FPlayers.GetPlayers(Player).FKnownStructures.Count <> 0;
  if not Result then
  begin
    P := AoWHSMap.FPlayers.Count;
    while (P > 1) and not Result do
    begin
      Dec(P);
      Result := (AoWHSMap.FPlayers.GetPlayers(P).FKnownStructures.Count <> 0) and
        (AoWHSMap.FPlayers.GetPlayers(P).FDiplomaticRelations.GetDiplomaticRelation(Player) = drAlliance);
    end;
  end;
end;

procedure TReflectingPool.NotifyPlayerChanged(MapField: TMapField; Distance: Integer);
var P: Integer;
begin
  for P := 1 to AoWHSMap.FPlayers.Count - 1 do
    if PoolVisionPlayer(P) then
      AoWHSMap.UpdatePlayerSeen(P, MapField.Xhx, MapField.Yhx, MapField.Lhx, Distance, TrueVisionRange);
end;

procedure TReflectingPool.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID = $110A) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
  begin
    if (VisibilityRange >= Msg.Param[0]) and PoolVisionPlayer(Msg.Param[1]) then Msg.Result := 1;
  end
  else if (Msg.MsgID = $110D) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
  begin
    if VisibilityRange >= Msg.Param[0] then NotifyPlayerChanged(Msg.MapField, Msg.Param[0]);
  end
  else inherited MapFieldMsgProc(Msg);
end;

constructor TReflectingPoolResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := True;
  FConnectRoads := False;
  FClaimed := False;
  FRazeable := False;
end;

class function TReflectingPoolResource.ResourceEditName: string;
begin Result := TranslateRStr(ReflectingPoolRStr); end;

class function TReflectingPoolResource.ClassID: Integer;
begin Result := $2063F; end;

function TReflectingPoolResource.ResourceUserClassID: Integer;
begin Result := $2063E; end;

procedure RegisterReflectingPool(AEngine: TEngine);
begin AEngine.RegisterEClasses([TReflectingPool, TReflectingPoolResource]); end;

initialization
finalization
end.
