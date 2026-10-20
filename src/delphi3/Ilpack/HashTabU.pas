unit HashTabU;

{ The HashTabU unit of Ilpack.dpl: the hash list and hash table classes, an older copy of the
  ones the Engine unit includes from inc\HashTab.PAS (Enginep.dpl). This version has no Assert
  calls, and TIntegerHashTable256 has neither DeleteSafe nor GetFreeID. }

interface

uses
  SysUtils;

type
  { HashTabU.THashList (instance size 16): +4 FCount, +8 FCapacity, +$C FItems }
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

  { HashTabU.TIntegerHashList (instance size 16): items keyed by an integer }
  TIntegerHashList = class(THashList)
  public
    procedure Add(Item: Pointer; Key: Integer);
    procedure Delete(Key: Integer);
    function Find(Key: Integer): Pointer;
  end;

  { HashTabU.TIntegerHashTable (instance size 4): the abstract table interface }
  TIntegerHashTable = class(TObject)
  public
    procedure Add(Item: Pointer; Key: Integer); virtual; abstract;
    procedure Delete(Key: Integer); virtual; abstract;
    function Find(Key: Integer): Pointer; virtual; abstract;
    procedure Clear; virtual; abstract;
  end;

  { HashTabU.TIntegerHashTable256 (instance size 1028): 256 lists selected by the low key byte }
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
  end;

  { HashTabU.TStringHashList (instance size 16): THashList items whose key dword is a string }
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

  { HashTabU.TStringHashTable (instance size 4): the abstract table interface }
  TStringHashTable = class(TObject)
  public
    procedure Add(Item: Pointer; const Key: string); virtual; abstract;
    procedure Delete(const Key: string); virtual; abstract;
    function Find(const Key: string): Pointer; virtual; abstract;
    procedure Clear; virtual; abstract;
  end;

  { HashTabU.TStringHashTable256 (instance size 1028): 256 lists selected by a hash of the first
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

implementation

{ THashList }

destructor THashList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure THashList.Clear;
begin
  FCount := 0;
  SetCapacity(0);
end;

procedure THashList.SetCapacity(NewCapacity: Integer);
begin
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FItems, NewCapacity * SizeOf(THashItem));
    FCapacity := NewCapacity;
  end;
end;

procedure THashList.Delete(Index: Integer);
begin
  Dec(FCount);
  if Index < FCount then
    Move(FItems^[Index + 1], FItems^[Index], (FCount - Index) * SizeOf(THashItem));
end;

procedure THashList.Add(Item: THashItem);
begin
  if FCapacity = FCount then SetCapacity(FCapacity + 16);
  FItems^[FCount] := Item;
  Inc(FCount);
end;

{ TIntegerHashList }

procedure TIntegerHashList.Add(Item: Pointer; Key: Integer);
var
  H: THashItem;
begin
  if Find(Key) <> nil then raise Exception.Create('ID already in HashTable');
  H.Key := Key;
  H.Item := Item;
  inherited Add(H);
end;

procedure TIntegerHashList.Delete(Key: Integer);
var
  I: Integer;
begin
  I := FCount;
  if I <> 0 then
    repeat
      Dec(I);
      if Key = FItems^[I].Key then
      begin
        inherited Delete(I);
        Exit;
      end;
    until I = 0;
end;

function TIntegerHashList.Find(Key: Integer): Pointer;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do
    if Key = FItems^[I].Key then
    begin
      Result := FItems^[I].Item;
      Exit;
    end;
  Result := nil;
end;

{ TIntegerHashTable256 }

constructor TIntegerHashTable256.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := 0 to 255 do FLists[I] := TIntegerHashList.Create;
end;

destructor TIntegerHashTable256.Destroy;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Free;
  inherited Destroy;
end;

procedure TIntegerHashTable256.Clear;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Clear;
end;

procedure TIntegerHashTable256.Add(Item: Pointer; Key: Integer);
begin
  FLists[Key and $FF].Add(Item, Key);
end;

procedure TIntegerHashTable256.Delete(Key: Integer);
begin
  FLists[Key and $FF].Delete(Key);
end;

function TIntegerHashTable256.Find(Key: Integer): Pointer;
begin
  Result := FLists[Key and $FF].Find(Key);
end;

{ TStringHashList }

procedure TStringHashList.Clear;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do PStringHashItem(@FItems^[I])^.Key := '';
  inherited Clear;
end;

function TStringHashList.Find(const Key: string): Pointer;
var
  I: Integer;
begin
  Result := nil;
  I := FCount;
  if I <> 0 then
    repeat
      Dec(I);
      if AnsiCompareStr(PStringHashItem(@FItems^[I])^.Key, Key) = 0 then
      begin
        Result := FItems^[I].Item;
        Exit;
      end;
    until I = 0;
end;

procedure TStringHashList.Add(Item: Pointer; const Key: string);
var
  H: THashItem;
begin
  if Find(Key) <> nil then raise Exception.Create('ID already in HashTable');
  H.Key := 0;
  H.Item := Item;
  string(H.Key) := Key;
  inherited Add(H);
end;

procedure TStringHashList.Delete(const Key: string);
var
  I: Integer;
begin
  I := FCount;
  if I <> 0 then
    repeat
      Dec(I);
      if AnsiCompareStr(PStringHashItem(@FItems^[I])^.Key, Key) = 0 then
      begin
        PStringHashItem(@FItems^[I])^.Key := '';
        inherited Delete(I);
        Exit;
      end;
    until I = 0;
end;

{ TStringHashTable256 }

constructor TStringHashTable256.Create;
var
  I: Integer;
begin
  inherited Create;
  for I := 0 to 255 do FLists[I] := TStringHashList.Create;
end;

destructor TStringHashTable256.Destroy;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Free;
  inherited Destroy;
end;

procedure TStringHashTable256.Clear;
var
  I: Integer;
begin
  for I := 0 to 255 do FLists[I].Clear;
end;

procedure TStringHashTable256.Add(Item: Pointer; const Key: string);
var
  H: Integer;
begin
  H := Length(Key);
  if H >= 2 then
    H := (Ord(Key[1]) + Ord(Key[H - 1]) + H shl 4) and $FF
  else if H = 1 then
    H := Ord(Key[1]);
  FLists[H].Add(Item, Key);
end;

procedure TStringHashTable256.Delete(const Key: string);
var
  H: Integer;
begin
  H := Length(Key);
  if H >= 2 then
    H := (Ord(Key[1]) + Ord(Key[H - 1]) + H shl 4) and $FF
  else if H = 1 then
    H := Ord(Key[1]);
  FLists[H].Delete(Key);
end;

function TStringHashTable256.Find(const Key: string): Pointer;
var
  H: Integer;
begin
  H := Length(Key);
  if H >= 2 then
    H := (Ord(Key[1]) + Ord(Key[H - 1]) + H shl 4) and $FF
  else if H = 1 then
    H := Ord(Key[1]);
  Result := FLists[H].Find(Key);
end;

end.
