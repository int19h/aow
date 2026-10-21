unit EHeroRes;

{ EHeroRes editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AlgnmBox, EAUnitRes, RaceBox, SpinEdit, AoWE;

type
  THeroResourceEditForm = class;
  THeroResourceEditor = class;


  { THeroResourceEditForm: size $2B0; $2A0 races, $2A4 hero resource,
    $2A8 skill caption, $2AC updating. VMT 00411EDC. }
  THeroResourceEditForm = class(TAbstractUnitResourceEditForm)
  public
    published
    Statistics: TTabSheet; { +0218 }
    GeneralSheet: TTabSheet; { +021C }
    Panel2: TPanel; { +0220 }
    GroupBox3: TGroupBox; { +0224 }
    Label2: TLabel; { +0228 }
    NameEdit: TEdit; { +022C }
    Label4: TLabel; { +0230 }
    RaceBox: TRaceBox; { +0234 }
    Label6: TLabel; { +0238 }
    AlignmentBox: TAlignmentBox; { +023C }
    Panel3: TPanel; { +0240 }
    DesignerOnlyBox: TCheckBox; { +0244 }
    GroupBox1: TGroupBox; { +0248 }
    AbilityListBox: TListBox; { +024C }
    AbilityBtn: TButton; { +0250 }
    GroupBox2: TGroupBox; { +0254 }
    Label11: TLabel; { +0258 }
    Label13: TLabel; { +025C }
    Label14: TLabel; { +0260 }
    Label15: TLabel; { +0264 }
    Label16: TLabel; { +0268 }
    Label17: TLabel; { +026C }
    AttackEdit: TSpin; { +0270 }
    DefenseEdit: TSpin; { +0274 }
    ResistanceEdit: TSpin; { +0278 }
    DamageEdit: TSpin; { +027C }
    HitsEdit: TSpin; { +0280 }
    MovesEdit: TSpin; { +0284 }
    LevelPointsUsed: TPanel; { +0288 }
    HeroTypeBox: TComboBox; { +028C }
    Label21: TLabel; { +0290 }
    GroupBox4: TGroupBox; { +0294 }
    FaceDrawPanel: TDrawPanel; { +0298 }
    SelectFaceBtn: TButton; { +029C }
    public
    FRaces: TRaceList; { $2A0 }
    FHeroResource: THeroResource; { $2A4 }
    FPointsCaption: string; { $2A8 }
    FUpdating: Boolean; { $2AC }
    F_HeroResourceEditForm_2AD: array[0..2] of Byte;
    procedure LoadSettings;
    procedure SaveSettings;
    procedure FormCreate;
    procedure FormDestroy;
    procedure AbilityBtnClick;
    procedure OKBtnClick;
    procedure LevelPointsChanged(Sender: TObject);
    procedure SelectFaceBtnClick;
    procedure FaceDrawPanelDraw(Sender: TObject; const R: TRect);
  end;

  { THeroResourceEditor (instance size 8, VMT 004122F8) }
  THeroResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses FaceSel, SelAbDlg;


procedure THeroResourceEditForm.LoadSettings;
begin
  with FHeroResource do
  begin
    FUpdating := True;
    NameEdit.Text := FName;
    RaceBox.SetRace(FRace);
    FRace := RaceBox.FRace;
    HeroTypeBox.ItemIndex := Ord(FHeroType);
    AlignmentBox.SetAlignment(FAlignment);
    FAlignment := AlignmentBox.FAlignment;
    AttackEdit.Value := FAttack;
    DefenseEdit.Value := FDefense;
    ResistanceEdit.Value := FResistance;
    DamageEdit.Value := FDamage;
    HitsEdit.Value := FHits;
    MovesEdit.Value := FMoves;
    DesignerOnlyBox.Checked := FHidden;
    FAbilities.ListAbilities(AbilityListBox.Items);
    FUpdating := False;
  end;
end;

procedure THeroResourceEditForm.SaveSettings;
begin
  if not FUpdating then
    with FHeroResource do
    begin
      FName := NameEdit.Text;
      FRace := RaceBox.FRace;
      FHeroType := THeroType(HeroTypeBox.ItemIndex);
      FAlignment := AlignmentBox.FAlignment;
      FAttack := AttackEdit.Value;
      FDefense := DefenseEdit.Value;
      FResistance := ResistanceEdit.Value;
      FDamage := DamageEdit.Value;
      FHits := HitsEdit.Value;
      FMoves := MovesEdit.Value;
      FHidden := DesignerOnlyBox.Checked;
    end;
end;

class function THeroResourceEditor.EditorClassID: Integer;
begin Result := $20231; end;


class procedure THeroResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  THeroResourceEditForm.vmt80(AEngine, TEResource(Obj), Done);
end;


procedure THeroResourceEditForm.FormCreate;
begin
  inherited FormCreate;
  FUpdating := False;
  FHeroResource := THeroResource(FUnitResource);
  MainPageControl.ActivePage := GeneralSheet;
  FRaces := TRaceList.Create(nil);
  FRaces.Update;
  RaceBox.SetRaces(FRaces);
  FPointsCaption := LevelPointsUsed.Caption;
  LoadSettings;
end;


procedure THeroResourceEditForm.FormDestroy;
begin
  FRaces.Free;
end;


procedure THeroResourceEditForm.AbilityBtnClick;
var Dlg: TAbilitySelectionDlg;
begin
  Dlg := TAbilitySelectionDlg.CreateSelection(FHeroResource.FAbilities, Self);
  if Dlg.ShowModal = mrOK then FHeroResource.FAbilities.Assign(Dlg.FAbilityOwner, AoWEngine);
  Dlg.Free;
  FHeroResource.FAbilities.ListAbilities(AbilityListBox.Items);
  LevelPointsChanged(Self);
end;


procedure THeroResourceEditForm.OKBtnClick;
begin
  SaveSettings;
end;


procedure THeroResourceEditForm.LevelPointsChanged(Sender: TObject);
begin
  SaveSettings;
  LevelPointsUsed.Caption := ReplaceText(FPointsCaption, '$', IntToStr(FHeroResource.UsedSkillPoints));
end;


procedure THeroResourceEditForm.SelectFaceBtnClick;
var Dlg: TFaceSelectionDlg; Index: Integer;
begin
  Dlg := TFaceSelectionDlg.Create(Self);
  Dlg.SetFaceIndex(FHeroResource.FFaceIndex);
  if Dlg.ShowModal = mrOK then
  begin
    Index := Dlg.FSelectedIndex;
    if Index <> -1 then
    begin
    FHeroResource.FFaceIndex := Index;
    FaceDrawPanel.Invalidate;
    end;
  end;
  Dlg.Free;
end;


procedure THeroResourceEditForm.FaceDrawPanelDraw(Sender: TObject; const R: TRect);
var DrawRect: TRect;
begin
  with FaceDrawPanel do
    if AoWHSSet.FFaceResources.GetFaceResource(FHeroResource.FFaceIndex) <> nil then
      BltLibraryImage(Canvas, AoWHSSet.FFaceResources.GetFaceResource(FHeroResource.FFaceIndex).GetCellImage,
        R, bmStretch, 100, 100, 0, Color, False, DrawRect);
end;



end.
