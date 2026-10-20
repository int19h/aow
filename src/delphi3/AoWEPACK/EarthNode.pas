unit EarthNode;

{ Draft declarations of EarthNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace;

type
  TEarthNode = class;
  TEarthNodeResource = class;


  { TEarthNode (instance size 76, VMT 557BFAE0) }
  TEarthNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    procedure GetMagicSphere; override;
  end;

  { TEarthNodeResource (instance size 120, VMT 557BFD94) }
  TEarthNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterEarthNode;  { draft }

implementation

class function TEarthNode.ClassID: Integer;
begin Result := 0; end;

procedure TEarthNode.GetMagicSphere;
begin end;

constructor TEarthNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TEarthNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TEarthNodeResource.ClassID: Integer;
begin Result := 0; end;

function TEarthNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterEarthNode;
begin end;


initialization
finalization

end.
