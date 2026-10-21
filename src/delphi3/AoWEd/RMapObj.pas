unit RMapObj;

{ Draft declarations of RMapObj, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, ILTools, SpinEdit, TerCBox;

type
  TMapObjectResourceEditForm = class;
  TMapObjectResourceEditor = class;


  { TMapObjectResourceEditForm (instance size 804, VMT 004037F0) }
  TMapObjectResourceEditForm = class(TForm)
  public
    published
    BottomPanel: TPanel; { +01DC }
    CloseBtn: TButton; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    BottomBevel: TBevel; { +01E8 }
    MainPageControl: TPageControl; { +01EC }
    SettingsSheet: TTabSheet; { +01F0 }
    SettingsPanel: TPanel; { +01F4 }
    SettingsWindowsDC: TWindows16DC; { +01F8 }
    Panel5: TPanel; { +01FC }
    Panel3: TPanel; { +0200 }
    Label3: TLabel; { +0204 }
    LevelBox: TComboBox; { +0208 }
    AnimationPanel: TPanel; { +020C }
    ComplexBox: TCheckBox; { +0210 }
    AniSheet: TTabSheet; { +0214 }
    OpenILDlg: TOpenDialog; { +0218 }
    TerrainPanel: TPanel; { +021C }
    Label1: TLabel; { +0220 }
    TerrainComboBox: TTerrainComboBox; { +0224 }
    OverlayTerrainPanel: TPanel; { +0228 }
    Label2: TLabel; { +022C }
    OverlayComboBox: TTerrainComboBox; { +0230 }
    LoadPanel: TPanel; { +0234 }
    LoadImageSetBtn: TButton; { +0238 }
    Panel2: TPanel; { +023C }
    Label6: TLabel; { +0240 }
    Label7: TLabel; { +0244 }
    MORComboBox: TComboBox; { +0248 }
    NameEdit: TEdit; { +024C }
    Panel1: TPanel; { +0250 }
    Display: TDisplay; { +0254 }
    ImageLibraryGrid: TImageLibraryGrid; { +0258 }
    Panel4: TPanel; { +025C }
    Panel7: TPanel; { +0260 }
    Panel8: TPanel; { +0264 }
    ImageIndexSelector: TDrawGrid; { +0268 }
    OpenLayerBtn: TSpeedButton; { +026C }
    CloseLayerBtn: TSpeedButton; { +0270 }
    PreviewImagePanel: TPanel; { +0274 }
    Label8: TLabel; { +0278 }
    PreviewFramesEdit: TEdit; { +027C }
    Panel9: TPanel; { +0280 }
    Label9: TLabel; { +0284 }
    ResourceIDEdit: TEdit; { +0288 }
    Windows16DC1: TWindows16DC; { +028C }
    ImageSequencer: TImageSequencer; { +0290 }
    Windows16DC2: TWindows16DC; { +0294 }
    SequenceLayerSelector: TSequenceLayerSelector; { +0298 }
    PreviewILGrid: TImageLibraryGrid; { +029C }
    Panel6: TPanel; { +02A0 }
    AniSettingsBox: TGroupBox; { +02A4 }
    Label4: TLabel; { +02A8 }
    Label5: TLabel; { +02AC }
    SequenceSpeedBox: TComboBox; { +02B0 }
    SequenceModeBox: TComboBox; { +02B4 }
    GroupBox1: TGroupBox; { +02B8 }
    FrameTableEdit: TEdit; { +02BC }
    GroupBox3: TGroupBox; { +02C0 }
    LayerSpin: TSpin; { +02C4 }
    SequenceDisplayEditor: TSequenceDisplayEditor; { +02C8 }
    PlayModeBox: TGroupBox; { +02CC }
    PlayLooped: TCheckBox; { +02D0 }
    PlayBtn: TButton; { +02D4 }
    ILPanelLarge: TPanel; { +02D8 }
    ILManagerComboBox: TILManagerComboBox; { +02DC }
    ImageLibraryLabel: TLabel; { +02E0 }
    BKColorLabel: TLabel; { +02E4 }
    ChangeBKColor: TButton; { +02E8 }
    ColorDialog: TColorDialog; { +02EC }
    public
    F_MapObjectResourceEditForm_2F0: array[0..7] of Byte;
    F_MapObjectResourceEditForm_2F8: Integer;
    F_MapObjectResourceEditForm_2FC: Integer;
    F_MapObjectResourceEditForm_300: Integer;
    F_MapObjectResourceEditForm_304: Integer;
    F_MapObjectResourceEditForm_308: Integer;
    F_MapObjectResourceEditForm_30C: array[0..3] of Byte;
    F_MapObjectResourceEditForm_310: Integer;
    F_MapObjectResourceEditForm_314: Integer;
    F_MapObjectResourceEditForm_318: Byte;
    F_MapObjectResourceEditForm_319: array[0..2] of Byte;
    F_MapObjectResourceEditForm_31C: Integer;
    F_MapObjectResourceEditForm_320: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure WndProc(var Message: TMessage); override;
    procedure vmt80; virtual;  { +080 draft }
    procedure vmt84; virtual;  { +084 draft }
    procedure vmt88(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +088 draft }
    procedure vmt8C(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +08C draft }
    procedure vmt90(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +090 draft }
    function vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; virtual;  { +094 draft }
    procedure FormCreate;  { draft }
    procedure FormClose(A1: Integer; A2: Integer);  { draft }
    procedure CloseBtnClick;  { draft }
    procedure CancelBtnClick;  { draft }
    procedure MORComboBoxChange;  { draft }
    procedure ComplexBoxClick;  { draft }
    procedure TerrainComboBoxChange;  { draft }
    procedure OverlayComboBoxChange;  { draft }
    procedure LevelBoxChange;  { draft }
    procedure NameEditChange;  { draft }
    procedure LoadImageSetBtnClick;  { draft }
    procedure ImageIndexSelectorDrawCell(A1: Integer; A2: Integer);  { draft }
    procedure PreviewFramesEditChange;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DisplayUpdateFrame(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure FrameTableEditChange;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure ImageSequencerChange;  { draft }
    procedure ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);  { draft }
    procedure LayerSpinUpdate;  { draft }
    procedure SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SequenceDisplayEditorUpdateFrame(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SequenceModeBoxChange;  { draft }
    procedure SequenceSpeedBoxChange;  { draft }
    procedure SequenceDisplayEditorActivateDC;  { draft }
    procedure OpenLayerBtnClick;  { draft }
    procedure CloseLayerBtnClick;  { draft }
    procedure ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlayBtnClick;  { draft }
    procedure PlayLoopedClick;  { draft }
    procedure ChangeBKColorClick;  { draft }
    procedure ExEditClick;  { draft }
    procedure ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ResourceIDEditChange;  { draft }
  end;

  { TMapObjectResourceEditor (instance size 8, VMT 00404200) }
  TMapObjectResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TMapObjectResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TMapObjectResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

constructor TMapObjectResourceEditForm.Create(AOwner: Classes.TComponent);
begin end;

function TMapObjectResourceEditForm.vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

destructor TMapObjectResourceEditForm.Destroy;
begin end;

procedure TMapObjectResourceEditForm.vmt80;
begin end;

procedure TMapObjectResourceEditForm.FormCreate;
begin end;

procedure TMapObjectResourceEditForm.WndProc(var Message: TMessage);
begin end;

procedure TMapObjectResourceEditForm.FormClose(A1: Integer; A2: Integer);
begin end;

procedure TMapObjectResourceEditForm.CloseBtnClick;
begin end;

procedure TMapObjectResourceEditForm.CancelBtnClick;
begin end;

procedure TMapObjectResourceEditForm.MORComboBoxChange;
begin end;

procedure TMapObjectResourceEditForm.vmt84;
begin end;

procedure TMapObjectResourceEditForm.vmt88(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapObjectResourceEditForm.vmt8C(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapObjectResourceEditForm.vmt90(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapObjectResourceEditForm.ComplexBoxClick;
begin end;

procedure TMapObjectResourceEditForm.TerrainComboBoxChange;
begin end;

procedure TMapObjectResourceEditForm.OverlayComboBoxChange;
begin end;

procedure TMapObjectResourceEditForm.LevelBoxChange;
begin end;

procedure TMapObjectResourceEditForm.NameEditChange;
begin end;

procedure TMapObjectResourceEditForm.LoadImageSetBtnClick;
begin end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorDrawCell(A1: Integer; A2: Integer);
begin end;

procedure TMapObjectResourceEditForm.PreviewFramesEditChange;
begin end;

procedure TMapObjectResourceEditForm.MainPageControlChange;
begin end;

procedure TMapObjectResourceEditForm.DisplayKeyDown(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMapObjectResourceEditForm.DisplayUpdateFrame(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMapObjectResourceEditForm.FrameTableEditChange;
begin end;

procedure TMapObjectResourceEditForm.ILManagerComboBoxChange;
begin end;

procedure TMapObjectResourceEditForm.ImageSequencerChange;
begin end;

procedure TMapObjectResourceEditForm.ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);
begin end;

procedure TMapObjectResourceEditForm.LayerSpinUpdate;
begin end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorUpdateFrame(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMapObjectResourceEditForm.SequenceModeBoxChange;
begin end;

procedure TMapObjectResourceEditForm.SequenceSpeedBoxChange;
begin end;

procedure TMapObjectResourceEditForm.SequenceDisplayEditorActivateDC;
begin end;

procedure TMapObjectResourceEditForm.OpenLayerBtnClick;
begin end;

procedure TMapObjectResourceEditForm.CloseLayerBtnClick;
begin end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMapObjectResourceEditForm.PlayBtnClick;
begin end;

procedure TMapObjectResourceEditForm.PlayLoopedClick;
begin end;

procedure TMapObjectResourceEditForm.ChangeBKColorClick;
begin end;

procedure TMapObjectResourceEditForm.ExEditClick;
begin end;

procedure TMapObjectResourceEditForm.ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TMapObjectResourceEditForm.ResourceIDEditChange;
begin end;


end.
