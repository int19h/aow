unit WaterNode;

{ WaterNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TWaterNode = class;
  TWaterNodeResource = class;


  { TWaterNode (instance size 76, no added fields, VMT 557C092C) }
  TWaterNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TWaterNodeResource (instance size 120, no added fields, VMT 557C0BE0) }
  TWaterNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterWaterNode(AEngine: TEngine);

implementation

class function TWaterNode.ClassID: Integer;
begin Result := $204B3; end;

function TWaterNode.GetMagicSphere: TMagicSphere;
begin Result := msWater; end;

constructor TWaterNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FTerrainBound := False;
  FRebuildGold := 50;
  FRebuildDays := 2;
end;

class function TWaterNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(WaterNodeRStr); end;

class function TWaterNodeResource.ClassID: Integer;
begin Result := $204B4; end;

function TWaterNodeResource.ResourceUserClassID: Integer;
begin Result := $204B3; end;

procedure RegisterWaterNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TWaterNode, TWaterNodeResource]);
end;


initialization
finalization

end.
