unit Hexagon;

{ The Hexagon unit of HSEPack.dpl: the plain terrain hexagon (THexagon, ClassID $20152) drawn from
  the first image of its resource's image library, with the transitions to the neighbour terrain
  on three sides from HexTrans.ILB (THexagonResource, ClassID $20153). }

interface

uses
  Windows, SysUtils, Classes, Engine, GFXE, ImageLib, HSEngine;

type
  { Hexagon.THexagon (instance size 20): +$10 FTransitions (the transition image of the sides 0..2),
    +$13 FTransitionSides (bits 0..2: the sides with a transition, bits 3..5: the shifted variants) }
  THexagon = class(TAbstractHexagon)
  private
    FTransitions: array[0..2] of Byte;
    FTransitionSides: Byte;
  public
    class function ClassID: Integer; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    procedure UpdateTransitions; override;
    procedure UpdateTransition(Side: Byte); virtual;
  end;

  { Hexagon.THexagonResource (instance size 56): +$34 FTransitionLibrary (HexTrans.ILB) }
  THexagonResource = class(TAbstractHexagonResource)
  private
    FTransitionLibrary: TCustomImageLibrary;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function PlaceResourceUser(Map: THSMap; Xhx, Yhx, Lhx: ShortInt): TMapObject; override;
    procedure Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc; Hexagon: THexagon);
  end;

procedure RegisterHexagon(Engine: TEngine);

implementation

{ THexagon }

class function THexagon.ClassID: Integer;
begin
  Result := $20152;
end;

procedure THexagon.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  THexagonResource(FResource).Show(Xhp - XhpSurf - 8, Yhp - YhpSurf, SurfaceDesc, Self);
end;

procedure THexagon.NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo);
begin
  if HN = 0 then
    case Info.HN of
      1: UpdateTransition(0);
      2: UpdateTransition(1);
      6: UpdateTransition(2);
    end;
end;

procedure THexagon.UpdateTransition(Side: Byte);
begin
end;

procedure THexagon.UpdateTransitions;
var
  Side: Byte;
begin
  for Side := 0 to 2 do UpdateTransition(Side);
end;

{ THexagonResource }

constructor THexagonResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(0);
end;

class function THexagonResource.ClassID: Integer;
begin
  Result := $20153;
end;

function THexagonResource.ResourceUserClassID: Integer;
begin
  Result := $20152;
end;

procedure THexagonResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
    FTransitionLibrary := FEngine.HSSet.ImageLibraryManager.LinkToIL([icDisk], 'HexTrans.ILB');
  if Msg.MsgID = $10055 then Msg.Result := 5;
end;

class function THexagonResource.ResourceEditName: string;
begin
  Result := HexagonStr;
end;

function THexagonResource.PlaceResourceUser(Map: THSMap; Xhx, Yhx, Lhx: ShortInt): TMapObject;
var
  MapField: TMapField;
begin
  MapField := Map.MapContainer.GetField(Xhx, Yhx, Lhx);
  Result := TMapObject(MapField.FindOwnedChild(ResourceUserClassID));
  if Result <> nil then
  begin
    if Result.GetTerrain(0) <> FTerrainList.GetTerrain(0) then
    begin
      Result.SetResource(Self);
      MapField.UpdateTerrainType;
      TAbstractHexagon(Result).UpdateTransitions;
    end
    else
      Result.SetResource(Self);
    Map.InvalidateStaticScene(Xhx, Yhx, Lhx);
  end
  else
  begin
    Result := TMapObject(CreateResourceUser);
    if not Result.PlaceHX(Map.MapContainer, Xhx, Yhx, Lhx) then
    begin
      Result.Free;
      Result := nil;
    end;
  end;
end;

procedure THexagonResource.Show(Xhp, Yhp: Integer; const SurfaceDesc: TSurfaceDesc;
  Hexagon: THexagon);
var
  Sides: Byte;
begin
  FImageLibrary[0].Show(Xhp, Yhp, SurfaceDesc);
  if Hexagon.FTransitionSides and 7 <> 0 then
  begin
    Sides := Hexagon.FTransitionSides;
    if Sides and 2 <> 0 then
      if Sides and $10 <> 0 then
        FTransitionLibrary[Hexagon.FTransitions[1]].Show(Xhp - 6, Yhp - 9 - 32, SurfaceDesc)
      else
        FTransitionLibrary[Hexagon.FTransitions[1]].Show(Xhp - 6, Yhp - 9, SurfaceDesc);
    if Sides and 1 <> 0 then
      if Sides and 8 <> 0 then
        FTransitionLibrary[Hexagon.FTransitions[0]].Show(Xhp - 6 - 32, Yhp - 9 - 16, SurfaceDesc)
      else
        FTransitionLibrary[Hexagon.FTransitions[0]].Show(Xhp - 6, Yhp - 9, SurfaceDesc);
    if Sides and 4 <> 0 then
      if Sides and $20 <> 0 then
        FTransitionLibrary[Hexagon.FTransitions[2]].Show(Xhp - 6 + 32, Yhp - 9 - 16, SurfaceDesc)
      else
        FTransitionLibrary[Hexagon.FTransitions[2]].Show(Xhp - 6, Yhp - 9, SurfaceDesc);
  end;
end;

procedure RegisterHexagon(Engine: TEngine);
begin
  Engine.RegisterEClasses([THexagon, THexagonResource]);
end;

end.
