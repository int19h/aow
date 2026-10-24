unit AoWControl;

{ The AoWControl unit of aowInt.dpl: TAOWControl, the ancestor of the controls that sit in a
  window (buttons, edits, lists, scroll bars, ...). It knows its window and shows its tool tip. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWToolTip, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin;

type
  { AoWControl.TAOWControl (instance size 276). Fields: +$104 FToolTipText, +$108 FToolTipShown
    (updates the tool tip has been visible), +$10C FAOWWindow, +$110 FToolTip }
  TAOWControl = class(TAoWComponent)
  public
    FToolTipText: TStringList;
    FToolTipShown: Integer;
    FAOWWindow: TAOWBaseWindow;
    FToolTip: TAOWToolTip;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Update; override;
    procedure SetOwner(Value: TAoWComponent); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure SetAOWWindow(Value: TAOWBaseWindow);
    procedure SetToolStrings(Value: TStringList);
  published
    property Priority;
    property WinLeft;
    property WinTop;
    property AOWWindow: TAOWBaseWindow read FAOWWindow write SetAOWWindow;
    property ToolTip: TAOWToolTip read FToolTip write FToolTip;
    property ToolTipText: TStringList read FToolTipText write SetToolStrings;
    property CaptureInput;
    property Alignment;
    property Masked;
  end;

implementation


{ TAOWControl }

constructor TAOWControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FToolTipText := TStringList.Create;
  FCaptureInput := True;
end;

destructor TAOWControl.Destroy;
begin
  FToolTipText.Destroy;
  inherited Destroy;
end;

procedure TAOWControl.SetAOWWindow(Value: TAOWBaseWindow);
begin
  SetOwner(Value);
end;

procedure TAOWControl.SetOwner(Value: TAoWComponent);
begin
  inherited SetOwner(Value);
  FAOWWindow := TAOWBaseWindow(FAOWOwner);
end;

procedure TAOWControl.SetToolStrings(Value: TStringList);
var
  I: Integer;
begin
  FToolTipText.Clear;
  for I := 0 to Value.Count - 1 do
    FToolTipText.Add(Value[I]);
end;

{ Update counts the tool tip delay and shows or hides the tool tip, and asks the owner to redraw
  the control's old and new places when it moved, changed size or became hidden. FOldRect holds
  the place of the last update as (Left, Top, Width, Height); the rectangles to redraw are in the
  coordinates of the window manager (the owner's position is added unless the owner is the
  manager's direct child... of a window placed in the manager) }
procedure TAOWControl.Update;
var
  R: TRect;
  W: TAOWBaseWindow;
begin { Tried Self/field casts, receiver scope and receiver/local staging; Self/temporary registers still differ. }
  if FValid then
    if FVisible then
    begin
      inherited Update;
      if FToolTip <> nil then
        if FToolTipCount > 0 then
        begin
          if (FToolTipShown > 0) and (FMouseIn = True) and (FToolTip.FShowDuration > 0) then
            if FToolTipShown < FToolTip.FShowDuration then
              Inc(FToolTipShown)
            else
            begin
              if not FToolTip.FToolTipStatic and (FToolTip <> nil) then
                FToolTip.SetVisible(False);
              FToolTipShown := 0;
            end;
          if FToolTip.FToolTipDelay > FToolTipCount then
            Inc(FToolTipCount)
          else if (FToolTipText.Count > 0) and (FMouseIn = False) then
          begin
            FToolTip.SetFStrings(FToolTipText);
            if not FToolTip.FToolTipStatic then
            begin
              FToolTip.SetVisible(True);
              FAOWWindow.FRedraw := True;
              FToolTip.FSized := False;
            end;
            W := FAOWWindow;
            while W.FAOWOwner is TAOWBaseWindow do
              W := TAOWBaseWindow(W.FAOWOwner);
            if FAOWWindow <> W then
              FToolTip.FControlRect := Rect(FAOWWindow.FWinLeft + W.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + W.FWinTop + FWinTop,
                FAOWWindow.FWinLeft + W.FWinLeft + FToolTipLeft,
                FAOWWindow.FWinTop + W.FWinTop + FWinTop + FWinHeight)
            else
              FToolTip.FControlRect := Rect(FAOWWindow.FWinLeft + FWinLeft,
                FAOWWindow.FWinTop + FWinTop, FAOWWindow.FWinLeft + FToolTipLeft,
                FAOWWindow.FWinTop + FWinTop + FWinHeight);
            FMouseIn := True;
            FToolTipShown := 1;
          end;
        end
        else if FMouseIn = True then
        begin
          if not FToolTip.FToolTipStatic and (FToolTip <> nil) then
            FToolTip.SetVisible(False);
          FMouseIn := False;
        end;
      if (FOldRect.Right > 0) and (FOldRect.Bottom > 0) and ((FOldRect.Left <> FWinLeft) or
        (FOldRect.Top <> FWinTop) or (FOldRect.Right <> FWinWidth) or
        (FOldRect.Bottom <> FWinHeight)) then
      begin
        if FAOWOwner.FAOWOwner.FAOWOwner = nil then
          R := Rect(FOldRect.Left, FOldRect.Top, FOldRect.Left + FOldRect.Right - 1,
            FOldRect.Top + FOldRect.Bottom - 1)
        else
          R := Rect(FAOWOwner.FWinLeft + FOldRect.Left, FAOWOwner.FWinTop + FOldRect.Top,
            FAOWOwner.FWinLeft + FOldRect.Left + FOldRect.Right - 1,
            FAOWOwner.FWinTop + FOldRect.Top + FOldRect.Bottom - 1);
        FAOWOwner.AddDrawRect(R, Self);
        FDrawn := False;
      end
      else if FMasked and not FDrawn then
      begin
        if FAOWOwner.FAOWOwner.FAOWOwner = nil then
          R := Rect(FWinLeft, FWinTop, FWinLeft + FWinWidth - 1, FWinTop + FWinHeight - 1)
        else
          R := Rect(FAOWOwner.FWinLeft + FWinLeft, FAOWOwner.FWinTop + FWinTop,
            FAOWOwner.FWinLeft + FWinLeft + FWinWidth - 1,
            FAOWOwner.FWinTop + FWinTop + FWinHeight - 1);
        FAOWOwner.AddDrawRect(R, Self);
      end;
      if not FDrawn then
      begin
        if FAOWOwner.FAOWOwner.FAOWOwner = nil then
          R := Rect(FWinLeft, FWinTop, FWinLeft + FWinWidth - 1, FWinTop + FWinHeight - 1)
        else
          R := Rect(FAOWOwner.FWinLeft + FWinLeft, FAOWOwner.FWinTop + FWinTop,
            FAOWOwner.FWinLeft + FWinLeft + FWinWidth - 1,
            FAOWOwner.FWinTop + FWinTop + FWinHeight - 1);
        FAOWOwner.InvalidateRect(FAOWOwner.FChildren.IndexOf(Self), R, Self);
      end;
      FOldRect.Left := FWinLeft;
      FOldRect.Top := FWinTop;
      FOldRect.Right := FWinWidth;
      FOldRect.Bottom := FWinHeight;
    end
    else if FHidden then
    begin
      if FAOWOwner.FAOWOwner.FAOWOwner = nil then
        R := Rect(FWinLeft, FWinTop, FWinLeft + FWinWidth - 1, FWinTop + FWinHeight - 1)
      else
        R := Rect(FAOWOwner.FWinLeft + FWinLeft, FAOWOwner.FWinTop + FWinTop,
          FAOWOwner.FWinLeft + FWinLeft + FWinWidth - 1,
          FAOWOwner.FWinTop + FWinTop + FWinHeight - 1);
      FAOWOwner.AddDrawRect(R, Self);
      FHidden := False;
    end;
end;

procedure TAOWControl.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if FToolTip <> nil then
  begin
    FToolTip.SetVisible(False);
    FToolTipShown := FToolTip.FShowDuration;
    FMouseIn := True;
    FToolTipCount := FToolTip.FToolTipDelay;
  end;
end;

procedure TAOWControl.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin { Tried Self/coordinate identities and receiver scope; Y/sum registers still differ. }
  if (X < FAOWWindow.FWinLeft + FWinLeft) or (X > FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) or
    (Y < FAOWWindow.FWinTop + FWinTop) or (Y > FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
    FToolTipCount := 0
  else if (FToolTip <> nil) and (FToolTip.FToolTipDelay > FToolTipCount) then
  begin
    FToolTipLeft := X - FAOWWindow.FWinLeft;
    FToolTipCount := 1;
  end;
end;

end.
