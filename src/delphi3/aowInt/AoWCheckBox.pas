unit AoWCheckBox;

{ The AoWCheckBox unit of aowInt.dpl: TAOWCheckBox, a button that toggles its down state
  (Checked) on a left click; with a RadioIndex above 0 it is a radio button, which only turns
  on, and its window turns off the other radio buttons of the group (RadioChange). A right
  click opens its PopupMenu at the mouse, kept inside the window manager. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWButton, AOWMenuBar, AOWMenu, AOWToolTip, AoWControl, AOWWinManager,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  { AoWCheckBox.TAOWCheckBox (instance size 320). Fields: +$138 FOnDoubleClick.
    VMT (new): SetChecked }
  TAOWCheckBox = class(TAOWBaseButton)
  public
    FOnDoubleClick: TNotifyEvent;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetChecked(Value: Boolean); virtual;
  published
    property Checked: Boolean read FChecked write SetChecked;
    property OnChange;
    property RadioIndex: Integer read FRadioIndex write FRadioIndex;
    property OnDoubleClick: TNotifyEvent read FOnDoubleClick write FOnDoubleClick;
  end;

procedure Register;

implementation

{ TAOWCheckBox }

procedure TAOWCheckBox.SetChecked(Value: Boolean);
begin
  if Value <> FChecked then
  begin
    FChecked := Value;
    FDrawn := False;
    if FRadioIndex > 0 then
      if FAOWWindow <> nil then
        if FChecked then
          FAOWWindow.RadioChange(Self);
  end;
end;

procedure TAOWCheckBox.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  FLit := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) and
    (FValid = True) and (FVisible = True) then
  begin
    FHandled := True;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
    if Button = mbLeft then
    begin
      if FRadioIndex > 0 then
      begin
        if not FChecked then
        begin
          FChecked := True;
          if Assigned(FOnChange) then
            FOnChange(Self);
          FChecked := not FChecked;
          Checked := not FChecked;
        end;
      end
      else
      begin
        FChecked := not FChecked;
        if Assigned(FOnChange) then
          FOnChange(Self);
        FChecked := not FChecked;
        Checked := not FChecked;
      end;
      if Shift * [ssDouble] = [ssDouble] then
        if Assigned(FOnDoubleClick) then
          FOnDoubleClick(Self);
    end
    else if (Button = mbRight) and (FPopupMenu <> nil) then
    begin
      FPopupMenu.WinLeft := X;
      FPopupMenu.WinTop := Y;
      FPopupMenu.SetPopupOwner(Self);
      if FPopupMenu.FWinManager <> nil then
      begin
        if FPopupMenu.FWinLeft + FPopupMenu.FWinWidth > FPopupMenu.FWinManager.FWinWidth then
          FPopupMenu.FWinLeft := X - FPopupMenu.FWinWidth;
        if FPopupMenu.FWinTop + FPopupMenu.FWinHeight > FPopupMenu.FWinManager.FWinHeight then
          FPopupMenu.FWinTop := Y - FPopupMenu.FWinHeight;
      end;
      FPopupMenu.Visible := True;
    end;
  end;
end;

procedure TAOWCheckBox.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  FLit := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) and
    (FValid = True) and (FVisible = True) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWCheckBox.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  OldLit: Boolean;
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  OldLit := FLit;
  if (X < FAOWWindow.FWinLeft + FWinLeft) or (X > FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) or
    (Y < FAOWWindow.FWinTop + FWinTop) or (Y > FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
    FLit := False
  else
  begin
    FHandled := True;
    FLit := not FChecked and not FAOWOwner.FHandled;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
  FRedraw := FLit;
  if OldLit <> FLit then
    FDrawn := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWCheckBox]);
end;

end.
