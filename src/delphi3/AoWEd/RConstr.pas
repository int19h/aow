unit RConstr;

{ Draft declarations of RConstr, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Buttons, RMultiHx, SpinEdit, UnitIGrd;

type
  TConstructionResourceEditForm = class;
  TConstructionResourceEditor = class;


  { TConstructionResourceEditForm (instance size 888, VMT 00408A78) }
  TConstructionResourceEditForm = class(TMultiHexResourceEditForm)
  public
    published
    TabSheet1: TTabSheet; { +033C }
    SelectSampleBox: TGroupBox; { +0340 }
    SFXManagerBox: TSFXManagerComboBox; { +0344 }
    LoopBox: TCheckBox; { +0348 }
    PlaySample: TSpeedButton; { +034C }
    Label10: TLabel; { +0350 }
    DescriptionSheet: TTabSheet; { +0354 }
    DescriptionMemo: TMemo; { +0358 }
    CombatTerrainTagPanel: TPanel; { +035C }
    CTTLabel: TLabel; { +0360 }
    CombatTerrainTagEdit: TSpin; { +0364 }
    RazeDefendersSheet: TTabSheet; { +0368 }
    RazeDefendersGrid: TUnitIndexGrid; { +036C }
    AddRazeDefender: TButton; { +0370 }
    DeleteRazeDefender: TButton; { +0374 }
    public
    function vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer; override;
    procedure vmt98(A1: Integer); override;
    function vmt9C(A1: Integer): Integer; override;
    procedure LoopBoxClick;  { draft }
    procedure PlaySampleClick;  { draft }
    procedure SFXManagerBoxChange;  { draft }
    procedure CloseBtnClick(A1: Integer);  { draft }
    procedure CombatTerrainTagEditChange;  { draft }
    procedure AddRazeDefenderClick;  { draft }
    procedure DeleteRazeDefenderClick;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure FormHide;  { draft }
  end;

  { TConstructionResourceEditor (instance size 8, VMT 00408DFC) }
  TConstructionResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TConstructionResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TConstructionResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

function TConstructionResourceEditForm.vmt94(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer): Integer;
begin Result := 0; end;

procedure TConstructionResourceEditForm.vmt98(A1: Integer);
begin end;

function TConstructionResourceEditForm.vmt9C(A1: Integer): Integer;
begin Result := 0; end;

procedure TConstructionResourceEditForm.LoopBoxClick;
begin end;

procedure TConstructionResourceEditForm.PlaySampleClick;
begin end;

procedure TConstructionResourceEditForm.SFXManagerBoxChange;
begin end;

procedure TConstructionResourceEditForm.CloseBtnClick(A1: Integer);
begin end;

procedure TConstructionResourceEditForm.CombatTerrainTagEditChange;
begin end;

procedure TConstructionResourceEditForm.AddRazeDefenderClick;
begin end;

procedure TConstructionResourceEditForm.DeleteRazeDefenderClick;
begin end;

procedure TConstructionResourceEditForm.MainPageControlChange;
begin end;

procedure TConstructionResourceEditForm.FormHide;
begin end;


end.
