class function TAIPlayerAction.SupportedPhases: TAIPlayerProcessPhases;
begin Result := [appMain]; end;

function TAIPlayerAction.Setup(Control: TAIPlayerControl; Phase: TAIPlayerProcessPhase): Boolean;
begin
  FControl := Control;
  FPhase := Phase;
  Result := Phase in SupportedPhases;
end;

function TAIPlayerAction.Process: Boolean;
begin
  Inc(FProcessCycles);
  Result := False;
end;

function TAIPlayerAction.Activate: Boolean;
begin
  FProcessCycles := 0;
  Result := True;
end;

procedure TAIPlayerAction.Deactivate;
begin end;

function TAIPlayerActionList.GetActions(Index: Integer): TAIPlayerAction;
begin
  Result := TAIPlayerAction(FChildren.List^[Index]);
end;

function TAIPlayerActionList.IndexOf(Action: TAIPlayerAction): Integer;
begin
  Result := FChildren.IndexOf(Action);
end;

constructor TAIPlayerActionManager.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRegisteredClasses := TList.Create;
end;

destructor TAIPlayerActionManager.Destroy;
begin
  FRegisteredClasses.Free;
  inherited Destroy;
end;

function TAIPlayerActionManager.GetCount: Integer;
begin
  Result := FRegisteredClasses.Count;
end;

function TAIPlayerActionManager.GetRegisteredClasses(Index: Integer): TAIPlayerActionClass;
begin
  Result := TAIPlayerActionClass(FRegisteredClasses.List^[Index]);
end;

function CompareAIPlayerActionClasses(Item1, Item2: Pointer): Integer;
begin
  Result := TAIPlayerActionClass(Item2).Priority - TAIPlayerActionClass(Item1).Priority;
end;

procedure TAIPlayerActionManager.RegisterClasses(Classes: array of TAIPlayerActionClass);
var
  I: Integer;
begin
  for I := 0 to High(Classes) do
  begin
    if FRegisteredClasses.IndexOf(Classes[I]) <> -1 then
      raise Exception.Create('AIPlayerAction already Registered');
    FRegisteredClasses.Add(Classes[I]);
  end;
  FRegisteredClasses.Sort(CompareAIPlayerActionClasses);
end;

procedure TAIPlayerActionManager.UnRegisterClasses(Classes: array of TAIPlayerActionClass);
var
  I: Integer;
begin
  for I := 0 to High(Classes) do
    FRegisteredClasses.Remove(Classes[I]);
end;

constructor TAIPlayerControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FActions := TAIPlayerActionList.Create(nil);
  FMoveExecuter := TAIMoveExecuter.Create(nil);
  FProcessCyclesMax := 10;
end;

destructor TAIPlayerControl.Destroy;
begin
  Reset;
  try
    FActions.Free;
    FActions := nil;
  except
  end;
  try
    FMoveExecuter.Free;
    FMoveExecuter := nil;
  except
  end;
  inherited Destroy;
end;

procedure TAIPlayerControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FDefenseStrengthMultiplier, SizeOf(FDefenseStrengthMultiplier), 10);
end;

procedure TAIPlayerControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20010017 then Deactivate;
end;

function TAIPlayerControl.ListAvailableTransporters(Units: TUnitList): Integer;
var
  I: Integer;
  AUnit: TAbstractUnit;
  Group: TUnitUserList;
begin
  Result := 0;
  with FPlayer do
    for I := 0 to FArmies.Count - 1 do
    begin
      AUnit := FArmies.GetArmy(I).Transporter($FF);
      if AUnit <> nil then
      begin
        Group := AUnit.FGroup;
        if (Group = nil) or (Group.ClassID = $21467) then
        begin
          Units.AddUnit(AUnit);
          Inc(Result);
        end;
      end;
    end;
end;

function TAIPlayerControl.UnitIndexToPriority(UnitIndex: Integer): Integer;
begin
  Result := GetUnitIndexAIPriority(UnitIndex, FPlayer.FPlayerIndex, 0);
end;

procedure TAIPlayerControl.Reset;
begin
  FPhase := appNone;
  FActionIndex := -1;
  DeactivateAction;
  FActions.Clear;
end;

procedure TAIPlayerControl.SetupProcessPhase(Phase: TAIPlayerProcessPhase);
var
  I: Integer;
  ActionClass: TAIPlayerActionClass;
  Action: TAIPlayerAction;
begin
  FActions.Clear;
  for I := 0 to AoWHSMap.FAIPlayerActionManager.GetCount - 1 do
  begin
    ActionClass := AoWHSMap.FAIPlayerActionManager.GetRegisteredClasses(I);
    if Phase in ActionClass.SupportedPhases then
    begin
      Action := ActionClass.Create(nil);
      if Action.Setup(Self, Phase) then Action.SetOwner(FActions)
      else Action.Free;
    end;
  end;
  FPhase := Phase;
end;

function TAIPlayerControl.GetProcessCyclesMax: Integer;
begin
  if not FPlayer.FSingleProcessCycle then Result := FProcessCyclesMax
  else Result := 1;
end;

procedure TAIPlayerControl.Activate(Executer: TAIExecuter);
begin
  Reset;
  if AoWHSMap.FDay < 10 then FDefenseStrengthMultiplier := AoWHSMap.FDay * 0.1
  else FDefenseStrengthMultiplier := 1;
  SetupProcessPhase(appMain);
  case FPlayer.FPlayerType of
    ptCPU1: FProcessCyclesMax := 5;
    ptCPU2: FProcessCyclesMax := 7;
    ptCPU3: FProcessCyclesMax := 9;
    ptCPU4: FProcessCyclesMax := 9;
    ptCPU5: FProcessCyclesMax := 9;
    ptIndependent: FProcessCyclesMax := 3;
  end;
end;

procedure TAIPlayerControl.Deactivate;
begin
  Reset;
end;

function TAIPlayerControl.GetRandomGroupBehavior: TGroupBehavior; { Near miss: Self and player register allocation differ after three variants. }
var
  Player: TPlayer;
begin
  Player := FPlayer;
  if FPlayer.FPlayerIndex = 0 then
    Result := IndependentGroupBehaviorTable[AoWHSMap.GetIndependentAIMode, Random(10)]
  else Result := Player2GroupBehaviorTable[Player.FBehavior, Random(10)];
end;

procedure TAIPlayerControl.UpdateSkirmishGroups;
var
  I, J, SkirmishCount, WantedCount, GroupPriority, UnitPriority: Integer;
  Group: TAIGroup;
  AUnit: TAbstractUnit;
  Units: TDoubleItemList;
  Item: TDoubleItem;
begin
  SkirmishCount := 0;
  for I := 0 to FPlayer.FAIGroups.Count - 1 do
    if FPlayer.FAIGroups.GetGroups(I).ClassID = $21466 then Inc(SkirmishCount);
  if AoWHSMap.FDay > 5 then
  begin
    WantedCount := FPlayer.FAIGroups.Count div 6;
    if WantedCount > 4 then WantedCount := 4;
    if (WantedCount = 0) and (AoWHSMap.FDay and $10 = $10) then
      WantedCount := 1;
  end
  else WantedCount := 2;
  if SkirmishCount < WantedCount then
  begin
    Units := TDoubleItemList.Create;
    for I := FPlayer.FAIGroups.Count - 1 downto 0 do
    begin
      Group := FPlayer.FAIGroups.GetGroups(I);
      if (Group.FTargetType <> gtsExecute) and
        (Group.ClassID <> $21459) and (Group.ClassID <> $21466) and
        (Group.ClassID <> $21451) and (Group.ClassID <> $21453) and
        (Group.ClassID <> $21467) then
      begin
        GroupPriority := Group.GetProcessPriority * -10;
        for J := Group.Count - 1 downto 0 do
        begin
          AUnit := Group.GetUnit(J);
          if not (AUnit is THero) then
          begin
            UnitPriority := AUnit.GetMoves;
            if mtFlying in AUnit.GetMoveTypes then Inc(UnitPriority, 15);
            Units.AddAB(Integer(AUnit), UnitPriority + GroupPriority);
          end;
        end;
      end;
    end;
    Units.SortDescendingItemB;
    while (SkirmishCount < WantedCount) and (Units.Count <> 0) do
    begin
      Group := AoWHSMap.FAIGroupManager.CreateGroup(FPlayer.FPlayerIndex, 0, gbSkirmish);
      Item := Units[0];
      Group.AddUnit(TAbstractUnit(Item.A));
      Group.Release;
      Inc(SkirmishCount);
      Units.Delete(0);
    end;
    Units.Free;
  end;
end;

function TAIPlayerControl.ActivateAction(Index: Integer): Boolean;
begin
  DeactivateAction;
  FAction := FActions.GetActions(Index);
  Result := FAction.Activate;
  if not Result then FAction := nil;
end;

procedure TAIPlayerControl.DeactivateAction;
var
  Action: TAIPlayerAction;
begin
  Action := FAction;
  if Action <> nil then
  begin
    Action.Deactivate;
    FAction := nil;
  end;
end;

procedure TAIPlayerControl.ListPeaceWarUnknownPlayers(Peace, War, Unknown: TByteList); { Near miss: status field corrected; relation stack slot differs after three variants. }
var
  I: Integer;
  Relation: TDiplomaticRelation;
begin
  Peace.Clear;
  War.Clear;
  Peace.Add(FPlayer.FPlayerIndex);
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayer.FPlayerIndex then
      if (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
      begin
        Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayer.FPlayerIndex, I);
        if Relation in [drPeace, drAlliance] then Peace.Add(I)
        else if Relation = drWar then War.Add(I)
        else if Relation = drUnknown then
          if FPlayer.GetFirstDaySeen(I) <> -1 then Unknown.Add(I);
      end;
  { Original checks player status at $45; Unknown is not cleared before appending. }
end;

procedure TAIPlayerControl.ListIdealPeaceWarPlayers(Peace, War: TByteList);
var
  I: Integer;
  Players: TDoubleItemList;
  Relation: TDiplomaticRelation;
  Priority: Integer;
  RaceRelation: TStatus;
  Days, MiddlePlayer: Integer;
  Action: TDiplomaticAction;
  Item: TDoubleItem;
begin
  Peace.Clear;
  War.Clear;
  Players := TDoubleItemList.Create;
  Players.AddAB(FPlayer.FPlayerIndex, 999);
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if (I <> FPlayer.FPlayerIndex) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) then
    begin
      Priority := 0;
      Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayer.FPlayerIndex, I);
      RaceRelation := AoWHSMap.FRaces.GetRace(
        AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FPlayerRace).
        GetDefaultRaceRelation(AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace);
      Action := FPlayer.FDiplomaticActions.FindLastAction(daDeclareWar, darNone,
        I, FPlayer.FPlayerIndex, -1);
      if Action <> nil then
      begin
        Days := AoWHSMap.FDay - Action.FDay;
        if Days < 30 then Priority := Days + (Priority - 30);
      end;
      case RaceRelation of
        sHostile, sWary: Inc(Priority, 0);
        sNeutral: Inc(Priority, 10);
        sPolite, sFriendly: Inc(Priority, 20);
      end;
      if Relation = drAlliance then Inc(Priority, 50)
      else if Relation = drPeace then Inc(Priority, 15);
      if (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) and
        (FPlayer.FPlayerType in [ptCPU3, ptCPU4, ptCPU5]) then Dec(Priority, 5);
      Players.AddAB(I, Priority);
    end;
  Players.SortDescendingItemB;
  for I := 0 to Players.Count div 2 - 1 do
  begin
    Item := Players[I];
    Peace.Add(Item.A);
  end;
  for I := Players.Count - 1 downto (Players.Count + 1) div 2 do
  begin
    Item := Players[I];
    War.Add(Item.A);
  end;
  if Odd(Players.Count) then
  begin
    Item := Players[Players.Count div 2]; MiddlePlayer := Item.A;
    { The middle player relation is evaluated directly below. }


    if AoWHSMap.FRaces.GetRace(AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FPlayerRace).GetDefaultRaceRelation(AoWHSMap.FPlayers.GetPlayers(MiddlePlayer).FPlayerRace) in [sHostile, sWary] then War.Add(MiddlePlayer)
    else Peace.Add(MiddlePlayer);
  end;
  Players.Free;
end;

function TAIPlayerControl.CanOfferPeace(Player: Byte): Boolean; { Original peace exception requires more than two active players. }
var
  Peace, War, Unknown, IdealPeace, IdealWar: TByteList;
  PeaceCount, WarCount, PeaceIndex, WarIndex, Index, I: Integer;
begin
  if not ((FPlayer.FDiplomaticRelations.GetHistory(Shortint(Player)).GetRelationOnDay(0) = drWar) and
    (FPlayer.FDiplomaticRelations.GetDiplomaticRelation(Shortint(Player)) = drWar)) then
  begin
    IdealPeace := TByteList.Create;
    IdealWar := TByteList.Create;
    Peace := TByteList.Create;
    War := TByteList.Create;
    Unknown := TByteList.Create;
    ListPeaceWarUnknownPlayers(Peace, War, Unknown);
    ListIdealPeaceWarPlayers(IdealPeace, IdealWar);
    War.Remove(Player);
    Unknown.Remove(Player);
    Peace.Remove(Player);
    PeaceCount := Peace.Count;
    WarCount := War.Count;
    PeaceIndex := IdealPeace.IndexOf(Player);
    WarIndex := IdealWar.IndexOf(Player);
    for I := 0 to Unknown.Count - 1 do
    begin
      Index := IdealPeace.IndexOf(Unknown[I]);
      if Index <> -1 then
        if (PeaceIndex = -1) or (Index < PeaceIndex) then Inc(PeaceCount)
        else Inc(WarCount);
      Index := IdealWar.IndexOf(Unknown[I]);
      if Index <> -1 then
        if (WarIndex = -1) or (Index < WarIndex) then Inc(WarCount)
        else Inc(PeaceCount);
    end;
    Result := not ((PeaceCount > WarCount) and
      not ((WarCount = 0) and (PeaceCount = 1) and
        (AoWHSMap.FPlayers.FActivePlayers.Count > 2)));

    if FPlayer.FPlayerType in [ptCPU3, ptCPU4, ptCPU5] then
      if AoWHSMap.FRaces.GetRace(
        AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FPlayerRace).
        GetDefaultRaceRelation(AoWHSMap.FPlayers.GetPlayers(Shortint(Player)).FPlayerRace)
        in [sHostile, sWary] then Result := False;
    Peace.Free;
    War.Free;
    Unknown.Free;
    IdealPeace.Free;
    IdealWar.Free;
  end
  else Result := False;
end;

function TAIPlayerControl.CanDeclareWar(Player: Byte): Boolean;
var
  Peace, War, Unknown, IdealPeace, IdealWar: TByteList;
  PeaceCount, WarCount, PeaceIndex, WarIndex, Index, I: Integer;
begin
  if not ((FPlayer.FDiplomaticRelations.GetHistory(Shortint(Player)).GetRelationOnDay(0) = drPeace) and
    (FPlayer.FDiplomaticRelations.GetDiplomaticRelation(Shortint(Player)) = drPeace)) then
  begin
    IdealPeace := TByteList.Create;
    IdealWar := TByteList.Create;
    Peace := TByteList.Create;
    War := TByteList.Create;
    Unknown := TByteList.Create;
    ListPeaceWarUnknownPlayers(Peace, War, Unknown);
    ListIdealPeaceWarPlayers(IdealPeace, IdealWar);
    Peace.Remove(Player);
    Unknown.Remove(Player);
    War.Remove(Player);
    PeaceCount := Peace.Count;
    WarCount := War.Count;
    PeaceIndex := IdealPeace.IndexOf(Player);
    WarIndex := IdealWar.IndexOf(Player);
    for I := 0 to Unknown.Count - 1 do
    begin
      Index := IdealPeace.IndexOf(Unknown[I]);
      if Index <> -1 then
        if (PeaceIndex = -1) or (Index < PeaceIndex) then Inc(PeaceCount)
        else Inc(WarCount);
      Index := IdealWar.IndexOf(Unknown[I]);
      if Index <> -1 then
        if (WarIndex = -1) or (Index < WarIndex) then Inc(WarCount)
        else Inc(PeaceCount);
    end;
    Result := not ((WarCount > PeaceCount) and
      (FPlayer.FDiplomaticRelations.GetHistory(Shortint(Player)).GetRelationOnDay(0) <> drWar));


    Peace.Free;
    War.Free;
    Unknown.Free;
    IdealPeace.Free;
    IdealWar.Free;
  end
  else Result := False;
end;

function TAIPlayerControl.CanProposeAlliance(Player: Byte): Boolean;
begin
  if CanOfferPeace(Player) and
    (FPlayer.FDiplomaticRelations.GetDiplomaticRelation(Shortint(Player)) = drPeace) then
  begin
    Result := AoWHSMap.FDay > 10;
    if AoWHSMap.FDay - FPlayer.FDiplomaticRelations.GetHistory(
      Shortint(Player)).GetLastModifiedOnDay < 8 then Result := False;
    if AoWHSMap.FRaces.GetRace(
      AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FPlayerRace).
      GetDefaultRaceRelation(AoWHSMap.FPlayers.GetPlayers(Shortint(Player)).FPlayerRace)
      in [sHostile, sWary] then Result := False;
  end
  else Result := False;
end;

function TAIPlayerControl.Process(Executer: TAIExecuter; TokenControlDone: Boolean): Boolean;
var
  Done: Boolean;
  I: Integer;
  Action: TAIPlayerAction;
begin
  if not FPlayer.GetBusy and AoWHSMap.FTokenManager.PlayerReady(FPlayer.FPlayerIndex) then
  begin
    case FPhase of
    appMain:
    begin
      Done := False;
      while not Done and (FActions.Count <> 0) and not FPlayer.GetBusy and
        AoWHSMap.FTokenManager.PlayerReady(FPlayer.FPlayerIndex) do
      begin
        if FMoveExecuter.FStatus <> mesBusy then
        { Process queued player actions before continuing movement. }
        begin
          while (FAction = nil) and (FActions.Count <> 0) do
            if not ActivateAction(0) then FActions.GetActions(0).Free;
          if FAction <> nil then
          begin
            Done := FAction.Process;
            if not Done then
            begin
              Action := FAction;
              DeactivateAction;
              Action.Free;
            end;
          end;
        end else Done := FMoveExecuter.Process;
        if not Done and (Executer.GetProcessTimeLeft <= 0) then Done := True;
      end;
      if FActions.Count = 0 then SetupProcessPhase(appLoop);
      Result := not FPlayer.GetBusy and
        AoWHSMap.FTokenManager.PlayerReady(FPlayer.FPlayerIndex);
    end;
    appLoop:
    begin
      Done := False;
      I := 0;
      while not Done and (I < FActions.Count) and not FPlayer.GetBusy and
        AoWHSMap.FTokenManager.PlayerReady(FPlayer.FPlayerIndex) do
      begin
        if FMoveExecuter.FStatus <> mesBusy then
        { Process queued player actions before continuing movement. }
        begin
          while (FAction = nil) and (I <> FActions.Count) do
          begin
            Inc(I);
            Inc(FActionIndex);
            if FActionIndex >= FActions.Count then FActionIndex := 0;
            if FActionIndex < FActions.Count then ActivateAction(FActionIndex);
          end;
          if FAction <> nil then
          begin
            Done := FAction.Process;
            if not Done then DeactivateAction;
          end;
        end else Done := FMoveExecuter.Process;
        if not Done and (Executer.GetProcessTimeLeft <= 0) then Done := True;
      end;
      Result := (FActions.Count <> 0) and not FPlayer.GetBusy and
        AoWHSMap.FTokenManager.PlayerReady(FPlayer.FPlayerIndex);
    end;
    else Result := False;
    end;
  end
  else Result := False;
end;

constructor TAIExecuter.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPlayers := TByteList.Create;
  FPlayer := -1;
  FProcessTimeMode := ptmStatic;
  FProcessTime := 5000;
  FTokenCycles := 5;
end;

destructor TAIExecuter.Destroy;
begin
  FPlayers.Free;
  inherited Destroy;
end;

function TAIExecuter.RequestProcessTime(Time: Integer): Boolean;
var
  Used: Integer;
begin
  case FProcessTimeMode of
    ptmStatic:
    begin
      Used := FProcessTimeUsed;
      if Used <> 0 then Result := Time <= FProcessTime - Used
      else Result := True;
    end;
    ptmDynamic:
      if FProcessTimeUsed <> 0 then Result := Time < GetProcessTimeLeft
      else Result := True;
  else Result := False;
  end;
end;

function TAIExecuter.GetProcessTimeLeft: Integer;
begin
  case FProcessTimeMode of
    ptmStatic: Result := FProcessTime - FProcessTimeUsed;
    { Original behavior: the millisecond delta is multiplied by 1000. }
    ptmDynamic: Result := FProcessTime - (GetElapsedMilliSeconds - FProcessStarted) * 1000;
  else Result := -1;
  end;
end;

function TAIExecuter.GetProcessTimeElapsed: Integer;
begin
  case FProcessTimeMode of
    ptmStatic: Result := FProcessTimeUsed;
    ptmDynamic: Result := (GetElapsedMilliSeconds - FProcessStarted) * 1000;
  else Result := -1;
  end;
end;

procedure TAIExecuter.UseProcessTime(Time: Integer);
begin
  if aesExecuting in FStatus then Inc(FProcessTimeUsed, Time);
end;

function TAIExecuter.ActivatePlayer(Player: Shortint): Boolean;
begin
  if FPlayers.IndexOf(Byte(Player)) = -1 then
  begin
    FPlayers.Add(Byte(Player));
    FStatus := FStatus + [aesEnabled];
    AoWHSMap.FPlayers.GetPlayers(Player).FAIControl.Activate(Self);
    if FPlayer = -1 then FPlayer := Player;
    Result := True;
  end
  else Result := False;
end;

procedure TAIExecuter.DeactivatePlayer(Player: Shortint);
begin
  if FPlayers.IndexOf(Byte(Player)) <> -1 then
  begin
    FPlayers.Remove(Byte(Player));
    AoWHSMap.FPlayers.GetPlayers(Player).FAIControl.Deactivate;
    if FPlayers.Count = 0 then
    begin
      FPlayer := -1;
      FStatus := FStatus - [aesEnabled];
    end;
  end;
end;

procedure TAIExecuter.TokenControlDoneEvent(Sender: TObject);
begin
  if (aesEnabled in FStatus) and (AoWHSMap.FPlayMode = pmSimultaneous) then
  begin
    FTokenControlDone := True;
    if (AoWHSMap.FCurrentPlayer = 0) and (AoWHSMap.FCombatMap = nil) then
      CaptureTokenCycles(5);
  end;
end;

procedure TAIExecuter.Lock;
begin
  Inc(FLockCount);
end;

procedure TAIExecuter.Unlock;
begin














































































































































































































































































  Assert(FLockCount <> 0);
  Dec(FLockCount);
end;

procedure TAIExecuter.CaptureTokenCycles(Cycles: Integer);
begin
  Assert(not (aesTokenLocked in FStatus));
  FStatus := FStatus + [aesTokenLocked];
  AoWHSMap.FTokenManager.TokenExecuter.Lock;
  FTokenCycle := 0;
  FTokenCycles := Cycles;
end;

procedure TAIExecuter.TokenCyclesCaptured;
begin

  Assert(aesTokenLocked in FStatus);
  FStatus := FStatus - [aesTokenLocked];
  AoWHSMap.FTokenManager.TokenExecuter.Unlock;
end;

procedure TAIExecuter.Process;
var
  Done: Boolean;
  I, Index: Integer;
begin
  if (aesEnabled in FStatus) and (FLockCount = 0) then
  begin
    FStatus := FStatus + [aesExecuting];
    AoWHSMap.SynchroniseBegin;
    FProcessTimeUsed := 0;
    if FProcessTimeMode = ptmDynamic then FProcessStarted := GetElapsedMilliSeconds
    else FProcessStarted := 0;
    try
      case AoWHSMap.FPlayMode of
        pmTurn:
          if not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy and
            AoWHSMap.FTokenManager.PlayerReady(FPlayer) then
          begin
            Inc(FProcessCycles);
            AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.Process(Self, FTokenControlDone);
            FTokenControlDone := False;
          end;
        pmSimultaneous:
          if aesTokenLocked in FStatus then
          begin
            Inc(FProcessCycles);
            Done := False;
            I := 0;
            while not Done and (GetProcessTimeLeft > 0) and
              (aesEnabled in FStatus) and (I < FPlayers.Count) do
            begin
              Done := AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.Process(Self, FTokenControlDone);
              if Done then
              begin
                Inc(FPlayerProcessCycles);
                I := 0;
              end
              else Inc(I);
              FTokenControlDone := False;
              if not Done or
                (AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.GetProcessCyclesMax <= FPlayerProcessCycles) then
              begin
                Index := FPlayers.IndexOf(Byte(FPlayer));
                Inc(Index);
                FPlayerProcessCycles := 0;
                { Original behavior: Index = Count is not wrapped here. }
                if Index > FPlayers.Count then Index := 0;
                FPlayer := FPlayers[Index];
              end;
            end;
            Inc(FTokenCycle);
            if (I >= FPlayers.Count) or (FTokenCycle >= FTokenCycles) then TokenCyclesCaptured;
          end;
      end;
    except
      ShowMessage('AI ERROR');
    end;
    AoWHSMap.SynchroniseEnd;
    FStatus := FStatus - [aesExecuting];
  end;
end;

class function TInitializeAIPA.Priority: Integer;
begin Result := 1000; end;

function TInitializeAIPA.Process: Boolean;
begin
  FControl.FPlayer.FAIBudget.UpdateBudgets;
  if FControl.FPlayer.FPlayerIndex <> 0 then FControl.UpdateSkirmishGroups;
  Result := False;
end;

destructor TEndTurnAIPA.Destroy;
begin
  inherited Destroy;
end;

class function TEndTurnAIPA.Priority: Integer;
begin Result := 10; end;

function TEndTurnAIPA.Process: Boolean;
var
  Event: TEndTurnTE;
begin
  if not FControl.FPlayer.FSingleProcessCycle then
  begin
    Event := TEndTurnTE.Create(nil);
    Event.FPlayer := FControl.FPlayer.FPlayerIndex;
    Event.FDay := AoWHSMap.FDay;
    Event.FMode := emEndTurn;
    AoWHSMap.FTokenManager.GetTokenControl(FControl.FPlayer.FPlayerIndex).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

constructor TGroupControlAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

destructor TGroupControlAIPA.Destroy;
begin
  DeactivateGroupControl;
  inherited Destroy;
end;

class function TGroupControlAIPA.Priority: Integer;
begin Result := 20; end;

procedure TGroupControlAIPA.ActivateGroupControl(Group: TAIGroup);
begin
  DeactivateGroupControl;
  FGroupControl := Group.CreateGroupControl;
  FGroupControl.Activate;
end;

procedure TGroupControlAIPA.DeactivateGroupControl; { Near miss: single-use control local is optimized away after three variants. }
var
  Control: TAIGroupControl;
begin
  Control := FGroupControl;
  if Control <> nil then
  begin
    Control.Deactivate;
    FGroupControl.Free;
    FGroupControl := nil;
  end;
end;

function TGroupControlAIPA.Process: Boolean;
var
  Busy, Done: Boolean;
  I: Integer;
  Control: TAIGroupControl;
begin
  Inc(FGroupProcessCycles);
  try
    Busy := False;
    Done := False;
    while not Done and not Busy and (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) do
    begin
      if FGroupControl = nil then
      begin
        FControl.FPlayer.FAIGroups.SortOnProcessPriority;
        I := 0;
        while (I < FControl.FPlayer.FAIGroups.Count) and
          (agsDone in FControl.FPlayer.FAIGroups.GetGroups(I).FStatus) do Inc(I);
        if I < FControl.FPlayer.FAIGroups.Count then
          ActivateGroupControl(FControl.FPlayer.FAIGroups.GetGroups(I))
        else Done := True;
      end;
      Control := FGroupControl;
      if Control <> nil then
      begin
        Busy := Control.Process(False);
        if not Busy then DeactivateGroupControl;
      end
      else Done := True;
    end;
    Result := not Done;
  except
    Result := False;
  end;
end;

constructor TGroupControlLoopAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

destructor TGroupControlLoopAIPA.Destroy;
begin
  DeactivateGroupControl;
  inherited Destroy;
end;

class function TGroupControlLoopAIPA.Priority: Integer;
begin Result := 20; end;

class function TGroupControlLoopAIPA.SupportedPhases: TAIPlayerProcessPhases;
begin Result := [appLoop]; end;

procedure TGroupControlLoopAIPA.ActivateGroupControl(Group: TAIGroup);
begin
  DeactivateGroupControl;
  FGroupControl := Group.CreateGroupControl;
  FGroupControl.Activate;
end;

procedure TGroupControlLoopAIPA.DeactivateGroupControl; { Near miss: single-use control local is optimized away after three variants. }
var
  Control: TAIGroupControl;
begin
  Control := FGroupControl;
  if Control <> nil then
  begin
    Control.Deactivate;
    FGroupControl.Free;
    FGroupControl := nil;
  end;
end;

function TGroupControlLoopAIPA.Activate: Boolean;
var
  I: Integer;
begin
  Result := inherited Activate;
  with FControl.FPlayer do
    for I := FAIGroups.Count - 1 downto 0 do
      FAIGroups.GetGroups(I).FStatus := FAIGroups.GetGroups(I).FStatus - [agsDone];
end;

function TGroupControlLoopAIPA.Process: Boolean;
var
  Busy, Done: Boolean;
  I: Integer;
  Control: TAIGroupControl;
begin
  Inc(FGroupProcessCycles);
  try
    Busy := False;
    Done := False;
    while not Done and not Busy and (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) do
    begin
      if FGroupControl = nil then
      begin
        FControl.FPlayer.FAIGroups.SortOnProcessPriority;
        I := 0;
        while (I < FControl.FPlayer.FAIGroups.Count) and
          (agsDone in FControl.FPlayer.FAIGroups.GetGroups(I).FStatus) do Inc(I);
        if I < FControl.FPlayer.FAIGroups.Count then
          ActivateGroupControl(FControl.FPlayer.FAIGroups.GetGroups(I))
        else Done := True;
      end;
      Control := FGroupControl;
      if Control <> nil then
      begin
        Busy := Control.Process(True);
        if not Busy then DeactivateGroupControl;
      end
      else Done := True;
    end;
    Result := not Done;
  except
    Result := False;
  end;
end;

constructor TAutoProduceAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProductions := TQuadItemList.Create;
end;

destructor TAutoProduceAIPA.Destroy;
begin
  FProductions.Free;
  inherited Destroy;
end;

class function TAutoProduceAIPA.Priority: Integer;
begin Result := 12; end;

function CompareAutoProductions(const Item1, Item2: TQuadItem): Integer;
begin
  Result := Item2.D - Item1.D;
end;

procedure TAutoProduceAIPA.UpdateProductions(Control: TProductionControl);
var
  I, UnitIndex, Priority, Bonus: Integer;
begin
  if Control.FStatus = pcsIdle then
  begin
    Bonus := 0;
    for I := 0 to Control.FUnitProductions.Count - 1 do
      if Control.FUnitProductions.GetItem(I).FResearched then
      begin
        UnitIndex := Control.FUnitProductions.GetItem(I).FUnitIndex;
        if UnitIndex <> -1 then
        begin
          Priority := FControl.UnitIndexToPriority(UnitIndex);
          if Priority <> -1 then
            FProductions.AddABCD(Integer(Control), I, 0, Priority + Bonus);
        end;
      end;
  end;
end;

function TAutoProduceAIPA.ExecuteProduce(Control: TProductionControl; Index: Integer): Boolean;
var
  Gold, Mana, GoldUpkeep, ManaUpkeep: Integer;
begin
  Result := False;
  if (FControl.FPlayer.FProductionControls.IndexOf(Control) <> -1) and
    (Control.FStatus = pcsIdle) then
  begin
    Gold := Control.UnitProductionGold(Index);
    Mana := Control.UnitProductionMana(Index);
    GoldUpkeep := Control.UnitProductionGoldUpkeep(Index);
    ManaUpkeep := Control.UnitProductionManaUpkeep(Index);
    if (GoldUpkeep <= FGoldUpkeep) and (ManaUpkeep <= FManaUpkeep) then
      if FControl.FPlayer.FAIBudget.RequestProductionExpense(Gold, GoldUpkeep, Mana, ManaUpkeep) then
        if Control.ProduceUnitEx(Index, 0, False) then
        begin
          FControl.FPlayer.FAIBudget.ProductionExpenseMade(
            Control.UnitProductionGold(Index), Control.UnitProductionGoldUpkeep(Index),
            Control.UnitProductionMana(Index), Control.UnitProductionManaUpkeep(Index));
          Dec(FGoldUpkeep, GoldUpkeep);
          Dec(FManaUpkeep, ManaUpkeep);
          Result := True;
        end;
  end;
end;

function TAutoProduceAIPA.ExecuteResearch(Control: TProductionControl; Index: Integer): Boolean;
var
  Gold, Mana: Integer;
begin
  Result := False;
  if (FControl.FPlayer.FProductionControls.IndexOf(Control) <> -1) and
    (Control.FStatus = pcsIdle) then
  begin
    { Original behavior: affordability uses production prices for research. }
    Gold := Control.UnitProductionGold(Index);
    Mana := Control.UnitProductionMana(Index);
    if FControl.FPlayer.FAIBudget.RequestProductionExpense(Gold, 0, Mana, 0) then
      if Control.ResearchUnit(Index, False) then
      begin
        FControl.FPlayer.FAIBudget.ExpenseMade(Control.UnitResearchGold(Index),
          Control.UnitResearchMana(Index));
        Result := True;
      end;
  end;
end;

function TAutoProduceAIPA.TransporterPriority(UnitIndex: Integer): Integer;
var
  Resource: TUnitResource;
  AUnit: TUnit;
begin
  Resource := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex);
  if (Resource <> nil) and (Resource.GetTransportCapacity <> 0) then
  begin
    AUnit := TUnit.Create(nil);
    AUnit.SetUnitResource(Resource);
    AUnit.UpdateOffensiveStrength;
    Result := AUnit.FMaxOffensiveStrength;
    AUnit.Release;
    if Result <= 0 then Result := -1;
  end
  else Result := -1;
end;

function TAutoProduceAIPA.ResearchTransporter(Budget: TAIBudget): Boolean;
var
  Candidates: TQuadItemList;
  Structure: TPlayerStructure;
  I, J: Integer;
  X, Y, L: Shortint;
  Player: TPlayer;
  Control: TProductionControl;
  Resource: TUnitResource;
  Priority: Integer;
begin
  Player := FControl.FPlayer;
  if Budget.FGold > 50 then
  begin
    Candidates := TQuadItemList.Create;
    I := Player.FProductionControls.Count;
    while I <> 0 do
    begin
      Dec(I);
      Control := Player.FProductionControls.GetPC(I);
      if Control.FStatus = pcsIdle then
        for J := 0 to Control.FUnitProductions.Count - 1 do
          if (Control.FUnitProductions.GetItem(J).FUnitIndex <> -1) and
            not Control.FUnitProductions.GetItem(J).FResearched then
          begin
            Resource := AoWHSSet.FUnitResources.GetUnitResource(
              Control.FUnitProductions.GetItem(J).FUnitIndex);
            if Resource.GetTransportCapacity <> 0 then
              if Player.FAIBudget.RequestBudgetExpense(
                Control.UnitResearchGold(J),
                Control.UnitResearchMana(J), Budget, False) then
              begin
                Control.GetLocation(X, Y, L);
                Structure := TPlayerStructure(AoWHSMap.MapContainer.GetField(X, Y, L).
                  FindNoneTransparentHS(TPlayerStructure));
                Priority := TransporterPriority(Control.FUnitProductions.GetItem(J).FUnitIndex);
                if Priority <> -1 then
                begin
                  if (Structure <> nil) and (Structure.FProductionPriority > 0) then
                    if Structure.FProductionPriority > 10 then
                      Priority := Priority * 5
                    else Priority := Round(Priority * 0.5 * Structure.FProductionPriority);
                  Candidates.AddABCD(Integer(Control), J, 0, Priority);
                end;
              end;
          end;
    end;
    if Candidates.Count <> 0 then
    begin
      Candidates.Sort(CompareAutoProductions);
      Player.FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
      if ExecuteResearch(TProductionControl(Candidates[0].A), Candidates[0].B) then
      begin
        Budget.FGold := 0;
        Budget.FMana := 0;
        Budget.FRequiredGold := 0;
        Budget.FRequiredMana := 0;
      end
      else Player.FAIBudget.ExpenseMade(Budget.FGold, Budget.FMana);
    end;
    Candidates.Free;
  end;
  { Original behavior: both transporter routines always return False. }
  Result := False;
end;

function TAutoProduceAIPA.ProduceTransporter(Budget: TAIBudget): Boolean;
var
  Candidates: TQuadItemList;
  Structure: TPlayerStructure;
  I, J: Integer;
  X, Y, L: Shortint;
  Player: TPlayer;
  Control: TProductionControl;
  Resource: TUnitResource;
  Priority: Integer;
begin
  Player := FControl.FPlayer;
  if Budget.FGold > 50 then
  begin
    Candidates := TQuadItemList.Create;
    I := Player.FProductionControls.Count;
    while I <> 0 do
    begin
      Dec(I);
      Control := Player.FProductionControls.GetPC(I);
      if Control.FStatus = pcsIdle then
        for J := 0 to Control.FUnitProductions.Count - 1 do
          if (Control.FUnitProductions.GetItem(J).FUnitIndex <> -1) and
            Control.FUnitProductions.GetItem(J).FResearched then
          begin
            Resource := AoWHSSet.FUnitResources.GetUnitResource(
              Control.FUnitProductions.GetItem(J).FUnitIndex);
            if Resource.GetTransportCapacity <> 0 then
              if Player.FAIBudget.RequestBudgetExpense(
                Control.UnitProductionGold(J),
                Control.UnitProductionMana(J), Budget, False) then
                if Player.FAIBudget.RequestProductionExpenseEx(
                  Control.UnitProductionGold(J), Control.UnitProductionGoldUpkeep(J),
                  Control.UnitProductionMana(J), Control.UnitProductionManaUpkeep(J), Budget) then
              begin
                Control.GetLocation(X, Y, L);
                Structure := TPlayerStructure(AoWHSMap.MapContainer.GetField(X, Y, L).
                  FindNoneTransparentHS(TPlayerStructure));
                Priority := TransporterPriority(Control.FUnitProductions.GetItem(J).FUnitIndex);
                if Priority <> -1 then
                begin
                  if (Structure <> nil) and (Structure.FProductionPriority > 0) then
                    if Structure.FProductionPriority > 10 then
                      Inc(Priority, Priority * 5)
                    else Inc(Priority, Round(Priority * 0.5 * Structure.FProductionPriority));
                  Candidates.AddABCD(Integer(Control), J, 0, Priority);
                end;
              end;
          end;
    end;
    if Candidates.Count <> 0 then
    begin
      Candidates.Sort(CompareAutoProductions);
      Player.FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
      if ExecuteProduce(TProductionControl(Candidates[0].A), Candidates[0].B) then
      begin
        Budget.FGold := 0;
        Budget.FMana := 0;
        Budget.FRequiredGold := 0;
        Budget.FRequiredMana := 0;
      end
      else Player.FAIBudget.ExpenseMade(Budget.FGold, Budget.FMana);
    end
    else if not ResearchingTransporter then ResearchTransporter(Budget);
    Candidates.Free;
  end;
  { Original behavior: both transporter routines always return False. }
  Result := False;
end;

function TAutoProduceAIPA.FindAvailableTransporter: TAbstractUnit;
var
  I: Integer;
begin
  with FControl.FPlayer do
  begin
    Result := nil;
    I := FArmies.Count;
    while (I <> 0) and (Result = nil) do
    begin
      Dec(I);
      Result := FArmies.GetArmy(I).Transporter($FF);
      if (Result <> nil) and (Result.FGroupID <> 0) then Result := nil;
    end;
  end;
end;

function TAutoProduceAIPA.TransporterProductionControlExists: Boolean;
var
  Resource: TUnitResource; I, J: Integer;
  Control: TProductionControl;
  { locals follow the original stack order }
begin
  with FControl.FPlayer do
  begin
    Result := False;
    I := FProductionControls.Count;
    while (I <> 0) and not Result do
    begin
      Dec(I);
      Control := FProductionControls.GetPC(I);
      for J := 0 to Control.FUnitProductions.Count - 1 do
        if (Control.FUnitProductions.GetItem(J).FUnitIndex <> -1) and
          Control.FUnitProductions.GetItem(J).FResearched then
        begin
          Resource := AoWHSSet.FUnitResources.GetUnitResource(
            Control.FUnitProductions.GetItem(J).FUnitIndex);
          Result := Result or (Resource.GetTransportCapacity <> 0);
        end;
    end;
  end;
end;

function TAutoProduceAIPA.ProducingTransporter: Boolean;
var
  I: Integer;
  Control: TProductionControl;
begin
  with FControl.FPlayer do
  begin
    Result := False;
    I := FProductionControls.Count;
    while (I <> 0) and not Result do
    begin
      Dec(I);
      Control := FProductionControls.GetPC(I);
      if Control.FStatus = pcsProducing then
        if Control.FQueue.GetItem(0).FProductionID = 1 then
          Result := Control.FSettings.FUnit.GetTransportCapacity <> 0;
    end;
  end;
end;

function TAutoProduceAIPA.ResearchingTransporter: Boolean;
var
  I: Integer;
  Control: TProductionControl;
  Resource: TUnitResource;
begin
  with FControl.FPlayer do
  begin
    Result := False;
    I := FProductionControls.Count;
    while (I <> 0) and not Result do
    begin
      Dec(I);
      Control := FProductionControls.GetPC(I);
      if Control.FStatus = pcsProducing then
        if Control.FQueue.GetItem(0).FProductionID = 2 then
        begin
          Resource := AoWHSSet.FUnitResources.GetUnitResource(
            Control.FUnitProductions.GetItem(Control.FSettings.FUnitProductionIndex).FUnitIndex);
          if Resource <> nil then Result := Resource.GetTransportCapacity <> 0;
        end;
    end;
  end;
end;

function TAutoProduceAIPA.Process: Boolean;
var
  I, Priority: Integer;
  Budget: TAIBudget; Controls: TProductionControlList;
begin
  case FState of
    0:
      with FControl.FPlayer do
      begin
        if FPlayerIndex <> 0 then
        begin
          if (FindAvailableTransporter = nil) and not ProducingTransporter and
            (AoWHSMap.FDay > 5) then
          begin
            Budget := TAIBudget(FAIBudget.FBudgets.FindChild($2029E));
            if Budget = nil then
            begin
              Budget := TAITransporterBudget.Create(nil);
              Budget.SetOwner(FAIBudget.FBudgets);
            end;
            if Budget.FRequiredGold < 100 then Inc(Budget.FRequiredGold, 15);
            ProduceTransporter(Budget);
            if not TransporterProductionControlExists then
            begin
              FAIBudget.ReturnExpense(Budget.FGold, Budget.FMana);
              Budget.FGold := 0;
              Budget.FMana := 0;
              Budget.FRequiredGold := 0;
            end;
          end;
          FGoldUpkeep := FAIBudget.FGoldUpkeep - Round(FIncome * 0.1);
          if FGoldUpkeep < 0 then FGoldUpkeep := 0;
          FManaUpkeep := FAIBudget.FManaUpkeep - Round(FMagicControl.GetManaIncome * 0.1);
          if FManaUpkeep < 0 then FManaUpkeep := 0;
          if (FPlayerIndex <> 0) and
            ((FAIBudget.FGold > 25) or (FAIBudget.FMana > 25)) and
            ((FGoldUpkeep > 0) or (FManaUpkeep > 0)) then
          begin
            FProductionIndex := -1;
            Inc(FState);
          end
          else FState := -1;
        end
        else FState := -1;
      end;
    1:
      while FState = 1 do
      begin
        Inc(FProductionIndex);
        Controls := FControl.FPlayer.FProductionControls; with Controls do
          if FProductionIndex < Count then
            UpdateProductions(TProductionControlList(Integer(Controls) shl 0).GetPC(FProductionIndex))
          else
          begin
            FProductions.Sort(CompareAutoProductions);
            if FProductions.Count <> 0 then Inc(FState)
            else FState := -1;
          end;
      end;
    2:
      while (FState = 2) and not FControl.FPlayer.GetBusy do
      begin
        I := 0;
        Priority := Round(FProductions[0].D * 0.8);
        while (I + 1 < FProductions.Count) and
          (FProductions[I + 1].D >= Priority) do Inc(I);
        I := AoWHSMap.Random(I + 1);
        ExecuteProduce(TProductionControl(FProductions[I].A), FProductions[I].B);
        FProductions.Delete(I);
        if not ((FProductions.Count <> 0) and
          ((FGoldUpkeep > 2) or (FManaUpkeep > 2)) and
          ((FControl.FPlayer.FAIBudget.FGold > 25) or
          (FControl.FPlayer.FAIBudget.FMana > 25))) then FState := -1;
      end;
  end;
  Result := FState <> -1;
end;

constructor TProcessEventlogAIPA.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FLogIndex := -1;
end;

destructor TProcessEventlogAIPA.Destroy;
begin
  inherited Destroy;
end;

class function TProcessEventlogAIPA.Priority: Integer;
begin
  Result := 999;
end;

function TProcessEventlogAIPA.Process: Boolean;
var
  Done: Boolean;
  Log: TEventLog;
begin
  Done := False;
  while not FControl.FPlayer.GetBusy and not Done do
  begin
    if FLogIndex = -1 then
      FLogIndex := FControl.FPlayer.FEventLogbook.FindFirstLogEx($202E3,
        FControl.FPlayer.FPlayerIndex, AoWHSMap.FDay - 1) + 1
    else
      Inc(FLogIndex);
    if FLogIndex < FControl.FPlayer.FEventLogbook.GetCount then
    begin
      Log := FControl.FPlayer.FEventLogbook.GetLogs(FLogIndex);
      if Log is THeroEmergeEventLog then
        THeroEmergeEventLog(Log).ExecuteAI
      else if Log is TDiplomaticActionEventLog then
        TDiplomaticActionEventLog(Log).FAction.ExecuteAI(FControl.FPlayer.FPlayerIndex);
    end
    else
      Done := True;
  end;
  Result := not Done;
end;

class function TAIBudget.ClassID: Integer;
begin
  Result := $2029C;
end;

procedure TAIBudget.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FPriority, $1E);
  Stream.rwInteger(FRequiredGold, $1F);
  Stream.rwInteger(FRequiredMana, $20);
  Stream.rwInteger(FGoldUpkeep, $21);
  Stream.rwInteger(FManaUpkeep, $22);
  Stream.rwInteger(FGold, $23);
  Stream.rwInteger(FMana, $24);
  Stream.rwInteger(FDays, $25);
  Stream.rwInteger(FDayGoldMax, $26);
  Stream.rwInteger(FDayManaMax, $27);
  Stream.rwInteger(FDayGold, $28);
  Stream.rwInteger(FDayMana, $29);
end;

procedure TAIBudget.Done;
begin end;

procedure TAIBudget.OutputDebugInfo;
begin
  AoWEngine.OutputDebugMessage(TMPDID, ClassName + ' Gold:' +
    IntToStr(FGold) + '/' + IntToStr(FRequiredGold) + ' Mana:' +
    IntToStr(FMana) + '/' + IntToStr(FRequiredMana));
end;

procedure TAIBudget.UpdateDayRequirements;
begin
  FDayGold := FRequiredGold - FGold;
  FDayMana := FRequiredMana - FMana;
  if FDays <> 0 then
  begin
    if FDays > 1 then Dec(FDays);
    FDayGold := Round(FDayGold / FDays);
    FDayMana := Round(FDayMana / FDays);
  end
  else
  begin
    if FDayGoldMax < FDayGold then FDayGold := FDayGoldMax;
    if FDayManaMax < FDayMana then FDayMana := FDayManaMax;
  end;
end;

function TAIBudget.GetReady: Boolean;
begin
  Result := (FRequiredGold = FGold) and (FRequiredMana = FMana);
end;

function TAIBudgetList.GetBudgets(Index: Integer): TAIBudget;
begin
  Result := TAIBudget(FChildren.List^[Index]);
end;

constructor TAIBudgetManager.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FBudgets := TAIBudgetList.Create(nil);
  FGoldIncomeFactor := 0.75;
  FManaIncomeFactor := 0.75;
  FGoldReserveFactor := 0.5;
  FManaReserveFactor := 0.5;
end;

destructor TAIBudgetManager.Destroy;
begin
  FBudgets.Free;
  inherited Destroy;
end;

procedure TAIBudgetManager.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FBudgets, $14);
  Stream.rwInteger(FGold, $15);
  Stream.rwInteger(FMana, $16);
  Stream.rwInteger(FGoldUpkeep, $17);
  Stream.rwInteger(FManaUpkeep, $18);
  Stream.rwInteger(FProductionGoldUpkeep, $19);
  Stream.rwInteger(FProductionManaUpkeep, $1A);
end;

function TAIBudgetManager.GetBudgetGoldUpkeep: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FGoldUpkeep);
end;

function TAIBudgetManager.GetBudgetManaUpkeep: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FManaUpkeep);
end;

function TAIBudgetManager.GetReservedBudgetGold: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FGold);
end;

function TAIBudgetManager.GetReservedBudgetMana: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FMana);
end;

function TAIBudgetManager.GetRequiredBudgetDayGold: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FDayGold);
end;

function TAIBudgetManager.GetRequiredBudgetDayMana: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FBudgets.Count - 1 downto 0 do
    Inc(Result, FBudgets.GetBudgets(I).FDayMana);
end;

procedure TAIBudgetManager.UpdateBudgetDayRequirements;
var
  I: Integer;
begin
  for I := FBudgets.Count - 1 downto 0 do
    FBudgets.GetBudgets(I).UpdateDayRequirements;
end;

procedure TAIBudgetManager.UpdateProductionUpkeep;
var
  Control: TProductionControl;
  I: Integer;
begin
  with FPlayer do
  begin
    FProductionManaUpkeep := 0;
    FProductionGoldUpkeep := 0;
    for I := FProductionControls.Count - 1 downto 0 do
    begin
      Control := FProductionControls.GetPC(I);
      if (Control.FStatus = pcsProducing) and
        (Control.FQueue.GetItem(0).FProductionID = 1) and
        (Control.FSettings.FUnit <> nil) then
      begin
        Inc(FProductionGoldUpkeep, Control.FSettings.FGoldUpkeep);
        Inc(FProductionManaUpkeep, Control.FSettings.FManaUpkeep);
      end;
    end;
  end;
end;

function TAIBudgetManager.GetGroupsGoldBudget: Integer;
var
  I: Integer;
begin
  with FPlayer do
  begin
    Result := 0;
    for I := FAIGroups.Count - 1 downto 0 do
      Inc(Result, FAIGroups.GetGroups(I).GetGoldBudget);
  end;
end;

function TAIBudgetManager.GetGroupsManaBudget: Integer;
var
  I: Integer;
begin
  with FPlayer do
  begin
    Result := 0;
    for I := FAIGroups.Count - 1 downto 0 do
      Inc(Result, FAIGroups.GetGroups(I).GetManaBudget);
  end;
end;

procedure TAIBudgetManager.ReserveForBudgets(Gold, Mana: Integer);
var
  I, M, G, TotalGold, TotalMana, GoldLeft, ManaLeft: Integer;
begin
  GoldLeft := Gold;
  ManaLeft := Mana;
  TotalGold := GetRequiredBudgetDayGold;
  TotalMana := GetRequiredBudgetDayMana;
  I := FBudgets.Count;
  while (I <> 0) and ((GoldLeft > 0) or (ManaLeft > 0)) do
  begin
    Dec(I);
    if TotalGold <> 0 then
    begin
      G := Round(FBudgets.GetBudgets(I).FDayGold * Gold / TotalGold);
      if G > FBudgets.GetBudgets(I).FDayGold then G := FBudgets.GetBudgets(I).FDayGold;
      if G > GoldLeft then G := GoldLeft;
    end
    else G := 0;
    if TotalMana <> 0 then
    begin
      M := Round(FBudgets.GetBudgets(I).FDayMana * Mana / TotalMana);
      if M > FBudgets.GetBudgets(I).FDayMana then M := FBudgets.GetBudgets(I).FDayMana;
      if M > ManaLeft then M := ManaLeft;
    end
    else M := 0;
    with FBudgets.GetBudgets(I) do
    begin
      Inc(FGold, G);
      Inc(FMana, M);
      Dec(FDayGold, G);
      Dec(FDayMana, M);
    end;
    Dec(GoldLeft, G);
    Dec(ManaLeft, M);
  end;
end;

procedure TAIBudgetManager.ReturnFromBudgets(Gold, Mana: Integer);
var
  I, G, M, TotalGold, TotalMana, GoldLeft, ManaLeft: Integer;
begin
  GoldLeft := Gold;
  ManaLeft := Mana;
  TotalGold := GetReservedBudgetGold;
  TotalMana := GetReservedBudgetMana;
  I := FBudgets.Count;
  while (I <> 0) and ((GoldLeft > 0) or (ManaLeft > 0)) do
  begin
    Dec(I);
    if (TotalGold <> 0) and (GoldLeft > 0) then
    begin
      G := Round(FBudgets.GetBudgets(I).FGold * Gold / TotalGold) + 1;
      if G > FBudgets.GetBudgets(I).FGold then G := FBudgets.GetBudgets(I).FGold;
      if G > GoldLeft then G := GoldLeft;
    end
    else G := 0;
    if (TotalMana <> 0) and (ManaLeft > 0) then
    begin
      { Original bug: mana returns are weighted by reserved gold. }
      M := Round(FBudgets.GetBudgets(I).FGold * Mana / TotalMana) + 1;
      if M > FBudgets.GetBudgets(I).FMana then M := FBudgets.GetBudgets(I).FMana;
      if M > ManaLeft then M := ManaLeft;
    end
    else M := 0;
    with FBudgets.GetBudgets(I) do
    begin
      Dec(FGold, G);
      Dec(FMana, M);
    end;
    Dec(GoldLeft, G);
    Dec(ManaLeft, M);
  end;
end;

procedure TAIBudgetManager.ValidateReservations;
var
  Gold, Mana: Integer;
begin
  Gold := GetReservedBudgetGold - FPlayer.FGems;
  Mana := GetReservedBudgetMana - FPlayer.FMagicControl.FMana;
  if Gold < 0 then Gold := 0;
  if Mana < 0 then Mana := 0;
  if (Gold > 0) or (Mana > 0) then
  begin
    AoWEngine.OutputDebugMessage(TMPDID, 'RETURNING FROM BUDGETS (GOLD:' +
      IntToStr(Gold) + '/MANA:' + IntToStr(Mana) + ')');
    ReturnFromBudgets(Gold, Mana);
  end;
end;

procedure TAIBudgetManager.OutputDebugInfo;
var
  I: Integer;
begin
  for I := 0 to FBudgets.Count - 1 do
    FBudgets.GetBudgets(I).OutputDebugInfo;
  AoWEngine.OutputDebugMessage(TMPDID, 'GROUPS BUDGET (GOLD:' +
    IntToStr(GetGroupsGoldBudget) + '/MANA:' + IntToStr(GetGroupsManaBudget) + ')');
  AoWEngine.OutputDebugMessage(TMPDID, 'POOL (GOLD:' +
    IntToStr(FGold) + '/MANA:' + IntToStr(FMana) + ')');
  AoWEngine.OutputDebugMessage(TMPDID, 'REAL (GOLD:' +
    IntToStr(FPlayer.FGems) + '/MANA:' + IntToStr(FPlayer.FMagicControl.FMana) + ')');
end;

procedure TAIBudgetManager.ValidateManaUpkeep;
begin
  if FManaUpkeep < 0 then
    FPlayer.FMagicControl.AIOverrideUpkeep($FFFFFF, Abs(FManaUpkeep));
end;

procedure TAIBudgetManager.UpdateBudgets;
var
  RequiredGold, RequiredMana, Gold, Mana, GoldUpkeep, ManaUpkeep, ReserveGold, ReserveMana: Integer;
begin
  ValidateReservations;
  UpdateProductionUpkeep;
  UpdateBudgetDayRequirements;
  Gold := FPlayer.FGems - GetReservedBudgetGold - GetGroupsGoldBudget;
  Mana := FPlayer.FMagicControl.FMana - GetReservedBudgetMana - GetGroupsManaBudget;
  GoldUpkeep := FPlayer.GetUpkeep + FProductionGoldUpkeep + GetBudgetGoldUpkeep;
  ManaUpkeep := FPlayer.FMagicControl.GetManaUpkeep + FProductionManaUpkeep + GetBudgetManaUpkeep;
  FGoldUpkeep := Round(FPlayer.FIncome * FGoldIncomeFactor) - GoldUpkeep;
  FManaUpkeep := Round(FPlayer.FMagicControl.GetManaIncome * FManaIncomeFactor) - ManaUpkeep;
  if FManaUpkeep < 0 then ValidateManaUpkeep;
  RequiredGold := GetRequiredBudgetDayGold;
  RequiredMana := GetRequiredBudgetDayMana;
  ReserveGold := Round(Gold * FGoldReserveFactor);
  ReserveMana := Round(Mana * FManaReserveFactor);
  if ReserveGold > RequiredGold then ReserveGold := RequiredGold;
  if ReserveMana > RequiredMana then ReserveMana := RequiredMana;
  ReserveForBudgets(ReserveGold, ReserveMana);
  FGold := Gold - ReserveGold;
  FMana := Mana - ReserveMana;
end;

function TAIBudgetManager.RequestProductionExpense(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer): Boolean;
begin
  Result := ((Gold = 0) or (Gold <= FGold)) and
    ((Mana = 0) or (Mana <= FMana)) and
    ((GoldUpkeep = 0) or (GoldUpkeep <= FGoldUpkeep)) and
    ((ManaUpkeep = 0) or (ManaUpkeep <= FManaUpkeep));
end;

function TAIBudgetManager.RequestProductionExpenseEx(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer; Budget: TAIBudget): Boolean;
var
  G, M: Integer;
begin
  G := FGold;
  M := FMana;
  if Budget <> nil then
  begin
    Inc(G, Budget.FGold);
    Inc(M, Budget.FMana);
  end;
  Result := ((Gold = 0) or (G >= Gold)) and
    ((Mana = 0) or (Mana <= M)) and
    ((GoldUpkeep = 0) or (FGoldUpkeep >= GoldUpkeep)) and
    ((ManaUpkeep = 0) or (FManaUpkeep >= ManaUpkeep));
end;

function TAIBudgetManager.ProductionExpenseMade(Gold, GoldUpkeep, Mana, ManaUpkeep: Integer): Boolean;
begin
  if RequestProductionExpense(Gold, GoldUpkeep, Mana, ManaUpkeep) then
  begin
    if Gold < 0 then Gold := 0;
    if Mana < 0 then Mana := 0;
    if ManaUpkeep < 0 then ManaUpkeep := 0;
    if GoldUpkeep < 0 then GoldUpkeep := 0;
    Dec(FGold, Gold);
    Dec(FMana, Mana);
    Dec(FGoldUpkeep, GoldUpkeep);
    Dec(FManaUpkeep, ManaUpkeep);
    Inc(FProductionGoldUpkeep, GoldUpkeep);
    Inc(FProductionManaUpkeep, ManaUpkeep);
    Result := True;
  end
  else Result := False;
end;

function TAIBudgetManager.RequestBudgetExpense(Gold, Mana: Integer; Budget: TAIBudget; UsePool: Boolean): Boolean;
var
  G, M: Integer;
begin
  G := 0;
  M := 0;
  if Budget <> nil then
  begin
    Inc(G, Budget.FGold);
    Inc(M, Budget.FMana);
  end;
  if UsePool then
  begin
    Inc(G, FGold);
    Inc(M, FMana);
  end;
  Result := ((Gold = 0) or (Gold <= G)) and
    ((Mana = 0) or (Mana <= M));
end;

function TAIBudgetManager.BudgetExpenseMade(Gold, Mana: Integer; Budget: TAIBudget; Mode: TBudgetExpenseMode): Boolean;
begin
  if RequestBudgetExpense(Gold, Mana, Budget, Mode <> bemBudget) then
  begin
    if Gold < 0 then Gold := 0;
    if Mana < 0 then Mana := 0;
    if Mode = bemPoolThenBudget then
    begin
      if Gold < FGold then
      begin
        Dec(FGold, Gold);
        Gold := 0;
      end
      else
      begin
        Dec(Gold, FGold);
        FGold := 0;
      end;
      if Mana < FMana then
      begin
        Dec(FMana, Mana);
        Mana := 0;
      end
      else
      begin
        Dec(Mana, FMana);
        FMana := 0;
      end;
    end;
    if Budget <> nil then
    begin
      if Gold < Budget.FGold then
      begin
        Dec(Budget.FGold, Gold);
        Gold := 0;
      end
      else
      begin
        Dec(Gold, Budget.FGold);
        Budget.FGold := 0;
      end;
      if Mana < Budget.FMana then
      begin
        Dec(Budget.FMana, Mana);
        Mana := 0;
      end
      else
      begin
        Dec(Mana, Budget.FMana);
        Budget.FMana := 0;
      end;
    end;
    if Mode = bemBudgetThenPool then
    begin
      if Gold < FGold then Dec(FGold, Gold)
      else FGold := 0;
      if Mana < FMana then Dec(FMana, Mana)
      else FMana := 0;
    end;
    Result := True;
  end
  else Result := False;
end;

function TAIBudgetManager.RequestBudgetExpenseEx(Gold, Mana, GoldUpkeep, ManaUpkeep: Integer; Budget: TAIBudget; UsePool: Boolean): Boolean;
begin
  if Gold < 0 then Gold := 0;
  if Mana < 0 then Mana := 0;
  if ManaUpkeep < 0 then ManaUpkeep := 0;
  if GoldUpkeep < 0 then GoldUpkeep := 0;
  Result := RequestBudgetExpense(Gold, Mana, Budget, UsePool) and
    ((GoldUpkeep = 0) or (GoldUpkeep <= FGoldUpkeep)) and
    ((ManaUpkeep = 0) or (ManaUpkeep <= FManaUpkeep));
end;

function TAIBudgetManager.BudgetExpenseMadeEx(Gold, Mana, GoldUpkeep, ManaUpkeep: Integer; Budget: TAIBudget; Mode: TBudgetExpenseMode): Boolean;
begin
  if RequestBudgetExpenseEx(Gold, Mana, GoldUpkeep, ManaUpkeep, Budget, Mode <> bemBudget) then
  begin
    if Gold < 0 then Gold := 0;
    if Mana < 0 then Mana := 0;
    if ManaUpkeep < 0 then ManaUpkeep := 0;
    if GoldUpkeep < 0 then GoldUpkeep := 0;
    Result := BudgetExpenseMade(Gold, Mana, Budget, Mode);
    Dec(FGoldUpkeep, GoldUpkeep);
    Dec(FManaUpkeep, ManaUpkeep);
  end
  else Result := False;
end;

function TAIBudgetManager.RequestExpense(Gold, Mana: Integer): Boolean;
begin
  Result := (Gold >= 0) and (Mana >= 0) and (Gold <= FGold) and (Mana <= FMana);
end;

function TAIBudgetManager.ExpenseMade(Gold, Mana: Integer): Boolean;
begin
  if RequestExpense(Gold, Mana) then
  begin
    if Gold < 0 then Gold := 0;
    if Mana < 0 then Mana := 0;
    Dec(FGold, Gold);
    Dec(FMana, Mana);
    Result := True;
  end
  else Result := False;
end;

function TAIBudgetManager.ReturnExpense(Gold, Mana: Integer): Boolean;
begin
  if Gold < 0 then Gold := 0;
  if Mana < 0 then Mana := 0;
  Inc(FGold, Gold);
  Inc(FMana, Mana);
  Result := True;
end;

procedure TAIBudgetManager.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (FPlayer.FPlayerType <> ptHuman) and (Msg.MsgID = $20000008) then
  begin
    FDefaultBudget := TAIBudget(FBudgets.FindChild($2029D));
    if FDefaultBudget = nil then
    begin
      FDefaultBudget := TAISavingsBudget.Create(nil);
      FDefaultBudget.SetOwner(FBudgets);
    end;
  end;
end;

constructor TAISavingsBudget.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FRequiredGold := 150;
  FRequiredMana := 150;
  FDayGoldMax := 25;
  FDayManaMax := 15;
end;

class function TAISavingsBudget.ClassID: Integer;
begin Result := $2029D; end;

constructor TAITransporterBudget.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FDayGoldMax := 15;
end;

class function TAITransporterBudget.ClassID: Integer;
begin Result := $2029E; end;

constructor TBudgetManagerAIPA.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); end;

destructor TBudgetManagerAIPA.Destroy;
begin inherited Destroy; end;

class function TBudgetManagerAIPA.Priority: Integer;
begin Result := 25; end;

function TBudgetManagerAIPA.Process: Boolean;
begin Result := False; end;

