constructor TArmyID.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
end;

destructor TArmyID.Destroy;
begin
  FUnitIDs.Free;
  inherited Destroy;
end;

class function TArmyID.ClassID: Integer;
begin Result := $20220; end;

procedure TArmyID.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 10);
  Stream.rwInteger(Integer(Pointer(@FX)^), 11);
  Stream.rwStreamProc(12, FUnitIDs.LoadFromStream, FUnitIDs.SaveToStream);
end;

function TArmyID.Valid: Boolean;
var ArmyHS: TArmyHS; I: Integer;
begin
  if FX <> -1 then
  begin
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetArmyHS;
    if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = FPlayer) then
    begin
      I := FUnitIDs.Count;
      Result := True;
      while Result and (I <> 0) do
      begin
        Dec(I);
        Result := ArmyHS.FArmy.IndexOfID(FUnitIDs[I]) <> -1;
      end;
    end
    else Result := False;
  end
  else Result := False;
end;

function TArmyID.RetrieveArmy(var ArmyHS: TArmyHS; var Selection: Byte): Boolean;
var I, Index: Integer;
begin
  if FX <> -1 then
  begin
    Selection := 0;
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetArmyHS;
    if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = FPlayer) then
    begin
      I := FUnitIDs.Count;
      Result := True;
      while Result and (I <> 0) do
      begin
        Dec(I);
        Index := ArmyHS.FArmy.IndexOfID(FUnitIDs[I]);
        { Original shifts by the missing unit index before reporting failure. }
        Selection := Selection or (Byte(1) shl Index);
        Result := Index <> -1;
      end;
    end
    else Result := False;
  end
  else Result := False;
  if not Result then
  begin
    ArmyHS := nil;
    Selection := 0;
  end;
end;

class function TArmyView.ClassID: Integer;
begin Result := $20219; end;

function TArmyView.GetConcealedForPlayer(Player: Shortint): Boolean;
begin Result := (FConcealedForPlayers shr (Player - 1)) and 1 <> 0; end;

procedure TArmyView.SetConcealedForPlayer(Player: Shortint; Value: Boolean);
var Mask: Integer;
begin
  Mask := 1 shl (Player - 1);
  if Value then FConcealedForPlayers := FConcealedForPlayers or Word(Mask)
  else FConcealedForPlayers := FConcealedForPlayers and not Word(Mask);
end;

function TArmyView.GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean;
begin Result := (FUnitConcealment[Index] shr (Player - 1)) and 1 <> 0; end;

procedure TArmyView.SetUnitConcealedForPlayer(Index: Integer; Player: Shortint; Value: Boolean);
var Mask: Integer;
begin
  Mask := 1 shl (Player - 1);
  if Value then FUnitConcealment[Index] := FUnitConcealment[Index] or Word(Mask)
  else FUnitConcealment[Index] := FUnitConcealment[Index] and not Word(Mask);
end;

procedure TArmyView.Setup(Army: TArmy; Selection: Byte);
var I, Player: Integer; AUnit: TAbstractUnit;
begin
  AssignSettings(Army);
  FX := Army.FX;
  FY := Army.FY;
  FL := Army.FL;
  for I := 0 to Army.GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(Army.GetUnit(I).Copy(AoWEngine));
      AUnit.SetOwner(Self);
      AUnit.Release;
      FMoraleValues[GetCount - 1] := Army.GetUnit(I).FMoraleValue;
      for Player := 1 to AoWHSMap.FPlayers.GetCount - 1 do
        SetUnitConcealedForPlayer(GetCount - 1, Player, Army.GetUnitConcealedForPlayer(I, Player));
    end;
    Selection := Selection shr 1;
  end;
end;

procedure TArmyView.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FUnitConcealment, 16, 40);
  Stream.rwWord(FConcealedForPlayers, 41);
  Stream.rwData(FMoraleValues, 32, 42);
end;

procedure TArmyView.MainReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited MainReadWrite(Stream);
  if smRead in Stream.StorageMode then
    for I := 0 to GetCount - 1 do GetUnit(I).FMoraleValue := FMoraleValues[I];
end;

procedure TArmyView.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin Xhx := FX; Yhx := FY; Lhx := FL; end;

constructor TArmyEventLog.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FArmyMessages := TStringList.Create;
  FArmyView := TArmyView.Create(nil);
  FDamageValues := TByteList.Create;
  FDamageTypes := TByteList.Create;
end;

destructor TArmyEventLog.Destroy;
begin
  FArmyMessages.Free;
  FArmyView.Free;
  FDamageValues.Free;
  FDamageTypes.Free;
  inherited Destroy;
end;

class function TArmyEventLog.ClassID: Integer;
begin Result := $20218; end;

procedure TArmyEventLog.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmyView, 15);
  Stream.rwString(FArmyText, 16);
  Stream.rwStrings(FArmyMessages, 17);
  Stream.rwInteger(FArmyIcon, 18);
  Stream.rwStreamProc(19, FDamageValues.LoadFromStream, FDamageValues.SaveToStream);
  Stream.rwStreamProc(20, FDamageTypes.LoadFromStream, FDamageTypes.SaveToStream);
  Stream.rwBool(FGameOver, 21);
end;

function TArmyEventLog.GetLeftIcon: Integer;
begin
  if FArmyView.FPlayer > 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(FArmyView.FPlayer).FPlayerRace
  else Result := 12;
end;

procedure TArmyEventLog.SetArmyView(Value: TArmyView);
begin FArmyView.Assign(Value, AoWEngine); end;

function TArmyEventLog.GetText: string;
begin Result := FArmyText; end;

function TArmyEventLog.LeaderKilled: Boolean;
var I: Integer;
begin
  Result := False;
  I := FArmyView.GetCount;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := (FArmyView.GetUnit(I) is TLeader) and
      (FArmyView.GetUnit(I).GetHitPoints <= FDamageValues[I]);
  end;
end;

function TArmyEventLog.PartyDestroyed: Boolean;
var I: Integer;
begin
  Result := True;
  I := FArmyView.GetCount;
  while Result and (I <> 0) do
  begin
    Dec(I);
    Result := Result and (FArmyView.GetUnit(I).GetHitPoints <= FDamageValues[I]);
  end;
end;

procedure TArmyEventLog.ValidateGameOver;
begin
  FGameOver := LeaderKilled or (PartyDestroyed and
    (AoWHSMap.FPlayers.GetPlayers(FArmyView.FPlayer).FArmies.GetCount = 1));
end;

function TArmyEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var ShowEvent: Boolean;
begin
  Result := False;
  case Trigger of
    etUser:
      begin
        AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
        Result := True;
      end;
    etEvent, etNewTurn:
      begin
        ShowEvent := False;
        if (AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer) then
        begin
          ShowEvent := ShowEvent or ((AoWHSMap.FPlayMode = pmTurn) and
            (wpPartyDamage in AoWEngine.FRegistry.GetClassicWindowPopupEvents));
          ShowEvent := ShowEvent or ((AoWHSMap.FPlayMode = pmSimultaneous) and
            (wpPartyDamage in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents));
        end;
        ShowEvent := ShowEvent or FGameOver;
        if ShowEvent then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      end;
  end;
end;

procedure TArmyEventLog.ViewLocation;
var Army: TArmyView;
begin
  Army := FArmyView;
  if (Army <> nil) and (Army.FX <> -1) then CenterViewTo(Army.FX, Army.FY, Army.FL);
end;

constructor TArmyInfoEventLog.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FMessages := TStringList.Create;
  FArmyView := TArmyView.Create(nil);
  FTriggers := [etEvent, etUser, etNewTurn];
end;

destructor TArmyInfoEventLog.Destroy;
begin
  FMessages.Free;
  FArmyView.Free;
  inherited Destroy;
end;

class function TArmyInfoEventLog.ClassID: Integer;
begin Result := $202E9; end;

procedure TArmyInfoEventLog.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmyView, 15);
  Stream.rwStrings(FMessages, 16);
  Stream.rwData(FSelection, 1, 17);
  Stream.rwString(FTitle, 18);
  Stream.rwString(FText, 19);
  Stream.rwString(FDescription, 20);
end;

procedure TArmyInfoEventLog.SetArmyView(Value: TArmyView);
begin FArmyView.Assign(Value, AoWEngine); end;

function TArmyInfoEventLog.GetText: string;
begin Result := FText; end;

procedure TArmyInfoEventLog.ViewLocation;
var Army: TArmyView;
begin
  Army := FArmyView;
  if (Army <> nil) and (Army.FX <> -1) then CenterViewTo(Army.FX, Army.FY, Army.FL);
end;

function TArmyInfoEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  Result := False;
  if Trigger in FTriggers then
    case Trigger of
      etUser:
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      etNewTurn:
        if (AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer) then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end;
      etEvent:
        if (AoWHSMap.FConnectionType = pcLocal) and
          ((AoWHSMap.FSeatedPlayer = FPlayer) or (AoWHSMap.FSeatedPlayer = FArmyView.FPlayer)) then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end
        else PlaySample('SFX\EVENTS\NEWEVENT.WAV');
    end;
end;

constructor TArmy.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FX := -1;
  FY := -1;
  FL := -1;
  FDestinationX := -1;
  FDestinationY := -1;
  FDestinationL := -1;
  FIndependentRelation := -1;
end;

destructor TArmy.Destroy;
begin
  if not (msDestroying in AoWHSMap.Status) then AoWHSMap.ArmyDestroyed(Self);
  FOnUpdate := nil;
  inherited Destroy;
end;

procedure TArmy.Kill(Selection: Byte);
var I: Integer;
begin
  BeginUpdate;
  for I := GetCount - 1 downto 0 do
    if (Selection shr I) and 1 <> 0 then TAbstractUnit(FChildren.List^[I]).Killed;
  EndUpdate;
end;

function TArmy.GetStrengthEx(Selection: Byte; DamageType: TDamageType): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    if (1 shl I) and Selection <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrength(DamageType));
end;

function TArmy.GetStrengthMaxEx(Selection: Byte; DamageTypes: TDamageTypes): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    if (1 shl I) and Selection <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrengthMax(DamageTypes));
end;

procedure TArmy.ReturnBattleFieldInfo(var Info: TBattleFieldInfo);
var I, Strength: Integer; AUnit: TAbstractUnit;
  Relation: TDiplomaticRelation; Behavior: TGroupBehavior; IncludeUnit: Boolean;
begin
  Relation := DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation);
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if AUnit.FGroup <> nil then Behavior := AUnit.FGroup.Behavior else Behavior := gbPassive;
    IncludeUnit := (Info.Units = nil) or (Info.Units.FChildren.IndexOf(AUnit) = -1);
    if IncludeUnit and (bfrIgnorePassiveIndependents in Info.Requests) then
      IncludeUnit := (AUnit.FPlayer <> 0) or ((AUnit.FGroup <> nil) and
        (AUnit.FGroup.Behavior <> gbPassive) and (AUnit.FGroup.Behavior <> gbGuard));
    if IncludeUnit and (bfrIgnoreIndependents in Info.Requests) and (AUnit.FPlayer = 0) then
      IncludeUnit := False;
    if IncludeUnit then
    begin
      Strength := AUnit.GetStrengthMax(Info.DamageTypes);
      if Ord(Relation) in Info.FriendlyRelations then Inc(Info.FriendlyStrength, Strength);
      if (Ord(Relation) in Info.EnemyRelations) or (Behavior = gbGuardArea) then Inc(Info.Strength, Strength);
    end;
  end;
end;

function TArmy.HealUnits(Selection: Byte): Boolean;
var I: Integer; AUnit: TAbstractUnit;
begin
  Result := False;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.GetHitPoints <> AUnit.GetHits then
      begin Result := True; AUnit.SetHitPoints(AUnit.GetHits); end;
    end;
    Selection := Selection shr 1;
  end;
end;

function TArmy.CreateGroupID(Selection: Byte): Integer;
var I: Integer;
begin
  I := 0;
  while (Selection and 1 = 0) and (I <> FChildren.Count) do
  begin
    Inc(I);
    Selection := Selection shr 1;
  end;
  if I <> FChildren.Count then Result := TAbstractUnit(FChildren.List^[I]).FUnitID
  else Result := 0;
end;

function TArmy.GetGroup(Selection: Byte): TAIGroup;
var Different: Boolean; I: Integer; Found: Boolean;
begin
  Result := nil;
  Different := False;
  I := 0;
  Found := False;
  while (I <> FChildren.Count) and not Different do
  begin
    if Selection and 1 <> 0 then
      if not Found then
      begin
        Result := TAbstractUnit(FChildren.List^[I]).FGroup;
        Found := True;
      end
      else Different := Result <> TAbstractUnit(FChildren.List^[I]).FGroup;
    Selection := Selection shr 1;
    Inc(I);
  end;
  if not Found or Different then Result := nil;
end;

procedure TArmy.SetGroup(Selection: Byte; Group: TAIGroup);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Group.AddUnit(TAbstractUnit(FChildren.List^[I]));
    Selection := Selection shr 1;
  end;
end;

function TArmy.GetGroupSelection(GroupID: Integer): Byte;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Result := Result shl 1;
    if GroupID = TAbstractUnit(FChildren.List^[I]).FGroupID then Result := Result or 1;
  end;
end;

function TArmy.GetBehavior(Selection: Byte): TGroupBehavior;
var Group: TAIGroup;
begin
  Group := GetGroup(Selection);
  if Group <> nil then Result := Group.Behavior else Result := gbNone;
end;

procedure TArmy.SetBehavior(Selection: Byte; Behavior: TGroupBehavior);
var Group: TAIGroup; I: Integer;
begin
  Group := AoWHSMap.FAIGroupManager.CreateGroup(FPlayer, FIndependentRelation, Behavior);
  if Group <> nil then
  begin
    for I := 0 to FChildren.Count - 1 do
    begin
      if Selection and 1 <> 0 then Group.AddUnit(TAbstractUnit(FChildren.List^[I]));
      Selection := Selection shr 1;
    end;
    Group.Release;
  end;
end;

function TArmy.GetOldAIBehavior: TGroupBehavior;
var I: Integer;
begin
  Result := gbNone;
  I := GetCount;
  while (Result = gbNone) and (I <> 0) do
  begin
    Dec(I);
    Result := TGroupBehavior(GetUnit(I).F_AbstractUnit_38);
  end;
end;

procedure TArmy.InitializeGroupBehavior;
var Selection: Byte; Index: Integer; Behavior: TGroupBehavior; AHero: THero;
begin
  Selection := $FF;
  AHero := Hero(Selection, [htLeader, htHeroLeader]);
  if AHero <> nil then
  begin
    Index := IndexOf(AHero);
    if Index <> -1 then
    begin
      SetBehavior(Byte(1) shl Index, gbFortify);
      Selection := Selection and not (Byte(1) shl Index);
    end;
  end;
  Index := IndexOfTransporter(Selection);
  if (Index <> -1) and (FOldAIBehavior = gbNone) then
    Selection := Selection and not (Byte(1) shl Index);
  if Selection <> 0 then
  begin
    Behavior := FOldAIBehavior;
    if Behavior = gbNone then
      if (FPlayer = 0) and (AoWHSMap.GetIndependentAIMode <> iaOff) then
      begin
        if (FX <> -1) and
          (AoWHSMap.MapContainer.GetField(FX, FY, FL).FindNoneTransparentHS(TPlayerStructure) = nil) then
          if FIndependentRelation >= 0 then Behavior := gbPatrol else Behavior := gbGuardArea
        else Behavior := gbPassive;
      end
      else Behavior := AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.GetRandomGroupBehavior;
    SetBehavior(Selection, Behavior);
  end;
end;

procedure TArmy.UpdateGroupBehavior;
var Selection: Byte; Index: Integer; Behavior: TGroupBehavior;
begin
  Selection := GetGroupSelection(0);
  if Selection <> 0 then
  begin
    Index := IndexOfTransporter(Selection);
    if Index <> -1 then
    begin
      Selection := Selection and not (Byte(1) shl Index);
      if TAbstractUnit(FChildren.List^[Index]).FGroupID = 0 then
        SetBehavior(Byte(1) shl Index, gbTransport);
    end;
    Behavior := gbPassive;
    if (FPlayer = 0) and (Hero(Selection, [htHero]) <> nil) then Behavior := gbScout
    else if (FPlayer = 0) and (AoWHSMap.GetIndependentAIMode <> iaOff) and (FX <> -1) then
      if AoWHSMap.MapContainer.GetField(FX, FY, FL).FindNoneTransparentHS(TPlayerStructure) = nil then
        if FIndependentRelation >= 0 then Behavior := gbPatrol else Behavior := gbGuardArea;
    if Selection <> 0 then
    begin
      Index := IndexOfBehavior(Behavior);
      if Index = -1 then SetBehavior(Selection, Behavior)
      else SetGroup(Selection, TAbstractUnit(FChildren.List^[Index]).FGroup);
    end;
  end;
end;

function TArmy.CreateID(Selection: Byte): TArmyID;
var ID: TArmyID; I: Integer;
begin
  ID := TArmyID.Create(nil);
  ID.FX := FX;
  ID.FY := FY;
  ID.FL := FL;
  ID.FPlayer := FPlayer;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then ID.FUnitIDs.Add(TAbstractUnit(FChildren.List^[I]).FUnitID);
    Selection := Selection shr 1;
  end;
  Result := ID;
end;

class function TArmy.ClassID: Integer;
begin Result := $20216; end;

function TArmy.GetArmyHS: TArmyHS;
var X, Y, L: Shortint;
begin
  GetLocation(X, Y, L);
  if X <> -1 then
    Result := TArmyHS(AoWHSMap.MapContainer.GetField(X, Y, L).FindOwnedChild($20217))
  else Result := nil;
end;

function TArmy.GetEngine: TEngine;
begin Result := AoWEngine; end;

procedure TArmy.AssignSettings(Army: TArmy);
begin
  FDestinationX := Army.FDestinationX;
  FDestinationY := Army.FDestinationY;
  FDestinationL := Army.FDestinationL;
  FPlayer := Army.FPlayer;
end;

procedure TArmy.SetFullyConcealed(Value: Boolean);
begin
  if Value <> (asFullyConcealed in FStatus) then
  begin
    if Value then FStatus := FStatus + [asFullyConcealed]
    else FStatus := FStatus - [asFullyConcealed];
    if (asActivated in FStatus) and (FX <> -1) then
      AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
  end;
end;

function TArmy.GetFullyConcealed: Boolean;
begin Result := asFullyConcealed in FStatus; end;

procedure TArmy.UpdateConcealment;
var Concealed: Boolean; ALeader: TLeader; Changed, ShowCrown: Boolean;
begin
  if asActivated in FStatus then
  begin
    if (FConcealedUnits <> 0) and (AoWHSMap.FSeatedPlayer <> FPlayer) and
      not (msEditting in AoWHSMap.Status) then Concealed := GetConcealedForPlayer(AoWHSMap.FSeatedPlayer)
    else Concealed := False;
    ALeader := Leader($FF);
    ShowCrown := ALeader <> nil;
    if ShowCrown and Concealed then
      if (FConcealedUnits shr IndexOf(ALeader)) and 1 <> 0 then ShowCrown := False;
    Changed := False;
    if ShowCrown then FStatus := FStatus + [asShowCrown] else FStatus := FStatus - [asShowCrown];
    if Concealed <> (asConcealed in FStatus) then
    begin
      if Concealed then FStatus := FStatus + [asConcealed] else FStatus := FStatus - [asConcealed];
      Changed := True;
    end;
    Concealed := Concealed and (GetCount = ConcealedUnitsCount);
    if Concealed <> GetFullyConcealed then
    begin SetFullyConcealed(Concealed); Changed := True; end;
    if Changed then TriggerOnUpdateEvent;
  end;
end;

procedure TArmy.SetXYL(X, Y, L: Shortint);
begin
  FX := X;
  FY := Y;
  FL := L;
  if UpdateCount = 0 then UpdateConcealedUnits;
end;

function TArmy.GetRace(Selection: Byte): Integer;
var Same: Boolean; I, Race: Integer;
begin
  Result := -1;
  Same := True;
  for I := 0 to GetCount - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      Race := TAbstractUnit(FChildren.List^[I]).GetRace;
      if Race <> -1 then
        if Result <> -1 then Same := Same and (Race = Result)
        else Result := Race;
    end;
    Selection := Selection shr 1;
  end;
  if not Same then Result := -1;
end;

function TArmy.GetUpkeep: Byte;
begin Result := FUpkeep; end;

procedure TArmy.ResetDestinationPos;
begin FDestinationX := -1; FDestinationY := -1; FDestinationL := -1; end;

procedure TArmy.SetDestinationPos(X, Y, L: Shortint);
begin FDestinationX := X; FDestinationY := Y; FDestinationL := L; end;

function TArmy.ConcealedUnitsCount: Integer;
var Selection: Byte;
begin
  Selection := FConcealedUnits;
  Result := 0;
  while Selection <> 0 do
  begin
    if Selection and 1 <> 0 then Inc(Result);
    Selection := Selection shr 1;
  end;
end;

procedure TArmy.UpdateConcealedUnits;
var I: Integer; Field: TAoWMapField;
begin
  if (FX <> -1) and (FL <> -1) and (asActivated in FStatus) then
  begin
    FConcealedUnits := 0;
    I := FChildren.Count;
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
    while I <> 0 do
    begin
      Dec(I);
      FConcealedUnits := FConcealedUnits shl 1;
      if TAbstractUnit(FChildren.List^[I]).ConcealedOnMapF(Field) then
        FConcealedUnits := FConcealedUnits or 1;
    end;
  end;
end;

procedure TArmy.UpdateUpkeep; { Near miss: comparison operand order differs after three variants. }
var Upkeep, Previous: Byte; I, Delta: Integer;
begin
  Upkeep := 0;
  for I := 0 to GetCount - 1 do Inc(Upkeep, TAbstractUnit(FChildren.List^[I]).GetUpkeep);
  Previous := FUpkeep; if (Upkeep <> Previous) and (asActivated in FStatus) then begin Delta := Integer(Upkeep) - Integer(Previous);
    AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep +
      Delta); end;
  FUpkeep := Upkeep;
end;

procedure TArmy.Changed;
begin Update; end;

procedure TArmy.ValidateTerrainEx(TerrainType, OverlayType, Player: Shortint);
var Transport: TAbstractUnit; Selection: Byte; I: Integer;
  Log: TArmyEventLog; AUnit: TAbstractUnit;
begin
  Transport := Transporter($FF);
  if (Transport = nil) or not Transport.ValidTerrain(TerrainType, OverlayType) then
  begin
    Selection := 0;
    for I := GetCount - 1 downto 0 do
    begin
      Selection := Selection shl 1;
      if not TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType) then
        Selection := Selection or 1;
    end;
  end
  else Selection := 0;
  if Selection <> 0 then
  begin
    if not (msEditting in AoWHSMap.Status) and (AoWHSMap.FDay <> 0) then
    begin
      BeginUpdate;
      Log := TArmyEventLog.Create(nil);
      Log.FPlayer := Player;
      if TerrainType in [0, 10] then
      begin
        Log.FArmyText := TranslateRStr(UnitsDrownRStr);
        Log.FArmyMessages.Add(TranslateRStr(UnitsDrownRStr));
        Log.FArmyIcon := 3;
      end
      else case TerrainType of
        9:
        begin
          Log.FArmyText := TranslateRStr(UnitsBurnedRStr);
          Log.FArmyMessages.Add(TranslateRStr(UnitsBurnedRStr));
          Log.FArmyIcon := 0;
        end;
      else
        Log.FArmyText := TranslateRStr(UnitsCrushedRStr);
        Log.FArmyMessages.Add(TranslateRStr(UnitsCrushedRStr));
        Log.FArmyIcon := 2;
      end;
      Log.FArmyView.Setup(Self, $FF);
      for I := 0 to GetCount - 1 do
      begin
        AUnit := GetUnit(I);
        if (Selection shr I) and 1 <> 0 then
        begin
          Log.FDamageValues.Add(AUnit.GetHitPoints);
          Log.FDamageTypes.Add(9);
          AUnit.SetHitPoints(0);
        end
        else
        begin
          Log.FDamageValues.Add(0);
          Log.FDamageTypes.Add(9);
        end;
      end;
      Log.ValidateGameOver;
      DistributeLocationEventLog(Log, FPlayer, FX, FY, FL, True);
      Log.Release;
      EndUpdate;
    end;
    Validate;
  end;
end;

procedure TArmy.ValidateTerrain(TerrainType, OverlayType: Shortint);
begin
  ValidateTerrainEx(TerrainType, OverlayType, FPlayer);
end;

procedure TArmy.Validate;
var I: Integer; AUnit: TAbstractUnit; NewUnit: TUnit;
begin
  AoWHSMap.LockGameOverEvent;
  BeginUpdate;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if AUnit.GetHitPoints = 0 then
      if AUnit.GetAbilityEnabled($6B) then
      begin
        NewUnit := TUnit.Create(nil);
        NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource($98));
        AUnit.Killed;
        AddUnit(NewUnit);
      end
      else AUnit.Killed;
  end;
  EndUpdate;
  AoWHSMap.UnlockGameOverEvent;
end;

procedure TArmy.UpdateFormation;
var I, Level, UnitLevel: Integer; AUnit: TAbstractUnit; SourceName: string;
begin
  Level := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    AUnit.UpdateMoraleValue;
    if AUnit.GetAbilityEnabled($2E) or (AUnit.GetAbilityLevel($2E) > 0) then
    begin
      TLeadershipAbility(AoWHSSet.FAbilityControl.GetAbility($2E)).ResetExternalSource(AUnit);
      UnitLevel := AUnit.GetAbilityLevel($2E);
      if UnitLevel > Level then
      begin
        Level := UnitLevel;
        SourceName := AUnit.GetAbilityOwner($2E).GetOwnerName;
        if SourceName = TranslateRStr(ArmyInherentRStr) then SourceName := AUnit.GetName;
      end;
    end;
  end;
  if Level > 0 then
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.GetAbilityLevel($2E) < Level then
        TLeadershipAbility(AoWHSSet.FAbilityControl.GetAbility($2E)).SetExternalSource(AUnit, Level, SourceName);
    end;
end;

procedure TArmy.Update;
begin
  if (UpdateCount = 0) and (asActivated in FStatus) then
  begin
    LockChanged;
    SortUnits;
    UpdateVisibilityRanges;
    UpdateUnfog;
    UpdateUpkeep;
    UpdateConcealedUnits;
    UpdateConcealment;
    UpdateFormation;
    UpdateIndependentRelation;
    if (msEditting in AoWHSMap.Status) and (FX <> -1) then
      AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
    UnlockChanged;
    TriggerOnUpdateEvent;
  end;
end;

procedure TArmy.TriggerOnUpdateEvent;
begin
  if (UpdateCount = 0) and (asActivated in FStatus) then
  begin
    AoWHSMap.ArmyChanged(Self);
    if Assigned(FOnUpdate) then FOnUpdate(Self);
  end;
end;

procedure TArmy.Activate;
var I: Integer; AUnit: TAbstractUnit;
begin










































































































































































































































































































  Assert(not (asActivated in FStatus), 'Army already activated');
  if FOldAIBehavior = gbNone then FOldAIBehavior := GetOldAIBehavior;
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    if not (usActivated in AUnit.FUnitStatus) then AUnit.Activate;
  end;
  FStatus := FStatus + [asActivated];
  FUpkeep := 0;
  if FPlayer <> -1 then AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.AddChild(Self);
  { Original treats X = 0 as an unset location. }
  if FX = 0 then begin FX := -1; FY := -1; FL := -1; end;
  Update;
end;

procedure TArmy.Deactivate;
var I: Integer; AUnit: TAbstractUnit;
begin
  if asActivated in FStatus then
  begin
    if FUnfogRange <> 0 then
    begin
      AoWHSMap.FogArea(FX, FY, FL, FUnfogRange);
      FUnfogRange := 0;
    end;
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if usActivated in AUnit.FUnitStatus then AUnit.Deactivate;
    end;
    if FPlayer <> -1 then
    begin
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.RemoveChild(Self);
      AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep - FUpkeep);
    end;
    FStatus := FStatus - [asActivated];
  end;
end;

function TArmy.ValidateSelection(Selection: Byte): Byte;
begin
  Result := Selection and ArmySelectionMasks[FChildren.Count];
end;

function TArmy.SelectionCount(Selection: Byte): Integer;
begin
  Selection := Selection and ArmySelectionMasks[FChildren.Count];
  Result := 0;
  while Selection <> 0 do
  begin
    if Selection and 1 <> 0 then Inc(Result);
    Selection := Selection shr 1;
  end;
end;

function TArmy.ValidateMoveSelection(Selection: Byte): Byte;
begin
  Result := ValidateSelection(Selection);
  if (IndexOfTransporter($FF) <> -1) and (UnitsInTransporter and not Selection <> 0) and
    (Transporter(Selection) <> nil) then
    Result := Result and not (Byte(1) shl FChildren.IndexOf(Transporter($FF)));
end;

procedure TArmy.Select;
begin FStatus := FStatus + [asSelected]; end;

procedure TArmy.Unselect;
begin FStatus := FStatus - [asSelected]; end;

function TArmy.GetPlayer: Shortint;
begin Result := FPlayer; end;

function TArmy.GetUnitConcealed(Index: Integer): Boolean;
var Field: TAoWMapField;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
  Result := TAbstractUnit(FChildren.List^[Index]).ConcealedOnMapF(Field);
end;

function TArmy.GetUnitConcealedForPlayer(Index: Integer; Player: Shortint): Boolean;
var Field: TAoWMapField;
begin
  if (Player <> FPlayer) and (Player <> -1) and (FX <> -1) then
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL));
    Result := TAbstractUnit(FChildren.List^[Index]).ConcealedOnMapF(Field) and GetConcealedForPlayer(Player);
  end
  else Result := False;
end;

function TArmy.GetUnitsConcealedForPlayer(Selection: Byte; Player: Shortint): Boolean;
begin
  Selection := ValidateSelection(Selection);
  if Selection = (FConcealedUnits and Selection) then Result := GetConcealedForPlayer(Player)
  else Result := False;
end;

function TArmy.GetConcealedForPlayer(Player: Shortint): Boolean;
var Level: TMapLevel; Field: TAoWMapField; Msg: TMapFieldMsg; Walk: THNWalkData;
begin
  if Player <> -1 then
  begin
    Result := True;
    Level := AoWHSMap.MapContainer.MapLevels[FL];
    Msg.MsgID := $110B;
    Msg.Result := 0;
    Msg.Param[1] := Player;
    InitHNWalk(Walk, FX, FY, 0);
    while Result and (Walk.Radius < 8) do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      begin
        Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
        if Field.FFieldFlags and $1000 <> 0 then
        begin
          Msg.Param[0] := Walk.Radius;
          Field.SendMapFieldMsg(Msg);
          Result := Msg.Result = 0;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end
  else Result := False;
end;

procedure TArmy.SetPlayer(Player: Shortint);
var I: Integer;
begin
  if AoWHSMap.FPlayers.GetPlayers(Player) = nil then Player := 0;
  if Player <> FPlayer then
  begin
    BeginUpdate;
    if asActivated in FStatus then
    begin
      if FPlayer <> -1 then
      begin
        AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
          AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep - FUpkeep);
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.RemoveChild(Self);
      end;
      FPlayer := Player;
      if FPlayer <> -1 then
      begin
        AoWHSMap.FPlayers.GetPlayers(FPlayer).SetArmyUpkeep(
          AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmyUpkeep + FUpkeep);
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FArmies.AddChild(Self);
      end;
      for I := FChildren.Count - 1 downto 0 do TAbstractUnit(FChildren.List^[I]).SetPlayer(FPlayer);
      if FX <> -1 then AoWHSMap.ScannerIconsChangedRad(FX, FY, FL, 0);
      if (FPlayer > 0) and (AoWHSMap.FDay > 0) then
        if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman then SetBehavior($FF, gbPassive);
      UpdateUnfog;
      UpdateExploration;
    end
    else FPlayer := Player;
    EndUpdate;
  end;
end;

function TArmy.ImmunityTypes(Selection: Byte): TDamageTypes;
var I: Integer;
begin
  Result := dtAll;
  I := 0;
  while (Result <> []) and (I <> GetCount) do
  begin
    if Selection and 1 <> 0 then
      Result := Result * TAbstractUnit(FChildren.List^[I]).GetImmunityTypes;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.ObtainValue(Selection: Byte): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Inc(Result, TAbstractUnit(FChildren.List^[I]).GetObtainValue);
    Selection := Selection shr 1;
  end;
end;

function TArmy.MovePoints(Selection: Byte): Shortint;
var I: Integer; Transport, AUnit: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMovePoints
  else if Selection <> 0 then
  begin
    Result := 50;
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        if AUnit.GetMovePoints < Result then Result := AUnit.GetMovePoints;
      end;
      Selection := Selection shr 1;
    end;
  end
  else Result := 0;
end;

function TArmy.Moves(Selection: Byte): Shortint;
var I: Integer; Transport, AUnit: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMoves
  else if Selection <> 0 then
  begin
    Result := 50;
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        if AUnit.GetMoves < Result then Result := AUnit.GetMoves;
      end;
      Selection := Selection shr 1;
    end;
  end
  else Result := 0;
end;

function TArmy.MoveTypes(Selection: Byte): TMoveTypes;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport <> nil then Result := Transport.GetMoveTypes
  else
  begin
    Result := [];
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
        Result := Result + TAbstractUnit(FChildren.List^[I]).GetMoveTypes;
      Selection := Selection shr 1;
    end;
  end;
end;

function TArmy.GetPartyMoves(Selection: Byte): TMoveTypes;
var Transport: TAbstractUnit; Common, Moves: TMoveTypes; MoveType, I: Integer;
begin
  Transport := Transporter(Selection);
  if Transport = nil then
  begin
    Common := [mtWalking..mtTunneling];
    MoveType := Ord(mtFlying);
    for I := 0 to GetCount - 1 do
      if (1 shl I) and Selection <> 0 then
      begin
        Moves := TAbstractUnit(FChildren.List^[I]).GetMoveTypes;
        Common := Common * Moves;
        if MoveType <> -1 then
          if TMoveType(MoveType) = mtFlying then
          begin
            if not (mtFlying in Moves) then
              if mtSwimming in Moves then MoveType := Ord(mtSwimming)
              else MoveType := Ord(mtWalking);
          end
          else if TMoveType(MoveType) = mtSwimming then
          begin
            if [mtFlying, mtSwimming] * Moves = [] then MoveType := Ord(mtWalking);
          end
          else if TMoveType(MoveType) = mtWalking then
            if [mtWalking, mtFlying, mtForestry..mtLavaCrossing] * Moves = [] then MoveType := -1;
      end;
    { Original leaves Result uninitialized when the units share no movement mode. }
    if MoveType <> -1 then Result := [TMoveType(MoveType)];
    Result := Result + Common;
  end
  else Result := Transport.GetMoveTypes;
end;

function TArmy.MoveOnMovePoints(Selection: Byte; TerrainType, OverlayType: Shortint): Integer;
var I: Integer; Table, UnitTable: TMovePointTable; Transport: TAbstractUnit;
begin
  FillChar(Table, SizeOf(Table), 1);
  Transport := Transporter(Selection);
  if Transport <> nil then Transport.CreateMovePointTable(Table)
  else
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        TAbstractUnit(FChildren.List^[I]).CreateMovePointTable(UnitTable);
        MaximizeMovePointTable(Table, UnitTable);
      end;
      Selection := Selection shr 1;
    end;
  Result := Table[TerrainType, OverlayType];
end;

procedure TArmy.CreateMovePointTable(Selection: Byte; var Table);
var I, Count: Integer; UnitTable: TMovePointTable; Transport: TAbstractUnit;
begin
  Count := 0;
  FillChar(Table, SizeOf(TMovePointTable), 1);
  Transport := Transporter(Selection);
  if Transport <> nil then
  begin
    Transport.CreateMovePointTable(TMovePointTable(Table));
    Inc(Count);
  end
  else
    for I := 0 to GetCount - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        TAbstractUnit(FChildren.List^[I]).CreateMovePointTable(UnitTable);
        MaximizeMovePointTable(Table, UnitTable);
        Inc(Count);
      end;
      Selection := Selection shr 1;
    end;
  if Count = 0 then FillChar(Table, SizeOf(TMovePointTable), -1);
end;

function TArmy.ValidTerrainEx(Selection: Byte; TerrainType, OverlayType: Shortint): Boolean;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter(Selection);
  if Transport = nil then
  begin
    I := 0;
    Result := True;
    while ((I <> GetCount) and Result) do
    begin
      if (1 shl I) and Selection <> 0 then
        Result := TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType);
      Inc(I);
    end;
  end
  else Result := Transport.ValidTerrain(TerrainType, OverlayType);
end;

function TArmy.ValidTerrain(TerrainType, OverlayType: Shortint): Boolean;
var I: Integer; Transport: TAbstractUnit;
begin
  Transport := Transporter($FF);
  if Transport = nil then
  begin
    I := 0;
    Result := True;
    while ((I <> GetCount) and Result) do
    begin
      Result := TAbstractUnit(FChildren.List^[I]).ValidTerrain(TerrainType, OverlayType);
      Inc(I);
    end;
  end
  else Result := Transport.ValidTerrain(TerrainType, OverlayType);
end;

function TArmy.CanPlace(X, Y, L: Shortint): Boolean;
var Field: TMapField; I: Integer;
begin
  Field := AoWHSMap.MapContainer.GetField(X, Y, L);
  Result := ValidTerrain(Field.TerrainType, Field.OverlayType);
  I := 0;
  if not (asActivated in FStatus) then
    while Result and (I <> FChildren.Count) do
    begin
      Result := TAbstractUnit(FChildren.List^[I]).CanActivate;
      Inc(I);
    end;
end;

procedure TArmy.MovedTo(OldField, NewField: TMapField; MaxCost: Integer);
var AUnit: TAbstractUnit; I: Integer;
begin
  BeginUpdate;
  FUserMode := FUserMode - [aumGuard];
  AUnit := Transporter($FF);
  if AUnit = nil then
    for I := FChildren.Count - 1 downto 0 do
      TAbstractUnit(FChildren.List^[I]).MovedTo(OldField, NewField, MaxCost)
  else
  begin
    AUnit.MovedTo(OldField, NewField, MaxCost);
    for I := FChildren.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if not AUnit.GetTransporter then AUnit.MovedTo(OldField, NewField, 0);
    end;
  end;
  UpdateExploration;
  EndUpdate;
end;

function TArmy.MaxSize: Integer;
var I, Capacity: Integer;
begin
  Result := 8;
  for I := 0 to GetCount - 1 do
  begin
    Capacity := TAbstractUnit(FChildren.List^[I]).GetTransportCapacity;
    if (Capacity <> 0) and (Result > Capacity + 1) then Result := Capacity + 1;
  end;
end;

function TArmy.Hero(Selection: Byte; Types: THeroTypes): THero;
var I: Integer; AUnit: TAbstractUnit;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if (AUnit is THero) and (THero(AUnit).GetHeroType in Types) then Result := THero(AUnit);
    end;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.Leader(Selection: Byte): TLeader;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
      if TAbstractUnit(FChildren.List^[I]).ClassID = $20232 then
        Result := TLeader(FChildren.List^[I]);
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.Transporter(Selection: Byte): TAbstractUnit;
var I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> GetCount) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
      if TAbstractUnit(FChildren.List^[I]).GetTransporter then
        Result := TAbstractUnit(FChildren.List^[I]);
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

function TArmy.IndexOfTransporter(Selection: Byte): Integer;
begin
  Result := GetCount;
  while Result <> 0 do
  begin
    Dec(Result);
    if ((1 shl Result) and Selection <> 0) and TAbstractUnit(FChildren.List^[Result]).GetTransporter then Exit;
  end;
  Result := -1;
end;

function TArmy.UnitsInTransporter: Byte;
var I: Integer; Field: TMapField;
begin
  if FX <> -1 then
  begin
    Field := AoWHSMap.MapContainer.GetField(FX, FY, FL);
    I := 0;
    Result := 0;
    while I <> GetCount do
    begin
      if not TAbstractUnit(FChildren.List^[I]).ValidTerrain(Field.TerrainType, Field.OverlayType) then
        Result := Result + (Byte(1) shl I);
      Inc(I);
    end;
  end
  else Result := 0;
end;

procedure TArmy.UpdateVisibilityRanges;
var I: Integer; TrueVision, Vision, Range: Byte;
begin
  Vision := 0;
  TrueVision := 0;
  for I := 0 to FChildren.Count - 1 do
  begin
    Range := TAbstractUnit(FChildren.List^[I]).VisibilityRange;
    if Range > Vision then Vision := Range;
    Range := TAbstractUnit(FChildren.List^[I]).TrueVisionRange;
    if Range > TrueVision then TrueVision := Range;
  end;
  FVisibilityRanges := TrueVision shl 4 + Vision;
end;

function TArmy.VisibilityRange: Byte;
begin Result := FVisibilityRanges and $F; end;

function TArmy.TrueVisionRange: Byte;
begin Result := FVisibilityRanges shr 4; end;

procedure TArmy.TurnUnFogOff;
var Range: Byte;
begin
  if asActivated in FStatus then
  begin
    Range := FUnfogRange;
    if Range <> 0 then
    begin
      AoWHSMap.FogArea(FX, FY, FL, Range);
      FUnfogRange := 0;
    end;
  end;
end;

procedure TArmy.UpdateExploration;
var Player: Integer;
begin
  if asActivated in FStatus then
    for Player := 1 to AoWHSMap.FPlayers.GetCount - 1 do
      if (Player = FPlayer) or
        (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Player) = drAlliance) then
        AoWHSMap.ExploreArea(FX, FY, FL, Player, VisibilityRange);
end;

procedure TArmy.UpdateUnfog;
var Range: Integer;
begin
  if asActivated in FStatus then
  begin
    if (AoWHSMap.FSeatedPlayer <> -1) and ((AoWHSMap.FSeatedPlayer = FPlayer) or
      (AoWHSMap.FPlayers.GetPlayers(FPlayer).FDiplomaticRelations.GetDiplomaticRelation(AoWHSMap.FSeatedPlayer) = drAlliance)) then
      Range := VisibilityRange
    else Range := 0;
    if Range <> FUnfogRange then
    begin
      if FUnfogRange <> 0 then AoWHSMap.FogArea(FX, FY, FL, FUnfogRange);
      FUnfogRange := Range;
      if FX <> -1 then
      begin
        if FUnfogRange <> 0 then AoWHSMap.UnFogArea(FX, FY, FL, FUnfogRange);
      end
      else FUnfogRange := 0;
    end;
  end;
end;

function TArmy.CanAddUnit(AUnit: TAbstractUnit): Boolean;
var HasTransporter: Boolean; Field: TMapField;
begin
  if asActivated in FStatus then
  begin
    Result := (GetCount < MaxSize) and AUnit.CanAddToList(Self);
    HasTransporter := IndexOfTransporter($FF) <> -1;
    if Result and not HasTransporter and (FX <> -1) and (FX <> 0) and
      not (amDisableTerrainValidation in FMode) then
    begin
      { Original skips terrain validation on the zero X column. }
      Field := AoWHSMap.MapContainer.GetField(FX, FY, FL);
      Result := AUnit.ValidTerrain(Field.TerrainType, Field.OverlayType);
    end;
    if Result and AUnit.GetTransporter then
      Result := not HasTransporter and (AUnit.GetTransportCapacity >= GetCount);
  end
  else Result := True;
end;

function TArmy.CanAddUnits(Units: TUnitList): TAddUnitsResult;
var I, TransportCount: Integer; Transport: TAbstractUnit;
begin
  TransportCount := 0;
  for I := 0 to Units.GetCount - 1 do
    if Units.GetUnit(I).GetTransporter then Inc(TransportCount);
  if IndexOfTransporter($FF) <> -1 then Inc(TransportCount);
  if TransportCount <= 1 then
  begin
  if TransportCount = 1 then
  begin
    Transport := Transporter($FF);
    if Transport = nil then
      for I := 0 to Units.GetCount - 1 do
        if Units.GetUnit(I).GetTransporter then Transport := Units.GetUnit(I);
    if Units.GetCount + GetCount <= Transport.GetTransportCapacity + 1 then Result := arOK
    else Result := arTooManyUnits;
  end
  else if Units.GetCount + GetCount <= 8 then
  begin
    I := 0;
    { Original repeats the list count test before testing each candidate. }
    if I <> Units.GetCount then
      while (I <> Units.GetCount) and CanAddUnit(Units.GetUnit(I)) do Inc(I);
    if I <> Units.GetCount then Result := arInvalidMoveType else Result := arOK;
  end
  else Result := arTooManyUnits;
  end
  else Result := arMultipleTransporters;
end;

function TArmy.AddUnits(Units: TUnitList): Boolean;
var I: Integer;
begin
  Result := CanAddUnits(Units) = arOK;
  if Result then
  begin
    BeginUpdate;
    for I := Units.GetCount - 1 downto 0 do AddUnit(Units.GetUnit(I));
    EndUpdate;
  end;
end;

function TArmy.CanAddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
var List: TList; I, TransportCount: Integer; Transport: TAbstractUnit;
begin
  List := TList.Create;
  for I := 0 to Units.GetCount - 1 do
  begin
    if Selection and 1 <> 0 then List.Add(Units.GetUnit(I));
    Selection := Selection shr 1;
  end;
  TransportCount := 0;
  for I := 0 to List.Count - 1 do
    if TAbstractUnit(List[I]).GetTransporter then Inc(TransportCount);
  if IndexOfTransporter($FF) <> -1 then Inc(TransportCount);
  if TransportCount <= 1 then
  begin
  if TransportCount = 1 then
  begin
    Transport := Transporter($FF);
    if Transport = nil then
      for I := 0 to List.Count - 1 do
        if TAbstractUnit(List[I]).GetTransporter then Transport := TAbstractUnit(List[I]);
    if List.Count + GetCount <= Transport.GetTransportCapacity + 1 then Result := arOK
    else Result := arTooManyUnits;
  end
  else if List.Count + GetCount <= 8 then
  begin
    I := 0;
    while (I <> List.Count) and CanAddUnit(TAbstractUnit(List[I])) do Inc(I);
    if I <> List.Count then Result := arInvalidMoveType else Result := arOK;
  end
  else Result := arTooManyUnits;
  end
  else Result := arMultipleTransporters;
  List.Free;
end;

function TArmy.AddUnitSelection(Units: TUnitList; Selection: Byte): TAddUnitsResult;
var I: Integer; List: TUnitUserList;
begin
  Result := CanAddUnitSelection(Units, Selection);
  if Result = arOK then
  begin
    Units.BeginUpdate;
    List := TUnitUserList.Create(nil);
    for I := Units.GetCount - 1 downto 0 do
      if (1 shl I) and Selection <> 0 then
        if not Units.GetUnit(I).GetTransporter then List.AddUnit(Units.GetUnit(I))
        else AddUnit(Units.GetUnit(I));
    for I := List.GetCount - 1 downto 0 do AddUnit(List.GetUnit(I));
    Units.EndUpdate;
    List.Free;
  end;
end;

function TArmy.CanDeleteUnit(AUnit: TAbstractUnit): Boolean;
begin
  if IndexOfTransporter($FF) <> -1 then
    if AUnit.GetTransporter and (UnitsInTransporter <> 0) then Result := False
    else Result := True
  else Result := True;
end;

function TArmy.RemoveChild(Child: TEObject): Integer;
begin
  BeginUpdate;
  with TAbstractUnit(Child) do AddRef;
  Result := inherited RemoveChild(Child);
  with TAbstractUnit(Child) do Release;
  EndUpdate;
end;

function TArmy.AddChild(Child: TEObject): Integer;
begin
  if not (asActivated in FStatus) or TAbstractUnit(Child).CanActivate then
  begin
    Result := inherited AddChild(Child);
    if Result <> -1 then
    begin
      if (asActivated in FStatus) and not (usActivated in TAbstractUnit(Child).FUnitStatus) then
        TAbstractUnit(Child).Activate;
      TAbstractUnit(Child).SetPlayer(FPlayer);
    end;
  end
  else Result := -1;
end;

function TArmy.AddUnit(AUnit: TAbstractUnit): Boolean;
begin
  AUnit.SetOwner(Self);
  Result := Self = AUnit.Owner;
end;

procedure TArmy.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin
  if asActivated in FStatus then
  begin Xhx := FX; Yhx := FY; Lhx := FL; end
  else begin Xhx := -1; Yhx := -1; Lhx := -1; end;
end;

function TArmy.SelectionUnit(Selection: Byte; Index: Integer): TAbstractUnit;
var I: Integer;
begin
  Result := nil;
  I := 0;
  while (I <> FChildren.Count) and (Result = nil) do
  begin
    if Selection and 1 <> 0 then
    begin
      if Index = 0 then Result := TAbstractUnit(FChildren.List^[I]);
      Dec(Index);
    end;
    Selection := Selection shr 1;
    Inc(I);
  end;
end;

procedure TArmy.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), 4);
  Stream.rwByte(Byte(FX), 5);
  Stream.rwByte(Byte(FY), 6);
  Stream.rwByte(Byte(FL), 7);
  if not (smWrite in Stream.StorageMode) or (AoWHSMap = nil) or
    (AoWHSMap.FConnectionType <> TPlayerConnectionType(1)) then
  begin
    Stream.rwByte(Byte(FDestinationX), 8);
    Stream.rwByte(Byte(FDestinationY), 9);
    Stream.rwByte(Byte(FDestinationL), 10);
    Stream.rwData(FUserMode, SizeOf(FUserMode), 13);
  end;
  Stream.rwData(FOldAIBehavior, SizeOf(FOldAIBehavior), 11);
  Stream.rwData(FMode, SizeOf(FMode), 12);
  if (smRead in Stream.StorageMode) and (amMoving in FMode) then
    FMode := FMode - [amMoving];
end;

procedure TArmy.MakeIndependent(Selection: Byte; var Armies: TArmyHSList); { Near miss: Selection spill and loop-counter allocation differ after three variants. }
var X, Y, L: Shortint; GoodArmy, EvilArmy: TArmy; Races, Units: TList;
  I, J, Race: Integer; AUnit: TAbstractUnit; Alignment: TAlignment; ArmyHS: TArmyHS;
  function PlaceIndependentArmy(AX, AY, AL: Shortint; Army: TArmy): TArmyHS;
  begin
    try
      if Army.GetCount <> 0 then
      begin
        Result := TArmyHS.Create(nil);
        Result.FArmy.BeginUpdate;
        Result.FArmy.AddUnits(Army);
        if Result.PlaceEx(X, Y, L, [apSafe, apScanArea]) then
        begin
          Result.Activate;
          Result.FArmy.EndUpdate;
        end
        else
        begin
          Result.FArmy.Kill($FF);
          Result.Free;
          Result := nil;
        end;
      end
      else Result := nil;
    except
      { Original suppresses placement failures without releasing a partly built army. }
      Result := nil;
    end;
  end;
begin
  BeginUpdate;
  GoodArmy := nil;
  EvilArmy := nil;
  Races := TList.Create;
  Units := TList.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then Units.Add(FChildren.List^[I]);
    Selection := Selection shr 1;
  end;
  for I := Units.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(Units.List^[I]);
    if (AUnit.GetRace <> -1) and not AUnit.GetAbilityEnabled($6B) then
    begin
      if AUnit.GetRace >= Races.Count then Races.Count := AUnit.GetRace + 1;
      if Races.List^[AUnit.GetRace] = nil then Races.List^[AUnit.GetRace] := TArmy.Create(nil);
      TArmy(Races.List^[AUnit.GetRace]).AddUnit(AUnit);
      Units.Delete(I);
    end;
  end;
  for I := Units.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(Units.List^[I]);
    Alignment := AUnit.GetAlignment;
    Race := -1;
    for J := Races.Count - 1 downto 0 do
      if (Races.List^[J] <> nil) and
        (Alignment in AoWHSSet.FRaceResources.GetRaceResource(J).FAlignments) then
        { Original chooses the largest compatible race group. }
        if (Race = -1) or (TArmy(Races.List^[Race]).GetCount <= TArmy(Races.List^[J]).GetCount) then Race := J;
    if Race <> -1 then
    begin
      TArmy(Races.List^[Race]).AddUnit(AUnit);
      Units.Delete(I);
    end
    else if (Alignment in alsGood) and
      (not (Alignment in alsEvil) or ((GoodArmy <> nil) and (EvilArmy = nil)) or
      ((GoodArmy = nil) and (EvilArmy = nil)) or
      ((GoodArmy <> nil) and (EvilArmy <> nil) and (GoodArmy.GetCount >= EvilArmy.GetCount))) then
    begin
      if GoodArmy = nil then GoodArmy := TArmy.Create(nil);
      GoodArmy.AddUnit(AUnit);
      Units.Delete(I);
    end
    else
    begin
      if EvilArmy = nil then EvilArmy := TArmy.Create(nil);
      EvilArmy.AddUnit(AUnit);
      Units.Delete(I);
    end;
  end;
  X := FX;
  Y := FY;
  L := FL;
  EndUpdate;
  for I := 0 to Races.Count - 1 do
    if Races.List^[I] <> nil then
    begin
      ArmyHS := PlaceIndependentArmy(X, Y, L, TArmy(Races.List^[I]));
      if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
      TArmy(Races.List^[I]).Free;
      Races.List^[I] := nil;
    end;
  if GoodArmy <> nil then
  begin
    ArmyHS := PlaceIndependentArmy(X, Y, L, GoodArmy);
    if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
    GoodArmy.Free;
  end;
  if EvilArmy <> nil then
  begin
    ArmyHS := PlaceIndependentArmy(X, Y, L, EvilArmy);
    if (Armies <> nil) and (ArmyHS <> nil) then Armies.AddChild(ArmyHS);
    EvilArmy.Free;
  end;
  Units.Free;
  Races.Free;
end;

procedure TArmy.UpdateIndependentRelation;
var Race: Shortint; Valid, Evil, Good, Neutral: Boolean; I, UnitRace: Integer;
  AUnit: TAbstractUnit; Alignment: TAlignment;
begin
  if FPlayer = 0 then
  begin
    Race := -1;
    Valid := True;
    I := FChildren.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      if not TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($6B) then
        UnitRace := TAbstractUnit(FChildren.List^[I]).GetRace
      else UnitRace := -1;
      if (UnitRace <> -1) and (UnitRace <> Race) then
        if Race = -1 then Race := UnitRace else Valid := False;
    end;
    if Valid and (Race = -1) then
    begin
      if FX <> -1 then
      begin
        Race := FIndependentRelation;
        FIndependentRelation := -1;
        FIndependentRelation := TAoWMapField(AoWHSMap.MapContainer.GetField(FX, FY, FL)).GetIndependentRelation;
        if FIndependentRelation >= 0 then Race := FIndependentRelation
        else begin FIndependentRelation := Race; Race := -1; end;
      end;
      if Race = -1 then
        if FIndependentRelation >= 0 then Race := FIndependentRelation else Valid := False;
    end;
    I := FChildren.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      Valid := (Race = TAbstractUnit(FChildren.List^[I]).GetRace) or
        (TAbstractUnit(FChildren.List^[I]).GetAlignment in AoWHSSet.FRaceResources.GetRaceResource(Race).FAlignments);
    end;
    if not Valid then
    begin
      Evil := True;
      Good := True;
      Neutral := True;
      for I := 0 to FChildren.Count - 1 do
      begin
        AUnit := TAbstractUnit(FChildren.List^[I]);
        Alignment := AUnit.GetAlignment;
        Evil := Evil and (Alignment in alsEvil) and
          ((AUnit.GetRace = -1) or (Alignment in [alEvil, alPureEvil]));
        Good := Good and (Alignment in alsGood) and
          ((AUnit.GetRace = -1) or (Alignment in [alPureGood, alGood]));
        Neutral := Neutral and (Alignment in alsNeutral);
      end;
      if Good and not Evil then FIndependentRelation := -2
      else if Evil and not Good then FIndependentRelation := -4
      else FIndependentRelation := -3;
    end
    else FIndependentRelation := Race;
  end
  else FIndependentRelation := -1;
end;

procedure TArmy.Desert(Selection: Byte); { Near miss: Three variants retain different selection-mask/register allocation. }
var Units: TList; Player: Shortint; Armies: TArmyHSList; Count, I, Bit: Integer;
  Log: TArmyInfoEventLog; AUnit: TAbstractUnit;
begin
  AoWHSMap.LockGameOverEvent;
  Units := TList.Create;
  Count := SelectionCount(Selection);
  Log := TArmyInfoEventLog.Create(nil);
  Log.FArmyView.Setup(Self, $FF);
  Log.FSelection := Selection;
  Log.FPlayer := FPlayer;
  Log.FTitle := TranslateRStr(DesertionRStr);
  Log.FTriggers := [etUser];
  if (AoWHSMap.FPlayMode = pmTurn) and (wpRebellion in AoWEngine.FRegistry.GetClassicWindowPopupEvents) then
  begin
    Log.FTriggers := Log.FTriggers + [etEvent];
    if AoWHSMap.FRequestCombatType then Log.FTriggers := Log.FTriggers + [etNewTurn];
  end;
  if (AoWHSMap.FPlayMode = pmSimultaneous) and (wpRebellion in AoWEngine.FRegistry.GetSimultaneousWindowPopupEvents) then
    Log.FTriggers := Log.FTriggers + [etEvent, etNewTurn];
  Log.FDescription := TranslateRStr(TheLeaderOfThePartyStepsForwardRStr);
  if Count = 1 then Log.FText := TranslateRStr(OneUnitDesertedRStr)
  else Log.FText := Format(TranslateRStr(XUnitsDesertedRStr), [IntToStr(Count)]);
  if (AoWHSMap.FPlayers.GetPlayers(FPlayer).FGems = 0) and
    (AoWHSMap.FPlayers.GetPlayers(FPlayer).GetUpkeep > AoWHSMap.FPlayers.GetPlayers(FPlayer).FIncome) then
    if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitNoUpkeepRStr)
    else Log.FMessages.Text := TranslateRStr(DesertUnitsNoUpkeepRStr)
  else if ValidateSelection($FF) = Selection then
    if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitLowMoraleRStr)
    else Log.FMessages.Text := TranslateRStr(DesertUnitsLowMoraleRStr)
  else if Count = 1 then Log.FMessages.Text := TranslateRStr(DesertUnitLowMoraleSplitRStr)
  else Log.FMessages.Text := TranslateRStr(DesertUnitsLowMoraleSplitRStr);
  DistributeLocationEventLog(Log, -1, FX, FY, FL, True);
  Log.Release;
  for I := GetCount - 1 downto 0 do
  begin
    Bit := 1 shl I;
    if (Bit and Selection <> 0) and GetUnit(I).GetAbilityEnabled($9B) then
    begin
      Units.Add(GetUnit(I));
      Selection := Selection and not Byte(Bit);
    end;
  end;
  Armies := TArmyHSList.Create(nil);
  Player := FPlayer;
  MakeIndependent(Selection, Armies);
  while Units.Count <> 0 do
  begin
    AUnit := TAbstractUnit(Units[0]);
    AUnit.AddRef;
    AUnit.Killed;
    AUnit.SetOwner(nil);
    AUnit.Release;
    Units.Delete(0);
  end;
  for I := 0 to Armies.GetCount - 1 do
    if DiplomaticRelation(0, Armies.GetArmyHS(I).FArmy.FIndependentRelation, Player, 0) = drWar then
      Armies.GetArmyHS(I).FArmy.SetBehavior($FF, gbRaid)
    else Armies.GetArmyHS(I).FArmy.SetBehavior($FF, gbScout);
  Armies.Free;
  Units.Free;
  AoWHSMap.UnlockGameOverEvent;
end;

function TArmy.GetPartyStatus(Selection: Byte): TPartyStatus;
var I, Morale, Count: Integer; Predictor: TCombatPredictor; UnitMorale: Integer; AUnit: TAbstractUnit;
begin
  Morale := 100;
  Count := 0;
  Predictor := TCombatPredictor.Create;
  for I := 0 to FChildren.Count - 1 do
  begin
    if Selection and 1 <> 0 then
    begin
      AUnit := TAbstractUnit(FChildren.List^[I]);
      UnitMorale := AUnit.FMoraleValue;
      if AUnit.GetUnitType <> utMachine then
      begin
        if UnitMorale < Morale then Morale := UnitMorale;
        Inc(Count);
      end;
      if UnitMorale <= 40 then Predictor.AddOpponent(AUnit, 0)
      else Predictor.AddUnit(AUnit);
    end;
    Selection := Selection shr 1;
  end;
  if Predictor.Execute = crDefeat then
    if Predictor.GetSuperiority < 50 then Result := psUnruly else Result := psUnrest
  else if (Count = 0) or (Morale <= 60) then Result := psStable
  else if Morale <= 80 then Result := psContent
  else Result := psCheerful;
  Predictor.Free;
end;

procedure TArmy.UpdateDesertion;
var Status: TPartyStatus; Chance, I: Integer; Selection: Byte;
begin
  if (FX <> -1) and (FPlayer <> 0) then
  begin
    Status := GetPartyStatus($FF);
    if Status in [psUnruly, psUnrest] then
    begin
      if Status = psUnrest then Chance := 10 else Chance := 50;
      if Chance > AoWHSMap.Random(100) then
      begin
        Selection := 0;
        for I := FChildren.Count - 1 downto 0 do
        begin
          Selection := Selection shl 1;
          if Smallint(TAbstractUnit(FChildren.List^[I]).FMoraleValue) <= 40 then Selection := Selection or 1;
        end;
        if Selection <> 0 then Desert(Selection);
      end;
    end;
  end;
end;

function TArmy.ValidateCrusaders: Boolean;
var I: Integer;
begin
  I := GetCount;
  Result := False;
  while (I <> 0) and not Result do
  begin
    Dec(I);
    if TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($65) then Result := True;
  end;
  if Result then
  begin
    BeginUpdate;
    for I := GetCount - 1 downto 0 do
      if TAbstractUnit(FChildren.List^[I]).GetAbilityEnabled($65) then
        TAbstractUnit(FChildren.List^[I]).ValidateCrusader;
    Result := GetCount <> 0;
    EndUpdate;
  end
  else Result := True;
end;

procedure TArmy.NewTurn(Player: Shortint);
begin
  if Player = FPlayer then
  begin
    FUserMode := FUserMode - [aumTurnDone];
    if ValidateCrusaders then UpdateDesertion;
  end;
end;

procedure TArmy.NewTurnDone(Player: Shortint);
begin
  if Player = FPlayer then
    if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman then UpdateGroupBehavior;
end;

procedure TArmy.NewDay;
begin
  if AoWHSMap.FDay = 1 then
  begin
    ResetDestinationPos;
    if (FX <> -1) and (FPlayer > 0) then
    begin
      AoWHSMap.ExploreArea(FX, FY, FL, FPlayer, VisibilityRange);
      AoWHSMap.UpdatePlayerSeen(FPlayer, FX, FY, FL, VisibilityRange, TrueVisionRange);
    end;
    InitializeGroupBehavior;
  end;
end;

procedure TArmy.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20020003 then NewTurnDone(Msg.Value);
  if Msg.MsgID = $20020002 then LockChanged;
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then UnlockChanged;
  if Msg.MsgID = $20020005 then SetPlayer(FPlayer)
  else if (Msg.MsgID = $20020006) and (AoWHSMap.FSeatedPlayer <> -1) then
  begin
    UpdateUnfog;
    UpdateConcealment;
  end
  else if Msg.MsgID = $20020008 then
  begin
    UpdateVisibilityRanges;
    UpdateExploration;
    if AoWHSMap.FSeatedPlayer <> -1 then
    begin UpdateUnfog; UpdateConcealment; end;
  end
  else if Msg.MsgID = $20020002 then NewTurn(Msg.Value)
  else if Msg.MsgID = $20020001 then NewDay
  else if (Msg.MsgID = $20020003) and (Msg.Value = FPlayer) then ValidateCrusaders;
end;

function TArmy.CanActivate: Boolean;
begin
  Result := True;
end;

function TArmy.GetMoveAction(Player: Shortint): TMoveAction;
begin
  Result := maNormal;
  if Player <> FPlayer then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType = ptHuman then
    begin
      if not (asFullyConcealed in FStatus) then
        if (FPlayer = 0) and (GetJoinSelection(Player) <> 0) then Result := maNegotiate
        else Result := maAttack;
    end
    else
      if (FPlayer = 0) and (GetJoinSelection(Player) <> 0) then Result := maNegotiate
      else Result := maAttack;
  end
  else Result := maCombine;
end;

function TArmy.GetCanJoinSelection(Player: Shortint): Byte;
var I: Integer; AUnit: TAbstractUnit;
begin
  if Player > 0 then
  begin
    Result := 0;
    for I := Count - 1 downto 0 do
    begin
      Result := Result shl 1;
      AUnit := TAbstractUnit(FChildren.List^[I]);
      if AUnit.CanJoin(Player) then Result := Result or 1;
    end;
    if IndexOfTransporter($FF) <> -1 then
      if Result <> ValidateSelection($FF) then Result := 0;
  end
  else Result := 0;
end;

function TArmy.GetJoinSelection(Player: Shortint): Byte;
var WantsJoin: Boolean; I: Integer;
begin
  Result := 0;
  if Player > 0 then
  begin
    WantsJoin := False;
    I := Count;
    while not WantsJoin and (I <> 0) do
    begin
      Dec(I);
      WantsJoin := TAbstractUnit(FChildren.List^[I]).OfferToJoin(Player);
    end;
    if WantsJoin then Result := GetCanJoinSelection(Player);
  end;
end;

function TArmy.JoinAmount(Player: Shortint; Selection: Byte): Integer;
var I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      Inc(Result, TAbstractUnit(FChildren.List^[I]).JoinAmount(Player));
    Selection := Selection shr 1;
  end;
end;

function TArmy.IncommingNegotiateRequest(Log: TNegotiateRequestEventLog): Boolean;
begin
  Result := False;
  if FPlayer = 0 then
  begin
    Log.SetupJoinArmy(Self, Log.FPlayer, jmDefault);
    Log.FObject := noArmy;
    Log.FText := TranslateRStr(P2PartyJoinHeaderRStr);
    Result := Log.FSelection <> 0;
  end;
end;

function TArmy.IncommingNegotiateOffer(Offer: TNegotiateTE): Boolean; { Near miss: Frame and string-temporary layout differ after three variants. }
var
  Log: TArmyInfoEventLog;
  Selection: Byte;
  AHero: THero;
  Locations: TXYLList;
  I, J, Direction, X, Y, JoinCount: Integer;
  Placed: Boolean;
begin
  if Offer.FObject = noArmy then
  begin
    if Offer.FResult = nrAccept then
    begin
      Selection := GetJoinSelection(Offer.FPlayer);
      JoinCount := SelectionCount(Selection);
      if (nmPrisonerJoin in Offer.FMode) or (JoinAmount(Offer.FPlayer, Selection) <= Offer.FGold) then
      begin
        BeginUpdate;
        Offer.FMode := Offer.FMode + [nmMoveOnAccept];
        Log := TArmyInfoEventLog.Create(nil);
        Log.FArmyView.Setup(Self, Selection);
        Log.FSelection := $FF;
        Log.FDescription := '';
        Log.FTitle := TranslateRStr(P2PartyJoinRStr);
        Log.FTriggers := [etEvent];
        AHero := Hero(Selection, [htHero]);
        if AHero = nil then
        begin
          if JoinCount = 1 then
          begin
            Log.FText := TranslateRStr(P2OneUnitJoinedRStr);
            Log.FMessages.Add(Format(TranslateRStr(P2AUnitJoinedTheForcesofYRStr),
              [AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
          end
          else
          begin
            Log.FText := Format(TranslateRStr(P2XUnitsJoinedRStr), [IntToStr(JoinCount)]);
            Log.FMessages.Add(Format(TranslateRStr(P2XUnitsJoinedTheForcesofYRStr),
              [SelectionCount(Selection), AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
          end;
        end
        else
        begin
          Log.FText := Format(TranslateRStr(P2XJoinedRStr), [AHero.FHeroName]);
          Log.FMessages.Add(Format(TranslateRStr(P2XJoinedTheForcesOfYRStr),
            [AHero.FHeroName, AoWHSMap.FPlayers.GetPlayers(Offer.FPlayer).GetName]));
        end;
        DistributeLocationEventLog(Log, -1, FX, FY, FL, False);
        Log.Release;
        if ValidateSelection($FF) <> Selection then
        begin
          Locations := TXYLList.Create;
          if Offer.FArmyHS <> nil then
          begin
            Direction := dHXtoHNfast(FX, FY, Offer.FArmyHS.GetXhx, Offer.FArmyHS.GetYhx);
            if (Direction > 0) and (Direction <= 6) then
            begin
              Locations.AddXYL(FX, FY, FL);
              J := Direction + 1;
              if J > 6 then J := 1;
              CenterHNtoHX(Offer.FX, Offer.FY, J, X, Y);
              Locations.AddXYL(X, Y, FL);
              Dec(Direction);
              if Direction = 0 then Direction := 6;
              CenterHNtoHX(Offer.FX, Offer.FY, Direction, X, Y);
              Locations.AddXYL(X, Y, FL);
            end;
          end;
          J := 0;
          I := Count;
          while I <> 0 do
          begin
            Dec(I);
            if (Selection and (1 shl I)) <> 0 then
            begin
              Placed := False;
              while not Placed and (J < Locations.Count) do
              begin
                Placed := GetUnit(I).Place(Locations[J].X, Locations[J].Y, Locations[J].L,
                  Offer.FPlayer, []) <> nil;
                if not Placed then Inc(J);
              end;
              if not Placed then GetUnit(I).Place(FX, FY, FL, Offer.FPlayer, [pmScanArea]);
            end;
          end;
          Locations.Free;
        end
        else SetPlayer(Offer.FPlayer);
        EndUpdate;
        Offer.Accept;
      end
      else
      begin
        Offer.FMode := [nmAttackOnReject];
        Offer.Reject;
      end;
    end
    else if (Offer.FResult = nrReject) and not (nmPrisonerJoin in Offer.FMode) then Offer.Reject;
    Result := True;
  end
  else Result := False;
end;

procedure TArmy.TriggerFireDamage;
var Log: TArmyEventLog; AUnit: TAbstractUnit; Damage: Integer; Damaged: Boolean; I: Integer;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(P2FireDamageRStr);
  Log.FPlayer := GetArmyHS.FArmy.FPlayer;
  Log.FArmyMessages.Add(TranslateRStr(P2FireDamageRStr));
  Log.FArmyIcon := 0;
  Log.FArmyView.Setup(GetArmyHS.FArmy, $FF);
  BeginUpdate;
  Damaged := False;
  for I := 0 to Count - 1 do
  begin
    AUnit := GetUnit(I);
    if not (dtFire in AUnit.GetImmunityTypes) then
    begin
      Damage := AUnit.ExecuteDamageRole(4, 4, [dtFire]);
      if Damage > AUnit.GetHitPoints then Damage := AUnit.GetHitPoints;
      if Damage <> 0 then
      begin
        Damaged := True;
        AUnit.SetHitPoints(AUnit.GetHitPoints - Shortint(Damage));
      end;
      Log.FDamageValues.Add(Damage);
      Log.FDamageTypes.Add(Ord(dtFire));
    end
    else
    begin
      Log.FDamageValues.Add(0);
      Log.FDamageTypes.Add(Ord(dtNone));
    end;
  end;
  Log.ValidateGameOver;
  if Damaged then DistributeLocationEventLog(Log, -1, FX, FY, FL, True);
  Log.Release;
  Validate;
  EndUpdate;
end;

procedure TArmy.RetrieveStormDamageInfo(Storm: TStormType; Distance: Integer; var Info: TStormDamageInfo);
var I, Attack, Damage: Integer; Relation: Byte; Value, Amount: Integer; AUnit: TAbstractUnit;
begin
  Relation := Ord(DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation));
  if (Relation in Info.FriendlyRelations) or (Relation in Info.EnemyRelations) then
  begin
    case Storm of
      stIce: begin Attack := 7; Damage := 5; end;
      stLightning: begin Attack := 8; Damage := 7; end;
      stDeath: begin Attack := 7; Damage := 4; end;
      stHoly: begin Attack := 7; Damage := 5; end;
      stFire: begin Attack := 7; Damage := 5; end;
      stPestilence: begin Attack := 4; Damage := 3; end;
    else Attack := 0; Damage := 0;
    end;
    for I := Count - 1 downto 0 do
    begin
      AUnit := GetUnit(I);
      if (AUnit.FPlayer <> 0) or ((AUnit.FGroup <> nil) and (AUnit.FGroup.Behavior <> gbPassive)) then
      begin
        AUnit.RetrieveDamageInfo(Attack, Damage, [StormDamageType[Storm]], Value, Amount);
        if Relation in Info.FriendlyRelations then
        begin Inc(Info.FriendlyDamage, Amount); Inc(Info.FriendlyValue, Value); { Original assigns the second return to damage. } end;
        if Relation in Info.EnemyRelations then
        begin Inc(Info.EnemyDamage, Amount); Inc(Info.EnemyValue, Value); end;
      end;
    end;
  end;
end;

procedure TArmy.IncommingStorm(A1: TStormType; A2: Integer; A3: Shortint);
var Log: TArmyEventLog; Damaged: Boolean; I, Damage: Integer;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Log := TArmyEventLog.Create(nil);
  Log.FArmyText := TranslateRStr(TStormTypeRStr[A1]);
  Log.FPlayer := A3;
  Log.FArmyMessages.Add(TranslateRStr(TStormTypeRStr[A1])); { Original appends the storm message. }
  Log.FArmyIcon := 2;
  Log.FArmyView.Setup(Self, $FF);
  BeginUpdate;
  Damaged := False;
  for I := 0 to Count - 1 do
  begin
    Damage := TAbstractUnit(FChildren.List^[I]).ExecuteStormDamage(A1, A2);
    if Damage <> 0 then Damaged := True;
    Log.FDamageValues.Add(Damage);
    Log.FDamageTypes.Add(Ord(StormDamageType[A1]));
  end;
  if Damaged then
  begin
    Log.ValidateGameOver;
    DistributeLocationEventLog(Log, FPlayer, FX, FY, FL, True);
  end;
  Log.Release;
  Validate;
  EndUpdate;
end;

procedure TArmy.UpdateAITarget(const Info: TAITargetInfo; var Data: TAITargetData);
var Selection: Byte;
begin
  case Info.Mode of
    tmAttack, tmRaid, tmAttackArmies:
      if not GetUnitsConcealedForPlayer($FF, Info.Player) and (Info.Player <> FPlayer) then
      begin
        if FPlayer > 0 then
        begin
          if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) or (Info.Mode = tmRaid) then
            if (Info.Player <> 0) and (Leader($FF) <> nil) then Data.Priority := 300
            else if (Info.Player <> 0) and (Hero($FF, [htHero]) <> nil) then Data.Priority := 100
            else Data.Priority := 50
          else Data.Priority := 0;
        end
        else if FPlayer = 0 then
        begin
          Selection := GetJoinSelection(Info.Player);
          if Selection <> 0 then
          begin
            Data.Cost := JoinAmount(Info.Player, Selection);
            Data.TargetType := attNegotiate;
          end
          else if ValidAttackRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) then
            Data.Priority := 50;
        end;
      end;
    tmGuardArea:
      if not GetUnitsConcealedForPlayer($FF, Info.Player) and (Info.Player <> FPlayer) then Data.Priority := 50
      else Data.Priority := 0;
    tmHunt: Data.Priority := 10;
    tmRecruit:
      if (Info.Player = FPlayer) and ((FPlayer <> 0) or
        (DiplomaticRelation(Info.Player, Info.IndependentRelation, FPlayer, FIndependentRelation) <> drWar)) then
        Data.Priority := Data.Priority or 1;
  end;
end;

function TArmy.AIMovePriority: Integer;
begin
  Result := 0;
  if Leader($FF) <> nil then Inc(Result, 50000);
  if Hero($FF, [htHero, htHeroLeader]) <> nil then Inc(Result, 10000);
  Inc(Result, ObtainValue($FF));
end;

procedure TArmy.ResetMoveDone;
var I: Integer; AUnit: TAbstractUnit;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    AUnit := TAbstractUnit(FChildren.List^[I]);
    AUnit.FUnitStatus := AUnit.FUnitStatus - [usMoveDone];
  end;
end;

function TArmy.CanCombine(Army: TArmy; Selection: Byte): Boolean;
var I, MaxCount: Integer; Temp: Byte; OwnTransporter, OtherTransporter: TAbstractUnit;
begin
  Selection := Army.ValidateSelection(Selection);
  I := 0;
  Temp := Selection;
  while Temp <> 0 do
  begin
    if Temp and 1 <> 0 then Inc(I);
    Temp := Temp shr 1;
  end;
  OwnTransporter := Transporter($FF);
  if OwnTransporter <> nil then MaxCount := OwnTransporter.GetTransportCapacity + 1
  else MaxCount := 8;
  Inc(I, Count);
  if I <= MaxCount then
  begin
    OtherTransporter := Army.Transporter(Selection);
    if (OtherTransporter <> nil) and ((I > OtherTransporter.GetTransportCapacity + 1) or (OwnTransporter <> nil)) then
      Result := False
    else Result := True;
  end
  else Result := False;
end;

constructor TArmyHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmy := TArmy.Create(nil);
end;

destructor TArmyHS.Destroy;
begin
  FArmy.FOnUpdate := nil;
  inherited Destroy;
  FArmy.Free;
  FArmy := nil;
end;

class function TArmyHS.ClassID: Integer;
begin
  Result := $20217;
end;

function TArmyHS.GetFogEnabled: Boolean;
begin
  Result := (AoWHSMap.FFogEnabled) and
    (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo = 0);
end;

function TArmyHS.VisibleForSeatedPlayer: Boolean;
begin
  Result := ((not AoWHSMap.FFogEnabled) or
    (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0)) and not FArmy.GetFullyConcealed;
end;

function TArmyHS.EditName: string;
begin
  Result := TranslateRStr(P2ArmyRStr);
end;

procedure TArmyHS.Clear;
begin
  inherited Clear;
  FArmy.Clear;
end;

function TArmyHS.PlaceOnMap: Boolean;
var Msg: TMapFieldMsg;
begin
  Result := inherited PlaceOnMap;
  if Result then
  begin
    FArmy.BeginUpdate;
    with TMapField(Owner) do FArmy.SetXYL(Xhx, Yhx, Lhx);
    FArmy.UpdateUnfog;
    FArmy.UpdateExploration;
    Msg.MsgID := $1102;
    Msg.Param[0] := Integer(Self);
    TMapField(Owner).SendMapFieldMsg(Msg);
    FArmy.EndUpdate;
  end;
end;

procedure TArmyHS.RemoveFromMap;
var Field: TMapField; Msg: TMapFieldMsg;
begin
  Field := TMapField(Owner);
  if Owner <> nil then FArmy.TurnUnFogOff;
  inherited RemoveFromMap;
  if (Field <> nil) and (AoWHSMap <> nil) and not (msDestroying in AoWHSMap.Status) then
  begin
    Msg.MsgID := $1103;
    Msg.Param[0] := Integer(Self);
    Field.SendMapFieldMsg(Msg);
  end;
end;

procedure TArmyHS.Select;
begin
  FArmy.Select;
  if Self <> AoWHSMap.FSelectedArmy.GetArmyHS then AoWHSMap.FSelectedArmy.SetArmyHS(Self);
end;

procedure TArmyHS.Unselect;
begin
  inherited Unselect;
  FArmy.Unselect;
  if Self = AoWHSMap.FSelectedArmy.GetArmyHS then AoWHSMap.FSelectedArmy.SetArmyHS(nil);
end;

function TArmyHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  if not GetFogEnabled and (AoWHSMap.FSeatedPlayer <> -1) then
    begin if (asFullyConcealed in FArmy.FStatus) or not inherited CanSelect(Xhp, Yhp) then Result := False else Result := True; end else Result := False;
end;

function TArmyHS.GetSelected: Boolean;
begin
  Result := asSelected in FArmy.FStatus;
end;

procedure TArmyHS.ArmyUpdated(Sender: TObject);
var Msg: TMapFieldMsg;
begin
  if FArmy.Count <> 0 then
  begin
    Msg.MsgID := $1124;
    Msg.Param[0] := Integer(Self);
    TMapField(Owner).SendMapFieldMsg(Msg);
    UpdateUnitGFXResource;
    if FArmy.FPlayer <> 0 then FFlagID := AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace
    else FFlagID := $20;
  end
  else if Sender = FArmy then Destroy;
end;

procedure TArmyHS.UpdateFlagID;
begin
  if FArmy.FPlayer > 0 then
  begin
    FFlagID := AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace;
    Exit;
  end;
  FFlagID := $20;
end;

procedure TArmyHS.UpdateUnitGFXResource;
var I: Integer;
begin
  if asConcealed in FArmy.FStatus then
  begin
    I := 0;
    while ((FArmy.FConcealedUnits shr I) and 1) = 1 do Inc(I);
    if I >= FArmy.Count then I := 0;
  end
  else I := 0;
  FUnitIndex := I;
  SetUnitGFXResourceIndex(FArmy.GetUnit(I).GetUnitGFXResourceIndex);
  if mtFlying in FArmy.GetUnit(I).GetMoveTypes then FUnitYOffset := -8
  else FUnitYOffset := 0;



















































































































































































































































  Assert(FUnitGFXResource <> nil);
end;

procedure TArmyHS.Activate;
begin
  inherited Activate;
  FArmy.SetXYL(GetXhx, GetYhx, GetLhx);
  FArmy.Activate;
  FArmy.FOnUpdate := ArmyUpdated;
  if Self = TAoWMapField(Owner).GetArmyHS then
  begin
    if FArmy.Count <> 0 then UpdateUnitGFXResource
    else if not (msEditting in AoWHSMap.Status) then
    begin
      Destroy;
      Exit;
    end;
  end
  else Destroy;
end;

procedure TArmyHS.Deactivate;
begin
  inherited Deactivate;
  FArmy.Deactivate;
end;

procedure TArmyHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FArmy, 10);
end;

function TArmyHS.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin
  if Info.HN = 0 then
    Result := ((Info.MapField.TerrainType = 0) and (Info.Sender <> nil) and
      ((TEObject(Info.Sender).ClassID = $2123E) or (TEObject(Info.Sender).ClassID = $2016C))) or
      FArmy.ValidTerrain(Info.MapField.TerrainType, Info.MapField.OverlayType)
  else Result := True;
end;

procedure TArmyHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  if (Info.HN = 0) and (asActivated in FArmy.FStatus) then
  begin
    FArmy.BeginUpdate;
    FArmy.ValidateTerrain(Info.TerrainType, Info.OverlayType);
    FArmy.EndUpdate;
  end;
end;

function TArmyHS.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if Info.HN = 0 then
  begin
    if not (mmAI in TMoveControl(Info.Sender).FMode) and
      (GetFogEnabled or (asFullyConcealed in FArmy.FStatus) or (mmIgnoreArmies in TMoveControl(Info.Sender).FMode)) then
    begin Result := 1; Exit; end;
    if TMoveControl(Info.Sender).FPlayer = FArmy.FPlayer then
    begin
      if not (mmAvoidArmies in TMoveControl(Info.Sender).FMode) or (Self = TMoveControl(Info.Sender).FTransporterArmy) then
      begin
        if FArmy.FPlayer <> 0 then
        begin

          if (mmAI in TMoveControl(Info.Sender).FMode) and (FArmy.IndexOfTransporter($FF) <> -1) then
          begin Result := 2; Exit; end;
          if (TMoveControl(Info.Sender).FArmyHS <> nil) and
            FArmy.CanCombine(TMoveControl(Info.Sender).FArmyHS.FArmy, TMoveControl(Info.Sender).FSelection) then Result := 1
          else Result := 2;
        end else Result := 2;
      end
      else Result := 0;
    end
    else if AoWHSMap.FPlayers.GetDiplomaticRelation(TMoveControl(Info.Sender).FPlayer, FArmy.FPlayer) = drAlliance then
    begin
      if (Info.MapField.OverlayType <> 7) or (Info.MapField.FindNoneTransparentHS(TPlayerStructure) = nil) then
      Result := 2
      else Result := 0;
    end
    else Result := 0;
  end
  else Result := 1;
end;

procedure TArmyHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult); { Near miss: Three variants retain different sender caching and branches. }
begin
  if Info.HN = 0 then
  begin
    if FArmy.FPlayer = TMoveControl(Info.Sender).FPlayer then
    begin
      if (mmSurround in TMoveControl(Info.Sender).FMode) and (Info.MoveOverCode <> 1) and
        (TMapField(Owner).Xhx = TMoveControl(Info.Sender).FDestinationX) and
        (TMapField(Owner).Yhx = TMoveControl(Info.Sender).FDestinationY) and
        (TMapField(Owner).Lhx = TMoveControl(Info.Sender).FDestinationL) and
        not FArmy.CanCombine(TMoveControl(Info.Sender).FArmyHS.FArmy, TMoveControl(Info.Sender).FSelection) then
      begin MoveResult.Code := -1; MoveResult.Done := True; Exit; end;
      if (TMoveControl(Info.Sender).FArmyHS <> nil) and (FArmy.IndexOfTransporter($FF) <> -1) and
        (TMoveControl(Info.Sender).FArmyHS.FArmy.Transporter(TMoveControl(Info.Sender).FSelection) = nil) then
      begin MoveResult.Code := 4; MoveResult.Done := True; end;
    end
    else if Info.MoveOverCode <> 1 then
    begin MoveResult.Code := -1; MoveResult.Done := True; end;
  end;
end;

procedure TArmyHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN = 0 then TAoWMapField(Info.MapField).FFieldFlags := TAoWMapField(Info.MapField).FFieldFlags or $2000 or $1000 or $1000000 or $4000 or $2000000 or $4000000 or $8000000;
end;

function TArmyHS.MoveTo(Field: TMapField; MoveCost: Integer): Boolean;
var OldField: TMapField; Msg: TMapFieldMsg;
begin
  FArmy.BeginUpdate;
  OldField := TMapField(Owner);
  if OldField <> nil then
  begin
    Msg.MsgID := $1140;
    Msg.Param[0] := Integer(Self);
    Msg.Param[1] := Integer(Field);
    Msg.Result := 0;
    OldField.SendMapFieldMsg(Msg);
  end;
  if (OldField = nil) or (Msg.Result = 0) then
  begin
    Msg.MsgID := $1141;
    Msg.Param[0] := Integer(Self);
    Msg.Param[1] := Integer(OldField);
    Msg.Result := 0;
    Field.SendMapFieldMsg(Msg);
    if Msg.Result = 0 then
    begin
      inherited MoveTo(Field, MoveCost);
      if (OldField <> nil) and ((Field.Lhx <> OldField.Lhx) or
        not ConnectingHX(OldField.Xhx, OldField.Yhx, Field.Xhx, Field.Yhx)) then
      begin
        AoWHSMap.NotifyPlayerChanged(OldField.Xhx, OldField.Yhx, OldField.Lhx);
        AoWHSMap.NotifyPlayerChanged(Field.Xhx, Field.Yhx, Field.Lhx);
      end
      else AoWHSMap.NotifyPlayerChangedEx(Field.Xhx, Field.Yhx, Field.Lhx, $D);
      FArmy.Validate;
      FArmy.MovedTo(OldField, Field, MoveCost);
      Msg.MsgID := $1142;
      Msg.Param[0] := Integer(Self);
      Msg.Param[1] := Integer(OldField);
      Msg.Result := 0;
      Field.SendMapFieldMsg(Msg);
      if FArmy.FPlayer > 0 then AoWHSMap.UpdatePlayerSeen(FArmy.FPlayer, Field.Xhx,
        Field.Yhx, Field.Lhx, FArmy.VisibilityRange, FArmy.TrueVisionRange);
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
  FArmy.EndUpdate;
end;

function TArmyHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; { Near miss: field receiver spills or register choices after three variants. }
var Field: TMapField; Army: TEObject;
begin
  if FArmy.CanPlace(Xhx, Yhx, Lhx) then
  begin
    Field := Map.GetField(Xhx, Yhx, Lhx);
    Army := Field.FindOwnedChild($20217);
    if (Army = nil) or GetEditMode then Result := inherited PlaceHX(Map, Xhx, Yhx, Lhx)
    else Result := False;
  end
  else Result := False;
end;

function TArmyHS.PlacePrivate(Map: TMapContainer; X, Y, L: Shortint): Boolean;
begin
  Result := inherited PlaceHX(Map, X, Y, L);
  if Result then Activate;
end;

procedure TArmyHS.ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
var Sequence: TImageSequence; Part: Single; Xhp, Yhp, DX, DY, Frame: Integer;
begin
  if ((WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0) or (not AoWHSMap.FFogEnabled)) and
    not (asFullyConcealed in FArmy.FStatus) then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    X := Xhp - X;
    Y := Yhp - Y;
    if FMoveStep <> -1 then
    begin
      HNtoHP(FDirection, DX, DY);
      if FStatus and $10 = 0 then
      begin
        Part := FMoveStep / GetMoveSteps;
        Inc(X, Round(Part * DX));
        Inc(Y, Round(Part * DY));
      end;
    end;
    if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.GetImageSequence(27)
    else Sequence := FUnitGFXResource.FSequences.GetImageSequence(FDirection + 23);
    while Sequence <> nil do
    begin
      Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF); Sequence.ImageLibrary[Frame].Show(
        X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
  end;
end;

procedure TArmyHS.PlayMoveSFX;
var Sequence: TImageSequence; Frame: Integer;
begin
  if (FMoveStep <> -1) and (FStatus and 8 = 0) then
  begin
    if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[9]
    else Sequence := FUnitGFXResource.FSequences.List^[FDirection + 5];
    if Sequence <> nil then
    begin
      Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if Sequence.SpeedCount = Sequence.SequenceSpeed then
        FUnitGFXResource.FSFXLibraries[1].Play(Frame mod 100);
    end;
  end;
end;

procedure TArmyHS.ShowEnchantments(X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
var Info: TP2UnitShowInfo;
begin
  if FArmy.Count > FUnitIndex then
  begin
    Info.Overlays := [];
    Info.Animation := uaNone;
    Info.Frame := AoWHSMap.Frame + ((X + Y * 2) shr 4);
    Info.Looped := True;
    FArmy.GetUnit(FUnitIndex).ShowEx(X - 16, Y - 20, SurfaceDesc, Info);
  end;
end;

procedure TArmyHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc); { Near miss: Sequence/frame registers and flag evaluation differ after three variants. }
var Sequence: TImageSequence; Frame, Xhp, Yhp, DX, DY: Integer; Part: Real;
begin
  if (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0) or (not AoWHSMap.FFogEnabled) then
  begin














































    Assert(FDirection < FUnitGFXResource.FSequences.Count, 'Invalid Unit Index');
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    XhpSurf := Xhp - XhpSurf;
    YhpSurf := Yhp - YhpSurf;
    if FMoveStep <> -1 then
    begin
      HNtoHP(FDirection, DX, DY);
      if FStatus and $10 = 0 then
      begin
        Part := FMoveStep / FMoveSteps;
        Inc(XhpSurf, Round(Part * DX));
        Inc(YhpSurf, Round(Part * DY));
      end;
      if FStatus and 8 = 0 then
        if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[9]
        else Sequence := FUnitGFXResource.FSequences.List^[FDirection + 5]
      else
        if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[3]
        else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1];
    end
    else
    begin if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.List^[3] else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1]; end;
    if not (asConcealed in FArmy.FStatus) then
    begin
      if (msEditting in AoWHSMap.Status) or (AoWHSMap.FSeatedPlayer <> FArmy.FPlayer) or
        (FArmy.Count <> FArmy.ConcealedUnitsCount) then
      begin
        while Sequence <> nil do
        begin
          Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
        ShowEnchantments(XhpSurf, YhpSurf + FUnitYOffset, SurfaceDesc);
        if not (asSelected in FArmy.FStatus) or (AoWHSMap.Frame and 6 <> 6) then
          if FFlagID = $20 then AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
          else
          begin
            AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc);
            if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
          end;
      end
      else
      begin
        while Sequence <> nil do
        begin
          Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
          if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
            YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
          Sequence := Sequence.Next;
        end;
        ShowEnchantments(XhpSurf, YhpSurf + FUnitYOffset, SurfaceDesc);
        if asSelected in FArmy.FStatus then
        begin
          if AoWHSMap.Frame and 6 <> 6 then
            if FFlagID <> $20 then
            begin
              AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].ShowBlended(
                XhpSurf - 5, YhpSurf - 12, SurfaceDesc, AlphaBlendTable.LookupTables[50]);
              if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(
                XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
            end
            else AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].ShowBlended(XhpSurf - 5, YhpSurf - 12,
              SurfaceDesc, AlphaBlendTable.LookupTables[50]);
        end
        else if FFlagID <> $20 then
        begin
          AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count + 29].ShowBlended(
            XhpSurf - 5, YhpSurf - 12, SurfaceDesc, AlphaBlendTable.LookupTables[Abs((AoWHSMap.Frame shl 2) mod 60 - 30) + 40]);
          if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(
            XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
        end
        else AoWHSSet.FFlagControl.FFlags[FArmy.Count + 39].ShowBlended(XhpSurf - 5, YhpSurf - 12,
          SurfaceDesc, AlphaBlendTable.LookupTables[Abs((AoWHSMap.Frame shl 2) mod 60 - 30) + 40]);
      end;
    end
    else if not (asFullyConcealed in FArmy.FStatus) then
    begin
      while Sequence <> nil do
      begin
        Frame := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
        if Frame <> -1 then Sequence.ImageLibrary[Frame].Show(XhpSurf + Sequence.dXshift,
          YhpSurf + Sequence.dYshift + FUnitYOffset, SurfaceDesc);
        Sequence := Sequence.Next;
      end;
      if not (asSelected in FArmy.FStatus) or (AoWHSMap.Frame and 6 <> 6) then
        if FFlagID = $20 then AoWHSSet.FFlagControl.FFlags[FArmy.Count - FArmy.ConcealedUnitsCount + 39].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc)
        else
        begin
          AoWHSSet.FRaceResources.GetRaceResource(FFlagID).FImageLibrary[FArmy.Count - FArmy.ConcealedUnitsCount + 29].Show(XhpSurf - 5, YhpSurf - 12, SurfaceDesc);
          if asShowCrown in FArmy.FStatus then AoWHSSet.FFlagControl.FFlags[FFlagID + 80].Show(XhpSurf - 5, YhpSurf - 14, SurfaceDesc);
        end;
    end;
  end;
end;


procedure TArmyHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID and $40000000 = 0) and (FArmy <> nil) then FArmy.MsgProc(Msg, Sender);
  if Msg.MsgID = $20020005 then UpdateFlagID;
end;

procedure TArmyHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg); { Near miss: message ID reloads after three variants. }
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.HN = 0 then
    if Msg.MsgID = $110C then
    begin
      if not (asFullyConcealed in FArmy.FStatus) and ((not AoWHSMap.FFogEnabled) or
        (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo <> 0)) then
        if FArmy.FPlayer <> 0 then
          Msg.Param[0] := Msg.Param[0] or (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FPlayerRace + 1)
        else Msg.Param[0] := Msg.Param[0] or $D;
    end
    else if Msg.MsgID = $1200 then
    begin
      FArmy.UpdateAITarget(TAITargetInfo(Pointer(Msg.Param[0])^), TAITargetData(Pointer(Msg.Param[1])^));
      if TAITargetData(Pointer(Msg.Param[1])^).Priority < 0 then Msg.Result := 1;
    end
    else if Msg.MsgID = $1108 then FArmy.ReturnBattleFieldInfo(TBattleFieldInfo(Pointer(Msg.Param[0])^))
    else if Msg.MsgID = $1101 then Msg.Param[1] := Ord(FArmy.GetMoveAction(Msg.Param[0]))
    else if Msg.MsgID = $1100 then Msg.Result := FArmy.FPlayer
    else if Msg.MsgID = $1125 then
    begin
      if FArmy.FPlayer = 0 then Msg.Result := FArmy.FIndependentRelation;
    end
    else if Msg.MsgID = $1130 then
    begin
      if Msg.Param[1] = 1 then Msg.Result := FArmy.FPlayer
      else if FArmy.FConcealedUnits <> ArmySelectionMasks[FArmy.FChildren.Count] then Msg.Result := FArmy.FPlayer;
    end
    else if Msg.MsgID = $110A then
    begin
      if (FArmy.FPlayer = Msg.Param[1]) or
        (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
        if Msg.Param[0] <= FArmy.VisibilityRange then Msg.Result := 1;
    end
    else if Msg.MsgID = $110B then
    begin
      if (FArmy.FPlayer = Msg.Param[1]) or
        (AoWHSMap.FPlayers.GetPlayers(FArmy.FPlayer).FDiplomaticRelations.GetDiplomaticRelation(Msg.Param[1]) = drAlliance) then
        if Msg.Param[0] <= FArmy.TrueVisionRange then Msg.Result := 1;
    end
    else if Msg.MsgID = $110D then
    begin
      if Msg.Param[0] <= 8 then FArmy.UpdateConcealment;
      if (FArmy.FPlayer > 0) and (Msg.Param[0] <= FArmy.VisibilityRange) then
        AoWHSMap.UpdatePlayerSeen(FArmy.FPlayer, Msg.MapField.Xhx, Msg.MapField.Yhx, Msg.MapField.Lhx,
          Msg.Param[0], FArmy.TrueVisionRange);
    end
    else if Msg.MsgID = $110E then
    begin
      if FArmy.IncommingNegotiateRequest(TNegotiateRequestEventLog(Msg.Param[0])) then Msg.Param[1] := 1;
    end
    else if Msg.MsgID = $110F then
    begin
      if FArmy.IncommingNegotiateOffer(TNegotiateTE(Msg.Param[0])) then Msg.Result := 1;
    end
    else if (Msg.MsgID = $1150) and not TAoWMapField(Msg.MapField).GetMagicShieldActive then
    begin
      FArmy.IncommingStorm(TStormType(Msg.Param[0]), Msg.Param[1], Msg.Param[2]);
      Exit;
    end
    else if (Msg.MsgID = $1151) and not TAoWMapField(Msg.MapField).GetMagicShieldActive then
    begin
      FArmy.RetrieveStormDamageInfo(TStormType(Msg.Param[0]), Msg.Param[1], TStormDamageInfo(Pointer(Msg.Param[2])^));
      Exit;
    end
    else if Msg.MsgID = $1105 then FArmy.TriggerFireDamage;
end;

function TArmyHS.PlaceEx(X, Y, L: Shortint; Mode: TArmyPlaceMode): Boolean;
var Level: TMapLevel; Field: TAoWMapField; Msg: TMapFieldMsg; Walk: THNWalkData; Player: Integer;
begin
  Result := False;
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while not Result and ((Walk.Radius = 0) or (apScanArea in Mode)) and (Walk.Radius < 30) do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
      if Field.FindOwnedChild($20217) = nil then begin Player := Field.GetPlayer;
        if (Player = -1) or ((Player = Integer(FArmy.FPlayer)) and (apEnableOwnPlayerLocation in Mode)) then
        begin
          Msg.MsgID := $1120;
          Msg.Param[0] := Integer(Self);
          Msg.Result := 0;
          Field.SendMapFieldMsg(Msg);
          if Msg.Result = 0 then
            if FArmy.CanPlace(Walk.X, Walk.Y, L) then
            begin MoveTo(Field, 0); Result := True; end;
        end; end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TArmyHS.MoveFirst(Direction: Integer; Instant: Boolean): Shortint; { Near miss: Instant parameter spill differs after three variants. }
var Level: TMapLevel; X, Y, DX, DY: Integer; Animation: TImageSequenceAnimation;
begin
  Result := inherited MoveFirst(Direction, Instant);
  case AoWEngine.FRegistry.GetMovementSpeed of
    mmsNormal: FMoveSteps := inherited GetMoveSteps;
    mmsFast:
      begin
        FMoveSteps := inherited GetMoveSteps;
        if FMoveSteps < 9 then FMoveSteps := 4 else Dec(FMoveSteps, 4);
      end;
    mmsTurbo: FMoveSteps := 2;
  end;
  if AoWHSMap.FFPS > 0 then
  begin
    if AoWHSMap.FFPS < 15 then FMoveSteps := FMoveSteps div 2
    else if AoWHSMap.FFPS < 25 then Dec(FMoveSteps, 2);
    if FMoveSteps < 2 then FMoveSteps := 2;
  end;
  if GetLhx > 0 then
  begin
    Level := TMapLevel(Owner.Owner);
    CenterHNtoHX(GetXhx, GetYhx, Direction, X, Y);
    if (X >= 0) and (Y >= 0) and (X < Level.Width) and (Y < Level.Height) then
      if Level.GetField(X, Y).TerrainType = 7 then
        if AoWHSSet.FAbilityControl.GetAbility(42).FImageSequences.GetImageSequence(0) <> nil then
        begin
          Animation := TImageSequenceAnimation.Create(nil);
          Animation.SetImageSequence(AoWHSSet.FAbilityControl.GetAbility(42).FImageSequences.GetImageSequence(0));
          Animation.FAnimationLevel := 27;
          HNtoHP(Direction, DX, DY);
          Animation.SetXhpOffset(DX div 2);
          Animation.SetYhpOffset(DY div 2);
          AoWHSMap.PlaceHX(Animation, GetXhx, GetYhx, GetLhx);
        end;
  end;
end;

function TArmyHS.GetMoveSteps: Integer;
begin
  if Moving then
  begin Result := FMoveSteps; Exit; end;
  Result := inherited GetMoveSteps;
end;

function TArmyHSList.GetArmyHS(Index: Integer): TArmyHS;
begin
  Result := TArmyHS(FChildren.List^[Index]);
end;

constructor TSelectedArmy.Create;
begin
  inherited Create;
  FSelectedUnitGFX := TIntegerList.Create;
end;

destructor TSelectedArmy.Destroy;
begin
  ResetSelectedUnitGFX;
  FSelectedUnitGFX.Free;
  inherited Destroy;
end;

procedure TSelectedArmy.SetCurrentMove(A1: Integer);
begin
  if (FCurrentMove <> -1) and (GetArmyHS <> nil) then
    AoWHSMap.Selection.TriggerDeselectEvent(GetArmyHS);
  FCurrentMove := A1;
  if (FCurrentMove <> -1) and (GetArmyHS <> nil) then
    AoWHSMap.Selection.TriggerSelectEvent(GetArmyHS);
  UpdateSelectedUnitGFX;
end;

function TSelectedArmy.AddMoveArmy(ArmyHS: TArmyHS; Selection: Byte): Integer;
var Index: Integer;
begin
  Index := AddMoveObject(ArmyHS);
  FMoveSettingsList.GetMoveSettings(Index).FSelection := Selection;
  FMoveSettingsList.GetMoveSettings(Index).FMovePoints := ArmyHS.FArmy.MovePoints(Selection);
  FMoveSettingsList.GetMoveSettings(Index).FMoves := ArmyHS.FArmy.Moves(Selection);
  Result := Index;
end;

function TSelectedArmy.GetArmyHS: TArmyHS;
begin
  if FCurrentMove <> -1 then
    Result := TArmyHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject)
  else Result := nil;
end;

function TSelectedArmy.GetSelection: Byte;
begin
  if FCurrentMove <> -1 then
    Result := FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection
  else Result := 0;
end;

procedure TSelectedArmy.SetSelection(Selection: Byte);
var Points, Moves: Integer;
begin
  if FCurrentMove <> -1 then
  begin
    Selection := GetArmyHS.FArmy.ValidateMoveSelection(Selection);
    if FMode = samBuildRoads then
      Selection := Selection or (1 shl GetArmyHS.FArmy.IndexOfID(FRoadBuilderID));
    if Selection <> 0 then
    begin
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection := Selection;
      Points := GetArmyHS.FArmy.MovePoints(Selection);
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FMovePoints := Points;
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoves := GetArmyHS.FArmy.Moves(Selection);
      { Store the signed move count directly. }
    end;
    Update;
  end;
end;

function TSelectedArmy.GetMoveTypes: TMoveTypes;
begin
  if FCurrentMove <> -1 then
    Result := TArmyHS(FMoveSettingsList.GetMoveSettings(FCurrentMove).FMoveObject).FArmy.MoveTypes(
      FMoveSettingsList.GetMoveSettings(FCurrentMove).FSelection)
  else Result := [];
end;

procedure TSelectedArmy.ShowMovePaths(const Surface: TSurfaceDesc);
begin
  if Self = AoWHSMap.Mouse.Capture then inherited ShowMovePaths(Surface);
end;

procedure TSelectedArmy.ResetSelectedUnitGFX;
var I: Integer;
begin
  for I := FSelectedUnitGFX.Count - 1 downto 0 do
  begin
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FSelectedUnitGFX[I]).Release;
    FSelectedUnitGFX.Delete(I);
  end;
end;

procedure TSelectedArmy.UpdateSelectedUnitGFX;
var I, Index: Integer; List: TIntegerList;
begin
  List := TIntegerList.Create;
  if GetArmyHS <> nil then
    for I := 0 to GetArmyHS.FArmy.Count - 1 do
    begin
      Index := GetArmyHS.FArmy.GetUnit(I).GetUnitGFXResourceIndex;
      List.Add(Index);
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).AddRef;
    end;
  ResetSelectedUnitGFX;
  FSelectedUnitGFX.Assign(List);
  List.Free;
end;

procedure TSelectedArmy.OnDestroyArmy(Sender: TObject);
var Index: Integer;
begin
  if mssActivated in FStatus then
    if Sender <> nil then
    begin
      Index := FMoveSettingsList.IndexOfMoveObject(TArmy(Sender).GetArmyHS);
      if Index <> -1 then DeleteMoveObject(Index);
    end
    else Deactivate;
end;

procedure TSelectedArmy.RectangleSelectEvent(Sender: TObject);
var
  X1, Y1, X2, Y2, Xhp, Yhp: Integer;
  X, Y: Integer;
  Armies: TArmyHSList;
  I: Integer;
  R: TRect;
  Level: TMapLevel;
  ArmyHS: TArmyHS;
begin
  Armies := TArmyHSList.Create(nil);
  R := TAbstractAoWHSMapMouse(Sender).FSelectionRectangle;
  Level := AoWHSMap.MapContainer.GetMapLevel(AoWHSMap.ViewL);
  HPtoHX(R.Left, R.Top, X1, Y1);
  HPtoHX(R.Right, R.Bottom, X2, Y2);
  for X := X1 - 1 to X2 + 1 do
    for Y := Y1 - 1 to Y2 + 1 do
    begin
      HXtoHP(X, Y, Xhp, Yhp);
      Inc(Xhp, 16);
      Inc(Yhp, 16);
      if (X >= 0) and (X < Level.Width) and (Y > 0) and (Y < Level.Height) and
        (Xhp >= R.Left) and (Xhp < R.Right) and
        (Yhp >= R.Top) and (Yhp < R.Bottom) then
      begin
        ArmyHS := TAoWMapField(Level.GetField(X, Y)).GetArmyHS;
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
          Armies.AddChild(ArmyHS);
      end;
    end;
  if Armies.Count <> 0 then
  begin
    Clear;
    AoWHSMap.Selection.UnselectLocation;
    for I := 0 to Armies.Count - 1 do
    begin
      AddMoveArmy(Armies.GetArmyHS(I), $FF);
      AoWHSMap.Selection.SelectLocationHS(Armies.GetArmyHS(I));
    end;
    if Armies.Count = 1 then SetCurrentMove(0)
    else SetCurrentMove(-1);
    Update;
  end;
  Armies.Free;
end;

function TSelectedArmy.ValidMultiMoveSelection(Field: TAoWMapField): Boolean;
var Player: Shortint; Valid: Boolean; ArmyHS: TArmyHS;
begin
  Player := Field.GetPlayer;
  Valid := (Player = -1) or (Player = AoWHSMap.FSeatedPlayer);
  ArmyHS := Field.GetArmyHS;
  if ArmyHS <> nil then Valid := Valid and (ArmyHS.FArmy.Transporter($FF) = nil);
  Valid := Valid and (FMode <> samBuildRoads);
  Result := Valid;
end;

function TSelectedArmy.ValidateSelection(Field: TAoWMapField): Boolean;
begin
  if FMoveSettingsList.Count > 1 then Result := ValidMultiMoveSelection(Field)
  else Result := inherited ValidateSelection(Field);
  if FMode = samBuildRoads then
    if (Field.GetPlayer <> -1) and
      (Field.GetPlayer <> GetArmyHS.FArmy.FPlayer) then Result := False;
end;

procedure TSelectedArmy.CalculateMovePath(Index: Integer; X, Y, L: Shortint);
var
  Settings: TMoveSettings;
  ArmyHS: TArmyHS;
begin
  if X <> -1 then
  begin
    Settings := FMoveSettingsList.GetMoveSettings(Index);
    ArmyHS := TArmyHS(Settings.FMoveObject);
    Settings.FPathMovePoints := 0;
    FMoveControlSettings.Reset;
    FMoveControlSettings.SetSourcePos(ArmyHS.GetXhx, ArmyHS.GetYhx, ArmyHS.GetLhx);
    FMoveControlSettings.FPlayer := ArmyHS.FArmy.FPlayer;
    FMoveControlSettings.FArmyHS := ArmyHS;
    FMoveControlSettings.SetDestinationPos(X, Y, L);
    FMoveControlSettings.FUnits.AddUnitsEx(ArmyHS.FArmy, Settings.FSelection);
    if AoWHSMap.FExplorationEnabled then
      FMoveControlSettings.FMode := FMoveControlSettings.FMode + [mmExploredTerrainOnly];
    ArmyHS.FArmy.CreateMovePointTable(Settings.FSelection, FMoveControlSettings.FMovePointTable);
    AoWHSMap.FMoveControl.ProcessMove(FMoveControlSettings);
    if FMoveControlSettings.FPath.Count <> 0 then
    begin
      Settings.FPath.Assign(FMoveControlSettings.FPath);
      Settings.FPathMovePoints := Settings.FPath.PosToMovePoints(0);
      ArmyHS.FArmy.SetDestinationPos(Settings.FPath[0].X, Settings.FPath[0].Y, Settings.FPath[0].L);
      FMoveControlSettings.FPath.Clear;
      if FMode = samBuildRoads then
        if Settings.FMovePoints < Settings.FPathMovePoints then
        begin
          Settings.FPath.Clear;
          AoWHSMap.ShowMessage(TranslateRStr(ArmyNotEnoughMovePointsRStr));
        end
        else if Settings.FPath.Count <> 0 then
          AoWHSMap.ShowMessage(Format(TranslateRStr(ArmyRoadConstructionCostRStr),
            [IntToStr(RoadConstructionCost(GetArmyHS.FArmy.FPlayer, Settings.FPath, Settings.FMovePoints))]));
    end
    else
    begin
      FMoveSettingsList.GetMoveSettings(Index).FPath.Clear;
      ArmyHS.FArmy.ResetDestinationPos;
    end;
  end;
end;

procedure TSelectedArmy.SelectPath(X, Y, L: Shortint); { Near miss: path pointer caching after three variants. }
var
  Valid: Boolean;
  I: Integer;
  Settings: TMoveSettings;
begin
  if (GetArmyHS <> nil) and (GetArmyHS.GetXhx = AoWHSMap.Mouse.Xhx) and
    (GetArmyHS.GetYhx = AoWHSMap.Mouse.Yhx) and
    (GetArmyHS.GetLhx = AoWHSMap.ViewL) then
    AoWHSMap.Selection.SelectLocationHX(GetArmyHS.GetXhx, GetArmyHS.GetYhx, GetArmyHS.GetLhx)
  else if (FMoveSettingsList.Count > 1) and (FCurrentMove = -1) then
  begin
    Valid := True;
    I := FMoveSettingsList.Count;
    while Valid and (I <> 0) do
    begin
      Dec(I);
      Settings := FMoveSettingsList.GetMoveSettings(I);
      with Settings do
        Valid := (FPath.Count <> 0) and (FPath[0].X = X) and
          (FPath[0].Y = Y) and (FPath[0].L = L);
    end;
    if not Valid then
    begin
      if ValidateSelection(TAoWMapField(FMap.MapContainer.GetField(X, Y, L))) then
        for I := 0 to FMoveSettingsList.Count - 1 do
          CalculateMovePath(I, X, Y, L)
      else
        for I := 0 to FMoveSettingsList.Count - 1 do
          FMoveSettingsList.GetMoveSettings(I).FPath.Clear;
    end
    else ExecuteMove;
  end
  else inherited SelectPath(X, Y, L);
end;

procedure TSelectedArmy.Unselect;
begin
  inherited Unselect;
  Select(nil);
end;

procedure TSelectedArmy.MouseDownEvent(Sender: TObject);
var
  ArmyHS: TArmyHS;
  Index: Integer;
begin
  if not FIgnoreMouseDown then
    if ssShift in AoWHSMap.Mouse.Shift then
    begin
      if (FMoveSettingsList.Count = 1) and
        (FMoveSettingsList.GetMoveSettings(0).FPath.Count <> 0) then
        if not ValidMultiMoveSelection(TAoWMapField(FMap.MapContainer.GetField(
          FMoveSettingsList.GetMoveSettings(0).FPath[0].X,
          FMoveSettingsList.GetMoveSettings(0).FPath[0].Y,
          FMoveSettingsList.GetMoveSettings(0).FPath[0].L))) then Exit;
      if AoWHSMap.Mouse.Xhx <> -1 then
      begin
        ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
          AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL).FindOwnedChild($20217));
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
        begin
          Index := FMoveSettingsList.IndexOfMoveObject(ArmyHS);
          if Index = -1 then
          begin
            AddMoveArmy(ArmyHS, $FF);
            Update;
            AoWHSMap.Selection.SelectLocationHS(ArmyHS);
            SetCurrentMove(-1);
          end
          else
          begin
            ArmyHS.Unselect;
            DeleteMoveObject(Index);
            if FMoveSettingsList.Count = 1 then SetCurrentMove(0);
          end;
        end;
      end;
    end
    else if ssCtrl in AoWHSMap.Mouse.Shift then
    begin
      if (FMoveSettingsList.Count > 1) and (AoWHSMap.Mouse.Xhx <> -1) then
      begin
        ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
          AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL).FindOwnedChild($20217));
        if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
        begin
          Index := FMoveSettingsList.IndexOfMoveObject(ArmyHS);
          if Index <> -1 then
            if Index <> FCurrentMove then
            begin
              SetCurrentMove(Index);
              Update;
            end
            else SetCurrentMove(-1);
        end;
      end;
    end
    else
    begin
      if (AoWHSMap.Mouse.Capture <> AoWHSMap.FTargetSelection) and
        ((AoWHSMap.Mouse.Capture <> Self) or (FMap.Mouse.Button = mbRight)) then
        Unselect
      else if (AoWHSMap.Mouse.Capture = Self) and (AoWHSMap.Mouse.Button = mbLeft) then
        SelectPath(FMap.Mouse.Xhx, FMap.Mouse.Yhx, FMap.ViewL);
    end
  else FIgnoreMouseDown := False;
end;

procedure TSelectedArmy.ExecuteMove;
var
  I: Integer;
  ArmyHS: TArmyHS;
  Field: TAoWMapField;
  Cost: Integer;
begin
  if FMoveSettingsList.Count = 1 then
  begin
    with FMoveSettingsList.GetMoveSettings(FCurrentMove) do
    if (FPath.Count > 1) and (GetArmyHS <> nil) then
    begin
      ArmyHS := GetArmyHS;
      Field := TAoWMapField(AoWHSMap.MapContainer.GetField(FPath[0].X,
        FPath[0].Y, FPath[0].L));
      if (Field.GetMoveAction(ArmyHS.FArmy.FPlayer) <> maAttack) or (Field.GetPlayer <= 0) or
        (AoWHSMap.FPlayers.GetDiplomaticRelation(ArmyHS.FArmy.FPlayer, Field.GetPlayer) in [drWar, drUnknown]) then
      begin
        if FMode = samBuildRoads then
        begin
          Cost := RoadConstructionCost(ArmyHS.FArmy.FPlayer, FPath, FMovePoints);
          if Cost <= AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer).FGems then
          begin
            if MoveArmyEx(ArmyHS, GetSelection, FPath, [mmSelectEndLocation, mmBuildRoads], False) then
            begin
              FPath.Clear;
              if msEditting in AoWHSMap.Status then AoWHSMap.Selection.UnselectLocation;
              DeactivateMoveSelection;
            end;
          end
          else AoWHSMap.ShowWarning(TranslateRStr(NotEnoughGoldRStr));
        end
        else
        begin
          ArmyHS.FArmy.SetDestinationPos(FPath[0].X, FPath[0].Y, FPath[0].L);
          if MoveArmy(ArmyHS, GetSelection, FPath) then
          begin
            if FPath.MovePointsToPos(ArmyHS.FArmy.MovePoints($FF)) > 0 then
              with ArmyHS.FArmy do FUserMode := FUserMode + [aumTurnDone];
            FPath.Clear;
            if msEditting in AoWHSMap.Status then AoWHSMap.Selection.UnselectLocation;
            DeactivateMoveSelection;
          end;
        end;
      end
      else if (PByteArray(Field)^[26] <> 0) or (not AoWHSMap.FFogEnabled) then
        AoWHSMap.ShowMessage(Format(TranslateRStr(ArmyNotAtWarRStr),
          [TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerRace])]));
    end;
  end
  else if (FMoveSettingsList.Count > 1) and ExecuteMultiArmyMove(FMoveSettingsList) then
  begin
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      with FMoveSettingsList.GetMoveSettings(I) do
      begin
        TArmyHS(FMoveObject).FArmy.SetDestinationPos(FPath[0].X, FPath[0].Y, FPath[0].L);
        FPath.Clear;
      end;
    end;
    Deactivate;
    AoWHSMap.Selection.UnselectLocation;
    Clear;
  end;
end;

procedure TSelectedArmy.UpdateMoveCursor;
var Field: TAoWMapField; Cost: Integer;
begin
  if (AoWHSMap.Mouse.Xhx <> -1) and (AoWHSMap.Mouse.Yhx <> -1) and
    (AoWHSMap.Mouse.Capture = Self) then
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(AoWHSMap.Mouse.Xhx,
      AoWHSMap.Mouse.Yhx, AoWHSMap.ViewL));
    if (FCurrentMove <> -1) and
      (not AoWHSMap.FExplorationEnabled or Field.GetExplored(AoWHSMap.FSeatedPlayer)) and
      ((not AoWHSMap.FFogEnabled) or (PByteArray(Field)^[26] <> 0)) then
      case Field.GetMoveAction(GetArmyHS.FArmy.FPlayer) of
        maAttack: AoWHSMap.Mouse.CursorMode := $102;
        maNegotiate: AoWHSMap.Mouse.CursorMode := $103;
      else
        AoWHSMap.Mouse.CursorMode := $100;
      end
    else if FMoveSettingsList.Count <= 1 then AoWHSMap.Mouse.CursorMode := $100
    else AoWHSMap.Mouse.CursorMode := 0;
    if AoWHSMap.Mouse.CursorMode = $100 then
    begin
      if mtWalking in GetMoveTypes then AoWHSMap.Mouse.Cursor := $40
      else if mtSwimming in GetMoveTypes then AoWHSMap.Mouse.Cursor := $42
      else if mtFlying in GetMoveTypes then AoWHSMap.Mouse.Cursor := $44;
      Cost := FMoveControlSettings.FMovePointTable[Field.TerrainType, Field.OverlayType];
      if (Cost = 0) or (AoWHSMap.FExplorationEnabled and
        not Field.GetExplored(AoWHSMap.FSeatedPlayer)) then
        with AoWHSMap.Mouse do Cursor := Cursor or 1;
    end;
  end;
end;

procedure TSelectedArmy.ActivateMoveSelection;
begin
  Activate(AoWHSMap);
end;

procedure TSelectedArmy.Deactivate;
begin
  inherited Deactivate;
  FMode := samDefault;
end;

procedure TSelectedArmy.DeactivateMoveSelection;
begin
  Deactivate;
end;

procedure TSelectedArmy.Update;
var
  Selection: Byte;
  Field: TMapField;

  I: Integer;
  ArmyHS: TArmyHS;

begin
  UpdateSelectedUnitGFX;
  if GetArmyHS <> nil then
    GetArmyHS.FArmy.CreateMovePointTable(GetSelection, FMoveControlSettings.FMovePointTable);
  for I := 0 to FMoveSettingsList.Count - 1 do
  begin
    Selection := FMoveSettingsList.GetMoveSettings(I).FSelection;
    ArmyHS := TArmyHS(FMoveSettingsList.GetMoveSettings(I).FMoveObject);
    FMoveSettingsList.GetMoveSettings(I).FMovePoints :=
      ArmyHS.FArmy.MovePoints(Selection);
    FMoveSettingsList.GetMoveSettings(I).FMoves :=
      ArmyHS.FArmy.Moves(Selection);
  end;
  if mssActivated in FStatus then
    for I := 0 to FMoveSettingsList.Count - 1 do
    begin
      ArmyHS := TArmyHS(FMoveSettingsList.GetMoveSettings(I).FMoveObject);
      if ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer then
        if (ArmyHS.FArmy.FDestinationX <> -1) and (ArmyHS.FArmy.FDestinationX <> 0) then
        begin
          with ArmyHS.FArmy do
          begin
            Field := AoWHSMap.MapContainer.GetField(FDestinationX, FDestinationY, FDestinationL);
            if Self.ValidateSelection(TAoWMapField(Field)) then
              CalculateMovePath(I, FDestinationX, FDestinationY, FDestinationL)
            else ArmyHS.FArmy.ResetDestinationPos;
          end;
        end
        else if FMoveSettingsList.GetMoveSettings(I).FPath.Count <> 0 then
        begin
          with FMoveSettingsList.GetMoveSettings(I).FPath[0] do
            CalculateMovePath(I, X, Y, L);
        end;
    end;
  UpdateMoveCursor;
end;

procedure TSelectedArmy.OutputGroupInfo;
var
  Text: string;
  I: Integer;
  Group: TAIGroup;
begin
  Text := '';
  for I := 0 to GetArmyHS.FArmy.Count - 1 do
  begin
    Text := GetArmyHS.FArmy.GetUnit(I).GetName + '(ID:' +
      IntToStr(GetArmyHS.FArmy.GetUnit(I).FUnitID) + ')';
    Group := GetArmyHS.FArmy.GetUnit(I).FGroup;
    if Group <> nil then
    begin
      Text := Text + TGroupBehaviorStr[Group.Behavior] + '(GID:' + IntToStr(Group.FGroupID) +
        '/Target:' + IntToStr(Group.FTargetXYL.X) + ',' + IntToStr(Group.FTargetXYL.Y) +
        ',' + IntToStr(Group.FTargetXYL.L) + '/Budget:' + IntToStr(Group.FGoldBudget) +
        '/MP:' + IntToStr(Group.FTargetMovePoints) + ')';
      if Group.FTargetType = gtsSetup then Text := Text + '-setup'
      else if Group.FTargetType = gtsExecute then Text := Text + '-execute';
      if Group.FLeader = GetArmyHS.FArmy.GetUnit(I) then Text := Text + '/Leader';
    end;
    AoWEngine.OutputDebugStr(Text);
  end;
  AoWEngine.OutputDebugStr('Army strength: ' + IntToStr(GetArmyHS.FArmy.GetStrengthMax(dtAll - [dtNone])));
end;

procedure TSelectedArmy.SetArmyHS(ArmyHS: TArmyHS);
begin
  if (ArmyHS <> GetArmyHS) and not (msEditting in AoWHSMap.Status) and
    (FMoveSettingsList.Count <= 1) then
  begin
    Clear;
    FIgnoreMouseDown := False;
    FMode := samDefault;
    if ArmyHS <> nil then
    begin
      if ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer then ActivateMoveSelection;
      AddMoveArmy(ArmyHS, $FF);
      FCurrentMove := 0;
      Update;
    end
    else
    begin
      DeactivateMoveSelection;
      ResetSelectedUnitGFX;
    end;
    if (GetArmyHS <> nil) and AoWEngine.FRegistry.GetDebugMode then OutputGroupInfo;
  end;
end;

procedure TSelectedArmy.Select(ArmyHS: TArmyHS);
begin
  AoWHSMap.Selection.UnselectLocation;
  if ArmyHS <> nil then AoWHSMap.Selection.SelectLocationHS(ArmyHS);
end;

procedure TSelectedArmy.SelectBuildRoad(AUnit: TAbstractUnit);
var Army: TECustomNode; ArmyHS: TArmyHS;
begin
  Army := AUnit.Owner;
  if Army is TArmy then
  begin
    ArmyHS := TArmy(Army).GetArmyHS;
    ArmyHS.FArmy.ResetDestinationPos;
    if ArmyHS <> GetArmyHS then
    begin
      AoWHSMap.Selection.UnselectLocation;
      AoWHSMap.Selection.SelectLocationHS(ArmyHS);
      SetSelection($FF);
    end
    else
    begin
      DeleteMoves;
      AddMoveArmy(ArmyHS, $FF);
      FCurrentMove := 0;
    end;
    AoWHSMap.ShowMessage(TranslateRStr(SelectRoadConstructionPathRStr));
    FRoadBuilderID := AUnit.FUnitID;
    FMode := samBuildRoads;
  end;
end;

procedure TSelectedArmy.Center;
begin
  if GetArmyHS <> nil then
    with AoWHSMap do
      CenterViewTo(GetArmyHS.GetXhx, GetArmyHS.GetYhx, GetArmyHS.GetLhx);
end;

procedure TSelectedArmy.TurnDone;
begin
  if (GetArmyHS <> nil) and (GetArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    GetArmyHS.FArmy.FUserMode := GetArmyHS.FArmy.FUserMode + [aumTurnDone];
    AoWHSMap.SelectNextArmy;
  end;
end;

procedure TSelectedArmy.ToggleGuard; { Near miss: guard field fixed; set/register form differs after three variants. }
var ArmyHS: TArmyHS; Army: TArmy;
begin
  ArmyHS := GetArmyHS;
  if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    Army := ArmyHS.FArmy;
    if aumGuard in ArmyHS.FArmy.FUserMode then
    begin
      Army.FUserMode := ArmyHS.FArmy.FUserMode - [aumGuard];
      Army.Update;
    end
    else
    begin
      Army.FUserMode := ArmyHS.FArmy.FUserMode + [aumGuard];
      AoWHSMap.SelectNextArmy;
    end;
  end;
end;

class function TItemTE.ClassID: Integer;
begin Result := $20272; end;

procedure TItemTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FItemID, $14);
  Stream.rwData(FAction, 1, $15);
  Stream.rwInteger(FHeroID, $16);
end;

function TItemTE.Execute(TE: TTokenExecuter): TExecuteResult;
var Done: Boolean; Item: TItem; Hero: THero;
begin
  inherited Execute(TE);
  Done := False;
  Item := AoWHSMap.FItemControl.FindItem(FItemID);
  if Item <> nil then
    case FAction of
      0:
      begin
        Hero := AoWHSMap.FHeroControl.FindID(FHeroID);
        if Hero <> nil then Done := Item.ExecuteUse(Hero)
        else Done := False;
      end;
    end;
  if Done then Result := erDone else Result := erDoneHalt;
end;

constructor TItem.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FItemGFXIndex := -1;
  FDescription := TStringList.Create;
  FLibraryID := -1;
  FRefCount := 1;
end;

destructor TItem.Destroy;
begin
  AddRef;
  if isActivated in FStatus then Deactivate;
  if isRegistered in FStatus then AoWHSMap.FItemControl.UnRegisterItem(Self);
  FDescription.Free;
  inherited Destroy;
end;

function TItem.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TItem.Release: Integer;
var Count: Integer;
begin
  Dec(FRefCount);
  Count := FRefCount;
  Result := Count;
  if Count = 0 then Destroy;
end;

procedure TItem.SetOwner(AOwner: TECustomNode);
begin
  if AOwner <> FOwner then
  begin
    AddRef;
    if FOwner <> nil then FOwner.RemoveChild(Self);
    FOwner := AOwner;
    if FOwner <> nil then
      if FOwner.AddChild(Self) = -1 then FOwner := nil;
    Changed;
    Release;
  end;
end;

function TItem.ExecuteUse(Hero: THero): Boolean;
var Reason: string;
begin
  Result := True; { Original reports success even when CanUse rejects the item. }
  if CanUse(Hero, Reason) then
    case FItemType of
      itScroll:
      begin
        AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.ExecuteSpellResearched(FSpellID);
        if AoWHSMap.FSeatedPlayer = Hero.FPlayer then
        begin
          PlaySample('SFX\ATTACK\MAGICB01.WAV');
          AoWHSMap.ShowMessage(Format(TranslateRStr(ItemSpellResearchedRStr),
            [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]));
        end;
        Destroy;
        Hero.Changed;
      end;
    end;
end;

function TItem.CanUse(Hero: THero; var Reason: string): Boolean;
begin
  if (FItemType = itScroll) and (FSpellID <> 0) then
  begin
    if AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).FMagicControl.FSpells.IndexOf(FSpellID) = -1 then
      Result := True
    else
    begin
      Result := False;
      Reason := Format(TranslateRStr(ItemSpellAlreadyResearchedRStr),
        [AoWHSSet.FSpellControl.GetSpell(FSpellID).FSpellName]);
    end;
  end
  else
  begin
    Result := False;
    Reason := TranslateRStr(ItemNotUseableRStr);
  end;
end;

function TItem.Use(Hero: THero): Boolean;
var Reason: string; Event: TItemTE;
begin
  if CanUse(Hero, Reason) and not AoWHSMap.FPlayers.GetPlayers(Hero.FPlayer).GetBusy then
  begin
    Event := TItemTE.Create(nil);
    Event.FItemID := FItemID;
    Event.FHeroID := Hero.FUnitID;
    AoWHSMap.FTokenManager.GetTokenControl(Hero.FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TItem.SetArrayOwner(AOwner: TECustomNode; Index: Integer);
begin
  AddRef;
  inherited SetArrayOwner(AOwner, Index);
  if FOwner <> nil then AddRef;
  Changed;
  Release;
end;

procedure TItem.GetLocation(var X, Y, L: Shortint);
begin
  if (FOwner <> nil) and (FOwner is TItemList) then TItemList(FOwner).GetLocation(X, Y, L)
  else
  begin
    X := -1;
    Y := -1;
    L := -1;
  end;
end;

procedure TItem.Activate;
begin
  if not (isActivated in FStatus) then
  begin
    if (msEditting in AoWHSMap.Status) or (AoWHSMap.FDay = 0) then UpdateFromLibrary;
    FStatus := FStatus + [isActivated];
  end;
end;

procedure TItem.Deactivate;
begin
  if isActivated in FStatus then FStatus := FStatus - [isActivated];
end;

procedure TItem.Changed;
begin
  if isRegistered in FStatus then AoWHSMap.FItemControl.ItemChanged(Self);
end;

class function TItem.ClassID: Integer;
begin Result := $20268; end;

function TItem.GetCampaignTransferPoints: Integer;
begin Result := GetObtainValue; end;

function TItem.GetImage: TLibraryImage;
var GFX: TItemGFX;
begin
  GFX := AoWHSSet.FItemGFXResources.GetItemGFX(FItemGFXIndex);
  if GFX <> nil then
  begin
    GFX.AddRef;
    Result := GFX.GetItemImage;
    GFX.Release;
  end
  else Result := nil;
end;

function TItem.GetLibraryItem: Boolean;
begin Result := FLibraryID <> -1; end;

function TItem.GetLibraryName: string;
begin
  if FLibraryID <> -1 then
  begin
    Result := FLibraryName;
    if Result = '' then Result := TranslateRStr(ItemSystemLibraryRStr);
  end;
end;

procedure TItem.UpdateFromLibrary;
var ID: Integer; Item: TItem;
begin
  if FLibraryID <> -1 then
  begin
    Item := AoWHSSet.FItemLibraries.FindItem(FLibraryName, FLibraryID);
    if Item <> nil then
    begin
      ID := FItemID;
      Assign(Item, AoWEngine);
      FItemID := ID;
      Changed;
    end
    else if FOwner = nil then Free
    else FLibraryID := -1;
  end;
end;

function TItem.GetOwnerName: string;
begin Result := FOwnerName; end;

function TItem.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin
  case FItemType of
    itHead: Result := [astHeadItem];
    itTorso: Result := [astTorsoItem];
    itAttack: Result := [astAttackItem];
    itDefense: Result := [astDefenseItem];
    itRing: Result := [astRingItem];
    itUse: Result := [astUseItem];
  else Result := [];
  end;
end;

procedure TItem.SetItemGFXIndex(A1: Integer);
begin FItemGFXIndex := A1; end;

procedure TItem.Show(X, Y: Integer; const Surface: TSurfaceDesc);
var GFX: TItemGFX;
begin
  GFX := AoWHSSet.FItemGFXResources.GetItemGFX(FItemGFXIndex);
  if GFX <> nil then
  begin
    GFX.AddRef;
    GFX.GetItemImage.Show(X, Y, Surface);
    GFX.Release;
  end;
end;

procedure TItem.SetItemType(Value: TItemType);
var ItemType: TItemType;
begin
  FAttack := 0;
  FDefense := 0;
  FResistance := 0;
  FDamage := 0;
  ItemType := Value;
  FItemType := ItemType;
  FItemGFXIndex := AoWHSSet.FItemGFXResources.FindItemTypeGFX(ItemType);
  inherited Clear;
end;

function TItem.GetObtainValue: Integer;
begin
  if FObtainValue > 10 then Result := FObtainValue else Result := 10;
end;

procedure TItem.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smText in Stream.StorageMode) or not GetLibraryItem then
    Stream.rwInteger(FItemGFXIndex, 7);
  if not (smText in Stream.StorageMode) or (FOwner is TItemLibrary) or not GetLibraryItem then
    Stream.rwString(FOwnerName, 8);
  if not (smText in Stream.StorageMode) or not GetLibraryItem then
  begin
    Stream.rwString(FName, 9);
    Stream.rwData(FAvailability, 1, 10);
    Stream.rwByte(Byte(FAttack), 11);
    Stream.rwByte(Byte(FDefense), 12);
    Stream.rwByte(Byte(FDamage), 13);
    Stream.rwByte(Byte(FResistance), 14);
    Stream.rwData(FItemType, 1, 15);
    Stream.rwBool(FHidden, 16);
    Stream.rwInteger(FItemID, 17);
    Stream.rwStrings(FDescription, 18);
    Stream.rwInteger(FObtainValue, 19);
    Stream.rwInteger(FSpellID, 20);
    Stream.rwIntegerEx(FLibraryID, -1, 21);
    if not (smText in Stream.StorageMode) then Stream.rwString(FLibraryName, 22);
  end;
end;

function TItem.PlaceOnMap(Map: TAbstractAoWHSMap; X, Y, L: Shortint): Boolean;
var HS: TItemHS;
begin
  if (X >= 0) and (Y >= 0) and (L >= 0) and (X < Map.MapContainer.Width) and
    (Y < Map.MapContainer.Height) and (L < Map.MapContainer.LevelCount) and
    (Map.MapContainer.GetField(X, Y, L).TerrainType <> 15) then
  begin
    HS := TItemHS(Map.MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
    if HS = nil then
    begin
      HS := TItemHS.Create(nil);
      if not Map.PlaceHX(HS, X, Y, L) then
      begin
        HS.Free;
        HS := nil;
      end;
    end;
    if HS <> nil then
    begin
      SetOwner(HS.FItems);
      Result := True;
    end
    else Result := False;
  end
  else Result := False;
end;

procedure TItem.EditDropMsg(var Msg: TItemDropMsg);
var X, Y, L: Integer;
begin
  L := Msg.Lhp;
  HPtoHX(Msg.Xhp, Msg.Yhp, X, Y);
  if not PlaceOnMap(AoWHSMap, X, Y, L) then Msg.Result := -1
  else Msg.Result := 0;
end;

procedure TItem.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then EditDropMsg(TItemDropMsg(Msg));
end;

constructor TItemList.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); end;

function TItemList.RemoveChild(Child: TEObject): Integer;
begin
  Result := inherited RemoveChild(Child);
  if Result <> -1 then Child.Release;
end;

function TItemList.AddChild(Child: TEObject): Integer;
begin
  Result := inherited AddChild(Child);
  if Result <> -1 then Child.AddRef;
end;

procedure TItemList.DestroyAllChildren;
begin
  Clear;
  inherited DestroyAllChildren;
end;

procedure TItemList.MainReadWrite(Stream: TEStorageStream);
var I: Integer;
begin
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smText, smCompare] = [smRead] then
    for I := 0 to FChildren.Count - 1 do
      if FChildren.List^[I] <> nil then TEObject(FChildren.List^[I]).Release;
end;

procedure TItemList.Clear;
var I: Integer; Child: TEObject;
begin
  for I := Count - 1 downto 0 do
    if FChildren.List^[I] <> nil then
    begin
      Child := TEObject(FChildren.List^[I]);
      if Child <> nil then
        if Child.Owner <> Self then
        begin
          Child.Release;
          FChildren.Delete(I);
        end
        else Child.SetOwner(nil);
    end;
  inherited Clear;
end;

procedure TItemList.Changed;
begin
  inherited Changed;
  if Assigned(FOnChanged) then FOnChanged(Self);
end;

function TItemList.FindItem(ItemID: Integer): TItem;
var I: Integer; Item: TItem;
begin
  if Self <> nil then
  begin
    I := 0;
    Result := nil;
    while (I <> FChildren.Count) and (Result = nil) do
    begin
      Item := TItem(FChildren.List^[I]);
      if (Item <> nil) and (ItemID = Item.FItemID) then Result := Item;
      Inc(I);
    end;
  end
  else Result := nil;
end;

function TItemList.GetItem(Index: Integer): TItem;
begin
  if (Index >= 0) and (Index < Count) then Result := TItem(FChildren.List^[Index])
  else Result := nil;
end;

procedure TItemList.Update;
begin SortOnType; end;

procedure TItemList.GetLocation(var X, Y, L: Shortint);
begin X := -1; Y := -1; L := -1; end;

function CompareItemNames(Item1, Item2: Pointer): Integer;
begin
  if (Item1 <> nil) and (Item2 <> nil) then
  begin
    Result := CompareText(TItem(Item1).FOwnerName, TItem(Item2).FOwnerName);
    if Result = 0 then Result := Integer(Item1) - Integer(Item2);
  end
  else Result := 0;
end;

procedure TItemList.SortOnName;
begin FChildren.Sort(CompareItemNames); end;

function CompareItemTypes(Item1, Item2: Pointer): Integer;
begin
  { Original type comparison assumes both entries are non-nil. }
  Result := Ord(TItem(Item1).FItemType) - Ord(TItem(Item2).FItemType);
  if Result = 0 then Result := Integer(Item1) - Integer(Item2);
end;

procedure TItemList.SortOnType;
begin FChildren.Sort(CompareItemTypes); end;

procedure TItemList.RegisterItems;
var I: Integer; Item: TItem;
begin
  for I := FChildren.Count - 1 downto 0 do
  begin
    Item := TItem(FChildren.List^[I]);
    if (Item <> nil) and not (isRegistered in Item.FStatus) then
      AoWHSMap.FItemControl.RegisterItem(Item);
  end;
end;

procedure TItemList.LockChanged;
begin inherited LockChanged; end;

procedure TItemList.UnlockChanged;
begin inherited UnlockChanged; end;

constructor TItemControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TList.Create;
  FOnChanged := TEventList.Create;
  FOnItemChanged := TEventList.Create;
end;

destructor TItemControl.Destroy;
var I: Integer;
begin
  BeginUpdate;
  for I := FItems.Count - 1 downto 0 do UnRegisterItem(TItem(FItems.List^[I]));
  FItems.Clear;
  Changed;
  FItems.Free;
  FOnItemChanged.Free;
  FOnChanged.Free;
  inherited Destroy;
end;

procedure TItemControl.ReadWrite(Stream: Engine.TEStorageStream);
var ID, I: Integer; Item: TItem;
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FLastID, 9);
  if smCompare in Stream.StorageMode then
  begin
    ID := 10;
    for I := 0 to FItems.Count - 1 do
    begin
      Item := TItem(FItems[I]);
      if Item.Owner = nil then
      begin
        Stream.rwCreateEObject(TEObject(Item), nil, ID);
        Inc(ID);
      end;
    end;
  end
  else if Stream.StorageMode * [smTextOnly, smPreview, smCompare] = [] then
  begin
    if smRead in Stream.StorageMode then
    begin
      ID := 10;
      repeat
        Stream.rwCreateEObject(TEObject(Item), nil, ID);
        if Item <> nil then
        begin
          ValidateItem(Item);
          FItems.Add(Item);
          Item.FStatus := Item.FStatus + [isRegistered];
        end;
        Inc(ID);
      until Item = nil;
    end;
    if (smTextOnly in Stream.StorageMode) or (smWrite in Stream.StorageMode) then
    begin
      ID := 10;
      for I := 0 to FItems.Count - 1 do
        if TItem(FItems.List^[I]).Owner = nil then
        begin
          Stream.rwCreateEObject(TEObject(FItems.List^[I]), nil, ID);
          Inc(ID);
        end;
    end;
  end;
end;

function TItemControl.GetItem(Index: Integer): TItem;
begin
  Result := TItem(FItems.List^[Index]);
end;

function TItemControl.GetCount: Integer;
begin
  Result := FItems.Count;
end;

function TItemControl.FindItem(ItemID: Integer): TItem;
var I: Integer;
begin
  I := FItems.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TItem(FItems.List^[I]).FItemID = ItemID then
    begin
      Result := TItem(FItems.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TItemControl.ItemChanged(Item: TItem);
begin
  FOnItemChanged.TriggerNotifyEvents(Item);
end;

procedure TItemControl.Changed;
begin
  if FUpdateLock = 0 then FOnChanged.TriggerNotifyEvents(Self);
end;

procedure TItemControl.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TItemControl.EndUpdate;
begin
  Dec(FUpdateLock);
  if FUpdateLock = 0 then Changed;
end;

function TItemControl.CreateUniqueID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FLastID);
    if FLastID > $FFFFFFF then FLastID := 0;
    while (I <> FItems.Count) and (TItem(FItems.List^[I]).FItemID <> FLastID) do Inc(I);
  until I = FItems.Count;
  Result := FLastID;
end;

procedure TItemControl.ValidateItem(Item: TItem);
begin
  if FindItem(Item.FItemID) <> nil then Item.FItemID := CreateUniqueID;
end;

procedure TItemControl.UpdateLibraryItems;
var I: Integer;
begin
  BeginUpdate;
  for I := GetCount - 1 downto 0 do TItem(FItems.List^[I]).UpdateFromLibrary;
  EndUpdate;
end;

procedure TItemControl.RegisterItem(Item: TItem);
var Existing: TItem;
begin
  if not (isRegistered in Item.FStatus) then
  begin
    Existing := FindItem(Item.FItemID);
    if (Existing <> nil) and Existing.Compare(Item, AoWEngine) and
      (Existing.FRefCount = 1) then UnRegisterItem(Existing);
    ValidateItem(Item);
    Item.FStatus := Item.FStatus + [isRegistered];
    FItems.Add(Item);
    Item.AddRef;
    if (icsActivated in FStatus) and not (isActivated in Item.FStatus) then Item.Activate;
    Changed;
  end;
end;

procedure TItemControl.UnRegisterItem(Item: TItem);
begin
  if isRegistered in Item.FStatus then
  begin
    FItems.Remove(Item);
    Item.FStatus := Item.FStatus - [isRegistered];
    Item.Release;
    Changed;
  end;
end;

function TItemControl.GenerateItem(Types: TItemTypes; MinValue, MaxValue: Integer): TItem;
var List: TDoubleItemList; I, Value: Integer; Item: TItem;
begin
  List := TDoubleItemList.Create;
  for I := 0 to GetCount - 1 do
  begin
    Item := TItem(FItems.List^[I]);
    if (Item.FRefCount = 1) and (Item.FItemType in Types) then
    begin
      Value := Item.GetObtainValue;
      if (Value >= MinValue) and (Value <= MaxValue) then
        List.AddAB(Integer(Item), Ord(Item.FAvailability));
    end;
  end;
  if List.Count <> 0 then Result := TItem(List[List.RandomChanceItemB(1)].A)
  else Result := nil;
  List.Free;
end;

function TItemControl.GenerateItems(Types: TItemTypes; Owner: TECustomNode; Value: Integer): Integer;
var
  List: TDoubleItemList;
  I, Difference, Attempts, ItemValue, Distance: Integer;
  Done: Boolean;
  Item, Candidate: TItem;
begin
  Result := 0;
  List := TDoubleItemList.Create;
  for I := 0 to GetCount - 1 do
  begin
    Item := TItem(FItems.List^[I]);
    if (Item.FItemType in Types) and (Item.FRefCount = 1) then
      List.AddAB(Integer(Item), Ord(Item.FAvailability));
  end;
  Done := False;
  while not Done and (List.Count <> 0) do
  begin
    Candidate := TItem(List[List.RandomChanceItemB(1)].A);
    ItemValue := Candidate.GetObtainValue;
    if ItemValue > Value then
    begin
      Attempts := 10;
      Difference := Abs(ItemValue - Value);
      repeat
        Item := TItem(List[List.RandomChanceItemB(1)].A);
        Distance := Abs(Item.GetObtainValue - Value);
        if Distance < Difference then
        begin
          Difference := Distance;
          Candidate := Item;
        end;
        Dec(Attempts);
      until Attempts = 0;
      if Value < Difference then
      begin
        Candidate := nil;
        Done := True;
      end;
    end;
    if Candidate <> nil then
    begin
      Candidate.SetOwner(Owner);
      List.Delete(List.IndexOfItemA(Integer(Candidate)));
      Dec(Value, Candidate.GetObtainValue);
      Inc(Result);
    end;
  end;
  List.Free;
end;

procedure TItemControl.Activate;
var I: Integer;
begin
  if not (icsActivated in FStatus) then
  begin
    FStatus := FStatus + [icsActivated];
    for I := FItems.Count - 1 downto 0 do TItem(FItems.List^[I]).Activate;
  end;
end;

procedure TItemControl.Deactivate;
var I: Integer;
begin
  if icsActivated in FStatus then
  begin
    FStatus := FStatus - [icsActivated];
    for I := FItems.Count - 1 downto 0 do TItem(FItems.List^[I]).Deactivate;
  end;
end;

function TItemLibrary.CreateUniqueLibraryID: Integer;
var I: Integer;
begin
  repeat
    I := 0;
    Inc(FLastID);
    if FLastID > $FFFFFFF then FLastID := 0;
    while (I <> FChildren.Count) and (TItem(FChildren.List^[I]).FLibraryID <> FLastID) do Inc(I);
  until I = FChildren.Count;
  Result := FLastID;
end;

function TItemLibrary.AddChild(Child: Engine.TEObject): Integer;
begin
  with TItem(Child) do
    { Original checks the world item ID, not the library ID. }
    if (FLibraryID <= 0) or (FindItem(FLibraryID) <> nil) then FLibraryID := CreateUniqueLibraryID;
  Result := inherited AddChild(Child);
end;

function TItemLibrary.FindLibraryID(LibraryID: Integer): TItem;
var I: Integer;
begin
  I := FChildren.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TItem(FChildren.List^[I]).FLibraryID = LibraryID then
    begin
      Result := TItem(FChildren.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

procedure TItemLibrary.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 20);
  Stream.rwInteger(FLastID, 21);
end;

function TItemLibrary.GetName: string;
begin
  Result := FName;
  if Result = '' then Result := TranslateRStr(SystemItemLibraryRStr);
end;

function TItemLibrary.CreateItem: TItem;
var Item: TItem;
begin
  Item := TItem.Create(nil);
  Item.FLibraryID := CreateUniqueLibraryID;
  Item.FLibraryName := FName;
  Item.SetOwner(Self);
  Item.Release;
  Result := Item;
end;

procedure TItemLibrary.LoadFromFile(const FileName: string);
begin
  AoWEngine.ReadFromFile(FileName, Self, nil);
end;

procedure TItemLibrary.SaveToFile(const FileName: string);
begin
  AoWEngine.WriteToFile(FileName, Self, nil);
end;

constructor TItemLibraryManager.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSystemLibrary := TItemLibrary.Create(nil);
  FLibraries := TENode.Create(nil);
end;

destructor TItemLibraryManager.Destroy;
begin
  FLibraries.Free;
  FSystemLibrary.Free;
  inherited Destroy;
end;

procedure TItemLibraryManager.ReadWrite(Stream: Engine.TEStorageStream);
var Directory: string;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smTextOnly, smCompare] = [] then
  begin
    Directory := ExtractFilePath(AoWEngine.HSSFileName);
    if smRead in Stream.StorageMode then
    begin
      ReadUserLibraries;
      AoWEngine.ReadFromFile(Directory + 'ITEMS.PFS', FSystemLibrary, nil);
    end
    else
    begin
      AoWEngine.WriteToFile(Directory + 'ITEMS.PFS', FSystemLibrary, nil);
      WriteUserLibraries;
    end;
  end
  else Stream.rwEObject(FSystemLibrary, 20);
end;

function TItemLibraryManager.GetLibrary(Index: Integer): TItemLibrary;
begin
  Result := TItemLibrary(FLibraries.FChildren.EObjects[Index]);
end;

function TItemLibraryManager.GetCount: Integer;
begin
  Result := FLibraries.Count;
end;

procedure TItemLibraryManager.ReadUserLibraries;
var Search: TSearchRec; ItemLibrary: TItemLibrary; Found: Boolean;
begin
  FLibraries.Clear;
  FLibraries.AddChild(FSystemLibrary);
  Found := FindFirst(AoWEngine.StartupDirectory + 'User\' + '*' + '.ail',
    faAnyFile and not faDirectory, Search) = 0;
  while Found do
  begin
    ItemLibrary := TItemLibrary.Create(nil);
    try
      ItemLibrary.LoadFromFile(AoWEngine.StartupDirectory + 'User\' + Search.Name);
      ItemLibrary.SetOwner(FLibraries);
    except
      ItemLibrary.Free;
    end;
    Found := FindNext(Search) = 0;
  end;
  FindClose(Search);
end;

procedure TItemLibraryManager.WriteUserLibraries;
var I: Integer; ItemLibrary: TItemLibrary;
begin
  for I := 1 to FLibraries.Count - 1 do
  begin
    ItemLibrary := GetLibrary(I);
    ItemLibrary.SaveToFile(AoWEngine.StartupDirectory + 'User\' + ItemLibrary.GetName + '.ail');
  end;
end;

function TItemLibraryManager.IndexOfLibraryName(const Name: string): Integer;
begin
  Result := FLibraries.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if CompareText(Name, TItemLibrary(FLibraries.FChildren.List^[Result]).FName) = 0 then Exit;
  end;
  Result := -1;
end;

function TItemLibraryManager.IndexOfLibrary(ItemLibrary: TItemLibrary): Integer;
begin
  Result := FLibraries.FChildren.IndexOf(ItemLibrary);
end;

function TItemLibraryManager.FindItem(const LibraryName: string; LibraryID: Integer): TItem;
var Index: Integer;
begin
  Index := IndexOfLibraryName(LibraryName);
  if Index <> -1 then
    Result := TItemLibrary(FLibraries.FChildren.List^[Index]).FindLibraryID(LibraryID)
  else Result := nil;
end;

function TItemLibraryManager.CreateLibrary(const Name: string): TItemLibrary;
var LibraryName: string;
begin
  LibraryName := Name;
  { Original retains the period when stripping the extension. }
  if Pos('.', LibraryName) <> 0 then LibraryName := System.Copy(LibraryName, 1, Pos('.', LibraryName));
  if (LibraryName <> '') and (IndexOfLibraryName(LibraryName) = -1) then
  begin
    Result := TItemLibrary.Create(FLibraries);
    Result.FName := LibraryName;
    { Original creates in Release while reading and deleting from User. }
    Result.SaveToFile(AoWEngine.StartupDirectory + 'Release\' + LibraryName + '.ail');
  end
  else Result := nil;
end;

procedure TItemLibraryManager.DeleteLibrary(Index: Integer);
begin
  if (Index < FLibraries.Count) and (Index > 0) then
  begin
    Windows.DeleteFile(PChar(AoWEngine.StartupDirectory + 'User\' + GetLibrary(Index).GetName + '.ail'));
    GetLibrary(Index).Free;
  end;
end;

function TItemGFX.GetEngine: Engine.TEngine;
begin
  Result := AoWEngine;
end;

class function TItemGFX.ClassID: Integer;
begin
  Result := $20269;
end;

function TItemGFX.ItemGFXIndex: Integer;
begin
  Result := Owner.FindChildIndex(Self);
end;

procedure TItemGFX.LinkToIL;
begin
  ReleaseIL;
  if FImageLibraryName <> '' then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName)
  else FImageLibrary := nil;
end;

procedure TItemGFX.ReleaseIL;
begin
  if FImageLibrary <> nil then
  begin
    if FImageLibraryName <> '' then
      AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
end;

procedure TItemGFX.SetImageLibraryName(Value: string);
begin
  if FImageLibraryName <> '' then
  begin
    AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], FImageLibraryName);
    FImageLibrary := nil;
  end;
  FImageLibraryName := Value;
  if (FImageLibraryName <> '') and (FRefCount <> 0) then
    FImageLibrary := AoWHSSet.ImageLibraryManager.LinkToIL([icDisk], FImageLibraryName);
end;

function TItemGFX.AddRef: Integer;
begin
  if FRefCount = 0 then LinkToIL;
  Inc(FRefCount);
  Result := FRefCount;
end;

function TItemGFX.Release: Integer;
begin
  Dec(FRefCount);
  if FRefCount = 0 then ReleaseIL;
  Result := FRefCount;
end;

function TItemGFX.GetCellImage: ImageLib.TLibraryImage;
var Image: TLibraryImage;
begin
  AddRef;
  Image := FImageLibrary[FImageIndex];
  Release;
  Result := Image;
end;

function TItemGFX.GetItemImage: TLibraryImage;
begin
  if FImageLibrary <> nil then Result := FImageLibrary[FImageIndex]
  else Result := nil;
end;

procedure TItemGFX.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then Stream.rwString(FImageLibraryName, 6);
  Stream.rwInteger(FImageIndex, 7);
  Stream.rwData(FItemType, 1, 8);
  Stream.rwBool(FHidden, 9);
end;

constructor TItemGFXList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TItemGFXList.GetItemGFX(Index: Integer): TItemGFX;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TItemGFX(FChildren.List^[Index])
  else Result := nil;
end;

function TItemGFXList.FindItemTypeGFX(ItemType: TItemType): Integer;
var I: Integer;
begin
  Result := -1;
  I := 0;
  while (Result = -1) and (I <> FChildren.Count) do
  begin
    if (FChildren.List^[I] <> nil) and
      (TItemGFX(FChildren.List^[I]).FItemType = ItemType) then Result := I;
    Inc(I);
  end;
end;

procedure TItemHSList.SetOwner(AOwner: Engine.TECustomNode);
begin
  FOwner := AOwner;
end;

procedure TItemHSList.GetLocation(var X, Y, L: Shortint);
begin
  X := TItemHS(Owner).Xhx;
  Y := TItemHS(Owner).Yhx;
  L := TItemHS(Owner).Lhx;
end;

constructor TItemHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FItems := TItemHSList.Create(TECustomNode(Self));
  FItems.FOnChanged := ItemsChanged;
end;

destructor TItemHS.Destroy;
begin
  inherited Destroy;
  FItems.Free;
  FItems := nil;
end;

procedure TItemHS.ItemsChanged(Sender: TObject);
begin
  if (FItems.Count = 0) and ((FGenerateMode = igUserDefined) or (AoWHSMap.FDay > 0)) then
    Destroy
  else Changed;
end;

function TItemHS.GetLevel: Byte;
begin
  Result := 26;
end;

function TItemHS.GetShowPriority: Integer; { Near miss: arithmetic register allocation after three variants. }
var Xhp, Yhp: Integer; HS: THexagonSprite;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  Result := $68000000 + (Yhp + 33) * $2000 + (Xhp + 16);
  HS := TMapField(Owner).GetMaxLevelNoneTransparentHS;
  if (HS <> Self) and (HS <> nil) then
    if Result <= HS.GetShowPriority then Result := HS.GetShowPriority + 1;
end;

class function TItemHS.ClassID: Integer;
begin
  Result := $20271;
end;

function TItemHS.EditName: string;
begin
  Result := TranslateRStr(ItemBagRStr);
end;

function TItemHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  if (WordRec(LongRec(TAoWMapField(Owner).FFieldFlags).Hi).Lo = 0) and
    (AoWHSMap.FFogEnabled) then Result := False
  else Result := True;
end;

procedure TItemHS.Activate;
begin
  inherited Activate;
  FItems.RegisterItems;
end;

procedure TItemHS.Deactivate;
begin
  inherited Deactivate;
end;

procedure TItemHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  FItems.BeginUpdate;
  inherited ReadWrite(Stream);
  Stream.rwEObject(FItems, 4);
  Stream.rwData(FGenerateMode, 1, 5);
  FItems.EndUpdate;
end;

procedure TItemHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Xhp, Yhp: Integer;
begin
  if not GetSelected or (AoWHSMap.Frame and 6 <> 6) then
  begin
    HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
    AoWHSSet.FGeneralImages[0].Show(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc);
  end;
end;

function TItemHS.CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := inherited CanPlace(Map, Xhx, Yhx, Lhx);
end;
resourcestring P2RegisterLifeStealingRStr = 'Life Stealing'; P2RegisterChargeRStr = 'Charge'; P2RegisterDragonSlayingRStr = 'Dragon Slaying'; P2RegisterParryRStr = 'Parry'; P2RegisterExtraStrikeRStr = 'Extra Strike'; P2RegisterFirstStrikeRStr = 'First Strike'; P2RegisterEntangleStrikeRStr = 'Entangle Strike'; P2RegisterFireStrikeRStr = 'Fire Strike'; P2RegisterColdStrikeRStr = 'Cold Strike'; P2RegisterLightningStrikeRStr = 'Lightning Strike'; P2RegisterPoisonStrikeRStr = 'Poison Strike'; P2RegisterDeathStrikeRStr = 'Death Strike'; P2RegisterHolyStrikeRStr = 'Holy Strike'; P2RegisterMagicStrikeRStr = 'Magic Strike'; P2RegisterBlackBoltsRStr = 'Black Bolts'; P2RegisterMagicBoltsRStr = 'Magic Bolts'; P2RegisterFrostBoltsRStr = 'Frost Bolts'; P2RegisterLightningBoltsRStr = 'Lightning Bolts'; P2RegisterHolyBoltsRStr = 'Holy Bolts'; P2RegisterFireBreathRStr = 'Fire Breath'; P2RegisterColdBreathRStr = 'Cold Breath';
procedure TItemHS.GenerateItems;
var I: Byte; Item: TItem;
begin
  if FGenerateMode <> igUserDefined then
  begin
    RandSeed := AoWHSMap.Random($FFFFFF);
    FItems.FOnChanged := nil;
    if FGenerateMode = igRandom then FGenerateMode := TItemGenerateMode(AoWHSMap.Random(3) + 1);
    FItems.Clear;
    for I := 1 to Ord(FGenerateMode) do
    begin
      Item := AoWHSMap.FItemControl.GenerateItem([itHead, itTorso, itAttack, itDefense, itRing, itUse], 0, $FFFF);
      if Item <> nil then Item.SetOwner(FItems);
    end;
    FItems.FOnChanged := ItemsChanged;
    ItemsChanged(FItems);
  end;
end;
resourcestring P2RegisterBlackBreathRStr = 'Black Breath'; P2RegisterDivineBreathRStr = 'Divine Breath'; P2RegisterGasBreathRStr = 'Gas Breath'; P2RegisterShootJavelinRStr = 'Shoot Javelin'; P2RegisterShootBlackJavelinRStr = 'Shoot Black Javelin'; P2RegisterHurlStonesRStr = 'Hurl Stones'; P2RegisterFireMusketRStr = 'Fire Musket'; P2RegisterFireCannonRStr = 'Fire Cannon'; P2RegisterHurlBoulderRStr = 'Hurl Boulder'; P2RegisterVenomousSpitRStr = 'Venomous Spit'; P2RegisterCallFlamesRStr = 'Call Flames'; P2RegisterArcheryRStr = 'Archery'; P2RegisterPoisonDartsRStr = 'Poison Darts'; P2RegisterDoomGazeRStr = 'Doom Gaze';
procedure TItemHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020001) and (AoWHSMap.FDay = 1) then GenerateItems;
end;
function P2CreateRangedAttack(ID: Integer; const Name: string; Attack, Damage, Repeats: Shortint; Range: TCombatRange; DamageTypes: TDamageTypes; Enchantment: Integer): TRangedAttackAbility; var Ability: TRangedAttackAbility; begin Ability := TRangedAttackAbility.Create(nil); Ability.FAbilityID := ID; Ability.FAbilityName := Name; Ability.FRangeRA := Range; Ability.FDamageTypesRA.Value := DamageTypes; Ability.FAttackRA := Attack; Ability.FDamageRA := Damage; Ability.FAttackRepeatRA := Repeats; Result := Ability; end; { Original ignores Enchantment. }
constructor TWorldFXHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TXYZList.Create;
  FFrame := -1;
end;
function P2CreateBolts(ID: Integer; const Name: string; Attack: Integer; Damage: Shortint; DamageType: TDamageType; Enchantment: Integer): TBoltsAbility; var Ability: TBoltsAbility; begin Ability := TBoltsAbility.Create(nil); Ability.FAbilityID := ID; Ability.FAbilityName := Name; Ability.FDamageTypesRA.Value := [DamageType]; Ability.FDamageRA := Damage; Ability.FAttackRA := Attack; Result := Ability; end; { Original ignores Enchantment. }
destructor TWorldFXHS.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;
function P2CreateBreath(ID: Integer; const Name: string; DamageType: TDamageType; Enchantment: Integer): TBreathAbility; var Ability: TBreathAbility; begin Ability := TBreathAbility.Create(nil); Ability.FAbilityID := ID; Ability.FAbilityName := Name; Ability.FDamageTypesRA.Value := [DamageType]; Result := Ability; end; { Original ignores Enchantment. }
procedure TWorldFXHS.Activate;
begin
  inherited Activate;
  AoWHSMap.NewFrameEvents.Add(NewFrame);
  FFrame := -1;
end;
function P2CreateStrikeEnhancement(ID: Integer; const Name: string; Selection: TAbilitySelectionTypes): TStrikeEnhancementAbility; var Ability: TStrikeEnhancementAbility; begin Ability := TStrikeEnhancementAbility.Create(nil); Ability.FSelectionTypes := Selection; Ability.FAbilityID := ID; Ability.FAbilityName := Name; Result := Ability; end;
procedure TWorldFXHS.Deactivate;
begin
  AoWHSMap.NewFrameEvents.Remove(NewFrame);
  inherited Deactivate;
end;
procedure P2RegisterRangedGroup1(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateBolts(120, TranslateRStr(P2RegisterBlackBoltsRStr), 6, 3, dtDeath, 126)); Control.RegisterAbility(P2CreateBolts(121, TranslateRStr(P2RegisterMagicBoltsRStr), 7, 3, dtMagic, 124)); Control.RegisterAbility(P2CreateBolts(122, TranslateRStr(P2RegisterFrostBoltsRStr), 6, 3, dtCold, 125)); Control.RegisterAbility(P2CreateBolts(123, TranslateRStr(P2RegisterLightningBoltsRStr), 6, 3, dtLightning, -1)); Control.RegisterAbility(P2CreateBolts(124, TranslateRStr(P2RegisterHolyBoltsRStr), 6, 3, dtHoly, 125)); Control.RegisterAbility(P2CreateBreath(86, TranslateRStr(P2RegisterFireBreathRStr), dtFire, -1)); Control.RegisterAbility(P2CreateBreath(87, TranslateRStr(P2RegisterColdBreathRStr), dtCold, -1)); end;
function TWorldFXHS.GetShowPriority: Integer;
begin
  Result := $6C000000;
end;
procedure P2RegisterRangedGroup2(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateBreath(88, TranslateRStr(P2RegisterBlackBreathRStr), dtDeath, -1)); Control.RegisterAbility(P2CreateBreath(89, TranslateRStr(P2RegisterDivineBreathRStr), dtHoly, -1)); Control.RegisterAbility(P2CreateBreath(90, TranslateRStr(P2RegisterGasBreathRStr), dtPoison, -1)); Control.RegisterAbility(TFlameThrowingAbility.Create(nil)); Control.RegisterAbility(P2CreateRangedAttack(57, TranslateRStr(P2RegisterShootJavelinRStr), 5, 5, 2, crLong, [dtPhysical], 122)); Control.RegisterAbility(P2CreateRangedAttack(58, TranslateRStr(P2RegisterShootBlackJavelinRStr), 5, 5, 2, crLong, [dtDeath,dtPhysical], 123)); Control.RegisterAbility(P2CreateRangedAttack(25, TranslateRStr(P2RegisterHurlStonesRStr), 3, 1, 4, crMedium, [dtPhysical], 111)); end;
procedure TWorldFXHS.NewFrame(Sender: TObject); { Near miss: Particle loop registers and temporary slots differ after three variants. }
var Effect: TWorldFXHS; I, J, Count, RadiusX, RadiusY: Integer; Gravity, VZ, Speed, Z: Single;
begin
  try
    Inc(FFrame);
    case FEffectType of
      fxHatred:
        case FFrame of
          0..89:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 200;
              RadiusY := 200;
              for I := 0 to 29 do
              begin
                Effect := AoWHSMap.AddEffect(fxHatredParticle);
                Effect.FX := 50;
                Effect.FY := 50;
                RadiusX := -RadiusX;
                MakeLinePath(0, 0, Round(Cos((Random(12) + (I * 12 + FFrame * 4)) * Pi / 180) * (RadiusX + Random(10))),
                  Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 75, Effect.FPath);
              end;
            end;
          90: FFrame := -1;
        end;
      fxTranquility:
        case FFrame of
          0..89:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 200;
              RadiusY := 200;
              for I := 0 to 29 do
              begin
                Effect := AoWHSMap.AddEffect(fxTranqParticle);
                Effect.FX := 50;
                Effect.FY := 50;
                RadiusX := -RadiusX;
                MakeLinePath(0, 0, Round(Cos((Random(12) + (I * 12 + FFrame * 4)) * Pi / 180) * (RadiusX + Random(10))),
                  Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 75, Effect.FPath);
              end;
            end;
          90: FFrame := -1;
        end;
      fxCrusade:
        case FFrame of
          0..74:
            if FFrame mod 3 = 0 then
            begin
              RadiusX := 150;
              RadiusY := 150;
              for I := 0 to 59 do
              begin
                Effect := AoWHSMap.AddEffect(fxWMLParticle);
                Effect.FLayer := FLayer;
                RadiusX := -RadiusX;
                MakeLinePath(FX, FY, FX + Round(Cos((I * 6 + FFrame * 4) * Pi / 180) * (RadiusX + Random(10))),
                  FY + Round(Sin((I * 6 + FFrame * 4) * Pi / 180) * (RadiusY + Random(10))) div 2, 50, Effect.FPath);
              end;
            end;
          75: FFrame := -1;
        end;
      fxWaterMastery:
        case FFrame of
          0..199:
            begin
              if FFrame mod 5 = 0 then
              begin
                AoWHSSet.FSpellControl.GetSpell(45).FCastSounds.Play(1);
                Count := Random(10) + 100;
                for J := 0 to Count do
                begin
                  Effect := AoWHSMap.AddEffect(fxWMParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  Speed := (Random(50) + 50) * 0.1;
                  Gravity := 0.1;
                  VZ := (Random(5) + 5) * 0.1;
                  Z := 0;
                  MakeArcPath(0, 0, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
              for J := 0 to 1 do
              begin
                Count := Random(3) + 7;
                for I := 1 to Count - 1 do
                begin
                  Effect := AoWHSMap.AddEffect(fxWMParticle);
                  Effect.FX := 50 + Round(Cos(FFrame * 360 * 0.01 * Pi / 180) * FFrame) div 4;
                  Effect.FY := 50 + Round(Sin(FFrame * 360 * 0.01 * Pi / 180) * FFrame) div 8;
                  if J = 1 then
                  begin Effect.FX := 100 - Effect.FX; Effect.FY := 100 - Effect.FY; end;
                  Speed := (Random(10) + 30) * 0.1;
                  Gravity := 0.5;
                  VZ := (Random(50) + FFrame div 2) * 0.1;
                  Z := 0;
                  MakeArcPath(0, 0, I * 360 div Count, Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
            end;
          200: FFrame := -1;
        end;
      fxSpellWard:
        begin
          case FFrame of
            0..14:
              begin
                RadiusX := 200;
                RadiusY := 200;
                for I := 0 to 29 do
                begin
                  Effect := AoWHSMap.AddEffect(fxSWParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  RadiusX := -RadiusX;
                  MakeArcPathXY(Round(Cos((I * 12 + FFrame * 5) * Pi / 180) * (RadiusX + Random(10))),
                    Round(Sin((I * 12 + FFrame * 5) * Pi / 180) * (RadiusY + Random(10))) div 2,
                    0, -150, 100, 10, Effect.FPath);
                  for J := 0 to Effect.FPath.Count - 1 do
                    Effect.FPath[J].Z := -Effect.FPath[J].Z;
                end;
              end;
          end;
          case FFrame of
            15..44:
              if FFrame mod 5 = 0 then
              begin
                Count := Random(10) + 100;
                for J := 0 to Count do
                begin
                  Effect := AoWHSMap.AddEffect(fxSWBeamParticle);
                  Effect.FX := 50;
                  Effect.FY := 50;
                  Speed := (Random(50) + 50) * 0.1;
                  Gravity := 0.1;
                  VZ := (Random(5) + 5) * 0.1;
                  Z := 0;
                  MakeArcPath(0, -150, Random(360), Z, Speed, VZ, Gravity, Effect.FPath);
                end;
              end;
            120: FFrame := -1;
          end;
        end;
      fxEarthMastery:
        case FFrame of
          0..49:
            for I := 0 to 29 do
            begin
              Effect := AoWHSMap.AddEffect(fxEMParticle);
              RadiusX := Random(12);
              Effect.FX := Round(Cos((I * 12 + RadiusX) * Pi / 180) * 150) + 50;
              Effect.FY := Round(Sin((I * 12 + RadiusX) * Pi / 180) * 150) div 2 + 50;
              MakeLinePath(0, 0, 0, FFrame * 3 - 200, 30, Effect.FPath);
            end;
          200: FFrame := -1;
        end;
      fxWMParticle, fxWMLParticle, fxHatredParticle, fxSWParticle, fxSWBeamParticle, fxEMParticle, fxTranqParticle:
        if FFrame >= FPath.Count - 1 then
        begin FFrame := FPath.Count - 1; FDone := True; end;
    end;
    if FFrame = -1 then FDone := True;
  except
    MessageBox(0, PChar('Error - WorldfxHS ' + IntToStr(Ord(FEffectType))), 'Error during NewFrame', 0);
  end;
end;
procedure P2RegisterRangedGroup3(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateRangedAttack(45, TranslateRStr(P2RegisterFireMusketRStr), 5, 7, 1, crLong, [dtPhysical], 113)); Control.RegisterAbility(P2CreateRangedAttack(44, TranslateRStr(P2RegisterFireCannonRStr), 5, 8, 1, crLong, [dtPhysical,dtWall], 112)); Control.RegisterAbility(P2CreateRangedAttack(24, TranslateRStr(P2RegisterHurlBoulderRStr), 3, 7, 1, crLong, [dtPhysical,dtWall], 110)); Control.RegisterAbility(P2CreateRangedAttack(62, TranslateRStr(P2RegisterVenomousSpitRStr), 5, 4, 1, crShort, [dtPoison], -1)); Control.RegisterAbility(P2CreateRangedAttack(31, TranslateRStr(P2RegisterCallFlamesRStr), 5, 4, 1, crMedium, [dtFire], -1)); Control.RegisterAbility(P2CreateRangedAttack(22, TranslateRStr(P2RegisterArcheryRStr), 4, 2, 2, crMedium, [dtPhysical], -1)); end;
procedure TWorldFXHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var Sequence: TImageSequence; Frame: Integer;
  procedure ShowGlobal(Shadow, Inverse: Boolean);
  var Brightness: Integer;
  begin
    Brightness := 100 - FFrame * 100 div FPath.Count - ((FFrame mod 10 * 2 + Integer(Self)) mod 20);
    if Brightness < 0 then Brightness := 0;
    if Shadow then Inc(Brightness, 20);
    if Brightness > 100 then Brightness := 100;
    while Sequence <> nil do
    begin
      { Original uses the instance address as the animation phase. }
      Frame := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3);
      if Frame <> -1 then
        if Shadow then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
              FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
              SurfaceDesc, ShadowBlendTable.LookupTables[Brightness]);
        end
        else if Inverse then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
              FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
              SurfaceDesc, IntensityBlendTable.LookupTables[100 - Brightness]);
        end
        else if Sequence.ImageLibrary.ImageExist(Frame) then
          Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + (SurfaceDesc.Width * FX div 100 + Sequence.dXshift),
            FPath[FFrame].Y + (SurfaceDesc.Height * FY div 100 + Sequence.dYshift) - FPath[FFrame].Z,
            SurfaceDesc, IntensityBlendTable.LookupTables[Brightness]);
      Sequence := Sequence.Next;
    end;
  end;
  procedure ShowLocal(Shadow: Boolean);
  var Brightness: Integer;
  begin
    Brightness := 100 - FFrame * 100 div FPath.Count - ((FFrame mod 10 * 2 + Integer(Self)) mod 20);
    if Brightness < 0 then Brightness := 0;
    if Shadow then Inc(Brightness, 20);
    if Brightness > 100 then Brightness := 100;
    while Sequence <> nil do
    begin
      Frame := Sequence.GetUnloopedFrameIndex(Integer(Self) mod 3);
      if Frame <> -1 then
        if Shadow then
        begin
          if Sequence.ImageLibrary.ImageExist(Frame) then
            Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + Sequence.dXshift - XhpSurf,
              FPath[FFrame].Y + Sequence.dYshift - FPath[FFrame].Z - YhpSurf,
              SurfaceDesc, ShadowBlendTable.LookupTables[Brightness]);
        end
        else if Sequence.ImageLibrary.ImageExist(Frame) then
          Sequence.ImageLibrary[Frame].ShowBlended(FPath[FFrame].X + Sequence.dXshift - XhpSurf,
            FPath[FFrame].Y + Sequence.dYshift - FPath[FFrame].Z - YhpSurf,
            SurfaceDesc, IntensityBlendTable.LookupTables[Brightness]);
      Sequence := Sequence.Next;
    end;
  end;
begin
  try
    if FFrame >= 0 then
      case FEffectType of
        fxEMParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(64).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
        fxWMParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(45).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
        fxWMLParticle:
          if AoWHSMap.ViewL = FLayer then
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(75).FCastImages.GetImageSequence(1); ShowLocal(False); end;
        fxHatredParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(46).FCastImages.GetImageSequence(0); ShowGlobal(True, False); end;
        fxTranqParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(47).FCastImages.GetImageSequence(0); ShowGlobal(False, False); end;
        fxSWParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(65).FCastImages.GetImageSequence(1); ShowGlobal(False, True); end;
        fxSWBeamParticle:
          begin Sequence := AoWHSSet.FSpellControl.GetSpell(65).FCastImages.GetImageSequence(1); ShowGlobal(False, False); end;
      end;
  except
    MessageBox(0, 'Error during Show', Pointer('Error - WorldfxHS ' + IntToStr(Ord(FEffectType))), 0);
  end;
end;
procedure P2RegisterRangedGroup4(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateRangedAttack(61, TranslateRStr(P2RegisterPoisonDartsRStr), 4, 1, 3, crMedium, [dtPoison,dtPhysical], 114)); Control.RegisterAbility(P2CreateRangedAttack(55, TranslateRStr(P2RegisterDoomGazeRStr), 6, 5, 1, crLong, [dtDeath], -1)); end;
procedure TTranslateTextStream.TranslateString(var S: string);
begin
  S := FDictionary.Translate(S);
end;
procedure P2RegisterStrikeGroup1(Control: TAbilityControl); begin Control.RegisterAbility(TStrikeAbility.Create(nil)); Control.RegisterAbility(P2CreateStrikeEnhancement(118, TranslateRStr(P2RegisterLifeStealingRStr), [astUnit,astAttackItem,astEditor])); Control.RegisterAbility(P2CreateStrikeEnhancement(111, TranslateRStr(P2RegisterChargeRStr), [astUnit,astEditor])); Control.RegisterAbility(P2CreateStrikeEnhancement(112, TranslateRStr(P2RegisterDragonSlayingRStr), [astUnit,astAttackItem,astEditor])); Control.RegisterAbility(P2CreateStrikeEnhancement(113, TranslateRStr(P2RegisterParryRStr), [astUnit,astEditor])); Control.RegisterAbility(P2CreateStrikeEnhancement(115, TranslateRStr(P2RegisterExtraStrikeRStr), [astUnit,astAttackItem,astEditor])); Control.RegisterAbility(P2CreateStrikeEnhancement(116, TranslateRStr(P2RegisterFirstStrikeRStr), [astUnit,astAttackItem,astEditor])); end;
procedure TTranslateTextStream.TranslateStrings(var Strings: Classes.TStrings);
var S: string; I, EndOfLine, LineFeed: Integer;
begin
  if Strings.Count <> 0 then
  begin
    S := '';
    for I := 0 to Strings.Count - 1 do
    begin
      S := S + Strings[I];
      if I <> Strings.Count - 1 then S := S + '<eol>';
    end;
    S := FDictionary.Translate(S);
    Strings.Clear;
    repeat
      EndOfLine := Pos('<eol>', S);
      LineFeed := Pos(#10, S);
      if ((EndOfLine < LineFeed) or (LineFeed = 0)) and (EndOfLine <> 0) then
      begin
        Strings.Add(Copy(S, 1, EndOfLine - 1));
        S := Copy(S, EndOfLine + 5, Length(S) - EndOfLine - 4);
      end
      else if ((LineFeed < EndOfLine) or (EndOfLine = 0)) and (LineFeed <> 0) then
      begin
        Strings.Add(Copy(S, 1, LineFeed - 1));
        { Original reverses the length comparison before reading the following CR. }
        if (Length(S) < LineFeed + 1) and (S[LineFeed + 1] = #13) then Inc(LineFeed);
        S := Copy(S, LineFeed + 1, Length(S) - LineFeed);
      end
      else
      begin Strings.Add(S); S := ''; end;
    until S = '';
  end;
end;
procedure P2RegisterStrikeGroup2(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateStrikeEnhancement(119, TranslateRStr(P2RegisterEntangleStrikeRStr), [astUnit])); Control.RegisterAbility(P2CreateStrikeEnhancement(14, TranslateRStr(P2RegisterFireStrikeRStr), [astUnit,astAttackItem])); Control.RegisterAbility(P2CreateStrikeEnhancement(15, TranslateRStr(P2RegisterColdStrikeRStr), [astUnit,astAttackItem])); Control.RegisterAbility(P2CreateStrikeEnhancement(16, TranslateRStr(P2RegisterLightningStrikeRStr), [astUnit,astAttackItem])); Control.RegisterAbility(P2CreateStrikeEnhancement(17, TranslateRStr(P2RegisterPoisonStrikeRStr), [astUnit,astAttackItem])); Control.RegisterAbility(P2CreateStrikeEnhancement(18, TranslateRStr(P2RegisterDeathStrikeRStr), [astUnit,astAttackItem])); end;
procedure TAoWEngine.TranslateEObject(Obj: TEObject; Dictionary: TIvDictionary);
var Stream: TTranslateTextStream;
begin
  Stream := TTranslateTextStream.Create(Self);
  Stream.FDictionary := Dictionary;
  try
    Stream.rwEObject(Obj, 0);
  finally
    Stream.Free;
  end;
end;
procedure P2RegisterStrikeGroup3(Control: TAbilityControl); begin Control.RegisterAbility(P2CreateStrikeEnhancement(19, TranslateRStr(P2RegisterHolyStrikeRStr), [astUnit,astAttackItem])); Control.RegisterAbility(P2CreateStrikeEnhancement(20, TranslateRStr(P2RegisterMagicStrikeRStr), [astUnit,astAttackItem])); end;
procedure TAoWEngine.TranslateEObjectFromFile(Obj: TEObject; const FileName: string);
var Dictionary: TAoWDictionary;
begin
  if FileExists(FileName) then
  begin
    Dictionary := TAoWDictionary.Create(nil);
    try
      Dictionary.FFileName := FileName;
      Dictionary.Open;
      case FRegistry.GetLanguage of
        alAuto: Dictionary.SetLanguage(-1);
        alEnglish: Dictionary.SetLanguage(1);
        alGerman: Dictionary.SetLanguage(2);
        alFrench: Dictionary.SetLanguage(3);
        alItalian: Dictionary.SetLanguage(4);
        alSpanish: Dictionary.SetLanguage(5);
      end;
      TranslateEObject(Obj, Dictionary);
      Dictionary.Close;
    finally
      Dictionary.Free;
    end;
  end;
end;

procedure TExportTextStream.rwString(var S: string; ID: Integer);
var Buffer: string;
begin
  if not PropertyTable.PropertyExist(ID) then
  begin
    if S <> '' then
    begin
      Buffer := '[' + IntToStr(ID) + ']=' + '|' + S + '|' + #13 + #10;
      FBuffer.Write(Buffer[1], Length(Buffer));
      PropertyTable.Add(ID, 0);
    end;
  end
  else raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TExportTextStream.rwStrings(Strings: Classes.TStrings; ID: Integer);
var S, Buffer: string; I: Integer;
begin
  if not PropertyTable.PropertyExist(ID) then
  begin
    if Strings.Count <> 0 then
    begin
      for I := 0 to Strings.Count - 1 do
      begin
        S := S + Strings[I];
        if I <> Strings.Count - 1 then S := S + '<eol>';
      end;
      try
        Buffer := '[' + IntToStr(ID) + ']=';
        if S <> '' then Buffer := Buffer + '|' + S + '|' + #13 + #10
        else Buffer := Buffer + #13 + #10;
        FBuffer.Write(Buffer[1], Length(Buffer));
        PropertyTable.Add(ID, 0);
      finally
      end;
    end;
  end
  else raise EDoublePrioriyID.Create('Double priorityID found');
end;

procedure TAoWEngine.ExportTextToFile(const FileName: string; Obj: TEObject);
var Stream: TExportTextStream; FileStream: TFileStream;
begin
  FileStream := TFileStream.Create(FileName, fmCreate);
  try
    Stream := TExportTextStream.Create(FileStream, Self);
    try
      Stream.rwEObject(Obj, 0);
    finally
      Stream.Free;
    end;
  finally
    FileStream.Free;
  end;
end;

function TAoWEngine.TranslateRStr(const S: string): string;
begin
  if FDictionary.FLanguage > 0 then Result := FDictionary.Translate(S)
  else if CompareText(S, P2UndeadPluralRStr) = 0 then Result := P2UndeadRStr
  else Result := S;
end;

function TAoWEngine.TranslateText(const Text: string): string;
begin
  Result := TranslateRStr(Text);
end;

class function TAoWMapObjectEditor.EditorClassID: Integer;
begin
  Result := $10156;
end;

procedure P2RegisterEnhancements(Control: TAbilityControl); begin P2RegisterRangedGroup1(Control); P2RegisterRangedGroup2(Control); P2RegisterRangedGroup3(Control); P2RegisterRangedGroup4(Control); end; { Original ranged-attack registration at 5576F2EC. }
procedure P2RegisterTouches(Control: TAbilityControl); begin P2RegisterStrikeGroup1(Control); P2RegisterStrikeGroup2(Control); P2RegisterStrikeGroup3(Control); end; { Original strike registration at 557672B4. }
procedure P2InitializeMovePoints; var Mask, Terrain, Overlay, MoveType, Points: Integer; const MoveBits: array[0..7] of Byte = (1,4,2,8,16,32,64,128); begin FillChar(MovePointTables, SizeOf(MovePointTables), $FF); for Mask := 0 to 255 do for Overlay := -1 to 11 do for Terrain := 0 to 15 do begin Points := 127; for MoveType := 0 to 7 do if (Mask and MoveBits[MoveType] <> 0) and (P2MovementTemplates[MoveType,Terrain,Overlay] <> -1) and (P2MovementTemplates[MoveType,Terrain,Overlay] < Points) then Points := P2MovementTemplates[MoveType,Terrain,Overlay]; if Points <> 127 then MovePointTables[Mask,Terrain,Overlay] := Points; end; end;
procedure P2RegisterGroupControls; begin AoWEngine.RegisterEClasses([TGuardGC, TPassiveGC, TGuardAreaGC, TSuicidalGC, TPatrolGC, TScoutGC, TRefugeGC]); end;
procedure P2RegisterMoveEvents(AEngine: TAoWEngine); begin AEngine.RegisterEClasses([TEndTurnTE, TGameOverTE, TMultiMoveTE, TCheatTE, TDisbandUnitTE, TChangePlayerSettingsTE, TCombatFlowControlTE, TTerminatePlayerTE]); end;
procedure P2RegisterAbilities(Control: TAbilityControl); begin AoWEngine.RegisterEClasses([TCosmeticSurgeryEnchantment, TLeadershipAbilityData, TDispelMagicAbilityCA]); AoWEngine.RegisterEClasses([TDurationAbilityData, TMultiLevelAbilityData, TRangedAttackCA, TSelfDestructCA, TStrikeCA]); AoWEngine.RegisterEClasses([TUnitEnchantmentAbilityData, TUnitEnchantment, TDispelMagicAbilityTE, TPossessedAbilityData]); AoWEngine.RegisterEClasses([TCommandCA, TCommandedAbilityData, TCommandAbilityData, THealingTE, TDispelMagicAbilityData]); AoWEngine.RegisterEClasses([TPossessCA, TWebCA, THealingCA, TEntangleCA, THealingAbilityData, TTurnUndeadCA, TInvokeDeathCA]); Control.RegisterAbility(TLeadershipAbility.Create(nil)); Control.RegisterAbility(TEntangleAbility.Create(nil)); Control.RegisterAbility(TWebAbility.Create(nil)); Control.RegisterAbility(TSelfDestructAbility.Create(nil)); Control.RegisterAbility(TRoundAttackAbility.Create(nil)); Control.RegisterAbility(TCharmAbility.Create(nil)); Control.RegisterAbility(TCharmedAbility.Create(nil)); Control.RegisterAbility(TDominateAbility.Create(nil)); Control.RegisterAbility(TDominatedAbility.Create(nil)); Control.RegisterAbility(TSeduceAbility.Create(nil)); Control.RegisterAbility(TSeducedAbility.Create(nil)); Control.RegisterAbility(THealingAbility.Create(nil)); Control.RegisterAbility(TSpellCastingAbility.Create(nil)); Control.RegisterAbility(TTurnUndeadAbility.Create(nil)); Control.RegisterAbility(TInvokeDeathAbility.Create(nil)); Control.RegisterAbility(TConstructAbility.Create(nil)); Control.RegisterAbility(TDispelMagicAbility.Create(nil)); Control.RegisterAbility(TWallCrushingAbility.Create(nil)); Control.RegisterAbility(TTransportAbility.Create(nil)); Control.RegisterAbility(TPossessAbility.Create(nil)); Control.RegisterAbility(TPossessedAbility.Create(nil)); P2RegisterEnhancements(Control); P2RegisterTouches(Control); end;
procedure P2RegisterSpells(AEngine: TAoWEngine); begin AEngine.RegisterEClasses([TSpellTE]); AEngine.RegisterEClasses([TSpellCastEventLog]); AEngine.RegisterEClasses([TUnitSpellTE, TUnitSpellCA]); end;
constructor TAoWEngine.Create(AOwner: Engine.TECustomNode); { Near miss: Original SetLanguage uses or edx,1; three source variants emit or edx,-1. }
begin
  AoWEngine := Self;
  SetVersion(1, 36, 53);
  FRegistry := TAoWRegistry.Create;
  FUser := [euProgrammer, euDesigner, euUser];
  P2InitializeMovePoints;
  FDebug := FRegistry.GetDebugMode;
  FAnimationDetail := Byte(FRegistry.GetDetailLevel);
  FEmailGames := TEmailGameControl.Create(nil);
  FDictionary := TAoWDictionary.Create(nil);
  FDictionary.SetDictionaryName('ResourceStringDictionary');
  { Original selects English for every explicit language here. }
  case FRegistry.GetLanguage of
    alAuto: FDictionary.SetLanguage(-1);
    alEnglish: FDictionary.SetLanguage(1);
    alGerman: FDictionary.SetLanguage(1);
    alFrench: FDictionary.SetLanguage(1);
    alItalian: FDictionary.SetLanguage(1);
    alSpanish: FDictionary.SetLanguage(1);
  end;
  FDemo := False;
  FLanguage := Byte(FRegistry.GetLanguage);
  inherited Create(AOwner);
  Options := Options - [emVerifyEObjects];
  RegisterEClasses([TAoWHSSet, TAoWHSMap, TAoWMapLevel, TAoWCampaign, TAoWCampaignScenario]);
  RegisterEClasses([TPlayer, TRace, TUnit, TRaceResource, TUnitGFXResource, TUnitResource, TUnitHS]);
  RegisterEClasses([THero, THeroResource, THeroUpgradeTE, THeroJoinEventLog, THeroEmergeEventLog, TLeader, TItemGFX, TItem, TItemTE, TItemHS, TFaceResource]);
  RegisterEClasses([TArmy, TArmyHS, TArmyView, TArmyEventLog, TArmyID, TTurnInfoItem, TShowMessageEventLog]);
  RegisterEClasses([TArmyDefaultMoveTE, TArmyCombatMoveTE, TArmyCombineMoveTE, TArmyNegotiateMoveTE, TNegotiateTE, TSaveGameTE, TChangePlayerMagicTE, TChangeGlobalMagicTE]);
  RegisterEClasses([TCombatLogbook, TCombatParty, TCombatData, TDamageCA, TDamageEffectCA, TFleeCA, TCombatUnit]);
  RegisterEClasses([TFastCombat, TCombatWall, TFastCombatUnit, TMoveWallCA, TProductionEventLog]);
  RegisterEClasses([TUpdateHeaderCA, TNewCombatTurnCA, TNewCombatRoundCA, TCombatObjectTurnDoneCA]);
  RegisterEClasses([TCombatEventLog, TCombatPlayer, TDiplomaticAction, TEmailGame, TRestartGameEventLog]);
  RegisterEClasses([TStructure, TStructureResource, TStructureTE, TConstructStructureTE, TProductionTE, THeroUpdateTE]);
  RegisterEClasses([TPlayerStructure, TPlayerStructureResource, TProductionItem, TUnitProduction]);
  RegisterEClasses([TFire, TFireResource]);
  RegisterEClasses([TNewDayEventLog, TArmyInfoEventLog, TTextControlItem, THeroUpgradeEventLog]);
  RegisterEClasses([TDiplomaticActionTE, TDiplomaticActionEventLog, TPlayerMagicEventLog, TDiplomaticRelationHistoryItem, TDiplomaticRelationHistoryList]);
  RegisterEClasses([THuntAG, TAIBudget, TAISavingsBudget, TAITransporterBudget]);
  P2RegisterGroupControls;
  RegisterSoundEngineClasses(Self);
  RegisterNetworkEngine(Self);
  P2RegisterMoveEvents(Self);
  RegisterEventLog(Self);
  P2RegisterAbilities(FGameSet.FAbilityControl); P2RegisterSpells(Self);
  CombatDID := RegisterDebugID('Combat');
  AIDID := RegisterDebugID('AI');
  TMPDID := RegisterDebugID('TMP');
  MAGICDID := RegisterDebugID('MAGIC');
  Editors.RegisterClass(TAoWMapObjectEditor);
  LoadExternalPlugIns(StartupDirectory + 'PLUGINS');
  FEmailGames.Load;
end;


































destructor TAoWEngine.Destroy;
begin
  CloseCampaign;
  CloseHSM(nil);
  UnregisterCoreSpells(Self);
  UnregisterCoreAbilities(FGameSet.FAbilityControl);




































  inherited Destroy;
  FDictionary.Free;
  FEmailGames.Free;
  FRegistry.Free;
end;

procedure TAoWEngine.UpdateStartupDirectory; { Near miss: Self register differs after three source variants. }
begin
  if FRegistry.GetStartupDirectory <> '' then SetStartupDirectory(FRegistry.GetStartupDirectory)
  else SetStartupDirectory(ExtractFilePath(Application.ExeName));
  if StartupDirectory[Length(StartupDirectory)] <> '\' then SetStartupDirectory(StartupDirectory + '\');
  BaseImageLibraryPath := StartupDirectory;
  BaseSoundEnginePath := StartupDirectory;
  FDictionary.FFileName := StartupDirectory + 'Dict\' + 'ResStr' + '.mld';
  FDictionary.Open;
end;

class function TAoWEngine.ClassID: Integer;
begin Result := $20001; end;

function TAoWEngine.GetMajorVersion: Integer;
begin Result := (FVersion shr 24) and $FF; end;

function TAoWEngine.GetMinorVersion: Integer;
begin
  Result := (FVersion shr 16) and $FF;
  if Result > 99 then Result := 99;
end;

function TAoWEngine.GetBuildNumber: Integer;
begin
  Result := FVersion and $FFFF;
  if Result > 9999 then Result := 9999;
end;

procedure TAoWEngine.SetVersion(Major, Minor, Build: Integer);
begin
  if Major < 0 then Major := 0;
  if Major > 99 then Major := 99;
  if Minor < 0 then Minor := 0;
  if Minor > 99 then Minor := 99;
  if Build < 0 then Build := 0;
  if Build > 9999 then Build := 9999;
  FVersion := (Major shl 24) + (Minor shl 16) + Build;
end;

function TAoWEngine.GetVersionStr: string;
var Version: Integer;
begin
  Result := IntToStr(GetMajorVersion) + '.';
  Version := GetMinorVersion;
  if Version < 10 then Result := Result + '0' + IntToStr(Version) + '.'
  else Result := Result + IntToStr(Version) + '.';
  Version := GetBuildNumber;
  if Version < 1000 then Result := Result + '0';
  if Version < 100 then Result := Result + '0';
  if Version < 10 then Result := Result + '0';
  Result := Result + IntToStr(Version);
end;

procedure TAoWEngine.CreateHSSet;
begin
  FHSSet := TAoWHSSet.Create(Self);
  FGameSet := TAoWHSSet(FHSSet);
  AoWHSSet := FGameSet;
end;

procedure TAoWEngine.CloseHSM(AProgress: Engine.TProgressEvent);
begin
  try
    inherited CloseHSM(AProgress);
    FGameMap := nil;
    AoWHSMap := nil;
  except
    raise Exception.Create('exception occurred during CloseHSM');
  end;
end;

procedure TAoWEngine.SetHSMap(Value: HSEngine.THSMap);
begin
  inherited SetHSMap(Value);
  if Value is TAoWHSMap then
  begin
    FGameMap := TAoWHSMap(FHSMap);
    AoWHSMap := TAoWHSMap(Value);
  end;
end;

function TAoWEngine.RegisteredVersion: Boolean;
var Registered: Boolean; Mem: TMemoryStream; FileStream: TFileStream; Name: string;
begin
  try
    Mem := TMemoryStream.Create;
    { Original leaks Mem if opening or loading the file raises. }
    FileStream := TFileStream.Create(AoWEngine.StartupDirectory + 'RELEASE\GENERAL.PFS', fmOpenRead or fmShareDenyWrite);
    try
      Mem.LoadFromStream(FileStream);
    finally
      FileStream.Free;
    end;
    try
      Mem.Position := 0;
      Mem.Read(Registered, 1);
      StringFromStream(Name, Mem);
      Result := Registered;
    finally
      Mem.Free;
    end;
  except
    Result := True;
  end;
end;

function TAoWEngine.RegisteredTo: string;
var Registered: Boolean; Mem: TMemoryStream; Name: string;
begin
  try
    Mem := TMemoryStream.Create;
    try
      Mem.LoadFromFile(AoWEngine.StartupDirectory + 'RELEASE\GENERAL.PFS');
      Mem.Read(Registered, 1);
      StringFromStream(Name, Mem);
      Result := Encode(Name, 0);
    finally
      Mem.Free;
    end;
  except
    Result := '';
  end;
end;

function TAoWEngine.RequestAccess(const Name, Code: string): Boolean;

  function RegistrationCode(Text: string): string;
  var I, Value: Integer; Hex: string;
  begin
    Result := '';
    if Length(Text) >= 4 then
    begin
      Value := 0;
      for I := 1 to Length(Text) do Inc(Value, Ord(Text[I]));
      for I := 1 to 4 do
      begin
        Hex := IntToHex(Ord(Text[I]) * Value + I, 6);
        Result := Result + Hex[Length(Hex)];
        Inc(Value, Ord(Hex[Length(Hex)]) + Ord(Hex[1]));
      end;
    end;
  end;
begin
  Result := (RegisteredTo = Name) and
    (Name <> '') and
    (Code = RegistrationCode(Name));
end;

procedure TAoWEngine.CloseCampaign;
begin
  if FCampaign <> nil then
  begin
    FCampaign.Free;
    FCampaign := nil;
  end;
end;

procedure TAoWEngine.LoadCampaignMap(AProgress: Engine.TProgressEvent);
begin
  if (FCampaign <> nil) and (FCampaign.FStream <> nil) then
  begin
    CloseHSM(nil);
    AoWEngine.LoadHSMfromStream(FCampaign.FStream, False, AProgress);
  end;
end;

procedure TAoWEngine.LoadCampaign(const FileName: string);
begin
  CloseCampaign;
  FCampaign := TAoWCampaign(RetrieveFromFile(FileName, nil));
  TranslateEObjectFromFile(FCampaign, AoWEngine.StartupDirectory + 'Dict\' + 'Campaign' + '.mld');
  FCampaign.FFileName := FileName;
end;

procedure TAoWEngine.SaveCampaign(const FileName: string);
begin
  if FCampaign <> nil then
  begin
    FCampaign.FStream.Clear;
    if FGameMap <> nil then SaveHSMtoStream(FCampaign.FStream, nil);
    StoreInFile(FileName, FCampaign, nil);
  end;
end;

procedure TAoWEngine.NewCampaign(AClassID: Integer);
begin
  CloseCampaign;
  FCampaign := TAoWCampaign(CreateEObject(AClassID, nil));
end;

procedure TAgeOfWondersEngine.SetHSEngine(Value: HSEngine.THSEngine);
begin
  inherited SetHSEngine(Value);
  FGameEngine := Value;
end;

procedure TAgeOfWondersEngine.CreateEngine;
begin
  ValidateAoWEngine;
  if AoWEngine <> nil then SetHSEngine(AoWEngine);
end;

destructor TAgeOfWondersEngine.Destroy;
begin
  FGameEngine := nil;
  Engine := nil;
  inherited Destroy;
end;


procedure Register;
begin
  RegisterComponents('AoWEngine', [TAgeOfWondersEngine]);
end;

function ValidateAoWEngine: Boolean;
begin
  if (AoWEngine = nil) and (ToolServices = nil) then TAoWEngine.Create(nil);
  Result := AoWEngine <> nil;
end;



function TUnitResourceAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := [astUnit]; end;

function THeroResourceAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
begin Result := [astUnit, astEditor]; end;

class function TCombatWall.LinkP3Helpers(Index: Integer): Pointer;
begin
  if Index = 0 then Result := @P3InitializeHitProbabilities
  else Result := @P3LimitedDamage;
end;
