constructor TPlayer.Create(AOwner: TEObject);
  procedure Embed(O: TEObject);
  begin
    O.EmbeddedShared := True;
  end;
begin
  inherited Create(AOwner);
  FEventLogbook := TEventLogbook.Create(Self); Embed(FEventLogbook);
  FAIPlayerControl := TAIPlayerControl.Create(Self); Embed(FAIPlayerControl);
  FLeaderObject := TLeader.Create(Self); Embed(FLeaderObject);
  FPlayerMagicControl := TPlayerMagicControl.Create(Self); Embed(FPlayerMagicControl);
  FPlayerStatistics := TPlayerStatistics.Create(Self); Embed(FPlayerStatistics);
  FAIBudgetManager := TAIBudgetManager.Create(Self); Embed(FAIBudgetManager);
  FDiplomaticActionList := TDiplomaticActionList.Create(Self); Embed(FDiplomaticActionList);
  FPBEMPlayerSettings := TPBEMPlayerSettings.Create(Self); Embed(FPBEMPlayerSettings);
  FPlayerDiplomaticRelations := TPlayerDiplomaticRelations.Create(Self); Embed(FPlayerDiplomaticRelations);
  FLegacyRelations := TByteList.Create;
  FLegacyRelations2 := TByteList.Create;
  FIntList32 := TIntegerList.Create;
  FIntList33 := TIntegerList.Create;
  FStrings40 := TStringList.Create;
  FBitList53 := TBitList.Create;
end;

destructor TPlayer.Destroy;
begin
  FLegacyRelations.Free;
  FLegacyRelations2.Free;
  FIntList32.Free;
  FIntList33.Free;
  FStrings40.Free;
  FBitList53.Free;
  inherited Destroy;
end;

procedure TPlayer.ReadWrite(Stream: TEStorageStream);              { AoWE.TPlayer.ReadWrite }
var
  Reading: Boolean;
  T: TPropertyTable;
begin
  inherited ReadWrite(Stream);
  Reading := (Stream.StorageMode and smRead) <> 0;
  T := nil;
  if Stream is TEReadStorageStream then
    T := TEReadStorageStream(Stream).PropertyTable;
  Stream.rwByte(FRace, 2);
  Stream.rwData(FByte3, 1, 3);
  Stream.rwBool(FBool4, 4);
  Stream.rwInteger(FInt5, 5);
  Stream.rwInteger(FInt6, 6);
  Stream.rwData(FByte10, 1, 10);
  if (Stream.StorageMode and smCompare) = 0 then
    Stream.rwString(FStr11, $B);
  Stream.rwString(FStr12, $C);
  Stream.rwInteger(FGems, $10);
  Stream.rwByte(FPlayerIndex, $12);
  { id $13: the editor reads a leader created here; the game skips it (AoWEngine flags and 6 = 0) }
  if Reading and (T <> nil) and T.PropertyExist($13) then
    Stream.rwCreateEObject(FLeader, nil, $13);
  { ids $14..$16 are written for the current player only; the model remembers whether they were there }
  if Reading then
  begin
    FHasView := (T <> nil) and (T.PropertyExist($14) or T.PropertyExist($15) or T.PropertyExist($16));
    Stream.rwByte(FView14, $14);
    Stream.rwByte(FView15, $15);
    Stream.rwByte(FView16, $16);
  end
  else if FHasView then
  begin
    Stream.rwByte(FView14, $14);
    Stream.rwByte(FView15, $15);
    Stream.rwByte(FView16, $16);
  end;
  if (Stream.StorageMode and smPartial) = 0 then
    Stream.rwEObject(FEventLogbook, $17);
  Stream.rwString(FName, $18);
  Stream.rwData(FByte25, 1, $19);
  if Reading then
    Stream.rwStreamProc($1A, FLegacyRelations.LoadFromStream, FLegacyRelations.SaveToStream);
  Stream.rwByte(FByte27, $1B);
  Stream.rwEObject(FAIPlayerControl, $1C);
  Stream.rwData(FByte29, 1, $1D);
  if FPlayerIndex <> 0 then
    Stream.rwEObject(FLeaderObject, $1E);   { the original writes FLeader here only while a hero is being transferred }
  Stream.rwEObject(FPlayerMagicControl, $1F);
  Stream.rwStreamProc($20, FIntList32.LoadFromStream, FIntList32.SaveToStream);
  Stream.rwStreamProc($21, FIntList33.LoadFromStream, FIntList33.SaveToStream);
  Stream.rwInteger(FInt34, $22);
  Stream.rwEObject(FPlayerStatistics, $23);
  Stream.rwInteger(FInt36, $24);
  Stream.rwInteger(FInt37, $25);
  Stream.rwInteger(FInt38, $26);
  Stream.rwInteger(FInt39, $27);
  { read mode: SetRace, event logbook and relation list setup }
  Stream.rwStrings(FStrings40, $28);
  if Reading then
    Stream.rwStreamProc($29, FLegacyRelations2.LoadFromStream, FLegacyRelations2.SaveToStream);
  Stream.rwInteger(FInt50, $32);
  Stream.rwEObject(FAIBudgetManager, $33);
  Stream.rwEObject(FDiplomaticActionList, $34);
  Stream.rwStreamProc($35, FBitList53.LoadFromStream, FBitList53.SaveToStream);
  Stream.rwEObject(FPBEMPlayerSettings, $36);
  Stream.rwBool(FBool56, $38);
  if Reading then
  begin
    FHas57 := (T <> nil) and T.PropertyExist($39);
    Stream.rwInteger(FInt57, $39);
  end
  else if FHas57 then
    Stream.rwInteger(FInt57, $39);
  Stream.rwEObject(FPlayerDiplomaticRelations, $3A);
  if FPlayerIndex = 0 then
    FByte3 := 4;
end;
