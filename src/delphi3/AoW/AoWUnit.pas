unit AoWUnit;

{ AoWUnit handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

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
    FCursor: Smallint; FCursorPad: Word; { $1E8; 00452938 }
    FDebugWindow: TDebugMessageDlg; { $1EC }
    F_MainForm_1F0: array[0..7] of Byte; FCursorImage: TLibraryImage; { $1F8; 0040A0E4 }
    FLastCursorRect: TRect; { $1FC; 0045309A }
    { $200 is FLastCursorRect.Top. }
    { $204 is FLastCursorRect.Right. }
    { $208 is FLastCursorRect.Bottom. }
    FCursorChanged: Boolean; { $20C }
    F_MainForm_20D: array[0..2] of Byte;
    procedure PlayInterfaceSound(Kind: Byte);
    procedure GetCursorRect(X, Y: Integer; var R: TRect);
    procedure DrawCursor(X, Y: Integer; const Surface: TSurfaceDesc);
    procedure ScrollMap(X, Y: Integer);
    procedure ExitGameDone(Mode: TExitGameMode; Exited: Boolean);
    procedure DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
    procedure FormCreate(Sender: TObject);
    procedure DisplayMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure DisplayMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure DisplayKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure DisplayResizeBackSurface(Sender: TObject; Width, Height: Integer);
    procedure DisplayDblClick;
    procedure DisplaySurfaceDataLost;
    procedure FormDestroy;
    procedure DisplayActivateDC(Sender: TObject; DC: TAbstractDC);
    procedure FormShow;
    procedure DisplayKeyPress(Sender: TObject; var Key: Char);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure DisplaySwapDC(DC: TAbstractDC);
  end;


var
  MainForm: TMainForm;
  DeferredSetupAction: Byte; { $45B2B5 }
  DisplayActivated: Boolean; { $45B2B4 }

implementation

uses AoWExeForms, AoWWinMan, AoWComp, E2WindowLayout, E2Globals, E2GameFlow,
  aowSetupEvents, AoWIntroScene, AOWTitleWindow, aowHelpWin, AoWVideoDlg, AOWMWindow, ActiveX;

procedure TMainForm.PlayInterfaceSound(Kind: Byte);
begin
  case Kind of
    0: PlaySample('Sfx\Int\Btn1.wav');
    1: PlaySample('Sfx\Int\Btn5.wav');
    2: PlaySample('Sfx\Int\Btn6.wav');
    3: PlaySample('Sfx\Int\Btn3.wav');
  end;
end;

procedure TMainForm.ExitGameDone(Mode: TExitGameMode; Exited: Boolean);
begin
  if Exited then Application.Terminate;
end;

procedure TMainForm.GetCursorRect(X, Y: Integer; var R: TRect);
var
  Bounds: TRect;
  Cursor: Integer;
begin
  R.Left := 0; R.Right := 0; R.Top := 0; R.Bottom := 0;
  if X <> -1 then
    if AoWHSMap = nil then
    begin
      if FCursor <> 1 then
        if IntGfxMod.Cursors.ImageExist(FCursor) then
        begin
          IntGfxMod.Cursors[FCursor].GetVisualDimensions(Bounds);
          Bounds.Left := Bounds.Left + X - 25; Bounds.Right := X + Bounds.Right - 25;
          Bounds.Top := Bounds.Top + Y - 25; Bounds.Bottom := Bounds.Bottom + Y - 25;
          UnionRect(R, R, Bounds);
        end;
    end
    else
    begin
      if FCursorImage <> nil then
      begin
        FCursorImage.GetVisualDimensions(Bounds);
        Bounds.Left := Bounds.Left + X - 15; Bounds.Right := Bounds.Right + X - 15;
        Bounds.Top := Bounds.Top + Y - 20; Bounds.Bottom := Bounds.Bottom + Y - 20;
        UnionRect(R, R, Bounds);
      end;
      Cursor := FCursor;
      if (Cursor = 9999) and (AoWHSMap <> nil) then Cursor := AoWHSMap.Mouse.Cursor;
      if Cursor <> 1 then
        if AoWHSSet.FCursorImages[Cursor] <> nil then
        begin
          AoWHSSet.FCursorImages[Cursor].GetVisualDimensions(Bounds);
          Bounds.Left := Bounds.Left + X - 25; Bounds.Right := X + Bounds.Right - 25;
          Bounds.Top := Bounds.Top + Y - 25; Bounds.Bottom := Bounds.Bottom + Y - 25;
          UnionRect(R, R, Bounds);
        end;
    end;
end;

procedure TMainForm.DrawCursor(X, Y: Integer; const Surface: TSurfaceDesc);
var
  Cursor: Integer;
begin
  if X <> -1 then
    if (AoWHSMap = nil) or not (msActivated in AoWHSMap.Status) then
    begin
      if (FCursor <> 1) and IntGfxMod.Cursors.ImageExist(FCursor) then
        IntGfxMod.Cursors[FCursor].ShowClipped(X - 25, Y - 25, Surface);
    end
    else
    begin
      if FCursorImage <> nil then FCursorImage.Show(X - 15, Y - 20, Surface);
      Cursor := FCursor;
      if (Cursor = 9999) and (AoWHSMap <> nil) then Cursor := AoWHSMap.Mouse.Cursor;
      if (Cursor <> 1) and (AoWHSSet.FCursorImages[Cursor] <> nil) then
      begin
        if (AoWHSMap.FSeatedPlayer <> -1) and (AoWHSMap.FCombatMap = nil) then
          if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetBusy and
            (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerType = ptHuman) then
          begin
            AoWHSSet.FCursorImages[Cursor].ShowBlended(X - 25, Y - 25, Surface,
              AlphaBlendTable.LookupTables[Abs((AoWHSMap.Frame shl 2) mod 100 - 50) + 30]);
            FCursorChanged := True;
            Exit;
          end;
        AoWHSSet.FCursorImages[Cursor].Show(X - 25, Y - 25, Surface);
      end;
    end;
end;

procedure TMainForm.ScrollMap(X, Y: Integer);
begin
  if not HasModalWindow(General) and (X <> -1) and Application.Active then
  begin
    if X < 2 then
    begin
      MWindow.MapViewer.SceneX := MWindow.MapViewer.SceneX - 16;
      SWindow.Scanner.SetTLeft(MWindow.MapViewer.SceneX div 32 - 6);
    end;
    if X >= Display.ActiveDC.GetSurface(0).Width - 1 then
    begin
      MWindow.MapViewer.SceneX := MWindow.MapViewer.SceneX + 16;
      SWindow.Scanner.SetTLeft(MWindow.MapViewer.SceneX div 32 - 6);
    end;
    if Y < 2 then
    begin
      MWindow.MapViewer.SceneY := MWindow.MapViewer.SceneY - 16;
      SWindow.Scanner.SetTTop(MWindow.MapViewer.SceneY div 32 - 6);
    end;
    if Y >= Display.ActiveDC.GetSurface(0).Height - 1 then
    begin
      MWindow.MapViewer.SceneY := MWindow.MapViewer.SceneY + 16;
      SWindow.Scanner.SetTTop(MWindow.MapViewer.SceneY div 32 - 6);
    end;
  end;
end;

procedure TMainForm.DisplayUpdateFrame(Sender: TObject; DC: TAbstractDC; SurfaceType: Integer);
var
  X, Y: Integer;
  R: TRect;
  Surface: TSurfaceDesc;
begin
  if AoWEngine.FRegistry.GetDebugMode then Sleep(1) else Sleep(0);
  case DeferredSetupAction of
    1: begin
         DeferredSetupAction := 0;
         ScenSetup.FSetupControl.hPlayerSetupDone;
       end;
    2: begin
         DeferredSetupAction := 0;
         OpenSelectedGame(FileDlgWindow);
       end;
  end;
  if SetupEvents.DPlay.Session <> nil then SetupEvents.DPlay.CheckMessages;
  ProcessSound;
  try
    if AoWHSMap <> nil then AoWHSMap.NewFrame;
  except
  end;
  if (DC <> nil) and (DC.GetSurface(1) <> nil) then
  begin
    Display.GetMousePos(X, Y);
    GetCursorRect(X, Y, R);
    FCursorChanged := FCursorChanged or ((AoWHSMap <> nil) and AoWHSMap.Mouse.CursorVisible) or
      (FLastCursorRect.Left <> R.Left) or (FLastCursorRect.Top <> R.Top) or
      (FLastCursorRect.Right <> R.Right) or (FLastCursorRect.Bottom <> R.Bottom);
    if AoWHSMap <> nil then ScrollMap(X, Y);
    try
      General.Manager.DrawSurface(DC.GetSurface(1));
    except
    end;
    if X <> -1 then
      if Succeeded(DC.GetSurface(1).Lock(Surface)) then
      begin
        DrawCursor(X, Y, Surface);
        DC.GetSurface(1).Unlock;
      end;
    FLastCursorRect := R;
    DialogWin.FrameLbl.Text := IntToStr(Display.CurrentFrameRate);
  end;
  if (AoWHSMap <> nil) and AoWHSMap.FExitPending then CloseGame(General);
  ApplyVideoSettings(VideoDialog);
end;

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
  SetVideoMode(VideoDialog, TScreenMode(AoWEngine.FRegistry.GetDisplayMode));
  if VideoDialog.FFullScreen <> scmWindowed then
  begin
    WindowState := wsNormal;
    SetVideoMode(VideoDialog, scmGame);
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


procedure TMainForm.DisplayKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  General.Manager.CheckKeyDown(Key, Shift);
  if (Key = VK_F1) and (AoWHSMap <> nil) and (AoWHSMap.FGameType = gtTutorial) then
    ShowTutorialMessage(TutorialWindow);
end;

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
begin
  if AoWHSMap <> nil then
    if not HasModalWindow(General) then AoWHSMap.Mouse.DblClick;
end;

procedure TMainForm.DisplaySurfaceDataLost;
begin
  General.Manager.FAligned := False;
end;


procedure TMainForm.FormDestroy;
begin
  ReleaseSoundSystem;
  SaveWindowLayout(General);
  AoWEngine.FRegistry.SetMainWindowState(WindowState);
  AoWEngine.FRegistry.SetString(0, MultiWindow.TCPName.Text);
  AoWEngine.FRegistry.SetString(1, MultiWindow.IPEdit.Text);
  AoWEngine.FRegistry.SetDisplayWidth(VideoDialog.FDisplayWidth);
  AoWEngine.FRegistry.SetDisplayHeight(VideoDialog.FDisplayHeight);
  if Display.ActiveDC = DXDC then AoWEngine.FRegistry.SetDisplayMode(1)
  else AoWEngine.FRegistry.SetDisplayMode(0);
  AoWEngine.FRegistry.SetUseDirectSound(SoundDlg.FSettings.UseDirectSound);
  AoWEngine.FRegistry.SetSFXEnabled(SoundDlg.FSettings.SFXEnabled);
  AoWEngine.FRegistry.SetMusicEnabled(SoundDlg.FSettings.MusicEnabled);
  AoWEngine.FRegistry.SetSoundQuality(SoundDlg.FSoundQuality);
  AoWEngine.FRegistry.SetSFXVolume(SoundDlg.SFXVolume.Position);
  AoWEngine.FRegistry.SetMusicVolume(SoundDlg.MusicVolume.Position);
end;

procedure TMainForm.DisplayActivateDC(Sender: TObject; DC: TAbstractDC);
begin
  if DC = WinDC then SetVideoMode(VideoDialog, scmWindowed);
  DisplayActivated := True;
end;

procedure TMainForm.FormShow;
begin
  SongPlayer.OnSongChange := SoundDlg.SongChange;
  AoWEngine.OutputDebugStr('ParamStr: ' + ParamStr(1));
  if (CompareText(ParamStr(1), 'dplobby') = 0) or (CompareText(ParamStr(1), 'dblobby') = 0) then
    if StartLobby(SetupEvents) then Exit;
  if (ParamStr(1) <> '') and FileExists(ParamStr(1)) then
    if (CompareText(ExtractFileExt(ParamStr(1)), '.asg') = 0) or
      (CompareText(ExtractFileExt(ParamStr(1)), '.acg') = 0) then
    begin
      ShowTitleScene(TitleScene, False);
      DeferredSetupAction := 2;
      FileDlgWindow.FLastFileName := ParamStr(1);
      Exit;
    end;
  if not AoWEngine.FDemo then
    if not AoWEngine.FDebug and not AoWEngine.FRegistry.GetSkipIntro then IntroScene.Execute
    else ShowTitleScene(TitleScene, True)
  else TitleWindow.ShowSplash;
end;

procedure TMainForm.DisplayKeyPress(Sender: TObject; var Key: Char);
begin
  General.Manager.CheckKeyPress(Key);
end;


procedure TMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  if AoWHSMap = nil then CanClose := True
  else
    if AoWHSMap.FCombatMap = nil then
    begin
      AoWHSMap.ExitGame(egmTerminate, ExitGameDone);
      CanClose := AoWHSMap.FExitPending;
    end
    else
    begin
      ConfirmDialog(DialogWin, TranslateRStr(ConfirmRStr), TranslateRStr(QuitCombatRStr), 6);
      CanClose := False;
    end;
end;

procedure TMainForm.DisplaySwapDC(DC: TAbstractDC);
begin
  if DC = DXDC then
    if AoWEngine.FRegistry.GetAllowResolutionSwitches then
    begin
      DXDC.DisplayHeight := VideoDialog.FSceneHeight;
      DXDC.DisplayWidth := VideoDialog.FSceneWidth;
    end
    else
    begin
      DXDC.DisplayHeight := VideoDialog.FDisplayHeight;
      DXDC.DisplayWidth := VideoDialog.FDisplayWidth;
    end;
end;

end.
