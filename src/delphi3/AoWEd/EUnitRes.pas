unit EUnitRes;

{ Unit resource property form recovered from AoWEd.exe. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AlgnmBox, EAUnitRes, RaceBox, SpinEdit;

type
  TUnitResourceEditForm = class;
  TUnitResourceEditor = class;


  { TUnitResourceEditForm (instance size $2DC, VMT 004107E0; $2D4 FRaces, $2D8 FRank) }
  TUnitResourceEditForm = class(TAbstractUnitResourceEditForm)
  public
    published
    StatisticsSheet: TTabSheet; { +0218 }
    Panel3: TPanel; { +021C }
    GroupBox2: TGroupBox; { +0220 }
    Label11: TLabel; { +0224 }
    Label13: TLabel; { +0228 }
    Label14: TLabel; { +022C }
    Label15: TLabel; { +0230 }
    Label16: TLabel; { +0234 }
    Label17: TLabel; { +0238 }
    GroupBox1: TGroupBox; { +023C }
    GeneralSheet: TTabSheet; { +0240 }
    Panel2: TPanel; { +0244 }
    GroupBox3: TGroupBox; { +0248 }
    Label4: TLabel; { +024C }
    Label5: TLabel; { +0250 }
    Label6: TLabel; { +0254 }
    Label8: TLabel; { +0258 }
    Label12: TLabel; { +025C }
    Label18: TLabel; { +0260 }
    Label2: TLabel; { +0264 }
    UnitNameEdit: TEdit; { +0268 }
    ClassNameEdit: TEdit; { +026C }
    AlignmentBox: TAlignmentBox; { +0270 }
    RaceBox: TRaceBox; { +0274 }
    UnitTypeBox: TComboBox; { +0278 }
    UnitLevelEdit: TSpin; { +027C }
    GenderBox: TComboBox; { +0280 }
    Label7: TLabel; { +0284 }
    TransportCapacityEdit: TSpin; { +0288 }
    AttackEdit: TSpin; { +028C }
    DefenseEdit: TSpin; { +0290 }
    ResistanceEdit: TSpin; { +0294 }
    DamageEdit: TSpin; { +0298 }
    HitsEdit: TSpin; { +029C }
    MovesEdit: TSpin; { +02A0 }
    CostLabel: TLabel; { +02A4 }
    CostEdit: TSpin; { +02A8 }
    DescriptionSheet: TTabSheet; { +02AC }
    Panel8: TPanel; { +02B0 }
    DescriptionMemo: TMemo; { +02B4 }
    Label3: TLabel; { +02B8 }
    UnitSizeBox: TComboBox; { +02BC }
    Label9: TLabel; { +02C0 }
    BloodTypeBox: TComboBox; { +02C4 }
    AbilityRankTabs: TTabControl; { +02C8 }
    AbilityListBox: TListBox; { +02CC }
    AbilityBtn: TButton; { +02D0 }
    public
    FRaces: TRaceList; { $2D4 }
    FRank: TUnitRank; { $2D8 }
    F_UnitResourceEditForm_2D9: array[0..2] of Byte;
    procedure SetRank(Rank: TUnitRank);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure RaceBoxChange(Sender: TObject);
    procedure AbilityBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure AbilityRankTabsChange(Sender: TObject);
  end;

  { TUnitResourceEditor (instance size 8, VMT 00410CAC) }
  TUnitResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses SelAbDlg;

class procedure TUnitResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TUnitResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  MainPageControl.ActivePage := GeneralSheet;
  FRaces := TRaceList.Create(nil);
  FRaces.Update;
  RaceBox.SetRaces(FRaces);
  with TUnitResource(FUnitResource) do
  begin
    UnitNameEdit.Text := FName;
    RaceBox.SetRace(FRace);
    FRace := RaceBox.FRace;
    RaceBoxChange(Self);
    ClassNameEdit.Text := FNickname;
    AlignmentBox.SetAlignment(FAlignment);
    FAlignment := AlignmentBox.FAlignment;
    UnitTypeBox.ItemIndex := Ord(FUnitType);
    GenderBox.ItemIndex := Ord(FGender);
    UnitLevelEdit.Value := FLevel;
    AttackEdit.Value := FAttack;
    DefenseEdit.Value := FDefense;
    ResistanceEdit.Value := FResistance;
    DamageEdit.Value := FDamage;
    HitsEdit.Value := FHits;
    MovesEdit.Value := FMoves;
    TransportCapacityEdit.Value := GetTransportCapacity;
    DescriptionMemo.Text := FDescription.Text;
    CostEdit.Value := FObtainValue;
    UnitSizeBox.ItemIndex := Ord(FUnitSize);
    BloodTypeBox.ItemIndex := Ord(FBloodType);
  end;
  SetRank(urNone);
end;

procedure TUnitResourceEditForm.FormDestroy(Sender: TObject);
begin
  FRaces.Free;
end;

procedure TUnitResourceEditForm.RaceBoxChange(Sender: TObject);
var Race: Shortint;
begin
  Race := RaceBox.FRace;
  if (Race >= 0) and (TUnitResource(FUnitResource).FName = '') then
    UnitNameEdit.Text := AoWHSSet.FRaceResources.GetRaceResource(Race).FName;
end;

procedure TUnitResourceEditForm.AbilityBtnClick(Sender: TObject);
var Dlg: TAbilitySelectionDlg;
begin
  Dlg := TAbilitySelectionDlg.CreateSelection(TUnitResource(FUnitResource).FAbilities[FRank], Self);
  if Dlg.ShowModal = mrOK then TUnitResource(FUnitResource).FAbilities[FRank].AssignAb(Dlg.FAbilityOwner);
  Dlg.Free;
  TUnitResource(FUnitResource).FAbilities[FRank].ListAbilities(AbilityListBox.Items);
end;

procedure TUnitResourceEditForm.OKBtnClick(Sender: TObject);
begin
  with TUnitResource(FUnitResource) do
  begin
    FName := UnitNameEdit.Text;
    FRace := RaceBox.FRace;
    FNickname := ClassNameEdit.Text;
    FAlignment := AlignmentBox.FAlignment;
    FUnitType := TUnitType(UnitTypeBox.ItemIndex);
    FLevel := UnitLevelEdit.Value;
    FAttack := AttackEdit.Value;
    FDefense := DefenseEdit.Value;
    FResistance := ResistanceEdit.Value;
    FDamage := DamageEdit.Value;
    FHits := HitsEdit.Value;
    FMoves := MovesEdit.Value;
    FGender := TUnitGender(GenderBox.ItemIndex);
    FTransportCapacity := TransportCapacityEdit.Value;
    FDescription.Text := DescriptionMemo.Text;
    FObtainValue := CostEdit.Value;
    FUnitSize := TUnitSize(UnitSizeBox.ItemIndex);
    FBloodType := TBloodType(BloodTypeBox.ItemIndex);
  end;
end;

procedure TUnitResourceEditForm.AbilityRankTabsChange(Sender: TObject);
begin
  SetRank(TUnitRank(AbilityRankTabs.TabIndex));
end;


procedure TUnitResourceEditForm.SetRank(Rank: TUnitRank);
begin
  AbilityRankTabs.TabIndex := Ord(Rank);
  FRank := Rank;
  TUnitResource(FUnitResource).FAbilities[Rank].ListAbilities(AbilityListBox.Items);
end;

end.
