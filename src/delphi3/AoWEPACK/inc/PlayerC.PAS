constructor TPlayerControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FDisconnectedPlayers := TDoubleItemList.Create;
end;

destructor TPlayerControl.Destroy;
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FTokenManager <> nil) then
    with AoWHSMap.FTokenManager.TokenExecuter do
    begin
      OnGetSyncValue := nil;
      OnSyncError := nil;
    end;
  FDisconnectedPlayers.Free;
  inherited Destroy;
end;

procedure TPlayerControl.Setup;
var
  I: Integer;
  PCC: TLocalPCC;
begin
  if (AoWHSMap.FConnectionType = pcNetwork) and not (msEditting in AoWHSMap.Status) then
  begin
    if AoWHSMap.FPlayerCommunicator.PCC = nil then
      raise Exception.Create('Please setup DirectPlayPCC');
    with AoWHSMap.FTokenManager.TokenExecuter do
    begin
      OnGetSyncValue := Self.GetSyncValue;
      OnSyncError := OutOfSync;
    end;
  end
  else if ((msEditting in AoWHSMap.Status) or (AoWHSMap.FConnectionType in [pcLocal, pcEmail])) and
    (AoWHSMap.FPlayerCommunicator.PCC = nil) then
  begin
    PCC := TLocalPCC.Create;
    PCC.Setup(AoWHSMap.FPlayers.Count);
    for I := 0 to AoWHSMap.FPlayers.Count - 1 do
      if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman then
        PCC.SetConnectionMode(I, cmLocal)
      else PCC.SetConnectionMode(I, cmGlobal);
    AoWHSMap.FPlayerCommunicator.ActivatePCC(PCC);
    PCC.Release;
    AoWHSMap.FPlayers.Update;
  end;
end;

procedure TPlayerControl.GetSyncValue(var Value: Integer);
begin
  Value := AoWHSMap.FDefendersSeed;
end;

procedure TPlayerControl.OutOfSync(Sender: TObject);
var
  Log: TPlayerConnectionEventLog;
begin
  if AoWHSMap.FTokenManager.TokenExecuter.ActiveTC.Active then
    if not FOutOfSyncShown then
    begin
      Log := TPlayerConnectionEventLog.Create(nil);
      Log.Setup(-1, 3);
      AoWHSMap.TriggerExecuteEventLog(Log, AoWHSMap.FCombat <> nil, nil);
      Log.Release;
      FOutOfSyncShown := True;
    end
    else AoWHSMap.FTokenManager.TokenExecuter.Lock;
end;

procedure TPlayerControl.NewFrame;
begin
  ValidateTurnTiming;
  ValidateDisconnectedPlayers;
end;

procedure TPlayerControl.NewDay;
var
  Msg: TEMsg;
  Log: TTextEventLog;
  MessageLog: TMessageEventLog;
  I: Integer;
begin
  Inc(AoWHSMap.FDay);
  AoWHSMap.FPlayers.BeginUpdate;
  AoWHSMap.LockRelationsChanged;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Log := TNewDayEventLog.Create(nil);
    Log.FText := Format(TranslateRStr(NewDayRStr), [AoWHSMap.FDay]);
    if (AoWHSMap.FDayLimit <> 0) and (AoWHSMap.FDayLimit - AoWHSMap.FDay <= 10) then
      Log.FText := Log.FText + ' (' + FmtDaysLeftStr(AoWHSMap.FDayLimit - AoWHSMap.FDay) + ')';
    Log.FPlayer := I;
    AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
    Log.Release;
  end;
  if AoWHSMap.FTurnOrderMode = toChanging then AoWHSMap.GenerateNewTurnOrder;
  if AoWHSMap.FDay = 1 then
  begin
    AoWHSMap.FRaces.ResetPlayerRelations;
    if AoWHSMap.FConnectionType = pcLocal then
    begin
      Randomize;
      AoWHSMap.FInitialRandomSeed := RandSeed;
    end;
    AoWHSMap.FDefendersSeed := AoWHSMap.FInitialRandomSeed;
  end;
  try
    InitMsg(Msg, $20020001, Self);
    AoWHSMap.SendMsg(Msg, Self);
  except
  end;
  try
    AoWHSMap.FNewDayEvents.TriggerNotifyEvents(Self);
  except
  end;
  if AoWHSMap.FDayLimit = AoWHSMap.FDay then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FTitle := TranslateRStr(InfoRStr);
    MessageLog.FButtons := mebOk;
    MessageLog.FLayout := melNormal;
    MessageLog.FMessage.Text := TranslateRStr(TurnLimitReachedRStr);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, nil);
    MessageLog.Release;
    AoWHSMap.GameOver(AoWHSMap.FSeatedPlayer, goLost);
    for I := 1 to AoWHSMap.FPlayers.Count - 1 do AoWHSMap.GameOver(I, goLost);
  end;
  AoWHSMap.UnlockRelationsChanged;
  AoWHSMap.TriggerRelationsChanged;
  AoWHSMap.FPlayers.EndUpdate;
end;

procedure TPlayerControl.AutoSave;
var
  FileName: string;
begin
  if AoWHSMap.FGameType = gtCampaign then
    try
      FileName := 'autosave.acg';
      AoWEngine.SaveCampaign(AoWEngine.StartupDirectory + 'Save\' + FileName);
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [FileName]));
    end
  else
    try
      FileName := 'autosave.asg';
      AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'Save\' + FileName, nil);
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [FileName]));
    end;
end;

procedure TPlayerControl.EndTurn(Player: Shortint);
var
  Msg: TEMsg;
  X, Y, L: Integer;
  P: TPlayer;
begin
  AoWHSMap.LockRelationsChanged;
  if Player = AoWHSMap.FSeatedPlayer then
  begin
    P := AoWHSMap.FPlayers.GetPlayers(Player);
    P.SetEndTurn(True);
    if P <> nil then
    begin
      AoWHSMap.GetViewCenter(X, Y, L);
      P.FViewX := X; P.FViewY := Y; P.FViewL := L;
    end;
  end;
  InitMsg(Msg, $20020007, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.UnlockRelationsChanged;
  AoWHSMap.TriggerRelationsChanged;
end;

procedure TPlayerControl.NewTurn(Player: Shortint);
var
  Msg: TEMsg;
begin
  if AoWHSMap.FDay <> 1 then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).SetGems(
      AoWHSMap.FPlayers.GetPlayers(Player).FGems +
      AoWHSMap.FPlayers.GetPlayers(Player).FIncome -
      AoWHSMap.FPlayers.GetPlayers(Player).GetUpkeep);
    if AoWHSMap.FPlayers.GetPlayers(Player).FGems < 0 then
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).SetGems(0);
      Dec(AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue, 5);
      if AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue < -50 then
        AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue := -50;
    end
    else AoWHSMap.FPlayers.GetPlayers(Player).FMoraleValue := 0;
    AoWHSMap.FPlayers.GetPlayers(Player).SetEndTurn(False);
  end;
  Inc(AoWHSMap.FPlayers.GetPlayers(Player).FDay);
  AoWHSMap.LockUpdateVisibility;
  InitMsg(Msg, $20020002, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.FNewTurnEvents.TriggerNotifyEvents(TObject(Integer(Player)));
  InitMsg(Msg, $20020003, Self);
  Msg.Value := Player;
  AoWHSMap.SendMsg(Msg, Self);
  AoWHSMap.UnLockUpdateVisibility;
  if AoWHSMap.FDebugSave then
    try
      if AoWHSMap.FPlayMode = pmSimultaneous then
      begin
        if Player = 0 then
          AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'DEBUG\' + AoWHSMap.FMapName +
            IntToStr(AoWHSMap.FDay) + '_p' + IntToStr(AoWHSMap.FSeatedPlayer) +
            '.asg', nil);
      end
      else
        AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'DEBUG\' + AoWHSMap.FMapName +
          IntToStr(AoWHSMap.FDay) + '-' + IntToStr(Player) + '_p' +
          IntToStr(AoWHSMap.FSeatedPlayer) + '.asg', nil);
    except
    end;
end;

procedure TPlayerControl.StartNewMap;
var
  I: Integer;
begin
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
end;

procedure TPlayerControl.StartLoadedMap;
begin end;

procedure TPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus);
begin
  AoWHSMap.FPlayers.GetPlayers(Player).SetGameOverStatus(Status);
end;

procedure TPlayerControl.GameOver(Player: Shortint; Status: TGameOverStatus);
var
  I: Integer;
begin
  if (AoWHSMap.FPlayers.GetPlayers(Player).FGameOverStatus <> Status) and
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus <> psTerminated) then
  begin
    AoWHSMap.LockGameOverEvent;
    SetPlayerGameOverStatus(Player, Status);
    if Status = goLost then
    begin
      if not AoWHSMap.FAlliedVictory then
      begin
        if AoWHSMap.FPlayers.FActivePlayers.Count = 1 then
          GameOver(AoWHSMap.FPlayers.FActivePlayers[0], goWon);
      end
      else if AoWHSMap.FPlayers.GetActivePlayersAllied then
        for I := 1 to AoWHSMap.FPlayers.Count - 1 do
          if (I <> Player) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
            (AoWHSMap.FPlayers.GetPlayers(I).FGameOverStatus <> goLost) then
            SetPlayerGameOverStatus(I, goWon);
    end
    else if Status = goWon then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if (I <> Player) and (AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying) and
          (AoWHSMap.FPlayers.GetPlayers(I).FGameOverStatus <> goLost) then
          if (AoWHSMap.FPlayers.GetDiplomaticRelation(Player, I) = drAlliance) and
            AoWHSMap.FAlliedVictory then SetPlayerGameOverStatus(I, goWon)
          else SetPlayerGameOverStatus(I, goLost);
    AoWHSMap.UnlockGameOverEvent;
  end;
end;

procedure TPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
end;

procedure TPlayerControl.SetSeatedPlayer(Player: Shortint);
begin
  if Player <> AoWHSMap.FSeatedPlayer then
  begin
    AoWHSMap.FSeatedPlayer := Player;
    AoWHSMap.SeatedPlayerChanged;
    AoWHSMap.ResetSeatedPlayerView;
  end;
end;

function TPlayerControl.LockAI: Boolean;
begin
  Result := (AoWHSMap.FConnectionType = pcLocal) and (AoWHSMap.FRequestCombatType = False) and
    (AoWHSMap.FAILockCount <> 0);
end;

procedure TPlayerControl.ListPlayerInfo(Strings: TStrings);
var
  I, Race: Integer;
  Text: string;
  PCC: TPlayerCommunicationControl;
begin
  PCC := AoWHSMap.FPlayerCommunicator.PCC;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Text := 'Player ' + IntToStr(I);
    Race := AoWHSMap.FPlayers.GetPlayers(I).FPlayerRace;
    if Race <> -1 then Text := Text + '(' + TranslateRStr(RaceNamesPluralRStr[Race]) + ')';
    Text := Text + ' at system ' + IntToStr(PCC.Players[I].SystemID);
    if Strings <> nil then Strings.Add(Text);
    AoWEngine.OutputDebugStr(Text);
  end;
end;

procedure TPlayerControl.ExitSaveGameCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
  begin
    if AoWEngine.FCampaign <> nil then AoWEngine.SaveCampaign(TSaveGameEventLog(Log).FFileName)
    else AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
    AoWHSMap.ExecuteExitGame;
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
  end
  else if Assigned(FExitCallBack) then FExitCallBack(FExitMode, False);
  FExitCallBack := nil;
end;

procedure TPlayerControl.SaveGameOnExitCallBack(Log: TEventLog);
var
  SaveLog: TSaveGameEventLog;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    if ((AoWEngine.FCampaign = nil) and ((AoWHSMap.FileName = '') or
      (CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0))) or
      ((AoWEngine.FCampaign <> nil) and ((AoWEngine.FCampaign.FFileName = '') or
      (CompareText(ExtractFileExt(AoWHSMap.FileName), '.csm') = 0))) then
    begin
      SaveLog := TSaveGameEventLog.Create(nil);
      if AoWHSMap.FileName <> '' then
      begin
        SaveLog.FDefaultName := ExtractFileName(AoWHSMap.FileName);
        if Pos('.', SaveLog.FDefaultName) <> 0 then
          SaveLog.FDefaultName := System.Copy(SaveLog.FDefaultName, 1, Pos('.', SaveLog.FDefaultName) - 1);
      end
      else SaveLog.FDefaultName := AoWHSMap.FMapName;
      SaveLog.FDirectory := AoWEngine.StartupDirectory + 'Save\';
      AoWHSMap.TriggerExecuteEventLog(SaveLog, False, ExitSaveGameCallBack);
      SaveLog.Release;
    end
    else
    begin
      with AoWEngine do
        if FCampaign <> nil then SaveCampaign(FCampaign.FFileName)
        else SaveHSM(AoWHSMap.FileName, nil);
      AoWHSMap.ExecuteExitGame;
      if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
      FExitCallBack := nil;
    end;
  end
  else if TMessageEventLog(Log).FPressedButton = pebNo then
  begin
    AoWHSMap.ExecuteExitGame;
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
    FExitCallBack := nil;
  end
  else if TMessageEventLog(Log).FPressedButton = pebCancel then
  begin
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, False);
    FExitCallBack := nil;
  end;
end;

procedure TPlayerControl.ExitNetworkGameCallBack(Log: TEventLog);
var
  TE: TTerminatePlayerTE;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
    if (AoWHSMap.FPlayMode = pmSimultaneous) or (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
    begin
      TE := TTerminatePlayerTE.Create(nil);
      TE.FPlayer := AoWHSMap.FSeatedPlayer;
      TE.FExitCallBack := FExitCallBack;
      TE.FExitMode := FExitMode;
      AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(TE);
      TE.Release;
    end;
end;

procedure TPlayerControl.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  Log: TMessageEventLog;
begin
  if AoWHSMap.FCombat = nil then
  begin
    if (AoWHSMap.FConnectionType = pcNetwork) and (AoWHSMap.FGameStatus <> gsTerminated) and
      (AoWHSMap.FGameType <> gtTutorial) and (AoWHSMap.FPlayers.FLocalPlayers.Count > 1) then
    begin
      if (AoWHSMap.FPlayMode = pmSimultaneous) or (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
      begin
        FExitMode := Mode;
        FExitCallBack := Done;
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(ConfirmRStr);
        Log.FButtons := mebYesNoCancel;
        Log.FLayout := melNormal;
        Log.FMessage.Add(TranslateRStr(YourAboutToExitAMultiPlayerGameRStr));
        Log.FMessage.Add(TranslateRStr(DoYouWantToContinueExitingRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, ExitNetworkGameCallBack);
        Log.Release;
      end
      else
      begin
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(MessageRStr);
        Log.FButtons := mebOk;
        Log.FLayout := melNormal;
        Log.FMessage.Add(TranslateRStr(PleaseWaitTillItIsYourTurnRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
        Log.Release;
      end;
    end
    else if (msModified in AoWHSMap.Status) and (AoWHSMap.FGameStatus <> gsTerminated) and
      (AoWHSMap.FGameType <> gtTutorial) then
    begin
      if not Assigned(FExitCallBack) then
      begin
        if Mode <> egmReload then
        begin
          FExitMode := Mode;
          FExitCallBack := Done;
          Log := TMessageEventLog.Create(nil);
          Log.FTitle := TranslateRStr(ConfirmRStr);
          Log.FButtons := mebYesNoCancel;
          if (AoWEngine.FCampaign = nil) and (AoWHSMap.FileName <> '') and
            (CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') <> 0) then
          begin
            Log.FLayout := melNormal;
            Log.FMessage.Add(Format(TranslateRStr(SaveGameToXRStr), [ExtractFileName(AoWHSMap.FileName)]));
          end
          else if (AoWEngine.FCampaign <> nil) and (AoWEngine.FCampaign.FFileName <> '') and
            (CompareText(ExtractFileExt(AoWHSMap.FileName), '.csm') <> 0) then
          begin
            { Original tests the map extension when saving a campaign. }
            Log.FLayout := melNormal;
            Log.FMessage.Add(Format(TranslateRStr(SaveGameToXRStr), [ExtractFileName(AoWEngine.FCampaign.FFileName)]));
          end
          else
          begin
            Log.FLayout := melNormal;
            Log.FMessage.Add(TranslateRStr(DoYouWantToSaveThisGameRStr));
          end;
          AoWHSMap.TriggerExecuteEventLog(Log, False, SaveGameOnExitCallBack);
          Log.Release;
        end
        else Done(Mode, True);
      end
      else FExitCallBack(FExitMode, False);
    end
    else AoWHSMap.ExecuteExitGame;
  end
  else if Assigned(Done) then Done(Mode, False);
end;

procedure TPlayerControl.PasswordFailed;
begin
  AoWHSMap.ExecuteExitGame;
end;

procedure TPlayerControl.PasswordValidated;
begin end;

procedure TPlayerControl.PasswordTryAgainCallBack(Log: TEventLog);
var
  PasswordLog: TPasswordEventLog;
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    PasswordLog := TPasswordEventLog.Create(nil);
    AoWHSMap.TriggerExecuteEventLog(PasswordLog, False, ValidatePasswordCallBack);
    PasswordLog.Release;
  end
  else PasswordFailed;
end;

procedure TPlayerControl.ValidatePasswordCallBack(Log: TEventLog);
var
  Password: string;
  MessageLog: TMessageEventLog;
begin
  Password := Encode(TPasswordEventLog(Log).FPassword, 0);
  if (TPasswordEventLog(Log).FPressedButton <> pebOk) or (Password <> FPassword) then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FTitle := TranslateRStr(WarningRStr);
    MessageLog.FButtons := mebYesNo;
    MessageLog.FMessage.Text := TranslateRStr(PasswordFailedRStr);
    MessageLog.FMessage.Add('');
    MessageLog.FMessage.Add(TranslateRStr(DoYouWantToTryAgainRStr));
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, PasswordTryAgainCallBack);
    MessageLog.Release;
  end
  else PasswordValidated;
end;

procedure TPlayerControl.ValidatePassword(const Password: string);
var
  Log: TPasswordEventLog;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then SetSeatedPlayer(-1);
  FPassword := Password;
  Log := TPasswordEventLog.Create(nil);
  AoWHSMap.TriggerExecuteEventLog(Log, False, ValidatePasswordCallBack);
  Log.Release;
end;

procedure TPlayerControl.ValidateTurnTiming;
begin end;

procedure TPlayerControl.ValidateDisconnectedPlayers;
var
  I, Player, Count: Integer;
  Log: TPlayerConnectionEventLog;
begin
  for I := FDisconnectedPlayers.Count - 1 downto 0 do
  begin
    Player := FDisconnectedPlayers[I].A;
    if AoWHSMap.FPlayers.GetPlayers(Player).FGameOverStatus = goNone then
    begin
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FCurrentPlayer) and
        (AoWHSMap.FTokenManager.TokenExecuter.ActiveTC.Count = 0) then
      begin
        Count := FDisconnectedPlayers[I].B;
        if Count > 0 then
        begin
          Dec(Count);
          FDisconnectedPlayers.List^[I].B := Count;
        end;
        if Count = 0 then
        begin
          Log := TPlayerConnectionEventLog.Create(nil);
          Log.Setup(Player, 2);
          AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
          Log.Release;
          FDisconnectedPlayers.Delete(I);
        end;
      end;
    end
    else FDisconnectedPlayers.Delete(I);
  end;
end;

procedure TPlayerControl.PlayerDisconnected(Player: Shortint);
begin
  if FDisconnectedPlayers.IndexOfItemA(Player) = -1 then FDisconnectedPlayers.AddAB(Player, 150);
end;

procedure TPlayerControl.ConnectionLost;
var
  Log: TPlayerConnectionEventLog;
begin
  Log := TPlayerConnectionEventLog.Create(nil);
  Log.Setup(-1, 2);
  AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
  Log.Release;
end;

class function TTurnPlayerControl.ClassID: Integer;
begin Result := $20250; end;

procedure TTurnPlayerControl.Setup;
begin
  inherited Setup;
  AoWHSMap.FTokenManager.TokenExecuter.HoldTC := True;
end;

procedure TTurnPlayerControl.NewDay;
var
  Player: Integer;
begin
  if AoWHSMap.FRequestCombatType then
  begin
    Player := AoWHSMap.FSeatedPlayer;
    AoWHSMap.FSeatedPlayer := -1;
    inherited NewDay;
    AoWHSMap.FSeatedPlayer := Player;
  end
  else inherited NewDay;
end;

procedure TTurnPlayerControl.NewTurn(Player: Shortint);
var
  Log: TNewTurnEventLog;
  BookLog: TShowBookEventLog;
  Spells: TSpellList;
  MagicLog: TPlayerMagicEventLog;
begin
  AoWHSMap.LockMapChangedEvent;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(Player);
  if AoWHSMap.FRequestCombatType then
  begin
    if AoWHSMap.FSeatedPlayer <> -1 then AoWHSMap.SetSeatedPlayer(-1);
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(ItsYourTurnRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, ShowNewTurnCallBack);
      Log.Release;
    end
    else
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [];
      if Player = 0 then Log.FText := TranslateRStr(IndependentsAreMovingRStr)
      else Log.FText := Format(TranslateRStr(PlayerIsMovingRStr), [AoWHSMap.FPlayers.GetPlayers(Player).GetName]);
      AoWHSMap.TriggerExecuteEventLog(Log, True, nil);
      Log.Release;
    end;
  end
  else if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (Player = AoWHSMap.FSeatedPlayer) then
  begin
    if (AoWHSMap.FGameType <> gtTutorial) or (AoWHSMap.FDay <> 1) then
    begin
      AoWHSMap.ResetTurnTimer;
      AoWHSMap.EnableTurnTimer;
      AoWHSMap.ResetSeatedPlayerView;
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := Player;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(ItsYourTurnRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
      Log.Release;
      ReplayLogbook;
    end
    else AoWHSMap.FTutorialControl.ShowMessage(50, False, True);
  end;
  inherited NewTurn(Player);
  if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (AoWHSMap.FConnectionType <> pcEmail) and AoWEngine.FRegistry.GetAutoSave then AutoSave;
  AoWHSMap.UnlockMapChangedEvent;
  AoWHSMap.InvalidateMap;
  if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then
  begin
    AoWHSMap.FAIExecuter.ActivatePlayer(Player);
    if Player = 0 then AoWHSMap.ShowMessage(Format(TranslateRStr(AreMovingRStr), [TranslateRStr(IndependentsRStr)]))
    else AoWHSMap.ShowMessage(Format(TranslateRStr(AreMovingRStr),
      [TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace])]));
  end
  else
  begin
    PlaySample('SFX\EVENTS\NEWTURN.WAV');
    if (AoWHSMap.FDay = 1) and (AoWHSMap.FRequestCombatType or (Player = AoWHSMap.FSeatedPlayer)) then
    begin
      if AoWHSMap.FGameType in [gtCustom, gtTutorial] then
          begin
            BookLog := TShowBookEventLog.Create(nil);
            AoWHSMap.TriggerExecuteEventLog(BookLog, False, nil);
            BookLog.Release;
          end;
      if AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FResearchSpellID = 0 then
      begin
        Spells := TSpellList.Create;
        AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.ListResearchSpells(Spells, [stCombat, stUnit, stGlobal]);
        if Spells.GetCount > 0 then
        begin
          MagicLog := TPlayerMagicEventLog.Create(nil);
          MagicLog.FMode := pmemStartResearch;
          AoWHSMap.TriggerExecuteEventLog(MagicLog, False, nil);
          MagicLog.Release;
        end;
        Spells.Free;
      end;
      AoWHSMap.FTutorialControl.ShowMessage(52, False, True);
    end;
  end;
end;

procedure TTurnPlayerControl.ReplayLogbook;
var
  Book: TEventLogbook;
  Index, I: Integer;
begin
  Book := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FEventLogbook;
  Index := Book.FindFirstLogEx($202E3, AoWHSMap.FCurrentPlayer, AoWHSMap.FDay - 1);
  for I := Index + 1 to Book.GetCount - 1 do Book.GetLogs(I).Execute(False, etNewTurn, nil);
end;

procedure TTurnPlayerControl.SetSeatedPlayer(Player: Shortint);
begin
  AoWHSMap.LockMapChangedEvent;
  inherited SetSeatedPlayer(Player);
  AoWHSMap.UnlockMapChangedEvent;
  AoWHSMap.InvalidateMap;
end;

procedure TTurnPlayerControl.ShowNewTurnCallBack(Log: TEventLog);
begin
  SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
  AoWHSMap.ResetTurnTimer;
  AoWHSMap.EnableTurnTimer;
  if AoWHSMap.FCurrentPlayer <> -1 then ReplayLogbook;
end;

procedure TTurnPlayerControl.StartGameCallBack(Log: TEventLog);
begin
  if AoWHSMap.FSeatedPlayer = -1 then SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
  AoWHSMap.EnableTurnTimer;
end;

procedure TTurnPlayerControl.EndTurn(Player: Shortint);
var
  Log: TEndTurnEventLog;
  Index: Integer;
  Found: Boolean;
  NextPlayer: Shortint;
begin
  inherited EndTurn(Player);
  if Player = AoWHSMap.FSeatedPlayer then
  begin
    AoWHSMap.ZeroTurnTimer;
    if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then AoWHSMap.ClearExecuteEventLogBuffer;
    AoWHSMap.Selection.UnselectLocation;
  end;
  if Player = AoWHSMap.FCurrentPlayer then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then AoWHSMap.FAIExecuter.DeactivatePlayer(Player);
    Log := TEndTurnEventLog.Create(nil);
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FEventLogbook.AddEvent(Log);
    Log.Release;
    Index := AoWHSMap.FTurnOrder.IndexOf(AoWHSMap.FCurrentPlayer);
    Found := False;
    while not Found do
    begin
      Inc(Index);
      if Index = AoWHSMap.FTurnOrder.Count then
      begin
        NewDay;
        Index := 0;
      end;
      NextPlayer := AoWHSMap.FTurnOrder[Index];
      Found := AoWHSMap.FPlayers.GetPlayers(NextPlayer).FStatus = psPlaying;
      if not Found then
      begin
        inherited NewTurn(NextPlayer);
        inherited EndTurn(NextPlayer);
      end;
    end;
    if AoWHSMap.FTurnOrder.Count <> 0 then NewTurn(AoWHSMap.FTurnOrder[Index])
    else NewTurn(0);
  end;
end;

procedure TTurnPlayerControl.DefaultStartMap;
begin
  AoWHSMap.FPlayers.Update;
  AoWHSMap.FRequestCombatType := (AoWHSMap.FConnectionType = pcEmail) or
    ((AoWHSMap.FConnectionType = pcLocal) and (AoWHSMap.FPlayers.FLocalHumanPlayers.Count > 1));
  AoWHSMap.FShowIndependentMoves := not AoWHSMap.FRequestCombatType;
end;

procedure TTurnPlayerControl.StartNewMap;
begin
  inherited StartNewMap;
  DefaultStartMap;
  NewDay;
  if not AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
    AoWHSMap.ResetSeatedPlayerView;
  end;
  NewTurn(AoWHSMap.FTurnOrder[1]);
end;

procedure TTurnPlayerControl.StartLoadedMapEx;
var
  Log: TNewTurnEventLog;
begin
  DefaultStartMap;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  if AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.SetSeatedPlayer(-1);
    if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType = ptHuman then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(YourTurnContinuesRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
      Log.Release;
    end
    else
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [];
      if AoWHSMap.FCurrentPlayer = 0 then Log.FText := TranslateRStr(IndependentsAreMovingRStr)
      else Log.FText := Format(TranslateRStr(PlayerIsMovingRStr),
        [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).GetName]);
      AoWHSMap.TriggerExecuteEventLog(Log, True, nil);
      Log.Release;
    end;
  end
  else
  begin
    AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
    AoWHSMap.ResetSeatedPlayerView;
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType = ptHuman) and
      (AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer) then
    begin
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(YourTurnContinuesRStr);
      AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
      Log.Release;
    end;
  end;
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPlayerType <> ptHuman then
    AoWHSMap.FAIExecuter.ActivatePlayer(AoWHSMap.FCurrentPlayer);
  AoWEngine.OutputDebugStr('Random Seed: ' + IntToStr(AoWHSMap.FDefendersSeed));
end;

procedure TTurnPlayerControl.PasswordValidated;
begin StartLoadedMapEx; end;

procedure TTurnPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings)
  else StartLoadedMapEx;
end;

procedure TTurnPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  if AoWHSMap.FRequestCombatType then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
    AoWHSMap.FPlayers.Update;
    AoWHSMap.TriggerPlayerTerminatedEvent(Player);
    if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent
    else EndPlayerTurn(AoWHSMap.FCurrentPlayer);
  end;
end;

procedure TTurnPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus); { Near miss: player/status parameter spill differs after three variants. }
begin
  inherited SetPlayerGameOverStatus(Player, Status);
  if not AoWHSMap.FRequestCombatType or (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
    AoWHSMap.FPlayers.Update;
    AoWHSMap.TriggerPlayerTerminatedEvent(Player);
    if (AoWHSMap.FCurrentPlayer = Player) and AoWHSMap.FPlayers.GetPlayers(Player).GetLocal then
      EndPlayerTurn(AoWHSMap.FCurrentPlayer);
    if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent;
  end;
end;

procedure TTurnPlayerControl.GameOver(Player: Shortint; Status: TGameOverStatus);
begin
  AoWHSMap.LockGameOverEvent;
  inherited GameOver(Player, Status);
  AoWHSMap.UnlockGameOverEvent;
end;

procedure TTurnPlayerControl.ValidateTurnTiming;
begin
  if AoWHSMap.GetTurnTimerEnabled then if AoWHSMap.FCurrentPlayer = AoWHSMap.FSeatedPlayer then
    if AoWHSMap.GetTurnTimeLeft <= 0 then
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone) and
      (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle = False) then
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FSeatedPlayer) then EndPlayerTurn(AoWHSMap.FSeatedPlayer);
end;

class function TPBEMPlayerControl.ClassID: Integer;
begin Result := $20253; end;

procedure TPBEMPlayerControl.TerminateEmailGame;
begin AoWHSMap.ExitGame(egmExit, nil); end;

procedure TPBEMPlayerControl.TerminateEmailGameCallBack(Log: TEventLog);
begin TerminateEmailGame; end;

procedure TPBEMPlayerControl.SendEmailGameAutomatedCallBack(Log: TEventLog);
var
  SendLog: TSendEmailGameEventLog;
begin
  Windows.DeleteFile(PChar(TSMTPEventLog(Log).FFileName));
  if not TSMTPEventLog(Log).FSuccess then
  begin
    SendLog := TSendEmailGameEventLog.Create(nil);
    SendLog.FMode := 1;
    SendLog.FSendPlayer := AoWHSMap.FCurrentPlayer;
    AoWHSMap.TriggerExecuteEventLog(SendLog, False, SendEmailGameCallBack);
    SendLog.Release;
  end
  else TerminateEmailGame;
end;

procedure TPBEMPlayerControl.SendEmailGameManualCallBack(Log: TEventLog);
var
  Failed: Boolean;
  MessageLog: TMessageEventLog;
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ShowMessage(Format(TranslateRStr(GameSavedRStr), [TSaveGameEventLog(Log).FFileName]));
      Failed := False;
    except Failed := True;
    end
  else Failed := True;
  if Failed then
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FMessage.Text := Format(TranslateRStr(CouldNotSaveXRStr) + '.', [TSaveGameEventLog(Log).FFileName]);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
    MessageLog.Release;
  end
  else
  begin
    MessageLog := TMessageEventLog.Create(nil);
    MessageLog.FMessage.Text := Format(TranslateRStr(GameSuccessfullySavedRStr) + '.', [TSaveGameEventLog(Log).FFileName]);
    AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
    MessageLog.Release;
  end;
end;

procedure TPBEMPlayerControl.SendEmailGameCallBack(Log: TEventLog);
var
  SMTPLog: TSMTPEventLog;
  SaveLog: TSaveGameEventLog;
  TempPath: array[0..500] of Char;
  I: Integer;
begin
  case TSendEmailGameEventLog(Log).FMode of
    2: TerminateEmailGame;
    1:
      begin
        SaveLog := TSaveGameEventLog.Create(nil);
        SaveLog.FTitle := TranslateRStr(SaveEmailGameRStr);
        SaveLog.FDefaultName := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName;
        SaveLog.FDirectory := AoWEngine.StartupDirectory + 'EmailOut\';
        AoWHSMap.TriggerExecuteEventLog(SaveLog, False, SendEmailGameManualCallBack);
        SaveLog.Release;
      end;
    0:
      begin
        GetTempPath(SizeOf(TempPath), TempPath);
        SMTPLog := TSMTPEventLog.Create(nil);
        SMTPLog.FSubject := Format(TranslateRStr(AoWEmailGameXRStr),
          [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName]);
        SMTPLog.FFromAddress := AoWEngine.FRegistry.GetLocalEmailAddress;
        SMTPLog.FToAddress := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FEmailAddress;
        SMTPLog.FFileName := TempPath + AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName + '.asg';
        SMTPLog.FMessage.Add(TranslateRStr(AgeOfWondersEmailGameRStr));
        SMTPLog.FMessage.Add('--------------------------------------------------------');
        SMTPLog.FMessage.Add(Format(TranslateRStr(NameXRStr),
          [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName]));
        SMTPLog.FMessage.Add(Format(TranslateRStr(MapXRStr), [AoWHSMap.FMapName]));
        SMTPLog.FMessage.Add(Format(TranslateRStr(TurnXRStr), [IntToStr(AoWHSMap.FDay)]));
        SMTPLog.FMessage.Add('');
        SMTPLog.FMessage.Add(TranslateRStr(PlayersRStr) + ':');
        for I := 1 to AoWHSMap.FPlayers.Count - 1 do
          if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman then
            SMTPLog.FMessage.Add(Format(TranslateRStr(XatYRStr),
              [AoWHSMap.FPlayers.GetPlayers(I).GetName, AoWHSMap.FPlayers.GetPlayers(I).FPBEMSettings.FEmailGame.FEmailAddress]));
        AoWEngine.SaveHSM(SMTPLog.FFileName, nil);
        AoWHSMap.TriggerExecuteEventLog(SMTPLog, False, SendEmailGameAutomatedCallBack);
        SMTPLog.Release;
      end;
  end;
end;

procedure TPBEMPlayerControl.NewTurn(Player: Shortint);
var
  Log: TSendEmailGameEventLog;
begin
  if (pbsNewTurn in AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus) or
    (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) or
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psTerminated) then
  begin
    inherited NewTurn(Player);
    AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus - [pbsNewTurn, pbsTurnDone] + [pbsPlaying];
  end
  else
  begin
    if (AoWHSMap.FPlayers.FLocalPlayers.Count > 1) or (Player <> FLocalPlayer) then
    begin
      AoWHSMap.SetCurrentPlayer(Player);
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsNewTurn];
      Log := TSendEmailGameEventLog.Create(nil);
      Log.FMode := 2;
      Log.FSendPlayer := Player;
      AoWHSMap.TriggerExecuteEventLog(Log, False, SendEmailGameCallBack);
      Log.Release;
    end
    else
    begin
      inherited NewTurn(Player);
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus - [pbsNewTurn, pbsTurnDone] + [pbsPlaying];
    end;
  end;
end;

procedure TPBEMPlayerControl.TriggerGameRestartedEvents(Player: Shortint);
var
  Log: TRestartGameEventLog;
begin
  AoWHSMap.SynchroniseBegin;
  Log := TRestartGameEventLog.Create(nil);
  Log.FPlayer := Player;
  Log.FMessage.Text := Format(TranslateRStr(GameRestartEventLogXRStr), [AoWHSMap.FPlayers.GetPlayers(Player).GetName]);
  DistributeEventLog(Log, False);
  Log.Release;
  AoWHSMap.SynchroniseEnd;
end;

procedure TPBEMPlayerControl.EndTurnGameSavedCallBack(Log: TEventLog);
var
  Failed: Boolean;
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus :=
        (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus + [pbsTurnDone]) - [pbsPlaying];
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ShowMessage(Format(TranslateRStr(GameSavedRStr), [TSaveGameEventLog(Log).FFileName]));
      AoWHSMap.SynchroniseBegin;
      inherited EndTurn(AoWHSMap.FCurrentPlayer);
      AoWHSMap.SynchroniseEnd;
      Failed := False;
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [TSaveGameEventLog(Log).FFileName]));
      Failed := True;
    end
  else Failed := True;
  if Failed then AoWHSMap.TriggerEndTurnEvent(AoWHSMap.FCurrentPlayer);
end;

procedure TPBEMPlayerControl.EndTurn(Player: Shortint);
var
  SaveLog: TSaveGameEventLog;
  MessageLog: TMessageEventLog;
  Saved: Boolean;
begin
  if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman) and
    (AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying) then
  begin
    if CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0 then
    begin
      SaveLog := TSaveGameEventLog.Create(nil);
      SaveLog.FTitle := TranslateRStr(SaveEmailGameRStr);
      if AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FName <> '' then
        SaveLog.FDefaultName := AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FName + '.asg';
      SaveLog.FDirectory := AoWEngine.StartupDirectory + 'EmailIn\';
      AoWHSMap.TriggerExecuteEventLog(SaveLog, False, EndTurnGameSavedCallBack);
      SaveLog.Release;
    end
    else
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
        (AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsTurnDone]) - [pbsPlaying];
      try
        AoWEngine.SaveHSM(AoWHSMap.FileName, nil);
        Saved := True;
      except Saved := False;
      end;
      if Saved then inherited EndTurn(AoWHSMap.FCurrentPlayer)
      else
      begin
        MessageLog := TMessageEventLog.Create(nil);
        MessageLog.FMessage.Text := Format(TranslateRStr(CouldNotSaveXRStr) + '.', [AoWHSMap.FileName]);
        AoWHSMap.TriggerExecuteEventLog(MessageLog, False, TerminateEmailGameCallBack);
        MessageLog.Release;
      end;
    end;
  end
  else inherited EndTurn(AoWHSMap.FCurrentPlayer); { Original uses current player, ignoring Player here. }
end;

procedure TPBEMPlayerControl.StartLoadedEmailGame;
begin
  AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FLastDay := AoWHSMap.FDay;
  AoWEngine.FEmailGames.UpdateGame(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame);
  AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus :=
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus + [pbsPlaying];
  if pbsNewTurn in AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus then
  begin
    AoWHSMap.SynchroniseBegin;
    DefaultStartMap;
    AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
    NewTurn(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
  end
  else StartLoadedMapEx;
end;

procedure TPBEMPlayerControl.ContinueRestartedGameCallBack(Log: TEventLog);
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    AoWHSMap.SynchroniseBegin;
    TriggerGameRestartedEvents(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
    StartLoadedEmailGame;
  end
  else AoWHSMap.ExecuteExitGame;
end;

procedure TPBEMPlayerControl.ContinueTurnDoneGameCallBack(Log: TEventLog);
begin
  if TMessageEventLog(Log).FPressedButton = pebYes then
  begin
    AoWHSMap.SynchroniseBegin;
    DefaultStartMap;
    AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
    EndTurn(AoWHSMap.FCurrentPlayer);
    AoWHSMap.SynchroniseEnd;
  end
  else AoWHSMap.ExecuteExitGame;
end;

procedure TPBEMPlayerControl.ValidateLoadedMap;
var
  Restarted: Boolean;
  Log: TMessageEventLog;
begin
  FLocalPlayer := AoWHSMap.FCurrentPlayer;
  if AoWEngine.FEmailGames.FindEmailGame(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame) = nil then
  begin
    Restarted := AoWEngine.FEmailGames.EmailGameRestarted(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame);
    AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.SetGame(AoWEngine.FEmailGames.CreateEmailGame(
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName,
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FEmailAddress));
    if Restarted then TriggerGameRestartedEvents(AoWHSMap.FCurrentPlayer);
    StartLoadedEmailGame;
  end
  else
  begin
    if AoWEngine.FEmailGames.EmailGameRestarted(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame) then
    begin
      SetSeatedPlayer(-1);
      Log := TMessageEventLog.Create(nil);
      Log.FButtons := mebYesNo;
      Log.FTitle := TranslateRStr(WarningRStr);
      Log.FMessage.Text := TranslateRStr(PBEMRestartCheatRStr);
      Log.FMessage.Add('');
      Log.FMessage.Add(TranslateRStr(DoYouWantToContinueRStr));
      AoWHSMap.TriggerExecuteEventLog(Log, False, ContinueRestartedGameCallBack);
      Log.Release;
    end
    else
    begin
      SetSeatedPlayer(-1);
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus * [pbsNewTurn, pbsTurnDone] = [pbsTurnDone] then
      begin
        Log := TMessageEventLog.Create(nil);
        Log.FTitle := TranslateRStr(WarningRStr);
        Log.FButtons := mebYesNo;
        Log.FMessage.Text := TranslateRStr(PBEMGameEndedRStr);
        Log.FMessage.Add('');
        Log.FMessage.Add(TranslateRStr(DoYouWantToContinueRStr));
        AoWHSMap.TriggerExecuteEventLog(Log, False, ContinueTurnDoneGameCallBack);
        Log.Release;
      end
      else StartLoadedEmailGame;
    end;
  end;
end;

procedure TPBEMPlayerControl.PasswordValidated;
begin ValidateLoadedMap; end;

procedure TPBEMPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FSettings)
  else ValidateLoadedMap;
end;

procedure TPBEMPlayerControl.StartNewMap;
var
  I: Integer;
  Player: Integer;
begin
  DefaultStartMap;
  NewDay;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
  I := 0;
  while (I < AoWHSMap.FTurnOrder.Count) and
    (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FTurnOrder[I]).FPlayerType <> ptHuman) do Inc(I);
  Player := AoWHSMap.FTurnOrder[I];
  if (AoWEngine.FEmailGames.FindEmailGame(AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame) <> nil) and
    (CompareText(AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FEmailGame.FEmailAddress, AoWEngine.FRegistry.GetLocalEmailAddress) = 0) then
  begin
    FLocalPlayer := Player;
    AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus :=
      AoWHSMap.FPlayers.GetPlayers(Player).FPBEMSettings.FStatus + [pbsNewTurn];
  end
  else AoWHSMap.SetSeatedPlayer(-1);
  NewTurn(AoWHSMap.FTurnOrder[1]);
end;

procedure TPBEMPlayerControl.ExitGameSaveAsCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
    try
      AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
      AoWHSMap.ExecuteExitGame;
    except
      AoWHSMap.ShowWarning(Format(TranslateRStr(CouldNotSaveXRStr), [TSaveGameEventLog(Log).FFileName]));
    end;
end;

procedure TPBEMPlayerControl.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  Log: TSaveGameEventLog;
begin
  if pbsPlaying in AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FStatus then
  begin
    if CompareText(ExtractFileExt(AoWHSMap.FileName), '.hsm') = 0 then
    begin
      Log := TSaveGameEventLog.Create(nil);
      Log.FTitle := TranslateRStr(SaveEmailGameRStr);
      if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName <> '' then
        Log.FDefaultName := AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FName + '.asg';
      Log.FDirectory := AoWEngine.StartupDirectory + 'EmailIn\';
      AoWHSMap.TriggerExecuteEventLog(Log, False, ExitGameSaveAsCallBack);
      Log.Release;
    end
    else
    begin
      AoWEngine.SaveHSM(AoWHSMap.FileName, nil);
      AoWHSMap.ExecuteExitGame;
    end;
  end
  else AoWHSMap.ExecuteExitGame;
end;

class function TSimultaniousPlayerControl.ClassID: Integer;
begin Result := $20251; end;

procedure TSimultaniousPlayerControl.NewTurn(Player: Shortint); { Near miss: player index caching after three variants. }
var
  Log: TEventLog;
  Spells: TSpellList;
begin
  if Player = AoWHSMap.FSeatedPlayer then
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      if AoWHSMap.FDay = 1 then
      begin
        if AoWHSMap.FGameType = gtCustom then
        begin
          Log := TShowBookEventLog.Create(nil);
          AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
          Log.Release;
        end;
        if AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FResearchSpellID = 0 then
        begin
          Spells := TSpellList.Create;
          AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.ListResearchSpells(Spells, [stCombat, stUnit, stGlobal]);
          if Spells.GetCount > 0 then
          begin
            Log := TPlayerMagicEventLog.Create(nil);
            TPlayerMagicEventLog(Log).FMode := pmemStartResearch;
            AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
            Log.Release;
          end;
          Spells.Free;
        end;
      end
      else
      begin
        AoWHSMap.ResetTurnTimer;
        AoWHSMap.EnableTurnTimer;
      end;
    end;
  inherited NewTurn(Player);
  if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then
    if AoWHSMap.FPlayers.GetPlayers(Player).FStatus = psPlaying then AoWHSMap.FAIExecuter.ActivatePlayer(Player);
end;

procedure TSimultaniousPlayerControl.Setup;
begin
  inherited Setup;
  AoWHSMap.FTokenManager.TokenExecuter.HoldTC := False;
end;

procedure TSimultaniousPlayerControl.EndTurn(Player: Shortint);
var
  I: Integer;
  AllDone: Boolean;
  Log: TEndTurnEventLog;
  Msg: TEMsg;
begin
  AoWHSMap.FPlayers.GetPlayers(Player).SetEndTurn(True);
  AllDone := True;
  I := 1;
  while AllDone and (I <> AoWHSMap.FPlayers.Count) do
  begin
    AllDone := (AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psPlaying) or
      AoWHSMap.FPlayers.GetPlayers(I).FSingleProcessCycle;
    Inc(I);
  end;
  if AllDone then
  begin
    if AoWHSMap.FSeatedPlayer = Player then AoWHSMap.ClearExecuteEventLogBuffer;
    AoWHSMap.LockRelationsChanged;
    for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    begin
      if AoWHSMap.FPlayers.GetPlayers(I).FStatus = psPlaying then
      begin
        if AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptHuman then AoWHSMap.FAIExecuter.DeactivatePlayer(I);
        Log := TEndTurnEventLog.Create(nil);
        AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Log);
        Log.Release;
      end;
      InitMsg(Msg, $20020007, Self);
      Msg.Value := I;
      AoWHSMap.SendMsg(Msg, Self);
    end;
    AoWHSMap.UnlockRelationsChanged;
    NewDay;
  end;
end;

procedure TSimultaniousPlayerControl.NewDay;
var
  I: Integer;
begin
  AoWHSMap.Selection.UnselectLocation;
  inherited NewDay;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do NewTurn(I);
  PlaySample('SFX\EVENTS\NEWTURN.WAV');
  if AoWEngine.FRegistry.GetAutoSave then AutoSave;
end;

procedure TSimultaniousPlayerControl.StartGameCallBack(Log: TEventLog);
begin
  if AoWHSMap.FConnectionType <> pcNetwork then
  begin
    AoWHSMap.FAIExecuter.Unlock;
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end;
end;

procedure TSimultaniousPlayerControl.StartNewMap;
var
  I: Integer;
  Log: TNewTurnEventLog;
begin
  inherited StartNewMap;
  AoWHSMap.FShowIndependentMoves := False;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if (I = 0) or (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptIndependent) then
      AoWHSMap.FPlayers.GetPlayers(I).FStatus := psPlaying;
  AoWHSMap.FPlayers.Update;
  AoWHSMap.FCurrentPlayer := 0;
  AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
  AoWHSMap.SeatedPlayerChanged;














































































































































































































  Assert(AoWHSMap.FSeatedPlayer <> 0);
  AoWHSMap.ResetSeatedPlayerView;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  Log := TNewTurnEventLog.Create(nil);
  Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
  Log.FMode := ntDialog;
  Log.FDialogStyle := [nsCloseable];
  Log.FText := TranslateRStr(LetTheGameBeginRStr);
  AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
  Log.Release;
  if AoWHSMap.FConnectionType = pcNetwork then
  begin
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end
  else AoWHSMap.FAIExecuter.Lock;
  NewDay;
end;

procedure TSimultaniousPlayerControl.StartLoadedMapEx;
var
  I: Integer;
  Log: TNewTurnEventLog;
  Player: TPlayer;
begin
  AoWHSMap.FShowIndependentMoves := False;
  AoWHSMap.SetSeatedPlayer(AoWHSMap.FPlayers.FLocalHumanPlayers[0]);
  AoWHSMap.SeatedPlayerChanged;
  AoWHSMap.ResetSeatedPlayerView;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Player := AoWHSMap.FPlayers.GetPlayers(I);
    if (Player.FStatus = psPlaying) and (Player.FPlayerType <> ptHuman) then AoWHSMap.FAIExecuter.ActivatePlayer(I);
  end;
  for I := 0 to AoWHSMap.FPlayers.Count - 1 do
    if AoWHSMap.FPlayers.GetPlayers(I).FStatus <> psPlaying then AoWHSMap.FTokenManager.TokenControls[I].Active := False;
  AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(AoWHSMap.FCurrentPlayer);
  Log := TNewTurnEventLog.Create(nil);
  Log.FTurnPlayer := AoWHSMap.FSeatedPlayer;
  Log.FMode := ntDialog;
  Log.FDialogStyle := [nsCloseable];
  Log.FText := TranslateRStr(TheGameContinuesRStr);
  AoWHSMap.TriggerExecuteEventLog(Log, False, StartGameCallBack);
  Log.Release;
  if AoWHSMap.FConnectionType = pcNetwork then
  begin
    AoWHSMap.ResetTurnTimer;
    AoWHSMap.EnableTurnTimer;
  end
  else AoWHSMap.FAIExecuter.Lock;
end;

procedure TSimultaniousPlayerControl.PasswordValidated;
begin StartLoadedMapEx; end;

procedure TSimultaniousPlayerControl.StartLoadedMap;
begin
  if AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FSettings <> '' then
    ValidatePassword(AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FSettings)
  else StartLoadedMapEx;
end;

procedure TSimultaniousPlayerControl.GameOverEventHandled(Player: Shortint);
begin
  AoWHSMap.SetSeatedPlayer(-1);
  AoWHSMap.TriggerGameTerminatedEvent;
end;

procedure TSimultaniousPlayerControl.SetPlayerGameOverStatus(Player: Shortint; Status: TGameOverStatus); { Near miss: status parameter spill after three variants. }
begin
  inherited SetPlayerGameOverStatus(Player, Status);
  AoWHSMap.FPlayers.GetPlayers(Player).FStatus := psTerminated;
  AoWHSMap.FTokenManager.TokenExecuter.GetTC(Player).Active := False;
  AoWHSMap.FPlayers.Update;
  AoWHSMap.TriggerPlayerTerminatedEvent(Player);
  if AoWHSMap.FPlayers.FLocalHumanPlayers.Count = 0 then AoWHSMap.TriggerGameTerminatedEvent
  else EndTurn(Player);
end;

procedure TSimultaniousPlayerControl.ValidateTurnTiming;
begin
  if AoWHSMap.GetTurnTimerEnabled and (AoWHSMap.GetTurnTimeLeft <= 0) then
    if (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FGameOverStatus = goNone) and
      (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FSingleProcessCycle = False) then
      if AoWHSMap.FTokenManager.PlayerReady(AoWHSMap.FSeatedPlayer) then EndPlayerTurn(AoWHSMap.FSeatedPlayer);
end;

procedure TPlayerConnectionEventLog.Setup(Player: Shortint; Reason: Byte);
begin
  FReason := Reason;
  FDisconnectedPlayer := Player;
  case FReason of
    3:
      begin
        FButtons := mebYesNo;
        FMessage.Text := TranslateRStr(OutOfSyncRStr);
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
    1:
      begin
        FButtons := mebYesNo;
        FMessage.Text := Format(TranslateRStr(ConnectionXTimeOutRStr),
          [AoWHSMap.FPlayers.GetPlayers(FDisconnectedPlayer).GetName]);
        FMessage.Add('');
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
    2:
      begin
        FButtons := mebYesNo;
        if FDisconnectedPlayer <> -1 then
          FMessage.Text := Format(TranslateRStr(ConnectionXLostRStr),
            [AoWHSMap.FPlayers.GetPlayers(FDisconnectedPlayer).GetName])
        else FMessage.Text := TranslateRStr(ConnectionLostRStr);
        FMessage.Add('');
        FMessage.Add(TranslateRStr(TerminateGameSaveRStr));
      end;
  end;
end;

procedure TPlayerConnectionEventLog.ExitSaveGameCallBack(Log: TEventLog);
begin
  if TSaveGameEventLog(Log).FFileName <> '' then
  begin
    if AoWEngine.FCampaign <> nil then AoWEngine.SaveCampaign(TSaveGameEventLog(Log).FFileName)
    else AoWEngine.SaveHSM(TSaveGameEventLog(Log).FFileName, nil);
  end
  else AoWHSMap.ExecuteExitGame; { Original exits twice when the dialog is canceled. }
  AoWHSMap.ExecuteExitGame;
end;

function TPlayerConnectionEventLog.Yes: Boolean;
var
  Log: TSaveGameEventLog;
begin
  Log := TSaveGameEventLog.Create(nil);
  Log.FDefaultName := '';
  Log.FDirectory := AoWEngine.StartupDirectory + 'Save\';
  AoWHSMap.TriggerExecuteEventLog(Log, False, ExitSaveGameCallBack);
  Log.Release;
  Result := True;
end;

function TPlayerConnectionEventLog.No: Boolean;
begin
  AoWHSMap.ExecuteExitGame;
  Result := True;
end;

constructor TRaceResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIndexes := TUnitIndexList.Create;
  FSpecialUnitIndexes := TUnitIndexList.Create;
  FHeroNames := TStringList.Create;
end;

destructor TRaceResource.Destroy;
begin
  ReleaseIL;
  FUnitIndexes.Free;
  FSpecialUnitIndexes.Free;
  FHeroNames.Free;
  inherited Destroy;
end;

function TRaceResource.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function TRaceResource.GetFace: TLibraryImage;
var
  Images: TCustomImageLibrary;
begin
  AddRef;
  Images := FFaceLibrary;
  if Images <> nil then Result := Images.GetSafe(GetRaceIndex)
  else Result := nil;
  Release;
end;

function TRaceResource.GetRaceIndex: Integer;
begin Result := EditIndex; end;

procedure TRaceResource.LinkToIL;
begin
  if FImageLibrary = nil then
  begin
    if FImageLibraryName <> '' then
      FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
    FFaceLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'FACES\R_FACES.ILB');
  end;
end;

procedure TRaceResource.ReleaseIL;
begin
  if FImageLibrary <> nil then { Original leaves the face library linked when the city library is nil. }
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'FACES\R_FACES.ILB');
    FFaceLibrary := nil;
    FImageLibrary := nil;
  end;
end;

procedure TRaceResource.SetImageLibraryName(Value: string);
begin
  if Value <> FImageLibraryName then
  begin
    ReleaseIL;
    FImageLibraryName := Value;
    if FReferences <> 0 then LinkToIL;
  end;
end;

function TRaceResource.AddRef: Integer;
begin
  if FReferences = 0 then LinkToIL;
  Inc(FReferences);
  Result := FReferences;
end;

function TRaceResource.Release: Integer;
begin
  Dec(FReferences);
  if FReferences = 0 then ReleaseIL;
  Result := FReferences;
end;

class function TRaceResource.ClassID: Integer;
begin Result := $20201; end;

class function TRaceResource.ResourceEditName: string;
begin Result := 'Race'; end;

function TRaceResource.GetCellImage: ImageLib.TLibraryImage;
var
  I: Integer;
begin
  AddRef;
  Result := nil;
  if FImageLibrary <> nil then
  begin
    I := 0;
    while (I < FImageLibrary.Count) and (Result = nil) do
    begin
      Result := FImageLibrary[I];
      Inc(I);
    end;
  end;
  Release;
end;

procedure TRaceResource.SetCellImage(Value: ImageLib.TLibraryImage);
begin end;

function TRaceResource.GetCityImage(Size, Terrain, Level: Integer): TLibraryImage;
var
  Index: Integer;
begin
  if Terrain = 5 then Index := Size + 60 - 1
  else Index := Terrain * 10 + 70 + (Size - 1);
  if FImageLibrary.ImageExist(Index) then Result := FImageLibrary[Index]
  else Result := nil;
  if Result = nil then
  begin
    if Level = 0 then Index := Size + 50 - 1
    else Index := Size + 60 - 1;
    if FImageLibrary.ImageExist(Index) then Result := FImageLibrary[Index];
  end;
end;

procedure TRaceResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then FUnitIndexes.VerifyUnits(True);
end;

procedure TRaceResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 5);
  Stream.rwString(FRaceName, 6);
  Stream.rwString(FDescription, 7);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 8);
  Stream.rwData(FAlignments, 1, 9);
  Stream.rwStreamProc(10, FUnitIndexes.LoadFromStream, FUnitIndexes.SaveToStream);
  Stream.rwStreamProc(11, FSpecialUnitIndexes.LoadFromStream, FSpecialUnitIndexes.SaveToStream);
  Stream.rwInteger(FHeroUnitIndex, 12);
  Stream.rwStrings(FHeroNames, 13);
end;

function TRaceResource.GetAlignment: TAlignment;
begin
  if FAlignments = alsPureGood then
  begin
    Result := alPureGood;
    Exit;
  end;
  if FAlignments = alsGood then Result := alGood
  else if FAlignments = alsNeutral then Result := alNeutral
  else if FAlignments = alsEvil then Result := alEvil
  else if FAlignments = alsPureEvil then Result := alPureEvil
  else if FAlignments = alsPureNeutral then Result := alPureNeutral
  else Result := alNone;
end;

constructor TRaceResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TRaceResourceList.GetRaceResource(Index: Integer): TRaceResource;
begin
  if (Index < GetCount) and (Index >= 0) then
    Result := TRaceResource(FChildren.List^[Index])
  else Result := nil;
end;

function TRaceResourceList.GetMaxRaceIndex: Integer;
begin
  Result := Count - 1;
  while (Result > 0) and (FChildren.List^[Result] = nil) do Dec(Result);
end;

constructor TFlagControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  with TAoWHSSet(AOwner) do
  begin
    FFlags := ImageLibraryManager.LinkToIL([icDisk], 'Flags.ILB');
    Self.FRaceResources := FRaceResources;
  end;
  SetControlStyle([csFixedChild]);
end;

destructor TFlagControl.Destroy;
begin
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'Flags.ILB');
  FFlags := nil;
  inherited Destroy;
end;

procedure TFlagControl.ShowFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
begin
  FFlags.Images[4].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 2) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 22].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset + 12].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
begin
  if ShowBase then FFlags.Images[4].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 2) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 22].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset + 12].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowStructureFlag(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc);
begin
  FFlags.Images[FlagID shr 6].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 1) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 10].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset].Show(X - 21, Y - 16, SurfaceDesc);
end;

procedure TFlagControl.ShowStructureFlagEx(X, Y, FrameOffset: Integer; FlagID: Byte; const SurfaceDesc: TSurfaceDesc; ShowBase: Boolean);
begin
  if ShowBase then FFlags.Images[FlagID shr 6].Show(X, Y, SurfaceDesc);
  FrameOffset := (FrameOffset shr 1) mod 12;
  if FlagID and $20 <> 0 then
    FFlags.Images[FrameOffset + 10].Show(X - 21, Y - 16, SurfaceDesc)
  else
    FRaceResources.GetRaceResource(FlagID and $1F).FImageLibrary.Images[FrameOffset].Show(X - 21, Y - 16, SurfaceDesc);
end;

function Format(const S: string; const Args: array of const): string;
{ conflict: function Format(const Fmt: string; const Args: array of const): string; }
begin
  try
    Result := SysUtils.Format(S, Args);
  except
    Result := S;
  end;
end;

function FmtTurnsStr(Turns: Integer): string;
begin
  if Turns = 1 then Result := Format(TranslateRStr(XTurnRStr), ['1'])
  else Result := Format(TranslateRStr(XTurnsRStr), [IntToStr(Turns)]);
end;


function FmtTurnsLeftStr(Turns: Integer): string;
begin
  if Turns = 1 then Result := Format(TranslateRStr(XTurnLeftRStr), ['1'])
  else Result := Format(TranslateRStr(XTurnsLeftRStr), [IntToStr(Turns)]);
end;


function FmtDaysStr(Days: Integer): string;
begin
  if Days = 1 then Result := Format(TranslateRStr(XDayRStr), ['1'])
  else Result := Format(TranslateRStr(XDaysRStr), [IntToStr(Days)]);
end;


function FmtDaysLeftStr(Days: Integer): string;
begin
  if Days = 1 then Result := Format(TranslateRStr(XDayLeftRStr), ['1'])
  else Result := Format(TranslateRStr(XDaysLeftRStr), [IntToStr(Days)]);
end;

function HitPointsToHitPcnt(A1, A2: Shortint): Integer;
begin
  Result := A1 * 100 div A2;
  if (Result = 0) and (A1 <> 0) then Result := 1;
  if Result > 100 then Result := 100;
end;


procedure ShowHitPcnt(X, Y: Integer; const Surface: TSurfaceDesc; Percent: Integer);
var
  SD: TSurfaceDesc;
  Left: Integer;
begin
  SD := Surface;
  AoWHSSet.FCombatImages[0].Show(X + 20, Y + 54, SD);
  Left := X + 20;
  SD.ClipRect.Right := Left + (Percent + 3) div 4;
  if SD.ClipRect.Right > Surface.ClipRect.Right then SD.ClipRect.Right := Surface.ClipRect.Right;
  AoWHSSet.FCombatImages[1].Show(Left, Y + 54, SD);
end;


procedure ShowDamageIcon(X, Y: Integer; const Surface: TSurfaceDesc; Damage: Integer; DamageType: TDamageType);
begin
  if DamageType <> dtNone then
  begin
    AoWHSSet.FCombatImages[Ord(DamageType) + 10].Show(X + 15, Y + 10, Surface);
    if DamageType in [dtCold, dtLightning, dtMagic, dtHoly] then AoWEngine.FCombatFont.Color := clBlack
    else AoWEngine.FCombatFont.Color := clWhite;
    AoWEngine.FCombatFont.SetTextCentered(X + 34, Y + 36, IntToStr(Damage), Surface);
  end;
end;


function ShowDamageEffects(DamageTypes: TDamageTypes; X, Y, Frame: Integer; const Surface: TSurfaceDesc): Boolean;
begin
  Result := False;
  if dtFire in DamageTypes then
    Result := Result or AoWHSSet.FAbilityControl.GetAbility(127).FImageSequences.Show(0, X + 32, Y + 32, Frame, Surface);
  if dtPoison in DamageTypes then
    Result := Result or AoWHSSet.FAbilityControl.GetAbility(96).FImageSequences.Show(0, X + 32, Y + 32, Frame, Surface);
  if dtCold in DamageTypes then
    Result := Result or AoWHSSet.FAbilityControl.GetAbility(95).FImageSequences.Show(1, X + 32, Y + 32, Frame, Surface);
  if dtDeath in DamageTypes then
    Result := Result or AoWHSSet.FAbilityControl.GetAbility(93).FImageSequences.Show(0, X + 32, Y + 32, Frame, Surface);
  if dtHoly in DamageTypes then
    Result := Result or AoWHSSet.FAbilityControl.GetAbility(98).FImageSequences.Show(0, X + 32, Y + 32, Frame, Surface);
end;


function DamageEffectsAnimationFrames(A1: TDamageTypes): Integer;
var
  Frames: Integer;
begin
  Result := 0;
  if dtFire in A1 then
  begin
    Frames := AoWHSSet.FAbilityControl.GetAbility(127).FImageSequences.GetFramesCount(0);
    if Result < Frames then Result := Frames;
  end;
  if dtPoison in A1 then
  begin
    Frames := AoWHSSet.FAbilityControl.GetAbility(96).FImageSequences.GetFramesCount(0);
    if Result < Frames then Result := Frames;
  end;
  if dtCold in A1 then
  begin
    Frames := AoWHSSet.FAbilityControl.GetAbility(95).FImageSequences.GetFramesCount(1);
    if Result < Frames then Result := Frames;
  end;
  if dtDeath in A1 then
  begin
    Frames := AoWHSSet.FAbilityControl.GetAbility(93).FImageSequences.GetFramesCount(0);
    if Result < Frames then Result := Frames;
  end;
  if dtHoly in A1 then
  begin
    Frames := AoWHSSet.FAbilityControl.GetAbility(98).FImageSequences.GetFramesCount(0);
    if Result < Frames then Result := Frames;
  end;
end;


function StatusToStatusValue(Status: TStatus): Integer;
begin
  case Ord(Status) of
    0: Result := 10;
    1: Result := 30;
    2: Result := 50;
    3: Result := 70;
    4: Result := 90;
  else
    Result := 50;
    { Original constructs and leaks this exception without raising it. }
    Exception.Create('Invalid TStatus Value');
  end;
end;

function StatusValueToStatus(Value: Integer): TStatus;
begin
  if Value <= 20 then Result := sHostile
  else if Value > 80 then Result := sFriendly
  else
    case Value of
      21..40: Result := sWary;
      41..60: Result := sNeutral;
      61..80: Result := sPolite;
    else
      Result := sNeutral;
      { Original constructs and leaks this exception without raising it. }
      Exception.Create('Invalid StatusValue');
    end;
end;

function MoraleToMoraleValue(Value: Integer): Integer;
begin
  case Value and $7F of
    0: Result := 10;
    1: Result := 30;
    2: Result := 50;
    3: Result := 70;
    4: Result := 90;
  else
    Result := 50;
    Exception.Create('Invalid TMoral Value'); { Original leaks the exception without raising it. }
  end;
end;


function MoraleValueToMorale(Value: Integer): TMorale;
begin
  if Value <= 20 then Result := mTerrible
  else if Value > 80 then Result := mHigh
  else
    case Value of
      21..40: Result := mPoor;
      41..60: Result := mOK;
      61..80: Result := mGood;
    else
      Result := mOK;
      Exception.Create('Invalid MoralValue'); { Original leaks the exception without raising it. }
    end;
end;


function dAlignmentsToStatus(A, B: TAlignments): TStatus;
begin
  if A = B then Result := sFriendly
  else if A * B = [] then Result := sHostile
  else Result := sNeutral;
end;


function DamageTypesToDamageType(A1: TDamageTypes): TDamageType;
begin
  if A1 <> [] then
    if dtHoly in A1 then Result := dtHoly
    else if dtMagic in A1 then Result := dtMagic
    else if dtDeath in A1 then Result := dtDeath
    else if dtCold in A1 then Result := dtCold
    else if dtFire in A1 then Result := dtFire
    else if dtPoison in A1 then Result := dtPoison
    else if dtPhysical in A1 then Result := dtPhysical
    else if dtWall in A1 then Result := dtWall
    else Result := dtNone
  else Result := dtNone;
end;


function dAlignmentToStatus(A, B: TAlignment): TStatus;
begin
  Result := StatusValueToStatus(dAlignmentToStatusValue[A, B]);
end;


function AlsToInt(Alignments: TAlignments): Integer;
begin
  Result := PByte(@Alignments)^;
end;


function IntToAls(Value: Integer): TAlignments;
type
  PAlignments = ^TAlignments;
begin
  Result := PAlignments(@Value)^;
end;


function Land(Terrain: Shortint): Boolean;
begin
  Result := not (Terrain in [0, 6, 9, 10, 13]);
end;


function MoveTypesToInt(Types: TMoveTypes): Integer;
begin
  Result := PByte(@Types)^;
end;


function IntToMoveTypes(Value: Integer): TMoveTypes;
type
  PMoveTypes = ^TMoveTypes;
begin
  Result := PMoveTypes(@Value)^;
end;


function CombatRangeToCombatMode(A1: TCombatRange): TCombatMode;
begin
  case A1 of
    crLong: Result := cmLongRange;
    crMedium: Result := cmMediumRange;
    crShort: Result := cmShortRange;
    crTouch: Result := cmTouch;
  else Result := cmNone;
  end;
end;


function PlaceRandomUnits(X, Y, L: Integer; Player: Shortint; Units: TUnitIndexList; Level, Value: Integer; Types: TUnitTypes): Integer;
var Index, Tries, Difference, BestIndex, I, Delta: Integer; Unit_: TUnit;
begin
  Result := 0; Tries := 50;
  if Units.Count <> 0 then
    while (Result < Value) and (Tries <> 0) do
    begin
      Dec(Tries);
      Index := Units[Random(Units.Count)];
      if (Index <> -1) and (AoWHSSet.FUnitResources.GetUnitResource(Index).FUnitType in Types) and
        (AoWHSSet.FUnitResources.GetUnitResource(Index).GetObtainValue + Result > Value) and
        (AoWHSSet.FUnitResources.GetUnitResource(Index).FLevel <= Level) then
      begin
        BestIndex := Index; I := 20;
        Difference := Abs(AoWHSSet.FUnitResources.GetUnitResource(Index).GetObtainValue - (Value - Result));
        repeat
          Index := Units[Random(Units.Count)];
          if (Index <> -1) and (AoWHSSet.FUnitResources.GetUnitResource(Index).FUnitType in Types) then
          begin
            Delta := Abs(AoWHSSet.FUnitResources.GetUnitResource(Index).GetObtainValue - (Value - Result));
            if Delta < Difference then begin Difference := Delta; BestIndex := Index; end;
          end;
          Dec(I);
        until I = 0;
        Index := BestIndex;
      end;
      if (Index <> -1) and (AoWHSSet.FUnitResources.GetUnitResource(Index).FUnitType in Types) and
        (AoWHSSet.FUnitResources.GetUnitResource(Index).FLevel <= Level) then
      begin
        Unit_ := TUnit.Create(nil);
        Unit_.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
        if Unit_.Place(X, Y, L, Player, []) <> nil then
        begin Inc(Result, Unit_.GetObtainValue); Tries := 50; end;
        Unit_.Release;
      end;
    end;
end;

function FillWithRandomUnits(Indexes: TIntegerList; Units: TUnitList; Level, Value: Integer; Types: TUnitTypes): Integer;
var TestUnit: TUnit; Index, Tries, I, Difference, BestIndex, Delta: Integer; Unit_: TUnit;
  function CanUse(Unit_: TUnit): Boolean;
  begin
    Result := (Unit_.FUnitResource <> nil) and (Unit_.GetUnitType in Types) and
      (Unit_.GetUnitLevel <= Level) and Units.CanAddUnit(Unit_);
  end;
begin
  TestUnit := TUnit.Create(nil); Result := 0; Tries := 50;
  Units.BeginUpdate;
  while (Result < Value) and (Tries <> 0) do
  begin
    Dec(Tries);
    Index := Indexes[Random(Indexes.Count)];
    if Index <> -1 then
    begin
      TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
      if CanUse(TestUnit) then
      begin
        if TestUnit.GetObtainValue + Result > Value then
        begin
          BestIndex := Index; I := 20;
          Difference := Abs(TestUnit.GetObtainValue - (Value - Result));
          repeat
            Index := Indexes[Random(Indexes.Count)];
            if (Index <> -1) and (Index <> BestIndex) then
            begin
              TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
              if CanUse(TestUnit) then
              begin
                Delta := Abs(TestUnit.GetObtainValue - (Value - Result));
                if Delta < Difference then begin BestIndex := Index; Difference := Delta; end;
              end;
            end;
            Dec(I);
          until I = 0;
          Index := BestIndex;
        end;
        Unit_ := TUnit.Create(nil);
        Unit_.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
        Units.AddUnit(Unit_);
        Inc(Result, Unit_.GetObtainValue);
        Tries := 50;
        Unit_.Release;
      end;
    end;
  end;
  Units.EndUpdate;
  TestUnit.Release;
end;

function FillWithRandomUnitIndexes(Indexes, Units: TIntegerList; Level, Value: Integer; Types: TUnitTypes): Integer;
var TestUnit: TUnit; Index, Tries, I, Difference, BestIndex, Delta: Integer;
  function CanUse(Unit_: TUnit): Boolean;
  begin
    Result := (Unit_.FUnitResource <> nil) and (Unit_.GetUnitType in Types) and
      (Unit_.GetUnitLevel <= Level);
  end;
begin
  TestUnit := TUnit.Create(nil); Result := 0; Tries := 50;

  while (Result < Value) and (Tries <> 0) do
  begin
    Dec(Tries);
    Index := Indexes[Random(Indexes.Count)];
    if Index <> -1 then
    begin
      TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
      if CanUse(TestUnit) then
      begin
        if TestUnit.GetObtainValue + Result > Value then
        begin
          BestIndex := Index; I := 20;
          Difference := Abs(TestUnit.GetObtainValue - (Value - Result));
          repeat
            Index := Indexes[Random(Indexes.Count)];
            if (Index <> -1) and (Index <> BestIndex) then
            begin
              TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(Index));
              if CanUse(TestUnit) then
              begin
                Delta := Abs(TestUnit.GetObtainValue - (Value - Result));
                if Delta < Difference then begin BestIndex := Index; Difference := Delta; end;
              end;
            end;
            Dec(I);
          until I = 0;
          Index := BestIndex;
        end;
        Units.Add(Index);
        Inc(Result, AoWHSSet.FUnitResources.GetUnitResource(Index).FObtainValue);
        Tries := 50;
      end;
    end;
  end;

  TestUnit.Release;
end;

procedure TriggerStormDamage(Storm: TStormType; X, Y, L, InnerRadius, OuterRadius, Player: Shortint);
var Msg: TMapFieldMsg; Walk: THNWalkData; Level: TMapLevel;
begin

  Level := AoWHSMap.MapContainer.MapLevels[L];
  Msg.MsgID := $1150;
  Msg.Param[0] := Ord(Storm);
  Msg.Param[2] := Player;
  InitHNWalk(Walk, X, Y, InnerRadius);
  while Walk.Radius <= OuterRadius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Msg.Param[1] := Walk.Radius;
      Level.Field[Walk.X, Walk.Y].SendMapFieldMsg(Msg);
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure RetrieveStormDamageInfo(Player: Shortint; Storm: TStormType; X, Y, L, InnerRadius, OuterRadius: Shortint; var Info: TStormDamageInfo);
var Msg: TMapFieldMsg; Walk: THNWalkData; Level: TMapLevel;
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.Player := Player;
  Info.FriendlyRelations := [0, 2];
  Info.EnemyRelations := [1, 3];
  Level := AoWHSMap.MapContainer.MapLevels[L];
  Msg.MsgID := $1151;
  Msg.Param[0] := Ord(Storm);
  Msg.Param[2] := Integer(@Info);
  Msg.Param[3] := 0;
  InitHNWalk(Walk, X, Y, InnerRadius);
  while Walk.Radius <= OuterRadius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Msg.Param[1] := Walk.Radius;
      Level.Field[Walk.X, Walk.Y].SendMapFieldMsg(Msg);
    end;
    WalkToNextHN(Walk);
  end;
end;

function dAlignmentToDiplomaticRelation(A, B: TAlignment): TDiplomaticRelation;
begin
  if A in [alPureGood, alGood] then
    if B in [alPureGood, alGood] then Result := drPeace
    else if B in [alPureNeutral, alNeutral, alNone] then Result := drUnknown
    else Result := drWar
  else if A in [alEvil, alPureEvil] then
    if B in [alEvil, alPureEvil] then Result := drPeace
    else if B in [alPureNeutral, alNeutral, alNone] then Result := drUnknown
    else Result := drWar
  else if (A = alPureNeutral) and (B = alPureNeutral) then Result := drPeace
  else Result := drUnknown;
end;


function StatusToDiplomaticRelation(Status: TStatus): TDiplomaticRelation;
begin
  case Status of
    sPolite, sFriendly: Result := drPeace;
    sNeutral: Result := drUnknown;
    sHostile, sWary: Result := drWar;
  else Result := drUnknown; end;
end;

function GetCombatSide(Attacker, AttackerRelation, Defender, DefenderRelation, Player, Relation: Shortint): TCombatSideIndex;
begin
  if (Player <> 0) and (Attacker = 0) and (Defender = 0) then Result := csNeutral
  else if (Player = Attacker) and ((Player <> 0) or (AttackerRelation = Relation)) then Result := csAttacker
  else if (Player = Defender) and ((Player <> 0) or (DefenderRelation = Relation)) then Result := csDefender
  else if Player = 0 then
  begin
    if (Attacker <> 0) and (DiplomaticRelation(Attacker, AttackerRelation, Player, Relation) = drPeace) and
      (DiplomaticRelation(Defender, DefenderRelation, Player, Relation) <> drPeace) then Result := csAttacker
    else if (Defender <> 0) and (DiplomaticRelation(Defender, DefenderRelation, Player, Relation) = drPeace) and
      (DiplomaticRelation(Attacker, AttackerRelation, Player, Relation) <> drPeace) then Result := csDefender
    else Result := csNeutral;
  end
  else
  begin
    if (Attacker <> 0) and (DiplomaticRelation(Attacker, AttackerRelation, Player, Relation) = drAlliance) and
      (DiplomaticRelation(Defender, DefenderRelation, Player, Relation) <> drAlliance) then Result := csAttacker
    else if (Defender <> 0) and (DiplomaticRelation(Defender, DefenderRelation, Player, Relation) = drAlliance) and
      (DiplomaticRelation(Attacker, AttackerRelation, Player, Relation) <> drAlliance) then Result := csDefender
    else Result := csNeutral;
  end;
end;

function AlignmentToIR(Alignment: TAlignment): Shortint;
begin
  case Alignment of
    alPureGood, alGood: Result := -2;
    alEvil, alPureEvil: Result := -4;
    alPureNeutral, alNeutral: Result := -3;
  else Result := -1; end;
end;

function IRtoAlignment(Relation: Shortint): TAlignment;
begin
  if Relation < 0 then
    case Relation of
      -2: Result := alGood;
      -4: Result := alEvil;
      -3: Result := alNeutral;
    else Result := alNeutral; end
  else Result := AoWHSSet.FRaceResources.GetRaceResource(Relation).GetAlignment;
end;

function DiplomaticRelation(Player, IndependentRelation, OtherPlayer, OtherIndependentRelation: Shortint): TDiplomaticRelation;
var Race, OtherRace: Shortint; Alignment, OtherAlignment: TAlignment;
begin
  if (Player = 0) or (OtherPlayer = 0) then
  begin
    if Player <> 0 then Race := AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace
    else if IndependentRelation >= 0 then Race := IndependentRelation else Race := -1;
    if OtherPlayer <> 0 then OtherRace := AoWHSMap.FPlayers.GetPlayers(OtherPlayer).FPlayerRace
    else if OtherIndependentRelation >= 0 then OtherRace := OtherIndependentRelation else OtherRace := -1;
    if (Race = -1) or (OtherRace = -1) then
    begin
      if Race = -1 then Alignment := IRtoAlignment(IndependentRelation)
      else Alignment := AoWHSSet.FRaceResources.GetRaceResource(Race).GetAlignment;
      if OtherRace = -1 then OtherAlignment := IRtoAlignment(OtherIndependentRelation)
      else OtherAlignment := AoWHSSet.FRaceResources.GetRaceResource(OtherRace).GetAlignment;
      Result := dAlignmentToDiplomaticRelation(Alignment, OtherAlignment);
    end
    else Result := StatusToDiplomaticRelation(AoWHSMap.FRaces.GetRace(Race).GetRelation(OtherRace));
  end
  else if Player = OtherPlayer then Result := drAlliance
  else Result := AoWHSMap.FPlayers.GetDiplomaticRelation(Player, OtherPlayer);
end;

function ValidAttackRelation(Player, IndependentRelation, TargetPlayer, TargetRace: Shortint): Boolean;
begin
  if Player = 0 then
    if TargetPlayer <> 0 then
      Result := DiplomaticRelation(Player, IndependentRelation, TargetPlayer, TargetRace) in [drWar, drUnknown]
    else Result := False
  else Result := AoWHSMap.FPlayers.GetPlayers(Player).ValidAttackRelation(TargetPlayer, TargetRace);
end;

function GetUnitIndexAIPriority(UnitIndex: Integer; Player: Shortint; Relation: Shortint): Integer;
var Resource: TUnitResource; Value: Integer; Unit_: TUnit; DefaultUnit: TAdjustableUnit;
begin
  Resource := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex);
  if (Resource <> nil) and (Resource.GetTransportCapacity = 0) then
  begin
    if Player <> 0 then
      if Resource.FRace <> -1 then
        Value := AoWHSMap.FRaces.GetRace(Resource.FRace).GetPlayerRelationValue(Player)
      else Value := dAlignmentToStatusValue[Resource.FAlignment, AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace).GetAlignment]
    else Value := dAlignmentToStatusValue[Resource.FAlignment, IRtoAlignment(Relation)];
    if Value >= 50 then
    begin
      Unit_ := TUnit.Create(nil); Unit_.SetUnitResource(Resource);
      DefaultUnit := TAdjustableUnit.Create(nil); DefaultUnit.MakeDefaultLevelUnit(1);
      if Unit_.GetCombatValue(DefaultUnit, 0) > 0 then
      begin
        Result := Unit_.GetStrengthMax(dtAll - [dtWall]) div 100 + (Resource.FLevel * 100 + Resource.FMoves * 10 + Value div 2);
        if Resource.FAbilities[urNone].GetAbSet(57) or Resource.FAbilities[urNone].GetAbSet(58) then Inc(Result, 100);
        if Resource.FAbilities[urNone].GetAbSet(13) then Inc(Result, 150);
        if (AoWHSMap <> nil) and (AoWHSMap.FDay > 20) and
          (Resource.FAbilities[urNone].GetAbSet(20) or Resource.FAbilities[urNone].GetAbSet(19) or
           Resource.FAbilities[urNone].GetAbSet(18) or Resource.FAbilities[urNone].GetAbSet(121) or
           Resource.FAbilities[urNone].GetAbSet(88) or Resource.FAbilities[urNone].GetAbSet(89)) then Inc(Result, 100);
        if Resource.FAbilities[urNone].GetAbSet(1) or Resource.FAbilities[urNone].GetAbSet(36) or
          Resource.FAbilities[urNone].GetAbSet(66) or Resource.FAbilities[urNone].GetAbSet(24) or
          Resource.FAbilities[urNone].GetAbSet(44) or
          (Resource.FAbilities[urNone].GetAbSet(117) and Resource.FAbilities[urNone].GetAbSet(21)) then Inc(Result, 100);
        if Resource.FAbilities[urNone].GetAbSet(65) then Result := Result div 2;
      end
      else Result := -1;
      DefaultUnit.Free; Unit_.Free;
    end
    else Result := -1;
  end
  else Result := -1;
end;

function UnitsToIndependentRelation(Units: TUnitList; DefaultRelation: Shortint): Shortint;
var SameRace, Evil, Good, Neutral: Boolean; I: Integer; Race: Integer; Unit_: TAbstractUnit; Alignment: TAlignment; Relation: Shortint;
begin
  Relation := -1; SameRace := True; I := Units.FChildren.Count;
  while SameRace and (I <> 0) do
  begin
    Dec(I); Race := TAbstractUnit(Units.FChildren.List^[I]).GetRace;
    if (Race <> -1) and (Race <> Relation) then
      if Relation = -1 then Relation := Race else SameRace := False;
  end;
  if SameRace and (Relation = -1) then Relation := DefaultRelation;
  if Relation = -1 then SameRace := False;
  I := Units.FChildren.Count;
  while SameRace and (I <> 0) do
  begin
    Dec(I);
    SameRace := (Relation = TAbstractUnit(Units.FChildren.List^[I]).GetRace) or
      (TAbstractUnit(Units.FChildren.List^[I]).GetAlignment in AoWHSSet.FRaceResources.GetRaceResource(Relation).FAlignments);
  end;
  if not SameRace then
  begin
    Evil := True; Good := True; Neutral := True;
    for I := 0 to Units.FChildren.Count - 1 do
    begin
      Unit_ := TAbstractUnit(Units.FChildren.List^[I]); Alignment := Unit_.GetAlignment;
      Evil := Evil and (Alignment in alsEvil) and ((Unit_.GetRace = -1) or (Alignment in [alEvil, alPureEvil]));
      Good := Good and (Alignment in alsGood) and ((Unit_.GetRace = -1) or (Alignment in [alPureGood, alGood]));
      Neutral := Neutral and (Alignment in alsNeutral);
    end;
    if Good and not Evil then Result := -2
    else if Evil and not Good then Result := -4 else Result := -3;
  end else Result := Relation;
end;

procedure DegreesRadToCo(A1: Integer; A2: Integer; var A3: Integer; var A4: Integer);
var
  Radians: Single;
begin
  Radians := A1 * Pi / 180;
  A3 := Round(Cos(Radians) * A2);
  A4 := Round(Sin(Radians) * A2);
end;

function Encode(Text: string; Mode: Integer): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to Length(Text) do
    Result := Result + Char(Ord(Text[I]) xor ((Length(Text) + (I + 5)) and $FF));
end;

procedure SetupBattleFieldInfo(var Info: TBattleFieldInfo; Player, Relation: Shortint; Requests: TBattleFieldInfoRequests; DamageTypes: TDamageTypes);
begin
  FillChar(Info, SizeOf(Info), 0);
  Info.Player := Player;
  { Original ignores the independent relation parameter. }
  Info.Requests := Requests;
  Info.DamageTypes := DamageTypes;
  Info.FriendlyRelations := [2];
  Info.EnemyRelations := [1, 3];
end;

function StrengthInfoMax(const Strengths): Integer;
type TStrengthInfo = array[TDamageType] of Integer;
var DamageType: TDamageType;
begin
  Result := 0;
  for DamageType := Low(TDamageType) to High(TDamageType) do
    if TStrengthInfo(Strengths)[DamageType] > Result then Result := TStrengthInfo(Strengths)[DamageType];
end;

function InvertDamageTypes(Types: TDamageTypes): TDamageTypes;
var DamageType: TDamageType;
begin
  Result := [];
  for DamageType := Low(TDamageType) to High(TDamageType) do
    if not (DamageType in Types) then Result := Result + [DamageType];
end;

function ListMovementGaps(Map: TAoWHSMap; Path: TMovepath; const Table: TMovePointTable; Starts, Ends: TIntegerList): Integer;
var I: Integer; Gap: Boolean; Field: TMapField;
begin
  I := Path.Count - 1; Result := 0; Gap := False;
  while I > 1 do
  begin
    Dec(I);
    Field := Map.MapContainer.GetField(Path[I].X, Path[I].Y, Path[I].L);
    if Table[Field.TerrainType, Field.OverlayType] = -1 then
    begin
      if not Gap then
      begin
        Inc(Result);
        if Starts <> nil then Starts.Add(I);
        Gap := True;
      end;
    end
    else if Gap then
    begin
      if Ends <> nil then Ends.Add(I);
      Gap := False;
    end;
  end;
  if Gap and (Ends <> nil) then Ends.Add(1);
end;

function GetMovepathBattleFieldStrength(Player, IndependentRelation: Shortint; Movepath: TMovepath; TargetRange, Range, Step: Integer): Integer;
var Units: TUnitUserList; I, J, Distance: Integer; Walk: THNWalkData; Info: TBattleFieldInfo; Level: TMapLevel; Field: TAoWMapField; Army: TArmyHS;
begin
  if (Movepath <> nil) and (Movepath.Count > 0) then
  begin
    Distance := Round(Range * 0.5);
    Result := 0;
    I := Movepath.Count - 1;
    Units := nil;
    if Movepath.Count - TargetRange < I then I := Movepath.Count - TargetRange;
    SetupBattleFieldInfo(Info, Player, IndependentRelation, [], dtAll - [dtWall]);
    Info.FriendlyRelations := [];
    Info.Requests := Info.Requests + [bfrIgnorePassiveIndependents, bfrEffectiveStrength];
    if Step > 0 then
    begin
      Units := TUnitUserList.Create(nil);
      Level := AoWHSMap.MapContainer.MapLevels[Movepath[Movepath.Count - 1].L];
      InitHNWalk(Walk, Movepath[Movepath.Count - 1].X, Movepath[Movepath.Count - 1].Y, 0);
      while Walk.Radius <= Step do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        begin
          Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
          if Field.FFieldFlags and $04000000 <> 0 then
          begin
            Army := Field.GetArmyHS;
            if (Army <> nil) and (Army.FArmy.FPlayer <> Player) then Units.AddUnits(Army.FArmy);
          end;
        end;
        WalkToNextHN(Walk);
      end;
      Info.Units := Units;
    end;
    while I >= 0 do
    begin
      Info.Strength := 0;
      AoWHSMap.RetrieveBattleFieldInfo(Movepath[I].X, Movepath[I].Y, Movepath[I].L, Range, Info);
      if Info.Strength > Result then Result := Info.Strength;
      J := I;
      while (J >= 0) and (Movepath[J].L = Movepath[I].L) and (J > I - Distance) do Dec(J);
      if (J = 0) or (Movepath[I].L <> Movepath[J].L) then
        if J - 1 <> I then
        begin
          Info.Strength := 0;
          AoWHSMap.RetrieveBattleFieldInfo(Movepath[J + 1].X, Movepath[J + 1].Y, Movepath[J + 1].L, Range, Info);
          if Info.Strength > Result then Result := Info.Strength;
        end;
      I := J;
    end;
    if Units <> nil then Units.Free;
    AoWHSMap.FAIExecuter.UseProcessTime(50);
  end
  else Result := 0;
end;

function GetBattleFieldStrengthAdvantage(Location: Integer; Player, Relation: Shortint; DamageTypes: TDamageTypes; EnemyRadius, FriendlyRadius: Integer; Units: TUnitList): Integer; { Near miss: set/arithmetic register allocation differs after three variants. }
var Info: TBattleFieldInfo;
begin
  SetupBattleFieldInfo(Info, Player, Relation, [], DamageTypes);
  Info.EnemyRelations := [];
  Info.Units := Units;
  Include(Info.Requests, bfrIgnorePassiveIndependents);
  AoWHSMap.RetrieveBattleFieldInfo(TXYL(Location).X, TXYL(Location).Y, TXYL(Location).L, EnemyRadius, Info);
  Result := Info.FriendlyStrength;
  SetupBattleFieldInfo(Info, Player, Relation, [], DamageTypes);
  Info.FriendlyRelations := [];
  Info.Units := Units;
  Include(Info.Requests, bfrIgnorePassiveIndependents);
  AoWHSMap.RetrieveBattleFieldInfo(TXYL(Location).X, TXYL(Location).Y, TXYL(Location).L, FriendlyRadius, Info);
  Result := Result - Info.Strength;
end;

