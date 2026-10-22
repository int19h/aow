unit AOWMenuBar;

{ The AOWMenuBar unit of aowInt.dpl: TAOWMenuBar, a horizontal bar of buttons, one per item, in a
  window. Clicking an item selects it and shows the menus (TAOWMenu) that belong to the item
  (their OwnerItem is the item's index); clicking it again closes it. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AOWToolTip, AoWControl, AOWWinManager, AoWComp, AOWInterfaceImgLib, AoWWinControl, AoWBaseWin;

type
  { AOWMenuBar.TAOWMenuBar (instance size 308). Fields: +$114 FItems, +$118 FSelected (-1 for
    none), +$11C FILButton, +$120 FLastSelected, +$124 FILIndexUp, +$128 FILIndexDown, +$12C
    FMenus (the TAOWMenu objects whose OwnerMenuBar is this bar), +$130 F130 (only cleared and
    tested: a click on the item last selected then does nothing).
    VMT (new): SetILButton, SetILUIndex, SetILDIndex }
  TAOWMenuBar = class(TAOWControl)
  public
    FItems: TStringList;
    FSelected: Integer;
    FILButton: TInterfaceIL;
    FLastSelected: Integer;
    FILIndexUp: Integer;
    FILIndexDown: Integer;
    FMenus: TList;
    F130: Boolean;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure ReAlign; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILButton(Value: TInterfaceIL); virtual;
    procedure SetILUIndex(Value: Integer); virtual;
    procedure SetILDIndex(Value: Integer); virtual;
    procedure SetFStrings(Value: TStringList);
  published
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property BorderWidth: Integer read FBorderWidth write FBorderWidth;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property OnChange;
    property Selected: Integer read FSelected write FSelected;
    property WinWidth;
    property TextColor;
    property TextSelColor;
    property ILButton: TInterfaceIL read FILButton write SetILButton;
    property ILIndexDown: Integer read FILIndexDown write SetILDIndex;
    property ILIndexUp: Integer read FILIndexUp write SetILUIndex;
  end;

procedure Register;

implementation
uses AoWVScroll;

{ TAOWMenuBar }

constructor TAOWMenuBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FMenus := TList.Create;
  FSelected := -1;
end;

destructor TAOWMenuBar.Destroy;
var
  I: Integer;
  M: TAOWWindowControl;
begin
  for I := 0 to FMenus.Count - 1 do
  begin
    M := FMenus[I];
    M.DetachMenuBar;
  end;
  FMenus.Destroy;
  FItems.Destroy;
  inherited Destroy;
end;

procedure TAOWMenuBar.SetILButton(Value: TInterfaceIL);
begin
  if Value <> FILButton then
  begin
    FValid := False;
    FILButton := Value;
  end;
end;

procedure TAOWMenuBar.Validate;
begin
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexUp, 3, Self);
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexDown, 3, Self);
  if FILButton <> nil then
    FValid := True;
  inherited Validate;
end;

{ The bar is at least as wide as one up and one down button per item }
procedure TAOWMenuBar.SetSize;
var
  I: Integer;
begin
  if (FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width) * FItems.Count > FWinWidth then
    FWinWidth := (FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width) * FItems.Count;
  FWinHeight := FILButton[FILIndexUp].Height;
  for I := 0 to FMenus.Count - 1 do
    TAoWComponent(FMenus[I]).FAligned := False;
  inherited SetSize;
end;

procedure TAOWMenuBar.ReAlign;
var
  I: Integer;
begin
  for I := 0 to FMenus.Count - 1 do
    TAoWComponent(FMenus[I]).FAligned := False;
  inherited ReAlign;
end;

procedure TAOWMenuBar.SetILUIndex(Value: Integer);
begin
  if Value <> FILIndexUp then
  begin
    FILIndexUp := Value;
    FValid := False;
  end;
end;

procedure TAOWMenuBar.SetILDIndex(Value: Integer);
begin
  if Value <> FILIndexDown then
  begin
    FILIndexDown := Value;
    FValid := False;
  end;
end;

procedure TAOWMenuBar.SetFStrings(Value: TStringList);
var
  I: Integer;
begin
  FItems.Clear;
  for I := 0 to Value.Count - 1 do
    FItems.Add(Value[I]);
end;

{ Draw: the items side by side, each in an equal share of the width; the selected one with the up
  image and the text one pixel lower }
procedure TAOWMenuBar.Draw(SurfDesc: TSurfaceDesc);
var
  I: Integer;
  OldClip: TRect;
begin
  try
    if FValid and FVisible then
    begin
      if Assigned(FOnPreDraw) then
        FOnPreDraw(Self, SurfDesc);
      OldClip := SurfDesc.ClipRect;
      for I := 0 to FItems.Count - 1 do
        if I <> FSelected then
        begin
          FILButton.DrawILLh(FILIndexDown, Rect(FAOWWindow.FWinLeft + FWinLeft +
            FWinWidth * I div FItems.Count, FAOWWindow.FWinTop + FWinTop,
            FWinWidth div FItems.Count, FWinHeight), SurfDesc);
          if FAOWFont <> nil then
          begin
            FAOWFont.Color := FSelColor;
            FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth * I div FItems.Count +
              FBorderWidth, FAOWWindow.FWinTop + FWinTop + FBorderHeight, FItems[I], SurfDesc);
          end;
        end
        else
        begin
          FILButton.DrawILLh(FILIndexUp, Rect(FAOWWindow.FWinLeft + FWinLeft +
            FWinWidth * I div FItems.Count, FAOWWindow.FWinTop + FWinTop,
            FWinWidth div FItems.Count, FWinHeight), SurfDesc);
          if FAOWFont <> nil then
          begin
            FAOWFont.Color := FColor;
            FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth * I div FItems.Count +
              FBorderWidth, FAOWWindow.FWinTop + FWinTop + FBorderHeight + 1, FItems[I], SurfDesc);
          end;
        end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: a left click on an item selects it and shows its menus, or closes it when it
  was selected; a click outside the bar closes the selected item }
procedure TAOWMenuBar.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  I: Integer;
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    FRedraw := True;
    if Button = mbLeft then
    begin
      I := (X - FAOWWindow.FWinLeft - FWinLeft) div (FWinWidth div FItems.Count);
      if I = FSelected then
      begin
        FSelected := -1;
        if Assigned(FOnChange) then
          FOnChange(Self);
        FDrawn := False;
      end
      else if not F130 or (I > -1) and (I <> FLastSelected) then
      begin
        FSelected := I;
        FLastSelected := I;
        for I := 0 to FMenus.Count - 1 do
          with TAoWComponent(FMenus[I]) do
            if FOwnerItem = Self.FSelected then
              SetVisible(True);
        if Assigned(FOnChange) then
          FOnChange(Self);
        FDrawn := False;
      end;
    end;
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end
  else if FSelected > -1 then
  begin
    FSelected := -1;
    FDrawn := False;
  end;
  F130 := False;
end;

procedure TAOWMenuBar.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) and
    (FValid = True) and (FVisible = True) then
  begin
    FHandled := True;
    if Assigned(FOnMouseUp) then
      FOnMouseUp(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWMenuBar.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseMove(Shift, X, Y);
  FHandled := False;
  if (X >= FAOWWindow.FWinLeft + FWinLeft) and (X <= FAOWWindow.FWinLeft + FWinLeft + FWinWidth - 1) and
    (Y >= FAOWWindow.FWinTop + FWinTop) and (Y <= FAOWWindow.FWinTop + FWinTop + FWinHeight - 1) then
  begin
    FHandled := True;
    if Assigned(FOnMouseMove) then
      FOnMouseMove(Self, Shift, X, Y);
  end;
end;

procedure TAOWMenuBar.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWMenuBar]);
end;

end.
