unit WaterNode;

{ Draft declarations of WaterNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TWaterNode = class;
  TWaterNodeResource = class;


  { TWaterNode (instance size 76, VMT 557C092C) }
  TWaterNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TWaterNodeResource (instance size 120, VMT 557C0BE0) }
  TWaterNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterWaterNode;  { draft }

implementation

class function TWaterNode.ClassID: Integer;
begin Result := 0; end;

function TWaterNode.GetMagicSphere: TMagicSphere;
begin end;

constructor TWaterNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TWaterNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TWaterNodeResource.ClassID: Integer;
begin Result := 0; end;

function TWaterNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterWaterNode;
begin end;


initialization
finalization

end.
