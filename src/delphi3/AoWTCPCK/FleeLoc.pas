unit FleeLoc;

{ FleeLoc, AoWTCPCK.dpl. Original layouts and VMT order.
  Flee location: $10 highlighted, $14 alpha, $18 alpha step.
  Movement sprite: $0C enabled. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, AoWTC;

type
  TFleeLocation = class;
  TFleeLocationResource = class;
  TMovementHS = class;


  { TFleeLocation (instance size 28, VMT 00430EB4) }
  TFleeLocation = class(TMapObject)
  public
    FHighlighted: Boolean; { $10 }
    F_FleeLocation_11: array[0..2] of Byte;
    FAlpha: Integer; { $14 }
    FAlphaStep: Integer; { $18 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    procedure Activate; override;
    procedure DeActivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList; override;
    function CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure NewFrame(Sender: TObject);
  end;

  { TFleeLocationResource (instance size 52, VMT 00431048) }
  TFleeLocationResource = class(TMapObjectResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TMovementHS (instance size 16, VMT 00431140) }
  TMovementHS = class(TSingleHS)
  public
    FEnabled: Boolean; { $0C }
    F_MovementHS_0D: array[0..2] of Byte;
    class function ClassID: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
  end;

procedure RegisterFleeLocation(AEngine: TEngine);

implementation

procedure TFleeLocation.DeActivate;
begin
  AoWCombatMap.NewFrameEvents.Remove(NewFrame);
  inherited Deactivate;
end;

constructor TFleeLocation.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TFleeLocation.ClassID: Integer;
begin Result := $220528; end;

function TFleeLocation.GetResourceList(AEngine: Engine.TEngine): HSEngine.TMapObjectResourceList;
begin Result := AoWHSSet.FCombatResources; end;

function TFleeLocation.GetShowPriority: Integer;
begin
  Result := $68000000 + (Yhx shl 13) + Xhx;
end;

function TFleeLocation.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := True; end;

function TFleeLocation.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := True; end;

function TFleeLocation.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  OldHexagon: TEObject;
  MapField: TMapField;
begin
  if not GetEditMode then
  begin
    MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
    OldHexagon := MapField.FindOwnedChild($20557);
    if OldHexagon <> nil then
    begin
      OldHexagon.Free;
      AoWHSSet.FCombatHexagons.Place(AoWCombatMap.MapContainer, Xhx, Yhx, 0, 1);
    end;
  end;
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

procedure TFleeLocation.Activate;
begin
  inherited Activate;
  AoWCombatMap.NewFrameEvents.Add(NewFrame);
  FHighlighted := msEditting in AoWCombatMap.Status;
  if FHighlighted then FAlpha := 50 else FAlpha := 0;
  AoWCombatMap.FFleeLocations.Add(Self);
end;

procedure TFleeLocation.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if Info.HN = 0 then
  begin
    if TCombatMoveControl(Info.Sender).FUnitHS.FUnit.GetSide = csAttacker then
      MoveResult.Code := 25
    else
      MoveResult.Code := TCombatMoveControl(Info.Sender).FMovePointTable[Info.MapField.TerrainType, Info.MapField.OverlayType];
    MoveResult.Done := True;
  end;
end;

procedure TFleeLocation.NewFrame(Sender: TObject);
var
  Highlight: Boolean;
begin
  Highlight := False;
  if msEditting in AoWCombatMap.Status then Highlight := True
  else if (AoWCombatMap.FUnitSelection.GetTCUnitHS <> nil) and
    (AoWCombatMap.FUnitSelection.GetTCUnitHS.FUnit.FCombatPlayer = AoWCombatMap.FSeatedCombatPlayer) and
    (AoWCombatMap.FUnitSelection.GetTCUnitHS.FUnit.FCombatPlayer <>
      AoWCombatMap.FCombat.FCombatData.FDefenderPlayer) then Highlight := True;
  if Highlight <> FHighlighted then
  begin
    FHighlighted := Highlight;
    if FHighlighted then FAlphaStep := 5 else FAlphaStep := -5;
  end
  else if ((FAlpha > 0) and (FAlphaStep < 0)) or ((FAlpha < 50) and (FAlphaStep > 0)) then
    FAlpha := FAlpha + FAlphaStep;
end;

procedure TFleeLocation.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y: Integer;
begin
  if FAlpha > 0 then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
    FResource.ImageLibrary.Get(0).ShowBlended(X - XhpSurf - 8, Y - YhpSurf,
      SurfaceDesc, AlphaBlendTable.LookupTables[FAlpha]);
  end;
end;

class function TFleeLocationResource.ClassID: Integer;
begin Result := $220529; end;

class function TFleeLocationResource.ResourceEditName: string;
begin Result := 'Combat Flee Location'; end;

function TFleeLocationResource.ResourceUserClassID: Integer;
begin Result := $220528; end;

class function TMovementHS.ClassID: Integer;
begin Result := $22010A; end;

function TMovementHS.GetShowPriority: Integer;
begin Result := $20; end;

procedure TMovementHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if (Info.HN = 0) and not FEnabled then
  begin
    MoveResult.Code := -1;
    MoveResult.Done := True;
  end;
end;

procedure TMovementHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
end;

procedure RegisterFleeLocation(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TFleeLocationResource, TFleeLocation, TMovementHS]);
end;


initialization
finalization

end.
