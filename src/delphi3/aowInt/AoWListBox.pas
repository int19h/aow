unit AoWListBox;

{ The AoWListBox unit of aowInt.dpl: TAOWListBox, a list of text items in a frame (or without one,
  when the image libraries are missing) with an optional vertical scroll bar, a highlight of the
  selected item, a double click event and a popup menu on the right mouse button. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWMenuBar, AOWMenu, AoWVScroll, AOWToolTip, AoWControl, AOWWinManager,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  TLBType = (lbNormal, lbBlank);

  { AoWListBox.TAOWListBox (instance size 396). Fields: +$114 FItems, +$118 FVScrollBar, +$11C
    F11C (the rows shown), +$120 FSelected, +$124 F124 (set to -1 by SetSize, otherwise unused),
    +$128 FOnPreDrawItem, +$130 FOnDrawItem, +$138 F138 (the width the frame or the scroll bar
    takes at the right), +$13C F13C (the scroll bar is visible), +$140 FILFrame, +$144
    FILTextureNormal, +$148 FILTextureSelected, +$14C FItemHeight, +$150 FOnDoubleClick, +$158
    FTextAlign, +$15C F15C (the first item shown), +$160 F160 (0: drawn with the frame and the
    textures, 1: text only), +$164 FILIndexFrame, +$168 FILIndexTNormal, +$16C FILIndexTSelected,
    +$170 FPopupMenu, +$174 FDrawItem, +$178 FDrawItemRect (the item and its rectangle while
    OnPreDrawItem and OnDrawItem run), +$188 F188 (the item under the mouse, -1 for none).
    VMT (new): SetILFrame, SetILTNorm, SetILTSel }
  TAOWListBox = class(TAOWControl)
  public
    FItems: TStringList;
    FVScrollBar: TAOWVScrollBar;
    F11C: Integer;
    FSelected: Integer;
    F124: Integer;
    FOnPreDrawItem: TAoWOnDrawItemEvent;
    FOnDrawItem: TAoWOnDrawItemEvent;
    F138: Integer;
    F13C: Boolean;
    FILFrame: TInterfaceIL;
    FILTextureNormal: TInterfaceIL;
    FILTextureSelected: TInterfaceIL;
    FItemHeight: Integer;
    FOnDoubleClick: TNotifyEvent;
    FTextAlign: TaowTextAlign;
    F15C: Integer;
    F160: Byte;
    FILIndexFrame: Integer;
    FILIndexTNormal: Integer;
    FILIndexTSelected: Integer;
    FPopupMenu: TAOWMenu;
    FDrawItem: Integer;
    FDrawItemRect: TRect;
    F188: Integer;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILTNorm(Value: TInterfaceIL); virtual;
    procedure SetILTSel(Value: TInterfaceIL); virtual;
    procedure SetFStrings(Value: TStringList);
    procedure SetIndex(Value: Integer);
    procedure SetListOff(Value: Integer);
    procedure SetVScroll(Value: TAOWVScrollBar);
    procedure SetILFIndex(Value: Integer);
    procedure SetILTnIndex(Value: Integer);
    procedure SetILTsIndex(Value: Integer);
    property ListOffset: Integer read F15C write SetListOff;
  published
    property WinWidth;
    property WinHeight;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property VScrollBar: TAOWVScrollBar read FVScrollBar write SetVScroll;
    property OnChange;
    property OnDoubleClick: TNotifyEvent read FOnDoubleClick write FOnDoubleClick;
    property Selected: Integer read FSelected write SetIndex;
    property OnDrawItem: TAoWOnDrawItemEvent read FOnDrawItem write FOnDrawItem;
    property OnPreDrawItem: TAoWOnDrawItemEvent read FOnPreDrawItem write FOnPreDrawItem;
    property TextColor;
    property TextSelColor;
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILTextureNormal: TInterfaceIL read FILTextureNormal write SetILTNorm;
    property ILTextureSelected: TInterfaceIL read FILTextureSelected write SetILTSel;
    property ILIndexFrame: Integer read FILIndexFrame write SetILFIndex;
    property ILIndexTNormal: Integer read FILIndexTNormal write SetILTnIndex;
    property ILIndexTSelected: Integer read FILIndexTSelected write SetILTsIndex;
    property ItemHeight: Integer read FItemHeight write FItemHeight;
    property PopupMenu: TAOWMenu read FPopupMenu write FPopupMenu;
    property TextAlign: TaowTextAlign read FTextAlign write FTextAlign;
  end;

procedure Register;

implementation

{ TAOWListBox }

constructor TAOWListBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  F11C := 3;
  FItemHeight := 10;
end;

destructor TAOWListBox.Destroy;
begin
  FItems.Destroy;
  inherited Destroy;
end;

{ Validate: a list box needs only its font; without all three image libraries it is drawn as
  text only }
procedure TAOWListBox.Validate;
begin
  if FAOWFont <> nil then
  begin
    if FILFrame <> nil then
      FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
    if FILTextureNormal <> nil then
      FILTextureNormal := FILTextureNormal.CheckIL(FILIndexTNormal, 1, Self);
    if FILTextureSelected <> nil then
      FILTextureSelected := FILTextureSelected.CheckIL(FILIndexTSelected, 1, Self);
    if (FILFrame <> nil) and (FILTextureNormal <> nil) and (FILTextureSelected <> nil) then
      F160 := 0
    else
      F160 := 1;
    FValid := True;
  end;
  inherited Validate;
end;

procedure TAOWListBox.SetSize;
begin
  if FItemHeight < 1 then
    FItemHeight := 10;
  case F160 of
    0:
      begin
        if FILFrame[FILIndexFrame + 1].Height + FILFrame[FILIndexFrame + 6].Height > FWinHeight then
          FWinHeight := FILFrame[FILIndexFrame + 1].Height + FILFrame[FILIndexFrame + 6].Height;
        if FILFrame[FILIndexFrame + 3].Width + FILFrame[FILIndexFrame + 4].Width > FWinWidth then
          FWinWidth := FILFrame[FILIndexFrame + 3].Width + FILFrame[FILIndexFrame + 4].Width;
        F11C := (FWinHeight - FILFrame[FILIndexFrame + 1].Height -
          FILFrame[FILIndexFrame + 6].Height) div FItemHeight;
        F138 := FILFrame[FILIndexFrame + 4].Width;
        FMasked := False;
      end;
    1:
      begin
        F11C := FWinHeight div FItemHeight;
        F138 := 0;
        FMasked := True;
      end;
  end;
  if FItems.Count < F11C then
    F11C := FItems.Count;
  if F11C < 1 then
    F11C := 1;
  if FItems.Count <= FSelected then
    FSelected := FItems.Count - 1;
  if FItems.Count < F15C + F11C then
    F15C := FItems.Count - F11C;
  if F15C < 0 then
    F15C := 0;
  F13C := False;
  if FVScrollBar <> nil then
  begin
    F124 := -1;
    if FVScrollBar.FAOWWindow <> FAOWWindow then
      FVScrollBar.SetAOWWindow(FAOWWindow);
    FVScrollBar.Priority := FPriority + 1;
    FVScrollBar.SetFMin(0);
    FVScrollBar.SetFMax(FItems.Count - 1);
    FVScrollBar.SetFPos(F15C);
    FVScrollBar.SetFNum(F11C);
    FVScrollBar.WinHeight := FWinHeight;
    FVScrollBar.SetLarge(F11C - 1);
    FVScrollBar.Visible := FVisible;
    if FVScrollBar.FVanishWhenFull and (FItems.Count - 1 < F11C) then
      FVScrollBar.Visible := False
    else
      F138 := FVScrollBar.FWinWidth;
    FVScrollBar.FSized := False;
    FVScrollBar.WinLeft := FWinLeft + FWinWidth - FVScrollBar.FWinWidth;
    FVScrollBar.WinTop := FWinTop;
    F13C := FVScrollBar.FVisible;
  end;
  inherited SetSize;
end;

procedure TAOWListBox.SetFStrings(Value: TStringList);
begin
  FItems.Clear;
  FItems.AddStrings(Value);
end;

procedure TAOWListBox.SetIndex(Value: Integer);
begin
  if Value >= FItems.Count then
    Value := FItems.Count - 1;
  if Value <> FSelected then
  begin
    FSelected := Value;
    FDrawn := False;
  end;
end;

procedure TAOWListBox.SetListOff(Value: Integer);
begin
  if Value >= FItems.Count then
    Value := FItems.Count - 1;
  if Value < 0 then
    Value := 0;
  if Value <> F15C then
  begin
    F15C := Value;
    FDrawn := False;
  end;
end;

procedure TAOWListBox.SetVScroll(Value: TAOWVScrollBar);
begin
  FVScrollBar := Value;
  if Value <> nil then
    Value.Priority := FPriority;
  Priority := FPriority;
  FSized := False;
end;

procedure TAOWListBox.SetVisible(Value: Boolean);
begin
  inherited SetVisible(Value);
  if FVScrollBar <> nil then
    FVScrollBar.Visible := FVisible;
end;

procedure TAOWListBox.SetILFIndex(Value: Integer);
begin
  if Value <> FILIndexFrame then
  begin
    FILIndexFrame := Value;
    FValid := False;
  end;
end;

procedure TAOWListBox.SetILTnIndex(Value: Integer);
begin
  if Value <> FILIndexTNormal then
  begin
    FILIndexTNormal := Value;
    FValid := False;
  end;
end;

procedure TAOWListBox.SetILTsIndex(Value: Integer);
begin
  if Value <> FILIndexTSelected then
  begin
    FILIndexTSelected := Value;
    FValid := False;
  end;
end;

procedure TAOWListBox.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAOWListBox.SetILTNorm(Value: TInterfaceIL);
begin
  if Value <> FILTextureNormal then
  begin
    FValid := False;
    FILTextureNormal := Value;
  end;
end;

procedure TAOWListBox.SetILTSel(Value: TInterfaceIL);
begin
  if Value <> FILTextureSelected then
  begin
    FValid := False;
    FILTextureSelected := Value;
  end;
end;

{ Draw draws the frame and the texture, then the visible items (one more than fit: the loop runs
  to F11C, original) clipped to the inside, the selected one on its highlight texture }
procedure TAOWListBox.Draw(SurfDesc: TSurfaceDesc);
var
  L, W, T, H: Integer;
  OldClip: TRect;
  I: Integer;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      FAOWFont.Color := FColor;
      OldClip := SurfDesc.ClipRect;
      case F160 of
        0:
          begin
            FILFrame.DrawILF(FILIndexFrame, Rect(FAOWWindow.FWinLeft + FWinLeft,
              FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
            FILTextureNormal.DrawILT(FILIndexTNormal, Rect(FAOWWindow.FWinLeft + FWinLeft +
              FILFrame[FILIndexFrame + 3].Width, FAOWWindow.FWinTop + FWinTop +
              FILFrame[FILIndexFrame + 1].Height,
              FWinWidth - FILFrame[FILIndexFrame + 3].Width - F138,
              FWinHeight - FILFrame[FILIndexFrame + 1].Height -
              FILFrame[FILIndexFrame + 6].Height), SurfDesc);
            L := FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILIndexFrame + 3].Width;
            T := FAOWWindow.FWinTop + FWinTop + FILFrame[FILIndexFrame + 1].Height;
            H := FWinHeight - FILFrame[FILIndexFrame + 1].Height -
              FILFrame[FILIndexFrame + 6].Height;
            W := FWinWidth - FILFrame[FILIndexFrame + 3].Width - F138;
          end;
      else
        L := FAOWWindow.FWinLeft + FWinLeft;
        T := FAOWWindow.FWinTop + FWinTop;
        H := FWinHeight;
        W := FWinWidth - F138;
      end;
      if L + W < OldClip.Right then
        SurfDesc.ClipRect.Right := L + W;
      if T + H < OldClip.Bottom then
        SurfDesc.ClipRect.Bottom := T + H;
      for I := 0 to F11C do
        if F15C + I < FItems.Count then
        begin
          FDrawItem := F15C + I;
          FDrawItemRect := Rect(L, FItemHeight * I + T, L + W, (I + 1) * FItemHeight + T);
          if FDrawItemRect.Bottom > SurfDesc.ClipRect.Bottom then
            FDrawItemRect.Bottom := SurfDesc.ClipRect.Bottom;
          if Assigned(FOnPreDrawItem) then
            FOnPreDrawItem(Self, FDrawItemRect, FDrawItem, SurfDesc);
          if F15C + I = FSelected then
          begin
            FAOWFont.Color := FSelColor;
            if F160 = 0 then
              FILTextureSelected.DrawILT(FILIndexTSelected, Rect(L, FItemHeight * I + T, W,
                FItemHeight), SurfDesc);
          end
          else
            FAOWFont.Color := FColor;
          case FTextAlign of
            taLeft:
              FAOWFont.SetText(FBorderWidth + L, FBorderHeight + T + FItemHeight * I,
                FItems[F15C + I], SurfDesc);
            taRight:
              FAOWFont.SetText(L + W - FBorderWidth - FAOWFont.GetTextWidth(FItems[F15C + I]),
                FBorderHeight + T + FItemHeight * I, FItems[F15C + I], SurfDesc);
          else
            FAOWFont.SetText(L + W div 2 - FAOWFont.GetTextWidth(FItems[F15C + I]) div 2,
              FBorderHeight + T + FItemHeight * I, FItems[F15C + I], SurfDesc);
          end;
          if Assigned(FOnDrawItem) then
            FOnDrawItem(Self, FDrawItemRect, FDrawItem, SurfDesc);
        end;
      SurfDesc.ClipRect := OldClip;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ Update keeps the first item shown in step with the scroll bar }
procedure TAOWListBox.Update;
begin
  if FVisible and (FVScrollBar <> nil) and (FItems.Count > 0) then
    if FVScrollBar.FPosition <> F15C then
    begin
      F15C := FVScrollBar.FPosition;
      if F15C + F11C > FItems.Count then
        F15C := FItems.Count - F11C;
      if F15C < 0 then
        F15C := 0;
      FDrawn := False;
    end;
  inherited Update;
end;

{ CheckMouseDown selects the item under the mouse unless the owner already handled the click;
  a double click calls OnDoubleClick, the right button opens the popup menu at the mouse, moved
  back inside the window manager when it would stick out }
procedure TAOWListBox.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if not FAOWOwner.FHandled and (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F138) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if F160 = 0 then
      I := (Y - FAOWWindow.FWinTop - FWinTop - FILFrame[FILIndexFrame].Height) div FItemHeight +
        F15C
    else
      I := (Y - FAOWWindow.FWinTop - FWinTop) div FItemHeight + F15C;
    if FItems.Count > I then
    begin
      if I <> FSelected then
      begin
        FSelected := I;
        FDrawn := False;
        if Assigned(FOnChange) then
          FOnChange(Self);
      end;
      if (Button = mbLeft) and ([ssDouble] * Shift = [ssDouble]) and Assigned(FOnDoubleClick) then
        FOnDoubleClick(Self);
      if (FSelected > -1) and (Button = mbRight) and (FPopupMenu <> nil) then
      begin
        FPopupMenu.SetPopupOwner(Self);
        FPopupMenu.WinLeft := X;
        FPopupMenu.WinTop := Y;
        if FPopupMenu.WinManager <> nil then
          if FPopupMenu.FHidden then
          begin
            if FPopupMenu.FMenuLeft + FPopupMenu.WinWidth > FPopupMenu.WinManager.WinWidth then
              FPopupMenu.WinLeft := X - FPopupMenu.WinWidth;
            if FPopupMenu.FMenuTop + FPopupMenu.WinHeight > FPopupMenu.WinManager.WinHeight then
              FPopupMenu.WinTop := Y - FPopupMenu.WinHeight;
          end
          else
          begin
            if FPopupMenu.WinLeft + FPopupMenu.WinWidth > FPopupMenu.WinManager.WinWidth then
              FPopupMenu.WinLeft := X - FPopupMenu.WinWidth;
            if FPopupMenu.WinTop + FPopupMenu.WinHeight > FPopupMenu.WinManager.WinHeight then
              FPopupMenu.WinTop := Y - FPopupMenu.WinHeight;
          end;
        FPopupMenu.Visible := True;
      end;
    end;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWListBox.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F138) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

{ CheckMouseMove tracks the item under the mouse }
procedure TAOWListBox.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (X < FAOWWindow.FWinLeft + FWinLeft) or
    (X > FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F138 - 1) or
    (Y < FAOWWindow.FWinTop + FWinTop) or
    (Y > FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
    F188 := -1
  else
  begin
    FHandled := True;
    if F160 = 0 then
      F188 := (Y - FAOWWindow.FWinTop - FWinTop - FILFrame[FILIndexFrame].Height) div
        FItemHeight + F15C
    else
      F188 := (Y - FAOWWindow.FWinTop - FWinTop) div FItemHeight + F15C;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure TAOWListBox.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWListBox]);
end;

end.
