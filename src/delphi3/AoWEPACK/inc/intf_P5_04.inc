{ Interface declaration run owned by P5. }
  { TEmailGame (instance size 32, VMT 55714BAC) }
  TEmailGame = class(TEObject)
  public
    F_EmailGame_08: Integer;
    F_EmailGame_0C: Integer;
    F_EmailGame_10: Integer;
    F_EmailGame_14: Integer;
    F_EmailGame_18: Integer;
    F_EmailGame_1C: array[0..3] of Byte;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TEmailGameList (instance size 12, VMT 55714C84) }
  TEmailGameList = class(TENode)
  public
    procedure GetEmailGames(A1: Integer);  { draft }
    procedure IndexOfUniqueLocalID(A1: Integer);  { draft }
  end;

  { TEmailGameControl (instance size 12, VMT 55714D84) }
  TEmailGameControl = class(TEObject)
  public
    F_EmailGameControl_08: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure CreateUniqueLocalID;  { draft }
    procedure Load;  { draft }
    procedure Save;  { draft }
    procedure FindEmailGame(A1: Integer);  { draft }
    procedure EmailGameRestarted(A1: Integer);  { draft }
    procedure GenerateSecurityID;  { draft }
    procedure UpdateGame(A1: Integer);  { draft }
    procedure CreateEmailGame(A1: Integer; A2: Integer);  { draft }
    procedure ValidateIncommingGame(A1: Integer; A2: Integer);  { draft }
  end;

  { TRestartGameEventLog (instance size 40, VMT 55714E4C) }
  TRestartGameEventLog = class(TMessageEventLog)
  public
    class function ClassID: Integer; override;
    procedure GetText(A1: Integer); override;
    function Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TSMTPEventLog (instance size 52, VMT 55714F58) }
  TSMTPEventLog = class(TEventLog)
  public
    F_SMTPEventLog_18: array[0..11] of Byte;
    F_SMTPEventLog_24: Integer;
    F_SMTPEventLog_28: array[0..11] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

