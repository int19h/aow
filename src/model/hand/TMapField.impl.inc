procedure TMapField.ReadWrite(Stream: TEStorageStream);            { HSEngine.TMapField.ReadWrite }
var
  I, ID: Integer;
  Child: TEObject;
  T: TPropertyTable;
begin
  if (Stream.StorageMode and smCompare) = 0 then
  begin
    if (Stream.StorageMode and smRead) = 0 then
    begin
      ID := $32;
      for I := 0 to GetCount - 1 do
      begin
        Child := GetChild(I);
        if (Child <> nil) and (Child.Owner = Self)
           and ((Child.GetControlStyle and csShared) = 0)
           and ((Child.GetControlStyle and csStored) <> 0) then
        begin
          Stream.rwCreateEObject(Child, Self, ID);
          Inc(ID);
        end;
      end;
    end
    else if (Stream.StorageMode and smTranslate) = 0 then
    begin
      T := TEReadStorageStream(Stream).PropertyTable;
      { the table grows while children are created; read the bounds once like the original }
      for I := T.First to T.Count - 1 do
      begin
        ID := T.Items^[I].ID;
        if ID > $31 then
          Stream.rwCreateEObject(Child, Self, ID);
      end;
    end
    else
    begin
      { translate mode pairs the existing children with the stored ids }
      T := TEReadStorageStream(Stream).PropertyTable;
      for I := T.First to T.Count - 1 do
      begin
        ID := T.Items^[I].ID;
        if ID > $31 then
          Stream.rwCreateEObject(Child, Self, ID);
      end;
    end;
  end
  else
    inherited ReadWriteChildren(Stream);
end;

procedure TMapField.ReadWriteChildren(Stream: TEStorageStream);
begin
  { children are handled by ReadWrite above; TECustomNode.MainReadWrite must not add an id-1 table }
end;
