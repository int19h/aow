unit AltIce;

{ AltIce altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Altar, Storms, AoWE;

type
  TAltarOfIce = class;
  TAltarOfIceResource = class;


  { TAltarOfIce (instance size 68, no added fields, VMT 557CFAF0) }
  TAltarOfIce = class(TAltar)
  public
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfIceResource (instance size 116, no added fields, VMT 557CFDA0) }
  TAltarOfIceResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfIce(AEngine: TEngine);

implementation

class function TAltarOfIce.ClassID: Integer;
begin Result := $2024B; end;

function TAltarOfIce.CreateStorm: TStorm;
begin
  Result := TIceStorm.Create(nil);
end;

constructor TAltarOfIceResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfIceResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfIceRStr); end;

class function TAltarOfIceResource.ClassID: Integer;
begin Result := $2024C; end;

function TAltarOfIceResource.ResourceUserClassID: Integer;
begin Result := $2024B; end;

procedure RegisterAltarOfIce(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfIce, TAltarOfIceResource]);
end;

initialization
finalization

end.
