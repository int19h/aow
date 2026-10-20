{ Interface declaration run owned by P5. }
  { TFastCombatCommand (instance size $1C, VMT 55715EDC). $04 ability ID,
    $08 source DV, $0C target DV, $10 expected DV, $14 move cost, $18 target. }
  TFastCombatCommand = class(TObject)
  public
    FAbilityID: Integer;  { $04 }
    FSourceDV, FTargetDV, FExpectedDV, FMoveCost: Integer; { $08..$14 }
    FTarget: TCombatObject;  { $18 }
    function GetName: string; virtual; { +000; 557790CF..5577910F }
    constructor Create(AbilityID: Integer);
  end;

  { TFastCombatCommandList (instance size $18, VMT 55715F60).
    $04 source, $08 source side, $0C target side, $10 combat, $14 command list. }
  TFastCombatCommandList = class(TObject)
  public
    FSource: TCombatObject;  { $04 }
    FSourceSide: TCombatSide; { $08 }
    FTargetSide: TCombatSide;  { $0C }
    FCombat: TFastCombat; { $10 }
    FCommands: TList; { $14 }
    destructor Destroy; override;
    constructor Create(Source: TCombatObject; Combat: TFastCombat; Side: TCombatSide);
    procedure Clear;
    function GetCommands(Index: Integer): TFastCombatCommand;
    function GetCount: Integer;
    procedure Add(A1: TFastCombatCommand);
    procedure Delete(Index: Integer);
    procedure Sort;
  end;

