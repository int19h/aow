unit AltIce;

{ Draft declarations of AltIce, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, Altar;

type
  TAltarOfIce = class;
  TAltarOfIceResource = class;


  { TAltarOfIce (instance size 68, VMT 557CFAF0) }
  TAltarOfIce = class(TAltar)
  public
    class function ClassID: Integer; override;
    procedure CreateStorm; override;
  end;

  { TAltarOfIceResource (instance size 116, VMT 557CFDA0) }
  TAltarOfIceResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfIce;  { draft }

implementation

class function TAltarOfIce.ClassID: Integer;
begin Result := 0; end;

procedure TAltarOfIce.CreateStorm;
begin end;

constructor TAltarOfIceResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAltarOfIceResource.ResourceEditName: string;
begin Result := ''; end;

class function TAltarOfIceResource.ClassID: Integer;
begin Result := 0; end;

function TAltarOfIceResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterAltarOfIce;
begin end;


initialization
finalization

end.
