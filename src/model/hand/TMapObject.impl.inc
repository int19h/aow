procedure TMapObject.ReadWrite(Stream: TEStorageStream);           { HSEngine.TMapObject.ReadWrite }
begin
  if (Stream.StorageMode and (smCompare or smTranslate)) = 0 then
    Stream.rwInteger(FResourceID, 1);          { write: GetResourceID; read: then LinkToResource }
end;
