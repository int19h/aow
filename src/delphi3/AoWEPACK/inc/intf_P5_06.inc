{ Interface declaration run owned by P5. }
  { TAIPlayerAction (instance size $14, VMT 55717458).
    $08 process cycles, $0C player control, $10 phase. }
  TAIPlayerAction = class(TEObject)
  public
    FProcessCycles: Integer; { $08 }
    FControl: TAIPlayerControl; { $0C }
    FPhase: TAIPlayerProcessPhase; { $10 }
    F_AIPlayerAction_11: array[0..2] of Byte;
    procedure Priority; virtual; abstract;  { +04C draft }
    class function SupportedPhases: TAIPlayerProcessPhases; virtual; { $50 }
    function Setup(Control: TAIPlayerControl; Phase: TAIPlayerProcessPhase): Boolean; virtual; { $54 }
    function Activate: Boolean; virtual; { $58 }
    procedure Deactivate; virtual;  { +05C draft }
    function Process: Boolean; virtual; { $60 }
  end;

  { TAIPlayerActionList (instance size 12, VMT 55717534) }
  TAIPlayerActionList = class(TENode)
  public
    procedure GetActions(A1: Integer);  { draft }
    procedure IndexOf;  { draft }
  end;

  { TAIPlayerActionManager (instance size 12, VMT 5571763C) }
  TAIPlayerActionManager = class(TEObject)
  public
    F_AIPlayerActionManager_08: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetRegisteredClasses(A1: Integer);  { draft }
    procedure RegisterClasses(A1: Integer; A2: Integer);  { draft }
    procedure UnRegisterClasses(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIGroupList (instance size 12, VMT 55717710) }
  TAIGroupList = class(TENode)
  public
    procedure GetGroups(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure FindID;  { draft }
    procedure SortOnProcessPriority;  { draft }
  end;

  { TAIPlayerControl (instance size 40, VMT 5571780C) }
  TAIPlayerControl = class(TEObject)
  public
    FPlayer: TPlayer; { $08 }
    F_AIPlayerControl_0C: Integer;
    F_AIPlayerControl_10: Integer;
    F_AIPlayerControl_14: Integer;
    F_AIPlayerControl_18: Integer;
    F_AIPlayerControl_1C: Integer;
    F_AIPlayerControl_20: Byte;
    F_AIPlayerControl_21: array[0..2] of Byte;
    F_AIPlayerControl_24: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure ListAvailableTransporters(A1: Integer);  { draft }
    procedure UnitIndexToPriority(A1: Integer);  { draft }
    procedure Reset;  { draft }
    procedure SetupProcessPhase(A1: Integer);  { draft }
    procedure GetProcessCyclesMax;  { draft }
    procedure Activate(A1: Integer; A2: Integer);  { draft }
    procedure Deactivate;  { draft }
    procedure GetRandomGroupBehavior;  { draft }
    procedure UpdateSkirmishGroups;  { draft }
    procedure ActivateAction(A1: Integer);  { draft }
    procedure DeactivateAction;  { draft }
    procedure ListPeaceWarUnknownPlayers(Peace, War, Unknown: TByteList);
    procedure ListIdealPeaceWarPlayers(Peace, War: TByteList);
    function CanOfferPeace(Player: Byte): Boolean;
    function CanDeclareWar(Player: Byte): Boolean;
    function CanProposeAlliance(Player: Byte): Boolean;
    procedure Process(A1: Integer);  { draft }
  end;

  { TAIExecuter (instance size 52, VMT 55717968) }
  TAIExecuter = class(TEObject)
  public
    F_AIExecuter_08: Integer;
    F_AIExecuter_0C: Integer;
    F_AIExecuter_10: Byte;
    F_AIExecuter_11: array[0..2] of Byte;
    F_AIExecuter_14: Integer;
    F_AIExecuter_18: Byte;
    F_AIExecuter_19: Byte;
    F_AIExecuter_1A: Byte;
    F_AIExecuter_1B: array[0..0] of Byte;
    F_AIExecuter_1C: Integer;
    F_AIExecuter_20: Integer;
    F_AIExecuter_24: Integer;
    F_AIExecuter_28: Integer;
    F_AIExecuter_2C: Integer;
    F_AIExecuter_30: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure RequestProcessTime(A1: Integer);  { draft }
    procedure GetProcessTimeLeft;  { draft }
    procedure GetProcessTimeElapsed;  { draft }
    procedure UseProcessTime(A1: Integer);  { draft }
    procedure ActivatePlayer(A1: Integer);  { draft }
    procedure DeactivatePlayer(Player: Shortint);
    procedure TokenControlDoneEvent;  { draft }
    procedure Lock;  { draft }
    procedure Unlock;  { draft }
    procedure CaptureTokenCycles(A1: Integer);  { draft }
    procedure TokenCyclesCaptured;  { draft }
    procedure Process(A1: Integer; A2: Integer);  { draft }
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
    F_MoveTarget_0C: array[0..35] of Byte;
    F_MoveTarget_30: Integer;
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
    F_AIMoveTargetSelector_10: Byte;
    F_AIMoveTargetSelector_11: array[0..2] of Byte;
    F_AIMoveTargetSelector_14: Integer;
    F_AIMoveTargetSelector_18: Byte;
    F_AIMoveTargetSelector_19: array[0..2] of Byte;
    F_AIMoveTargetSelector_1C: Integer;
    F_AIMoveTargetSelector_20: Integer;
    F_AIMoveTargetSelector_24: Integer;
    F_AIMoveTargetSelector_28: Integer;
    F_AIMoveTargetSelector_2C: Byte;
    F_AIMoveTargetSelector_2D: Byte;
    F_AIMoveTargetSelector_2E: array[0..253] of Byte;
    F_AIMoveTargetSelector_12C: Integer;
    F_AIMoveTargetSelector_130: Byte;
    F_AIMoveTargetSelector_131: Byte;
    F_AIMoveTargetSelector_132: array[0..9] of Byte;
    F_AIMoveTargetSelector_13C: Byte;
    F_AIMoveTargetSelector_13D: Byte;
    F_AIMoveTargetSelector_13E: array[0..253] of Byte;
    F_AIMoveTargetSelector_23C: Integer;
    F_AIMoveTargetSelector_240: Integer;
    F_AIMoveTargetSelector_244: Integer;
    F_AIMoveTargetSelector_248: Integer;
    F_AIMoveTargetSelector_24C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetTransporter(A1: Integer);  { draft }
    procedure Reset(A1: Integer; A2: Integer);  { draft }
    procedure SetupArmy(A1: Integer; A2: Integer);  { draft }
    procedure SetupTransport(A1: Integer; A2: Byte);  { draft }
    procedure Done;  { draft }
    procedure TriggerTargetFound(A1: Integer; A2: Integer);  { draft }
    procedure ProcessBufferedTargets;  { draft }
    procedure ProcessBufferedTransportTargets(A1: Integer; A2: Integer);  { draft }
    procedure ProcessStates(A1: Integer);  { draft }
    procedure Process(A1: Integer; A2: Integer);  { draft }
    procedure Search(A1: Integer);  { draft }
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
    procedure CreateMove(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); virtual;  { +04C draft }
    procedure CanMoveTo(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer); virtual;  { +050 draft }
    procedure CalculateMoves(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Activate(A1: Integer); virtual;  { +058 draft }
    procedure Deactivate; virtual;  { +05C draft }
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
    F_AIMoveExecuter_24: Byte;
    F_AIMoveExecuter_25: array[0..2] of Byte;
    F_AIMoveExecuter_28: Integer;
    F_AIMoveExecuter_2C: Byte;
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
    procedure Process;  { draft }
    procedure SetupTransporter(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteMove(A1: Byte; A2: Integer; A3: Integer);  { draft }
  end;

  { TEndTurnAIPA (instance size 20, VMT 55718EDC) }
  TEndTurnAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    procedure Priority; override;
    function Process: Boolean; override;
  end;

  { TInitializeAIPA (instance size 20, VMT 55718FB4) }
  TInitializeAIPA = class(TAIPlayerAction)
  public
    procedure Priority; override;
    function Process: Boolean; override;
  end;

  { TGroupControlAIPA (instance size 28, VMT 55719090) }
  TGroupControlAIPA = class(TAIPlayerAction)
  public
    F_GroupControlAIPA_14: Integer;
    F_GroupControlAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    function Process: Boolean; override;
    procedure ActivateGroupControl(A1: Integer);  { draft }
    procedure DeactivateGroupControl;  { draft }
  end;

  { TGroupControlLoopAIPA (instance size 28, VMT 55719170) }
  TGroupControlLoopAIPA = class(TAIPlayerAction)
  public
    F_GroupControlLoopAIPA_14: Integer;
    F_GroupControlLoopAIPA_18: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    class function SupportedPhases: TAIPlayerProcessPhases; override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
    procedure ActivateGroupControl(A1: Integer);  { draft }
    procedure DeactivateGroupControl;  { draft }
  end;

  { TAIBudget (instance size 56, VMT 55719258) }
  TAIBudget = class(TEObject)
  public
    F_AIBudget_08: Integer;
    F_AIBudget_0C: Integer;
    F_AIBudget_10: Integer;
    F_AIBudget_14: Integer;
    F_AIBudget_18: Integer;
    F_AIBudget_1C: Integer;
    F_AIBudget_20: Integer;
    F_AIBudget_24: Integer;
    F_AIBudget_28: Integer;
    F_AIBudget_2C: Integer;
    F_AIBudget_30: Integer;
    F_AIBudget_34: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetReady; virtual;  { +04C draft }
    procedure OutputDebugInfo; virtual;  { +050 draft }
    procedure Done; virtual;  { +054 draft }
    procedure UpdateDayRequirements; virtual;  { +058 draft }
  end;

  { TAISavingsBudget (instance size 56, VMT 55719320) }
  TAISavingsBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAITransporterBudget (instance size 56, VMT 557193F8) }
  TAITransporterBudget = class(TAIBudget)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TAIBudgetList (instance size 12, VMT 557194D8) }
  TAIBudgetList = class(TENode)
  public
    procedure GetBudgets(A1: Integer);  { draft }
  end;

  { TAIBudgetManager (instance size 60, VMT 55719628) }
  TAIBudgetManager = class(TEObject)
  public
    FPlayer: TPlayer; { $08 }
    F_AIBudgetManager_0C: Integer;
    F_AIBudgetManager_10: Integer;
    F_AIBudgetManager_14: Integer;
    F_AIBudgetManager_18: Integer;
    F_AIBudgetManager_1C: Integer;
    F_AIBudgetManager_20: Integer;
    F_AIBudgetManager_24: Integer;
    F_AIBudgetManager_28: Integer;
    F_AIBudgetManager_2C: Integer;
    F_AIBudgetManager_30: Integer;
    F_AIBudgetManager_34: Integer;
    FDefaultBudget: TAIBudget;  { $38; 55785970 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetBudgetGoldUpkeep;  { draft }
    procedure GetBudgetManaUpkeep;  { draft }
    procedure GetReservedBudgetGold;  { draft }
    procedure GetReservedBudgetMana;  { draft }
    procedure GetRequiredBudgetDayGold;  { draft }
    procedure GetRequiredBudgetDayMana;  { draft }
    procedure UpdateBudgetDayRequirements;  { draft }
    procedure UpdateProductionUpkeep;  { draft }
    procedure GetGroupsGoldBudget;  { draft }
    procedure GetGroupsManaBudget;  { draft }
    procedure ReserveForBudgets(A1: Integer; A2: Integer);  { draft }
    procedure ReturnFromBudgets(A1: Integer; A2: Integer);  { draft }
    procedure ValidateReservations;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure ValidateManaUpkeep;  { draft }
    procedure UpdateBudgets;  { draft }
    procedure RequestProductionExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure RequestProductionExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ProductionExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    function RequestBudgetExpense(Gold, Mana: Integer; Budget: TAIBudget; UsePool: Boolean): Boolean;
    function BudgetExpenseMade(Gold, Mana: Integer; Budget: TAIBudget; Mode: TBudgetExpenseMode): Boolean;
    procedure RequestBudgetExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure BudgetExpenseMadeEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);  { draft }
    procedure RequestExpense(A1: Integer; A2: Integer);  { draft }
    procedure ExpenseMade(A1: Integer; A2: Integer);  { draft }
    procedure ReturnExpense(A1: Integer; A2: Integer);  { draft }
  end;

  { TBudgetManagerAIPA (instance size 20, VMT 557196F0) }
  TBudgetManagerAIPA = class(TAIPlayerAction)
  public
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    function Process: Boolean; override;
  end;

  { TAutoProduceAIPA (instance size 40, VMT 557197D4) }
  TAutoProduceAIPA = class(TAIPlayerAction)
  public
    F_AutoProduceAIPA_14: Integer;
    F_AutoProduceAIPA_18: Integer;
    F_AutoProduceAIPA_1C: Integer;
    F_AutoProduceAIPA_20: Integer;
    F_AutoProduceAIPA_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    function Process: Boolean; override;
    procedure UpdateProductions(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteProduce(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteResearch(A1: Integer; A2: Integer);  { draft }
    procedure TransporterPriority;  { draft }
    procedure ResearchTransporter(A1: Integer);  { draft }
    procedure ProduceTransporter(A1: Integer);  { draft }
    procedure FindAvailableTransporter;  { draft }
    procedure TransporterProductionControlExists;  { draft }
    procedure ProducingTransporter;  { draft }
    procedure ResearchingTransporter;  { draft }
  end;

  { TProcessEventlogAIPA (instance size 24, VMT 557198B4) }
  TProcessEventlogAIPA = class(TAIPlayerAction)
  public
    F_ProcessEventlogAIPA_14: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    function Process: Boolean; override;
  end;

