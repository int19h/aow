unit AoWImage;

{ The AoWImage unit of aowInt.dpl: TAOWImage, a control that shows one image of an image
  library as a texture filling its rectangle, or plays the images AnimStart..AnimEnd as an
  animation, one image every AnimFrameDelay updates. Its mouse events get coordinates relative
  to the control. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AoWWinGeneric,
  AOWToolTip, AoWControl;

type
  { AoWImage.TAOWImage (instance size 304). Fields: +$114 FAnimate, +$118 FAnimFrameDelay, +$11C
    FFrameCount (updates left until the next image), +$120 FAnimStart, +$124 FCurrentImage, +$128
    FAnimEnd, +$12C FImageLib }
  TAOWImage = class(TAOWControl)
  public
    FAnimate: Boolean;
    FAnimFrameDelay: Integer;
    FFrameCount: Integer;
    FAnimStart: Integer;
    FCurrentImage: Integer;
    FAnimEnd: Integer;
    FImageLib: TInterfaceIL;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILB(Value: TInterfaceIL);
    procedure SetAnim(Value: Boolean);
    procedure SetStart(Value: Integer);
    procedure SetCurrent(Value: Integer);
    procedure SetEnd(Value: Integer);
  published
    property ImageLib: TInterfaceIL read FImageLib write SetILB;
    property AnimStart: Integer read FAnimStart write SetStart;
    property CurrentImage: Integer read FCurrentImage write SetCurrent;
    property AnimEnd: Integer read FAnimEnd write SetEnd;
    property WinWidth;
    property WinHeight;
    property Animate: Boolean read FAnimate write SetAnim;
    property AnimFrameDelay: Integer read FAnimFrameDelay write FAnimFrameDelay;
  end;

procedure Register;

implementation

{ TAOWImage }

procedure TAOWImage.SetILB(Value: TInterfaceIL);
begin
  if Value <> FImageLib then
  begin
    FValid := False;
    FImageLib := Value;
  end;
end;

procedure TAOWImage.Validate;
begin
  if FImageLib <> nil then
    if FAnimate then
      FImageLib := FImageLib.CheckIL(FAnimStart, FAnimEnd + 1 - FAnimStart, Self)
    else
      FImageLib := FImageLib.CheckIL(FCurrentImage, 1, Self);
  if FImageLib <> nil then
    FValid := True;
  inherited Validate;
end;

procedure TAOWImage.SetSize;
begin
  if FWinWidth = 0 then
    FWinWidth := FImageLib[FCurrentImage].Width;
  if FWinHeight = 0 then
    FWinHeight := FImageLib[FCurrentImage].Height;
  inherited SetSize;
end;

procedure TAOWImage.SetAnim(Value: Boolean);
begin
  if Value <> FAnimate then
  begin
    FAnimate := Value;
    FValid := False;
  end;
end;

procedure TAOWImage.SetStart(Value: Integer);
begin
  if Value < 0 then
    Value := 0;
  if Value <> FAnimStart then
  begin
    FAnimStart := Value;
    FValid := False;
  end;
end;

procedure TAOWImage.SetCurrent(Value: Integer);
begin
  if Value < FAnimStart then
    Value := FAnimStart;
  if Value <> FCurrentImage then
  begin
    FCurrentImage := Value;
    FDrawn := False;
  end;
end;

procedure TAOWImage.SetEnd(Value: Integer);
begin
  if Value <> FAnimEnd then
  begin
    FAnimEnd := Value;
    FValid := False;
  end;
end;

procedure TAOWImage.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FImageLib.DrawILT(FCurrentImage, Rect(FAOWWindow.FWinLeft + FWinLeft,
        FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWImage.Update;
var
  I: Integer;
begin
  if FVisible and (FAnimate = True) then
    if FFrameCount > 0 then
      Dec(FFrameCount)
    else
    begin
      FFrameCount := FAnimFrameDelay;
      I := FCurrentImage + 1;
      if I > FAnimEnd then
        I := FAnimStart;
      SetCurrent(I);
    end;
  inherited Update;
end;

procedure TAOWImage.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X - FAOWWindow.FWinLeft - FWinLeft,
        Y - FAOWWindow.FWinTop - FWinTop);
  end;
end;

procedure TAOWImage.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  FRedraw := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWImage.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X - FAOWWindow.FWinLeft - FWinLeft, Y - FAOWWindow.FWinTop - FWinTop);
  end;
end;

procedure TAOWImage.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWImage]);
end;

end.
