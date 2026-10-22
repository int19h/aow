unit RExploreS;

{ Draft declarations of RExploreS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Resource and animation fields are inherited; the grids bind the resource collections. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RConstr, UnitIGrd;

type
  TExplorationSiteResourceEditForm = class;
  TExplorationSiteResourceEditor = class;


  { TExplorationSiteResourceEditForm (instance size 908, VMT 0040A4D4) }
  TExplorationSiteResourceEditForm = class(TConstructionResourceEditForm)
  public
    published
    DefendersSheet: TTabSheet; { +0378 }
    DefendersGrid: TUnitIndexGrid; { +037C }
    AddDefender: TButton; { +0380 }
    DeleteDefender: TButton; { +0384 }
    Label11: TLabel; { +0388 }
    public
    published procedure FormCreate(Sender: TObject); public
    published procedure MainPageControlChange(Sender: TObject); public
    published procedure FormDestroy(Sender: TObject); public
    published procedure AddDefenderClick(Sender: TObject); public
    published procedure DeleteDefenderClick(Sender: TObject); public
  end;

  { TExplorationSiteResourceEditor (instance size 8, VMT 0040A6FC) }
  TExplorationSiteResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

uses AoWE, ExploreS, Dungeon, UnitFlt;

class function TExplorationSiteResourceEditor.EditorClassID: Integer;
begin
  Result := $203C2;
end;

class procedure TExplorationSiteResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TExplorationSiteResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure TExplorationSiteResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  DefendersGrid.SetUnitIndexList(TExplorationSiteResource(FResource).FDefenderCollections.FUnits);
end;

procedure TExplorationSiteResourceEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Sender);
  if MainPageControl.ActivePage = DefendersSheet then
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
  end else UnitFloater.Hide;
end;

procedure TExplorationSiteResourceEditForm.FormDestroy(Sender: TObject);
begin
  UnitFloater.Hide;
end;

procedure TExplorationSiteResourceEditForm.AddDefenderClick(Sender: TObject);
var Index: Integer;
begin
  Index := UnitFloater.UnitTabControl.FSelectionControl.FSelectedUnitIndex;
  if Index <> -1 then
  begin
    TExplorationSiteResource(FResource).FDefenderCollections.AddUnit(DefendersGrid.Row, Index);
    DefendersGrid.Invalidate;
  end
  else MessageBeep(0);
end;

procedure TExplorationSiteResourceEditForm.DeleteDefenderClick(Sender: TObject);
begin
  TExplorationSiteResource(FResource).FDefenderCollections.DeleteUnit(DefendersGrid.Row, DefendersGrid.Col);
  DefendersGrid.Invalidate;
end;

end.
