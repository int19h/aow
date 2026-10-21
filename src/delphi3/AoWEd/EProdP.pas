unit EProdP;

{ Draft declarations of EProdP, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EConstr;

type
  TProductionPlaceEditForm = class;
  TProductionPlaceEditor = class;


  { TProductionPlaceEditForm (instance size 568, VMT 0041D6EC) }
  TProductionPlaceEditForm = class(TPlayerConstructionEditForm)
  public
    published
    DefendersModeBox: TComboBox; { +0230 }
    Label2: TLabel; { +0234 }
    public
    procedure FormCreate;  { draft }
    procedure PlayerComboBoxChange;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;

  { TProductionPlaceEditor (instance size 8, VMT 0041D880) }
  TProductionPlaceEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TProductionPlaceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TProductionPlaceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TProductionPlaceEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TProductionPlaceEditForm.FormCreate;
begin end;

procedure TProductionPlaceEditForm.PlayerComboBoxChange;
begin end;

procedure TProductionPlaceEditForm.OKBtnClick(A1: Integer);
begin end;


end.
