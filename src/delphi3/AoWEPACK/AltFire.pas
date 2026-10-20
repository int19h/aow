unit AltFire;

{ Draft declarations of AltFire, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfFire = class;
  TAltarOfFireResource = class;


  { TAltarOfFire (instance size 68, VMT 557CF5F8) }
  TAltarOfFire = class(TAltar)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfFireResource (instance size 116, VMT 557CF8B0) }
  TAltarOfFireResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfFire;  { draft }

implementation

constructor TAltarOfFire.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfFire.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfFire.CreateStorm;
begin end;

constructor TAltarOfFireResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfFireResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfFireResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfFireResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfFire;
begin end;


initialization
finalization

end.
