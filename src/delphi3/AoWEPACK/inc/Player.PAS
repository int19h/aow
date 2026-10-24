function TPlayerStructureList.GetStructure(Index: Integer): TPlayerStructure;
begin
  Result := FChildren.List^[Index];
end;

function TArmyList.GetArmy(Index: Integer): TArmy;
begin
  Result := FChildren.List^[Index];
end;

constructor TDiplomaticRelationList.Create;
begin
  inherited Create;
  Default := Ord(drUnknown);
end;

function TDiplomaticRelationList.GetDiplomaticRelation(Index: Integer): TDiplomaticRelation;
begin
  if Index < Count then Result := TDiplomaticRelation(List^[Index])
  else Result := drUnknown;
end;

procedure TDiplomaticRelationList.SetDiplomaticRelation(Index: Integer; Value: TDiplomaticRelation);
begin
  Items[Index] := Ord(Value);
end;

class function TDiplomaticRelationHistoryItem.ClassID: Integer;
begin
  Result := $2011A;
end;

procedure TDiplomaticRelationHistoryItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDay, 20);
  Stream.rwData(FRelation, 1, 21);
end;

class function TDiplomaticRelationHistoryList.ClassID: Integer;
begin
  Result := $2011B;
end;

function TDiplomaticRelationHistoryList.GetItems(Index: Integer): TDiplomaticRelationHistoryItem;
begin
  Result := TDiplomaticRelationHistoryItem(FChildren.EObjects[Index]);
end;

function TDiplomaticRelationHistoryList.GetLastModifiedOnDay: Integer;
begin
  if Count <> 0 then Result := GetItems(Count - 1).FDay
  else Result := 0;
end;

function TDiplomaticRelationHistoryList.GetRelationOnDay(Day: Integer): TDiplomaticRelation;
var
  I: Integer;
begin
  Result := drUnknown;
  I := 0;
  while (I < Count) and (GetItems(I).FDay <= Day) do
  begin
    Result := GetItems(I).FRelation;
    Inc(I);
  end;
end;

procedure TDiplomaticRelationHistoryList.Add(Relation: TDiplomaticRelation; Day: Integer);
begin
  with TDiplomaticRelationHistoryItem.Create(Self) do
  begin
    FDay := Day;
    FRelation := Relation;
  end;
end;

constructor TPlayerDiplomaticRelations.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRelations := TByteList.Create;
  FHistory := TENode.Create(nil);
end;

destructor TPlayerDiplomaticRelations.Destroy;
begin
  FRelations.Free;
  FHistory.Free;
  inherited Destroy;
end;

procedure TPlayerDiplomaticRelations.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(20, FRelations.LoadFromStream, FRelations.SaveToStream);
  Stream.rwEObject(FHistory, 21);
  if smRead in Stream.StorageMode then FRelations.Default := Ord(drUnknown);
end;

function TPlayerDiplomaticRelations.GetDiplomaticRelation(Player: Shortint): TDiplomaticRelation;
begin
  if Player < FRelations.Count then
    Result := TDiplomaticRelation(FRelations.List^[Player])
  else Result := drUnknown;
end;

procedure TPlayerDiplomaticRelations.SetDiplomaticRelation(Player: Shortint; Value: TDiplomaticRelation);
begin
  FRelations[Integer(Player)] := Byte(Value);
  if not (msEditting in AoWHSMap.Status) and (AoWHSMap.FDay > 0) then
    GetHistory(Player).Add(Value, AoWHSMap.FDay);
end;

function TPlayerDiplomaticRelations.GetHistory(Player: Shortint): TDiplomaticRelationHistoryList;
begin
  Result := FHistory.FChildren.List^[Player - 1];
end;

procedure TPlayerDiplomaticRelations.ValidateHistory;
begin
  while FHistory.Count + 1 < AoWHSMap.FPlayers.Count do
    TDiplomaticRelationHistoryList.Create(nil).Owner := FHistory;
  while FHistory.Count + 1 > AoWHSMap.FPlayers.Count do
    FHistory.Children[FHistory.Count - 1].Free;
end;

procedure TPlayerDiplomaticRelations.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
var
  Player: Shortint;
  I: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    ValidateHistory;
    if FPlayer.FLegacyNewRelations.Count <> 0 then
    begin
      FRelations.Assign(FPlayer.FLegacyNewRelations);
      FPlayer.FLegacyNewRelations.Clear;
    end;
    if (AoWHSMap.FDay = 0) and not (msEditting in AoWHSMap.Status) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      begin
        { The loop index supplies the player. }
        GetHistory(I).Add(GetDiplomaticRelation(I), 0);
      end
    else if FPlayer.FLegacyRelations.Count <> 0 then
    begin
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        GetHistory(I).Add(FPlayer.FLegacyRelations.GetDiplomaticRelation(I), 0);
      FPlayer.FLegacyRelations.Clear;
    end;
  end;
end;

class function TTurnInfoItem.ClassID: Integer;
begin
  Result := $2029B;
end;

procedure TTurnInfoItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGold, 25);
  Stream.rwInteger(FMana, 26);
  Stream.rwInteger(FStructures, 27);
  Stream.rwInteger(FArmyStrength, 28);
  Stream.rwByte(FHeroes, 29);
end;

function TTurnInfoItem.GetSuperiority: Integer;
begin
  Result := FArmyStrength div 100 + FStructures * 10 +
    (FGold shr 3) + (FMana shr 3) + FHeroes * 100;
end;

function TTurnInfo.GetTurnInfo(Index: Integer): TTurnInfoItem;
begin
  Result := FChildren.List^[Index];
end;

constructor TPlayerStatistics.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTurnInfo := TTurnInfo.Create(nil);
end;

destructor TPlayerStatistics.Destroy;
begin
  FTurnInfo.Free;
  inherited Destroy;
end;

procedure TPlayerStatistics.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FTurnInfo, 20);
  Stream.rwInteger(FUnitsKilled, 21);
  Stream.rwInteger(FUnitsLost, 22);
end;

function TIncomeSource.Name: string;
begin
  Result := '';
end;

function TIncomeSource.Income: Integer;
begin
  Result := 0;
end;

procedure TIncomeSource.GetLocation(var X, Y, L: Shortint);
begin
  X := -1;
  Y := -1;
  L := -1;
end;

procedure TIncomeSource.CenterToLocation;
var
  X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    AoWHSMap.CenterViewTo(X, Y, L);
    AoWHSMap.PlayCenterAnimation(X, Y, L);
  end;
end;

function TIncomeSourceList.GetItems(Index: Integer): TIncomeSource;
begin
  Result := FChildren.List^[Index];
end;

constructor TPBEMPlayerSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStatus := [];
  FEmailGame := TEmailGame.Create(nil);
end;

destructor TPBEMPlayerSettings.Destroy;
begin
  FEmailGame.Free;
  inherited Destroy;
end;

procedure TPBEMPlayerSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FStatus, 1, 20);
  Stream.rwEObject(FEmailGame, 21);
end;

procedure TPBEMPlayerSettings.SetGame(Game: TEObject);
begin
  FEmailGame.Assign(Game, AoWEngine);
end;

constructor TPlayer.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FIncomeChangedEvents := TEventList.Create;
  FGemsChangedEvents := TEventList.Create;
  FUpkeepChangedEvents := TEventList.Create;
  FStructures := TPlayerStructureList.Create(nil);
  FStructures.FPlayer := Self;
  FArmies := TArmyList.Create(nil);
  FAIControl := TAIPlayerControl.Create(nil);
  FAIControl.FPlayer := Self;
  FAIBudget := TAIBudgetManager.Create(nil);
  FAIBudget.FPlayer := Self;
  FAIGroups := TAIGroupList.Create(nil);
  FMagicControl := TPlayerMagicControl.Create(nil);
  FMagicControl.FPlayer := Self;
  FStatistics := TPlayerStatistics.Create(nil);
  FArmies.FPlayer := Self;
  FArmies.Events.Add(ArmiesChanged);
  FHeroes := THeroList.Create(nil);
  FInitialGold := 250;
  FBaseIncome := 0;
  FPlayerIndex := -1;
  FParticipating := False;
  FEventLogbook := TEventLogbook.Create(nil);
  FEventLogbook.SetOnChanged(LogbookChangedEvent);
  FLogbookChangedEvents := TEventList.Create;
  FDiplomaticRelations := TPlayerDiplomaticRelations.Create(nil);
  FDiplomaticRelations.FPlayer := Self;
  FLegacyNewRelations := TDiplomaticRelationList.Create;
  FProductionControls := TProductionControlList.Create;
  FIncomeSources := TIncomeSourceList.Create(nil);
  FLeaderSetup := TLeader.Create(nil);
  FStatus := psIdle;
  FGameOverStatus := goNone;
  FFirstDaySeen := TIntegerList.Create;
  FFirstDaySeen.Default := -1;
  FLastDaySeen := TIntegerList.Create;
  FLastDaySeen.Default := -1;
  FVictoryLocations := TPlayerStructureList.Create(nil);
  FKnownStructures := TPlayerStructureList.Create(nil);
  FMessages := TStringList.Create;
  FDiplomaticActions := TDiplomaticActionList.Create(nil);
  FAIValidAttackPlayers := TBitList.Create;
  FPBEMSettings := TPBEMPlayerSettings.Create(nil);
  FLegacyRelations := TDiplomaticRelationList.Create;
  FHeroEmerging := False;
  FBaseHeroJoinDay := -1;
  FHeroJoinDay := -1;
  FPlayerRace := -1;
  FViewX := $FF;
  FViewY := $FF;
end;

destructor TPlayer.Destroy;
var
  I: Integer; Structures: TPlayerStructureList; Armies: TArmyList;
begin
  try
    FIncomeChangedEvents.Clear;
    FGemsChangedEvents.Clear;
    FUpkeepChangedEvents.Clear;
    try
      if (AoWHSMap <> nil) and (msDestroying in AoWHSMap.Status) then
      begin
        Assert(FVictoryLocations.Count = 0, 'Victory Locations not correctly cleared (TPlayer)');
        Assert(FStructures.Count = 0, 'Registered Player Structures not correctly cleared (TPlayer)');
        Assert(FArmies.Count = 0, 'Registered Player Armies not correctly cleared (TPlayer)');
      end
      else
      begin
        Structures := FStructures; for I := Structures.Count - 1 downto 0 do
          FStructures.GetStructure(I).SetPlayer(0);
        Armies := FArmies; for I := Armies.Count - 1 downto 0 do
          FArmies.GetArmy(I).SetPlayer(0);
      end;
    except
    end;
    FMessages.Free;
    FMessages := nil;
    FDiplomaticActions.Free;
    FDiplomaticActions := nil;
    FAIValidAttackPlayers.Free;
    FAIValidAttackPlayers := nil;
    FLegacyRelations.Free;
    try
      FLogbookChangedEvents.Clear;
      FEventLogbook.Free;
      FLogbookChangedEvents.Free;
    except
    end;
    try
      FLegacyNewRelations.Free;
      FDiplomaticRelations.Free;
    except
    end;
    try FProductionControls.Free; except end;
    try FAIControl.Free; except end;
    try FStatistics.Free; except end;
    try FMagicControl.Free; except end;
    try FLeaderSetup.Free; except end;
    try
      FFirstDaySeen.Free;
      FLastDaySeen.Free;
    except
    end;
    try FHeroes.Free; except end;
    try
      FArmies.Free;
      FAIGroups.Free;
      FAIBudget.Free;
      FStructures.Free;
      FVictoryLocations.Free;
      FIncomeSources.Free;
      FKnownStructures.Free;
    except
    end;
    try inherited Destroy; except end;
    FPBEMSettings.Free;
    FPBEMSettings := nil;
    FIncomeChangedEvents.Free;
    FIncomeChangedEvents := nil;
    FGemsChangedEvents.Free;
    FGemsChangedEvents := nil;
    FUpkeepChangedEvents.Free;
    FUpkeepChangedEvents := nil;
  except
  end;
end;
class function TPlayer.ClassID: Integer;
begin
  Result := $20020;
end;
function TPlayer.GetBusy: Boolean;
begin
  Result := (FBusyCount <> 0) or not AoWHSMap.FTokenManager.PlayerReady(FPlayerIndex);
  Result := Result or ((AoWHSMap.FCombat = nil) and
    (AoWHSMap.FPlayMode = pmTurn) and (AoWHSMap.FCurrentPlayer <> FPlayerIndex));
  Result := Result or ((AoWHSMap.FCombat <> nil) and
    (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(
      AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer <> FPlayerIndex));
  Result := Result or (FGameOverStatus <> goNone) or not GetLocal;
  Result := Result or ((FPlayerType = ptHuman) and
    AoWHSMap.GetTurnTimerEnabled and (AoWHSMap.GetTurnTimeLeft <= 0));
end;
function TPlayer.GetSuperiority: Integer;
begin
  if FStatistics.FTurnInfo.Count <> 0 then
    Result := FStatistics.FTurnInfo.GetTurnInfo(FStatistics.FTurnInfo.Count - 1).GetSuperiority
  else Result := 0;
end;
function TPlayer.GetUnitCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FArmies.Count - 1 downto 0 do
    Inc(Result, FArmies.GetArmy(I).Count);
end;
procedure TPlayer.SetPlayerIndex(Value: Shortint);
begin
  FPlayerIndex := Value;
  FEventLogbook.FPlayer := Value;
end;
procedure TPlayer.SetGameOverStatus(Value: TGameOverStatus);
var
  Event: TGameOverEventLog;
  I: Integer; Structures: TPlayerStructureList; Armies: TArmyList;
  Campaign: TAoWCampaign;
begin
  if (Value <> FGameOverStatus) and (FGameOverStatus = goNone) then
  begin
    FGameOverStatus := Value;
    AoWHSMap.FAIExecuter.DeactivatePlayer(FPlayerIndex);
    if (AoWHSMap.FGameType = gtCampaign) and (FPlayerType = ptHuman) then
    begin
      if FGameOverStatus = goLost then
      begin
        AoWHSMap.FGameResult := grFailed;
        Campaign := AoWEngine.FCampaign;
        if Campaign <> nil then Campaign.RestartScenario;
      end
      else if FGameOverStatus = goWon then
      begin
        AoWHSMap.FGameResult := grSucceeded;
        Campaign := AoWEngine.FCampaign;
        if Campaign <> nil then Campaign.FinishScenario;
      end;
    end;
    if FGameOverStatus = goLost then
    begin
      BeginUpdate;
      FMagicControl.RemoveEnchantments;
      Structures := FStructures; for I := Structures.Count - 1 downto 0 do
        FStructures.GetStructure(I).SetPlayer(0);
      Armies := FArmies; for I := Armies.Count - 1 downto 0 do
        FArmies.GetArmy(I).SetPlayer(0);
      FMagicControl.SetMana(0);
      FGems := 0;
      EndUpdate;
      AoWHSMap.FPlayers.Update;
    end;
    Event := TGameOverEventLog.Create(nil);
    Event.FPlayer := FPlayerIndex;
    if Value = goLost then
    begin
      Event.FMessage.Text := Format(TranslateRStr(GameOverDefeatMessageRStr),
        [IntToStr(AoWHSMap.FDay), TranslateRStr(RaceNamesPluralRStr[FPlayerRace]), GetName]);

    end
    else
    begin
      Event.FMessage.Text := Format(TranslateRStr(GameOverVictoryMessageRStr),
        [IntToStr(AoWHSMap.FDay), TranslateRStr(RaceNamesPluralRStr[FPlayerRace]), GetName]);

    end;
    AoWHSMap.ExecuteGameOverEvent(Event);
    Event.Release;
    if FGameOverStatus = goLost then
      AoWHSMap.FGlobalMagicControl.RemovePlayerEnchantments(FPlayerIndex);
  end;
end;

function TPlayer.Surrender: Boolean;
var
  TE: TGameOverTE;
begin
  if not GetBusy and (FGameOverStatus = goNone) then
  begin
    TE := TGameOverTE.Create(nil);
    TE.FPlayer := FPlayerIndex;
    TE.FGameOverStatus := goLost;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;
function TPlayer.Win: Boolean;
var
  TE: TGameOverTE;
begin
  if not GetBusy and (FGameOverStatus = goNone) then
  begin
    TE := TGameOverTE.Create(nil);
    TE.FPlayer := FPlayerIndex;
    TE.FGameOverStatus := goWon;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TPlayer.Validate(Errors: TStrings): Boolean; { Match: the addressable Errors parameter uses the original stack slot. }
var
  S, LeaderName: string; ErrorAddress: Pointer;
begin ErrorAddress := @Errors;
  if FPlayerIndex > 0 then
  begin
    Result := True;
    if FLeader.GetSphereCount <> AoWHSMap.FSphereCount then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotAllSpheresAssignedRStr);
      Errors.Add(S);
      Result := False;
    end;
    if FLeader.Owner = nil then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotPlacedOnMapRStr);
      Errors.Add(S);
      Result := False;
    end;
    if FLeader.GetSkillPoints <> 0 then
    begin
      LeaderName := Format(XLeaderRStr, [TranslateRStr(RaceNamesRStr[FPlayerRace])]);
      S := LeaderName + ': ' + TranslateRStr(NotAllSkillPointsAssignedRStr);
      Errors.Add(S);
      { Original reports unassigned skill points without failing validation. }
    end;
  end
  else Result := True;
end;

procedure TPlayer.LockBusy;
begin
  Inc(FBusyCount);
end;

procedure TPlayer.UnlockBusy;
begin
  Assert(FBusyCount <> 0, 'Invalid busy counter usage');
  Dec(FBusyCount);
end;

procedure TPlayer.LogbookChangedEvent(Sender: TObject);
begin
  if FUpdateCount = 0 then FLogbookChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.BeginUpdate;
begin
  Inc(FUpdateCount);
  FStructures.BeginUpdate;
  FArmies.BeginUpdate;
  FMagicControl.BeginUpdate;
end;

procedure TPlayer.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
  begin
    FGemsChangedEvents.TriggerNotifyEvents(Self);
    FUpkeepChangedEvents.TriggerNotifyEvents(Self);
    UpdateIncome;
    FLogbookChangedEvents.TriggerNotifyEvents(Self);
  end;
  FStructures.EndUpdate;
  FArmies.EndUpdate;
  FMagicControl.EndUpdate;
end;

procedure TPlayer.ArmiesChanged(Sender: TObject);
begin
  if FArmies.Count = 0 then AoWHSMap.GameOver(FPlayerIndex, goLost);
end;

procedure TPlayer.SetGems(Value: Integer);
begin
  FGems := Value;
  if FUpdateCount = 0 then FGemsChangedEvents.TriggerNotifyEvents(Self);
  if (AoWHSMap.FVictoryCondition = vcAccumulateGold) and
    (AoWHSMap.FVictoryGold <= FGems) then
    AoWHSMap.GameOver(FPlayerIndex, goWon);
end;

procedure TPlayer.UpdateIncome;
var
  I: Integer;
begin
  FIncome := FBaseIncome;
  for I := FIncomeSources.Count - 1 downto 0 do
    Inc(FIncome, TIncomeSource(FIncomeSources.FChildren.List^[I]).Income);
  if FPlayerType = ptCPU2 then FIncome := Round(FIncome * 1.0)
  else if FPlayerType = ptCPU3 then FIncome := Round(FIncome * 2.0)
  else if FPlayerType = ptCPU4 then FIncome := Round(FIncome * 2.5) + 50
  else if FPlayerType = ptCPU5 then FIncome := Round(FIncome * 3) + 100;
  if FUpdateCount = 0 then FIncomeChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.RegisterIncomeSource(Source: TIncomeSource);
begin
  if FIncomeSources.FChildren.IndexOf(Source) = -1 then
  begin
    FIncomeSources.FChildren.Add(Source);
    if FUpdateCount = 0 then UpdateIncome;
  end;
end;

procedure TPlayer.UnregisterIncomeSource(Source: TIncomeSource);
begin
  if (FIncomeSources.FChildren.Remove(Source) <> -1) and (FUpdateCount = 0) then
    UpdateIncome;
end;

function TPlayer.GetUpkeep: Integer;
begin
  Result := FArmyUpkeep + FMagicUpkeep;
end;

procedure TPlayer.SetArmyUpkeep(Value: Integer);
begin
  FArmyUpkeep := Value;
  if FUpdateCount = 0 then FUpkeepChangedEvents.TriggerNotifyEvents(Self);
end;

procedure TPlayer.SetMagicUpkeep(Value: Integer);
begin
  FMagicUpkeep := Value;
  if FUpdateCount = 0 then FUpkeepChangedEvents.TriggerNotifyEvents(Self);
end;

function TPlayer.GetName: string;
begin
  if FPlayerIndex <> 0 then
  begin
    if FLeader <> nil then
    begin
      Result := FLeader.FHeroName;
      if FLeader.GetNickname <> '' then
        Result := Result + ' ' + FLeader.GetNickname;
    end
    else Result := FName;
    if Result = '' then
      Result := TranslateRStr(PlayerRStr) + ' ' + IntToStr(FPlayerIndex);
  end
  else Result := TranslateRStr(IndependentsRStr);
end;

function TPlayer.GetNameEx: string;
begin
  if FPlayerIndex <> 0 then
    Result := Format(TranslateRStr(PlayerNameExRStr),
      [GetName, TranslateRStr(RaceNamesPluralRStr[FPlayerRace])])
  else Result := GetName;
end;

procedure TPlayer.SetName(Value: string);
begin
  if FPlayerIndex <> 0 then
    if FLeader <> nil then
    begin
      FLeader.FHeroName := Value;
      FLeader.SetNickname('');
    end
    else FName := Value;
end;

function TPlayer.GetFace: TLibraryImage;
begin
  if FLeader <> nil then Result := FLeader.GetFace
  else Result := nil;
end;

function TPlayer.GetHeroCountMax: Integer;
var
  Strength, Maximum: Integer;
begin
  Strength := FStatistics.FTurnInfo.GetTurnInfo(FStatistics.FTurnInfo.Count - 1).FArmyStrength;
  if Strength < 10 then Result := 1
  else if Strength < 40 then Result := 2
  else if Strength < 80 then Result := 3
  else if Strength < 120 then Result := 4
  else if Strength < 200 then Result := 5
  else Result := (Strength - 200) div 100 + 5;
  Maximum := AoWHSMap.FHeroCountMax;
  if Maximum < Result then Result := Maximum;
end;

function TPlayer.GetIdealHeroJoinDay: Integer;
var
  Average, Maximum: Integer;
begin
  Result := FLastHeroJoinDay;
  Average := AoWHSMap.FPlayers.GetAverageHeroCount;
  Maximum := AoWHSMap.FPlayers.GetMaxHeroCount;
  if (Maximum > Average) and (FHeroes.Count = Maximum) then
    Inc(Result, 15)
  else if (Average <= FHeroes.Count) and (FHeroes.Count <> 0) and (AoWHSMap.FDay > 15) then
    Inc(Result, 10)
  else Inc(Result, 5);
end;

function TPlayer.GetIdealHeroEmergeDay: Integer;
var
  Average, Maximum, Earliest: Integer;
begin
  Result := GetIdealHeroJoinDay;
  Average := AoWHSMap.FPlayers.GetAverageHeroCount;
  Maximum := AoWHSMap.FPlayers.GetMaxHeroCount;
  if (Maximum > Average) and (FHeroes.Count = Maximum) then
    Inc(Result, 15)
  else if (Average < FHeroes.Count) and (FHeroes.Count <> 0) and (AoWHSMap.FDay > 10) then
    Inc(Result, 10)
  else Inc(Result, 5);
  Earliest := FLastHeroEmergeDay + 5;
  if Earliest > Result then Result := Earliest;
end;

procedure TPlayer.ResetBaseHeroJoinDay;
begin
  FLastHeroJoinDay := AoWHSMap.FDay;
end;

procedure TPlayer.MakeHeroEmerge(Mode: THeroEmergeMode);
var
  Chance: Integer;
  Heroes: TDoubleItemList;
  Log: THeroEmergeEventLog;
  Locations: TXYLList;
  Structure: TStructure;
  Item: TDoubleItem;
  I: Integer;
  Hero: THero;
begin
  Heroes := TDoubleItemList.Create;
  if Mode = hemNormal then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
    begin
      Hero := AoWHSMap.FHeroControl.GetHero(I);
      if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and
        (Hero.Owner = nil) and Hero.CanJoin(FPlayerIndex) then
      begin
        Chance := GetHeroJoinChance(Hero.GetLevel);
        if (Chance > 0) and (Hero.JoinAmount(FPlayerIndex) < FGems) then
          Heroes.AddAB(Integer(Hero), Chance * Chance);
      end;
    end
  else if Mode = hemFirstHero then
    for I := AoWHSMap.FHeroControl.GetCount - 1 downto 0 do
    begin
      Hero := AoWHSMap.FHeroControl.GetHero(I);
      if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and
        (Hero.Owner = nil) and Hero.GetAbilityEnabled($34) and
        (Hero.GetLevel >= 2) and (Hero.GetLevel <= 3) then
        if (AoWHSMap.FRaces.GetRace(Hero.FRace).GetPlayerRelation(FPlayerIndex) in
          [sPolite, sFriendly]) and (Hero.JoinAmount(FPlayerIndex) < FGems) then
          Heroes.AddAB(Integer(Hero), (Hero.GetLevel - 2) * 1000 + 1);
    end;
  if Heroes.Count <> 0 then
  begin
    Locations := TXYLList.Create;
    for I := FStructures.Count - 1 downto 0 do
    begin
      Structure := FStructures.GetStructure(I);
      if Structure.ClassID = $20108 then
        Locations.AddXYL(Structure.GetXhx, Structure.GetYhx, Structure.GetLhx);
    end;
    if Locations.Count <> 0 then
    begin
      FLastHeroEmergeDay := AoWHSMap.FDay;
      RandSeed := AoWHSMap.Random($FFFFF);
      I := Heroes.RandomChanceItemB(0);
      Item := Heroes[I];
      Hero := THero(Item.A);
      I := AoWHSMap.Random(Locations.Count);
      FEmergingHeroID := Hero.FUnitID;
      Hero.UpdateSettings;
      Hero.Place(Locations[I].X, Locations[I].Y, Locations[I].L,
        0, [pmScanArea, pmCreateNewArmy]);
      Structure := TStructure(AoWHSMap.MapContainer.GetField(
        Locations[I].X, Locations[I].Y, Locations[I].L).
        FindNoneTransparentHS(TStructure));
      Log := THeroEmergeEventLog.Create(nil);
      Log.Setup(Hero, FPlayerIndex, hjmEmerged);
      if Structure <> nil then Log.FLocationName := Structure.GetName
      else Log.FLocationName := TranslateRStr(UnknownRStr);
      FEventLogbook.AddEvent(Log);
      if (FPlayerIndex = AoWHSMap.FSeatedPlayer) and
        (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).FPlayerType = ptHuman) then
        Log.Execute(False, etEvent, nil);
      Log.Release;
    end;
    Locations.Free;
  end;
  Heroes.Free;
end;

procedure TPlayer.UpdateHeroJoin;
var
  I, Days: Integer;
begin
  for I := FHeroes.Count - 1 downto 0 do
    if FHeroes.GetHero(I).GetLevel > FHighestHeroLevel then
      FHighestHeroLevel := FHeroes.GetHero(I).GetLevel;
  FBaseHeroJoinLevel := AoWHSMap.FPlayers.GetAverageHeroLevel;
  if FBaseHeroJoinLevel = 0 then
    FBaseHeroJoinLevel := AoWHSMap.FHeroControl.GetMinFreeHeroLevel;
  if FHighestHeroLevel <> 0 then
    FBaseHeroJoinLevel := (FBaseHeroJoinLevel + FHighestHeroLevel + 1) div 2;
  if FHeroes.Count = GetHeroCountMax then ResetBaseHeroJoinDay;
  FEmergingHeroID := 0;
  Days := GetIdealHeroEmergeDay - AoWHSMap.FDay;
  if (AoWHSMap.FDay = 1) and (FHeroes.Count = 1) and not AoWHSMap.FFixedLeaders then
  begin
    MakeHeroEmerge(hemFirstHero);
    Exit;
  end;
  if Days <= 0 then
    if AoWHSMap.Random(4) = 1 then MakeHeroEmerge(hemNormal);
end;

function TPlayer.GetHeroJoinChance(Level: Integer): Integer;
var
  Maximum: Integer;
begin
  Maximum := GetHeroJoinLevelMax;
  if Level <= Maximum then
  begin
    Result := Round((Maximum + 2) / (Level + 2) * 20);
    if Result > 40 then Result := 40;
  end
  else Result := 0;
end;

function TPlayer.GetHeroJoinLevelMax: Integer;
var
  Days: Integer;
begin
  Result := FBaseHeroJoinLevel;
  Days := AoWHSMap.FDay - GetIdealHeroJoinDay;
  if Days > 0 then Inc(Result, Days div 5);
  if Days < 0 then
  begin
    Inc(Result, Round((Result * Days + 2.5) / 5));
    if Result < 0 then Result := 0;
  end;
  if (Result < 3) and not AoWHSMap.FFixedLeaders and (AoWHSMap.FDay = 1) then
    Result := 3;
end;

procedure TPlayer.ValidateLeader;
var
  FaceIndex, ResourceIndex: Integer;
  HeroType: THeroType;
  Name: string;
begin
  if (AoWHSMap <> nil) and (FPlayerIndex <> 0) then
  begin
    HeroType := htHeroLeader;
    if (FLeader <> nil) and (FLeader.GetHeroType <> HeroType) then
    begin
      Name := FLeader.FHeroName;
      FaceIndex := FLeader.FFaceIndex;
      FLeader.Deactivate;
      ResourceIndex := AoWHSSet.FHeroResources.Find(FPlayerRace, HeroType);
      FLeader.SetHeroResourceIndex(ResourceIndex);
      FLeader.FHeroName := Name;
      FLeader.SetFaceIndex(FaceIndex);
      FLeader.Activate;
    end
    else if FLeader = nil then
    begin
      ResourceIndex := AoWHSSet.FHeroResources.Find(FPlayerRace, HeroType);
      if ResourceIndex <> -1 then
      begin
        FLeader := TLeader.Create(nil);
        FLeader.SetHeroResourceIndex(ResourceIndex);
        FLeader.FPlayer := FPlayerIndex;
        FLeader.Activate;
      end;
    end
    else if (FLeader <> nil) and not AoWHSMap.FFixedLeaders and
      (AoWHSMap.FGameType <> gtCampaign) and not (msEditting in AoWHSMap.Status) then
      FLeader.Owner := nil;
  end;
end;

procedure TPlayer.SetLeader(Value: TLeader);
begin
  FLeader := Value;
end;

procedure TPlayer.SetRace(Value: Shortint);
begin
  FPlayerRace := Value;
end;

procedure TPlayer.SetEndTurn(Value: Boolean);
begin
  if Value <> FSingleProcessCycle then
  begin
    FSingleProcessCycle := Value;
    AoWHSMap.TriggerEndTurnEvent(FPlayerIndex);
  end;
end;

procedure TPlayer.UpdateLogbook;
begin
  while (FEventLogbook.GetCount <> 0) and
    (AoWHSMap.FDay - FEventLogbook.GetLogs(0).FDay >= 3) do
    FEventLogbook.RemoveEvent(FEventLogbook.GetLogs(0));
end;

procedure TPlayer.UpdateTurnInfo;
var
  Info: TTurnInfoItem;
  I, J: Integer;
  Army: TArmy;
  AUnit: TAbstractUnit;
begin
  Info := TTurnInfoItem.Create(FStatistics.FTurnInfo);
  if FGameOverStatus <> goLost then
  begin
    Info.FGold := FGems;
    Info.FMana := FMagicControl.FMana;
    Info.FStructures := FStructures.Count;
    Info.FHeroes := FHeroes.Count;
    for I := 0 to FArmies.Count - 1 do
    begin
      Army := FArmies.GetArmy(I);
      for J := Army.Count - 1 downto 0 do
      begin
        AUnit := Army.GetUnit(J);
        if Info.FArmyStrength < $3FFFFFFF then
          Inc(Info.FArmyStrength, AUnit.GetStrengthMax(dtAll - [dtWall]));
      end;
    end;
  end;
end;

procedure TPlayer.UpdateAlliedPlayersSeen;
var
  I: Integer;
begin Self := Self;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayerIndex then
      if AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayerIndex, I) = drAlliance then
        PlayerSeen(I);
end;

procedure TPlayer.SetupAIValidAttackPlayers;
var
  I: Integer;
begin
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayerIndex then
      FAIValidAttackPlayers[I] := FDiplomaticRelations.GetDiplomaticRelation(I) = drWar;
end;

procedure TPlayer.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FDiplomaticRelations.MsgProc(Msg, Sender);
  if (Msg.MsgID = $20000008) and (AoWHSMap.FDay = 0) then
  begin
    FFirstDaySeen.Clear;
    FLastDaySeen.Clear;
  end;
  if Msg.MsgID = $20020005 then ValidateLeader;
  if Msg.MsgID = $20020001 then
    try
      UpdateLogbook;
      if AoWHSMap.FDay = 1 then
      begin
        FViewX := $FF;
        if (AoWHSMap.FGameType <> gtCampaign) and not AoWHSMap.FFixedLeaders and
          (FLeader <> nil) then
        begin
          FLeader.Owner := nil;
          FMagicControl.UnregisterPowerSource(FLeader.FPowerSource);
          FHeroes.RemoveChild(Self); { Original removes the player, not the leader. }
        end;
        UpdateAlliedPlayersSeen;
        SetupAIValidAttackPlayers;
      end;
    except
    end;
  if Msg.MsgID = $20020103 then
    if not Validate(TStrings(Msg.Value)) then Msg.Data[0] := 1;
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayerIndex) then
    UpdateAlliedPlayersSeen;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayerIndex) then
  begin
    UpdateTurnInfo;
    if FPlayerIndex <> 0 then UpdateHeroJoin;
  end;
  if (Msg.MsgID = $20000008) and (AoWHSMap.FDay = 0) then
  begin
    FViewX := $FF;
    FViewY := $FF;
    FViewL := $FF;
  end;
  FMagicControl.MsgProc(Msg, Sender);
  FAIControl.MsgProc(Msg, Sender);
  FAIBudget.MsgProc(Msg, Sender);
  FEventLogbook.MsgProc(Msg, Sender);
end;

procedure TPlayer.ReadWrite(Stream: Engine.TEStorageStream);
var
  X, Y, L: Integer;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayerRace), 2);
  Stream.rwData(FPlayerType, 1, 3);
  Stream.rwBool(FParticipating, 4);
  Stream.rwInteger(FInitialGold, 5);
  Stream.rwInteger(FBaseIncome, 6);
  Stream.rwData(FStatus, 1, $A);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSettings, $B);
  Stream.rwString(FDescription, $C);
  Stream.rwInteger(FGems, $10);
  Stream.rwByte(Byte(FPlayerIndex), $12);
  if (AoWEngine.Status * [esLoadingHSM, esSavingHSM] <> []) or
    (smTextOnly in Stream.StorageMode) then
    if not (smWrite in Stream.StorageMode) then
    begin
      Stream.rwCreateEObject(TEObject(FLeader), nil, $13);
      if (FLeader <> nil) and not (smPreview in Stream.StorageMode) then
      begin
        FLeader.FPlayer := FPlayerIndex;
        AoWHSMap.FHeroControl.RegisterHero(FLeader);
      end;
    end;
  if smWrite in Stream.StorageMode then
  begin
    if (AoWHSMap.FSeatedPlayer = FPlayerIndex) and (AoWHSMap.FConnectionType <> pcNetwork) then
    begin
      AoWHSMap.GetViewCenter(X, Y, L);
      FViewX := X; FViewY := Y; FViewL := L;
      Stream.rwByte(FViewX, $14);
      Stream.rwByte(FViewY, $15);
      Stream.rwByte(FViewL, $16);
    end;
  end
  else
  begin
    Stream.rwByte(FViewX, $14);
    Stream.rwByte(FViewY, $15);
    Stream.rwByte(FViewL, $16);
  end;
  if not (smPreview in Stream.StorageMode) then Stream.rwEObject(FEventLogbook, $17);
  Stream.rwString(FPassword, $18);
  Stream.rwData(FGameOverStatus, 1, $19);
  if smRead in Stream.StorageMode then
    Stream.rwStreamProc($1A, FLegacyNewRelations.LoadFromStream, FLegacyNewRelations.SaveToStream);
  Stream.rwByte(Byte(FMoraleValue), $1B);
  Stream.rwEObject(FAIControl, $1C);
  Stream.rwData(FBehavior, 1, $1D);
  if FPlayerIndex <> 0 then
    if (smWrite in Stream.StorageMode) and (msEditting in AoWHSMap.Status) and
      (FLeader <> nil) then Stream.rwEObject(FLeader, $1E)
    else Stream.rwEObject(FLeaderSetup, $1E);
  Stream.rwEObject(FMagicControl, $1F);
  Stream.rwStreamProc($20, FFirstDaySeen.LoadFromStream, FFirstDaySeen.SaveToStream);
  Stream.rwStreamProc($21, FLastDaySeen.LoadFromStream, FLastDaySeen.SaveToStream);
  Stream.rwInteger(FDay, $22);
  Stream.rwEObject(FStatistics, $23);
  Stream.rwInteger(FBaseHeroJoinLevel, $24);
  Stream.rwInteger(FLastHeroJoinDay, $25);
  Stream.rwInteger(FLastHeroEmergeDay, $26);
  Stream.rwInteger(FHighestHeroLevel, $27);
  if smRead in Stream.StorageMode then
  begin
    SetRace(FPlayerRace);
    FEventLogbook.FPlayer := FPlayerIndex;
    FLegacyNewRelations.Default := Ord(drUnknown);
  end;
  Stream.rwStrings(FMessages, $28);
  if smRead in Stream.StorageMode then
    Stream.rwStreamProc($29, FLegacyRelations.LoadFromStream, FLegacyRelations.SaveToStream);
  Stream.rwInteger(FEmergingHeroID, $32);
  Stream.rwEObject(FAIBudget, $33);
  Stream.rwEObject(FDiplomaticActions, $34);
  Stream.rwStreamProc($35, FAIValidAttackPlayers.LoadFromStream, FAIValidAttackPlayers.SaveToStream);
  Stream.rwEObject(FPBEMSettings, $36);
  Stream.rwBool(FHeroEmerging, $38);
  if (smRead in Stream.StorageMode) or (AoWHSMap.FConnectionType <> pcNetwork) then
    Stream.rwInteger(FBaseHeroJoinDay, $39);
  Stream.rwEObject(FDiplomaticRelations, $3A);
  if FPlayerIndex = 0 then FPlayerType := ptIndependent;
end;

function TPlayer.GetFirstDaySeen(Player: Shortint): Integer;
begin
  if Player <> FPlayerIndex then
    if Player < FFirstDaySeen.Count then Result := FFirstDaySeen[Player]
    else Result := -1
  else Result := 0;
end;

function TPlayer.GetLastDaySeen(Player: Shortint): Integer;
begin
  if Player <> FPlayerIndex then
    if Player < FLastDaySeen.Count then Result := FLastDaySeen[Player]
    else Result := -1
  else Result := AoWHSMap.FDay;
end;

procedure TPlayer.PlayerSeen(Player: Shortint); { Tried Self identity, Pointer identity, typed with; cast Self at list field access; still differs. }
begin
  if not (msEditting in AoWHSMap.Status) and
    ((Player >= FLastDaySeen.Count) or (FLastDaySeen[Player] <> AoWHSMap.FDay)) then
  begin
    FLastDaySeen[Player] := AoWHSMap.FDay;
    if GetFirstDaySeen(Player) = -1 then FFirstDaySeen[Player] := AoWHSMap.FDay;
  end;
end;

procedure TPlayer.GetLeaderLocation(var X, Y, L: Shortint);
begin
  if (FLeader <> nil) and (FLeader.Owner <> nil) then
    TUnitList(FLeader.Owner).GetLocation(X, Y, L)
  else
  begin
    X := -1;
    Y := -1;
    L := -1;
  end;
end;

function TPlayer.GetLocal: Boolean;
var
  Control: TPlayerCommunicationControl;
begin Self := Self;
  Control := AoWHSMap.FPlayerCommunicator.PCC;
  if Control <> nil then
    Result := Control.GetPlayers(FPlayerIndex).ConnectionMode in [cmLocal, cmGlobal]



  else Result := True;
end;

procedure TPlayer.RegisterVictoryLocation(Structure: TPlayerStructure);
begin
  FVictoryLocations.AddChild(Structure);
end;

procedure TPlayer.UnregisterVictoryLocation(Structure: TPlayerStructure);
begin
  FVictoryLocations.RemoveChild(Structure);
end;

procedure TPlayer.CheckCaptureLocations;
begin
  if AoWHSMap.FVictoryCondition = vcCaptureLocations then
    if CaptureLocationsLeft = 0 then AoWHSMap.GameOver(FPlayerIndex, goWon);
end;

function TPlayer.CaptureLocationsLeft: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FVictoryLocations.Count - 1 do
    if FVictoryLocations.GetStructure(I).FPlayer <> FPlayerIndex then
      if not ((FVictoryLocations.GetStructure(I).FPlayer > 0) and
        (AoWHSMap.FPlayers.GetDiplomaticRelation(
          FVictoryLocations.GetStructure(I).FPlayer, FPlayerIndex) = drAlliance) and
        AoWHSMap.FAlliedVictory) then Inc(Result);
end;

function TPlayer.CreateDiplomaticAction(Action: TDiplomaticActionType; Target, Other: Shortint): TDiplomaticAction;
begin
  if AoWHSMap.FPlayers.GetPlayers(Target).FStatus = psPlaying then
  begin
    Result := TDiplomaticAction.Create(nil);
    Result.FSource := FPlayerIndex;
    Result.FTarget := Target;
    Result.FOtherPlayer := Other;
    Result.FActionType := Action;
    RetrieveDefaultDiplomaticActionMessage(FPlayerIndex, Target, Other,
      Action, darNone, Result.FMessage);
  end
  else Result := nil;
end;

function TPlayer.DiplomaticActionAleadySend(Action: TDiplomaticActionType; Target, Other: Shortint): Boolean;
var
  Logbook: TEventLogbook;
  I: Integer;
  Item: TDiplomaticAction;
begin
  Logbook := AoWHSMap.FPlayers.GetPlayers(Target).FEventLogbook;
  Result := False;
  I := Logbook.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    if Logbook.GetLogs(I).FDay = AoWHSMap.FDay then
      if Logbook.GetLogs(I) is TDiplomaticActionEventLog then
      begin
        Item := TDiplomaticActionEventLog(Logbook.GetLogs(I)).FAction;
        Result := (Item.FActionType = Action) and
          (Item.FSource = FPlayerIndex) and (Item.FTarget = Target) and
          ((Other = -1) or (Item.FOtherPlayer = Other));
      end;
  end;
end;

function TPlayer.ListDiplomaticActions(Player: Shortint; var Actions: TDiplomaticActionList): Integer;
var
  Count, I: Integer;
  Relation: TDiplomaticRelation;
  Action: TDiplomaticAction;
begin
  if (Player <> FPlayerIndex) and (GetFirstDaySeen(Player) <> -1) then
  begin
    Count := Actions.Count;
    Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(Player, FPlayerIndex);
    if (FPlayerType = ptHuman) and (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
    begin
      Action := CreateDiplomaticAction(daSendMessage, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drWar, drUnknown]) and not DiplomaticActionAleadySend(daOfferPeace, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daOfferPeace, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation <> drWar) and (Relation <> drAlliance) then
    begin
      Action := CreateDiplomaticAction(daDeclareWar, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drPeace]) and not DiplomaticActionAleadySend(daProposeAlliance, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daProposeAlliance, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    if (Relation in [drPeace, drUnknown]) and not DiplomaticActionAleadySend(daThreatenToAttack, Player, -1) then
    begin
      Action := CreateDiplomaticAction(daThreatenToAttack, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    Action := CreateDiplomaticAction(daMakeTribute, Player, -1);
    if Action <> nil then
    begin
      Actions.AddChild(Action);
      Action.Release;
    end;
    if Relation in [drAlliance] then
    begin
      Action := CreateDiplomaticAction(daBreakAlliance, Player, -1);
      if Action <> nil then
      begin
        Actions.AddChild(Action);
        Action.Release;
      end;
    end;
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (I <> Player) and (I <> FPlayerIndex) and
        (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
        if not DiplomaticActionAleadySend(daDeclareWarToY, Player, I) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) in [drPeace, drUnknown]) then
        begin
          Action := CreateDiplomaticAction(daDeclareWarToY, Player, I);
          if Action <> nil then
          begin
            Actions.AddChild(Action);
            Action.Release;
          end;
        end;
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (I <> Player) and (I <> FPlayerIndex) and
        (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
        if not DiplomaticActionAleadySend(daBreakAllianceWithY, Player, I) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
          (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) = drAlliance) then
        begin
          Action := CreateDiplomaticAction(daBreakAllianceWithY, Player, I);
          if Action <> nil then
          begin
            Actions.AddChild(Action);
            Action.Release;
          end;
        end;
    if (FPlayerRace = 5) and FHeroEmerging and (FPlayerType = ptHuman) and
      (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if (I <> Player) and (I <> FPlayerIndex) and
          (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
          (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) then
          if (AoWHSMap.FPlayers.GetPlayers(FPlayerIndex).GetFirstDaySeen(I) <> -1) and
            (AoWHSMap.FPlayers.GetPlayers(Player).GetFirstDaySeen(I) <> -1) and
            (AoWHSMap.FPlayers.GetPlayers(I).GetFirstDaySeen(Player) <> -1) then
          begin
            Action := CreateDiplomaticAction(daSendMessageAsY, Player, I);
            if Action <> nil then
            begin
              Actions.AddChild(Action);
              Action.Release;
            end;
          end;
    Count := Actions.Count - Count;
  end
  else Count := 0; Result := Count;
end;

function TPlayer.ValidAttackRelation(Player, IndependentRelation: Shortint): Boolean;
begin








































  Assert(FPlayerIndex <> 0);
  if FPlayerType in [ptCPU1, ptCPU2, ptCPU3, ptCPU4, ptCPU5] then
    Result := FAIValidAttackPlayers[Player]
  else
    Result := DiplomaticRelation(FPlayerIndex, 0, Player, IndependentRelation) in
      [drWar, drUnknown];
end;

function TPlayer.ChangePlayerSettings(const Settings: string; var Error: string): Boolean;
var
  Event: TChangePlayerSettingsTE;
begin
  if not GetBusy then
  begin
    Event := TChangePlayerSettingsTE.Create(nil);
    Event.FPlayer := FPlayerIndex;
    Event.FSettings := Settings;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayerIndex).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

constructor TPlayerList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
  SetNumberOfPlayers(2);
  F_PlayerList_14 := Integer(TByteList.Create);
  FLocalHumanPlayers := TByteList.Create;
  FActivePlayers := TByteList.Create;
  FLocalPlayers := TByteList.Create;
end;

destructor TPlayerList.Destroy;
begin
  inherited Destroy;
  TByteList(F_PlayerList_14).Free;
  FLocalHumanPlayers.Free;
  FActivePlayers.Free;
  FLocalPlayers.Free;
end;

function TPlayerList.GetDiplomaticRelationCount(Player: Shortint; Relations: TDiplomaticRelations): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> Player then
      if GetPlayers(I).FStatus = psPlaying then
        if GetDiplomaticRelation(Player, I) in Relations then Inc(Result);
end;

function TPlayerList.GetDiplomaticRelation(Player, OtherPlayer: Shortint): TDiplomaticRelation;
begin
  Result := TPlayer(FChildren.List^[Player]).FDiplomaticRelations.GetDiplomaticRelation(OtherPlayer);
end;

procedure TPlayerList.SetDiplomaticRelation(Player, OtherPlayer: Shortint; Relation: TDiplomaticRelation);
var
  I, J: Integer;
begin
  if (TPlayer(FChildren.List^[Player]).FDiplomaticRelations.GetDiplomaticRelation(OtherPlayer) <> Relation) or
    (TPlayer(FChildren.List^[OtherPlayer]).FDiplomaticRelations.GetDiplomaticRelation(Player) <> Relation) then
  begin
    if Relation = drAlliance then
      for I := 1 to Count - 1 do
      begin
        if (GetPlayers(Player).GetFirstDaySeen(I) = -1) and
          (GetPlayers(OtherPlayer).GetFirstDaySeen(I) <> -1) then GetPlayers(Player).PlayerSeen(I);
        if (GetPlayers(OtherPlayer).GetFirstDaySeen(I) = -1) and
          (GetPlayers(Player).GetFirstDaySeen(I) <> -1) then GetPlayers(OtherPlayer).PlayerSeen(I);
      end;
    TPlayer(FChildren.List^[Player]).FDiplomaticRelations.SetDiplomaticRelation(OtherPlayer, Relation);
    TPlayer(FChildren.List^[OtherPlayer]).FDiplomaticRelations.SetDiplomaticRelation(Player, Relation);
    if Relation = drWar then
    begin
      TPlayer(FChildren.List^[Player]).FAIValidAttackPlayers[OtherPlayer] := True;
      TPlayer(FChildren.List^[OtherPlayer]).FAIValidAttackPlayers[Player] := True;
    end;
    if Relation in [drPeace, drAlliance] then
    begin
      TPlayer(FChildren.List^[Player]).FAIValidAttackPlayers[OtherPlayer] := False;
      TPlayer(FChildren.List^[OtherPlayer]).FAIValidAttackPlayers[Player] := False;
    end;
    AoWHSMap.FDiplomaticRelationsChangedEvents.TriggerNotifyEvents(Self);
    for J := Count - 1 downto 1 do
      TPlayer(FChildren.List^[J]).FMagicControl.UpdateEnemyEnchantments;
    AoWHSMap.UpdateVisibility;
  end;
end;

function TPlayerList.GetActivePlayers: Integer;
var
  I: Integer;
begin
  I := 1;
  Result := 0;
  { Original tests the active count, not the index, and can run past the list. }
  while Result <> FChildren.Count do
  begin
    if TPlayer(FChildren.List^[I]).FGameOverStatus <> goLost then Inc(Result);
    Inc(I);
  end;
end;

procedure TPlayerList.Update;
var
  I: Integer;
  Player: TPlayer;
begin
  if AoWHSMap.FPlayerCommunicator.PCC <> nil then
  begin
    TByteList(F_PlayerList_14).Clear;
    FLocalHumanPlayers.Clear;
    FLocalPlayers.Clear;
    FActivePlayers.Clear;
    for I := 0 to FChildren.Count - 1 do
    begin
      Player := TPlayer(FChildren.List^[I]);
      if Player.FStatus = psPlaying then
      begin
        if (Player.FGameOverStatus <> goLost) and (I <> 0) then FActivePlayers.Add(I);
        if Player.GetLocal then
        begin
          TByteList(F_PlayerList_14).Add(I);
          if Player.FPlayerType = ptHuman then FLocalHumanPlayers.Add(I);
        end;
        if Player.FPlayerType = ptHuman then FLocalPlayers.Add(I);
      end;
    end;
  end;
end;

procedure TPlayerList.BeginUpdate;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).BeginUpdate;
end;

procedure TPlayerList.EndUpdate;
var
  I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).EndUpdate;
  Update;
end;

procedure TPlayerList.Assign(Source: Engine.TEObject; AEngine: Engine.TEngine);
var
  I: Integer;
begin
  SetNumberOfPlayers(TPlayerList(Source).GetNumberOfPlayers);
  for I := 0 to FChildren.Count - 1 do
    TPlayer(FChildren.List^[I]).Assign(TPlayerList(Source).GetPlayers(I), AoWEngine);
end;

function TPlayerList.GetPlayers(Index: Integer): TPlayer;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TPlayer(FChildren.List^[Index])
  else Result := nil;
end;

function TPlayerList.GetActivePlayersAllied: Boolean;
var
  I, J: Integer;
begin
  Result := True;
  I := FActivePlayers.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    J := FActivePlayers.Count;
    while Result and (J <> 0) do
    begin
      Dec(J);
      if J <> I then Result := GetDiplomaticRelation(FActivePlayers[J], FActivePlayers[I]) = drAlliance;
    end;
  end;
end;

function TPlayerList.GetAverageHeroLevel: Integer;
var
  Count, I, J: Integer;
  Player: TPlayer;
begin
  Count := 0;
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
  begin
    Player := TPlayer(FChildren.EObjects[I]);
    for J := Player.FHeroes.Count - 1 downto 0 do
    begin
      Inc(Result, Player.FHeroes.GetHero(J).GetLevel);
      Inc(Count);
    end;
  end;
  if Count <> 0 then Result := Result div Count
  else Result := 0;
end;

function TPlayerList.GetAverageHeroCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
    Inc(Result, TPlayer(FChildren.EObjects[I]).FHeroes.Count);
  Result := Result div (FChildren.Count - 1);
end;

function TPlayerList.GetMaxHeroCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 1 to FChildren.Count - 1 do
    if TPlayer(FChildren.EObjects[I]).FHeroes.Count > Result then
      Result := TPlayer(FChildren.EObjects[I]).FHeroes.Count;
end;

function TPlayerList.GetNumberOfPlayers: Byte;
begin
  Result := FChildren.Count - 1;
end;

function TPlayerList.RaceToPlayer(Race: Shortint): Integer;
var
  I: Integer;
begin
  Result := -1;
  I := 1;
  { Original uses <> Count and assumes at least the independent player exists. }
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if TPlayer(FChildren.List^[I]).FPlayerRace = Race then Result := I;
    Inc(I);
  end;
end;

procedure TPlayerList.SetNumberOfPlayers(Value: Byte);
var
  Player: TPlayer;
begin
  if Value < 2 then Value := 2;
  if Value > 12 then Value := 12;
  while Count <= Value do
  begin
    Player := TPlayer.Create(nil);
    Player.SetPlayerIndex(Count);
    if Count = 0 then Player.FPlayerType := ptIndependent;
    Player.FPlayerRace := Count - 1;
    Player.SetArrayOwner(Self, Count);
  end;
  while Count > Value + 1 do
  begin
    GetPlayers(Count - 1).Destroy;
    FChildren.Delete(Count - 1);
  end;
end;

procedure TPlayerList.ValidateRaces(Races: TRaceList); { Tried Self identity, Pointer identity, typed with; addressable Self parameter; still differs. }
var
  Available, Invalid: TIntegerList;
  I, Index, DefaultRace: Integer;
begin
  Available := TIntegerList.Create;
  Invalid := TIntegerList.Create;
  for I := 0 to Races.Count - 1 do
    if Races.GetRace(I).FEnabled then Available.Add(I);
  for I := 1 to FChildren.Count - 1 do
  begin
    Index := Available.IndexOf(TPlayer(FChildren.List^[I]).FPlayerRace);
    if Index = -1 then Invalid.Add(I)
    else Available.Delete(Index);
  end;
  I := 0;
  DefaultRace := -1;
  while (I <> AoWHSSet.FRaceResources.Count) and (DefaultRace = -1) do
  begin
    if AoWHSSet.FRaceResources.GetRaceResource(I) <> nil then
      if (Races = nil) or Races.GetRace(I).FEnabled then DefaultRace := I;
    Inc(I);
  end;
  for I := 0 to Invalid.Count - 1 do
    if Available.Count = 0 then TPlayer(FChildren.List^[Invalid[I]]).SetRace(DefaultRace)
    else
    begin
      TPlayer(FChildren.List^[Invalid[I]]).SetRace(Available[0]);
      Available.Delete(0);
    end;
  Invalid.Free;
  Available.Free;
end;

function TPlayerList.VerifyRaces(Races: TRaceList): Integer;
var
  Valid: Boolean;
  I, J: Integer;
  Player: TPlayer;
begin
  Valid := True;
  I := 1;
  while Valid and (I < FChildren.Count) do
  begin
    Player := TPlayer(FChildren.List^[I]);
    Valid := (Player.FPlayerRace <> -1) and Races.GetRace(Player.FPlayerRace).FEnabled;
    if Valid then
    begin
      J := 1;
      while Valid and (J <> FChildren.Count) do
      begin
        Valid := (J = I) or (GetPlayers(J).FPlayerRace <> Player.FPlayerRace);
        Inc(J);
      end;
    end;
    if Valid then Inc(I);
  end;
  if Valid then Result := 0
  else Result := I;
end;

function TPlayerList.GetSuperiorPlayer: Shortint;
var
  Maximum, BestPlayer, I, Value: Integer;
begin
  Maximum := 0;
  BestPlayer := -1;
  for I := 1 to Count - 1 do
    if GetPlayers(I).FStatus = psPlaying then
    begin
      Value := GetPlayers(I).GetSuperiority;
      if Value > Maximum then
      begin
        Maximum := Value;
        BestPlayer := I;
      end;
    end;
  Result := BestPlayer;
end;

function TPlayerList.IndexOfPlayerType(PlayerType: TPlayerType): Integer;
var
  I: Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if GetPlayers(Result).FPlayerType = PlayerType then
    begin
      { The search index is the function result. }
      Exit;
    end;
  end;
  Result := -1;
  { Return the final search index. }
end;

constructor TLeaderSetupControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TIntegerList.Create;
  FOriginalLeader := TLeader.Create(nil);
  FLeader := TLeader.Create(nil);
  FRefCount := 1;
  FMode := [lsmLook, lsmSettings, lsmSpheres];
  FOnDone := nil;
end;

destructor TLeaderSetupControl.Destroy;
begin
  FOriginalLeader.Free;
  FLeader.Free;
  FItems.Free;
  inherited Destroy;
end;

function TLeaderSetupControl.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TLeaderSetupControl.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then Destroy;
end;

function TLeaderSetupControl.Done: Boolean;
begin
  if Assigned(FOnDone) then FOnDone(Self);
  Result := True;
end;

