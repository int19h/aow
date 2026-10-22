unit AoWEMod;

{ AoWEd.exe engine-module initialization and editor registration.
  The registration helpers are the original 15-byte routines called at $41FE38/$41FEFC. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti;

type
  TAoWEngineModule = class;


  { TAoWEngineModule (instance size 68, VMT 0041FDB4) }
  TAoWEngineModule = class(TDataModule)
  public
    procedure RegisterResourceEditors(AEngine: TEngine);
    procedure RegisterMapEditors(AEngine: TEngine);
    published procedure AoWEngineModuleCreate(Sender: TObject); public
  end;


implementation

uses AoWE, AoWTCReg, FontMod,
  RPad, RHexagon, RRoad, RBridge, RIsoHex, RILTer, RAoWTer, RMultiHx, RConstr, RCity, EUnitGFX, EUnitRes, ERaceRes, EHeroRes, EItemGFX, EFaceRes, EItemHS, RProdP, RMapObj, RFire, RExploreS, RDungeon, RCTerrain, RCILTer, ETCUnitPos, RPlayerStructure, ROverlay, ESign, Ecity, ETeleprt, EConstr, EArmy, EGems, EExplorS, EDungeon, EItmExpS, EFire, EFarm, EProdP, EPoisonC, EManaC, EChangeSong, EShowMessage, EPlaySample, EWizardsTower, ETutorialMessageEvent, EFlagMsgEvent, ESmokeC;

procedure RegisterPadResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TPadResourceEditor);
end;

procedure RegisterHexagonResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(THexagonResourceEditor);
end;

procedure RegisterRoadResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TRoadResourceEditor);
end;

procedure RegisterBridgeResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TBridgeResourceEditor);
end;

procedure RegisterIsometricHexagonResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TIsometricHexagonResourceEditor);
end;

procedure RegisterILTerrainResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TILTerrainResourceEditor);
end;

procedure RegisterAoWTerrainResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TAoWTerrainResourceEditor);
end;

procedure RegisterMultiHexResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TMultiHexResourceEditor);
end;

procedure RegisterConstructionResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TConstructionResourceEditor);
end;

procedure RegisterCityResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TCityResourceEditor);
end;

procedure RegisterUnitGFXResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TUnitGFXResourceEditor);
end;

procedure RegisterUnitResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TUnitResourceEditor);
end;

procedure RegisterRaceResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TRaceResourceEditor);
end;

procedure RegisterHeroResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(THeroResourceEditor);
end;

procedure RegisterItemGFXEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TItemGFXEditor);
end;

procedure RegisterFaceResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TFaceResourceEditor);
end;

procedure RegisterItemHSEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TItemHSEditor);
end;

procedure RegisterProductionPlaceResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TProductionPlaceResourceEditor);
end;

procedure RegisterMapObjectResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TMapObjectResourceEditor);
end;

procedure RegisterFireResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TFireResourceEditor);
end;

procedure RegisterExplorationSiteResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TExplorationSiteResourceEditor);
end;

procedure RegisterDungeonResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TDungeonResourceEditor);
end;

procedure RegisterCombatTerrainResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TCombatTerrainResourceEditor);
end;

procedure RegisterCombatILTerrainResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TCombatILTerrainResourceEditor);
end;

procedure RegisterUnitPositionEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TUnitPositionEditor);
end;

procedure RegisterPlayerStructureResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TPlayerStructureResourceEditor);
end;

procedure RegisterOverlayObjectResourceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TOverlayObjectResourceEditor);
end;

procedure RegisterSignEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TSignEditor);
end;

procedure RegisterCityEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TCityEditor);
end;

procedure RegisterTeleportEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TTeleportEditor);
end;

procedure RegisterPlayerConstructionEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TPlayerConstructionEditor);
end;

procedure RegisterArmyHSEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TArmyHSEditor);
end;

procedure RegisterGemsEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TGemsEditor);
end;

procedure RegisterExplorationSiteEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TExplorationSiteEditor);
end;

procedure RegisterDungeonEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TDungeonEditor);
end;

procedure RegisterItemExplorationSiteEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TItemExplorationSiteEditor);
end;

procedure RegisterFireEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TFireEditor);
end;

procedure RegisterFarmEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TFarmEditor);
end;

procedure RegisterProductionPlaceEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TProductionPlaceEditor);
end;

procedure RegisterPoisonCloudEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TPoisonCloudEditor);
end;

procedure RegisterManaCrystalsEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TManaCrystalsEditor);
end;

procedure RegisterChangeSongEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TChangeSongEditor);
end;

procedure RegisterShowMessageEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TShowMessageEditor);
end;

procedure RegisterPlaySampleEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TPlaySampleEditor);
end;

procedure RegisterWizardsTowerEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TWizardsTowerEditor);
end;

procedure RegisterTutorialMessageEventEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TTutorialMessageEventEditor);
end;

procedure RegisterFlagMessageEventEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TFlagMessageEventEditor);
end;

procedure RegisterSmokeCloudEditor(AEngine: TEngine);
begin
  AEngine.Editors.RegisterClass(TSmokeCloudEditor);
end;

procedure TAoWEngineModule.RegisterResourceEditors(AEngine: TEngine);
begin
  RegisterPadResourceEditor(AEngine);
  RegisterHexagonResourceEditor(AEngine);
  RegisterRoadResourceEditor(AEngine);
  RegisterBridgeResourceEditor(AEngine);
  RegisterIsometricHexagonResourceEditor(AEngine);
  RegisterILTerrainResourceEditor(AEngine);
  RegisterAoWTerrainResourceEditor(AEngine);
  RegisterMultiHexResourceEditor(AEngine);
  RegisterConstructionResourceEditor(AEngine);
  RegisterCityResourceEditor(AEngine);
  RegisterUnitGFXResourceEditor(AEngine);
  RegisterUnitResourceEditor(AEngine);
  RegisterRaceResourceEditor(AEngine);
  RegisterHeroResourceEditor(AEngine);
  RegisterItemGFXEditor(AEngine);
  RegisterFaceResourceEditor(AEngine);
  RegisterItemHSEditor(AEngine);
  RegisterProductionPlaceResourceEditor(AEngine);
  RegisterMapObjectResourceEditor(AEngine);
  RegisterFireResourceEditor(AEngine);
  RegisterExplorationSiteResourceEditor(AEngine);
  RegisterDungeonResourceEditor(AEngine);
  RegisterCombatTerrainResourceEditor(AEngine);
  RegisterCombatILTerrainResourceEditor(AEngine);
  RegisterUnitPositionEditor(AEngine);
  RegisterPlayerStructureResourceEditor(AEngine);
  RegisterOverlayObjectResourceEditor(AEngine);
end;

procedure TAoWEngineModule.RegisterMapEditors(AEngine: TEngine);
begin
  RegisterSignEditor(AEngine);
  RegisterCityEditor(AEngine);
  RegisterTeleportEditor(AEngine);
  RegisterPlayerConstructionEditor(AEngine);
  RegisterArmyHSEditor(AEngine);
  RegisterGemsEditor(AEngine);
  RegisterExplorationSiteEditor(AEngine);
  RegisterDungeonEditor(AEngine);
  RegisterItemExplorationSiteEditor(AEngine);
  RegisterFireEditor(AEngine);
  RegisterFarmEditor(AEngine);
  RegisterProductionPlaceEditor(AEngine);
  RegisterPoisonCloudEditor(AEngine);
  RegisterManaCrystalsEditor(AEngine);
  RegisterChangeSongEditor(AEngine);
  RegisterShowMessageEditor(AEngine);
  RegisterPlaySampleEditor(AEngine);
  RegisterWizardsTowerEditor(AEngine);
  RegisterTutorialMessageEventEditor(AEngine);
  RegisterFlagMessageEventEditor(AEngine);
  RegisterSmokeCloudEditor(AEngine);
end;

procedure TAoWEngineModule.AoWEngineModuleCreate(Sender: TObject);
begin
  AoWEngine.FCombatFont := FontModule.SmallFont;
  RegisterTacticalCombat(AoWEngine);
  RegisterResourceEditors(AoWEngine);
  RegisterMapEditors(AoWEngine);
end;

end.
