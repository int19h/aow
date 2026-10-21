unit Crops;

{ Crops of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TPlayerCropStructure = class;
  TPlayerCropStructureResource = class;
  TCrop = class;
  TCropResource = class;


  { TPlayerCropStructure (instance size 68, VMT 557A5634): +$3C FIncome,
    +$3D FChangingCrops, +$40 FIncomeSource. }
  TPlayerCropStructure = class(TPlayerStructure)
  public
    FIncome: Byte;
    FChangingCrops: Boolean;
    FReserved3E: array[0..1] of Byte;
    FIncomeSource: TPlayerStructureIncomeSource;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo); override;
    procedure Remove; override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    procedure NewTurn(Player: Shortint); override;
    procedure SetPlayer(Player: Shortint); override;
    function GetIncome: Integer; override;
    function CanPlaceCrop(Field: TMapField): Boolean; virtual;
    function CropsEnabled: Boolean; virtual;
    procedure RegrowCrops; virtual;  { +22C draft }
    procedure UpdateIncome; virtual;
    procedure UpdateCrops; virtual;  { +234 draft }
    function GetRace: Shortint; virtual;
    procedure CropsChanged; virtual;  { +23C draft }
    procedure CropTrampled(Player: Shortint); virtual;
    procedure SetIncome(A1: Byte);  { draft }
    procedure UpdateCropSettings;
    function GetCropCount: Integer;
    procedure SetCropCount(A1: Integer);
    procedure LinkToCrops;  { draft }
  end;

  { TPlayerCropStructureResource (instance size 120, VMT 557A58FC): +$74 FCropLocations. }
  TPlayerCropStructureResource = class(TPlayerStructureResource)
  public
    FCropLocations: TWordList;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function ResourceUserClassID: Integer; override;
  end;

  { TCrop (instance size 32, VMT 557A5A10): +$1C FCropOwner. }
  TCrop = class(TILTerrainMO)
  public
    FCropOwner: TPlayerCropStructure;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure SetCropOwner(Value: TPlayerCropStructure);
    procedure UpdateSettings;  { draft }
    procedure EndTurn(Player: Shortint);
    procedure LinkToCropOwner;  { draft }
  end;

  { TCropResource (instance size 68, VMT 557A5BB0) }
  TCropResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure SetLevel(Value: Byte); override;
    function PlaceCrop(X, Y, L: Shortint; CropOwner: TPlayerCropStructure): TCrop;
  end;

procedure RegisterCrops(AEngine: TEngine);

implementation

type
  PCropMap = ^TAoWHSMap;
  TCropILFields = packed record
    Reserved: array[0..19] of Byte;
    ImageIndex: Integer;
    TerrainType: Shortint;
  end;
const
  WorldMap: PCropMap = @AoWE.AoWHSMap;

constructor TCrop.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

destructor TCrop.Destroy;
begin
  inherited Destroy;
end;

class function TCrop.ClassID: Integer;
begin Result := $2036A; end;

procedure TCrop.SetCropOwner(Value: TPlayerCropStructure);
begin
  FCropOwner := Value;
  UpdateSettings;
end;

procedure TCrop.UpdateSettings;
var Index: Integer;
begin
  Index := GetTerrainTypeImage(TerrainType);
  TCropILFields(Pointer(Self)^).ImageIndex := Index;
  if not FResource.ImageLibrary.ImageExist(Index) then Destroy;
end;

procedure TCrop.EndTurn(Player: Shortint);
var PlayerIndex: Shortint; Army: TArmyHS;
begin
  Army := TAoWMapField(Owner).GetArmyHS;
  PlayerIndex := Player;
  if (Army <> nil) and (Army.FArmy.FPlayer = PlayerIndex) and
    (FCropOwner.FPlayer > 0) and
    (PlayerIndex <> FCropOwner.FPlayer) then
    if TPlayerList(WorldMap^.FPlayers).GetDiplomaticRelation(FCropOwner.FPlayer, PlayerIndex) = drWar then
    begin
      FCropOwner.CropTrampled(PlayerIndex);
      Destroy;
    end;
end;

procedure TCrop.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020007 then EndTurn(Shortint(Msg.Value));
end;

procedure TCrop.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if Msg.MsgID <> $10 then inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1105 then Destroy;
end;

procedure TCrop.LinkToCropOwner;
var
  Found: TPlayerCropStructure;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
begin
  Found := nil;
  MapLevel := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 1);
  while (Walk.Radius <= 1) and (Found = nil) do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
      Found := TPlayerCropStructure(MapLevel.GetField(Walk.X, Walk.Y).
        FindNoneTransparentHS(TPlayerCropStructure));
    WalkToNextHN(Walk);
  end;
  SetCropOwner(Found);
end;

procedure TCrop.Activate;
begin
  LinkToCropOwner;
  inherited Activate;
end;

procedure TCrop.Deactivate;
begin
  if (FCropOwner <> nil) and not (msDestroying in WorldMap^.Status) then
    with FCropOwner do
    begin
      Self.FCropOwner := nil;
      CropsChanged;
    end;
  inherited Deactivate;
end;

function TCrop.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TCrop.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
var
  Overlay: Smallint;
  HS: THexagonSprite;
begin
  if Info.HN <> 0 then Exit;
  if moActivated in FStatus then
  begin
    if not ValidTerrainType(Info.TerrainType) then Destroy
    else
    begin
    TCropILFields(Pointer(Self)^).TerrainType := Info.TerrainType;
    TCropILFields(Pointer(Self)^).ImageIndex := GetTerrainTypeImage(Info.TerrainType);
    HS := Info.MapField.GetMaxLevelNoneTransparentHS;
    if (HS <> nil) and (HS.GetLevel > GetLevel) and not (HS is TAbstractRoad) then Destroy
    else
    begin
      Overlay := Info.OverlayType;
      if (Overlay >= 0) and (Overlay <> 4) then Destroy;
    end;
    end;
  end
  else TCropILFields(Pointer(Self)^).TerrainType := Info.TerrainType;
end;

function TCrop.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  Result := TerrainType;
  if (FCropOwner <> nil) and (FCropOwner.GetRace = 11) then Inc(Result, 30);
end;

function TCrop.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  Field: TMapField;
  HS: THexagonSprite;
begin
  Field := MapContainer.GetField(Xhx, Yhx, Lhx);
  HS := Field.GetMaxLevelNoneTransparentHS;
  Result := (Field.FindOwnedHS(TFire) = nil) and
    ((HS = nil) or (HS.GetLevel < 10) or (HS is TAbstractRoad));
end;

class function TCropResource.ClassID: Integer;
begin Result := $2036B; end;

procedure TCropResource.SetLevel(Value: Byte);
begin inherited SetLevel(5); end;

function TCropResource.ResourceUserClassID: Integer;
begin Result := $2036A; end;

class function TCropResource.ResourceEditName: string;
begin Result := TranslateRStr(CropRStr); end;

function TCropResource.PlaceCrop(X, Y, L: Shortint; CropOwner: TPlayerCropStructure): TCrop;
begin
  Result := TCrop.Create(nil);
  Result.SetResource(Self);
  Result.ResourceLinked := True;
  Result.FCropOwner := CropOwner;
  if not WorldMap^.PlaceHX(Result, X, Y, L) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

constructor TPlayerCropStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FChangingCrops := False;
  FIncomeSource := TPlayerStructureIncomeSource.Create(nil);
  FIncomeSource.Setup(Self);
end;

destructor TPlayerCropStructure.Destroy;
begin
  inherited Destroy;
  FIncomeSource.Free;
end;

class function TPlayerCropStructure.ClassID: Integer;
begin Result := $2034E; end;

function TPlayerCropStructure.GetIncome: Integer;
asm MOVZX EAX,BYTE PTR [EAX+$3C] end;

procedure TPlayerCropStructure.CropTrampled(Player: Shortint);
var Race: Integer;
begin
  if (Player <> FPlayer) and (FPlayer > 0) and
    (Player > 0) then
  begin
    Race := TPlayerList(WorldMap^.FPlayers).GetPlayers(FPlayer).FPlayerRace;
    TRaceList(WorldMap^.FRaces).GetRace(Race).SetPlayerRelationValue(
      Player, TRaceList(WorldMap^.FRaces).GetRace(Race).GetPlayerRelationValue(Player) - (-5));
  end;
end;

procedure TPlayerCropStructure.SetIncome(A1: Byte);
var Player: Shortint;
begin
  with TPlayerCropStructure(Self) do if (A1 <> FIncome) and (moActivated in FStatus) then
  begin
    FIncome := A1;
    Player := FPlayer;
    if Player <> -1 then
      TPlayerList(WorldMap^.FPlayers).GetPlayers(Player).UpdateIncome;
  end;
end;

procedure TPlayerCropStructure.RegrowCrops;
begin
  if GetCropCount < TPlayerCropStructureResource(FResource).FCropLocations.Count then
    SetCropCount(GetCropCount + 1);
end;

function TPlayerCropStructure.CropsEnabled: Boolean;
begin
  Result := not GetRazed and not GetBuilding;
end;

procedure TPlayerCropStructure.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  if FPlayer = Player then
    if CropsEnabled then RegrowCrops;
end;

procedure TPlayerCropStructure.UpdateIncome;
begin
  if not GetRazed and not GetBuilding then
    SetIncome(GetCropCount * 2)
  else SetIncome(0);
end;

procedure TPlayerCropStructure.CropsChanged;
begin UpdateIncome; end;

procedure TPlayerCropStructure.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    if FPlayer <> -1 then
      TPlayerList(WorldMap^.FPlayers).GetPlayers(FPlayer).
        UnregisterIncomeSource(FIncomeSource);
    inherited SetPlayer(Player);
    UpdateCrops;
    if FPlayer <> -1 then
      TPlayerList(WorldMap^.FPlayers).GetPlayers(FPlayer).
        RegisterIncomeSource(FIncomeSource);
  end;
end;

procedure TPlayerCropStructure.Activate;
var Player: Shortint;
begin
  inherited Activate;
  Player := FPlayer;
  if Player <> -1 then
    TPlayerList(WorldMap^.FPlayers).GetPlayers(Player).
      RegisterIncomeSource(FIncomeSource);
  if not GetEditMode then
  begin
    LinkToCrops;
    UpdateCrops;
  end;
end;

procedure TPlayerCropStructure.Deactivate;
var Player: Shortint;
begin
  Player := FPlayer;
  if Player <> -1 then
    TPlayerList(WorldMap^.FPlayers).GetPlayers(Player).
      UnregisterIncomeSource(FIncomeSource);
  inherited Deactivate;
end;

procedure TPlayerCropStructure.UpdateCropSettings;
var
  MapLevel: TMapLevel;
  I, X, Y: Integer;
  Crop: TCrop;
begin
  MapLevel := TMapLevel(Owner.Owner);
  for I := TPlayerCropStructureResource(FResource).FCropLocations.Count - 1 downto 0 do
  begin
    CenterHNtoHX(FXhx, FYhx, TPlayerCropStructureResource(FResource).
      FCropLocations.List^[I], X, Y);
    if (X >= 0) and (MapLevel.Width > X) and (Y >= 0) and (MapLevel.Height > Y) then
    begin
      Crop := TCrop(MapLevel.GetField(X, Y).FindOwnedChild($2036A));
      if Crop <> nil then Crop.UpdateSettings;
    end;
  end;
end;

procedure TPlayerCropStructure.UpdateCrops;
begin
  if not GetEditMode and (moActivated in FStatus) then
  begin
    if msEditting in WorldMap^.Status then
      if CropsEnabled then
        SetCropCount(TPlayerCropStructureResource(FResource).FCropLocations.Count);
    UpdateCropSettings;
    UpdateIncome;
  end;
end;

function TPlayerCropStructure.GetRace: Shortint;
begin
  if FPlayer > 0 then
    Result := TPlayerList(WorldMap^.FPlayers).GetPlayers(FPlayer).FPlayerRace
  else Result := -1;
end;

function TPlayerCropStructure.GetCropCount: Integer;
var
  MapLevel: TMapLevel;
  I, X, Y: Integer;
  Crop: TCrop;
begin
  Result := 0;
  MapLevel := TMapLevel(Owner.Owner);
  for I := TPlayerCropStructureResource(FResource).FCropLocations.Count - 1 downto 0 do
  begin
    CenterHNtoHX(FXhx, FYhx, TPlayerCropStructureResource(FResource).
      FCropLocations.List^[I], X, Y);
    if (X >= 0) and (MapLevel.Width > X) and (Y >= 0) and (MapLevel.Height > Y) then
    begin
      Crop := TCrop(MapLevel.GetField(X, Y).FindChild($2036A));
      if Crop <> nil then if Crop.FCropOwner = Self then Inc(Result);
    end;
  end;
end;

function TPlayerCropStructure.CanPlaceCrop(Field: TMapField): Boolean;
var
  Army: TArmyHS;
  HS: THexagonSprite;
begin
  if not GetRazed then
  begin
    Army := TArmyHS(Field.FindOwnedChild($20217));
    Result := ((Army = nil) or
      (TPlayerList(WorldMap^.FPlayers).GetDiplomaticRelation(
        TArmy(Army.FArmy).FPlayer, FPlayer) <> drWar));
    if Result then
    begin
      HS := Field.GetMaxLevelNoneTransparentHS;
      Result := (HS = nil) or (HS.GetLevel < 26);
    end;
    if Result then
      Result := (Field.TerrainType in [1..4, 12]) or
        ((Field.TerrainType = 5) and (GetRace = 11));
  end
  else Result := False;
end;

procedure TPlayerCropStructure.SetCropCount(A1: Integer);
var
  MapLevel: TMapLevel;
  I, X, Y: Integer;
  Crop: TCrop;
  Locations: TWordList;
  Crops: TList;
  Field: TMapField;
  Resource: TCropResource;
begin
  if (moPlacedOnMap in FStatus) and not FChangingCrops then
  begin
    FChangingCrops := True;
    MapLevel := TMapLevel(Owner.Owner);
    Crops := TList.Create;
    Locations := TWordList.Create;
    Locations.Assign(TPlayerCropStructureResource(FResource).FCropLocations);
    for I := Locations.Count - 1 downto 0 do
    begin
      CenterHNtoHX(FXhx, FYhx, Locations.List^[I], X, Y);
      if (X < 0) or (X >= MapLevel.Width) or (Y < 0) or (Y >= MapLevel.Height) then
        Locations.Delete(I)
      else
      begin
        Field := MapLevel.GetField(X, Y);
        Crop := TCrop(Field.FindOwnedChild($2036A));
        if (Crop <> nil) or not CanPlaceCrop(Field) then
        begin
          if (Crop <> nil) and (Crop.FCropOwner = Self) then Crops.Add(Crop);
          Locations.Delete(I);
        end;
      end;
    end;
    if Crops.Count < A1 then
    begin
      Resource := TCropResource(FResource.Engine.HSSet.MapObjectResourceList.FindChild($2036B));
      if Resource <> nil then
        while (Crops.Count <> A1) and (Locations.Count <> 0) do
        begin
          I := WorldMap^.Random(Locations.Count);
          CenterHNtoHX(FXhx, FYhx, Locations.List^[I], X, Y);
          Crop := Resource.PlaceCrop(X, Y, MapLevel.Lhx, Self);
          if Crop <> nil then
          begin
            Crops.Add(Crop);
            Crop.SetCropOwner(Self);
          end;
          Locations.Delete(I);
        end;
    end
    else if Crops.Count > A1 then
      while (Crops.Count <> A1) and (Crops.Count <> 0) do
      begin
        I := WorldMap^.Random(Crops.Count);
        TCrop(Crops.Items[I]).Destroy;
        Crops.Delete(I);
      end;
    { Original frees and clears the recursion guard only on normal completion. }
    Crops.Free;
    Locations.Free;
    FChangingCrops := False;
    CropsChanged;
  end;
end;

procedure TPlayerCropStructure.NeighbourTerrainChanged(HN: Integer; const Info: HSEngine.THSTerrainInfo);
begin
  if ([msEditting, msActivated] <= WorldMap^.Status) and
    not FChangingCrops then UpdateCrops;
end;

procedure TPlayerCropStructure.Remove;
begin
  if not GetEditMode then SetCropCount(0);
  inherited Remove;
end;

procedure TPlayerCropStructure.LinkToCrops;
var
  MapLevel: TMapLevel;
  I, X, Y: Integer;
  Crop: TCrop;
begin
  if GetEditMode then Exit;
  MapLevel := TMapLevel(Owner.Owner);
  for I := TPlayerCropStructureResource(FResource).FCropLocations.Count - 1 downto 0 do
  begin
    CenterHNtoHX(FXhx, FYhx, TPlayerCropStructureResource(FResource).
      FCropLocations.List^[I], X, Y);
    if (X >= 0) and (MapLevel.Width > X) and (Y >= 0) and (MapLevel.Height > Y) then
    begin
      Crop := TCrop(MapLevel.GetField(X, Y).FindChild($2036A));
      if Crop <> nil then Crop.SetCropOwner(Self);
    end;
  end;
end;

function TPlayerCropStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  MapLevel: TMapLevel;
  I, HN, X, Y, NX, NY: Integer;
begin
  Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx);
  if Result and not GetEditMode then
  begin
    MapLevel := MapContainer.GetMapLevel(Lhx);
    I := TPlayerCropStructureResource(FResource).FCropLocations.Count;
    while Result and (I <> 0) do
    begin
      Dec(I);
      CenterHNtoHX(Xhx, Yhx, TPlayerCropStructureResource(FResource).FCropLocations.List^[I], X, Y);
      NX := X; NY := Y; HN := 0;
      while Result and (HN <> 7) do
      begin
        if (NX >= 0) and (NX < MapLevel.Width) and (NY >= 0) and (NY < MapLevel.Height) then
          Result := MapLevel.GetField(NX, NY).FindNoneTransparentHS(TPlayerCropStructure) = nil;
        Inc(HN);
        CenterHNtoHX(X, Y, HN, NX, NY);
      end;
    end;
  end;
end;

function TPlayerCropStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
  if Result then if not GetEditMode then UpdateCrops;
end;

destructor TPlayerCropStructureResource.Destroy;
begin
  FCropLocations.Free;
  FCropLocations := nil;
  inherited Destroy;
end;

class function TPlayerCropStructureResource.ClassID: Integer;
begin Result := $2034F; end;

function TPlayerCropStructureResource.ResourceUserClassID: Integer;
begin Result := $2034E; end;

procedure TPlayerCropStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    if FCropLocations <> nil then FCropLocations.Free;
    FCropLocations := TerrainList.CreateSurroundingHNTable;
  end;
end;

procedure RegisterCrops(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCrop, TCropResource]);
  AEngine.RegisterEClasses([TPlayerCropStructure, TPlayerCropStructureResource]);
end;


initialization
finalization

end.
