unit MainStructure;

{ MainStructure, AoWTCPCK.dpl. Original layouts and VMT order.
  TMainStructure: size $28, no added fields. Resource: size $48, no added fields. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, CombatStructure;

type
  TMainStructure = class;
  TMainStructureResource = class;


  { TMainStructure (instance size 40, VMT 00435310) }
  TMainStructure = class(TCombatStructure)
  public
    class function ClassID: Integer; override;
    function GetTerrainTypeImage(TerrainType: Integer): Integer; override;
  end;

  { TMainStructureResource (instance size 72, VMT 004354CC) }
  TMainStructureResource = class(TCombatStructureResource)
  public
    class function ClassID: Integer; override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
  end;

procedure RegisterMainStructure(AEngine: TEngine);

implementation

class function TMainStructure.ClassID: Integer;
begin Result := $22051C; end;

function TMainStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := TerrainType; end;

class function TMainStructureResource.ClassID: Integer;
begin Result := $22051D; end;

class function TMainStructureResource.ResourceEditName: string;
begin Result := 'Combat Main Structure'; end;

function TMainStructureResource.ResourceUserClassID: Integer;
begin Result := $22051C; end;

procedure RegisterMainStructure(AEngine: TEngine);
begin
  AEngine.RegisterEClasses([TMainStructureResource, TMainStructure]);
end;


initialization
finalization

end.
