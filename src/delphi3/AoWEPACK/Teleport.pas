unit Teleport;

{ Teleport of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Animation, AoWE;

type
  TTeleportState = set of (tsRazed, ts1, ts2, ts3, ts4, ts5, ts6, ts7);
  TTeleport = class;
  TTeleportResource = class;


  { TTeleport (instance size 52, VMT 557A4A28): +$30 FDestinationX, +$31 FDestinationY,
    +$32 FDestinationL, +$33 FState (bit 0 razed). }
  TTeleport = class(TStructure)
  public
    FDestinationX: Shortint;
    FDestinationY: Shortint;
    FDestinationL: Shortint;
    FState: TTeleportState;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure MoveExclusive(const Info: HSEngine.THSSenderInfo); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    function ValidateMap(A1: TStrings): Boolean; override;
    procedure ShowTeleportAnimations;
    function CanTeleportArmy(ArmyHS: TArmyHS): Boolean;
    function CanTeleport(Player: Shortint): Boolean;
    function Teleport(Player: Shortint): Boolean;
  end;

  { TTeleportResource (instance size 100, VMT 557A4C88) }
  TTeleportResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterTeleport(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PAoWHSSet = ^TAoWHSSet;
  TTeleportFieldFlags = packed record
    Reserved: array[0..23] of Byte;
    Flags: Integer;
  end;
  TTeleportMapFields = packed record
    Reserved: array[0..164] of Byte;
    SeatedPlayer: Shortint;
  end;
  TTeleportPlayerFields = packed record
    Reserved: array[0..164] of Byte;
    Race: Shortint;
  end;
  TTeleportImageFields = packed record
    Reserved: array[0..19] of Byte;
    ImageIndex: Integer;
  end;
  TTeleportMoveFlags = set of (tm0, tm1, tm2, tm3, tm4, tm5, tm6, tm7);
  TTeleportRaceNames = array[0..12] of string;
  PTeleportRaceNames = ^TTeleportRaceNames;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  WorldSet: PAoWHSSet = @AoWE.AoWHSSet;
  { Original AoWE resource initialization table $55798BC0..$557990E4. }
  RaceNames: TTeleportRaceNames = ('Humans', 'Azracs', 'Lizards', 'Frostlings',
    'Elves', 'Halflings', 'Dwarves', 'Highmen', 'Dark Elves', 'Orcs',
    'Goblins', 'Undead(plural)', 'Independents');
  RaceNameTable: PTeleportRaceNames = @RaceNames;
resourcestring
  TeleportNoWarRStr = 'Not at war with the %s'; { original RT_STRING $FCD6 }
  TeleportWarningRStr = 'Warning'; { original RT_STRING $FEB4 }

{ needs: draft AoWE result declarations; retain their proven register ABI. }
function TeleportValidTerrain(Army: TArmy; Terrain, Overlay: Shortint): Boolean; assembler;
asm JMP TArmy.ValidTerrain end;
function TeleportCanAdd(Army: TArmy; Units: TUnitList): Boolean; assembler;
asm JMP TArmy.CanAddUnits end;
function TeleportMoveAction(Field: TAoWMapField; Player: Byte): Byte; assembler;
asm JMP TAoWMapField.GetMoveAction end;

constructor TTeleport.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDestinationX := 0;
  FDestinationY := 0;
  FDestinationL := 0;
end;

class function TTeleport.ClassID: Integer;
begin Result := $20104; end;

function TTeleport.GetRazed: Boolean;
{ needs: TStructure.GetRazed returns Boolean in AL. }
asm
  TEST BYTE PTR [EAX+$33],1
  SETNE AL
end;

procedure TTeleport.SetRazed(Value: Boolean);
begin
  if Value then FState := FState + [tsRazed] else FState := FState - [tsRazed];
  { needs: ILTer.TILTerrainMO.FImageIndex is private. }
  TTeleportImageFields(Pointer(Self)^).ImageIndex := GetTerrainTypeImage(TerrainType);
end;

procedure TTeleport.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FDestinationX), 7);
  Stream.rwByte(Byte(FDestinationY), 8);
  Stream.rwByte(Byte(FDestinationL), 9);
  Stream.rwData(FState, 1, 10);
end;

procedure TTeleport.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then
    TTeleportFieldFlags(Pointer(Info.MapField)^).Flags :=
      TTeleportFieldFlags(Pointer(Info.MapField)^).Flags or $8000;
end;

procedure TTeleport.MoveExclusive(const Info: HSEngine.THSSenderInfo);
begin
  if (Info.HN = 0) and not (tsRazed in FState) then
    TMoveControl(Info.Sender).ExecuteExternalMove(TAoWMapField(Info.MapField),
      TAoWMapField(WorldMap^.MapContainer.GetField(FDestinationX, FDestinationY, FDestinationL)), 0);
end;

procedure TTeleport.ShowTeleportAnimations;
var
  Anim: TImageSequenceAnimation;
begin
  Anim := TImageSequenceAnimation.Create(nil);
  Anim.SetImageSequence(TImageSequenceList(WorldSet^.FImageSequences).ImageSequences[13]);
  WorldMap^.PlaceHX(Anim, GetXhx, GetYhx, GetLhx);
  Anim := TImageSequenceAnimation.Create(nil);
  Anim.SetImageSequence(TImageSequenceList(WorldSet^.FImageSequences).ImageSequences[12]);
  WorldMap^.PlaceHX(Anim, FDestinationX, FDestinationY, FDestinationL);
end;

procedure TTeleport.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if (Msg.HN = 0) and (Msg.MsgID = $1140) and
    (TMapField(Msg.Param[1]).Xhx = FDestinationX) and
    (TMapField(Msg.Param[1]).Yhx = FDestinationY) and
    (TMapField(Msg.Param[1]).Lhx = FDestinationL) then
  begin
    if (not AoWE.AoWHSMap.FFogEnabled) or
      AoWE.AoWHSMap.VisibleForPlayer(GetXhx, GetYhx, GetLhx,
        TTeleportMapFields(Pointer(AoWE.AoWHSMap)^).SeatedPlayer) or
      AoWE.AoWHSMap.VisibleForPlayer(FDestinationX, FDestinationY, FDestinationL,
        TTeleportMapFields(Pointer(AoWE.AoWHSMap)^).SeatedPlayer) then
      Sound.PlaySample('SFX\PLACES\TELEPORT.WAV');
    ShowTeleportAnimations;
  end;
end;

procedure TTeleport.Activate;
begin inherited Activate; TMapField(Owner).UpdateMapField; end;

procedure TTeleport.Deactivate;
begin
  inherited Deactivate;
  FStatus := FStatus - [moActivated];
  TMapField(Owner).UpdateMapField;
end;

function TTeleport.CanTeleportArmy(ArmyHS: TArmyHS): Boolean;
var
  Field: TAoWMapField;
  OtherArmy: TArmyHS;
begin
  Result := False;
  if (FDestinationL >= 0) and (FDestinationL < WorldMap^.MapContainer.LevelCount) and
    (FDestinationX >= 0) and (FDestinationX < WorldMap^.MapContainer.Width) and
    (FDestinationY >= 0) and (FDestinationY < WorldMap^.MapContainer.Height) then
  begin
    Field := TAoWMapField(WorldMap^.MapContainer.GetField(FDestinationX, FDestinationY, FDestinationL));
    if TeleportValidTerrain(TArmy(ArmyHS.FArmy), Field.TerrainType, Field.OverlayType) then
    begin
      OtherArmy := Field.GetArmyHS;
      { Original rejects a same-player army when CanAddUnits succeeds. }
      if (OtherArmy <> nil) and
        (Byte(TArmy(ArmyHS.FArmy).FPlayer) = Byte(TArmy(OtherArmy.FArmy).FPlayer)) and
        TeleportCanAdd(TArmy(OtherArmy.FArmy), TUnitList(ArmyHS.FArmy)) then Exit;
      Result := True;
    end;
  end;
end;

function TTeleport.CanTeleport(Player: Shortint): Boolean;
var
  ArmyHS: TArmyHS;
begin
  ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
  { Original only checks destination X here; X=0 is rejected. }
  Result := (ArmyHS <> nil) and (Player = ArmyHS.FArmy.FPlayer) and
    not (tsRazed in FState) and (FDestinationX > 0);
end;

function TTeleport.Teleport(Player: Shortint): Boolean; { Unmatched: tried make player parameter addressable. }
var
  ArmyHS: TArmyHS;
  Path: TMovepath;
  Field: TAoWMapField;
  Event: TTokenEvent;
  MessageText: string;
begin
  if CanTeleport(Player) then
  begin
    ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
    if CanTeleportArmy(ArmyHS) then
    begin
      TArmy(ArmyHS.FArmy).ResetDestinationPos;
      Path := TMovepath.Create;
      Path.AddXYL(FDestinationX, FDestinationY, FDestinationL);
      Path.AddXYL(GetXhx, GetYhx, GetLhx);
      Field := TAoWMapField(AoWE.AoWHSMap.MapContainer.GetField(FDestinationX, FDestinationY, FDestinationL));
      if (Field.GetMoveAction(ArmyHS.FArmy.FPlayer) <> maAttack) or
        (Field.GetPlayer <= 0) or
        (TPlayerList(AoWE.AoWHSMap.FPlayers).GetDiplomaticRelation(
          ArmyHS.FArmy.FPlayer, Field.GetPlayer) in [drWar, drUnknown]) then
      begin
        if (Field.GetPlayer > -1) and
          (Field.GetPlayer <> ArmyHS.FArmy.FPlayer) then
          if not TPlayerList(AoWE.AoWHSMap.FPlayers).GetPlayers(ArmyHS.FArmy.FPlayer).GetBusy then
          begin
            Event := CreateArmyMoveTE(ArmyHS, $FF, Path, maAttack, []); { Original passes action before mode. }
            if Event <> nil then
            begin
              TTokenManager(AoWE.AoWHSMap.FTokenManager).GetTokenControl(
                Shortint(TArmy(ArmyHS.FArmy).FPlayer)).AddEvent(Event);
              Event.Release;
              Result := True;
            end
            else Result := False;
          end
          else Result := False
        else Result := MoveArmyEx(ArmyHS, $FF, Path, [], False);
        if Result and (Byte(TTeleportMapFields(Pointer(AoWE.AoWHSMap)^).SeatedPlayer) =
          Byte(TArmy(ArmyHS.FArmy).FPlayer)) then
        begin
          AoWE.AoWHSMap.CenterViewTo(FDestinationX, FDestinationY, FDestinationL);
          TSelectedArmy(AoWE.AoWHSMap.FSelectedArmy).Select(ArmyHS);
        end;
      end
      else
      begin
        MessageText := SysUtils.Format(TranslateRStr(LoadResString(@NoWarDeclaredtoXRStr)),
          [TranslateRStr(RaceNamesPluralRStr[TPlayerList(AoWE.AoWHSMap.FPlayers).GetPlayers(Field.GetPlayer).FPlayerRace])]);
        TAbstractAoWHSMap(AoWE.AoWHSMap).ShowMessage(MessageText);
        Result := False;
      end;
      { Original frees the path only on normal completion. }
      Path.Free;
    end
    else Result := False;
  end
  else Result := False;
end;

function TTeleport.ValidateMap(A1: TStrings): Boolean;
begin
  if (FDestinationX = 0) or (FDestinationY = 0) then
  begin
    A1.Add(TranslateRStr(WarningRStr) + ': ' + TranslateRStr(InvalidLocationSpecifiedRStr));
    Result := False;
  end
  else Result := True;

end;

constructor TTeleportResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FRazeable := True;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TTeleportResource.ClassID: Integer;
begin Result := $20105; end;

class function TTeleportResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@TeleportRStr)); end;

function TTeleportResource.ResourceUserClassID: Integer;
begin Result := $20104; end;

procedure RegisterTeleport(AEngine: TEngine);
begin AEngine.RegisterEClasses([TTeleport, TTeleportResource]); end;


initialization
finalization

end.
