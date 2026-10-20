unit Spring;

{ Spring of AoWEPACK.dpl: recovered bodies and original instance layouts.
  Remaining inherited declaration constraints are documented at local ABI adapters. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Animation, AoWE;

type
  TSpringOfLifeAnimation = class;
  TSpringOfLife = class;
  TSpringOfLifeResource = class;


  { TSpringOfLifeAnimation (instance size 60, VMT 557A3858) }
  TSpringOfLifeAnimation = class(TAnimation)
  public
    procedure AnimationControlMode; override;
    procedure NewFrame; override;
  end;

  { TSpringOfLife (instance size 48, VMT 557A3A04) }
  TSpringOfLife = class(TStructure)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ShowBlessingAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure ExecuteNaturesBlessing(ArmyHS: Pointer);
  end;

  { TSpringOfLifeResource (instance size 100, VMT 557A3C6C) }
  TSpringOfLifeResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterSpringOfLife(AEngine: TEngine);

implementation

type
  TSpringUnitList = class(TUnitList)
    function UnitAt(Index: Integer): TUnit;
  end;
  TSpringMap = class(TAoWHSMap)
    function IsVisible(Xhx, Yhx, Lhx: Shortint; Radius: Integer): Boolean;
    function IsWatching(Xhx, Yhx, Lhx: Shortint; Radius: Integer): Boolean;
  end;
  PAoWHSMap = ^TAoWHSMap;
  TSpringMapFields = packed record
    Reserved: array[0..164] of Byte;
    SeatedPlayer: Byte;
  end;
  TSpringAnimationCallback = packed record
    Reserved: array[0..35] of Byte;
    OnShow: TShowAnimationEvent;
  end;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  SpringMode: TAnimationControlMode = [amLinkToNewFrame, amOwnedByMap];

{ needs: AnimationControlMode returns TAnimationControlMode in AL. }

procedure TSpringOfLifeAnimation.AnimationControlMode;
asm
  MOV AL,SpringMode
end;

{ needs: AoWE draft result signatures; preserve the original register ABI. }
function TSpringUnitList.UnitAt(Index: Integer): TUnit; assembler;
asm JMP TUnitList.GetUnit end;
function TSpringMap.IsVisible(Xhx, Yhx, Lhx: Shortint; Radius: Integer): Boolean; assembler;
asm JMP TAoWHSMap.Visible end;
function TSpringMap.IsWatching(Xhx, Yhx, Lhx: Shortint; Radius: Integer): Boolean; assembler;
asm JMP TAoWHSMap.Watching end;
function TranslateSpringName(const S: string): string; assembler;
asm JMP AoWE.TranslateRStr end;

procedure TSpringOfLifeAnimation.NewFrame;
begin
  inherited NewFrame;
  if F_Animation_10 > 20 then Destroy;
end;

constructor TSpringOfLife.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

class function TSpringOfLife.ClassID: Integer;
begin Result := $20100; end;

procedure TSpringOfLife.ShowBlessingAnimation(Anim: TAnimation; XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  Dec(Xhp, XhpSurf);
  Dec(Yhp, YhpSurf);
  FResource.ImageSequenceList.Show(20, Xhp, Yhp, Anim.F_Animation_10, SurfaceDesc);
end;

procedure TSpringOfLife.ExecuteNaturesBlessing(ArmyHS: Pointer);
var
  Anim: TSpringOfLifeAnimation;
  R: TRect;
  I: Integer;
begin
  for I := 0 to TUnitList(TArmyHS(ArmyHS).FArmy).Count - 1 do
    TSpringUnitList(TArmyHS(ArmyHS).FArmy).UnitAt(I).ExpandAbility(99);
  if (Byte(TArmy(TArmyHS(ArmyHS).FArmy).FPlayer) =
    TSpringMapFields(Pointer(WorldMap^)^).SeatedPlayer) or
    TSpringMap(WorldMap^).IsWatching(GetXhx, GetYhx, GetLhx, 0) then
    Sound.PlaySample('SFX\ATTACK\ENCHP02.WAV');
  if TSpringMap(WorldMap^).IsVisible(GetXhx, GetYhx, GetLhx, 0) then
  begin
    Anim := TSpringOfLifeAnimation.Create(nil);
    R := Rect(-16, -8, 32, 40);
    { needs: TAnimation.SetDimensions(const R: TRect). }
    Anim.SetDimensions(Integer(@R));
    Anim.F_Animation_0B[0] := 27;
    TSpringAnimationCallback(Pointer(Anim)^).OnShow := ShowBlessingAnimation;
    WorldMap^.PlaceHX(Anim, GetXhx, GetYhx, GetLhx);
  end;
end;

procedure TSpringOfLife.ArmyPlaced(A1: Integer);
begin
  inherited ArmyPlaced(A1);
  if not (TMapField(Owner).TerrainType in [3, 5]) then ExecuteNaturesBlessing(Pointer(A1));
end;

constructor TSpringOfLifeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  F_StructureResource_44 := 0;
end;

class function TSpringOfLifeResource.ClassID: Integer;
begin Result := $20101; end;

class function TSpringOfLifeResource.ResourceEditName: string;
begin Result := TranslateSpringName(LoadResString(@SpringOfLifeRStr)); end;

function TSpringOfLifeResource.ResourceUserClassID: Integer;
begin Result := $20100; end;

procedure RegisterSpringOfLife(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TSpringOfLife, TSpringOfLifeResource]);
end;


initialization
finalization

end.
