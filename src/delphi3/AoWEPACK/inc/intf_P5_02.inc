{ Interface declaration run owned by P5. }
  { TJoinEventLog (instance size 60, VMT 55711C84) }
  TJoinEventLog = class(TEventLog)
  public
    F_JoinEventLog_18: Integer;
    F_JoinEventLog_1C: Integer;
    F_JoinEventLog_20: Integer;
    F_JoinEventLog_24: Byte;
    F_JoinEventLog_25: array[0..2] of Byte;
    F_JoinEventLog_28: Integer;
    F_JoinEventLog_2C: Integer;
    F_JoinEventLog_30: Integer;
    F_JoinEventLog_34: Byte;
    F_JoinEventLog_35: array[0..2] of Byte;
    F_JoinEventLog_38: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Validate(A1: Integer; A2: Integer); virtual;  { +078 draft }
    procedure ListJoinUnits(A1: Integer; A2: Integer); virtual;  { +07C draft }
    procedure Accept(A1: Integer; A2: Integer); virtual;  { +080 draft }
    procedure Cancel; virtual;  { +084 draft }
    procedure Reject; virtual;  { +088 draft }
    procedure SetupJoinArmy(A1: Integer; A2: Byte; A3: Integer);  { draft }
  end;

