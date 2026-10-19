unit FMemStr;

{ The game's FMemStr unit (Enginep.dpl), written for Delphi 3.02 and compared with the original code
  by tools/match.py. TFastMemoryStream is Delphi 3's TMemoryStream with a direct Position field, a
  32/128-byte capacity granularity and one-, two- and four-byte fast paths in Read and Write. }

interface

uses
  Windows, SysUtils, Classes;

type
  { FMemStr.TFastMemoryStream (instance size 20): +4 FMemory, +8 FSize, +$C FPosition, +$10 FCapacity }
  TFastMemoryStream = class(TStream)
  private
    FMemory: Pointer;
    FSize: Longint;
    FPosition: Longint;
    FCapacity: Longint;
    procedure SetCapacity(NewCapacity: Longint);
  protected
    procedure SetSize(NewSize: Longint); override;
  public
    destructor Destroy; override;
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
    procedure Clear;
    procedure LoadFromStream(Stream: TStream);
    procedure LoadFromFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);
    procedure SaveToFile(const FileName: string);
    property Memory: Pointer read FMemory;
    property Position: Longint read FPosition write FPosition;
    property Capacity: Longint read FCapacity write SetCapacity;
  end;

implementation

uses
  Consts;

function TFastMemoryStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FSize - FPosition;
  if Result > 0 then
  begin
    if Result > Count then Result := Count;
    if Count = 4 then
      Integer(Buffer) := PInteger(Longint(FMemory) + FPosition)^
    else if Count = 1 then
      Byte(Buffer) := PByte(Longint(FMemory) + FPosition)^
    else if Count = 2 then
      Word(Buffer) := PWord(Longint(FMemory) + FPosition)^
    else
      Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
    Inc(FPosition, Result);
    Exit;
  end;
  Result := 0;
end;

function TFastMemoryStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    soFromBeginning: FPosition := Offset;
    soFromCurrent: Inc(FPosition, Offset);
    soFromEnd: FPosition := FSize + Offset;
  end;
  Result := FPosition;
end;

procedure TFastMemoryStream.SaveToStream(Stream: TStream);
begin
  if FSize <> 0 then Stream.WriteBuffer(FMemory^, FSize);
end;

procedure TFastMemoryStream.SaveToFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

destructor TFastMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TFastMemoryStream.Clear;
begin
  SetCapacity(0);
  FSize := 0;
  FPosition := 0;
end;

procedure TFastMemoryStream.LoadFromStream(Stream: TStream);
var
  Count: Longint;
begin
  Stream.Position := 0;
  Count := Stream.Size;
  SetSize(Count);
  if Count <> 0 then Stream.ReadBuffer(FMemory^, Count);
end;

procedure TFastMemoryStream.LoadFromFile(const FileName: string);
var
  Stream: TStream;
begin
  Stream := TFileStream.Create(FileName, fmOpenRead);
  try
    LoadFromStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TFastMemoryStream.SetCapacity(NewCapacity: Longint);
begin
  if NewCapacity > 0 then
    if FCapacity > 32 then
      NewCapacity := (NewCapacity + $7F) and not $7F
    else
      NewCapacity := (NewCapacity + $1F) and not $1F;
  if NewCapacity <> FCapacity then
  begin
    if NewCapacity = 0 then
    begin
      GlobalFreePtr(FMemory);
      FMemory := nil;
    end
    else
    begin
      if FCapacity = 0 then
        FMemory := GlobalAllocPtr(HeapAllocFlags, NewCapacity)
      else
        FMemory := GlobalReAllocPtr(FMemory, NewCapacity, HeapAllocFlags);
      if FMemory = nil then raise EStreamError.Create(SMemoryStreamError);
    end;
    FCapacity := NewCapacity;
    if FCapacity > FSize then FSize := FCapacity;
  end;
end;

procedure TFastMemoryStream.SetSize(NewSize: Longint);
begin
  if NewSize < FPosition then FPosition := NewSize - 1;
  SetCapacity(NewSize);
  FSize := NewSize;
end;

function TFastMemoryStream.Write(const Buffer; Count: Longint): Longint;
var
  Pos: Longint;
begin
  if (FPosition >= 0) and (Count >= 0) then
  begin
    Pos := FPosition + Count;
    if Pos > 0 then
    begin
      if Pos > FSize then
      begin
        if Pos > FCapacity then SetCapacity(Pos);
        FSize := Pos;
      end;
      if Count = 4 then
        PInteger(Longint(FMemory) + FPosition)^ := Integer(Buffer)
      else if Count = 1 then
        PByte(Longint(FMemory) + FPosition)^ := Byte(Buffer)
      else if Count = 2 then
        PWord(Longint(FMemory) + FPosition)^ := Word(Buffer)
      else
        Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
      FPosition := Pos;
      Result := Count;
      Exit;
    end;
  end;
  Result := 0;
end;

end.
