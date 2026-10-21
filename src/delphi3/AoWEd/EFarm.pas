unit EFarm;

{ Draft declarations of EFarm, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TFarmEditForm $238 bytes; inherited $20C is the farm. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Farm, AoWE, EConstr;

type
  TFarmEditForm = class;
  TFarmEditor = class;


  { TFarmEditForm (instance size 568, VMT 0041D410) }
  TFarmEditForm = class(TPlayerConstructionEditForm)
  public
    published
    Label2: TLabel; { +0230 }
    IncomeLabel: TPanel; { +0234 }
    public
    procedure FormCreate(Sender: TObject);
  end;

  { TFarmEditor (instance size 8, VMT 0041D55C) }
  TFarmEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TFarmEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TFarmEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TFarmEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  IncomeLabel.Caption := IntToStr(TFarm(FMapObject).FIncome);
end;


end.
