unit FMemStr;

{ Stub of the game's FMemStr unit (Enginep.dpl): TFastMemoryStream is a TMemoryStream look-alike with
  a direct Position field. Only the declaration matters for matching the Engine unit; the bodies are
  stubs until the unit itself is matched. }

interface

uses
  SysUtils, Classes;

type
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
  end;

implementation

procedure TFastMemoryStream.SetCapacity(NewCapacity: Longint);
begin
  ReallocMem(FMemory, NewCapacity);
  FCapacity := NewCapacity;
end;

procedure TFastMemoryStream.SetSize(NewSize: Longint);
begin
  if NewSize > FCapacity then SetCapacity(NewSize);
  FSize := NewSize;
  if FPosition > FSize then FPosition := FSize;
end;

destructor TFastMemoryStream.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TFastMemoryStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FSize - FPosition;
  if Result > Count then Result := Count;
  if Result > 0 then
  begin
    Move(Pointer(Longint(FMemory) + FPosition)^, Buffer, Result);
    Inc(FPosition, Result);
  end;
end;

function TFastMemoryStream.Write(const Buffer; Count: Longint): Longint;
var
  Pos: Longint;
begin
  Pos := FPosition + Count;
  if Pos > FSize then SetSize(Pos);
  Move(Buffer, Pointer(Longint(FMemory) + FPosition)^, Count);
  FPosition := Pos;
  Result := Count;
end;

function TFastMemoryStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  case Origin of
    0: FPosition := Offset;
    1: Inc(FPosition, Offset);
    2: FPosition := FSize + Offset;
  end;
  Result := FPosition;
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

end.
