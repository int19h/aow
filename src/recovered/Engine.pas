unit Engine;

{ Recovered from Enginep.dpl (Age of Wonders 1.36, Delphi 3), persistence part of the Engine unit.

  Sources: notes/decomp/Enginep-typed-all (Ghidra, typed), notes/persistence.md.
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

type
  TEStorageStream = class;
  TEngine = class;

  { Engine.TEObject (instance size 8): +4 FOwner. ClassVersion/ClassID/ReadWrite/MainReadWrite are the
    virtual slots that persistence uses; the rest of the class is left for later. }
  TEObject = class(TObject)
  private
    FOwner: TEObject;                          { +$04 }
  public
    constructor Create(AOwner: TEObject); virtual;
    function ClassVersion: Integer; virtual;   { slot +$00 }
    procedure SetOwner(AOwner: TEObject); virtual;   { slot +$08 }
    procedure ReadWrite(Stream: TEStorageStream); virtual;        { slot +$18 }
    procedure MainReadWrite(Stream: TEStorageStream); virtual;    { slot +$1C }
    function ClassID: Integer; virtual;        { slot +$24 }
    procedure Clear; virtual;                  { slot +$30 }
    property Owner: TEObject read FOwner write SetOwner;
  end;

  TEObjectClass = class of TEObject;

  { The part of Engine.TEngine that the storage stream needs: creating an object from its class id. }
  TEngine = class(TEObject)
  public
    function CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject; virtual;   { slot +$90 }
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

constructor TEObject.Create(AOwner: TEObject);
begin
  inherited Create;
  FOwner := AOwner;
end;

function TEObject.ClassVersion: Integer;
begin
  Result := 0;
end;

procedure TEObject.SetOwner(AOwner: TEObject);
begin
  FOwner := AOwner;
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

function TEngine.CreateEObject(AClassID: Integer; AOwner: TEObject): TEObject;
begin
  Result := nil;
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
    rwCreateEObject(Child, Node, FPropertyTable.Items^[I].ID);
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
