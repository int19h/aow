{ Interface declaration run owned by P2. }
  { TUnitControl (instance size 20, VMT 557105E8) }
  TUnitControl = class(TEObject)
  public
    F_UnitControl_08: Integer;
    F_UnitControl_0C: Integer;
    F_UnitControl_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetCount;  { draft }
    procedure TriggerUnitsChanged;  { draft }
    procedure GetUnit(A1: Integer);  { draft }
    procedure FindUnit(A1: Integer);  { draft }
    procedure GetFreeID;  { draft }
    procedure RegisterUnit(A1: Integer);  { draft }
    procedure UnRegisterUnit(A1: Integer);  { draft }
  end;

  { TAbstractUnit (instance size 60, VMT 55710740) }
  TAbstractUnit = class(TAbilityOwner)
  public
    F_AbstractUnit_14: Integer;
    F_AbstractUnit_18: Integer;
    F_AbstractUnit_1C: Integer;
    F_AbstractUnit_20: Integer;
    F_AbstractUnit_24: Byte;
    F_AbstractUnit_25: Byte;
    F_AbstractUnit_26: Byte;
    F_AbstractUnit_27: array[0..0] of Byte;
    F_AbstractUnit_28: Byte;
    F_AbstractUnit_29: array[0..8] of Byte;
    F_AbstractUnit_32: Byte;
    F_AbstractUnit_33: array[0..0] of Byte;
    F_AbstractUnit_34: Integer;
    F_AbstractUnit_38: Byte;
    F_AbstractUnit_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetOwnerName(A1: Integer); override;
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
    procedure Changed; override;
    procedure RemoveAbility(A1: Integer); override;
    procedure GetUpkeep; virtual;  { +09C draft }
    procedure GetUnitLevel; virtual;  { +0A0 draft }
    procedure GetRace; virtual;  { +0A4 draft }
    procedure GetInherentAttack; virtual;  { +0A8 draft }
    procedure GetInherentDefense; virtual;  { +0AC draft }
    procedure GetInherentDamage; virtual;  { +0B0 draft }
    procedure GetInherentResistance; virtual;  { +0B4 draft }
    procedure GetInherentAbility(A1: Integer); virtual;  { +0B8 draft }
    procedure GetInherentAbilityLevel(A1: Integer); virtual;  { +0BC draft }
    procedure GetAttack(A1: Integer; A2: Integer); virtual;  { +0C0 draft }
    procedure GetDefense(A1: Integer; A2: Integer); virtual;  { +0C4 draft }
    procedure GetDamage(A1: Integer; A2: Integer); virtual;  { +0C8 draft }
    procedure GetResistance(A1: Integer; A2: Integer); virtual;  { +0CC draft }
    procedure GetHits; virtual;  { +0D0 draft }
    procedure GetMoves; virtual;  { +0D4 draft }
    procedure GetMovePoints; virtual;  { +0D8 draft }
    procedure SetMovePoints(A1: Integer); virtual;  { +0DC draft }
    procedure GetHitPoints; virtual;  { +0E0 draft }
    procedure SetHitPoints(A1: Integer); virtual;  { +0E4 draft }
    procedure GetMoveTypes; virtual;  { +0E8 draft }
    procedure GetImmunityTypes; virtual;  { +0EC draft }
    procedure GetProtectionTypes; virtual;  { +0F0 draft }
    procedure GetFace; virtual;  { +0F4 draft }
    procedure GetName(A1: Integer); virtual;  { +0F8 draft }
    procedure GetAlignment; virtual;  { +0FC draft }
    procedure GetPreviewImage; virtual;  { +100 draft }
    procedure GetTransportCapacity; virtual;  { +104 draft }
    procedure GetTransporter; virtual;  { +108 draft }
    procedure GetGender; virtual;  { +10C draft }
    procedure GetBloodType; virtual;  { +110 draft }
    procedure GetUnitType; virtual;  { +114 draft }
    procedure GetUnitGFXResourceIndex; virtual;  { +118 draft }
    procedure CanAddToList; virtual;  { +11C draft }
    procedure GetWallCombatFeatures; virtual;  { +120 draft }
    procedure GetCampaignTransferPoints; virtual;  { +124 draft }
    procedure GetCastingPointsMax; virtual;  { +128 draft }
    procedure GetCastingPoints; virtual;  { +12C draft }
    procedure SetCastingPoints(A1: Integer); virtual;  { +130 draft }
    procedure GetPowerGeneration; virtual;  { +134 draft }
    procedure NewDay(A1: Integer; A2: Integer); virtual;  { +138 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +13C draft }
    procedure NewTurnDone(A1: Byte); virtual;  { +140 draft }
    procedure GetAbilityLevel(A1: Integer); virtual;  { +144 draft }
    procedure GetAbilityEnabled(A1: Integer); virtual;  { +148 draft }
    procedure GetAbilitySet(A1: Integer); virtual;  { +14C draft }
    procedure GetAbilityName(A1: Integer; A2: Integer); virtual;  { +150 draft }
    procedure GetAbilityOwner(A1: Integer); virtual;  { +154 draft }
    procedure GetAbilityCount; virtual;  { +158 draft }
    procedure GetExperience; virtual;  { +15C draft }
    procedure SetExperience(A1: Integer; A2: Integer); virtual;  { +160 draft }
    procedure GetNextLevelExperience; virtual;  { +164 draft }
    procedure GetDescription; virtual;  { +168 draft }
    procedure SetPlayer(A1: Integer); virtual;  { +16C draft }
    procedure GetIndependentRelation; virtual;  { +170 draft }
    procedure GetObtainValue; virtual;  { +174 draft }
    procedure GetUnitSize; virtual;  { +178 draft }
    procedure GetUnitMoraleValue(A1: Integer; A2: Byte); virtual;  { +17C draft }
    procedure CanActivate; virtual;  { +180 draft }
    procedure Activate(A1: Integer; A2: Integer); virtual;  { +184 draft }
    procedure Deactivate; virtual;  { +188 draft }
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer); virtual;  { +18C draft }
    procedure CanDisband; virtual;  { +190 draft }
    procedure CanJoin(A1: Byte; A2: Integer); virtual;  { +194 draft }
    procedure JoinAmount(A1: Integer; A2: Integer); virtual;  { +198 draft }
    procedure OfferToJoin(A1: Integer); virtual;  { +19C draft }
    procedure GetJoinMessage(A1: Integer; A2: Integer); virtual;  { +1A0 draft }
    procedure ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +1A4 draft }
    procedure UnitKilled; virtual;  { +1A8 draft }
    procedure Killed; virtual;  { +1AC draft }
    procedure Resurrect; virtual;  { +1B0 draft }
    procedure Animate; virtual;  { +1B4 draft }
    procedure RetrieveDamageInfo(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure GetRelationValue(A1: Byte; A2: Integer);  { draft }
    procedure GetRelation(A1: Integer; A2: Integer);  { draft }
    procedure UnitRelation(A1: Integer; A2: Integer);  { draft }
    procedure UpdateMoraleValue;  { draft }
    procedure GetMorale;  { draft }
    procedure UpdateEnchanted;  { draft }
    procedure RemoveEnchantments;  { draft }
    procedure RemoveHandicaps;  { draft }
    procedure RegisterEnchantments;  { draft }
    procedure UnregisterEnchantments;  { draft }
    procedure AbilityToEnchantment;  { draft }
    procedure CanDispelEnchantment(A1: Integer);  { draft }
    procedure ListEnchantments(A1: Integer; A2: Integer);  { draft }
    procedure UpdateDefensiveStrength;  { draft }
    procedure UpdateOffensiveStrength;  { draft }
    procedure GetStrength(A1: Integer);  { draft }
    procedure GetStrengthMax(A1: Word; A2: Integer);  { draft }
    procedure GetCombatValue(A1: Integer; A2: Byte);  { draft }
    procedure ListAbilityInfo(A1: Integer; A2: Integer);  { draft }
    procedure GetManaUpkeep;  { draft }
    procedure GetTransporting(A1: Integer; A2: Integer);  { draft }
    procedure CreateMovePointTable(A1: Integer);  { draft }
    procedure ValidTerrain(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteTrailOfDarkness(A1: Integer);  { draft }
    procedure PathOfLifeTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfDecayTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfFrostTerrainChange(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PathOfFrostTerrainChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UpdatePathOfFrost(A1: Integer; A2: Integer);  { draft }
    procedure ConcealedOnMapF(A1: Integer);  { draft }
    procedure ExecuteStormDamage(A1: Byte);  { draft }
    procedure MovePointCost(A1: Integer; A2: Byte);  { draft }
    procedure ResetEarthMasteryStoneSkin;  { draft }
    procedure SetEarthMasteryStoneSkin;  { draft }
    procedure ResetFireMasteryProtection;  { draft }
    procedure SetFireMasteryProtection;  { draft }
    procedure ResetLifeMasteryBlessing;  { draft }
    procedure SetLifeMasteryBlessing;  { draft }
    procedure ResetLifeMasteryFear;  { draft }
    procedure ExecuteLifeMasteryFearRole;  { draft }
    procedure ValidateLifeMastery;  { draft }
    procedure ExecuteDeathMasteryCurseRole;  { draft }
    procedure ValidateDeathMastery;  { draft }
    procedure VisibilityRange(A1: Integer; A2: Integer);  { draft }
    procedure TrueVisionRange;  { draft }
    procedure CanPlace(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure Place(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ValidateCrusader;  { draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ShowFace(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ExecuteResistanceRole(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteDamageEffectsRole(A1: Word);  { draft }
    procedure ExecuteDamageEffects(A1: Word; A2: Integer);  { draft }
    procedure ExecuteCombatDamageEffects(A1: Integer; A2: Integer);  { draft }
    procedure OptimalDamageType(A1: Word; A2: Integer);  { draft }
    procedure Disband;  { draft }
  end;

  { TAbstractUnitResource (instance size 28, VMT 5571096C) }
  TAbstractUnitResource = class(TEResource)
  public
    F_AbstractUnitResource_18: Integer;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    procedure DropUnit(A1: Integer; A2: Integer; A3: Integer); virtual;  { +064 draft }
    procedure GetPreviewImage; virtual;  { +068 draft }
    procedure GetFace; virtual;  { +06C draft }
    procedure GetObtainValue; virtual;  { +070 draft }
    procedure SetUnitGFXResourceIndex(A1: Integer);  { draft }
    procedure EditDropMsg(A1: Integer);  { draft }
  end;

  { TUnitResource (instance size 84, VMT 55710A64) }
  TUnitResource = class(TAbstractUnitResource)
  public
    F_UnitResource_1C: Integer;
    F_UnitResource_20: Byte;
    F_UnitResource_21: Byte;
    F_UnitResource_22: array[0..1] of Byte;
    F_UnitResource_24: Integer;
    F_UnitResource_28: Byte;
    F_UnitResource_29: Byte;
    F_UnitResource_2A: Byte;
    F_UnitResource_2B: Byte;
    F_UnitResource_2C: Byte;
    F_UnitResource_2D: Byte;
    F_UnitResource_2E: Byte;
    F_UnitResource_2F: Byte;
    F_UnitResource_30: Byte;
    F_UnitResource_31: Byte;
    F_UnitResource_32: array[0..5] of Byte;
    F_UnitResource_38: Integer;
    F_UnitResource_3C: Integer;
    F_UnitResource_40: Integer;
    F_UnitResource_44: Byte;
    F_UnitResource_45: array[0..2] of Byte;
    F_UnitResource_48: Integer;
    F_UnitResource_4C: Integer;
    F_UnitResource_50: Byte;
    F_UnitResource_51: Byte;
    F_UnitResource_52: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ResourceUserClassID: Integer; override;
    function CreateResourceUser: Engine.TEObject; override;
    procedure DropUnit(A1: Integer; A2: Integer; A3: Integer); override;
    procedure GetObtainValue; override;
    procedure GetMoveTypes;  { draft }
    procedure GetTransportCapacity;  { draft }
    procedure GetUpkeep;  { draft }
    procedure SetDescription;  { draft }
    procedure UnitResourceIndex;  { draft }
    procedure GetUnitName(A1: Integer);  { draft }
  end;

  { TUnitResourceList (instance size 20, VMT 55710B64) }
  TUnitResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetUnitResource(A1: Integer);  { draft }
  end;

  { TUnit (instance size 72, VMT 55710CAC) }
  TUnit = class(TAbstractUnit)
  public
    F_Unit_3C: Byte;
    F_Unit_3D: Byte;
    F_Unit_3E: Byte;
    F_Unit_3F: array[0..0] of Byte;
    F_Unit_40: Integer;
    F_Unit_44: Byte;
    F_Unit_45: Byte;
    F_Unit_46: Byte;
    F_Unit_47: Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Changed; override;
    procedure GetUnitLevel; override;
    procedure GetRace; override;
    procedure GetInherentAttack; override;
    procedure GetInherentDefense; override;
    procedure GetInherentDamage; override;
    procedure GetInherentResistance; override;
    procedure GetAttack(A1: Integer; A2: Integer); override;
    procedure GetDefense(A1: Integer; A2: Integer); override;
    procedure GetDamage(A1: Integer; A2: Integer); override;
    procedure GetResistance(A1: Integer; A2: Integer); override;
    procedure GetHits; override;
    procedure GetMoves; override;
    procedure GetMovePoints; override;
    procedure SetMovePoints(A1: Integer); override;
    procedure GetHitPoints; override;
    procedure SetHitPoints(A1: Integer); override;
    procedure GetFace; override;
    procedure GetName(A1: Integer); override;
    procedure GetAlignment; override;
    procedure GetPreviewImage; override;
    procedure GetTransportCapacity; override;
    procedure GetTransporter; override;
    procedure GetGender; override;
    procedure GetBloodType; override;
    procedure GetUnitType; override;
    procedure GetUnitGFXResourceIndex; override;
    procedure NewDay(A1: Integer; A2: Integer); override;
    procedure GetExperience; override;
    procedure SetExperience(A1: Integer; A2: Integer); override;
    procedure GetNextLevelExperience; override;
    procedure GetDescription; override;
    procedure GetObtainValue; override;
    procedure GetUnitSize; override;
    procedure Activate(A1: Integer; A2: Integer); override;
    procedure ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure UnitKilled; override;
    procedure Killed; override;
    procedure GetRank;  { draft }
    procedure SetRank(A1: Integer);  { draft }
    procedure SetUnitResource(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitList (instance size 16, VMT 55710EC8) }
  TUnitList = class(TEChangeNotifyNode)
  public
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure GetPlayer; virtual;  { +08C draft }
    procedure GetStrength(A1: Integer); virtual;  { +090 draft }
    procedure GetStrengthMax(A1: Word; A2: Integer); virtual;  { +094 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +098 draft }
    procedure SortUnits; virtual;  { +09C draft }
    procedure SortOnMoves; virtual;  { +0A0 draft }
    procedure CanAddUnit(A1: Integer; A2: Integer); virtual;  { +0A4 draft }
    procedure CanDeleteUnit(A1: Integer); virtual;  { +0A8 draft }
    procedure AddUnit(A1: Integer); virtual;  { +0AC draft }
    procedure DeleteUnit(A1: Integer); virtual;  { +0B0 draft }
    procedure AddUnits(A1: Integer); virtual;  { +0B4 draft }
    procedure IndexOf;  { draft }
    procedure IndexOfID(A1: Integer);  { draft }
    procedure IndexOfBehavior(A1: Integer);  { draft }
    procedure IndexOfGroup(A1: Integer);  { draft }
    procedure IndexOfGroupID(A1: Integer);  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure GetUnit(A1: Integer);  { draft }
    procedure SetUnit(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitUserList (instance size 16, VMT 55710FEC) }
  TUnitUserList = class(TUnitList)
  public
    procedure Clear; override;
    procedure AddUnit(A1: Integer); override;
    procedure DeleteUnit(A1: Integer); override;
    procedure AddUnitsEx(A1: Integer; A2: Integer);  { draft }
  end;

  { TUnitIndexList (instance size 20, VMT 55711118) }
  TUnitIndexList = class(TIntegerList)
  public
    procedure Create(A1: Byte);  { draft }
    procedure GetUnitIndex(A1: Integer);  { draft }
    procedure VerifyUnits(A1: Byte);  { draft }
    procedure SetUnitIndex(A1: Integer; A2: Integer);  { draft }
    procedure SortUnits;  { draft }
  end;

  { TUnitIndexListCollection (instance size 12, VMT 557111A4) }
  TUnitIndexListCollection = class(TObject)
  public
    F_UnitIndexListCollection_04: Integer;
    F_UnitIndexListCollection_08: Integer;
    destructor Destroy; override;
    constructor Create;  { draft }
    procedure LoadFromStream;  { draft }
    procedure SaveToStream;  { draft }
    procedure GetCollectionCount(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure GetU(A1: Integer; A2: Integer);  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
    procedure DeleteUnit(A1: Integer; A2: Integer);  { draft }
    procedure GetRndCollection;  { draft }
  end;

