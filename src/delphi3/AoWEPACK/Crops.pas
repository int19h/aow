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
    procedure NewTurn(A1: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure GetIncome(A1: Integer; A2: Integer); override;
    procedure CanPlaceCrop(A1: Integer); virtual;  { +224 draft }
    procedure CropsEnabled; virtual;  { +228 draft }
    procedure RegrowCrops; virtual;  { +22C draft }
    procedure UpdateIncome(A1: Integer; A2: Integer); virtual;  { +230 draft }
    procedure UpdateCrops; virtual;  { +234 draft }
    procedure GetRace; virtual;  { +238 draft }
    procedure CropsChanged; virtual;  { +23C draft }
    procedure CropTrampled(A1: Integer); virtual;  { +240 draft }
    procedure SetIncome(A1: Byte);  { draft }
    procedure UpdateCropSettings;  { draft }
    function GetCropCount: Integer;
    procedure SetCropCount(A1: Integer);  { draft }
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
  TCropPlayers = class(TPlayerList)
    function PlayerAt(Player: Integer): TPlayer;
  end;
  PCropMap = ^TAoWHSMap;
  TCropILFields = packed record
    Reserved: array[0..19] of Byte;
    ImageIndex: Integer;
    TerrainType: Shortint;
  end;
const
  WorldMap: PCropMap = @AoWE.AoWHSMap;

{ needs: GetArmyHS returns TArmyHS; its EAX is tested at $557A5D0A. }
function CropArmy(Field: TAoWMapField): TArmyHS; assembler;
asm JMP TAoWMapField.GetArmyHS end;
{ needs: GetDiplomaticRelation returns Byte, tested against 1 at $557A5D41. }
function CropRelation(List: TPlayerList; A, B: Shortint): Byte; assembler;
asm JMP TPlayerList.GetDiplomaticRelation end;
{ GetRace's virtual slot returns a signed race id in AL. }
procedure CropTrample(Structure: TPlayerCropStructure; Player: Shortint); assembler;
asm MOV ECX,[EAX]; JMP DWORD PTR [ECX+$240] end;
function CropRace(Structure: TPlayerCropStructure): Shortint; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$238] end;
function TranslateCropName(const Name: string): string; assembler;
asm JMP AoWE.TranslateRStr end;



type
  TCropPlayerFields = packed record
    Reserved: array[0..164] of Byte;
    Race: Shortint;
  end;
{ needs: the following draft methods return objects or values in EAX/AL. }
function TCropPlayers.PlayerAt(Player: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;
function CropGetRace(List: TRaceList; Race: Shortint): TRace; assembler;
asm JMP TRaceList.GetRace end;
function CropRelationValue(Race: TRace; Player: Shortint): Integer; assembler;
asm JMP TRace.GetPlayerRelationValue end;
function CropRazed(Structure: TStructure): Boolean; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$150] end;
function CropBuilding(Structure: TStructure): Boolean; assembler;
asm JMP TStructure.GetBuilding end;
function CropEnabled(Structure: TPlayerCropStructure): Boolean; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$228] end;
function CropAllowed(Structure: TPlayerCropStructure; Field: TMapField): Boolean; assembler;
asm MOV ECX,[EAX]; JMP DWORD PTR [ECX+$224] end;
procedure CropUpdateIncome(Structure: TPlayerCropStructure); assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$230] end;
procedure CropSetPlayer(Structure: TPlayerStructure; Player: Byte); assembler;
asm JMP TPlayerStructure.SetPlayer end;
procedure CropPlayerIncome(Player: TPlayer); assembler;
asm JMP TPlayer.UpdateIncome end;
function CropRandom(Map: TAoWHSMap; Range: Integer): Integer; assembler;
asm JMP TAoWHSMap.Random end;

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
var Army: TArmyHS;
begin
  Army := CropArmy(TAoWMapField(Owner));
  if (Army <> nil) and (Player = Shortint(TArmy(Army.F_ArmyHS_1C).F_Army_12)) and
    (Shortint(FCropOwner.F_PlayerStructure_30) > 0) and
    (Player <> Shortint(FCropOwner.F_PlayerStructure_30)) then
    if CropRelation(TPlayerList(WorldMap^.FPlayers),
      Shortint(FCropOwner.F_PlayerStructure_30), Player) = 1 then
    begin
      CropTrample(FCropOwner, Player);
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
  if (FCropOwner <> nil) and (CropRace(FCropOwner) = 11) then Inc(Result, 30);
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
begin Result := TranslateCropName(CropRStr); end;

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
  FIncomeSource.Setup(Integer(Self));
end;

destructor TPlayerCropStructure.Destroy;
begin
  inherited Destroy;
  FIncomeSource.Free;
end;

class function TPlayerCropStructure.ClassID: Integer;
begin Result := $2034E; end;

procedure TPlayerCropStructure.GetIncome(A1: Integer; A2: Integer);
asm MOVZX EAX,BYTE PTR [EAX+$3C] end;

procedure TPlayerCropStructure.CropTrampled(A1: Integer);
var Race: Shortint;
begin
  if (Byte(A1) <> F_PlayerStructure_30) and (Shortint(F_PlayerStructure_30) > 0) and
    (Shortint(A1) > 0) then
  begin
    Race := TCropPlayerFields(Pointer(TCropPlayers(WorldMap^.FPlayers).PlayerAt(Shortint(F_PlayerStructure_30)))^).Race;
    CropGetRace(TRaceList(WorldMap^.FRaces), Race).SetPlayerRelationValue(
      Byte(A1), CropRelationValue(CropGetRace(TRaceList(WorldMap^.FRaces), Race),
      Shortint(A1)) + 5);
  end;
end;

procedure TPlayerCropStructure.SetIncome(A1: Byte);
var Player: Shortint;
begin
  if (A1 <> FIncome) and (moActivated in FStatus) then
  begin
    FIncome := A1;
    Player := Shortint(F_PlayerStructure_30);
    if Player <> -1 then
      CropPlayerIncome(TCropPlayers(WorldMap^.FPlayers).PlayerAt(Player));
  end;
end;

procedure TPlayerCropStructure.RegrowCrops;
begin
  if GetCropCount < TPlayerCropStructureResource(FResource).FCropLocations.Count then
    SetCropCount(GetCropCount + 1);
end;

procedure TPlayerCropStructure.CropsEnabled;
begin
  if not CropRazed(Self) and not CropBuilding(Self) then
    asm MOV AL,1 end
  else
    asm XOR EAX,EAX end;
end;

procedure TPlayerCropStructure.NewTurn(A1: Integer);
var Player: Byte;
begin
  Player := Byte(A1);
  inherited NewTurn(A1);
  if F_PlayerStructure_30 = Player then
    if CropEnabled(Self) then RegrowCrops;
end;

procedure TPlayerCropStructure.UpdateIncome(A1: Integer; A2: Integer);
begin
  if not CropRazed(Self) and not CropBuilding(Self) then
    SetIncome(GetCropCount * 2)
  else SetIncome(0);
end;

procedure TPlayerCropStructure.CropsChanged;
asm MOV EDX,[EAX]; CALL DWORD PTR [EDX+$230] end;

procedure TPlayerCropStructure.SetPlayer(A1: Integer; A2: Integer);
begin
  if Byte(A1) <> F_PlayerStructure_30 then
  begin
    if F_PlayerStructure_30 <> $FF then
      TCropPlayers(WorldMap^.FPlayers).PlayerAt(Shortint(F_PlayerStructure_30)).
        UnregisterIncomeSource(Integer(FIncomeSource));
    CropSetPlayer(Self, Byte(A1));
    UpdateCrops;
    if F_PlayerStructure_30 <> $FF then
      TCropPlayers(WorldMap^.FPlayers).PlayerAt(Shortint(F_PlayerStructure_30)).
        RegisterIncomeSource(Integer(FIncomeSource));
  end;
end;

procedure TPlayerCropStructure.Activate;
var Player: Shortint;
begin
  inherited Activate;
  Player := Shortint(F_PlayerStructure_30);
  if Player <> -1 then
    TCropPlayers(WorldMap^.FPlayers).PlayerAt(Player).
      RegisterIncomeSource(Integer(FIncomeSource));
  if not GetEditMode then
  begin
    LinkToCrops;
    UpdateCrops;
  end;
end;

procedure TPlayerCropStructure.Deactivate;
var Player: Shortint;
begin
  Player := Shortint(F_PlayerStructure_30);
  if Player <> -1 then
    TCropPlayers(WorldMap^.FPlayers).PlayerAt(Player).
      UnregisterIncomeSource(Integer(FIncomeSource));
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
      if CropEnabled(Self) then
        SetCropCount(TPlayerCropStructureResource(FResource).FCropLocations.Count);
    UpdateCropSettings;
    CropUpdateIncome(Self);
  end;
end;

procedure TPlayerCropStructure.GetRace;
var Race: Shortint;
begin
  if Shortint(F_PlayerStructure_30) > 0 then
    Race := TCropPlayerFields(Pointer(TCropPlayers(WorldMap^.FPlayers).PlayerAt(Shortint(F_PlayerStructure_30)))^).Race
  else Race := -1;
  asm MOV AL,Race end;
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

procedure TPlayerCropStructure.CanPlaceCrop(A1: Integer);
var
  Field: TMapField;
  Army: TArmyHS;
  HS: THexagonSprite;
  Allowed: Boolean;
begin
  Field := TMapField(A1);
  if CropRazed(Self) then Allowed := False
  else
  begin
    Army := TArmyHS(Field.FindOwnedChild($20217));
    Allowed := ((Army = nil) or
      (CropRelation(TPlayerList(WorldMap^.FPlayers),
        Shortint(TArmy(Army.F_ArmyHS_1C).F_Army_12), Shortint(F_PlayerStructure_30)) <> 1));
    if Allowed then
    begin
      HS := Field.GetMaxLevelNoneTransparentHS;
      Allowed := (HS = nil) or (HS.GetLevel < 26);
    end;
    if Allowed then
      Allowed := (Field.TerrainType in [1..4, 12]) or
        ((Field.TerrainType = 5) and (CropRace(Self) = 11));
  end;
  asm MOV AL,Allowed end;
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
        if (Crop <> nil) or not CropAllowed(Self, Field) then
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
          I := CropRandom(WorldMap^, Locations.Count);
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
        I := CropRandom(WorldMap^, Crops.Count);
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
