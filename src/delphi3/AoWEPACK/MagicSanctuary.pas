unit MagicSanctuary;

{ MagicSanctuary of AoWEPACK.dpl: recovered bodies and original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TMagicSanctuaryOverlayHS = class;
  TMagicSanctuary = class;
  TMagicSanctuaryResource = class;


  { TMagicSanctuaryOverlayHS (instance size 20, VMT 557D404C):
    $0C FStructure; $10 FFadeEndFrame. }
  TMagicSanctuaryOverlayHS = class(TSingleHS)
  public
    FStructure: TMagicSanctuary; { $0C }
    FFadeEndFrame: Integer; { $10 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure FadeUp;
  end;

  { TMagicSanctuary (instance size 52, VMT 557D41F4): $30 FOverlayHS. }
  TMagicSanctuary = class(TStructure)
  public
    FOverlayHS: TMagicSanctuaryOverlayHS; { $30 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure ArmyPlaced(A1: TArmyHS); override;
  end;

  { TMagicSanctuaryResource (instance size 100, VMT 557D4464) }
  TMagicSanctuaryResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMagicSanctuary(AEngine: TEngine);

implementation

type
  PAoWHSMap = ^TAoWHSMap;
  PBlendTables = ^TLookupBlendTableCollection100;
const
  WorldMap: PAoWHSMap = @AoWE.AoWHSMap;
  BlendTables: PBlendTables = @GFXE.IntensityBlendTable;

constructor TMagicSanctuaryOverlayHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FFadeEndFrame := -1;
end;

function TMagicSanctuaryOverlayHS.GetShowPriority: Integer;
begin
  Result := FStructure.GetShowPriority + $08000000;
end;

procedure TMagicSanctuaryOverlayHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  FrameIndex, Blend, Xhp, Yhp, FramesLeft: Integer;
begin
  HXtoHP(FStructure.FXhx, FStructure.FYhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  Sequence := FStructure.FResource.ImageSequenceList.GetImageSequence(19);
  if Sequence <> nil then
  begin
    Blend := 50;
    if (FFadeEndFrame <> -1) and (FFadeEndFrame > WorldMap^.Frame) then
    begin
      FramesLeft := FFadeEndFrame - WorldMap^.Frame;
      if FramesLeft <= 20 then
        Inc(Blend, (10 - Abs(FramesLeft - 10)) * 3)
      else FFadeEndFrame := -1;
    end
    else FFadeEndFrame := -1;
    FrameIndex := Sequence.GetFrameIndex(0, 0);
    Sequence.ImageLibrary.Images[FrameIndex].ShowBlended(
      XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift,
      SurfaceDesc, BlendTables^.LookupTables[Blend]);
  end;
end;

procedure TMagicSanctuaryOverlayHS.FadeUp;
begin
  FFadeEndFrame := WorldMap^.Frame + 20;
end;

constructor TMagicSanctuary.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FOverlayHS := TMagicSanctuaryOverlayHS.Create(nil);
  FOverlayHS.FStructure := Self;
end;

destructor TMagicSanctuary.Destroy;
begin
  WorldMap^.DynamicVisibleHS.RemoveChild(FOverlayHS);
  FOverlayHS.Free;
  inherited Destroy;
end;

class function TMagicSanctuary.ClassID: Integer;
begin Result := $2089A; end;

procedure TMagicSanctuary.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    inherited MakeVisible(VisibilityList);
    FOverlayHS.MakeVisible(VisibilityList);
  end;
end;

procedure TMagicSanctuary.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.GetTerrain(Msg.HN) >= 0 then
    if Msg.MsgID = $1129 then Msg.Param[0] := 1;
end;

procedure TMagicSanctuary.ArmyPlaced(A1: TArmyHS);
begin
  inherited ArmyPlaced(A1);
  FOverlayHS.FadeUp;
end;

constructor TMagicSanctuaryResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := False;
  FRazeable := False;
  FConnectRoads := False;
end;

class function TMagicSanctuaryResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@MagicSanctuaryRStr)); end;

class function TMagicSanctuaryResource.ClassID: Integer;
begin Result := $2089B; end;

function TMagicSanctuaryResource.ResourceUserClassID: Integer;
begin Result := $2089A; end;

procedure RegisterMagicSanctuary(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TMagicSanctuary, TMagicSanctuaryResource]);
end;


initialization
finalization

end.
