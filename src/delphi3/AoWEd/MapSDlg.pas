unit MapSDlg;

{ Map settings editor recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RaceBox, SpinEdit, checklst, AoWE, PasswordDialog;

type
  TMapSettingsDlg = class;


  { TMapSettingsDlg: size $300; $2F4 players, $2F8 races, $2FC available songs.
    VMT 004220D8. }
  TMapSettingsDlg = class(TForm)
  public
    published
    ClientPnl: TPanel; { +01DC }
    MainPageControl: TPageControl; { +01E0 }
    GeneralSheet: TTabSheet; { +01E4 }
    MapNameLbl: TLabel; { +01E8 }
    Label5: TLabel; { +01EC }
    MapnameEdit: TEdit; { +01F0 }
    PasswordEdit: TEdit; { +01F4 }
    SettingsSheet: TTabSheet; { +01F8 }
    GroupBox3: TGroupBox; { +01FC }
    RaceListCheckBox: TCheckListBox; { +0200 }
    PlayersSheet: TTabSheet; { +0204 }
    BottomPnl: TPanel; { +0208 }
    Button1: TButton; { +020C }
    CancelBtn: TButton; { +0210 }
    MapIntroductionMemo: TMemo; { +0214 }
    MapDescriptionLbl: TLabel; { +0218 }
    Bevel1: TBevel; { +021C }
    Label7: TLabel; { +0220 }
    PlayListBox: TListBox; { +0224 }
    AvailableSongsBox: TListBox; { +0228 }
    Label4: TLabel; { +022C }
    AddSong: TButton; { +0230 }
    DeleteSong: TButton; { +0234 }
    MapSongsLbl: TLabel; { +0238 }
    IndependantAIGroup: TRadioGroup; { +023C }
    RestrictionsBox: TGroupBox; { +0240 }
    Label6: TLabel; { +0244 }
    NumberOfHeroesEdit: TSpin; { +0248 }
    MaxSpherePicksEdit: TSpin; { +024C }
    MaxSpellLevelLabel: TLabel; { +0250 }
    Label2: TLabel; { +0254 }
    NumberOfPlayersEdit: TSpin; { +0258 }
    Label1: TLabel; { +025C }
    PlayerCB: TComboBox; { +0260 }
    Bevel3: TBevel; { +0264 }
    PlayerPnl: TPanel; { +0268 }
    Label15: TLabel; { +026C }
    PlayerRaceBox: TRaceBox; { +0270 }
    PlayerTypeBox: TComboBox; { +0274 }
    Label16: TLabel; { +0278 }
    PlayerFixed: TCheckBox; { +027C }
    Label18: TLabel; { +0280 }
    StartGoldEdit: TSpin; { +0284 }
    ExternalGoldIncomeEdit: TSpin; { +0288 }
    Label17: TLabel; { +028C }
    StartManaLbl: TLabel; { +0290 }
    ExternalManaIncome: TLabel; { +0294 }
    Bevel2: TBevel; { +0298 }
    ObjectiveDescriptionLbl: TLabel; { +029C }
    ObjectiveMemo: TMemo; { +02A0 }
    StartManaEdit: TSpin; { +02A4 }
    ExternalPowerIncomeEdit: TSpin; { +02A8 }
    BehaviorLbl: TLabel; { +02AC }
    BehaviorCB: TComboBox; { +02B0 }
    Bevel4: TBevel; { +02B4 }
    DiplomacySheet: TTabSheet; { +02B8 }
    RelationGrid: TDrawGrid; { +02BC }
    DiplomaticIcons: TImageList; { +02C0 }
    ChangePasswordBtn: TButton; { +02C4 }
    ObjectiveBox: TGroupBox; { +02C8 }
    ObjectivePnl: TPanel; { +02CC }
    AccumulateGoldRB: TRadioButton; { +02D0 }
    CaptureLocationsRB: TRadioButton; { +02D4 }
    NoneRB: TRadioButton; { +02D8 }
    AmountLbl: TLabel; { +02DC }
    AccumulateManaRB: TRadioButton; { +02E0 }
    Label3: TLabel; { +02E4 }
    AccumulateManaEdit: TSpin; { +02E8 }
    AccumulateGoldEdit: TSpin; { +02EC }
    Translator: TIvTranslator; { +02F0 }
    public
    FPlayers: TPlayerList; { $2F4 }
    FRaces: TRaceList; { $2F8 }
    FSongs: TSonglist; { $2FC }
    published procedure FormCreate(Sender: TObject); public
    published procedure FormDestroy(Sender: TObject); public
    published procedure RaceListCheckBoxClickCheck(Sender: TObject); public
    published procedure PlayerCBChange(Sender: TObject); public
    published procedure ObjectiveMemoChange(Sender: TObject); public
    published procedure ExternalGoldIncomeEditChange(Sender: TObject); public
    published procedure StartGoldEditChange(Sender: TObject); public
    published procedure PlayerFixedClick(Sender: TObject); public
    published procedure PlayerRaceBoxChange(Sender: TObject); public
    published procedure PlayerTypeBoxChange(Sender: TObject); public
    published procedure BehaviorCBChange(Sender: TObject); public
    published procedure StartManaEditChange(Sender: TObject); public
    published procedure ExternalPowerIncomeEditChange(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
    published procedure AddSongClick(Sender: TObject); public
    published procedure DeleteSongClick(Sender: TObject); public
    published procedure ObjectiveBoxooClick(Sender: TObject); public
    published procedure NumberOfPlayersEditChange(Sender: TObject); public
    published procedure RelationGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean); public
    published procedure RelationGridDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState); public
    published procedure RelationGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer); public
    published procedure ChangePasswordBtnClick(Sender: TObject); public
    published procedure VictoryConditionClick(Sender: TObject); public
    published procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean); public
    procedure LoadSettings;
    procedure SaveSettings;
    procedure UpdateRaceList;
    procedure UpdatePlayerList;
    procedure UpdateVictoryCondition;
    procedure UpdateRelationHint(X, Y: Integer);
  end;


implementation

procedure TMapSettingsDlg.LoadSettings;
begin
  if AoWHSMap <> nil then
  begin
    FRaces.Assign(AoWHSMap.FRaces, AoWEngine);
    PlayListBox.Items.Assign(AoWHSMap.FStartupSongs.SongNames);
    FPlayers.Assign(AoWHSMap.FPlayers, AoWEngine);
    NumberOfPlayersEdit.Value := AoWHSMap.FPlayers.GetNumberOfPlayers;
    PlayerTypeBox.Items.Clear;
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptHuman)]), TObject(Ord(ptHuman)));
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptCPU1)]), TObject(Ord(ptCPU1)));
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptCPU2)]), TObject(Ord(ptCPU2)));
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptCPU3)]), TObject(Ord(ptCPU3)));
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptCPU4)]), TObject(Ord(ptCPU4)));
    PlayerTypeBox.Items.AddObject(TranslateRStr(TPlayerTypeRStr[Ord(ptCPU5)]), TObject(Ord(ptCPU5)));
    UpdatePlayerList;
    MapnameEdit.Text := AoWHSMap.FMapName;
    PasswordEdit.Text := Encode(AoWHSMap.FAuthor, 0);
    MapIntroductionMemo.Lines.Text := AoWHSMap.FDescription.Text;
    NumberOfHeroesEdit.Value := AoWHSMap.FHeroCountMax;
    MaxSpherePicksEdit.Value := AoWHSMap.FSphereCount;
    IndependantAIGroup.ItemIndex := Ord(AoWHSMap.GetIndependentAIMode);
    case AoWHSMap.FVictoryCondition of
      vcNone: NoneRB.Checked := True;
      vcCaptureLocations: CaptureLocationsRB.Checked := True;
      vcAccumulateGold: AccumulateGoldRB.Checked := True;
      vcAccumulateMana: AccumulateManaRB.Checked := True;
    end;
    AccumulateGoldEdit.Value := AoWHSMap.FVictoryGold;
    AccumulateManaEdit.Value := AoWHSMap.FVictoryMana;
  end;
end;

procedure TMapSettingsDlg.SaveSettings;
var I, Index: Integer; Songs: TStringList;
begin
  Songs := AoWHSMap.FStartupSongs.Songs;
  Songs.BeginUpdate;
  Songs.Clear;
  for I := 0 to PlayListBox.Items.Count - 1 do
  begin
    Index := FSongs.SongNames.IndexOf(PlayListBox.Items[I]);
    Songs.Add(FSongs.Songs[Index]);
  end;
  Songs.EndUpdate;
  AoWHSMap.FGameSongs.Songs.Clear;
  AoWHSMap.FPlayers.Assign(FPlayers, AoWEngine);
  AoWHSMap.FRaces.Assign(FRaces, AoWEngine);
  AoWHSMap.FMapName := MapnameEdit.Text;
  AoWHSMap.FAuthor := Encode(PasswordEdit.Text, 0);
  AoWHSMap.FDescription.Text := MapIntroductionMemo.Lines.Text;
  AoWHSMap.FHeroCountMax := NumberOfHeroesEdit.Value;
  AoWHSMap.FSphereCount := MaxSpherePicksEdit.Value;
  AoWHSMap.FIndependentAIMode := TIndependentAIMode(IndependantAIGroup.ItemIndex);
  if NoneRB.Checked then AoWHSMap.FVictoryCondition := vcNone
  else if CaptureLocationsRB.Checked then AoWHSMap.FVictoryCondition := vcCaptureLocations
  else if AccumulateGoldRB.Checked then AoWHSMap.FVictoryCondition := vcAccumulateGold
  else if AccumulateManaRB.Checked then AoWHSMap.FVictoryCondition := vcAccumulateMana;
  AoWHSMap.FVictoryGold := AccumulateGoldEdit.Value;
  AoWHSMap.FVictoryMana := AccumulateManaEdit.Value;
end;

procedure TMapSettingsDlg.UpdateRaceList;
var I: Integer;
begin
  RaceListCheckBox.Items.Clear;
  for I := 0 to FRaces.Count - 1 do
    if FRaces.GetRace(I) <> nil then
    begin
      RaceListCheckBox.Items.AddObject(AoWHSSet.FRaceResources.GetRaceResource(I).FName, TObject(I));
      RaceListCheckBox.Checked[RaceListCheckBox.Items.Count - 1] := FRaces.GetRace(I).FEnabled;
    end;
end;

procedure TMapSettingsDlg.FormCreate(Sender: TObject);
var SongList: TSonglist; Behavior: TPlayerBehavior;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling, identity assignments; still differs. }
  SongList := TSonglist.Create(nil);
  with SongList do
  begin
    Self.FSongs := SongList;
    Search('SONGS\', 'S3M');
  end;
  FSongs.Search('SONGS\', 'IT');
  AvailableSongsBox.Items.Assign(FSongs.SongNames);
  FPlayers := TPlayerList.Create(nil);
  FRaces := TRaceList.Create(nil);
  BehaviorCB.Items.Clear;
  for Behavior := Low(TPlayerBehavior) to High(TPlayerBehavior) do
    BehaviorCB.Items.Add(TranslateRStr(TPlayerBehaviorRStr[Behavior]));
  MainPageControl.ActivePage := GeneralSheet;
  LoadSettings;
  FPlayers.SetNumberOfPlayers(NumberOfPlayersEdit.Value);
  UpdateRaceList;
end;

procedure TMapSettingsDlg.FormDestroy(Sender: TObject);
begin
  FSongs.Free;
  FPlayers.Free;
  FRaces.Free;
end;

procedure TMapSettingsDlg.RaceListCheckBoxClickCheck(Sender: TObject);
var Race: Integer;
begin
  with RaceListCheckBox do
  begin
    Race := Integer(Items.Objects[ItemIndex]);
    FRaces.GetRace(Race).SetEnabled(Checked[ItemIndex]);
  end;
  FPlayers.ValidateRaces(FRaces);
  UpdatePlayerList;
end;

procedure TMapSettingsDlg.PlayerCBChange(Sender: TObject);
var Player: TPlayer;
begin
  Player := FPlayers.GetPlayers(PlayerCB.ItemIndex + 1);
  PlayerRaceBox.SetRace(Player.FPlayerRace);
  PlayerTypeBox.ItemIndex := PlayerTypeBox.Items.IndexOfObject(TObject(Player.FPlayerType));
  StartGoldEdit.Value := Player.FInitialGold;
  ExternalGoldIncomeEdit.Value := Player.FBaseIncome;
  StartManaEdit.Value := Player.FMagicControl.FExternalMana;
  ExternalPowerIncomeEdit.Value := Player.FMagicControl.FExternalPower;
  PlayerFixed.Checked := Player.FParticipating;
  BehaviorCB.ItemIndex := Ord(Player.FBehavior);
  ObjectiveMemo.Text := Player.FMessages.Text;
end;

procedure TMapSettingsDlg.UpdatePlayerList;
var Index, I: Integer;
begin
  Index := PlayerCB.ItemIndex;
  PlayerCB.Items.Clear;
  for I := 1 to NumberOfPlayersEdit.Value do
    PlayerCB.Items.Add(TranslateRStr(PlayerRStr) + ' ' + IntToStr(I) + ' (' +
      TranslateRStr(RaceNamesRStr[FPlayers.GetPlayers(I).FPlayerRace]) + ')');
  PlayerCB.ItemIndex := Index;
  if PlayerCB.ItemIndex = -1 then PlayerCB.ItemIndex := 0;
  PlayerRaceBox.SetRaces(FRaces);
  PlayerCBChange(Self);
end;

procedure TMapSettingsDlg.ObjectiveMemoChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FMessages.Text := ObjectiveMemo.Lines.Text;
end;

procedure TMapSettingsDlg.ExternalGoldIncomeEditChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FBaseIncome := ExternalGoldIncomeEdit.Value;
end;

procedure TMapSettingsDlg.StartGoldEditChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FInitialGold := StartGoldEdit.Value;
end;

procedure TMapSettingsDlg.PlayerFixedClick(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FParticipating := PlayerFixed.Checked;
end;

procedure TMapSettingsDlg.PlayerRaceBoxChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).SetRace(PlayerRaceBox.FRace);
  UpdatePlayerList;
end;

procedure TMapSettingsDlg.PlayerTypeBoxChange(Sender: TObject);
begin
  with PlayerTypeBox do
    FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FPlayerType := TPlayerType(Items.Objects[ItemIndex]);
end;

procedure TMapSettingsDlg.BehaviorCBChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FBehavior := TPlayerBehavior(BehaviorCB.ItemIndex);
end;

procedure TMapSettingsDlg.StartManaEditChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FMagicControl.FExternalMana := StartManaEdit.Value;
end;

procedure TMapSettingsDlg.ExternalPowerIncomeEditChange(Sender: TObject);
begin
  FPlayers.GetPlayers(PlayerCB.ItemIndex + 1).FMagicControl.FExternalPower := ExternalPowerIncomeEdit.Value;
end;

procedure TMapSettingsDlg.OKBtnClick(Sender: TObject);
var Valid: Boolean; Msg: TEMsg;
begin
  Valid := FPlayers.VerifyRaces(FRaces) = 0;
  if not Valid then MessageDlg(UniqueRacesRStr, mtWarning, [mbOK], 0);
  if Valid then
  begin
    Hide;
    SaveSettings;
    AoWHSMap.SetModified;
    InitMsg(Msg, $20020005, AoWEngine);
    AoWHSMap.MsgProc(Msg, AoWEngine);
    ModalResult := mrOK;
  end;
end;

procedure TMapSettingsDlg.UpdateVictoryCondition;
begin
  if AccumulateGoldRB.Checked then
  begin
    AccumulateGoldEdit.Color := clWindow;
    AccumulateGoldEdit.Enabled := True;
  end
  else
  begin
    AccumulateGoldEdit.Color := clBtnFace;
    AccumulateGoldEdit.Enabled := False;
  end;
  if AccumulateManaRB.Checked then
  begin
    AccumulateManaEdit.Color := clWindow;
    AccumulateManaEdit.Enabled := True;
  end
  else
  begin
    AccumulateManaEdit.Color := clBtnFace;
    AccumulateManaEdit.Enabled := False;
  end;
end;

procedure TMapSettingsDlg.AddSongClick(Sender: TObject);
begin
  with AvailableSongsBox do
    if ItemIndex <> -1 then PlayListBox.Items.Add(Items[ItemIndex]);
end;

procedure TMapSettingsDlg.DeleteSongClick(Sender: TObject);
begin
  with PlayListBox do
    if ItemIndex <> -1 then Self.PlayListBox.Items.Delete(ItemIndex);
end;

procedure TMapSettingsDlg.ObjectiveBoxooClick(Sender: TObject);
begin
end;

procedure TMapSettingsDlg.NumberOfPlayersEditChange(Sender: TObject);
begin
  FPlayers.SetNumberOfPlayers(NumberOfPlayersEdit.Value);
  FPlayers.ValidateRaces(FRaces);
  UpdatePlayerList;
end;

procedure TMapSettingsDlg.RelationGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  if (ACol <> 0) and (ARow <> 0) and (ACol < FPlayers.Count) and (ARow < FPlayers.Count) then
  begin
    case FPlayers.GetDiplomaticRelation(ARow, ACol) of
      drPeace: FPlayers.SetDiplomaticRelation(ARow, ACol, drWar);
      drWar: FPlayers.SetDiplomaticRelation(ARow, ACol, drAlliance);
      drAlliance: FPlayers.SetDiplomaticRelation(ARow, ACol, drUnknown);
      drUnknown: FPlayers.SetDiplomaticRelation(ARow, ACol, drPeace);
    end;
    RelationGrid.Invalidate;
  end;
end;

procedure TMapSettingsDlg.RelationGridDrawCell(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
begin
  with RelationGrid do
    if ACol = 0 then
    begin
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOM);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOP);
      if (ARow > 0) and (ARow < FPlayers.Count) then
        DiplomaticIcons.Draw(Canvas, R.Left, R.Top, FPlayers.GetPlayers(ARow).FPlayerRace + 4);
    end
    else if ARow = 0 then
    begin
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_BOTTOM);
      DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_TOP);
      if (ACol > 0) and (ACol < FPlayers.Count) then
        DiplomaticIcons.Draw(Canvas, R.Left, R.Top, FPlayers.GetPlayers(ACol).FPlayerRace + 4);
    end
    else if ACol = ARow then DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_RECT)
    else if (ACol < FPlayers.Count) and (ARow < FPlayers.Count) then
      DiplomaticIcons.Draw(Canvas, R.Left, R.Top, Ord(FPlayers.GetDiplomaticRelation(ARow, ACol)))
    else DrawEdge(Canvas.Handle, R, BDR_RAISEDINNER, BF_RECT);
end;

procedure TMapSettingsDlg.UpdateRelationHint(X, Y: Integer);
var Coord: TGridCoord;
begin
  RelationGrid.Hint := '';
  Coord := RelationGrid.MouseCoord(X, Y);
  if Coord.X = 0 then
  begin
    if (Coord.Y > 0) and (Coord.Y < FPlayers.Count) then
      RelationGrid.Hint := TranslateRStr(RaceNamesRStr[FPlayers.GetPlayers(Coord.Y).FPlayerRace]);
  end
  else if Coord.Y = 0 then
  begin
    if (Coord.X > 0) and (Coord.X < FPlayers.Count) then
      RelationGrid.Hint := TranslateRStr(RaceNamesRStr[FPlayers.GetPlayers(Coord.X).FPlayerRace]);
  end
  else if (Coord.X < FPlayers.Count) and (Coord.Y < FPlayers.Count) and (Coord.X <> Coord.Y) then
    RelationGrid.Hint := TranslateRStr(RaceNamesRStr[FPlayers.GetPlayers(Coord.Y).FPlayerRace]) + ' ' +
      TranslateRStr(VersusRStr) + ' ' + TranslateRStr(RaceNamesRStr[FPlayers.GetPlayers(Coord.X).FPlayerRace]) + ': ' +
      TranslateRStr(TDiplomaticRelationRStr[FPlayers.GetDiplomaticRelation(Coord.X, Coord.Y)]);
end;

procedure TMapSettingsDlg.RelationGridMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  UpdateRelationHint(X, Y);
end;

procedure TMapSettingsDlg.ChangePasswordBtnClick(Sender: TObject);
var Password: string; Dlg: TPasswordDlg;
begin
  Dlg := TPasswordDlg.Create(Self);
  Dlg.Caption := TranslateRStr(ChangePasswordRStr);
  Dlg.EnterPasswordLbl.Caption := TranslateRStr(EnterNewPasswordRStr);
  if Dlg.ShowModal = mrOK then
  begin
    Sleep(250);
    Password := Dlg.PasswordEdit.Text;
    Dlg.PasswordEdit.Text := '';
    Dlg.EnterPasswordLbl.Caption := TranslateRStr(ReenterNewPasswordRStr);
    Dlg.Caption := TranslateRStr(ConfirmPasswordRStr);
    if Dlg.ShowModal = mrOK then
      if Dlg.PasswordEdit.Text = Password then PasswordEdit.Text := Password
      else ShowMessage(TranslateRStr(ConfirmationFailedRStr));
  end;
  Dlg.Free;
end;

procedure TMapSettingsDlg.VictoryConditionClick(Sender: TObject);
begin
  UpdateVictoryCondition;
end;

procedure TMapSettingsDlg.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  CanClose := CancelBtn.Enabled or (ModalResult = mrOK);
end;

end.
