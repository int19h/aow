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
    function GetTopBorderImage: TLibraryImage; override;
    function GetMiddleBorderImage: TLibraryImage; override;
    function GetBottomBorderImage: TLibraryImage; override;
    procedure ArmyPlaced(A1: TArmyHS); override;
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
    function Yes: Boolean; override;
    function No: Boolean; override;
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
function CaveUnit(Units: TUnitList; Index: Integer): TAbstractUnit; assembler;
asm JMP TUnitList.GetUnit end;
function CaveUnitCost(AUnit: TAbstractUnit; Terrain, Overlay: Shortint): Integer; assembler;
asm JMP TAbstractUnit.MovePointCost end;
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

function TCave.GetTopBorderImage: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[33] <> nil) then
      Result := FResource.ImageSequenceList.ImageSequences[33].GetPreviewImage
    else Result := nil;
  end
  else Result := inherited GetTopBorderImage;
end;

function TCave.GetMiddleBorderImage: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[34] <> nil) then
      Result := FResource.ImageSequenceList.ImageSequences[34].GetPreviewImage
    else Result := nil;
  end
  else Result := inherited GetMiddleBorderImage;
end;

function TCave.GetBottomBorderImage: TLibraryImage;
begin
  if FEntrance = ceUp then
  begin
    if (FResource.ImageSequenceList <> nil) and
      (FResource.ImageSequenceList.ImageSequences[35] <> nil) then
      Result := FResource.ImageSequenceList.ImageSequences[35].GetPreviewImage
    else Result := nil;
  end
  else Result := inherited GetBottomBorderImage;
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

procedure TCave.MoveExclusive(const Info: HSEngine.THSSenderInfo); { Near miss: register or temporary allocation differs after three variants. }
var Field: TMapField;
begin
  if Info.HN = 0 then
  begin
    case FEntrance of
      ceUp: Field := WorldMap^.MapContainer.GetField(FXhx, FYhx, TMapField(Owner).Lhx - 1);
      ceDown: Field := WorldMap^.MapContainer.GetField(FXhx, FYhx, TMapField(Owner).Lhx + 1);
    else Field := nil;
    end;
    { Original dereferences the destination even for an idle entrance. }
    TMoveControl(Info.Sender).ExecuteExternalMove(TAoWMapField(Info.MapField), TAoWMapField(Field),
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
      AUnit.GetMovePoints then Inc(Result, Byte(1) shl I);
  end;
end;

function TCave.CanEnter(Player: Shortint): Boolean; { Near miss: three variants retain an extra ArmyHS register and a shared return. }
var ArmyHS: TArmyHS;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  Result := (ArmyHS <> nil) and (Player = ArmyHS.FArmy.FPlayer) and
    (CanEnterSelection(ArmyHS.FArmy) <> 0);
end;

function TCave.EnterEx: Boolean; { Near miss: path/result spills and managed temporaries differ after three variants. }
var
  Selection: Byte;
  Path: TMovepath;
  L: Shortint;
  MessageText: string;
  ArmyHS: TArmyHS;
  Field: TAoWMapField;
  Event: TTokenEvent;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  if (ArmyHS <> nil) and CanEnter(ArmyHS.FArmy.FPlayer) then
  begin
    Selection := CanEnterSelection(TUnitList(ArmyHS.FArmy));
    L := 0;
    Path := TMovepath.Create;
    case FEntrance of
      ceDown: L := GetLhx + 1;
      ceUp: L := GetLhx - 1;
    end;
    Path.AddXYL(GetXhx, GetYhx, L);
    Path.List^[0].Flag := EnterMovePoints(TArmy(ArmyHS.FArmy), Selection);
    Path.AddXYL(GetXhx, GetYhx, GetLhx);
    Field := TAoWMapField(AoWE.AoWHSMap.MapContainer.GetField(GetXhx, GetYhx, L));
    if (Field.GetMoveAction(ArmyHS.FArmy.FPlayer) <> maAttack) or
      (Field.GetPlayer <= 0) or
      (Ord(AoWE.AoWHSMap.FPlayers.GetDiplomaticRelation(
        Shortint(TArmy(ArmyHS.FArmy).FPlayer), Field.GetPlayer)) in [1, 3]) then
    begin
      if (Field.GetPlayer > -1) and (Field.GetPlayer <> ArmyHS.FArmy.FPlayer) then
        if not AoWE.AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer).GetBusy then
        begin
          Event := CreateArmyMoveTE(ArmyHS, Selection, Path, maAttack, []); { Original passes action before mode. }
          if Event <> nil then
          begin
            AoWE.AoWHSMap.FTokenManager.GetTokenControl(ArmyHS.FArmy.FPlayer).AddEvent(Event);
            Event.Release;
            Result := True;
          end else Result := False;
        end else Result := False
      else Result := MoveArmyEx(ArmyHS, Selection, Path, [], False);
      if Result and (Byte(TCaveMapFields(Pointer(AoWE.AoWHSMap)^).SeatedPlayer) =
        Byte(TArmy(ArmyHS.FArmy).FPlayer)) then
      begin
        AoWE.AoWHSMap.ViewLevel(L);
        TSelectedArmy(AoWE.AoWHSMap.FSelectedArmy).Select(ArmyHS);
      end;
    end
    else
    begin
      if ArmyHS.FArmy.FPlayer = AoWE.AoWHSMap.FSeatedPlayer then { Original only warns the seated player. }
      begin
        MessageText := SysUtils.Format(TranslateRStr(LoadResString(@NoWarDeclaredtoXRStr)),
          [TranslateRStr(RaceNamesPluralRStr[AoWE.AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerRace])]);
        TAbstractAoWHSMap(AoWE.AoWHSMap).ShowMessage(MessageText);
      end;
      Result := False;
    end;
    { Original frees the path only on normal completion. }
    Path.Free;
  end else Result := False;
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
      Log.FMessage.Text := TranslateCaveName(SplitOnEnterCaveWarningRStr);
      Log.FButtons := mebYesNo;
      Log.Execute(True, etUser, nil);
      Log.Release;
      Result := True;
    end
    else Result := EnterEx;
  end
  else Result := False;
end;

procedure TCave.ArmyPlaced(A1: TArmyHS);
var L: Integer; ArmyHS: TArmyHS;
begin
  inherited ArmyPlaced(A1);
  ArmyHS := TArmyHS(A1);
  if ArmyHS <> nil then
  begin
    if FEntrance = ceDown then L := GetLhx + 1 else L := GetLhx - 1;
    TAoWMapLevel(WorldMap^.MapContainer.GetMapLevel(L)).ExploreArea(
      ArmyHS.GetXhx, ArmyHS.GetYhx, TArmy(ArmyHS.FArmy).FPlayer,
      TArmy(ArmyHS.FArmy).VisibilityRange);
  end;
end;

constructor TCaveResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := False;
  FConnectRoads := True;
end;

class function TCaveResource.ResourceEditName: string;
begin Result := TranslateCaveName(CaveRStr); end;

class function TCaveResource.ClassID: Integer;
begin Result := $2037F; end;

function TCaveResource.ResourceUserClassID: Integer;
begin Result := $2037E; end;

function TEnterCaveEventLog.Yes: Boolean;
begin
  FCave.EnterEx;
  Result := True;
end;

function TEnterCaveEventLog.No: Boolean;
asm MOV AL,1 end;

procedure RegisterCave(AEngine: TEngine);
begin AEngine.RegisterEClasses([TCave, TCaveResource]); end;


initialization
finalization

end.
