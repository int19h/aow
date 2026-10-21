unit E2GameFlow;

{ Unnamed executable flow routines called by E2. Original addresses are in E2.json. }
interface
uses AoWTutorialWin, AoWCampaignJoin, AoWScenSetup, AOWMultiWin, AoWSpellBook, aowSetupEvents, AoWVideoDlg, E2Globals, AOWDialogWin, AoWCampaignSettings, AoWWindow, AoWLabel, AOWGauge, Classes, AoWTitleScene, AOWTitleWindow, AoWCampaignTransferDlg,
  AoWTargetSelection, AoWWinMan, AoWLeaderSetup, AoWFileDialog, AoWIntroScene;
procedure HideGameWindows(Controller: TGeneral);
procedure ConfirmDialog(Dialog: TDWin; Title, Message: string; Kind: Byte);
procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
procedure OpenSelectedGame(Dialog: TFileDlgWindow);
function StartLobby(Events: TSetupEvents): Boolean;
procedure SaveWindowLayout(Controller: TGeneral);
procedure ShowTutorialMessage(Dialog: TTutorialWindow);
procedure ApplyVideoSettings(Dialog: TVideoDialog);
procedure SetSceneSize(Dialog: TVideoDialog; Width, Height: Integer);
procedure ShowResearch(Book: TSpellBook);
procedure HideScenarioSetup(Setup: TScenSetup);
procedure UpdateScenarioSetup(Setup: TScenSetup);
procedure ShowMultiplayer(Window: TMultiWindow; const FileName: string);
procedure StartCampaignJoin(Dialog: TCampaignJoinDlg; Faction: Integer);
procedure LoadGame(Controller: TGeneral; FileName: string);
procedure StartGame(Controller: TGeneral);
procedure CloseGame(Controller: TGeneral);
function HasModalWindow(Controller: TGeneral): Boolean;

implementation
uses Windows, SysUtils, AoWE, AoWExeForms, AoWUnit, E1Globals,
  AoWComp, AoWSWindow, AOWMWindow,
  AoWTBWindow, AoWPInfoWin, aowHelpWin, Sound, HSEngine;

procedure StartCampaignJoin(Dialog: TCampaignJoinDlg; Faction: Integer);
begin
  { Unrecovered original 004184A0. }
end;

procedure HideScenarioSetup(Setup: TScenSetup);
begin
  Setup.ScenSetupPnl.Visible := False;
  Setup.FSetupControl := nil;
end;

procedure UpdateScenarioSetup(Setup: TScenSetup);
begin
  { Unrecovered original 00411460. }
end;

procedure ShowMultiplayer(Window: TMultiWindow; const FileName: string);
begin
  { Unrecovered original 0042ABF0. }
end;

procedure ShowResearch(Book: TSpellBook);
begin
  { Unrecovered original 00430948. }
end;

procedure OpenSelectedGame(Dialog: TFileDlgWindow);
begin
  { Unrecovered original 0041FC08 and its file-loading helper 0041FA60. }
end;

function StartLobby(Events: TSetupEvents): Boolean;
begin
  { Unrecovered original 00413DE8. }
  Result := False;
end;

procedure SaveWindowLayout(Controller: TGeneral);
begin
  { Unrecovered original 0045660C. }
end;

procedure ShowTutorialMessage(Dialog: TTutorialWindow);
begin
  { Unrecovered original 0044E4A4. }
end;

procedure SetSceneSize(Dialog: TVideoDialog; Width, Height: Integer);
begin
  Dialog.FSceneWidth := Width;
  Dialog.FSceneHeight := Height;
  if Dialog.FFullScreen = scmTitle then Dialog.FModeChanged := True;
end;

procedure ApplyVideoSettings(Dialog: TVideoDialog);
begin
  if Dialog.FModeChanged then
  begin
    with Dialog do
      if MainForm.Display.ActiveDC <> nil then
        case FFullScreen of
          scmGame: if MainForm.Display.ActiveDC <> MainForm.WinDC then ChangeResolution(FDisplayWidth, FDisplayHeight)
             else ChangeResolution(0, 0);
          scmTitle: if MainForm.Display.ActiveDC <> MainForm.WinDC then
               if AoWEngine.FRegistry.GetAllowResolutionSwitches and (MainForm.Display.ActiveDC <> MainForm.WinDC) then
                 ChangeResolution(FSceneWidth, FSceneHeight)
               else ChangeResolution(FDisplayWidth, FDisplayHeight)
             else ChangeResolution(0, 0);
          scmWindowed: ChangeResolution(0, 0);
        end
      else
        case FFullScreen of
          scmTitle: if AoWEngine.FRegistry.GetAllowResolutionSwitches then
             begin
               MainForm.DXDC.DisplayWidth := FSceneWidth;
               MainForm.DXDC.DisplayHeight := FSceneHeight;
               MainForm.Display.BackSurfaceWidth := MainForm.DXDC.DisplayWidth;
               MainForm.Display.BackSurfaceHeight := MainForm.DXDC.DisplayHeight;
             end;
          scmGame: begin
               MainForm.DXDC.DisplayWidth := FDisplayWidth;
               MainForm.DXDC.DisplayHeight := FDisplayHeight;
               MainForm.Display.BackSurfaceWidth := MainForm.DXDC.DisplayWidth;
               MainForm.Display.BackSurfaceHeight := MainForm.DXDC.DisplayHeight;
             end;
        end;
    Dialog.FModeChanged := False;
  end;
end;

procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
begin
  if Music then
    if not ((SongPlayer.CurrentIndex <> -1) and (SongPlayer.CurrentIndex < SongPlayer.Songs.Count) and
      (SongPlayer.Songs[SongPlayer.CurrentIndex] = 'SONGS\TITLE.IT')) then
    begin
      SongPlayer.Songs.Clear;
      SongPlayer.Songs.Add('SONGS\TITLE.IT');
      SongPlayer.Play(0);
    end;
  General.Manager.OverlayPriority := 0;
  Scene.TitleSceneIL.LoadDiscardableImageData;
  SetSceneSize(VideoDialog, 640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  ApplyVideoSettings(VideoDialog);
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVideoMemory := True;
  Scene.FRedrawBackground := True;
  Scene.FPressedButton := -1;
  Scene.FHoverButton := -1;
  Scene.FFont := FontModule.AoW15WhiteGrey;
  Scene.FCreditsFont := FontModule.AoW15WhiteGrey;
  Scene.Window.WinManager.ILIndexTBack := 4;
  Scene.Window.Visible := True;
end;

procedure LoadGame(Controller: TGeneral; FileName: string);
begin
  if AoWHSMap <> nil then AoWEngine.CloseHSM(nil);
  ProgressDialog.Title.Text := TranslateRStr(LoadingRStr) + ': ' + ExtractFileName(FileName) + '...';
  ProgressDialog.StatusLbl.Text := '';
  ProgressDialog.Bar.Position := 0;
  ProgressDialog.Bar.Max := 100;
  ProgressDialog.ProgDlg.Visible := True;
  if not TitleScene.Window.Visible then Controller.Manager.OverlayPriority := 5000;
  SongPlayer.Stop(False);
  SongPlayer.Songs.Clear;
  FadeMusicVolume(0, 1);
  AoWEngine.LoadHSM(FileName, False, Controller.MapProgress);
  if AoWEngine.FDemo and (AoWHSMap <> nil) and not AoWHSMap.FShowAllPlayers then CloseGame(Controller);
  Controller.Manager.OverlayPriority := 0;
  ProgressDialog.ProgDlg.Visible := False;
end;

procedure StartGame(Controller: TGeneral);
var
  I: Integer;
begin
  Controller.FWindowsHidden := False;
  SongPlayer.Songs.Clear;
  if AoWHSMap.FGameSongs.Songs.Count <> 0 then
    SongPlayer.Songs.AddStrings(AoWHSMap.FGameSongs.Songs)
  else
    if AoWHSMap.FStartupSongs.Songs.Count = 0 then
      SongPlayer.Songs.Add('Songs\Heartwoo.it')
    else
      for I := 0 to AoWHSMap.FStartupSongs.Songs.Count - 1 do
        if CompareText(AoWHSMap.FStartupSongs.SongNames[I], TranslateRStr(FileNotFoundRStr)) <> 0 then
          SongPlayer.Songs.Add(AoWHSMap.FStartupSongs.Songs[I]);
  SongPlayer.Play(0);
  SetMusicVolume(SoundDlg.MusicVolume.Position);
  TBWindow.StartMenuBar.Items.Clear;
  TBWindow.StartMenuBar.Items.Add(TranslateRStr(BackgroundRStr));
  if AoWEngine.FCampaign <> nil then TBWindow.StartMenuBar.Items.Add(TranslateRStr(CampaignRStr));
  TitleScene.Window.Visible := False;
  TitleWindow.TitleWin.Visible := False;
  TBWindow.TaskWindow.Visible := True;
  MWindow.MapWindow.Visible := True;
  SWindow.ScannerWindow.Visible := True;
  MWindow.MapViewer.SetHSMap(AoWHSMap);
  SWindow.Scanner.SetMap(AoWHSMap);
  SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.MapLevels[0]);
  TBWindow.TurnButton.FButtonChecked := False;
  TBWindow.ChatBtn.Visible := SetupEvents.DPlay.Connected;
  Controller.Manager.FAligned := False;
  SWindow.Scanner.FPreviousWidth := 0;
  SWindow.Scanner.FIncremental := False;
  SWindow.Scanner.FSized := False;
  SWindow.ScannerTab.Items.Clear;
  SWindow.ScannerTab.Items.Add(TranslateRStr(SurfaceRStr));
  if AoWHSMap.MapContainer.LevelCount > 1 then SWindow.ScannerTab.Items.Add(TranslateRStr(CavernsRStr));
  if AoWHSMap.MapContainer.LevelCount > 2 then SWindow.ScannerTab.Items.Add(TranslateRStr(DepthsRStr));
  SWindow.ScannerTab.Selected := 0;
  SWindow.ScannerTab.FSized := False;
  SWindow.Scanner.SetTWidth(0);
  SWindow.Scanner.SetTHeight(0);
  SWindow.Scanner.SetTLeft(-1);
  SWindow.Scanner.SetTTop(-1);
  SWindow.Scanner.FUpdateStep := -1;
  SWindow.Scanner.SetMap(AoWHSMap);
  SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.MapLevels[0]);
  MWindow.MapViewer.SetHSMap(AoWHSMap);
  MWindow.MapViewer.SceneWidth := MWindow.MapWindow.WinWidth - 24;
  MWindow.MapViewer.SceneHeight := MWindow.MapWindow.WinHeight - 24;
  AoWHSMap.Activate;
  ControlWin.ControlWindow.Visible := False;
  MapEvents.TheMapArmyDeselected;
  MapEvents.TheMapStructureDeselected;
  TBWindow.TBWorldUpdate;
  PInfoW.UpdatePlayer;
  if msActivated in AoWHSMap.Status then
    with TBWindow.TurnButton do
      if AoWHSMap.FSeatedPlayer = -1 then
      begin
        FCurPlayer := 12; FLastPlayer := 12; FAnimationFrame := FCurPlayer * 7;
        TBWindow.AutoBtn.Visible := False;
      end
      else
      begin
        FLastPlayer := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerRace;
        if FLastPlayer = -1 then FLastPlayer := 12;
        FCurPlayer := FLastPlayer;
        FAnimationFrame := FLastPlayer * 7;
        TBWindow.AutoBtn.Visible := AoWHSMap.FPlayMode = pmSimultaneous;
      end;
  TBWindow.FWorldClockDelay := 0;
  TBWindow.ChatBtn.TextColor := 14;
  TBWindow.FChatFlash := 0;
  VideoDialog.ChangeResolution(VideoDialog.FDisplayWidth, VideoDialog.FDisplayHeight);
end;

procedure HideGameWindows(Controller: TGeneral);
var
  I: Integer;
begin
  if not Controller.FWindowsHidden then
  begin
    Controller.FWindowsHidden := True;
    Controller.FInfoVisible := PInfoW.PInfoWin.Visible;
    Controller.FRealmVisible := RealmWin.Dlg.Visible;
    Controller.FMagicVisible := MagicWin.Dlg.Visible;
    Controller.FUnitVisible := ControlWin.ControlWindow.Visible;
    Controller.FTargetVisible := ChatWindow.ChatWin.Visible;
    Controller.FScannerVisible := SWindow.ScannerWindow.Visible;
    Controller.FControlVisible := UnitWindow.UnitWin.Visible;
    Controller.FChatVisible := IWindow.InfoWin.Visible;
    Controller.FMapVisible := MWindow.MapWindow.Visible;
    for I := 0 to General.Manager.FChildren.Count - 1 do
      if General.Manager.FChildren[I] <> TBWindow.TaskWindow then
        TAOWWindow(General.Manager.FChildren[I]).Visible := False;
  end;
end;

procedure CloseGame(Controller: TGeneral);
begin
  AoWEngine.CloseHSM(nil);
  AoWEngine.CloseCampaign;
  SWindow.Scanner.SetMap(nil);
  TCScanner.Scanner.SetMap(nil);
  SongPlayer.Stop(False);
  SongPlayer.Songs.Clear;
  SetCurrentDir(AoWEngine.StartupDirectory);
  HideGameWindows(General);
  TBWindow.TaskWindow.Visible := False;
  TitleWindow.TitleWin.Visible := False;
  TitleScene.ResetScene;
  ShowTitleScene(TitleScene, True);
end;

procedure ConfirmDialog(Dialog: TDWin; Title, Message: string; Kind: Byte);
begin
  Dialog.F_DWin_A4 := Kind;
  Dialog.DTitle.Text := Title;
  Dialog.DMessage.Text := Message;
  Dialog.yesPnl.Visible := True;
  Dialog.okPnl.Visible := False;
  Dialog.Dialog.Visible := True;
end;

function HasModalWindow(Controller: TGeneral): Boolean;
var
  I: Integer;
  Window: TAOWWindow;
begin
  Result := False;
  I := Controller.Manager.FChildren.Count - 1;
  while I >= 0 do
  begin
    Window := TAOWWindow(Controller.Manager.FChildren[I]);
    if (Window <> MWindow.MapWindow) and Window.Modal and Window.Visible then
    begin Result := True; I := -1; end
    else Dec(I);
  end;
end;

end.
