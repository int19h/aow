{ Interface declaration run owned by P1. }
  { TUnitCategoryList (instance size 16, VMT 55711230) }
  TUnitCategoryList = class(TList)
  public
    destructor Destroy; override;
    procedure GetCategory(A1: Integer);  { draft }
    procedure Clear;  { draft }
    procedure SortUnits;  { draft }
    procedure AddUnit(A1: Integer; A2: Integer);  { draft }
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
    F_UnitSelector_04: Integer;
    F_UnitSelector_08: Byte;
    F_UnitSelector_09: array[0..2] of Byte;
    F_UnitSelector_0C: Byte;
    F_UnitSelector_0D: array[0..2] of Byte;
    F_UnitSelector_10: Integer;
    F_UnitSelector_14: Byte;
    F_UnitSelector_15: Byte;
    F_UnitSelector_16: Byte;
    F_UnitSelector_17: array[0..0] of Byte;
    F_UnitSelector_18: Integer;
    F_UnitSelector_1C: Byte;
    F_UnitSelector_1D: array[0..0] of Byte;
    F_UnitSelector_1E: Word;
    F_UnitSelector_20: Integer;
    F_UnitSelector_24: Byte;
    F_UnitSelector_25: array[0..0] of Byte;
    F_UnitSelector_26: Word;
    F_UnitSelector_28: Integer;
    destructor Destroy; override;
    procedure SetSelection(A1: Byte); virtual;  { +000 draft }
    procedure CanSelectUnit(A1: Integer); virtual;  { +004 draft }
    procedure Setup(A1: Integer; A2: Integer); virtual;  { +008 draft }
    procedure CanSelect(A1: Integer); virtual;  { +00C draft }
    procedure Select; virtual;  { +010 draft }
    procedure Cancel; virtual;  { +014 draft }
    constructor Create;  { draft }
    procedure AddRef;  { draft }
    procedure Release;  { draft }
    procedure GetSelectionCount;  { draft }
  end;

  { TUnitSelectorAAI (instance size 32, VMT 55711454) }
  TUnitSelectorAAI = class(TActivateAbilityInfo)
  public
    F_UnitSelectorAAI_1C: array[0..3] of Byte;
    destructor Destroy; override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure SetUnitSelector(A1: Integer);  { draft }
  end;

