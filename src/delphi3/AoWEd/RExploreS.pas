unit RExploreS;

{ Draft declarations of RExploreS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
    procedure FormCreate;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure FormDestroy;  { draft }
    procedure AddDefenderClick;  { draft }
    procedure DeleteDefenderClick;  { draft }
  end;

  { TExplorationSiteResourceEditor (instance size 8, VMT 0040A6FC) }
  TExplorationSiteResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TExplorationSiteResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TExplorationSiteResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TExplorationSiteResourceEditForm.FormCreate;
begin end;

procedure TExplorationSiteResourceEditForm.MainPageControlChange;
begin end;

procedure TExplorationSiteResourceEditForm.FormDestroy;
begin end;

procedure TExplorationSiteResourceEditForm.AddDefenderClick;
begin end;

procedure TExplorationSiteResourceEditForm.DeleteDefenderClick;
begin end;


end.
