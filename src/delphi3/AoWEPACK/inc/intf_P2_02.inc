{ Interface declaration run owned by P2. }
  { TSelectedArmy (instance size $28): $18 mode, $1C road builder ID,
    $20 selected graphics references, $24 ignore next mouse-down. }
  TSelectedArmy = class(TMoveSelector)
  public
    FMode: TSelectedArmyMode; { $18 }
    F_SelectedArmy_19: array[0..2] of Byte;
    FRoadBuilderID: Integer; { $1C }
    FSelectedUnitGFX: TIntegerList; { $20 }
    FIgnoreMouseDown: Boolean; { $24; 557632E7 }
    F_SelectedArmy_25: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseDownEvent(Sender: TObject); override;
    procedure CalculateMovePath(Index: Integer; X, Y, L: Shortint); override;
    procedure UpdateMoveCursor; override;
    procedure SetCurrentMove(A1: Integer); override;
    procedure SelectPath(X, Y, L: Shortint); override;
    procedure Unselect; override;
    function ValidateSelection(Field: TAoWMapField): Boolean; override;
    procedure ExecuteMove; override;
    procedure Deactivate; override;
    procedure ShowMovePaths(const Surface: TSurfaceDesc); override;
    constructor Create;
    function AddMoveArmy(ArmyHS: TArmyHS; Selection: Byte): Integer;
    function GetArmyHS: TArmyHS;
    function GetSelection: Byte;
    procedure SetSelection(Selection: Byte);
    function GetMoveTypes: TMoveTypes;
    procedure ResetSelectedUnitGFX;
    procedure UpdateSelectedUnitGFX;
    procedure OnDestroyArmy(Sender: TObject);
    { conflict: procedure OnDestroyArmy(Army: TArmy); }
    procedure RectangleSelectEvent(Sender: TObject);
    { conflict: procedure RectangleSelectEvent(Mouse: TAbstractAoWHSMapMouse); }
    function ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
    procedure ActivateMoveSelection;
    procedure DeactivateMoveSelection;
    procedure Update;
    procedure OutputGroupInfo;
    procedure SetArmyHS(ArmyHS: TArmyHS);
    procedure Select(ArmyHS: TArmyHS);
    procedure SelectBuildRoad(AUnit: TAbstractUnit);
    procedure Center;
    procedure TurnDone;
    procedure ToggleGuard;
  end;

