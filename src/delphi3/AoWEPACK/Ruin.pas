unit Ruin;

{ Draft declarations of Ruin, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemExpS;

type
  TRuin = class;
  TRuinResource = class;


  { TRuin (instance size 64, VMT 557C68FC) }
  TRuin = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TRuinResource (instance size 104, VMT 557C6B68) }
  TRuinResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterRuin;  { draft }

implementation

class function TRuin.ClassID: Integer;
begin Result := 0; end;

class function TRuinResource.ResourceEditName: string;
begin Result := ''; end;

class function TRuinResource.ClassID: Integer;
begin Result := 0; end;

function TRuinResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterRuin;
begin end;


initialization
finalization

end.
