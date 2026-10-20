{ Interface declaration run owned by P5. }
  { TFastCombatCommand (instance size 28, VMT 55715EDC) }
  TFastCombatCommand = class(TObject)
  public
    F_FastCombatCommand_04: Integer;
    F_FastCombatCommand_08: array[0..15] of Byte;
    F_FastCombatCommand_18: Byte;
    F_FastCombatCommand_19: array[0..2] of Byte;
    procedure GetName(A1: Integer); virtual;  { +000 draft }
    constructor Create;  { draft }
  end;

  { TFastCombatCommandList (instance size 24, VMT 55715F60) }
  TFastCombatCommandList = class(TObject)
  public
    F_FastCombatCommandList_04: Integer;
    F_FastCombatCommandList_08: Integer;
    F_FastCombatCommandList_0C: Integer;
    F_FastCombatCommandList_10: Integer;
    F_FastCombatCommandList_14: Integer;
    destructor Destroy; override;
    constructor Create(A1: Integer; A2: Integer);  { draft }
    procedure Clear;  { draft }
    procedure GetCommands(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure Add;  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure Sort;  { draft }
  end;

