{ Interface declaration run owned by P3. }
  { TCombatPredictorUnit (instance size 84, VMT 5571567C) }
  TCombatPredictorUnit = class(TObject)
  public
    F_CombatPredictorUnit_04: Integer;
    F_CombatPredictorUnit_08: Integer;
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
    procedure Setup(A1: Integer; A2: Integer; A3: Byte);  { draft }
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
    procedure Execute;  { draft }
    procedure DeleteUnit(A1: Integer);  { draft }
    function AddUnitEx(A1: Integer; A2: Byte; A3: Byte): TCombatPredictorUnit;  { draft }
    procedure AddUnit(A1: Integer);  { draft }
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddOpponent(A1: Integer; A2: Integer);  { draft }
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
    function Usefullness(A1: Integer): Integer;  { draft }
  end;

  { TCombatObject (instance size $4C, VMT 557158EC).
    $0C FID; $46 FPosition; $47 FStatus; $48 FControlMode.
    Other fields retain their offset names pending recovery. }
  TCombatObject = class(TEObject)
  public
    FCombat: TCombat;  { $08 }
    FID: Byte;
    F_CombatObject_0D: array[0..2] of Byte;
    F_CombatObject_10: Integer;
    F_CombatObject_14: Integer;
    F_CombatObject_18: Integer;
    F_CombatObject_1C: Integer;
    F_CombatObject_20: Integer;
    F_CombatObject_24: array[0..3] of Byte;
    F_CombatObject_28: Integer;
    F_CombatObject_2C: Integer;
    F_CombatObject_30: Integer;
    F_CombatObject_34: array[0..3] of Byte;
    F_CombatObject_38: Integer;
    F_CombatObject_3C: Byte;
    F_CombatObject_3D: array[0..2] of Byte;
    F_CombatObject_40: Integer;
    F_CombatObject_44: Byte;
    F_CombatObject_45: Byte;
    FPosition: Byte;
    FStatus: TCombatObjectStatus;
    FControlMode: TCombatObjectControlMode;
    F_CombatObject_49: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); virtual;  { +04C draft }
    procedure GetTargetWallCV(A1: Integer); virtual;  { +050 draft }
    procedure TargetsChanged; virtual;  { +054 draft }
    procedure GetTargetPriority; virtual;  { +058 draft }
    function GetTargetStrength: Integer; virtual;  { +05C draft }
    function GetEnabled: Boolean; virtual;  { +060 draft }
    function GetLocked: Boolean; virtual;  { +064 draft }
    procedure SetCombatPlayer(A1: Integer; A2: Integer); virtual;  { +068 draft }
    function GetAttack: Shortint; virtual;  { +06C draft }
    function GetDefense: Shortint; virtual;  { +070 draft }
    function GetResistance: Shortint; virtual;  { +074 draft }
    function GetDamage: Shortint; virtual;  { +078 draft }
    function GetImmunityTypes: TDamageTypes; virtual;  { +07C draft }
    function GetProtectionTypes: TDamageTypes; virtual;  { +080 draft }
    function GetHits: Byte; virtual;  { +084 draft }
    function GetHitPoints: Byte; virtual;  { +088 draft }
    procedure SetHitPoints(A1: Byte); virtual;  { +08C draft }
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
    procedure Finalize(A1: Integer); virtual;  { +0D0 draft }
    procedure fcRoundDistance; virtual;  { +0D4 draft }
    procedure fcExecute(A1: Integer); virtual;  { +0D8 draft }
    function fcBehindWall: Boolean; virtual;
    function fcWallInBetween(A1: Byte): Boolean; virtual;
    procedure SupportCombatMode(A1: Byte; A2: Integer); virtual;  { +0E4 draft }
    function WallCombatFeatures: TWallCombatFeatures; virtual;  { +0E8 draft }
    procedure PlaySFX(A1: Byte); virtual;  { +0EC draft }
    procedure NewTurn(A1: Byte); virtual;  { +0F0 draft }
    procedure NewRound; virtual;  { +0F4 draft }
    procedure CombatDone; virtual;  { +0F8 draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +0FC draft }
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +100 draft }
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +104 draft }
    function DoDamage(A1: TCombatObject; A2: Integer): Integer; virtual;
    procedure GetOptimalDamageType(A1: Word; A2: Integer); virtual;  { +10C draft }
    function ExecuteDamageRole(A1: Integer; A2: Integer; A3: TDamageTypes): Integer; virtual;  { +110 draft }
    function ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: TDamageTypes; A4: Byte): Integer; virtual;  { +114 draft }
    function ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes; virtual;  { +118 draft }
    procedure Surrender; virtual;  { +11C draft }
    procedure DestroyObject; virtual;  { +120 draft }
    function ExecuteDamage(A1: Integer): Integer; virtual;  { +124 draft }
    function ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes; virtual;  { +128 draft }
    procedure TurnDone; virtual;  { +12C draft }
    function IDStr: string; virtual;  { +130 draft }
    procedure AddTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DeleteTarget(A1: Integer);  { draft }
    procedure RemoveTarget(A1: Integer);  { draft }
    procedure ResetTargets;  { draft }
    procedure SetupTargets;  { draft }
    function GetSide: TCombatSideIndex;  { draft }
    function GetOpponentSide: TCombatSideIndex;  { draft }
    procedure GetPlayer;  { draft }
    procedure GetPlayerIR;  { draft }
  end;

  { TCombatUnit (instance size $5C, VMT 55715A94).
    $4C FUnit; $50 party; $54 FDisabled; $55 FWallCombatFeatures;
    $58 FUnitGFXResourceIndex. Inherited: $0C FID; $46 FPosition;
    $47 FStatus; $48 FControlMode. }
  TCombatUnit = class(TCombatObject)
  public
    FUnit: TAbstractUnit;
    F_CombatUnit_50: array[0..3] of Byte;
    FDisabled: Boolean;
    FWallCombatFeatures: TWallCombatFeatures;
    F_CombatUnit_56: array[0..1] of Byte;
    FUnitGFXResourceIndex: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetTargetWallCV(A1: Integer); override;
    procedure GetTargetPriority; override;
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
    function GetHitPoints: Byte; override;
    procedure SetHitPoints(A1: Byte); override;
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
    procedure Finalize(A1: Integer); override;
    procedure SupportCombatMode(A1: Byte; A2: Integer); override;
    function WallCombatFeatures: TWallCombatFeatures; override;
    procedure PlaySFX(A1: Byte); override;
    procedure NewTurn(A1: Byte); override;
    procedure NewRound; override;
    procedure CombatDone; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    function ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes; override;
    procedure Surrender; override;
    procedure DestroyObject; override;
    function ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes; override;
    function IDStr: string; override;
    procedure SetUnit(A1: Integer); virtual;  { +134 draft }
    procedure KillUnit; virtual;  { +138 draft }
    procedure Setup(A1: Byte; A2: Integer; A3: Integer; A4: Byte; A5: Byte);  { draft }
    procedure UpdateWallCombatFeatures;  { draft }
    procedure SetParty(A1: Integer);  { draft }
    procedure UpdateParty;  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure ReleaseUnitGFXResource;  { draft }
    procedure SetStatus(A1: Byte; A2: Integer);  { draft }
    procedure CommandingTargetPriority(A1: Integer; A2: Integer);  { draft }
    procedure CommandingTargetStrength(A1: Integer; A2: Integer);  { draft }
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
    procedure GetTargetPriority; override;
    function GetTargetStrength: Integer; override;
    function GetLocked: Boolean; override;
    function GetDefense: Shortint; override;
    function GetResistance: Shortint; override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetHits: Byte; override;
    function GetHitPoints: Byte; override;
    procedure SetHitPoints(A1: Byte); override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure fcRoundDistance; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure DestroyObject; override;
    function IDStr: string; override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer);  { draft }
    class function LinkP3Helpers(Index: Integer): Pointer;
  end;

  { TCombatSide (instance size $1C, VMT 55715DE4):
    $0C side index; $10 FOpponent; $14 strength; $18 conquer-object count. }
  TCombatSide = class(TENode)
  public
    F_CombatSide_0C: Byte;
    F_CombatSide_0D: array[0..2] of Byte;
    FOpponent: TCombatSide;
    F_CombatSide_14: Integer;
    F_CombatSide_18: Integer;
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

