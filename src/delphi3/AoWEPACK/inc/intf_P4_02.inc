{ Interface declaration run owned by P4. }
  { TAbilityPlugIn (instance size 16, VMT 5571D8AC) }
  TAbilityPlugIn = class(TPlugIn)
  public
    function Name: string; override;
    function Initialize(AEngine: Engine.TEngine): Boolean; override;
    function Finalize(AEngine: Engine.TEngine): Boolean; override;
  end;

  { TAdjustableAbility (instance size 40, VMT 5571D930) }
  TAdjustableAbility = class(TAbility)
  public
    F_AdjustableAbility_24: Integer;
    procedure GetAbilityType; override;
  end;

  { TEnhancementAbility (instance size 40, VMT 5571DABC) }
  TEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TDurationAbilityData (instance size 20, VMT 5571DC94) }
  TDurationAbilityData = class(TAbilityData)
  public
    F_DurationAbilityData_0C: Byte;
    F_DurationAbilityData_0D: Byte;
    F_DurationAbilityData_0E: Word;
    F_DurationAbilityData_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TDurationAbility (instance size 44, VMT 5571DD68) }
  TDurationAbility = class(TAdjustableAbility)
  public
    F_DurationAbility_28: Byte;
    F_DurationAbility_29: array[0..2] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure NewDay(A1: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetDuration(A1: Integer); virtual;  { +10C draft }
    procedure GetTotalDuration; virtual;  { +110 draft }
  end;

  { TMultiLevelAbilityData (instance size 16, VMT 5571DEF8) }
  TMultiLevelAbilityData = class(TAbilityData)
  public
    F_MultiLevelAbilityData_0C: Byte;
    F_MultiLevelAbilityData_0D: array[0..0] of Byte;
    F_MultiLevelAbilityData_0E: Word;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
  end;

  { TMultiLevelAbility (instance size 48, VMT 5571DFD0) }
  TMultiLevelAbility = class(TAdjustableAbility)
  public
    F_MultiLevelAbility_28: Integer;
    F_MultiLevelAbility_2C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure GetInherentLevel(A1: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetLevelName(A1: Integer; A2: Integer); virtual;  { +10C draft }
  end;

  { TTransportAbility (instance size 48, VMT 5571E160) }
  TTransportAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
  end;

  { TStrikeCA (instance size 28, VMT 5571E344) }
  TStrikeCA = class(TDamageCA)
  public
    F_StrikeCA_18: Byte;
    F_StrikeCA_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure Generate(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
  end;

  { TMeleeRound (instance size 52, VMT 5571E460) }
  TMeleeRound = class(TObject)
  public
    F_MeleeRound_04: array[0..3] of Byte;
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
    F_MeleeRound_30: Word;
    F_MeleeRound_32: Word;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure SetCapacity(A1: Integer);  { draft }
    procedure SetCount(A1: Integer);  { draft }
    procedure GetMeleeStrike(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
    procedure CalculateUnitStrikes(A1: Byte);  { draft }
    procedure CalculateFreeUnitSwing(A1: Integer; A2: Integer);  { draft }
    procedure CalculateUnit(A1: Integer; A2: Integer);  { draft }
    procedure CalculateStrikes(A1: Byte);  { draft }
    procedure Calculate(A1: Integer; A2: Integer);  { draft }
    procedure CalculateSingleSide(A1: Integer; A2: Integer);  { draft }
    procedure CreateStrikeCA(A1: Integer);  { draft }
    procedure CalculateDV(A1: Integer; A2: Integer);  { draft }
    procedure GetAttackerDV;  { draft }
    procedure GetDefenderDV;  { draft }
  end;

  { TStrikeEnhancementAbility (instance size 40, VMT 5571E4D0) }
  TStrikeEnhancementAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanExpand(A1: Integer); override;
  end;

  { TStrikeAbility (instance size 44, VMT 5571E668) }
  TStrikeAbility = class(TAdjustableAbility)
  public
    F_StrikeAbility_28: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatMode(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanExecuteMelee(A1: Integer; A2: Integer);  { draft }
    procedure GetDamageTypes(A1: Integer);  { draft }
  end;

  { TRangedAttackCA (instance size 28, VMT 5571E7EC) }
  TRangedAttackCA = class(TDamageCA)
  public
    F_RangedAttackCA_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure Play(A1: Integer); override;
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
    procedure GetCombatMode(A1: Integer); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcValidRoundDistance(A1: Integer; A2: Integer); override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
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
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TFlameThrowingAbility (instance size 48, VMT 5571EDA4) }
  TFlameThrowingAbility = class(TBreathAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TTouchAbility (instance size 40, VMT 5571EF48) }
  TTouchAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCombatMode(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TPossessAbility (instance size 40, VMT 5571F1B4) }
  TPossessAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
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
    procedure GetAbilityID; override;
  end;

  { TPossessedAbility (instance size 40, VMT 5571F424) }
  TPossessedAbility = class(TPossessAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure AbilityDataClass; override;
  end;

  { TWebCA (instance size 20, VMT 5571F5C4) }
  TWebCA = class(TSingleTargetCA)
  public
    F_WebCA_10: Byte;
    F_WebCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TWebAbility (instance size 40, VMT 5571F690) }
  TWebAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TEntangleAbility (instance size 40, VMT 5571F8F8) }
  TEntangleAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TInvokeDeathAbility (instance size 40, VMT 5571FB74) }
  TInvokeDeathAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure GetTouchAttack(A1: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TTurnUndeadCA (instance size 24, VMT 5571FD18) }
  TTurnUndeadCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure GetSuccessfull;  { draft }
  end;

  { TTurnUndeadAbility (instance size 40, VMT 5571FDFC) }
  TTurnUndeadAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
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
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
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
    procedure GetAbilityID; override;
  end;

  { TCommandedAbility (instance size 40, VMT 55720218) }
  TCommandedAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
  end;

  { TCommandCA (instance size 24, VMT 557203A0) }
  TCommandCA = class(TSingleTargetCA)
  public
    F_CommandCA_10: Integer;
    F_CommandCA_14: Byte;
    F_CommandCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
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
    procedure GetAbilityID; override;
    procedure CommandingTargetPriority(A1: Integer; A2: Integer);  { draft }
    procedure CommandingTargetStrength(A1: Integer; A2: Integer);  { draft }
  end;

  { TCommandAbility (instance size 44, VMT 55720544) }
  TCommandAbility = class(TTouchAbility)
  public
    F_CommandAbility_28: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAbilityType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure CombatObjectDestroyed(A1: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
  end;

  { TSelfDestructAbility (instance size 40, VMT 5572116C) }
  TSelfDestructAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure CreateSelfDestructCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TWallCrushingAbility (instance size 40, VMT 55721314) }
  TWallCrushingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetWallCombatFeatures(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
  end;

  { THealingCA (instance size 16, VMT 557214BC) }
  THealingCA = class(TSingleTargetCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
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
    procedure GetAbilityID; override;
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
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetEnabled(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
    procedure ShowObject(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer); override;
    procedure Generate(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TDispelMagicAbilityCA (instance size 20, VMT 55721A34) }
  TDispelMagicAbilityCA = class(TDispelMagicCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: Integer; A2: Integer); override;
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
    procedure GetAbilityID; override;
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
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetLevel(A1: Integer); override;
    procedure GetEnabled(A1: Integer); override;
    procedure GetSkillPoints(A1: Integer); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure ExpandCost; override;
    procedure ExpandName(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure GetDamageValue(A1: Integer; A2: Integer); override;
    procedure GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure GetCombatInfo(A1: Integer; A2: Integer); override;
    procedure AbilityDataClass; override;
    procedure CanTouch(A1: Integer; A2: Integer); override;
    procedure CanTouchUnit(A1: Integer; A2: Integer); override;
    procedure SetEnabled(A1: Integer; A2: Integer);  { draft }
    procedure GetDispelMana(A1: Integer);  { draft }
    procedure GetLevelName(A1: Integer; A2: Integer);  { draft }
    procedure CreateCA(A1: Integer; A2: Integer);  { draft }
  end;

  { TLeadershipAbilityData (instance size 24, VMT 55721F1C) }
  TLeadershipAbilityData = class(TMultiLevelAbilityData)
  public
    F_LeadershipAbilityData_10: Byte;
    F_LeadershipAbilityData_11: array[0..2] of Byte;
    F_LeadershipAbilityData_14: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TLeadershipAbility (instance size 48, VMT 55722008) }
  TLeadershipAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetLevel(A1: Integer); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure GetInherent(A1: Integer); override;
    procedure CanExpand(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
    procedure SetExternalSource(A1: Integer; A2: Integer);  { draft }
    procedure ResetExternalSource(A1: Integer);  { draft }
  end;

  { TUnitEnchantment (instance size 32, VMT 55722198) }
  TUnitEnchantment = class(TEnchantment)
  public
    F_UnitEnchantment_18: Integer;
    F_UnitEnchantment_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetName(A1: Integer); override;
    procedure GetBinding(A1: Integer); override;
    procedure GetAIUpkeepPriority; override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
    procedure Dispel; override;
    procedure Select; override;
  end;

  { TUnitEnchantmentAbilityData (instance size 20, VMT 55722284) }
  TUnitEnchantmentAbilityData = class(TAbilityData)
  public
    F_UnitEnchantmentAbilityData_0C: Word;
    F_UnitEnchantmentAbilityData_0E: Byte;
    F_UnitEnchantmentAbilityData_0F: Byte;
    F_UnitEnchantmentAbilityData_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetAbilityID; override;
    procedure SetEnchantment(A1: Integer);  { draft }
  end;

  { TUnitEnchantmentAbility (instance size 40, VMT 55722364) }
  TUnitEnchantmentAbility = class(TAdjustableAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetName(A1: Integer; A2: Integer); override;
    procedure GetSourceName(A1: Integer; A2: Integer); override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure NewCombatTurn(A1: Integer; A2: Integer); override;
    procedure CombatDone(A1: Integer); override;
    procedure AbilityDataClass; override;
    procedure GetDurationMode; virtual;  { +10C draft }
    procedure GetDuration(A1: Integer); virtual;  { +110 draft }
    procedure GetAIUpkeepPriority(A1: Integer); virtual;  { +114 draft }
    procedure GetTotalDuration; virtual;  { +118 draft }
    procedure CreateEnchantment; virtual;  { +11C draft }
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
    procedure GetControlType; override;
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
    procedure GetName(A1: Integer); override;
  end;

  { TCosmeticSurgeryAbility (instance size 40, VMT 55722988) }
  TCosmeticSurgeryAbility = class(TUnitEnchantmentAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateEnchantment; override;
  end;

  { TSpellCastingAbility (instance size 48, VMT 55722B30) }
  TSpellCastingAbility = class(TMultiLevelAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetControlType; override;
    procedure fcPrefetchCombatCommands(A1: Integer); override;
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); override;
    procedure CanActivate(A1: Integer; A2: Integer); override;
    procedure Expand(A1: Integer; A2: Integer); override;
    procedure Remove(A1: Integer; A2: Integer); override;
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetLevelName(A1: Integer; A2: Integer); override;
    procedure CanCastBreachWallSpell(A1: Integer);  { draft }
    procedure AICanCastCombatSpell(A1: Integer);  { draft }
  end;

  { TSpellCC (instance size 32, VMT 55722D0C) }
  TSpellCC = class(TFastCombatCommand)
  public
    F_SpellCC_1C: Integer;
    procedure GetName(A1: Integer); override;
  end;

  { TSpell (instance size 52, VMT 55722D7C) }
  TSpell = class(TEObject)
  public
    F_Spell_08: Integer;
    F_Spell_0C: Byte;
    F_Spell_0D: array[0..2] of Byte;
    F_Spell_10: Integer;
    F_Spell_14: Integer;
    F_Spell_18: Integer;
    F_Spell_1C: Integer;
    F_Spell_20: Byte;
    F_Spell_21: Byte;
    F_Spell_22: Byte;
    F_Spell_23: array[0..0] of Byte;
    F_Spell_24: Integer;
    F_Spell_28: Integer;
    F_Spell_2C: Integer;
    F_Spell_30: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +04C draft }
    procedure ExecuteTE(A1: Integer; A2: Integer; A3: Integer); virtual;  { +050 draft }
    procedure CreateCastSpellAction; virtual;  { +054 draft }
    procedure SetupCastSpellAction(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); virtual;  { +05C draft }
    procedure AIExecuteCastSpellAction(A1: Integer); virtual;  { +060 draft }
    procedure GetEnabled; virtual;  { +064 draft }
    procedure CanActivate(A1: Integer; A2: Integer); virtual;  { +068 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +06C draft }
    procedure CanActivateCombat(A1: Integer; A2: Integer); virtual;  { +070 draft }
    procedure ActivateCombat(A1: Integer); virtual;  { +074 draft }
    procedure CreateCA(A1: Integer; A2: Integer; A3: Integer); virtual;  { +078 draft }
    procedure GetCombatInfo(A1: Integer; A2: Integer); virtual;  { +07C draft }
    procedure GetCombatDamageValue(A1: Integer; A2: Integer); virtual;  { +080 draft }
    procedure GetCombatDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +084 draft }
    procedure tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +088 draft }
    procedure tcGetDamageValue; virtual;  { +08C draft }
    procedure fcPrefetchCombatCommands(A1: Integer); virtual;  { +090 draft }
    procedure fcExecuteCombatCommand(A1: Integer; A2: Integer); virtual;  { +094 draft }
    procedure fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +098 draft }
    procedure CastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CombatCastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CombatSpellCast(A1: Integer);  { draft }
    procedure AIRequestCastSpellExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure AICastSpellExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TSpellControl (instance size 12, VMT 55722E94) }
  TSpellControl = class(TEObject)
  public
    F_SpellControl_08: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure GetSpell(A1: Integer);  { draft }
    procedure RegisterSpell(A1: Integer);  { draft }
    procedure UnregisterSpell(A1: Integer);  { draft }
    procedure UnregisterSpellID(A1: Integer);  { draft }
    procedure UnregisterAll;  { draft }
    procedure ListSpells(A1: Integer; A2: Word);  { draft }
    procedure GetRandomSpell(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TSpellList (instance size 8, VMT 55722F54) }
  TSpellList = class(TObject)
  public
    F_SpellList_04: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure GetSpell(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure Add;  { draft }
    procedure Delete;  { draft }
    procedure Clear;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnLevel;  { draft }
  end;

  { TSpellTE (instance size 32, VMT 55722FC4) }
  TSpellTE = class(TTokenEvent)
  public
    F_SpellTE_10: Integer;
    F_SpellTE_14: Integer;
    F_SpellTE_18: Byte;
    F_SpellTE_19: array[0..2] of Byte;
    F_SpellTE_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
    procedure Validate(A1: Integer); virtual;  { +050 draft }
    procedure Process(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure PlayDefaultCastEffects(A1: Integer; A2: Integer); virtual;  { +058 draft }
    procedure Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure GetSource;  { draft }
  end;

  { TSpellCaster (instance size 20, VMT 5572308C) }
  TSpellCaster = class(TEObject)
  public
    F_SpellCaster_08: Integer;
    F_SpellCaster_0C: Integer;
    F_SpellCaster_10: Integer;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure CanCast(A1: Integer); virtual;  { +04C draft }
    procedure Cast; virtual;  { +050 draft }
    procedure GetSource;  { draft }
  end;

  { TCombatSpellCaster (instance size 20, VMT 55723154) }
  TCombatSpellCaster = class(TEObject)
  public
    F_CombatSpellCaster_08: array[0..7] of Byte;
    F_CombatSpellCaster_10: Integer;
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
    procedure GetText(A1: Integer); override;
    procedure Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
  end;

  { TUnitSpellCaster (instance size 28, VMT 55723318) }
  TUnitSpellCaster = class(TSpellCaster)
  public
    F_UnitSpellCaster_14: Integer;
    F_UnitSpellCaster_18: Byte;
    F_UnitSpellCaster_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CanCast(A1: Integer); override;
    procedure Cast; override;
    procedure SetSelection(A1: Byte; A2: Integer);  { draft }
    procedure GetSelectionCount;  { draft }
    procedure GetRequiredMana;  { draft }
    procedure GetRequiredDays;  { draft }
    procedure Valid;  { draft }
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
    procedure Validate(A1: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
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
    procedure Execute(A1: Integer; A2: Integer); override;
    procedure Play(A1: Integer); override;
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
    procedure AIPrefetchCastSpellActions(A1: Integer; A2: Integer); override;
    procedure AIExecuteCastSpellAction(A1: Integer); override;
    procedure Activate(A1: Integer; A2: Integer); override;
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
    procedure Process(A1: Integer; A2: Integer); override;
  end;

  { TAICastSpellAction (instance size 28, VMT 557237A8) }
  TAICastSpellAction = class(TEObject)
  public
    F_AICastSpellAction_08: array[0..19] of Byte;
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
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure Process(A1: Integer; A2: Integer); override;
    procedure PrefetchCastSpellActions(A1: Integer);  { draft }
    procedure CastingHeroesMax;  { draft }
    procedure ProcessStates;  { draft }
  end;

