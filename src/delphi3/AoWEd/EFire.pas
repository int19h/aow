unit EFire;

{ Draft declarations of EFire, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO;

type
  TFireEditForm = class;
  TFireEditor = class;


  { TFireEditForm (instance size 536, VMT 0041D060) }
  TFireEditForm = class(TAoWMapObjEditForm)
  public
    published
    DaysActiveEdit: TComboBox; { +0210 }
    Label1: TLabel; { +0214 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick;  { draft }
  end;

  { TFireEditor (instance size 8, VMT 0041D1C0) }
  TFireEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TFireEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TFireEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TFireEditForm.FormCreate;
begin end;

procedure TFireEditForm.OKBtnClick;
begin end;


end.
