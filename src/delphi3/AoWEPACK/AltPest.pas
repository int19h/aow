unit AltPest;

{ AltPest altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, Altar, Storms, AoWE;

type
  TAltarOfPestilence = class;
  TAltarOfPestilenceResource = class;


  { TAltarOfPestilence (instance size 68, no added fields, VMT 557D255C) }
  TAltarOfPestilence = class(TAltar)
  public
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfPestilenceResource (instance size 116, no added fields, VMT 557D281C) }
  TAltarOfPestilenceResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfPestilence(AEngine: TEngine);

implementation

class function TAltarOfPestilence.ClassID: Integer;
begin Result := $2030C; end;

function TAltarOfPestilence.CreateStorm: TStorm;
begin
  Result := TPestilenceStorm.Create(nil);
end;

constructor TAltarOfPestilenceResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfPestilenceResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfPestilenceRStr); end;

class function TAltarOfPestilenceResource.ClassID: Integer;
begin Result := $2030D; end;

function TAltarOfPestilenceResource.ResourceUserClassID: Integer;
begin Result := $2030C; end;

procedure RegisterAltarOfPestilence(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfPestilence, TAltarOfPestilenceResource]);
end;

initialization
finalization

end.
