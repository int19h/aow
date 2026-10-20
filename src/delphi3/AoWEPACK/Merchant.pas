unit Merchant;

{ Draft declarations of Merchant, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE;

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

procedure RegisterMerchant;  { draft }

implementation

constructor TMerchant.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMerchant.ClassID: Integer;
begin Result := 0; end;

constructor TMerchantResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TMerchantResource.ClassID: Integer;
begin Result := 0; end;

class function TMerchantResource.ResourceEditName: string;
begin Result := ''; end;

function TMerchantResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure RegisterMerchant;
begin end;


initialization
finalization

end.
