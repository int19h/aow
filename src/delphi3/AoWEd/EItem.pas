unit EItem;

{ EItem editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Spin, SpinEdit, AoWE;

type
  TItemEditForm = class;


  { TItemEditForm: size $284; $27C working item, $280 read-only mode. VMT 00412D30. }
  TItemEditForm = class(TForm)
  public
    published
    ClientPnl: TPanel; { +01DC }
    MainPageControl: TPageControl; { +01E0 }
    GeneralSheet: TTabSheet; { +01E4 }
    Label4: TLabel; { +01E8 }
    Label3: TLabel; { +01EC }
    AvailabilityLabel: TLabel; { +01F0 }
    Label1: TLabel; { +01F4 }
    Panel3: TPanel; { +01F8 }
    PreviewImagePanel: TDrawPanel; { +01FC }
    EditBtn: TButton; { +0200 }
    ItemNameEdit: TEdit; { +0204 }
    ItemTypeBox: TComboBox; { +0208 }
    AvailabilityBox: TComboBox; { +020C }
    CostEdit: TSpinEdit; { +0210 }
    OKBtn: TButton; { +0214 }
    CancelBtn: TButton; { +0218 }
    SourceLibraryLbl: TLabel; { +021C }
    Bevel1: TBevel; { +0220 }
    StatisticsPnl: TPanel; { +0224 }
    Label2: TLabel; { +0228 }
    Label5: TLabel; { +022C }
    Label7: TLabel; { +0230 }
    Label6: TLabel; { +0234 }
    Image8: TImage; { +0238 }
    Image7: TImage; { +023C }
    Image10: TImage; { +0240 }
    Image6: TImage; { +0244 }
    Label8: TLabel; { +0248 }
    Bevel2: TBevel; { +024C }
    AttackEdit: TSpin; { +0250 }
    DefenseEdit: TSpin; { +0254 }
    ResistanceEdit: TSpin; { +0258 }
    DamageEdit: TSpin; { +025C }
    AbilityListBox: TListBox; { +0260 }
    Label9: TLabel; { +0264 }
    ChangeAbilities: TButton; { +0268 }
    ScrollPnl: TPanel; { +026C }
    Label11: TLabel; { +0270 }
    SpellComboBox: TComboBox; { +0274 }
    Translator: TIvTranslator; { +0278 }
    public
    FItem: TItem; { $27C }
    FReadOnly: Boolean; { $280 }
    FReserved281: array[0..2] of Byte;
    procedure UpdateControls;
    procedure EditLibraryItem(Item: TItem);
    { conflict: function EditLibraryItem(Item: TItem): Boolean; }
    function EditItem(Item: TItem): Boolean;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy;
    procedure EditBtnClick; { draft: ItemSel selection constructor is not recovered }
    procedure PreviewImagePanelDraw(Sender: TObject; const R: TRect);
    procedure ItemTypeBoxChange;
    procedure ItemNameEditChange;
    procedure DefenseChange(Sender: TObject);
    procedure ResistanceChange(Sender: TObject);
    procedure AttackChange(Sender: TObject);
    procedure DamageChange(Sender: TObject);
    procedure AvailabilityBoxChange;
    procedure AbilityBtnClick;
    procedure DescriptionEditChange;
    procedure CostEditChange;
    procedure SpellComboBoxChange(Sender: TObject);
  end;


implementation

uses MDIForm, SelAbDlg;

procedure TItemEditForm.UpdateControls;
begin
  ItemNameEdit.Text := FItem.FOwnerName;
  ItemTypeBox.ItemIndex := Ord(FItem.FItemType);
  PreviewImagePanel.Invalidate;
  AvailabilityBox.ItemIndex := Ord(FItem.FAvailability);
  CostEdit.Value := FItem.FObtainValue;
  ScrollPnl.Visible := FItem.FItemType = itScroll;
  StatisticsPnl.Visible := not (FItem.FItemType in [itScroll]);
  with FItem do
    if FItemGFXIndex = -1 then SetItemGFXIndex(AoWHSSet.FItemGFXResources.FindItemTypeGFX(FItemType));
  if FItem.GetLibraryItem then
  begin
    SourceLibraryLbl.Visible := True;
    SourceLibraryLbl.Caption := AoWE.Format(TranslateRStr(SourceLibraryXRStr), [FItem.GetLibraryName]);
  end
  else SourceLibraryLbl.Visible := False;
  with FItem do
  begin
    DamageEdit.Value := FDamage;
    AttackEdit.Value := FAttack;
    DefenseEdit.Value := FDefense;
    ResistanceEdit.Value := FResistance;
  end;
  FItem.ListAbilities(AbilityListBox.Items);
  if FReadOnly then
  begin
    AttackEdit.Color := clBtnFace;
    DefenseEdit.Color := clBtnFace;
    ResistanceEdit.Color := clBtnFace;
    DamageEdit.Color := clBtnFace;
    ItemNameEdit.Color := clBtnFace;
    ItemTypeBox.Color := clBtnFace;
    AvailabilityBox.Color := clBtnFace;
    AbilityListBox.Color := clBtnFace;
    GeneralSheet.Enabled := False;
    CostEdit.Color := clBtnFace;
    SpellComboBox.Color := clBtnFace;
    SpellComboBox.Enabled := False;
  end
  else
  begin
    if FItem.FItemType <> itUse then
    begin
      AttackEdit.Color := clWindow;
      DefenseEdit.Color := clWindow;
      ResistanceEdit.Color := clWindow;
      DamageEdit.Color := clWindow;
    end
    else
    begin
      AttackEdit.Color := clBtnFace;
      DefenseEdit.Color := clBtnFace;
      ResistanceEdit.Color := clBtnFace;
      DamageEdit.Color := clBtnFace;
    end;
    ItemNameEdit.Color := clWindow;
    ItemTypeBox.Color := clWindow;
    AvailabilityBox.Color := clWindow;
    AbilityListBox.Color := clWindow;
    CostEdit.Color := clWindow;
    SpellComboBox.Color := clWindow;
    SpellComboBox.Enabled := True;
    with FItem do
      if FItemType = itScroll then
      begin
        with SpellComboBox do
          ItemIndex := Items.IndexOfObject(AoWHSSet.FSpellControl.GetSpell(FSpellID));
        if SpellComboBox.ItemIndex = -1 then
        begin
          SpellComboBox.ItemIndex := 0;
          SpellComboBoxChange(Self);
        end;
      end;
    GeneralSheet.Enabled := True;
  end;
end;

procedure TItemEditForm.EditLibraryItem(Item: TItem);
begin
  if FItem <> nil then FItem.Free;
  MainPageControl.ActivePage := GeneralSheet;
  CancelBtn.Caption := TranslateRStr(CloseRStr);
  OKBtn.Visible := False;
  FReadOnly := True;
  FItem := TItem(Item.Copy(AoWEngine));
  UpdateControls;
  ShowModal;
end;

function TItemEditForm.EditItem(Item: TItem): Boolean;
var Activated: Boolean;
begin
  if FItem <> nil then FItem.Free;
  MainPageControl.ActivePage := GeneralSheet;
  CancelBtn.Caption := TranslateRStr(CancelRStr);
  OKBtn.Visible := True;
  FReadOnly := False;
  FItem := TItem(Item.Copy(AoWEngine));
  UpdateControls;
  Result := ShowModal = mrOK;
  if Result then
  begin
    Activated := isActivated in Item.FStatus;
    if Activated then Item.Deactivate;
    Item.Assign(FItem, AoWEngine);
    if Activated then Item.Activate;
    Item.Changed;
  end;
end;

procedure TItemEditForm.FormCreate(Sender: TObject);
var List: TStringList; I: Integer;
begin
  with MainForm.HSMEdit do if Activated then PauseFrameUpdateLoop;
  List := TStringList.Create;
  for I := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
    if AoWHSSet.FSpellControl.GetSpell(I) <> nil then
      List.AddObject(AoWHSSet.FSpellControl.GetSpell(I).FSpellName, AoWHSSet.FSpellControl.GetSpell(I));
  List.Sort;
  SpellComboBox.Items.Assign(List);
  List.Free;
end;


procedure TItemEditForm.FormDestroy;
begin
  with MainForm.HSMEdit do if Activated then ResumeFrameUpdateLoop;
  if FItem <> nil then begin FItem.Free; FItem := nil; end;
end;


procedure TItemEditForm.EditBtnClick;
begin end;

procedure TItemEditForm.PreviewImagePanelDraw(Sender: TObject; const R: TRect);
var DrawRect: TRect;
begin
  with PreviewImagePanel do
    if AoWHSSet.FItemGFXResources.GetItemGFX(FItem.FItemGFXIndex) <> nil then
      BltLibraryImage(Canvas, AoWHSSet.FItemGFXResources.GetItemGFX(FItem.FItemGFXIndex).GetCellImage,
        R, bmCenter, 100, 100, 0, Color, False, DrawRect);
end;


procedure TItemEditForm.ItemTypeBoxChange;
begin
  FItem.SetItemType(TItemType(ItemTypeBox.ItemIndex));
  UpdateControls;
end;


procedure TItemEditForm.ItemNameEditChange;
begin
  FItem.FOwnerName := ItemNameEdit.Text;
end;


procedure TItemEditForm.DefenseChange(Sender: TObject);
begin
  FItem.FDefense := TSpin(Sender).Value;
end;


procedure TItemEditForm.ResistanceChange(Sender: TObject);
begin
  FItem.FResistance := TSpin(Sender).Value;
end;


procedure TItemEditForm.AttackChange(Sender: TObject);
begin
  FItem.FAttack := TSpin(Sender).Value;
end;


procedure TItemEditForm.DamageChange(Sender: TObject);
begin
  FItem.FDamage := TSpin(Sender).Value;
end;


procedure TItemEditForm.AvailabilityBoxChange;
begin
  FItem.FAvailability := TItemAvailability(AvailabilityBox.ItemIndex);
end;


procedure TItemEditForm.AbilityBtnClick;
var Dlg: TAbilitySelectionDlg;
begin
  Dlg := TAbilitySelectionDlg.CreateSelection(FItem, Self);
  if Dlg.ShowModal = mrOK then FItem.AssignAb(Dlg.FAbilityOwner);
  UpdateControls;
  Dlg.Free;
end;


procedure TItemEditForm.DescriptionEditChange;
begin end;

procedure TItemEditForm.CostEditChange;
begin
  FItem.FObtainValue := CostEdit.Value;
end;

procedure TItemEditForm.SpellComboBoxChange(Sender: TObject);
begin
  if SpellComboBox.ItemIndex <> -1 then
    with SpellComboBox do FItem.FSpellID := TSpell(Items.Objects[ItemIndex]).FSpellID
  else FItem.FSpellID := 0;
end;



end.
