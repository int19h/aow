{ Interface declaration run owned by P1. }
  TUnitSelectorNotifyEvent = procedure(Selector: TUnitSelector) of object;
  { TUnitCategoryList (instance size 16, VMT 55711230) }
  TUnitCategoryList = class(TList)
  public
    destructor Destroy; override;
    function GetCategory(Index: Integer): TUnitIndexList;
    procedure Clear;
    procedure SortUnits;
    procedure AddUnit(Category, UnitIndex: Integer);
  end;

  { TUnitSelectionControl (instance size 80, VMT 557112B4) }
  TUnitSelectionControl = class(TStringList)
  public
    F_UnitSelectionControl_2C: Byte;
    F_UnitSelectionControl_2D: Byte;
    F_UnitSelectionControl_2E: Byte;
    F_UnitSelectionControl_2F: array[0..0] of Byte;
    F_UnitSelectionControl_30: Integer;
    F_UnitSelectionControl_34: Integer;
    F_UnitSelectionControl_38: Integer;
    F_UnitSelectionControl_3C: Integer;
    F_UnitSelectionControl_40: Integer;
    F_UnitSelectionControl_44: Integer;
    F_UnitSelectionControl_48: Byte;
    F_UnitSelectionControl_49: Byte;
    F_UnitSelectionControl_4A: Byte;
    F_UnitSelectionControl_4B: Byte;
    F_UnitSelectionControl_4C: Integer;
    destructor Destroy; override;
    procedure Create(A1: Byte);  { draft }
    procedure SetSelectedUnitIndex(A1: Integer);  { draft }
    procedure SetSelectedHero(A1: Integer);  { draft }
    procedure GetUnitCategoryList(A1: Integer);  { draft }
    procedure GetUnitCategoryEnabled(A1: Integer);  { draft }
    procedure SetUnitCategoryEnabled(A1: Integer; A2: Integer);  { draft }
    procedure Reset;  { draft }
    procedure DisableAllCategories;  { draft }
    procedure UpdateSelection;  { draft }
  end;

  { TUnitSelector (instance size 44, VMT 557113B8) }
  TUnitSelector = class(TObject)
  public
    FReferences: Integer;  { $04 }
    FPlayer: Shortint;  { $08 }
    F_UnitSelector_09: array[0..2] of Byte;
    F_UnitSelector_0C: Byte;
    F_UnitSelector_0D: array[0..2] of Byte;
    FUnits: TUnitUserList;  { $10 }
    FSelection: Byte;  { $14 }
    FCanceled: Boolean;  { $15 }
    FSelectable: Byte;  { $16 }
    F_UnitSelector_17: array[0..0] of Byte;
    FSource: Pointer;  { $18 }
    FOnSelect: TUnitSelectorNotifyEvent;  { $1C }
    FOnCancel: TUnitSelectorNotifyEvent;  { $24 }
    destructor Destroy; override;
    procedure SetSelection(Value: Byte); virtual;
    procedure CanSelectUnit(A1: Integer); virtual;  { +004 draft }
    procedure Setup(Source: Pointer; Units: TUnitList); virtual;
    function CanSelect(var Error: string): Boolean; virtual;
    procedure Select; virtual;  { +010 draft }
    procedure Cancel; virtual;
    constructor Create;  { draft }
    function AddRef: Integer;
    function Release: Integer;
    function GetSelectionCount: Integer;
  end;

  { TUnitSelectorAAI (instance size 32, VMT 55711454) }
  TUnitSelectorAAI = class(TActivateAbilityInfo)
  public
    FUnitSelector: TUnitSelector;  { $1C }
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetUnitSelector(Value: TUnitSelector);
  end;

