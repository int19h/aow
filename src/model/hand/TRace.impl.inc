constructor TRace.Create(AOwner: TEObject);
begin
  inherited Create(AOwner);
  FIntegerList := TIntegerList.Create;
  FRelations := TByteList.Create;
end;

destructor TRace.Destroy;
begin
  FIntegerList.Free;
  FRelations.Free;
  inherited Destroy;
end;

procedure TRace.ReadWrite(Stream: TEStorageStream);                { AoWE.TRace.ReadWrite }
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FRace, 2);
  Stream.rwStreamProc(3, FIntegerList.LoadFromStream, FIntegerList.SaveToStream);
  Stream.rwBool(FEnabled, 4);            { read mode calls SetEnabled with the value }
  Stream.rwStreamProc(5, FRelations.LoadFromStream, FRelations.SaveToStream);
  { read mode: ResetDefaultRaceRelations when the list is empty }
end;
