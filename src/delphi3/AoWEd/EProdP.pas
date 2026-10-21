unit EProdP;

{ Draft declarations of EProdP, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Defender level uses TProductionPlace at inherited $20C FMapObject. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EConstr;

type
  TProductionPlaceEditForm = class;
  TProductionPlaceEditor = class;


  { TProductionPlaceEditForm (instance size 568, VMT 0041D6EC) }
  TProductionPlaceEditForm = class(TPlayerConstructionEditForm)
  public
    published
    DefendersModeBox: TComboBox; { +0230 }
    Label2: TLabel; { +0234 }
    public
    function DefendersEnabled: Boolean;
    procedure FormCreate(Sender: TObject);
    procedure PlayerComboBoxChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
  end;

  { TProductionPlaceEditor (instance size 8, VMT 0041D880) }
  TProductionPlaceEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses PrdPlace;

function TProductionPlaceEditForm.DefendersEnabled: Boolean;
begin
  Result := True;
end;

class function TProductionPlaceEditor.EditorClassID: Integer;
begin
  Result := $203BA;
end;

class procedure TProductionPlaceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TProductionPlaceEditForm.vmt90(Obj, Done);
end;

class procedure TProductionPlaceEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TProductionPlaceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  DefendersModeBox.ItemIndex := TProductionPlace(FMapObject).FDefenderLevel;
  PlayerComboBoxChange(Self);
end;

procedure TProductionPlaceEditForm.PlayerComboBoxChange(Sender: TObject);
begin
  if (PlayerComboBox.ItemIndex = 0) and DefendersEnabled then
  begin
    DefendersModeBox.Color := clWindow;
    DefendersModeBox.Enabled := True;
  end
  else
  begin
    DefendersModeBox.Color := clBtnFace;
    DefendersModeBox.Enabled := False;
  end;
end;

procedure TProductionPlaceEditForm.OKBtnClick(Sender: TObject);
begin
  TProductionPlace(FMapObject).FDefenderLevel := Byte(DefendersModeBox.ItemIndex);
  inherited OKBtnClick(Sender);
end;

end.
