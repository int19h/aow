procedure TMapContainer.ReadWrite(Stream: TEStorageStream);        { HSEngine.TMapContainer.ReadWrite }
begin
  inherited ReadWrite(Stream);
  { read mode also links the container to its engine and map; the model has no engine }
  Stream.rwByte(FByte3, 3);
  Stream.rwByte(FByte4, 4);
  Stream.rwByte(FByte5, 5);
end;
