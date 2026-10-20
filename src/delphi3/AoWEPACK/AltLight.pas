unit AltLight;

{ Draft declarations of AltLight, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfLightning = class;
  TAltarOfLightningResource = class;


  { TAltarOfLightning (instance size 68, VMT 557D16F4) }
  TAltarOfLightning = class(TAltar)
  public
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfLightningResource (instance size 116, VMT 557D19B4) }
  TAltarOfLightningResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfLightning;  { draft }

implementation

class function TAltarOfLightning.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfLightning.CreateStorm;
begin end;

constructor TAltarOfLightningResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfLightningResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfLightningResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfLightningResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfLightning;
begin end;


initialization
finalization

end.
