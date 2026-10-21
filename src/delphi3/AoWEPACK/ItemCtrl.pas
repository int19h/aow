unit ItemCtrl;

{ Draft declarations of ItemCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management, selection and cell rendering are recovered. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TItemControlGrid = class;


  { TItemControlGrid (instance size 504, VMT 5580795C); $1DC indices, $1E0 stream, $1E6 show status, $1E8 map, $1EC sort, $1F0 unselect event. }
  TItemControlGrid = class(TCustomImageDrawGrid)
  public
    FIndices: TIntegerList; { +$1DC }
    FStream: TMemoryStream; { +$1E0 }
    FDisplayMode: Byte; { +$1E4 }
    FUnplacedOnly: Boolean; { +$1E5 }
    FShowStatus: Boolean; { $1E6 }
    FReserved1E7: Byte;
    FMap: TAoWHSMap; { +$1E8 }
    FSort: Byte; { +$1EC }
    FReserved1ED: array[0..2] of Byte;
    FOnUnselect: TNotifyEvent; { +$1F0 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DelCell; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure ItemChanged(Sender: TObject);
    procedure ItemControlChanged(Sender: TObject);
    procedure SetAoWHSMap(Value: TAoWHSMap);
    procedure SortOnName;
    procedure SortOnType;
    function GetSelectedItem: TItem;
    function GetItem(Index: Integer): TItem;
    procedure UpdateItems;
    procedure Unselect;
    procedure EditItemDone(ResultCode: TEditResult; Obj: TEObject);
    procedure DeleteItem;  { draft }
    procedure RemoveItemFromMap; property SelectionEnabled; { AoWEd 0042B7C6 }
  end;

procedure Register;

implementation

resourcestring
  GridUsedRStr = 'Used';

type
  TGridMapView = class(TObject)
    Reserved04: array[4..$F3] of Byte;
    ItemControl: TItemControl;
    HeroControl: THeroControl;
    ReservedFC: array[$FC..$13F] of Byte;
    Players: TPlayerList;
    Reserved144: array[$144..$17B] of Byte;
    LeaderEvent: TEventList;
  end;
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
    Status: Byte;
    Reserved1D: array[0..$16] of Byte;
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

function ItemControlCompareName(A, B: Integer): Integer;
begin
  Result := CompareText(PItemView(ControlItemAt(TItemControl(TRawView(Pointer(AoWHSMap)^).Fields[$F4 div 4]), A))^.Name,
    PItemView(ControlItemAt(TItemControl(TRawView(Pointer(AoWHSMap)^).Fields[$F4 div 4]), B))^.Name);
end;
function ItemControlCompareType(A, B: Integer): Integer;
begin
  Result := PItemView(ControlItemAt(TItemControl(TRawView(Pointer(AoWHSMap)^).Fields[$F4 div 4]), A))^.Kind -
    PItemView(ControlItemAt(TItemControl(TRawView(Pointer(AoWHSMap)^).Fields[$F4 div 4]), B))^.Kind;
end;

constructor TItemControlGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  FStream := TMemoryStream.Create;
  DefaultColWidth := 155;
  DefaultRowHeight := 46;
  GrowDirection := ilVertical;
  BltMode := TBltMode(2);
  FIndices := TIntegerList.Create;
  FSort := 0;
end;

destructor TItemControlGrid.Destroy;
begin
  { Original does not detach its map event subscriptions here. }
  FStream.Free;
  FIndices.Free;
  inherited Destroy;
end;

procedure TItemControlGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Coord: TGridCoord;
begin
  if Button = mbRight then
  begin
    Coord := MouseCoord(X, Y);
    if (Selection.Left > Coord.X) or (Selection.Right < Coord.X) or
      (Selection.Top > Coord.Y) or (Selection.Bottom < Coord.Y) then
      inherited MouseDown(mbLeft, Shift, X, Y);
  end;
  inherited MouseDown(Button, Shift, X, Y);
end;

procedure TItemControlGrid.ItemChanged(Sender: TObject);
begin
  if FUnplacedOnly then UpdateItems
  else Invalidate;
end;

procedure TItemControlGrid.ItemControlChanged(Sender: TObject);
begin
  UpdateItems;
end;

procedure TItemControlGrid.SetAoWHSMap(Value: TAoWHSMap);
begin
  if Value <> FMap then
  begin
    if FMap <> nil then
    begin
      TEventList(TRawView(Pointer(TGridMapView(FMap).ItemControl)^).Fields[$C div 4]).Remove(ItemControlChanged);
      TEventList(TRawView(Pointer(TGridMapView(FMap).ItemControl)^).Fields[$14 div 4]).Remove(ItemChanged);
    end;
    FMap := Value;
    if FMap <> nil then
    begin
      TEventList(TRawView(Pointer(TGridMapView(FMap).ItemControl)^).Fields[$C div 4]).Add(ItemControlChanged);
      TEventList(TRawView(Pointer(TGridMapView(FMap).ItemControl)^).Fields[$14 div 4]).Add(ItemChanged);
    end;
    UpdateItems;
  end;
end;

procedure TItemControlGrid.SortOnName;
begin
  if FSort <> 0 then
  begin
    FSort := 0;
    FIndices.Sort(ItemControlCompareName);
    Invalidate;
  end;
end;

procedure TItemControlGrid.SortOnType;
begin
  if FSort <> 1 then
  begin
    FSort := 1;
    FIndices.Sort(ItemControlCompareType);
    Invalidate;
  end;
end;

procedure TItemControlGrid.DelCell;
begin
  if igDel in EditMode then DeleteItem;
end;

function TItemControlGrid.GetSelectedItem: TItem;
var
  Index: Integer;
  Map: TAoWHSMap;
begin
  Index := ImageIndex(Col, Row);
  Map := FMap;
  if (Map <> nil) and (Index < FIndices.Count) then Result := ControlItemAt(TItemControl(TRawView(Pointer(Map)^).Fields[$F4 div 4]), FIndices[Index])
  else Result := nil;
end;

function TItemControlGrid.GetItem(Index: Integer): TItem;
var
  I: Integer;
  Map: TAoWHSMap;
begin
  I := Index;
  Map := FMap;
  { Original checks only the upper bound. }
  if (Map <> nil) and (I < FIndices.Count) then Result := ControlItemAt(TItemControl(TRawView(Pointer(Map)^).Fields[$F4 div 4]), FIndices[I])
  else Result := nil;
end;

procedure TItemControlGrid.UpdateItems;
var
  I, Total: Integer;
  Map: TAoWHSMap;
  Item: TItem;
begin
  FIndices.Clear;
  Map := FMap;
  if Map <> nil then
  begin
    Total := ItemCount(TItemControl(TRawView(Pointer(Map)^).Fields[$F4 div 4]));
    for I := 0 to Total - 1 do
    begin
      Item := ControlItemAt(TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]), I);
      if ((PEngineView(AoWEngine)^.Status and 2) <> 0) or not PItemView(Item)^.Hidden then
        if (Item.Owner = nil) or not FUnplacedOnly then FIndices.Add(I);
    end;
  end;
  case FSort of
    1: FIndices.Sort(ItemControlCompareType);
    0: FIndices.Sort(ItemControlCompareName);
  end;
  Count := FIndices.Count;
  UpdateDimensions;
  Invalidate;
end;

procedure TItemControlGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
var
  Index, H: Integer;
  Text: string;
  R, DrawR: TRect;
  Item: TItem;
  Image: TLibraryImage;
begin
  if not (csDesigning in ComponentState) and (FMap <> nil) then
  begin
    H := ARect.Bottom - ARect.Top;
    Index := ImageIndex(ACol, ARow);
    if Index < FIndices.Count then
    begin
      Item := FMap.FItemControl.GetItem(FIndices[Index]);
      R := ARect;
      R.Right := R.Left + H - 6;
      if AoWHSSet.FItemGFXResources.GetItemGFX(Item.FItemGFXIndex) <> nil then
        Image := AoWHSSet.FItemGFXResources.GetItemGFX(Item.FItemGFXIndex).GetCellImage
      else Image := nil;
      BltLibraryImage(Canvas, Image, R, BltMode, 100, 100, clBtnFace, Color, False, DrawR);
      if not Item.GetLibraryItem then
      begin
        Canvas.Font.Color := clRed;
        Canvas.Brush.Style := bsClear;
        R := ARect;
        R.Left := ARect.Left + 6;
        Inc(R.Top, 30);
        Text := UserStr;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
        Canvas.Font.Color := Font.Color;
      end;
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
      if FShowStatus then
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_NOPREFIX)
      else DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      if FShowStatus then
      begin
        if Item.Owner = nil then
          Text := AoWE.TranslateRStr(StatusRStr) + ': ' + AoWE.TranslateRStr(FreeRStr)
        else Text := AoWE.TranslateRStr(StatusRStr) + ': ' + AoWE.TranslateRStr(GridUsedRStr);
        R := ARect;
        Inc(R.Top, 28);
        R.Left := R.Left + H - 2;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_NOPREFIX);
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

procedure TItemControlGrid.Unselect;
begin
  SelectionEnabled := False;
  if Assigned(FOnUnselect) then FOnUnselect(Self);
end;

procedure TItemControlGrid.EditItemDone(ResultCode: TEditResult; Obj: TEObject);
var Item: TItem;
begin
  Item := TItem(Obj);
  if ResultCode = erCancel then
  begin
    if FStream.Size <> 0 then
    begin
      FStream.Position := 0;
      AoWEngine.ReadEObject(FStream, Item, nil);
      FStream.Clear;
    end else Item.Free;
  end else
  begin
    FStream.Clear;
    if ((PItemView(Item)^.Status and 2) = 0) and (FMap <> nil) then
      TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).RegisterItem(Item);
  end;
  UpdateItems;
  Unselect;
  SetFocus;
end;

procedure TItemControlGrid.DeleteItem;
var List: TList; X, Y, I: Integer; Item: TItem;
begin
  List := TList.Create;
  TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).BeginUpdate;
  for Y := Selection.Bottom downto Selection.Top do
    for X := Selection.Right downto Selection.Left do
    begin
      I := ImageIndex(X, Y);
      if (I >= 0) and (I < FIndices.Count) then
      begin
        I := FIndices[ImageIndex(X, Y)];
        if I < ItemCount(TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4])) then
        begin
          Item := ControlItemAt(TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]), I);
          if Item <> nil then List.Add(Item);
        end;
      end;
    end;
  for I := List.Count - 1 downto 0 do
  begin
    Item := TItem(List[I]);
    Item.SetOwner(nil);
    TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).UnRegisterItem(Item);
    FMap.SetModified;
  end;
  TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).EndUpdate;
  List.Free;
  Unselect;
end;

procedure TItemControlGrid.RemoveItemFromMap;
var X, Y, I: Integer;
begin
  TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).BeginUpdate;
  for Y := Selection.Bottom downto Selection.Top do
    for X := Selection.Right downto Selection.Left do
    begin
      I := ImageIndex(X, Y);
      if (I >= 0) and (I < FIndices.Count) then
      begin
        I := FIndices[I];
        if I < ItemCount(TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4])) then ControlItemAt(TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]), I).SetOwner(nil);
      end;
    end;
  TItemControl(TRawView(Pointer(FMap)^).Fields[$F4 div 4]).EndUpdate;
  Unselect;
end;

procedure Register;
begin RegisterComponents('AoW', [TItemControlGrid]); end;


initialization
finalization

end.
