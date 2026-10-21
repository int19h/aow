unit AoWScenSetup;

{ Draft declarations of AoWScenSetup, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWSetup, AoWComp, AoWButton, AoWCheckBox, AoWComboBox, AoWEdit, AoWFrame, AoWHScroll, AoWImage, AoWLabel, AoWListBox, AoWMemo, AoWPanel, AoWVScroll;

type
  TScenSetup = class;


  { TScenSetup (instance size $348, VMT 0040FBF8).
    $338 map-validation delay; $33C setup control; $340 ping delay; $344 chat scroll pending. }
  TScenSetup = class(TDataModule)
  public
    published
    ChatMemo: TAOWMemo; { +0044 }
    ChatPnl: TAOWPanel; { +0048 }
    ChatSB: TAOWVScrollBar; { +004C }
    ChatEdit: TAOWEdit; { +0050 }
    SidesPnl: TAOWPanel; { +0054 }
    SettingsPnl: TAOWPanel; { +0058 }
    PlayerList: TAOWListBox; { +005C }
    R1Pnl: TAOWPanel; { +0060 }
    R5Pnl: TAOWPanel; { +0064 }
    R9Pnl: TAOWPanel; { +0068 }
    R2Pnl: TAOWPanel; { +006C }
    R6Pnl: TAOWPanel; { +0070 }
    R10Pnl: TAOWPanel; { +0074 }
    R3Pnl: TAOWPanel; { +0078 }
    R7Pnl: TAOWPanel; { +007C }
    R11Pnl: TAOWPanel; { +0080 }
    R4Pnl: TAOWPanel; { +0084 }
    R8Pnl: TAOWPanel; { +0088 }
    R12Pnl: TAOWPanel; { +008C }
    ExitGame: TAOWButton; { +0090 }
    PickScenarioBtn: TAOWButton; { +0094 }
    StartBtn: TAOWButton; { +0098 }
    MiscLbl: TAOWLabel; { +009C }
    ScenSetupPnl: TAOWPanel; { +00A0 }
    R1PlayerIcon: TAOWImage; { +00A4 }
    R1Lbl: TAOWLabel; { +00A8 }
    R1PlayerCB: TAOWComboBox; { +00AC }
    R1CenterPnl: TAOWPanel; { +00B0 }
    TurnLbl: TAOWLabel; { +00B4 }
    DurationLbl: TAOWLabel; { +00B8 }
    TurnsLbl: TAOWLabel; { +00BC }
    TurnTimeLbl: TAOWLabel; { +00C0 }
    TurnTimeSl: TAOWHScrollBar; { +00C4 }
    TurnTimeVal: TAOWLabel; { +00C8 }
    DurFr: TAoWFrame; { +00CC }
    TurnsSl: TAOWHScrollBar; { +00D0 }
    TurnsVal: TAOWLabel; { +00D4 }
    PlayModeCB: TAOWComboBox; { +00D8 }
    TurnVSB: TAOWVScrollBar; { +00DC }
    R1InfoLbl: TAOWLabel; { +00E0 }
    R1BehaviorCB: TAOWComboBox; { +00E4 }
    R1BehaviorSB: TAOWVScrollBar; { +00E8 }
    R1PlayerSB: TAOWVScrollBar; { +00EC }
    R3CenterPnl: TAOWPanel; { +00F0 }
    R3Lbl: TAOWLabel; { +00F4 }
    R3BehaviorCB: TAOWComboBox; { +00F8 }
    R3BehaviorSB: TAOWVScrollBar; { +00FC }
    R3PlayerIcon: TAOWImage; { +0100 }
    R3PlayerLbl: TAOWLabel; { +0104 }
    R3PlayerCB: TAOWComboBox; { +0108 }
    R3PlayerSB: TAOWVScrollBar; { +010C }
    R3InfoLbl: TAOWLabel; { +0110 }
    R2CenterPnl: TAOWPanel; { +0114 }
    R2Lbl: TAOWLabel; { +0118 }
    R2BehaviorCB: TAOWComboBox; { +011C }
    R2BehaviorSB: TAOWVScrollBar; { +0120 }
    R2PlayerIcon: TAOWImage; { +0124 }
    R2InfoLbl: TAOWLabel; { +0128 }
    R2PlayerCB: TAOWComboBox; { +012C }
    R2PlayerSB: TAOWVScrollBar; { +0130 }
    R2PlayerLbl: TAOWLabel; { +0134 }
    R4InfoLbl: TAOWLabel; { +0138 }
    R4PlayerLbl: TAOWLabel; { +013C }
    R4CenterPnl: TAOWPanel; { +0140 }
    R4Lbl: TAOWLabel; { +0144 }
    R4BehaviorSB: TAOWVScrollBar; { +0148 }
    R4PlayerCB: TAOWComboBox; { +014C }
    R4PlayerSB: TAOWVScrollBar; { +0150 }
    R4PlayerIcon: TAOWImage; { +0154 }
    R5PlayerIcon: TAOWImage; { +0158 }
    R5Lbl: TAOWLabel; { +015C }
    R5PlayerCB: TAOWComboBox; { +0160 }
    R5CenterPnl: TAOWPanel; { +0164 }
    R5BehaviorCB: TAOWComboBox; { +0168 }
    R5BehaviorSB: TAOWVScrollBar; { +016C }
    R5PlayerSB: TAOWVScrollBar; { +0170 }
    R5InfoLbl: TAOWLabel; { +0174 }
    R5PlayerLbl: TAOWLabel; { +0178 }
    R6CenterPnl: TAOWPanel; { +017C }
    R6Lbl: TAOWLabel; { +0180 }
    R6BehaviorCB: TAOWComboBox; { +0184 }
    R6BehaviorSB: TAOWVScrollBar; { +0188 }
    R6PlayerIcon: TAOWImage; { +018C }
    R6PlayerLbl: TAOWLabel; { +0190 }
    R6PlayerCB: TAOWComboBox; { +0194 }
    R6PlayerSB: TAOWVScrollBar; { +0198 }
    R6InfoLbl: TAOWLabel; { +019C }
    R7CenterPnl: TAOWPanel; { +01A0 }
    R7Lbl: TAOWLabel; { +01A4 }
    R7BehaviorCB: TAOWComboBox; { +01A8 }
    R7BehaviorSB: TAOWVScrollBar; { +01AC }
    R7PlayerIcon: TAOWImage; { +01B0 }
    R7PlayerLbl: TAOWLabel; { +01B4 }
    R7PlayerCB: TAOWComboBox; { +01B8 }
    R7PlayerSB: TAOWVScrollBar; { +01BC }
    R7InfoLbl: TAOWLabel; { +01C0 }
    R8InfoLbl: TAOWLabel; { +01C4 }
    R8PlayerLbl: TAOWLabel; { +01C8 }
    R8CenterPnl: TAOWPanel; { +01CC }
    R8Lbl: TAOWLabel; { +01D0 }
    R8BehaviorCB: TAOWComboBox; { +01D4 }
    R8BehaviorSB: TAOWVScrollBar; { +01D8 }
    R8PlayerCB: TAOWComboBox; { +01DC }
    R8PlayerSB: TAOWVScrollBar; { +01E0 }
    R8PlayerIcon: TAOWImage; { +01E4 }
    R9PlayerIcon: TAOWImage; { +01E8 }
    R9Lbl: TAOWLabel; { +01EC }
    R9PlayerCB: TAOWComboBox; { +01F0 }
    R9CenterPnl: TAOWPanel; { +01F4 }
    R9BehaviorCB: TAOWComboBox; { +01F8 }
    R9BehaviorSB: TAOWVScrollBar; { +01FC }
    R9PlayerSB: TAOWVScrollBar; { +0200 }
    R9InfoLbl: TAOWLabel; { +0204 }
    R9PlayerLbl: TAOWLabel; { +0208 }
    R10CenterPnl: TAOWPanel; { +020C }
    R10Lbl: TAOWLabel; { +0210 }
    R10BehaviorCB: TAOWComboBox; { +0214 }
    R10BehaviorSB: TAOWVScrollBar; { +0218 }
    R10PlayerIcon: TAOWImage; { +021C }
    R10PlayerLbl: TAOWLabel; { +0220 }
    R10PlayerCB: TAOWComboBox; { +0224 }
    s10sb2: TAOWVScrollBar; { +0228 }
    R10InfoLbl: TAOWLabel; { +022C }
    R11CenterPnl: TAOWPanel; { +0230 }
    R11Lbl: TAOWLabel; { +0234 }
    R11BehaviorCB: TAOWComboBox; { +0238 }
    R11BehaviorSB: TAOWVScrollBar; { +023C }
    R11PlayerIcon: TAOWImage; { +0240 }
    R11PlayerLbl: TAOWLabel; { +0244 }
    R11PlayerCB: TAOWComboBox; { +0248 }
    R11PlayerSB: TAOWVScrollBar; { +024C }
    R11InfoLbl: TAOWLabel; { +0250 }
    R12InfoLbl: TAOWLabel; { +0254 }
    R12PlayerLbl: TAOWLabel; { +0258 }
    R12CenterPnl: TAOWPanel; { +025C }
    R12Lbl: TAOWLabel; { +0260 }
    R12BehaviorCB: TAOWComboBox; { +0264 }
    R12BehaviorSB: TAOWVScrollBar; { +0268 }
    R12PlayerCB: TAOWComboBox; { +026C }
    R12PlayerSB: TAOWVScrollBar; { +0270 }
    R12PlayerIcon: TAOWImage; { +0274 }
    PreferredRaceCB: TAOWComboBox; { +0278 }
    PreferredRaceSB: TAOWVScrollBar; { +027C }
    PreferredRaceLbl: TAOWLabel; { +0280 }
    LFr: TAoWFrame; { +0284 }
    CustomizeLeaders: TAOWCheckBox; { +0288 }
    CustomizeLeadersLbl: TAOWLabel; { +028C }
    EjectBtn: TAOWButton; { +0290 }
    R4BehaviorCB: TAOWComboBox; { +0294 }
    R1FogPnl: TAOWPanel; { +0298 }
    R1PlayerLbl: TAOWLabel; { +029C }
    R2FogPnl: TAOWPanel; { +02A0 }
    R3FogPnl: TAOWPanel; { +02A4 }
    R4FogPnl: TAOWPanel; { +02A8 }
    R8FogPnl: TAOWPanel; { +02AC }
    R7FogPnl: TAOWPanel; { +02B0 }
    R6FogPnl: TAOWPanel; { +02B4 }
    R5FogPnl: TAOWPanel; { +02B8 }
    R12FogPnl: TAOWPanel; { +02BC }
    R11FogPnl: TAOWPanel; { +02C0 }
    R10FogPnl: TAOWPanel; { +02C4 }
    R9FogPnl: TAOWPanel; { +02C8 }
    PreferredRaceSort: TAOWButton; { +02CC }
    PlayerListSort: TAOWButton; { +02D0 }
    ConnectionPnl: TAOWPanel; { +02D4 }
    PreferredRaceList: TAOWListBox; { +02D8 }
    AOWButton1: TAOWButton; { +02DC }
    PingList: TAOWListBox; { +02E0 }
    PlayerListSB: TAOWVScrollBar; { +02E4 }
    SettingsFogPnl: TAOWPanel; { +02E8 }
    ExplorationLbl: TAOWLabel; { +02EC }
    Exploration: TAOWCheckBox; { +02F0 }
    ScenarioLbl: TAOWLabel; { +02F4 }
    HostNameLbl: TAOWLabel; { +02F8 }
    PlayerNameLbl: TAOWLabel; { +02FC }
    FileNameLbl: TAOWLabel; { +0300 }
    MakeHostBtn: TAOWButton; { +0304 }
    RestartSettingsFogPnl: TAOWPanel; { +0308 }
    ChatFogPnl: TAOWImage; { +030C }
    LeadersOnMapCB: TAOWCheckBox; { +0310 }
    AOWLabel1: TAOWLabel; { +0314 }
    AlliedVictoryCB: TAOWCheckBox; { +0318 }
    AlliedVictoryLbl: TAOWLabel; { +031C }
    Translator: TIvTranslator; { +0320 }
    AOWVScrollBar1: TAOWVScrollBar; { +0324 }
    TacticalCombatCB: TAOWComboBox; { +0328 }
    TacticalCombatLbl: TAOWLabel; { +032C }
    AlwaysViewTCCB: TAOWCheckBox; { +0330 }
    AlwaysViewTCLbl: TAOWLabel; { +0334 }
    public
    FValidateDelay: Integer; { $338 }
    FSetupControl: TSetupControl; { $33C }
    FPingDelay: Integer; { $340 }
    FChatScrollPending: Boolean; { $344 }
    F_ScenSetup_345: array[0..2] of Byte;
    procedure ExitGameClick;  { draft }
    procedure ChatEditReturn;
    procedure PlayerListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
    procedure PingListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
    procedure ScenSetupPnlUpdate;
    procedure PickScenarioBtnClick;  { draft }
    procedure PreferredRaceCBChange;
    procedure StartBtnClick;
    procedure EjectBtnClick;
    procedure MakeHostBtnClick;
    procedure PlayerListSBChange;
    procedure PlayerListChange(Sender: TObject);
    procedure TurnTimeSlChange;
    procedure TurnsCBChange(Sender: TObject);
    procedure TurnsSlChange(Sender: TObject);
    procedure PlayModeCBChange;
    procedure RacePlayerCBChange(Sender: TObject);
    procedure RaceBehaviorCBChange(Sender: TAOWComboBox);
    procedure LeadersOnMapCBChange(Sender: TObject);
    procedure CustomizeLeadersChange(Sender: TObject);
    procedure AlliedVictoryCBChange(Sender: TObject);
    procedure ExplorationChange(Sender: TObject);
    procedure AlwaysViewTCCBChange;
    procedure SettingsClick;
    procedure RacePnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure ChatSBUpdate;
    procedure TacticalCombatCBChange;
    procedure UpdateTurnTime;
    procedure UpdateTurnLimit;
    procedure SelectPlayer(Index: Integer);
  end;


implementation

uses E3Globals, AoWWinMan, aowSetupEvents, aowDPlayComp, AoWEmailGameSettingsDlg, AoWExeForms;

procedure TScenSetup.ExitGameClick;
begin end;

procedure TScenSetup.ChatEditReturn;
var
  Text: string;
begin
  if ChatEdit.Text <> '' then
  begin
    Text := SetupEvents.DPlay.PlayerName + ': ' + ChatEdit.Text;
    SetupEvents.DPlay.SendChatMessage(0, Text);
    ChatMemo.Items.Add(Text); FChatScrollPending := True;
    ChatEdit.Text := '';
  end;
  ChatEdit.FRedraw := True;
end;

procedure TScenSetup.PlayerListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
var
  I: Integer;
begin
  if DrawItem < PlayerList.Items.Count then
  begin
    I := FSetupControl.FSettings.FRemotePlayers.IndexOfRemoteID(Integer(PlayerList.Items.Objects[DrawItem]));
    if I <> -1 then
      if FSetupControl.FSettings.FRemotePlayers.GetPlayers(I).FMapValidation = mviInvalid then
      begin
        FontModule.Age8s.Color := $FF;
        FontModule.Age8s.SetText(DrawRect.Right - 8, DrawRect.Top + 4, 'X', SD);
      end
      else if FSetupControl.FSettings.FRemotePlayers.GetPlayers(I).FMapValidation = mviInvalidMap then
      begin
        FontModule.Age8s.Color := $8000;
        FontModule.Age8s.SetText(DrawRect.Right - 8, DrawRect.Top + 4, 'X', SD);
      end;
  end;
end;

procedure TScenSetup.PingListDrawItem(Sender: TAoWComponent; const DrawRect: TRect; DrawItem: Integer; var SD: TSurfaceDesc);
var
  I: Integer;
  P: TGDPlayer;
  Text: string;
begin
  if DrawItem < PingList.Items.Count then
  begin
    I := SetupEvents.DPlay.GetPlayerIndex(Integer(PingList.Items.Objects[DrawItem]));
    if I <> -1 then
    begin
      P := TGDPlayer(SetupEvents.DPlay.PlayerItems[I]);
      if P.FID <> SetupEvents.DPlay.PlayerID then
      begin
        case Cardinal(P.FPing) of
          0..249: FontModule.Age8s.Color := $FF00;
          250..499: FontModule.Age8s.Color := $FF80;
          500..749: FontModule.Age8s.Color := $FFFF;
          750..999: FontModule.Age8s.Color := $80FF;
        else FontModule.Age8s.Color := $FF;
        end;
        if P.FPing <= 999 then Text := IntToStr(P.FPing) else Text := '999';
        FontModule.Age8s.SetTextCentered((DrawRect.Left + DrawRect.Right) div 2, DrawRect.Top + 4, Text, SD);
      end;
    end;
  end;
end;

procedure TScenSetup.ScenSetupPnlUpdate;
begin
  if SetupEvents.DPlay.Connected and ScenSetupPnl.Visible then
  begin
    Dec(FPingDelay);
    if FPingDelay < 1 then
    begin FPingDelay := 150; SetupEvents.DPlay.SendPingMessage(0); end;
    Dec(FValidateDelay);
    if FValidateDelay < 0 then
      if FSetupControl.FRemotePlayer.FMapValidation = mviInvalid then
      begin FSetupControl.ValidateMap; FValidateDelay := 100; end;
  end;
end;

procedure TScenSetup.PickScenarioBtnClick;
begin end;

procedure TScenSetup.PreferredRaceCBChange;
begin
  if PreferredRaceCB.Selected >= 0 then
    FSetupControl.SetPreferredRace(Byte(PreferredRaceCB.Items.Objects[PreferredRaceCB.Selected]));
end;

procedure TScenSetup.StartBtnClick;
begin
  General.PlayButtonSound(0);
  if FSetupControl.FSettings.FConnectionType = 2 then
    EmailGameSettingsDlg.Execute(FSetupControl)
  else EmailSettingsAccepted := True;
end;

procedure TScenSetup.EjectBtnClick;
begin
  General.PlayButtonSound(0);
  if PlayerList.Selected > -1 then
    FSetupControl.hEjectPlayer(Integer(PlayerList.Items.Objects[PlayerList.Selected]));
end;

procedure TScenSetup.MakeHostBtnClick;
begin
  General.PlayButtonSound(0);
  if PlayerList.Selected > -1 then
    FSetupControl.hSetHostRemoteID(Integer(PlayerList.Items.Objects[PlayerList.Selected]));
end;

procedure TScenSetup.PlayerListSBChange;
begin
  PlayerList.ListOffset := PlayerListSB.Position;
  PingList.ListOffset := PlayerListSB.Position;
  PreferredRaceList.ListOffset := PlayerListSB.Position;
end;

procedure TScenSetup.PlayerListChange(Sender: TObject);
begin
  SelectPlayer(TAOWListBox(Sender).Selected);
end;

procedure TScenSetup.TurnTimeSlChange;
begin
  FSetupControl.hSetTurnTimeLimitation(TurnTimeSl.Position); UpdateTurnTime;
end;

procedure TScenSetup.TurnsCBChange(Sender: TObject);
begin
  TurnsSlChange(Self);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TScenSetup.TurnsSlChange(Sender: TObject);
begin
  if TurnsSl.Position = 0 then FSetupControl.hSetTurnLimitation(TurnsSl.Position)
  else FSetupControl.hSetTurnLimitation(TurnsSl.Position * 10);
  UpdateTurnLimit;
end;

procedure TScenSetup.PlayModeCBChange;
begin
  FSetupControl.hSetPlayMode(Byte(PlayModeCB.Items.Objects[PlayModeCB.Selected]));
  E3Globals.TitleWindow.TitleWin.FDrawn := False;
end;

procedure TScenSetup.RacePlayerCBChange(Sender: TObject);
var
  Behavior: TSetupPlayerBehavior;
begin
  if FSetupControl.PlayerNameToPlayerID(TAOWComboBox(Sender).Items[TAOWComboBox(Sender).Selected], Behavior) then
    FSetupControl.hSetPlayerID(FSetupControl.FSettings.IndexOfRace(Byte(TComponent(Sender).Tag)), Behavior, True);
  E3Globals.TitleWindow.TitleWin.FDrawn := False;
end;

procedure TScenSetup.RaceBehaviorCBChange(Sender: TAOWComboBox);
begin
  FSetupControl.hSetPlayerBehavior(FSetupControl.FSettings.IndexOfRace(Byte(Sender.Tag)),
    Sender.Selected);
  E3Globals.TitleWindow.TitleWin.FDrawn := False;
end;

procedure TScenSetup.LeadersOnMapCBChange(Sender: TObject);
begin
  FSetupControl.hSetLeadersOnMap(LeadersOnMapCB.Checked);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TScenSetup.CustomizeLeadersChange(Sender: TObject);
begin
  FSetupControl.hSetCustomizeLeaders(CustomizeLeaders.Checked);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TScenSetup.AlliedVictoryCBChange(Sender: TObject);
begin
  FSetupControl.hSetAlliedVictory(AlliedVictoryCB.Checked);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TScenSetup.ExplorationChange(Sender: TObject);
begin
  FSetupControl.hSetExplorationEnabled(Exploration.Checked);
  if TAOWCheckBox(Sender).Checked then General.PlayButtonSound(1) else General.PlayButtonSound(2);
end;

procedure TScenSetup.AlwaysViewTCCBChange;
begin
  FSetupControl.hSetAlwaysViewTC(AlwaysViewTCCB.Checked);
end;

procedure TScenSetup.SettingsClick;
begin
  General.PlayButtonSound(0);
end;

procedure TScenSetup.RacePnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
begin
  IntGfxMod.Shields[Sender.Tag].Show(Sender.WinLeft + 5, Sender.WinTop + 5, SD);
end;

procedure TScenSetup.ChatSBUpdate;
begin
  if FChatScrollPending then
  begin
    ChatSB.Position := ChatSB.Max + 1 - ChatSB.NumberVisible;
    FChatScrollPending := False;
  end;
end;

procedure TScenSetup.TacticalCombatCBChange;
begin
  FSetupControl.hSetTacticalCombatAvailability(Byte(TacticalCombatCB.Items.Objects[TacticalCombatCB.Selected]));
end;


procedure TScenSetup.UpdateTurnTime;
begin
  if TurnTimeSl.Position = 0 then TurnTimeVal.Text := LowerCase(TranslateRStr(NoTimerRStr))
  else TurnTimeVal.Text := AoWE.Format(TranslateRStr(XMinutesRStr), [IntToStr(TurnTimeSl.Position)]);
end;

procedure TScenSetup.UpdateTurnLimit;
begin
  if TurnsSl.Position = 0 then TurnsVal.Text := LowerCase(TranslateRStr(NoLimitRStr))
  else TurnsVal.Text := AoWE.Format(LowerCase(TranslateRStr(XTurnsRStr)), [IntToStr(TurnsSl.Position * 10)]);
end;

procedure TScenSetup.SelectPlayer(Index: Integer);
begin
  if (Index >= 0) and (Index < PlayerList.Items.Count) then
  begin
    PlayerList.Selected := Index; PingList.Selected := Index; PreferredRaceList.Selected := Index;
    EjectBtn.Visible := FSetupControl.GetHost and
      (Integer(PlayerList.Items.Objects[PlayerList.Selected]) <> FSetupControl.FRemotePlayer.FRemoteID);
    MakeHostBtn.Visible := FSetupControl.CanSetHostRemoteID(Integer(PlayerList.Items.Objects[PlayerList.Selected]));
  end
  else
  begin
    PlayerList.Selected := -1; PingList.Selected := -1; PreferredRaceList.Selected := -1;
    EjectBtn.Visible := False; MakeHostBtn.Visible := False;
  end;
end;

end.
