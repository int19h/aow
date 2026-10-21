unit EItemHS;

{ Draft declarations of EItemHS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Instance $234: $230 item sprite; controls at $204..$22C. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWMapEF, ItemGrid;

type
  TItemHSEditForm = class;
  TItemHSEditor = class;
  TItemPlaceControl = class;


  { TItemHSEditForm (instance size 564, VMT 00417618) }
  TItemHSEditForm = class(TAoWMapEditForm)
  public
    published
    MainPageControl: TPageControl; { +0204 }
    GeneralSheet: TTabSheet; { +0208 }
    UserDefinedItemsPanel: TPanel; { +020C }
    DeleteItemBtn: TButton; { +0210 }
    ItemGrid: TItemGrid; { +0214 }
    UserDefinedItemsBtn: TRadioButton; { +0218 }
    AutoGenerateItemsPanel: TPanel; { +021C }
    Label1: TLabel; { +0220 }
    GenerateItemBox: TComboBox; { +0224 }
    AutoGenerateItemsBtn: TRadioButton; { +0228 }
    AddBtn: TButton; { +022C }
    public
    FItemHS: TItemHS; { $230 }
    procedure SetItemsMode(Mode: Integer);
    procedure vmt84; override;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure AddItemBtnClick(Sender: TObject);
    procedure DeleteItemBtnClick(Sender: TObject);
    procedure GenerateItemBoxChange(Sender: TObject);
    procedure AutoGenerateItemsBtnClick(Sender: TObject);
    procedure UserDefinedItemsBtnClick(Sender: TObject);
    procedure OKBtnClick(Sender: TObject);
    procedure ItemGridDblClick;  { draft }
  end;

  { TItemHSEditor (instance size 8, VMT 00417920) }
  TItemHSEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu); override;
  end;

  { TItemPlaceControl (instance size 8, VMT 004179CC) }
  TItemPlaceControl = class(TEObject)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;


var ItemPlaceControl: TItemPlaceControl; { AoWEd 0042B68C }

implementation

uses EItem, ItemFlt;

procedure TItemHSEditForm.SetItemsMode(Mode: Integer);
begin
  case Mode of
    0:
      begin
        ItemGrid.SelectionEnabled := False;
        GenerateItemBox.Color := clWindow;
        UserDefinedItemsPanel.Enabled := False;
        AutoGenerateItemsPanel.Enabled := True;
        GenerateItemBoxChange(Self);
      end;
    1:
      begin
        GenerateItemBox.Color := clBtnFace;
        ItemGrid.SelectionEnabled := True;
        UserDefinedItemsPanel.Enabled := True;
        AutoGenerateItemsPanel.Enabled := False;
      end;
  end;
end;


class function TItemHSEditor.EditorClassID: Integer;
begin
  Result := $20271;
end;

class procedure TItemHSEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin
  TItemHSEditForm.vmt90(Obj, Done);
end;

class procedure TItemHSEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Engine.TEditMode; Menu: Menus.TPopupMenu);
begin
  Handled := Handled + [emEdit];
end;

procedure TItemHSEditForm.FormCreate(Sender: TObject);
begin
  FItemHS := TItemHS(FEditObject);
  TItemHS(FEditObject).FItems.BeginUpdate;
  ItemGrid.SetItems(FItemHS.FItems);
  if FItemHS.FGenerateMode = igUserDefined then
  begin
    SetItemsMode(1);
    GenerateItemBox.ItemIndex := 1;
    UserDefinedItemsBtn.Checked := True;
  end
  else
  begin
    AutoGenerateItemsBtn.Checked := True;
    GenerateItemBox.ItemIndex := Ord(FItemHS.FGenerateMode) - 1;
    SetItemsMode(0);
  end;
end;


procedure TItemHSEditForm.FormShow(Sender: TObject);
begin
  inherited FormShow;
  if UserDefinedItemsBtn.Checked then ItemFloater.Show;
end;


procedure TItemHSEditForm.vmt84;
begin
  FItemHS.Deactivate;
  inherited vmt84;
  FItemHS.Activate;
end;


procedure TItemHSEditForm.FormDestroy(Sender: TObject);
begin
  FItemHS.FItems.EndUpdate;
  ItemFloater.Hide;
end;


procedure TItemHSEditForm.AddItemBtnClick(Sender: TObject);
begin
  ItemGrid.AddItem(ItemFloater.ItemControlGrid.GetSelectedItem);
end;


procedure TItemHSEditForm.DeleteItemBtnClick(Sender: TObject);
begin
  ItemGrid.DeleteItem;
end;


procedure TItemHSEditForm.GenerateItemBoxChange(Sender: TObject);
begin
  FItemHS.FGenerateMode := TItemGenerateMode(GenerateItemBox.ItemIndex + 1);
end;


procedure TItemHSEditForm.AutoGenerateItemsBtnClick(Sender: TObject);
begin
  SetItemsMode(0);
  if Visible then ItemFloater.Hide;
end;


procedure TItemHSEditForm.UserDefinedItemsBtnClick(Sender: TObject);
begin
  SetItemsMode(1);
  if Visible then ItemFloater.Show;
end;


procedure TItemHSEditForm.OKBtnClick(Sender: TObject);
begin
  if AutoGenerateItemsBtn.Checked then FItemHS.FItems.Clear
  else FItemHS.FGenerateMode := igUserDefined;
  inherited OKBtnClick(Sender);
end;


procedure TItemHSEditForm.ItemGridDblClick;
var Item: TItem; Dlg: TItemEditForm;
begin
  Item := ItemGrid.GetSelectedItem;
  if Item <> nil then
  begin
    Dlg := TItemEditForm.Create(Application);
    if Item.GetLibraryItem then Dlg.EditLibraryItem(Item)
    else Dlg.EditItem(Item);
    Dlg.Free;
  end;
end;

procedure TItemPlaceControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var
  X, Y, L: Integer;
  HS: TItemHS;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then
  begin
    L := TItemDropMsg(Msg).Lhp;
    HPtoHX(TItemDropMsg(Msg).Xhp, TItemDropMsg(Msg).Yhp, X, Y);
    if Smallint(AoWHSMap.MapContainer.GetField(X, Y, L).TerrainType) <> 15 then
    begin
      HS := TItemHS(AoWHSMap.MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
      if HS = nil then
      begin
        HS := TItemHS.Create(nil);
        if not AoWHSMap.PlaceHX(HS, X, Y, L) then
        begin
          HS.Free;
          HS := nil;
        end;
      end;
      if HS <> nil then
      begin
        { Original leaves the change lock held if the editor raises. }
        HS.FItems.LockChanged;
        TEObjectEditorClass(HS.Editor).Edit(HS, AoWEngine, nil);
        Msg.MsgID := 0;
        Msg.Result := 0;
        HS.FItems.UnlockChanged;
      end;
    end;
  end;
end;



end.
