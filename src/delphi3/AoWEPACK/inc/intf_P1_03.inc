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

  { TLeaderSetupControl (instance size 40, VMT 5570BE8C) }
  TLeaderSetupControl = class(TEObject)
  public
    F_LeaderSetupControl_08: Integer;
    F_LeaderSetupControl_0C: Integer;
    F_LeaderSetupControl_10: Byte;
    F_LeaderSetupControl_11: array[0..2] of Byte;
    F_LeaderSetupControl_14: Integer;
    F_LeaderSetupControl_18: Integer;
    F_LeaderSetupControl_1C: array[0..3] of Byte;
    F_LeaderSetupControl_20: Integer;
    F_LeaderSetupControl_24: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Done; virtual;  { +04C draft }
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
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetGame(Game: TEObject);
  end;

  { TPlayer: size $DC; $08 update count, $0C..$18 events, $1C structures,
    $20 victory locations, $28 armies, $34 messages, $38/$3C legacy relations,
    $40 diplomacy, $44 game over, $45 end turn, $48 busy count, $58 leader setup,
    $60 statistics, $64 income sources, $68 known structures, $80 heroes,
    $84 groups, $88 AI control, $8C budget, $90 diplomatic actions, $94 attack players,
    $98/$9C seen days, $A0 PBEM, $A4 emerging hero, $A9 participating,
    $AC initial gold, $B0 base income, $B4/$B8 hero join days, $C8/$CC upkeep }
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
    F_Player_2C: Byte;
    F_Player_2D: Byte;
    F_Player_2E: Byte;
    F_Player_2F: Byte;
    F_Player_30: Integer;
    FMessages: TStringList; { $34 }
    FLegacyRelations: TDiplomaticRelationList; { $38 }
    FLegacyNewRelations: TDiplomaticRelationList; { $3C }
    FDiplomaticRelations: TPlayerDiplomaticRelations; { $40 }
    FGameOverStatus: TGameOverStatus;  { $44 }
    FEndTurn: Boolean; { $45 }
    F_Player_46: array[0..1] of Byte;
    FBusyCount: Integer; { $48 }
    FName: string; { $4C }
    F_Player_50: Byte;
    F_Player_51: array[0..2] of Byte;
    FMagicControl: TPlayerMagicControl;  { $54 }
    FLeaderSetup: TLeader; { $58 }
    F_Player_5C: Integer;
    FStatistics: TPlayerStatistics; { $60 }
    FIncomeSources: TIncomeSourceList; { $64 }
    FKnownStructures: TPlayerStructureList; { $68 }
    F_Player_6C: Integer;
    FLastHeroJoinDay: Integer; { $70 }
    F_Player_74: Integer;
    FLastHeroEmergeDay: Integer; { $78 }
    F_Player_7C: Integer;
    FHeroes: THeroList; { $80 }
    FAIGroups: TAIGroupList; { $84 }
    FAIControl: TAIPlayerControl; { $88 }
    FAIBudget: TAIBudgetManager; { $8C }
    FDiplomaticActions: TDiplomaticActionList; { $90 }
    FAIValidAttackPlayers: TBitList; { $94 }
    FFirstDaySeen: TIntegerList; { $98 }
    FLastDaySeen: TIntegerList; { $9C }
    FPBEMSettings: TPBEMPlayerSettings; { $A0 }
    FHeroEmerging: Boolean; { $A4 }
    FPlayerRace: Shortint;  { $A5 }
    FPlayerIndex: Shortint; { $A6 }
    FPlayerType: TPlayerType;  { $A7 }
    F_Player_A8: Byte;
    FParticipating: Boolean; { $A9 }
    F_Player_AA: array[0..1] of Byte;
    FInitialGold: Integer; { $AC }
    FBaseIncome: Integer; { $B0 }
    FBaseHeroJoinDay: Integer; { $B4 }
    FHeroJoinDay: Integer; { $B8 }
    F_Player_BC: Integer;
    F_Player_C0: Integer;
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
    procedure MakeHeroEmerge(A1: Integer);  { draft }
    procedure UpdateHeroJoin;  { draft }
    procedure GetHeroJoinChance(A1: Integer);  { draft }
    procedure GetHeroJoinLevelMax(A1: Integer; A2: Integer);  { draft }
    procedure ValidateLeader;  { draft }
    procedure SetLeader(A1: Integer);  { draft }
    procedure SetRace(A1: Byte);  { draft }
    procedure SetEndTurn(A1: Byte);  { draft }
    procedure UpdateLogbook;  { draft }
    procedure UpdateTurnInfo;  { draft }
    procedure UpdateAlliedPlayersSeen;  { draft }
    procedure SetupAIValidAttackPlayers;  { draft }
    procedure GetFirstDaySeen(A1: Byte);  { draft }
    procedure GetLastDaySeen(A1: Byte);  { draft }
    procedure PlayerSeen(A1: Integer);  { draft }
    procedure GetLeaderLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetLocal: Boolean;
    procedure RegisterVictoryLocation;  { draft }
    procedure UnregisterVictoryLocation;  { draft }
    procedure CheckCaptureLocations;  { draft }
    procedure CaptureLocationsLeft;  { draft }
    function CreateDiplomaticAction(Action: TDiplomaticActionType; Target, Other: Shortint): TDiplomaticAction;
    procedure DiplomaticActionAleadySend(A1: Byte; A2: Byte; A3: Integer);  { draft }
    procedure ListDiplomaticActions(A1: Integer; A2: Integer);  { draft }
    procedure ValidAttackRelation(A1: Integer; A2: Integer);  { draft }
    procedure ChangePlayerSettings(A1: Integer);  { draft }
  end;

  { TPlayerList (instance size 32, VMT 5570C5E8) }
  TPlayerList = class(TEControlStyleNode)
  public
    F_PlayerList_10: Integer;
    F_PlayerList_14: Integer;
    F_PlayerList_18: Integer;
    F_PlayerList_1C: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Assign(Source: Engine.TEObject; AEngine: Engine.TEngine); override;
    procedure GetDiplomaticRelationCount(A1: Integer; A2: Byte);  { draft }
    function GetDiplomaticRelation(Player, OtherPlayer: Shortint): TDiplomaticRelation;
    { conflict: function GetDiplomaticRelation(Source, Target: Shortint): TDiplomaticRelation; }
    procedure SetDiplomaticRelation(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure GetActivePlayers(A1: Integer; A2: Integer);  { draft }
    procedure Update;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    function GetPlayers(Index: Integer): TPlayer;
    procedure GetActivePlayersAllied;  { draft }
    procedure GetAverageHeroLevel;  { draft }
    function GetAverageHeroCount: Integer;
    function GetMaxHeroCount: Integer;
    procedure GetNumberOfPlayers;  { draft }
    function RaceToPlayer(Race: Shortint): Integer;
    procedure SetNumberOfPlayers(A1: Integer);  { draft }
    procedure ValidateRaces(A1: Integer);  { draft }
    procedure VerifyRaces(A1: Integer; A2: Integer);  { draft }
    procedure GetSuperiorPlayer(A1: Integer; A2: Integer);  { draft }
    procedure IndexOfPlayerType(A1: Integer);  { draft }
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
    procedure GetIndependentRelation;  { draft }
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

