unit EarthNode;

{ EarthNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $5A rebuild gold, $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TEarthNode = class;
  TEarthNodeResource = class;


  { TEarthNode (instance size 76, VMT 557BFAE0) }
  TEarthNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TEarthNodeResource (instance size 120, VMT 557BFD94) }
  TEarthNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterEarthNode(AEngine: TEngine);

implementation

class function TEarthNode.ClassID: Integer;
begin Result := $204CE; end;

function TEarthNode.GetMagicSphere: TMagicSphere;
begin Result := msEarth; end;

constructor TEarthNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FRebuildGold := 35;
  FRebuildDays := 2;
end;

class function TEarthNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(EarthNodeRStr); end;

class function TEarthNodeResource.ClassID: Integer;
begin Result := $204CF; end;

function TEarthNodeResource.ResourceUserClassID: Integer;
begin Result := $204CE; end;

procedure RegisterEarthNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TEarthNode, TEarthNodeResource]);
end;


initialization
finalization

end.
