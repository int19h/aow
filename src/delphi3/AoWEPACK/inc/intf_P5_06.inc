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

  { TAIMoveControlSettings: instance size $168, VMT 55717A78.
    $08 references, $0C player, $10..$18 source, $1C..$24 destination,
    $28 move table, $128 completion event, $130 transporter,
    $134/$138 search limits, $13C mode, $140 army, $144 selection,
    $148 cycles, $14C status, $150 cost, $154 path, $158..$164 transport locations. }
  TAIMoveControlSettings = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FPlayer: Shortint; { $0C }
    F_AIMoveControlSettings_0D: array[0..2] of Byte;
    FSourceX, FSourceY, FSourceL: Integer; { $10..$18 }
    FDestinationX, FDestinationY, FDestinationL: Integer; { $1C..$24 }
    FMovePointTable: TMovePointTable; { $28 }
    FOnDone: TNotifyEvent; { $128 }
    FTransporter: TAbstractUnit; { $130 }
    FMovePointsMax: Integer; { $134 }
    FQuickMovePointsMax: Integer; { $138 }
    FMoveMode: TMoveMode; { $13C }
    F_AIMoveControlSettings_13D: array[0..2] of Byte;
    FArmyHS: TArmyHS; { $140 }
    FSelection: Integer; { $144 }
    FProcessCycles: Integer; { $148 }
    FStatus: TAIMoveControlStatus; { $14C }
    F_AIMoveControlSettings_14D: array[0..2] of Byte;
    FMovePoints: Integer; { $150 }
    FTransportPath: TMovepath; { $154 }
    FBoardingPoint: TXYL; { $158 }
    FArrivalPoint: TXYL; { $15C }
    FTransportSource: TXYL; { $160 }
    FTransportDestination: TXYL; { $164 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure SetSourcePos(X, Y, L: Integer);
    procedure SetDestinationPos(X, Y, L: Integer);
    procedure Setup(Army: TArmyHS; Selection: Byte; X, Y, L: Integer);
  end;

  { TAIMoveControl: instance size $220; $08 status, $0C settings, $10 cycles,
    $14 army table, $114 transporter table, $214 multiple gaps, $215 mode,
    $218 search state, $21C path settings. }
  TAIMoveControl = class(TEObject)
  public
    FStatus: TAIMoveControlStatus; { $08 }
    F_AIMoveControl_09: array[0..2] of Byte;
    FSettings: TAIMoveControlSettings; { $0C }
    FProcessCycles: Integer; { $10 }
    FMovePointTable: TMovePointTable; { $14 }
    FTransportMovePointTable: TMovePointTable; { $114 }
    FMultipleTransportGaps: Boolean; { $214 }
    FMode: TAIMoveControlMode; { $215 }
    F_AIMoveControl_216: array[0..1] of Byte;
    FState: Integer; { $218 }
    FPathSettings: TMoveControlSettings; { $21C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ProcessingDone(Status: TAIMoveControlStatus);
    procedure ProcessCanMove;
    procedure SelectCombinedTransporterArmyMpT;
    function CalculateTransportGaps(Path: TMovepath; const Table: TMovePointTable): Boolean;
    procedure ProcessTransporterCanMove;
    procedure Initialize(Settings: TAIMoveControlSettings);
    function CanMove(Settings: TAIMoveControlSettings): Boolean;
    procedure Cancel;
    procedure Reset;
    function Process: Boolean;
  end;

  { TMoveTarget: instance size $34; $08 references, $0C target data,
    $24 location, $28 move points, $2C transporter ID, $30 path. }
  TMoveTarget = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FData: TAITargetData; { $0C }
    FLocation: TXYL; { $24 }
    FMovePoints, FTransporterID: Integer; { $28/$2C }
    FMovepath: TMovepath; { $30 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TMoveTargetList: instance size $0C; $08 reference children. }
  TMoveTargetList = class(TEReferenceNode)
  public
    function GetTarget(Index: Integer): TMoveTarget;
    function IndexOfXYL(Location: Integer): Integer;
    procedure AddTargetEx(Location: Integer; MovePoints, TransporterID: Integer; const Data: TAITargetData);
    procedure SortOnMovePoints;
  end;

  { TAIMoveTargetSelector (instance size $250). $08 state, $0C targets,
    $14 settings, $1C buffer, $2C transporter movement table, $244 transporter, $24C control. }
  TAIMoveTargetSelector = class(TEObject)
  public
    FState: Integer; { $08 }
    FTargets: TMoveTargetList; { $0C }
    FStatus: TAIMoveTargetSelectorStatus; { $10; 557D790E }
    F_AIMoveTargetSelector_11: array[0..2] of Byte;
    FSettings: TMoveControlSettings; { $14 }
    FMode: TAIMoveTargetSelectorMode; { $18; 5573A32B }
    F_AIMoveTargetSelector_19: array[0..2] of Byte;
    FBufferedTargets: TMoveTargetList; { $1C }
    FOnTargetFound: TMoveTargetFoundEvent; { $20; 557D7656 }
    FProcessCycles: Integer; { $28 }
    FTransportMovePointTable: TMovePointTable; { $2C }
    FSourceLocation: TXYL; { $12C; 557D7838 }
    FTargetInfo: TAITargetInfo; { $130; 557D779E }
    FMovePointTable: TMovePointTable; { $13C; 557D783F }
    FMovePointsMax: Integer; { $23C; 557D7660 }
    FMovePointsMin: Integer; { $240; 557D766C }
    FTransporter: TAbstractUnit; { $244 }
    FUnits: TUnitUserList; { $248; 5573A2E6 }
    FControl: TAIGroupControl; { $24C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetTransporter(Transporter: TAbstractUnit);
    procedure Reset;
    function SetupArmy(Army: TArmyHS; Selection: Byte): Boolean;
    procedure SetupTransport(Transporter: TAbstractUnit; ResetSettings: Boolean);
    procedure Done;
    procedure TriggerTargetFound(Target: TMoveTarget);
    function ProcessBufferedTargets: Boolean;
    function ProcessBufferedTransportTargets: Boolean;
    function ProcessStates: Boolean;
    function Process: Boolean;
    function Search(Control: TAIGroupControl): Boolean;
  end;

  { TAIMoveExecuterUnit: instance size $38; $08 unit, $0C ID, $10 location,
    $14 origin, $18 destination, $1C transporter ID, $20 transport status,
    $24..$30 transport points, $34 status, $35 move result. }
  TAIMoveExecuterUnit = class(TEObject)
  public
    FUnit: TAbstractUnit; { $08 }
    FUnitID: Integer; { $0C }
    FLocation: TXYL; { $10 }
    FOrigin: TXYL; { $14 }
    FDestination: TXYL; { $18 }
    FTransporterID: Integer; { $1C }
    FTransportStatus: TAIMoveExecuterTransportStatus; { $20 }
    FTransportPadding: array[0..2] of Byte;
    FBoardingPoint: TXYL; { $24 }
    FArrivalPoint: TXYL; { $28 }
    FTransportSource: TXYL; { $2C }
    FTransportDestination: TXYL; { $30 }
    FStatus: TAIMoveExecuterUnitStatus; { $34 }
    FMoveResult: Byte; { $35 }
    F_AIMoveExecuterUnit_36: array[0..1] of Byte;
    procedure Initialize(AUnit: TAbstractUnit; X, Y, L: Shortint);
    function Validate: Boolean;
    procedure ResetTransporterSettings;
  end;

  { TAIMoveExecuterUnitList: instance size $0C; $08 children. }
  TAIMoveExecuterUnitList = class(TENode)
  public
    function GetUnits(Index: Integer): TAIMoveExecuterUnit;
    function IndexOfUnitID(ID: Integer): Integer;
    function IndexOfUnit(AUnit: TAbstractUnit): Integer;
    function FindStatusUnit(Status: TAIMoveExecuterUnitStatus): Integer;
    function ValidateSelection(Selection: Byte): Byte;
    function SelectionCount(Selection: Byte): Integer;
    function Transporter(Selection: Byte): TAIMoveExecuterUnit;
    procedure SetMoveResult(Selection, MoveResult: Byte);
    procedure SetTransportStatus(Selection: Byte; Status: TAIMoveExecuterTransportStatus);
    procedure SetStatus(Selection: Byte; Status: TAIMoveExecuterUnitStatus);
  end;

  { TAIMoveExecuterArmy: instance size $30; $0C location, $10 destination,
    $14 transport status, $18..$24 transport points, $28 player, $29 grouped. }
  TAIMoveExecuterArmy = class(TAIMoveExecuterUnitList)
  public
    FLocation: TXYL; { $0C }
    FDestination: TXYL; { $10 }
    FTransportStatus: TAIMoveExecuterTransportStatus; { $14 }
    F_AIMoveExecuterArmy_15: array[0..2] of Byte;
    FBoardingPoint: TXYL; { $18 }
    FArrivalPoint: TXYL; { $1C }
    FTransportSource: TXYL; { $20 }
    FTransportDestination: TXYL; { $24 }
    FPlayer: Shortint; { $28 }
    FGrouped: Boolean; { $29 }
    F_AIMoveExecuterArmy_2A: array[0..5] of Byte;
    procedure Setup(Transporter: TAIMoveExecuterUnit);
    function CanAdd(UnitEntry: TAIMoveExecuterUnit): Boolean;
    procedure RetrieveArmy(Selection: Byte; var Army: TArmyHS; var ArmySelection: Byte);
    procedure ResetTransporterSettings;
    function WaitingForTransport: Boolean;
    function Moves(Selection: Byte): Integer;
    function MovePoints(Selection: Byte): Integer;
    function ValidTerrain(Selection: Byte; TerrainType, OverlayType: Shortint): Byte;
  end;

  { TAIMoveExecuterArmyList: instance size $0C; $08 armies. }
  TAIMoveExecuterArmyList = class(TENode)
  public
    function GetArmies(Index: Integer): TAIMoveExecuterArmy;
    function IndexOf(Army: TArmyHS; Selection: Byte): Integer;
    function IndexOfXYL(X, Y, L: Shortint): Integer;
    function IndexOfLoc(Location: TXYL): Integer;
    function IndexOfTransportStatus(Status: TAIMoveExecuterTransportStatus): Integer;
    procedure SortOnMovePoints;
  end;

  { TAIMoveExecuterMove: instance size $20; $08 units, $0C path, $10 points,
    $14 moves, $18..$1A source, $1B..$1D destination. }
  TAIMoveExecuterMove = class(TAIMoveExecuterUnitList)
  public
    FPath: TMovepath; { $0C }
    FMovePoints: Integer; { $10 }
    FMoves: Integer; { $14 }
    FSourceX: Shortint; { $18 }
    FSourceY: Shortint; { $19 }
    FSourceL: Shortint; { $1A }
    FDestinationX: Shortint; { $1B }
    FDestinationY: Shortint; { $1C }
    FDestinationL: Shortint; { $1D }
    F_AIMoveExecuterMove_1E: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddUnits(Units: TAIMoveExecuterUnitList; Selection: Byte);
    procedure AddUnit(UnitEntry: TAIMoveExecuterUnit);
    procedure SetUnitStatus(Status: TAIMoveExecuterUnitStatus);
    function RetrieveArmy(var Army: TArmyHS; var Selection: Byte): Boolean;
  end;

  { TAIMoveExecuterMoveQueue: instance size $0C; $08 queued moves. }
  TAIMoveExecuterMoveQueue = class(TENode)
  public
    procedure Clear; override;
    function GetMoves(Index: Integer): TAIMoveExecuterMove;
    procedure Reset;
  end;

  { TAIMoveExecuterControl: instance size $14; $08 move control, $0C executer, $10 state. }
  TAIMoveExecuterControl = class(TEObject)
  public
    FMoveControl: TAIMoveControl; { $08 }
    FExecuter: TAIMoveExecuter; { $0C }
    FState: Integer; { $10 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateMove(Army: TAIMoveExecuterArmy; Selection: Byte; X, Y, L: Shortint; Mode: TCreateMoveMode; MoveResult: PByte): TAIMoveExecuterMove; virtual; { $4C }
    function CanMoveTo(Army: TAIMoveExecuterArmy; Selection: Byte; X, Y, L: Shortint): Byte; virtual; { $50 }
    procedure CalculateMoves; virtual; { $54 }
    procedure Activate(Executer: TAIMoveExecuter); virtual; { $58 }
    procedure Deactivate; virtual; { $5C }
    procedure Done; virtual; { $60 }
    function Process: Boolean; virtual; { $64 }
  end;

  { TDefaultMEC: instance size $14; inherited move control, executer and state. }
  TDefaultMEC = class(TAIMoveExecuterControl)
  public
    procedure CalculateMoves; override;
  end;

  { TAdjacentArmy: instance size $18; $08 location, $0C moves,
    $10 current move points, $14 path. }
  TAdjacentArmy = class(TEObject)
  public
    FLocation: TXYL; { $08 }
    FMoves: Integer; { $0C }
    FMovePoints: Integer; { $10 }
    FPath: TMovepath; { $14 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMovementDays: Single;
  end;

  { TAdjacentArmyList: instance size $0C; $08 adjacent armies. }
  TAdjacentArmyList = class(TENode)
  public
    function GetAdjacentArmies(Index: Integer): TAdjacentArmy;
    function IndexOfLoc(Location: TXYL): Integer;
    function GetSlowestArmy: Integer;
    function GetAdjacent: Boolean;
  end;

  { TAdjacentMEC: instance size $1C; $14 meeting point, $18 adjacent armies. }
  TAdjacentMEC = class(TAIMoveExecuterControl)
  public
    FMeetingPoint: TXYL; { $14 }
    FAdjacentArmies: TAdjacentArmyList; { $18 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CalculateMoves; override;
    function ExecuteSurroundMove: Boolean;
    function CalculateMeetingPoint: Integer;
    function ExecuteMeetingPointMove: Boolean;
  end;

  { TTransportMEC (instance size $18, VMT 55718CD0). $14 meeting point. }
  TTransportMEC = class(TAIMoveExecuterControl)
  public
    FMeetingPoint: TXYL; { $14 }
    procedure CalculateMoves; override;
    procedure Done; override;
    function CreateTransporterMove(X, Y, L: Shortint; Queue: Boolean): TAIMoveExecuterMove;
    function TransportDone: Boolean;
    procedure DumpTransportUnits(Army: TAIMoveExecuterArmy);
    procedure UpdateTransportMeetingPoint;
    procedure CalculateTransportPathCallBack(Sender: TObject);
  end;

  TAIMoveExecuterDoneEvent = procedure(Sender: TObject) of object;
  TAIMoveExecuterControlClass = class of TAIMoveExecuterControl;

  { TAIMoveExecuter (instance size $3C, VMT 55718E18).
    $08 destination, $0C control, $10 control queue, $14 moves, $18 units,
    $1C transporter, $20 move limit, $24 mode, $28 state, $2C status,
    $2D player, $30 process cycles, $34 completion event. }
  TAIMoveExecuter = class(TEObject)
  public
    FDestination: TXYL; { $08 }
    FControl: TAIMoveExecuterControl; { $0C }
    FControlQueue: TIntegerList; { $10 }
    FMoves: TAIMoveExecuterMoveQueue; { $14 }
    FUnits: TAIMoveExecuterUnitList; { $18 }
    FTransporter: TAIMoveExecuterUnit; { $1C }
    FMovePointsMax: Integer; { $20 }
    FMode: TAIMoveExecuterMode; { $24; 557D7981 }
    F_AIMoveExecuter_25: array[0..2] of Byte;
    FState: Integer; { $28 }
    FStatus: TAIMoveExecuterStatus; { $2C }
    FPlayer: Shortint; { $2D }
    F_AIMoveExecuter_2E: array[0..1] of Byte;
    FProcessCycles: Integer; { $30 }
    FOnDone: TAIMoveExecuterDoneEvent; { $34 }
    { conflict: FOnDone: TNotifyEvent; }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure ActivateMEC(ControlClass: TAIMoveExecuterControlClass);
    procedure DeactivateMEC;
    function AddUnit(AUnit: TAbstractUnit): TAIMoveExecuterUnit;
    procedure AddUnits(Units: TUnitList);
    procedure AddArmy(Army: TArmyHS; Selection: Byte);
    procedure AddTransporter(AUnit: TAbstractUnit);
    procedure InvalidateMove(Army: TArmyHS; Selection: Byte);
    procedure Reset;
    function Validate: Boolean;
    function CreateArmies(Status: TAIMoveExecuterUnitStatusSet): TAIMoveExecuterArmyList;
    procedure FinishMoves;
    procedure ExecuteMoves;
    procedure UnitsMoveDone;
    function GetTransporting: Boolean;
    procedure UpdateMoveResult;
    procedure ProcessExecuteMoves;
    procedure ProcessMECS;
    function Process: Boolean;
    procedure SetupTransporter;
    function ExecuteMove(X, Y, L: Shortint): Boolean;
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

