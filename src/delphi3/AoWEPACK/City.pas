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
    $58 FEnchantmentList, $5C FEnchantments, $60 FOverlay, $64 FEnchantmentsVisible,
    $68 FWallBackImage, $6C FWallFrontImage, $70 FCityImage, $74 FCityAIMode. }
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
    F_City_54: Byte;
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
    FCityAIMode: Byte; { $74 }
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
    procedure SetupRazeDefenderAG(A1: Integer; A2: Integer); override;
    function ExecuteTE(A1: TStructureTE): TExecuteResult; override;
    procedure GetDefenseRequirements(A1: Integer; A2: Integer); override;
    procedure GetDefensePriority; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure ArmyPlaced(A1: Integer); override;
    procedure ArmyRemoved; override;
    procedure BuildingDone; override;
    procedure GenerateRazeDefenders(A1: Integer; A2: Integer); override;
    procedure ExecuteRaze(A1: Integer; A2: Integer); override;
    function GetCurrentActivityText: string; override;
    function ValidateMap(A1: Integer): Boolean; override;
    procedure UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer); override;
    procedure Update; override;
    function CanDblClick: Boolean; override;
    procedure GetRebuildInfo(A1: Integer; A2: Integer); override;
    procedure SetPlayer(Player: Shortint); override;
    procedure UpdateFlagID; override;
    function VisibilityRange: Integer; override;
    procedure FinalizeCombat(A1: Integer); override;
    procedure GetCombatEventText(A1: Integer; A2: Integer); override;
    procedure StructureCaptured(OldPlayer, NewPlayer: Shortint); override;
    procedure GetMoveAction(A1: Integer; A2: Integer); override;
    procedure UpdatePlayer; override;
    procedure UpdateIncome; override;
    procedure UpdateCrops; override;
    function GetRace: Shortint; override;
    procedure CropTrampled(Player: Shortint); override;
    procedure SetRace(A1: Byte); virtual;  { +244 draft }
    function GetActiveAction: TCityAction;
    procedure UpdateActiveEnchantments;
    procedure RegisterEnchantments;  { draft }
    procedure UnregisterEnchantments;  { draft }
    procedure ResetEnchantments;  { draft }
    function AICityEnchantmentUpkeepPriority(ID: TCityEnchantmentID): Integer;
    procedure ActivateEnchantment(Enchantment: TCityEnchantment);
    procedure DeactivateEnchantment(Enchantment: TCityEnchantment);
    procedure ListEnhancementsInfo(List: TStrings);
    procedure StartTownQuake;  { draft }
    procedure StopTownQuake;  { draft }
    procedure ExecuteAnarchy;  { draft }
    procedure ExecuteFountainOfLife;
    procedure UpdateAIMigration;  { draft }
    procedure ValidateAICityAction;  { draft }
    procedure MoveArmiesOutOfCity(A1: Byte);  { draft }
    function GetSize: Integer;
    procedure GetObtainUnitsValue;  { draft }
    function UpgradeCost: Integer;
    procedure UpgradeTime;  { draft }
    procedure CanUpgrade(A1: Byte; A2: Integer);  { draft }
    procedure Upgrade(A1: Integer);  { draft }
    function FortifyCost: Integer;
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
    function CanLoot(var Reason: string): Boolean;
    procedure Loot;  { draft }
    procedure MigrationTime(A1: Byte);  { draft }
    function CanMigrate(Race: Shortint; var Reason: string): Boolean;
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
    procedure Priority; override;
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
procedure RaceInCity(A1: Byte; A2: Byte; A3: Integer);  { draft }
procedure UnitLevelToCityLevel;  { draft }
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
  FCityAIMode := 3;
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

function TCity.ExecuteTE(A1: TStructureTE): TExecuteResult;
begin Result := inherited ExecuteTE(A1); end;

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

procedure TCity.ExecuteFountainOfLife;
begin end;

procedure TCity.UpdateAIMigration;
begin end;

procedure TCity.StructureCaptured(OldPlayer, NewPlayer: Shortint);
begin end;

procedure TCity.ValidateAICityAction;
begin end;

procedure TCity.SetPlayer(Player: Shortint);
begin end;

procedure TCity.SetupRazeDefenderAG(A1: Integer; A2: Integer);
begin end;

procedure TCity.GetDefensePriority;
begin end;

procedure TCity.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TCity.UpdateAITarget(var Info: TAITargetInfo; var Priority: Integer);
begin end;

procedure TCity.CropTrampled(Player: Shortint);
begin end;

procedure TCity.MoveArmiesOutOfCity(A1: Byte);
begin end;

procedure TCity.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

function TCity.GetSize: Integer;
begin Result := TCityResource(FResource).FSize; end;

procedure TCity.GetObtainUnitsValue;
begin end;

procedure TCity.UpdatePlayer;
begin end;

procedure TCity.ArmyPlaced(A1: Integer);
begin end;

procedure TCity.ArmyRemoved;
begin end;

function TCity.UpgradeCost: Integer;
begin Result := UpgradePrices[GetSize]; end;

procedure TCity.UpgradeTime;
begin end;

procedure TCity.CanUpgrade(A1: Byte; A2: Integer);
begin end;

procedure TCity.Upgrade(A1: Integer);
begin end;

function TCity.FortifyCost: Integer;
begin
  case FWallType of
    0: Result := WoodWallPrices[GetSize];
    1: Result := StoneWallPrices[GetSize];
  else Result := -1;
  end;
end;

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

function TCity.CanLoot(var Reason: string): Boolean;
begin Result := not (cmRazed in FMode); end;

procedure TCity.Loot;
begin end;

procedure TCity.MigrationTime(A1: Byte);
begin end;

function TCity.CanMigrate(Race: Shortint; var Reason: string): Boolean;
begin Result := False; end;

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

function TCity.GetRazed: Boolean;
begin end;

procedure TCity.SetRazed(Value: Boolean);
begin end;

procedure TCity.GetRebuildInfo(A1: Integer; A2: Integer);
begin end;

procedure TCity.CheckRebellion;
begin end;

procedure TCity.GenerateDefenders(A1: Integer; A2: Integer);
begin end;

procedure TCity.NewTurn(Player: Shortint);
begin end;

procedure TCity.NewDay;
begin end;

procedure TCity.UpdateCrops;
begin end;

procedure TCity.ListIncomeInfo(A1: Integer; A2: Integer);
begin end;

procedure TCity.UpdateIncome;
begin end;

function TCity.GetValidTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

function TCity.VisibilityRange: Integer;
begin Result := 0; end;

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

function TCity.GetName: string;
begin end;

procedure TCity.SetName(A1: Integer; A2: Integer);
begin end;

procedure TCity.SetWallType(A1: Byte);
begin end;

procedure TCity.SetRace(A1: Byte);
begin end;

function TCity.GetRace: Shortint;
begin Result := 0; end;

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

function TCityRebellionEventLog.GetText: string;
begin Result := ''; end;

procedure TCityRebellionEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

function TCityRebellionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
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
