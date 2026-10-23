unit HSEngine;

{ The HSEngine unit of HSEPack.dpl (the hexagon map engine of Age of Wonders: maps, levels, fields,
  hexagon sprites, map objects and their resources, the hex coordinate routines) written for the
  original compiler (Delphi 3.02), class by class: tools/match.py compares the code DCC32 generates
  for every method with the code in the game's module. Declarations follow the original instance
  layouts and VMT orders (notes/classes.json). As in the original (D:\GEngine\HSENGINE\), the code
  of the sprites, the map objects, the map and the library image sprites sits in the include files
  inc\HXSPRITE.PAS, inc\MAPOBJ.PAS, inc\HSMAP.PAS and inc\LibImgHS.PAS, whose names the Assert
  calls carry; their line numbers count through the includes, so the line layout is kept. }

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, Menus, StdCtrls,
  ExtCtrls, GFXE, Engine, ImageLib, {$IFNDEF RUNTIME_PACKAGES} DisplayC, {$ENDIF} Sound;

type
  PInteger = ^Integer;

  TWalkAroundRouteCallBack = function(X: Integer; Y: Integer; var Cancel: Boolean): Boolean of object;

resourcestring
  TerrainStr = 'Terrain';
  BridgeStr = 'Bridge';
  UpperIsometricHexagonStr = 'Upper Isometric Hexagon';
  LowerIsometricHexagonStr = 'Lower Isometric Hexagon';
  InvalidPlaceMentStr = 'Invalid Placement';
  HexagonStr = 'Hexagon';
  SelectedStr = 'selected';
  TransparentStr = 'Transparent';
  LoadingStr = 'Loading';
  ClosingStr = 'Closing';
  SaveChangesToXStr = 'Save changes to %s';
  OneMomentPleaseStr = 'One moment please...';
  CutStr = 'Cu&t';
  PasteStr = '&Paste';
  DeleteStr = '&Delete';
  CopyStr = '&Copy';
  EditStr = '&Edit';

type
  { forward declarations: the classes that the declarations below use before their own
    declaration (the type infos and VMTs of the original follow the declaration order of the
    complete types) }
  TMapField = class;
  TMapContainer = class;
  TVisibilityList = class;
  THSMap = class;
  THSEngine = class;
  THexagonSprite = class;
  TMapObject = class;
  TMapObjectResource = class;
  TMapObjectResourceList = class;

  THSMID = array[0..3] of Char;

  { A map location: hexagon column X, row Y, map level L and a flag byte (LocationsConnected
    marks the locations it has reached with it); the items of TXYLList, made by PackXYL }
  TXYL = packed record
    case Integer of
      0: (X: Shortint;
          Y: Shortint;
          L: Shortint;
          Flag: Shortint);
      1: (XY: Word);
      2: (XYL: Integer);
  end;

  { a column and row offset (HNtoXYTable) }
  XYTableEntry = record
    X: Integer;
    Y: Integer;
  end;

  { State of a walk around a centre hexagon (InitHNWalk, WalkToNextHN): the hexagon numbers
    ring after ring, 6 * Radius hexagons on ring Radius }
  THNWalkData = record
    Side: Integer;     { +00 side of the ring (0..5) }
    Step: Integer;     { +04 step on the side }
    HN: Integer;       { +08 hexagon number of X, Y }
    Radius: Integer;   { +0C }
    X: Integer;        { +10 }
    Y: Integer;        { +14 }
    CenterX: Integer;  { +18 the centre }
    CenterY: Integer;  { +1C }
  end;

  { TNewHSMapSettings (instance size 32): the parameters of a new map (THSMap.CreateNewMap) }
  TNewHSMapSettings = class(TObject)
  public
    Width: Integer;                { +04 }
    Height: Integer;               { +08 }
    Levels: Integer;               { +0C }
    HSSFileName: string;           { +10 }
    HSMapClassID: Integer;         { +14 }
    MapContainerClassID: Integer;  { +18 }
    MapLevelClassID: Integer;      { +1C }
    constructor Create;
  end;

  TTerrainCompareMode = set of (cmSameOverlayType, cmSameTerrainType);

  { TTerrainList (instance size 12): terrain and overlay types by hexagon number, two bytes per
    hexagon (terrain type, overlay type; -2: none) }
  TTerrainList = class(TObject)
  private
    FCount: Integer;  { +04 }
    FList: PChar;     { +08 }
  public
    destructor Destroy; override;
    procedure Assign(Source: TTerrainList); virtual;
    procedure LoadFromStream(Stream: TStream); virtual;
    procedure SaveToStream(Stream: TStream); virtual;
    function GetTerrain(Index: Integer): Shortint;
    procedure SetTerrain(Index: Integer; Value: Shortint);
    procedure SetCount(NewCount: Integer);
    function GetOverlay(Index: Integer): Shortint;
    procedure SetOverlay(Index: Integer; Value: Shortint);
    function GetTandO(Index: Integer): Word;
    procedure SetTandO(Index: Integer; Value: Word);
    function GetUsed(Index: Integer): Boolean;
    function UsedTerrain: Integer;
    function UsedOverlays: Integer;
    procedure Pack;
    function CreateSurroundingHNTable: TWordList;
    function CompareTerrain(List: TTerrainList; Mode: TTerrainCompareMode): Boolean;
    property Count: Integer read FCount write SetCount;
    property Terrain[Index: Integer]: Shortint read GetTerrain write SetTerrain;
    property Overlay[Index: Integer]: Shortint read GetOverlay write SetOverlay;
    property TandO[Index: Integer]: Word read GetTandO write SetTandO;
    property Used[Index: Integer]: Boolean read GetUsed;
  end;
  TMapFieldStatus = set of (msTerrainLocked, msVisible, msLoading, msComparing);

  { The sprites of a map field: FCapacity sprite pointers followed by FCapacity HN bytes (the
    hexagon number of each sprite on the field), in one block (TMapField.HSListDataSize). }
  PHSList = ^THSList;
  THSList = array[0..255] of THexagonSprite;
  PHNList = ^THNList;
  THNList = array[0..255] of Byte;

  { The records a map field passes by reference to the methods of its sprites. }

  { THexagonSprite.UpdateMapField (8 bytes) }
  THSMapFieldInfo = record
    MapField: TMapField;
    HN: Shortint;
  end;

  { THexagonSprite.CanChangeTerrain, CanMoveOver, MoveExclusive (12 bytes): Sender is the object
    that asks (the sprite that changes the terrain, the mover) }
  THSSenderInfo = record
    Sender: TObject;
    MapField: TMapField;
    HN: Shortint;
  end;

  { THexagonSprite.ChangeTerrain, TerrainChanged, NeighbourTerrainChanged (12 bytes) }
  THSTerrainInfo = record
    TerrainType: Shortint;
    OverlayType: Shortint;
    MapField: TMapField;
    HN: Shortint;
  end;

  { THexagonSprite.CanMoveOn (16 and 12 bytes) }
  THSMoveOnInfo = record
    Sender: TObject;
    MapField: TMapField;
    MoveOverCode: Integer;
    HN: Shortint;
  end;
  THSMoveOnResult = record
    Code: Integer;
    Data: Integer;
    Done: Boolean;
  end;

  { THexagonSprite.MapFieldMsgProc (32 bytes): TMapField.SendMapFieldMsg sets MapField and, for
    every sprite, HN; it stops when a sprite changes Result. MsgID $10 asks the sprites to place
    themselves again, $11 (GetDecorationType) asks for the decoration type. }
  PMapFieldMsg = ^TMapFieldMsg;
  TMapFieldMsg = record
    MsgID: Integer;
    MapField: TMapField;
    Param: array[0..3] of Integer;
    HN: Integer;
    Result: Integer;
  end;

  { HSEngine.TMapField (instance size 24): +8 FHSList, +$C FCapacity, +$D FCount, +$E
    FStaticCount, +$F FStatus, +$10 FXhx, +$11 FYhx, +$12 FLhx, +$13 FReserved, +$14 FTerrainType,
    +$15 FOverlayType. A hexagon field of a map level. The fields of a level sit in one block that
    TMapLevel.CreateMapFieldList allocates: NewInstance takes the address from MapFieldMemory and
    FreeInstance frees nothing. The sprites are sorted by their show priority; the first
    FStaticCount (priority shr 26 <= 15) are the static ones. }
  TMapField = class(TECustomNode)
  private
    FHSList: PHSList;
    FCapacity: Byte;
    FCount: Byte;
    FStaticCount: Byte;
    FStatus: TMapFieldStatus;
    FXhx: Shortint;
    FYhx: Shortint;
    FLhx: Shortint;
    FReserved: Byte;
    FTerrainType: Shortint;
    FOverlayType: Shortint;
  public
    class function NewInstance: TObject; override;
    procedure FreeInstance; override;
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    procedure SetOwner(AOwner: TECustomNode); override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure MainReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function GetCount: Integer; override;
    procedure SendMsg(var Msg: TEMsg; Sender: TEObject); override;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    function FindChild(AClassID: Integer): TEObject; override;
    function FindOwnedChild(AClassID: Integer): TEObject; override;
    procedure UpdateMapField; virtual;
    function GetXYL: Integer;
    function HSListDataSize: Integer;
    function GetHN(Index: Integer): Byte;
    procedure SetHN(Index: Integer; Value: Byte);
    procedure Resize(NewCapacity: Byte);
    procedure Sort;
    function AddHS(HS: THexagonSprite; HN: Integer): Integer;
    function RemoveHS(HS: THexagonSprite): Integer;
    procedure Remove(Index: Integer);
    function FindHS(AClass: TClass): THexagonSprite;
    function FindOwnedHS(AClass: TClass): THexagonSprite;
    function FindNoneTransparentHS(AClass: TClass): THexagonSprite;
    function FindNoneTransparentHSCID(AClassID: Integer): THexagonSprite;
    procedure SendMapFieldMsg(var Msg: TMapFieldMsg);
    procedure CopyDynamicVisibleHS(List: TVisibilityList);
    procedure CopyStaticVisibleHS(List: TVisibilityList);
    procedure ResetDynamicVisibleHS;
    procedure ResetStaticVisibleHS;
    procedure DestroyLevelHS(MinLevel: Integer; MaxLevel: Integer);
    procedure DestroyHS;
    procedure Activate;
    procedure Loaded;
    function CanChangeTerrainEx(Sender: TEObject): Boolean;
    function CanChangeTerrain(Sender: TEObject; TerrainType: Shortint; OverlayType: Shortint): Boolean;
    procedure TerrainChanged;
    procedure UpdateTerrainType;
    procedure UpdateOverlayType;
    procedure UpdateTerrain;
    procedure NeighbourTerrainChanged(var Info: THSTerrainInfo);
    function GetDecorationType: Shortint;
    procedure UpdateNeighbourTerrain;
    procedure Initialize;
    function CanMoveOn(Sender: TObject; DefaultCode: Integer; MoveOverCode: Integer): Integer;
    function CanMoveOver(Sender: TObject): Integer;
    procedure MoveExclusive(Sender: TObject);
    function GetMaxLevelNoneTransparentHS: THexagonSprite;
    function GetMaxLevelTerrainHS: THexagonSprite;
    function GetMaxLevelOverlayHS: THexagonSprite;
    function SetHNofHS(HS: THexagonSprite; HN: Byte): Integer;
    function GetHNofHS(HS: THexagonSprite): Integer;
    property HSList: PHSList read FHSList;
    property Capacity: Byte read FCapacity;
    property StaticCount: Byte read FStaticCount;
    property Status: TMapFieldStatus read FStatus write FStatus;
    property Xhx: Shortint read FXhx write FXhx;
    property Yhx: Shortint read FYhx write FYhx;
    property Lhx: Shortint read FLhx write FLhx;
    property XYL: Integer read GetXYL;
    property TerrainType: Shortint read FTerrainType write FTerrainType;
    property OverlayType: Shortint read FOverlayType write FOverlayType;
    property HN[Index: Integer]: Byte read GetHN write SetHN;
  end;

  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array[0..MaxInt div 4 - 1] of Integer;

  { HSEngine.TMapLevel (instance size 124): +8 FLhx, +$C FWidth, +$10 FHeight, +$14 FCount, +$18
    FMapContainer, +$1C FMap, +$20 FEngine, +$24 FMapFieldCID, +$28 FFieldSize, +$2C FFields, +$30
    FFieldsSize, +$34 FHNOffsets, +$74 FXOffsets, +$78 FYOffsets. One level of the map: the
    FWidth * FHeight fields lie row by row in the block FFields (FFieldSize bytes each, the instance
    size of MapFieldClass); field (X, Y) is at FYOffsets[Y] + FXOffsets[X], its neighbour in
    direction HN (1..6) FHNOffsets[X and 1, HN] bytes from it. The fields are the children. }
  TMapLevel = class(TECustomNode)
  protected
    FLhx: Integer;
    FWidth: Integer;
    FHeight: Integer;
    FCount: Integer;
    FMapContainer: TMapContainer;
    FMap: THSMap;
    FEngine: TEngine;
    FMapFieldCID: Integer;
    FFieldSize: Integer;
    FFields: Pointer;
    FFieldsSize: Integer;
  public FHNOffsets: array[0..1, 0..7] of Integer; protected { $74/$78 inherited access: AoWE 55772161/55772167. }
    FXOffsets: PIntegerArray;
    FYOffsets: PIntegerArray;
  public
    destructor Destroy; override;
    function GetEngine: TEngine; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function GetCount: Integer; override;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    procedure New(Settings: TNewHSMapSettings); virtual;
    function MapFieldClass: TEObjectClass; virtual;
    function GetField(X: Integer; Y: Integer): TMapField;
    procedure CreateMapFieldList(AWidth: Integer; AHeight: Integer);
    procedure DestroyMapFieldList;
    procedure DestroyHS;
    procedure UpdateTerrain;
    procedure Loaded;
    procedure Activate;
    property Lhx: Integer read FLhx write FLhx;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property MapContainer: TMapContainer read FMapContainer;
    property Map: THSMap read FMap;
    property MapFieldCID: Integer read FMapFieldCID write FMapFieldCID;
    property FieldSize: Integer read FFieldSize;
    property Fields: Pointer read FFields;
    property Field[X: Integer; Y: Integer]: TMapField read GetField;
  end;

  { HSEngine.TMapContainer (instance size 32): +$C FWidth, +$10 FHeight, +$14 FLevelCount, +$18
    FMap, +$1C FEngine. The levels of a map (the children, TMapLevel). }
  TMapContainer = class(TENode)
  private
    FWidth: Integer;
    FHeight: Integer;
    FLevelCount: Integer;
    FMap: THSMap;
    FEngine: TEngine;
  public
    procedure SetOwner(AOwner: TECustomNode); override;
    function GetEngine: TEngine; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure MainReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    procedure RemoveLevel(Index: Integer); virtual;
    function AddLevel(AClassID: Integer): Boolean; virtual;
    procedure New(Settings: TNewHSMapSettings); virtual;
    procedure UpdateTerrain; virtual;
    function GetMapLevel(Index: Integer): TMapLevel;
    function GetFieldXYL(XYL: Integer): TMapField;
    function GetField(X: Integer; Y: Integer; L: Integer): TMapField;
    procedure RemoveHS(X: Integer; Y: Integer; L: Integer; HS: THexagonSprite);
    procedure InsertHS(X: Integer; Y: Integer; L: Integer; HS: THexagonSprite; HN: Integer);
    procedure Loaded;
    procedure Activate;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
    property LevelCount: Integer read FLevelCount;
    property Map: THSMap read FMap;
    property MapLevels[Index: Integer]: TMapLevel read GetMapLevel;
  end;

  { HSEngine.TVisibilityList (instance size 28): the sorted list of the visible sprites of a
    scene (THSMap); a sprite removed from it is made invisible. }
  TVisibilityList = class(TEControlStyleInverseSortNode)
  public
    procedure QuickClear; override;
    function RemoveChild(Child: TEObject): Integer; override;
    procedure Grow; override;
  end;
  { HSEngine.THexagonSpriteSelection (instance size 32): the selected sprites of a map. The
    children (TENode.FChildren, +8) are every selected sprite; +$10 FLocationHS the sprites
    selected by location (clicking on a hexagon), +$14 FOnSelect, +$18 FOnDeselect (triggered with
    the map as the sender), +$1C FEventHS the sprite of the last event. The owner is the map. }
  THexagonSpriteSelection = class(TEControlStyleNode)
  private
    FLocationHS: TList;
    FOnSelect: TEventList;
    FOnDeselect: TEventList;
    FEventHS: THexagonSprite;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure TriggerDeselectEvent(HS: THexagonSprite);
    procedure TriggerSelectEvent(HS: THexagonSprite);
    procedure Unselect(HS: THexagonSprite);
    procedure Select(HS: THexagonSprite);
    procedure UnselectAll;
    function FindClass(AClass: TClass): THexagonSprite;
    function GetHS(Index: Integer): THexagonSprite;
    function CanSelectLocation(Xhp, Yhp, Lhp: Integer): Boolean;
    procedure SelectLocationHS(HS: THexagonSprite);
    procedure SelectLocation(Xhp, Yhp, Lhp: Integer);
    procedure SelectLocationHX(Xhx, Yhx, Lhx: Integer);
    procedure UnselectLocation;
    function FindLocationHSIndex(MapF: TMapField): Integer;
    property HS[Index: Integer]: THexagonSprite read GetHS;
    property LocationHS: TList read FLocationHS;
    property OnSelect: TEventList read FOnSelect;
    property OnDeselect: TEventList read FOnDeselect;
    property EventHS: THexagonSprite read FEventHS;
  end;

  TMouseStatus = set of (msChangingCapture);

  { HSEngine.THSMapMouse (instance size 60): the mouse of a map. +4 FHSMap, +8 FX, +$C FY (the
    position in the view port in pixels, Low(Integer) when outside), +$10 FButton, +$14 FOnUp,
    +$18 FOnDown, +$1C FOnMove, +$20 FOnDblClick, +$24 FOnCaptureChanged, +$28 FCapture (the
    object that gets the mouse events), +$2C FStatus, +$30 FCursor, +$34 FCursorMode, +$38
    FIgnoreDown, +$39 FShift, +$3A FCursorVisible (+$34 and +$3A are used by the game only). }
  THSMapMouse = class(TObject)
  private
    FHSMap: THSMap;
    FX: Integer;
    FY: Integer;
    FButton: TMouseButton;
    FOnUp: TEventList;
    FOnDown: TEventList;
    FOnMove: TEventList;
    FOnDblClick: TEventList;
    FOnCaptureChanged: TEventList;
    FCapture: TObject;
    FStatus: TMouseStatus;
    FCursor: Integer;
    FCursorMode: Integer;
    FIgnoreDown: Boolean;
    FShift: TShiftState;
    FCursorVisible: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    function GetCursor: Integer; virtual;
    procedure SetCursor(Value: Integer); virtual;
    function MouseDown: Boolean; virtual;
    function MouseUp: Boolean; virtual;
    function MouseMove: Boolean; virtual;
    function MouseDblClick: Boolean; virtual;
    procedure Down(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure Up(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); virtual;
    procedure Move(Shift: TShiftState; X, Y: Integer); virtual;
    procedure DblClick; virtual;
    procedure Reset;
    function GetXhp: Integer;
    function GetYhp: Integer;
    function GetXhx: Integer;
    function GetYhx: Integer;
    procedure SetCapture(Value: TObject);
    property HSMap: THSMap read FHSMap;
    property X: Integer read FX;
    property Y: Integer read FY;
    property Xhp: Integer read GetXhp;
    property Yhp: Integer read GetYhp;
    property Xhx: Integer read GetXhx;
    property Yhx: Integer read GetYhx;
    property Button: TMouseButton read FButton;
    property Shift: TShiftState read FShift;
    property OnUp: TEventList read FOnUp;
    property OnDown: TEventList read FOnDown;
    property OnMove: TEventList read FOnMove;
    property OnDblClick: TEventList read FOnDblClick;
    property OnCaptureChanged: TEventList read FOnCaptureChanged;
    property Capture: TObject read FCapture write SetCapture;
    property Cursor: Integer read GetCursor write SetCursor;
    property CursorMode: Integer read FCursorMode write FCursorMode;
    property IgnoreDown: Boolean read FIgnoreDown write FIgnoreDown;
    property CursorVisible: Boolean read FCursorVisible write FCursorVisible;
  end;

  TCenterViewEvent = procedure(Xhx: Integer; Yhx: Integer; Lhx: Integer) of object;
  TChangeViewEvent = procedure(Xhp: Integer; Yhp: Integer; Lhp: Integer) of object;
  TViewLevelEvent = procedure(Lhx: Integer) of object;
  THSMapStatus = set of (msModified, msEditting, msActivated, msDestroying, msPreviewMode);
  TMapProgressType = (ptLoading, ptSaving, ptInitializing, ptUpdatingTerrain, ptActivating, ptDestroying);
  TChangeTerrainProc = procedure(MapF: TMapField; var TerrainType: Shortint; var OverlayType: Shortint) of object;
  TTerrainChangedProc = procedure(MapF: TMapField; OriginalTerrainType: Shortint; OriginalOverlayType: Shortint) of object;

  { The record of THSMap.NotifyProgress (TMapLevel.Loaded fills one): the kind, the percentage
    done of the level and the level index. }
  TMapProgress = record
    ProgressType: TMapProgressType;
    Percent: Integer;
    Level: Integer;
  end;

  { The sender of the terrain changed events (THSMap.TriggerTerrainChangedEvent): the changed
    rectangle of hexagons, the level and its TMapLevel. }
  PTerrainChangedInfo = ^TTerrainChangedInfo;
  TTerrainChangedInfo = record
    Rect: TRect;
    Level: Integer;
    MapLevel: TMapLevel;
  end;

  { HSEngine.THSMap (instance size 164): the map. +$C FMouse, +$10 FMapContainer, +$14 FEngine,
    +$18 FSelection, +$1C FStaticVisibleHS, +$20 FDynamicVisibleHS (the sprites in the view port),
    +$24 FStaticFixedVisibleHS, +$28 FDynamicFixedVisibleHS (sprites shown wherever the view is),
    +$2C FTimer, +$30 FStaticSceneInvalid, +$31 FDynamicSceneInvalid, +$34 FVersion, +$38
    FHSSFileName, +$3C FStatus, +$40 FFrame, +$44 FTerrainChangedEvents, +$48 FOnCenterView, +$50
    FOnChangeView, +$58 FOnViewLevel, +$60 FOnProgress, +$68 FTerrainChangedLockCounter, +$6C
    FNewFrameEvents, +$70 FViewPortChangedEvents, +$74 FDestroyEvents, +$78 FHSChangedEvents, +$7C
    FFileName, +$80 FViewXhp, +$84 FViewYhp, +$88 FViewL, +$8C FViewWidth, +$90 FViewHeight (the
    view port in pixels), +$94 FViewXhx, +$98 FViewYhx, +$9C FViewWidthHX, +$A0 FViewHeightHX (the
    hexagons it covers). Persisted (ReadWrite): 2 FHSSFileName (rwString, not in text streams),
    3 FVersion (rwByte of a Shortint copy), 4 FViewXhp, 5 FViewYhp, 6 FViewL (rwInteger).
    FVersion is a guessed name: nothing but ReadWrite touches it. }
  THSMap = class(TENode)
  private
    FMouse: THSMapMouse;
    FMapContainer: TMapContainer;
    FEngine: THSEngine;
    FSelection: THexagonSpriteSelection;
    FStaticVisibleHS: TVisibilityList;
    FDynamicVisibleHS: TVisibilityList;
    FStaticFixedVisibleHS: TVisibilityList;
    FDynamicFixedVisibleHS: TVisibilityList;
    FTimer: TETimerNode;
    FStaticSceneInvalid: Boolean;
    FDynamicSceneInvalid: Boolean;
    FVersion: Integer;
    FHSSFileName: string;
    FStatus: THSMapStatus;
    FFrame: Integer;
    FTerrainChangedEvents: TEventList;
    FOnCenterView: TCenterViewEvent;
    FOnChangeView: TChangeViewEvent;
    FOnViewLevel: TViewLevelEvent;
    FOnProgress: TProgressEvent;
    FTerrainChangedLockCounter: Integer;
    FNewFrameEvents: TEventList;
    FViewPortChangedEvents: TEventList;
    FDestroyEvents: TEventList;
    FHSChangedEvents: TEventList;
    FFileName: string;
  protected FViewXhp: Integer;
    FViewYhp: Integer;
    FViewL: Integer;
    FViewWidth: Integer;
    FViewHeight: Integer;
    FViewXhx: Integer;
    FViewYhx: Integer;
    FViewWidthHX: Integer;
    FViewHeightHX: Integer;
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure MainReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function CreateMouse: THSMapMouse; virtual;
    procedure NotifyProgress(const Progress: TMapProgress); virtual;
    procedure InitializeNewMap; virtual;
    procedure TriggerTerrainChangedEvent(const R: TRect; L: Shortint); virtual;
    procedure DrawStaticHS(var SD: TSurfaceDesc); virtual;
    procedure DrawDynamicHS(var SD: TSurfaceDesc); virtual;
    procedure DrawStaticHSEx(var SD: TSurfaceDesc); virtual;
    procedure DrawDynamicHSEx(var SD: TSurfaceDesc); virtual;
    procedure FillLevelWithResource(L: Integer; Resource: TMapObjectResource); virtual;
    function AddMapLevel: Boolean; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    procedure ViewLevel(Lhx: Integer); virtual;
    procedure CenterViewTo(Xhx, Yhx, Lhx: Integer); virtual;
    procedure ChangeViewTo(Xhp, Yhp, Lhp: Integer); virtual;
    procedure GetViewCenter(var Xhx, Yhx, Lhx: Integer); virtual;
    procedure MakeVisible(Xhx, Yhx, Lhx, Radius: Integer); virtual;
    function CreateNewMap(Settings: TNewHSMapSettings): Boolean; virtual;
    function ChangeTerrain(MO: TEObject; X, Y, L, Radius, TerrainType: Integer): Integer; virtual;
    function ChangeTerrainEx(MO: TEObject; X, Y, L, Radius: Integer;
      ChangeTerrainProc: TChangeTerrainProc; TerrainChangedProc: TTerrainChangedProc): Integer; virtual;
    procedure UpdateStaticScene; virtual;
    procedure UpdateDynamicScene; virtual;
    procedure DrawStaticScene(var SD: TSurfaceDesc); virtual;
    procedure DrawDynamicScene(var SD: TSurfaceDesc); virtual;
    procedure NewFrame; virtual;
    procedure RemoveMapLevel(Index: Integer);
    procedure TerrainChanged(const R: TRect; L: Shortint);
    procedure TerrainChangedRad(X, Y, L: Shortint; Radius: Integer);
    procedure LockTerrainChangedEvent;
    procedure UnlockTerrainChangedEvent;
    procedure SetModified;
    procedure ResetModified;
    function GetMaxXhp: Integer;
    function GetMaxYhp: Integer;
    procedure SetHSSFileName(FileName: string);
    procedure ClearTerrain(X, Y, L, Radius, TerrainType: Integer);
    function CanChangeTerrain(MO: TMapObject; X, Y, L: Integer; TerrainList: TTerrainList): Boolean;
    function PlaceHX(HS: THexagonSprite; Xhx, Yhx, L: Integer): Boolean;
    function Place(HS: THexagonSprite; Xhp, Yhp, L: Integer): Boolean;
    procedure Remove(HS: THexagonSprite);
    function SetViewPort(Xhp, Yhp, Lhp, Width, Height: Integer): Boolean;
    procedure ClearViewPort;
    function Viewing(Xhx, Yhx, Lhx: Integer): Boolean;
    procedure ResetVisibleStaticHS;
    procedure ResetVisibleDynamicHS;
    procedure InvalidateStaticScene(Xhx, Yhx, Lhx: Integer);
    property Mouse: THSMapMouse read FMouse;
    property MapContainer: TMapContainer read FMapContainer;
    property Engine: THSEngine read FEngine;
    property Selection: THexagonSpriteSelection read FSelection;
    property StaticVisibleHS: TVisibilityList read FStaticVisibleHS;
    property DynamicVisibleHS: TVisibilityList read FDynamicVisibleHS;
    property StaticFixedVisibleHS: TVisibilityList read FStaticFixedVisibleHS;
    property DynamicFixedVisibleHS: TVisibilityList read FDynamicFixedVisibleHS;
    property Timer: TETimerNode read FTimer;
    property StaticSceneInvalid: Boolean read FStaticSceneInvalid write FStaticSceneInvalid;
    property DynamicSceneInvalid: Boolean read FDynamicSceneInvalid write FDynamicSceneInvalid;
    property Version: Integer read FVersion write FVersion;
    property HSSFileName: string read FHSSFileName write SetHSSFileName;
    property Status: THSMapStatus read FStatus write FStatus;
    property Frame: Integer read FFrame;
    property TerrainChangedEvents: TEventList read FTerrainChangedEvents;
    property OnCenterView: TCenterViewEvent read FOnCenterView write FOnCenterView;
    property OnChangeView: TChangeViewEvent read FOnChangeView write FOnChangeView;
    property OnViewLevel: TViewLevelEvent read FOnViewLevel write FOnViewLevel;
    property OnProgress: TProgressEvent read FOnProgress write FOnProgress;
    property NewFrameEvents: TEventList read FNewFrameEvents;
    property ViewPortChangedEvents: TEventList read FViewPortChangedEvents;
    property DestroyEvents: TEventList read FDestroyEvents;
    property HSChangedEvents: TEventList read FHSChangedEvents;
    property FileName: string read FFileName write FFileName;
    property ViewXhp: Integer read FViewXhp;
    property ViewYhp: Integer read FViewYhp;
    property ViewL: Integer read FViewL;
    property ViewWidth: Integer read FViewWidth;
    property ViewHeight: Integer read FViewHeight;
    property ViewXhx: Integer read FViewXhx;
    property ViewYhx: Integer read FViewYhx;
    property ViewWidthHX: Integer read FViewWidthHX;
    property ViewHeightHX: Integer read FViewHeightHX;
    property MaxXhp: Integer read GetMaxXhp;
    property MaxYhp: Integer read GetMaxYhp;
  end;

  { HSEngine.THSMapViewer (instance size 76): shows a map on a surface. +$24 FStaticSurface (the
    static scene, kept between frames), +$28 FSceneWidth, +$2C FSceneHeight, +$30 FSceneX, +$34
    FSceneY, +$38 FSceneL, +$3C FStaticSurfaceValid, +$40 FOnSceneChanged (published), +$48 FHSMap.
    SetHSMap points the map's OnCenterView, OnChangeView and OnViewLevel at CenterScene,
    ChangeScene and SetSceneL. }
  THSMapViewer = class(TComponent)
  private
    FStaticSurface: TSurface;
    FSceneWidth: Integer;
    FSceneHeight: Integer;
    FSceneX: Integer;
    FSceneY: Integer;
    FSceneL: Integer;
    FStaticSurfaceValid: Boolean;
    FOnSceneChanged: TNotifyEvent;
    FHSMap: THSMap;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetHSMap(Value: THSMap); virtual;
    procedure VerifyStaticSurface(Surface: TSurface); virtual;
    procedure ChangeScene(Xhp, Yhp, Lhp: Integer);
    procedure CenterScene(Xhx, Yhx, Lhx: Integer);
    procedure SetSceneL(Value: Integer);
    procedure SetSceneX(Value: Integer);
    procedure SetSceneY(Value: Integer);
    procedure SetSceneWidth(Value: Integer);
    procedure SetSceneHeight(Value: Integer);
    procedure ResetStaticSurface;
    procedure ShowScene(X, Y: Integer; Surface: TSurface);
    property HSMap: THSMap read FHSMap write SetHSMap;
    property StaticSurface: TSurface read FStaticSurface;
    property StaticSurfaceValid: Boolean read FStaticSurfaceValid write FStaticSurfaceValid;
    property SceneX: Integer read FSceneX write SetSceneX;
    property SceneY: Integer read FSceneY write SetSceneY;
    property SceneL: Integer read FSceneL write SetSceneL;
    property SceneWidth: Integer read FSceneWidth write SetSceneWidth;
    property SceneHeight: Integer read FSceneHeight write SetSceneHeight;
  published
    property OnSceneChanged: TNotifyEvent read FOnSceneChanged write FOnSceneChanged;
  end;
  { HSEngine.TMORTerrainControl (instance size 24): +8 FHSEngine, +$C FTries, +$10 FResources,
    +$14 FMOClass. The map object resources of one kind (THexagonControl: hexagons,
    TRoadControl: roads) sorted by terrain type: FResources holds one TList of resources per
    terrain type name of the set (THSSet.TerrainTypes), filled by RegisterResource when a resource
    is activated. Place and PlaceClass put a random resource of a terrain type on a map field. }
  TMORTerrainControl = class(TEObject)
  private
    FHSEngine: THSEngine;
    FTries: Integer;
    FResources: TList;
    FMOClass: TClass;
    procedure Initialize;
  public
    destructor Destroy; override;
    function GetControlStyle: TEControlStyles; override;
    constructor Create(AOwner: TECustomNode); override;
    procedure Clear; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function CreateMO(TerrainType: Shortint): TMapObject; virtual;
    function Place(Container: TMapContainer; X, Y, L: Shortint; TerrainType: Shortint): TMapObject; virtual;
    function PlaceClass(Container: TMapContainer; X, Y, L: Shortint; TerrainType: Shortint;
      AClassID: Integer): TMapObject; virtual;
    function GetRndResource(TerrainType: Integer; AClassID: Integer): TMapObjectResource;
    procedure RegisterResource(Resource: TMapObjectResource);
    property HSEngine: THSEngine read FHSEngine;
    property Tries: Integer read FTries write FTries;
    property Resources: TList read FResources;
    property MOClass: TClass read FMOClass write FMOClass;
  end;

  { HSEngine.THexagonControl (instance size 24): the hexagon resources of a set }
  THexagonControl = class(TMORTerrainControl)
  end;

  { HSEngine.TRoadControl (instance size 24): the road resources of a set }
  TRoadControl = class(TMORTerrainControl)
  end;

  THSSetStatus = set of (ssModified, ssEditting, ssActivated, ssDestroying);

  { HSEngine.THSSet (instance size 72): +$14 FStatus, +$18 FHexagonControl, +$1C FRoadControl,
    +$20 FActivatedEngine, +$24 FMapObjectResourceList, +$28 FResourceEditSettings,
    +$2C FImageLibraryManager, +$30 FSFXManager, +$34 FPlugInControl, +$38 FName,
    +$3C FTerrainTypes, +$40 FOverlayTypes, +$44 FDecorationTypes. The hexagon sprite set: the
    resources a map uses (an .hss file, THSEngine.LoadHSS). ReadWrite stores the name (id 4), the
    map object resources (5), the resource edit settings (6) and the plug-ins (7); the type name
    lists are filled by the game (TAoWHSSet.Create) and not stored. }
  THSSet = class(TECustomOwner)
  private
    FStatus: THSSetStatus;
    FHexagonControl: THexagonControl;
    FRoadControl: TRoadControl;
    FActivatedEngine: TEngine; public property ActivatedEngine: TEngine read FActivatedEngine; private
    FMapObjectResourceList: TMapObjectResourceList;
    FResourceEditSettings: TEResourceEditSettings;
    FImageLibraryManager: TImageLibraryManager;
    FSFXManager: TSFXManager;
    FPlugInControl: TPlugInControl;
    FName: string;
    FTerrainTypes: TStringList;
    FOverlayTypes: TStringList;
    FDecorationTypes: TStringList;
  public
    destructor Destroy; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    procedure Activate(Edit: Boolean);
    procedure DeActivate;
    procedure SetModified;
    procedure ResetModified;
    procedure SetEditting;
    procedure ResetEditting;
    property Status: THSSetStatus read FStatus;
    property HexagonControl: THexagonControl read FHexagonControl;
    property RoadControl: TRoadControl read FRoadControl;
    property MapObjectResourceList: TMapObjectResourceList read FMapObjectResourceList;
    property ResourceEditSettings: TEResourceEditSettings read FResourceEditSettings;
    property ImageLibraryManager: TImageLibraryManager read FImageLibraryManager;
    property SFXManager: TSFXManager read FSFXManager;
    property PlugInControl: TPlugInControl read FPlugInControl;
    property Name: string read FName write FName;
    property TerrainTypes: TStringList read FTerrainTypes;
    property OverlayTypes: TStringList read FOverlayTypes;
    property DecorationTypes: TStringList read FDecorationTypes;
  end;

  THSEngineStatus = set of (esLoadingHSMSettings, esLoadingHSM, esSavingHSM, esLoadingHSS, esSavingHSS);

  { HSEngine.THSEngine (instance size 88): +$34 FStatus, +$38 FHSSet, +$3C FHSMap,
    +$40 FHSSetSearchPath, +$44 FHSSFileName, +$48 FOnHSMLoaded, +$4C FOnHSMClose,
    +$50 FOnHSSLoaded, +$54 FOnHSSClose. The engine of the hex map: it owns the set (.hss: a
    52-byte header, the stored set and a CRC32) and the map (.hsm: a 16-byte header and the stored
    map, compressed); the event lists are told when a map or a set is loaded or closed. }
  THSEngine = class(TEngine)
  private
    FStatus: THSEngineStatus;
  protected
    FHSSet: THSSet;
    FHSMap: THSMap;
  private
    FHSSetSearchPath: string;
    FHSSFileName: string;
    FOnHSMLoaded: TEventList;
    FOnHSMClose: TEventList;
    FOnHSSLoaded: TEventList;
    FOnHSSClose: TEventList;
  public
    destructor Destroy; override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure CreateHSSet; virtual;
    procedure SetHSMap(Value: THSMap); virtual;
    procedure LoadHSM(const FileName: string; Edit: Boolean; AProgress: TProgressEvent); virtual;
    function CreatePreviewHSM(const FileName: string): THSMap; virtual;
    procedure SaveHSM(const FileName: string; AProgress: TProgressEvent); virtual;
    procedure CloseHSM(AProgress: TProgressEvent); virtual;
    procedure CloseHSS; virtual;
    function GetHSSetFiles(Mask: string): TStringList;
    procedure LoadHSS(const FileName: string; Edit: Boolean; AProgress: TProgressEvent);
    procedure SaveHSS(const FileName: string; AProgress: TProgressEvent);
    procedure LoadPreviewHSM(const FileName: string);
    function LoadHSMEx(const FileName: string; Edit: Boolean; AProgress: TProgressEvent): THSMap;
    procedure LoadHSMfromStream(Stream: TStream; Edit: Boolean; AProgress: TProgressEvent);
    procedure SaveHSMtoStream(Stream: TStream; AProgress: TProgressEvent);
    procedure InitializeHSSet(FileName: string; AProgress: TProgressEvent);
    function NewHSM(AClassID: Integer): THSMap;
    property Status: THSEngineStatus read FStatus;
    property HSSet: THSSet read FHSSet;
    property HSMap: THSMap read FHSMap write SetHSMap;
    property HSSetSearchPath: string read FHSSetSearchPath write FHSSetSearchPath;
    property HSSFileName: string read FHSSFileName;
    property OnHSMLoaded: TEventList read FOnHSMLoaded;
    property OnHSMClose: TEventList read FOnHSMClose;
    property OnHSSLoaded: TEventList read FOnHSSLoaded;
    property OnHSSClose: TEventList read FOnHSSClose;
  end;

  { HSEngine.THexagonSpriteEngine (instance size 60): +$38 FHSEngine. The component that creates
    the engine (CreateEngine) and keeps it as TEComponent.Engine; OnRegisterClasses and
    OnUnRegisterClasses are TEComponent's events, called from Loaded and Destroy. }
  THexagonSpriteEngine = class(TEComponent)
  private
    FHSEngine: THSEngine;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetHSEngine(Value: THSEngine); virtual;
    procedure CreateEngine; virtual;
    procedure SetHSSetSearchPath(Value: string);
    function GetHSSetSearchPath: string;
    property HSEngine: THSEngine read FHSEngine write SetHSEngine;
    property HSSetSearchPath: string read GetHSSetSearchPath write SetHSSetSearchPath;
  published
    property OnRegisterClasses;
    property OnUnRegisterClasses;
  end;
  TControlMode = set of (cmMultiSelect, cmShowSelectionSelf);

  { HSEngine.THexagonSprite (instance size 8): the base of everything placed on the map. Owner is
    the TMapField the sprite stands on (for the multi-hex sprites the field of the base hexagon). }
  THexagonSprite = class(TEObject)
  public
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function GetTerrain(HN: Integer): Shortint; virtual;
    procedure SetTerrain(HN: Integer; Value: Shortint); virtual;
    function GetTerrainCount: Integer; virtual;
    function GetOverlay(HN: Integer): Shortint; virtual;
    procedure SetOverlay(HN: Integer; Value: Shortint); virtual;
    function GetOverlayCount: Integer; virtual;
    function GetLevel: Byte; virtual;
    procedure SetVisible(Value: Boolean); virtual;
    function GetVisible: Boolean; virtual;
    function GetSelected: Boolean; virtual;
    function GetXhx: Shortint; virtual;
    function GetYhx: Shortint; virtual;
    function GetLhx: Shortint; virtual;
    function GetXYL: Integer; virtual;
    function GetEditMode: Boolean; virtual;
    procedure SetEditMode(Value: Boolean); virtual;
    function GetShowPriority: Integer; virtual;
    procedure Connect; virtual;
    procedure Disconnect; virtual;
    function CanChangeTerrain(const Info: THSSenderInfo): Boolean; virtual;
    procedure ChangeTerrain(const Info: THSTerrainInfo); virtual;
    procedure TerrainChanged(const Info: THSTerrainInfo); virtual;
    procedure NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo); virtual;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); virtual; abstract;
    function PlaceOnMap: Boolean; virtual;
    procedure RemoveFromMap; virtual;
    function MainPlace(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; virtual;
    procedure MainRemove; virtual;
    function MainLoaded: Boolean; virtual;
    function Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; virtual;
    procedure Remove; virtual;
    function Loaded: Boolean; virtual;
    procedure MapFieldMsgProc(var Msg: TMapFieldMsg); virtual;
    procedure CanMoveOn(const Info: THSMoveOnInfo; var MoveResult: THSMoveOnResult); virtual;
    function CanMoveOver(const Info: THSSenderInfo): Integer; virtual;
    procedure MoveExclusive(const Info: THSSenderInfo); virtual;
    procedure Changed; virtual;
    procedure Activate; virtual;
    procedure Deactivate; virtual;
    class function ControlMode: TControlMode; virtual;
    procedure UpdateMapField(const Info: THSMapFieldInfo); virtual;
    procedure MakeVisible(VisibilityList: TVisibilityList); virtual;
    procedure GetBaseHX(var XYL: Integer); virtual;
    function CanSelect(Xhp, Yhp: Integer): Boolean; virtual;
    procedure Select; virtual;
    procedure Unselect; virtual;
    function EditName: string; virtual;
    function PlaceOnMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer): Boolean;
    procedure RemoveFromMapEx(Xhp, Yhp, Width, Height: Integer);
    function PlaceUserOnMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer): Boolean;
    procedure RemoveUserFromMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer);
    procedure SortMapFieldEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer);
    property Terrain[HN: Integer]: Shortint read GetTerrain write SetTerrain;
    property TerrainCount: Integer read GetTerrainCount;
    property Overlay[HN: Integer]: Shortint read GetOverlay write SetOverlay;
    property OverlayCount: Integer read GetOverlayCount;
    property Level: Byte read GetLevel;
    property Visible: Boolean read GetVisible write SetVisible;
    property Selected: Boolean read GetSelected;
    property Xhx: Shortint read GetXhx;
    property Yhx: Shortint read GetYhx;
    property Lhx: Shortint read GetLhx;
    property XYL: Integer read GetXYL;
    property EditMode: Boolean read GetEditMode write SetEditMode;
    property ShowPriority: Integer read GetShowPriority;
  end;

  { HSEngine.TSingleHS (instance size 12): a sprite on one hexagon. +8 FStatus: bit 1 visible,
    2 edit mode, 4 selected, 8 activated (a Byte: the original sets the bits with or/and, which a
    set with Include does not give). }
  TSingleHS = class(THexagonSprite)
  private
    FStatus: Byte;
  public
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetSelected: Boolean; override;
    function GetEditMode: Boolean; override;
    procedure SetEditMode(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    function Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: TVisibilityList); override;
    procedure Select; override;
    procedure Unselect; override;
    function CanPlace(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; virtual;
    function PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; virtual;
    function Activated: Boolean;
  end;

  { HSEngine.TFixedVisibleHS (instance size 12): a sprite that is always in the visibility list
    (not on a field). +8 FStatus: bit 1 visible. }
  TFixedVisibleHS = class(THexagonSprite)
  private
    FStatus: Byte;
  public
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetShowPriority: Integer; override;
    procedure MainRemove; override;
    procedure MakeVisible(VisibilityList: TVisibilityList); override;
  end;

  TOnShowHSEvent = procedure(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc) of object;

  { HSEngine.TCustomFixedVisibleHS (instance size 24): +$C FShowPriority, +$10 FOnShow (Show calls
    it). TAbstractAoWHSMap (AoWEPACK) creates two and sets OnShow and ShowPriority. }
  TCustomFixedVisibleHS = class(TFixedVisibleHS)
  private
    FShowPriority: Integer;
    FOnShow: TOnShowHSEvent;
  public
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    property ShowPriority: Integer read GetShowPriority write FShowPriority;
    property OnShow: TOnShowHSEvent read FOnShow write FOnShow;
  end;

  TLibraryImageHSStatus = set of (lsVisible, lsEditMode, lsDestroyOnShow, lsMapIsOwner, lsPlacedOnMap);

  { HSEngine.TLibraryImageHS (instance size 32): an image of an image library shown at a pixel
    position. +8 FStatus, +$C FImage, +$10 FXhp, +$14 FYhp, +$18 FLhx, +$1C FShowPriority (the top
    six bits are the level, the rest the offset SetShowPriorityOffset adds). Persisted: 1 FStatus
    (rwData), 2 FShowPriority, 3 FXhp, 4 FYhp, 5 FLhx (rwByte). }
  TLibraryImageHS = class(THexagonSprite)
  private
    FStatus: TLibraryImageHSStatus;
    FImage: TLibraryImage;
    FXhp: Integer;
    FYhp: Integer;
    FLhx: Byte;
    FShowPriority: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function GetEditMode: Boolean; override;
    procedure SetEditMode(Value: Boolean); override;
    function GetShowPriority: Integer; override;
    procedure Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    procedure MakeVisible(VisibilityList: TVisibilityList); override;
    procedure SetImage(Value: TLibraryImage); virtual;
    function CanPlace(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; virtual;
    function PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; virtual;
    function GetMapIsOwner: Boolean;
    procedure SetMapIsOwner(Value: Boolean);
    function GetDestroyOnShow: Boolean;
    procedure SetDestroyOnShow(Value: Boolean);
    procedure SetLevel(Value: Byte);
    procedure SetShowPriorityOffset(OffsetX, OffsetY: Integer);
    property Image: TLibraryImage read FImage write SetImage;
    property MapIsOwner: Boolean read GetMapIsOwner write SetMapIsOwner;
    property DestroyOnShow: Boolean read GetDestroyOnShow write SetDestroyOnShow;
    property Level: Byte read GetLevel write SetLevel;
  end;

  { HSEngine.THPBasedHS (instance size 24): a sprite placed at a pixel position. +8 FVisible,
    +$C FXhp, +$10 FYhp, +$14 FLhx (HSLib.TLibraryHS reads FXhp and FYhp). Persisted: 4 FXhp,
    5 FYhp, 6 FLhx (rwByte). }
  THPBasedHS = class(THexagonSprite)
  protected
    FVisible: Boolean;
    FXhp: Integer;
    FYhp: Integer;
    FLhx: Shortint;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure SetVisible(Value: Boolean); override;
    function GetVisible: Boolean; override;
    function Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
  end;
  { HSEngine.EMapObjectResourceMissing (instance size 12): TMapObject.ReadWrite raises it when the
    resource id read from the stream is not in the resource list }
  EMapObjectResourceMissing = class(Exception)
  end;

  TMapObjectStatus = set of (moVisible, moResourceLinked, moEditMode, moPlacedOnMap, moSelected, moActivated);

  { HSEngine.TMapObject (instance size 16): a hexagon sprite drawn from a resource. +8 FResource
    (the resource; until the object is linked it holds the resource id, persisted as id 1), +$C
    FStatus. }
  TMapObject = class(THexagonSprite)
  protected
    FResource: TMapObjectResource;
    FStatus: TMapObjectStatus;
    function GetResourceID: Integer;
    procedure SetResourceID(Value: Integer);
    function GetResourceLinked: Boolean;
    procedure SetResourceLinked(Value: Boolean);
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    class function ClassID: Integer; override;
    function GetTerrain(Index: Integer): Shortint; override;
    procedure SetTerrain(Index: Integer; Value: Shortint); override;
    function GetTerrainCount: Integer; override;
    function GetOverlay(Index: Integer): Shortint; override;
    procedure SetOverlay(Index: Integer; Value: Shortint); override;
    function GetOverlayCount: Integer; override;
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
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    function MainPlace(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure MainRemove; override;
    function Place(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean; override;
    procedure Remove; override;
    function Loaded: Boolean; override;
    procedure MapFieldMsgProc(var Msg: TMapFieldMsg); override;
    procedure Activate; override;
    procedure Deactivate; override;
    procedure MakeVisible(VisibilityList: TVisibilityList); override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    procedure Select; override;
    procedure Unselect; override;
    function EditName: string; override;
    function GetResourceList(AEngine: TEngine): TMapObjectResourceList; virtual;
    function LinkToResource(AEngine: TEngine): Boolean; virtual;
    procedure SetResource(Value: TMapObjectResource); virtual;
    function CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; virtual;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; virtual;
    property Resource: TMapObjectResource read FResource write SetResource;
    property ResourceID: Integer read GetResourceID write SetResourceID;
    property ResourceLinked: Boolean read GetResourceLinked write SetResourceLinked;
    property Status: TMapObjectStatus read FStatus;
  end;

  { HSEngine.TMapObjectResource (instance size 52): the resource of map objects. +$18 FEngine (set
    by the engine activation message), +$1C FShowPriorityOffset (id 4), +$20 FImageLibrary (id 8),
    +$24 FImageSequenceList (nil without complex images; ids 9, 10), +$28 FTerrainList (id 7), +$2C
    FLevel (id 5), +$30 FName (id 6). }
  TMapObjectResource = class(TEResource)
  protected
    FEngine: THSEngine;
    FShowPriorityOffset: Integer;
    FImageLibrary: TImageLibrary;
    FImageSequenceList: TImageSequenceList;
    FTerrainList: TTerrainList;
    FLevel: Byte;
    FName: string;
  public
    destructor Destroy; override;
    function ClassVersion: Integer; override;
    function GetEngine: TEngine; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function GetCellImage: TLibraryImage; override;
    procedure SetCellImage(Value: TLibraryImage); override;
    class function ResourceEditName: string; override;
    function CreateResourceUser: TEObject; override;
    procedure Draw(Canvas: TCanvas; Rect: TRect; Mode: TBltMode; ScaleX, ScaleY: Integer; BkColor, Color: TColor); override;
    procedure SetLevel(Value: Byte); virtual;
    function PlaceResourceUser(HSMap: THSMap; Xhx, Yhx, Lhx: Shortint): TMapObject; virtual;
    procedure CalcShowPriorityOffset(dX, dY, Level: Integer); virtual;
    procedure ShowComplexImage(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; Index: Integer; Offset: Cardinal);
    procedure ClearTerrain(X, Y, Lhx: Integer);
    procedure EditDropMsg(var Msg: TEMsg);
    property Engine: THSEngine read FEngine;
    property ShowPriorityOffset: Integer read FShowPriorityOffset write FShowPriorityOffset;
    property ImageLibrary: TImageLibrary read FImageLibrary;
    property ImageSequenceList: TImageSequenceList read FImageSequenceList write FImageSequenceList;
    property TerrainList: TTerrainList read FTerrainList;
    property Level: Byte read FLevel write SetLevel;
    property Name: string read FName write FName;
  end;

  { HSEngine.TMapObjectResourceList (instance size 20) }
  TMapObjectResourceList = class(TEResourceList)
  public
    function GetMOR(Index: Integer): TMapObjectResource;
    function FindMOR(AClassID: Integer; TerrainList: TTerrainList; Mode: TTerrainCompareMode; var List: TList): Boolean;
    property MORs[Index: Integer]: TMapObjectResource read GetMOR;
  end;

  { HSEngine.TMultiHexMO (instance size 20): a map object that covers the hexagons of its terrain
    list around its main hexagon. +$10 FXhx, +$11 FYhx (the main hexagon, ids 3 and 4). }
  TMultiHexMO = class(TMapObject)
  protected
    FXhx: Shortint;
    FYhx: Shortint;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    function GetXhx: Shortint; override;
    function GetYhx: Shortint; override;
    function GetXYL: Integer; override;
    function GetShowPriority: Integer; override;
    procedure Connect; override;
    procedure Disconnect; override;
    procedure Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); override;
    function PlaceOnMap: Boolean; override;
    procedure RemoveFromMap; override;
    function CanSelect(Xhp, Yhp: Integer): Boolean; override;
    function CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure SortMapFields; virtual;
    function CanPlaceOnHS(HS: THexagonSprite): Boolean; virtual;
    function GetMostFrequentMapFieldTerrainType(MapLevel: TMapLevel; Xhx, Yhx, Default: Shortint): Shortint; virtual;
    procedure UpdateTerrain(MapLevel: TMapLevel; Xhx, Yhx: Integer);
    procedure UpdateMapFields(MapLevel: TMapLevel; Xhx, Yhx: Integer);
    procedure OverrideTerrain;
  end;

  { HSEngine.TMultiHexMOR (instance size 68): +$34 FdXImage, +$38 FdYImage (the image offset, ids 12
    and 13), +$3C FdXmainP, +$40 FdYmainP (the main point, ids 14 and 15, part of the show
    priority offset) }
  TMultiHexMOR = class(TMapObjectResource)
  protected
    FdXImage: Integer;
    FdYImage: Integer;
    FdXmainP: Integer;
    FdYmainP: Integer;
  public
    procedure ReadWrite(Stream: TEStorageStream); override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure SetdXmainP(Value: Integer); virtual;
    procedure SetdYmainP(Value: Integer); virtual;
    property dXImage: Integer read FdXImage write FdXImage;
    property dYImage: Integer read FdYImage write FdYImage;
    property dXmainP: Integer read FdXmainP write SetdXmainP;
    property dYmainP: Integer read FdYmainP write SetdYmainP;
  end;

  { HSEngine.TAbstractHexagon (instance size 16): the base of the terrain hexagons }
  TAbstractHexagon = class(TMapObject)
  public
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure ChangeTerrain(const Msg: THSTerrainInfo); override;
    procedure TerrainChanged(const Msg: THSTerrainInfo); override;
    procedure MapFieldMsgProc(var Msg: TMapFieldMsg); override;
    procedure Activate; override;
    procedure SetResource(Value: TMapObjectResource); override;
    function CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    function PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; virtual;
  end;

  { HSEngine.TAbstractHexagonResource (instance size 52) }
  TAbstractHexagonResource = class(TMapObjectResource)
  public
    constructor Create(AOwner: TECustomNode); override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function GetHexagonControl: THexagonControl; virtual;
  end;

  { HSEngine.TAbstractBorderHexagon (instance size 16) }
  TAbstractBorderHexagon = class(TAbstractHexagon)
  public
    class function ClassID: Integer; override;
  end;

  { HSEngine.TAbstractBorderHexagonResource (instance size 52) }
  TAbstractBorderHexagonResource = class(TAbstractHexagonResource)
  end;

  { HSEngine.TAbstractRoad (instance size 16): the base of roads and bridges }
  TAbstractRoad = class(TMapObject)
  public
    class function ClassID: Integer; override;
    function GetLevel: Byte; override;
    function GetShowPriority: Integer; override;
    procedure ChangeTerrain(const Msg: THSTerrainInfo); override;
    procedure NeighbourTerrainChanged(HN: Integer; const Msg: THSTerrainInfo); override;
    procedure Activate; override;
    function CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; override;
    procedure UpdateTransitions; virtual;
  end;

  { HSEngine.TAbstractRoadResource (instance size 52) }
  TAbstractRoadResource = class(TMapObjectResource)
  public
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function PlaceResourceUser(HSMap: THSMap; Xhx, Yhx, Lhx: Shortint): TMapObject; override;
    function GetRoadControl: TRoadControl; virtual;
  end;
  PXYLArray = ^TXYLArray;
  TXYLArray = array[0..MaxListSize - 1] of TXYL;
  TXYLSortCompare = function(Item1, Item2: TXYL): Integer;

  { TXYLList (instance size 20): Engine's value list (Classes.TList adapted to a value type, with
    a default item for new and out-of-range items and a run-length encoded stream form) for map
    locations }
  TXYLList = class(TPersistent)
  private
    FList: PXYLArray;    { +04 }
    FCount: Integer;     { +08 }
    FCapacity: Integer;  { +0C }
    FDefault: TXYL;      { +10 }
    function Get(Index: Integer): TXYL;
    procedure Put(Index: Integer; Item: TXYL);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  protected
    procedure Grow; virtual;
    class procedure Error(const Msg: string; Data: Integer); virtual;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: TXYL): Integer;
    function AddXYL(X, Y, L: Shortint): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TXYLList;
    function First: TXYL;
    function IndexOf(Item: TXYL): Integer;
    function IndexOfXY(X, Y: Shortint): Integer;
    function IndexOfXYL(X, Y, L: Shortint): Integer;
    procedure Insert(Index: Integer; Item: TXYL);
    function Last: TXYL;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: TXYL): Integer;
    procedure Pack;
    procedure Sort(Compare: TXYLSortCompare);
    function Compare(List: TXYLList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Default: TXYL read FDefault write FDefault;
    property Items[Index: Integer]: TXYL read Get write Put; default;
    property List: PXYLArray read FList;
  end;

{ Hexagon coordinates (hx: column X, row Y; the odd columns are half a hexagon lower), hexagon
  numbers (HN: 0 the centre, then the rings, 6 * R numbers on ring R, clockwise from the top),
  hexagon directions (HT: 1..6 like the HN of ring 1), pixel coordinates (hp: 32 pixels per column
  and row) and the two diagonal axes (H, V). }

function dHXtoRad(X1, Y1, X2, Y2: Integer): Integer;
function ConnectingHX(X1, Y1, X2, Y2: Integer): Boolean;
function HXtoRad(Xhx, Yhx: Integer): Integer;
function HXtoV(Xhx, Yhx: Integer): Integer;
function HXtoH(Xhx, Yhx: Integer): Integer;
procedure HVtoHX(H, V: Integer; var Xhx, Yhx: Integer);
procedure HXtoHV(Xhx, Yhx: Integer; var H, V: Integer);
function HNtoRad(HN: Integer): Integer;
function RadToHN(Rad: Integer): Integer;
function InvHN(HN: Integer): Integer;
function HXtoHN(Xhx, Yhx: Integer): Integer;
procedure HNtoHX(HN: Integer; var Xhx, Yhx: Integer);
procedure CenterHNtoHX(Xhx, Yhx, HN: Integer; var NewXhx, NewYhx: Integer);
procedure TranslateHX(FromXhx, FromYhx, ToXhx, ToYhx, Xhx, Yhx: Integer; var NewXhx, NewYhx: Integer);
procedure TranslateZeroHX(Xhx, Yhx, dXhx, dYhx: Integer; var NewXhx, NewYhx: Integer);
function dHXtoHN(X1, Y1, X2, Y2: Integer): Integer;
function dHXtoHNfast(X1, Y1, X2, Y2: Integer): Integer;
procedure HXtoHP(Xhx, Yhx: Integer; var Xhp, Yhp: Integer);
procedure HPtoHX(Xhp, Yhp: Integer; var Xhx, Yhx: Integer);
procedure HPtoHXs(Xhp, Yhp: Integer; var Xhx, Yhx: Shortint);
function HPtoHN(Xhp, Yhp: Integer): Integer;
procedure HNtoHP(HN: Integer; var Xhp, Yhp: Integer);
function HXtoHT(Xhx, Yhx: Integer): Integer;
function dHXtoHT(X1, Y1, X2, Y2: Integer): Integer;
procedure GenerateWalkAroundRoute(Xhx, Yhx: Integer; CallBack: TWalkAroundRouteCallBack);
procedure InitHNWalk(var Walk: THNWalkData; Xhx, Yhx, Radius: Integer);
procedure WalkToNextHN(var Walk: THNWalkData);
function PackXYL(X, Y, L: Shortint): TXYL;
function LocationsConnected(List: TXYLList): Boolean;

const
  { the signature of a map file (THSEngine.SaveHSM, LoadPreviewHSM) }
  HSMID: THSMID = 'HSM'#0;

  { offsets of the neighbours (HN 1..6) by column parity; 7: none }
  HNtoXYTable: array[0..1, 0..7] of XYTableEntry = (
    ((X: 0; Y: 0), (X: 0; Y: -1), (X: 1; Y: -1), (X: 1; Y: 0),
     (X: 0; Y: 1), (X: -1; Y: 0), (X: -1; Y: -1), (X: 0; Y: 0)),
    ((X: 0; Y: 0), (X: 0; Y: -1), (X: 1; Y: 0), (X: 1; Y: 1),
     (X: 0; Y: 1), (X: -1; Y: 1), (X: -1; Y: 0), (X: 0; Y: 0)));

  HNtoRadTable: array[0..36] of Byte = (
    0, 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2,
    2, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3, 3,
    3);

  { the hexagon number on the opposite side of the centre }
  InvHNTable: array[0..36] of Byte = (
    0, 4, 5, 6, 1, 2, 3, 13, 14, 15, 16, 17, 18, 7, 8, 9, 10, 11,
    12, 28, 29, 30, 31, 32, 33, 34, 35, 36, 19, 20, 21, 22, 23, 24, 25, 26,
    27);

  { the offsets of the hexagon numbers 0..36 (rings 0..3) from an even column }
  HNtoHXTable: array[0..36, 0..1] of Integer = (
    (0, 0), (0, -1), (1, -1), (1, 0),
    (0, 1), (-1, 0), (-1, -1), (0, -2),
    (1, -2), (2, -1), (2, 0), (2, 1),
    (1, 1), (0, 2), (-1, 1), (-2, 1),
    (-2, 0), (-2, -1), (-1, -2), (0, -3),
    (1, -3), (2, -2), (3, -2), (3, -1),
    (3, 0), (3, 1), (2, 2), (1, 2),
    (0, 3), (-1, 2), (-2, 2), (-3, 1),
    (-3, 0), (-3, -1), (-3, -2), (-2, -2),
    (-1, -3));

  { the number of hexagons inside the rings 0..10 (the first hexagon number of each ring) }
  RadToHNTable: array[0..10] of Integer = (0, 1, 7, 19, 37, 61, 91, 127, 169, 217, 271);

var
  HSEngineDID: Integer;

procedure Register;

implementation

uses
  Consts;
procedure OriginalAssert(const Message, Filename: string; LineNumber: Integer); external 'VCL30.dpl' name 'System.@Assert@E17CE8DC'; { Preserve original assertion locations without moving source lines. }
{ Group A, first part: the implementation-only tables (DATA after the interface tables: OppositeHTTable
  at $5562E248, used by TMapField.UpdateNeighbourTerrain; HNWalkTable at $5562E250, used by the asm of
  WalkToNextHN), TTerrainList and TXYLList (code $55605004..$55605CAE). }

type
  PShortint = ^Shortint;

const
  { the hexagon direction opposite to the directions 1..6 }
  OppositeHTTable: array[1..6] of Byte = (4, 5, 6, 1, 2, 3);

  { the step from side to side of a ring around a centre (WalkToNextHN), by column parity }
  HNWalkTable: array[0..1, 0..7] of XYTableEntry = (
    ((X: 1; Y: 0), (X: 0; Y: 1), (X: -1; Y: 0), (X: -1; Y: -1),
     (X: 0; Y: -1), (X: 1; Y: -1), (X: 0; Y: 0), (X: 0; Y: 0)),
    ((X: 1; Y: 1), (X: 0; Y: 1), (X: -1; Y: 1), (X: -1; Y: 0),
     (X: 0; Y: -1), (X: 1; Y: 0), (X: 0; Y: 0), (X: 0; Y: 0)));

{ TTerrainList }

destructor TTerrainList.Destroy;
begin
  ReallocMem(FList, 0);
  inherited Destroy;
end;

procedure TTerrainList.Assign(Source: TTerrainList);
begin
  SetCount(Source.FCount);
  System.Move(Source.FList^, FList^, FCount * 2);
end;

function TTerrainList.GetTerrain(Index: Integer): Shortint;
begin
  if Index < FCount then
    Result := PShortint(FList + Index + Index)^
  else
    Result := -2;
end;

procedure TTerrainList.SetTerrain(Index: Integer; Value: Shortint);
begin
  if Index >= FCount then SetCount(Index + 1);
  PShortint(FList + Index + Index)^ := Value;
end;

procedure TTerrainList.SetCount(NewCount: Integer);
begin
  ReallocMem(FList, NewCount + NewCount);
  if NewCount > FCount then
    FillChar((FList + FCount + FCount)^, (NewCount - FCount) * 2, -2);
  FCount := NewCount;
end;

function TTerrainList.GetOverlay(Index: Integer): Shortint;
begin
  if Index < FCount then
    Result := PShortint(FList + Index + Index + 1)^
  else
    Result := -2;
end;

procedure TTerrainList.SetOverlay(Index: Integer; Value: Shortint);
begin
  if Index >= FCount then SetCount(Index + 1);
  PShortint(FList + Index + Index + 1)^ := Value;
end;

function TTerrainList.GetTandO(Index: Integer): Word;
begin
  if Index < FCount then
    Result := PWord(FList + Index + Index)^
  else
    Result := $FEFE;
end;

procedure TTerrainList.SetTandO(Index: Integer; Value: Word);
begin
  if Index >= FCount then SetCount(Index + 1);
  PWord(FList + Index + Index)^ := Value;
end;

function TTerrainList.GetUsed(Index: Integer): Boolean;
begin
  Result := (Index < FCount) and (PWord(FList + Index + Index)^ and $8080 <> $8080);
end;

function TTerrainList.UsedTerrain: Integer;
var
  I: Integer;
  P: PShortint;
begin
  Result := 0;
  P := PShortint(FList);
  for I := FCount - 1 downto 0 do
  begin
    if P^ > -1 then Inc(Result);
    Inc(PChar(P), 2);
  end;
end;

function TTerrainList.UsedOverlays: Integer;
var
  I: Integer;
  P: PShortint;
begin
  Result := 0;
  P := PShortint(FList + 1);
  for I := FCount - 1 downto 0 do
  begin
    if P^ > -1 then Inc(Result);
    Inc(PChar(P), 2);
  end;
end;

procedure TTerrainList.Pack;
var
  NewCount: Integer;
begin
  NewCount := FCount;
  while (NewCount <> 0) and (GetOverlay(NewCount - 1) = -2) and (GetTerrain(NewCount - 1) = -2) do
    Dec(NewCount);
  if NewCount <> FCount then SetCount(NewCount);
end;

function TTerrainList.CreateSurroundingHNTable: TWordList;
var
  I, HN: Integer;
  Xhx, Yhx: Integer;
  Walk: THNWalkData;
begin
  Result := TWordList.Create;
  for I := 0 to FCount - 1 do
    if GetTerrain(I) >= 0 then
    begin
      HNtoHX(I, Xhx, Yhx);
      InitHNWalk(Walk, Xhx, Yhx, 1);
      while Walk.HN <> 7 do
      begin
        HN := HXtoHN(Walk.X, Walk.Y);
        if (HN >= FCount) or ((HN < FCount) and (GetTerrain(HN) < 0)) then
          if Result.IndexOf(HN) = -1 then Result.Add(HN);
        WalkToNextHN(Walk);
      end;
    end;
end;

function TTerrainList.CompareTerrain(List: TTerrainList; Mode: TTerrainCompareMode): Boolean;
var
  I, N, T1, T2, O1, O2: Integer;
begin
  Result := True;
  I := 0;
  if FCount >= List.FCount then N := FCount else N := List.FCount;
  while Result and (I <> N) do
  begin
    T1 := GetTerrain(I);
    T2 := List.GetTerrain(I);
    if not ((T1 < 0) and (T2 < 0)) then
      Result := (T1 >= 0) and (T2 >= 0) and (not (cmSameTerrainType in Mode) or (T1 = T2));
    if Result then
    begin
      O1 := GetOverlay(I);
      O2 := List.GetOverlay(I);
      if not ((O1 < 0) and (O2 < 0)) then
        Result := not (cmSameOverlayType in Mode) or (O1 = O2);
    end;
    Inc(I);
  end;
end;

procedure TTerrainList.LoadFromStream(Stream: TStream);
begin
  Stream.Read(FCount, SizeOf(Integer));
  SetCount(FCount);
  Stream.Read(FList^, FCount * 2);
end;

procedure TTerrainList.SaveToStream(Stream: TStream);
begin
  Pack;
  Stream.Write(FCount, SizeOf(Integer));
  Stream.Write(FList^, FCount * 2);
end;

{ TXYLList }

constructor TXYLList.Create;
begin
  inherited Create;
  FDefault.X := -1;
  FDefault.Y := -1;
  FDefault.L := -1;
  FDefault.Flag := 0;
end;

destructor TXYLList.Destroy;
begin
  Clear;
end;

procedure TXYLList.Assign(Source: TPersistent);
begin
  if Source is TXYLList then
    with TXYLList(Source) do
    begin
      Self.FCount := FCount;
      Self.SetCapacity(FCapacity);
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(TXYL));
      Self.FDefault := FDefault;
    end
  else
    inherited Assign(Source);
end;

function TXYLList.Add(Item: TXYL): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

function TXYLList.AddXYL(X, Y, L: Shortint): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result].X := X;
  FList^[Result].Y := Y;
  FList^[Result].L := L;
  FList^[Result].Flag := 0;
  Inc(FCount);
end;

procedure TXYLList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TXYLList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(TXYL));
end;

class procedure TXYLList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TXYLList.Exchange(Index1, Index2: Integer);
var
  Item: TXYL;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TXYLList.Expand: TXYLList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TXYLList.First: TXYL;
begin
  Result := Get(0);
end;

function TXYLList.Get(Index: Integer): TXYL;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := FDefault
  else
    Result := FList^[Index];
end;

procedure TXYLList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TXYLList.IndexOf(Item: TXYL): Integer;
begin
  Result := 0;
  while (Result < FCount) and (Integer(FList^[Result]) <> Integer(Item)) do Inc(Result);
  if Result = FCount then Result := -1;
end;

function TXYLList.IndexOfXY(X, Y: Shortint): Integer;
var
  Item: TXYL;
begin
  Item.X := X;
  Item.Y := Y;
  Result := 0;
  while (Result < FCount) and (FList^[Result].XY <> Item.XY) do Inc(Result);
  if Result = FCount then Result := -1;
end;

function TXYLList.IndexOfXYL(X, Y, L: Shortint): Integer;
begin
  Result := 0;
  while (Result < FCount) and ((FList^[Result].X <> X) or (FList^[Result].Y <> Y) or
    (FList^[Result].L <> L)) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TXYLList.Insert(Index: Integer; Item: TXYL);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(TXYL));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TXYLList.Last: TXYL;
begin
  Result := Get(FCount - 1);
end;

procedure TXYLList.Move(CurIndex, NewIndex: Integer);
var
  Item: TXYL;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

procedure TXYLList.Put(Index: Integer; Item: TXYL);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TXYLList.Remove(Item: TXYL): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TXYLList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if Integer(Items[I]) = Integer(FDefault) then Delete(I);
end;

procedure TXYLList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(TXYL));
    FCapacity := NewCapacity;
  end;
end;

procedure TXYLList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillInt(FList^[FCount], NewCount - FCount, Integer(FDefault));
  FCount := NewCount;
end;

procedure QuickSortXYL(SortList: PXYLArray; L, R: Integer;
  SCompare: TXYLSortCompare);
var
  I, J: Integer;
  P, T: TXYL;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1];
    repeat
      while SCompare(SortList^[I], P) < 0 do Inc(I);
      while SCompare(SortList^[J], P) > 0 do Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSortXYL(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TXYLList.Sort(Compare: TXYLSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSortXYL(FList, 0, Count - 1, Compare);
end;

function TXYLList.Compare(List: TXYLList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then
    Result := CompareMem(FList, List.FList, FCount * SizeOf(TXYL));
end;

procedure TXYLList.LoadFromStream(Stream: TStream);
var
  Count, Run: Integer;
  Item: TXYL;
begin
  Clear;
  Stream.Read(FDefault, SizeOf(TXYL));
  Stream.Read(Count, SizeOf(Integer));
  SetCapacity(Count);
  while Count <> FCount do
  begin
    Stream.Read(Item, SizeOf(TXYL));
    if Integer(Item) = Integer(FDefault) then
    begin
      Stream.Read(Run, SizeOf(Integer));
      SetCount(FCount + Run);
    end
    else
      Add(Item);
  end;
end;

procedure TXYLList.SaveToStream(Stream: TStream);
var
  I, Run: Integer;

  function DefaultRun: Integer;
  var
    J: Integer;
  begin
    Result := 0;
    J := I;
    while (J < FCount) and (Integer(FList^[J]) = Integer(FDefault)) do
    begin
      Inc(Result);
      Inc(J);
    end;
  end;

begin
  I := 0;
  Stream.Write(FDefault, SizeOf(TXYL));
  Stream.Write(FCount, SizeOf(Integer));
  while FCount <> I do
  begin
    Run := DefaultRun;
    if Run > 0 then
    begin
      Stream.Write(FDefault, SizeOf(TXYL));
      Stream.Write(Run, SizeOf(Integer));
      Inc(I, Run);
    end
    else
    begin
      Stream.Write(FList^[I], SizeOf(TXYL));
      Inc(I);
    end;
  end;
end;
{$I inc\HXSPRITE.PAS}
var
  { the address of the next TMapField instance (TMapField.NewInstance; TMapLevel.CreateMapFieldList
    steps it through the level's block) }
  MapFieldMemory: Pointer;
  { copies of a field's sprite list: SendMsg and Loaded call methods that may remove sprites }
  SendMsgList: THSList;
  LoadedList: THSList;

{ TMapField }

constructor TMapField.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainType := -1;
  FOverlayType := -1;
  FStatus := [];
  Resize(3);
end;

destructor TMapField.Destroy;
begin
  ReallocMem(FHSList, 0);
  FCount := 0;
end;

class function TMapField.NewInstance: TObject;
asm
        MOV     EDX,MapFieldMemory
        JMP     TObject.InitInstance
end;

procedure TMapField.FreeInstance;
begin
end;

procedure TMapField.SetOwner(AOwner: TECustomNode);
begin
  FOwner := AOwner;
end;

function TMapField.GetControlStyle: TEControlStyles;
begin
  Result := [csStored, csShared];
end;

class function TMapField.ClassID: Integer;
begin
  Result := $10101;
end;

function TMapField.GetXYL: Integer;
begin
  Result := FXhx + FYhx shl 8 + FLhx shl 16;
end;

function TMapField.GetChild(Index: Integer): TEObject;
begin
  if Index >= FCount then raise Exception.Create('Index out of bounds');
  Result := FHSList^[Index];
end;

procedure TMapField.SetChild(Index: Integer; Child: TEObject);
begin
  if Index >= FCount then raise Exception.Create('Index out of bounds');
  FHSList^[Index] := THexagonSprite(Child);
end;

function TMapField.HSListDataSize: Integer;
begin
  Result := FCapacity shl 2 + (FCapacity + 3) and $FC;
end;

function TMapField.GetHN(Index: Integer): Byte;
begin
  if Index >= FCount then raise Exception.Create('Index out of bounds');
  Result := Byte((PChar(FHSList) + FCapacity shl 2 + Index)^);
end;

procedure TMapField.SetHN(Index: Integer; Value: Byte);
begin
  if Index >= FCount then raise Exception.Create('Index out of bounds');
  (PChar(FHSList) + FCapacity shl 2 + Index)^ := Char(Value);
end;

function TMapField.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TMapField.Resize(NewCapacity: Byte);
begin
  if (NewCapacity <> 0) and (NewCapacity < 3) then NewCapacity := 3;
  if NewCapacity > FCapacity then
  begin
    ReallocMem(FHSList, NewCapacity shl 2 + (NewCapacity + 3) and $FC);
    if FCount > 0 then
      Move((PChar(FHSList) + FCapacity shl 2)^, (PChar(FHSList) + NewCapacity shl 2)^, FCount);
  end
  else
  begin
    if FCount > 0 then
      Move((PChar(FHSList) + FCapacity shl 2)^, (PChar(FHSList) + NewCapacity shl 2)^, FCount);
    ReallocMem(FHSList, NewCapacity shl 2 + (NewCapacity + 3) and $FC);
  end;
  FCapacity := NewCapacity;
end;

procedure TMapField.Sort;
var
  Changed: Boolean;
  I: Integer;
  HNs: PHNList;
  HS: THexagonSprite;
  HN: Byte;
begin
  Changed := True;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while Changed do
  begin
    Changed := False;
    I := Count - 2;
    while not Changed and (I >= 0) do
    begin
      if FHSList^[I].GetShowPriority > FHSList^[I + 1].GetShowPriority then
      begin
        Changed := True;
        HS := FHSList^[I];
        HN := HNs^[I];
        FHSList^[I] := FHSList^[I + 1];
        HNs^[I] := HNs^[I + 1];
        FHSList^[I + 1] := HS;
        HNs^[I + 1] := HN;
      end;
      Dec(I);
    end;
  end;
  FStaticCount := 0;
  while (FStaticCount <> FCount) and (FHSList^[FStaticCount].GetShowPriority shr 26 <= 15) do
    Inc(FStaticCount);
end;

procedure TMapField.ReadWrite(Stream: TEStorageStream);
var
  J: Integer;
  I: Integer;
  HS: TEObject;
begin
  if Stream.StorageMode * [smText] = [] then
  begin
    if smRead in Stream.StorageMode then
    begin
      if smCompare in Stream.StorageMode then
      begin
        J := 0;
        for I := Stream.PropertyTable.First to Stream.PropertyTable.Count - 1 do
          if Stream.PropertyTable.Items^[I].ID >= 50 then
          begin
            HS := FHSList^[J];
            Stream.rwCreateEObject(HS, Self, Stream.PropertyTable.Items^[I].ID);
            Inc(J);
          end;
      end
      else
        for I := Stream.PropertyTable.First to Stream.PropertyTable.Count - 1 do
        begin
          J := Stream.PropertyTable.Items^[I].ID;
          if J >= 50 then Stream.rwCreateEObject(HS, Self, J);
        end;
    end
    else
    begin
      I := 50;
      for J := 0 to FCount - 1 do
      begin
        HS := FHSList^[J];
        if (HS <> nil) and (HS.Owner = Self) and not (csShared in HS.GetControlStyle) and
          (csStored in HS.GetControlStyle) then
        begin
          Stream.rwCreateEObject(HS, Self, I);
          Inc(I);
        end;
      end;
    end;
  end
  else ReadWriteChildren(Stream);
end;

procedure TMapField.MainReadWrite(Stream: TEStorageStream);
begin
  ReadWrite(Stream);
end;

function TMapField.AddHS(HS: THexagonSprite; HN: Integer): Integer;
var
  Priority: Integer;
  HNs: PHNList;
begin
  try
    if HS = nil then raise Exception.Create('No nil HS allowed in TMapField');
    if FindChildIndex(HS) <> -1 then raise Exception.Create('HS already defined');
  except
  end;
  if FCapacity = FCount then Resize(FCapacity + 1);
  Priority := HS.GetShowPriority;
  if not (msComparing in FStatus) then
  begin
    Result := 0;
    while (Result < FCount) and (Priority > FHSList^[Result].GetShowPriority) do Inc(Result);
  end
  else Result := FCount;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  if Result < FCount then
  begin
    Move(FHSList^[Result], FHSList^[Result + 1], (FCount - Result) shl 2);
    Move(HNs^[Result], HNs^[Result + 1], FCount - Result);
  end;
  if Priority shr 26 <= 15 then Inc(FStaticCount);
  FHSList^[Result] := HS;
  HNs^[Result] := HN;
  Inc(FCount);
end;

function TMapField.RemoveHS(HS: THexagonSprite): Integer;
var
  I: Integer;
  HNs: PChar;
begin
  I := 0;
  while (I < FCount) and (HS <> FHSList^[I]) do Inc(I);
  if I < FCount then
  begin
    Dec(FCount);
    if I < FCount then
    begin
      HNs := PChar(FHSList) + FCapacity shl 2;
      Move(HNs[I + 1], HNs[I], FCount - I);
      Move(FHSList^[I + 1], FHSList^[I], (FCount - I) shl 2);
    end;
    if HS.GetShowPriority shr 26 <= 15 then
      if FStaticCount = 0 then
      begin
        try
          raise Exception.Create('Invalid StaticCount (' + HS.ClassName + ')');
        except
        end;
      end
      else Dec(FStaticCount);
    Result := FCount;
  end
  else Result := -1;
end;

procedure TMapField.Remove(Index: Integer);
var
  HNs: PChar;
begin
  Dec(FCount);
  if Index < FCount then
  begin
    HNs := PChar(FHSList) + FCapacity shl 2;
    Move(HNs[Index + 1], HNs[Index], FCount - Index);
    Move(FHSList^[Index + 1], FHSList^[Index], (FCount - Index) shl 2);
  end;
  if FCapacity > FCount + 1 then Resize(FCount);
end;

function TMapField.FindChild(AClassID: Integer): TEObject;
var
  I: Integer;
begin
  I := 0;
  while (I < FCount) and (FHSList^[I].ClassID <> AClassID) do Inc(I);
  if I < FCount then Result := FHSList^[I] else Result := nil;
end;

function TMapField.FindHS(AClass: TClass): THexagonSprite;
var
  I: Integer;
begin
  I := 0;
  while (I < FCount) and not (FHSList^[I] is AClass) do Inc(I);
  if I < FCount then Result := FHSList^[I] else Result := nil;
end;

function TMapField.FindOwnedHS(AClass: TClass): THexagonSprite;
var
  I: Integer;
  HS: THexagonSprite;
begin
  I := 0;
  Result := nil;
  while (I < FCount) and (Result = nil) do
  begin
    HS := FHSList^[I];
    if (HS is AClass) and (HS.Owner = Self) then Result := HS;
    Inc(I);
  end;
end;

function TMapField.FindNoneTransparentHS(AClass: TClass): THexagonSprite;
var
  I: Integer;
  HNs: PHNList;
begin
  I := 0;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while (I < FCount) and not ((FHSList^[I] is AClass) and
    (FHSList^[I].GetTerrain(HNs^[I]) >= 0)) do Inc(I);
  if I < FCount then Result := FHSList^[I] else Result := nil;
end;

function TMapField.FindNoneTransparentHSCID(AClassID: Integer): THexagonSprite;
var
  I: Integer;
  HNs: PHNList;
begin
  I := 0;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while (I < FCount) and not ((FHSList^[I].ClassID = AClassID) and
    (FHSList^[I].GetTerrain(HNs^[I]) >= 0)) do Inc(I);
  if I < FCount then Result := FHSList^[I] else Result := nil;
end;

function TMapField.FindOwnedChild(AClassID: Integer): TEObject;
var
  I: Integer;
begin
  I := 0;
  while (I < FCount) and not ((FHSList^[I].ClassID = AClassID) and (FHSList^[I].Owner = Self)) do
    Inc(I);
  if I < FCount then Result := FHSList^[I] else Result := nil;
end;

function TMapField.AddChild(Child: TEObject): Integer;
begin
  Result := AddHS(THexagonSprite(Child), 0);
end;

function TMapField.RemoveChild(Child: TEObject): Integer;
begin
  Result := RemoveHS(THexagonSprite(Child));
end;

procedure TMapField.SendMsg(var Msg: TEMsg; Sender: TEObject);
var
  I: Integer;
  N: Integer;
  HS: THexagonSprite;
begin
  if Msg.MsgID and $10000000 <> 0 then
  begin
    if Msg.MsgID and $20000000 = 0 then
    begin
      for I := FCount - 1 downto 0 do
      begin
        HS := FHSList^[I];
        if HS.GetLastMsg <> Msg.Seq then
        begin
          HS.SetLastMsg(Msg.Seq);
          HS.MsgProc(Msg, Self);
        end;
      end;
    end
    else
    begin
      for I := FCount - 1 downto 0 do
      begin
        HS := FHSList^[I];
        if (HS.GetLastMsg <> Msg.Seq) and (HS.Owner = Self) then
        begin
          HS.SetLastMsg(Msg.Seq);
          HS.MsgProc(Msg, Self);
        end;
      end;
    end;
  end
  else
    if Msg.MsgID and $20000000 = 0 then
    begin
      for I := Count - 1 downto 0 do
        with FHSList^[I] do MsgProc(Msg, Self);
    end
    else
    begin
      N := FCount;
      Move(FHSList^, SendMsgList, N shl 2);
      for I := N - 1 downto 0 do
        if SendMsgList[I].Owner = Self then SendMsgList[I].MsgProc(Msg, Self);
    end;
end;

procedure TMapField.SendMapFieldMsg(var Msg: TMapFieldMsg);
var
  I: Integer;
  OldResult: Integer;
  HNs: PHNList;
begin
  OldResult := Msg.Result;
  I := FCount;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  Msg.MapField := Self;
  while (I <> 0) and (OldResult = Msg.Result) do
  begin
    Dec(I);
    if I < Count then
    begin
      Msg.HN := HNs^[I];
      FHSList^[I].MapFieldMsgProc(Msg);
    end;
  end;
end;

procedure TMapField.CopyDynamicVisibleHS(List: TVisibilityList);
var
  I: Integer;
begin
  for I := FCount - 1 downto FStaticCount do
    FHSList^[I].MakeVisible(List);
end;

procedure TMapField.CopyStaticVisibleHS(List: TVisibilityList);
var
  I: Integer;
begin
  for I := FStaticCount - 1 downto 0 do
    FHSList^[I].MakeVisible(List);
end;

procedure TMapField.ResetDynamicVisibleHS;
var
  I: Integer;
begin
  for I := FCount - 1 downto FStaticCount do
    FHSList^[I].SetVisible(False);
end;

procedure TMapField.ResetStaticVisibleHS;
var
  I: Integer;
begin
  for I := FStaticCount - 1 downto 0 do
    FHSList^[I].SetVisible(False);
end;

{ The sprites with a level from MinLevel to MaxLevel that a map field owns are destroyed; the list
  is sorted, so the walk stops at the first sprite below MinLevel. The HP position is computed and
  never used. }
procedure TMapField.DestroyLevelHS(MinLevel: Integer; MaxLevel: Integer);
var
  Xhp: Integer;
  Yhp: Integer;
  Done: Boolean;
  I: Integer;
  Level: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  I := FCount - 1;
  Done := False;
  while not Done and (I >= 0) do
  begin
    Level := FHSList^[I].GetLevel;
    if Level <= MaxLevel then
      if Level >= MinLevel then
      begin
        if FHSList^[I].Owner is TMapField then FHSList^[I].Destroy;
      end
      else Done := True;
    Dec(I);
    if I >= FCount then I := FCount - 1;
  end;
end;

procedure TMapField.DestroyHS;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if I <= FCount - 1 then
      if FHSList^[I].Owner = Self then TEObject(FHSList^[I]).Destroy;
end;

procedure TMapField.Activate;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if FHSList^[I].Owner = Self then FHSList^[I].Activate;
end;

procedure TMapField.Loaded;
var
  N: Integer;
  I: Integer;
begin
  N := FCount;
  Move(FHSList^, LoadedList, FCount shl 2);
  for I := N - 1 downto 0 do
    if LoadedList[I].Owner = Self then
      if not LoadedList[I].MainLoaded then LoadedList[I].Free;
end;

function TMapField.CanChangeTerrainEx(Sender: TEObject): Boolean;
var
  HNs: PHNList;
  Info: THSSenderInfo;
  I: Integer;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    Info.MapField := Self;
    Info.Sender := Sender;
    I := FCount - 1;
    Result := True;
    while (I >= 0) and Result do
    begin
      Info.HN := HNs^[I];
      Result := FHSList^[I].CanChangeTerrain(Info);
      Dec(I);
    end;
  end
  else Result := False;
end;

function TMapField.CanChangeTerrain(Sender: TEObject; TerrainType: Shortint;
  OverlayType: Shortint): Boolean;
var
  OldTerrainType: Shortint;
  OldOverlayType: Shortint;
  HNs: PHNList;
  Info: THSSenderInfo;
  I: Integer;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    if TerrainType >= 0 then
    begin
      OldTerrainType := FTerrainType;
      FTerrainType := TerrainType;
    end;
    if OverlayType >= 0 then
    begin
      OldOverlayType := FOverlayType;
      FOverlayType := OverlayType;
    end;
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    Info.MapField := Self;
    Info.Sender := Sender;
    I := FCount - 1;
    Result := True;
    while (I >= 0) and Result do
    begin
      Info.HN := HNs^[I];
      Result := FHSList^[I].CanChangeTerrain(Info);
      Dec(I);
    end;
    if TerrainType >= 0 then FTerrainType := OldTerrainType;
    if OverlayType >= 0 then FOverlayType := OldOverlayType;
  end
  else Result := False;
end;

procedure TMapField.TerrainChanged;
var
  Info: THSTerrainInfo;
  I: Integer;
  HNs: PHNList;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    FStatus := FStatus + [msTerrainLocked];
    Info.MapField := Self;
    Info.TerrainType := FTerrainType;
    Info.OverlayType := FOverlayType;
    for I := FCount - 1 downto 0 do
    begin
      Info.HN := HNs^[I];
      FHSList^[I].ChangeTerrain(Info);
    end;
    FTerrainType := -1;
    FOverlayType := -1;
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    for I := FCount - 1 downto 0 do
    begin
      if FTerrainType < 0 then FTerrainType := FHSList^[I].GetTerrain(HNs^[I]);
      if FOverlayType < 0 then FOverlayType := FHSList^[I].GetOverlay(HNs^[I]);
    end;
    if FOverlayType < -1 then FOverlayType := -1;
    if FTerrainType < -1 then FTerrainType := -1;
    FStatus := FStatus - [msTerrainLocked];
    Info.TerrainType := FTerrainType;
    Info.OverlayType := FOverlayType;
    for I := FCount - 1 downto 0 do
    begin
      Info.HN := HNs^[I];
      FHSList^[I].TerrainChanged(Info);
    end;
    FStatus := FStatus + [msTerrainLocked];
    UpdateNeighbourTerrain;
    FStatus := FStatus - [msTerrainLocked];
  end
  else FStatus := FStatus + [msTerrainLocked];
end;

procedure TMapField.UpdateTerrainType;
var
  I: Integer;
  T: Shortint;
  HNs: PHNList;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    I := FCount;
    T := -1;
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    while (I <> 0) and (T < 0) do
    begin
      Dec(I);
      T := FHSList^[I].GetTerrain(HNs^[I]);
    end;
    if T < -1 then T := -1;
    if T <> FTerrainType then
    begin
      FTerrainType := T;
      TerrainChanged;
    end;
  end;
end;

procedure TMapField.UpdateOverlayType;
var
  I: Integer;
  T: Shortint;
  HNs: PHNList;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    I := FCount;
    T := -1;
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    while (I <> 0) and (T < 0) do
    begin
      Dec(I);
      T := FHSList^[I].GetOverlay(HNs^[I]);
    end;
    if T < -1 then T := -1;
    if T <> FOverlayType then
    begin
      FOverlayType := T;
      TerrainChanged;
    end;
  end;
end;

procedure TMapField.UpdateTerrain;
var
  O: Shortint;
  T: Shortint;
  HNs: PHNList;
  I: Integer;
begin
  if not (msTerrainLocked in FStatus) then
  begin
    O := -1;
    T := -1;
    HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
    for I := FCount - 1 downto 0 do
    begin
      if T < 0 then T := FHSList^[I].GetTerrain(HNs^[I]);
      if O < 0 then O := FHSList^[I].GetOverlay(HNs^[I]);
    end;
    if O < -1 then O := -1;
    if T < -1 then T := -1;
    if (O <> FOverlayType) or (T <> FTerrainType) then
    begin
      FOverlayType := O;
      FTerrainType := T;
      TerrainChanged;
    end;
  end;
end;

procedure TMapField.NeighbourTerrainChanged(var Info: THSTerrainInfo);
var
  HNs: PHNList;
  I: Integer;
begin
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  for I := FCount - 1 downto 0 do
    FHSList^[I].NeighbourTerrainChanged(HNs^[I], Info);
end;

function TMapField.GetDecorationType: Shortint;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $11;
  Msg.Result := -1;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;

procedure TMapField.UpdateNeighbourTerrain;
var
  Info: THSTerrainInfo;
  Walk: THNWalkData;
  I: Integer;
begin
  Info.MapField := Self;
  Info.TerrainType := FTerrainType;
  Info.OverlayType := FOverlayType;
  InitHNWalk(Walk, FXhx, FYhx, 0);
  for I := 1 to 6 do
  begin
    WalkToNextHN(Walk);
    if (Walk.X >= 0) and (Walk.X < TMapLevel(Owner).FWidth) and (Walk.Y >= 0) and
      (TMapLevel(Owner).FHeight > Walk.Y) then
    begin
      Info.HN := OppositeHTTable[I];
      TMapLevel(Owner).GetField(Walk.X, Walk.Y).NeighbourTerrainChanged(Info);
    end;
  end;
end;

procedure TMapField.UpdateMapField;
var
  HNs: PHNList;
  Info: THSMapFieldInfo;
  I: Integer;
begin
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  Info.MapField := Self;
  for I := FCount - 1 downto 0 do
  begin
    Info.HN := HNs^[I];
    FHSList^[I].UpdateMapField(Info);
  end;
end;

procedure TMapField.Initialize;
var
  O: Shortint;
  T: Shortint;
  HNs: PHNList;
  I: Integer;
  Info: THSTerrainInfo;
begin
  O := -1;
  T := -1;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  for I := FCount - 1 downto 0 do
  begin
    if T < 0 then T := FHSList^[I].GetTerrain(HNs^[I]);
    if O < 0 then O := FHSList^[I].GetOverlay(HNs^[I]);
  end;
  if O < -1 then O := -1;
  if T < -1 then T := -1;
  FOverlayType := O;
  FTerrainType := T;
  Info.MapField := Self;
  Info.TerrainType := FTerrainType;
  Info.OverlayType := FOverlayType;
  for I := FCount - 1 downto 0 do
  begin
    Info.HN := HNs^[I];
    FHSList^[I].TerrainChanged(Info);
  end;
  UpdateMapField;
end;

function TMapField.CanMoveOn(Sender: TObject; DefaultCode: Integer;
  MoveOverCode: Integer): Integer;
var
  HNs: PHNList;
  Res: THSMoveOnResult;
  Info: THSMoveOnInfo;
  I: Integer;
begin
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  Info.Sender := Sender;
  Info.MapField := Self;
  Info.MoveOverCode := MoveOverCode;
  Res.Code := DefaultCode;
  Res.Done := False;
  Res.Data := 0;
  I := FCount;
  while not Res.Done and (I <> 0) do
  begin
    Dec(I);
    Info.HN := HNs^[I];
    FHSList^[I].CanMoveOn(Info, Res);
  end;
  Result := Res.Code;
end;

function TMapField.CanMoveOver(Sender: TObject): Integer;
var
  HNs: PHNList;
  Info: THSSenderInfo;
  I: Integer;
begin
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  Info.Sender := Sender;
  Info.MapField := Self;
  Result := 1;
  I := FCount;
  while (Result = 1) and (I <> 0) do
  begin
    Dec(I);
    Info.HN := HNs^[I];
    Result := FHSList^[I].CanMoveOver(Info);
  end;
end;

procedure TMapField.MoveExclusive(Sender: TObject);
var
  HNs: PHNList;
  Info: THSSenderInfo;
  I: Integer;
begin
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  Info.Sender := Sender;
  Info.MapField := Self;
  for I := FCount - 1 downto 0 do
  begin
    Info.HN := HNs^[I];
    FHSList^[I].MoveExclusive(Info);
  end;
end;

function TMapField.GetMaxLevelNoneTransparentHS: THexagonSprite;
var
  Found: Boolean;
  I: Integer;
  HNs: PHNList;
  HN: Integer;
begin
  Found := False;
  I := FCount - 1;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while not Found and (I <> -1) do
  begin
    HN := HNs^[I];
    if (FHSList^[I].GetTerrain(HN) < 0) and (FHSList^[I].GetOverlay(HN) < 0) then Found := False
    else Found := True;
    Dec(I);
  end;
  if Found then Result := FHSList^[I + 1] else Result := nil;
end;

function TMapField.GetMaxLevelTerrainHS: THexagonSprite;
var
  Found: Boolean;
  I: Integer;
  HNs: PHNList;
  HN: Integer;
begin
  Found := False;
  I := FCount - 1;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while not Found and (I <> -1) do
  begin
    HN := HNs^[I];
    Found := FHSList^[I].GetTerrain(HN) >= 0;
    Dec(I);
  end;
  if Found then Result := FHSList^[I + 1] else Result := nil;
end;

function TMapField.GetMaxLevelOverlayHS: THexagonSprite;
var
  Found: Boolean;
  I: Integer;
  HNs: PHNList;
  HN: Integer;
begin
  Found := False;
  I := FCount - 1;
  HNs := PHNList(Integer(FHSList) + FCapacity shl 2);
  while not Found and (I <> -1) do
  begin
    HN := HNs^[I];
    Found := FHSList^[I].GetOverlay(HN) >= 0;
    Dec(I);
  end;
  if Found then Result := FHSList^[I + 1] else Result := nil;
end;

function TMapField.SetHNofHS(HS: THexagonSprite; HN: Byte): Integer;
var
  I: Integer;
begin
  I := 0;
  while (I < FCount) and (HS <> FHSList^[I]) do Inc(I);
  if I < FCount then
  begin
    (PChar(FHSList) + FCapacity shl 2 + I)^ := Char(HN);
    Result := I;
  end
  else Result := -1;
end;

function TMapField.GetHNofHS(HS: THexagonSprite): Integer;
var
  I: Integer;
begin
  I := 0;
  while (I < FCount) and (HS <> FHSList^[I]) do Inc(I);
  if I < FCount then Result := Byte((PChar(FHSList) + FCapacity shl 2 + I)^)
  else Result := -1;
end;
{ TNewHSMapSettings }

constructor TNewHSMapSettings.Create;
begin
  inherited Create;
  Width := 64;
  Height := 64;
  Levels := 1;
  HSSFileName := '';
  HSMapClassID := $10200;         { THSMap.ClassID }
  MapContainerClassID := $10103;  { TMapContainer.ClassID }
  MapLevelClassID := $10102;      { TMapLevel.ClassID }
end;
{ TMapLevel }

constructor TMapLevel.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FMapFieldCID := $10101;
end;

destructor TMapLevel.Destroy;
var
  P: TMapField;
  I: Integer;
begin
  P := FFields;
  for I := 0 to FCount - 1 do
  begin
    P.Destroy;
    P := TMapField(Integer(P) + FFieldSize);
  end;
  FCount := 0;
  DestroyMapFieldList;
  inherited Destroy;
end;

class function TMapLevel.ClassID: Integer;
begin
  Result := $10102;
end;

function TMapLevel.MapFieldClass: TEObjectClass;
begin
  Result := TMapField;
end;

procedure TMapLevel.ReadWrite(Stream: TEStorageStream);
var
  Step: Integer;
  I: Integer;
  W: Byte;
  H: Byte;
  L: Byte;
  Progress: TMapProgress;
  P: TMapField;
  S: TStream;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smText] = [smRead] then
  begin
    FEngine := Stream.Engine;
    FMapContainer := TMapContainer(Owner);
    FMap := FMapContainer.FMap;
  end;
  W := FWidth;
  Stream.rwByte(W, 3);
  FWidth := W;
  H := FHeight;
  Stream.rwByte(H, 4);
  FHeight := H;
  L := FLhx;
  Stream.rwByte(L, 5);
  FLhx := L;
  if not (smTranslate in Stream.StorageMode) then
  begin
    if smRead in Stream.StorageMode then Progress.ProgressType := ptLoading
    else Progress.ProgressType := ptSaving;
    Progress.Level := FLhx;
    Progress.Percent := 0;
    FMap.NotifyProgress(Progress);
  end;
  if (Stream.StorageMode * [smRead, smText, smCompare] = [smRead]) and (FWidth <> 0) then
    CreateMapFieldList(FWidth, FHeight);
  if smSetupCompare in Stream.StorageMode then
  begin
    P := FFields;
    for I := 0 to FCount - 1 do
    begin
      P.FStatus := P.FStatus + [msComparing];
      P := TMapField(Integer(P) + FFieldSize);
    end;
  end;
  S := Stream.OpenPropertyStream(6);
  if (S <> nil) or (smText in Stream.StorageMode) then
  begin
    Step := FCount div 10;
    P := FFields;
    for I := 0 to FCount - 1 do
    begin
      Stream.rwEObjectStream(P, I + 100);
      P := TMapField(Integer(P) + FFieldSize);
      Dec(Step);
      if Step = 0 then
      begin
        Inc(Progress.Percent, 10);
        if not (smTranslate in Stream.StorageMode) then FMap.NotifyProgress(Progress);
        Step := FCount div 10;
      end;
    end;
  end;
end;

procedure TMapLevel.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20000008 then
  begin
    FEngine := Msg.Engine;
    FMapContainer := TMapContainer(Owner);
    FMap := FMapContainer.FMap;
  end
  else if Msg.MsgID = $20010017 then DestroyHS
  else inherited MsgProc(Msg, Sender);
end;

function TMapLevel.GetEngine: TEngine;
begin
  Result := FEngine;
end;

function TMapLevel.GetChild(Index: Integer): TEObject;
begin
  Result := TMapField(Index * FFieldSize + Integer(FFields));
end;

procedure TMapLevel.SetChild(Index: Integer; Child: TEObject);
begin
  raise Exception.Create('Cannot set child in TMapLevel');
end;

function TMapLevel.AddChild(Child: TEObject): Integer;
begin
  raise Exception.Create('Cannot add child to TMapLevel');
end;

function TMapLevel.RemoveChild(Child: TEObject): Integer;
begin
  raise Exception.Create('Cannot remove from TMapLevel');
end;

function TMapLevel.GetCount: Integer;
begin
  Result := FCount;
end;

function TMapLevel.GetField(X: Integer; Y: Integer): TMapField;
begin
  Result := TMapField(FYOffsets^[Y] + FXOffsets^[X]);
end;

procedure TMapLevel.CreateMapFieldList(AWidth: Integer; AHeight: Integer);
var
  FieldClass: TEObjectClass;
  Y: Integer;
  X: Integer;
  RowSize: Integer;
  HN: Integer;
  Offset: Integer;
begin
  DestroyMapFieldList;
  FieldClass := MapFieldClass;
  FWidth := AWidth;
  FHeight := AHeight;
  FCount := FWidth * FHeight;
  FFieldSize := FieldClass.InstanceSize;
  FFieldsSize := FFieldSize * FWidth * FHeight;
  GetMem(FFields, FFieldsSize);
  MapFieldMemory := FFields;
  for Y := 0 to FHeight - 1 do
    for X := 0 to FWidth - 1 do
      with TMapField(FieldClass.Create(Self)) do
      begin
        FXhx := X;
        FYhx := Y;
        FLhx := Self.FLhx;
        MapFieldMemory := Pointer(Integer(MapFieldMemory) + Self.FFieldSize);
      end;
  MapFieldMemory := nil;
  RowSize := FWidth * FFieldSize;
  FillChar(FHNOffsets, SizeOf(FHNOffsets), 0);
  for HN := 1 to 6 do
  begin
    FHNOffsets[0, HN] := HNtoXYTable[0, HN].X * FFieldSize + HNtoXYTable[0, HN].Y * RowSize;
    FHNOffsets[1, HN] := HNtoXYTable[1, HN].X * FFieldSize + HNtoXYTable[1, HN].Y * RowSize;
  end;
  ReallocMem(FXOffsets, FWidth * 4);
  ReallocMem(FYOffsets, FHeight * 4);
  Offset := 0;
  for X := 0 to FWidth - 1 do
  begin
    FXOffsets^[X] := Offset;
    Inc(Offset, FFieldSize);
  end;
  Offset := Integer(FFields);
  for Y := 0 to FHeight - 1 do
  begin
    FYOffsets^[Y] := Offset;
    Inc(Offset, RowSize);
  end;
end;

procedure TMapLevel.DestroyMapFieldList;
var
  P: Pointer;
begin
  P := FFields;
  if P <> nil then
  begin
    FreeMem(P, FFieldsSize);
    FFieldsSize := 0;
    FFields := nil;
  end;
  ReallocMem(FXOffsets, 0);
  ReallocMem(FYOffsets, 0);
end;

procedure TMapLevel.DestroyHS;
var
  Progress: TMapProgress;
  Step: Integer;
  P: TMapField;
  I: Integer;
begin
  Progress.Level := FLhx;
  Progress.Percent := 0;
  Progress.ProgressType := ptDestroying;
  FMap.NotifyProgress(Progress);
  Step := FCount div 10;
  P := FFields;
  for I := 0 to FCount - 1 do
  begin
    P.DestroyHS;
    P := TMapField(Integer(P) + FFieldSize);
    Dec(Step);
    if Step = 0 then
    begin
      Inc(Progress.Percent, 10);
      FMap.NotifyProgress(Progress);
      Step := FCount div 10;
    end;
  end;
end;

procedure TMapLevel.UpdateTerrain;
var
  Progress: TMapProgress;
  Step: Integer;
  P: TMapField;
  I: Integer;
begin
  Progress.Level := FLhx;
  Progress.Percent := 0;
  Progress.ProgressType := ptUpdatingTerrain;
  FMap.NotifyProgress(Progress);
  Step := FCount div 5;
  P := FFields;
  for I := 0 to FCount - 1 do
  begin
    P.Initialize;
    P := TMapField(Integer(P) + FFieldSize);
    Dec(Step);
    if Step = 0 then
    begin
      Inc(Progress.Percent, 20);
      FMap.NotifyProgress(Progress);
      Step := FCount div 5;
    end;
  end;
  Progress.Percent := 100;
  FMap.NotifyProgress(Progress);
end;

procedure TMapLevel.Loaded;
var
  Progress: TMapProgress;
  Step: Integer;
  P: TMapField;
  I: Integer;
begin
  Progress.Level := FLhx;
  Progress.Percent := 0;
  Progress.ProgressType := ptInitializing;
  FMap.NotifyProgress(Progress);
  Step := FCount div 5;
  P := FFields;
  for I := 0 to FCount - 1 do
  begin
    P.Loaded;
    P := TMapField(Integer(P) + FFieldSize);
    Dec(Step);
    if Step = 0 then
    begin
      Inc(Progress.Percent, 20);
      FMap.NotifyProgress(Progress);
      Step := FCount div 5;
    end;
  end;
  Progress.Percent := 100;
  FMap.NotifyProgress(Progress);
end;

procedure TMapLevel.Activate;
var
  Progress: TMapProgress;
  Step: Integer;
  P: TMapField;
  I: Integer;
begin
  Progress.Level := FLhx;
  Progress.Percent := 0;
  Progress.ProgressType := ptActivating;
  FMap.NotifyProgress(Progress);
  Step := FCount div 5;
  P := FFields;
  for I := 0 to FCount - 1 do
  begin
    P.Activate;
    P := TMapField(Integer(P) + FFieldSize);
    Dec(Step);
    if Step = 0 then
    begin
      Inc(Progress.Percent, 20);
      FMap.NotifyProgress(Progress);
      Step := FCount div 5;
    end;
  end;
  Progress.Percent := 100;
  FMap.NotifyProgress(Progress);
end;

procedure TMapLevel.New(Settings: TNewHSMapSettings);
begin
  Clear;
  try
    CreateMapFieldList(Settings.Width, Settings.Height);
  except
    Clear;
    raise;
  end;
end;

{ TMapContainer }

type
  { an XYL value (TMapField.GetXYL, PackXYL) as its bytes }
  TXYLRec = packed record
    X: Shortint;
    Y: Shortint;
    L: Shortint;
    Reserved: Shortint;
  end;

constructor TMapContainer.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
end;

procedure TMapContainer.SetOwner(AOwner: TECustomNode);
begin
  inherited SetOwner(AOwner);
  FMap := THSMap(AOwner);
end;

procedure TMapContainer.ReadWrite(Stream: TEStorageStream);
var
  W: Byte;
  H: Byte;
  L: Byte;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smText] = [smRead] then
  begin
    FMap := THSMap(Owner);
    FEngine := Stream.Engine;
    FMap.FMapContainer := Self;
  end;
  W := FWidth;
  Stream.rwByte(W, 3);
  FWidth := W;
  H := FHeight;
  Stream.rwByte(H, 4);
  FHeight := H;
  L := FLevelCount;
  Stream.rwByte(L, 5);
  FLevelCount := L;
end;

procedure TMapContainer.MainReadWrite(Stream: TEStorageStream);
begin
  if not (msPreviewMode in THSMap(Owner).FStatus) then inherited MainReadWrite(Stream)
  else ReadWrite(Stream);
end;

function TMapContainer.GetEngine: TEngine;
begin
  Result := FEngine;
end;

class function TMapContainer.ClassID: Integer;
begin
  Result := $10103;
end;

procedure TMapContainer.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20000008 then FEngine := Msg.Engine;
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    UpdateTerrain;
    Activate;
  end;
end;

function TMapContainer.GetMapLevel(Index: Integer): TMapLevel;
begin
  Result := TMapLevel(FChildren.List^[Index]);
end;

function TMapContainer.GetFieldXYL(XYL: Integer): TMapField;
begin
  with TMapLevel(FChildren.List^[TXYLRec(XYL).L]) do
    Result := TMapField(FXOffsets^[TXYLRec(XYL).X] + FYOffsets^[TXYLRec(XYL).Y]);
end;

function TMapContainer.GetField(X: Integer; Y: Integer; L: Integer): TMapField;
begin
  with TMapLevel(FChildren.List^[L]) do
    Result := TMapField(FXOffsets^[X] + FYOffsets^[Y]);
end;

procedure TMapContainer.Clear;
begin
  inherited Clear;
  FWidth := 0;
  FHeight := 0;
  FLevelCount := 0;
end;

procedure TMapContainer.RemoveLevel(Index: Integer);
begin
  if (Index >= 0) and (Index < FChildren.Count) then
  begin
    TMapLevel(FChildren.List^[Index]).DestroyHS;
    TMapLevel(FChildren.List^[Index]).Free;
    Dec(FLevelCount);
  end;
end;

function TMapContainer.AddLevel(AClassID: Integer): Boolean;
var
  LevelClass: TEObjectClass;
  Level: TMapLevel;
begin
  LevelClass := FEngine.GetEClass(AClassID);
  if LevelClass <> nil then
  begin
    Level := TMapLevel(LevelClass.Create(Self));
    Level.FLhx := FLevelCount;
    FEngine.ActivateEObject(Level);
    Level.CreateMapFieldList(FWidth, FHeight);
    Inc(FLevelCount);
    Result := True;
  end
  else Result := False;
end;

procedure TMapContainer.New(Settings: TNewHSMapSettings);
var
  LevelClass: TEObjectClass;
  I: Integer;
  Level: TMapLevel;
begin
  Clear;
  try
    LevelClass := FEngine.GetEClass(Settings.MapLevelClassID);
    for I := 0 to Settings.Levels - 1 do
    begin
      Level := TMapLevel(LevelClass.Create(Self));
      Level.FLhx := I;
      FEngine.ActivateEObject(Level);
      Level.New(Settings);
    end;
    FWidth := Settings.Width;
    FHeight := Settings.Height;
    FLevelCount := Settings.Levels;
  except
    Clear;
    raise;
  end;
end;

procedure TMapContainer.RemoveHS(X: Integer; Y: Integer; L: Integer; HS: THexagonSprite);
var
  MapField: TMapField;
begin
  with TMapLevel(FChildren.List^[L]) do
    MapField := TMapField((Y * Self.FWidth + X) * FFieldSize + Integer(FFields));
  if MapField.RemoveHS(HS) <> -1 then
    if HS.GetLevel <= 15 then FMap.InvalidateStaticScene(X, Y, L);
end;

procedure TMapContainer.InsertHS(X: Integer; Y: Integer; L: Integer; HS: THexagonSprite;
  HN: Integer);
var
  MapField: TMapField;
begin
  with TMapLevel(FChildren.List^[L]) do
    MapField := TMapField((Y * Self.FWidth + X) * FFieldSize + Integer(FFields));
  MapField.AddHS(HS, HN);
  if HS.GetLevel <= 15 then FMap.InvalidateStaticScene(X, Y, L);
end;

procedure TMapContainer.UpdateTerrain;
var
  I: Integer;
begin
  for I := 0 to FLevelCount - 1 do
    TMapLevel(FChildren.List^[I]).UpdateTerrain;
end;

procedure TMapContainer.Loaded;
var
  I: Integer;
begin
  for I := 0 to FLevelCount - 1 do
    TMapLevel(FChildren.List^[I]).Loaded;
end;

procedure TMapContainer.Activate;
var
  I: Integer;
begin
  for I := 0 to FLevelCount - 1 do
    TMapLevel(FChildren.List^[I]).Activate;
end;
{ THSSet }

constructor THSSet.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle(GetControlStyle + [csReserved2]);
  FPlugInControl := TPlugInControl.Create(nil);
  FTerrainTypes := TStringList.Create;
  FOverlayTypes := TStringList.Create;
  FDecorationTypes := TStringList.Create;
  FHexagonControl := THexagonControl.Create(Self);
  FHexagonControl.MOClass := TAbstractHexagon;
  FRoadControl := TRoadControl.Create(Self);
  FRoadControl.MOClass := TAbstractRoad;
  FMapObjectResourceList := TMapObjectResourceList.Create(Self);
  FMapObjectResourceList.SetControlStyle([csStored, csShared]);
  FResourceEditSettings := TEResourceEditSettings.Create(Self);
  FResourceEditSettings.SetControlStyle([csStored, csShared]);
  FImageLibraryManager := TImageLibraryManager.Create(nil);
  FSFXManager := TSFXManager.Create(nil);
end;

destructor THSSet.Destroy;
var
  Msg: TEMsg;
begin
  FStatus := FStatus + [ssDestroying];
  InitMsg(Msg, $10404, Self);
  if (FActivatedEngine <> nil) and (FActivatedEngine.ControlNode <> nil) then
    FActivatedEngine.ControlNode.MsgProc(Msg, Self);
  inherited Destroy;
  FPlugInControl.Free;
  FTerrainTypes.Free;
  FTerrainTypes := nil;
  FOverlayTypes.Free;
  FOverlayTypes := nil;
  FDecorationTypes.Free;
  FDecorationTypes := nil;
  FImageLibraryManager.Free;
  FImageLibraryManager := nil;
  FSFXManager.Free;
  FSFXManager := nil;
  InitMsg(Msg, $10405, Self);
  if (FActivatedEngine <> nil) and (FActivatedEngine.ControlNode <> nil) then
    FActivatedEngine.ControlNode.MsgProc(Msg, Self);
  FStatus := FStatus - [ssDestroying];
end;

class function THSSet.ClassID: Integer;
begin
  Result := $10201;
end;

procedure THSSet.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then FActivatedEngine := Msg.Engine;
end;

procedure THSSet.Clear;
begin
  inherited Clear;
end;

procedure THSSet.ReadWrite(Stream: TEStorageStream);
begin
  SetEngine(Stream.Engine);
  FPlugInControl.Engine := Stream.Engine;
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 4);
  Stream.rwEObject(FMapObjectResourceList, 5);
  Stream.rwEObject(FResourceEditSettings, 6);
  Stream.rwEObject(FPlugInControl, 7);
end;

procedure THSSet.Activate(Edit: Boolean);
var
  Msg: TEMsg;
begin
  InitMsg(Msg, $10400, Self);
  GetEngine.ControlNode.MsgProc(Msg, Self);
  FStatus := FStatus + [ssActivated];
  if Edit then
  begin
    InitMsg(Msg, $10402, Self);
    GetEngine.ControlNode.MsgProc(Msg, Self);
    FStatus := FStatus + [ssEditting];
  end;
end;

procedure THSSet.DeActivate;
var
  Msg: TEMsg;
begin
  if ssActivated in FStatus then
  begin
    InitMsg(Msg, $10401, Self);
    GetEngine.ControlNode.MsgProc(Msg, Self);
    FStatus := FStatus - [ssActivated];
    if ssEditting in FStatus then
    begin
      InitMsg(Msg, $10403, Self);
      GetEngine.ControlNode.MsgProc(Msg, Self);
      FStatus := FStatus - [ssEditting];
    end;
  end;
end;

procedure THSSet.SetModified;
begin
  if ssEditting in FStatus then FStatus := FStatus + [ssModified];
end;

procedure THSSet.ResetModified;
begin
  FStatus := FStatus - [ssModified];
end;

procedure THSSet.SetEditting;
begin
  FStatus := FStatus + [ssEditting];
end;
procedure THSSet.ResetEditting;
begin
  FStatus := FStatus - [ssEditting];
end;
{$I inc\MAPOBJ.PAS}
{ THSMapMouse }

constructor THSMapMouse.Create;
begin
  inherited Create;
  FOnUp := TEventList.Create;
  FOnDown := TEventList.Create;
  FOnMove := TEventList.Create;
  FOnDblClick := TEventList.Create;
  FOnCaptureChanged := TEventList.Create;
  Reset;
end;

destructor THSMapMouse.Destroy;
begin
  FOnUp.Free;
  FOnDown.Free;
  FOnMove.Free;
  FOnDblClick.Free;
  FOnCaptureChanged.Free;
  inherited Destroy;
end;

procedure THSMapMouse.Reset;
begin
  FX := Low(Integer);
  FY := Low(Integer);
  FShift := [];
  FCursor := 0;
  SetCapture(nil);
end;

function THSMapMouse.GetCursor: Integer;
begin
  Result := FCursor;
end;

procedure THSMapMouse.SetCursor(Value: Integer);
begin
  FCursor := Value;
end;

function THSMapMouse.GetXhp: Integer;
begin
  if FX <> Low(Integer) then
  begin
    Result := FHSMap.FViewXhp + FX;
    if (Result > FHSMap.GetMaxXhp) or (Result < 0) then
      Result := Low(Integer);
  end
  else
    Result := Low(Integer);
end;

function THSMapMouse.GetYhp: Integer;
begin
  if FY <> Low(Integer) then
  begin
    Result := FHSMap.FViewYhp + FY;
    if (Result > FHSMap.GetMaxYhp) or (Result < 0) then
      Result := Low(Integer);
  end
  else
    Result := Low(Integer);
end;

{ Both GetXhx and GetYhx test the result against the width and the height of the map. }
function THSMapMouse.GetXhx: Integer;
var
  Y: Integer;
begin
  if FX <> Low(Integer) then
  begin
    HPtoHX(FHSMap.FViewXhp + FX, 0, Result, Y);
    if (Result < 0) or (FHSMap.FMapContainer.FWidth <= Result) or
      (FHSMap.FMapContainer.FHeight <= Result) then
      Result := -1;
  end
  else
    Result := -1;
end;

function THSMapMouse.GetYhx: Integer;
var
  X: Integer;
begin
  if FY <> Low(Integer) then
  begin
    HPtoHX(FHSMap.FViewXhp + FX, FHSMap.FViewYhp + FY, X, Result);
    if (Result < 0) or (FHSMap.FMapContainer.FWidth <= Result) or
      (FHSMap.FMapContainer.FHeight <= Result) then
      Result := -1;
  end
  else
    Result := -1;
end;

procedure THSMapMouse.SetCapture(Value: TObject);
begin
  if not (msChangingCapture in FStatus) and (Value <> FCapture) then
  begin
    FStatus := FStatus + [msChangingCapture];
    FCapture := Value;
    if Value = nil then
      FCursor := 0;
    FOnCaptureChanged.TriggerNotifyEvents(Self);
    FStatus := FStatus - [msChangingCapture];
  end;
end;

function THSMapMouse.MouseDown: Boolean;
begin
  Result := True;
  if (FCapture = nil) and (GetXhx <> -1) then
    if FButton = mbLeft then
    begin
      FHSMap.FSelection.SelectLocation(GetXhp, GetYhp, FHSMap.FViewL);
      Result := False;
    end
    else if (FButton = mbRight) and not (msEditting in FHSMap.FStatus) then
    begin
      FHSMap.FSelection.UnselectLocation;
      Result := False;
    end;
end;

{ Down and Up set FX twice when the position is outside (an original slip for FY). }
procedure THSMapMouse.Down(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if not FIgnoreDown then
  begin
    if (X >= 0) and (Y >= 0) then
    begin
      FX := X;
      FY := Y;
    end
    else
    begin
      FX := Low(Integer);
      FX := Low(Integer);
    end;
    FButton := Button;
    FShift := Shift;
    if MouseDown then
      FOnDown.TriggerNotifyEvents(Self);
  end
  else
    FIgnoreDown := False;
end;

function THSMapMouse.MouseUp: Boolean;
begin
  Result := True;
end;

procedure THSMapMouse.Up(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (X >= 0) and (Y >= 0) then
  begin
    FX := X;
    FY := Y;
  end
  else
  begin
    FX := Low(Integer);
    FX := Low(Integer);
  end;
  FButton := Button;
  FShift := Shift;
  if MouseUp then
    FOnUp.TriggerNotifyEvents(Self);
end;

function THSMapMouse.MouseMove: Boolean;
begin
  Result := True;
end;

procedure THSMapMouse.Move(Shift: TShiftState; X, Y: Integer);
begin
  if (X >= 0) and (Y >= 0) and (X <= FHSMap.GetMaxXhp) and (Y <= FHSMap.GetMaxYhp) then
  begin
    FX := X;
    FY := Y;
  end
  else
  begin
    FX := Low(Integer);
    FY := Low(Integer);
  end;
  if MouseMove then
    FOnMove.TriggerNotifyEvents(Self);
end;

function THSMapMouse.MouseDblClick: Boolean;
begin
  Result := True;
end;

procedure THSMapMouse.DblClick;
begin
  if GetXhp <> Low(Integer) then
    if MouseDblClick then
      FOnDblClick.TriggerNotifyEvents(Self);
end;

{ THexagonSpriteSelection }

constructor THexagonSpriteSelection.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FLocationHS := TList.Create;
  FOnSelect := TEventList.Create;
  FOnDeselect := TEventList.Create;
end;

destructor THexagonSpriteSelection.Destroy;
begin
  inherited Destroy;
  FLocationHS.Free;
  FOnSelect.Free;
  FOnSelect := nil;
  FOnDeselect.Free;
  FOnDeselect := nil;
end;

procedure THexagonSpriteSelection.TriggerDeselectEvent(HS: THexagonSprite);
begin
  FEventHS := HS;
  FOnDeselect.TriggerNotifyEvents(Owner);
end;

procedure THexagonSpriteSelection.TriggerSelectEvent(HS: THexagonSprite);
begin
  FEventHS := HS;
  FOnSelect.TriggerNotifyEvents(Owner);
end;

procedure THexagonSpriteSelection.Unselect(HS: THexagonSprite);
var
  I: Integer;
begin
  I := FChildren.IndexOf(HS);
  FLocationHS.Remove(HS);
  if I <> -1 then
  begin
    FChildren.Remove(HS);
    if FChildren.IndexOf(HS) = -1 then
      if HS.GetSelected then
        HS.Unselect;
    TriggerDeselectEvent(HS);
  end;
end;

procedure THexagonSpriteSelection.Select(HS: THexagonSprite);
begin
  FChildren.Add(HS);
  HS.Select;
  TriggerSelectEvent(HS);
end;

procedure THexagonSpriteSelection.UnselectAll;
begin
  while FChildren.Count <> 0 do
    Unselect(THexagonSprite(FChildren.List^[FChildren.Count - 1]));
end;

function THexagonSpriteSelection.FindClass(AClass: TClass): THexagonSprite;
var
  HS: THexagonSprite;
  I: Integer;
begin
  Result := nil;
  I := 0;
  while (I <> Count) and (Result = nil) do
  begin
    HS := THexagonSprite(FChildren.List^[I]);
    if HS is AClass then
      Result := THexagonSprite(FChildren.List^[I]);
    Inc(I);
  end;
end;

function THexagonSpriteSelection.GetHS(Index: Integer): THexagonSprite;
begin
  Result := THexagonSprite(FChildren.List^[Index]);
end;

procedure THexagonSpriteSelection.Clear;
begin
  FChildren.Clear;
  FLocationHS.Clear;
end;

function THexagonSpriteSelection.CanSelectLocation(Xhp, Yhp, Lhp: Integer): Boolean;
var
  Xhx, Yhx: Integer;
  MapF: TMapField;
  I: Integer;
begin
  HPtoHX(Xhp, Yhp, Xhx, Yhx);
  if (Xhx >= 0) and (THSMap(Owner).FMapContainer.FWidth > Xhx) and
    (THSMap(Owner).FMapContainer.FHeight > Yhx) and (Yhx >= 0) then
  begin
    MapF := THSMap(Owner).FMapContainer.GetField(Xhx, Yhx, Lhp);
    I := MapF.Count;
    Result := False;
    while not Result and (I <> 0) do
    begin
      Dec(I);
      Result := THexagonSprite(PPointerList(MapF.FHSList)^[I]).CanSelect(Xhp, Yhp);
    end;
  end
  else
    Result := False;
end;

procedure THexagonSpriteSelection.SelectLocationHS(HS: THexagonSprite);
begin
  FLocationHS.Add(HS);
  Select(HS);
end;

procedure THexagonSpriteSelection.SelectLocation(Xhp, Yhp, Lhp: Integer);
var
  N: Integer;
  Xhx, Yhx: Integer;
  MapF: TMapField;
  HS: THexagonSprite;
  I: Integer;
begin
  HPtoHX(Xhp, Yhp, Xhx, Yhx);
  MapF := THSMap(Owner).FMapContainer.GetField(Xhx, Yhx, Lhp);
  I := FindLocationHSIndex(MapF) - 1;
  HS := nil;
  if I < 0 then
    I := MapF.Count - 1;
  N := MapF.Count;
  while (N <> 0) and (HS = nil) do
  begin
    HS := THexagonSprite(PPointerList(MapF.FHSList)^[I]);
    if not HS.CanSelect(Xhp, Yhp) then
      HS := nil;
    Dec(N);
    Dec(I);
    if I < 0 then
      I := MapF.Count - 1;
  end;
  if HS <> nil then
    if FLocationHS.IndexOf(HS) = -1 then
    begin
      UnselectLocation;
      SelectLocationHS(HS);
    end;
end;

procedure THexagonSpriteSelection.SelectLocationHX(Xhx, Yhx, Lhx: Integer);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  SelectLocation(Xhp, Yhp, Lhx);
end;

procedure THexagonSpriteSelection.UnselectLocation;
begin
  while FLocationHS.Count <> 0 do
    Unselect(FLocationHS.Last);
end;

function THexagonSpriteSelection.FindLocationHSIndex(MapF: TMapField): Integer;
var
  I: Integer;
  Xhp, Yhp: Integer;
  HS: THexagonSprite;
begin
  Result := -1;
  if FLocationHS.Count <> 0 then
  begin
    I := 0;
    HXtoHP(Shortint(MapF.FXhx), Shortint(MapF.FYhx), Xhp, Yhp);
    while (Result = -1) and (I <> MapF.Count) do
    begin
      HS := THexagonSprite(PPointerList(MapF.FHSList)^[I]);
      if HS.CanSelect(Xhp, Yhp) then
        if FLocationHS.IndexOf(HS) <> -1 then
          Result := I;
      Inc(I);
    end;
  end;
end;
{ TVisibilityList }

procedure TVisibilityList.Grow;
begin
  Resize(FCapacity + 500);
end;

procedure TVisibilityList.QuickClear;
begin
  FCount := 0;
end;

function TVisibilityList.RemoveChild(Child: TEObject): Integer;
begin
  with THexagonSprite(Child) do
    if GetVisible then SetVisible(False);
  Result := inherited RemoveChild(Child);
end;
{$I inc\HSMAP.PAS}
{$I inc\LibImgHS.PAS}
{ Group A, third part: the unit routines (code $5560DCF4..$5560E81B). HXtoV, HXtoH, HVtoHX, HPtoHX,
  HPtoHXs and WalkToNextHN are assembler in the original (hand-scheduled code, explicit RETs). }

{ Hexagon coordinates }

function dHXtoRad(X1, Y1, X2, Y2: Integer): Integer;
var
  dX, dY, Half: Integer;
  Up: Boolean;
begin
  dX := Abs(X1 - X2);
  dY := Abs(Y1 - Y2);
  if dY >= dX then
  begin
    Up := Odd(dX) and ((not Odd(X1) and (Y1 < Y2)) or (not Odd(X2) and (Y2 < Y1)));
    if Up then
      Result := (dX + 1) shr 1 + dY
    else
      Result := dX shr 1 + dY;
  end
  else
  begin
    Result := dX;
    Half := (dX + 1) shr 1;
    if Odd(dX) and ((not Odd(X1) and (Y1 < Y2)) or (not Odd(X2) and (Y2 < Y1))) then Inc(dY);
    if dY > Half then Inc(Result, dY - Half);
  end;
end;

function ConnectingHX(X1, Y1, X2, Y2: Integer): Boolean;
begin
  if X1 = X2 then
    Result := (Y1 = Y2 + 1) or (Y1 = Y2 - 1)
  else if (X1 = X2 - 1) or (X1 = X2 + 1) then
  begin
    if not Odd(X1) then
      Result := (Y1 = Y2) or (Y1 = Y2 + 1)
    else
      Result := (Y1 = Y2) or (Y1 = Y2 - 1);
  end
  else
    Result := False;
end;

function HXtoRad(Xhx, Yhx: Integer): Integer;
var
  dX, dY, Half: Integer;
  Up: Boolean;
begin
  dX := Abs(Xhx);
  dY := Abs(Yhx);
  if dY >= dX then
  begin
    Up := Odd(dX) and ((Yhx > 0) or (not Odd(Xhx) and (Yhx < 0)));
    if Up then
      Result := (dX + 1) shr 1 + dY
    else
      Result := dX shr 1 + dY;
  end
  else
  begin
    Result := dX;
    Half := (dX + 1) shr 1;
    if Odd(dX) and ((Yhx > 0) or (not Odd(Xhx) and (Yhx < 0))) then Inc(dY);
    if dY > Half then Inc(Result, dY - Half);
  end;
end;

function HXtoV(Xhx, Yhx: Integer): Integer; assembler;
asm
        TEST    EAX,EAX
        JS      @@1
        INC     EAX
        SAR     EAX,1
        ADD     EAX,EDX
        RET
@@1:    SAR     EAX,1
        ADC     EAX,EDX
end;

function HXtoH(Xhx, Yhx: Integer): Integer; assembler;
asm
        ADD     EDX,EDX
        SUB     EAX,EDX
        JNS     @@1
        DEC     EAX
        SAR     EAX,1
        ADC     EAX,0
        RET
@@1:    SAR     EAX,1
end;

procedure HVtoHX(H, V: Integer; var Xhx, Yhx: Integer); assembler;
asm
        PUSH    EBX
        LEA     EBX,[EAX+EDX]
        SUB     EDX,EAX
        JS      @@1
        MOV     EAX,Yhx
        MOV     [ECX],EBX
        SAR     EDX,1
        POP     EBX
        MOV     [EAX],EDX
        JMP     @@2
@@1:    SAR     EDX,1
        MOV     EAX,Yhx
        MOV     [ECX],EBX
        POP     EBX
        MOV     [EAX],EDX
@@2:
end;

procedure HXtoHV(Xhx, Yhx: Integer; var H, V: Integer);
begin
  H := HXtoH(Xhx, Yhx);
  V := HXtoV(Xhx, Yhx);
end;

{ Hexagon numbers }

function HNtoRad(HN: Integer): Integer;
begin
  if HN < 37 then
    Result := HNtoRadTable[HN]
  else
    { the original lacks the "div 6" of InvHN and HNtoHX here }
    Result := Trunc(Sqrt((HN - 1) * 12 + 9)) + 3;
end;

function RadToHN(Rad: Integer): Integer;
begin
  if Rad <= 10 then
    Result := RadToHNTable[Rad]
  else
    Result := (Rad - 1) * Rad * 3 + 1;
end;

function InvHN(HN: Integer): Integer;
var
  R, N: Integer;
begin
  if HN < 37 then
    Result := InvHNTable[HN]
  else
  begin
    R := (Trunc(Sqrt((HN - 1) * 12 + 9)) + 3) div 6;
    N := R * 6;
    Result := (HN - (R - 1) * R * 3 - 1 + N shr 1) mod N + ((R - 1) * R * 3 + 1);
  end;
end;

function HXtoHN(Xhx, Yhx: Integer): Integer;
var
  R, Side, Pos: Integer;
  H, V: Integer;
begin
  R := HXtoRad(Xhx, Yhx);
  if R <> 0 then
  begin
    HXtoHV(Xhx, Yhx, H, V);
    if R = H then
    begin
      Side := 0;
      Pos := V + R;
    end
    else if R = V then
    begin
      Side := 2;
      Pos := -H;
    end
    else if -R = H then
    begin
      Side := 3;
      Pos := -V + R;
    end
    else if -R = V then
    begin
      Side := 5;
      Pos := H;
    end
    else if R = Xhx then
    begin
      Side := 1;
      Pos := (Xhx + 1) div 2 + Yhx;
    end
    else if R = -Xhx then
    begin
      Side := 4;
      Pos := -Yhx - Xhx div 2;
    end
    else
      raise Exception.Create('arithemetic error!');
    Result := Pos + ((R - 1) * R * 3 + 1 + Side * R);
  end
  else
    Result := 0;
end;

procedure HNtoHX(HN: Integer; var Xhx, Yhx: Integer);
var
  R, Side, Pos: Integer;
begin
  if HN < 37 then
  begin
    Xhx := HNtoHXTable[HN, 0];
    Yhx := HNtoHXTable[HN, 1];
  end
  else
  begin
    R := (Trunc(Sqrt((HN - 1) * 12 + 9)) + 3) div 6;
    HN := HN - (R - 1) * R * 3 - 1;
    Side := HN div R;
    Pos := HN mod R;
    case Side of
      0: HVtoHX(R, Pos - R, Xhx, Yhx);
      1:
        begin
          Xhx := R;
          Yhx := Pos - (R + 1) div 2;
        end;
      2: HVtoHX(-Pos, R, Xhx, Yhx);
      3: HVtoHX(-R, R - Pos, Xhx, Yhx);
      4:
        begin
          Xhx := -R;
          Yhx := -Pos + R div 2;
        end;
      5: HVtoHX(Pos, -R, Xhx, Yhx);
    end;
  end;
end;

procedure CenterHNtoHX(Xhx, Yhx, HN: Integer; var NewXhx, NewYhx: Integer);
var
  R, Side, Pos: Integer;
begin
  if HN <> 0 then
  begin
    R := (Trunc(Sqrt((HN - 1) * 12 + 9)) + 3) div 6;
    HN := HN - (R - 1) * R * 3 - 1;
    Side := HN div R;
    Pos := HN mod R;
    case Side of
      0: HVtoHX(R, Pos - R, NewXhx, NewYhx);
      1:
        begin
          NewXhx := R;
          NewYhx := Pos - (R + 1) div 2;
        end;
      2: HVtoHX(-Pos, R, NewXhx, NewYhx);
      3: HVtoHX(-R, R - Pos, NewXhx, NewYhx);
      4:
        begin
          NewXhx := -R;
          NewYhx := -Pos + R div 2;
        end;
      5: HVtoHX(Pos, -R, NewXhx, NewYhx);
    end;
  end
  else
  begin
    NewXhx := 0;
    NewYhx := 0;
  end;
  if Odd(Xhx) and Odd(NewXhx) then
    NewYhx := NewYhx + Yhx + 1
  else
    NewYhx := NewYhx + Yhx;
  NewXhx := NewXhx + Xhx;
end;

procedure TranslateHX(FromXhx, FromYhx, ToXhx, ToYhx, Xhx, Yhx: Integer; var NewXhx, NewYhx: Integer);
var
  dX, dY: Integer;
begin
  dX := ToXhx - FromXhx;
  dY := ToYhx - FromYhx;
  if Odd(dX) then
    if Odd(FromXhx) then
    begin
      if not Odd(Xhx) then Dec(dY);
    end
    else if Odd(Xhx) then Inc(dY);
  NewXhx := Xhx + dX;
  NewYhx := Yhx + dY;
end;

procedure TranslateZeroHX(Xhx, Yhx, dXhx, dYhx: Integer; var NewXhx, NewYhx: Integer);
begin
  if Odd(Xhx) and Odd(dXhx) then
    NewYhx := dYhx + Yhx + 1
  else
    NewYhx := dYhx + Yhx;
  NewXhx := dXhx + Xhx;
end;

function dHXtoHN(X1, Y1, X2, Y2: Integer): Integer;
begin
  TranslateHX(X1, Y1, 0, 0, X2, Y2, X2, Y2);
  Result := HXtoHN(X2, Y2);
end;

function dHXtoHNfast(X1, Y1, X2, Y2: Integer): Integer;
begin
  if X1 = X2 then
  begin
    if Y2 < Y1 then
      Result := 1
    else if Y2 > Y1 then
      Result := 4
    else
      Result := 0;
  end
  else if not Odd(X1) then
  begin
    if X2 < X1 then
    begin
      if Y2 < Y1 then Result := 6 else Result := 5;
    end
    else
      if Y2 < Y1 then Result := 2 else Result := 3;
  end
  else
  begin
    if X2 < X1 then
    begin
      if Y2 > Y1 then Result := 5 else Result := 6;
    end
    else
      if Y2 > Y1 then Result := 3 else Result := 2;
  end;
end;

{ Pixel coordinates }

procedure HXtoHP(Xhx, Yhx: Integer; var Xhp, Yhp: Integer);
begin
  Xhp := Xhx * 32 + 8;
  Yhp := Yhx * 32 + (Xhx and 1) * 16;
end;

procedure HPtoHX(Xhp, Yhp: Integer; var Xhx, Yhx: Integer); assembler;
asm
        SUB     EAX,8
        SAR     EAX,5
        MOV     [ECX],EAX
        AND     EAX,1
        MOV     ECX,Yhx
        SHL     EAX,4
        SUB     EDX,EAX
        SAR     EDX,5
        MOV     [ECX],EDX
end;

{ The same code as HPtoHX: it stores 4 bytes into each Shortint (original bug) }
procedure HPtoHXs(Xhp, Yhp: Integer; var Xhx, Yhx: Shortint); assembler;
asm
        SUB     EAX,8
        SAR     EAX,5
        MOV     [ECX],EAX
        AND     EAX,1
        MOV     ECX,Yhx
        SHL     EAX,4
        SUB     EDX,EAX
        SAR     EDX,5
        MOV     [ECX],EDX
end;

function HPtoHN(Xhp, Yhp: Integer): Integer;
begin
  HPtoHX(Xhp, Yhp, Xhp, Yhp);
  Result := HXtoHN(Xhp, Yhp);
end;

procedure HNtoHP(HN: Integer; var Xhp, Yhp: Integer);
begin
  HNtoHX(HN, Xhp, Yhp);
  HXtoHP(Xhp, Yhp, Xhp, Yhp);
  Dec(Xhp, 8);
end;

{ Hexagon directions }

function HXtoHT(Xhx, Yhx: Integer): Integer;
var
  H: Integer;
begin
  H := HXtoH(Xhx, Yhx);
  if H > 0 then
  begin
    if Xhx < 0 then
      Result := 6
    else if HXtoV(Xhx, Yhx) < 0 then
      Result := 1
    else
      Result := 2;
  end
  else if H < 0 then
  begin
    if Xhx > 0 then
      Result := 3
    else if HXtoV(Xhx, Yhx) > 0 then
      Result := 4
    else
      Result := 5;
  end
  else if Xhx < 0 then
    Result := 6
  else if Xhx > 0 then
    Result := 3
  else
    Result := 0;
end;

function dHXtoHT(X1, Y1, X2, Y2: Integer): Integer;
var
  dX, dY: Integer;
begin
  X2 := X2 - X1;
  Y2 := Y2 - Y1;
  if Odd(X2) and Odd(X1) then Dec(Y2);
  Result := HXtoHT(X2, Y2);
end;

{ Walks }

procedure GenerateWalkAroundRoute(Xhx, Yhx: Integer; CallBack: TWalkAroundRouteCallBack);
var
  NXhx, NYhx, TXhx, TYhx: Integer;
  HN: Integer;
  Found, Cancel: Boolean;
begin
  Cancel := False;
  NXhx := $FFFF;
  Found := False;
  HN := 0;
  while not Found and (HN <> 6) and not Cancel do
  begin
    Inc(HN);
    CenterHNtoHX(Xhx, Yhx, HN, NXhx, NYhx);
    Found := CallBack(NXhx, NYhx, Cancel);
  end;
  if Found and not Cancel then
  begin
    Xhx := NXhx;
    Yhx := NYhx;
    while not Cancel do
    begin
      Inc(HN, 2);
      if HN > 6 then Dec(HN, 6);
      repeat
        CenterHNtoHX(Xhx, Yhx, HN, TXhx, TYhx);
        Dec(HN);
        { the original asks for NXhx, NYhx here, not for the hexagon it just stepped to }
        Found := CallBack(NXhx, NYhx, Cancel);
      until Found and not Cancel;
      Xhx := TXhx;
      Yhx := TYhx;
    end;
  end;
end;

procedure InitHNWalk(var Walk: THNWalkData; Xhx, Yhx, Radius: Integer);
begin
  if Radius = 0 then
  begin
    Walk.HN := 0;
    Walk.Side := 5;
  end
  else
  begin
    Walk.HN := (Radius - 1) * Radius * 3 + 1;
    Walk.Side := 0;
  end;
  Walk.CenterX := Xhx;
  Walk.CenterY := Yhx;
  Walk.Radius := Radius;
  Walk.X := Xhx;
  Walk.Y := Yhx - Radius;
  Walk.Step := 0;
end;

procedure WalkToNextHN(var Walk: THNWalkData); assembler;
asm
        PUSH    EBX
        PUSH    ESI
        MOV     EBX,[EAX].THNWalkData.HN
        MOV     ECX,[EAX].THNWalkData.X
        INC     EBX
        MOV     EDX,[EAX].THNWalkData.Step
        AND     ECX,1
        MOV     [EAX].THNWalkData.HN,EBX
        INC     EDX
        MOV     EBX,[EAX].THNWalkData.Side
        SHL     ECX,6
        MOV     [EAX].THNWalkData.Step,EDX
        CMP     EDX,[EAX].THNWalkData.Radius
        JL      @@Step
        CMP     EBX,5
        JNE     @@Side
        { next ring }
        XOR     EDX,EDX
        INC     [EAX].THNWalkData.Radius
        MOV     [EAX].THNWalkData.Side,EDX
        MOV     [EAX].THNWalkData.Step,EDX
        MOV     ECX,[EAX].THNWalkData.CenterY
        MOV     EDX,[EAX].THNWalkData.CenterX
        SUB     ECX,[EAX].THNWalkData.Radius
        MOV     [EAX].THNWalkData.X,EDX
        MOV     [EAX].THNWalkData.Y,ECX
        POP     ESI
        POP     EBX
        RET
        { next side }
@@Side: LEA     ESI,[ECX+EBX*8+HNWalkTable]
        INC     EBX
        MOV     EDX,[EAX].THNWalkData.X
        MOV     [EAX].THNWalkData.Side,EBX
        MOV     EBX,[EAX].THNWalkData.Y
        MOV     ECX,[ESI+4]
        MOV     ESI,[ESI]
        ADD     ECX,EBX
        ADD     EDX,ESI
        MOV     [EAX].THNWalkData.Y,ECX
        XOR     ESI,ESI
        MOV     [EAX].THNWalkData.X,EDX
        MOV     [EAX].THNWalkData.Step,ESI
        POP     ESI
        POP     EBX
        RET
        { next hexagon on the side }
@@Step: LEA     ESI,[ECX+EBX*8+HNWalkTable]
        MOV     EBX,[EAX].THNWalkData.Y
        MOV     EDX,[EAX].THNWalkData.X
        MOV     ECX,[ESI+4]
        MOV     ESI,[ESI]
        ADD     ECX,EBX
        ADD     EDX,ESI
        MOV     [EAX].THNWalkData.Y,ECX
        MOV     [EAX].THNWalkData.X,EDX
        POP     ESI
        POP     EBX
        RET
end;

{ Locations }

function PackXYL(X, Y, L: Shortint): TXYL;
begin
  Result.X := X;
  Result.Y := Y;
  Result.L := L;
  Result.Flag := 0;
end;

function LocationsConnected(List: TXYLList): Boolean;
var
  Locations: TXYLList;
  I: Integer;
  XYL: TXYL;

  procedure Connect(XYL: TXYL);
  var
    Walk: THNWalkData;
    I: Integer;
  begin
    InitHNWalk(Walk, XYL.X, XYL.Y, 1);
    while Walk.Radius <= 1 do
    begin
      for I := 0 to Locations.Count - 1 do
        if Locations[I].Flag = 0 then
          if Integer(Locations[I]) = Integer(PackXYL(Walk.X, Walk.Y, XYL.L)) then
          begin
            Locations.FList^[I].Flag := 1;
            Connect(Locations[I]);
          end;
      WalkToNextHN(Walk);
    end;
  end;

begin
  Locations := TXYLList.Create;
  for I := 0 to List.Count - 1 do
  begin
    XYL := List[I];
    XYL.Flag := 0;
    if Locations.IndexOf(XYL) = -1 then Locations.Add(XYL);
  end;
  if Locations.Count > 0 then
    if Locations.Count > 1 then
    begin
      Locations.FList^[0].Flag := 1;
      Connect(Locations[0]);
      Result := True;
      for I := 0 to Locations.Count - 1 do
        if Locations[I].Flag <> 1 then Result := False;
    end
    else
      Result := True
  else
    Result := False;
  Locations.Free;
end;
{ TMORTerrainControl }

constructor TMORTerrainControl.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FResources := TList.Create;
  FMOClass := TMapObject;
  FTries := 5;
end;

destructor TMORTerrainControl.Destroy;
begin
  Clear;
  FResources.Free;
  FResources := nil;
  inherited Destroy;
end;

function TMORTerrainControl.GetControlStyle: TEControlStyles;
begin
  Result := [csShared];
end;

procedure TMORTerrainControl.Clear;
var
  I: Integer;
begin
  if FResources <> nil then
    for I := FResources.Count - 1 downto 0 do
    begin
      TObject(FResources[I]).Free;
      FResources.Delete(I);
    end;
end;

procedure TMORTerrainControl.Initialize;
var
  I: Integer;
begin
  Clear;
  for I := 0 to FHSEngine.FHSSet.TerrainTypes.Count - 1 do
    FResources.Add(TList.Create);
end;

procedure TMORTerrainControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    FHSEngine := THSEngine(Msg.Engine);
    Initialize;
  end;
end;

function TMORTerrainControl.GetRndResource(TerrainType: Integer; AClassID: Integer): TMapObjectResource;
var
  List: TList;
  I: Integer;
begin
  List := FResources[TerrainType];
  if List.Count <> 0 then
  begin
    I := 0;
    Result := nil;
    while (I <> FTries) and (Result = nil) do
    begin
      Result := List.List^[Random(List.Count)];
      if Result.ClassID <> AClassID then Result := nil;
      Inc(I);
    end;
    if Result = nil then
    begin
      I := 0;
      while (I <> List.Count) and (Result = nil) do
      begin
        Result := List.List^[I];
        if Result.ClassID <> AClassID then Result := nil;
        Inc(I);
      end;
    end;
  end
  else
    Result := nil;
end;

procedure TMORTerrainControl.RegisterResource(Resource: TMapObjectResource);
var
  TerrainType: Shortint;
begin
  TerrainType := Resource.FTerrainList.GetTerrain(0);
  if (TerrainType >= 0) and (TerrainType < FResources.Count) then
  begin
    if (TList(FResources.List^[TerrainType]).IndexOf(Resource) <> -1) or (Resource = nil) then
      raise Exception.Create('Resource double defined (TMORTerrainControl)');
    TList(FResources.List^[TerrainType]).Add(Resource);
  end;
end;

function TMORTerrainControl.CreateMO(TerrainType: Shortint): TMapObject;
var
  I: Integer;
  List: TList;
  Count: Integer;
  R: TMapObjectResource;
begin
  I := TerrainType;
  List := FResources[I];
  Count := List.Count;
  if Count <> 0 then
  begin
    R := List.List^[Random(Count)];
    Result := TMapObject(R.CreateResourceUser);
  end
  else
    Result := nil;
end;

function TMORTerrainControl.Place(Container: TMapContainer; X, Y, L: Shortint; TerrainType: Shortint): TMapObject;
var
  List: TList;
  R: TMapObjectResource;
  MapF: TMapField;
  MO: TMapObject;
begin
  Result := nil;
  List := FResources[TerrainType];
  if List.Count <> 0 then
  begin
    R := nil;
    MapF := TMapField(Container.GetField(X, Y, L));
    MO := TMapObject(MapF.FindOwnedHS(FMOClass));
    if MO <> nil then
    begin
      R := GetRndResource(TerrainType, MO.FResource.ClassID);
      if R <> nil then
      begin
        MO.SetResource(R);
        MapF.UpdateTerrain;
        Result := MO;
      end;
    end;
    if R = nil then
    begin
      R := List.List^[Random(List.Count)];
      if R <> nil then
        Result := TMapObject(R.PlaceResourceUser(Container.FMap, X, Y, L));
    end;
  end;
end;

function TMORTerrainControl.PlaceClass(Container: TMapContainer; X, Y, L: Shortint; TerrainType: Shortint;
  AClassID: Integer): TMapObject;
var
  R: TMapObjectResource;
  MapF: TMapField;
  MO: TMapObject;
begin
  Result := nil;
  if TList(FResources[TerrainType]).Count <> 0 then
  begin
    R := nil;
    MapF := TMapField(Container.GetField(X, Y, L));
    MO := TMapObject(MapF.FindOwnedHS(FMOClass));
    if (MO <> nil) and (MO.FResource.ClassID = AClassID) then
    begin
      R := GetRndResource(TerrainType, MO.FResource.ClassID);
      if R <> nil then
      begin
        MO.SetResource(R);
        MapF.UpdateTerrain;
        Result := MO;
      end;
    end;
    if R = nil then
    begin
      R := GetRndResource(TerrainType, AClassID);
      if R <> nil then
        Result := TMapObject(R.PlaceResourceUser(Container.FMap, X, Y, L));
    end;
  end;
end;
{ THSMapViewer }

constructor THSMapViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FStaticSurfaceValid := False;
  FOnSceneChanged := nil;
end;

{ Leaves the map's OnChangeView set (original slip). }
destructor THSMapViewer.Destroy;
begin
  if FHSMap <> nil then
  begin
    FHSMap.FOnCenterView := nil;
    FHSMap.FOnViewLevel := nil;
  end;
  FStaticSurface.Free;
  inherited Destroy;
end;

procedure THSMapViewer.ChangeScene(Xhp, Yhp, Lhp: Integer);
begin
  if FHSMap <> nil then
  begin
    SetSceneX(Xhp);
    SetSceneY(Yhp);
    SetSceneL(Lhp);
    if FHSMap.SetViewPort(FSceneX, FSceneY, FSceneL, FSceneWidth, FSceneHeight) and
      Assigned(FOnSceneChanged) then
      FOnSceneChanged(Self);
  end;
end;

procedure THSMapViewer.CenterScene(Xhx, Yhx, Lhx: Integer);
var
  Xhp, Yhp: Integer;
begin
  if FHSMap <> nil then
  begin
    HXtoHP(Xhx, Yhx, Xhp, Yhp);
    SetSceneX(Xhp + 16 - FSceneWidth shr 1);
    SetSceneY(Yhp + 16 - FSceneHeight shr 1);
    SetSceneL(Lhx);
    if FHSMap.SetViewPort(FSceneX, FSceneY, FSceneL, FSceneWidth, FSceneHeight) and
      Assigned(FOnSceneChanged) then
      FOnSceneChanged(Self);
  end;
end;

procedure THSMapViewer.SetHSMap(Value: THSMap);
begin
  FHSMap := Value;
  if FHSMap <> nil then
    with FHSMap do
    begin
      FOnCenterView := CenterScene;
      FOnChangeView := ChangeScene;
      FOnViewLevel := SetSceneL;
    end;
end;

procedure THSMapViewer.SetSceneL(Value: Integer);
begin
  if FHSMap <> nil then
  begin
    if Value < 0 then
      Value := 0;
    if Value >= FHSMap.FMapContainer.FLevelCount then
      Value := FHSMap.FMapContainer.FLevelCount - 1;
    FSceneL := Value;
  end;
end;

procedure THSMapViewer.SetSceneX(Value: Integer);
begin
  if FHSMap <> nil then
    with FHSMap do
    begin
      if Value < 16 then
        Value := 16;
      if GetMaxXhp < FSceneWidth + Value + 16 then
        Self.FSceneX := GetMaxXhp - FSceneWidth - 16
      else
        Self.FSceneX := Value;
    end;
end;

procedure THSMapViewer.SetSceneY(Value: Integer);
begin
  if FHSMap <> nil then
    with FHSMap do
    begin
      if Value < 16 then
        Value := 16;
      if GetMaxYhp - 16 < FSceneHeight + Value then
        Self.FSceneY := GetMaxYhp - FSceneHeight - 16
      else
        Self.FSceneY := Value;
    end;
end;

procedure THSMapViewer.SetSceneWidth(Value: Integer);
var
  M: THSMap;
begin
  M := FHSMap;
  if (M <> nil) and (Value > 0) then
  begin
    FSceneWidth := Value;
    SetSceneX(FSceneX);
  end;
end;

procedure THSMapViewer.SetSceneHeight(Value: Integer);
var
  M: THSMap;
begin
  M := FHSMap;
  if (M <> nil) and (Value > 0) then
  begin
    FSceneHeight := Value;
    SetSceneY(FSceneY);
  end;
end;

procedure THSMapViewer.VerifyStaticSurface(Surface: TSurface);
var
  IsDDraw: Boolean;
  Flags: TDDSCreationFlags;
begin
  IsDDraw := FStaticSurface is TDDrawSurface;
  if (FStaticSurface <> nil) and ((FStaticSurface.GetPixelFormatID <> Surface.GetPixelFormatID) or
    ((Surface is TDDrawSurface) xor IsDDraw)) then
  begin
    FStaticSurface.Free;
    FStaticSurface := nil;
  end;
  if (FStaticSurface = nil) or (FStaticSurface.GetWidth <> FSceneWidth) or
    (FStaticSurface.GetHeight <> FSceneHeight) then
  begin
    if FStaticSurface = nil then
    begin
      if Surface is TDDrawSurface then
      begin
        if ssVideoMemory in TDDrawSurface(Surface).Status then
          Flags := [cfVideoMemory, cfSystemMemory]
        else
          Flags := [cfSystemMemory];
        FStaticSurface := TDDrawSurface.Create;
        TDDrawSurface(FStaticSurface).CreateSurface(FSceneWidth, FSceneHeight,
          Surface.GetPixelFormatID, Flags);
      end
      else
        FStaticSurface := TDataSurface.Create(FSceneWidth, FSceneHeight, Surface.GetPixelFormatID, nil);
    end
    else
      FStaticSurface.Resize(FSceneWidth, FSceneHeight);
    IsDDraw := FStaticSurface is TDDrawSurface;
    FHSMap.FStaticSceneInvalid := True;
    FStaticSurfaceValid := False;
  end;
  if IsDDraw and TDDrawSurface(FStaticSurface).Lost then
  begin
    TDDrawSurface(FStaticSurface).Restore;
    FStaticSurfaceValid := False;
  end;
end;

procedure THSMapViewer.ResetStaticSurface;
begin
  FStaticSurface.Free;
  FStaticSurface := nil;
end;

procedure THSMapViewer.ShowScene(X, Y: Integer; Surface: TSurface);
var
  M: THSMap;
  R: TRect;
  SD: TSurfaceDesc;
begin
  try
    M := FHSMap;
    if M <> nil then
    begin
      if M.SetViewPort(FSceneX, FSceneY, FSceneL, FSceneWidth, FSceneHeight) and
        Assigned(FOnSceneChanged) then
        FOnSceneChanged(Self);
      VerifyStaticSurface(Surface);
      R.Left := X;
      R.Right := FSceneWidth + X;
      R.Top := Y;
      R.Bottom := FSceneHeight + Y;
      if M.FStaticSceneInvalid then
      begin
        M.UpdateStaticScene;
        M.UpdateDynamicScene;
        if Surface.LockEx(SD, R) >= 0 then
        begin
          M.DrawStaticScene(SD);
          M.DrawDynamicScene(SD);
          Surface.UnlockEx(SD);
        end;
        FStaticSurfaceValid := False;
      end
      else if FStaticSurfaceValid then
      begin
        FStaticSurface.BltClipped(Surface, nil, X, Y);
        M.UpdateDynamicScene;
        if Surface.LockEx(SD, R) >= 0 then
        begin
          M.DrawDynamicScene(SD);
          Surface.UnlockEx(SD);
        end;
      end
      else
      begin
        M.UpdateStaticScene;
        if FStaticSurface.Lock(SD) >= 0 then
        begin
          M.DrawStaticScene(SD);
          FStaticSurface.Unlock;
          FStaticSurfaceValid := True;
        end;
        if FStaticSurface.BltClipped(Surface, nil, X, Y) >= 0 then
        begin
          M.UpdateDynamicScene;
          if Surface.LockEx(SD, R) >= 0 then
          begin
            M.DrawDynamicScene(SD);
            Surface.UnlockEx(SD);
          end;
        end;
      end;
    end;
  except
    ShowMessage('Exception during MapViewer.ShowScene');
  end;
end;
{ THSEngine }

type
  { The header of an .hss file (52 bytes): the set follows at Size, a CRC32 of everything before it
    closes the file }
  THSSHeader = record
    Size: Integer;
    ID: string[4];
    Name: string[40];
  end;

  { The header of an .hsm file (16 bytes) in front of the stored map, inside the compressed stream }
  THSMHeader = record
    Size: Integer;
    ID: THSMID;
    Reserved: Integer;
    ClassID: Integer;
  end;

constructor THSEngine.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FOnHSMLoaded := TEventList.Create;
  FOnHSMClose := TEventList.Create;
  FOnHSSLoaded := TEventList.Create;
  FOnHSSClose := TEventList.Create;
  RegisterEClasses([TMapContainer, TMapLevel, THSMap, THSSet]);
  RegisterEClasses([TMapObjectResource, TMultiHexMOR]);
  RegisterEClasses([TAbstractHexagon, TAbstractBorderHexagon, TAbstractRoad]);
  HSEngineDID := RegisterDebugID('HS-Engine');
  FHSSFileName := 'noname.hss';
  CreateHSSet;
end;

destructor THSEngine.Destroy;
begin
  FOnHSMLoaded.Clear;
  FOnHSMClose.Clear;
  CloseHSM(nil);
  inherited Destroy;
  FOnHSMLoaded.Free;
  FOnHSMLoaded := nil;
  FOnHSMClose.Free;
  FOnHSMClose := nil;
  FOnHSSLoaded.Free;
  FOnHSSLoaded := nil;
  FOnHSSClose.Free;
  FOnHSSClose := nil;
end;

class function THSEngine.ClassID: Integer;
begin
  Result := $10001;
end;

procedure THSEngine.SetHSMap(Value: THSMap);
begin
  FHSMap := Value;
end;

function THSEngine.GetHSSetFiles(Mask: string): TStringList;
var
  Files: TStringList;

  { adds 'Name|Path' for every set file in Dir and its subdirectories }
  procedure Search(Dir: string);
  var
    Dirs: TStringList;
    Stream: TFileStream;
    Header: THSSHeader;
    SR: TSearchRec;
    Found: Boolean;
    I: Integer;
  begin
    Found := FindFirst(Dir + Mask, faAnyFile and not faDirectory, SR) = 0;
    while Found do
    begin
      FillChar(Header, SizeOf(Header), 0);
      Stream := TFileStream.Create(Dir + SR.Name, fmOpenRead);
      try
        try
          Stream.Read(Header, SizeOf(Header));
        finally
          Stream.Free;
        end;
      except
      end;
      if Header.ID = 'HSS'#0 then
        Files.Add(Header.Name + '|' + Dir + SR.Name);
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    Dirs := TStringList.Create;
    Found := FindFirst(Dir + '*.*', faDirectory, SR) = 0;
    while Found do
    begin
      if (SR.Attr and faDirectory <> 0) and (SR.Name <> '.') and (SR.Name <> '..') then
        Dirs.Add(Dir + SR.Name + '\');
      Found := FindNext(SR) = 0;
    end;
    FindClose(SR);
    for I := 0 to Dirs.Count - 1 do
      Search(Dirs[I]);
    Dirs.Free;
  end;

begin
  Files := TStringList.Create;
  Search(StartupDirectory);
  Result := Files;
end;

procedure THSEngine.CreateHSSet;
begin
  FHSSet := THSSet.Create(Self);
end;

procedure THSEngine.LoadHSS(const FileName: string; Edit: Boolean; AProgress: TProgressEvent);
var
  Mem: TMemoryStream;
  F: TFileStream;
  Header: THSSHeader;
  Msg: TEMsg;
  CRC: Integer;
begin
  FHSSet.Clear;
  FHSSFileName := ExpandFileName(FileName);
  FStatus := FStatus + [esLoadingHSS];
  Mem := TMemoryStream.Create;
  try
    F := TFileStream.Create(FHSSFileName, fmShareDenyWrite);
    try
      Mem.LoadFromStream(F);
    finally
      F.Destroy;
    end;
    Mem.Read(Header, SizeOf(Header));
    Mem.Position := Header.Size;
    CRC := PInteger(Integer(Mem.Memory) + Mem.Size - 4)^;
    if (Header.ID <> 'HSS'#0) or (CRC <> GetCRC32(Mem.Memory, Mem.Size - 4)) then
      raise Exception.Create('Invalid HSSET');
    ReadEObject(Mem, FHSSet, AProgress);
    ActivateEObject(FHSSet);
    InitMsg(Msg, $10014, Self);
    FHSSet.MsgProc(Msg, Self);
    ControlNode.MsgProc(Msg, Self);
    FOnHSSLoaded.TriggerNotifyEvents(Self);
  finally
    FStatus := FStatus - [esLoadingHSS];
    Mem.Free;
  end;
end;

procedure THSEngine.SaveHSS(const FileName: string; AProgress: TProgressEvent);
var
  Mem: TMemoryStream;
  F: TFileStream;
  CRC: Integer;
  Header: THSSHeader;
begin
  if FHSSet <> nil then
  begin
    Header.Size := SizeOf(Header);
    Header.Name := FHSSet.Name;
    Header.ID := 'HSS'#0;
    FHSSFileName := ExpandFileName(FileName);
    FStatus := FStatus + [esSavingHSS];
    Mem := TMemoryStream.Create;
    try
      Mem.Write(Header, SizeOf(Header));
      WriteEObject(Mem, FHSSet, AProgress);
      CRC := GetCRC32(Mem.Memory, Mem.Size);
      Mem.Write(CRC, SizeOf(CRC));
      F := TFileStream.Create(FHSSFileName, fmCreate);
      try
        Mem.SaveToStream(F);
      finally
        F.Free;
      end;
    finally
      FStatus := FStatus - [esSavingHSS];
      Mem.Free;
    end;
  end;
end;

procedure THSEngine.CloseHSS;
begin
  FOnHSSClose.TriggerNotifyEvents(Self);
  FHSSet.Clear;
  FHSSFileName := 'noname.hss';
end;

procedure THSEngine.LoadPreviewHSM(const FileName: string);
var
  Stream: TCompressStream;
  Header: THSMHeader;
begin
  if FHSMap <> nil then
  begin
    FHSMap.Free;
    SetHSMap(nil);
  end;
  try
    Stream := TCompressStream.Create;
    try
      Stream.LoadFromFile(FileName);
      Stream.Read(Header, SizeOf(Header));
      Stream.Position := Header.Size;
      if Header.ID = HSMID then
      begin
        SetHSMap(THSMap(CreateEObject(Header.ClassID, Self)));
        FHSMap.FStatus := FHSMap.FStatus + [msPreviewMode];
        FHSMap.FFileName := ExpandFileName(FileName);
        FStatus := FStatus + [esLoadingHSM];
        try
          ReadEObject(Stream, FHSMap, nil);
        except
          FHSMap.Free;
          SetHSMap(nil);
        end;
        FStatus := FStatus - [esLoadingHSM];
      end;
    finally
      Stream.Free;
    end;
  except
  end;
end;

function THSEngine.CreatePreviewHSM(const FileName: string): THSMap;
var
  Stream: TCompressStream;
  FullName: string;
  Header: THSMHeader;
begin
  Result := nil;
  FullName := ExpandFileName(FileName);
  try
    Stream := TCompressStream.Create;
    try
      Stream.LoadFromFile(FullName);
      Stream.Read(Header, SizeOf(Header));
      Stream.Position := Header.Size;
      if Header.ID = HSMID then
      begin
        Result := THSMap(CreateEObject(Header.ClassID, Self));
        Result.FFileName := ExpandFileName(FileName);
        FStatus := FStatus + [esLoadingHSM];
        try
          ReadPreviewEObject(Stream, Result, nil);
        except
          Result.Free;
          Result := nil;
        end;
        FStatus := FStatus - [esLoadingHSM];
      end;
    finally
      Stream.Free;
    end;
  except
  end;
end;

function THSEngine.LoadHSMEx(const FileName: string; Edit: Boolean; AProgress: TProgressEvent): THSMap;
var
  Stream: TCompressStream;
  FullName: string;
  Header: THSMHeader;
begin
  Result := nil;
  FullName := ExpandFileName(FileName);
  try
    Stream := TCompressStream.Create;
    try
      Stream.LoadFromFile(FullName);
      Stream.Read(Header, SizeOf(Header));
      Stream.Position := Header.Size;
      if Header.ID = HSMID then
      begin
        Result := THSMap(CreateEObject(Header.ClassID, nil));
        Result.FFileName := FullName;
        FStatus := FStatus + [esLoadingHSM];
        if Edit then Result.FStatus := Result.FStatus + [msEditting];
        try
          Result.FOnProgress := AProgress;
          ReadEObject(Stream, Result, AProgress);
          ActivateEObject(Result);
          Result.FOnProgress := nil;
          FOnHSMLoaded.TriggerNotifyEvents(Result);
        except
          Result.Free;
          Result := nil;
        end;
        FStatus := FStatus - [esLoadingHSM];
      end;
    finally
      Stream.Free;
    end;
  except
  end;
end;

procedure THSEngine.LoadHSM(const FileName: string; Edit: Boolean; AProgress: TProgressEvent);
var
  Stream: TCompressStream;
  Header: THSMHeader;
begin
  if FHSMap <> nil then
  begin
    FHSMap.Free;
    SetHSMap(nil);
  end;
  try
    Stream := TCompressStream.Create;
    try
      Stream.LoadFromFile(FileName);
      Stream.Read(Header, SizeOf(Header));
      Stream.Position := Header.Size;
      if Header.ID = HSMID then
      begin
        SetHSMap(THSMap(CreateEObject(Header.ClassID, Self)));
        FHSMap.FFileName := ExpandFileName(FileName);
        FStatus := FStatus + [esLoadingHSM];
        if Edit then FHSMap.FStatus := FHSMap.FStatus + [msEditting];
        try
          FHSMap.FOnProgress := AProgress;
          ReadEObject(Stream, FHSMap, AProgress);
          ActivateEObject(FHSMap);
          FHSMap.FOnProgress := nil;
          FOnHSMLoaded.TriggerNotifyEvents(FHSMap);
        except
          FHSMap.Free;
          SetHSMap(nil);
        end;
        FStatus := FStatus - [esLoadingHSM];
      end;
    finally
      Stream.Free;
    end;
  except
  end;
end;

procedure THSEngine.LoadHSMfromStream(Stream: TStream; Edit: Boolean; AProgress: TProgressEvent);
var
  CStream: TCompressStream;
  Header: THSMHeader;
begin
  if FHSMap <> nil then
  begin
    FHSMap.Free;
    SetHSMap(nil);
  end;
  try
    CStream := TCompressStream.Create;
    try
      CStream.LoadFromStream(Stream);
      CStream.Read(Header, SizeOf(Header));
      CStream.Position := Header.Size;
      if Header.ID = HSMID then
      begin
        SetHSMap(THSMap(CreateEObject(Header.ClassID, Self)));
        FStatus := FStatus + [esLoadingHSM];
        if Edit then FHSMap.FStatus := FHSMap.FStatus + [msEditting];
        try
          FHSMap.FOnProgress := AProgress;
          ReadEObject(CStream, FHSMap, AProgress);
          ActivateEObject(FHSMap);
          FHSMap.FOnProgress := nil;
          FOnHSMLoaded.TriggerNotifyEvents(FHSMap);
        except
          FHSMap.Free;
          SetHSMap(nil);
        end;
        FStatus := FStatus - [esLoadingHSM];
      end;
    finally
      CStream.Free;
    end;
  except
  end;
end;

procedure THSEngine.SaveHSM(const FileName: string; AProgress: TProgressEvent);
var
  Stream: TCompressStream;
  Header: THSMHeader;
begin
  if FHSMap <> nil then
  begin
    FillChar(Header, SizeOf(Header), 0);
    Header.Size := SizeOf(Header);
    Header.ClassID := FHSMap.ClassID;
    Header.Reserved := 0;
    Header.ID := HSMID;
    Stream := TCompressStream.Create;
    FStatus := FStatus + [esSavingHSM];
    try
      Stream.Write(Header, SizeOf(Header));
      WriteEObject(Stream, FHSMap, AProgress);
      Stream.SaveToFile(FileName);
    finally
      FStatus := FStatus - [esSavingHSM];
      Stream.Free;
    end;
  end;
end;

procedure THSEngine.SaveHSMtoStream(Stream: TStream; AProgress: TProgressEvent);
var
  CStream: TCompressStream;
  Header: THSMHeader;
begin
  if FHSMap <> nil then
  begin
    FillChar(Header, SizeOf(Header), 0);
    Header.Size := SizeOf(Header);
    Header.ClassID := FHSMap.ClassID;
    Header.Reserved := 0;
    Header.ID := HSMID;
    CStream := TCompressStream.Create;
    FStatus := FStatus + [esSavingHSM];
    try
      CStream.Write(Header, SizeOf(Header));
      WriteEObject(CStream, FHSMap, AProgress);
      CStream.SaveToStream(Stream);
    finally
      FStatus := FStatus - [esSavingHSM];
      CStream.Free;
    end;
  end;
end;

procedure THSEngine.InitializeHSSet(FileName: string; AProgress: TProgressEvent);
var
  Msg: TEMsg;
begin
  if (FHSSet = nil) or (CompareText(FileName, FHSSFileName) <> 0) then
    LoadHSS(FileName, False, AProgress)
  else
  begin
    InitMsg(Msg, $10015, Self);
    FHSSet.MsgProc(Msg, Self);
  end;
end;

function THSEngine.NewHSM(AClassID: Integer): THSMap;
begin
  if FHSMap <> nil then
  begin
    FHSMap.Free;
    SetHSMap(nil);
  end;
  SetHSMap(THSMap(CreateEObject(AClassID, Self)));
  FHSMap.FStatus := FHSMap.FStatus + [msEditting];
  ActivateEObject(FHSMap);
  FOnHSMLoaded.TriggerNotifyEvents(FHSMap);
  Result := FHSMap;
end;

procedure THSEngine.CloseHSM(AProgress: TProgressEvent);
begin
  if FHSMap <> nil then
  begin
    FHSMap.FOnProgress := AProgress;
    FOnHSMClose.TriggerNotifyEvents(FHSMap);
    FHSMap.Free;
    SetHSMap(nil);
  end;
end;

{ THexagonSpriteEngine }

constructor THexagonSpriteEngine.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CreateEngine;
  if FHSEngine <> nil then FHSEngine.FComponent := Self;
end;

procedure THexagonSpriteEngine.SetHSEngine(Value: THSEngine);
begin
  FHSEngine := Value;
  Engine := FHSEngine;
end;

procedure THexagonSpriteEngine.CreateEngine;
begin
  SetHSEngine(THSEngine.Create(nil));
end;

procedure THexagonSpriteEngine.SetHSSetSearchPath(Value: string);
begin
  if FHSEngine <> nil then FHSEngine.FHSSetSearchPath := Value;
end;

function THexagonSpriteEngine.GetHSSetSearchPath: string;
begin
  if FHSEngine <> nil then
    Result := FHSEngine.FHSSetSearchPath
  else
    Result := '';
end;
procedure Register;
begin
  RegisterComponents('HS-Engine', [THexagonSpriteEngine, THSMapViewer]);
end;

end.
