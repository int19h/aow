unit EngineLists;

{ Engine value lists written for the original compiler (Delphi 3.02): tools/match.py compares the
  code DCC32 generates for every method with the code in Enginep.dpl. Each list is Classes.TList
  adapted to a value type, with a default value for new and out-of-range items and a run-length
  encoded stream form. Same field order and types as the original (instance size 20). }

interface

uses
  SysUtils, Classes, Consts;

const
  MaxListSize = Maxint div 16;

type
  PIntegerArray = ^TIntegerArray;
  TIntegerArray = array[0..MaxListSize - 1] of Integer;
  TIntegerSortCompare = function(Item1, Item2: Integer): Integer;

  TIntegerList = class(TPersistent)
  private
    FList: PIntegerArray;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: Integer;
    function Get(Index: Integer): Integer;
    procedure Put(Index: Integer; Item: Integer);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function GetItemString: string;
    procedure SetItemString(S: string);
  protected
    procedure Grow; virtual;
    class procedure Error(const Msg: string; Data: Integer); virtual;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: Integer): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TIntegerList;
    function First: Integer;
    function IndexOf(Item: Integer): Integer;
    procedure Insert(Index: Integer; Item: Integer);
    function Last: Integer;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Integer): Integer;
    procedure Pack;
    procedure Sort(Compare: TIntegerSortCompare);
    function Compare(List: TIntegerList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function RandomChanceItem(Bonus: Integer): Integer;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Default: Integer read FDefault write FDefault;
    property Items[Index: Integer]: Integer read Get write Put; default;
    property ItemString: string read GetItemString write SetItemString;
    property List: PIntegerArray read FList;
  end;

  PByteArray = ^TByteArray;
  TByteArray = array[0..MaxListSize - 1] of Byte;
  TByteSortCompare = function(Item1, Item2: Byte): Integer;

  TByteList = class(TPersistent)
  private
    FList: PByteArray;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: Byte;
    function Get(Index: Integer): Byte;
    procedure Put(Index: Integer; Item: Byte);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function GetItemString: string;
    procedure SetItemString(S: string);
  protected
    procedure Grow; virtual;
    class procedure Error(const Msg: string; Data: Integer); virtual;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: Byte): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TByteList;
    function First: Byte;
    function IndexOf(Item: Byte): Integer;
    procedure Insert(Index: Integer; Item: Byte);
    function Last: Byte;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Byte): Integer;
    procedure Pack;
    procedure Sort(Compare: TByteSortCompare);
    function Compare(List: TByteList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function RandomChanceItem(Bonus: Integer): Integer;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Default: Byte read FDefault write FDefault;
    property Items[Index: Integer]: Byte read Get write Put; default;
    property ItemString: string read GetItemString write SetItemString;
    property List: PByteArray read FList;
  end;

  PShortIntArray = ^TShortIntArray;
  TShortIntArray = array[0..MaxListSize - 1] of ShortInt;
  TShortIntSortCompare = function(Item1, Item2: ShortInt): Integer;

  TShortIntList = class(TPersistent)
  private
    FList: PShortIntArray;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: ShortInt;
    function Get(Index: Integer): ShortInt;
    procedure Put(Index: Integer; Item: ShortInt);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  protected
    procedure Grow; virtual;
    class procedure Error(const Msg: string; Data: Integer); virtual;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: ShortInt): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TShortIntList;
    function First: ShortInt;
    function IndexOf(Item: ShortInt): Integer;
    procedure Insert(Index: Integer; Item: ShortInt);
    function Last: ShortInt;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: ShortInt): Integer;
    procedure Pack;
    procedure Sort(Compare: TShortIntSortCompare);
    function Compare(List: TShortIntList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function RandomChanceItem(Bonus: Integer): Integer;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Default: ShortInt read FDefault write FDefault;
    property Items[Index: Integer]: ShortInt read Get write Put; default;
    property List: PShortIntArray read FList;
  end;

  PWordArray = ^TWordArray;
  TWordArray = array[0..MaxListSize - 1] of Word;
  TWordSortCompare = function(Item1, Item2: Word): Integer;

  TWordList = class(TPersistent)
  private
    FList: PWordArray;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: Word;
    function Get(Index: Integer): Word;
    procedure Put(Index: Integer; Item: Word);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  protected
    procedure Grow; virtual;
    class procedure Error(const Msg: string; Data: Integer); virtual;
  public
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add(Item: Word): Integer;
    procedure Clear;
    procedure Delete(Index: Integer);
    procedure Exchange(Index1, Index2: Integer);
    function Expand: TWordList;
    function First: Word;
    function IndexOf(Item: Word): Integer;
    procedure Insert(Index: Integer; Item: Word);
    function Last: Word;
    procedure Move(CurIndex, NewIndex: Integer);
    function Remove(Item: Word): Integer;
    procedure Pack;
    procedure Sort(Compare: TWordSortCompare);
    function Compare(List: TWordList): Boolean;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    function RandomChanceItem(Bonus: Integer): Integer;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Count: Integer read FCount write SetCount;
    property Default: Word read FDefault write FDefault;
    property Items[Index: Integer]: Word read Get write Put; default;
    property List: PWordArray read FList;
  end;

procedure FillInteger(var Buf; Count, Value: Integer);
procedure FillWord(var Buf; Count: Integer; Value: Word);

implementation

procedure FillInteger(var Buf; Count, Value: Integer);
asm
        PUSH    EDI
        MOV     EDI,EAX
        MOV     EAX,ECX
        MOV     ECX,EDX
        REP     STOSD
        POP     EDI
end;

procedure FillWord(var Buf; Count: Integer; Value: Word);
asm
        PUSH    EDI
        MOV     EDI,EAX
        MOV     EAX,ECX
        MOV     ECX,EDX
        REP     STOSW
        POP     EDI
end;

{ TIntegerList }

destructor TIntegerList.Destroy;
begin
  Clear;
end;

procedure TIntegerList.Assign(Source: TPersistent);
begin
  if Source is TIntegerList then
    with TIntegerList(Source) do
    begin
      Self.FCount := FCount;
      Self.SetCapacity(FCount);
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(Integer));
      Self.FDefault := FDefault;
    end
  else
    inherited Assign(Source);
end;

function TIntegerList.Add(Item: Integer): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TIntegerList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TIntegerList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Integer));
end;

class procedure TIntegerList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TIntegerList.Exchange(Index1, Index2: Integer);
var
  Item: Integer;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TIntegerList.Expand: TIntegerList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TIntegerList.First: Integer;
begin
  Result := Get(0);
end;

function TIntegerList.Get(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := FDefault
  else
    Result := FList^[Index];
end;

procedure TIntegerList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TIntegerList.IndexOf(Item: Integer): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TIntegerList.Insert(Index: Integer; Item: Integer);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Integer));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TIntegerList.Last: Integer;
begin
  Result := Get(FCount - 1);
end;

procedure TIntegerList.Move(CurIndex, NewIndex: Integer);
var
  Item: Integer;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

procedure TIntegerList.Put(Index: Integer; Item: Integer);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TIntegerList.Remove(Item: Integer): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TIntegerList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do if Items[I] = FDefault then Delete(I);
end;

procedure TIntegerList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Integer));
    FCapacity := NewCapacity;
  end;
end;

procedure TIntegerList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillInteger(FList^[FCount], NewCount - FCount, FDefault);
  FCount := NewCount;
end;

procedure QuickSortInteger(SortList: PIntegerArray; L, R: Integer;
  SCompare: TIntegerSortCompare);
var
  I, J: Integer;
  P, T: Integer;
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
    if L < J then QuickSortInteger(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TIntegerList.Sort(Compare: TIntegerSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSortInteger(FList, 0, Count - 1, Compare);
end;

function TIntegerList.Compare(List: TIntegerList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then
    Result := CompareMem(FList, List.FList, FCount * SizeOf(Integer));
end;

procedure TIntegerList.LoadFromStream(Stream: TStream);
var
  Count, Item, Run: Integer;
begin
  Clear;
  Stream.Read(FDefault, SizeOf(Integer));
  Stream.Read(Count, SizeOf(Integer));
  SetCapacity(Count);
  while Count <> FCount do
  begin
    Stream.Read(Item, SizeOf(Integer));
    if Item = FDefault then
    begin
      Stream.Read(Run, SizeOf(Integer));
      SetCount(FCount + Run);
    end
    else
      Add(Item);
  end;
end;

procedure TIntegerList.SaveToStream(Stream: TStream);
var
  I, Run: Integer;

  function DefaultRun: Integer;
  var
    J: Integer;
  begin
    Result := 0;
    J := I;
    while (J < FCount) and (FList^[J] = FDefault) do
    begin
      Inc(Result);
      Inc(J);
    end;
  end;

begin
  I := 0;
  Stream.Write(FDefault, SizeOf(Integer));
  Stream.Write(FCount, SizeOf(Integer));
  while FCount <> I do
  begin
    Run := DefaultRun;
    if Run > 0 then
    begin
      Stream.Write(FDefault, SizeOf(Integer));
      Stream.Write(Run, SizeOf(Integer));
      Inc(I, Run);
    end
    else
    begin
      Stream.Write(FList^[I], SizeOf(Integer));
      Inc(I);
    end;
  end;
end;

function TIntegerList.GetItemString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FCount - 1 do
    Result := Result + IntToStr(FList^[I]) + ',';
  if Result <> '' then
    Result := Copy(Result, 1, Length(Result) - 1);
end;

procedure TIntegerList.SetItemString(S: string);
var
  Item: string;
  P, V: Integer;
begin
  Clear;
  P := Pos(',', S);
  while S <> '' do
  begin
    if P <> 0 then
    begin
      Item := Copy(S, 1, P - 1);
      System.Delete(S, 1, P);
    end
    else
    begin
      Item := S;
      S := '';
    end;
    if Item <> '' then V := StrToInt(Item) else V := 0;
    Add(V);
    P := Pos(',', S);
  end;
end;

function TIntegerList.RandomChanceItem(Bonus: Integer): Integer;
var
  I, Total, Chance, R: Integer;
begin
  if FCount <> 0 then
  begin
    Total := 0;
    for I := FCount - 1 downto 0 do
    begin
      Chance := FList^[I] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
    end;
    R := Random(Total);
    Total := 0;
    Result := 0;
    while Total < R do
    begin
      Chance := FList^[Result] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
      Inc(Result);
    end;
  end
  else
    Result := -1;
end;

{ TByteList }

destructor TByteList.Destroy;
begin
  Clear;
end;

procedure TByteList.Assign(Source: TPersistent);
begin
  if Source is TByteList then
    with TByteList(Source) do
    begin
      Self.FCount := FCount;
      Self.SetCapacity(FCount);
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(Byte));
      Self.FDefault := FDefault;
    end
  else
    inherited Assign(Source);
end;

function TByteList.Add(Item: Byte): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TByteList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TByteList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Byte));
end;

class procedure TByteList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TByteList.Exchange(Index1, Index2: Integer);
var
  Item: Byte;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TByteList.Expand: TByteList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TByteList.First: Byte;
begin
  Result := Get(0);
end;

function TByteList.Get(Index: Integer): Byte;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := FDefault
  else
    Result := FList^[Index];
end;

procedure TByteList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TByteList.IndexOf(Item: Byte): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TByteList.Insert(Index: Integer; Item: Byte);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Byte));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TByteList.Last: Byte;
begin
  Result := Get(FCount - 1);
end;

procedure TByteList.Move(CurIndex, NewIndex: Integer);
var
  Item: Byte;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

procedure TByteList.Put(Index: Integer; Item: Byte);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TByteList.Remove(Item: Byte): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TByteList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do if Items[I] = FDefault then Delete(I);
end;

procedure TByteList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Byte));
    FCapacity := NewCapacity;
  end;
end;

procedure TByteList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], NewCount - FCount, FDefault);
  FCount := NewCount;
end;

procedure QuickSortByte(SortList: PByteArray; L, R: Integer;
  SCompare: TByteSortCompare);
var
  I, J: Integer;
  P, T: Byte;
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
    if L < J then QuickSortByte(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TByteList.Sort(Compare: TByteSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSortByte(FList, 0, Count - 1, Compare);
end;

function TByteList.Compare(List: TByteList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then
    Result := CompareMem(FList, List.FList, FCount * SizeOf(Byte));
end;

procedure TByteList.LoadFromStream(Stream: TStream);
var
  Item, Run: Byte;
  Count: Integer;
begin
  Clear;
  Stream.Read(FDefault, SizeOf(Byte));
  Stream.Read(Count, SizeOf(Integer));
  SetCapacity(Count);
  while FCount < Count do
  begin
    Stream.Read(Item, SizeOf(Byte));
    if Item = FDefault then
    begin
      Stream.Read(Run, SizeOf(Byte));
      SetCount(FCount + Run);
    end
    else
      Add(Item);
  end;
end;

procedure TByteList.SaveToStream(Stream: TStream);
var
  I, Run: Integer;
  B: Byte;

  function DefaultRun: Integer;
  var
    J: Integer;
  begin
    Result := 0;
    J := I;
    while (J < FCount) and (FList^[J] = FDefault) do
    begin
      Inc(Result);
      Inc(J);
    end;
  end;

begin
  I := 0;
  Stream.Write(FDefault, SizeOf(Byte));
  Stream.Write(FCount, SizeOf(Integer));
  while FCount <> I do
  begin
    Run := DefaultRun;
    if Run > 0 then
    begin
      while Run > High(Byte) do
      begin
        B := High(Byte);
        Stream.Write(FDefault, SizeOf(Byte));
        Stream.Write(B, SizeOf(Byte));
        Dec(Run, High(Byte));
        Inc(I, High(Byte));
      end;
      B := Run;
      Stream.Write(FDefault, SizeOf(Byte));
      Stream.Write(B, SizeOf(Byte));
      Inc(I, Run);
    end
    else
    begin
      Stream.Write(FList^[I], SizeOf(Byte));
      Inc(I);
    end;
  end;
end;

function TByteList.GetItemString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FCount - 1 do
    Result := Result + IntToStr(FList^[I]) + ',';
  if Result <> '' then
    Result := Copy(Result, 1, Length(Result) - 1);
end;

procedure TByteList.SetItemString(S: string);
var
  Item: string;
  P, V: Integer;
begin
  Clear;
  P := Pos(',', S);
  while S <> '' do
  begin
    if P <> 0 then
    begin
      Item := Copy(S, 1, P - 1);
      System.Delete(S, 1, P);
    end
    else
    begin
      Item := S;
      S := '';
    end;
    if Item <> '' then V := StrToInt(Item) else V := 0;
    if V > High(Byte) then V := 0;
    Add(V);
    P := Pos(',', S);
  end;
end;

function TByteList.RandomChanceItem(Bonus: Integer): Integer;
var
  I, Total, Chance, R: Integer;
begin
  if FCount <> 0 then
  begin
    Total := 0;
    for I := FCount - 1 downto 0 do
    begin
      Chance := FList^[I] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
    end;
    R := Random(Total);
    Total := 0;
    Result := 0;
    while Total < R do
    begin
      Chance := FList^[Result] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
      Inc(Result);
    end;
  end
  else
    Result := -1;
end;

{ TShortIntList }

destructor TShortIntList.Destroy;
begin
  Clear;
end;

procedure TShortIntList.Assign(Source: TPersistent);
begin
  if Source is TShortIntList then
    with TShortIntList(Source) do
    begin
      Self.FCount := FCount;
      Self.SetCapacity(FCount);
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(ShortInt));
      Self.FDefault := FDefault;
    end
  else
    inherited Assign(Source);
end;

function TShortIntList.Add(Item: ShortInt): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TShortIntList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TShortIntList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(ShortInt));
end;

class procedure TShortIntList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TShortIntList.Exchange(Index1, Index2: Integer);
var
  Item: ShortInt;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TShortIntList.Expand: TShortIntList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TShortIntList.First: ShortInt;
begin
  Result := Get(0);
end;

function TShortIntList.Get(Index: Integer): ShortInt;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := FDefault
  else
    Result := FList^[Index];
end;

procedure TShortIntList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TShortIntList.IndexOf(Item: ShortInt): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TShortIntList.Insert(Index: Integer; Item: ShortInt);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(ShortInt));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TShortIntList.Last: ShortInt;
begin
  Result := Get(FCount - 1);
end;

procedure TShortIntList.Move(CurIndex, NewIndex: Integer);
var
  Item: ShortInt;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

procedure TShortIntList.Put(Index: Integer; Item: ShortInt);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TShortIntList.Remove(Item: ShortInt): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TShortIntList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do if Items[I] = FDefault then Delete(I);
end;

procedure TShortIntList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(ShortInt));
    FCapacity := NewCapacity;
  end;
end;

procedure TShortIntList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar(FList^[FCount], NewCount - FCount, FDefault);
  FCount := NewCount;
end;

procedure QuickSortShortInt(SortList: PShortIntArray; L, R: Integer;
  SCompare: TShortIntSortCompare);
var
  I, J: Integer;
  P, T: ShortInt;
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
    if L < J then QuickSortShortInt(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TShortIntList.Sort(Compare: TShortIntSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSortShortInt(FList, 0, Count - 1, Compare);
end;

function TShortIntList.Compare(List: TShortIntList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then
    Result := CompareMem(FList, List.FList, FCount * SizeOf(ShortInt));
end;

procedure TShortIntList.LoadFromStream(Stream: TStream);
var
  Run: Byte;
  Item: ShortInt;
  Count: Integer;
begin
  Clear;
  Stream.Read(FDefault, SizeOf(ShortInt));
  Stream.Read(Count, SizeOf(Integer));
  SetCapacity(Count);
  while FCount < Count do
  begin
    Stream.Read(Item, SizeOf(ShortInt));
    if Item = FDefault then
    begin
      Stream.Read(Run, SizeOf(Byte));
      SetCount(FCount + Run);
    end
    else
      Add(Item);
  end;
end;

procedure TShortIntList.SaveToStream(Stream: TStream);
var
  I, Run: Integer;
  B: Byte;

  function DefaultRun: Integer;
  var
    J: Integer;
  begin
    Result := 0;
    J := I;
    while (J < FCount) and (FList^[J] = FDefault) do
    begin
      Inc(Result);
      Inc(J);
    end;
  end;

begin
  I := 0;
  Stream.Write(FDefault, SizeOf(ShortInt));
  Stream.Write(FCount, SizeOf(Integer));
  while FCount <> I do
  begin
    Run := DefaultRun;
    if Run > 0 then
    begin
      while Run > High(Byte) do
      begin
        B := High(Byte);
        Stream.Write(FDefault, SizeOf(ShortInt));
        Stream.Write(B, SizeOf(Byte));
        Dec(Run, High(Byte));
        Inc(I, High(Byte));
      end;
      B := Run;
      Stream.Write(FDefault, SizeOf(ShortInt));
      Stream.Write(B, SizeOf(Byte));
      Inc(I, Run);
    end
    else
    begin
      Stream.Write(FList^[I], SizeOf(ShortInt));
      Inc(I);
    end;
  end;
end;

function TShortIntList.RandomChanceItem(Bonus: Integer): Integer;
var
  I, Total, Chance, R: Integer;
begin
  if FCount <> 0 then
  begin
    Total := 0;
    for I := FCount - 1 downto 0 do
    begin
      Chance := FList^[I] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
    end;
    R := Random(Total);
    Total := 0;
    Result := 0;
    while Total < R do
    begin
      Chance := FList^[Result] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
      Inc(Result);
    end;
  end
  else
    Result := -1;
end;

{ TWordList }

destructor TWordList.Destroy;
begin
  Clear;
end;

procedure TWordList.Assign(Source: TPersistent);
begin
  if Source is TWordList then
    with TWordList(Source) do
    begin
      Self.FCount := FCount;
      Self.SetCapacity(FCount);
      System.Move(FList^, Self.FList^, Self.FCount * SizeOf(Word));
      Self.FDefault := FDefault;
    end
  else
    inherited Assign(Source);
end;

function TWordList.Add(Item: Word): Integer;
begin
  Result := FCount;
  if Result = FCapacity then Grow;
  FList^[Result] := Item;
  Inc(FCount);
end;

procedure TWordList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TWordList.Delete(Index: Integer);
begin
  if (Index < 0) or (Index >= FCount) then Error(SListIndexError, Index);
  Dec(FCount);
  if Index < FCount then
    System.Move(FList^[Index + 1], FList^[Index],
      (FCount - Index) * SizeOf(Word));
end;

class procedure TWordList.Error(const Msg: string; Data: Integer);

  function ReturnAddr: Pointer;
  asm
          MOV     EAX,[EBP+4]
  end;

begin
  raise EListError.CreateFmt(Msg, [Data]) at ReturnAddr;
end;

procedure TWordList.Exchange(Index1, Index2: Integer);
var
  Item: Word;
begin
  if (Index1 < 0) or (Index1 >= FCount) then Error(SListIndexError, Index1);
  if (Index2 < 0) or (Index2 >= FCount) then Error(SListIndexError, Index2);
  Item := FList^[Index1];
  FList^[Index1] := FList^[Index2];
  FList^[Index2] := Item;
end;

function TWordList.Expand: TWordList;
begin
  if FCount = FCapacity then Grow;
  Result := Self;
end;

function TWordList.First: Word;
begin
  Result := Get(0);
end;

function TWordList.Get(Index: Integer): Word;
begin
  if (Index < 0) or (Index >= FCount) then
    Result := FDefault
  else
    Result := FList^[Index];
end;

procedure TWordList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4 else
    if FCapacity > 8 then Delta := 16 else
      Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

function TWordList.IndexOf(Item: Word): Integer;
begin
  Result := 0;
  while (Result < FCount) and (FList^[Result] <> Item) do Inc(Result);
  if Result = FCount then Result := -1;
end;

procedure TWordList.Insert(Index: Integer; Item: Word);
begin
  if (Index < 0) or (Index > FCount) then Error(SListIndexError, Index);
  if FCount = FCapacity then Grow;
  if Index < FCount then
    System.Move(FList^[Index], FList^[Index + 1],
      (FCount - Index) * SizeOf(Word));
  FList^[Index] := Item;
  Inc(FCount);
end;

function TWordList.Last: Word;
begin
  Result := Get(FCount - 1);
end;

procedure TWordList.Move(CurIndex, NewIndex: Integer);
var
  Item: Word;
begin
  if CurIndex <> NewIndex then
  begin
    if (NewIndex < 0) or (NewIndex >= FCount) then Error(SListIndexError, NewIndex);
    Item := Get(CurIndex);
    Delete(CurIndex);
    Insert(NewIndex, Item);
  end;
end;

procedure TWordList.Put(Index: Integer; Item: Word);
begin
  if Index < 0 then Error(SListIndexError, Index);
  if Index >= FCount then SetCount(Index + 1);
  FList^[Index] := Item;
end;

function TWordList.Remove(Item: Word): Integer;
begin
  Result := IndexOf(Item);
  if Result <> -1 then Delete(Result);
end;

procedure TWordList.Pack;
var
  I: Integer;
begin
  for I := FCount - 1 downto 0 do if Items[I] = FDefault then Delete(I);
end;

procedure TWordList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    Error(SListCapacityError, NewCapacity);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * SizeOf(Word));
    FCapacity := NewCapacity;
  end;
end;

procedure TWordList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    Error(SListCountError, NewCount);
  if NewCount > FCapacity then SetCapacity(NewCount);
  if NewCount > FCount then
    FillWord(FList^[FCount], NewCount - FCount, FDefault);
  FCount := NewCount;
end;

procedure QuickSortWord(SortList: PWordArray; L, R: Integer;
  SCompare: TWordSortCompare);
var
  I, J: Integer;
  P, T: Word;
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
    if L < J then QuickSortWord(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TWordList.Sort(Compare: TWordSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSortWord(FList, 0, Count - 1, Compare);
end;

function TWordList.Compare(List: TWordList): Boolean;
begin
  Result := List.FCount = FCount;
  if Result then
    Result := CompareMem(FList, List.FList, FCount * SizeOf(Word));
end;

procedure TWordList.LoadFromStream(Stream: TStream);
var
  Item, Run: Word;
  Count: Integer;
begin
  Clear;
  Stream.Read(FDefault, SizeOf(Word));
  Stream.Read(Count, SizeOf(Integer));
  SetCapacity(Count);
  while FCount < Count do
  begin
    Stream.Read(Item, SizeOf(Word));
    if Item = FDefault then
    begin
      Stream.Read(Run, SizeOf(Word));
      SetCount(FCount + Run);
    end
    else
      Add(Item);
  end;
end;

procedure TWordList.SaveToStream(Stream: TStream);
var
  I, Run: Integer;
  B: Word;

  function DefaultRun: Integer;
  var
    J: Integer;
  begin
    Result := 0;
    J := I;
    while (J < FCount) and (FList^[J] = FDefault) do
    begin
      Inc(Result);
      Inc(J);
    end;
  end;

begin
  I := 0;
  Stream.Write(FDefault, SizeOf(Word));
  Stream.Write(FCount, SizeOf(Integer));
  while FCount <> I do
  begin
    Run := DefaultRun;
    if Run > 0 then
    begin
      while Run > High(Word) do
      begin
        B := High(Word);
        Stream.Write(FDefault, SizeOf(Word));
        Stream.Write(B, SizeOf(Word));
        Dec(Run, High(Byte));  { sic: the original subtracts $FF here but advances I by $FFFF }
        Inc(I, High(Word));
      end;
      B := Run;
      Stream.Write(FDefault, SizeOf(Word));
      Stream.Write(B, SizeOf(Word));
      Inc(I, Run);
    end
    else
    begin
      Stream.Write(FList^[I], SizeOf(Word));
      Inc(I);
    end;
  end;
end;

function TWordList.RandomChanceItem(Bonus: Integer): Integer;
var
  I, Total, Chance, R: Integer;
begin
  if FCount <> 0 then
  begin
    Total := 0;
    for I := FCount - 1 downto 0 do
    begin
      Chance := FList^[I] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
    end;
    R := Random(Total);
    Total := 0;
    Result := 0;
    while Total < R do
    begin
      Chance := FList^[Result] + Bonus;
      if Chance < 0 then Chance := 0;
      Inc(Total, Chance);
      Inc(Result);
    end;
  end
  else
    Result := -1;
end;

end.
