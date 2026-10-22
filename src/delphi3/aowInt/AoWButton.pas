unit AoWButton;

{ The AoWButton unit of aowInt.dpl: TAOWBaseButton, the common ancestor of the push button and
  the check box, which draws itself from a button library (three images: the left end, the
  middle and the right end of a horizontal line) or from an icon library (one image), in the up,
  down or lit (mouse over) state, with its text centred on it; and TAOWButton, the push button,
  which calls OnClick when the left button is released over it. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWMenuBar, AOWMenu, AOWToolTip, AoWControl, AOWWinManager, AoWComp,
  AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  { AoWButton.TAOWBaseButton (instance size 312). Fields: +$114 FBorderHeightSelected (the text
    offset from the top when the button is down; FBorderHeight when it is up), +$118 FButtonType
    (btText: drawn from FILButton, btIcon: from FILIcon; set by Validate), +$11C FILButton, +$120
    FILIcon, +$124 FILIndexUp, +$128 FILIndexDown, +$12C FILIndexLit, +$130 FPopupMenu, +$134
    FLit (the mouse is over the button). FChecked (+$B0) is the down state.
    VMT (new): SetILButton, SetILIcon, SetILUIndex, SetILDIndex, SetILHIndex }
  TAOWBaseButton = class(TAOWControl)
  public
    FBorderHeightSelected: Integer;
    FButtonType: TButtonType;
    FILButton: TInterfaceIL;
    FILIcon: TInterfaceIL;
    FILIndexUp: Integer;
    FILIndexDown: Integer;
    FILIndexLit: Integer;
    FPopupMenu: TAOWMenu;
    FLit: Boolean;
    procedure Validate; override;
    procedure SetSize; override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure SetILButton(Value: TInterfaceIL); virtual;
    procedure SetILIcon(Value: TInterfaceIL); virtual;
    procedure SetILUIndex(Value: Integer); virtual;
    procedure SetILDIndex(Value: Integer); virtual;
    procedure SetILHIndex(Value: Integer); virtual;
    procedure SetGText(Value: string);
  published
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property BorderHeightSelected: Integer read FBorderHeightSelected write FBorderHeightSelected;
    property ILButton: TInterfaceIL read FILButton write SetILButton;
    property ILIcon: TInterfaceIL read FILIcon write SetILIcon;
    property ILIndexDown: Integer read FILIndexDown write SetILDIndex;
    property ILIndexLit: Integer read FILIndexLit write SetILHIndex;
    property ILIndexUp: Integer read FILIndexUp write SetILUIndex;
    property PopupMenu: TAOWMenu read FPopupMenu write FPopupMenu;
    property Text: string read FText write SetGText;
    property TextColor;
    property TextSelColor;
    property WinWidth;
  end;

  { AoWButton.TAOWButton (instance size 320). Fields: +$138 FOnClick }
  TAOWButton = class(TAOWBaseButton)
  public
    FOnClick: TNotifyEvent;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
  published
    property OnClick: TNotifyEvent read FOnClick write FOnClick;
  end;

procedure Register;

implementation


{ TAOWBaseButton }

procedure TAOWBaseButton.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
    FLit := False;
  inherited SetVisible(Value);
end;

procedure TAOWBaseButton.Validate;
begin
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexUp, 3, Self);
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexDown, 3, Self);
  if (FILButton <> nil) and (FILIndexLit <> FILIndexUp) then
    FILButton := FILButton.CheckIL(FILIndexLit, 3, Self);
  if FILIcon <> nil then
    FILIcon := FILIcon.CheckIL(FILIndexUp, 1, Self);
  if FILIcon <> nil then
    FILIcon := FILIcon.CheckIL(FILIndexDown, 1, Self);
  if (FILIcon <> nil) and (FILIndexLit <> FILIndexUp) then
    FILIcon := FILIcon.CheckIL(FILIndexLit, 1, Self);
  if FILButton <> nil then
  begin
    FButtonType := btText;
    FValid := True;
  end
  else if FILIcon <> nil then
  begin
    FButtonType := btIcon;
    FValid := True;
  end;
  inherited Validate;
end;

procedure TAOWBaseButton.SetSize;
begin
  case FButtonType of
    btText:
      begin
        if FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width > FWinWidth then
          FWinWidth := FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width;
        FWinHeight := FILButton[FILIndexUp].Height;
      end;
    btIcon:
      begin
        FWinWidth := FILIcon[FILIndexUp].Width;
        FWinHeight := FILIcon[FILIndexUp].Height;
      end;
  end;
  inherited SetSize;
end;

procedure TAOWBaseButton.SetGText(Value: string);
begin
  FText := Value;
  FDrawn := False;
end;

procedure TAOWBaseButton.SetILButton(Value: TInterfaceIL);
begin
  if Value <> FILButton then
  begin
    FILIcon := nil;
    FValid := False;
    FILButton := Value;
  end;
end;

procedure TAOWBaseButton.SetILIcon(Value: TInterfaceIL);
begin
  if Value <> FILIcon then
  begin
    FILButton := nil;
    FValid := False;
    FILIcon := Value;
  end;
end;

procedure TAOWBaseButton.SetILUIndex(Value: Integer);
begin
  if Value <> FILIndexUp then
  begin
    FILIndexUp := Value;
    FValid := False;
  end;
end;

procedure TAOWBaseButton.SetILDIndex(Value: Integer);
begin
  if Value <> FILIndexDown then
  begin
    FILIndexDown := Value;
    FValid := False;
  end;
end;

procedure TAOWBaseButton.SetILHIndex(Value: Integer);
begin
  if Value <> FILIndexLit then
  begin
    FILIndexLit := Value;
    FValid := False;
  end;
end;

procedure TAOWBaseButton.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FVisible and FValid then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      if FChecked then
      begin
        if FButtonType = btText then
          FILButton.DrawILLh(FILIndexDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc)
        else
          FILIcon.DrawILI(FILIndexDown, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
        if FAOWFont <> nil then
        begin
          FAOWFont.Color := FSelColor;
          FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth div 2 -
            FAOWFont.GetTextWidth(FText) div 2, FAOWWindow.FWinTop + FWinTop +
            FBorderHeightSelected, FText, SurfDesc);
        end;
      end
      else
      begin
        if FButtonType = btText then
          if FLit then
            FILButton.DrawILLh(FILIndexLit, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc)
          else
            FILButton.DrawILLh(FILIndexUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc)
        else if FLit then
          FILIcon.DrawILI(FILIndexLit, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc)
        else
          FILIcon.DrawILI(FILIndexUp, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
        if FAOWFont <> nil then
        begin
          FAOWFont.Color := FColor;
          FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth div 2 -
            FAOWFont.GetTextWidth(FText) div 2, FAOWWindow.FWinTop + FWinTop +
            FBorderHeight, FText, SurfDesc);
        end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ TAOWButton }

procedure TAOWButton.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  FLit := False;
  if not FAOWWindow.FHandled then
    if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
      (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    begin
      FHandled := True;
      if Button = mbLeft then
      begin
        FMouseDown := True;
        FChecked := True;
        FDrawn := False;
        FRedraw := True;
      end;
      if Assigned(FOnMouseDown) then
        FOnMouseDown(Self, Button, Shift, X, Y);
    end;
end;

procedure TAOWButton.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  FChecked := False;
  FLit := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Button = mbLeft then
    begin
      if FMouseDown and Assigned(FOnClick) then
        FOnClick(Self);
      FDrawn := False;
    end;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
  if FMouseDown then
    FDrawn := False;
  FMouseDown := False;
end;

procedure TAOWButton.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  OldChecked, OldLit: Boolean;
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  OldChecked := FChecked;
  OldLit := FLit;
  FRedraw := False;
  if FAOWWindow.FHandled or (X < FAOWWindow.FWinLeft + FWinLeft) or
    (X > FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) or (Y < FAOWWindow.FWinTop + FWinTop) or
    (Y > FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
  begin
    FChecked := False;
    FLit := False;
  end
  else
  begin
    FHandled := True;
    FChecked := FMouseDown;
    FLit := not FMouseDown;
    FRedraw := True;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
  if (OldLit <> FLit) or (OldChecked <> FChecked) then
    FDrawn := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWButton]);
end;

end.
