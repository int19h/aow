unit EUnitRes;

{ Draft declarations of EUnitRes, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AlgnmBox, EAUnitRes, RaceBox, SpinEdit;

type
  TUnitResourceEditForm = class;
  TUnitResourceEditor = class;


  { TUnitResourceEditForm (instance size 732, VMT 004107E0) }
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
    F_UnitResourceEditForm_2D4: Integer;
    F_UnitResourceEditForm_2D8: Byte;
    F_UnitResourceEditForm_2D9: array[0..2] of Byte;
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure RaceBoxChange;  { draft }
    procedure AbilityBtnClick;  { draft }
    procedure OKBtnClick;  { draft }
    procedure AbilityRankTabsChange;  { draft }
  end;

  { TUnitResourceEditor (instance size 8, VMT 00410CAC) }
  TUnitResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TUnitResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TUnitResourceEditForm.FormCreate;
begin end;

procedure TUnitResourceEditForm.FormDestroy;
begin end;

procedure TUnitResourceEditForm.RaceBoxChange;
begin end;

procedure TUnitResourceEditForm.AbilityBtnClick;
begin end;

procedure TUnitResourceEditForm.OKBtnClick;
begin end;

procedure TUnitResourceEditForm.AbilityRankTabsChange;
begin end;


end.
