unit OverlayObject;

{ Draft declarations of OverlayObject, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TOverlayObject = class;
  TOverlayObjectResource = class;


  { TOverlayObject (instance size 28, VMT 557D3C78) }
  TOverlayObject = class(TFixedILTerrainMO)
  public
    class function ClassID: Integer; override;
  end;

  { TOverlayObjectResource (instance size 72, VMT 557D3E30) }
  TOverlayObjectResource = class(TFixedILTerrainMOR)
  public
    F_OverlayObjectResource_44: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterOverlayObject;  { draft }
procedure UnRegisterOverlayObject;  { draft }

implementation

class function TOverlayObject.ClassID: Integer;
begin Result := 0; end;

class function TOverlayObjectResource.ResourceEditName: string;
begin Result := ''; end;

class function TOverlayObjectResource.ClassID: Integer;
begin Result := 0; end;

function TOverlayObjectResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TOverlayObjectResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure RegisterOverlayObject;
begin end;

procedure UnRegisterOverlayObject;
begin end;


initialization
finalization

end.
