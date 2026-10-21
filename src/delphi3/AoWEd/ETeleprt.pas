unit ETeleprt;

{ Draft declarations of ETeleprt, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, SpinEdit;

type
  TTeleportEditForm = class;
  TTeleportEditor = class;


  { TTeleportEditForm (instance size 568, VMT 0041944C) }
  TTeleportEditForm = class(TAoWMapObjEditForm)
  public
    published
    GroupBox1: TGroupBox; { +0210 }
    Label1: TLabel; { +0214 }
    Label2: TLabel; { +0218 }
    Label3: TLabel; { +021C }
    XtoEdit: TSpin; { +0220 }
    YtoEdit: TSpin; { +0224 }
    LtoEdit: TSpin; { +0228 }
    Panel3: TPanel; { +022C }
    BorderPanel: TDrawPanel; { +0230 }
    RazedCB: TCheckBox; { +0234 }
    public
    procedure FormCreate;  { draft }
    procedure BorderPanelDraw(A1: Integer; A2: Integer);  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;

  { TTeleportEditor (instance size 8, VMT 00419648) }
  TTeleportEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TTeleportEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TTeleportEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TTeleportEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TTeleportEditForm.FormCreate;
begin end;

procedure TTeleportEditForm.BorderPanelDraw(A1: Integer; A2: Integer);
begin end;

procedure TTeleportEditForm.OKBtnClick(A1: Integer);
begin end;


end.
