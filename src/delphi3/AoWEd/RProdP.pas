unit RProdP;

{ Draft declarations of RProdP, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  TProdPlaceResEditForm $38C bytes; inherited $308 is the resource. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace, RPlayerStructure, UnitIGrd;

type
  TProdPlaceResEditForm = class;
  TProductionPlaceResourceEditor = class;


  { TProdPlaceResEditForm (instance size 908, VMT 00409DB4) }
  TProdPlaceResEditForm = class(TPlayerStructureResourceEditForm)
  public
    published
    ProductionSheet: TTabSheet; { +0378 }
    GroupBox4: TGroupBox; { +037C }
    ProductionGrid: TUnitIndexGrid; { +0380 }
    AddBtn: TButton; { +0384 }
    DeleteBtn: TButton; { +0388 }
    public
    published procedure FormCreate(Sender: TObject); public
    published procedure FormDestroy(Sender: TObject); public
    published procedure AddBtnClick(Sender: TObject); public
    published procedure DeleteBtnClick(Sender: TObject); public
    published procedure MainPageControlChange(Sender: TObject); public
    published procedure CloseBtnClick(Sender: TObject); public
  end;

  { TProductionPlaceResourceEditor (instance size 8, VMT 00409FC8) }
  TProductionPlaceResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses UnitFlt;

class function TProductionPlaceResourceEditor.EditorClassID: Integer;
begin
  Result := $203BB;
end;

class procedure TProductionPlaceResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TProdPlaceResEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TProdPlaceResEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  UnitFloater.ResetSelection;
  with UnitFloater.UnitTabControl.FSelectionControl do
  begin
    FShowAllCategory := True;
    FShowRaceCategories := True;
    FShowTypeCategories := True;
    FMinimumLevel := 1;
    FMaximumLevel := 4;
  end;
  UnitFloater.UnitTabControl.UpdateSelection;
  ProductionGrid.FSelectionControl := UnitFloater.UnitTabControl.FSelectionControl;
  ProductionGrid.SetUnitIndexList(TProductionPlaceResource(FResource).FUnits);
end;

procedure TProdPlaceResEditForm.FormDestroy(Sender: TObject);
begin
  UnitFloater.Hide;
end;

procedure TProdPlaceResEditForm.AddBtnClick(Sender: TObject);
begin
  ProductionGrid.AddUnit;
end;

procedure TProdPlaceResEditForm.DeleteBtnClick(Sender: TObject);
begin
  ProductionGrid.DeleteUnit;
end;

procedure TProdPlaceResEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Sender);
  if MainPageControl.ActivePage = ProductionSheet then UnitFloater.Show;
end;

procedure TProdPlaceResEditForm.CloseBtnClick(Sender: TObject);
begin
  TProductionPlaceResource(FResource).FUnits.SortUnits;
  inherited CloseBtnClick(Sender);
end;


end.
