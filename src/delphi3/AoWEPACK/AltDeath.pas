unit AltDeath;

{ AltDeath altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Altar, Storms, AoWE;

type
  TAltarOfDeath = class;
  TAltarOfDeathResource = class;


  { TAltarOfDeath (instance size 68, no added fields, VMT 557D2094) }
  TAltarOfDeath = class(TAltar)
  public
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfDeathResource (instance size 116, no added fields, VMT 557D234C) }
  TAltarOfDeathResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfDeath(AEngine: TEngine);

implementation

class function TAltarOfDeath.ClassID: Integer;
begin Result := $20235; end;

function TAltarOfDeath.CreateStorm: TStorm;
begin
  Result := TDeathStorm.Create(nil);
end;

constructor TAltarOfDeathResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfDeathResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfDeathRStr); end;

class function TAltarOfDeathResource.ClassID: Integer;
begin Result := $20236; end;

function TAltarOfDeathResource.ResourceUserClassID: Integer;
begin Result := $20235; end;

procedure RegisterAltarOfDeath(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfDeath, TAltarOfDeathResource]);
end;

initialization
finalization

end.
