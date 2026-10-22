unit Animation;

{ Animation from AoWEPACK.dpl, recovered against Delphi 3.02. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx;

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

  { TAnimation: size $3C; $08/$09/$0A hex position, $0B display level,
    $0C state, $10 frame, $14..$23 dimensions, $24/$2C callbacks,
    $34 tag, $38 map. VMT 557FAEA0. }
  TAnimation = class(THexagonSprite)
  public
    FXhx: Shortint; { $08 }
    FYhx: Shortint; { $09 }
    FLhx: Shortint; { $0A }
    FAnimationLevel: Byte; { $0B }
    FState: TAnimationState; { $0C }
    FFrameCounter: Integer; { $10 }
    FDimensions: TRect; { $14 }
    FOnShow: TShowAnimationEvent; { $24 }
    { conflict: FOnShowAnimation: TShowAnimationEvent; }
    FOnNewFrame: TNewFrameAnimationEvent; { $2C }
    FTag: Integer; { $34 }
    FAnimationMap: THSMap; { $38 }
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
    class function AnimationControlMode: TAnimationControlMode; virtual; { $108; 557E2BB4 }
    function PlaceTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean; virtual; { $10C }
    function RemoveTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean; virtual; { $110 }
    function ExecuteTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean; virtual; { $114 }
    function CanPlace(Map: TMapContainer; X, Y, L: Shortint): Boolean; virtual; { $118 }
    function PlaceHX(Map: TMapContainer; X, Y, L: Shortint): Boolean; virtual; { +11C }
    procedure NewFrame; virtual; { $120 }
    procedure DestroyEvent(Sender: TObject);
    procedure NewFrameEvent(Sender: TObject);
    procedure SetDimensions(R: TRect);
  end;

  { TAnimationTE: size $18; $10 state, $14 animation. VMT 557FB074. }
  TAnimationTE = class(TTokenEvent)
  public
    FState: TAnimationTEState; { $10 }
    FAnimation: TAnimation; { $14 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Initialize(Animation: TAnimation);
  end;

  { TImageSequenceAnimation: size $50; $3C sequence, $40/$44 pixel offsets,
    $48 last frame, $4C loop flag. VMT 557FB13C. }
  TImageSequenceAnimation = class(TAnimation)
  public
    FImageSequence: TImageSequence; { $3C }
    FXhpOffset: Integer; { $40 }
    FYhpOffset: Integer; { $44 }
    FFrameCount: Integer; { $48 }
    FLooped: Boolean; { $4C }
    F_ImageSequenceAnimation_4D: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure NewFrame; override;
    procedure UpdateDimensions;
    procedure SetImageSequence(Sequence: TImageSequence);
    procedure SetXhpOffset(Value: Integer);
    procedure SetYhpOffset(Value: Integer);
  end;

  { TTwinkleAnimation: size $54; $3C sequence, $40 particle count, $44 radius,
    $48 lifetime, $4C random start delay, $50 mode. VMT 557FB340. }
  TTwinkleAnimation = class(TAnimation)
  public
    FImageSequence: TImageSequence; { $3C }
    FCount: Integer; { $40 }
    FRadius: Integer; { $44 }
    FDuration: Integer; { $48 }
    FStartDelay: Integer; { $4C }
    FMode: TTwinkleMode; { $50 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Setup(Sequence: TImageSequence; Mode: TTwinkleMode; Count, Radius, Duration, StartDelay: Integer);
  end;


implementation

uses AoWE, Pad;

constructor TAnimation.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAnimationLevel := 26;
end;

destructor TAnimation.Destroy;
begin
  inherited Destroy;
end;

procedure TAnimation.DestroyEvent(Sender: TObject);
begin
  if Owner = nil then Destroy;
end;

class function TAnimation.ClassID: Integer;
begin
  Result := $202E7;
end;

procedure TAnimation.NewFrameEvent(Sender: TObject);
begin
  NewFrame;
end;

function TAnimation.GetControlStyle: Engine.TEControlStyles;
begin
  if amSaveable in AnimationControlMode then Result := [csSaveLoad]
  else Result := [];
end;

class function TAnimation.AnimationControlMode: TAnimationControlMode;
begin
  Result := [amLinkToNewFrame, amFixedVisible, amLinkToOnDestroy];
end;

procedure TAnimation.Activate;
begin
  inherited Activate;
  FState := FState + [asActivated];
  if amLinkToNewFrame in AnimationControlMode then
    FAnimationMap.NewFrameEvents.Add(NewFrameEvent);
  if amFixedVisible in AnimationControlMode then
    FAnimationMap.DynamicFixedVisibleHS.AddChild(Self);
  if amLinkToOnDestroy in AnimationControlMode then
    FAnimationMap.DestroyEvents.Add(DestroyEvent);
end;

procedure TAnimation.Deactivate;
begin
  inherited Deactivate;
  if asActivated in FState then
  begin
    FState := FState - [asActivated];
    if amFixedVisible in AnimationControlMode then
    begin
      FAnimationMap.DynamicFixedVisibleHS.RemoveChild(Self);
      FAnimationMap.DynamicVisibleHS.RemoveChild(Self);
    end;
    if amLinkToNewFrame in AnimationControlMode then
      FAnimationMap.NewFrameEvents.Remove(NewFrameEvent);
    if amLinkToOnDestroy in AnimationControlMode then
      FAnimationMap.DestroyEvents.Remove(DestroyEvent);
  end;
end;

function TAnimation.GetLevel: Byte;
begin
  Result := FAnimationLevel;
end;

function TAnimation.GetShowPriority: Integer;
var
  X, Y: Integer;
begin
  HXtoHP(FXhx, FYhx, X, Y);
  Result := (Integer(FAnimationLevel) shl 26) + ((Y + FDimensions.Bottom) shl 13) + X;
end;

procedure TAnimation.SetVisible(Value: Boolean);
begin
  if Value then FState := FState + [asVisible]
  else FState := FState - [asVisible];
end;

function TAnimation.GetVisible: Boolean;
begin
  Result := asVisible in FState;
end;

procedure TAnimation.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (asVisible in FState) then
  begin
    FState := FState + [asVisible];
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;

function TAnimation.GetEditMode: Boolean;
begin
  Result := asEditMode in FState;
end;

procedure TAnimation.SetEditMode(Value: Boolean);
begin
  if Value then FState := FState + [asEditMode]
  else FState := FState - [asEditMode];
end;

procedure TAnimation.Select;
begin
  inherited Select;
  FState := FState + [asSelected];
end;

procedure TAnimation.Unselect;
begin
  inherited Unselect;
  FState := FState - [asSelected];
end;

function TAnimation.GetSelected: Boolean;
begin
  Result := asSelected in FState;
end;

procedure TAnimation.SetDimensions(R: TRect);
begin
  if not (asPlaced in FState) then FDimensions := R
  else raise Exception.Create('Cannot change dimensions when object is places');
end;

function TAnimation.GetXhx: Shortint;
begin
  Result := FXhx;
end;

function TAnimation.GetYhx: Shortint;
begin
  Result := FYhx;
end;

function TAnimation.GetLhx: Shortint;
begin
  Result := FLhx;
end;

procedure TAnimation.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FDimensions, SizeOf(FDimensions), 10);
  Stream.rwByte(Byte(FXhx), 11);
  Stream.rwByte(Byte(FYhx), 12);
  Stream.rwByte(Byte(FLhx), 13);
  Stream.rwInteger(FFrameCounter, 14);
end;

function TAnimation.PlaceTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean;
begin
  Result := PlaceHX(FAnimationMap.MapContainer, FXhx, FYhx, FLhx);
end;

function TAnimation.RemoveTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean;
begin
  MainRemove;
  Result := True;
end;

function TAnimation.ExecuteTE(Event: TAnimationTE; Executer: TTokenExecuter): Boolean;
begin
  Result := False;
end;

procedure TAnimation.NewFrame;
begin
  Inc(FFrameCounter);
  if Assigned(FOnNewFrame) then FOnNewFrame(Self, FFrameCounter);
end;

function TAnimation.CanPlace(Map: TMapContainer; X, Y, L: Shortint): Boolean;
begin
  if (X < 0) or (Y < 0) or (L < 0) or (X >= Map.Width) or
    (Y >= Map.Height) or (L >= Map.LevelCount) then Result := False
  else Result := True;
end;

procedure TAnimation.Connect;
var
  X, Y: Integer;
begin
  if not (asPlaced in FState) then
  begin
    HXtoHP(FXhx, FYhx, X, Y);
    if amOwnedByMap in AnimationControlMode then
      PlaceOnMapEx(FAnimationMap.MapContainer, X + FDimensions.Left,
        Y + FDimensions.Top, FLhx, X + FDimensions.Right, Y + FDimensions.Bottom)
    else
      PlaceUserOnMapEx(FAnimationMap.MapContainer, X + FDimensions.Left,
        Y + FDimensions.Top, FLhx, X + FDimensions.Right, Y + FDimensions.Bottom);
    FState := FState + [asPlaced];
  end;
end;

procedure TAnimation.Disconnect;
var
  X, Y: Integer;
begin
  if asPlaced in FState then
  begin
    HXtoHP(FXhx, FYhx, X, Y);
    if amOwnedByMap in AnimationControlMode then
      RemoveFromMapEx(X + FDimensions.Left, Y + FDimensions.Top,
        X + FDimensions.Right, Y + FDimensions.Bottom)
    else
      RemoveUserFromMapEx(FAnimationMap.MapContainer, X + FDimensions.Left,
        Y + FDimensions.Top, FLhx, X + FDimensions.Right, Y + FDimensions.Bottom);
    FState := FState - [asPlaced];
  end;
end;

function TAnimation.Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  X, Y: Integer;
begin
  HPtoHX(Xhp, Yhp, X, Y);
  Result := PlaceHX(Map, X, Y, Lhx);
end;

function TAnimation.PlaceHX(Map: TMapContainer; X, Y, L: Shortint): Boolean;
begin
  if GetEditMode or CanPlace(Map, X, Y, L) then
  begin
    FAnimationMap := Map.Map;
    Remove;
    FXhx := X;
    FYhx := Y;
    FLhx := L;
    Connect;
    Result := True;
  end
  else Result := False;
end;

procedure TAnimation.Remove;
begin
  inherited Remove;
  if GetVisible then
  begin
    if FAnimationLevel <= 15 then FAnimationMap.StaticVisibleHS.RemoveChild(Self)
    else FAnimationMap.DynamicVisibleHS.RemoveChild(Self);
    SetVisible(False);
  end;
end;

procedure TAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  if Assigned(FOnShow) then FOnShow(Self, XhpSurf, YhpSurf, SurfaceDesc);
end;

class function TAnimationTE.ClassID: Integer;
begin
  Result := $21109;
end;

procedure TAnimationTE.Initialize(Animation: TAnimation);
begin
  if FAnimation <> nil then FAnimation.Free;
  FAnimation := Animation;
end;

procedure TAnimationTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FAnimation), nil, 15);
end;

function TAnimationTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin
  Result := inherited Execute(TE);
  if FAnimation <> nil then
  begin
    if FState = atIdle then
      if FAnimation.PlaceTE(Self, TE) then FState := atPlaying
      else Result := erDoneHalt;
    if FState = atPlaying then
      if not FAnimation.ExecuteTE(Self, TE) then
      begin
        FAnimation.RemoveTE(Self, TE);
        FState := atDone;
      end;
    if FState = atDone then Result := erDone;
  end
  else Result := erDone;
end;

constructor TImageSequenceAnimation.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FFrameCount := -1;
  FXhpOffset := 0;
  FYhpOffset := 0;
end;

procedure TImageSequenceAnimation.UpdateDimensions;
var
  Sequence: TImageSequence;
  R: TRect;
begin
  FDimensions.Left := 0;
  FDimensions.Right := 0;
  FDimensions.Top := 0;
  FDimensions.Bottom := 0;
  Sequence := FImageSequence;
  while Sequence <> nil do
  begin
    Sequence.GetDimensions(R);
    UnionRect(FDimensions, FDimensions, R);
    Sequence := Sequence.Next;
  end;
  Inc(FDimensions.Left, 16);
  Inc(FDimensions.Right, 16);
  Inc(FDimensions.Top, 16);
  Inc(FDimensions.Bottom, 16);
end;

procedure TImageSequenceAnimation.SetImageSequence(Sequence: TImageSequence);
var
  Current: TImageSequence;
  Frames: Integer;
begin
  FImageSequence := Sequence;
  UpdateDimensions;
  if not FLooped then
  begin
    Current := FImageSequence;
    FFrameCount := -1;
    while Current <> nil do
    begin
      Frames := Current.GetTotalSequenceFrames;
      if Frames > FFrameCount then FFrameCount := Frames;
      Current := Current.Next;
    end;
    if FFrameCount <> -1 then Inc(FFrameCount);
  end;
end;

procedure TImageSequenceAnimation.SetXhpOffset(Value: Integer);
begin
  FXhpOffset := Value;
  UpdateDimensions;
end;

procedure TImageSequenceAnimation.SetYhpOffset(Value: Integer);
begin
  FYhpOffset := Value;
  UpdateDimensions;
end;

procedure TImageSequenceAnimation.NewFrame;
begin
  inherited NewFrame;
  if FFrameCounter = FFrameCount then Destroy;
end;

procedure TImageSequenceAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  X, Y, Index: Integer;
begin
  inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
  if GetLhx = FAnimationMap.ViewL then
  begin
    HXtoHP(FXhx, FYhx, X, Y);
    XhpSurf := X - XhpSurf + 16 + FXhpOffset;
    YhpSurf := Y - YhpSurf + 16 + FYhpOffset;
    if not FLooped then
    begin
      Sequence := FImageSequence;
      while Sequence <> nil do
      begin
        Index := Sequence.GetUnloopedFrameIndex(FFrameCounter);
        if Index <> -1 then
          if Sequence.ImageLibrary.ImageExist(Index) then
            Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift,
              YhpSurf + Sequence.dYshift, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
    end
    else
    begin
      Sequence := FImageSequence;
      while Sequence <> nil do
      begin
        Index := Sequence.GetFrameIndex(0, FFrameCounter);
        if Index <> -1 then
          Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
    end;
  end;
end;

constructor TTwinkleAnimation.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAnimationLevel := 28;
end;

procedure TTwinkleAnimation.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  OldSeed, Delay, X, Y, DX, DY, I, Radius, Angle, Index: Integer;
begin
  OldSeed := RandSeed;
  HXtoHP(FXhx, FYhx, X, Y);
  XhpSurf := X - XhpSurf + 16;
  YhpSurf := Y - YhpSurf + 16;
  RandSeed := GetXhx + AoWHSMap.FInitialRandomSeed + GetYhx * 3;
  for I := 0 to FCount - 1 do
  begin
    Radius := Random(FRadius);
    Angle := Random(360);
    Delay := Random(FStartDelay);
    if FFrameCounter - Delay >= 0 then
    begin
      if tmExpand in FMode then Radius := Round(Radius * FFrameCounter / FDuration) + Radius div 2;
      if tmExplode in FMode then Inc(Radius, Round((FFrameCounter - Delay) * (FFrameCounter - Delay)));
      if tmImplode in FMode then Inc(Radius, Round(FDuration - (FFrameCounter - Delay)));
      if tmRotate in FMode then Inc(Angle, FFrameCounter * 4);
      DegreesRadToCo(Angle, Radius, DX, DY);
      Sequence := FImageSequence;
      while Sequence <> nil do
      begin
        Index := Sequence.GetUnloopedFrameIndex(FFrameCounter - Delay);
        if Sequence.ImageLibrary.ImageExist(Index) then
          Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift + DX,
            YhpSurf + Sequence.dYshift + DY, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
    end;
  end;
  RandSeed := OldSeed;
  if FFrameCounter >= FDuration then Destroy;
end;

procedure TTwinkleAnimation.Setup(Sequence: TImageSequence; Mode: TTwinkleMode; Count, Radius, Duration, StartDelay: Integer);
begin
  FImageSequence := Sequence;
  FCount := Count;
  FRadius := Radius;
  FMode := Mode;
  FStartDelay := StartDelay;
  FDuration := Duration;
end;

initialization
finalization

end.
