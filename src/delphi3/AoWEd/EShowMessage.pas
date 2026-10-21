unit EShowMessage;

{ Draft declarations of EShowMessage, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TShowMessageEditForm edits the inherited $20C map object. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, MoveOnEvents, AoWE, EMoveOnEvent;

type
  TShowMessageEditForm = class;
  TShowMessageEditor = class;


  { TShowMessageEditForm (instance size 556, VMT 0041EADC) }
  TShowMessageEditForm = class(TMoveOnEventForm)
  public
    published
    TextSheet: TTabSheet; { +0224 }
    MessageMemo: TMemo; { +0228 }
    public
    procedure OKBtnClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  end;

  { TShowMessageEditor (instance size 8, VMT 0041EC50) }
  TShowMessageEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TShowMessageEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TShowMessageEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TShowMessageEditForm.OKBtnClick(Sender: TObject);
begin
  TShowMessageMoveOnEvent(FMapObject).FMessage.Text := MessageMemo.Text;
  inherited OKBtnClick(Sender);
end;

procedure TShowMessageEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  MessageMemo.Lines.Text := TShowMessageMoveOnEvent(FMapObject).FMessage.Text;
end;


end.
