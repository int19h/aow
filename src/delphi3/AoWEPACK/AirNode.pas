unit AirNode;

{ Draft declarations of AirNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace;

type
  TAirNode = class;
  TAirNodeResource = class;


  { TAirNode (instance size 76, VMT 557C0DF4) }
  TAirNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    procedure GetMagicSphere; override;
  end;

  { TAirNodeResource (instance size 120, VMT 557C10A4) }
  TAirNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAirNode;  { draft }

implementation

class function TAirNode.ClassID: Integer;
begin Result := 0; end;

procedure TAirNode.GetMagicSphere;
begin end;

constructor TAirNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAirNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TAirNodeResource.ClassID: Integer;
begin Result := 0; end;

function TAirNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAirNode;
begin end;


initialization
finalization

end.
