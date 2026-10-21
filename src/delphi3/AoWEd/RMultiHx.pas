unit RMultiHx;

{ Draft declarations of RMultiHx, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, RMapObj;

type
  TMultiHexResourceEditForm = class;
  TMultiHexResourceEditor = class;


  { TMultiHexResourceEditForm (instance size 828, VMT 00405DD8) }
  TMultiHexResourceEditForm = class(TMapObjectResourceEditForm)
  public
    published
    BtnPanel: TPanel; { +0324 }
    SelectBtn: TSpeedButton; { +0328 }
    DragBtn: TSpeedButton; { +032C }
    MainPBtn: TSpeedButton; { +0330 }
    public
    F_MultiHexResourceEditForm_334: Integer;
    F_MultiHexResourceEditForm_338: Byte;
    F_MultiHexResourceEditForm_339: array[0..2] of Byte;
    procedure vmt88(Index, X, Y: Integer; SD: TSurfaceDesc); override;
    procedure vmt98(A1: Integer); virtual;  { +098 draft }
    function vmt9C(A1: Integer): Integer; virtual;  { +09C draft }
    procedure DisplayUpdateFrame(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure DisplayMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure SelectBtnClick;  { draft }
    procedure DragBtnClick;  { draft }
    procedure MainPBtnClick;  { draft }
    procedure TerrainComboBoxChange;  { draft }
    procedure ComplexBoxClick;  { draft }
  end;

  { TMultiHexResourceEditor (instance size 8, VMT 00406020) }
  TMultiHexResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TMultiHexResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TMultiHexResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

function TMultiHexResourceEditForm.vmt9C(A1: Integer): Integer;
begin Result := 0; end;

procedure TMultiHexResourceEditForm.vmt98(A1: Integer);
begin end;

procedure TMultiHexResourceEditForm.vmt88(Index, X, Y: Integer; SD: TSurfaceDesc);
begin end;

procedure TMultiHexResourceEditForm.DisplayUpdateFrame(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMultiHexResourceEditForm.DisplayMouseDown(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMultiHexResourceEditForm.DisplayMouseMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMultiHexResourceEditForm.DisplayMouseUp(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMultiHexResourceEditForm.SelectBtnClick;
begin end;

procedure TMultiHexResourceEditForm.DragBtnClick;
begin end;

procedure TMultiHexResourceEditForm.MainPBtnClick;
begin end;

procedure TMultiHexResourceEditForm.TerrainComboBoxChange;
begin end;

procedure TMultiHexResourceEditForm.ComplexBoxClick;
begin end;


end.
