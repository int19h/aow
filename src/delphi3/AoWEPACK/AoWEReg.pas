unit AoWEReg;

{ AoWEReg, from AoWEPACK.dpl: package initialization registers the game types. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti,
  AoWE, AoWHex, AoWTer, RndHex, AoWRoad, HxBridge, Mountain, Bridge, Spring, BloodShrine, Sign, Teleport, Pad, Crops, Farm, Cave, Mine, Tower, PoisonP, Gems, PrdPlace, FireNode, WaterNode, DeathNode, LifeNode, EarthNode, AirNode, ExploreS, MonsterL, Dungeon, Crypt, Ruin, Pyramid, Shipyard, HolyG, UnHolyG, Merchant, AltFire, AltIce, AltLight, AltLife, AltDeath, AltPest, BldGuild, ItemExpS, AoWSetup, Storms, PoisonC, CitySpells, PowerNode, ManaCrystals, GlobalEnchantmentSpells, GlobalSpells, GlobalTargetSpells, CombatSpells, SummonSpells, PassiveAb, UnitSpells, MoveOnEvents, MagicSanctuary, Arena, ReflectingPool, WizardsTower, FlagEvents, OverlayObject, SmokeCloud;




implementation

type PAoWEngine = ^TAoWEngine;
const WorldEngine: PAoWEngine = @AoWE.AoWEngine;


initialization
  if ValidateAoWEngine then
  begin
    RegisterAoWHexagon(WorldEngine^);
    RegisterAoWTerrain(WorldEngine^);
    RegisterRandomHexagon(WorldEngine^);
    RegisterAoWRoad(WorldEngine^);
    RegisterHexagonBridge(WorldEngine^);
    RegisterMountain(WorldEngine^);
    RegisterBridge(WorldEngine^);
    RegisterSpringOfLife(WorldEngine^);
    RegisterBloodShrine(WorldEngine^);
    RegisterSign(WorldEngine^);
    RegisterTeleport(WorldEngine^);
    RegisterPad(WorldEngine^);
    RegisterILTerrain(WorldEngine^);
    RegisterCrops(WorldEngine^);
    RegisterFarm(WorldEngine^);
    RegisterCave(WorldEngine^);
    RegisterMine(WorldEngine^);
    RegisterTower(WorldEngine^);
    RegisterPoisonPlant(WorldEngine^);
    RegisterGems(WorldEngine^);
    RegisterProductionPlace(WorldEngine^);
    RegisterFireNode(WorldEngine^);
    RegisterWaterNode(WorldEngine^);
    RegisterDeathNode(WorldEngine^);
    RegisterLifeNode(WorldEngine^);
    RegisterEarthNode(WorldEngine^);
    RegisterAirNode(WorldEngine^);
    RegisterExplorationSite(WorldEngine^);
    RegisterMonsterlair(WorldEngine^);
    RegisterDungeon(WorldEngine^);
    RegisterCrypt(WorldEngine^);
    RegisterRuin(WorldEngine^);
    RegisterPyramid(WorldEngine^);
    RegisterShipyard(WorldEngine^);
    RegisterHolyGround(WorldEngine^);
    RegisterUnHolyGround(WorldEngine^);
    RegisterMerchant(WorldEngine^);
    RegisterAltarOfFire(WorldEngine^);
    RegisterAltarOfIce(WorldEngine^);
    RegisterAltarOfLightning(WorldEngine^);
    RegisterAltarOfLife(WorldEngine^);
    RegisterAltarOfDeath(WorldEngine^);
    RegisterAltarOfPestilence(WorldEngine^);
    RegisterBuildersGuild(WorldEngine^);
    RegisterItemExplorationSite(WorldEngine^);
    RegisterSetupClasses(WorldEngine^);
    RegisterStorms(WorldEngine^);
    RegisterPoisonCloud(WorldEngine^);
    RegisterCitySpells(WorldEngine^);
    RegisterPowerNode(WorldEngine^);
    RegisterManaCrystals(WorldEngine^);
    RegisterGlobalEnchantmentSpells(WorldEngine^);
    RegisterGlobalSpells(WorldEngine^);
    RegisterGlobalTargetSpells(WorldEngine^);
    RegisterCombatSpells(WorldEngine^);
    RegisterSummonSpells(WorldEngine^);
    RegisterPassiveAbilities(WorldEngine^.FGameSet.FAbilityControl);
    RegisterUnitSpells(WorldEngine^);
    RegisterMoveOnEvents(WorldEngine^);
    RegisterMagicSanctuary(WorldEngine^);
    RegisterArena(WorldEngine^);
    RegisterReflectingPool(WorldEngine^);
    RegisterWizardsTower(WorldEngine^);
    RegisterFlagEvents(WorldEngine^);
    RegisterOverlayObject(WorldEngine^);
    RegisterSmokeCloud(WorldEngine^);
  end;
finalization

end.
