{ Interface declaration run owned by P5. }
  { TSubMove (instance size 20, VMT 5570CA40) }
  TSubMove = class(TEObject)
  public
    F_SubMove_08: Integer;
    F_SubMove_0C: Integer;
    F_SubMove_10: Integer;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddMovePointLine;  { draft }
  end;

  { TSubMoveList (instance size 12, VMT 5570CAF8) }
  TSubMoveList = class(TENode)
  public
    procedure GetSubMove(A1: Integer);  { draft }
    procedure DeleteXYL(A1: Integer);  { draft }
    procedure Delete(A1: Integer);  { draft }
    procedure IndexOfXYL(A1: Integer);  { draft }
  end;

  { TMoveControlSettings (instance size 428, VMT 5570CC54) }
  TMoveControlSettings = class(TEObject)
  public
    F_MoveControlSettings_08: Integer;
    F_MoveControlSettings_0C: Integer;
    F_MoveControlSettings_10: Integer;
    F_MoveControlSettings_14: array[0..3] of Byte;
    FProcessedMapFields: TList; { $18; 557D7BF9 }
    F_MoveControlSettings_1C: Integer;
    F_MoveControlSettings_20: Integer;
    F_MoveControlSettings_24: Byte;
    F_MoveControlSettings_25: array[0..30] of Byte;
    F_MoveControlSettings_44: Byte;
    F_MoveControlSettings_45: array[0..30] of Byte;
    F_MoveControlSettings_64: Byte;
    F_MoveControlSettings_65: Byte;
    FMode: TMoveMode; { $66; 557D7B17 }
    F_MoveControlSettings_67: array[0..0] of Byte;
    FPath: TMovepath;  { $68 }
    FPlayer: Shortint;  { $6C }
    F_MoveControlSettings_6D: array[0..2] of Byte;
    F_MoveControlSettings_70: Integer;
    F_MoveControlSettings_74: Integer;
    F_MoveControlSettings_78: Integer;
    F_MoveControlSettings_7C: Integer;
    F_MoveControlSettings_80: Integer;
    F_MoveControlSettings_84: Integer;
    F_MoveControlSettings_88: Integer;
    F_MoveControlSettings_8C: Integer;
    F_MoveControlSettings_90: Integer;
    F_MoveControlSettings_94: array[0..3] of Byte;
    FMovePointsMax: Integer; { $98; 557D7B3D }
    FArmyHS: TArmyHS;  { $9C }
    FSelection: Integer;  { $A0 }
    F_MoveControlSettings_A4: array[0..3] of Byte;
    FUnits: TUnitUserList; { $A8; AddUnitsEx at 557929AD }
    FMovePointTable: TMovePointTable;  { $AC }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure ResetState;  { draft }
    procedure Reset;
    procedure SetSourcePos(A1: Integer; A2: Integer; A3: Integer);
    procedure SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);
    procedure SetupArmy(A1: Integer; A2: Integer);  { draft }
    procedure SetupLevel(A1: Integer);  { draft }
    procedure SetupMovePointData(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ClearMovePoints;  { draft }
    function GetMovePoints(A1: Integer; A2: Integer; A3: Integer): Integer;
    procedure SetMovePoints(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure GetMovePointLevelData(A1: Integer);  { draft }
    procedure GetMovePointsXYL(A1: Integer; A2: Integer);  { draft }
    procedure SetMovePointsXYL(A1: Integer; A2: Integer);  { draft }
  end;

  { TMoveControl (instance size 480, VMT 5570CDA8) }
  TMoveControl = class(TObject)
  public
    F_MoveControl_04: Integer;
    F_MoveControl_08: Byte;
    FPlayer: Shortint; { $09; 55761458 }
    F_MoveControl_0A: Byte;
    F_MoveControl_0B: array[0..0] of Byte;
    F_MoveControl_0C: Integer;
    F_MoveControl_10: Integer;
    F_MoveControl_14: Integer;
    F_MoveControl_18: Integer;
    F_MoveControl_1C: Integer;
    F_MoveControl_20: Integer;
    F_MoveControl_24: Integer;
    F_MoveControl_28: Integer;
    F_MoveControl_2C: Integer;
    F_MoveControl_30: Byte;
    F_MoveControl_31: Byte;
    F_MoveControl_32: array[0..253] of Byte;
    F_MoveControl_130: Integer;
    F_MoveControl_134: Integer;
    F_MoveControl_138: Integer;
    F_MoveControl_13C: Integer;
    F_MoveControl_140: Byte;
    F_MoveControl_141: array[0..2] of Byte;
    F_MoveControl_144: Integer;
    F_MoveControl_148: Byte;
    F_MoveControl_149: array[0..2] of Byte;
    F_MoveControl_14C: Byte;
    F_MoveControl_14D: array[0..58] of Byte;
    F_MoveControl_188: Byte;
    F_MoveControl_189: array[0..62] of Byte;
    F_MoveControl_1C8: Integer;
    F_MoveControl_1CC: Integer;
    F_MoveControl_1D0: Integer;
    F_MoveControl_1D4: array[0..3] of Byte;
    F_MoveControl_1D8: Integer;
    FSettings: TMoveControlSettings; { $1DC }
    destructor Destroy; override;
    procedure SetupMove; virtual;  { +000 draft }
    procedure ProcessMove(A1: TMoveControlSettings); virtual;  { +004 }
    constructor Create(AOwner: TAoWHSMap);
    procedure Clear;  { draft }
    procedure SetMapL(A1: Integer);  { draft }
    procedure DefaultMoveOnMovePointProc(A1: Integer; A2: Integer);  { draft }
    procedure FindSubMoveOrigin(A1: Integer);  { draft }
    procedure CalculateMovePointLine(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ProcessHexagon(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ValidLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure ExecuteExternalMove(A1: Integer; A2: Integer; A3: Integer);  { draft }
    procedure SetupSubMove(A1: Integer; A2: Integer);  { draft }
    procedure ProcessSubMove(A1: Integer);  { draft }
    procedure Process;  { draft }
    procedure CalculatePathEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer);  { draft }
    procedure CalculatePath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);  { draft }
    procedure ExploredOnlyMoveOnMovePointProc(A1: Integer; A2: Integer);  { draft }
    procedure Activate(A1: Integer);  { draft }
    procedure Deactivate;  { draft }
    procedure CanMove(A1: Integer; A2: Integer);  { draft }
    procedure ValidPath(A1: Integer; A2: Integer);  { draft }
    procedure CalculateGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
    procedure CalculateTurnAroundMovePoints(A1: Integer);  { draft }
    procedure GetMovePointsCostFast(A1: Integer; A2: Integer; A3: Integer; A4: Integer);  { draft }
  end;

  { TAoWTokenManager (instance size 28, VMT 5570CE24) }
  TAoWTokenManager = class(TTokenManager)
  public
  end;

