unit AoWComboBox;

{ The AoWComboBox unit of aowInt.dpl: TAOWComboBox, a drop-down list. Closed, it shows the
  selected item in an edit field; a click opens the list below the field (at PriorityOpened, with
  a vertical scroll bar when one is attached), a click on an item selects it and closes the list. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWVScroll, AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl,
  AoWBaseWin;

type
  { AoWComboBox.TAOWComboBox (instance size 416). Fields: +$114 F114 (the mouse button went down
    on the field), +$118 FOpen (the list is shown), +$11C FItems, +$120 FVScrollBar, +$124 F124
    (the rows the open list shows), +$128 FNumberVisible, +$12C F12C (the first item shown),
    +$130 FListBorderWidth, +$134 FListBorderHeight, +$138 FSelected, +$13C F13C (the item under
    the mouse, -1 for none), +$140 FPriorityOpened, +$144 F144 (the priority before the list was
    opened), +$148 FOnDrawItem, +$150 F150 (the width the scroll bar takes from the list), +$154
    F154 (the scroll bar is visible), +$158 FILEdit, +$15C FILFrame, +$160 FILTextureNormal, +$164
    FILTextureSelected, +$168 FItemHeight, +$16C FOnOpen, +$174 FOnClose, +$17C FILEIndex, +$180
    FILFIndex, +$184 FILTnIndex, +$188 FILTsIndex, +$18C FDrawItem, +$190 FDrawItemRect (the item
    and its rectangle while OnDrawItem runs).
    VMT (new): SetILEdit, SetILEIndex, SetILFrame, SetILFIndex, SetILTNorm, SetILTnIndex,
    SetILTSel, SetILTsIndex, SetIndex }
  TAOWComboBox = class(TAOWControl)
  public
    F114: LongBool;
    FOpen: LongBool;
    FItems: TStringList;
    FVScrollBar: TAOWVScrollBar;
    F124: Integer;
    FNumberVisible: Integer;
    F12C: Integer;
    FListBorderWidth: Integer;
    FListBorderHeight: Integer;
    FSelected: Integer;
    F13C: Integer;
    FPriorityOpened: Integer;
    F144: Integer;
    FOnDrawItem: TNotifyEvent;
    F150: Integer;
    F154: Boolean;
    FILEdit: TInterfaceIL;
    FILFrame: TInterfaceIL;
    FILTextureNormal: TInterfaceIL;
    FILTextureSelected: TInterfaceIL;
    FItemHeight: Integer;
    FOnOpen: TNotifyEvent;
    FOnClose: TNotifyEvent;
    FILEIndex: Integer;
    FILFIndex: Integer;
    FILTnIndex: Integer;
    FILTsIndex: Integer;
    FDrawItem: Integer;
    FDrawItemRect: TRect;
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
    procedure SetILEdit(Value: TInterfaceIL); virtual;
    procedure SetILEIndex(Value: Integer); virtual;
    procedure SetILFrame(Value: TInterfaceIL); virtual;
    procedure SetILFIndex(Value: Integer); virtual;
    procedure SetILTNorm(Value: TInterfaceIL); virtual;
    procedure SetILTnIndex(Value: Integer); virtual;
    procedure SetILTSel(Value: TInterfaceIL); virtual;
    procedure SetILTsIndex(Value: Integer); virtual;
    procedure SetIndex(Value: Integer); virtual;
    procedure SetFStrings(Value: TStringList);
    procedure SetVScroll(Value: TAOWVScrollBar);
  published
    property WinWidth;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property ListBorderWidth: Integer read FListBorderWidth write FListBorderWidth;
    property ListBorderHeight: Integer read FListBorderHeight write FListBorderHeight;
    property VScrollBar: TAOWVScrollBar read FVScrollBar write SetVScroll;
    property NumberVisible: Integer read FNumberVisible write FNumberVisible;
    property OnChange;
    property Selected: Integer read FSelected write SetIndex;
    property PriorityOpened: Integer read FPriorityOpened write FPriorityOpened;
    property OnDrawItem: TNotifyEvent read FOnDrawItem write FOnDrawItem;
    property TextColor;
    property TextSelColor;
    property ILEdit: TInterfaceIL read FILEdit write SetILEdit;
    property ILEIndex: Integer read FILEIndex write SetILEIndex;
    property ILFrame: TInterfaceIL read FILFrame write SetILFrame;
    property ILFIndex: Integer read FILFIndex write SetILFIndex;
    property ILTextureNormal: TInterfaceIL read FILTextureNormal write SetILTNorm;
    property ILTnIndex: Integer read FILTnIndex write SetILTnIndex;
    property ILTextureSelected: TInterfaceIL read FILTextureSelected write SetILTSel;
    property ILTsIndex: Integer read FILTsIndex write SetILTsIndex;
    property ItemHeight: Integer read FItemHeight write FItemHeight;
    property OnOpen: TNotifyEvent read FOnOpen write FOnOpen;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

procedure Register;

implementation

{ TAOWComboBox }

constructor TAOWComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  F13C := -1;
end;

destructor TAOWComboBox.Destroy;
begin
  FItems.Destroy;
  inherited Destroy;
end;

procedure TAOWComboBox.Validate;
begin
  if FILEdit <> nil then
    FILEdit := FILEdit.CheckIL(FILEIndex, 3, Self);
  if FILFrame <> nil then
    FILFrame := FILFrame.CheckIL(FILFIndex, 8, Self);
  if FILTextureNormal <> nil then
    FILTextureNormal := FILTextureNormal.CheckIL(FILTnIndex, 1, Self);
  if FILTextureSelected <> nil then
    FILTextureSelected := FILTextureSelected.CheckIL(FILTsIndex, 1, Self);
  if (FAOWFont <> nil) and (FILEdit <> nil) and (FILFrame <> nil) and
    (FILTextureNormal <> nil) and (FILTextureSelected <> nil) then
    FValid := True;
  inherited Validate;
end;

{ SetSize closes the list and sets up the scroll bar. The scroll bar's range and page are one
  item short of the open list's, and its top is taken from the first edit image (original) }
procedure TAOWComboBox.SetSize;
begin
  FOpen := False;
  if FILEdit[FILEIndex].Width + FILEdit[FILEIndex + 2].Width > FWinWidth then
    FWinWidth := FILEdit[FILEIndex].Width + FILEdit[FILEIndex + 2].Width;
  F124 := FNumberVisible;
  if F124 > FItems.Count then
    F124 := FItems.Count;
  if FItems.Count <= FSelected then
    FSelected := FItems.Count - 1;
  FWinHeight := FILEdit[FILEIndex].Height;
  if FVScrollBar <> nil then
  begin
    if FVScrollBar.FAOWWindow <> FAOWWindow then
      FVScrollBar.SetAOWWindow(FAOWWindow);
    FVScrollBar.Priority := FPriority + 1;
    FVScrollBar.SetFMin(0);
    FVScrollBar.SetFMax(FItems.Count - 2);
    FVScrollBar.SetFPos(F12C);
    FVScrollBar.SetFNum(F124 - 1);
    FVScrollBar.WinHeight := FILFrame[FILFIndex + 6].Height + (FItemHeight * F124 + FBorderHeight);
    FVScrollBar.SetLarge(F124 - 1);
    FVScrollBar.Visible := FOpen;
    if FVScrollBar.FVanishWhenFull and (FItems.Count - 1 < F124) then
      FVScrollBar.Visible := False;
    FVScrollBar.FSized := False;
    FVScrollBar.WinLeft := FWinLeft + FWinWidth - FVScrollBar.FWinWidth;
    FVScrollBar.WinTop := FILEdit[0].Height + FWinTop;
    F154 := FVScrollBar.FVisible;
  end;
  inherited SetSize;
end;

procedure TAOWComboBox.SetIndex(Value: Integer);
begin
  if Value >= FItems.Count then
    Value := FItems.Count - 1;
  if Value <> FSelected then
  begin
    FSelected := Value;
    FDrawn := False;
  end;
end;

procedure TAOWComboBox.SetFStrings(Value: TStringList);
begin
  FItems.Clear;
  FItems.AddStrings(Value);
end;

procedure TAOWComboBox.SetVScroll(Value: TAOWVScrollBar);
begin { Tried parameter identity, with and typed/TObject locals; original scrollbar save still differs. }
  FVScrollBar := Value;
  if Value <> nil then
    Value.Priority := FPriority;
  FSized := False;
end;

procedure TAOWComboBox.SetVisible(Value: Boolean);
begin
  inherited SetVisible(Value);
  if FOpen and (FVScrollBar <> nil) then
    FVScrollBar.Visible := FVisible;
end;

procedure TAOWComboBox.SetILEdit(Value: TInterfaceIL);
begin
  if Value <> FILEdit then
  begin
    FValid := False;
    FILEdit := Value;
  end;
end;

procedure TAOWComboBox.SetILEIndex(Value: Integer);
begin
  if Value <> FILEIndex then
  begin
    FILEIndex := Value;
    FValid := False;
  end;
end;

procedure TAOWComboBox.SetILFrame(Value: TInterfaceIL);
begin
  if Value <> FILFrame then
  begin
    FValid := False;
    FILFrame := Value;
  end;
end;

procedure TAOWComboBox.SetILFIndex(Value: Integer);
begin
  if Value <> FILFIndex then
  begin
    FILFIndex := Value;
    FValid := False;
  end;
end;

procedure TAOWComboBox.SetILTNorm(Value: TInterfaceIL);
begin
  if Value <> FILTextureNormal then
  begin
    FValid := False;
    FILTextureNormal := Value;
  end;
end;

procedure TAOWComboBox.SetILTnIndex(Value: Integer);
begin
  if Value <> FILTnIndex then
  begin
    FILTnIndex := Value;
    FValid := False;
  end;
end;

procedure TAOWComboBox.SetILTSel(Value: TInterfaceIL);
begin
  if Value <> FILTextureSelected then
  begin
    FValid := False;
    FILTextureSelected := Value;
  end;
end;

procedure TAOWComboBox.SetILTsIndex(Value: Integer);
begin
  if Value <> FILTsIndex then
  begin
    FILTsIndex := Value;
    FValid := False;
  end;
end;

{ Draw draws the edit field with the selected item and, when the list is open, the frame, the
  texture of the list, the highlight of the item under the mouse and the items, clipped short of
  the scroll bar; OnDrawItem is called for every item with FDrawItem and FDrawItemRect set }
procedure TAOWComboBox.Draw(SurfDesc: TSurfaceDesc);
var
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
      FILEdit.DrawILLh(FILEIndex, Rect(FAOWWindow.FWinLeft + FWinLeft,
        FAOWWindow.FWinTop + FWinTop, FWinWidth, FWinHeight), SurfDesc);
      if (FSelected > -1) and (FItems.Count > FSelected) then
        FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FBorderWidth,
          FAOWWindow.FWinTop + FWinTop + FBorderHeight, FItems[FSelected], SurfDesc);
      SurfDesc.ClipRect := OldClip;
      if FOpen = True then
      begin
        FILFrame.DrawILF(FILFIndex, Rect(FAOWWindow.FWinLeft + FWinLeft,
          FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height, FWinWidth,
          FILFrame[FILFIndex + 1].Height + FILFrame[FILFIndex + 6].Height +
          FItemHeight * F124 + FListBorderHeight), SurfDesc);
        FILTextureNormal.DrawILT(FILTnIndex, Rect(FAOWWindow.FWinLeft + FWinLeft +
          FILFrame[FILFIndex + 3].Width, FAOWWindow.FWinTop + FWinTop +
          FILEdit[FILEIndex].Height + FILFrame[FILFIndex + 1].Height,
          FWinWidth - FILFrame[FILFIndex + 3].Width - FILFrame[FILFIndex + 4].Width,
          FItemHeight * F124 + FListBorderHeight), SurfDesc);
        if (F13C >= F12C) and (F13C < F124 + F12C) then
          FILTextureSelected.DrawILT(FILTsIndex, Rect(FAOWWindow.FWinLeft + FWinLeft +
            FILFrame[FILFIndex + 3].Width, FAOWWindow.FWinTop + FWinTop +
            FILEdit[FILEIndex].Height + FILFrame[FILFIndex + 1].Height +
            (F13C - F12C) * FItemHeight,
            FWinWidth - FILFrame[FILFIndex + 3].Width - FILFrame[FILFIndex + 4].Width,
            FItemHeight), SurfDesc);
        if FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F150 < OldClip.Right then
          SurfDesc.ClipRect.Right := FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F150;
        for I := 0 to F124 - 1 do
          if I < FItems.Count then
          begin
            if F12C + I = F13C then
              FAOWFont.Color := FSelColor;
            FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FListBorderWidth,
              FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height +
              FILFrame[FILFIndex + 1].Height + FListBorderHeight + FItemHeight * I,
              FItems[F12C + I], SurfDesc);
            if F12C + I = F13C then
              FAOWFont.Color := FColor;
            FDrawItem := F12C + I;
            FDrawItemRect := Rect(FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILFIndex + 3].Width,
              FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex + 1].Height +
              FILFrame[FILFIndex + 1].Height + FItemHeight * I,
              FAOWWindow.FWinLeft + FWinLeft + FILFrame[FILFIndex + 3].Width + FWinWidth,
              FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex + 1].Height +
              FILFrame[FILFIndex + 1].Height + (I + 1) * FItemHeight);
            if Assigned(FOnDrawItem) then
              FOnDrawItem(Self);
          end;
        SurfDesc.ClipRect := OldClip;
      end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ Update keeps the first item shown in step with the scroll bar }
procedure TAOWComboBox.Update;
begin
  inherited Update;
  if FVisible then
  begin
    FRedraw := FOpen;
    if (FVScrollBar <> nil) and (FItems.Count > 0) then
      if FVScrollBar.FPosition <> F12C then
      begin
        F12C := FVScrollBar.FPosition;
        if F12C + F124 > FItems.Count then
          F12C := FItems.Count - F124;
        FDrawn := False;
      end;
  end;
end;

{ CheckMouseDown opens or closes the list with a click on the edit field and closes it with a
  click outside the control }
procedure TAOWComboBox.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height) then
  begin
    FHandled := True;
    if Button = mbLeft then
    begin
      FMouseDown := True;
      F114 := True;
      if (FValid = True) and (FVisible = True) then
      begin
        if FOpen then
        begin
          if F144 <> FPriority then
            Priority := F144;
          FOpen := False;
          FWinHeight := FILEdit[FILEIndex].Height;
          if FVScrollBar <> nil then
            FVScrollBar.Visible := False;
          if Assigned(FOnClose) then
            FOnClose(Self);
        end
        else
        begin
          F144 := FPriority;
          if FPriorityOpened <> FPriority then
            Priority := FPriorityOpened;
          FOpen := True;
          if FItems.Count < F124 then
            F124 := FItems.Count;
          FWinHeight := FILEdit[FILEIndex].Height + FListBorderHeight + FItemHeight * F124 +
            FILFrame[FILFIndex + 1].Height + FILFrame[FILFIndex + 6].Height;
          if FItems.Count < F12C + F124 then
            F12C := FItems.Count - F124;
          FDrawn := False;
          F150 := FILFrame[FILFIndex + 4].Width;
          F154 := False;
          if (FVScrollBar <> nil) and (F124 > 0) then
          begin
            if FPriority + 1 <> FVScrollBar.FPriority then
              FVScrollBar.Priority := FPriority + 1;
            FVScrollBar.SetFMin(0);
            FVScrollBar.SetFMax(FItems.Count - 1);
            FVScrollBar.SetFPos(F12C);
            FVScrollBar.SetFNum(F124);
            FVScrollBar.WinHeight := FILFrame[FILFIndex + 6].Height +
              (FItemHeight * F124 + FBorderHeight);
            FVScrollBar.Visible := True;
            if (FVScrollBar.FVanishWhenFull = True) and (FItems.Count - 1 < F124) then
              FVScrollBar.Visible := False
            else
              F150 := FVScrollBar.FWinWidth;
            F154 := FVScrollBar.FVisible;
            FVScrollBar.FSized := False;
            FVScrollBar.WinLeft := FWinLeft + FWinWidth - FVScrollBar.FWinWidth;
            FVScrollBar.WinTop := FILEdit[FILEIndex].Height + FWinTop;
            FVScrollBar.FDrawn := False;
          end;
          if Assigned(FOnOpen) then
            FOnOpen(Self);
        end;
      end
      else if FOpen = True then
      begin
        if F144 <> FPriority then
          Priority := F144;
        FOpen := False;
        FWinHeight := FILEdit[FILEIndex].Height;
        if FVScrollBar <> nil then
          FVScrollBar.Visible := False;
        if Assigned(FOnClose) then
          FOnClose(Self);
      end;
    end;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end
  else if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    FHandled := True
  else if FOpen then
  begin
    if F144 <> FPriority then
      Priority := F144;
    FOpen := False;
    FWinHeight := FILEdit[FILEIndex].Height;
    if FVScrollBar <> nil then
      FVScrollBar.Visible := False;
    if Assigned(FOnClose) then
      FOnClose(Self);
  end;
end;

{ CheckMouseUp selects the item under the mouse in the open list and closes the list }
procedure TAOWComboBox.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  FHandled := False;
  FMouseDown := False;
  F114 := False;
  FRedraw := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and
    (Y < FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end
  else if (Button = mbLeft) and (FValid = True) and (FVisible = True) and (FOpen = True) then
    if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and
      (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
      (Y > FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height - 1) and
      (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
    begin
      if X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F150 then
      begin
        I := (Y - FAOWWindow.FWinTop - FWinTop - FBorderHeight - FILEdit[FILEIndex].Height) div
          FItemHeight + F12C;
        if I < FItems.Count then
          FSelected := I;
        FOpen := False;
        FRedraw := False;
        FWinHeight := FILEdit[FILEIndex].Height;
        if FVScrollBar <> nil then
          FVScrollBar.Visible := False;
        FHandled := True;
        if Assigned(FOnChange) then
          FOnChange(Self);
        if Assigned(FOnClose) then
          FOnClose(Self);
      end;
    end
    else
    begin
      FOpen := False;
      FRedraw := False;
      FWinHeight := FILEdit[FILEIndex].Height;
      if FVScrollBar <> nil then
        FVScrollBar.Visible := False;
      if Assigned(FOnClose) then
        FOnClose(Self);
    end;
end;

{ CheckMouseMove tracks the item under the mouse in the open list }
procedure TAOWComboBox.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var
  OldItem: Integer;
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  OldItem := F13C;
  F13C := -1;
  if (X >= FAOWWindow.FWinLeft + FWinLeft) and
    (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth - F150) and
    (Y >= FAOWWindow.FWinTop + FWinTop) and
    (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if FOpen then
      if (Y >= FAOWWindow.FWinTop + FWinTop + FBorderHeight + FILEdit[FILEIndex].Height) and
        (Y < FAOWWindow.FWinTop + FWinTop + FILEdit[FILEIndex].Height + FBorderHeight +
        FItemHeight * F124) then
        F13C := (Y - FAOWWindow.FWinTop - FWinTop - FBorderHeight - FILEdit[FILEIndex].Height) div
          FItemHeight + F12C;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
  if (FOpen = True) and (OldItem <> F13C) then
  begin
    FDrawn := False;
    if FVScrollBar <> nil then
      FVScrollBar.FDrawn := False;
  end;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWComboBox]);
end;

end.
