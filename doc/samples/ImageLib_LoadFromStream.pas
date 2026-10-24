{ Reconstruction sample: ImageLib.TCustomImageLibrary.LoadFromStream from Ilpack.dpl (VA 5521A9C0).
  Source: Ghidra decompilation (data/decomp/Ilpack) plus RTTI (data/rtti/Ilpack.dpl.txt).
  Field names marked (RTTI) come from published properties; the others are inferred from use.

  Instance layout seen so far (TCustomImageLibrary, size 80):
    +$24  byte   FState          bit 1 = loading, bit 0 = unknown flag
    +$28  method OnChange        (RTTI)
    +$30  byte   FUpdateCount
    +$31  byte   FReloadable     (inferred)
    +$32  bool   FLoadOnDemand   (RTTI)
    +$38  string FFileName       (RTTI)
    +$3C  int    FDataOffset     absolute stream position of the image data block (format >= 4.0)
    +$4C  obj    FPaletteManager TPaletteManager
  Virtual slots used: +$30 = BeginUpdate (inferred), +$44 = EndUpdate/Changed (inferred).

  The ILB header is 24 bytes: an 8 byte field, a Single version, then
  HeaderSize (offset of the index block) and DataOffset (offset of the pixel data). }

type
  TILBHeader = packed record
    Reserved: array[0..7] of Byte;
    Version: Single;        // 1.x, 2.x, 3.0 or >= 4.0
    HeaderSize: Integer;    // local_28
    DataOffset: Integer;    // local_24
  end;

procedure TCustomImageLibrary.LoadFromStream(Stream: TStream);
var
  Header: TILBHeader;
  StartPos, ImageIndex, RefIndex, SubIndex: Integer;
  Index: TMemoryStream;
  Image: TLibraryImage;
begin
  FState := FState or 2;                 // loading
  Inc(FUpdateCount);
  BeginUpdate;                           // virtual +$30
  FReloadable := ((FState and 1) <> 0) and FLoadOnDemand;

  StartPos := Stream.Position;
  Stream.Read(Header, SizeOf(Header));
  Stream.Seek(StartPos + Header.HeaderSize, soFromBeginning);

  if Header.Version >= 4.0 then
  begin
    // Format 4: the index block is read into memory; pixel data stays in the file
    // so that images can be loaded on demand.
    FDataOffset := StartPos + Header.DataOffset;
    Index := TMemoryStream.Create;
    try
      Index.SetSize(Header.DataOffset - Header.HeaderSize);
      Stream.ReadBuffer(Index.Memory^, Index.Size);
      FPaletteManager.LoadFromStream(Index);
      Index.Read(ImageIndex, 4);
      while ImageIndex <> -1 do
      begin
        Image := ReadImageFromStreamEx(Index, Stream, Self);
        SetImage(ImageIndex, Image);
        Index.Read(RefIndex, 4);
        SetImageReference(ImageIndex, RefIndex);
        Index.Read(ImageIndex, 4);
      end;
    finally
      Index.Free;
    end;
    // Recovered with tools/ghidra/FixDelphiFinally.java: without it Ghidra ends the
    // function at the try/finally epilog ("push addr; ret") and loses the next line.
    if (FState and 1) = 0 then
      Stream.Seek(StartPos + Header.TotalSize, soFromBeginning);
  end
  else
  begin
    FDataOffset := 0;
    if Header.Version <= 1.5 then
      FPaletteManager.Clear
    else
      FPaletteManager.LoadFromStream(Stream);

    if Header.Version > 2.0 then
    begin
      if Header.Version = 3.0 then
      begin
        Stream.Read(ImageIndex, 4);
        while ImageIndex <> -1 do
        begin
          SetImage(ImageIndex, ReadImageFromStream(Stream, Self));
          Stream.Read(RefIndex, 4);
          SetImageReference(ImageIndex, RefIndex);
          Stream.Read(ImageIndex, 4);
        end;
      end;
    end
    else
    begin
      // Formats 1.x and 2.x: each image is a list of sub-images ended by nil.
      Stream.Read(ImageIndex, 4);
      while ImageIndex <> -1 do
      begin
        SubIndex := 0;
        Image := ReadImageFromStream(Stream, Self);
        while Image <> nil do
        begin
          SetSubImage(ImageIndex, SubIndex, Image);
          Inc(SubIndex);
          Image := ReadImageFromStream(Stream, Self);
        end;
        Stream.Read(RefIndex, 4);
        SetImageReference(ImageIndex, RefIndex);
        Stream.Read(ImageIndex, 4);
      end;
    end;
  end;

  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    EndUpdate;                           // virtual +$44
  FState := FState and not 2;
end;
