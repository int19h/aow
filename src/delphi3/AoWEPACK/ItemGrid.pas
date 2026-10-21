unit ItemGrid;

{ Draft declarations of ItemGrid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management, selection and cell rendering are recovered. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TItemGrid = class;


  { TItemGrid (instance size 496, VMT 55802170); $1E0 indices, $1E4 items, $1E8 stream, $1ED show availability, $1EE sort. }
  TItemGrid = class(TCustomImageDrawGrid)
  public
    FDisplayOptions: array[0..3] of Byte; { +$1DC }
    FIndices: TIntegerList; { +$1E0 }
    FItems: TItemList; { +$1E4 }
    FStream: TMemoryStream; { +$1E8 }
    FEditable: Boolean; { $1EC; AoWEd 00420664 }
    FShowAvailability: Boolean; { $1ED }
    FSort: Byte; { +$1EE }
    FReserved1EF: Byte; published property SelectionEnabled; public { AoWEd 004164F4 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DelCell; override;
    function GetSelectedItem: TItem;
    function GetItem(Index: Integer): TItem;
    procedure SetItems(Value: TItemList);
    procedure UpdateItems;
    procedure SortOnName;
    procedure SortOnType;
    procedure EditItemDone(ResultCode: TEditResult; Obj: TEObject);
    procedure CreateNewItem;  { draft }
    procedure AddItem(Item: TItem);
    procedure DeleteItem;  { draft }
  end;

procedure Register;

implementation

const
  ItemAvailabilityRStr: array[TItemAvailability] of string =
    ('Exceptional', 'Rare', 'Common', 'Frequent');


type
  { needs: TItemList.GetItem returns TItem at VMT +$8C. This ABI view
    supplies the typed virtual slot without editing the foreign declaration. }
  TEObjectEditorClass = class of TEObjectEditor;
  TItemListView = class(TEChangeNotifyNode)
    function GetItem(Index: Integer): TItem; virtual; abstract;
  end;
  PItemStatus = ^TItemStatus;
  TItemStatus = record Reserved: array[0..$1B] of Byte; Status: Byte; end;
  TRawView = record Fields: array[0..511] of Pointer; end;
  PNodeView = ^TNodeView;
  TNodeView = record Reserved: array[0..7] of Byte; Children: TList; end;
  PEngineView = ^TEngineView;
  TEngineView = record Reserved: array[0..$2F] of Byte; Status: Byte; end;
  PHeroView = ^THeroView;
  THeroView = record
    Reserved00: array[0..$5F] of Byte;
    Name: string;
    Reserved64: array[0..3] of Byte;
    Race: Byte;
    Reserved69: array[0..$E] of Byte;
    Hidden: Boolean;
  end;
  PItemView = ^TItemView;
  TItemView = record
    Reserved00: array[0..$17] of Byte;
    Name: string;
    Reserved1C: array[0..$17] of Byte;
    Kind: Byte;
    Reserved35: array[0..$E] of Byte;
    Hidden: Boolean;
  end;

{ needs: typed results for the existing draft methods. These tail jumps keep their ABI. }
function HeroAt(List: THeroList; Index: Integer): THero; assembler;
asm jmp THeroList.GetHero end;
function ControlHeroAt(Control: THeroControl; Index: Integer): THero; assembler;
asm jmp THeroControl.GetHero end;
function HeroCount(Control: THeroControl): Integer; assembler;
asm jmp THeroControl.GetCount end;
function HeroIndexOf(Control: THeroControl; Hero: THero): Integer; assembler;
asm jmp THeroControl.IndexOf end;
function HeroLevel(Hero: THero): Shortint; assembler;
asm jmp THero.GetLevel end;
function ItemAt(List: TItemList; Index: Integer): TItem; assembler;
asm mov ecx,[eax]; jmp dword ptr [ecx+$8C] end;
function ControlItemAt(Control: TItemControl; Index: Integer): TItem; assembler;
asm jmp TItemControl.GetItem end;
function ItemCount(Control: TItemControl): Integer; assembler;
asm jmp TItemControl.GetCount end;
function PlayerAt(List: TPlayerList; Index: Integer): TPlayer; assembler;
asm jmp TPlayerList.GetPlayers end;
function RaceToPlayer(List: TPlayerList; Race: Byte): Integer; assembler;
asm jmp TPlayerList.RaceToPlayer end;


constructor TItemGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls];
  FStream := TMemoryStream.Create;
  DefaultColWidth := 155;
  DefaultRowHeight := 46;
  GrowDirection := ilVertical;
  BltMode := TBltMode(2);
  FIndices := TIntegerList.Create;
end;

destructor TItemGrid.Destroy;
begin
  FStream.Free;
  FIndices.Free;
  inherited Destroy;
end;

procedure TItemGrid.DelCell;
begin
  if igDel in EditMode then DeleteItem;
end;

function TItemGrid.GetSelectedItem: TItem;
var
  Index: Integer;

begin
  Index := ImageIndex(Col, Row);
  if Index < FIndices.Count then Result := TItemListView(FItems).GetItem(FIndices[Index])
  else Result := nil;
end;

function TItemGrid.GetItem(Index: Integer): TItem;
begin
  { Original checks only the upper bound. }
  if Index < FIndices.Count then Result := TItemListView(FItems).GetItem(FIndices[Index])
  else Result := nil;
end;

procedure TItemGrid.SetItems(Value: TItemList);
begin
  FItems := Value;
  UpdateItems;
end;

procedure TItemGrid.UpdateItems;
var
  I: Integer;
  List: TItemList;
begin
  FIndices.Clear;
  List := FItems;
  if List <> nil then
    if not (Engine.csArrayMode in List.GetControlStyle) then
    begin
      case FSort of
        1: FItems.SortOnType;
        0: FItems.SortOnName;
      end;
      for I := 0 to FItems.Count - 1 do
        if ((PEngineView(AoWEngine)^.Status and 2) <> 0) or not PItemView(TItemListView(FItems).GetItem(I))^.Hidden then FIndices.Add(I);
    end
    else
      for I := 0 to FItems.Count - 1 do FIndices.Add(I);
  Count := FIndices.Count;
  Invalidate;
end;

procedure TItemGrid.SortOnName;
begin
  FSort := 0;
  UpdateItems;
end;

procedure TItemGrid.SortOnType;
begin
  FSort := 1;
  UpdateItems;
end;

procedure TItemGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
var
  Index, H: Integer;
  Text: string;
  R, DrawR: TRect;
  Item: TItem;
  Image: TLibraryImage;
begin
  if not (csDesigning in ComponentState) and (FItems <> nil) then
  begin
    H := ARect.Bottom - ARect.Top;
    Index := ImageIndex(ACol, ARow);
    if (Index < FIndices.Count) and (FItems.GetItem(FIndices[Index]) <> nil) then
    begin
      Item := FItems.GetItem(FIndices[Index]);
      R := ARect;
      R.Right := R.Left + H - 6;
      if AoWHSSet.FItemGFXResources.GetItemGFX(Item.FItemGFXIndex) <> nil then
        Image := AoWHSSet.FItemGFXResources.GetItemGFX(Item.FItemGFXIndex).GetCellImage
      else Image := nil;
      BltLibraryImage(Canvas, Image, R, bmCenter, 100, 100, clBtnFace, Color, False, DrawR);
      R := ARect;
      R.Left := R.Left + H - 6;
      Canvas.Brush.Color := clBtnFace;
      Canvas.FillRect(R);
      Text := Item.FOwnerName;
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := Font.Color;
      R := ARect;
      R.Left := R.Left + H - 2;
      Inc(R.Top);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      if FShowAvailability then
      begin
        Text := AoWE.TranslateRStr(ItemAvailabilityRStr[Item.FAvailability]);
        R := ARect;
        Inc(R.Top, 28);
        R.Left := R.Left + H - 2;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      end;
    end
    else
    begin
      Canvas.Brush.Color := clBtnFace;
      Canvas.FillRect(ARect);
    end;
  end;
  inherited DrawCell(ACol, ARow, ARect, AState);
end;

procedure TItemGrid.EditItemDone(ResultCode: TEditResult; Obj: TEObject);
begin
  if ResultCode = erCancel then
  begin
    if FStream.Size <> 0 then
    begin
      FStream.Position := 0;
      AoWEngine.ReadEObject(FStream, Obj, nil);
      FStream.Clear;
    end else Obj.Free;
  end else FStream.Clear;
  UpdateItems;
  Invalidate;
end;

procedure TItemGrid.CreateNewItem;
var Item: TItem;
begin
  FStream.Clear;
  Item := TItem.Create(FItems);
  AoWEngine.ActivateEObject(Item);
  TEObjectEditorClass(Item.Editor).Edit(Item, AoWEngine, EditItemDone);
end;

procedure TItemGrid.AddItem(Item: TItem);
begin
  if Item <> nil then
  begin
    if csArrayMode in FItems.GetControlStyle then
    begin
      if TItemListView(FItems).GetItem(ImageIndex(Col, Row)) = nil then
        Item.SetArrayOwner(FItems, ImageIndex(Col, Row));
    end else Item.SetOwner(FItems);
    UpdateItems;
  end;
end;

procedure TItemGrid.DeleteItem;
var X, Y, I: Integer; Item: TItem;
begin
  if GetSelectedItem <> nil then
  begin
    for Y := Selection.Bottom downto Selection.Top do
      for X := Selection.Right downto Selection.Left do
      begin
        I := ImageIndex(X, Y);
        Item := TItemListView(FItems).GetItem(FIndices[I]);
        if Item <> nil then
          if (PItemStatus(Item)^.Status and 2) <> 0 then Item.SetOwner(nil)
          else Item.Free;
      end;
    UpdateItems;
  end;
end;

procedure Register;
begin RegisterComponents('AoW', [TItemGrid]); end;


initialization
finalization

end.
