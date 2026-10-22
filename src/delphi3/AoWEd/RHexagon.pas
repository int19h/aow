unit RHexagon;

{ Draft declarations of RHexagon, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Form initialization and terrain-selection actions are recovered. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, RMapObj;

type
  THexagonResourceEditForm = class;
  THexagonResourceEditor = class;


  { THexagonResourceEditForm (instance size 804, VMT 00407908) }
  THexagonResourceEditForm = class(TMapObjectResourceEditForm)
  public
    published procedure FormCreate(Sender: TObject); public
  end;

  { THexagonResourceEditor (instance size 8, VMT 00407A40) }
  THexagonResourceEditor = class(TEObjectEditor)
  public
    class procedure ChangeTerrain(Sender: TObject);
    class procedure ChangeSelectedTerrain(Sender: TObject);
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdateMultiPopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu; Objects: Engine.TEObjectList); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;


implementation

uses TerTSFrm, TerCBox;

var
  EditHexagonResource: TMapObjectResource;
  EditHexagonResources: TEObjectList;

class procedure THexagonResourceEditor.ChangeTerrain(Sender: TObject);
var Dlg: TTerrainTypeSelectionForm;
begin
  Dlg := TTerrainTypeSelectionForm.CreateSelection(Application,
    EditHexagonResource.Engine, EditHexagonResource.TerrainList.GetTerrain(0), tmTerrain);
  if Dlg.ShowModal = mrOK then
    EditHexagonResource.TerrainList.SetTerrain(0, Dlg.GetTerrainType);
  { The original leaves the terrain selection form allocated. }
end;

class procedure THexagonResourceEditor.ChangeSelectedTerrain(Sender: TObject);
var I: Integer; Dlg: TTerrainTypeSelectionForm;
begin
  Dlg := TTerrainTypeSelectionForm.CreateSelection(Application,
    EditHexagonResource.Engine, EditHexagonResource.TerrainList.GetTerrain(0), tmTerrain);
  if Dlg.ShowModal = mrOK then
    for I := 0 to EditHexagonResources.Count - 1 do
      if EditHexagonResources[I] <> nil then
        TMapObjectResource(EditHexagonResources[I]).TerrainList.SetTerrain(0, Dlg.GetTerrainType);
  { The original leaves the terrain selection form allocated. }
end;

class function THexagonResourceEditor.EditorClassID: Integer;
begin
  Result := $20153;
end;

class procedure THexagonResourceEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
var Item: TMenuItem;
begin
  EditHexagonResource := TMapObjectResource(Obj);
  Item := TMenuItem.Create(Menu);
  Item.Caption := 'Change Terrain';
  Item.OnClick := ChangeTerrain;
  Menu.Items.Add(NewLine);
  Menu.Items.Add(Item);
end;

class procedure THexagonResourceEditor.UpdateMultiPopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu; Objects: Engine.TEObjectList);
var Item: TMenuItem;
begin
  if Objects.AllHaveCID($20153) then
  begin
    EditHexagonResource := TMapObjectResource(Obj);
    EditHexagonResources := Objects;
    Item := TMenuItem.Create(Menu);
    Item.Caption := 'Change Terrain';
    Item.OnClick := ChangeSelectedTerrain;
    Menu.Items.Add(NewLine);
    Menu.Items.Add(Item);
  end;
end;

class procedure THexagonResourceEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  THexagonResourceEditForm.CreateForm(THSEngine(AEngine), TMapObjectResource(Obj), Done);
end;

procedure THexagonResourceEditForm.FormCreate(Sender: TObject);
begin
  inherited FormCreate(Sender);
  MainPageControl.Pages[1].TabVisible := False;
end;


end.
