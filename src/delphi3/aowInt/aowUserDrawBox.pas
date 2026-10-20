unit aowUserDrawBox;

{ The aowUserDrawBox unit of aowInt.dpl: TaowUserDrawBox, an empty control that its owner draws
  in OnPreDraw and OnDraw; its mouse events get coordinates relative to the control. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AoWWinGeneric,
  AOWToolTip, AoWControl;

type
  { aowUserDrawBox.TaowUserDrawBox (instance size 276): no fields of its own }
  TaowUserDrawBox = class(TAOWControl)
  public
    procedure Validate; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
  published
    property WinWidth;
    property WinHeight;
  end;

procedure Register;

implementation

{ TaowUserDrawBox }

procedure TaowUserDrawBox.Validate;
begin
  FValid := True;
  inherited Validate;
end;

procedure TaowUserDrawBox.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TaowUserDrawBox.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TaowUserDrawBox.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := FCaptureInput;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TaowUserDrawBox.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TaowUserDrawBox.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TaowUserDrawBox]);
end;

end.
