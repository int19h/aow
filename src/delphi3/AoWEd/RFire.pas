unit RFire;

{ Draft declarations of RFire, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RILTer;

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
    procedure FireTypeBoxChange;  { draft }
    procedure FormCreate;  { draft }
  end;

  { TFireResourceEditor (instance size 8, VMT 0040A378) }
  TFireResourceEditor = class(TEObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class procedure TFireResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TFireResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TFireResourceEditForm.FireTypeBoxChange;
begin end;

procedure TFireResourceEditForm.FormCreate;
begin end;


end.
