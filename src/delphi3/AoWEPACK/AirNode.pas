unit AirNode;

{ AirNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TAirNode = class;
  TAirNodeResource = class;


  { TAirNode (instance size 76, no added fields, VMT 557C0DF4) }
  TAirNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TAirNodeResource (instance size 120, no added fields, VMT 557C10A4) }
  TAirNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAirNode(AEngine: TEngine);

implementation

class function TAirNode.ClassID: Integer;
begin Result := $2094E; end;

function TAirNode.GetMagicSphere: TMagicSphere;
begin Result := msAir; end;

constructor TAirNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FRebuildGold := 50;
  FRebuildDays := 2;
  FTerrainBound := False;
end;

class function TAirNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AirNodeRStr); end;

class function TAirNodeResource.ClassID: Integer;
begin Result := $2094F; end;

function TAirNodeResource.ResourceUserClassID: Integer;
begin Result := $2094E; end;

procedure RegisterAirNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAirNode, TAirNodeResource]);
end;


initialization
finalization

end.
