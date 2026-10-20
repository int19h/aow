{ Interface declaration run owned by P2. }
  { Editor drop message, size $30: screen X/Y at $18/$1C, level at $20, result at $2C. }
  TItemDropMsg = record
    MsgID, Seq: Integer;
    Sender: TEObject;
    Param: array[0..2] of Integer;
    Xhp, Yhp, Lhp, Reserved0, Reserved1, Result: Integer;
  end;
  { TItemGFX (instance size 48, VMT 5570F7E0) }
  TItemGFX = class(TEResource)
  public
    F_ItemGFX_18: Integer;
    F_ItemGFX_1C: Integer;
    F_ItemGFX_20: Byte;
    F_ItemGFX_21: array[0..2] of Byte;
    F_ItemGFX_24: Integer;
    F_ItemGFX_28: Integer;
    F_ItemGFX_2C: Byte;
    F_ItemGFX_2D: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure ItemGFXIndex;  { draft }
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetImageLibraryName(A1: Integer; A2: Integer);  { draft }
    function GetItemImage: TLibraryImage;
  end;

  { TItemGFXList (instance size 20, VMT 5570F8C0) }
  TItemGFXList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetItemGFX(Index: Integer): TItemGFX;
    function FindItemTypeGFX(ItemType: TItemType): Integer;
  end;

  { TItemTE (instance size $1C): $10 item ID, $14 action, $18 hero ID. }
  TItemTE = class(TTokenEvent)
  public
    FItemID: Integer; { $10 }
    FAction: Byte; { $14; 0 = use }
    F_ItemTE_15: array[0..2] of Byte;
    FHeroID: Integer; { $18 }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TItem (instance size $4C): $14 ID, $18 owner name, $1C status, $20 references,
    $24 library ID, $28 library name, $2C value, $30 name, $34 type, $38 spell ID,
    $3C description, $40 graphics index, $44 hidden, $45 availability,
    $46 attack, $47 defense, $48 damage, $49 resistance. }
  TItem = class(TAbilityOwner)
  public
    FItemID: Integer; { $14 }
    FOwnerName: string; { $18 }
    FStatus: TItemStatus; { $1C }
    F_Item_1D: array[0..2] of Byte;
    FRefCount: Integer; { $20 }
    FLibraryID: Integer; { $24 }
    FLibraryName: string; { $28 }
    FObtainValue: Integer; { $2C }
    FName: string; { $30 }
    FItemType: TItemType;  { $34 }
    F_Item_35: array[0..2] of Byte;
    FSpellID: Integer; { $38 }
    FDescription: TStringList; { $3C }
    FItemGFXIndex: Integer; { $40 }
    FHidden: Boolean; { $44 }
    FAvailability: TItemAvailability; { $45 }
    FAttack: Shortint;  { $46 }
    FDefense: Shortint;  { $47 }
    FDamage: Shortint;  { $48 }
    FResistance: Shortint;  { $49 }
    F_Item_4A: array[0..1] of Byte;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    procedure SetArrayOwner(AOwner: Engine.TECustomNode; Index: Integer); override;
    function GetOwnerName: string; override;
    function GetAbilitySelectionTypes: TAbilitySelectionTypes; override;
    procedure Changed; override;
    function CanUse(Hero: THero; var Reason: string): Boolean; virtual; { $09C }
    function Use(Hero: THero): Boolean; virtual; { $0A0 }
    function ExecuteUse(Hero: THero): Boolean; virtual; { $A4 }
    procedure Show(X, Y: Integer; const Surface: TSurfaceDesc); virtual; { $A8 }
    procedure Activate; virtual;  { +0AC draft }
    procedure Deactivate; virtual;  { +0B0 draft }
    procedure GetLocation(var X, Y, L: Shortint);
    function GetCampaignTransferPoints: Integer;
    function GetImage: TLibraryImage;
    function GetLibraryItem: Boolean;
    function GetLibraryName: string;
    procedure UpdateFromLibrary;  { draft }
    procedure SetItemGFXIndex(A1: Integer);  { draft }
    procedure SetItemType(Value: TItemType);
    function GetObtainValue: Integer;
    function PlaceOnMap(Map: TAoWHSMap; X, Y, L: Shortint): Boolean;
    procedure EditDropMsg(var Msg: TItemDropMsg);
  end;

  { TItemList (instance size $18): inherited $08 children, $0C update lock;
    $10..$17 change event. }
  TItemList = class(TEChangeNotifyNode)
  public
    FOnChanged: TNotifyEvent; { $10 code, $14 data }
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed; override;
    function GetItem(Index: Integer): TItem; virtual;
    procedure GetLocation(var X, Y, L: Shortint); virtual;
    function FindItem(ItemID: Integer): TItem;
    procedure Update;
    procedure SortOnName;
    procedure SortOnType;
    procedure RegisterItems;
    procedure LockChanged;
    procedure UnlockChanged;
  end;

  { TItemLibrary (instance size 32, VMT 5570FD34) }
  TItemLibrary = class(TItemList)
  public
    F_ItemLibrary_18: Integer;
    F_ItemLibrary_1C: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure GetName(A1: Integer); virtual;  { +094 draft }
    procedure CreateUniqueLibraryID;  { draft }
    procedure FindLibraryID(A1: Integer);  { draft }
    procedure CreateItem;  { draft }
    procedure LoadFromFile;  { draft }
    procedure SaveToFile;  { draft }
  end;

  { TItemLibraryManager (instance size 16, VMT 5570FE50) }
  TItemLibraryManager = class(TEObject)
  public
    F_ItemLibraryManager_08: Integer;
    F_ItemLibraryManager_0C: Integer;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetLibrary(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    procedure ReadUserLibraries;  { draft }
    procedure WriteUserLibraries;  { draft }
    procedure IndexOfLibraryName(A1: Integer);  { draft }
    procedure IndexOfLibrary;  { draft }
    function FindItem(const LibraryName: string; LibraryID: Integer): TItem;
    procedure CreateLibrary(A1: Integer);  { draft }
    procedure DeleteLibrary(A1: Integer);  { draft }
  end;

  { TItemControl (instance size 32, VMT 5570FF60) }
  TItemControl = class(TEObject)
  public
    F_ItemControl_08: Integer;
    F_ItemControl_0C: Integer;
    F_ItemControl_10: Integer;
    F_ItemControl_14: Integer;
    F_ItemControl_18: Integer;
    F_ItemControl_1C: Byte;
    F_ItemControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetItem(A1: Integer);  { draft }
    procedure GetCount;  { draft }
    function FindItem(ItemID: Integer): TItem;
    procedure ItemChanged(Item: TItem);
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure CreateUniqueID;  { draft }
    procedure ValidateItem(A1: Integer);  { draft }
    procedure UpdateLibraryItems;  { draft }
    procedure RegisterItem(Item: TItem);
    procedure UnRegisterItem(Item: TItem);
    function GenerateItem(Types: TItemTypes; MinValue, MaxValue: Integer): TItem;
    procedure GenerateItems(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
  end;

  { TItemHSList (instance size 24, VMT 55710020) }
  TItemHSList = class(TItemList)
  public
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(var X, Y, L: Shortint); override;
  end;

  { TItemHS (instance size 20, VMT 55710178) }
  TItemHS = class(TSingleHS)
  public
    FItems: TItemHSList; { $0C }
    F_ItemHS_10: Byte;
    F_ItemHS_11: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    procedure Activate; override;
    procedure Deactivate; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function EditName: string; override;
    function CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure ItemsChanged;  { draft }
    procedure GenerateItems;  { draft }
  end;

