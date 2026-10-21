unit LeadrGrd;

{ Draft declarations of LeadrGrd, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management, selection and cell rendering are recovered. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TLeaderGrid = class;


  { TLeaderGrid (instance size 488, VMT 55803A10); $1DC show level, $1DE show status, $1E0 stream, $1E4 map. }
  TLeaderGrid = class(TCustomImageDrawGrid)
  public
    FShowLevel: Boolean; { $1DC }
    FReserved1DD: Byte;
    FShowStatus: Boolean; { $1DE }
    FReserved1DF: Byte;
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
    procedure RemoveFromMap; property SelectionEnabled; { AoWEd 0042D0F8 }
  end;

procedure Register;

implementation

resourcestring
  GridUsedRStr = 'Used';
  GridPlayerRStr = 'Player';

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
  ScrollBars := ssVertical;
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
var
  Player, H, Race: Integer;
  Image: TLibraryImage;
  Region: HRGN;
  Text: string;
  R, ClipR, SourceR, DrawR: TRect;
  Leader: TLeader;
begin
  if not (csDesigning in ComponentState) and (FMap <> nil) then
  begin
    H := ARect.Bottom - ARect.Top;
    Player := ImageIndex(ACol, ARow) + 1;
    if (Player < FMap.FPlayers.GetCount) and (FMap.FPlayers.GetPlayers(Player).FLeader <> nil) then
    begin
      Leader := FMap.FPlayers.GetPlayers(Player).FLeader;
      Race := FMap.FPlayers.GetPlayers(Player).FPlayerRace;
      R := ARect;
      R.Right := R.Left + H - 6;
      if Leader.GetFace <> nil then
        BltLibraryImage(Canvas, Leader.GetFace, R, bmStretch, 100, 100, 0, Color, False, DrawR);
      R := ARect;
      R.Left := R.Left + H - 6;
      Canvas.Brush.Color := clBtnFace;
      Canvas.FillRect(R);
      Image := Leader.GetPreviewImage;
      if Image <> nil then
      begin
        R := ARect;
        R.Left := R.Right - H - 5;
        Dec(R.Top, 5);
        R.Right := Image.Width + R.Left;
        Inc(R.Bottom, 5);
        ClipR := Canvas.ClipRect;
        IntersectClipRect(Canvas.Handle, ARect.Left, ARect.Top, ARect.Right, ARect.Bottom);
        SourceR.Left := 0;
        SourceR.Top := 0;
        SourceR.Bottom := Image.Height;
        SourceR.Right := Image.Width;
        BltLibraryImage(Canvas, Image, R, bmCenter, 100, 100, clBtnFace, clBtnFace, False, DrawR);
        Region := CreateRectRgnIndirect(ClipR);
        SelectObject(Canvas.Handle, Region);
        if not DeleteObject(Region) then raise Exception.Create('Ooohps');
      end;
      if FShowLevel then
      begin
        Canvas.Brush.Style := bsClear;
        Canvas.Font.Color := clRed;
        R := ARect;
        R.Left := R.Right - 15;
        Inc(R.Top, 2);
        Text := IntToStr(Leader.GetLevel);
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      end;
      Text := '- ' + AoWE.TranslateRStr(GridPlayerRStr) + ' ' + IntToStr(Player) + ' / ' +
        AoWHSSet.FRaceResources.GetRaceResource(Race).FRaceName + ' -';
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := AoWHSSet.FRaceResources.GetRaceResource(Race).FHeroUnitIndex;
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Size := 11;
      R := ARect;
      Inc(R.Top);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_CENTER or DT_SINGLELINE or DT_NOPREFIX);
      Text := AoWE.TranslateRStr(NameRStr) + ': ' + Leader.FHeroName;
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := Font.Color;
      Canvas.Font.Size := 8;
      Canvas.Font.Style := [];
      R := ARect;
      Inc(R.Left, H);
      Inc(R.Top, 20);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      if Leader.GetNickname <> '' then
      begin
        Inc(R.Top, 14);
        Text := AoWE.TranslateRStr(TitleRStr) + ': ' + Leader.GetNickname;
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      end;
      if FShowStatus then
      begin
        Inc(R.Top, 14);
        if Leader.Owner = nil then
          Text := AoWE.TranslateRStr(StatusRStr) + ': ' + AoWE.TranslateRStr(FreeRStr)
        else Text := AoWE.TranslateRStr(StatusRStr) + ': ' + AoWE.TranslateRStr(GridUsedRStr);
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
