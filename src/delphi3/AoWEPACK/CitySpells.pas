unit CitySpells;

{ City-targeted spells recovered from AoWEPACK.dpl.
  Layouts and VMT order follow the original. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, City, Animation, EventLog;

type
  TCityTargetSpellTE = class;
  TCityTargetSpell = class;
  TTownGateTE = class;
  TTownGate = class;
  TCityEnchantmentSpellTE = class;
  TCityEnchantmentSpell = class;
  TFountainOfLife = class;
  TGoldRush = class;
  TAntiMagicShell = class;
  TWarmonger = class;
  TTownQuake = class;
  TAnarchy = class;
  TAnimateRuins = class;

  TCityTargetMode = set of (ctmOwn, ctmEnemy, ctmSkipSource, ctmRazed); { ot=1 }
  TCityEnchantmentCastSpellSituation = set of (ccsLeaderInCity, ccs4HexCity, ccs3HexCity); { ot=1 }

  { TCityTargetSpellTE (instance size 40, VMT 557AF390):
    $20 packed target coordinates; $24 target owner. }
  TCityTargetSpellTE = class(TSpellTE)
  public
    FTargetLocation: TXYL; { $20 }
    FTargetPlayer: Shortint; { $24 }
    F_CityTargetSpellTE_25: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    procedure SetLocation(X, Y, L: Shortint);
    function GetSelectedCity: TCity;
  end;

  { TCityTargetSpell (instance size 60, VMT 557AF4C8):
    $34 source unit ID; $38 city target modes. }
  TCityTargetSpell = class(TSpell)
  public
    FSourceID: Integer; { $34 }
    FCityTargetMode: TCityTargetMode; { $38 }
    F_CityTargetSpell_39: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure OnTargetSelectionChange(Sender: TObject); virtual; { +09C }
    procedure PlayDefaultCityEffects(Source: TAbstractUnit; TargetCity: TCity); virtual;  { +0A0 }
    procedure SetupTargetSelection(Source: TAbstractUnit; TargetSelection: TTargetSelectionControl); virtual;  { +0A4 }
    function TargetSelected(Source: TAbstractUnit; X, Y, L: Integer): Boolean; virtual; { +0A8 }
    function ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean; virtual;  { +0AC }
    function CreateTE: TCityTargetSpellTE; virtual;  { +0B0 }
    function SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean; virtual;  { +0B4 }
    procedure ValidateTarget(TargetSelection: TTargetSelectionControl; X, Y, L: Shortint; var Valid: Boolean);
  end;

  { TTownGateTE (instance size 48, VMT 557AF604): $28 army ID; $2C destination coordinates. }
  TTownGateTE = class(TCityTargetSpellTE)
  public
    FArmyID: TArmyID; { $28 }
    FTeleportLocation: TXYL; { $2C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
  end;

  { TTownGate (instance size 60, VMT 557AF6D4) }
  TTownGate = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    procedure SetupTargetSelection(Source: TAbstractUnit; TargetSelection: TTargetSelectionControl); override;
    function CreateTE: TCityTargetSpellTE; override;
    function SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean; override;
    function ValidTeleportLocation(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint): Boolean;
  end;

  { TCityEnchantmentSpellTE (instance size 40, VMT 557AF800) }
  TCityEnchantmentSpellTE = class(TCityTargetSpellTE)
  public
    class function ClassID: Integer; override;
  end;

  { TCityEnchantmentSpell (instance size 80, VMT 557AF958): $3C enchantment ID,
    $40 enchantment setting, $44 AI priority, $48 AI budget, $4C AI cast situations. }
  TCityEnchantmentSpell = class(TCityTargetSpell)
  public
    FEnchantmentID: TCityEnchantmentID; { $3C }
    F_CityEnchantmentSpell_3D: array[0..2] of Byte;
    FEnchantmentSpellID: Integer; { $40 }
    FAIPriority: Integer; { $44 }
    FAIBudget: Integer; { $48 }
    FAICastSituation: TCityEnchantmentCastSpellSituation; { $4C }
    F_CityEnchantmentSpell_4D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean; override;
    function CreateTE: TCityTargetSpellTE; override;
    function SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean; override;
  end;

  { TFountainOfLife (instance size 80, VMT 557AFA9C) }
  TFountainOfLife = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    procedure ShowFountain(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc);
  end;

  { TGoldRush (instance size 80, VMT 557AFBD0) }
  TGoldRush = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TAntiMagicShell (instance size 80, VMT 557AFCFC) }
  TAntiMagicShell = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCityEffects(Source: TAbstractUnit; TargetCity: TCity); override;
  end;

  { TWarmonger (instance size 80, VMT 557AFE30) }
  TWarmonger = class(TCityEnchantmentSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTownQuake (instance size 60, VMT 557AFF5C) }
  TTownQuake = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean; override;
    procedure TriggerArmyDamage(Source: TAbstractUnit; Army: TArmyHS);
  end;

  { TAnarchy (instance size 60, VMT 557B0088) }
  TAnarchy = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean; override;
    procedure ShowAnimation(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc);
  end;

  { TAnimateRuins (instance size 60, VMT 557B01B4) }
  TAnimateRuins = class(TCityTargetSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; override;
    function ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean; override;
    procedure ShowAnimation(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc);
  end;

procedure RegisterCitySpells(A1: TAoWEngine);
procedure UnregisterCitySpells(A1: TAoWEngine);

implementation

class function TCityTargetSpellTE.ClassID: Integer;
begin
  Result := $2130D;
end;

procedure TCityTargetSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTargetLocation.XYL, $14);
  Stream.rwByte(Byte(FTargetPlayer), $15);
end;

procedure TCityTargetSpellTE.SetLocation(X, Y, L: Shortint);
begin
  FTargetLocation.X := X;
  FTargetLocation.Y := Y;
  FTargetLocation.L := L;
end;

function TCityTargetSpellTE.Validate(A1: THero): Boolean;
var
  TargetCity: TCity;
begin
  Result := inherited Validate(A1);
  if Result then
  begin
    TargetCity := GetSelectedCity;
    if (TargetCity = nil) or (TargetCity.FPlayer <> FTargetPlayer) then
      Result := False
    else
      Result := True;
  end;
end;

function TCityTargetSpellTE.GetSelectedCity: TCity;
begin
  Result := TCity(AoWHSMap.MapContainer.GetFieldXYL(FTargetLocation.XYL).FindNoneTransparentHS(TCity));
end;

constructor TCityTargetSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
end;

procedure TCityTargetSpell.PlayDefaultCityEffects(Source: TAbstractUnit; TargetCity: TCity); { Near miss: register or temporary allocation differs after three variants. }
var
  Level: TMapLevel;
  A: TImageSequenceAnimation;
  Walk: THNWalkData;
  PlaySound: Boolean;
begin
  PlaySound := False;
  Level := AoWHSMap.MapContainer.GetMapLevel(TargetCity.GetLhx);
  InitHNWalk(Walk, TargetCity.GetXhx, TargetCity.GetYhx, 0);
  while Walk.HN < TStructureResource(TargetCity.Resource).TerrainList.Count do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < Level.Width) and (Walk.Y < Level.Height) and
      TStructureResource(TargetCity.Resource).TerrainList.Used[Walk.HN] then
      if (Source.FPlayer = AoWHSMap.FSeatedPlayer) or
        AoWHSMap.TerrainVisible(Walk.X, Walk.Y, TargetCity.GetLhx, 0) { Original passes the city layer before the radius. } then
      begin
        A := TImageSequenceAnimation.Create(nil);
        A.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[0]);
        A.FFrameCounter := Random(5);
        A.FAnimationLevel := 27;
        AoWHSMap.PlaceHX(A, Walk.X, Walk.Y, TargetCity.GetLhx);
        if (Source.FPlayer = AoWHSMap.FSeatedPlayer) or
          AoWHSMap.WatchingTerrain(Walk.X, Walk.Y, TargetCity.GetLhx, 0) then
          PlaySound := True;
      end;
    WalkToNextHN(Walk);
  end;
  if PlaySound then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
end;

function TCityTargetSpell.ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean;
var
  X, Y, L: Shortint; Found: TCity;
begin
  Result := ((ctmOwn in FCityTargetMode) and (TargetCity.FPlayer = Source.FPlayer)) or
    ((ctmEnemy in FCityTargetMode) and (TargetCity.FPlayer <> Source.FPlayer));
  Result := Result and (not TargetCity.GetRazed or (ctmRazed in FCityTargetMode));
  if Result and (ctmSkipSource in FCityTargetMode) then
  begin
    Source.GetLocation(X, Y, L);
    Found := TCity(AoWHSMap.MapContainer.GetField(X, Y, L).FindNoneTransparentHS(TCity)); Result := TargetCity <> Found;
  end;
end;

procedure TCityTargetSpell.ValidateTarget(TargetSelection: TTargetSelectionControl; X, Y, L: Shortint; var Valid: Boolean);
var
  Source: TAbstractUnit;
  Level: TMapLevel;
  Field: TAoWMapField;
  TargetCity: TCity;
begin
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceID);
  if (Source <> nil) and (X >= 0) and (Y >= 0) and
    (X < Level.Width) and (Y < Level.Height) then
  begin
    Field := TAoWMapField(Level.GetField(X, Y));
    Valid := not AoWHSMap.FExplorationEnabled or Field.GetExplored(Source.FPlayer);
    if Valid then
    begin
      TargetCity := TCity(Field.FindNoneTransparentHS(TCity));
      if TargetCity <> nil then
        Valid := ValidTargetCity(Source, TargetCity)
      else
        Valid := False;
    end;
  end
  else Valid := False;
end;

procedure TCityTargetSpell.OnTargetSelectionChange(Sender: TObject);
var
  TargetSelection: TTargetSelectionControl;
  Source: TAbstractUnit;
  Valid: Boolean;
begin
  TargetSelection := TTargetSelectionControl(Sender);
  Source := AoWHSMap.FUnitControl.FindUnit(FSourceID);
  if Source <> nil then
    case TargetSelection.FChange of
      tscDeactivated:
        begin
          TargetSelection.FOnChange.Remove(OnTargetSelectionChange);
          TargetSelection.Deactivate;
        end;
      tscSelected:
        begin
          ValidateTarget(TargetSelection, TargetSelection.FTargetX,
            TargetSelection.FTargetY, TargetSelection.FTargetL, Valid);
          if Valid then
            if TargetSelected(Source, TargetSelection.FTargetX,
              TargetSelection.FTargetY, TargetSelection.FTargetL) then
            begin
              TargetSelection.FOnChange.Remove(OnTargetSelectionChange);
              TargetSelection.Deactivate;
            end;
        end;
    end
  else
  begin
    TargetSelection.FOnChange.Remove(OnTargetSelectionChange);
    TargetSelection.Deactivate;
  end;
end;

procedure TCityTargetSpell.SetupTargetSelection(Source: TAbstractUnit; TargetSelection: TTargetSelectionControl);
var
  X, Y, L: Shortint;
begin
  TargetSelection.Initialize(Source);
  TargetSelection.FTargetMode := TargetSelection.FTargetMode + [tmValidateDistance, tmExternalFloater];
  TargetSelection.FText.Text := SysUtils.Format(AoWE.TranslateRStr(SelectTargetCityForXOnMapRStr), [FSpellName]);
  TargetSelection.FTitle := FSpellName;
  TargetSelection.FCancelText := AoWE.TranslateRStr(CancelRStr);
  TargetSelection.FSourceImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[20].GetPreviewImage;
  TargetSelection.FValidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[21].GetPreviewImage;
  TargetSelection.FInvalidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[22].GetPreviewImage;
  Source.GetLocation(X, Y, L);
  TargetSelection.FSourceX := X;
  TargetSelection.FSourceY := Y;
  TargetSelection.FSourceL := L;
  TargetSelection.FRange := 12;
  if TargetSelection.FOnChange.Count > 1 then
    raise Exception.Create('oohps'); { Original rejects two existing listeners. }
  TargetSelection.FOnChange.Add(OnTargetSelectionChange);
  TargetSelection.FOnValidateTarget := ValidateTarget;
end;

function TCityTargetSpell.CreateTE: TCityTargetSpellTE;
begin
  Result := TCityTargetSpellTE.Create(nil);
end;

function TCityTargetSpell.SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean;
begin
  Event.Initialize(FSpellID, Source.FPlayer, Source.FUnitID, FBaseManaCost);
  Event.SetLocation(X, Y, L);
  Event.FTargetPlayer := Event.GetSelectedCity.FPlayer;
  Result := True;
end;

function TCityTargetSpell.TargetSelected(Source: TAbstractUnit; X, Y, L: Integer): Boolean;
var
  Event: TCityTargetSpellTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    Event := CreateTE;
    if SetupTE(Event, Source, X, Y, L) then
    begin
      AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(Event);
      Result := True;
    end
    else Result := False;
    Event.Release;
  end
  else Result := False;
end;

function TCityTargetSpell.Activate(A1: TAbstractUnit): Boolean;
var
  Reason: string;
begin
  if CanActivate(A1, Reason) then
  begin
    FSourceID := A1.FUnitID;
    SetupTargetSelection(A1, AoWHSMap.FTargetSelection);
    AoWHSMap.FTargetSelection.Activate;
    Result := True;
  end
  else Result := False;
end;

destructor TTownGateTE.Destroy;
begin
  FArmyID.Free;
  inherited Destroy;
end;

class function TTownGateTE.ClassID: Integer;
begin Result := $2130E; end;

procedure TTownGateTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTeleportLocation.XYL, $1E);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, $1F);
end;

function TTownGateTE.Validate(A1: THero): Boolean;
var
  Selection: Byte;
  Army: TArmyHS;
begin
  Result := inherited Validate(A1) and FArmyID.Valid;
  if Result then
  begin
    FArmyID.RetrieveArmy(Army, Selection);
    Result := TTownGate(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).ValidTeleportLocation(
      Army, Selection, FTeleportLocation.X, FTeleportLocation.Y, FTeleportLocation.L);
  end;
end;

constructor TTownGate.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(TownGateRStr);
  FSpellID := $26;
  FCityTargetMode := [ctmOwn, ctmSkipSource];
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msCosmos;
end;

function TTownGate.ValidTeleportLocation(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint): Boolean;
var
  Field: TAoWMapField;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L));
  if (Field.GetPlayer <> -1) and (Field.GetPlayer <> Army.FArmy.FPlayer) then
    Result := False
  else Result := True; if Result then Result := Army.FArmy.ValidTerrainEx(Selection, Field.TerrainType, Field.OverlayType);
  { CanAddUnitSelection returns arOK (zero) when the destination accepts the selection. }
  Result := Result and ((Field.GetArmyHS = nil) or
    (Field.GetArmyHS.FArmy.CanAddUnitSelection(Army.FArmy, Selection) = arOK));
end;

function TTownGate.CreateTE: TCityTargetSpellTE;
begin
  Result := TTownGateTE.Create(nil);
end;

function TTownGate.SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  Army: TArmyHS;
  Selection: Byte;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  Result := inherited SetupTE(Event, Source, X, Y, L);
  if Result then
  begin
    Army := TArmy(Source.Owner).GetArmyHS;
    if (Army.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) and
      (AoWHSMap.FSelectedArmy.GetArmyHS = Army) then
      Selection := AoWHSMap.FSelectedArmy.GetSelection
    else Selection := $FF;
    InitHNWalk(Walk, X, Y, 0);
    Result := False;
    Level := AoWHSMap.MapContainer.GetMapLevel(L);
    while (Walk.Radius < 4) and not Result do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and
        (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        Result := ValidTeleportLocation(Army, Selection, Walk.X, Walk.Y, L);
      if not Result then WalkToNextHN(Walk);
    end;
    if Result then
    begin
      TTownGateTE(Event).FArmyID := Army.FArmy.CreateID(Selection);
      TTownGateTE(Event).FTeleportLocation := PackXYL(Walk.X, Walk.Y, L);
      Result := True;
    end
    else Result := False;
  end;
end;

function TTownGate.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  ShowSource, ShowTarget: Boolean;
  Selection: Byte;
  Army: TArmyHS;
  Field: TAoWMapField;
  NewArmy: TArmyHS;
  X, Y, L: Shortint;
  A: TImageSequenceAnimation;
begin
  A2.GetLocation(X, Y, L);
  TTownGateTE(A1).FArmyID.RetrieveArmy(Army, Selection);
  Field := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(TTownGateTE(A1).FTeleportLocation.XYL));
  Army.FArmy.ResetDestinationPos;
  if AoWHSMap.FSelectedArmy.GetArmyHS = Army then
    AoWHSMap.FSelectedArmy.Select(Army);
  if Army.FArmy.ValidateSelection(Selection) <> Army.FArmy.ValidateSelection($FF) then
  begin
    NewArmy := TArmyHS.Create(nil);
    NewArmy.FArmy.SetPlayer(Army.FArmy.FPlayer);
    NewArmy.FArmy.AddUnitSelection(Army.FArmy, Selection);
    AoWHSMap.PlaceHX(NewArmy, TTownGateTE(A1).FTeleportLocation.X,
      TTownGateTE(A1).FTeleportLocation.Y, TTownGateTE(A1).FTeleportLocation.L);
  end
  else if Field.GetArmyHS <> nil then
    Field.GetArmyHS.FArmy.AddUnitSelection(Army.FArmy, Selection)
  else Army.MoveTo(Field, 0);
  ShowSource := (AoWHSMap.FSeatedPlayer = A2.FPlayer) or AoWHSMap.Visible(X, Y, L, 0);
  ShowTarget := (AoWHSMap.FSeatedPlayer = A2.FPlayer) or AoWHSMap.Visible(Field.Xhx, Field.Yhx, Field.Lhx, 0);
  if ShowSource then
    if AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[0] <> nil then
    begin
      A := TImageSequenceAnimation.Create(nil);
      A.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[0]);
      AoWHSMap.PlaceHX(A, X, Y, L);
    end;
  if ShowTarget then
    if AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[0] <> nil then
    begin
      A := TImageSequenceAnimation.Create(nil);
      A.SetImageSequence(AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[0]);
      AoWHSMap.PlaceHX(A, Field.Xhx, Field.Yhx, Field.Lhx);
    end;
  if AoWHSMap.FSeatedPlayer = A2.FPlayer then
    AoWHSMap.CenterViewTo(Field.Xhx, Field.Yhx, Field.Lhx)
  else if not AoWHSMap.ValidateObservation(A2.FPlayer, Field.Xhx, Field.Yhx, Field.Lhx, 0) then
    AoWHSMap.ValidateObservation(A2.FPlayer, X, Y, L, 0);
  if (AoWHSMap.FSeatedPlayer = A2.FPlayer) or AoWHSMap.Watching(X, Y, L, 0) or
    AoWHSMap.Watching(Field.Xhx, Field.Yhx, Field.Lhx, 0) then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.Play(0);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

function TTownGate.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin
  Result := inherited CanActivate(A1, A2);
end;

procedure TTownGate.SetupTargetSelection(Source: TAbstractUnit; TargetSelection: TTargetSelectionControl);
begin
  inherited SetupTargetSelection(Source, TargetSelection);
  TargetSelection.FTargetMode := TargetSelection.FTargetMode - [tmFixedLevel, tmValidateDistance];
end;

class function TCityEnchantmentSpellTE.ClassID: Integer;
begin Result := $202ED; end;

constructor TCityEnchantmentSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAIPriority := -1;
end;

function TCityEnchantmentSpell.CreateTE: TCityTargetSpellTE;
begin
  Result := TCityEnchantmentSpellTE.Create(nil);
end;

function TCityEnchantmentSpell.SetupTE(Event: TCityTargetSpellTE; Source: TAbstractUnit; X, Y, L: Integer): Boolean;
begin
  Result := inherited SetupTE(Event, Source, X, Y, L);
end;

function TCityEnchantmentSpell.ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean;
begin
  Result := inherited ValidTargetCity(Source, TargetCity);
  if Result then Result := not (FEnchantmentID in TargetCity.FEnchantments);
end;

function TCityEnchantmentSpell.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  TargetCity: TCity;
  Enchantment: TCityEnchantment;
begin
  TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
  Enchantment := TCityEnchantment.Create(nil);
  Enchantment.FEnchantmentID := FEnchantmentID;
  Enchantment.FEnchantmentManaUpkeep := FManaUpkeep;
  Enchantment.FEnchantmentLocation.XYL := TMapField(TargetCity.Owner).GetXYL;
  Enchantment.FDispelMana := FEnchantmentSpellID;
  Enchantment.FPlayerIndex := A2.FPlayer;
  TargetCity.ActivateEnchantment(Enchantment);
  PlayDefaultCityEffects(A1.GetSource, TargetCity);
  CastingDone(A2, A1.FEventMana);
  Result := False;
end;

procedure TCityEnchantmentSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
var
  Valid: Boolean;
  Action: TAICastSpellAction;
  Reason: string;
  X, Y, L: Shortint;
  TargetCity: TCity;
begin
  if FAIPriority <> -1 then
  begin
    A1.GetLocation(X, Y, L);
    TargetCity := TCity(AoWHSMap.MapContainer.GetField(X, Y, L).FindNoneTransparentHS(TCity));
    Valid := (TargetCity <> nil) and AIRequestCastSpellExpense(A1,
      FBaseManaCost, FManaUpkeep, TargetCity.AICityEnchantmentUpkeepPriority(FEnchantmentID)); { Original uses mana upkeep for mana and city priority for upkeep. }
    Valid := Valid and ValidTargetCity(A1, TargetCity);
    Valid := Valid and THero(A1).CanCastSpell(FSpellID, Reason);
    if Valid then
      if ((ccsLeaderInCity in FAICastSituation) and (A1 is TLeader)) or
        ((ccs4HexCity in FAICastSituation) and (TargetCity.GetSize = 4)) or
        ((ccs3HexCity in FAICastSituation) and (TargetCity.GetSize = 3)) then
      begin
        Action := CreateCastSpellAction;
        SetupCastSpellAction(A1, Action);
        Action.FPriority := FAIPriority;
        Action.SetOwner(A2);
      end;
  end;
end;

function TCityEnchantmentSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  X, Y, L: Shortint;
  TargetCity: TCity;
begin
  A1.GetLocation(X, Y, L);
  TargetCity := TCity(AoWHSMap.MapContainer.GetField(X, Y, L).FindNoneTransparentHS(TCity));
  if (TargetCity <> nil) and ValidTargetCity(A1, TargetCity) and
    THero(A1).CanCastSpell(FSpellID, Reason) then
  begin
    AICastSpellExpenseMade(A1, FBaseManaCost, FManaUpkeep, FAIBudget);
    with THero(A1) do
      if CanCastSpellInstantly(FSpellID, FBaseManaCost, Reason) then
        Result := TargetSelected(A1, X, Y, L)
      else
        if FCastingSpellID <> FSpellID then
        begin
          ExecuteStartCasting(FSpellID);
          Result := True;
        end
        else Result := True;
  end
  else Result := False;
end;

constructor TFountainOfLife.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(FountainOfLifeRStr);
  FSpellID := $34;
  FCityTargetMode := [ctmOwn];
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msWater;
  FEnchantmentID := ceiFountainOfLife;
  FCastDuration := 20;
  FAIPriority := 500;
  FAICastSituation := [ccsLeaderInCity];
  FAIBudget := 600;
  FEnchantmentSpellID := 50;
end;

procedure TFountainOfLife.ShowFountain(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc); { Near miss: register or temporary allocation differs after three variants. }
var
  I, DX, VY, Offset, CY, CX, VX, T, DY: Integer;
begin
  HXtoHP(Animation.FTag and $FF, Animation.FTag shr 8, CX, CY);
  CX := CX + 10 - X;
  CY := CY - Y + 10;
  RandSeed := 0; { Original resets the process-wide random seed for every draw. }
  for I := 0 to 100 do
  begin
    VX := Random(100) - 50;
    VY := Random(5) + 7;
    Offset := Round(VX * 0.1);
    T := Random(30);
    if (T < Animation.FFrameCounter) and (Animation.FFrameCounter - T < 90) then
    begin
      T := (Animation.FFrameCounter - T) mod 30;
      DX := Round(T * VX / 30);
      DY := VY * T - Round(T * 0.25 * T);
      if T > 0 then
        AoWHSSet.FSpellControl.GetSpell($34).FCastImages.Show(0, CX + DX + Offset, CY - DY, 0, SD);
    end;
  end;
  if Animation.FFrameCounter = 120 then Animation.Free;
end;

function TFountainOfLife.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  TargetCity: TCity;
  A: TAnimation;
begin
  Result := inherited ExecuteTE(A1, A2, A3);
  if A3 = 0 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    A := TAnimation.Create(nil);
    A.FAnimationLevel := 27;
    A.FOnShow := ShowFountain;
    A.FAnimationMap := AoWHSMap;
    A.FTag := TargetCity.GetXhx or (TargetCity.GetYhx shl 8);
    A.Activate;
  end;
end;

constructor TGoldRush.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(GoldRushRStr);
  FSpellID := $35;
  FCityTargetMode := [ctmOwn];
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msWater;
  FEnchantmentID := ceiGoldRush;
  FCastDuration := 20;
  FAIPriority := 500;
  FAICastSituation := [ccs4HexCity];
  FAIBudget := 600;
  FEnchantmentSpellID := 25;
end;

constructor TAntiMagicShell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(AntiMagicShellRStr);
  FSpellID := $36;
  FCityTargetMode := [ctmOwn];
  FBaseManaCost := 1;
  FSpellLevel := 4;
  FMagicSphere := msCosmos;
  FEnchantmentID := ceiAntiMagicShell;
  FCastDuration := 40;
  FAIPriority := 500;
  FAICastSituation := [ccsLeaderInCity];
  FEnchantmentSpellID := 100;
end;

procedure TAntiMagicShell.PlayDefaultCityEffects(Source: TAbstractUnit; TargetCity: TCity);
begin
  inherited PlayDefaultCityEffects(Source, TargetCity);
  if (Source.FPlayer = AoWHSMap.FSeatedPlayer) or
    AoWHSMap.WatchingTerrain(TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx, 1) then
    AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastSounds.PlayEx(1, -1, False, 30, spCenter, nil);
end;

constructor TWarmonger.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(WarmongerRStr);
  FSpellID := $3A;
  FCityTargetMode := [ctmOwn];
  FEnchantmentID := ceiWarmonger;
  FCastDuration := 30;
  FAIPriority := 600;
  FAICastSituation := [ccs4HexCity, ccs3HexCity];
  FEnchantmentSpellID := 50;
end;

constructor TTownQuake.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(TownQuakeRStr);
  FSpellID := $47;
  FCityTargetMode := [ctmEnemy];

end;

procedure TTownQuake.TriggerArmyDamage(Source: TAbstractUnit; Army: TArmyHS);
var
  Log: TArmyEventLog;
  Damaged: Boolean;
  I, Damage: Integer;
  AUnit: TAbstractUnit;
begin
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := AoWE.TranslateRStr(TownQuakeDamageRStr);
  Log.FPlayer := Source.FPlayer;
  Log.FArmyMessages.Add(AoWE.TranslateRStr(TownQuakeRStr));
  Log.FArmyIcon := 2;
  Log.FArmyView.Setup(Army.FArmy, $FF);
  Army.FArmy.BeginUpdate;
  Damaged := False;
  for I := 0 to Army.FArmy.Count - 1 do
  begin
    AUnit := Army.FArmy.GetUnit(I);
    Damage := AUnit.ExecuteDamageRole(7, 5, [dtPhysical]);
    if Damage > AUnit.GetHitPoints then Damage := AUnit.GetHitPoints;
    if Damage > 0 then
    begin
      AUnit.SetHitPoints(AUnit.GetHitPoints - Damage);
      Damaged := True;
    end;
    Log.FDamageValues.Add(Damage);
    Log.FDamageTypes.Add(7);
  end;
  if Damaged then
  begin
    Log.ValidateGameOver;
    DistributeLocationEventLog(Log, Army.FArmy.FPlayer,
      Army.GetXhx, Army.GetYhx, Army.GetLhx, True);
  end;
  Log.Release;
  Army.FArmy.Validate;
  Army.FArmy.EndUpdate;
end;

function TTownQuake.ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean;
begin
  Result := inherited ValidTargetCity(Source, TargetCity);
  if not Result or (ceiAntiMagicShell in TargetCity.FEnchantments) then
    Result := False
  else Result := True;
end;

function TTownQuake.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  TargetCity: TCity;
  Armies: TArmyHSList;
  I: Integer;
begin
  if A3 = 0 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    PlayDefaultCityEffects(A2, TargetCity);
    TargetCity.StartTownQuake;
    TargetCity.ValidateObservation(A2.FPlayer);
    Result := True;
  end
  else if A3 = 50 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    TargetCity.StopTownQuake;
    Armies := TArmyHSList.Create(nil);
    if AoWHSMap.Random(10) < 7 then TargetCity.SetWallType(0);
    TargetCity.ListArmies(Armies);
    for I := 0 to Armies.Count - 1 do TriggerArmyDamage(A2, Armies.GetArmyHS(I));
    Armies.Free;
    CastingDone(A2, A1.FEventMana);
    Result := False;
  end
  else Result := True;
end;

constructor TAnarchy.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(AnarchyRStr);
  FSpellID := $48;
  FCityTargetMode := [ctmEnemy];

end;

function TAnarchy.ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean;
begin
  Result := inherited ValidTargetCity(Source, TargetCity);
  if not Result or (TargetCity.FPlayer = 0) or
    (ceiAntiMagicShell in TargetCity.FEnchantments) then
    Result := False
  else Result := True;
end;

procedure TAnarchy.ShowAnimation(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc); { Near miss: animation cast adds saved registers after three variants. }
begin
  with TImageSequenceAnimation(Animation) do
    if (FImageSequence.GetUnloopedFrameIndex(FFrameCounter) = 0) and
      (Ord(AoWEngine.FAnimationDetail) <> 0) then
      Sound.PlaySample(ExplosionSFX[Random(2)]);
end;

function TAnarchy.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  TargetCity: TCity;
  Log: TLocationTextEventLog;
  A: TImageSequenceAnimation;
begin
  if A3 = 0 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := A2.FPlayer;
    Log.FText := SysUtils.Format(AoWE.TranslateRStr(XCastRStr), [FSpellName]);
    Log.SetLocation(TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx);
    AoWHSMap.FPlayers.GetPlayers(TargetCity.FPlayer).FEventLogbook.AddEvent(Log);
    Log.Release;
    PlayDefaultCityEffects(A2, TargetCity);
    TargetCity.ValidateObservation(A2.FPlayer);
    if TargetCity.Resource.ImageSequenceList.ImageSequences[16] <> nil then
    begin
      A := TImageSequenceAnimation.Create(nil);
      A.SetImageSequence(TargetCity.Resource.ImageSequenceList.ImageSequences[16]);
      A.SetXhpOffset(A.FXhpOffset - 16);
      A.SetYhpOffset(A.FYhpOffset - 16);
      A.FOnShow := ShowAnimation;
      A.FLooped := True;
      A.FFrameCount := 120;
      AoWHSMap.PlaceHX(A, TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx);
    end;
    Result := True;
  end
  else if A3 = 50 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    TargetCity.ExecuteAnarchy;
    CastingDone(A2, A1.FEventMana);
    Result := False;
  end
  else Result := True;
end;

constructor TAnimateRuins.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := AoWE.TranslateRStr(AnimateRuinsRStr);
  FSpellID := $4C;
  FCityTargetMode := [ctmEnemy, ctmRazed];

end;

function TAnimateRuins.ValidTargetCity(Source: TAbstractUnit; TargetCity: TCity): Boolean;
begin
  Result := inherited ValidTargetCity(Source, TargetCity);
  Result := Result and TargetCity.GetRazed;
end;

procedure TAnimateRuins.ShowAnimation(Animation: TAnimation; X, Y: Integer; const SD: TSurfaceDesc); { Near miss: animation cast adds saved registers after three variants. }
begin
  with TImageSequenceAnimation(Animation) do
    if (FImageSequence.GetUnloopedFrameIndex(FFrameCounter) = 0) and
      (Ord(AoWEngine.FAnimationDetail) <> 0) then
      Sound.PlaySample(ExplosionSFX[Random(2)]);
end;

function TAnimateRuins.ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean;
var
  TargetCity: TCity;
  Log: TLocationTextEventLog;
  A: TImageSequenceAnimation;
  I, Count: Integer;
  AUnit: TUnit;
const
  UndeadUnits: array[0..1] of Integer = (198, 201);
begin
  if A3 = 0 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := A2.FPlayer;
    Log.FText := SysUtils.Format(AoWE.TranslateRStr(XCastRStr), [AoWE.TranslateRStr(AnimateRuinsRStr)]);
    Log.SetLocation(TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx);
    DistributeLocationEventLog(Log, A2.FPlayer, TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx, False);
    Log.Release;
    PlayDefaultCityEffects(A2, TargetCity);
    TargetCity.ValidateObservation(A2.FPlayer);
    if TargetCity.Resource.ImageSequenceList.ImageSequences[20] <> nil then
    begin
      A := TImageSequenceAnimation.Create(nil);
      A.SetImageSequence(TargetCity.Resource.ImageSequenceList.ImageSequences[20]);
      A.SetXhpOffset(A.FXhpOffset - 16);
      A.SetYhpOffset(A.FYhpOffset - 16);
      A.FOnShow := ShowAnimation;
      AoWHSMap.PlaceHX(A, TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx);
    end;
    Result := True;
  end
  else if A3 = 50 then
  begin
    TargetCity := TCityTargetSpellTE(A1).GetSelectedCity;
    TargetCity.SetRace(AoWHSMap.FPlayers.GetPlayers(A2.FPlayer).FPlayerRace);
    TargetCity.SetRazed(False);
    Count := AoWHSMap.Random(TargetCity.GetSize * 2) + 1; for I := 0 to Count do
    begin
      AUnit := TUnit.Create(nil);
      AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(UndeadUnits[AoWHSMap.Random(2)]));
      AUnit.Place(TargetCity.GetXhx, TargetCity.GetYhx, TargetCity.GetLhx, A2.FPlayer, [pmScanArea]);
      AUnit.Release;
    end;
    CastingDone(A2, A1.FEventMana);
    Result := False;
  end
  else Result := True;
end;

procedure RegisterCitySpells(A1: TAoWEngine);
begin
  A1.RegisterEClasses([TCityEnchantmentSpellTE, TCityTargetSpellTE, TTownGateTE]);
  with A1.FGameSet.FSpellControl do
  begin
    RegisterSpell(TAnarchy.Create(nil));
    RegisterSpell(TTownQuake.Create(nil));
    RegisterSpell(TTownGate.Create(nil));
    RegisterSpell(TFountainOfLife.Create(nil));
    RegisterSpell(TGoldRush.Create(nil));
    RegisterSpell(TAntiMagicShell.Create(nil));
    RegisterSpell(TWarmonger.Create(nil));
    RegisterSpell(TAnimateRuins.Create(nil));
  end;
end;

procedure UnregisterCitySpells(A1: TAoWEngine);
begin
  A1.UnregisterEClasses([TCityEnchantmentSpellTE, TCityTargetSpellTE, TTownGateTE]);
  with A1.FGameSet.FSpellControl do
  begin
    UnregisterSpellID($48);
    UnregisterSpellID($26); { Original leaves Town Quake ($47) registered. }
    UnregisterSpellID($34);
    UnregisterSpellID($35);
    UnregisterSpellID($36);
    UnregisterSpellID($3A);
    UnregisterSpellID($4C);
  end;
end;


initialization
finalization

end.
