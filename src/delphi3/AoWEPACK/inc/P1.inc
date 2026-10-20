constructor TAoWHSSet.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWHSSet.Destroy;
begin end;

class function TAoWHSSet.ClassID: Integer;
begin Result := 0; end;

procedure TAoWHSSet.GetFileCRC(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSSet.RetrieveHSSCRC;
begin end;

procedure TAoWHSSet.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWHSSet.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWHSSet.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TRace.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TRace.Destroy;
begin end;

procedure TRace.GetRelationValue(A1: Integer);
begin end;

procedure TRace.GetRelation(A1: Integer);
begin end;

procedure TRace.SetPlayerRelationValue(A1: Byte; A2: Integer);
begin end;

procedure TRace.GetPlayerRelationValue(A1: Integer);
begin end;

procedure TRace.GetPlayerRelation(A1: Integer);
begin end;

procedure TRace.NewDay;
begin end;

procedure TRace.GetDefaultRaceRelation(A1: Integer);
begin end;

class function TRace.ClassID: Integer;
begin Result := 0; end;

procedure TRace.ResetDefaultRaceRelations;
begin end;

procedure TRace.ResetPlayerRelations;
begin end;

procedure TRace.SetRace(A1: Byte);
begin end;

procedure TRace.SetEnabled(A1: Integer);
begin end;

procedure TRace.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRace.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TRaceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRaceList.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRaceList.GetRace(A1: Integer);
begin end;

procedure TRaceList.GetEnabledRaces;
begin end;

procedure TRaceList.GetRandomRace;
begin end;

procedure TRaceList.ResetPlayerRelations;
begin end;

procedure TRaceList.ResetDefaultRelations;
begin end;

procedure TRaceList.Update(A1: Integer; A2: Integer);
begin end;

class function TFaceResource.ClassID: Integer;
begin Result := 0; end;

function TFaceResource.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TFaceResource.FaceResourceIndex;
begin end;

procedure TFaceResource.LinkToIL;
begin end;

procedure TFaceResource.ReleaseIL;
begin end;

procedure TFaceResource.SetImageLibraryName(A1: Integer; A2: Integer);
begin end;

function TFaceResource.AddRef: Integer;
begin Result := 0; end;

function TFaceResource.Release: Integer;
begin Result := 0; end;

function TFaceResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TFaceResource.GetFaceImage;
begin end;

procedure TFaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TFaceResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TFaceResourceList.IndexOfFaceImage(A1: Integer);
begin end;

procedure TFaceResourceList.GetFaceResource(A1: Integer);
begin end;

procedure TFaceResourceList.PrevFace(A1: Integer);
begin end;

procedure TFaceResourceList.NextFace(A1: Integer);
begin end;

constructor TUnitSelector.Create;
begin end;

destructor TUnitSelector.Destroy;
begin end;

procedure TUnitSelector.AddRef;
begin end;

procedure TUnitSelector.Release;
begin end;

procedure TUnitSelector.SetSelection(A1: Byte);
begin end;

procedure TUnitSelector.GetSelectionCount;
begin end;

procedure TUnitSelector.CanSelect(A1: Integer);
begin end;

procedure TUnitSelector.Select;
begin end;

procedure TUnitSelector.Cancel;
begin end;

procedure TUnitSelector.CanSelectUnit(A1: Integer);
begin end;

procedure TUnitSelector.Setup(A1: Integer; A2: Integer);
begin end;

constructor TUnitSelectorAAI.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitSelectorAAI.Destroy;
begin end;

procedure TUnitSelectorAAI.SetUnitSelector(A1: Integer);
begin end;

destructor TUnitCategoryList.Destroy;
begin end;

procedure TUnitCategoryList.GetCategory(A1: Integer);
begin end;

procedure TUnitCategoryList.Clear;
begin end;

procedure TUnitCategoryList.SortUnits;
begin end;

procedure TUnitCategoryList.AddUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitSelectionControl.Create(A1: Byte);
begin end;

destructor TUnitSelectionControl.Destroy;
begin end;

procedure TUnitSelectionControl.SetSelectedUnitIndex(A1: Integer);
begin end;

procedure TUnitSelectionControl.SetSelectedHero(A1: Integer);
begin end;

procedure TUnitSelectionControl.GetUnitCategoryList(A1: Integer);
begin end;

procedure TUnitSelectionControl.GetUnitCategoryEnabled(A1: Integer);
begin end;

procedure TUnitSelectionControl.SetUnitCategoryEnabled(A1: Integer; A2: Integer);
begin end;

procedure TUnitSelectionControl.Reset;
begin end;

procedure TUnitSelectionControl.DisableAllCategories;
begin end;

procedure TUnitSelectionControl.UpdateSelection;
begin end;

constructor TActivateAbilityInfo.Create(AOwner: Engine.TECustomNode);
begin end;

function TActivateAbilityInfo.AddRef: Integer;
begin Result := 0; end;

function TActivateAbilityInfo.Release: Integer;
begin Result := 0; end;

destructor TCustomAbilityList.Destroy;
begin end;

procedure TCustomAbilityList.Clear;
begin end;

procedure TCustomAbilityList.SetAbSet(A1: Integer; A2: Byte);
begin end;

procedure TCustomAbilityList.GetAbSet(A1: Integer);
begin end;

procedure TCustomAbilityList.SetAbCount(A1: Integer);
begin end;

procedure TCustomAbilityList.GetAbCount;
begin end;

procedure TCustomAbilityList.AssignAb(A1: Integer; A2: Integer);
begin end;

procedure TCustomAbilityList.CompareAb(A1: Integer);
begin end;

procedure TCustomAbilityList.ComposeAb(A1: Integer);
begin end;

procedure TCustomAbilityList.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TCustomAbilityList.GetItemString(A1: Integer);
begin end;

procedure TCustomAbilityList.SetItemString(A1: Integer);
begin end;

procedure TCustomAbilityList.ListAbilitiesEx(A1: Integer; A2: Word);
begin end;

procedure TAbilityData.GetAbilityID;
begin end;

procedure TAbilityData.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TAbility.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbility.Destroy;
begin end;

procedure TAbility.ShowInfo(A1: Integer; A2: Integer);
begin end;

procedure TAbility.GetSourceName(A1: Integer; A2: Integer);
begin end;

procedure TAbility.SetAb(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbility.GetControlType;
begin end;

procedure TAbility.GetCombatMode(A1: Integer);
begin end;

procedure TAbility.GetDamageValue(A1: Integer; A2: Integer);
begin end;

procedure TAbility.GetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbility.fcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbility.fcValidRoundDistance(A1: Integer; A2: Integer);
begin end;

procedure TAbility.fcGetDamageValue(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbility.tcGetDamageValueEx(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbility.tcGetDamageValue(A1: Integer);
begin end;

procedure TAbility.GetCombatInfo(A1: Integer; A2: Integer);
begin end;

procedure TAbility.GetWallCombatFeatures(A1: Integer);
begin end;

procedure TAbility.CanExpand(A1: Integer);
begin end;

procedure TAbility.ExpandName(A1: Integer; A2: Integer);
begin end;

procedure TAbility.ExpandCost;
begin end;

procedure TAbility.Expand(A1: Integer; A2: Integer);
begin end;

procedure TAbility.Remove(A1: Integer; A2: Integer);
begin end;

procedure TAbility.GetInherent(A1: Integer);
begin end;

procedure TAbility.GetInherentLevel(A1: Integer);
begin end;

procedure TAbility.GetSkillPoints(A1: Integer);
begin end;

procedure TAbility.AbilityDataClass;
begin end;

procedure TAbility.GetName(A1: Integer; A2: Integer);
begin end;

procedure TAbility.GetAttack;
begin end;

procedure TAbility.GetDefense;
begin end;

procedure TAbility.GetResistance;
begin end;

procedure TAbility.GetDamage;
begin end;

procedure TAbility.GetMoveTypes;
begin end;

procedure TAbility.GetHidden;
begin end;

procedure TAbility.GetLevel(A1: Integer);
begin end;

procedure TAbility.GetOffensiveStrength(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbility.ListInfo(A1: Integer; A2: Byte);
begin end;

procedure TAbility.GetEnabled(A1: Integer);
begin end;

procedure TAbility.GetImmunityTypes;
begin end;

procedure TAbility.GetProtectionTypes;
begin end;

procedure TAbility.ListSpells;
begin end;

procedure TAbility.GetAbilityType;
begin end;

procedure TAbility.CombatObjectDestroyed(A1: Integer);
begin end;

procedure TAbility.fcPrefetchCombatCommands(A1: Integer);
begin end;

procedure TAbility.fcExecuteCombatCommand(A1: Integer; A2: Integer);
begin end;

procedure TAbility.Execute;
begin end;

procedure TAbility.NewDay(A1: Integer);
begin end;

procedure TAbility.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TAbility.NewCombatTurn(A1: Integer; A2: Integer);
begin end;

procedure TAbility.CombatDone(A1: Integer);
begin end;

procedure TAbility.CanActivate(A1: Integer; A2: Integer);
begin end;

procedure TAbility.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAbility.CanActivateCombat(A1: Integer; A2: Integer);
begin end;

procedure TAbility.ActivateCombat(A1: Integer; A2: Integer);
begin end;

procedure TAbility.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TAbilityOwner.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAbilityOwner.Clear;
begin end;

procedure TAbilityOwner.GetAbilitySelectionTypes(A1: Word; A2: Integer);
begin end;

procedure TAbilityOwner.GetOwnerName(A1: Integer);
begin end;

procedure TAbilityOwner.ValidateOwnerTypeAbilities;
begin end;

procedure TAbilityOwner.GetAbilityData(A1: Integer);
begin end;

procedure TAbilityOwner.AssignAb(A1: Integer);
begin end;

procedure TAbilityOwner.AddAbilityData(A1: Integer);
begin end;

procedure TAbilityOwner.RemoveAbilityData(A1: Integer);
begin end;

procedure TAbilityOwner.RemoveAbilityDataID(A1: Integer);
begin end;

procedure TAbilityOwner.SetAbSet(A1: Integer; A2: Byte);
begin end;

procedure TAbilityOwner.Execute;
begin end;

procedure TAbilityOwner.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAbilityOwner.UpdateDefaultAbilities(A1: Integer);
begin end;

procedure TAbilityOwner.Changed;
begin end;

procedure TAbilityOwner.ExpandAbility(A1: Integer);
begin end;

procedure TAbilityOwner.RemoveAbility(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbAttackAll;
begin end;

procedure TAbilityOwner.GetAbDefenseAll;
begin end;

procedure TAbilityOwner.GetAbResistanceAll;
begin end;

procedure TAbilityOwner.GetAbDamageAll;
begin end;

procedure TAbilityOwner.GetAbMoveTypesAll;
begin end;

procedure TAbilityOwner.GetAbWallCombatFeatures;
begin end;

procedure TAbilityOwner.GetAbProtectionTypesAll;
begin end;

procedure TAbilityOwner.GetAbImmunityTypesAll;
begin end;

procedure TAbilityOwner.GetAbName(A1: Integer; A2: Integer);
begin end;

procedure TAbilityOwner.GetAbAttack(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbDefense(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbResistance(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbDamage(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbMoveTypes(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbProtectionTypes(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbImmunityTypes(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbLevel(A1: Integer);
begin end;

procedure TAbilityOwner.GetAbEnabled(A1: Integer);
begin end;

procedure TAbilityOwner.TriggerNewDay;
begin end;

procedure TAbilityOwner.TriggerNewTurn(A1: Byte; A2: Integer);
begin end;

procedure TAbilityOwner.TriggerNewCombatTurn(A1: Integer; A2: Byte);
begin end;

procedure TAbilityOwner.TriggerCombatDone(A1: Integer);
begin end;

procedure TAbilityOwner.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAbilityOwner.ListAbilitiesEx(A1: Integer; A2: Word);
begin end;

procedure TAbilityOwner.ListAbilities(A1: Integer);
begin end;

procedure TAbilityTypeList.GetAbility(A1: Integer);
begin end;

constructor TAbilityControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbilityControl.Destroy;
begin end;

procedure TAbilityControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAbilityControl.GetCount;
begin end;

procedure TAbilityControl.GetAbility(A1: Integer);
begin end;

procedure TAbilityControl.RegisterAbility(A1: Integer);
begin end;

procedure TAbilityControl.UnregisterAbility(A1: Integer);
begin end;

procedure TAbilityControl.UnregisterAll;
begin end;

procedure TAbilityControl.UnregisterAbilityID(A1: Integer);
begin end;

procedure TAbilityControl.ListAbilities(A1: Integer; A2: Word);
begin end;

procedure TAbilityControl.ListAbilityInfo(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TPlayerStructureList.GetStructure(A1: Integer);
begin end;

procedure TArmyList.GetArmy(A1: Integer);
begin end;

procedure TDiplomaticRelationList.Create(A1: Byte);
begin end;

procedure TDiplomaticRelationList.GetDiplomaticRelation(A1: Integer);
begin end;

procedure TDiplomaticRelationList.SetDiplomaticRelation;
begin end;

class function TDiplomaticRelationHistoryItem.ClassID: Integer;
begin Result := 0; end;

procedure TDiplomaticRelationHistoryItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TDiplomaticRelationHistoryList.ClassID: Integer;
begin Result := 0; end;

procedure TDiplomaticRelationHistoryList.GetItems(A1: Integer);
begin end;

procedure TDiplomaticRelationHistoryList.GetLastModifiedOnDay;
begin end;

procedure TDiplomaticRelationHistoryList.GetRelationOnDay(A1: Integer);
begin end;

procedure TDiplomaticRelationHistoryList.Add(A1: Integer; A2: Integer);
begin end;

constructor TPlayerDiplomaticRelations.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerDiplomaticRelations.Destroy;
begin end;

procedure TPlayerDiplomaticRelations.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerDiplomaticRelations.GetDiplomaticRelation(A1: Byte);
begin end;

procedure TPlayerDiplomaticRelations.SetDiplomaticRelation(A1: Integer; A2: Integer);
begin end;

procedure TPlayerDiplomaticRelations.GetHistory(A1: Byte);
begin end;

procedure TPlayerDiplomaticRelations.ValidateHistory;
begin end;

procedure TPlayerDiplomaticRelations.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

class function TTurnInfoItem.ClassID: Integer;
begin Result := 0; end;

procedure TTurnInfoItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTurnInfoItem.GetSuperiority;
begin end;

procedure TTurnInfo.GetTurnInfo(A1: Integer);
begin end;

constructor TPlayerStatistics.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerStatistics.Destroy;
begin end;

procedure TPlayerStatistics.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TIncomeSource.Name(A1: Integer);
begin end;

procedure TIncomeSource.Income;
begin end;

procedure TIncomeSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TIncomeSource.CenterToLocation(A1: Integer; A2: Integer);
begin end;

procedure TIncomeSourceList.GetItems(A1: Integer);
begin end;

constructor TPBEMPlayerSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPBEMPlayerSettings.Destroy;
begin end;

procedure TPBEMPlayerSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPBEMPlayerSettings.SetGame;
begin end;

constructor TPlayer.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayer.Destroy;
begin end;

class function TPlayer.ClassID: Integer;
begin Result := 0; end;

procedure TPlayer.GetBusy;
begin end;

procedure TPlayer.GetSuperiority;
begin end;

procedure TPlayer.GetUnitCount;
begin end;

procedure TPlayer.SetPlayerIndex(A1: Byte);
begin end;

procedure TPlayer.SetGameOverStatus(A1: Byte);
begin end;

procedure TPlayer.Surrender;
begin end;

procedure TPlayer.Win;
begin end;

procedure TPlayer.Validate(A1: Integer);
begin end;

procedure TPlayer.LockBusy;
begin end;

procedure TPlayer.UnlockBusy;
begin end;

procedure TPlayer.LogbookChangedEvent;
begin end;

procedure TPlayer.BeginUpdate;
begin end;

procedure TPlayer.EndUpdate;
begin end;

procedure TPlayer.ArmiesChanged;
begin end;

procedure TPlayer.SetGems(A1: Integer);
begin end;

procedure TPlayer.UpdateIncome(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.RegisterIncomeSource(A1: Integer);
begin end;

procedure TPlayer.UnregisterIncomeSource(A1: Integer);
begin end;

procedure TPlayer.GetUpkeep;
begin end;

procedure TPlayer.SetArmyUpkeep(A1: Integer);
begin end;

procedure TPlayer.SetMagicUpkeep(A1: Integer);
begin end;

procedure TPlayer.GetName(A1: Integer);
begin end;

procedure TPlayer.GetNameEx(A1: Integer);
begin end;

procedure TPlayer.SetName(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.GetFace;
begin end;

procedure TPlayer.GetHeroCountMax;
begin end;

procedure TPlayer.GetIdealHeroJoinDay;
begin end;

procedure TPlayer.GetIdealHeroEmergeDay;
begin end;

procedure TPlayer.ResetBaseHeroJoinDay;
begin end;

procedure TPlayer.MakeHeroEmerge(A1: Integer);
begin end;

procedure TPlayer.UpdateHeroJoin;
begin end;

procedure TPlayer.GetHeroJoinChance(A1: Integer);
begin end;

procedure TPlayer.GetHeroJoinLevelMax(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ValidateLeader;
begin end;

procedure TPlayer.SetLeader(A1: Integer);
begin end;

procedure TPlayer.SetRace(A1: Byte);
begin end;

procedure TPlayer.SetEndTurn(A1: Byte);
begin end;

procedure TPlayer.UpdateLogbook;
begin end;

procedure TPlayer.UpdateTurnInfo;
begin end;

procedure TPlayer.UpdateAlliedPlayersSeen;
begin end;

procedure TPlayer.SetupAIValidAttackPlayers;
begin end;

procedure TPlayer.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayer.GetFirstDaySeen(A1: Byte);
begin end;

procedure TPlayer.GetLastDaySeen(A1: Byte);
begin end;

procedure TPlayer.PlayerSeen(A1: Integer);
begin end;

procedure TPlayer.GetLeaderLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPlayer.GetLocal;
begin end;

procedure TPlayer.RegisterVictoryLocation;
begin end;

procedure TPlayer.UnregisterVictoryLocation;
begin end;

procedure TPlayer.CheckCaptureLocations;
begin end;

procedure TPlayer.CaptureLocationsLeft;
begin end;

procedure TPlayer.CreateDiplomaticAction(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TPlayer.DiplomaticActionAleadySend(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TPlayer.ListDiplomaticActions(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ValidAttackRelation(A1: Integer; A2: Integer);
begin end;

procedure TPlayer.ChangePlayerSettings(A1: Integer);
begin end;

constructor TPlayerList.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerList.Destroy;
begin end;

procedure TPlayerList.GetDiplomaticRelationCount(A1: Integer; A2: Byte);
begin end;

procedure TPlayerList.GetDiplomaticRelation(A1: Byte; A2: Integer);
begin end;

procedure TPlayerList.SetDiplomaticRelation(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TPlayerList.GetActivePlayers(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.Update;
begin end;

procedure TPlayerList.BeginUpdate;
begin end;

procedure TPlayerList.EndUpdate;
begin end;

procedure TPlayerList.Assign(Source: Engine.TEObject; AEngine: Engine.TEngine);
begin end;

procedure TPlayerList.GetPlayers(A1: Integer);
begin end;

procedure TPlayerList.GetActivePlayersAllied;
begin end;

procedure TPlayerList.GetAverageHeroLevel;
begin end;

procedure TPlayerList.GetAverageHeroCount;
begin end;

procedure TPlayerList.GetMaxHeroCount;
begin end;

procedure TPlayerList.GetNumberOfPlayers;
begin end;

procedure TPlayerList.RaceToPlayer(A1: Byte);
begin end;

procedure TPlayerList.SetNumberOfPlayers(A1: Integer);
begin end;

procedure TPlayerList.ValidateRaces(A1: Integer);
begin end;

procedure TPlayerList.VerifyRaces(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.GetSuperiorPlayer(A1: Integer; A2: Integer);
begin end;

procedure TPlayerList.IndexOfPlayerType(A1: Integer);
begin end;

constructor TLeaderSetupControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TLeaderSetupControl.Destroy;
begin end;

function TLeaderSetupControl.AddRef: Integer;
begin Result := 0; end;

function TLeaderSetupControl.Release: Integer;
begin Result := 0; end;

procedure TLeaderSetupControl.Done;
begin end;

constructor TPlayerControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerControl.Destroy;
begin end;

procedure TPlayerControl.Setup;
begin end;

procedure TPlayerControl.GetSyncValue(A1: Integer);
begin end;

procedure TPlayerControl.OutOfSync;
begin end;

procedure TPlayerControl.NewFrame;
begin end;

procedure TPlayerControl.NewDay;
begin end;

procedure TPlayerControl.AutoSave;
begin end;

procedure TPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.StartNewMap;
begin end;

procedure TPlayerControl.StartLoadedMap;
begin end;

procedure TPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.GameOver(A1: Integer; A2: Integer);
begin end;

procedure TPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TPlayerControl.SetSeatedPlayer(A1: Integer);
begin end;

procedure TPlayerControl.LockAI;
begin end;

procedure TPlayerControl.ListPlayerInfo(A1: Integer);
begin end;

procedure TPlayerControl.ExitSaveGameCallBack(A1: Integer);
begin end;

procedure TPlayerControl.SaveGameOnExitCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ExitNetworkGameCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ExitGame(A1: Byte);
begin end;

procedure TPlayerControl.PasswordFailed;
begin end;

procedure TPlayerControl.PasswordValidated;
begin end;

procedure TPlayerControl.PasswordTryAgainCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ValidatePasswordCallBack(A1: Integer);
begin end;

procedure TPlayerControl.ValidatePassword(A1: Integer);
begin end;

procedure TPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerControl.ValidateDisconnectedPlayers;
begin end;

procedure TPlayerControl.PlayerDisconnected(A1: Integer);
begin end;

procedure TPlayerControl.ConnectionLost;
begin end;

class function TTurnPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TTurnPlayerControl.Setup;
begin end;

procedure TTurnPlayerControl.NewDay;
begin end;

procedure TTurnPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.ReplayLogbook;
begin end;

procedure TTurnPlayerControl.SetSeatedPlayer(A1: Integer);
begin end;

procedure TTurnPlayerControl.ShowNewTurnCallBack;
begin end;

procedure TTurnPlayerControl.StartGameCallBack;
begin end;

procedure TTurnPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.DefaultStartMap;
begin end;

procedure TTurnPlayerControl.StartNewMap;
begin end;

procedure TTurnPlayerControl.StartLoadedMapEx;
begin end;

procedure TTurnPlayerControl.PasswordValidated;
begin end;

procedure TTurnPlayerControl.StartLoadedMap;
begin end;

procedure TTurnPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TTurnPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.GameOver(A1: Integer; A2: Integer);
begin end;

procedure TTurnPlayerControl.ValidateTurnTiming;
begin end;

class function TPBEMPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TPBEMPlayerControl.TerminateEmailGame;
begin end;

procedure TPBEMPlayerControl.TerminateEmailGameCallBack;
begin end;

procedure TPBEMPlayerControl.SendEmailGameAutomatedCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.SendEmailGameManualCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.SendEmailGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TPBEMPlayerControl.TriggerGameRestartedEvents(A1: Integer);
begin end;

procedure TPBEMPlayerControl.EndTurnGameSavedCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TPBEMPlayerControl.StartLoadedEmailGame;
begin end;

procedure TPBEMPlayerControl.ContinueRestartedGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ContinueTurnDoneGameCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ValidateLoadedMap;
begin end;

procedure TPBEMPlayerControl.PasswordValidated;
begin end;

procedure TPBEMPlayerControl.StartLoadedMap;
begin end;

procedure TPBEMPlayerControl.StartNewMap;
begin end;

procedure TPBEMPlayerControl.ExitGameSaveAsCallBack(A1: Integer);
begin end;

procedure TPBEMPlayerControl.ExitGame(A1: Byte);
begin end;

class function TSimultaniousPlayerControl.ClassID: Integer;
begin Result := 0; end;

procedure TSimultaniousPlayerControl.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.Setup;
begin end;

procedure TSimultaniousPlayerControl.EndTurn(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.NewDay;
begin end;

procedure TSimultaniousPlayerControl.StartGameCallBack;
begin end;

procedure TSimultaniousPlayerControl.StartNewMap;
begin end;

procedure TSimultaniousPlayerControl.StartLoadedMapEx;
begin end;

procedure TSimultaniousPlayerControl.PasswordValidated;
begin end;

procedure TSimultaniousPlayerControl.StartLoadedMap;
begin end;

procedure TSimultaniousPlayerControl.GameOverEventHandled(A1: Integer);
begin end;

procedure TSimultaniousPlayerControl.SetPlayerGameOverStatus(A1: Integer; A2: Integer);
begin end;

procedure TSimultaniousPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerConnectionEventLog.Setup(A1: Byte; A2: Byte);
begin end;

procedure TPlayerConnectionEventLog.ExitSaveGameCallBack(A1: Integer);
begin end;

procedure TPlayerConnectionEventLog.Yes;
begin end;

procedure TPlayerConnectionEventLog.No;
begin end;

constructor TRaceResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TRaceResource.Destroy;
begin end;

function TRaceResource.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRaceResource.GetFace;
begin end;

procedure TRaceResource.GetRaceIndex;
begin end;

procedure TRaceResource.LinkToIL;
begin end;

procedure TRaceResource.ReleaseIL;
begin end;

procedure TRaceResource.SetImageLibraryName(A1: Integer; A2: Integer);
begin end;

function TRaceResource.AddRef: Integer;
begin Result := 0; end;

function TRaceResource.Release: Integer;
begin Result := 0; end;

class function TRaceResource.ClassID: Integer;
begin Result := 0; end;

class function TRaceResource.ResourceEditName: string;
begin Result := ''; end;

function TRaceResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRaceResource.SetCellImage(Value: ImageLib.TLibraryImage);
begin end;

procedure TRaceResource.GetCityImage(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TRaceResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TRaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TRaceResource.GetAlignment;
begin end;

constructor TRaceResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TRaceResourceList.GetRaceResource(A1: Integer);
begin end;

procedure TRaceResourceList.GetMaxRaceIndex;
begin end;

constructor TFlagControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFlagControl.Destroy;
begin end;

procedure TFlagControl.ShowFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TFlagControl.ShowFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TFlagControl.ShowStructureFlag(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TFlagControl.ShowStructureFlagEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

class function TProductionEventLog.ClassID: Integer;
begin Result := 0; end;

class function TUnitProduction.ClassID: Integer;
begin Result := 0; end;

procedure TUnitProduction.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitProductionList.GetItem(A1: Integer);
begin end;

procedure TUnitProductionList.Add(A1: Integer; A2: Integer);
begin end;

procedure TUnitProductionList.IndexOf(A1: Integer);
begin end;

procedure TUnitProductionList.SortOnLevel;
begin end;

class function TProductionItem.ClassID: Integer;
begin Result := 0; end;

procedure TProductionItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionItem.GetName(A1: Integer);
begin end;

procedure TProductionItem.GetNameProgressive(A1: Integer);
begin end;

procedure TProductionQueue.GetItem(A1: Integer);
begin end;

procedure TProductionQueue.IndexOfID(A1: Integer);
begin end;

procedure TProductionQueue.IndexOf(A1: Integer; A2: Integer; A3: Integer);
begin end;

destructor TProductionSettings.Destroy;
begin end;

procedure TProductionSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionSettings.Clear;
begin end;

destructor TProductionTE.Destroy;
begin end;

class function TProductionTE.ClassID: Integer;
begin Result := 0; end;

procedure TProductionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TProductionTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TProductionControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TProductionControl.Destroy;
begin end;

procedure TProductionControl.BeginUpdate;
begin end;

procedure TProductionControl.EndUpdate;
begin end;

procedure TProductionControl.Update;
begin end;

procedure TProductionControl.Activate;
begin end;

procedure TProductionControl.Deactivate;
begin end;

procedure TProductionControl.GetProduceUnitLevelMax;
begin end;

procedure TProductionControl.GetResearchUnitLevelMax;
begin end;

procedure TProductionControl.CancelProductionReturnGold;
begin end;

procedure TProductionControl.CancelProductionReturnMana;
begin end;

procedure TProductionControl.GetQueueSizeMax;
begin end;

procedure TProductionControl.GetQueueLocked;
begin end;

procedure TProductionControl.ExecuteCancelProduction;
begin end;

procedure TProductionControl.RegisterGroupProduction;
begin end;

procedure TProductionControl.UnregisterGroupProduction;
begin end;

procedure TProductionControl.GroupProductionProduced(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.PlayerChanged;
begin end;

procedure TProductionControl.CanExecuteProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.ExecuteProduction(A1: Integer);
begin end;

procedure TProductionControl.ExecuteAddProduction(A1: Integer);
begin end;

procedure TProductionControl.ExecuteDeleteProduction(A1: Integer);
begin end;

procedure TProductionControl.ExecuteDeleteProductions;
begin end;

procedure TProductionControl.ExecuteAIProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.ExecuteAIResearch(A1: Integer);
begin end;

procedure TProductionControl.ExecuteProductionTE(A1: Integer);
begin end;

procedure TProductionControl.CreateProductionTE;
begin end;

procedure TProductionControl.UnitProduced;
begin end;

procedure TProductionControl.CreateUnitProduction(A1: Integer);
begin end;

procedure TProductionControl.UnitProductionGold(A1: Integer);
begin end;

procedure TProductionControl.UnitProductionGoldUpkeep(A1: Integer);
begin end;

procedure TProductionControl.UnitProductionMana(A1: Integer);
begin end;

procedure TProductionControl.UnitProductionManaUpkeep(A1: Integer);
begin end;

procedure TProductionControl.UnitProductionTime(A1: Integer);
begin end;

procedure TProductionControl.CanProduceUnit(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TProductionControl.ProduceUnitEx(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.ProduceUnit(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.UnitResearched;
begin end;

procedure TProductionControl.UnitResearchGold(A1: Integer);
begin end;

procedure TProductionControl.UnitResearchMana;
begin end;

procedure TProductionControl.UnitResearchTime(A1: Integer);
begin end;

procedure TProductionControl.CanResearchUnit(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.ResearchUnit(A1: Integer; A2: Byte);
begin end;

procedure TProductionControl.Produce(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.DeleteProduction(A1: Integer);
begin end;

procedure TProductionControl.DeleteProductions;
begin end;

procedure TProductionControl.RetryProductionExecution(A1: Integer);
begin end;

procedure TProductionControl.SetLoopQueueTo(A1: Integer);
begin end;

procedure TProductionControl.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TProductionControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TProductionControl.ProductionDone;
begin end;

procedure TProductionControl.NewTurn(A1: Integer);
begin end;

procedure TProductionControl.LockQueueProduction(A1: Integer);
begin end;

procedure TProductionControl.LoopableProduction(A1: Integer);
begin end;

procedure TProductionControl.GetProductionName(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.GetProductionNameProgressive(A1: Integer; A2: Integer);
begin end;

procedure TProductionControl.FindOptimalResearchProduction(A1: Integer; A2: Integer);
begin end;

procedure TProductionControlList.GetPC(A1: Integer);
begin end;

destructor TStructureShadow.Destroy;
begin end;

procedure TStructureShadow.SetVisible(Value: Boolean);
begin end;

function TStructureShadow.GetVisible: Boolean;
begin Result := False; end;

procedure TStructureShadow.Connect;
begin end;

procedure TStructureShadow.Disconnect;
begin end;

function TStructureShadow.GetShowPriority: Integer;
begin Result := 0; end;

procedure TStructureShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

class function TStructure.ClassID: Integer;
begin Result := 0; end;

constructor TStructure.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructure.Destroy;
begin end;

procedure TStructure.BeginUpdate;
begin end;

procedure TStructure.EndUpdate;
begin end;

procedure TStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructure.ExecuteAI(A1: Integer; A2: Integer);
begin end;

procedure TStructure.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

function TStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin Result := 0; end;

procedure TStructure.UpdateRoads(A1: Integer);
begin end;

procedure TStructure.GetPlayer;
begin end;

function TStructure.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TStructure.RemoveFromMap;
begin end;

procedure TStructure.CreateShadow;
begin end;

procedure TStructure.DestroyShadow;
begin end;

procedure TStructure.Update;
begin end;

procedure TStructure.CreateTE;
begin end;

procedure TStructure.SetupTE(A1: Integer);
begin end;

procedure TStructure.ExecuteTE(A1: Integer; A2: Integer);
begin end;

function TStructure.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin Result := 0; end;

procedure TStructure.GetName(A1: Integer);
begin end;

procedure TStructure.GetCurrentActivityText(A1: Integer);
begin end;

procedure TStructure.GetDescription;
begin end;

procedure TStructure.CanDblClick;
begin end;

function TStructure.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TStructure.PlaySelectSample;
begin end;

procedure TStructure.Select;
begin end;

procedure TStructure.Unselect;
begin end;

procedure TStructure.FogChanged;
begin end;

procedure TStructure.GetTopBorderImage;
begin end;

procedure TStructure.GetMiddleBorderImage;
begin end;

procedure TStructure.GetBottomBorderImage;
begin end;

function TStructure.GetOverlay(Index: Integer): Shortint;
begin Result := 0; end;

function TStructure.GetTerrain(Index: Integer): ShortInt;
begin Result := 0; end;

function TStructure.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin Result := False; end;

function TStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin Result := False; end;

procedure TStructure.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

function TStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

procedure TStructure.GetRazeable;
begin end;

procedure TStructure.GetRazed;
begin end;

procedure TStructure.SetRazed(A1: Integer);
begin end;

procedure TStructure.VisibleForPlayer(A1: Byte);
begin end;

procedure TStructure.ValidateObservation(A1: Byte);
begin end;

procedure TStructure.ExecuteRebuild(A1: Integer);
begin end;

procedure TStructure.ExecuteBuild(A1: Integer; A2: Byte);
begin end;

procedure TStructure.GetBuilding;
begin end;

procedure TStructure.BuildingDone;
begin end;

procedure TStructure.GetRebuildInfo(A1: Integer; A2: Integer);
begin end;

procedure TStructure.CanRebuild(A1: Integer; A2: Integer);
begin end;

procedure TStructure.Rebuild(A1: Integer);
begin end;

procedure TStructure.NewDay;
begin end;

procedure TStructure.NewTurn(A1: Integer);
begin end;

procedure TStructure.ArmyPlaced(A1: Integer);
begin end;

procedure TStructure.ArmyRemoved;
begin end;

procedure TStructure.ArmyChanged;
begin end;

procedure TStructure.SeatedPlayerChanged;
begin end;

procedure TStructure.GetDefensePriority;
begin end;

procedure TStructure.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TStructure.ListUnits(A1: Integer);
begin end;

procedure TStructure.ListArmies(A1: Integer);
begin end;

procedure TStructure.ValidateMap(A1: Integer);
begin end;

procedure TStructure.MainValidateMap(A1: Integer);
begin end;

procedure TStructure.Activate;
begin end;

procedure TStructure.Deactivate;
begin end;

procedure TStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TStructure.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TStructure.ShowBorderImage(A1: Integer; A2: Integer);
begin end;

procedure TStructure.ShowBorderImageDC(A1: Integer; A2: Integer);
begin end;

procedure TStructure.CanRaze(A1: Byte; A2: Integer);
begin end;

procedure TStructure.GenerateRazeDefenders(A1: Integer; A2: Integer);
begin end;

procedure TStructure.SetupRazeDefenderAG(A1: Integer; A2: Integer);
begin end;

procedure TStructure.PlaceRazeDefenders(A1: Byte);
begin end;

procedure TStructure.ShowRazeAnimation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TStructure.ExecuteRaze(A1: Integer; A2: Integer);
begin end;

procedure TStructure.RazeEx(A1: Integer);
begin end;

procedure TStructure.Raze(A1: Integer);
begin end;

procedure TStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

constructor TStructureResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureResource.Destroy;
begin end;

class function TStructureResource.ClassID: Integer;
begin Result := 0; end;

class function TStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TStructureResource.CalculatePadIndex;
begin end;

procedure TStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureResource.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TPlayerStructure.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerStructure.Destroy;
begin end;

class function TPlayerStructure.ClassID: Integer;
begin Result := 0; end;

procedure TPlayerStructure.GetVictoryLocation(A1: Byte);
begin end;

procedure TPlayerStructure.SetVictoryLocation(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.RegisterVictoryLocations;
begin end;

procedure TPlayerStructure.UnregisterVictoryLocations;
begin end;

procedure TPlayerStructure.BuildingDone;
begin end;

procedure TPlayerStructure.CanRebuild(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.ExecuteRebuild(A1: Integer);
begin end;

procedure TPlayerStructure.ExecuteBuild(A1: Integer; A2: Byte);
begin end;

procedure TPlayerStructure.UpdatePlayer;
begin end;

procedure TPlayerStructure.NewTurn(A1: Integer);
begin end;

procedure TPlayerStructure.NewDay;
begin end;

procedure TPlayerStructure.StructureCaptured(A1: Integer; A2: Byte);
begin end;

procedure TPlayerStructure.GetCombatEventText(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.FinalizeCombat(A1: Integer);
begin end;

procedure TPlayerStructure.SetPlayer(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.UpdateFlagID;
begin end;

procedure TPlayerStructure.ArmyPlaced(A1: Integer);
begin end;

procedure TPlayerStructure.ArmyChanged;
begin end;

procedure TPlayerStructure.GetIncome(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.GetPower;
begin end;

procedure TPlayerStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TPlayerStructure.TrueVisionRange;
begin end;

procedure TPlayerStructure.VisibilityRange;
begin end;

procedure TPlayerStructure.UpdatePlayerSeen;
begin end;

procedure TPlayerStructure.UpdateExploration;
begin end;

procedure TPlayerStructure.UpdateUnfog;
begin end;

procedure TPlayerStructure.SeatedPlayerChanged;
begin end;

procedure TPlayerStructure.Activate;
begin end;

procedure TPlayerStructure.Deactivate;
begin end;

procedure TPlayerStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

function TPlayerStructure.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TPlayerStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TPlayerStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TPlayerStructure.GetDefaultAITargetPriority;
begin end;

procedure TPlayerStructure.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.GetMoveAction(A1: Integer; A2: Integer);
begin end;

procedure TPlayerStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

constructor TPlayerStructureResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPlayerStructureResource.Destroy;
begin end;

class function TPlayerStructureResource.ClassID: Integer;
begin Result := 0; end;

function TPlayerStructureResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TPlayerStructureResource.GenerateFlagPositions;
begin end;

procedure TPlayerStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TPlayerStructureResource.ActivateMsg;
begin end;

procedure TPlayerStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

function TPlayerStructureResource.PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TPlayerStructureIncomeSource.Setup(A1: Integer);
begin end;

procedure TPlayerStructureIncomeSource.Name(A1: Integer);
begin end;

procedure TPlayerStructureIncomeSource.Income;
begin end;

procedure TPlayerStructureIncomeSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPlayerStructurePowerSource.Setup(A1: Integer);
begin end;

procedure TPlayerStructurePowerSource.Name(A1: Integer);
begin end;

procedure TPlayerStructurePowerSource.Power;
begin end;

procedure TPlayerStructurePowerSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TPlayerStructurePowerSource.Select(A1: Integer; A2: Integer);
begin end;

class function TStructureTE.ClassID: Integer;
begin Result := 0; end;

procedure TStructureTE.Initialize(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureTE.Validate;
begin end;

function TStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TRazeStructureEventLog.Yes;
begin end;

class function TConstructStructureTE.ClassID: Integer;
begin Result := 0; end;

procedure TConstructStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TConstructStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TStructureConstructionControl.StructureResource(A1: Integer; A2: Integer);
begin end;

procedure TStructureConstructionControl.ValidateLocation(A1: Integer; A2: Integer);
begin end;

procedure TStructureConstructionControl.CanConstruct(A1: Integer; A2: Integer);
begin end;

procedure TStructureConstructionControl.Construct(A1: Integer);
begin end;

constructor TStructureControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureControl.Destroy;
begin end;

procedure TStructureControl.GetStructure(A1: Integer);
begin end;

procedure TStructureControl.GetCount;
begin end;

procedure TStructureControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TStructureControl.CreateUniqueID;
begin end;

procedure TStructureControl.IndexOfID(A1: Integer);
begin end;

procedure TStructureControl.FindID;
begin end;

procedure TStructureControl.Register(A1: Integer);
begin end;

procedure TStructureControl.Unregister(A1: Integer);
begin end;

procedure TStructureControl.Activate;
begin end;

constructor TStructureAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TStructureAIPA.Destroy;
begin end;

procedure TStructureAIPA.Activate(A1: Integer; A2: Integer);
begin end;

procedure TStructureAIPA.Process(A1: Integer; A2: Integer);
begin end;

constructor TStructurePhase1AIPA.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStructurePhase1AIPA.Priority;
begin end;

constructor TStructurePhase2AIPA.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStructurePhase2AIPA.Priority;
begin end;

constructor TFire.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFire.ClassID: Integer;
begin Result := 0; end;

procedure TFire.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TFire.GetTerrain(Index: Integer): ShortInt;
begin Result := 0; end;

function TFire.GetShowPriority: Integer;
begin Result := 0; end;

procedure TFire.CalcShowPriority(A1: Integer);
begin end;

function TFire.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

function TFire.GetMostFrequentMapFieldTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx, Default: Shortint): Shortint;
begin Result := 0; end;

procedure TFire.Connect;
begin end;

function TFire.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TFire.RemoveFromMap;
begin end;

function TFire.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin Result := False; end;

procedure TFire.SetupExplosion(A1: Integer);
begin end;

procedure TFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TFire.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TFire.TriggerDamage;
begin end;

procedure TFire.CanDoDamage(A1: Integer);
begin end;

procedure TFire.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

function TFire.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TFire.ArmyPlaced(A1: Integer);
begin end;

procedure TFire.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TFire.NewTurn;
begin end;

procedure TFire.NewTurnDone;
begin end;

procedure TFire.WaterMasteryCast;
begin end;

procedure TFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

destructor TFireResource.Destroy;
begin end;

class function TFireResource.ResourceEditName: string;
begin Result := ''; end;

class function TFireResource.ClassID: Integer;
begin Result := 0; end;

function TFireResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure TFireResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFireResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TFireControl.Create;
begin end;

destructor TFireControl.Destroy;
begin end;

procedure TFireControl.GetRndFireResource(A1: Byte; A2: Integer);
begin end;

procedure TFireControl.PlaceFire(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TFireControl.RegisterFireResource;
begin end;

procedure TFireControl.UnregisterFireResource;
begin end;

constructor TTargetSelectionControl.Create;
begin end;

destructor TTargetSelectionControl.Destroy;
begin end;

procedure TTargetSelectionControl.TriggerOnChangeEvent(A1: Byte);
begin end;

procedure TTargetSelectionControl.DeselectHS;
begin end;

procedure TTargetSelectionControl.MouseDownEvent;
begin end;

procedure TTargetSelectionControl.ValidTarget(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTargetSelectionControl.NewFrameEvent;
begin end;

procedure TTargetSelectionControl.MouseMoveEvent;
begin end;

procedure TTargetSelectionControl.ShowSelection(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TTargetSelectionControl.Initialize(A1: Integer);
begin end;

procedure TTargetSelectionControl.Activate;
begin end;

procedure TTargetSelectionControl.Deactivate;
begin end;

procedure TTargetSelectionControl.UnitChanged(A1: Integer);
begin end;

procedure TMovepath.MovePointsToPos(A1: Integer);
begin end;

procedure TMovepath.PosToMovePoints(A1: Integer);
begin end;

procedure TMovepath.GetMovePoints;
begin end;

constructor TMoveSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveSettings.Destroy;
begin end;

procedure TMoveSettings.GetMoveLoc(A1: Integer; A2: Integer);
begin end;

procedure TMoveSettings.GetMovePrio;
begin end;

procedure TMoveSettingsList.GetMoveSettings(A1: Integer);
begin end;

procedure TMoveSettingsList.GetNoneValidMove;
begin end;

procedure TMoveSettingsList.IndexOfMoveObject(A1: Integer);
begin end;

procedure TMoveSettingsList.CalculateMovePositions(A1: Integer; A2: Integer);
begin end;

constructor TMoveSelector.Create;
begin end;

destructor TMoveSelector.Destroy;
begin end;

function TMoveSelector.CreateMCS: Integer;
begin Result := 0; end;

procedure TMoveSelector.Clear;
begin end;

procedure TMoveSelector.SetCurrentMove(A1: Integer);
begin end;

procedure TMoveSelector.Unselect(A1: Integer; A2: Integer);
begin end;

procedure TMoveSelector.ValidateSelection(A1: Integer);
begin end;

procedure TMoveSelector.ExecuteMove;
begin end;

procedure TMoveSelector.AddMoveObject(A1: Integer);
begin end;

procedure TMoveSelector.DeleteMoveObject(A1: Integer);
begin end;

procedure TMoveSelector.DeleteMoves;
begin end;

procedure TMoveSelector.UpdateMoveCursor;
begin end;

procedure TMoveSelector.MouseMoveEvent;
begin end;

procedure TMoveSelector.CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TMoveSelector.SelectPath(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TMoveSelector.MouseDownEvent(A1: Integer);
begin end;

procedure TMoveSelector.Activate(A1: Integer);
begin end;

procedure TMoveSelector.Deactivate;
begin end;

procedure TMoveSelector.ShowMovePaths(A1: Integer);
begin end;

constructor TTextControlItem.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTextControlItem.Destroy;
begin end;

class function TTextControlItem.ClassID: Integer;
begin Result := 0; end;

procedure TTextControlItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTextControl.GetItem(A1: Integer);
begin end;

procedure TTextControl.Delete(A1: Integer);
begin end;

procedure TTextControl.New;
begin end;

procedure TTextControl.FindID(A1: Integer);
begin end;

procedure TTextControl.Sort;
begin end;

procedure TTextControl.IndexOf;
begin end;

procedure TTextControl.RetrieveText(A1: Integer; A2: Integer);
begin end;

class function TFrozenWaterHS.ClassID: Integer;
begin Result := 0; end;

function TFrozenWaterHS.GetLevel: Byte;
begin Result := 0; end;

procedure TFrozenWaterHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFrozenWaterHS.MeltIce;
begin end;

procedure TFrozenWaterHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TFrozenWaterHS.NewTurn(A1: Byte);
begin end;

procedure TFrozenWaterHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TFrozenWaterHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TTutorialControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TTutorialControl.Destroy;
begin end;

procedure TTutorialControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TTutorialControl.ShowMessage(A1: Integer; A2: Byte; A3: Integer);
begin end;

class function TAoWMapField.ClassID: Integer;
begin Result := 0; end;

procedure TAoWMapField.GetExplored(A1: Integer);
begin end;

procedure TAoWMapField.SetExplored(A1: Integer; A2: Integer);
begin end;

procedure TAoWMapField.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWMapField.FogChanged;
begin end;

procedure TAoWMapField.SetFogCount(A1: Byte);
begin end;

procedure TAoWMapField.UpdateMapField;
begin end;

procedure TAoWMapField.GetPlayer;
begin end;

procedure TAoWMapField.GetScannerIcon;
begin end;

procedure TAoWMapField.GetCombatTerrainTag;
begin end;

procedure TAoWMapField.GetConcealmentActive;
begin end;

procedure TAoWMapField.GetMagicShieldActive;
begin end;

procedure TAoWMapField.GetProductionControl;
begin end;

procedure TAoWMapField.GetAITarget(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWMapField.GetMoveAction(A1: Byte);
begin end;

procedure TAoWMapField.GetIndependentRelation;
begin end;

procedure TAoWMapField.GetDefensePriority;
begin end;

procedure TAoWMapField.GetDefenseRequirements(A1: Integer; A2: Integer);
begin end;

procedure TAoWMapField.GetWallType;
begin end;

procedure TAoWMapField.GetArmyHS;
begin end;

procedure TAoWMapField.RestoreTerrain;
begin end;

class function TAoWMapLevel.ClassID: Integer;
begin Result := 0; end;

function TAoWMapLevel.MapFieldClass: Engine.TEObjectClass;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWMapLevel.FogArea(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWMapLevel.UnFogArea(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWMapLevel.UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWMapLevel.ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWMapLevel.ResetFog;
begin end;

procedure TAoWMapLevel.ResetUnFog;
begin end;

procedure TAoWMapLevel.Reset;
begin end;

constructor TAbstractAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbstractAoWHSMap.Destroy;
begin end;

function TAbstractAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAbstractAoWHSMap.SetFogEnabled(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.SetExplorationEnabled(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.PlayCenterAnimation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractAoWHSMap.LockMapChangedEvent;
begin end;

procedure TAbstractAoWHSMap.UnlockMapChangedEvent;
begin end;

procedure TAbstractAoWHSMap.TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint);
begin end;

procedure TAbstractAoWHSMap.MapChanged(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.MapChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.InvalidateMap;
begin end;

procedure TAbstractAoWHSMap.TriggerMapChangedEvent(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.LockScannerIconsChangedEvent;
begin end;

procedure TAbstractAoWHSMap.UnlockScannerIconsChangedEvent;
begin end;

procedure TAbstractAoWHSMap.ScannerIconsChanged(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.ScannerIconsChangedRad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.InvalidateScannerIcons;
begin end;

procedure TAbstractAoWHSMap.TriggerScannerIconsChangedEvent(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMap.UpdateShowMessage;
begin end;

procedure TAbstractAoWHSMap.ShowWarning(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.ShowMessage(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.SetSeatedPlayer(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.SetCurrentPlayer(A1: Byte);
begin end;

procedure TAbstractAoWHSMap.FogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.UnFogArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractAoWHSMap.ExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractAoWHSMap.UnFogExploreArea(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractAoWHSMap.DrawGrid(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.DrawFog(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.ShowHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.HideHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.ShowBackHexagonSelector(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractAoWHSMap.ShowFrontHexagonSelector(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractAoWHSMap.UpdateHexagonSelector;
begin end;

procedure TAbstractAoWHSMap.UpdateStaticScene;
begin end;

procedure TAbstractAoWHSMap.UpdateDynamicScene;
begin end;

procedure TAbstractAoWHSMap.NewFrame;
begin end;

procedure TAbstractAoWHSMap.UpdateFPS(A1: Integer);
begin end;

procedure TAbstractAoWHSMap.DropHeroItem(A1: Integer; A2: Integer);
begin end;

function TAbstractAoWHSMap.GetHeroItemsOnGround(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TAbstractAoWHSMap.DrawSelectionRect(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TAbstractAoWCombatMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAbstractAoWCombatMap.Destroy;
begin end;

procedure TAoWNewHSMapSettings.Create(A1: Byte);
begin end;

procedure TAoWHSMapKeyboard.Lock;
begin end;

procedure TAoWHSMapKeyboard.Unlock;
begin end;

procedure TAoWHSMapKeyboard.RunDefaultTest;
begin end;

procedure TAoWHSMapKeyboard.KeyDown(A1: Integer; A2: Byte);
begin end;

procedure TAbstractAoWHSMapMouse.Create(A1: Byte);
begin end;

destructor TAbstractAoWHSMapMouse.Destroy;
begin end;

procedure TAbstractAoWHSMapMouse.ResetRectangleSelection;
begin end;

procedure TAbstractAoWHSMapMouse.GetSelectingRectangle;
begin end;

procedure TAbstractAoWHSMapMouse.StartRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.UpdateRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.StopRectangleSelection(A1: Integer; A2: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAbstractAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

function TAoWHSMapMouse.GetCursor: Integer;
begin Result := 0; end;

procedure TAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
begin end;

procedure TAoWHSMapMouse.DblClick;
begin end;

constructor TStartupSongList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TStartupSongList.OriginalSongsChanged;
begin end;

constructor TAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWHSMap.Destroy;
begin end;

procedure TAoWHSMap.StartTokenEventLogging;
begin end;

procedure TAoWHSMap.StopTokenEventLogging;
begin end;

procedure TAoWHSMap.SynchroniseBegin;
begin end;

procedure TAoWHSMap.SynchroniseEnd;
begin end;

procedure TAoWHSMap.GetSynchronised;
begin end;

procedure TAoWHSMap.OnExecuteTokenEvent(A1: Integer);
begin end;

procedure TAoWHSMap.PlayerDisconnected;
begin end;

procedure TAoWHSMap.PlayerConnectionLost;
begin end;

procedure TAoWHSMap.OnTokenManagerMessage(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.GetIndependentAIMode;
begin end;

procedure TAoWHSMap.SaveGame(A1: Integer);
begin end;

function TAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAoWHSMap.SetSeatedPlayer(A1: Byte);
begin end;

procedure TAoWHSMap.TerrainVisible(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.Visible(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.WatchingTerrain(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.Watching(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.ValidateTerrainObservation(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.ValidateObservation(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.UnlockGameOverEventCallBack;
begin end;

procedure TAoWHSMap.SelectNextHero;
begin end;

procedure TAoWHSMap.SelectNextArmy;
begin end;

procedure TAoWHSMap.SelectPrevArmy;
begin end;

procedure TAoWHSMap.SeatedPlayerChanged;
begin end;

procedure TAoWHSMap.BeginUnitUpdate;
begin end;

procedure TAoWHSMap.EndUnitUpdate;
begin end;

procedure TAoWHSMap.UnitChanged;
begin end;

procedure TAoWHSMap.UnitDestroyed;
begin end;

procedure TAoWHSMap.BeginArmyUpdate;
begin end;

procedure TAoWHSMap.EndArmyUpdate;
begin end;

procedure TAoWHSMap.ArmyChanged;
begin end;

procedure TAoWHSMap.ArmyDestroyed;
begin end;

procedure TAoWHSMap.BeginStructureUpdate;
begin end;

procedure TAoWHSMap.EndStructureUpdate;
begin end;

procedure TAoWHSMap.StructureChanged;
begin end;

procedure TAoWHSMap.StructureDestroyed;
begin end;

procedure TAoWHSMap.TriggerCombatEvent;
begin end;

procedure TAoWHSMap.TriggerGameTerminatedEvent;
begin end;

procedure TAoWHSMap.ExecuteExitGame;
begin end;

procedure TAoWHSMap.ExitGame(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.TriggerEndTurnEvent(A1: Byte);
begin end;

procedure TAoWHSMap.ClearExecuteEventLogBuffer;
begin end;

procedure TAoWHSMap.ExecuteNextEventLog;
begin end;

procedure TAoWHSMap.SetExecuteEventLogDelay(A1: Integer);
begin end;

procedure TAoWHSMap.UpdateExecuteEventLogDelay;
begin end;

procedure TAoWHSMap.ExecuteEventLogDone(A1: Integer);
begin end;

procedure TAoWHSMap.LockExecuteEventLog;
begin end;

procedure TAoWHSMap.UnlockExecuteEventLog;
begin end;

procedure TAoWHSMap.TriggerExecuteEventLog(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.TriggerPlayerTerminatedEvent;
begin end;

procedure TAoWHSMap.GameOverEventHandled;
begin end;

procedure TAoWHSMap.ExecuteGameOverEvent(A1: Integer);
begin end;

procedure TAoWHSMap.UnlockGameOverEvent;
begin end;

procedure TAoWHSMap.LockGameOverEvent;
begin end;

procedure TAoWHSMap.GameOver(A1: Byte; A2: Integer);
begin end;

procedure TAoWHSMap.VerifyAddOnPacks;
begin end;

procedure TAoWHSMap.ValidateMap(A1: Integer);
begin end;

procedure TAoWHSMap.OnStreamError(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.NotifyProgress(const Progress: HSEngine.TMapProgress);
begin end;

procedure TAoWHSMap.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWHSMap.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function TAoWHSMap.ClassID: Integer;
begin Result := 0; end;

procedure TAoWHSMap.InitializeMapLevel(A1: Byte);
begin end;

procedure TAoWHSMap.InitializeNewMap;
begin end;

function TAoWHSMap.AddMapLevel: Boolean;
begin Result := False; end;

function TAoWHSMap.CreateNewMap(Settings: HSEngine.TNewHSMapSettings): Boolean;
begin Result := False; end;

procedure TAoWHSMap.NotifyPlayerChangedEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.UpdatePlayerSeen(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TAoWHSMap.NotifyPlayerChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWHSMap.VisibleForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.FoggedForPlayer(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWHSMap.MouseMoved;
begin end;

procedure TAoWHSMap.UpdateCursor;
begin end;

procedure TAoWHSMap.ResetSeatedPlayerView(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.Select(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.PlayerChanged;
begin end;

procedure TAoWHSMap.TokenControlActivatedEvent;
begin end;

procedure TAoWHSMap.NewFrame;
begin end;

procedure TAoWHSMap.StartNewMap;
begin end;

procedure TAoWHSMap.StartLoadedMap;
begin end;

procedure TAoWHSMap.SetupPlayerControl(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.Activate;
begin end;

procedure TAoWHSMap.ActivateMsg;
begin end;

procedure TAoWHSMap.Random(A1: Integer);
begin end;

procedure TAoWHSMap.GenerateNewTurnOrder;
begin end;

procedure TAoWHSMap.EndTurn;
begin end;

procedure TAoWHSMap.CancelEndTurn;
begin end;

procedure TAoWHSMap.LockUpdateVisibility;
begin end;

procedure TAoWHSMap.UnLockUpdateVisibility;
begin end;

procedure TAoWHSMap.UpdateVisibility;
begin end;

procedure TAoWHSMap.ResetMapLevels;
begin end;

procedure TAoWHSMap.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWHSMap.SendMsg(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAoWHSMap.ExecuteNegotiateMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.InitializeCombatMap(A1: Integer; A2: Integer);
begin end;

procedure TAoWHSMap.ReleaseCombatMap;
begin end;

procedure TAoWHSMap.CreateCombat(A1: Integer);
begin end;

procedure TAoWHSMap.ShowSeatedPlayerCallBack;
begin end;

procedure TAoWHSMap.DestroyCombat;
begin end;

procedure TAoWHSMap.DrawDynamicScene(var SD: GFXE.TSurfaceDesc);
begin end;

procedure TAoWHSMap.RetrieveBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.TriggerRelationsChanged;
begin end;

procedure TAoWHSMap.LockRelationsChanged;
begin end;

procedure TAoWHSMap.UnlockRelationsChanged;
begin end;

procedure TAoWHSMap.UpdateTurnTimeBeep;
begin end;

procedure TAoWHSMap.ResetTurnTimer;
begin end;

procedure TAoWHSMap.GetTurnTimeLeft;
begin end;

procedure TAoWHSMap.GetTurnTimerEnabled;
begin end;

procedure TAoWHSMap.EnableTurnTimer;
begin end;

procedure TAoWHSMap.DisableTurnTimer;
begin end;

procedure TAoWHSMap.ZeroTurnTimer;
begin end;

function TAoWHSMap.ChangeTerrain(MO: HSEngine.TMapObject; X, Y, L, Radius, TerrainType: Integer): Integer;
begin Result := 0; end;

function TAoWHSMap.ChangeTerrainEx(MO: HSEngine.TMapObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer;
begin Result := 0; end;

procedure TAoWHSMap.CenterOnLeader(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWHSMap.PlaceTerrain(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.UpdateEffects;
begin end;

procedure TAoWHSMap.AddEffect(A1: Integer);
begin end;

procedure TranslateRStr(A1: Integer; A2: Integer);
begin end;

procedure HitRole(A1: Integer);
begin end;

procedure HitRoleProbability(A1: Integer);
begin end;

procedure DMmaxDCtoDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure DMDCtoDV(A1: Integer; A2: Integer);
begin end;

procedure ExecuteDamageRole(A1: Integer; A2: Integer);
begin end;

procedure DVtoDEV(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure StatisticsToMaxDamage(A1: Integer; A2: Word; A3: Integer; A4: Integer);
begin end;

procedure StatisticsToDV(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure StatisticsToLimitedDV(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

procedure DistributeCombatEvent(A1: Integer; A2: Byte);
begin end;

procedure CreateDamageCA(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure RetrieveDefaultDiplomaticActionMessage(A1: Integer; A2: Byte; A3: Byte);
begin end;

procedure MaximizeMovePointTable(A1: Integer; A2: Integer);
begin end;

procedure CreateArmyMoveTE(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure CreateArmyMoveXYLTE(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure MoveArmyEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure MoveArmy;
begin end;

procedure MoveArmyXYL(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure MoveArmyXYLEx(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

procedure Format(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure FmtTurnsStr(A1: Integer; A2: Integer);
begin end;

procedure FmtTurnsLeftStr(A1: Integer; A2: Integer);
begin end;

procedure FmtDaysStr(A1: Integer; A2: Integer);
begin end;

procedure FmtDaysLeftStr(A1: Integer; A2: Integer);
begin end;

procedure HitPointsToHitPcnt(A1: Integer; A2: Integer);
begin end;

procedure ShowHitPcnt(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure ShowDamageIcon(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure ShowDamageEffects(A1: Word; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure DamageEffectsAnimationFrames(A1: Word; A2: Integer; A3: Integer);
begin end;

procedure StatusToStatusValue(A1: Integer);
begin end;

procedure StatusValueToStatus(A1: Integer);
begin end;

procedure MoraleToMoraleValue(A1: Integer);
begin end;

procedure MoraleValueToMorale(A1: Integer);
begin end;

procedure dAlignmentsToStatus(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure DamageTypesToDamageType(A1: Word; A2: Integer; A3: Integer);
begin end;

procedure dAlignmentToStatus(A1: Integer; A2: Integer);
begin end;

procedure AlsToInt(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure IntToAls(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure Land(A1: Byte);
begin end;

procedure MoveTypesToInt(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure IntToMoveTypes(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure CombatRangeToCombatMode(A1: Byte);
begin end;

procedure PlaceRandomUnits(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

procedure FillWithRandomUnits(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure FillWithRandomUnitIndexes(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TriggerStormDamage(A1: Byte; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure RetrieveStormDamageInfo(A1: Integer; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer);
begin end;

procedure dAlignmentToDiplomaticRelation(A1: Integer; A2: Integer);
begin end;

procedure StatusToDiplomaticRelation(A1: Byte);
begin end;

procedure GetCombatSide(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure AlignmentToIR(A1: Byte);
begin end;

procedure IRtoAlignment(A1: Integer);
begin end;

procedure DiplomaticRelation(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure ValidAttackRelation(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure GetUnitIndexAIPriority(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure UnitsToIndependentRelation(A1: Integer; A2: Byte);
begin end;

procedure DegreesRadToCo(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure Encode(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure SetupBattleFieldInfo(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure StrengthInfoMax(A1: Integer);
begin end;

procedure InvertDamageTypes(A1: Word);
begin end;

procedure ListMovementGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure GetMovepathBattleFieldStrength(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure GetBattleFieldStrengthAdvantage(A1: Integer; A2: Integer; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure IgnitionChance(A1: Integer);
begin end;

procedure CreateEnhancementAbility(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure MeleeDamageTypes(A1: Integer);
begin end;

procedure StrikeDV(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure CreateStrikeCA(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure Register(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure ValidateAoWEngine;
begin end;

