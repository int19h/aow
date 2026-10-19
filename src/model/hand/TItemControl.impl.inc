constructor TItemControl.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FItems := TList.Create;
end;

destructor TItemControl.Destroy;
var
  I: Integer;
begin
  if FItems <> nil then
    for I := 0 to FItems.Count - 1 do
      TObject(FItems[I]).Free;
  FItems.Free;
  inherited Destroy;
end;

procedure TItemControl.ReadWrite(Stream: TEStorageStream);         { AoWE.TItemControl.ReadWrite }
var
  ID, I: Integer;
  Item: TEObject;
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FInt9, 9);
  if (Stream.StorageMode and smTranslate) = 0 then
  begin
    if (Stream.StorageMode and (smCompare or smPartial or smTranslate)) = 0 then
    begin
      if (Stream.StorageMode and smRead) <> 0 then
      begin
        ID := 10;
        repeat
          Stream.rwCreateEObject(Item, nil, ID);
          if Item <> nil then
            FItems.Add(Item);              { the original also validates the item and sets a flag }
          Inc(ID);
        until Item = nil;
      end;
      if (Stream.StorageMode and (smCompare or smWrite)) <> 0 then
      begin
        ID := 10;
        for I := 0 to FItems.Count - 1 do
        begin
          Item := TEObject(FItems[I]);
          if Item.Owner = nil then
          begin
            Stream.rwCreateEObject(Item, nil, ID);
            Inc(ID);
          end;
        end;
      end;
    end;
  end
  else
  begin
    ID := 10;
    for I := 0 to FItems.Count - 1 do
    begin
      Item := TEObject(FItems[I]);
      if Item.Owner = nil then
      begin
        Stream.rwCreateEObject(Item, nil, ID);
        Inc(ID);
      end;
    end;
  end;
end;
