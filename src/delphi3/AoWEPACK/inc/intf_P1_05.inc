{ Interface declaration run owned by P1. }
  { TTargetSelectionControl (instance size 92, VMT 5570E03C) }
  TTargetSelectionControl = class(TObject)
  public
    FImageLibrary: TCustomImageLibrary; { $04 }
    FHNs: TShortIntList; { $08 }
    FStatus: TTargetSelectionStatus; { $0C }
    FTargetMode: TTargetSelectionMode; { $0D }
    F_TargetSelectionControl_0E: array[0..1] of Byte;
    FOnShow: TShowTargetSelectionEvent; { $10 }
    FOnValidateTarget: TValidateTargetEvent; { $18 }
    FRange: Integer; { $20 }
    FSourceX: Integer; { $24 }
    FSourceY: Integer; { $28 }
    FSourceL: Integer; { $2C }
    FSource: TObject; { $30 }
    FOnChange: TEventList; { $34 }
    FChange: TTargetSelectionChange; { $38 }
    FTargetX: Shortint; { $39 }
    FTargetY: Shortint; { $3A }
    FTargetL: Shortint; { $3B }
    FText: TStrings; { $3C }
    FTitle: string; { $40 }
    FCancelText: string; { $44 }
    F_TargetSelectionControl_48: Integer;
    F_TargetSelectionControl_4C: array[0..3] of Byte;
    FSourceImage: TLibraryImage; { $50 }
    FValidTargetImage: TLibraryImage; { $54 }
    FInvalidTargetImage: TLibraryImage; { $58 }
    destructor Destroy; override;
    constructor Create;
    procedure TriggerOnChangeEvent(Change: TTargetSelectionChange);
    procedure DeselectHS(Sender: TObject);
    procedure MouseDownEvent(Sender: TObject);
    function ValidTarget(X, Y, L: Shortint): Boolean;
    procedure NewFrameEvent(Sender: TObject);
    procedure MouseMoveEvent(Sender: TObject);
    procedure ShowSelection(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
    procedure Initialize(A1: TObject);
    procedure Activate;
    procedure Deactivate;
    procedure UnitChanged(AUnit: TAbstractUnit);
    { conflict: procedure UnitChanged(Sender: TObject); }
  end;

  { TAoWHSMapKeyboard (instance size 20, VMT 5570E11C) }
  TAoWHSMapKeyboard = class(TEObject)
  public
    F_AoWHSMapKeyboard_08: Integer;
    F_AoWHSMapKeyboard_0C: Byte;
    F_AoWHSMapKeyboard_0D: array[0..2] of Byte;
    F_AoWHSMapKeyboard_10: Integer;
    procedure KeyDown(A1: Integer; A2: Byte); virtual;  { +04C draft }
    procedure Lock;  { draft }
    procedure Unlock;  { draft }
    procedure RunDefaultTest;  { draft }
  end;

  { TAbstractAoWHSMapMouse (instance size 80, VMT 5570E22C) }
  TAbstractAoWHSMapMouse = class(THSMapMouse)
  public
    FSelectionRectangle: TRect; { $3C..$48; 55792672 }
    FRectangleSelectEvents: TEventList; { $4C; 55774A94 }
    destructor Destroy; override;
    procedure Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Move(Shift: Classes.TShiftState; X, Y: Integer); override;
    constructor Create;
    procedure ResetRectangleSelection;  { draft }
    procedure GetSelectingRectangle;  { draft }
    procedure StartRectangleSelection(A1: Integer; A2: Integer);  { draft }
    procedure UpdateRectangleSelection(A1: Integer; A2: Integer);  { draft }
    procedure StopRectangleSelection(A1: Integer; A2: Integer);  { draft }
  end;

  { TAoWHSMapMouse: size $50; no additional fields. VMT 5570E2DC. }
  TAoWHSMapMouse = class(TAbstractAoWHSMapMouse)
  public
    function GetCursor: Integer; override;
    procedure Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure Move(Shift: Classes.TShiftState; X, Y: Integer); override;
    procedure DblClick; override;
  end;

  { TAbstractAoWHSMap (instance size 216, VMT 5570E37C) }
  TAbstractAoWHSMap = class(THSMap)
  public
    FCurrentPlayer: Shortint;  { $A4 }
    FSeatedPlayer: Shortint;  { $A5 }
    FReservedA6: array[0..1] of Byte;
    F_AbstractAoWHSMap_A8: Integer;
    F_AbstractAoWHSMap_AC: Integer;
    F_AbstractAoWHSMap_B0: Byte;
    F_AbstractAoWHSMap_B1: array[0..2] of Byte;
    F_AbstractAoWHSMap_B4: Integer;
    F_AbstractAoWHSMap_B8: Integer;
    F_AbstractAoWHSMap_BC: Integer;
    F_AbstractAoWHSMap_C0: Integer;
    F_AbstractAoWHSMap_C4: Integer;
    FFogEnabled: Byte; { $C8 }
    FExplorationEnabled: Boolean; { $C9 }
    F_AbstractAoWHSMap_CA: Byte;
    F_AbstractAoWHSMap_CB: array[0..0] of Byte;
    F_AbstractAoWHSMap_CC: Integer;
    F_AbstractAoWHSMap_D0: Integer;
    F_AbstractAoWHSMap_D4: Byte;
    F_AbstractAoWHSMap_D5: Byte;
    F_AbstractAoWHSMap_D6: Byte;
    F_AbstractAoWHSMap_D7: array[0..0] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateMouse: HSEngine.THSMapMouse; override;
    procedure TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint); override;
    procedure UpdateStaticScene; override;
    procedure UpdateDynamicScene; override;
    procedure NewFrame; override;
    procedure ShowBackHexagonSelector(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0EC draft }
    procedure ShowFrontHexagonSelector(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0F0 draft }
    procedure UpdateHexagonSelector; virtual;  { +0F4 draft }
    procedure SetSeatedPlayer(A1: Shortint); virtual; { $F8 }
    procedure SetCurrentPlayer(A1: Shortint); virtual; { $FC }
    procedure SetFogEnabled(A1: Byte); virtual;  { +100 draft }
    procedure SetExplorationEnabled(A1: Byte); virtual;  { +104 draft }
    procedure DropHeroItem(Hero: THero; Item: TItem); virtual; { $108 }
    function GetHeroItemsOnGround(Hero: THero): TItemList; virtual; { $10C }
    procedure ShowMessage(const A1: string); virtual;
    procedure ShowWarning(const Text: string); virtual;
    procedure PlayCenterAnimation(X, Y, L: Shortint);
    procedure LockMapChangedEvent;  { draft }
    procedure UnlockMapChangedEvent;  { draft }
    procedure MapChanged(A1: Integer);  { draft }
    procedure MapChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure InvalidateMap;  { draft }
    procedure TriggerMapChangedEvent(A1: Integer; A2: Integer);  { draft }
    procedure LockScannerIconsChangedEvent;  { draft }
    procedure UnlockScannerIconsChangedEvent;  { draft }
    procedure ScannerIconsChanged(A1: Integer; A2: Integer);  { draft }
    procedure ScannerIconsChangedRad(Xhx, Yhx, Lhx, Radius: Integer);
    procedure InvalidateScannerIcons;  { draft }
    procedure TriggerScannerIconsChangedEvent(A1: Integer; A2: Integer);  { draft }
    procedure UpdateShowMessage;  { draft }
    function FogArea(X, Y, Level: Integer; Range: Integer): Boolean;
    function UnFogArea(X, Y, Level: Integer; Range: Integer): Boolean;
    function ExploreArea(X, Y, Level: Integer; Player: Shortint; Range: Integer): Boolean;
    procedure UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure DrawGrid(A1: Integer);  { draft }
    procedure DrawFog(A1: Integer);  { draft }
    procedure ShowHexagonSelector;  { draft }
    procedure HideHexagonSelector;  { draft }
    procedure UpdateFPS(A1: Integer);  { draft }
    procedure DrawSelectionRect(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAbstractAoWCombatMap (instance size 224, VMT 5570E548) }
  TAbstractAoWCombatMap = class(TAbstractAoWHSMap)
  public
    F_AbstractAoWCombatMap_D8: Integer;
    F_AbstractAoWCombatMap_DC: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

  { TTutorialControl (instance size 12, VMT 5570E6E4) }
  TTutorialControl = class(TEObject)
  public
    F_TutorialControl_08: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure ShowMessage(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

  { TStartupSongList: instance size $10; inherited $08 Songs, $0C SongNames. VMT 5570E7AC. }
  TStartupSongList = class(TSonglist)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure OriginalSongsChanged(Sender: TObject);
  end;

  { TAoWHSMap: size $41C; $E4 map name, $F8 heroes, $139 game mode, $13A stream mode,
    $148 fixed leaders, $14B allied victory, $158 day limit, $16C turn order,
    $19C/$1A0 day/turn events, $1D8 event-log locks, $1E8 diplomacy events,
    $22C initial seed, $230 random seed, $238 debug save, $240 communicator,
    $24C..$417 token log Text, $418 logging enabled. VMT 5570E874. }
  TAoWHSMap = class(TAbstractAoWHSMap)
  public
    FSelectedArmy: TSelectedArmy; { $D8 }
    F_AoWHSMap_DC: Byte;
    F_AoWHSMap_DD: array[0..2] of Byte;
    FTargetSelection: TTargetSelectionControl; { $E0 }
    FMapName: string; { $E4 }
    FAuthor: string; { $E8 }
    FSphereCount: Integer; { $EC }
    FDescription: TStringList; { $F0 }
    FItemControl: TItemControl; { $F4 }
    FHeroControl: THeroControl; { $F8 }
    FUnitControl: TUnitControl; { $FC }
    FStructureControl: TStructureControl; { $100; 5575F6CF }
    FIndependentAIMode: TIndependentAIMode; { $104 }
    F_AoWHSMap_105: array[0..2] of Byte;
    FObjectives: TStringList; { $108 }
    FHeroCountMax: Shortint; { $10C }
    F_AoWHSMap_10D: array[0..2] of Byte;
    FStartupSongs: TStartupSongList; { $110 }
    FGameSongs: TSonglist; { $114 }
    FGameStatus: TGameStatus; { $118 }
    FGameResult: TGameResult; { $119 }
    FGameType: TGameType; { $11A }
    F_AoWHSMap_11B: array[0..0] of Byte;
    FCombatMap: TAbstractAoWCombatMap; { $11C }
    FCombat: TCombat; { $120 }
    FTutorialControl: TTutorialControl; { $124 }
    FAIExecuter: TAIExecuter; { $128 }
    FAIPlayerActionManager: TAIPlayerActionManager; { $12C }
    FAIGroupManager: TAIGroupManager; { $130 }
    FKeyboard: TAoWHSMapKeyboard; { $134; 5576374C }
    F_AoWHSMap_138: Byte;
    FRequestCombatType: Boolean; { $139 }
    { conflict: FGameMode: Byte; }
    { conflict: FTacticalCombatEnabled: Boolean; }
    FConnectionType: TPlayerConnectionType; { $13A }
    { conflict: FStreamMode: Byte; }
    { conflict: FTacticalCombatAvailability: TTacticalCombatAvailability; }
    F_AoWHSMap_13B: array[0..0] of Byte;
    FTextControl: TTextControl; { $13C }
    FPlayers: TPlayerList;  { $140 }
    FRaces: TRaceList;  { $144 }
    FFixedLeaders: Boolean; { $148 }
    FLeadersFixed: Boolean;  { $149; 55786C99 }
    F_AoWHSMap_14A: Byte;
    FAlliedVictory: Boolean; { $14B }
    F_AoWHSMap_14C: Byte;
    FVictoryCondition: TVictoryCondition; { $14D }
    F_AoWHSMap_14E: array[0..1] of Byte;
    FVictoryMana: Integer; { $150 }
    FVictoryGold: Integer; { $154 }
    FDayLimit: Integer; { $158 }
    F_AoWHSMap_15C: Integer;
    F_AoWHSMap_160: Integer;
    F_AoWHSMap_164: Integer;
    FCampaignMapIndex: Integer; { $168 }
    FTurnOrderMode: TTurnOrderMode; { $16C }
    F_AoWHSMap_16D: array[0..2] of Byte;
    FTurnOrder: TByteList; { $170 }
    FDay: Integer;  { $174 }
    FSessionName: string; { $178 }
    FOnLeaderChanged: TEventList; { $17C; 5578B0B7 }
    FShowIndependentMoves: Boolean; { $180 }
    F_AoWHSMap_181: array[0..2] of Byte;
    FMoveControl: TMoveControl;  { $184 }
    FGlobalMagicControl: TGlobalMagicControl; { $188 }
    { conflict: FPlayerControl: TPlayerControl; }
    FCampaignSettings: TAoWMapCampaignSettings; { $18C }
    FEditorPlayer: Shortint;  { $190, read at $55784FB4 }
    F_AoWHSMap_191: Byte;
    F_AoWHSMap_192: array[0..1] of Byte;
    F_AoWHSMap_194: Integer;
    FPlayerChangedEvents: TEventList; { $198 }
    FNewDayEvents: TEventList; { $19C }
    FNewTurnEvents: TEventList; { $1A0 }
    FEndTurnEvents: TEventList; { $1A4 }
    FCurrentPlayerChangedEvents: TEventList; { $1A8 }
    FSeatedPlayerChangedEvents: TEventList; { $1AC }
    FCombatEvents: TEventList; { $1B0 }
    FPlayerTerminatedEvents: TEventList; { $1B4 }
    FGameOverEvents: TEventList; { $1B8 }
    FGameTerminatedEvents: TEventList; { $1BC }
    FExitPending: Boolean; { $1C0 }
    F_AoWHSMap_1C1: array[0..2] of Byte;
    FExitEvents: TEventList; { $1C4 }
    FGameOverLockCount: Integer; { $1C8 }
    FExecuteEventLogBuffer: TEventLogList; { $1CC }
    FExecuteEventLogEvents: TEventList; { $1D0 }
    FExecuteEventLogCallBacks: TExecuteEventLogCallBackList; { $1D4 }
    FAILockCount: Integer; { $1D8 }
    FExecuteEventLogDelay: Integer; { $1DC }
    FCosmeticSurgeryEvents: TEventList; { $1E0 }
    FOnActivateAbility: TEventList; { $1E4 }
    FDiplomaticRelationsChangedEvents: TEventList; { $1E8 }
    FUpdateVisibilityEvents: TEventList; { $1EC }
    FEffects: TList; { $1F0 }
    F_AoWHSMap_1F4: Integer;
    F_AoWHSMap_1F8: Byte;
    F_AoWHSMap_1F9: array[0..2] of Byte;
    FArmyUpdateCount: Integer; { $1FC }
    FStructureUpdateCount: Integer; { $200 }
    FUnitUpdateCount: Integer; { $204 }
    FUnitChangedEvents: TEventList; { $208 }
    FArmyChangedEvents: TEventList; { $20C }
    FStructureChangedEvents: TEventList; { $210 }
    FUnitDestroyedEvents: TEventList; { $214 }
    FArmyDestroyedEvents: TEventList; { $218 }
    FStructureDestroyedEvents: TEventList; { $21C }
    FTokenControlActivatedEvents: TEventList; { $220 }
    FCombatMapCreatedEvents: TEventList; { $224 }
    FCombatMapDestroyedEvents: TEventList; { $228 }
    FInitialRandomSeed: Integer; { $22C }
    { conflict: FRandomSeed: Integer; }
    FDefendersSeed: Integer; { $230 }
    FSynchroniseCount: Integer; { $234 }
    FDebugSave: Boolean; { $238 }
    FPlayMode: TPlayMode; { $239 }
    F_AoWHSMap_23A: array[0..1] of Byte;
    FTokenManager: TTokenManager; { $23C }
    { conflict: FTokenManager: TAoWTokenManager; }
    FPlayerCommunicator: TPlayerCommunicator; { $240 }
    FPlayerControl: TPlayerControl; { $244 }
    FUseTurnTimer: Boolean; { $248 }
    FShowUnitShadows: Boolean;  { $249, tested at $55783E36 }
    F_AoWHSMap_24A: array[0..1] of Byte;
    FTokenEventLog: Text; { $24C..$417 }
    FTokenEventLogging: Boolean; { $418 }
    F_AoWHSMap_419: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SendMsg(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function CreateMouse: HSEngine.THSMapMouse; override;
    procedure NotifyProgress(const Progress: HSEngine.TMapProgress); override;
    procedure InitializeNewMap; override;
    function AddMapLevel: Boolean; override;
    procedure Activate; override;
    function CreateNewMap(Settings: HSEngine.TNewHSMapSettings): Boolean; override;
    function ChangeTerrain(MO: HSEngine.TMapObject; X, Y, L, Radius, TerrainType: Integer): Integer; override;
    function ChangeTerrainEx(MO: Engine.TEObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer; override;
    procedure DrawDynamicScene(var SD: GFXE.TSurfaceDesc); override;
    procedure NewFrame; override;
    procedure SetSeatedPlayer(A1: Shortint); override;
    procedure TriggerCombatEvent(Combat: TCombat); virtual;
    procedure TriggerGameTerminatedEvent; virtual;  { +11C draft }
    procedure TriggerPlayerTerminatedEvent(Player: Integer); virtual; { $120 }
    procedure StartNewMap; virtual;  { +124 draft }
    procedure StartLoadedMap; virtual;  { +128 draft }
    procedure TriggerExecuteEventLog(Log: TEventLog; Immediate: Boolean; Done: TExecuteDoneEvent); virtual;
    procedure StartTokenEventLogging;
    procedure StopTokenEventLogging;
    procedure SynchroniseBegin;
    procedure SynchroniseEnd;
    function GetSynchronised: Boolean;
    procedure OnExecuteTokenEvent(Event: TTokenEvent);
    procedure PlayerDisconnected(Player: Shortint);
    procedure PlayerConnectionLost;
    procedure OnTokenManagerMessage(Sender: TObject; const Msg: string);
    function GetIndependentAIMode: TIndependentAIMode;
    function SaveGame(FileName: string): Boolean;
    function TerrainVisible(X, Y, L: Shortint; Radius: Integer): Boolean;
    function Visible(X, Y, L: Shortint; Radius: Integer): Boolean;
    function WatchingTerrain(X, Y, L: Shortint; Radius: Integer): Boolean;
    function Watching(X, Y, L: Shortint; Radius: Integer): Boolean;
    function ValidateTerrainObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean;
    function ValidateObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean;
    procedure UnlockGameOverEventCallBack;
    function SelectNextHero: Boolean;
    function SelectNextArmy: Boolean;
    function SelectPrevArmy: Boolean;
    procedure SeatedPlayerChanged;
    procedure BeginUnitUpdate;
    procedure EndUnitUpdate;
    procedure UnitChanged(AUnit: TAbstractUnit);
    procedure UnitDestroyed(AUnit: TAbstractUnit);
    procedure BeginArmyUpdate;
    procedure EndArmyUpdate;
    procedure ArmyChanged(Army: TArmyHS);
    procedure ArmyDestroyed(Army: TArmyHS);
    { conflict: procedure ArmyDestroyed(Army: TArmy); }
    procedure BeginStructureUpdate;
    procedure EndStructureUpdate;
    procedure StructureChanged(Structure: TStructure);
    procedure StructureDestroyed(Structure: TStructure);
    procedure ExecuteExitGame;
    procedure ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
    procedure TriggerEndTurnEvent(Player: Shortint);
    procedure ClearExecuteEventLogBuffer;
    procedure ExecuteNextEventLog;
    procedure SetExecuteEventLogDelay(Value: Integer);
    procedure UpdateExecuteEventLogDelay;
    procedure ExecuteEventLogDone(Log: TEventLog);
    procedure LockExecuteEventLog;
    procedure UnlockExecuteEventLog;
    procedure GameOverEventHandled;  { draft }
    procedure ExecuteGameOverEvent(Event: TGameOverEventLog);
    procedure UnlockGameOverEvent;  { draft }
    procedure LockGameOverEvent;  { draft }
    procedure GameOver(Player: Shortint; Status: TGameOverStatus);
    { conflict: procedure GameOver(A1: Byte; A2: TGameOverStatus); }
    procedure VerifyAddOnPacks;  { draft }
    procedure ValidateMap(A1: Integer);  { draft }
    procedure OnStreamError(A1: Integer; A2: Integer);  { draft }
    procedure InitializeMapLevel(A1: Byte);  { draft }
    procedure NotifyPlayerChangedEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure UpdatePlayerSeen(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
    procedure NotifyPlayerChanged(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function VisibleForPlayer(X, Y, Level: Integer; Player: Shortint): Boolean;
    procedure FoggedForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure MouseMoved(Sender: TObject);
    procedure UpdateCursor;  { draft }
    procedure ResetSeatedPlayerView;
    procedure Select(A1: TArmyHS; A2: Boolean);
    procedure PlayerChanged;  { draft }
    procedure TokenControlActivatedEvent(Sender: TObject);
    procedure SetupPlayerControl(Mode: TPlayMode; Connection: TPlayerConnectionType);
    procedure ActivateMsg;  { draft }
    function Random(Range: Integer): Integer;
    procedure GenerateNewTurnOrder;  { draft }
    procedure EndTurn;  { draft }
    procedure CancelEndTurn;  { draft }
    procedure LockUpdateVisibility;  { draft }
    procedure UnLockUpdateVisibility;  { draft }
    procedure UpdateVisibility;  { draft }
    procedure ResetMapLevels;  { draft }
    procedure ExecuteNegotiateMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure InitializeCombatMap(A1: Integer; A2: Integer);  { draft }
    procedure ReleaseCombatMap;  { draft }
    function CreateCombat(A1: Integer): TCombat;
    procedure ShowSeatedPlayerCallBack;  { draft }
    procedure DestroyCombat;  { draft }
    procedure RetrieveBattleFieldInfo(X, Y, L, Radius: Integer; var Info: TBattleFieldInfo);
    procedure TriggerRelationsChanged;  { draft }
    procedure LockRelationsChanged;  { draft }
    procedure UnlockRelationsChanged;  { draft }
    procedure UpdateTurnTimeBeep;  { draft }
    procedure ResetTurnTimer;  { draft }
    function GetTurnTimeLeft: Integer;
    function GetTurnTimerEnabled: Boolean;
    procedure EnableTurnTimer;  { draft }
    procedure DisableTurnTimer;  { draft }
    procedure ZeroTurnTimer;  { draft }
    procedure CenterOnLeader(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure PlaceTerrain(A1: Shortint; A2: Shortint; A3: Shortint; A4: Shortint; A5: Shortint);
    procedure UpdateEffects;  { draft }
    procedure AddEffect(A1: Integer);  { draft }
  end;

