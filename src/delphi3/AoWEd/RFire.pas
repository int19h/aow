unit RFire;

{ Draft declarations of RFire, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Fire type handlers use TFireResource.FFireType at inherited resource offset $308. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RILTer, AoWE;

type
  TFireResourceEditForm = class;
  TFireResourceEditor = class;


  { TFireResourceEditForm (instance size 840, VMT 0040A1E4) }
  TFireResourceEditForm = class(TILTerrainResourceEditForm)
  public
    published
    Panel10: TPanel; { +033C }
    Label10: TLabel; { +0340 }
    FireTypeBox: TComboBox; { +0344 }
    public
    published procedure FireTypeBoxChange(Sender: TObject); public
    published procedure FormCreate(Sender: TObject); public
  end;

  { TFireResourceEditor (instance size 8, VMT 0040A378) }
  TFireResourceEditor = class(TEObjectEditor)
  public class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TFireResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TFireResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TFireResourceEditForm.FireTypeBoxChange(Sender: TObject);
begin
  TFireResource(FResource).FFireType := TFireType(FireTypeBox.ItemIndex);
end;

procedure TFireResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  FireTypeBox.ItemIndex := Ord(TFireResource(FResource).FFireType);
end;


class function TFireResourceEditor.EditorClassID: Integer;
begin Result := $2077F; end;

end.
