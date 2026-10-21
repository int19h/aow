unit CombatRoad;

{ CombatRoad, AoWTCPCK.dpl. Original layouts and VMT order.
  TCombatRoad: size $18; $10 main image, $11..$16 neighbour images, $17 padding.
  TCombatRoadResource: size $34, no added fields. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCombatRoad = class;
  TCombatRoadResource = class;


  { TCombatRoad (instance size 24, VMT 00410C0C) }
  TCombatRoad = class(TAbstractRoad)
  public
    FImages: array[0..6] of Byte; { $10 main image, $11..$16 neighbour images }
    FReserved17: Byte;
    class function ClassID: Integer; override;
    procedure NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; override;
    procedure UpdateTransition(HN: Byte);
  end;

  { TCombatRoadResource (instance size 52, VMT 00410DA0) }
  TCombatRoadResource = class(TAbstractRoadResource)
  public
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    function GetRoadControl: HSEngine.TRoadControl; override;
  end;

procedure RegisterCombatRoad(AEngine: TEngine);

implementation

class function TCombatRoad.ClassID: Integer;
begin Result := $220502; end;

function TCombatRoad.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

function TCombatRoad.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  if (Xhx >= 0) and (Yhx >= 0) and (Lhx >= 0) and
    (Xhx < MapContainer.Width) and (Yhx < MapContainer.Height) and (Lhx < MapContainer.LevelCount) then
    Result := not ((MapContainer.GetField(Xhx, Yhx, Lhx).OverlayType = 4) or
      (MapContainer.GetField(Xhx, Yhx, Lhx).TerrainType = 15))
  else Result := False;
end;

function TCombatRoad.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  MapField: TMapField;
  OldRoad: THexagonSprite;
begin
  MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
  OldRoad := MapField.FindHS(TAbstractRoad);
  if OldRoad <> nil then OldRoad.Destroy;
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

procedure TCombatRoad.UpdateTransition(HN: Byte);
var
  MapLevel: TMapLevel;
  Overlay: Shortint;
  X, Y: Integer;
begin
  MapLevel := TMapLevel(Owner.Owner);
  CenterHNtoHX(TMapField(Owner).Xhx, TMapField(Owner).Yhx, HN, X, Y);
  if (X >= 0) and (Y >= 0) and (X < MapLevel.Width) and (Y < MapLevel.Height) then
  begin
    Overlay := MapLevel.GetField(X, Y).OverlayType;
    if Overlay <> 4 then
      case HN of
        1: FImages[HN] := Random(2) * 3 + 1;
        2: FImages[HN] := Random(2) * 3 + 2;
        3: FImages[HN] := 6;
        4: FImages[HN] := 7;
        5: FImages[HN] := 8;
        6: FImages[HN] := Random(2) * 3;
      end
    else FImages[HN] := $FF;
  end;
end;

procedure TCombatRoad.UpdateTransitions;
var
  I: Integer;
begin
  for I := 1 to 6 do UpdateTransition(I);
end;

procedure TCombatRoad.NeighbourTerrainChanged(HN: Integer; const Msg: HSEngine.THSTerrainInfo);
begin
  if HN = 0 then UpdateTransition(Msg.HN);
end;

procedure TCombatRoad.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Images: TCustomImageLibrary;
  X, Y, I: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  X := X - XhpSurf - 8;
  Y := Y - YhpSurf;
  Images := FResource.ImageSequenceList.GetImageSequence(0).ImageLibrary;
  Images.Get(FImages[0]).Show(X, Y, SurfaceDesc);
  for I := 1 to 6 do
    if FImages[I] <> $FF then Images.Get(FImages[I]).Show(X - 8, Y - 16, SurfaceDesc);
end;

procedure TCombatRoad.Activate;
begin
  inherited Activate;
  FImages[0] := Random(12) + 10;
end;

class function TCombatRoadResource.ClassID: Integer;
begin Result := $220503; end;

class function TCombatRoadResource.ResourceEditName: string;
begin Result := 'Combat Road'; end;

function TCombatRoadResource.GetRoadControl: HSEngine.TRoadControl;
begin
  Result := TAoWHSSet(Engine.HSSet).FCombatRoads;
end;

procedure TCombatRoadResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10055 then Msg.Result := 5;
end;

function TCombatRoadResource.ResourceUserClassID: Integer;
begin Result := $220502; end;

function TCombatRoadResource.GetCellImage: ImageLib.TLibraryImage;
begin
  Result := nil;
  if (ImageSequenceList <> nil) and (ImageSequenceList.Count > 0) and
    (ImageSequenceList.GetImageSequence(0) <> nil) then
    Result := ImageSequenceList.GetImageSequence(0).ImageLibrary.Get(10);
  if Result = nil then Result := inherited GetCellImage;
end;

procedure RegisterCombatRoad(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatRoadResource, TCombatRoad]);
end;


initialization
finalization

end.
