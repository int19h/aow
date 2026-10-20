unit City;

{ Draft declarations of City, from AoWEPACK.dpl.
  Layouts and VMT order follow notes/classes.json; guessed signatures are marked draft.
  Stub bodies are placeholders for source recovery. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Crops, EventLog;

type
  TCityProductionControl = class;
  TCityOverlayHS = class;
  TMigrationItem = class;
  TMigrationList = class;
  TCityEnchantment = class;
  TCity = class;
  TCityResource = class;
  TCityRebellionEventLog = class;
  TAICityUpgradeBudget = class;
  TAICityResearchBudget = class;
  TAICityFortifyBudget = class;
  TCityAIPA = class;
  TCityProductionEventLog = class;
  TRegistrator = class;

  TCivilStatus = (csUnruly, csUnrest, csStable, csContent, csCheerful, csOppressed, csSlavery);  { ot=1 }
  TCityEnchantmentID = (ceiFountainOfLife, ceiGoldRush, ceiAntiMagicShell, ceiWarmonger);  { ot=1 }
  TCityEnchantmentIDs = set of TCityEnchantmentID; { ot=1 }
  TCityAction = (caNone, caTrade, caUpgrade, caFortify, caMigrate, caLoot, caRaze, caResearch, caProduce);  { ot=1 }
  TCityMode = set of (cmWarmode, cmRazed, cmTownQuake, cmAnarchy); { ot=1 }
  TCityOverlayMode = (omIdle, omShowRazeAnimation, omLooting);  { ot=1 }
  TMoveOutOfCitySelection = set of (msSkipOwnPlayer); { ot=1 }
  TDefendersGenerateMode = (dgNone, dgRandom, dgWeak, dgAverage, dgStrong);  { ot=1 }

  { TCityProductionControl (instance size 44, VMT 557A6D34) }
  TCityProductionControl = class(TProductionControl)
  public
    F_CityProductionControl_28: Integer;
    procedure ExecuteCancelProduction; override;
    procedure ExecuteProduction(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetPlayer; override;
    procedure LoopableProduction(A1: Integer); override;
    procedure LockQueueProduction(A1: Integer); override;
    procedure UnitProduced; override;
    procedure UnitResearched; override;
    procedure Update; override;
    procedure CreateUnitProduction(A1: Integer); override;
    procedure NewTurn(A1: Integer); override;
    procedure CanExecuteProduction(A1: Integer; A2: Integer); override;
    procedure GetProductionName(A1: Integer; A2: Integer); override;
    procedure GetProductionNameProgressive(A1: Integer; A2: Integer); override;
    procedure UnitProductionTime(A1: Integer); override;
  end;

  { TCityOverlayHS (instance size 28, VMT 557A6EFC) }
  TCityOverlayHS = class(TSingleHS)
  public
    F_CityOverlayHS_0C: Integer;
    F_CityOverlayHS_10: Integer;
    F_CityOverlayHS_14: array[0..0] of Byte;
    F_CityOverlayHS_15: Byte;
    F_CityOverlayHS_16: array[0..1] of Byte;
    F_CityOverlayHS_18: Integer;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure PlaySetupShellAnimation;  { draft }
    procedure PlayFadeShellAnimation;  { draft }
    procedure SetMode(A1: Byte);  { draft }
  end;

  { TMigrationItem (instance size 20, VMT 557A7084) }
  TMigrationItem = class(TEObject)
  public
    F_MigrationItem_08: array[0..11] of Byte;
  end;

  { TMigrationList (instance size 12, VMT 557A7148) }
  TMigrationList = class(TENode)
  public
    procedure GetItems(A1: Integer);  { draft }
  end;

  { TCityEnchantment (instance size 44, VMT 557A7294) }
  TCityEnchantment = class(TGlobalEnchantment)
  public
    F_CityEnchantment_24: Byte;
    F_CityEnchantment_25: array[0..2] of Byte;
    F_CityEnchantment_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure GetLocation(A1: Integer; A2: Integer); override;
    procedure GetAIUpkeepPriority; override;
    procedure Deactivate(A1: Byte); override;
    procedure VisibleForPlayer(A1: Integer; A2: Integer); override;
    procedure GetCity;  { draft }
  end;

  { TCity (instance size 120, VMT 557A73F0) }
  TCity = class(TPlayerCropStructure)
  public
    F_City_44: Byte;
    F_City_45: Byte;
    F_City_46: array[0..1] of Byte;
    F_City_48: Integer;
    F_City_4C: Byte;
    F_City_4D: Byte;
    F_City_4E: array[0..1] of Byte;
    F_City_50: Integer;
    F_City_54: Byte;
    F_City_55: array[0..2] of Byte;
    F_City_58: Integer;
    F_City_5C: Byte;
    F_City_5D: array[0..2] of Byte;
    F_City_60: Integer;
    F_City_64: Byte;
    F_City_65: array[0..2] of Byte;
    F_City_68: Integer;
    F_City_6C: Integer;
    F_City_70: Integer;
    F_City_74: Byte;
    F_City_75: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    procedure Select; override;
    function GetValidTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt; override;
    procedure GetTopBorderImage; override;
    procedure GetMiddleBorderImage; override;
    procedure GetBottomBorderImage; override;
    procedure GetName(A1: Integer); override;
    procedure SetRazed(A1: Integer); override;
    procedure GetRazed; override;
    procedure SetupRazeDefenderAG(A1: Integer; A2: Integer); override;
    procedure ExecuteTE(A1: Integer; A2: Integer); override;
    procedure GetDefenseRequirements(A1: Integer; A2: Integer); override;
    procedure GetDefensePriority; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer); override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ArmyRemoved; override;
    procedure BuildingDone; override;
    procedure GenerateRazeDefenders(A1: Integer; A2: Integer); override;
    procedure ExecuteRaze(A1: Integer; A2: Integer); override;
    procedure GetCurrentActivityText(A1: Integer); override;
    procedure ValidateMap(A1: Integer); override;
    procedure UpdateAITarget(A1: Integer; A2: Integer); override;
    procedure Update; override;
    procedure CanDblClick; override;
    procedure GetRebuildInfo(A1: Integer; A2: Integer); override;
    procedure SetPlayer(A1: Integer; A2: Integer); override;
    procedure UpdateFlagID; override;
    procedure VisibilityRange; override;
    procedure FinalizeCombat(A1: Integer); override;
    procedure GetCombatEventText(A1: Integer; A2: Integer); override;
    procedure StructureCaptured(A1: Integer; A2: Byte); override;
    procedure GetMoveAction(A1: Integer; A2: Integer); override;
    procedure UpdatePlayer; override;
    procedure UpdateIncome(A1: Integer; A2: Integer); override;
    procedure UpdateCrops; override;
    procedure GetRace; override;
    procedure CropTrampled(A1: Integer); override;
    procedure SetRace(A1: Byte); virtual;  { +244 draft }
    procedure GetActiveAction;  { draft }
    procedure UpdateActiveEnchantments(A1: Integer; A2: Integer);  { draft }
    procedure RegisterEnchantments;  { draft }
    procedure UnregisterEnchantments;  { draft }
    procedure ResetEnchantments;  { draft }
    procedure AICityEnchantmentUpkeepPriority(A1: Byte);  { draft }
    procedure ActivateEnchantment(A1: Integer; A2: Integer);  { draft }
    procedure DeactivateEnchantment(A1: Integer);  { draft }
    procedure ListEnhancementsInfo(A1: Integer);  { draft }
    procedure StartTownQuake;  { draft }
    procedure StopTownQuake;  { draft }
    procedure ExecuteAnarchy;  { draft }
    procedure ExecuteFountainOfLife(A1: Integer; A2: Integer);  { draft }
    procedure UpdateAIMigration;  { draft }
    procedure ValidateAICityAction;  { draft }
    procedure MoveArmiesOutOfCity(A1: Byte);  { draft }
    procedure GetSize;  { draft }
    procedure GetObtainUnitsValue;  { draft }
    procedure UpgradeCost;  { draft }
    procedure UpgradeTime;  { draft }
    procedure CanUpgrade(A1: Byte; A2: Integer);  { draft }
    procedure Upgrade(A1: Integer);  { draft }
    procedure FortifyCost;  { draft }
    procedure FortifyTime;  { draft }
    procedure CanFortify(A1: Byte; A2: Integer);  { draft }
    procedure Fortify(A1: Integer);  { draft }
    procedure ProductionCost;  { draft }
    procedure ProductionTime;  { draft }
    procedure CanProduce(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Produce;  { draft }
    procedure ResearchCost;  { draft }
    procedure ResearchTime;  { draft }
    procedure CanResearch(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Research;  { draft }
    procedure CanTrade;  { draft }
    procedure Trade(A1: Integer);  { draft }
    procedure LootTime;  { draft }
    procedure CanLoot;  { draft }
    procedure Loot;  { draft }
    procedure MigrationTime(A1: Byte);  { draft }
    procedure CanMigrate(A1: Byte; A2: Integer);  { draft }
    procedure Migrate(A1: Integer);  { draft }
    procedure CreateMigrationItem(A1: Integer);  { draft }
    procedure CreateMigrationSelection(A1: Integer; A2: Integer);  { draft }
    procedure CheckRebellion;  { draft }
    procedure GenerateDefenders(A1: Integer; A2: Integer);  { draft }
    procedure ListIncomeInfo(A1: Integer; A2: Integer);  { draft }
    procedure SetDefaultProductions;  { draft }
    procedure GenerateRebelUnits(A1: Integer);  { draft }
    procedure ListCivilStatusInfo(A1: Integer);  { draft }
    procedure GetCivilStatus;  { draft }
    procedure UpdateImages;  { draft }
    procedure SetUpgradeLevel(A1: Integer; A2: Integer);  { draft }
    procedure SetName(A1: Integer; A2: Integer);  { draft }
    procedure SetWallType(A1: Byte);  { draft }
    procedure InitCombat(A1: Integer; A2: Integer);  { draft }
    procedure GetObtainValue;  { draft }
    procedure JoinAmount(A1: Byte);  { draft }
    procedure IncommingNegotiateRequest(A1: Integer);  { draft }
    procedure IncommingNegotiateOffer(A1: Integer);  { draft }
    procedure GetEnemiesIndependentRelation(A1: Integer);  { draft }
    procedure GetIndependentRelation;  { draft }
    procedure ReturnBattleFieldInfo(A1: Integer);  { draft }
    procedure UpdateVisibleForSeatedPlayer;  { draft }
    procedure GetTopCityActionImage(A1: Integer);  { draft }
    procedure GetMiddleCityActionImage(A1: Integer);  { draft }
    procedure GetBottomCityActionImage(A1: Integer);  { draft }
  end;

  { TCityResource (instance size 124, VMT 557A76AC) }
  TCityResource = class(TPlayerCropStructureResource)
  public
    F_CityResource_78: Byte;
    F_CityResource_79: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure ShowCity(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ActivateMsg;  { draft }
  end;

  { TCityRebellionEventLog (instance size 40, VMT 557A77A0) }
  TCityRebellionEventLog = class(TEventLog)
  public
    F_CityRebellionEventLog_18: Integer;
    F_CityRebellionEventLog_1C: Integer;
    F_CityRebellionEventLog_20: Integer;
    F_CityRebellionEventLog_24: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TAICityUpgradeBudget (instance size 56, VMT 557A78B4) }
  TAICityUpgradeBudget = class(TAIBudget)
  public
    class function ClassID: Integer; override;
  end;

  { TAICityResearchBudget (instance size 56, VMT 557A7994) }
  TAICityResearchBudget = class(TAIBudget)
  public
    class function ClassID: Integer; override;
  end;

  { TAICityFortifyBudget (instance size 56, VMT 557A7A74) }
  TAICityFortifyBudget = class(TAIBudget)
  public
    class function ClassID: Integer; override;
  end;

  { TCityAIPA (instance size 48, VMT 557A7B54) }
  TCityAIPA = class(TAIPlayerAction)
  public
    F_CityAIPA_14: Integer;
    F_CityAIPA_18: Byte;
    F_CityAIPA_19: array[0..14] of Byte;
    F_CityAIPA_28: Integer;
    F_CityAIPA_2C: Integer;
    procedure Priority; override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure ValidResearchCity(A1: Integer);  { draft }
    procedure ValidResearchBudgetCity(A1: Integer);  { draft }
    procedure ValidateResearchBudget(A1: Integer);  { draft }
    procedure ResearchProduction(A1: Integer; A2: Integer);  { draft }
    procedure ValidUpgradeCity(A1: Integer);  { draft }
    procedure ValidUpgradeBudgetCity(A1: Integer);  { draft }
    procedure UpgradeCity(A1: Integer);  { draft }
    procedure ValidateUpgradeBudget(A1: Integer);  { draft }
    procedure ValidFortifyCity(A1: Integer);  { draft }
    procedure ValidFortifyBudgetCity(A1: Integer);  { draft }
    procedure FortifyCity(A1: Integer);  { draft }
    procedure ValidateFortifyBudget(A1: Integer);  { draft }
    procedure UpgradeableCities(A1: Integer; A2: Integer);  { draft }
    procedure UpdateStatistics;  { draft }
  end;

  { TCityProductionEventLog (instance size 32, VMT 557A7C24) }
  TCityProductionEventLog = class(TProductionEventLog)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCity;  { draft }
  end;

  { TRegistrator (instance size 4, VMT 557AF144) }
  TRegistrator = class(TObject)
  public
  end;

procedure ProductionIDToCityAction(A1: Integer; A2: Integer; A3: Integer);  { draft }
procedure CityActionToProductionID(A1: Integer);  { draft }
procedure RaceInCity(A1: Byte; A2: Byte; A3: Integer);  { draft }
procedure UnitLevelToCityLevel;  { draft }
procedure PlayerCities(A1: Byte);  { draft }
procedure CityIncome(A1: Byte);  { draft }

implementation

procedure TCityProductionControl.CanExecuteProduction(A1: Integer; A2: Integer);
begin end;

procedure TCityProductionControl.ExecuteProduction(A1: Integer);
begin end;

procedure TCityProductionControl.NewTurn(A1: Integer);
begin end;

procedure TCityProductionControl.ExecuteCancelProduction;
begin end;

procedure TCityProductionControl.LockQueueProduction(A1: Integer);
begin end;

procedure TCityProductionControl.LoopableProduction(A1: Integer);
begin end;

procedure TCityProductionControl.GetProductionName(A1: Integer; A2: Integer);
begin end;

procedure TCityProductionControl.GetProductionNameProgressive(A1: Integer; A2: Integer);
begin end;

procedure TCityProductionControl.Update;
begin end;

procedure TCityProductionControl.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCityProductionControl.CreateUnitProduction(A1: Integer);
begin end;

procedure TCityProductionControl.UnitResearched;
begin end;

procedure TCityProductionControl.UnitProduced;
begin end;

procedure TCityProductionControl.GetPlayer;
begin end;

procedure TCityProductionControl.UnitProductionTime(A1: Integer);
begin end;

function TCityOverlayHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TCityOverlayHS.PlaySetupShellAnimation;
begin end;

procedure TCityOverlayHS.PlayFadeShellAnimation;
begin end;

procedure TCityOverlayHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCityOverlayHS.SetMode(A1: Byte);
begin end;

constructor TCity.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TCity.Destroy;
begin end;

class function TCity.ClassID: Integer;
begin Result := 0; end;

procedure TCity.CanDblClick;
begin end;

procedure TCity.GetActiveAction;
begin end;

procedure TCity.ExecuteTE(A1: Integer; A2: Integer);
begin end;

procedure TCity.Update;
begin end;

procedure TCity.ValidateMap(A1: Integer);
begin end;

procedure TCity.BuildingDone;
begin end;

procedure TCity.UpdateActiveEnchantments(A1: Integer; A2: Integer);
begin end;

procedure TCity.RegisterEnchantments;
begin end;

procedure TCity.UnregisterEnchantments;
begin end;

procedure TCity.ResetEnchantments;
begin end;

procedure TCity.AICityEnchantmentUpkeepPriority(A1: Byte);
begin end;

procedure TCity.ActivateEnchantment(A1: Integer; A2: Integer);
begin end;

procedure TCity.DeactivateEnchantment(A1: Integer);
begin end;

procedure TCity.ListEnhancementsInfo(A1: Integer);
begin end;

procedure TCity.StartTownQuake;
begin end;

procedure TCity.StopTownQuake;
begin end;

procedure TCity.ExecuteAnarchy;
begin end;

procedure TCity.ExecuteFountainOfLife(A1: Integer; A2: Integer);
begin end;

procedure TCity.UpdateAIMigration;
begin end;

procedure TCity.StructureCaptured(A1: Integer; A2: Byte);
begin end;

procedure TCity.ValidateAICityAction;
begin end;

procedure TCity.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TCity.SetupRazeDefenderAG(A1: Integer; A2: Integer);
begin end;

procedure TCity.GetDefensePriority;
begin end;

procedure TCity.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TCity.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TCity.CropTrampled(A1: Integer);
begin end;

procedure TCity.MoveArmiesOutOfCity(A1: Byte);
begin end;

procedure TCity.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TCity.GetSize;
begin end;

procedure TCity.GetObtainUnitsValue;
begin end;

procedure TCity.UpdatePlayer;
begin end;

procedure TCity.ArmyPlaced(A1: Integer);
begin end;

procedure TCity.ArmyRemoved;
begin end;

procedure TCity.UpgradeCost;
begin end;

procedure TCity.UpgradeTime;
begin end;

procedure TCity.CanUpgrade(A1: Byte; A2: Integer);
begin end;

procedure TCity.Upgrade(A1: Integer);
begin end;

procedure TCity.FortifyCost;
begin end;

procedure TCity.FortifyTime;
begin end;

procedure TCity.CanFortify(A1: Byte; A2: Integer);
begin end;

procedure TCity.Fortify(A1: Integer);
begin end;

procedure TCity.ProductionCost;
begin end;

procedure TCity.ProductionTime;
begin end;

procedure TCity.CanProduce(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCity.Produce;
begin end;

procedure TCity.ResearchCost;
begin end;

procedure TCity.ResearchTime;
begin end;

procedure TCity.CanResearch(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TCity.Research;
begin end;

procedure TCity.CanTrade;
begin end;

procedure TCity.Trade(A1: Integer);
begin end;

procedure TCity.LootTime;
begin end;

procedure TCity.CanLoot;
begin end;

procedure TCity.Loot;
begin end;

procedure TCity.MigrationTime(A1: Byte);
begin end;

procedure TCity.CanMigrate(A1: Byte; A2: Integer);
begin end;

procedure TCity.Migrate(A1: Integer);
begin end;

procedure TCity.CreateMigrationItem(A1: Integer);
begin end;

procedure TCity.CreateMigrationSelection(A1: Integer; A2: Integer);
begin end;

procedure TCity.GenerateRazeDefenders(A1: Integer; A2: Integer);
begin end;

procedure TCity.ExecuteRaze(A1: Integer; A2: Integer);
begin end;

procedure TCity.GetRazed;
begin end;

procedure TCity.SetRazed(A1: Integer);
begin end;

procedure TCity.GetRebuildInfo(A1: Integer; A2: Integer);
begin end;

procedure TCity.CheckRebellion;
begin end;

procedure TCity.GenerateDefenders(A1: Integer; A2: Integer);
begin end;

procedure TCity.NewTurn(A1: Integer);
begin end;

procedure TCity.NewDay;
begin end;

procedure TCity.UpdateCrops;
begin end;

procedure TCity.ListIncomeInfo(A1: Integer; A2: Integer);
begin end;

procedure TCity.UpdateIncome(A1: Integer; A2: Integer);
begin end;

function TCity.GetValidTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

procedure TCity.VisibilityRange;
begin end;

procedure TCity.SetDefaultProductions;
begin end;

procedure TCity.GenerateRebelUnits(A1: Integer);
begin end;

procedure TCity.ListCivilStatusInfo(A1: Integer);
begin end;

procedure TCity.GetCivilStatus;
begin end;

procedure TCity.UpdateImages;
begin end;

procedure TCity.SetUpgradeLevel(A1: Integer; A2: Integer);
begin end;

procedure TCity.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TCity.UpdateFlagID;
begin end;

procedure TCity.GetName(A1: Integer);
begin end;

procedure TCity.SetName(A1: Integer; A2: Integer);
begin end;

procedure TCity.SetWallType(A1: Byte);
begin end;

procedure TCity.SetRace(A1: Byte);
begin end;

procedure TCity.GetRace;
begin end;

procedure TCity.Activate;
begin end;

procedure TCity.Deactivate;
begin end;

procedure TCity.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TCity.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCity.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TCity.RemoveFromMap;
begin end;

procedure TCity.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TCity.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TCity.InitCombat(A1: Integer; A2: Integer);
begin end;

procedure TCity.GetCombatEventText(A1: Integer; A2: Integer);
begin end;

procedure TCity.FinalizeCombat(A1: Integer);
begin end;

procedure TCity.GetObtainValue;
begin end;

procedure TCity.JoinAmount(A1: Byte);
begin end;

procedure TCity.GetMoveAction(A1: Integer; A2: Integer);
begin end;

procedure TCity.IncommingNegotiateRequest(A1: Integer);
begin end;

procedure TCity.IncommingNegotiateOffer(A1: Integer);
begin end;

procedure TCity.GetEnemiesIndependentRelation(A1: Integer);
begin end;

procedure TCity.GetIndependentRelation;
begin end;

procedure TCity.ReturnBattleFieldInfo(A1: Integer);
begin end;

procedure TCity.UpdateVisibleForSeatedPlayer;
begin end;

procedure TCity.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TCity.GetTopBorderImage;
begin end;

procedure TCity.GetMiddleBorderImage;
begin end;

procedure TCity.GetBottomBorderImage;
begin end;

procedure TCity.GetTopCityActionImage(A1: Integer);
begin end;

procedure TCity.GetMiddleCityActionImage(A1: Integer);
begin end;

procedure TCity.GetBottomCityActionImage(A1: Integer);
begin end;

procedure TCity.GetCurrentActivityText(A1: Integer);
begin end;

procedure TCity.Select;
begin end;

constructor TCityResource.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCityResource.ClassID: Integer;
begin Result := 0; end;

class function TCityResource.ResourceEditName: string;
begin Result := ''; end;

function TCityResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TCityResource.ShowCity(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TCityResource.ActivateMsg;
begin end;

procedure TCityResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

class function TCityRebellionEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TCityRebellionEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCityRebellionEventLog.GetText(A1: Integer);
begin end;

procedure TCityRebellionEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TCityRebellionEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMigrationList.GetItems(A1: Integer);
begin end;

constructor TCityEnchantment.Create(AOwner: Engine.TECustomNode);
begin end;

class function TCityEnchantment.ClassID: Integer;
begin Result := 0; end;

procedure TCityEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCityEnchantment.VisibleForPlayer(A1: Integer; A2: Integer);
begin end;

procedure TCityEnchantment.GetLocation(A1: Integer; A2: Integer);
begin end;

procedure TCityEnchantment.Deactivate(A1: Byte);
begin end;

procedure TCityEnchantment.GetCity;
begin end;

procedure TCityEnchantment.GetName(A1: Integer);
begin end;

procedure TCityEnchantment.GetAIUpkeepPriority;
begin end;

class function TAICityUpgradeBudget.ClassID: Integer;
begin Result := 0; end;

class function TAICityResearchBudget.ClassID: Integer;
begin Result := 0; end;

class function TAICityFortifyBudget.ClassID: Integer;
begin Result := 0; end;

procedure TCityAIPA.Priority;
begin end;

procedure TCityAIPA.ValidResearchCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidResearchBudgetCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidateResearchBudget(A1: Integer);
begin end;

procedure TCityAIPA.ResearchProduction(A1: Integer; A2: Integer);
begin end;

procedure TCityAIPA.ValidUpgradeCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidUpgradeBudgetCity(A1: Integer);
begin end;

procedure TCityAIPA.UpgradeCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidateUpgradeBudget(A1: Integer);
begin end;

procedure TCityAIPA.ValidFortifyCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidFortifyBudgetCity(A1: Integer);
begin end;

procedure TCityAIPA.FortifyCity(A1: Integer);
begin end;

procedure TCityAIPA.ValidateFortifyBudget(A1: Integer);
begin end;

procedure TCityAIPA.UpgradeableCities(A1: Integer; A2: Integer);
begin end;

procedure TCityAIPA.UpdateStatistics;
begin end;

procedure TCityAIPA.Process(A1: Integer; A2: Integer);
begin end;

class function TCityProductionEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TCityProductionEventLog.GetCity;
begin end;

procedure TCityProductionEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure ProductionIDToCityAction(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure CityActionToProductionID(A1: Integer);
begin end;

procedure RaceInCity(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure UnitLevelToCityLevel;
begin end;

procedure PlayerCities(A1: Byte);
begin end;

procedure CityIncome(A1: Byte);
begin end;


initialization
finalization

end.
