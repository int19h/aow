unit RDungeon;

{ Draft declarations of RDungeon, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Resource and animation fields are inherited; the grids bind the resource collections. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RExploreS, UnitIGrd;

type
  TDungeonResourceEditForm = class;
  TDungeonResourceEditor = class;


  { TDungeonResourceEditForm (instance size 928, VMT 0040A958) }
  TDungeonResourceEditForm = class(TExplorationSiteResourceEditForm)
  public
    published
    PrisonersSheet: TTabSheet; { +038C }
    Label12: TLabel; { +0390 }
    PrisonersGrid: TUnitIndexGrid; { +0394 }
    AddPrisoner: TButton; { +0398 }
    DeletePrisoners: TButton; { +039C }
    public
    published procedure MainPageControlChange(Sender: TObject); public
    published procedure AddPrisonerClick(Sender: TObject); public
    published procedure DeletePrisonersClick(Sender: TObject); public
    published procedure FormCreate(Sender: TObject); public
  end;

  { TDungeonResourceEditor (instance size 8, VMT 0040AB60) }
  TDungeonResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses AoWE, ExploreS, Dungeon, UnitFlt;

class function TDungeonResourceEditor.EditorClassID: Integer;
begin Result := $2032B; end;

class procedure TDungeonResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin TDungeonResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done); end;

procedure TDungeonResourceEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Self);
  if MainPageControl.ActivePage = PrisonersSheet then
  begin
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
    UnitFloater.Show;
  end;
end;

procedure TDungeonResourceEditForm.AddPrisonerClick(Sender: TObject);
var Index: Integer;
begin
  Index := UnitFloater.UnitTabControl.FSelectionControl.FSelectedUnitIndex;
  if Index <> -1 then
  begin
    TDungeonResource(FResource).FPrisonerCollections.AddUnit(PrisonersGrid.Row, Index);
    PrisonersGrid.Invalidate;
  end
  else MessageBeep(0);
end;

procedure TDungeonResourceEditForm.DeletePrisonersClick(Sender: TObject);
begin
  TDungeonResource(FResource).FPrisonerCollections.DeleteUnit(PrisonersGrid.Row, PrisonersGrid.Col);
  PrisonersGrid.Invalidate;
end;

procedure TDungeonResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  PrisonersGrid.SetUnitIndexList(TDungeonResource(FResource).FPrisonerCollections.FUnits);
end;

end.
