unit E1GameFlow;

{ Unnamed executable game-flow routines used by E1. }

interface

uses AoWWinMan, AoWScenSetup, AoWSelFactionWin, AoWWorldMap, AOWMultiWin, AOWTitleWindow, AOWPyreScrn;

procedure FinishPyre(Dialog: TPyreScreen);
procedure ShowExitSplash(Dialog: TTitleWindow);
procedure HideGameWindows(Controller: TGeneral);
procedure RestoreGameWindows(Controller: TGeneral);
procedure ExitToTitle(Controller: TGeneral);
procedure SaveGame(Controller: TGeneral; Name: string);
procedure SaveCampaign(Controller: TGeneral; Name: string);
procedure PickScenarioMap(Dialog: TScenSetup; Name: string);
procedure LoadGame(Controller: TGeneral; Name: string);
procedure LoadCampaign(Controller: TGeneral; Name: string);
procedure StartGame(Controller: TGeneral);
procedure ShowMultiplayer(Dialog: TMultiWindow; const Name: string);
procedure ShowCampaignMap(Dialog: TWorldMap);
procedure ShowFactionSelection(Dialog: TSelFactionWin);

implementation

uses SysUtils, Classes, HSEngine, EventLog, AoWE, AoWWindow, E3Globals, AoWExeForms, AoWFileDialog,
  AoWTitleScene, Sound, E1Globals, E1Resources, AoWComp, AoWVideoDlg, E2CampaignSupport, AoWUnit, AoWReg, aowSetupEvents, aowDPlayComp;

procedure HideGameWindows(Controller: TGeneral);
var
  I: Integer;
begin
  with Controller do
    if not FWindowsHidden then
    begin
      FWindowsHidden := True;
      FInfoVisible := PInfoW.PInfoWin.Visible;
      FRealmVisible := RealmWin.Dlg.Visible;
      FMagicVisible := MagicWin.Dlg.Visible;
      FUnitVisible := UnitWindow.UnitWin.Visible;
      FTargetVisible := TargetSelectionDlg.Dlg.Visible;
      FScannerVisible := SWindow.ScannerWindow.Visible;
      FControlVisible := ControlWin.ControlWindow.Visible;
      FChatVisible := ChatWindow.ChatWin.Visible;
      FMapVisible := MWindow.MapWindow.Visible;
      for I := 0 to General.Manager.FChildren.Count - 1 do
        if General.Manager.FChildren[I] <> TBWindow.TaskWindow then
          TAOWWindow(General.Manager.FChildren[I]).Visible := False;
    end;
end;

procedure RestoreGameWindows(Controller: TGeneral);
begin
  with Controller do
    if FWindowsHidden then
    begin
      FWindowsHidden := False;
      PInfoW.PInfoWin.Visible := FInfoVisible;
      RealmWin.Dlg.Visible := FRealmVisible;
      MagicWin.Dlg.Visible := FMagicVisible;
      SWindow.ScannerWindow.Visible := FScannerVisible;
      ControlWin.ControlWindow.Visible := FControlVisible;
      MWindow.MapWindow.Visible := FMapVisible;
      UnitWindow.UnitWin.Visible := FUnitVisible;
      TargetSelectionDlg.Dlg.Visible := FTargetVisible;
      ChatWindow.ChatWin.Visible := FChatVisible;
    end;
end;

procedure ExitToTitle(Controller: TGeneral);
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
  TitleScene.ShowScene(True);
end;

procedure SaveGame(Controller: TGeneral; Name: string);
begin
  AoWHSMap.SaveGame(Name);
end;

procedure SaveCampaign(Controller: TGeneral; Name: string);
begin
  AoWHSMap.SaveGame(Name); { Original campaign-save command uses the map save routine. }
end;

procedure PickScenarioMap(Dialog: TScenSetup; Name: string);
begin
  Name := ExtractRelativePath(AoWEngine.StartupDirectory, GetCurrentDir + '\' + Name);
  FileDlgWindow.FileDialog.Visible := False;
  Dialog.FSetupControl.hPickMap(Name);
end;


procedure LoadGame(Controller: TGeneral; Name: string);
begin
  if AoWHSMap <> nil then AoWEngine.CloseHSM(nil);
  ProgressDialog.Title.Text := TranslateRStr(E1LoadingRStr) + ' ' + ExtractFileName(Name) + '...';
  ProgressDialog.StatusLbl.Text := '';
  ProgressDialog.Bar.Position := 0;
  ProgressDialog.Bar.Max := 100;
  ProgressDialog.ProgDlg.Visible := True;
  if not TitleScene.Window.Visible then General.Manager.OverlayPriority := 5000;
  SongPlayer.Stop(False);
  SongPlayer.Songs.Clear;
  FadeMusicVolume(0, 1);
  AoWEngine.LoadHSM(Name, False, Controller.MapProgress);
  if AoWEngine.FDemo and (AoWHSMap <> nil) and not AoWHSMap.FShowAllPlayers then ExitToTitle(Controller);
  General.Manager.OverlayPriority := 0;
  ProgressDialog.ProgDlg.Visible := False;
end;

procedure LoadCampaign(Controller: TGeneral; Name: string);
begin
  if AoWHSMap <> nil then AoWEngine.CloseHSM(nil);
  AoWEngine.LoadCampaign(Name);
  if AoWEngine.FCampaign <> nil then
    if AoWEngine.FCampaign.FScenarioStarted then
    begin
      ProgressDialog.Title.Text := TranslateRStr(E1LoadingRStr) + ' ' + ExtractFileName(Name) + '...';
      ProgressDialog.StatusLbl.Text := '';
      ProgressDialog.Bar.Position := 0;
      ProgressDialog.Bar.Max := 100;
      ProgressDialog.ProgDlg.Visible := True;
      if not TitleScene.Window.Visible then General.Manager.OverlayPriority := 5000;
      SongPlayer.Stop(False);
      SongPlayer.Songs.Clear;
      FadeMusicVolume(0, 1);
      AoWEngine.LoadCampaignMap(Controller.MapProgress);
      General.Manager.OverlayPriority := 0;
      ProgressDialog.ProgDlg.Visible := False;
    end
    else
    begin
      TitleScene.HideScene;
      ShowCampaignMap(WorldMap);
    end;
end;

procedure StartGame(Controller: TGeneral);
var
  I: Integer;
begin
  Controller.FWindowsHidden := False;
  SongPlayer.Songs.Clear;
  if AoWHSMap.FGameSongs.Songs.Count = 0 then
  begin
    if AoWHSMap.FStartupSongs.Songs.Count = 0 then SongPlayer.Songs.Add('Songs\Heartwoo.it')
    else
      for I := 0 to AoWHSMap.FStartupSongs.Songs.Count - 1 do
        if CompareText(AoWHSMap.FStartupSongs.SongNames[I], TranslateRStr(E1FileNotFoundRStr)) <> 0 then
          SongPlayer.Songs.Add(AoWHSMap.FStartupSongs.Songs[I]);
  end
  else SongPlayer.Songs.AddStrings(AoWHSMap.FGameSongs.Songs);
  SongPlayer.Play(0);
  SetMusicVolume(SoundDlg.MusicVolume.Position);
  PopupWindows.OverViewsMenu.Items.Clear;
  PopupWindows.OverViewsMenu.Items.Add(TranslateRStr(E1BackgroundRStr));
  if AoWEngine.FCampaign <> nil then PopupWindows.OverViewsMenu.Items.Add(TranslateRStr(E1CampaignRStr));
  TitleScene.Window.Visible := False;
  TitleWindow.TitleWin.Visible := False;
  TBWindow.TaskWindow.Visible := True;
  MWindow.MapWindow.Visible := True;
  SWindow.ScannerWindow.Visible := True;
  MWindow.MapViewer.HSMap := AoWHSMap;
  SWindow.Scanner.SetMap(AoWHSMap);
  SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.GetMapLevel(0));
  TBWindow.TurnButton.FButtonChecked := False;
  TBWindow.ChatBtn.Visible := SetupEvents.DPlay.Connected;
  General.Manager.FAligned := False;
  with SWindow.Scanner do
  begin
    FPreviousWidth := 0;
    FIncremental := False;
    FSized := False;
  end;
  SWindow.ScannerTab.Items.Clear;
  SWindow.ScannerTab.Items.Add(TranslateRStr(E1SurfaceRStr));
  if AoWHSMap.MapContainer.LevelCount > 1 then SWindow.ScannerTab.Items.Add(TranslateRStr(E1CavernsRStr));
  if AoWHSMap.MapContainer.LevelCount > 2 then SWindow.ScannerTab.Items.Add(TranslateRStr(E1DepthsRStr));
  SWindow.ScannerTab.Selected := 0;
  SWindow.ScannerTab.FSized := False;
  SWindow.Scanner.SetTWidth(0);
  SWindow.Scanner.SetTHeight(0);
  SWindow.Scanner.SetTLeft(-1);
  SWindow.Scanner.SetTTop(-1);
  SWindow.Scanner.FUpdateStep := -1;
  SWindow.Scanner.SetMap(AoWHSMap);
  SWindow.Scanner.SetLevel(AoWHSMap.MapContainer.GetMapLevel(0));
  MWindow.MapViewer.HSMap := AoWHSMap;
  MWindow.MapViewer.SceneWidth := MWindow.MapWindow.WinWidth - 24;
  MWindow.MapViewer.SceneHeight := MWindow.MapWindow.WinHeight - 24;
  AoWHSMap.Activate;
  UnitWindow.UnitWin.Visible := False;
  MapEvents.TheMapArmyDeselected;
  MapEvents.TheMapStructureDeselected;
  TBWindow.CurPUpdate;
  PInfoW.UpdatePlayer;
  if msActivated in AoWHSMap.Status then
    with TBWindow.TurnButton do
      if AoWHSMap.FSeatedPlayer = -1 then
      begin
        FCurPlayer := 12;
        FLastPlayer := 12;
        FAnimationFrame := FCurPlayer * 7;
        TBWindow.CurP.Visible := False;
      end
      else
      begin
        FLastPlayer := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerRace;
        if FLastPlayer = -1 then FLastPlayer := 12;
        FCurPlayer := FLastPlayer;
        FAnimationFrame := FLastPlayer * 7;
        TBWindow.CurP.Visible := AoWHSMap.FPlayMode = pmTurn;
      end;
  TBWindow.FWorldClockDelay := 0;
  TBWindow.ChatBtn.ILIndexUp := 14;
  TBWindow.FChatFlash := 0;
  SetVideoSize(VideoDialog, VideoDialog.FDisplayWidth, VideoDialog.FDisplayHeight);
end;

procedure ShowMultiplayer(Dialog: TMultiWindow; const Name: string);
var
  I: Integer;
  Kind: TConnectionType;
begin
  if not ((SongPlayer.CurrentIndex <> -1) and (SongPlayer.CurrentIndex < SongPlayer.Songs.Count) and
    (SongPlayer.Songs[SongPlayer.CurrentIndex] = 'SONGS\TITLE.IT')) then
  begin
    SongPlayer.Songs.Clear;
    SongPlayer.Songs.Add('SONGS\TITLE.IT');
    SongPlayer.Play(0);
  end;
  SetVideoSize(VideoDialog, 640, 480);
  Dialog.FPendingMap := Name;
  if SetupEvents.DPlay.Connected then SetupEvents.DPlay.DisConnect;
  TitleWindow.TitleWin.Visible := True;
  TitleWindow.TitlePnl.Visible := False;
  Dialog.BackBtn.Visible := True;
  Dialog.GamePanel.Visible := True;
  Dialog.TCPPnl.Visible := False;
  Dialog.LanPnl.Visible := False;
  Dialog.MultiPnl.Visible := False;
  Dialog.TCPBtn.Visible := False;
  Dialog.IPXBtn.Visible := False;
  Dialog.PBEMPnl.Visible := False;
  if SetupEvents.DPlay.GetConnections = 0 then
    for I := 0 to SetupEvents.DPlay.Connections.Count - 1 do
    begin
      Kind := TGDConnection(SetupEvents.DPlay.Connections[I]).FType;
      case Kind of
        conTCP: Dialog.TCPBtn.Visible := True;
        conIPX: Dialog.IPXBtn.Visible := True;
      end;
    end;
end;

procedure ShowCampaignMap(Dialog: TWorldMap);
var
  Song: string;
begin
  Dialog.BookClosed;
  AoWEngine.CloseHSM(nil);
  TitleWindow.TitleWin.Visible := True;
  TitleWindow.TitlePnl.Visible := False;
  Dialog.WorldPnl.Visible := True;
  Dialog.FPathFrame := 0;
  Dialog.FPathDelay := 5;
  Dialog.DescLbl.Text := '';
  General.Manager.OverlayPriority := 249;
  SongPlayer.Stop(False);
  SetCurrentDir(AoWEngine.StartupDirectory);
  if GetCampaignScenario(Dialog.GetCampaign, Dialog.GetCampaign.FCurrentScenarioID).FImageLibrary = '' then
    Song := 'Songs\Title.IT'
  else Song := 'Songs\' + GetCampaignScenario(Dialog.GetCampaign, Dialog.GetCampaign.FCurrentScenarioID).FImageLibrary;
  PlaySongEx(Song, 1, 0, True);
  Dialog.PPawn.CurrentImage := Dialog.GetCampaign.FFaction + 7;
  Dialog.EPawn.CurrentImage := 8 - Dialog.GetCampaign.FFaction;
  Dialog.UpdateCampaignState;
end;

procedure ShowFactionSelection(Dialog: TSelFactionWin);
begin
  TitleWindow.TitleWin.Visible := True;
  Dialog.FactionPnl.Visible := True;
  Dialog.TopLbl.Visible := True;
  Dialog.TopLbl.Text := TranslateRStr(E1FactionRStr);
  Dialog.LName.Visible := False;
  Dialog.LText.Visible := False;
  Dialog.LBack.Visible := False;
  Dialog.LStart.Visible := False;
  Dialog.LSphere.Visible := False;
  Dialog.DName.Visible := False;
  Dialog.DText.Visible := False;
  Dialog.DBack.Visible := False;
  Dialog.DStart.Visible := False;
  Dialog.DSphere.Visible := False;
  Dialog.FFade := -1;
  Dialog.FactionPnl.ILIndexTexture := 0;
  Dialog.F_SelFactionWin_8C[0] := 0;
end;


procedure ShowSplash(Dialog: TTitleWindow);
begin
  SetVideoSize(VideoDialog, 640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  VideoDialog.ApplyBtnClick;
  Dialog.TitleWin.Visible := True;
  Dialog.TitlePnl.Visible := False;
  Dialog.SplashPnl.ILTexture := Dialog.DemoIL;
  Dialog.SplashPnl.ILIndexTexture := 0;
  Dialog.SplashPnl.Visible := True;
  Dialog.F_TitleWindow_54 := 450;
  Dialog.FSplashStage := 0;
end;

procedure ShowExitSplash(Dialog: TTitleWindow);
begin
  ShowSplash(Dialog);
  Dialog.SplashPnl.ILIndexTexture := 2;
  Dialog.FSplashStage := 10;
  Dialog.F_TitleWindow_54 := 300;
end;


procedure ClearPyre(Dialog: TPyreScreen);
begin
  if Dialog.FAnimation <> nil then
  begin
    Dialog.FAnimation.Free;
    Dialog.FAnimation := nil;
  end;
end;

procedure FinishPyre(Dialog: TPyreScreen);
var
  Done: TExecuteDoneEvent;
  Event: TGameOverEventLog;
begin
  SetSFXVolume(SoundDlg.SFXVolume.Position);
  ClearPyre(Dialog);
  if Dialog.FSavedSongStatus <> nil then
  begin
    RestoreSongStatus(Dialog.FSavedSongStatus);
    Dialog.FSavedSongStatus.Free;
    Dialog.FSavedSongStatus := nil;
  end;
  Dialog.FGameOverEvent.Handled;
  General.Manager.OverlayPriority := 0;
  Done := Dialog.FDone;
  Event := Dialog.FGameOverEvent;
  Dialog.FDone := nil;
  Dialog.FGameOverEvent := nil;
  if Assigned(Done) then Done(Event);
  if Event <> nil then Event.Release;
end;

end.
