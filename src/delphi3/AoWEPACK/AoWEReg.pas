unit AoWEReg;

{ AoWEReg, from AoWEPACK.dpl: package initialization registers the game types. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti,
  AoWE, AoWHex, AoWTer, RndHex, AoWRoad, HxBridge, Mountain, Bridge, Spring, BloodShrine, Sign, Teleport, Pad, Crops, Farm, Cave, Mine, Tower, PoisonP, Gems, PrdPlace, FireNode, WaterNode, DeathNode, LifeNode, EarthNode, AirNode, ExploreS, MonsterL, Dungeon, Crypt, Ruin, Pyramid, Shipyard, HolyG, UnHolyG, Merchant, AltFire, AltIce, AltLight, AltLife, AltDeath, AltPest, BldGuild, ItemExpS, AoWSetup, Storms, PoisonC, CitySpells, PowerNode, ManaCrystals, GlobalEnchantmentSpells, GlobalSpells, GlobalTargetSpells, CombatSpells, SummonSpells, PassiveAb, UnitSpells, MoveOnEvents, MagicSanctuary, Arena, ReflectingPool, WizardsTower, FlagEvents, OverlayObject, SmokeCloud;




implementation




initialization
  if ValidateAoWEngine then
  begin
    RegisterAoWHexagon(AoWE.AoWEngine);
    RegisterAoWTerrain(AoWE.AoWEngine);
    RegisterRandomHexagon(AoWE.AoWEngine);
    RegisterAoWRoad(AoWE.AoWEngine);
    RegisterHexagonBridge(AoWE.AoWEngine);
    RegisterMountain(AoWE.AoWEngine);
    RegisterBridge(AoWE.AoWEngine);
    RegisterSpringOfLife(AoWE.AoWEngine);
    RegisterBloodShrine(AoWE.AoWEngine);
    RegisterSign(AoWE.AoWEngine);
    RegisterTeleport(AoWE.AoWEngine);
    RegisterPad(AoWE.AoWEngine);
    RegisterILTerrain(AoWE.AoWEngine);
    RegisterCrops(AoWE.AoWEngine);
    RegisterFarm(AoWE.AoWEngine);
    RegisterCave(AoWE.AoWEngine);
    RegisterMine(AoWE.AoWEngine);
    RegisterTower(AoWE.AoWEngine);
    RegisterPoisonPlant(AoWE.AoWEngine);
    RegisterGems(AoWE.AoWEngine);
    RegisterProductionPlace(AoWE.AoWEngine);
    RegisterFireNode(AoWE.AoWEngine);
    RegisterWaterNode(AoWE.AoWEngine);
    RegisterDeathNode(AoWE.AoWEngine);
    RegisterLifeNode(AoWE.AoWEngine);
    RegisterEarthNode(AoWE.AoWEngine);
    RegisterAirNode(AoWE.AoWEngine);
    RegisterExplorationSite(AoWE.AoWEngine);
    RegisterMonsterlair(AoWE.AoWEngine);
    RegisterDungeon(AoWE.AoWEngine);
    RegisterCrypt(AoWE.AoWEngine);
    RegisterRuin(AoWE.AoWEngine);
    RegisterPyramid(AoWE.AoWEngine);
    RegisterShipyard(AoWE.AoWEngine);
    RegisterHolyGround(AoWE.AoWEngine);
    RegisterUnHolyGround(AoWE.AoWEngine);
    RegisterMerchant(AoWE.AoWEngine);
    RegisterAltarOfFire(AoWE.AoWEngine);
    RegisterAltarOfIce(AoWE.AoWEngine);
    RegisterAltarOfLightning(AoWE.AoWEngine);
    RegisterAltarOfLife(AoWE.AoWEngine);
    RegisterAltarOfDeath(AoWE.AoWEngine);
    RegisterAltarOfPestilence(AoWE.AoWEngine);
    RegisterBuildersGuild(AoWE.AoWEngine);
    RegisterItemExplorationSite(AoWE.AoWEngine);
    RegisterSetupClasses(AoWE.AoWEngine);
    RegisterStorms(AoWE.AoWEngine);
    RegisterPoisonCloud(AoWE.AoWEngine);
    RegisterCitySpells(AoWE.AoWEngine);
    RegisterPowerNode(AoWE.AoWEngine);
    RegisterManaCrystals(AoWE.AoWEngine);
    RegisterGlobalEnchantmentSpells(AoWE.AoWEngine);
    RegisterGlobalSpells(AoWE.AoWEngine);
    RegisterGlobalTargetSpells(AoWE.AoWEngine);
    RegisterCombatSpells(AoWE.AoWEngine);
    RegisterSummonSpells(AoWE.AoWEngine);
    RegisterPassiveAbilities(AoWE.AoWEngine.FGameSet.FAbilityControl);
    RegisterUnitSpells(AoWE.AoWEngine);
    RegisterMoveOnEvents(AoWE.AoWEngine);
    RegisterMagicSanctuary(AoWE.AoWEngine);
    RegisterArena(AoWE.AoWEngine);
    RegisterReflectingPool(AoWE.AoWEngine);
    RegisterWizardsTower(AoWE.AoWEngine);
    RegisterFlagEvents(AoWE.AoWEngine);
    RegisterOverlayObject(AoWE.AoWEngine);
    RegisterSmokeCloud(AoWE.AoWEngine);
  end;
finalization

end.
