unit AOWWinManager;

{ The AOWWinManager unit of aowInt.dpl: TAOWWinManager, the root of a screen of AoW windows. It
  owns the windows (its children, sorted by priority), draws the background and foreground
  textures and the windows into the display surface, keeps the dirty rectangles of the whole
  screen and passes the mouse and keyboard input to the windows from the top down. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWDialogForm, AoWComp, AOWInterfaceImgLib, AoWWinControl;

type
  { AOWWinManager.TAOWWinManager (instance size 316). Fields: +$104 FForegroundTexture, +$108
    FBackgroundTexture, +$10C FOverlayPriority (windows below it get no input), +$110
    FNewOverlayPriority (applied by Draw), +$114 FBorderLeft, +$118 FBorderTop, +$11C
    FBorderRight, +$120 FBorderBottom, +$124 FOldCursor (the cursor before CheckMouseMove), +$126
    FDefaultCursor (the cursor when no window claims the mouse), +$128 FOnChangeCursor, +$130
    FILIndexTBack, +$134 FILIndexTFore, +$138 FDrawOverlay (draw the foreground texture over
    the windows below the overlay priority).
    VMT (new): SetILTB, SetILTF }
  TAOWWinManager = class(TAoWComponent)
  public
    FForegroundTexture: TInterfaceIL;
    FBackgroundTexture: TInterfaceIL;
    FOverlayPriority: Integer;
    FNewOverlayPriority: Integer;
    FBorderLeft: Integer;
    FBorderTop: Integer;
    FBorderRight: Integer;
    FBorderBottom: Integer;
    FOldCursor: TCursor;
    FDefaultCursor: TCursor;
    FOnChangeCursor: TNotifyEvent;
    FILIndexTBack: Integer;
    FILIndexTFore: Integer;
    FDrawOverlay: Boolean;
    constructor Create(AOwner: TComponent); override;
    procedure Validate; override;
    procedure Update; override;
    procedure InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent); override;
    procedure DrawSurface(Surface: TSurface); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure SetILTB(Value: TInterfaceIL); virtual;
    procedure SetILTF(Value: TInterfaceIL); virtual;
    procedure SetILBIndex(Value: Integer);
    procedure SetILFIndex(Value: Integer);
    procedure SetOverPri(Value: Integer);
    procedure SetCursor(Value: TCursor);
  published
    property Cursor: TCursor read FCursor write SetCursor;
    property OnChangeCursor: TNotifyEvent read FOnChangeCursor write FOnChangeCursor;
    property WinLeft;
    property WinTop;
    property WinWidth;
    property WinHeight;
    property BackgroundTexture: TInterfaceIL read FBackgroundTexture write SetILTB;
    property ForegroundTexture: TInterfaceIL read FForegroundTexture write SetILTF;
    property ILIndexTBack: Integer read FILIndexTBack write SetILBIndex;
    property ILIndexTFore: Integer read FILIndexTFore write SetILFIndex;
    property OverlayPriority: Integer read FOverlayPriority write SetOverPri;
    property BorderLeft: Integer read FBorderLeft write FBorderLeft;
    property BorderRight: Integer read FBorderRight write FBorderRight;
    property BorderTop: Integer read FBorderTop write FBorderTop;
    property BorderBottom: Integer read FBorderBottom write FBorderBottom;
    property DrawOverlay: Boolean read FDrawOverlay write FDrawOverlay;
  end;

procedure Register;

implementation

{ TAOWWinManager }

constructor TAOWWinManager.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FWinHeight := 480;
  FWinWidth := 640;
  FOldCursor := -2;
  FDefaultCursor := -2;
  FDrawOverlay := True;
end;

procedure TAOWWinManager.Validate;
begin
  if FBackgroundTexture <> nil then
    FBackgroundTexture := FBackgroundTexture.CheckIL(FILIndexTBack, 1, Self);
  if FForegroundTexture <> nil then
    FForegroundTexture := FForegroundTexture.CheckIL(FILIndexTFore, 1, Self);
  if FBackgroundTexture <> nil then
    FValid := True;
  inherited Validate;
end;

procedure TAOWWinManager.SetILTB(Value: TInterfaceIL);
begin
  if Value <> FBackgroundTexture then
  begin
    FValid := False;
    FBackgroundTexture := Value;
  end;
end;

procedure TAOWWinManager.SetILTF(Value: TInterfaceIL);
begin
  if Value <> FForegroundTexture then
  begin
    FValid := False;
    FForegroundTexture := Value;
  end;
end;

procedure TAOWWinManager.SetILBIndex(Value: Integer);
begin
  if Value <> FILIndexTBack then
  begin
    FILIndexTBack := Value;
    FValid := False;
  end;
end;

procedure TAOWWinManager.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexTFore then
  begin
    FILIndexTFore := Value;
    FValid := False;
  end;
end;

procedure TAOWWinManager.SetOverPri(Value: Integer);
begin
  if (Value <> FOverlayPriority) or (Value <> FNewOverlayPriority) then
  begin
    FNewOverlayPriority := Value;
    FDrawn := False;
  end;
end;

procedure TAOWWinManager.SetCursor(Value: TCursor);
begin
  if Value <> FCursor then
  begin
    FCursor := Value;
    if Assigned(FOnChangeCursor) then
      FOnChangeCursor(Self);
  end;
end;

procedure TAOWWinManager.Draw(SurfDesc: TSurfaceDesc);
var
  I: Integer;
  C: TAoWComponent;
begin
  if FOverlayPriority > FNewOverlayPriority then
    for I := 0 to FChildren.Count - 1 do
    begin
      C := FChildren[I];
      if (C.FPriority >= FNewOverlayPriority) and (C.FPriority < FOverlayPriority) and C.FVisible then
      begin
        C.FDrawn := False;
        C.FSurfaceValid := False;
      end;
    end;
  FOverlayPriority := FNewOverlayPriority;
  FBackgroundTexture.DrawILT(FILIndexTBack, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
end;

procedure TAOWWinManager.Update;
var
  I: Integer;
  C: TAoWComponent;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnUpdate) then
        FOnUpdate(Self);
      for I := 0 to FChildren.Count - 1 do
      begin
        C := FChildren[I];
        if C.FVisible and (C.FPriority >= FOverlayPriority) then
          C.Update;
      end;
      if not FValid or not FAligned or not FSized then
        Setup;
    end;
  except
    MessageBox(0, 'Exception during Update', Pointer('Error - ' + Name), 0);
  end;
end;

{ InvalidateRect passes ARect (screen coordinates) on to the windows from Index up that it touches
  (a rectangle from a window only when that window is not below the overlay priority): a
  double-buffered window adds it, in its own coordinates, to its blit list, any other window adds
  it to its draw list. The window itself is passed as the Sender. }
procedure TAOWWinManager.InvalidateRect(Index: Integer; var ARect: TRect; Sender: TAoWComponent);
var
  I: Integer;
  C: TAoWComponent;
  R: TRect;
begin
  if FValid and FVisible then
    if (Sender = nil) or ((Sender <> nil) and (Sender is TAOWWindowControl) and
      (TAoWComponent(FChildren[Index]).FPriority >= FOverlayPriority)) then
      for I := Index to FChildren.Count - 1 do
      begin
        C := FChildren[I];
        if C.FValid and C.FVisible and (FWinLeft + C.FWinLeft <= ARect.Right) and
          (FWinLeft + C.FWinLeft + C.FWinWidth >= ARect.Left) and
          (FWinTop + C.FWinTop <= ARect.Bottom) and
          (FWinTop + C.FWinTop + C.FWinHeight >= ARect.Top) and
          (ARect.Left <= ARect.Right) and (ARect.Top <= ARect.Bottom) then
          if C.FDoubleBuffered then
          begin
            R := Rect(ARect.Left - C.FWinLeft, ARect.Top - C.FWinTop, ARect.Right - C.FWinLeft,
              ARect.Bottom - C.FWinTop);
            C.AddBltRect(R, C);
          end
          else
            C.AddDrawRect(ARect, C);
      end;
end;

{ DrawSurface draws the screen into Surface: first it brings the windows up to date and adds the
  screen area that a hidden or moved window uncovered to the draw list (only the frame strips for a
  masked window), then it redraws the background (all of it the first time, else only the dirty
  rectangles) and asks every window to draw itself; the rectangles each window blitted are passed
  on to the windows above it, and the foreground texture is drawn again over them when the window
  is below the overlay priority. FBackRect holds the window's last place as (Left, Top, Width,
  Height). }
procedure TAOWWinManager.DrawSurface(Surface: TSurface);
var
  I, J: Integer;
  C: TAOWWindowControl;
  D: TaowRect;
  WasValid: Boolean;
  SD: TSurfaceDesc;
  R: TRect;
begin
  try
    Setup;
    Update;
    if FValid then
      for I := 0 to FChildren.Count - 1 do
      begin
        C := FChildren[I];
        if C.FValid then
        begin
          if not FDrawn then
            if C.FDoubleBuffered then
              C.FSurfaceValid := False
            else
              C.FDrawn := False;
          if C.FHidden = True then
          begin
            C.FHidden := False;
            R := Rect(C.FWinLeft, C.FWinTop, C.FWinLeft + C.FWinWidth, C.FWinTop + C.FWinHeight);
            AddDrawRect(R, C);
          end
          else
          begin
            if C.FVisible and FDrawn and (C.FBackRect.Right > 0) and (C.FBackRect.Bottom > 0) then
            begin
              { the window moved: add the parts of its old place it no longer covers. For a
                masked window the strips are off (original bugs): the third strip of the left
                and right cases is everything below the top frame, and the right case starts
                at FWinLeft + FFrameRight }
              if C.FBackRect.Left < C.FWinLeft then
                if C.FMasked then
                begin
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FWinLeft + C.FFrameLeft,
                    C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FBackRect.Right,
                    C.FBackRect.Top + C.FFrameBottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top + C.FFrameBottom,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end
                else
                begin
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FWinLeft,
                    C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end;
              if C.FBackRect.Top < C.FWinTop then
                if C.FMasked then
                begin
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FBackRect.Right,
                    C.FWinTop + C.FFrameTop);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FFrameLeft,
                    C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left + C.FFrameRight, C.FBackRect.Top,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end
                else
                begin
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FBackRect.Right,
                    C.FWinTop);
                  AddDrawRect(R, C);
                end;
              if C.FBackRect.Left + C.FBackRect.Right > C.FWinLeft + C.FWinWidth then
                if C.FMasked then
                begin
                  R := Rect(C.FWinLeft + C.FFrameRight, C.FBackRect.Top,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FBackRect.Right,
                    C.FBackRect.Top + C.FFrameBottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top + C.FFrameBottom,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end
                else
                begin
                  R := Rect(C.FWinLeft + C.FWinWidth, C.FBackRect.Top,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end;
              if C.FBackRect.Top + C.FBackRect.Bottom > C.FWinTop + C.FWinHeight then
                if C.FMasked then
                begin
                  R := Rect(C.FBackRect.Left, C.FWinTop + C.FFrameTop,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left, C.FBackRect.Top, C.FBackRect.Left + C.FFrameLeft,
                    C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                  R := Rect(C.FBackRect.Left + C.FFrameRight, C.FBackRect.Top,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end
                else
                begin
                  R := Rect(C.FBackRect.Left, C.FWinTop + C.FWinHeight,
                    C.FBackRect.Left + C.FBackRect.Right, C.FBackRect.Top + C.FBackRect.Bottom);
                  AddDrawRect(R, C);
                end;
            end;
            C.FBackRect.Top := C.FWinTop;
            C.FBackRect.Left := C.FWinLeft;
            C.FBackRect.Right := C.FWinWidth;
            C.FBackRect.Bottom := C.FWinHeight;
          end;
        end;
      end;
    if not FDrawn then
    begin
      if Surface.Lock(SD) >= 0 then
      begin
        Draw(SD);
        if FDrawOverlay and (FOverlayPriority > 0) then
          FForegroundTexture.DrawILT(FILIndexTFore, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SD);
        Surface.Unlock;
      end;
    end
    else if Surface.Lock(SD) >= 0 then
    begin
      for J := 0 to FDrawCount - 1 do
      begin
        D := FDrawList[J];
        if FWinLeft > D.R.Left then
          D.R.Left := FWinLeft;
        if FWinTop > D.R.Top then
          D.R.Top := FWinTop;
        Inc(D.R.Right);
        Inc(D.R.Bottom);
        if FWinLeft + FWinWidth < D.R.Right then
          D.R.Right := FWinLeft + FWinWidth;
        if FWinTop + FWinHeight < D.R.Bottom then
          D.R.Bottom := FWinTop + FWinHeight;
        SD.ClipRect := Rect(D.R.Left, D.R.Top, D.R.Right, D.R.Bottom);
        Draw(SD);
        if FDrawOverlay and (FOverlayPriority > 0) then
          FForegroundTexture.DrawILT(FILIndexTFore, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SD);
        InvalidateRect(0, D.R, nil);
      end;
      FDrawCount := 0;
      Surface.Unlock;
    end;
    for I := 0 to FChildren.Count - 1 do
    begin
      C := FChildren[I];
      C.FHidden := False;
      if C.FValid and C.FVisible then
      begin
        WasValid := C.FSurfaceValid;
        if not C.FDrawn then
          WasValid := False;
        C.DrawSurface(Surface);
        if not WasValid or not C.FSurfaceValid then
        begin
          R := Rect(C.FWinLeft, C.FWinTop, C.FWinLeft + C.FWinWidth, C.FWinTop + C.FWinHeight);
          AddBltRect(R, C);
        end;
        C.FDrawn := True;
        C.FSurfaceValid := True;
        for J := 0 to FBltCount - 1 do
        begin
          D := FBltList[J];
          InvalidateRect(I + 1, D.R, nil);
        end;
        if FDrawOverlay and (C.FPriority < FOverlayPriority) then
          if Surface.Lock(SD) >= 0 then
          begin
            for J := 0 to FBltCount - 1 do
            begin
              D := FBltList[J];
              if C.FWinLeft > D.R.Left then
                D.R.Left := C.FWinLeft;
              if C.FWinTop > D.R.Top then
                D.R.Top := C.FWinTop;
              Inc(D.R.Right);
              Inc(D.R.Bottom);
              if C.FWinLeft + C.FWinWidth < D.R.Right then
                D.R.Right := C.FWinLeft + C.FWinWidth;
              if C.FWinTop + C.FWinHeight < D.R.Bottom then
                D.R.Bottom := C.FWinTop + C.FWinHeight;
              SD.ClipRect := Rect(D.R.Left, D.R.Top, D.R.Right, D.R.Bottom);
              FForegroundTexture.DrawILT(FILIndexTFore, Rect(FWinLeft, FWinTop, FWinWidth,
                FWinHeight), SD);
            end;
            Surface.Unlock;
          end;
        FBltCount := 0;
      end;
    end;
    FDrawn := True;
    ClearDrawList;
    ClearBltList;
  except
    MessageBox(0, 'Exception during DrawSurface', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAOWWinManager.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
  Redraw: Boolean;
begin
  FHandled := False;
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := FChildren[I];
    if C.FPriority >= FOverlayPriority then
    begin
      Redraw := C.FRedraw;
      C.FHandled := False;
      if (FHandled = False) or (Redraw = True) then
        C.CheckMouseDown(Button, Shift, X, Y);
      if C.FHandled then
        FHandled := True;
    end;
  end;
  if Assigned(FOnMouseDown) then
    FOnMouseDown(Self, Button, Shift, X, Y);
end;

procedure TAOWWinManager.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := FChildren[I];
    if C.FPriority >= FOverlayPriority then
    begin
      if (FHandled = False) or (C.FRedraw = True) then
        C.CheckMouseUp(Button, Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
    end;
  end;
  if Assigned(FOnMouseUp) then
    FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TAOWWinManager.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAOWWindowControl;
begin
  FHandled := False;
  FOldCursor := FCursor;
  FCursor := FDefaultCursor;
  if X < 0 then
    X := 0;
  if Y < 0 then
    Y := 0;
  if FWinWidth <= X then
    X := FWinWidth - 1;
  if FWinHeight <= Y then
    Y := FWinHeight - 1;
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := FChildren[I];
    if C.FPriority >= FOverlayPriority then
      if (FHandled = False) or (C.FRedraw = True) then
      begin
        C.CheckMouseMove(Shift, X, Y);
        if C.FHandled = True then
        begin
          if FHandled = False then
          begin
            FCursor := C.FCursor;
            if not C.FMouseInside then
            begin
              C.FMouseInside := True;
              if Assigned(C.FOnEnter) then
                C.FOnEnter(C);
            end;
          end
          else if C.FMouseInside then
          begin
            C.FMouseInside := False;
            if Assigned(C.FOnExit) then
              C.FOnExit(C);
          end;
          FHandled := True;
        end
        else if C.FMouseInside then
        begin
          C.FMouseInside := False;
          if Assigned(C.FOnExit) then
            C.FOnExit(C);
        end;
      end
      else if C.FMouseInside then
      begin
        C.FMouseInside := False;
        if Assigned(C.FOnExit) then
          C.FOnExit(C);
      end;
  end;
  if FCursor <> FOldCursor then
    if Assigned(FOnChangeCursor) then
      FOnChangeCursor(Self);
  if Assigned(FOnMouseMove) then
    FOnMouseMove(Self, Shift, X, Y);
end;

procedure TAOWWinManager.CheckKeyPress(var Key: Char);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := FChildren[I];
    if C.FPriority >= FOverlayPriority then
    begin
      C.CheckKeyPress(Key);
      if C.FHandled = True then
        FHandled := True;
    end;
  end;
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TAOWWinManager.CheckKeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := FChildren[I];
    if not FHandled and (C.FPriority >= FOverlayPriority) and C.FVisible then
    begin
      C.CheckKeyDown(Key, Shift);
      if C.FHandled = True then
        FHandled := True;
    end;
  end;
  if not FHandled and Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWWinManager]);
end;

end.
