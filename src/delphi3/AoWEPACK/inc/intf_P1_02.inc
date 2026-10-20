{ Interface declaration run owned by P1. }
  { TPlayerStructureList (instance size 24, VMT 55709EC8) }
  TPlayerStructureList = class(TEChangeNotifyEventList)
  public
    FPlayer: TPlayer; { $14 }
    function GetStructure(Index: Integer): TPlayerStructure;
  end;

  { TArmyList (instance size 24, VMT 55709FD8) }
  TArmyList = class(TEChangeNotifyEventList)
  public
    FPlayer: TPlayer; { $14 }
    function GetArmy(Index: Integer): TArmy;
  end;

  { TUnitProduction (instance size 16, VMT 5570A0D0) }
  TUnitProduction = class(TEObject)
  public
    FUnitIndex: Integer;  { $08 }
    FResearched: Boolean;  { $0C }
    F_UnitProduction_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TUnitProductionList (instance size 12, VMT 5570A194) }
  TUnitProductionList = class(TENode)
  public
    function GetItem(Index: Integer): TUnitProduction;
    procedure Add(UnitIndex: Integer; Researched: Boolean);
    function IndexOf(Index: Integer): Integer;
    procedure SortOnLevel;
  end;

  { TProductionItem (instance size 20, VMT 5570A29C) }
  TProductionItem = class(TEObject)
  public
    FProductionID: Integer;  { $08 }
    FParameter: Integer;  { $0C }
    F_ProductionItem_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); virtual;  { +04C draft }
    procedure GetNameProgressive(A1: Integer);  { draft }
  end;

  { TProductionQueue (instance size 16, VMT 5570A364) }
  TProductionQueue = class(TENode)
  public
    F_ProductionQueue_0C: array[0..3] of Byte;
    function GetItem(Index: Integer): TProductionItem;
    procedure IndexOfID(A1: Integer);  { draft }
    procedure IndexOf(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TProductionSettings (instance size 44, VMT 5570A4B4) }
  TProductionSettings = class(TEObject)
  public
    F_ProductionSettings_08: Integer;
    F_ProductionSettings_0C: Integer;
    FWaiting: Boolean;  { $10 }
    F_ProductionSettings_11: array[0..2] of Byte;
    FGoldUpkeep: Integer; { $14 }
    FManaUpkeep: Integer; { $18 }
    FTradeMode: Byte;  { $1C }
    FPlayer: Shortint;  { $1D }
    F_ProductionSettings_1E: array[0..1] of Byte;
    FGroupID: Integer; { $20 }
    FUnit: TAbstractUnit;  { $24 }
    FUnitProductionIndex: Integer;  { $28 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
  end;

  { TProductionEventLog (instance size 32, VMT 5570A580) }
  TProductionEventLog = class(TLocationTextEventLog)
  public
    class function ClassID: Integer; override;
  end;

  { TProductionTE (instance size 40, VMT 5570A6C0) }
  TProductionTE = class(TTokenEvent)
  public
    F_ProductionTE_10: Byte;
    F_ProductionTE_11: Byte;
    F_ProductionTE_12: Byte;
    F_ProductionTE_13: Byte;
    F_ProductionTE_14: Integer;
    F_ProductionTE_18: Integer;
    F_ProductionTE_1C: Byte;
    F_ProductionTE_1D: array[0..2] of Byte;
    F_ProductionTE_20: Integer;
    F_ProductionTE_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TProductionControl (instance size 40, VMT 5570A784) }
  TProductionControl = class(TEObject)
  public
    F_ProductionControl_08: Byte;
    F_ProductionControl_09: array[0..0] of Byte;
    F_ProductionControl_0A: Word;
    F_ProductionControl_0C: Integer;
    FUpdateCount: Integer;  { $10 }
    FQueue: TProductionQueue;  { $14 }
    F_ProductionControl_18: Byte;
    F_ProductionControl_19: array[0..2] of Byte;
    FUnitProductions: TUnitProductionList;  { $1C }
    FStatus: TProductionControlStatus;  { $20 }
    F_ProductionControl_21: array[0..2] of Byte;
    FSettings: TProductionSettings;  { $24 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CancelProductionReturnGold; virtual;  { +04C draft }
    procedure CancelProductionReturnMana; virtual;  { +050 draft }
    procedure ExecuteCancelProduction; virtual;  { +054 draft }
    procedure ExecuteAIProduction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure ExecuteAIResearch(A1: Integer); virtual;  { +05C draft }
    function ExecuteProduction(Item: TProductionItem): Boolean; virtual;
    procedure ExecuteAddProduction(Item: TProductionItem); virtual;
    procedure ExecuteDeleteProduction(A1: Integer); virtual;  { +068 draft }
    procedure ExecuteDeleteProductions; virtual;
    procedure ExecuteProductionTE(A1: Integer); virtual;  { +070 draft }
    procedure CreateProductionTE; virtual;  { +074 draft }
    procedure GetLocation(var X, Y, L: Shortint); virtual;
    function GetPlayer: Shortint; virtual; abstract;
    procedure GetQueueSizeMax; virtual;  { +080 draft }
    procedure GetQueueLocked; virtual;  { +084 draft }
    function LoopableProduction(A1: Integer): Boolean; virtual;
    function LockQueueProduction(A1: Integer): Boolean; virtual;
    function UnitProduced: Boolean; virtual;
    procedure UnitResearched; virtual;
    procedure Update; virtual;
    function CreateUnitProduction(A1: Integer): TUnit; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure NewTurn(Player: Shortint); virtual;
    procedure PlayerChanged; virtual;
    function CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean; virtual;
    procedure DeleteProduction(A1: Integer); virtual;  { +0B4 draft }
    procedure DeleteProductions; virtual;  { +0B8 draft }
    function GetProductionName(Item: TProductionItem): string; virtual;
    function GetProductionNameProgressive(Item: TProductionItem): string; virtual;
    function UnitProductionGold(Index: Integer): Integer; virtual;
    function UnitProductionMana(Index: Integer): Integer; virtual;
    function UnitProductionGoldUpkeep(Index: Integer): Integer; virtual;
    function UnitProductionManaUpkeep(Index: Integer): Integer; virtual;
    function UnitProductionTime(Index: Integer): Integer; virtual;
    function CanProduceUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean; virtual;
    function ProduceUnitEx(Index, GroupID: Integer; Queue: Boolean): Boolean; virtual; { $DC }
    function ProduceUnit(Index: Integer; Queue: Boolean): Boolean; virtual;
    function UnitResearchGold(Index: Integer): Integer; virtual;
    function UnitResearchMana(Index: Integer): Integer; virtual;
    function UnitResearchTime(Index: Integer): Integer; virtual;
    function CanResearchUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean; virtual;
    function ResearchUnit(Index: Integer; Queue: Boolean): Boolean; virtual;
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    function GetProduceUnitLevelMax: Integer;
    procedure GetResearchUnitLevelMax;  { draft }
    procedure RegisterGroupProduction;  { draft }
    procedure UnregisterGroupProduction;  { draft }
    procedure GroupProductionProduced(A1: Integer; A2: Integer);  { draft }
    function Produce(Item: TProductionItem; Queue: Boolean): Boolean;
    procedure RetryProductionExecution(A1: Integer);  { draft }
    procedure SetLoopQueueTo(A1: Integer);  { draft }
    procedure ProductionDone;
    function FindOptimalResearchProduction(Predictor: TCombatPredictor; Gold: Integer): Integer;
  end;

  { TProductionControlList (instance size 16, VMT 5570A8FC) }
  TProductionControlList = class(TList)
  public
    function GetPC(Index: Integer): TProductionControl;
  end;

