unit ILTer;

{ The ILTer unit of HSEPack.dpl: image library terrain, multi-hexagon objects that show one image
  per terrain type (TILTerrainMO, ClassID $20186; resource TILTerrainMOR, $20187), and the fixed
  variant that keeps its terrain type and updates the map terrain instead
  (TFixedILTerrainMO, $20188; TFixedILTerrainMOR, $20189). }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine;

type
  { ILTer.TILTerrainMO (instance size 28): +$14 FImageIndex, +$18 FTerrainType }
  TILTerrainMO = class(TMultiHexMO)
  private
    FImageIndex: Integer;
    FTerrainType: ShortInt;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetTerrain(Index: Integer): ShortInt; override;
    function CanChangeTerrain(const Info: THSSenderInfo): Boolean; override;
    procedure ChangeTerrain(const Info: THSTerrainInfo); override;
    procedure TerrainChanged(const Info: THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    function Loaded: Boolean; override;
    procedure Activate; override;
    function CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    function ValidTerrainType(TerrainType: Integer): Boolean; virtual;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; virtual;
    function ForceTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt; virtual;
    function GetValidTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt; virtual;
    property ImageIndex: Integer read FImageIndex;
    property TerrainType: ShortInt read FTerrainType;
  end;

  { ILTer.TILTerrainMOR (instance size 68) }
  TILTerrainMOR = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    procedure SetCellImage(Value: TLibraryImage); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { ILTer.TFixedILTerrainMO (instance size 28) }
  TFixedILTerrainMO = class(TILTerrainMO)
  public
    class function ClassID: Integer; override;
    function CanChangeTerrain(const Info: THSSenderInfo): Boolean; override;
    procedure ChangeTerrain(const Info: THSTerrainInfo); override;
    procedure TerrainChanged(const Info: THSTerrainInfo); override;
    function ForceTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
  end;

  { ILTer.TFixedILTerrainMOR (instance size 68) }
  TFixedILTerrainMOR = class(TILTerrainMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterILTerrain(Engine: TEngine);

implementation

{ TILTerrainMO }

constructor TILTerrainMO.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainType := -1;
end;

class function TILTerrainMO.ClassID: Integer;
begin
  Result := $20186;
end;

function TILTerrainMO.ForceTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin
  Result := -2;
end;

function TILTerrainMO.ValidTerrainType(TerrainType: Integer): Boolean;
var
  Index: Integer;
  Sequences: TImageSequenceList;
begin
  if TerrainType >= 0 then
  begin
    Index := GetTerrainTypeImage(TerrainType);
    Sequences := FResource.ImageSequenceList;
    if Sequences = nil then
      Result := FResource.ImageLibrary.ImageExist(Index)
    else
      Result := Sequences.GetImageSequence(Index) <> nil;
  end
  else
    Result := False;
end;

function TILTerrainMO.GetValidTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
var
  Count: Integer;
begin
  Result := GetMostFrequentMapFieldTerrainType(MapLevel, Xhx, Yhx, -1);
  if not ValidTerrainType(Result) then
  begin
    Result := ForceTerrainType(MapLevel, Xhx, Yhx);
    if GetEditMode or (Result <> -2) then
      if not ValidTerrainType(Result) then
      begin
        Result := 0;
        Count := FResource.Engine.HSSet.TerrainTypes.Count;
        while (Result < Count) and not ValidTerrainType(Result) do Inc(Result);
        if Result = Count then Result := -1;
      end;
  end;
end;

function TILTerrainMO.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  Result := TerrainType;
end;

function TILTerrainMO.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    Result := GetMostFrequentMapFieldTerrainType(TMapLevel(Owner.Owner), FXhx,
      FYhx, FTerrainType) = Info.MapField.TerrainType
  else
    Result := True;
end;

procedure TILTerrainMO.TerrainChanged(const Info: THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end
    else
      Destroy;
end;

procedure TILTerrainMO.ChangeTerrain(const Info: THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end
    else
      Destroy;
end;

function TILTerrainMO.GetTerrain(Index: Integer): ShortInt;
begin
  Result := FResource.TerrainList.GetTerrain(Index);
  if Result >= 0 then Result := FTerrainType;
end;

procedure TILTerrainMO.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  with FResource do
    if ImageSequenceList = nil then
      ImageLibrary[FImageIndex].Show(
        Xhp - XhpSurf + TMultiHexMOR(Self.FResource).dXImage,
        Yhp - YhpSurf + TMultiHexMOR(Self.FResource).dYImage, SurfaceDesc)
    else
      ShowComplexImage(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc, FImageIndex, Xhp + Yhp);
end;

function TILTerrainMO.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then
    FTerrainType := GetValidTerrainType(TMapLevel(Owner.Owner), FXhx, FYhx);
end;

function TILTerrainMO.Loaded: Boolean;
begin
  Result := inherited PlaceOnMap;
end;

function TILTerrainMO.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  CanPlaceHere: Boolean;
  Count: Integer;
  TerrainType: ShortInt;
  I: Integer;
  Walk: THNWalkData;
  Overlay: ShortInt;
  HS: THexagonSprite;
  TerrainList: TTerrainList;
begin
  CanPlaceHere := True;
  Count := FResource.TerrainList.Count;
  FTerrainType := GetValidTerrainType(MapContainer.GetMapLevel(Lhx), Xhx, Yhx);
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while CanPlaceHere and (Walk.HN < Count) do
  begin
    TerrainType := GetTerrain(Walk.HN);
    Overlay := GetOverlay(Walk.HN);
    if ((TerrainType >= 0) or (Overlay >= 0)) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapContainer.Width) and (Walk.Y < MapContainer.Height) then
    begin
      HS := MapContainer.GetField(Walk.X, Walk.Y, Lhx).GetMaxLevelNoneTransparentHS;
      CanPlaceHere := (HS = nil) or CanPlaceOnHS(HS);
    end;
    WalkToNextHN(Walk);
  end;
  if CanPlaceHere then
  begin
    TerrainList := TTerrainList.Create;
    TerrainList.Assign(FResource.TerrainList);
    for I := 0 to TerrainList.Count - 1 do
      if TerrainList.GetTerrain(I) >= 0 then TerrainList.SetTerrain(I, FTerrainType);
    CanPlaceHere := CanPlaceHere and
      MapContainer.Map.CanChangeTerrain(Self, Xhx, Yhx, Lhx, TerrainList);
    TerrainList.Free;
  end;
  Result := CanPlaceHere;
end;

function TILTerrainMO.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
  if Result then
  begin
    Result := False;
    FTerrainType := GetValidTerrainType(MapContainer.GetMapLevel(Lhx), Xhx, Yhx);
    if FTerrainType >= 0 then
    begin
      FImageIndex := GetTerrainTypeImage(FTerrainType);
      if FImageIndex <> -1 then
      begin
        if not GetEditMode then OverrideTerrain;
        Result := True;
      end;
    end;
  end;
end;

procedure TILTerrainMO.Activate;
begin
  inherited Activate;
  FTerrainType := GetValidTerrainType(TMapLevel(Owner.Owner), FXhx, FYhx);
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

{ TILTerrainMOR }

class function TILTerrainMOR.ResourceEditName: string;
begin
  Result := 'ImageLibrary Terrain';
end;

class function TILTerrainMOR.ClassID: Integer;
begin
  Result := $20187;
end;

function TILTerrainMOR.ResourceUserClassID: Integer;
begin
  Result := $20186;
end;

procedure TILTerrainMOR.SetCellImage(Value: TLibraryImage);
begin
end;

{ TFixedILTerrainMO }

class function TFixedILTerrainMO.ClassID: Integer;
begin
  Result := $20188;
end;

function TFixedILTerrainMO.ForceTerrainType(MapLevel: TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin
  Result := -1;
end;

function TFixedILTerrainMO.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    Result := ValidTerrainType(Info.MapField.TerrainType) and
      (GetMostFrequentMapFieldTerrainType(TMapLevel(Owner.Owner), FXhx, FYhx,
      FResource.TerrainList.GetTerrain(Info.HN)) = Info.MapField.TerrainType)
  else
    Result := True;
end;

procedure TFixedILTerrainMO.ChangeTerrain(const Info: THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end;
end;

procedure TFixedILTerrainMO.TerrainChanged(const Info: THSTerrainInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    if ValidTerrainType(Info.TerrainType) then
    begin
      FTerrainType := Info.TerrainType;
      UpdateTerrain(TMapLevel(Owner.Owner), FXhx, FYhx);
      FImageIndex := GetTerrainTypeImage(Info.TerrainType);
    end
    else
      try
        raise Exception.Create('TILFixedTerrain Failure');
      except
        Destroy;
      end;
end;

{ TFixedILTerrainMOR }

class function TFixedILTerrainMOR.ResourceEditName: string;
begin
  Result := 'Fixed ImageLibrary Terrain';
end;

class function TFixedILTerrainMOR.ClassID: Integer;
begin
  Result := $20189;
end;

function TFixedILTerrainMOR.ResourceUserClassID: Integer;
begin
  Result := $20188;
end;

procedure RegisterILTerrain(Engine: TEngine);
begin
  Engine.RegisterEClasses([TILTerrainMO, TILTerrainMOR]);
  Engine.RegisterEClasses([TFixedILTerrainMO, TFixedILTerrainMOR]);
end;

end.
