unit Engine;

{ The Engine unit of Enginep.dpl written for the original compiler (Delphi 3.02), class by class:
  tools/match.py compares the code DCC32 generates for every method with the code in the game's
  module. Declarations follow the original instance layouts and VMT orders (notes/classes.json); a
  method whose body is still a stub is marked "stub". The value lists live in EngineLists.pas and
  TPropertyTable in PropTable.pas until the whole unit is assembled. }

interface

uses
  SysUtils, Classes, FMemStr;

type
  { TEStorageStream.StorageMode }
  TStorageMode = (smRead, smWrite, smCompare, smPartial, smReserved4, smReserved5, smTranslate);
  TStorageModes = set of TStorageMode;

  { TEObject.GetControlStyle }
  TEControlStyle = (csStored, csShared, csReserved2, csKeepIndex);
  TEControlStyles = set of TEControlStyle;

  PEMsg = ^TEMsg;
  TEMsg = record
    MsgID: Integer;
    Seq: Integer;
    Param: Integer;
    Result: Integer;
  end;

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

  TStorageErrorEvent = procedure(Sender: TObject; const Msg: string; var Continue: Boolean) of object;
  TStorageProgressEvent = procedure(Sender: TObject; const Msg: string; Percent: Integer) of object;

  EDoublePrioriyID = class(Exception);

  { Engine.TEBufferStream (instance size 20): the write stream's data buffer }
  TEBufferStream = class(TFastMemoryStream)
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
    procedure AddRef; virtual;
    procedure Release; virtual;
    procedure Clear; virtual;
    function Compare(Obj: TEObject; AEngine: TEngine): Boolean; virtual;
    function Editor: TClass; virtual;
    procedure Assign(Source: TEObject; AEngine: TEngine); virtual;
    procedure TimerEvent; virtual;
    procedure MsgProc(var Msg: TEMsg; Sender: TEObject); virtual;
    procedure SetArrayOwner(AOwner: TECustomNode; Index: Integer); virtual;
    destructor Destroy; override;
    function Copy(AEngine: TEngine): TEObject;
    property Owner: TECustomNode read FOwner write SetOwner;
    property EObjectPath: string read GetEObjectPath;
    property LastMsg: Integer read GetLastMsg write SetLastMsg;
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
    procedure RemoveChild(Child: TEObject); virtual; abstract;
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
    procedure RemoveChild(Child: TEObject); override;
    function AddChild(Child: TEObject): Integer; override;
    function FindChild(AClassID: Integer): TEObject; override;
    function FindChildIndex(Child: TEObject): Integer; override;
    destructor Destroy; override;
    procedure DestroyEObjects(AClassID: Integer);
  end;

  { Engine.TEObjectEditor (instance size 8): editors are looked up by class. stub }
  TEObjectEditor = class(TEObject)
  public
    class function EditorClassID: Integer; virtual;
    procedure Edit; virtual;
    procedure UpdateMultiPopupMenu; virtual;
    procedure UpdatePopupMenu; virtual;
  end;

  TEObjectEditorClass = class of TEObjectEditor;

  { Engine.TEObjectClassList (instance size 16): a TList of class references. stub }
  TEObjectClassList = class(TList)
  end;

  { Engine.TEObjectEditorList (instance size 16) }
  TEObjectEditorList = class(TEObjectClassList)
  public
    function FindEditor(AClassID: Integer): TEObjectEditorClass;
  end;

  { Engine.TEngine (instance size 52): +$18 FEditors. stub }
  TEngine = class(TENode)
  private
    FUnknown0C: Integer;
    FUnknown10: Integer;
    FUnknown14: Integer;
    FEditors: TEObjectEditorList;
    FUnknown1C: Integer;
    FUnknown20: Integer;
    FUnknown24: Integer;
    FUnknown28: Integer;
    FUnknown2C: Integer;
    FUnknown30: Integer;
  public
    function GetEngine: TEngine; override;
    constructor Create(AOwner: TECustomNode); override;
    class function ClassID: Integer; override;
    procedure SetStartupDirectory(const Value: string); virtual;
    procedure UpdateStartupDirectory; virtual;
    function CreateEObject(AClassID: Integer; AOwner: TECustomNode): TEObject; virtual;
    function GetEClass(AClassID: Integer): TEObjectClass; virtual;
    function TranslateText(const Text: string): string; virtual;
    procedure ReadEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    procedure WriteEObject(Stream: TStream; Obj: TEObject; AProgress: TStorageProgressEvent);
    property Editors: TEObjectEditorList read FEditors;
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
    procedure rwEObjectStream(Obj: TEObject); virtual; abstract;
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
    procedure rwEObjectStream(Obj: TEObject); override;
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
    procedure rwEObjectStream(Obj: TEObject); override;
  end;

procedure StringToStream(const S: string; Stream: TStream);
procedure StringFromStream(var S: string; Stream: TStream);
procedure StringsToStream(Strings: TStrings; Stream: TStream);
procedure StringsFromStream(Strings: TStrings; Stream: TStream);

resourcestring
  EStreamReadErrorStr = 'Error Reading EObject';
  EStreamWriteErrorStr = 'Error Writing EObject';

implementation

{ strings }

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

procedure TEObject.AddRef;
begin
  raise Exception.Create('Reference counting not supported');
end;

procedure TEObject.Release;
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

procedure TEObject.TimerEvent;
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
  if Stream.StorageMode * [smRead, smCompare, smTranslate] = [smRead] then Clear;
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
    if Stream.StorageMode * [smCompare, smTranslate] = [] then Clear;
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

procedure TENode.RemoveChild(Child: TEObject);
var
  I: Integer;
begin
  if csKeepIndex in GetControlStyle then
  begin
    I := FChildren.IndexOf(Child);
    if I <> -1 then FChildren.List^[I] := nil;
  end
  else
    FChildren.Remove(Child);
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

procedure TEObjectEditor.Edit;
begin
end;

procedure TEObjectEditor.UpdateMultiPopupMenu;
begin
end;

procedure TEObjectEditor.UpdatePopupMenu;
begin
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

{ TEngine: stubs except the object entry points }

function TEngine.GetEngine: TEngine;
begin
  Result := Self;
end;

constructor TEngine.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TEngine.ClassID: Integer;
begin
  Result := 0;
end;

procedure TEngine.SetStartupDirectory(const Value: string);
begin
end;

procedure TEngine.UpdateStartupDirectory;
begin
end;

function TEngine.CreateEObject(AClassID: Integer; AOwner: TECustomNode): TEObject;
begin
  Result := nil;
end;

function TEngine.GetEClass(AClassID: Integer): TEObjectClass;
begin
  Result := nil;
end;

function TEngine.TranslateText(const Text: string): string;
begin
  Result := Text;
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

procedure TEWriteStorageStream.rwEObjectStream(Obj: TEObject);
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

procedure TEReadStorageStream.rwEObjectStream(Obj: TEObject);
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

end.
