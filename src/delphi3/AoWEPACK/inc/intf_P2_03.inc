{ Interface declaration run owned by P2. }
  { TUnitGFXResource (instance size 72, VMT 5570EA70) }
  TUnitGFXResource = class(TEResource)
  public
    F_UnitGFXResource_18: Integer;
    F_UnitGFXResource_1C: Integer;
    F_UnitGFXResource_20: Integer;
    F_UnitGFXResource_24: Integer;
    FSequences: TImageSequenceList;
    F_UnitGFXResource_2C: Integer;
    F_UnitGFXResource_30: Byte;
    F_UnitGFXResource_31: array[0..2] of Byte;
    F_UnitGFXResource_34: Integer;
    F_UnitGFXResource_38: Integer;
    F_UnitGFXResource_3C: Integer;
    F_UnitGFXResource_40: Integer;
    F_UnitGFXResource_44: Integer;
    destructor Destroy; override;
    function GetEngine: Engine.TEngine; override;
    procedure ReadWrite(Stream: Engine.TEStorageStream); override;
    constructor Create(AOwner: Engine.TECustomNode); override;
    class function ClassID: Integer; override;
    function AddRef: Integer; override;
    function Release: Integer; override;
    procedure MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); override;
    function GetCellImage: ImageLib.TLibraryImage; override;
    procedure LinkToIL;  { draft }
    procedure ReleaseIL;  { draft }
    procedure SetFaceImageLibraryName(A1: Integer; A2: Integer);  { draft }
    function GetFaceImage: TLibraryImage;
    procedure Show(Direction,X,Y: Integer; const SD: TSurfaceDesc);
    procedure GetIndex;  { draft }
  end;

  { TUnitGFXResourceList (instance size 20, VMT 5570EB68) }
  TUnitGFXResourceList = class(TEResourceList)
  public
    constructor Create(AOwner: Engine.TECustomNode); override;
    function GetUnitGFXResource(Index: Integer): TUnitGFXResource;
    procedure CreateUnitGFXSelectionList(A1: Integer; A2: Integer);  { draft }
  end;

  { TAoWMapObjectEditor (instance size 8, VMT 5570EC78) }
  TAoWMapObjectEditor = class(TEObjectEditor)
  public
    class function EditorClassID: Integer; override;
  end;

  { TUnitShadowHS (instance size 12, VMT 5570ED54) }
  TUnitShadowHS = class(THexagonSprite)
  public
    F_UnitShadowHS_08: Byte;
    F_UnitShadowHS_09: array[0..2] of Byte;
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
    procedure ShowShadow(A1: Integer; A2: Integer; A3: Integer); virtual;  { +114 draft }
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

