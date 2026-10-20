unit Shipyard;

{ Shipyard and its construction control recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TShipyard = class;
  TShipyardResource = class;
  TShipyardConstructionControl = class;


  { TShipyard (instance size 76, no added fields, VMT 557C715C) }
  TShipyard = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    procedure UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer); override;
    function GetBaseIncome: Integer; override;
  end;

  { TShipyardResource (instance size 120, no added fields, VMT 557C740C) }
  TShipyardResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

  { TShipyardConstructionControl (instance size 8, no added fields, VMT 557C750C) }
  TShipyardConstructionControl = class(TStructureConstructionControl)
  public
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); override;
    function ID: Integer; override;
    function ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean; override;
    function StructureResource(AUnit: TAbstractUnit): TStructureResource; override;
  end;

procedure RegisterShipyard(AEngine: TEngine);

implementation

class function TShipyard.ClassID: Integer;
begin Result := $204BE; end;

function TShipyard.GetBaseIncome: Integer;
begin Result := 0; end;

procedure TShipyard.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
begin
  inherited UpdateAITarget(Info, Priority);
end;

constructor TShipyardResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := False;
  FRazeDefenderBudget := 150;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TShipyardResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(ShipyardRStr); end;

class function TShipyardResource.ClassID: Integer;
begin Result := $204BF; end;

function TShipyardResource.ResourceUserClassID: Integer;
begin Result := $204BE; end;

function TShipyardConstructionControl.ID: Integer;
begin Result := 4; end;

function TShipyardConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
var
  X, Y, L: Shortint;
begin
  AUnit.GetLocation(X, Y, L);
  if L = 0 then
    Result := TStructureResource(AoWHSSet.MapObjectResourceList.FindResource(60))
  else
    Result := TStructureResource(AoWHSSet.MapObjectResourceList.FindResource(107));
end;

procedure TShipyardConstructionControl.GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer);
begin
  Text := Format(TranslateRStr(BuildXRStr), [TranslateRStr(ShipyardRStr)]);
  Gold := 50;
  Days := 2;
end;

function TShipyardConstructionControl.ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean;
var
  X, Y, L: Shortint;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
begin
  Result := inherited ValidateLocation(AUnit, Reason);
  if Result then
  begin
    Result := False;
    AUnit.GetLocation(X, Y, L);
    MapLevel := AoWHSMap.MapContainer.GetMapLevel(L);
    InitHNWalk(Walk, X, Y, 0);
    while (Walk.HN < 7) and not Result do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and
        (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
        Result := MapLevel.GetField(Walk.X, Walk.Y).TerrainType in [0, 10];
      WalkToNextHN(Walk);
    end;
    if not Result then
      Reason := TranslateRStr(CanOnlyBuildNextToWaterRStr);
  end;
end;

procedure RegisterShipyard(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TShipyard, TShipyardResource]);
  TConstructAbility(AoWHSSet.FAbilityControl.GetAbility(125)).
    RegisterConstructionControl(TShipyardConstructionControl.Create(nil));
end;

initialization
finalization

end.
