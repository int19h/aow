{ Interface declaration run owned by P2. }
  { TSelectedArmy (instance size 40, VMT 5570DD70) }
  TSelectedArmy = class(TMoveSelector)
  public
    F_SelectedArmy_18: Byte;
    F_SelectedArmy_19: array[0..2] of Byte;
    F_SelectedArmy_1C: Integer;
    F_SelectedArmy_20: Integer;
    F_SelectedArmy_24: Byte;
    F_SelectedArmy_25: array[0..2] of Byte;
    destructor Destroy; override;
    procedure MouseDownEvent(A1: Integer); override;
    procedure CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer); override;
    procedure UpdateMoveCursor; override;
    procedure SetCurrentMove(A1: Integer); override;
    procedure SelectPath(A1: Byte; A2: Integer; A3: Integer); override;
    procedure Unselect; override;
    procedure ValidateSelection(A1: Integer); override;
    procedure ExecuteMove; override;
    procedure Deactivate; override;
    procedure ShowMovePaths(A1: Integer); override;
    procedure Create(A1: Byte);  { draft }
    procedure AddMoveArmy(A1: Integer; A2: Integer);  { draft }
    function GetArmyHS: TArmyHS;
    function GetSelection: Byte;
    procedure SetSelection(A1: Integer);  { draft }
    procedure GetMoveTypes;  { draft }
    procedure ResetSelectedUnitGFX;  { draft }
    procedure UpdateSelectedUnitGFX(A1: Integer; A2: Integer);  { draft }
    procedure OnDestroyArmy(A1: Integer);  { draft }
    procedure RectangleSelectEvent(A1: Integer);  { draft }
    procedure ValidMultiMoveSelection(A1: Integer);  { draft }
    procedure ActivateMoveSelection;  { draft }
    procedure DeactivateMoveSelection;  { draft }
    procedure Update;  { draft }
    procedure OutputGroupInfo;  { draft }
    procedure SetArmyHS(A1: Integer);  { draft }
    procedure Select(A1: Integer);  { draft }
    procedure SelectBuildRoad(A1: Integer);  { draft }
    procedure Center;  { draft }
    procedure TurnDone;  { draft }
    procedure ToggleGuard;  { draft }
  end;

