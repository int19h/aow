{ Interface declaration run owned by P5. }
  { TFastCombatCommand (instance size 28, VMT 55715EDC) }
  TFastCombatCommand = class(TObject)
  public
    FAbilityID: Integer;  { $04 }
    FSourceDV, FTargetDV, FExpectedDV, FMoveCost: Integer; { $08..$14 }
    FTarget: TCombatObject;  { $18 }
    function GetName: string; virtual; { +000; 557790CF..5577910F }
    constructor Create(A1: Integer);
  end;

  { TFastCombatCommandList (instance size 24, VMT 55715F60) }
  TFastCombatCommandList = class(TObject)
  public
    FSource: TCombatObject;  { $04 }
    FSourceSide: TCombatSide; { $08 }
    FTargetSide: TCombatSide;  { $0C }
    FCombat: TFastCombat; { $10 }
    F_FastCombatCommandList_14: Integer;
    destructor Destroy; override;
    constructor Create(A1: Integer; A2: Integer);  { draft }
    procedure Clear;  { draft }
    procedure GetCommands(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure Add(A1: TFastCombatCommand);
    procedure Delete(A1: Integer);  { draft }
    procedure Sort;  { draft }
  end;

