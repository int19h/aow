{ Interface declaration run owned by P5. }
  { TAIGroupProductionList (instance size $0C, VMT 55719EA8). $08 children. }
  TAIGroupProductionList = class(TENode)
  public
    function GetProductions(Index: Integer): TAIGroupProduction;
    function GetStrengthMax(DamageTypes: TDamageTypes): Integer;
    procedure Add(Control: TProductionControl; AUnit: TAbstractUnit);
    procedure Delete(Index: Integer);
    procedure DeleteUnit(AUnit: TAbstractUnit);
    procedure ChangeGroup(Index: Integer; Group: TAIGroup);
    function IndexOfU(AUnit: TAbstractUnit): Integer;
  end;

  { TAIGroup (instance size $50, VMT 55719FB8). $10 status, $14 references,
    $18 leader, $1C transporter, $20 productions, $24 ID, $28 player,
    $2C/$30 leader/transporter IDs, $34 independent relation, $38 target location,
    $3C target status, $40/$44 budget, $48 move points, $4C mode, $4D/$4E priorities. }
  TAIGroupControlClass = class of TAIGroupControl;
  TAIGroupClass = class of TAIGroup;

  TAIGroup = class(TUnitUserList)
  public
    FStatus: TAIGroupStatus; { $10 }
    F_AIGroup_11: array[0..2] of Byte;
    FRefCount: Integer; { $14 }
    FLeader: TAbstractUnit; { $18 }
    FTransporter: TAbstractUnit; { $1C }
    FProductions: TAIGroupProductionList; { $20 }
    FGroupID: Integer;  { $24; 5578305E }
    FPlayer: Shortint; { $28 }
    F_AIGroup_29: array[0..2] of Byte;
    FLeaderID: Integer; { $2C }
    FTransporterID: Integer; { $30 }
    FIndependentRelation: Shortint; { $34 }
    { conflict: FRelation: Shortint; }
    F_AIGroup_35: array[0..2] of Byte;
    FTargetXYL: TXYL; { $38 }
    { conflict: FDefenseLocation: TXYL; }
    { conflict: FTargetLocation: Integer; }
    FTargetType: TAIGroupTargetStatus; { $3C }
    F_AIGroup_3D: array[0..2] of Byte;
    FGoldBudget: Integer; { $40 }
    { conflict: FTargetGold: Integer; }
    FManaBudget: Integer; { $44 }
    FTargetMovePoints: Integer; { $48 }
    FTargetMode: Byte; { $4C }
    { conflict: FDefendMode: TGroupDefendMode; }
    FProcessPriority: Byte; { $4D }
    FRecruitmentPriority: Byte; { $4E }
    { conflict: FRecruitPriority: Byte; }
    F_AIGroup_4F: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint); override;
    function AddUnit(AUnit: TAbstractUnit): Boolean; override;
    function DeleteUnit(AUnit: TAbstractUnit): Boolean; override;
    function AddUnits(Units: TUnitList): Boolean; override;
    function GetGoldBudget: Integer; virtual; { $B8 }
    function GetManaBudget: Integer; virtual; { $BC }
    function GetLoc: Integer; virtual; { $C0 }
    class function GroupControlClass: TAIGroupControlClass; virtual; { $C4 }
    procedure NewTurn(Player: Shortint); virtual; { $C8 }
    function CreateGroupControl: TAIGroupControl; virtual; { $CC }
    class function Behavior: TGroupBehavior; virtual;
    function DefendLocation(Location: Integer): Boolean; virtual; { $D4 }
    function CooperateWithGroup(Group: TAIGroup): Boolean; virtual; { $D8 }
    function GetRecruitableUnits(Phase: Integer; Units, Recruitable: TUnitList): Boolean; virtual; { $DC }
    { conflict: function GetRecruitableUnits(Group: TAIGroup; Units, Recruitable: TUnitList): Boolean; virtual; }
    function GetProcessPriority: Integer;
    function GetAdjacent: Boolean;
    procedure SetLeader(AUnit: TAbstractUnit);
    function GetMovePointsMin: Integer;
    function GetMovesMin: Integer;
    procedure ResetTargetExpense;
    procedure ReturnTargetExpense;
    function RequestTargetExpense(Gold, Mana: Integer): Boolean;
    function MakeTargetExpense(Gold, Mana: Integer): Boolean;
    function SetupTargetEx(Location: TXYL; MovePoints: Integer; TargetType: TAIGroupTargetStatus; Mode: Byte; TransporterID, Gold, Mana: Integer): Boolean;
    function SetupTarget(Target: TAIGroupControlTarget; TargetType: TAIGroupTargetStatus; Mode: Byte): Boolean;
    procedure ValidateEmpty;
    procedure AddTransporter(AUnit: TAbstractUnit);
    procedure UnitProduced(Control: TProductionControl; AUnit: TAbstractUnit);
    procedure Activate;
    procedure Deactivate;
    procedure SetPlayer(Player: Shortint);
  end;

  { TAIGroupManager (instance size $14, VMT 5571A104). $0C next ID, $10 classes. }
  TAIGroupManager = class(TAIGroupList)
  public
    FNextID: Integer; { $0C }
    FRegisteredClasses: TList; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure RegisterAIGroupClasses(Classes: array of TAIGroupClass);
    procedure UnregisterAIGroupClasses(Classes: array of TAIGroupClass);
    function CreateGroup(Player, Relation: Shortint; Behavior: TGroupBehavior): TAIGroup;
    function CreateUniqueID: Integer;
  end;

  { TAIGroupControlTarget (instance size $4C, VMT 5571A280).
    $08 references; $0C info; $18 data; $30 location; $34 moves; $38 transporter;
    $3C status; $40 path strength; $44 data A; $48 data B. }
  TAIGroupControlTarget = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FInfo: TAITargetInfo; { $0C; 557D77A4 }
    FData: TAITargetData; { $18; 557D77BE }
    FLocation: TXYL; { $30; 557D77CD }
    FMovePoints: Integer; { $34; 557D77D3 }
    FTransporterID: Integer; { $38; 557D77FF }
    FStatus: TAIGroupControlTargetStatus; { $3C }
    F_AIGroupControlTarget_3D: array[0..2] of Byte;
    FPathStrength: Integer; { $40; 557D77F4 }
    FDataA: Integer; { $44 }
    FDataB: Integer; { $48 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Validate(Control: TAIGroupControl): Boolean; virtual; { $4C }
    function GetTargetGold: Integer;
    function GetTargetMana: Integer;
    procedure GetDebugInfo(var Text: string);
  end;

  { TAIGroupControlTargetList (instance size $10, VMT 5571A354).
    $08 children; $0C group control. }
  TAIGroupControlTargetList = class(TEReferenceNode)
  public
    FControl: TAIGroupControl; { $0C }
    function GetTargets(Index: Integer): TAIGroupControlTarget;
    procedure SortOnPriority;
    procedure SortOnDataB;
    procedure Add(Target: TAIGroupControlTarget);
    procedure Delete(Index: Integer);
    function Validate: Boolean;
    function IndexOfXYL(Location: Integer): Integer;
  end;

  { TAIRecruitmentGroup (instance size $28, VMT 5571A468). $08 references,
    $0C location, $10 group, $14 moves, $18 transporter, $1C path strength. }
  TAIRecruitmentGroup = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FLocation: TXYL; { $0C }
    FGroup: TAIGroup; { $10 }
    FMovePoints: Integer; { $14 }
    FTransporterID: Integer; { $18 }
    FPathStrength: Integer; { $1C }
    F_AIRecruitmentGroup_20: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Validate(Control: TAIGroupControl): Boolean; virtual; { $4C }
    procedure SetGroup(Group: TAIGroup);
  end;

  { TAIRecruitmentGroupList (instance size $0C, VMT 5571A538). $08 children. }
  TAIRecruitmentGroupList = class(TEReferenceNode)
  public
    function GetRecruitmentGroups(Index: Integer): TAIRecruitmentGroup;
    procedure SortOnMovePoints;
    procedure OutputDebugInfo;
    procedure Add(Group: TAIRecruitmentGroup);
    procedure Delete(Index: Integer);
    function Validate(Control: TAIGroupControl): Boolean;
    function UnitExists(AUnit: TAbstractUnit): Boolean;
    function FindUnit(AUnit: TAbstractUnit): TAIRecruitmentGroup;
  end;

  { TAIGroupProductionLocation (instance size $28, VMT 5571A648). $08 references,
    $0C production control, $10 location, $14 moves, $18 transporter, $1C path strength. }
  TAIGroupProductionLocation = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FProductionControl: TProductionControl; { $0C }
    FLocation: TXYL; { $10 }
    FMovePoints: Integer; { $14 }
    FTransporterID: Integer; { $18 }
    FPathStrength: Integer; { $1C }
    F_AIGroupProductionLocation_20: array[0..7] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Validate(Control: TAIGroupControl): Boolean; virtual; { $4C }
  end;

  { TAIGroupProductionLocationList (instance size $0C, VMT 5571A728). $08 children. }
  TAIGroupProductionLocationList = class(TEReferenceNode)
  public
    function GetProductionLocation(Index: Integer): TAIGroupProductionLocation;
    procedure SortOnMovePoints;
    procedure Add(Location: TAIGroupProductionLocation);
    procedure Delete(Index: Integer);
    function IndexOfPC(Control: TProductionControl): Integer; { 5573ACC8 }
    function FindPC(Control: TProductionControl): TAIGroupProductionLocation;
    function Validate(Control: TAIGroupControl): Boolean;
  end;

  { TAIGroupControlPlugin (instance size $1C, VMT 5571A894).
    $08 references, $0C cycles, $10 control, $14 status, $18 state. }
  TAIGroupControlPlugin = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FProcessCycles: Integer; { $0C }
    FGroupControl: TAIGroupControl; { $10 }
    FStatus: TAIGroupControlPluginStatus; { $14 }
    F_AIGroupControlPlugin_15: array[0..2] of Byte;
    FState: Integer; { $18; 557D7422 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate; virtual;  { $4C }
    function GetBusy: Boolean; virtual; { $50; 5573A348 }
    function Activate(Control: TAIGroupControl): Boolean; virtual;
    procedure Deactivate; virtual; { $58 }
    function Process: Boolean; virtual;
    procedure Done;
    function MainProcess: Boolean;
  end;

  { TAIGroupControl (instance size $170, VMT 5571A978).
    $08 cycles, $0C group, $10 status, $14 location, $18 army, $1C army sprite,
    $20 selection, $24 targets, $28 strengths, $50 max strength, $54 move table,
    $154 immunity, $158 predictor, $15C move executer, $160 recruitment,
    $164 production locations, $168 plugin, $16C state. }
  TAIGroupControl = class(TEObject)
  public
    FProcessCycles: Integer; { $08 }
    FGroup: TAIGroup; { $0C }
    FStatus: TAIGroupControlStatus; { $10 }
    F_AIGroupControl_11: array[0..2] of Byte;
    FLocation: TXYL; { $14; 557D74F8 }
    FArmy: TArmy; { $18 }
    FArmyHS: TArmyHS; { $1C; 557D7B43 }
    FSelection: Byte; { $20; 557D7B4C }
    F_AIGroupControl_21: array[0..2] of Byte;
    FTargets: TAIGroupControlTargetList; { $24; 5573A36F }
    FStrength: array[TDamageType] of Integer; { $28 }
    FStrengthMax: Integer; { $50; 557D7805 }
    FMovePointTable: TMovePointTable; { $54; 557D7845 }
    FImmunityTypes: TDamageTypes; { $154 }
    F_AIGroupControl_156: array[0..1] of Byte;
    FCombatPredictor: TCombatPredictor; { $158; 5573A7F5 }
    FMoveExecuter: TAIMoveExecuter; { $15C; 557D7974 }
    FRecruitmentGroups: TAIRecruitmentGroupList; { $160; 5573A6F4 }
    FProductionLocations: TAIGroupProductionLocationList; { $164; 5573ACC0 }
    FPlugin: TAIGroupControlPlugin; { $168 }
    FState: Integer; { $16C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MoveExecuterDone; virtual;  { $4C }
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); virtual; { $50; 5573A217 }
    procedure RecruitmentGroupFoundEvent(Sender: TAIGroupControlPlugin; Group: TAIRecruitmentGroup; var SearchDone: Boolean); virtual; { $54; 5573A4FA }
    procedure ProductionLocationFoundEvent(Sender: TAIGroupControlPlugin; Location: TAIGroupProductionLocation; var SearchDone: Boolean); virtual; { $58; 5573AD1E }
    function Validate: Boolean; virtual; { $5C }
    procedure ProcessStates; virtual;  { +060 }
    procedure ProcessStatesLooped; virtual;  { +064 }
    function Split: Boolean; virtual; { $68 }
    procedure Activate; virtual;  { +06C }
    procedure Deactivate; virtual;  { +070 }
    procedure ResetME; virtual;  { +074 }
    procedure SetupME; virtual; { +078 }
    procedure ExecuteME(X, Y, L: Shortint); virtual; { +07C }
    procedure Done;
    function GetStrengthMax(DamageTypes: TDamageTypes): Integer;
    procedure UpdateGroupChanges;
    function RetrieveGroupArmy(X, Y, L: Shortint; var Army: TArmy; var Selection: Byte): Boolean;
    procedure CombineIdleGroups;
    procedure ResetCP;
    procedure SetupCP(Target: TAIGroupControlTarget);
    procedure ActivatePlugin(Plugin: TAIGroupControlPlugin);
    procedure DeactivatePlugin;
    procedure MainProcessStates(Looped: Boolean);
    function Process(Looped: Boolean): Boolean;
    function FindAvailableTransporter: TAbstractUnit;
  end;

  { TAIGroupTargetFinder (instance size 56, VMT 5571AAC4).
    $1C control, $20 selector, $24 mode, $28/$2C ranges, $30 step, $34 damage types. }
  TAIGroupTargetFinder = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FSelector: TAIMoveTargetSelector; { $20 }
    FMode: TAIGroupTargetFinderMode; { $24 }
    F_AIGroupTargetFinder_25: array[0..2] of Byte;
    FRange: Integer; { $28 }
    FTargetRange: Integer; { $2C }
    FStep: Integer; { $30 }
    FDamageTypes: TDamageTypes; { $34 }
    F_AIGroupTargetFinder_36: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure Reset; virtual;
    function Setup(Control: TAIGroupControl): Boolean; virtual;
    procedure TargetFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
  end;

  { TGroupDefenseSelector (instance size 16, VMT 5571ABB0) }
  TGroupDefenseSelector = class(TObject)
  public
    F_GroupDefenseSelector_04: array[0..3] of Byte;
    FDefenders: TUnitList; { $08 }
    FDefenseLocation: TXYL; { $0C }
    destructor Destroy; override;
    constructor Create; virtual; { $00 }
    procedure GetDefenders(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure EnoughStrength(A1: Integer);  { draft }
    procedure UsefullUnit(A1: Integer; A2: Integer);  { draft }
    procedure UpdateDefenseLocation(A1: Integer);  { draft }
    function Execute(Group: TAIGroup; X, Y, L: Shortint; Units: TUnitList): Boolean;
  end;

  { TAIGroupDefenseControl (instance size 40, VMT 5571ACDC) }
  TAIGroupDefenseControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupDefenseControl_1C: Integer;
    F_AIGroupDefenseControl_20: Integer;
    F_AIGroupDefenseControl_24: Byte;
    FDefendOnly: Boolean; { $25; 557D9594 }
    F_AIGroupDefenseControl_26: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
  end;

  { TAIRecruitmentGroupFinder (instance size 52, VMT 5571AE1C).
    $1C control, $20 selector, $24 range, $28 step, $2C target range, $30 mode. }
  TAIRecruitmentGroupFinder = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FSelector: TAIMoveTargetSelector; { $20 }
    FRange: Integer; { $24 }
    FStep: Integer; { $28 }
    FTargetRange: Integer; { $2C }
    FMode: TAIRecruitmentGroupFinderMode; { $30 }
    F_AIRecruitmentGroupFinder_31: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    function Setup(Control: TAIGroupControl): Boolean; virtual;
    procedure RecruitGroupFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
    procedure Reset;
  end;

  { TAIGroupRecruitControl: instance size $98, VMT 5571AF78.
    $1C mode, $20 control, $24 completion, $28 units, $2C remaining strengths,
    $54 remaining maximum, $58 requested maximum, $5C damage types,
    $60 requested strengths, $88 superiority, $8C move types, $90 moves,
    $94 path-strength factor. }
  TAIGroupRecruitControl = class(TAIGroupControlPlugin)
  public
    FMode: TAIGroupRecruitControlMode; { $1C }
    F_AIGroupRecruitControl_1D: array[0..2] of Byte;
    FControl: TAIGroupControl; { $20 }
    FComplete: Boolean; { $24 }
    F_AIGroupRecruitControl_25: array[0..2] of Byte;
    FUnits: TUnitUserList; { $28 }
    FRemainingStrengths: array[TDamageType] of Integer; { $2C }
    FRemainingStrength: Integer; { $54 }
    FRecruitStrength: Integer; { $58 }
    FDamageTypes: TDamageTypes; { $5C }
    F_AIGroupRecruitControl_5E: array[0..1] of Byte;
    FRecruitStrengths: array[TDamageType] of Integer; { $60 }
    FSuperiority: Integer; { $88 }
    FMoveTypes: TMoveTypes; { $8C }
    F_AIGroupRecruitControl_8D: array[0..2] of Byte;
    FMovesMin: Integer; { $90 }
    FPathStrengthFactor: Single; { $94 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    function Setup: Boolean; virtual; { $60 }
    function GetRecruitedStrength: Integer;
    function GetRecruitStrengthEx(DamageType: TDamageType): Integer;
    procedure SetRecruitStrengthEx(DamageType: TDamageType; Value: Integer);
    function GetRecruitMoveDays: Integer;
    function UsefullRecruitUnit(AUnit: TAbstractUnit): Boolean;
    procedure UpdateCompletion;
    procedure AddRecruitUnit(AUnit: TAbstractUnit);
    procedure DeleteRecruitUnit(AUnit: TAbstractUnit);
    procedure ExecuteRecruitment;
    function ValidRecruitmentGroup(Group: TAIRecruitmentGroup): Boolean;
    function RecruitFromGroup(Group: TAIRecruitmentGroup): Boolean;
    procedure Reset;
  end;

  { TAIGroupCooperationControl (instance size 148, VMT 5571B0C8) }
  TAIGroupCooperationControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupCooperationControl_1C: Byte;
    F_AIGroupCooperationControl_1D: array[0..2] of Byte;
    F_AIGroupCooperationControl_20: Integer;
    F_AIGroupCooperationControl_24: Integer;
    F_AIGroupCooperationControl_28: Byte;
    F_AIGroupCooperationControl_29: array[0..2] of Byte;
    F_AIGroupCooperationControl_2C: Integer;
    F_AIGroupCooperationControl_30: Byte;
    F_AIGroupCooperationControl_31: array[0..38] of Byte;
    F_AIGroupCooperationControl_58: Integer;
    F_AIGroupCooperationControl_5C: Integer;
    F_AIGroupCooperationControl_60: Integer;
    F_AIGroupCooperationControl_64: Word;
    F_AIGroupCooperationControl_66: array[0..1] of Byte;
    F_AIGroupCooperationControl_68: Byte;
    F_AIGroupCooperationControl_69: array[0..38] of Byte;
    F_AIGroupCooperationControl_90: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure Setup(A1: Integer; A2: Integer); virtual;  { +060 draft }
    procedure GetCooperateMoveDays(A1: Integer; A2: Integer);  { draft }
    procedure GetCooperatedStrength;  { draft }
    procedure GetCooperateStrengthEx(A1: Integer);  { draft }
    procedure SetCooperateStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure UpdateCompletion;  { draft }
    procedure Reset;  { draft }
    procedure AddCooperationGroup(A1: Integer; A2: Integer);  { draft }
    procedure ValidCooperationGroup(A1: Integer);  { draft }
    procedure ExecuteCooperation(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIProductionLocationFinder: instance size $34, VMT 5571B218.
    $1C control, $20 selector, $24 mode, $28 range, $2C step, $30 target range. }
  TAIProductionLocationFinder = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FSelector: TAIMoveTargetSelector; { $20 }
    FMode: TAIProductionLocationFinderMode; { $24 }
    F_AIProductionLocationFinder_25: array[0..2] of Byte;
    FRange: Integer; { $28 }
    FStep: Integer; { $2C }
    FTargetRange: Integer; { $30 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    function Setup(Control: TAIGroupControl): Boolean; virtual; { $60 }
    procedure ProductionLocationFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
    procedure Reset;
  end;

  { TAIGroupUnitProduction: instance size $30, VMT 5571B36C.
    $08 references, $0C unit, $10 production location, $14 gold, $18 mana,
    $1C/$20 upkeep, $24 production time, $28 priority, $2C research. }
  TAIGroupUnitProduction = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FU: TUnit; { $0C }
    FProductionLocation: TAIGroupProductionLocation; { $10 }
    FGold: Integer; { $14 }
    FMana: Integer; { $18 }
    FGoldUpkeep: Integer; { $1C }
    FManaUpkeep: Integer; { $20 }
    FProductionTime: Integer; { $24 }
    FPriority: Integer; { $28 }
    FResearch: Boolean; { $2C }
    F_AIGroupUnitProduction_2D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure SetU(U: TUnit);
    procedure SetProductionLocation(Location: TAIGroupProductionLocation);
  end;

  { TAIGroupUnitProductionList: instance size $0C, VMT 5571B440; $08 children. }
  TAIGroupUnitProductionList = class(TEReferenceNode)
  public
    function GetUnitProductions(Index: Integer): TAIGroupUnitProduction;
  end;

  { TAIGroupProductionControl: instance size $C0, VMT 5571B558.
    $1C control, $20 mode, $21 completion, $24/$28 costs, $2C/$30 upkeep,
    $34 productions, $38 candidates, $3C remaining strengths, $64 remainder,
    $68 requested strength, $6C damage types, $70 requested strengths,
    $98 priority range, $9C multiple, $A0 group ID, $A4 superiority,
    $A8 move-point priority, $AC allow research, $B0 research priority,
    $B4 move types, $B8 minimum moves, $BC path-strength factor. }
  TAIGroupProductionControl = class(TAIGroupControlPlugin)
  public
    FControl: TAIGroupControl; { $1C }
    FMode: TAIGroupProductionControlMode; { $20 }
    FComplete: Boolean; { $21 }
    F_AIGroupProductionControl_22: array[0..1] of Byte;
    FGold: Integer; { $24 }
    FMana: Integer; { $28 }
    FGoldUpkeep: Integer; { $2C }
    FManaUpkeep: Integer; { $30 }
    FProductions: TAIGroupUnitProductionList; { $34 }
    FProduceableUnits: TAIGroupUnitProductionList; { $38 }
    FRemainingStrengths: array[TDamageType] of Integer; { $3C }
    FRemainingStrength: Integer; { $64 }
    FProduceStrength: Integer; { $68 }
    FDamageTypes: TDamageTypes; { $6C }
    F_AIGroupProductionControl_6E: array[0..1] of Byte;
    FProduceStrengths: array[TDamageType] of Integer; { $70 }
    FPriorityRange: Integer; { $98 }
    FMultiple: Boolean; { $9C }
    F_AIGroupProductionControl_9D: array[0..2] of Byte;
    FGroupID: Integer; { $A0 }
    FSuperiority: Integer; { $A4 }
    FMovePointPriority: Integer; { $A8 }
    FAllowResearch: Boolean; { $AC }
    F_AIGroupProductionControl_AD: array[0..2] of Byte;
    FResearchPriority: Integer; { $B0 }
    FMoveTypes: TMoveTypes; { $B4 }
    F_AIGroupProductionControl_B5: array[0..2] of Byte;
    FMovesMin: Integer; { $B8 }
    FPathStrengthFactor: Single; { $BC }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    function Setup(Control: TAIGroupControl): Boolean; virtual; { $60 }
    function GetProducedStrength: Integer;
    function GetProduceStrengthEx(DamageType: TDamageType): Integer;
    procedure SetProduceStrengthEx(DamageType: TDamageType; Value: Integer);
    function UnitProductionPriority(AUnit: TUnit): Integer;
    function GetCurrentProductionTime: Integer;
    function GetCompleteProductionTime: Integer;
    procedure UpdateCompletion;
    function ExecuteProductions(GroupID: Integer): Boolean;
    procedure AddProduction(Production: TAIGroupUnitProduction);
    procedure DeleteProduction(Index: Integer);
    procedure Reset;
    function ListProduceableUnits(Location: TAIGroupProductionLocation): Boolean;
    function ValidProductionLocation(Location: TAIGroupProductionLocation): Boolean;
    procedure UpdateProduceableUnits;
  end;

  { TAIGroupTargetPrioritySettings (instance size 60, VMT 5571B750) }
  TAIGroupTargetPrioritySettings = class(TObject)
  public
    F_AIGroupTargetPrioritySettings_04: array[0..55] of Byte;
  end;

  { TAIGroupTargetSelector (instance size 136, VMT 5571B7E8) }
  TAIGroupTargetSelector = class(TAIGroupControlPlugin)
  public
    F_AIGroupTargetSelector_1C: Byte;
    F_AIGroupTargetSelector_1D: array[0..2] of Byte;
    F_AIGroupTargetSelector_20: Integer;
    F_AIGroupTargetSelector_24: Integer;
    F_AIGroupTargetSelector_28: Integer;
    F_AIGroupTargetSelector_2C: Integer;
    F_AIGroupTargetSelector_30: Byte;
    F_AIGroupTargetSelector_31: array[0..2] of Byte;
    F_AIGroupTargetSelector_34: Integer;
    F_AIGroupTargetSelector_38: Integer;
    F_AIGroupTargetSelector_3C: Integer;
    F_AIGroupTargetSelector_40: Integer;
    F_AIGroupTargetSelector_44: Integer;
    F_AIGroupTargetSelector_48: Integer;
    F_AIGroupTargetSelector_4C: Integer;
    F_AIGroupTargetSelector_50: Integer;
    F_AIGroupTargetSelector_54: Integer;
    F_AIGroupTargetSelector_58: Word;
    F_AIGroupTargetSelector_5A: array[0..1] of Byte;
    F_AIGroupTargetSelector_5C: Integer;
    F_AIGroupTargetSelector_60: Integer;
    F_AIGroupTargetSelector_64: Integer;
    F_AIGroupTargetSelector_68: Integer;
    F_AIGroupTargetSelector_6C: Integer;
    F_AIGroupTargetSelector_70: Integer;
    F_AIGroupTargetSelector_74: Integer;
    F_AIGroupTargetSelector_78: Integer;
    F_AIGroupTargetSelector_7C: Byte;
    F_AIGroupTargetSelector_7D: array[0..2] of Byte;
    F_AIGroupTargetSelector_80: Integer;
    F_AIGroupTargetSelector_84: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Validate; override;
    function GetBusy: Boolean; override;
    function Activate(Control: TAIGroupControl): Boolean; override;
    function Process: Boolean; override;
    procedure TargetOverlapFound(A1: Integer; A2: Integer);  { draft }
    procedure ValidateTargetOverlap(A1: Integer; A2: Integer);  { draft }
    procedure GetValidTargets;  { draft }
    procedure Reset;  { draft }
    procedure ActivatePlugin(A1: Integer);  { draft }
    procedure DeactivatePlugin;  { draft }
    procedure GetTargetSetupPriority(A1: Integer; A2: Integer);  { draft }
    procedure Setup(A1: Integer);  { draft }
    procedure TargetProcessed;  { draft }
    procedure GetRequiredSuperiority(A1: Integer);  { draft }
    procedure GetRequiredCombatPredictorSuperiority(A1: Integer);  { draft }
    procedure GetRequiredTargetStrength(A1: Integer);  { draft }
    procedure GetRequiredBattleFieldSuperiority(A1: Integer);  { draft }
    procedure GetRequiredBattleFieldStrength(A1: Integer);  { draft }
    procedure GetRequiredStrength(A1: Integer);  { draft }
    procedure ValidateTargetRequirements(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ValidMultiTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ShowTargetInfo;  { draft }
    procedure NoTargetsFound;  { draft }
    procedure AllowMultiTargets(A1: Integer; A2: Integer);  { draft }
  end;

  { THuntAG (instance size 84, VMT 5571B8D0) }
  { THuntAG (instance size $54). $50 hunted unit IDs. }
  THuntAG = class(TAIGroup)
  public
    FTargetUnitIDs: TIntegerList; { $50; 5575FE61 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    class function GroupControlClass: TAIGroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
    function HuntingPlayer(Player: Shortint): Boolean;
  end;

  { THuntAGC (instance size 368, VMT 5571BA18) }
  THuntAGC = class(TAIGroupControl)
  public
    procedure TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean); override;
    procedure ProcessStates; override;
  end;

  { TGroupControl (instance size 8, VMT 5571BB04) }
  TGroupControl = class(TEObject)
  public
    function Behavior: TGroupBehavior; virtual;  { $4C }
  end;

  { TGuardGC (instance size 8, VMT 5571BBC8) }
  TGuardGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TPassiveGC (instance size 8, VMT 5571BC84) }
  TPassiveGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TGuardAreaGC (instance size 8, VMT 5571BD44) }
  TGuardAreaGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TSuicidalGC (instance size 8, VMT 5571BE08) }
  TSuicidalGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TPatrolGC (instance size 8, VMT 5571BEC8) }
  TPatrolGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TScoutGC (instance size 8, VMT 5571BF84) }
  TScoutGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TRefugeGC (instance size 8, VMT 5571C040) }
  TRefugeGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    function Behavior: TGroupBehavior; override;
  end;

  { TEndTurnTE (instance size $1C, VMT 5571C138).
    $10 player, $14 day, $18 end-turn mode. }
  TEndTurnTE = class(TTokenEvent)
  public
    FPlayer: Shortint; { $10 }
    F_EndTurnTE_11: array[0..2] of Byte;
    FDay: Integer; { $14 }
    FMode: TEndTurnMode; { $18 }
    F_EndTurnTE_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TChangePlayerSettingsTE (instance size 24, VMT 5571C1F8) }
  TChangePlayerSettingsTE = class(TTokenEvent)
  public
    FPlayer: Shortint; { $10 }
    F_ChangePlayerSettingsTE_11: array[0..2] of Byte;
    FSettings: string; { $14 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TMoveTE (instance size 28, VMT 5571C330) }
  TMoveTE = class(TTokenEvent)
  public
    F_MoveTE_10: Byte;
    F_MoveTE_11: array[0..2] of Byte;
    F_MoveTE_14: Integer;
    F_MoveTE_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    function GetMapF(A1: Integer; A2: Integer): Integer; virtual;  { +050 draft }
    procedure ProcessMove; virtual;  { +054 draft }
    function Validate: Integer; virtual;  { +058 draft }
    procedure InitializeMove; virtual;  { +05C draft }
    procedure FinishMove; virtual;  { +060 draft }
    procedure Move; virtual;  { +064 draft }
    function LastMove(A1: Integer; A2: Byte): Byte; virtual;  { +068 draft }
    function DefaultMove: Byte; virtual;  { +06C draft }
    procedure GetDirection(A1: Integer);  { draft }
    procedure GetHT(A1: Integer);  { draft }
  end;

  { TMultiMoveTE (instance size 24, VMT 5571C408) }
  TMultiMoveTE = class(TTokenEvent)
  public
    FEvents: TTokenEventList; { $10 }
    FMoveMode: Byte; { $14 }
    F_MultiMoveTE_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TMoveArmyTE (instance size 56, VMT 5571C52C) }
  TMoveArmyTE = class(TMoveTE)
  public
    F_MoveArmyTE_1C: Byte;
    F_MoveArmyTE_1D: array[0..2] of Byte;
    F_MoveArmyTE_20: Integer;
    F_MoveArmyTE_24: Byte;
    F_MoveArmyTE_25: array[0..2] of Byte;
    F_MoveArmyTE_28: Integer;
    F_MoveArmyTE_2C: Byte;
    F_MoveArmyTE_2D: Byte;
    F_MoveArmyTE_2E: Byte;
    F_MoveArmyTE_2F: Byte;
    F_MoveArmyTE_30: Byte;
    F_MoveArmyTE_31: Byte;
    F_MoveArmyTE_32: Byte;
    F_MoveArmyTE_33: Byte;
    F_MoveArmyTE_34: Byte;
    F_MoveArmyTE_35: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate: Integer; override;
    procedure InitializeMove; override;
    procedure FinishMove; override;
    function DefaultMove: Byte; override;
    procedure Animating; virtual;  { +070 draft }
    procedure UpdateAnimation; virtual;  { +074 draft }
    procedure SetupNextMove; virtual;  { +078 draft }
    procedure CanMoveNext; virtual;  { +07C draft }
    procedure ExecuteMove; virtual;  { +080 draft }
    function Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean; virtual;  { +084 }
    procedure GetNoneMovingArmyHS(A1: Integer);  { draft }
    procedure ObserveMove;  { draft }
    procedure MoveVisible(A1: Integer);  { draft }
  end;

  { TArmyDefaultMoveTE (instance size 56, VMT 5571C624) }
  TArmyDefaultMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    function Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean; override;
  end;

  { TArmyNegotiateMoveTE (instance size 56, VMT 5571C72C) }
  TArmyNegotiateMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    function Validate: Integer; override;
    procedure Animating; override;
    procedure CanMoveNext; override;
    procedure ExecuteMove; override;
  end;

  { TArmyCombineMoveTE (instance size 56, VMT 5571C838) }
  TArmyCombineMoveTE = class(TMoveArmyTE)
  public
    class function ClassID: Integer; override;
    procedure CanMoveNext; override;
    procedure ShowCombineFailure(A1: Byte);  { draft }
  end;

  { TArmyCombatMoveTE (instance size 60, VMT 5571C9D4) }
  TArmyCombatMoveTE = class(TMoveArmyTE)
  public
    F_ArmyCombatMoveTE_38: Byte;
    F_ArmyCombatMoveTE_39: Byte;
    F_ArmyCombatMoveTE_3A: Byte;
    F_ArmyCombatMoveTE_3B: array[0..0] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure ProcessMove; override;
    function Validate: Integer; override;
    procedure InitializeMove; override;
    procedure Animating; override;
    procedure CanMoveNext; override;
    procedure ExecuteMove; override;
    function Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean; override;
    procedure RequestCombatTypeCallBack(A1: Integer);  { draft }
    procedure RestoreHotseatMode(A1: Integer);  { draft }
    procedure RestoreHotSeatModeCallBack;  { draft }
    procedure ShowHotSeatPlayerCallBack(A1: Integer);  { draft }
    procedure SetupCombat;  { draft }
    procedure CombatExecuted(A1: Integer);  { draft }
    procedure ExecuteCombat;  { draft }
    procedure ExecuteLastMove;  { draft }
  end;

  { TCombatRestoreHotseatEventLog (instance size 28, VMT 5571CAD8) }
  TCombatRestoreHotseatEventLog = class(TEventLog)
  public
    F_CombatRestoreHotseatEventLog_18: Byte;
    F_CombatRestoreHotseatEventLog_19: array[0..2] of Byte;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TNegotiateTE (instance size $3C, VMT 5571CCFC).
    $10 Gold, $14 Offer, $15/$16/$17 X/Y/L, $18 ArmyID,
    $1C Player, $1D OwnerPlayer, $20 ArmyHS, $24 Object, $28 MovePoints,
    $2C Selection, $2D Mode, $2E Result, $30 EventLogID, $34/$38 Data1/Data2. }
  TNegotiateTE = class(TTokenEvent)
  public
    FGold: Integer;
    FOffer: TNegotiateOffer;
    FX: Byte;
    FY: Byte;
    FL: Byte;
    FArmyID: TArmyID;
    FPlayer: Shortint; { $1C }
    FOwnerPlayer: Byte;
    F_NegotiateTE_1E: array[0..1] of Byte;
    FArmyHS: TArmyHS;
    FObject: TNegotiateObject;
    F_NegotiateTE_25: array[0..2] of Byte;
    FMovePoints: Integer;
    FSelection: Byte;
    FMode: TNegotiateMode;
    FResult: TNegotiateResult;
    F_NegotiateTE_2F: array[0..0] of Byte;
    FEventLogID: Integer;
    FData1: Integer;
    FData2: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    function Validate: Boolean; virtual;  { +050 }
    procedure Accept; virtual;  { +054 }
    procedure Reject; virtual;  { +058 }
  end;

  { TNegotiateRequestEventLog (instance size $54, VMT 5571CDCC).
    $3C/$3D/$3E X/Y/L, $40 MovePoints, $44 ArmyID, $48 Object,
    $4C/$50 Data1/Data2; inherited join fields $18..$3B. }
  TNegotiateRequestEventLog = class(TJoinEventLog)
  public
    FX: Byte;
    FY: Byte;
    FL: Byte;
    F_NegotiateRequestEventLog_3F: array[0..0] of Byte;
    FMovePoints: Integer;
    FArmyID: TArmyID;
    FObject: TNegotiateObject;
    F_NegotiateRequestEventLog_49: array[0..2] of Byte;
    FData1: Integer;
    FData2: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    function Accept(var ErrorText: string): Boolean; override;
    function Cancel: Boolean; override;
    function Reject(var ErrorText: string): Boolean; override;
    function CreateNegotiateTE: TNegotiateTE; virtual;  { +08C }
  end;

  { TGameOverTE (instance size 20, VMT 5571CEE8) }
  TGameOverTE = class(TTokenEvent)
  public
    FPlayer: Shortint; { $10 }
    FGameOverStatus: TGameOverStatus; { $11 }
    F_GameOverTE_12: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TSaveGameTE (instance size 20, VMT 5571CFA8) }
  TSaveGameTE = class(TTokenEvent)
  public
    FFileName: string; { $10; 557758D5 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCheatTE (instance size 24, VMT 5571D07C) }
  TCheatTE = class(TTokenEvent)
  public
    F_CheatTE_10: Byte;
    F_CheatTE_11: array[0..2] of Byte;
    F_CheatTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TDisbandUnitTE (instance size 24, VMT 5571D138) }
  TDisbandUnitTE = class(TTokenEvent)
  public
    F_DisbandUnitTE_10: Integer;
    F_DisbandUnitTE_14: Byte;
    F_DisbandUnitTE_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TCombatFlowControlTE (instance size 24, VMT 5571D2A8) }
  TCombatFlowControlTE = class(TTokenEvent)
  public
    F_CombatFlowControlTE_10: Byte;
    F_CombatFlowControlTE_11: array[0..2] of Byte;
    F_CombatFlowControlTE_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TTerminatePlayerTE (instance size 32, VMT 5571D37C) }
  TTerminatePlayerTE = class(TTokenEvent)
  public
    FPlayer: Shortint; { $10; 55755EB4 }
    F_TerminatePlayerTE_11: array[0..2] of Byte;
    FExitCallBack: TExitGameCallBack; { $14; 55755EB7 }
    FExitMode: TExitGameMode; { $1C; 55755EC3 }
    F_TerminatePlayerTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TFastCombatUnit (instance size $64, VMT 5571D4BC). $5C round distance, $60 state. }
  TFastCombatUnit = class(TCombatUnit)
  public
    FRoundDistance: Integer; { $5C }
    FState: TFastCombatUnitState;  { $60 }
    F_FastCombatUnit_61: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer); override;
    function GetTargetWallCV(Target: TCombatObject): Integer; override;
    function GetTargetPriority: Integer; override;
    procedure SetCombatPlayer(Player: Byte); override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure Initialize(A1: Integer); override;
    function fcRoundDistance: Integer; override;
    function fcExecute(A1: Integer): Boolean; override;
    function fcBehindWall: Boolean; override;
    function fcWallInBetween(A1: Byte): Boolean; override;
    { conflict: function fcWallInBetween(A1: Integer): Boolean; override; }
    procedure Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc); override;
    function ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    function ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    procedure DestroyObject; override;
    procedure SetUnit(AUnit: TAbstractUnit); override;
    procedure KillUnit; override;
    function CanCastWallSiegeSpell: Boolean;
    procedure UpdateWallSiegeObjectRegistration;
  end;

  { TFastCombatParty (instance size 28, VMT 5571D670) }
  TFastCombatParty = class(TCombatParty)
  public
  end;

  { TCombatObjectList (instance size 16, VMT 5571D738) }
  TCombatObjectList = class(TList)
  public
    procedure GetObject(A1: Integer);  { draft }
  end;

  { TFastCombat (instance size 80, VMT 5571D7BC) }
  TFastCombat = class(TCombat)
  public
    FWallSiegeObjectCount: Integer; { $4C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function CreateCombatUnit: Integer; override;
    function Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Byte; A7: Byte; A8: Integer; A9: Integer; A10: Integer; A11: Boolean): Boolean; override;
    function Execute: Byte; override;
    procedure Initialize; override;
    procedure Activate; override;
    procedure Deactivate; override;
    function GetRoundDistance: Integer;
    procedure GetRoundDistanceMax;  { draft }
    function GetWallInBetween(Source, Target: Byte): Boolean;
    function GetWallSituation(A1, A2: TCombatObject): TWallSituation;
    function AttackerCanCrushWall: Boolean;
    function GetAttackerBalisticCV: Integer;
    function GetDefenderBalisticCV: Integer;
    procedure ValidateWallBreaching;  { draft }
    procedure ExecuteCombatRound;  { draft }
  end;

