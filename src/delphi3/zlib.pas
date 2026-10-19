unit zlib;

{ Stub of the game's zlib unit (compiled into Enginep.dpl): the stream classes TCompressStream uses,
  with the constructor signatures its calls show. The deflate/inflate code and the real bodies are
  stubs until the zlib unit itself is matched. }

interface

uses
  Classes;

type
  TCompressionLevel = (clNone, clFastest, clDefault, clMax);

  TCustomZlibStream = class(TStream)
  private
    FStream: TStream;
  end;

  TCompressionStream = class(TCustomZlibStream)
  public
    constructor Create(CompressionLevel: TCompressionLevel; Dest: TStream);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

  TDecompressionStream = class(TCustomZlibStream)
  public
    constructor Create(Source: TStream);
    function Read(var Buffer; Count: Longint): Longint; override;
    function Write(const Buffer; Count: Longint): Longint; override;
    function Seek(Offset: Longint; Origin: Word): Longint; override;
  end;

implementation

constructor TCompressionStream.Create(CompressionLevel: TCompressionLevel; Dest: TStream);
begin
  inherited Create;
  FStream := Dest;
end;

function TCompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := 0;
end;

function TCompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := FStream.Write(Buffer, Count);
end;

function TCompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  Result := 0;
end;

constructor TDecompressionStream.Create(Source: TStream);
begin
  inherited Create;
  FStream := Source;
end;

function TDecompressionStream.Read(var Buffer; Count: Longint): Longint;
begin
  Result := FStream.Read(Buffer, Count);
end;

function TDecompressionStream.Write(const Buffer; Count: Longint): Longint;
begin
  Result := 0;
end;

function TDecompressionStream.Seek(Offset: Longint; Origin: Word): Longint;
begin
  Result := 0;
end;

end.
