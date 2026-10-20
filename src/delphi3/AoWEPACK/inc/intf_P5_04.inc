{ Interface declaration run owned by P5. }
  { TEmailGame (instance size $20, VMT 55714BAC).
    $08 name; $0C unique local ID; $10 unique ID; $14 security ID;
    $18 email address; $1C last day (not serialized by the original). }
  TEmailGame = class(TEObject)
  public
    FName: string; { $08 }
    FUniqueLocalID: Integer; { $0C }
    FUniqueID: Integer; { $10 }
    FSecurityID: Integer; { $14 }
    FEmailAddress: string; { $18 }
    FLastDay: Integer; { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
  end;

  { TEmailGameList (instance size 12, VMT 55714C84) }
  TEmailGameList = class(TENode)
  public
    function GetEmailGames(Index: Integer): TEmailGame;
    function IndexOfUniqueLocalID(ID: Integer): Integer;
  end;

  { TEmailGameControl (instance size $0C, VMT 55714D84). $08 games. }
  TEmailGameControl = class(TEObject)
  public
    FGames: TEmailGameList; { $08 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function CreateUniqueLocalID: Integer;
    procedure Load;
    procedure Save;
    function FindEmailGame(Game: TEmailGame): TEmailGame;
    function EmailGameRestarted(Game: TEmailGame): Boolean;
    function GenerateSecurityID: Integer;
    function UpdateGame(Game: TEmailGame): Boolean;
    function CreateEmailGame(Name, EmailAddress: string): TEmailGame;
    procedure ValidateIncommingGame(const FileName: string; var Destination: string);
  end;

  { TRestartGameEventLog (instance size 40, VMT 55714E4C) }
  TRestartGameEventLog = class(TMessageEventLog)
  public
    class function ClassID: Integer; override;
    function GetText: string; override;
    function Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; override;
  end;

  { TSMTPEventLog (instance size $34, VMT 55714F58). $24 message. }
  TSMTPEventLog = class(TEventLog)
  public
    F_SMTPEventLog_18: array[0..11] of Byte;
    FMessage: TStringList; { $24 }
    F_SMTPEventLog_28: array[0..11] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
  end;

