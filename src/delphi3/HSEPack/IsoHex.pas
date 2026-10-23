unit IsoHex;

{ The IsoHex unit of HSEPack.dpl: isometric hexagons, terrain hexagons drawn from the first image
  sequence of their resource with the walls towards the neighbours that are not hexagons of the
  same kind. The walls are drawn by a TDynamicIsometricHexagon (ClassID $2016F) that the hexagon
  creates while it has open sides; it sits in the dynamic scene at the level of the resource.
  TIsometricHexagon $2016D (resource $2016E), TUpperIsometricHexagon $20170 ($20171),
  TLowerIsometricHexagon $20172 ($20173). }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine, BorderHx;

type
  TIsometricHexagon = class;

  { IsoHex.TDynamicIsometricHexagon (instance size 8): owned by its TIsometricHexagon (FOwner set
    directly, so it is not added as a child) and shown from the map field of that hexagon }
  TDynamicIsometricHexagon = class(THexagonSprite)
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetXhx: ShortInt; override;
    function GetYhx: ShortInt; override;
    function GetLhx: ShortInt; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    class function ControlMode: TControlMode; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
  end;

  TDynamicIsometricHexagonClass = class of TDynamicIsometricHexagon;

  { IsoHex.TIsometricHexagon (instance size 24): +$10 FDynamic, +$14 FOpenSides (bit HN-1: the
    neighbour HN is no hexagon of this kind), +$15 FSides (bits 0..5: the neighbour HN has another
    terrain, bits 6..7: the image variant) }
  TIsometricHexagon = class(TAbstractHexagon)
  protected
    FDynamic: TDynamicIsometricHexagon;
    FOpenSides: Byte;
    FSides: Byte;
  public
    destructor Destroy; override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Disconnect; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    class function DynamicIsometricHexagonClass: TDynamicIsometricHexagonClass; virtual;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); virtual;
  end;

  { IsoHex.TIsometricHexagonResource (instance size 56): +$34 FDynamicLevel (26) }
  TIsometricHexagonResource = class(TAbstractHexagonResource)
  protected
    FDynamicLevel: Byte;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function PlaceResourceUser(Map: THSMap; Xhx, Yhx, Lhx: ShortInt): TMapObject; override;
  end;

  { IsoHex.TUpperIsometricHexagon (instance size 24) }
  TUpperIsometricHexagon = class(TIsometricHexagon)
  public
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    procedure UpdateTransitions; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
  end;

  { IsoHex.TUpperIsometricHexagonResource (instance size 56) }
  TUpperIsometricHexagonResource = class(TIsometricHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { IsoHex.TLowerIsometricHexagon (instance size 24) }
  TLowerIsometricHexagon = class(TIsometricHexagon)
  public
    class function ClassID: Integer; override;
    procedure UpdateTransitions; override;
    procedure ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
  end;

  { IsoHex.TLowerIsometricHexagonResource (instance size 56) }
  TLowerIsometricHexagonResource = class(TIsometricHexagonResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterIsometricHexagon(Engine: TEngine);

implementation {$IFDEF RUNTIME_PACKAGES} uses ILTer; {$ENDIF}

{ TDynamicIsometricHexagon }

constructor TDynamicIsometricHexagon.Create(AOwner: TECustomNode);
begin
  inherited Create(nil);
  FOwner := AOwner;
  TMapField(AOwner.Owner).AddHS(Self, 0);
end;

destructor TDynamicIsometricHexagon.Destroy;
begin
  if TIsometricHexagon(Owner).GetVisible then
    TMapLevel(Owner.Owner.Owner).Map.DynamicVisibleHS.RemoveChild(Self);
  TMapField(Owner.Owner).RemoveHS(Self);
  TIsometricHexagon(Owner).FDynamic := nil;
  FOwner := nil;
  inherited Destroy;
end;

class function TDynamicIsometricHexagon.ClassID: Integer;
begin
  Result := $2016F;
end;

function TDynamicIsometricHexagon.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := False;
end;

function TDynamicIsometricHexagon.GetControlStyle: TEControlStyles;
begin
  Result := [];
end;

class function TDynamicIsometricHexagon.ControlMode: TControlMode;
begin
  Result := [];
end;

function TDynamicIsometricHexagon.GetXhx: ShortInt;
begin
  Result := TMapField(Owner.Owner).Xhx;
end;

function TDynamicIsometricHexagon.GetYhx: ShortInt;
begin
  Result := TMapField(Owner.Owner).Yhx;
end;

function TDynamicIsometricHexagon.GetLhx: ShortInt;
begin
  Result := TMapField(Owner.Owner).Lhx;
end;

procedure TDynamicIsometricHexagon.SetVisible(Value: Boolean);
begin
end;

function TDynamicIsometricHexagon.GetVisible: Boolean;
begin
  Result := False;
end;

function TDynamicIsometricHexagon.GetShowPriority: Integer;
var



  Xhp, Yhp: Integer;
begin



  Xhp := TMapField(Owner.Owner).Xhx * 32 + 8;
  Yhp := (TMapField(Owner.Owner).Xhx and 1) * 16 + TMapField(Owner.Owner).Yhx * 32;
  Result := TIsometricHexagonResource(TIsometricHexagon(Owner).FResource).FDynamicLevel shl 26 +
    (Yhp + 32) shl 13 + (Xhp + 8);
end;

function TDynamicIsometricHexagon.GetLevel: Byte;
begin
  Result := TIsometricHexagonResource(TIsometricHexagon(Owner).FResource).FDynamicLevel;
end;

procedure TDynamicIsometricHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  TIsometricHexagon(Owner).ShowDynamic(XhpSurf, YhpSurf, SurfaceDesc);
end;

{ TIsometricHexagon }

constructor TIsometricHexagon.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSides := Random(4) shl 6;
end;

destructor TIsometricHexagon.Destroy;
begin
  if FDynamic <> nil then
  begin
    FDynamic.Free;
    FDynamic := nil;
  end;
  inherited Destroy;
end;

class function TIsometricHexagon.ClassID: Integer;
begin
  Result := $2016D;
end;

class function TIsometricHexagon.DynamicIsometricHexagonClass: TDynamicIsometricHexagonClass;
begin
  Result := TDynamicIsometricHexagon;
end;

procedure TIsometricHexagon.Disconnect;
begin
  if FDynamic <> nil then
  begin
    FDynamic.Free;
    FDynamic := nil;
  end;
  inherited Disconnect;
end;

procedure TIsometricHexagon.NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo);
begin
  UpdateTransitions;
end;

procedure TIsometricHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  IL: TCustomImageLibrary;
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  IL[FSides shr 6 + 40].Show(Xhp, Yhp, SurfaceDesc);
  Dec(Xhp, 6);
  Dec(Yhp, 9);
  if FSides and 1 <> 0 then IL[31].Show(Xhp, Yhp, SurfaceDesc);
  if FSides and 2 <> 0 then IL[32].Show(Xhp, Yhp, SurfaceDesc);
  if FSides and $20 <> 0 then IL[30].Show(Xhp, Yhp, SurfaceDesc);
end;

procedure TIsometricHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
end;

{ TIsometricHexagonResource }

constructor TIsometricHexagonResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FDynamicLevel := 26;
end;

class function TIsometricHexagonResource.ClassID: Integer;
begin
  Result := $2016E;
end;

function TIsometricHexagonResource.PlaceResourceUser(Map: THSMap; Xhx, Yhx, Lhx: ShortInt): TMapObject;
var
  MapField: TMapField;
begin
  MapField := Map.MapContainer.GetField(Xhx, Yhx, Lhx);
  Result := TMapObject(MapField.FindOwnedHS(TIsometricHexagon));
  if Result <> nil then
  begin
    if Result.GetTerrain(0) <> FTerrainList.GetTerrain(0) then
    begin
      Result.SetResource(Self);
      MapField.UpdateTerrainType;
      TIsometricHexagon(Result).UpdateTransitions;
    end
    else
      Result.SetResource(Self);
    Map.InvalidateStaticScene(Xhx, Yhx, Lhx);
  end
  else
  begin
    Result := TMapObject(CreateResourceUser);
    if not Map.PlaceHX(Result, Xhx, Yhx, Lhx) then
    begin
      Result.Free;
      Result := nil;
    end;
  end;
end;

procedure TIsometricHexagonResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10055 then Msg.Result := 5;
end;

{ TUpperIsometricHexagon }

class function TUpperIsometricHexagon.ClassID: Integer;
begin
  Result := $20170;
end;

procedure TUpperIsometricHexagon.UpdateTransitions;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapField: TMapField;
  HS: THexagonSprite;
begin
  FOpenSides := 0;
  FSides := FSides and $C0;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 1);
  while Walk.HN <= 6 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and
      (Walk.Y < Level.Height) then
    begin
      MapField := Level.GetField(Walk.X, Walk.Y);
      HS := MapField.FindOwnedHS(TUpperIsometricHexagon);
      if HS = nil then HS := MapField.FindOwnedHS(TBorderHexagon);
      if HS = nil then
        FOpenSides := FOpenSides or (1 shl (Walk.HN - 1))
      else if Level.GetField(Walk.X, Walk.Y).TerrainType <> GetTerrain(0) then
        FSides := FSides or (1 shl (Walk.HN - 1));
    end;
    WalkToNextHN(Walk);
  end;
  if FOpenSides <> 0 then
  begin
    if FDynamic = nil then FDynamic := DynamicIsometricHexagonClass.Create(TECustomNode(Self));
  end
  else if FDynamic <> nil then
  begin
    FDynamic.Free;
    FDynamic := nil;
    FSides := Random(4) shl 6;
    FResource.Engine.HSMap.InvalidateStaticScene(
      TMapField(Owner).Xhx, TMapField(Owner).Yhx, TMapField(Owner).Lhx);
  end;
end;

procedure TUpperIsometricHexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  IL: TCustomImageLibrary;
  Xhp, Yhp: Integer;
begin
  if FDynamic = nil then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    Xhp := Xhp - XhpSurf - 8;
    Yhp := Yhp - YhpSurf;
    IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
    IL[FSides shr 6 + 40].Show(Xhp, Yhp, SurfaceDesc);
    Dec(Xhp, 6);
    Dec(Yhp, 9);
    if FSides and 1 <> 0 then IL[31].Show(Xhp, Yhp, SurfaceDesc);
    if FSides and 2 <> 0 then IL[32].Show(Xhp, Yhp, SurfaceDesc);
    if FSides and $20 <> 0 then IL[30].Show(Xhp, Yhp, SurfaceDesc);
  end;
end;

procedure TUpperIsometricHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  IL: TCustomImageLibrary;
  Xhp, Yhp: Integer;
  Variant: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  Variant := (Integer(Self) shr 8) and 3;
  if Variant = 3 then Variant := 0;
  IL[FSides shr 6 + 40].Show(Xhp, Yhp, SurfaceDesc);
  if FOpenSides <> 0 then
  begin
    if FOpenSides and 1 <> 0 then
    begin
      if FOpenSides and $20 = 0 then IL[18].Show(Xhp - 19, Yhp - 48 - 16, SurfaceDesc);
      if FOpenSides and 2 = 0 then IL[19].Show(Xhp - 19, Yhp - 48 - 16, SurfaceDesc);
      if FOpenSides and $22 = $22 then
        IL[23].Show(Xhp - 20, Yhp - 48 - 16, SurfaceDesc)
      else if FOpenSides and $22 = 0 then
        IL[20].Show(Xhp - 20, Yhp - 50 - 16, SurfaceDesc);
    end;
    if FOpenSides and 8 <> 0 then
    begin
      if FOpenSides and $10 <> 0 then
        if FOpenSides and $20 <> 0 then
          IL[17].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 3].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc);
      if FOpenSides and 4 <> 0 then
        if FOpenSides and 2 <> 0 then
          IL[16].Show(Xhp - 19 + 16 + 16, Yhp - 16, SurfaceDesc)
        else
          IL[Variant].Show(Xhp - 19 + 16 + 16, Yhp - 16, SurfaceDesc);
      if FOpenSides and $14 = $14 then
        IL[13].Show(Xhp - 19, Yhp, SurfaceDesc)
      else if FOpenSides and $14 = 0 then
        IL[6].Show(Xhp - 19, Yhp, SurfaceDesc);
    end
    else
    begin
      if FOpenSides and $10 <> 0 then
        if FOpenSides and $20 = 0 then
          IL[25].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else if FOpenSides and 1 <> 0 then
          IL[15].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 10].Show(Xhp - 19 - 32, Yhp - 16, SurfaceDesc);
      if FOpenSides and 4 <> 0 then
        if FOpenSides and 2 = 0 then
          IL[24].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc)
        else if FOpenSides and 1 <> 0 then
          IL[14].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc)
        else
          IL[Variant + 7].Show(Xhp - 19 + 32, Yhp - 16, SurfaceDesc);
    end;
  end;
end;

{ TUpperIsometricHexagonResource }

class function TUpperIsometricHexagonResource.ClassID: Integer;
begin
  Result := $20171;
end;

function TUpperIsometricHexagonResource.ResourceUserClassID: Integer;
begin
  Result := $20170;
end;

class function TUpperIsometricHexagonResource.ResourceEditName: string;
begin
  Result := UpperIsometricHexagonStr;
end;

{ TLowerIsometricHexagon }

class function TLowerIsometricHexagon.ClassID: Integer;
begin
  Result := $20172;
end;

procedure TLowerIsometricHexagon.UpdateTransitions;
var
  Walk: THNWalkData;
  Level: TMapLevel;
  MapField: TMapField;
  HS: THexagonSprite;
begin
  FOpenSides := 0;
  FSides := FSides and $C0;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, TMapField(Owner).Xhx, TMapField(Owner).Yhx, 1);
  while Walk.HN <= 6 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and
      (Walk.Y < Level.Height) then
    begin
      MapField := Level.GetField(Walk.X, Walk.Y);
      HS := MapField.FindOwnedHS(TLowerIsometricHexagon);
      if HS = nil then HS := MapField.FindOwnedHS(TBorderHexagon);
      if HS = nil then
        FOpenSides := FOpenSides or (1 shl (Walk.HN - 1))
      else if Level.GetField(Walk.X, Walk.Y).TerrainType <> GetTerrain(0) then
        FSides := FSides or (1 shl (Walk.HN - 1));
    end;
    WalkToNextHN(Walk);
  end;
  if FOpenSides <> 0 then
  begin
    if FDynamic = nil then FDynamic := DynamicIsometricHexagonClass.Create(TECustomNode(Self));
  end
  else if FDynamic <> nil then
  begin
    FDynamic.Free;
    FDynamic := nil;
    FSides := Random(4) shl 6;
    FResource.Engine.HSMap.InvalidateStaticScene(
      TMapField(Owner).Xhx, TMapField(Owner).Yhx, TMapField(Owner).Lhx);
  end;
end;

{ IL[Variant + 0] reproduces the original's lea edx, [esi] for the index. }
procedure TLowerIsometricHexagon.ShowDynamic(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  IL: TCustomImageLibrary;
  Xhp, Yhp: Integer;
  Variant: Integer;
  X, Y: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Xhp := Xhp - XhpSurf - 8;
  Yhp := Yhp - YhpSurf;
  IL := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  Variant := (Integer(Self) shr 8) and 3;
  if Variant = 3 then Variant := 0;
  if FOpenSides <> 0 then
  begin
    X := Xhp - 19;
    Y := Yhp - 32;
    if FOpenSides and 1 <> 0 then
    begin
      if FOpenSides and $23 = $23 then
        IL[6].Show(X, Y, SurfaceDesc)
      else if FOpenSides and $23 = 1 then
        IL[13].Show(X, Y, SurfaceDesc);
      if FOpenSides and 7 = 7 then
        IL[25].Show(X, Y, SurfaceDesc)
      else if FOpenSides and 3 = 3 then
        IL[Variant + 3].Show(X, Y, SurfaceDesc);
      if FOpenSides and $31 = $31 then
        IL[24].Show(X, Y, SurfaceDesc)
      else if FOpenSides and $21 = $21 then
        IL[Variant + 0].Show(X, Y, SurfaceDesc);
    end
    else
    begin
      if FOpenSides and 6 = 6 then
        IL[Variant + 10].Show(X, Y, SurfaceDesc)
      else if FOpenSides and 2 = 2 then
        IL[17].Show(X, Y, SurfaceDesc);
      if FOpenSides and $30 = $30 then
        IL[Variant + 7].Show(X, Y, SurfaceDesc)
      else if FOpenSides and $20 = $20 then
        IL[16].Show(X, Y, SurfaceDesc);
    end;
    if FOpenSides and 8 <> 0 then
    begin
      if FOpenSides and $E = $E then
        IL[22].Show(X, Y + 1, SurfaceDesc)
      else if FOpenSides and $C = $C then
        if Variant = 2 then
          IL[19].Show(X, Y + 1, SurfaceDesc)
        else
          IL[Variant + 30].Show(X, Y + 1, SurfaceDesc);
      if FOpenSides and $38 = $38 then
        IL[21].Show(X, Y, SurfaceDesc)
      else if FOpenSides and $18 = $18 then
        if Variant = 2 then
          IL[18].Show(X, Y + 1, SurfaceDesc)
        else
          IL[Variant + 28].Show(X, Y, SurfaceDesc);
      if FOpenSides and $1C = 8 then IL[23].Show(X, Y, SurfaceDesc);
    end
    else if FOpenSides and $E = 4 then
      IL[15].Show(X, Y, SurfaceDesc)
    else if FOpenSides and $38 = $10 then
      IL[14].Show(X, Y, SurfaceDesc);
  end;
end;

{ TLowerIsometricHexagonResource }

class function TLowerIsometricHexagonResource.ClassID: Integer;
begin
  Result := $20173;
end;

class function TLowerIsometricHexagonResource.ResourceEditName: string;
begin
  Result := LowerIsometricHexagonStr;
end;

function TLowerIsometricHexagonResource.ResourceUserClassID: Integer;
begin
  Result := $20172;
end;

procedure RegisterIsometricHexagon(Engine: TEngine);
begin
  Engine.RegisterEClasses([TIsometricHexagon, TIsometricHexagonResource, TUpperIsometricHexagon,
    TUpperIsometricHexagonResource, TLowerIsometricHexagon, TLowerIsometricHexagonResource]);
end;

end.
