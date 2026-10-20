unit UnHolyG;

{ Draft declarations of UnHolyG, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TUnHolyGround is recovered; resource and spell bodies remain drafts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, GlobalTargetSpells, AoWE, Animation, EventLog;

type
  TUnHolyGround = class;
  TUnHolyGroundResource = class;
  TUnholyGroundSpellTE = class;
  TUnholyGroundSpell = class;


  { TUnHolyGround (instance size 32, VMT 557C8B10): $1C FMode, $1D FPlayer,
    $1E FDuration, $1F FOriginalOverlay. }
  TUnHolyGround = class(TILTerrainMO)
  public
    FMode: set of (hgSummoning); { $1C }
    FPlayer: Shortint; { $1D }
    FDuration: Shortint; { $1E }
    FOriginalOverlay: Shortint; { $1F }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure TriggerArmyDamage(Army: TArmyHS);
    procedure ArmyPlaced(Army: TArmyHS);
    procedure RestoreTerrain;
    procedure NewTurn(Player: Shortint);
    function CanDoDamage(Units: TUnitList): Boolean;
    procedure ShowSummonAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure NewFrameSummonAnimation(Anim: TAnimation; FrameCounter: Integer);
  end;

  { TUnHolyGroundResource (instance size 68, VMT 557C8CC0) }
  TUnHolyGroundResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TUnholyGroundSpellTE (instance size 36, VMT 557C8DC0) }
  TUnholyGroundSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure CreateUnholyGround(A1: Integer);  { draft }
  end;

  { TUnholyGroundSpell (instance size 60, VMT 557C8EA4) }
  TUnholyGroundSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

procedure RegisterUnHolyGround(A1: Integer);  { draft }
procedure UnRegisterUnholyGround(A1: Integer);  { draft }

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  WorldEngine: ^TAoWEngine = @AoWE.AoWEngine;
  RandomSeed: ^Integer = @System.RandSeed;
  GoodAlignments: ^TAlignments = @AoWE.alsPureGood;

class function TUnHolyGround.ClassID: Integer;
begin Result := $20391; end;

procedure TUnHolyGround.TriggerArmyDamage(Army: TArmyHS);
var
  Log: TArmyEventLog;
  I, Damage, Damaged: Integer;
  AUnit: TAbstractUnit;
begin
  Damaged := 0;
  RandomSeed^ := WorldMap^.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(UnholyGroundDamageRStr);
  Log.FArmyMessages.Add(TranslateRStr(UnholyGroundDamageRStr));
  Log.FArmyIcon := 2;
  with Army.FArmy do
  begin
    for I := 0 to Count - 1 do
    begin
      AUnit := GetUnit(I);
      if (AUnit.GetAlignment <> alNone) and
        (AUnit.GetAlignment in GoodAlignments^) and not AUnit.GetAbilityEnabled(1) then
      begin
        Damage := AUnit.ExecuteDamageRole(4, 3, [dtDeath]);
        if Damage > AUnit.GetHitPoints then Damage := AUnit.GetHitPoints;
        if Damage <> 0 then
        begin
          AUnit.SetHitPoints(AUnit.GetHitPoints - Damage);
          Inc(Damaged);
        end;
        Log.FDamageValues.Add(Damage);
        Log.FDamageTypes.Add(Ord(dtDeath));
      end
      else
      begin
        Log.FDamageValues.Add(0);
        Log.FDamageTypes.Add(Ord(dtDeath));
      end;
    end;
    Log.FPlayer := FPlayer;
    Log.FArmyView.Setup(GetArmyHS.FArmy, $FF);
  end;
  Log.ValidateGameOver;
  if Damaged <> 0 then
    DistributeLocationEventLog(Log, Log.FPlayer, GetXhx, GetYhx, GetLhx, 1);
  Log.Release;
  Army.FArmy.Validate;
end;

procedure TUnHolyGround.ArmyPlaced(Army: TArmyHS);
begin
  if not (msEditting in WorldMap^.Status) then TriggerArmyDamage(Army);
end;

procedure TUnHolyGround.RestoreTerrain;
var Field: TMapField; Overlay: Shortint;
begin
  Field := TMapField(Owner);
  Overlay := FOriginalOverlay;
  Destroy;
  if Overlay > 0 then
    WorldMap^.PlaceTerrain(Field.Xhx, Field.Yhx, Field.Lhx, Field.TerrainType, Overlay);
end;

procedure TUnHolyGround.NewTurn(Player: Shortint);
var Army: TArmyHS;
begin
  Army := TArmyHS(Owner.FindOwnedChild($20217));
  if (Army <> nil) and (Player = Army.FArmy.FPlayer) then TriggerArmyDamage(Army);
  if (Player = FPlayer) and (FDuration > 0) then
  begin
    Dec(FDuration);
    if FDuration = 0 then RestoreTerrain;
  end;
end;

function TUnHolyGround.CanDoDamage(Units: TUnitList): Boolean;
var I: Integer; AUnit: TAbstractUnit;
begin
  Result := False;
  I := Units.Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := Units.GetUnit(I);
    Result := not (dtDeath in AUnit.GetImmunityTypes) and
      (AUnit.GetAlignment <> alNone) and (AUnit.GetAlignment in GoodAlignments^) and
      not AUnit.GetAbilityEnabled(1);
  end;
end;

procedure TUnHolyGround.UpdateMapField(const Info: THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function TUnHolyGround.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), GetXhx, GetYhx);
end;

procedure TUnHolyGround.RemoveFromMap;
var Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(Level, FXhx, FYhx);
end;

procedure TUnHolyGround.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortintEx(FPlayer, -1, 40);
  Stream.rwShortintEx(FDuration, -1, 41);
  Stream.rwShortintEx(FOriginalOverlay, -1, 42);
end;

function TUnHolyGround.CanMoveOver(const Info: THSSenderInfo): Integer;
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
  begin
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else begin Result := 0; Exit; end;
  end
  else Result := 1;
end;

procedure TUnHolyGround.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1142 then
  begin
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
    begin
      ArmyPlaced(TArmyHS(Msg.Param[0]));
      Exit;
    end;
  end
  else if Msg.MsgID = $1120 then
  begin
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
      if CanDoDamage(TArmyHS(Msg.Param[0]).FArmy) then Msg.Result := 1;
  end
  else if Msg.MsgID = $1132 then
    if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and (FPlayer > 0) and
      (FDuration > 0) then RestoreTerrain;
end;

procedure TUnHolyGround.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure TUnHolyGround.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  if not (hgSummoning in FMode) then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TUnHolyGround.ShowSummonAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var Field: TMapField;
begin
  Field := WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx);
  if (Self = Field.FindOwnedChild($20391)) and (WorldEngine^.FAnimationDetail <> 0) and
    (Anim.FFrameCounter = 0) then
    if (WorldMap^.FSeatedPlayer = Anim.FTag) or
      AoWE.AoWHSMap.WatchingTerrain(GetXhx, GetYhx, GetLhx, 0) then
      WorldSet^.FSpellControl.GetSpell(14).FCastSounds.Play(0);
end;

procedure TUnHolyGround.NewFrameSummonAnimation(Anim: TAnimation; FrameCounter: Integer);
var Field: TMapField;
begin
  Field := WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx);
  if (Self = Field.FindOwnedChild($20391)) and (FrameCounter = 9) then
    FMode := FMode - [hgSummoning];
end;

class function TUnHolyGroundResource.ResourceEditName: string;
begin Result := ''; end;

class function TUnHolyGroundResource.ClassID: Integer;
begin Result := 0; end;

function TUnHolyGroundResource.ResourceUserClassID: Integer;
begin Result := 0; end;

class function TUnholyGroundSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TUnholyGroundSpellTE.CreateUnholyGround(A1: Integer);
begin end;

function TUnholyGroundSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin Result := False; end;

constructor TUnholyGroundSpell.Create(AOwner: Engine.TECustomNode);
begin end;

function TUnholyGroundSpell.ValidTargetMapF(A1: TMapField): Boolean;
begin Result := False; end;

function TUnholyGroundSpell.ValidTargetSelectionMapF(A1: TMapField): Boolean;
begin Result := False; end;

procedure TUnholyGroundSpell.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
begin end;

function TUnholyGroundSpell.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
begin Result := False; end;

procedure RegisterUnHolyGround(A1: Integer);
begin end;

procedure UnRegisterUnholyGround(A1: Integer);
begin end;


initialization
finalization

end.
