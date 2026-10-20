unit MonsterL;

{ Draft declarations of MonsterL, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemExpS;

type
  TMonsterlair = class;
  TMonsterlairResource = class;


  { TMonsterlair (instance size 64, VMT 557C2D24) }
  TMonsterlair = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TMonsterlairResource (instance size 104, VMT 557C2FA4) }
  TMonsterlairResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMonsterlair;  { draft }

implementation

class function TMonsterlair.ClassID: Integer;
begin Result := 0; end;

class function TMonsterlairResource.ResourceEditName: string;
begin Result := ''; end;

class function TMonsterlairResource.ClassID: Integer;
begin Result := 0; end;

function TMonsterlairResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterMonsterlair;
begin end;


initialization
finalization

end.
