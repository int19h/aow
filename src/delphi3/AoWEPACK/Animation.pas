unit Animation;

{ Draft declarations of Animation, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAnimation = class;
  TAnimationTE = class;
  TImageSequenceAnimation = class;
  TTwinkleAnimation = class;

  TAnimationControlMode = set of (amLinkToNewFrame, amFixedVisible, amSelectable, amSaveable, amOwnedByMap, amLinkToOnDestroy); { ot=1 }
  TAnimationState = set of (asVisible, asEditMode, asSelected, asLinkedToTE, asActivated, asPlaced); { ot=1 }
  TShowAnimationEvent = procedure(Animation: TAnimation; XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc) of object;
  TNewFrameAnimationEvent = procedure(Animation: TAnimation; FrameCounter: Integer) of object;
  TAnimationTEState = (atIdle, atPlaying, atDone);  { ot=1 }
  TTwinkleMode = set of (tmRotate, tmExpand, tmExplode, tmImplode); { ot=1 }

  { TAnimation (instance size 60, VMT 557FAEA0) }
  TAnimation = class(THexagonSprite)
  public
    F_Animation_08: Byte;
    F_Animation_09: Byte;
    F_Animation_0A: Byte;
    F_Animation_0B: array[0..0] of Byte;
    F_Animation_0C: Byte;
    F_Animation_0D: array[0..2] of Byte;
    F_Animation_10: Integer;
    F_Animation_14: Byte;
    F_Animation_15: array[0..2] of Byte;
    F_Animation_18: Integer;
    F_Animation_1C: Integer;
    F_Animation_20: Integer;
    F_Animation_24: Byte;
    F_Animation_25: array[0..0] of Byte;
    F_Animation_26: Word;
    F_Animation_28: Integer;
    F_Animation_2C: Byte;
    F_Animation_2D: array[0..0] of Byte;
    F_Animation_2E: Word;
    F_Animation_30: Integer;
    F_Animation_34: Integer;
    F_Animation_38: Integer;
    destructor Destroy; override;
    function GetControlStyle: Engine.TEControlStyles; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetSelected: Boolean; override;
    function GetXhx: Shortint; override;
    function GetYhx: Shortint; override;
    function GetLhx: Shortint; override;
    function GetEditMode: Boolean; override;
    procedure SetEditMode(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure Select; override;
    procedure Unselect; override;
    procedure AnimationControlMode; virtual;  { +108 draft }
    procedure PlaceTE; virtual;  { +10C draft }
    procedure RemoveTE; virtual;  { +110 draft }
    procedure ExecuteTE; virtual;  { +114 draft }
    procedure CanPlace(A1: Integer; A2: Byte; A3: Integer; A4: Integer); virtual;  { +118 draft }
    procedure PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +11C draft }
    procedure NewFrame; virtual;  { +120 draft }
    procedure DestroyEvent;  { draft }
    procedure NewFrameEvent;  { draft }
    procedure SetDimensions(A1: Integer);  { draft }
  end;

  { TAnimationTE (instance size 24, VMT 557FB074) }
  TAnimationTE = class(TTokenEvent)
  public
    F_AnimationTE_10: Byte;
    F_AnimationTE_11: array[0..2] of Byte;
    F_AnimationTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Initialize(A1: Integer);  { draft }
  end;

  { TImageSequenceAnimation (instance size 80, VMT 557FB13C) }
  TImageSequenceAnimation = class(TAnimation)
  public
    F_ImageSequenceAnimation_3C: Integer;
    F_ImageSequenceAnimation_40: Integer;
    F_ImageSequenceAnimation_44: Integer;
    F_ImageSequenceAnimation_48: Integer;
    F_ImageSequenceAnimation_4C: Byte;
    F_ImageSequenceAnimation_4D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure NewFrame; override;
    procedure UpdateDimensions;  { draft }
    procedure SetImageSequence(A1: Integer);  { draft }
    procedure SetXhpOffset(A1: Integer);  { draft }
    procedure SetYhpOffset(A1: Integer);  { draft }
  end;

  { TTwinkleAnimation (instance size 84, VMT 557FB340) }
  TTwinkleAnimation = class(TAnimation)
  public
    F_TwinkleAnimation_3C: Integer;
    F_TwinkleAnimation_40: Integer;
    F_TwinkleAnimation_44: Integer;
    F_TwinkleAnimation_48: Integer;
    F_TwinkleAnimation_4C: Integer;
    F_TwinkleAnimation_50: Byte;
    F_TwinkleAnimation_51: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
  end;


implementation

constructor TAnimation.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAnimation.Destroy;
begin end;

procedure TAnimation.DestroyEvent;
begin end;

class function TAnimation.ClassID: Integer;
begin Result := 0; end;

procedure TAnimation.NewFrameEvent;
begin end;

function TAnimation.GetControlStyle: Engine.TEControlStyles;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAnimation.AnimationControlMode;
begin end;

procedure TAnimation.Activate;
begin end;

procedure TAnimation.Deactivate;
begin end;

function TAnimation.GetLevel: Byte;
begin Result := 0; end;

function TAnimation.GetShowPriority: Integer;
begin Result := 0; end;

procedure TAnimation.SetVisible(Value: Boolean);
begin end;

function TAnimation.GetVisible: Boolean;
begin Result := False; end;

procedure TAnimation.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

function TAnimation.GetEditMode: Boolean;
begin Result := False; end;

procedure TAnimation.SetEditMode(Value: Boolean);
begin end;

procedure TAnimation.Select;
begin end;

procedure TAnimation.Unselect;
begin end;

function TAnimation.GetSelected: Boolean;
begin Result := False; end;

procedure TAnimation.SetDimensions(A1: Integer);
begin end;

function TAnimation.GetXhx: Shortint;
begin Result := 0; end;

function TAnimation.GetYhx: Shortint;
begin Result := 0; end;

function TAnimation.GetLhx: Shortint;
begin Result := 0; end;

procedure TAnimation.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAnimation.PlaceTE;
begin end;

procedure TAnimation.RemoveTE;
begin end;

procedure TAnimation.ExecuteTE;
begin end;

procedure TAnimation.NewFrame;
begin end;

procedure TAnimation.CanPlace(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TAnimation.Connect;
begin end;

procedure TAnimation.Disconnect;
begin end;

function TAnimation.Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin Result := False; end;

procedure TAnimation.PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAnimation.Remove;
begin end;

procedure TAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TAnimationTE.ClassID: Integer;
begin Result := 0; end;

procedure TAnimationTE.Initialize(A1: Integer);
begin end;

procedure TAnimationTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TAnimationTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TImageSequenceAnimation.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TImageSequenceAnimation.UpdateDimensions;
begin end;

procedure TImageSequenceAnimation.SetImageSequence(A1: Integer);
begin end;

procedure TImageSequenceAnimation.SetXhpOffset(A1: Integer);
begin end;

procedure TImageSequenceAnimation.SetYhpOffset(A1: Integer);
begin end;

procedure TImageSequenceAnimation.NewFrame;
begin end;

procedure TImageSequenceAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TTwinkleAnimation.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TTwinkleAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TTwinkleAnimation.Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;


initialization
finalization

end.
