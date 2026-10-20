unit Bridge;

{ The Bridge unit of HSEPack.dpl: a bridge over water (TBridge, ClassID $20174, an overlay at level
  10) whose image is chosen from the roads and shores around it (TBridgeResource, ClassID $20175). }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine, BorderHx;

type
  { Bridge.TBridge (instance size 20): +$10 FTransitions (two bits per side HN 1..6: 0 none, 1 a
    road, 2 the shore the bridge reaches) }
  TBridge = class(TAbstractRoad)
  private
    FTransitions: Word;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    procedure UpdateTransitions; override;
  end;

  { Bridge.TBridgeResource (instance size 52) }
  TBridgeResource = class(TAbstractRoadResource)
  public
    constructor Create(AOwner: TECustomNode); override;
    function ResourceUserClassID: Integer; override;
    class function ResourceEditName: string; override;
    class function ClassID: Integer; override;
    procedure Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc; Bridge: TBridge);
    function Editor: TClass; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

procedure RegisterBridge(Engine: TEngine);

implementation

{ TBridge }

constructor TBridge.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TBridge.ClassID: Integer;
begin
  Result := $20174;
end;

procedure TBridge.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  TBridgeResource(FResource).Show(Xhp - XhpSurf - 8 - 6, Yhp - YhpSurf - 9, SurfaceDesc, Self);
end;

{ Original oddity: the overlay of the owner of the previous owner (a map level, not a map field)
  is updated. }
function TBridge.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  MapField: TMapField;
  OldRoad: THexagonSprite;
  OldOwner: TMapField;
begin
  MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
  OldRoad := MapField.FindHS(TAbstractRoad);
  if OldRoad <> nil then OldRoad.Destroy;
  OldOwner := TMapField(Owner);
  Owner := MapField;
  FStatus := FStatus + [moPlacedOnMap];
  if OldOwner <> nil then TMapField(OldOwner.Owner).UpdateOverlayType;
  MapField.UpdateOverlayType;
  UpdateTransitions;
  MapContainer.Map.InvalidateStaticScene(Xhx, Yhx, Lhx);
  Result := True;
end;

procedure TBridge.UpdateTransitions;
var
  Sides: array[1..6] of Byte;
  Transitions: Integer;
  MaxDistance, MaxSide: Integer;
  HasRoad, InShore: Boolean;
  Xhx, Yhx: Integer;
  Shores: Integer;
  TerrainType: ShortInt;
  Level: TMapLevel;
  HN, Start, Shore, Distance: Integer;
  MapField: TMapField;
  IsShore: Boolean;
begin
  Transitions := 0;
  Level := TMapLevel(Owner.Owner);
  Shores := 0;
  InShore := False;
  for HN := 1 to 6 do
  begin
    HNtoHX(HN, Xhx, Yhx);
    TranslateHX(0, 0, TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhx, Yhx,
      Xhx, Yhx);
    if (Xhx >= 0) and (Yhx >= 0) and (Level.Width > Xhx) and (Level.Height > Yhx) then
    begin
      MapField := Level.GetField(Xhx, Yhx);
      TerrainType := MapField.TerrainType;
      HasRoad := MapField.FindHS(TAbstractRoad) <> nil;
      IsShore := (TerrainType <> 0) and
        (FResource.TerrainList.GetTerrain(0) <> TerrainType) and
        (MapField.FindHS(TBorderHexagon) = nil);
      if HasRoad then
      begin
        Sides[HN] := 1;
        InShore := False;
      end
      else if IsShore then
      begin
        if not InShore then Inc(Shores);
        Sides[HN] := Shores + 2;
        InShore := True;
      end
      else
      begin
        Sides[HN] := 0;
        InShore := False;
      end;
    end
    else
      Sides[HN] := 0;
  end;
  { the shores on side 1 and side 6 are one shore }
  if (Sides[1] > 2) and (Sides[6] > 2) and (Sides[1] <> Sides[6]) then
  begin
    for HN := 3 to 6 do
      if Sides[HN] = Sides[6] then Sides[HN] := Sides[1];
    Dec(Shores);
  end;
  { the side the bridge starts from: a road, else the first side without water }
  Start := 1;
  while (Start <= 6) and (Sides[Start] <> 1) do Inc(Start);
  if Start = 1 then
    if Sides[2] = 1 then Start := 2
    else if Sides[3] = 1 then Start := 3;
  if Start = 7 then
  begin
    Start := 1;
    while (Start <= 6) and (Sides[Start] = 0) do Inc(Start);
    if Start = 1 then
      if Sides[2] <> 0 then Start := 2
      else if Sides[3] = 0 then Start := 3;
  end;
  if Start <= 6 then
  begin
    { of every shore keep the side farthest from the start }
    for Shore := 3 to Shores + 2 do
    begin
      MaxDistance := 0;
      MaxSide := 0;
      if (Shore <> Sides[Start]) or (Shores = 1) then
      begin
        for HN := 1 to 6 do
          if Shore = Sides[HN] then
          begin
            Distance := Abs(HN - Start);
            if Distance > 3 then Distance := Abs(Distance - 6);
            if Distance > MaxDistance then
            begin
              MaxDistance := Distance;
              MaxSide := HN;
            end;
          end;
      end
      else
        MaxSide := Start;
      for HN := 1 to 6 do
        if (HN <> Start) and (Shore = Sides[HN]) then
          if HN <> MaxSide then Sides[HN] := 0 else Sides[HN] := 2;
    end;
    for HN := 1 to 6 do
      Inc(Transitions, Sides[HN] shl ((HN - 1) * 2));
  end;
  FTransitions := Transitions;
end;

{ TBridgeResource }

constructor TBridgeResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(10);
end;

function TBridgeResource.ResourceUserClassID: Integer;
begin
  Result := $20174;
end;

class function TBridgeResource.ResourceEditName: string;
begin
  Result := BridgeStr;
end;

class function TBridgeResource.ClassID: Integer;
begin
  Result := $20175;
end;

procedure TBridgeResource.Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc; Bridge: TBridge);
var
  Transitions: Integer;
  Base: Integer;
begin
  Transitions := Bridge.FTransitions;
  Base := 1;
  FImageLibrary[Base + 18].Show(Xhp, Yhp, SurfaceDesc);
  if Transitions and 3 <> 0 then
  begin
    if Transitions and 3 = 1 then FImageLibrary[Base + 6].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 12].Show(Xhp, Yhp, SurfaceDesc);
  end;
  if Transitions and $C <> 0 then
  begin
    if Transitions and $C = 4 then FImageLibrary[Base + 7].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 13].Show(Xhp, Yhp, SurfaceDesc);
  end;
  if Transitions and $30 <> 0 then
  begin
    if Transitions and $30 = $10 then FImageLibrary[Base + 8].Show(Xhp, Yhp, SurfaceDesc)
    else FImageLibrary[Base + 2].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 14].Show(Xhp, Yhp, SurfaceDesc);
  end;
  if Transitions and $C0 <> 0 then
  begin
    if Transitions and $C0 = $40 then FImageLibrary[Base + 9].Show(Xhp, Yhp, SurfaceDesc)
    else FImageLibrary[Base + 3].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 15].Show(Xhp, Yhp, SurfaceDesc);
  end;
  if Transitions and $300 <> 0 then
  begin
    if Transitions and $300 = $100 then FImageLibrary[Base + 10].Show(Xhp, Yhp, SurfaceDesc)
    else FImageLibrary[Base + 4].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 16].Show(Xhp, Yhp, SurfaceDesc);
  end;
  if Transitions and $C00 <> 0 then
  begin
    if Transitions and $C00 = $400 then FImageLibrary[Base + 11].Show(Xhp, Yhp, SurfaceDesc);
    FImageLibrary[Base + 17].Show(Xhp, Yhp, SurfaceDesc);
  end;
end;

function TBridgeResource.Editor: TClass;
begin
  Result := FEngine.Editors.FindEditor($20175);
  if Result = nil then Result := inherited Editor;
end;

procedure TBridgeResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID <> $10014 then inherited MsgProc(Msg, Sender);
end;

procedure RegisterBridge(Engine: TEngine);
begin
  Engine.RegisterEClasses([TBridge, TBridgeResource]);
end;

end.
