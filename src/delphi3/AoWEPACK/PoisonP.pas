unit PoisonP;

{ PoisonP, recovered from AoWEPACK.dpl.
  Remaining guessed signatures are marked draft. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, EventLog, GlobalTargetSpells, Animation, AoWE;

type
  TPoisonPlantStatus = set of (ppsSummoning);
  TPoisonPlant = class;
  TPoisonPlantResource = class;
  TPoisonPlantSpellTE = class;
  TPoisonPlantSpell = class;


  { TPoisonPlant (instance size 32, VMT 557C3AB8):
    $1C summoning status; $1D caster player; $1E remaining turns; $1F original overlay. }
  TPoisonPlant = class(TILTerrainMO)
  public
    FPlantStatus: TPoisonPlantStatus; { $1C }
    FCasterPlayer: Shortint; { $1D }
    FDaysRemaining: Shortint; { $1E }
    FOriginalOverlay: Shortint; { $1F }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function PoisonPlantActive: Boolean;
    function CanDoDamage(Units: TUnitList): Boolean;
    procedure TriggerArmyDamage(ArmyHS: TArmyHS);
    procedure ArmyPlaced(ArmyHS: TArmyHS);
    procedure RestoreTerrain;
    procedure NewTurn(Player: Shortint);
    procedure ShowSummonAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure NewFrameSummonAnimation(Animation: TAnimation; FrameCounter: Integer);
  end;

  { TPoisonPlantResource (instance size 68, VMT 557C3C68) }
  TPoisonPlantResource = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TPoisonPlantSpellTE (instance size 36, VMT 557C3D68) }
  TPoisonPlantSpellTE = class(TGlobalTargetSpellTE)
  public
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure CreatePoisonPlant(Source: TAbstractUnit);
  end;

  { TPoisonPlantSpell (instance size 60, VMT 557C3E48) }
  TPoisonPlantSpell = class(TGlobalTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl); override;
    function TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean; override;
    function ValidTargetSelectionMapF(A1: TMapField): Boolean; override;
    function ValidTargetMapF(A1: TMapField): Boolean; override;
  end;

procedure RegisterPoisonPlant(AEngine: TAoWEngine);
procedure UnRegisterPoisonPlant(AEngine: TAoWEngine);

implementation

constructor TPoisonPlant.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCasterPlayer := -1;
  FOriginalOverlay := -1;
  FDaysRemaining := -1;
  FPlantStatus := [];
end;

class function TPoisonPlant.ClassID: Integer;
begin
  Result := $2039E;
end;

function TPoisonPlant.PoisonPlantActive: Boolean;
begin
  Result := not (FTerrainType in [3, 5]);
end;

procedure TPoisonPlant.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortintEx(FCasterPlayer, -1, $28);
  Stream.rwShortintEx(FDaysRemaining, -1, $29);
  Stream.rwShortintEx(FOriginalOverlay, -1, $2A);
end;

function TPoisonPlant.CanDoDamage(Units: TUnitList): Boolean;
var
  I: Integer;
  U: TAbstractUnit;
begin
  Result := False;
  I := Units.Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    U := Units.GetUnit(I);
    Result := not (dtPoison in U.GetImmunityTypes) and not U.GetAbilityEnabled(1);
  end;
end;

procedure TPoisonPlant.TriggerArmyDamage(ArmyHS: TArmyHS);
var
  I, Count: Integer;
  Units: TUnitList;
  Log: TArmyEventLog;
  U: TAbstractUnit;
  Damage: Integer;
begin
  Count := 0;
  RandSeed := AoWHSMap.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(PoisonPlantDamageRStr);
  Log.FPlayer := ArmyHS.FArmy.FPlayer;
  Log.FArmyMessages.Add(TranslateRStr(PoisonPlantDamageRStr));
  Log.FArmyIcon := 1;
  Log.FArmyView.Setup(ArmyHS.FArmy, $FF);
  Units := ArmyHS.FArmy;
  for I := 0 to Units.Count - 1 do
  begin
    U := Units.GetUnit(I);
    U.AddRef;
    if not (dtPoison in U.GetImmunityTypes) and not U.GetAbilityEnabled(1) then
    begin
      Damage := U.ExecuteDamageRole(4, 3, [dtPoison]);
      if Damage > U.GetHitPoints then Damage := U.GetHitPoints;
      if Damage <> 0 then
      begin
        U.SetHitPoints(U.GetHitPoints - Damage);
        if U.GetHitPoints <> 0 then U.ExecuteDamageEffects([dtPoison]);
        Inc(Count);
      end;
      Log.FDamageValues.Add(Damage);
      Log.FDamageTypes.Add(Ord(dtPoison));
    end
    else
    begin
      Log.FDamageValues.Add(0);
      Log.FDamageTypes.Add(Ord(dtNone));
    end;
    U.Release;
  end;
  Log.ValidateGameOver;
  if Count <> 0 then
    DistributeLocationEventLog(Log, Log.FPlayer, GetXhx, GetYhx, GetLhx, True);
  ArmyHS.FArmy.Validate;
  Log.Release;
end;

procedure TPoisonPlant.ArmyPlaced(ArmyHS: TArmyHS);
begin
  if PoisonPlantActive and not (msEditting in AoWHSMap.Status) then
    TriggerArmyDamage(ArmyHS);
end;

procedure TPoisonPlant.RestoreTerrain; { Unmatched: tried identity assignment to Self; Pointer identity assignment to Self; TObject cast destructor receiver (5 variants total). }
var
  MapF: TMapField;
  OriginalOverlay: Shortint;
begin
  MapF := TMapField(Owner);
  OriginalOverlay := FOriginalOverlay;
  Destroy;
  if OriginalOverlay > 0 then
    AoWHSMap.PlaceTerrain(MapF.Xhx, MapF.Yhx, MapF.Lhx, MapF.TerrainType, OriginalOverlay);
end;

procedure TPoisonPlant.NewTurn(Player: Shortint);
var
  ArmyHS: TArmyHS;
begin
  if PoisonPlantActive then
  begin
    ArmyHS := TArmyHS(Owner.FindOwnedChild($20217));
    if (ArmyHS <> nil) and (Player = ArmyHS.FArmy.FPlayer) then
      TriggerArmyDamage(ArmyHS);
  end;
  if (Player = FCasterPlayer) and (FDaysRemaining > 0) then
  begin
    Dec(FDaysRemaining);
    if FDaysRemaining = 0 then RestoreTerrain;
  end;
end;

procedure TPoisonPlant.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function TPoisonPlant.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if (FResource.TerrainList.GetTerrain(Info.HN) >= 0) and PoisonPlantActive then
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else Result := 0
  else Result := 1;
end;


procedure TPoisonPlant.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1142 then
  begin
    if FResource.TerrainList.GetTerrain(Msg.HN) >= 0 then
      ArmyPlaced(TArmyHS(Msg.Param[0]));
  end
  else if Msg.MsgID = $1120 then
  begin
    if (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) and
      not (dtPoison in TArmyHS(Msg.Param[0]).FArmy.ImmunityTypes($FF)) and
      PoisonPlantActive then Msg.Result := 1;
  end
  else if Msg.MsgID = $1132 then
  begin
    { Original excludes player zero from early restoration. }
    if (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) and
      (FCasterPlayer > 0) and (FDaysRemaining > 0) then RestoreTerrain;
  end;
end;

function TPoisonPlant.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), GetXhx, GetYhx);
end;

procedure TPoisonPlant.RemoveFromMap;
var
  Level: TMapLevel;
begin
  Level := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(Level, FXhx, FYhx);
end;

procedure TPoisonPlant.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure TPoisonPlant.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if not (ppsSummoning in FPlantStatus) then
    inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TPoisonPlant.ShowSummonAnimation(Animation: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  MapF: TMapField;
begin
  MapF := TMapField(AoWHSMap.MapContainer.GetField(Animation.GetXhx, Animation.GetYhx, Animation.GetLhx));
  if (Self = MapF.FindOwnedChild($2039E)) and (Ord(AoWEngine.FAnimationDetail) <> 0) and
    (Animation.FFrameCounter = 0) then
    if (AoWHSMap.FSeatedPlayer = Animation.FTag) or
      AoWHSMap.WatchingTerrain(GetXhx, GetYhx, GetLhx, 0) then
      AoWHSSet.FSpellControl.GetSpell(12).FCastSounds.Play(0);
end;

procedure TPoisonPlant.NewFrameSummonAnimation(Animation: TAnimation; FrameCounter: Integer);
var
  MapF: TMapField;
begin
  Animation := TAnimation(AoWHSMap.MapContainer.GetField(Animation.GetXhx, Animation.GetYhx, Animation.GetLhx));
  if (Self = TMapField(Animation).FindOwnedChild($2039E)) and (FrameCounter = 9) then
    FPlantStatus := FPlantStatus - [ppsSummoning];
end;

class function TPoisonPlantResource.ResourceEditName: string;
begin
  Result := TranslateRStr(PoisonPlantRStr);
end;

class function TPoisonPlantResource.ClassID: Integer;
begin
  Result := $2039F;
end;

function TPoisonPlantResource.ResourceUserClassID: Integer;
begin
  Result := $2039E;
end;

class function TPoisonPlantSpellTE.ClassID: Integer;
begin
  Result := $21305;
end;

procedure TPoisonPlantSpellTE.CreatePoisonPlant(Source: TAbstractUnit); { Unmatched: tried reinterpret walk record in with scope. }
var
  Level: TMapLevel;
  Walk: THNWalkData;
  Resource: TPoisonPlantResource;
  MapF: TAoWMapField;
  Plant: TPoisonPlant;
  Animation: TImageSequenceAnimation;
  Twinkle: TTwinkleAnimation;
begin
  with Walk do
  begin
    Level := AoWHSMap.MapContainer.MapLevels[FLocation.L];
    InitHNWalk(Walk, FLocation.X, FLocation.Y, 0);
    Resource := TPoisonPlantResource(AoWHSSet.MapObjectResourceList.FindChild($2039F));
    while Radius <= 1 do
    begin
      if (X >= 0) and (Y >= 0) and (X < Level.Width) and
        (Y < Level.Height) then
      begin
        MapF := TAoWMapField(Level.GetField(X, Y));
        if TGlobalTargetSpell(AoWHSSet.FSpellControl.GetSpell(12)).ValidTargetMapF(MapF) and
          (MapF.GetArmyHS = nil) then
        begin
          MapF.RestoreTerrain;
          Plant := TPoisonPlant(Resource.CreateResourceUser);
          Plant.FDaysRemaining := 3 + (AoWHSMap.Random(11) - 5) div 5;
          Plant.FCasterPlayer := Source.FPlayer;
          Plant.FOriginalOverlay := MapF.OverlayType;
          AoWHSMap.ClearTerrain(X, Y, FLocation.L, 0, -1);
          if AoWHSMap.PlaceHX(Plant, X, Y, FLocation.L) then
          begin
            Plant.FPlantStatus := [ppsSummoning];
            Animation := TImageSequenceAnimation.Create(nil);
            Animation.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(12).FCastImages.ImageSequences[0]);
            Animation.FOnShow := Plant.ShowSummonAnimation;
            Animation.FOnNewFrame := Plant.NewFrameSummonAnimation;
            Animation.FFrameCounter := -AoWHSMap.Random(15);
            Animation.FAnimationLevel := 27;
            AoWHSMap.PlaceHX(Animation, X, Y, FLocation.L);
            Twinkle := TTwinkleAnimation.Create(nil);
            Twinkle.Setup(AoWHSSet.FSpellControl.GetSpell(2).FCastImages.ImageSequences[0], [],
              2, 6, Abs(Animation.FFrameCounter + 5), Abs(Animation.FFrameCounter + 5) div 2);
            AoWHSMap.PlaceHX(Twinkle, X, Y, FLocation.L);
          end
          else Plant.Free;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end;
end;

function TPoisonPlantSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  CreatePoisonPlant(A1);
  AoWHSMap.ValidateTerrainObservation(A1.FPlayer, FLocation.X,
    FLocation.Y, FLocation.L, 1);
  AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
  Result := False;
end;

constructor TPoisonPlantSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(PoisonPlantsRStr);
  FSpellID := 12;
  FBaseManaCost := 5;
  FSpellLevel := 2;
  FMagicSphere := msEarth;
  FAboveGroundOnly := False;
end;

function TPoisonPlantSpell.ValidTargetMapF(A1: TMapField): Boolean;
begin
  Result := inherited ValidTargetMapF(A1) and (A1.TerrainType in [1..5, 12]);
  { Original precedence also accepts these overlays without the terrain test. }
  Result := Result and (A1.OverlayType = -1) or (A1.OverlayType in [1..4, 9]);
  Result := Result and (A1.FindNoneTransparentHS(TStructure) = nil) and (TAoWMapField(A1).GetArmyHS = nil);
end;

function TPoisonPlantSpell.ValidTargetSelectionMapF(A1: TMapField): Boolean;
var
  ArmyHS: TArmyHS;
begin
  Result := inherited ValidTargetSelectionMapF(A1) and (A1.TerrainType in [1..5, 12]);
  { Original precedence also accepts these overlays without the terrain test. }
  Result := Result and (A1.OverlayType = -1) or (A1.OverlayType in [1..4, 9]);
  Result := Result and (A1.FindNoneTransparentHS(TStructure) = nil) and (TAoWMapField(A1).GetArmyHS = nil);
  if Result then
  begin
    ArmyHS := TAoWMapField(A1).GetArmyHS;
    if ArmyHS <> nil then Result := not ArmyHS.VisibleForSeatedPlayer;
  end;
end;

procedure TPoisonPlantSpell.SetupTargetSelection(A1: TAbstractUnit; A2: TTargetSelectionControl);
var
  I: Integer;
begin
  inherited SetupTargetSelection(A1, A2);
  A2.FHNs.Clear;
  for I := 0 to RadToHN(2) - 1 do A2.FHNs.Add(0);
end;

function TPoisonPlantSpell.TargetSelected(A1: TAbstractUnit; A2: Integer; A3: Integer; A4: Integer): Boolean;
var
  Event: TPoisonPlantSpellTE;
begin
  Event := TPoisonPlantSpellTE.Create(nil);
  Event.Initialize(FSpellID, A1.FPlayer, A1.FUnitID, FBaseManaCost);
  Event.SetLocation(A2, A3, A4);
  AoWHSMap.FTokenManager.GetTokenControl(A1.FPlayer).AddEvent(Event);
  Event.Release;
  Result := True;
end;

procedure RegisterPoisonPlant(AEngine: TAoWEngine);
begin
  AEngine.RegisterEClasses([TPoisonPlant, TPoisonPlantResource, TPoisonPlantSpellTE]);
  AEngine.FGameSet.FSpellControl.RegisterSpell(TPoisonPlantSpell.Create(nil));
end;

procedure UnRegisterPoisonPlant(AEngine: TAoWEngine);
begin
  AEngine.UnRegisterEClasses([TPoisonPlant, TPoisonPlantResource, TPoisonPlantSpellTE]);
  AEngine.FGameSet.FSpellControl.UnregisterSpellID(12);
end;

initialization
finalization

end.
