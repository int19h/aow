unit ItemLibF;

{ ItemLibF editor routines recovered from AoWEd.exe. Remaining stubs are marked draft. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemGrid, AoWE;

type
  TItemLibraryEditForm = class;


  { TItemLibraryEditForm: size $234; $230 selected library index. VMT 00420050. }
  TItemLibraryEditForm = class(TForm)
  public
    published
    Panel1: TPanel; { +01DC }
    CloseBtn: TButton; { +01E0 }
    AddBtn: TButton; { +01E4 }
    CopyBtn: TButton; { +01E8 }
    LibraryItemGrid: TItemGrid; { +01EC }
    ItemToolbar: TToolBar; { +01F0 }
    NewLibrary: TToolButton; { +01F4 }
    DeleteLibrary: TToolButton; { +01F8 }
    NewItem: TToolButton; { +01FC }
    DeleteItem: TToolButton; { +0200 }
    ToolButton6: TToolButton; { +0204 }
    ToolButton8: TToolButton; { +0208 }
    ItemImageList: TImageList; { +020C }
    Panel2: TPanel; { +0210 }
    LibraryLbl: TLabel; { +0214 }
    LibraryCB: TComboBox; { +0218 }
    SortOnNamesBtn: TToolButton; { +021C }
    SortOnTypeBtn: TToolButton; { +0220 }
    ToolButton3: TToolButton; { +0224 }
    EditItemBtn: TToolButton; { +0228 }
    Translator: TIvTranslator; { +022C }
    public
    FLibraryIndex: Integer; { $230 }
    procedure EditItem(Item: TItem; ReadOnly: Boolean);
    procedure EditSelectedItem;
    procedure UpdateLibraries;
    procedure SetLibraryIndex(Index: Integer);
    published procedure AddBtnClick; public
    published procedure CopyBtnClick; public
    published procedure FormShow; public
    published procedure LibraryCBChange; public
    published procedure SortOnNamesBtnClick; public
    published procedure SortOnTypeBtnClick; public
    published procedure DeleteItemClick; public
    published procedure NewLibraryClick; public
    published procedure DeleteLibraryClick; public
    published procedure CloseBtnClick; public
    published procedure LibraryItemGridDblClick; public
    published procedure EditItemBtnClick; public
    published procedure NewItemClick; public
  end;


implementation

uses EItem;


procedure TItemLibraryEditForm.EditItem(Item: TItem; ReadOnly: Boolean);
var Dlg: TItemEditForm;
begin
  Dlg := TItemEditForm.Create(Application);
  if ReadOnly then Dlg.EditLibraryItem(Item) else Dlg.EditItem(Item);
  Dlg.Free;
end;

procedure TItemLibraryEditForm.EditSelectedItem;
begin
  if LibraryItemGrid.GetSelectedItem <> nil then
    EditItem(LibraryItemGrid.GetSelectedItem, (AoWHSMap <> nil) and (FLibraryIndex = 0));
end;

procedure TItemLibraryEditForm.UpdateLibraries;
var I: Integer; Manager: TItemLibraryManager;
begin
  LibraryCB.Items.Clear;
  if AoWHSSet <> nil then
  begin
    Manager := AoWHSSet.FItemLibraries;
    for I := 0 to Manager.GetCount - 1 do LibraryCB.Items.Add(Manager.GetLibrary(I).GetName);
  end
  else FLibraryIndex := -1;
  LibraryCB.ItemIndex := FLibraryIndex;
  CopyBtn.Enabled := AoWHSMap <> nil;
  AddBtn.Enabled := AoWHSMap <> nil;
end;

procedure TItemLibraryEditForm.SetLibraryIndex(Index: Integer);
begin
  if (Index >= 0) and (Index < LibraryCB.Items.Count) then FLibraryIndex := Index
  else FLibraryIndex := 0;
  LibraryCB.ItemIndex := FLibraryIndex;
  if (AoWHSSet <> nil) and (FLibraryIndex <> -1) then
  begin
    LibraryItemGrid.SetItems(AoWHSSet.FItemLibraries.GetLibrary(FLibraryIndex));
    LibraryItemGrid.FEditable := (FLibraryIndex <> 0) or (AoWHSMap = nil);
  end
  else
  begin
    LibraryItemGrid.SetItems(nil);
    LibraryItemGrid.FEditable := False;
  end;
  if (FLibraryIndex = 0) and (AoWHSMap <> nil) then
  begin
    DeleteLibrary.Enabled := False;
    NewItem.Enabled := False;
    DeleteItem.Enabled := False;
  end
  else
  begin
    DeleteLibrary.Enabled := True;
    NewItem.Enabled := True;
    DeleteItem.Enabled := True;
  end;
end;

procedure TItemLibraryEditForm.AddBtnClick;
var X, Y, Index: Integer; Item: TItem;
begin
  with LibraryItemGrid do
    for Y := Selection.Top to Selection.Bottom do
      for X := Selection.Left to Selection.Right do
      begin
        Index := ImageIndex(X, Y);
        if GetItem(Index) <> nil then
        begin
          Item := TItem(GetItem(Index).Copy(AoWEngine));
          AoWHSMap.FItemControl.RegisterItem(Item);
          Item.Release;
          AoWHSMap.SetModified;
        end;
      end;
end;


procedure TItemLibraryEditForm.CopyBtnClick;
var X, Y, Index: Integer; Item: TItem;
begin
  with LibraryItemGrid do
    for Y := Selection.Top to Selection.Bottom do
      for X := Selection.Left to Selection.Right do
      begin
        Index := ImageIndex(X, Y);
        if GetItem(Index) <> nil then
        begin
          Item := TItem(GetItem(Index).Copy(AoWEngine));
          Item.FLibraryID := -1;
          AoWHSMap.FItemControl.RegisterItem(Item);
          Item.Release;
          AoWHSMap.SetModified;
        end;
      end;
end;


procedure TItemLibraryEditForm.FormShow;
begin
  UpdateLibraries;
  SetLibraryIndex(FLibraryIndex);
end;


procedure TItemLibraryEditForm.LibraryCBChange;
begin
  SetLibraryIndex(LibraryCB.ItemIndex);
end;


procedure TItemLibraryEditForm.SortOnNamesBtnClick;
begin
  LibraryItemGrid.SortOnName;
end;


procedure TItemLibraryEditForm.SortOnTypeBtnClick;
begin
  LibraryItemGrid.SortOnType;
end;


procedure TItemLibraryEditForm.DeleteItemClick;
begin
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then LibraryItemGrid.DeleteItem;
end;


procedure TItemLibraryEditForm.NewLibraryClick;
var Name: string; Lib: TItemLibrary;
begin
  Name := InputBox(TranslateRStr(CreateNewLibraryRStr), TranslateRStr(EnterLibraryNameRStr), '');
  if Name <> '' then
  begin
    Lib := AoWHSSet.FItemLibraries.CreateLibrary(Name);
    if Lib <> nil then
    begin
      UpdateLibraries;
      SetLibraryIndex(AoWHSSet.FItemLibraries.IndexOfLibrary(Lib));
    end
    else ShowMessage(AoWE.Format(TranslateRStr(XAlreadyExistsRStr), [Name]));
  end;
end;


procedure TItemLibraryEditForm.DeleteLibraryClick;
begin
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then
  begin
    AoWHSSet.FItemLibraries.DeleteLibrary(FLibraryIndex);
    UpdateLibraries;
    SetLibraryIndex(FLibraryIndex);
  end;
end;


procedure TItemLibraryEditForm.CloseBtnClick;
begin
  if AoWHSMap <> nil then
  begin
    AoWHSMap.FItemControl.UpdateLibraryItems;
    AoWHSSet.FItemLibraries.WriteUserLibraries;
  end;
end;


procedure TItemLibraryEditForm.LibraryItemGridDblClick;
begin
  EditSelectedItem;
end;


procedure TItemLibraryEditForm.EditItemBtnClick;
begin
  EditSelectedItem;
end;


procedure TItemLibraryEditForm.NewItemClick;
var Dlg: TItemEditForm; Item: TItem;
begin { Match trials (3): named temporaries, with scopes, Pointer casts, zero-shift scheduling; still differs. }
  if (FLibraryIndex <> 0) or (AoWHSMap = nil) then
  begin
    Item := AoWHSSet.FItemLibraries.GetLibrary(FLibraryIndex).CreateItem;
    Dlg := TItemEditForm.Create(Application);
    if Dlg.EditItem(Item) then LibraryItemGrid.UpdateItems else Item.Free;
    Dlg.Free;
  end;
end;



end.
