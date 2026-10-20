unit FireNode;

{ Draft declarations of FireNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, PrdPlace;

type
  TFireNode = class;
  TFireNodeResource = class;


  { TFireNode (instance size 76, VMT 557BF624) }
  TFireNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    procedure GetMagicSphere; override;
  end;

  { TFireNodeResource (instance size 120, VMT 557BF8D4) }
  TFireNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterFireNode;  { draft }

implementation

class function TFireNode.ClassID: Integer;
begin Result := 0; end;

procedure TFireNode.GetMagicSphere;
begin end;

constructor TFireNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFireNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TFireNodeResource.ClassID: Integer;
begin Result := 0; end;

function TFireNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterFireNode;
begin end;


initialization
finalization

end.
