constructor THeroUpgradeTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAbilities := TAbilityOwner.Create(nil);
end;

destructor THeroUpgradeTE.Destroy;
begin
  FAbilities.Free;
  inherited Destroy;
end;

procedure THeroUpgradeTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FAttack), 30);
  Stream.rwByte(Byte(FDefense), 31);
  Stream.rwByte(Byte(FResistance), 32);
  Stream.rwByte(Byte(FDamage), 33);
  Stream.rwByte(Byte(FMoves), 34);
  Stream.rwByte(Byte(FHits), 35);
  Stream.rwEObject(FAbilities, 36);
  Stream.rwInteger(FUnitID, 37);
  Stream.rwByte(Byte(FPlayer), 38);
end;

class function THeroUpgradeTE.ClassID: Integer;
begin Result := $2131D; end;

function THeroUpgradeTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var Hero: THero;
begin
  Result := inherited Execute(TE);
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (Hero.GetHitPoints <> 0) and (Hero.FPlayer = FPlayer) then
  begin
    Hero.SetUnitAttack(Hero.FUnitAttack + FAttack);
    Hero.SetUnitDefense(Hero.FUnitDefense + FDefense);
    Hero.SetUnitResistance(Hero.FUnitResistance + FResistance);
    Hero.SetUnitDamage(Hero.FUnitDamage + FDamage);
    Hero.SetUnitMoves(Hero.FUnitMoves + FMoves);
    Hero.SetUnitHits(Hero.FUnitHits + FHits);
    Hero.UpdateDefaultAbilities(FAbilities);
    Hero.FUpgradePending := False;
  end;
end;

procedure THeroUpgradeTE.Setup(Hero: THero);
begin
  FUnitID := Hero.FUnitID;
  FPlayer := Hero.FPlayer;
end;

class function THeroUpgradeEventLog.ClassID: Integer;
begin Result := $202F1; end;

procedure THeroUpgradeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 25);
  Stream.rwByte(FOldLevel, 26);
  Stream.rwByte(FNewLevel, 27);
  Stream.rwInteger(FDay, 28);
end;

function THeroUpgradeEventLog.GetText: string;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if Hero <> nil then
    if FNewLevel - FOldLevel = 1 then
      Result := Format(TranslateRStr(XMadeALevelRStr), [Hero.GetName])
    else Result := Format(TranslateRStr(XMadeYLevelsRStr), [Hero.GetName, FNewLevel - FOldLevel]);
end;

function THeroUpgradeEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (AoWHSMap.FSeatedPlayer = Hero.FPlayer) then
  begin
    if Hero.FUpgradePending then
    begin
      Result := Trigger = etUser;
      Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
        (wpHeroUpgrade in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
      Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
        (wpHeroUpgrade in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
      if Result then Result := inherited Execute(Mode, Trigger, Done);
    end
    else
    begin
      if AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FDay = FDay then
        AoWHSMap.ShowWarning(TranslateRStr(CanOnlyUpgradeHeroOnceRStr))
      else AoWHSMap.ShowWarning(TranslateRStr(CanOnlyUpgradeOnTheDayALevelIsMadeRStr));
      Result := False;
    end;
  end
  else Result := False;
end;

procedure THeroUpgradeEventLog.ViewLocation;
var U: TAbstractUnit; X, Y, L: Shortint;
begin
  U := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if U <> nil then
  begin
    U.GetLocation(X, Y, L);
    if X <> -1 then CenterViewTo(X, Y, L);
  end;
end;

class function THeroJoinEventLog.ClassID: Integer;
begin Result := $202F4; end;

function THeroJoinEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FFirstUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
  begin
    Result := Trigger = etUser;
    Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
      (wpHeroJoin in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
    Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
      (wpHeroJoin in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
    if Result then Result := inherited Execute(Mode, Trigger, Done);
  end
  else Result := False;
end;

function THeroJoinEventLog.ExecuteAI: Boolean;
var Hero: THero; ErrorText: string;
begin
  Result := False;
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FFirstUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
    if AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.RequestBudgetExpense(
      FGold, 0, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, True) then
    begin
      if Accept(ErrorText) then
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.BudgetExpenseMade(
          FGold, 0, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, bemBudgetThenPool);
      Result := True;
    end;
end;

function THeroJoinEventLog.Accept(var ErrorText: string): Boolean;
var TE: TNegotiateTE; U: TAbstractUnit; Location: TXYL;
begin
  Result := inherited Accept(ErrorText);
  if Result and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    U := AoWHSMap.FUnitControl.FindUnit(FFirstUnitID);
    U.GetLocation(Location.X, Location.Y, Location.L);
    TE := TNegotiateTE.Create(nil);
    TE.FPlayer := FPlayer;
    TE.FObject := noArmy;
    TE.FGold := FGold;
    TE.FOffer := noOfferBribe;
    TE.FX := Location.X;
    TE.FY := Location.Y;
    TE.FL := Location.L;
    TE.FMode := [];
    TE.FResult := nrAccept;
    TE.FEventLogID := FJoinIndex;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
  end;
end;

class function THeroEmergeEventLog.ClassID: Integer;
begin Result := $202F8; end;

procedure THeroEmergeEventLog.Setup(Hero: THero; Player: Shortint; Mode: THeroJoinMode);
var Name: string;
begin
  FPlayer := Player;
  FUnitID := Hero.FUnitID;
  FDay := AoWHSMap.FDay;
  FMode := Mode;
  Name := Hero.FHeroName;
  if Hero.GetNickname <> '' then Name := Name + ' ' + Hero.GetNickname;
  { Original builds Name but formats the message from FHeroName instead. }
  FText := Format(TranslateRStr(XOffersToJoinRStr), [Hero.FHeroName]);
end;

procedure THeroEmergeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 39);
  Stream.rwInteger(FDay, 40);
  Stream.rwString(FText, 41);
  Stream.rwString(FLocationName, 42);
  Stream.rwData(FMode, 1, 43);
end;

function THeroEmergeEventLog.GetText: string;
begin
  Result := FText;
end;

procedure THeroEmergeEventLog.ViewLocation;
var U: TAbstractUnit; X, Y, L: Shortint;
begin
  U := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if U <> nil then
  begin
    U.GetLocation(X, Y, L);
    if X <> -1 then CenterViewTo(X, Y, L);
  end;
end;

function THeroEmergeEventLog.CreateHeroJoinEventLog: THeroJoinEventLog;
var Hero: THero;
begin
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if (Hero <> nil) and (Hero.FPlayer = 0) and Hero.OfferToJoin(FPlayer) then
  begin
    Result := THeroJoinEventLog.Create(nil);
    Result.FJoinIndex := FID;
    case FMode of
    hjmEmerged:
    begin
      Result.SetupJoinArmy(TArmy(Hero.Owner), FPlayer, Result.FJoinMode);
      Result.FFirstUnitID := Hero.FUnitID;
      Result.FJoinMessage.Text := Format(TranslateRStr(XEmergedAtYAndOffersToJoinYouForZgpRStr),
        [Hero.FHeroName, FLocationName, Result.FGold]);
    end;
    hjmResurrected:
    begin
      Result.SetupJoinArmy(TArmy(Hero.Owner), FPlayer, Result.FJoinMode);
      Result.FFirstUnitID := Hero.FUnitID;
      Result.FJoinMessage.Text := Format(TranslateRStr(XwasResurrectedAndOffersToJoinYouForZgpRStr),
        [Hero.FHeroName, Result.FGold]);
    end;
    end;
  end
  else Result := nil;
end;

function THeroEmergeEventLog.ExecuteAI: Boolean;
var Log: THeroJoinEventLog;
begin
  Log := CreateHeroJoinEventLog;
  if Log <> nil then
  begin
    Result := Log.ExecuteAI;
    Log.Release;
  end
  else Result := False;
end;

function THeroEmergeEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var Log: THeroJoinEventLog; Hero: THero;
begin
  Log := CreateHeroJoinEventLog;
  if Log <> nil then
  begin
    Result := Log.Execute(Mode, Trigger, Done);
    Log.Release;
  end
  else
  begin
    Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
    if Hero <> nil then
      if Hero.FPlayer = FPlayer then
        AoWHSMap.ShowWarning(Format(TranslateRStr(XAlreadyJoinedRStr), [Hero.FHeroName]))
      else AoWHSMap.ShowWarning(Format(TranslateRStr(XDoesntWantToJoinAnymoreRStr), [Hero.FHeroName]));
    Result := False;
  end;
end;

constructor THeroInventory.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(nil);
  FOwner := AOwner;
end;

destructor THeroInventory.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function THeroInventory.GetFreeSlot: Integer;
begin
  Result := 0;
  while (Result < FChildren.Count) and (Result <> 8) do
  begin
    if FChildren.List^[Result] = nil then Exit;
    Inc(Result);
  end;
  Result := -1;
end;

function THeroInventory.GetControlStyle: Engine.TEControlStyles;
begin
  Result := inherited GetControlStyle + [csArrayMode];
end;

procedure THeroInventory.GetLocation(var X, Y, L: Shortint);
begin
  TAbstractUnit(FOwner).GetLocation(X, Y, L);
end;

function THeroInventory.GetAbilityCount: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and (Result < Item.GetAbCount) then Result := Item.GetAbCount;
  end;
end;

function THeroInventory.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbEnabled(AbilityID) and (Item.FItemType = itUse) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroInventory.GetAbilityEnabled(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and (Item.FItemType = itUse) and Item.GetAbEnabled(AbilityID);
    Inc(I);
  end;
end;

function THeroInventory.GetAbilitySet(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and (Item.FItemType = itUse) and Item.GetAbSet(AbilityID);
    Inc(I);
  end;
end;

function THeroInventory.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbSet(AbilityID) and (Item.FItemType = itUse) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroInventory.GetSlot(Position: THeroItemPosition): TItem;
var I: Integer;
begin
  case Position of
    ipInventorySlot1..ipInventorySlot8:
    begin
      I := Ord(Position) - Ord(ipInventorySlot1);
      if (I < Count) and (I >= 0) then Result := GetItem(I)
      else
      begin
        Result := nil;
        Exit;
      end;
    end;
  else Result := nil;
  end;
end;

constructor THeroItems.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(nil);
  FOwner := AOwner;
end;

destructor THeroItems.Destroy;
begin
  FOwner := nil;
  inherited Destroy;
end;

function THeroItems.GetControlStyle: Engine.TEControlStyles;
begin
  Result := inherited GetControlStyle + [csArrayMode];
end;

procedure THeroItems.GetLocation(var X, Y, L: Shortint);
begin
  TAbstractUnit(FOwner).GetLocation(X, Y, L);
end;

function THeroItems.GetAttack: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FAttack);
  end;
end;

function THeroItems.GetDefense: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FDefense);
  end;
end;

function THeroItems.GetDamage: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FDamage);
  end;
end;

function THeroItems.GetResistance: Shortint;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Inc(Result, Item.FResistance);
  end;
end;

function THeroItems.GetMoveTypes: TMoveTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbMoveTypesAll;
  end;
end;

function THeroItems.GetImmunityTypes: TDamageTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbImmunityTypesAll;
  end;
end;

function THeroItems.GetProtectionTypes: TDamageTypes;
var I: Integer; Item: TItem;
begin
  Result := [];
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if Item <> nil then Result := Result + Item.GetAbProtectionTypesAll;
  end;
end;

function THeroItems.GetAbilityCount: Integer;
var I: Integer; Item: TItem;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and (Result < Item.GetAbCount) then Result := Item.GetAbCount;
  end;
end;

function THeroItems.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbEnabled(AbilityID) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroItems.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var I: Integer; Item: TItem;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and Item.GetAbSet(AbilityID) then
      if (Result = nil) or (Item.GetAbLevel(AbilityID) > Result.GetAbLevel(AbilityID)) then
        Result := Item;
  end;
end;

function THeroItems.GetAbilityEnabled(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and Item.GetAbEnabled(AbilityID);
    Inc(I);
  end;
end;

function THeroItems.GetAbilitySet(AbilityID: Integer): Boolean;
var I: Integer; Item: TItem;
begin
  Result := False;
  I := 0;
  while not Result and (I < Count) do
  begin
    Item := TItem(FChildren.List^[I]);
    Result := (Item <> nil) and Item.GetAbSet(AbilityID);
    Inc(I);
  end;
end;

function THeroItems.GetPositionItem(Position: THeroItemPosition): TItem;
var Index: Integer;
begin
  Index := Ord(Position) and $7F;
  if Index < FChildren.Count then Result := TItem(FChildren.List^[Index])
  else Result := nil;
end;

function THeroItems.GetPositionItemType(Position: THeroItemPosition): TItemType;
const Types: array[0..5] of TItemType = (itAttack, itHead, itDefense, itRing, itTorso, itRing);
begin
  Result := Types[Ord(Position)];
end;

function THeroItems.GetItemTypePosition(ItemType: TItemType): THeroItemPosition;
const Positions: array[TItemType] of THeroItemPosition =
  (ipHeadSlot, ipTorsoSlot, ipAttackSlot, ipDefenseSlot, ipLeftRingSlot, ipNone, ipNone);
begin
  Result := Positions[ItemType];
end;

function THeroItems.CanPlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
begin
  Result := (Item <> nil) and (Integer(Position) < 6) and
    (GetPositionItem(Position) = nil) and (GetPositionItemType(Position) = Item.FItemType);
end;

function THeroItems.PlaceItem(Item: TItem; Position: THeroItemPosition): Boolean;
begin
  if CanPlaceItem(Item, Position) then
  begin
    Item.SetArrayOwner(Self, Ord(Position));
    Result := True;
  end
  else Result := False;
end;

function THeroPowerSource.Name: string;
begin
  Result := FHero.FHeroName;
end;

function THeroPowerSource.Power: Integer;
begin
  Result := FHero.GetPowerGeneration;
end;

procedure THeroPowerSource.Select;
var
  X, Y, L: Shortint;
  ArmyHS: TArmyHS;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
  begin
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetArmyHS;
    if ArmyHS <> nil then AoWHSMap.Select(ArmyHS, True);
  end;
end;

procedure THeroPowerSource.GetLocation(var A1, A2, A3: Shortint);
begin
  FHero.GetLocation(A1, A2, A3);
end;

constructor THero.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FHeroItems := THeroItems.Create(TECustomNode(Self));
  FInventory := THeroInventory.Create(TECustomNode(Self));
  FPowerSource := THeroPowerSource.Create(nil);
  FPowerSource.FHero := Self;
  FHeroResourceIndex := -1;
  FHeroStatus := [];
  FLevel := 1;
  FCastingSpellID := 0;
  FCastingMana := 0;
  FCastingProgress := 0;
  FLibraryID := -1;
end;

destructor THero.Destroy;
begin
  AddRef;
  AddRef;
  AddRef;
  AddRef; { Original repeats the reference increment four times. }
  if FRegistered and (AoWHSMap <> nil) then AoWHSMap.FHeroControl.UnRegisterHero(Self);
  inherited Destroy;
  FHeroItems.Free;
  FInventory.Free;
  FPowerSource.Free;
end;

function THero.GetCampaignTransferPoints: Integer;
begin
  Result := inherited GetCampaignTransferPoints;
  Result := Result div 2;
end;

function THero.GetLibraryName: string;
begin
  Result := FLibraryName;
  if Result = '' then Result := TranslateRStr(SystemRStr);
end;

procedure THero.UpdateFromLibraryBegin;
begin FMode := FMode + [hmUpdatingFromLibrary]; end;

procedure THero.UpdateFromLibraryEnd;
begin FMode := FMode - [hmUpdatingFromLibrary]; end;

procedure THero.UpdateFromLibrary;
var Hero: THero; ID: Integer;
begin
  if FLibraryID <> -1 then
  begin
    Hero := AoWHSSet.FHeroLibraries.FindHero(FLibraryName, FLibraryID);
    if Hero <> nil then
    begin
      ID := FUnitID;
      FMode := FMode + [hmUpdatingFromLibrary];
      Assign(Hero, AoWEngine);
      FMode := FMode - [hmUpdatingFromLibrary];
      FUnitID := ID;
      Changed;
    end;
  end;
end;

function THero.GetUnitLevel: Shortint;
begin Result := FLevel; end;

procedure THero.SetOwner(AOwner: Engine.TECustomNode);
begin
  AddRef;
  inherited SetOwner(AOwner);
  if usActivated in FUnitStatus then Changed;
  Release;
end;

function THero.GetNickname: string;
begin Result := FNickname; end;

procedure THero.SetNickname(Value: string);
begin FNickname := Value; end;

function THero.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := [astEditor]; end;

function THero.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;

function THero.GetLibraryHero: Boolean;
begin Result := FLibraryID <> -1; end;

function THero.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer;
begin
  Result := inherited ShowEx(X, Y, SD, Info);
  if uoRank in Info.Overlays then
  begin
    AoWEngine.FCombatFont.Color := $FFFFFF;
    AoWEngine.FCombatFont.SetTextCentered(X + 43, Y + 12, IntToStr(GetLevel), SD);
  end;
end;

procedure THero.Changed;
begin
  inherited Changed;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.FHeroControl.HeroChanged(Self);
end;

class function THero.ClassID: Integer;
begin Result := $20230; end;

function THero.GetObtainValue: Integer;
begin Result := GetLevel * 50 + 75; end;

function THero.GetDescription: TStrings;
begin Result := nil; end;

function THero.GetGender: TUnitGender;
begin Result := FGender; end;

function THero.GetUnitType: TUnitType;
begin Result := utHumanoid; end;

procedure THero.NewDay;
begin
  inherited NewDay;
  if AoWHSMap.FDay = 1 then
  begin
    if ((AoWEngine.FCampaign = nil) or (AoWHSMap.FPlayers.GetPlayers(FPlayer) = nil) or
       (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman)) and
       (not AoWHSMap.FLeadersFixed or not (Self is TLeader)) then
      FUsedSkillPoints := GetSkillPoints;
    UpdateSettings;
  end;
end;

function THero.UsedSkillPoints: Integer;
var I: Integer;
begin
  Result := FUnitAttack * 5 + FUnitDefense * 5 + FUnitDamage * 10 +
    FUnitResistance * 5 + FUnitHits * 5 + FUnitMoves * 2;
  for I := GetAbCount - 1 downto 0 do
    if GetAbSet(I) then
    begin
      Inc(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(Self));
      if FHeroResource.FAbilities.GetAbSet(I) then
        Dec(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(FHeroResource.FAbilities));
    end;
end;

function THero.CanJoin(Player: Shortint): Boolean;
var Race: TRace; APlayer: TPlayer;
begin
  if FRace <> -1 then

  begin
    APlayer := AoWHSMap.FPlayers.GetPlayers(Player);
    Result := AoWHSMap.FRaces.GetRace(FRace).GetPlayerRelation(Player) in [sPolite, sFriendly];

    if Result then if ((FGroup = nil) or (FGroup.Behavior <> gbRefuge)) and
      (not GetAbilityEnabled(128) or (Player <> FDeathPlayer) or
       (FDeathDay + 2 < AoWHSMap.FPlayers.GetPlayers(Player).FDay)) then
      Result := Result and (APlayer.FHeroes.Count < APlayer.GetHeroCountMax) and
        (GetLevel <= APlayer.GetHeroJoinLevelMax);
  end else Result := False;
end;

function THero.EmergedToPlayer: Shortint;
var I: Integer;
begin
  I := AoWHSMap.FPlayers.Count;
  Result := -1;
  while (I <> 1) and (Result = -1) do
  begin
    Dec(I);
    if AoWHSMap.FPlayers.GetPlayers(I).FEmergingHeroID = FUnitID then Result := I;
  end;
end;

function THero.OfferToJoin(Player: Shortint): Boolean;
var APlayer: TPlayer; Seed, Chance: Integer;
begin
  if CanJoin(Player) then
  begin
  APlayer := AoWHSMap.FPlayers.GetPlayers(Player);
  if EmergedToPlayer = -1 then
  begin
    if (not GetAbilityEnabled(128) or (Player <> FDeathPlayer)) and
      ((FGroup = nil) or (FGroup.Behavior <> gbRefuge)) then
    begin
      Chance := APlayer.GetHeroJoinChance(GetLevel);
      Seed := RandSeed;
      RandSeed := (AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + FUnitID * 16) and $FF8;
      Result := Random(100) < Chance;
      RandSeed := Seed;
    end
    else Result := True;
  end
  else Result := Player = EmergedToPlayer;
  end
  else Result := False;
end;

function THero.GetRace: Shortint;
begin Result := FHeroResource.FRace; end;

function THero.GetName: string;
begin Result := FHeroName; end;

function THero.GetMoveTypes: TMoveTypes;
begin
  Result := inherited GetMoveTypes;
  Result := Result + FHeroItems.GetMoveTypes;
end;

function THero.GetImmunityTypes: TDamageTypes;
begin
  Result := inherited GetImmunityTypes;
  Result := Result + FHeroItems.GetImmunityTypes;
end;

function THero.GetProtectionTypes: TDamageTypes;
begin
  Result := inherited GetProtectionTypes;
  Result := Result + FHeroItems.GetProtectionTypes;
end;

function THero.GetMovePoints: Shortint;
begin Result := FMovePoints; end;

procedure THero.SetMovePoints(Value: Shortint);
begin
  if GetMoves < Value then Value := GetMoves;
  FMovePoints := Value;
end;

function THero.GetHitPoints: Shortint;
begin Result := FHitPoints; end;

procedure THero.SetHitPoints(Value: Shortint);
begin
  if GetHits < Value then Value := GetHits;
  if Value < 0 then Value := 0;
  FHitPoints := Value;
  UpdateDefensiveStrength;
end;

function THero.GetAlignment: TAlignment;
var Race: Shortint;
begin
  if GetAbilityEnabled(107) then Result := alPureEvil
  else
  begin
    Race := FRace;
    if AoWHSSet.FRaceResources.GetRaceResource(Race) <> nil then
      Result := AoWHSSet.FRaceResources.GetRaceResource(Race).GetAlignment
    else Result := FHeroResource.FAlignment;
  end;
end;

procedure THero.DropItemsOnMap(Map: TAoWHSMap; X, Y, L: Shortint);
var I: Integer; Position: THeroItemPosition;
begin
  for I := FInventory.Count - 1 downto 0 do
    if FInventory.GetItem(I) <> nil then FInventory.GetItem(I).PlaceOnMap(Map, X, Y, L);
  for Position := ipAttackSlot to ipRightRingSlot do
    if FHeroItems.GetPositionItem(Position) <> nil then
      FHeroItems.GetPositionItem(Position).PlaceOnMap(Map, X, Y, L);
end;

procedure THero.Killed;
var Position: THeroItemPosition; I: Integer;
begin
  for I := FInventory.Count - 1 downto 0 do
    if FInventory.GetItem(I) <> nil then
      ExecutePlaceItem(FInventory.GetItem(I).FItemID, ipGround);
  for Position := ipAttackSlot to ipRightRingSlot do
    if FHeroItems.GetPositionItem(Position) <> nil then
      ExecutePlaceItem(FHeroItems.GetPositionItem(Position).FItemID, ipGround);
  FDeathDay := AoWHSMap.FPlayers.GetPlayers(FPlayer).FDay;
  FDeathPlayer := FPlayer;
  inherited Killed;
  FHeroStatus := FHeroStatus + [hsDied];
  SetPlayer(-1);
  SetOwner(nil);
end;

procedure THero.Resurrect;
begin
  inherited Resurrect;
  FHeroStatus := FHeroStatus - [hsDied];
end;

procedure THero.Animate;
begin
  inherited Animate;
  FHeroStatus := FHeroStatus - [hsDied];
end;

function THero.CanActivate: Boolean;
var Hero: THero;
begin
  Result := inherited CanActivate;
  if Result and not FRegistered and (FUnitID <> -1) then
  begin
    Hero := AoWHSMap.FHeroControl.FindID(FUnitID);
    if (Hero = nil) or (Hero = Self) then Result := True
    else
    begin
      if (Hero.Owner = nil) and CompatibleHero(Hero) then Result := True
      else Result := False;
    end;
  end;
end;

function THero.GetUpkeep: Shortint;
begin Result := GetLevel * 2 + 5; end;

procedure THero.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    if (FPlayer <> -1) and (FPlayer < AoWHSMap.FPlayers.Count) then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.RemoveChild(Self);
    end;
    inherited SetPlayer(Player);
    if FPlayer <> -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.AddChild(Self);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).ResetBaseHeroJoinDay;
    end;
  end;
end;

function THero.CompatibleHero(Hero: THero): Boolean;
var GroupID, OtherGroupID: Integer;
begin
  GroupID := FGroupID;
  OtherGroupID := Hero.FGroupID;
  Hero.FGroupID := 0;
  FGroupID := 0;
  Result := Hero.Compare(Self, AoWEngine);
  Hero.FGroupID := OtherGroupID;
  FGroupID := GroupID;
end;

procedure THero.Activate;
var Hero: THero;
begin
  if FUnitID <> -1 then
  begin
    Hero := AoWHSMap.FHeroControl.FindID(FUnitID);
    if (Hero <> nil) and (Hero <> Self) and (Hero.Owner = nil) and CompatibleHero(Hero) then
      AoWHSMap.FHeroControl.UnRegisterHero(Hero);
  end;
  if msEditting in AoWHSMap.Status then FLevel := GetLevel;
  if FHeroResourceIndex = -1 then SetHeroResourceIndex(0);
  if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer) = nil) and (Owner = nil) then FPlayer := -1;
  if (Owner = nil) and (FGroupID <> 0) then FGroupID := 0;
  inherited Activate;
  if AoWHSMap <> nil then
  begin
    if not (hmSkipLibraryUpdate in FMode) and
       ((msEditting in AoWHSMap.Status) or (AoWHSMap.FDay = 0)) then UpdateFromLibrary;
    if not FRegistered then AoWHSMap.FHeroControl.RegisterHero(Self);
    if (FPlayer <> -1) and (Owner <> nil) then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.RegisterPowerSource(FPowerSource);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.AddChild(Self);
    end;
    FInventory.RegisterItems;
    FHeroItems.RegisterItems;
  end;
end;

procedure THero.Deactivate;
begin
  if (FPlayer <> -1) and (FPlayer < AoWHSMap.FPlayers.Count) then
  begin
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.UnregisterPowerSource(FPowerSource);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FHeroes.RemoveChild(Self);
  end;
  inherited Deactivate;
end;

function THero.GetUnitGFXResourceIndex: Integer;
begin Result := FHeroResource.FUnitGFXResourceIndex; end;

function THero.GetSkillPoints: Integer;
begin
  if (AoWHSMap <> nil) and not (msEditting in AoWHSMap.Status) then
    Result := FLevel * 10 + 15 - UsedSkillPoints - FUsedSkillPoints
  else Result := FLevel * 10 + 15 - UsedSkillPoints;
end;

function THero.GetSkillPointsMax: Integer;
begin Result := FLevel * 10 + 15 - FUsedSkillPoints; end;

function THero.GetLevelMax: Integer;
var Maximum: Integer;
begin
  Result := 30;
  if (AoWHSMap <> nil) and (AoWHSMap.FCampaignSettings <> nil) and
    (AoWHSMap.FCampaignSettings.FHeroLevelMax > 0) then
  begin
    Maximum := AoWHSMap.FCampaignSettings.FHeroLevelMax;
    if Maximum < Result then Result := Maximum;
  end;
end;

function THero.GetExperience: Integer;
begin Result := FExperience; end;

procedure THero.SetExperience(Value: Integer);
var Maximum: Integer;
begin
  FExperience := Value;
  Maximum := LevelToExperience(GetLevelMax);
  if Maximum < FExperience then FExperience := Maximum;
  Changed;
end;

function THero.LevelToExperience(Level: Integer): Integer;
var I, Total: Integer;
begin
  Total := 0;
  for I := 1 to Level - 1 do
    if I div 5 <= 5 then Inc(Total, HeroExperienceTable[I div 5].Experience);
  Result := Total;
end;

function THero.ExperienceToLevel(Experience: Integer): Shortint;
var Level, Total, Maximum: Integer;
begin
  Level := 1;
  Total := 0;
  Maximum := GetLevelMax;
  repeat
    Inc(Total, HeroExperienceTable[Level div 5].Experience);
    if Experience < Total then Break;
    Inc(Level);
  until Level >= Maximum;
  Result := Level;
end;

function THero.GetNextLevelExperience: Integer;
var Level, Maximum: Integer;
begin
  Level := GetLevel;
  Maximum := GetLevelMax; if Level < Maximum then Result := LevelToExperience(Level + 1)
  else Result := LevelToExperience(Level);
end;

function THero.GetLevel: Shortint;
begin
  with Self do Result := ExperienceToLevel(FExperience);
end;

procedure THero.SetLevel(Value: Shortint);
var Maximum, Level, Points: Integer;
begin
  Maximum := GetLevelMax;
  if Value < 1 then Value := 1;
  if Maximum < Value then Value := Maximum;
  Level := GetLevel;
  if Level > Value then
  begin
    Points := GetSkillPoints;
    while (Points >= 10) and (Level <> Value) do
    begin
      Dec(Level);
      Dec(Points, 10);
    end;
    Value := Level;
  end;
  FExperience := LevelToExperience(Value);
  FLevel := Value;
end;

function THero.GetHeroType: THeroType;
begin Result := FHeroResource.FHeroType; end;

procedure THero.SetUnitAttack(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FAttack > 10 then Value := 10 - FHeroResource.FAttack;
  if Value > FUnitAttack then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitAttack) do
    begin
      Inc(FUnitAttack);
      Dec(Points, 5);
    end;
  end
  else FUnitAttack := Value;
end;

procedure THero.SetUnitDefense(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FDefense > 10 then Value := 10 - FHeroResource.FDefense;
  if Value > FUnitDefense then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitDefense) do
    begin
      Inc(FUnitDefense);
      Dec(Points, 5);
    end;
  end
  else FUnitDefense := Value;
end;

procedure THero.SetUnitDamage(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FDamage > 10 then Value := 10 - FHeroResource.FDamage;
  if Value > FUnitDamage then
  begin
    Points := GetSkillPoints;
    while (Points >= 10) and (Value <> FUnitDamage) do
    begin
      Inc(FUnitDamage);
      Dec(Points, 10);
    end;
  end
  else FUnitDamage := Value;
end;

procedure THero.SetUnitHits(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FHits > 30 then Value := 30 - FHeroResource.FHits;
  if Value > FUnitHits then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitHits) do
    begin
      Inc(FUnitHits);
      Dec(Points, 5);
    end;
  end
  else FUnitHits := Value;
end;

procedure THero.SetUnitMoves(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FMoves > 50 then Value := 50 - FHeroResource.FMoves;
  if Value > FUnitMoves then
  begin
    Points := GetSkillPoints;
    while (Points >= 2) and (Value <> FUnitMoves) do
    begin
      Inc(FUnitMoves);
      Dec(Points, 2);
    end;
  end
  else FUnitMoves := Value;
end;

procedure THero.SetUnitResistance(Value: Shortint);
var Points: Integer;
begin
  if Value < 0 then Value := 0;
  if Value + FHeroResource.FResistance > 10 then Value := 10 - FHeroResource.FResistance;
  if Value > FUnitResistance then
  begin
    Points := GetSkillPoints;
    while (Points >= 5) and (Value <> FUnitResistance) do
    begin
      Inc(FUnitResistance);
      Dec(Points, 5);
    end;
  end
  else FUnitResistance := Value;
end;

procedure THero.LinkToResource;
begin
  FHeroResource := AoWHSSet.FHeroResources.GetHeroResource(FHeroResourceIndex);
end;

procedure THero.Loaded;
begin
  if FHeroResource <> nil then
  begin
    UpdateDefaultAbilities(FHeroResource.FAbilities);
    SetUnitAttack(FUnitAttack);
    SetUnitDefense(FUnitDefense);
    SetUnitResistance(FUnitResistance);
    SetUnitDamage(FUnitDamage);
    SetUnitHits(FUnitHits);
    SetUnitMoves(FUnitMoves);
  end;
end;

procedure THero.ListSpells(var List: TSpellList);
begin
  AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.ListSpells(List, [stCombat, stUnit, stGlobal]);
end;

procedure THero.ExecuteUpgradeHeroAI;
var
  Choices: TDoubleItemList;
  Points, Index: Integer;
  Choice: TDoubleItem;
begin
  Choices := TDoubleItemList.Create;
  repeat
    Choices.Clear;
    Points := GetSkillPoints;
    if (Points >= 5) and (FUnitAttack + FHeroResource.FAttack < 10) then Choices.AddAB(0, 10);
    if (Points >= 5) and (FUnitDefense + FHeroResource.FDefense < 10) then Choices.AddAB(1, 25);
    if (Points >= 5) and (FUnitResistance + FHeroResource.FResistance < 10) then Choices.AddAB(2, 10);
    if (Points >= 10) and (FUnitDamage + FHeroResource.FDamage < 10) then Choices.AddAB(3, 10);
    if (Points >= 5) and (FUnitHits + FHeroResource.FHits < 30) then Choices.AddAB(4, 10);
    if AoWHSSet.FAbilityControl.GetAbility(46).CanExpand(Self) and
      (Points >= AoWHSSet.FAbilityControl.GetAbility(46).ExpandCost(Self)) then Choices.AddAB(5, 10);
    if AoWHSSet.FAbilityControl.GetAbility(22).CanExpand(Self) and
      (Points >= AoWHSSet.FAbilityControl.GetAbility(22).ExpandCost(Self)) then Choices.AddAB(6, 10);
    if AoWHSSet.FAbilityControl.GetAbility(52).CanExpand(Self) then
      if Points >= AoWHSSet.FAbilityControl.GetAbility(52).ExpandCost(Self) then Choices.AddAB(7, 9999)
      else Choices.AddAB(7, 100);
    if Choices.Count <> 0 then
    begin
      RandSeed := AoWHSMap.Random($FFFFFF);
      Index := Choices.RandomChanceItemB(0);
      Choice := Choices[Index];
      case Choice.A of
        0: SetUnitAttack(FUnitAttack + 1);
        1: SetUnitDefense(FUnitDefense + 1);
        2: SetUnitResistance(FUnitResistance + 1);
        3: SetUnitDamage(FUnitDamage + 1);
        4: SetUnitHits(FUnitHits + 1);
        5: ExpandAbility(46);
        6: ExpandAbility(22);
        7: if Points >= AoWHSSet.FAbilityControl.GetAbility(52).ExpandCost(Self) then ExpandAbility(52)
           else Points := 0;
      end;
    end;
  until (Choices.Count = 0) or (GetSkillPoints = 0) or (Points = 0);
  Choices.Free;
end;

procedure THero.ValidateHeroUpgrade;
var
  X, Y, L: Shortint;
  Level, OldLevel: Integer;
  Log: THeroUpgradeEventLog;
begin
  GetLocation(X, Y, L);
  if (FPlayer <> 0) and (X <> -1) then
  begin
    FUpgradePending := False;
    Level := GetLevel;
    if Level < GetLevelMax then
    begin
      if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU2) then
        SetExperience(GetExperience + (HeroExperienceTable[Level div 5].DailyExperience + 1))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU3) then
        SetExperience(GetExperience + (HeroExperienceTable[Level div 5].DailyExperience + 2))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU4) then
        SetExperience(GetExperience + (HeroExperienceTable[Level div 5].DailyExperience + 3))
      else if (FPlayer > 0) and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptCPU5) then
        SetExperience(GetExperience + (HeroExperienceTable[Level div 5].DailyExperience + 4))
      else SetExperience(GetExperience + HeroExperienceTable[Level div 5].DailyExperience);
      Level := GetLevel;
    end;
    if FLevel < Level then
    begin
      FUpgradePending := True;
      OldLevel := FLevel;
      FLevel := Level;
      Log := THeroUpgradeEventLog.Create(nil);
      Log.FOldLevel := OldLevel;
      Log.FNewLevel := FLevel;
      Log.FDay := AoWHSMap.FPlayers.GetPlayers(FPlayer).FDay;
      Log.FPlayer := FPlayer;
      Log.FUnitID := FUnitID;
      DistributeLocationEventLog(Log, FPlayer, X, Y, L, True);
      Log.Release;
      if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman then ExecuteUpgradeHeroAI;
    end;
  end;
end;

procedure THero.NewTurn(Player: Shortint);
var Log: TSpellCastEventLog;
begin
  inherited NewTurn(Player);
  if Player = FPlayer then
  begin
    ValidateHeroUpgrade;
    Player := GetCastingPointsMax; FCastingPoints := Player;
    if (FCastingSpellID <> 0) and (FCastingMana < FCastingProgress) then
    begin
      Inc(FCastingMana, Player);
      FCastingPoints := 0;
      if FCastingMana > FCastingProgress then
      begin
        FCastingPoints := FCastingMana - FCastingProgress;
        FCastingMana := FCastingProgress;
      end;
      if FCastingMana = FCastingProgress then
      begin
        Log := TSpellCastEventLog.Create(nil);
        Log.FPlayer := FPlayer;
        Log.FUnitID := FUnitID;
        Log.FSpellID := FCastingSpellID;
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FEventLogbook.AddEvent(Log);
        if (AoWHSMap.FSeatedPlayer = FPlayer) and
          (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType = ptHuman) then
          Log.Execute(False, etEvent, nil);
        Log.Release;
      end;
    end;
  end;
end;

procedure THero.SetAbSet(A1: Integer; A2: Byte);
begin inherited SetAbSet(A1, A2); end;

function THero.GetAbSet(A1: Integer): Boolean;
begin Result := inherited GetAbSet(A1); end;

function THero.GetUnitAbilityEnabled(AbilityID: Integer): Boolean;
begin Result := inherited GetAbilityEnabled(AbilityID); end;

function THero.GetAbilityCount: Integer;
var Count: Integer;
begin
  Result := GetAbCount;
  Count := FHeroItems.GetAbilityCount;
  if Count > Result then Result := Count;
  Count := FInventory.GetAbilityCount;
  if Count > Result then Result := Count;
end;

function THero.GetSuperlativeEnabledAbOwner(AbilityID: Integer): TAbilityOwner;
var Candidate, Best: TAbilityOwner;
begin
  if GetAbEnabled(AbilityID) then Best := Self else Best := nil;
  Candidate := FHeroItems.GetSuperlativeEnabledAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Candidate := FInventory.GetSuperlativeEnabledAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Result := Best;
end;

function THero.GetSuperlativeAbOwner(AbilityID: Integer): TAbilityOwner;
var Candidate, Best: TAbilityOwner;
begin
  if GetAbSet(AbilityID) then Best := Self else Best := nil;
  Candidate := FHeroItems.GetSuperlativeAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Candidate := FInventory.GetSuperlativeAbOwner(AbilityID);
  if Candidate <> nil then
    if (Best = nil) or (Candidate.GetAbLevel(AbilityID) > Best.GetAbLevel(AbilityID)) then
      Best := Candidate;
  Result := Best;
end;

function THero.GetAbilityOwner(AbilityID: Integer): TAbilityOwner;
begin Result := GetSuperlativeAbOwner(AbilityID); end;

function THero.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin
  Result := inherited GetAbilityEnabled(AbilityID);
  if not Result then Result := FHeroItems.GetAbilityEnabled(AbilityID);
  if not Result then Result := FInventory.GetAbilityEnabled(AbilityID);
end;

function THero.GetAbilitySet(AbilityID: Integer): Boolean;
begin
  Result := inherited GetAbilitySet(AbilityID);
  if not Result then Result := FHeroItems.GetAbilitySet(AbilityID);
  if not Result then Result := FInventory.GetAbilitySet(AbilityID);
end;

function THero.GetAbilityName(AbilityID: Integer): string;
var AOwner: TAbilityOwner;
begin
  AOwner := GetSuperlativeAbOwner(AbilityID);
  if AOwner = nil then AOwner := Self;
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetName(AOwner);
end;

function THero.GetAbilityLevel(AbilityID: Integer): Integer;
var AOwner: TAbilityOwner;
begin
  AOwner := GetSuperlativeAbOwner(AbilityID);
  if AOwner = nil then AOwner := Self;
  Result := AoWHSSet.FAbilityControl.GetAbility(AbilityID).GetLevel(AOwner);
end;

function THero.GetInherentAttack: Shortint;
begin Result := FHeroResource.FAttack + FUnitAttack; end;

function THero.GetAttack: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbAttack(I));
  end;
  Result := FHeroItems.GetAttack + (FUnitAttack + Result + FHeroResource.FAttack);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentDefense: Shortint;
begin Result := FHeroResource.FDefense + FUnitDefense; end;

function THero.GetDefense: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbDefense(I));
  end;
  Result := FHeroItems.GetDefense + (FUnitDefense + Result + FHeroResource.FDefense) + P2MoraleDefense[GetMorale];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentDamage: Shortint;
begin Result := FHeroResource.FDamage + FUnitDamage; end;

function THero.GetDamage: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbDamage(I));
  end;
  Result := FHeroItems.GetDamage + (FUnitDamage + Result + FHeroResource.FDamage);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetInherentResistance: Shortint;
begin Result := FHeroResource.FResistance + FUnitResistance; end;

function THero.GetResistance: Shortint;
var AOwner: TAbilityOwner; I, Count: Integer;
begin
  Count := GetAbilityCount;
  Result := 0;
  { Original includes the ability-count index in the scan. }
  for I := 0 to Count do
  begin
    AOwner := GetSuperlativeEnabledAbOwner(I);
    if AOwner <> nil then Inc(Result, AOwner.GetAbResistance(I));
  end;
  Result := FHeroItems.GetResistance + (FUnitResistance + Result + FHeroResource.FResistance) + P2MoraleResistance[GetMorale];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;

function THero.GetHits: Shortint;
begin
  Result := FHeroResource.FHits + FUnitHits;
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 30 then Result := 30;
end;

function THero.GetMoves: Shortint;
begin
  Result := FHeroResource.FMoves + FUnitMoves;
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 50 then Result := 50;
end;

function THero.GetPowerGeneration: Integer;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 5
  else Result := 0;
end;

function THero.GetCastingPointsMax: Shortint;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 10
  else Result := 0;
end;

function THero.GetCastingPoints: Shortint;
begin Result := FCastingPoints; end;

procedure THero.SetCastingPoints(Value: Shortint);
begin
  if Value > GetCastingPointsMax then Value := GetCastingPointsMax;
  FCastingPoints := Value;
  Changed;
end;

function THero.GetPreviewImage: TLibraryImage;
begin
  if FHeroResource <> nil then Result := FHeroResource.GetPreviewImage
  else Result := nil;
end;

procedure THero.ResetSkillPoints;
begin
  AssignAb(FHeroResource.FAbilities);
  FUnitAttack := 0;
  FUnitDefense := 0;
  FUnitDamage := 0;
  FUnitHits := 0;
  FUnitMoves := 0;
  FUnitResistance := 0;
end;

procedure THero.ResetResourceSettings;
begin
  AssignAb(FHeroResource.FAbilities);
  FUnitAttack := 0;
  FUnitDefense := 0;
  FUnitDamage := 0;
  FUnitHits := 0;
  FUnitMoves := 0;
  FUnitResistance := 0;
  FExperience := 0;
  FRace := FHeroResource.FRace;
  if (AoWHSMap <> nil) and (msEditting in AoWHSMap.Status) then FFaceIndex := FHeroResource.FFaceIndex;
  Changed;
end;

procedure THero.UpdateSettings;
begin
  FMovePoints := GetMoves;
  FHitPoints := GetHits;
  FCastingPoints := GetCastingPointsMax;
  FLevel := ExperienceToLevel(FExperience);
  Changed;
end;

procedure THero.SetRace(Value: Shortint);
var Found: Boolean; Index: Integer; Resource: THeroResource;
begin
  if FRace <> Value then
  begin
    Found := False;
    Index := AoWHSSet.FHeroResources.GetCount;
    while not Found and (Index <> 0) do
    begin
      Dec(Index);
      Resource := AoWHSSet.FHeroResources.GetHeroResource(Index);
      Found := (Resource <> nil) and (Resource.FRace = Value) and (GetHeroType = Resource.FHeroType);
    end;
    if Found then SetHeroResourceIndex(Index);
  end;
end;

function THero.GetFace: TLibraryImage;
var Resource: TFaceResource; Index: Integer;
begin
  if not GetAbilityEnabled(126) then
  begin
    Resource := AoWHSSet.FFaceResources.GetFaceResource(FFaceIndex);
    if Resource <> nil then Result := Resource.GetCellImage
    else Result := nil;
  end
  else
  begin
    Index := TCosmeticSurgeryEnchantment(TUnitEnchantmentAbilityData(GetAbilityData(126)).FEnchantment).FFaceIndex;
    Result := AoWHSSet.FFaceResources.GetFaceResource(Index).GetCellImage;
  end;
end;

procedure THero.SetFaceIndex(Value: Integer);
begin FFaceIndex := Value; end;

procedure THero.SetHeroResourceIndex(Value: Integer);
begin
  if (AoWHSSet.FHeroResources.GetHeroResource(Value) <> nil) and (Value <> FHeroResourceIndex) then
  begin
    FHeroResourceIndex := Value;
    FHeroResource := AoWHSSet.FHeroResources.GetHeroResource(Value);
    ResetResourceSettings;
  end;
end;

procedure THero.ReadWrite(Stream: Engine.TEStorageStream);
var Player: Shortint; OldExperience: Integer;
begin
  Player := FPlayer;
  Stream.rwInteger(FHeroResourceIndex, 8);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then LinkToResource;
  inherited ReadWrite(Stream);
  if (Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead]) and
    (hmUpdatingFromLibrary in FMode) then FPlayer := Player;
  Stream.rwInteger(FFaceIndex, 7);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then
    Stream.rwInteger(OldExperience, 9)
  else OldExperience := 0;
  Stream.rwString(FHeroName, 10);
  Stream.rwString(FNickname, 11);
  Stream.rwByte(Byte(FRace), 12);
  Stream.rwByte(Byte(FCastingPoints), 13);
  Stream.rwInteger(FCastingSpellID, 14);
  Stream.rwData(FGender, 1, 15);
  Stream.rwByte(Byte(FUnitAttack), 16);
  Stream.rwByte(Byte(FUnitDefense), 17);
  Stream.rwByte(Byte(FUnitDamage), 18);
  Stream.rwByte(Byte(FUnitHits), 19);
  Stream.rwByte(Byte(FUnitMoves), 20);
  Stream.rwByte(Byte(FUnitResistance), 21);
  Stream.rwByte(FLevel, 22);
  Stream.rwBool(FUpgradePending, 23);
  Stream.rwInteger(FExperience, 24);
  Stream.rwData(FHeroStatus, 1, 25);
  Stream.rwInteger(FDeathDay, 26);
  Stream.rwByte(Byte(FDeathPlayer), 27);
  if (Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead]) and (FExperience = 0) then
    FExperience := LevelToExperience((OldExperience shr 5) + 1);
  Stream.rwByte(Byte(FMovePoints), 29);
  Stream.rwByte(Byte(FHitPoints), 30);
  Stream.rwInteger(FCastingMana, 31);
  Stream.rwBool(FCastSpellInstantly, 33);
  Stream.rwInteger(FCastingProgress, 34);
  Stream.rwIntegerEx(FLibraryID, -1, 35);
  if not (hmUpdatingFromLibrary in FMode) then
  begin
    Stream.rwEObject(FInventory, 36);
    Stream.rwEObject(FHeroItems, 37);
  end;
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FLibraryName, 38);
  Stream.rwInteger(FUsedSkillPoints, 39);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then Loaded;
end;

procedure THero.EditDropMsg(var Msg: TEMsg);
var Level: TMapLevel; L, X, Y, Player: Integer; Placed: Boolean;
begin
  Level := TMapLevel(Msg.Param[0]);
  L := Msg.Data[1];
  HPtoHX(Msg.Value, Msg.Data[0], X, Y);
  if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
  begin
    if msEditting in AoWHSMap.Status then
    begin
      Player := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetPlayer;
      if Player = -1 then Player := AoWHSMap.FEditorPlayer;
    end
    else Player := -1;
    Placed := Place(X, Y, L, Player, []) <> nil;
  end
  else Placed := False;
  if Placed then Msg.Result := 0 else Msg.Result := -1;
end;

procedure THero.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    if (AoWHSMap.FPlayers.GetCount <= FPlayer) and (Owner = nil) then
    begin
      SetPlayer(-1);
      Exit;
    end;
  end
  else if Msg.MsgID = $10005 then EditDropMsg(Msg);
end;

function THero.CreateHeroUpdateTE: THeroUpdateTE;
begin
  Result := THeroUpdateTE.Create(nil);
  Result.FUnitID := FUnitID;
end;

function THero.GetItemsOnGround: TItemList;
var Map: TAbstractAoWCombatMap;
begin
  Map := AoWHSMap.FCombatMap;
  if Map <> nil then Result := Map.GetHeroItemsOnGround(Self)
  else Result := AoWHSMap.GetHeroItemsOnGround(Self);
end;

function THero.CanUseItem(ItemID: Integer; var Reason: string): Boolean;
var Item: TItem;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then Result := Item.CanUse(Self, Reason)
  else
  begin
    Result := False;
    Reason := '';
  end;
end;

function THero.UseItem(ItemID: Integer): Boolean;
var Item: TItem;
begin
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then Result := Item.Use(Self)
  else Result := False;
end;

function THero.CanPlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var Item: TItem; IX, IY, IL, X, Y, L: Shortint;
begin
  Result := False;
  Item := AoWHSMap.FItemControl.FindItem(ItemID);
  if Item <> nil then
  begin
    GetLocation(X, Y, L);
    Item.GetLocation(IX, IY, IL);
    if (AoWHSMap.FCombatMap <> nil) or ((X = IX) and (Y = IY) and (L = IL)) then
      if Position in [ipAttackSlot..ipRightRingSlot] then Result := FHeroItems.CanPlaceItem(Item, Position)
      else if Position in [ipInventorySlot1..ipInventorySlot8] then Result := FInventory.GetSlot(Position) = nil
      else Result := True;
  end;
end;

function THero.CanSwapItem(ItemID1, ItemID2: Integer): Boolean;
var Item1, Item2: TItem;
begin
  Result := True;
  Item1 := AoWHSMap.FItemControl.FindItem(ItemID1);
  Item2 := AoWHSMap.FItemControl.FindItem(ItemID2);
  if (Item1 <> nil) and (Item2 <> nil) and (Item1 <> Item2) then
  begin
    if (FHeroItems = Item1.Owner) or (FHeroItems = Item2.Owner) then
      Result := Item1.FItemType = Item2.FItemType;
  end
  else Result := False;
end;

function THero.SwapItem(ItemID1, ItemID2: Integer): Boolean;
var TE: THeroUpdateTE;
begin
  if CanSwapItem(ItemID1, ItemID2) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmSwapItem;
    TE.FItemID := ItemID1;
    TE.FParameter := ItemID2;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function THero.PlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var TE: THeroUpdateTE;
begin
  if CanPlaceItem(ItemID, Position) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmPlaceItem;
    TE.FItemID := ItemID;
    TE.FParameter := Ord(Position);
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function THero.ExecuteSwapItem(ItemID1, ItemID2: Integer): Boolean;
var Item1, Item2: TItem; Owner1, Owner2: TItemList; Index1, Index2: Integer;
begin
  if CanSwapItem(ItemID1, ItemID2) then
  begin
    Item1 := AoWHSMap.FItemControl.FindItem(ItemID1);
    Item2 := AoWHSMap.FItemControl.FindItem(ItemID2);
    Owner1 := TItemList(Item1.Owner);
    Owner2 := TItemList(Item2.Owner);
    Owner1.BeginUpdate;
    Owner2.BeginUpdate;
    Index1 := Item1.Owner.FindChildIndex(Item1);
    Index2 := Item2.Owner.FindChildIndex(Item2);
    Item1.SetOwner(nil);
    Item2.SetOwner(nil);
    if csArrayMode in Owner1.GetControlStyle then Item2.SetArrayOwner(Owner1, Index1)
    else Item2.SetOwner(Owner1);
    if csArrayMode in Owner2.GetControlStyle then Item1.SetArrayOwner(Owner2, Index2)
    else Item1.SetOwner(Owner2);
    Owner2.EndUpdate;
    Owner1.EndUpdate;
    Changed;
    Result := True;
  end
  else Result := False;
end;

function THero.AutoPlaceItem(Item: TItem): Boolean;
var Position: THeroItemPosition; Slot: Integer;
begin
  Result := False;
  Position := FHeroItems.GetItemTypePosition(Item.FItemType);
  if FHeroItems.CanPlaceItem(Item, Position) then
  begin
    FHeroItems.PlaceItem(Item, Position);
    Result := True;
  end
  else
  begin
    Slot := FInventory.GetFreeSlot;
    if Slot <> -1 then
    begin
      Item.SetArrayOwner(FInventory, Slot);
      Result := True;
    end;
  end;
end;

function THero.ExecutePlaceItem(ItemID: Integer; Position: THeroItemPosition): Boolean;
var Item: TItem; Map: TAbstractAoWCombatMap;
begin
  if CanPlaceItem(ItemID, Position) then
  begin
    Item := AoWHSMap.FItemControl.FindItem(ItemID);
    case Position of
      ipGround:
        begin
          Map := AoWHSMap.FCombatMap;
          if Map <> nil then Map.DropHeroItem(Self, Item)
          else AoWHSMap.DropHeroItem(Self, Item);
          Changed;
        end;
      ipAttackSlot..ipRightRingSlot:
        begin FHeroItems.PlaceItem(Item, Position); Changed; end;
      ipInventorySlot1..ipInventorySlot8:
        begin Item.SetArrayOwner(FInventory, Ord(Position) - 6); Changed; end;
    end;
    Result := True;
  end
  else Result := False;
end;

function THero.ExecuteStartCasting(SpellID: Integer): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID <> 0 then ExecuteCancelCasting;
  Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
  if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) and
    (CastingMana(Spell) > FCastingPoints) then
  begin
    FCastingProgress := CastingMana(Spell);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana - FCastingProgress);
    FCastingMana := FCastingPoints;
    FCastingPoints := 0;
    if AoWHSMap.FSeatedPlayer = FPlayer then
      AoWHSMap.ShowMessage(Format(TranslateRStr(CastingXInProgressRStr), [Spell.FSpellName]));
    FCastingSpellID := SpellID;
    Changed;
    Result := True;
  end
  else Result := False;
end;

procedure THero.RemoveCastingReadyEventLog;
var Logbook: TEventLogbook; I: Integer;
begin
  Logbook := AoWHSMap.FPlayers.GetPlayers(FPlayer).FEventLogbook;
  for I := Logbook.GetCount - 1 downto 0 do
    if (Logbook.GetLogs(I) is TSpellCastEventLog) and
      (TSpellCastEventLog(Logbook.GetLogs(I)).FUnitID = FUnitID) then Logbook.GetLogs(I).SetOwner(nil);
end;

function THero.ExecuteCancelCasting: Boolean;
begin
  if FCastingSpellID <> 0 then
  begin
    RemoveCastingReadyEventLog;
    if GetCastingPointsMax < FCastingPoints + FCastingMana then FCastingPoints := GetCastingPointsMax
    else Inc(FCastingPoints, FCastingMana);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana + FCastingProgress);
    FCastingSpellID := 0;
    FCastingMana := 0;
    FCastingProgress := 0;
    Changed;
    Result := True;
  end
  else Result := False;
end;

procedure THero.CastingDone(SpellID, Mana: Integer);
begin
  if SpellID = FCastingSpellID then
  begin























































































































































    Assert(CastingReady);
    FCastingMana := 0;
    FCastingProgress := 0;
    FCastingSpellID := 0;
    RemoveCastingReadyEventLog;
  end
  else
  begin
    if FCastingSpellID <> 0 then ExecuteCancelCasting;
    if not AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.SetMana(
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana - Mana);
      Dec(FCastingPoints, Mana);
    end;
  end;
end;

function THero.CastingMana(Spell: TSpell): Integer;
begin
  Result := Spell.FBaseManaCost;
  if AoWHSMap.FGlobalMagicControl.GetSphereManaDoubled(Spell.FMagicSphere) then Result := Result * 2;
end;

function THero.CastingTurns(Spell: TSpell): Integer;
var Mana, Points: Integer;
begin
  Mana := CastingMana(Spell);
  Points := FCastingPoints + FCastingMana;
  if GetCastingPointsMax < Points then Points := GetCastingPointsMax;
  if Points < Mana then
  begin
    Result := (Mana - Points) div GetCastingPointsMax;
    if (Mana - Points) mod GetCastingPointsMax <> 0 then Inc(Result);
  end
  else Result := 0;
end;

function THero.Casting: Boolean;
begin Result := FCastingSpellID <> 0; end;

function THero.CastingReady: Boolean;
begin Result := (FCastingSpellID <> 0) and (FCastingMana = FCastingProgress); end;

function THero.CastingTurnsLeft: Integer;
begin
  if (FCastingSpellID <> 0) and (GetCastingPointsMax <> 0) then
    if FCastingMana < FCastingProgress then
    begin
      Result := (FCastingProgress - FCastingMana) div GetCastingPointsMax;
      if (FCastingProgress - FCastingMana) mod GetCastingPointsMax <> 0 then Inc(Result);
    end
    else Result := 0
  else Result := -1;
end;

function THero.CanCastSpellInstantly(SpellID, Mana: Integer; var Reason: string): Boolean;
begin
  if not AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    if (Mana <= FCastingPoints) or ((SpellID = FCastingSpellID) and Casting and CastingReady) then
      Result := CanCastSpell(SpellID, Reason)
    else
    begin
      Result := False;
      Reason := TranslateRStr(P2NotEnoughCastingPointsRStr);
    end
  else Result := True;
end;

function THero.CanCastSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID = 0 then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) or
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
      Result := Spell.CanActivate(Self, Reason)
    else
    begin
      Result := False;
      Reason := TranslateRStr(NotEnoughManaRStr);
    end;
  end
  else
  begin
    Result := SpellID = FCastingSpellID;
    if Result and (AoWHSSet.FSpellControl.GetSpell(SpellID).FSpellType = stGlobal) and
      (AoWHSMap.FCombatMap <> nil) then
    begin
      Reason := TranslateRStr(CannotCastSpellInCombatRStr);
      Result := False;
    end;
  end;
end;

function THero.CastSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell; TE: THeroUpdateTE;
begin
  if CanCastSpell(SpellID, Reason) then
  begin
    if FCastingSpellID = 0 then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
      if (CastingMana(Spell) <= FCastingPoints) or
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
      begin
        Result := Spell.CanActivate(Self, Reason);
        if Result then Result := Spell.Activate(Self);
      end
      else if not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
      begin
        if AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell) then
        begin
          TE := CreateHeroUpdateTE;
          TE.FMode := hmStartCasting;
          TE.FItemID := SpellID;
          AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
          TE.Release;
          Result := True;
        end
        else
        begin
          Result := False;
          Reason := TranslateRStr(NotEnoughManaRStr);
        end;
      end
      else Result := False;
    end
    else if CastingReady then
    begin
      Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
      Result := Spell.CanActivate(Self, Reason);
      if Result then Result := Spell.Activate(Self);
    end
    else Result := True;
  end
  else Result := False;
end;

function THero.CanCastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  if FCastingSpellID = 0 then
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    if (CastingMana(Spell) <= FCastingPoints) or
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
    begin
      if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FMana >= CastingMana(Spell)) or
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
        Result := Spell.CanActivateCombat(Self, Reason)
      else
      begin
        Result := False;
        Reason := TranslateRStr(NotEnoughManaRStr);
      end;
    end
    else
    begin
      Result := False;
      Reason := TranslateRStr(NotEnoughChannelingPointsRStr);
    end;
  end
  else
  begin
    Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
    Result := (Spell.FSpellType in [stCombat, stUnit]) and
      CanCastSpellInstantly(SpellID, CastingMana(Spell), Reason);
  end;
end;

function THero.CastCombatSpell(SpellID: Integer; var Reason: string): Boolean;
var Spell: TSpell;
begin
  Spell := AoWHSSet.FSpellControl.GetSpell(SpellID);
  if CanCastCombatSpell(SpellID, Reason) then
  begin
    Result := Spell.CanActivateCombat(Self, Reason);
    if Result then Result := Spell.ActivateCombat(Self);
  end
  else Result := False;
end;

function THero.CancelCasting: Boolean;
var TE: THeroUpdateTE;
begin
  { Original tests -1 although zero is the idle spell ID. }
  if (FCastingSpellID <> -1) and not AoWHSMap.FPlayers.GetPlayers(FPlayer).GetBusy then
  begin
    TE := CreateHeroUpdateTE;
    TE.FMode := hmCancelCasting;
    AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

procedure THeroUpdateTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitID, 20);
  Stream.rwData(FMode, 1, 21);
  Stream.rwInteger(FItemID, 22);
  Stream.rwInteger(FParameter, 23);
end;

class function THeroUpdateTE.ClassID: Integer;
begin Result := $21105; end;

function THeroUpdateTE.Execute(TE: TTokenExecuter): TExecuteResult;
var Success: Boolean; Hero: THero;
begin
  Success := False;
  Hero := THero(AoWHSMap.FUnitControl.FindUnit(FUnitID));
  if ((AoWHSMap.FCombat = nil) and (AoWHSMap.FCurrentPlayer = Hero.FPlayer)) or
    ((AoWHSMap.FCombat <> nil) and
    (AoWHSMap.FCombat.FCombatData.FPlayers.GetPlayers(AoWHSMap.FCombat.FCombatData.FCurrentPlayer).FPlayer = Hero.FPlayer)) then
    case FMode of
      hmPlaceItem: Success := Hero.ExecutePlaceItem(FItemID, THeroItemPosition(FParameter));
      hmSwapItem: Success := Hero.ExecuteSwapItem(FItemID, FParameter);
      hmStartCasting: Success := Hero.ExecuteStartCasting(FItemID);
      hmCancelCasting: Success := Hero.ExecuteCancelCasting;
    end;
  if Success then Result := erDone else Result := erDoneHalt;
end;

constructor THeroResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FAbilities := THeroResourceAbilityOwner.Create(nil);
  FAttack := 3;
  FDefense := 3;
  FDamage := 3;
  FHits := 5;
  FMoves := 28;
  FResistance := 2;
end;

destructor THeroResource.Destroy;
begin FAbilities.Free; inherited Destroy; end;

class function THeroResource.ClassID: Integer;
begin Result := $20231; end;

function THeroResource.ResourceUserClassID: Integer;
begin Result := $20230; end;

function THeroResource.HeroResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;

function THeroResource.UsedSkillPoints: Integer;
var I: Integer;
begin
  Result := FAttack * 5 + FDefense * 5 + FDamage * 10 + FResistance * 5 + FHits * 5 + FMoves * 2;
  for I := FAbilities.GetAbCount - 1 downto 0 do
    if FAbilities.GetAbSet(I) then
      Inc(Result, AoWHSSet.FAbilityControl.GetAbility(I).GetSkillPoints(FAbilities));
end;

procedure THeroResource.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 10);
  Stream.rwByte(Byte(FRace), 11);
  Stream.rwData(FHeroType, 1, 12);
  Stream.rwData(FAlignment, 1, 13);
  if FAlignment > alNone then FAlignment := alNeutral;
  Stream.rwBool(FHidden, 14);
  Stream.rwByte(Byte(FAttack), 15);
  Stream.rwByte(Byte(FDefense), 16);
  Stream.rwByte(Byte(FDamage), 17);
  Stream.rwByte(Byte(FHits), 18);
  Stream.rwByte(Byte(FMoves), 19);
  Stream.rwByte(Byte(FResistance), 20);
  Stream.rwEObject(FAbilities, 29);
  Stream.rwInteger(FFaceIndex, 30);
end;

constructor THeroResourceList.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]); end;

function THeroResourceList.GetHeroResource(Index: Integer): THeroResource;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := THeroResource(FChildren.List^[Index])
  else Result := nil;
end;

function THeroResourceList.CreateHeroResourceStrings(HeroTypes: THeroTypes): TStringList;
var I: Integer; Resource: THeroResource; List: TStringList;
begin
  List := TStringList.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    Resource := THeroResource(FChildren.List^[I]);
    if (Resource <> nil) and ((euDesigner in AoWEngine.FUser) or not Resource.FHidden) and
      (Resource.FHeroType in HeroTypes) then List.AddObject(Resource.FName, TObject(I));
  end;
  Result := List;
end;

function THeroResourceList.Find(Race: Integer; HeroType: THeroType): Integer;
var I: Integer; Resource: THeroResource;
begin
  I := 0;
  Result := -1;
  while (I < FChildren.Count) and (Result = -1) do
  begin
    Resource := THeroResource(FChildren.List^[I]);
    if (Resource <> nil) and (Race = Resource.FRace) and (HeroType = Resource.FHeroType) then Result := I;
    Inc(I);
  end;
end;

function THeroList.FindHero(ID: Integer): THero;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> FChildren.Count) and (Result = nil) do
  begin
    if ID = THero(FChildren.List^[I]).FUnitID then Result := THero(FChildren.List^[I]);
    Inc(I);
  end;
end;

function THeroList.GetHero(Index: Integer): THero;
begin
  if (Index >= 0) and (Index < FChildren.Count) then Result := THero(FChildren.List^[Index])
  else Result := nil;
end;

constructor THeroControl.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FOnChanged := TEventList.Create;
  FOnHeroChanged := TEventList.Create;
  FHeroes := THeroList.Create(nil);
end;

destructor THeroControl.Destroy;
var I: Integer;
begin
  BeginUpdate;
  for I := FHeroes.GetCount - 1 downto 0 do UnRegisterHero(THero(FHeroes.FChildren.List^[I]));
  FHeroes.Free;
  FOnHeroChanged.Free;
  FOnChanged.Free;
  inherited Destroy;
end;

procedure THeroControl.Changed;
begin if FUpdateCount = 0 then FOnChanged.TriggerNotifyEvents(Self); end;

procedure THeroControl.ReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FHeroes, 20);
  if Stream.StorageMode * [smRead, smTextOnly, smSetupCompare, smCompare] = [smRead] then
    for I := FHeroes.GetCount - 1 downto 0 do FHeroes.GetHero(I).FRegistered := True;
end;

procedure THeroControl.BeginUpdate;
begin Inc(FUpdateCount); end;

procedure THeroControl.EndUpdate;
begin Dec(FUpdateCount); if FUpdateCount = 0 then Changed; end;

procedure THeroControl.UpdateLibraryHeroes;
var I: Integer;
begin
  BeginUpdate;
  for I := FHeroes.GetCount - 1 downto 0 do THero(FHeroes.FChildren.List^[I]).UpdateFromLibrary;
  EndUpdate;
end;

function THeroControl.GetHero(Index: Integer): THero;
begin Result := THero(FHeroes.FChildren.List^[Index]); end;

function THeroControl.GetCount: Integer;
begin Result := FHeroes.GetCount; end;

function THeroControl.FindID(ID: Integer): THero;
begin Result := FHeroes.FindHero(ID); end;

function THeroControl.IndexOf(Hero: THero): Integer;
begin Result := FHeroes.FChildren.IndexOf(Hero); end;

function THeroControl.IndexOfLibraryEx(const LibraryName: string; LibraryID: Integer): Integer;
var Hero: THero;
begin
  Result := FHeroes.GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    Hero := THero(FHeroes.FChildren.List^[Result]);
    if (Hero.FLibraryID = LibraryID) and (CompareText(Hero.GetLibraryName, LibraryName) = 0) then Exit;
  end;
  Result := -1;
end;

procedure THeroControl.ValidateLibraryHeroes;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (Hero <> nil) and (Hero.FLibraryID <> -1) and
      (AoWHSSet.FHeroLibraries.FindHero(Hero.FLibraryName, Hero.FLibraryID) = nil) then
      if Hero.Owner = nil then Hero.Free else Hero.FLibraryID := -1;
  end;
end;

procedure THeroControl.Activate;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (not (usActivated in Hero.FUnitStatus)) and (Hero.Owner = nil) then Hero.Activate;
  end;
end;

procedure THeroControl.Deactivate;
var I: Integer; Hero: THero;
begin
  for I := FHeroes.GetCount - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if (usActivated in Hero.FUnitStatus) and (Hero.Owner = nil) then Hero.Deactivate;
  end;
end;

function THeroControl.RegisterHero(Hero: THero): Boolean;
begin
  if not Hero.FRegistered then
  begin Hero.FRegistered := True; FHeroes.AddChild(Hero); Changed; Result := True; end
  else Result := False;
end;

procedure THeroControl.UnRegisterHero(Hero: THero);
begin
  if Hero.FRegistered then
  begin Hero.FRegistered := False; FHeroes.RemoveChild(Hero); Changed; end;
end;

procedure THeroControl.HeroChanged(Hero: THero);
begin if not (msDestroying in AoWHSMap.Status) then FOnHeroChanged.TriggerNotifyEvents(Hero); end;

function THeroControl.GetAverageFreeHeroLevel: Integer;
var I, Count: Integer; Hero: THero;
begin
  Result := 0;
  Count := 0;
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) then
    begin Inc(Result, Hero.GetLevel); Inc(Count); end;
  end;
  if Count <> 0 then Result := Result div Count else Result := 0;
end;

function THeroControl.GetMinFreeHeroLevel: Integer;
var I: Integer; Hero: THero;
begin
  Result := 30;
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if not (hsDied in Hero.FHeroStatus) and (Hero.FPlayer <= 0) and (Result > Hero.GetLevel) then
      Result := Hero.GetLevel;
  end;
end;

procedure THeroControl.ListDeadHeroes(List: THeroList);
var I: Integer; Hero: THero;
begin
  for I := FHeroes.FChildren.Count - 1 downto 0 do
  begin
    Hero := THero(FHeroes.FChildren.List^[I]);
    if hsDied in Hero.FHeroStatus then List.AddChild(Hero);
  end;
end;

procedure THeroControl.MsgProc(var Msg: TEMsg; Sender: TEObject);
var I: Integer;
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin ValidateLibraryHeroes; Activate; end
  else if Msg.MsgID = $20010017 then Deactivate
  else
    for I := FHeroes.GetCount - 1 downto 0 do
      if THero(FHeroes.FChildren.List^[I]).Owner = nil then
        THero(FHeroes.FChildren.List^[I]).MsgProc(Msg, Sender);
end;

function THeroLibrary.CreateUniqueLibraryID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FNextLibraryID);
    if FNextLibraryID > $FFFFFFF then FNextLibraryID := 0;
    while (I <> FChildren.Count) and (THero(FChildren.List^[I]).FLibraryID <> FNextLibraryID) do Inc(I);
  until I = FChildren.Count;
  Result := FNextLibraryID;
end;

function THeroLibrary.AddChild(Child: TEObject): Integer;
begin
  with THero(Child) do
    { Original checks unit IDs rather than library IDs for a collision. }
    if (FLibraryID = 0) or (FindHero(FLibraryID) <> nil) then FLibraryID := CreateUniqueLibraryID;
  FChildren.Add(Child);
  if Child.AddRef = -1 then raise Exception.Create('EObject doesn''t support ReferenceCounting');
  Result := FChildren.Count - 1;
end;

function THeroLibrary.CreateHero: THero;
var Hero: THero;
begin
  Hero := THero.Create(nil);
  Hero.SetHeroResourceIndex(0);
  Hero.FLibraryID := CreateUniqueLibraryID;
  Hero.FLibraryName := FLibraryName;
  Hero.SetOwner(Self);
  Hero.Release;
  Result := Hero;
end;

function THeroLibrary.GetName: string;
begin
  Result := FLibraryName;
  if Result = '' then Result := TranslateRStr(SystemRStr);
end;

function THeroLibrary.FindLibraryID(ID: Integer): THero;
var I: Integer;
begin
  I := FChildren.Count;
  while I <> 0 do
  begin
    Dec(I);
    if ID = THero(FChildren.List^[I]).FLibraryID then
    begin Result := THero(FChildren.List^[I]); Exit; end;
  end;
  Result := nil;
end;

procedure THeroLibrary.LoadFromFile(const FileName: string);
begin AoWEngine.ReadFromFile(FileName, Self, nil); end;

procedure THeroLibrary.SaveToFile(const FileName: string);
begin AoWEngine.WriteToFile(FileName, Self, nil); end;

procedure THeroLibrary.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FLibraryName, 20);
  Stream.rwInteger(FNextLibraryID, 21);
end;

constructor THeroLibraryManager.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSystemLibrary := THeroLibrary.Create(nil);
  FLibraries := TENode.Create(nil);
end;

destructor THeroLibraryManager.Destroy;
begin FLibraries.Free; FSystemLibrary.Free; inherited Destroy; end;

procedure THeroLibraryManager.ReadWrite(Stream: TEStorageStream);
var Directory: string;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    Directory := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      ReadUserLibraries;
      AoWEngine.ReadFromFile(Directory + 'Heroes.PFS', FSystemLibrary, nil);
    end
    else
    begin
      AoWEngine.WriteToFile(Directory + 'Heroes.PFS', FSystemLibrary, nil);
      WriteUserLibraries;
    end;
  end
  else Stream.rwEObject(FSystemLibrary, 20);
end;

function THeroLibraryManager.GetLibrary(Index: Integer): THeroLibrary;
begin Result := THeroLibrary(FLibraries.FChildren.EObjects[Index]); end;

function THeroLibraryManager.GetCount: Integer;
begin Result := FLibraries.GetCount; end;

procedure THeroLibraryManager.ReadUserLibraries;
var Lib: THeroLibrary; Search: TSearchRec; Found: Boolean;
begin
  FLibraries.Clear;
  FLibraries.AddChild(FSystemLibrary);
  Found := FindFirst(AoWEngine.StartupDirectory + 'User\' + '*' + '.ahl', faAnyFile - faDirectory, Search) = 0;
  while Found do
  begin
    Lib := THeroLibrary.Create(nil);
    try
      Lib.LoadFromFile(AoWEngine.StartupDirectory + 'User\' + Search.Name);
      Lib.SetOwner(FLibraries);
    except
      Lib.Free;
    end;
    Found := FindNext(Search) = 0;
  end;
  FindClose(Search);
end;

procedure THeroLibraryManager.WriteUserLibraries;
var I: Integer; Lib: THeroLibrary;
begin
  for I := 1 to FLibraries.GetCount - 1 do
  begin
    Lib := GetLibrary(I);
    Lib.SaveToFile(AoWEngine.StartupDirectory + 'User\' + Lib.GetName + '.ahl');
  end;
end;

function THeroLibraryManager.IndexOfLibraryName(const Name: string): Integer;
begin
  Result := FLibraries.GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if CompareText(Name, THeroLibrary(FLibraries.FChildren.List^[Result]).FLibraryName) = 0 then Exit;
  end;
  Result := -1;
end;

function THeroLibraryManager.IndexOfLibrary(Lib: THeroLibrary): Integer;
begin Result := FLibraries.FChildren.IndexOf(Lib); end;

function THeroLibraryManager.FindHero(const LibraryName: string; LibraryID: Integer): THero;
var Index: Integer;
begin
  Index := IndexOfLibraryName(LibraryName);
  if Index <> -1 then Result := THeroLibrary(FLibraries.FChildren.List^[Index]).FindLibraryID(LibraryID)
  else Result := nil;
end;

function THeroLibraryManager.CreateLibrary(const Name: string): THeroLibrary;
var LibraryName: string;
begin
  LibraryName := Name;
  { Original retains the period when stripping the extension. }
  if Pos('.', LibraryName) <> 0 then LibraryName := System.Copy(LibraryName, 1, Pos('.', LibraryName));
  if (LibraryName <> '') and (IndexOfLibraryName(LibraryName) = -1) then
  begin
    Result := THeroLibrary.Create(FLibraries);
    Result.FLibraryName := LibraryName;
    Result.SaveToFile(AoWEngine.StartupDirectory + 'Release\' + LibraryName + '.ahl');
  end
  else Result := nil;
end;

procedure THeroLibraryManager.DeleteLibrary(Index: Integer);
begin
  if (Index < FLibraries.GetCount) and (Index > 0) then
  begin
    Windows.DeleteFile(PChar(AoWEngine.StartupDirectory + 'User\' + GetLibrary(Index).GetName + '.ahl'));
    GetLibrary(Index).Free;
  end;
end;

constructor TLeader.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FSpheres := TByteList.Create;
  FSpherePicksMax := 5;
end;

destructor TLeader.Destroy;
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FPlayers.GetPlayers(FPlayer) <> nil) and
    (Self = AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader) then AoWHSMap.FPlayers.GetPlayers(FPlayer).SetLeader(nil);
  inherited Destroy;
  FSpheres.Free;
end;

procedure TLeader.Changed;
begin
  inherited Changed;
  if (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
    AoWHSMap.FOnLeaderChanged.TriggerNotifyEvents(Self);
end;

class function TLeader.ClassID: Integer;
begin Result := $20232; end;

function TLeader.GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer;
begin Result := 90; end;

function TLeader.GetNickname: string;
begin
  if AoWHSMap <> nil then
    if AoWHSMap.FGameType <> gtCampaign then Result := ''
    else begin Result := FNickname; Exit; end
  else Result := '';
end;

procedure TLeader.SetNickname(Value: string);
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FGameType = gtCampaign) then inherited SetNickname(Value);
end;

function TLeader.GetSpherePicks(Sphere: TMagicSphere): Byte;
var I: Integer;
begin
  if Sphere <> msCosmos then
  begin
    Result := 0;
    for I := FSpheres.Count - 1 downto 0 do
      if FSpheres.List^[I] = Byte(Sphere) then Inc(Result);
  end
  else Result := 4;
end;

function TLeader.GetSpheres(Index: Integer): TMagicSphere;
begin Result := TMagicSphere(FSpheres.List^[Index]); end;

function TLeader.GetSphereCount: Integer;
begin Result := FSpheres.Count; end;

procedure TLeader.SetSpherePicksMax(Value: Byte);
begin
  FSpherePicksMax := Value;
  while FSpheres.Count > FSpherePicksMax do FSpheres.Delete(FSpheres.Count - 1);
end;

function TLeader.CanAddSphere(Sphere: TMagicSphere): Boolean;
begin
  if FSpheres.Count < FSpherePicksMax then
  begin
    if Sphere = msCosmos then Result := False
    else if AoWEngine.FDemo and (GetSpherePicks(Sphere) >= 2) then Result := False
    else if GetSpherePicks(Sphere) = 4 then Result := False
    else if (Sphere = msFire) and (GetSpherePicks(msWater) <> 0) then Result := False
    else if (Sphere = msWater) and (GetSpherePicks(msFire) <> 0) then Result := False
    else if (Sphere = msLife) and (GetSpherePicks(msDeath) <> 0) then Result := False
    else if (Sphere = msDeath) and (GetSpherePicks(msLife) <> 0) then Result := False
    else if (Sphere = msEarth) and (GetSpherePicks(msAir) <> 0) then Result := False
    else if (Sphere = msAir) and (GetSpherePicks(msEarth) <> 0) then Result := False
    else Result := True;
  end
  else Result := False;
end;

function TLeader.AddSphere(Sphere: TMagicSphere): Boolean;
begin Result := CanAddSphere(Sphere); if Result then FSpheres.Add(Byte(Sphere)); end;

procedure TLeader.MsgProc(var Msg: TEMsg; Sender: TEObject); { Near miss: player field caching after three variants. }
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then
  begin
    SetSpherePicksMax(Byte(AoWHSMap.FSphereCount));
    if AoWHSMap.FPlayers.GetCount > FPlayer then
    begin
      if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace <> FRace then
      begin
        SetHeroResourceIndex(AoWHSSet.FHeroResources.Find(AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace, htHeroLeader));
        Changed;
      end;
    end
    else Destroy;
  end;
end;

function TLeader.DeleteSphereIndex(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < FSpheres.Count) then
  begin FSpheres.Delete(Index); Result := True; end
  else Result := False;
end;

function TLeader.DeleteSphere(Sphere: TMagicSphere): Boolean;
var I: Integer;
begin
  I := FSpheres.Count;
  Result := False;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := FSpheres[I] = Byte(Sphere);
  end;
  if Result then FSpheres.Delete(I);
end;

procedure TLeader.ClearSpheres;
begin FSpheres.Clear; end;

function TLeader.GetPowerGeneration: Integer;
begin
  if GetAbilityEnabled(52) then Result := GetAbilityLevel(52) * 5 + 5 else Result := 0;
end;

procedure TLeader.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByteEx(FSpherePicksMax, 5, 45);
  Stream.rwStreamProc(46, FSpheres.LoadFromStream, FSpheres.SaveToStream);
end;

function TLeader.GetEngine: TEngine;
begin Result := AoWEngine; end;

procedure TLeader.SetHeroResourceIndex(Value: Integer);
begin
  inherited SetHeroResourceIndex(Value);
  if (FHeroResource <> nil) and (AoWHSMap <> nil) and (msEditting in AoWHSMap.Status) then
    FHeroName := FHeroResource.FName;
end;

procedure TLeader.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
    if FPlayer <> 0 then begin SetOwner(nil); Changed; end
    else inherited SetPlayer(Player);
end;

procedure TLeader.Killed;
begin
  if (usActivated in FUnitStatus) and (AoWHSMap.FCombat = nil) then AoWHSMap.GameOver(FPlayer, goLost);
  inherited Killed;
end;

function TLeader.CanActivate: Boolean;
var Leader: TLeader;
begin
  Result := inherited CanActivate;
  if Result then
  begin
    Leader := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader;
    if (Leader <> nil) and not CompatibleHero(Leader) then Result := False;
  end;
end;

procedure TLeader.Activate;
var Leader: TLeader;
begin
  FLibraryID := -1;
  if FPlayer = 0 then FPlayer := AoWHSMap.FPlayers.RaceToPlayer(FRace);
  inherited Activate;
  if AoWHSMap.FPlayers.GetPlayers(FPlayer) <> nil then
  begin
    Leader := AoWHSMap.FPlayers.GetPlayers(FPlayer).FLeader;
    if Leader <> Self then
    begin
      if (Leader <> nil) and (Leader.Owner <> nil) then
        try
          raise Exception.Create('Double leader used');
        except
          { Original silently swallows this duplicate-leader exception. }
        end;
      AoWHSMap.FPlayers.GetPlayers(FPlayer).SetLeader(Self);
      Changed;
    end
    else Changed;
  end
  else begin SetOwner(nil); Release; end;
end;

procedure TLeader.Deactivate;
begin inherited Deactivate; end;

procedure TLeader.EditDropMsg(var Msg: TEMsg);
var Level: TMapLevel; L, X, Y: Integer; Placed: Boolean;
begin
  Level := TMapLevel(Msg.Param[0]);
  L := Msg.Data[1];
  HPtoHX(Msg.Value, Msg.Data[0], X, Y);
  if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
    Placed := Place(X, Y, L, FPlayer, []) <> nil
  else Placed := False;
  if Placed then Msg.Result := 0 else Msg.Result := -1;
end;

function TLeader.CanDisband(var Reason: string): Boolean;
begin Result := False; end;

function TLeader.GetUpkeep: Shortint;
begin Result := 0; end;

