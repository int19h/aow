unit Storms;

{ Storms, recovered from AoWEPACK.dpl through TFireStorm.
  Later classes retain draft bodies and marked guessed signatures. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TStorm = class;
  TBlastStorm = class;
  TIceStorm = class;
  TDeathStorm = class;
  TDivineStorm = class;
  TLightningStorm = class;
  TFireStorm = class;
  TPestilenceStorm = class;
  TStormSpellTE = class;
  TStormSpell = class;
  TFireStormSpell = class;
  TDivineStormSpell = class;
  TDeathStormSpell = class;
  TIceStormSpell = class;
  TLightningStormSpell = class;
  TPestilenceStormSpell = class;


  { TStorm (instance size 64, VMT 557CB0BC): $3C player, $3D padding. }
  TStorm = class(TAnimation)
  public
    FPlayer: Shortint; { $3C }
    FReserved3D: array[0..2] of Byte;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); virtual; abstract;  { +124 }
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); virtual;
    procedure InitializeStorm(Player, X, Y, L: Shortint); virtual;
    function UpdateStorm: Boolean; virtual;
    procedure FinalizeStorm; virtual;  { +134 }
    class function Name: string; virtual; abstract;
    procedure ShowTargetSelection(Selection: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc);
    function GetBestTarget(Player: Shortint; X, Y, L, Range: Integer; var Target: TXYL; var Info: TStormDamageInfo): Boolean;
  end;

  { TBlastStorm (instance size 68, VMT 557CB260): $40 storm image library. }
  TBlastStorm = class(TStorm)
  public
    FStormImages: TCustomImageLibrary; { $40 }
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    procedure ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint); virtual;  { +13C }
    procedure StormTerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint); virtual;  { +140 }
    function StormFileName: string; virtual;  { +144 }
    function StormType: TStormType; virtual;  { +148 }
  end;

  { TIceStorm (instance size 68, VMT 557CB41C) }
  TIceStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint); override;
    procedure StormTerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint); override;
    function StormFileName: string; override;
    function StormType: TStormType; override;
  end;

  { TDeathStorm (instance size 68, VMT 557CB5D8) }
  TDeathStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint); override;
    function StormFileName: string; override;
    function StormType: TStormType; override;
  end;

  { TDivineStorm (instance size 68, VMT 557CB794) }
  TDivineStorm = class(TBlastStorm)
  public
    class function ClassID: Integer; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint); override;
    function StormFileName: string; override;
    function StormType: TStormType; override;
  end;

  { TLightningStorm (instance size 68, VMT 557CB958): $40 storm image library. }
  TLightningStorm = class(TStorm)
  public
    FStormImages: TCustomImageLibrary; { $40 }
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
  end;

  { TFireStorm (instance size 64, VMT 557CBB0C) }
  TFireStorm = class(TStorm)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
    procedure ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
  end;

  { TPestilenceStorm (instance size 68, VMT 557CBCB8) }
  TPestilenceStorm = class(TStorm)
  public
    F_PestilenceStorm_40: array[0..3] of Byte;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
  end;

  { TStormSpellTE (instance size 40, VMT 557CBE74) }
  TStormSpellTE = class(TSpellTE)
  public
    F_StormSpellTE_20: array[0..3] of Byte;
    F_StormSpellTE_24: Byte;
    F_StormSpellTE_25: Byte;
    F_StormSpellTE_26: Byte;
    F_StormSpellTE_27: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TStormSpell (instance size 60, VMT 557CBF48) }
  TStormSpell = class(TSpell)
  public
    F_StormSpell_34: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure CreateStorm; virtual; abstract;  { +09C draft }
    procedure ExecuteStormSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0A0 draft }
    procedure AICastSpellPriority(A1: Integer); virtual;  { +0A4 draft }
    procedure OnTargetSelectionChange(A1: Integer);  { draft }
  end;

  { TFireStormSpell (instance size 60, VMT 557CC060) }
  TFireStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TDivineStormSpell (instance size 60, VMT 557CC180) }
  TDivineStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TDeathStormSpell (instance size 60, VMT 557CC2A8) }
  TDeathStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TIceStormSpell (instance size 60, VMT 557CC3D0) }
  TIceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TLightningStormSpell (instance size 60, VMT 557CC4F0) }
  TLightningStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

  { TPestilenceStormSpell (instance size 60, VMT 557CC620) }
  TPestilenceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateStorm; override;
  end;

procedure RegisterStorms(A1: Integer);  { draft }
procedure UnRegisterStorms(A1: Integer);  { draft }

implementation

procedure TStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin
  FPlayer := Player;
  FAnimationLevel := 28;
  AoWHSMap.LockExecuteEventLog;
end;

function TStorm.UpdateStorm: Boolean;
begin
  Result := False;
end;

procedure TStorm.FinalizeStorm;
begin
  AoWHSMap.UnlockExecuteEventLog;
end;

procedure TStorm.ShowTargetSelection(Selection: TTargetSelectionControl; HN, Xs, Ys: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Intensity: Integer;
begin
  HN := HNtoRad(HN);
  Intensity := Abs((AoWHSMap.Frame + HN) mod 9 - 4) * 20 + 20;
  Selection.FImageLibrary[0].ShowBlended(Xs - 8, Ys, SurfaceDesc,
    IntensityBlendTable.GetLookupTables(Intensity));
end;

procedure TStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin
  Selection.FOnShow := ShowTargetSelection;
  Selection.FTargetMode := Selection.FTargetMode + [tmOwnerDraw];
end;

function TStorm.GetBestTarget(Player: Shortint; X, Y, L, Range: Integer; var Target: TXYL; var Info: TStormDamageInfo): Boolean;
var
  Candidate: TStormDamageInfo;
  Walk: THNWalkData;
  Level: TMapLevel;
  ArmyHS: TArmyHS;
begin
  Level := AoWHSMap.MapContainer.MapLevels[L];
  Target.XYL := $FFFFFF;
  Result := False;
  FillChar(Info, SizeOf(Info), 0);
  FillChar(Candidate, SizeOf(Candidate), 0);
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Range do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      ArmyHS := TAoWMapField(Level.Field[Walk.X, Walk.Y]).GetArmyHS;
      if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer <> 0) and
        ValidAttackRelation(Player, 0, ArmyHS.FArmy.FPlayer, 0) then
      begin
        GetTargetDamageInfo(Player, Walk.X, Walk.Y, L, Candidate);
        if Info.EnemyDamage - Info.FriendlyDamage < Candidate.EnemyDamage - Candidate.FriendlyDamage then
        begin
          Info := Candidate;
          Target := PackXYL(Walk.X, Walk.Y, L);
          Result := True;
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TBlastStorm.InitializeStorm(Player, X, Y, L: Shortint);
var
  R: TRect;
begin
  inherited InitializeStorm(Player, X, Y, L);
  FStormImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], StormFileName);
  if GetVisible then FStormImages.LoadDiscardableImageData;
  R.Left := -(FStormImages[0].Width shr 1);
  R.Right := FStormImages[0].Width shr 1;
  R.Top := -(FStormImages[0].Height shr 1);
  R.Bottom := FStormImages[0].Height shr 1;
  SetDimensions(R);
  AoWHSMap.ValidateTerrainObservation(AoWHSMap.FCurrentPlayer, X, Y, L, 4);
  if (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.TerrainVisible(X, Y, L, 4) then
    PlaySample('SFX\ATTACK\STORMBIG.WAV');
  PlaceHX(AoWHSMap.MapContainer, X, Y, L);
end;

function TBlastStorm.StormFileName: string;
begin
  Result := '';
end;

function TBlastStorm.StormType: TStormType;
begin
  Result := stNone;
end;

procedure TBlastStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
end;

procedure TBlastStorm.StormTerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
begin
end;

function TBlastStorm.UpdateStorm: Boolean;
begin
  NewFrame;
  if FFrameCounter = 8 then
    AoWHSMap.ChangeTerrainEx(nil, GetXhx, GetYhx, GetLhx, 1, ChangeStormTerrain, StormTerrainChanged)
  else if FFrameCounter = 12 then
    AoWHSMap.ChangeTerrainEx(nil, GetXhx, GetYhx, GetLhx, 2, ChangeStormTerrain, StormTerrainChanged)
  else if FFrameCounter = 18 then
    AoWHSMap.ChangeTerrainEx(nil, GetXhx, GetYhx, GetLhx, 3, ChangeStormTerrain, StormTerrainChanged)
  else if FFrameCounter = 22 then
    AoWHSMap.ChangeTerrainEx(nil, GetXhx, GetYhx, GetLhx, 4, ChangeStormTerrain, StormTerrainChanged);
  if FStormImages.Count = FFrameCounter then
  begin
    TriggerStormDamage(StormType, GetXhx, GetYhx, GetLhx, 0, 4, AoWHSMap.FCurrentPlayer);
    Result := False;
  end
  else Result := True;
end;

procedure TBlastStorm.FinalizeStorm;
begin
  FStormImages.ReleaseDiscardableImageData;
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], StormFileName);
  inherited FinalizeStorm;
end;

procedure TBlastStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y, Frame: Integer;
begin
  Frame := FFrameCounter mod FStormImages.Count;
  HXtoHP(GetXhx, GetYhx, X, Y);
  X := X - (FStormImages[Frame].Width shr 1) + 10;
  Y := Y - (FStormImages[Frame].Height shr 1) - 42;
  FStormImages[Frame].Show(X - XhpSurf, Y - YhpSurf, SurfaceDesc);
end;

procedure TBlastStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
var
  I: Integer;
begin
  inherited UpdateTargetSelection(Selection);
  Selection.FHNs.Clear;
  for I := 0 to RadToHN(5) - 1 do Selection.FHNs.Add(0);
end;

procedure TBlastStorm.GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo);
begin
  RetrieveStormDamageInfo(Player, StormType, X, Y, L, 0, 4, Info);
end;

class function TIceStorm.ClassID: Integer;
begin
  Result := $2123A;
end;

class function TIceStorm.Name: string;
begin
  Result := TranslateRStr(IceStormRStr);
end;

procedure TIceStorm.StormTerrainChanged(MapF: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if (MapF.TerrainType in [6, 13]) and not (OriginalTerrainType in [6, 13]) then
  begin
    Ice := TFrozenWaterHS(MapF.FindOwnedHS(TFrozenWaterHS));
    if Ice = nil then
    begin
      Ice := TFrozenWaterHS.Create(nil);
      AoWHSMap.PlaceHX(Ice, MapF.Xhx, MapF.Yhx, MapF.Lhx);
    end;
    Ice.FDaysRemaining := 3 + (AoWHSMap.Random(11) - 5) div 5;
    Ice.FCasterPlayer := FPlayer;
  end;
end;

procedure TIceStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  { Original sends terrain 13 to the default branch before the ice refresh test. }
  case Smallint(TerrainType) of
    0: TerrainType := 6;
    6:
      if TerrainType in [6, 13] then
      begin
        Ice := TFrozenWaterHS(MapF.FindOwnedHS(TFrozenWaterHS));
        if Ice <> nil then
        begin
          Ice.FDaysRemaining := 3 + (AoWHSMap.Random(11) - 5) div 5;
          Ice.FCasterPlayer := FPlayer;
        end;
      end;
  else
    TerrainType := 3;
  end;
end;

function TIceStorm.StormFileName: string;
begin
  Result := 'EFFECTS\STORM1.ILB';
end;

function TIceStorm.StormType: TStormType;
begin
  Result := stIce;
end;

class function TLightningStorm.ClassID: Integer;
begin
  Result := $2123B;
end;

class function TLightningStorm.Name: string;
begin
  Result := TranslateRStr(LightningStormRStr);
end;

procedure TLightningStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y, Frame: Integer;
begin
  Frame := FFrameCounter mod FStormImages.Count;
  if FStormImages[Frame] <> nil then
  begin
    HXtoHP(GetXhx, GetYhx, X, Y);
    X := X - (FStormImages[Frame].Width shr 1) + 20;
    Y := Y - FStormImages[Frame].Height + 32 + 40;
    FStormImages[Frame].Show(X - XhpSurf, Y - YhpSurf, SurfaceDesc);
  end;
end;

procedure TLightningStorm.InitializeStorm(Player, X, Y, L: Shortint);
var
  R: TRect;
begin
  inherited InitializeStorm(Player, X, Y, L);
  FStormImages := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'EFFECTS\LIGHTN.ILB');
  if GetVisible then FStormImages.LoadDiscardableImageData;
  R.Left := -(FStormImages[0].Width shr 1);
  R.Right := FStormImages[0].Width shr 1;
  R.Top := -FStormImages[0].Height + 32;
  R.Bottom := 32;
  SetDimensions(R);
  AoWHSMap.ValidateTerrainObservation(AoWHSMap.FCurrentPlayer, X, Y, L, 2);
  PlaceHX(AoWHSMap.MapContainer, X, Y, L);
end;

procedure TLightningStorm.FinalizeStorm;
begin
  FStormImages.ReleaseDiscardableImageData;
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'EFFECTS\LIGHTN.ILB');
  inherited FinalizeStorm;
end;

function TLightningStorm.UpdateStorm: Boolean;
begin
  NewFrame;
  if FStormImages.GetSafe(FFrameCounter) <> nil then PlaySample('SFX\ATTACK\LIGHTNG.WAV');
  if FStormImages.Count = FFrameCounter then
  begin
    TriggerStormDamage(stLightning, GetXhx, GetYhx, GetLhx, 0, 1, AoWHSMap.FCurrentPlayer);
    Result := False;
  end
  else Result := True;
end;

procedure TLightningStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
var
  I: Integer;
begin
  inherited UpdateTargetSelection(Selection);
  { Original adds to the map selection, without clearing its existing hexes. }
  for I := 0 to RadToHN(2) - 1 do AoWHSMap.FTargetSelection.FHNs.Add(0);
end;

procedure TLightningStorm.GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo);
begin
  RetrieveStormDamageInfo(Player, stLightning, X, Y, L, 0, 1, Info);
end;

class function TDeathStorm.ClassID: Integer;
begin
  Result := $2123D;
end;

class function TDeathStorm.Name: string;
begin
  Result := TranslateRStr(DeathStormRStr);
end;

procedure TDeathStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
  case Smallint(TerrainType) of
    0, 6: ;
  else
    TerrainType := 5;
  end;
end;

function TDeathStorm.StormFileName: string;
begin
  Result := 'EFFECTS\STORMD.ILB';
end;

function TDeathStorm.StormType: TStormType;
begin
  Result := stDeath;
end;

class function TFireStorm.ClassID: Integer;
begin
  Result := $2123E;
end;

class function TFireStorm.Name: string;
begin
  Result := TranslateRStr(FireStormRStr);
end;

procedure TFireStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y, Frame: Integer;
  Sequence: TImageSequence;
begin
  HXtoHP(GetXhx, GetYhx, X, Y);
  X := X - XhpSurf + 8;
  Y := Y - YhpSurf;
  Sequence := AoWHSSet.FImageSequences.ImageSequences[0];
  while Sequence <> nil do
  begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrameCounter);
    if (Frame <> -1) and Sequence.ImageLibrary.ImageExist(Frame) then
      Sequence.ImageLibrary[Frame].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;

procedure TFireStorm.InitializeStorm(Player, X, Y, L: Shortint);
var
  R: TRect;
begin
  inherited InitializeStorm(Player, X, Y, L);
  R.Left := -80;
  R.Right := 96;
  R.Top := -80;
  R.Bottom := 96;
  SetDimensions(R);
  AoWHSMap.ValidateTerrainObservation(AoWHSMap.FCurrentPlayer, X, Y, L, 2);
  PlaceHX(AoWHSMap.MapContainer, X, Y, L);
end;

procedure TFireStorm.FinalizeStorm;
begin
  inherited FinalizeStorm;
end;

procedure TFireStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
  case Smallint(TerrainType) of
    6: TerrainType := 0;
  end;
end;

function TFireStorm.UpdateStorm: Boolean;
var
  Sequence: TImageSequence;
  Frame: Integer;
begin
  NewFrame;
  if FFrameCounter = 20 then
  begin
    TriggerStormDamage(stFire, GetXhx, GetYhx, GetLhx, 0, 2, AoWHSMap.FCurrentPlayer);
    AoWHSMap.ChangeTerrainEx(Self, GetXhx, GetYhx, GetLhx, 2, ChangeStormTerrain, nil);
  end;
  Sequence := AoWHSSet.FImageSequences.ImageSequences[0];
  Frame := -1;
  while (Sequence <> nil) and (Frame = -1) do
  begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrameCounter);
    Sequence := Sequence.Next;
  end;
  if Frame = 1 then
    if (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) or
      AoWHSMap.TerrainVisible(GetXhx, GetYhx, GetLhx, 2) then
      PlaySample(ExplosionSFX[System.Random(2)]);
  Result := Frame <> -1;
end;

procedure TFireStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
var
  I: Integer;
begin
  inherited UpdateTargetSelection(Selection);
  { Original adds to the map selection, without clearing its existing hexes. }
  for I := 0 to RadToHN(3) - 1 do AoWHSMap.FTargetSelection.FHNs.Add(0);
end;

procedure TFireStorm.GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo);
begin
  RetrieveStormDamageInfo(Player, stFire, X, Y, L, 0, 2, Info);
end;

class function TDivineStorm.ClassID: Integer;
begin Result := 0; end;

class function TDivineStorm.Name: string;
begin Result := ''; end;

procedure TDivineStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin end;

function TDivineStorm.StormFileName: string;
begin Result := ''; end;

function TDivineStorm.StormType: TStormType;
begin Result := stNone; end;

class function TPestilenceStorm.ClassID: Integer;
begin Result := 0; end;

class function TPestilenceStorm.Name: string;
begin Result := ''; end;

procedure TPestilenceStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TPestilenceStorm.InitializeStorm(Player, X, Y, L: Shortint);
begin end;

procedure TPestilenceStorm.FinalizeStorm;
begin end;

function TPestilenceStorm.UpdateStorm: Boolean;
begin Result := False; end;

procedure TPestilenceStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
begin end;

procedure TPestilenceStorm.GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo);
begin end;

class function TStormSpellTE.ClassID: Integer;
begin Result := 0; end;

procedure TStormSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TStormSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin Result := False; end;

constructor TStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStormSpell.ExecuteStormSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStormSpell.OnTargetSelectionChange(A1: Integer);
begin end;

function TStormSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
begin Result := False; end;

function TStormSpell.Activate(A1: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TStormSpell.AICastSpellPriority(A1: Integer);
begin end;

procedure TStormSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
begin end;

function TStormSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
begin Result := False; end;

constructor TFireStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFireStormSpell.CreateStorm;
begin end;

constructor TDivineStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDivineStormSpell.CreateStorm;
begin end;

constructor TDeathStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TDeathStormSpell.CreateStorm;
begin end;

constructor TIceStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TIceStormSpell.CreateStorm;
begin end;

constructor TPestilenceStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TPestilenceStormSpell.CreateStorm;
begin end;

constructor TLightningStormSpell.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TLightningStormSpell.CreateStorm;
begin end;

procedure RegisterStorms(A1: Integer);
begin end;

procedure UnRegisterStorms(A1: Integer);
begin end;


initialization
finalization

end.
