class function TProductionEventLog.ClassID: Integer;
begin Result := $202F9; end;

class function TUnitProduction.ClassID: Integer;
begin Result := $20299; end;

procedure TUnitProduction.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitIndex, 20);
  Stream.rwBool(FResearched, 21);
end;

function TUnitProductionList.GetItem(Index: Integer): TUnitProduction;
begin
  if (Index >= 0) and (Index < Count) then Result := FChildren.List^[Index]
  else Result := nil;
end;

procedure TUnitProductionList.Add(UnitIndex: Integer; Researched: Boolean);
begin
  with TUnitProduction.Create(Self) do
  begin
    FUnitIndex := UnitIndex;
    FResearched := Researched;
  end;
end;

function TUnitProductionList.IndexOf(Index: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Index = GetItem(Result).FUnitIndex then Exit;
  end;
  Result := -1;
end;

function CompareUnitProductionLevel(Item1, Item2: Pointer): Integer;
var
  Level1, Level2: Integer;
begin
  with TUnitProduction(Item1) do
    if AoWHSSet.FUnitResources.GetUnitResource(FUnitIndex) <> nil then
      Level1 := AoWHSSet.FUnitResources.GetUnitResource(FUnitIndex).FLevel * 2
    else Level1 := 0;
  if AoWHSSet.FUnitResources.GetUnitResource(TUnitProduction(Item2).FUnitIndex) <> nil then
    Level2 := AoWHSSet.FUnitResources.GetUnitResource(TUnitProduction(Item2).FUnitIndex).FLevel * 2
  else Level2 := 0;
  Result := Level1 - Level2;
  if Result = 0 then Result := TUnitProduction(Item1).FUnitIndex - TUnitProduction(Item2).FUnitIndex;
end;

procedure TUnitProductionList.SortOnLevel;
begin
  FChildren.Sort(CompareUnitProductionLevel);
end;

class function TProductionItem.ClassID: Integer;
begin Result := $20297; end;

procedure TProductionItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FProductionID, 20);
  Stream.rwInteger(FParameter, 21);
  Stream.rwInteger(FGroupID, 22);
end;

function TProductionItem.GetName: string;
begin
  if Owner <> nil then Result := TProductionQueue(Owner).FProductionControl.GetProductionName(Self)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionItem.GetNameProgressive: string;
begin
  if Owner <> nil then Result := TProductionQueue(Owner).FProductionControl.GetProductionNameProgressive(Self)
  else Result := TranslateRStr(UnknownRStr);
end;

function TProductionQueue.GetItem(Index: Integer): TProductionItem;
begin
  if (Index >= 0) and (Index < Count) then Result := FChildren.List^[Index]
  else Result := nil;
end;

function TProductionQueue.IndexOfID(ID: Integer): Integer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if ID = TProductionItem(FChildren.List^[Result]).FProductionID then Exit;
  end;
  Result := -1;
end;

function TProductionQueue.IndexOf(ID, Parameter, GroupID: Integer): Integer;
var
  Item: TProductionItem;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    Item := FChildren.List^[Result];
    if (ID = Item.FProductionID) and (Parameter = Item.FParameter) and (Item.FGroupID = GroupID) then Exit;
  end;
  Result := -1;
end;

destructor TProductionSettings.Destroy;
begin
  Clear;
  inherited Destroy;
end;

procedure TProductionSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGold, 10);
  Stream.rwInteger(FMana, 11);
  Stream.rwByte(Byte(FTurnsLeft), 12);
  Stream.rwByte(Byte(FTurnsTotal), 13);
  Stream.rwByte(Byte(FPlayer), 14);
  Stream.rwInteger(FGroupID, 15);
  Stream.rwInteger(FUnitProductionIndex, 16);
  Stream.rwCreateEObject(TEObject(FUnit), nil, 17);
  Stream.rwInteger(FGoldUpkeep, 18);
  Stream.rwInteger(FManaUpkeep, 19);
end;

procedure TProductionSettings.Clear;
var
  U: TAbstractUnit;
begin
  FTurnsLeft := 0;
  FGold := 0;
  FMana := 0;
  FTurnsTotal := 0;
  FPlayer := 0;
  FGroupID := 0;
  FUnitProductionIndex := -1;
  U := FUnit;
  if U <> nil then
  begin
    U.Release;
    FUnit := nil;
  end;
  { Original leaves the upkeep fields unchanged. }
end;

destructor TProductionTE.Destroy;
begin
  if FItem <> nil then
  begin
    FItem.Free;
    FItem := nil;
  end;
  inherited Destroy;
end;

class function TProductionTE.ClassID: Integer;
begin Result := $20298; end;

procedure TProductionTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FCommand, 20);
  Stream.rwByte(Byte(FX), 21);
  Stream.rwByte(Byte(FY), 22);
  Stream.rwByte(Byte(FL), 23);
  Stream.rwByte(Byte(FPlayer), 24);
  Stream.rwCreateEObject(TEObject(FItem), nil, 25);
  Stream.rwInteger(FIndex, 26);
  Stream.rwInteger(FReserved, 27);
  Stream.rwBool(FQueue, 28);
end;

function TProductionTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Control: TProductionControl;
begin
  Control := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetProductionControl;
  if Control <> nil then Result := Control.ExecuteProductionTE(Self)
  else Result := erDoneHalt;
end;

constructor TProductionControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSettings := TProductionSettings.Create(nil);
  FUnitProductions := TUnitProductionList.Create(nil);
  FQueue := TProductionQueue.Create(nil);
  FQueue.FProductionControl := Self;
  FStatus := pcsIdle;
  Clear;
end;

destructor TProductionControl.Destroy;
begin
  FSettings.Free;
  FUnitProductions.Free;
  FQueue.Free;
  inherited Destroy;
end;

procedure TProductionControl.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure TProductionControl.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then Update;
end;

procedure TProductionControl.Update;
begin
  if FUpdateCount = 0 then
    if Assigned(FOnChange) then FOnChange(Self);
end;

procedure TProductionControl.Activate;
begin RegisterGroupProduction; end;

procedure TProductionControl.Deactivate;
begin UnregisterGroupProduction; end;

function TProductionControl.GetProduceUnitLevelMax: Integer;
var
  I: Integer;
  Resource: TUnitResource;
begin
  Result := 0;
  for I := FUnitProductions.Count - 1 downto 0 do
    if (FUnitProductions.GetItem(I).FResearched) and (FUnitProductions.GetItem(I).FUnitIndex >= 0) then
    begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex);
      if Resource <> nil then
        if Result < Resource.FLevel then Result := Shortint(PChar(Resource)[$2F]); { reload FLevel }
    end;
end;

function TProductionControl.GetResearchUnitLevelMax: Integer;
var
  I: Integer;
  Resource: TUnitResource;
begin
  Result := 0;
  for I := FUnitProductions.Count - 1 downto 0 do
    if (not FUnitProductions.GetItem(I).FResearched) and (FUnitProductions.GetItem(I).FUnitIndex >= 0) then
    begin
      Resource := AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex);
      if Resource <> nil then
        if Result < Resource.FLevel then Result := Shortint(PChar(Resource)[$2F]); { reload FLevel }
    end;
end;

function TProductionControl.CancelProductionReturnGold: Integer;
begin
  if FStatus = pcsProducing then
    with FSettings do
      if FTurnsTotal <> 0 then Result := Round(FTurnsLeft * FGold / FTurnsTotal)
      else Result := 0
  else Result := 0;
end;

function TProductionControl.CancelProductionReturnMana: Integer;
begin
  if FStatus = pcsProducing then
    with FSettings do
      if FTurnsTotal <> 0 then Result := Round(FTurnsLeft * FMana / FTurnsTotal)
      else Result := 0
  else Result := 0;
end;

function TProductionControl.GetQueueSizeMax: Integer;
begin Result := 5; end;

function TProductionControl.GetQueueLocked: Boolean;
var
  I: Integer;
begin
  I := FQueue.Count;
  Result := I >= GetQueueSizeMax;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := LockQueueProduction(FQueue.GetItem(I));
  end;
end;

procedure TProductionControl.ExecuteCancelProduction;
var
  Player: Shortint;
begin
  if FStatus = pcsProducing then
  begin
    if FSettings.FGroupID <> 0 then UnregisterGroupProduction;
    Player := GetPlayer;
    if Player > -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(Player).SetGems(
        AoWHSMap.FPlayers.GetPlayers(Player).FGems + CancelProductionReturnGold);
      AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.SetMana(
        AoWHSMap.FPlayers.GetPlayers(Player).FMagicControl.FMana + CancelProductionReturnMana);
    end;
    FSettings.Clear;
    FStatus := pcsWaiting;
    Update;
  end;
end;

procedure TProductionControl.RegisterGroupProduction;
var
  Group: TAIGroup;
begin
  if (FStatus = pcsProducing) and (FSettings.FGroupID <> 0) then
  begin
    Group := AoWHSMap.FAIGroupManager.FindID(FSettings.FGroupID);
    if Group <> nil then Group.FProductions.Add(Self, FSettings.FUnit);
  end;
end;

procedure TProductionControl.UnregisterGroupProduction;
var
  Group: TAIGroup;
begin
  if (FStatus = pcsProducing) and (FSettings.FGroupID <> 0) then
  begin
    Group := AoWHSMap.FAIGroupManager.FindID(FSettings.FGroupID);
    if Group <> nil then Group.FProductions.DeleteUnit(FSettings.FUnit);
    FSettings.FGroupID := 0;
  end;
end;

procedure TProductionControl.GroupProductionProduced(AUnit: TAbstractUnit; GroupID: Integer);
var
  Group: TAIGroup;
begin
  Group := AoWHSMap.FPlayers.GetPlayers(GetPlayer).FAIGroups.FindID(GroupID);
  if Group <> nil then Group.UnitProduced(Self, AUnit);
end;

procedure TProductionControl.PlayerChanged;
var
  I: Integer;
begin
  for I := FQueue.Count - 1 downto 1 do FQueue.GetItem(I).Free;
  UnregisterGroupProduction;
  FLoopQueue := False;
  if (FQueue.Count <> 0) and (FStatus <> pcsProducing) then
  begin
    FQueue.GetItem(0).Free;
    FStatus := pcsIdle;
  end;
end;

function TProductionControl.CanExecuteProduction(Item: TProductionItem; var Reason: string): Boolean;
begin
  if FStatus = pcsWaiting then Reason := '(' + LowerCase(TranslateRStr(WaitingRStr)) + ')';
  { Original continues checking costs after assigning the waiting text. }
  case Item.FProductionID of
    1:
      if UnitProductionGold(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGems then
        if UnitProductionMana(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FMagicControl.FMana then
          Result := True
        else
        begin
          Result := False;
          Reason := TranslateRStr(NotEnoughManaRStr);
        end
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughGoldRStr);
      end;
    2:
      if UnitResearchGold(Item.FParameter) <= AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGems then
        Result := True
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughGoldRStr);
      end;
  else Result := False;
  end;
end;

function TProductionControl.ExecuteProduction(Item: TProductionItem): Boolean;
var
  Reason: string;
begin
  if CanExecuteProduction(Item, Reason) then
  begin
    BeginUpdate;
    ExecuteCancelProduction;
    FStatus := pcsWaiting;
    case Item.FProductionID of
      1:
        begin
          FSettings.Clear;
          FSettings.FUnitProductionIndex := Item.FParameter;
          FSettings.FUnit := CreateUnitProduction(Item.FParameter);
          FSettings.FGold := UnitProductionGold(Item.FParameter);
          FSettings.FMana := UnitProductionMana(Item.FParameter);
          FSettings.FGoldUpkeep := UnitProductionGoldUpkeep(Item.FParameter);
          FSettings.FManaUpkeep := UnitProductionManaUpkeep(Item.FParameter);
          FSettings.FGroupID := Item.FGroupID;
          FSettings.FTurnsTotal := UnitProductionTime(Item.FParameter);
          FSettings.FPlayer := GetPlayer;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          with AoWHSMap.FPlayers.GetPlayers(FSettings.FPlayer) do
          begin
            SetGems(FGems - Self.FSettings.FGold);
            FMagicControl.SetMana(FMagicControl.FMana - Self.FSettings.FMana);
          end;
          FStatus := pcsProducing;
          if FSettings.FGroupID <> 0 then RegisterGroupProduction;
        end;
      2:
        begin
          FSettings.Clear;
          FSettings.FUnitProductionIndex := Item.FParameter;
          FSettings.FGold := UnitResearchGold(Item.FParameter);
          FSettings.FMana := 0;
          FSettings.FTurnsTotal := UnitResearchTime(Item.FParameter);
          FSettings.FPlayer := GetPlayer;
          FSettings.FTurnsLeft := FSettings.FTurnsTotal;
          with AoWHSMap.FPlayers.GetPlayers(FSettings.FPlayer) do
          begin
            SetGems(FGems - Self.FSettings.FGold);
            FMagicControl.SetMana(FMagicControl.FMana - Self.FSettings.FMana);
          end;
          FStatus := pcsProducing;
        end;
    end;
    EndUpdate;
    Result := True;
  end
  else
  begin
    FStatus := pcsWaiting;
    Result := False;
  end;
end;

procedure TProductionControl.ExecuteAddProduction(Item: TProductionItem);
var
  NewItem: TProductionItem;
begin
  BeginUpdate;
  NewItem := TProductionItem(Item.Copy(AoWEngine));
  NewItem.SetOwner(FQueue);
  if FQueue.Count = 1 then ExecuteProduction(NewItem);
  EndUpdate;
end;

procedure TProductionControl.ExecuteDeleteProduction(Index: Integer);
begin
  BeginUpdate;
  if Index = 0 then
  begin
    ExecuteCancelProduction;
    FQueue.GetItem(Index).Free;
    if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
    else FStatus := pcsIdle;
  end
  else FQueue.GetItem(Index).Free;
  EndUpdate;
end;

procedure TProductionControl.ExecuteDeleteProductions;
begin
  BeginUpdate;
  ExecuteCancelProduction;
  FQueue.Clear;
  EndUpdate;
end;

function TProductionControl.ExecuteAIProduction(Index, GroupID: Integer): Boolean;
var
  Item: TProductionItem;
begin
  ExecuteDeleteProductions;
  Item := TProductionItem.Create(nil);
  Item.FProductionID := 1;
  Item.FParameter := Index;
  Item.FGroupID := GroupID;
  ExecuteAddProduction(Item);
  Item.Free;
  Result := True;
end;

function TProductionControl.ExecuteAIResearch(Index: Integer): Boolean;
var
  Item: TProductionItem;
begin
  if not FUnitProductions.GetItem(Index).FResearched then
  begin
    ExecuteDeleteProductions;
    Item := TProductionItem.Create(nil);
    Item.FProductionID := 2;
    Item.FParameter := Index;
    ExecuteAddProduction(Item);
    Item.Free;
    Result := True;
  end
  else Result := True;
end;

function TProductionControl.ExecuteProductionTE(Event: TProductionTE): TExecuteResult;
begin
  case Event.FCommand of
    0:
      begin
        BeginUpdate;
        if not Event.FQueue then ExecuteDeleteProductions;
        ExecuteAddProduction(Event.FItem);
        Result := erDone;
        EndUpdate;
      end;
    1:
      begin
        ExecuteDeleteProduction(Event.FIndex);
        Result := erDone;
      end;
    2:
      begin
        ExecuteDeleteProductions;
        Result := erDone;
      end;
    3:
      begin
        if (FQueue.Count <> 0) and (FStatus = pcsWaiting) then
          ExecuteProduction(FQueue.GetItem(0));
        Result := erDone;
      end;
    4:
      begin
        FLoopQueue := Event.FIndex = 1;
        Update;
        Result := erDone;
      end;
  else Result := erDone;
  end;
end;

function TProductionControl.CreateProductionTE: TProductionTE;
var
  Event: TProductionTE;
begin
  Event := TProductionTE.Create(nil);
  GetLocation(Event.FX, Event.FY, Event.FL);
  Event.FPlayer := GetPlayer;
  Result := Event;
end;

function TProductionControl.UnitProduced: Boolean;
begin Result := False; end;

function TProductionControl.CreateUnitProduction(Index: Integer): TUnit;
var
  AUnit: TUnit;
begin
  if FUnitProductions.GetItem(Index) <> nil then
  begin
    AUnit := TUnit.Create(nil);
    AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(Index).FUnitIndex));
    Result := AUnit;
  end
  else Result := nil;
end;

function TProductionControl.UnitProductionGold(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FObtainValue;
end;

function TProductionControl.UnitProductionGoldUpkeep(Index: Integer): Integer;
begin
  Result := (AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(Index).FUnitIndex).FLevel + 1) * 2;
end;

function TProductionControl.UnitProductionMana(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitProductionManaUpkeep(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitProductionTime(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FLevel;
end;

function TProductionControl.CanProduceUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin Result := True; end;

function TProductionControl.ProduceUnitEx(Index, GroupID: Integer; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
  Reason: string;
begin
  if CanProduceUnit(Index, Queue, Reason) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem.Create(nil);
    { explicit item receiver }
    begin
      Event.FItem.FProductionID := 1;
      Event.FItem.FParameter := Index;
      Event.FItem.FGroupID := GroupID;
    end;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.ProduceUnit(Index: Integer; Queue: Boolean): Boolean;
begin
  Result := ProduceUnitEx(Index, 0, Queue);
end;

procedure TProductionControl.UnitResearched;
begin
  FUnitProductions.GetItem(FSettings.FUnitProductionIndex).FResearched := True;
end;

function TProductionControl.UnitResearchGold(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FObtainValue;
end;

function TProductionControl.UnitResearchMana(Index: Integer): Integer;
begin Result := 0; end;

function TProductionControl.UnitResearchTime(Index: Integer): Integer;
var
  UnitIndex: Integer;
begin
  UnitIndex := FUnitProductions.GetItem(Index).FUnitIndex;
  Result := AoWHSSet.FUnitResources.GetUnitResource(UnitIndex).FLevel;
end;

function TProductionControl.CanResearchUnit(Index: Integer; Queue: Boolean; var Reason: string): Boolean;
begin
  if not Queue or (FQueue.IndexOf(2, Index, 0) = -1) then Result := True
  else
  begin
    Result := False;
    Reason := TranslateRStr(ActionAlreadyQueuedRStr);
  end;
end;

function TProductionControl.ResearchUnit(Index: Integer; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
  Reason: string;
begin
  if CanResearchUnit(Index, Queue, Reason) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem.Create(nil);
    { explicit item receiver }
    begin
      Event.FItem.FProductionID := 2;
      Event.FItem.FParameter := Index;
    end;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := False; { Original returns False after successfully queueing research. }
  end
  else Result := True;
end;

function TProductionControl.Produce(Item: TProductionItem; Queue: Boolean): Boolean;
var
  Event: TProductionTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 0;
    Event.FQueue := Queue;
    Event.FItem := TProductionItem(Item.Copy(AoWEngine));
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := False; { Original returns False after successfully queueing production. }
  end
  else Result := True;
end;

function TProductionControl.DeleteProduction(Index: Integer): Boolean;
var
  Event: TProductionTE;
begin
  if (Index >= 0) and (Index < FQueue.Count) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 1;
    Event.FIndex := Index;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.DeleteProductions: Boolean;
var
  Event: TProductionTE;
begin
  if (FQueue.Count <> 0) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 2;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TProductionControl.RetryProductionExecution(var Reason: string): Boolean;
var
  Event: TProductionTE;
begin
  if (FQueue.Count <> 0) and (FStatus = pcsWaiting) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    if CanExecuteProduction(FQueue.GetItem(0), Reason) then
    begin
      Event := CreateProductionTE;
      Event.FCommand := 3;
      AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
      Event.Release;
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

function TProductionControl.SetLoopQueueTo(Value: Boolean): Boolean;
var
  Event: TProductionTE;
begin
  if (Value <> FLoopQueue) and not AoWHSMap.FPlayers.GetPlayers(GetPlayer).GetBusy then
  begin
    Event := CreateProductionTE;
    Event.FCommand := 4;
    if Value then Event.FIndex := 1 else Event.FIndex := 0;
    AoWHSMap.FTokenManager.GetTokenControl(GetPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TProductionControl.GetLocation(var X, Y, L: Shortint);
begin
  X := -1;
  Y := -1;
  L := -1;
end;

procedure TProductionControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FQueue, 20);
  Stream.rwEObject(FUnitProductions, 21);
  Stream.rwEObject(FSettings, 22);
  Stream.rwData(FStatus, SizeOf(FStatus), 23);
  Stream.rwBool(FLoopQueue, 24);
end;

procedure TProductionControl.ProductionDone;
begin
  BeginUpdate;
  if FLoopQueue and LoopableProduction(FQueue.GetItem(0)) then
    FQueue.FChildren.Move(0, FQueue.Count - 1)
  else FQueue.GetItem(0).Free;
  if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
  else FStatus := pcsIdle;
  EndUpdate;
end;

procedure TProductionControl.NewTurn(Player: Shortint);
begin
  if (FStatus = pcsWaiting) and (Player = GetPlayer) then
  begin
    if FQueue.Count <> 0 then ExecuteProduction(FQueue.GetItem(0))
    else FStatus := pcsIdle;
  end
  else if (FStatus = pcsProducing) and (Player = FSettings.FPlayer) then
  begin
    if FSettings.FTurnsLeft > 0 then Dec(FSettings.FTurnsLeft);
    if FSettings.FTurnsLeft = 0 then
      case FQueue.GetItem(0).FProductionID of
        1:
          if UnitProduced then
          begin
            if (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) and (FSettings.FGroupID <> 0) then
              GroupProductionProduced(FSettings.FUnit, FSettings.FGroupID);
            FSettings.Clear;
            ProductionDone;
          end;
        2:
          begin
            UnitResearched;
            FSettings.Clear;
            ProductionDone;
          end;
      end;
  end;
end;

function TProductionControl.LockQueueProduction(Item: TProductionItem): Boolean;
begin Result := False; end;

function TProductionControl.LoopableProduction(Item: TProductionItem): Boolean;
begin Result := Item.FProductionID <> 2; end;

function TProductionControl.GetProductionName(Item: TProductionItem): string;
var
  Production: TUnitProduction;
begin
  case Item.FProductionID of
    1:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          if UnitProductionGold(Item.FParameter) <> 0 then
            Result := Format(TranslateRStr(ProduceXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
          else Result := Format(TranslateRStr(SummonXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
    2:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          Result := Format(TranslateRStr(InstallXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
  else Result := TranslateRStr(UnknownRStr);
  end;
end;

function TProductionControl.GetProductionNameProgressive(Item: TProductionItem): string;
var
  Production: TUnitProduction;
begin
  case Item.FProductionID of
    1:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          if UnitProductionGold(Item.FParameter) <> 0 then
            Result := Format(TranslateRStr(ProducingXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
          else Result := Format(TranslateRStr(SummoningXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
    2:
      begin
        Production := FUnitProductions.GetItem(Item.FParameter);
        if Production <> nil then
          Result := Format(TranslateRStr(InstallingXRStr), [AoWHSSet.FUnitResources.GetUnitResource(Production.FUnitIndex).GetUnitName])
        else Result := TranslateRStr(UnknownRStr);
      end;
  else Result := TranslateRStr(UnknownRStr);
  end;
end;

function TProductionControl.FindOptimalResearchProduction(Predictor: TCombatPredictor; Gold: Integer): Integer;
var
  Player: TPlayer;
  AUnit: TUnit;
  Productions: TDoubleItemList;
  I, Priority, Minimum: Integer;
  Include: Boolean;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(GetPlayer);
  AUnit := TUnit.Create(nil);
  Productions := TDoubleItemList.Create;
  for I := FUnitProductions.Count - 1 downto 0 do
    if not FUnitProductions.GetItem(I).FResearched then
    begin
      Include := UnitResearchGold(I) <= Gold;
      if Predictor <> nil then
      begin
        AUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(FUnitProductions.GetItem(I).FUnitIndex));
        Priority := Predictor.Usefullness(AUnit);
        Include := Priority and $800000 <> 0; { Original replaces the affordability check here. }
      end
      else Priority := GetUnitIndexAIPriority(FUnitProductions.GetItem(I).FUnitIndex, Player.FPlayerIndex, 0);
      if Include then Productions.AddAB(I, Priority);
    end;
  if Productions.Count <> 0 then
  begin
    Productions.SortDescendingItemB;
    Result := 0;
    Minimum := Round(Productions[0].B * 0.8);
    while (Result + 1 < Productions.Count) and (Productions[Result + 1].B >= Minimum) do Inc(Result);
    if AoWHSMap.Random(2) = 1 then Result := 0
    else Result := AoWHSMap.Random(Result + 1);
    Result := Productions[Result].A;
  end
  else Result := -1;
  Productions.Free;
  AUnit.Free;
end;

function TProductionControlList.GetPC(Index: Integer): TProductionControl;
begin
  Result := TProductionControl(List^[Index]);
end;

destructor TStructureShadow.Destroy;
begin
  if sssVisible in FShadowStatus then AoWHSMap.StaticVisibleHS.RemoveChild(Self);
  inherited Destroy;
end;

procedure TStructureShadow.SetVisible(Value: Boolean);
begin
  if Value then FShadowStatus := FShadowStatus + [sssVisible]
  else FShadowStatus := FShadowStatus - [sssVisible];
end;

function TStructureShadow.GetVisible: Boolean;
begin
  Result := sssVisible in FShadowStatus;
end;

procedure TStructureShadow.Connect;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  if not (sssConnected in FShadowStatus) then
  begin
    FShadowStatus := FShadowStatus + [sssConnected];
    Count := FStructure.GetTerrainCount;
    Level := TMapLevel(FStructure.Owner.Owner);
    InitHNWalk(Walk, FStructure.FXhx, FStructure.FYhx, 0);
    while Walk.HN < Count do
    begin
      if ((FStructure.GetTerrain(Walk.HN) >= -1) or (FStructure.GetOverlay(Walk.HN) >= -1)) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        Level.GetField(Walk.X, Walk.Y).AddHS(Self, Walk.HN);
      WalkToNextHN(Walk);
    end;
  end;
end;

procedure TStructureShadow.Disconnect;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  if sssConnected in FShadowStatus then
  begin
    Count := FStructure.GetTerrainCount;
    FShadowStatus := FShadowStatus - [sssConnected];
    Level := TMapLevel(FStructure.Owner.Owner);
    InitHNWalk(Walk, FStructure.FXhx, FStructure.FYhx, 0);
    while Walk.HN < Count do
    begin
      if ((FStructure.GetTerrain(Walk.HN) >= -1) or (FStructure.GetOverlay(Walk.HN) >= -1)) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        Level.GetField(Walk.X, Walk.Y).RemoveHS(Self);
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructureShadow.GetShowPriority: Integer;
begin
  Result := (FStructure.GetShowPriority and $03FFFFFF) + $30000000;
end;

procedure TStructureShadow.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); { Tried coordinate identity assignment; zero-shift Y argument; still differs. }
begin
  FStructure.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc);
end;

class function TStructure.ClassID: Integer;
begin
  Result := $2034A;
end;

constructor TStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FBuildingPlayer := -1;
  FFogged := True;
end;

destructor TStructure.Destroy;
begin
  if FShadow <> nil then DestroyShadow;
  if (Owner <> nil) and (moResourceLinked in FStatus) and TStructureResource(FResource).FTerrainBound then
    Owner.DestroyChildren($20106);
  inherited Destroy;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.StructureDestroyed(Self);
end;

procedure TStructure.BeginUpdate;
begin
  Inc(FUpdateCount);
end;

procedure TStructure.EndUpdate;
begin
  Dec(FUpdateCount);
  if FUpdateCount = 0 then AoWHSMap.StructureChanged(Self);
end;

procedure TStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FBuildingDays, 0);
  Stream.rwInteger(FStructureID, $62);
  Stream.rwByteEx(Byte(FBuildingPlayer), $FF, $63);
end;

function TStructure.ExecuteAI(Player: Shortint; Phase: Integer): Boolean;
begin Result := False; end;

procedure TStructure.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
end;

function TStructure.GetTerrainTypeImage(TerrainType: Integer): Integer;
begin
  if GetRazed then
    if TerrainType = 3 then Result := 23
    else if TerrainType = 5 then Result := 24
    else Result := 22
  else if GetBuilding then
    if TerrainType = 3 then Result := 26
    else if TerrainType = 5 then Result := 27
    else Result := 25
  else Result := inherited GetTerrainTypeImage(TerrainType);
end;

procedure TStructure.UpdateRoads(MapField: TMapField);
var
  Level: TMapLevel;
  Table: TWordList;
  I, X, Y: Integer;
  Road: TAbstractRoad;
begin
  Level := TMapLevel(MapField.Owner);
  Table := FResource.TerrainList.CreateSurroundingHNTable;
  for I := 0 to Table.Count - 1 do
  begin
    CenterHNtoHX(MapField.Xhx, MapField.Yhx, Table[I], X, Y);
    if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
    begin
      Road := TAbstractRoad(Level.GetField(X, Y).FindHS(TAbstractRoad));
      if Road <> nil then Road.UpdateTransitions;
    end;
  end;
  Table.Free;
end;

function TStructure.GetPlayer: Shortint;
begin
  Result := TAoWMapField(Owner).GetPlayer;
end;

function TStructure.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if not GetEditMode then UpdateRoads(TMapField(Owner));
end;

procedure TStructure.RemoveFromMap;
var
  MapField: TMapField;
begin
  MapField := TMapField(Owner);
  inherited RemoveFromMap;
  if (MapField <> nil) and not GetEditMode then UpdateRoads(MapField);
end;

procedure TStructure.CreateShadow;
begin
  if FShadow <> nil then DestroyShadow;
  FShadow := TStructureShadow.Create(nil);
  FShadow.FStructure := Self;
  FShadow.Connect;
end;

procedure TStructure.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if sssConnected in FShadow.FShadowStatus then FShadow.Disconnect;
    FShadow.Free;
    FShadow := nil;
  end;
end;

procedure TStructure.Update;
begin
  if FUpdateCount = 0 then AoWHSMap.StructureChanged(Self);
end;

function TStructure.CreateTE: TStructureTE;
begin
  Result := TStructureTE.Create(nil);
end;

procedure TStructure.SetupTE(A1: TStructureTE);
begin
  A1.Initialize(ClassID, GetXhx, GetYhx, GetLhx);
end;

function TStructure.ExecuteTE(A1: TStructureTE; Executer: TTokenExecuter): TExecuteResult;
var
  AUnit: TAbstractUnit;
begin
  if A1.FAction = -1 then
    if ExecuteRaze(A1.FParam) then Result := erDone else Result := erDoneHalt
  else if A1.FAction = -2 then
  begin
    AUnit := AoWHSMap.FUnitControl.FindUnit(A1.FParam);
    if (AUnit <> nil) and ExecuteRebuild(AUnit) then
    begin
      AUnit.Killed;
      Result := erDone;
    end
    else Result := erDoneHalt;
  end
  else Result := erDoneHalt;
end;

function TStructure.ForceTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx: ShortInt): ShortInt;
begin
  if MapLevel.Lhx <> 0 then Result := 12 else Result := -1;
end;

function TStructure.GetName: string;
begin
  Result := EditName;
end;

function TStructure.GetCurrentActivityText: string;
begin
  Result := '-';
end;

function TStructure.GetDescription: TStrings;
begin
  Result := TStructureResource(FResource).FDescription;
end;

function TStructure.CanDblClick: Boolean;
begin
  Result := False;
end;

function TStructure.CanSelect(Xhp, Yhp: Integer): Boolean;
var
  X, Y, HN: Integer;
begin
  if (not AoWHSMap.FFogEnabled) or not FFogged then
  begin
    HPtoHX(Xhp, Yhp, X, Y);
    HN := dHXtoHN(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
    if (HN >= FResource.TerrainList.Count) or
      ((FResource.TerrainList.Terrain[HN] < 0) and (FResource.TerrainList.Overlay[HN] < 0)) then
      Result := False
    else Result := True;
  end
  else Result := False;
end;

procedure TStructure.PlaySelectSample;
begin
  if not GetRazed and (TStructureResource(FResource).FSelectSFX <> '') then
    Sound.PlaySample(TStructureResource(FResource).FSelectSFX);
end;

procedure TStructure.Select; { Tried Self identity, Pointer identity, typed with; Pointer identity after inherited call; still differs. }
begin
  inherited Select;
  if not (msEditting in AoWHSMap.Status) then PlaySelectSample;
end;

procedure TStructure.Unselect;
begin
  inherited Unselect;
end;

procedure TStructure.FogChanged;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
begin
  FFogged := AoWHSMap.FFogEnabled;
  if FFogged then
  begin
    Count := GetTerrainCount;
    Level := TMapLevel(Owner.Owner);
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while (Walk.HN < Count) and FFogged do
    begin
      if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
        (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
        FFogged := WordRec(LongRec(TAoWMapField(Level.GetField(Walk.X, Walk.Y)).FFieldFlags).Hi).Lo = 0;
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructure.GetTopBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if TImageSequenceList(Integer(Sequences) shl 0).GetImageSequence(30) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(30).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetSafe(30);
end;

function TStructure.GetMiddleBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if TImageSequenceList(Integer(Sequences) shl 0).GetImageSequence(31) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(31).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetSafe(31);
end;

function TStructure.GetBottomBorderImage: TLibraryImage;
var
  Sequences: TImageSequenceList;
begin
  Sequences := FResource.ImageSequenceList;
  if Sequences <> nil then
    if TImageSequenceList(Integer(Sequences) shl 0).GetImageSequence(32) <> nil then
      Result := FResource.ImageSequenceList.GetImageSequence(32).GetPreviewImage
    else Result := nil
  else Result := FResource.ImageLibrary.GetSafe(32);
end;

function TStructure.GetOverlay(Index: Integer): Shortint;
begin
  Result := FResource.TerrainList.Terrain[Index];
  if Result >= 0 then Result := 7;
end;

function TStructure.GetTerrain(Index: Integer): ShortInt;
begin
  Result := FResource.TerrainList.Terrain[Index];
  if Result >= 0 then Result := FTerrainType;
end;

function TStructure.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin
  Result := TStructureResource(FResource).FTerrainBound or inherited CanChangeTerrain(Info);
end;

function TStructure.ValidTerrainType(TerrainType: Integer): Boolean;
begin
  Result := (TStructureResource(FResource).FTerrainBound and AoWHSSet.FPadControl.FTerrainTypes[TerrainType]) or inherited ValidTerrainType(TerrainType);
end;

procedure TStructure.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    if TStructureResource(FResource).FTerrainBound then
    begin
      FTerrainType := Info.TerrainType;
      FImageIndex := GetTerrainTypeImage(FTerrainType);
    end
    else inherited TerrainChanged(Info);
end;

function TStructure.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  if TStructureResource(FResource).FTerrainBound then
    Result := AoWHSSet.FPadControl.CanPlacePad(Xhx, Yhx, Lhx, TStructureResource(FResource).FFlagType)
  else Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx);
end;

function TStructure.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
var
  Pad: TILTerrainMO;
begin
  if GetEditMode or CanPlace(MapContainer, Xhx, Yhx, Lhx) then
    if TStructureResource(FResource).FTerrainBound then
    begin
      if not GetEditMode then
        Pad := AoWHSSet.FPadControl.PlacePad(Xhx, Yhx, Lhx, TStructureResource(FResource).FFlagType)
      else Pad := nil;
      if (Pad <> nil) or GetEditMode then
      begin
        if Pad <> nil then FTerrainType := Pad.TerrainType;
        Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
      end
      else Result := False;
    end
    else Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx)
  else Result := False;
end;

function TStructure.GetRazeable: Boolean;
begin
  Result := TStructureResource(FResource).FRazeable;
end;

function TStructure.GetRazed: Boolean;
begin
  Result := False;
end;

procedure TStructure.SetRazed(Value: Boolean);
begin end;

function TStructure.VisibleForPlayer(Player: Shortint): Boolean;
var
  Walk: THNWalkData;
begin
  Result := False;
  if Player >= 0 then
  begin
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while (Walk.HN < GetTerrainCount) and not Result do
    begin
      if FResource.TerrainList.Used[Walk.HN] then
        Result := AoWHSMap.VisibleForPlayer(Walk.X, Walk.Y, GetLhx, Player);
      WalkToNextHN(Walk);
    end;
  end;
end;

function TStructure.ValidateObservation(Player: Shortint): Boolean;
var
  Walk: THNWalkData;
  Level: TMapLevel;
begin
  Result := False;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < GetTerrainCount) and not Result do
  begin
    if FResource.TerrainList.Used[Walk.HN] and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      Result := AoWHSMap.ValidateObservation(Player, Walk.X, Walk.Y, GetLhx, 0);
    WalkToNextHN(Walk);
  end;
end;

function TStructure.ExecuteRebuild(AUnit: TAbstractUnit): Boolean;
var
  Time, Cost: Integer;
  Reason: string;
begin
  if CanRebuild(AUnit, Reason) then
  begin
    GetRebuildInfo(Cost, Time);

    AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).SetGems(AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems - Cost);
    FBuildingDays := Time;
    FBuildingPlayer := AUnit.FPlayer;
    ValidateObservation(AUnit.FPlayer);
    FImageIndex := GetTerrainTypeImage(FTerrainType); Result := True;
  end else Result := False;
end;

function TStructure.ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean;
begin
  FBuildingDays := Days;
  FBuildingPlayer := AUnit.FPlayer;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
  ValidateObservation(AUnit.FPlayer);
  Result := True;
end;

function TStructure.GetBuilding: Boolean;
begin
  Result := FBuildingPlayer <> -1;
end;

procedure TStructure.BuildingDone;
var
  Log: TLocationTextEventLog;
begin
  Log := TLocationTextEventLog.Create(nil);
  Log.FPlayer := FBuildingPlayer;
  if GetRazed then Log.FText := Format(TranslateRStr(StructureRebuiltRStr), [EditName])
  else Log.FText := Format(TranslateRStr(StructureBuiltRStr), [EditName]);
  Log.SetLocation(GetXhx, GetYhx, GetLhx);
  DistributeLocationEventLog(Log, FBuildingPlayer, GetXhx, GetYhx, GetLhx, False);
  Log.Release;
  SetRazed(False);
  FBuildingPlayer := -1;
  FImageIndex := GetTerrainTypeImage(FTerrainType);
end;

procedure TStructure.GetRebuildInfo(var Cost, Time: Integer);
begin
  Cost := TStructureResource(FResource).FRebuildGold;
  Time := TStructureResource(FResource).FRebuildDays;
end;




function TStructure.CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean;
var
  Cost, Time: Integer;
begin
  if GetRazed then
    if not GetBuilding then
    begin
      GetRebuildInfo(Cost, Time);
      if AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems >= Cost then Result := True
      else
      begin
        Reason := TranslateRStr(NotEnoughGoldRStr);
        Result := False;
      end;
    end
    else Result := False
  else Result := False;
end;

function TStructure.Rebuild(AUnit: TAbstractUnit): Boolean;
var
  Reason: string;
  Event: TStructureTE;
begin
  if CanRebuild(AUnit, Reason) and not AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).GetBusy then
  begin
    Event := CreateTE;
    SetupTE(Event);
    Event.FAction := -2;
    Event.FParam := AUnit.FUnitID;
    AoWHSMap.FTokenManager.GetTokenControl(AUnit.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TStructure.NewDay;
begin end;

procedure TStructure.NewTurn(Player: Shortint);
begin
  if Player = FBuildingPlayer then
  begin
    if FBuildingDays <> 0 then Dec(FBuildingDays);
    if FBuildingDays = 0 then BuildingDone;
  end;
end;

procedure TStructure.ArmyPlaced(A1: TArmyHS);
begin end;

procedure TStructure.ArmyRemoved(Army: TArmyHS);
begin end;

procedure TStructure.ArmyChanged(Army: TArmyHS);
begin end;

procedure TStructure.SeatedPlayerChanged;
begin
  FogChanged;
end;

function TStructure.GetDefensePriority: TDefensePriority;
begin Result := dpNone; end;

function TStructure.GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements): Boolean;
begin Result := False; end;

function TStructure.ListUnits(List: TUnitList): Integer;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
  Army: TArmyHS;
begin
  Result := 0;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := TAoWMapField(Level.GetField(Walk.X, Walk.Y)).GetArmyHS;
      if Army <> nil then
      begin
        List.AddUnits(Army.FArmy);
        Inc(Result, Army.FArmy.Count);
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TStructure.ListArmies(List: TArmyHSList): Integer;
var
  Walk: THNWalkData;
  Count: Integer;
  Level: TMapLevel;
  Army: TEObject;
begin
  List.BeginUpdate;
  Result := 0;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217);
      if Army <> nil then
      begin
        List.AddChild(Army);
        Inc(Result);
      end;
    end;
    WalkToNextHN(Walk);
  end;
  List.EndUpdate;
end;

function TStructure.ValidateMap(Messages: TStrings): Boolean;
begin
  Result := True;
end;

function TStructure.MainValidateMap(Messages: TStrings): Boolean;
var
  Errors: TStringList;
  I: Integer;
begin
  Errors := TStringList.Create;
  Result := ValidateMap(Errors);
  if Errors.Count <> 0 then
  begin
    Messages.Add(Format(TranslateRStr(XatLocationYRStr), [EditName,
      '(' + IntToStr(GetXhx) + ', ' + IntToStr(GetYhx) + ', ' + IntToStr(GetLhx) + ')']));
    for I := 0 to Errors.Count - 1 do Messages.Add('  ' + Errors[I]);
  end;
  Errors.Free;
end;

procedure TStructure.Activate;
begin
  inherited Activate;
  AoWHSMap.FStructureControl.Register(Self);
  if AoWHSMap.FShowUnitShadows and TStructureResource(FResource).FCastsShadow and not GetEditMode then
    CreateShadow;
end;

procedure TStructure.Deactivate;
begin
  AoWHSMap.FStructureControl.Unregister(Self);
  inherited Deactivate;
end;

procedure TStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); { Tried Self identity, Pointer identity, typed with; parameter spill or local lifetime/receiver staging; still differs. }
begin
  inherited MapFieldMsgProc(Msg);
  if FResource.TerrainList.Terrain[Msg.HN] >= 0 then
    if Msg.MsgID = $1106 then FogChanged
    else if Msg.MsgID = $1200 then
    begin
      UpdateAITarget(TAITargetInfo(Pointer(Msg.Param[0])^), TAITargetData(Pointer(Msg.Param[1])^));
      if TAITargetData(Pointer(Msg.Param[1])^).Priority < 0 then Msg.Result := 1;
    end
    else if Msg.MsgID = $1124 then ArmyChanged(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1102 then ArmyPlaced(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1103 then ArmyRemoved(TArmyHS(Msg.Param[0]))
    else if Msg.MsgID = $1131 then
    begin
      if TStructureResource(FResource).FConnectRoads then Msg.Param[1] := 1;
    end
    else if Msg.MsgID = $1122 then Msg.Result := TStructureResource(FResource).FScannerIcon
    else if Msg.MsgID = $1126 then Msg.Result := Ord(GetDefensePriority)
    else if Msg.MsgID = $1127 then
    begin
      if GetDefenseRequirements(Msg.Param[0], TDefenseRequirements(Pointer(Msg.Param[1])^)) then Msg.Result := 1;
    end
    else if (Msg.MsgID = $110C) and (Msg.HN = 0) then
    begin
      if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and ((not AoWHSMap.FFogEnabled) or not FFogged) then
        Inc(Msg.Param[0], $E00);
    end;
end;

procedure TStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); { Tried Self identity, Pointer identity, typed with; base sender cast; still differs. }
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020001 then NewDay
  else if Msg.MsgID = $20020002 then NewTurn(Shortint(Msg.Value))
  else if Msg.MsgID = $20020006 then SeatedPlayerChanged
  else if Msg.MsgID = $20020103 then
    if not MainValidateMap(TStrings(Msg.Value)) then Msg.Data[0] := 1;
end;

procedure TStructure.ShowShadow(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  FResource.ImageSequenceList.Show(90, Xhp - XhpSurf, Yhp - YhpSurf, 0, SurfaceDesc);
end;

procedure TStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  TStructureResource(FResource).Show(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc, Self);
end;

function TStructure.ShowBorderImage(SurfaceDesc: TSurfaceDesc; R: TRect): Boolean;
var
  TopImage, MiddleImage, BottomImage: TLibraryImage;
  Height, Y, I: Integer;
begin
  Result := False;
  if GetTopBorderImage <> nil then
  begin
    if SurfaceDesc.ClipRect.Right > R.Right then SurfaceDesc.ClipRect.Right := R.Right;
    if SurfaceDesc.ClipRect.Bottom > R.Bottom then SurfaceDesc.ClipRect.Bottom := R.Bottom;
    Height := R.Bottom - R.Top;
    TopImage := GetTopBorderImage;
    MiddleImage := GetMiddleBorderImage;
    BottomImage := GetBottomBorderImage;
    if (BottomImage <> nil) and (TopImage <> nil) and (MiddleImage <> nil) then
    begin
      { Original uses the height, rather than R.Bottom, for the bottom image. }
      BottomImage.Show(R.Left, Height - BottomImage.Height, SurfaceDesc);
      if Height > BottomImage.Height then
      begin
        Y := R.Bottom - BottomImage.Height - MiddleImage.Height;
        I := (Height - BottomImage.Height) div MiddleImage.Height; for I := 0 to I do
        begin
          MiddleImage.Show(R.Left, Y, SurfaceDesc);
          Dec(Y, MiddleImage.Height);
        end;
        TopImage.Show(R.Left, R.Top, SurfaceDesc);
      end;
      Result := True;
    end;
  end;
end;

function TStructure.ShowBorderImageDC(DC: HDC; R: TRect): Boolean;
var
  Surface: TDIB16Surface; Width, Height: Integer;
  SurfaceDesc: TSurfaceDesc; BorderRect: TRect;
begin
  Result := False;
  if GetBottomBorderImage <> nil then
  begin
    Width := R.Right - R.Left; Height := R.Bottom - R.Top; Surface := TDIB16Surface.Create(Width, Height, pfRGB565);
    try

      BorderRect := Rect(0, 0, Width, Height); Surface.Lock(SurfaceDesc); Result := ShowBorderImage(SurfaceDesc, BorderRect);
      Surface.Unlock;
      Surface.BltDC(DC, nil, @R);
    finally
      Surface.Free;
    end;
  end;
end;

function TStructure.CanRaze(Player: Shortint; var Reason: string): Boolean;
var
  Predictor: TCombatPredictor;
  Defenders, Units: TUnitList;
  I: Integer;
begin
  if not GetRazed and GetRazeable then
  begin
    Predictor := TCombatPredictor.Create;
    Defenders := TUnitList.Create(nil);
    Units := TUnitUserList.Create(nil);
    ListUnits(Units);
    for I := 0 to Units.Count - 1 do
      if Units.GetUnit(I).FPlayer = Player then Predictor.AddUnit(Units.GetUnit(I));
    Units.Free;
    GenerateRazeDefenders(Player, Defenders);
    for I := 0 to Defenders.Count - 1 do Predictor.AddOpponent(Defenders.GetUnit(I), 0);
    Predictor.Execute;
    Result := (Predictor.FResult in [3, 4, 6]) and (Predictor.GetSuperiority > 50);
    if not Result then Reason := TranslateRStr(NotEnoughForcesRStr);
    Defenders.Free;
    Predictor.Free;
  end
  else Result := False;
end;

function TStructure.GenerateRazeDefenders(Player: Shortint; Units: TUnitList): Boolean;
var
  Collection: Integer;
  Indexes: TUnitIndexList;
  I: Integer;
begin
  RandSeed := GetXhx + AoWHSMap.FInitialRandomSeed + GetYhx;
  Collection := TStructureResource(FResource).FDefenders.GetRndCollection;
  if Collection <> -1 then
  begin
    Indexes := TUnitIndexList.Create;
    with TStructureResource(FResource).FDefenders do
      for I := GetCollectionCount(Collection) - 1 downto 0 do Indexes.Add(GetU(Collection, I));
    FillWithRandomUnits(Indexes, Units, 4, TStructureResource(FResource).FRazeDefenderBudget,
      [utHumanoid, utCreature, utMachine]);
    while Units.Count > 8 do Units.DeleteUnit(Units.GetUnit(Units.Count - 1));
    Indexes.Free;
  end;
  Result := True;
end;

procedure TStructure.SetupRazeDefenderAG(Attackers, Defenders: TUnitList);
var
  Group: THuntAG;
  I: Integer;
begin
  Group := THuntAG(AoWHSMap.FAIGroupManager.CreateGroup(0, UnitsToIndependentRelation(Defenders, 5), gbHunt));
  Group.AddUnits(Defenders);
  for I := Attackers.Count - 1 downto 0 do
    if Attackers.GetUnit(I).FPlayer <> 0 then Group.FTargetUnitIDs.Add(Attackers.GetUnit(I).FUnitID);
  Group.Release;
end;

function TStructure.PlaceRazeDefenders(Player: Shortint): Boolean;
var
  Defenders, Placed, Attackers: TUnitList;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Defenders := TUnitList.Create(nil);
  Placed := TUnitUserList.Create(nil);
  Attackers := TUnitUserList.Create(nil);
  GenerateRazeDefenders(Player, Defenders);
  if Defenders.Count <> 0 then
  begin
    for I := Defenders.Count - 1 downto 0 do
    begin
      AUnit := Defenders.GetUnit(I);
      Placed.AddUnit(AUnit);
      AUnit.Place(GetXhx, GetYhx, GetLhx, 0, [pmScanArea]);
    end;
    ListUnits(Attackers);
    SetupRazeDefenderAG(Attackers, Placed);
    Result := True;
  end
  else Result := False;
  Attackers.Free;
  Placed.Free;
  Defenders.Free;
end;

procedure TStructure.ShowRazeAnimation(Animation: TAnimation; X, Y: Integer; const SurfaceDesc: TSurfaceDesc); { Tried with animation receiver; same animation cast for frame argument; still differs. }
begin
  if (TImageSequenceAnimation(Animation).FImageSequence.GetUnloopedFrameIndex(Animation.FFrameCounter) = 0) and
    (AoWEngine.FAnimationDetail <> Byte(dtlLow)) then Sound.PlaySample(ExplosionSFX[System.Random(2)]);
end;

function TStructure.ExecuteRaze(Player: Shortint): Boolean;
var
  Reason: string;
  Log: TLocationTextEventLog;
  Animation: TImageSequenceAnimation;
begin
  if CanRaze(Player, Reason) then
  begin
    BeginUpdate;
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := Player;
    Log.FText := Format(TranslateRStr(StructureRazedRStr), [EditName]);
    Log.SetLocation(GetXhx, GetYhx, GetLhx);
    DistributeLocationEventLog(Log, Player, GetXhx, GetYhx, GetLhx, False);
    Log.Release;
    if FResource.ImageSequenceList.GetImageSequence(20) <> nil then
    begin
      Animation := TImageSequenceAnimation.Create(nil);
      Animation.SetImageSequence(FResource.ImageSequenceList.GetImageSequence(20));
      Animation.SetXhpOffset(Animation.FXhpOffset - 16);
      Animation.SetYhpOffset(Animation.FYhpOffset - 16);
      Animation.FOnShow := ShowRazeAnimation;
      AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
    end;
    if FResource.ImageSequenceList.GetImageSequence(21) <> nil then
    begin
      Animation := TImageSequenceAnimation.Create(nil);
      Animation.SetImageSequence(FResource.ImageSequenceList.GetImageSequence(21));
      Animation.FFrameCount := 300;
      Animation.SetXhpOffset(Animation.FXhpOffset - 16);
      Animation.SetYhpOffset(Animation.FYhpOffset - 16);
      Animation.FLooped := True;
      AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
    end;
    ValidateObservation(Player);
    SetRazed(True);
    PlaceRazeDefenders(Player);
    EndUpdate;
    Result := True;
  end
  else Result := False;
end;

function TStructure.RazeEx(Player: Shortint): Boolean;
var
  Reason: string;
  Event: TStructureTE;
begin
  if CanRaze(Player, Reason) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
  begin
    Event := CreateTE;
    SetupTE(Event);
    Event.FAction := -1;
    Event.FParam := Player;
    AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TStructure.Raze(Player: Shortint): Boolean;
var
  Reason: string;
  Log: TRazeStructureEventLog;
begin
  if CanRaze(Player, Reason) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      Log := TRazeStructureEventLog.Create(nil);
      Log.FStructure := Self;
      Log.FButtons := mebYesNo;
      Log.FTitle := TranslateRStr(WarningRStr);
      Log.FMessage.Add(TranslateRStr(RazeStructureWarningRStr));
      Log.FMessage.Add(TranslateRStr(DoYouWishToContinueRStr));
      Log.Execute(True, etUser, nil);
      Log.Release;
      Result := True;
    end
    else Result := RazeEx(Player);
  end
  else Result := False;
end;

procedure TStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $08000000;
end;

constructor TStructureResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(26);
  FConnectRoads := True;
  FTerrainBound := True;
  FDescription := TStringList.Create;
  FDefenders := TUnitIndexListCollection.Create;
  FRazeDefenderBudget := 50;
  FRazeable := False;
end;

destructor TStructureResource.Destroy;
begin
  FDescription.Free;
  FDefenders.Free;
  inherited Destroy;
end;

class function TStructureResource.ClassID: Integer;
begin Result := $2034B; end;

class function TStructureResource.ResourceEditName: string;
begin Result := ''; end;

function TStructureResource.ResourceUserClassID: Integer;
begin Result := $2034A; end;

procedure TStructureResource.CalculatePadIndex;
var
  I: Integer;
begin
  FFlagType := 0;
  for I := 0 to FTerrainList.Count - 1 do
    if FTerrainList.Terrain[I] >= 0 then Inc(FFlagType);
end;

procedure TStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwBool(FSelectSFXLooped, 20);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FSelectSFX, 21);
  Stream.rwStrings(FDescription, 22);
  Stream.rwInteger(FScannerIcon, 23);
  Stream.rwStreamProc(28, FDefenders.LoadFromStream, FDefenders.SaveToStream);
  if smRead in Stream.StorageMode then CalculatePadIndex;
end;

procedure TStructureResource.Show(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; Structure: TStructure);
var
  Index, Offset, FrameIndex: Integer;
  Sequence: TImageSequence;
begin
  if Structure.GetSelected and (AoWHSMap.Frame and 6 = 6) then
  begin
    Index := Structure.ImageIndex;
    Offset := TMapField(Structure.Owner).Xhx + TMapField(Structure.Owner).Yhx * 16;
    if FImageSequenceList <> nil then
    begin
      Sequence := FImageSequenceList.List^[Index];
      while Sequence <> nil do
      begin
        FrameIndex := Sequence.GetFrameIndex(AoWHSMap.Frame, Offset);
        if FrameIndex <> -1 then
          if Sequence.ImageLibrary[FrameIndex].ShowInfo.ShowMode = smOpaque then
            Sequence.ImageLibrary[FrameIndex].ShowTransparent(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc)
          else Sequence.ImageLibrary[FrameIndex].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
    end
    else FImageLibrary[Index].ShowTransparent(X + FdXImage, Y + FdYImage, SurfaceDesc);
  end
  else
    if FImageSequenceList = nil then FImageLibrary[Structure.ImageIndex].Show(X, Y, SurfaceDesc)
    else ShowComplexImage(X, Y, SurfaceDesc, Structure.ImageIndex,
      TMapField(Structure.Owner).Xhx + TMapField(Structure.Owner).Yhx * 16);
end;

constructor TPlayerStructure.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FVictoryLocations := TBitList.Create;
  FUnfogRange := 0;
end;

destructor TPlayerStructure.Destroy;
begin
  inherited Destroy;
  FVictoryLocations.Free;
end;

class function TPlayerStructure.ClassID: Integer;
begin Result := $2034C; end;

function TPlayerStructure.GetVictoryLocation(Player: Shortint): Boolean;
begin
  Result := FVictoryLocations[Player];
end;

procedure TPlayerStructure.SetVictoryLocation(Player: Shortint; Value: Boolean);
begin
  if FVictoryLocations[Player] <> Value then
  begin
    FVictoryLocations[Player] := Value;
    if Value then AoWHSMap.FPlayers.GetPlayers(Player).RegisterVictoryLocation(Self)
    else AoWHSMap.FPlayers.GetPlayers(Player).UnregisterVictoryLocation(Self);
    Update;
  end;
end;

procedure TPlayerStructure.RegisterVictoryLocations;
var
  I: Integer;
begin
  for I := 1 to FVictoryLocations.Count - 1 do
    if FVictoryLocations[I] then
      if AoWHSMap.FPlayers.GetPlayers(I) <> nil then
        AoWHSMap.FPlayers.GetPlayers(I).RegisterVictoryLocation(Self)
      else FVictoryLocations[I] := False;
end;

procedure TPlayerStructure.UnregisterVictoryLocations;
var
  I: Integer;
begin
  for I := 1 to FVictoryLocations.Count - 1 do
    if FVictoryLocations[I] and (AoWHSMap.FPlayers.GetPlayers(I) <> nil) then
      AoWHSMap.FPlayers.GetPlayers(I).UnregisterVictoryLocation(Self);
end;

procedure TPlayerStructure.BuildingDone;
begin
  inherited BuildingDone;
  UpdatePlayer;
  UpdateExploration;
  UpdateUnfog;
end;

function TPlayerStructure.CanRebuild(AUnit: TAbstractUnit; var Reason: string): Boolean;
begin
  Result := inherited CanRebuild(AUnit, Reason);
end;

function TPlayerStructure.ExecuteRebuild(AUnit: TAbstractUnit): Boolean;
begin
  Result := inherited ExecuteRebuild(AUnit);
  if Result then SetPlayer(AUnit.FPlayer);
end;

function TPlayerStructure.ExecuteBuild(AUnit: TAbstractUnit; Days: Integer): Boolean;
begin
  Result := inherited ExecuteBuild(AUnit, Days);
  if Result then SetPlayer(AUnit.FPlayer);
end;

function TPlayerStructure.UpdatePlayer: Boolean;
var
  Player: Shortint;
  Different: Boolean;
  Count: Integer;
  Level: TMapLevel;
  Walk: THNWalkData;
  Army: TArmyHS;
begin
  Player := -1;
  Different := False;
  Count := GetTerrainCount;
  Level := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while (Walk.HN < Count) and not Different do
  begin
    if (FResource.TerrainList.Terrain[Walk.HN] >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Army := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if Army <> nil then
        if Player <> -1 then Different := Army.FArmy.FPlayer <> Player
        else Player := Army.FArmy.FPlayer;
    end;
    WalkToNextHN(Walk);
  end;
  if Player <> -1 then
    if Different then SetPlayer(-1) else SetPlayer(Player);
  Result := not Different;
end;

procedure TPlayerStructure.NewTurn(Player: Shortint);
begin
  inherited NewTurn(Player);
  if (Player = FPlayer) and (FProductionPriority <> $FF) then Inc(FProductionPriority);
end;

procedure TPlayerStructure.NewDay;
begin
  inherited NewDay;
  if (AoWHSMap.FDay = 1) and (FPlayer > 0) then
  begin
    UpdateExploration;
    UpdatePlayerSeen;
  end;
end;

procedure TPlayerStructure.StructureCaptured(OldPlayer, NewPlayer: Shortint);
var
  Log: TLocationTextEventLog;

begin
  if not GetRazed and not GetBuilding and (OldPlayer = 0) and
    not (msEditting in AoWHSMap.Status) and (moActivated in FStatus) and
    not TPlayerStructureResource(FResource).FClaimed then
  begin
    Log := TLocationTextEventLog.Create(nil);
    Log.FPlayer := NewPlayer;
    Log.FText := Format(TranslateRStr(StructureCapturedRStr), [EditName]);

    Log.FXhx := GetXhx;
    Log.FYhx := GetYhx;
    Log.FLhx := GetLhx;
    DistributeLocationEventLog(Log, FPlayer, GetXhx, GetYhx, GetLhx, False);
    Log.Release;
  end;
end;

function TPlayerStructure.GetCombatEventText(Combat: TCombat): string;
begin
  if not GetRazed then
    if (Combat.FCombatResult = crVictory) or (Combat.FCombatResult = crNoDefenders) then
      Result := Format(TranslateRStr(StructureCapturedRStr), [EditName])
    else Result := '';
  { Original leaves the result unchanged for a razed structure. }
end;

procedure TPlayerStructure.FinalizeCombat(Combat: TCombat);
begin
  if (Combat.FCombatResult = crVictory) or (Combat.FCombatResult = crNoDefenders) then
    SetPlayer(Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FAttackerPlayer).FPlayer);
end;

procedure TPlayerStructure.SetPlayer(Player: Shortint);
var
  I: Integer;
begin
  if Player <> FPlayer then
  begin
    if GetRazed and not GetBuilding then Exit;
    FProductionPriority := 0;
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.RemoveChild(Self);
    if AoWHSMap.FDay > 0 then StructureCaptured(FPlayer, Player);
    FPlayer := Player;
    UpdateUnfog;
    UpdatePlayerSeen;
    UpdateExploration;
    AoWHSMap.ScannerIconsChangedRad(GetXhx, GetYhx, GetLhx, HNtoRad(FResource.TerrainList.Count));
    UpdateFlagID;
    FogChanged;
    AoWHSMap.NotifyPlayerChanged(GetXhx, GetYhx, GetLhx);
    if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.AddChild(Self);
    if (FPlayer > 0) and (AoWHSMap.FVictoryCondition = vcCaptureLocations) then
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        if FVictoryLocations[I] then
          if (I = FPlayer) or (AoWHSMap.FAlliedVictory and
            (AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayer, I) = drAlliance)) then
            AoWHSMap.FPlayers.GetPlayers(I).CheckCaptureLocations;
    Update;
  end;
end;

procedure TPlayerStructure.UpdateFlagID;
begin
  if not (moEditMode in FStatus) then
    if FPlayer > 0 then FFlagID := AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace
    else if TPlayerStructureResource(FResource).FClaimed then FFlagID := $20
    else FFlagID := $3F
  else FFlagID := $3F;
end;

procedure TPlayerStructure.ArmyPlaced(A1: TArmyHS);
begin UpdatePlayer; end;

procedure TPlayerStructure.ArmyChanged(Army: TArmyHS);
begin UpdatePlayer; end;

function TPlayerStructure.GetIncome: Integer;
begin Result := 0; end;

function TPlayerStructure.GetPower: Integer;
begin Result := 0; end;

procedure TPlayerStructure.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 5);
  Stream.rwStreamProc(6, FVictoryLocations.LoadFromStream, FVictoryLocations.SaveToStream);
  Stream.rwByte(FProductionPriority, 7);
end;

procedure TPlayerStructure.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  if (FFlagID <> $3F) and ((not AoWHSMap.FFogEnabled) or not FFogged) then
    with TPlayerStructureResource(FResource) do
      if FFlagType <= 1 then
        AoWHSSet.FFlagControl.ShowFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
          Engine.HSMap.Frame + Xhp, FFlagID, SurfaceDesc)
      else FFlagControl.ShowStructureFlag(FFlagX + XhpSurf, FFlagY + YhpSurf,
          Engine.HSMap.Frame + Xhp, FFlagID, SurfaceDesc);
  TPlayerStructureResource(FResource).Show(XhpSurf, YhpSurf, SurfaceDesc, Self);
end;

function TPlayerStructure.TrueVisionRange: Integer;
begin Result := 1; end;

function TPlayerStructure.VisibilityRange: Integer;
begin
  if not GetBuilding then
  begin
    Result := 6;
    if (GetLhx <> 0) or ((FPlayer > 0) and
      (Byte(AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FEnemyEnchantments) and 8 <> 0)) then
      Result := (Result + 1) shr 1;
  end
  else Result := 4;
end;

procedure TPlayerStructure.UpdatePlayerSeen;
var
  I, X, Y: Integer;
begin
  if (moPlacedOnMap in FStatus) and (FPlayer > 0) then
    for I := 0 to FResource.TerrainList.Count - 1 do
      if FResource.TerrainList.Terrain[I] >= 0 then
      begin
        CenterHNtoHX(FXhx, FYhx, I, X, Y);
        AoWHSMap.UpdatePlayerSeen(FPlayer, X, Y, GetLhx, VisibilityRange, TrueVisionRange);
      end;
end;

procedure TPlayerStructure.UpdateExploration;
var
  Player, I, X, Y: Integer;
begin
  if (moPlacedOnMap in FStatus) and (FPlayer > 0) then
    for Player := 1 to AoWHSMap.FPlayers.Count - 1 do
      if (Player = FPlayer) or
        (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Player) = drAlliance) then
        for I := 0 to FResource.TerrainList.Count - 1 do
          if FResource.TerrainList.Terrain[I] >= 0 then
          begin
            CenterHNtoHX(FXhx, FYhx, I, X, Y);
            AoWHSMap.ExploreArea(X, Y, TMapField(Owner).Lhx, Player, VisibilityRange);
          end;
end;

procedure TPlayerStructure.UpdateUnfog;
var
  Range, I, X, Y: Integer;
begin
  if not (moPlacedOnMap in FStatus) then Exit;
  if (moActivated in FStatus) and (FPlayer <> -1) and (AoWHSMap.FSeatedPlayer <> -1) and
    ((AoWHSMap.FSeatedPlayer = FPlayer) or
    (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(AoWHSMap.FSeatedPlayer) = drAlliance)) then
    Range := VisibilityRange
  else Range := 0;
  if Range <> FUnfogRange then
  begin
    if FUnfogRange <> 0 then
      for I := 0 to FResource.TerrainList.Count - 1 do
        if FResource.TerrainList.Terrain[I] >= 0 then
        begin
          CenterHNtoHX(FXhx, FYhx, I, X, Y);
          AoWHSMap.FogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
        end;
    FUnfogRange := Range;
    if FUnfogRange <> 0 then
      for I := 0 to FResource.TerrainList.Count - 1 do
        if FResource.TerrainList.Terrain[I] >= 0 then
        begin
          CenterHNtoHX(FXhx, FYhx, I, X, Y);
          AoWHSMap.UnFogArea(X, Y, TMapField(Owner).Lhx, FUnfogRange);
        end;
  end;
end;

procedure TPlayerStructure.SeatedPlayerChanged;
begin
  inherited SeatedPlayerChanged;
  UpdateUnfog;
end;

procedure TPlayerStructure.Activate;
begin
  inherited Activate;
  UpdateFlagID;
  UpdateUnfog;
  RegisterVictoryLocations;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.AddChild(Self);
end;

procedure TPlayerStructure.Deactivate;
begin
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FStructures.RemoveChild(Self);
  UnregisterVictoryLocations;
  inherited Deactivate;
  UpdateUnfog;
end;

procedure TPlayerStructure.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    if not GetRazed and (FPlayer <> -1) and (TMoveControl(Info.Sender).FPlayer <> FPlayer) and
      (Info.MoveOverCode <> 1) then
    begin
      MoveResult.Code := -1;
      MoveResult.Done := True;
    end;
end;

function TPlayerStructure.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if (FResource.TerrainList.Terrain[Info.HN] >= 0) and (not GetRazed or GetBuilding) then
  begin
    if FPlayer = 0 then
      if (TMoveControl(Info.Sender).FPlayer = FPlayer) or not TPlayerStructureResource(FResource).FClaimed then
        Result := 1
      else Result := 0
    else
      if (TMoveControl(Info.Sender).FPlayer = FPlayer) or (FPlayer = -1) then Result := 1
      else Result := 0;
  end
  else Result := 1;
end;

procedure TPlayerStructure.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); { Tried Self identity, Pointer identity, typed with; base sender cast; still differs. }
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    if AoWHSMap.FPlayers.GetNumberOfPlayers < FPlayer then SetPlayer(0);
    UpdateFlagID;
  end
  else if Msg.MsgID = $20020008 then
  begin
    UpdateExploration;
    UpdateUnfog;
  end;
end;

procedure TPlayerStructure.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.Terrain[Info.HN] >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $1000 or $2000 or $4000 or $2000000 or $1000000 or $8000000;
end;

function TPlayerStructure.GetDefaultAITargetPriority: Integer;
begin Result := 10; end;

procedure TPlayerStructure.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
begin
  if GetRazed and not GetBuilding then Exit;
  case Info.Mode of
    tmAttack:
      if (Info.Player <> FPlayer) and not GetRazed then
        if (FPlayer = 0) or ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, 0) then
          Data.Priority := GetDefaultAITargetPriority;
  end;
end;

function TPlayerStructure.GetMoveAction(Player: Shortint; Action: TMoveAction): TMoveAction;
begin
  if (Player <> FPlayer) and not GetRazed and
    ((FPlayer <> 0) or TPlayerStructureResource(FResource).FClaimed) then Result := maAttack
  else Result := Action;
end;

procedure TPlayerStructure.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID = $110C) and (Msg.HN = 0) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
  begin
    if (not AoWHSMap.FFogEnabled) or not FFogged then
    begin
      if FPlayer >= 0 then
        if FPlayer > 0 then
          Inc(Msg.Param[0], (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace + 1) * $100)
        else Inc(Msg.Param[0], $D00)
      else Inc(Msg.Param[0], $E00);
      if (AoWHSMap.FVictoryCondition = vcCaptureLocations) and FVictoryLocations[AoWHSMap.FSeatedPlayer] then
        Msg.Param[0] := Msg.Param[0] or $1000000;
    end
    else Inc(Msg.Param[0], $E00);
  end
  else inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $1100 then
  begin
    if (FResource.TerrainList.Terrain[Msg.HN] >= 0) and not GetRazed then
      if FPlayer = 0 then
        if TPlayerStructureResource(FResource).FClaimed then Msg.Result := 0 else Msg.Result := -1
      else Msg.Result := FPlayer;
  end
  else if (Msg.MsgID = $110D) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
  begin
    if (FPlayer > 0) and (Msg.Param[0] <= VisibilityRange) then
      AoWHSMap.UpdatePlayerSeen(FPlayer, Msg.MapField.Xhx, Msg.MapField.Yhx, Msg.MapField.Lhx,
        Msg.Param[0], TrueVisionRange);
  end
  else if (Msg.MsgID = $1130) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then Msg.Result := FPlayer
  else if (Msg.MsgID = $1101) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    Msg.Param[1] := Ord(GetMoveAction(Msg.Param[0], TMoveAction(Msg.Param[1])))
  else if (Msg.MsgID = $110A) and (FPlayer > 0) then
  begin
    if (FPlayer = Msg.Param[1]) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
      if Msg.Param[0] <= VisibilityRange then Msg.Result := 1;
  end;
  if (Msg.MsgID = $110B) and (FPlayer > 0) then
  begin
    if (FPlayer = Msg.Param[1]) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
      if Msg.Param[0] <= TrueVisionRange then Msg.Result := 1;
  end
  else if (Msg.MsgID = $1110) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    FinalizeCombat(TCombat(Msg.Param[0]))
  else if (Msg.MsgID = $1109) and (FResource.TerrainList.Terrain[Msg.HN] >= 0) then
    string(Pointer(Msg.Result)^) := GetCombatEventText(TCombat(Msg.Param[0]));
end;

{ TPlayerStructureResource (instance size 116; $64 claimed, $68/$6C flag position, $70 flag control). }
constructor TPlayerStructureResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FClaimed := True;
  FFlagX := 20;
  FFlagY := -35;
end;

destructor TPlayerStructureResource.Destroy;
begin
  inherited Destroy;
end;

class function TPlayerStructureResource.ClassID: Integer;
begin
  Result := $2034D;
end;

function TPlayerStructureResource.ResourceUserClassID: Integer;
begin
  Result := $2034C;
end;

procedure TPlayerStructureResource.GenerateFlagPositions;
begin
  if FTerrainBound then
    case FFlagType of
      1: begin FFlagX := 20; FFlagY := -30; end;
      2: begin FFlagX := 35; FFlagY := -50; end;
      3: begin FFlagX := 5; FFlagY := -45; end;
      4: begin FFlagX := 30; FFlagY := -60; end;
    end;
end;

procedure TPlayerStructureResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if smRead in Stream.StorageMode then GenerateFlagPositions;
end;

procedure TPlayerStructureResource.ActivateMsg;
begin
  FFlagControl := TAoWHSSet(Engine.HSSet).FFlagControl;
end;

procedure TPlayerStructureResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then ActivateMsg;
end;

function TPlayerStructureResource.PlaceResourceUser(HSMap: HSEngine.THSMap; Xhx, Yhx, Lhx: Shortint): HSEngine.TMapObject;
begin
  Result := inherited PlaceResourceUser(HSMap, Xhx, Yhx, Lhx);
  if (Result <> nil) and (msEditting in AoWHSMap.Status) then
    TPlayerStructure(Result).SetPlayer(AoWHSMap.FEditorPlayer);
end;

{ TPlayerStructureIncomeSource (instance size 12; $08 FStructure). }
procedure TPlayerStructureIncomeSource.Setup(Structure: TPlayerStructure);
begin
  FStructure := Structure;
end;

function TPlayerStructureIncomeSource.Name: string;
begin
  Result := FStructure.GetName;
end;

function TPlayerStructureIncomeSource.Income: Integer;
begin
  Result := FStructure.GetIncome;
end;

procedure TPlayerStructureIncomeSource.GetLocation(var X, Y, L: Shortint);
begin
  X := FStructure.Xhx;
  Y := FStructure.Yhx;
  L := FStructure.Lhx;
end;

{ TPlayerStructurePowerSource (instance size 12; $08 FStructure). }
procedure TPlayerStructurePowerSource.Setup(Structure: TPlayerStructure);
begin
  FStructure := Structure;
end;

function TPlayerStructurePowerSource.Name: string;
begin
  Result := FStructure.GetName;
end;

function TPlayerStructurePowerSource.Power: Integer;
begin
  Result := FStructure.GetPower;
end;

procedure TPlayerStructurePowerSource.GetLocation(var X, Y, L: Shortint);
begin
  X := FStructure.Xhx;
  Y := FStructure.Yhx;
  L := FStructure.Lhx;
end;

procedure TPlayerStructurePowerSource.Select;
begin
  AoWHSMap.Select(FStructure, True);
end;

{ TStructureTE (instance size 40; $10/$11/$12 coordinates, $13 player, $14 class ID, $18 action, $1C razed, $20/$24 parameters). }
class function TStructureTE.ClassID: Integer;
begin
  Result := $21110;
end;

procedure TStructureTE.Initialize(AClassID: Integer; X, Y, L: Shortint);
var
  MapField: TAoWMapField;
  Structure: TStructure;
begin
  FX := X;
  FY := Y;
  FL := L;
  MapField := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Structure := TStructure(MapField.FindOwnedChild(AClassID));


















































































































































































































































































































































































































































































































  Assert(AClassID = Structure.ClassID, 'Invalid position (StructureTE)');
  FStructureClassID := AClassID;
  FRazed := Structure.GetRazed;
  FPlayer := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetPlayer;
end;

procedure TStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FAction, 15);
  Stream.rwByte(Byte(FX), 16);
  Stream.rwByte(Byte(FY), 17);
  Stream.rwByte(Byte(FL), 18);
  Stream.rwByte(Byte(FPlayer), 19);
  Stream.rwInteger(FStructureClassID, 20);
  Stream.rwBool(FRazed, 21);
  Stream.rwInteger(FParam, 22);
  Stream.rwInteger(FParam2, 23);
end;

function TStructureTE.Validate: Boolean;
var
  Structure: TStructure;
  MapField: TAoWMapField;
begin
  MapField := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Structure := TStructure(MapField.FindOwnedChild(FStructureClassID));
  if (Structure <> nil) and (Structure.ClassID = FStructureClassID) then
    Result := MapField.GetPlayer = FPlayer
  else Result := False;
end;

function TStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin
  if (TE.ExecuteCount <> 0) or Validate then
    Result := TStructure(AoWHSMap.MapContainer.GetField(FX, FY, FL).
      FindOwnedChild(FStructureClassID)).ExecuteTE(Self, TE)
  else Result := erDoneHalt;
end;

{ TRazeStructureEventLog (instance size 44; $28 FStructure). }
function TRazeStructureEventLog.Yes: Boolean;
begin
  FStructure.RazeEx(AoWHSMap.FSeatedPlayer);
  Result := True;
end;

{ TConstructStructureTE (instance size 28; $10 unit ID, $14 player, $18 construction control ID). }
class function TConstructStructureTE.ClassID: Integer;
begin
  Result := $2131A;
end;

procedure TConstructStructureTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FControlID, 20);
  Stream.rwInteger(FUnitID, 21);
  Stream.rwByte(Byte(FPlayer), 22);
end;

function TConstructStructureTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  AUnit: TAbstractUnit;
  Control: TStructureConstructionControl;
  Resource: TStructureResource;
  Structure: TStructure;
  Reason, Text: string;
  Gold, Days: Integer;
  Owner: TEChangeNotifyNode;
  X, Y, L: Shortint;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  Result := erDoneHalt;
  inherited Execute(TE);
  AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  Control := TStructureConstructionControl(TConstructAbility(
    AoWHSSet.FAbilityControl.GetAbility(125)).FConstructionControls.FindID(FControlID));
  if (Control <> nil) and (AUnit <> nil) and (AUnit.FPlayer = FPlayer) and
    Control.CanConstruct(AUnit, Reason) then
  begin
    Resource := Control.StructureResource(AUnit);
    if Resource <> nil then
    begin
      AUnit.GetLocation(X, Y, L);
      Level := AoWHSMap.MapContainer.GetMapLevel(L);
      InitHNWalk(Walk, X, Y, 0);
      while Walk.HN < Resource.TerrainList.Count do
      begin
        if (Walk.X >= 0) and (Walk.Y >= 0) and (Level.Width > Walk.X) and
          (Level.Height > Walk.Y) and Resource.TerrainList.GetUsed(Walk.HN) then
          AoWHSMap.ClearTerrain(Walk.X, Walk.Y, L, 0, -1);
        WalkToNextHN(Walk);
      end;
      Owner := TEChangeNotifyNode(AUnit.Owner);
      Owner.BeginUpdate;
      Structure := TStructure(Resource.PlaceResourceUser(AoWHSMap, X, Y, L));
      if Structure <> nil then
      begin
        Control.GetInfo(AUnit, Text, Gold, Days);
        Structure.ExecuteBuild(AUnit, Days);
        AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).SetGems(
          AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FGems - Gold);
        AUnit.Killed;
        Result := erDone;
      end;
      Owner.EndUpdate;
    end;
  end;
end;

{ TStructureConstructionControl (instance size 8; no additional fields). }
function TStructureConstructionControl.StructureResource(AUnit: TAbstractUnit): TStructureResource;
{ conflict: function TStructureConstructionControl.StructureResource: TStructureResource; }
begin Result := nil; end;

function TStructureConstructionControl.ValidateLocation(AUnit: TAbstractUnit; var Reason: string): Boolean;
var
  Resource: TStructureResource;
  X, Y, L: Shortint;
  Level: TMapLevel;
  MapField: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := True;
  Resource := StructureResource(AUnit);
  AUnit.GetLocation(X, Y, L);
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Resource.TerrainList.Count > Walk.HN) and Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and
      (Walk.Y < Level.Height) then
    begin
      if Resource.TerrainList.GetUsed(Walk.HN) then
      begin
        MapField := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
        Result := (MapField.GetPlayer = -1) or (MapField.GetPlayer = AUnit.FPlayer);
        Result := Result and (MapField.FindNoneTransparentHS(TStructure) = nil);
        Result := Result and not (MapField.OverlayType in [0, 2]);
        Result := Result and (MapField.TerrainType in [1..5, 12]);
      end;
    end
    else Result := False;
    WalkToNextHN(Walk);
  end;
  if not Result then Reason := TranslateRStr(CannotBuildOnCurrentLocationRStr);
end;

function TStructureConstructionControl.CanConstruct(A1: TAbstractUnit; var A2: string): Boolean;
begin
  Result := ValidateLocation(A1, A2);
  if Result then Result := inherited CanConstruct(A1, A2) and (StructureResource(A1) <> nil);
end;

function TStructureConstructionControl.Construct(AUnit: TAbstractUnit): Boolean;
var
  Event: TConstructStructureTE;
  Reason: string;
begin
  if CanConstruct(AUnit, Reason) and not AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).GetBusy then
  begin
    Event := TConstructStructureTE.Create(nil);
    Event.FUnitID := AUnit.FUnitID;
    Event.FPlayer := AUnit.FPlayer;
    Event.FControlID := ID;
    AoWHSMap.FTokenManager.GetTokenControl(AUnit.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

{ TStructureControl (instance size 20; $08 structures, $0C next ID, $10 city count). }
constructor TStructureControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStructures := TENode.Create(nil);
  FNextID := 0;
end;

destructor TStructureControl.Destroy;
begin
  FStructures.Free;
  inherited Destroy;
end;

function TStructureControl.GetStructure(Index: Integer): TStructure;
begin
  if (Index >= 0) and (Index < GetCount) then
    Result := FStructures.FChildren.List^[Index]
  else Result := nil;
end;

function TStructureControl.GetCount: Integer;
begin
  Result := FStructures.GetCount;
end;

procedure TStructureControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FNextID, 20);
  Stream.rwInteger(FCityCount, 21);
end;

function TStructureControl.CreateUniqueID: Integer;
begin
  repeat
    Inc(FNextID);
    if FNextID > $0FFFFFFF then FNextID := 0;
  until IndexOfID(FNextID) = -1;
  Result := FNextID;
end;

function TStructureControl.IndexOfID(ID: Integer): Integer;
begin
  Result := GetCount;
  if Result <> 0 then
    repeat
      Dec(Result);
      if ID = TStructure(FStructures.FChildren.List^[Result]).FStructureID then Exit;
    until Result = 0;
  Result := -1;
end;

function TStructureControl.FindID(ID: Integer): TStructure;
var
  Index: Integer;
begin
  Index := IndexOfID(ID);
  if Index <> -1 then Result := FStructures.FChildren.List^[Index]
  else Result := nil;
end;

procedure TStructureControl.Register(Structure: TStructure);
begin
















  Assert(FStructures.FChildren.IndexOf(Structure) = -1);
  if (Structure.FStructureID = 0) or (IndexOfID(Structure.FStructureID) <> -1) then
    Structure.FStructureID := CreateUniqueID;
  FStructures.AddChild(Structure);
  if Structure.ClassID = $20108 then Inc(FCityCount);
end;

procedure TStructureControl.Unregister(Structure: TStructure);
begin
  FStructures.FChildren.Remove(Structure);
  if Structure.ClassID = $20108 then Dec(FCityCount);
end;

procedure TStructureControl.Activate;
begin
  FCityCount := 0;
end;

{ TStructureAIPA (instance size 28; $14 phase, $18 structure IDs). }
constructor TStructureAIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStructureIDs := TIntegerList.Create;
end;

destructor TStructureAIPA.Destroy;
begin
  FStructureIDs.Free;
  inherited Destroy;
end;

function TStructureAIPA.Activate: Boolean;
var
  I: Integer;
begin
  inherited Activate;
  if FControl.FPlayer.FPlayerIndex > 0 then
  begin
    for I := 0 to AoWHSMap.FStructureControl.GetCount - 1 do
      FStructureIDs.Add(AoWHSMap.FStructureControl.GetStructure(I).FStructureID);
    Result := True;
  end
  else Result := False;
end;

function TStructureAIPA.Process: Boolean;
var
  Waiting: Boolean;
  Structure: TStructure;
begin
  Waiting := False;
  while not Waiting and (FStructureIDs.Count <> 0) and
    (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) and not FControl.FPlayer.GetBusy do
  begin
    Structure := AoWHSMap.FStructureControl.FindID(FStructureIDs[FStructureIDs.Count - 1]);
    if Structure <> nil then Waiting := Structure.ExecuteAI(FControl.FPlayer.FPlayerIndex, FPhase);
    if not Waiting then FStructureIDs.Delete(FStructureIDs.Count - 1);
  end;
  Result := FStructureIDs.Count <> 0;
end;

{ TStructurePhase1AIPA (instance size 28; inherited $14 phase). }
constructor TStructurePhase1AIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPhase := 1;
end;

class function TStructurePhase1AIPA.Priority: Integer;
begin
  Result := 21;
end;

{ TStructurePhase2AIPA (instance size 28): inherited $14 FPhase. }
constructor TStructurePhase2AIPA.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPhase := 2;
end;

class function TStructurePhase2AIPA.Priority: Integer;
begin
  Result := 15;
end;

{ TFire (instance size 44): $1C mode, $1D lifetime, $1E age,
  $20 priority, $24 owner player, $28 explosion frame. }
constructor TFire.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTurnsLeft := 3;
  FAge := 0;
  FPlayer := 0;
  FShowPriority := $68000000;
  FMode := [fmExpandable];
  FExplosionFrame := 0;
end;

class function TFire.ClassID: Integer;
begin
  Result := $2077E;
end;

procedure TFire.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FTurnsLeft), 5);
  Stream.rwData(FMode, 1, 6);
  Stream.rwByte(Byte(FPlayer), 7);
  Stream.rwByte(FAge, 8);
end;

function TFire.GetTerrain(Index: Integer): ShortInt;
begin
  Result := FResource.TerrainList.GetTerrain(Index);
  if Result >= 0 then Result := -1;
end;

function TFire.GetShowPriority: Integer;
begin
  Result := FShowPriority;
end;

procedure TFire.CalcShowPriority(MapField: TMapField);
var
  X, Y: Integer;
  HS: THexagonSprite;
begin
  HXtoHP(MapField.Xhx, MapField.Yhx, X, Y);
  HS := MapField.GetMaxLevelNoneTransparentHS;
  FShowPriority := $68000000 + (Y + 36) shl 13 + (X + 16);
  if (HS <> Self) and (HS <> nil) then
    if HS.GetShowPriority >= FShowPriority then
      FShowPriority := HS.GetShowPriority + 1;
end;

function TFire.PlaceHX(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  CalcShowPriority(MapContainer.GetField(Xhx, Yhx, Lhx));
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

function TFire.GetMostFrequentMapFieldTerrainType(MapLevel: HSEngine.TMapLevel; Xhx, Yhx, Default: Shortint): Shortint;
var
  Terrains: TTerrainList;
  Counts: array[0..127] of Byte;
  Walk: THNWalkData;
  TerrainType: Shortint;
begin
  Result := Default;
  Terrains := FResource.TerrainList;
  if Result < 0 then Result := 0;
  FillChar(Counts, SizeOf(Counts), 0);
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN < Terrains.Count do
  begin
    if (FResource.TerrainList.GetTerrain(Walk.HN) >= 0) and
      (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      TerrainType := MapLevel.GetField(Walk.X, Walk.Y).TerrainType;
      if TerrainType >= 0 then
      begin
        Inc(Counts[TerrainType]);
        if Counts[TerrainType] > Counts[Result] then Result := TerrainType;
      end;
    end;
    WalkToNextHN(Walk);
  end;
  if Default >= 0 then
    if Counts[Result] = Counts[Default] then Result := Default;
end;

procedure TFire.Connect;
begin
  CalcShowPriority(TMapField(Owner));
  inherited Connect;
end;

function TFire.PlaceOnMap: Boolean;
begin
  Result := inherited PlaceOnMap;
  if Result then TMapField(Owner).UpdateMapField;
end;

procedure TFire.RemoveFromMap; { Tried guarded untyped owner pointer; guarded owner with typed explicit receiver; still differs. }
var
  MapField: TMapField;
begin
  MapField := TMapField(Owner);
  if MapField <> nil then
    with MapField do
    begin
      inherited RemoveFromMap;
      UpdateMapField;
    end;
end;

function TFire.CanPlace(MapContainer: HSEngine.TMapContainer; Xhx, Yhx, Lhx: ShortInt): Boolean;
begin
  Result := inherited CanPlace(MapContainer, Xhx, Yhx, Lhx);
  if Result then Result := MapContainer.GetField(Xhx, Yhx, Lhx).FindOwnedChild(ClassID) = nil;
end;

procedure TFire.SetupExplosion(Delay: Integer);
begin
  if FResource.ImageSequenceList.GetImageSequence(20) <> nil then
    FExplosionFrame := Delay + AoWHSMap.Frame;
end;

procedure TFire.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin
  if not (moVisible in FStatus) and (FExplosionFrame <> 0) and
    (AoWHSMap.Frame = FExplosionFrame) then
    PlaySample(ExplosionSFX[(GetXhx + AoWHSMap.Frame) mod 2]);
  inherited MakeVisible(VisibilityList);
end;

procedure TFire.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Frame, X, Y: Integer;
begin
  if FExplosionFrame <> 0 then
  begin
    Frame := AoWHSMap.Frame - FExplosionFrame;
    if (Frame >= 0) and
      (Frame < FResource.ImageSequenceList.GetImageSequence(20).GetTotalSequenceFrames) then
    begin
      HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
      FResource.ImageSequenceList.Show(20, X - XhpSurf, Y - YhpSurf, Frame, SurfaceDesc);
    end
    else if (Frame < -1000) or (Frame >= 0) then
    begin
      FExplosionFrame := 0;
      inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
    end;
  end
  else inherited Show(XhpSurf, YhpSurf, SurfaceDesc);
end;

procedure TFire.TriggerDamage;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1105;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  TMapField(Owner).SendMapFieldMsg(Msg);
end;

function TFire.CanDoDamage(Units: TUnitList): Boolean;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Result := False;
  I := Units.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := Units.GetUnit(I);
    Result := not (dtFire in AUnit.GetImmunityTypes);
  end;
end;

procedure TFire.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
    TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;

function TFire.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if FResource.TerrainList.GetTerrain(Info.HN) >= 0 then
  begin
    if not CanDoDamage(TMoveControl(Info.Sender).FSettings.FUnits) then Result := 1
    else
    begin
      Result := 0;
      Exit;
    end;
  end
  else Result := 1;
end;

procedure TFire.ArmyPlaced(ArmyHS: TArmyHS);
begin
  if not (msEditting in AoWHSMap.Status) then ArmyHS.FArmy.TriggerFireDamage;
end;

procedure TFire.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  if (Msg.MsgID <> $10) or (msEditting in AoWHSMap.Status) then inherited MapFieldMsgProc(Msg);
  if (Msg.MsgID = $1142) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
  begin
    ArmyPlaced(TArmyHS(Msg.Param[0]));
    Exit;
  end;
  if (Msg.MsgID = $1120) and (FResource.TerrainList.GetTerrain(Msg.HN) >= 0) then
    if not (dtFire in TArmyHS(Msg.Param[0]).FArmy.ImmunityTypes($FF)) then Msg.Result := 1;
end;

function IgnitionChance(MapField: TAoWMapField): Integer;
begin
  if (MapField.TerrainType in [1..5, 12]) and (MapField.FindOwnedChild($2077E) = nil) and not MapField.GetMagicShieldActive then
  begin
    if MapField.OverlayType = 1 then
      if MapField.TerrainType = 3 then Result := 40
      else if MapField.TerrainType = 2 then Result := 80 else Result := 60
    else if MapField.OverlayType = 3 then
      if MapField.TerrainType = 3 then Result := 10
      else if MapField.TerrainType = 2 then Result := 30 else Result := 20
    else if MapField.TerrainType = 3 then Result := 1 else Result := 5;
    if MapField.FindNoneTransparentHS(TStructure) <> nil then
    begin
      Inc(Result, 5);
      if (AoWHSMap <> nil) and (getFireMastery in AoWHSMap.FGlobalMagicControl.FActiveEnchantments) then Inc(Result, 5);
    end;
    if Result < 0 then Result := 0;
  end
  else Result := 0;
end;

procedure TFire.NewTurn;
begin
  if FAge < 99 then Inc(FAge);
end;

procedure TFire.NewTurnDone;
var
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  Chance: Integer;
  Fire: TFire;
begin
  if FAge > 0 then
  begin
    MapLevel := TMapLevel(TMapField(Owner).Owner);
    InitHNWalk(Walk, GetXhx, GetYhx, 1);
    while Walk.Radius = 1 do
    begin
      { Original excludes the top row when spreading fire. }
      if (Walk.X >= 0) and (Walk.X < MapLevel.Width) and
        (Walk.Y > 0) and (Walk.Y < MapLevel.Height) then
      begin
        Chance := IgnitionChance(TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y)));
        if Chance > AoWHSMap.Random(1000) then
        begin
          RandSeed := AoWHSMap.Random($FFFFFF);
          Fire := AoWHSSet.FFireControl.PlaceFire(Walk.X, Walk.Y, GetLhx, ftLarge);
          if Fire <> nil then
          begin
            Fire.FPlayer := FPlayer;
            Fire.FTurnsLeft := 3;
          end;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end;
  if FTurnsLeft <> 0 then
  begin
    Dec(FTurnsLeft);
    if FTurnsLeft <> 0 then TriggerDamage else Destroy;
  end
  else TriggerDamage;
end;

procedure TFire.WaterMasteryCast;
begin
  if FTurnsLeft <> 0 then Destroy;
end;

procedure TFire.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = FPlayer) then
  begin
    NewTurn;
    Exit;
  end;
  if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then NewTurnDone
  else if (Msg.MsgID = $20020102) and (Byte(Msg.Param[1]) = 6) then WaterMasteryCast;
end;

{ TFireResource (instance size 72): $44 FFireType. }
destructor TFireResource.Destroy;
begin
  if (FEngine <> nil) and not (ssDestroying in AoWHSSet.Status) then
    AoWHSSet.FFireControl.UnregisterFireResource(Self);
  inherited Destroy;
end;

class function TFireResource.ResourceEditName: string;
begin
  Result := TranslateRStr(FireRStr);
end;

class function TFireResource.ClassID: Integer;
begin
  Result := $2077F;
end;

function TFireResource.ResourceUserClassID: Integer;
begin
  Result := $2077E;
end;

procedure TFireResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FFireType, 1, 20);
end;

procedure TFireResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then AoWHSSet.FFireControl.RegisterFireResource(Self);
end;

{ TFireControl (instance size 8): $04 FResources. }
constructor TFireControl.Create;
begin
  inherited Create;
  FResources := TList.Create;
end;

destructor TFireControl.Destroy;
begin
  FResources.Free;
  inherited Destroy;
end;

function TFireControl.GetRndFireResource(FireType: TFireType): TFireResource;
var
  I: Integer;
  Resources: TList;
begin
  Resources := TList.Create;
  for I := 0 to FResources.Count - 1 do
    if TFireResource(FResources.List^[I]).FFireType = FireType then
      Resources.Add(FResources.List^[I]);
  if Resources.Count <> 0 then
    Result := TFireResource(Resources.List^[System.Random(Resources.Count)])
  else Result := nil;
  Resources.Free;
end;

function TFireControl.PlaceFire(X, Y, L: Integer; FireType: TFireType): TFire;
var
  Resource: TFireResource;
  Fire: TFire;
begin
  Resource := GetRndFireResource(FireType);
  if Resource <> nil then
  begin
    Fire := TFire(Resource.CreateResourceUser);
    Fire.FPlayer := AoWHSMap.FCurrentPlayer;
    if not AoWHSMap.PlaceHX(Fire, X, Y, L) then
    begin
      Fire.Free;
      Result := nil;
    end
    else
    begin
      Result := Fire;
      Fire.TriggerDamage;
    end;
  end
  else Result := nil;
end;

procedure TFireControl.RegisterFireResource(Resource: TFireResource);
begin
  FResources.Add(Resource);
end;

procedure TFireControl.UnregisterFireResource(Resource: TFireResource);
begin
  FResources.Remove(Resource);
end;

{ TTargetSelectionControl (instance size 92): $04 images, $08 HNs,
  $0C status, $0D mode, $10/$18 callbacks, $20 range, $24..$2C source
  coordinates, $30 source, $34 change events, $38 change, $39..$3B target,
  $3C text, $40 title, $44 cancel text, $50/$54/$58 images. }
constructor TTargetSelectionControl.Create;
begin
  inherited Create;
  FOnChange := TEventList.Create;
  FHNs := TShortIntList.Create;
  FText := TStringList.Create;
end;

destructor TTargetSelectionControl.Destroy;
begin
  FText.Free;
  FOnChange.Free;
  FOnChange := nil;
  FHNs.Free;
  FHNs := nil;
  if FImageLibrary <> nil then
  begin
    { Original links the image library again when destroying the control. }
    AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TARGHEX.ILB');
    FImageLibrary := nil;
  end;
  inherited Destroy;
end;

procedure TTargetSelectionControl.TriggerOnChangeEvent(Change: TTargetSelectionChange);
begin
  FChange := Change;
  FOnChange.TriggerNotifyEvents(Self);
  FChange := tscNone;
end;

procedure TTargetSelectionControl.DeselectHS(Sender: TObject);
begin
  if tsActivated in FStatus then Deactivate;
end;

procedure TTargetSelectionControl.MouseDownEvent(Sender: TObject); { Tried Self identity, Pointer identity, typed with; typed mouse receiver; still differs. }
var
  Mouse: THSMapMouse;
begin
  if tsActivated in FStatus then
  begin
    if (AoWHSMap.Mouse.Capture <> Self) or (AoWHSMap.Mouse.Button = mbRight) then
    begin
      Deactivate;
      AoWHSMap.FSelectedArmy.FIgnoreMouseDown := True;
    end
    else
    begin
      Mouse := AoWHSMap.Mouse;
      if (Mouse.Capture = Self) and (Mouse.Button = mbLeft) then
      if ValidTarget(FTargetX, FTargetY, FTargetL) then
      begin
        TriggerOnChangeEvent(tscSelected);
        if not (tsActivated in FStatus) then AoWHSMap.FSelectedArmy.FIgnoreMouseDown := True;
      end;
    end;
  end;
end;

function TTargetSelectionControl.ValidTarget(X, Y, L: Shortint): Boolean;
var
  MapField: TMapField;
begin
  if (X <> -1) and (Y <> -1) then
  begin
    if tmValidateDistance in FTargetMode then
      Result := dHXtoRad(FSourceX, FSourceY, X, Y) <= FRange
    else Result := True;
    if tmFixedLevel in FTargetMode then Result := Result and (L = FSourceL);
    MapField := AoWHSMap.MapContainer.GetField(X, Y, L);
    Result := Result and (Smallint(MapField.TerrainType) <> 15);
    if Result and Assigned(FOnValidateTarget) then FOnValidateTarget(Self, X, Y, L, Result);
  end
  else Result := False;
end;

procedure TTargetSelectionControl.NewFrameEvent(Sender: TObject);
begin
  if tsActivated in FStatus then
    if tsVisible in FStatus then
    begin
      AoWHSMap.Mouse.SetCursor(110 + (AoWHSMap.Frame shr 2) mod 10);
      AoWHSMap.Mouse.CursorVisible := True;
    end
    else
    begin
      AoWHSMap.Mouse.SetCursor(120);
      AoWHSMap.Mouse.CursorVisible := False;
    end;
end;

procedure TTargetSelectionControl.MouseMoveEvent(Sender: TObject);
begin
  if tsActivated in FStatus then
  begin
    FTargetX := AoWHSMap.Mouse.GetXhx;
    FTargetY := AoWHSMap.Mouse.GetYhx;
    FTargetL := AoWHSMap.ViewL;
    if (AoWHSMap.Mouse.GetXhx <> -1) and (AoWHSMap.Mouse.GetYhx <> -1) and
      ValidTarget(AoWHSMap.Mouse.GetXhx, AoWHSMap.Mouse.GetYhx, AoWHSMap.ViewL) then
      FStatus := FStatus + [tsVisible]
    else FStatus := FStatus - [tsVisible];
  end;
end;

procedure TTargetSelectionControl.ShowSelection(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc); { Tried Self identity, Pointer identity, typed with; addressable coordinates and X parameter identity; still differs. }
var
  I, DX, DY, X, Y, XS, YS: Integer;
begin
  if (tsActivated in FStatus) and (FTargetX <> -1) and (tsVisible in FStatus) then
  begin
    HXtoHP(FTargetX, FTargetY, X, Y);
    Dec(X, XhpSurf);
    Dec(Y, YhpSurf);
    for I := 0 to FHNs.Count - 1 do
      if FHNs[I] >= 0 then
      begin
        HNtoHP(I, DX, DY);
        XS := X + DX;
        YS := Y + DY;
        if tmOwnerDraw in FTargetMode then
        begin
          if Assigned(FOnShow) then FOnShow(Self, I, XS, YS, SurfaceDesc);
        end
        else FImageLibrary.Get(FHNs[I]).Show(XS - 8, YS, SurfaceDesc);
      end;
  end;
end;

procedure TTargetSelectionControl.Initialize(A1: TObject);
begin
  if FImageLibrary = nil then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], 'TARGHEX.ILB');
  if not (tsActivated in FStatus) then
  begin
    FHNs.Clear;
    FSource := A1;
    FTargetMode := [tmFixedLevel];
  end
  else raise Exception.Create('please deactivate before initializing (TTargetSelectionControl)');
end;

procedure TTargetSelectionControl.Activate;
begin
  if not (tsActivated in FStatus) then
  begin
    FStatus := FStatus + [tsActivated];
    AoWHSMap.Mouse.SetCapture(Self);
    AoWHSMap.Mouse.OnDown.Add(MouseDownEvent);
    AoWHSMap.Mouse.OnMove.Add(MouseMoveEvent);
    AoWHSMap.NewFrameEvents.Add(NewFrameEvent);
    AoWHSMap.Selection.OnDeselect.Add(DeselectHS);
    AoWHSMap.Mouse.CursorMode := $100;
    AoWHSMap.FKeyboard.Lock;
    TriggerOnChangeEvent(tscActivated);
    MouseMoveEvent(Self);
  end
  else raise Exception.Create('Already activated');
end;

procedure TTargetSelectionControl.Deactivate;
var
  ArmyHS: TArmyHS;
begin
  if tsActivated in FStatus then
  begin
    FStatus := FStatus - [tsActivated];
    AoWHSMap.Mouse.OnDown.Remove(MouseDownEvent);
    AoWHSMap.Mouse.OnMove.Remove(MouseMoveEvent);
    AoWHSMap.NewFrameEvents.Remove(NewFrameEvent);
    AoWHSMap.Selection.OnDeselect.Remove(DeselectHS);
    if AoWHSMap.Mouse.Capture = Self then
      if AoWHSMap.FSelectedArmy.GetArmyHS <> nil then
      begin
        ArmyHS := AoWHSMap.FSelectedArmy.GetArmyHS;
        AoWHSMap.Mouse.SetCapture(nil);
        AoWHSMap.Selection.UnselectLocation;
        AoWHSMap.Selection.SelectLocationHS(ArmyHS);
      end
      else AoWHSMap.Mouse.SetCapture(nil);
    AoWHSMap.FKeyboard.Unlock;
    TriggerOnChangeEvent(tscDeactivated);
    FSource := nil;
    FOnShow := nil;
    FOnValidateTarget := nil;
  end;
end;

procedure TTargetSelectionControl.UnitChanged(AUnit: TObject);
begin
  if (tsActivated in FStatus) and (FSource <> nil) and (AUnit = FSource) and
    (usKilled in TAbstractUnit(AUnit).FUnitStatus) then Deactivate;
end;

{ TMovepath (instance size 20): inherited $04 locations and $08 count. }
function TMovepath.MovePointsToPos(MovePoints: Integer): Integer;
begin
  if MovePoints >= 0 then
  begin
    Result := Count;
    while (Result > 0) and (MovePoints >= 0) do
    begin
      Dec(Result);
      Dec(MovePoints, List^[Result].Flag);
    end;
    if MovePoints < 0 then Inc(Result);
  end
  else Result := Count - 1;
end;

function TMovepath.PosToMovePoints(Pos: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := Count - 1 downto Pos do Inc(Result, List^[I].Flag);
end;

function TMovepath.GetMovePoints: Integer;
begin
  Result := PosToMovePoints(0);
end;

{ TMoveSettings (instance size 44): $08 path, $0C path cost, $10 object,
  $14 available points, $1C priority, $20 selection, $24 position, $28 valid. }
constructor TMoveSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TMovepath.Create;
  FPriority := 1;
end;

destructor TMoveSettings.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

function TMoveSettings.GetMoveLoc: TXYL;
begin
  if (FPath.Count > FMovePos) and (FMovePos >= 0) then
  begin
    Result := FPath.List^[FMovePos];
    Result.Flag := 0;
  end
  else Integer(Result) := $FFFFFF;
end;

function TMoveSettings.GetMovePrio: Integer;
begin
  Result := (FPath.Count - FMovePos) * FPriority;
end;

{ TMoveSettingsList (instance size 12): inherited $08 FChildren. }
function TMoveSettingsList.GetMoveSettings(Index: Integer): TMoveSettings;
begin
  Result := TMoveSettings(FChildren.List^[Index]);
end;

function TMoveSettingsList.GetNoneValidMove: Integer;
var
  I, MinPriority, Priority: Integer;
begin
  Result := -1;
  MinPriority := $FFFFFF;
  for I := GetCount - 1 downto 0 do
    with TMoveSettings(FChildren.List^[I]) do
      if not FValid then
      begin
        Priority := GetMovePrio;
        if Priority <= MinPriority then
        begin
          Result := I;
          MinPriority := Priority;
        end;
      end;
end;

function TMoveSettingsList.IndexOfMoveObject(MoveObject: TObject): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if MoveObject = TMoveSettings(FChildren.List^[Result]).FMoveObject then Exit;
  end;
  Result := -1;
end;

procedure TMoveSettingsList.CalculateMovePositions(Validate: TValidateMovePositionProc);
var
  I, Index: Integer;
  Settings: TMoveSettings;
begin
  for I := GetCount - 1 downto 0 do
  begin
    Settings := GetMoveSettings(I);
    Settings.FMovePos := Settings.FPath.MovePointsToPos(Settings.FMovePoints);
    Settings.FValid := (Settings.FPath.Count = 0) or (Settings.FMovePos = Settings.FPath.Count - 1);
  end;
  Index := GetNoneValidMove;
  while not (Index = -1) do
  begin
    if Validate(Self, Index) then
    begin
      GetMoveSettings(Index).FValid := True;
      for I := 0 to GetCount - 1 do
        if Index <> I then
          if Integer(GetMoveSettings(Index).GetMoveLoc) = Integer(GetMoveSettings(I).GetMoveLoc) then
            if GetMoveSettings(Index).GetMovePrio < GetMoveSettings(I).GetMovePrio then
              GetMoveSettings(I).FValid := False;
    end
    else
    begin
      Inc(GetMoveSettings(Index).FMovePos);
      GetMoveSettings(Index).FValid := GetMoveSettings(Index).FMovePos = GetMoveSettings(Index).FPath.Count - 1;
    end;
    Index := GetNoneValidMove;
  end;
end;

{ TMoveSelector (instance size 24): $04 control settings, $08 moves, $0C current move,
  $10 map, $14 status. }
constructor TMoveSelector.Create;
begin
  inherited Create;
  FMoveControlSettings := CreateMCS;
  FMoveSettingsList := TMoveSettingsList.Create(nil);
  FCurrentMove := -1;
  FMap := nil;
end;

destructor TMoveSelector.Destroy;
begin
  Clear;
  FMoveControlSettings.Release;
  FMoveSettingsList.Free;
  inherited Destroy;
end;

function TMoveSelector.CreateMCS: TMoveControlSettings;
begin
  Result := TMoveControlSettings.Create(nil);
end;

procedure TMoveSelector.Clear;
begin
  FMoveControlSettings.Clear;
  FMoveSettingsList.Clear;
  FCurrentMove := -1;
end;

procedure TMoveSelector.SetCurrentMove(A1: Integer);
begin
  FCurrentMove := A1;
end;

procedure TMoveSelector.Unselect;
begin
  Deactivate;
  Clear;
end;

function TMoveSelector.ValidateSelection(Field: TAoWMapField): Boolean;
begin
  Result := True;
end;

procedure TMoveSelector.ExecuteMove;
begin end;

function TMoveSelector.AddMoveObject(Obj: THexagonSprite): Integer;
var
  Settings: TMoveSettings;
begin
  Settings := TMoveSettings.Create(nil);
  Settings.FMoveObject := Obj;
  Settings.SetOwner(FMoveSettingsList);
  Result := FMoveSettingsList.Count - 1;
end;

procedure TMoveSelector.DeleteMoveObject(A1: Integer);
var
  Obj: TObject;
begin
  if FCurrentMove <> -1 then
    Obj := FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject
  else Obj := nil;
  TObject(FMoveSettingsList.FChildren.List^[A1]).Free;
  if Obj <> nil then
  begin
    A1 := FMoveSettingsList.IndexOfMoveObject(Obj);
    if A1 = -1 then SetCurrentMove(FMoveSettingsList.Count - 1)
    else SetCurrentMove(A1);
  end;
end;

procedure TMoveSelector.DeleteMoves;
begin
  while FMoveSettingsList.Count <> 0 do
    DeleteMoveObject(FMoveSettingsList.Count - 1);
end;

procedure TMoveSelector.UpdateMoveCursor;
begin end;

procedure TMoveSelector.MouseMoveEvent(Sender: TObject);
begin
  UpdateMoveCursor;
end;

procedure TMoveSelector.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
begin end;

procedure TMoveSelector.SelectPath(X, Y, L: Shortint); { Tried Self identity, Pointer identity, typed with; typed settings receiver at each path access; still differs. }
begin
  if (FCurrentMove <> -1) and (X <> -1) then
  begin
    with FMoveSettingsList.GetMoveSettings(FCurrentMove) do
    if (FPath.Count <> 0) and (FPath[0].X = X) and
      (FPath[0].Y = Y) and (FPath[0].L = L) then
      ExecuteMove
    else if ValidateSelection(TAoWMapField(FMap.MapContainer.GetField(X, Y, L))) then
      CalculateMovePath(FCurrentMove, X, Y, L)
    else FPath.Clear;
  end;
end;

procedure TMoveSelector.MouseDownEvent(Sender: TObject); var Capture: TObject; Mouse: THSMapMouse;
begin
  Mouse := FMap.Mouse; Capture := Mouse.Capture;
  if ((Capture <> Self) and (Capture <> AoWHSMap.FTargetSelection)) or
    (Mouse.Button = mbRight) then Unselect
    else
      with FMap.Mouse do
        if (Capture = Self) and (Button = mbLeft) then
          SelectPath(Xhx, FMap.Mouse.Yhx, FMap.ViewL);
end;

procedure TMoveSelector.Activate(Map: TAbstractAoWHSMap);
begin
  if mssActivated in FStatus then Deactivate;
  FMap := Map;
  FMap.Mouse.SetCapture(Self);
  FMap.Mouse.OnDown.Add(MouseDownEvent);
  FMap.Mouse.OnMove.Add(MouseMoveEvent);
  FMap.Mouse.OnCaptureChanged.Add(MouseDownEvent);
  FMap.Mouse.CursorMode := $100;
  UpdateMoveCursor;
  FStatus := FStatus + [mssActivated];
  FMap.ShowHexagonSelector;
end;

procedure TMoveSelector.Deactivate;
begin
  if mssActivated in FStatus then
  begin
    FStatus := FStatus - [mssActivated];
    FMap.Mouse.OnDown.Remove(MouseDownEvent);
    FMap.Mouse.OnMove.Remove(MouseMoveEvent);
    FMap.Mouse.OnCaptureChanged.Remove(MouseDownEvent);
    if FMap.Mouse.Capture = Self then FMap.Mouse.SetCapture(nil);
    FMap.HideHexagonSelector;
    UpdateMoveCursor;
  end;
end;

procedure TMoveSelector.ShowMovePaths(const Surface: TSurfaceDesc); { Tried Self identity, Pointer identity, typed with; still differs. }
var
  X1, Y1, X2, Y2, I, J, ImageIndex, MaxX, MaxY, Xhp, Yhp, PointsLeft, Direction: Integer;
  Settings: TMoveSettings;
  MapField: TMapField;
begin
  if (mssActivated in FStatus) and (FMoveSettingsList.Count <> 0) then
  begin
    with FMap do
    begin
      MaxX := ViewXhx + ViewWidthHX - 1;
      MaxY := ViewYhx + ViewHeightHX - 1;
    end;
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      Settings := FMoveSettingsList.GetMoveSettings(I);
      PointsLeft := Settings.FPathMovePoints;
      if Settings.FPath.Count > 1 then
      begin
        for J := 0 to Settings.FPath.Count - 2 do
        begin
          if (Settings.FPath[J].X >= FMap.ViewXhx) and
            (Settings.FPath[J].X <= MaxX) and
            (Settings.FPath[J].Y >= FMap.ViewYhx) and
            (Settings.FPath[J].Y <= MaxY) and
            (Settings.FPath[J].L = FMap.ViewL) then
          begin
            X1 := Settings.FPath[J].X;
            Y1 := Settings.FPath[J].Y;
            X2 := Settings.FPath[J + 1].X;
            Y2 := Settings.FPath[J + 1].Y;
            if dHXtoRad(X1, Y1, X2, Y2) = 1 then
            begin
              Direction := dHXtoHNfast(X1, Y1, X2, Y2);
              if Direction <> 0 then
              begin
                if PointsLeft <= Settings.FMovePoints then ImageIndex := Direction + 34
                else ImageIndex := Direction + 41;
                HXtoHP(X1, Y1, Xhp, Yhp);
                if (FCurrentMove = I) or (FCurrentMove = -1) then
                  AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                    Yhp - FMap.ViewYhp - 8, Surface)
                else
                  AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                    Yhp - FMap.ViewYhp - 8, Surface);
              end;
            end
            else if FCurrentMove = I then
            begin
              if PointsLeft <= Settings.FMovePoints then ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X1, Y1, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
              if (PointsLeft - Settings.FPath[J].Flag <> 0) and
                (Settings.FPath[J + 1].L = FMap.ViewL) then
              begin
                if PointsLeft - Settings.FPath[J].Flag <= Settings.FMovePoints then
                  ImageIndex := 41 else ImageIndex := 48;
                HXtoHP(X2, Y2, Xhp, Yhp);
                AoWHSSet.FCursorImages[ImageIndex].Show(Xhp - FMap.ViewXhp - 8,
                  Yhp - FMap.ViewYhp - 8, Surface);
              end;
            end
            else
            begin
              if PointsLeft <= Settings.FMovePoints then ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X1, Y1, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
              if PointsLeft - Settings.FPath[J].Flag <= Settings.FMovePoints then
                ImageIndex := 41 else ImageIndex := 48;
              HXtoHP(X2, Y2, Xhp, Yhp);
              AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp - FMap.ViewXhp - 8,
                Yhp - FMap.ViewYhp - 8, Surface);
            end;
          end;
          Dec(PointsLeft, Settings.FPath[J].Flag);
        end;
        if (Settings.FPath[0].X >= FMap.ViewXhx) and
          (Settings.FPath[0].X <= MaxX) and
          (Settings.FPath[0].Y >= FMap.ViewYhx) and
          (Settings.FPath[0].Y <= MaxY) and
          (Settings.FPath[0].L = FMap.ViewL) then
        begin
          MapField := FMap.MapContainer.GetField(Settings.FPath[0].X,
            Settings.FPath[0].Y, Settings.FPath[0].L);
          HXtoHP(MapField.Xhx, MapField.Yhx, Xhp, Yhp);
          Xhp := Xhp - FMap.ViewXhp - 8;
          Yhp := Yhp - FMap.ViewYhp - 8;
          if Settings.FMovePoints < Settings.FPathMovePoints then
          begin
            ImageIndex := 48;
            AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface);
            { Original sets the font color before checking the font for nil. }
            AoWEngine.FCombatFont.Color := 0;
            if AoWEngine.FCombatFont <> nil then
              AoWEngine.FCombatFont.SetTextCentered(Xhp + 25, Yhp + 9,
                IntToStr((Settings.FPathMovePoints - Settings.FMovePoints - 1) div Settings.FMoves + 1),
                Surface);
          end
          else
          begin
            ImageIndex := 41;
            if (FCurrentMove = I) or (FCurrentMove = -1) then
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface)
            else AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp, Yhp, Surface);
          end;
        end;
        if Settings.FMovePoints < Settings.FPathMovePoints then
        begin
          J := Settings.FPath.MovePointsToPos(Settings.FMovePoints);
          if (J > 0) and (J < Settings.FPath.Count - 1) and
            (Settings.FPath[J].X >= FMap.ViewXhx) and
            (Settings.FPath[J].X <= MaxX) and
            (Settings.FPath[J].Y >= FMap.ViewYhx) and
            (Settings.FPath[J].Y <= MaxY) and
            (Settings.FPath[J].L = FMap.ViewL) then
          begin
            HXtoHP(Settings.FPath[J].X, Settings.FPath[J].Y, Xhp, Yhp);
            Xhp := Xhp - FMap.ViewXhp - 8;
            Yhp := Yhp - FMap.ViewYhp - 8;
            ImageIndex := 41;
            if (FCurrentMove = I) or (FCurrentMove = -1) then
              AoWHSSet.FCursorImages[ImageIndex].Show(Xhp, Yhp, Surface)
            else AoWHSSet.FCursorImages[ImageIndex].ShowTransparent(Xhp, Yhp, Surface);
          end;
        end;
      end
      else if (Settings.FPath.Count = 1) and (AoWHSMap.FCombat <> nil) then
      begin
        MapField := FMap.MapContainer.GetField(Settings.FPath[0].X,
          Settings.FPath[0].Y, Settings.FPath[0].L);
        HXtoHP(MapField.Xhx, MapField.Yhx, Xhp, Yhp);
        Xhp := Xhp - FMap.ViewXhp - 8;
        Yhp := Yhp - FMap.ViewYhp - 8;
        AoWHSSet.FCursorImages[41].Show(Xhp, Yhp, Surface);
      end;
    end;
  end;
end;

constructor TTextControlItem.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FText := TStringList.Create;
end;

destructor TTextControlItem.Destroy;
begin
  FText.Free;
  inherited Destroy;
end;

class function TTextControlItem.ClassID: Integer;
begin
  Result := $2029A;
end;

procedure TTextControlItem.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FID, 9);
  Stream.rwStrings(FText, 10);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FName, 11);
end;

function TTextControl.GetItem(Index: Integer): TTextControlItem;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TTextControlItem(FChildren.List^[Index])
  else Result := nil;
end;

procedure TTextControl.Delete(Index: Integer);
begin
  if GetItem(Index) <> nil then GetItem(Index).Free;
end;

function TTextControl.New: TTextControlItem;
begin
  Result := TTextControlItem.Create(Self);
end;

function TTextControl.FindID(ID: Integer): TTextControlItem;
var
  I: Integer;
begin
  I := Count;
  Result := nil;
  while (Result = nil) and (I <> 0) do
  begin
    Dec(I);
    if TTextControlItem(FChildren.List^[I]).FID = ID then
      Result := TTextControlItem(FChildren.List^[I]);
  end;
end;

function CompareTextControlItems(Item1, Item2: Pointer): Integer;
begin
  Result := TTextControlItem(Item1).FID - TTextControlItem(Item2).FID;
  if Result = 0 then
    Result := TTextControlItem(Item1).FText.Count - TTextControlItem(Item2).FText.Count;
  if Result = 0 then Result := Integer(Item1) - Integer(Item2);
end;

procedure TTextControl.Sort;
begin
  FChildren.Sort(CompareTextControlItems);
end;

function TTextControl.IndexOf(Item: TTextControlItem): Integer;
begin
  Result := FindChildIndex(Item);
end;

procedure TTextControl.RetrieveText(ID: Integer; Text: TStrings);
var
  Item: TTextControlItem;
begin
  Text.Clear;
  Item := FindID(ID);
  if Item <> nil then Text.Text := Item.FText.Text;
end;

class function TFrozenWaterHS.ClassID: Integer;
begin
  Result := $2016C;
end;

function TFrozenWaterHS.GetLevel: Byte;
begin
  Result := $1C;
end;

procedure TFrozenWaterHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwShortint(FDaysRemaining, $1E);
  Stream.rwShortint(FCasterPlayer, $1F);
end;

procedure TFrozenWaterHS.MeltIce;
begin
  if TMapField(Owner).TerrainType = 6 then
    AoWHSMap.ChangeTerrain(Self, Xhx, Yhx, Lhx, 0, 0)
  else if TMapField(Owner).TerrainType = 13 then
    AoWHSMap.ChangeTerrain(Self, Xhx, Yhx, Lhx, 0, 10)
  else Destroy;
end;

procedure TFrozenWaterHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  if (Info.HN = 0) and not (Info.TerrainType in [6, 13]) then Destroy;
end;

procedure TFrozenWaterHS.NewTurn(Player: Shortint);
begin
  if Player = FCasterPlayer then
  begin
    Dec(FDaysRemaining);
    if FDaysRemaining <= 0 then MeltIce;
  end;
end;

procedure TFrozenWaterHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Msg.Value);
end;

procedure TFrozenWaterHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  X, Y: Integer;
begin
  HXtoHP(Xhx, Yhx, X, Y);
  X := X - XhpSurf + 16;
  Y := Y - YhpSurf + 16;
  AoWHSSet.FImageSequences.ShowLoopedEx(70, X, Y, AoWHSMap.Frame,
    Xhx + Yhx + Yhx * 2, SurfaceDesc);
end;

