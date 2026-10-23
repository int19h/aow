unit HolyG;

{ HolyG, from AoWEPACK.dpl. Recovered holy terrain, damage, summoning and
  spell bodies at the original instance layouts and VMT order. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, EventLog, GlobalTargetSpells, Animation, AoWE;

type
  THolyGround = class;
  THolyGroundResource = class;
  THolyGroundSpellTE = class;
  THolyGroundSpell = class;


  { THolyGround (instance size 32, VMT 557C79A0): $1C FMode, $1D FPlayer,
    $1E FDuration, $1F FOriginalOverlay. }
  THolyGround = class(TILTerrainMO)
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

  { THolyGroundResource (instance size 68, VMT 557C7B48) }
  THolyGroundResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { THolyGroundSpellTE (instance size 36, VMT 557C7C40) }
  THolyGroundSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure CreateHolyGround(Caster: TAbstractUnit);
  end;

  { THolyGroundSpell (instance size 60, VMT 557C7D1C) }
  THolyGroundSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

procedure RegisterHolyGround(Engine: TEngine);
procedure UnRegisterHolyGround(Engine: TEngine);

implementation

{$IFDEF RUNTIME_PACKAGES}
var
  RandomSeed: ^Integer;
{$ENDIF}

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  WorldEngine: ^TAoWEngine = @AoWE.AoWEngine;
{$IFNDEF RUNTIME_PACKAGES}
  RandomSeed: ^Integer = @System.RandSeed;
{$ENDIF}
  EvilAlignments: ^TAlignments = @AoWE.alsPureEvil;

class function THolyGround.ClassID: Integer;
begin Result := $20393; end;

procedure THolyGround.TriggerArmyDamage(Army: TArmyHS);
var
  Log: TArmyEventLog;
  I, Damage, Damaged: Integer;
  AUnit: TAbstractUnit;
begin
  Damaged := 0;
  RandomSeed^ := WorldMap^.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(HolyGroundDamageRStr);
  Log.FArmyMessages.Add(TranslateRStr(HolyGroundDamageRStr));
  Log.FArmyIcon := 2;
  Log.FPlayer := Army.FArmy.FPlayer;
  Log.FArmyView.Setup(Army.FArmy, $FF);
  with Army.FArmy do
    for I := 0 to Count - 1 do
    begin
      AUnit := GetUnit(I);
      if (AUnit.GetAlignment <> alNone) and
        (AUnit.GetAlignment in EvilAlignments^) and not AUnit.GetAbilityEnabled(1) then
      begin
        Damage := AUnit.ExecuteDamageRole(3, 4, [dtHoly]);
        if Damage > AUnit.GetHitPoints then Damage := AUnit.GetHitPoints;
        if Damage <> 0 then
        begin
          AUnit.SetHitPoints(AUnit.GetHitPoints - Damage);
          Inc(Damaged);
        end;
        Log.FDamageValues.Add(Damage);
        Log.FDamageTypes.Add(Ord(dtHoly));
      end
      else
      begin
        Log.FDamageValues.Add(0);
        Log.FDamageTypes.Add(Ord(dtNone));
      end;
    end;
  Log.ValidateGameOver;
  if Damaged <> 0 then
    DistributeLocationEventLog(Log, Log.FPlayer, GetXhx, GetYhx, GetLhx, True);
  Log.Release;
  Army.FArmy.Validate;
end;

procedure THolyGround.ArmyPlaced(Army: TArmyHS);
begin
  if not (msEditting in WorldMap^.Status) then TriggerArmyDamage(Army);
end;

procedure THolyGround.RestoreTerrain;
var Field: TMapField; Overlay: Shortint;
begin
  Field := TMapField(Owner);
  Overlay := FOriginalOverlay;
  Destroy;
  if Overlay > 0 then
    WorldMap^.PlaceTerrain(Field.Xhx, Field.Yhx, Field.Lhx, Field.TerrainType, Overlay);
end;

procedure THolyGround.NewTurn(Player: Shortint);
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

function THolyGround.CanDoDamage(Units: TUnitList): Boolean;
var I: Integer; AUnit: TAbstractUnit;
begin
  Result := False;
  I := Units.Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := Units.GetUnit(I);
    Result := not (dtHoly in AUnit.GetImmunityTypes) and
      (AUnit.GetAlignment <> alNone) and (AUnit.GetAlignment in EvilAlignments^) and
      not AUnit.GetAbilityEnabled(1);
  end;
end;

procedure THolyGround.UpdateMapField(const Info: THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function THolyGround.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), GetXhx, GetYhx);
end;

procedure THolyGround.RemoveFromMap;
var Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(Level, FXhx, FYhx);
end;

procedure THolyGround.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortintEx(FPlayer, -1, 40);
  Stream.rwShortintEx(FDuration, -1, 41);
  Stream.rwShortintEx(FOriginalOverlay, -1, 42);
end;

function THolyGround.CanMoveOver(const Info: THSSenderInfo): Integer;
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
  begin
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else begin Result := 0; Exit; end;
  end
  else Result := 1;
end;

procedure THolyGround.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1142 then
  begin
    if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and
      not (msEditting in WorldMap^.Status) then
    begin
      ArmyPlaced(TArmyHS(Msg.Param[0]));
      Exit;
    end;
    Exit;
  end;
  if Integer(Msg.MsgID) = $1120 then
  begin
    if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
      if CanDoDamage(TArmyHS(Msg.Param[0]).FArmy) then Msg.Result := 1;
  end
  else
  if TMapFieldMsg(Pointer(@Msg)^).MsgID = $1132 then
    if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and (FPlayer > 0) and
      (FDuration > 0) then RestoreTerrain;
end;

procedure THolyGround.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure THolyGround.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  if not (hgSummoning in FMode) then inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure THolyGround.ShowSummonAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var Field: TMapField;
begin
  Field := WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx);
  if (Self = Field.FindOwnedChild($20393)) and (Ord(WorldEngine^.FAnimationDetail) <> 0) and
    (Anim.FFrameCounter = 0) then
    if (WorldMap^.FSeatedPlayer = Anim.FTag) or
      AoWE.AoWHSMap.WatchingTerrain(GetXhx, GetYhx, GetLhx, 0) then
      WorldSet^.FSpellControl.GetSpell(13).FCastSounds.Play(0);
end;

procedure THolyGround.NewFrameSummonAnimation(Anim: TAnimation; FrameCounter: Integer);
var Field: TMapField;
begin
  Anim := TAnimation(WorldMap^.MapContainer.GetField(Anim.GetXhx, Anim.GetYhx, Anim.GetLhx));
  if (Self = TMapField(Anim).FindOwnedChild($20393)) and (FrameCounter = 9) then
    FMode := FMode - [hgSummoning];
end;

class function THolyGroundResource.ResourceEditName: string;
begin Result := TranslateRStr(HolyGroundRStr); end;

class function THolyGroundResource.ClassID: Integer;
begin Result := $20394; end;

function THolyGroundResource.ResourceUserClassID: Integer;
begin Result := $20393; end;

class function THolyGroundSpellTE.ClassID: Integer;
begin Result := $21306; end;

procedure THolyGroundSpellTE.CreateHolyGround(Caster: TAbstractUnit);
var
  Level: TMapLevel;
  Walk: THNWalkData;
  Resource: THolyGroundResource;
  Field: TAoWMapField;
  Ground: THolyGround;
  Anim: TImageSequenceAnimation;
begin
  Level := WorldMap^.MapContainer.GetMapLevel(TXYL(FLocation).L);
  InitHNWalk(Walk, TXYL(FLocation).X, TXYL(FLocation).Y, 0);
  Resource := THolyGroundResource(WorldSet^.MapObjectResourceList.FindChild($20394));
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.Field[Walk.X, Walk.Y]);
      if THolyGroundSpell(WorldSet^.FSpellControl.GetSpell(13)).ValidTargetMapF(Field) then
        if Field.GetArmyHS = nil then
        begin
          Field.RestoreTerrain;
          Ground := THolyGround(Resource.CreateResourceUser);
          Ground.FDuration := (WorldMap^.Random(11) - 5) div 5 + 3;
          Ground.FPlayer := Caster.FPlayer;
          Ground.FOriginalOverlay := Field.OverlayType;
          WorldMap^.ClearTerrain(Walk.X, Walk.Y, TXYL(FLocation).L, 0, -1);
          if WorldMap^.PlaceHX(Ground, Walk.X, Walk.Y, TXYL(FLocation).L) then
          begin
            Ground.FMode := [hgSummoning];
            Anim := TImageSequenceAnimation.Create(nil);
            Anim.SetImageSequence(WorldSet^.FSpellControl.GetSpell(13).FCastImages.ImageSequences[0]);
            Anim.FOnShow := Ground.ShowSummonAnimation;
            Anim.FOnNewFrame := Ground.NewFrameSummonAnimation;
            Anim.FFrameCounter := -WorldMap^.Random(15);
            Anim.FTag := Caster.FPlayer;
            WorldMap^.PlaceHX(Anim, Walk.X, Walk.Y, TXYL(FLocation).L);
          end
          else Ground.Free;
        end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function THolyGroundSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  CreateHolyGround(A1);
  WorldMap^.ValidateTerrainObservation(A1.FPlayer,
    TXYL(FLocation).X, TXYL(FLocation).Y, TXYL(FLocation).L, 1);
  WorldSet^.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
  Result := False;
end;

constructor THolyGroundSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(HolyGroundsRStr);
  FSpellID := 13;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msLife;
  FAboveGroundOnly := False;
end;

function THolyGroundSpell.ValidTargetMapF(A1: TMapField): Boolean;
begin
  Result := inherited ValidTargetMapF(A1) and (TAoWMapField(A1).TerrainType in [1..5, 12]);
  { Original overlay test allows these overlays even when the terrain check failed. }
  Result := Result and (TAoWMapField(A1).OverlayType = -1) or
    (TAoWMapField(A1).OverlayType in [1..4, 9]);
  Result := Result and (TAoWMapField(A1).FindNoneTransparentHS(TStructure) = nil) and
    (TAoWMapField(A1).GetArmyHS = nil);
end;

function THolyGroundSpell.ValidTargetSelectionMapF(A1: TMapField): Boolean;
var Army: TArmyHS;
begin
  Result := inherited ValidTargetMapF(A1) and (TAoWMapField(A1).TerrainType in [1..5, 12]);
  { Original overlay test allows these overlays even when the terrain check failed. }
  Result := Result and (TAoWMapField(A1).OverlayType = -1) or
    (TAoWMapField(A1).OverlayType in [1..4, 9]);
  Result := Result and (TAoWMapField(A1).FindNoneTransparentHS(TStructure) = nil);
  if Result then
  begin
    Army := TAoWMapField(A1).GetArmyHS;
    if Army <> nil then Result := not Army.VisibleForSeatedPlayer;
  end;
end;

procedure THolyGroundSpell.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var I: Integer;
begin
  inherited SetupTargetSelection(A1, A2);
  TTargetSelectionControl(A2).FHNs.Clear;
  for I := 0 to RadToHN(2) - 1 do
    TTargetSelectionControl(A2).FHNs.Add(0);
end;

function THolyGroundSpell.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var Event: THolyGroundSpellTE;
begin
  Event := THolyGroundSpellTE.Create(nil);
  Event.Initialize(FSpellID, TAbstractUnit(A1).FPlayer, TAbstractUnit(A1).FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  WorldMap^.FTokenManager.GetTokenControl(TAbstractUnit(A1).FPlayer).AddEvent(Event);
  Event.Release;
  Result := True;
end;

procedure RegisterHolyGround(Engine: TEngine);
begin
  Engine.RegisterEClasses([THolyGround, THolyGroundResource, THolyGroundSpellTE]);
  TAoWEngine(Engine).FGameSet.FSpellControl.RegisterSpell(THolyGroundSpell.Create(nil));
end;

procedure UnRegisterHolyGround(Engine: TEngine);
begin
  Engine.UnregisterEClasses([THolyGround, THolyGroundResource, THolyGroundSpellTE]);
  TAoWEngine(Engine).FGameSet.FSpellControl.UnregisterSpellID(13);
end;

initialization
{$IFDEF RUNTIME_PACKAGES}
  RandomSeed := @System.RandSeed;
{$ENDIF}
finalization

end.
