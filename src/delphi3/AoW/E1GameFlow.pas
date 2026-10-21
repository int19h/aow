unit E1GameFlow;

{ Unnamed executable game-flow routines used by E1. }

interface

uses Classes, AoWWinMan, AoWScenSetup, AoWSelFactionWin, AoWWorldMap, AOWMultiWin, AOWTitleWindow, AOWPyreScrn, AoWMagic;

procedure ShowMagic(Window: TMagicWin);
procedure HideMagic(Window: TMagicWin);
procedure FinishPyre(Dialog: TPyreScreen);
procedure ShowExitSplash(Dialog: TTitleWindow);
procedure HideGameWindows(Controller: TGeneral);
procedure RestoreGameWindows(Controller: TGeneral);
procedure ExitToTitle(Controller: TGeneral);
procedure SaveGame(Controller: TGeneral; Name: string);
procedure SaveCampaign(Controller: TGeneral; Name: string);
procedure PickScenarioMap(Dialog: TScenSetup; Name: string);

procedure ShowMultiplayer(Dialog: TMultiWindow; const Name: string);
procedure ShowCampaignMap(Dialog: TWorldMap);

implementation

uses SysUtils, HSEngine, EventLog, AoWE, AoWWindow, E3Globals, AoWExeForms, AoWFileDialog,
  AoWTitleScene, Sound, E1Globals, E1Resources, AoWComp, AoWVideoDlg, E2CampaignSupport, AoWUnit, AoWReg, aowSetupEvents, aowDPlayComp;

procedure ShowMagic(Window: TMagicWin);
begin
  if not Window.Dlg.Visible then
  begin
    RefreshMagicWindow(Window);
    RefreshGlobalMagic(Window);
  end;
  Window.Dlg.Visible := True;
end;

procedure HideMagic(Window: TMagicWin);
begin
  if Window.Dlg.Visible then Window.Dlg.Visible := False;
end;

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
  Dialog.FSplashTimer := 450;
  Dialog.FSplashStage := 0;
end;

procedure ShowExitSplash(Dialog: TTitleWindow);
begin
  ShowSplash(Dialog);
  Dialog.SplashPnl.ILIndexTexture := 2;
  Dialog.FSplashStage := 10;
  Dialog.FSplashTimer := 300;
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
