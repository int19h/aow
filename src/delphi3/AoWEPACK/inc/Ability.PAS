constructor TAoWHSSet.Create(AOwner: Engine.TECustomNode);
var
  Enabled: TBitList;
begin
  inherited Create(AOwner);
  FCombatResources := TMapObjectResourceList.Create(Self);
  FCombatResources.SetControlStyle([csSaveLoad, csFixedChild]);
  FCombatHexagons := THexagonControl.Create(Self);
  FCombatHexagons.MOClass := TAbstractHexagon;
  FCombatRoads := TRoadControl.Create(Self);
  FCombatRoads.MOClass := TAbstractRoad;
  ImageLibraryManager.ExecutePathSearch(AoWEngine.StartupDirectory + 'IMAGES');
  SFXManager.ExecutePathSearch(AoWEngine.StartupDirectory + 'SFX');
  FImageSequences := TImageSequenceList.Create(ImageLibraryManager, nil);
  TerrainTypes.Add(TranslateRStr(WaterRStr));
  TerrainTypes.Add(TranslateRStr(GrassRStr));
  TerrainTypes.Add(TranslateRStr(DesertRStr));
  TerrainTypes.Add(TranslateRStr(SnowRStr));
  TerrainTypes.Add(TranslateRStr(SteppeRStr));
  TerrainTypes.Add(TranslateRStr(WastelandRStr));
  TerrainTypes.Add(TranslateRStr(IceRStr));
  TerrainTypes.Add(TranslateRStr(EarthRStr));
  TerrainTypes.Add(TranslateRStr(RockRStr));
  TerrainTypes.Add(TranslateRStr(LavaRStr));
  TerrainTypes.Add(TranslateRStr(WaterRStr));
  TerrainTypes.Add(TranslateRStr(ReservedRStr));
  TerrainTypes.Add(TranslateRStr(DirtRStr));
  TerrainTypes.Add(TranslateRStr(IceRStr));
  TerrainTypes.Add(TranslateRStr(CoastRStr));
  TerrainTypes.Add(TranslateRStr(BorderRStr));
  OverlayTypes.Add(TranslateRStr(MountainRStr));
  OverlayTypes.Add(TranslateRStr(DenseVegetationRStr));
  OverlayTypes.Add(TranslateRStr(HillRStr));
  OverlayTypes.Add(TranslateRStr(VegetationRStr));
  OverlayTypes.Add(TranslateRStr(RoadRStr));
  OverlayTypes.Add(TranslateRStr(BridgeRStr));
  OverlayTypes.Add(TranslateRStr(RubbleRStr));
  OverlayTypes.Add(TranslateRStr(StructureRStr));
  OverlayTypes.Add(TranslateRStr(ObstacleRStr));
  OverlayTypes.Add(TranslateRStr(LightVegetationRStr));
  OverlayTypes.Add(TranslateRStr(SolidRStr));
  DecorationTypes.Add(TranslateRStr(NoneRStr));
  DecorationTypes.Add(TranslateRStr(RocksRStr));
  DecorationTypes.Add(TranslateRStr(BonesRStr));
  DecorationTypes.Add(TranslateRStr(DeadTreeRStr));
  DecorationTypes.Add(TranslateRStr(ToadstoolsRStr));
  FPadControl := TPadControl.Create(Self);
  Enabled := FPadControl.FTerrainTypes;
  Enabled[1] := True;
  Enabled[2] := True;
  Enabled[3] := True;
  Enabled[4] := True;
  Enabled[5] := True;
  Enabled[6] := True;
  Enabled[12] := True;
  FRaceResources := TRaceResourceList.Create(Self);
  FFlagControl := TFlagControl.Create(Self);
  FFireControl := TFireControl.Create;
  FUnitResources := TUnitResourceList.Create(Self);
  FUnitGFXResources := TUnitGFXResourceList.Create(Self);
  FHeroResources := THeroResourceList.Create(Self);
  FItemGFXResources := TItemGFXList.Create(Self);
  FFaceResources := TFaceResourceList.Create(Self);
  FItemLibraries := TItemLibraryManager.Create(nil);
  FHeroLibraries := THeroLibraryManager.Create(nil);
  FAbilityControl := TAbilityControl.Create(nil);
  FSpellControl := TSpellControl.Create(nil);
  FTextControl := TTextControl.Create(nil);
  FGeneralImages := ImageLibraryManager.LinkToIL([icDisk], 'GENERAL.ILB');
  FCursorImages := ImageLibraryManager.LinkToIL([icDisk], 'CURSORS.ILB');
  FCombatImages := ImageLibraryManager.LinkToIL([icDisk], 'COMBAT.ILB');
end;

destructor TAoWHSSet.Destroy;
begin
  FFireControl.Free;
  FImageSequences.Free;
  FTextControl.Free;
  FAbilityControl.UnregisterAll;
  FSpellControl.UnregisterAll;
  FItemLibraries.Free;
  FHeroLibraries.Free;
  inherited Destroy;
  FAbilityControl.Free;
  FSpellControl.Free;
end;

class function TAoWHSSet.ClassID: Integer;
begin Result := $20010; end;

function TAoWHSSet.GetFileCRC(const FileName: string; AtEnd: Boolean): Integer;
var
  FileStream: TFileStream;
begin
  Result := 0;
  FileStream := TFileStream.Create(FileName, fmOpenRead or fmShareDenyWrite);
  try
    if AtEnd then
    begin
      FileStream.Position := FileStream.Size - 4;
      FileStream.Read(Result, 4);
    end
    else FileStream.Read(Result, 4);
  finally
    FileStream.Free;
  end;
end;

function TAoWHSSet.RetrieveHSSCRC: Integer;
var
  CRCs: TIntegerList;
  Path: string;
begin
  CRCs := TIntegerList.Create;
  Path := ExtractFilePath(AoWEngine.HSSFileName);
  { Original includes ABILITY.PFS twice and does not free CRCs on a read error. }
  CRCs.Add(GetFileCRC(Path + 'ABILITY.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'ABILITY.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'UNITRES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'UNITGFX.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'HERORES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'ITEMGFX.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'FACERES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'COMB_RES.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'SPELLS.PFS', False));
  CRCs.Add(GetFileCRC(Path + 'RELEASE.HSS', True));
  Result := GetCRC32(CRCs.List, CRCs.Count * 4);
  CRCs.Free;
end;

procedure TAoWHSSet.ReadWrite(Stream: Engine.TEStorageStream);
var
  Path: string;
  Loaded: Boolean;
begin
  if smRead in Stream.StorageMode then
    Stream.ShowProgress(Self, TranslateRStr(LoadingGamePackRStr), 0);
  inherited ReadWrite(Stream);
  Stream.rwEObject(FRaceResources, $0A);
  Stream.rwEObject(FItemLibraries, $0B);
  if not (smTextOnly in Stream.StorageMode) then
  begin
    Path := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      Loaded := AoWEngine.ReadFromFileCRC(Path + 'ABILITY.PFS', FAbilityControl, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingUnitsRStr), 70);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'UNITRES.PFS', FUnitResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'UNITGFX.PFS', FUnitGFXResources, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingHeroesRStr), 80);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'HERORES.PFS', FHeroResources, nil);
      Stream.ShowProgress(Self, TranslateRStr(LoadingItemsRStr), 90);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'ITEMGFX.PFS', FItemGFXResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'FACERES.PFS', FFaceResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'COMB_RES.PFS', FCombatResources, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'SPELLS.PFS', FSpellControl, nil);
      Loaded := Loaded and AoWEngine.ReadFromFileCRC(Path + 'TEXT.PFS', FTextControl, nil);
      if not Loaded then raise Exception.Create('CRC-CHECK FAILED');
      Stream.ShowProgress(Self, TranslateRStr(GamePackLoadedRStr), 100);
    end
    else
    begin
      AoWEngine.WriteToFileCRC(Path + 'ABILITY.PFS', FAbilityControl, nil);
      AoWEngine.WriteToFileCRC(Path + 'UNITRES.PFS', FUnitResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'UNITGFX.PFS', FUnitGFXResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'HERORES.PFS', FHeroResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'ITEMGFX.PFS', FItemGFXResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'FACERES.PFS', FFaceResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'COMB_RES.PFS', FCombatResources, nil);
      AoWEngine.WriteToFileCRC(Path + 'SPELLS.PFS', FSpellControl, nil);
      AoWEngine.WriteToFileCRC(Path + 'TEXT.PFS', FTextControl, nil);
    end;
  end
  else
  begin
    Stream.rwEObject(FUnitResources, $6F);
    Stream.rwEObject(FUnitGFXResources, $70);
    Stream.rwEObject(FHeroResources, $71);
    Stream.rwEObject(FItemGFXResources, $72);
    Stream.rwEObject(FFaceResources, $73);
    Stream.rwEObject(FSpellControl, $75);
    Stream.rwEObject(FAbilityControl, $76);
    Stream.rwEObject(FTextControl, $77);
  end;
  Stream.rwEObject(FHeroLibraries, $11);
  Stream.rwStreamProc($12, FImageSequences.LoadFromStream, FImageSequences.SaveToStream);
  if smRead in Stream.StorageMode then
  begin
    FImageSequences.LinkToIL;
    FHSSCRC := RetrieveHSSCRC;
  end;
end;

procedure TAoWHSSet.MainReadWrite(Stream: Engine.TEStorageStream);
var
  DictionaryFile: string;
begin
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead] then
  begin
    DictionaryFile := AoWEngine.StartupDirectory + 'Dict\' + 'Release' + '.mld';
    AoWEngine.TranslateEObjectFromFile(Self, DictionaryFile);
  end;
end;

procedure TAoWHSSet.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FItemLibraries.MsgProc(Msg, Sender);
end;

constructor TRace.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPlayerRelations := TIntegerList.Create;
  FDefaultRelations := TByteList.Create;
  FRace := -1;
  FEnabled := False;
end;

destructor TRace.Destroy;
begin
  SetEnabled(False);
  FPlayerRelations.Free;
  FDefaultRelations.Free;
  inherited Destroy;
end;

function TRace.GetRelationValue(Race: Shortint): Integer;
var
  Player: Integer;
begin
  Player := AoWHSMap.FPlayers.RaceToPlayer(Race);
  if Player = -1 then Result := StatusToStatusValue(TStatus(FDefaultRelations[Race]))
  else Result := FPlayerRelations[Player - 1];
  Result := Result + TRaceList(Owner).FRelationOffset;
end;

function TRace.GetRelation(Race: Shortint): TStatus;
var
  Player: Integer;
begin
  Player := AoWHSMap.FPlayers.RaceToPlayer(Race);
  if Player = -1 then
    Result := StatusValueToStatus(StatusToStatusValue(TStatus(FDefaultRelations[Race])) + AoWHSMap.FRaces.FRelationOffset)
  else Result := StatusValueToStatus(FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset);
end;

procedure TRace.SetPlayerRelationValue(Player: Shortint; Value: Integer);
begin
  if Player > 0 then
  begin
    { Original dereferences AoWHSMap before the nil check below. }
    FPlayerRelations[Player - 1] := Value - AoWHSMap.FRaces.FRelationOffset;
    if AoWHSMap <> nil then AoWHSMap.TriggerRelationsChanged;
  end;
end;

function TRace.GetPlayerRelationValue(Player: Shortint): Integer;
begin
  if Player > 0 then Result := FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset
  else Result := 50;
end;

function TRace.GetPlayerRelation(Player: Shortint): TStatus;
begin
  if Player > 0 then Result := StatusValueToStatus(FPlayerRelations[Player - 1] + AoWHSMap.FRaces.FRelationOffset)
  else Result := sNeutral;
end;

procedure TRace.NewDay;
type
  TControlBits = set of 0..7;
var
  I, DefaultValue: Integer;
begin
  if AoWHSMap.FDay <> 1 then
  begin
    if AoWHSMap.FGlobalMagicControl.FActiveEnchantments * [getHatred, getHarmony] = [] then
      for I := 0 to FPlayerRelations.Count - 1 do
      begin
        DefaultValue := StatusToStatusValue(TStatus(FDefaultRelations[AoWHSMap.FPlayers.GetPlayers(I + 1).FPlayerRace]));
        if FPlayerRelations[I] > DefaultValue then
        begin
          FPlayerRelations[I] := FPlayerRelations[I] - 1;
          if FPlayerRelations[I] < DefaultValue then FPlayerRelations[I] := DefaultValue;
        end;
        if FPlayerRelations[I] < DefaultValue then
        begin
          FPlayerRelations[I] := FPlayerRelations[I] + 1;
          if FPlayerRelations[I] > DefaultValue then FPlayerRelations[I] := DefaultValue;
        end;
      end;
  end
  else ResetPlayerRelations;
end;

function TRace.GetDefaultRaceRelation(Race: Shortint): TStatus;
begin
  if (Race >= 0) and (Race < FDefaultRelations.Count) then
    Result := TStatus(FDefaultRelations[Race])
  else Result := sNeutral;
end;

class function TRace.ClassID: Integer;
begin Result := $20202; end;

procedure TRace.ResetDefaultRaceRelations;
var
  I: Integer;
begin
  FDefaultRelations.Clear;
  if (Smallint(FRace) >= 0) and (Smallint(FRace) <= 11) then
    for I := 0 to 11 do FDefaultRelations.Add(Ord(DefaultRaceRelations[FRace, I]));
end;

procedure TRace.ResetPlayerRelations;
var
  I: Integer;
begin
  FPlayerRelations.Clear;
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    FPlayerRelations.Add(StatusToStatusValue(TStatus(FDefaultRelations[AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace])));
end;

procedure TRace.SetRace(Value: Shortint);
begin
  FRace := Value;
  ResetDefaultRaceRelations;
end;

procedure TRace.SetEnabled(Value: Boolean);
begin
  if Value <> FEnabled then
    if AoWHSSet.FRaceResources.GetRaceResource(FRace) <> nil then
    begin
      if Value then AoWHSSet.FRaceResources.GetRaceResource(FRace).AddRef
      else AoWHSSet.FRaceResources.GetRaceResource(FRace).Release;
      FEnabled := Value;
    end;
end;

procedure TRace.ReadWrite(Stream: Engine.TEStorageStream);
var
  Enabled: Boolean;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FRace), 2);
  Stream.rwStreamProc(3, FPlayerRelations.LoadFromStream, FPlayerRelations.SaveToStream);
  if Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead] then
  begin
    { Original leaves this local uninitialized if property 4 is absent. }
    Stream.rwBool(Enabled, 4);
    SetEnabled(Enabled);
  end
  else Stream.rwBool(FEnabled, 4);
  Stream.rwStreamProc(5, FDefaultRelations.LoadFromStream, FDefaultRelations.SaveToStream);
  if (smRead in Stream.StorageMode) and (FDefaultRelations.Count = 0) then ResetDefaultRaceRelations;
end;

procedure TRace.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then NewDay;
end;

constructor TRaceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

procedure TRaceList.ReadWrite(Stream: Engine.TEStorageStream); { Original bypasses TEControlStyleNode.ReadWrite. }
asm
  PUSH EBX; PUSH ESI; MOV ESI, EDX; MOV EBX, EAX; MOV EDX, ESI; MOV EAX, EBX; CALL TEObject.ReadWrite
  LEA EDX, [EBX].TRaceList.FRelationOffset; MOV ECX, 20; MOV EAX, ESI; MOV EBX, [EAX]; CALL DWORD PTR [EBX+$2C]; POP ESI; POP EBX
end;

function TRaceList.GetRace(Index: Integer): TRace;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := TRace(FChildren.List^[Index])
  else Result := nil;
end;

function TRaceList.GetEnabledRaces: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FChildren.Count - 1 do
    if (FChildren.List^[I] <> nil) and TRace(FChildren.List^[I]).FEnabled then Inc(Result);
end;

function TRaceList.GetRandomRace: Shortint;
var
  I: Integer;
  Races: TList;
begin
  Races := TList.Create;
  for I := 0 to FChildren.Count - 1 do
    if (FChildren.List^[I] <> nil) and TRace(FChildren.List^[I]).FEnabled then Races.Add(FChildren.List^[I]);
  if Races.Count <> 0 then Result := TRace(Races.List^[Random(Races.Count)]).FRace
  else Result := -1;
  Races.Free;
end;

procedure TRaceList.ResetPlayerRelations;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then TRace(FChildren.List^[I]).ResetPlayerRelations;
end;

procedure TRaceList.ResetDefaultRelations;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then TRace(FChildren.List^[I]).ResetDefaultRaceRelations;
end;

procedure TRaceList.Update;
var
  I: Integer;
  Race: TRace;
begin
  for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do
    if AoWHSSet.FRaceResources.GetRaceResource(I) <> nil then
    begin
      if GetRace(I) = nil then
      begin
        Race := TRace.Create(nil);
        Race.FRace := I;
        Race.SetArrayOwner(Self, I);
        Race.SetEnabled(True);
      end;
    end
    else GetRace(I).Free;
end;

class function TFaceResource.ClassID: Integer;
begin Result := $20270; end;

function TFaceResource.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function TFaceResource.FaceResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;

procedure TFaceResource.LinkToIL;
begin
  ReleaseIL;
  if FImageLibraryName <> '' then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName)
  else FImageLibrary := nil;
end;

procedure TFaceResource.ReleaseIL;
begin
  if FImageLibrary <> nil then
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
end;

procedure TFaceResource.SetImageLibraryName(Value: string);
begin
  if FImageLibraryName <> '' then
  begin
    { Original releases the old name even when this resource has no references. }
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
  FImageLibraryName := Value;
  if (FImageLibraryName <> '') and (FReferences <> 0) then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
end;

function TFaceResource.AddRef: Integer;
begin
  if FReferences = 0 then LinkToIL;
  Inc(FReferences);
  Result := FReferences;
end;

function TFaceResource.Release: Integer;
begin
  Dec(FReferences);
  if FReferences = 0 then ReleaseIL;
  Result := FReferences;
end;

function TFaceResource.GetCellImage: ImageLib.TLibraryImage;
begin
  AddRef;
  Result := FImageLibrary[FImageIndex];
  Release;
end;

function TFaceResource.GetFaceImage: TLibraryImage;
var
  Images: TCustomImageLibrary;
begin
  Images := FImageLibrary;
  if Images <> nil then Result := Images[FImageIndex]
  else Result := nil;
end;

procedure TFaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 5);
  Stream.rwInteger(FImageIndex, 6);
  Stream.rwBool(FDeveloperOnly, 7);
end;

constructor TFaceResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TFaceResourceList.IndexOfFaceImage(Image: TLibraryImage): Integer;
var
  Face: TFaceResource;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    Face := TFaceResource(FChildren.List^[Result]);
    if (Face <> nil) and (Face.GetFaceImage = Image) then Exit;
  end;
  Result := -1;
end;

function TFaceResourceList.GetFaceResource(Index: Integer): TFaceResource;
begin
  if (Index < FChildren.Count) and (Index >= 0) then
    Result := TFaceResource(FChildren.List^[Index])
  else Result := nil;
end;

function TFaceResourceList.PrevFace(Index: Integer): Integer;
var
  Developer: Boolean;
begin
  Result := Index;
  Developer := TAoWRegistry(AoWEngine.FRegistry).GetDeveloper;
  { Original assumes the list contains a selectable face. }
  repeat
    Dec(Result);
    if Result < 0 then Result := FChildren.Count - 1;
  until (FChildren.List^[Result] <> nil) and
    (Developer or not TFaceResource(FChildren.List^[Result]).FDeveloperOnly);
end;

function TFaceResourceList.NextFace(Index: Integer): Integer;
var
  Developer: Boolean;
begin
  Result := Index;
  Developer := TAoWRegistry(AoWEngine.FRegistry).GetDeveloper;
  { Original assumes the list contains a selectable face. }
  repeat
    Inc(Result);
    if Result >= FChildren.Count then Result := 0;
  until (FChildren.List^[Result] <> nil) and
    (Developer or not TFaceResource(FChildren.List^[Result]).FDeveloperOnly);
end;

constructor TUnitSelector.Create;
begin
  inherited Create;
  FUnits := TUnitUserList.Create(nil);
  FReferences := 1;
  FCanceled := False;
end;

destructor TUnitSelector.Destroy;
begin
  FUnits.Free;
  inherited Destroy;
end;

function TUnitSelector.AddRef: Integer;
begin
  Inc(FReferences);
  Result := FReferences;
end;

function TUnitSelector.Release: Integer;
var
  Count: Integer;
begin
  Dec(FReferences);
  Count := FReferences;
  Result := Count;
  if Count = 0 then Destroy;
end;

procedure TUnitSelector.SetSelection(Value: Byte);
begin
  FSelection := Value and FSelectable;
end;

function TUnitSelector.GetSelectionCount: Integer;
var
  Bits: Cardinal;
begin
  Result := 0;
  Bits := Byte(FSelection);
  while Bits <> 0 do
  begin
    if Bits and 1 <> 0 then Inc(Result);
    Bits := Bits shr 1;
  end;
end;

function TUnitSelector.CanSelect(var Error: string): Boolean;
begin
  if FSelection = 0 then
  begin
    Error := TranslateRStr(NoUnitSelectedRStr);
    Result := False;
  end
  else Result := True;
end;

function TUnitSelector.Select: Boolean;
asm
  { needs: function Select: Boolean; P4 has unmarked procedure overrides. }
  PUSH EBX
  PUSH ESI
  MOV BL, 1
  CMP WORD PTR [EAX+$1E], 0
  JE @@Done
  MOV ESI, EAX
  MOV EDX, EAX
  MOV EAX, [ESI+$20]
  CALL DWORD PTR [ESI+$1C]
@@Done:
  MOV EAX, EBX
  POP ESI
  POP EBX
end;

procedure TUnitSelector.Cancel;
begin
  if Assigned(FOnCancel) then FOnCancel(Self);
end;

function TUnitSelector.CanSelectUnit(A1: TUnit): Boolean;
asm
  { needs: function CanSelectUnit(Unit: TUnit): Boolean; unmarked P4 overrides. }
  MOV AL, 1
end;

procedure TUnitSelector.Setup(Source: TAbstractUnit; Units: TUnitList);








var
  I: Integer;
begin
  if Source <> nil then
  begin
    FSourceUnitID := Source.FUnitID;
    FPlayer := Source.FPlayer;
  end;
  FUnits.Clear;
  FUnits.AddUnits(Units);
  FUnits.SortUnits;
  { Original accumulates FSelectable rather than clearing it on a new setup. }
  for I := FUnits.GetCount - 1 downto 0 do
  begin

    if CanSelectUnit(TUnit(FUnits.GetUnit(I))) then FSelectable := FSelectable or (Byte(1) shl I);
  end;
end;

constructor TUnitSelectorAAI.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitSelector := nil;
end;

destructor TUnitSelectorAAI.Destroy;
var
  Selector: TUnitSelector;
begin
  Selector := FUnitSelector;
  if Selector <> nil then
  begin
    Selector.Release;
    FUnitSelector := nil;
  end;
  inherited Destroy;
end;

procedure TUnitSelectorAAI.SetUnitSelector(Value: TUnitSelector);
var
  Old: TUnitSelector;
begin
  Old := FUnitSelector;
  if Old <> Value then
  begin
    if Old <> nil then Old.Release;
    Old := Value;
    FUnitSelector := Old;
    if Old <> nil then Old.AddRef;
  end;
end;

destructor TUnitCategoryList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

function TUnitCategoryList.GetCategory(Index: Integer): TUnitIndexList;
begin
  if (Index >= 0) and (Index < Count) then
    Result := TUnitIndexList(Items[Index])
  else Result := nil;
end;

procedure TUnitCategoryList.Clear;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if List^[I] <> nil then TUnitIndexList(List^[I]).Free;
  inherited Clear;
end;

procedure TUnitCategoryList.SortUnits;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    if List^[I] <> nil then TUnitIndexList(List^[I]).SortUnits;
end;

procedure TUnitCategoryList.AddUnit(Category, UnitIndex: Integer);
begin
  while Category >= Count do Add(nil);
  { Original does not reject negative category indexes. }
  if List^[Category] = nil then
      List^[Category] := TUnitIndexList.Create;
  if TUnitIndexList(List^[Category]).IndexOf(UnitIndex) = -1 then
    TUnitIndexList(List^[Category]).Add(UnitIndex);
end;

constructor TUnitSelectionControl.Create;
begin
  inherited Create;
  FRacesEnabled := TBitList.Create;
  FRacesEnabled.Default := True;
  FTypesEnabled := TBitList.Create;
  FTypesEnabled.Default := True;
  FRaceUnits := TUnitCategoryList.Create;
  FTypeUnits := TUnitCategoryList.Create;
  FAllUnits := TUnitIndexList.Create;
  Reset;
end;

destructor TUnitSelectionControl.Destroy;
begin
  Clear;
  FRacesEnabled.Free;
  FTypesEnabled.Free;
  FRaceUnits.Free;
  FTypeUnits.Free;
  FAllUnits.Free;
  inherited Destroy;
end;

procedure TUnitSelectionControl.SetSelectedUnitIndex(Value: Integer);
var
  Resource: TUnitResource;
begin
  if AoWHSSet <> nil then
  begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(Value);
    if Resource <> nil then
      FSelectedUnitIndex := Value
    else FSelectedUnitIndex := -1;
    FSelectedHero := nil;
  end;
end;

procedure TUnitSelectionControl.SetSelectedHero(Value: THero);
begin
  FSelectedHero := Value;
  FSelectedUnitIndex := -1;
end;

function TUnitSelectionControl.GetUnitCategoryList(Category: Shortint): TUnitIndexList;
begin
  if Category >= 0 then Result := FRaceUnits.GetCategory(Category)
  else if Category = -16 then Result := FAllUnits
  else Result := FTypeUnits.GetCategory(Shortint(Abs(Category)) - 1);
end;

function TUnitSelectionControl.GetUnitCategoryEnabled(Category: Shortint): Boolean;
begin
  if Category >= 0 then Result := FRacesEnabled[Category]
  else Result := FTypesEnabled[Shortint(Abs(Category)) - 1];
end;

procedure TUnitSelectionControl.SetUnitCategoryEnabled(Category: Shortint; Value: Boolean);
begin
  if Category >= 0 then FRacesEnabled[Category] := Value
  else FTypesEnabled[Shortint(Abs(Category)) - 1] := Value;
end;

procedure TUnitSelectionControl.Reset;
var
  I: Integer;
begin
  FAlignments := alsAll;
  FMinimumLevel := 0;
  FMaximumLevel := 255;
  FRacesEnabled.Clear;
  FTypesEnabled.Clear;
  FAllUnits.Clear;
  FSelectedUnitIndex := -1;
  FSelectedHero := nil;
  FShowRaceCategories := True;
  FShowAllCategory := False;
  FShowTypeCategories := True;
  if AoWHSMap <> nil then
    for I := 0 to AoWHSMap.FRaces.GetCount - 1 do
      if AoWHSMap.FRaces.GetRace(I) <> nil then
        FRacesEnabled[I] := AoWHSMap.FRaces.GetRace(I).FEnabled;
end;

procedure TUnitSelectionControl.DisableAllCategories;
var
  I: Integer;
begin
  for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do FRacesEnabled[I] := False;
  for I := 0 to FTypesEnabled.Count - 1 do FTypesEnabled[I] := False;
end;

procedure TUnitSelectionControl.UpdateSelection;
var
  Index: Integer;
  Resources: TUnitResourceList;
  I, J: Integer;
  Resource: TUnitResource;
  UnitType_: TUnitType;
begin
  FRaceUnits.Clear;
  FTypeUnits.Clear;
  FAllUnits.Clear;
  Resources := AoWHSSet.FUnitResources;
  { Original intersects FAlignments with itself, ignoring the unit alignment. }
  if FShowAllCategory then
    for I := 0 to Resources.GetCount - 1 do
      if Resources.GetUnitResource(I) <> nil then
      begin
        Resource := Resources.GetUnitResource(I);
        if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
          (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
          (FAlignments * FAlignments <> []) then FAllUnits.Add(I);
      end;
  if FShowTypeCategories then
    for I := 0 to Resources.GetCount - 1 do
      if Resources.GetUnitResource(I) <> nil then
      begin
        Resource := Resources.GetUnitResource(I);
        if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
          (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
          (FAlignments * FAlignments <> []) then FTypeUnits.AddUnit(Integer(Resource.FUnitType), I);
      end;
  if FShowRaceCategories then
    { Original bounds this race loop by the unit-resource count. }
    for I := 0 to Resources.GetCount - 1 do
      if FRacesEnabled[I] and (AoWHSSet.FRaceResources.GetRaceResource(I) <> nil) then
        for J := 0 to AoWHSSet.FRaceResources.GetRaceResource(I).FUnitIndexes.Count - 1 do
        begin
          Index := AoWHSSet.FRaceResources.GetRaceResource(I).FUnitIndexes[J];
          if Index <> -1 then
          begin
            Resource := Resources.GetUnitResource(Index);
            if (Smallint(Shortint(Resource.FLevel)) >= Smallint(FMinimumLevel)) and
              (Smallint(Shortint(Resource.FLevel)) <= Smallint(FMaximumLevel)) and
              (FAlignments * FAlignments <> []) then FRaceUnits.AddUnit(I, Index);
          end;
        end;
  FTypeUnits.SortUnits;
  FRaceUnits.SortUnits;
  FAllUnits.SortUnits;
  Clear;
  if FShowAllCategory and ((FAllUnits.Count <> 0) or FShowEmptyCategories) then
    AddObject('All', TObject(-16));
  if FShowTypeCategories then
    for UnitType_ := Low(TUnitType) to High(TUnitType) do
      if FTypesEnabled[Ord(UnitType_)] and
        (FTypeUnits.GetCategory(Ord(UnitType_)) <> nil) and
        ((FTypeUnits.GetCategory(Ord(UnitType_)).Count <> 0) or FShowEmptyCategories) then
        AddObject(TranslateRStr(UnitTypePluralRStr[UnitType_]), TObject(-(Ord(UnitType_) + 1)));
  if FShowRaceCategories then
    for I := 0 to AoWHSSet.FRaceResources.GetCount - 1 do
      if FRacesEnabled[I] and (FRaceUnits.GetCategory(I) <> nil) and
        ((FRaceUnits.GetCategory(I).Count <> 0) or FShowEmptyCategories) then
        AddObject(AoWHSSet.FRaceResources.GetRaceResource(I).FRaceName, TObject(I));
end;

constructor TActivateAbilityInfo.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FReferences := 1;
end;

function TActivateAbilityInfo.AddRef: Integer;
begin
  Inc(FReferences);
  Result := FReferences;
end;

function TActivateAbilityInfo.Release: Integer;
var
  Count: Integer;
begin
  Dec(FReferences);
  Count := FReferences;
  Result := Count;
  if Count = 0 then Destroy;
end;

destructor TCustomAbilityList.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TCustomAbilityList.Clear;
begin
  inherited Clear;
  SetAbCount(0);
end;

procedure TCustomAbilityList.SetAbSet(Index: Integer; Value: Byte);
asm
  CMP EDX,[EAX].FAbilityCount
  JAE @@grow
@@set:
  MOV EAX,[EAX].FAbilityBits
  OR CL,CL
  JZ @@clear
  BTS [EAX],EDX
  RET
@@clear:
  BTR [EAX],EDX
  RET
@@grow:
  PUSH EAX
  PUSH EDX
  PUSH ECX
  INC EDX
  CALL TCustomAbilityList.SetAbCount
  POP ECX
  POP EDX
  POP EAX
  JMP @@set
end;

function TCustomAbilityList.GetAbSet(A1: Integer): Boolean;
{ needs: Boolean result; P2 has an unmarked procedure override. }
asm
  CMP EDX,[EAX].FAbilityCount
  JAE @@none
  MOV EAX,[EAX].FAbilityBits
  BT [EAX],EDX
  SBB EAX,EAX
  AND EAX,1
  RET
@@none:
  MOV AL,0
  AND EAX,1
end;

procedure TCustomAbilityList.SetAbCount(Value: Integer);
var
  OldSize, NewSize: Integer;
begin
  { Original assertion accepts every Integer: its bounds predicate uses OR. }
























































































































  Assert(not ((Value < 0) and (Value >= $07FFFFFF)), 'Invalid AbCount Value (TArrayList)');
  OldSize := (FAbilityCount + 7) shr 3;
  NewSize := (Value + 7) shr 3;
  if NewSize <> OldSize then
  begin
    ReallocMem(FAbilityBits, NewSize);
    if NewSize > OldSize then
      FillChar(PChar(FAbilityBits)[OldSize], NewSize - OldSize, 0);
  end;
  FAbilityCount := Value;
end;
function TCustomAbilityList.GetAbCount: Integer;
begin
  Result := FAbilityCount;
end;
procedure TCustomAbilityList.AssignAb(Source: TCustomAbilityList);
var
  Count, I: Integer;
begin
  if Source.GetAbCount > GetAbCount then Count := Source.GetAbCount
  else Count := GetAbCount;
  for I := 0 to Count - 1 do
    if Source.GetAbSet(I) <> GetAbSet(I) then
      SetAbSet(I, Ord(Source.GetAbSet(I)));
end;
function TCustomAbilityList.CompareAb(Source: TCustomAbilityList): Boolean;
begin
  Result := Source.GetAbCount = FAbilityCount;
  if Result then Result := CompareMem(FAbilityBits, Source.FAbilityBits, (GetAbCount + 7) shr 3);
end;
function TCustomAbilityList.ComposeAb(Source: TCustomAbilityList): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to Source.GetAbCount - 1 do
    if Source.GetAbSet(I) and not GetAbSet(I) then
    begin
      SetAbSet(I, 1);
      Result := True;
    end;
end;
procedure TCustomAbilityList.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    if smRead in Stream.StorageMode then
    begin
      Stream.rwInteger(I, 2);
      SetAbCount(I);
      Stream.rwData(FAbilityBits^, (FAbilityCount + 7) shr 3, 3);
    end
    else
    begin
      Stream.rwInteger(FAbilityCount, 2);
      Stream.rwData(FAbilityBits^, (FAbilityCount + 7) shr 3, 3);
    end;
  end;
  if not (smPreview in Stream.StorageMode) then
    for I := 0 to FAbilityCount - 1 do
      if GetAbSet(I) and (AoWHSSet.FAbilityControl.GetAbility(I) = nil) then
        SetAbSet(I, 0);
end;
function TCustomAbilityList.GetItemString: string;
var
  I: Integer;
begin
  Result := '';
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then Result := Result + IntToStr(I) + ',';
  if Result <> '' then Result := System.Copy(Result, 1, Length(Result) - 1);
end;
procedure TCustomAbilityList.SetItemString(S: string);
var
  Part: string;
  P: Integer;
begin
  Clear;
  P := Pos(',', S);
  while S <> '' do
  begin
    if P <> 0 then
    begin
      Part := System.Copy(S, 1, P - 1);
      Delete(S, 1, P);
    end
    else
    begin
      Part := S;
      S := '';
    end;
    if Part <> '' then SetAbSet(StrToInt(Part), 1);
    P := Pos(',', S);
  end;
end;
procedure TCustomAbilityList.ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes);
var
  I: Integer;
  Ability: TAbility;
begin
  TStrings(A1).Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      if TP1AbilityKinds(Ability.FSelectionTypes) * TP1AbilityKinds(A2) <> [] then
        TStrings(A1).AddObject(Ability.GetName(nil), TObject(I));
    end;
end;
function TAbilityData.GetAbilityID: Integer;
asm
  OR EAX,-1
end;
procedure TAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
end;
constructor TAbility.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDescription := TStringList.Create;
  FSFXLibrary := TSFXLibrary.Create(nil);
  FImageSequences := TImageSequenceList.Create(AoWHSSet.ImageLibraryManager, nil);
end;
destructor TAbility.Destroy;
begin
  FDescription.Free;
  FSFXLibrary.Free;
  FImageSequences.Free;
  inherited Destroy;
end;
procedure TAbility.ShowInfo(Owner: TAbilityOwner; Font: TImageLibraryFont; X, Y: Integer; const Surface: TSurfaceDesc);
begin
  Font.SetText(X, Y, Self.GetName(Owner), Surface);
end;
function TAbility.GetSourceName(A1: TAbilityOwner): string;
begin
  Result := A1.GetOwnerName;
end;
procedure TAbility.SetAb(Owner: TAbilityOwner; Index: Integer; Value: Byte);
begin
  Owner.SetAbSet(Index, Value);
end;
function TAbility.GetControlType(Owner: TAbilityOwner): TAbilityControlType;
asm
  MOV AL,P1EmptyControlType
end;
function TAbility.GetCombatMode(A1: TAbilityOwner): TCombatMode;
asm
  XOR EAX,EAX
end;
function TAbility.GetDamageValue(A1, A2: TAbstractUnit): Integer;
asm
  XOR EAX,EAX
end;
procedure TAbility.GetDamageValueEx(A1, A2: TAbstractUnit; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  with PP1DamageValues(@A4)^ do
  begin
    Damage := 0;
    Experience := 0;
    CounterDamage := 0;
    CounterExperience := 0;
    { Original leaves Reserved untouched. }
  end;
end;
procedure TAbility.fcGetDamageValueEx(A1, A2: TCombatObject; A3: TWallSituation; var A4: TAbilityDamageValues);
begin
  with PP1DamageValues(@A4)^ do
  begin
    Damage := 0;
    Experience := 0;
    CounterDamage := 0;
    CounterExperience := 0;
    { Original leaves Reserved untouched. }
  end;
end;
function TAbility.fcValidRoundDistance(A1, A2: TCombatObject): Boolean;
var
  Distance: Integer;
  Value: Boolean;
begin
  Distance := TP1FastRound(@TFastCombat.GetRoundDistance)(TFastCombat(TCombatObject(A1).FCombat));
  if TP1DistanceCombatView(A1).Speed >= 32 then Inc(Distance, 2);
  Value := Distance >= TP1DistanceCombatView(A2).LastRound;
  if Value and (TCombatObject(A1) is TCombatUnit) and
    (TObject(TCombatUnit(A1).FUnit) is THero) then
    Value := Value and (((Byte(TCombatObject(A1).FStatus) and $10) <> 0) or
      (TP1DistanceCombatView(A1).LastRound <=
       TP1FastRound(@TFastCombat.GetRoundDistance)(TFastCombat(TCombatObject(A1).FCombat)) + 2));
  asm MOV AL,Value end;
end;
function TAbility.fcGetDamageValue(Source, Target: TCombatObject; Defensive: Boolean): Integer;
var
  Values: TAbilityDamageValues;
begin
  fcGetDamageValueEx(Source, Target, TWallSituation(Defensive), Values);
  Result := Values.SourceDamage;
end;
procedure TAbility.tcGetDamageValueEx(A1, A2: TCombatObject; var A3: TAbilityDamageValues);
begin
  fcGetDamageValueEx(A1, A2, wsNone, A3);
end;
function TAbility.tcGetDamageValue(Source, Target: TCombatObject): Integer;
var
  Values: TP1DamageValues;
begin
  TP1AbilityView(Self).tcGetDamageValueEx(Source, Target, Values);
  Result := Values.Damage;
end;
procedure TAbility.GetCombatInfo(A1: TAbilityOwner; var A2: TAbilityCombatInfo);
begin
  with A2 do
  begin
    Attack := -1;
    Damage := -1;
    DamageTypes := [];
    RepeatCount := -1;
  end;
end;
function TAbility.GetWallCombatFeatures(A1: TAbilityOwner): TWallCombatFeatures;
asm
  MOV AL,P1EmptyWallFeatures
end;
function TAbility.CanExpand(A1: TAbilityOwner): Boolean;
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JNZ @@none
  MOV EAX,ESI
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+$8C]
  AND AX,[EBX].FSelectionTypes
  MOV DX,P1EmptySelectionTypes
  CMP DX,AX
  JNZ @@yes
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
  RET
@@yes:
  MOV AL,1
  POP ESI
  POP EBX
end;
function TAbility.ExpandName(A1: TAbilityOwner): string;
begin
  Result := FAbilityName;
end;
function TAbility.ExpandCost(A1: TAbilityOwner): Integer;
asm
  MOV EAX,[EAX].FSkillPointCost
end;
function TAbility.Expand(A1: TAbilityOwner): Boolean;
begin
  A1.SetAbSet(FAbilityID, 1);
  Result := True;
end;
function TAbility.Remove(A1: TAbilityOwner): Boolean;
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JZ @@none
  XOR ECX,ECX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV EBX,[EAX]
  CALL DWORD PTR [EBX+$50]
  MOV AL,1
  POP ESI
  POP EBX
  RET
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
end;
function TAbility.GetInherent(A1: TAbilityOwner): Boolean;
asm
  MOV EAX,[EAX].FAbilityID
  XCHG EDX,EAX
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
end;
function TAbility.GetInherentLevel(Owner: TAbilityOwner): Integer;
asm
  XOR EAX,EAX
end;
function TAbility.GetSkillPoints(A1: TAbilityOwner): Integer;
asm
  PUSH EBX
  PUSH ESI
  MOV ESI,EDX
  MOV EBX,EAX
  MOV EDX,[EBX].FAbilityID
  MOV EAX,ESI
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
  TEST AL,AL
  JZ @@none
  MOV EAX,[EBX].FSkillPointCost
  POP ESI
  POP EBX
  RET
@@none:
  XOR EAX,EAX
  POP ESI
  POP EBX
end;
function TAbility.AbilityDataClass: TEObjectClass;
asm
  XOR EAX,EAX
end;
function TAbility.GetName(A1: TAbilityOwner): string;
begin
  Result := FAbilityName;
end;
function TAbility.GetAttack(A1: TAbilityOwner): Shortint;
asm
  XOR EAX,EAX
end;
function TAbility.GetDefense(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
function TAbility.GetResistance(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
function TAbility.GetDamage(A1: TAbilityOwner): Shortint;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
function TAbility.GetMoveTypes(A1: TAbilityOwner): TMoveTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AL,P1EmptyMoveTypes
end;
procedure TAbility.GetHidden;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
function TAbility.GetLevel(A1: TAbilityOwner): Integer;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
procedure TAbility.GetOffensiveStrength(A1: TAbilityOwner; var A2: Integer; var A3: TDamageTypes);
begin
  A2 := 0;
  A3 := P1EmptyDamageTypes;
end;
procedure TAbility.ListInfo(A1: TStrings; A2: TAbilityInfoMode);
var
  Info: TP1CombatInfo;
  Strength: Integer;
  Types: TDamageTypes;
  DamageNames: string;
  DamageType_: TDamageType;
begin
  TStrings(A1).Add('Name: ' + Self.GetName(nil));
  TStrings(A1).Add('-------------------------------------------------');
  if aimID in A2 then TStrings(A1).Add('ID: ' + IntToStr(FAbilityID));
  TStrings(A1).Add('Type: ' + TranslateRStr(TAbilityTypeRStr[TP1AbilityView(Self).GetAbilityType]));
  if Self.GetAttack(nil) <> 0 then
    TStrings(A1).Add('Attack modifier: ' + IntToStr(Self.GetAttack(nil)));
  if Self.GetDefense(nil) <> 0 then
    TStrings(A1).Add('Defense modifier: ' + IntToStr(Self.GetDefense(nil)));
  if Self.GetDamage(nil) <> 0 then
    TStrings(A1).Add('Damage modifier: ' + IntToStr(Self.GetDamage(nil)));
  if Self.GetResistance(nil) <> 0 then
    TStrings(A1).Add('Resistance modifier: ' + IntToStr(Self.GetResistance(nil)));
  if aimDescription in A2 then
  begin
    TStrings(A1).Add('Description: ');
    TStrings(A1).AddStrings(FDescription);
  end;
  if TP1AbilityView(Self).GetCombatMode(nil) <> cmNone then
    TStrings(A1).Add('Combat mode: ' + TranslateRStr(TCombatModeRStr[TP1AbilityView(Self).GetCombatMode(nil)]));
  if aimStatistics in A2 then
  begin
    TP1AbilityView(Self).GetCombatInfo(nil, Info);
    if Info.Attack <> -1 then TStrings(A1).Add('Attack: ' + IntToStr(Info.Attack));
    if Info.Damage <> -1 then TStrings(A1).Add('Damage: ' + IntToStr(Info.Damage));
    if Info.RepeatCount <> -1 then TStrings(A1).Add('Repeat: ' + IntToStr(Info.RepeatCount));
    if Info.Types <> [] then
    begin
      DamageNames := '';
      for DamageType_ := Low(TDamageType) to High(TDamageType) do
        if DamageType_ in Info.Types then
        begin
          if DamageNames <> '' then DamageNames := DamageNames + ',';
          DamageNames := DamageNames + TranslateRStr(TDamageTypeRStr[DamageType_]);
        end;
      TStrings(A1).Add('Damage Types: ' + DamageNames);
    end;
  end;
  if aimStrength in A2 then
  begin
    TP1AbilityView(Self).GetOffensiveStrength(nil, Strength, Types);
    if Strength <> 0 then TStrings(A1).Add('Strength: ' + IntToStr(Strength));
  end;
end;
function TAbility.GetEnabled(A1: TAbilityOwner): Boolean;
asm
  MOV EAX,[EAX].FAbilityID
  XCHG EDX,EAX
  MOV ECX,[EAX]
  CALL DWORD PTR [ECX+$4C]
end;
function TAbility.GetImmunityTypes(A1: TAbilityOwner): TDamageTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AX,P1EmptyDamageTypes
end;
function TAbility.GetProtectionTypes(A1: TAbilityOwner): TDamageTypes;
{ needs: set result; preserve existing procedure-header return ABI. }
asm
  MOV AX,P1EmptyDamageTypes
end;
procedure TAbility.ListSpells;
begin
end;
function TAbility.GetAbilityType: TAbilityType;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
procedure TAbility.CombatObjectDestroyed(A1: TCombatObject);
begin
end;
procedure TAbility.fcPrefetchCombatCommands(A1: TFastCombatCommandList);
begin
end;
function TAbility.fcExecuteCombatCommand(A1: TCombatObject; A2: TFastCombatCommand): Boolean;
{ needs: function result; existing unmarked derived procedure headers are retained. }
asm
  XOR EAX,EAX
end;
procedure TAbility.Execute;
begin
end;
procedure TAbility.NewDay(A1: TAbilityOwner);
begin
end;
procedure TAbility.NewTurn(A1: TAbilityOwner; A2: Shortint);
begin
end;
procedure TAbility.NewCombatTurn(A1: TCombatObject; A2: Shortint);
begin
end;
procedure TAbility.CombatDone(A1: TCombatObject);
begin
end;
function TAbility.CanActivate(A1: TAbilityOwner; var A2: string): Boolean;
begin
  A2 := '';
  Result := acAction in GetControlType(A1);







end;
function TAbility.Activate(A1: TAbilityOwner; var A2: string): Boolean;
var
  Info: TActivateAbilityInfo;
begin
  { The original reports successful activation after releasing the notification. }
  if CanActivate(A1, A2) then
  begin
    Info := TActivateAbilityInfo.Create(nil);
    Info.FAbilityID := FAbilityID;
    if A1 is TAbstractUnit then
      Info.FUnitID := TAbstractUnit(A1).FUnitID
    else Info.FUnitID := 0;
    TEventList(AoWHSMap.FOnActivateAbility).TriggerNotifyEvents(Info);
    Info.Release;
    Result := True;
  end
  else Result := False;
end;
function TAbility.CanActivateCombat(A1: TAbilityOwner; var A2: string): Boolean;
begin
  A2 := '';
  Result := acCombatAction in GetControlType(A1);








end;
function TAbility.ActivateCombat(Owner: TAbilityOwner; var Reason: string): Boolean;
var
  Info: TActivateAbilityInfo;
begin
  if TP1AbilityView(Self).CanActivateCombat(Owner, Reason) then
  begin
    Info := TActivateAbilityInfo.Create(nil);
    Info.FAbilityID := FAbilityID;
    if Owner is TAbstractUnit then
      Info.FUnitID := TAbstractUnit(Owner).FUnitID
    else Info.FUnitID := 0;
    AoWHSMap.FCombatMap.FAbilityActivatedEvents.TriggerNotifyEvents(Info);
    Info.Release;
    Result := True;
  end
  else Result := False;
end;
procedure TAbility.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStrings(FDescription, 5);
  Stream.rwInteger(FSkillPointCost, 6);
  Stream.rwEObject(FSFXLibrary, 7);
  Stream.rwStreamProc(8, FImageSequences.LoadFromStream, FImageSequences.SaveToStream);
  Stream.rwData(FSelectionTypes, 2, 9);
end;
constructor TAbilityOwner.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;
procedure TAbilityOwner.Clear;
begin
  inherited Clear;
  while FAbilityData <> nil do RemoveAbilityData(FAbilityData);
end;
function TAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin
  Result := [];
end;
function TAbilityOwner.GetOwnerName: string;
begin Result := ''; end;
procedure TAbilityOwner.ValidateOwnerTypeAbilities;
var
  Types: TAbilitySelectionTypes;
  I: Integer;
begin
  Types := GetAbilitySelectionTypes;
  for I := GetAbCount - 1 downto 0 do
    if GetAbSet(I) and (AoWHSSet.FAbilityControl.GetAbility(I).FSelectionTypes * Types = []) then
      SetAbSet(I, 0);
end;
function TAbilityOwner.GetAbilityData(AbilityID: Integer): TAbilityData;
var
  Data: TAbilityData;
begin
  Data := FAbilityData;
  while (Data <> nil) and (Data.GetAbilityID <> AbilityID) do Data := Data.FNext;
  Result := Data;
end;
procedure TAbilityOwner.AssignAb(Source: TAbilityOwner);
var
  I: Integer;
  Data: TAbilityData;
begin
  while FAbilityData <> nil do RemoveAbilityData(FAbilityData);
  SetAbCount(Source.GetAbCount);
  for I := Source.GetAbCount - 1 downto 0 do
    if Source.GetAbSet(I) <> GetAbSet(I) then SetAbSet(I, Ord(Source.GetAbSet(I)));
  Data := Source.FAbilityData;
  while Data <> nil do
  begin
    AddAbilityData(TAbilityData(Data.Copy(AoWEngine)));
    Data := Data.FNext;
  end;
end;
procedure TAbilityOwner.AddAbilityData(Data: TAbilityData);
begin
  Data.FNext := FAbilityData;
  FAbilityData := Data;
end;
procedure TAbilityOwner.RemoveAbilityData(Data: TAbilityData);
var
  Current, Previous: TAbilityData;
begin
  Current := FAbilityData;
  Previous := nil;
  while (Current <> nil) and (Current <> Data) do
  begin
    Previous := Current;
    Current := Current.FNext;
  end;
  if Current = Data then
  begin
    { Original dereferences nil when Data is nil. }
    if Previous <> nil then Previous.FNext := Current.FNext
    else FAbilityData := Current.FNext;
    Current.Free;
  end;
end;
procedure TAbilityOwner.RemoveAbilityDataID(AbilityID: Integer);
var
  Current, Previous: TAbilityData;
begin
  Current := FAbilityData;
  Previous := nil;
  while (Current <> nil) and (Current.GetAbilityID <> AbilityID) do
  begin
    Previous := Current;
    Current := Current.FNext;
  end;
  if (Current <> nil) and (Current.GetAbilityID = AbilityID) then
  begin
    if Previous <> nil then Previous.FNext := Current.FNext
    else FAbilityData := Current.FNext;
    Current.Free;
  end;
end;
procedure TAbilityOwner.SetAbSet(A1: Integer; A2: Byte);
begin
  inherited SetAbSet(A1, A2);
end;
function TAbilityOwner.Execute: Integer;
begin
  Result := 1;
end;
procedure TAbilityOwner.ReadWrite(Stream: Engine.TEStorageStream);
var
  Previous, Data: TAbilityData;
  IDs: TIntegerList;
  I: Integer;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smCompare] = [smRead] then
  begin
    { Original tests property 3 before reading the data-ID list at $31. }
    if Stream.PropertyTable.PropertyExist(3) then
    begin
      Previous := nil;
      IDs := TIntegerList.Create;
      Stream.rwStreamProc($31, IDs.LoadFromStream, IDs.SaveToStream);
      for I := 0 to IDs.Count - 1 do
      begin
        Stream.rwCreateEObject(TEObject(Data), nil, IDs[I] + $32);
        if Previous <> nil then Previous.FNext := Data;
        Previous := Data;
        if FAbilityData = nil then FAbilityData := Data;
      end;
      IDs.Free;
    end;
  end
  else if Stream.StorageMode * [smWrite] = [smWrite] then
  begin
    if FAbilityData <> nil then
    begin
      IDs := TIntegerList.Create;
      Data := FAbilityData;
      while Data <> nil do
      begin
        IDs.Add(Data.GetAbilityID);
        Data := Data.FNext;
      end;
      Stream.rwStreamProc($31, IDs.LoadFromStream, IDs.SaveToStream);
      Data := FAbilityData;
      while Data <> nil do
      begin
        Stream.rwCreateEObject(TEObject(Data), nil, Data.GetAbilityID + $32);
        Data := Data.FNext;
      end;
      IDs.Free;
    end;
  end
  else if Stream.StorageMode * [smCompare] = [smCompare] then
  begin
    Data := FAbilityData;
    while Data <> nil do
    begin
      Stream.rwCreateEObject(TEObject(Data), nil, Data.GetAbilityID + $32);
      Data := Data.FNext;
    end;
  end;
end;
procedure TAbilityOwner.UpdateDefaultAbilities(Source: TAbilityOwner);
{ conflict: procedure TAbilityOwner.UpdateDefaultAbilities(A1: TCustomAbilityList); }
var
  I: Integer;
  Data: TAbilityData;
begin
  for I := Source.GetAbCount - 1 downto 0 do
    if Source.GetAbSet(I) and (not GetAbSet(I) or (Source.GetAbLevel(I) > GetAbLevel(I))) then
    begin
      Data := Source.GetAbilityData(I);
      if Data <> nil then
      begin
        RemoveAbilityDataID(I);
        Data := TAbilityData(Data.Copy(AoWEngine));
        AddAbilityData(Data);
      end;
      SetAbSet(I, 1);
    end;
end;
procedure TAbilityOwner.Changed;
begin
end;
function TAbilityOwner.ExpandAbility(AbilityID: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).Expand(Self);
  if Result then Changed;
end;
function TAbilityOwner.RemoveAbility(A1: Integer): Boolean;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(A1).Remove(Self);
  if Result then Changed;
end;
function TAbilityOwner.GetAbAttackAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetAttack(Self);
end;
function TAbilityOwner.GetAbDefenseAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetDefense(Self);
end;
function TAbilityOwner.GetAbResistanceAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetResistance(Self);
end;
function TAbilityOwner.GetAbDamageAll: Shortint;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to GetAbCount - 1 do
    if GetAbEnabled(I) then Result := Result + AoWHSSet.FAbilityControl.GetAbility(I).GetDamage(Self);
end;
function TAbilityOwner.GetAbMoveTypesAll: TMoveTypes;
begin
  Result := [];
  if GetAbEnabled(0) then Result := Result + [mtWalking];
  if GetAbEnabled(1) or GetAbEnabled(165) or GetAbEnabled(59) then Result := Result + [mtFlying];
  if GetAbEnabled(2) or GetAbEnabled(23) or GetAbEnabled(164) or GetAbEnabled(166) then Result := Result + [mtSwimming];
  if GetAbEnabled(3) or GetAbEnabled(157) then Result := Result + [mtForestry];
  if GetAbEnabled(4) or GetAbEnabled(157) then Result := Result + [mtCaveCrawling];
  if GetAbEnabled(5) or GetAbEnabled(157) then Result := Result + [mtMountaineering];
  if GetAbEnabled(7) or GetAbEnabled(163) then Result := Result + [mtTunneling];
  if GetAbEnabled(42) then Result := Result + [mtLavaCrossing];
end;
function TAbilityOwner.GetAbWallCombatFeatures: TWallCombatFeatures;
var
  I: Integer;
begin
  Result := [];
  { Original intersects into an empty set, so the result is always empty. }
  for I := GetAbCount - 1 downto 0 do
    if GetAbEnabled(I) then Result := Result * AoWHSSet.FAbilityControl.GetAbility(I).GetWallCombatFeatures(Self);
end;
function TAbilityOwner.GetAbProtectionTypesAll: TDamageTypes;
begin
  Result := [];
  if GetAbEnabled(77) or GetAbEnabled(166) then Result := Result + [dtPhysical];
  if GetAbEnabled(71) or GetAbEnabled(167) then Result := Result + [dtFire];
  if GetAbEnabled(75) then Result := Result + [dtMagic];
  if GetAbEnabled(76) then Result := Result + [dtCold];
  if GetAbEnabled(74) then Result := Result + [dtLightning];
  if GetAbEnabled(73) then Result := Result + [dtPoison];
  if GetAbEnabled(70) or GetAbEnabled(158) then Result := Result + [dtDeath];
  if GetAbEnabled(72) then Result := Result + [dtHoly];
end;
function TAbilityOwner.GetAbImmunityTypesAll: TDamageTypes;
begin
  Result := [];
  if GetAbEnabled(13) then Result := Result + [dtPhysical];
  if GetAbEnabled(7) or GetAbEnabled(163) then Result := Result + [dtFire];
  if GetAbEnabled(6) then Result := Result + [dtMagic];
  if GetAbEnabled(8) then Result := Result + [dtCold];
  if GetAbEnabled(9) then Result := Result + [dtLightning];
  if GetAbEnabled(10) then Result := Result + [dtPoison];
  if GetAbEnabled(11) then Result := Result + [dtDeath];
  if GetAbEnabled(12) then Result := Result + [dtHoly];
end;
function TAbilityOwner.GetAbName(AbilityID: Integer): string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(Self);
end;
function TAbilityOwner.GetAbAttack(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetAttack(Self);
end;
function TAbilityOwner.GetAbDefense(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetDefense(Self);
end;
function TAbilityOwner.GetAbResistance(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetResistance(Self);
end;
function TAbilityOwner.GetAbDamage(AbilityID: Integer): Shortint;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetDamage(Self);
end;
function TAbilityOwner.GetAbMoveTypes(AbilityID: Integer): TMoveTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetMoveTypes(Self);
end;
function TAbilityOwner.GetAbProtectionTypes(AbilityID: Integer): TDamageTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetProtectionTypes(Self);
end;
function TAbilityOwner.GetAbImmunityTypes(AbilityID: Integer): TDamageTypes;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetImmunityTypes(Self);
end;
function TAbilityOwner.GetAbLevel(AbilityID: Integer): Integer;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetLevel(Self);
end;
function TAbilityOwner.GetAbEnabled(AbilityID: Integer): Boolean;
begin
  Result := GetAbSet(AbilityID) and AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetEnabled(Self);
end;
procedure TAbilityOwner.TriggerNewDay;
var
  I: Integer;
begin
  try
    for I := 0 to GetAbCount - 1 do
      if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewDay(Self);
  except
  end;
end;
procedure TAbilityOwner.TriggerNewTurn(Player: Shortint);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewTurn(Self, Player);
end;
procedure TAbilityOwner.TriggerNewCombatTurn(Combat: TCombatObject; Player: Shortint);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).NewCombatTurn(Combat, Player);
end;
procedure TAbilityOwner.TriggerCombatDone(Combat: TCombatObject);
var
  I: Integer;
begin
  for I := 0 to GetAbCount - 1 do
    if GetAbSet(I) then AoWHSSet.FAbilityControl.GetAbility(I).CombatDone(Combat);
end;
procedure TAbilityOwner.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then TriggerNewDay
  else if Msg.MsgID = $20020002 then TriggerNewTurn(Shortint(Msg.Value));
end;
procedure TAbilityOwner.ListAbilitiesEx(A1: TStrings; A2: TAbilitySelectionTypes);
var
  I: Integer;
  Ability: TAbility;
begin
  A1.Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      if Ability.FSelectionTypes * A2 <> [] then
        A1.AddObject(Ability.GetName(Self), TObject(I));
    end;
end;
procedure TAbilityOwner.ListAbilities(Text: TStrings);
var
  I: Integer;
  Ability: TAbility;
  Name: string;
begin
  Text.Clear;
  for I := 0 to FAbilityCount - 1 do
    if GetAbSet(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      Name := Ability.GetName(Self);
      if Name <> '' then Text.AddObject(Name, TObject(I));
    end;
end;
function TAbilityTypeList.GetAbility(A1: Integer): TAbility;
begin Result := TAbility(List^[A1]); end;
constructor TAbilityControl.Create(AOwner: Engine.TECustomNode);
var
  Kind: TAbilityType;
begin
  inherited Create(AOwner);
  FAbilities := TList.Create;
  for Kind := Low(TAbilityType) to High(TAbilityType) do
    FAbilitiesByType[Kind] := TAbilityTypeList.Create;
end;
destructor TAbilityControl.Destroy;
var
  Kind: TAbilityType;
begin
  UnregisterAll;
  for Kind := Low(TAbilityType) to High(TAbilityType) do FAbilitiesByType[Kind].Free;
  FAbilities.Free;
  inherited Destroy;
end;
procedure TAbilityControl.ReadWrite(Stream: Engine.TEStorageStream);
var
  I: Integer;
begin
  inherited ReadWrite(Stream);
  for I := 0 to FAbilities.Count - 1 do
    if FAbilities[I] <> nil then Stream.rwEObject(TAbility(FAbilities[I]), I + 10);
end;
function TAbilityControl.GetCount: Integer;
begin
  Result := FAbilities.Count;
end;
function TAbilityControl.GetAbility(Index: Integer): TAbility;
var
  Items: PIntegerArray;
begin
  Assert(Index >= 0, 'Invalid AbilityID');
  if Index < FAbilities.Count then
  begin
    Items := PIntegerArray(FAbilities.List);
    Result := TAbility(Items^[Index]);
  end
  else Result := nil;
end;

procedure TAbilityControl.RegisterAbility(Ability: TAbility);
var
  ID: Integer;
begin
  ID := Ability.FAbilityID;
  if ID <> -1 then
  begin
    with FAbilities do
      if (ID < Count) and (Items[ID] <> nil) then
        raise Exception.Create('Ability already registered (' + IntToStr(ID) + ')');
    while ID >= FAbilities.Count do FAbilities.Add(nil);
    FAbilities.List^[ID] := Ability;
    FAbilitiesByType[Ability.GetAbilityType].Add(Ability);
    Ability.FImageSequences.LinkToIL;
  end
  else raise Exception.Create('Invalid AbilityID (' + Ability.ClassName + ')');
end;

procedure TAbilityControl.UnregisterAbility(Ability: TAbility);
var
  ID: Integer;
begin
  ID := Ability.FAbilityID;
  if ID <> -1 then
  begin
    if (ID < 0) or (ID >= FAbilities.Count) or (FAbilities[ID] <> Ability) then
      raise Exception.Create('Cannot Unregister Ability (' + IntToStr(ID) + ')');
    if FAbilities.List^[ID] <> nil then
    begin
      FAbilitiesByType[Ability.GetAbilityType].Remove(Ability);
      TAbility(FAbilities.List^[ID]).FImageSequences.ReleaseIL;
      TObject(FAbilities.List^[ID]).Free;
      FAbilities.List^[ID] := nil;
    end;
  end
  else raise Exception.Create('Invalid AbilityID (' + Ability.ClassName + ')');
end;

procedure TAbilityControl.UnregisterAll;
var
  I: Integer;
begin
  for I := FAbilities.Count - 1 downto 0 do
    if FAbilities[I] <> nil then UnregisterAbility(FAbilities[I]);
end;

procedure TAbilityControl.UnregisterAbilityID(ID: Integer);
begin
  if Integer(FAbilities.List^[ID]) <> 0 then UnregisterAbility(FAbilities.List^[ID]);
end;

procedure TAbilityControl.ListAbilities(Text: TStrings; Types: TAbilitySelectionTypes);
var
  I: Integer;
begin
  Text.Clear;
  with FAbilities do
    for I := 0 to Count - 1 do
      if List^[I] <> nil then
        if (TAbility(List^[I]).FSelectionTypes * Types <> []) or
          ((Types = [Low(TAbilitySelectionType)..High(TAbilitySelectionType)]) and
          (TAbility(List^[I]).FSelectionTypes = [])) then
          Text.AddObject(TAbility(List^[I]).GetName(nil), TObject(I));
end;

function CompareAbilityNames(Item1, Item2: Pointer): Integer;
begin
  Result := CompareStr(TAbility(Item1).GetName(nil), TAbility(Item2).GetName(nil));
end;

procedure TAbilityControl.ListAbilityInfo(Text: TStrings; SortByName: Boolean; Mode: TAbilityInfoMode);
var
  List: TList;
  I: Integer;
begin
  List := TList.Create;
  for I := 0 to FAbilities.Count - 1 do
    if FAbilities.List^[I] <> nil then List.Add(FAbilities.List^[I]);
  if SortByName then List.Sort(CompareAbilityNames);
  { Original frees the temporary list only after all ability callbacks succeed. }
  for I := 0 to List.Count - 1 do
  begin
    TAbility(List[I]).ListInfo(Text, Mode);
    Text.Add('-------------------------------------------------');
    Text.Add('');
  end;
  List.Free;
end;

