unit AOWMultiWin;

{ Draft declarations of AOWMultiWin, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWButton, AoWEdit, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll, AoWE, aowDPlayComp;

type
  TMultiWindow = class;


  { TMultiWindow (instance size $F4, VMT 0042A6C4): $EC pending map, $F0 menu animation height. }
  TMultiWindow = class(TDataModule)
  public
    published
    JoinPnl: TAOWPanel; { +0044 }
    GamesLB: TAOWListBox; { +0048 }
    GLBvsc: TAOWVScrollBar; { +004C }
    JoinBtn: TAOWButton; { +0050 }
    MultiPnl: TAOWPanel; { +0054 }
    BackBtn: TAOWButton; { +0058 }
    GamePanel: TAOWPanel; { +005C }
    TCPBtn: TAOWButton; { +0060 }
    IPXBtn: TAOWButton; { +0064 }
    SingleBtn: TAOWButton; { +0068 }
    EmailBtn: TAOWButton; { +006C }
    TCPPnl: TAOWPanel; { +0070 }
    TCPNameLbl: TAOWLabel; { +0074 }
    Single: TAOWLabel; { +0078 }
    Address: TAOWLabel; { +007C }
    CancelTCP: TAOWButton; { +0080 }
    Host: TAOWButton; { +0084 }
    Find: TAOWButton; { +0088 }
    GameLbl: TAOWLabel; { +008C }
    TCPName: TAOWEdit; { +0090 }
    IPEdit: TAOWEdit; { +0094 }
    LanPnl: TAOWPanel; { +0098 }
    LANFind: TAOWButton; { +009C }
    JoinLbl: TAOWLabel; { +00A0 }
    BottomPnl: TAOWPanel; { +00A4 }
    BackButn: TAOWButton; { +00A8 }
    MsgPnl: TAOWPanel; { +00AC }
    CancelOKBut: TAOWButton; { +00B0 }
    MessageMemo: TAOWMemo; { +00B4 }
    LANCancel: TAOWButton; { +00B8 }
    AOWLabel1: TAOWLabel; { +00BC }
    LANLbl: TAOWLabel; { +00C0 }
    IPXName: TAOWEdit; { +00C4 }
    LANHost: TAOWButton; { +00C8 }
    PBEMPnl: TAOWPanel; { +00CC }
    CancelPBEMBtn: TAOWButton; { +00D0 }
    CheckEmailBtn: TAOWButton; { +00D4 }
    NewPBEMGameBtn: TAOWButton; { +00D8 }
    LoadPBEMGameBtn: TAOWButton; { +00DC }
    EmailSettingsBtn: TAOWButton; { +00E0 }
    HeatNetBtn: TAOWButton; { +00E4 }
    Translator: TIvTranslator; { +00E8 }
    public
    FPendingMap: string; { $EC }
    FMenuHeight: Integer; { $F0 }
    procedure Execute(const MapName: string);
    function ConnectProvider(Kind: TConnectionType): Integer;
    function ValidateEmail: Boolean;
    published procedure CloseBtnClick; public  { draft }
    published procedure MultiWinUpdate; public
    published procedure JoinBtnClick; public  { draft }
    published procedure GamesLBChange; public
    published procedure BackBtnClick; public
    published procedure TCPBtnClick; public
    published procedure IPXBtnClick; public
    published procedure CancelTCPClick; public
    published procedure FindClick; public
    published procedure HostClick(Sender: TObject); public  { draft }
    published procedure IPXNameChange; public
    published procedure TCPNameChange; public
    published procedure LANFindClick; public
    published procedure LANHostClick(Sender: TObject); public  { draft }
    published procedure SingleBtnClick; public  { draft }
    published procedure ModemBtnClick; public
    published procedure DirectBtnClick; public
    published procedure EmailBtnClick; public
    published procedure CancelOKButClick; public
    published procedure CancelPBEMBtnClick; public
    published procedure CheckEmailBtnClick; public  { draft }
    published procedure NewPBEMGameBtnClick; public  { draft }
    published procedure LoadPBEMGameBtnClick; public
    published procedure EmailSettingsBtnClick; public
    published procedure HeatNetBtnClick; public
  end;


implementation

uses E2GameFlow, AoWMessageDlg, AoWSelFactionWin, E3Globals, AoWWinMan, aowSetupEvents, AoWFileDialog, AoWExeForms, AoWScenSetup, ShellAPI, AoWPOP3Dlg;

var
  SessionRefreshDelay: Integer; { $45B170 }

procedure TMultiWindow.CloseBtnClick;
begin
  General.PlayButtonSound(0);
  if SetupEvents.DPlay.Connected then SetupEvents.DPlay.DisConnect;
  TitleWindow.TitleWin.Visible := False;
  MultiPnl.Visible := False;
  E2GameFlow.ShowTitleScene(TitleScene, True);
end;

procedure TMultiWindow.MultiWinUpdate;
begin
  if MultiPnl.Visible and (FMenuHeight < GamePanel.WinHeight) then
  begin
    Inc(FMenuHeight, 10);
    if FMenuHeight > GamePanel.WinHeight then FMenuHeight := GamePanel.WinHeight;
    GamePanel.WinTop := FMenuHeight - GamePanel.WinHeight;
    BottomPnl.WinTop := 480 - FMenuHeight + GamePanel.WinHeight - BottomPnl.WinHeight;
    GamePanel.FSurfaceValid := False;
    BottomPnl.FSurfaceValid := False;
  end;
  if SetupEvents.DPlay.FAsyncEnum and SetupEvents.DPlay.Connected and not SetupEvents.DPlay.InSession then
    begin
      Dec(SessionRefreshDelay);
      if SessionRefreshDelay < 1 then
      begin
        SessionRefreshDelay := 30;
        GamesLB.Items.Clear;
        if SetupEvents.DPlay.GetSessions(True) = 0 then
          GamesLB.Items.AddStrings(SetupEvents.DPlay.Sessions);
        if GamesLB.Selected > GamesLB.Items.Count - 1 then
        begin
          GamesLB.Selected := -1;
          JoinBtn.Visible := False;
        end;
      end;
    end;
end;


procedure TMultiWindow.JoinBtnClick;
var
  Index: Integer;
begin
  General.PlayButtonSound(0);
  Index := GamesLB.Selected;
  if Index > -1 then
    if (SetupEvents.DPlay.JoinSession(Index) = 0) and SetupEvents.DPlay.InSession then
    begin
      MultiPnl.Visible := False;
      SetupEvents.SetupControl.SetupUser(SetupEvents.DPlay.PlayerName, SetupEvents.DPlay.PlayerID);
      ScenSetup.Execute(SetupEvents.SetupControl);
    end;
end;

procedure TMultiWindow.GamesLBChange;
begin
  if GamesLB.Selected > -1 then JoinBtn.Visible := True else JoinBtn.Visible := False;
end;


procedure TMultiWindow.BackBtnClick;
begin
  General.PlayButtonSound(0);
  case SetupEvents.DPlay.ConnectionType of
    conTCP: TCPPnl.Visible := True;
    conIPX: LanPnl.Visible := True;
  end;
  SetupEvents.DPlay.GetSessions(False);
  JoinPnl.Visible := False;
end;


procedure TMultiWindow.TCPBtnClick;
begin
  General.PlayButtonSound(0);
  GamePanel.Visible := False;
  TCPPnl.Visible := True;
end;


procedure TMultiWindow.IPXBtnClick;
begin
  General.PlayButtonSound(0);
  GamePanel.Visible := False;
  LanPnl.Visible := True;
end;


procedure TMultiWindow.CancelTCPClick;
begin
  General.PlayButtonSound(0);
  GamePanel.Visible := True;
  TCPPnl.Visible := False;
  LanPnl.Visible := False;
end;


procedure TMultiWindow.FindClick;
begin
  General.PlayButtonSound(0);
  if ConnectProvider(conTCP) = 0 then
  begin
    SetupEvents.DPlay.PlayerName := TCPName.Text;
    SessionRefreshDelay := 0;
    TCPPnl.Visible := False;
    JoinPnl.Visible := True;
    GamesLB.Items.Clear;
    GamesLB.FSized := False;
  end;
end;


procedure TMultiWindow.HostClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  if ConnectProvider(conTCP) = 0 then
  begin
    SetupEvents.DPlay.PlayerName := TCPName.Text;
    SetupEvents.DPlay.SessionName := AoWE.Format(TranslateRStr(XsGameRStr), [TCPName.Text]);
    if SetupEvents.DPlay.CreateSession = 0 then
    begin
      MultiPnl.Visible := False;
      SetupEvents.SetupControl.SetupHost(SetupEvents.DPlay.PlayerName, 1, SetupEvents.DPlay.PlayerID);
      if FPendingMap <> '' then SetupEvents.SetupControl.hPickMap(FPendingMap);
      ScenSetup.Execute(SetupEvents.SetupControl);
    end;
  end;
end;

procedure TMultiWindow.IPXNameChange;
begin
  TCPName.Text := IPXName.Text;
end;


procedure TMultiWindow.TCPNameChange;
begin
  IPXName.Text := TCPName.Text;
end;


procedure TMultiWindow.LANFindClick;
begin
  General.PlayButtonSound(0);
  if ConnectProvider(conIPX) = 0 then
  begin
    SetupEvents.DPlay.PlayerName := TCPName.Text;
    SessionRefreshDelay := 0;
    LanPnl.Visible := False;
    JoinPnl.Visible := True;
    GamesLB.Items.Clear;
    GamesLB.FSized := False;
  end;
end;


procedure TMultiWindow.LANHostClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  if ConnectProvider(conIPX) = 0 then
  begin
    SetupEvents.DPlay.PlayerName := TCPName.Text;
    SetupEvents.DPlay.SessionName := AoWE.Format(TranslateRStr(XsGameRStr), [TCPName.Text]);
    if SetupEvents.DPlay.CreateSession = 0 then
    begin
      MultiPnl.Visible := False;
      SetupEvents.SetupControl.SetupHost(SetupEvents.DPlay.PlayerName, 1, SetupEvents.DPlay.PlayerID);
      if FPendingMap <> '' then SetupEvents.SetupControl.hPickMap(FPendingMap);
      ScenSetup.Execute(SetupEvents.SetupControl);
    end;
  end;
end;

procedure TMultiWindow.SingleBtnClick;
begin
  General.PlayButtonSound(0);
  MultiPnl.Visible := False;
  SetupEvents.SetupControl.SetupHost('', 0, 0);
  if FPendingMap <> '' then SetupEvents.SetupControl.hPickMap(FPendingMap);
  ScenSetup.Execute(SetupEvents.SetupControl);
end;

procedure TMultiWindow.ModemBtnClick;
begin
  General.PlayButtonSound(0);
end;


procedure TMultiWindow.DirectBtnClick;
begin
  General.PlayButtonSound(0);
end;


procedure TMultiWindow.EmailBtnClick;
begin
  General.PlayButtonSound(0);
  GamePanel.Visible := False;
  PBEMPnl.Visible := True;
end;


procedure TMultiWindow.CancelOKButClick;
begin
  General.PlayButtonSound(0);
end;


procedure TMultiWindow.CancelPBEMBtnClick;
begin
  GamePanel.Visible := True;
  PBEMPnl.Visible := False;
end;


procedure TMultiWindow.CheckEmailBtnClick;
begin
  if ValidateEmail then POP3Dlg.ShowDialog;
end;

procedure TMultiWindow.NewPBEMGameBtnClick;
begin
  if ValidateEmail then
  begin
    MultiPnl.Visible := False;
    SetupEvents.SetupControl.SetupHost('', 2, 0);
    if FPendingMap <> '' then SetupEvents.SetupControl.hPickMap(FPendingMap);
    ScenSetup.Execute(SetupEvents.SetupControl);
  end;
end;

procedure TMultiWindow.LoadPBEMGameBtnClick;
begin
  FileDlgWindow.FMode := 0;
  FileDlgWindow.FileDialog.Visible := True;
  SetCurrentDirectory(PChar(AoWEngine.StartupDirectory + 'EmailIn\'));
  FileDlgWindow.FindFiles;
end;


procedure TMultiWindow.EmailSettingsBtnClick;
begin
  ShowEmailSettings(EmailSettingsDlg);
end;


procedure TMultiWindow.HeatNetBtnClick;
begin
  if not AoWEngine.FDemo then
  begin
    if Integer(ShellExecute(Application.Handle, 'open', PChar(AoWEngine.StartupDirectory + 'GOTOHEAT.EXE'),
      PChar(IntToStr(5223)), nil, SW_SHOW)) > 32 then Application.Terminate;
  end
  else ShowDemoMessage;
end;




function TMultiWindow.ConnectProvider(Kind: TConnectionType): Integer;
var
  I, Found: Integer;
begin
  I := 0;
  Found := -1;
  Result := 0; { Original also reports success when no provider is found. }
  while I < SetupEvents.DPlay.ConnectionItems.Count do
  begin
    if TGDConnection(SetupEvents.DPlay.ConnectionItems[I]).FType = Kind then
    begin
      Found := I;
      I := SetupEvents.DPlay.ConnectionItems.Count;
    end;
    Inc(I);
  end;
  if Found > -1 then
  begin
    SetupEvents.DPlay.TCPPort := IPEdit.Text;
    Result := SetupEvents.DPlay.Connect(Found);
  end;
end;

function TMultiWindow.ValidateEmail: Boolean;
begin
  if AoWEngine.FRegistry.GetLocalEmailAddress = '' then
  begin
    ResetMessageDialog(MessageDlg);
    MessageDlg.MessageMemo.Items.Add('');
    MessageDlg.MessageMemo.Items.Add(TranslateRStr(PleaseSetupEmailSettingsFirstRStr));
    MessageDlg.OKPnl.Visible := True;
    MessageDlg.Dlg.Visible := True;
    Result := False;
  end
  else Result := True;
end;

procedure TMultiWindow.Execute(const MapName: string);
var I: Integer;
begin
  if (SongPlayer.CurrentIndex = -1) or (SongPlayer.CurrentIndex >= SongPlayer.Songs.Count) or
    (SongPlayer.Songs[SongPlayer.CurrentIndex] <> 'SONGS\TITLE.IT') then
  begin SongPlayer.Songs.Clear; SongPlayer.Songs.Add('SONGS\TITLE.IT'); SongPlayer.Play(0); end;
  VideoDialog.SetSceneSize(640, 480);
  FPendingMap := MapName;
  if SetupEvents.DPlay.Connected then SetupEvents.DPlay.DisConnect;
  TitleWindow.TitleWin.Visible := True; TitleWindow.TitlePnl.Visible := False;
  MultiPnl.Visible := True; GamePanel.Visible := True; TCPPnl.Visible := False;
  LanPnl.Visible := False; JoinPnl.Visible := False; TCPBtn.Visible := False;
  IPXBtn.Visible := False; PBEMPnl.Visible := False;
  if SetupEvents.DPlay.GetConnections = 0 then
    for I := 0 to SetupEvents.DPlay.ConnectionItems.Count - 1 do
      case TGDConnection(SetupEvents.DPlay.ConnectionItems[I]).FType of conTCP: TCPBtn.Visible := True;
      conIPX: IPXBtn.Visible := True; end;
end;

end.
