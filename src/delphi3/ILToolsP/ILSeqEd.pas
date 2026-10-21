unit ILSeqEd;

{ Draft declarations of ILSeqEd, from ILToolsP.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TImageSequenceEditor = class;


  { TImageSequenceEditor (instance size 616, VMT 5530310C) }
  TImageSequenceEditor = class(TForm)
  public
    F_ImageSequenceEditor_1DC: Integer;
    F_ImageSequenceEditor_1E0: Integer;
    F_ImageSequenceEditor_1E4: Integer;
    F_ImageSequenceEditor_1E8: Integer;
    F_ImageSequenceEditor_1EC: Integer;
    F_ImageSequenceEditor_1F0: Integer;
    F_ImageSequenceEditor_1F4: Integer;
    F_ImageSequenceEditor_1F8: Integer;
    F_ImageSequenceEditor_1FC: Integer;
    F_ImageSequenceEditor_200: Integer;
    F_ImageSequenceEditor_204: Integer;
    F_ImageSequenceEditor_208: Integer;
    F_ImageSequenceEditor_20C: Integer;
    F_ImageSequenceEditor_210: Integer;
    F_ImageSequenceEditor_214: Integer;
    F_ImageSequenceEditor_218: Integer;
    F_ImageSequenceEditor_21C: Integer;
    F_ImageSequenceEditor_220: Integer;
    F_ImageSequenceEditor_224: Integer;
    F_ImageSequenceEditor_228: Integer;
    F_ImageSequenceEditor_22C: Integer;
    F_ImageSequenceEditor_230: Integer;
    F_ImageSequenceEditor_234: Integer;
    F_ImageSequenceEditor_238: Integer;
    F_ImageSequenceEditor_23C: Integer;
    F_ImageSequenceEditor_240: Integer;
    F_ImageSequenceEditor_244: Integer;
    F_ImageSequenceEditor_248: Integer;
    F_ImageSequenceEditor_24C: Integer;
    F_ImageSequenceEditor_250: Integer;
    F_ImageSequenceEditor_254: Integer;
    F_ImageSequenceEditor_258: Integer;
    F_ImageSequenceEditor_25C: Integer;
    F_ImageSequenceEditor_260: Integer;
    F_ImageSequenceEditor_264: Integer;
    function GetImageSequenceList: Integer;  { draft }
    procedure SetImageSequenceList(A1: Integer);  { draft }
    procedure FrameTableEditChange;  { draft }
    procedure ILManagerComboBoxChange;  { draft }
    procedure LayerSpinUpdate;  { draft }
    procedure PlayBtnClick;  { draft }
    procedure PlayLoopedClick;  { draft }
    procedure SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SequenceDisplayEditorUpdateFrame(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SequenceModeBoxChange;  { draft }
    procedure SequenceSpeedBoxChange;  { draft }
    procedure ImageSequencerChange;  { draft }
    procedure ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);  { draft }
    procedure ImageIndexSelectorDrawCell(A1: Integer; A2: Integer);  { draft }
    procedure ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CloseLayerBtnClick;  { draft }
    procedure ImageIndexSelectorDrawCell2(A1: Integer; A2: Integer);  { draft }
    procedure ImageIndexSelectorSelectCell2(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure OpenLayerBtnClick;  { draft }
    procedure FormCreate;  { draft }
    procedure FormDestroy;  { draft }
    procedure SpeedButton2Click;  { draft }
    function ShowModal: Integer;  { draft }
    procedure ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);  { draft }
    procedure ChangeColorClick;  { draft }
  end;


implementation

function TImageSequenceEditor.GetImageSequenceList: Integer;
begin Result := 0; end;

procedure TImageSequenceEditor.SetImageSequenceList(A1: Integer);
begin end;

procedure TImageSequenceEditor.FrameTableEditChange;
begin end;

procedure TImageSequenceEditor.ILManagerComboBoxChange;
begin end;

procedure TImageSequenceEditor.LayerSpinUpdate;
begin end;

procedure TImageSequenceEditor.PlayBtnClick;
begin end;

procedure TImageSequenceEditor.PlayLoopedClick;
begin end;

procedure TImageSequenceEditor.SequenceDisplayEditorResizeBackSurface(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TImageSequenceEditor.SequenceDisplayEditorUpdateFrame(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TImageSequenceEditor.SequenceModeBoxChange;
begin end;

procedure TImageSequenceEditor.SequenceSpeedBoxChange;
begin end;

procedure TImageSequenceEditor.ImageSequencerChange;
begin end;

procedure TImageSequenceEditor.ImageSequencerCreateImageSequence(A1: Integer; A2: Integer);
begin end;

procedure TImageSequenceEditor.ImageIndexSelectorDrawCell(A1: Integer; A2: Integer);
begin end;

procedure TImageSequenceEditor.ImageIndexSelectorSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TImageSequenceEditor.CloseLayerBtnClick;
begin end;

procedure TImageSequenceEditor.ImageIndexSelectorDrawCell2(A1: Integer; A2: Integer);
begin end;

procedure TImageSequenceEditor.ImageIndexSelectorSelectCell2(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TImageSequenceEditor.OpenLayerBtnClick;
begin end;

procedure TImageSequenceEditor.FormCreate;
begin end;

procedure TImageSequenceEditor.FormDestroy;
begin end;

procedure TImageSequenceEditor.SpeedButton2Click;
begin end;

function TImageSequenceEditor.ShowModal: Integer;
begin Result := 0; end;

procedure TImageSequenceEditor.ImageIndexSelectorKeyDown(A1: Integer; A2: Integer);
begin end;

procedure TImageSequenceEditor.ChangeColorClick;
begin end;


initialization
finalization

end.
