{ Interface declaration run owned by P5. }
  { TAIPlayerAction (instance size $14, VMT 55717458).
    $08 process cycles, $0C player control, $10 phase. }
  TAIPlayerAction = class(TEObject)
  public
    FProcessCycles: Integer; { $08 }
    FControl: TAIPlayerControl; { $0C }
    FPhase: TAIPlayerProcessPhase; { $10 }
    F_AIPlayerAction_11: array[0..2] of Byte;
    class function Priority: Integer; virtual; abstract;  { $4C }
    class function SupportedPhases: TAIPlayerProcessPhases; virtual; { $50 }
    function Setup(Control: TAIPlayerControl; Phase: TAIPlayerProcessPhase): Boolean; virtual; { $54 }
    function Activate: Boolean; virtual; { $58 }
    procedure Deactivate; virtual; { $5C }
    function Process: Boolean; virtual; { $60 }
  end;

  TAIPlayerActionClass = class of TAIPlayerAction;

  { TAIPlayerActionList (instance size $0C, VMT 55717534). $08 children. }
  TAIPlayerActionList = class(TENode)
  public
    function GetActions(Index: Integer): TAIPlayerAction;
    function IndexOf(Action: TAIPlayerAction): Integer;
  end;

  { TAIPlayerActionManager (instance size $0C, VMT 5571763C). $08 registered classes. }
  TAIPlayerActionManager = class(TEObject)
  public
    FRegisteredClasses: TList; { $08 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCount: Integer;
    function GetRegisteredClasses(Index: Integer): TAIPlayerActionClass;
    procedure RegisterClasses(Classes: array of TAIPlayerActionClass);
    procedure UnRegisterClasses(Classes: array of TAIPlayerActionClass);
  end;

  { TAIGroupList (instance size $0C, VMT 55717710). $08 children. }
  TAIGroupList = class(TENode)
  public
    function GetGroups(Index: Integer): TAIGroup;
    function IndexOfID(ID: Integer): Integer;
    function FindID(ID: Integer): TAIGroup;
    procedure SortOnProcessPriority;
  end;

  { TAIPlayerControl (instance size $28, VMT 5571780C).
    $08 player, $0C actions, $10 action, $14 action index, $18 cycles,
    $1C move executer, $20 phase, $24 progress. }
  TAIPlayerControl = class(TEObject)
  public
    FPlayer: TPlayer; { $08 }
    FActions: TAIPlayerActionList; { $0C }
    FAction: TAIPlayerAction; { $10 }
    FActionIndex: Integer; { $14 }
    FProcessCyclesMax: Integer; { $18 }
    FMoveExecuter: TAIMoveExecuter; { $1C }
    FPhase: TAIPlayerProcessPhase; { $20 }
    F_AIPlayerControl_21: array[0..2] of Byte;
    FDefenseStrengthMultiplier: Single; { $24 }
    { conflict: FProgress: Single; }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function ListAvailableTransporters(Units: TUnitList): Integer;
    function UnitIndexToPriority(UnitIndex: Integer): Integer;
    procedure Reset;
    procedure SetupProcessPhase(Phase: TAIPlayerProcessPhase);
    function GetProcessCyclesMax: Integer;
    procedure Activate(Executer: TAIExecuter);
    procedure Deactivate;
    function GetRandomGroupBehavior: TGroupBehavior;
    procedure UpdateSkirmishGroups;
    function ActivateAction(Index: Integer): Boolean;
    procedure DeactivateAction;
    procedure ListPeaceWarUnknownPlayers(Peace, War, Unknown: TByteList);
    procedure ListIdealPeaceWarPlayers(Peace, War: TByteList);
    function CanOfferPeace(Player: Byte): Boolean;
    function CanDeclareWar(Player: Byte): Boolean;
    function CanProposeAlliance(Player: Byte): Boolean;
    function Process(Executer: TAIExecuter; TokenControlDone: Boolean): Boolean;
  end;

  { TAIExecuter (instance size $34, VMT 55717968).
    $08 cycles, $0C players, $10 current player, $14 player cycles, $18 status,
    $19 token done, $1A time mode, $1C time, $20 used time, $24 start,
    $28 token cycles, $2C token cycle, $30 lock count. }
  TAIExecuter = class(TEObject)
  public
    FProcessCycles: Integer; { $08 }
    FPlayers: TByteList; { $0C }
    FPlayer: Shortint; { $10 }
    F_AIExecuter_11: array[0..2] of Byte;
    FPlayerProcessCycles: Integer; { $14 }
    FStatus: TAIExecuterStatus; { $18 }
    FTokenControlDone: Boolean; { $19 }
    FProcessTimeMode: TProcessTimeMode; { $1A }
    F_AIExecuter_1B: array[0..0] of Byte;
    FProcessTime: Integer; { $1C }
    FProcessTimeUsed: Integer; { $20 }
    FProcessStarted: Integer; { $24 }
    FTokenCycles: Integer; { $28 }
    FTokenCycle: Integer; { $2C }
    FLockCount: Integer; { $30 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function RequestProcessTime(Time: Integer): Boolean;
    function GetProcessTimeLeft: Integer;
    function GetProcessTimeElapsed: Integer;
    procedure UseProcessTime(Time: Integer);
    function ActivatePlayer(Player: Shortint): Boolean;
    procedure DeactivatePlayer(Player: Shortint);
    procedure TokenControlDoneEvent(Sender: TObject);
    procedure Lock;
    procedure Unlock;
    procedure CaptureTokenCycles(Cycles: Integer);
    procedure TokenCyclesCaptured;
    procedure Process;
  end;

  { TAIMoveControlSettings (instance size 360, VMT 55717A78) }
  TAIMoveControlSettings = class(TEObject)
  public
    F_AIMoveControlSettings_08: Integer;
    F_AIMoveControlSettings_0C: Byte;
    F_AIMoveControlSettings_0D: array[0..2] of Byte;
    F_AIMoveControlSettings_10: Integer;
    F_AIMoveControlSettings_14: Integer;
    F_AIMoveControlSettings_18: Integer;
    F_AIMoveControlSettings_1C: Integer;
    F_AIMoveControlSettings_20: Integer;
    F_AIMoveControlSettings_24: Integer;
    F_AIMoveControlSettings_28: Byte;
    F_AIMoveControlSettings_29: array[0..254] of Byte;
    F_AIMoveControlSettings_128: Byte;
    F_AIMoveControlSettings_129: array[0..2] of Byte;
    F_AIMoveControlSettings_12C: Byte;
    F_AIMoveControlSettings_12D: array[0..2] of Byte;
    F_AIMoveControlSettings_130: Integer;
    F_AIMoveControlSettings_134: Integer;
    F_AIMoveControlSettings_138: Integer;
    F_AIMoveControlSettings_13C: Byte;
    F_AIMoveControlSettings_13D: array[0..2] of Byte;
    F_AIMoveControlSettings_140: Byte;
    F_AIMoveControlSettings_141: array[0..2] of Byte;
    F_AIMoveControlSettings_144: Integer;
    F_AIMoveControlSettings_148: Integer;
    F_AIMoveControlSettings_14C: array[0..3] of Byte;
    F_AIMoveControlSettings_150: Integer;
    F_AIMoveControlSettings_154: Integer;
    F_AIMoveControlSettings_158: Byte;
    F_AIMoveControlSettings_159: array[0..2] of Byte;
    F_AIMoveControlSettings_15C: Byte;
    F_AIMoveControlSettings_15D: array[0..2] of Byte;
    F_AIMoveControlSettings_160: Byte;
    F_AIMoveControlSettings_161: array[0..3] of Byte;
    F_AIMoveControlSettings_165: Byte;
    F_AIMoveControlSettings_166: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetSourcePos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TAIMoveControl (instance size 544, VMT 55717B94) }
  TAIMoveControl = class(TEObject)
  public
    F_AIMoveControl_08: Byte;
    F_AIMoveControl_09: array[0..2] of Byte;
    F_AIMoveControl_0C: Integer;
    F_AIMoveControl_10: Integer;
    F_AIMoveControl_14: Byte;
    F_AIMoveControl_15: Byte;
    F_AIMoveControl_16: array[0..253] of Byte;
    F_AIMoveControl_114: Byte;
    F_AIMoveControl_115: Byte;
    F_AIMoveControl_116: array[0..253] of Byte;
    F_AIMoveControl_214: Byte;
    F_AIMoveControl_215: Byte;
    F_AIMoveControl_216: array[0..1] of Byte;
    F_AIMoveControl_218: Integer;
    F_AIMoveControl_21C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ProcessingDone(A1: Byte);  { draft }
    procedure ProcessCanMove;  { draft }
    procedure SelectCombinedTransporterArmyMpT(A1: Integer);  { draft }
    procedure CalculateTransportGaps(A1: Integer; A2: Integer);  { draft }
    procedure ProcessTransporterCanMove(A1: Integer; A2: Integer);  { draft }
    procedure Initialize(A1: Integer);  { draft }
    procedure CanMove(A1: Integer);  { draft }
    procedure Cancel;  { draft }
    procedure Reset;  { draft }
    procedure Process;  { draft }
  end;

  { TMoveTarget (instance size 52, VMT 55717C58) }
  TMoveTarget = class(TEObject)
  public
    F_MoveTarget_08: Integer;
    FData: TAITargetData; FLocation: TXYL; FMovePoints, FTransporterID: Integer; { $0C/$24/$28/$2C; 557D77BB }
    FMovepath: TMovepath; { $30; 557D77EA }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TMoveTargetList (instance size 12, VMT 55717D14) }
  TMoveTargetList = class(TEReferenceNode)
  public
    procedure GetTarget(A1: Integer);  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
    procedure AddTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
  end;

  { TAIMoveTargetSelector (instance size 592, VMT 55717F10) }
  TAIMoveTargetSelector = class(TEObject)
  public
    F_AIMoveTargetSelector_08: Integer;
    F_AIMoveTargetSelector_0C: Integer;
    FStatus: TAIMoveTargetSelectorStatus; { $10; 557D790E }
    F_AIMoveTargetSelector_11: array[0..2] of Byte;
    F_AIMoveTargetSelector_14: Integer;
    FMode: TAIMoveTargetSelectorMode; { $18; 5573A32B }
    F_AIMoveTargetSelector_19: array[0..2] of Byte;
    F_AIMoveTargetSelector_1C: Integer;
    FOnTargetFound: TMoveTargetFoundEvent; { $20; 557D7656 }
    F_AIMoveTargetSelector_28: Integer;
    F_AIMoveTargetSelector_2C: Byte;
    F_AIMoveTargetSelector_2D: Byte;
    F_AIMoveTargetSelector_2E: array[0..253] of Byte;
    FSourceLocation: TXYL; { $12C; 557D7838 }
    FTargetInfo: TAITargetInfo; { $130; 557D779E }
    FMovePointTable: TMovePointTable; { $13C; 557D783F }
    FMovePointsMax: Integer; { $23C; 557D7660 }
    FMovePointsMin: Integer; { $240; 557D766C }
    F_AIMoveTargetSelector_244: Integer;
    FUnits: TUnitUserList; { $248; 5573A2E6 }
    F_AIMoveTargetSelector_24C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetTransporter(A1: Integer);  { draft }
    procedure Reset;
    procedure SetupArmy(A1: Integer; A2: Integer);  { draft }
    procedure SetupTransport(A1: Integer; A2: Byte);  { draft }
    procedure Done;  { draft }
    procedure TriggerTargetFound(A1: Integer; A2: Integer);  { draft }
    procedure ProcessBufferedTargets;  { draft }
    procedure ProcessBufferedTransportTargets(A1: Integer; A2: Integer);  { draft }
    procedure ProcessStates(A1: Integer);  { draft }
    function Process: Boolean;
    procedure Search(A1: TAIGroupControl);
  end;

  { TAIMoveExecuterUnit (instance size 56, VMT 5571819C) }
  TAIMoveExecuterUnit = class(TEObject)
  public
    F_AIMoveExecuterUnit_08: Integer;
    F_AIMoveExecuterUnit_0C: Integer;
    F_AIMoveExecuterUnit_10: Byte;
    F_AIMoveExecuterUnit_11: Byte;
    F_AIMoveExecuterUnit_12: Byte;
    F_AIMoveExecuterUnit_13: Byte;
    F_AIMoveExecuterUnit_14: Byte;
    F_AIMoveExecuterUnit_15: Byte;
    F_AIMoveExecuterUnit_16: Byte;
    F_AIMoveExecuterUnit_17: Byte;
    F_AIMoveExecuterUnit_18: Byte;
    F_AIMoveExecuterUnit_19: Byte;
    F_AIMoveExecuterUnit_1A: Byte;
    F_AIMoveExecuterUnit_1B: Byte;
    F_AIMoveExecuterUnit_1C: array[0..7] of Byte;
    F_AIMoveExecuterUnit_24: Byte;
    F_AIMoveExecuterUnit_25: array[0..2] of Byte;
    F_AIMoveExecuterUnit_28: Byte;
    F_AIMoveExecuterUnit_29: array[0..2] of Byte;
    F_AIMoveExecuterUnit_2C: Byte;
    F_AIMoveExecuterUnit_2D: array[0..2] of Byte;
    F_AIMoveExecuterUnit_30: Byte;
    F_AIMoveExecuterUnit_31: array[0..2] of Byte;
    F_AIMoveExecuterUnit_34: Byte;
    F_AIMoveExecuterUnit_35: Byte;
    F_AIMoveExecuterUnit_36: array[0..1] of Byte;
    procedure Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure Validate;  { draft }
    procedure ResetTransporterSettings;  { draft }
  end;

  { TAIMoveExecuterUnitList (instance size 12, VMT 55718268) }
  TAIMoveExecuterUnitList = class(TENode)
  public
    procedure GetUnits(A1: Integer);  { draft }
    procedure IndexOfUnitID(A1: Integer);  { draft }
    procedure IndexOfUnit(A1: Integer);  { draft }
    procedure FindStatusUnit(A1: Integer);  { draft }
    procedure ValidateSelection(A1: Byte);  { draft }
    procedure SelectionCount;  { draft }
    procedure Transporter(A1: Integer; A2: Integer);  { draft }
    procedure SetMoveResult(A1: Integer; A2: Integer);  { draft }
    procedure SetTransportStatus(A1: Integer; A2: Integer);  { draft }
    procedure SetStatus(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIMoveExecuterArmy (instance size 48, VMT 55718378) }
  TAIMoveExecuterArmy = class(TAIMoveExecuterUnitList)
  public
    F_AIMoveExecuterArmy_0C: Integer;
    F_AIMoveExecuterArmy_10: Integer;
    F_AIMoveExecuterArmy_14: Byte;
    F_AIMoveExecuterArmy_15: array[0..2] of Byte;
    F_AIMoveExecuterArmy_18: Integer;
    F_AIMoveExecuterArmy_1C: Integer;
    F_AIMoveExecuterArmy_20: Integer;
    F_AIMoveExecuterArmy_24: Integer;
    F_AIMoveExecuterArmy_28: Byte;
    F_AIMoveExecuterArmy_29: Byte;
    F_AIMoveExecuterArmy_2A: array[0..5] of Byte;
    procedure Setup(A1: Integer);  { draft }
    procedure CanAdd(A1: Integer);  { draft }
    procedure RetrieveArmy(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ResetTransporterSettings;  { draft }
    procedure WaitingForTransport;  { draft }
    procedure Moves(A1: Integer; A2: Integer);  { draft }
    procedure MovePoints(A1: Integer; A2: Integer);  { draft }
    procedure ValidTerrain(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { TAIMoveExecuterArmyList (instance size 12, VMT 55718480) }
  TAIMoveExecuterArmyList = class(TENode)
  public
    procedure GetArmies(A1: Integer);  { draft }
    procedure IndexOf(A1: Integer; A2: Byte);  { draft }
    procedure IndexOfXYL(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure IndexOfLoc(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfTransportStatus(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
  end;

  { TAIMoveExecuterMove (instance size 32, VMT 55718590) }
  TAIMoveExecuterMove = class(TAIMoveExecuterUnitList)
  public
    F_AIMoveExecuterMove_0C: Integer;
    F_AIMoveExecuterMove_10: Integer;
    F_AIMoveExecuterMove_14: Integer;
    F_AIMoveExecuterMove_18: Byte;
    F_AIMoveExecuterMove_19: Byte;
    F_AIMoveExecuterMove_1A: Byte;
    F_AIMoveExecuterMove_1B: Byte;
    F_AIMoveExecuterMove_1C: Byte;
    F_AIMoveExecuterMove_1D: Byte;
    F_AIMoveExecuterMove_1E: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddUnits(A1: Integer; A2: Integer);  { draft }
    procedure AddUnit;  { draft }
    procedure SetUnitStatus(A1: Integer);  { draft }
    procedure RetrieveArmy(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIMoveExecuterMoveQueue (instance size 12, VMT 55718698) }
  TAIMoveExecuterMoveQueue = class(TENode)
  public
    procedure Clear; override;
    procedure GetMoves(A1: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIMoveExecuterControl (instance size 20, VMT 55718868) }
  TAIMoveExecuterControl = class(TEObject)
  public
    F_AIMoveExecuterControl_08: Integer;
    F_AIMoveExecuterControl_0C: Integer;
    F_AIMoveExecuterControl_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateMove(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { $4C }
    procedure CanMoveTo(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer); virtual;  { +050 draft }
    procedure CalculateMoves(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Activate(A1: Integer); virtual;  { +058 draft }
    procedure Deactivate; virtual; { $5C }
    procedure Done; virtual;  { +060 draft }
    procedure Process; virtual;  { +064 draft }
  end;

  { TDefaultMEC (instance size 20, VMT 55718958) }
  TDefaultMEC = class(TAIMoveExecuterControl)
  public
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
  end;

  { TAdjacentArmy (instance size 24, VMT 55718A30) }
  TAdjacentArmy = class(TEObject)
  public
    F_AdjacentArmy_08: array[0..3] of Byte;
    F_AdjacentArmy_0C: Integer;
    F_AdjacentArmy_10: array[0..3] of Byte;
    F_AdjacentArmy_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMovementDays;  { draft }
  end;

  { TAdjacentArmyList (instance size 12, VMT 55718AF0) }
  TAdjacentArmyList = class(TENode)
  public
    procedure GetAdjacentArmies(A1: Integer);  { draft }
    procedure IndexOfLoc(A1: Integer; A2: Integer);  { draft }
    procedure GetSlowestArmy;  { draft }
    procedure GetAdjacent;  { draft }
  end;

  { TAdjacentMEC (instance size 28, VMT 55718BF4) }
  TAdjacentMEC = class(TAIMoveExecuterControl)
  public
    F_AdjacentMEC_14: Integer;
    F_AdjacentMEC_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
    procedure ExecuteSurroundMove;  { draft }
    procedure CalculateMeetingPoint;  { draft }
    procedure ExecuteMeetingPointMove;  { draft }
  end;

  { TTransportMEC (instance size 24, VMT 55718CD0) }
  TTransportMEC = class(TAIMoveExecuterControl)
  public
    F_TransportMEC_14: Integer;
    procedure CalculateMoves(A1: Integer; A2: Integer); override;
    procedure Done; override;
    procedure CreateTransporterMove(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure TransportDone;  { draft }
    procedure DumpTransportUnits(A1: Integer);  { draft }
    procedure UpdateTransportMeetingPoint;  { draft }
    procedure CalculateTransportPathCallBack;  { draft }
  end;

  { TAIMoveExecuter (instance size 60, VMT 55718E18) }
  TAIMoveExecuter = class(TEObject)
  public
    F_AIMoveExecuter_08: Integer;
    F_AIMoveExecuter_0C: Integer;
    F_AIMoveExecuter_10: Integer;
    F_AIMoveExecuter_14: Integer;
    F_AIMoveExecuter_18: Integer;
    F_AIMoveExecuter_1C: Integer;
    F_AIMoveExecuter_20: Integer;
    FMode: TAIMoveExecuterMode; { $24; 557D7981 }
    F_AIMoveExecuter_25: array[0..2] of Byte;
    F_AIMoveExecuter_28: Integer;
    FStatus: TAIMoveExecuterStatus; { $2C }
    F_AIMoveExecuter_2D: Byte;
    F_AIMoveExecuter_2E: array[0..1] of Byte;
    F_AIMoveExecuter_30: Integer;
    F_AIMoveExecuter_34: Integer;
    F_AIMoveExecuter_38: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ActivateMEC(A1: Integer);  { draft }
    procedure DeactivateMEC;  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddArmy(A1: Integer; A2: Integer);  { draft }
    procedure AddTransporter(A1: Integer; A2: Integer);  { draft }
    procedure InvalidateMove;  { draft }
    procedure Reset;  { draft }
    procedure Validate;  { draft }
    procedure CreateArmies(A1: Byte);  { draft }
    procedure FinishMoves;  { draft }
    procedure ExecuteMoves;  { draft }
    procedure UnitsMoveDone;  { draft }
    procedure GetTransporting;  { draft }
    procedure UpdateMoveResult;  { draft }
    procedure ProcessExecuteMoves;  { draft }
    procedure ProcessMECS;  { draft }
    function Process: Boolean;
    procedure SetupTransporter(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteMove(A1: Byte; A2: Integer; A3: Integer);  { draft }
  end;

  { TEndTurnAIPA (instance size 20, VMT 55718EDC) }
  TEndTurnAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    class function Priority: Integer; override;
    function Process: Boolean; override;
  end;

  { TInitializeAIPA (instance size 20, VMT 55718FB4) }
  TInitializeAIPA = class(TAIPlayerAction)
  public
    class function Priority: Integer; override;
    function Process: Boolean; override;
  end;

  { TGroupControlAIPA (instance size $1C). $14 group cycles, $18 group control. }
  TGroupControlAIPA = class(TAIPlayerAction)
  public
    FGroupProcessCycles: Integer; { $14 }
    FGroupControl: TAIGroupControl; { $18 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    function Process: Boolean; override;
    procedure ActivateGroupControl(Group: TAIGroup);
    procedure DeactivateGroupControl;
  end;

  { TGroupControlLoopAIPA (instance size $1C). $14 group cycles, $18 group control. }
  TGroupControlLoopAIPA = class(TAIPlayerAction)
  public
    FGroupProcessCycles: Integer; { $14 }
    FGroupControl: TAIGroupControl; { $18 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    class function SupportedPhases: TAIPlayerProcessPhases; override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
    procedure ActivateGroupControl(Group: TAIGroup);
    procedure DeactivateGroupControl;
  end;

  { TAIBudget (instance size $38, VMT 55719258).
    $08 priority, $0C/$10 required gold/mana, $14/$18 upkeep, $1C days,
    $20/$24 daily limits, $28/$2C daily requirements, $30/$34 gold/mana. }
  TAIBudget = class(TEObject)
  public
    FPriority: Integer; { $08 }
    FRequiredGold: Integer; { $0C }
    FRequiredMana: Integer; { $10 }
    FGoldUpkeep: Integer; { $14 }
    FManaUpkeep: Integer; { $18 }
    FDays: Integer; { $1C }
    { conflict: FPriority: Integer; }
    FDayGoldMax: Integer; { $20 }
    FDayManaMax: Integer; { $24 }
    FDayGold: Integer; { $28 }
    FDayMana: Integer; { $2C }
    FGold: Integer; { $30 }
    FMana: Integer; { $34 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetReady: Boolean; virtual; { $4C }
    procedure OutputDebugInfo; virtual; { $50 }
    procedure Done; virtual; { $54 }
    procedure UpdateDayRequirements; virtual; { $58 }
  end;

  { TAISavingsBudget (instance size $38, VMT 55719320). Uses TAIBudget fields. }
  TAISavingsBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAITransporterBudget (instance size $38, VMT 557193F8). Uses TAIBudget fields. }
  TAITransporterBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAIBudgetList (instance size 12, VMT 557194D8) }
  TAIBudgetList = class(TENode)
  public
    function GetBudgets(Index: Integer): TAIBudget;
  end;

  { TAIBudgetManager (instance size $3C, VMT 55719628). $08 player, $0C budgets,
    $10..$1C income/reserve factors, $20/$24 production upkeep,
    $28/$2C available upkeep, $30/$34 pool, $38 savings budget. }
  TAIBudgetManager = class(TEObject)
  public
    FPlayer: TPlayer; { $08 }
    FBudgets: TAIBudgetList; { $0C }
    { conflict: FBudgets: TENode; }
    FGoldIncomeFactor: Single; { $10 }
    FManaIncomeFactor: Single; { $14 }
    FGoldReserveFactor: Single; { $18 }
    FManaReserveFactor: Single; { $1C }
    FProductionGoldUpkeep: Integer; { $20 }
    FProductionManaUpkeep: Integer; { $24 }
    FGoldUpkeep: Integer; { $28 }
    FManaUpkeep: Integer; { $2C }
    FGold: Integer; { $30 }
    FMana: Integer; { $34 }
    FDefaultBudget: TAIBudget;  { $38; 55785970 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetBudgetGoldUpkeep: Integer;
    function GetBudgetManaUpkeep: Integer;
    function GetReservedBudgetGold: Integer;
    function GetReservedBudgetMana: Integer;
    function GetRequiredBudgetDayGold: Integer;
    function GetRequiredBudgetDayMana: Integer;
    procedure UpdateBudgetDayRequirements;
    procedure UpdateProductionUpkeep;
    function GetGroupsGoldBudget: Integer;
    function GetGroupsManaBudget: Integer;
    procedure ReserveForBudgets(Gold, Mana: Integer);
    procedure ReturnFromBudgets(Gold, Mana: Integer);
    procedure ValidateReservations;
    procedure OutputDebugInfo;
    procedure ValidateManaUpkeep;
    procedure UpdateBudgets;
    function RequestProductionExpense(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer): Boolean;
    function RequestProductionExpenseEx(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer; Budget: TAIBudget): Boolean;
    function ProductionExpenseMade(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer): Boolean;
    function RequestBudgetExpense(Gold, Mana: Integer; Budget: TAIBudget; UsePool: Boolean): Boolean;
    function BudgetExpenseMade(Gold, Mana: Integer; Budget: TAIBudget; Mode: TBudgetExpenseMode): Boolean;
    function RequestBudgetExpenseEx(Gold, Mana, GoldUpkeep, ManaUpkeep: Integer; Budget: TAIBudget; UsePool: Boolean): Boolean;
    function BudgetExpenseMadeEx(Gold, Mana, GoldUpkeep, ManaUpkeep: Integer; Budget: TAIBudget; Mode: TBudgetExpenseMode): Boolean;
    function RequestExpense(Gold, Mana: Integer): Boolean;
    function ExpenseMade(Gold, Mana: Integer): Boolean;
    function ReturnExpense(Gold, Mana: Integer): Boolean;
  end;

  { TBudgetManagerAIPA (instance size $14, VMT 557196F0). No new fields. }
  TBudgetManagerAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    function Process: Boolean; override;
  end;

  { TAutoProduceAIPA (instance size $28, VMT 557197D4).
    $14 production index, $18 state, $1C gold upkeep, $20 mana upkeep, $24 productions. }
  TAutoProduceAIPA = class(TAIPlayerAction)
  public
    FProductionIndex: Integer; { $14 }
    FState: Integer; { $18 }
    FGoldUpkeep: Integer; { $1C }
    FManaUpkeep: Integer; { $20 }
    FProductions: TQuadItemList; { $24 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    function Process: Boolean; override;
    procedure UpdateProductions(Control: TProductionControl);
    function ExecuteProduce(Control: TProductionControl; Index: Integer): Boolean;
    function ExecuteResearch(Control: TProductionControl; Index: Integer): Boolean;
    function TransporterPriority(UnitIndex: Integer): Integer;
    function ResearchTransporter(Budget: TAIBudget): Boolean;
    function ProduceTransporter(Budget: TAIBudget): Boolean;
    function FindAvailableTransporter: TAbstractUnit;
    function TransporterProductionControlExists: Boolean;
    function ProducingTransporter: Boolean;
    function ResearchingTransporter: Boolean;
  end;

  { TProcessEventlogAIPA (instance size $18, VMT 557198B4). $14 log index. }
  TProcessEventlogAIPA = class(TAIPlayerAction)
  public
    FLogIndex: Integer; { $14 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function Priority: Integer; override;
    function Process: Boolean; override;
  end;

