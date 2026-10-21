unit EPoisonC;

{ Draft declarations of EPoisonC, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO;

type
  TPoisonCloudEditForm = class;
  TPoisonCloudEditor = class;


  { TPoisonCloudEditForm (instance size 540, VMT 0041DE80) }
  TPoisonCloudEditForm = class(TAoWMapObjEditForm)
  public
    published
    MoveableCheck: TCheckBox; { +0210 }
    DaysActiveEdit: TComboBox; { +0214 }
    Label1: TLabel; { +0218 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
  end;

  { TPoisonCloudEditor (instance size 8, VMT 0041E008) }
  TPoisonCloudEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TPoisonCloudEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TPoisonCloudEditForm.vmt90(Obj, Done);
end;

class procedure TPoisonCloudEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TPoisonCloudEditForm.FormCreate;
begin end;

procedure TPoisonCloudEditForm.OKBtnClick;
begin end;


end.
