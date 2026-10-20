{ Interface declaration run owned by P1. }
  { TPlayerConnectionEventLog: size $2C; $28 reason, $29 disconnected player. VMT 5570CF20. }
  TPlayerConnectionEventLog = class(TMessageEventLog)
  public
    FReason: Byte; { $28 }
    FDisconnectedPlayer: Shortint; { $29 }
    F_PlayerConnectionEventLog_2A: array[0..1] of Byte;
    function Yes: Boolean; override;
    function No: Boolean; override;
    procedure Setup(Player: Shortint; Reason: Byte);
    procedure ExitSaveGameCallBack(Log: TEventLog);
  end;

  { TPlayerControl: size $20; $08 exit callback, $10 exit mode, $14 password,
    $18 disconnected-player list, $1C sync warning shown. VMT 5570D074. }
  TPlayerControl = class(TEObject)
  public
    FExitCallBack: TExitGameCallBack; { $08 }
    FExitMode: TExitGameMode; { $10 }
    F_PlayerControl_11: array[0..2] of Byte;
    FPassword: string; { $14 }
    FDisconnectedPlayers: TDoubleItemList; { $18 }
    FOutOfSyncShown: Boolean; { $1C }
    F_PlayerControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewFrame; virtual;
    procedure NewDay; virtual;
    procedure NewTurn(Player: Shortint); virtual;
    procedure AutoSave; virtual;
    procedure ValidateTurnTiming; virtual;
    procedure Setup; virtual;
    procedure StartNewMap; virtual;
    procedure StartLoadedMap; virtual;
    procedure PasswordFailed; virtual;
    procedure PasswordValidated; virtual;
    procedure SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus); virtual;
    procedure GameOver(Player: Shortint; Status: TGameOverStatus); virtual;
    procedure GameOverEventHandled(Player: Shortint); virtual;
    procedure ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack); virtual; { $80 }
    procedure EndTurn(Player: Shortint); virtual;
    procedure SetSeatedPlayer(Player: Shortint); virtual;
    procedure ValidateDisconnectedPlayers; virtual;
    procedure ConnectionLost; virtual;
    function LockAI: Boolean; virtual;
    procedure GetSyncValue(var Value: Integer);
    procedure OutOfSync(Sender: TObject);
    procedure ListPlayerInfo(Strings: TStrings);
    procedure ExitSaveGameCallBack(Log: TEventLog);
    procedure SaveGameOnExitCallBack(Log: TEventLog);
    procedure ExitNetworkGameCallBack(Log: TEventLog);
    procedure PasswordTryAgainCallBack(Log: TEventLog);
    procedure ValidatePasswordCallBack(Log: TEventLog);
    procedure ValidatePassword(const Password: string);
    procedure PlayerDisconnected(Player: Shortint);
  end;

  { TTextControlItem (instance size 20, VMT 5570D198) }
  TTextControlItem = class(TEObject)
  public
    F_TextControlItem_08: Integer;
    F_TextControlItem_0C: Integer;
    F_TextControlItem_10: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
  end;

  { TTextControl (instance size 12, VMT 5570D270) }
  TTextControl = class(TENode)
  public
    procedure GetItem(A1: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure New;  { draft }
    procedure FindID(A1: Integer);  { draft }
    procedure Sort;  { draft }
    procedure IndexOf;  { draft }
    procedure RetrieveText(ID: Integer; Text: TStrings);
  end;

  { TNewTurnEventLog: size $24; $18 player, $1C text, $20 mode, $21 dialog style. VMT 5570D448. }
  TNewTurnEventLog = class(TEventLog)
  public
    FTurnPlayer: Shortint; { $18 }
    FReserved19: array[0..2] of Byte;
    FText: string; { $1C }
    FMode: TNewTurnEventLogMode; { $20 }
    FDialogStyle: TNewTurnEventLogDialogStyle; { $21 }
  end;

  { TTurnPlayerControl: size $20, no added fields. VMT 5570D54C. }
  TTurnPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus); override;
    procedure GameOver(Player: Shortint; Status: TGameOverStatus); override;
    procedure GameOverEventHandled(Player: Shortint); override;
    procedure EndTurn(Player: Shortint); override;
    procedure SetSeatedPlayer(Player: Shortint); override;
    procedure StartLoadedMapEx; virtual; { $98 }
    procedure ReplayLogbook;
    procedure ShowNewTurnCallBack(Log: TEventLog);
    procedure StartGameCallBack(Log: TEventLog);
    procedure DefaultStartMap;
  end;

  { TSendEmailGameEventLog: size $1C; $18 mode, $19 player. VMT 5570D6AC. }
  TSendEmailGameEventLog = class(TEventLog)
  public
    FMode: Byte; { $18 }
    FSendPlayer: Shortint; { $19 }
  end;

  { TPBEMPlayerControl: size $24; $20 local player. VMT 5570D7AC. }
  TPBEMPlayerControl = class(TTurnPlayerControl)
  public
    FLocalPlayer: Shortint; { $20 }
    F_PBEMPlayerControl_21: array[0..2] of Byte;
    class function ClassID: Integer; override;
    procedure NewTurn(Player: Shortint); override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack); override;
    procedure EndTurn(Player: Shortint); override;
    procedure TerminateEmailGame;
    procedure TerminateEmailGameCallBack(Log: TEventLog);
    procedure SendEmailGameAutomatedCallBack(Log: TEventLog);
    procedure SendEmailGameManualCallBack(Log: TEventLog);
    procedure SendEmailGameCallBack(Log: TEventLog);
    procedure TriggerGameRestartedEvents(Player: Shortint);
    procedure EndTurnGameSavedCallBack(Log: TEventLog);
    procedure StartLoadedEmailGame;
    procedure ContinueRestartedGameCallBack(Log: TEventLog);
    procedure ContinueTurnDoneGameCallBack(Log: TEventLog);
    procedure ValidateLoadedMap;
    procedure ExitGameSaveAsCallBack(Log: TEventLog);
  end;

  { TSimultaniousPlayerControl: size $20, no added fields. VMT 5570D8C8. }
  TSimultaniousPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(Player: Shortint); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus); override;
    procedure GameOverEventHandled(Player: Shortint); override;
    procedure EndTurn(Player: Shortint); override;
    procedure StartGameCallBack(Log: TEventLog);
    procedure StartLoadedMapEx;
  end;

  { TMovepath (instance size 20, VMT 5570D9F0) }
  TMovepath = class(TXYLList)
  public
    function MovePointsToPos(A1: Integer): Integer;
    procedure PosToMovePoints(A1: Integer);  { draft }
    procedure GetMovePoints;  { draft }
  end;

  { TMoveSettings (instance size 44, VMT 5570DA70) }
  TMoveSettings = class(TEObject)
  public
    F_MoveSettings_08: Integer;
    F_MoveSettings_0C: array[0..15] of Byte;
    F_MoveSettings_1C: Integer;
    F_MoveSettings_20: array[0..3] of Byte;
    F_MoveSettings_24: Integer;
    F_MoveSettings_28: Byte;
    F_MoveSettings_29: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetMoveLoc(A1: Integer; A2: Integer);  { draft }
    procedure GetMovePrio;  { draft }
  end;

  { TMoveSettingsList (instance size 12, VMT 5570DB30) }
  TMoveSettingsList = class(TENode)
  public
    procedure GetMoveSettings(A1: Integer);  { draft }
    procedure GetNoneValidMove;  { draft }
    procedure IndexOfMoveObject(A1: Integer);  { draft }
    procedure CalculateMovePositions(A1: Integer; A2: Integer);  { draft }
  end;

  { TMoveSelector (instance size 24, VMT 5570DC88) }
  TMoveSelector = class(TObject)
  public
    F_MoveSelector_04: Integer;
    F_MoveSelector_08: Integer;
    F_MoveSelector_0C: Integer;
    F_MoveSelector_10: Integer;
    F_MoveSelector_14: Byte;
    F_MoveSelector_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseMoveEvent; virtual;  { +000 draft }
    procedure MouseDownEvent(A1: Integer); virtual;  { +004 draft }
    procedure CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer); virtual;  { +008 draft }
    procedure UpdateMoveCursor; virtual;  { +00C draft }
    function CreateMCS: Integer; virtual;  { +010 draft }
    procedure SetCurrentMove(A1: Integer); virtual;  { +014 draft }
    procedure SelectPath(A1: Byte; A2: Integer; A3: Integer); virtual;  { +018 draft }
    procedure Unselect; virtual; { +01C }
    procedure ValidateSelection(A1: Integer); virtual;  { +020 draft }
    procedure ExecuteMove; virtual;  { +024 draft }
    procedure Activate(A1: Integer); virtual;  { +028 draft }
    procedure Deactivate; virtual;  { +02C draft }
    procedure ShowMovePaths(A1: Integer); virtual;  { +030 draft }
    constructor Create;  { draft }
    procedure Clear;  { draft }
    procedure AddMoveObject(A1: Integer);  { draft }
    procedure DeleteMoveObject(A1: Integer);  { draft }
    procedure DeleteMoves;  { draft }
  end;

