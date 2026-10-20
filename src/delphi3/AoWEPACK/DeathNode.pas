unit DeathNode;

{ DeathNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TDeathNode = class;
  TDeathNodeResource = class;


  { TDeathNode (instance size 76, VMT 557BFFA4) }
  TDeathNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TDeathNodeResource (instance size 120, VMT 557C0258) }
  TDeathNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterDeathNode(AEngine: TEngine);

implementation

class function TDeathNode.ClassID: Integer;
begin Result := $204AE; end;

function TDeathNode.GetMagicSphere: TMagicSphere;
begin Result := msDeath; end;

constructor TDeathNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FRebuildGold := 25;
  FRebuildDays := 2;
  FTerrainBound := False;
end;

class function TDeathNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(DeathNodeRStr); end;

class function TDeathNodeResource.ClassID: Integer;
begin Result := $204AF; end;

function TDeathNodeResource.ResourceUserClassID: Integer;
begin Result := $204AE; end;

procedure RegisterDeathNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TDeathNode, TDeathNodeResource]);
end;


initialization
finalization

end.
