unit EFlagMsgEvent;

{ Draft declarations of EFlagMsgEvent, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EFlagEvent;

type
  TFlagMessageEventEditForm = class;
  TFlagMessageEventEditor = class;


  { TFlagMessageEventEditForm (instance size 564, VMT 0041F9C0) }
  TFlagMessageEventEditForm = class(TFlagEventEditForm)
  public
    published
    MessageSheet: TTabSheet; { +0220 }
    MessageMemo: TMemo; { +0224 }
    MessageLbl: TLabel; { +0228 }
    TitleLbl: TLabel; { +022C }
    TitleEdit: TEdit; { +0230 }
    public
    procedure FormCreate;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
  end;

  { TFlagMessageEventEditor (instance size 8, VMT 0041FB7C) }
  TFlagMessageEventEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TFlagMessageEventEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TFlagMessageEventEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TFlagMessageEventEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TFlagMessageEventEditForm.FormCreate;
begin end;

procedure TFlagMessageEventEditForm.OKBtnClick(A1: Integer);
begin end;


end.
