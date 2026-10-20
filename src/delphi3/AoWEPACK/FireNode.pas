unit FireNode;

{ FireNode specialization recovered from AoWEPACK.dpl.
  Inherited resource fields: $5A rebuild gold, $5B rebuild days, $60 raze defender budget. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TFireNode = class;
  TFireNodeResource = class;


  { TFireNode (instance size 76, VMT 557BF624) }
  TFireNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TFireNodeResource (instance size 120, VMT 557BF8D4) }
  TFireNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterFireNode(AEngine: TEngine);

implementation

class function TFireNode.ClassID: Integer;
begin Result := $203DE; end;

function TFireNode.GetMagicSphere: TMagicSphere;
begin Result := msFire; end;

constructor TFireNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeDefenderBudget := 200;
  FRebuildGold := 50;
  FRebuildDays := 3;
end;

class function TFireNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(FireNodeRStr); end;

class function TFireNodeResource.ClassID: Integer;
begin Result := $203DF; end;

function TFireNodeResource.ResourceUserClassID: Integer;
begin Result := $203DE; end;

procedure RegisterFireNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TFireNode, TFireNodeResource]);
end;


initialization
finalization

end.
