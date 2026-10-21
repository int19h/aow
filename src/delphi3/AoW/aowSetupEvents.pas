unit aowSetupEvents;

{ aowSetupEvents handlers recovered from AoW.exe.
  Class layouts and field offsets follow the original executable. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWSetup, aowDPlayComp;

type
  TSetupEvents = class;


  { TSetupEvents (instance size 80, VMT 0041375C) }
  TSetupEvents = class(TDataModule)
  public
    published
    DPlay: TGDPlay; { +0044 }
    SetupControl: TSetupControl; { +0048 }
    public
    FLobbyGame: Boolean; FReserved4D: array[0..2] of Byte; { $4C }
    { conflict: FCommandLineLaunch: Boolean; FSetupPad: array[0..2] of Byte; }
    procedure ClearChat;
    procedure UpdateChatPlayers;
    procedure UpdatePlayerName(const Name: string);
    procedure SetupControlStart;
    procedure SetupControlSendMap(Control: TSetupControl; Data: Pointer; Size, Recipient: Integer);
    procedure DPlayFileStartMessage(ID: Integer; var Name: string; Size: Integer; var Response: Byte);
    procedure DPlayFileDoneMessage(ID: Integer; const FileData: TGDFile);
    procedure DPlayFileProgressMessage(ID, Position, Size: Integer);
    procedure DPlayChatMessage(var Message: string; var ToID, FromID: Integer);
    procedure DPlayMessageTimeout(var Message: TGDMessage);
    procedure DPlayEjected;
    procedure DPlayPingMessage(PingMS, Player: Integer);
    procedure SetupControlCustomizeLeader(Control: TSetupControl; Leader: TCustomizeLeaderControl);
    procedure SetupControlLoadMap(Control: TSetupControl; const FileName: string);
    function SetupControlSendData(Data: Pointer; Size, Recipient: Integer): Boolean;
    procedure SetupControlSettingChanged;
    procedure SetupControlEjectPlayer(Control: TSetupControl; RemoteID: Integer);
    procedure DPlayMessage(var Data: Pointer; var Size, ToID, FromID: Integer);
    procedure SetupControlSynchronize(Control: TSetupControl);
    procedure SetupControlPlayerSetupDone;
    procedure SetupControlIncompatibleVersion(Control: TSetupControl; Major, Minor: Integer);
    procedure DPlaySessionLost;
    procedure SetupControlSendingMaps;
    procedure DPlayMessageError;
    procedure SetupEventsCreate;
    procedure DPlayDestroyPlayer(ID, NumPlayers: Integer);
  end;


var
  SetupEvents: TSetupEvents;

implementation

uses AoWE, AoWExeForms, E2Globals, E2GameFlow, AoWWinMan, AoWUnit,
  AoWReg, AoWScenSetup, AoWSyncDlg, AoWMessageDlg;

procedure TSetupEvents.ClearChat;
begin
  ChatWindow.ChatMemo.Items.Clear;
  ChatWindow.ChatEdit.Text := '';
end;

procedure TSetupEvents.UpdateChatPlayers;
var
  I: Integer;
begin
  ChatWindow.PlayerList.Items.Clear;
  ChatWindow.PlayerList.Items.AddObject(TranslateRStr(AllPlayersRStr), nil);
  if AoWHSMap <> nil then
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (I <> AoWHSMap.FSeatedPlayer) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psTerminated) and
        (AoWHSMap.FPlayerCommunicator.PCC.Players[I].ConnectionMode = cmRemote) then
      begin
        ChatWindow.PlayerList.Items.AddObject(AoWHSMap.FPlayers.GetPlayers(I).FLeader.FHeroName,
          TObject(AoWHSMap.FPlayerCommunicator.PCC.Players[I].SystemID));
        ChatWindow.PlayerList.Selected := 0;
      end;
end;

procedure TSetupEvents.UpdatePlayerName(const Name: string);
begin
  if SetupControl.GetRemote and DPlay.Connected then
    DPlay.PlayerName := Name;
end;

procedure TSetupEvents.SetupControlStart;
begin
  SynchronizeDlg.Dlg.Visible := False;
  ScenSetup.CloseSetup;
  StartGame(General);
  if DPlay.Connected then
  begin
    ClearChat;
    UpdateChatPlayers;
  end;
end;

procedure TSetupEvents.SetupControlSendMap(Control: TSetupControl; Data: Pointer; Size, Recipient: Integer);
begin
  ProgressDialog.Title.Text := 'Sending Map to ' + DPlay.Players[DPlay.GetPlayerIndex(Recipient)] + '...';
  ProgressDialog.StatusLbl.Text := '0k of ' + IntToStr(Size div 1000) + 'k';
  ProgressDialog.Bar.Position := 0;
  ProgressDialog.Bar.Max := Size;
  DPlay.SendFileDataMessage(Recipient, Data, Size, 'MP Map', fsmBurst);
end;

procedure TSetupEvents.DPlayFileStartMessage(ID: Integer; var Name: string; Size: Integer; var Response: Byte);
begin
  ProgressDialog.StatusLbl.Text := '0k of ' + IntToStr(Size div 1000) + 'k';
  ProgressDialog.Title.Text := 'Receiving File';
  ProgressDialog.Bar.Max := Size;
  ProgressDialog.Bar.Position := 0;
end;

procedure TSetupEvents.DPlayFileDoneMessage(ID: Integer; const FileData: TGDFile);
begin
  if FileData <> nil then SetupControl.MapReceived(FileData.FData, FileData.FSize)
  else SetupControl.MapReceived(nil, 0);
end;

procedure TSetupEvents.DPlayFileProgressMessage(ID, Position, Size: Integer);
begin
  if Position > ProgressDialog.Bar.Position then
  begin
    ProgressDialog.StatusLbl.Text := IntToStr(Position div 1000) + 'k of ' + IntToStr(Size div 1000) + 'k';
    ProgressDialog.Bar.Position := Position;
  end;
end;

procedure TSetupEvents.DPlayChatMessage(var Message: string; var ToID, FromID: Integer);
begin
  if ScenSetup.ScenSetupPnl.Visible then
  begin
    ScenSetup.ChatMemo.Items.Add(Message);
    ScenSetup.FChatScrollPending := True;
  end
  else
  begin
    ChatWindow.ChatMemo.Items.Add(Message);
    TBWindow.FChatFlash := 136;
    ChatWindow.FScrollPending := True;
    PlaySample('SFX\EVENTS\CHAT.WAV');
  end;
end;

procedure TSetupEvents.DPlayMessageTimeout(var Message: TGDMessage);
var
  Player: Shortint;
  Event: TPlayerConnectionEventLog;
begin
  if AoWHSMap <> nil then
  begin
    Player := AoWHSMap.FPlayerCommunicator.PCC.IndexOfSystemID(Message.FToID);
    if Player <> -1 then
      if AoWHSMap.FPlayers.GetPlayers(Shortint(Player)) <> nil then
        if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then
        begin
          Event := TPlayerConnectionEventLog.Create(nil);
          Event.Setup(Player, 1);
          AoWHSMap.TriggerExecuteEventLog(Event, False, nil);
          Event.Release;
        end;
  end;
end;

procedure TSetupEvents.DPlayEjected;
begin
  if ScenSetup.ScenSetupPnl.Visible then
  begin
    ScenSetup.ExitGameClick(nil);
    ResetMessageDialog(AoWExeForms.MessageDlg);
    AoWExeForms.MessageDlg.TitleLbl.Text := TranslateRStr(WarningRStr);
    AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
    AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(YouWereEjectedByTheHostRStr));
    AoWExeForms.MessageDlg.OKPnl.Visible := True;
    AoWExeForms.MessageDlg.Dlg.Visible := True;
  end;
end;

procedure TSetupEvents.DPlayPingMessage(PingMS, Player: Integer);
begin
  if ScenSetup.ScenSetupPnl.Visible then ScenSetup.PingList.FDrawn := False;
end;

procedure TSetupEvents.SetupControlCustomizeLeader(Control: TSetupControl; Leader: TCustomizeLeaderControl);
begin
  ScenSetup.ScenSetupPnl.Visible := False;
  LeaderSetupWin.Execute(Leader);
end;

procedure TSetupEvents.SetupControlLoadMap(Control: TSetupControl; const FileName: string);
begin
  ProgressDialog.Title.Text := AoWE.Format(TranslateRStr(LoadingXRStr), [ExtractFileName(FileName)]);
  ProgressDialog.StatusLbl.Text := '';
  ProgressDialog.Bar.Position := 0;
  ProgressDialog.Bar.Max := 100;
  ProgressDialog.ProgDlg.Visible := True;
  General.Manager.OverlayPriority := 5000;
  if not Control.FSettings.FCustomizeLeaders then
  begin
    SongPlayer.Stop(False);
    SongPlayer.Songs.Clear;
    FadeMusicVolume(0, 1);
  end;
  if Control.FStream.Size <> 0 then
  begin
    AoWEngine.LoadHSMfromStream(Control.FStream, False, General.MapProgress);
    AoWHSMap.FileName := AoWEngine.StartupDirectory + 'Scenario\' + ExtractFileName(FileName);
  end
  else AoWEngine.LoadHSM(FileName, False, General.MapProgress);
  General.Manager.OverlayPriority := 0;
  ProgressDialog.ProgDlg.Visible := False;
  Control.MapLoaded;
end;

function TSetupEvents.SetupControlSendData(Data: Pointer; Size, Recipient: Integer): Boolean;
begin
  Result := DPlay.SendMessage(Recipient, Data, Size) <> 0; { Original reports a nonzero HRESULT as true. }
end;

procedure TSetupEvents.SetupControlSettingChanged;
begin UpdateScenarioSetup(ScenSetup); end;

procedure TSetupEvents.SetupControlEjectPlayer(Control: TSetupControl; RemoteID: Integer);
begin DPlay.EjectPlayer(RemoteID); end;

procedure TSetupEvents.DPlayMessage(var Data: Pointer; var Size, ToID, FromID: Integer);
begin
  if ssBusy in SetupControl.FStatus then SetupControl.DataReceived(Data, Size, FromID);
  if (AoWHSMap <> nil) and (msActivated in AoWHSMap.Status) then
    if AoWHSMap.FPlayerCommunicator.PCC is TRemotePCC then
      TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC).DataReceived(Data, Size, FromID);
end;

procedure TSetupEvents.SetupControlSynchronize(Control: TSetupControl);
begin
  General.Manager.FAligned := False;
  ScenSetup.ScenSetupPnl.Visible := False;
  if Control.GetRemote then SynchronizeDlg.Dlg.Visible := True;
end;

procedure TSetupEvents.SetupControlPlayerSetupDone;
begin DPlay.LockSession; end;

procedure TSetupEvents.SetupControlIncompatibleVersion(Control: TSetupControl; Major, Minor: Integer);
begin
  ResetMessageDialog(AoWExeForms.MessageDlg);
  AoWExeForms.MessageDlg.TitleLbl.Text := TranslateRStr(WarningRStr);
  AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
  AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(IncompatibleVersionRStr));
  AoWExeForms.MessageDlg.MessageMemo.Items.Add(AoWE.Format(TranslateRStr(VersionXYRequiredRStr), [IntToStr(Major), IntToStr(Minor)]));
  AoWExeForms.MessageDlg.OKPnl.Visible := True;
  AoWExeForms.MessageDlg.Dlg.Visible := True;
  DPlay.CloseSession;
  ScenSetup.CloseSetup;
  if SetupEvents.FLobbyGame then MainForm.Close else MultiWindow.Execute('');
end;

procedure TSetupEvents.DPlaySessionLost;
begin
  if AoWHSMap = nil then
  begin
    ResetMessageDialog(AoWExeForms.MessageDlg);
    AoWExeForms.MessageDlg.TitleLbl.Text := TranslateRStr(WarningRStr);
    AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
    AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(ConnectionLostRStr));
    AoWExeForms.MessageDlg.OKPnl.Visible := True;
    AoWExeForms.MessageDlg.Dlg.Visible := True;
    DPlay.Disconnect;
    ScenSetup.CloseSetup;
    General.Manager.OverlayPriority := 0;
    ProgressDialog.ProgDlg.Visible := False;
    if SetupEvents.FLobbyGame then MainForm.Close else MultiWindow.Execute('');
  end
  else AoWHSMap.PlayerConnectionLost;
end;

procedure TSetupEvents.SetupControlSendingMaps;
begin
  General.Manager.OverlayPriority := 5000;
  ProgressDialog.ProgDlg.Visible := True;
  ProgressDialog.Title.Text := 'Transferring Files...';
  ProgressDialog.StatusLbl.Text := 'Please Wait';
  ProgressDialog.Bar.Position := 0;
end;

procedure TSetupEvents.DPlayMessageError;
begin
  if AoWHSMap <> nil then AoWHSMap.PlayerConnectionLost;
end;

procedure TSetupEvents.SetupEventsCreate;
begin DPlay.AppGUID := ID_AOWAPP; end;

procedure TSetupEvents.DPlayDestroyPlayer(ID, NumPlayers: Integer);
var
  Player: Shortint;
begin
  if ScenSetup.FSetupControl <> nil then
    if ScenSetup.FSetupControl.GetHost then ScenSetup.FSetupControl.hDisconnectPlayer(ID);
  if (AoWHSMap <> nil) and (AoWHSMap.FPlayerCommunicator.PCC <> nil) then
  begin
    Player := AoWHSMap.FPlayerCommunicator.PCC.IndexOfSystemID(ID);
    if Player <> -1 then
      if AoWHSMap.FPlayers.GetPlayers(Shortint(Player)) <> nil then
      begin
        if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then AoWHSMap.PlayerDisconnected(Player);
        UpdateChatPlayers;
      end;
  end;
end;

end.
