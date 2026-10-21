unit EHero;

{ Draft declarations of EHero, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemGrid, SpinEdit;

type
  THeroEditForm = class;


  { THeroEditForm (instance size 912, VMT 00413E70) }
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
    F_HeroEditForm_384: Integer;
    F_HeroEditForm_388: Integer;
    F_HeroEditForm_38C: Byte;
    F_HeroEditForm_38D: array[0..2] of Byte;
    procedure vmt80; virtual;  { +080 draft }
    procedure vmt84; virtual;  { +084 draft }
    procedure vmt88(A1: Integer; A2: Integer); virtual;  { +088 draft }
    procedure vmt8C(A1: Integer; A2: Integer); virtual;  { +08C draft }
    function vmt90(A1: Integer): Integer; virtual;  { +090 draft }
    function vmt94(A1: Integer): Integer; virtual;  { +094 draft }
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure HeroResourceComboBoxChange;  { draft }
    procedure EditFaceBtnClick;  { draft }
    procedure PreviewImagePanelDraw(A1: Integer; A2: Integer);  { draft }
    procedure OKBtnClick;  { draft }
    procedure ResetBtnClick;  { draft }
    procedure HeroLevelEditChange;  { draft }
    procedure AttackEditChange;  { draft }
    procedure DefenseEditChange;  { draft }
    procedure ResistanceEditChange;  { draft }
    procedure DamageEditChange;  { draft }
    procedure HitsEditChange;  { draft }
    procedure MovesEditChange;  { draft }
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure AvailableAbBoxClick;  { draft }
    procedure SelectedAbBoxClick;  { draft }
    procedure AddItemBtnClick;  { draft }
    procedure DeleteItemBtnClick;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure NicknameEditChange;  { draft }
    procedure NameEditChange;  { draft }
    procedure ItemGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure BodyGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure BodyGridDblClick;  { draft }
    procedure ItemGridDblClick;  { draft }
    procedure SphereEditChange(A1: Integer; A2: Integer);  { draft }
  end;


implementation

procedure THeroEditForm.vmt80;
begin end;

procedure THeroEditForm.vmt84;
begin end;

procedure THeroEditForm.vmt88(A1: Integer; A2: Integer);
begin end;

procedure THeroEditForm.vmt8C(A1: Integer; A2: Integer);
begin end;

function THeroEditForm.vmt90(A1: Integer): Integer;
begin Result := 0; end;

function THeroEditForm.vmt94(A1: Integer): Integer;
begin Result := 0; end;

procedure THeroEditForm.FormCreate;
begin end;

procedure THeroEditForm.FormDestroy;
begin end;

procedure THeroEditForm.HeroResourceComboBoxChange;
begin end;

procedure THeroEditForm.EditFaceBtnClick;
begin end;

procedure THeroEditForm.PreviewImagePanelDraw(A1: Integer; A2: Integer);
begin end;

procedure THeroEditForm.OKBtnClick;
begin end;

procedure THeroEditForm.ResetBtnClick;
begin end;

procedure THeroEditForm.HeroLevelEditChange;
begin end;

procedure THeroEditForm.AttackEditChange;
begin end;

procedure THeroEditForm.DefenseEditChange;
begin end;

procedure THeroEditForm.ResistanceEditChange;
begin end;

procedure THeroEditForm.DamageEditChange;
begin end;

procedure THeroEditForm.HitsEditChange;
begin end;

procedure THeroEditForm.MovesEditChange;
begin end;

procedure THeroEditForm.AddBtnClick;
begin end;

procedure THeroEditForm.DeleteBtnClick;
begin end;

procedure THeroEditForm.AvailableAbBoxClick;
begin end;

procedure THeroEditForm.SelectedAbBoxClick;
begin end;

procedure THeroEditForm.AddItemBtnClick;
begin end;

procedure THeroEditForm.DeleteItemBtnClick;
begin end;

procedure THeroEditForm.MainPageControlChange;
begin end;

procedure THeroEditForm.NicknameEditChange;
begin end;

procedure THeroEditForm.NameEditChange;
begin end;

procedure THeroEditForm.ItemGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THeroEditForm.BodyGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THeroEditForm.BodyGridDblClick;
begin end;

procedure THeroEditForm.ItemGridDblClick;
begin end;

procedure THeroEditForm.SphereEditChange(A1: Integer; A2: Integer);
begin end;


end.
