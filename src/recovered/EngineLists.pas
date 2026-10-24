unit EngineLists;

{ Recovered from Enginep.dpl (Engine unit): the typed value lists that the game persists through
  rwStreamProc. Instance layout of each list (12 bytes + default value): +4 FList, +8 FCount,
  +$C FCapacity, +$10 FDefault. The stream form is: default value, Integer count, then the items,
  where a run of items equal to the default is stored as the default followed by the run length
  (Integer for TIntegerList, Byte for the byte lists, Word for TWordList). TBitList stores its bits
  packed. Sources: data/decomp/Enginep-typed-all. }

{$MODE DELPHI}{$H+}

interface

uses
  SysUtils, Classes;

type
  TIntegerList = class(TObject)
  private
    FList: PInteger;                            { +$04 }
    FCount: Integer;                            { +$08 }
    FCapacity: Integer;                         { +$0C }
    FDefault: Integer;                          { +$10 }
    function Get(Index: Integer): Integer;
    procedure Put(Index: Integer; Value: Integer);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function DefaultRun(Index: Integer): Integer;
  protected
    procedure Grow; virtual;
  public
    destructor Destroy; override;
    function Add(Value: Integer): Integer;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Count: Integer read FCount write SetCount;
    property Capacity: Integer read FCapacity write SetCapacity;
    property Default: Integer read FDefault write FDefault;
    property Items[Index: Integer]: Integer read Get write Put; default;
  end;

  TByteList = class(TObject)
  private
    FList: PByte;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: Byte;
    function Get(Index: Integer): Byte;
    procedure Put(Index: Integer; Value: Byte);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function DefaultRun(Index: Integer): Integer;
  protected
    procedure Grow; virtual;
  public
    destructor Destroy; override;
    function Add(Value: Byte): Integer;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Count: Integer read FCount write SetCount;
    property Default: Byte read FDefault write FDefault;
    property Items[Index: Integer]: Byte read Get write Put; default;
  end;

  { Same layout and stream form as TByteList, signed items. }
  TShortIntList = class(TByteList)
  end;

  TWordList = class(TObject)
  private
    FList: PWord;
    FCount: Integer;
    FCapacity: Integer;
    FDefault: Word;
    function Get(Index: Integer): Word;
    procedure Put(Index: Integer; Value: Word);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
    function DefaultRun(Index: Integer): Integer;
  protected
    procedure Grow; virtual;
  public
    destructor Destroy; override;
    function Add(Value: Word): Integer;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Count: Integer read FCount write SetCount;
    property Default: Word read FDefault write FDefault;
    property Items[Index: Integer]: Word read Get write Put; default;
  end;

  TBitList = class(TObject)
  private
    FList: PByte;
    FCount: Integer;
    FCapacity: Integer;                         { in bits, multiple of 32 }
    FDefault: Byte;
    function Get(Index: Integer): Boolean;
    procedure Put(Index: Integer; Value: Boolean);
    procedure SetCapacity(NewCapacity: Integer);
    procedure SetCount(NewCount: Integer);
  protected
    procedure Grow; virtual;
  public
    destructor Destroy; override;
    function Add(Value: Boolean): Integer;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure SaveToStream(Stream: TStream);
    property Count: Integer read FCount write SetCount;
    property Items[Index: Integer]: Boolean read Get write Put; default;
  end;

implementation

const
  MaxListSize = $7FFFFFF;

{ ---------------------------------------------------------------- TIntegerList }

destructor TIntegerList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TIntegerList.Get(Index: Integer): Integer;                { Engine.TIntegerList.Get: out of range gives the default }
begin
  if (Index >= 0) and (Index < FCount) then
    Result := PInteger(PByte(FList) + Index * 4)^
  else
    Result := FDefault;
end;

procedure TIntegerList.Put(Index: Integer; Value: Integer);
begin
  if (Index < 0) or (Index >= FCount) then
    raise EListError.CreateFmt('List index out of bounds (%d)', [Index]);
  PInteger(PByte(FList) + Index * 4)^ := Value;
end;

procedure TIntegerList.Grow;                                       { TList-style growth }
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4
  else if FCapacity > 8 then Delta := 16
  else Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TIntegerList.SetCapacity(NewCapacity: Integer);          { Engine.TIntegerList.SetCapacity }
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EListError.CreateFmt('List capacity out of bounds (%d)', [NewCapacity]);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * 4);
    FCapacity := NewCapacity;
  end;
end;

procedure TIntegerList.SetCount(NewCount: Integer);                { Engine.TIntegerList.SetCount: new items get the default }
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EListError.CreateFmt('List count out of bounds (%d)', [NewCount]);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  for I := FCount to NewCount - 1 do
    PInteger(PByte(FList) + I * 4)^ := FDefault;
  FCount := NewCount;
end;

function TIntegerList.Add(Value: Integer): Integer;                { Engine.TIntegerList.Add }
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  PInteger(PByte(FList) + Result * 4)^ := Value;
  Inc(FCount);
end;

procedure TIntegerList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

function TIntegerList.DefaultRun(Index: Integer): Integer;         { FUN_55514218: length of the run of defaults at Index }
begin
  Result := 0;
  while (Index + Result < FCount) and (Get(Index + Result) = FDefault) do
    Inc(Result);
end;

procedure TIntegerList.LoadFromStream(Stream: TStream);            { Engine.TIntegerList.LoadFromStream }
var
  Total, V, Run: Integer;
begin
  Clear;
  Stream.Read(FDefault, 4);
  Stream.Read(Total, 4);
  SetCapacity(Total);
  while FCount <> Total do
  begin
    Stream.Read(V, 4);
    if V = FDefault then
    begin
      Stream.Read(Run, 4);
      SetCount(FCount + Run);
    end
    else
      Add(V);
  end;
end;

procedure TIntegerList.SaveToStream(Stream: TStream);              { Engine.TIntegerList.SaveToStream }
var
  I, Run: Integer;
begin
  Stream.Write(FDefault, 4);
  Stream.Write(FCount, 4);
  I := 0;
  while I <> FCount do
  begin
    Run := DefaultRun(I);
    if Run < 1 then
    begin
      Stream.Write(PInteger(PByte(FList) + I * 4)^, 4);
      Inc(I);
    end
    else
    begin
      Stream.Write(FDefault, 4);
      Stream.Write(Run, 4);
      Inc(I, Run);
    end;
  end;
end;

{ ---------------------------------------------------------------- TByteList }

destructor TByteList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TByteList.Get(Index: Integer): Byte;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := (FList + Index)^
  else
    Result := FDefault;
end;

procedure TByteList.Put(Index: Integer; Value: Byte);
begin
  if (Index < 0) or (Index >= FCount) then
    raise EListError.CreateFmt('List index out of bounds (%d)', [Index]);
  (FList + Index)^ := Value;
end;

procedure TByteList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4
  else if FCapacity > 8 then Delta := 16
  else Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TByteList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EListError.CreateFmt('List capacity out of bounds (%d)', [NewCapacity]);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity);
    FCapacity := NewCapacity;
  end;
end;

procedure TByteList.SetCount(NewCount: Integer);
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EListError.CreateFmt('List count out of bounds (%d)', [NewCount]);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  if NewCount > FCount then
    FillChar((FList + FCount)^, NewCount - FCount, FDefault);
  FCount := NewCount;
end;

function TByteList.Add(Value: Byte): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  (FList + Result)^ := Value;
  Inc(FCount);
end;

procedure TByteList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

function TByteList.DefaultRun(Index: Integer): Integer;
begin
  Result := 0;
  while (Index + Result < FCount) and (Get(Index + Result) = FDefault) do
    Inc(Result);
end;

procedure TByteList.LoadFromStream(Stream: TStream);               { Engine.TByteList.LoadFromStream }
var
  Total: Integer;
  V, Run: Byte;
begin
  Clear;
  Stream.Read(FDefault, 1);
  Stream.Read(Total, 4);
  SetCapacity(Total);
  while FCount < Total do
  begin
    Stream.Read(V, 1);
    if V = FDefault then
    begin
      Stream.Read(Run, 1);
      SetCount(FCount + Run);
    end
    else
      Add(V);
  end;
end;

procedure TByteList.SaveToStream(Stream: TStream);                 { Engine.TByteList.SaveToStream }
var
  I, Run: Integer;
  B: Byte;
begin
  Stream.Write(FDefault, 1);
  Stream.Write(FCount, 4);
  I := 0;
  while I <> FCount do
  begin
    Run := DefaultRun(I);
    if Run < 1 then
    begin
      Stream.Write((FList + I)^, 1);
      Inc(I);
    end
    else
    begin
      while Run > $FF do
      begin
        B := $FF;
        Stream.Write(FDefault, 1);
        Stream.Write(B, 1);
        Inc(I, $FF);
        Dec(Run, $FF);
      end;
      B := Run;
      Stream.Write(FDefault, 1);
      Stream.Write(B, 1);
      Inc(I, Run);
    end;
  end;
end;

{ ---------------------------------------------------------------- TWordList }

destructor TWordList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TWordList.Get(Index: Integer): Word;
begin
  if (Index >= 0) and (Index < FCount) then
    Result := (FList + Index)^
  else
    Result := FDefault;
end;

procedure TWordList.Put(Index: Integer; Value: Word);
begin
  if (Index < 0) or (Index >= FCount) then
    raise EListError.CreateFmt('List index out of bounds (%d)', [Index]);
  (FList + Index)^ := Value;
end;

procedure TWordList.Grow;
var
  Delta: Integer;
begin
  if FCapacity > 64 then Delta := FCapacity div 4
  else if FCapacity > 8 then Delta := 16
  else Delta := 4;
  SetCapacity(FCapacity + Delta);
end;

procedure TWordList.SetCapacity(NewCapacity: Integer);
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EListError.CreateFmt('List capacity out of bounds (%d)', [NewCapacity]);
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity * 2);
    FCapacity := NewCapacity;
  end;
end;

procedure TWordList.SetCount(NewCount: Integer);
var
  I: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EListError.CreateFmt('List count out of bounds (%d)', [NewCount]);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  for I := FCount to NewCount - 1 do
    (FList + I)^ := FDefault;
  FCount := NewCount;
end;

function TWordList.Add(Value: Word): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  (FList + Result)^ := Value;
  Inc(FCount);
end;

procedure TWordList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

function TWordList.DefaultRun(Index: Integer): Integer;
begin
  Result := 0;
  while (Index + Result < FCount) and (Get(Index + Result) = FDefault) do
    Inc(Result);
end;

procedure TWordList.LoadFromStream(Stream: TStream);               { Engine.TWordList.LoadFromStream }
var
  Total: Integer;
  V, Run: Word;
begin
  Clear;
  Stream.Read(FDefault, 2);
  Stream.Read(Total, 4);
  SetCapacity(Total);
  while FCount < Total do
  begin
    Stream.Read(V, 2);
    if V = FDefault then
    begin
      Stream.Read(Run, 2);
      SetCount(FCount + Run);
    end
    else
      Add(V);
  end;
end;

procedure TWordList.SaveToStream(Stream: TStream);                 { Engine.TWordList.SaveToStream }
var
  I, Run: Integer;
  W: Word;
begin
  Stream.Write(FDefault, 2);
  Stream.Write(FCount, 4);
  I := 0;
  while I <> FCount do
  begin
    Run := DefaultRun(I);
    if Run < 1 then
    begin
      Stream.Write((FList + I)^, 2);
      Inc(I);
    end
    else
    begin
      { the original decrements the run by $FF while advancing by $FFFF here; a run longer than
        65535 defaults therefore corrupts the stream in the game too. Kept as is for byte identity. }
      while Run > $FFFF do
      begin
        W := $FFFF;
        Stream.Write(FDefault, 2);
        Stream.Write(W, 2);
        Inc(I, $FFFF);
        Dec(Run, $FF);
      end;
      W := Run;
      Stream.Write(FDefault, 2);
      Stream.Write(W, 2);
      Inc(I, Run);
    end;
  end;
end;

{ ---------------------------------------------------------------- TBitList }

destructor TBitList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TBitList.Get(Index: Integer): Boolean;                     { Engine.TBitList.Get }
begin
  if (Index >= 0) and (Index < FCount) then
    Result := ((FList + (Index shr 3))^ shr (Index and 7)) and 1 <> 0
  else
    Result := (FDefault and 1) <> 0;
end;

procedure TBitList.Put(Index: Integer; Value: Boolean);            { Engine.TBitList.Put }
var
  P: PByte;
begin
  P := FList + (Index shr 3);
  if Value then
    P^ := P^ or (1 shl (Index and 7))
  else
    P^ := P^ and not (1 shl (Index and 7));
end;

procedure TBitList.Grow;
begin
  SetCapacity(FCapacity + 32);
end;

procedure TBitList.SetCapacity(NewCapacity: Integer);              { Engine.TBitList.SetCapacity: rounded up to 32 bits }
var
  I: Integer;
begin
  if (NewCapacity < FCount) or (NewCapacity > MaxListSize) then
    raise EListError.CreateFmt('List capacity out of bounds (%d)', [NewCapacity]);
  NewCapacity := (NewCapacity + 31) and not 31;
  if NewCapacity <> FCapacity then
  begin
    ReallocMem(FList, NewCapacity shr 3);
    FCapacity := NewCapacity;
    for I := FCount to NewCapacity - 1 do
      Put(I, (FDefault and 1) <> 0);
  end;
end;

procedure TBitList.SetCount(NewCount: Integer);
var
  I, Old: Integer;
begin
  if (NewCount < 0) or (NewCount > MaxListSize) then
    raise EListError.CreateFmt('List count out of bounds (%d)', [NewCount]);
  if NewCount > FCapacity then
    SetCapacity(NewCount);
  Old := FCount;
  FCount := NewCount;
  for I := Old to NewCount - 1 do
    Put(I, (FDefault and 1) <> 0);
end;

function TBitList.Add(Value: Boolean): Integer;
begin
  Result := FCount;
  if Result = FCapacity then
    Grow;
  Inc(FCount);
  Put(Result, Value);
end;

procedure TBitList.Clear;
begin
  SetCount(0);
  SetCapacity(0);
end;

procedure TBitList.LoadFromStream(Stream: TStream);                { Engine.TBitList.LoadFromStream }
begin
  Clear;
  Stream.Read(FDefault, 1);
  Stream.Read(FCount, 4);
  SetCapacity(FCount);
  if FCount > 0 then
    Stream.Read(FList^, (FCount + 7) shr 3);
end;

procedure TBitList.SaveToStream(Stream: TStream);                  { Engine.TBitList.SaveToStream }
begin
  Stream.Write(FDefault, 1);
  Stream.Write(FCount, 4);
  if FCount > 0 then
    Stream.Write(FList^, (FCount + 7) shr 3);
end;

end.
