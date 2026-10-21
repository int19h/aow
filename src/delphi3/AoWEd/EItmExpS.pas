unit EItmExpS;

{ Draft declarations of EItmExpS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  TItemExplorationSiteEditForm $268 bytes, inherited $20C FMapObject. }

{$R-,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ItemExpS, EExplorS, ItemGrid;

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
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MainPageControlChange(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure GenerateItemBoxChange(Sender: TObject);
    procedure AutoGenerateItemsBtnClick(Sender: TObject);
    procedure UserDefinedItemsBtnClick(Sender: TObject);
    procedure AddItemBtnClick(Sender: TObject);
    procedure DeleteItemBtnClick(Sender: TObject);
  end;

  { TItemExplorationSiteEditor (instance size 8, VMT 0041BB94) }
  TItemExplorationSiteEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses ItemFlt, UnitFlt;

class function TItemExplorationSiteEditor.EditorClassID: Integer;
begin
  Result := $203F3;
end;

class procedure TItemExplorationSiteEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TItemExplorationSiteEditForm.vmt90(Obj, Done);
end;

class procedure TItemExplorationSiteEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TItemExplorationSiteEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  ItemGrid.SetItems(TItemExplorationSite(FMapObject).FItems);
  if TItemExplorationSite(FMapObject).FItemCount = 0 then
  begin
    UserDefinedItemsBtnClick(Self);
    GenerateItemBox.ItemIndex := 1;
    UserDefinedItemsBtn.Checked := True;
  end
  else
  begin
    AutoGenerateItemsBtn.Checked := True;
    GenerateItemBox.ItemIndex := TItemExplorationSite(FMapObject).FItemCount - 1;
    AutoGenerateItemsBtnClick(Self);
  end;
end;

procedure TItemExplorationSiteEditForm.FormDestroy(Sender: TObject);
begin
  ItemFloater.Hide;
  inherited FormDestroy(Sender);
end;

procedure TItemExplorationSiteEditForm.MainPageControlChange(Sender: TObject);
begin
  inherited MainPageControlChange(Sender);
  if MainPageControl.ActivePage = ItemsSheet then
  begin
    if UserDefinedItemsBtn.Checked then ItemFloater.Show else ItemFloater.Hide;
    UnitFloater.Hide;
  end
  else ItemFloater.Hide;
end;

procedure TItemExplorationSiteEditForm.OKBtnClick(Sender: TObject);
begin
  if AutoGenerateItemsBtn.Checked then TItemExplorationSite(FMapObject).FItems.Clear
  else TItemExplorationSite(FMapObject).FItemCount := 0;
  inherited OKBtnClick(Sender);
end;

procedure TItemExplorationSiteEditForm.GenerateItemBoxChange(Sender: TObject);
begin
  TItemExplorationSite(FMapObject).FItemCount := GenerateItemBox.ItemIndex + 1;
end;

procedure TItemExplorationSiteEditForm.AutoGenerateItemsBtnClick(Sender: TObject);
begin
  ItemGrid.SelectionEnabled := False;
  UserDefinedItemsPanel.Enabled := False;
  AutoGenerateItemsPanel.Enabled := True;
  ItemFloater.Hide;
end;

procedure TItemExplorationSiteEditForm.UserDefinedItemsBtnClick(Sender: TObject);
begin
  ItemGrid.SelectionEnabled := True;
  UserDefinedItemsPanel.Enabled := True;
  AutoGenerateItemsPanel.Enabled := False;
  if MainPageControl.ActivePage = ItemsSheet then ItemFloater.Show;
end;

procedure TItemExplorationSiteEditForm.AddItemBtnClick(Sender: TObject);
begin
  ItemGrid.AddItem(ItemFloater.ItemControlGrid.GetSelectedItem);
end;

procedure TItemExplorationSiteEditForm.DeleteItemBtnClick(Sender: TObject);
begin
  ItemGrid.DeleteItem;
end;


end.
