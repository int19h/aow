constructor TAbilityOwner.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FAbilityData := TList.Create;
  FAbilityIDs := TIntegerList.Create;
end;

destructor TAbilityOwner.Destroy;
var
  I: Integer;
begin
  if FAbilityData <> nil then
    for I := 0 to FAbilityData.Count - 1 do
      TObject(FAbilityData[I]).Free;
  FAbilityData.Free;
  FAbilityIDs.Free;
  inherited Destroy;
end;

procedure TAbilityOwner.ReadWrite(Stream: TEStorageStream);        { AoWE.TAbilityOwner.ReadWrite }
var
  IDs: TIntegerList;
  I: Integer;
  Obj: TEObject;
begin
  inherited ReadWrite(Stream);
  if (Stream.StorageMode and (smRead or smTranslate)) = smRead then
  begin
    if TEReadStorageStream(Stream).PropertyTable.PropertyExist(3) then
    begin
      IDs := TIntegerList.Create;
      try
        Stream.rwStreamProc($31, IDs.LoadFromStream, IDs.SaveToStream);
        for I := 0 to IDs.Count - 1 do
        begin
          Stream.rwCreateEObject(Obj, nil, IDs[I] + $32);
          FAbilityData.Add(Obj);
          FAbilityIDs.Add(IDs[I]);
        end;
      finally
        IDs.Free;
      end;
    end;
  end
  else if (Stream.StorageMode and smWrite) = smWrite then
  begin
    if FAbilityData.Count > 0 then
    begin
      { the original collects GetAbilityID of every entry; the model stored the ids as read }
      Stream.rwStreamProc($31, FAbilityIDs.LoadFromStream, FAbilityIDs.SaveToStream);
      for I := 0 to FAbilityData.Count - 1 do
      begin
        Obj := TEObject(FAbilityData[I]);
        Stream.rwCreateEObject(Obj, nil, FAbilityIDs[I] + $32);
      end;
    end;
  end
  else if (Stream.StorageMode and smTranslate) = smTranslate then
  begin
    for I := 0 to FAbilityData.Count - 1 do
    begin
      Obj := TEObject(FAbilityData[I]);
      Stream.rwCreateEObject(Obj, nil, FAbilityIDs[I] + $32);
    end;
  end;
end;
