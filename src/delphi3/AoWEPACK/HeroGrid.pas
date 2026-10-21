unit HeroGrid;

{ Draft declarations of HeroGrid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  List management, selection and cell rendering are recovered. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  THeroGrid = class;


  { THeroGrid (instance size 496, VMT 558012E8); $1DC indices, $1E0 heroes, $1E4 show level, $1E6 show status, $1E8 stream, $1EC sort. }
  THeroGrid = class(TCustomImageDrawGrid)
  public
    FIndices: TIntegerList; { +$1DC }
    FHeroes: THeroList; { +$1E0 }
    FShowLevel: Boolean; { $1E4 }
    FReservedDisplay: Byte;
    FShowStatus: Boolean; { $1E6 }
    FUnplacedOnly: Boolean; { +$1E7 }
    FStream: TMemoryStream; { +$1E8 }
    FSort: Byte; { +$1EC }
    FReserved1ED: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Classes.TComponent); override;
    procedure DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState); override;
    procedure DeleteCell; override;
    procedure DelCell; override;
    function GetHero(Index: Integer): THero;
    function GetSelectedHero: THero;
    procedure SetSelectedHero(Value: THero);
    procedure SortHeroes(Mode: Byte);
    procedure UpdateHeroes;
    procedure SortOnName;
    procedure SortOnLevel;
    procedure HeroesUpdated(Sender: TObject);
    procedure SetHeroes(Value: THeroList);
    procedure DeleteHero(Index: Integer);
    procedure DeleteSelectedHero;
  end;

procedure Register;

implementation

resourcestring
  GridUsedRStr = 'Used';

type
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

var SortHeroList: THeroList;

function HeroGridCompareName(A, B: Integer): Integer;
begin
  Result := CompareText(PHeroView(HeroAt(SortHeroList, A))^.Name, PHeroView(HeroAt(SortHeroList, B))^.Name);
  { Original uses object addresses to break ties. }
  if Result = 0 then Result := Integer(HeroAt(SortHeroList, A)) - Integer(HeroAt(SortHeroList, B));
end;
function HeroGridCompareLevel(A, B: Integer): Integer;
begin
  Result := HeroLevel(HeroAt(SortHeroList, A)) - HeroLevel(HeroAt(SortHeroList, B));
  if Result = 0 then Result := Integer(HeroAt(SortHeroList, A)) - Integer(HeroAt(SortHeroList, B));
end;

constructor THeroGrid.Create(AOwner: Classes.TComponent);
begin
  inherited Create(AOwner);
  DefaultColWidth := 155;
  DefaultRowHeight := 46;
  GrowDirection := ilVertical;
  BltMode := TBltMode(2);
  FIndices := TIntegerList.Create;
  FStream := TMemoryStream.Create;
  FSort := 1;
end;

destructor THeroGrid.Destroy;
begin
  SetHeroes(nil);
  FIndices.Free;
  FStream.Free;
  inherited Destroy;
end;

procedure THeroGrid.DeleteCell;
begin
  if igDelete in EditMode then DeleteSelectedHero;
end;

procedure THeroGrid.DelCell;
begin
  if igDel in EditMode then DeleteSelectedHero;
end;

function THeroGrid.GetHero(Index: Integer): THero;
begin
  { Original checks only the upper bound. }
  if Index < FIndices.Count then Result := HeroAt(FHeroes, FIndices[Index])
  else Result := nil;
end;

function THeroGrid.GetSelectedHero: THero;
var
  Index: Integer;
begin
  Index := ImageIndex(Col, Row);
  if Index < FIndices.Count then Result := HeroAt(FHeroes, FIndices[Index])
  else Result := nil;
end;

procedure THeroGrid.SetSelectedHero(Value: THero);
var
  I: Integer;
begin
  I := PNodeView(FHeroes)^.Children.IndexOf(Value);
  if I <> -1 then
  begin
    I := FIndices.IndexOf(I);
    if I <> -1 then SelectIndex(I);
  end;
end;

procedure THeroGrid.SortHeroes(Mode: Byte);
begin
  FSort := Mode;
  SortHeroList := FHeroes;
  case FSort of
    0: FIndices.Sort(HeroGridCompareName);
    1: FIndices.Sort(HeroGridCompareLevel);
  end;
  Invalidate;
end;

procedure THeroGrid.UpdateHeroes;
var
  I: Integer;
  List: THeroList;
begin
  FIndices.Clear;
  List := FHeroes;
  if List <> nil then
  begin
    for I := 0 to List.Count - 1 do
      if ((PEngineView(AoWEngine)^.Status and 2) <> 0) or not PHeroView(HeroAt(FHeroes, I))^.Hidden then
        if not FUnplacedOnly or (HeroAt(FHeroes, I).Owner = nil) then FIndices.Add(I);
    Count := FIndices.Count;
  end;
  SortHeroes(FSort);
  Invalidate;
  if SelectionEnabled and Focused then SelectCell(Col, Row);
end;

procedure THeroGrid.SortOnName;
begin
  SortHeroes(0);
end;

procedure THeroGrid.SortOnLevel;
begin
  SortHeroes(1);
end;

procedure THeroGrid.HeroesUpdated(Sender: TObject);
begin
  UpdateHeroes;
end;

procedure THeroGrid.SetHeroes(Value: THeroList);
begin
  if Value <> FHeroes then
  begin
    FHeroes := Value;
    UpdateHeroes;
  end;
end;

procedure THeroGrid.DrawCell(ACol, ARow: Longint; ARect: Windows.TRect; AState: Grids.TGridDrawState);
var
  Index, H: Integer;
  Text: string;
  R, ClipR, SourceR, DrawR: TRect;
  Hero: THero;
  Image: TLibraryImage;
  Region: HRGN;
begin
  if not (csDesigning in ComponentState) and (FHeroes <> nil) then
  begin
    H := ARect.Bottom - ARect.Top;
    Index := ImageIndex(ACol, ARow);
    if Index < FIndices.Count then
    begin
      Hero := FHeroes.GetHero(FIndices[Index]);
      R := ARect;
      R.Right := R.Left + H - 6;
      if Hero.GetFace <> nil then
        BltLibraryImage(Canvas, Hero.GetFace, R, bmStretch, 100, 100, 0, Color, False, DrawR);
      R := ARect;
      R.Left := R.Left + H - 6;
      Canvas.Brush.Color := clBtnFace;
      Canvas.FillRect(R);
      Image := Hero.GetPreviewImage;
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
        Text := IntToStr(Hero.GetLevel);
        DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      end;
      Text := Hero.FHeroName;
      Canvas.Brush.Style := bsClear;
      Canvas.Font.Color := Font.Color;
      R := ARect;
      R.Left := R.Left + H - 2;
      Inc(R.Top);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      Text := Hero.GetNickname;
      Inc(R.Top, 13);
      DrawText(Canvas.Handle, PChar(Text), Length(Text), R, DT_SINGLELINE or DT_NOPREFIX);
      if FShowStatus then
      begin
        Inc(R.Top, 13);
        if Hero.Owner = nil then
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

procedure THeroGrid.DeleteHero(Index: Integer);
var
  Hero: THero;
begin
  Hero := GetHero(Index);
  if Hero <> nil then
  begin
    FHeroes.RemoveChild(Hero);
    UpdateHeroes;
  end;
end;

procedure THeroGrid.DeleteSelectedHero;
begin
  DeleteHero(ImageIndex(Col, Row));
end;

procedure Register;
begin RegisterComponents('AoW', [THeroGrid]); end;


initialization
finalization

end.
