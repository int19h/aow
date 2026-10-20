unit HeroCtrl;

{ Draft declarations of HeroCtrl, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management and selection recovered; remaining rendering/editor stubs are unfinished. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  THeroControlGrid = class;


  { THeroControlGrid (instance size 504, VMT 55808AFC) }
  THeroControlGrid = class(TCustomImageDrawGrid)
  public
    FIndices: TIntegerList; { +$1DC }
    FDisplayOptions: array[0..2] of Byte; { +$1E0 }
    FUnplacedOnly: Boolean; { +$1E3 }
    FStream: TMemoryStream; { +$1E4 }
    FMap: TAoWHSMap; { +$1E8 }
    FSort: Byte; { +$1EC }
    FReserved1ED: array[0..2] of Byte;
    FOnUnselect: TNotifyEvent; { +$1F0 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetAoWHSMap(Value: TAoWHSMap);
    procedure HeroControlChanged(Sender: TObject);
    procedure HeroChanged(Sender: TObject);
    function GetHero(Index: Integer): THero;
    function GetSelectedHero: THero;
    procedure SetSelectedHero(Value: THero);
    procedure Unselect;
    procedure UpdateHeroes;
    procedure SortOnName;
    procedure SortOnLevel;
    procedure DeleteHero;
    procedure RemoveFromMap;
  end;

procedure Register;

implementation

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

function HeroControlCompareName(A, B: Integer): Integer;
begin
  Result := CompareText(PHeroView(ControlHeroAt(THeroControl(TRawView(Pointer(AoWHSMap)^).Fields[$F8 div 4]), A))^.Name,
    PHeroView(ControlHeroAt(THeroControl(TRawView(Pointer(AoWHSMap)^).Fields[$F8 div 4]), B))^.Name);
end;
function HeroControlCompareLevel(A, B: Integer): Integer;
begin
  Result := HeroLevel(ControlHeroAt(THeroControl(TRawView(Pointer(AoWHSMap)^).Fields[$F8 div 4]), A)) -
    HeroLevel(ControlHeroAt(THeroControl(TRawView(Pointer(AoWHSMap)^).Fields[$F8 div 4]), B));
  if Result = 0 then Result := HeroControlCompareName(A, B);
end;

constructor THeroControlGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  DefaultColWidth := 155;
  DefaultRowHeight := 46;
  GrowDirection := ilVertical;
  BltMode := TBltMode(2);
  FIndices := TIntegerList.Create;
  FStream := TMemoryStream.Create;
  FSort := 0;
end;

destructor THeroControlGrid.Destroy;
begin
  { Original does not detach its map event subscriptions here. }
  FIndices.Free;
  FStream.Free;
  inherited Destroy;
end;

procedure THeroControlGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
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

procedure THeroControlGrid.SetAoWHSMap(Value: TAoWHSMap);
begin
  if Value <> FMap then
  begin
    if FMap <> nil then
    begin
      TEventList(TRawView(Pointer(TGridMapView(FMap).HeroControl)^).Fields[$8 div 4]).Remove(HeroControlChanged);
      TEventList(TRawView(Pointer(TGridMapView(FMap).HeroControl)^).Fields[$10 div 4]).Remove(HeroChanged);
    end;
    FMap := Value;
    if FMap <> nil then
    begin
      TEventList(TRawView(Pointer(TGridMapView(FMap).HeroControl)^).Fields[$8 div 4]).Add(HeroControlChanged);
      TEventList(TRawView(Pointer(TGridMapView(FMap).HeroControl)^).Fields[$10 div 4]).Add(HeroChanged);
    end;
    UpdateHeroes;
  end;
end;

procedure THeroControlGrid.HeroControlChanged(Sender: TObject);
begin
  UpdateHeroes;
end;

procedure THeroControlGrid.HeroChanged(Sender: TObject);
begin
  if FUnplacedOnly then UpdateHeroes
  else Invalidate;
end;

function THeroControlGrid.GetHero(Index: Integer): THero;
begin
  { Original checks only the upper bound. }
  if Index < FIndices.Count then Result := ControlHeroAt(THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]), FIndices[Index])
  else Result := nil;
end;

function THeroControlGrid.GetSelectedHero: THero;
var
  Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  if Index < FIndices.Count then Result := ControlHeroAt(THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]), FIndices[Index])
  else Result := nil;
end;

procedure THeroControlGrid.SetSelectedHero(Value: THero);
var
  I: Integer;
begin
  I := HeroIndexOf(THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]), Value);
  if I <> -1 then
  begin
    I := FIndices.IndexOf(I);
    if I <> -1 then SelectIndex(I);
  end;
end;

procedure THeroControlGrid.Unselect;
begin
  SelectionEnabled := False;
  if Assigned(FOnUnselect) then FOnUnselect(Self);
end;

procedure THeroControlGrid.UpdateHeroes;
var
  I: Integer;
  Hero: THero;
  Map: TAoWHSMap;
begin
  FIndices.Clear;
  Map := FMap;
  if Map <> nil then
    for I := 0 to HeroCount(THeroControl(TRawView(Pointer(Map)^).Fields[$F8 div 4])) - 1 do
    begin
      Hero := ControlHeroAt(THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]), I);
      if ((PEngineView(AoWEngine)^.Status and 2) <> 0) or not PHeroView(Hero)^.Hidden then
        if not (Hero is TLeader) then
          if not FUnplacedOnly or (Hero.Owner = nil) then FIndices.Add(I);
    end;
  case FSort of
    0: FIndices.Sort(HeroControlCompareName);
    1: FIndices.Sort(HeroControlCompareLevel);
  end;
  Count := FIndices.Count;
  Invalidate;
  if SelectionEnabled and Focused then SelectCell(Col, Row);
end;

procedure THeroControlGrid.SortOnName;
begin
  if FSort <> 0 then
  begin
    FSort := 0;
    UpdateHeroes;
  end;
end;

procedure THeroControlGrid.SortOnLevel;
begin
  if FSort <> 1 then
  begin
    FSort := 1;
    UpdateHeroes;
  end;
end;

procedure THeroControlGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure THeroControlGrid.DeleteHero;
var List: TList; X, Y, I: Integer; Hero: THero;
begin
  List := TList.Create;
  THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]).BeginUpdate;
  for Y := Selection.Bottom downto Selection.Top do
    for X := Selection.Right downto Selection.Left do
    begin
      Hero := GetHero(ImageIndex(X, Y));
      if Hero <> nil then List.Add(Hero);
    end;
  for I := List.Count - 1 downto 0 do
  begin
    Hero := THero(List[I]);
    Hero.SetOwner(nil);
    Hero.Free;
    FMap.SetModified;
  end;
  THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]).EndUpdate;
  List.Free;
  Unselect;
end;

procedure THeroControlGrid.RemoveFromMap;
var Hero: THero; Y, X: Integer;
begin
  THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]).BeginUpdate;
  for Y := Selection.Top to Selection.Bottom do
    for X := Selection.Left to Selection.Right do
    begin
      Hero := GetHero(ImageIndex(X, Y));
      if Hero <> nil then
      begin
        Hero.SetOwner(nil);
        FMap.SetModified;
      end;
    end;
  THeroControl(TRawView(Pointer(FMap)^).Fields[$F8 div 4]).EndUpdate;
  Unselect;
end;

procedure Register;
begin RegisterComponents('AoW', [THeroControlGrid]); end;


initialization
finalization

end.
