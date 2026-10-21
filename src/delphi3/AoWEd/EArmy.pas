unit EArmy;

{ Draft declarations of EArmy, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EAoWMO, PlayerBox, UnitGrid;

type
  TArmyEditForm = class;
  TArmyHSEditor = class;
  TArmyPlaceControl = class;


  { TArmyEditForm (instance size 596, VMT 004198F8) }
  TArmyEditForm = class(TAoWMapObjEditForm)
  public
    published
    GroupBox1: TGroupBox; { +0210 }
    UnitGrid: TUnitGrid; { +0214 }
    AddBtn: TButton; { +0218 }
    DeleteBtn: TButton; { +021C }
    EditBtn: TButton; { +0220 }
    GroupBox2: TGroupBox; { +0224 }
    Dir1: TRadioButton; { +0228 }
    Dir6: TRadioButton; { +022C }
    Dir2: TRadioButton; { +0230 }
    Dir5: TRadioButton; { +0234 }
    Dir3: TRadioButton; { +0238 }
    Dir4: TRadioButton; { +023C }
    Label1: TLabel; { +0240 }
    PlayerComboBox: TPlayerComboBox; { +0244 }
    BehaviourPanel: TPanel; { +0248 }
    BehaviourComboBox: TComboBox; { +024C }
    public
    F_ArmyEditForm_250: Integer;
    procedure FormCreate(A1: Integer; A2: Integer);  { draft }
    procedure CloseBtnClick;  { draft }
    procedure PlayerComboBoxChange;  { draft }
    procedure BehaviourComboBoxChange;  { draft }
    procedure FormShow;  { draft }
    procedure FormDestroy;  { draft }
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure UnitGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure EditBtnClick;  { draft }
    procedure UnitGridDblClick;  { draft }
    procedure DirectionChanged;  { draft }
  end;

  { TArmyHSEditor (instance size 8, VMT 00419C18) }
  TArmyHSEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;

  { TArmyPlaceControl (instance size 8, VMT 00419CC4) }
  TArmyPlaceControl = class(TEObject)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;


implementation

class function TArmyHSEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TArmyHSEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TArmyHSEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TArmyEditForm.FormCreate(A1: Integer; A2: Integer);
begin end;

procedure TArmyEditForm.CloseBtnClick;
begin end;

procedure TArmyEditForm.PlayerComboBoxChange;
begin end;

procedure TArmyEditForm.BehaviourComboBoxChange;
begin end;

procedure TArmyEditForm.FormShow;
begin end;

procedure TArmyEditForm.FormDestroy;
begin end;

procedure TArmyEditForm.AddBtnClick;
begin end;

procedure TArmyEditForm.DeleteBtnClick;
begin end;

procedure TArmyEditForm.UnitGridSelectCell(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TArmyEditForm.EditBtnClick;
begin end;

procedure TArmyEditForm.UnitGridDblClick;
begin end;

procedure TArmyEditForm.DirectionChanged;
begin end;

procedure TArmyPlaceControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;


end.
