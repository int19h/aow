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
    F_CombatPredictorUnit_50: Byte;
    F_CombatPredictorUnit_51: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure Setup(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetEnabled(A1: Byte);  { draft }
    procedure UpdateTargets;  { draft }
    procedure UpdateWallTargets(A1: Integer; A2: Integer);  { draft }
    procedure InvalidateTargets;  { draft }
    procedure ResetCombat;  { draft }
    procedure ResetRoundTargets;  { draft }
    procedure SetupRoundTargets(A1: Byte);  { draft }
    procedure UpdateRoundTargetPriority;  { draft }
    procedure SortRoundTargets;  { draft }
    procedure ExecuteRound;  { draft }
    procedure FinishCombat;  { draft }
  end;

  { TCombatPredictorUnitList (instance size 16, VMT 55715700) }
  TCombatPredictorUnitList = class(TList)
  public
    procedure GetUnits(A1: Integer);  { draft }
    procedure IndexOfUnit(A1: Integer);  { draft }
    procedure IndexOfCPUID(A1: Integer);  { draft }
  end;

  { TCombatPredictorSide (instance size 60, VMT 55715794) }
  TCombatPredictorSide = class(TCombatPredictorUnitList)
  public
    F_CombatPredictorSide_10: array[0..3] of Byte;
    F_CombatPredictorSide_14: Byte;
    F_CombatPredictorSide_15: array[0..38] of Byte;
    procedure Reset;  { draft }
    procedure GetStrength(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
  end;

  { TCombatPredictor (instance size 52, VMT 55715820) }
  TCombatPredictor = class(TObject)
  public
    F_CombatPredictor_04: Integer;
    F_CombatPredictor_08: Integer;
    F_CombatPredictor_0C: Integer;
    F_CombatPredictor_10: Integer;
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
    procedure CreateUniqueCPUID;  { draft }
    procedure EnableAllUnits;  { draft }
    procedure Validate;  { draft }
    procedure ResetCombat;  { draft }
    procedure SetupCombat(A1: Integer);  { draft }
    procedure ExecuteCombatRound;  { draft }
    procedure CanPassWall;  { draft }
    procedure FinishCombat;  { draft }
    procedure Execute;  { draft }
    procedure DeleteUnit(A1: Integer; A2: Integer);  { draft }
    procedure AddUnitEx(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure AddUnit;  { draft }
    procedure AddUnits(A1: Integer);  { draft }
    procedure AddOpponent(A1: Integer; A2: Integer);  { draft }
    procedure AddOpponents(A1: Integer; A2: Integer);  { draft }
    procedure AddWall(A1: Integer);  { draft }
    procedure DeleteWall;  { draft }
    procedure DeleteUnits;  { draft }
    procedure DeleteOpponents;  { draft }
    procedure InitAdjacentArmies(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure InitAdjacentOpponents(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure GetSuperiority(A1: Integer; A2: Integer);  { draft }
    procedure GetEfficiency;  { draft }
    procedure ListRequiredUnitsEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ListRequiredUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListOptionalUnits(A1: Integer; A2: Integer);  { draft }
    procedure ListUselessUnits(A1: Integer);  { draft }
    procedure Usefullness(A1: Integer; A2: Integer);  { draft }
  end;

  { TCombatObject (instance size 76, VMT 557158EC) }
  TCombatObject = class(TEObject)
  public
    F_CombatObject_08: Integer;
    F_CombatObject_0C: Byte;
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
    F_CombatObject_46: Byte;
    F_CombatObject_47: Byte;
    F_CombatObject_48: Byte;
    F_CombatObject_49: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); virtual;  { +04C draft }
    procedure GetTargetWallCV(A1: Integer); virtual;  { +050 draft }
    procedure TargetsChanged; virtual;  { +054 draft }
    procedure GetTargetPriority; virtual;  { +058 draft }
    procedure GetTargetStrength; virtual;  { +05C draft }
    procedure GetEnabled; virtual;  { +060 draft }
    procedure GetLocked; virtual;  { +064 draft }
    procedure SetCombatPlayer(A1: Integer; A2: Integer); virtual;  { +068 draft }
    procedure GetAttack; virtual;  { +06C draft }
    procedure GetDefense; virtual;  { +070 draft }
    procedure GetResistance; virtual;  { +074 draft }
    procedure GetDamage; virtual;  { +078 draft }
    procedure GetImmunityTypes; virtual;  { +07C draft }
    procedure GetProtectionTypes; virtual;  { +080 draft }
    procedure GetHits; virtual;  { +084 draft }
    procedure GetHitPoints; virtual;  { +088 draft }
    procedure SetHitPoints(A1: Byte); virtual;  { +08C draft }
    procedure GetAlignment; virtual;  { +090 draft }
    procedure GetMoves; virtual;  { +094 draft }
    procedure GetExperience; virtual;  { +098 draft }
    procedure SetExperience; virtual;  { +09C draft }
    procedure GetLevel; virtual;  { +0A0 draft }
    procedure GetVisibilityRange; virtual;  { +0A4 draft }
    procedure GetAbilityEnabled; virtual;  { +0A8 draft }
    procedure SetAbilityEnabled; virtual;  { +0AC draft }
    procedure GetAbilityLevel; virtual;  { +0B0 draft }
    procedure GetAbilityCount; virtual;  { +0B4 draft }
    procedure GetAbilityOwner; virtual;  { +0B8 draft }
    procedure Activate(A1: Integer); virtual;  { +0BC draft }
    procedure Deactivate; virtual;  { +0C0 draft }
    procedure ObjectDestroyed(A1: Integer); virtual;  { +0C4 draft }
    procedure ObjectSideChanged(A1: Integer); virtual;  { +0C8 draft }
    procedure Initialize(A1: Integer); virtual;  { +0CC draft }
    procedure Finalize(A1: Integer); virtual;  { +0D0 draft }
    procedure fcRoundDistance; virtual;  { +0D4 draft }
    procedure fcExecute(A1: Integer); virtual;  { +0D8 draft }
    procedure fcBehindWall; virtual;  { +0DC draft }
    procedure fcWallInBetween(A1: Integer); virtual;  { +0E0 draft }
    procedure SupportCombatMode(A1: Byte; A2: Integer); virtual;  { +0E4 draft }
    procedure WallCombatFeatures; virtual;  { +0E8 draft }
    procedure PlaySFX(A1: Byte); virtual;  { +0EC draft }
    procedure NewTurn(A1: Integer); virtual;  { +0F0 draft }
    procedure NewRound; virtual;  { +0F4 draft }
    procedure CombatDone; virtual;  { +0F8 draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +0FC draft }
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +100 draft }
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); virtual;  { +104 draft }
    procedure DoDamage(A1: Integer; A2: Integer); virtual;  { +108 draft }
    procedure GetOptimalDamageType(A1: Word; A2: Integer); virtual;  { +10C draft }
    procedure ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer); virtual;  { +110 draft }
    procedure ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +114 draft }
    procedure ExecuteDamageEffectsRole(A1: Word; A2: Integer); virtual;  { +118 draft }
    procedure Surrender; virtual;  { +11C draft }
    procedure DestroyObject; virtual;  { +120 draft }
    function ExecuteDamage(A1: Integer): Integer; virtual;  { +124 draft }
    procedure ExecuteDamageEffects(A1: Word; A2: Integer); virtual;  { +128 draft }
    procedure TurnDone; virtual;  { +12C draft }
    procedure IDStr(A1: Integer); virtual;  { +130 draft }
    procedure AddTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure DeleteTarget(A1: Integer);  { draft }
    procedure RemoveTarget(A1: Integer);  { draft }
    procedure ResetTargets;  { draft }
    procedure SetupTargets;  { draft }
    procedure GetSide;  { draft }
    procedure GetOpponentSide;  { draft }
    procedure GetPlayer;  { draft }
    procedure GetPlayerIR;  { draft }
  end;

  { TCombatUnit (instance size 92, VMT 55715A94) }
  TCombatUnit = class(TCombatObject)
  public
    F_CombatUnit_4C: Integer;
    F_CombatUnit_50: array[0..3] of Byte;
    F_CombatUnit_54: Byte;
    F_CombatUnit_55: Byte;
    F_CombatUnit_56: array[0..1] of Byte;
    F_CombatUnit_58: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetCVDV(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetTargetWallCV(A1: Integer); override;
    procedure GetTargetPriority; override;
    procedure GetTargetStrength; override;
    procedure GetEnabled; override;
    procedure GetLocked; override;
    procedure GetAttack; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetDamage; override;
    procedure GetImmunityTypes; override;
    procedure GetProtectionTypes; override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Byte); override;
    procedure GetAlignment; override;
    procedure GetMoves; override;
    procedure GetExperience; override;
    procedure SetExperience; override;
    procedure GetLevel; override;
    procedure GetVisibilityRange; override;
    procedure GetAbilityEnabled; override;
    procedure SetAbilityEnabled; override;
    procedure GetAbilityLevel; override;
    procedure GetAbilityCount; override;
    procedure GetAbilityOwner; override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure ObjectDestroyed(A1: Integer); override;
    procedure Initialize(A1: Integer); override;
    procedure Finalize(A1: Integer); override;
    procedure SupportCombatMode(A1: Byte; A2: Integer); override;
    procedure WallCombatFeatures; override;
    procedure PlaySFX(A1: Byte); override;
    procedure NewTurn(A1: Integer); override;
    procedure NewRound; override;
    procedure CombatDone; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ExecuteDamageEffectsRole(A1: Word; A2: Integer); override;
    procedure Surrender; override;
    procedure DestroyObject; override;
    procedure ExecuteDamageEffects(A1: Word; A2: Integer); override;
    procedure IDStr(A1: Integer); override;
    procedure SetUnit(A1: Integer); virtual;  { +134 draft }
    procedure KillUnit; virtual;  { +138 draft }
    procedure Setup(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure UpdateWallCombatFeatures;  { draft }
    procedure SetParty(A1: Integer);  { draft }
    procedure UpdateParty;  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure ReleaseUnitGFXResource;  { draft }
    procedure SetStatus(A1: Byte; A2: Integer);  { draft }
    procedure CommandingTargetPriority(A1: Integer; A2: Integer);  { draft }
    procedure CommandingTargetStrength(A1: Integer; A2: Integer);  { draft }
  end;

  { TCombatWall (instance size 80, VMT 55715C40) }
  TCombatWall = class(TCombatObject)
  public
    F_CombatWall_4C: Byte;
    F_CombatWall_4D: Byte;
    F_CombatWall_4E: Byte;
    F_CombatWall_4F: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure GetTargetPriority; override;
    procedure GetTargetStrength; override;
    procedure GetLocked; override;
    procedure GetDefense; override;
    procedure GetResistance; override;
    procedure GetImmunityTypes; override;
    procedure GetHits; override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Byte); override;
    procedure Activate(A1: Integer); override;
    procedure Deactivate; override;
    procedure fcRoundDistance; override;
    procedure Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowAttackAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure ShowHitAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer); override;
    procedure DestroyObject; override;
    procedure IDStr(A1: Integer); override;
    procedure Setup(A1: Byte; A2: Byte; A3: Integer);  { draft }
  end;

  { TCombatSide (instance size 28, VMT 55715DE4) }
  TCombatSide = class(TENode)
  public
    F_CombatSide_0C: Byte;
    F_CombatSide_0D: array[0..6] of Byte;
    F_CombatSide_14: Integer;
    F_CombatSide_18: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetObjects(A1: Integer);  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure GetDestroyedObjects;  { draft }
    procedure GetUndestroyedConquerObjects;  { draft }
    procedure OutputDebugInfo;  { draft }
    procedure UpdateSettings;  { draft }
  end;

