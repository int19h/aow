unit ETutorialMessageEvent;

{ Draft declarations of ETutorialMessageEvent, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TTutorialMessageEventEditForm edits the inherited $20C map object. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, FlagEvents, AoWE, EFlagEvent;

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
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  end;

  { TTutorialMessageEventEditor (instance size 8, VMT 0041F7B8) }
  TTutorialMessageEventEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TTutorialMessageEventEditor.EditorClassID: Integer;
begin Result := $2056B; end;

class procedure TTutorialMessageEventEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TTutorialMessageEventEditForm.vmt90(Obj, Done); end;

class procedure TTutorialMessageEventEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TTutorialMessageEventEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  MessageMemo.Lines.Text := TTutorialMessageEvent(FMapObject).FMessage.Text;
end;

procedure TTutorialMessageEventEditForm.OKBtnClick(Sender: TObject);
begin
  TTutorialMessageEvent(FMapObject).FMessage.Text := MessageMemo.Text;
  inherited OKBtnClick(Sender);
end;


end.
