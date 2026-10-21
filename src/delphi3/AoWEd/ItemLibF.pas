unit ItemLibF;

{ Draft declarations of ItemLibF, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemGrid;

type
  TItemLibraryEditForm = class;


  { TItemLibraryEditForm (instance size 564, VMT 00420050) }
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
    F_ItemLibraryEditForm_230: Integer;
    procedure AddBtnClick;  { draft }
    procedure CopyBtnClick;  { draft }
    procedure FormShow;  { draft }
    procedure LibraryCBChange;  { draft }
    procedure SortOnNamesBtnClick;  { draft }
    procedure SortOnTypeBtnClick;  { draft }
    procedure DeleteItemClick;  { draft }
    procedure NewLibraryClick;  { draft }
    procedure DeleteLibraryClick;  { draft }
    procedure CloseBtnClick;  { draft }
    procedure LibraryItemGridDblClick;  { draft }
    procedure EditItemBtnClick;  { draft }
    procedure NewItemClick;  { draft }
  end;


implementation

procedure TItemLibraryEditForm.AddBtnClick;
begin end;

procedure TItemLibraryEditForm.CopyBtnClick;
begin end;

procedure TItemLibraryEditForm.FormShow;
begin end;

procedure TItemLibraryEditForm.LibraryCBChange;
begin end;

procedure TItemLibraryEditForm.SortOnNamesBtnClick;
begin end;

procedure TItemLibraryEditForm.SortOnTypeBtnClick;
begin end;

procedure TItemLibraryEditForm.DeleteItemClick;
begin end;

procedure TItemLibraryEditForm.NewLibraryClick;
begin end;

procedure TItemLibraryEditForm.DeleteLibraryClick;
begin end;

procedure TItemLibraryEditForm.CloseBtnClick;
begin end;

procedure TItemLibraryEditForm.LibraryItemGridDblClick;
begin end;

procedure TItemLibraryEditForm.EditItemBtnClick;
begin end;

procedure TItemLibraryEditForm.NewItemClick;
begin end;


end.
