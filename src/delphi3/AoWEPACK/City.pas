unit City;

{ City, from AoWEPACK.dpl. Recovered TCity bodies through GetObtainValue,
  migration helpers, and production sorting. Layouts and VMT order follow the original;
  remaining draft declarations and stub bodies are retained for the next recovery pass. }

interface

uses
  Animation, Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls, ExtCtrls, ComCtrls, Grids, Registry, Engine, PlugInM, GFXE, ImageLib, DisplayC, Sound, NetworkE, aowFX, HSEngine, IsoHex, ILTer, Terrain, Hexagon, Road, BorderHx, IvDictio, IvAMulti, IvBinDic, IvMulti, AoWE, Crops, EventLog;

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
    function LoopableProduction(A1: Integer): Boolean; override;
    function LockQueueProduction(A1: Integer): Boolean; override;
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

  { TCityEnchantment (instance size 44, VMT 557A7294): $24 FEnchantmentID. }
  TCityEnchantment = class(TGlobalEnchantment)
  public
    FEnchantmentID: TCityEnchantmentID; { $24 }
    F_CityEnchantment_25: array[0..2] of Byte;
    FEnchantmentLocation: TXYL; { $28 }
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
    procedure SetupRazeDefenderAG(Armies: TArmyHSList; Units: TUnitList); override;
    function ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult; override;
    function GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean; override;
    function GetDefensePriority: TDefensePriority; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ArmyRemoved; override;
    procedure BuildingDone; override;
    function GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean; override;
    function ExecuteRaze(Player: Shortint): Boolean; override;
    function GetCurrentActivityText: string; override;
    function ValidateMap(A1: Integer): Boolean; override;
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
    procedure GetMoveAction(A1: Integer; A2: Integer); override;
    function UpdatePlayer: Boolean; override;
    procedure UpdateIncome; override;
    procedure UpdateCrops; override;
    function GetRace: Shortint; override;
    procedure CropTrampled(Player: Shortint); override;
    procedure SetRace(Race: Byte); virtual;
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
    procedure IncommingNegotiateRequest(A1: Integer);  { draft }
    procedure IncommingNegotiateOffer(A1: Integer);  { draft }
    function GetEnemiesIndependentRelation(Player: Shortint): Shortint;
    procedure GetIndependentRelation;  { draft }
    procedure ReturnBattleFieldInfo(A1: Integer);  { draft }
    procedure UpdateVisibleForSeatedPlayer;  { draft }
    procedure GetTopCityActionImage(A1: Integer);  { draft }
    procedure GetMiddleCityActionImage(A1: Integer);  { draft }
    procedure GetBottomCityActionImage(A1: Integer);  { draft }
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
    procedure ActivateMsg;  { draft }
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
    class function Priority: Integer; override;
    function Process: Boolean; override;
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
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure GetCity;  { draft }
  end;

  { TRegistrator (instance size 4, VMT 557AF144) }
  TRegistrator = class(TObject)
  public
  end;

function ProductionIDToCityAction(ID: Integer): TCityAction;
function CityActionToProductionID(Action: TCityAction): Integer;
function RaceInCity(Race, Player: Shortint): Boolean;
function UnitLevelToCityLevel(Level, Size: Integer): Integer;
procedure PlayerCities(A1: Byte);  { draft }
procedure CityIncome(A1: Byte);  { draft }

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
begin end;

procedure TCityProductionControl.NewTurn(Player: Shortint);
begin end;

procedure TCityProductionControl.ExecuteCancelProduction;
begin end;

function TCityProductionControl.LockQueueProduction(A1: Integer): Boolean;
begin
  Result := inherited LockQueueProduction(A1);
  case ProductionIDToCityAction(TProductionItem(A1).FProductionID) of
    caMigrate: Result := True;
    caLoot: Result := True;
  end;
end;

function TCityProductionControl.LoopableProduction(A1: Integer): Boolean;
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

function TCity.ValidateMap(A1: Integer): Boolean;
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
    DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, 0);
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

procedure TCity.SetupRazeDefenderAG(Armies: TArmyHSList; Units: TUnitList);
var Group: TAIGroup;
begin
  if WorldMap^.Random(8) = 0 then
  begin
    Group := WorldMap^.FAIGroupManager.CreateGroup(0, UnitsToIndependentRelation(Units, 5), 5);
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
        Result := Army.PlaceEx(Walk.X, Walk.Y, [apSafe, apScanArea], GetLhx);
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
        if Army <> nil then Inc(Result, Army.FArmy.ObtainValue(-1));
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

procedure TCity.ArmyPlaced(A1: Integer);
begin
  inherited ArmyPlaced(A1);
  if ceiFountainOfLife in FEnchantments then ExecuteFountainOfLife;
  if ceiAntiMagicShell in FEnchantments then FOverlay.PlayFadeShellAnimation;
end;

procedure TCity.ArmyRemoved;
begin
  inherited ArmyRemoved;
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
        DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, 0);
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
    for I := 0 to Armies.Count - 1 do Dec(Value, Armies.GetArmyHS(I).FArmy.ObtainValue(-1));
    if Value > 0 then
    begin
      RandomSeed^ := WorldMap^.Random($FFFFF);
      PlaceRandomUnits(GetXhx, GetYhx, GetLhx, 0,
        WorldSet^.FRaceResources.GetRaceResource(FRace).FUnitIndexes,
        FUpgradeLevel, Value, [pmScanArea, pmNeglectEmptyPlayerLocation]);
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
    (WorldMap^.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments and 8 <> 0)) then
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
      if Predictor.GetSuperiority div 4 < 75 then
        List.Add(SysUtils.Format(TranslateRStr(LoadResString(OccupationForcesXText)),
          [TranslateRStr(LoadResString(AverageText))]))
      else List.Add(SysUtils.Format(TranslateRStr(LoadResString(OccupationForcesXText)),
          [TranslateRStr(LoadResString(StrongText))]));
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
  else if (Terrain = 5) or (Terrain in [7..9, 12..13]) then Offset := 40
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
  if (moEditMode in FStatus) or ((cmRazed in FMode) and not GetBuilding) or (cmWarmode in FMode) then
    FFlagID := 63
  else if FPlayer > 0 then
    FFlagID := WorldMap^.FPlayers.GetPlayers(FPlayer).FPlayerRace + (FUpgradeLevel - 1) * 64
  else FFlagID := 32 + (FUpgradeLevel - 1) * 64;
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

procedure TCity.SetRace(Race: Byte);
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
    if ((msEditting in WorldMap^.Status) or not FFogged or (WorldMap^.FFogEnabled = 0)) and
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
begin
  Result := 0;
end;

procedure TCity.GetMoveAction(A1: Integer; A2: Integer);
begin end;

procedure TCity.IncommingNegotiateRequest(A1: Integer);
begin end;

procedure TCity.IncommingNegotiateOffer(A1: Integer);
begin end;

function TCity.GetEnemiesIndependentRelation(Player: Shortint): Shortint;
begin Result := 0; end;

procedure TCity.GetIndependentRelation;
begin end;

procedure TCity.ReturnBattleFieldInfo(A1: Integer);
begin end;

procedure TCity.UpdateVisibleForSeatedPlayer;
begin end;

procedure TCity.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

function TCity.GetTopBorderImage: TLibraryImage;
begin Result := nil; end;

function TCity.GetMiddleBorderImage: TLibraryImage;
begin Result := nil; end;

function TCity.GetBottomBorderImage: TLibraryImage;
begin Result := nil; end;

procedure TCity.GetTopCityActionImage(A1: Integer);
begin end;

procedure TCity.GetMiddleCityActionImage(A1: Integer);
begin end;

procedure TCity.GetBottomCityActionImage(A1: Integer);
begin end;

function TCity.GetCurrentActivityText: string;
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

procedure TCityResource.ShowCity(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; City: TCity);
begin end;

procedure TCityResource.ActivateMsg;
begin end;

procedure TCityResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

class function TCityRebellionEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TCityRebellionEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCityRebellionEventLog.GetText: string;
begin Result := ''; end;

procedure TCityRebellionEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

function TCityRebellionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

function TMigrationList.GetItems(Index: Integer): TMigrationItem;
begin
  Result := TMigrationItem(Children[Index]);
end;

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

class function TCityAIPA.Priority: Integer;
begin Result := 0; end;

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

function TCityAIPA.Process: Boolean;
begin Result := False; end;

class function TCityProductionEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TCityProductionEventLog.GetCity;
begin end;

function TCityProductionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

function ProductionIDToCityAction(ID: Integer): TCityAction;
begin
  case ID of
    10: Result := caTrade;
    11: Result := caUpgrade;
    12: Result := caFortify;
    13: Result := caMigrate;
    14: Result := caLoot;
    1: Result := caProduce;
    2: Result := caResearch;
  else Result := caNone;
  end;
end;

function CityActionToProductionID(Action: TCityAction): Integer;
begin
  case Action of
    caTrade: Result := 10;
    caUpgrade: Result := 11;
    caFortify: Result := 12;
    caMigrate: Result := 13;
    caLoot: Result := 14;
    caProduce: Result := 1;
    caResearch: Result := 2;
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

procedure PlayerCities(A1: Byte);
begin end;

procedure CityIncome(A1: Byte);
begin end;


initialization
finalization

end.
