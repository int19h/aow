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
    FSource: Integer; { $10 }
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
    function GetSkillPoints(A1: TAbilityOwner): Integer; override;
    procedure GetInherentLevel(A1: Integer); override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    function ExpandCost(A1: TAbilityOwner): Integer; override;
    function ExpandName(A1: TAbilityOwner): string; override;
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

  TMeleeStrikeArray = array[0..$7FFFFFF div SizeOf(TMeleeStrike)] of TMeleeStrike;
  PMeleeStrikeArray = ^TMeleeStrikeArray;

  { TMeleeRound (instance size 52, VMT 5571E460):
    $04 count, $08 capacity, $0C strikes, $10/$14 combat objects,
    $18/$1C cached damage values, $20/$24 units, $28/$2C strike counts,
    $30/$32 attacker/defender damage types. }
  TMeleeRound = class(TObject)
  public
    FCount: Integer; { $04 }
    FCapacity: Integer; { $08 }
    FStrikes: PMeleeStrikeArray; { $0C }
    FAttacker, FDefender: TCombatObject; { $10/$14 }
    FAttackerDV, FDefenderDV: Integer; { $18/$1C }
    FAttackerUnit, FDefenderUnit: TAbstractUnit; { $20/$24 }
    FAttackerStrikes, FDefenderStrikes: Integer; { $28/$2C }
    FAttackerDamageTypes, FDefenderDamageTypes: TDamageTypes; { $30/$32 }
    destructor Destroy; override;
    constructor Create;
    procedure SetCapacity(A1: Integer);
    procedure SetCount(A1: Integer);
    procedure GetMeleeStrike(A1: Integer; var A2: TMeleeStrike);
    procedure Reset;
    procedure CalculateUnitStrikes(A1: TCombatSideIndex);
    procedure CalculateFreeUnitSwing(A1, A2: TAbstractUnit);
    procedure CalculateUnit(A1, A2: TAbstractUnit);
    procedure CalculateStrikes(A1: TCombatSideIndex);
    procedure Calculate(A1, A2: TCombatObject);
    procedure CalculateSingleSide(A1, A2: TCombatObject);
    function CreateStrikeCA(A1: Integer): TStrikeCA;
    procedure CalculateDV;
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
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function CanExecuteMelee(A1, A2: TCombatObject): Boolean;
    function GetDamageTypes(A1: TAbilityOwner): TDamageTypes;
  end;

  { TRangedAttackCA (instance size 28, VMT 5571E7EC; $18 ability ID) }
  TRangedAttackCA = class(TDamageCA)
  public
    FAbilityID: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetName: string; override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
  end;

  { TRangedAttackAbility (instance size 48, VMT 5571E8D4;
    $28 range, $29 damage, $2A attack, $2B packed damage types, $2D repeats) }
  TRangedAttackAbility = class(TAdjustableAbility)
  public
    FRangeRA: TCombatRange; { $28 }
    FDamageRA: Shortint; { $29 }
    FAttackRA: Shortint; { $2A }
    FDamageTypesRA: TP3PackedDamageTypes; { $2B }
    FAttackRepeatRA: Shortint; { $2D }
    F_RangedAttackAbility_2E: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCombatMode(A1: TAbilityOwner): TCombatMode; override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function GetControlType: TAbilityControlType; override;
    function fcValidRoundDistance(A1, A2: TCombatObject): Boolean; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function GetRangeRA(A1: TAbilityOwner): TCombatRange; virtual; { +10C }
    function GetDamageRA(A1: TAbilityOwner): Shortint; virtual; { +110 }
    function GetAttackRA(A1: TAbilityOwner): Shortint; virtual; { +114 }
    function GetAttackRepeatRA(A1: TAbilityOwner): Shortint; virtual; { +118 }
    function GetDamageTypesRA(A1: TAbilityOwner): TDamageTypes; virtual; { +11C }
    function CreateRangedAttackCA(A1, A2: TCombatObject; A3: Integer): TRangedAttackCA;
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
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
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
    function GetTouchAttack(A1: Integer): Shortint; virtual; { +10C }
    function CombatTouchRole(A1: TCombatUnit; A2: TCombatObject): Boolean; virtual; { +110 }
    function CombatTouchRoleProbability(A1: TCombatUnit; A2: TCombatObject): Single; virtual; { +114 }
    function TouchRoleProbability(A1, A2: TAbstractUnit): Single; virtual; { +118 }
    function CanTouch(A1, A2: TCombatObject): Boolean; virtual; { +11C }
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; virtual; { +120 }
    procedure fcValidateMoveOutsideWall(A1, A2: TCombatObject);
  end;

  { TPossessCA (instance size 20, VMT 5571F0E0; $10 possession succeeded) }
  TPossessCA = class(TSingleTargetCA)
  public
    FSuccessful: Boolean; { $10 }
    F_PossessCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(A1, A2: Byte; A3: Boolean);
  end;

  { TPossessAbility (instance size 40, VMT 5571F1B4) }
  TPossessAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    function CreatePossessCA(A1, A2: TCombatObject): TPossessCA;
  end;

  { TPossessedAbilityData (instance size 16, VMT 5571F350; $0C source experience) }
  TPossessedAbilityData = class(TAbilityData)
  public
    FSourceExperience: Integer; { $0C }
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

  { TWebCA (instance size 20, VMT 5571F5C4; $10 successful) }
  TWebCA = class(TSingleTargetCA)
  public
    FSuccessful: Boolean; { $10 }
    F_WebCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Boolean);
  end;

  { TWebAbility (instance size 40, VMT 5571F690) }
  TWebAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CreateWebCA(A1, A2: TCombatObject): TWebCA;
  end;

  { TEntangleCA (instance size 20, VMT 5571F824; $10 successful) }
  TEntangleCA = class(TSingleTargetCA)
  public
    FSuccessful: Boolean; { $10 }
    F_EntangleCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Boolean);
  end;

  { TEntangleAbility (instance size 40, VMT 5571F8F8) }
  TEntangleAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CreateEntangleCA(A1, A2: TCombatObject): TEntangleCA;
  end;

  { TInvokeDeathCA (instance size 20, VMT 5571FA98; $10 successful) }
  TInvokeDeathCA = class(TSingleTargetCA)
  public
    FSuccessful: Boolean; { $10 }
    F_InvokeDeathCA_11: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(A1: Byte; A2: Byte; A3: Boolean);
  end;

  { TInvokeDeathAbility (instance size 40, VMT 5571FB74) }
  TInvokeDeathAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    function CreateCA(A1, A2: TCombatObject): TInvokeDeathCA;
  end;

  { TTurnUndeadCA (instance size 24, VMT 5571FD18) }
  TTurnUndeadCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    function GetSuccessfull: Boolean;
  end;

  { TTurnUndeadAbility (instance size 40, VMT 5571FDFC) }
  TTurnUndeadAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    function GetSkillPoints(A1: TAbilityOwner): Integer; override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    function ExpandCost(A1: TAbilityOwner): Integer; override;
    function ExpandName(A1: TAbilityOwner): string; override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    function GetLevelName(A1: Integer): string;
    function GetTurnUndeadDamage(A1: Integer): Shortint;
    function CreateTurnUndeadCA(A1, A2: TCombatObject): TTurnUndeadCA;
  end;

  { TRoundAttackAbility (instance size 40, VMT 5571FFA0) }
  TRoundAttackAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
  end;

  { TCommandedAbilityData (instance size 28, VMT 55720144;
    $0C ability ID, $10 commander ID, $14 command ability ID, $18 original combat player) }
  TCommandedAbilityData = class(TAbilityData)
  public
    FAbilityID: Integer; { $0C }
    FSourceID: Byte; { $10 }
    F_CommandedAbilityData_11: array[0..2] of Byte;
    FCommandAbilityID: Integer; { $14 }
    FOriginalCombatPlayer: Byte; { $18 }
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

  { TCommandCA (instance size 24, VMT 557203A0; $10 ability ID, $14 success) }
  TCommandCA = class(TSingleTargetCA)
  public
    FAbilityID: Integer; { $10 }
    FSuccessful: Boolean; { $14 }
    F_CommandCA_15: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(SourceID, TargetID: Byte; Successful: Boolean);
  end;

  { TCommandAbilityData (instance size 20, VMT 55720474;
    $0C ability ID, $10 commanded combat-unit IDs) }
  TCommandAbilityData = class(TAbilityData)
  public
    FAbilityID: Integer; { $0C }
    FCommandedUnits: TByteList; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
    function CommandingTargetPriority(Combat: TCombat): Integer;
    function CommandingTargetStrength(Combat: TCombat): Integer;
  end;

  { TCommandAbility (instance size 44, VMT 55720544; $28 commanded ability ID) }
  TCommandAbility = class(TTouchAbility)
  public
    FCommandedAbilityID: Integer; { $28 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAbilityType: TAbilityType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure CombatObjectDestroyed(A1: TCombatObject); override;
    procedure CombatDone(A1: TCombatObject); override;
    function AbilityDataClass: TEObjectClass; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    procedure Command(Source, Target: TCombatUnit); virtual; { +124 }
    function CreateCommandCA(Source, Target: TCombatUnit): TCommandCA; virtual; { +128 }
    procedure ResetCommandedUnits(A1: TCombatUnit); virtual; { +12C }
    procedure Uncommand(A1: TCombatUnit); virtual; { +130 }
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
    function GetTouchAttack(A1: Integer): Shortint; override;
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
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
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
    function GetTouchAttack(A1: Integer): Shortint; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
  end;

  { TSelfDestructCA (instance size 24, VMT 55721084) }
  TSelfDestructCA = class(TDamageCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
  end;

  { TSelfDestructAbility (instance size 40, VMT 5572116C) }
  TSelfDestructAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    function CreateSelfDestructCA(A1, A2: TCombatObject): TSelfDestructCA;
  end;

  { TWallCrushingAbility (instance size 40, VMT 55721314) }
  TWallCrushingAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures; override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
  end;

  { THealingCA (instance size 16, VMT 557214BC) }
  THealingCA = class(TSingleTargetCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Initialize(A1: Byte; A2: Byte);
  end;

  { THealingAbilityData (instance size 16, VMT 55721590; $0C enabled) }
  THealingAbilityData = class(TAbilityData)
  public
    FEnabled: Boolean; { $0C }
    F_HealingAbilityData_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { THealingTE (instance size 32, VMT 55721660; $10/$18 unit IDs, $14/$1C players) }
  THealingTE = class(TTokenEvent)
  public
    FSourceID: Integer; { $10 }
    FSourcePlayer: Byte; { $14 }
    F_HealingTE_15: array[0..2] of Byte;
    FTargetID: Integer; { $18 }
    FTargetPlayer: Byte; { $1C }
    F_HealingTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { THealingUnitSelector (instance size 44, VMT 55721720) }
  THealingUnitSelector = class(TUnitSelector)
  public
    function CanSelectUnit(A1: TUnit): Boolean; override;
    function Select: Boolean; override;
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
    function Activate(A1: TAbilityOwner; var A2: string): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    procedure SetEnabled(A1: TAbilityOwner; A2: Boolean);
    function GetHealHitPoints(A1: TCombatObject): Integer;
    function CreateHealingCA(A1, A2: TCombatObject): THealingCA;
    function HealUnit(A1: TAbstractUnit): Boolean;
  end;

  { TDispelMagicCA (instance size 20, VMT 55721958; $10 dispelled enchantment IDs) }
  TDispelMagicCA = class(TSingleTargetCA)
  public
    FEnchantmentIDs: TIntegerList; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
    procedure ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc); override;
    procedure Generate(A1, A2: TCombatObject; A3: Integer);
  end;

  { TDispelMagicAbilityCA (instance size 20, VMT 55721A34) }
  TDispelMagicAbilityCA = class(TDispelMagicCA)
  public
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
  end;

  { TDispelMagicAbilityTE (instance size 32, VMT 55721B1C;
    $10/$14 source unit ID/player, $18/$1C target unit ID/player) }
  TDispelMagicAbilityTE = class(TTokenEvent)
  public
    FSourceID: Integer; { $10 }
    FSourcePlayer: Byte; { $14 }
    F_DispelMagicAbilityTE_15: array[0..2] of Byte;
    FTargetID: Integer; { $18 }
    FTargetPlayer: Byte; { $1C }
    F_DispelMagicAbilityTE_1D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TDispelMagicAbilityData (instance size 16, VMT 55721BF0; $0C enabled, $0D level) }
  TDispelMagicAbilityData = class(TAbilityData)
  public
    FEnabled: Boolean; { $0C }
    FLevel: Byte; { $0D }
    F_DispelMagicAbilityData_0E: array[0..1] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetAbilityID: Integer; override;
  end;

  { TDispelMagicAbilityUnitSelector (instance size 44, VMT 55721CC8) }
  TDispelMagicAbilityUnitSelector = class(TUnitSelector)
  public
    function CanSelectUnit(A1: TUnit): Boolean; override;
    function Select: Boolean; override;
  end;

  { TDispelMagicAbility (instance size 40, VMT 55721D78) }
  TDispelMagicAbility = class(TTouchAbility)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetName(A1: TAbilityOwner): string; override;
    function GetLevel(A1: TAbilityOwner): Integer; override;
    function GetEnabled(A1: TAbilityOwner): Boolean; override;
    function GetSkillPoints(A1: TAbilityOwner): Integer; override;
    function GetControlType: TAbilityControlType; override;
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); override;
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; override;
    procedure NewTurn(A1: TAbilityOwner; A2: Shortint); override;
    function Activate(A1: TAbilityOwner; var A2: string): Boolean; override;
    function CanExpand(A1: TAbilityOwner): Boolean; override;
    function ExpandCost(A1: TAbilityOwner): Integer; override;
    function ExpandName(A1: TAbilityOwner): string; override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    function GetDamageValue(A1, A2: TAbstractUnit): Integer; override;
    procedure GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo); override;
    function AbilityDataClass: TEObjectClass; override;
    function CanTouch(A1, A2: TCombatObject): Boolean; override;
    function CanTouchUnit(A1, A2: TAbstractUnit): Boolean; override;
    procedure SetEnabled(A1: TAbilityOwner; A2: Boolean);
    function GetDispelMana(A1: TAbilityOwner): Integer;
    function GetLevelName(A1: Integer): string;
    function CreateCA(A1, A2: TCombatObject): TDispelMagicAbilityCA;
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
    procedure GetInfo(AUnit: TAbstractUnit; var Text: string; var Gold, Days: Integer); virtual;  { +04C }
    function CanConstruct(A1: TAbstractUnit; var A2: string): Boolean; virtual;
    function Construct(AUnit: TAbstractUnit): Boolean; virtual;  { +054 }
    function ID: Integer; virtual;  { +058 }
  end;

  { TConstructionControlList (instance size 12, VMT 557225EC) }
  TConstructionControlList = class(TENode)
  public
    function GetConstructionControl(Index: Integer): TConstructionControl;
    function FindID(ID: Integer): TConstructionControl;
  end;

  { TConstructAbility (instance size 44, VMT 55722700; $28 construction controls) }
  TConstructAbility = class(TAdjustableAbility)
  public
    FConstructionControls: TConstructionControlList; { $28 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetControlType: TAbilityControlType; override;
    function CanActivate(A1: TAbilityOwner; var A2: string): Boolean; override;
    procedure RegisterConstructionControl(Control: TConstructionControl);
  end;

  { TCosmeticSurgeryEnchantment (instance size 36, VMT 55722888) }
  TCosmeticSurgeryEnchantment = class(TUnitEnchantment)
  public
    FFaceIndex: Integer; { $20 }
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
    function CanActivate(A1: TAbilityOwner; var A2: string): Boolean; override;
    function Expand(A1: TAbilityOwner): Boolean; override;
    function Remove(A1: TAbilityOwner): Boolean; override;
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); override;
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); override;
    function GetLevelName(A1: Integer): string; override;
    function CanCastBreachWallSpell(AUnit: TAbstractUnit): Boolean;
    function AICanCastCombatSpell(A1: TCombatUnit): Boolean;
  end;

  { TSpellCC (instance size 32, VMT 55722D0C) }
  TSpellCC = class(TFastCombatCommand)
  public
    FSpellID: Integer; { $1C }
    function GetName: string; override;
  end;

  TUnitSpellData = array[0..1] of Integer;
  TSpellCombatInfo = packed record
    Attack, Damage: Shortint;
    DamageTypes: TDamageTypes;
    RepeatCount, Range, Radius: Shortint;
    TargetTypes: TCombatTargetType;
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
    FResearchCost: Integer; { $18; 557D5EE7 }
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
    procedure PlayDefaultCastEffects(Player, X, Y, Layer: Shortint); virtual; { +04C }
    function ExecuteTE(A1: TSpellTE; A2: TAbstractUnit; A3: Integer): Boolean; virtual;  { +050 }
    function CreateCastSpellAction: TAICastSpellAction; virtual;  { +054 }
    procedure SetupCastSpellAction(A1: TAbstractUnit; A2: TAICastSpellAction); virtual;  { +058 }
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); virtual;  { +05C }
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; virtual;  { +060 }
    function GetEnabled: Boolean; virtual; { +064 }
    function CanActivate(A1: TAbstractUnit; var A2: string): Boolean; virtual;  { +068 }
    function Activate(A1: TAbstractUnit): Boolean; virtual;  { +06C }
    function CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean; virtual; { $070 }
    function ActivateCombat(A1: TAbstractUnit): Boolean; virtual; { $074 }
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; virtual;  { +078 }
    procedure GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo); virtual; { +07C }
    function GetCombatDamageValue(A1, A2: TCombatObject): Integer; virtual;  { +080 }
    procedure GetCombatDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); virtual;  { +084 }
    procedure tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues); virtual;  { +088 draft }
    procedure tcGetDamageValue; virtual;  { +08C draft }
    procedure fcPrefetchCombatCommands(A1: TFastCombatCommandList); virtual;  { +090 }
    function fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean; virtual;  { +094 }
    procedure fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues); virtual;  { +098 }
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
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; virtual;  { +054  }
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
    function CanCast(var Reason: string): Boolean; virtual; { +04C }
    function Cast: Boolean; virtual; { +050 }
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

  { TSpellCastEventLog (instance size 32, VMT 55723220; $18 unit ID, $1C spell ID) }
  TSpellCastEventLog = class(TEventLog)
  public
    FUnitID: Integer; { $18 }
    FSpellID: Integer; { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
  end;

  { TUnitSpellCaster (instance size 28, VMT 55723318; $14 target-unit users, $18 selection bits) }
  TUnitSpellCaster = class(TSpellCaster)
  public
    FTargetUnits: TUnitUserList; { $14 }
    FSelectionMask: Byte;
    F_UnitSpellCaster_19: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CanCast(var Reason: string): Boolean; override;
    function Cast: Boolean; override;
    procedure SetSelection(Selection: Byte);
    function GetSelectionCount: Integer;
    function GetRequiredMana: Integer;
    function GetRequiredDays: Integer;
    function Valid: Boolean;
  end;

  { TUnitSpellTE (instance size 52, VMT 557233E8;
    $20 target IDs, $24 target users, $28 target player, $2C spell data) }
  TUnitSpellTE = class(TSpellTE)
  public
    FTargetUnitIDs: TIntegerList; { $20 }
    FTargetUnits: TUnitUserList; { $24 }
    FTargetPlayer: Byte; { $28 }
    F_UnitSpellTE_29: array[0..2] of Byte;
    FSpellData: TUnitSpellData; { $2C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Validate(A1: THero): Boolean; override;
    function Process(A1: TAbstractUnit; A2: Integer): Boolean; override;
    procedure Initialize(SpellID: Integer; Source: TAbstractUnit; Targets: TUnitList; Mana: Integer);
  end;

  { TUnitSpellCA (instance size 32, VMT 557234B8;
    $0C spell ID, $10/$11 source/target IDs, $14 spell data, $1C mana) }
  TUnitSpellCA = class(TCombatAction)
  public
    FSpellID: Integer; { $0C }
    FSourceID: Byte; { $10 }
    FTargetID: Byte; { $11 }
    F_UnitSpellCA_12: array[0..1] of Byte;
    FSpellData: TUnitSpellData; { $14 }
    FMana: Integer; { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Execute(A1: TCombat); override;
    function Play(A1: TCombatViewer): Boolean; override;
  end;

  { TUnitSpell (instance size 68, VMT 55723590) }
  TUnitSpell = class(TSpell)
  public
    FAllowMultipleTargets: Boolean; { $34 }
    F_UnitSpell_35: array[0..2] of Byte;
    FTargetRange: Integer; { $38 }
    FUnitDispelResistance: Byte; { $3C }
    F_UnitSpell_3D: array[0..2] of Byte;
    FAIValue: Integer; { $40 }
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AIPrefetchCastSpellActions(A1: TAbstractUnit; A2: TAICastSpellActionList); override;
    function AIExecuteCastSpellAction(A1: TAbstractUnit): Boolean; override;
    function Activate(A1: TAbstractUnit): Boolean; override;
    function CanActivateCombat(A1: TAbstractUnit; var A2: string): Boolean; override;
    function CreateCA(A1, A2: TCombatObject; A3: Boolean): TCombatAction; override;
    procedure GetCombatInfo(Source: TAbstractUnit; var Info: TSpellCombatInfo); override;
    function ValidTargetUnit(Source, Target: TAbstractUnit): Boolean; virtual;  { +09C }
    procedure ValidateUnitSelection(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A0 draft }
    procedure SetupUSC(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A4 draft }
    function CastSpell(Source: TAbstractUnit; Targets: TUnitList): Boolean; virtual; { +0A8 }
    function ValidTargetParty(Source: TAbstractUnit; Party: TArmyHS): Boolean; virtual; { +0AC }
    procedure TargetPartySelected(A1: Integer; A2: Integer); virtual;  { +0B0 draft }
    function ExecuteSpell(Source, Target: TAbstractUnit; Mana: Integer; var Data: TUnitSpellData): Boolean; virtual;  { +0B4 }
    procedure CreateCAEx(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0B8 draft }
    procedure ExecuteCA(Combat: TCombat; Action: TUnitSpellCA); virtual; { +0BC }
    procedure AIRetrieveOptimalTargetUnit(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +0C0 draft }
    procedure OnValidateTarget(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure OnTargetSelectionChange(A1: Integer; A2: Integer);  { draft }
    procedure ResetTargetSelection;  { draft }
    procedure SetupTargetSelection(A1: Integer; A2: Integer);  { draft }
  end;

  { TResearchSpellAIPA (instance size 20, VMT 557236C4) }
  TResearchSpellAIPA = class(TAIPlayerAction)
  public
    class function Priority: Integer; override;
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
    class function Priority: Integer; override;
    function Activate: Boolean; override;
    function Process: Boolean; override;
    procedure PrefetchCastSpellActions(A1: Integer);  { draft }
    procedure CastingHeroesMax;  { draft }
    procedure ProcessStates;  { draft }
  end;

