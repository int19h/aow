unit AoWTCReg;

{ AoWTCReg, AoWTCPCK.dpl: register the tactical-combat classes in original order. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;



procedure RegisterTacticalCombat(AEngine: TEngine);

implementation

uses WorkShop, Townhall, House, SingleCombatHex, IsoCombatHex, MainStructure, CenterViewLoc,
  FleeLoc, CombatHex, CombatTE, CombatTerrain, CombatRoad, CombatObstacle, CombatILTer,
  CityWall, CombatFire, AoWTC;

procedure RegisterTacticalCombat(AEngine: TEngine);
begin
  RegisterAoWTCClasses(AEngine);
  RegisterCombatILTerrain(AEngine);
  RegisterCombatHexagon(AEngine);
  RegisterCombatRoad(AEngine);
  RegisterCombatTerrain(AEngine);
  RegisterCityWall(AEngine);
  RegisterWorkshop(AEngine);
  RegisterTownhall(AEngine);
  RegisterHouse(AEngine);
  RegisterFleeLocation(AEngine);
  RegisterSingleCombatHexagon(AEngine);
  RegisterCombatObstacle(AEngine);
  RegisterCombatTE(AEngine);
  RegisterIsometricCombatHexagon(AEngine);
  RegisterMainStructure(AEngine);
  RegisterCenterViewLocation(AEngine);
  RegisterCombatFire(AEngine);
end;


initialization
finalization

end.
