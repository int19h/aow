unit AOWMenu;

{ The AOWMenu unit of aowInt.dpl: TAOWMenu, a pop-up menu window. It belongs to an item of a menu
  bar (OwnerMenuBar and OwnerItem) or of another menu (OwnerMenu: a submenu), places itself under
  the bar's item when it is shown, highlights the item under the mouse and shows the submenus of
  the highlighted item after SubMenuShowDelay updates. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWMenuBar, AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib,
  AoWWinControl, AoWBaseWin, AoWWinGeneric;

type
  { AOWMenu.TAOWMenu (instance size 596). Fields: +$1EC FPopupOwner, +$1F0 FILIndexTSelected,
    +$1F4 FMenuLeft, +$1F8 FMenuTop (SetWinLeft and SetWinTop store the position here while the
    menu is hidden), +$1FC FShowPending (SetVisible was called while hidden), +$200 FSelectedItem
    (the item clicked last, -1 for none; read by OnSelect), +$204 FILTextureSelected, +$208
    FItems, +$20C FItemTypes (never created: SetITStrings fails, original bug), +$210 FOnDrawItem,
    +$218 FItemHeight, +$21C FOwnerMenuBar, +$220 FOwnerMenu, +$224 FSubMenuShowDelay, +$228
    FOnSelect, +$230 FHighlighted (the item under the mouse, -1 for none), +$234 FSubMenuItem (the
    item whose submenus are shown), +$238 FSubMenus (sorted by priority), +$23C FShowDelay
    (updates since the highlight moved), +$240 FDrawItem, +$244 FDrawItemRect (the item drawn
    last, for OnDrawItem).
    VMT (new): SetMenu, SetMenuBar, SetILTSel }
  TAOWMenu = class(TAOWGenericWindow)
  public
    FPopupOwner: TAoWComponent;
    FILIndexTSelected: Integer;
    FMenuLeft: Integer;
    FMenuTop: Integer;
    FShowPending: Boolean;
    FSelectedItem: Integer;
    FILTextureSelected: TInterfaceIL;
    FItems: TStringList;
    FItemTypes: TStringList;
    FOnDrawItem: TNotifyEvent;
    FItemHeight: Integer;
    FOwnerMenuBar: TAOWMenuBar;
    FOwnerMenu: TAOWMenu;
    FSubMenuShowDelay: Integer;
    FOnSelect: TNotifyEvent;
    FHighlighted: Integer;
    FSubMenuItem: Integer;
    FSubMenus: TList;
    FShowDelay: Integer;
    FDrawItem: Integer;
    FDrawItemRect: TRect;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Update; override;
    procedure SetWinLeft(Value: Integer); override;
    procedure SetWinTop(Value: Integer); override;
    procedure SetVisible(Value: Boolean); override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure CheckKeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DetachMenuBar; override;
    procedure SetMenu(Value: TAOWMenu); virtual;
    procedure SetMenuBar(Value: TAOWMenuBar); virtual;
    procedure SetILTSel(Value: TInterfaceIL); virtual;
    procedure DetachMenu;
    procedure SetILTsIndex(Value: Integer);
    procedure SetFStrings(Value: TStringList);
    procedure SetITStrings(Value: TStringList);
    procedure SetPopupOwner(Value: TAoWComponent);
  published
    property ILFrame;
    property ILTextureNormal: TInterfaceIL read FILTexture write SetILTexture;
    property ILTextureSelected: TInterfaceIL read FILTextureSelected write SetILTSel;
    property ILIndexFrame: Integer read FILIndexFrame write FILIndexFrame;
    property ILIndexTNormal: Integer read FILIndexTexture write SetILTIndex;
    property ILIndexTSelected: Integer read FILIndexTSelected write SetILTsIndex;
    property Items: TStringList read FItems write SetFStrings;
    property ItemTypes: TStringList read FItemTypes write SetITStrings;
    property OnChange;
    property OnDrawItem: TNotifyEvent read FOnDrawItem write FOnDrawItem;
    property TextColor;
    property TextSelColor;
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property ItemHeight: Integer read FItemHeight write FItemHeight;
    property OwnerMenuBar: TAOWMenuBar read FOwnerMenuBar write SetMenuBar;
    property OwnerMenu: TAOWMenu read FOwnerMenu write SetMenu;
    property OwnerItem: Integer read FOwnerItem write FOwnerItem;
    property SubMenuShowDelay: Integer read FSubMenuShowDelay write FSubMenuShowDelay;
    property OnSelect: TNotifyEvent read FOnSelect write FOnSelect;
    property WinHeight;
  end;

procedure Register;

implementation

{ TAOWMenu }

constructor TAOWMenu.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FHighlighted := -1;
  FSelectedItem := -1;
  FSubMenuItem := -1;
  FItemHeight := 10;
  FSubMenus := TList.Create;
  FVisible := False;
end;

{ Destroy removes the menu from the lists of its owner menu and menu bar and detaches its
  submenus }
destructor TAOWMenu.Destroy;
var
  I: Integer;
  M: TAOWMenu;
begin
  I := 0;
  if FOwnerMenu <> nil then
    try
      while I < FOwnerMenu.FSubMenus.Count do
      begin
        M := FOwnerMenu.FSubMenus[I];
        if M = Self then
        begin
          FOwnerMenu.FSubMenus.Delete(I);
          I := FOwnerMenu.FSubMenus.Count;
        end;
        Inc(I);
      end;
    except
    end;
  I := 0;
  if FOwnerMenuBar <> nil then
    try
      while I < FOwnerMenuBar.FMenus.Count do
      begin
        M := FOwnerMenuBar.FMenus[I];
        if M = Self then
        begin
          FOwnerMenuBar.FMenus.Delete(I);
          I := FOwnerMenuBar.FMenus.Count;
        end;
        Inc(I);
      end;
    except
    end;
  FItems.Destroy;
  for I := 0 to FSubMenus.Count - 1 do
    TAOWMenu(FSubMenus[I]).DetachMenu;
  FSubMenus.Destroy;
  inherited Destroy;
end;

procedure TAOWMenu.Validate;
begin
  if FILFrame <> nil then
    FILFrame := FILFrame.CheckIL(FILIndexFrame, 8, Self);
  if FILTexture <> nil then
    FILTexture := FILTexture.CheckIL(FILIndexTexture, 1, Self);
  if FILTextureSelected <> nil then
    FILTextureSelected := FILTextureSelected.CheckIL(FILIndexTSelected, 1, Self);
  if (FAOWOwner <> nil) and (FILFrame <> nil) and (FILTexture <> nil) and
    (FILTextureSelected <> nil) and (FAOWFont <> nil) then
    FValid := True;
  inherited Validate;
end;

procedure TAOWMenu.SetWinLeft(Value: Integer);
begin
  if FHidden then
    FMenuLeft := Value
  else
    FWinLeft := Value;
  FDrawn := False;
end;

procedure TAOWMenu.SetWinTop(Value: Integer);
begin
  if FHidden then
    FMenuTop := Value
  else
    FWinTop := Value;
  FDrawn := False;
end;

procedure TAOWMenu.DetachMenu;
begin
  FOwnerMenu := nil;
end;

procedure TAOWMenu.DetachMenuBar;
begin
  FOwnerMenuBar := nil;
end;

{ SetVisible: a menu shown under a menu bar places itself under the bar's selected item, kept
  inside the window manager's screen; hiding it clears the bar's selection }
procedure TAOWMenu.SetVisible(Value: Boolean);
var
  Bar: TAOWMenuBar; W: TAOWBaseWindow; MB: TAOWMenuBar;
begin { Tried Self/menu identities and receiver scope; owner temporaries still differ. }
  if Value <> FVisible then
    if FHidden then
      FShowPending := True
    else
    begin
      FVisible := Value;
      if FVisible = True then
      begin
        FHighlighted := -1;
        if (FWinManager <> nil) and (FOwnerMenuBar <> nil) then
        begin
          MB := FOwnerMenuBar;
          W := MB.FAOWWindow;
          if W <> nil then
          begin
          FWinLeft := W.FWinLeft + MB.FWinLeft + MB.FWinWidth div MB.FItems.Count *
            FOwnerMenuBar.FSelected;
          FWinTop := FOwnerMenuBar.FAOWWindow.FWinTop + FOwnerMenuBar.FWinTop +
            FOwnerMenuBar.FWinHeight;
          if FWinManager.FWinWidth < FWinLeft + FWinWidth then
            FWinLeft := FWinManager.FWinWidth - FWinWidth;
          if FWinTop + FWinHeight > FWinManager.FWinHeight then
            FWinTop := FOwnerMenuBar.FAOWWindow.FWinTop + FOwnerMenuBar.FWinTop - FWinHeight;
          end;
        end;
        FDrawn := False;
        if not FHidden then
        begin
          FBackRect.Right := FWinWidth;
          FBackRect.Bottom := FWinHeight;
          FBackRect.Top := FWinTop;
          FBackRect.Left := FWinLeft;
        end;
        FHidden := False;
        FShowPending := False;
        if Assigned(FOnShow) then
          FOnShow(Self);
      end
      else
      begin
        Bar := FOwnerMenuBar;
        if Bar <> nil then
        begin
          Bar.FSelected := -1;
          Bar.FDrawn := False;
        end;
        FHidden := True;
        if Assigned(FOnHide) then
          FOnHide(Self);
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

{ SetMenu moves the menu from the submenu list of its old owner menu to the list of the new one,
  in priority order }
procedure TAOWMenu.SetMenu(Value: TAOWMenu);
var
  I, NewIndex: Integer;
  M: TAOWMenu;
begin
  if Value <> FOwnerMenu then
  begin
    if FOwnerMenu <> nil then
    begin
      I := 0;
      while I < FOwnerMenu.FSubMenus.Count do
      begin
        M := FOwnerMenu.FSubMenus[I];
        if M = Self then
        begin
          FOwnerMenu.FSubMenus.Delete(I);
          I := FOwnerMenu.FSubMenus.Count;
        end;
        Inc(I);
      end;
    end;
    FOwnerMenu := Value;
    if (FOwnerMenu <> Self) and (FOwnerMenu <> nil) then
    begin
      I := 0;
      NewIndex := -1;
      while I < FOwnerMenu.FSubMenus.Count do
      begin
        M := FOwnerMenu.FSubMenus[I];
        if M.FPriority > FPriority then
        begin
          NewIndex := I;
          I := FOwnerMenu.FSubMenus.Count;
        end;
        Inc(I);
      end;
      if NewIndex = -1 then
        FOwnerMenu.FSubMenus.Add(Self)
      else
        FOwnerMenu.FSubMenus.Insert(NewIndex, Self);
    end;
  end;
end;

{ SetMenuBar: the same for the menu list of the menu bar }
procedure TAOWMenu.SetMenuBar(Value: TAOWMenuBar);
var
  I, NewIndex: Integer;
  M: TAOWMenu;
begin
  if Value <> FOwnerMenuBar then
  begin
    if FOwnerMenuBar <> nil then
    begin
      I := 0;
      while I < FOwnerMenuBar.FMenus.Count do
      begin
        M := FOwnerMenuBar.FMenus[I];
        if M = Self then
        begin
          FOwnerMenuBar.FMenus.Delete(I);
          I := FOwnerMenuBar.FMenus.Count;
        end;
        Inc(I);
      end;
    end;
    FOwnerMenuBar := Value;
    if FOwnerMenuBar <> nil then
    begin
      I := 0;
      NewIndex := -1;
      while I < FOwnerMenuBar.FMenus.Count do
      begin
        M := FOwnerMenuBar.FMenus[I];
        if M.FPriority > FPriority then
        begin
          NewIndex := I;
          I := FOwnerMenuBar.FMenus.Count;
        end;
        Inc(I);
      end;
      if NewIndex = -1 then
        FOwnerMenuBar.FMenus.Add(Self)
      else
        FOwnerMenuBar.FMenus.Insert(NewIndex, Self);
    end;
  end;
end;

procedure TAOWMenu.SetILTSel(Value: TInterfaceIL);
begin
  if Value <> FILTextureSelected then
  begin
    FValid := False;
    FILTextureSelected := Value;
  end;
end;

procedure TAOWMenu.SetILTsIndex(Value: Integer);
begin
  if Value <> FILIndexTSelected then
  begin
    FILIndexTSelected := Value;
    FValid := False;
  end;
end;

{ SetSize: the height fits the items between the top and bottom frame pieces; the menu is placed
  under its menu bar item and inside the window manager's borders; the frame rectangle is set
  for masked menus }
procedure TAOWMenu.SetSize;
var
  MB: TAOWMenuBar;
  W: TAOWBaseWindow;
begin
  if FItemHeight = 0 then
    FItemHeight := FILFrame[FILIndexFrame + 3].Height;
  if FWinHeight = 0 then
    FWinHeight := FILFrame[FILIndexFrame].Height + FILFrame[FILIndexFrame + 7].Height +
      FItems.Count * FItemHeight;
  if FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width > FWinWidth then
    FWinWidth := FILFrame[FILIndexFrame].Width + FILFrame[FILIndexFrame + 2].Width;
  if FILFrame[FILIndexFrame].Height + FItems.Count * FItemHeight +
    FILFrame[FILIndexFrame + 5].Height > FWinHeight then
    FWinHeight := FILFrame[FILIndexFrame].Height + FItems.Count * FItemHeight +
      FILFrame[FILIndexFrame + 5].Height;
  if (FWinManager <> nil) and (FOwnerMenuBar <> nil) then
  begin
    MB := FOwnerMenuBar;
    W := MB.FAOWWindow;
    if W <> nil then
    begin
      FWinLeft := W.FWinLeft + MB.FWinLeft + MB.FWinWidth div MB.FItems.Count *
        FOwnerMenuBar.FSelected;
      FWinTop := FOwnerMenuBar.FAOWWindow.FWinTop + FOwnerMenuBar.FWinTop +
        FOwnerMenuBar.FWinHeight;
      if FWinManager.FWinWidth < FWinLeft + FWinWidth then
        FWinLeft := FWinManager.FWinWidth - FWinWidth;
      if FWinTop + FWinHeight > FWinManager.FWinHeight then
        FWinTop := FOwnerMenuBar.FAOWWindow.FWinTop + FOwnerMenuBar.FWinTop - FWinHeight;
    end;
  end;
  if FUseManagerBorders then
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
  if FMasked then
  begin
    FFrameLeft := FILFrame[FILIndexFrame + 3].Width;
    FFrameRight := FWinWidth - FILFrame[FILIndexFrame + 4].Width;
    FFrameTop := FILFrame[FILIndexFrame + 1].Height;
    FFrameBottom := FWinHeight - FILFrame[FILIndexFrame + 6].Height;
  end;
  if FDoubleBuffered and (FBackSurface <> nil) then
  begin
    FBackSurface.Resize(FWinWidth, FWinHeight);
    if FMasked then
      FBackSurface.Cls(FMaskColor);
  end;
  inherited SetSize;
end;

procedure TAOWMenu.SetFStrings(Value: TStringList);
var
  I: Integer;
begin
  FItems.Clear;
  for I := 0 to Value.Count - 1 do
    FItems.Add(Value[I]);
end;

procedure TAOWMenu.SetITStrings(Value: TStringList);
var
  I: Integer;
begin
  FItemTypes.Clear;
  for I := 0 to Value.Count - 1 do
    FItemTypes.Add(Value[I]);
end;

procedure TAOWMenu.SetPopupOwner(Value: TAoWComponent);
begin
  FPopupOwner := Value;
end;

{ Update: after the highlight rested SubMenuShowDelay updates on an item, the submenus of the
  previous item are hidden and those of the highlighted item are shown beside it }
procedure TAOWMenu.Update;
var
  I: Integer;
  M: TAOWMenu;
begin
  if FValid and FVisible then
  begin
    inherited Update;
    if FHighlighted > -1 then
      if FShowDelay < FSubMenuShowDelay then
        Inc(FShowDelay)
      else
      begin
        if FHighlighted <> FSubMenuItem then
          for I := 0 to FSubMenus.Count - 1 do
          begin
            M := FSubMenus[I];
            if M.FOwnerItem = FSubMenuItem then
              M.SetVisible(False);
          end;
        for I := 0 to FSubMenus.Count - 1 do
        begin
          M := FSubMenus[I];
          if M.FOwnerItem = FHighlighted then
          begin
            M.SetWinLeft(FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 2].Width);
            M.SetWinTop(FWinTop + FILFrame[FILIndexFrame].Height + FItemHeight * FHighlighted);
            M.SetVisible(True);
            FSubMenuItem := FHighlighted;
          end;
        end;
      end;
  end;
end;

{ Draw: the frame, the texture, and the items; the highlighted item on the selected texture }
procedure TAOWMenu.Draw(SurfDesc: TSurfaceDesc);
var
  I: Integer;
  OldClip: TRect;
begin
  try
    if FValid and FVisible then
    begin
      FILFrame.DrawILF(FILIndexFrame, Rect(FWinLeft, FWinTop, FWinWidth, FWinHeight), SurfDesc);
      FILTexture.DrawILT(FILIndexTexture, Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
        FWinTop + FILFrame[FILIndexFrame + 1].Height,
        FWinWidth - FILFrame[FILIndexFrame + 3].Width - FILFrame[FILIndexFrame + 4].Width,
        FWinHeight - FILFrame[FILIndexFrame + 1].Height - FILFrame[FILIndexFrame + 6].Height),
        SurfDesc);
      FAOWFont.Color := FColor;
      OldClip := SurfDesc.ClipRect;
      if FItems.Count > 0 then
        for I := 0 to FItems.Count - 1 do
        begin
          if FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 4].Width < OldClip.Right then
            SurfDesc.ClipRect.Right := FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 4].Width;
          if (I < FItems.Count) and (FItems.Count > 0) then
          begin
            if I = FHighlighted then
            begin
              FAOWFont.Color := FSelColor;
              FILTextureSelected.DrawILT(FILIndexTSelected, Rect(FWinLeft +
                FILFrame[FILIndexFrame + 3].Width, FWinTop + FILFrame[FILIndexFrame].Height +
                FItemHeight * I, FWinWidth - FILFrame[FILIndexFrame + 3].Width -
                FILFrame[FILIndexFrame + 4].Width, FItemHeight), SurfDesc);
            end
            else
              FAOWFont.Color := FColor;
            FAOWFont.SetText(FWinLeft + FBorderWidth + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FBorderHeight + FILFrame[FILIndexFrame].Height + FItemHeight * I,
              FItems[I], SurfDesc);
            FDrawItem := I;
            FDrawItemRect := Rect(FWinLeft + FILFrame[FILIndexFrame + 3].Width,
              FWinTop + FILFrame[FILIndexFrame + 1].Height + FILFrame[FILIndexFrame + 3].Height * I,
              FWinLeft + FWinWidth, FWinTop + FILFrame[FILIndexFrame + 1].Height +
              FILFrame[FILIndexFrame + 3].Height * (I + 1));
            if Assigned(FOnDrawItem) then
              FOnDrawItem(Self);
          end;
          SurfDesc.ClipRect := OldClip;
        end;
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: the controls of the menu first; a click on an item selects it (OnSelect) and
  shows its submenus; a click outside hides the menu unless a submenu took it }
procedure TAOWMenu.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
  Show, Keep: Boolean;
  M: TAOWMenu;
begin
  FHandled := False;
  FRedraw := False;
  FSelectedItem := -1;
  Keep := True;
  if FVisible = True then
  begin
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      if (FHandled = False) and C.FCaptureInput then
        C.CheckMouseDown(Button, Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
    end;
    Show := FVisible;
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
    begin
      if FHandled = False then
      begin
        FRedraw := True;
        FHandled := True;
        if FHighlighted > -1 then
        begin
          Show := False;
          for I := 0 to FSubMenus.Count - 1 do
          begin
            M := FSubMenus[I];
            if M.FHandled and M.FVisible then
              Show := True;
            if (M.FOwnerItem = FHighlighted) and (M.FHandled = False) then
            begin
              M.SetWinLeft(FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 2].Width);
              M.SetWinTop(FWinTop + FILFrame[FILIndexFrame].Height + FItemHeight * FHighlighted);
              M.SetVisible(True);
              Show := True;
              FRedraw := True;
              FSubMenuItem := FHighlighted;
            end;
          end;
          FSelectedItem := FHighlighted;
          if Assigned(FOnSelect) then
            FOnSelect(Self);
        end;
      end;
    end
    else
    begin
      Show := False;
      for I := 0 to FSubMenus.Count - 1 do
      begin
        M := FSubMenus[I];
        if M.FHandled = True then
          if M.FVisible = True then
          begin
            Show := True;
            FRedraw := True;
          end
          else
            Keep := False;
        if not Show then
          FSubMenuItem := -1;
        if Keep = True then
          ;
      end;
    end;
    SetVisible(Show);
    if FHandled and Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWMenu.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  if FVisible = True then
  begin
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      if ((FHandled = False) or (C.FRedraw = True)) and C.FCaptureInput then
        C.CheckMouseUp(Button, Shift, X, Y);
      if C.FHandled = True then
        FHandled := True;
    end;
    if (X > FWinLeft - 1) and (X < FWinLeft + FWinWidth) and (Y > FWinTop - 1) and
      (Y < FWinTop + FWinHeight) then
    begin
      FHandled := True;
      if Assigned(FOnMouseUp) then
        FOnMouseUp(Self, Button, Shift, X, Y);
    end;
  end;
end;

{ CheckMouseMove highlights the item under the mouse; when the highlight moves, the submenus of
  the old item are hidden (by the item index into the submenu list: original bug) }
procedure TAOWMenu.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
var C: TAoWComponent; OldHighlighted, I: Integer;
  SM: TShiftState absolute Shift; XM: Integer absolute X;
  OM: Integer absolute OldHighlighted;
  CM: TAoWComponent absolute C; { Keep the child on the stack and I in a register. }
begin
  FHandled := False;
  FInResizeArea := True;
  if FVisible = True then
  begin
    FRedraw := True;
    OldHighlighted := FHighlighted;
    FCursor := -2;
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := FChildren[I];
      if ((FHandled = False) or (CM.FRedraw = True) or (CM.FToolTipCount > 0)) and CM.FCaptureInput then
        CM.CheckMouseMove(Shift, X, Y);
      if CM.FHandled = True then
        FHandled := True;
    end;
    FHandled := True;
    I := -1;
    if (X > FWinLeft + FILFrame[FILIndexFrame].Width - 1) and
      (X < FWinLeft + FWinWidth - FILFrame[FILIndexFrame + 7].Width) and
      (Y > FWinTop + FILFrame[FILIndexFrame].Height - 1) and
      (Y < FWinTop + FWinHeight - FILFrame[FILIndexFrame + 7].Height) then
    begin
      I := (Y - FWinTop - FILFrame[FILIndexFrame].Height) div FItemHeight;
      if Assigned(FOnMouseMove) then
        FOnMouseMove(Self, Shift, X, Y);
    end;
    if (I > -2) and (I < FItems.Count) then
      FHighlighted := I;
    if I = -1 then
      if FSubMenuItem > -1 then
        for I := 0 to FSubMenus.Count - 1 do
          with TAoWComponent(FSubMenus[I]) do
            if FHandled = True then
              Self.FHighlighted := FOwnerItem;
    if OldHighlighted <> FHighlighted then
    begin
      FShowDelay := 0;
      if (OldHighlighted > -1) and (FSubMenus.Count > OldHighlighted) then
        TAOWMenu(FSubMenus[OldHighlighted]).SetVisible(False);
      FDrawn := False;
      if Assigned(FOnChange) then
        FOnChange(Self);
    end;
  end;
end;

procedure TAOWMenu.CheckKeyPress(var Key: Char);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  for I := 0 to FChildren.Count - 1 do
  begin
    C := FChildren[I];
    C.CheckKeyPress(Key);
    if C.FHandled = True then
      FHandled := True;
  end;
  if Assigned(FOnKeyPress) then
    FOnKeyPress(Self, Key);
end;

procedure TAOWMenu.CheckKeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  C: TAoWComponent;
begin
  FHandled := False;
  for I := 0 to FChildren.Count - 1 do
  begin
    C := FChildren[I];
    C.CheckKeyDown(Key, Shift);
    if C.FHandled = True then
      FHandled := True;
  end;
  if Assigned(FOnKeyDown) then
    FOnKeyDown(Self, Key, Shift);
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWMenu]);
end;

end.
