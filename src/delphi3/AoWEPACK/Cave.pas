unit Cave;

{ Cave of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EventLog;

type
  TCave = class;
  TCaveResource = class;
  TEnterCaveEventLog = class;

  TCaveEntrance = (ceUp, ceDown, ceIdle);  { ot=1 }

  { TCave (instance size 52, VMT 557B3018): +$30 FEntrance. }
  TCave = class(TStructure)
  public
    FEntrance: TCaveEntrance;
    F_Cave_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
    procedure GetTopBorderImage; override;
    procedure GetMiddleBorderImage; override;
    procedure GetBottomBorderImage; override;
    procedure ArmyPlaced(A1: Integer); override;
    function EnterMovePoints(Army: TArmy; Selection: Byte): Shortint;
    function CanEnterSelection(Units: TUnitList): Byte;
    function CanEnter(Player: Shortint): Boolean;
    function EnterEx: Boolean;
    function Enter(Player: Shortint): Boolean;
  end;

  { TCaveResource (instance size 100, VMT 557B326C) }
  TCaveResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TEnterCaveEventLog (instance size 44, VMT 557B335C): +$28 FCave. }
  TEnterCaveEventLog = class(TMessageEventLog)
  public
    FCave: TCave;
    procedure Yes; override;
    procedure No; override;
  end;

procedure RegisterCave(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  TCaveFieldFlags = packed record
    Reserved: array[0..23] of Byte;
    Flags: Integer;
  end;
  TCaveMapFields = packed record
    Reserved: array[0..164] of Byte;
    SeatedPlayer: Shortint;
  end;
  TCavePlayerFields = packed record
    Reserved: array[0..164] of Byte;
    Race: Shortint;
  end;
  TCaveMoveFlags = set of (tm0, tm1, tm2, tm3, tm4, tm5, tm6, tm7);
  TCaveRaceNames = array[0..12] of string;
  PCaveRaceNames = ^TCaveRaceNames;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  { Original AoWE resource initialization table $55798BC0..$557990E4. }
  RaceNames: TCaveRaceNames = ('Humans', 'Azracs', 'Lizards', 'Frostlings',
    'Elves', 'Halflings', 'Dwarves', 'Highmen', 'Dark Elves', 'Orcs',
    'Goblins', 'Undead(plural)', 'Independents');
  RaceNameTable: PCaveRaceNames = @RaceNames;
resourcestring
  CaveNoWarRStr = 'Not at war with the %s'; { original RT_STRING $FCD6 }

{ needs: draft AoWE result declarations; retain their proven register ABI. }
function TranslateCaveName(const S: string): string; assembler;
asm JMP AoWE.TranslateRStr end;
function CaveFieldPlayer(Field: TAoWMapField): Shortint; assembler;
asm JMP TAoWMapField.GetPlayer end;
function CaveMoveAction(Field: TAoWMapField; Player: Byte): Byte; assembler;
asm JMP TAoWMapField.GetMoveAction end;
function CavePlayer(List: TPlayerList; Player: Integer): TPlayer; assembler;
asm JMP TPlayerList.GetPlayers end;
function CavePlayerBusy(Player: TPlayer): Boolean; assembler;
asm JMP TPlayer.GetBusy end;
function CaveRelation(List: TPlayerList; PlayerA, PlayerB: Shortint): Byte; assembler;
asm JMP TPlayerList.GetDiplomaticRelation end;
function CaveMoveArmy(ArmyHS: TArmyHS; Mode: Shortint; Path: TMovepath;
  Flags: TCaveMoveFlags; Extra: Integer): Boolean; assembler;
asm JMP AoWE.MoveArmyEx end;
function CaveCreateMove(ArmyHS: TArmyHS; Mode: Shortint; Path: TMovepath;
  Flags: TCaveMoveFlags; Extra: Integer): TTokenEvent; assembler;
asm JMP AoWE.CreateArmyMoveTE end;


type
  TCaveLevel = class(TAoWMapLevel)
    procedure Explore(X, Y, Radius: Integer; Player: Byte);
  end;
  TCaveMoveData = packed record
    Reserved: array[0..48] of Byte;
    Costs: array[0..15, 0..15] of Shortint;
  end;
{ needs: TStructure border image methods return TLibraryImage in EAX. }
function CaveTop(Structure: TStructure): TLibraryImage; assembler;
asm JMP TStructure.GetTopBorderImage end;
function CaveMiddle(Structure: TStructure): TLibraryImage; assembler;
asm JMP TStructure.GetMiddleBorderImage end;
function CaveBottom(Structure: TStructure): TLibraryImage; assembler;
asm JMP TStructure.GetBottomBorderImage end;
function CaveUnit(Units: TUnitList; Index: Integer): TAbstractUnit; assembler;
asm JMP TUnitList.GetUnit end;
function CaveUnitCost(AUnit: TAbstractUnit; Terrain, Overlay: Shortint): Integer; assembler;
asm JMP TAbstractUnit.MovePointCost end;
function CaveUnitMovePoints(AUnit: TAbstractUnit): Shortint; assembler;
asm MOV EDX,[EAX]; JMP DWORD PTR [EDX+$D8] end;
function CaveArmyMovePoints(Army: TArmy; Selection: Byte; Terrain, Overlay: Shortint): Shortint; assembler;
asm JMP TArmy.MoveOnMovePoints end;
function CaveValidateSelection(Army: TArmy; Selection: Byte): Byte; assembler;
asm JMP TArmy.ValidateSelection end;
function CaveVisibility(Army: TArmy): Byte; assembler;
asm JMP TArmy.VisibilityRange end;
procedure TCaveLevel.Explore(X, Y, Radius: Integer; Player: Byte); assembler;
asm JMP TAoWMapLevel.ExploreArea end;


constructor TCave.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEntrance := ceDown;
end;

destructor TCave.Destroy;
var
  OldEntrance: TCaveEntrance;
  Partner: TCave;
begin
  OldEntrance := FEntrance;
  FEntrance := ceIdle;
  if (moPlacedOnMap in FStatus) and (Owner <> nil) then
    if not GetEditMode then
    begin
      if OldEntrance = ceUp then
      begin
        Partner := TCave(WorldMap^.MapContainer.GetField(FXhx, FYhx,
          TMapField(Owner).Lhx - 1).FindOwnedChild($2037E));
        if (Partner <> nil) and (Partner.FEntrance = ceDown) then Partner.Destroy;
      end
      else
      begin
        Partner := TCave(WorldMap^.MapContainer.GetField(FXhx, FYhx,
          TMapField(Owner).Lhx + 1).FindOwnedChild($2037E));
        if (Partner <> nil) and (Partner.FEntrance = ceUp) then Partner.Destroy;
      end;
    end;
  inherited Destroy;
end;

class function TCave.ClassID: Integer;
begin Result := $2037E; end;

procedure TCave.GetTopBorderImage;
var Image: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[33] <> nil) then
      Image := FResource.ImageSequenceList.ImageSequences[33].GetPreviewImage
    else Image := nil;
  end
  else Image := CaveTop(Self);
  asm MOV EAX,Image end;
end;

procedure TCave.GetMiddleBorderImage;
var Image: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[34] <> nil) then
      Image := FResource.ImageSequenceList.ImageSequences[34].GetPreviewImage
    else Image := nil;
  end
  else Image := CaveMiddle(Self);
  asm MOV EAX,Image end;
end;

procedure TCave.GetBottomBorderImage;
var Image: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[35] <> nil) then
      Image := FResource.ImageSequenceList.ImageSequences[35].GetPreviewImage
    else Image := nil;
  end
  else Image := CaveBottom(Self);
  asm MOV EAX,Image end;
end;

function TCave.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  if FEntrance = ceDown then Result := TerrainType else Result := TerrainType + 30;
end;

function TCave.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  { Original permits an upward cave on level zero; there is no lower-bound test. }
  Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx) and
    ((Lhx + 1 < MapContainer.LevelCount) or (FEntrance = ceUp));
end;

function TCave.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var Up, Down: TCave;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
  if Result then
    if not GetEditMode then
      if FEntrance = ceDown then
      begin
        Up := TCave(MapContainer.GetField(Xhx, Yhx, Lhx + 1).FindOwnedChild($2037E));
        if Up = nil then
        begin
          Up := TCave(FResource.CreateResourceUser);
          Up.FEntrance := ceUp;
          Result := Up.PlaceHX(MapContainer, Xhx, Yhx, Lhx + 1);
        end
        else Result := Up.FEntrance = ceUp;
        { Original destroys an existing partner when its entrance direction is wrong. }
        if not Result then Up.Destroy else OverrideTerrain;
      end
      else
      begin
        Down := TCave(MapContainer.GetField(Xhx, Yhx, Lhx - 1).FindOwnedChild($2037E));
        if Down = nil then
        begin
          Down := TCave(FResource.CreateResourceUser);
          Down.FEntrance := ceDown;
          Result := Down.PlaceHX(MapContainer, Xhx, Yhx, Lhx - 1);
        end
        else Result := Down.FEntrance = ceDown;
        if not Result then Down.Destroy else OverrideTerrain;
      end;
end;

procedure TCave.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FEntrance, 1, 6);
end;

procedure TCave.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TCaveFieldFlags(Pointer(Info.MapField)^).Flags :=
      TCaveFieldFlags(Pointer(Info.MapField)^).Flags or $8000;
end;

procedure TCave.MoveExclusive(const Info: HSEngine.THSSenderInfo);
var Field: TMapField;
  Cave: TCave;
begin
  Cave := Self;
  if Info.HN = 0 then
  begin
    case Cave.FEntrance of
      ceDown: Field := WorldMap^.MapContainer.GetField(Cave.FXhx, Cave.FYhx, TMapField(Cave.Owner).Lhx + 1);
      ceUp: Field := WorldMap^.MapContainer.GetField(Cave.FXhx, Cave.FYhx, TMapField(Cave.Owner).Lhx - 1);
    else Field := nil;
    end;
    { Original dereferences the destination even for an idle entrance. }
    TMoveControl(Info.Sender).ExecuteExternalMove(Integer(Info.MapField), Integer(Field),
      TCaveMoveData(Pointer(Info.Sender)^).Costs[Field.TerrainType, Field.OverlayType]);
  end;
end;

function TCave.GetOverlay(Index: Integer): Shortint;
begin
  Result := FResource.TerrainList.Terrain[Index];
  if Result >= 0 then Result := -1;
end;

procedure TCave.Activate;
begin
  inherited Activate;
  TAoWMapField(Owner).UpdateMapField;
end;

procedure TCave.Deactivate;
begin
  inherited Deactivate;
  FStatus := FStatus - [moActivated];
  TAoWMapField(Owner).UpdateMapField;
end;

function TCave.EnterMovePoints(Army: TArmy; Selection: Byte): Shortint;
var Field: TMapField; L: Integer;
begin
  if FEntrance = ceDown then L := GetLhx + 1 else L := GetLhx - 1;
  Field := WorldMap^.MapContainer.GetField(GetXhx, GetYhx, L);
  Result := CaveArmyMovePoints(Army, Selection, Field.TerrainType, Field.OverlayType);
end;

function TCave.CanEnterSelection(Units: TUnitList): Byte;
var
  L, I: Integer;
  Field: TMapField;
  AUnit: TAbstractUnit;
begin
  if FEntrance = ceDown then L := GetLhx + 1 else L := GetLhx - 1;
  Field := WorldMap^.MapContainer.GetField(GetXhx, GetYhx, L);
  Result := 0;
  for I := 0 to Units.Count - 1 do
  begin
    AUnit := CaveUnit(Units, I);
    if CaveUnitCost(AUnit, Field.TerrainType, Field.OverlayType) <=
      CaveUnitMovePoints(AUnit) then Inc(Result, Byte(1) shl I);
  end;
end;

function TCave.CanEnter(Player: Shortint): Boolean;
var ArmyHS: Pointer;
begin
  ArmyHS := Owner.FindOwnedChild($20217);
  if ArmyHS = nil then Result := False
  else if Player <> Shortint(TArmy(TArmyHS(ArmyHS).FArmy).FPlayer) then Result := False
  else Result := CanEnterSelection(TUnitList(TArmyHS(ArmyHS).FArmy)) <> 0;
end;

function TCave.EnterEx: Boolean;
var
  MessageText: string;
  Path: TMovepath;
  L: Shortint;
  ArmyHS: TArmyHS;
  Selection: Byte;
  Field: TAoWMapField;
  Event: TTokenEvent;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  if (ArmyHS = nil) or not CanEnter(Shortint(TArmy(ArmyHS.FArmy).FPlayer)) then
    Result := False
  else
  begin
    Selection := CanEnterSelection(TUnitList(ArmyHS.FArmy));
    L := 0;
    Path := TMovepath.Create;
    case FEntrance of
      ceUp: L := GetLhx - 1;
      ceDown: L := GetLhx + 1;
    end;
    Path.AddXYL(GetXhx, GetYhx, L);
    Path.List^[0].Flag := EnterMovePoints(TArmy(ArmyHS.FArmy), Selection);
    Path.AddXYL(GetXhx, GetYhx, GetLhx);
    Field := TAoWMapField(WorldMap^.MapContainer.GetField(GetXhx, GetYhx, L));
    if (CaveMoveAction(Field, Byte(TArmy(ArmyHS.FArmy).FPlayer)) <> 1) or
      (CaveFieldPlayer(Field) <= 0) or
      (CaveRelation(TPlayerList(WorldMap^.FPlayers),
        Shortint(TArmy(ArmyHS.FArmy).FPlayer), CaveFieldPlayer(Field)) in [1, 3]) then
    begin
      if (CaveFieldPlayer(Field) < 0) or
        (Byte(CaveFieldPlayer(Field)) = Byte(TArmy(ArmyHS.FArmy).FPlayer)) then
        Result := CaveMoveArmy(ArmyHS, Shortint(Selection), Path, [], 0)
      else if not CavePlayerBusy(CavePlayer(TPlayerList(WorldMap^.FPlayers),
        Shortint(TArmy(ArmyHS.FArmy).FPlayer))) then
      begin
        Event := CaveCreateMove(ArmyHS, Shortint(Selection), Path, [], 1);
        if Event <> nil then
        begin
          TTokenManager(WorldMap^.F_AoWHSMap_23C).GetTokenControl(
            Shortint(TArmy(ArmyHS.FArmy).FPlayer)).AddEvent(Event);
          Event.Release;
          Result := True;
        end
        else Result := False;
      end
      else Result := False;
      if Result and (Byte(TCaveMapFields(Pointer(WorldMap^)^).SeatedPlayer) =
        Byte(TArmy(ArmyHS.FArmy).FPlayer)) then
      begin
        WorldMap^.ViewLevel(L);
        TSelectedArmy(WorldMap^.F_AoWHSMap_D8).Select(Integer(ArmyHS));
      end;
    end
    else
    begin
      MessageText := SysUtils.Format(TranslateCaveName(LoadResString(@CaveNoWarRStr)),
        [TranslateCaveName(RaceNameTable^[TCavePlayerFields(Pointer(CavePlayer(
          TPlayerList(WorldMap^.FPlayers), CaveFieldPlayer(Field)))^).Race])]);
      TAbstractAoWHSMap(WorldMap^).ShowMessage(Integer(Pointer(MessageText)));
      Result := False;
    end;
    { Original frees the path only on normal completion. }
    Path.Free;
  end;
end;

function TCave.Enter(Player: Shortint): Boolean;
var
  ArmyHS: TArmyHS;
  Log: TEnterCaveEventLog;
begin
  if CanEnter(Player) then
  begin
    ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
    if CanEnterSelection(TUnitList(ArmyHS.FArmy)) <>
      CaveValidateSelection(TArmy(ArmyHS.FArmy), $FF) then
    begin
      Log := TEnterCaveEventLog.Create(nil);
      Log.FCave := Self;
      TStrings(Log.F_MessageEventLog_20).Text := TranslateCaveName(SplitOnEnterCaveWarningRStr);
      Log.F_MessageEventLog_25 := Ord(mebYesNo);
      Log.Execute(1, etUser, nil);
      Log.Release;
      Result := True;
    end
    else Result := EnterEx;
  end
  else Result := False;
end;

procedure TCave.ArmyPlaced(A1: Integer);
var L: Integer; ArmyHS: TArmyHS;
begin
  inherited ArmyPlaced(A1);
  ArmyHS := TArmyHS(A1);
  if ArmyHS <> nil then
  begin
    if FEntrance = ceDown then L := GetLhx + 1 else L := GetLhx - 1;
    TCaveLevel(WorldMap^.MapContainer.GetMapLevel(L)).Explore(
      ArmyHS.GetXhx, ArmyHS.GetYhx, CaveVisibility(TArmy(ArmyHS.FArmy)),
      Byte(TArmy(ArmyHS.FArmy).FPlayer));
  end;
end;

constructor TCaveResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_StructureResource_44 := 0;
  F_StructureResource_45 := 1;
end;

class function TCaveResource.ResourceEditName: string;
begin Result := TranslateCaveName(CaveRStr); end;

class function TCaveResource.ClassID: Integer;
begin Result := $2037F; end;

function TCaveResource.ResourceUserClassID: Integer;
begin Result := $2037E; end;

procedure TEnterCaveEventLog.Yes;
begin
  FCave.EnterEx;
  asm MOV AL,1 end;
end;

procedure TEnterCaveEventLog.No;
asm MOV AL,1 end;

procedure RegisterCave(AEngine: TEngine);
begin AEngine.RegisterEClasses([TCave, TCaveResource]); end;


initialization
finalization

end.
