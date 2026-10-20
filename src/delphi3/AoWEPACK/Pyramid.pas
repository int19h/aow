unit Pyramid;

{ Draft declarations of Pyramid, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemExpS;

type
  TPyramid = class;
  TPyramidResource = class;


  { TPyramid (instance size 64, VMT 557C6D20) }
  TPyramid = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TPyramidResource (instance size 104, VMT 557C6F98) }
  TPyramidResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPyramid;  { draft }

implementation

class function TPyramid.ClassID: Integer;
begin Result := 0; end;

class function TPyramidResource.ResourceEditName: string;
begin Result := ''; end;

class function TPyramidResource.ClassID: Integer;
begin Result := 0; end;

function TPyramidResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterPyramid;
begin end;


initialization
finalization

end.
