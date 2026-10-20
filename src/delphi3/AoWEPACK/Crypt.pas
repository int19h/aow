unit Crypt;

{ Draft declarations of Crypt, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, ItemExpS;

type
  TCrypt = class;
  TCryptResource = class;


  { TCrypt (instance size 64, VMT 557C64D0) }
  TCrypt = class(TItemExplorationSite)
  public
    class function ClassID: Integer; override;
  end;

  { TCryptResource (instance size 104, VMT 557C6740) }
  TCryptResource = class(TItemExplorationSiteResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterCrypt;  { draft }

implementation

class function TCrypt.ClassID: Integer;
begin Result := 0; end;

class function TCryptResource.ResourceEditName: string;
begin Result := ''; end;

class function TCryptResource.ClassID: Integer;
begin Result := 0; end;

function TCryptResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterCrypt;
begin end;


initialization
finalization

end.
