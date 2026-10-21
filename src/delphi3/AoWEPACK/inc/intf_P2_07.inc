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

  { TLeader (instance size 164, VMT 55712238): +9C FSpherePicksMax; +A0 FSpheres. }
  TLeader = class(THero)
  public
    FSpherePicksMax: Byte; { $9C }
    F_Leader_9D: array[0..2] of Byte;
    FSpheres: TByteList; { $A0 }
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
    function GetSpheres(Index: Integer): TMagicSphere;
    function GetSphereCount: Integer;
    procedure SetSpherePicksMax(Value: Byte);
    function CanAddSphere(Sphere: TMagicSphere): Boolean;
    function AddSphere(Sphere: TMagicSphere): Boolean;
    function DeleteSphereIndex(Index: Integer): Boolean;
    function DeleteSphere(Sphere: TMagicSphere): Boolean;
    procedure ClearSpheres;
  end;

  { THeroList (instance size 12, VMT 557124C8) }
  THeroList = class(TEReferenceNode)
  public
    function FindHero(ID: Integer): THero;
    function GetHero(Index: Integer): THero;
  end;

  { THeroControl (instance size 24, VMT 557125BC): +08 FOnChanged; +0C FUpdateCount;
    +10 FOnHeroChanged; +14 FHeroes. }
  THeroControl = class(TEObject)
  public
    FOnChanged: TEventList; { $08 }
    FUpdateCount: Integer; { $0C }
    FOnHeroChanged: TEventList; { $10 }
    FHeroes: THeroList; { $14 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure Changed;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure UpdateLibraryHeroes;
    function GetHero(Index: Integer): THero;
    function GetCount: Integer;
    function FindID(ID: Integer): THero;
    function IndexOf(Hero: THero): Integer;
    function IndexOfLibraryEx(const LibraryName: string; LibraryID: Integer): Integer;
    procedure ValidateLibraryHeroes;
    procedure Activate;
    procedure Deactivate;
    function RegisterHero(Hero: THero): Boolean;
    procedure UnRegisterHero(Hero: THero);
    procedure HeroChanged(Hero: THero);
    function GetAverageFreeHeroLevel: Integer;
    function GetMinFreeHeroLevel: Integer;
    procedure ListDeadHeroes(List: THeroList);
  end;

  { THeroLibrary (instance size 20, VMT 5571267C): +0C FLibraryName; +10 FNextLibraryID. }
  THeroLibrary = class(THeroList)
  public
    FLibraryName: string; { $0C }
    FNextLibraryID: Integer; { $10 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    function CreateUniqueLibraryID: Integer;
    function CreateHero: THero;
    function GetName: string;
    function FindLibraryID(ID: Integer): THero;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
  end;

  { THeroLibraryManager (instance size 16, VMT 55712788): +08 FSystemLibrary; +0C FLibraries. }
  THeroLibraryManager = class(TEObject)
  public
    FSystemLibrary: THeroLibrary; { $08 }
    FLibraries: TENode; { $0C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLibrary(Index: Integer): THeroLibrary;
    function GetCount: Integer;
    procedure ReadUserLibraries;
    procedure WriteUserLibraries;
    function IndexOfLibraryName(const Name: string): Integer;
    function IndexOfLibrary(Lib: THeroLibrary): Integer;
    function FindHero(const LibraryName: string; LibraryID: Integer): THero;
    function CreateLibrary(const Name: string): THeroLibrary;
    procedure DeleteLibrary(Index: Integer);
  end;

  { THeroResource (instance size 52, VMT 55712854): +20 FRace; +21 FHeroType;
    +1C FName; +22 FAlignment; +23 FHidden; +24..29 base statistics; +2C FAbilities; +30 FFaceIndex. }
  THeroResource = class(TAbstractUnitResource)
  public
    FName: string; { $1C }
    FRace: Shortint;  { $20 }
    FHeroType: THeroType;  { $21 }
    FAlignment: TAlignment;  { $22 }
    FHidden: Boolean; { $23 }
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
    function HeroResourceIndex: Integer;
    function UsedSkillPoints: Integer;
  end;

  { THeroResourceList (instance size 20, VMT 5571294C) }
  THeroResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetHeroResource(Index: Integer): THeroResource;
    function CreateHeroResourceStrings(HeroTypes: THeroTypes): TStringList;
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

  { TArmyID (instance size 20, VMT 55712FF4): +08 FUnitIDs; +0C FPlayer; +10 FX, FY, FL. }
  TArmyID = class(TEObject)
  public
    FUnitIDs: TIntegerList; { $08 }
    FPlayer: Shortint; { $0C }
    F_ArmyID_0D: array[0..2] of Byte;
    FX, FY, FL: Shortint; { $10..12 }
    F_ArmyID_13: Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function Valid: Boolean;
    function RetrieveArmy(var ArmyHS: TArmyHS; var Selection: Byte): Boolean;
  end;

  { TArmy (instance size 44, VMT 557130EC): +10 FStatus; +11 FMode; +12 FPlayer;
    +13..15 location; +16 FIndependentRelation; +17 FUnfogRange; +18 FUpkeep; +1C FOnUpdate;
    +24 FOldAIBehavior; +25..27 destination; +28 FUserMode;
    +29 FVisibilityRanges; +2A FConcealedUnits. }
  TArmy = class(TUnitList)
  public
    FStatus: TArmyStatus; { $10 }
    FMode: TArmyMode; { $11 }
    FPlayer: Shortint;  { $12 }
    FX: Shortint; { $13 }
    FY: Shortint; { $14 }
    FL: Shortint; { $15 }
    FIndependentRelation: Shortint; { $16 }
    FUnfogRange: Byte; { $17 }
    FUpkeep: Byte; { $18 }
    F_Army_19: array[0..2] of Byte;
    FOnUpdate: TNotifyEvent; { $1C }
    FOldAIBehavior: TGroupBehavior; { $24 }
    FDestinationX: Shortint; { $25 }
    FDestinationY: Shortint; { $26 }
    FDestinationL: Shortint; { $27 }
    FUserMode: TArmyUserMode; { $28; 5578E986 }
    FVisibilityRanges: Byte; { $29 }
    FConcealedUnits: Byte; { $2A }
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
    function GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean; virtual; { +0B8 }
    function GetConcealedForPlayer(Player: Shortint): Boolean; virtual; { +0BC }
    procedure Kill(Selection: Byte);
    function GetStrengthEx(Selection: Byte; DamageType: TDamageType): Integer;
    function GetStrengthMaxEx(Selection: Byte; DamageTypes: TDamageTypes): Integer;
    procedure ReturnBattleFieldInfo(var Info: TBattleFieldInfo);
    function HealUnits(Selection: Byte): Boolean;
    function CreateGroupID(Selection: Byte): Integer;
    function GetGroup(Selection: Byte): TAIGroup;
    procedure SetGroup(Selection: Byte; Group: TAIGroup);
    function GetGroupSelection(GroupID: Integer): Byte;
    function GetBehavior(Selection: Byte): TGroupBehavior;
    procedure SetBehavior(Selection: Byte; Behavior: TGroupBehavior);
    { conflict: procedure SetBehavior(Player: Shortint; Behavior: TGroupBehavior); }
    function GetOldAIBehavior: TGroupBehavior;
    procedure InitializeGroupBehavior;
    procedure UpdateGroupBehavior;
    function CreateID(Selection: Byte): TArmyID;
    function GetArmyHS: TArmyHS;
    procedure AssignSettings(Army: TArmy);
    procedure SetFullyConcealed(Value: Boolean);
    function GetFullyConcealed: Boolean;
    procedure UpdateConcealment;
    procedure SetXYL(X, Y, L: Shortint);
    function GetRace(Selection: Byte): Integer;
    function GetUpkeep: Byte;
    procedure ResetDestinationPos;
    procedure SetDestinationPos(X, Y, L: Shortint);
    function ConcealedUnitsCount: Integer;
    procedure UpdateConcealedUnits;
    procedure UpdateUpkeep;
    procedure ValidateTerrainEx(TerrainType, OverlayType, Player: Shortint);
    procedure ValidateTerrain(TerrainType, OverlayType: Shortint);
    procedure Validate;
    procedure UpdateFormation;
    procedure Update;
    procedure TriggerOnUpdateEvent;
    procedure Activate;
    procedure Deactivate;
    function ValidateSelection(Selection: Byte): Byte;
    function SelectionCount(Selection: Byte): Integer;
    function ValidateMoveSelection(Selection: Byte): Byte;
    procedure Select;
    procedure Unselect;
    function GetUnitConcealed(Index: Integer): Boolean;
    function GetUnitsConcealedForPlayer(Selection: Byte; Player: Shortint): Boolean;
    procedure SetPlayer(Player: Shortint);
    function ImmunityTypes(Selection: Byte): TDamageTypes;
    function ObtainValue(Selection: Byte): Integer;
    function MovePoints(Selection: Byte): Shortint;
    function Moves(Selection: Byte): Shortint;
    function MoveTypes(Selection: Byte): TMoveTypes;
    function GetPartyMoves(Selection: Byte): TMoveTypes;
    function MoveOnMovePoints(Selection: Byte; TerrainType, OverlayType: Shortint): Integer;
    procedure CreateMovePointTable(Selection: Byte; var Table);
    function ValidTerrainEx(Selection: Byte; TerrainType, OverlayType: Shortint): Boolean;
    function ValidTerrain(TerrainType, OverlayType: Shortint): Boolean;
    function CanPlace(X, Y, L: Shortint): Boolean;
    procedure MovedTo(OldField, NewField: TMapField; MaxCost: Integer);
    function MaxSize: Integer;
    function Hero(Selection: Byte; Types: THeroTypes): THero;
    function Leader(Selection: Byte): TLeader;
    function Transporter(Selection: Byte): TAbstractUnit;
    function IndexOfTransporter(Selection: Byte): Integer;
    function UnitsInTransporter: Byte;
    procedure UpdateVisibilityRanges;
    function VisibilityRange: Byte;
    function TrueVisionRange: Byte;
    procedure TurnUnFogOff;
    procedure UpdateExploration;
    procedure UpdateUnfog;
    function CanAddUnits(Units: TUnitList): TAddUnitsResult;
    function CanAddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
    function AddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
    function SelectionUnit(Selection: Byte; Index: Integer): TAbstractUnit;
    procedure MakeIndependent(Selection: Byte; var Armies: TArmyHSList);
    procedure UpdateIndependentRelation;
    procedure Desert(Selection: Byte);
    function GetPartyStatus(Selection: Byte): TPartyStatus;
    procedure UpdateDesertion;
    function ValidateCrusaders: Boolean;
    procedure NewTurn(Player: Shortint);
    procedure NewTurnDone(Player: Shortint);
    procedure NewDay;
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

  { TArmyView (instance size 96, VMT 55713210): +2C FUnitConcealment;
    +3C FConcealedForPlayers; +40 FMoraleValues. }
  TArmyView = class(TArmy)
  public
    FUnitConcealment: array[0..7] of Word; { $2C }
    FConcealedForPlayers: Word; { $3C }
    F_ArmyView_3E: array[0..1] of Byte;
    FMoraleValues: array[0..7] of Integer; { $40 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetLocation(var Xhx, Yhx, Lhx: Shortint); override;
    function GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean; override;
    function GetConcealedForPlayer(Player: Shortint): Boolean; override;
    procedure Setup(Army: TArmy; Selection: Byte); virtual;  { +0C0 }
    procedure SetConcealedForPlayer(Player: Shortint; Value: Boolean);
    procedure SetUnitConcealedForPlayer(Index: Integer; Player: Shortint; Value: Boolean);
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
    function MoveTo(Field: TMapField; MoveCost: Integer): Boolean; override;
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
    function PlaceEx(X, Y, L: Shortint; Mode: TArmyPlaceMode): Boolean;
  end;

  { TArmyHSList (instance size 20, VMT 5571352C) }
  TArmyHSList = class(TEChangeNotifyEventList)
  public
    function GetArmyHS(Index: Integer): TArmyHS;
  end;

  { TArmyEventLog (instance size 52, VMT 55713628): +18 FArmyView; +1C FArmyText;
    +20 FArmyMessages; +24 FArmyIcon; +28 FDamageValues; +2C FDamageTypes; +30 FGameOver. }
  TArmyEventLog = class(TEventLog)
  public
    FArmyView: TArmyView; { $18 }
    FArmyText: string; { $1C }
    FArmyMessages: TStrings; { $20 }
    FArmyIcon: Integer; { $24 }
    FDamageValues: TByteList; { $28 }
    FDamageTypes: TByteList; { $2C }
    FGameOver: Boolean; { $30 }
    F_ArmyEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function GetLeftIcon: Integer; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
    procedure SetArmyView(Value: TArmyView);
    function LeaderKilled: Boolean;
    function PartyDestroyed: Boolean;
    procedure ValidateGameOver;
  end;

  { TArmyInfoEventLog (instance size 52, VMT 55713724): +18 FArmyView; +1C FSelection;
    +20 FMessages; +24 FTitle; +28 FText; +2C FDescription; +30 FTriggers. }
  TArmyInfoEventLog = class(TEventLog)
  public
    FArmyView: TArmyView; { $18 }
    FSelection: Byte; { $1C }
    F_ArmyInfoEventLog_1D: array[0..2] of Byte;
    FMessages: TStrings; { $20 }
    FTitle: string; { $24 }
    FText: string; { $28 }
    FDescription: string; { $2C }
    FTriggers: TExecuteTriggers; { $30 }
    F_ArmyInfoEventLog_31: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
    procedure ViewLocation; override;
    procedure SetArmyView(Value: TArmyView);
  end;

