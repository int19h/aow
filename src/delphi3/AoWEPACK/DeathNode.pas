unit DeathNode;

{ Draft declarations of DeathNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

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

procedure RegisterDeathNode;  { draft }

implementation

class function TDeathNode.ClassID: Integer;
begin Result := 0; end;

function TDeathNode.GetMagicSphere: TMagicSphere;
begin end;

constructor TDeathNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TDeathNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TDeathNodeResource.ClassID: Integer;
begin Result := 0; end;

function TDeathNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterDeathNode;
begin end;


initialization
finalization

end.
