unit EHero;

{ Hero property and upgrade editor from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemGrid, SpinEdit, AoWE, ItemFlt;

type
  THeroEditForm = class;


  { THeroEditForm (instance size $390): $384 edited hero, $388 saved hero,
    $38C read-only mode; VMT 00413E70. }
  THeroEditForm = class(TForm)
  public
    published
    BottomPnl: TPanel; { +01DC }
    OKBtn: TButton; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    ClientPnl: TPanel; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    GeneralSheet: TTabSheet; { +01F0 }
    Panel2: TPanel; { +01F4 }
    Label4: TLabel; { +01F8 }
    Label5: TLabel; { +01FC }
    Label2: TLabel; { +0200 }
    Label1: TLabel; { +0204 }
    Label3: TLabel; { +0208 }
    EditFaceBtn: TButton; { +020C }
    GenderBox: TComboBox; { +0210 }
    NicknameEdit: TComboBox; { +0214 }
    NameEdit: TEdit; { +0218 }
    HeroResourceComboBox: TComboBox; { +021C }
    HeroLevelEdit: TSpin; { +0220 }
    Panel4: TPanel; { +0224 }
    PreviewImagePanel: TDrawPanel; { +0228 }
    ResetBtn: TButton; { +022C }
    ItemSheet: TTabSheet; { +0230 }
    Panel7: TPanel; { +0234 }
    Label8: TLabel; { +0238 }
    Label10: TLabel; { +023C }
    BodyGrid: TItemGrid; { +0240 }
    Image1: TImage; { +0244 }
    Image2: TImage; { +0248 }
    Image3: TImage; { +024C }
    Image4: TImage; { +0250 }
    Image5: TImage; { +0254 }
    Image6: TImage; { +0258 }
    AddItemBtn: TButton; { +025C }
    DeleteItemBtn: TButton; { +0260 }
    ItemGrid: TItemGrid; { +0264 }
    SkillPoints: TPanel; { +0268 }
    SourceLibraryLbl: TLabel; { +026C }
    Bevel1: TBevel; { +0270 }
    Label15: TLabel; { +0274 }
    Bevel2: TBevel; { +0278 }
    HitsLabel: TLabel; { +027C }
    DamageLabel: TLabel; { +0280 }
    AttackLabel: TLabel; { +0284 }
    AttackBase: TLabel; { +0288 }
    DamageBase: TLabel; { +028C }
    HitsBase: TLabel; { +0290 }
    Image9: TImage; { +0294 }
    Image7: TImage; { +0298 }
    Image11: TImage; { +029C }
    AttackEdit: TSpin; { +02A0 }
    DamageEdit: TSpin; { +02A4 }
    HitsEdit: TSpin; { +02A8 }
    Label6: TLabel; { +02AC }
    Label20: TLabel; { +02B0 }
    Label21: TLabel; { +02B4 }
    Label34: TLabel; { +02B8 }
    Attack: TLabel; { +02BC }
    Label31: TLabel; { +02C0 }
    Damage: TLabel; { +02C4 }
    Label30: TLabel; { +02C8 }
    Hits: TLabel; { +02CC }
    DefenseLabel: TLabel; { +02D0 }
    ResistanceLabel: TLabel; { +02D4 }
    MovesLabel: TLabel; { +02D8 }
    DefenseBase: TLabel; { +02DC }
    ResistanceBase: TLabel; { +02E0 }
    MovesBase: TLabel; { +02E4 }
    Label9: TLabel; { +02E8 }
    Label12: TLabel; { +02EC }
    Label22: TLabel; { +02F0 }
    MovesEdit: TSpin; { +02F4 }
    ResistanceEdit: TSpin; { +02F8 }
    DefenseEdit: TSpin; { +02FC }
    Label33: TLabel; { +0300 }
    Label32: TLabel; { +0304 }
    Label29: TLabel; { +0308 }
    Moves: TLabel; { +030C }
    Resistance: TLabel; { +0310 }
    Defense: TLabel; { +0314 }
    Image10: TImage; { +0318 }
    Image8: TImage; { +031C }
    Image12: TImage; { +0320 }
    Panel10: TPanel; { +0324 }
    SelectedAbBox: TListBox; { +0328 }
    AvailableAbBox: TListBox; { +032C }
    Panel11: TPanel; { +0330 }
    DeleteBtn: TButton; { +0334 }
    AddBtn: TButton; { +0338 }
    SpheresSheet: TTabSheet; { +033C }
    SpherePnl: TPanel; { +0340 }
    LifeLbl: TLabel; { +0344 }
    DeathLbl: TLabel; { +0348 }
    EarthLbl: TLabel; { +034C }
    WaterLbl: TLabel; { +0350 }
    FireLbl: TLabel; { +0354 }
    AirLbl: TLabel; { +0358 }
    LifeEdit: TSpin; { +035C }
    DeathEdit: TSpin; { +0360 }
    EarthEdit: TSpin; { +0364 }
    AirEdit: TSpin; { +0368 }
    FireEdit: TSpin; { +036C }
    WaterEdit: TSpin; { +0370 }
    Bevel3: TBevel; { +0374 }
    Bevel4: TBevel; { +0378 }
    AssignSpheresLbl: TLabel; { +037C }
    Translator: TIvTranslator; { +0380 }
    public
    FHero: THero; { $384 }
    FSavedHero: THero; { $388 }
    FReadOnly: Boolean; { $38C }
    F_HeroEditForm_38D: array[0..2] of Byte;
    procedure vmt80; virtual;  { +080 }
    procedure vmt84; virtual;  { +084 }
    function vmt88(AbilityID: Integer): string; virtual;  { +088 }
    function vmt8C(AbilityID: Integer): string; virtual;  { +08C }
    function vmt90(AbilityID: Integer): Boolean; virtual;  { +090 }
    function vmt94(AbilityID: Integer): Boolean; virtual;  { +094 }
    procedure UpdateAddButton;
    procedure UpdateDeleteButton;
    procedure UpdateStatistics;
    procedure UpdateLeader;
    procedure UpdateControls;
    procedure UpdateSkillPoints;
    procedure SetHero(Hero: THero);
    function EditLibraryHero(Hero: THero): Boolean;
    function EditHero(Hero: THero): Boolean;
    published procedure FormCreate; public  { }
    published procedure FormDestroy; public  { }
    published procedure HeroResourceComboBoxChange(Sender: TObject); public  { }
    published procedure EditFaceBtnClick; public
    published procedure PreviewImagePanelDraw(Sender: TObject; const R: TRect); public
    published procedure OKBtnClick; public  { }
    published procedure ResetBtnClick; public  { }
    published procedure HeroLevelEditChange; public  { }
    published procedure AttackEditChange; public  { }
    published procedure DefenseEditChange; public  { }
    published procedure ResistanceEditChange; public  { }
    published procedure DamageEditChange; public  { }
    published procedure HitsEditChange; public  { }
    published procedure MovesEditChange; public  { }
    published procedure AddBtnClick; public  { }
    published procedure DeleteBtnClick; public  { }
    published procedure AvailableAbBoxClick; public  { }
    published procedure SelectedAbBoxClick; public  { }
    published procedure AddItemBtnClick; public
    published procedure DeleteItemBtnClick; public
    published procedure MainPageControlChange; public  { }
    published procedure NicknameEditChange; public  { }
    published procedure NameEditChange; public  { }
    published procedure ItemGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean); public  { }
    published procedure BodyGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean); public  { }
    published procedure BodyGridDblClick; public
    published procedure ItemGridDblClick; public
    published procedure SphereEditChange(Sender: TObject); public  { }
  end;


implementation

uses MDIForm, FaceSel, EItem;

procedure THeroEditForm.vmt80;
var
  Index, Top, I: Integer;
  List: TStringList;
  S: string;
begin
  List := TStringList.Create;
  Index := AvailableAbBox.ItemIndex;
  Top := AvailableAbBox.TopIndex;
  for I := 0 to AoWHSSet.FAbilityControl.GetCount - 1 do
    if AoWHSSet.FAbilityControl.GetAbility(I) <> nil then
      if AoWHSSet.FAbilityControl.GetAbility(I).CanExpand(FHero) then
        List.AddObject(vmt8C(I), TObject(I));
  AvailableAbBox.Items.Assign(List);
  AvailableAbBox.TopIndex := Top;
  if not FReadOnly then
  begin
    AvailableAbBox.ItemIndex := Index;
    if AvailableAbBox.ItemIndex < 0 then AvailableAbBox.ItemIndex := 0;
  end
  else AvailableAbBox.ItemIndex := -1;
  List.Free;
end;

procedure THeroEditForm.vmt84;
var
  Index, I: Integer;
begin
  with SelectedAbBox do
  begin
    Index := ItemIndex;
    Items.Clear;
  end;
  for I := 0 to FHero.GetAbCount - 1 do
    if FHero.GetAbilityEnabled(I) then
      if AoWHSSet.FAbilityControl.GetAbility(I).FSelectionTypes * [astUnit, astCustomizeLeader, astHeroUpgrade, astEditor] <> [] then
        SelectedAbBox.Items.AddObject(vmt88(I), TObject(I));
  if not FReadOnly then
  begin
    SelectedAbBox.ItemIndex := Index;
    if SelectedAbBox.ItemIndex < 0 then
      with SelectedAbBox do ItemIndex := Items.Count - 1;
  end
  else SelectedAbBox.ItemIndex := -1;
end;

function THeroEditForm.vmt88(AbilityID: Integer): string;
var
  Cost: Integer;
begin
  if FHero.FHeroResource.FAbilities.GetAbSet(AbilityID) and
    (FHero.FHeroResource.FAbilities.GetAbLevel(AbilityID) = FHero.GetAbilityLevel(AbilityID)) then
    Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(FHero) + ' (' + LowerCase(TranslateRStr(FixedRStr)) + ')'
  else
  begin
    Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(FHero);
    Cost := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetSkillPoints(FHero);
    if Cost <> 0 then Result := Result + ' (' + IntToStr(Cost) + LowerCase(TranslateRStr(spRStr)) + ')';
  end;
end;

function THeroEditForm.vmt8C(AbilityID: Integer): string;
var
  Cost: Integer;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandName(FHero);
  Cost := AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandCost(FHero);
  if Cost <> 0 then Result := Result + ' (' + IntToStr(Cost) + LowerCase(TranslateRStr(spRStr)) + ')';
end;

function THeroEditForm.vmt90(AbilityID: Integer): Boolean;
begin
  Result := not FReadOnly and not (FHero.FHeroResource.FAbilities.GetAbSet(AbilityID) and
    (FHero.FHeroResource.FAbilities.GetAbLevel(AbilityID) = FHero.GetAbilityLevel(AbilityID)));
end;

function THeroEditForm.vmt94(AbilityID: Integer): Boolean;
begin
  Result := not FReadOnly and AoWHSSet.FAbilityControl.GetAbility(AbilityID).CanExpand(FHero) and
    (AoWHSSet.FAbilityControl.GetAbility(AbilityID).ExpandCost(FHero) <= FHero.GetSkillPoints);
end;

procedure THeroEditForm.FormCreate;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  if MainForm.HSMEdit.Activated then MainForm.HSMEdit.PauseFrameUpdateLoop;
  MainPageControl.ActivePage := GeneralSheet;
  with AttackLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(5) + ')';
  with DefenseLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(5) + ')';
  with ResistanceLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(5) + ')';
  with DamageLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(10) + ')';
  with HitsLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(5) + ')';
  with MovesLabel do Caption := Caption + ' (' + TranslateRStr(spRStr) + ':' + IntToStr(2) + ')';
end;

procedure THeroEditForm.FormDestroy;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  if FSavedHero <> nil then
  begin
    FSavedHero.Free;
    FSavedHero := nil;
  end;
  if MainForm.HSMEdit.Activated then MainForm.HSMEdit.ResumeFrameUpdateLoop;
  ItemFloater.Hide;
end;

procedure THeroEditForm.HeroResourceComboBoxChange(Sender: TObject);
begin
  with HeroResourceComboBox do FHero.SetHeroResourceIndex(Integer(Items.Objects[ItemIndex]));
  UpdateControls;
end;

procedure THeroEditForm.EditFaceBtnClick;
var Dlg: TFaceSelectionDlg; Index: Integer;
begin
  Dlg := TFaceSelectionDlg.Create(Self);
  Dlg.SetFaceIndex(FHero.FFaceIndex);
  if Dlg.ShowModal = mrOK then
  begin
    Index := Dlg.FSelectedIndex;
    if Index <> -1 then
    begin
      FHero.SetFaceIndex(Index);
      PreviewImagePanel.Invalidate;
    end;
  end;
  Dlg.Free;
end;

procedure THeroEditForm.PreviewImagePanelDraw(Sender: TObject; const R: TRect);
var DrawRect: TRect;
begin
  with PreviewImagePanel do
    if AoWHSSet.FFaceResources.GetFaceResource(FHero.FFaceIndex) <> nil then
      BltLibraryImage(Canvas, AoWHSSet.FFaceResources.GetFaceResource(FHero.FFaceIndex).GetCellImage,
        R, bmCenter, 100, 100, 0, Color, False, DrawRect);
end;

procedure THeroEditForm.OKBtnClick;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  with FHero do
  begin
    FHeroName := NameEdit.Text;
    FGender := TUnitGender(GenderBox.ItemIndex);
    SetNickname(NicknameEdit.Text);
  end;
  if AoWHSMap <> nil then AoWHSMap.SetModified else AoWHSSet.SetModified;
  FHero.Changed;
end;

procedure THeroEditForm.ResetBtnClick;
begin
  FHero.ResetSkillPoints;
  UpdateControls;
end;

procedure THeroEditForm.HeroLevelEditChange;
begin
  { Original truncates to a byte before the signed range check. }
  FHero.SetLevel(Byte(HeroLevelEdit.Value));
  HeroLevelEdit.Value := FHero.GetLevel;
  UpdateSkillPoints;
  UpdateAddButton;
end;

procedure THeroEditForm.AttackEditChange;
begin
  FHero.SetUnitAttack(AttackEdit.Value);
  AttackEdit.Value := FHero.FUnitAttack;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.DefenseEditChange;
begin
  FHero.SetUnitDefense(DefenseEdit.Value);
  DefenseEdit.Value := FHero.FUnitDefense;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.ResistanceEditChange;
begin
  FHero.SetUnitResistance(ResistanceEdit.Value);
  ResistanceEdit.Value := FHero.FUnitResistance;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.DamageEditChange;
begin
  FHero.SetUnitDamage(DamageEdit.Value);
  DamageEdit.Value := FHero.FUnitDamage;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.HitsEditChange;
begin
  FHero.SetUnitHits(HitsEdit.Value);
  HitsEdit.Value := FHero.FUnitHits;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.MovesEditChange;
begin
  { Original truncates to a byte before the signed range check. }
  FHero.SetUnitMoves(Byte(Integer(MovesEdit.Value) and $FF));
  MovesEdit.Value := FHero.FUnitMoves;
  UpdateSkillPoints;
  UpdateStatistics;
end;

procedure THeroEditForm.AddBtnClick;
begin
  with AvailableAbBox do FHero.ExpandAbility(Integer(Items.Objects[ItemIndex]));
  vmt84;
  vmt80;
  UpdateStatistics;
  UpdateSkillPoints;
  UpdateAddButton;
  UpdateDeleteButton;
end;

procedure THeroEditForm.DeleteBtnClick;
begin
  with SelectedAbBox do FHero.RemoveAbility(Integer(Items.Objects[ItemIndex]));
  vmt84;
  vmt80;
  UpdateStatistics;
  UpdateSkillPoints;
  UpdateAddButton;
  UpdateDeleteButton;
end;

procedure THeroEditForm.AvailableAbBoxClick;
begin
  UpdateAddButton;
end;

procedure THeroEditForm.SelectedAbBoxClick;
begin
  UpdateDeleteButton;
end;

procedure THeroEditForm.AddItemBtnClick;
begin
  with ItemGrid do
    if SelectionEnabled then
    begin
      AddItem(ItemFloater.ItemControlGrid.GetSelectedItem);
      Exit;
    end;
  if FHero.FHeroItems.CanPlaceItem(ItemFloater.ItemControlGrid.GetSelectedItem,
    THeroItemPosition(BodyGrid.ImageIndex(BodyGrid.Col, BodyGrid.Row))) then
    BodyGrid.AddItem(ItemFloater.ItemControlGrid.GetSelectedItem);
end;

procedure THeroEditForm.DeleteItemBtnClick;
begin
  if ItemGrid.SelectionEnabled then ItemGrid.DeleteItem
  else BodyGrid.DeleteItem;
end;

procedure THeroEditForm.MainPageControlChange;
begin
  if ItemSheet.Enabled and (ItemSheet = MainPageControl.ActivePage) then ItemFloater.Show
  else ItemFloater.Hide;
end;

procedure THeroEditForm.NicknameEditChange;
begin
  FHero.SetNickname(NicknameEdit.Text);
end;

procedure THeroEditForm.NameEditChange;
begin
  FHero.FHeroName := NameEdit.Text;
end;

procedure THeroEditForm.ItemGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  BodyGrid.SelectionEnabled := False;
end;

procedure THeroEditForm.BodyGridSelectCell(Sender: TObject; ACol, ARow: Integer; var CanSelect: Boolean);
begin
  ItemGrid.SelectionEnabled := False;
end;

procedure THeroEditForm.BodyGridDblClick;
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := BodyGrid.GetSelectedItem;
  if Item <> nil then
  begin
    Dlg := TItemEditForm.Create(Application);
    if Item.GetLibraryItem then Dlg.EditLibraryItem(Item)
    else Dlg.EditItem(Item);
    Dlg.Free;
  end;
end;

procedure THeroEditForm.ItemGridDblClick;
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := ItemGrid.GetSelectedItem;
  if Item <> nil then
  begin
    Dlg := TItemEditForm.Create(Application);
    if Item.GetLibraryItem then Dlg.EditLibraryItem(Item)
    else Dlg.EditItem(Item);
    Dlg.Free;
  end;
end;

procedure THeroEditForm.SphereEditChange(Sender: TObject);
var
  Sphere: TMagicSphere;
  Picks: Integer;
begin
  Sphere := TMagicSphere(TSpin(Sender).Tag);
  Picks := TLeader(FHero).GetSpherePicks(Sphere);
  if TSpin(Sender).Value > Picks then TLeader(FHero).AddSphere(Sphere)
  else if TSpin(Sender).Value < Picks then TLeader(FHero).DeleteSphere(Sphere);
  TSpin(Sender).Value := TLeader(FHero).GetSpherePicks(Sphere);
end;



procedure THeroEditForm.UpdateAddButton;
var AbilityID: Integer; begin
  with AvailableAbBox do
    if ItemIndex <> -1 then begin AbilityID := Integer(Items.Objects[ItemIndex]); AddBtn.Enabled := vmt94(AbilityID); end
    else AddBtn.Enabled := False;
end;

procedure THeroEditForm.UpdateDeleteButton;
var AbilityID: Integer; begin
  with SelectedAbBox do
    if ItemIndex <> -1 then begin AbilityID := Integer(Items.Objects[ItemIndex]); DeleteBtn.Enabled := vmt90(AbilityID); end
    else DeleteBtn.Enabled := False;
end;

procedure THeroEditForm.UpdateStatistics;
begin
  Attack.Caption := IntToStr(FHero.FHeroResource.FAttack + FHero.FUnitAttack);
  Defense.Caption := IntToStr(FHero.FHeroResource.FDefense + FHero.FUnitDefense);
  Resistance.Caption := IntToStr(FHero.FHeroResource.FResistance + FHero.FUnitResistance);
  Damage.Caption := IntToStr(FHero.FHeroResource.FDamage + FHero.FUnitDamage);
  Hits.Caption := IntToStr(FHero.FHeroResource.FHits + FHero.FUnitHits);
  Moves.Caption := IntToStr(FHero.FHeroResource.FMoves + FHero.FUnitMoves);
end;

procedure THeroEditForm.UpdateLeader; var Hero: TLeader;
begin
  Hero := TLeader(FHero); if TObject(Hero) is TLeader then
  begin
    Caption := TranslateRStr(LeaderRStr) + ' ' + TranslateRStr(PropertiesRStr);
    LifeEdit.Value := Hero.GetSpherePicks(msLife);
    DeathEdit.Value := Hero.GetSpherePicks(msDeath);
    FireEdit.Value := Hero.GetSpherePicks(msFire);
    AirEdit.Value := Hero.GetSpherePicks(msAir);
    EarthEdit.Value := Hero.GetSpherePicks(msEarth);
    WaterEdit.Value := Hero.GetSpherePicks(msWater);
  end;
end;

procedure THeroEditForm.UpdateControls;
var
  I: Integer;
begin
  with FHero do
  begin
    NameEdit.Text := FHeroName;
    NicknameEdit.Text := GetNickname;
    HeroLevelEdit.Value := GetLevel;
    if GetLibraryHero then
    begin
      SourceLibraryLbl.Visible := True;
      SourceLibraryLbl.Caption := AoWE.Format(TranslateRStr(SourceLibraryXRStr), [GetLibraryName]);
    end
    else SourceLibraryLbl.Visible := False;
    with HeroResourceComboBox do
    begin
      I := 0;
      HeroResourceComboBox.ItemIndex := -1;
      while (I <> Items.Count) and (HeroResourceComboBox.ItemIndex = -1) do
      begin
        if AoWHSSet.FHeroResources.GetHeroResource(Integer(Items.Objects[I])).FRace = FHero.FRace then
          HeroResourceComboBox.ItemIndex := I;
        Inc(I);
      end;
    end;
    GenderBox.ItemIndex := Integer(FGender);
    AttackEdit.Value := FUnitAttack;
    DefenseEdit.Value := FUnitDefense;
    ResistanceEdit.Value := FUnitResistance;
    DamageEdit.Value := FUnitDamage;
    HitsEdit.Value := FUnitHits;
    MovesEdit.Value := FUnitMoves;
    AttackBase.Caption := IntToStr(FHeroResource.FAttack);
    DefenseBase.Caption := IntToStr(FHeroResource.FDefense);
    ResistanceBase.Caption := IntToStr(FHeroResource.FResistance);
    DamageBase.Caption := IntToStr(FHeroResource.FDamage);
    HitsBase.Caption := IntToStr(FHeroResource.FHits);
    MovesBase.Caption := IntToStr(FHeroResource.FMoves);
  end;
  UpdateStatistics;
  UpdateLeader;
  UpdateSkillPoints;
  vmt80;
  vmt84;
  UpdateAddButton;
  UpdateDeleteButton;
  if FReadOnly then
  begin
    NameEdit.Color := clBtnFace;
    NicknameEdit.Color := clBtnFace;
    HeroResourceComboBox.Color := clBtnFace;
    HeroLevelEdit.Color := clBtnFace;
    GenderBox.Color := clBtnFace;
    AttackEdit.Color := clBtnFace;
    DefenseEdit.Color := clBtnFace;
    ResistanceEdit.Color := clBtnFace;
    DamageEdit.Color := clBtnFace;
    HitsEdit.Color := clBtnFace;
    MovesEdit.Color := clBtnFace;
    SelectedAbBox.Color := clBtnFace;
    AvailableAbBox.Color := clBtnFace;
    ItemGrid.SelectionEnabled := False;
    BodyGrid.SelectionEnabled := False;
    GeneralSheet.Enabled := False;
  end
  else
  begin
    NameEdit.Color := clWindow;
    NicknameEdit.Color := clWindow;
    HeroResourceComboBox.Color := clWindow;
    HeroLevelEdit.Color := clWindow;
    GenderBox.Color := clWindow;
    AttackEdit.Color := clWindow;
    DefenseEdit.Color := clWindow;
    ResistanceEdit.Color := clWindow;
    DamageEdit.Color := clWindow;
    HitsEdit.Color := clWindow;
    MovesEdit.Color := clWindow;
    SelectedAbBox.Color := clWindow;
    AvailableAbBox.Color := clWindow;
    ItemGrid.SelectionEnabled := False;
    BodyGrid.SelectionEnabled := True;
    GeneralSheet.Enabled := True;
  end;
  { Original dereferences AoWHSMap for leaders without a nil check. }
  if (FHero is TLeader) and (AoWHSMap.FGameType <> gtCampaign) then
  begin
    NicknameEdit.Color := clBtnFace;
    NicknameEdit.Enabled := False;
  end;
end;

procedure THeroEditForm.UpdateSkillPoints;
begin
  SkillPoints.Caption := TranslateRStr(SkillPointsRStr) + ' ' + IntToStr(FHero.GetSkillPoints) + '/' + IntToStr(FHero.GetSkillPointsMax);
end;

procedure THeroEditForm.SetHero(Hero: THero);
var Types: THeroTypes; List: TStringList; Saved: THero; Index: Integer;
begin
  Saved := FSavedHero;
  if Saved <> nil then Saved.Free;
  ItemSheet.TabVisible := usActivated in Hero.FUnitStatus;
  SpheresSheet.TabVisible := (usActivated in Hero.FUnitStatus) and (Hero is TLeader);
  FHero := Hero;
  FSavedHero := THero(Hero.Copy(AoWEngine));
  ItemGrid.SetItems(FHero.FInventory);
  BodyGrid.SetItems(FHero.FHeroItems);
  { The original builds a singleton set for the selected hero type. }

  List := AoWHSSet.FHeroResources.CreateHeroResourceStrings([FHero.GetHeroType]);
  HeroResourceComboBox.Items := List;
  List.Free;
  Index := FHero.FHeroResourceIndex;
  if Index = -1 then
  begin
    HeroResourceComboBox.ItemIndex := 0;
    HeroResourceComboBoxChange(Self);
  end
  else HeroResourceComboBox.ItemIndex := Index;
end;

function THeroEditForm.EditLibraryHero(Hero: THero): Boolean;
var Accepted, Active: Boolean;
begin { Match trials (8): addressable/absolute locals, record storage, declaration/operand order, named temporaries, with scopes, Pointer casts, Result/modal locals; still differs. }
  MainPageControl.ActivePage := GeneralSheet;
  if usActivated in Hero.FUnitStatus then
  begin
    OKBtn.Visible := True;
    CancelBtn.Caption := TranslateRStr(CancelRStr);
  end
  else
  begin
    CancelBtn.Caption := TranslateRStr(CloseRStr);
    OKBtn.Visible := False;
  end;
  FReadOnly := True;
  SetHero(Hero);
  UpdateControls;
  Accepted := ShowModal = mrOK;
  if not Accepted then
  begin
    Active := usActivated in Hero.FUnitStatus;
    if Active then Hero.Deactivate;
    Hero.Assign(FSavedHero, AoWEngine);
    if Active then Hero.Activate;
  end;
  Result := Accepted;
end;

function THeroEditForm.EditHero(Hero: THero): Boolean;
var Accepted, Active: Boolean;
begin { Match trials (8): addressable/absolute locals, record storage, declaration/operand order, named temporaries, with scopes, Pointer casts, Result/modal locals; still differs. }
  MainPageControl.ActivePage := GeneralSheet;
  CancelBtn.Caption := TranslateRStr(CancelRStr);
  OKBtn.Visible := True;
  FReadOnly := False;
  SetHero(Hero);
  UpdateControls;
  Accepted := ShowModal = mrOK;
  if not Accepted then
  begin
    Active := usActivated in Hero.FUnitStatus;
    if Active then Hero.Deactivate;
    Hero.Assign(FSavedHero, AoWEngine);
    if Active then Hero.Activate;
  end;
  Result := Accepted;
end;

end.
