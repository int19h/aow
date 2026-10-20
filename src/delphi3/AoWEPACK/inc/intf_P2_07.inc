{ Interface declaration run owned by P2. }
  { THeroJoinEventLog (instance size 60, VMT 55711D94) }
  THeroJoinEventLog = class(TJoinEventLog)
  public
    class function ClassID: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    function Accept(var ErrorText: string): Boolean; override;
    function ExecuteAI: Boolean;
  end;

  { THeroEmergeEventLog (instance size 44, VMT 55711ED8): +18 FUnitID; +1C FDay;
    +20 FText; +24 FMode; +28 FLocationName. }
  THeroEmergeEventLog = class(TEventLog)
  public
    FUnitID: Integer;  { $18 }
    FDay: Integer;  { $1C }
    FText: string;  { $20 }
    FMode: THeroJoinMode;  { $24 }
    F_HeroEmergeEventLog_25: array[0..2] of Byte;
    FLocationName: string;  { $28 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
    procedure Setup(Hero: THero; Player: Shortint; Mode: THeroJoinMode);
    function CreateHeroJoinEventLog: THeroJoinEventLog;
    function ExecuteAI: Boolean;
  end;

  { THero (instance size 156, VMT 55711FEC): +54 FUpgradePending;
    +40 FHeroResource; +44 FHeroResourceIndex; +48 FExperience; +50 FUsedSkillPoints;
    +58 FDeathDay; +5C FDeathPlayer; +4C FLevel; +55 FHeroStatus; +60 FHeroName;
    +64 FNickname; +68 FRace; +69 FGender; +6A..6F unit statistics; +78 FCastSpellInstantly; +79 FMovePoints; +7A FHitPoints; +7C FPowerSource;
    +80 FCastingPoints; +88 FCastingMana; +8C FCastingProgress; +90 FLibraryID; +94 FLibraryName; +98 FRegistered. }
  THero = class(TAbstractUnit)
  public
    FFaceIndex: Integer; { $3C }
    FHeroResource: THeroResource;  { $40 }
    FHeroResourceIndex: Integer;  { $44 }
    FExperience: Integer;  { $48 }
    FLevel: Byte;  { $4C }
    F_Hero_4D: array[0..2] of Byte;
    FUsedSkillPoints: Integer;  { $50 }
    FUpgradePending: Boolean;  { $54 }
    FHeroStatus: THeroStatus; { $55 }
    F_Hero_56: array[0..1] of Byte;
    FDeathDay: Integer;  { $58 }
    FDeathPlayer: Shortint;  { $5C }
    FMode: THeroMode; { $5D }
    F_Hero_5E: array[0..1] of Byte;
    FHeroName: string;  { $60 }
    FNickname: string;  { $64 }
    FRace: Shortint; { $68 }
    FGender: TUnitGender;  { $69 }
    FUnitAttack: Shortint;  { $6A }
    FUnitDefense: Shortint;  { $6B }
    FUnitDamage: Shortint;  { $6C }
    FUnitHits: Shortint;  { $6D }
    FUnitMoves: Shortint;  { $6E }
    FUnitResistance: Shortint;  { $6F }
    FHeroItems: THeroItems; { $70 }
    FInventory: THeroInventory; { $74 }
    FCastSpellInstantly: Boolean; { $78 }
    FMovePoints: Shortint;  { $79 }
    FHitPoints: Shortint;  { $7A }
    F_Hero_7B: array[0..0] of Byte;
    FPowerSource: THeroPowerSource; { $7C }
    FCastingPoints: Shortint; { $80 }
    F_Hero_81: array[0..2] of Byte;
    FCastingSpellID: Integer; { $84 }
    FCastingMana: Integer;  { $88 }
    FCastingProgress: Integer;  { $8C }
    FLibraryID: Integer;  { $90 }
    FLibraryName: string;  { $94 }
    FRegistered: Boolean;  { $98 }
    F_Hero_99: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetAbSet(A1: Integer): Boolean; override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    function GetAbilitySelectionTypes: TAbilitySelectionTypes; override;
    procedure Changed; override;
    function GetUpkeep: Shortint; override;
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
    function GetMoveTypes: TMoveTypes; override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetProtectionTypes: TDamageTypes; override;
    function GetFace: TLibraryImage; override;
    function GetName: string; override;
    function GetAlignment: TAlignment; override;
    function GetPreviewImage: TLibraryImage; override;
    function GetGender: TUnitGender; override;
    function GetUnitType: TUnitType; override;
    function GetUnitGFXResourceIndex: Integer; override;
    function GetCampaignTransferPoints: Integer; override;
    function GetCastingPointsMax: Shortint; override;
    function GetCastingPoints: Shortint; override;
    procedure SetCastingPoints(Value: Shortint); override;
    function GetPowerGeneration: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    function GetAbilityLevel(AbilityID: Integer): Integer; override;
    function GetAbilityEnabled(AbilityID: Integer): Boolean; override;
    function GetAbilitySet(AbilityID: Integer): Boolean; override;
    function GetAbilityName(AbilityID: Integer): string; override;
    function GetAbilityOwner(AbilityID: Integer): TAbilityOwner; override;
    function GetAbilityCount: Integer; override;
    function GetExperience: Integer; override;
    procedure SetExperience(Value: Integer); override;
    function GetNextLevelExperience: Integer; override;
    function GetDescription: TStrings; override;
    procedure SetPlayer(Player: Shortint); override;
    function GetObtainValue: Integer; override;
    function CanActivate: Boolean; override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanJoin(Player: Shortint): Boolean; override;
    function OfferToJoin(Player: Shortint): Boolean; override;
    function ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer; override;
    procedure Killed; override;
    procedure Resurrect; override;
    procedure Animate; override;
    function GetNickname: string; virtual; { $1B8 }
    procedure SetNickname(Value: string); virtual; { $1BC }
    procedure SetHeroResourceIndex(Value: Integer); virtual;  { $1C0 }
    procedure EditDropMsg(var Msg: TEMsg); virtual;  { $1C4 }
    function GetLibraryName: string;
    procedure UpdateFromLibraryBegin;
    procedure UpdateFromLibraryEnd;
    procedure UpdateFromLibrary;
    function GetLibraryHero: Boolean;
    function UsedSkillPoints: Integer;
    function EmergedToPlayer: Shortint;
    procedure DropItemsOnMap(Map: TAoWHSMap; X, Y, L: Shortint);
    function CompatibleHero(Hero: THero): Boolean;
    function GetSkillPoints: Integer;
    function GetSkillPointsMax: Integer;
    function GetLevelMax: Integer;
    function LevelToExperience(Level: Integer): Integer;
    function ExperienceToLevel(Experience: Integer): Shortint;
    function GetLevel: Shortint;
    procedure SetLevel(Value: Shortint);
    function GetHeroType: THeroType;
    procedure SetUnitAttack(Value: Shortint);
    procedure SetUnitDefense(Value: Shortint);
    procedure SetUnitDamage(Value: Shortint);
    procedure SetUnitHits(Value: Shortint);
    procedure SetUnitMoves(Value: Shortint);
    procedure SetUnitResistance(Value: Shortint);
    procedure LinkToResource;
    procedure Loaded;
    procedure ListSpells(var List: TSpellList);
    procedure ExecuteUpgradeHeroAI;
    procedure ValidateHeroUpgrade;
    function GetUnitAbilityEnabled(AbilityID: Integer): Boolean;
    function GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
    function GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
    procedure ResetSkillPoints;
    procedure ResetResourceSettings;
    procedure UpdateSettings;
    procedure SetRace(Value: Shortint);
    procedure SetFaceIndex(Value: Integer);
    function CreateHeroUpdateTE: THeroUpdateTE;
    function GetItemsOnGround: TItemList;
    function CanUseItem(ItemID: Integer; var Reason: string): Boolean;
    function UseItem(ItemID: Integer): Boolean;
    function CanPlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
    function CanSwapItem(ItemID1, ItemID2: Integer): Boolean;
    function SwapItem(ItemID1, ItemID2: Integer): Boolean;
    function PlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
    function ExecuteSwapItem(ItemID1, ItemID2: Integer): Boolean;
    function AutoPlaceItem(Item: TItem): Boolean;
    function ExecutePlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
    { conflict: procedure ExecutePlaceItem(ItemID: Integer; Position: THeroItemPosition); }
    function ExecuteStartCasting(SpellID: Integer): Boolean;
    procedure RemoveCastingReadyEventLog;
    function ExecuteCancelCasting: Boolean;
    procedure CastingDone(SpellID, Mana: Integer);
    function CastingMana(Spell: TSpell): Integer;
    function CastingTurns(Spell: TSpell): Integer;
    function Casting: Boolean;
    function CastingReady: Boolean;
    function CastingTurnsLeft: Integer;
    function CanCastSpellInstantly(SpellID, Mana: Integer; var Reason: string): Boolean;
    function CanCastSpell(SpellID: Integer; var Reason: string): Boolean;
    function CastSpell(SpellID: Integer; var Reason: string): Boolean;
    function CanCastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
    function CastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
    function CancelCasting: Boolean;
  end;

  { TLeader (instance size 164, VMT 55712238) }
  TLeader = class(THero)
  public
    F_Leader_9C: Byte;
    F_Leader_9D: array[0..2] of Byte;
    F_Leader_A0: Integer;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Changed; override;
    function GetUpkeep: Shortint; override;
    function GetPowerGeneration: Integer; override;
    procedure SetPlayer(Player: Shortint); override;
    function GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer; override;
    function CanActivate: Boolean; override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanDisband(var Reason: string): Boolean; override;
    procedure Killed; override;
    function GetNickname: string; override;
    procedure SetNickname(Value: string); override;
    procedure SetHeroResourceIndex(Value: Integer); override;
    procedure EditDropMsg(var Msg: TEMsg); override;
    function GetSpherePicks(Sphere: TMagicSphere): Byte;
    procedure GetSpheres(A1: Integer);  { draft }
    function GetSphereCount: Integer;
    procedure SetSpherePicksMax(A1: Byte);  { draft }
    procedure CanAddSphere(A1: Integer);  { draft }
    function AddSphere(Sphere: TMagicSphere): Boolean;
    procedure DeleteSphereIndex(A1: Integer);  { draft }
    procedure DeleteSphere(A1: Byte; A2: Integer);  { draft }
    procedure ClearSpheres;  { draft }
  end;

  { THeroList (instance size 12, VMT 557124C8) }
  THeroList = class(TEReferenceNode)
  public
    procedure FindHero(A1: Integer);  { draft }
    function GetHero(Index: Integer): THero;
  end;

  { THeroControl (instance size 24, VMT 557125BC) }
  THeroControl = class(TEObject)
  public
    F_HeroControl_08: Integer;
    F_HeroControl_0C: Integer;
    F_HeroControl_10: Integer;
    F_HeroControl_14: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure UpdateLibraryHeroes;  { draft }
    function GetHero(Index: Integer): THero;
    function GetCount: Integer;
    function FindID(ID: Integer): THero;
    procedure IndexOf;  { draft }
    procedure IndexOfLibraryEx(A1: Integer; A2: Integer);  { draft }
    procedure ValidateLibraryHeroes;  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure RegisterHero(Hero: THero);
    procedure UnRegisterHero(Hero: THero);
    procedure HeroChanged(Hero: THero);
    procedure GetAverageFreeHeroLevel(A1: Integer; A2: Integer);  { draft }
    function GetMinFreeHeroLevel: Integer;
    procedure ListDeadHeroes(A1: Integer);  { draft }
  end;

  { THeroLibrary (instance size 20, VMT 5571267C) }
  THeroLibrary = class(THeroList)
  public
    F_HeroLibrary_0C: Integer;
    F_HeroLibrary_10: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure CreateUniqueLibraryID;  { draft }
    procedure CreateHero;  { draft }
    procedure GetName(A1: Integer);  { draft }
    procedure FindLibraryID(A1: Integer);  { draft }
    procedure LoadFromFile;  { draft }
    procedure SaveToFile;  { draft }
  end;

  { THeroLibraryManager (instance size 16, VMT 55712788) }
  THeroLibraryManager = class(TEObject)
  public
    F_HeroLibraryManager_08: Integer;
    F_HeroLibraryManager_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLibrary(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure ReadUserLibraries;  { draft }
    procedure WriteUserLibraries;  { draft }
    procedure IndexOfLibraryName(A1: Integer);  { draft }
    procedure IndexOfLibrary;  { draft }
    function FindHero(const LibraryName: string; LibraryID: Integer): THero;
    procedure CreateLibrary(A1: Integer);  { draft }
    procedure DeleteLibrary(A1: Integer);  { draft }
  end;

  { THeroResource (instance size 52, VMT 55712854): +20 FRace; +21 FHeroType;
    +22 FAlignment; +24..29 base statistics; +2C FAbilities; +30 FFaceIndex. }
  THeroResource = class(TAbstractUnitResource)
  public
    F_HeroResource_1C: Integer;
    FRace: Shortint;  { $20 }
    FHeroType: THeroType;  { $21 }
    FAlignment: TAlignment;  { $22 }
    F_HeroResource_23: Byte;
    FAttack: Shortint;  { $24 }
    FDefense: Shortint;  { $25 }
    FDamage: Shortint;  { $26 }
    FHits: Shortint;  { $27 }
    FMoves: Shortint;  { $28 }
    FResistance: Shortint;  { $29 }
    F_HeroResource_2A: array[0..1] of Byte;
    FAbilities: TAbilityOwner;  { $2C }
    FFaceIndex: Integer; { $30 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function ResourceUserClassID: Integer; override;
    procedure HeroResourceIndex;  { draft }
    procedure UsedSkillPoints;  { draft }
  end;

  { THeroResourceList (instance size 20, VMT 5571294C) }
  THeroResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetHeroResource(Index: Integer): THeroResource;
    procedure CreateHeroResourceStrings(A1: Byte);  { draft }
    function Find(Race: Integer; HeroType: THeroType): Integer;
  end;

  { TAdjustableUnit (instance size 72, VMT 55712A54): +3C attack; +3D defense; +3E resistance;
    +3F hits; +40 damage; +41 immunity; +43 protection; +45 hit points. }
  TAdjustableUnit = class(TAbstractUnit)
  public
    FAttack: Shortint;  { $3C }
    FDefense: Shortint;  { $3D }
    FResistance: Shortint;  { $3E }
    FHits: Shortint;  { $3F }
    FDamage: Shortint;  { $40 }
    FImmunityTypes: TDamageTypes;  { $41 }
    FProtectionTypes: TDamageTypes;  { $43 }
    FHitPoints: Shortint;  { $45 }
    F_AdjustableUnit_46: array[0..1] of Byte;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetAttack: Shortint; override;
    function GetDefense: Shortint; override;
    function GetDamage: Shortint; override;
    function GetResistance: Shortint; override;
    function GetHits: Shortint; override;
    function GetHitPoints: Shortint; override;
    procedure SetHitPoints(Value: Shortint); override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetProtectionTypes: TDamageTypes; override;
    procedure MakeDefaultLevelUnit(Level: Shortint);
  end;

  { TWallUnit (instance size 64, VMT 55712C84): +3C FWallType; +3D FHitPoints; +3E FHits. }
  TWallUnit = class(TAbstractUnit)
  public
    FWallType: TWallType;  { $3C }
    FHitPoints: Shortint;  { $3D }
    FHits: Shortint;  { $3E }
    F_WallUnit_3F: Byte;
    function GetDefense: Shortint; override;
    function GetHits: Shortint; override;
    function GetHitPoints: Shortint; override;
    function GetImmunityTypes: TDamageTypes; override;
    function GetName: string; override;
    function GetUnitType: TUnitType; override;
    procedure SetWallType(Value: TWallType);
  end;

  { TArmyID (instance size 20, VMT 55712FF4) }
  TArmyID = class(TEObject)
  public
    F_ArmyID_08: Integer;
    F_ArmyID_0C: Byte;
    F_ArmyID_0D: array[0..2] of Byte;
    F_ArmyID_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Valid: Boolean;
    function RetrieveArmy(var A1: TArmyHS; var A2: Byte): Boolean;
  end;

  { TArmy (instance size 44, VMT 557130EC) }
  TArmy = class(TUnitList)
  public
    F_Army_10: Byte;
    F_Army_11: Byte;
    FPlayer: Shortint;  { $12 }
    FX: Shortint; { $13 }
    FY: Shortint; { $14 }
    FL: Shortint; { $15 }
    FRace: Byte; { $16 }
    F_Army_17: Byte;
    F_Army_18: Integer;
    F_Army_1C: Integer;
    F_Army_20: Integer;
    F_Army_24: Byte;
    F_Army_25: Byte;
    F_Army_26: Byte;
    F_Army_27: Byte;
    F_Army_28: Byte;
    F_Army_29: Byte;
    F_Army_2A: Byte;
    F_Army_2B: array[0..0] of Byte;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed; override;
    function GetPlayer: Shortint; override;
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint); override;
    function CanAddUnit(AUnit: TAbstractUnit): Boolean; override;
    function CanDeleteUnit(AUnit: TAbstractUnit): Boolean; override;
    function AddUnit(AUnit: TAbstractUnit): Boolean; override;
    function AddUnits(Units: TUnitList): Boolean; override;
    procedure GetUnitConcealedForPlayer(A1: Integer; A2: Integer); virtual;  { +0B8 draft }
    procedure GetConcealedForPlayer(A1: Byte); virtual;  { +0BC draft }
    procedure Kill(A1: Integer);  { draft }
    procedure GetStrengthEx(A1: Integer; A2: Integer);  { draft }
    procedure GetStrengthMaxEx(A1: Integer; A2: Integer);  { draft }
    procedure ReturnBattleFieldInfo(A1: Integer; A2: Integer);  { draft }
    function HealUnits(Selection: Byte): Boolean;
    procedure CreateGroupID(A1: Integer);  { draft }
    procedure GetGroup(A1: Byte);  { draft }
    procedure SetGroup(A1: Integer; A2: Integer);  { draft }
    procedure GetGroupSelection(A1: Integer);  { draft }
    procedure GetBehavior;  { draft }
    procedure SetBehavior(Player: Shortint; Behavior: TGroupBehavior);
    procedure GetOldAIBehavior;  { draft }
    procedure InitializeGroupBehavior;  { draft }
    procedure UpdateGroupBehavior(A1: Integer; A2: Integer);  { draft }
    function CreateID(A1: Byte): TArmyID;
    function GetArmyHS: TArmyHS;
    procedure AssignSettings(A1: Integer);  { draft }
    procedure SetFullyConcealed(A1: Byte);  { draft }
    procedure GetFullyConcealed;  { draft }
    procedure UpdateConcealment(A1: Integer; A2: Integer);  { draft }
    procedure SetXYL(A1: Byte; A2: Byte; A3: Byte);
    procedure GetRace(A1: Integer);  { draft }
    procedure GetUpkeep;  { draft }
    procedure ResetDestinationPos;  { draft }
    procedure SetDestinationPos(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure ConcealedUnitsCount;  { draft }
    procedure UpdateConcealedUnits;  { draft }
    procedure UpdateUpkeep;  { draft }
    procedure ValidateTerrainEx(A1: Byte; A2: Byte);  { draft }
    procedure ValidateTerrain;  { draft }
    procedure Validate;  { draft }
    procedure UpdateFormation;  { draft }
    procedure Update;  { draft }
    procedure TriggerOnUpdateEvent;  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    function ValidateSelection(A1: Byte): Byte;
    function SelectionCount(Selection: Byte): Integer;
    procedure ValidateMoveSelection(A1: Integer; A2: Integer);  { draft }
    procedure Select;  { draft }
    procedure Unselect;  { draft }
    procedure GetUnitConcealed(A1: Integer);  { draft }
    procedure GetUnitsConcealedForPlayer(A1: Integer; A2: Integer);  { draft }
    procedure SetPlayer(Player: Shortint);
    function ImmunityTypes(A1: Byte): TDamageTypes;
    function ObtainValue(Player: Shortint): Integer;
    { conflict: function ObtainValue(Selection: Byte): Integer; }
    function MovePoints(A1: Byte): Shortint;
    procedure Moves(A1: Integer);  { draft }
    procedure MoveTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetPartyMoves(A1: Byte);  { draft }
    procedure MoveOnMovePoints(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure CreateMovePointTable(A1: Byte; var Table);
    function ValidTerrainEx(A1: Byte; A2, A3: Shortint): Boolean;
    procedure ValidTerrain(A1: Byte; A2: Integer);  { draft }
    function CanPlace(A1: Shortint; A2: Shortint; A3: Shortint): Boolean;
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure MaxSize(A1: Integer; A2: Integer);  { draft }
    procedure Hero(A1: Integer; A2: Byte);  { draft }
    procedure Leader(A1: Integer);  { draft }
    function Transporter(Player: Byte): TAbstractUnit;
    { conflict: function Transporter(Selection: Byte): TAbstractUnit; }
    procedure IndexOfTransporter(A1: Integer);  { draft }
    function UnitsInTransporter: Boolean;
    procedure UpdateVisibilityRanges(A1: Integer; A2: Integer);  { draft }
    procedure VisibilityRange;  { draft }
    procedure TrueVisionRange;  { draft }
    procedure TurnUnFogOff;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    procedure CanAddUnits(A1: Integer; A2: Integer);  { draft }
    function CanAddUnitSelection(A1: TUnitList; A2: Byte): Boolean;
    procedure AddUnitSelection(A1: Integer; A2: Integer);  { draft }
    procedure SelectionUnit(A1: Byte; A2: Integer);  { draft }
    procedure MakeIndependent(A1: Integer; A2: Integer);  { draft }
    procedure UpdateIndependentRelation;  { draft }
    procedure Desert(A1: Byte);  { draft }
    procedure GetPartyStatus(A1: Integer);  { draft }
    procedure UpdateDesertion;  { draft }
    procedure ValidateCrusaders;  { draft }
    procedure NewTurn(A1: Byte);  { draft }
    procedure NewTurnDone(A1: Byte);  { draft }
    procedure NewDay;  { draft }
    procedure CanActivate;  { draft }
    procedure GetMoveAction(A1: Byte; A2: Integer);  { draft }
    function GetCanJoinSelection(Player: Shortint): Byte;
    function GetJoinSelection(Player: Shortint): Byte;
    function JoinAmount(Player: Shortint; Selection: Byte): Integer;
    procedure IncommingNegotiateRequest(A1: Integer);  { draft }
    procedure IncommingNegotiateOffer(A1: Integer);  { draft }
    procedure TriggerFireDamage;  { draft }
    procedure RetrieveStormDamageInfo(A1: Byte);  { draft }
    procedure IncommingStorm(A1: TStormType; A2: Integer; A3: Shortint);
    procedure UpdateAITarget(A1: Integer; A2: Integer);  { draft }
    procedure AIMovePriority;  { draft }
    procedure ResetMoveDone;  { draft }
    procedure CanCombine(A1: Integer; A2: Integer);  { draft }
  end;

  { TArmyView (instance size 96, VMT 55713210) }
  TArmyView = class(TArmy)
  public
    F_ArmyView_2C: Byte;
    F_ArmyView_2D: array[0..14] of Byte;
    F_ArmyView_3C: Word;
    F_ArmyView_3E: array[0..1] of Byte;
    F_ArmyView_40: Byte;
    F_ArmyView_41: array[0..30] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint); override;
    procedure GetUnitConcealedForPlayer(A1: Integer; A2: Integer); override;
    procedure GetConcealedForPlayer(A1: Byte); override;
    procedure Setup(A1: TArmy; A2: Byte); virtual;  { +0C0 }
    procedure SetConcealedForPlayer(A1: Byte; A2: Integer);  { draft }
    procedure SetUnitConcealedForPlayer(A1: Integer; A2: Integer; A3: Integer);  { draft }
  end;

  { TArmyHS (instance size 36, VMT 557133A0) }
  TArmyHS = class(TUnitHS)
  public
    FArmy: TArmy;  { $1C }
    F_ArmyHS_20: Byte;
    F_ArmyHS_21: Byte;
    F_ArmyHS_22: Byte;
    F_ArmyHS_23: array[0..0] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetSelected: Boolean; override;
    function CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    procedure CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    function EditName: string; override;
    function MoveTo(Field: TMapField): Boolean; override;
    function PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc); override;
    procedure UpdateFlagID; override;
    function MoveFirst(Direction: Byte; Instant: Boolean): Shortint; override;
    function GetMoveSteps: Integer; override;
    procedure GetFogEnabled;  { draft }
    function VisibleForSeatedPlayer: Boolean;
    procedure ArmyUpdated(A1: Integer);  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure PlacePrivate(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlayMoveSFX;  { draft }
    procedure ShowEnchantments(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function PlaceEx(X, Y: Shortint; Mode: TArmyPlaceMode; L: Shortint): Boolean;
  end;

  { TArmyHSList (instance size 20, VMT 5571352C) }
  TArmyHSList = class(TEChangeNotifyEventList)
  public
    function GetArmyHS(Index: Integer): TArmyHS;
  end;

  { TArmyEventLog (instance size 52, VMT 55713628) }
  TArmyEventLog = class(TEventLog)
  public
    FArmyView: TArmyView; { $18 }
    FArmyText: string; { $1C }
    FArmyMessages: TStrings; { $20 }
    FArmyIcon: Integer; { $24 }
    FDamageValues: TByteList; { $28 }
    FDamageTypes: TByteList; { $2C }
    F_ArmyEventLog_30: Byte;
    F_ArmyEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function GetLeftIcon: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
    procedure SetArmyView;  { draft }
    procedure LeaderKilled;  { draft }
    procedure PartyDestroyed;  { draft }
    procedure ValidateGameOver;  { draft }
  end;

  { TArmyInfoEventLog (instance size 52, VMT 55713724) }
  TArmyInfoEventLog = class(TEventLog)
  public
    F_ArmyInfoEventLog_18: Integer;
    F_ArmyInfoEventLog_1C: Byte;
    F_ArmyInfoEventLog_1D: array[0..2] of Byte;
    F_ArmyInfoEventLog_20: Integer;
    F_ArmyInfoEventLog_24: Integer;
    F_ArmyInfoEventLog_28: Integer;
    F_ArmyInfoEventLog_2C: Integer;
    F_ArmyInfoEventLog_30: Byte;
    F_ArmyInfoEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
    procedure SetArmyView;  { draft }
  end;

