unit OverlayObject;

{ OverlayObject of AoWEPACK.dpl: recovered bodies and original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

type
  TOverlayObject = class;
  TOverlayObjectResource = class;


  { TOverlayObject (instance size 28, VMT 557D3C78) }
  TOverlayObject = class(TFixedILTerrainMO)
  public
    class function ClassID: Integer; override;
  end;

  { TOverlayObjectResource (instance size 72, VMT 557D3E30): $44 FOverlayType. }
  TOverlayObjectResource = class(TFixedILTerrainMOR)
  public
    FOverlayType: Integer; { $44 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterOverlayObject(AEngine: TEngine);
procedure UnRegisterOverlayObject(AEngine: TEngine);

implementation

class function TOverlayObject.ClassID: Integer;
begin Result := $2009C; end;

class function TOverlayObjectResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@OverlayObjectRStr)); end;

class function TOverlayObjectResource.ClassID: Integer;
begin Result := $2009D; end;

function TOverlayObjectResource.ResourceUserClassID: Integer;
begin Result := $2009C; end;

procedure TOverlayObjectResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FOverlayType, 40);
end;

procedure RegisterOverlayObject(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TOverlayObject, TOverlayObjectResource]);
end;

procedure UnRegisterOverlayObject(AEngine: TEngine);
begin
  AEngine.UnregisterEClasses([TOverlayObject, TOverlayObjectResource]);
end;


initialization
finalization

end.
