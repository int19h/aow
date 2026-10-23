unit Terrain;

{ The Terrain unit of HSEPack.dpl: the multi-hexagon terrain objects (TTerrainMO, ClassID $20166)
  whose resources (TTerrainMOR, ClassID $20167) carry a terrain type per hexagon. Changing the
  terrain under one swaps the object for the resource of the same kind that fits the new terrain;
  clearing it spreads single-terrain resources over its hexagons. }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine;

type
  TTerrainMOR = class;

  { Terrain.TTerrainMO (instance size 20) }
  TTerrainMO = class(TMultiHexMO)
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function CanChangeTerrain(const Info: THSSenderInfo): Boolean; override;
    procedure ChangeTerrain(const Info: THSTerrainInfo); override;
    procedure MapFieldMsgProc(var Msg: TMapFieldMsg); override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    procedure ClearTerrain(MapField: TMapField; HN: Integer); virtual;
    function FindTerrainResource(TerrainType: Byte): TTerrainMOR; virtual;
    function FindDecorationResource(DecorationType: Byte): TTerrainMOR; virtual;
    function FindCompatibleResource(ATerrainType: Byte; OverlayType: ShortInt;
      DecorationType: Integer): TTerrainMOR;
    function CanChangeOwnTerrain(HN: Integer): Boolean;
  end;

  { Terrain.TTerrainMOR (instance size 72): +$44 FDecorationType (-1 none), +$45 FTerrainType;
    persisted as ids $12 and $11 }
  TTerrainMOR = class(TMultiHexMOR)
  private
    FDecorationType: ShortInt;
    FTerrainType: Byte;
  public
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    property DecorationType: ShortInt read FDecorationType write FDecorationType;
    property TerrainType: Byte read FTerrainType write FTerrainType;
  end;

procedure RegisterTerrain(Engine: TEngine);

implementation

type
  { the resource list's children (TENode.FChildren is protected) }
  TENodeAccess = class(TENode);

{ TTerrainMO }

constructor TTerrainMO.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TTerrainMO.ClassID: Integer;
begin
  Result := $20166;
end;

function TTerrainMO.FindDecorationResource(DecorationType: Byte): TTerrainMOR;
var
  Candidates: TList;
  Resources: TEObjectList;
  I: Integer;
  R: TTerrainMOR;
begin
  Candidates := TList.Create;
  Resources := TENodeAccess(GetResourceList(FResource.Engine)).FChildren;
  for I := 0 to Resources.Count - 1 do
  begin
    R := TTerrainMOR(Resources.List^[I]);
    if (R.ClassID = FResource.ClassID) and
      (TTerrainMOR(Pointer(R)).FTerrainType = TTerrainMOR(FResource).FTerrainType) and
      (R.FDecorationType = DecorationType) and (R <> FResource) and
      R.TerrainList.CompareTerrain(FResource.TerrainList, [cmSameOverlayType]) then
      Candidates.Add(R);
  end;
  if Candidates.Count <> 0 then
    Result := TTerrainMOR(Candidates.List^[Random(Candidates.Count)])
  else
    Result := nil;
  Candidates.Free;
end;

function TTerrainMO.FindTerrainResource(TerrainType: Byte): TTerrainMOR;
var
  Candidates: TList;
  Resources: TEObjectList;
  I: Integer;
  R: TTerrainMOR;
begin
  Candidates := TList.Create;
  Resources := TENodeAccess(GetResourceList(FResource.Engine)).FChildren;
  for I := 0 to Resources.Count - 1 do
  begin
    R := TTerrainMOR(Resources.List^[I]);
    if (R.ClassID = FResource.ClassID) and
      (TTerrainMOR(Pointer(R)).FDecorationType = TTerrainMOR(FResource).FDecorationType) and
      (R.FTerrainType = TerrainType) and (R <> FResource) and
      R.TerrainList.CompareTerrain(FResource.TerrainList, [cmSameOverlayType]) then
      Candidates.Add(R);
  end;
  if Candidates.Count <> 0 then
    Result := TTerrainMOR(Candidates.List^[Random(Candidates.Count)])
  else
    Result := nil;
  Candidates.Free;
end;

function TTerrainMO.FindCompatibleResource(ATerrainType: Byte; OverlayType: ShortInt;
  DecorationType: Integer): TTerrainMOR;
var
  Candidates: TList;
  I: Integer;
  Resources: TEObjectList;
  R: TTerrainMOR;
  J: Integer;
  Compatible: Boolean;
  HexOverlay: ShortInt;
begin
  Candidates := TList.Create;
  Resources := TENodeAccess(GetResourceList(FResource.Engine)).FChildren;
  for I := 0 to Resources.Count - 1 do
  begin
    R := TTerrainMOR(Resources.List^[I]);
    if (R.ClassID = FResource.ClassID) and
      ((DecorationType = -1) or (R.FDecorationType = DecorationType)) then
      with TTerrainMOR(R) do
        if (FTerrainType = ATerrainType) and (R <> FResource) and
          R.TerrainList.CompareTerrain(Self.FResource.TerrainList, []) then
        begin
          Compatible := True;
          J := FTerrainList.Count;
          while Compatible and (J <> 0) do
          begin
            Dec(J);
            with R.TerrainList do HexOverlay := GetOverlay(J);
            Compatible := (HexOverlay < 0) or (HexOverlay = OverlayType);
          end;
          if Compatible then Candidates.Add(R);
        end;
  end;
  if Candidates.Count <> 0 then
    Result := TTerrainMOR(Candidates.List^[Random(Candidates.Count)])
  else
    Result := nil;
  Candidates.Free;
end;

function TTerrainMO.CanChangeOwnTerrain(HN: Integer): Boolean;
var
  Level: TMapLevel;
  Count: Integer;
  Walk: THNWalkData;
begin
  Result := True;
  Level := TMapLevel(Owner.Owner);
  Count := GetTerrainCount;
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < Count) and Result do
  begin
    if (Walk.HN <> HN) and (GetTerrain(Walk.HN) >= 0) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      Result := Level.GetField(Walk.X, Walk.Y).CanChangeTerrainEx(Self);
    WalkToNextHN(Walk);
  end;
end;

function TTerrainMO.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin
  if Self <> Info.Sender then
    if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
      if GetMostFrequentMapFieldTerrainType(TMapLevel(Owner.Owner), FXhx,
        FYhx, FResource.TerrainList.GetTerrain(Info.HN)) =
        Info.MapField.TerrainType then
        Result := CanChangeOwnTerrain(Info.HN)
      else
        Result := False
    else
      Result := True
  else
    Result := True;
end;

procedure TTerrainMO.ChangeTerrain(const Info: THSTerrainInfo);
var
  TerrainType, NewTerrainType: ShortInt;
  R: TTerrainMOR;
  OldOwner: TECustomNode;
begin
  TerrainType := FResource.TerrainList.GetTerrain(Info.HN);
  if (TerrainType >= 0) and (TerrainType <> Info.TerrainType) then
  begin
    NewTerrainType := GetMostFrequentMapFieldTerrainType(TMapLevel(Owner.Owner), FXhx,
      FYhx, FResource.TerrainList.GetTerrain(Info.HN));
    if NewTerrainType <> TerrainType then
    begin
      R := FindTerrainResource(NewTerrainType);
      if R <> nil then
      begin
        OldOwner := Owner;
        RemoveFromMap;
        SetResource(R);
        Owner := OldOwner;
        PlaceOnMap;
        if FResource.Level <= 15 then
          FResource.Engine.HSMap.StaticSceneInvalid := True;
        OverrideTerrain;
      end
      else
        Destroy;
    end;
  end;
end;

procedure TTerrainMO.ClearTerrain(MapField: TMapField; HN: Integer);
var
  Xhx, Yhx, Lhx: Integer;
  X, Y: Integer;
  TerrainList: TTerrainList;
  Map: THSMap;
  R: TTerrainMOR;
  Resources: TEObjectList;
  I: Integer;
  Found: Boolean;
begin
  if FResource.TerrainList.UsedTerrain > 1 then
  begin
    R := nil;
    Resources := TENodeAccess(GetResourceList(FResource.Engine)).FChildren;
    I := Resources.Count;
    Found := False;
    while not Found and (I <> 0) do
    begin
      Dec(I);
      R := TTerrainMOR(Resources.List^[I]);
      Found := (R.ClassID = FResource.ClassID) and
        (TTerrainMOR(Pointer(R)).FDecorationType = TTerrainMOR(FResource).FDecorationType) and
        (TTerrainMOR(Pointer(R)).FTerrainType = TTerrainMOR(FResource).FTerrainType) and
        (R.TerrainList.UsedTerrain = 1) and (R.TerrainList.GetTerrain(0) >= 0) and
        (GetOverlay(0) = R.TerrainList.GetOverlay(0));
    end;
    if Found then
    begin
      Xhx := GetXhx;
      Yhx := GetYhx;
      Lhx := GetLhx;
      Map := TMapLevel(Owner.Owner).Map;
      TerrainList := FResource.TerrainList;
      Destroy;
      for I := 0 to TerrainList.Count - 1 do
        if (TerrainList.GetTerrain(I) >= 0) and (I <> HN) then
        begin
          CenterHNtoHX(Xhx, Yhx, I, X, Y);
          R.PlaceResourceUser(Map, X, Y, Lhx);
        end;
    end
    else
      Destroy;
  end
  else
    Destroy;
end;

procedure TTerrainMO.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  if Msg.MsgID = $10 then
  begin
    if FResource.TerrainList.GetTerrain(Msg.HN) >= 0 then
      ClearTerrain(Msg.MapField, Msg.HN)
    else if Msg.HN = 0 then
      Destroy;
  end
  else
    inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $11 then
    if FResource.TerrainList.GetTerrain(Msg.HN) >= 0 then
      Msg.Result := TTerrainMOR(FResource).FDecorationType;
end;

function TTerrainMO.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
  if Result and not GetEditMode then OverrideTerrain;
end;

{ TTerrainMOR }

constructor TTerrainMOR.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FDecorationType := -1;
end;

destructor TTerrainMOR.Destroy;
begin
  inherited Destroy;
end;

procedure TTerrainMOR.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FTerrainType, $11);
  Stream.rwByte(Byte(FDecorationType), $12);
end;

class function TTerrainMOR.ResourceEditName: string;
begin
  Result := TerrainStr;
end;

function TTerrainMOR.ResourceUserClassID: Integer;
begin
  Result := $20166;
end;

class function TTerrainMOR.ClassID: Integer;
begin
  Result := $20167;
end;

procedure RegisterTerrain(Engine: TEngine);
begin
  Engine.RegisterEClasses([TTerrainMO, TTerrainMOR]);
end;

end.
