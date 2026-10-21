unit ESmokeC;

{ Draft declarations of ESmokeC, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Inherited $20C map object supplies lifetime $18 and drifting flag $1C. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, SmokeCloud, EAoWMO;

type
  TSmokeCloudEditForm = class;
  TSmokeCloudEditor = class;


  { TSmokeCloudEditForm (instance size 540, VMT 0041CC60) }
  TSmokeCloudEditForm = class(TAoWMapObjEditForm)
  public
    published
    MoveableCheck: TCheckBox; { +0210 }
    DaysActiveEdit: TComboBox; { +0214 }
    Label1: TLabel; { +0218 }
    public
    procedure FormCreate(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  end;

  { TSmokeCloudEditor (instance size 8, VMT 0041CDE8) }
  TSmokeCloudEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TSmokeCloudEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TSmokeCloudEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin end;

procedure TSmokeCloudEditForm.FormCreate(Sender: TObject);
begin
  if TSmokeCloud(FMapObject).FTurnsRemaining = 0 then DaysActiveEdit.ItemIndex := 0
  else DaysActiveEdit.Text := IntToStr(TSmokeCloud(FMapObject).FTurnsRemaining);
  MoveableCheck.Checked := TSmokeCloud(FMapObject).FDrifting;
end;


procedure TSmokeCloudEditForm.OKBtnClick(Sender: TObject);
begin
  inherited OKBtnClick(Sender);
  try
    TSmokeCloud(FMapObject).FTurnsRemaining := StrToInt(DaysActiveEdit.Text);
  except
    TSmokeCloud(FMapObject).FTurnsRemaining := 0;
  end;
  TSmokeCloud(FMapObject).FDrifting := MoveableCheck.Checked;
end;



end.
