constructor TMapLevel.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FFields := TList.Create;
end;

destructor TMapLevel.Destroy;
var
  I: Integer;
begin
  if FFields <> nil then
    for I := 0 to FFields.Count - 1 do
      TObject(FFields[I]).Free;
  FFields.Free;
  inherited Destroy;
end;

function TMapLevel.CreateMapField: TEObject;
begin
  Result := TMapField.Create(nil);
end;

procedure TMapLevel.CreateMapFieldList(W, H: Integer);
var
  I: Integer;
begin
  for I := 0 to FFields.Count - 1 do
    TObject(FFields[I]).Free;
  FFields.Clear;
  for I := 0 to W * H - 1 do
    FFields.Add(CreateMapField);
end;

procedure TMapLevel.ReadWrite(Stream: TEStorageStream);            { HSEngine.TMapLevel.ReadWrite }
var
  I: Integer;
  S: TStream;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FWidth, 3);
  Stream.rwByte(FHeight, 4);
  Stream.rwByte(FLevelIndex, 5);
  if ((Stream.StorageMode and (smRead or smCompare or smTranslate)) = smRead) and (FWidth <> 0) then
    CreateMapFieldList(FWidth, FHeight);
  S := Stream.OpenPropertyStream(6);
  if (S <> nil) or ((Stream.StorageMode and smCompare) <> 0) then
    for I := 0 to FFields.Count - 1 do
      Stream.rwEObjectStream(TEObject(FFields[I]));
end;
