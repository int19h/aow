{ Interface declaration run owned by P2. }
  { TUnitGFXResource (instance size 72, VMT 5570EA70): +18 FName; +1C FFaceIndex;
    +20 FFaceImageLibrary; +24 FFaceImageLibraryName; +28 FSequences; +2C FRefCount;
    +30 flags; +34..44 FSFXLibraries. }
  TUnitGFXResource = class(TEResource)
  public
    FName: string;  { $18 }
    FFaceIndex: Integer;  { $1C }
    FFaceImageLibrary: TCustomImageLibrary;  { $20 }
    FFaceImageLibraryName: string;  { $24 }
    FSequences: TImageSequenceList;
    FRefCount: Integer;  { $2C }
    F_UnitGFXResource_30: Byte;
    F_UnitGFXResource_31: array[0..2] of Byte;
    FSFXLibraries: array[0..4] of TSFXLibrary;  { $34..$44 }
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure LinkToIL;
    procedure ReleaseIL;
    procedure SetFaceImageLibraryName(Value: string);
    function GetFaceImage: TLibraryImage;
    procedure Show(Direction,X,Y: Integer; const SD: TSurfaceDesc);
    function GetIndex: Integer;
  end;

  { TUnitGFXResourceList (instance size 20, VMT 5570EB68) }
  TUnitGFXResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetUnitGFXResource(Index: Integer): TUnitGFXResource;
    procedure CreateUnitGFXSelectionList(List: TStrings);
  end;

  { TAoWMapObjectEditor (instance size 8, VMT 5570EC78) }
  TAoWMapObjectEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
  end;

  { TUnitShadowHS (instance size 12, VMT 5570ED54): +08 FUnitHS. }
  TUnitShadowHS = class(THexagonSprite)
  public
    FUnitHS: TUnitHS;  { $08 }
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
  end;

  { TUnitHS (instance size 28, VMT 5570EED0) }
  TUnitHS = class(THexagonSprite)
  public
    F_UnitHS_08: Byte;
    F_UnitHS_09: array[0..2] of Byte;
    F_UnitHS_0C: Integer;
    F_UnitHS_10: Integer;
    F_UnitHS_14: Byte;
    F_UnitHS_15: Byte;
    F_UnitHS_16: Byte;
    F_UnitHS_17: array[0..0] of Byte;
    F_UnitHS_18: Integer;
    destructor Destroy; override;
    procedure SetOwner(AOwner: Engine.TECustomNode); override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    procedure TimerEvent(Tick: Integer; Sender: Engine.TEObject); override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetSelected: Boolean; override;
    function GetXhx: Shortint; override;
    function GetYhx: Shortint; override;
    function GetLhx: Shortint; override;
    function GetEditMode: Boolean; override;
    procedure SetEditMode(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure TerrainChanged(const Info: HSEngine.THSTerrainInfo); override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    function Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    procedure MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); override;
    function CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure UpdateMapField(const Info: HSEngine.THSMapFieldInfo); override;
    procedure MakeVisible(VisibilityList: HSEngine.TVisibilityList); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    procedure CalcShowPriority; virtual;  { +108 draft }
    procedure MoveTo(A1: Integer; A2: Integer); virtual;  { +10C draft }
    procedure PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer); virtual;  { +110 draft }
    procedure ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc); virtual;
    procedure UpdateFlagID; virtual;  { +118 draft }
    procedure MoveFirst(A1: Integer; A2: Integer); virtual;  { +11C draft }
    function GetMoveSteps: Integer; virtual;  { +120 draft }
    procedure CreateShadow;  { draft }
    procedure DestroyShadow;  { draft }
    procedure GetUnitGFXResourceIndex;  { draft }
    procedure SetUnitGFXResourceIndex(A1: Integer);  { draft }
    procedure SetDirection(A1: Integer);  { draft }
    procedure GetMoveStatus;  { draft }
    procedure SetMoveStatus(A1: Integer);  { draft }
    procedure MoveNext;  { draft }
    procedure Moving;  { draft }
    procedure PauseMove;  { draft }
    procedure CancelMove;  { draft }
  end;

