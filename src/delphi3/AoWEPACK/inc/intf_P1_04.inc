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
  { TMovepath (instance size 20): inherited $04 locations and $08 count;
    the signed Flag byte of each location is its movement cost. }
  TMovepath = class(TXYLList)
  public
    function MovePointsToPos(MovePoints: Integer): Integer;
    function PosToMovePoints(Pos: Integer): Integer;
    { conflict: function PosToMovePoints(Index: Integer): Integer; }
    function GetMovePoints: Integer;
  end;

  { TMoveSettings (instance size 44): $08 FPath, $0C FPathMovePoints,
    $10 FMoveObject, $14 FMovePoints, $1C FPriority, $20 FSelection,
    $24 FMovePos, $28 FValid. }
  TMoveSettings = class(TEObject)
  public
    FPath: TMovepath; { $08 }
    FPathMovePoints: Integer; { $0C }
    { conflict: FMoveCost: Integer; }
    FMoveObject: TObject; { $10 }
    { conflict: FMoveObject: THexagonSprite; }
    FMovePoints: Integer; { $14 }
    FMoves: Integer; { $18 }
    FPriority: Integer; { $1C }
    FSelection: Byte; { $20 }
    { conflict: FSelection: Integer; }
    FReserved21: array[0..2] of Byte;
    FMovePos: Integer; { $24 }
    FValid: Boolean; { $28 }
    FReserved29: array[0..2] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetMoveLoc: TXYL;
    function GetMovePrio: Integer;
  end;

  TValidateMovePositionProc = function(Moves: TMoveSettingsList; Index: Integer): Boolean;

  { TMoveSettingsList (instance size 12): inherited $08 FChildren. }
  TMoveSettingsList = class(TENode)
  public
    function GetMoveSettings(Index: Integer): TMoveSettings;
    function GetNoneValidMove: Integer;
    function IndexOfMoveObject(MoveObject: TObject): Integer;
    { conflict: function IndexOfMoveObject(Obj: THexagonSprite): Integer; }
    procedure CalculateMovePositions(Validate: TValidateMovePositionProc);
  end;

  { TMoveSelector (instance size 24, VMT 5570DC88) }
  TMoveSelector = class(TObject)
  public
    FMoveControlSettings: TMoveControlSettings; { $04 }
    FMoveSettingsList: TMoveSettingsList; { $08; 5577468B }
    FCurrentMove: Integer; { $0C }
    FMap: TAoWHSMap; { $10 }
    FStatus: TMoveSelectorStatus; { $14 }
    F_MoveSelector_15: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseMoveEvent(Sender: TObject); virtual; { $000 }
    procedure MouseDownEvent(Sender: TObject); virtual; { $04 }
    procedure CalculateMovePath(Index: Integer; X, Y, L: Shortint); virtual; { $08 }
    procedure UpdateMoveCursor; virtual; { $00C }
    function CreateMCS: TMoveControlSettings; virtual; { $010 }
    procedure SetCurrentMove(A1: Integer); virtual; { $014 }
    procedure SelectPath(X, Y, L: Shortint); virtual; { $18 }
    procedure Unselect; virtual; { +01C }
    function ValidateSelection(Field: TAoWMapField): Boolean; virtual; { $20 }
    procedure ExecuteMove; virtual; { $024 }
    procedure Activate(Map: TAoWHSMap); virtual; { $28 }
    procedure Deactivate; virtual; { $02C }
    procedure ShowMovePaths(const Surface: TSurfaceDesc); virtual; { $30 }
    constructor Create;
    procedure Clear;
    function AddMoveObject(Obj: THexagonSprite): Integer;
    procedure DeleteMoveObject(A1: Integer);
    procedure DeleteMoves;
  end;

