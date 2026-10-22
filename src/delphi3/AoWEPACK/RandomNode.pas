unit RandomNode;

{ Random node specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, PrdPlace, AoWE;

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

procedure RegisterRandomNode(AEngine: TEngine);

implementation

class function TRandomNode.ClassID: Integer;
begin Result := $20822; end;

constructor TRandomNodeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TRandomNodeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(RandomNodeRStr); end;

class function TRandomNodeResource.ClassID: Integer;
begin Result := $20823; end;

function TRandomNodeResource.ResourceUserClassID: Integer;
begin Result := $20822; end;

procedure RegisterRandomNode(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TRandomNode, TRandomNodeResource]);
end;


initialization
finalization

end.
