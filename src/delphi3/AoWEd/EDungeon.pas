unit EDungeon;

{ Draft declarations of EDungeon, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EExplorS, UnitGrid;

type
  TDungeonEditForm = class;
  TDungeonEditor = class;


  { TDungeonEditForm (instance size 616, VMT 0041B27C) }
  TDungeonEditForm = class(TExplorationSiteEditForm)
  public
    published
    PrisonersSheet: TTabSheet; { +0240 }
    AutoGeneratePrisBtn: TRadioButton; { +0244 }
    AutoGeneratePrisPanel: TPanel; { +0248 }
    Label1: TLabel; { +024C }
    PrisonersModeBox: TComboBox; { +0250 }
    UserDefinedPrisPanel: TPanel; { +0254 }
    PrisonersGrid: TUnitGrid; { +0258 }
    DeletePrisBtn: TButton; { +025C }
    AddPrisBtn: TButton; { +0260 }
    UserDefinedPrisBtn: TRadioButton; { +0264 }
    public
    procedure MainPageControlChange;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure PrisonersModeBoxChange;  { draft }
    procedure AutoGeneratePrisBtnClick;  { draft }
    procedure UserDefinedPrisBtnClick;  { draft }
    procedure AddPrisBtnClick;  { draft }
    procedure DeletePrisBtnClick;  { draft }
    procedure FormCreate;  { draft }
    procedure FormShow;  { draft }
  end;

  { TDungeonEditor (instance size 8, VMT 0041B568) }
  TDungeonEditor = class(TAoWMapObjectEditor)
  public
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class procedure TDungeonEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TDungeonEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TDungeonEditForm.MainPageControlChange;
begin end;

procedure TDungeonEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TDungeonEditForm.PrisonersModeBoxChange;
begin end;

procedure TDungeonEditForm.AutoGeneratePrisBtnClick;
begin end;

procedure TDungeonEditForm.UserDefinedPrisBtnClick;
begin end;

procedure TDungeonEditForm.AddPrisBtnClick;
begin end;

procedure TDungeonEditForm.DeletePrisBtnClick;
begin end;

procedure TDungeonEditForm.FormCreate;
begin end;

procedure TDungeonEditForm.FormShow;
begin end;


end.
