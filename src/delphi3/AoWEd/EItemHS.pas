unit EItemHS;

{ Draft declarations of EItemHS, from AoWEd.exe.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWMapEF, ItemGrid;

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
    F_ItemHSEditForm_230: Integer;
    procedure vmt84; override;
    procedure FormCreate;  { draft }
    procedure FormShow;  { draft }
    procedure FormDestroy;  { draft }
    procedure AddItemBtnClick;  { draft }
    procedure DeleteItemBtnClick;  { draft }
    procedure GenerateItemBoxChange;  { draft }
    procedure AutoGenerateItemsBtnClick;  { draft }
    procedure UserDefinedItemsBtnClick;  { draft }
    procedure OKBtnClick(A1: Integer);  { draft }
    procedure ItemGridDblClick;  { draft }
  end;

  { TItemHSEditor (instance size 8, VMT 00417920) }
  TItemHSEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
    class procedure Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent); override;
    class procedure UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu); override;
  end;

  { TItemPlaceControl (instance size 8, VMT 004179CC) }
  TItemPlaceControl = class(TEObject)
  public
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
  end;


implementation

class function TItemHSEditor.EditorClassID: Integer;
begin Result := 0; end;

class procedure TItemHSEditor.Edit(Obj: Engine.TEObject; AEngine: Engine.TEngine; Done: Engine.TEditDoneEvent);
begin end;

class procedure TItemHSEditor.UpdatePopupMenu(Obj: Engine.TEObject; AEngine: Engine.TEngine; var Handled: Boolean; Menu: Menus.TPopupMenu);
begin end;

procedure TItemHSEditForm.FormCreate;
begin end;

procedure TItemHSEditForm.FormShow;
begin end;

procedure TItemHSEditForm.vmt84;
begin end;

procedure TItemHSEditForm.FormDestroy;
begin end;

procedure TItemHSEditForm.AddItemBtnClick;
begin end;

procedure TItemHSEditForm.DeleteItemBtnClick;
begin end;

procedure TItemHSEditForm.GenerateItemBoxChange;
begin end;

procedure TItemHSEditForm.AutoGenerateItemsBtnClick;
begin end;

procedure TItemHSEditForm.UserDefinedItemsBtnClick;
begin end;

procedure TItemHSEditForm.OKBtnClick(A1: Integer);
begin end;

procedure TItemHSEditForm.ItemGridDblClick;
begin end;

procedure TItemPlaceControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;


end.
