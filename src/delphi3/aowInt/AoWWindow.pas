unit AoWWindow;

{ The AoWWindow unit of aowInt.dpl: TAOWWindow, the ordinary window of the window manager. It
  draws its frame and texture, can be dragged by its title area (DragHeight) and resized by its
  borders, and keeps itself inside the window manager's screen and borders. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  { AoWWindow.TAOWWindow (instance size 492): no fields of its own. It uses the dragging fields of
    TAOWWindowControl: FDragging (0 none, 1 dragging, 2 resizing), FDragX and FDragY (the
    mouse's offset from the edge being moved), FResizingX and FResizingY (0 none, 1 the left or
    top edge, 2 the right or bottom edge). }
  TAOWWindow = class(TAOWGenericWindow)
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetSize; override;
    procedure ReAlign; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
  published
    property ILFrame;
    property ILIndexFrame;
    property ILIndexTexture;
    property ILTexture;
    property DragHeight: Integer read FDragHeight write FDragHeight;
    property Draggable: LongBool read FDraggable write FDraggable;
    property Resizable: LongBool read FResizable write FResizable;
    property OnDrag: TNotifyEvent read FOnChange write FOnChange;
    property OnResize: TNotifyEvent read FOnResize write FOnResize;
    property OnInternalResize: TNotifyEvent read FOnInternalResize write FOnInternalResize;
    property MinWidth: Integer read FMinWidth write FMinWidth;
    property MinHeight: Integer read FMinHeight write FMinHeight;
    property MaxWidth: Integer read FMaxWidth write FMaxWidth;
    property MaxHeight: Integer read FMaxHeight write FMaxHeight;
    property UseManagerBorders: Boolean read FUseManagerBorders write FUseManagerBorders;
    property Modal: Boolean read FModal write FModal;
    property WinHeight;
    property Dockable: Boolean read FDockable write FDockable;
  end;

procedure Register;

implementation

{ TAOWWindow }

constructor TAOWWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FUseManagerBorders := True;
end;

{ SetSize: at least as large as the frame corners, between the minimum and maximum size, and
  inside the window manager's screen (and borders); the frame rectangle is set for masked
  windows }
procedure TAOWWindow.SetSize;
begin
  case FWindowType of
    winNormal, winHollow:
      if (FILFrame <> nil) and ((FILTexture <> nil) or (FWindowType = winHollow)) then
      begin
        if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width;
        if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
        if (FMinWidth > 0) and (FMinWidth > FWinWidth) then
          FWinWidth := FMinWidth;
        if (FMinHeight > 0) and (FMinHeight > FWinHeight) then
          FWinHeight := FMinHeight;
        if (FMaxWidth > 0) and (FMaxWidth < FWinWidth) then
          FWinWidth := FMaxWidth;
        if (FMaxHeight > 0) and (FMaxHeight < FWinHeight) then
          FWinHeight := FMaxHeight;
        if (FWinManager.FWinWidth > 0) and (FWinManager.FWinHeight > 0) then
          if FUseManagerBorders then
          begin
            if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + FWinWidth then
              FWinLeft := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinWidth;
            if FWinManager.FBorderLeft > FWinLeft then
            begin
              FWinLeft := FWinManager.FBorderLeft;
              if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + FWinWidth then
                FWinWidth := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinLeft;
            end;
            if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
              FWinTop := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinHeight;
            if FWinManager.FBorderTop > FWinTop then
            begin
              FWinTop := FWinManager.FBorderTop;
              if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
                FWinHeight := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinTop;
            end;
          end
          else
          begin
            if FWinManager.FWinWidth < FWinLeft + FWinWidth then
              FWinLeft := FWinManager.FWinWidth - FWinWidth;
            if FWinLeft < 0 then
            begin
              FWinLeft := 0;
              if FWinManager.FWinWidth < FWinLeft + FWinWidth then
                FWinWidth := FWinManager.FWinWidth - FWinLeft;
            end;
            if FWinManager.FWinHeight < FWinTop + FWinHeight then
              FWinTop := FWinManager.FWinHeight - FWinHeight;
            if FWinTop < 0 then
            begin
              FWinTop := 0;
              if FWinManager.FWinHeight < FWinTop + FWinHeight then
                FWinHeight := FWinManager.FWinHeight - FWinTop;
            end;
          end;
        if FMasked then
          if FWindowType = winHollow then
          begin
            FFrameLeft := FWinWidth;
            FFrameRight := 0;
            FFrameTop := FWinHeight;
            FFrameBottom := 0;
          end
          else
          begin
            FFrameLeft := FILFrame[FILIndexFrame + 3].Width;
            FFrameRight := FWinWidth - FILFrame[FILIndexFrame + 4].Width;
            FFrameTop := FILFrame[FILIndexFrame + 1].Height;
            FFrameBottom := FWinHeight - FILFrame[FILIndexFrame + 6].Height;
          end;
      end;
    winBorderless, winBlank:
      if (FILTexture <> nil) or (FWindowType = winBlank) then
      begin
        if (FMinWidth > 0) and (FMinWidth > FWinWidth) then
          FWinWidth := FMinWidth;
        if (FMinHeight > 0) and (FMinHeight > FWinHeight) then
          FWinHeight := FMinHeight;
        if (FMaxWidth > 0) and (FMaxWidth < FWinWidth) then
          FWinWidth := FMaxWidth;
        if (FMaxHeight > 0) and (FMaxHeight < FWinHeight) then
          FWinHeight := FMaxHeight;
        if (FWinManager.FWinWidth > 0) and (FWinManager.FWinHeight > 0) then
          if FUseManagerBorders then
          begin
            if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + WinWidth then
              FWinLeft := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinWidth;
            if FWinManager.BorderLeft > FWinLeft then
            begin
              FWinLeft := FWinManager.FBorderLeft;
              if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + FWinWidth then
                FWinWidth := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinLeft;
            end;
            if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
              FWinTop := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinHeight;
            if FWinManager.BorderTop > FWinTop then
            begin
              FWinTop := FWinManager.FBorderTop;
              if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
                FWinHeight := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinTop;
            end;
          end
          else
          begin
            if FWinManager.FWinWidth < FWinLeft + WinWidth then
              FWinLeft := FWinManager.FWinWidth - FWinWidth;
            if FWinLeft < 0 then
            begin
              FWinLeft := 0;
              if FWinManager.FWinWidth < FWinLeft + FWinWidth then
                FWinWidth := FWinManager.FWinWidth - FWinLeft;
            end;
            if FWinManager.FWinHeight < FWinTop + FWinHeight then
              FWinTop := FWinManager.FWinHeight - FWinHeight;
            if FWinTop < 0 then
            begin
              FWinTop := 0;
              if FWinManager.FWinHeight < FWinTop + FWinHeight then
                FWinHeight := FWinManager.FWinHeight - FWinTop;
            end;
          end;
        if FMasked then
        begin
          FFrameLeft := FWinWidth;
          FFrameRight := 0;
          FFrameTop := FWinHeight;
          FFrameBottom := 0;
        end;
      end;
  end;
  if FDoubleBuffered and (FBackSurface <> nil) then
  begin
    FBackSurface.Resize(FWinWidth, FWinHeight);
    if FMasked then
      FBackSurface.Cls(FMaskColor);
  end;
  if Assigned(FOnInternalResize) then
    FOnInternalResize(Self);
  FSurfaceValid := False;
  inherited SetSize;
end;

{ ReAlign: a centered window is centered between the window manager's borders }
procedure TAOWWindow.ReAlign;
begin
  inherited ReAlign;
  if FUseManagerBorders then
  begin
    if FAlignment.AlignWidth = awCenter then
      FWinLeft := (FAOWOwner.FWinWidth - FWinManager.FBorderLeft - FWinManager.FBorderRight) div 2 +
        FWinManager.FBorderLeft - FWinWidth div 2;
    if FAlignment.AlignHeight = ahCenter then
      FWinTop := (FAOWOwner.FWinHeight - FWinManager.FBorderTop - FWinManager.FBorderBottom) div 2 +
        FWinManager.FBorderTop - FWinHeight div 2;
  end;
end;

procedure TAOWWindow.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FValid and FVisible then
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
      if Assigned(FOnDrawBack) then
        FOnDrawBack(Self, SurfDesc);
      FSurfaceValid := False;
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: a click brings the window to the front; the controls get it first; a left
  click in the title area starts dragging, one on a border (Resizable) starts resizing }
procedure TAOWWindow.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  FRedraw := False;
  FDragging := 0;
  if (FWinManager <> nil) and not FWinManager.FHandled and (FVisible = True) then
  begin
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
      SetPriority(FPriority);
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      C.FHandled := False;
      if ((FHandled = False) or C.FRedraw) and (C.FVisible = True) and C.FCaptureInput then
        C.CheckMouseDown(Button, Shift, X, Y);
      if C.FHandled = True then
      begin
        C.FRedraw := True;
        FHandled := True;
        FRedraw := True;
      end;
    end;
    if (FHandled = False) and (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and
      (Y > FWinTop - 1) and (Y < FWinTop + FWinHeight) then
    begin
      FDragX := 0;
      FDragY := 0;
      if (Button = mbLeft) and (FDraggable = True) and
        (Y < FWinTop + FBorderHeight + FDragHeight - 1) then
      begin
        FDragging := 1;
        FDragX := X - FWinLeft;
        FDragY := Y - FWinTop;
      end;
      if (Button = mbLeft) and (FResizable = True) then
      begin
        FResizingX := 0;
        FResizingY := 0;
        if X < FWinLeft + FBorderWidth - 1 then
        begin
          FDragging := 2;
          FResizingX := 1;
          FDragX := X - FWinLeft;
          if Y < FBorderHeight * 5 + FWinTop - 1 then
          begin
            FResizingY := 1;
            FDragY := Y - FWinTop;
          end;
          if Y > FWinTop + FWinHeight - FBorderHeight * 5 then
          begin
            FResizingY := 2;
            FDragY := FWinTop + FWinHeight - Y;
          end;
        end;
        if X > FWinLeft + FWinWidth - FBorderHeight then
        begin
          FDragging := 2;
          FResizingX := 2;
          FDragX := FWinLeft + FWinWidth - X;
          if Y < FBorderHeight * 5 + FWinTop - 1 then
          begin
            FResizingY := 1;
            FDragY := Y - FWinTop;
          end;
          if Y > FWinTop + FWinHeight - FBorderHeight * 5 then
          begin
            FResizingY := 2;
            FDragY := FWinTop + FWinHeight - Y;
          end;
        end;
        if Y < FWinTop + FBorderHeight - 1 then
        begin
          FDragging := 2;
          FResizingY := 1;
          FDragY := Y - FWinTop;
          if X < FBorderWidth * 5 + FWinLeft - 1 then
          begin
            FResizingX := 1;
            FDragX := X - FWinLeft;
          end;
          if X > FWinLeft + FWinWidth - FBorderWidth * 5 then
          begin
            FResizingX := 2;
            FDragX := FWinLeft + FWinWidth - X;
          end;
        end;
        if Y > FWinTop + FWinHeight - FBorderHeight then
        begin
          FDragging := 2;
          FResizingY := 2;
          FDragY := FWinTop + FWinHeight - Y;
          if X < FBorderWidth * 5 + FWinLeft - 1 then
          begin
            FResizingX := 1;
            FDragX := X - FWinLeft;
          end;
          if X > FWinLeft + FWinWidth - FBorderWidth * 5 then
          begin
            FResizingX := 2;
            FDragX := FWinLeft + FWinWidth - X;
          end;
        end;
      end;
      FRedraw := True;
      FHandled := True;
    end;
    if FHandled then
      if FWinManager <> nil then
      begin
        if (FWinManager.FHandled = False) and Assigned(FOnMouseDown) then
          FOnMouseDown(Self, Button, Shift, X, Y);
      end
      else if Assigned(FOnMouseDown) then
        FOnMouseDown(Self, Button, Shift, X, Y);
    if FModal then
      FHandled := True;
  end;
end;

procedure TAOWWindow.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible and FValid then
  begin
    FDragging := 0;
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
      FHandled := True;
    if FHandled then
    begin
      if (FWinManager.FHandled = False) and Assigned(FOnMouseUp) then
        FOnMouseUp(Self, Button, Shift, X, Y);
    end
    else if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
    if FModal then
      FHandled := True;
  end;
end;

{ CheckMouseMove drags or resizes the window, passes the move to the controls and sets the
  resize cursors over the borders }
procedure TAOWWindow.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  Resized: Boolean;
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  FOldCursor := FCursor;
  FCursor := FWindowCursor;
  FInResizeArea := True;
  Resized := False;
  if FVisible = True then
  begin
    case FDragging of
      1:
        begin
          FWinLeft := X - FDragX;
          FWinTop := Y - FDragY;
          if (FWinManager <> nil) and FUseManagerBorders then
          begin
            if FWinManager.FBorderLeft > FWinLeft then
              FWinLeft := FWinManager.FBorderLeft;
            if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + FWinWidth then
              FWinLeft := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinWidth;
            if FWinManager.FBorderTop > FWinTop then
              FWinTop := FWinManager.FBorderTop;
            if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
              FWinTop := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinHeight;
          end;
          if Assigned(FOnChange) then
            FOnChange(Self);
          if not FDoubleBuffered then
            FDrawn := False;
          FSurfaceValid := False;
        end;
      2:
        begin
          case FResizingX of
            1:
              begin
                if FWinLeft + FDragX > X then if (FWinManager <> nil) and FUseManagerBorders then if
                  (FWinManager.FBorderLeft > X - FDragX) then
                  X := FWinManager.FBorderLeft + FDragX;
                I := FWinLeft + FWinWidth;
                FWinWidth := FWinWidth - X + FWinLeft + FDragX;
                if FWinWidth < FMinWidth then
                  FWinWidth := FMinWidth;
                if (FMaxWidth < FWinWidth) and (FMaxWidth > 0) then
                  FWinWidth := FMaxWidth;
                FWinLeft := I - FWinWidth;
                Resized := True;
              end;
            2:
              begin
                FWinWidth := X + FDragX - FWinLeft;
                if (FWinManager <> nil) and FUseManagerBorders then
                  if FWinManager.FWinWidth - FWinManager.FBorderRight < FWinLeft + FWinWidth then
                    FWinWidth := FWinManager.FWinWidth - FWinManager.FBorderRight - FWinLeft;
                if FMinWidth > FWinWidth then
                  FWinWidth := FMinWidth;
                if (FMaxWidth < FWinWidth) and (FMaxWidth > 0) then
                  FWinWidth := FMaxWidth;
                Resized := True;
              end;
          end;
          case FResizingY of
            1:
              begin
                if FWinTop + FDragY > Y then if (FWinManager <> nil) and FUseManagerBorders then if
                  (FWinManager.FBorderTop > Y - FDragY) then
                  Y := FWinManager.FBorderTop + FDragY;
                I := FWinTop + FWinHeight;
                FWinHeight := FWinHeight - Y + FWinTop + FDragY;
                if FWinHeight < FMinHeight then
                  FWinHeight := FMinHeight;
                if (FMaxHeight < FWinHeight) and (FMaxHeight > 0) then
                  FWinHeight := FMaxHeight;
                FWinTop := I - FWinHeight;
                Resized := True;
              end;
            2:
              begin
                FWinHeight := Y + FDragY - FWinTop;
                if (FWinManager <> nil) and FUseManagerBorders then
                  if FWinManager.FWinHeight - FWinManager.FBorderBottom < FWinTop + FWinHeight then
                    FWinHeight := FWinManager.FWinHeight - FWinManager.FBorderBottom - FWinTop;
                if FMinHeight > FWinHeight then
                  FWinHeight := FMinHeight;
                if (FMaxHeight < FWinHeight) and (FMaxHeight > 0) then
                  FWinHeight := FMaxHeight;
                Resized := True;
              end;
          end;
          if Resized then
          begin
            if Assigned(FOnResize) then
              FOnResize(Self);
            FAligned := False;
          end;
        end;
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
    if (FHandled = False) and (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and
      (Y > FWinTop - 1) and (Y < FWinTop + FWinHeight) then
    begin
      FHandled := True;
      if FResizable = True then
        if X < FWinLeft + FBorderWidth - 1 then
        begin
          FCursor := crSizeWE;
          if Y < FBorderHeight * 5 + FWinTop - 1 then
            FCursor := crSizeNWSE;
          if Y > FWinTop + FWinHeight - FBorderHeight * 5 then
            FCursor := crSizeNESW;
        end
        else if X > FWinLeft + FWinWidth - FBorderWidth then
        begin
          FCursor := crSizeWE;
          if Y < FBorderHeight * 5 + FWinTop - 1 then
            FCursor := crSizeNESW;
          if Y > FWinTop + FWinHeight - FBorderHeight * 5 then
            FCursor := crSizeNWSE;
        end
        else if Y < FWinTop + FBorderHeight - 1 then
        begin
          FCursor := crSizeNS;
          if X < FBorderWidth * 5 + FWinLeft - 1 then
            FCursor := crSizeNWSE;
          if X > FWinLeft + FWinWidth - FBorderWidth * 5 then
            FCursor := crSizeNESW;
        end
        else if Y > FWinTop + FWinHeight - FBorderHeight then
        begin
          FCursor := crSizeNS;
          if X < FBorderWidth * 5 + FWinLeft - 1 then
            FCursor := crSizeNESW;
          if X > FWinLeft + FWinWidth - FBorderWidth * 5 then
            FCursor := crSizeNWSE;
        end;
    end;
    if FHandled then
      if FWinManager <> nil then
      begin
        if (FWinManager.FHandled = False) and Assigned(FOnMouseMove) then
          FOnMouseMove(Self, Shift, X, Y);
      end
      else if Assigned(FOnMouseMove) then
        FOnMouseMove(Self, Shift, X, Y);
    if FModal then
      FHandled := True;
  end;
  if (FCursor <> FOldCursor) and Assigned(FOnChangeCursor) then
    FOnChangeCursor(Self);
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWWindow]);
end;

end.
