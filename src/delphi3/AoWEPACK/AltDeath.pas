unit AltDeath;

{ Draft declarations of AltDeath, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfDeath = class;
  TAltarOfDeathResource = class;


  { TAltarOfDeath (instance size 68, VMT 557D2094) }
  TAltarOfDeath = class(TAltar)
  public
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfDeathResource (instance size 116, VMT 557D234C) }
  TAltarOfDeathResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfDeath;  { draft }

implementation

class function TAltarOfDeath.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfDeath.CreateStorm;
begin end;

constructor TAltarOfDeathResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfDeathResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfDeathResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfDeathResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfDeath;
begin end;


initialization
finalization

end.
