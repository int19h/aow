unit AoWFrame;

{ The AoWFrame unit of aowInt.dpl: TAoWFrame, a decoration control: a frame of eight images,
  filled with a texture or hollow, or a horizontal or vertical line of three images. A right
  click opens its PopupMenu at the mouse, kept inside the window manager. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWMenuBar, AOWMenu, AOWToolTip, AoWControl, AOWWinManager, AoWComp,
  AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  TFrameType = (frFilledBox, frHollowBox, frHorizLine, frVertLine);

  { AoWFrame.TAoWFrame (instance size 308). Fields: +$114 FFrameType, +$118 FILFrame, +$11C
    FILTexture, +$120 FILLine, +$124 FILIndexFrame, +$128 FILIndexLine, +$12C FILIndexTexture,
    +$130 FPopupMenu.
    VMT (new): SetILFrame, SetILTexture, SetILLine }
  TAoWFrame = class(TAOWControl)
  public
    FFrameType: TFrameType;
    FILFrame: TInterfaceIL;
    FILTexture: TInterfaceIL;
    FILLine: TInterfaceIL;
    FILIndexFrame: Integer;
    FILIndexLine: Integer;
    FILIndexTexture: Integer;
    FPopupMenu: TAOWMenu;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILTexture(Value: TInterfaceIL); virtual;
    procedure SetILLine(Value: TInterfaceIL); virtual;
    procedure SetILFIndex(Value: Integer);
    procedure SetILLIndex(Value: Integer);
    procedure SetILTIndex(Value: Integer);
  published
    property WinWidth;
    property WinHeight;
    property FrameType: TFrameType read FFrameType write FFrameType;
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILIndexFrame: Integer read FILIndexFrame write SetILFIndex;
    property ILIndexLine: Integer read FILIndexLine write SetILLIndex;
    property ILIndexTexture: Integer read FILIndexTexture write SetILTIndex;
    property ILLine: TInterfaceIL read FILLine write SetILLine;
    property ILTexture: TInterfaceIL read FILTexture write SetILTexture;
    property PopupMenu: TAOWMenu read FPopupMenu write FPopupMenu;
  end;

procedure Register;

implementation

{ TAoWFrame }

procedure TAoWFrame.Validate;
begin
  if FILFrame <> nil then
    FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
  if FILTexture <> nil then
    FILTexture := FILTexture.CheckIL(FILIndexTexture, 1, Self);
  if FILLine <> nil then
    FILLine := FILLine.CheckIL(FILIndexLine, 3, Self);
  if (FILFrame <> nil) or (FILLine <> nil) then
  begin
    FValid := True;
    if FILFrame <> nil then
      if FILTexture <> nil then
        FFrameType := frFilledBox
      else
        FFrameType := frHollowBox
    else if FILLine <> nil then
      if FFrameType <> frHorizLine then
        FFrameType := frVertLine;
  end;
  inherited Validate;
end;

procedure TAoWFrame.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexFrame then
  begin
    FILIndexFrame := Value;
    FValid := False;
  end;
end;

procedure TAoWFrame.SetILLIndex(Value: Integer);
begin
  if Value <> FILIndexLine then
  begin
    FILIndexLine := Value;
    FValid := False;
  end;
end;

procedure TAoWFrame.SetILTIndex(Value: Integer);
begin
  if Value <> FILIndexTexture then
  begin
    FILIndexTexture := Value;
    FValid := False;
  end;
end;

procedure TAoWFrame.SetSize;
begin
  case FFrameType of
    frFilledBox, frHollowBox:
      begin
        if FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 5].Height;
        if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width;
      end;
    frHorizLine:
      begin
        FWinHeight := FILLine[FILIndexLine].Height;
        if FILLine[FILIndexLine].Width + FILLine[FILIndexLine + 2].Width > FWinWidth then
          FWinWidth := FILLine[FILIndexLine].Width + FILLine[FILIndexLine + 2].Width;
      end;
    frVertLine:
      begin
        if FILLine[FILIndexLine].Height + FILLine[FILIndexLine + 2].Height > FWinHeight then
          FWinHeight := FILLine[FILIndexLine].Height + FILLine[FILIndexLine + 2].Height;
        FWinWidth := FILLine[FILIndexLine].Width;
      end;
  end;
  inherited SetSize;
end;

procedure TAoWFrame.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAoWFrame.SetILTexture(Value: TInterfaceIL);
begin
  if Value <> FILTexture then
  begin
    FValid := False;
    FILTexture := Value;
  end;
end;

procedure TAoWFrame.SetILLine(Value: TInterfaceIL);
begin
  if Value <> FILLine then
  begin
    FValid := False;
    FILLine := Value;
  end;
end;

procedure TAoWFrame.Draw(SurfDesc: TSurfaceDesc);
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      case FFrameType of
        frVertLine:
          FILLine.DrawILLv(FILIndexLine, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
        frHorizLine:
          FILLine.DrawILLh(FILIndexLine, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
        frHollowBox:
          FILFrame.DrawILF(FILIndexFrame, Rect(FAOWWindow.FWinLeft + FWinLeft,
            FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
        frFilledBox:
          begin
            FILFrame.DrawILF(FILIndexFrame, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            FILTexture.DrawILT(FILIndexTexture, Rect(FAOWWindow.FWinLeft + FWinLeft +
              FILFrame[FILIndexFrame + 3].Width, FAOWWindow.FWinTop + FWinTop +
              FILFrame[FILIndexFrame + 1].Height, FWinWidth - FILFrame[FILIndexFrame + 3].Width -
              FILFrame[FILIndexFrame + 4].Width, FWinHeight - FILFrame[FILIndexFrame + 1].Height -
              FILFrame[FILIndexFrame + 6].Height), SurfDesc);
          end;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

procedure TAoWFrame.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
    if (Button = mbRight) and (FPopupMenu <> nil) then
    begin
      FPopupMenu.SetPopupOwner(Self);
      FPopupMenu.WinLeft := X;
      FPopupMenu.WinTop := Y;
      if FPopupMenu.FWinManager <> nil then
        if FPopupMenu.FHidden then
        begin
          if FPopupMenu.FMenuLeft + FPopupMenu.FWinWidth > FPopupMenu.FWinManager.FWinWidth then
            FPopupMenu.WinLeft := X - FPopupMenu.FWinWidth;
          if FPopupMenu.FMenuTop + FPopupMenu.FWinHeight > FPopupMenu.FWinManager.FWinHeight then
            FPopupMenu.WinTop := Y - FPopupMenu.FWinHeight;
        end
        else
        begin
          if FPopupMenu.FWinLeft + FPopupMenu.FWinWidth > FPopupMenu.FWinManager.FWinWidth then
            FPopupMenu.WinLeft := X - FPopupMenu.FWinWidth;
          if FPopupMenu.FWinTop + FPopupMenu.FWinHeight > FPopupMenu.FWinManager.FWinHeight then
            FPopupMenu.WinTop := Y - FPopupMenu.FWinHeight;
        end;
      FPopupMenu.Visible := True;
    end;
  end;
end;

procedure TAoWFrame.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
end;

procedure TAoWFrame.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
end;

procedure TAoWFrame.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAoWFrame]);
end;

end.
