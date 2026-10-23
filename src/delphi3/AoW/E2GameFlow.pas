unit E2GameFlow;

{ Unnamed executable flow routines called by E2. Original addresses are in E2.json. }
interface
uses AoWTutorialWin, AoWCampaignJoin, AoWScenSetup, AOWMultiWin, AoWSpellBook, aowSetupEvents, AoWVideoDlg, E2Globals, AOWDialogWin, AoWCampaignSettings, AoWWindow, AoWLabel, AOWGauge, Classes, AoWTitleScene, AOWTitleWindow, AoWCampaignTransferDlg,
  AoWTargetSelection, AoWWinMan, AoWLeaderSetup, AoWFileDialog, AoWIntroScene;
procedure HideGameWindows(Controller: TGeneral);
procedure ConfirmDialog(Dialog: TDWin; Title, Message: string; Kind: Byte);
procedure ShowTitleScene(Scene: TTitleScene; Music: Boolean);
function StartLobby(Events: TSetupEvents): Boolean;
procedure OpenSelectedGame(Dialog: TFileDlgWindow);
procedure SaveWindowLayout(Controller: TGeneral);
procedure ShowTutorialMessage(Dialog: TTutorialWindow);
procedure ApplyVideoSettings(Dialog: TVideoDialog);
procedure SetSceneSize(Dialog: TVideoDialog; Width, Height: Integer);
procedure HideScenarioSetup(Setup: TScenSetup);
procedure UpdateScenarioSetup(Setup: TScenSetup);
procedure StartCampaignJoin(Dialog: TCampaignJoinDlg; Faction: Integer);
procedure LoadGame(Controller: TGeneral; FileName: string);
procedure StartGame(Controller: TGeneral);
procedure CloseGame(Controller: TGeneral);
function HasModalWindow(Controller: TGeneral): Boolean;

implementation
uses Windows, SysUtils, AoWE, AoWExeForms, AoWUnit, E1Globals,
  AoWComp, AoWSWindow, AOWMWindow,
  AoWTBWindow, AoWPInfoWin, aowHelpWin, Sound, HSEngine, AoWSetup, aowDPlayComp, AoWComboBox, AoWPanel, AoWImage, AoWWorldMap, E2CampaignSupport, ImageLib;

procedure InitializeCampaignJoin(Dialog: TCampaignJoinDlg);
begin
  Dialog.CharGenPnl.Visible := True;
  Dialog.LeaderTypePnl.Visible := False;
  TitleWindow.TitleWin.Visible := True;
  Dialog.ScrollTextDB.Visible := True;
  Dialog.FScrollDelay := 0;
  Dialog.FScrollPosition := 0;
  Dialog.FScrollText.Clear;
end;

procedure LoadWorldCampaign(Dialog: TWorldMap; Name: string);
begin
  AoWEngine.LoadCampaign(AoWEngine.StartupDirectory + 'Scenario\Campaign\' + Name);
end;

procedure StartCampaignJoin(Dialog: TCampaignJoinDlg; Faction: Integer);
var
  Lines: TStringList;
  Campaign: TWMCampaign;
  Index, I: Integer;
  Preview: TAoWHSMap;
begin
  Dialog.ResetCampaignJoin;
  Dialog.FFaction := Faction;
  Dialog.FStage := 0;
  Lines := TStringList.Create;
  case Dialog.FFaction of
    0: begin
         LoadWorldCampaign(E1Globals.WorldMap, 'Keepers.cam');
         Dialog.CharGenPnl.ILIndexTexture := 10;
         AoWHSSet.FTextControl.RetrieveText(10, Lines);
       end;
    1: begin
         LoadWorldCampaign(E1Globals.WorldMap, 'Storm.cam');
         Dialog.CharGenPnl.ILIndexTexture := 11;
         AoWHSSet.FTextControl.RetrieveText(11, Lines);
       end;
  end;
  ParseFontText(Lines.Text, Dialog.FScrollText, FontModule.AoW15WhiteGrey, 300);
  Campaign := E1Globals.WorldMap.GetCampaign;
  Index := Campaign.FScenarios.IndexOfID(GetCampaignScenario(Campaign, 0).FPaths[0]);
  Preview := TAoWHSMap(AoWEngine.CreatePreviewHSM(AoWEngine.StartupDirectory +
    'Scenario\Campaign\' + GetCampaignScenario(E1Globals.WorldMap.GetCampaign, Index).FFileName));
  I := 0;
  { Original uses the preview map child count as the player-search bound. }
  while (I < Preview.Count) and (Ord(Preview.FPlayers.GetPlayers(I).FPlayerType) <> 0) do Inc(I);
  Dialog.FLeader.Assign(Preview.FPlayers.GetPlayers(I).FLeaderSetup, AoWEngine);
  Preview.Free;
  Lines.Free;
end;

procedure HideScenarioSetup(Setup: TScenSetup);
begin
  Setup.ScenSetupPnl.Visible := False;
  Setup.FSetupControl := nil;
end;

procedure UpdateScenarioRow(Setup: TScenSetup; Settings: TPlayerSetupSettings;
  PlayerBox, BehaviorBox: TAOWComboBox; Icon: TAOWImage;
  PlayerName, Info: TAOWLabel; Fog: TAOWPanel);
var
  Behavior: TSetupPlayerBehavior;
  B: Byte;
  I: Integer;
  Visible, Found: Boolean;
begin
  if Settings <> nil then
  begin
    Visible := Setup.FSetupControl.GetHost and not (pssFixed in Settings.FStatus);
    if Visible <> PlayerBox.Visible then PlayerBox.Visible := Visible;
    if PlayerBox.Visible then
    begin
      PlayerBox.Items.BeginUpdate;
      PlayerBox.Items.Clear;
      Setup.FSetupControl.ListAvailablePlayers(PlayerBox.Items);
      PlayerBox.Items.EndUpdate;
      Found := False;
      I := PlayerBox.Items.Count;
      while not Found and (I <> 0) do
      begin
        Dec(I);
        if Setup.FSetupControl.PlayerNameToPlayerID(PlayerBox.Items[I], Behavior) then
          Found := (Settings.FBehavior.PlayerType = Behavior.PlayerType) and
            (Settings.FBehavior.Flags = Behavior.Flags);
      end;
      if Found then PlayerBox.Selected := I else PlayerBox.Selected := -1;
      PlayerName.Visible := False;
    end
    else
    begin
      PlayerName.Visible := True;
      if (Settings.FBehavior.PlayerType = 0) and (Settings.FBehavior.Flags <> 0) then
      begin
        I := Setup.FSetupControl.FSettings.FRemotePlayers.IndexOfRemoteID(Settings.FBehavior.Flags);
        if I <> -1 then PlayerName.Text := Setup.FSetupControl.FSettings.FRemotePlayers.GetPlayers(I).FName
        else PlayerName.Text := TranslateRStr(HumanRStr);
      end
      else PlayerName.Text := TranslateRStr(TPlayerTypeRStr[Settings.FBehavior.PlayerType]);
    end;
    Info.Text := '';
    Info.Visible := Setup.FSetupControl.GetRemote or (pssFixed in Settings.FStatus);
    if Info.Visible then
      if pssFixed in Settings.FStatus then Info.Text := TranslateRStr(FixedRStr)
      else if Setup.FSetupControl.GetRemote and (pssForced in Settings.FStatus) and
        (Settings.FBehavior.PlayerType = 0) then
      begin
        I := Setup.FSetupControl.FSettings.FRemotePlayers.IndexOfRemoteID(Settings.FBehavior.Flags);
        if I <> -1 then
          if Setup.FSetupControl.FSettings.FRemotePlayers.GetPlayers(I).FPreferredRace = Byte(Settings.FRace) then { Original compares race bytes, including the FF sentinel. }
            Info.Text := TranslateRStr(TakenRStr)
          else Info.Text := TranslateRStr(ForcedRStr);
      end
      else if Settings.FBehavior.Flags <> 0 then Info.Text := TranslateRStr(TakenRStr)
      else if Settings.FBehavior.PlayerType in [1..3, 6..7] then
        Info.Text := TranslateRStr(TPlayerBehaviorRStr[TPlayerBehavior(Settings.FBehaviorMode)]);
    BehaviorBox.Visible := Setup.FSetupControl.GetHost and
      (Settings.FBehavior.PlayerType in [1..3, 6..7]);
    if BehaviorBox.Visible then
    begin
      BehaviorBox.Items.BeginUpdate;
      BehaviorBox.Items.Clear;
      for B := 0 to 5 do
        BehaviorBox.Items.AddObject(TranslateRStr(TPlayerBehaviorRStr[TPlayerBehavior(B)]), TObject(B));
      BehaviorBox.Items.EndUpdate;
      BehaviorBox.Selected := Settings.FBehaviorMode;
    end;
    Icon.Visible := Settings.FBehavior.PlayerType in [0..3, 6..7];
    if Icon.Visible then
      case Settings.FBehavior.PlayerType of
        1: Icon.CurrentImage := 1;
        2: Icon.CurrentImage := 2;
        3: Icon.CurrentImage := 3;
        6: Icon.CurrentImage := 4;
        7: Icon.CurrentImage := 5;
      else Icon.CurrentImage := 0;
      end;
    Fog.Visible := pssFixed in Settings.FStatus;
  end
  else
  begin
    Icon.Visible := False;
    PlayerBox.Visible := False;
    BehaviorBox.Visible := False;
    PlayerName.Visible := False;
    Info.Visible := True;
    Info.Text := TranslateRStr(UnavailableRStr);
    Fog.Visible := True;
  end;
end;

procedure UpdateScenarioSetup(Setup: TScenSetup);
var
  I, HostIndex: Integer;
  HostName, Connection: string;
  Player: TRemotePlayer;
  Control: TSetupControl;
begin
  with Setup do
    if FSetupControl <> nil then
    begin
      Control := FSetupControl;
      PlayerList.Items.Clear;
      PingList.Items.Clear;
      PreferredRaceList.Items.Clear;
      for I := 0 to Control.FSettings.FRemotePlayers.Count - 1 do
      begin
        Player := Control.FSettings.FRemotePlayers.GetPlayers(I);
        PlayerList.Items.AddObject(Player.FName, TObject(Player.FRemoteID));
        if Player.FPreferredRace <> $FF then
          PreferredRaceList.Items.Add(TranslateRStr(RaceNamesPluralRStr[Shortint(Player.FPreferredRace)]))
        else PreferredRaceList.Items.Add(TranslateRStr(NoneRStr));
        PingList.Items.AddObject('', TObject(Player.FRemoteID));
      end;
      PlayerListSB.Max := PlayerList.Items.Count - 1;
      SelectPlayer(PlayerList.Selected);
      CustomizeLeaders.Checked := FSetupControl.FSettings.FCustomizeLeaders;
      PlayModeCB.Selected := PlayModeCB.Items.IndexOfObject(TObject(FSetupControl.FSettings.FPlayMode));
      Exploration.Checked := FSetupControl.FSettings.FExplorationEnabled;
      TurnTimeSl.Position := FSetupControl.FSettings.FTurnTime;
      if FSetupControl.FSettings.FDayLimit <> 0 then
        TurnsSl.Position := FSetupControl.FSettings.FDayLimit div 10
      else TurnsSl.Position := 0;
      UpdateTurnLimit;
      UpdateTurnTime;
      StartBtn.Visible := FSetupControl.GetHost and FSetupControl.GetPlayerSetupValid;
      PickScenarioBtn.Visible := FSetupControl.GetHost;
      SettingsFogPnl.Visible := not FSetupControl.GetHost;
      RestartSettingsFogPnl.Visible := not SettingsFogPnl.Visible and (FSetupControl.FSettings.FMapDay <> 0);
      LeadersOnMapCB.Checked := FSetupControl.FSettings.FLeadersOnMap;
      AlliedVictoryCB.Checked := FSetupControl.FSettings.FAlliedVictory;
      TacticalCombatCB.Selected := TacticalCombatCB.Items.IndexOfObject(TObject(FSetupControl.FSettings.FTacticalCombatAvailability));
      AlwaysViewTCCB.Visible := TacticalCombatCB.Visible and (FSetupControl.FSettings.FTacticalCombatAvailability <> 0);
      AlwaysViewTCCB.Checked := FSetupControl.FSettings.FAlwaysViewTC;
      AlwaysViewTCLbl.Visible := AlwaysViewTCCB.Visible;
      PreferredRaceLbl.Visible := FSetupControl.GetRemote;
      PreferredRaceCB.Visible := FSetupControl.GetRemote;
      if PreferredRaceCB.Visible then
      begin
        PreferredRaceCB.Items.Clear;
        PreferredRaceCB.Items.AddObject(TranslateRStr(NoneRStr), TObject(-1));
        for I := 0 to FSetupControl.FSettings.Count - 1 do
          if not (pssFixed in FSetupControl.FSettings.GetSettings(I).FStatus) then
            PreferredRaceCB.Items.AddObject(
              TranslateRStr(RaceNamesPluralRStr[Shortint(FSetupControl.FSettings.GetSettings(I).FRace)]),
              TObject(Shortint(FSetupControl.FSettings.GetSettings(I).FRace)));
        with PreferredRaceCB do
        begin
          NumberVisible := 5; FSized := False;
          Selected := Items.IndexOfObject(TObject(Shortint(FSetupControl.FRemotePlayer.FPreferredRace)));
        end;
      end;
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(0)),
        R1PlayerCB, R1BehaviorCB, R1PlayerIcon, R1PlayerLbl, R1InfoLbl, R1FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(1)),
        R2PlayerCB, R2BehaviorCB, R2PlayerIcon, R2PlayerLbl, R2InfoLbl, R2FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(2)),
        R3PlayerCB, R3BehaviorCB, R3PlayerIcon, R3PlayerLbl, R3InfoLbl, R3FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(3)),
        R4PlayerCB, R4BehaviorCB, R4PlayerIcon, R4PlayerLbl, R4InfoLbl, R4FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(4)),
        R5PlayerCB, R5BehaviorCB, R5PlayerIcon, R5PlayerLbl, R5InfoLbl, R5FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(5)),
        R6PlayerCB, R6BehaviorCB, R6PlayerIcon, R6PlayerLbl, R6InfoLbl, R6FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(6)),
        R7PlayerCB, R7BehaviorCB, R7PlayerIcon, R7PlayerLbl, R7InfoLbl, R7FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(7)),
        R8PlayerCB, R8BehaviorCB, R8PlayerIcon, R8PlayerLbl, R8InfoLbl, R8FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(8)),
        R9PlayerCB, R9BehaviorCB, R9PlayerIcon, R9PlayerLbl, R9InfoLbl, R9FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(9)),
        R10PlayerCB, R10BehaviorCB, R10PlayerIcon, R10PlayerLbl, R10InfoLbl, R10FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(10)),
        R11PlayerCB, R11BehaviorCB, R11PlayerIcon, R11PlayerLbl, R11InfoLbl, R11FogPnl);
      UpdateScenarioRow(Setup, Control.FSettings.GetSettings(Control.FSettings.IndexOfRace(11)),
        R12PlayerCB, R12BehaviorCB, R12PlayerIcon, R12PlayerLbl, R12InfoLbl, R12FogPnl);
      if FSetupControl.GetRemote then
      begin
        case SetupEvents.DPlay.ConnectionType of
          conTCP: Connection := TranslateRStr(TCPIPRStr);
          conIPX: Connection := TranslateRStr(IPXRStr);
          conModem: Connection := TranslateRStr(ModemRStr);
          conSerial: Connection := TranslateRStr(SerialRStr);
        else Connection := '';
        end;
        with FSetupControl.FSettings do HostIndex := FRemotePlayers.IndexOfRemoteID(FHostRemoteID);
        if HostIndex <> -1 then HostName := FSetupControl.FSettings.FRemotePlayers.GetPlayers(HostIndex).FName
        else HostName := '?';
        HostNameLbl.Visible := True;
        FileNameLbl.Visible := True;
        PlayerNameLbl.Visible := True;
        HostNameLbl.Text := AoWE.Format(TranslateRStr(XHostYRStr), [Connection, HostName]);
        PlayerNameLbl.Text := AoWE.Format(TranslateRStr(PlayerNameXRStr), [FSetupControl.FRemotePlayer.FName]);
        FileNameLbl.Text := AoWE.Format(TranslateRStr(FileNameXRStr), [FSetupControl.FSettings.FMapName]);
        if FSetupControl.FRemotePlayer.FMapValidation = mviInvalid then FileNameLbl.TextColor := $FF
        else FileNameLbl.TextColor := $9D9D9D;
      end
      else
      begin
        HostNameLbl.Visible := False;
        FileNameLbl.Visible := False;
        PlayerNameLbl.Visible := False;
      end;
      ScenarioLbl.Text := AoWE.Format(TranslateRStr(ScenarioXRStr), [FSetupControl.FSettings.FFileName]);
      TitleWindow.TitleWin.FDrawn := False;
    end;
end;


procedure InitializeScenarioSetup(Setup: TScenSetup; Control: TSetupControl);
var
  B: Byte;
begin
  with Setup do
  begin
    FSetupControl := Control;
    TitleWindow.TitleWin.Visible := True;
    ScenSetupPnl.Visible := True;
    ChatMemo.Items.Clear;
    ChatEdit.Text := '';
    FValidateDelay := 100;
    FPingDelay := 15;
    ChatFogPnl.Visible := not FSetupControl.GetRemote;
    ChatMemo.CaptureInput := FSetupControl.GetRemote;
    ChatEdit.CaptureInput := FSetupControl.GetRemote;
    if FSetupControl.GetHost and (FSetupControl.FSettings.FMapName = '') then PickMap;
    if FSetupControl.GetRemote then
    begin
      TacticalCombatCB.Visible := True;
      TacticalCombatLbl.Visible := True;
      TacticalCombatCB.Items.Clear;
      for B := 0 to 2 do
        TacticalCombatCB.Items.AddObject(TranslateRStr(TTacticalCombatAvailabilityRStr[B]), TObject(B));
    end
    else
    begin
      TacticalCombatCB.Visible := False;
      TacticalCombatLbl.Visible := False;
    end;
    if FSetupControl.FSettings.FConnectionType = 2 then
    begin
      CustomizeLeadersLbl.TextColor := $808080;
      CustomizeLeaders.CaptureInput := False;
      PlayModeCB.Items.Clear;
      PlayModeCB.Items.AddObject(TranslateRStr(ClassicRStr), TObject(1));
    end
    else
    begin
      CustomizeLeadersLbl.TextColor := AlliedVictoryLbl.TextColor;
      CustomizeLeaders.CaptureInput := True;
      PlayModeCB.Items.Clear;
      PlayModeCB.Items.AddObject(TranslateRStr(SimultaneousRStr), TObject(2));
      PlayModeCB.Items.AddObject(TranslateRStr(ClassicRStr), TObject(1));
    end;
    if not ((SongPlayer.CurrentIndex <> -1) and (SongPlayer.CurrentIndex < SongPlayer.Songs.Count) and
      (SongPlayer.Songs[SongPlayer.CurrentIndex] = 'SONGS\TITLE.IT')) then
    begin
      SongPlayer.Songs.Clear;
      SongPlayer.Songs.Add('SONGS\TITLE.IT');
      SongPlayer.Play(0);
    end;
    UpdateScenarioSetup(Setup);
  end;
end;

function StartLobby(Events: TSetupEvents): Boolean;
begin
  if Events.DPlay.CheckLobby then
  begin
    if Events.DPlay.IsHost then
    begin
      AoWEngine.OutputDebugStr('Setting up host (DPID:' + IntToStr(Events.DPlay.PlayerID) + ')');
      Events.SetupControl.SetupHost(Events.DPlay.PlayerName, 1, Events.DPlay.PlayerID);
    end
    else
    begin
      AoWEngine.OutputDebugStr('Joining session (DPID:' + IntToStr(Events.DPlay.PlayerID) + ')');
      Events.SetupControl.SetupUser(Events.DPlay.PlayerName, Events.DPlay.PlayerID);
    end;
    ScenSetup.Execute(Events.SetupControl);
    Events.FLobbyGame := True;
    Result := True;
  end
  else
  begin
    AoWEngine.OutputDebugStr('Not lobbied');
    Events.FLobbyGame := False;
    Result := False;
  end;
end;

procedure OpenSelectedGame(Dialog: TFileDlgWindow);
begin
  Dialog.LoadSelectedGame(Dialog.FLastFileName);
end;

procedure SaveWindowLayout(Controller: TGeneral);
begin
  with PInfoW.PInfoWin do
    AoWEngine.FRegistry.SetRectangle(0, Rect(PInfoW.PInfoWin.Alignment.RightOffset, PInfoW.PInfoWin.Alignment.BottomOffset, WinWidth, WinHeight));
  with ControlWin.ControlWindow do
    AoWEngine.FRegistry.SetRectangle(1, Rect(ControlWin.ControlWindow.Alignment.RightOffset, ControlWin.ControlWindow.Alignment.TopOffset, WinWidth, WinHeight));
  with UnitWindow.UnitWin do
    if Alignment.AlignWidth <> awCenter then
      AoWEngine.FRegistry.SetRectangle(2, Rect(UnitWindow.UnitWin.Alignment.LeftOffset, UnitWindow.UnitWin.Alignment.TopOffset, WinWidth, WinHeight))
    else AoWEngine.FRegistry.SetRectangle(2, Rect(0, 0, 0, 0));
  with RealmWin.Dlg do
    if Alignment.AlignWidth <> awBoth then
      AoWEngine.FRegistry.SetRectangle(5, Rect(RealmWin.Dlg.Alignment.LeftOffset, RealmWin.Dlg.Alignment.TopOffset, WinWidth, WinHeight))
    else AoWEngine.FRegistry.SetRectangle(5, Rect(0, 0, 0, 0));
  with MagicWin.Dlg do
    if Alignment.AlignWidth <> awBoth then
      AoWEngine.FRegistry.SetRectangle(13, Rect(MagicWin.Dlg.Alignment.LeftOffset, MagicWin.Dlg.Alignment.TopOffset, WinWidth, WinHeight))
    else AoWEngine.FRegistry.SetRectangle(13, Rect(0, 0, 0, 0));
  with SWindow.ScannerWindow do
    AoWEngine.FRegistry.SetRectangle(6, Rect(SWindow.ScannerWindow.Alignment.RightOffset, SWindow.ScannerWindow.Alignment.TopOffset, WinWidth, WinHeight));
  with IWindow.InfoWin do
    AoWEngine.FRegistry.SetRectangle(7, Rect(IWindow.InfoWin.Alignment.RightOffset, IWindow.InfoWin.Alignment.TopOffset, WinWidth, WinHeight));
  with ChatWindow.ChatWin do
    if Alignment.AlignWidth <> awBoth then
      AoWEngine.FRegistry.SetRectangle(8, Rect(ChatWindow.ChatWin.Alignment.LeftOffset, ChatWindow.ChatWin.Alignment.BottomOffset, WinWidth, WinHeight))
    else AoWEngine.FRegistry.SetRectangle(8, Rect(0, 0, 0, 0));
  with MWindow.MapWindow do
    if Alignment.AlignWidth <> awBoth then
      AoWEngine.FRegistry.SetRectangle(9, Rect(MWindow.MapWindow.Alignment.LeftOffset, MWindow.MapWindow.Alignment.TopOffset, WinWidth, WinHeight))
    else AoWEngine.FRegistry.SetRectangle(9, Rect(0, 0, 0, 0));
  with TCUnit.TCUnitWin do
    AoWEngine.FRegistry.SetRectangle(12, Rect(TCUnit.TCUnitWin.Alignment.RightOffset, TCUnit.TCUnitWin.Alignment.TopOffset, WinWidth, WinHeight));
  with TCScanner.TCScannerWin do
    AoWEngine.FRegistry.SetRectangle(10, Rect(TCScanner.TCScannerWin.Alignment.RightOffset, TCScanner.TCScannerWin.Alignment.BottomOffset, WinWidth, WinHeight));
  if MWindow.FMapAlignWidth <> awBoth then
    AoWEngine.FRegistry.SetRectangle(11, Rect(MWindow.FMapRect.Left, MWindow.FMapRect.Top, MWindow.FMapRect.Right, MWindow.FMapRect.Bottom))
  else AoWEngine.FRegistry.SetRectangle(11, Rect(0, 0, 0, 0));
end;

procedure ShowTutorialMessage(Dialog: TTutorialWindow);
begin
  if Dialog.MessageMemo.Items.Count > 0 then Dialog.Dlg.Visible := True;
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
  if Music and not ((SongPlayer.CurrentIndex <> -1) and (SongPlayer.CurrentIndex < SongPlayer.Songs.Count) and
      (SongPlayer.Songs[SongPlayer.CurrentIndex] = 'SONGS\TITLE.IT')) then
    begin
      SongPlayer.Songs.Clear;
      SongPlayer.Songs.Add('SONGS\TITLE.IT');
      SongPlayer.Play(0);
    end;
  General.Manager.OverlayPriority := 0;
  Scene.TitleSceneIL.LoadDiscardableImageData;
  VideoDialog.SetSceneSize(640, 480);
  SetVideoMode(VideoDialog, scmTitle);
  VideoDialog.ApplyMode;
  MainForm.Display.FrameRate := 30;
  MainForm.DXDC.UseVerticalBlank := True; { Original enables vertical blank synchronization. }
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
    if AoWHSMap.FStartupSongs.Songs.Count <> 0 then
    begin
      for I := 0 to AoWHSMap.FStartupSongs.Songs.Count - 1 do
        if CompareText(AoWHSMap.FStartupSongs.SongNames[I], TranslateRStr(FileNotFoundRStr)) <> 0 then
          SongPlayer.Songs.Add(AoWHSMap.FStartupSongs.Songs[I]);
    end
    else SongPlayer.Songs.Add('Songs\Heartwoo.it');
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
  MapEvents.TheMapArmyDeselected(nil);
  MapEvents.TheMapStructureDeselected(nil);
  TBWindow.TBWorldUpdate(nil);
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
  Dialog.FAction := Kind;
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
