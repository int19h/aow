unit AltLife;

{ AltLife altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Altar, Storms, AoWE;

type
  TAltarOfLife = class;
  TAltarOfLifeResource = class;


  { TAltarOfLife (instance size 68, no added fields, VMT 557D1BCC) }
  TAltarOfLife = class(TAltar)
  public
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfLifeResource (instance size 116, no added fields, VMT 557D1E84) }
  TAltarOfLifeResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfLife(AEngine: TEngine);

implementation

class function TAltarOfLife.ClassID: Integer;
begin Result := $20233; end;

function TAltarOfLife.CreateStorm: TStorm;
begin
  Result := TDivineStorm.Create(nil);
end;

constructor TAltarOfLifeResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfLifeResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfLifeRStr); end;

class function TAltarOfLifeResource.ClassID: Integer;
begin Result := $20234; end;

function TAltarOfLifeResource.ResourceUserClassID: Integer;
begin Result := $20233; end;

procedure RegisterAltarOfLife(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfLife, TAltarOfLifeResource]);
end;

initialization
finalization

end.
