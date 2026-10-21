unit EConstr;

{ Draft declarations of EConstr, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, PlayerBox, checklst;

type
  TPlayerConstructionEditForm = class;
  TPlayerConstructionEditor = class;


  { TPlayerConstructionEditForm (instance size 560, VMT 00418498) }
  TPlayerConstructionEditForm = class(TAoWMapObjEditForm)
  public
    published
    Panel3: TPanel; { +0210 }
    BorderPanel: TDrawPanel; { +0214 }
    PlayerComboBox: TPlayerComboBox; { +0218 }
    Label1: TLabel; { +021C }
    RazedBox: TCheckBox; { +0220 }
    VictorySheet: TTabSheet; { +0224 }
    Memo1: TMemo; { +0228 }
    VictoryListBox: TCheckListBox; { +022C }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure BorderPanelDraw(A1: Integer; A2: Integer);  { draft }
    procedure RazedBoxClick;  { draft }
  end;

  { TPlayerConstructionEditor (instance size 8, VMT 004186BC) }
  TPlayerConstructionEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TPlayerConstructionEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TPlayerConstructionEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TPlayerConstructionEditForm.FormCreate;
begin end;

procedure TPlayerConstructionEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TPlayerConstructionEditForm.BorderPanelDraw(A1: Integer; A2: Integer);
begin end;

procedure TPlayerConstructionEditForm.RazedBoxClick;
begin end;


end.
