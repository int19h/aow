unit AoWUnit;

{ Draft declarations of AoWUnit, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, DebMDlg, AoWReg, AoWTCReg;

type
  TMainForm = class;


  { TMainForm: size $210; $1DC display, $1E0/$1E4 controllers, $1EC debug window, $1F8 cursor image. VMT 004526C0. }
  TMainForm = class(TForm)
  public
    published
    Display: TDisplay; { +01DC }
    WinDC: TWindows16DC; { +01E0 }
    DXDC: TDDrawFullScr16DC; { +01E4 }
    public
    F_MainForm_1E8: array[0..3] of Byte;
    FDebugWindow: TDebugMessageDlg; { $1EC }
    F_MainForm_1F0: array[0..7] of Byte; FCursorImage: TLibraryImage; { $1F8; 0040A0E4 }
    F_MainForm_1FC: Integer;
    F_MainForm_200: Integer;
    F_MainForm_204: Integer;
    F_MainForm_208: Integer;
    F_MainForm_20C: Byte;
    F_MainForm_20D: array[0..2] of Byte;
    procedure PlayInterfaceSound(Kind: Byte);
    procedure DisplayUpdateFrame(A1: Integer; A2: Integer);  { draft }
    procedure FormCreate(Sender: TObject);
    procedure DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DisplayResizeBackSurface(Sender: TObject; Width, Height: Integer);
    procedure DisplayDblClick;  { draft }
    procedure DisplaySurfaceDataLost;
    procedure FormDestroy;  { draft }
    procedure DisplayActivateDC(A1: Integer; A2: Integer);  { draft }
    procedure FormShow;  { draft }
    procedure DisplayKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(A1: Integer; A2: Integer);  { draft }
    procedure DisplaySwapDC(A1: Integer);  { draft }
  end;


var
  MainForm: TMainForm;

implementation

uses AoWExeForms, AoWWinMan, AoWComp, E2WindowLayout;

procedure TMainForm.PlayInterfaceSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
  end;
end;

procedure TMainForm.DisplayUpdateFrame(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.FormCreate(Sender: TObject);
var
  S: string;
  R: TRect;
begin
  RegisterTacticalCombat(AoWEngine);
  ClientWidth := 640;
  ClientHeight := 480;
  AoWEngine.FRegistry.RegisterDPlayLobbyServer;
  AoWEngine.InitializeHSSet(AoWEngine.StartupDirectory + 'RELEASE\RELEASE.HSS', nil);
  if AoWEngine.FRegistry.GetDebugMode then
  begin
    FDebugWindow := TDebugMessageDlg.Create(Self);
    FDebugWindow.Engine := AoWEngine;
    FDebugWindow.Left := 0;
    FDebugWindow.Top := 40;
    FDebugWindow.WindowState := wsNormal;
    FDebugWindow.Show;
    with Display do
    begin
      Options := Options + [doShowFrameRate];
      FrameRate := 0;
    end;
  end;
  DXDC.UseVideoMemory := AoWEngine.FRegistry.GetDetailLevel = dtlLow;
  WindowState := AoWEngine.FRegistry.GetMainWindowState;
  if WindowState = wsNormal then
  begin
    R := AoWEngine.FRegistry.GetMainWindowPosition;
    if R.Right <> R.Left then
    begin
      Position := poDesigned;
      SetBounds(R.Left, R.Top, R.Right - R.Left, R.Bottom - R.Top);
    end
    else
    begin
      ClientWidth := 640;
      ClientHeight := 480;
    end;
  end;
  SoundDlg.MusicVolume.Position := AoWEngine.FRegistry.GetMusicVolume;
  SoundDlg.SFXVolume.Position := AoWEngine.FRegistry.GetSFXVolume;
  with SoundDlg.FSettings do
  begin
    MusicEnabled := AoWEngine.FRegistry.GetMusicEnabled;
    SFXEnabled := AoWEngine.FRegistry.GetSFXEnabled;
    UseDirectSound := AoWEngine.FRegistry.GetUseDirectSound;
    Window := Display.FSWinControl.Handle;
    SoundDlg.FSoundQuality := AoWEngine.FRegistry.GetSoundQuality;
    SoundDlg.SFXVolume.Position := AoWEngine.FRegistry.GetSFXVolume;
    SoundDlg.MusicVolume.Position := AoWEngine.FRegistry.GetMusicVolume;
    SampleVoices := 16;
    case AoWEngine.FRegistry.GetSoundQuality of
      1: begin OutputMode := [omMono, om8bit]; SampleRate := 22050; end;
      2: begin OutputMode := [omMono, om16bit]; SampleRate := 44100; end;
      3: begin OutputMode := [omStereo, om16bit]; SampleRate := 44100; end;
      4: begin OutputMode := [omStereo, om16bit, omHighQuality]; SampleRate := 44100; end;
    end;
  end;
  if DD <> nil then DD.SetCooperativeLevel(Display.FSWinControl.Handle, $57);
  if AoWEngine.FRegistry.GetSoundQuality <> 0 then
  begin
    InitializeSoundSystem('Galaxy', SoundDlg.FSettings);
    SetMusicVolume(AoWEngine.FRegistry.GetMusicVolume);
    SetSFXVolume(AoWEngine.FRegistry.GetSFXVolume);
  end;
  SetVideoSize(VideoDialog, AoWEngine.FRegistry.GetDisplayWidth, AoWEngine.FRegistry.GetDisplayHeight);
  SetVideoMode(VideoDialog, Boolean(AoWEngine.FRegistry.GetDisplayMode));
  if VideoDialog.FFullScreen then
  begin
    WindowState := wsNormal;
    SetVideoMode(VideoDialog, True);
    DXDC.DisplayWidth := AoWEngine.FRegistry.GetDisplayWidth;
    DXDC.DisplayHeight := AoWEngine.FRegistry.GetDisplayHeight;
    Display.PrimaryDC := DXDC;
    Display.SecondaryDC := WinDC;
    Display.BackSurfaceWidth := DXDC.DisplayWidth;
    Display.BackSurfaceHeight := DXDC.DisplayHeight;
  end;
  General.Manager.WinWidth := Display.BackSurfaceWidth;
  General.Manager.WinHeight := Display.BackSurfaceHeight;
  General.Manager.FAligned := False;
  S := AoWEngine.FRegistry.GetString(0);
  if S <> '' then
  begin
    MultiWindow.TCPName.Text := S;
    MultiWindow.IPXName.Text := S;
  end;
  S := AoWEngine.FRegistry.GetString(1);
  if S <> '' then MultiWindow.IPEdit.Text := S;
  RestoreWindowLayout(General);
  SetCurrentDir(AoWEngine.StartupDirectory);
  AoWEngine.FCombatFont := FontModule.Age8;
end;


procedure TMainForm.DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  General.Manager.CheckMouseDown(Button, Shift, X, Y);
end;


procedure TMainForm.DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  General.Manager.CheckMouseMove(Shift, X, Y);
end;


procedure TMainForm.DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  General.Manager.CheckMouseUp(Button, Shift, X, Y);
  if AoWHSMap <> nil then TAbstractAoWHSMapMouse(AoWHSMap.Mouse).ResetRectangleSelection;
end;


procedure TMainForm.DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMainForm.DisplayResizeBackSurface(Sender: TObject; Width, Height: Integer);
begin
  with General.Manager do
  begin
    WinWidth := Display.BackSurfaceWidth;
    WinHeight := Display.BackSurfaceHeight;
    if WinWidth < 640 then WinWidth := 640;
    if WinHeight < 480 then WinHeight := 480;
  end;
  General.ResetLayout;
end;


procedure TMainForm.DisplayDblClick;
begin end;

procedure TMainForm.DisplaySurfaceDataLost;
begin
  General.Manager.FAligned := False;
end;


procedure TMainForm.FormDestroy;
begin end;

procedure TMainForm.DisplayActivateDC(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.FormShow;
begin end;

procedure TMainForm.DisplayKeyPress(Sender: TObject; var Key: Char);
begin
  General.Manager.CheckKeyPress(Key);
end;


procedure TMainForm.FormCloseQuery(A1: Integer; A2: Integer);
begin end;

procedure TMainForm.DisplaySwapDC(A1: Integer);
begin end;


end.
