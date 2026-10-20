unit Storms;

{ Storms, recovered from AoWEPACK.dpl: storm animations, targeting and spells. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE, PoisonC;

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

  { TPestilenceStorm (instance size 68, VMT 557CBCB8): $40 poison cloud resource. }
  TPestilenceStorm = class(TStorm)
  public
    FCloudResource: TPoisonCloudResource; { $40 }
    class function ClassID: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo); override;
    procedure UpdateTargetSelection(Selection: TTargetSelectionControl); override;
    procedure InitializeStorm(Player, X, Y, L: Shortint); override;
    function UpdateStorm: Boolean; override;
    procedure FinalizeStorm; override;
    class function Name: string; override;
  end;

  { TStormSpellTE (instance size 40, VMT 557CBE74): $20 storm, $24 X, $25 Y, $26 layer. }
  TStormSpellTE = class(TSpellTE)
  public
    FStorm: TStorm; { $20 }
    FX: Shortint; { $24 }
    FY: Shortint; { $25 }
    FL: Shortint; { $26 }
    F_StormSpellTE_27: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
  end;

  { TStormSpell (instance size 60, VMT 557CBF48): $34 targeting storm, $38 caster. }
  TStormSpell = class(TSpell)
  public
    FTargetStorm: TStorm; { $34 }
    FSource: TAbstractUnit; { $38 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function CreateStorm: TStorm; virtual; abstract; { +09C }
    function ExecuteStormSpell(Source: TAbstractUnit; X, Y, L: Shortint): Boolean; virtual; { +0A0 }
    function AICastSpellPriority(Source: TAbstractUnit): Integer; virtual; { +0A4 }
    procedure OnTargetSelectionChange(Sender: TObject);
  end;

  { TFireStormSpell (instance size 60, VMT 557CC060) }
  TFireStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

  { TDivineStormSpell (instance size 60, VMT 557CC180) }
  TDivineStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

  { TDeathStormSpell (instance size 60, VMT 557CC2A8) }
  TDeathStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

  { TIceStormSpell (instance size 60, VMT 557CC3D0) }
  TIceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

  { TLightningStormSpell (instance size 60, VMT 557CC4F0) }
  TLightningStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

  { TPestilenceStormSpell (instance size 60, VMT 557CC620) }
  TPestilenceStormSpell = class(TStormSpell)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateStorm: TStorm; override;
  end;

procedure RegisterStorms(AEngine: TEngine);
procedure UnRegisterStorms(AEngine: TEngine);

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
begin
  Result := $2123C;
end;

class function TDivineStorm.Name: string;
begin
  Result := TranslateRStr(DivineStormRStr);
end;

procedure TDivineStorm.ChangeStormTerrain(MapF: TMapField; var TerrainType, OverlayType: Shortint);
begin
  if (Smallint(TerrainType) <> 6) and (Smallint(TerrainType) <> 0) then
    TerrainType := 1;
end;

function TDivineStorm.StormFileName: string;
begin
  Result := 'EFFECTS\STORMLGT.ILB';
end;

function TDivineStorm.StormType: TStormType;
begin
  Result := stHoly;
end;

class function TPestilenceStorm.ClassID: Integer;
begin
  Result := $21241;
end;

class function TPestilenceStorm.Name: string;
begin
  Result := TranslateRStr(PestilenceStormRStr);
end;

procedure TPestilenceStorm.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y, Frame, Blend: Integer;
  Sequence: TImageSequence;
begin
  HXtoHP(GetXhx, GetYhx, X, Y);
  X := X - XhpSurf + 8;
  Y := Y - YhpSurf;
  Sequence := FCloudResource.ImageSequenceList.ImageSequences[0];
  while Sequence <> nil do
  begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrameCounter);
    if (Frame <> -1) and Sequence.ImageLibrary.ImageExist(Frame) then
    begin
      Blend := Sequence.GetTotalSequenceFrames;
      if Blend <> 0 then Blend := FFrameCounter * 100 div Blend
      else Blend := 100;
      Sequence.ImageLibrary[Frame].ShowBlended(X + Sequence.dXshift, Y + Sequence.dYshift,
        SurfaceDesc, ShadowBlendTable.LookupTables[Blend]);
    end;
    Sequence := Sequence.Next;
  end;
end;

procedure TPestilenceStorm.InitializeStorm(Player, X, Y, L: Shortint);
var
  R: TRect;
begin
  FCloudResource := TPoisonCloudResource(AoWHSSet.MapObjectResourceList.FindChild($21240));
  inherited InitializeStorm(Player, X, Y, L);
  R.Left := -80;
  R.Right := 96;
  R.Top := -80;
  R.Bottom := 96;
  SetDimensions(R);
  AoWHSMap.ValidateTerrainObservation(AoWHSMap.FCurrentPlayer, X, Y, L, 2);
  if (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) or AoWHSMap.TerrainVisible(X, Y, L, 2) then
    AoWHSSet.FSpellControl.GetSpell(9).FCastSounds.Play(0);
  PlaceHX(AoWHSMap.MapContainer, X, Y, L);
end;

procedure TPestilenceStorm.FinalizeStorm;
begin
  inherited FinalizeStorm;
end;

function TPestilenceStorm.UpdateStorm: Boolean;
var
  Sequence: TImageSequence;
  Frame: Integer;
  Cloud: TPoisonCloud;
begin
  NewFrame;
  Sequence := FCloudResource.ImageSequenceList.ImageSequences[0];
  Frame := -1;
  while (Sequence <> nil) and (Frame = -1) do
  begin
    Frame := Sequence.GetUnloopedFrameIndex(FFrameCounter);
    Sequence := Sequence.Next;
  end;
  if Frame = -1 then
  begin
    Cloud := TPoisonCloud(FCloudResource.CreateResourceUser);
    Cloud.FTurnsRemaining := 3;
    Cloud.FPlayer := AoWHSMap.FCurrentPlayer;
    if AoWHSMap.PlaceHX(Cloud, GetXhx, GetYhx, GetLhx) then Cloud.TriggerDamage
    else Cloud.Free;
    Result := False;
  end
  else Result := True;
end;

procedure TPestilenceStorm.UpdateTargetSelection(Selection: TTargetSelectionControl);
var
  I: Integer;
begin
  inherited UpdateTargetSelection(Selection);
  { Original adds to the map selection without clearing its existing hexes. }
  for I := 0 to RadToHN(3) - 1 do AoWHSMap.FTargetSelection.FHNs.Add(0);
end;

procedure TPestilenceStorm.GetTargetDamageInfo(Player, X, Y, L: Shortint; var Info: TStormDamageInfo);
begin
  RetrieveStormDamageInfo(Player, stPestilence, X, Y, L, 0, 2, Info);
end;

class function TStormSpellTE.ClassID: Integer;
begin
  Result := $21301;
end;

procedure TStormSpellTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FX), 20);
  Stream.rwByte(Byte(FY), 21);
  Stream.rwByte(Byte(FL), 22);
end;

function TStormSpellTE.Process(A1: TAbstractUnit; A2: Integer): Boolean;
begin
  inherited Process(A1, A2);
  if A2 = 0 then
  begin
    FStorm := TStormSpell(AoWHSSet.FSpellControl.GetSpell(FEventSpellID)).CreateStorm;
    with FStorm do InitializeStorm(A1.FPlayer, FX, FY, FL);
    AoWHSSet.FSpellControl.GetSpell(FEventSpellID).CastingDone(A1, FEventMana);
  end;
  if not FStorm.UpdateStorm then
  begin
    FStorm.FinalizeStorm;
    FStorm.Free;
    FStorm := nil;
    Result := False;
  end
  else Result := True;
end;

constructor TStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellType := stGlobal;
end;

function TStormSpell.ExecuteStormSpell(Source: TAbstractUnit; X, Y, L: Shortint): Boolean;
var
  TE: TStormSpellTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(Source.FPlayer).GetBusy then
  begin
    TE := TStormSpellTE.Create(nil);
    TE.Initialize(FSpellID, Source.FPlayer, Source.FUnitID, FBaseManaCost);
    TE.FX := X;
    TE.FY := Y;
    TE.FL := L;
    AoWHSMap.FTokenManager.GetTokenControl(Source.FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TStormSpell.OnTargetSelectionChange(Sender: TObject);
var
  Selection: TTargetSelectionControl;
begin
  Selection := TTargetSelectionControl(Sender);
  case Selection.FChange of
    tscDeactivated:
      begin
        FTargetStorm.Free;
        FTargetStorm := nil;
        Selection.FOnChange.Remove(OnTargetSelectionChange);
      end;
    tscSelected:
      begin
        Selection.FOnChange.Remove(OnTargetSelectionChange);
        if ExecuteStormSpell(FSource, Selection.FTargetX, Selection.FTargetY, Selection.FTargetL) then
          Selection.Deactivate;
        FTargetStorm.Free;
        FTargetStorm := nil;
      end;
  end;
end;

function TStormSpell.CanActivate(A1: TAbstractUnit; var A2: string): Boolean;
var
  X, Y, L: Shortint;
begin
  Result := inherited CanActivate(A1, A2);
  if Result then
  begin
    A1.GetLocation(X, Y, L);
    if L <> 0 then
    begin
      Result := False;
      A2 := TranslateRStr(CannotCastSpellInUndergoundRStr);
    end;
  end;
end;

function TStormSpell.Activate(A1: TAbstractUnit): Boolean;
var
  X, Y, L: Shortint;
  Reason: string;
  Selection: TTargetSelectionControl;
begin
  inherited Activate(A1);
  if CanActivate(A1, Reason) then
  begin
    FSource := A1;
    A1.GetLocation(X, Y, L);
    Selection := AoWHSMap.FTargetSelection;
    FTargetStorm := CreateStorm;
    Selection.Initialize(Self);
    Selection.FTargetMode := Selection.FTargetMode + [tmValidateDistance, tmExternalFloater];
    Selection.FSourceX := X;
    Selection.FSourceY := Y;
    Selection.FSourceL := L;
    AoWHSMap.MakeVisible(X, Y, L, 5);
    Selection.FText.Text := SysUtils.Format(TranslateRStr(SelectTargetLocationForXOnMapRStr),
      [FTargetStorm.Name]);
    Selection.FTitle := FSpellName;
    Selection.FCancelText := TranslateRStr(CancelRStr);
    Selection.FRange := 12;
    Selection.FOnChange.Add(OnTargetSelectionChange);
    Selection.FSourceImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[20].GetPreviewImage;
    Selection.FValidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[21].GetPreviewImage;
    Selection.FInvalidTargetImage := AoWHSSet.FSpellControl.GetSpell(FSpellID).FCastImages.ImageSequences[22].GetPreviewImage;
    Selection.Activate;
    FTargetStorm.UpdateTargetSelection(AoWHSMap.FTargetSelection);
    Result := True;
  end
  else Result := False;
end;

function TStormSpell.AICastSpellPriority(Source: TAbstractUnit): Integer;
var
  Target: TXYL;
  X, Y, L: Shortint;
  Reason: string;
  Storm: TStorm;
  Info: TStormDamageInfo;
begin
  if CanActivate(Source, Reason) then
  begin
    Result := -1;
    Source.GetLocation(X, Y, L);
    if L = 0 then
    begin
      Storm := CreateStorm;
      if Storm.GetBestTarget(Source.FPlayer, X, Y, L, 12, Target, Info) and
        ((Info.EnemyDamage - Info.FriendlyDamage) > (FBaseManaCost * 0.75)) then
        Result := (Info.EnemyDamage - Info.FriendlyDamage) * 5 + 750;
      Storm.Free;
    end;
  end
  else Result := -1;
end;

procedure TStormSpell.AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList);
var
  Priority: Integer;
  Action: TAICastSpellAction;
begin
  if AIRequestCastSpellExpense(A1, FBaseManaCost, 0, 0) then
  begin
    Priority := AICastSpellPriority(A1);
    if Priority <> -1 then
    begin
      Action := CreateCastSpellAction;
      SetupCastSpellAction(A1, Action);
      Action.FPriority := Priority;
      Action.SetOwner(A2);
    end;
  end;
end;

function TStormSpell.AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean;
var
  Reason: string;
  Target: TXYL;
  X, Y, L: Shortint;
  Storm: TStorm;
  Info: TStormDamageInfo;
begin
  if AICastSpellPriority(A1) <> -1 then
  begin
    AICastSpellExpenseMade(A1, FBaseManaCost, FManaUpkeep, 0);
    if THero(A1).CanCastSpellInstantly(FSpellID, FBaseManaCost, Reason) then
    begin
      A1.GetLocation(X, Y, L);
      Storm := CreateStorm;
      if Storm.GetBestTarget(A1.FPlayer, X, Y, L, 12, Target, Info) then
      begin
        ExecuteStormSpell(A1, Target.X, Target.Y, Target.L);
        Result := True;
      end
      else Result := False;
      Storm.Free;
    end
    else if THero(A1).FCastingSpellID <> FSpellID then
    begin
      THero(A1).ExecuteStartCasting(FSpellID);
      Result := True;
    end
    else Result := True;
  end
  else Result := False;
end;

constructor TFireStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(FireStormRStr);
  FSpellID := 3;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msFire;
end;

function TFireStormSpell.CreateStorm: TStorm;
begin
  Result := TFireStorm.Create(nil);
end;

constructor TDivineStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DivineStormRStr);
  FSpellID := 6;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msLife;
end;

function TDivineStormSpell.CreateStorm: TStorm;
begin
  Result := TDivineStorm.Create(nil);
end;

constructor TDeathStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(DeathStormRStr);
  FSpellID := 5;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msDeath;
end;

function TDeathStormSpell.CreateStorm: TStorm;
begin
  Result := TDeathStorm.Create(nil);
end;

constructor TIceStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(IceStormRStr);
  FSpellID := 4;
  FBaseManaCost := 5;
  FSpellLevel := 4;
  FMagicSphere := msAir;
end;

function TIceStormSpell.CreateStorm: TStorm;
begin
  Result := TIceStorm.Create(nil);
end;

constructor TPestilenceStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(PestilenceStormRStr);
  FSpellID := 9;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msDeath;
end;

function TPestilenceStormSpell.CreateStorm: TStorm;
begin
  Result := TPestilenceStorm.Create(nil);
end;

constructor TLightningStormSpell.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSpellName := TranslateRStr(LightningStormRStr);
  FSpellID := 7;
  FBaseManaCost := 5;
  FSpellLevel := 3;
  FMagicSphere := msAir;
end;

function TLightningStormSpell.CreateStorm: TStorm;
begin
  Result := TLightningStorm.Create(nil);
end;

procedure RegisterStorms(AEngine: TEngine);
var
  Spells: TSpellControl;
begin
  AEngine.RegisterEClasses([TIceStorm, TDeathStorm, TDivineStorm, TFireStorm,
    TLightningStorm, TPestilenceStorm, TStormSpellTE]);
  Spells := TAoWEngine(AEngine).FGameSet.FSpellControl;
  Spells.RegisterSpell(TFireStormSpell.Create(nil));
  Spells.RegisterSpell(TDeathStormSpell.Create(nil));
  Spells.RegisterSpell(TDivineStormSpell.Create(nil));
  Spells.RegisterSpell(TLightningStormSpell.Create(nil));
  Spells.RegisterSpell(TIceStormSpell.Create(nil));
  Spells.RegisterSpell(TPestilenceStormSpell.Create(nil));
end;

procedure UnRegisterStorms(AEngine: TEngine);
var
  Spells: TSpellControl;
begin
  Spells := TAoWEngine(AEngine).FGameSet.FSpellControl;
  Spells.UnregisterSpellID(3);
  Spells.UnregisterSpellID(5);
  Spells.UnregisterSpellID(6);
  Spells.UnregisterSpellID(7);
  Spells.UnregisterSpellID(4);
  Spells.UnregisterSpellID(9);
end;

initialization
finalization

end.
