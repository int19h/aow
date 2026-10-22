unit Pyramid;

{ Pyramid exploration-site specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, ItemExpS, AoWE;

type
  TPyramid = class;
  TPyramidResource = class;


  { TPyramid (instance size 64, no added fields, VMT 557C6D20) }
  TPyramid = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TPyramidResource (instance size 104, no added fields, VMT 557C6F98) }
  TPyramidResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterPyramid(AEngine: TEngine);

implementation

class function TPyramid.ClassID: Integer;
begin Result := $2038E; end;

class function TPyramidResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(PyramidRStr); end;

class function TPyramidResource.ClassID: Integer;
begin Result := $2038F; end;

function TPyramidResource.ResourceUserClassID: Integer;
begin Result := $2038E; end;

procedure RegisterPyramid(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TPyramid, TPyramidResource]);
end;


initialization
finalization

end.
