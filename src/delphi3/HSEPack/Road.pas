unit Road;

{ The Road unit of HSEPack.dpl: a road on a hexagon (TRoad, ClassID $20164) whose image is chosen
  from the roads on the six neighbour hexagons (TRoadResource, ClassID $20165). }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine;

type
  { Road.TRoad (instance size 20): +$10 FTransitions (bit HN-1: a road on the neighbour HN; the
    pairs 2+6 and 3+5 become bits 7 and 6) }
  TRoad = class(TAbstractRoad)
  protected
    FTransitions: Byte;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean; override;
    procedure UpdateTransitions; override;
    procedure UpdateNeighbourTransitions;
  end;

  { Road.TRoadResource (instance size 52) }
  TRoadResource = class(TAbstractRoadResource)
  public
    function ResourceUserClassID: Integer; override;
    class function ResourceEditName: string; override;
    class function ClassID: Integer; override;
    procedure Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc; Road: TRoad);
    function Editor: TClass; override;
  end;

procedure RegisterRoad(Engine: TEngine);

implementation

{ TRoad }

constructor TRoad.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TRoad.ClassID: Integer;
begin
  Result := $20164;
end;

procedure TRoad.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  TRoadResource(FResource).Show(Xhp - XhpSurf - 8 - 6, Yhp - YhpSurf - 9, SurfaceDesc, Self);
end;

function TRoad.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  MapField: TMapField;
  OldRoad: THexagonSprite;
begin
  MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
  OldRoad := MapField.FindOwnedHS(TAbstractRoad);
  if OldRoad <> nil then OldRoad.Destroy;
  Owner := MapField;
  Result := PlaceOnMap;
  UpdateTransitions;
  UpdateNeighbourTransitions;
end;

procedure TRoad.UpdateTransitions;
var
  Xhx, Yhx: Integer;
  Level: TMapLevel;
  HN: Integer;
  MapField: TMapField;
  HasRoad: Boolean;
begin
  Level := TMapLevel(Owner.Owner);
  FTransitions := 0;
  for HN := 1 to 6 do
  begin
    HNtoHX(HN, Xhx, Yhx);
    TranslateHX(0, 0, TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhx, Yhx,
      Xhx, Yhx);
    if (Xhx >= 0) and (Yhx >= 0) and (Level.Width > Xhx) and (Level.Height > Yhx) then
    begin
      MapField := Level.GetField(Xhx, Yhx);
      HasRoad := MapField.FindOwnedHS(TAbstractRoad) <> nil;
      if HasRoad then
        Inc(FTransitions, 1 shl (HN - 1));
    end;
  end;
  if FTransitions and $22 = $22 then FTransitions := FTransitions and $DD + $80;
  if FTransitions and $14 = $14 then FTransitions := FTransitions and $EB + $40;
end;

procedure TRoad.UpdateNeighbourTransitions;
var
  Xhx, Yhx: Integer;
  Level: TMapLevel;
  HN: Integer;
  MapField: TMapField;
  Road: TAbstractRoad;
begin
  Level := TMapLevel(Owner.Owner);
  for HN := 1 to 6 do
  begin
    HNtoHX(HN, Xhx, Yhx);
    TranslateHX(0, 0, TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhx, Yhx,
      Xhx, Yhx);
    if (Xhx >= 0) and (Yhx >= 0) and (Xhx < Level.Width) and (Yhx < Level.Height) then
    begin
      MapField := Level.GetField(Xhx, Yhx);
      Road := TAbstractRoad(MapField.FindChild($20164));
      if Road <> nil then Road.UpdateTransitions;
    end;
  end;
end;

{ TRoadResource }

function TRoadResource.ResourceUserClassID: Integer;
begin
  Result := $20164;
end;

class function TRoadResource.ResourceEditName: string;
begin
  Result := 'Road';
end;

class function TRoadResource.ClassID: Integer;
begin
  Result := $20165;
end;

procedure TRoadResource.Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc; Road: TRoad);
var
  Transitions: Byte;
  Base: Byte;
begin
  Transitions := Road.FTransitions;
  Base := 1;
  if Transitions <> 0 then
  begin
    if Transitions and $40 = 0 then
    begin
      if Transitions and $10 <> 0 then FImageLibrary[Base + 4].Show(Xhp, Yhp, SurfaceDesc);
      if Transitions and 4 <> 0 then FImageLibrary[Base + 2].Show(Xhp, Yhp, SurfaceDesc);
    end
    else
      FImageLibrary[Base + 6].Show(Xhp, Yhp, SurfaceDesc);
    if Transitions and $80 = 0 then
    begin
      if Transitions and 2 <> 0 then FImageLibrary[Base + 1].Show(Xhp, Yhp, SurfaceDesc);
      if Transitions and $20 <> 0 then FImageLibrary[Base + 5].Show(Xhp, Yhp, SurfaceDesc);
    end
    else
      FImageLibrary[Base + 7].Show(Xhp, Yhp, SurfaceDesc);
    if Transitions and 1 <> 0 then FImageLibrary[Base].Show(Xhp, Yhp, SurfaceDesc);
    if Transitions and 8 <> 0 then FImageLibrary[Base + 3].Show(Xhp, Yhp, SurfaceDesc);
  end
  else
    FImageLibrary[Base + 6].Show(Xhp, Yhp, SurfaceDesc);
end;

function TRoadResource.Editor: TClass;
begin
  Result := FEngine.Editors.FindEditor($20165);
  if Result = nil then Result := inherited Editor;
end;

procedure RegisterRoad(Engine: TEngine);
begin
  Engine.RegisterEClasses([TRoad, TRoadResource]);
end;

end.
