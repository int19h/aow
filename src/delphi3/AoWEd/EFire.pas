unit EFire;

{ Draft declarations of EFire, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TFireEditForm $218 bytes, inherited $20C FMapObject. }

{$R+,Q+}

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
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;

  { TFireEditor (instance size 8, VMT 0041D1C0) }
  TFireEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TFireEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TFireEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin Handled := Handled + [emEdit]; end;

procedure TFireEditForm.FormCreate(Sender: TObject);
var
  Days: Shortint;
begin
  Days := TFire(FMapObject).FTurnsLeft;
  if Days = 0 then DaysActiveEdit.ItemIndex := 0
  else DaysActiveEdit.Text := IntToStr(Days);
end;

procedure TFireEditForm.OKBtnClick(Sender: TObject);
begin
  inherited OKBtnClick(Sender);
  try
    TFire(FMapObject).FTurnsLeft := StrToInt(DaysActiveEdit.Text);
  except
    TFire(FMapObject).FTurnsLeft := 0;
  end;
end;


class function TFireEditor.EditorClassID: Integer;
begin Result := $2077E; end;

end.
