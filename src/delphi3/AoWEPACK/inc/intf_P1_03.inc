{ Interface declaration run owned by P1. }
  { TRace: size $18; $08 race, $0C defaults, $10 player relations, $14 enabled. }
  TRace = class(TEObject)
  public
    FRace: Shortint;  { $08 }
    F_Race_09: array[0..2] of Byte;
    FDefaultRelations: TByteList;  { $0C, TStatus values }
    FPlayerRelations: TIntegerList;  { $10 }
    FEnabled: Boolean;  { $14 }
    F_Race_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetRelationValue(Race: Shortint): Integer;
    function GetRelation(Race: Shortint): TStatus;
    procedure SetPlayerRelationValue(Player: Shortint; Value: Integer);
    function GetPlayerRelationValue(Player: Shortint): Integer;
    function GetPlayerRelation(Player: Shortint): TStatus;
    procedure NewDay;
    function GetDefaultRaceRelation(Race: Shortint): TStatus;
    procedure ResetDefaultRaceRelations;
    procedure ResetPlayerRelations;
    procedure SetRace(Value: Shortint);
    procedure SetEnabled(Value: Boolean);
  end;

  { TRaceList (instance size 20, VMT 5570B974) }
  TRaceList = class(TEControlStyleNode)
  public
    FRelationOffset: Integer;  { $10 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetRace(Index: Integer): TRace;
    function GetEnabledRaces: Integer;
    function GetRandomRace: Shortint;
    procedure ResetPlayerRelations;
    procedure ResetDefaultRelations;
    procedure Update;
  end;

  { TDiplomaticRelationList: size $14; inherited TByteList, $10 default relation }
  TDiplomaticRelationList = class(TByteList)
  public
    constructor Create;
    function GetDiplomaticRelation(Index: Integer): TDiplomaticRelation;
    procedure SetDiplomaticRelation(Index: Integer; Value: TDiplomaticRelation);
  end;

  { TDiplomaticRelationHistoryItem: size $10; $08 day, $0C relation }
  TDiplomaticRelationHistoryItem = class(TEObject)
  public
    FDay: Integer; { $08 }
    FRelation: TDiplomaticRelation; { $0C }
    F_DiplomaticRelationHistoryItem_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TDiplomaticRelationHistoryList (instance size 12, VMT 5570BBE8) }
  TDiplomaticRelationHistoryList = class(TENode)
  public
    class function ClassID: Integer; override;
    function GetItems(Index: Integer): TDiplomaticRelationHistoryItem;
    function GetLastModifiedOnDay: Integer;
    function GetRelationOnDay(Day: Integer): TDiplomaticRelation;
    procedure Add(Relation: TDiplomaticRelation; Day: Integer);
  end;

  { TPlayerDiplomaticRelations: size $14; $08 player, $0C relations, $10 history }
  TPlayerDiplomaticRelations = class(TEObject)
  public
    FPlayer: TPlayer; { $08 }
    FRelations: TByteList; { $0C }
    FHistory: TENode; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetDiplomaticRelation(Player: Shortint): TDiplomaticRelation;
    procedure SetDiplomaticRelation(Player: Shortint; Value: TDiplomaticRelation);
    function GetHistory(Player: Shortint): TDiplomaticRelationHistoryList;
    procedure ValidateHistory;
  end;

  { TLeaderSetupControl: size $28; $08 references, $0C leader, $10 mode, $14 original leader, $18 items, $20 done event. VMT 5570BE8C. }
  TLeaderSetupControl = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FLeader: TLeader; { $0C }
    FMode: TLeaderSetupMode; { $10 }
    F_LeaderSetupControl_11: array[0..2] of Byte;
    FOriginalLeader: TLeader; { $14 }
    FItems: TIntegerList; { $18 }
    F_LeaderSetupControl_1C: array[0..3] of Byte;
    FOnDone: TNotifyEvent; { $20 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function Done: Boolean; virtual;
  end;

  { TTurnInfoItem: size $1C; $08 gold, $0C mana, $10 structures, $14 army strength, $18 heroes }
  TTurnInfoItem = class(TEObject)
  public
    FGold: Integer; { $08 }
    FMana: Integer; { $0C }
    FStructures: Integer; { $10 }
    FArmyStrength: Integer; { $14 }
    FHeroes: Byte; { $18 }
    F_TurnInfoItem_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetSuperiority: Integer;
  end;

  { TTurnInfo (instance size 12, VMT 5570C01C) }
  TTurnInfo = class(TENode)
  public
    function GetTurnInfo(Index: Integer): TTurnInfoItem;
  end;

  { TPlayerStatistics: size $14; $08 turn info, $0C units killed, $10 units lost }
  TPlayerStatistics = class(TEObject)
  public
    FTurnInfo: TTurnInfo; { $08 }
    FUnitsKilled: Integer; { $0C }
    FUnitsLost: Integer; { $10 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TIncomeSource (instance size 8, VMT 5570C1D8) }
  TIncomeSource = class(TEObject)
  public
    function Name: string; virtual; { $04C }
    function Income: Integer; virtual; { $050 }
    procedure GetLocation(var X, Y, L: Shortint); virtual; { $054 }
    procedure CenterToLocation; virtual; { $058 }
  end;

  { TIncomeSourceList (instance size 12, VMT 5570C2A8) }
  TIncomeSourceList = class(TENode)
  public
    function GetItems(Index: Integer): TIncomeSource;
  end;

  { TPBEMPlayerSettings: size $10; $08 status, $0C email game }
  TPBEMPlayerSettings = class(TEObject)
  public
    FStatus: TPBEMPlayerStatus; { $08 }
    F_PBEMPlayerSettings_09: array[0..2] of Byte;
    FEmailGame: TEmailGame; { $0C }
    { conflict: FGame: TEmailGame; }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetGame(Game: TEObject);
  end;

  { TPlayer: size $DC; $08 update count, $0C..$18 events, $1C structures,
    $20 victory locations, $28 armies, $34 messages, $38/$3C legacy relations,
    $40 diplomacy, $44 game over, $45 player status, $48 busy count, $50 morale, $58 leader setup,
    $60 statistics, $64 income sources, $68 known structures, $80 heroes,
    $84 groups, $88 AI control, $8C budget, $90 diplomatic actions, $94 attack players,
    $98/$9C seen days, $A0 PBEM, $A4 emerging hero, $A9 participating,
    $AC initial gold, $B0 base income, $B4/$B8 hero join days, $C8/$CC upkeep;
    $2C end turn, $2D..$2F view, $30 password, $5C turn number, $6C base hero level,
    $74 emerging hero ID, $78 emerge day, $7C highest hero level, $BC/$C0 settings/description }
  TPlayer = class(TEObject)
  public
    FUpdateCount: Integer; { $08 }
    FGemsChangedEvents: TEventList; { $0C }
    FIncomeChangedEvents: TEventList; { $10 }
    FUpkeepChangedEvents: TEventList; { $14 }
    FLogbookChangedEvents: TEventList; { $18 }
    FStructures: TPlayerStructureList; { $1C }
    FVictoryLocations: TPlayerStructureList; { $20 }
    FProductionControls: TProductionControlList;  { $24 }
    FArmies: TArmyList; { $28 }
    FSingleProcessCycle: Boolean; { $2C }
    { conflict: FEndTurn: Boolean; }
    FViewX: Byte; { $2D }
    FViewY: Byte; { $2E }
    FViewL: Byte; { $2F }
    FPassword: string; { $30 }
    FMessages: TStringList; { $34 }
    FLegacyRelations: TDiplomaticRelationList; { $38 }
    FLegacyNewRelations: TDiplomaticRelationList; { $3C }
    FDiplomaticRelations: TPlayerDiplomaticRelations; { $40 }
    FGameOverStatus: TGameOverStatus;  { $44 }
    FStatus: TPlayerStatus; { $45 }
    F_Player_46: array[0..1] of Byte;
    FBusyCount: Integer; { $48 }
    FName: string; { $4C }
    FMoraleValue: Shortint; { $50 }
    F_Player_51: array[0..2] of Byte;
    FMagicControl: TPlayerMagicControl;  { $54 }
    FLeaderSetup: TLeader; { $58 }
    FDay: Integer;  { $5C; 55785754 }
    { conflict: FTurnNumber: Integer; }
    FStatistics: TPlayerStatistics; { $60 }
    FIncomeSources: TIncomeSourceList; { $64 }
    FKnownStructures: TPlayerStructureList; { $68 }
    FBaseHeroJoinLevel: Integer; { $6C }
    FLastHeroJoinDay: Integer; { $70 }
    FEmergingHeroID: Integer; { $74 }
    { conflict: FHeroEmergeID: Integer; }
    FLastHeroEmergeDay: Integer; { $78 }
    FHighestHeroLevel: Integer; { $7C }
    FHeroes: THeroList; { $80 }
    FAIGroups: TAIGroupList; { $84 }
    FAIControl: TAIPlayerControl; { $88 }
    FAIBudget: TAIBudgetManager; { $8C }
    { conflict: FBudgetManager: TAIBudgetManager; }
    FDiplomaticActions: TDiplomaticActionList; { $90 }
    FAIValidAttackPlayers: TBitList; { $94 }
    FFirstDaySeen: TIntegerList; { $98 }
    FLastDaySeen: TIntegerList; { $9C }
    FPBEMSettings: TPBEMPlayerSettings; { $A0 }
    FHeroEmerging: Boolean; { $A4 }
    FPlayerRace: Shortint;  { $A5 }
    FPlayerIndex: Shortint; { $A6 }
    FPlayerType: TPlayerType;  { $A7 }
    FBehavior: TPlayerBehavior; { $A8 }
    { conflict: FConnectionType: TPlayerConnectionType; }
    FParticipating: Boolean; { $A9 }
    F_Player_AA: array[0..1] of Byte;
    FInitialGold: Integer; { $AC }
    { conflict: FGold: Integer; }
    FBaseIncome: Integer; { $B0 }
    FBaseHeroJoinDay: Integer; { $B4 }
    FHeroJoinDay: Integer; { $B8 }
    FSettings: string; { $BC }
    FDescription: string; { $C0 }
    FGems: Integer; { $C4 }
    { conflict: FGems: Integer; $C4, read at $557A7E18 }
    FArmyUpkeep: Integer; { $C8 }
    FMagicUpkeep: Integer; { $CC }
    FIncome: Integer;  { $D0 }
    FLeader: TLeader;  { $D4 }
    FEventLogbook: TEventLogbook;  { $D8 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetBusy: Boolean;
    function GetSuperiority: Integer;
    function GetUnitCount: Integer;
    procedure SetPlayerIndex(Value: Shortint);
    procedure SetGameOverStatus(Value: TGameOverStatus);
    function Surrender: Boolean;
    function Win: Boolean;
    function Validate(Errors: TStrings): Boolean;
    procedure LockBusy;
    procedure UnlockBusy;
    procedure LogbookChangedEvent(Sender: TObject);
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure ArmiesChanged(Sender: TObject);
    procedure SetGems(Value: Integer);
    procedure UpdateIncome;
    procedure RegisterIncomeSource(Source: TIncomeSource);
    procedure UnregisterIncomeSource(Source: TIncomeSource);
    function GetUpkeep: Integer;
    procedure SetArmyUpkeep(Value: Integer);
    procedure SetMagicUpkeep(Value: Integer);
    function GetName: string;
    function GetNameEx: string;
    procedure SetName(Value: string);
    function GetFace: TLibraryImage;
    function GetHeroCountMax: Integer;
    function GetIdealHeroJoinDay: Integer;
    function GetIdealHeroEmergeDay: Integer;
    procedure ResetBaseHeroJoinDay;
    procedure MakeHeroEmerge(Mode: THeroEmergeMode);
    procedure UpdateHeroJoin;
    function GetHeroJoinChance(Level: Integer): Integer;
    function GetHeroJoinLevelMax: Integer;
    procedure ValidateLeader;
    procedure SetLeader(Value: TLeader);
    procedure SetRace(Value: Shortint);
    procedure SetEndTurn(Value: Boolean);
    procedure UpdateLogbook;
    procedure UpdateTurnInfo;
    procedure UpdateAlliedPlayersSeen;
    procedure SetupAIValidAttackPlayers;
    function GetFirstDaySeen(Player: Shortint): Integer;
    function GetLastDaySeen(Player: Shortint): Integer;
    procedure PlayerSeen(Player: Shortint);
    procedure GetLeaderLocation(var X, Y, L: Shortint);
    function GetLocal: Boolean;
    procedure RegisterVictoryLocation(Structure: TPlayerStructure);
    procedure UnregisterVictoryLocation(Structure: TPlayerStructure);
    procedure CheckCaptureLocations;
    function CaptureLocationsLeft: Integer;
    function CreateDiplomaticAction(Action: TDiplomaticActionType; Target, Other: Shortint): TDiplomaticAction;
    function DiplomaticActionAleadySend(Action: TDiplomaticActionType; Target, Other: Shortint): Boolean;
    function ListDiplomaticActions(Player: Shortint; var Actions: TDiplomaticActionList): Integer;
    function ValidAttackRelation(Player, IndependentRelation: Shortint): Boolean;
    function ChangePlayerSettings(const Settings: string): Boolean;
  end;

  { TPlayerList: size $20; $10 active, $14 local, $18 human, $1C local human lists. VMT 5570C5E8. }
  TPlayerList = class(TEControlStyleNode)
  public
    FActivePlayers: TByteList; { $10 }
    F_PlayerList_14: Integer;
    FLocalPlayers: TByteList; { $18 }
    { conflict: FLocalPlayers: TByteList; $14 }
    { conflict: FHumanPlayers: TByteList; }
    { conflict: FActivePlayers: TIntegerList; }
    FLocalHumanPlayers: TByteList; { $1C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Assign(Source: Engine.TEObject; AEngine: Engine.TEngine); override;
    function GetDiplomaticRelationCount(Player: Shortint; Relations: TDiplomaticRelations): Integer;
    function GetDiplomaticRelation(Player, OtherPlayer: Shortint): TDiplomaticRelation;
    { conflict: function GetDiplomaticRelation(Source, Target: Shortint): TDiplomaticRelation; }
    procedure SetDiplomaticRelation(Player, OtherPlayer: Shortint; Relation: TDiplomaticRelation);
    function GetActivePlayers: Integer;
    procedure Update;
    procedure BeginUpdate;
    procedure EndUpdate;
    function GetPlayers(Index: Integer): TPlayer;
    function GetActivePlayersAllied: Boolean;
    function GetAverageHeroLevel: Integer;
    function GetAverageHeroCount: Integer;
    function GetMaxHeroCount: Integer;
    function GetNumberOfPlayers: Byte;
    function RaceToPlayer(Race: Shortint): Integer;
    procedure SetNumberOfPlayers(Value: Byte);
    procedure ValidateRaces(Races: TRaceList);
    function VerifyRaces(Races: TRaceList): Integer;
    function GetSuperiorPlayer: Shortint;
    function IndexOfPlayerType(PlayerType: TPlayerType): Integer;
  end;

  { TAoWNewHSMapSettings (instance size 32, VMT 5570C6E0) }
  TAoWNewHSMapSettings = class(TNewHSMapSettings)
  public
    procedure Create(A1: Byte);  { draft }
  end;

  { TAoWMapField (instance size 28, VMT 5570C764) }
  TAoWMapField = class(TMapField)
  public
    FFieldFlags: Integer;  { $18 }
    { conflict: FMapFlags: Word; }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure UpdateMapField; override;
    function GetExplored(A1: Integer): Boolean;
    procedure SetExplored(A1: Integer; A2: Integer);  { draft }
    procedure FogChanged;  { draft }
    procedure SetFogCount(A1: Byte);  { draft }
    function GetPlayer: Shortint;
    procedure GetScannerIcon;  { draft }
    procedure GetCombatTerrainTag;  { draft }
    procedure GetConcealmentActive;  { draft }
    function GetMagicShieldActive: Boolean;
    procedure GetProductionControl;  { draft }
    procedure GetAITarget(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetMoveAction(A1: Byte): TMoveAction;
    function GetIndependentRelation: Byte;
    procedure GetDefensePriority;  { draft }
    procedure GetDefenseRequirements(A1: Integer; A2: Integer);  { draft }
    procedure GetWallType;  { draft }
    function GetArmyHS: TArmyHS;
    procedure RestoreTerrain;  { draft }
  end;

  { TAoWMapLevel (instance size 128, VMT 5570C864) }
  TAoWMapLevel = class(TMapLevel)
  public
    F_AoWMapLevel_7C: array[0..3] of Byte;
    class function ClassID: Integer; override;
    function MapFieldClass: Engine.TEObjectClass; override;
    procedure FogArea(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UnFogArea(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure ResetFog;  { draft }
    procedure ResetUnFog;  { draft }
    procedure Reset;  { draft }
  end;

