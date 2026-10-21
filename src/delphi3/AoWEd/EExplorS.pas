unit EExplorS;

{ Draft declarations of EExplorS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, EAoWMO, UnitGrid;

type
  TExplorationSiteEditForm = class;
  TExplorationSiteEditor = class;


  { TExplorationSiteEditForm (instance size 576, VMT 0041AB40) }
  TExplorationSiteEditForm = class(TAoWMapObjEditForm)
  public
    published
    DefendersSheet: TTabSheet; { +0210 }
    AutoGenerateBtn: TRadioButton; { +0214 }
    AutoGeneratePanel: TPanel; { +0218 }
    Label2: TLabel; { +021C }
    DefendersModeBox: TComboBox; { +0220 }
    UserDefinedPanel: TPanel; { +0224 }
    DefendersGrid: TUnitGrid; { +0228 }
    DeleteBtn: TButton; { +022C }
    AddBtn: TButton; { +0230 }
    UserDefinedBtn: TRadioButton; { +0234 }
    Panel3: TPanel; { +0238 }
    BorderPanel: TDrawPanel; { +023C }
    public
    procedure AddBtnClick;  { draft }
    procedure DeleteBtnClick;  { draft }
    procedure MainPageControlChange;  { draft }
    procedure FormCreate;  { draft }
    procedure UserDefinedBtnClick;  { draft }
    procedure AutoGenerateBtnClick;  { draft }
    procedure FormDestroy;  { draft }
    procedure DefendersModeBoxChange;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure FormShow;  { draft }
    procedure BorderPanelDraw(A1: Integer; A2: Integer);  { draft }
  end;

  { TExplorationSiteEditor (instance size 8, VMT 0041AE5C) }
  TExplorationSiteEditor = class(TAoWMapObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TExplorationSiteEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TExplorationSiteEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TExplorationSiteEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TExplorationSiteEditForm.AddBtnClick;
begin end;

procedure TExplorationSiteEditForm.DeleteBtnClick;
begin end;

procedure TExplorationSiteEditForm.MainPageControlChange;
begin end;

procedure TExplorationSiteEditForm.FormCreate;
begin end;

procedure TExplorationSiteEditForm.UserDefinedBtnClick;
begin end;

procedure TExplorationSiteEditForm.AutoGenerateBtnClick;
begin end;

procedure TExplorationSiteEditForm.FormDestroy;
begin end;

procedure TExplorationSiteEditForm.DefendersModeBoxChange;
begin end;

procedure TExplorationSiteEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TExplorationSiteEditForm.FormShow;
begin end;

procedure TExplorationSiteEditForm.BorderPanelDraw(A1: Integer; A2: Integer);
begin end;


end.
