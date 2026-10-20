{ Interface declaration run owned by P1. }
  { TPlayerConnectionEventLog (instance size 44, VMT 5570CF20) }
  TPlayerConnectionEventLog = class(TMessageEventLog)
  public
    F_PlayerConnectionEventLog_28: Byte;
    F_PlayerConnectionEventLog_29: Byte;
    F_PlayerConnectionEventLog_2A: array[0..1] of Byte;
    procedure Yes; override;
    procedure No; override;
    procedure Setup(A1: Byte; A2: Byte);  { draft }
    procedure ExitSaveGameCallBack(A1: Integer);  { draft }
  end;

  { TPlayerControl (instance size 32, VMT 5570D074) }
  TPlayerControl = class(TEObject)
  public
    F_PlayerControl_08: Integer;
    F_PlayerControl_0C: Integer;
    F_PlayerControl_10: Byte;
    F_PlayerControl_11: array[0..2] of Byte;
    F_PlayerControl_14: Integer;
    F_PlayerControl_18: Integer;
    F_PlayerControl_1C: Byte;
    F_PlayerControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure NewFrame; virtual;  { +04C draft }
    procedure NewDay; virtual;  { +050 draft }
    procedure NewTurn(A1: Integer; A2: Integer); virtual;  { +054 draft }
    procedure AutoSave; virtual;  { +058 draft }
    procedure ValidateTurnTiming; virtual;  { +05C draft }
    procedure Setup; virtual;  { +060 draft }
    procedure StartNewMap; virtual;  { +064 draft }
    procedure StartLoadedMap; virtual;  { +068 draft }
    procedure PasswordFailed; virtual;  { +06C draft }
    procedure PasswordValidated; virtual;  { +070 draft }
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); virtual;  { +074 draft }
    procedure GameOver(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure GameOverEventHandled(A1: Integer); virtual;  { +07C draft }
    procedure ExitGame(A1: Byte); virtual;  { +080 draft }
    procedure EndTurn(A1: Integer; A2: Integer); virtual;  { +084 draft }
    procedure SetSeatedPlayer(A1: Integer); virtual;  { +088 draft }
    procedure ValidateDisconnectedPlayers; virtual;  { +08C draft }
    procedure ConnectionLost; virtual;  { +090 draft }
    procedure LockAI; virtual;  { +094 draft }
    procedure GetSyncValue(A1: Integer);  { draft }
    procedure OutOfSync;  { draft }
    procedure ListPlayerInfo(A1: Integer);  { draft }
    procedure ExitSaveGameCallBack(A1: Integer);  { draft }
    procedure SaveGameOnExitCallBack(A1: Integer);  { draft }
    procedure ExitNetworkGameCallBack(A1: Integer);  { draft }
    procedure PasswordTryAgainCallBack(A1: Integer);  { draft }
    procedure ValidatePasswordCallBack(A1: Integer);  { draft }
    procedure ValidatePassword(A1: Integer);  { draft }
    procedure PlayerDisconnected(A1: Integer);  { draft }
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
    procedure RetrieveText(A1: Integer; A2: Integer);  { draft }
  end;

  { TNewTurnEventLog (instance size 36, VMT 5570D448) }
  TNewTurnEventLog = class(TEventLog)
  public
    F_NewTurnEventLog_18: array[0..11] of Byte;
  end;

  { TTurnPlayerControl (instance size 32, VMT 5570D54C) }
  TTurnPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); override;
    procedure GameOver(A1: Integer; A2: Integer); override;
    procedure GameOverEventHandled(A1: Integer); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure SetSeatedPlayer(A1: Integer); override;
    procedure StartLoadedMapEx; virtual;  { +098 draft }
    procedure ReplayLogbook;  { draft }
    procedure ShowNewTurnCallBack;  { draft }
    procedure StartGameCallBack;  { draft }
    procedure DefaultStartMap;  { draft }
  end;

  { TSendEmailGameEventLog (instance size 28, VMT 5570D6AC) }
  TSendEmailGameEventLog = class(TEventLog)
  public
    F_SendEmailGameEventLog_18: array[0..3] of Byte;
  end;

  { TPBEMPlayerControl (instance size 36, VMT 5570D7AC) }
  TPBEMPlayerControl = class(TTurnPlayerControl)
  public
    F_PBEMPlayerControl_20: Byte;
    F_PBEMPlayerControl_21: array[0..2] of Byte;
    class function ClassID: Integer; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure ExitGame(A1: Byte); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure TerminateEmailGame;  { draft }
    procedure TerminateEmailGameCallBack;  { draft }
    procedure SendEmailGameAutomatedCallBack(A1: Integer);  { draft }
    procedure SendEmailGameManualCallBack(A1: Integer);  { draft }
    procedure SendEmailGameCallBack(A1: Integer);  { draft }
    procedure TriggerGameRestartedEvents(A1: Integer);  { draft }
    procedure EndTurnGameSavedCallBack(A1: Integer);  { draft }
    procedure StartLoadedEmailGame;  { draft }
    procedure ContinueRestartedGameCallBack(A1: Integer);  { draft }
    procedure ContinueTurnDoneGameCallBack(A1: Integer);  { draft }
    procedure ValidateLoadedMap;  { draft }
    procedure ExitGameSaveAsCallBack(A1: Integer);  { draft }
  end;

  { TSimultaniousPlayerControl (instance size 32, VMT 5570D8C8) }
  TSimultaniousPlayerControl = class(TPlayerControl)
  public
    class function ClassID: Integer; override;
    procedure NewDay; override;
    procedure NewTurn(A1: Integer; A2: Integer); override;
    procedure ValidateTurnTiming; override;
    procedure Setup; override;
    procedure StartNewMap; override;
    procedure StartLoadedMap; override;
    procedure PasswordValidated; override;
    procedure SetPlayerGameOverStatus(A1: Integer; A2: Integer); override;
    procedure GameOverEventHandled(A1: Integer); override;
    procedure EndTurn(A1: Integer; A2: Integer); override;
    procedure StartGameCallBack;  { draft }
    procedure StartLoadedMapEx;  { draft }
  end;

  { TMovepath (instance size 20, VMT 5570D9F0) }
  TMovepath = class(TXYLList)
  public
    procedure MovePointsToPos(A1: Integer);  { draft }
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
    procedure Unselect(A1: Integer; A2: Integer); virtual;  { +01C draft }
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

