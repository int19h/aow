{ Interface declaration run owned by P5. }
  { TJoinEventLog (instance size $3C, VMT 55711C84).
    $18 FirstUnitID, $1C UnitIDs, $20 Location, $24 Selection,
    $28 JoinIndex, $2C JoinMessage, $30 Gold, $34 JoinMode, $38 Text. }
  TJoinEventLog = class(TEventLog)
  public
    FFirstUnitID: Integer;
    FUnitIDs: TIntegerList;
    FLocation: TXYL;
    FSelection: Byte;
    F_JoinEventLog_25: array[0..2] of Byte;
    FJoinIndex: Integer;
    FJoinMessage: TStringList;
    FGold: Integer;
    FJoinMode: TJoinMode;
    F_JoinEventLog_35: array[0..2] of Byte;
    FText: string;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function Validate: Boolean; virtual;  { +078 }
    procedure ListJoinUnits(Units: TUnitList; var Selection: Byte); virtual;  { +07C }
    procedure Accept(A1: Integer; A2: Integer); virtual;  { +080 needs: P2 THeroJoinEventLog.Accept must return Boolean, var ErrorText: string. }
    procedure Cancel; virtual;  { +084 needs: P7 TPrisonersJoinEventLog.Cancel returns Boolean. }
    function Reject(var ErrorText: string): Boolean; virtual;  { +088 }
    procedure SetupJoinArmy(Army: TArmy; Player: Shortint; JoinMode: TJoinMode);
  end;

