unit BloodShrine;

{ Blood shrines of AoWEPACK.dpl: army bloodlust and blessing animations. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TBloodShrineAnimation = class;
  TBloodShrine = class;
  TBloodShrineResource = class;


  { TBloodShrineAnimation: size $3C, VMT 557E26D0; no additional fields. }
  TBloodShrineAnimation = class(TAnimation)
  public
    function AnimationControlMode: TAnimationControlMode; override;
    procedure NewFrame; override;
  end;

  { TBloodShrine: size $30, VMT 557E2880; no additional fields. }
  TBloodShrine = class(TStructure)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure ArmyPlaced(A1: TArmyHS); override;
    procedure ShowBlessingAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure ExecuteBloodlust(ArmyHS: TArmyHS);
  end;

  { TBloodShrineResource: size $64, VMT 557E2AEC; no additional fields. }
  TBloodShrineResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterBloodShrine(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PAoWHSSet = ^TAoWHSSet;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  WorldSet: PAoWHSSet = @AoWE.AoWHSSet;

function TBloodShrineAnimation.AnimationControlMode: TAnimationControlMode;
begin Result := [amLinkToNewFrame, amOwnedByMap]; end;

procedure TBloodShrineAnimation.NewFrame;
begin
  inherited NewFrame;
  if FFrameCounter > 20 then Destroy;
end;

constructor TBloodShrine.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

class function TBloodShrine.ClassID: Integer;
begin Result := $20130; end;

procedure TBloodShrine.ShowBlessingAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  Dec(Xhp, XhpSurf);
  Dec(Yhp, YhpSurf);
  FResource.ImageSequenceList.Show(20, Xhp, Yhp, Anim.FFrameCounter, SurfaceDesc);
end;

procedure TBloodShrine.ExecuteBloodlust(ArmyHS: TArmyHS);
var
  Anim: TBloodShrineAnimation;
  R: TRect;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  for I := 0 to ArmyHS.FArmy.Count - 1 do
  begin
    AUnit := ArmyHS.FArmy.GetUnit(I);
    WorldSet^.FAbilityControl.GetAbility($A8).Expand(AUnit);
  end;
  if (ArmyHS.FArmy.FPlayer = WorldMap^.FSeatedPlayer) or
    WorldMap^.Watching(GetXhx, GetYhx, GetLhx, 0) then
    Sound.PlaySample('SFX\ATTACK\ENCHP02.WAV');
  if WorldMap^.Visible(GetXhx, GetYhx, GetLhx, 0) then
  begin
    Anim := TBloodShrineAnimation.Create(nil);
    R := Rect(-16, -8, 32, 40);
    Anim.SetDimensions(R);
    Anim.FAnimationLevel := 27;
    Anim.FOnShow := ShowBlessingAnimation;
    WorldMap^.PlaceHX(Anim, GetXhx, GetYhx, GetLhx);
  end;
end;

procedure TBloodShrine.ArmyPlaced(A1: TArmyHS);
begin
  inherited ArmyPlaced(A1);
  ExecuteBloodlust(A1);
end;

constructor TBloodShrineResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := True;
  FConnectRoads := False;
end;

class function TBloodShrineResource.ClassID: Integer;
begin Result := $20131; end;

class function TBloodShrineResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@BloodShrineRStr)); end;

function TBloodShrineResource.ResourceUserClassID: Integer;
begin Result := $20130; end;

procedure RegisterBloodShrine(AEngine: TEngine);
begin AEngine.RegisterEClasses([TBloodShrine, TBloodShrineResource]); end;

initialization
finalization
end.
