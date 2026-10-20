unit AoWDialogForm;

{ The AoWDialogForm unit of aowInt.dpl: TDialog, the design-time editor of a window of the AoW
  interface (TAOWComponentEditor opens it). It draws the window and its controls into a TDisplay,
  lets the user pick a control (in the combo box or with the mouse), drag it on a grid, and set
  its position and size with the up-down buttons. The original has a DFM; here the component
  fields are plain published fields and the event handlers published methods. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ComCtrls,
  DsgnIntf, GFXE, DisplayC, AoWComp, AOWInterfaceImgLib, AoWWinControl;

type
  { AoWDialogForm.TDialog (instance size 664). The components (+$1DC Display1 .. +$22C
    CompCombo), then +$230 FWindow (the window being edited), +$234 FOldLeft, +$238 FOldTop (the
    window's position while it is drawn at 0, 0), +$23C FSurfDesc (the locked back surface of the
    display), +$278 FSelected (the index of the selected control, -1 for the window itself), +$27C
    FChild (the control at hand), +$280 FDragX, +$284 FDragY (the mouse position inside the dragged
    control), +$288 FOldWidth, +$28C FOldHeight (the size of the window at the last Draw), +$290
    FDragging, +$291 FComboSet (the combo box shows the selection), +$292 FSelectionShown (the
    selection was passed to the designer), +$294 FDesigner. }
  TDialog = class(TForm)
    Display1: TDisplay;
    Windows16DC1: TWindows16DC;
    Label8: TLabel;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label9: TLabel;
    TopEdit: TEdit;
    LeftEdit: TEdit;
    UpDown2: TUpDown;
    UpDown3: TUpDown;
    HeightEdit: TEdit;
    WidthEdit: TEdit;
    UpDown6: TUpDown;
    UpDown7: TUpDown;
    GridXEdit: TEdit;
    GridYEdit: TEdit;
    UpDown8: TUpDown;
    UpDown9: TUpDown;
    CompCombo: TComboBox;
    procedure Display1UpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure Display1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure UpDown2Click(Sender: TObject; Button: TUDBtnType);
    procedure Display1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure Display1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer);
    procedure UpDown3Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown6Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown7Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown9Click(Sender: TObject; Button: TUDBtnType);
    procedure UpDown8Click(Sender: TObject; Button: TUDBtnType);
    procedure CompComboChange(Sender: TObject);
  public
    FWindow: TAOWWindowControl;
    FOldLeft: Integer;
    FOldTop: Integer;
    FSurfDesc: TSurfaceDesc;
    FSelected: Integer;
    FChild: TAoWComponent;
    FDragX: Integer;
    FDragY: Integer;
    FOldWidth: Integer;
    FOldHeight: Integer;
    FDragging: Boolean;
    FComboSet: Boolean;
    FSelectionShown: Boolean;
    FDesigner: TFormDesigner;
    procedure Draw(AWindow: TComponent; ADesigner: TFormDesigner);
  end;

var
  Dialog: TDialog;

implementation

{ TDialog }

{ Draw fills the combo box with the window and its controls, sizes the display and the form to
  the window and shows the position and size of the selection }
procedure TDialog.Draw(AWindow: TComponent; ADesigner: TFormDesigner);
var
  I: Integer;
begin
  FWindow := TAOWWindowControl(AWindow);
  FDesigner := ADesigner;
  FOldHeight := FWindow.FWinHeight;
  FOldWidth := FWindow.FWinWidth;
  CompCombo.Items.Clear;
  CompCombo.Items.Add(FWindow.Name);
  if FSelected = -1 then
    I := 0;
  for I := 0 to FWindow.FChildren.Count - 1 do
  begin
    FChild := FWindow.FChildren[I];
    CompCombo.Items.Add(FChild.Name);
    if not FSelectionShown and (I = FSelected) then
      FDesigner.SelectComponent(FChild);
  end;
  if not FSelectionShown then
    FSelectionShown := True
  else
    FDesigner.Modified;
  CompCombo.Text := CompCombo.Items[FSelected + 1];
  Display1.Width := FWindow.FWinWidth;
  Display1.Height := FWindow.FWinHeight;
  ClientWidth := FWindow.FWinWidth + 160;
  if FWindow.FWinHeight < 213 then
    ClientHeight := 213
  else
    ClientHeight := FWindow.FWinHeight;
  if FSelected = -1 then
  begin
    TopEdit.Text := IntToStr(FWindow.FWinTop);
    LeftEdit.Text := IntToStr(FWindow.FWinLeft);
    HeightEdit.Text := IntToStr(FWindow.FWinHeight);
    WidthEdit.Text := IntToStr(FWindow.FWinWidth);
    UpDown2.Position := FWindow.FWinTop;
    UpDown3.Position := FWindow.FWinLeft;
    UpDown6.Position := FWindow.FWinWidth;
    UpDown7.Position := FWindow.FWinHeight;
  end
  else if FSelected < FWindow.FChildren.Count then
  begin
    FChild := FWindow.FChildren[FSelected];
    TopEdit.Text := IntToStr(FChild.FWinTop);
    LeftEdit.Text := IntToStr(FChild.FWinLeft);
    HeightEdit.Text := IntToStr(FChild.FWinHeight);
    WidthEdit.Text := IntToStr(FChild.FWinWidth);
    UpDown2.Position := FChild.FWinTop;
    UpDown3.Position := FChild.FWinLeft;
    UpDown6.Position := FChild.FWinWidth;
    UpDown7.Position := FChild.FWinHeight;
  end;
end;

{ Display1UpdateFrame draws the window at 0, 0 into the display's back surface }
procedure TDialog.Display1UpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  OldVisible: Boolean;
  C: TAoWComponent;
begin
  if ((FWindow <> nil) and Visible) = True then
    if Name = FWindow.Name + 'IntDlg' then
    begin
      if not FComboSet then
      begin
        CompCombo.Text := CompCombo.Items[FSelected + 1];
        FComboSet := True;
      end;
      C := FWindow;
      C.FBltCount := 0;
      C.FDrawCount := 0;
      C := C.FAOWOwner;
      while C <> nil do
      begin
        C.FBltCount := 0;
        C.FDrawCount := 0;
        C := C.FAOWOwner;
      end;
      FWindow.FValid := False;
      OldVisible := FWindow.FVisible;
      FWindow.Visible := True;
      FWindow.Setup;
      if (FWindow.FWinHeight <> FOldHeight) or (FWindow.FWinWidth <> FOldWidth) then
        Draw(FWindow, FDesigner);
      FWindow.Update;
      FOldLeft := FWindow.FWinLeft;
      FOldTop := FWindow.FWinTop;
      FWindow.FWinLeft := 0;
      FWindow.FWinTop := 0;
      Display1.ActiveDC.GetSurface(1).Cls(0);
      Display1.ActiveDC.GetSurface(1).Lock(FSurfDesc);
      FWindow.DrawSurfDesc(FSurfDesc);
      Display1.ActiveDC.GetSurface(1).Unlock;
      FWindow.FWinLeft := FOldLeft;
      FWindow.FWinTop := FOldTop;
      FWindow.Visible := OldVisible;
    end;
end;

{ Display1MouseDown selects the last visible control under the mouse (or the window) and starts
  dragging it }
procedure TDialog.Display1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  I, Old: Integer;
begin
  Old := FSelected;
  FSelected := -1;
  for I := 0 to FWindow.FChildren.Count - 1 do
  begin
    FChild := FWindow.FChildren[I];
    if (X > FChild.FWinLeft - 1) and (X < FChild.FWinLeft + FChild.FWinWidth) and
      (Y > FChild.FWinTop - 1) and (Y < FChild.FWinTop + FChild.FWinHeight) and
      (FChild.FVisible = True) then
    begin
      FSelected := I;
      FDragX := X - FChild.FWinLeft;
      FDragY := Y - FChild.FWinTop;
      FDragging := True;
    end;
  end;
  if Old <> FSelected then
    FSelectionShown := False;
  Draw(FWindow, FDesigner);
end;

procedure TDialog.UpDown2Click(Sender: TObject; Button: TUDBtnType);
begin
  if FSelected = -1 then
    FWindow.FWinTop := UpDown2.Position
  else
  begin
    FChild := FWindow.FChildren[FSelected];
    if UpDown2.Position + FChild.FWinHeight > FWindow.FWinHeight then
      UpDown2.Position := FWindow.FWinHeight - FChild.FWinHeight;
    FChild.FWinTop := UpDown2.Position;
  end;
end;

{ Display1MouseMove drags the selected control, snapped to the grid and kept inside the window
  at the bottom and the right }
procedure TDialog.Display1MouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if FDragging = True then
  begin
    FChild := FWindow.FChildren[FSelected];
    Y := Y div UpDown9.Position * UpDown9.Position;
    X := X div UpDown8.Position * UpDown8.Position;
    if Y - FDragY + FChild.FWinHeight > FWindow.FWinHeight then
      Y := FWindow.FWinHeight + FDragY - FChild.FWinHeight;
    UpDown2.Position := Y - FDragY;
    FChild.FWinTop := UpDown2.Position;
    if X - FDragX + FChild.FWinWidth > FWindow.FWinWidth then
      X := FWindow.FWinWidth + FDragX - FChild.FWinWidth;
    UpDown3.Position := X - FDragX;
    FChild.FWinLeft := UpDown3.Position;
  end;
end;

procedure TDialog.Display1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FDragging := False;
end;

procedure TDialog.UpDown3Click(Sender: TObject; Button: TUDBtnType);
begin
  if FSelected = -1 then
    FWindow.FWinLeft := UpDown3.Position
  else
  begin
    FChild := FWindow.FChildren[FSelected];
    if UpDown3.Position + FChild.FWinWidth > FWindow.FWinWidth then
      UpDown3.Position := FWindow.FWinWidth - FChild.FWinWidth;
    FChild.FWinLeft := UpDown3.Position;
  end;
end;

procedure TDialog.UpDown6Click(Sender: TObject; Button: TUDBtnType);
begin
  if FSelected = -1 then
  begin
    FWindow.FWinWidth := UpDown6.Position;
    FWindow.FSized := False;
    Draw(FWindow, FDesigner);
  end
  else
  begin
    FChild := FWindow.FChildren[FSelected];
    FChild.FWinWidth := UpDown6.Position;
    FChild.FSized := False;
    Draw(FWindow, FDesigner);
  end;
end;

procedure TDialog.UpDown7Click(Sender: TObject; Button: TUDBtnType);
begin
  if FSelected = -1 then
  begin
    FWindow.FWinHeight := UpDown7.Position;
    FWindow.FSized := False;
    Draw(FWindow, FDesigner);
  end
  else
  begin
    FChild := FWindow.FChildren[FSelected];
    FChild.FWinHeight := UpDown7.Position;
    FChild.FSized := False;
    Draw(FWindow, FDesigner);
  end;
end;

procedure TDialog.UpDown9Click(Sender: TObject; Button: TUDBtnType);
begin
  GridYEdit.Text := IntToStr(UpDown9.Position);
end;

procedure TDialog.UpDown8Click(Sender: TObject; Button: TUDBtnType);
begin
  GridXEdit.Text := IntToStr(UpDown8.Position);
end;

{ CompComboChange selects the control named in the combo box }
procedure TDialog.CompComboChange(Sender: TObject);
var
  I, Old: Integer;
begin
  Old := FSelected;
  if CompCombo.Text = FWindow.Name then
    FSelected := -1
  else
    for I := 0 to FWindow.FChildren.Count - 1 do
    begin
      FChild := FWindow.FChildren[I];
      if CompCombo.Text = FChild.Name then
        FSelected := I;
    end;
  if Old <> FSelected then
  begin
    FSelectionShown := False;
    Draw(FWindow, FDesigner);
    FComboSet := False;
  end;
end;

end.
