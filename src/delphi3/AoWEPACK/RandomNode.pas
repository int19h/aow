unit RandomNode;

{ Draft declarations of RandomNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace;

type
  TRandomNode = class;
  TRandomNodeResource = class;


  { TRandomNode (instance size 76, VMT 5580B3D8) }
  TRandomNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
  end;

  { TRandomNodeResource (instance size 120, VMT 5580B68C) }
  TRandomNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterRandomNode;  { draft }

implementation

class function TRandomNode.ClassID: Integer;
begin Result := 0; end;

constructor TRandomNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TRandomNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TRandomNodeResource.ClassID: Integer;
begin Result := 0; end;

function TRandomNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterRandomNode;
begin end;


initialization
finalization

end.
