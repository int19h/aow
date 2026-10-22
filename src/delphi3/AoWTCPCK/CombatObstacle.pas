unit CombatObstacle;

{ CombatObstacle, AoWTCPCK.dpl. Original layouts and VMT order.
  Shadow and overlay: $08 obstacle. Obstacle: $14 shadow, $18 overlay. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TCombatObstacleShadow = class;
  TCombatObstacleOverlay = class;
  TCombatObstacle = class;
  TCombatObstacleResource = class;


  { TCombatObstacleShadow (instance size 12, VMT 00431888) }
  TCombatObstacleShadow = class(THexagonSprite)
  public
    FObstacle: TCombatObstacle; { $08 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatObstacleOverlay (instance size 12, VMT 00431A20) }
  TCombatObstacleOverlay = class(THexagonSprite)
  public
    FObstacle: TCombatObstacle; { $08 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TCombatObstacle (instance size 28, VMT 00431BB8) }
  TCombatObstacle = class(TMultiHexMO)
  public
    FShadow: TCombatObstacleShadow; { $14 }
    FOverlay: TCombatObstacleOverlay; { $18 }
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure CreateShadow;
    procedure DestroyShadow;
    procedure CreateOverlay;
    procedure DestroyOverlay;
    procedure ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure ShowOverlay(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
  end;

  { TCombatObstacleResource (instance size 68, VMT 00431D60) }
  TCombatObstacleResource = class(TMultiHexMOR)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCombatObstacle(AEngine: TEngine);

implementation
uses AoWTC;

function TCombatObstacleShadow.GetShowPriority: Integer;
begin
  Result := (FObstacle.GetShowPriority and $3FFFFFF) - $64000000;
end;

procedure TCombatObstacleShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  FObstacle.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc);
end;

function TCombatObstacleOverlay.GetShowPriority: Integer;
begin
  Result := (FObstacle.GetShowPriority and $3FFFFFF) + $60000;
end;

procedure TCombatObstacleOverlay.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  FObstacle.ShowOverlay(XhpSurf, YhpSurf, SurfaceDesc);
end;

class function TCombatObstacle.ClassID: Integer;
begin Result := $22052A; end;

destructor TCombatObstacle.Destroy;
begin
  DestroyShadow;
  DestroyOverlay;
  inherited Destroy;
end;

function TCombatObstacle.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := True; end;

function TCombatObstacle.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

function TCombatObstacle.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), Xhx, Yhx);
end;

procedure TCombatObstacle.RemoveFromMap;
var
  MapLevel: TMapLevel;
begin
  MapLevel := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(MapLevel, FXhx, FYhx);
end;

procedure TCombatObstacle.CreateShadow;
begin
  if FResource.ImageSequenceList.GetImageSequence(40) <> nil then
  begin
    if FShadow <> nil then DestroyShadow;
    if (AoWHSMap = nil) or AoWHSMap.FShowUnitShadows then
    begin
      FShadow := TCombatObstacleShadow.Create(nil);
      FShadow.FObstacle := Self;
    end;
  end;
end;

procedure TCombatObstacle.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if GetVisible then AoWCombatMap.DynamicVisibleHS.RemoveChild(FShadow);
    FShadow.Free;
    FShadow := nil;
  end;
end;

procedure TCombatObstacle.CreateOverlay;
begin
  if FResource.ImageSequenceList.GetImageSequence(41) <> nil then
  begin
    if FOverlay <> nil then DestroyOverlay;
    if (AoWHSMap = nil) or AoWHSMap.FShowUnitShadows then
    begin
      FOverlay := TCombatObstacleOverlay.Create(nil);
      FOverlay.FObstacle := Self;
    end;
  end;
end;

procedure TCombatObstacle.DestroyOverlay;
begin
  if FOverlay <> nil then
  begin
    if GetVisible then AoWCombatMap.DynamicVisibleHS.RemoveChild(FOverlay);
    FOverlay.Free;
    FOverlay := nil;
  end;
end;

procedure TCombatObstacle.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X, Y: Integer;
begin
  HXtoHP(FXhx, FYhx, X, Y);
  XhpSurf := X - XhpSurf;
  YhpSurf := Y - YhpSurf;
  FResource.ShowComplexImage(XhpSurf, YhpSurf, SurfaceDesc, 40,
    TMapField(Owner).Xhx + (TMapField(Owner).Yhx shl 4));
end;

procedure TCombatObstacle.ShowOverlay(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  X, Y: Integer;
begin
  HXtoHP(FXhx, FYhx, X, Y);
  XhpSurf := X - XhpSurf;
  YhpSurf := Y - YhpSurf;
  FResource.ShowComplexImage(XhpSurf, YhpSurf, SurfaceDesc, 41,
    TMapField(Owner).Xhx + (TMapField(Owner).Yhx shl 4));
end;

procedure TCombatObstacle.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    inherited MakeVisible(VisibilityList);
    if FShadow <> nil then VisibilityList.AddSortChild(FShadow, FShadow.GetShowPriority);
    if FOverlay <> nil then VisibilityList.AddSortChild(FOverlay, FOverlay.GetShowPriority);
  end;
end;

function TCombatObstacle.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

procedure TCombatObstacle.Activate;
begin
  inherited Activate;
  CreateShadow;
  CreateOverlay;
end;

procedure TCombatObstacle.Deactivate;
begin
  DestroyShadow;
  DestroyOverlay;
  inherited Deactivate;
end;

procedure TCombatObstacle.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  inherited UpdateMapField(Info);
  if Info.HN < FResource.TerrainList.Count then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $4000;
end;

procedure TCombatObstacle.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetAbilityEnabled(59) then
    if FResource.TerrainList.GetOverlay(Info.HN) = 8 then
    begin
      MoveResult.Code := -1;
      MoveResult.Done := True;
    end;
end;

class function TCombatObstacleResource.ClassID: Integer;
begin Result := $22052B; end;

class function TCombatObstacleResource.ResourceEditName: string;
begin Result := 'Combat ' + TranslateRStr(ObstacleRStr); end;

function TCombatObstacleResource.ResourceUserClassID: Integer;
begin Result := $22052A; end;

procedure RegisterCombatObstacle(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCombatObstacleResource, TCombatObstacle]);
end;


initialization
finalization

end.
