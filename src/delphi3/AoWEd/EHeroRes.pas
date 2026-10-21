unit EHeroRes;

{ Draft declarations of EHeroRes, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AlgnmBox, EAUnitRes, RaceBox, SpinEdit;

type
  THeroResourceEditForm = class;
  THeroResourceEditor = class;


  { THeroResourceEditForm (instance size 688, VMT 00411EDC) }
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
    F_HeroResourceEditForm_2A0: Integer;
    F_HeroResourceEditForm_2A4: Integer;
    F_HeroResourceEditForm_2A8: Integer;
    F_HeroResourceEditForm_2AC: Byte;
    F_HeroResourceEditForm_2AD: array[0..2] of Byte;
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure AbilityBtnClick;  { draft }
    procedure OKBtnClick;  { draft }
    procedure LevelPointsChanged;  { draft }
    procedure SelectFaceBtnClick;  { draft }
    procedure FaceDrawPanelDraw(A1: Integer; A2: Integer);  { draft }
  end;

  { THeroResourceEditor (instance size 8, VMT 004122F8) }
  THeroResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function THeroResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure THeroResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure THeroResourceEditForm.FormCreate;
begin end;

procedure THeroResourceEditForm.FormDestroy;
begin end;

procedure THeroResourceEditForm.AbilityBtnClick;
begin end;

procedure THeroResourceEditForm.OKBtnClick;
begin end;

procedure THeroResourceEditForm.LevelPointsChanged;
begin end;

procedure THeroResourceEditForm.SelectFaceBtnClick;
begin end;

procedure THeroResourceEditForm.FaceDrawPanelDraw(A1: Integer; A2: Integer);
begin end;


end.
