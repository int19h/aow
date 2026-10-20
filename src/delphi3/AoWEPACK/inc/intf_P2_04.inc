{ Interface declaration run owned by P2. }
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
    procedure GetItemImage;  { draft }
  end;

  { TItemGFXList (instance size 20, VMT 5570F8C0) }
  TItemGFXList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure GetItemGFX(A1: Integer);  { draft }
    procedure FindItemTypeGFX(A1: Byte);  { draft }
  end;

  { TItemTE (instance size 28, VMT 5570F9F0) }
  TItemTE = class(TTokenEvent)
  public
    F_ItemTE_10: Integer;
    F_ItemTE_14: Byte;
    F_ItemTE_15: array[0..2] of Byte;
    F_ItemTE_18: Integer;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    class function ClassID: Integer; override;
    function Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult; override;
  end;

  { TItem (instance size 76, VMT 5570FAFC) }
  TItem = class(TAbilityOwner)
  public
    FHeroID: Integer; { $14 }
    F_Item_18: Integer;
    F_Item_1C: Byte;
    F_Item_1D: array[0..2] of Byte;
    F_Item_20: Integer;
    F_Item_24: Integer;
    F_Item_28: Integer;
    F_Item_2C: Integer;
    F_Item_30: Integer;
    F_Item_34: Byte;
    F_Item_35: array[0..2] of Byte;
    F_Item_38: Integer;
    F_Item_3C: Integer;
    F_Item_40: Integer;
    F_Item_44: Byte;
    F_Item_45: Byte;
    F_Item_46: Byte;
    F_Item_47: Byte;
    F_Item_48: Byte;
    F_Item_49: Byte;
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
    procedure CanUse(A1: Integer; A2: Integer); virtual;  { +09C draft }
    procedure Use(A1: Integer); virtual;  { +0A0 draft }
    procedure ExecuteUse(A1: Integer); virtual;  { +0A4 draft }
    procedure Show(A1: Integer; A2: Integer; A3: Integer); virtual;  { +0A8 draft }
    procedure Activate; virtual;  { +0AC draft }
    procedure Deactivate; virtual;  { +0B0 draft }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer);  { draft }
    function GetCampaignTransferPoints: Integer;
    procedure GetImage;  { draft }
    procedure GetLibraryItem;  { draft }
    procedure GetLibraryName(A1: Integer);  { draft }
    procedure UpdateFromLibrary;  { draft }
    procedure SetItemGFXIndex(A1: Integer);  { draft }
    procedure SetItemType(A1: Integer);  { draft }
    procedure GetObtainValue;  { draft }
    function PlaceOnMap(Map: TAoWHSMap; X, Y, L: Shortint): Boolean;
    procedure EditDropMsg(A1: Integer);  { draft }
  end;

  { TItemList (instance size 24, VMT 5570FC34) }
  TItemList = class(TEChangeNotifyNode)
  public
    F_ItemList_10: Byte;
    F_ItemList_11: array[0..0] of Byte;
    F_ItemList_12: Word;
    F_ItemList_14: Integer;
    procedure MainReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: Engine.TEObject): Integer; override;
    function AddChild(Child: Engine.TEObject): Integer; override;
    procedure Changed; override;
    function GetItem(A1: Integer): TItem; virtual; { $8C }
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); virtual;  { +090 draft }
    procedure FindItem(A1: Integer; A2: Integer);  { draft }
    procedure Update;  { draft }
    procedure SortOnName;  { draft }
    procedure SortOnType;  { draft }
    procedure RegisterItems;  { draft }
    procedure LockChanged;  { draft }
    procedure UnlockChanged;  { draft }
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
    procedure FindItem(A1: Integer; A2: Integer);  { draft }
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
    procedure FindItem(A1: Integer);  { draft }
    procedure ItemChanged;  { draft }
    procedure Changed;  { draft }
    procedure BeginUpdate;  { draft }
    procedure EndUpdate;  { draft }
    procedure CreateUniqueID;  { draft }
    procedure ValidateItem(A1: Integer);  { draft }
    procedure UpdateLibraryItems;  { draft }
    procedure RegisterItem(Item: TItem);
    procedure UnRegisterItem(A1: Integer);  { draft }
    procedure GenerateItem(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure GenerateItems(A1: Byte; A2: Integer; A3: Integer);  { draft }
    procedure Activate;  { draft }
    procedure Deactivate;  { draft }
  end;

  { TItemHSList (instance size 24, VMT 55710020) }
  TItemHSList = class(TItemList)
  public
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure GetLocation(A1: Integer; A2: Integer; A3: Integer); override;
  end;

  { TItemHS (instance size 20, VMT 55710178) }
  TItemHS = class(TSingleHS)
  public
    F_ItemHS_0C: Integer;
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

