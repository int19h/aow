unit EUnitGFX;

{ Draft declarations of EUnitGFX, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWREFrm, Buttons, ILTools, SpinEdit;

type
  { Declaration-only field type from Vcladdon.dpl (instance size 516). }
  TEditStringGrid = class(TStringGrid)
  private
    F_External: array[0..15] of Byte;
  end;

  TUnitGFXResourceEditForm = class;
  TUnitGFXResourceEditor = class;


  { TUnitGFXResourceEditForm (instance size 764, VMT 0040E2F8) }
  TUnitGFXResourceEditForm = class(TAoWResourceEditForm)
  public
    published
    Panel2: TPanel; { +01FC }
    Windows16DC1: TWindows16DC; { +0200 }
    Panel3: TPanel; { +0204 }
    UnitGFXNameEdit: TEdit; { +0208 }
    PageControl1: TPageControl; { +020C }
    FramesSheet: TTabSheet; { +0210 }
    FaceSheet: TTabSheet; { +0214 }
    Panel4: TPanel; { +0218 }
    Panel5: TPanel; { +021C }
    Panel8: TPanel; { +0220 }
    OpenLayerBtn: TSpeedButton; { +0224 }
    CloseLayerBtn: TSpeedButton; { +0228 }
    ImageIndexSelector: TEditStringGrid; { +022C }
    GroupBox4: TGroupBox; { +0230 }
    FaceImagePanel: TImageLibraryPanel; { +0234 }
    FaceImageLibraryPreviewGrid: TImageLibraryGrid; { +0238 }
    FaceILManagerComboBox: TILManagerComboBox; { +023C }
    FaceIndexSpin: TSpin; { +0240 }
    Label1: TLabel; { +0244 }
    Label2: TLabel; { +0248 }
    ImageSequencer: TImageSequencer; { +024C }
    Windows16DC2: TWindows16DC; { +0250 }
    SequenceLayerSelector: TSequenceLayerSelector; { +0254 }
    PreviewILGrid: TImageLibraryGrid; { +0258 }
    Panel6: TPanel; { +025C }
    AniSettingsBox: TGroupBox; { +0260 }
    Label4: TLabel; { +0264 }
    Label5: TLabel; { +0268 }
    SequenceSpeedBox: TComboBox; { +026C }
    SequenceModeBox: TComboBox; { +0270 }
    GroupBox1: TGroupBox; { +0274 }
    FrameTableEdit: TEdit; { +0278 }
    GroupBox2: TGroupBox; { +027C }
    ILManagerComboBox: TILManagerComboBox; { +0280 }
    GroupBox3: TGroupBox; { +0284 }
    LayerSpin: TSpin; { +0288 }
    GenerateBtn: TButton; { +028C }
    SFXSheet: TTabSheet; { +0290 }
    GroupBox5: TGroupBox; { +0294 }
    PlayHitSample: TSpeedButton; { +0298 }
    Panel7: TPanel; { +029C }
    Panel9: TPanel; { +02A0 }
    Panel10: TPanel; { +02A4 }
    SequenceDisplayEditor: TSequenceDisplayEditor; { +02A8 }
    GroupBox6: TGroupBox; { +02AC }
    MoveSpeedBox: TComboBox; { +02B0 }
    GroupBox8: TGroupBox; { +02B4 }
    SpeedButton1: TSpeedButton; { +02B8 }
    GroupBox9: TGroupBox; { +02BC }
    SpeedButton2: TSpeedButton; { +02C0 }
    GroupBox10: TGroupBox; { +02C4 }
    SpeedButton3: TSpeedButton; { +02C8 }
    EditStandstillSFX: TButton; { +02CC }
    EditMoveSFX: TButton; { +02D0 }
    EditMeleeSFX: TButton; { +02D4 }
    EditDieSFX: TButton; { +02D8 }
    GroupBox7: TGroupBox; { +02DC }
    SpeedButton4: TSpeedButton; { +02E0 }
    Button1: TButton; { +02E4 }
    GroupBox11: TGroupBox; { +02E8 }
    Label3: TLabel; { +02EC }
    ChangeColor: TButton; { +02F0 }
    ColorDialog: TColorDialog; { +02F4 }
    public
    F_UnitGFXResourceEditForm_2F8: Integer;
    destructor Destroy; override;
    procedure FormCreate;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure LayerSpinUpdate;  { draft }
    procedure SequenceModeBoxChange;  { draft }
    procedure SequenceSpeedBoxChange;  { draft }
    procedure FrameTableEditChange;  { draft }
    procedure ImageSequencerChange;  { draft }
    procedure OpenLayerBtnClick;  { draft }
    procedure CloseLayerBtnClick;  { draft }
    procedure ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure SequenceDisplayEditorStartUpdateFrame(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);  { draft }
    procedure UnitGFXNameEditChange;  { draft }
    procedure FaceIndexSpinUpdate;  { draft }
    procedure FaceILManagerComboBoxChange;  { draft }
    procedure GenerateBtnClick;  { draft }
    procedure MoveSpeedBoxChange;  { draft }
    procedure SequenceDisplayEditorShowImageSequence(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure EditStandstillSFXClick;  { draft }
    procedure EditMoveSFXClick;  { draft }
    procedure EditMeleeSFXClick;  { draft }
    procedure EditDieSFXClick;  { draft }
    procedure Button1Click;  { draft }
    procedure ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ChangeColorClick;  { draft }
  end;

  { TUnitGFXResourceEditor (instance size 8, VMT 0040EBC0) }
  TUnitGFXResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TUnitGFXResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TUnitGFXResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

destructor TUnitGFXResourceEditForm.Destroy;
begin end;

procedure TUnitGFXResourceEditForm.FormCreate;
begin end;

procedure TUnitGFXResourceEditForm.ILManagerComboBoxChange;
begin end;

procedure TUnitGFXResourceEditForm.LayerSpinUpdate;
begin end;

procedure TUnitGFXResourceEditForm.SequenceModeBoxChange;
begin end;

procedure TUnitGFXResourceEditForm.SequenceSpeedBoxChange;
begin end;

procedure TUnitGFXResourceEditForm.FrameTableEditChange;
begin end;

procedure TUnitGFXResourceEditForm.ImageSequencerChange;
begin end;

procedure TUnitGFXResourceEditForm.OpenLayerBtnClick;
begin end;

procedure TUnitGFXResourceEditForm.CloseLayerBtnClick;
begin end;

procedure TUnitGFXResourceEditForm.ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorStartUpdateFrame(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitGFXResourceEditForm.ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);
begin end;

procedure TUnitGFXResourceEditForm.UnitGFXNameEditChange;
begin end;

procedure TUnitGFXResourceEditForm.FaceIndexSpinUpdate;
begin end;

procedure TUnitGFXResourceEditForm.FaceILManagerComboBoxChange;
begin end;

procedure TUnitGFXResourceEditForm.GenerateBtnClick;
begin end;

procedure TUnitGFXResourceEditForm.MoveSpeedBoxChange;
begin end;

procedure TUnitGFXResourceEditForm.SequenceDisplayEditorShowImageSequence(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TUnitGFXResourceEditForm.EditStandstillSFXClick;
begin end;

procedure TUnitGFXResourceEditForm.EditMoveSFXClick;
begin end;

procedure TUnitGFXResourceEditForm.EditMeleeSFXClick;
begin end;

procedure TUnitGFXResourceEditForm.EditDieSFXClick;
begin end;

procedure TUnitGFXResourceEditForm.Button1Click;
begin end;

procedure TUnitGFXResourceEditForm.ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TUnitGFXResourceEditForm.ChangeColorClick;
begin end;


end.
