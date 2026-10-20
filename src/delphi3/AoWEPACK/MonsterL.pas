unit MonsterL;

{ MonsterL exploration-site specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ItemExpS;

type
  TMonsterlair = class;
  TMonsterlairResource = class;


  { TMonsterlair (instance size 64, no added fields, VMT 557C2D24) }
  TMonsterlair = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TMonsterlairResource (instance size 104, no added fields, VMT 557C2FA4) }
  TMonsterlairResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMonsterlair(AEngine: TEngine);

implementation

class function TMonsterlair.ClassID: Integer;
begin Result := $2032E; end;

class function TMonsterlairResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(MonsterLairRStr); end;

class function TMonsterlairResource.ClassID: Integer;
begin Result := $2032F; end;

function TMonsterlairResource.ResourceUserClassID: Integer;
begin Result := $2032E; end;

procedure RegisterMonsterlair(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TMonsterlair, TMonsterlairResource]);
end;


initialization
finalization

end.
