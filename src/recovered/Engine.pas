unit Engine;

{ Recovered from Enginep.dpl (Age of Wonders 1.36, Delphi 3), persistence part of the Engine unit.

  Sources: data/decomp/Enginep-typed-all (Ghidra, typed), doc/persistence.md.
  Field names are the original ones where RTTI or accessors gave them, and descriptive names otherwise;
  the field order and sizes follow the original instance layout so that a Delphi 3 build can later be
  compared byte for byte. Method bodies are translated by hand from the decompiled code; each one names
  the function it came from.

  Covered so far: TPropertyTable, TEStorageStream, TEReadStorageStream, TCompressStream, the string and
  string-list stream helpers, and the minimum of TEObject needed to read objects. The write side,
  compare and translate streams, and the node classes follow. }

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils, Classes, zstream;

const
  { TEStorageStream.StorageMode flags }
  smRead = 1;           { TEReadStorageStream }
  smWrite = 2;          { TEWriteStorageStream }
  smCompare = 4;        { TCompareStorageStream }
  smPartial = 8;        { read stream created with the "partial" flag: map data is skipped }
  smNoProgress = $10;
  smTranslate = $40;    { TTranslateStorageStream }

  { TEObject.GetControlStyle flags }
  csStored = 1;
  csShared = 2;
  csKeepIndex = 8;

type
  TEStorageStream = class;
  TEngine = class;

  TECustomNode = class;

  { Engine.TEObject (instance size 8): +4 FOwner. The slot comments give the original VMT offsets.
    GetControlStyle flags: csStored (1) the object is written by rwChildren; csShared (2) the owner
    does not free it on Clear and rwChildren skips it; csKeepIndex (8) RemoveChild leaves a nil slot. }
  TEObject = class(TObject)
  private
    FOwner: TEObject;                          { +$04 }
    FEmbeddedShared: Boolean;                  { model aid, not in the original: see GetControlStyle }
    FStoredIndex: Integer;                     { model aid: the child slot this object was read from, or -1 }
  public
    constructor Create(AOwner: TEObject); virtual;             { slot +$20 }
    destructor Destroy; override;
    function ClassVersion: Integer; virtual;                   { slot +$00 }
    function GetControlStyle: Byte; virtual;                   { slot +$04 }
    procedure SetOwner(AOwner: TEObject); virtual;             { slot +$08 }
    procedure ReadWrite(Stream: TEStorageStream); virtual;     { slot +$18 }
    procedure MainReadWrite(Stream: TEStorageStream); virtual; { slot +$1C }
    function ClassID: Integer; virtual;                        { slot +$24 }
    procedure Clear; virtual;                                  { slot +$30 }
    procedure SetArrayOwner(AOwner: TEObject; Index: Integer); virtual;   { slot +$48 }
    property Owner: TEObject read FOwner write SetOwner;
    { Objects that an owner creates in its constructor and persists with rwEObject must not be freed by
      the owner's Clear nor written again by rwChildren. The original classes achieve that with their
      own GetControlStyle overrides; the generated model sets this flag instead. }
    property EmbeddedShared: Boolean read FEmbeddedShared write FEmbeddedShared;
    { rwChildren stores a child under its index in the owner's list. The original owner has a few
      unstored children (embedded lists) in front, created by its constructor; the model does not
      reproduce that order yet, so the index a child was read from is kept and written back. }
    property StoredIndex: Integer read FStoredIndex write FStoredIndex;
  end;

  TEObjectClass = class of TEObject;

  { Engine.TECustomNode (instance size 8): a TEObject that owns children through an abstract list
    interface; TENode keeps them in a TList. Children are persisted after the node's own properties. }
  TECustomNode = class(TEObject)
  public
    destructor Destroy; override;
    procedure MainReadWrite(Stream: TEStorageStream); override;
    procedure Clear; override;
    function GetChild(Index: Integer): TEObject; virtual; abstract;      { slot +$4C }
    procedure SetChild(Index: Integer; Child: TEObject); virtual; abstract;   { slot +$50 }
    function GetCount: Integer; virtual; abstract;                      { slot +$54 }
    function AddChild(Child: TEObject): Integer; virtual; abstract;     { slot +$70 }
    procedure RemoveChild(Child: TEObject); virtual; abstract;          { slot +$6C }
    procedure ReadWriteChildren(Stream: TEStorageStream); virtual;
    procedure DestroyAllChildren; virtual;
    function FindChild(AClassID: Integer): TEObject;
    function FindChildIndex(Child: TEObject): Integer; virtual;
    function DestroyChildren(AClassID: Integer): Integer;
    property Count: Integer read GetCount;
    property Children[Index: Integer]: TEObject read GetChild write SetChild;
  end;

  { Engine.TENode (instance size 12): +8 FChildren, a TEObjectList (TList of TEObject). }
  TENode = class(TECustomNode)
  private
    FChildren: TList;                          { +$08 }
  public
    constructor Create(AOwner: TEObject); override;
    destructor Destroy; override;
    procedure Clear; override;
    procedure DestroyAllChildren; override;
    function GetChild(Index: Integer): TEObject; override;
    procedure SetChild(Index: Integer; Child: TEObject); override;
    function GetCount: Integer; override;
    function AddChild(Child: TEObject): Integer; override;
    procedure RemoveChild(Child: TEObject); override;
    function FindChildIndex(Child: TEObject): Integer; override;
    procedure DestroyEObjects(AClassID: Integer);
  end;

  { Engine.TEControlStyleNode (instance size 16, class id $101): a node with a stored control style. }
  TEControlStyleNode = class(TENode)
  private
    FControlStyle: Byte;                       { +$0C }
  public
    constructor Create(AOwner: TEObject); override;
    function ClassID: Integer; override;
    function GetControlStyle: Byte; override;
    procedure SetControlStyle(Value: Byte);
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  { Engine.TEControlStyleObject (instance size 12, class id $51). }
  TEControlStyleObject = class(TEObject)
  private
    FControlStyle: Byte;                       { +$08 }
  public
    constructor Create(AOwner: TEObject); override;
    function ClassID: Integer; override;
    function GetControlStyle: Byte; override;
    procedure SetControlStyle(Value: Byte);
    procedure ReadWrite(Stream: TEStorageStream); override;
  end;

  { The part of Engine.TEngine that persistence needs: creating an object from its class id, and the
    root read/write entry points. }
  TEngine = class(TEObject)
  public
    function CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject; virtual;   { slot +$90 }
    procedure ReadEObject(Stream: TStream; Obj: TEObject);     { Engine.TEngine.ReadEObject }
    procedure WriteEObject(Stream: TStream; Obj: TEObject);    { Engine.TEngine.WriteEObject }
  end;

  PPropertyItem = ^TPropertyItem;
  TPropertyItem = packed record
    ID: Integer;
    Offset: Integer;
  end;
  PPropertyItems = ^TPropertyItems;
  TPropertyItems = array[0..MaxInt div SizeOf(TPropertyItem) - 1] of TPropertyItem;

  PPropertySettings = ^TPropertySettings;
  TPropertySettings = packed record             { 12 bytes, one per BackupSettings }
    First: Integer;
    NextIndex: Integer;
    MaxID: Integer;
  end;
  PPropertySettingsArray = ^TPropertySettingsArray;
  TPropertySettingsArray = array[0..MaxInt div SizeOf(TPropertySettings) - 1] of TPropertySettings;

  { Engine.TPropertyTable (instance size 40). Maps property ids to byte offsets inside one object's data.
    Nested objects push their own table on top of the outer one (BackupSettings/RestoreSettings), so the
    items of all open objects live in one growing array and First marks where the current object starts. }
  TPropertyTable = class(TObject)
  private
    FItems: PPropertyItems;                    { +$04 }
    FCapacity: Integer;                        { +$08 }
    FCount: Integer;                           { +$0C }
    FNextIndex: Integer;                       { +$10  sequential-read hint }
    FMaxID: Integer;                           { +$14  highest id added }
    FStack: PPropertySettingsArray;            { +$18 }
    FStackCount: Integer;                      { +$1C }
    FStackCapacity: Integer;                   { +$20 }
    FFirst: Integer;                           { +$24  first item of the current table }
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
    property Count: Integer read FCount;
    property First: Integer read FFirst;
    property Items: PPropertyItems read FItems;
  end;

  TStreamProc = procedure(Stream: TStream) of object;
  TStorageErrorEvent = function(Sender: TEStorageStream; const Msg: string; var Continue: Boolean): Boolean of object;
  TStorageProgressEvent = procedure(Sender: TObject; const Msg: string; Percent: Integer) of object;

  { Engine.TEStorageStream (instance size 36): the abstract read/write visitor. Every rw* method is
    symmetric: the stream decides whether the argument is read or written. }
  TEStorageStream = class(TObject)
  private
    FEngine: TEngine;                          { +$04 }
    FStream: TStream;                          { +$08 }
    FErrorHandled: Boolean;                    { +$0C }
    FOnError: TStorageErrorEvent;              { +$14 }
    FOnProgress: TStorageProgressEvent;        { +$1C }
  public
    constructor Create(AStream: TStream; AEngine: TEngine); virtual;
    function StorageMode: Byte; virtual; abstract;                                   { slot +$00 }
    function OpenPropertyStream(ID: Integer): TStream; virtual;                      { slot +$04 }
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TEObject; ID: Integer); virtual; abstract;  { +$08 }
    procedure rwEObject(Obj: TEObject; ID: Integer); virtual; abstract;             { slot +$0C }
    procedure rwEObjectStream(Obj: TEObject); virtual; abstract;                    { slot +$10 }
    procedure rwChildren(Node: TEObject; ID: Integer); virtual; abstract;           { slot +$14 }
    procedure rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc); virtual; { slot +$18 }
    procedure rwData(var Buffer; Size: Integer; ID: Integer); virtual;              { slot +$1C }
    procedure rwString(var S: string; ID: Integer); virtual;                        { slot +$20 }
    procedure rwStrings(Strings: TStrings; ID: Integer); virtual;                   { slot +$24 }
    procedure rwStringsEx(Strings: TStrings; ID: Integer); virtual;                 { slot +$28 }
    procedure rwInteger(var I: Integer; ID: Integer); virtual;                      { slot +$2C }
    procedure rwByte(var B: Byte; ID: Integer); virtual;                            { slot +$30 }
    procedure rwWord(var W: Word; ID: Integer); virtual;                            { slot +$34 }
    procedure rwBool(var B: Boolean; ID: Integer); virtual;                         { slot +$38 }
    procedure rwShortint(var S: Shortint; ID: Integer); virtual;                    { slot +$3C }
    procedure rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); virtual;  { slot +$40 }
    procedure rwByteEx(var B: Byte; Default: Byte; ID: Integer); virtual;           { slot +$44 }
    procedure rwWordEx(var W: Word; Default: Word; ID: Integer); virtual;           { slot +$48 }
    procedure rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); virtual; { slot +$4C }
    procedure ShowProgress(Sender: TObject; const Msg: string; Percent: Integer);
    property Engine: TEngine read FEngine;
    property Stream: TStream read FStream;
    property OnError: TStorageErrorEvent read FOnError write FOnError;
    property OnProgress: TStorageProgressEvent read FOnProgress write FOnProgress;
  end;

  { Engine.TEReadStorageStream (instance size 44). The constructor reads the root property table at
    the current stream position; FDataBase is where that table's offsets count from. }
  TEReadStorageStream = class(TEStorageStream)
  private
    FPropertyTable: TPropertyTable;            { +$10 }
    FPartial: Boolean;                         { +$24  adds smPartial to StorageMode }
    FDataBase: Integer;                        { +$28 }
    procedure SeekTo(Offset: Integer);
  public
    constructor Create(AStream: TStream; APartial: Boolean; AEngine: TEngine); reintroduce;
    destructor Destroy; override;
    function StorageMode: Byte; override;
    function OpenPropertyStream(ID: Integer): TStream; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TEObject; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject); override;
    procedure rwChildren(Node: TEObject; ID: Integer); override;
    procedure rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc); override;
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
    function HandleException(E: Exception): Boolean;
    property PropertyTable: TPropertyTable read FPropertyTable;
    property DataBase: Integer read FDataBase;
  end;

  { Engine.TEWriteStorageStream (instance size 44). Values go into a memory buffer; the property table
    records (id, buffer position) for each one. Nested objects get their own buffer, which is appended
    to the outer buffer as [table][data] when they finish. The destructor writes the root table and
    the root buffer to the real stream. Properties equal to their default (0, empty, False) are not
    written at all; the reader turns a missing id back into the default. }
  TEWriteStorageStream = class(TEStorageStream)
  private
    FPropertyTable: TPropertyTable;            { +$10 }
    FPartial: Boolean;                         { +$24 }
    FBuffer: TMemoryStream;                    { +$28  TEBufferStream }
    procedure PropertyExistError(ID: Integer);
    procedure CheckNew(ID: Integer);
    procedure Nest(Obj: TEObject; ID: Integer; WriteClassID: Boolean);
  public
    constructor Create(AStream: TStream; APartial: Boolean; AEngine: TEngine); reintroduce;
    destructor Destroy; override;
    function StorageMode: Byte; override;
    function OpenPropertyStream(ID: Integer): TStream; override;
    procedure rwCreateEObject(var Obj: TEObject; AOwner: TEObject; ID: Integer); override;
    procedure rwEObject(Obj: TEObject; ID: Integer); override;
    procedure rwEObjectStream(Obj: TEObject); override;
    procedure rwChildren(Node: TEObject; ID: Integer); override;
    procedure rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc); override;
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

  EDoublePriorityID = class(Exception);        { Engine.EDoublePrioriyID, misspelled in the original }

  { Engine.TCompressStream: a TMemoryStream whose file form is "CFS"#0, a version byte, and the zlib
    stream of the contents (version 2). Version 0 means stored without compression. }
  TCompressStream = class(TMemoryStream)
  public
    procedure LoadFromStream(Stream: TStream); reintroduce;
    procedure LoadFromFile(const FileName: string); reintroduce;
    procedure SaveToStreamEx(Stream: TStream; Version: Byte);
    procedure SaveToStream(Stream: TStream); reintroduce;
  end;

{ Engine string helpers (unnamed in the exports, FUN_5550f81c and friends): one length byte, $FF + Integer
  for long strings, then the characters. }
procedure ReadStringFromStream(var S: string; Stream: TStream);
procedure WriteStringToStream(const S: string; Stream: TStream);
{ Engine.StringsFromStream / StringsToStream: Integer length + the text of TStrings.Text. }
procedure StringsFromStream(Strings: TStrings; Stream: TStream);
procedure StringsToStream(Strings: TStrings; Stream: TStream);

const
  CompressStreamID: array[0..3] of AnsiChar = 'CFS'#0;

var
  { statistics for the round-trip tests }
  StorageStats: record
    ObjectsRead, ObjectsWritten, ChildrenRead, ChildrenWritten, ChildrenSkipped: Integer;
  end;

implementation

{ ---------------------------------------------------------------- strings }

procedure ReadStringFromStream(var S: string; Stream: TStream);   { FUN_5550f81c }
var
  B: Byte;
  Len: Integer;
begin
  S := '';
  Stream.Read(B, 1);
  if B = $FF then
    Stream.Read(Len, 4)
  else
    Len := B;
  SetLength(S, Len);
  if Len > 0 then
    Stream.Read(S[1], Len);
end;

procedure WriteStringToStream(const S: string; Stream: TStream);
var
  B: Byte;
  Len: Integer;
begin
  Len := Length(S);
  if Len >= $FF then
  begin
    B := $FF;
    Stream.Write(B, 1);
    Stream.Write(Len, 4);
  end
  else
  begin
    B := Len;
    Stream.Write(B, 1);
  end;
  if Len > 0 then
    Stream.Write(S[1], Len);
end;

procedure StringsFromStream(Strings: TStrings; Stream: TStream);   { Engine.StringsFromStream }
var
  Len: Integer;
  Text: string;
begin
  Strings.BeginUpdate;
  try
    Stream.Read(Len, 4);
    SetLength(Text, Len);
    if Len > 0 then
      Stream.Read(Text[1], Len);
    Strings.Text := Text;
  finally
    Strings.EndUpdate;
  end;
end;

procedure StringsToStream(Strings: TStrings; Stream: TStream);     { Engine.StringsToStream }
var
  Text: string;
  Len: Integer;
begin
  Text := Strings.Text;
  Len := Length(Text);
  Stream.Write(Len, 4);
  if Len > 0 then
    Stream.WriteBuffer(Text[1], Len);
end;

{ ---------------------------------------------------------------- TEObject }

constructor TEObject.Create(AOwner: TEObject);                     { Engine.TEObject.Create }
begin
  inherited Create;
  FStoredIndex := -1;
  SetOwner(AOwner);
end;

destructor TEObject.Destroy;                                       { Engine.TEObject.Destroy }
begin
  SetOwner(nil);
  inherited Destroy;
end;

function TEObject.ClassVersion: Integer;
begin
  Result := 0;
end;

function TEObject.GetControlStyle: Byte;                           { Engine.TEObject.GetControlStyle }
begin
  if FEmbeddedShared then
    Result := csStored or csShared
  else
    Result := csStored;
end;

procedure TEObject.SetOwner(AOwner: TEObject);                     { Engine.TEObject.SetOwner }
begin
  { the owner is told through its node interface: slot +$6C RemoveChild, slot +$70 AddChild }
  if AOwner <> FOwner then
  begin
    if FOwner is TECustomNode then
      TECustomNode(FOwner).RemoveChild(Self);
    FOwner := AOwner;
    if AOwner is TECustomNode then
      TECustomNode(AOwner).AddChild(Self);
  end;
end;

procedure TEObject.SetArrayOwner(AOwner: TEObject; Index: Integer);   { Engine.TEObject.SetArrayOwner }
begin
  if FOwner is TECustomNode then
    TECustomNode(FOwner).RemoveChild(Self);
  FOwner := AOwner;
  if AOwner is TECustomNode then
    TECustomNode(AOwner).SetChild(Index, Self);
end;

procedure TEObject.ReadWrite(Stream: TEStorageStream);             { Engine.TEObject.ReadWrite: empty }
begin
end;

procedure TEObject.MainReadWrite(Stream: TEStorageStream);         { Engine.TEObject.MainReadWrite }
begin
  if (Stream.StorageMode and (smRead or smCompare or smTranslate)) = smRead then
    Clear;
  ReadWrite(Stream);
end;

function TEObject.ClassID: Integer;
begin
  Result := 0;
end;

procedure TEObject.Clear;
begin
end;

{ ---------------------------------------------------------------- TECustomNode }

destructor TECustomNode.Destroy;                                   { Engine.TECustomNode.Destroy }
begin
  DestroyAllChildren;
  inherited Destroy;
end;

procedure TECustomNode.MainReadWrite(Stream: TEStorageStream);     { Engine.TECustomNode.MainReadWrite }
begin
  if (Stream.StorageMode and smRead) <> 0 then
    if (Stream.StorageMode and (smCompare or smTranslate)) = 0 then
      Clear;
  ReadWrite(Stream);
  ReadWriteChildren(Stream);
end;

procedure TECustomNode.ReadWriteChildren(Stream: TEStorageStream);   { Engine.TECustomNode.ReadWriteChildren }
begin
  Stream.rwChildren(Self, 1);
end;

procedure TECustomNode.Clear;                                      { Engine.TECustomNode.Clear }
var
  I: Integer;
  Child: TEObject;
begin
  if GetCount = 0 then
    Exit;
  { owned children are freed, shared ones are cleared }
  for I := GetCount - 1 downto 0 do
  begin
    Child := GetChild(I);
    if (Child <> nil) and (Child.FOwner = Self) then
      if (Child.GetControlStyle and csShared) = 0 then
        Child.Free
      else
        Child.Clear;
  end;
  { then every child that is not an owned shared one leaves the list }
  for I := GetCount - 1 downto 0 do
  begin
    Child := GetChild(I);
    if Child <> nil then
      if not ((Child.FOwner = Self) and ((Child.GetControlStyle and csShared) <> 0)) then
        RemoveChild(Child);
  end;
end;

procedure TECustomNode.DestroyAllChildren;                         { Engine.TECustomNode.DestroyAllChildren }
var
  I: Integer;
  Child: TEObject;
begin
  for I := GetCount - 1 downto 0 do
  begin
    Child := GetChild(I);
    if (Child <> nil) and (Child.FOwner = Self) then
      Child.Free;
  end;
  for I := GetCount - 1 downto 0 do
  begin
    Child := GetChild(I);
    if Child <> nil then
      RemoveChild(Child);
  end;
end;

function TECustomNode.FindChild(AClassID: Integer): TEObject;       { Engine.TECustomNode.FindChild }
var
  I: Integer;
begin
  for I := 0 to GetCount - 1 do
  begin
    Result := GetChild(I);
    if (Result <> nil) and (Result.ClassID = AClassID) then
      Exit;
  end;
  Result := nil;
end;

function TECustomNode.FindChildIndex(Child: TEObject): Integer;     { Engine.TECustomNode.FindChildIndex }
begin
  Result := GetCount - 1;
  while (Result >= 0) and (GetChild(Result) <> Child) do
    Dec(Result);
end;

function TECustomNode.DestroyChildren(AClassID: Integer): Integer;  { Engine.TECustomNode.DestroyChildren }
var
  I: Integer;
  Child: TEObject;
begin
  Result := 0;
  for I := GetCount - 1 downto 0 do
  begin
    Child := GetChild(I);
    if (Child <> nil) and (Child.ClassID = AClassID) then
    begin
      Child.Free;
      Inc(Result);
    end;
  end;
end;

{ ---------------------------------------------------------------- TENode }

constructor TENode.Create(AOwner: TEObject);                       { Engine.TENode.Create }
begin
  FChildren := TList.Create;                   { TEObjectList in the original }
  inherited Create(AOwner);
end;

destructor TENode.Destroy;                                         { Engine.TENode.Destroy }
begin
  inherited Destroy;
  FChildren.Free;
end;

function TENode.GetChild(Index: Integer): TEObject;
begin
  Result := TEObject(FChildren[Index]);
end;

procedure TENode.SetChild(Index: Integer; Child: TEObject);        { Engine.TENode.SetChild }
var
  Old: TEObject;
begin
  while Index >= GetCount do
    FChildren.Add(nil);
  Old := TEObject(FChildren[Index]);
  if (Old <> nil) and (Old.FOwner = Self) then
    Old.Free;
  FChildren[Index] := Child;
end;

function TENode.GetCount: Integer;
begin
  Result := FChildren.Count;
end;

function TENode.AddChild(Child: TEObject): Integer;                { Engine.TENode.AddChild }
begin
  FChildren.Add(Child);
  Result := FChildren.Count - 1;
end;

procedure TENode.RemoveChild(Child: TEObject);                     { Engine.TENode.RemoveChild }
var
  I: Integer;
begin
  if (GetControlStyle and csKeepIndex) = 0 then
    FChildren.Remove(Child)
  else
  begin
    I := FChildren.IndexOf(Child);
    if I <> -1 then
      FChildren[I] := nil;
  end;
end;

function TENode.FindChildIndex(Child: TEObject): Integer;
begin
  Result := FChildren.IndexOf(Child);
end;

procedure TENode.Clear;                                            { Engine.TENode.Clear }
var
  I: Integer;
begin
  inherited Clear;
  { trailing nil slots left by csKeepIndex are dropped }
  I := FChildren.Count - 1;
  while (I >= 0) and (FChildren[I] = nil) do
  begin
    FChildren.Delete(I);
    Dec(I);
  end;
end;

procedure TENode.DestroyAllChildren;                               { Engine.TENode.DestroyAllChildren }
var
  I: Integer;
  Child: TEObject;
begin
  Clear;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Child := TEObject(FChildren[I]);
    if (Child <> nil) and (Child.FOwner = Self) then
      Child.Free;
  end;
end;

procedure TENode.DestroyEObjects(AClassID: Integer);               { Engine.TENode.DestroyEObjects }
var
  I: Integer;
  Child: TEObject;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    Child := TEObject(FChildren[I]);
    if (Child <> nil) and (Child.ClassID = AClassID) and (Child.FOwner = Self) then
      Child.Free;
  end;
end;

{ ---------------------------------------------------------------- control style classes }

constructor TEControlStyleNode.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

function TEControlStyleNode.ClassID: Integer;
begin
  Result := $101;
end;

function TEControlStyleNode.GetControlStyle: Byte;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleNode.SetControlStyle(Value: Byte);
begin
  FControlStyle := Value;
end;

procedure TEControlStyleNode.ReadWrite(Stream: TEStorageStream);   { Engine.TEControlStyleNode.ReadWrite }
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FControlStyle, 1, 2);
end;

constructor TEControlStyleObject.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FControlStyle := inherited GetControlStyle;
end;

function TEControlStyleObject.ClassID: Integer;
begin
  Result := $51;
end;

function TEControlStyleObject.GetControlStyle: Byte;
begin
  Result := FControlStyle;
end;

procedure TEControlStyleObject.SetControlStyle(Value: Byte);
begin
  FControlStyle := Value;
end;

procedure TEControlStyleObject.ReadWrite(Stream: TEStorageStream);   { Engine.TEControlStyleObject.ReadWrite }
begin
  Stream.rwData(FControlStyle, 1, 1);
end;

{ ---------------------------------------------------------------- TEngine }

function TEngine.CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject;
begin
  Result := nil;
end;

procedure TEngine.ReadEObject(Stream: TStream; Obj: TEObject);      { Engine.TEngine.ReadEObject }
var
  S: TEReadStorageStream;
begin
  S := TEReadStorageStream.Create(Stream, False, Self);
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;
  end;
end;

procedure TEngine.WriteEObject(Stream: TStream; Obj: TEObject);     { Engine.TEngine.WriteEObject }
var
  S: TEWriteStorageStream;
begin
  S := TEWriteStorageStream.Create(Stream, False, Self);
  try
    S.rwEObject(Obj, 0);
  finally
    S.Free;                                    { the destructor writes table and data }
  end;
end;

{ ---------------------------------------------------------------- TPropertyTable }

destructor TPropertyTable.Destroy;                                 { Engine.TPropertyTable.Destroy }
begin
  SetCapacity(0);
  ReallocMem(FStack, 0);
  inherited Destroy;
end;

procedure TPropertyTable.SetCapacity(NewCapacity: Integer);        { Engine.TPropertyTable.SetCapacity }
begin
  if NewCapacity > 0 then
    NewCapacity := (NewCapacity + 31) and not 31;                  { grow in blocks of 32 items }
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FItems, NewCapacity * SizeOf(TPropertyItem));
    FCapacity := NewCapacity;
    if NewCapacity < FCount then
      FCount := NewCapacity;
  end;
end;

procedure TPropertyTable.Add(ID, Offset: Integer);                 { Engine.TPropertyTable.Add }
begin
  if FCapacity = FCount then
    SetCapacity(FCapacity + 1);
  FItems^[FCount].ID := ID;
  FItems^[FCount].Offset := Offset;
  Inc(FCount);
  if ID > FMaxID then
    FMaxID := ID;
end;

procedure TPropertyTable.Clear;                                    { Engine.TPropertyTable.Clear }
begin
  FNextIndex := 0;
  FMaxID := 0;
  SetCapacity(0);
end;

function TPropertyTable.FindOffset(ID: Integer): Integer;          { Engine.TPropertyTable.FindOffset }
var
  I: Integer;
begin
  { fast path: properties are usually read in the order they were written }
  I := FNextIndex;
  if (I < FCount) and (FItems^[I].ID = ID) then
  begin
    Result := FItems^[I].Offset;
    Inc(FNextIndex);
    Exit;
  end;
  Result := -1;
  I := FFirst;
  while (I < FCount) and (FItems^[I].ID <> ID) do
    Inc(I);
  if I <> FCount then
  begin
    Result := FItems^[I].Offset;
    FNextIndex := I + 1;
  end;
end;

function TPropertyTable.PropertyExist(ID: Integer): Boolean;       { Engine.TPropertyTable.PropertyExist }
var
  I: Integer;
begin
  Result := False;
  if ID > FMaxID then
    Exit;
  I := FFirst;
  while (I < FCount) and (FItems^[I].ID <> ID) do
    Inc(I);
  Result := I <> FCount;
end;

procedure TPropertyTable.BackupSettings;                           { Engine.TPropertyTable.BackupSettings }
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
  { the nested table starts where the current items end }
  FNextIndex := FCount;
  FFirst := FCount;
  FMaxID := 0;
end;

procedure TPropertyTable.RestoreSettings;                          { Engine.TPropertyTable.RestoreSettings }
begin
  Dec(FStackCount);
  FCount := FFirst;                                                { drop the nested table's items }
  with FStack^[FStackCount] do
  begin
    FFirst := First;
    FNextIndex := NextIndex;
    FMaxID := MaxID;
  end;
end;

procedure TPropertyTable.LoadFromStream(Stream: TStream);          { Engine.TPropertyTable.LoadFromStream }
var
  ShortCount: Byte;
  LongCount, I, ID, Offset: Integer;
  Pair: Word;
begin
  Stream.Read(ShortCount, 1);
  if (ShortCount and $80) = 0 then
    LongCount := 0
  else
  begin
    ShortCount := ShortCount and $7F;
    Stream.Read(LongCount, 4);
  end;
  for I := 1 to ShortCount do
  begin
    Stream.Read(Pair, 2);
    Add(Pair and $FF, Pair shr 8);
  end;
  for I := 1 to LongCount do
  begin
    Stream.Read(ID, 4);
    Stream.Read(Offset, 4);
    Add(ID, Offset);
  end;
end;

procedure TPropertyTable.SaveToStream(Stream: TStream);            { Engine.TPropertyTable.SaveToStream }
var
  LongCount, I: Integer;
  ShortCount, Marker: Byte;
  Pair: Word;
begin
  LongCount := 0;
  ShortCount := 0;
  for I := FFirst to FCount - 1 do
    if (FItems^[I].ID < $80) and (FItems^[I].Offset < $100) then
      Inc(ShortCount)
    else
      Inc(LongCount);
  if LongCount = 0 then
    Stream.Write(ShortCount, 1)
  else
  begin
    Marker := ShortCount or $80;
    Stream.Write(Marker, 1);
    Stream.Write(LongCount, 4);
  end;
  if ShortCount <> 0 then
    for I := FFirst to FCount - 1 do
      if (FItems^[I].ID < $80) and (FItems^[I].Offset < $100) then
      begin
        Pair := FItems^[I].ID + FItems^[I].Offset * $100;
        Stream.Write(Pair, 2);
      end;
  if LongCount <> 0 then
    for I := FFirst to FCount - 1 do
      if (FItems^[I].ID >= $80) or (FItems^[I].Offset >= $100) then
      begin
        Stream.Write(FItems^[I].ID, 4);
        Stream.Write(FItems^[I].Offset, 4);
      end;
end;

{ ---------------------------------------------------------------- TEStorageStream }

constructor TEStorageStream.Create(AStream: TStream; AEngine: TEngine);   { Engine.TEStorageStream.Create }
begin
  inherited Create;
  FEngine := AEngine;
  FStream := AStream;
  FErrorHandled := False;
end;

function TEStorageStream.OpenPropertyStream(ID: Integer): TStream;
begin
  Result := nil;
end;

procedure TEStorageStream.rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc); begin end;
procedure TEStorageStream.rwData(var Buffer; Size: Integer; ID: Integer); begin end;
procedure TEStorageStream.rwString(var S: string; ID: Integer); begin end;
procedure TEStorageStream.rwStrings(Strings: TStrings; ID: Integer); begin end;
procedure TEStorageStream.rwStringsEx(Strings: TStrings; ID: Integer); begin end;
procedure TEStorageStream.rwInteger(var I: Integer; ID: Integer); begin end;
procedure TEStorageStream.rwByte(var B: Byte; ID: Integer); begin end;
procedure TEStorageStream.rwWord(var W: Word; ID: Integer); begin end;
procedure TEStorageStream.rwBool(var B: Boolean; ID: Integer); begin end;
procedure TEStorageStream.rwShortint(var S: Shortint; ID: Integer); begin end;
procedure TEStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer); begin end;
procedure TEStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer); begin end;
procedure TEStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer); begin end;
procedure TEStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer); begin end;

procedure TEStorageStream.ShowProgress(Sender: TObject; const Msg: string; Percent: Integer);   { Engine.TEStorageStream.ShowProgress }
begin
  if Assigned(FOnProgress) then
    FOnProgress(Sender, Msg, Percent);
end;

{ ---------------------------------------------------------------- TEReadStorageStream }

constructor TEReadStorageStream.Create(AStream: TStream; APartial: Boolean; AEngine: TEngine);   { Engine.TEReadStorageStream.Create }
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

function TEReadStorageStream.StorageMode: Byte;                    { Engine.TEReadStorageStream.StorageMode }
begin
  if FPartial then
    Result := smRead or smPartial
  else
    Result := smRead;
end;

procedure TEReadStorageStream.SeekTo(Offset: Integer);
begin
  { every rw* method does this: seek only when the sequential read is not already there }
  if FStream.Position <> FDataBase + Offset then
    FStream.Position := FDataBase + Offset;
end;

function TEReadStorageStream.OpenPropertyStream(ID: Integer): TStream;   { Engine.TEReadStorageStream.OpenPropertyStream }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Result := nil
  else
  begin
    SeekTo(Offset);
    Result := FStream;
  end;
end;

procedure TEReadStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TEObject; ID: Integer);   { Engine.TEReadStorageStream.rwCreateEObject }
var
  Offset, SavedBase, AClassID: Integer;
begin
  Obj := nil;
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Exit;
  SeekTo(Offset);
  FStream.Read(AClassID, 4);
  if AClassID = 0 then
    Exit;
  SavedBase := FDataBase;
  FPropertyTable.BackupSettings;
  FPropertyTable.LoadFromStream(FStream);
  FDataBase := FStream.Position;
  try
    Obj := FEngine.CreateEObject(AClassID, nil);
    Inc(StorageStats.ObjectsRead);
    Obj.FOwner := AOwner;                      { set directly, SetOwner runs after the load }
    Obj.MainReadWrite(Self);
    Obj.FOwner := nil;
    Obj.SetOwner(AOwner);
  finally
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
  end;
end;

procedure TEReadStorageStream.rwEObject(Obj: TEObject; ID: Integer);   { Engine.TEReadStorageStream.rwEObject }
var
  Offset, SavedBase: Integer;
begin
  SavedBase := FDataBase;
  Offset := FPropertyTable.FindOffset(ID);
  FPropertyTable.BackupSettings;
  if Offset <> -1 then
  begin
    SeekTo(Offset);
    FPropertyTable.LoadFromStream(FStream);
    FDataBase := FStream.Position;
  end;
  try
    Obj.MainReadWrite(Self);
  finally
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
  end;
end;

procedure TEReadStorageStream.rwEObjectStream(Obj: TEObject);     { Engine.TEReadStorageStream.rwEObjectStream }
var
  Start, Size, SavedBase: Integer;
begin
  Start := FStream.Position;
  FStream.Read(Size, 4);
  if Size = 0 then
    Exit;
  SavedBase := FDataBase;
  FPropertyTable.BackupSettings;
  try
    FPropertyTable.LoadFromStream(FStream);
    FDataBase := FStream.Position;
    Obj.MainReadWrite(Self);
  finally
    FPropertyTable.RestoreSettings;
    FDataBase := SavedBase;
    FStream.Position := Start + Size + 4;
  end;
end;

procedure TEReadStorageStream.rwChildren(Node: TEObject; ID: Integer);   { Engine.TEReadStorageStream.rwChildren }
var
  Offset, SavedBase, I: Integer;
  Child: TEObject;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Exit;
  SavedBase := FDataBase;
  FPropertyTable.BackupSettings;
  SeekTo(Offset);
  FPropertyTable.LoadFromStream(FStream);
  FDataBase := FStream.Position;
  { every item of the nested table is one child, keyed by the id that was written }
  for I := FPropertyTable.First to FPropertyTable.Count - 1 do
  begin
    Inc(StorageStats.ChildrenRead);
    rwCreateEObject(Child, Node, FPropertyTable.Items^[I].ID);
    if Child <> nil then
      Child.FStoredIndex := FPropertyTable.Items^[I].ID;
    { the original also calls Node slot +$48 (SetArrayOwner) on each child when StorageMode has bit 8,
      and relies on rwCreateEObject's SetOwner to insert the child; node classes come later }
  end;
  FPropertyTable.RestoreSettings;
  FDataBase := SavedBase;
end;

procedure TEReadStorageStream.rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc);   { Engine.TEReadStorageStream.rwStreamProc }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Exit;
  SeekTo(Offset);
  LoadProc(FStream);
end;

procedure TEReadStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);   { Engine.TEReadStorageStream.rwData }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Exit;
  SeekTo(Offset);
  FStream.Read(Buffer, Size);
end;

procedure TEReadStorageStream.rwString(var S: string; ID: Integer);   { Engine.TEReadStorageStream.rwString }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    S := ''
  else
  begin
    SeekTo(Offset);
    ReadStringFromStream(S, FStream);
  end;
end;

procedure TEReadStorageStream.rwStrings(Strings: TStrings; ID: Integer);   { Engine.TEReadStorageStream.rwStrings }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Strings.Clear
  else
  begin
    SeekTo(Offset);
    StringsFromStream(Strings, FStream);
  end;
end;

procedure TEReadStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);   { Engine.TEReadStorageStream.rwStringsEx }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    Strings.Clear
  else
  begin
    SeekTo(Offset);
    { FUN_5550fa70: the "Ex" form reads the strings one by one; not translated yet }
    StringsFromStream(Strings, FStream);
  end;
end;

procedure TEReadStorageStream.rwInteger(var I: Integer; ID: Integer);   { Engine.TEReadStorageStream.rwInteger }
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    I := 0
  else
  begin
    SeekTo(Offset);
    FStream.Read(I, 4);
  end;
end;

procedure TEReadStorageStream.rwByte(var B: Byte; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    B := 0
  else
  begin
    SeekTo(Offset);
    FStream.Read(B, 1);
  end;
end;

procedure TEReadStorageStream.rwWord(var W: Word; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    W := 0
  else
  begin
    SeekTo(Offset);
    FStream.Read(W, 2);
  end;
end;

procedure TEReadStorageStream.rwBool(var B: Boolean; ID: Integer);   { Engine.TEReadStorageStream.rwBool: presence is the value }
begin
  B := FPropertyTable.FindOffset(ID) <> -1;
end;

procedure TEReadStorageStream.rwShortint(var S: Shortint; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    S := 0
  else
  begin
    SeekTo(Offset);
    FStream.Read(S, 1);
  end;
end;

procedure TEReadStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    I := Default
  else
  begin
    SeekTo(Offset);
    FStream.Read(I, 4);
  end;
end;

procedure TEReadStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    B := Default
  else
  begin
    SeekTo(Offset);
    FStream.Read(B, 1);
  end;
end;

procedure TEReadStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    W := Default
  else
  begin
    SeekTo(Offset);
    FStream.Read(W, 2);
  end;
end;

procedure TEReadStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
var
  Offset: Integer;
begin
  Offset := FPropertyTable.FindOffset(ID);
  if Offset = -1 then
    S := Default
  else
  begin
    SeekTo(Offset);
    FStream.Read(S, 1);
  end;
end;

function TEReadStorageStream.HandleException(E: Exception): Boolean;   { Engine.TEReadStorageStream.HandleException }
var
  ContinueLoading: Boolean;
begin
  { Result is True when the caller may continue. The first error asks OnError; once an error was
    not accepted, FErrorHandled stays set and every later error is reported as fatal. }
  if not FErrorHandled then
  begin
    ContinueLoading := True;
    if Assigned(FOnError) then
    begin
      if E.Message = '' then
        FOnError(Self, 'Error reading stream', ContinueLoading)   { EStreamReadErrorStr resource }
      else
        FOnError(Self, E.Message, ContinueLoading);
    end;
    if not ContinueLoading then
      FErrorHandled := True;
  end;
  Result := not FErrorHandled;
end;

{ ---------------------------------------------------------------- TEWriteStorageStream }

constructor TEWriteStorageStream.Create(AStream: TStream; APartial: Boolean; AEngine: TEngine);   { Engine.TEWriteStorageStream.Create }
begin
  inherited Create(AStream, AEngine);
  FBuffer := TMemoryStream.Create;
  FPropertyTable := TPropertyTable.Create;
  FPartial := APartial;
end;

destructor TEWriteStorageStream.Destroy;                           { Engine.TEWriteStorageStream.Destroy }
begin
  FPropertyTable.SaveToStream(FStream);
  FBuffer.Position := 0;
  FStream.CopyFrom(FBuffer, FBuffer.Size);
  FPropertyTable.Free;
  FBuffer.Free;
  inherited Destroy;
end;

function TEWriteStorageStream.StorageMode: Byte;                   { Engine.TEWriteStorageStream.StorageMode }
begin
  if FPartial then
    Result := smWrite or smPartial
  else
    Result := smWrite;
end;

procedure TEWriteStorageStream.PropertyExistError(ID: Integer);    { Engine.TEWriteStorageStream.PropertyExistError }
begin
  raise EDoublePriorityID.Create('PropertyID already in use (' + IntToStr(ID) + ') in ' + ClassName);
end;

procedure TEWriteStorageStream.CheckNew(ID: Integer);
begin
  if FPropertyTable.PropertyExist(ID) then
    PropertyExistError(ID);
end;

function TEWriteStorageStream.OpenPropertyStream(ID: Integer): TStream;   { Engine.TEWriteStorageStream.OpenPropertyStream }
begin
  CheckNew(ID);
  FPropertyTable.Add(ID, FBuffer.Position);
  Result := FBuffer;
end;

{ Shared body of rwEObject, rwCreateEObject and rwChildren: run the object in a fresh buffer and append
  [class id][table][data] (class id only for rwCreateEObject) to the outer buffer under ID. }
procedure TEWriteStorageStream.Nest(Obj: TEObject; ID: Integer; WriteClassID: Boolean);
var
  Outer: TMemoryStream;
  Start, AClassID: Integer;
begin
  Outer := FBuffer;
  Start := Outer.Position;
  if WriteClassID then
  begin
    if Obj = nil then
      AClassID := 0
    else
      AClassID := Obj.ClassID;
    if AClassID = 0 then
    begin
      Outer.Write(AClassID, 4);
      FPropertyTable.Add(ID, Start);
      Exit;
    end;
  end;
  FBuffer := TMemoryStream.Create;
  FPropertyTable.BackupSettings;
  try
    Inc(StorageStats.ObjectsWritten);
    Obj.MainReadWrite(Self);
    if WriteClassID then
      Outer.Write(AClassID, 4);
    FPropertyTable.SaveToStream(Outer);
    FBuffer.Position := 0;
    Outer.CopyFrom(FBuffer, FBuffer.Size);
  finally
    FBuffer.Free;
    FPropertyTable.RestoreSettings;
    FBuffer := Outer;
  end;
  FPropertyTable.Add(ID, Start);
end;

procedure TEWriteStorageStream.rwCreateEObject(var Obj: TEObject; AOwner: TEObject; ID: Integer);   { Engine.TEWriteStorageStream.rwCreateEObject }
begin
  if FPropertyTable.PropertyExist(ID) then
    raise EDoublePriorityID.Create('Double priorityID found (' + IntToStr(ID) + ')');
  Nest(Obj, ID, True);
end;

procedure TEWriteStorageStream.rwEObject(Obj: TEObject; ID: Integer);   { Engine.TEWriteStorageStream.rwEObject }
begin
  if FPropertyTable.PropertyExist(ID) then
    raise EDoublePriorityID.Create('Double priorityID found (' + IntToStr(ID) + ') for ' + Obj.ClassName);
  Nest(Obj, ID, False);
end;

procedure TEWriteStorageStream.rwEObjectStream(Obj: TEObject);     { Engine.TEWriteStorageStream.rwEObjectStream }
var
  Outer: TMemoryStream;
  Start, Len: Integer;
begin
  Outer := FBuffer;
  Start := Outer.Position;
  FBuffer := TMemoryStream.Create;
  FPropertyTable.BackupSettings;
  try
    Obj.MainReadWrite(Self);
    Len := 0;
    Outer.Write(Len, 4);
    FPropertyTable.SaveToStream(Outer);
    FBuffer.Position := 0;
    Outer.CopyFrom(FBuffer, FBuffer.Size);
    Len := Outer.Position - Start - 4;
    Outer.Position := Start;
    Outer.Write(Len, 4);
    Outer.Position := Start + Len + 4;
  finally
    FPropertyTable.RestoreSettings;
    FBuffer.Free;
    FBuffer := Outer;
  end;
end;

procedure TEWriteStorageStream.rwChildren(Node: TEObject; ID: Integer);   { Engine.TEWriteStorageStream.rwChildren }
var
  Outer: TMemoryStream;
  Start, I: Integer;
  N: TECustomNode;
  Child: TEObject;
begin
  if FPropertyTable.PropertyExist(ID) then
    raise EDoublePriorityID.Create('Double priorityID found (' + IntToStr(ID) + ')');
  N := Node as TECustomNode;
  Outer := FBuffer;
  Start := Outer.Position;
  FBuffer := TMemoryStream.Create;
  FPropertyTable.BackupSettings;
  try
    { every owned, stored, non-shared child goes under its index }
    for I := 0 to N.GetCount - 1 do
    begin
      Child := N.GetChild(I);
      if (Child <> nil) and (Child.FOwner = Node)
         and ((Child.GetControlStyle and csShared) = 0)
         and ((Child.GetControlStyle and csStored) <> 0) then
      begin
        Inc(StorageStats.ChildrenWritten);
        if Child.FStoredIndex >= 0 then
          rwCreateEObject(Child, Node, Child.FStoredIndex)   { model aid, see StoredIndex }
        else
          rwCreateEObject(Child, Node, I);
      end
      else
        Inc(StorageStats.ChildrenSkipped);
    end;
    FPropertyTable.SaveToStream(Outer);
    FBuffer.Position := 0;
    Outer.CopyFrom(FBuffer, FBuffer.Size);
  finally
    FBuffer.Free;
    FPropertyTable.RestoreSettings;
    FBuffer := Outer;
  end;
  FPropertyTable.Add(ID, Start);
end;

procedure TEWriteStorageStream.rwStreamProc(ID: Integer; LoadProc, SaveProc: TStreamProc);   { Engine.TEWriteStorageStream.rwStreamProc }
begin
  CheckNew(ID);
  FPropertyTable.Add(ID, FBuffer.Position);
  SaveProc(FBuffer);
end;

procedure TEWriteStorageStream.rwData(var Buffer; Size: Integer; ID: Integer);   { Engine.TEWriteStorageStream.rwData }
begin
  CheckNew(ID);
  if Size <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(Buffer, Size);
  end;
end;

procedure TEWriteStorageStream.rwString(var S: string; ID: Integer);   { Engine.TEWriteStorageStream.rwString }
begin
  CheckNew(ID);
  if S <> '' then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    WriteStringToStream(S, FBuffer);
  end;
end;

procedure TEWriteStorageStream.rwStrings(Strings: TStrings; ID: Integer);   { Engine.TEWriteStorageStream.rwStrings }
begin
  CheckNew(ID);
  if Strings.Count <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    StringsToStream(Strings, FBuffer);
  end;
end;

procedure TEWriteStorageStream.rwStringsEx(Strings: TStrings; ID: Integer);
begin
  CheckNew(ID);
  if Strings.Count <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    StringsToStream(Strings, FBuffer);        { FUN_5550f9b4 also writes the Objects; not translated yet }
  end;
end;

procedure TEWriteStorageStream.rwInteger(var I: Integer; ID: Integer);   { Engine.TEWriteStorageStream.rwInteger }
begin
  CheckNew(ID);
  if I <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(I, 4);
  end;
end;

procedure TEWriteStorageStream.rwByte(var B: Byte; ID: Integer);
begin
  CheckNew(ID);
  if B <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(B, 1);
  end;
end;

procedure TEWriteStorageStream.rwWord(var W: Word; ID: Integer);
begin
  CheckNew(ID);
  if W <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(W, 2);
  end;
end;

procedure TEWriteStorageStream.rwBool(var B: Boolean; ID: Integer);   { Engine.TEWriteStorageStream.rwBool: only the id is stored }
begin
  CheckNew(ID);
  if B then
    FPropertyTable.Add(ID, FBuffer.Position);
end;

procedure TEWriteStorageStream.rwShortint(var S: Shortint; ID: Integer);
begin
  CheckNew(ID);
  if S <> 0 then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(S, 1);
  end;
end;

procedure TEWriteStorageStream.rwIntegerEx(var I: Integer; Default: Integer; ID: Integer);
begin
  CheckNew(ID);
  if I <> Default then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(I, 4);
  end;
end;

procedure TEWriteStorageStream.rwByteEx(var B: Byte; Default: Byte; ID: Integer);
begin
  CheckNew(ID);
  if B <> Default then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(B, 1);
  end;
end;

procedure TEWriteStorageStream.rwWordEx(var W: Word; Default: Word; ID: Integer);
begin
  CheckNew(ID);
  if W <> Default then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(W, 2);
  end;
end;

procedure TEWriteStorageStream.rwShortintEx(var S: Shortint; Default: Shortint; ID: Integer);
begin
  CheckNew(ID);
  if S <> Default then
  begin
    FPropertyTable.Add(ID, FBuffer.Position);
    FBuffer.Write(S, 1);
  end;
end;

{ ---------------------------------------------------------------- TCompressStream }

procedure TCompressStream.LoadFromStream(Stream: TStream);         { Engine.TCompressStream.LoadFromStream }
var
  ID: array[0..3] of AnsiChar;
  Version: Byte;
  Decompressor: TDecompressionStream;
  Buffer: Pointer;
  N: Integer;
const
  BufferSize = $1FA0;
begin
  Stream.Read(ID, 4);
  Stream.Read(Version, 1);
  if ID <> CompressStreamID then
  begin
    { not a CFS file: take the whole stream as it is }
    Version := 0;
    Stream.Position := 0;
  end;
  Clear;
  if Version = 0 then
    CopyFrom(Stream, Stream.Size - Stream.Position)
  else
  begin
    GetMem(Buffer, BufferSize);
    try
      Decompressor := TDecompressionStream.Create(Stream);
      try
        repeat
          N := Decompressor.Read(Buffer^, BufferSize);
          if N > 0 then
            WriteBuffer(Buffer^, N);
        until N = 0;
      finally
        Decompressor.Free;
      end;
    finally
      FreeMem(Buffer);
    end;
  end;
  Position := 0;
end;

procedure TCompressStream.LoadFromFile(const FileName: string);    { Engine.TCompressStream.LoadFromFile }
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

procedure TCompressStream.SaveToStreamEx(Stream: TStream; Version: Byte);   { Engine.TCompressStream.SaveToStreamEx }
var
  Compressor: TCompressionStream;
begin
  Stream.Write(CompressStreamID, 4);
  Stream.Write(Version, 1);
  if Version = 0 then
    Stream.CopyFrom(Self, 0)
  else
  begin
    Compressor := TCompressionStream.Create(clDefault, Stream);
    try
      Compressor.WriteBuffer(Memory^, Size);
    finally
      Compressor.Free;
    end;
  end;
end;

procedure TCompressStream.SaveToStream(Stream: TStream);           { Engine.TCompressStream.SaveToStream: version 2 }
begin
  SaveToStreamEx(Stream, 2);
end;

end.
