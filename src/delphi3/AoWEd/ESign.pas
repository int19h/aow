unit ESign;

{ Draft declarations of ESign, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Sign text uses TSign at inherited $20C FMapObject. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO;

type
  TSignEditForm = class;
  TSignEditor = class;


  { TSignEditForm (instance size 536, VMT 00418124) }
  TSignEditForm = class(TAoWMapObjEditForm)
  public
    published
    Label1: TLabel; { +0210 }
    SignText: TMemo; { +0214 }
    public
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;

  { TSignEditor (instance size 8, VMT 00418280) }
  TSignEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses Sign;

class procedure TSignEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TSignEditForm.vmt90(Obj, Done);
end;

class procedure TSignEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TSignEditForm.FormCreate(Sender: TObject);
begin
  SignText.Lines.Text := TSign(FMapObject).FText.Text;
end;

procedure TSignEditForm.OKBtnClick(Sender: TObject);
begin
  TSign(FMapObject).FText.Text := SignText.Lines.Text;
  inherited OKBtnClick(Sender);
end;

class function TSignEditor.EditorClassID: Integer;
begin Result := $20102; end;

end.
