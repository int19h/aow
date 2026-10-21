unit AoWGamePlayDlg;

{ Draft declarations of AoWGamePlayDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWReg, EventLog, AoWButton, AoWCheckBox, AoWComboBox, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWTabPanel, AoWVScroll, AoWWindow;

type
  TGamePlayDlg = class;


  { TGamePlayDlg (size $134, VMT 0042200C): $130 pending password. }
  TGamePlayDlg = class(TDataModule)
  public
    published
    GamePlayDlg: TAOWWindow; { +0044 }
    CancelBtn: TAOWButton; { +0048 }
    BCeltL: TAoWFrame; { +004C }
    Title: TAOWLabel; { +0050 }
    Close: TAOWButton; { +0054 }
    TCeltLR: TAOWImage; { +0058 }
    TCeltLL: TAOWImage; { +005C }
    TitleIcon: TAOWImage; { +0060 }
    AutoSaveCB: TAOWCheckBox; { +0064 }
    asLbl: TAOWLabel; { +0068 }
    SkipIntroCB: TAOWCheckBox; { +006C }
    siLbl: TAOWLabel; { +0070 }
    Tab1: TAOWTabPanel; { +0074 }
    Pnl1: TAOWPanel; { +0078 }
    Pnl2: TAOWPanel; { +007C }
    GamePasswordLbl: TAOWLabel; { +0080 }
    PasswordEdit: TAOWEdit; { +0084 }
    CombatResolveModeCB: TAOWComboBox; { +0088 }
    CombatResolveModeSB: TAOWVScrollBar; { +008C }
    Classic1CB: TAOWCheckBox; { +0090 }
    PopupLbl1: TAOWLabel; { +0094 }
    Classic2CB: TAOWCheckBox; { +0098 }
    PopupLbl2: TAOWLabel; { +009C }
    Classic3CB: TAOWCheckBox; { +00A0 }
    PopupLbl3: TAOWLabel; { +00A4 }
    Classic4CB: TAOWCheckBox; { +00A8 }
    Classic5CB: TAOWCheckBox; { +00AC }
    Classic6CB: TAOWCheckBox; { +00B0 }
    WindowPopupLbl: TAOWLabel; { +00B4 }
    ClassicLbl: TAOWLabel; { +00B8 }
    SimultaneousLbl: TAOWLabel; { +00BC }
    Sim1CB: TAOWCheckBox; { +00C0 }
    Sim2CB: TAOWCheckBox; { +00C4 }
    Sim3CB: TAOWCheckBox; { +00C8 }
    Sim4CB: TAOWCheckBox; { +00CC }
    Sim5CB: TAOWCheckBox; { +00D0 }
    Sim6CB: TAOWCheckBox; { +00D4 }
    PopupLbl4: TAOWLabel; { +00D8 }
    PopupLbl5: TAOWLabel; { +00DC }
    PopupLbl6: TAOWLabel; { +00E0 }
    Classic7CB: TAOWCheckBox; { +00E4 }
    Sim7CB: TAOWCheckBox; { +00E8 }
    PopupLbl7: TAOWLabel; { +00EC }
    ChangePasswordBtn: TAOWButton; { +00F0 }
    MovementSpeedCB: TAOWComboBox; { +00F4 }
    OKBtn: TAOWButton; { +00F8 }
    Classic8CB: TAOWCheckBox; { +00FC }
    Sim8CB: TAOWCheckBox; { +0100 }
    PopupLbl8: TAOWLabel; { +0104 }
    CombLbl: TAOWLabel; { +0108 }
    CombFr: TAOWPanel; { +010C }
    CombPnl: TAOWPanel; { +0110 }
    Movelbl: TAOWLabel; { +0114 }
    MovFr: TAOWPanel; { +0118 }
    BtmPnl: TAOWPanel; { +011C }
    MovPnl: TAOWPanel; { +0120 }
    AOWPanel1: TAOWPanel; { +0124 }
    CeltLineL: TAOWImage; { +0128 }
    Translator: TIvTranslator; { +012C }
    public
    FNewPassword: string; { $130 }
    procedure PasswordEntered(Log: TEventLog);
    procedure PasswordConfirmed(Log: TEventLog);
    procedure GamePlayDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure GamePlayDlgShow(Sender: TObject);
    procedure ChangePasswordBtnClick;
    procedure OKBtnClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
  end;


implementation

uses AoWWinMan, AoWExeForms;

procedure TGamePlayDlg.GamePlayDlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  case Key of 27: CancelClick(Self); end;
end;

procedure TGamePlayDlg.GamePlayDlgShow(Sender: TObject);
var
  Mode: TCombatResolveMode;
  Events: TWindowPopupEvents;
begin
  AutoSaveCB.Checked := AoWEngine.FRegistry.GetAutoSave;
  SkipIntroCB.Checked := AoWEngine.FRegistry.GetSkipIntro;
  MovementSpeedCB.Selected := Ord(AoWEngine.FRegistry.GetMovementSpeed);
  CombatResolveModeCB.Items.Clear;
  for Mode := Low(TCombatResolveMode) to High(TCombatResolveMode) do
    CombatResolveModeCB.Items.AddObject(TranslateRStr(TCombatResolveModeRStr[Mode]), TObject(Mode));
  CombatResolveModeCB.Selected := CombatResolveModeCB.Items.IndexOfObject(TObject(AoWEngine.FRegistry.GetCombatResolveMode));
  Events := AoWEngine.FRegistry.GetClassicWindowPopupEvents;
  Classic1CB.Checked := wpCombat in Events;
  Classic2CB.Checked := wpDiplomacy in Events;
  Classic3CB.Checked := wpSpellResearched in Events;
  Classic4CB.Checked := wpSpellReady in Events;
  Classic5CB.Checked := wpRebellion in Events;
  Classic6CB.Checked := wpPartyDamage in Events;
  Classic7CB.Checked := wpHeroUpgrade in Events;
  Classic8CB.Checked := wpHeroJoin in Events;
  Events := AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents;
  Sim1CB.Checked := wpCombat in Events;
  Sim2CB.Checked := wpDiplomacy in Events;
  Sim3CB.Checked := wpSpellResearched in Events;
  Sim4CB.Checked := wpSpellReady in Events;
  Sim5CB.Checked := wpRebellion in Events;
  Sim6CB.Checked := wpPartyDamage in Events;
  Sim7CB.Checked := wpHeroUpgrade in Events;
  Sim8CB.Checked := wpHeroJoin in Events;
  PasswordEdit.Text := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSettings;
end;

procedure TGamePlayDlg.ChangePasswordBtnClick;
var
  Log: TPasswordEventLog;
begin
  if (AoWHSMap.FPlayMode <> pmTurn) or (AoWHSMap.FConnectionType <> pcNetwork) or
    (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    Log := TPasswordEventLog.Create(nil);
    Log.FPrompt := TranslateRStr(EnterNewPasswordRStr);
    AoWHSMap.TriggerExecuteEventLog(Log, True, PasswordEntered);
    Log.Release;
  end;
end;

procedure TGamePlayDlg.OKBtnClick(Sender: TObject);
var
  Error: string;
  Events: TWindowPopupEvents;
begin
  General.PlayButtonSound(0);
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSettings <> PasswordEdit.Text then
    if AoWHSMap.FConnectionType <> pcNetwork then
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSettings := PasswordEdit.Text
    else
    begin
      if not AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).ChangePlayerSettings(PasswordEdit.Text, Error) then
      begin
        ResetMessageDialog(AoWExeForms.MessageDlg);
        AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
        AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(CouldntChangePasswordRStr));
        AoWExeForms.MessageDlg.OKPnl.Visible := True;
        AoWExeForms.MessageDlg.Dlg.Visible := True;
      end;
    end;
  AoWEngine.FRegistry.SetAutoSave(AutoSaveCB.Checked);
  AoWEngine.FRegistry.SetSkipIntro(SkipIntroCB.Checked);
  AoWEngine.FRegistry.SetMovementSpeed(TMovementSpeed(MovementSpeedCB.Selected));
  AoWEngine.FRegistry.SetCombatResolveMode(TCombatResolveMode(CombatResolveModeCB.Items.Objects[CombatResolveModeCB.Selected]));
  Events := [];
  if Classic1CB.Checked then Events := Events + [wpCombat];
  if Classic2CB.Checked then Events := Events + [wpDiplomacy];
  if Classic3CB.Checked then Events := Events + [wpSpellResearched];
  if Classic4CB.Checked then Events := Events + [wpSpellReady];
  if Classic5CB.Checked then Events := Events + [wpRebellion];
  if Classic6CB.Checked then Events := Events + [wpPartyDamage];
  if Classic7CB.Checked then Events := Events + [wpHeroUpgrade];
  if Classic8CB.Checked then Events := Events + [wpHeroJoin];
  AoWEngine.FRegistry.SetClassicWindowPopupEvents(Events);
  Events := [];
  if Sim1CB.Checked then Events := Events + [wpCombat];
  if Sim2CB.Checked then Events := Events + [wpDiplomacy];
  if Sim3CB.Checked then Events := Events + [wpSpellResearched];
  if Sim4CB.Checked then Events := Events + [wpSpellReady];
  if Sim5CB.Checked then Events := Events + [wpRebellion];
  if Sim6CB.Checked then Events := Events + [wpPartyDamage];
  if Sim7CB.Checked then Events := Events + [wpHeroUpgrade];
  if Sim8CB.Checked then Events := Events + [wpHeroJoin];
  AoWEngine.FRegistry.SetSimultaneousWindowPopupEvents(Events);
  GamePlayDlg.Visible := False;
end;

procedure TGamePlayDlg.CancelClick(Sender: TObject);
begin
  General.PlayButtonSound(0);
  GamePlayDlg.Visible := False;
end;

procedure TGamePlayDlg.PasswordEntered(Log: TEventLog);
var
  Password: TPasswordEventLog;
begin
  if TPasswordEventLog(Log).FPressedButton = pebOk then
    if TPasswordEventLog(Log).FPassword = '' then PasswordEdit.Text := ''
    else
    begin
      FNewPassword := TPasswordEventLog(Log).FPassword;
      Password := TPasswordEventLog.Create(nil);
      Password.FTitle := TranslateRStr(PasswordConfirmationRStr);
      Password.FPrompt := TranslateRStr(ReenterNewPasswordRStr);
      AoWHSMap.TriggerExecuteEventLog(Password, True, PasswordConfirmed);
      Password.Release;
    end;
end;

procedure TGamePlayDlg.PasswordConfirmed(Log: TEventLog);
begin
  if TPasswordEventLog(Log).FPassword = FNewPassword then PasswordEdit.Text := Encode(FNewPassword, 0)
  else
  begin
    ResetMessageDialog(AoWExeForms.MessageDlg);
    AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
    AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(ConfirmationFailedRStr));
    AoWExeForms.MessageDlg.OKPnl.Visible := True;
    AoWExeForms.MessageDlg.Dlg.Visible := True;
  end;
end;

end.
