unit ZoomControl;

{ The ZoomControl unit of Adcpack.dpl: TZoomControl, a window that can be "zoomed" from a child
  control of a form to a top-most 320x240 popup window and back (Alt+Enter), written for the
  original compiler (Delphi 3.02) and compared function by function with the shipped module
  (tools/match.py). Declarations follow the original instance layout (notes/classes.json,
  notes/rtti/Adcpack.dpl.txt); the class has no published properties.

  How it works: MaximizeZoom hides every visible form of the application, takes the control's
  window out of its parent (SetParent 0), makes it a top-most popup (WS_POPUP or WS_SYSMENU,
  WS_EX_TOPMOST), remembers the old parent, styles and window placement, makes it the owner of
  the application window (GWL_HWNDPARENT), hides the application window and gives the window the
  application title. NormalizeZoom undoes all of it and shows the forms again. While zoomed,
  deactivating the window minimizes it (zsMinimized) and activating it again restores it; F1
  minimizes it too. The menu key (Alt+Enter arrives as WM_SYSCOMMAND SC_KEYMENU with key 13) is
  swallowed, and the arrow keys are kept by the control (CM_WANTSPECIALKEY).

  The unit was compiled with optimization off and overflow checks on ($O-,Q+): every local and
  parameter lives on the stack and `Screen.FormCount - 1` is checked (jno @IntOver). Nothing in
  the code is range checked, so $R cannot be told; it is left at the default. }

{$O-,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TZoomState = (zsNormal, zsMaximized, zsMinimized);

  { ZoomControl.TZoomControl (instance size 340): +$118 FZoomState, +$11C FOldParent (the parent
    window before MaximizeZoom), +$120 FOldExStyle, +$124 FOldStyle, +$128 FPlacement (44 bytes).
    VMT: Create (+$24), WndProc (+$40) and CreateParams (+$5C) overridden; MouseDown and KeyDown
    are dynamic overrides, CMWantSpecialKey a message handler. }
  TZoomControl = class(TWinControl)
  private
    FZoomState: TZoomState;
    FOldParent: HWND;
    FOldExStyle: Longint;
    FOldStyle: Longint;
    FPlacement: TWindowPlacement;
    procedure CMWantSpecialKey(var Message: TCMWantSpecialKey); message CM_WANTSPECIALKEY;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure WndProc(var Message: TMessage); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure HideApplicationForms;
    procedure ShowApplicationForms;
    procedure MaximizeZoom;
    procedure NormalizeZoom;
  end;

procedure Register;

implementation

constructor TZoomControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 100;
  Color := clBlack;
  FZoomState := zsNormal;
end;

procedure TZoomControl.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hIcon := Application.Icon.Handle;
end;

procedure TZoomControl.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Windows.SetFocus(Handle);
end;

procedure TZoomControl.HideApplicationForms;
var
  I: Integer;
begin
  for I := Screen.FormCount - 1 downto 0 do
    if Screen.Forms[I].Visible then
      ShowWindow(Screen.Forms[I].Handle, SW_HIDE);
end;

procedure TZoomControl.ShowApplicationForms;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible then
      ShowWindow(Screen.Forms[I].Handle, SW_SHOW);
end;

procedure TZoomControl.CMWantSpecialKey(var Message: TCMWantSpecialKey);
begin
  inherited;
  if (Message.CharCode = VK_LEFT) or (Message.CharCode = VK_RIGHT) or
    (Message.CharCode = VK_UP) or (Message.CharCode = VK_DOWN) then
    Message.Result := 1;
end;

procedure TZoomControl.MaximizeZoom;
var
  L: Longint;
begin
  FZoomState := zsMaximized;
  HideApplicationForms;
  FOldParent := Windows.SetParent(Handle, 0);
  FOldExStyle := SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOPMOST);
  FOldStyle := SetWindowLong(Handle, GWL_STYLE, WS_POPUP or WS_SYSMENU);
  FPlacement.length := SizeOf(TWindowPlacement);
  GetWindowPlacement(Handle, @FPlacement);
  L := SetWindowLong(Application.Handle, GWL_HWNDPARENT, Handle);
  SetWindowPos(Application.Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_HIDEWINDOW);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 320, 240, SWP_SHOWWINDOW);
  SetWindowText(Handle, PChar(Application.Title));
end;

procedure TZoomControl.NormalizeZoom;
var
  L: Longint;
  Unused: Longint; { never used: the third stack slot of the original }
begin
  FZoomState := zsNormal;
  L := SetWindowLong(Application.Handle, GWL_HWNDPARENT, 0);
  L := SetWindowLong(Handle, GWL_EXSTYLE, FOldExStyle);
  L := SetWindowLong(Handle, GWL_STYLE, FOldStyle or WS_CHILD);
  SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW);
  SetWindowPlacement(Handle, @FPlacement);
  SetWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW);
  Windows.SetParent(Handle, FOldParent);
  ShowApplicationForms;
end;

procedure TZoomControl.WndProc(var Message: TMessage);
begin
  if (Message.Msg <> WM_SYSCOMMAND) or (Message.WParam and $FFF0 <> SC_KEYMENU) or
    (Message.LParam <> 13) then
    inherited WndProc(Message)
  else
    Message.Result := 0;
  if Message.Msg = WM_ACTIVATE then
  begin
    { sic: the second test reads Msg instead of WParam, so WA_CLICKACTIVE never restores }
    if ((Message.WParam and $FF = WA_ACTIVE) or (Message.Msg and $FF = WA_CLICKACTIVE)) and
      (FZoomState = zsMinimized) and IsIconic(Handle) then
    begin
      OpenIcon(Handle);
      FZoomState := zsMaximized;
    end;
    if (Message.WParam and $FF = WA_INACTIVE) and (FZoomState = zsMaximized) then
    begin
      ShowWindow(Handle, SW_SHOWMINIMIZED);
      FZoomState := zsMinimized;
    end;
  end;
  if Message.Msg = WM_INITMENU then
    NormalizeZoom;
end;

procedure TZoomControl.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_RETURN) and (Shift = [ssAlt]) then
    if FZoomState = zsNormal then
      MaximizeZoom
    else
      NormalizeZoom;
  if Key = VK_F1 then
    ShowWindow(Handle, SW_SHOWMINIMIZED);
end;

procedure Register;
begin
  RegisterComponents('Samples', [TZoomControl]);
end;

end.
