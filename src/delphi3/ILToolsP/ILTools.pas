unit ILTools;

{ Draft declarations of ILTools, from ILToolsP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TImageSequencer = class;
  TSequenceLayerSelector = class;
  TSequenceDisplayEditor = class;

  TOnCreateImageSequenceEvent = procedure(ImageSequencer: TImageSequencer; CreatedImageSequence: TImageSequence) of object;
  TOnShowImageSequenceEvent = procedure(ImageSequence: TImageSequence; ImageIndex: Integer; Xshow: Integer; Yshow: Integer; SurfaceDesc: TSurfaceDesc) of object;

  { TImageSequencer (instance size 76, VMT 55301CE4) }
  TImageSequencer = class(TComponent)
  public
    F_ImageSequencer_24: array[0..7] of Byte;
    F_ImageSequencer_2C: Integer;
    F_ImageSequencer_30: array[0..3] of Byte;
    F_ImageSequencer_34: Integer;
    F_ImageSequencer_38: Integer;
    F_ImageSequencer_3C: Integer;
    F_ImageSequencer_40: Integer;
    F_ImageSequencer_44: Byte;
    F_ImageSequencer_45: array[0..2] of Byte;
    F_ImageSequencer_48: Byte;
    F_ImageSequencer_49: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetImageSequenceList(A1: Integer);  { draft }
    procedure CurrentImageSequenceUpdated;  { draft }
    procedure SetCurrentImageSequence(A1: Integer);  { draft }
    procedure SetCurrentSequenceIndex(A1: Integer);  { draft }
    procedure AddSequenceLayer;  { draft }
    procedure DeleteSequenceLayer;  { draft }
    procedure IncreaseLayer;  { draft }
    procedure DecreaseLayer;  { draft }
  end;

  { TSequenceLayerSelector (instance size 324, VMT 55301DFC) }
  TSequenceLayerSelector = class(TTabControl)
  public
    F_SequenceLayerSelector_140: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure SetParent(AParent: Controls.TWinControl); override;
    procedure SetImageSequencer(A1: Integer);  { draft }
    procedure UpdateSettings;  { draft }
    procedure Change; override;
    procedure UpdateTabs;  { draft }
  end;

  { TSequenceDisplayEditor (instance size 480, VMT 55301FC0) }
  TSequenceDisplayEditor = class(TDisplay)
  public
    F_SequenceDisplayEditor_1AC: array[0..27] of Byte;
    F_SequenceDisplayEditor_1C8: Integer;
    F_SequenceDisplayEditor_1CC: Integer;
    F_SequenceDisplayEditor_1D0: Integer;
    F_SequenceDisplayEditor_1D4: array[0..3] of Byte;
    F_SequenceDisplayEditor_1D8: Integer;
    F_SequenceDisplayEditor_1DC: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure ResizeBackSurfaces(AWidth, AHeight: Integer); override;
    procedure UpdateFrame; override;
    procedure SetImageSequencer(A1: Integer);  { draft }
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure UpdateSettings;  { draft }
  end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);  { draft }

implementation

destructor TImageSequencer.Destroy;
begin end;

procedure TImageSequencer.SetImageSequenceList(A1: Integer);
begin end;

procedure TImageSequencer.CurrentImageSequenceUpdated;
begin end;

procedure TImageSequencer.SetCurrentImageSequence(A1: Integer);
begin end;

procedure TImageSequencer.SetCurrentSequenceIndex(A1: Integer);
begin end;

procedure TImageSequencer.AddSequenceLayer;
begin end;

procedure TImageSequencer.DeleteSequenceLayer;
begin end;

procedure TImageSequencer.IncreaseLayer;
begin end;

procedure TImageSequencer.DecreaseLayer;
begin end;

constructor TSequenceDisplayEditor.Create(AOwner: Classes.TComponent);
begin end;

destructor TSequenceDisplayEditor.Destroy;
begin end;

procedure TSequenceDisplayEditor.SetImageSequencer(A1: Integer);
begin end;

procedure TSequenceDisplayEditor.ResizeBackSurfaces(AWidth, AHeight: Integer);
begin end;

procedure TSequenceDisplayEditor.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin end;

procedure TSequenceDisplayEditor.MouseMove(Shift: TShiftState; X, Y: Integer);
begin end;

procedure TSequenceDisplayEditor.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin end;

procedure TSequenceDisplayEditor.UpdateFrame;
begin end;

procedure TSequenceDisplayEditor.UpdateSettings;
begin end;

constructor TSequenceLayerSelector.Create(AOwner: Classes.TComponent);
begin end;

destructor TSequenceLayerSelector.Destroy;
begin end;

procedure TSequenceLayerSelector.SetImageSequencer(A1: Integer);
begin end;

procedure TSequenceLayerSelector.SetParent(AParent: Controls.TWinControl);
begin end;

procedure TSequenceLayerSelector.UpdateSettings;
begin end;

procedure TSequenceLayerSelector.Change;
begin end;

procedure TSequenceLayerSelector.UpdateTabs;
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;


initialization
finalization

end.
