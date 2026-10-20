unit AltFire;

{ AltFire altar specialization recovered from AoWEPACK.dpl.
  Both classes retain their inherited layouts with no added fields. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Altar, Storms;

type
  TAltarOfFire = class;
  TAltarOfFireResource = class;


  { TAltarOfFire (instance size 68, no added fields, VMT 557CF5F8) }
  TAltarOfFire = class(TAltar)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function CreateStorm: TStorm; override;
  end;

  { TAltarOfFireResource (instance size 116, no added fields, VMT 557CF8B0) }
  TAltarOfFireResource = class(TAltarResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterAltarOfFire(AEngine: TEngine);

implementation

constructor TAltarOfFire.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfFire.ClassID: Integer;
begin Result := $2023A; end;

function TAltarOfFire.CreateStorm: TStorm;
begin
  Result := TFireStorm.Create(nil);
end;

constructor TAltarOfFireResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TAltarOfFireResource.ResourceEditName: string;
begin Result := AoWE.TranslateRStr(AltarOfFireRStr); end;

class function TAltarOfFireResource.ClassID: Integer;
begin Result := $2023B; end;

function TAltarOfFireResource.ResourceUserClassID: Integer;
begin Result := $2023A; end;

procedure RegisterAltarOfFire(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TAltarOfFire, TAltarOfFireResource]);
end;

initialization
finalization

end.
