unit TurnButton;

{ TurnButton from AOWTools.dpl: recovered from the original code and RTTI.
  Class layouts and VMT order follow the shipped module. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWControl;

type
  TAOWTurnButton = class;

  TButtonType = (btText, btIcon);  { ot=1 }

  { TAOWTurnButton: instance size $144; $114 library, $118 current player, $11C last player,
    $120 animating, $124 animation phase, $128 frame offset, $12C done event,
    $134 change event, $13C checked, $140 animation frame. }
  TAOWTurnButton = class(TAOWControl)
  public
    FImageLib: TImageLibrary; { $114 }
    FCurPlayer: Integer; { $118 }
    FLastPlayer: Integer; { $11C }
    FAnimating: Boolean; { $120 }
    FAnimationPhase: Integer; { $124 }
    FFrameOffset: Integer; { $128 }
    FOnAnimDone: TNotifyEvent; { $12C }
    FOnPlayerChange: TNotifyEvent; { $134 }
    FButtonChecked: Boolean; { $13C }
    FAnimationFrame: Integer; { $140 }
    constructor Create(AOwner: Classes.TComponent); override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: GFXE.TSurfaceDesc); override;
    procedure CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure SetILB(Value: TImageLibrary); virtual;
  published
    property ImageLib: TImageLibrary read FImageLib write SetILB;
    property CurPlayer: Integer read FCurPlayer write FCurPlayer;
    property LastPlayer: Integer read FLastPlayer write FLastPlayer;
    property Animating: Boolean read FAnimating write FAnimating;
    property OnAnimDone: TNotifyEvent read FOnAnimDone write FOnAnimDone;
    property OnChange: TNotifyEvent read FOnPlayerChange write FOnPlayerChange;
    property Checked: Boolean read FButtonChecked write FButtonChecked;
  end;

procedure Register;

implementation

constructor TAOWTurnButton.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FFrameOffset := 11;
end;

procedure TAOWTurnButton.Validate;
begin
  if FImageLib <> nil then FValid := True;
  inherited Validate;
end;

procedure TAOWTurnButton.SetSize;
begin
  FWinWidth := FImageLib[0].Width;
  FWinHeight := FImageLib[0].Height;
  inherited SetSize;
end;

procedure TAOWTurnButton.SetILB(Value: TImageLibrary);
begin
  if Value <> nil then FImageLib := Value
  else FImageLib := nil;
end;

procedure TAOWTurnButton.Update;
begin
  inherited Update;
  if FVisible then
    case FAnimationPhase of
      0:
        if FLastPlayer <> FCurPlayer then
        begin
          FAnimationFrame := FLastPlayer * 7;
          FFrameOffset := 11;
          FAnimationPhase := 1;
          FAnimating := True;
          FDrawn := False;
        end;
      1:
        begin
          Inc(FAnimationFrame);
          FDrawn := False;
          if FLastPlayer * 7 + 5 < FAnimationFrame then
          begin
            FAnimationFrame := 0;
            FAnimationPhase := 2;
            FFrameOffset := 0;
          end;
        end;
      2:
        begin
          Inc(FAnimationFrame);
          FDrawn := False;
          if FAnimationFrame > 10 then
          begin
            FAnimationPhase := 3;
            FAnimationFrame := FCurPlayer * 7 + 5;
            FFrameOffset := 11;
          end;
        end;
      3:
        begin
          Dec(FAnimationFrame);
          FDrawn := False;
          if FCurPlayer * 7 > FAnimationFrame then
          begin
            FAnimationFrame := FCurPlayer * 7;
            FAnimationPhase := 0;
            FFrameOffset := 11;
            FLastPlayer := FCurPlayer;
            FAnimating := False;
            if Assigned(FOnAnimDone) then FOnAnimDone(Self);
          end;
        end;
    end;
end;

procedure TAOWTurnButton.Draw(SurfDesc: GFXE.TSurfaceDesc);
begin
  try
    if (FVisible = True) and (FValid = True) then
    begin
      if Assigned(FOnPreDraw) then FOnPreDraw(Self, SurfDesc);
      if not FAnimating and (FButtonChecked = True) then
        FImageLib[FFrameOffset + FCurPlayer * 7 + 6].ShowClipped(
          FAOWWindow.FWinLeft + FWinLeft, FAOWWindow.FWinTop + FWinTop, SurfDesc)
      else
        FImageLib[FFrameOffset + FAnimationFrame].ShowClipped(
          FAOWWindow.FWinLeft + FWinLeft, FAOWWindow.FWinTop + FWinTop, SurfDesc);
      if Assigned(FOnDraw) then FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWTurnButton.CheckMouseDown(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if (Button = mbLeft) and not FAnimating then
    begin
      if FButtonChecked then FButtonChecked := False else FButtonChecked := True;
      FDrawn := False;
      if Assigned(FOnPlayerChange) then FOnPlayerChange(Self);
      if Assigned(FOnMouseDown) then FOnMouseDown(Self, Button, Shift, X, Y);
    end;
  end;
end;

procedure TAOWTurnButton.CheckMouseUp(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWTurnButton.CheckMouseMove(Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (X >= FAOWWindow.FWinLeft + FWinLeft) and (X <= FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) and
    (Y >= FAOWWindow.FWinTop + FWinTop) and (Y <= FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
  begin
    FHandled := True;
    if Assigned(FOnMouseMove) then FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Tools', [TAOWTurnButton]);
end;


initialization
finalization

end.
