unit LeadrGrd;

{ Draft declarations of LeadrGrd, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management and selection recovered; remaining rendering/editor stubs are unfinished. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TLeaderGrid = class;


  { TLeaderGrid (instance size 488, VMT 55803A10) }
  TLeaderGrid = class(TCustomImageDrawGrid)
  public
    FDisplayOptions: array[0..3] of Byte; { +$1DC }
    FStream: TMemoryStream; { +$1E0 }
    FMap: TAoWHSMap; { +$1E4 }
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure LeadersUpdated(Sender: TObject);
    procedure SetAoWHSMap(Value: TAoWHSMap);
    function GetLeader(Player: Shortint): TLeader;
    function GetSelectedLeader: TLeader;
    procedure SetSelectedLeader(Value: TLeader);
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


constructor TLeaderGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  DefaultColWidth := 155;
  DefaultRowHeight := 56;
  GrowDirection := ilVertical;
  BltMode := TBltMode(2);
  FStream := TMemoryStream.Create;
end;

destructor TLeaderGrid.Destroy;
begin
  { Original does not detach its map event subscription here. }
  FStream.Free;
  inherited Destroy;
end;

procedure TLeaderGrid.LeadersUpdated(Sender: TObject);
begin
  Invalidate;
end;

procedure TLeaderGrid.SetAoWHSMap(Value: TAoWHSMap);
begin
  if Value <> FMap then
  begin
    if FMap <> nil then TEventList(TGridMapView(FMap).LeaderEvent).Remove(LeadersUpdated);
    FMap := Value;
    if FMap <> nil then TEventList(TGridMapView(FMap).LeaderEvent).Add(LeadersUpdated);
    Invalidate;
  end;
end;

function TLeaderGrid.GetLeader(Player: Shortint): TLeader;
var
  Map: TAoWHSMap;
begin
  Map := FMap;
  if (Map <> nil) and (Player > 0) and (TPlayerList(TRawView(Pointer(Map)^).Fields[$140 div 4]).Count > Player) then
    Result := TLeader(TRawView(Pointer(PlayerAt(TPlayerList(TRawView(Pointer(FMap)^).Fields[$140 div 4]), Player))^).Fields[$D4 div 4])
  else Result := nil;
end;

function TLeaderGrid.GetSelectedLeader: TLeader;
var
  Player: Integer;
begin
  Player := ImageIndex(Col, Row) + 1;
  { Original dereferences FMap without a nil check. }
  if Player < TPlayerList(TRawView(Pointer(FMap)^).Fields[$140 div 4]).Count then
    Result := TLeader(TRawView(Pointer(PlayerAt(TPlayerList(TRawView(Pointer(FMap)^).Fields[$140 div 4]), Player))^).Fields[$D4 div 4])
  else Result := nil;
end;

procedure TLeaderGrid.SetSelectedLeader(Value: TLeader);
var
  I: Integer;
begin
  if FMap <> nil then
  begin
    I := RaceToPlayer(TGridMapView(FMap).Players, PHeroView(Value)^.Race);
    if I <> -1 then SelectIndex(I - 1);
  end;
end;

procedure TLeaderGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
begin end;

procedure TLeaderGrid.RemoveFromMap;
var
  Leader: TLeader;
begin
  Leader := GetSelectedLeader;
  if Leader <> nil then Leader.SetOwner(nil);
end;

procedure Register;
begin RegisterComponents('AoW', [TLeaderGrid]); end;


initialization
finalization

end.
