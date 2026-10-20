unit AltPest;

{ Draft declarations of AltPest, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfPestilence = class;
  TAltarOfPestilenceResource = class;


  { TAltarOfPestilence (instance size 68, VMT 557D255C) }
  TAltarOfPestilence = class(TAltar)
  public
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfPestilenceResource (instance size 116, VMT 557D281C) }
  TAltarOfPestilenceResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfPestilence;  { draft }

implementation

class function TAltarOfPestilence.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfPestilence.CreateStorm;
begin end;

constructor TAltarOfPestilenceResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfPestilenceResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfPestilenceResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfPestilenceResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfPestilence;
begin end;


initialization
finalization

end.
