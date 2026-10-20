{ Interface declaration run owned by P2. }
  { THeroJoinEventLog (instance size 60, VMT 55711D94) }
  THeroJoinEventLog = class(TJoinEventLog)
  public
    class function ClassID: Integer; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    function Accept(var ErrorText: string): Boolean; override;
    procedure ExecuteAI;  { draft }
  end;

  { THeroEmergeEventLog (instance size 44, VMT 55711ED8) }
  THeroEmergeEventLog = class(TEventLog)
  public
    F_HeroEmergeEventLog_18: Integer;
    F_HeroEmergeEventLog_1C: Integer;
    F_HeroEmergeEventLog_20: Integer;
    F_HeroEmergeEventLog_24: Byte;
    F_HeroEmergeEventLog_25: array[0..2] of Byte;
    F_HeroEmergeEventLog_28: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure Setup(A1: Integer; A2: Byte);  { draft }
    procedure CreateHeroJoinEventLog;  { draft }
    procedure ExecuteAI;  { draft }
  end;

  { THero (instance size 156, VMT 55711FEC) }
  THero = class(TAbstractUnit)
  public
    F_Hero_3C: Integer;
    F_Hero_40: Integer;
    F_Hero_44: Integer;
    F_Hero_48: Integer;
    F_Hero_4C: Byte;
    F_Hero_4D: array[0..2] of Byte;
    F_Hero_50: Integer;
    F_Hero_54: Byte;
    F_Hero_55: Byte;
    F_Hero_56: array[0..1] of Byte;
    F_Hero_58: Integer;
    F_Hero_5C: Byte;
    F_Hero_5D: Byte;
    F_Hero_5E: array[0..1] of Byte;
    F_Hero_60: Integer;
    F_Hero_64: Integer;
    F_Hero_68: Byte;
    F_Hero_69: Byte;
    F_Hero_6A: Byte;
    F_Hero_6B: Byte;
    F_Hero_6C: Byte;
    F_Hero_6D: Byte;
    F_Hero_6E: Byte;
    F_Hero_6F: Byte;
    F_Hero_70: Integer;
    F_Hero_74: Integer;
    F_Hero_78: Byte;
    F_Hero_79: Byte;
    F_Hero_7A: Byte;
    F_Hero_7B: array[0..0] of Byte;
    F_Hero_7C: Integer;
    F_Hero_80: Byte;
    F_Hero_81: array[0..2] of Byte;
    F_Hero_84: Integer;
    F_Hero_88: Integer;
    F_Hero_8C: Integer;
    F_Hero_90: Integer;
    F_Hero_94: Integer;
    F_Hero_98: Byte;
    F_Hero_99: array[0..2] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetAbSet(A1: Integer); override;
    procedure SetAbSet(A1: Integer; A2: Byte); override;
    procedure GetAbilitySelectionTypes(A1: Word; A2: Integer); override;
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
    function GetCastingPointsMax: Byte; override;
    function GetCastingPoints: Byte; override;
    procedure SetCastingPoints(A1: Integer); override;
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
    function GetDescription: Integer; override;
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
    procedure GetNickname(A1: Integer); virtual;  { +1B8 draft }
    procedure SetNickname(A1: Integer; A2: Integer); virtual;  { +1BC draft }
    procedure SetHeroResourceIndex(A1: Integer); virtual;  { +1C0 draft }
    procedure EditDropMsg(A1: Integer); virtual;  { +1C4 draft }
    procedure GetLibraryName(A1: Integer);  { draft }
    procedure UpdateFromLibraryBegin;  { draft }
    procedure UpdateFromLibraryEnd;  { draft }
    procedure UpdateFromLibrary;  { draft }
    procedure GetLibraryHero;  { draft }
    procedure UsedSkillPoints;  { draft }
    procedure EmergedToPlayer;  { draft }
    procedure DropItemsOnMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CompatibleHero(A1: Integer; A2: Integer);  { draft }
    procedure GetSkillPoints;  { draft }
    procedure GetSkillPointsMax;  { draft }
    procedure GetLevelMax;  { draft }
    procedure LevelToExperience(A1: Integer);  { draft }
    procedure ExperienceToLevel(A1: Integer);  { draft }
    procedure GetLevel;  { draft }
    procedure SetLevel(A1: Integer);  { draft }
    procedure GetHeroType;  { draft }
    procedure SetUnitAttack(A1: Integer);  { draft }
    procedure SetUnitDefense(A1: Integer);  { draft }
    procedure SetUnitDamage(A1: Integer);  { draft }
    procedure SetUnitHits(A1: Integer);  { draft }
    procedure SetUnitMoves(A1: Integer);  { draft }
    procedure SetUnitResistance(A1: Integer);  { draft }
    procedure LinkToResource;  { draft }
    procedure Loaded;  { draft }
    procedure ListSpells(A1: Integer);  { draft }
    procedure ExecuteUpgradeHeroAI;  { draft }
    procedure ValidateHeroUpgrade(A1: Integer; A2: Integer);  { draft }
    procedure GetUnitAbilityEnabled;  { draft }
    procedure GetSuperlativeEnabledAbOwner(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperlativeAbOwner(A1: Integer; A2: Integer);  { draft }
    procedure ResetSkillPoints;  { draft }
    procedure ResetResourceSettings;  { draft }
    procedure UpdateSettings;  { draft }
    procedure SetRace(A1: Byte; A2: Integer);  { draft }
    procedure SetFaceIndex(A1: Integer);  { draft }
    procedure CreateHeroUpdateTE;  { draft }
    procedure GetItemsOnGround;  { draft }
    procedure CanUseItem(A1: Integer; A2: Integer);  { draft }
    procedure UseItem;  { draft }
    procedure CanPlaceItem(A1: Integer; A2: Byte);  { draft }
    procedure CanSwapItem(A1: Integer; A2: Integer);  { draft }
    procedure SwapItem(A1: Integer; A2: Integer);  { draft }
    procedure PlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteSwapItem(A1: Integer; A2: Integer);  { draft }
    procedure AutoPlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecutePlaceItem(A1: Integer; A2: Integer);  { draft }
    procedure ExecuteStartCasting(A1: Integer);  { draft }
    procedure RemoveCastingReadyEventLog;  { draft }
    procedure ExecuteCancelCasting;  { draft }
    procedure CastingDone(A1: Integer; A2: Integer);  { draft }
    procedure CastingMana(A1: Integer);  { draft }
    procedure CastingTurns;  { draft }
    procedure Casting;  { draft }
    procedure CastingReady;  { draft }
    procedure CastingTurnsLeft;  { draft }
    procedure CanCastSpellInstantly(A1: Integer; A2: Integer);  { draft }
    procedure CanCastSpell(A1: Integer; A2: Integer);  { draft }
    procedure CastSpell(A1: Integer; A2: Integer);  { draft }
    procedure CanCastCombatSpell(A1: Integer; A2: Integer);  { draft }
    procedure CastCombatSpell(A1: Integer; A2: Integer);  { draft }
    procedure CancelCasting;  { draft }
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
    procedure GetNickname(A1: Integer); override;
    procedure SetNickname(A1: Integer; A2: Integer); override;
    procedure SetHeroResourceIndex(A1: Integer); override;
    procedure EditDropMsg(A1: Integer); override;
    function GetSpherePicks(Sphere: TMagicSphere): Byte;
    procedure GetSpheres(A1: Integer);  { draft }
    procedure GetSphereCount;  { draft }
    procedure SetSpherePicksMax(A1: Byte);  { draft }
    procedure CanAddSphere(A1: Integer);  { draft }
    procedure AddSphere(A1: Byte; A2: Integer);  { draft }
    procedure DeleteSphereIndex(A1: Integer);  { draft }
    procedure DeleteSphere(A1: Byte; A2: Integer);  { draft }
    procedure ClearSpheres;  { draft }
  end;

  { THeroList (instance size 12, VMT 557124C8) }
  THeroList = class(TEReferenceNode)
  public
    procedure FindHero(A1: Integer);  { draft }
    procedure GetHero(A1: Integer);  { draft }
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
    procedure GetHero(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure FindID;  { draft }
    procedure IndexOf;  { draft }
    procedure IndexOfLibraryEx(A1: Integer; A2: Integer);  { draft }
    procedure ValidateLibraryHeroes;  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
    procedure RegisterHero(A1: Integer);  { draft }
    procedure UnRegisterHero(A1: Integer);  { draft }
    procedure HeroChanged;  { draft }
    procedure GetAverageFreeHeroLevel(A1: Integer; A2: Integer);  { draft }
    procedure GetMinFreeHeroLevel;  { draft }
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
    procedure FindHero(A1: Integer; A2: Integer);  { draft }
    procedure CreateLibrary(A1: Integer);  { draft }
    procedure DeleteLibrary(A1: Integer);  { draft }
  end;

  { THeroResource (instance size 52, VMT 55712854) }
  THeroResource = class(TAbstractUnitResource)
  public
    F_HeroResource_1C: Integer;
    F_HeroResource_20: Byte;
    F_HeroResource_21: Byte;
    F_HeroResource_22: Byte;
    F_HeroResource_23: Byte;
    F_HeroResource_24: Byte;
    F_HeroResource_25: Byte;
    F_HeroResource_26: Byte;
    F_HeroResource_27: Byte;
    F_HeroResource_28: Byte;
    F_HeroResource_29: Byte;
    F_HeroResource_2A: array[0..1] of Byte;
    F_HeroResource_2C: Integer;
    F_HeroResource_30: Integer;
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
    procedure GetHeroResource(A1: Integer);  { draft }
    procedure CreateHeroResourceStrings(A1: Byte);  { draft }
    procedure Find(A1: Integer; A2: Byte);  { draft }
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
    F_Army_16: Byte;
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
    procedure HealUnits(A1: Integer);  { draft }
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
    procedure GetArmyHS(A1: Integer; A2: Integer);  { draft }
    procedure AssignSettings(A1: Integer);  { draft }
    procedure SetFullyConcealed(A1: Byte);  { draft }
    procedure GetFullyConcealed;  { draft }
    procedure UpdateConcealment(A1: Integer; A2: Integer);  { draft }
    procedure SetXYL(A1: Byte; A2: Byte; A3: Integer);  { draft }
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
    procedure ImmunityTypes(A1: Integer);  { draft }
    function ObtainValue(Player: Shortint): Integer;
    procedure MovePoints(A1: Integer);  { draft }
    procedure Moves(A1: Integer);  { draft }
    procedure MoveTypes(A1: Integer; A2: Integer);  { draft }
    procedure GetPartyMoves(A1: Byte);  { draft }
    procedure MoveOnMovePoints(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure CreateMovePointTable(A1: Byte; var Table);
    procedure ValidTerrainEx(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure ValidTerrain(A1: Byte; A2: Integer);  { draft }
    function CanPlace(A1: Shortint; A2: Shortint; A3: Shortint): Boolean;
    procedure MovedTo(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure MaxSize(A1: Integer; A2: Integer);  { draft }
    procedure Hero(A1: Integer; A2: Byte);  { draft }
    procedure Leader(A1: Integer);  { draft }
    function Transporter(Player: Shortint): TAbstractUnit;
    procedure IndexOfTransporter(A1: Integer);  { draft }
    function UnitsInTransporter: Boolean;
    procedure UpdateVisibilityRanges(A1: Integer; A2: Integer);  { draft }
    procedure VisibilityRange;  { draft }
    procedure TrueVisionRange;  { draft }
    procedure TurnUnFogOff;  { draft }
    procedure UpdateExploration;  { draft }
    procedure UpdateUnfog;  { draft }
    procedure CanAddUnits(A1: Integer; A2: Integer);  { draft }
    procedure CanAddUnitSelection(A1: Integer; A2: Integer);  { draft }
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
    procedure GetCanJoinSelection(A1: Byte; A2: Integer);  { draft }
    function GetJoinSelection(Player: Shortint): Byte;
    function JoinAmount(Player: Shortint; Selection: Byte): Integer;
    procedure IncommingNegotiateRequest(A1: Integer);  { draft }
    procedure IncommingNegotiateOffer(A1: Integer);  { draft }
    procedure TriggerFireDamage;  { draft }
    procedure RetrieveStormDamageInfo(A1: Byte);  { draft }
    procedure IncommingStorm(A1: Byte; A2: Integer);  { draft }
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
    procedure Setup(A1: Integer; A2: Byte); virtual;  { +0C0 draft }
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
    procedure MoveTo(A1: Integer; A2: Integer); override;
    procedure PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer); override;
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc); override;
    procedure UpdateFlagID; override;
    procedure MoveFirst(A1: Integer; A2: Integer); override;
    function GetMoveSteps: Integer; override;
    procedure GetFogEnabled;  { draft }
    function VisibleForSeatedPlayer: Boolean;
    procedure ArmyUpdated(A1: Integer);  { draft }
    procedure UpdateUnitGFXResource;  { draft }
    procedure PlacePrivate(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure PlayMoveSFX;  { draft }
    procedure ShowEnchantments(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PlaceEx(A1: Byte; A2: Byte; A3: Integer; A4: Integer);  { draft }
  end;

  { TArmyHSList (instance size 20, VMT 5571352C) }
  TArmyHSList = class(TEChangeNotifyEventList)
  public
    procedure GetArmyHS(A1: Integer);  { draft }
  end;

  { TArmyEventLog (instance size 52, VMT 55713628) }
  TArmyEventLog = class(TEventLog)
  public
    F_ArmyEventLog_18: Integer;
    F_ArmyEventLog_1C: Integer;
    F_ArmyEventLog_20: Integer;
    F_ArmyEventLog_24: Integer;
    F_ArmyEventLog_28: Integer;
    F_ArmyEventLog_2C: Integer;
    F_ArmyEventLog_30: Byte;
    F_ArmyEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function GetLeftIcon: Integer; override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
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
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation(A1: Integer; A2: Integer); override;
    procedure SetArmyView;  { draft }
  end;

