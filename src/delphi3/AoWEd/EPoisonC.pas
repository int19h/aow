unit EPoisonC;

{ Draft declarations of EPoisonC, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Poison cloud settings use inherited $20C FMapObject. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, PoisonC;

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
    published procedure FormCreate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;

  { TPoisonCloudEditor (instance size 8, VMT 0041E008) }
  TPoisonCloudEditor = class(TAoWMapObjectEditor)
  public class function EditorClassID: Integer; override;
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

procedure TPoisonCloudEditForm.FormCreate(Sender: TObject);
begin
  if TPoisonCloud(FMapObject).FTurnsRemaining = 0 then DaysActiveEdit.ItemIndex := 0
  else DaysActiveEdit.Text := IntToStr(TPoisonCloud(FMapObject).FTurnsRemaining);
  MoveableCheck.Checked := TPoisonCloud(FMapObject).FDrifting;
end;

procedure TPoisonCloudEditForm.OKBtnClick(Sender: TObject);
begin
  inherited OKBtnClick(Sender);
  try
    TPoisonCloud(FMapObject).FTurnsRemaining := StrToInt(DaysActiveEdit.Text);
  except
    TPoisonCloud(FMapObject).FTurnsRemaining := 0;
  end;
  TPoisonCloud(FMapObject).FDrifting := MoveableCheck.Checked;
end;

class function TPoisonCloudEditor.EditorClassID: Integer;
begin Result := $2123F; end;

end.
