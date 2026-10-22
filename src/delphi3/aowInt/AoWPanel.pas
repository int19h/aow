unit AoWPanel;

{ The AoWPanel unit of aowInt.dpl: TAOWPanel, a window inside a window (AOWWindow), drawn into
  its owner's surface. Its controls are positioned relative to it: while it updates, draws or
  passes input on, it moves itself by the window's position and restores its own position
  afterwards. A panel can belong to a tab of a TAOWTabPanel (TabPanel and OwnerItem): it is then
  visible only while its tab is selected. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWTabPanel, AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl,
  AoWBaseWin;

type
  { AoWPanel.TAOWPanel (instance size 508). Fields: +$1EC FOrgLeft, +$1F0 FOrgTop (the panel's
    own position, saved while it is moved by the window's position), +$1F4 FTabPanel, +$1F8
    FAOWWindow.
    VMT (new): SetTabPanel }
  TAOWPanel = class(TAOWBaseWindow)
  public
    FOrgLeft: Integer;
    FOrgTop: Integer;
    FTabPanel: TAOWTabPanel;
    FAOWWindow: TAOWBaseWindow;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetSize; override;
    procedure Setup; override;
    procedure Update; override;
    procedure InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent); override;
    procedure AddBltRect(var ARect: TRect; Sender: TAoWComponent); override;
    procedure AddDrawRect(var ARect: TRect; Sender: TAoWComponent); override;
    procedure SetOwner(Value: TAoWComponent); override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure DetachMenuBar; override;
    procedure SetTabPanel(Value: TAOWTabPanel); virtual;
    procedure SetAOWWindow(Value: TAOWBaseWindow);
  published
    property WinHeight;
    property AOWWindow: TAOWBaseWindow read FAOWWindow write SetAOWWindow;
    property TabPanel: TAOWTabPanel read FTabPanel write SetTabPanel;
    property ILFrame;
    property ILTexture;
    property ILIndexFrame;
    property ILIndexTexture;
    property OwnerItem: Integer read FOwnerItem write FOwnerItem;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MinHeight: Integer read FMinHeight write FMinHeight;
  end;

procedure Register;

implementation

{ TAOWPanel }

constructor TAOWPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FCaptureInput := True;
end;

destructor TAOWPanel.Destroy;
begin
  if FTabPanel <> nil then
    FTabPanel.FPanels.Delete(FTabPanel.FPanels.IndexOf(Self));
  inherited Destroy;
end;

procedure TAOWPanel.SetOwner(Value: TAoWComponent);
begin
  inherited SetOwner(Value);
  FAOWWindow := TAOWBaseWindow(FAOWOwner);
end;

procedure TAOWPanel.AddBltRect(var ARect: TRect; Sender: TAoWComponent);
begin
  FAOWOwner.AddBltRect(ARect, Self);
end;

procedure TAOWPanel.AddDrawRect(var ARect: TRect; Sender: TAoWComponent);
begin
  if FMasked then
    FAOWOwner.AddDrawRect(ARect, Self);
  if FWindowType <> winBlank then
    inherited AddDrawRect(ARect, Sender);
end;

{ InvalidateRect: the controls from Index on that ARect touches are redrawn (windows are asked to
  invalidate the rectangle themselves), then the windows above the panel in its owner }
procedure TAOWPanel.InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent);
var
  OldLeft, OldTop: Integer;
  I: Integer;
  C: TAoWComponent;
  R: TRect;
begin
  if FValid and FVisible and (FWindowType <> winBlank) then
    AddDrawRect(ARect, Sender);
  OldLeft := FWinLeft;
  OldTop := FWinTop;
  Inc(FWinLeft, FAOWOwner.FWinLeft);
  Inc(FWinTop, FAOWOwner.FWinTop);
  for I := Index to FChildren.Count - 1 do
  begin
    C := FChildren[I];
    if C.FVisible then
      if ((FWinLeft + C.FWinLeft >= ARect.Left) and (FWinLeft + C.FWinLeft <= ARect.Right) or
        (FWinLeft + C.FWinLeft <= ARect.Left) and (ARect.Left <= FWinLeft + C.FWinLeft + C.FWinWidth)) and
        ((FWinTop + C.FWinTop >= ARect.Top) and (FWinTop + C.FWinTop <= ARect.Bottom) or
        (FWinTop + C.FWinTop <= ARect.Top) and (ARect.Top <= FWinTop + C.FWinTop + C.FWinHeight)) and
        (C <> Sender) then
        if C is TAOWBaseWindow then
          TAOWBaseWindow(C).InvalidateRect(0, ARect, Self)
        else if C.FDrawn then
        begin
          C.FDrawn := False;
          if C.FMasked then
          begin
            R := Rect(FWinLeft + C.FWinLeft, FWinTop + C.FWinTop, FWinLeft + C.FWinLeft + C.FWinWidth,
              FWinTop + C.FWinTop + C.FWinHeight);
            AddDrawRect(R, Self);
          end;
        end;
  end;
  if FAOWOwner <> Sender then
    FAOWOwner.InvalidateRect(FAOWOwner.FChildren.IndexOf(Self) + 1, ARect, Self);
  FWinLeft := OldLeft;
  FWinTop := OldTop;
end;

procedure TAOWPanel.DetachMenuBar;
begin
  FTabPanel := nil;
end;

{ SetTabPanel moves the panel from the panel list of its old tab panel to the list of the new
  one, in priority order }
procedure TAOWPanel.SetTabPanel(Value: TAOWTabPanel);
var
  I, NewIndex: Integer;
  P: TAOWPanel;
begin
  if Value <> FTabPanel then
  begin
    if FTabPanel <> nil then
    begin
      I := 0;
      while I < FTabPanel.FPanels.Count do
      begin
        P := FTabPanel.FPanels[I];
        if P = Self then
        begin
          FTabPanel.FPanels.Delete(I);
          I := FTabPanel.FPanels.Count;
        end;
        Inc(I);
      end;
    end;
    FTabPanel := Value;
    if FTabPanel <> nil then
    begin
      I := 0;
      NewIndex := -1;
      while I < FTabPanel.FPanels.Count do
      begin
        P := FTabPanel.FPanels[I];
        if P.FPriority > FPriority then
        begin
          NewIndex := I;
          I := FTabPanel.FPanels.Count;
        end;
        Inc(I);
      end;
      if NewIndex = -1 then
        FTabPanel.FPanels.Add(Self)
      else
        FTabPanel.FPanels.Insert(NewIndex, Self);
    end;
  end;
end;

{ SetVisible: showing sets the back rectangle and marks the panel hidden (original bug: FHidden
  set instead of cleared) }
procedure TAOWPanel.SetVisible(Value: Boolean);
begin
  if Value <> FVisible then
  begin
    FVisible := Value;
    if not FVisible then
    begin
      FHidden := True;
      if Assigned(FOnHide) then
        FOnHide(Self);
    end
    else
    begin
      FDrawn := False;
      if not FHidden then
      begin
        FBackRect.Right := FWinWidth;
        FBackRect.Bottom := FWinHeight;
        FBackRect.Top := FWinTop;
        FBackRect.Left := FWinLeft;
        FHidden := True;
      end;
      if Assigned(FOnShow) then
        FOnShow(Self);
    end;
  end;
  if FVisible then
  begin
    if not FValid or not FAligned or not FSized then
      Setup;
    ClearBltList;
    ClearDrawList;
    FDrawn := False;
    SetPriority(FPriority);
  end;
end;

procedure TAOWPanel.SetAOWWindow(Value: TAOWBaseWindow);
begin
  SetOwner(Value);
end;

{ SetSize: at least as large as the frame corners, kept inside the window, at least MinWidth by
  MinHeight; the panel uses the window's window manager }
procedure TAOWPanel.SetSize;
begin
  if not FVisible and (FTabPanel <> nil) and (FTabPanel.FSelected = FOwnerItem) then
    FVisible := True;
  case FWindowType of
    winNormal, winHollow:
      begin
        if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width;
        if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
        if FAOWWindow.FWinWidth < FWinLeft + FWinWidth then
          FWinLeft := FAOWWindow.FWinWidth - FWinWidth;
        if FWinLeft < 0 then
        begin
          FWinLeft := 0;
          if FAOWWindow.FWinWidth < FWinLeft + FWinWidth then
            FWinWidth := FAOWWindow.FWinWidth - FWinLeft;
        end;
        if FAOWWindow.FWinHeight < FWinTop + FWinHeight then
          FWinTop := FAOWWindow.FWinHeight - FWinHeight;
        if FWinTop < 0 then
        begin
          FWinTop := 0;
          if FAOWWindow.FWinHeight < FWinTop + FWinHeight then
            FWinHeight := FAOWWindow.FWinHeight - FWinTop;
        end;
      end;
    winBorderless, winBlank:
      begin
        if FAOWWindow.FWinWidth < FWinLeft + FWinWidth then
          FWinLeft := FAOWWindow.FWinWidth - FWinWidth;
        if FWinLeft < 0 then
        begin
          FWinLeft := 0;
          if FAOWWindow.FWinWidth < FWinLeft + FWinWidth then
            FWinWidth := FAOWWindow.FWinWidth - FWinLeft;
        end;
        if FAOWWindow.FWinHeight < FWinTop + FWinHeight then
          FWinTop := FAOWWindow.FWinHeight - FWinHeight;
        if FWinTop < 0 then
        begin
          FWinTop := 0;
          if FAOWWindow.FWinHeight < FWinTop + FWinHeight then
            FWinHeight := FAOWWindow.FWinHeight - FWinTop;
        end;
      end;
  end;
  if (FMinWidth > 0) and (FMinWidth > FWinWidth) then
    FWinWidth := FMinWidth;
  if (FMinHeight > 0) and (FMinHeight > FWinHeight) then
    FWinHeight := FMinHeight;
  if FAOWWindow.FWinManager <> nil then
    FWinManager := FAOWWindow.FWinManager;
  FSurfaceValid := False;
  if FWindowType = winBlank then
    FMasked := True;
  inherited SetSize;
end;

{ Setup: like TAoWComponent.Setup, with the controls set up while the panel is moved by the
  position of a panel it sits in }
procedure TAOWPanel.Setup;
var
  I: Integer;
begin
  try
    if not FValid then
      Validate;
    if FValid then
    begin
      if not FSized then
        SetSize;
      if not FAligned then
        ReAlign;
      if not FSized then
        SetSize;
      FOrgLeft := FWinLeft;
      FOrgTop := FWinTop;
      if FAOWWindow is TAOWPanel then
      begin
        Inc(FWinLeft, FAOWWindow.FWinLeft);
        Inc(FWinTop, FAOWWindow.FWinTop);
      end;
      for I := 0 to FChildren.Count - 1 do
        TAoWComponent(FChildren[I]).Setup;
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
      FBltCount := 0;
      FDrawCount := 0;
    end;
  except
    MessageBox(0, 'Exception during Setup', Pointer('Error - ' + Name), 0);
  end;
end;

{ Update: the controls are updated with the panel moved by its window's position; when the
  panel moved or changed size, its old rectangle is redrawn in the owner }
procedure TAOWPanel.Update;
var
  I: Integer;
  R: TRect;
begin
  if FVisible then
  begin
    FOrgLeft := FWinLeft;
    FOrgTop := FWinTop;
    if FAOWWindow is TAOWPanel then
    begin
      Inc(FWinLeft, FAOWWindow.FWinLeft);
      Inc(FWinTop, FAOWWindow.FWinTop);
    end;
    if Assigned(FOnUpdate) then
      FOnUpdate(Self);
    for I := 0 to FChildren.Count - 1 do
      TAoWComponent(FChildren[I]).Update;
    FWinLeft := FOrgLeft;
    FWinTop := FOrgTop;
    if (FOldRect.Right > 0) and (FOldRect.Bottom > 0) and ((FOldRect.Left <> FWinLeft) or
      (FOldRect.Top <> FWinTop) or (FOldRect.Right <> FWinWidth) or (FOldRect.Bottom <> FWinHeight)) then
    begin
      if FAOWOwner.FAOWOwner.FAOWOwner = nil then
        R := Rect(FOldRect.Left, FOldRect.Top, FOldRect.Left + FOldRect.Right - 1,
          FOldRect.Top + FOldRect.Bottom - 1)
      else
        R := Rect(FAOWOwner.FWinLeft + FOldRect.Left, FAOWOwner.FWinTop + FOldRect.Top,
          FAOWOwner.FWinLeft + FOldRect.Left + FOldRect.Right - 1,
          FAOWOwner.FWinTop + FOldRect.Top + FOldRect.Bottom - 1);
      if FMasked then
        FAOWOwner.AddDrawRect(R, Self)
      else
        FAOWOwner.AddBltRect(R, Self);
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
        FAOWOwner.FWinLeft + FWinLeft + FWinWidth - 1, FAOWOwner.FWinTop + FWinTop + FWinHeight - 1);
    FAOWOwner.AddDrawRect(R, Self);
    FHidden := False;
  end;
  FSurfaceValid := FDrawn;
  FDrawn := False;
  FRedraw := True;
end;

{ Draw: the background (redrawn only in the dirty rectangles once the surface is valid), then
  the controls that need it; the rectangles of redrawn controls are passed on to the controls
  above them and blitted }
procedure TAOWPanel.Draw(SurfDesc: TSurfaceDesc);
var
  BltRect: TRect;
  I, J: Integer;
  OldClip: TRect;
  C: TAoWComponent;
  D: TaowRect;

  procedure DrawBack;
  begin
    if FWindowType <> winBlank then
    begin
      case FWindowType of
        winNormal:
          begin
            FILFrame.DrawILF(FILIndexFrame, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
            FILTexture.DrawILT(FILIndexTexture, Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FILFrame[FILIndexFrame + 1].Height,
              FWinWidth - FILFrame[FILIndexFrame + 3].Width - FILFrame[FILIndexFrame + 4].Width,
              FWinHeight - FILFrame[FILIndexFrame + 1].Height - FILFrame[FILIndexFrame + 6].Height),
              SurfDesc);
          end;
        winHollow:
          FILFrame.DrawILF(FILIndexFrame, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
        winBorderless:
          FILTexture.DrawILT(FILIndexTexture, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
      end;
      BltRect := Rect(SurfDesc.ClipRect.Left, SurfDesc.ClipRect.Top, SurfDesc.ClipRect.Right,
        SurfDesc.ClipRect.Bottom);
      FAOWOwner.AddBltRect(BltRect, Self);
    end;
  end;

begin
  try
    if FValid and FVisible then
    begin
      FOrgLeft := FWinLeft;
      FOrgTop := FWinTop;
      Inc(FWinLeft, FAOWWindow.FWinLeft);
      Inc(FWinTop, FAOWWindow.FWinTop);
      if (FWinLeft < SurfDesc.ClipRect.Right) and (FWinLeft > SurfDesc.ClipRect.Left) then
        SurfDesc.ClipRect.Left := FWinLeft;
      if (FWinTop < SurfDesc.ClipRect.Bottom) and (FWinTop > SurfDesc.ClipRect.Top) then
        SurfDesc.ClipRect.Top := FWinTop;
      if (FWinLeft + FWinWidth > SurfDesc.ClipRect.Left) and
        (FWinLeft + FWinWidth < SurfDesc.ClipRect.Right) then
        SurfDesc.ClipRect.Right := FWinLeft + FWinWidth;
      if (FWinTop + FWinHeight > SurfDesc.ClipRect.Top) and
        (FWinTop + FWinHeight < SurfDesc.ClipRect.Bottom) then
        SurfDesc.ClipRect.Bottom := FWinTop + FWinHeight;
      if FSurfaceValid then
        for J := 0 to FDrawCount - 1 do
          begin
            D := FDrawList[J];
            OldClip := SurfDesc.ClipRect;
            SurfDesc.ClipRect := Rect(D.R.Left, D.R.Top, D.R.Right + 1, D.R.Bottom + 1);
            DrawBack;
            SurfDesc.ClipRect := OldClip;
            FWinLeft := FOrgLeft;
            FWinTop := FOrgTop;
            InvalidateRect(0, D.R, D.Owner);
            Inc(FWinLeft, FAOWWindow.FWinLeft);
            Inc(FWinTop, FAOWWindow.FWinTop);
          end
      else
      begin
        DrawBack;
        if Assigned(FOnDrawBack) then
          FOnDrawBack(Self, SurfDesc);
      end;
      FDrawCount := 0;
      FDrawn := FSurfaceValid;
      for I := 0 to FChildren.Count - 1 do
      begin
        C := FChildren[I];
        if C.FValid and C.FVisible and (not FDrawn or not C.FDrawn) then
        begin
          C.FDrawn := False;
          if not FDrawn and (C is TAOWBaseWindow) then
            TAOWBaseWindow(C).FSurfaceValid := False;
          C.Draw(SurfDesc);
          C.FFirstDraw := C.FDrawn;
          C.FDrawn := True;
          for J := 0 to FDrawCount - 1 do
          begin
            D := FDrawList[J];
            InvalidateRect(I + 1, D.R, nil);
          end;
          FDrawCount := 0;
          if not FDrawn or not C.FFirstDraw then
          begin
            BltRect := Rect(FWinLeft + C.FWinLeft, FWinTop + C.FWinTop,
              FWinLeft + C.FWinLeft + C.FWinWidth, FWinTop + C.FWinTop + C.FWinHeight);
            FAOWOwner.AddBltRect(BltRect, Self);
            FWinLeft := FOrgLeft;
            FWinTop := FOrgTop;
            BltRect := Rect(FAOWWindow.FWinLeft + FWinLeft + C.FWinLeft,
              FAOWWindow.FWinTop + FWinTop + C.FWinTop,
              FAOWWindow.FWinLeft + FWinLeft + C.FWinLeft + C.FWinWidth - 1,
              FAOWWindow.FWinTop + FWinTop + C.FWinTop + C.FWinHeight - 1);
            InvalidateRect(I + 1, BltRect, C);
            Inc(FWinLeft, FAOWWindow.FWinLeft);
            Inc(FWinTop, FAOWWindow.FWinTop);
          end;
        end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
      FDrawn := FSurfaceValid;
      SurfDesc.ClipRect := OldClip;
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
      FSurfaceValid := True;
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: the controls first (from the top), with the panel moved by its window's
  position }
procedure TAOWPanel.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible = True then
  begin
    FOrgLeft := FWinLeft;
    FOrgTop := FWinTop;
    if FAOWWindow <> nil then
    begin
      Inc(FWinLeft, FAOWWindow.FWinLeft);
      Inc(FWinTop, FAOWWindow.FWinTop);
      FHandled := FAOWWindow.FHandled;
    end;
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.FHandled := False;
      if ((FHandled = False) or C.FRedraw) and (C.FVisible = True) and C.FCaptureInput then
        C.CheckMouseDown(Button, Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
      if C.FHandled = True then
        C.FRedraw := True;
    end;
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
    begin
      FHandled := True;
      FRedraw := True;
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
      if Assigned(FOnMouseDown) then
        FOnMouseDown(Self, Button, Shift, X, Y);
    end
    else
    begin
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
    end;
  end;
end;

procedure TAOWPanel.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible = True then
  begin
    FOrgLeft := FWinLeft;
    FOrgTop := FWinTop;
    if FAOWWindow <> nil then
    begin
      Inc(FWinLeft, FAOWWindow.FWinLeft);
      Inc(FWinTop, FAOWWindow.FWinTop);
      FHandled := FAOWWindow.FHandled;
    end;
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.FHandled := False;
      if ((FHandled = False) or (C.FRedraw = True)) and (C.FVisible = True) and C.FCaptureInput then
        C.CheckMouseUp(Button, Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
    end;
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
    begin
      FHandled := True;
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
      if Assigned(FOnMouseUp) then
        FOnMouseUp(Self, Button, Shift, X, Y);
    end
    else
    begin
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
    end;
  end;
end;

procedure TAOWPanel.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible = True then
  begin
    FOrgLeft := FWinLeft;
    FOrgTop := FWinTop;
    if FAOWWindow <> nil then
    begin
      Inc(FWinLeft, FAOWWindow.FWinLeft);
      Inc(FWinTop, FAOWWindow.FWinTop);
      FHandled := FAOWWindow.FHandled;
    end;
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.FHandled := False;
      if ((FHandled = False) or (C.FRedraw = True) or (C.FToolTipCount > 0)) and
        (C.FVisible = True) and C.FCaptureInput then
        C.CheckMouseMove(Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
    end;
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
    begin
      FHandled := True;
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
      if Assigned(FOnMouseMove) then
        FOnMouseMove(Self, Shift, X, Y);
    end
    else
    begin
      FWinLeft := FOrgLeft;
      FWinTop := FOrgTop;
    end;
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWPanel]);
end;

end.
