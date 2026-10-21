unit WorkShop;

{ WorkShop, AoWTCPCK.dpl. Original layouts and VMT order.
  TWorkshop: size $28, no added fields. TWorkshopResource: size $48, no added fields. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  TWorkshop = class;
  TWorkshopResource = class;


  { TWorkshop (instance size 40, VMT 004334E0) }
  TWorkshop = class(TCombatStructure)
  public
    class function ClassID: Integer; override;
  end;

  { TWorkshopResource (instance size 72, VMT 0043368C) }
  TWorkshopResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterWorkshop(AEngine: TEngine);

implementation

class function TWorkshop.ClassID: Integer;
begin Result := $220508; end;

class function TWorkshopResource.ClassID: Integer;
begin Result := $220509; end;

class function TWorkshopResource.ResourceEditName: string;
begin Result := 'Combat Workshop'; end;

function TWorkshopResource.ResourceUserClassID: Integer;
begin Result := $220508; end;

procedure RegisterWorkshop(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TWorkshopResource, TWorkshop]);
end;


initialization
finalization

end.
