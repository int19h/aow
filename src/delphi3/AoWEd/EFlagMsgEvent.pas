unit EFlagMsgEvent;

{ Flag message form, size $234, inherited $20C map object. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EFlagEvent, FlagEvents;

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
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;

  { TFlagMessageEventEditor (instance size 8, VMT 0041FB7C) }
  TFlagMessageEventEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TFlagMessageEventEditor.EditorClassID: Integer;
begin
  Result := $2056D;
end;

class procedure TFlagMessageEventEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TFlagMessageEventEditForm.vmt90(Obj, Done);
end;

class procedure TFlagMessageEventEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TFlagMessageEventEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  MessageMemo.Lines.Text := TFlagMessageEvent(FMapObject).FMessage.Text;
  TitleEdit.Text := TFlagMessageEvent(FMapObject).FHelpFileName;
end;

procedure TFlagMessageEventEditForm.OKBtnClick(Sender: TObject);
begin
  TFlagMessageEvent(FMapObject).FMessage.Text := MessageMemo.Text;
  TFlagMessageEvent(FMapObject).FHelpFileName := TitleEdit.Text;
  inherited OKBtnClick(Sender);
end;


end.
