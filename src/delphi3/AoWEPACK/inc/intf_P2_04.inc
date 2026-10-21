{ Interface declaration run owned by P2. }
  { Editor drop message, size $30: screen X/Y at $18/$1C, level at $20, result at $2C. }
  TItemDropMsg = record
    MsgID, Seq: Integer;
    Sender: TEObject;
    Param: array[0..2] of Integer;
    Xhp, Yhp, Lhp, Reserved0, Reserved1, Result: Integer;
  end;
  { TItemGFX (instance size $30): $18 library name, $1C image index,
    $20 item type, $24 library, $28 references, $2C hidden. }
  TItemGFX = class(TEResource)
  public
    FImageLibraryName: string; { $18 }
    FImageIndex: Integer; { $1C }
    FItemType: TItemType; { $20 }
    F_ItemGFX_21: array[0..2] of Byte;
    FImageLibrary: TCustomImageLibrary; { $24 }
    FRefCount: Integer; { $28 }
    FHidden: Boolean; { $2C }
    F_ItemGFX_2D: array[0..2] of Byte;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    function ItemGFXIndex: Integer;
    procedure LinkToIL;
    procedure ReleaseIL;
    procedure SetImageLibraryName(Value: string);
    function GetItemImage: TLibraryImage;
  end;

  { TItemGFXList (instance size $14): inherited $08 children, $0C engine, $10 control style. }
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

  { TItemLibrary (instance size $20): $18 name, $1C last library ID. }
  TItemLibrary = class(TItemList)
  public
    FName: string; { $18 }
    FLastID: Integer; { $1C }
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    function GetName: string; virtual; { $94 }
    function CreateUniqueLibraryID: Integer;
    function FindLibraryID(LibraryID: Integer): TItem;
    function CreateItem: TItem;
    procedure LoadFromFile(const FileName: string);
    procedure SaveToFile(const FileName: string);
  end;

  { TItemLibraryManager (instance size $10): $08 system library, $0C libraries. }
  TItemLibraryManager = class(TEObject)
  public
    FSystemLibrary: TItemLibrary; { $08 }
    FLibraries: TENode; { $0C }
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetLibrary(Index: Integer): TItemLibrary;
    function GetCount: Integer;
    procedure ReadUserLibraries;
    procedure WriteUserLibraries;
    function IndexOfLibraryName(const Name: string): Integer;
    function IndexOfLibrary(ItemLibrary: TItemLibrary): Integer;
    function FindItem(const LibraryName: string; LibraryID: Integer): TItem;
    function CreateLibrary(const Name: string): TItemLibrary;
    procedure DeleteLibrary(Index: Integer);
  end;

  { TItemControl (instance size $20): $08 items, $0C change events,
    $10 update lock, $14 item change events, $18 last ID, $1C status. }
  TItemControl = class(TEObject)
  public
    FItems: TList; { $08 }
    FOnChanged: TEventList; { $0C }
    FUpdateLock: Integer; { $10 }
    FOnItemChanged: TEventList; { $14 }
    FLastID: Integer; { $18 }
    FStatus: TItemControlStatus; { $1C }
    F_ItemControl_1D: array[0..2] of Byte;
    destructor Destroy; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetItem(Index: Integer): TItem;
    function GetCount: Integer;
    function FindItem(ItemID: Integer): TItem;
    procedure ItemChanged(Item: TItem);
    procedure Changed;
    procedure BeginUpdate;
    procedure EndUpdate;
    function CreateUniqueID: Integer;
    procedure ValidateItem(Item: TItem);
    procedure UpdateLibraryItems;
    procedure RegisterItem(Item: TItem);
    procedure UnRegisterItem(Item: TItem);
    function GenerateItem(Types: TItemTypes; MinValue, MaxValue: Integer): TItem;
    function GenerateItems(Types: TItemTypes; Owner: TECustomNode; Value: Integer): Integer;
    procedure Activate;
    procedure Deactivate;
  end;

  { TItemHSList (instance size $18): inherited $08 children, $0C update lock, $10 change event. }
  TItemHSList = class(TItemList)
  public
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(var X, Y, L: Shortint); override;
  end;

  { TItemHS (instance size $14): $0C items, $10 generation mode. }
  TItemHS = class(TSingleHS)
  public
    FItems: TItemHSList; { $0C }
    FGenerateMode: TItemGenerateMode; { $10 }
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
    procedure ItemsChanged(Sender: TObject);
    procedure GenerateItems;
  end;

