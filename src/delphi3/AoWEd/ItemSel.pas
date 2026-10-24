unit ItemSel;

{ Draft declarations of ItemSel, from AoWEd.exe.
  Layouts and VMT order follow data/classes.json; guessed signatures are marked draft.
  Selection fields: $200 item type, $204 filtered GFX indexes, $208 selected index. }

{$R+,Q+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWDlg;

type
  TItemSelectionDlg = class;


  { TItemSelectionDlg (instance size 524, VMT 004128BC) }
  TItemSelectionDlg = class(TAoWDialog)
  public
    published
    Panel1: TPanel; { +01E0 }
    CancelBtn: TButton; { +01E4 }
    OKBtn: TButton; { +01E8 }
    ClientPnl: TPanel; { +01EC }
    MainPageControl: TPageControl; { +01F0 }
    GeneralSheet: TTabSheet; { +01F4 }
    ItemGrid: TImageDrawGrid; { +01F8 }
    Label1: TLabel; { +01FC }
    public
    FItemType: TItemType; { $200 }
    F_ItemSelectionDlg_201: array[0..2] of Byte;
    FItemIndexes: TIntegerList; { $204 }
    FSelectedIndex: Integer; { $208 }
    constructor CreateSelection(AOwner: Classes.TComponent; ItemType: TItemType);
    procedure SetSelectedIndex(Value: Integer);
    published procedure ItemGridCellUpdated(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState); public
    published procedure FormCreate(Sender: TObject); public
    published procedure FormDeactivate(Sender: TObject); public
    published procedure OKBtnClick(Sender: TObject); public
  end;


implementation

constructor TItemSelectionDlg.CreateSelection(AOwner: Classes.TComponent; ItemType: TItemType);
begin
  FItemType := ItemType;
  Create(AOwner);
end;

procedure TItemSelectionDlg.SetSelectedIndex(Value: Integer);
var Index: Integer;
Found: Integer; begin
  Index := Value;
  FSelectedIndex := Index;
  Found := FItemIndexes.IndexOf(Index);
  if Found <> -1 then
    with ItemGrid do
    begin
      Col := Found mod ColCount;
      Row := Found div ColCount;
    end;
end;

procedure TItemSelectionDlg.ItemGridCellUpdated(Sender: TObject; ACol, ARow: Integer; R: TRect; State: TGridDrawState);
var
  Index: Integer;
  DrawRect: TRect;
begin
  Index := ItemGrid.ImageIndex(ACol, ARow);
  if Index < FItemIndexes.Count then
    with ItemGrid do
      BltLibraryImage(Canvas, AoWHSSet.FItemGFXResources.GetItemGFX(FItemIndexes[Index]).GetCellImage,
        R, bmStretch, 50, 50, 0, Color, False, DrawRect)
  else with ItemGrid do
  begin
    Canvas.Brush.Color := clBtnFace;
    Canvas.FillRect(R);
  end;
end;


procedure TItemSelectionDlg.FormCreate(Sender: TObject);
var I: Integer;
begin
  FItemIndexes := TIntegerList.Create;
  FItemIndexes.Default := -1;
  with AoWHSSet.FItemGFXResources do
    for I := 0 to GetCount - 1 do
      if (GetItemGFX(I) <> nil) and (GetItemGFX(I).FItemType = FItemType) and
         (not GetItemGFX(I).FHidden or (euDesigner in AoWEngine.FUser)) then
        FItemIndexes.Add(I);
  ItemGrid.Count := FItemIndexes.Count;
end;


procedure TItemSelectionDlg.FormDeactivate(Sender: TObject);
begin
  FItemIndexes.Free;
end;


procedure TItemSelectionDlg.OKBtnClick(Sender: TObject);
begin
  with ItemGrid do FSelectedIndex := FItemIndexes[ImageIndex(Col, Row)];
end;



end.
