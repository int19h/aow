{ Interface declaration run owned by P5. }
  { TAIGroupProductionList (instance size 12, VMT 55719EA8) }
  TAIGroupProductionList = class(TENode)
  public
    procedure GetProductions(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure DeleteUnit;  { draft }
    procedure ChangeGroup(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfU(A1: Integer);  { draft }
  end;

  { TAIGroup (instance size 80, VMT 55719FB8) }
  TAIGroup = class(TUnitUserList)
  public
    F_AIGroup_10: Byte;
    F_AIGroup_11: array[0..2] of Byte;
    F_AIGroup_14: Integer;
    F_AIGroup_18: array[0..3] of Byte;
    F_AIGroup_1C: Integer;
    F_AIGroup_20: Integer;
    FGroupID: Integer;  { $24; 5578305E }
    F_AIGroup_28: Byte;
    F_AIGroup_29: array[0..2] of Byte;
    F_AIGroup_2C: Integer;
    F_AIGroup_30: Integer;
    F_AIGroup_34: Byte;
    F_AIGroup_35: array[0..2] of Byte;
    F_AIGroup_38: Integer;
    F_AIGroup_3C: Byte;
    F_AIGroup_3D: array[0..2] of Byte;
    F_AIGroup_40: Integer;
    F_AIGroup_44: Integer;
    F_AIGroup_48: Integer;
    F_AIGroup_4C: Byte;
    F_AIGroup_4D: Byte;
    F_AIGroup_4E: Byte;
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
    procedure GetGoldBudget; virtual;  { +0B8 draft }
    procedure GetManaBudget; virtual;  { +0BC draft }
    procedure GetLoc(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure GroupControlClass; virtual;  { +0C4 draft }
    procedure NewTurn(A1: Byte); virtual;  { +0C8 draft }
    procedure CreateGroupControl; virtual;  { +0CC draft }
    class function Behavior: TGroupBehavior; virtual;
    procedure DefendLocation(A1: Integer); virtual; { +0D4 }
    procedure CooperateWithGroup(A1: Integer); virtual;  { +0D8 draft }
    procedure GetRecruitableUnits(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0DC draft }
    procedure GetProcessPriority;  { draft }
    procedure GetAdjacent(A1: Integer; A2: Integer);  { draft }
    procedure SetLeader(A1: Integer);  { draft }
    procedure GetMovePointsMin;  { draft }
    procedure GetMovesMin;  { draft }
    procedure ResetTargetExpense;  { draft }
    procedure ReturnTargetExpense;  { draft }
    procedure RequestTargetExpense(A1: Integer; A2: Integer);  { draft }
    procedure MakeTargetExpense(A1: Integer; A2: Integer);  { draft }
    procedure SetupTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);  { draft }
    procedure SetupTarget(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ValidateEmpty;  { draft }
    procedure AddTransporter(A1: Integer);  { draft }
    procedure UnitProduced(A1: Integer; A2: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure SetPlayer(A1: Integer);  { draft }
  end;

  { TAIGroupManager (instance size 20, VMT 5571A104) }
  TAIGroupManager = class(TAIGroupList)
  public
    F_AIGroupManager_0C: Integer;
    F_AIGroupManager_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure RegisterAIGroupClasses(A1: Integer; A2: Integer);  { draft }
    procedure UnregisterAIGroupClasses(A1: Integer; A2: Integer);  { draft }
    function CreateGroup(Player, Relation, GroupType: Shortint): TAIGroup;
    procedure CreateUniqueID;  { draft }
  end;

  { TAIGroupControlTarget (instance size 76, VMT 5571A280) }
  TAIGroupControlTarget = class(TEObject)
  public
    F_AIGroupControlTarget_08: Integer;
    F_AIGroupControlTarget_0C: Byte;
    F_AIGroupControlTarget_0D: array[0..10] of Byte;
    F_AIGroupControlTarget_18: Integer;
    F_AIGroupControlTarget_1C: Byte;
    F_AIGroupControlTarget_1D: array[0..2] of Byte;
    F_AIGroupControlTarget_20: Integer;
    F_AIGroupControlTarget_24: array[0..11] of Byte;
    F_AIGroupControlTarget_30: Integer;
    F_AIGroupControlTarget_34: Integer;
    F_AIGroupControlTarget_38: Integer;
    F_AIGroupControlTarget_3C: Byte;
    F_AIGroupControlTarget_3D: array[0..2] of Byte;
    F_AIGroupControlTarget_40: Integer;
    F_AIGroupControlTarget_44: Integer;
    F_AIGroupControlTarget_48: array[0..3] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate(A1: Integer); virtual;  { +04C draft }
    procedure GetTargetGold;  { draft }
    procedure GetTargetMana;  { draft }
    procedure GetDebugInfo(A1: Integer);  { draft }
  end;

  { TAIGroupControlTargetList (instance size 16, VMT 5571A354) }
  TAIGroupControlTargetList = class(TEReferenceNode)
  public
    F_AIGroupControlTargetList_0C: Integer;
    procedure GetTargets(A1: Integer);  { draft }
    procedure SortOnPriority;  { draft }
    procedure SortOnDataB;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Validate;  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
  end;

  { TAIRecruitmentGroup (instance size 40, VMT 5571A468) }
  TAIRecruitmentGroup = class(TEObject)
  public
    F_AIRecruitmentGroup_08: Integer;
    F_AIRecruitmentGroup_0C: Integer;
    F_AIRecruitmentGroup_10: Integer;
    F_AIRecruitmentGroup_14: Integer;
    F_AIRecruitmentGroup_18: Integer;
    F_AIRecruitmentGroup_1C: Integer;
    F_AIRecruitmentGroup_20: array[0..7] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate(A1: Integer; A2: Integer); virtual;  { +04C draft }
    procedure SetGroup(A1: Integer);  { draft }
  end;

  { TAIRecruitmentGroupList (instance size 12, VMT 5571A538) }
  TAIRecruitmentGroupList = class(TEReferenceNode)
  public
    procedure GetRecruitmentGroups(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Validate(A1: Integer; A2: Integer);  { draft }
    procedure UnitExists(A1: Integer);  { draft }
    procedure FindUnit(A1: Integer);  { draft }
  end;

  { TAIGroupProductionLocation (instance size 40, VMT 5571A648) }
  TAIGroupProductionLocation = class(TEObject)
  public
    F_AIGroupProductionLocation_08: Integer;
    F_AIGroupProductionLocation_0C: array[0..27] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate; virtual;  { +04C draft }
  end;

  { TAIGroupProductionLocationList (instance size 12, VMT 5571A728) }
  TAIGroupProductionLocationList = class(TEReferenceNode)
  public
    procedure GetProductionLocation(A1: Integer);  { draft }
    procedure SortOnMovePoints;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure IndexOfPC(A1: Integer);  { draft }
    procedure FindPC;  { draft }
    procedure Validate(A1: Integer; A2: Integer);  { draft }
  end;

  { TAIGroupControlPlugin (instance size 28, VMT 5571A894) }
  TAIGroupControlPlugin = class(TEObject)
  public
    F_AIGroupControlPlugin_08: Integer;
    F_AIGroupControlPlugin_0C: Integer;
    F_AIGroupControlPlugin_10: Integer;
    F_AIGroupControlPlugin_14: Byte;
    F_AIGroupControlPlugin_15: array[0..2] of Byte;
    F_AIGroupControlPlugin_18: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Validate; virtual;  { +04C draft }
    procedure GetBusy; virtual;  { +050 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure Deactivate; virtual;  { +058 draft }
    procedure Process(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure Done;  { draft }
    procedure MainProcess;  { draft }
  end;

  { TAIGroupControl (instance size 368, VMT 5571A978) }
  TAIGroupControl = class(TEObject)
  public
    F_AIGroupControl_08: Integer;
    F_AIGroupControl_0C: Integer;
    F_AIGroupControl_10: Byte;
    F_AIGroupControl_11: array[0..2] of Byte;
    F_AIGroupControl_14: Integer;
    F_AIGroupControl_18: Integer;
    F_AIGroupControl_1C: Integer;
    F_AIGroupControl_20: Byte;
    F_AIGroupControl_21: array[0..2] of Byte;
    F_AIGroupControl_24: Integer;
    F_AIGroupControl_28: Byte;
    F_AIGroupControl_29: array[0..38] of Byte;
    F_AIGroupControl_50: Integer;
    F_AIGroupControl_54: Byte;
    F_AIGroupControl_55: array[0..254] of Byte;
    F_AIGroupControl_154: Word;
    F_AIGroupControl_156: array[0..1] of Byte;
    F_AIGroupControl_158: Integer;
    F_AIGroupControl_15C: Integer;
    F_AIGroupControl_160: Integer;
    F_AIGroupControl_164: Integer;
    F_AIGroupControl_168: Integer;
    F_AIGroupControl_16C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MoveExecuterDone; virtual;  { +04C draft }
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +050 draft }
    procedure RecruitmentGroupFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +054 draft }
    procedure ProductionLocationFoundEvent(A1: Integer; A2: Integer; A3: Integer); virtual;  { +058 draft }
    procedure Validate; virtual;  { +05C draft }
    procedure ProcessStates(A1: Integer; A2: Integer); virtual;  { +060 draft }
    procedure ProcessStatesLooped; virtual;  { +064 draft }
    procedure Split; virtual;  { +068 draft }
    procedure Activate; virtual;  { +06C draft }
    procedure Deactivate; virtual;  { +070 draft }
    procedure ResetME; virtual;  { +074 draft }
    procedure SetupME(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure ExecuteME(A1: Integer; A2: Integer; A3: Integer); virtual;  { +07C draft }
    procedure Done;  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure UpdateGroupChanges;  { draft }
    procedure RetrieveGroupArmy(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure CombineIdleGroups(A1: Integer; A2: Integer);  { draft }
    procedure ResetCP;  { draft }
    procedure SetupCP(A1: Integer);  { draft }
    procedure ActivatePlugin(A1: Integer);  { draft }
    procedure DeactivatePlugin;  { draft }
    procedure MainProcessStates(A1: Integer);  { draft }
    procedure Process(A1: Byte);  { draft }
    procedure FindAvailableTransporter;  { draft }
  end;

  { TAIGroupTargetFinder (instance size 56, VMT 5571AAC4) }
  TAIGroupTargetFinder = class(TAIGroupControlPlugin)
  public
    F_AIGroupTargetFinder_1C: Integer;
    F_AIGroupTargetFinder_20: Integer;
    F_AIGroupTargetFinder_24: Byte;
    F_AIGroupTargetFinder_25: array[0..2] of Byte;
    F_AIGroupTargetFinder_28: Integer;
    F_AIGroupTargetFinder_2C: Integer;
    F_AIGroupTargetFinder_30: Integer;
    F_AIGroupTargetFinder_34: Word;
    F_AIGroupTargetFinder_36: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Reset; virtual;  { +060 draft }
    procedure Setup(A1: Integer); virtual;  { +064 draft }
    procedure TargetFoundEvent(A1: Integer; A2: Integer);  { draft }
  end;

  { TGroupDefenseSelector (instance size 16, VMT 5571ABB0) }
  TGroupDefenseSelector = class(TObject)
  public
    F_GroupDefenseSelector_04: array[0..3] of Byte;
    F_GroupDefenseSelector_08: Integer;
    F_GroupDefenseSelector_0C: Integer;
    destructor Destroy; override;
    procedure Create(A1: Byte); virtual;  { +000 draft }
    procedure GetDefenders(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure EnoughStrength(A1: Integer);  { draft }
    procedure UsefullUnit(A1: Integer; A2: Integer);  { draft }
    procedure UpdateDefenseLocation(A1: Integer);  { draft }
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
  end;

  { TAIGroupDefenseControl (instance size 40, VMT 5571ACDC) }
  TAIGroupDefenseControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupDefenseControl_1C: Integer;
    F_AIGroupDefenseControl_20: Integer;
    F_AIGroupDefenseControl_24: Byte;
    F_AIGroupDefenseControl_25: Byte;
    F_AIGroupDefenseControl_26: array[0..1] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TAIRecruitmentGroupFinder (instance size 52, VMT 5571AE1C) }
  TAIRecruitmentGroupFinder = class(TAIGroupControlPlugin)
  public
    F_AIRecruitmentGroupFinder_1C: Integer;
    F_AIRecruitmentGroupFinder_20: Integer;
    F_AIRecruitmentGroupFinder_24: Integer;
    F_AIRecruitmentGroupFinder_28: Integer;
    F_AIRecruitmentGroupFinder_2C: Integer;
    F_AIRecruitmentGroupFinder_30: Byte;
    F_AIRecruitmentGroupFinder_31: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure RecruitGroupFoundEvent(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIGroupRecruitControl (instance size 152, VMT 5571AF78) }
  TAIGroupRecruitControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupRecruitControl_1C: Byte;
    F_AIGroupRecruitControl_1D: array[0..2] of Byte;
    F_AIGroupRecruitControl_20: Integer;
    F_AIGroupRecruitControl_24: Byte;
    F_AIGroupRecruitControl_25: array[0..2] of Byte;
    F_AIGroupRecruitControl_28: Integer;
    F_AIGroupRecruitControl_2C: Byte;
    F_AIGroupRecruitControl_2D: array[0..38] of Byte;
    F_AIGroupRecruitControl_54: Integer;
    F_AIGroupRecruitControl_58: Integer;
    F_AIGroupRecruitControl_5C: Word;
    F_AIGroupRecruitControl_5E: array[0..1] of Byte;
    F_AIGroupRecruitControl_60: Byte;
    F_AIGroupRecruitControl_61: array[0..38] of Byte;
    F_AIGroupRecruitControl_88: Integer;
    F_AIGroupRecruitControl_8C: Byte;
    F_AIGroupRecruitControl_8D: array[0..2] of Byte;
    F_AIGroupRecruitControl_90: Integer;
    F_AIGroupRecruitControl_94: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup; virtual;  { +060 draft }
    procedure GetRecruitedStrength;  { draft }
    procedure GetRecruitStrengthEx(A1: Integer);  { draft }
    procedure SetRecruitStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure GetRecruitMoveDays;  { draft }
    procedure UsefullRecruitUnit(A1: Integer);  { draft }
    procedure UpdateCompletion;  { draft }
    procedure AddRecruitUnit(A1: Integer);  { draft }
    procedure DeleteRecruitUnit(A1: Integer);  { draft }
    procedure ExecuteRecruitment;  { draft }
    procedure ValidRecruitmentGroup(A1: Integer);  { draft }
    procedure RecruitFromGroup(A1: Integer);  { draft }
    procedure Reset;  { draft }
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
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
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

  { TAIProductionLocationFinder (instance size 52, VMT 5571B218) }
  TAIProductionLocationFinder = class(TAIGroupControlPlugin)
  public
    F_AIProductionLocationFinder_1C: Integer;
    F_AIProductionLocationFinder_20: Integer;
    F_AIProductionLocationFinder_24: Byte;
    F_AIProductionLocationFinder_25: array[0..2] of Byte;
    F_AIProductionLocationFinder_28: Integer;
    F_AIProductionLocationFinder_2C: Integer;
    F_AIProductionLocationFinder_30: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure ProductionLocationFoundEvent(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
  end;

  { TAIGroupUnitProduction (instance size 48, VMT 5571B36C) }
  TAIGroupUnitProduction = class(TEObject)
  public
    F_AIGroupUnitProduction_08: Integer;
    F_AIGroupUnitProduction_0C: Integer;
    F_AIGroupUnitProduction_10: Integer;
    F_AIGroupUnitProduction_14: Integer;
    F_AIGroupUnitProduction_18: Integer;
    F_AIGroupUnitProduction_1C: Integer;
    F_AIGroupUnitProduction_20: Integer;
    F_AIGroupUnitProduction_24: Integer;
    F_AIGroupUnitProduction_28: Integer;
    F_AIGroupUnitProduction_2C: Byte;
    F_AIGroupUnitProduction_2D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure SetU(A1: Integer);  { draft }
    procedure SetProductionLocation(A1: Integer);  { draft }
  end;

  { TAIGroupUnitProductionList (instance size 12, VMT 5571B440) }
  TAIGroupUnitProductionList = class(TEReferenceNode)
  public
    procedure GetUnitProductions(A1: Integer);  { draft }
  end;

  { TAIGroupProductionControl (instance size 192, VMT 5571B558) }
  TAIGroupProductionControl = class(TAIGroupControlPlugin)
  public
    F_AIGroupProductionControl_1C: Integer;
    F_AIGroupProductionControl_20: Byte;
    F_AIGroupProductionControl_21: Byte;
    F_AIGroupProductionControl_22: array[0..1] of Byte;
    F_AIGroupProductionControl_24: Integer;
    F_AIGroupProductionControl_28: Integer;
    F_AIGroupProductionControl_2C: Integer;
    F_AIGroupProductionControl_30: Integer;
    F_AIGroupProductionControl_34: Integer;
    F_AIGroupProductionControl_38: Integer;
    F_AIGroupProductionControl_3C: Byte;
    F_AIGroupProductionControl_3D: array[0..38] of Byte;
    F_AIGroupProductionControl_64: Integer;
    F_AIGroupProductionControl_68: Integer;
    F_AIGroupProductionControl_6C: Word;
    F_AIGroupProductionControl_6E: array[0..1] of Byte;
    F_AIGroupProductionControl_70: Byte;
    F_AIGroupProductionControl_71: array[0..38] of Byte;
    F_AIGroupProductionControl_98: Integer;
    F_AIGroupProductionControl_9C: Byte;
    F_AIGroupProductionControl_9D: array[0..2] of Byte;
    F_AIGroupProductionControl_A0: Integer;
    F_AIGroupProductionControl_A4: Integer;
    F_AIGroupProductionControl_A8: Integer;
    F_AIGroupProductionControl_AC: Byte;
    F_AIGroupProductionControl_AD: array[0..2] of Byte;
    F_AIGroupProductionControl_B0: Integer;
    F_AIGroupProductionControl_B4: Byte;
    F_AIGroupProductionControl_B5: array[0..2] of Byte;
    F_AIGroupProductionControl_B8: Integer;
    F_AIGroupProductionControl_BC: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer); virtual;  { +060 draft }
    procedure GetProducedStrength;  { draft }
    procedure GetProduceStrengthEx(A1: Integer);  { draft }
    procedure SetProduceStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure UnitProductionPriority(A1: Integer);  { draft }
    procedure GetCurrentProductionTime;  { draft }
    procedure GetCompleteProductionTime;  { draft }
    procedure UpdateCompletion;  { draft }
    procedure ExecuteProductions(A1: Integer);  { draft }
    procedure AddProduction(A1: Integer);  { draft }
    procedure DeleteProduction(A1: Integer);  { draft }
    procedure Reset;  { draft }
    procedure ListProduceableUnits(A1: Integer);  { draft }
    procedure ValidProductionLocation(A1: Integer);  { draft }
    procedure UpdateProduceableUnits;  { draft }
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
    procedure GetBusy; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
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
  THuntAG = class(TAIGroup)
  public
    F_HuntAG_50: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GroupControlClass; override;
    class function Behavior: TGroupBehavior; override;
    procedure HuntingPlayer(A1: Integer);  { draft }
  end;

  { THuntAGC (instance size 368, VMT 5571BA18) }
  THuntAGC = class(TAIGroupControl)
  public
    procedure TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer); override;
    procedure ProcessStates(A1: Integer; A2: Integer); override;
  end;

  { TGroupControl (instance size 8, VMT 5571BB04) }
  TGroupControl = class(TEObject)
  public
    procedure Behavior; virtual;  { +04C draft }
  end;

  { TGuardGC (instance size 8, VMT 5571BBC8) }
  TGuardGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TPassiveGC (instance size 8, VMT 5571BC84) }
  TPassiveGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TGuardAreaGC (instance size 8, VMT 5571BD44) }
  TGuardAreaGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TSuicidalGC (instance size 8, VMT 5571BE08) }
  TSuicidalGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TPatrolGC (instance size 8, VMT 5571BEC8) }
  TPatrolGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TScoutGC (instance size 8, VMT 5571BF84) }
  TScoutGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TRefugeGC (instance size 8, VMT 5571C040) }
  TRefugeGC = class(TGroupControl)
  public
    class function ClassID: Integer; override;
    procedure Behavior; override;
  end;

  { TEndTurnTE (instance size 28, VMT 5571C138) }
  TEndTurnTE = class(TTokenEvent)
  public
    F_EndTurnTE_10: Byte;
    F_EndTurnTE_11: array[0..2] of Byte;
    F_EndTurnTE_14: Integer;
    F_EndTurnTE_18: Byte;
    F_EndTurnTE_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TChangePlayerSettingsTE (instance size 24, VMT 5571C1F8) }
  TChangePlayerSettingsTE = class(TTokenEvent)
  public
    F_ChangePlayerSettingsTE_10: Byte;
    F_ChangePlayerSettingsTE_11: array[0..2] of Byte;
    F_ChangePlayerSettingsTE_14: Integer;
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
    F_MultiMoveTE_10: Integer;
    F_MultiMoveTE_14: Byte;
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
    FPlayer: Byte;
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
    F_SaveGameTE_10: Integer;
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
    F_TerminatePlayerTE_10: Byte;
    F_TerminatePlayerTE_11: array[0..2] of Byte;
    F_TerminatePlayerTE_14: Byte;
    F_TerminatePlayerTE_15: array[0..0] of Byte;
    F_TerminatePlayerTE_16: Word;
    F_TerminatePlayerTE_18: Integer;
    F_TerminatePlayerTE_1C: Byte;
    F_TerminatePlayerTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TFastCombatUnit (instance size 100, VMT 5571D4BC) }
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
    procedure CanCastWallSiegeSpell;  { draft }
    procedure UpdateWallSiegeObjectRegistration;  { draft }
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
    F_FastCombat_4C: Integer;
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
    procedure GetWallInBetween(A1: Integer; A2: Integer);  { draft }
    procedure GetWallSituation(A1: Integer; A2: Integer);  { draft }
    procedure AttackerCanCrushWall;  { draft }
    procedure GetAttackerBalisticCV(A1: Integer; A2: Integer);  { draft }
    procedure GetDefenderBalisticCV(A1: Integer; A2: Integer);  { draft }
    procedure ValidateWallBreaching;  { draft }
    procedure ExecuteCombatRound;  { draft }
  end;

