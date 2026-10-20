{ Interface declaration run owned by P1. }
  { TPlayerStructureList (instance size 24, VMT 55709EC8) }
  TPlayerStructureList = class(TEChangeNotifyEventList)
  public
    F_PlayerStructureList_14: array[0..3] of Byte;
    procedure GetStructure(A1: Integer);  { draft }
  end;

  { TArmyList (instance size 24, VMT 55709FD8) }
  TArmyList = class(TEChangeNotifyEventList)
  public
    F_ArmyList_14: Byte;
    F_ArmyList_15: array[0..2] of Byte;
    procedure GetArmy(A1: Integer);  { draft }
  end;

  { TUnitProduction (instance size 16, VMT 5570A0D0) }
  TUnitProduction = class(TEObject)
  public
    F_UnitProduction_08: Integer;
    F_UnitProduction_0C: Byte;
    F_UnitProduction_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TUnitProductionList (instance size 12, VMT 5570A194) }
  TUnitProductionList = class(TENode)
  public
    procedure GetItem(A1: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
    procedure IndexOf(A1: Integer);  { draft }
    procedure SortOnLevel;  { draft }
  end;

  { TProductionItem (instance size 20, VMT 5570A29C) }
  TProductionItem = class(TEObject)
  public
    F_ProductionItem_08: Integer;
    F_ProductionItem_0C: Integer;
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
    procedure GetItem(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure IndexOf(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TProductionSettings (instance size 44, VMT 5570A4B4) }
  TProductionSettings = class(TEObject)
  public
    F_ProductionSettings_08: Integer;
    F_ProductionSettings_0C: Integer;
    F_ProductionSettings_10: Byte;
    F_ProductionSettings_11: array[0..2] of Byte;
    F_ProductionSettings_14: Integer;
    F_ProductionSettings_18: Integer;
    F_ProductionSettings_1C: Byte;
    F_ProductionSettings_1D: Byte;
    F_ProductionSettings_1E: array[0..1] of Byte;
    F_ProductionSettings_20: Integer;
    F_ProductionSettings_24: Integer;
    F_ProductionSettings_28: Integer;
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
    F_ProductionControl_10: Integer;
    F_ProductionControl_14: Integer;
    F_ProductionControl_18: Byte;
    F_ProductionControl_19: array[0..2] of Byte;
    F_ProductionControl_1C: Integer;
    F_ProductionControl_20: Byte;
    F_ProductionControl_21: array[0..2] of Byte;
    F_ProductionControl_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CancelProductionReturnGold; virtual;  { +04C draft }
    procedure CancelProductionReturnMana; virtual;  { +050 draft }
    procedure ExecuteCancelProduction; virtual;  { +054 draft }
    procedure ExecuteAIProduction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure ExecuteAIResearch(A1: Integer); virtual;  { +05C draft }
    procedure ExecuteProduction(A1: Integer); virtual;  { +060 draft }
    procedure ExecuteAddProduction(A1: Integer); virtual;  { +064 draft }
    procedure ExecuteDeleteProduction(A1: Integer); virtual;  { +068 draft }
    procedure ExecuteDeleteProductions; virtual;  { +06C draft }
    procedure ExecuteProductionTE(A1: Integer); virtual;  { +070 draft }
    procedure CreateProductionTE; virtual;  { +074 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +078 draft }
    procedure GetPlayer; virtual; abstract;  { +07C draft }
    procedure GetQueueSizeMax; virtual;  { +080 draft }
    procedure GetQueueLocked; virtual;  { +084 draft }
    procedure LoopableProduction(A1: Integer); virtual;  { +088 draft }
    procedure LockQueueProduction(A1: Integer); virtual;  { +08C draft }
    procedure UnitProduced; virtual;  { +090 draft }
    procedure UnitResearched; virtual;  { +094 draft }
    procedure Update; virtual;  { +098 draft }
    procedure CreateUnitProduction(A1: Integer); virtual;  { +09C draft }
    procedure Activate; virtual;  { +0A0 draft }
    procedure Deactivate; virtual;  { +0A4 draft }
    procedure NewTurn(A1: Integer); virtual;  { +0A8 draft }
    procedure PlayerChanged; virtual;  { +0AC draft }
    procedure CanExecuteProduction(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure DeleteProduction(A1: Integer); virtual;  { +0B4 draft }
    procedure DeleteProductions; virtual;  { +0B8 draft }
    procedure GetProductionName(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure GetProductionNameProgressive(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure UnitProductionGold(A1: Integer); virtual;  { +0C4 draft }
    procedure UnitProductionMana(A1: Integer); virtual;  { +0C8 draft }
    procedure UnitProductionGoldUpkeep(A1: Integer); virtual;  { +0CC draft }
    procedure UnitProductionManaUpkeep(A1: Integer); virtual;  { +0D0 draft }
    procedure UnitProductionTime(A1: Integer); virtual;  { +0D4 draft }
    procedure CanProduceUnit(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0D8 draft }
    procedure ProduceUnitEx(A1: Integer; A2: Integer); virtual;  { +0DC draft }
    procedure ProduceUnit(A1: Integer; A2: Integer); virtual;  { +0E0 draft }
    procedure UnitResearchGold(A1: Integer); virtual;  { +0E4 draft }
    procedure UnitResearchMana; virtual;  { +0E8 draft }
    procedure UnitResearchTime(A1: Integer); virtual;  { +0EC draft }
    procedure CanResearchUnit(A1: Integer; A2: Integer); virtual;  { +0F0 draft }
    procedure ResearchUnit(A1: Integer; A2: Byte); virtual;  { +0F4 draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure GetProduceUnitLevelMax;  { draft }
    procedure GetResearchUnitLevelMax;  { draft }
    procedure RegisterGroupProduction;  { draft }
    procedure UnregisterGroupProduction;  { draft }
    procedure GroupProductionProduced(A1: Integer; A2: Integer);  { draft }
    procedure Produce(A1: Integer; A2: Integer);  { draft }
    procedure RetryProductionExecution(A1: Integer);  { draft }
    procedure SetLoopQueueTo(A1: Integer);  { draft }
    procedure ProductionDone;  { draft }
    procedure FindOptimalResearchProduction(A1: Integer; A2: Integer);  { draft }
  end;

  { TProductionControlList (instance size 16, VMT 5570A8FC) }
  TProductionControlList = class(TList)
  public
    procedure GetPC(A1: Integer);  { draft }
  end;

