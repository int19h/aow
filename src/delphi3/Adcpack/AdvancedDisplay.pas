unit AdvancedDisplay;

{ The AdvancedDisplay unit of Adcpack.dpl: TAdvancedDisplay, a window that switches between a
  child control of a form and an exclusive full-screen DirectDraw window of 640x480 in 16 bits
  (Alt+Enter), written for the original compiler (Delphi 3.02) and compared function by function
  with the shipped module (tools/match.py). Declarations follow the original instance layout
  (notes/classes.json, notes/rtti/Adcpack.dpl.txt); the class has no published properties. It is
  TZoomControl (ZoomControl unit) reworked: SetDisplayMode(dmFullScreen) does what
  MaximizeZoom does, with the window sized to the screen, and SwapDisplayMode then takes the
  DirectDraw object of GFXE (GFXE.DD) into exclusive full-screen mode.

  The unit was compiled with optimization off and overflow checks on ($O-,Q+), like ZoomControl. }

{$O-,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  GFXE;

const
  { DirectDraw cooperative level flags (ddraw.h) }
  DDSCL_FULLSCREEN = $00000001;
  DDSCL_ALLOWREBOOT = $00000002;
  DDSCL_NOWINDOWCHANGES = $00000004;
  DDSCL_EXCLUSIVE = $00000010;
  DDSCL_ALLOWMODEX = $00000040;

type
  TDisplayMode = (dmWindowed, dmFullScreen);

  { AdvancedDisplay.TAdvancedDisplay (instance size 340): +$118 FDisplayMode, +$11C FOldParent,
    +$120 FOldExStyle, +$124 FOldStyle, +$128 FPlacement (44 bytes). VMT: Create (+$24), WndProc
    (+$40) and CreateParams (+$5C) overridden; MouseDown and KeyDown are dynamic overrides. }
  TAdvancedDisplay = class(TWinControl)
  private
    FDisplayMode: TDisplayMode;
    FOldParent: HWND;
    FOldExStyle: Longint;
    FOldStyle: Longint;
    FPlacement: TWindowPlacement;
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var Message: TMessage); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure HideApplicationForms;
    procedure ShowApplicationForms;
    procedure SetDisplayMode(Mode: TDisplayMode);
    procedure SwapDisplayMode;
  end;

procedure Register;

implementation

constructor TAdvancedDisplay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 100;
  Height := 100;
  Color := clBlack;
end;

procedure TAdvancedDisplay.CreateParams(var Params: TCreateParams);
begin
  inherited CreateParams(Params);
  Params.WindowClass.hIcon := Application.Icon.Handle;
end;

procedure TAdvancedDisplay.HideApplicationForms;
var
  I: Integer;
begin
  for I := Screen.FormCount - 1 downto 0 do
    if Screen.Forms[I].Visible then
      ShowWindow(Screen.Forms[I].Handle, SW_HIDE);
end;

procedure TAdvancedDisplay.ShowApplicationForms;
var
  I: Integer;
begin
  for I := 0 to Screen.FormCount - 1 do
    if Screen.Forms[I].Visible and not (csDestroying in Screen.Forms[I].ComponentState) then
      ShowWindow(Screen.Forms[I].Handle, SW_SHOW);
end;

procedure TAdvancedDisplay.SetDisplayMode(Mode: TDisplayMode);
var
  L: Longint;
begin
  if Mode <> FDisplayMode then
    if Mode = dmFullScreen then
    begin
      FDisplayMode := dmFullScreen;
      HideApplicationForms;
      FOldParent := Windows.SetParent(Handle, 0);
      FOldExStyle := SetWindowLong(Handle, GWL_EXSTYLE, WS_EX_TOPMOST);
      FOldStyle := SetWindowLong(Handle, GWL_STYLE, WS_POPUP or WS_SYSMENU);
      FPlacement.length := SizeOf(TWindowPlacement);
      GetWindowPlacement(Handle, @FPlacement);
      L := SetWindowLong(Application.Handle, GWL_HWNDPARENT, Handle);
      SetWindowPos(Application.Handle, HWND_BOTTOM, 0, 0, 0, 0, SWP_HIDEWINDOW);
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, Screen.Width, Screen.Height - 1, SWP_SHOWWINDOW);
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, Screen.Width, Screen.Height, SWP_SHOWWINDOW);
      SetWindowText(Handle, PChar(Application.Title));
    end
    else if Mode = dmWindowed then
    begin
      FDisplayMode := dmWindowed;
      L := SetWindowLong(Application.Handle, GWL_HWNDPARENT, 0);
      L := SetWindowLong(Handle, GWL_EXSTYLE, FOldExStyle);
      L := SetWindowLong(Handle, GWL_STYLE, FOldStyle or WS_CHILD);
      SetWindowPos(Handle, HWND_TOPMOST, 0, 0, 0, 0, SWP_SHOWWINDOW);
      SetWindowPlacement(Handle, @FPlacement);
      SetWindowPos(Application.Handle, HWND_TOP, 0, 0, 0, 0, SWP_SHOWWINDOW);
      Windows.SetParent(Handle, FOldParent);
      ShowApplicationForms;
    end;
end;

procedure TAdvancedDisplay.WndProc(var Message: TMessage);
begin
  if (Message.Msg <> WM_SYSCOMMAND) or (Message.WParam and $FFF0 <> SC_KEYMENU) or
    (Message.LParam <> 13) then
    inherited WndProc(Message)
  else
    Message.Result := 0;
  if Message.Msg = WM_ACTIVATE then
  begin
    { sic: the second test reads Msg instead of WParam, as in TZoomControl.WndProc }
    if ((Message.WParam and $FF = WA_ACTIVE) or (Message.Msg and $FF = WA_CLICKACTIVE)) and
      (FDisplayMode = dmFullScreen) and IsIconic(Handle) then
      OpenIcon(Handle);
    if (Message.WParam and $FF = WA_INACTIVE) and (FDisplayMode = dmFullScreen) then
      ShowWindow(Handle, SW_SHOWMINIMIZED);
  end;
end;

procedure TAdvancedDisplay.SwapDisplayMode;
var
  HR: HResult;
begin
  if FDisplayMode = dmFullScreen then
    SetDisplayMode(dmWindowed)
  else
  begin
    SetDisplayMode(dmFullScreen);
    HR := DD.SetCooperativeLevel(Handle, DDSCL_FULLSCREEN or DDSCL_ALLOWREBOOT or
      DDSCL_NOWINDOWCHANGES or DDSCL_EXCLUSIVE or DDSCL_ALLOWMODEX);
    HR := DD.SetDisplayMode(640, 480, 16, 0, 0);
  end;
end;

procedure TAdvancedDisplay.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  inherited MouseDown(Button, Shift, X, Y);
  Windows.SetFocus(Handle);
end;

procedure TAdvancedDisplay.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited KeyDown(Key, Shift);
  if (Key = VK_RETURN) and (Shift = [ssAlt]) then
    SwapDisplayMode;
end;

procedure Register;
begin
  RegisterComponents('Samples', [TAdvancedDisplay]);
end;

end.
