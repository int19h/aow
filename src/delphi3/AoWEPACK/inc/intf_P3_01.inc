{ Interface declaration run owned by P3. }
  { TCombatPredictorUnit: instance size $54, VMT 5571567C;
    $08 FCPUID, the unique key used by the target caches. }
  TCombatPredictorUnit = class(TObject)
  public
    F_CombatPredictorUnit_04: Integer;
    FCPUID: Integer;  { $08 }
    F_CombatPredictorUnit_0C: Integer;
    F_CombatPredictorUnit_10: Integer;
    F_CombatPredictorUnit_14: Byte;
    F_CombatPredictorUnit_15: array[0..2] of Byte;
    F_CombatPredictorUnit_18: Integer;
    F_CombatPredictorUnit_1C: Byte;
    F_CombatPredictorUnit_1D: Byte;
    F_CombatPredictorUnit_1E: array[0..1] of Byte;
    F_CombatPredictorUnit_20: Integer;
    F_CombatPredictorUnit_24: Integer;
    F_CombatPredictorUnit_28: Integer;
    F_CombatPredictorUnit_2C: Integer;
    F_CombatPredictorUnit_30: Byte;
    F_CombatPredictorUnit_31: Byte;
    F_CombatPredictorUnit_32: array[0..1] of Byte;
    F_CombatPredictorUnit_34: Integer;
    F_CombatPredictorUnit_38: Integer;
    F_CombatPredictorUnit_3C: Integer;
    F_CombatPredictorUnit_40: Integer;
    F_CombatPredictorUnit_44: Integer;
    F_CombatPredictorUnit_48: Integer;
    F_CombatPredictorUnit_4C: Integer;
    F_CombatPredictorUnit_50: TCombatPredictorUnitStatus;
    F_CombatPredictorUnit_51: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Setup(A1: TAbstractUnit; A2: Integer; A3: Byte);
    procedure SetEnabled(A1: Byte);  { draft }
    procedure UpdateTargets;  { draft }
    procedure UpdateWallTargets;  { draft }
    procedure InvalidateTargets;  { draft }
    procedure ResetCombat;  { draft }
    procedure ResetRoundTargets;  { draft }
    procedure SetupRoundTargets(A1: Byte);  { draft }
    procedure UpdateRoundTargetPriority;  { draft }
    procedure SortRoundTargets;  { draft }
    function ExecuteRound: Boolean;  { draft }
    procedure FinishCombat;  { draft }
  end;

  { TCombatPredictorUnitList (instance size 16, VMT 55715700) }
  TCombatPredictorUnitList = class(TList)
  public
    function GetUnits(A1: Integer): TCombatPredictorUnit;  { draft }
    function IndexOfUnit(A1: Integer): Integer;  { draft }
    function IndexOfCPUID(A1: Integer): Integer;  { draft }
  end;

  { TCombatPredictorSide (instance size $3C, VMT 55715794):
    $10 dirty flag; $14 FStrength (ten Integers indexed by TDamageType). }
  TCombatPredictorSide = class(TCombatPredictorUnitList)
  public
    F_CombatPredictorSide_10: array[0..3] of Byte;
    FStrength: array[TDamageType] of Integer;
    procedure Reset;  { draft }
    function GetStrength(A1: TDamageType): Integer;  { draft }
    function GetStrengthMax(A1: TDamageTypes): Integer;  { draft }
  end;

  { TCombatPredictor (instance size $34, VMT 55715820):
    $04 all units; $08 active units; $0C/$10 FSides; $14 result;
    $18/$1C metrics; $20 wall; $24 rounds; $28 unique ID; $2C dirty; $30 work. }
  TCombatPredictor = class(TObject)
  public
    F_CombatPredictor_04: Integer;
    F_CombatPredictor_08: Integer;
    FSides: array[0..1] of Integer;
    F_CombatPredictor_14: Byte;
    F_CombatPredictor_15: array[0..2] of Byte;
    F_CombatPredictor_18: Integer;
    F_CombatPredictor_1C: Integer;
    F_CombatPredictor_20: Integer;
    F_CombatPredictor_24: Integer;
    F_CombatPredictor_28: Integer;
    F_CombatPredictor_2C: Byte;
    F_CombatPredictor_2D: array[0..2] of Byte;
    F_CombatPredictor_30: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Reset;  { draft }
    function CreateUniqueCPUID: Integer;  { draft }
    procedure EnableAllUnits;  { draft }
    procedure Validate;  { draft }
    procedure ResetCombat;  { draft }
    procedure SetupCombat(A1: Byte);  { draft }
    function ExecuteCombatRound: Boolean;  { draft }
    function CanPassWall: Boolean;  { draft }
    procedure FinishCombat;  { draft }
    function Execute: TCombatResult;
    procedure DeleteUnit(A1: Integer);  { draft }
    function AddUnitEx(A1: TAbstractUnit; A2: Byte; A3: Byte): TCombatPredictorUnit;
    procedure AddUnit(A1: TAbstractUnit);
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddOpponent(A1: TAbstractUnit; A2: Byte);
    procedure AddOpponents(A1: Integer; A2: Byte);  { draft }
    procedure AddWall(A1: Integer);  { draft }
    procedure DeleteWall;  { draft }
    procedure DeleteUnits;  { draft }
    procedure DeleteOpponents;  { draft }
    procedure InitAdjacentArmies(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure InitAdjacentOpponents(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    function GetSuperiority: Integer;  { draft }
    function GetEfficiency: Integer;  { draft }
    procedure ListRequiredUnitsEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ListRequiredUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListOptionalUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListUselessUnits(A1: Integer);  { draft }
    function Usefullness(A1: TAbstractUnit): Integer;
  end;

  { TCombatObject: instance size $4C, VMT 557158EC.
    $08 FCombat; $0C FID; $10 FTargets; $14 FTargetedBy;
    $18/$1C outgoing CV/wall CV; $20/$24 incoming CV/wall CV;
    $28/$2C target counts; $30/$34 attacker counts;
    $38/$3C target priority/cache flag; $40/$44 strength/cache flag;
    $45 FCombatPlayer; $46 FPosition; $47 FStatus; $48 FControlMode. }
  TCombatObject = class(TEObject)
  public
    FCombat: TCombat;  { $08 }
    FID: Byte;
    F_CombatObject_0D: array[0..2] of Byte;
    FTargets: TQuadItemList;  { $10 }
    FTargetedBy: TQuadItemList;  { $14 }
    FCombatValue: Integer;
    FWallCombatValue: Integer;
    FIncomingCombatValue: Integer;
    FIncomingWallCombatValue: Integer;
    FTargetCount: Integer;
    FWallTargetCount: Integer;
    FAttackerCount: Integer;
    FWallAttackerCount: Integer;  { $34 }
    FTargetPriority: Integer;
    FTargetPriorityInvalid: Boolean;  { $3C }
    F_CombatObject_3D: array[0..2] of Byte;
    FTargetStrength: Integer;
    FTargetStrengthInvalid: Boolean;  { $44 }
    FCombatPlayer: Byte;  { $45 }
    FPosition: Byte;
    FStatus: TCombatObjectStatus;
    FControlMode: TCombatObjectControlMode;
    F_CombatObject_49: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer); virtual;  { +04C }
    function GetTargetWallCV(Target: TCombatObject): Integer; virtual;  { +050 }
    procedure TargetsChanged; virtual;  { +054 draft }
    function GetTargetPriority: Integer; virtual;  { +058 }
    function GetTargetStrength: Integer; virtual;  { +05C draft }
    function GetEnabled: Boolean; virtual;  { +060 draft }
    function GetLocked: Boolean; virtual;  { +064 draft }
    procedure SetCombatPlayer(Player: Byte); virtual;  { +068 }
    function GetAttack: Shortint; virtual;  { +06C draft }
    function GetDefense: Shortint; virtual;  { +070 draft }
    function GetResistance: Shortint; virtual;  { +074 draft }
    function GetDamage: Shortint; virtual;  { +078 draft }
    function GetImmunityTypes: TDamageTypes; virtual;  { +07C draft }
    function GetProtectionTypes: TDamageTypes; virtual;  { +080 draft }
    function GetHits: Byte; virtual;  { +084 draft }
    { conflict: function GetHits: Shortint; virtual; }
    function GetHitPoints: Shortint; virtual;  { +088 }
    procedure SetHitPoints(A1: Byte); virtual;  { +08C draft }
    { conflict: procedure SetHitPoints(A1: Shortint); virtual; }
    function GetAlignment: TAlignment; virtual;  { +090 draft }
    function GetMoves: Integer; virtual;  { +094 draft }
    function GetExperience: Integer; virtual;  { +098 draft }
    procedure SetExperience(A1: Integer); virtual;  { +09C draft }
    function GetLevel: Byte; virtual;  { +0A0 draft }
    function GetVisibilityRange: Integer; virtual;  { +0A4 draft }
    function GetAbilityEnabled(A1: Integer): Boolean; virtual;  { +0A8 draft }
    procedure SetAbilityEnabled(A1: Integer; A2: Boolean); virtual;  { +0AC draft }
    function GetAbilityLevel(A1: Integer): Integer; virtual;  { +0B0 draft }
    function GetAbilityCount: Integer; virtual;  { +0B4 draft }
    function GetAbilityOwner: TAbilityOwner; virtual;  { +0B8 draft }
    procedure Activate(A1: Integer); virtual;  { +0BC draft }
    procedure Deactivate; virtual;  { +0C0 draft }
    procedure ObjectDestroyed(A1: Integer); virtual;  { +0C4 draft }
    procedure ObjectSideChanged(A1: Integer); virtual;  { +0C8 draft }
    procedure Initialize(A1: Integer); virtual;  { +0CC draft }
    procedure Finalize(A1: TCombatResult); virtual;  { +0D0 draft }
    function fcRoundDistance: Integer; virtual;  { +0D4 }
    function fcExecute(A1: Integer): Boolean; virtual;  { +0D8 }
    function fcBehindWall: Boolean; virtual;
    function fcWallInBetween(A1: Byte): Boolean; virtual;
    { conflict: function fcWallInBetween(A1: Integer): Boolean; virtual; }
    function SupportCombatMode(Modes: TCombatModes): Boolean; virtual;  { +0E4 }
    function WallCombatFeatures: TWallCombatFeatures; virtual;  { +0E8 draft }
    procedure PlaySFX(A1: Byte); virtual;  { +0EC draft }
    procedure NewTurn(A1: Byte); virtual;  { +0F0 draft }
    procedure NewRound; virtual;  { +0F4 draft }
    procedure CombatDone; virtual;  { +0F8 draft }
    procedure Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc); virtual;  { +0FC draft }
    function ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; virtual;  { +100 draft }
    function ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; virtual;  { +104 draft }
    function DoDamage(A1: TCombatObject; A2: Integer): Integer; virtual;
    function GetOptimalDamageType(Types: TDamageTypes): TDamageType; virtual;  { +10C }
    function ExecuteDamageRole(A1: Integer; A2: Integer; A3: TDamageTypes): Integer; virtual;  { +110 draft }
    function ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: TDamageTypes; A4: Byte): Integer; virtual;  { +114 draft }
    function ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes; virtual;  { +118 draft }
    procedure Surrender; virtual;  { +11C draft }
    procedure DestroyObject; virtual;  { +120 draft }
    function ExecuteDamage(A1: Integer): Integer; virtual;  { +124 draft }
    function ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes; virtual;  { +128 draft }
    procedure TurnDone; virtual;  { +12C draft }
    function IDStr: string; virtual;  { +130 draft }
    procedure AddTarget(Target: TCombatObject; CV, WallCV, DV: Integer);
    procedure DeleteTarget(Index: Integer);
    procedure RemoveTarget(Target: TCombatObject);
    procedure ResetTargets;  { draft }
    procedure SetupTargets;  { draft }
    function GetSide: TCombatSideIndex;  { draft }
    function GetOpponentSide: TCombatSideIndex;  { draft }
    function GetPlayer: Shortint;
    function GetPlayerIR: Shortint;
  end;

  { TCombatUnit (instance size $5C, VMT 55715A94).
    $4C FUnit; $50 FParty; $54 FDisabled; $55 FWallCombatFeatures;
    $58 FUnitGFXResourceIndex. Inherited: $0C FID; $46 FPosition;
    $47 FStatus; $48 FControlMode. }
  TCombatUnit = class(TCombatObject)
  public
    FUnit: TAbstractUnit;
    FParty: TCombatParty;  { $50 }
    FDisabled: Boolean;
    FWallCombatFeatures: TWallCombatFeatures;
    F_CombatUnit_56: array[0..1] of Byte;
    FUnitGFXResourceIndex: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer); override;
    function GetTargetWallCV(Target: TCombatObject): Integer; override;
    function GetTargetPriority: Integer; override;
    function GetTargetStrength: Integer; override;
    function GetEnabled: Boolean; override;
    function GetLocked: Boolean; override;
    function GetAttack: Shortint; override;
    function GetDefense: Shortint; override;
    function GetResistance: Shortint; override;
    function GetDamage: Shortint; override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetProtectionTypes: TDamageTypes; override;
    function GetHits: Byte; override;
    { conflict: function GetHits: Shortint; override; }
    function GetHitPoints: Shortint; override;
    procedure SetHitPoints(A1: Byte); override;
    { conflict: procedure SetHitPoints(A1: Shortint); override; }
    function GetAlignment: TAlignment; override;
    function GetMoves: Integer; override;
    function GetExperience: Integer; override;
    procedure SetExperience(A1: Integer); override;
    function GetLevel: Byte; override;
    function GetVisibilityRange: Integer; override;
    function GetAbilityEnabled(A1: Integer): Boolean; override;
    procedure SetAbilityEnabled(A1: Integer; A2: Boolean); override;
    function GetAbilityLevel(A1: Integer): Integer; override;
    function GetAbilityCount: Integer; override;
    function GetAbilityOwner: TAbilityOwner; override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure ObjectDestroyed(A1: Integer); override;
    procedure Initialize(A1: Integer); override;
    procedure Finalize(A1: TCombatResult); override;
    function SupportCombatMode(Modes: TCombatModes): Boolean; override;
    function WallCombatFeatures: TWallCombatFeatures; override;
    procedure PlaySFX(A1: Byte); override;
    procedure NewTurn(A1: Byte); override;
    procedure NewRound; override;
    procedure CombatDone; override;
    procedure Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc); override;
    function ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    function ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    function ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes; override;
    procedure Surrender; override;
    procedure DestroyObject; override;
    function ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes; override;
    function IDStr: string; override;
    procedure SetUnit(AUnit: TAbstractUnit); virtual;  { +134 }
    procedure KillUnit; virtual;  { +138 draft }
    procedure Setup(A1: Byte; A2: Integer; A3: TAbstractUnit; A4: Byte; A5: Byte);
    procedure UpdateWallCombatFeatures;  { draft }
    procedure SetParty(Party: TCombatParty);
    procedure UpdateParty;  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure ReleaseUnitGFXResource;  { draft }
    procedure SetStatus(Status: TCombatObjectStatus);
    function CommandingTargetPriority: Integer;
    function CommandingTargetStrength: Integer;
  end;

  { TCombatWall (instance size $50, VMT 55715C40): $4C FWallType;
    $4D FHitPoints; $4E FLocked. }
  TCombatWall = class(TCombatObject)
  public
    FWallType: Byte;
    FHitPoints: Byte;
    FLocked: Boolean;
    F_CombatWall_4F: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetTargetPriority: Integer; override;
    function GetTargetStrength: Integer; override;
    function GetLocked: Boolean; override;
    function GetDefense: Shortint; override;
    function GetResistance: Shortint; override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetHits: Byte; override;
    { conflict: function GetHits: Shortint; override; }
    function GetHitPoints: Shortint; override;
    procedure SetHitPoints(A1: Byte); override;
    { conflict: procedure SetHitPoints(A1: Shortint); override; }
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    function fcRoundDistance: Integer; override;
    procedure Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc); override;
    function ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    function ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer; override;
    procedure DestroyObject; override;
    function IDStr: string; override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer);  { draft }
    class function LinkP3Helpers(Index: Integer): Pointer;
  end;

  { TCombatSide (instance size $1C, VMT 55715DE4):
    $0C FSideIndex; $10 FOpponent; $14 FStrength; $18 FConquerCount. }
  TCombatSide = class(TENode)
  public
    FSideIndex: Byte;
    F_CombatSide_0D: array[0..2] of Byte;
    FOpponent: TCombatSide;
    FStrength: Integer;
    FConquerCount: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetObjects(A1: Integer): TCombatObject;  { draft }
    function IndexOfID(A1: Integer): Integer;  { draft }
    function GetDestroyedObjects: Integer;  { draft }
    function GetUndestroyedConquerObjects: Integer;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure UpdateSettings;  { draft }
  end;

