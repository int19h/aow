{ Interface declaration run owned by P2. }
  TP2UnitShowInfo = record
    Direction: Byte;
    Overlays: TUnitOverlayModes;
    Animation: TUnitAnimation;
    Frame: Integer;
    Looped: Boolean;
  end;

  TP2MovePointTable = array[0..15, -1..14] of Shortint;

  { TUnitControl (instance size 20, VMT 557105E8):
    +08 FNextUnitID; +0C FUnitTable; +10 FUnits. }
  TUnitControl = class(TEObject)
  public
    FNextUnitID: Integer;
    FUnitTable: TIntegerHashTable256;
    FUnits: TList;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetCount: Integer;
    procedure TriggerUnitsChanged;
    function GetUnit(Index: Integer): TAbstractUnit;
    function FindUnit(ID: Integer): TAbstractUnit;
    function GetFreeID: Integer;
    procedure RegisterUnit(AUnit: TAbstractUnit);
    procedure UnRegisterUnit(AUnit: TAbstractUnit);
  end;

  { TAbstractUnit (instance size 60, VMT 55710740):
    +14 FRefCount; +18 FUnitID; +1C FGroupID; +20 FGroup: TAIGroup;
    +25 FUnitStatus.
    Other fields retain their offset names pending recovery. }
  TAbstractUnit = class(TAbilityOwner)
  public
    FRefCount: Integer;
    FUnitID: Integer;
    FGroupID: Integer;
    FGroup: TAIGroup;  { $20; group VMT at 55782FF8 }
    FPlayer: Shortint;
    FUnitStatus: TUnitStatus;
    FMoraleValue: Shortint;
    F_AbstractUnit_27: array[0..0] of Byte;
    FOffensiveStrength: array[TDamageType] of Byte;
    FMaxOffensiveStrength: Byte;
    F_AbstractUnit_33: array[0..0] of Byte;
    FDefensiveStrength: Integer;
    F_AbstractUnit_38: Byte;
    F_AbstractUnit_39: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetOwnerName: string; override;
    function GetAbilitySelectionTypes: TAbilitySelectionTypes; override;
    procedure Changed; override;
    function RemoveAbility(A1: Integer): Boolean; override;
    function GetUpkeep: Shortint; virtual;  { +09C draft }
    function GetUnitLevel: Shortint; virtual;
    function GetRace: Shortint; virtual;  { +0A4 draft }
    function GetInherentAttack: Shortint; virtual;  { +0A8 draft }
    function GetInherentDefense: Shortint; virtual;  { +0AC draft }
    function GetInherentDamage: Shortint; virtual;  { +0B0 draft }
    function GetInherentResistance: Shortint; virtual;  { +0B4 draft }
    function GetInherentAbility(AbilityID: Integer): Boolean; virtual;  { +0B8 draft }
    function GetInherentAbilityLevel(AbilityID: Integer): Shortint; virtual;  { +0BC draft }
    function GetAttack: Shortint; virtual;  { +0C0 draft }
    function GetDefense: Shortint; virtual;  { +0C4 draft }
    function GetDamage: Shortint; virtual;  { +0C8 draft }
    function GetResistance: Shortint; virtual;  { +0CC }
    function GetHits: Shortint; virtual;  { +0D0 }
    function GetMoves: Shortint; virtual;  { +0D4 draft }
    function GetMovePoints: Shortint; virtual;  { +0D8 draft }
    procedure SetMovePoints(Value: Shortint); virtual;  { +0DC draft }
    function GetHitPoints: Shortint; virtual;  { +0E0 draft }
    procedure SetHitPoints(Value: Shortint); virtual;  { +0E4 }
    function GetMoveTypes: TMoveTypes; virtual;  { +0E8 draft }
    function GetImmunityTypes: TDamageTypes; virtual;  { +0EC draft }
    function GetProtectionTypes: TDamageTypes; virtual;  { +0F0 draft }
    function GetFace: TLibraryImage; virtual;  { +0F4 draft }
    function GetName: string; virtual;
    function GetAlignment: TAlignment; virtual;  { +0FC }
    function GetPreviewImage: TLibraryImage; virtual;  { +100 draft }
    function GetTransportCapacity: Byte; virtual;  { +104 draft }
    function GetTransporter: Boolean; virtual;  { +108 draft }
    function GetGender: TUnitGender; virtual;  { +10C draft }
    function GetBloodType: TBloodType; virtual;  { +110 draft }
    function GetUnitType: TUnitType; virtual;  { +114 draft }
    function GetUnitGFXResourceIndex: Integer; virtual;  { +118 draft }
    function CanAddToList(AList: TUnitList): Boolean; virtual;
    function GetWallCombatFeatures: TWallCombatFeatures; virtual;  { +120 draft }
    function GetCampaignTransferPoints: Integer; virtual;  { +124 draft }
    function GetCastingPointsMax: Shortint; virtual; { $128 }
    function GetCastingPoints: Shortint; virtual; { $12C }
    procedure SetCastingPoints(Value: Shortint); virtual; { $130 }
    function GetPowerGeneration: Integer; virtual;  { +134 draft }
    procedure NewDay; virtual;  { +138 draft }
    procedure NewTurn(Player: Shortint); virtual;  { +13C draft }
    procedure NewTurnDone(Player: Shortint); virtual;  { +140 draft }
    function GetAbilityLevel(AbilityID: Integer): Integer; virtual;  { +144 draft }
    function GetAbilityEnabled(AbilityID: Integer): Boolean; virtual;  { +148 draft }
    function GetAbilitySet(AbilityID: Integer): Boolean; virtual;  { +14C draft }
    function GetAbilityName(AbilityID: Integer): string; virtual;  { +150 draft }
    function GetAbilityOwner(AbilityID: Integer): TAbilityOwner; virtual;  { +154 draft }
    function GetAbilityCount: Integer; virtual;  { +158 draft }
    function GetExperience: Integer; virtual;  { +15C draft }
    procedure SetExperience(Value: Integer); virtual;  { +160 }
    function GetNextLevelExperience: Integer; virtual;  { +164 draft }
    function GetDescription: TStrings; virtual;  { +168 draft }
    procedure SetPlayer(Player: Shortint); virtual;
    function GetIndependentRelation: Shortint; virtual;  { +170 draft }
    function GetObtainValue: Integer; virtual;  { +174 draft }
    function GetUnitSize: TUnitSize; virtual;  { +178 draft }
    function GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer; virtual;  { +17C draft }
    function CanActivate: Boolean; virtual;  { +180 draft }
    procedure Activate; virtual;  { +184 draft }
    procedure Deactivate; virtual;  { +188 draft }
    procedure MovedTo(OldField, NewField: TMapField; MaxCost: Integer); virtual;  { +18C draft }
    function CanDisband(var Reason: string): Boolean; virtual;  { +190 draft }
    function CanJoin(Player: Shortint): Boolean; virtual;  { +194 draft }
    function JoinAmount(Player: Shortint): Integer; virtual; { $198 }
    function OfferToJoin(Player: Shortint): Boolean; virtual;  { +19C draft }
    procedure GetJoinMessage(Player: Shortint; Count, Amount: Integer; Mode: TJoinMode; Messages: TStrings); virtual;  { +1A0 draft }
    function ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer; virtual;  { +1A4 draft }
    procedure UnitKilled; virtual;  { +1A8 draft }
    procedure Killed; virtual;  { +1AC }
    procedure Resurrect; virtual;  { +1B0 draft }
    procedure Animate; virtual;  { +1B4 draft }
    procedure RetrieveDamageInfo(Attack, Damage: Shortint; DamageTypes: TDamageTypes;
      var DamageValue, ObtainValue: Integer);
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint);
    function GetRelationValue(Player, IndependentRelation: Shortint): Integer;
    function GetRelation(Player, IndependentRelation: Shortint): TStatus;  { draft }
    function UnitRelation(AUnit: TAbstractUnit): TStatus;
    function UpdateMoraleValue: Shortint;
    function GetMorale: TMorale;
    procedure UpdateEnchanted;  { draft }
    procedure RemoveEnchantments;  { draft }
    procedure RemoveHandicaps;  { draft }
    procedure RegisterEnchantments;  { draft }
    procedure UnregisterEnchantments;  { draft }
    function AbilityToEnchantment(AbilityID: Integer): TUnitEnchantment;
    function CanDispelEnchantment(Player: Shortint): Boolean;
    procedure ListEnchantments(List: TECustomNode);
    procedure UpdateDefensiveStrength;  { draft }
    procedure UpdateOffensiveStrength;  { draft }
    function GetStrength(DamageType: TDamageType): Integer;
    function GetStrengthMax(DamageTypes: TDamageTypes): Integer;
    function GetCombatValue(Target: TAbstractUnit; Mode: Byte): Integer;
    procedure ListAbilityInfo(Names, Types, Sources: TStrings);
    function GetManaUpkeep: Integer;
    function GetTransporting: Boolean;
    procedure CreateMovePointTable(var Table: TP2MovePointTable);
    function ValidTerrain(TerrainType, OverlayType: Shortint): Boolean;
    procedure ExecuteTrailOfDarkness(MapField: TMapField);
    procedure PathOfLifeTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
    procedure PathOfDecayTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
    procedure PathOfFrostTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
    procedure PathOfFrostTerrainChanged(MapField: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
    procedure UpdatePathOfFrost;
    function ConcealedOnMapF(Field: TAoWMapField): Boolean;
    function ExecuteStormDamage(Storm: TStormType): Integer;
    function MovePointCost(TerrainType, OverlayType: Shortint): Integer;
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
    function VisibilityRange: Integer;
    function TrueVisionRange: Integer;
    function CanPlace(X,Y,L: Integer; Player: Shortint; Mode: TUnitPlaceMode): Boolean;
    function Place(X,Y,L: Integer; Player: Shortint; Mode: TUnitPlaceMode): TArmyHS;
    procedure ValidateCrusader;  { draft }
    procedure Show(X,Y: Integer; const SD: TSurfaceDesc);
    procedure ShowFace(const R: TRect; const SD: TSurfaceDesc);
    function ExecuteDamageRole(Attack, Damage: Integer; DamageTypes: TDamageTypes): Integer;
    function ExecuteResistanceRole(Attack: Integer; DamageType: TDamageType): Boolean;
    function ExecuteDamageEffectsRole(DamageTypes: TDamageTypes): TDamageTypes;
    function ExecuteDamageEffects(DamageTypes: TDamageTypes): TDamageTypes;
    function ExecuteCombatDamageEffects(Combat: TCombat; DamageTypes: TDamageTypes): TDamageTypes;
    function OptimalDamageType(DamageTypes: TDamageTypes): TDamageType;
    function Disband: Boolean;
  end;

  { TAbstractUnitResource (instance size 28, VMT 5571096C): +18 FUnitGFXResourceIndex. }
  TAbstractUnitResource = class(TEResource)
  public
    FUnitGFXResourceIndex: Integer;  { $18 }
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    class function ResourceEditName: string; override;
    function DropUnit(Xhx, Yhx, Lhx: Integer): Boolean; virtual;
    function GetPreviewImage: TLibraryImage; virtual;  { +068 draft }
    function GetFace: TLibraryImage; virtual;
    function GetObtainValue: Integer; virtual;
    procedure SetUnitGFXResourceIndex(Value: Integer);
    procedure EditDropMsg(var Msg: TEMsg);
  end;

  { TUnitResource (instance size 84, VMT 55710A64): +1C FName; +20 FRace;
    +21 FChampion; +24 FNickname; +28..31 unit statistics; +38 FAbilities[rank];
    +44 FTransportCapacity; +48 FDescription; +4C FObtainValue; +50 size; +51 blood. }
  TUnitResource = class(TAbstractUnitResource)
  public
    FName: string;  { $1C }
    FRace: Shortint;
    FChampion: Boolean;  { $21 }
    F_UnitResource_22: array[0..1] of Byte;
    FNickname: string;  { $24 }
    FAlignment: TAlignment;
    FAttack: Shortint;
    FDefense: Shortint;
    FDamage: Shortint;
    FHits: Shortint;
    FMoves: Shortint;
    FResistance: Shortint;
    FLevel: Shortint;
    FUnitType: TUnitType;
    FGender: TUnitGender;
    FReserved32: array[0..5] of Byte;
    FAbilities: array[TUnitRank] of TAbilityOwner;  { $38..$40 }
    FTransportCapacity: Byte;  { $44 }
    F_UnitResource_45: array[0..2] of Byte;
    FDescription: TStringList;  { $48 }
    FObtainValue: Integer;
    FUnitSize: TUnitSize;
    FBloodType: TBloodType;
    F_UnitResource_52: array[0..1] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ResourceUserClassID: Integer; override;
    function CreateResourceUser: Engine.TEObject; override;
    function DropUnit(Xhx, Yhx, Lhx: Integer): Boolean; override;
    function GetObtainValue: Integer; override;
    function GetMoveTypes: TMoveTypes;
    function GetTransportCapacity: Byte;
    function GetUpkeep: Shortint;
    procedure SetDescription(Value: TStrings);
    function UnitResourceIndex: Integer;
    function GetUnitName: string;
  end;

  { TUnitResourceList (instance size 20, VMT 55710B64) }
  TUnitResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetUnitResource(Index: Integer): TUnitResource;
  end;

  { TUnit (instance size 72, VMT 55710CAC) }
  TUnit = class(TAbstractUnit)
  public
    FExperience: Byte;
    FMovePoints: Shortint;
    FHitPoints: Shortint;
    F_Unit_3F: array[0..0] of Byte;
    FUnitResource: TUnitResource;
    FAbAttack: Shortint;
    FAbDefense: Shortint;
    FAbResistance: Shortint;
    FAbDamage: Shortint;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure Changed; override;
    function GetUnitLevel: Shortint; override;
    function GetRace: Shortint; override;
    function GetInherentAttack: Shortint; override;
    function GetInherentDefense: Shortint; override;
    function GetInherentDamage: Shortint; override;
    function GetInherentResistance: Shortint; override;
    function GetAttack: Shortint; override;
    function GetDefense: Shortint; override;
    function GetDamage: Shortint; override;
    function GetResistance: Shortint; override;
    function GetHits: Shortint; override;
    function GetMoves: Shortint; override;
    function GetMovePoints: Shortint; override;
    procedure SetMovePoints(Value: Shortint); override;
    function GetHitPoints: Shortint; override;
    procedure SetHitPoints(Value: Shortint); override;
    function GetFace: TLibraryImage; override;
    function GetName: string; override;
    function GetAlignment: TAlignment; override;
    function GetPreviewImage: TLibraryImage; override;
    function GetTransportCapacity: Byte; override;
    function GetTransporter: Boolean; override;
    function GetGender: TUnitGender; override;
    function GetBloodType: TBloodType; override;
    function GetUnitType: TUnitType; override;
    function GetUnitGFXResourceIndex: Integer; override;
    procedure NewDay; override;
    function GetExperience: Integer; override;
    procedure SetExperience(Value: Integer); override;
    function GetNextLevelExperience: Integer; override;
    function GetDescription: TStrings; override;
    function GetObtainValue: Integer; override;
    function GetUnitSize: TUnitSize; override;
    procedure Activate; override;
    function ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer; override;
    procedure UnitKilled; override;
    procedure Killed; override;
    function GetRank: TUnitRank;
    procedure SetRank(Value: TUnitRank);
    procedure SetUnitResource(Resource: TUnitResource);
  end;

  { TUnitList (instance size 16, VMT 55710EC8): inherited +08 FChildren,
    +0C UpdateCount. }
  TUnitList = class(TEChangeNotifyNode)
  public
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    function GetPlayer: Shortint; virtual;
    function GetStrength(DamageType: TDamageType): Integer; virtual;
    function GetStrengthMax(DamageTypes: TDamageTypes): Integer; virtual;
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint); virtual;
    procedure SortUnits; virtual;
    procedure SortOnMoves; virtual;
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; virtual;
    function CanDeleteUnit(AUnit: TAbstractUnit): Boolean; virtual;
    function AddUnit(AUnit: TAbstractUnit): Boolean; virtual;
    function DeleteUnit(AUnit: TAbstractUnit): Boolean; virtual;
    function AddUnits(Units: TUnitList): Boolean; virtual;
    function IndexOf(AUnit: TAbstractUnit): Integer;
    function IndexOfID(ID: Integer): Integer;
    function IndexOfBehavior(Behavior: TGroupBehavior): Integer;
    function IndexOfGroup(Group: TAIGroup): Integer;
    function IndexOfGroupID(ID: Integer): Integer;
    function FindID(ID: Integer): TAbstractUnit;
    function GetUnit(A1: Integer): TAbstractUnit;
    procedure SetUnit(Index: Integer; AUnit: TAbstractUnit);
  end;

  { TUnitUserList (instance size 16, VMT 55710FEC): inherited +08 FChildren. }
  TUnitUserList = class(TUnitList)
  public
    procedure Clear; override;
    function AddUnit(AUnit: TAbstractUnit): Boolean; override;
    function DeleteUnit(AUnit: TAbstractUnit): Boolean; override;
    procedure AddUnitsEx(Units: TUnitList; Selection: Byte);
  end;

  { TUnitIndexList (instance size 20, VMT 55711118): inherited +04 List,
    +08 Count, +10 Default. }
  TUnitIndexList = class(TIntegerList)
  public
    constructor Create;
    function GetUnitIndex(Index: Integer): Integer;
    procedure VerifyUnits(ShowErrors: Boolean);
    procedure SetUnitIndex(Index, Value: Integer);
    procedure SortUnits;
  end;

  { TUnitIndexListCollection (instance size 12, VMT 557111A4): +04 FCollectionSize; +08 FUnits. }
  TUnitIndexListCollection = class(TObject)
  public
    FCollectionSize: Integer;  { $04 }
    FUnits: TUnitIndexList;  { $08 }
    destructor Destroy; override;
    constructor Create;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function GetCollectionCount(Index: Integer): Integer;
    function GetCount: Integer;
    function GetU(Collection, Index: Integer): Integer;
    function AddUnit(Collection, UnitIndex: Integer): Boolean;
    procedure DeleteUnit(Collection, Index: Integer);
    function GetRndCollection: Integer;
  end;

