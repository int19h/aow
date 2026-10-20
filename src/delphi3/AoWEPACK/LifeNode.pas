unit LifeNode;

{ Draft declarations of LifeNode, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, PrdPlace;

type
  TLifeNode = class;
  TLifeNodeResource = class;


  { TLifeNode (instance size 76, VMT 557C046C) }
  TLifeNode = class(TProductionPlace)
  public
    class function ClassID: Integer; override;
    function GetMagicSphere: TMagicSphere; override;
  end;

  { TLifeNodeResource (instance size 120, VMT 557C071C) }
  TLifeNodeResource = class(TProductionPlaceResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterLifeNode;  { draft }

implementation

class function TLifeNode.ClassID: Integer;
begin Result := 0; end;

function TLifeNode.GetMagicSphere: TMagicSphere;
begin end;

constructor TLifeNodeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TLifeNodeResource.ResourceEditName: string;
begin Result := ''; end;

class function TLifeNodeResource.ClassID: Integer;
begin Result := 0; end;

function TLifeNodeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterLifeNode;
begin end;


initialization
finalization

end.
