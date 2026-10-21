unit RDungeon;

{ Draft declarations of RDungeon, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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
    procedure MainPageControlChange;  { draft }
    procedure AddPrisonerClick;  { draft }
    procedure DeletePrisonersClick;  { draft }
    procedure FormCreate;  { draft }
  end;

  { TDungeonResourceEditor (instance size 8, VMT 0040AB60) }
  TDungeonResourceEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
  end;


implementation

class function TDungeonResourceEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TDungeonResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

procedure TDungeonResourceEditForm.MainPageControlChange;
begin end;

procedure TDungeonResourceEditForm.AddPrisonerClick;
begin end;

procedure TDungeonResourceEditForm.DeletePrisonersClick;
begin end;

procedure TDungeonResourceEditForm.FormCreate;
begin end;


end.
