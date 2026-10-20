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
    FMinimumLevel: Byte;  { $2C }
    FMaximumLevel: Byte;  { $2D }
    FAlignments: TAlignments;  { $2E }
    F_UnitSelectionControl_2F: array[0..0] of Byte;
    FRacesEnabled: TBitList;  { $30 }
    FTypesEnabled: TBitList;  { $34 }
    FRaceUnits: TUnitCategoryList;  { $38 }
    FTypeUnits: TUnitCategoryList;  { $3C }
    FAllUnits: TUnitIndexList;  { $40 }
    FSelectedUnitIndex: Integer;  { $44 }
    FShowEmptyCategories: Boolean;  { $48 }
    FShowRaceCategories: Boolean;  { $49 }
    FShowTypeCategories: Boolean;  { $4A }
    FShowAllCategory: Boolean;  { $4B }
    FSelectedHero: THero;  { $4C }
    destructor Destroy; override;
    constructor Create;
    procedure SetSelectedUnitIndex(Value: Integer);
    procedure SetSelectedHero(Value: THero);
    function GetUnitCategoryList(Category: Shortint): TUnitIndexList;
    function GetUnitCategoryEnabled(Category: Shortint): Boolean;
    procedure SetUnitCategoryEnabled(Category: Shortint; Value: Boolean);
    procedure Reset;
    procedure DisableAllCategories;
    procedure UpdateSelection;
  end;

  { TUnitSelector (instance size 44, VMT 557113B8) }
  TUnitSelector = class(TObject)
  public
    FReferences: Integer;  { $04 }
    FPlayer: Shortint;  { $08 }
    F_UnitSelector_09: array[0..2] of Byte;
    FCaption: string; { $0C }
    FUnits: TUnitUserList;  { $10 }
    FSelection: Byte;  { $14 }
    FCanceled: Boolean;  { $15 }
    FSelectable: Byte;  { $16 }
    F_UnitSelector_17: array[0..0] of Byte;
    FSourceUnitID: Integer; { $18 }
    FOnSelect: TUnitSelectorNotifyEvent;  { $1C }
    FOnCancel: TUnitSelectorNotifyEvent;  { $24 }
    destructor Destroy; override;
    procedure SetSelection(Value: Byte); virtual;
    function CanSelectUnit(A1: TUnit): Boolean; virtual; { +004 }
    procedure Setup(Source: Pointer; Units: TUnitList); virtual;
    function CanSelect(var Error: string): Boolean; virtual;
    function Select: Boolean; virtual; { +010 }
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

