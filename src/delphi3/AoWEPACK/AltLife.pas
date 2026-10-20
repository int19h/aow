unit AltLife;

{ Draft declarations of AltLife, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfLife = class;
  TAltarOfLifeResource = class;


  { TAltarOfLife (instance size 68, VMT 557D1BCC) }
  TAltarOfLife = class(TAltar)
  public
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfLifeResource (instance size 116, VMT 557D1E84) }
  TAltarOfLifeResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfLife;  { draft }

implementation

class function TAltarOfLife.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfLife.CreateStorm;
begin end;

constructor TAltarOfLifeResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfLifeResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfLifeResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfLifeResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfLife;
begin end;


initialization
finalization

end.
