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

  { TUnitProduction: size $10; $08 unit index, $0C researched. VMT 5570A0D0. }
  TUnitProduction = class(TEObject)
  public
    FUnitIndex: Integer;  { $08 }
    FResearched: Boolean;  { $0C }
    F_UnitProduction_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TUnitProductionList: size $0C, no added fields. VMT 5570A194. }
  TUnitProductionList = class(TENode)
  public
    function GetItem(Index: Integer): TUnitProduction;
    procedure Add(UnitIndex: Integer; Researched: Boolean);
    function IndexOf(Index: Integer): Integer;
    procedure SortOnLevel;
  end;

  { TProductionItem: size $14; $08 production ID, $0C parameter, $10 group ID. VMT 5570A29C. }
  TProductionItem = class(TEObject)
  public
    FProductionID: Integer;  { $08 }
    FParameter: Integer;  { $0C }
    FGroupID: Integer; { $10 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetName: string; virtual; { $4C }
    function GetNameProgressive: string;
  end;

  { TProductionQueue: size $10; $0C production control. VMT 5570A364. }
  TProductionQueue = class(TENode)
  public
    FProductionControl: TProductionControl; { $0C }
    function GetItem(Index: Integer): TProductionItem;
    function IndexOfID(ID: Integer): Integer;
    function IndexOf(ID, Parameter, GroupID: Integer): Integer;
  end;

  { TProductionSettings: size $2C; $08/$0C costs, $10 turns left, $14/$18 upkeep,
    $1C turns total, $1D player, $20 group, $24 unit, $28 unit production. VMT 5570A4B4. }
  TProductionSettings = class(TEObject)
  public
    FGold: Integer; { $08 }
    FMana: Integer; { $0C }
    FTurnsLeft: Shortint;  { $10 }
    F_ProductionSettings_11: array[0..2] of Byte;
    FGoldUpkeep: Integer; { $14 }
    FManaUpkeep: Integer; { $18 }
    FTurnsTotal: Shortint;  { $1C }
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

  { TProductionTE: size $28; $10..$13 location/player, $14 command, $18 item,
    $1C queue, $20 index, $24 reserved. VMT 5570A6C0. }
  TProductionTE = class(TTokenEvent)
  public
    FX: Shortint; { $10 }
    FY: Shortint; { $11 }
    FL: Shortint; { $12 }
    FPlayer: Shortint; { $13 }
    FCommand: Integer; { $14 }
    FItem: TProductionItem; { $18 }
    FQueue: Boolean; { $1C }
    F_ProductionTE_1D: array[0..2] of Byte;
    FIndex: Integer; { $20 }
    FReserved: Integer; { $24 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TProductionControl: size $28; $08 change event, $10 update count, $14 queue,
    $18 loop queue, $1C unit productions, $20 status, $24 settings. VMT 5570A784. }
  TProductionControl = class(TEObject)
  public
    FOnChange: TNotifyEvent; { $08 }
    FUpdateCount: Integer;  { $10 }
    FQueue: TProductionQueue;  { $14 }
    FLoopQueue: Boolean; { $18 }
    F_ProductionControl_19: array[0..2] of Byte;
    FUnitProductions: TUnitProductionList;  { $1C }
    FStatus: TProductionControlStatus;  { $20 }
    F_ProductionControl_21: array[0..2] of Byte;
    FSettings: TProductionSettings;  { $24 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CancelProductionReturnGold: Integer; virtual;
    function CancelProductionReturnMana: Integer; virtual;
    procedure ExecuteCancelProduction; virtual;
    procedure ExecuteAIProduction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure ExecuteAIResearch(A1: Integer); virtual;  { +05C draft }
    function ExecuteProduction(Item: TProductionItem): Boolean; virtual;
    procedure ExecuteAddProduction(Item: TProductionItem); virtual;
    procedure ExecuteDeleteProduction(Index: Integer); virtual; { $68 }
    procedure ExecuteDeleteProductions; virtual;
    function ExecuteProductionTE(Event: TProductionTE): TExecuteResult; virtual; { $70 }
    procedure CreateProductionTE; virtual;  { +074 draft }
    procedure GetLocation(var X, Y, L: Shortint); virtual;
    function GetPlayer: Shortint; virtual; abstract;
    function GetQueueSizeMax: Integer; virtual;
    function GetQueueLocked: Boolean; virtual;
    function LoopableProduction(A1: Integer): Boolean; virtual;
    function LockQueueProduction(A1: TProductionItem): Boolean; virtual;
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
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetProduceUnitLevelMax: Integer;
    function GetResearchUnitLevelMax: Integer;
    procedure RegisterGroupProduction;
    procedure UnregisterGroupProduction;
    procedure GroupProductionProduced(AUnit: TAbstractUnit; GroupID: Integer);
    function Produce(Item: TProductionItem; Queue: Boolean): Boolean;
    procedure RetryProductionExecution(A1: Integer);  { draft }
    procedure SetLoopQueueTo(A1: Integer);  { draft }
    procedure ProductionDone;
    function FindOptimalResearchProduction(Predictor: TCombatPredictor; Gold: Integer): Integer;
  end;

  { TProductionControlList: size $10; inherited $04 item array. VMT 5570A8FC. }
  TProductionControlList = class(TList)
  public
    function GetPC(Index: Integer): TProductionControl;
  end;

