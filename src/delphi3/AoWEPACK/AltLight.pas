unit AltLight;

{ AltLight altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Altar, Storms;

type
  TAltarOfLightning = class;
  TAltarOfLightningResource = class;


  { TAltarOfLightning (instance size 68, no added fields, VMT 557D16F4) }
  TAltarOfLightning = class(TAltar)
  public
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfLightningResource (instance size 116, no added fields, VMT 557D19B4) }
  TAltarOfLightningResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfLightning(AEngine: TEngine);

implementation

class function TAltarOfLightning.ClassID: Integer;
begin Result := $2023D; end;

function TAltarOfLightning.CreateStorm: TStorm;
begin
  Result := TLightningStorm.Create(nil);
end;

constructor TAltarOfLightningResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfLightningResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfLightningRStr); end;

class function TAltarOfLightningResource.ClassID: Integer;
begin Result := $2023E; end;

function TAltarOfLightningResource.ResourceUserClassID: Integer;
begin Result := $2023D; end;

procedure RegisterAltarOfLightning(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfLightning, TAltarOfLightningResource]);
end;

initialization
finalization

end.
