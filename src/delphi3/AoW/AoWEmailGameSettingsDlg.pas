unit AoWEmailGameSettingsDlg;

{ Draft declarations of AoWEmailGameSettingsDlg, from AoW.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWSetup, AoWComp, AoWButton, AoWEdit, AoWFrame, AoWImage, AoWLabel, AoWPanel, AoWVScroll, AoWWindow;

type
  TEmailGameSettingsDlg = class;


  { TEmailGameSettingsDlg (instance size $E8, VMT 0040EFAC).
    $E0 editable email address list; $E4 setup control. }
  TEmailGameSettingsDlg = class(TDataModule)
  public
    published
    OKBtn: TAOWButton; { +0044 }
    TitleIcon: TAOWImage; { +0048 }
    Title: TAOWLabel; { +004C }
    CancelBut: TAOWButton; { +0050 }
    Dlg: TAOWWindow; { +0054 }
    LocalEmailAdressLbl: TAOWLabel; { +0058 }
    DecoL: TAOWImage; { +005C }
    DecoR: TAOWImage; { +0060 }
    AoWFrame1: TAoWFrame; { +0064 }
    LocalEmailAddressEdit: TAOWEdit; { +0068 }
    PlayerEMailAddressesLbl: TAOWLabel; { +006C }
    EmailAddressEdit1: TAOWEdit; { +0070 }
    PlayerPnl: TAOWPanel; { +0074 }
    PlayerLbl1: TAOWLabel; { +0078 }
    PlayerSB: TAOWVScrollBar; { +007C }
    PlayerLbl2: TAOWLabel; { +0080 }
    PlayerLbl3: TAOWLabel; { +0084 }
    EmailAddressEdit2: TAOWEdit; { +0088 }
    EmailAddressEdit3: TAOWEdit; { +008C }
    PlayerLbl4: TAOWLabel; { +0090 }
    EmailAddressEdit4: TAOWEdit; { +0094 }
    EmailGameNameLbl: TAOWLabel; { +0098 }
    EmailGameNameEdit: TAOWEdit; { +009C }
    SettingsBtn: TAOWButton; { +00A0 }
    Player1Pnl: TAOWPanel; { +00A4 }
    PowePnl: TAOWPanel; { +00A8 }
    Player2Pnl: TAOWPanel; { +00AC }
    Player3Pnl: TAOWPanel; { +00B0 }
    Player4Pnl: TAOWPanel; { +00B4 }
    PlayerLbl5: TAOWLabel; { +00B8 }
    EmailAddressEdit5: TAOWEdit; { +00BC }
    PlayerLbl6: TAOWLabel; { +00C0 }
    EmailAddressEdit6: TAOWEdit; { +00C4 }
    Player5Pnl: TAOWPanel; { +00C8 }
    Player6Pnl: TAOWPanel; { +00CC }
    NamePnl: TAOWPanel; { +00D0 }
    LocalPnl: TAOWPanel; { +00D4 }
    CloseBtn: TAOWButton; { +00D8 }
    Translator: TIvTranslator; { +00DC }
    public
    FEmailAddresses: TStringList; { $E0 }
    FSetupControl: TSetupControl; { $E4 }
    procedure EmailGameSettingsDlgCreate;
    procedure EmailGameSettingsDlgDestroy;
    procedure PlayerSBChange;
    procedure EmailAddressEdit1Change(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure CancelButClick;
    procedure SettingsBtnClick;
    procedure LocalEmailAddressEditUpdate;
    procedure Player6PnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
    procedure DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure UpdatePlayer(Index: Integer; NameLabel: TAOWLabel; EmailEdit: TAOWEdit);
    procedure UpdatePlayers;
    function SettingsComplete: Boolean;
    procedure ResetSettings;
    procedure Execute(Control: TSetupControl);
  end;


implementation

uses E3Globals, AoWExeForms, AoWUnit;

procedure TEmailGameSettingsDlg.EmailGameSettingsDlgCreate;
begin
  FEmailAddresses := TStringList.Create;
end;

procedure TEmailGameSettingsDlg.EmailGameSettingsDlgDestroy;
begin
  FEmailAddresses.Free;
end;

procedure TEmailGameSettingsDlg.PlayerSBChange;
begin
  UpdatePlayers;
end;

procedure TEmailGameSettingsDlg.EmailAddressEdit1Change(Sender: TObject);
var
  I: Integer;
begin
  I := TComponent(Sender).Tag + PlayerSB.Position;
  if I < FEmailAddresses.Count then FEmailAddresses[I] := TAOWEdit(Sender).Text;
end;

procedure TEmailGameSettingsDlg.OKBtnClick(Sender: TObject);
var
  I, Index: Integer;
begin
  if SettingsComplete then
  begin
    if FSetupControl <> nil then
    begin
    for I := 0 to FEmailAddresses.Count - 1 do
    begin
      Index := FSetupControl.FSettings.IndexOfRace(Integer(FEmailAddresses.Objects[I]));
      FSetupControl.FSettings.GetSettings(Index).FEmailAddress := FEmailAddresses[I];
    end;
    FSetupControl.FSettings.FEmailGameName := EmailGameNameEdit.Text;
    AoWUnit.DeferredSetupAction := 1;
    Dlg.Visible := False;
    end;
  end
  else
  begin
    ResetMessageDialog(AoWExeForms.MessageDlg);
    AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
    AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(PleaseFillInAllSettingsRStr));
    AoWExeForms.MessageDlg.OKPnl.Visible := True;
    AoWExeForms.MessageDlg.Dlg.Visible := True;
  end;
end;

procedure TEmailGameSettingsDlg.CancelButClick;
begin
  Dlg.Visible := False;
end;

procedure TEmailGameSettingsDlg.SettingsBtnClick;
begin
  ShowEmailSettings(EmailSettingsDlg);
end;

procedure TEmailGameSettingsDlg.LocalEmailAddressEditUpdate;
begin
  if AoWEngine.FRegistry.GetLocalEmailAddress <> LocalEmailAddressEdit.Text then
    LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
end;

procedure TEmailGameSettingsDlg.Player6PnlDrawBack(Sender: TAoWComponent; SD: TSurfaceDesc);
var
  R: TRaceResource;
  I: Integer;
begin with TAOWPanel(Sender) do begin
  I := Tag + PlayerSB.Position;
  if I < FEmailAddresses.Count then
  begin
    R := AoWHSSet.FRaceResources.GetRaceResource(Integer(FEmailAddresses.Objects[I]));
    R.AddRef;
    R.FImageLibrary[38].Show(WinLeft, WinTop, SD);
    R.Release;
  end;
end; end;

procedure TEmailGameSettingsDlg.DlgKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_ESCAPE then Dlg.Visible := False;
end;


procedure TEmailGameSettingsDlg.UpdatePlayer(Index: Integer; NameLabel: TAOWLabel; EmailEdit: TAOWEdit);
begin
  if Index < FEmailAddresses.Count then
  begin
    EmailEdit.CaptureInput := True;
    EmailEdit.Text := FEmailAddresses[Index];
    NameLabel.Text := TranslateRStr(RaceNamesPluralRStr[Integer(FEmailAddresses.Objects[Index])]);
  end
  else
  begin
    EmailEdit.CaptureInput := False; EmailEdit.Text := ''; NameLabel.Text := '';
  end;
end;

procedure TEmailGameSettingsDlg.UpdatePlayers;
begin
  PlayerSB.Min := 0; PlayerSB.Max := FEmailAddresses.Count - 1; PlayerSB.NumberVisible := 6;
  PlayerPnl.FDrawn := False;
  UpdatePlayer(PlayerSB.Position, PlayerLbl1, EmailAddressEdit1);
  UpdatePlayer(PlayerSB.Position + 1, PlayerLbl2, EmailAddressEdit2);
  UpdatePlayer(PlayerSB.Position + 2, PlayerLbl3, EmailAddressEdit3);
  UpdatePlayer(PlayerSB.Position + 3, PlayerLbl4, EmailAddressEdit4);
  UpdatePlayer(PlayerSB.Position + 4, PlayerLbl5, EmailAddressEdit5);
  UpdatePlayer(PlayerSB.Position + 5, PlayerLbl6, EmailAddressEdit6);
end;

function TEmailGameSettingsDlg.SettingsComplete: Boolean;
var
  I: Integer;
begin
  I := FEmailAddresses.Count;
  Result := (LocalEmailAddressEdit.Text <> '') and (EmailGameNameEdit.Text <> '');
  while Result and (I <> 0) do
  begin
    Dec(I); Result := FEmailAddresses[I] <> '';
  end;
end;

procedure TEmailGameSettingsDlg.ResetSettings;
begin
  FSetupControl := nil;
  FEmailAddresses.Clear;
  PlayerSB.Visible := True;
  PlayerSB.Position := 0;
  LocalEmailAddressEdit.Text := AoWEngine.FRegistry.GetLocalEmailAddress;
end;

procedure TEmailGameSettingsDlg.Execute(Control: TSetupControl);
var
  I: Integer;
  C: TSetupControl;
begin
  ResetSettings;
  FSetupControl := TSetupControl(Control); C := FSetupControl;
  for I := 0 to C.FSettings.Count - 1 do
    if C.FSettings.GetSettings(I).FBehavior.PlayerType = 0 then
      FEmailAddresses.AddObject(AoWEngine.FRegistry.GetLocalEmailAddress, TObject(Shortint(C.FSettings.GetSettings(I).FRace)));
  if FEmailAddresses.Count > 1 then
  begin
    UpdatePlayers;
    Dlg.Visible := True;
  end
  else
  begin
    ResetMessageDialog(AoWExeForms.MessageDlg);
    AoWExeForms.MessageDlg.MessageMemo.Items.Add('');
    AoWExeForms.MessageDlg.MessageMemo.Items.Add(TranslateRStr(YouNeed2HumanPlayersToPlayAnEmailGameRStr));
    AoWExeForms.MessageDlg.OKPnl.Visible := True;
    AoWExeForms.MessageDlg.Dlg.Visible := True;
  end;
end;

end.
