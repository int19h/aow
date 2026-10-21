unit AoWTCReg;

{ AoWTCReg, AoWTCPCK.dpl: register the tactical-combat classes in original order. }

{$O-,Q+,R+}

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;



procedure RegisterTacticalCombat(AEngine: TEngine);

implementation

uses AoWTC, CombatILTer, CombatHex, CombatRoad, CombatTerrain, CityWall, WorkShop,
  Townhall, House, FleeLoc, SingleCombatHex, CombatObstacle, CombatTE, IsoCombatHex,
  MainStructure, CenterViewLoc, CombatFire;

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
