unit RHexagon;

{ Draft declarations of RHexagon, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMapObj;

type
  THexagonResourceEditForm = class;
  THexagonResourceEditor = class;


  { THexagonResourceEditForm (instance size 804, VMT 00407908) }
  THexagonResourceEditForm = class(TMapObjectResourceEditForm)
  public
    procedure FormCreate;  { draft }
  end;

  { THexagonResourceEditor (instance size 8, VMT 00407A40) }
  THexagonResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdateMultiPopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu; Objects: Engine.TEObjectList); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function THexagonResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure THexagonResourceEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

class procedure THexagonResourceEditor.UpdateMultiPopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu; Objects: Engine.TEObjectList);
begin end;

class procedure THexagonResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure THexagonResourceEditForm.FormCreate;
begin end;


end.
