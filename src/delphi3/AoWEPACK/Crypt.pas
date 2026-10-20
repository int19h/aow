unit Crypt;

{ Crypt exploration-site specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, ItemExpS;

type
  TCrypt = class;
  TCryptResource = class;


  { TCrypt (instance size 64, no added fields, VMT 557C64D0) }
  TCrypt = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TCryptResource (instance size 104, no added fields, VMT 557C6740) }
  TCryptResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCrypt(AEngine: TEngine);

implementation

class function TCrypt.ClassID: Integer;
begin Result := $2030A; end;

class function TCryptResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(CryptRStr); end;

class function TCryptResource.ClassID: Integer;
begin Result := $2030B; end;

function TCryptResource.ResourceUserClassID: Integer;
begin Result := $2030A; end;

procedure RegisterCrypt(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TCrypt, TCryptResource]);
end;


initialization
finalization

end.
