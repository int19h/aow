unit ETutorialMessageEvent;

{ Draft declarations of ETutorialMessageEvent, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EFlagEvent;

type
  TTutorialMessageEventEditForm = class;
  TTutorialMessageEventEditor = class;


  { TTutorialMessageEventEditForm (instance size 552, VMT 0041F624) }
  TTutorialMessageEventEditForm = class(TFlagEventEditForm)
  public
    published
    MessageSheet: TTabSheet; { +0220 }
    MessageMemo: TMemo; { +0224 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;

  { TTutorialMessageEventEditor (instance size 8, VMT 0041F7B8) }
  TTutorialMessageEventEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TTutorialMessageEventEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TTutorialMessageEventEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TTutorialMessageEventEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TTutorialMessageEventEditForm.FormCreate;
begin end;

procedure TTutorialMessageEventEditForm.OKBtnClick(A1: Integer);
begin end;


end.
