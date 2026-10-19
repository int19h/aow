unit Engine;

{ The Engine unit of Enginep.dpl written for the original compiler (Delphi 3.02), class by class:
  tools/match.py compares the code DCC32 generates for every method with the code in the game's
  module. Declarations follow the original instance layouts and VMT orders (notes/classes.json); a
  method whose body is still a stub is marked "stub". The value lists live in EngineLists.pas until
  the whole unit is assembled; the hash classes come from inc\HashTab.PAS as in the original. }

interface

uses
  Windows, SysUtils, Classes, Forms, Clipbrd, EngineLists, FMemStr, ImageLib, zlib;

type
  PByte = ^Byte;
  PInteger = ^Integer;

  { TEStorageStream.StorageMode: smRead/smWrite the binary streams, smPartial the preview streams,
    smText the text streams and the translate stream, smTranslate the translate stream,
    smSetupCompare/smCompare the compare streams }
  TStorageMode = (smRead, smWrite, smText, smPartial, smTranslate, smSetupCompare, smCompare);
  TStorageModes = set of TStorageMode;

  { TEObject.GetControlStyle }
  TEControlStyle = (csStored, csShared, csReserved2, csKeepIndex);
  TEControlStyles = set of TEControlStyle;

  PPropertyItem = ^TPropertyItem;
  TPropertyItem = record
    ID: Integer;
    Offset: Integer;
  end;
  PPropertyItemArray = ^TPropertyItemArray;
  TPropertyItemArray = array[0..MaxInt div SizeOf(TPropertyItem) - 1] of TPropertyItem;

  PPropertySettings = ^TPropertySettings;
  TPropertySettings = record
    First: Integer;
    NextIndex: Integer;
    MaxID: Integer;
  end;
  PPropertySettingsArray = ^TPropertySettingsArray;
  TPropertySettingsArray = array[0..MaxInt div SizeOf(TPropertySettings) - 1] of TPropertySettings;

  TPropertyTable = class(TObject)
  private
    FItems: PPropertyItemArray;
    FCapacity: Integer;
    FCount: Integer;
    FNextIndex: Integer;
    FMaxID: Integer;
    FStack: PPropertySettingsArray;
    FStackCount: Integer;
    FStackCapacity: Integer;
    FFirst: Integer;
    procedure SetCapacity(NewCapacity: Integer);
  public
    destructor Destroy; override;
    procedure Add(ID, Offset: Integer);
    procedure Clear;
    function FindOffset(ID: Integer): Integer;
    function PropertyExist(ID: Integer): Boolean;
    procedure BackupSettings;
    procedure RestoreSettings;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Items: PPropertyItemArray read FItems;
    property Count: Integer read FCount;
    property First: Integer read FFirst;
  end;

  TEObject = class;
  TECustomNode = class;
  TEngine = class;
  TEStorageStream = class;
  TEObjectEditorList = class;

  TEObjectClass = class of TEObject;

  { The message record (48 bytes) that InitMsg clears: +0 MsgID, +4 Seq, +8 Sender, +$18 Engine
    (TEngine.ActivateEObject), +$2C Result (-1 after InitMsg). }
  PEMsg = ^TEMsg;
  TEMsg = record
    MsgID: Integer;
    Seq: Integer;
    Sender: TEObject;
    Param: array[0..2] of Integer;
    Engine: TEngine;
    Data: array[0..3] of Integer;
    Result: Integer;
  end;


  TStorageErrorEvent = procedure(Sender: TObject; const Msg: string; var Continue: Boolean) of object;
  TStorageProgressEvent = procedure(Sender: TObject; const Msg: string; Percent: Integer) of object;

  EDoublePrioriyID = class(Exception);

  { Engine.TEBufferStream (instance size 20): the write stream's data buffer }
  TEBufferStream = class(TFastMemoryStream)
  end;

  { Engine.TCompressStream (instance size 20): a TMemoryStream whose SaveToStream writes the
    "CFS" header, the compression level and the zlib-compressed bytes }
  TCompressStream = class(TMemoryStream)
  public
    procedure LoadFromStream(Stream: TStream);
    function SaveToStreamEx(Stream: TStream; Level: Byte): Integer;
    procedure SaveToStream(Stream: TStream);
    function SaveToFileEx(const FileName: string; Level: Byte): Integer;
    procedure SaveToFile(const FileName: string);
    procedure LoadFromFile(const FileName: string);
  end;

  { Engine.TEObject (instance size 8): +4 FOwner. }
  TEObject = class(TObject)
  private
    FOwner: TECustomNode;
    function GetEObjectPath: string;
  public
    function ClassVersion: Integer; virtual;
    function GetControlStyle: TEControlStyles; virtual;
    procedure SetOwner(AOwner: TECustomNode); virtual;
    function GetEngine: TEngine; virtual;
    function GetLastMsg: Integer; virtual;
    procedure SetLastMsg(Value: Integer); virtual;
    procedure ReadWrite(Stream: TEStorageStream); virtual;
    procedure MainReadWrite(Stream: TEStorageStream); virtual;
    constructor Create(AOwner: TECustomNode); virtual;
    class function ClassID: Integer; virtual;
    function AddRef: Integer; virtual;
    function Release: Integer; virtual;
    procedure Clear; virtual;
    function Compare(Obj: TEObject; AEngine: TEngine): Boolean; virtual;
    function Editor: TClass; virtual;
    procedure Assign(Source: TEObject; AEngine: TEngine); virtual;
    procedure TimerEvent(Tick: Integer; Sender: TEObject); virtual;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); virtual;
    procedure SetArrayOwner(AOwner: TECustomNode; Index: Integer); virtual;
    destructor Destroy; override;
    function Copy(AEngine: TEngine): TEObject;
    property Owner: TECustomNode read FOwner write SetOwner;
    property EObjectPath: string read GetEObjectPath;
    property LastMsg: Integer read GetLastMsg write SetLastMsg;
  end;

  { Engine.TPlugIn (instance size 16): +4 FRefCount, +8 FEngines, +$C FCounts. A plug-in registers
    itself in PlugIns on creation and counts the engines it is initialized for. }
  TPlugIn = class(TObject)
  private
    FRefCount: Integer;
    FEngines: TList;
    FCounts: TIntegerList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure AddRef;
    procedure Release;
    function Name: string; virtual;
    function Initialize(AEngine: TEngine): Boolean; virtual;
    function Finalize(AEngine: TEngine): Boolean; virtual;
    property RefCount: Integer read FRefCount;
  end;

  EPlugInMissing = class(Exception);

  { Engine.TPlugInControl (instance size 16): +8 FEngine, +$C FUsedPlugIns; the names of the
    plug-ins an engine uses, initialized and finalized as the list changes }
  TPlugInControl = class(TEObject)
  private
    FEngine: TEngine;
    FUsedPlugIns: TStringList;
    procedure SetUsedPlugIns(Value: TStrings);
    function GetUsedPlugIns: TStrings;
    procedure OnChange(Sender: TObject);
    procedure OnChanging(Sender: TObject);
    procedure InitializePlugIns;
    procedure FinalizePlugIns;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    function GetEngine: TEngine; override;
    function GetControlStyle: TEControlStyles; override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    property Engine: TEngine read FEngine write FEngine;
    property UsedPlugIns: TStrings read GetUsedPlugIns write SetUsedPlugIns;
  end;

  { Engine.TECustomNode (instance size 8): children through an abstract list interface. Message ids
    carry flags: $10000000 deliver once per Seq, $20000000 owned children only, $40000000 do not
    forward to children. }
  TECustomNode = class(TEObject)
  public
    procedure MainReadWrite(Stream: TEStorageStream); override;
    procedure Clear; override;
    procedure Assign(Source: TEObject; AEngine: TEngine); override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
    function GetChild(Index: Integer): TEObject; virtual; abstract;
    procedure SetChild(Index: Integer; Child: TEObject); virtual; abstract;
    function GetCount: Integer; virtual; abstract;
    procedure ReadWriteChildren(Stream: TEStorageStream); virtual;
    function SendToChild(var Msg: TEMsg): Boolean; virtual;
    procedure DestroyAllChildren; virtual;
    procedure QuickClear; virtual;
    procedure SendMsg(var Msg: TEMsg; Sender: TEObject); virtual;
    function RemoveChild(Child: TEObject): Integer; virtual; abstract;
    function AddChild(Child: TEObject): Integer; virtual; abstract;
    function DestroyChildren(AClassID: Integer): Integer; virtual;
    function FindChildInTree(AClassID: Integer): TEObject; virtual;
    function FindChild(AClassID: Integer): TEObject; virtual;
    function FindOwnedChild(AClassID: Integer): TEObject; virtual;
    function FindChildIndex(Child: TEObject): Integer; virtual;
    destructor Destroy; override;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TEObject read GetChild write SetChild;
  end;

  { Engine.TEObjectList (instance size 16): the child list of a TENode }
  TEObjectList = class(TList)
  protected
    function GetEObject(Index: Integer): TEObject;
    procedure SetEObject(Index: Integer; Value: TEObject);
  public
    function FindObject(AClassID: Integer): TEObject;
    function FindObjectIndex(AClassID: Integer): Integer;
    procedure ClearList;
    function AllHaveCID(AClassID: Integer): Boolean;
    property EObjects[Index: Integer]: TEObject read GetEObject write SetEObject;
  end;

  { Engine.TENode (instance size 12): +8 FChildren }
  TENode = class(TECustomNode)
  private
    FChildren: TEObjectList;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure Clear; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function GetCount: Integer; override;
    procedure DestroyAllChildren; override;
    procedure SendMsg(var Msg: TEMsg; Sender: TEObject); override;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    function FindChild(AClassID: Integer): TEObject; override;
    function FindChildIndex(Child: TEObject): Integer; override;
    destructor Destroy; override;
    procedure DestroyEObjects(AClassID: Integer);
  end;

  { Engine.TETimerNode (instance size 56): +8 FTick, +$C FCount, +$10 FTimerLists[1..10]. Children
    sit in one of ten lists and get TimerEvent every tick, every second tick, ... every tenth. }
  TETimerNode = class(TECustomNode)
  private
    FTick: Integer;
    FCount: Integer;
    FTimerLists: array[1..10] of TList;
    function FindTimerList(Child: TEObject): Integer;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function GetControlStyle: TEControlStyles; override;
    function GetCount: Integer; override;
    function GetTimerList(Timer: Shortint): TList;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function AddTimerChild(Child: TEObject; Timer: Shortint): Integer;
    function RemoveTimerChild(Child: TEObject; Timer: Shortint): Integer;
    procedure TriggerTimerListEvent(Timer: Integer);
    procedure TriggerTimerEvent;
    property Tick: Integer read FTick;
  end;

  { Engine.TEChangeNotifyNode (instance size 16): +8 FChildren, +$C FUpdateCount. A node that calls
    Changed whenever its children change, unless a BeginUpdate holds the call back. }
  TEChangeNotifyNode = class(TECustomNode)
  private
    FChildren: TEObjectList;
    FUpdateCount: Integer;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    procedure Clear; override;
    class function ClassID: Integer; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    procedure Assign(Source: TEObject; AEngine: TEngine); override;
    procedure LockChanged;
    procedure UnlockChanged;
    procedure Changed; virtual;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure Sort(Compare: TListSortCompare);
    procedure MainReadWrite(Stream: TEStorageStream); override;
    function GetCount: Integer; override;
    procedure SendMsg(var Msg: TEMsg; Sender: TEObject); override;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    function FindChild(AClassID: Integer): TEObject; override;
    function FindChildIndex(Child: TEObject): Integer; override;
    property UpdateCount: Integer read FUpdateCount;
  end;

  { Engine.TEChangeNotifyEventList (instance size 20): +$10 FEvents, notified by Changed }
  TEChangeNotifyEventList = class(TEChangeNotifyNode)
  private
    FEvents: TEventList;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    procedure Changed; override;
    property Events: TEventList read FEvents;
  end;

  { TEObjectEditor.Edit calls this like a constructor: the flag is the hidden allocation flag }
  TEditorConstructor = procedure(Alloc: Boolean; Obj: TEObject) of object;

  { Engine.TEObjectEditor (instance size 8): editors are looked up by class. stub }
  TEObjectEditor = class(TEObject)
  public
    class function EditorClassID: Integer; virtual;
    procedure Edit(Obj: TEObject; CreateEditor: TEditorConstructor); virtual;
    procedure UpdateMultiPopupMenu(Objects: TList; Menu: TObject; A, B, C: Integer); virtual;
    procedure UpdatePopupMenu(Obj: TEObject; Menu: TObject; A, B: Integer); virtual;
  end;

  TEObjectEditorClass = class of TEObjectEditor;

  { Engine.THashList (instance size 16): +4 FCount, +8 FCapacity, +$C FItems. The hash classes
    come from an include file of the original, D:\GEngine\Engine\inc\HashTab.PAS, whose name the
    Assert calls carry. }
  THashItem = record
    Key: Integer;
    Item: Pointer;
  end;
  PHashItemArray = ^THashItemArray;
  THashItemArray = array[0..MaxInt div SizeOf(THashItem) - 1] of THashItem;

  THashList = class(TObject)
  private
    FCount: Integer;
    FCapacity: Integer;
    FItems: PHashItemArray;
  protected
    procedure SetCapacity(NewCapacity: Integer);
    procedure Delete(Index: Integer);
    procedure Add(Item: THashItem);
  public
    destructor Destroy; override;
    procedure Clear; virtual;
    property Count: Integer read FCount;
  end;

  { Engine.TIntegerHashList (instance size 16): items keyed by an integer }
  TIntegerHashList = class(THashList)
  public
    procedure Add(Item: Pointer; Key: Integer);
    procedure Delete(Key: Integer);
    function Find(Key: Integer): Pointer;
  end;

  { Engine.TIntegerHashTable (instance size 4): the abstract table interface }
  TIntegerHashTable = class(TObject)
  public
    procedure Add(Item: Pointer; Key: Integer); virtual; abstract;
    procedure Delete(Key: Integer); virtual; abstract;
    function Find(Key: Integer): Pointer; virtual; abstract;
    procedure Clear; virtual; abstract;
    function GetFreeID: Integer; virtual; abstract;
  end;

  { Engine.TIntegerHashTable256 (instance size 1028): 256 lists selected by the low key byte }
  TIntegerHashTable256 = class(TIntegerHashTable)
  private
    FLists: array[0..255] of TIntegerHashList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Add(Item: Pointer; Key: Integer); override;
    procedure Delete(Key: Integer); override;
    function Find(Key: Integer): Pointer; override;
    procedure DeleteSafe(Item: Pointer; Key: Integer);
    function GetFreeID: Integer; override;
  end;

  { Engine.TStringHashList (instance size 16): THashList items whose key dword is a string }
  PStringHashItem = ^TStringHashItem;
  TStringHashItem = record
    Key: string;
    Item: Pointer;
  end;

  TStringHashList = class(THashList)
  public
    procedure Clear; override;
    function Find(const Key: string): Pointer;
    procedure Add(Item: Pointer; const Key: string);
    procedure Delete(const Key: string);
  end;

  { Engine.TStringHashTable (instance size 4): the abstract table interface }
  TStringHashTable = class(TObject)
  public
    procedure Add(Item: Pointer; const Key: string); virtual; abstract;
    procedure Delete(const Key: string); virtual; abstract;
    function Find(const Key: string): Pointer; virtual; abstract;
    procedure Clear; virtual; abstract;
  end;

  { Engine.TStringHashTable256 (instance size 1028): 256 lists selected by a hash of the first
    and the second-to-last character and the length }
  TStringHashTable256 = class(TStringHashTable)
  private
    FLists: array[0..255] of TStringHashList;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear; override;
    procedure Add(Item: Pointer; const Key: string); override;
    procedure Delete(const Key: string); override;
    function Find(const Key: string): Pointer; override;
  end;

  { Engine.TEControlStyleObject (instance size 12): +8 FControlStyle }
  TEControlStyleObject = class(TEObject)
  private
    FControlStyle: TEControlStyles;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetControlStyle: TEControlStyles; override;
    procedure SetControlStyle(Value: TEControlStyles);
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  { Engine.TEControlStyleNode (instance size 16): +$C FControlStyle }
  TEControlStyleNode = class(TENode)
  private
    FControlStyle: TEControlStyles;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetControlStyle: TEControlStyles; override;
    procedure SetControlStyle(Value: TEControlStyles);
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  { Engine.TECustomOwner (instance size 20): +$C FEngine, +$10 FControlStyle. A node that knows
    its engine: message $20000008 (TEngine.ActivateEObject) carries the engine in the message. }
  TECustomOwner = class(TENode)
  private
    FEngine: TEngine;
    FControlStyle: TEControlStyles;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetEngine: TEngine; override;
    procedure SetEngine(AEngine: TEngine);
    function GetControlStyle: TEControlStyles; override;
    procedure SetControlStyle(Value: TEControlStyles);
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); override;
  end;

  { Engine.TEObjectClassList (instance size 16): a TList of class references }
  TEObjectClassList = class(TList)
  protected
    function GetEClass(Index: Integer): TEObjectClass;
  public
    function FindClass(AClassID: Integer): TEObjectClass;
    function FindClassIndex(AClassID: Integer): Integer;
    function GetClass(AClassID: Integer): TEObjectClass;
    procedure RegisterClass(AClass: TEObjectClass);
    procedure UnregisterClass(AClass: TEObjectClass);
    property EClasses[Index: Integer]: TEObjectClass read GetEClass;
  end;

  { Engine.TEObjectEditorList (instance size 16) }
  TEObjectEditorList = class(TEObjectClassList)
  public
    function FindEditor(AClassID: Integer): TEObjectEditorClass;
  end;

  { Engine.TEResourceEditSettings (instance size 16): +$C FEditors, editor names with ids }
  TEResourceEditSettings = class(TEControlStyleObject)
  private
    FEditors: TStringList;
    function GetUniqueEditID: Integer;
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    function GetUniqueEditorName(Name: string): string;
    function GetEditID(Name: string): Integer;
    function RemoveEditor(Name: string): Integer;
    procedure ReadWrite(Stream: TEStorageStream); override;
    property Editors: TStringList read FEditors;
  end;

  { Engine.TESortNode (instance size 24): +8 FSorted, +$C FCount, +$10 FCapacity, +$14 FItems.
    Children with a sort value, kept in order once Sort has run. }
  PSortItem = ^TSortItem;
  TSortItem = record
    SortValue: Integer;
    Child: TEObject;
  end;
  PSortItemArray = ^TSortItemArray;
  TSortItemArray = array[0..MaxInt div SizeOf(TSortItem) - 1] of TSortItem;

  TESortNode = class(TECustomNode)
  private
    FSorted: Boolean;
    FCount: Integer;
    FCapacity: Integer;
    FItems: PSortItemArray;
    function GetSortValue(Index: Integer): Integer;
    procedure SetSortValue(Index: Integer; Value: Integer);
    procedure Resize(NewCapacity: Integer);
  public
    constructor Create(AOwner: TECustomNode); override;
    destructor Destroy; override;
    class function ClassID: Integer; override;
    procedure QuickClear; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function GetCount: Integer; override;
    procedure Grow; virtual;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    function AddSortChild(Child: TEObject; SortValue: Integer): Integer; virtual;
    procedure ReadWrite(Stream: TEStorageStream); override;
    procedure Sort; virtual;
    property SortValue[Index: Integer]: Integer read GetSortValue write SetSortValue;
    property Sorted: Boolean read FSorted;
  end;

  { Engine.TEInverseSortNode: the same, sorted the other way }
  TEInverseSortNode = class(TESortNode)
  public
    class function ClassID: Integer; override;
    function AddSortChild(Child: TEObject; SortValue: Integer): Integer; override;
    procedure Sort; override;
  end;

  { Engine.TEControlStyleSortNode (instance size 28): +$18 FControlStyle }
  TEControlStyleSortNode = class(TESortNode)
  private
    FControlStyle: TEControlStyles;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetControlStyle: TEControlStyles; override;
    procedure SetControlStyle(Value: TEControlStyles);
  end;

  { Engine.TEControlStyleInverseSortNode (instance size 28): +$18 FControlStyle }
  TEControlStyleInverseSortNode = class(TEInverseSortNode)
  private
    FControlStyle: TEControlStyles;
  public
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    function GetControlStyle: TEControlStyles; override;
    procedure SetControlStyle(Value: TEControlStyles);
  end;

  { Engine.TEReferenceNode (instance size 12): a TENode that holds references to objects owned
    elsewhere (AddRef on AddChild, Release on removal) }
  TEReferenceNode = class(TENode)
  public
    procedure Clear; override;
    procedure ReadWriteChildren(Stream: TEStorageStream); override;
    procedure DestroyAllChildren; override;
    function RemoveChild(Child: TEObject): Integer; override;
    function AddChild(Child: TEObject): Integer; override;
  end;

  { Engine.TEUser (instance size 12): +8 FNode, the node the user is connected to }
  TEUser = class(TEObject)
  private
    FNode: TECustomNode;
  public
    destructor Destroy; override;
    procedure Connect(Node: TECustomNode);
    procedure Disconnect;
    property Node: TECustomNode read FNode;
  end;

  { Engine.TEResource (instance size 24): +8 FResourceList, +$C FResourceID, +$10 and +$14 two
    more persisted integers (ids 2 and 3) }
  TEResource = class(TEObject)
  private
    FResourceList: TECustomNode;
    FResourceID: Integer;
    FValue2: Integer;
    FValue3: Integer;
  public
    procedure SetOwner(AOwner: TECustomNode); override;
    procedure ReadWrite(Stream: TEStorageStream); override;
    class function ClassID: Integer; override;
    procedure SetArrayOwner(AOwner: TECustomNode; Index: Integer); override;
    function GetCellImage: Pointer; virtual;
    procedure SetCellImage(Value: Pointer); virtual;
    class function ResourceEditName: string; virtual;
    function ResourceUserClassID: Integer; virtual;
    function CreateResourceUser: TEObject; virtual;
    procedure Draw(Dest: TObject; Rect: TRect; Mode: Byte; A, B, C, D: Integer); virtual;
    property ResourceList: TECustomNode read FResourceList;
    property ResourceID: Integer read FResourceID write FResourceID;
    property CellImage: Pointer read GetCellImage write SetCellImage;
  end;

  { Engine.TEResourceList (instance size 20): resources with unique ids }
  TEResourceList = class(TECustomOwner)
  protected
    function GetResource(Index: Integer): TEResource;
  public
    class function ClassID: Integer; override;
    procedure ResourceChanged; virtual;
    function FindResource(ID: Integer): TEResource;
    procedure ValidateResourceID(Index: Integer);
    property Resources[Index: Integer]: TEResource read GetResource;
  end;

  { Engine.TEComponent (instance size 56): +$24 FOnLoaded, +$2C FOnDestroy, +$34 the object it
    owns (its name is not known; it is freed with the component) }
  TEComponent = class(TComponent)
  private
    FOnLoaded: TNotifyEvent;
    FOnDestroy: TNotifyEvent;
    FObject: TObject;
  protected
    procedure Loaded; override;
  public
    destructor Destroy; override;
    property OnLoaded: TNotifyEvent read FOnLoaded write FOnLoaded;
    property OnDestroy: TNotifyEvent read FOnDestroy write FOnDestroy;
  end;

  { Engine.TECopyComponent (instance size 44): +$24 FName, +$28 FEObjects. Carries objects through
    the VCL clipboard as a streamed component; CopyEngine is the engine that reads them back. }
  TECopyComponent = class(TComponent)
  private
    FName: string;
    FEObjects: TEObjectList;
    function GetEObject(Index: Integer): TEObject;
    procedure SetEObject(Index: Integer; Value: TEObject);
    function GetCount: Integer;
  protected
    procedure ReadState(Reader: TReader); override;
    procedure WriteState(Writer: TWriter); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure CopyToClipboard(AEngine: TEngine; Name: string);
    procedure PasteFromClipboard(AEngine: TEngine; Name: string);
    property EObjects[Index: Integer]: TEObject read GetEObject write SetEObject;
    property Count: Integer read GetCount;
  end;

  { Engine.TCallBackEventList (instance size 8): +4 FList of 12-byte records on the heap }
  PCallBackEvent = ^TCallBackEvent;
  TCallBackEvent = record
    Event: TNotifyEvent;
    Data: Integer;
  end;

  TCallBackEventList = class(TObject)
  private
    FList: TList;
    function GetCount: Integer;
    function GetItem(Index: Integer): PCallBackEvent;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;
    procedure Add(const Event: TCallBackEvent);
    procedure Delete(Index: Integer);
    property Count: Integer read GetCount;
    property Items[Index: Integer]: PCallBackEvent read GetItem; default;
  end;

  { TEngine.OutputDebugStr / OutputDebugMessage hand this to the debug events }
  TEngineDebugInfo = record
    ID: Integer;
    Text: string;
  end;

  TEngineOption = (eoVerifyClasses);
  TEngineOptions = set of TEngineOption;

  TEReadTextStorageStream = class;
  TEWriteTextStorageStream = class;

  { Engine.TEngine (instance size 52): +$C FMsgCount, +$10 FEClasses, +$14 FClassTable,
    +$18 FEditors, +$1C FControlNode, +$24 FDebugIDs, +$28 FDebugEvents, +$2C FStartupDirectory,
    +$31 FOptions. Every engine is in the Engines list. }
  TEngine = class(TENode)
  private
    FMsgCount: Integer;
    FEClasses: TEObjectClassList;
    FClassTable: TIntegerHashTable256;
    FEditors: TEObjectEditorList;
    FControlNode: TEControlStyleNode;
    FUnknown20: Integer;
    FDebugIDs: TStringList;
    FDebugEvents: TEventList;
    FStartupDirectory: string;
    FUnknown30: Byte;
    FOptions: TEngineOptions;
    function CreateUniqueDebugID: Integer;
  public
    function GetEngine: TEngine; override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    destructor Destroy; override;
    procedure SetStartupDirectory(Value: string); virtual;
    procedure UpdateStartupDirectory; virtual;
    function CreateEObject(AClassID: Integer; AOwner: TECustomNode): TEObject; virtual;
    function GetEClass(AClassID: Integer): TEObjectClass; virtual;
    function TranslateText(const Text: string): string; virtual;
    function RegisterDebugID(const Name: string): Integer;
    procedure UnregisterDebugID(ID: Integer);
    procedure OutputDebugStr(const S: string);
    procedure OutputDebugMessage(ID: Integer; const S: string);
    procedure ResetMsgCount;
    function IncMsgCount: Integer;
    procedure RegisterEClasses(AClasses: array of TEObjectClass);
    procedure UnregisterEClasses(AClasses: array of TEObjectClass);
    function GetDescendantClasses(AClass: TClass): TEObjectClassList;
    procedure ActivateEObject(Obj: TEObject);
    procedure WriteEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure ReadEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure WritePreviewEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure ReadPreviewEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure StoreEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    function RetrieveEObject(Stream: TStream; AProgress: TStorageProgressEvent): TEObject;
    function RetrieveFromFile(const FileName: string; AProgress: TStorageProgressEvent): TEObject;
    procedure StoreInFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure WriteToFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure ReadFromFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure WriteToFileCRC(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
    function ReadFromFileCRC(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent): Boolean;
    procedure ReadTextFromFile(const FileName: string; Obj: TEObject);
    procedure WriteTextToFile(const FileName: string; Obj: TEObject);
    function VerifyEObjectClass(AClass: TEObjectClass): Boolean;
    property EClasses: TEObjectClassList read FEClasses;
    property ClassTable: TIntegerHashTable256 read FClassTable;
    property Editors: TEObjectEditorList read FEditors;
    property ControlNode: TEControlStyleNode read FControlNode;
    property DebugIDs: TStringList read FDebugIDs;
    property DebugEvents: TEventList read FDebugEvents;
    property StartupDirectory: string read FStartupDirectory write SetStartupDirectory;
    property Options: TEngineOptions read FOptions write FOptions;
  end;

  TStreamProc = procedure(Stream: TStream) of object;

  { Engine.TEStorageStream (instance size 36): the base of every storage stream. The rw* methods do
    nothing here; the subclasses read, write, compare or translate. }
  TEStorageStream = class(TObject)
  private
    FEngine: TEngine;
    FStream: TStream;
    FErrorHandled: Boolean;
    FPropertyTable: TPropertyTable;
    FOnError: TStorageErrorEvent;
    FOnProgress: TStorageProgressEvent;
  public
    function StorageMode: TStorageModes; virtual; abstract;
    function OpenPropertyStream(ID: Integer): TStream; virtual;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); virtual; abstract;
    procedure rwEObject(Obj: TEObject; ID: Integer); virtual; abstract;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); virtual; abstract;
    procedure rwChildren(Node: TECustomNode; ID: Integer); virtual; abstract;
    procedure rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc); virtual;
    procedure rwData(var Buffer; Size: Integer; ID: Integer); virtual;
    procedure rwString(var S: string; ID: Integer); virtual;
    procedure rwStrings(Strings: TStrings; ID: Integer); virtual;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); virtual;
    procedure rwInteger(var I: Integer; ID: Integer); virtual;
    procedure rwByte(var B: Byte; ID: Integer); virtual;
    procedure rwWord(var W: Word; ID: Integer); virtual;
    procedure rwBool(var B: Boolean; ID: Integer); virtual;
    procedure rwShortint(var S: Shortint; ID: Integer); virtual;
    procedure rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); virtual;
    procedure rwByteEx(var B: Byte; Default: Byte; ID: Integer); virtual;
    procedure rwWordEx(var W: Word; Default: Word; ID: Integer); virtual;
    procedure rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); virtual;
    constructor Create(AStream: TStream; AEngine: TEngine);
    procedure ShowProgress(Sender: TObject; const Msg: string; Percent: Integer);
    property Engine: TEngine read FEngine;
    property Stream: TStream read FStream;
    property PropertyTable: TPropertyTable read FPropertyTable;
    property OnError: TStorageErrorEvent read FOnError write FOnError;
    property OnProgress: TStorageProgressEvent read FOnProgress write FOnProgress;
  end;

  { Engine.TEReadStorageStream (instance size 44): +$24 FPartial, +$28 FDataBase. The constructor
    reads the root property table; every property is found through the table and read at
    FDataBase + offset. }
  TEReadStorageStream = class(TEStorageStream)
  private
    FPartial: Boolean;
    FDataBase: Integer;
  public
    constructor Create(AStream: TStream; AEngine: TEngine; APartial: Boolean);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwInteger(var I: Integer; ID: Integer); override;
    procedure rwByte(var B: Byte; ID: Integer); override;
    procedure rwShortint(var S: Shortint; ID: Integer); override;
    procedure rwWord(var W: Word; ID: Integer); override;
    procedure rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); override;
    procedure rwByteEx(var B: Byte; Default: Byte; ID: Integer); override;
    procedure rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); override;
    procedure rwWordEx(var W: Word; Default: Word; ID: Integer); override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwData(var Buffer; Size: Integer; ID: Integer); override;
    procedure rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc); override;
    function OpenPropertyStream(ID: Integer): TStream; override;
    procedure rwBool(var B: Boolean; ID: Integer); override;
    function HandleException(E: Exception): Boolean;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
    property DataBase: Integer read FDataBase;
  end;

  { Engine.TEWriteStorageStream (instance size 44): +$24 FPartial, +$28 FBuffer. Values go into the
    buffer; the property table records (id, buffer position). A nested object gets its own buffer,
    appended to the outer one as [table][data]. The destructor writes the root table and buffer. }
  TEWriteStorageStream = class(TEStorageStream)
  private
    FPartial: Boolean;
    FBuffer: TEBufferStream;
    procedure PropertyExistError(ID: Integer);
  public
    constructor Create(AStream: TStream; AEngine: TEngine; APartial: Boolean);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwByte(var B: Byte; ID: Integer); override;
    procedure rwWord(var W: Word; ID: Integer); override;
    procedure rwShortint(var S: Shortint; ID: Integer); override;
    procedure rwInteger(var I: Integer; ID: Integer); override;
    procedure rwByteEx(var B: Byte; Default: Byte; ID: Integer); override;
    procedure rwWordEx(var W: Word; Default: Word; ID: Integer); override;
    procedure rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); override;
    procedure rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwData(var Buffer; Size: Integer; ID: Integer); override;
    procedure rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc); override;
    function OpenPropertyStream(ID: Integer): TStream; override;
    procedure rwBool(var B: Boolean; ID: Integer); override;
    function HandleException(E: Exception): Boolean;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
  end;

  { Engine.TDebugWriteStream (instance size 44): a write storage stream that writes every
    object's data straight into the stream (FBuffer is the stream itself) }
  TDebugWriteStream = class(TEWriteStorageStream)
  public
    constructor Create(AStream: TStream; AEngine: TEngine);
    destructor Destroy; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
  end;

  { Engine.TEReadTextStorageStream (instance size 56): +$24 FPath, +$28 FSize, +$2C FSections,
    +$30 FText, +$34 FValues. The text form of the storage: "[:path:]" lines open the section of
    an object (its path is the ids of its parents joined with '\'), "[id]=value" lines are its
    properties; the section is split into FValues with the property table pointing at them. }
  TEReadTextStorageStream = class(TEStorageStream)
  private
    FPath: string;
    FSize: Integer;
    FSections: TStringList;
    FText: TStringList;
    FValues: TStringList;
    procedure ReadStreamText;
    procedure ReadTextBuffer;
  public
    constructor Create(AStream: TStream; AEngine: TEngine; ASize: Integer);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
  end;

  { Engine.TEWriteTextStorageStream (instance size 44): +$24 FPath, +$28 FBuffer. Each object's
    properties are collected in FBuffer and written behind the "[:path:]" line. }
  TEWriteTextStorageStream = class(TEStorageStream)
  private
    FPath: string;
    FBuffer: TEBufferStream;
    procedure WriteTextBuffer(Stream: TStream);
  public
    constructor Create(AStream: TStream; AEngine: TEngine);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
  end;

  { Engine.TTranslateStorageStream (instance size 36): visits every string of an object tree
    through TranslateString and TranslateStrings; nothing is read or written. }
  TTranslateStorageStream = class(TEStorageStream)
  public
    constructor Create(AEngine: TEngine);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
    procedure TranslateStrings(var Strings: TStrings); virtual;
    procedure TranslateString(var S: string); virtual;
  end;

  { Engine.TSetupCompareStorageStream (instance size 44): a read stream that announces a
    comparison to come (smSetupCompare) }
  TSetupCompareStorageStream = class(TEReadStorageStream)
  public
    function StorageMode: TStorageModes; override;
  end;

  { Engine.TCompareStorageStream (instance size 44): reads a stored copy and calls Mismatch for
    every property that differs from the object; Mismatch raises and swallows its own exception,
    a place for a breakpoint. }
  TCompareStorageStream = class(TEReadStorageStream)
  private
    procedure Mismatch(ID: Integer);
  public
    constructor Create(AStream: TStream; AEngine: TEngine);
    destructor Destroy; override;
    function StorageMode: TStorageModes; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer); override;
    procedure rwChildren(Node: TECustomNode; ID: Integer); override;
    procedure rwData(var Buffer; Size: Integer; ID: Integer); override;
    procedure rwString(var S: string; ID: Integer); override;
    procedure rwStrings(Strings: TStrings; ID: Integer); override;
    procedure rwStringsEx(Strings: TStrings; ID: Integer); override;
    procedure rwInteger(var I: Integer; ID: Integer); override;
    procedure rwByte(var B: Byte; ID: Integer); override;
    procedure rwWord(var W: Word; ID: Integer); override;
    procedure rwBool(var B: Boolean; ID: Integer); override;
    procedure rwShortint(var S: Shortint; ID: Integer); override;
    procedure rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); override;
    procedure rwByteEx(var B: Byte; Default: Byte; ID: Integer); override;
    procedure rwWordEx(var W: Word; Default: Word; ID: Integer); override;
    procedure rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); override;
  end;

  { SortStrings: Compare gets two strings with their objects; the linked lists follow the moves }
  TStringCompareFunc = function(const S1, S2: string; O1, O2: TObject): Integer;

function ReplaceText(S, Old, New: string): string;
procedure SortStrings(Strings: TStrings; Compare: TStringCompareFunc);
procedure SortStringsEx(Strings: TStrings; Compare: TStringCompareFunc; LinkedStrings: array of TStrings);
procedure SortStringsAscending(Strings: TStrings; LinkedStrings: array of TStrings);
procedure SortStringsDescending(Strings: TStrings; LinkedStrings: array of TStrings);
procedure SortStringsNumericalAscending(Strings: TStrings; LinkedStrings: array of TStrings);
procedure SortStringsNumericalDescending(Strings: TStrings; LinkedStrings: array of TStrings);
function HexToInt(const S: string): Integer;
function CopyStreamToClipboard(Stream: TStream; const Format: string): Integer;
function PasteStreamFromClipboard(Stream: TStream; const Format: string): Integer;
procedure RegisterPlugIn(PlugIn: TPlugIn);
procedure UnregisterPlugIn(PlugIn: TPlugIn);
procedure InitializePlugIns(AEngine: TEngine);
procedure FinalizePlugIns(AEngine: TEngine);
function GetPlugIn(Index: Integer): TPlugIn;
function FindPlugIn(Name: string): TPlugIn;
procedure LoadExternalPlugIns(const Directory: string);
procedure UnloadExternalPlugIns;

procedure InitMsg(var Msg: TEMsg; MsgID: Integer; Sender: TEObject);
procedure InitMsgEx(var Msg: TEMsg; MsgID: Integer; Sender: TEObject; Seq: Integer);
function GetCRC32(P: Pointer; Size: Integer): Integer;
function GetFileCRC32(const FileName: string): Integer;
procedure ReleaseCRC32Table;
function GetEngine(Index: Integer): TEngine;
function FindEngine(AClassID: Integer): TEngine;

var
  Engines: TList;
  PlugIns: TList;
  CopyEngine: TEngine;
  Packages: TStringList;
  ClipboardFormat: Word;
  EngineLoaded: Boolean;

procedure StringToStream(const S: string; Stream: TStream);
procedure StringFromStream(var S: string; Stream: TStream);
procedure StringsToStream(Strings: TStrings; Stream: TStream);
procedure StringsFromStream(Strings: TStrings; Stream: TStream);

resourcestring
  EStreamReadErrorStr = 'Error Reading EObject';
  EStreamWriteErrorStr = 'Error Writing EObject';
  UserStr = 'User';

implementation

{ strings }

{ TESortNode }

constructor TESortNode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FItems := nil;
end;

destructor TESortNode.Destroy;
begin
  inherited Destroy;
  Resize(0);
end;

class function TESortNode.ClassID: Integer;
begin
  Result := $104;
end;

procedure TESortNode.QuickClear;
begin
  Resize(0);
end;

function TESortNode.GetChild(Index: Integer): TEObject;
begin
  Result := FItems^[Index].Child;
end;

procedure TESortNode.SetChild(Index: Integer; Child: TEObject);
begin
  FItems^[Index].Child := Child;
end;

function TESortNode.GetSortValue(Index: Integer): Integer;
begin
  Result := FItems^[Index].SortValue;
end;

procedure TESortNode.SetSortValue(Index: Integer; Value: Integer);
begin
  FItems^[Index].SortValue := Value;
end;

function TESortNode.GetCount: Integer;
begin
  Result := FCount;
end;

procedure TESortNode.Resize(NewCapacity: Integer);
begin
  ReallocMem(FItems, NewCapacity * SizeOf(TSortItem));
  FCapacity := NewCapacity;
  if FCapacity < FCount then FCount := FCapacity;
end;

procedure TESortNode.Grow;
begin
  Resize(FCapacity + 2);
end;

function TESortNode.RemoveChild(Child: TEObject): Integer;
begin
  Result := FCount - 1;
  while (Result >= 0) and (Child <> FItems^[Result].Child) do Dec(Result);
  if Result >= 0 then
  begin
    Dec(FCount);
    if Result < FCount then
      Move(FItems^[Result + 1], FItems^[Result], (FCount - Result) shl 3);
  end;
end;

function TESortNode.AddChild(Child: TEObject): Integer;
begin
  Result := AddSortChild(Child, 0);
end;

function TESortNode.AddSortChild(Child: TEObject; SortValue: Integer): Integer;
var
  I: Integer;
begin
  if FCount >= FCapacity then Grow;
  if FSorted then
  begin
    I := FCount;
    while (I > 0) and (SortValue > FItems^[I - 1].SortValue) do Dec(I);
    if I <> FCount then Move(FItems^[I], FItems^[I + 1], (FCount - I) shl 3);
    FItems^[I].Child := Child;
    FItems^[I].SortValue := SortValue;
    Result := I;
  end
  else
  begin
    FItems^[FCount].Child := Child;
    FItems^[FCount].SortValue := SortValue;
    Result := FCount;
  end;
  Inc(FCount);
end;

procedure TESortNode.ReadWrite(Stream: TEStorageStream);
begin
  raise Exception.Create('Read/Write not supported (TESortNode)');
end;

procedure SortItems(SortList: PSortItemArray; L, R: Integer);
var
  I, J, P: Integer;
  T: TSortItem;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1].SortValue;
    repeat
      while P > SortList^[I].SortValue do Inc(I);
      while P < SortList^[J].SortValue do Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then SortItems(SortList, L, J);
    L := I;
  until I >= R;
end;

procedure TESortNode.Sort;
begin
  if not FSorted and (FCount > 0) then SortItems(FItems, 0, FCount - 1);
  FSorted := True;
end;

procedure InverseSortItems(SortList: PSortItemArray; L, R: Integer);
var
  I, J, P: Integer;
  T: TSortItem;
begin
  repeat
    I := L;
    J := R;
    P := SortList^[(L + R) shr 1].SortValue;
    repeat
      while P < SortList^[I].SortValue do Inc(I);
      while P > SortList^[J].SortValue do Dec(J);
      if I <= J then
      begin
        T := SortList^[I];
        SortList^[I] := SortList^[J];
        SortList^[J] := T;
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then InverseSortItems(SortList, L, J);
    L := I;
  until I >= R;
end;

{ TEInverseSortNode }

class function TEInverseSortNode.ClassID: Integer;
begin
  Result := $106;
end;

function TEInverseSortNode.AddSortChild(Child: TEObject; SortValue: Integer): Integer;
var
  I: Integer;
begin
  if FCount >= FCapacity then Grow;
  if FSorted then
  begin
    I := FCount;
    while (I > 0) and (SortValue < FItems^[I - 1].SortValue) do Dec(I);
    if I <> FCount then Move(FItems^[I], FItems^[I + 1], (FCount - I) shl 3);
    FItems^[I].Child := Child;
    FItems^[I].SortValue := SortValue;
    Result := I;
  end
  else
  begin
    FItems^[FCount].Child := Child;
    FItems^[FCount].SortValue := SortValue;
    Result := FCount;
  end;
  Inc(FCount);
end;

procedure TEInverseSortNode.Sort;
begin
  if not FSorted and (FCount > 0) then InverseSortItems(FItems, 0, FCount - 1);
  FSorted := True;
end;

{ TEControlStyleSortNode }

constructor TEControlStyleSortNode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

class function TEControlStyleSortNode.ClassID: Integer;
begin
  Result := $105;
end;

function TEControlStyleSortNode.GetControlStyle: TEControlStyles;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleSortNode.SetControlStyle(Value: TEControlStyles);
begin
  FControlStyle := Value;
end;

{ TEControlStyleInverseSortNode }

constructor TEControlStyleInverseSortNode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

class function TEControlStyleInverseSortNode.ClassID: Integer;
begin
  Result := $107;
end;

function TEControlStyleInverseSortNode.GetControlStyle: TEControlStyles;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleInverseSortNode.SetControlStyle(Value: TEControlStyles);
begin
  FControlStyle := Value;
end;

{ TCompressStream }

const
  CompressMagic: array[0..3] of Char = 'CFS'#0;

procedure TCompressStream.LoadFromStream(Stream: TStream);
var
  Compressed: Boolean;
  Magic: array[0..3] of Char;
  D: TDecompressionStream;
  Buffer: Pointer;
  Count: Integer;
begin
  Stream.Read(Magic, SizeOf(Magic));
  Stream.Read(Compressed, SizeOf(Compressed));
  if Magic <> CompressMagic then
  begin
    Compressed := False;
    Stream.Seek(0, soFromBeginning);
  end;
  if Compressed then
  begin
    Buffer := nil;
    Count := -1;
    ReallocMem(Buffer, 8096);
    D := TDecompressionStream.Create(Stream);
    try
      while Count <> 0 do
      begin
        Count := D.Read(Buffer^, 8096);
        if Count <> 0 then WriteBuffer(Buffer^, Count);
      end;
    finally
      ReallocMem(Buffer, 0);
      D.Free;
    end;
  end
  else
    CopyFrom(Stream, Stream.Size - Stream.Position);
  Position := 0;
end;

function TCompressStream.SaveToStreamEx(Stream: TStream; Level: Byte): Integer;
var
  C: TCompressionStream;
  StartSize: Integer;
begin
  Position := 0;
  Result := 100;
  StartSize := Stream.Size;
  Stream.Write(CompressMagic, SizeOf(CompressMagic));
  Stream.Write(Level, SizeOf(Level));
  if Level <> 0 then
  begin
    C := TCompressionStream.Create(TCompressionLevel(Level), Stream);
    try
      C.CopyFrom(Self, 0);
      Result := Round((1 - (Stream.Size - StartSize) / Size) * 100);
    finally
      C.Free;
    end;
  end
  else
    Stream.CopyFrom(Self, 0);
end;

procedure TCompressStream.SaveToStream(Stream: TStream);
begin
  SaveToStreamEx(Stream, 2);
end;

function TCompressStream.SaveToFileEx(const FileName: string; Level: Byte): Integer;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    Result := SaveToStreamEx(F, Level);
  finally
    F.Free;
  end;
end;

procedure TCompressStream.SaveToFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStreamEx(F, 2);
  finally
    F.Free;
  end;
end;

procedure TCompressStream.LoadFromFile(const FileName: string);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    LoadFromStream(F);
  finally
    F.Free;
  end;
end;

{ TETimerNode }

constructor TETimerNode.Create(AOwner: TECustomNode);
var
  I: Integer;
begin
  inherited Create(AOwner);
  FCount := 0;
  for I := 1 to 10 do FTimerLists[I] := TList.Create;
end;

destructor TETimerNode.Destroy;
var
  I: Integer;
begin
  inherited Destroy;
  for I := 1 to 10 do FTimerLists[I].Free;
end;

class function TETimerNode.ClassID: Integer;
begin
  Result := $108;
end;

function TETimerNode.GetControlStyle: TEControlStyles;
begin
  Result := [csStored, csShared, csReserved2];
end;

function TETimerNode.GetCount: Integer;
begin
  Result := FCount;
end;

function TETimerNode.GetTimerList(Timer: Shortint): TList;
begin
  Result := FTimerLists[Timer];
end;

function TETimerNode.FindTimerList(Child: TEObject): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I < 10) do
  begin
    Inc(I);
    { the original indexes the lists with Result (-1 on the first round), not with I }
    Result := FTimerLists[Result].IndexOf(Child);
  end;
  if Result <> -1 then Result := I else Result := -1;
end;

function TETimerNode.RemoveChild(Child: TEObject): Integer;
var
  L: Integer;
begin
  L := FindTimerList(Child);
  if L <> -1 then
  begin
    Result := FTimerLists[L].Remove(Child);
    if Result <> -1 then Dec(FCount);
  end
  else
    Result := -1;
end;

function TETimerNode.AddChild(Child: TEObject): Integer;
begin
  Result := FTimerLists[1].Add(Child);
  Inc(FCount);
end;

function TETimerNode.GetChild(Index: Integer): TEObject;
var
  I, Total: Integer;
  L: TList;
begin
  I := 1;
  L := FTimerLists[1];
  Total := L.Count;
  while (Index >= Total) and (I < 10) do
  begin
    Inc(I);
    L := FTimerLists[I];
    Inc(Total, L.Count);
  end;
  L := FTimerLists[I];
  Dec(Total, L.Count);
  Result := TEObject(L.List^[Index - Total]);
end;

procedure TETimerNode.SetChild(Index: Integer; Child: TEObject);
begin
  raise Exception.Create('Set Child not supported (TETimerNode)');
end;

function TETimerNode.AddTimerChild(Child: TEObject; Timer: Shortint): Integer;
begin
  Result := FTimerLists[Timer].Add(Child);
  Inc(FCount);
end;

function TETimerNode.RemoveTimerChild(Child: TEObject; Timer: Shortint): Integer;
begin
  Result := FTimerLists[Timer].Remove(Child);
  if Result <> -1 then Dec(FCount);
end;

procedure TETimerNode.TriggerTimerListEvent(Timer: Integer);
var
  I: Integer;
begin
  for I := 0 to FTimerLists[Timer].Count - 1 do
    TEObject(FTimerLists[Timer].List^[I]).TimerEvent(FTick, Self);
end;

procedure TETimerNode.TriggerTimerEvent;
begin
  if FTick > $FFFFFFF then FTick := FTick and $F;
  Inc(FTick);
  TriggerTimerListEvent(1);
  if FTick and 1 = 0 then TriggerTimerListEvent(2);
  if FTick mod 3 = 0 then TriggerTimerListEvent(3);
  if FTick and 3 = 2 then TriggerTimerListEvent(4);
  if FTick mod 5 = 0 then TriggerTimerListEvent(5);
  if FTick mod 6 = 0 then TriggerTimerListEvent(6);
  if FTick mod 7 = 0 then TriggerTimerListEvent(7);
  if FTick and 7 = 4 then TriggerTimerListEvent(8);
  if FTick mod 9 = 0 then TriggerTimerListEvent(9);
  if FTick mod 10 = 0 then TriggerTimerListEvent(10);
end;

{ Strings }

function ReplaceText(S, Old, New: string): string;
var
  P: Integer;
begin
  Result := '';
  P := Pos(Old, S);
  while P <> 0 do
  begin
    Result := Result + Copy(S, 1, P - 1) + New;
    S := Copy(S, P + Length(Old), Length(S) - P - Length(Old) + 1);
    P := Pos(Old, S);
  end;
  Result := Result + S;
end;

type
  TExchangeProc = procedure(Data: TList; I, J: Integer);
  TSortStringsContext = record
    Strings: TStrings;
    Compare: TStringCompareFunc;
    ExchangeProc: TExchangeProc;
    ExchangeData: TList;
  end;

procedure QuickSortStrings(var Ctx: TSortStringsContext; L, R: Integer);
var
  I, J, M: Integer;
  PO: TObject;
  P: string;
begin
  repeat
    I := L;
    J := R;
    M := (L + R) shr 1;
    P := Ctx.Strings[M];
    PO := Ctx.Strings.Objects[M];
    repeat
      while Ctx.Compare(Ctx.Strings[I], P, Ctx.Strings.Objects[I], PO) < 0 do Inc(I);
      while Ctx.Compare(Ctx.Strings[J], P, Ctx.Strings.Objects[J], PO) > 0 do Dec(J);
      if I <= J then
      begin
        Ctx.Strings.Exchange(I, J);
        if Assigned(Ctx.ExchangeProc) then Ctx.ExchangeProc(Ctx.ExchangeData, I, J);
        Inc(I);
        Dec(J);
      end;
    until I > J;
    if L < J then QuickSortStrings(Ctx, L, J);
    L := I;
  until I >= R;
end;

procedure SortStrings(Strings: TStrings; Compare: TStringCompareFunc);
var
  Ctx: TSortStringsContext;
begin
  if Strings.Count <> 0 then
  begin
    Ctx.Strings := Strings;
    Ctx.Compare := Compare;
    Ctx.ExchangeProc := nil;
    QuickSortStrings(Ctx, 0, Strings.Count - 1);
  end;
end;

procedure ExchangeLinkedStrings(Lists: TList; I, J: Integer);
var
  K: Integer;
begin
  for K := Lists.Count - 1 downto 0 do TStrings(Lists.List^[K]).Exchange(I, J);
end;

procedure SortStringsEx(Strings: TStrings; Compare: TStringCompareFunc; LinkedStrings: array of TStrings);
var
  Lists: TList;
  I: Integer;
  Ctx: TSortStringsContext;
begin
  if Strings.Count <> 0 then
  begin
    Strings.BeginUpdate;
    Ctx.Strings := Strings;
    Ctx.Compare := Compare;
    if High(LinkedStrings) >= 0 then
    begin
      Lists := TList.Create;
      for I := 0 to High(LinkedStrings) do
      begin
        LinkedStrings[I].BeginUpdate;
        Lists.Add(LinkedStrings[I]);
      end;
      Ctx.ExchangeProc := ExchangeLinkedStrings;
      Ctx.ExchangeData := Lists;
    end
    else
      Lists := nil;
    QuickSortStrings(Ctx, 0, Strings.Count - 1);
    if Lists <> nil then
    begin
      for I := 0 to High(LinkedStrings) do LinkedStrings[I].EndUpdate;
      Lists.Free;
    end;
    Strings.EndUpdate;
  end;
end;

function CompareAscending(const S1, S2: string; O1, O2: TObject): Integer;
begin
  Result := CompareText(S1, S2);
  if Result = 0 then Result := Length(S1) - Length(S2);
end;

procedure SortStringsAscending(Strings: TStrings; LinkedStrings: array of TStrings);
begin
  SortStringsEx(Strings, CompareAscending, LinkedStrings);
end;

function CompareDescending(const S1, S2: string; O1, O2: TObject): Integer;
begin
  Result := CompareText(S2, S1);
  if Result = 0 then Result := Length(S2) - Length(S1);
end;

procedure SortStringsDescending(Strings: TStrings; LinkedStrings: array of TStrings);
begin
  SortStringsEx(Strings, CompareDescending, LinkedStrings);
end;

function CompareNumericalAscending(const S1, S2: string; O1, O2: TObject): Integer;
var
  V1, V2: Integer;
begin
  V1 := StrToIntDef(S1, -1);
  V2 := StrToIntDef(S2, -1);
  Result := V1 - V2;
end;

procedure SortStringsNumericalAscending(Strings: TStrings; LinkedStrings: array of TStrings);
begin
  SortStringsEx(Strings, CompareNumericalAscending, LinkedStrings);
end;

function CompareNumericalDescending(const S1, S2: string; O1, O2: TObject): Integer;
var
  V1, V2: Integer;
begin
  V1 := StrToIntDef(S1, -1);
  V2 := StrToIntDef(S2, -1);
  Result := V2 - V1;
end;

procedure SortStringsNumericalDescending(Strings: TStrings; LinkedStrings: array of TStrings);
begin
  SortStringsEx(Strings, CompareNumericalDescending, LinkedStrings);
end;

function HexToInt(const S: string): Integer;
var
  I, L, D: Integer;
  C: Char;
begin
  Result := 0;
  L := Length(S);
  if L > 8 then L := 8;
  for I := 0 to L - 1 do
  begin
    C := S[L - I];
    if C in ['0'..'9'] then
      D := Ord(C) - Ord('0')
    else if C in ['A'..'F'] then
      D := Ord(C) - Ord('A') + 10
    else if C in ['a'..'f'] then
      D := Ord(C) - Ord('a') + 10
    else
      D := 0;
    Result := Result or (D shl (I * 4));
  end;
end;

procedure StringToStream(const S: string; Stream: TStream);
var
  Len: Integer;
begin
  Len := Length(S);
  Stream.Write(Len, SizeOf(Integer));
  Stream.Write(PChar(S)^, Len);
end;

procedure StringFromStream(var S: string; Stream: TStream);
var
  Len: Integer;
begin
  Stream.Read(Len, SizeOf(Integer));
  SetLength(S, Len);
  Stream.Read(S[1], Len);
end;

procedure SaveStringToStream(const S: string; Stream: TStream);
var
  Len: Integer;
  B: Byte;
begin
  Len := Length(S);
  if Len < $FF then
  begin
    B := Len;
    Stream.Write(B, SizeOf(Byte));
  end
  else
  begin
    B := $FF;
    Stream.Write(B, SizeOf(Byte));
    Stream.Write(Len, SizeOf(Integer));
  end;
  Stream.Write(PChar(S)^, Len);
end;

procedure LoadStringFromStream(var S: string; Stream: TStream);
var
  Len: Integer;
  B: Byte;
begin
  S := '';
  Stream.Read(B, SizeOf(Byte));
  if B = $FF then
    Stream.Read(Len, SizeOf(Integer))
  else
    Len := B;
  SetLength(S, Len);
  Stream.Read(S[1], Len);
end;

procedure StringsToStream(Strings: TStrings; Stream: TStream);
var
  P: PChar;
  Len: Integer;
begin
  P := Strings.GetText;
  Len := Length(P);
  Stream.Write(Len, SizeOf(Integer));
  Stream.WriteBuffer(P^, Len);
  StrDispose(P);
end;

procedure StringsFromStream(Strings: TStrings; Stream: TStream);
var
  Len: Integer;
  S: string;
begin
  Strings.BeginUpdate;
  try
    Stream.Read(Len, SizeOf(Integer));
    SetString(S, nil, Len);
    Stream.Read(Pointer(S)^, Len);
    Strings.Text := S;
  finally
    Strings.EndUpdate;
  end;
end;

procedure StringsToStreamEx(Strings: TStrings; Stream: TStream);
var
  P: PChar;
  Len, I, Obj: Integer;
begin
  P := Strings.GetText;
  Len := Length(P);
  Stream.Write(Len, SizeOf(Integer));
  Stream.WriteBuffer(P^, Len);
  StrDispose(P);
  for I := 0 to Strings.Count - 1 do
  begin
    Obj := Integer(Strings.Objects[I]);
    Stream.Write(Obj, SizeOf(Integer));
  end;
end;

procedure StringsFromStreamEx(Strings: TStrings; Stream: TStream);
var
  Len, I, Obj: Integer;
  S: string;
begin
  Strings.BeginUpdate;
  try
    Stream.Read(Len, SizeOf(Integer));
    SetString(S, nil, Len);
    Stream.Read(Pointer(S)^, Len);
    Strings.Text := S;
    for I := 0 to Strings.Count - 1 do
    begin
      Stream.Read(Obj, SizeOf(Integer));
      Strings.Objects[I] := TObject(Obj);
    end;
  finally
    Strings.EndUpdate;
  end;
end;

{ TPropertyTable }

destructor TPropertyTable.Destroy;
begin
  SetCapacity(0);
  ReallocMem(FStack, 0);
  inherited Destroy;
end;

procedure TPropertyTable.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity > 0 then
    NewCapacity := (NewCapacity + 31) and not 31;
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FItems, NewCapacity * SizeOf(TPropertyItem));
    FCapacity := NewCapacity;
    if FCapacity < FCount then
      FCount := FCapacity;
  end;
end;

procedure TPropertyTable.Add(ID, Offset: Integer);
begin
  if FCapacity = FCount then
    SetCapacity(FCapacity + 1);
  FItems^[FCount].ID := ID;
  FItems^[FCount].Offset := Offset;
  Inc(FCount);
  if ID > FMaxID then
    FMaxID := ID;
end;

procedure TPropertyTable.Clear;
begin
  FNextIndex := 0;
  FMaxID := 0;
  SetCapacity(0);
end;

function TPropertyTable.FindOffset(ID: Integer): Integer;
var
  I: Integer;
begin
  I := FNextIndex;
  if (I >= FCount) or (FItems^[I].ID <> ID) then
  begin
    I := FFirst;
    Result := -1;
    while (I < FCount) and (FItems^[I].ID <> ID) do
      Inc(I);
    if I <> FCount then
    begin
      Result := FItems^[I].Offset;
      FNextIndex := I + 1;
    end;
  end
  else
  begin
    Result := FItems^[I].Offset;
    Inc(FNextIndex);
  end;
end;

function TPropertyTable.PropertyExist(ID: Integer): Boolean;
var
  I: Integer;
begin
  if ID <= FMaxID then
  begin
    I := FFirst;
    while (I < FCount) and (FItems^[I].ID <> ID) do
      Inc(I);
    Result := I <> FCount;
  end
  else
    Result := False;
end;

procedure TPropertyTable.BackupSettings;
begin
  if FStackCount = FStackCapacity then
  begin
    Inc(FStackCapacity, 16);
    ReallocMem(FStack, FStackCapacity * SizeOf(TPropertySettings));
  end;
  with FStack^[FStackCount] do
  begin
    First := FFirst;
    NextIndex := FNextIndex;
    MaxID := FMaxID;
  end;
  Inc(FStackCount);
  FNextIndex := FCount;
  FFirst := FCount;
  FMaxID := 0;
end;

procedure TPropertyTable.RestoreSettings;
begin
  Dec(FStackCount);
  FCount := FFirst;
  with FStack^[FStackCount] do
  begin
    FFirst := First;
    FNextIndex := NextIndex;
    FMaxID := MaxID;
  end;
end;

procedure TPropertyTable.LoadFromStream(Stream: TStream);
var
  LongCount, ID, Offset: Integer;
  ShortCount: Byte;
  Pair: Word;
  I: Word;
begin
  Stream.Read(ShortCount, 1);
  if (ShortCount and $80) <> 0 then
  begin
    ShortCount := ShortCount and $7F;
    Stream.Read(LongCount, 4);
  end
  else
    LongCount := 0;
  if ShortCount <> 0 then
    for I := 0 to ShortCount - 1 do
    begin
      Stream.Read(Pair, 2);
      Add(Pair and $FF, Pair shr 8);
    end;
  if LongCount <> 0 then
    for I := 0 to LongCount - 1 do
    begin
      Stream.Read(ID, 4);
      Stream.Read(Offset, 4);
      Add(ID, Offset);
    end;
end;

procedure TPropertyTable.SaveToStream(Stream: TStream);
var
  LongCount, I: Integer;
  ShortCount, Marker: Byte;
  Pair: Integer;
begin
  LongCount := 0;
  ShortCount := 0;
  for I := FFirst to FCount - 1 do
    if (FItems^[I].ID <= $7F) and (FItems^[I].Offset <= $FF) then
      Inc(ShortCount)
    else
      Inc(LongCount);
  if LongCount <> 0 then
  begin
    Marker := ShortCount or $80;
    Stream.Write(Marker, 1);
    Stream.Write(LongCount, 4);
  end
  else
    Stream.Write(ShortCount, 1);
  if ShortCount <> 0 then
    for I := FFirst to FCount - 1 do
      if (FItems^[I].ID <= $7F) and (FItems^[I].Offset <= $FF) then
      begin
        Pair := FItems^[I].ID + FItems^[I].Offset shl 8;
        Stream.Write(Pair, 2);
      end;
  if LongCount <> 0 then
    for I := FFirst to FCount - 1 do
      if (FItems^[I].ID > $7F) or (FItems^[I].Offset > $FF) then
      begin
        Stream.Write(FItems^[I].ID, 4);
        Stream.Write(FItems^[I].Offset, 4);
      end;
end;

{ TEObject }

constructor TEObject.Create(AOwner: TECustomNode);
begin
  inherited Create;
  SetOwner(AOwner);
end;

destructor TEObject.Destroy;
begin
  SetOwner(nil);
  inherited Destroy;
end;

function TEObject.ClassVersion: Integer;
begin
  Result := 0;
end;

function TEObject.AddRef: Integer;
begin
  raise Exception.Create('Reference counting not supported');
end;

function TEObject.Release: Integer;
begin
  raise Exception.Create('Reference counting not supported');
end;

procedure TEObject.Clear;
begin
end;

class function TEObject.ClassID: Integer;
begin
  Result := 80;
end;

function TEObject.Editor: TClass;
var
  C: TClass;
  E: TEngine;
begin
  Result := nil;
  C := ClassType;
  E := GetEngine;
  if E <> nil then
    while (C <> TEObject) and (Result = nil) do
    begin
      Result := E.FEditors.FindEditor(TEObjectClass(C).ClassID);
      if Result = nil then C := C.ClassParent;
    end;
  if Result = nil then Result := TEObjectEditor;
end;

procedure TEObject.TimerEvent(Tick: Integer; Sender: TEObject);
begin
end;

function TEObject.GetEObjectPath: string;
var
  P: TEObject;
  S: string;
begin
  S := ClassName;
  P := FOwner;
  while P <> nil do
  begin
    S := P.ClassName + '' + S;
    P := P.FOwner;
  end;
  Result := S;
end;

function TEObject.GetLastMsg: Integer;
begin
  Result := MaxInt;
end;

procedure TEObject.SetLastMsg(Value: Integer);
begin
end;

function TEObject.Compare(Obj: TEObject; AEngine: TEngine): Boolean;
var
  S1, S2: TMemoryStream;
begin
  Result := False;
  if ClassID <> Obj.ClassID then Exit;
  S1 := TMemoryStream.Create;
  S2 := TMemoryStream.Create;
  try
    AEngine.WriteEObject(S1, Self, nil);
    AEngine.WriteEObject(S2, Obj, nil);
    Result := (S1.Size = S2.Size) and CompareMem(S1.Memory, S2.Memory, S1.Size);
  finally
    S1.Free;
    S2.Free;
  end;
end;

procedure TEObject.Assign(Source: TEObject; AEngine: TEngine);
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    AEngine.WriteEObject(S, Source, nil);
    S.Position := 0;
    AEngine.ReadEObject(S, Self, nil);
  finally
    S.Destroy;
  end;
end;

function TEObject.Copy(AEngine: TEngine): TEObject;
var
  S: TMemoryStream;
begin
  S := TMemoryStream.Create;
  try
    AEngine.WriteEObject(S, Self, nil);
    S.Position := 0;
    Result := TEObjectClass(ClassType).Create(nil);
    AEngine.ReadEObject(S, Result, nil);
  finally
    S.Destroy;
  end;
end;

function TEObject.GetEngine: TEngine;
begin
  Result := FOwner.GetEngine;
end;

function TEObject.GetControlStyle: TEControlStyles;
begin
  Result := [csStored];
end;

procedure TEObject.SetOwner(AOwner: TECustomNode);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveChild(Self);
    FOwner := AOwner;
    if FOwner <> nil then FOwner.AddChild(Self);
  end;
end;

procedure TEObject.SetArrayOwner(AOwner: TECustomNode; Index: Integer);
begin
  if FOwner <> nil then FOwner.RemoveChild(Self);
  FOwner := AOwner;
  if FOwner <> nil then FOwner.SetChild(Index, Self);
end;

procedure TEObject.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = 1 then SetLastMsg(MaxInt);
end;

procedure TEObject.ReadWrite(Stream: TEStorageStream);
begin
end;

procedure TEObject.MainReadWrite(Stream: TEStorageStream);
begin
  if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then Clear;
  ReadWrite(Stream);
end;

{ TECustomNode }

destructor TECustomNode.Destroy;
begin
  DestroyAllChildren;
  inherited Destroy;
end;

procedure TECustomNode.DestroyAllChildren;
var
  C: TEObject;
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    C := Children[I];
    if (C <> nil) and (C.Owner = Self) then C.Destroy;
  end;
  if Count <> 0 then
    for I := Count - 1 downto 0 do
    begin
      C := Children[I];
      if C <> nil then RemoveChild(C);
    end;
end;

procedure TECustomNode.Clear;
var
  I: Integer;
  C: TEObject;
begin
  if Count <> 0 then
  begin
    for I := Count - 1 downto 0 do
    begin
      C := Children[I];
      if (C <> nil) and (C.Owner = Self) then
        if not (csShared in C.GetControlStyle) then C.Destroy else C.Clear;
    end;
    for I := Count - 1 downto 0 do
    begin
      C := Children[I];
      if C <> nil then
        if not ((C.Owner = Self) and (csShared in C.GetControlStyle)) then RemoveChild(C);
    end;
  end;
end;

procedure TECustomNode.Assign(Source: TEObject; AEngine: TEngine);
begin
  Clear;
  inherited Assign(Source, AEngine);
end;

procedure TECustomNode.QuickClear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do RemoveChild(Children[I]);
end;

procedure TECustomNode.ReadWriteChildren(Stream: TEStorageStream);
begin
  Stream.rwChildren(Self, 1);
end;

procedure TECustomNode.MainReadWrite(Stream: TEStorageStream);
begin
  if smRead in Stream.StorageMode then
    if Stream.StorageMode * [smText, smCompare] = [] then Clear;
  ReadWrite(Stream);
  ReadWriteChildren(Stream);
end;

procedure TECustomNode.SendMsg(var Msg: TEMsg; Sender: TEObject);
var
  I: Integer;
  C: TEObject;
begin
  if Msg.MsgID and $10000000 <> 0 then
    if Msg.MsgID and $20000000 = 0 then
      for I := Count - 1 downto 0 do
      begin
        C := Children[I];
        if (C <> nil) and (C.GetLastMsg <> Msg.Seq) then
        begin
          C.SetLastMsg(Msg.Seq);
          C.MsgProc(Msg, Self);
        end;
      end
    else
      for I := Count - 1 downto 0 do
      begin
        C := Children[I];
        if (C <> nil) and (C.GetLastMsg <> Msg.Seq) and (C.Owner = Self) then
        begin
          C.SetLastMsg(Msg.Seq);
          C.MsgProc(Msg, Self);
        end;
      end
  else
    if Msg.MsgID and $20000000 = 0 then
      for I := Count - 1 downto 0 do
      begin
        C := Children[I];
        if C <> nil then C.MsgProc(Msg, Self);
      end
    else
      for I := Count - 1 downto 0 do
      begin
        C := Children[I];
        if (C <> nil) and (C.Owner = Self) then C.MsgProc(Msg, Self);
      end;
end;

function TECustomNode.SendToChild(var Msg: TEMsg): Boolean;
begin
  Result := Msg.MsgID and $40000000 = 0;
end;

procedure TECustomNode.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if SendToChild(Msg) then SendMsg(Msg, Sender);
end;

function TECustomNode.FindChild(AClassID: Integer): TEObject;
var
  I: Integer;
  Found: Boolean;
  C: TEObject;
begin
  I := 0;
  Found := False;
  C := nil;
  while not Found and (I < Count) do
  begin
    C := Children[I];
    Found := (C <> nil) and (C.ClassID = AClassID);
    Inc(I);
  end;
  if Found then Result := C else Result := nil;
end;

function TECustomNode.FindOwnedChild(AClassID: Integer): TEObject;
var
  I: Integer;
  Found: Boolean;
  C: TEObject;
begin
  I := 0;
  Found := False;
  C := nil;
  while not Found and (I < Count) do
  begin
    C := Children[I];
    Found := (C <> nil) and (C.Owner = Self) and (AClassID = C.ClassID);
    Inc(I);
  end;
  if Found then Result := C else Result := nil;
end;

function TECustomNode.FindChildIndex(Child: TEObject): Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (Child <> Children[Result]) do Dec(Result);
end;

function TECustomNode.FindChildInTree(AClassID: Integer): TEObject;
var
  I: Integer;
begin
  Result := FindChild(AClassID);
  if Result = nil then
  begin
    I := 0;
    while I < Count do
    begin
      if Children[I] is TECustomNode then
        Result := TECustomNode(Children[I]).FindChildInTree(AClassID);
      Inc(I);
      if Result <> nil then Break;
    end;
  end;
end;

function TECustomNode.DestroyChildren(AClassID: Integer): Integer;
var
  I: Integer;
  C: TEObject;
  N: Integer;
begin
  N := 0;
  for I := Count - 1 downto 0 do
  begin
    C := Children[I];
    if (C <> nil) and (C.ClassID = AClassID) then
    begin
      C.Destroy;
      Inc(N);
    end;
  end;
  Result := N;
end;

{ TENode }

constructor TENode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FChildren := TEObjectList.Create;
end;

destructor TENode.Destroy;
begin
  inherited Destroy;
  FChildren.Free;
end;

procedure TENode.DestroyAllChildren;
var
  I: Integer;
  C: TEObject;
begin
  Clear;
  if FChildren.Count <> 0 then
    for I := FChildren.Count - 1 downto 0 do
    begin
      C := TEObject(FChildren.List^[I]);
      if (C <> nil) and (C.Owner = Self) then C.Destroy;
    end;
end;

procedure TENode.Clear;
var
  I: Integer;
  C: TEObject;
begin
  for I := Count - 1 downto 0 do
  begin
    C := TEObject(FChildren.List^[I]);
    if (C <> nil) and (C.Owner = Self) then
      if not (csShared in C.GetControlStyle) then C.Destroy else C.Clear;
  end;
  if Count <> 0 then
  begin
    for I := Count - 1 downto 0 do
    begin
      C := TEObject(FChildren.List^[I]);
      if C <> nil then
        if not ((C.Owner = Self) and (csShared in C.GetControlStyle)) then RemoveChild(C);
    end;
    I := FChildren.Count - 1;
    while (I >= 0) and (FChildren.List^[I] = nil) do
    begin
      FChildren.Delete(I);
      Dec(I);
    end;
  end;
end;

class function TENode.ClassID: Integer;
begin
  Result := 256;
end;

function TENode.GetChild(Index: Integer): TEObject;
begin
  Result := TEObject(FChildren.List^[Index]);
end;

procedure TENode.SetChild(Index: Integer; Child: TEObject);
begin
  while Index >= Count do FChildren.Add(nil);
  if (FChildren.List^[Index] <> nil) and (TEObject(FChildren.List^[Index]).Owner = Self) then
    TEObject(FChildren.List^[Index]).Destroy;
  FChildren.List^[Index] := Child;
end;

function TENode.GetCount: Integer;
begin
  Result := FChildren.Count;
end;

procedure TENode.SendMsg(var Msg: TEMsg; Sender: TEObject);
var
  I: Integer;
begin
  with FChildren do
    if csKeepIndex in GetControlStyle then
      if Msg.MsgID and $10000000 <> 0 then
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(List^[I]) do
              begin
                if GetLastMsg <> Msg.Seq then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
              end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(Items[I]) do
              begin
                if (GetLastMsg <> Msg.Seq) and (Owner = Self) then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
              end;
        end
      else
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(List^[I]) do
              begin
                MsgProc(Msg, Self);
              end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(Items[I]) do
              begin
                if Owner = Self then MsgProc(Msg, Self);
              end;
        end
    else
      if Msg.MsgID and $10000000 <> 0 then
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            with TEObject(List^[I]) do
            begin
                if GetLastMsg <> Msg.Seq then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
            end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            with TEObject(Items[I]) do
            begin
                if (GetLastMsg <> Msg.Seq) and (Owner = Self) then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
            end;
        end
      else
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            with TEObject(List^[I]) do
            begin
                MsgProc(Msg, Self);
            end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            with TEObject(Items[I]) do
            begin
                if Owner = Self then MsgProc(Msg, Self);
            end;
        end;
end;

function TENode.RemoveChild(Child: TEObject): Integer;
begin
  if csKeepIndex in GetControlStyle then
  begin
    Result := FChildren.IndexOf(Child);
    if Result <> -1 then FChildren.List^[Result] := nil;
  end
  else
    Result := FChildren.Remove(Child);
end;

function TENode.AddChild(Child: TEObject): Integer;
begin
  FChildren.Add(Child);
  Result := FChildren.Count - 1;
end;

function TENode.FindChild(AClassID: Integer): TEObject;
var
  I: Integer;
  Found: Boolean;
  C: TEObject;
begin
  I := 0;
  Found := False;
  C := nil;
  while not Found and (I < FChildren.Count) do
  begin
    C := TEObject(FChildren.List^[I]);
    Found := (C <> nil) and (AClassID = C.ClassID);
    Inc(I);
  end;
  if Found then Result := C else Result := nil;
end;

function TENode.FindChildIndex(Child: TEObject): Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (Child <> TEObject(FChildren.List^[Result])) do Dec(Result);
end;

procedure TENode.DestroyEObjects(AClassID: Integer);
var
  I: Integer;
  C: TEObject;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    C := TEObject(FChildren.List^[I]);
    if (C <> nil) and (AClassID = C.ClassID) and (C.Owner = Self) then C.Destroy;
  end;
end;

{ TEObjectEditor: stubs }

class function TEObjectEditor.EditorClassID: Integer;
begin
  Result := 0;
end;

procedure TEObjectEditor.Edit(Obj: TEObject; CreateEditor: TEditorConstructor);
begin
  CreateEditor(True, Obj);
end;

procedure TEObjectEditor.UpdateMultiPopupMenu(Objects: TList; Menu: TObject; A, B, C: Integer);
begin
end;

procedure TEObjectEditor.UpdatePopupMenu(Obj: TEObject; Menu: TObject; A, B: Integer);
begin
end;

{ CRC32 }

var
  CRC32Table: PIntegerArray;

procedure BuildCRC32Table;
var
  I, J, C, Polynomial: Integer;
begin
  if CRC32Table = nil then
  begin
    GetMem(CRC32Table, 256 * SizeOf(Integer));
    Polynomial := Integer($EDB88320);
    for I := 0 to 255 do
    begin
      C := I;
      for J := 7 downto 0 do
      begin
        if C and 1 <> 0 then C := (C shr 1) xor Polynomial else C := C shr 1;
        CRC32Table^[I] := C;
      end;
    end;
  end;
end;

procedure ReleaseCRC32Table;
begin
  FreeMem(CRC32Table);
end;

function GetCRC32(P: Pointer; Size: Integer): Integer;
begin
  if CRC32Table = nil then BuildCRC32Table;
  Result := -1;
  while Size <> 0 do
  begin
    Result := CRC32Table^[(PByte(P)^ xor Result) and $FF] xor ((Result shr 8) and $FFFFFF);
    Inc(PByte(P));
    Dec(Size);
  end;
  Result := Result xor $FFFFFFFF;
end;

function GetFileCRC32(const FileName: string): Integer;
var
  M: TMemoryStream;
  F: TFileStream;
begin
  M := TMemoryStream.Create;
  try
    F := TFileStream.Create(FileName, fmOpenRead);
    try
      M.LoadFromStream(F);
      Result := GetCRC32(M.Memory, M.Size);
    finally
      F.Free;
    end;
  finally
    M.Free;
  end;
end;

{ Clipboard: a registered format holding the format name, its length and the stream bytes }

function CopyStreamToClipboard(Stream: TStream; const Format: string): Integer;
var
  SavedPosition: Integer;
  H: THandle;
  P: PChar;
begin
  SavedPosition := Stream.Position;
  Result := -1;
  if OpenClipboard(Application.Handle) and (Format <> '') then
  try
    Stream.Position := 0;
    H := GlobalAlloc(GMEM_MOVEABLE, Length(Format) + 4 + 4 + Stream.Size);
    try
      P := GlobalLock(H);
      try
        PInteger(P)^ := Length(Format);
        Move(PChar(Format)^, P[4], Length(Format));
        PInteger(P + 4 + Length(Format))^ := Stream.Size;
        Inc(P, 4);
        Stream.ReadBuffer(P[Length(Format) + 4], Stream.Size);
        SetClipboardData(ClipboardFormat, H);
        Result := Stream.Size;
      finally
        GlobalUnlock(H);
      end;
    except
      GlobalFree(H);
      raise;
    end;
  finally
    Stream.Position := SavedPosition;
    CloseClipboard;
  end;
end;

function PasteStreamFromClipboard(Stream: TStream; const Format: string): Integer;
var
  H: THandle;
  P: PChar;
  L: Integer;
  S: string;
begin
  Result := -1;
  if OpenClipboard(Application.Handle) then
  try
    H := GetClipboardData(ClipboardFormat);
    if H <> 0 then
    begin
      P := GlobalLock(H);
      try
        if GlobalSize(THandle(P)) > 4 then
        begin
          L := PInteger(P)^;
          SetLength(S, L);
          Move(P[4], S[1], L);
          if S = Format then
          begin
            Inc(P, 4);
            P := PChar(L + Integer(P));
            L := PInteger(P)^;
            Stream.Position := 0;
            Stream.Size := L;
            Stream.WriteBuffer(P[4], L);
            Result := L;
            Stream.Position := 0;
          end;
        end;
      finally
        GlobalUnlock(H);
      end;
    end;
  finally
    CloseClipboard;
  end;
end;

{ TCallBackEventList }

constructor TCallBackEventList.Create;
begin
  inherited Create;
  FList := TList.Create;
end;

destructor TCallBackEventList.Destroy;
begin
  Clear;
  FList.Free;
  inherited Destroy;
end;

procedure TCallBackEventList.Clear;
begin
  while FList.Count <> 0 do Delete(FList.Count - 1);
end;

function TCallBackEventList.GetCount: Integer;
begin
  Result := FList.Count;
end;

function TCallBackEventList.GetItem(Index: Integer): PCallBackEvent;
begin
  Result := FList.List^[Index];
end;

procedure TCallBackEventList.Add(const Event: TCallBackEvent);
var
  P: PCallBackEvent;
begin
  New(P);
  P^ := Event;
  FList.Add(P);
end;

procedure TCallBackEventList.Delete(Index: Integer);
begin
  if Index < FList.Count then
  begin
    Dispose(PCallBackEvent(FList.List^[Index]));
    FList.Delete(Index);
  end;
end;

{$I inc\HashTab.PAS}

{ TEUser }

destructor TEUser.Destroy;
begin
  Disconnect;
  inherited Destroy;
end;

procedure TEUser.Connect(Node: TECustomNode);
begin
  Disconnect;
  FNode := Node;
  if Node <> nil then FNode.AddChild(Self);
end;

procedure TEUser.Disconnect;
begin
  if FNode <> nil then
  begin
    FNode.RemoveChild(Self);
    FNode := nil;
  end;
end;

{ TEObjectList }

function TEObjectList.GetEObject(Index: Integer): TEObject;
begin
  Result := TEObject(Items[Index]);
end;

procedure TEObjectList.SetEObject(Index: Integer; Value: TEObject);
begin
  Items[Index] := Value;
end;

function TEObjectList.FindObject(AClassID: Integer): TEObject;
var
  I: Integer;
  Found: Boolean;
begin
  I := 0;
  Found := False;
  while not Found and (I < Count) do
  begin
    Found := (List^[I] <> nil) and (AClassID = TEObject(List^[I]).ClassID);
    Inc(I);
  end;
  if Found then Result := TEObject(List^[I - 1]) else Result := nil;
end;

function TEObjectList.FindObjectIndex(AClassID: Integer): Integer;
var
  I: Integer;
  Found: Boolean;
begin
  I := 0;
  Found := False;
  while not Found and (I < Count) do
  begin
    Found := (List^[I] <> nil) and (AClassID = TEObject(List^[I]).ClassID);
    Inc(I);
  end;
  if Found then Result := I - 1 else Result := -1;
end;

procedure TEObjectList.ClearList;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    { the original tests List^[Count], one past the end, not List^[I] }
    if List^[Count] <> nil then TEObject(List^[I]).Destroy;
    Delete(I);
  end;
end;

function TEObjectList.AllHaveCID(AClassID: Integer): Boolean;
var
  I: Integer;
  OK: Boolean;
begin
  I := 0;
  OK := True;
  while I < Count do
  begin
    OK := (List^[I] = nil) or (AClassID = TEObject(List^[I]).ClassID);
    Inc(I);
  end;
  Result := OK and (Count <> 0);
end;

{ TEChangeNotifyNode }

constructor TEChangeNotifyNode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FChildren := TEObjectList.Create;
  FUpdateCount := 0;
end;

destructor TEChangeNotifyNode.Destroy;
begin
  BeginUpdate;
  inherited Destroy;
  FChildren.Free;
  FChildren := nil;
end;

procedure TEChangeNotifyNode.Clear;
var
  I: Integer;
  C: TEObject;
begin
  for I := Count - 1 downto 0 do
  begin
    C := TEObject(FChildren.List^[I]);
    if (C <> nil) and (C.Owner = Self) then
      if not (csShared in C.GetControlStyle) then C.Destroy else C.Clear;
  end;
  for I := Count - 1 downto 0 do
  begin
    C := TEObject(FChildren.List^[I]);
    if C <> nil then
      if not ((C.Owner = Self) and (csShared in C.GetControlStyle)) then RemoveChild(C);
  end;
  I := FChildren.Count - 1;
  while (I >= 0) and (FChildren.List^[I] = nil) do
  begin
    FChildren.Delete(I);
    Dec(I);
  end;
  if FUpdateCount = 0 then Changed;
end;

class function TEChangeNotifyNode.ClassID: Integer;
begin
  Result := $109;
end;

function TEChangeNotifyNode.GetChild(Index: Integer): TEObject;
begin
  Result := TEObject(FChildren.List^[Index]);
end;

procedure TEChangeNotifyNode.SetChild(Index: Integer; Child: TEObject);
begin
  while Index >= Count do FChildren.Add(nil);
  FChildren.Items[Index] := Child;
  if FUpdateCount = 0 then Changed;
end;

procedure TEChangeNotifyNode.Assign(Source: TEObject; AEngine: TEngine);
begin
  BeginUpdate;
  inherited Assign(Source, AEngine);
  EndUpdate;
end;

procedure TEChangeNotifyNode.LockChanged;
begin
  Inc(FUpdateCount);
end;

procedure TEChangeNotifyNode.UnlockChanged;
begin
  Dec(FUpdateCount);
end;

procedure TEChangeNotifyNode.Changed;
begin
end;

procedure TEChangeNotifyNode.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TEChangeNotifyNode.EndUpdate;
begin
  Assert(FUpdateCount > 0, 'Invalid UpdateCount Usage');
  Dec(FUpdateCount);
  if FUpdateCount = 0 then Changed;
end;

procedure TEChangeNotifyNode.Sort(Compare: TListSortCompare);
begin
  BeginUpdate;
  FChildren.Sort(Compare);
  EndUpdate;
end;

procedure TEChangeNotifyNode.MainReadWrite(Stream: TEStorageStream);
begin
  if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then BeginUpdate;
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then EndUpdate;
end;

function TEChangeNotifyNode.GetCount: Integer;
begin
  Result := FChildren.Count;
end;

procedure TEChangeNotifyNode.SendMsg(var Msg: TEMsg; Sender: TEObject);
var
  I: Integer;
begin
  with FChildren do
    if csKeepIndex in GetControlStyle then
      if Msg.MsgID and $10000000 <> 0 then
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(List^[I]) do
              begin
                if GetLastMsg <> Msg.Seq then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
              end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(Items[I]) do
              begin
                if (GetLastMsg <> Msg.Seq) and (Owner = Self) then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
              end;
        end
      else
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(List^[I]) do
              begin
                MsgProc(Msg, Self);
              end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            if List^[I] <> nil then
              with TEObject(Items[I]) do
              begin
                if Owner = Self then MsgProc(Msg, Self);
              end;
        end
    else
      if Msg.MsgID and $10000000 <> 0 then
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            with TEObject(List^[I]) do
            begin
                if GetLastMsg <> Msg.Seq then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
            end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            with TEObject(Items[I]) do
            begin
                if (GetLastMsg <> Msg.Seq) and (Owner = Self) then
                begin
                  SetLastMsg(Msg.Seq);
                  MsgProc(Msg, Self);
                end;
            end;
        end
      else
        if Msg.MsgID and $20000000 = 0 then
        begin
          for I := Count - 1 downto 0 do
            with TEObject(List^[I]) do
            begin
                MsgProc(Msg, Self);
            end;
        end
        else
        begin
          for I := Count - 1 downto 0 do
            with TEObject(Items[I]) do
            begin
                if Owner = Self then MsgProc(Msg, Self);
            end;
        end;
end;

function TEChangeNotifyNode.RemoveChild(Child: TEObject): Integer;
begin
  if csKeepIndex in GetControlStyle then
  begin
    Result := FChildren.IndexOf(Child);
    if Result <> -1 then FChildren.List^[Result] := nil;
  end
  else
    Result := FChildren.Remove(Child);
  if FUpdateCount = 0 then Changed;
end;

function TEChangeNotifyNode.AddChild(Child: TEObject): Integer;
begin
  FChildren.Add(Child);
  if FUpdateCount = 0 then Changed;
  Result := FChildren.Count - 1;
end;

function TEChangeNotifyNode.FindChild(AClassID: Integer): TEObject;
var
  I: Integer;
  Found: Boolean;
  C: TEObject;
begin
  I := 0;
  Found := False;
  C := nil;
  while not Found and (I < FChildren.Count) do
  begin
    C := TEObject(FChildren.List^[I]);
    Found := (C <> nil) and (AClassID = C.ClassID);
    Inc(I);
  end;
  if Found then Result := C else Result := nil;
end;

function TEChangeNotifyNode.FindChildIndex(Child: TEObject): Integer;
begin
  Result := Count - 1;
  while (Result >= 0) and (Child <> FChildren.List^[Result]) do Dec(Result);
end;

{ TEChangeNotifyEventList }

constructor TEChangeNotifyEventList.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FEvents := TEventList.Create;
end;

destructor TEChangeNotifyEventList.Destroy;
begin
  FEvents.Free;
  inherited Destroy;
end;

procedure TEChangeNotifyEventList.Changed;
begin
  FEvents.TriggerNotifyEvents(Self);
end;

{ TEReferenceNode }

procedure TEReferenceNode.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do TEObject(FChildren.List^[I]).Release;
  FChildren.Clear;
end;

procedure TEReferenceNode.DestroyAllChildren;
begin
  Clear;
end;

procedure TEReferenceNode.ReadWriteChildren(Stream: TEStorageStream);
var
  I: Integer;
begin
  if smWrite in Stream.StorageMode then
  begin
    for I := 0 to FChildren.Count - 1 do
      if TEObject(FChildren.List^[I]).FOwner = nil then TEObject(FChildren.List^[I]).FOwner := Self;
    inherited ReadWriteChildren(Stream);
    for I := 0 to FChildren.Count - 1 do
      if TEObject(FChildren.List^[I]).FOwner = Self then TEObject(FChildren.List^[I]).FOwner := nil;
  end
  else
  begin
    inherited ReadWriteChildren(Stream);
    if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then
      for I := 0 to FChildren.Count - 1 do TEObject(FChildren.List^[I]).Release;
  end;
end;

function TEReferenceNode.RemoveChild(Child: TEObject): Integer;
begin
  Result := FChildren.Remove(Child);
  if Result <> -1 then Child.Release;
end;

function TEReferenceNode.AddChild(Child: TEObject): Integer;
begin
  if Child.FOwner = Self then Child.FOwner := nil;
  FChildren.Add(Child);
  if Child.AddRef = -1 then raise Exception.Create('EObject doesn''t support ReferenceCounting');
  Result := FChildren.Count - 1;
end;

{ TEControlStyleNode }

constructor TEControlStyleNode.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

class function TEControlStyleNode.ClassID: Integer;
begin
  Result := $101;
end;

function TEControlStyleNode.GetControlStyle: TEControlStyles;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleNode.SetControlStyle(Value: TEControlStyles);
begin
  FControlStyle := Value;
end;

procedure TEControlStyleNode.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FControlStyle, 1, 2);
end;

{ TEControlStyleObject }

constructor TEControlStyleObject.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

class function TEControlStyleObject.ClassID: Integer;
begin
  Result := $51;
end;

function TEControlStyleObject.GetControlStyle: TEControlStyles;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleObject.SetControlStyle(Value: TEControlStyles);
begin
  FControlStyle := Value;
end;

procedure TEControlStyleObject.ReadWrite(Stream: TEStorageStream);
begin
  Stream.rwData(FControlStyle, 1, 1);
end;

{ TECustomOwner }

constructor TECustomOwner.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FOwner := AOwner;
  FControlStyle := inherited GetControlStyle;
end;

class function TECustomOwner.ClassID: Integer;
begin
  Result := $103;
end;

function TECustomOwner.GetEngine: TEngine;
begin
  Result := FEngine;
end;

procedure TECustomOwner.SetEngine(AEngine: TEngine);
begin
  FEngine := AEngine;
end;

function TECustomOwner.GetControlStyle: TEControlStyles;
begin
  Result := FControlStyle;
end;

procedure TECustomOwner.SetControlStyle(Value: TEControlStyles);
begin
  FControlStyle := Value;
end;

procedure TECustomOwner.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FControlStyle, 1, 2);
end;

procedure TECustomOwner.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20000008 then FEngine := Msg.Engine;
  inherited MsgProc(Msg, Sender);
end;

{ TEObjectClassList }

function TEObjectClassList.GetEClass(Index: Integer): TEObjectClass;
begin
  Result := TEObjectClass(Items[Index]);
end;

function TEObjectClassList.FindClass(AClassID: Integer): TEObjectClass;
var
  I: Integer;
  Found: Boolean;
begin
  I := 0;
  Found := False;
  while not Found and (I < Count) do
  begin
    Found := AClassID = TEObjectClass(Items[I]).ClassID;
    Inc(I);
  end;
  if Found then Result := TEObjectClass(Items[I - 1]) else Result := nil;
end;

function TEObjectClassList.FindClassIndex(AClassID: Integer): Integer;
var
  I: Integer;
  Found: Boolean;
begin
  I := 0;
  Found := False;
  while not Found and (I < Count) do
  begin
    Found := AClassID = TEObjectClass(Items[I]).ClassID;
    Inc(I);
  end;
  if Found then Result := I - 1 else Result := -1;
end;

function TEObjectClassList.GetClass(AClassID: Integer): TEObjectClass;
begin
  Result := FindClass(AClassID);
  if Result = nil then
    raise Exception.Create('Unregistered E-ClassID found (' + IntToStr(AClassID) + ')');
end;

procedure TEObjectClassList.RegisterClass(AClass: TEObjectClass);
begin
  if (FindClass(AClass.ClassID) = nil) and (AClass.ClassID <> 0) then
    Add(AClass)
  else
    raise Exception.Create('EObject Class ID double defined!');
end;

procedure TEObjectClassList.UnregisterClass(AClass: TEObjectClass);
var
  I: Integer;
begin
  I := FindClassIndex(AClass.ClassID);
  if I <> -1 then Delete(I);
end;

{ TEObjectEditorList }

function TEObjectEditorList.FindEditor(AClassID: Integer): TEObjectEditorClass;
var
  I: Integer;
begin
  I := 0;
  while (I <> Count) and (AClassID <> TEObjectEditorClass(List^[I]).EditorClassID) do Inc(I);
  if I <> Count then
    Result := TEObjectEditorClass(List^[I])
  else
    Result := nil;
end;

{ TECopyComponent }

type
  { the layout of TList, to write its count field straight from the object }
  TListFields = class(TObject)
    FList: Pointer;
    FCount: Integer;
  end;

function TECopyComponent.GetEObject(Index: Integer): TEObject;
begin
  Result := TEObject(FEObjects[Index]);
end;

procedure TECopyComponent.SetEObject(Index: Integer; Value: TEObject);
begin
  while Index >= FEObjects.Count do FEObjects.Add(nil);
  FEObjects.EObjects[Index] := Value;
end;

function TECopyComponent.GetCount: Integer;
begin
  Result := FEObjects.Count;
end;

procedure TECopyComponent.ReadState(Reader: TReader);
var
  Size, Count, I: Integer;
  S: TEReadStorageStream;
  M: TMemoryStream;
  O: TEObject;
begin
  inherited ReadState(Reader);
  M := TMemoryStream.Create;
  try
    Reader.Read(Size, SizeOf(Integer));
    M.Size := Size;
    Reader.Read(M.Memory^, Size);
    FEObjects.Clear;
    StringFromStream(FName, M);
    M.Read(Count, SizeOf(Integer));
    S := TEReadStorageStream.Create(M, CopyEngine, False);
    try
      for I := 0 to Count - 1 do
      begin
        S.rwCreateEObject(O, nil, I);
        FEObjects.Add(O);
      end;
    finally
      S.Free;
    end;
  finally
    M.Destroy;
  end;
end;

procedure TECopyComponent.WriteState(Writer: TWriter);
var
  S: TEWriteStorageStream;
  Size: Integer;
  M: TMemoryStream;
  O: TEObject;
  I: Integer;
begin
  inherited WriteState(Writer);
  M := TMemoryStream.Create;
  StringToStream(FName, M);
  M.Write(TListFields(FEObjects).FCount, SizeOf(Integer));
  S := TEWriteStorageStream.Create(M, CopyEngine, False);
  try
    for I := 0 to FEObjects.Count - 1 do
    begin
      O := FEObjects.EObjects[I];
      S.rwCreateEObject(O, nil, I);
    end;
  finally
    S.Free;
  end;
  Size := M.Size;
  Writer.Write(Size, SizeOf(Integer));
  Writer.Write(M.Memory^, Size);
  M.Destroy;
end;

constructor TECopyComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FName := '';
  FEObjects := TEObjectList.Create;
end;

destructor TECopyComponent.Destroy;
begin
  FEObjects.Free;
  inherited Destroy;
end;

procedure TECopyComponent.CopyToClipboard(AEngine: TEngine; Name: string);
begin
  CopyEngine := AEngine;
  FName := Name;
  Clipboard.SetComponent(Self);
end;

procedure TECopyComponent.PasteFromClipboard(AEngine: TEngine; Name: string);
var
  C: TComponent;
  I: Integer;
  Source: TECopyComponent;
begin
  FEObjects.ClearList;
  CopyEngine := AEngine;
  C := Clipboard.GetComponent(Self, nil);
  if (C <> nil) and (C is TECopyComponent) and (TECopyComponent(C).FName = Name) then
  begin
    Source := TECopyComponent(C);
    for I := 0 to Source.Count - 1 do
    begin
      EObjects[I] := Source.EObjects[I];
      Source.EObjects[I] := nil;
    end;
  end;
  C.Free;
end;

{ TEResource }

class function TEResource.ClassID: Integer;
begin
  Result := $400;
end;

class function TEResource.ResourceEditName: string;
begin
  Result := ClassName;
end;

procedure TEResource.SetOwner(AOwner: TECustomNode);
begin
  inherited SetOwner(AOwner);
  FResourceList := AOwner;
end;

procedure TEResource.SetArrayOwner(AOwner: TECustomNode; Index: Integer);
begin
  inherited SetArrayOwner(AOwner, Index);
  FResourceList := AOwner;
end;

procedure TEResource.Draw(Dest: TObject; Rect: TRect; Mode: Byte; A, B, C, D: Integer);
var
  R: TRect;
begin
  BltLibraryImage(Dest, GetCellImage, Rect, Mode, A, B, C, D, False, R);
end;

function TEResource.GetCellImage: Pointer;
begin
  Result := nil;
end;

procedure TEResource.SetCellImage(Value: Pointer);
begin
end;

procedure TEResource.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FResourceID, 1);
  Stream.rwInteger(FValue2, 2);
  Stream.rwInteger(FValue3, 3);
end;

function TEResource.ResourceUserClassID: Integer;
begin
  Result := 0;
end;

function TEResource.CreateResourceUser: TEObject;
var
  UserClassID: Integer;
begin
  UserClassID := ResourceUserClassID;
  if UserClassID <> 0 then
    Result := GetEngine.CreateEObject(UserClassID, nil)
  else
    Result := nil;
end;

{ TEResourceList }

class function TEResourceList.ClassID: Integer;
begin
  Result := $401;
end;

function TEResourceList.GetResource(Index: Integer): TEResource;
begin
  Result := TEResource(FChildren.List^[Index]);
end;

procedure TEResourceList.ResourceChanged;
begin
end;

function TEResourceList.FindResource(ID: Integer): TEResource;
var
  I: Integer;
  Found: Boolean;
begin
  with FChildren do
  begin
    Found := False;
    I := 0;
    while not Found and (I <> Count) do
    begin
      Found := (List^[I] <> nil) and (ID = TEResource(List^[I]).FResourceID);
      Inc(I);
    end;
    if Found then Result := TEResource(List^[I - 1]) else Result := nil;
  end;
end;

procedure TEResourceList.ValidateResourceID(Index: Integer);
var
  ID, NewID, Tries: Integer;
  Found: Boolean;
begin
  if Index < FChildren.Count then
  begin
    ID := GetResource(Index).FResourceID;
    with GetResource(Index) do FResourceID := FResourceID xor $FFFF;
    if FindResource(ID) <> nil then
    begin
      Tries := 10;
      Found := False;
      NewID := 0;
      while (Tries > 0) and not Found do
      begin
        NewID := Random($FFFFFFF);
        Found := FindResource(NewID) = nil;
        Dec(Tries);
      end;
      while not Found do
      begin
        NewID := Tries;
        Found := FindResource(NewID) = nil;
        Inc(Tries);
      end;
      GetResource(Index).FResourceID := NewID;
    end
    else
      GetResource(Index).FResourceID := ID;
  end;
end;

{ TEComponent }

destructor TEComponent.Destroy;
begin
  if Assigned(FOnDestroy) then FOnDestroy(Self);
  FObject.Free;
  inherited Destroy;
end;

procedure TEComponent.Loaded;
begin
  inherited Loaded;
  if Assigned(FOnLoaded) then FOnLoaded(Self);
end;

{ TEResourceEditSettings }

constructor TEResourceEditSettings.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FEditors := TStringList.Create;
end;

destructor TEResourceEditSettings.Destroy;
begin
  FEditors.Free;
  inherited Destroy;
end;

class function TEResourceEditSettings.ClassID: Integer;
begin
  Result := $402;
end;

function TEResourceEditSettings.GetUniqueEditorName(Name: string): string;
var
  S: string;
begin
  S := Name;
  while FEditors.IndexOf(S) <> -1 do
    S := Name + IntToStr(Random($FFFFFFF));
  Result := S;
end;

function TEResourceEditSettings.GetUniqueEditID: Integer;
var
  I: Integer;
  Found: Boolean;
begin
  Result := 1;
  I := 0;
  Found := FEditors.Count = 0;
  while not Found do
  begin
    if Result <> Integer(FEditors.Objects[I]) then
    begin
      Inc(I);
      Found := I = FEditors.Count;
    end
    else
    begin
      I := 0;
      Inc(Result);
    end;
  end;
end;

function TEResourceEditSettings.GetEditID(Name: string): Integer;
var
  I: Integer;
begin
  I := FEditors.IndexOf(Name);
  if I <> -1 then
    Result := Integer(FEditors.Objects[I])
  else
  begin
    Result := GetUniqueEditID;
    FEditors.AddObject(Name, TObject(Result));
  end;
end;

function TEResourceEditSettings.RemoveEditor(Name: string): Integer;
begin
  Result := FEditors.IndexOf(Name);
  if Result <> -1 then FEditors.Delete(Result);
end;

procedure TEResourceEditSettings.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smText in Stream.StorageMode) then Stream.rwStringsEx(FEditors, 3);
end;

{ TEngine }

constructor TEngine.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  UpdateStartupDirectory;
  FOptions := [eoVerifyClasses];
  FDebugEvents := TEventList.Create;
  FEClasses := TEObjectClassList.Create;
  FClassTable := TIntegerHashTable256.Create;
  FEditors := TEObjectEditorList.Create;
  FControlNode := TEControlStyleNode.Create(Self);
  FControlNode.SetControlStyle([csShared]);
  FDebugIDs := TStringList.Create;
  FDebugIDs.AddObject(UserStr, TObject(-1));
  RegisterEClasses([TEControlStyleObject, TEControlStyleNode, TECustomOwner, TEResourceEditSettings]);
  Engines.Add(Self);
end;

destructor TEngine.Destroy;
begin
  FEditors.Free;
  Engines.Remove(Self);
  FDebugEvents.Free;
  FDebugIDs.Free;
  inherited Destroy;
  FClassTable.Free;
  FEClasses.Free;
end;

class function TEngine.ClassID: Integer;
begin
  Result := $11;
end;

function TEngine.TranslateText(const Text: string): string;
begin
  Result := Text;
end;

procedure TEngine.UpdateStartupDirectory;
begin
  FStartupDirectory := ExtractFilePath(Application.ExeName);
end;

procedure TEngine.SetStartupDirectory(Value: string);
begin
  FStartupDirectory := Value;
end;

function TEngine.CreateUniqueDebugID: Integer;
begin
  Result := 0;
  while FDebugIDs.IndexOfObject(TObject(Result)) <> -1 do Inc(Result);
end;

function TEngine.RegisterDebugID(const Name: string): Integer;
begin
  Result := CreateUniqueDebugID;
  FDebugIDs.AddObject(Name, TObject(Result));
end;

procedure TEngine.UnregisterDebugID(ID: Integer);
var
  I: Integer;
begin
  I := FDebugIDs.IndexOfObject(TObject(ID));
  if I <> -1 then FDebugIDs.Delete(I);
end;

procedure TEngine.OutputDebugStr(const S: string);
var
  Info: TEngineDebugInfo;
begin
  Info.ID := -1;
  Info.Text := S;
  FDebugEvents.TriggerNotifyEvents(TObject(@Info));
end;

procedure TEngine.OutputDebugMessage(ID: Integer; const S: string);
var
  Info: TEngineDebugInfo;
begin
  Info.ID := ID;
  Info.Text := S;
  FDebugEvents.TriggerNotifyEvents(TObject(@Info));
end;

function TEngine.GetEngine: TEngine;
begin
  Result := Self;
end;

procedure TEngine.ResetMsgCount;
var
  Msg: TEMsg;
begin
  InitMsgEx(Msg, 1, Self, FMsgCount + 1);
  MsgProc(Msg, Self);
  FMsgCount := 0;
end;

function TEngine.IncMsgCount: Integer;
begin
  Inc(FMsgCount);
  if FMsgCount > $FFFFFFF then ResetMsgCount;
  Result := FMsgCount;
end;

procedure TEngine.RegisterEClasses(AClasses: array of TEObjectClass);
var
  I: Integer;
begin
  for I := 0 to High(AClasses) do
  begin
    if eoVerifyClasses in FOptions then VerifyEObjectClass(AClasses[I]);
    if FClassTable.Find(AClasses[I].ClassID) <> nil then
      raise Exception.Create('EObject Class ID double defined!');
    FEClasses.Add(AClasses[I]);
    FClassTable.Add(AClasses[I], AClasses[I].ClassID);
  end;
end;

procedure TEngine.UnregisterEClasses(AClasses: array of TEObjectClass);
var
  I: Integer;
begin
  for I := 0 to High(AClasses) do
  begin
    FEClasses.Remove(AClasses[I]);
    FClassTable.Delete(AClasses[I].ClassID);
  end;
end;

function TEngine.GetEClass(AClassID: Integer): TEObjectClass;
begin
  Result := TEObjectClass(FClassTable.Find(AClassID));
  if Result = nil then
    raise Exception.Create('Unregistered E-ClassID found (' + IntToStr(AClassID) + ')');
end;

function TEngine.GetDescendantClasses(AClass: TClass): TEObjectClassList;
var
  I: Integer;
  L: TEObjectClassList;
begin
  L := TEObjectClassList.Create;
  for I := 0 to FEClasses.Count - 1 do
    if TEObjectClass(FEClasses[I]).InheritsFrom(AClass) then L.Add(FEClasses[I]);
  Result := L;
end;

procedure TEngine.ActivateEObject(Obj: TEObject);
var
  Msg: TEMsg;
begin
  InitMsg(Msg, $20000008, Self);
  Msg.Engine := Self;
  Obj.MsgProc(Msg, Self);
end;

function TEngine.CreateEObject(AClassID: Integer; AOwner: TECustomNode): TEObject;
var
  C: TEObjectClass;
begin
  C := GetEClass(AClassID);
  Result := C.Create(AOwner);
end;

procedure TEngine.WriteEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  S: TEStorageStream;
begin
  S := TEWriteStorageStream.Create(Stream, Self, False);
  S.OnProgress := AProgress;
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;
  end;
end;

procedure TEngine.ReadEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  S: TEStorageStream;
begin
  S := TEReadStorageStream.Create(Stream, Self, False);
  S.OnProgress := AProgress;
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;
  end;
end;

procedure TEngine.WritePreviewEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  S: TEStorageStream;
begin
  S := TEWriteStorageStream.Create(Stream, Self, True);
  S.OnProgress := AProgress;
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;
  end;
end;

procedure TEngine.ReadPreviewEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  S: TEStorageStream;
begin
  S := TEReadStorageStream.Create(Stream, Self, True);
  S.OnProgress := AProgress;
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;
  end;
end;

procedure TEngine.StoreEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  S: TEStorageStream;
begin
  S := TEWriteStorageStream.Create(Stream, Self, False);
  S.OnProgress := AProgress;
  try
    S.rwCreateEObject(Obj, nil, 0);
  finally
    S.Free;
  end;
end;

function TEngine.RetrieveEObject(Stream: TStream; AProgress: TStorageProgressEvent): TEObject;
var
  S: TEStorageStream;
begin
  S := TEReadStorageStream.Create(Stream, Self, False);
  S.OnProgress := AProgress;
  try
    S.rwCreateEObject(Result, nil, 0);
  finally
    S.Free;
  end;
end;

function TEngine.RetrieveFromFile(const FileName: string; AProgress: TStorageProgressEvent): TEObject;
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    Result := RetrieveEObject(F, AProgress);
  finally
    F.Free;
  end;
end;

procedure TEngine.StoreInFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    StoreEObject(F, Obj, AProgress);
  finally
    F.Free;
  end;
end;

procedure TEngine.WriteToFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  M: TMemoryStream;
  F: TFileStream;
begin
  M := TMemoryStream.Create;
  try
    WriteEObject(M, Obj, AProgress);
    F := TFileStream.Create(FileName, fmCreate);
    try
      M.Position := 0;
      F.CopyFrom(M, M.Size);
    finally
      F.Free;
    end;
  finally
    M.Free;
  end;
end;

procedure TEngine.ReadFromFile(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  M: TMemoryStream;
  F: TFileStream;
begin
  M := TMemoryStream.Create;
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    M.LoadFromStream(F);
  finally
    F.Free;
  end;
  M.Position := 0;
  try
    ReadEObject(M, Obj, AProgress);
  finally
    M.Free;
  end;
end;

procedure TEngine.WriteToFileCRC(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent);
var
  CRC1, CRC2: Integer;
  M: TMemoryStream;
  F: TFileStream;
begin
  M := TMemoryStream.Create;
  try
    WriteEObject(M, Obj, AProgress);
    CRC1 := GetCRC32(M.Memory, M.Size);
    M.Write(CRC1, SizeOf(Integer));
    CRC2 := GetCRC32(M.Memory, M.Size);
    F := TFileStream.Create(FileName, fmCreate);
    try
      F.Write(CRC2, SizeOf(Integer));
      F.Write(M.Memory^, M.Size);
    finally
      F.Free;
    end;
  finally
    M.Free;
  end;
end;

function TEngine.ReadFromFileCRC(const FileName: string; Obj: TEObject; AProgress: TStorageProgressEvent): Boolean;
var
  M: TMemoryStream;
  F: TFileStream;
  CRC2, CRC1: Integer;
begin
  Result := False;
  M := TMemoryStream.Create;
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    M.LoadFromStream(F);
    M.Position := 0;
    if M.Size > 8 then
    begin
      CRC1 := PInteger(M.Memory)^;
      CRC2 := PInteger(Integer(M.Memory) + M.Size - 4)^;
      if (CRC1 = GetCRC32(Pointer(Integer(M.Memory) + 4), M.Size - 4)) and
        (CRC2 = GetCRC32(Pointer(Integer(M.Memory) + 4), M.Size - 8)) then
      begin
        M.Position := 4;
        ReadEObject(M, Obj, AProgress);
        Result := True;
      end;
    end;
  finally
    F.Free;
    M.Free;
  end;
end;

procedure TEngine.ReadTextFromFile(const FileName: string; Obj: TEObject);
var
  S: TEStorageStream;
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    S := TEReadTextStorageStream.Create(F, Self, 0);
    try
      S.rwEObject(Obj, 0);
    finally
      S.Free;
    end;
  finally
    F.Free;
  end;
end;

procedure TEngine.WriteTextToFile(const FileName: string; Obj: TEObject);
var
  S: TEStorageStream;
  F: TFileStream;
begin
  F := TFileStream.Create(FileName, fmCreate);
  try
    S := TEWriteTextStorageStream.Create(F, Self);
    try
      S.rwEObject(Obj, 0);
    finally
      S.Free;
    end;
  finally
    F.Free;
  end;
end;

function TEngine.VerifyEObjectClass(AClass: TEObjectClass): Boolean;
var
  Allocated: Integer;
begin
  Result := True;
  Allocated := GetHeapStatus.TotalAllocated;
  AClass.Create(nil).Free;
  try
    if Allocated <> GetHeapStatus.TotalAllocated then
      raise Exception.Create(AClass.ClassName + ' contains memory leak constructor/destructor(' +
        IntToStr(GetHeapStatus.TotalAllocated - Allocated) + ' bytes)');
  except
  end;
end;

{ TPlugIn }

constructor TPlugIn.Create;
begin
  inherited Create;
  FEngines := TList.Create;
  FCounts := TIntegerList.Create;
  RegisterPlugIn(Self);
  FRefCount := 1;
end;

destructor TPlugIn.Destroy;
begin
  while FEngines.Count <> 0 do Finalize(TEngine(FEngines[FEngines.Count - 1]));
  FEngines.Free;
  FCounts.Free;
  UnregisterPlugIn(Self);
  inherited Destroy;
end;

procedure TPlugIn.AddRef;
begin
  Inc(FRefCount);
end;

procedure TPlugIn.Release;
begin
  Dec(FRefCount);
  if FRefCount = 0 then Destroy;
end;

function TPlugIn.Name: string;
begin
  Result := 'Abstract PlugIn';
end;

function TPlugIn.Initialize(AEngine: TEngine): Boolean;
var
  I: Integer;
begin
  AddRef;
  I := FEngines.IndexOf(AEngine);
  if I = -1 then
  begin
    FEngines.Add(AEngine);
    FCounts.Add(1);
    Result := True;
  end
  else
  begin
    FCounts[I] := FCounts[I] + 1;
    Result := False;
  end;
end;

function TPlugIn.Finalize(AEngine: TEngine): Boolean;
var
  I: Integer;
begin
  I := FEngines.IndexOf(AEngine);
  if I <> -1 then
  begin
    if FCounts[I] = 0 then raise Exception.Create('Invalid PlugIn Finalize Usage');
    if FCounts[I] = 1 then
    begin
      FEngines.Remove(AEngine);
      FCounts.Delete(I);
      Result := True;
    end
    else
    begin
      FCounts[I] := FCounts[I] - 1;
      Result := False;
    end;
  end
  else
    Result := False;
  Release;
end;

{ Plug-in registry }

procedure RegisterPlugIn(PlugIn: TPlugIn);
var
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  I := 0;
  while not Found and (I <> PlugIns.Count) do
  begin
    Found := TPlugIn(PlugIns[I]).Name = PlugIn.Name;
    Inc(I);
  end;
  if not Found then
    PlugIns.Add(PlugIn)
  else
    raise Exception.Create('PlugIn ' + PlugIn.Name + ' already registered');
end;

procedure UnregisterPlugIn(PlugIn: TPlugIn);
begin
  if PlugIns.IndexOf(PlugIn) <> -1 then
    PlugIns.Remove(PlugIn)
  else
    raise Exception.Create('PlugIn not found');
end;

{ TPlugInControl }

constructor TPlugInControl.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FUsedPlugIns := TStringList.Create;
  FUsedPlugIns.Sorted := True;
  FUsedPlugIns.OnChange := OnChange;
  FUsedPlugIns.OnChanging := OnChanging;
  FEngine := nil;
end;

destructor TPlugInControl.Destroy;
begin
  FUsedPlugIns.Clear;
  FUsedPlugIns.Free;
  inherited Destroy;
end;

function TPlugInControl.GetEngine: TEngine;
begin
  Result := FEngine;
end;

function TPlugInControl.GetControlStyle: TEControlStyles;
begin
  Result := [csStored, csShared];
end;

procedure TPlugInControl.SetUsedPlugIns(Value: TStrings);
begin
  FUsedPlugIns.Assign(Value);
end;

function TPlugInControl.GetUsedPlugIns: TStrings;
begin
  Result := FUsedPlugIns;
end;

procedure TPlugInControl.OnChange(Sender: TObject);
begin
  InitializePlugIns;
end;

procedure TPlugInControl.OnChanging(Sender: TObject);
begin
  FinalizePlugIns;
end;

procedure TPlugInControl.InitializePlugIns;
var
  I: Integer;
  S: string;
  P: TPlugIn;
begin
  for I := 0 to FUsedPlugIns.Count - 1 do
  begin
    S := FUsedPlugIns[I];
    P := FindPlugIn(S);
    if P <> nil then
      P.Initialize(FEngine)
    else
    begin
      S := 'PlugIn Missing (' + FUsedPlugIns[I] + ')';
      raise EPlugInMissing.Create(S);
    end;
  end;
end;

procedure TPlugInControl.FinalizePlugIns;
var
  I: Integer;
  P: TPlugIn;
begin
  for I := 0 to FUsedPlugIns.Count - 1 do
  begin
    P := FindPlugIn(FUsedPlugIns[I]);
    if P <> nil then P.Finalize(FEngine);
  end;
end;

procedure TPlugInControl.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTranslate in Stream.StorageMode) then Stream.rwStrings(FUsedPlugIns, 1);
end;

procedure InitializePlugIns(AEngine: TEngine);
var
  I: Integer;
begin
  for I := 0 to PlugIns.Count - 1 do TPlugIn(PlugIns[I]).Initialize(AEngine);
end;

procedure FinalizePlugIns(AEngine: TEngine);
var
  I: Integer;
begin
  for I := 0 to PlugIns.Count - 1 do TPlugIn(PlugIns[I]).Finalize(AEngine);
end;

function GetPlugIn(Index: Integer): TPlugIn;
begin
  if (PlugIns <> nil) and (Index >= 0) and (Index < PlugIns.Count) then
    Result := TPlugIn(PlugIns[Index])
  else
    Result := nil;
end;

function FindPlugIn(Name: string): TPlugIn;
var
  I: Integer;
begin
  Result := nil;
  if PlugIns <> nil then
  begin
    I := 0;
    while (I <> PlugIns.Count) and (Result = nil) do
    begin
      if TPlugIn(PlugIns[I]).Name = Name then Result := TPlugIn(PlugIns[I]);
      Inc(I);
    end;
  end;
end;

procedure LoadExternalPlugIns(const Directory: string);
var
  Dir: string;

  procedure LoadFrom(Dir: string);
  var
    SR: TSearchRec;
    Dirs: TStringList;
    I: Integer;
    Found: Boolean;
    H: HMODULE;
  begin
    Found := FindFirst(Dir + '*.DPL', faAnyFile - faDirectory, SR) = 0;
    while Found do
    begin
      try
        H := LoadPackage(Dir + SR.Name);
        Packages.AddObject(Dir + SR.Name, TObject(H));
      except
        raise Exception.Create('Unable to load PlugIn: ' + Dir + SR.Name);
      end;
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
    for I := 0 to Dirs.Count - 1 do LoadFrom(Dirs[I]);
    Dirs.Free;
  end;

begin
  Dir := ExpandFileName(Directory);
  { the original tests the character of Directory, not of Dir }
  if (Dir <> '') and (Directory[Length(Dir)] <> '\') then Dir := Dir + '\';
  LoadFrom(Dir);
end;

procedure UnloadExternalPlugIns;
var
  I: Integer;
  S: string;
begin
  for I := Packages.Count - 1 downto 0 do
  begin
    try
      S := Packages[I];
      { the original hands the name, not the handle in Objects, to UnloadPackage }
      UnloadPackage(HMODULE(S));
      Packages.Delete(I);
    except
      S := 'Could not release PlugIn: ' + Packages[I];
      raise Exception.Create(S);
    end;
  end;
  Packages.Clear;
end;

{ Messages and engines }

procedure InitMsg(var Msg: TEMsg; MsgID: Integer; Sender: TEObject);
begin
  FillChar(Msg, SizeOf(TEMsg), 0);
  Msg.MsgID := MsgID;
  Msg.Sender := Sender;
  Msg.Result := -1;
end;

procedure InitMsgEx(var Msg: TEMsg; MsgID: Integer; Sender: TEObject; Seq: Integer);
begin
  FillChar(Msg, SizeOf(TEMsg), 0);
  Msg.MsgID := MsgID;
  Msg.Seq := Seq;
  Msg.Sender := Sender;
  Msg.Result := -1;
end;

function GetEngine(Index: Integer): TEngine;
begin
  if (Engines <> nil) and (Index >= 0) and (Index < Engines.Count) then
    Result := TEngine(Engines[Index])
  else
    Result := nil;
end;

function FindEngine(AClassID: Integer): TEngine;
var
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  Result := nil;
  if Engines <> nil then
  begin
    I := 0;
    Found := False;
    while not Found and (I < Engines.Count) do
    begin
      Found := AClassID = TEngine(Engines[I]).ClassID;
      Inc(I);
    end;
    if Found then Result := TEngine(Engines[I - 1]);
  end;
  if not Found then raise Exception.Create('Cannot access Engine');
end;

{ TEStorageStream }

constructor TEStorageStream.Create(AStream: TStream; AEngine: TEngine);
begin
  inherited Create;
  FEngine := AEngine;
  FStream := AStream;
  FErrorHandled := False;
end;

procedure TEStorageStream.ShowProgress(Sender: TObject; const Msg: string; Percent: Integer);
begin
  if Assigned(FOnProgress) then FOnProgress(Sender, Msg, Percent);
end;

function TEStorageStream.OpenPropertyStream(ID: Integer): TStream;
begin
  Result := nil;
end;

procedure TEStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);
begin
end;

procedure TEStorageStream.rwString(var S: string; ID: Integer);
begin
end;

procedure TEStorageStream.rwStrings(Strings: TStrings; ID: Integer);
begin
end;

procedure TEStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
end;

procedure TEStorageStream.rwInteger(var I: Integer; ID: Integer);
begin
end;

procedure TEStorageStream.rwByte(var B: Byte; ID: Integer);
begin
end;

procedure TEStorageStream.rwShortint(var S: Shortint; ID: Integer);
begin
end;

procedure TEStorageStream.rwWord(var W: Word; ID: Integer);
begin
end;

procedure TEStorageStream.rwBool(var B: Boolean; ID: Integer);
begin
end;

procedure TEStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
begin
end;

procedure TEStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
begin
end;

procedure TEStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
begin
end;

procedure TEStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
begin
end;

procedure TEStorageStream.rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc);
begin
end;

{ TEWriteStorageStream }

constructor TEWriteStorageStream.Create(AStream: TStream; AEngine: TEngine; APartial: Boolean);
begin
  inherited Create(AStream, AEngine);
  FEngine := AEngine;
  FStream := AStream;
  FBuffer := TEBufferStream.Create;
  FPropertyTable := TPropertyTable.Create;
  FPartial := APartial;
end;

destructor TEWriteStorageStream.Destroy;
begin
  FPropertyTable.SaveToStream(FStream);
  FBuffer.SaveToStream(FStream);
  FPropertyTable.Free;
  FBuffer.Free;
  inherited Destroy;
end;

function TEWriteStorageStream.StorageMode: TStorageModes;
begin
  if FPartial then
    Result := [smWrite, smPartial]
  else
    Result := [smWrite];
end;

procedure TEWriteStorageStream.PropertyExistError(ID: Integer);
begin
  raise EDoublePrioriyID.Create('PropertyID already in use (' + IntToStr(ID) + ' / ' + ClassName + ')');
end;

procedure TEWriteStorageStream.rwByte(var B: Byte; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if B <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(B, SizeOf(Byte));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwWord(var W: Word; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if W <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(W, SizeOf(Word));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwShortint(var S: Shortint; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if S <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(S, SizeOf(Shortint));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwInteger(var I: Integer; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if I <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(I, SizeOf(Integer));
    end;
  end
  else
    raise EDoublePrioriyID.Create('PropertyID already in use');
end;

procedure TEWriteStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if B <> Default then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(B, SizeOf(Byte));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if W <> Default then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(W, SizeOf(Word));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if S <> Default then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(S, SizeOf(Shortint));
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if I <> Default then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(I, SizeOf(Integer));
    end;
  end
  else
    raise EDoublePrioriyID.Create('PropertyID already in use');
end;

procedure TEWriteStorageStream.rwString(var S: string; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if S <> '' then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      SaveStringToStream(S, FBuffer);
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwStrings(Strings: TStrings; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if Strings.Count <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      StringsToStream(Strings, FBuffer);
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if Strings.Count <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      StringsToStreamEx(Strings, FBuffer);
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if Size <> 0 then
    begin
      FPropertyTable.Add(ID, FBuffer.Position);
      FBuffer.Write(Buffer, Size);
    end;
  end
  else
    PropertyExistError(ID);
end;

procedure TEWriteStorageStream.rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    try
      SaveProc(FBuffer);
    except
    end;
  end
  else
    PropertyExistError(ID);
end;

function TEWriteStorageStream.OpenPropertyStream(ID: Integer): TStream;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    Result := FBuffer;
  end
  else
  begin
    PropertyExistError(ID);
    Result := nil;
  end;
end;

procedure TEWriteStorageStream.rwBool(var B: Boolean; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if B then FPropertyTable.Add(ID, FBuffer.Position);
  end
  else
    PropertyExistError(ID);
end;

function TEWriteStorageStream.HandleException(E: Exception): Boolean;
var
  Continue: Boolean;
begin
  if not FErrorHandled then
  begin
    Continue := True;
    if Assigned(FOnError) then
      if E.Message = '' then
        FOnError(Self, EStreamWriteErrorStr, Continue)
      else
        FOnError(Self, E.Message, Continue);
    if not Continue then FErrorHandled := True;
  end;
  Result := not FErrorHandled;
end;

procedure TEWriteStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  Outer: TEBufferStream;
  Start, AClassID: Integer;
  O: TEObject;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    Start := FBuffer.Position;
    O := Obj;
    if O <> nil then AClassID := O.ClassID else AClassID := 0;
    if AClassID <> 0 then
    begin
      Outer := FBuffer;
      FBuffer := TEBufferStream.Create;
      FPropertyTable.BackupSettings;
      try
        Obj.MainReadWrite(Self);
        Outer.Write(AClassID, SizeOf(Integer));
        FPropertyTable.SaveToStream(Outer);
        FBuffer.SaveToStream(Outer);
        FBuffer.Free;
        FPropertyTable.RestoreSettings;
        FBuffer := Outer;
        FPropertyTable.Add(ID, Start);
      except
        on E: Exception do
        begin
          FPropertyTable.RestoreSettings;
          FBuffer.Free;
          FBuffer := Outer;
          Outer.Position := Start;
          if not HandleException(E) then raise;
        end;
      end;
    end
    else
    begin
      FBuffer.Write(AClassID, SizeOf(Integer));
      FPropertyTable.Add(ID, Start);
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + IntToStr(ID) + ')');
end;

procedure TEWriteStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  Outer: TEBufferStream;
  Start: Integer;
  C: TEObject;
  I: Integer;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    Start := FBuffer.Position;
    Outer := FBuffer;
    FBuffer := TEBufferStream.Create;
    FPropertyTable.BackupSettings;
    for I := 0 to Node.Count - 1 do
    begin
      C := Node.Children[I];
      if (C <> nil) and (C.Owner = Node) and not (csShared in C.GetControlStyle) and
        (csStored in C.GetControlStyle) then
        rwCreateEObject(C, Node, I);
    end;
    FPropertyTable.SaveToStream(Outer);
    FBuffer.SaveToStream(Outer);
    FBuffer.Free;
    FPropertyTable.RestoreSettings;
    FBuffer := Outer;
    FPropertyTable.Add(ID, Start);
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + IntToStr(ID) + ')');
end;

procedure TEWriteStorageStream.rwEObject(Obj: TEObject; ID: Integer);
var
  Outer: TEBufferStream;
  Start: Integer;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    Start := FBuffer.Position;
    Outer := FBuffer;
    FBuffer := TEBufferStream.Create;
    FPropertyTable.BackupSettings;
    try
      Obj.MainReadWrite(Self);
      FPropertyTable.SaveToStream(Outer);
      FBuffer.SaveToStream(Outer);
      FPropertyTable.RestoreSettings;
      FBuffer.Free;
      FBuffer := Outer;
      FPropertyTable.Add(ID, Start);
    except
      on E: Exception do
      begin
        FPropertyTable.RestoreSettings;
        FBuffer.Free;
        FBuffer := Outer;
        Outer.Position := Start;
        if not HandleException(E) then raise;
      end;
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + Obj.ClassName + ':' + IntToStr(ID) + ')');
end;

procedure TEWriteStorageStream.rwEObjectStream(Obj: TEObject; ID: Integer);
var
  Outer: TEBufferStream;
  Start, Len: Integer;
begin
  Start := FBuffer.Position;
  Outer := FBuffer;
  FBuffer := TEBufferStream.Create;
  FPropertyTable.BackupSettings;
  try
    Obj.MainReadWrite(Self);
    Outer.Write(Len, SizeOf(Integer));
    FPropertyTable.SaveToStream(Outer);
    FBuffer.SaveToStream(Outer);
    Len := Outer.Position - Start - SizeOf(Integer);
    Outer.Position := Start;
    Outer.Write(Len, SizeOf(Integer));
    Outer.Position := Start + Len + SizeOf(Integer);
    FPropertyTable.RestoreSettings;
    FBuffer.Free;
    FBuffer := Outer;
  except
    on E: Exception do
    begin
      FBuffer.Free;
      FBuffer := Outer;
      FPropertyTable.RestoreSettings;
      Len := 0;
      Outer.Position := Start;
      Outer.Write(Len, SizeOf(Integer));
      if not HandleException(E) then raise;
    end;
  end;
end;

{ TEReadStorageStream }

constructor TEReadStorageStream.Create(AStream: TStream; AEngine: TEngine; APartial: Boolean);
begin
  inherited Create(AStream, AEngine);
  FPropertyTable := TPropertyTable.Create;
  FPropertyTable.LoadFromStream(AStream);
  FDataBase := FStream.Position;
  FPartial := APartial;
end;

destructor TEReadStorageStream.Destroy;
begin
  FPropertyTable.Free;
  inherited Destroy;
end;

function TEReadStorageStream.StorageMode: TStorageModes;
begin
  if FPartial then
    Result := [smRead, smPartial]
  else
    Result := [smRead];
end;

procedure TEReadStorageStream.rwInteger(var I: Integer; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(I, SizeOf(Integer));
  end
  else
    I := 0;
end;

procedure TEReadStorageStream.rwByte(var B: Byte; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(B, SizeOf(Byte));
  end
  else
    B := 0;
end;

procedure TEReadStorageStream.rwShortint(var S: Shortint; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(S, SizeOf(Shortint));
  end
  else
    S := 0;
end;

procedure TEReadStorageStream.rwWord(var W: Word; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(W, SizeOf(Word));
  end
  else
    W := 0;
end;

procedure TEReadStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(I, SizeOf(Integer));
  end
  else
    I := Default;
end;

procedure TEReadStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(B, SizeOf(Byte));
  end
  else
    B := Default;
end;

procedure TEReadStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(S, SizeOf(Shortint));
  end
  else
    S := Default;
end;

procedure TEReadStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(W, SizeOf(Word));
  end
  else
    W := Default;
end;

procedure TEReadStorageStream.rwString(var S: string; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    LoadStringFromStream(S, FStream);
  end
  else
    S := '';
end;

procedure TEReadStorageStream.rwStrings(Strings: TStrings; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    StringsFromStream(Strings, FStream);
  end
  else
    Strings.Clear;
end;

procedure TEReadStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    StringsFromStreamEx(Strings, FStream);
  end
  else
    Strings.Clear;
end;

procedure TEReadStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(Buffer, Size);
  end;
end;

procedure TEReadStorageStream.rwStreamProc(ID: Integer; Obj: TObject; LoadProc, SaveProc: TStreamProc);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    try
      LoadProc(FStream);
    except
    end;
  end;
end;

function TEReadStorageStream.OpenPropertyStream(ID: Integer): TStream;
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    Result := FStream;
  end
  else
    Result := nil;
end;

procedure TEReadStorageStream.rwBool(var B: Boolean; ID: Integer);
begin
  B := FPropertyTable.FindOffset(ID) <> -1;
end;

function TEReadStorageStream.HandleException(E: Exception): Boolean;
var
  Continue: Boolean;
begin
  if not FErrorHandled then
  begin
    Continue := True;
    if Assigned(FOnError) then
      if E.Message = '' then
        FOnError(Self, EStreamReadErrorStr, Continue)
      else
        FOnError(Self, E.Message, Continue);
    if not Continue then FErrorHandled := True;
  end;
  Result := not FErrorHandled;
end;

procedure TEReadStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  Offset, SavedBase, AClassID: Integer;
begin
  Obj := nil;
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(AClassID, SizeOf(Integer));
    if AClassID <> 0 then
    begin
      SavedBase := FDataBase;
      FPropertyTable.BackupSettings;
      FPropertyTable.LoadFromStream(FStream);
      FDataBase := FStream.Position;
      try
        Obj := FEngine.CreateEObject(AClassID, nil);
        Obj.FOwner := AOwner;
        Obj.MainReadWrite(Self);
        Obj.FOwner := nil;
        Obj.SetOwner(AOwner);
        FPropertyTable.RestoreSettings;
        FDataBase := SavedBase;
      except
        on E: Exception do
        begin
          Obj.Free;
          Obj := nil;
          FPropertyTable.RestoreSettings;
          FDataBase := SavedBase;
          if not HandleException(E) then raise;
        end;
      end;
    end;
  end;
end;

procedure TEReadStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  Offset, SavedBase, I, ChildID: Integer;
  Child: TEObject;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    SavedBase := FDataBase;
    FPropertyTable.BackupSettings;
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FPropertyTable.LoadFromStream(FStream);
    FDataBase := FStream.Position;
    if csKeepIndex in Node.GetControlStyle then
      for I := FPropertyTable.First to FPropertyTable.Count - 1 do
      begin
        ChildID := FPropertyTable.Items^[I].ID;
        rwCreateEObject(Child, Node, ChildID);
        if Child <> nil then Child.SetArrayOwner(Node, ChildID);
      end
    else
      for I := FPropertyTable.First to FPropertyTable.Count - 1 do
      begin
        ChildID := FPropertyTable.Items^[I].ID;
        rwCreateEObject(Child, Node, ChildID);
      end;
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
  end;
end;

procedure TEReadStorageStream.rwEObject(Obj: TEObject; ID: Integer);
var
  Offset, SavedBase: Integer;
begin
  SavedBase := FDataBase;
  Offset := FPropertyTable.FindOffset(ID);
  FPropertyTable.BackupSettings;
  if Offset <> -1 then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FPropertyTable.LoadFromStream(FStream);
    FDataBase := FStream.Position;
  end;
  try
    Obj.MainReadWrite(Self);
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
  except
    on E: Exception do
    begin
      FPropertyTable.RestoreSettings;
      FDataBase := SavedBase;
      if not HandleException(E) then raise;
    end;
  end;
end;

procedure TEReadStorageStream.rwEObjectStream(Obj: TEObject; ID: Integer);
var
  SavedBase, Start, Size: Integer;
begin
  Start := FStream.Position;
  FStream.Read(Size, SizeOf(Integer));
  if Size <> 0 then
  begin
    SavedBase := FDataBase;
    FPropertyTable.BackupSettings;
    try
      FPropertyTable.LoadFromStream(FStream);
      FDataBase := FStream.Position;
      Obj.MainReadWrite(Self);
      FPropertyTable.RestoreSettings;
      FDataBase := SavedBase;
      FStream.Position := Start + Size + SizeOf(Integer);
    except
      on E: Exception do
      begin
        FPropertyTable.RestoreSettings;
        FDataBase := SavedBase;
        FStream.Position := Start + Size + SizeOf(Integer);
        if not HandleException(E) then raise;
      end;
    end;
  end;
end;

{ TEWriteTextStorageStream }

constructor TEWriteTextStorageStream.Create(AStream: TStream; AEngine: TEngine);
begin
  inherited Create(AStream, AEngine);
  FPath := '';
  FBuffer := TEBufferStream.Create;
  FPropertyTable := TPropertyTable.Create;
end;

destructor TEWriteTextStorageStream.Destroy;
begin
  WriteTextBuffer(FStream);
  FBuffer.Free;
  FPropertyTable.Free;
end;

function TEWriteTextStorageStream.StorageMode: TStorageModes;
begin
  Result := [smWrite, smText];
end;

procedure TEWriteTextStorageStream.WriteTextBuffer(Stream: TStream);
var
  S: string;
begin
  if (FPropertyTable.Count <> 0) and (FBuffer.Size <> 0) then
  begin
    S := '[:' + FPath + ':]' + #13 + #10;
    if FPath <> '' then S := #13#10 + S;
    Stream.Write(S[1], Length(S));
    FBuffer.SaveToStream(Stream);
  end;
end;

procedure TEWriteTextStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  O: TEObject;
begin
  O := Obj;
  if O <> nil then rwEObject(O, ID);
end;

procedure TEWriteTextStorageStream.rwEObject(Obj: TEObject; ID: Integer);
var
  SavedBuffer: TEBufferStream;
  SavedPath: string;
  Continue: Boolean;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    SavedBuffer := FBuffer;
    SavedPath := FPath;
    FPropertyTable.BackupSettings;
    FBuffer := TEBufferStream.Create;
    if FPath <> '' then FPath := FPath + '\' + IntToStr(ID) else FPath := IntToStr(ID);
    try
      Obj.MainReadWrite(Self);
      WriteTextBuffer(FStream);
      FBuffer.Free;
      FPropertyTable.RestoreSettings;
      FBuffer := SavedBuffer;
      FPath := SavedPath;
      FPropertyTable.Add(ID, 0);
    except
      FBuffer.Free;
      FBuffer := SavedBuffer;
      FPropertyTable.RestoreSettings;
      FPath := SavedPath;
      Continue := True;
      if Assigned(FOnError) then
        FOnError(Self, 'Error writing object (cid:' + IntToStr(Obj.ClassID) + ')', Continue);
      if not Continue then raise;
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TEWriteTextStorageStream.rwEObjectStream(Obj: TEObject; ID: Integer);
begin
  rwEObject(Obj, ID);
end;

procedure TEWriteTextStorageStream.rwString(var S: string; ID: Integer);
var
  Line: string;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if S <> '' then
    begin
      Line := '[' + IntToStr(ID) + ']=' + S + #13 + #10;
      FBuffer.Write(Line[1], Length(Line));
      FPropertyTable.Add(ID, 0);
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TEWriteTextStorageStream.rwStrings(Strings: TStrings; ID: Integer);
var
  Line: string;
  P: PChar;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    if Strings.Count <> 0 then
    begin
      P := Strings.GetText;
      try
        Line := '[' + IntToStr(ID) + ']=';
        if P <> nil then Line := Line + P else Line := Line + #13 + #10;
        FBuffer.Write(Line[1], Length(Line));
        FPropertyTable.Add(ID, 0);
      finally
        StrDispose(P);
      end;
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TEWriteTextStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
  rwStrings(Strings, ID);
end;

procedure TEWriteTextStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  SavedPath: string;
  I: Integer;
  C: TEObject;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    SavedPath := FPath;
    if FPath <> '' then FPath := FPath + '\' + IntToStr(ID) else FPath := IntToStr(ID);
    for I := 0 to Node.Count - 1 do
    begin
      C := Node.Children[I];
      if (C <> nil) and (C.Owner = Node) and not (csShared in C.GetControlStyle) and
        (csStored in C.GetControlStyle) then
        rwEObject(C, I);
    end;
    FPath := SavedPath;
    FPropertyTable.Add(ID, 0);
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found');
end;

{ TDebugWriteStream }

constructor TDebugWriteStream.Create(AStream: TStream; AEngine: TEngine);
begin
  FEngine := AEngine;
  FStream := AStream;
  FBuffer := TEBufferStream(AStream);
  FPropertyTable := TPropertyTable.Create;
  FPartial := False;
  FErrorHandled := False;
end;

destructor TDebugWriteStream.Destroy;
begin
  FPropertyTable.SaveToStream(FStream);
  FPropertyTable.Free;
end;

procedure TDebugWriteStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  AClassID: Integer;
  O: TEObject;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    O := Obj;
    if O <> nil then AClassID := O.ClassID else AClassID := 0;
    if AClassID <> 0 then
    begin
      FPropertyTable.BackupSettings;
      try
        Obj.MainReadWrite(Self);
        FBuffer.Write(AClassID, SizeOf(Integer));
        FPropertyTable.SaveToStream(FBuffer);
        FBuffer.Free;
        FPropertyTable.RestoreSettings;
        FPropertyTable.Add(ID, FBuffer.Position);
      except
        on E: Exception do
        begin
          FPropertyTable.RestoreSettings;
          if not HandleException(E) then raise;
        end;
      end;
    end
    else
    begin
      FBuffer.Write(AClassID, SizeOf(Integer));
      FPropertyTable.Add(ID, FBuffer.Position);
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + IntToStr(ID) + ')');
end;

procedure TDebugWriteStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  C: TEObject;
  I: Integer;
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    FPropertyTable.BackupSettings;
    for I := 0 to Node.Count - 1 do
    begin
      C := Node.Children[I];
      if (C <> nil) and (C.Owner = Node) and not (csShared in C.GetControlStyle) and
        (csStored in C.GetControlStyle) then
        rwCreateEObject(C, Node, I);
    end;
    FPropertyTable.SaveToStream(FBuffer);
    FPropertyTable.RestoreSettings;
    FPropertyTable.Add(ID, FBuffer.Position);
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + IntToStr(ID) + ')');
end;

procedure TDebugWriteStream.rwEObject(Obj: TEObject; ID: Integer);
begin
  if not FPropertyTable.PropertyExist(ID) then
  begin
    FPropertyTable.BackupSettings;
    try
      Obj.MainReadWrite(Self);
      FPropertyTable.SaveToStream(FBuffer);
      FPropertyTable.RestoreSettings;
      FPropertyTable.Add(ID, FBuffer.Position);
    except
      on E: Exception do
      begin
        FPropertyTable.RestoreSettings;
        if not HandleException(E) then raise;
      end;
    end;
  end
  else
    raise EDoublePrioriyID.Create('Double priorityID found (' + Obj.ClassName + ':' + IntToStr(ID) + ')');
end;

procedure TDebugWriteStream.rwEObjectStream(Obj: TEObject; ID: Integer);
var
  Size: Integer;
begin
  FPropertyTable.BackupSettings;
  try
    Obj.MainReadWrite(Self);
    FBuffer.Write(Size, SizeOf(Integer));
    FPropertyTable.SaveToStream(FBuffer);
    FBuffer.Write(Size, SizeOf(Integer));
    FPropertyTable.RestoreSettings;
  except
    on E: Exception do
    begin
      FPropertyTable.RestoreSettings;
      Size := 0;
      FBuffer.Write(Size, SizeOf(Integer));
      if not HandleException(E) then raise;
    end;
  end;
end;

{ TEReadTextStorageStream }

constructor TEReadTextStorageStream.Create(AStream: TStream; AEngine: TEngine; ASize: Integer);
begin
  inherited Create(AStream, AEngine);
  FPath := '';
  if ASize <= 0 then FSize := FStream.Size - FStream.Position else FSize := ASize;
  FValues := TStringList.Create;
  FPropertyTable := TPropertyTable.Create;
  FText := TStringList.Create;
  FSections := TStringList.Create;
  ReadStreamText;
  ReadTextBuffer;
end;

destructor TEReadTextStorageStream.Destroy;
begin
  FValues.Free;
  FPropertyTable.Free;
  FSections.Free;
  FText.Free;
end;

procedure TEReadTextStorageStream.ReadStreamText;
var
  Buffer, Line: string;
  Text: TStringList;
  P, Start: PChar;
  L: Integer;
begin
  Text := FText;
  FSections.Clear;
  Text.BeginUpdate;
  try
    SetString(Buffer, nil, FSize);
    FStream.Read(Pointer(Buffer)^, FSize);
    Text.Clear;
    P := Pointer(Buffer);
    if P <> nil then
      while P^ <> #0 do
      begin
        Start := P;
        while not (P^ in [#0, #10, #13]) do Inc(P);
        SetString(Line, Start, P - Start);
        if Line <> '' then
        begin
          L := Length(Line);
          if (L >= 4) and (Copy(Line, 1, 2) = '[:') and (Copy(Line, L - 1, 2) = ':]') then
            FSections.AddObject(Copy(Line, 3, L - 4), TObject(Text.Count))
          else
            Text.Add(Line);
        end;
        if P^ = #13 then Inc(P);
        if P^ = #10 then Inc(P);
      end;
  finally
    Text.EndUpdate;
  end;
end;

function TEReadTextStorageStream.StorageMode: TStorageModes;
begin
  Result := [smRead, smText];
end;

{ "[id]=" at the start of a text line, or -1 }
function GetLineID(S: string): Integer;
var
  I: Integer;
begin
  I := 1;
  while S[I] in ['0'..'9', '['] do Inc(I);
  if Copy(S, I, 2) = ']=' then Result := StrToInt(Copy(S, 2, I - 2)) else Result := -1;
end;

{ the text behind "[id]=" }
function GetLineValue(S: string): string;
var
  I: Integer;
begin
  I := 1;
  while S[I] in ['0'..'9', '[', ']'] do Inc(I);
  Result := Copy(S, I + 1, Length(S) - I);
end;

procedure TEReadTextStorageStream.ReadTextBuffer;
var
  Index, First, Last, I, ID, NewID: Integer;
  Value: string;
begin
  FValues.Clear;
  Index := FSections.IndexOf(FPath);
  if Index <> -1 then
  begin
    First := Integer(FSections.Objects[Index]);
    if Index <> FSections.Count - 1 then
      Last := Integer(FSections.Objects[Index + 1]) - 1
    else
      Last := FText.Count - 1;
    I := First;
    ID := -1;
    Value := '';
    while I <= Last do
    begin
      NewID := GetLineID(FText[I]);
      if ID <> -1 then
      begin
        if (NewID <> ID) and (NewID <> -1) then
        begin
          FPropertyTable.Add(ID, FValues.Count);
          FValues.Add(Value);
          ID := NewID;
          Value := GetLineValue(FText[I]);
        end
        else
          Value := Value + #13 + #10 + FText[I];
      end
      else if NewID <> -1 then
      begin
        if ID = -1 then ID := NewID;
        Value := GetLineValue(FText[I]);
      end;
      Inc(I);
    end;
    if ID <> -1 then
    begin
      FPropertyTable.Add(ID, FValues.Count);
      FValues.Add(Value);
    end;
  end;
end;

procedure TEReadTextStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  O: TEObject;
begin
  O := Obj;
  if O <> nil then rwEObject(O, ID);
end;

procedure TEReadTextStorageStream.rwEObject(Obj: TEObject; ID: Integer);
var
  SavedValues: TStringList;
  SavedPath: string;
  Continue: Boolean;
begin
  SavedPath := FPath;
  if FPath <> '' then FPath := FPath + '\' + IntToStr(ID) else FPath := IntToStr(ID);
  SavedValues := FValues;
  FPropertyTable.BackupSettings;
  FValues := TStringList.Create;
  try
    ReadTextBuffer;
    Obj.MainReadWrite(Self);
    FValues.Free;
    FPropertyTable.RestoreSettings;
    FValues := SavedValues;
    FPath := SavedPath;
  except
    FValues.Free;
    FPropertyTable.RestoreSettings;
    FValues := SavedValues;
    FPath := SavedPath;
    Continue := True;
    if Assigned(FOnError) then
      FOnError(Self, 'Error reading object (cid:' + IntToStr(Obj.ClassID) + ')', Continue);
    if not Continue then raise;
  end;
end;

procedure TEReadTextStorageStream.rwEObjectStream(Obj: TEObject; ID: Integer);
begin
  rwEObject(Obj, ID);
end;

procedure TEReadTextStorageStream.rwString(var S: string; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then S := FValues[Offset] else S := '';
end;

procedure TEReadTextStorageStream.rwStrings(Strings: TStrings; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then Strings.SetText(PChar(FValues[Offset])) else Strings.Clear;
end;

procedure TEReadTextStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
  rwStrings(Strings, ID);
end;

procedure TEReadTextStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  SavedPath: string;
  I: Integer;
  C: TEObject;
begin
  { the original saves the path and never restores it }
  SavedPath := FPath;
  if FPath <> '' then FPath := FPath + '\' + IntToStr(ID) else FPath := IntToStr(ID);
  for I := 0 to Node.Count - 1 do
  begin
    C := Node.Children[I];
    if (C <> nil) and (C.Owner = Node) and not (csShared in C.GetControlStyle) and
      (csStored in C.GetControlStyle) then
      rwEObject(C, I);
  end;
end;

{ TTranslateStorageStream }

constructor TTranslateStorageStream.Create(AEngine: TEngine);
begin
  inherited Create(nil, AEngine);
  FPropertyTable := TPropertyTable.Create;
end;

destructor TTranslateStorageStream.Destroy;
begin
  FPropertyTable.Free;
  inherited Destroy;
end;

function TTranslateStorageStream.StorageMode: TStorageModes;
begin
  Result := [smRead, smText, smTranslate];
end;

procedure TTranslateStorageStream.rwString(var S: string; ID: Integer);
begin
  TranslateString(S);
end;

procedure TTranslateStorageStream.rwStrings(Strings: TStrings; ID: Integer);
begin
  TranslateStrings(Strings);
end;

procedure TTranslateStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
  TranslateStrings(Strings);
end;

procedure TTranslateStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  O: TEObject;
begin
  O := Obj;
  if O <> nil then rwEObject(O, ID);
end;

procedure TTranslateStorageStream.rwEObject(Obj: TEObject; ID: Integer);
var
  Continue: Boolean;
begin
  try
    FPropertyTable.BackupSettings;
    Obj.MainReadWrite(Self);
    FPropertyTable.RestoreSettings;
  except
    FPropertyTable.RestoreSettings;
    { the original leaves Continue uninitialized here }
    if Assigned(FOnError) then
      FOnError(Self, 'Error reading object (cid:' + IntToStr(Obj.ClassID) + ')', Continue);
    if not Continue then raise;
  end;
end;

procedure TTranslateStorageStream.rwEObjectStream(Obj: TEObject; ID: Integer);
begin
  rwEObject(Obj, ID);
end;

procedure TTranslateStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  I: Integer;
  C: TEObject;
begin
  for I := 0 to Node.Count - 1 do
  begin
    C := Node.Children[I];
    if (C <> nil) and (C.Owner = Node) and not (csShared in C.GetControlStyle) and
      (csStored in C.GetControlStyle) then
      rwEObject(C, I);
  end;
end;

procedure TTranslateStorageStream.TranslateStrings(var Strings: TStrings);
begin
end;

procedure TTranslateStorageStream.TranslateString(var S: string);
begin
end;

{ TSetupCompareStorageStream }

function TSetupCompareStorageStream.StorageMode: TStorageModes;
begin
  Result := [smRead, smSetupCompare];
end;

{ TCompareStorageStream }

constructor TCompareStorageStream.Create(AStream: TStream; AEngine: TEngine);
begin
  inherited Create(AStream, AEngine, False);
end;

destructor TCompareStorageStream.Destroy;
begin
  inherited Destroy;
end;

function TCompareStorageStream.StorageMode: TStorageModes;
begin
  Result := [smRead, smCompare];
end;

procedure TCompareStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TECustomNode; ID: Integer);
var
  Offset, SavedBase, AClassID: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if (Offset <> -1) and (Obj <> nil) then
  begin
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FStream.Read(AClassID, SizeOf(Integer));
    if AClassID <> 0 then
    begin
      SavedBase := FDataBase;
      FPropertyTable.BackupSettings;
      FPropertyTable.LoadFromStream(FStream);
      FDataBase := FStream.Position;
      try
        Obj.MainReadWrite(Self);
      finally
        FPropertyTable.RestoreSettings;
        FDataBase := SavedBase;
      end;
    end;
  end;
end;

procedure TCompareStorageStream.rwChildren(Node: TECustomNode; ID: Integer);
var
  SavedBase, I, Start: Integer;
  C: TEObject;
  Offset, Index: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset <> -1 then
  begin
    SavedBase := FDataBase;
    FPropertyTable.BackupSettings;
    if FStream.Position <> FDataBase + Offset then FStream.Position := FDataBase + Offset;
    FPropertyTable.LoadFromStream(FStream);
    FDataBase := FStream.Position;
    if csKeepIndex in Node.GetControlStyle then
    begin
      for I := FPropertyTable.First to FPropertyTable.Count - 1 do
      begin
        Index := FPropertyTable.Items^[I].ID;
        C := Node.Children[Index];
        if C <> nil then rwCreateEObject(C, Node, Index);
      end;
    end
    else
    begin
      Start := 0;
      while (Start < Node.Count) and (Node.Children[Start] <> nil) and
        (Node.Children[Start].GetControlStyle * [csShared] <> []) do
        Inc(Start);
      for I := FPropertyTable.First to FPropertyTable.Count - 1 do
      begin
        Index := FPropertyTable.Items^[I].ID;
        if Index < Node.Count then
        begin
          C := Node.Children[I - FPropertyTable.First + Start];
          if C <> nil then rwCreateEObject(C, Node, Index);
        end;
      end;
    end;
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
  end;
end;

procedure TCompareStorageStream.Mismatch(ID: Integer);
begin
  try
    raise Exception.Create('Property Mismatch (PropertyID:' + IntToStr(ID) + ')');
  except
  end;
end;

procedure TCompareStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);
var
  P: Pointer;
begin
  P := nil;
  ReallocMem(P, Size);
  FillChar(P^, Size, 0);
  inherited rwData(P^, Size, ID);
  if not CompareMem(P, @Buffer, Size) then Mismatch(ID);
  ReallocMem(P, 0);
end;

procedure TCompareStorageStream.rwString(var S: string; ID: Integer);
var
  Value: string;
begin
  inherited rwString(Value, ID);
  if Value <> S then Mismatch(ID);
end;

procedure TCompareStorageStream.rwStrings(Strings: TStrings; ID: Integer);
var
  L: TStringList;
begin
  { the original never frees L }
  L := TStringList.Create;
  inherited rwStrings(L, ID);
  if CompareText(L.Text, Strings.Text) <> 0 then Mismatch(ID);
end;

procedure TCompareStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
var
  L: TStringList;
begin
  L := TStringList.Create;
  inherited rwStrings(L, ID);
  if CompareText(L.Text, Strings.Text) <> 0 then Mismatch(ID);
end;

procedure TCompareStorageStream.rwInteger(var I: Integer; ID: Integer);
var
  Value: Integer;
begin
  inherited rwInteger(Value, ID);
  if I <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwByte(var B: Byte; ID: Integer);
var
  Value: Byte;
begin
  inherited rwByte(Value, ID);
  if B <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwShortint(var S: Shortint; ID: Integer);
var
  Value: Shortint;
begin
  inherited rwShortint(Value, ID);
  if S <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwWord(var W: Word; ID: Integer);
var
  Value: Word;
begin
  inherited rwWord(Value, ID);
  if W <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwBool(var B: Boolean; ID: Integer);
var
  Value: Boolean;
begin
  inherited rwBool(Value, ID);
  if B <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
var
  Value: Integer;
begin
  inherited rwIntegerEx(Value, Default, ID);
  if I <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
var
  Value: Byte;
begin
  inherited rwByteEx(Value, Default, ID);
  if B <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
var
  Value: Shortint;
begin
  inherited rwShortintEx(Value, Default, ID);
  if S <> Value then Mismatch(ID);
end;

procedure TCompareStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
var
  Value: Word;
begin
  inherited rwWordEx(Value, Default, ID);
  if W <> Value then Mismatch(ID);
end;

initialization
  CRC32Table := nil;
  EngineLoaded := True;
  Engines := TList.Create;
  PlugIns := TList.Create;
  Packages := TStringList.Create;
  ClipboardFormat := RegisterClipboardFormat('ECLIPBOARD FORMAT');
  RegisterClass(TECopyComponent);
finalization
  ReleaseCRC32Table;
  UnloadExternalPlugIns;
  Packages.Free;
  Engines.Free;
  PlugIns.Free;

end.
