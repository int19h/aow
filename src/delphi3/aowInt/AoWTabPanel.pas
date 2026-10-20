unit AoWTabPanel;

{ The AoWTabPanel unit of aowInt.dpl: TAOWTabPanel, a row of tabs, one per item, in a window.
  Clicking a tab selects it; the panels (TAOWPanel) whose TabPanel is this control are shown when
  their OwnerItem is the selected tab and hidden otherwise. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, GFXE, ImageLib,
  AoWComp, AOWInterfaceImgLib, AoWWinControl, AOWWinManager, AoWBaseWin, AOWToolTip, AoWControl;

type
  { AoWTabPanel.TAOWTabPanel (instance size 304). Fields: +$114 FItems, +$118 FSelected, +$11C
    FILButton, +$120 FBorderHeightSelected (the text offset of the selected tab), +$124
    FILIndexUp, +$128 FILIndexDown, +$12C FPanels (the TAOWPanel objects of the tabs).
    VMT (new): SetILButton, SetILUIndex, SetILDIndex }
  TAOWTabPanel = class(TAOWControl)
  public
    FItems: TStringList;
    FSelected: Integer;
    FILButton: TInterfaceIL;
    FBorderHeightSelected: Integer;
    FILIndexUp: Integer;
    FILIndexDown: Integer;
    FPanels: TList;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Validate; override;
    procedure SetSize; override;
    procedure Draw(SurfDesc: TSurfaceDesc); override;
    procedure CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure CheckMouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure CheckKeyPress(var Key: Char); override;
    procedure SetILButton(Value: TInterfaceIL); virtual;
    procedure SetILUIndex(Value: Integer); virtual;
    procedure SetILDIndex(Value: Integer); virtual;
    procedure SetFStrings(Value: TStringList);
    procedure SetIndex(Value: Integer);
  published
    property AOWFont: TImageLibraryFont read FAOWFont write FAOWFont;
    property Items: TStringList read FItems write SetFStrings;
    property BorderHeight: Integer read FBorderHeight write FBorderHeight;
    property OnChange;
    property Selected: Integer read FSelected write SetIndex;
    property WinWidth;
    property TextColor;
    property TextSelColor;
    property ILButton: TInterfaceIL read FILButton write SetILButton;
    property ILIndexDown: Integer read FILIndexDown write SetILDIndex;
    property ILIndexUp: Integer read FILIndexUp write SetILUIndex;
    property BorderHeightSelected: Integer read FBorderHeightSelected write FBorderHeightSelected;
  end;

procedure Register;

implementation

{ TAOWTabPanel }

constructor TAOWTabPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FItems := TStringList.Create;
  FItems.OnChange := OnChangeText;
  FPanels := TList.Create;
end;

destructor TAOWTabPanel.Destroy;
var
  I: Integer;
  P: TAOWWindowControl;
begin
  for I := 0 to FPanels.Count - 1 do
  begin
    P := FPanels[I];
    P.DetachMenuBar;
  end;
  FPanels.Destroy;
  FItems.Destroy;
  inherited Destroy;
end;

procedure TAOWTabPanel.SetILButton(Value: TInterfaceIL);
begin
  if Value <> FILButton then
  begin
    FValid := False;
    FILButton := Value;
  end;
end;

procedure TAOWTabPanel.SetILUIndex(Value: Integer);
begin
  if Value <> FILIndexUp then
  begin
    FILIndexUp := Value;
    FValid := False;
  end;
end;

procedure TAOWTabPanel.SetILDIndex(Value: Integer);
begin
  if Value <> FILIndexDown then
  begin
    FILIndexDown := Value;
    FValid := False;
  end;
end;

procedure TAOWTabPanel.Validate;
begin
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexUp, 3, Self);
  if FILButton <> nil then
    FILButton := FILButton.CheckIL(FILIndexDown, 3, Self);
  if (FILButton <> nil) and (FAOWFont <> nil) then
    FValid := True;
  inherited Validate;
end;

procedure TAOWTabPanel.SetSize;
begin
  if (FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width) * FItems.Count > FWinWidth then
    FWinWidth := (FILButton[FILIndexUp].Width + FILButton[FILIndexUp + 2].Width) * FItems.Count;
  FWinHeight := FILButton[FILIndexUp].Height;
  if FItems.Count <= FSelected then
    FSelected := FItems.Count - 1;
  inherited SetSize;
end;

procedure TAOWTabPanel.SetFStrings(Value: TStringList);
var
  I: Integer;
begin
  FItems.Clear;
  for I := 0 to Value.Count - 1 do
    FItems.Add(Value[I]);
end;

{ SetIndex selects a tab: the panels of the tab are shown, the others hidden }
procedure TAOWTabPanel.SetIndex(Value: Integer);
var
  I: Integer;
begin
  if Value <> FSelected then
  begin
    FSelected := Value;
    for I := 0 to FPanels.Count - 1 do
      with TAoWComponent(FPanels[I]) do
        if FOwnerItem = Self.FSelected then
          SetVisible(True)
        else
          SetVisible(False);
    if Assigned(FOnChange) then
      FOnChange(Self);
    FDrawn := False;
  end;
end;

{ Draw: the tabs side by side in equal shares of the width, the text centered; the selected tab
  with the down image and its text BorderHeightSelected pixels down }
procedure TAOWTabPanel.Draw(SurfDesc: TSurfaceDesc);
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
          FILButton.DrawILLh(FILIndexUp, Rect(FAOWWindow.FWinLeft + FWinLeft +
            FWinWidth * I div FItems.Count, FAOWWindow.FWinTop + FWinTop,
            FWinWidth div FItems.Count, FWinHeight), SurfDesc);
          if FAOWFont <> nil then
          begin
            FAOWFont.Color := FSelColor;
            FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth * (2 * I + 1) div
              (2 * FItems.Count) - FAOWFont.GetTextWidth(FItems[I]) div 2,
              FAOWWindow.FWinTop + FWinTop + FBorderHeight, FItems[I], SurfDesc);
          end;
        end
        else
        begin
          FILButton.DrawILLh(FILIndexDown, Rect(FAOWWindow.FWinLeft + FWinLeft +
            FWinWidth * I div FItems.Count, FAOWWindow.FWinTop + FWinTop,
            FWinWidth div FItems.Count, FWinHeight), SurfDesc);
          if FAOWFont <> nil then
          begin
            FAOWFont.Color := FColor;
            FAOWFont.SetText(FAOWWindow.FWinLeft + FWinLeft + FWinWidth * (2 * I + 1) div
              (2 * FItems.Count) - FAOWFont.GetTextWidth(FItems[I]) div 2,
              FAOWWindow.FWinTop + FWinTop + FBorderHeightSelected, FItems[I], SurfDesc);
          end;
        end;
      if Assigned(FOnDraw) then
        FOnDraw(Self, SurfDesc);
    end;
  except
    MessageBox(0, 'Exception during Draw', Pointer('Error - ' + Name), 0);
  end;
end;

{ CheckMouseDown: a left click on a tab selects it }
procedure TAOWTabPanel.CheckMouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited CheckMouseDown(Button, Shift, X, Y);
  FHandled := False;
  if (X > FAOWWindow.FWinLeft + FWinLeft - 1) and (X < FAOWWindow.FWinLeft + FWinLeft + FWinWidth) and
    (Y > FAOWWindow.FWinTop + FWinTop - 1) and (Y < FAOWWindow.FWinTop + FWinTop + FWinHeight) then
  begin
    FHandled := True;
    if Button = mbLeft then
      SetIndex((X - FAOWWindow.FWinLeft - FWinLeft) div (FWinWidth div FItems.Count));
    if Assigned(FOnMouseDown) then
      FOnMouseDown(Self, Button, Shift, X, Y);
  end;
end;

procedure TAOWTabPanel.CheckMouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure TAOWTabPanel.CheckMouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TAOWTabPanel.CheckKeyPress(var Key: Char);
begin
  FHandled := False;
end;

procedure Register;
begin
  RegisterComponents('AOW Interface', [TAOWTabPanel]);
end;

end.
