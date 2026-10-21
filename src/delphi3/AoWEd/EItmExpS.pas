unit EItmExpS;

{ Draft declarations of EItmExpS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, EExplorS, ItemGrid;

type
  TItemExplorationSiteEditForm = class;
  TItemExplorationSiteEditor = class;


  { TItemExplorationSiteEditForm (instance size 616, VMT 0041B894) }
  TItemExplorationSiteEditForm = class(TExplorationSiteEditForm)
  public
    published
    ItemsSheet: TTabSheet; { +0240 }
    AutoGenerateItemsBtn: TRadioButton; { +0244 }
    UserDefinedItemsBtn: TRadioButton; { +0248 }
    UserDefinedItemsPanel: TPanel; { +024C }
    DeleteItemBtn: TButton; { +0250 }
    AddItemBtn: TButton; { +0254 }
    ItemGrid: TItemGrid; { +0258 }
    AutoGenerateItemsPanel: TPanel; { +025C }
    Label1: TLabel; { +0260 }
    GenerateItemBox: TComboBox; { +0264 }
    public
    procedure FormCreate;  { draft }
    procedure FormDestroy(A1: Integer);  { draft }
    procedure MainPageControlChange;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure GenerateItemBoxChange;  { draft }
    procedure AutoGenerateItemsBtnClick;  { draft }
    procedure UserDefinedItemsBtnClick;  { draft }
    procedure AddItemBtnClick;  { draft }
    procedure DeleteItemBtnClick;  { draft }
  end;

  { TItemExplorationSiteEditor (instance size 8, VMT 0041BB94) }
  TItemExplorationSiteEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;


implementation

class function TItemExplorationSiteEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TItemExplorationSiteEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TItemExplorationSiteEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TItemExplorationSiteEditForm.FormCreate;
begin end;

procedure TItemExplorationSiteEditForm.FormDestroy(A1: Integer);
begin end;

procedure TItemExplorationSiteEditForm.MainPageControlChange;
begin end;

procedure TItemExplorationSiteEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TItemExplorationSiteEditForm.GenerateItemBoxChange;
begin end;

procedure TItemExplorationSiteEditForm.AutoGenerateItemsBtnClick;
begin end;

procedure TItemExplorationSiteEditForm.UserDefinedItemsBtnClick;
begin end;

procedure TItemExplorationSiteEditForm.AddItemBtnClick;
begin end;

procedure TItemExplorationSiteEditForm.DeleteItemBtnClick;
begin end;


end.
