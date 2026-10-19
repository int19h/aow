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

procedure FillInteger(var Buf; Count, Value: Integer);

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

procedure QuickSort(SortList: PIntegerArray; L, R: Integer;
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
    if L < J then QuickSort(SortList, L, J, SCompare);
    L := I;
  until I >= R;
end;

procedure TIntegerList.Sort(Compare: TIntegerSortCompare);
begin
  if (FList <> nil) and (Count > 0) then
    QuickSort(FList, 0, Count - 1, Compare);
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

end.
