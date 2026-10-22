unit Merchant;

{ Merchant of AoWEPACK.dpl: recovered bodies and original instance layouts. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, GFXE, ImageLib, Sound, NetworkE, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, AoWE;

type
  TMerchant = class;
  TMerchantResource = class;


  { TMerchant (instance size 48, VMT 557C9C54) }
  TMerchant = class(TStructure)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TMerchantResource (instance size 100, VMT 557C9EB4) }
  TMerchantResource = class(TStructureResource)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMerchant(AEngine: TEngine);

implementation

constructor TMerchant.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

class function TMerchant.ClassID: Integer;
begin Result := $2010A; end;

constructor TMerchantResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainBound := False;
end;

class function TMerchantResource.ClassID: Integer;
begin Result := $2010B; end;

class function TMerchantResource.ResourceEditName: string;
begin Result := TranslateRStr(LoadResString(@MerchantRStr)); end;

function TMerchantResource.ResourceUserClassID: Integer;
begin Result := $2010A; end;

procedure RegisterMerchant(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TMerchant, TMerchantResource]);
end;


initialization
finalization

end.
