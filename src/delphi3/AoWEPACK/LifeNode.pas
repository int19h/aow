unit LifeNode;

{ LifeNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $44 terrain binding, $5A rebuild gold,
  $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TLifeNode = class;
  TLifeNodeResource = class;


  { TLifeNode (instance size 76, no added fields, VMT 557C046C) }
  TLifeNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TLifeNodeResource (instance size 120, no added fields, VMT 557C071C) }
  TLifeNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterLifeNode(AEngine: TEngine);

implementation

class function TLifeNode.ClassID: Integer;
begin Result := $20371; end;

function TLifeNode.GetMagicSphere: TMagicSphere;
begin Result := msLife; end;

constructor TLifeNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FTerrainBound := False;
  FRebuildGold := 25;
  FRebuildDays := 2;
end;

class function TLifeNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(LifeNodeRStr); end;

class function TLifeNodeResource.ClassID: Integer;
begin Result := $20372; end;

function TLifeNodeResource.ResourceUserClassID: Integer;
begin Result := $20371; end;

procedure RegisterLifeNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TLifeNode, TLifeNodeResource]);
end;


initialization
finalization

end.
