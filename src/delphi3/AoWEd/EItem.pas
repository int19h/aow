unit EItem;

{ Draft declarations of EItem, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Spin, SpinEdit;

type
  TItemEditForm = class;


  { TItemEditForm (instance size 644, VMT 00412D30) }
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
    F_ItemEditForm_27C: Integer;
    F_ItemEditForm_280: array[0..3] of Byte;
    procedure FormCreate(A1: Integer; A2: Integer);  { draft }
    procedure FormDestroy;  { draft }
    procedure EditBtnClick;  { draft }
    procedure PreviewImagePanelDraw(A1: Integer; A2: Integer);  { draft }
    procedure ItemTypeBoxChange;  { draft }
    procedure ItemNameEditChange;  { draft }
    procedure DefenseChange(A1: Integer);  { draft }
    procedure ResistanceChange(A1: Integer);  { draft }
    procedure AttackChange(A1: Integer);  { draft }
    procedure DamageChange(A1: Integer);  { draft }
    procedure AvailabilityBoxChange;  { draft }
    procedure AbilityBtnClick;  { draft }
    procedure DescriptionEditChange;  { draft }
    procedure CostEditChange;  { draft }
    procedure SpellComboBoxChange;  { draft }
  end;


implementation

procedure TItemEditForm.FormCreate(A1: Integer; A2: Integer);
begin end;

procedure TItemEditForm.FormDestroy;
begin end;

procedure TItemEditForm.EditBtnClick;
begin end;

procedure TItemEditForm.PreviewImagePanelDraw(A1: Integer; A2: Integer);
begin end;

procedure TItemEditForm.ItemTypeBoxChange;
begin end;

procedure TItemEditForm.ItemNameEditChange;
begin end;

procedure TItemEditForm.DefenseChange(A1: Integer);
begin end;

procedure TItemEditForm.ResistanceChange(A1: Integer);
begin end;

procedure TItemEditForm.AttackChange(A1: Integer);
begin end;

procedure TItemEditForm.DamageChange(A1: Integer);
begin end;

procedure TItemEditForm.AvailabilityBoxChange;
begin end;

procedure TItemEditForm.AbilityBtnClick;
begin end;

procedure TItemEditForm.DescriptionEditChange;
begin end;

procedure TItemEditForm.CostEditChange;
begin end;

procedure TItemEditForm.SpellComboBoxChange;
begin end;


end.
