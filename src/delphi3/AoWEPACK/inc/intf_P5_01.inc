{ Interface declaration run owned by P5. }
  { TSubMove: instance size $14; $08 location, $0C origin, $10 move point lines. }
  TSubMove = class(TEObject)
  public
    FLocation: TXYL; { $08 }
    FOrigin: TXYL; { $0C }
    FMovePointLines: TDoubleItemList; { $10 }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure AddMovePointLine(Direction, Count: Integer);
  end;

  { TSubMoveList (instance size 12, VMT 5570CAF8) }
  TSubMoveList = class(TENode)
  public
    function GetSubMove(Index: Integer): TSubMove;
    function DeleteXYL(Location: Integer): Integer;
    procedure Delete(Index: Integer);
    function IndexOfXYL(Location: Integer): Integer;
  end;

  { TMoveControlSettings: instance size $1AC; $08 references, $10 submoves,
    $18 processed fields, $1C row offsets, $20 level data, $24/$44 neighbor offsets,
    $64 points clear, $70/$74/$78 map size, $7C source, $88 destination,
    $98 move limit, $9C army, $A0 selection, $A8 units, $AC move point table. }
  PMovePointLevelArray = ^TMovePointLevelArray;
  TMovePointLevelArray = array[0..16383] of PIntegerArray;
  TMoveControlSettings = class(TEObject)
  public
    FRefCount: Integer; { $08 }
    FMovePointsLimit: Integer; { $0C }
    FSubMoves: TSubMoveList; { $10 }
    FSubMoveIndex: Integer; { $14 }
    FProcessedMapFields: TList; { $18; 557D7BF9 }
    FRowOffsets: PIntegerArray; { $1C }
    FLevelData: PMovePointLevelArray; { $20 }
    FEvenOffsets: array[0..7] of Integer; { $24 }
    FOddOffsets: array[0..7] of Integer; { $44 }
    FMovePointsClear: Boolean; { $64 }
    FStatus: TMoveControlSettingsStatus; { $65 }
    FMode: TMoveMode; { $66; 557D7B17 }
    F_MoveControlSettings_67: array[0..0] of Byte;
    FPath: TMovepath;  { $68 }
    FPlayer: Shortint;  { $6C }
    F_MoveControlSettings_6D: array[0..2] of Byte;
    FWidth: Integer; { $70 }
    FHeight: Integer; { $74 }
    FLevelCount: Integer; { $78 }
    FSourceX: Integer; { $7C }
    FSourceY: Integer; { $80 }
    FSourceL: Integer; { $84 }
    FDestinationX: Integer; { $88 }
    FDestinationY: Integer; { $8C }
    FDestinationL: Integer; { $90 }
    F_MoveControlSettings_94: array[0..3] of Byte;
    FMovePointsMax: Integer; { $98; 557D7B3D }
    FArmyHS: TArmyHS;  { $9C }
    FSelection: Integer;  { $A0 }
    FTransporterArmy: TArmyHS; { $A4 }
    FUnits: TUnitUserList; { $A8; AddUnitsEx at 557929AD }
    FMovePointTable: TMovePointTable;  { $AC }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure Clear; override;
    procedure ResetState;
    procedure Reset;
    procedure SetSourcePos(X, Y, L: Integer);
    procedure SetDestinationPos(X, Y, L: Integer);
    procedure SetupArmy(Army: TArmyHS; Selection: Byte);
    procedure SetupLevel(Level: Integer);
    procedure SetupMovePointData(Width, Height, LevelCount: Integer);
    procedure ClearMovePoints;
    function GetMovePoints(X, Y, L: Integer): Integer;
    procedure SetMovePoints(X, Y, L, Value: Integer);
    function GetMovePointLevelData(Level: Integer): PIntegerArray;
    function GetMovePointsXYL(Location: Integer): Integer;
    procedure SetMovePointsXYL(Location, Value: Integer);
  end;

  { TMoveControl: instance size $1E0; $04 map, $08 status, $09 player, $0A mode,
    $0C source, $18 destination, $24 map level, $28 processed count, $2C move limit,
    $30 move table, $130 processed fields, $134 army, $138 selection, $13C move data,
    $140 callback, $148 field offsets, $188 point offsets, $1C8/$1CC gap endpoints,
    $1D0 direct route, $1D8 exploration mask, $1DC settings. }
  TMoveControl = class(TObject)
  public
    FMap: THSMap; { $04; AoWTCPCK 0041B428 }
    FStatus: TMoveControlStatus; { $08 }
    FPlayer: Shortint; { $09; 55761458 }
    FMode: TMoveMode; { $0A }
    F_MoveControl_0B: Byte;
    FSourceX: Integer; { $0C }
    FSourceY: Integer; { $10 }
    FSourceL: Integer; { $14 }
    FDestinationX: Integer; { $18 }
    FDestinationY: Integer; { $1C }
    FDestinationL: Integer; { $20 }
    FMapLevel: TMapLevel; { $24 }
    FProcessedCount: Integer; { $28 }
    FMovePointsLimit: Integer; { $2C }
    FMovePointTable: TMovePointTable; { $30 }
    FProcessedMapFields: TList; { $130 }
    FArmyHS: TArmyHS; { $134 }
    FSelection: Integer; { $138 }
    FTransporterArmy: TArmyHS; { $13C }
    FOnMovePoint: TMoveOnMovePointProc; { $140 }
    FFieldOffsets: array[0..1, 0..7] of Integer; { $148 }
    FPointOffsets: array[0..1, 0..7] of Integer; { $188 }
    FGapStarts: TXYLList; { $1C8 }
    FGapEnds: TXYLList; { $1CC }
    FDirectRoute: TXYLList; { $1D0 }
    F_MoveControl_1D4: Integer;
    FExploredMask: Integer; { $1D8 }
    FSettings: TMoveControlSettings; { $1DC }
    destructor Destroy; override;
    function SetupMove: Boolean; virtual; { +000 }
    procedure ProcessMove(A1: TMoveControlSettings); virtual;  { +004 }
    constructor Create(AOwner: THSMap);
    procedure Clear;
    procedure SetMapL(Level: TMapLevel);
    function DefaultMoveOnMovePointProc(MapF: TAoWMapField; MoveOverCode: Integer): Integer;
    function FindSubMoveOrigin(MapF: TAoWMapField): TAoWMapField;
    function CalculateMovePointLine(MapF: TAoWMapField; Direction, MoveOverCode: Integer): Integer;
    procedure ProcessHexagon(MapF: TAoWMapField; Direction, Count: Integer);
    function ValidLocation(X, Y, L: Integer): Boolean;
    procedure ExecuteExternalMove(Source, Target: TAoWMapField; MovePoints: Integer);
    function SetupSubMove(MapF, Origin: TAoWMapField): TSubMove;
    function ProcessSubMove(SubMove: TSubMove): Boolean;
    function Process: Boolean;
    procedure CalculatePathEx(Path: TMovepath; X, Y, L: Shortint);
    procedure CalculatePath(Settings: TMoveControlSettings; Path: TMovepath; X, Y, L: Shortint);
    function ExploredOnlyMoveOnMovePointProc(MapF: TAoWMapField; MoveOverCode: Integer): Integer;
    function Activate(Settings: TMoveControlSettings): Boolean;
    procedure Deactivate;
    function CanMove(Settings: TMoveControlSettings; Mode: TCanMoveMode): Integer;
    function ValidPath(Settings: TMoveControlSettings; Path: TMovepath): Boolean;
    procedure CalculateGaps(SourceX, SourceY, DestinationX, DestinationY: Integer);
    function CalculateTurnAroundMovePoints(var GapIndex: Integer): Integer;
    function GetMovePointsCostFast(SourceX, SourceY, DestinationX, DestinationY: Integer): Integer;
  end;

  { TAoWTokenManager (instance size 28, VMT 5570CE24) }
  TAoWTokenManager = class(TTokenManager)
  public
  end;

