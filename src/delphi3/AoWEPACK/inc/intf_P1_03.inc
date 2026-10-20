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

  { TDiplomaticRelationList (instance size 20, VMT 5570BA68) }
  TDiplomaticRelationList = class(TByteList)
  public
    procedure Create(A1: Byte);  { draft }
    procedure GetDiplomaticRelation(A1: Integer);  { draft }
    procedure SetDiplomaticRelation;  { draft }
  end;

  { TDiplomaticRelationHistoryItem (instance size 16, VMT 5570BB04) }
  TDiplomaticRelationHistoryItem = class(TEObject)
  public
    F_DiplomaticRelationHistoryItem_08: Integer;
    F_DiplomaticRelationHistoryItem_0C: Byte;
    F_DiplomaticRelationHistoryItem_0D: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TDiplomaticRelationHistoryList (instance size 12, VMT 5570BBE8) }
  TDiplomaticRelationHistoryList = class(TENode)
  public
    class function ClassID: Integer; override;
    procedure GetItems(A1: Integer);  { draft }
    procedure GetLastModifiedOnDay;  { draft }
    procedure GetRelationOnDay(A1: Integer);  { draft }
    procedure Add(A1: Integer; A2: Integer);  { draft }
  end;

  { TPlayerDiplomaticRelations (instance size 20, VMT 5570BD08) }
  TPlayerDiplomaticRelations = class(TEObject)
  public
    F_PlayerDiplomaticRelations_08: Integer;
    F_PlayerDiplomaticRelations_0C: Integer;
    F_PlayerDiplomaticRelations_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure GetDiplomaticRelation(A1: Byte);  { draft }
    procedure SetDiplomaticRelation(A1: Integer; A2: Integer);  { draft }
    procedure GetHistory(A1: Byte);  { draft }
    procedure ValidateHistory;  { draft }
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

  { TTurnInfoItem (instance size 28, VMT 5570BF5C) }
  TTurnInfoItem = class(TEObject)
  public
    F_TurnInfoItem_08: Integer;
    F_TurnInfoItem_0C: Integer;
    F_TurnInfoItem_10: Integer;
    F_TurnInfoItem_14: Integer;
    F_TurnInfoItem_18: Byte;
    F_TurnInfoItem_19: array[0..2] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure GetSuperiority;  { draft }
  end;

  { TTurnInfo (instance size 12, VMT 5570C01C) }
  TTurnInfo = class(TENode)
  public
    procedure GetTurnInfo(A1: Integer);  { draft }
  end;

  { TPlayerStatistics (instance size 20, VMT 5570C110) }
  TPlayerStatistics = class(TEObject)
  public
    F_PlayerStatistics_08: Integer;
    F_PlayerStatistics_0C: Integer;
    F_PlayerStatistics_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TIncomeSource (instance size 8, VMT 5570C1D8) }
  TIncomeSource = class(TEObject)
  public
    procedure Name(A1: Integer); virtual;  { +04C draft }
    procedure Income; virtual;  { +050 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +054 draft }
    procedure CenterToLocation(A1: Integer; A2: Integer); virtual;  { +058 draft }
  end;

  { TIncomeSourceList (instance size 12, VMT 5570C2A8) }
  TIncomeSourceList = class(TENode)
  public
    procedure GetItems(A1: Integer);  { draft }
  end;

  { TPBEMPlayerSettings (instance size 16, VMT 5570C400) }
  TPBEMPlayerSettings = class(TEObject)
  public
    F_PBEMPlayerSettings_08: Byte;
    F_PBEMPlayerSettings_09: array[0..2] of Byte;
    F_PBEMPlayerSettings_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetGame;  { draft }
  end;

  { TPlayer (instance size 220, VMT 5570C508) }
  TPlayer = class(TEObject)
  public
    F_Player_08: Integer;
    F_Player_0C: Integer;
    F_Player_10: Integer;
    F_Player_14: Integer;
    F_Player_18: Integer;
    F_Player_1C: Integer;
    F_Player_20: Integer;
    F_Player_24: Integer;
    F_Player_28: Integer;
    F_Player_2C: Byte;
    F_Player_2D: Byte;
    F_Player_2E: Byte;
    F_Player_2F: Byte;
    F_Player_30: Integer;
    F_Player_34: Integer;
    F_Player_38: Integer;
    F_Player_3C: Integer;
    F_Player_40: Integer;
    F_Player_44: Byte;
    F_Player_45: Byte;
    F_Player_46: array[0..1] of Byte;
    F_Player_48: Integer;
    F_Player_4C: Integer;
    F_Player_50: Byte;
    F_Player_51: array[0..2] of Byte;
    F_Player_54: Integer;
    F_Player_58: Integer;
    F_Player_5C: Integer;
    F_Player_60: Integer;
    F_Player_64: Integer;
    F_Player_68: Integer;
    F_Player_6C: Integer;
    F_Player_70: Integer;
    F_Player_74: Integer;
    F_Player_78: Integer;
    F_Player_7C: Integer;
    F_Player_80: Integer;
    F_Player_84: Integer;
    F_Player_88: Integer;
    F_Player_8C: Integer;
    F_Player_90: Integer;
    F_Player_94: Integer;
    F_Player_98: Integer;
    F_Player_9C: Integer;
    F_Player_A0: Integer;
    F_Player_A4: Byte;
    FPlayerRace: Shortint;  { $A5 }
    F_Player_A6: Byte;
    FPlayerType: TPlayerType;  { $A7 }
    F_Player_A8: Byte;
    F_Player_A9: Byte;
    F_Player_AA: array[0..1] of Byte;
    F_Player_AC: Integer;
    F_Player_B0: Integer;
    F_Player_B4: Integer;
    F_Player_B8: Integer;
    F_Player_BC: Integer;
    F_Player_C0: Integer;
    F_Player_C4: Integer;
    F_Player_C8: Integer;
    F_Player_CC: Integer;
    F_Player_D0: Integer;
    F_Player_D4: Integer;
    FEventLogbook: TEventLogbook;  { $D8 }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetBusy: Boolean;
    procedure GetSuperiority;  { draft }
    procedure GetUnitCount;  { draft }
    procedure SetPlayerIndex(A1: Byte);  { draft }
    procedure SetGameOverStatus(A1: Byte);  { draft }
    procedure Surrender;  { draft }
    procedure Win;  { draft }
    procedure Validate(A1: Integer);  { draft }
    procedure LockBusy;  { draft }
    procedure UnlockBusy;  { draft }
    procedure LogbookChangedEvent;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure ArmiesChanged;  { draft }
    procedure SetGems(A1: Integer);  { draft }
    procedure UpdateIncome(A1: Integer; A2: Integer);  { draft }
    procedure RegisterIncomeSource(A1: Integer);  { draft }
    procedure UnregisterIncomeSource(A1: Integer);  { draft }
    procedure GetUpkeep;  { draft }
    procedure SetArmyUpkeep(A1: Integer);  { draft }
    procedure SetMagicUpkeep(A1: Integer);  { draft }
    procedure GetName(A1: Integer);  { draft }
    procedure GetNameEx(A1: Integer);  { draft }
    procedure SetName(A1: Integer; A2: Integer);  { draft }
    procedure GetFace;  { draft }
    procedure GetHeroCountMax;  { draft }
    procedure GetIdealHeroJoinDay;  { draft }
    procedure GetIdealHeroEmergeDay;  { draft }
    procedure ResetBaseHeroJoinDay;  { draft }
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
    procedure GetLocal;  { draft }
    procedure RegisterVictoryLocation;  { draft }
    procedure UnregisterVictoryLocation;  { draft }
    procedure CheckCaptureLocations;  { draft }
    procedure CaptureLocationsLeft;  { draft }
    procedure CreateDiplomaticAction(A1: Byte; A2: Integer; A3: Integer);  { draft }
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
    procedure GetDiplomaticRelation(A1: Byte; A2: Integer);  { draft }
    procedure SetDiplomaticRelation(A1: Integer; A2: Byte; A3: Integer);  { draft }
    procedure GetActivePlayers(A1: Integer; A2: Integer);  { draft }
    procedure Update;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    function GetPlayers(Index: Integer): TPlayer;
    procedure GetActivePlayersAllied;  { draft }
    procedure GetAverageHeroLevel;  { draft }
    procedure GetAverageHeroCount;  { draft }
    procedure GetMaxHeroCount;  { draft }
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
    F_AoWMapField_18: Word;
    F_AoWMapField_1A: Byte;
    F_AoWMapField_1B: Byte;
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
    procedure GetMoveAction(A1: Byte);  { draft }
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

