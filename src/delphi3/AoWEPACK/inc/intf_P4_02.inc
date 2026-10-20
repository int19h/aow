{ Interface declaration run owned by P4. }
  { TAbilityPlugIn (instance size 16, VMT 5571D8AC) }
  TAbilityPlugIn = class(TPlugIn)
  public
    function Name: string; override;
    function Initialize(AEngine: Engine.TEngine): Boolean; override;
    function Finalize(AEngine: Engine.TEngine): Boolean; override;
  end;

  { TAdjustableAbility (instance size 40, VMT 5571D930; $24 ability type) }
  TAdjustableAbility = class(TAbility)
  public
    FAbilityType: TAbilityType; { $24 }
    FAbilityTypePadding: array[0..2] of Byte; { $25 }
    function GetAbilityType: TAbilityType; override;
  end;

  { TEnhancementAbility (instance size 40, VMT 5571DABC) }
  TEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDurationAbilityData (instance size 20, VMT 5571DC94;
    $0C duration, $0D player index, $0E ability ID, $10 unresolved Integer) }
  TDurationAbilityData = class(TAbilityData)
  public
    FDuration: Byte;
    FPlayerIndex: Byte;
    FAbilityID: Word;
    F_DurationAbilityData_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TDurationAbility (instance size 44, VMT 5571DD68; $28 duration mode) }
  TDurationAbility = class(TAdjustableAbility)
  public
    FDurationMode: TDurationMode;
    FDurationPadding: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    procedure NewDay(A1: TAbilityOwner); override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); override;
    procedure CombatDone(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
    function GetDuration(AbilityOwner: TAbilityOwner): Byte; virtual; { +10C }
    function GetTotalDuration: Integer; virtual;
  end;

  { TMultiLevelAbilityData (instance size 16, VMT 5571DEF8; $0C level, $0E ability ID) }
  TMultiLevelAbilityData = class(TAbilityData)
  public
    FLevel: Byte;
    F_MultiLevelAbilityData_0D: array[0..0] of Byte;
    FLevelAbilityID: Word;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TMultiLevelAbility (instance size 48, VMT 5571DFD0; $28 max level, $2C level costs) }
  TMultiLevelAbility = class(TAdjustableAbility)
  public
    FMaxLevel: Integer;
    FLevelCosts: TIntegerList; { $2C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure GetInherentLevel(A1: Integer); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function AbilityDataClass: TEObjectClass; override;
    function GetLevelName(A1: Integer): string; virtual;
  end;

  { TTransportAbility (instance size 48, VMT 5571E160) }
  TTransportAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLevelName(A1: Integer): string; override;
  end;

  { TStrikeCA (instance size 28, VMT 5571E344; $18 strike mode) }
  TStrikeCA = class(TDamageCA)
  public
    FStrikeMode: TStrikeMode;  { $18 }
    F_StrikeCA_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes); override;
  end;

  { TMeleeRound (instance size 52, VMT 5571E460; $04 strike count, $30 attacker damage types) }
  TMeleeRound = class(TObject)
  public
    FCount: Integer;  { $04 }
    F_MeleeRound_08: Integer;
    F_MeleeRound_0C: Integer;
    F_MeleeRound_10: Integer;
    F_MeleeRound_14: Integer;
    F_MeleeRound_18: Integer;
    F_MeleeRound_1C: Integer;
    F_MeleeRound_20: Integer;
    F_MeleeRound_24: Integer;
    F_MeleeRound_28: Integer;
    F_MeleeRound_2C: Integer;
    FAttackerDamageTypes: TDamageTypes;  { $30 }
    F_MeleeRound_32: Word;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure SetCapacity(A1: Integer);  { draft }
    procedure SetCount(A1: Integer);  { draft }
    procedure GetMeleeStrike(A1: Integer; var A2: TMeleeStrike);
    procedure Reset;  { draft }
    procedure CalculateUnitStrikes(A1: Byte);  { draft }
    procedure CalculateFreeUnitSwing(A1: Integer; A2: Integer);  { draft }
    procedure CalculateUnit(A1, A2: TAbstractUnit);
    procedure CalculateStrikes(A1: Byte);  { draft }
    procedure Calculate(A1, A2: TCombatObject);
    procedure CalculateSingleSide(A1: Integer; A2: Integer);  { draft }
    function CreateStrikeCA(A1: Integer): TStrikeCA;
    procedure CalculateDV(A1: Integer; A2: Integer);  { draft }
    function GetAttackerDV: Integer;
    function GetDefenderDV: Integer;
  end;

  { TStrikeEnhancementAbility (instance size 40, VMT 5571E4D0) }
  TStrikeEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
  end;

  { TStrikeAbility (instance size 44, VMT 5571E668; $28 melee round) }
  TStrikeAbility = class(TAdjustableAbility)
  public
    FMeleeRound: TMeleeRound;  { $28 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCombatMode(A1: TAbilityOwner): TCombatMode; override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function CanExecuteMelee(A1, A2: TCombatObject): Boolean;
    function GetDamageTypes(A1: TAbilityOwner): TDamageTypes;
  end;

  { TRangedAttackCA (instance size 28, VMT 5571E7EC) }
  TRangedAttackCA = class(TDamageCA)
  public
    F_RangedAttackCA_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TRangedAttackAbility (instance size 48, VMT 5571E8D4) }
  TRangedAttackAbility = class(TAdjustableAbility)
  public
    F_RangedAttackAbility_28: Integer;
    F_RangedAttackAbility_2C: array[0..0] of Byte;
    F_RangedAttackAbility_2D: Byte;
    F_RangedAttackAbility_2E: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCombatMode(A1: TAbilityOwner): TCombatMode; override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function GetControlType: TAbilityControlType; override;
    function fcValidRoundDistance(A1, A2: TCombatObject): Boolean; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    procedure GetRangeRA; virtual;  { +10C draft }
    procedure GetDamageRA(A1: Integer); virtual;  { +110 draft }
    procedure GetAttackRA(A1: Integer); virtual;  { +114 draft }
    procedure GetAttackRepeatRA; virtual;  { +118 draft }
    procedure GetDamageTypesRA; virtual;  { +11C draft }
    procedure CreateRangedAttackCA(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TBoltsAbility (instance size 48, VMT 5571EA78) }
  TBoltsAbility = class(TRangedAttackAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TBreathAbility (instance size 48, VMT 5571EC0C) }
  TBreathAbility = class(TRangedAttackAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; A3: Pointer); override;
  end;

  { TFlameThrowingAbility (instance size 48, VMT 5571EDA4) }
  TFlameThrowingAbility = class(TBreathAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
  end;

  { TTouchAbility (instance size 40, VMT 5571EF48) }
  TTouchAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCombatMode(A1: TAbilityOwner): TCombatMode; override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    procedure GetTouchAttack(A1: Integer); virtual;  { +10C draft }
    procedure CombatTouchRole(A1: Integer; A2: Integer); virtual;  { +110 draft }
    procedure CombatTouchRoleProbability(A1: Integer; A2: Integer); virtual;  { +114 draft }
    procedure TouchRoleProbability(A1: Integer; A2: Integer); virtual;  { +118 draft }
    procedure CanTouch(A1: Integer; A2: Integer); virtual;  { +11C draft }
    procedure CanTouchUnit(A1: Integer; A2: Integer); virtual;  { +120 draft }
    procedure fcValidateMoveOutsideWall(A1: Integer; A2: Integer);  { draft }
  end;

  { TPossessCA (instance size 20, VMT 5571F0E0) }
  TPossessCA = class(TSingleTargetCA)
  public
    F_PossessCA_10: Byte;
    F_PossessCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TPossessAbility (instance size 40, VMT 5571F1B4) }
  TPossessAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreatePossessCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TPossessedAbilityData (instance size 16, VMT 5571F350) }
  TPossessedAbilityData = class(TAbilityData)
  public
    F_PossessedAbilityData_0C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TPossessedAbility (instance size 40, VMT 5571F424) }
  TPossessedAbility = class(TPossessAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure CombatObjectDestroyed(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
  end;

  { TWebCA (instance size 20, VMT 5571F5C4) }
  TWebCA = class(TSingleTargetCA)
  public
    F_WebCA_10: Byte;
    F_WebCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TWebAbility (instance size 40, VMT 5571F690) }
  TWebAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CreateWebCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TEntangleCA (instance size 20, VMT 5571F824) }
  TEntangleCA = class(TSingleTargetCA)
  public
    F_EntangleCA_10: Byte;
    F_EntangleCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TEntangleAbility (instance size 40, VMT 5571F8F8) }
  TEntangleAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CreateEntangleCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TInvokeDeathCA (instance size 20, VMT 5571FA98) }
  TInvokeDeathCA = class(TSingleTargetCA)
  public
    F_InvokeDeathCA_10: Byte;
    F_InvokeDeathCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TInvokeDeathAbility (instance size 40, VMT 5571FB74) }
  TInvokeDeathAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TTurnUndeadCA (instance size 24, VMT 5571FD18) }
  TTurnUndeadCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure GetSuccessfull;  { draft }
  end;

  { TTurnUndeadAbility (instance size 40, VMT 5571FDFC) }
  TTurnUndeadAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    procedure GetSkillPoints(A1: Integer); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure GetLevelName(A1: Integer; A2: Integer);  { draft }
    procedure GetTurnUndeadDamage(A1: Integer);  { draft }
    procedure CreateTurnUndeadCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TRoundAttackAbility (instance size 40, VMT 5571FFA0) }
  TRoundAttackAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; A3: Pointer); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
  end;

  { TCommandedAbilityData (instance size 28, VMT 55720144) }
  TCommandedAbilityData = class(TAbilityData)
  public
    F_CommandedAbilityData_0C: Integer;
    F_CommandedAbilityData_10: Byte;
    F_CommandedAbilityData_11: array[0..2] of Byte;
    F_CommandedAbilityData_14: Integer;
    F_CommandedAbilityData_18: Byte;
    F_CommandedAbilityData_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TCommandedAbility (instance size 40, VMT 55720218) }
  TCommandedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure CombatObjectDestroyed(A1: TCombatObject); override;
    procedure CombatDone(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
  end;

  { TCommandCA (instance size 24, VMT 557203A0) }
  TCommandCA = class(TSingleTargetCA)
  public
    F_CommandCA_10: Integer;
    F_CommandCA_14: Byte;
    F_CommandCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TCommandAbilityData (instance size 20, VMT 55720474) }
  TCommandAbilityData = class(TAbilityData)
  public
    F_CommandAbilityData_0C: Integer;
    F_CommandAbilityData_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
    function CommandingTargetPriority(Combat: TCombat): Integer;
    function CommandingTargetStrength(Combat: TCombat): Integer;
  end;

  { TCommandAbility (instance size 44, VMT 55720544) }
  TCommandAbility = class(TTouchAbility)
  public
    F_CommandAbility_28: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAbilityType: TAbilityType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure CombatObjectDestroyed(A1: TCombatObject); override;
    procedure CombatDone(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure Command(A1: Integer; A2: Integer); virtual;  { +124 draft }
    procedure CreateCommandCA(A1: Integer; A2: Integer); virtual;  { +128 draft }
    procedure ResetCommandedUnits(A1: Integer; A2: Integer); virtual;  { +12C draft }
    procedure Uncommand(A1: Integer); virtual;  { +130 draft }
  end;

  { TDominatedAbility (instance size 40, VMT 557206F0) }
  TDominatedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDominateAbility (instance size 44, VMT 55720878) }
  TDominateAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
  end;

  { TCharmedAbility (instance size 40, VMT 55720A28) }
  TCharmedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TCharmAbility (instance size 44, VMT 55720BAC) }
  TCharmAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
  end;

  { TSeducedAbility (instance size 40, VMT 55720D54) }
  TSeducedAbility = class(TCommandedAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TSeduceAbility (instance size 44, VMT 55720ED8) }
  TSeduceAbility = class(TCommandAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
  end;

  { TSelfDestructCA (instance size 24, VMT 55721084) }
  TSelfDestructCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TSelfDestructAbility (instance size 40, VMT 5572116C) }
  TSelfDestructAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateSelfDestructCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TWallCrushingAbility (instance size 40, VMT 55721314) }
  TWallCrushingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; A3: Pointer); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
  end;

  { THealingCA (instance size 16, VMT 557214BC) }
  THealingCA = class(TSingleTargetCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte);  { draft }
  end;

  { THealingAbilityData (instance size 16, VMT 55721590) }
  THealingAbilityData = class(TAbilityData)
  public
    F_HealingAbilityData_0C: Byte;
    F_HealingAbilityData_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { THealingTE (instance size 32, VMT 55721660) }
  THealingTE = class(TTokenEvent)
  public
    F_HealingTE_10: Integer;
    F_HealingTE_14: Byte;
    F_HealingTE_15: array[0..2] of Byte;
    F_HealingTE_18: Integer;
    F_HealingTE_1C: Byte;
    F_HealingTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THealingUnitSelector (instance size 44, VMT 55721720) }
  THealingUnitSelector = class(TUnitSelector)
  public
    procedure CanSelectUnit(A1: Integer); override;
    procedure Select; override;
  end;

  { THealingAbility (instance size 40, VMT 557217BC) }
  THealingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetEnabled(A1: TAbilityOwner): Boolean; override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure SetEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetHealHitPoints(A1: Integer);  { draft }
    procedure CreateHealingCA(A1: Integer; A2: Integer);  { draft }
    procedure HealUnit(A1: Integer);  { draft }
  end;

  { TDispelMagicCA (instance size 20, VMT 55721958) }
  TDispelMagicCA = class(TSingleTargetCA)
  public
    F_DispelMagicCA_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Generate(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TDispelMagicAbilityCA (instance size 20, VMT 55721A34) }
  TDispelMagicAbilityCA = class(TDispelMagicCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TDispelMagicAbilityTE (instance size 32, VMT 55721B1C) }
  TDispelMagicAbilityTE = class(TTokenEvent)
  public
    F_DispelMagicAbilityTE_10: Integer;
    F_DispelMagicAbilityTE_14: Byte;
    F_DispelMagicAbilityTE_15: array[0..2] of Byte;
    F_DispelMagicAbilityTE_18: Integer;
    F_DispelMagicAbilityTE_1C: Byte;
    F_DispelMagicAbilityTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TDispelMagicAbilityData (instance size 16, VMT 55721BF0) }
  TDispelMagicAbilityData = class(TAbilityData)
  public
    F_DispelMagicAbilityData_0C: Byte;
    F_DispelMagicAbilityData_0D: Byte;
    F_DispelMagicAbilityData_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TDispelMagicAbilityUnitSelector (instance size 44, VMT 55721CC8) }
  TDispelMagicAbilityUnitSelector = class(TUnitSelector)
  public
    procedure CanSelectUnit(A1: Integer); override;
    procedure Select; override;
  end;

  { TDispelMagicAbility (instance size 40, VMT 55721D78) }
  TDispelMagicAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    function GetEnabled(A1: TAbilityOwner): Boolean; override;
    procedure GetSkillPoints(A1: Integer); override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure SetEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetDispelMana(A1: Integer);  { draft }
    procedure GetLevelName(A1: Integer; A2: Integer);  { draft }
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TLeadershipAbilityData (instance size 24, VMT 55721F1C; $10 external level, $14 source name) }
  TLeadershipAbilityData = class(TMultiLevelAbilityData)
  public
    FExternalLevel: Byte;  { $10 }
    F_LeadershipAbilityData_11: array[0..2] of Byte;
    FExternalSource: string;  { $14 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TLeadershipAbility (instance size 48, VMT 55722008) }
  TLeadershipAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack(A1: TAbilityOwner): Shortint; override;
    function GetDefense(A1: TAbilityOwner): Shortint; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    function GetInherent(A1: TAbilityOwner): Boolean; override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    function AbilityDataClass: TEObjectClass; override;
    function GetLevelName(A1: Integer): string; override;
    procedure SetExternalSource(A1: TAbilityOwner; A2: Byte; SourceName: string);
    procedure ResetExternalSource(A1: TAbilityOwner);
  end;

  { TUnitEnchantment (instance size 32, VMT 55722198; $18 unit ID, $1C ability ID) }
  TUnitEnchantment = class(TEnchantment)
  public
    FUnitID: Integer;  { $18 }
    FEnchantmentAbilityID: Integer;  { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
    function GetBinding: string; override;
    function GetAIUpkeepPriority: Integer; override;
    procedure GetLocation(var A1, A2, A3: Shortint); override;
    function Dispel: Boolean; override;
    procedure Select; override;
  end;

  { TUnitEnchantmentAbilityData (instance size 20, VMT 55722284; $0C ability ID, $0E duration, $0F player, $10 enchantment) }
  TUnitEnchantmentAbilityData = class(TAbilityData)
  public
    FEnchantmentAbilityID: Word;
    FEnchantmentDuration: ShortInt; { $0E; -1 is permanent }
    FEnchantmentPlayerIndex: ShortInt; { $0F }
    FEnchantment: TUnitEnchantment; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
    procedure SetEnchantment(Enchantment: TUnitEnchantment);
  end;

  { TUnitEnchantmentAbility (instance size 40, VMT 55722364) }
  TUnitEnchantmentAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetSourceName(A1: TAbilityOwner): string; override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure NewCombatTurn(A1: TCombatObject; A2: Shortint); override;
    procedure CombatDone(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
    function GetDurationMode: TDurationMode; virtual;
    function GetDuration(A1: TAbilityOwner): Byte; virtual; { +110 }
    function GetAIUpkeepPriority(A1: TAbilityOwner): Integer; virtual;
    function GetTotalDuration: Shortint; virtual;
    function CreateEnchantment: TUnitEnchantment; virtual;
  end;

  { TConstructionControl (instance size 8, VMT 5572250C) }
  TConstructionControl = class(TEObject)
  public
    procedure GetInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +04C draft }
    procedure CanConstruct(A1: Integer; A2: Integer); virtual;  { +050 draft }
    procedure Construct(A1: Integer); virtual;  { +054 draft }
    procedure ID; virtual;  { +058 draft }
  end;

  { TConstructionControlList (instance size 12, VMT 557225EC) }
  TConstructionControlList = class(TENode)
  public
    procedure GetConstructionControl(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
  end;

  { TConstructAbility (instance size 44, VMT 55722700) }
  TConstructAbility = class(TAdjustableAbility)
  public
    F_ConstructAbility_28: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetControlType: TAbilityControlType; override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure RegisterConstructionControl(A1: Integer);  { draft }
  end;

  { TCosmeticSurgeryEnchantment (instance size 36, VMT 55722888) }
  TCosmeticSurgeryEnchantment = class(TUnitEnchantment)
  public
    F_CosmeticSurgeryEnchantment_20: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
  end;

  { TCosmeticSurgeryAbility (instance size 40, VMT 55722988) }
  TCosmeticSurgeryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateEnchantment: TUnitEnchantment; override;
  end;

  { TSpellCastingAbility (instance size 48, VMT 55722B30) }
  TSpellCastingAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: Boolean; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; A3: Pointer); override;
    function GetLevelName(A1: Integer): string; override;
    function CanCastBreachWallSpell(AUnit: TAbstractUnit): Boolean;
    procedure AICanCastCombatSpell(A1: Integer);  { draft }
  end;

  { TSpellCC (instance size 32, VMT 55722D0C) }
  TSpellCC = class(TFastCombatCommand)
  public
    F_SpellCC_1C: Integer;
    procedure GetName(A1: Integer); override;
  end;

  { TSpell (instance size 52, VMT 55722D7C; $08 name, $0C control types,
    $10 spell ID, $14 base mana cost, $20 sphere, $21 level, $22 type,
    $24 text, $28 sounds, $2C images; $18/$1C/$30 remain unresolved Integers) }
  TSpell = class(TEObject)
  public
    FSpellName: string; { $08 }
    FSpellControlTypes: TSpellControlType; { $0C }
    F_Spell_0D: array[0..2] of Byte;
    FSpellID: Integer;
    FBaseManaCost: Integer;
    F_Spell_18: Integer;
    FManaUpkeep: Integer; { $1C }
    FMagicSphere: TMagicSphere; { $20 }
    FSpellLevel: Byte;
    FSpellType: TSpellType; { $22; stGlobal guard at 557792E8 }
    F_Spell_23: array[0..0] of Byte;
    FSpellText: TStringList; { $24 }
    FCastSounds: TSFXLibrary; { $28 }
    FCastImages: TImageSequenceList; { $2C }
    { conflict: FImageSequences: TImageSequenceList; }
    FCastDuration: Integer; { $30 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual; { +04C; byte coordinates, external overrides are draft }
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; virtual;  { +050 }
    function CreateCastSpellAction: TAICastSpellAction; virtual;  { +054 }
    procedure SetupCastSpellAction(A1: TAbstractUnit; A2: TAICastSpellAction); virtual;  { +058 }
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); virtual;  { +05C }
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; virtual;  { +060 }
    procedure GetEnabled; virtual;  { +064 draft }
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; virtual;  { +068 }
    function Activate(A1: TAbstractUnit): Boolean; virtual;  { +06C }
    procedure CanActivateCombat(A1: Integer; A2: Integer); virtual;  { +070 draft }
    procedure ActivateCombat(A1: Integer); virtual;  { +074 draft }
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); virtual;  { +078 draft }
    procedure GetCombatInfo(A1: Integer; A2: Integer); virtual;  { +07C draft }
    procedure GetCombatDamageValue(A1: Integer; A2: Integer); virtual;  { +080 draft }
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +084 draft }
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; A3: Pointer); virtual;  { +088 }
    procedure tcGetDamageValue; virtual;  { +08C draft }
    procedure fcPrefetchCombatCommands(A1: Integer); virtual;  { +090 draft }
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); virtual;  { +094 draft }
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +098 draft }
    procedure CastingDone(Source: TAbstractUnit; Mana: Integer);
    procedure CombatCastingDone(Source: TCombatObject; Mana: Integer);
    procedure CombatSpellCast(Source: TCombatUnit);
    function AIRequestCastSpellExpense(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
    function AICastSpellExpenseMade(Source: TAbstractUnit; Budget, Mana, Upkeep: Integer): Boolean;
  end;

  { TSpellControl (instance size 12, VMT 55722E94; $08 registered-spell list) }
  TSpellControl = class(TEObject)
  public
    FRegisteredSpells: TList; { $08 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCount: Integer;
    function GetSpell(Index: Integer): TSpell;
    { conflict: function GetSpell(SpellID: Integer): TSpell; }
    procedure RegisterSpell(Spell: TSpell);
    procedure UnregisterSpell(Spell: TSpell);
    procedure UnregisterSpellID(A1: Integer);  { draft }
    procedure UnregisterAll;  { draft }
    procedure ListSpells(SpellStrings: TStrings; Spheres: TMagicSpheres);
    function GetRandomSpell(MinLevel, MaxLevel: Integer; Spheres: TMagicSpheres): Integer;
  end;

  { TSpellList (instance size 8, VMT 55722F54; $04 spell list) }
  TSpellList = class(TObject)
  public
    FSpells: TList; { $04 }
    destructor Destroy; override;
    constructor Create;  { draft }
    function GetSpell(Index: Integer): TSpell;
    function GetCount: Integer;
    procedure Add(Spell: TSpell);
    procedure Delete(Index: Integer);
    procedure Clear;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnLevel;  { draft }
  end;

  { TSpellTE (instance size 32, VMT 55722FC4; $10 spell ID, $14 source ID, $18 player, $1C mana) }
  TSpellTE = class(TTokenEvent)
  public
    FEventSpellID: Integer;
    FEventSourceID: Integer;
    FEventPlayerIndex: Byte;
    F_SpellTE_19: array[0..2] of Byte;
    FEventMana: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    function Validate(A1: THero): Boolean; virtual;  { +050 }
    function Process(A1: Integer; A2: Integer): Boolean; virtual;  { +054  }
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Initialize(SpellID: Integer; PlayerIndex: Byte; SourceID, Mana: Integer);
    function GetSource: TAbstractUnit;
  end;

  { TSpellCaster (instance size 20, VMT 5572308C; $08 spell ID, $0C source ID, $10 refcount) }
  TSpellCaster = class(TEObject)
  public
    FCasterSpellID: Integer;
    FCasterSourceID: Integer;
    FCasterRefCount: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure CanCast(A1: Integer); virtual;  { +04C draft }
    procedure Cast; virtual;  { +050 draft }
    function GetSource: TAbstractUnit;
  end;

  { TCombatSpellCaster (instance size 20, VMT 55723154; $08 spell ID, $0C source ID, $10 refcount) }
  TCombatSpellCaster = class(TEObject)
  public
    FCombatCasterSpellID: Integer; { $08 }
    FCombatCasterSourceID: Integer; { $0C }
    FCombatCasterRefCount: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
  end;

  { TSpellCastEventLog (instance size 32, VMT 55723220) }
  TSpellCastEventLog = class(TEventLog)
  public
    F_SpellCastEventLog_18: Integer;
    F_SpellCastEventLog_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TUnitSpellCaster (instance size 28, VMT 55723318; $14 target-unit users, $18 selection bits) }
  TUnitSpellCaster = class(TSpellCaster)
  public
    FTargetUnits: TUnitUserList; { $14 }
    FSelectionMask: Byte;
    F_UnitSpellCaster_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanCast(A1: Integer); override;
    procedure Cast; override;
    procedure SetSelection(Selection: Byte);
    function GetSelectionCount: Integer;
    function GetRequiredMana: Integer;
    function GetRequiredDays: Integer;
    function Valid: Boolean;
  end;

  { TUnitSpellTE (instance size 52, VMT 557233E8) }
  TUnitSpellTE = class(TSpellTE)
  public
    F_UnitSpellTE_20: Integer;
    F_UnitSpellTE_24: Integer;
    F_UnitSpellTE_28: Byte;
    F_UnitSpellTE_29: array[0..10] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: Integer; A2: Integer): Boolean; override;
    procedure Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TUnitSpellCA (instance size 32, VMT 557234B8) }
  TUnitSpellCA = class(TCombatAction)
  public
    F_UnitSpellCA_0C: Integer;
    F_UnitSpellCA_10: Byte;
    F_UnitSpellCA_11: Byte;
    F_UnitSpellCA_12: array[0..9] of Byte;
    F_UnitSpellCA_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TUnitSpell (instance size 68, VMT 55723590) }
  TUnitSpell = class(TSpell)
  public
    F_UnitSpell_34: Byte;
    F_UnitSpell_35: array[0..2] of Byte;
    F_UnitSpell_38: Integer;
    F_UnitSpell_3C: Byte;
    F_UnitSpell_3D: array[0..2] of Byte;
    F_UnitSpell_40: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    procedure CanActivateCombat(A1: Integer; A2: Integer); override;
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure ValidTargetUnit(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure ValidateUnitSelection(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A0 draft }
    procedure SetupUSC(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A4 draft }
    procedure CastSpell(A1: Integer; A2: Integer); virtual;  { +0A8 draft }
    procedure ValidTargetParty(A1: Integer; A2: Integer); virtual;  { +0AC draft }
    procedure TargetPartySelected(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    procedure ExecuteSpell(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0B4 draft }
    procedure CreateCAEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0B8 draft }
    procedure ExecuteCA(A1: Integer; A2: Integer); virtual;  { +0BC draft }
    procedure AIRetrieveOptimalTargetUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0C0 draft }
    procedure OnValidateTarget(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure OnTargetSelectionChange(A1: Integer; A2: Integer);  { draft }
    procedure ResetTargetSelection;  { draft }
    procedure SetupTargetSelection(A1: Integer; A2: Integer);  { draft }
  end;

  { TResearchSpellAIPA (instance size 20, VMT 557236C4) }
  TResearchSpellAIPA = class(TAIPlayerAction)
  public
    procedure Priority; override;
    function Process: Boolean; override;
  end;

  { TAICastSpellAction (instance size 28, VMT 557237A8) }
  TAICastSpellAction = class(TEObject)
  public
    F_AICastSpellAction_08: array[0..15] of Byte;
    FPriority: Integer; { $18 }
  end;

  { TAICastSpellActionList (instance size 12, VMT 55723874) }
  TAICastSpellActionList = class(TENode)
  public
    procedure GetCastSpellActions(A1: Integer);  { draft }
    procedure SortOnPriority;  { draft }
  end;

  { TCastSpellAIPA (instance size 40, VMT 55723984) }
  TCastSpellAIPA = class(TAIPlayerAction)
  public
    F_CastSpellAIPA_14: Integer;
    F_CastSpellAIPA_18: Integer;
    F_CastSpellAIPA_1C: Integer;
    F_CastSpellAIPA_20: Integer;
    F_CastSpellAIPA_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Priority; override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
    procedure PrefetchCastSpellActions(A1: Integer);  { draft }
    procedure CastingHeroesMax;  { draft }
    procedure ProcessStates;  { draft }
  end;

