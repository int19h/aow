unit Ruin;

{ Ruin exploration-site specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ItemExpS;

type
  TRuin = class;
  TRuinResource = class;


  { TRuin (instance size 64, no added fields, VMT 557C68FC) }
  TRuin = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TRuinResource (instance size 104, no added fields, VMT 557C6B68) }
  TRuinResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterRuin(AEngine: TEngine);

implementation

class function TRuin.ClassID: Integer;
begin Result := $2039A; end;

class function TRuinResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(RuinRStr); end;

class function TRuinResource.ClassID: Integer;
begin Result := $2039B; end;

function TRuinResource.ResourceUserClassID: Integer;
begin Result := $2039A; end;

procedure RegisterRuin(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TRuin, TRuinResource]);
end;


initialization
finalization

end.
