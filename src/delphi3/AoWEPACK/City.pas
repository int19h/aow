unit City;

{ City, from AoWEPACK.dpl. Recovered TCity negotiation, resource, enchantment,
  event-log and AI bodies. Layouts and VMT order follow the original;
  production-control bodies recovered from the original code. }

interface

uses
  Animation, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Crops, EventLog, AoWReg;

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

  { TCityProductionControl (instance size 44, VMT 557A6D34): $28 FCity. }
  TCityProductionControl = class(TProductionControl)
  public
    FCity: TCity; { $28 }
    procedure ExecuteCancelProduction; override;
    function ExecuteProduction(Item: TProductionItem): Boolean; override;
    procedure GetLocation(var X, Y, L: Shortint); override;
    function GetPlayer: Shortint; override;
    function LoopableProduction(A1: TProductionItem): Boolean; override;
    function LockQueueProduction(A1: TProductionItem): Boolean; override;
    function UnitProduced: Boolean; override;
    procedure UnitResearched; override;
    procedure Update; override;
    function CreateUnitProduction(A1: Integer): TUnit; override;
    procedure NewTurn(Player: Shortint); override;
    function CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean; override;
    function GetProductionName(Item: TProductionItem): string; override;
    function GetProductionNameProgressive(Item: TProductionItem): string; override;
    function UnitProductionTime(Index: Integer): Integer; override;
  end;

  { TCityOverlayHS (instance size 28, VMT 557A6EFC): $0C FCity,
    $10 FModeStartFrame, $14 FMode, $15 FShellAnimation, $18 FShellEndFrame. }
  TCityOverlayHS = class(TSingleHS)
  public
    FCity: TCity; { $0C }
    FModeStartFrame: Integer; { $10 }
    FMode: TCityOverlayMode; { $14 }
    FShellAnimation: (saSetup, saFade); { $15 }
    F_CityOverlayHS_16: array[0..1] of Byte;
    FShellEndFrame: Integer; { $18 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure PlaySetupShellAnimation;
    procedure PlayFadeShellAnimation;
    procedure SetMode(Mode: TCityOverlayMode);
  end;

  { TMigrationItem (instance size 20, VMT 557A7084): $08 FRace, $0C FTime, $10 FRelation. }
  TMigrationItem = class(TEObject)
  public
    FRace: Shortint; { $08 }
    FReserved09: array[0..2] of Byte;
    FTime: Integer; { $0C }
    FRelation: TStatus; { $10 }
    FReserved11: array[0..2] of Byte;
  end;

  { TMigrationList (instance size 12, VMT 557A7148) }
  TMigrationList = class(TENode)
  public
    function GetItems(Index: Integer): TMigrationItem;
  end;

  { TCityEnchantment (instance size 44, VMT 557A7294): $24 FEnchantmentID, $28 FEnchantmentLocation. }
  TCityEnchantment = class(TGlobalEnchantment)
  public
    FEnchantmentID: TCityEnchantmentID; { $24 }
    F_CityEnchantment_25: array[0..2] of Byte;
    FEnchantmentLocation: TXYL; { $28 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
    function GetLocation: TXYL; override;
    function GetAIUpkeepPriority: Integer; override;
    function Deactivate(Player: Byte): Boolean; override;
    function VisibleForPlayer(Player: Shortint): Boolean; override;
    function GetCity: TCity;
  end;

  { TCity (instance size 120, VMT 557A73F0): $44 FMode, $45 FRace,
    $48 FName, $4C FWallType, $4D FUpgradeLevel, $50 FProduction,
    $54 FFlagID, $58 FEnchantmentList, $5C FEnchantments, $60 FOverlay, $64 FEnchantmentsVisible,
    $68 FWallBackImage, $6C FWallFrontImage, $70 FCityImage, $74 FDefendersMode. }
  TCity = class(TPlayerCropStructure)
  public
    FMode: TCityMode; { $44 }
    FRace: Shortint; { $45 }
    F_City_46: array[0..1] of Byte;
    FName: string; { $48 }
    FWallType: Byte; { $4C }
    FUpgradeLevel: Byte; { $4D }
    F_City_4E: array[0..1] of Byte;
    FProduction: TCityProductionControl; { $50 }
    FFlagID: Byte; { $54 }
    F_City_55: array[0..2] of Byte;
    FEnchantmentList: TGlobalEnchantmentList; { $58 }
    FEnchantments: TCityEnchantmentIDs; { $5C }
    { conflict: FEnchantmentIDs: TCityEnchantmentIDs; }
    F_City_5D: array[0..2] of Byte;
    FOverlay: TCityOverlayHS; { $60 }
    FEnchantmentsVisible: Boolean; { $64 }
    F_City_65: array[0..2] of Byte;
    FWallBackImage: TLibraryImage; { $68 }
    FWallFrontImage: TLibraryImage; { $6C }
    FCityImage: TLibraryImage; { $70 }
    FDefendersMode: TDefendersGenerateMode; { $74 }
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
    function GetTopBorderImage: TLibraryImage; override;
    function GetMiddleBorderImage: TLibraryImage; override;
    function GetBottomBorderImage: TLibraryImage; override;
    function GetName: string; override;
    procedure SetRazed(Value: Boolean); override;
    function GetRazed: Boolean; override;
    procedure SetupRazeDefenderAG(Armies, Units: TUnitList); override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    function GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean; override;
    function GetDefensePriority: TDefensePriority; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure ArmyPlaced(A1: TArmyHS); override;
    procedure ArmyRemoved(Army: TArmyHS); override;
    procedure BuildingDone; override;
    function GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean; override;
    function ExecuteRaze(Player: Shortint): Boolean; override;
    function GetCurrentActivityText: string; override;
    function ValidateMap(A1: TStrings): Boolean; override;
    procedure UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData); override;
    procedure Update; override;
    function CanDblClick: Boolean; override;
    procedure GetRebuildInfo(var Cost, Time: Integer); override;
    procedure SetPlayer(Player: Shortint); override;
    procedure UpdateFlagID; override;
    function VisibilityRange: Integer; override;
    procedure FinalizeCombat(Combat: TCombat); override;
    function GetCombatEventText(Combat: TCombat): string; override;
    procedure StructureCaptured(OldPlayer, NewPlayer: Shortint); override;
    function GetMoveAction(Player: Shortint; Action: TMoveAction): TMoveAction; override;
    function UpdatePlayer: Boolean; override;
    procedure UpdateIncome; override;
    procedure UpdateCrops; override;
    function GetRace: Shortint; override;
    procedure CropTrampled(Player: Shortint); override;
    procedure SetRace(Race: Shortint); virtual;
    function GetActiveAction: TCityAction;
    procedure UpdateActiveEnchantments;
    procedure RegisterEnchantments;
    procedure UnregisterEnchantments;
    procedure ResetEnchantments;
    function AICityEnchantmentUpkeepPriority(ID: TCityEnchantmentID): Integer;
    procedure ActivateEnchantment(Enchantment: TCityEnchantment);
    procedure DeactivateEnchantment(Enchantment: TCityEnchantment);
    procedure ListEnhancementsInfo(List: TStrings);
    procedure StartTownQuake;
    procedure StopTownQuake;
    procedure ExecuteAnarchy;
    function ExecuteFountainOfLife: Boolean;
    procedure UpdateAIMigration;
    procedure ValidateAICityAction;
    function MoveArmiesOutOfCity(Selection: TMoveOutOfCitySelection): Boolean;
    function GetSize: Integer;
    function GetObtainUnitsValue: Integer;
    function UpgradeCost: Integer;
    function UpgradeTime: Integer;
    function CanUpgrade(Queue: Boolean; var Reason: string): Boolean;
    function Upgrade(Queue: Boolean): Boolean;
    function FortifyCost: Integer;
    function FortifyTime: Integer;
    function CanFortify(Queue: Boolean; var Reason: string): Boolean;
    function Fortify(Queue: Boolean): Boolean;
    function ProductionCost(Index: Integer): Integer;
    function ProductionTime(Index: Integer): Integer;
    function CanProduce(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
    function Produce(Index: Integer; Queue: Boolean): Boolean;
    function ResearchCost(Index: Integer): Integer;
    function ResearchTime(Index: Integer): Integer;
    function CanResearch(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
    function Research(Index: Integer; Queue: Boolean): Boolean;
    function CanTrade(Queue: Boolean; var Reason: string): Boolean;
    function Trade(Queue: Boolean): Boolean;
    function LootTime: Integer;
    function CanLoot(var Reason: string): Boolean;
    function Loot: Boolean;
    function MigrationTime(Race: Shortint): Integer;
    function CanMigrate(Race: Shortint; var Reason: string): Boolean;
    function Migrate(Race: Shortint): Boolean;
    function CreateMigrationItem(Race: Shortint): TMigrationItem;
    function CreateMigrationSelection: TMigrationList;
    procedure CheckRebellion;
    procedure GenerateDefenders;
    procedure ListIncomeInfo(Names, Values: TStrings);
    procedure SetDefaultProductions;
    procedure GenerateRebelUnits(Units: TUnitList);
    procedure ListCivilStatusInfo(List: TStrings);
    function GetCivilStatus: TCivilStatus;
    procedure UpdateImages;
    procedure SetUpgradeLevel(Level: Byte);
    procedure SetName(Name: string);
    procedure SetWallType(WallType: Byte);
    procedure InitCombat(Combat: TCombat; Army: TArmyHS);
    function GetObtainValue: Integer;
    function JoinAmount(Player: Shortint): Integer;
    function IncommingNegotiateRequest(Request: TNegotiateRequestEventLog): Boolean;
    function IncommingNegotiateOffer(Offer: TNegotiateTE): Boolean;
    function GetEnemiesIndependentRelation(Player: Shortint): Shortint;
    function GetIndependentRelation: Shortint;
    procedure ReturnBattleFieldInfo(var Info: TBattleFieldInfo);
    procedure UpdateVisibleForSeatedPlayer;
    function GetTopCityActionImage(Action: TCityAction): TLibraryImage;
    function GetMiddleCityActionImage(Action: TCityAction): TLibraryImage;
    function GetBottomCityActionImage(Action: TCityAction): TLibraryImage;
  end;

  { TCityResource (instance size 124, VMT 557A76AC): $78 FSize. }
  TCityResource = class(TPlayerCropStructureResource)
  public
    FSize: Byte; { $78 }
    F_CityResource_79: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    class function ResourceEditName: string; override;
    function ResourceUserClassID: Integer; override;
    procedure ShowCity(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; City: TCity);
    procedure ActivateMsg;
  end;

  { TCityRebellionEventLog (instance size 40, VMT 557A77A0): $18 FXhx, $1C FYhx,
    $20 FLhx, $24 FCityName. }
  TCityRebellionEventLog = class(TEventLog)
  public
    FXhx: Integer; { $18 }
    FYhx: Integer; { $1C }
    FLhx: Integer; { $20 }
    FCityName: string; { $24 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
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

  { TCityAIPA (instance size 48, VMT 557A7B54): $14 FCityCount,
    $18..$24 FProductionLevelCounts, $28 FMaxProductionLevel, $2C FProductionRatio. }
  TCityAIPA = class(TAIPlayerAction)
  public
    FCityCount: Integer; { $14 }
    FProductionLevelCounts: array[1..4] of Integer; { $18..$24 }
    FMaxProductionLevel: Integer; { $28 }
    FProductionRatio: Single; { $2C }
    class function Priority: Integer; override;
    function Process: Boolean; override;
    function ValidResearchCity(City: TCity): Boolean;
    function ValidResearchBudgetCity(City: TCity): Boolean;
    procedure ValidateResearchBudget(Budget: TAIBudget);
    function ResearchProduction(ResearchBudget, UpgradeBudget: TAIBudget): Boolean;
    function ValidUpgradeCity(City: TCity): Boolean;
    function ValidUpgradeBudgetCity(City: TCity): Boolean;
    function UpgradeCity(Budget: TAIBudget): Boolean;
    procedure ValidateUpgradeBudget(Budget: TAIBudget);
    function ValidFortifyCity(City: TCity): Boolean;
    function ValidFortifyBudgetCity(City: TCity): Boolean;
    function FortifyCity(Budget: TAIBudget): Boolean;
    procedure ValidateFortifyBudget(Budget: TAIBudget);
    function UpgradeableCities: Integer;
    procedure UpdateStatistics;
  end;

  { TCityProductionEventLog (instance size 32, VMT 557A7C24) }
  TCityProductionEventLog = class(TProductionEventLog)
  public
    class function ClassID: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    function GetCity: TCity;
  end;

  { TRegistrator (instance size 4, VMT 557AF144): no added fields. }
  TRegistrator = class(TObject)
  public
    class procedure MapLoaded(Sender: TObject);
  end;

function ProductionIDToCityAction(ID: Integer): TCityAction;
function CityActionToProductionID(Action: TCityAction): Integer;
function RaceInCity(Race, Player: Shortint): Boolean;
function UnitLevelToCityLevel(Level, Size: Integer): Integer;
function PlayerCities(Player: Shortint): Integer;
function CityIncome(Player: Shortint): Integer; const TCivilStatusRStr: array[TCivilStatus] of string = ('Unruly', 'Unrest', 'Stable', 'Content', 'Cheerful', 'Oppressed', 'Slavery'); { export $558E8E10; AoW 0043B208 }

implementation

type
  PAoWMap = ^TAoWHSMap;
  PAoWSet = ^TAoWHSSet;
  PRaceNames = ^TRaceNames;
  TRaceNames = array[0..12] of string;
const
  WorldMap: PAoWMap = @AoWE.AoWHSMap;
  WorldSet: PAoWSet = @AoWE.AoWHSSet;
  WorldEngine: ^TAoWEngine = @AoWE.AoWEngine;
  RandomSeed: ^Integer = @System.RandSeed;
  RaceTerrainTable: ^TRaceTerrainTable = @AoWE.RaceTerrain;
  StatusNames: ^TStatusNames = @AoWE.TStatusRStr;
  RaceNames: PRaceNames = @AoWE.RaceNamesPluralRStr;
  CityEnchantmentNames: array[TCityEnchantmentID] of string = ('Fountain Of Life', 'Gold Rush', 'Anti Magic Shell', 'Warmonger');
  UpgradePrices: array[1..4] of Byte = (250, 250, 250, 250);
  WoodWallPrices: array[1..4] of Byte = (20, 40, 60, 80);
  StoneWallPrices: array[1..4] of Byte = (20, 40, 60, 80);
resourcestring
  CityNotEnoughGoldRStr = 'Not enough gold.';
  CityWarningRStr = 'Warning';
  CityWoodenWallRStr = 'Wooden Wall';
  CityStoneWallRStr = 'Stone Wall';
const
  CapturedText: PResStringRec = @AoWE.StructureCapturedRStr;
  MaxUpgradeText: PResStringRec = @AoWE.MaxUpgradeLevelReachedRStr;
  MaxFortifyText: PResStringRec = @AoWE.MaxFortifyLevelReachedRStr;
  BaseIncomeText: PResStringRec = @AoWE.BaseIncomeRStr;
  XCropFieldsText: PResStringRec = @AoWE.XCropFieldsRStr;
  ProducingMerchandiseText: PResStringRec = @AoWE.ProducingMerchandiseRStr;
  GoldRushText: PResStringRec = @AoWE.GoldRushRStr;
  CityText: PResStringRec = @AoWE.CityRStr;
  RebellionText: PResStringRec = @AoWE.CityRebellionRStr;
  RaceRelationXText: PResStringRec = @AoWE.RaceRelationXRStr;
  TerrainPenaltyXText: PResStringRec = @AoWE.TerrainPenaltyXRStr;
  TerrainBonusXText: PResStringRec = @AoWE.TerrainBonusXRStr;
  AverageText: PResStringRec = @AoWE.AverageRStr;
  StrongText: PResStringRec = @AoWE.StrongRStr;
  WeakText: PResStringRec = @AoWE.WeakRStr;
  OccupationForcesXText: PResStringRec = @AoWE.OccupationForcesXRStr;
  CityBattleWonText: PResStringRec = @AoWE.CityBattleWonRStr;
  CityBattleLostText: PResStringRec = @AoWE.CityBattleLostRStr;
  CityBattleDrawnText: PResStringRec = @AoWE.CityBattleDrawnRStr;
  NotEnoughGold: PResStringRec = @CityNotEnoughGoldRStr;
  WarningText: PResStringRec = @CityWarningRStr;
  WoodenWallText: PResStringRec = @CityWoodenWallRStr;
  StoneWallText: PResStringRec = @CityStoneWallRStr;

function TCityProductionControl.CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean;
begin
  case ProductionIDToCityAction(Item.FProductionID) of
    caTrade: Result := True;
    caFortify:
      if WorldMap^.FPlayers.GetPlayers(GetPlayer).FGems >= FCity.FortifyCost then
        Result := True
      else
      begin
        Result := False;
        Reason := TranslateRStr(LoadResString(NotEnoughGold));
      end;
    caMigrate: Result := FCity.CanMigrate(Item.FParameter, Reason);
    caLoot: Result := FCity.CanLoot(Reason);
    caUpgrade:
      if WorldMap^.FPlayers.GetPlayers(GetPlayer).FGems >= FCity.UpgradeCost then
        Result := True
      else
      begin
        Result := False;
        Reason := TranslateRStr(LoadResString(NotEnoughGold));
      end;
  else Result := inherited CanExecuteProduction(Item, Reason);
  end;
end;

function TCityProductionControl.ExecuteProduction(Item: TProductionItem): Boolean;
var Log: TLocationTextEventLog;
begin
  Result := inherited ExecuteProduction(Item);
  if Result then
    case ProductionIDToCityAction(Item.FProductionID) of
      caTrade:
        begin
          FSettings.FTurnsTotal := Item.FParameter;
          FSettings.FTurnsLeft := 1;
          FSettings.FPlayer := GetPlayer;
          FStatus := pcsProducing;
        end;
      caFortify:
        begin
          FSettings.FTurnsTotal := FCity.FortifyTime;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          FSettings.FPlayer := GetPlayer;
          FSettings.FGold := FCity.FortifyCost;
          WorldMap^.FPlayers.GetPlayers(GetPlayer).SetGems(
            WorldMap^.FPlayers.GetPlayers(GetPlayer).FGems - FSettings.FGold);
          FStatus := pcsProducing;
        end;
      caUpgrade:
        begin
          FSettings.FTurnsTotal := FCity.UpgradeTime;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          FSettings.FPlayer := GetPlayer;
          FSettings.FGold := FCity.UpgradeCost;
          WorldMap^.FPlayers.GetPlayers(GetPlayer).SetGems(
            WorldMap^.FPlayers.GetPlayers(GetPlayer).FGems - FSettings.FGold);
          FStatus := pcsProducing;
        end;
      caLoot:
        begin
          FSettings.FTurnsTotal := FCity.LootTime;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          FSettings.FPlayer := GetPlayer;
          FSettings.FGold := 0;
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + (-30));
          Log := TLocationTextEventLog.Create(nil);
          Log.FPlayer := GetPlayer;
          Log.FText := SysUtils.Format(TranslateRStr(CityLootingRStr), [FCity.GetName]);
          Log.SetLocation(FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
          DistributeLocationEventLog(Log, GetPlayer, FCity.GetXhx, FCity.GetYhx, FCity.GetLhx, False);
          Log.Release;
          FCity.FOverlay.SetMode(omLooting);
          FStatus := pcsProducing;
        end;
      caMigrate:
        begin
          FSettings.FTurnsTotal := FCity.MigrationTime(Item.FParameter);
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          FSettings.FPlayer := GetPlayer;
          FStatus := pcsProducing;
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + (-15));
        end;
    end;
end;

procedure TCityProductionControl.NewTurn(Player: Shortint);
var Log: TCityProductionEventLog;
begin
  inherited NewTurn(Player);
  if (FStatus = pcsProducing) and (Player = FSettings.FPlayer) and
    (FSettings.FTurnsLeft = 0) then
    case ProductionIDToCityAction(FQueue.GetItem(0).FProductionID) of
      caTrade: ProductionDone;
      caUpgrade:
        begin
          BeginUpdate;
          FCity.SetUpgradeLevel(FCity.FUpgradeLevel + 1);
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + 5);
          ProductionDone;
          Log := TCityProductionEventLog.Create(nil);
          Log.FPlayer := GetPlayer;
          Log.FText := SysUtils.Format(TranslateRStr(XUpgradedRStr), [FCity.GetName]);
          Log.SetLocation(FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
          WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
          Log.Release;
          EndUpdate;
        end;
      caFortify:
        begin
          BeginUpdate;
          case FCity.FWallType of
            0: FCity.FWallType := 1;
            1: FCity.FWallType := 2;
          end;
          Log := TCityProductionEventLog.Create(nil);
          Log.FPlayer := GetPlayer;
          Log.FText := SysUtils.Format(TranslateRStr(CityFortifiedRStr), [FCity.GetName]);
          Log.SetLocation(FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
          WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
          Log.Release;
          FCity.UpdateImages;
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + 5);
          ProductionDone;
          EndUpdate;
        end;
      caLoot:
        begin
          BeginUpdate;
          Log := TCityProductionEventLog.Create(nil);
          Log.FPlayer := GetPlayer;
          Log.FText := SysUtils.Format(TranslateRStr(CityLootedRStr), [FCity.GetName, IntToStr(FCity.FIncome * 3)]);
          Log.SetLocation(FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
          WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
          Log.Release;
          WorldMap^.FPlayers.GetPlayers(GetPlayer).SetGems(
            WorldMap^.FPlayers.GetPlayers(GetPlayer).FGems + FCity.FIncome * 3);
          FCity.FOverlay.SetMode(omIdle);
          FCity.SetRazed(True);
          EndUpdate;
        end;
      caMigrate:
        begin
          BeginUpdate;
          Log := TCityProductionEventLog.Create(nil);
          Log.FPlayer := GetPlayer;
          Log.FText := SysUtils.Format(TranslateRStr(CityMigratedToRStr), [FCity.GetName, TranslateRStr(RaceNames^[FQueue.GetItem(0).FParameter])]);
          Log.SetLocation(FCity.GetXhx, FCity.GetYhx, FCity.GetLhx);
          WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
          Log.Release;
          FCity.SetRace(FQueue.GetItem(0).FParameter);
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + 10);
          FUnitProductions.Clear;
          FCity.SetUpgradeLevel(FCity.FUpgradeLevel);
          ProductionDone;
          EndUpdate;
        end;
    end;
end;

procedure TCityProductionControl.ExecuteCancelProduction;
begin
  if FStatus = pcsProducing then
    case ProductionIDToCityAction(FQueue.GetItem(0).FProductionID) of
      caLoot:
        if FSettings.FTurnsLeft = FSettings.FTurnsTotal then
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) - (-30))
        else
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + 20);
      caMigrate:
        if FSettings.FTurnsLeft = FSettings.FTurnsTotal then
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) - (-15))
        else
          WorldMap^.FRaces.GetRace(FCity.FRace).SetPlayerRelationValue(GetPlayer,
            WorldMap^.FRaces.GetRace(FCity.FRace).GetPlayerRelationValue(GetPlayer) + 10);
    end;
  inherited ExecuteCancelProduction;
end;

function TCityProductionControl.LockQueueProduction(A1: TProductionItem): Boolean;
begin
  Result := inherited LockQueueProduction(A1);
  case ProductionIDToCityAction(TProductionItem(A1).FProductionID) of
    caMigrate: Result := True;
    caLoot: Result := True;
  end;
end;

function TCityProductionControl.LoopableProduction(A1: TProductionItem): Boolean;
begin
  Result := inherited LoopableProduction(A1);
  case ProductionIDToCityAction(TProductionItem(A1).FProductionID) of
    caMigrate: Result := False;
    caLoot: Result := False;
    caFortify: Result := False;
    caUpgrade: Result := False;
  end;
end;

function TCityProductionControl.GetProductionName(Item: TProductionItem): string;
begin
  Result := inherited GetProductionName(Item);
  case ProductionIDToCityAction(Item.FProductionID) of
    caTrade: Result := TranslateRStr(ProduceMerchandiseRStr);
    caUpgrade: Result := TranslateRStr(UpgradeRStr);
    caMigrate: Result := SysUtils.Format(TranslateRStr(MigrateToXRStr), [TranslateRStr(RaceNames^[Item.FParameter])]);
    caLoot: Result := TranslateRStr(LootRStr);
    caFortify: Result := TranslateRStr(FortifyRStr);
  end;
end;

function TCityProductionControl.GetProductionNameProgressive(Item: TProductionItem): string;
begin
  Result := inherited GetProductionNameProgressive(Item);
  case ProductionIDToCityAction(Item.FProductionID) of
    caTrade: Result := TranslateRStr(ProducingMerchandiseRStr);
    caUpgrade: Result := TranslateRStr(UpgradingRStr);
    caMigrate: Result := SysUtils.Format(TranslateRStr(MigratingToXRStr), [TranslateRStr(RaceNames^[Item.FParameter])]);
    caLoot: Result := TranslateRStr(LootingRStr);
    caFortify: Result := TranslateRStr(FortifyingRStr);
  end;
end;

procedure TCityProductionControl.Update;
begin
  inherited Update;
  if FUpdateCount = 0 then FCity.Update;
end;

procedure TCityProductionControl.GetLocation(var X, Y, L: Shortint);
begin
  X := FCity.GetXhx;
  Y := FCity.GetYhx;
  L := FCity.GetLhx;
end;

function TCityProductionControl.CreateUnitProduction(A1: Integer): TUnit;
var Unit_: TUnit;
begin
  Unit_ := inherited CreateUnitProduction(A1);
  if (Unit_ <> nil) and (ceiWarmonger in FCity.FEnchantments) then Unit_.SetRank(urSilver);
  Result := Unit_;
end;

procedure TCityProductionControl.UnitResearched;
var
  City: TCity;
  Log: TCityProductionEventLog;
begin
  inherited UnitResearched;
  City := FCity;
  Log := TCityProductionEventLog.Create(nil);
  Log.FPlayer := City.FPlayer;
  Log.FText := SysUtils.Format(TranslateRStr(XInstalledAtYRStr),
    [WorldSet^.FUnitResources.GetUnitResource(FUnitProductions.GetItem(FSettings.FUnitProductionIndex).FUnitIndex).GetUnitName,
    FCity.GetName]);
  Log.SetLocation(City.GetXhx, City.GetYhx, City.GetLhx);
  WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
  Log.Release;
end;

function TCityProductionControl.UnitProduced: Boolean;
var
  City: TCity;
  Valid: Boolean;
  Count: Integer;
  Level: TMapLevel;
  Walk: THNWalkData;
  Log: TCityProductionEventLog;
begin
  City := FCity;
  Valid := False;
  Count := City.GetTerrainCount;
  Level := TMapLevel(City.Owner.Owner);
  InitHNWalk(Walk, City.GetXhx, City.GetYhx, 0);
  while (Walk.HN < Count) and not Valid do
  begin
    if (City.FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      Valid := FSettings.FUnit.Place(Walk.X, Walk.Y, City.GetLhx, City.FPlayer, []) <> nil;
    WalkToNextHN(Walk);
  end;
  if not Valid then
    Valid := FSettings.FUnit.Place(City.GetXhx, City.GetYhx, City.GetLhx, City.FPlayer, [pmScanArea]) <> nil;
  Log := TCityProductionEventLog.Create(nil);
  Log.FPlayer := City.FPlayer;
  Log.FText := SysUtils.Format(TranslateRStr(XProducedAtYRStr), [FSettings.FUnit.GetName, FCity.GetName]);
  Log.SetLocation(City.GetXhx, City.GetYhx, City.GetLhx);
  WorldMap^.FPlayers.GetPlayers(Log.FPlayer).FEventLogbook.AddEvent(Log);
  Log.Release;
  Result := Valid;
end;

function TCityProductionControl.GetPlayer: Shortint;
begin Result := FCity.FPlayer; end;

function TCityProductionControl.UnitProductionTime(Index: Integer): Integer;
var UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := WorldSet^.FUnitResources.GetUnitResource(UnitIndex).FLevel - FCity.GetSize div 2 + 1;
  if Result < 1 then Result := 1;
end;

function TCityOverlayHS.GetShowPriority: Integer;
begin Result := FCity.GetShowPriority + $8000000; end;

procedure TCityOverlayHS.PlaySetupShellAnimation;
begin
  FShellAnimation := saSetup;
  FShellEndFrame := WorldMap^.Frame + 50;
end;

procedure TCityOverlayHS.PlayFadeShellAnimation;
begin
  FShellAnimation := saFade;
  FShellEndFrame := WorldMap^.Frame + 20;
end;

procedure TCityOverlayHS.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp, Intensity, Index, Frame: Integer;
  Sequence: TImageSequence;
begin
  HXtoHP(FCity.FXhx, FCity.FYhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  if FCity.FEnchantmentsVisible then
  begin
    if ceiWarmonger in FCity.FEnchantments then
    begin
      Intensity := Abs(Integer((WorldMap^.Frame shr 1) mod 20) - 10) + 50;
      Sequence := FCity.FResource.ImageSequenceList.ImageSequences[17];
      while Sequence <> nil do
      begin
        Index := Sequence.GetFrameIndex(0, 0);
        if Sequence = FCity.FResource.ImageSequenceList.ImageSequences[17] then
          Sequence.ImageLibrary[Index].ShowBlended(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift, SurfaceDesc, IntensityBlendTable.LookupTables[Intensity])
        else
          Sequence.ImageLibrary[Index].ShowBlended(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift, SurfaceDesc, AlphaBlendTable.LookupTables[Intensity]);
        Sequence := Sequence.Next;
      end;
    end;
    if ceiGoldRush in FCity.FEnchantments then
    begin
      Intensity := Abs(Integer((WorldMap^.Frame shr 1) mod 20) - 10) + 70;
      Sequence := FCity.FResource.ImageSequenceList.ImageSequences[18];
      while Sequence <> nil do
      begin
        if Sequence = FCity.FResource.ImageSequenceList.ImageSequences[18] then
        begin
          Index := Sequence.GetFrameIndex(0, 0);
          if Sequence.ImageLibrary.ImageExist(Index) then
            Sequence.ImageLibrary[Index].ShowBlended(XhpSurf + Sequence.dXshift,
              YhpSurf + Sequence.dYshift, SurfaceDesc, IntensityBlendTable.LookupTables[Intensity]);
        end
        else
        begin
          Index := Sequence.GetFrameIndex(0, WorldMap^.Frame);
          if Sequence.ImageLibrary.ImageExist(Index) then
            Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift,
              YhpSurf + Sequence.dYshift, SurfaceDesc);
        end;
        Sequence := Sequence.Next;
      end;
    end;
    if ceiAntiMagicShell in FCity.FEnchantments then
    begin
      Sequence := FCity.FResource.ImageSequenceList.ImageSequences[19];
      if Sequence <> nil then
      begin
        Intensity := 50;
        Index := Sequence.GetFrameIndex(0, 0);
        if (FShellEndFrame <> -1) and (WorldMap^.Frame < FShellEndFrame) then
        begin
          case FShellAnimation of
            saSetup:
              begin
                Frame := FShellEndFrame - WorldMap^.Frame;
                if Frame <= 50 then Intensity := 50 - Frame else FShellEndFrame := -1;
              end;
            saFade:
              begin
                Frame := FShellEndFrame - WorldMap^.Frame;
                if Frame <= 20 then Intensity := Intensity + (10 - Abs(Frame - 10)) * 3
                else FShellEndFrame := -1;
              end;
          end;
        end;
        Sequence.ImageLibrary[Index].ShowBlended(XhpSurf + Sequence.dXshift,
          YhpSurf + Sequence.dYshift, SurfaceDesc, IntensityBlendTable.LookupTables[Intensity]);
      end;
    end;
    if FMode = omLooting then
      FCity.FResource.ShowComplexImage(XhpSurf, YhpSurf, SurfaceDesc, 22,
        TMapField(FCity.Owner).Xhx + TMapField(FCity.Owner).Yhx * 16);
  end;
end;

procedure TCityOverlayHS.SetMode(Mode: TCityOverlayMode);
begin
  if Mode <> FMode then
  begin
    FModeStartFrame := WorldMap^.Frame;
    FMode := Mode;
  end;
end;

constructor TCity.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FProduction := TCityProductionControl.Create(nil);
  FProduction.FCity := Self;
  FDefendersMode := dgAverage;
  FRace := -1;
  FName := TranslateRStr(NonameRStr);
  FUpgradeLevel := 1;
  FOverlay := TCityOverlayHS.Create(nil);
  FOverlay.FCity := Self;
  FEnchantmentList := TGlobalEnchantmentList.Create(nil);
  FEnchantmentsVisible := False;
end;

destructor TCity.Destroy;
begin
  if GetVisible then WorldMap^.DynamicVisibleHS.RemoveChild(FOverlay);
  FOverlay.Free;
  inherited Destroy;
  FProduction.Free;
  FEnchantmentList.Free;
  FEnchantmentList := nil;
end;

class function TCity.ClassID: Integer;
begin Result := $20108; end;

function TCity.CanDblClick: Boolean;
begin
  Result := (WorldMap^.FSeatedPlayer = FPlayer) and not GetRazed and not GetBuilding;
end;

function TCity.GetActiveAction: TCityAction;
begin
  if FProduction.FStatus = pcsProducing then
    Result := ProductionIDToCityAction(FProduction.FQueue.GetItem(0).FProductionID)
  else Result := caNone;
end;

function TCity.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
begin Result := inherited ExecuteTE(A1, Executer); end;

procedure TCity.Update;
begin
  if FUpdateCount = 0 then
  begin
    UpdateIncome;
    inherited Update;
  end;
end;

function TCity.ValidateMap(A1: TStrings): Boolean;
begin
  Result := inherited ValidateMap(A1);
  if (CompareText(FName, TranslateRStr(NonameRStr)) = 0) or (FName = '') then
  begin
    TStrings(A1).Add(TranslateRStr(LoadResString(WarningText)) + ': ' + TranslateRStr(NoNameSpecifiedRStr));
    Result := False;
  end;
end;

procedure TCity.BuildingDone;
begin
  FUpgradeLevel := 1;
  FWallType := 0;
  SetRace(WorldMap^.FPlayers.GetPlayers(FBuildingPlayer).FPlayerRace);
  inherited BuildingDone;
end;

procedure TCity.UpdateActiveEnchantments;
var I: Integer;
begin
  FEnchantments := [];
  for I := FEnchantmentList.Count - 1 downto 0 do
    FEnchantments := FEnchantments + [TCityEnchantment(FEnchantmentList.GetEnchantments(I)).FEnchantmentID];
end;

procedure TCity.RegisterEnchantments;
var I: Integer;
begin
  for I := FEnchantmentList.Count - 1 downto 0 do
    FEnchantmentList.GetEnchantments(I).Activate(FEnchantmentList.GetEnchantments(I).FPlayerIndex);
  UpdateActiveEnchantments;
end;

procedure TCity.UnregisterEnchantments;
var I: Integer;
begin
  for I := FEnchantmentList.Count - 1 downto 0 do
    FEnchantmentList.GetEnchantments(I).Deactivate(FEnchantmentList.GetEnchantments(I).FPlayerIndex);
end;

procedure TCity.ResetEnchantments;
begin
  UnregisterEnchantments;
  FEnchantmentList.Clear;
  FEnchantments := [];
end;

function TCity.AICityEnchantmentUpkeepPriority(ID: TCityEnchantmentID): Integer;
begin
  case ID of
    ceiFountainOfLife: Result := GetSize * 25 + 600;
    ceiGoldRush: Result := GetSize * 25 + 600;
    ceiAntiMagicShell: Result := GetSize * 25 + 700;
    ceiWarmonger: Result := GetSize * 25 + 600;
  else Result := 0;
  end;
end;

procedure TCity.ActivateEnchantment(Enchantment: TCityEnchantment);
begin
  Enchantment.Owner := FEnchantmentList;
  Enchantment.Activate(Enchantment.FPlayerIndex);
  FEnchantments := FEnchantments + [Enchantment.FEnchantmentID];
  if Enchantment.FEnchantmentID = ceiFountainOfLife then ExecuteFountainOfLife;
  if Enchantment.FEnchantmentID = ceiGoldRush then UpdateIncome;
  if Enchantment.FEnchantmentID = ceiAntiMagicShell then FOverlay.PlaySetupShellAnimation;
end;

procedure TCity.DeactivateEnchantment(Enchantment: TCityEnchantment);
begin
  Enchantment.Owner := nil;
  Enchantment.Deactivate(Enchantment.FPlayerIndex);
  UpdateActiveEnchantments;
  if Enchantment.FEnchantmentID = ceiGoldRush then UpdateIncome;
  Enchantment.Release;
  Update;
end;

procedure TCity.ListEnhancementsInfo(List: TStrings);
begin
  List.Add(SysUtils.Format(TranslateRStr(UpgradeLevelXRStr), [IntToStr(FUpgradeLevel)]));
  if FWallType = 1 then List.Add(TranslateRStr(LoadResString(WoodenWallText)));
  if FWallType = 2 then List.Add(TranslateRStr(LoadResString(StoneWallText)));
  if ceiFountainOfLife in FEnchantments then
    List.Add(TranslateRStr(EnchantmentRStr) + ': ' + TranslateRStr(FountainOfLifeRStr));
  if ceiGoldRush in FEnchantments then
    List.Add(TranslateRStr(EnchantmentRStr) + ': ' + TranslateRStr(GoldRushRStr));
  if ceiAntiMagicShell in FEnchantments then
    List.Add(TranslateRStr(EnchantmentRStr) + ': ' + TranslateRStr(AntiMagicShellRStr));
  if ceiWarmonger in FEnchantments then
    List.Add(TranslateRStr(EnchantmentRStr) + ': ' + TranslateRStr(WarmongerRStr));
end;

procedure TCity.StartTownQuake;
begin FMode := FMode + [cmTownQuake]; end;

procedure TCity.StopTownQuake;
begin FMode := FMode - [cmTownQuake]; end;

procedure TCity.ExecuteAnarchy;
begin
  FMode := FMode + [cmAnarchy];
  CheckRebellion;
  FMode := FMode - [cmAnarchy];
end;

function TCity.ExecuteFountainOfLife: Boolean;
var
  Armies: TArmyHSList;
  I: Integer;
  Animation: TImageSequenceAnimation;
  PlaySound: Boolean;
begin
  Armies := TArmyHSList.Create(nil);
  ListArmies(Armies);
  Result := False;
  PlaySound := False;
  for I := 0 to Armies.Count - 1 do
    if Armies.GetArmyHS(I).FArmy.HealUnits($FF) then
    begin
      if WorldMap^.VisibleForPlayer(Armies.GetArmyHS(I).GetXhx, Armies.GetArmyHS(I).GetYhx,
        Armies.GetArmyHS(I).GetLhx, WorldMap^.FSeatedPlayer) then
      begin
        Animation := TImageSequenceAnimation.Create(nil);
        Animation.SetImageSequence(WorldSet^.FAbilityControl.GetAbility(47).FImageSequences.ImageSequences[0]);
        Animation.FAnimationLevel := 27;
        WorldMap^.PlaceHX(Animation, Armies.GetArmyHS(I).GetXhx,
          Armies.GetArmyHS(I).GetYhx, Armies.GetArmyHS(I).GetLhx);
        PlaySound := PlaySound or (Armies.GetArmyHS(I).FArmy.FPlayer = WorldMap^.FSeatedPlayer) or
          WorldMap^.Watching(Armies.GetArmyHS(I).GetXhx, Armies.GetArmyHS(I).GetYhx,
            Armies.GetArmyHS(I).GetLhx, 1);
      end;
      Result := True;
    end;
  if PlaySound then WorldSet^.FAbilityControl.GetAbility(47).FSFXLibrary.Play(0);
  Armies.Free;
end;

procedure TCity.UpdateAIMigration;
var
  Selection: TMigrationList;
  I, Value, BestIndex, BestValue: Integer;
  Item: TProductionItem;
begin
  if (WorldMap^.FDay <> 0) and not (msEditting in WorldMap^.Status) then
    if FPlayer > 0 then
    begin
      if (WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman) and
        ([cmWarmode, cmRazed] * FMode = []) and (GetActiveAction in [caNone, caTrade]) and
        (WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer) in [sHostile, sWary, sNeutral]) then
      begin
        Selection := CreateMigrationSelection;
        BestValue := 0;
        BestIndex := -1;
        for I := 0 to Selection.Count - 1 do
        begin
          if Selection.GetItems(I).FRelation in [sPolite, sFriendly] then
          begin
            if (WorldMap^.FPlayers.RaceToPlayer(Selection.GetItems(I).FRace) = -1) or
              (Selection.GetItems(I).FRace = WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerRace) then
              Value := 10 else Value := 5;
          end else Value := 0;
          Inc(Value, Selection.GetItems(I).FTime);
          if (Value > BestValue) or ((Value = BestValue) and (WorldMap^.Random(2) = 1)) then
          begin
            BestValue := Value;
            BestIndex := I;
          end;
        end;
        if BestIndex <> -1 then
        begin
          FProduction.ExecuteDeleteProductions;
          Item := TProductionItem.Create(nil);
          Item.FProductionID := CityActionToProductionID(caMigrate);
          Item.FParameter := Selection.GetItems(BestIndex).FRace;
          FProduction.ExecuteAddProduction(Item);
          Item.Free;
        end;
        Selection.Free;
      end;
    end
    else if (FPlayer = 0) and (GetActiveAction in [caMigrate, caLoot]) then
      FProduction.ExecuteDeleteProductions;
end;

procedure TCity.StructureCaptured(OldPlayer, NewPlayer: Shortint);
var
  Log: TCityProductionEventLog;
  Text: string;
begin
  if not GetRazed and not GetBuilding and (OldPlayer = 0) and
    not (msEditting in WorldMap^.Status) and (moActivated in FStatus) and
    not TCityResource(FResource).FClaimed then
  begin
    Log := TCityProductionEventLog.Create(nil);
    Log.FPlayer := NewPlayer;
    Text := SysUtils.Format(TranslateRStr(LoadResString(CapturedText)), [EditName]);
    Log.FText := Text;
    Log.FXhx := GetXhx;
    Log.FYhx := GetYhx;
    Log.FLhx := GetLhx;
    DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, False);
    Log.Release;
  end;
end;

procedure TCity.ValidateAICityAction;
begin
  if (FPlayer > 0) and (WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman) and
    ([cmWarmode, cmRazed] * FMode = []) and not (GetActiveAction in [caNone, caTrade]) then
    if (WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer) in [sHostile, sWary, sNeutral]) and
      not ((GetActiveAction = caMigrate) and
        (WorldMap^.FRaces.GetRace(FProduction.FQueue.GetItem(0).FParameter).GetPlayerRelation(FPlayer)
          in [sPolite, sFriendly])) then
      FProduction.ExecuteDeleteProductions;
end;

procedure TCity.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    FProduction.PlayerChanged;
    ResetEnchantments;
    if FPlayer <> -1 then WorldMap^.FPlayers.GetPlayers(FPlayer).FProductionControls.Remove(FProduction);
    inherited SetPlayer(Player);
    if GetActiveAction = caMigrate then
    begin
      FProduction.ExecuteCancelProduction;
      FProduction.FQueue.GetItem(0).Free;
    end;
    ValidateAICityAction;
    UpdateAIMigration;
    if FPlayer <> -1 then WorldMap^.FPlayers.GetPlayers(FPlayer).FProductionControls.Add(FProduction);
  end;
end;

procedure TCity.SetupRazeDefenderAG(Armies, Units: TUnitList);
var Group: TAIGroup;
begin
  if WorldMap^.Random(8) = 0 then
  begin
    Group := WorldMap^.FAIGroupManager.CreateGroup(0, UnitsToIndependentRelation(Units, 5), gbRefuge);
    Group.AddUnits(Units);
    Group.Release;
  end
  else inherited SetupRazeDefenderAG(Armies, Units);
end;

function TCity.GetDefensePriority: TDefensePriority;
begin
  if FMode * [cmWarmode, cmRazed] = [] then
  begin
    if GetSize = 1 then Result := dpLow else Result := dpAverage;
    if (FProduction.FStatus = pcsProducing) and (Result = dpLow) then Result := dpAverage;
    if (FPlayer <> 0) and
      (WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer) in [sHostile, sWary]) then Result := dpHigh;
  end else Result := dpNone;
end;

function TCity.GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean;
var
  Info: TBattleFieldInfo;
  Maximum, Minimum: Integer;
  Relation: TStatus;
begin
  if FMode * [cmWarmode, cmRazed] = [] then
  begin
    SetupBattleFieldInfo(Info, Player, 0, [], dtAll - [dtWall]);
    Info.Requests := Info.Requests + [bfrIgnorePassiveIndependents];
    WorldMap^.RetrieveBattleFieldInfo(GetXhx, GetYhx, GetLhx, 10, Info);
    Requirements.Strength := Info.Strength;
    Maximum := Round(GetSize * 5000);
    Minimum := Round(GetSize * 5000 * WorldMap^.FPlayers.GetPlayers(Player).FAIControl.FDefenseStrengthMultiplier);
    if Player <> 0 then Relation := WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(Player)
    else Relation := sFriendly;
    { Original condition makes this neutral-player adjustment unreachable. }
    if (Relation in [sHostile, sWary, sNeutral]) and (Player = FPlayer) and (FPlayer = 0) then
    begin
      Maximum := Round(Maximum) + 7500;
      Minimum := Maximum;
    end;
    if Requirements.Strength < Minimum then Requirements.Strength := Minimum;
    if Maximum < Requirements.Strength then Requirements.Strength := Maximum;
    Result := True;
  end else Result := False;
end;

procedure TCity.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
var Amount, Priority: Integer;
begin
  if not (cmRazed in FMode) then
    case Info.Mode of
      tmAttack, tmRaid:
        if Info.Player <> FPlayer then
        begin
          Priority := Data.Priority;
          if FPlayer > 0 then
          begin
            if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, FRace) then
              Priority := 100 + (GetSize - 1) * 10;
          end
          else if FPlayer = 0 then
          begin
            if WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(Info.Player) in [sPolite, sFriendly] then
            begin
              Amount := JoinAmount(Info.Player);
              if Amount <> -1 then
              begin
                Data.Cost := Amount;
                Priority := 100 + (GetSize - 1) * 10;
                Data.TargetType := attNegotiate;
              end
              else Priority := 100 + (GetSize - 1) * 10;
            end
            else Priority := 100 + (GetSize - 1) * 10;
          end
          else if (cmWarmode in FMode) and (Priority <> 0) then
            Priority := 100 + (GetSize - 1) * 10;
          if Priority > Data.Priority then Data.Priority := Priority;
        end;
      tmProduce:
        if Info.Player = FPlayer then Data.Priority := Data.Priority or 2;
      tmFortify:
        if (Info.Player = FPlayer) and
          (WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(Info.Player) in [sPolite, sFriendly]) and
          (GetActiveAction <> caMigrate) then
        begin
          Data.Priority := 500 + GetSize * 100 + FWallType * 45;
          if ceiAntiMagicShell in FEnchantments then Inc(Data.Priority, 150);
          if GetLhx <> 0 then Inc(Data.Priority, 50);
        end;
      tmDefend:
        if Info.Player = FPlayer then Data.Priority := 50 + GetSize * 20;
    end;
end;

procedure TCity.CropTrampled(Player: Shortint);
var Race: Integer;
begin
  if (Player <> FPlayer) and (Player <> 0) then
  begin
    if FPlayer > 0 then Race := WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerRace else Race := FRace;
    WorldMap^.FRaces.GetRace(Race).SetPlayerRelationValue(Player,
      WorldMap^.FRaces.GetRace(Race).GetPlayerRelationValue(Player) + (-5));
  end;
end;

function TCity.MoveArmiesOutOfCity(Selection: TMoveOutOfCitySelection): Boolean;
var
  MapLevel: TMapLevel;
  Army: TArmyHS;
  Count: Integer;
  Walk: THNWalkData;
begin
  Result := True;
  Count := GetTerrainCount;
  MapLevel := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < Count) and Result do
  begin
    if (FResource.TerrainList.GetTerrain(Walk.HN) >= 0) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      Army := TArmyHS(MapLevel.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if (Army <> nil) and (not (msSkipOwnPlayer in Selection) or (Army.FArmy.FPlayer <> FPlayer)) then
        Result := Army.PlaceEx(Walk.X, Walk.Y, GetLhx, [apSafe, apScanArea]);
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TCity.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    inherited MakeVisible(VisibilityList);
    if [ceiGoldRush, ceiAntiMagicShell, ceiWarmonger] * FEnchantments <> [] then
      FOverlay.MakeVisible(VisibilityList);
  end;
end;

function TCity.GetSize: Integer;
begin Result := TCityResource(FResource).FSize; end;

function TCity.GetObtainUnitsValue: Integer;
var
  Count: Integer;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
  Army: TArmyHS;
begin
  with Walk do
  begin
    Result := 0;
    Count := GetTerrainCount;
    MapLevel := TMapLevel(Owner.Owner);
    InitHNWalk(Walk, GetXhx, GetYhx, 0);
    while HN < Count do
    begin
      if (FResource.TerrainList.GetTerrain(HN) >= 0) and (X >= 0) and (Y >= 0) and
        (X < MapLevel.Width) and (Y < MapLevel.Height) then
      begin
        Army := TArmyHS(MapLevel.GetField(X, Y).FindOwnedChild($20217));
        if Army <> nil then Inc(Result, Army.FArmy.ObtainValue($FF));
      end;
      WalkToNextHN(Walk);
    end;
  end;
end;

function TCity.UpdatePlayer: Boolean;
var
  MultiplePlayers: Boolean;
  MapLevel: TMapLevel;
  Count: Integer;
  Walk: THNWalkData;
  Army: TArmyHS;
  Player: Shortint;
begin
  if not ((cmRazed in FMode) and not GetBuilding) then
  begin
  MultiplePlayers := False;
  Player := -1;
  Count := GetTerrainCount;
  MapLevel := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < Count) and not MultiplePlayers do
  begin
    if (FResource.TerrainList.GetTerrain(Walk.HN) >= 0) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      Army := TArmyHS(MapLevel.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if Army <> nil then
        if Player = -1 then Player := Army.FArmy.FPlayer
        else MultiplePlayers := Army.FArmy.FPlayer <> Player;
    end;
    WalkToNextHN(Walk);
  end;
  if MultiplePlayers then
  begin
    if not (cmWarmode in FMode) then
    begin
      FMode := FMode + [cmWarmode];
      SetPlayer(-1);
      UpdateFlagID;
      Update;
    end;
  end
  else if cmWarmode in FMode then
  begin
    FMode := FMode - [cmWarmode];
    if Player <> -1 then SetPlayer(Player) else SetPlayer(0);
    UpdateFlagID;
    Update;
  end
  else if Player <> -1 then SetPlayer(Player);
  end;
  Result := True;
end;

procedure TCity.ArmyPlaced(A1: TArmyHS);
begin
  inherited ArmyPlaced(A1);
  if ceiFountainOfLife in FEnchantments then ExecuteFountainOfLife;
  if ceiAntiMagicShell in FEnchantments then FOverlay.PlayFadeShellAnimation;
end;

procedure TCity.ArmyRemoved(Army: TArmyHS);
begin
  inherited ArmyRemoved(Army);
  UpdatePlayer;
end;

function TCity.UpgradeCost: Integer;
begin Result := UpgradePrices[GetSize]; end;

function TCity.UpgradeTime: Integer;
begin
  Result := 3;
end;

function TCity.CanUpgrade(Queue: Boolean; var Reason: string): Boolean;
var Level, I: Integer;
begin
  Level := FUpgradeLevel;
  if Queue then
    for I := 0 to FProduction.FQueue.Count - 1 do
      if FProduction.FQueue.GetItem(I).FProductionID = CityActionToProductionID(caUpgrade) then Inc(Level);
  if Level < GetSize then Result := True
  else
  begin
    Result := False;
    Reason := TranslateRStr(LoadResString(MaxUpgradeText));
  end;
end;

function TCity.Upgrade(Queue: Boolean): Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanUpgrade(Queue, Reason) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := CityActionToProductionID(caUpgrade);
    FProduction.Produce(Item, Queue);
    Item.Free;
    Result := True;
  end else Result := False;
end;

function TCity.FortifyCost: Integer;
begin
  case FWallType of
    0: Result := WoodWallPrices[GetSize];
    1: Result := StoneWallPrices[GetSize];
  else Result := -1;
  end;
end;

function TCity.FortifyTime: Integer;
begin
  Result := 2;
end;

function TCity.CanFortify(Queue: Boolean; var Reason: string): Boolean;
var Level, I: Integer;
begin
  Level := FWallType;
  if Queue then
    for I := 0 to FProduction.FQueue.Count - 1 do
      if FProduction.FQueue.GetItem(I).FProductionID = CityActionToProductionID(caFortify) then Inc(Level);
  if Level <> 2 then Result := True
  else
  begin
    Result := False;
    Reason := TranslateRStr(LoadResString(MaxFortifyText));
  end;
end;

function TCity.Fortify(Queue: Boolean): Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanFortify(Queue, Reason) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := CityActionToProductionID(caFortify);
    FProduction.Produce(Item, Queue);
    Item.Free;
    Result := True;
  end else Result := False;
end;

function TCity.ProductionCost(Index: Integer): Integer;
begin
  Result := FProduction.UnitProductionGold(Index);
end;

function TCity.ProductionTime(Index: Integer): Integer;
begin
  Result := FProduction.UnitProductionTime(Index);
end;

function TCity.CanProduce(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin
  Result := FProduction.CanProduceUnit(Index, Queue, Reason);
end;

function TCity.Produce(Index: Integer; Queue: Boolean): Boolean;
begin
  Result := FProduction.ProduceUnit(Index, Queue);
end;

function TCity.ResearchCost(Index: Integer): Integer;
begin
  Result := FProduction.UnitResearchGold(Index);
end;

function TCity.ResearchTime(Index: Integer): Integer;
begin
  Result := FProduction.UnitResearchTime(Index);
end;

function TCity.CanResearch(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin
  Result := FProduction.CanResearchUnit(Index, Queue, Reason);
end;

function TCity.Research(Index: Integer; Queue: Boolean): Boolean;
begin
  Result := FProduction.ResearchUnit(Index, Queue);
end;

function TCity.CanTrade(Queue: Boolean; var Reason: string): Boolean;
begin
  Result := True;
end;

function TCity.Trade(Queue: Boolean): Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanTrade(Queue, Reason) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := CityActionToProductionID(caTrade);
    if Queue then Item.FParameter := 1 else Item.FParameter := -1;
    FProduction.Produce(Item, Queue);
    Item.Free;
    Result := True;
  end else Result := False;
end;

function TCity.LootTime: Integer;
begin
  Result := GetSize;
end;

function TCity.CanLoot(var Reason: string): Boolean;
begin Result := not (cmRazed in FMode); end;

function TCity.Loot: Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanLoot(Reason) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := CityActionToProductionID(caLoot);
    FProduction.Produce(Item, False);
    Item.Free;
    Result := True;
  end else Result := False;
end;

function TCity.MigrationTime(Race: Shortint): Integer;
var
  Reason: string;
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  Radius: Integer;
  City: TCity;
begin
  if CanMigrate(Race, Reason) then
    if Race <> FRace then
    begin
      Radius := -1;
      MapLevel := TMapLevel(Owner.Owner);
      InitHNWalk(Walk, FXhx, FYhx, 1);
      while (Walk.Radius <= 20) and (Radius = -1) do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and
          (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
        begin
          City := TCity(MapLevel.GetField(Walk.X, Walk.Y).FindNoneTransparentHS(TCity));
          if (City <> nil) and (City.FRace = Race) then Radius := Walk.Radius;
        end;
        WalkToNextHN(Walk);
      end;
      if Radius <> -1 then Result := Radius div 10 + 3 else Result := 5;
    end
    else Result := 0
  else Result := -1;
end;

function TCity.CanMigrate(Race: Shortint; var Reason: string): Boolean;
var I: Integer; Player: Shortint;
begin
  if FRace <> Race then
  begin
    Result := RaceInCity(Race, FPlayer);
    I := WorldMap^.FPlayers.Count;
    while (I <> 1) and not Result do
    begin
      Dec(I);
      Player := I;
      Result := (WorldMap^.FPlayers.GetDiplomaticRelation(Player, FPlayer) = drAlliance) and
        RaceInCity(Race, Player);
    end;
  end else Result := False;
end;

function TCity.Migrate(Race: Shortint): Boolean;
var
  Item: TProductionItem;
  Reason: string;
begin
  if CanMigrate(Race, Reason) and not WorldMap^.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    Item := TProductionItem.Create(nil);
    Item.FProductionID := CityActionToProductionID(caMigrate);
    Item.FParameter := Race;
    FProduction.Produce(Item, False);
    Item.Free;
    Result := True;
  end else Result := False;
end;

function TCity.CreateMigrationItem(Race: Shortint): TMigrationItem;
var Reason: string;
begin
  if CanMigrate(Race, Reason) then
  begin
    Result := TMigrationItem.Create(nil);
    Result.FRace := Race;
    Result.FTime := MigrationTime(Race);
    Result.FRelation := WorldMap^.FRaces.GetRace(Race).GetPlayerRelation(FPlayer);
  end else Result := nil;
end;

function TCity.CreateMigrationSelection: TMigrationList;
var
  I: Integer;
  Item: TMigrationItem;
begin
  Result := TMigrationList.Create(nil);
  for I := 0 to WorldMap^.FRaces.Count - 1 do
    if WorldMap^.FRaces.GetRace(I).FEnabled then
    begin
      Item := CreateMigrationItem(I);
      if (Item <> nil) and (Item.FRelation in [sNeutral, sPolite, sFriendly]) then Item.Owner := Result
      else Item.Free;
    end;
end;

function TCity.GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean;
begin
  GenerateRebelUnits(Units);
  Result := True;
end;

function TCity.ExecuteRaze(Player: Shortint): Boolean;
begin
  Result := inherited ExecuteRaze(Player);
  if Result then
    WorldMap^.FRaces.GetRace(FRace).SetPlayerRelationValue(Player,
      WorldMap^.FRaces.GetRace(FRace).GetPlayerRelationValue(Player) + (-30));
end;

function TCity.GetRazed: Boolean;
begin
  Result := cmRazed in FMode;
end;

procedure TCity.SetRazed(Value: Boolean);
begin
  if Value <> GetRazed then
  begin
    FProduction.ExecuteDeleteProductions;
    if Value then SetPlayer(-1);
    if Value then FMode := FMode + [cmRazed] else FMode := FMode - [cmRazed];
    ImageIndex := GetTerrainTypeImage(TerrainType);
    ResetEnchantments;
    UpdateImages;
    UpdateCrops;
    Update;
    SetWallType(0);
  end;
end;

procedure TCity.GetRebuildInfo(var Cost, Time: Integer);
begin
  Cost := GetSize * 25;
  Time := GetSize + 1;
end;

procedure TCity.CheckRebellion;
var
  Chance, I: Integer;
  Log: TCityRebellionEventLog;
  Units: TUnitList;
begin
  if FPlayer <> 0 then
  begin
    Chance := Ord(GetCivilStatus);
    if (TCivilStatus(Chance) in [csUnruly, csUnrest]) and not GetRazed then
    begin
      if TCivilStatus(Chance) = csUnruly then Chance := 50 else Chance := 10;
      if Chance >= WorldMap^.Random(100) then
      begin
        MoveArmiesOutOfCity([]);
        Log := TCityRebellionEventLog.Create(nil);
        Log.FPlayer := FPlayer;
        Log.FCityName := GetName;
        Log.FXhx := GetXhx;
        Log.FYhx := GetYhx;
        Log.FLhx := GetLhx;
        DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, False);
        Log.Release;
        SetPlayer(0);
        Units := TUnitList.Create(nil);
        GenerateRebelUnits(Units);
        for I := Units.Count - 1 downto 0 do
          Units.GetUnit(I).Place(GetXhx, GetYhx, GetLhx, 0, []);
        Units.Free;
        FProduction.ExecuteDeleteProductions;
      end;
    end;
  end;
end;

procedure TCity.GenerateDefenders;
var
  Value, I: Integer;
  Armies: TArmyHSList;
begin
  if not GetRazed and (FDefendersMode <> dgNone) and not (cmWarmode in FMode) and (FPlayer = 0) then
  begin
    Armies := TArmyHSList.Create(nil);
    ListArmies(Armies);
    if FDefendersMode = dgRandom then FDefendersMode := TDefendersGenerateMode(System.Random(3) + 2);
    Value := (Ord(FDefendersMode) - 2) * 25 + 25;
    Inc(Value, (GetSize - 1) * Value div 2);
    for I := 0 to Armies.Count - 1 do Dec(Value, Armies.GetArmyHS(I).FArmy.ObtainValue($FF));
    if Value > 0 then
    begin
      RandomSeed^ := WorldMap^.Random($FFFFF);
      PlaceRandomUnits(GetXhx, GetYhx, GetLhx, 0,
        WorldSet^.FRaceResources.GetRaceResource(FRace).FUnitIndexes,
        FUpgradeLevel, Value, [utHumanoid, utCreature]);
    end;
    Armies.Free;
  end;
end;

procedure TCity.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  if not (cmWarmode in FMode) then FProduction.NewTurn(Player);
  if Player = FPlayer then
    if WorldMap^.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then UpdateAIMigration;
end;

procedure TCity.NewDay;
var I: Integer;
begin
  inherited NewDay;
  if FRace < 0 then
    if (FRace < -1) and (WorldMap^.FGameType = gtCampaign) then
    begin
      I := Shortint(Abs(FRace)) - 3;
      if (I >= 0) and (I < WorldEngine^.FCampaign.FRaceHistory.Count) then
        SetRace(WorldEngine^.FCampaign.FRaceHistory[I])
      else SetRace(WorldMap^.FRaces.GetRandomRace);
    end
    else SetRace(WorldMap^.FRaces.GetRandomRace);
  if WorldMap^.FDay = 1 then
  begin
    FProduction.FUnitProductions.Clear;
    SetUpgradeLevel(FUpgradeLevel);
    GenerateDefenders;
    if FWallType = 3 then
    begin
      FWallType := WorldMap^.Random(3);
      UpdateImages;
    end;
  end;
  CheckRebellion;
  if FOverlay.FMode = omShowRazeAnimation then FOverlay.SetMode(omIdle);
end;

procedure TCity.UpdateCrops;
var Count: Integer;
begin
  if not GetEditMode then
  begin
    if GetRazed then Count := 0
    else if msEditting in WorldMap^.Status then Count := TCityResource(FResource).FCropLocations.Count
    else Count := -1;
    if Count <> -1 then SetCropCount(Count);
    UpdateCropSettings;
    UpdateIncome;
  end;
end;

procedure TCity.ListIncomeInfo(Names, Values: TStrings);
var Income: Integer;
begin
  Income := GetSize * 5;
  Names.Add(TranslateRStr(LoadResString(BaseIncomeText)));
  Values.Add(IntToStr(Income));
  Inc(Income, GetCropCount * 2);
  Names.Add(SysUtils.Format(TranslateRStr(LoadResString(XCropFieldsText)), [IntToStr(GetCropCount)]));
  Values.Add(IntToStr(GetCropCount * 2));
  if GetActiveAction in [caNone, caTrade] then
  begin
    Names.Add(TranslateRStr(LoadResString(ProducingMerchandiseText)));
    Values.Add(IntToStr(Round(Income * 0.25)));
    Inc(Income, Round(Income * 0.25));
  end;
  if ceiGoldRush in FEnchantments then
  begin
    Names.Add(TranslateRStr(LoadResString(GoldRushText)));
    Values.Add(IntToStr(Income));
  end;
end;

procedure TCity.UpdateIncome;
begin
  if not GetRazed and (GetActiveAction <> caMigrate) and not GetBuilding then
  begin
    SetIncome(GetCropCount * 2 + GetSize * 5);
    if GetActiveAction in [caNone, caTrade] then SetIncome(FIncome + Round(FIncome * 0.25));
    if ceiGoldRush in FEnchantments then SetIncome(FIncome * 2);
  end else SetIncome(0);
end;

function TCity.GetValidTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: Shortint): Shortint;
begin
  Result := GetMostFrequentMapFieldTerrainType(MapLevel, Xhx, Yhx, -1);
end;

function TCity.VisibilityRange: Integer;
begin
  Result := 6;
  if (GetLhx <> 0) or ((FPlayer > 0) and
    (Byte(WorldMap^.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments) and 8 <> 0)) then
    Result := (Result + 1) shr 1;
end;

procedure TCity.SetDefaultProductions;
begin
  FProduction.FUnitProductions.Clear;
  if FRace >= 0 then SetUpgradeLevel(FUpgradeLevel);
end;

procedure TCity.GenerateRebelUnits(Units: TUnitList);
var SavedSeed: Integer;
begin
  SavedSeed := RandomSeed^;
  RandomSeed^ := GetXhx * 10 + WorldMap^.FInitialRandomSeed + GetYhx;
  FillWithRandomUnits(WorldSet^.FRaceResources.GetRaceResource(FRace).FUnitIndexes,
    Units, 2, GetSize * 25, [utHumanoid, utCreature]);
  RandomSeed^ := SavedSeed;
end;

procedure TCity.ListCivilStatusInfo(List: TStrings);
var
  Predictor: TCombatPredictor;
  Armies: TArmyHSList;
  Units: TUnitList;
  I, J: Integer;
  U: TAbstractUnit;
begin
  if (FPlayer <> 0) and (FRace >= 0) then
  begin
    List.Add(SysUtils.Format(TranslateRStr(LoadResString(RaceRelationXText)),
      [TranslateRStr(StatusNames^[WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer)])]));
    if TerrainType in RaceTerrainTable^[FRace].Penalty then
      List.Add(SysUtils.Format(TranslateRStr(LoadResString(TerrainPenaltyXText)), [WorldSet^.TerrainTypes[TerrainType]]));
    if TerrainType in RaceTerrainTable^[FRace].Bonus then
      List.Add(SysUtils.Format(TranslateRStr(LoadResString(TerrainBonusXText)), [WorldSet^.TerrainTypes[TerrainType]]));
    Predictor := TCombatPredictor.Create;
    Armies := TArmyHSList.Create(nil);
    ListArmies(Armies);
    for I := 0 to Armies.Count - 1 do
      for J := 0 to Armies.GetArmyHS(I).FArmy.Count - 1 do
      begin
        U := Armies.GetArmyHS(I).FArmy.GetUnit(J);
        if U.FMoraleValue <= 40 then Predictor.AddOpponent(U, 0)
        else Predictor.AddUnit(U);
      end;
    Units := TUnitList.Create(nil);
    GenerateRebelUnits(Units);
    for J := 0 to Units.Count - 1 do Predictor.AddOpponent(Units.GetUnit(J), 0);
    if Predictor.Execute = crVictory then
    begin
      if Predictor.GetSuperiority div 4 >= 75 then
        List.Add(SysUtils.Format(TranslateRStr(LoadResString(OccupationForcesXText)),
          [TranslateRStr(LoadResString(StrongText))]))
      else List.Add(SysUtils.Format(TranslateRStr(LoadResString(OccupationForcesXText)),
          [TranslateRStr(LoadResString(AverageText))]));
    end
    else List.Add(SysUtils.Format(TranslateRStr(LoadResString(OccupationForcesXText)),
        [TranslateRStr(LoadResString(WeakText))]));
    Predictor.Free;
    Units.Free;
    Armies.Free;
  end;
end;

function TCity.GetCivilStatus: TCivilStatus;
var
  Relation: TStatus;
  Value, ArmyValue, Bonus, I, J: Integer;
  Predictor: TCombatPredictor;
  Armies: TArmyHSList;
  Units: TUnitList;
  U: TAbstractUnit;
begin
  if (FPlayer <> 0) and not (cmWarmode in FMode) then
  begin
    if cmAnarchy in FMode then Relation := sHostile
    else Relation := WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer);
    case Relation of
      sHostile: Value := -35;
      sWary: Value := -25;
      sNeutral: Value := 0;
      sPolite: Value := 15;
      sFriendly: Value := 25;
    else Value := 0;
    end;
    Value := Value + FWallType * 5 + FUpgradeLevel * 5;
    if FRace >= 0 then
    begin
      if TerrainType in RaceTerrainTable^[FRace].Penalty then Inc(Value, -10);
      if TerrainType in RaceTerrainTable^[FRace].Bonus then Inc(Value, 10);
      Predictor := TCombatPredictor.Create;
      ArmyValue := 0;
      Armies := TArmyHSList.Create(nil);
      ListArmies(Armies);
      for I := 0 to Armies.Count - 1 do
        for J := 0 to Armies.GetArmyHS(I).FArmy.Count - 1 do
        begin
          U := Armies.GetArmyHS(I).FArmy.GetUnit(J);
          if U.FMoraleValue <= 40 then
          begin
            Predictor.AddOpponent(U, 0);
            { Original anarchy counts disloyal defenders twice. }
            if cmAnarchy in FMode then Predictor.AddOpponent(U, 0);
          end
          else
          begin
            Inc(ArmyValue, U.GetObtainValue);
            Predictor.AddUnit(U);
          end;
        end;
      Armies.Free;
      if Relation in [sHostile, sWary] then
      begin
        Units := TUnitList.Create(nil);
        GenerateRebelUnits(Units);
        for I := 0 to Units.Count - 1 do
        begin
          Predictor.AddOpponent(Units.GetUnit(I), 0);
          if cmAnarchy in FMode then Predictor.AddOpponent(Units.GetUnit(I), 0);
        end;
        if Predictor.Execute = crVictory then
        begin
          Bonus := Predictor.GetSuperiority div 4;
          if Bonus >= 75 then Bonus := 75
          else if Bonus >= 26 then Bonus := 50
          else Bonus := 25;
        end else Bonus := 0;
        Inc(Value, Bonus);
        Units.Free;
      end
      else if Relation in [sPolite, sFriendly] then
      begin
        ArmyValue := ArmyValue div (GetSize * 10);
        if ArmyValue > 10 then ArmyValue := 10;
        Inc(Value, ArmyValue);
      end;
      Predictor.Free;
      if Value < -30 then Result := csUnruly
      else if Value < -10 then Result := csUnrest
      else if Value < 10 then Result := csStable
      else if Value < 30 then
        if Relation in [sHostile, sWary] then Result := csOppressed else Result := csContent
      else if Relation in [sHostile, sWary] then Result := csSlavery else Result := csCheerful;
    end else Result := csStable;
  end else Result := csStable;
end;

procedure TCity.UpdateImages;
var
  Terrain, Offset, Size, Index: Integer;
  Images: TCustomImageLibrary;
  RaceResource: TRaceResource;
begin
  Terrain := TMapField(Owner).TerrainType;
  if Terrain = 3 then Offset := 20
  else if Terrain in [5, 7..9, 12..13] then Offset := 40
  else Offset := 0;
  Images := FResource.ImageSequenceList.ImageSequences[0].ImageLibrary;
  if GetRazed then
  begin
    FCityImage := nil;
    FWallBackImage := nil;
    FWallFrontImage := nil;
  end
  else
  begin
    if FRace >= 0 then
    begin
      RaceResource := WorldSet^.FRaceResources.GetRaceResource(FRace);
      Size := TCityResource(FResource).FSize;
      if RaceResource <> nil then
        FCityImage := RaceResource.GetCityImage(Size, Terrain, TMapField(Owner).Lhx);
      if FCityImage = nil then
        if Images.ImageExist(Offset) then FCityImage := Images[Offset] else FCityImage := Images[0];
    end
    else
    begin
      Index := Offset + 1;
      if Images.ImageExist(Index) then FCityImage := Images[Index] else FCityImage := Images[1];
    end;
    if (FWallType <> 0) and (FWallType <> 3) then
    begin
      Index := FWallType * 2 + Offset;
      if Images.ImageExist(Index) then
      begin
        FWallFrontImage := Images[Index];
        FWallBackImage := Images[Index + 1];
      end
      else
      begin
        FWallFrontImage := Images[FWallType * 2];
        FWallBackImage := Images[FWallType * 2 + 1];
      end;
    end
    else
    begin
      FWallBackImage := nil;
      FWallFrontImage := nil;
    end;
  end;
  UpdateFlagID;
end;

var
  SortingCity: TCity;

function CompareCityProductions(Item1, Item2: Pointer): Integer;
var Value1, Value2: Integer;
begin
  with TUnitProduction(Item1) do
  begin
  if WorldSet^.FUnitResources.GetUnitResource(FUnitIndex) <> nil then
  begin
    Value1 := WorldSet^.FUnitResources.GetUnitResource(FUnitIndex).FLevel * 2;
    if SortingCity.FRace <> -1 then
      if WorldSet^.FRaceResources.GetRaceResource(SortingCity.FRace).FSpecialUnitIndexes.Count > 3 then
        if WorldSet^.FRaceResources.GetRaceResource(SortingCity.FRace).FSpecialUnitIndexes[3] =
          FUnitIndex then Inc(Value1);
  end else Value1 := 0;
  end;
  with TUnitProduction(Item2) do
  begin
  if WorldSet^.FUnitResources.GetUnitResource(FUnitIndex) <> nil then
  begin
    Value2 := WorldSet^.FUnitResources.GetUnitResource(FUnitIndex).FLevel * 2;
    if SortingCity.FRace <> -1 then
      if WorldSet^.FRaceResources.GetRaceResource(SortingCity.FRace).FSpecialUnitIndexes.Count > 3 then
        if WorldSet^.FRaceResources.GetRaceResource(SortingCity.FRace).FSpecialUnitIndexes[3] =
          FUnitIndex then Inc(Value2);
  end else Value2 := 0;
  end;
  Result := Value1 - Value2;
  if Result = 0 then Result := TUnitProduction(Item1).FUnitIndex - TUnitProduction(Item2).FUnitIndex;
end;

procedure TCity.SetUpgradeLevel(Level: Byte);
var
  RaceResource: TRaceResource;
  I, UnitLevel: Integer;
  Researched: Boolean;
begin
  if Level > GetSize then Level := GetSize;
  if Level < 1 then Level := 1;
  FUpgradeLevel := Level;
  if FRace >= 0 then
  begin
    RaceResource := WorldSet^.FRaceResources.GetRaceResource(FRace);
    for I := RaceResource.FUnitIndexes.Count - 1 downto 0 do
      if RaceResource.FUnitIndexes[I] <> -1 then
        if FProduction.FUnitProductions.IndexOf(RaceResource.FUnitIndexes[I]) = -1 then
        begin
          UnitLevel := UnitLevelToCityLevel(
            WorldSet^.FUnitResources.GetUnitResource(RaceResource.FUnitIndexes[I]).FLevel, GetSize);
          if (UnitLevel <> -1) and (UnitLevel <= FUpgradeLevel) then
          begin
            Researched := (UnitLevel = 1) and not
              ((RaceResource.FSpecialUnitIndexes.Count >= 4) and
                (RaceResource.FUnitIndexes[I] = RaceResource.FSpecialUnitIndexes[3]));
            FProduction.FUnitProductions.Add(RaceResource.FUnitIndexes[I], Researched);
          end;
        end;
    SortingCity := Self;
    FProduction.FUnitProductions.FChildren.Sort(CompareCityProductions);
  end;
end;

procedure TCity.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  UpdateImages;
end;

procedure TCity.UpdateFlagID;
begin
  if not (moEditMode in FStatus) and (not (cmRazed in FMode) or GetBuilding) and not (cmWarmode in FMode) then
    if FPlayer > 0 then
      FFlagID := WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerRace + (FUpgradeLevel - 1) * 64
    else FFlagID := 32 + (FUpgradeLevel - 1) * 64
  else FFlagID := 63;
end;

function TCity.GetName: string;
begin
  Result := FName;
end;

procedure TCity.SetName(Name: string);
begin
  FName := Name;
  Update;
end;

procedure TCity.SetWallType(WallType: Byte);
begin
  FWallType := WallType;
  UpdateImages;
end;

procedure TCity.SetRace(Race: Shortint);
begin
  if Shortint(Race) <> FRace then
  begin
    FRace := Race;
    if FRace >= 0 then SetDefaultProductions;
    UpdateCrops;
    UpdateImages;
  end;
end;

function TCity.GetRace: Shortint;
begin
  Result := FRace;
end;

procedure TCity.Activate;
begin
  RegisterEnchantments;
  inherited Activate;
  UpdateVisibleForSeatedPlayer;
  FProduction.Activate;
  if FPlayer <> -1 then WorldMap^.FPlayers.GetPlayers(FPlayer).FProductionControls.Add(FProduction);
  if (msEditting in WorldMap^.Status) and (WorldMap^.FDay = 0) then SetUpgradeLevel(FUpgradeLevel);
  UpdateImages;
end;

procedure TCity.Deactivate;
begin
  UnregisterEnchantments;
  if FPlayer <> -1 then WorldMap^.FPlayers.GetPlayers(FPlayer).FProductionControls.Remove(FProduction);
  FProduction.Deactivate;
  inherited Deactivate;
end;

procedure TCity.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var X, Y: Integer;
begin
  HXtoHP(FXhx, FYhx, X, Y);
  XhpSurf := X - XhpSurf;
  YhpSurf := Y - YhpSurf;
  if not (cmRazed in FMode) or GetBuilding then
    if ((msEditting in WorldMap^.Status) or not FFogged or (not WorldMap^.FFogEnabled)) and
      (FFlagID <> 63) and (TCityResource(FResource).FClaimed or (FFlagID and $20 = 0)) then
      with TCityResource(FResource) do
        if FFlagType <= 1 then
          WorldSet^.FFlagControl.ShowFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
            Engine.HSMap.Frame + X, Self.FFlagID, SurfaceDesc)
        else WorldSet^.FFlagControl.ShowStructureFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
            Engine.HSMap.Frame + X, Self.FFlagID, SurfaceDesc);
  if cmTownQuake in FMode then
  begin
    XhpSurf := XhpSurf + System.Random(5) - 2;
    YhpSurf := YhpSurf + System.Random(5) - 2;
  end;
  if not (cmRazed in FMode) then
    TCityResource(FResource).ShowCity(XhpSurf, YhpSurf, SurfaceDesc, Self)
  else TCityResource(FResource).Show(XhpSurf, YhpSurf, SurfaceDesc, Self);
end;

procedure TCity.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 12);
  Stream.rwByte(Byte(FRace), 13);
  Stream.rwData(FWallType, 1, 15);
  Stream.rwByte(FUpgradeLevel, 16);
  Stream.rwEObject(FProduction, 18);
  Stream.rwData(FMode, 1, 22);
  Stream.rwData(FDefendersMode, 1, 27);
  Stream.rwEObject(FEnchantmentList, 29);
end;

function TCity.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then UpdateMapFields(TMapLevel(Owner.Owner), FXhx, FYhx);
end;

procedure TCity.RemoveFromMap;
var MapLevel: TMapLevel;
begin
  MapLevel := TMapLevel(Owner.Owner);
  inherited RemoveFromMap;
  UpdateMapFields(MapLevel, FXhx, FYhx);
end;

procedure TCity.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  inherited UpdateMapField(Info);
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $4000000;
end;

procedure TCity.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    if FRace >= 0 then
      if (WorldMap^.FRaces.GetRace(FRace) = nil) or not WorldMap^.FRaces.GetRace(FRace).FEnabled then
      begin
        FRace := -1;
        UpdateImages;
      end;
  end
  else if Msg.MsgID = $20020009 then UpdateVisibleForSeatedPlayer;
end;

procedure TCity.InitCombat(Combat: TCombat; Army: TArmyHS);
begin
  if FPlayer = 0 then
    with Combat.FCombatData do
      FPlayers.GetPlayers(FDefenderPlayer).FIndependentRelation := GetEnemiesIndependentRelation(Army.FArmy.FPlayer);
  Combat.InitDefaultArmies(Army.FArmy, Army.GetXhx, Army.GetYhx, Army.GetLhx);
end;

function TCity.GetCombatEventText(Combat: TCombat): string;
begin
  if not GetRazed then
    if (Combat.FCombatResult = crVictory) or (Combat.FCombatResult = crNoDefenders) then
      Result := SysUtils.Format(TranslateRStr(LoadResString(CityBattleWonText)), [GetName])
    else if Combat.FCombatResult = crDefeat then
      Result := SysUtils.Format(TranslateRStr(LoadResString(CityBattleLostText)), [GetName])
    else if Combat.FCombatResult <> crCannotBreachWall then
      Result := SysUtils.Format(TranslateRStr(LoadResString(CityBattleDrawnText)), [GetName]);
end;

procedure TCity.FinalizeCombat(Combat: TCombat);
begin
  if (Combat.FCombatResult = crVictory) or (Combat.FCombatResult = crNoDefenders) then
  begin
    with Combat.FCombatData do SetPlayer(FPlayers.GetPlayers(FAttackerPlayer).FPlayer);
    UpdatePlayer;
  end;
end;

function TCity.GetObtainValue: Integer;
begin
  Result := UpgradePrices[GetSize] * FUpgradeLevel;
  if FWallType = 1 then Inc(Result, WoodWallPrices[GetSize]);
  if FWallType = 2 then Result := Result + WoodWallPrices[GetSize] + StoneWallPrices[GetSize];
end;

function TCity.JoinAmount(Player: Shortint): Integer;
const JoinPercent: array[TStatus] of Integer = (200, 175, 150, 125, 100);
var Armies: TArmyHSList; I: Integer; Army: TArmy; CanJoin: Boolean; Value: Integer;
begin
  Result := 0;
  Armies := TArmyHSList.Create(nil);
  ListArmies(Armies);
  I := Armies.Count;
  CanJoin := True;
  if I <> 0 then
  begin
    while (I <> 0) and CanJoin do
    begin
      Dec(I);
      Army := Armies.GetArmyHS(I).FArmy;
      CanJoin := Army.GetCanJoinSelection(Player) = Army.ValidateSelection($FF);
      if CanJoin then Inc(Result, Army.JoinAmount(Player, $FF));
    end;
    if CanJoin then
    begin
      Value := GetObtainValue div 4;
      Inc(Result, JoinPercent[WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(Player)] * Value div 100);
    end
    else Result := -1;
  end
  else if WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(Player) in [sPolite, sFriendly] then Result := 0
  else Result := -1;
  Armies.Free;
end;

function TCity.GetMoveAction(Player: Shortint; Action: TMoveAction): TMoveAction;
begin
  Result := Action;
  if FPlayer = 0 then
  begin
    if (Action in [maNormal, maAttack]) and not GetRazed and not (cmWarmode in FMode) then
      if JoinAmount(Player) <> -1 then Result := maNegotiate else Result := maAttack;
  end
  else if (FPlayer <> Player) and (FPlayer <> -1) then Result := maAttack;
end;

function TCity.IncommingNegotiateRequest(Request: TNegotiateRequestEventLog): Boolean;
var Amount: Integer;
begin
  if (FPlayer = 0) and not (cmWarmode in FMode) then
  begin
    Amount := JoinAmount(Request.FPlayer);
    if Amount <> -1 then
    begin
      Request.FObject := noCity;
      Request.FText := SysUtils.Format(TranslateRStr(CityJoinHeaderRStr), [GetName]);
      Request.FGold := Amount;
      if Request.FGold = 0 then Request.FJoinMessage.Text := TranslateRStr(CityFreeJoinRStr)
      else Request.FJoinMessage.Text := SysUtils.Format(TranslateRStr(CityTributeJoinRStr), [IntToStr(Request.FGold)]);
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

function TCity.IncommingNegotiateOffer(Offer: TNegotiateTE): Boolean;
var Amount, I: Integer; Armies: TArmyHSList; Log: TLocationTextEventLog;
begin
  if Offer.FObject = noCity then
  begin
    Amount := JoinAmount(Offer.FPlayer);
    if (Offer.FOffer = noOfferBribe) and (Amount <= Offer.FGold) and (Amount <> -1) then
    begin
      if WorldMap^.FPlayers.GetPlayers(Offer.FPlayer).FGems >= Offer.FGold then
      begin
        SetPlayer(Offer.FPlayer);
        Armies := TArmyHSList.Create(nil);
        ListArmies(Armies);
        for I := 0 to Armies.Count - 1 do
          if Armies.GetArmyHS(I).FArmy.FPlayer = 0 then Armies.GetArmyHS(I).FArmy.SetPlayer(Offer.FPlayer);
        Armies.Free;
        Log := TLocationTextEventLog.Create(nil);
        Log.FPlayer := FPlayer;
        Log.FText := SysUtils.Format(TranslateRStr(XOverthrownRStr), [GetName]);
        Log.SetLocation(GetXhx, GetYhx, GetLhx);
        DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, False);
        Log.Release;
        Offer.Accept;
      end
      else WorldMap^.ShowMessage(TranslateRStr(NotEnoughGoldRStr));
    end
    else Offer.Reject;
    Result := True;
  end
  else Result := False;
end;

function TCity.GetEnemiesIndependentRelation(Player: Shortint): Shortint;
var Units: TUnitUserList; I: Integer;
begin
  Units := TUnitUserList.Create(nil);
  ListUnits(Units);
  for I := Units.Count - 1 downto 0 do
    if Units.GetUnit(I).CanJoin(Player) then Units.DeleteUnit(Units.GetUnit(I));
  Result := UnitsToIndependentRelation(Units, FRace); { Original uses the race index as the default relation. }
  Units.Free;
end;

function TCity.GetIndependentRelation: Shortint;
var Units: TUnitUserList;
begin
  Units := TUnitUserList.Create(nil);
  ListUnits(Units);
  Result := UnitsToIndependentRelation(Units, FRace); { Original uses the race index as the default relation. }
  Units.Free;
end;

procedure TCity.ReturnBattleFieldInfo(var Info: TBattleFieldInfo);
var Value: Integer; Relation: TDiplomaticRelation;
begin
  if (bfrEffectiveStrength in Info.Requests) and (FPlayer > 0) then
  begin
    Value := 5000;
    if WorldMap^.FRaces.GetRace(FRace).GetPlayerRelation(FPlayer) in [sHostile, sWary] then Value := Value * 2;
    Relation := DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, 0);
    if Ord(Relation) in Info.FriendlyRelations then Dec(Info.FriendlyStrength, Value);
    if Ord(Relation) in Info.EnemyRelations then Dec(Info.Strength, Value);
  end;
end;

procedure TCity.UpdateVisibleForSeatedPlayer;
var Visible: Boolean;
begin
  Visible := VisibleForPlayer(WorldMap^.FSeatedPlayer);
  if FEnchantmentsVisible xor Visible then
  begin
    FEnchantmentsVisible := Visible;
    if FEnchantments <> [] then WorldMap^.FGlobalMagicControl.TriggerChangedEvent;
  end;
end;

procedure TCity.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if not ((Msg.MsgID = $110C) and (FResource.TerrainList.Terrain[Msg.HN] >= 0)) then inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
  begin
    if (Msg.MsgID = $110C) and (Msg.HN = 0) then
    begin
      if ((not WorldMap^.FFogEnabled) or not FFogged) and (FPlayer >= 0) then
      begin
        if FPlayer = 0 then Inc(Msg.Param[0], $D0000)
        else Inc(Msg.Param[0], (WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerRace + 1) * $10000);
      end
      else Inc(Msg.Param[0], $E0000);
      Inc(Msg.Param[0], (TCityResource(FResource).FSize - 1) * $400000);
    end
    else if Msg.MsgID = $1201 then Msg.Result := Integer(FProduction)
    else if Msg.MsgID = $1108 then ReturnBattleFieldInfo(TBattleFieldInfo(Pointer(Msg.Param[0])^))
    else if Msg.MsgID = $1107 then
    begin
      InitCombat(TCombat(Msg.Param[0]), TArmyHS(Msg.Param[1]));
      Msg.Result := 1;
    end
    else if Msg.MsgID = $110D then UpdateVisibleForSeatedPlayer
    else if Msg.MsgID = $1123 then
    begin
      if (FWallType <> 0) and not (cmWarmode in FMode) and not GetRazed then
        if Self = TMapField(Msg.Param[0]).FindNoneTransparentHS(TCity) then Msg.Result := FWallType;
    end
    else if Msg.MsgID = $1125 then
    begin
      if FPlayer = 0 then Msg.Result := GetIndependentRelation;
    end
    else if Msg.MsgID = $110E then
    begin
      if IncommingNegotiateRequest(TNegotiateRequestEventLog(Msg.Param[0])) then Msg.Param[1] := 1;
    end
    else if Msg.MsgID = $110F then
    begin
      if IncommingNegotiateOffer(TNegotiateTE(Msg.Param[0])) then Msg.Result := 1;
    end
    else if (Msg.MsgID = $1129) and (ceiAntiMagicShell in FEnchantments) then Msg.Param[0] := 1;
  end;
end;

function TCity.GetTopBorderImage: TLibraryImage;
var Index: Integer; Sequences: TImageSequenceList;
begin
  Result := GetTopCityActionImage(GetActiveAction);
  if Result = nil then
  begin
    if FRace <> -1 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(40)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(43);
    end
    else Result := nil;
  end;
  if cmRazed in FMode then
  begin
    Index := 42;
    Sequences := FResource.ImageSequenceList;
    if Sequences <> nil then
    begin
      if Sequences.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end;
end;

function TCity.GetMiddleBorderImage: TLibraryImage;
var Index: Integer; Sequences: TImageSequenceList;
begin
  Result := GetMiddleCityActionImage(GetActiveAction);
  if Result = nil then
  begin
    if FRace <> -1 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(41)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(44);
    end
    else Result := nil;
  end;
  if cmRazed in FMode then
  begin
    Index := 43;
    Sequences := FResource.ImageSequenceList;
    if Sequences <> nil then
    begin
      if Sequences.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end;
end;

function TCity.GetBottomBorderImage: TLibraryImage;
var Index: Integer; Sequences: TImageSequenceList;
begin
  Result := GetBottomCityActionImage(GetActiveAction);
  if Result = nil then
  begin
    if FRace >= 0 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(42)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(45);
    end
    else Result := nil;
  end;
  if cmRazed in FMode then
  begin
    Index := 44;
    Sequences := FResource.ImageSequenceList;
    if Sequences <> nil then
    begin
      if Sequences.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end;
end;

function TCity.GetTopCityActionImage(Action: TCityAction): TLibraryImage;
var Index: Integer;
begin
  if not (Action in [caNone, caTrade, caProduce]) then
  begin
    Index := -1;
    case Action of
      caFortify:
        case FWallType of
          0: Index := 30;
          1: Index := 48;
        end;
      caUpgrade: Index := 33;
      caMigrate: Index := 39;
      caRaze: Index := 51;
      caLoot: Index := 45;
    end;
    if (FResource.ImageSequenceList <> nil) and (Index <> -1) then
    begin
      if FResource.ImageSequenceList.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end
  else
  begin
    if FRace <> -1 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(40)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(43);
    end
    else Result := nil;
  end;
end;

function TCity.GetMiddleCityActionImage(Action: TCityAction): TLibraryImage;
var Index: Integer;
begin
  if not (Action in [caNone, caTrade, caProduce]) then
  begin
    Index := -1;
    case Action of
      caFortify:
        case FWallType of
          0: Index := 31;
          1: Index := 49;
        end;
      caUpgrade: Index := 34;
      caMigrate: Index := 40;
      caRaze: Index := 52;
      caLoot: Index := 46;
    end;
    if (FResource.ImageSequenceList <> nil) and (Index <> -1) then
    begin
      if FResource.ImageSequenceList.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end
  else
  begin
    if FRace <> -1 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(41)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(44);
    end
    else Result := nil;
  end;
end;

function TCity.GetBottomCityActionImage(Action: TCityAction): TLibraryImage;
var Index: Integer;
begin
  if not (Action in [caNone, caTrade, caProduce]) then
  begin
    Index := -1;
    case Action of
      caFortify:
        case FWallType of
          0: Index := 32;
          1: Index := 50;
        end;
      caUpgrade: Index := 35;
      caMigrate: Index := 41;
      caRaze: Index := 53;
      caLoot: Index := 47;
    end;
    if (FResource.ImageSequenceList <> nil) and (Index <> -1) then
    begin
      if FResource.ImageSequenceList.GetImageSequence(Index) <> nil then
        Result := FResource.ImageSequenceList.GetImageSequence(Index).GetPreviewImage
      else Result := nil;
    end
    else Result := nil;
  end
  else
  begin
    if FRace >= 0 then
    begin
      if GetLhx = 0 then Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(42)
    else Result := WorldSet^.FRaceResources.GetRaceResource(FRace).FImageLibrary.GetSafe(45);
    end
    else Result := nil;
  end;
end;

function TCity.GetCurrentActivityText: string;
begin
  if FProduction.FQueue.Count = 0 then Result := TranslateRStr(LoadResString(ProducingMerchandiseText))
  else Result := FProduction.GetProductionNameProgressive(FProduction.FQueue.GetItem(0));
end;

procedure TCity.Select;
begin
  inherited Select;
end;

constructor TCityResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRazeable := True;
end;

class function TCityResource.ClassID: Integer;
begin
  Result := $20109;
end;

class function TCityResource.ResourceEditName: string;
begin
  Result := TranslateRStr(LoadResString(CityText));
end;

function TCityResource.ResourceUserClassID: Integer;
begin
  Result := $20108;
end;

procedure TCityResource.ShowCity(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; City: TCity);
var
  Image: TLibraryImage;
begin
  X := FdXImage + X;
  Y := Y + FdYImage;
  Image := City.FWallBackImage;
  if Image <> nil then Image.Show(X, Y, SurfaceDesc);
  if City.FCityImage <> nil then
    if City.GetSelected and ([msActivated, msEditting] <= WorldMap^.Status) then
      City.FCityImage.ShowTransparent(X, Y, SurfaceDesc)
    else City.FCityImage.Show(X, Y, SurfaceDesc);
  Image := City.FWallFrontImage;
  if Image <> nil then Image.Show(X, Y, SurfaceDesc);
end;

procedure TCityResource.ActivateMsg;
var I: Integer;
begin
  FSize := 0;
  for I := 0 to FTerrainList.Count - 1 do
    if FTerrainList.Terrain[I] >= 0 then Inc(FSize);
end;

procedure TCityResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then ActivateMsg;
end;

class function TCityRebellionEventLog.ClassID: Integer;
begin
  Result := $20112;
end;

procedure TCityRebellionEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FXhx, $14);
  Stream.rwInteger(FYhx, $15);
  Stream.rwInteger(FLhx, $16);
  Stream.rwString(FCityName, $17);
end;

function TCityRebellionEventLog.GetText: string;
begin
  Result := SysUtils.Format(TranslateRStr(LoadResString(RebellionText)), [FCityName]);
end;

procedure TCityRebellionEventLog.ViewLocation;
begin
  CenterViewTo(FXhx, FYhx, FLhx);
end;

function TCityRebellionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var ShowEvent: Boolean;
begin
  ShowEvent := Trigger = etUser;
  ShowEvent := ShowEvent or ((WorldMap^.FPlayMode = pmTurn) and
    (wpRebellion in WorldEngine^.FRegistry.GetClassicWindowPopupEvents));
  ShowEvent := ShowEvent or ((WorldMap^.FPlayMode = pmSimultaneous) and
    (wpRebellion in WorldEngine^.FRegistry.GetSimultaneousWindowPopupEvents));
  if ShowEvent then Result := inherited Execute(Mode, Trigger, Done)
  else Result := False;
end;

function TMigrationList.GetItems(Index: Integer): TMigrationItem;
begin
  Result := TMigrationItem(Children[Index]);
end;

constructor TCityEnchantment.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FEnchantmentMode := FEnchantmentMode - [gemTrueGlobal, gemOwned];
end;

class function TCityEnchantment.ClassID: Integer;
begin
  Result := $202EC;
end;

procedure TCityEnchantment.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FEnchantmentID, SizeOf(FEnchantmentID), $14);
  Stream.rwInteger(FEnchantmentLocation.XYL, $15);
end;

function TCityEnchantment.VisibleForPlayer(Player: Shortint): Boolean;
begin
  Result := GetCity.VisibleForPlayer(Player);
end;

function TCityEnchantment.GetLocation: TXYL;
begin
  Result.X := FEnchantmentLocation.X;
  Result.Y := FEnchantmentLocation.Y;
  Result.L := FEnchantmentLocation.L;
end;

function TCityEnchantment.Deactivate(Player: Byte): Boolean;
begin
  if getActivated in FEnchantmentStatus then
  begin
    Result := inherited Deactivate(Player);
    GetCity.DeactivateEnchantment(Self);
  end
  else Result := False;
end;

function TCityEnchantment.GetCity: TCity;
begin
  Result := TCity(WorldMap^.MapContainer.GetField(FEnchantmentLocation.X,
    FEnchantmentLocation.Y, FEnchantmentLocation.L).FindNoneTransparentHS(TCity));
end;

function TCityEnchantment.GetName: string;
begin
  Result := TranslateRStr(CityEnchantmentNames[FEnchantmentID]);
end;

function TCityEnchantment.GetAIUpkeepPriority: Integer;
var City: TCity;
begin
  City := GetCity;
  if City <> nil then Result := City.AICityEnchantmentUpkeepPriority(FEnchantmentID)
  else Result := 0;
end;

class function TAICityUpgradeBudget.ClassID: Integer;
begin
  Result := $20115;
end;

class function TAICityResearchBudget.ClassID: Integer;
begin
  Result := $20116;
end;

class function TAICityFortifyBudget.ClassID: Integer;
begin
  Result := $20117;
end;

class function TCityAIPA.Priority: Integer;
begin
  Result := 13;
end;

function TCityAIPA.ValidResearchCity(City: TCity): Boolean;
begin
  Result := City.FProduction.GetProduceUnitLevelMax < City.FUpgradeLevel;
  Result := Result and ((City.GetActiveAction in [caNone, caTrade]) or
    ((City.GetActiveAction in [caProduce]) and (City.FProduction.FSettings.FTurnsLeft = City.FProduction.FSettings.FTurnsTotal)));
end;

function TCityAIPA.ValidResearchBudgetCity(City: TCity): Boolean;
begin
  Result := (City.FProduction.GetProduceUnitLevelMax <> City.FUpgradeLevel) or (City.GetActiveAction = caUpgrade);
end;

procedure TCityAIPA.ValidateResearchBudget(Budget: TAIBudget);
var
  Player: TPlayer;
  I, Count, Total, Priority: Integer;
  Structure: TPlayerStructure;
begin
  Player := FControl.FPlayer;
  Count := 0;
  Total := 0;
  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    Structure := Player.FStructures.GetStructure(I);
    if Structure is TCity then
    begin
      Inc(Total);
      if ValidResearchBudgetCity(TCity(Structure)) then Inc(Count);
    end;
  end;
  if Count = 0 then
  begin
    Player.FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
    Budget.FGold := 0;
    Budget.FMana := 0;
    Budget.FRequiredGold := 0;
    Budget.FPriority := 7;
  end
  else
  begin
    Budget.FRequiredGold := 125;
    Priority := 7 - (Count * Total) div 3;
    if Priority < 3 then Priority := 3;
    if Priority < Budget.FPriority then Budget.FPriority := Priority;
  end;
end;

function TCityAIPA.ResearchProduction(ResearchBudget, UpgradeBudget: TAIBudget): Boolean;
var
  Player: TPlayer;
  Cities: TDoubleItemList;
  I, J, UnitIndex, Index, Value: Integer;
  Structure: TPlayerStructure;
  City: TCity;
  Valid: Boolean;
  Production: TProductionItem;
begin
  Result := False;
  Player := FControl.FPlayer;
  Cities := TDoubleItemList.Create;
  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    Structure := Player.FStructures.GetStructure(I);
    if (Structure is TCity) and ValidResearchCity(TCity(Structure)) then
    begin
      City := TCity(Structure);
      Valid := False;
      for J := City.FProduction.FUnitProductions.Count - 1 downto 0 do
      begin
        UnitIndex := City.FProduction.FUnitProductions.GetItem(J).FUnitIndex;
        if UnitIndex <> -1 then
          Valid := Valid or ((WorldSet^.FUnitResources.GetUnitResource(UnitIndex).FLevel = City.FUpgradeLevel) and
            not City.FProduction.FUnitProductions.GetItem(J).FResearched and
            (City.ResearchCost(J) <= ResearchBudget.FGold + UpgradeBudget.FGold));
      end;
      if Valid then Cities.AddAB(Integer(City), City.GetSize * 2 + (City.FProductionPriority + City.FWallType * 3));
    end;
  end;
  Cities.SortDescendingItemB;
  if Cities.Count <> 0 then
  begin
    Index := 0;
    Value := Round(Cities[0].B * 0.75);
    while (Index + 1 < Cities.Count) and (Value <= Cities[Index + 1].B) do Inc(Index);
    Index := WorldMap^.Random(Index + 1);
    City := TCity(Cities[Index].A);
    RandomSeed^ := WorldMap^.Random($FFFFFF);
    Index := TCity(Cities[Index].A).FProduction.FindOptimalResearchProduction(nil, ResearchBudget.FGold + UpgradeBudget.FGold);
    if Index <> -1 then
    begin
      City.FProduction.ExecuteDeleteProductions;
      Production := TProductionItem.Create(nil);
      Production.FProductionID := 2;
      Production.FParameter := Index;
      City.FProduction.ExecuteAddProduction(Production);
      Production.Free;
      Value := City.ResearchCost(Index);
      if Value > ResearchBudget.FGold then
      begin
        Dec(Value, ResearchBudget.FGold);
        Player.FAIBudget.BudgetExpenseMade(ResearchBudget.FGold, 0, ResearchBudget, bemBudget);
        Player.FAIBudget.BudgetExpenseMade(Value, 0, UpgradeBudget, bemBudget);
      end
      else Player.FAIBudget.BudgetExpenseMade(Value, 0, ResearchBudget, bemBudget);
      Result := True;
    end;
  end;
  Cities.Free;
end;

function TCityAIPA.ValidUpgradeCity(City: TCity): Boolean;
var Reason: string; Level: Integer;
begin
  Level := City.FProduction.GetProduceUnitLevelMax;
  Result := City.CanUpgrade(False, Reason);
  Result := Result and (City.GetSize > City.FUpgradeLevel) and
    not ((Level = FMaxProductionLevel) and (FProductionLevelCounts[Level] = 1)) and
    (Level = City.FUpgradeLevel);
  Result := Result and ((City.GetActiveAction in [caNone, caTrade]) or
    ((City.GetActiveAction in [caProduce]) and (City.FProduction.FSettings.FTurnsLeft = City.FProduction.FSettings.FTurnsTotal)));
end;

function TCityAIPA.ValidUpgradeBudgetCity(City: TCity): Boolean;
var Level: Integer;
begin
  Level := City.FProduction.GetProduceUnitLevelMax;
  Result := (City.GetSize > City.FUpgradeLevel) and (Level = City.FUpgradeLevel);
end;

function TCityAIPA.UpgradeCity(Budget: TAIBudget): Boolean;
var
  Player: TPlayer;
  Cities: TDoubleItemList;
  I, Priority: Integer;
  City: TCity;
  Production: TProductionItem;
begin
  Player := FControl.FPlayer;
  Cities := TDoubleItemList.Create;
  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    City := TCity(Player.FStructures.GetStructure(I));
    if (City is TCity) and ValidUpgradeCity(City) then
    begin
      Priority := City.GetSize * 2 + (City.FProductionPriority + City.FWallType * 3);
      Cities.AddAB(Integer(City), Priority);
    end;
  end;
  Cities.SortDescendingItemB;
  Result := Cities.Count <> 0;
  if Result then
  begin
    with Cities[0] do
    begin
    TCity(A).FProduction.ExecuteDeleteProductions;
    Production := TProductionItem.Create(nil);
    Production.FProductionID := CityActionToProductionID(caUpgrade);
    TCity(A).FProduction.ExecuteAddProduction(Production);
    Production.Free;
    Player.FAIBudget.BudgetExpenseMade(250, 0, Budget, bemBudget);
    end;
  end;
  Cities.Free;
end;

procedure TCityAIPA.ValidateUpgradeBudget(Budget: TAIBudget);
var
  Player: TPlayer;
  I, Count, Priority: Integer;
  Structure: TPlayerStructure;
begin
  Player := FControl.FPlayer;
  Count := 0;

  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    Structure := Player.FStructures.GetStructure(I);
    if Structure is TCity then
    begin

      if ValidUpgradeBudgetCity(TCity(Structure)) then Inc(Count);
    end;
  end;
  if Count = 0 then
  begin
    Player.FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
    Budget.FGold := 0;
    Budget.FMana := 0;
    Budget.FRequiredGold := 0;
    Budget.FPriority := 7;
  end
  else
  begin
    Budget.FRequiredGold := 250;
    Priority := 8 - Count div 2;
    if Priority < 5 then Priority := 5;
    if Priority < Budget.FPriority then Budget.FPriority := Priority;
  end;
end;

function TCityAIPA.ValidFortifyCity(City: TCity): Boolean;
var Reason: string;
begin
  Result := City.CanFortify(False, Reason);
  Result := (Result and (City.FWallType = 0)) or
    ((City.FWallType = 1) and (City.GetSize > 2) and (City.FUpgradeLevel > 1) and (WorldMap^.FDay >= 30));
  Result := Result and ((City.GetActiveAction in [caNone, caTrade]) or
    ((City.GetActiveAction in [caProduce]) and (City.FProduction.FSettings.FTurnsLeft = City.FProduction.FSettings.FTurnsTotal)));
end;

function TCityAIPA.ValidFortifyBudgetCity(City: TCity): Boolean;
begin
  Result := (City.FWallType = 0) or ((City.FWallType = 1) and
    (City.GetSize > 2) and (City.FUpgradeLevel > 1) and (WorldMap^.FDay >= 30));
end;

function TCityAIPA.FortifyCity(Budget: TAIBudget): Boolean;
var
  Player: TPlayer;
  Cities: TDoubleItemList;
  I, Priority: Integer;
  City: TCity;
  Production: TProductionItem;
begin
  Player := FControl.FPlayer;
  Cities := TDoubleItemList.Create;
  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    City := TCity(Player.FStructures.GetStructure(I));
    if (City is TCity) and ValidFortifyCity(City) then
    begin
      Priority := City.GetSize * 2 + City.FProductionPriority;
      if City.FWallType = 0 then Inc(Priority, 3);
      Cities.AddAB(Integer(City), Priority);
    end;
  end;
  Cities.SortDescendingItemB;
  Result := Cities.Count <> 0;
  if Result then
  begin
    with Cities[0] do
    begin
    TCity(A).FProduction.ExecuteDeleteProductions;
    Player.FAIBudget.BudgetExpenseMade(TCity(A).FortifyCost, 0, Budget, bemBudget);
    Production := TProductionItem.Create(nil);
    Production.FProductionID := CityActionToProductionID(caFortify);
    TCity(A).FProduction.ExecuteAddProduction(Production);
    Production.Free;
    end;
  end;
  Cities.Free;
end;

procedure TCityAIPA.ValidateFortifyBudget(Budget: TAIBudget);
var
  Player: TPlayer;
  I, Count, Priority: Integer;
  Structure: TPlayerStructure;
begin
  Player := FControl.FPlayer;
  Count := 0;

  for I := Player.FStructures.Count - 1 downto 0 do
  begin
    Structure := Player.FStructures.GetStructure(I);
    if Structure is TCity then
    begin

      if ValidFortifyBudgetCity(TCity(Structure)) then Inc(Count);
    end;
  end;
  if Count = 0 then
  begin
    Player.FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
    Budget.FGold := 0;
    Budget.FMana := 0;
    Budget.FRequiredGold := 0;
    Budget.FPriority := 7;
  end
  else
  begin
    Budget.FRequiredGold := 80;
    Priority := 8 - Count div 2;
    if Priority < 4 then Priority := 4;
    if Priority < Budget.FPriority then Budget.FPriority := Priority;
  end;
end;

function TCityAIPA.UpgradeableCities: Integer;
var I: Integer; Structure: TPlayerStructure; City: TCity;
begin
  Result := 0;
  for I := FControl.FPlayer.FStructures.Count - 1 downto 0 do
  begin
    Structure := FControl.FPlayer.FStructures.GetStructure(I);
    if Structure is TCity then
    begin
      City := TCity(Structure);
      if City.GetSize > City.FUpgradeLevel then Inc(Result);
    end;
  end;
end;

procedure TCityAIPA.UpdateStatistics;
var
  I, Level, Available, Busy: Integer;
  City: TCity;
begin
  FCityCount := 0;
  FMaxProductionLevel := 0;
  Available := 0;
  Busy := 0;
  FillChar(FProductionLevelCounts, SizeOf(FProductionLevelCounts), 0);
  for I := FControl.FPlayer.FStructures.Count - 1 downto 0 do
    if FControl.FPlayer.FStructures.GetStructure(I) is TCity then
    begin
      Inc(FCityCount);
      City := TCity(FControl.FPlayer.FStructures.GetStructure(I));
      if City.GetActiveAction in [caNone, caTrade, caProduce] then
      begin
        Inc(Available, (City.GetSize + 1) div 2);
        Level := City.FProduction.GetProduceUnitLevelMax;
        if Level > 0 then Inc(FProductionLevelCounts[Level]);
        if Level > FMaxProductionLevel then FMaxProductionLevel := Level;
      end
      else Inc(Busy, (City.GetSize + 1) div 2);
    end;
  if FCityCount <> 0 then FProductionRatio := Round(Available / (Available + Busy)) { Original rounds the fraction before storing it. }
  else FProductionRatio := 0;
end;

function TCityAIPA.Process: Boolean;
var
  Player: TPlayer;
  Manager: TAIBudgetManager;
  UpgradeBudget, ResearchBudget, FortifyBudget: TAIBudget;
begin
  UpdateStatistics;
  Player := FControl.FPlayer;
  if Player.FPlayerIndex <> 0 then
  begin
    Manager := Player.FAIBudget;
    UpgradeBudget := TAIBudget(Manager.FBudgets.FindChild($20115));
    if UpgradeBudget = nil then
    begin
      UpgradeBudget := TAICityUpgradeBudget.Create(nil);
      UpgradeBudget.Owner := Manager.FBudgets;
      UpgradeBudget.FRequiredGold := 250;
      UpgradeBudget.FDays := 7;
    end;
    ResearchBudget := TAIBudget(Manager.FBudgets.FindChild($20116));
    if ResearchBudget <> nil then
    begin
      if ResearchBudget.FGold + UpgradeBudget.FGold > 125 then
        if ResearchProduction(ResearchBudget, UpgradeBudget) then
        begin
          ResearchBudget.FDays := 7;
          ResearchBudget.FRequiredGold := 125;
        end;
    end
    else
    begin
      ResearchBudget := TAICityResearchBudget.Create(nil);
      ResearchBudget.FDays := 7;
      ResearchBudget.FRequiredGold := 125;
      ResearchBudget.Owner := Manager.FBudgets;
    end;
    ValidateResearchBudget(ResearchBudget);
    if UpgradeBudget.GetReady then
      if UpgradeCity(UpgradeBudget) then
      begin
        UpgradeBudget.FRequiredGold := 250;
        UpgradeBudget.FDays := 7;
      end;
    ValidateUpgradeBudget(UpgradeBudget);
    FortifyBudget := TAIBudget(Manager.FBudgets.FindChild($20117));
    if FortifyBudget = nil then
    begin
      if WorldMap^.FDay > 5 then
      begin
        FortifyBudget := TAICityFortifyBudget.Create(nil);
        FortifyBudget.FDays := 7;
        FortifyBudget.FRequiredGold := 80;
        FortifyBudget.Owner := Manager.FBudgets;
      end;
    end
    else if FortifyBudget.GetReady then
      if FortifyCity(FortifyBudget) then
      begin
        FortifyBudget.FDays := 7;
        FortifyBudget.FRequiredGold := 80;
      end;
    if FortifyBudget <> nil then ValidateFortifyBudget(FortifyBudget);
  end;
  Result := False;
end;

class function TCityProductionEventLog.ClassID: Integer;
begin
  Result := $202FA;
end;

function TCityProductionEventLog.GetCity: TCity;
begin
  Result := TCity(WorldMap^.MapContainer.GetField(FXhx, FYhx, FLhx).FindNoneTransparentHS(TCity));
end;

function TCityProductionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var City: TCity;
begin
  if Trigger = etUser then
  begin
    City := GetCity;
    if (City <> nil) and (WorldMap^.FSeatedPlayer = City.FPlayer) then
    begin
      WorldMap^.CenterViewTo(FXhx, FYhx, FLhx);
      WorldMap^.TriggerExecuteEventLog(Self, True, Done);
    end;
  end;
  Result := False;
end;

function ProductionIDToCityAction(ID: Integer): TCityAction;
begin
  case ID of
    1: Result := caProduce;
    2: Result := caResearch;
    10: Result := caTrade;
    11: Result := caUpgrade;
    12: Result := caFortify;
    13: Result := caMigrate;
    14: Result := caLoot;
  else Result := caNone;
  end;
end;

function CityActionToProductionID(Action: TCityAction): Integer;
begin
  case Action of
    caProduce: Result := 1;
    caResearch: Result := 2;
    caTrade: Result := 10;
    caUpgrade: Result := 11;
    caFortify: Result := 12;
    caMigrate: Result := 13;
    caLoot: Result := 14;
  else Result := 0;
  end;
end;

function RaceInCity(Race, Player: Shortint): Boolean;
var P: TPlayer; I: Integer;
begin
  Result := False;
  P := WorldMap^.FPlayers.GetPlayers(Player);
  I := 0;
  while (I <> P.FStructures.Count) and not Result do
  begin
    if P.FStructures.GetStructure(I) is TCity then
      Result := not TCity(P.FStructures.GetStructure(I)).GetBuilding and
        (TCity(P.FStructures.GetStructure(I)).FRace = Race);
    Inc(I);
  end;
end;

function UnitLevelToCityLevel(Level, Size: Integer): Integer;
begin
  Result := Level;
end;

function PlayerCities(Player: Shortint): Integer;
var
  P: TPlayer;
  I: Integer;
  Structure: TPlayerStructure;
begin
  if WorldMap^ = nil then Result := 0
  else
  begin
    P := WorldMap^.FPlayers.GetPlayers(Player);
    Result := 0;
    for I := 0 to P.FStructures.Count - 1 do
    begin
      Structure := P.FStructures.GetStructure(I);
      if (Structure.ClassID = $20108) and (Structure.FPlayer = Player) then Inc(Result, 1);
    end;
  end;
end;

function CityIncome(Player: Shortint): Integer;
var
  P: TPlayer;
  I: Integer;
  Structure: TPlayerStructure;
begin
  if WorldMap^ = nil then Result := -1
  else
  begin
    P := WorldMap^.FPlayers.GetPlayers(Player);
    Result := 0;
    for I := 0 to P.FStructures.Count - 1 do
    begin
      Structure := P.FStructures.GetStructure(I);
      if (Structure.ClassID = $20108) and (Structure.FPlayer = Player) then Inc(Result, TCity(Structure).FIncome);
    end;
  end;
end;


class procedure TRegistrator.MapLoaded(Sender: TObject);
begin
  if Sender = WorldMap^ then
    WorldMap^.FAIPlayerActionManager.RegisterClasses([TCityAIPA]);
end;

initialization
  if ValidateAoWEngine then
  begin
    WorldEngine^.RegisterEClasses([TCityEnchantment, TCity, TCityResource,
      TCityRebellionEventLog, TAICityUpgradeBudget, TAICityResearchBudget,
      TAICityFortifyBudget, TCityProductionEventLog]);
    WorldEngine^.OnHSMLoaded.Add(TRegistrator.MapLoaded);
  end;
finalization
  if WorldEngine^ <> nil then
    WorldEngine^.OnHSMLoaded.Remove(TRegistrator.MapLoaded);

end.
