unit HSLib;

{ The HSLib unit of HSEPack.dpl: THSLibrary, an image library component whose images can be put
  on the map of a THexagonSpriteEngine as TLibraryHS sprites (registered on the HS-Engine palette
  page). }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Engine, GFXE, ImageLib,
  HSEngine;

type
  THSLibrary = class;

  { HSLib.TLibraryHS (instance size 44): a library image shown at a pixel position of the map.
    +$18 FMapContainer, +$1C FLevel (the show level, 30 by default), +$20 FImage, +$24
    FDestroyOnShow, +$28 FLibrary (the THSLibrary that created it). FXhp = Low(Integer) means not
    placed. }
  TLibraryHS = class(THPBasedHS)
  private
    FMapContainer: TMapContainer;
    FLevel: Byte;
    FImage: TLibraryImage;
    FDestroyOnShow: Boolean;
    FLibrary: THSLibrary;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    procedure GetBaseHex(var Lhx: ShortInt);
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function GetXhx: ShortInt; override;
    function GetYhx: ShortInt; override;
    function GetLhx: ShortInt; override;
    procedure Remove; override;
    procedure SetImage(Value: TLibraryImage);
    function Place(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    function PlaceEx(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer; Level: Byte): Boolean;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
    function PlaceHXEx(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt; Level: ShortInt;
      Center: Boolean): Boolean;
    property MapContainer: TMapContainer read FMapContainer;
    property Level: Byte read FLevel write FLevel;
    property Image: TLibraryImage read FImage write SetImage;
    property DestroyOnShow: Boolean read FDestroyOnShow write FDestroyOnShow;
  end;

  { HSLib.THSLibrary (instance size 92): +$50 FList (the TLibraryHS it created), +$54 FHSEngine,
    +$58 FEngine }
  THSLibrary = class(TImageLibrary)
  private
    FList: TList;
    FHSEngine: THSEngine;
    FEngine: THexagonSpriteEngine;
    procedure SetEngine(Value: THexagonSpriteEngine);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ClearList;
    procedure RemoveHS(HS: TLibraryHS);
    function CreateHS(Index: Integer): TLibraryHS;
  published
    property Engine: THexagonSpriteEngine read FEngine write SetEngine;
  end;

procedure Register;

implementation

{ TLibraryHS }

constructor TLibraryHS.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FLevel := 30;
end;

destructor TLibraryHS.Destroy;
begin
  FLibrary.RemoveHS(Self);
  inherited Destroy;
end;

procedure TLibraryHS.GetBaseHex(var Lhx: ShortInt);
begin
  Lhx := -1;
end;

function TLibraryHS.GetLevel: Byte;
begin
  Result := FLevel;
end;

function TLibraryHS.GetShowPriority: Integer;
begin
  Result := FLevel shl 26 + FYhp shl 13 + FXhp;
end;

procedure TLibraryHS.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
end;

procedure TLibraryHS.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp: Integer;
begin
  Xhp := FXhp;
  if Xhp <> Low(Integer) then FImage.Show(Xhp - XhpSurf, FYhp - YhpSurf, SurfaceDesc);
  if FDestroyOnShow then Destroy;
end;

function TLibraryHS.GetXhx: ShortInt;
begin
  Result := -1;
end;

function TLibraryHS.GetYhx: ShortInt;
begin
  Result := -1;
end;

function TLibraryHS.GetLhx: ShortInt;
begin
  Result := -1;
end;

{ Original bug: the right edge of the image is taken 8 pixels short for the second column. }
procedure TLibraryHS.Remove;
var
  I, J: Integer;
  XMin, OddYMin, EvenYMin, XMax, OddYMax, EvenYMax: Integer;
begin
  if FXhp <> Low(Integer) then
  begin
    HPtoHX(FXhp - 8, FYhp, XMin, OddYMin);
    HPtoHX(FXhp - 8 + 32, FYhp, I, J);
    if not Odd(XMin) then
    begin
      EvenYMin := OddYMin;
      OddYMin := J;
    end
    else
      EvenYMin := J;
    J := FImage.Height + FYhp - 1;
    HPtoHX(FImage.Width + FXhp + 8 - 1, J, XMax, OddYMax);
    HPtoHX(FImage.Width + FXhp - 1 + 32, J, I, J);
    if not Odd(XMax) then
    begin
      EvenYMax := OddYMax;
      OddYMax := J;
    end
    else
      EvenYMax := J;
    if XMin < 0 then XMin := 0;
    if XMax >= FMapContainer.Width then XMax := FMapContainer.Width - 1;
    if EvenYMin < 0 then EvenYMin := 0;
    if EvenYMax >= FMapContainer.Height then EvenYMax := FMapContainer.Height - 1;
    if OddYMin < 0 then OddYMin := 0;
    if OddYMax >= FMapContainer.Height then OddYMax := FMapContainer.Height - 1;
    for I := XMin to XMax do
      if not Odd(I) then
        for J := EvenYMin to EvenYMax do
          FMapContainer.RemoveHS(I, J, FLhx, Self)
      else
        for J := OddYMin to OddYMax do
          FMapContainer.RemoveHS(I, J, FLhx, Self);
    if GetVisible then
    begin
      if FLevel <= 15 then
      begin
        FMapContainer.Map.StaticVisibleHS.RemoveChild(Self);
        FMapContainer.Map.StaticSceneInvalid := True;
      end
      else
        FMapContainer.Map.DynamicVisibleHS.RemoveChild(Self);
      SetVisible(False);
    end;
    FXhp := Low(Integer);
  end;
end;

procedure TLibraryHS.SetImage(Value: TLibraryImage);
var
  Xhp: Integer;
begin
  if FXhp <> Low(Integer) then
  begin
    Xhp := FXhp;
    Remove;
    FXhp := Low(Integer);
  end
  else
    Xhp := Low(Integer);
  FImage := Value;
  if (Value <> nil) and (Xhp <> Low(Integer)) then
    Place(FMapContainer, Xhp, FYhp, FLhx);
end;

function TLibraryHS.Place(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  I, J: Integer;
  XMin, OddYMin, EvenYMin, XMax, OddYMax, EvenYMax: Integer;
begin
  if FXhp <> Low(Integer) then Remove;
  FXhp := Xhp;
  FYhp := Yhp;
  FLhx := Lhx;
  FMapContainer := MapContainer;
  if Xhp <> Low(Integer) then
  begin
    HPtoHX(FXhp - 8, FYhp, XMin, OddYMin);
    HPtoHX(FXhp - 8 + 32, FYhp, I, J);
    if not Odd(XMin) then
    begin
      EvenYMin := OddYMin;
      OddYMin := J;
    end
    else
      EvenYMin := J;
    J := FImage.Height + FYhp - 1;
    HPtoHX(FImage.Width + FXhp + 8 - 1, J, XMax, OddYMax);
    HPtoHX(FImage.Width + FXhp + 8 - 1 + 32, J, I, J);
    if not Odd(XMax) then
    begin
      EvenYMax := OddYMax;
      OddYMax := J;
    end
    else
      EvenYMax := J;
    if XMin < 0 then XMin := 0;
    if XMax >= MapContainer.Width then XMax := MapContainer.Width - 1;
    if EvenYMin < 0 then EvenYMin := 0;
    if EvenYMax >= MapContainer.Height then EvenYMax := MapContainer.Height - 1;
    if OddYMin < 0 then OddYMin := 0;
    if OddYMax >= MapContainer.Height then OddYMax := MapContainer.Height - 1;
    for I := XMin to XMax do
      if not Odd(I) then
        for J := EvenYMin to EvenYMax do
          MapContainer.InsertHS(I, J, FLhx, Self, 0)
      else
        for J := OddYMin to OddYMax do
          MapContainer.InsertHS(I, J, FLhx, Self, 0);
  end;
  Result := True;
end;

function TLibraryHS.PlaceEx(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer; Level: Byte): Boolean;
begin
  FLevel := Level;
  Result := Place(MapContainer, Xhp, Yhp, Lhx);
end;

function TLibraryHS.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Result := Place(MapContainer, Xhp - 8, Yhp, Lhx);
end;

function TLibraryHS.PlaceHXEx(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt; Level: ShortInt;
  Center: Boolean): Boolean;
var
  Xhp, Yhp: Integer;
begin
  if Level <> -1 then FLevel := Level;
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Xhp := Xhp + 16 - FImage.Width shr 1;
  Yhp := Yhp + 16 - FImage.Height shr 1;
  Result := Place(MapContainer, Xhp, Yhp, Lhx);
end;

{ THSLibrary }

constructor THSLibrary.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FList := TList.Create;
end;

destructor THSLibrary.Destroy;
begin
  ClearList;
  FList.Free;
  inherited Destroy;
end;

procedure THSLibrary.SetEngine(Value: THexagonSpriteEngine);
var
  I: Integer;
begin
  if not (csDesigning in ComponentState) and (Value <> FEngine) then
  begin
    FEngine := Value;
    FHSEngine := FEngine.HSEngine;
    for I := FList.Count - 1 downto 0 do TLibraryHS(FList[I]).Remove;
  end;
end;

procedure THSLibrary.ClearList;
var
  I: Integer;
begin
  for I := FList.Count - 1 downto 0 do TLibraryHS(FList[I]).Destroy;
  FList.Clear;
end;

procedure THSLibrary.RemoveHS(HS: TLibraryHS);
begin
  FList.Remove(HS);
end;

function THSLibrary.CreateHS(Index: Integer): TLibraryHS;
var
  HS: TLibraryHS;
begin
  HS := TLibraryHS.Create(nil);
  HS.SetImage(Images[Index]);
  HS.FLibrary := Self;
  FList.Add(HS);
  Result := HS;
end;

procedure Register;
begin
  RegisterComponents('HS-Engine', [THSLibrary]);
end;

end.
