constructor TJoinEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
  FJoinMessage := TStringList.Create;
  FLocation.X := -1;
  FLocation.Y := -1;
  FLocation.L := -1;
  FJoinIndex := -1;
end;

destructor TJoinEventLog.Destroy;
begin
  FUnitIDs.Free;
  FJoinMessage.Free;
  inherited Destroy;
end;

procedure TJoinEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FFirstUnitID, $15);
  Stream.rwStreamProc($16, FUnitIDs.LoadFromStream, FUnitIDs.SaveToStream);
  Stream.rwByte(FSelection, $17);
  Stream.rwStrings(FJoinMessage, $18);
  Stream.rwInteger(FGold, $19);
  Stream.rwInteger(Integer(FLocation), $1A);
  Stream.rwData(FJoinMode, SizeOf(FJoinMode), $1B);
  Stream.rwString(FText, $1C);
  Stream.rwIntegerEx(FJoinIndex, -1, $1D);
end;

procedure TJoinEventLog.SetupJoinArmy(Army: TArmy; Player: Shortint;
  JoinMode: TJoinMode);
var
  I: Integer;
begin
  FFirstUnitID := 0;
  FPlayer := Byte(Player);
  FSelection := Army.GetJoinSelection(Player);
  FGold := Army.JoinAmount(Player, FSelection);
  FJoinMode := JoinMode;
  FUnitIDs.Clear;
  for I := 0 to Army.Count - 1 do
  begin
    if (FFirstUnitID = 0) and ((1 shl I) and FSelection <> 0) then
    begin
      FFirstUnitID := Army.GetUnit(I).FUnitID;
      Army.GetUnit(I).GetJoinMessage(Player,
        Army.SelectionCount(FSelection) - 1, FGold, JoinMode, FJoinMessage);
    end;
    FUnitIDs.Add(Army.GetUnit(I).FUnitID);
  end;
  FLocation := PackXYL(Shortint(Army.FX), Shortint(Army.FY),
    Shortint(Army.FL));
end;

function TJoinEventLog.Validate: Boolean;
var
  I: Integer;
  AUnit: TAbstractUnit;
  Location: TXYL;
begin
  Result := True;
  I := FUnitIDs.Count;
  while Result and (I <> 0) do
  begin
    Dec(I);
    AUnit := TUnitControl(AoWHSMap.FUnitControl).FindUnit(FUnitIDs[I]);
    { Original behavior: missing and dead units do not invalidate the offer. }
    if (AUnit <> nil) and (AUnit.FPlayer = 0) then
    begin
      AUnit.GetLocation(Location.X, Location.Y, Location.L);
      Result := (FLocation.X = Location.X) and
        (FLocation.Y = Location.Y) and (FLocation.L = Location.L);
    end;
  end;
end;

procedure TJoinEventLog.ListJoinUnits(Units: TUnitList; var Selection: Byte);
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  for I := 0 to FUnitIDs.Count - 1 do
  begin
    AUnit := TUnitControl(AoWHSMap.FUnitControl).FindUnit(FUnitIDs[I]);
    Units.AddUnit(AUnit);
  end;
  Selection := FSelection;
end;

function TJoinEventLog.Accept(var ErrorText: string): Boolean;
begin
  if TPlayerList(AoWHSMap.FPlayers).GetPlayers(FPlayer).FGems >= FGold then
    Result := True
  else
  begin
    Result := False;
    ErrorText := TranslateRStr(P5NotEnoughGoldRStr);
  end;
end;


function TJoinEventLog.Cancel: Boolean;
begin
  Result := True;
end;

function TJoinEventLog.Reject(var ErrorText: string): Boolean;
begin
  Result := True;
end;

constructor TNegotiateTE.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmyID := nil;
  FMode := [nmAttackOnReject, nmMoveOnAccept];
  FEventLogID := -1;
  FOwnerPlayer := 0;
end;

destructor TNegotiateTE.Destroy;
var
  ID: TArmyID;
begin
  ID := FArmyID;
  if ID <> nil then ID.Free;
  inherited Destroy;
end;

class function TNegotiateTE.ClassID: Integer;
begin
  Result := $21107;
end;

procedure TNegotiateTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGold, $1E);
  Stream.rwData(FOffer, SizeOf(FOffer), $1F);
  Stream.rwByte(FX, $20);
  Stream.rwByte(FY, $21);
  Stream.rwByte(FL, $22);
  Stream.rwByte(Byte(FPlayer), $23);
  Stream.rwByte(FOwnerPlayer, $24);
  Stream.rwData(FObject, SizeOf(FObject), $25);
  Stream.rwInteger(FMovePoints, $26);
  Stream.rwInteger(FData1, $27);
  Stream.rwInteger(FData2, $28);
  Stream.rwData(FMode, SizeOf(FMode), $29);
  Stream.rwData(FResult, SizeOf(FResult), $2A);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, $2B);
  Stream.rwIntegerEx(FEventLogID, -1, $2C);
end;

function TNegotiateTE.Validate: Boolean;
var
  ID: TArmyID;
begin
  ID := FArmyID;
  if ID <> nil then
    Result := ID.RetrieveArmy(FArmyHS, FSelection)
  else
    Result := True;
  if Result and (FX <> $FF) then
    Result := Byte(TAoWMapField(
      AoWHSMap.MapContainer.GetField(Shortint(FX), Shortint(FY),
        Shortint(FL))).GetPlayer) = FOwnerPlayer
  else
    Result := False;
end;

{ needs: P2 TArmyID.RetrieveArmy(var Army: TArmyHS; var Selection: Byte):
  Boolean, proved by 5572C3DF..5572C3F1 and 5578B894..5578B930. }

{ needs: P1 TAoWMapField.GetPlayer: Shortint (5572C419..5572C421). }



{ needs: P1 CreateArmyMoveTE(Army: TArmyHS; Selection: Byte; Path: TMovepath;
  MoveType: Byte; Mode: TArmyMoveMode): TMoveArmyTE.
  5572C53A..5572C54A pushes MoveType before Mode; 5574A1B3 reads MoveType. }
function P5CreateArmyMoveTE(Army: TArmyHS; Selection: Byte; Path: TMovepath;
  MoveType: Byte; Mode: TArmyMoveMode): TMoveArmyTE;
asm
  POP EBP
  JMP CreateArmyMoveTE
end;

procedure TNegotiateTE.Accept;
var
  Log: TEventLog;
  Path: TMovepath;
  Move: TMoveArmyTE;
begin
  if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).FGems >= FGold then
  begin
    TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).SetGems(
      TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).FGems - FGold);
    if FEventLogID <> -1 then
    begin
      Log := TEventLogbook(
        TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).FEventLogbook).FindID(FEventLogID);
      if Log <> nil then
        TEventLogbook(
          TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).FEventLogbook).RemoveEvent(Log);
    end;
    if (FArmyHS <> nil) and (nmMoveOnAccept in FMode) then
    begin
      Path := TMovepath.Create;
      Path.AddXYL(Shortint(FX), Shortint(FY), Shortint(FL));
      Path.AddXYL(FArmyHS.Xhx, FArmyHS.Yhx, FArmyHS.Lhx);
      Path.List^[0].Flag := Shortint(FMovePoints);
      Move := P5CreateArmyMoveTE(FArmyHS, FSelection, Path, 3,
        [mmSelectEndLocation]);
      TTokenManager(AoWHSMap.FTokenManager).TokenExecuter.InsertExecuteEvent(Move);
      { Original bug: no nil check after CreateArmyMoveTE can return nil. }
      Move.Release;
      Path.Free;
    end;
  end;
end;

procedure TNegotiateTE.Reject;
var
  Path: TMovepath;
  Move: TMoveArmyTE;
begin
  if (FOffer = noForceOffer) and (FArmyHS <> nil) and
    (nmAttackOnReject in FMode) then
  begin
    Path := TMovepath.Create;
    Path.AddXYL(Shortint(FX), Shortint(FY), Shortint(FL));
    Path.AddXYL(FArmyHS.Xhx, FArmyHS.Yhx, FArmyHS.Lhx);
    Path.List^[0].Flag := Shortint(FMovePoints);
    Move := P5CreateArmyMoveTE(FArmyHS, FSelection, Path, 1,
      [mmSelectEndLocation]);
    TTokenManager(AoWHSMap.FTokenManager).TokenExecuter.InsertExecuteEvent(Move);
    { Original bug: no nil check after CreateArmyMoveTE can return nil. }
    Move.Release;
    Path.Free;
  end;
end;

function TNegotiateTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
var
  Msg: TMapFieldMsg;
begin
  if Validate then
  begin
    Msg.MsgID := $110F;
    Msg.Param[0] := Integer(Self);
    Msg.Result := 0;
    AoWHSMap.MapContainer.GetField(Shortint(FX), Shortint(FY),
      Shortint(FL)).SendMapFieldMsg(Msg);
  end;
  Result := erDone;
end;

{ needs: P1 TPlayer.GetBusy: Boolean, tested in AL at 5572C813..5572C81A. }

constructor TNegotiateRequestEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FArmyID := nil;
end;

destructor TNegotiateRequestEventLog.Destroy;
var
  ID: TArmyID;
begin
  ID := FArmyID;
  if ID <> nil then ID.Free;
  inherited Destroy;
end;

class function TNegotiateRequestEventLog.ClassID: Integer;
begin
  Result := $202E6;
end;

procedure TNegotiateRequestEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FX), $28);
  Stream.rwByte(Byte(FY), $29);
  Stream.rwByte(Byte(FL), $2A);
  Stream.rwData(FObject, SizeOf(FObject), $2B);
  Stream.rwInteger(FData1, $2C);
  Stream.rwInteger(FData2, $2D);
  Stream.rwCreateEObject(TEObject(FArmyID), nil, $2E);
end;

function TNegotiateRequestEventLog.CreateNegotiateTE: TNegotiateTE;
var
  Event: TNegotiateTE;
  ID: TArmyID;
begin
  Event := TNegotiateTE.Create(nil);
  Event.FPlayer := FPlayer;
  Event.FObject := FObject;
  Event.FX := FX;
  Event.FY := FY;
  Event.FL := FL;
  Event.FData1 := FData1;
  Event.FData2 := FData2;
  ID := FArmyID;
  if ID <> nil then
  begin
    Event.FArmyID := TArmyID(ID.Copy(AoWEngine));
    Event.FMovePoints := FMovePoints;
  end
  else
    Event.FArmyID := nil;
  Result := Event;
end;

function TNegotiateRequestEventLog.Accept(var ErrorText: string): Boolean;
var
  TE: TNegotiateTE;
begin
  Result := inherited Accept(ErrorText);
  if Result then
  begin
    if (TPlayerList(AoWHSMap.FPlayers).GetPlayers(FPlayer).FPlayerType = ptHuman) and
      TPlayerList(AoWHSMap.FPlayers).GetPlayers(FPlayer).GetBusy then Exit;
    TE := CreateNegotiateTE;
    TE.FGold := FGold;
    TE.FOffer := noOfferBribe;
    TE.FResult := nrAccept;
    TTokenManager(AoWHSMap.FTokenManager).TokenControls[FPlayer].AddEvent(TE);
    TE.Release;
    Result := True;
  end;
end;

function TNegotiateRequestEventLog.Reject(var ErrorText: string): Boolean;
var
  TE: TNegotiateTE;
begin
  Result := inherited Reject(ErrorText);
  if Result then
  begin
    if (TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).FPlayerType = ptHuman) and
      TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FPlayer)).GetBusy then Exit;
    TE := CreateNegotiateTE;
    TE.FGold := 0;
    TE.FOffer := noForceOffer;
    TE.FResult := nrReject;
    TTokenManager(AoWHSMap.FTokenManager).TokenControls[
      Shortint(FPlayer)].AddEvent(TE);
    TE.Release;
    Result := True;
  end;
end;

function TNegotiateRequestEventLog.Cancel: Boolean;
begin
  Result := True;
end;

function TNegotiateRequestEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  { needs: EventLog.TEventLog.Execute returns Boolean; A2 is a Boolean in CL.
    Shared map's current-player byte is $A5 (5572C8FC..5572C90B). }
  PUSH EBX
  TEST CL, CL
  JNE @@Skip
  MOV EBX, AoWHSMap
  MOV BL, [EBX+$A5]
  CMP BL, [EAX+$10]
  JNE @@Skip
  PUSH DWORD PTR [Done+4]
  PUSH DWORD PTR [Done]
  CALL TEventLog.Execute
  JMP @@Done
@@Skip:
  XOR EAX, EAX
@@Done:
  POP EBX
end;

{ needs: P2 TArmy.CreateID(Selection: Byte): TArmyID (5572C98A..5572C995). }

{ needs: P1 TPlayer.GetLocal: Boolean (5572CA17..5572CA23). }
function P5PlayerLocal(Player: TPlayer): Boolean;
asm
  JMP TPlayer.GetLocal
end;

{ Original unnamed helper 5572C924, following TNegotiateRequestEventLog.
  needs: P1 declare NegotiateArmy after all forward classes are defined, then
  reference it from hosts/P5.inc. Splitting the earlier type block is illegal. }
procedure NegotiateArmy(Player: Shortint; ArmyHS: TArmyHS; Selection: Byte;
  X, Y, L: Shortint; MovePoints: Integer);
var
  Log: TNegotiateRequestEventLog;
  ErrorText: string;
  Msg: TMapFieldMsg;
begin
  if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FPlayerType = ptHuman then
  begin
    { needs: P1 current-player byte at $A5, inside the draft $A4 field. }
    if Player = AoWHSMap.FSeatedPlayer then
    begin
      Log := TNegotiateRequestEventLog.Create(nil);
      Log.FArmyID := TArmy(ArmyHS.FArmy).CreateID(Selection);
      Log.FMovePoints := MovePoints;
      Log.FX := Byte(X);
      Log.FY := Byte(Y);
      Log.FL := Byte(L);
      Log.FPlayer := Byte(Player);
      Msg.MsgID := $110E;
      Msg.Param[0] := Integer(Log);
      Msg.Param[1] := 0;
      Msg.Result := 0;
      AoWHSMap.MapContainer.GetField(X, Y, L).SendMapFieldMsg(Msg);
      if Msg.Param[1] <> 0 then Log.Execute(True, etEvent, nil);
      Log.Release;
    end;
  end
  else
    if P5PlayerLocal(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player)) then
    begin
      Log := TNegotiateRequestEventLog.Create(nil);
      Log.FArmyID := TArmy(ArmyHS.FArmy).CreateID(Selection);
      Log.FMovePoints := MovePoints;
      Log.FX := Byte(X);
      Log.FY := Byte(Y);
      Log.FL := Byte(L);
      Log.FPlayer := Byte(Player);
      Msg.MsgID := $110E;
      Msg.Param[0] := Integer(Log);
      Msg.Param[1] := 0;
      Msg.Result := 0;
      AoWHSMap.MapContainer.GetField(X, Y, L).SendMapFieldMsg(Msg);
      if (Msg.Param[1] <> 0) and
        (TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FGems >= Log.FGold) then
        Log.Accept(ErrorText)
      else
        Log.Reject(ErrorText);
      Log.Release;
    end;
end;





function P5FirstDaySeen(Player: TPlayer; Other: Byte): Integer;
asm
  JMP TPlayer.GetFirstDaySeen
end;

{ Original unnamed helper 5572CB08: copy a diplomatic event to eligible players. }
procedure BroadcastDiplomaticEvent(Log: TDiplomaticActionEventLog; Exclude: Shortint);
var
  CopyLog: TEventLog;
  Player: TPlayer;
  I: Integer;
begin
  for I := 0 to TPlayerList(AoWHSMap.FPlayers).Count - 1 do
  begin
    Player := TPlayerList(AoWHSMap.FPlayers).GetPlayers(I);
    if (Player.FStatus = psPlaying) and (I <> Exclude) and
      ((I = Shortint(Log.FAction.FSource)) or
       (I = Shortint(Log.FAction.FTarget)) or
       ((P5FirstDaySeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(I),
          Log.FAction.FSource) <> -1) and
        (P5FirstDaySeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(I),
          Log.FAction.FTarget) <> -1))) then
    begin
      CopyLog := TEventLog(Log.Copy(AoWEngine));
      TEventLogbook(Player.FEventLogbook).AddEvent(CopyLog);
      CopyLog.Release;
    end;
  end;
end;

constructor TDiplomaticAction.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FMessage := TStringList.Create;
end;

destructor TDiplomaticAction.Destroy;
begin
  FMessage.Free;
  inherited Destroy;
end;

class function TDiplomaticAction.ClassID: Integer;
begin Result := $20252; end;


function P5Format(S: string; const Args: array of const): string;
asm
  POP EBP
  JMP Format
end;

function TDiplomaticAction.GetName(Player: Shortint): string;
begin
  case FActionType of
    daDeclareWar: Result := TranslateRStr(P5DeclareWarRStr);
    daOfferPeace: Result := TranslateRStr(P5OfferPeaceRStr);
    daProposeAlliance: Result := TranslateRStr(P5ProposeAllianceRStr);
    daSendMessage: Result := TranslateRStr(P5SendMessageRStr);
    daThreatenToAttack: Result := TranslateRStr(P5ThreatenToAttackRStr);
    daMakeTribute: Result := TranslateRStr(P5MakeTributeRStr);
    daBreakAlliance: Result := TranslateRStr(P5BreakAllianceRStr);
    daBreakAllianceWithY: Result := P5Format(TranslateRStr(P5SuggestAllianceBreakWithYRStr), [TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).GetName]);
    daDeclareWarToY: Result := P5Format(TranslateRStr(P5SuggestWarWithYRStr), [TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).GetName]);
    daSendMessageAsY: Result := P5Format(TranslateRStr(P5SendMessageAsXRStr), [TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).GetName]);
  else Result := '';
  end;
end;

function P5DiplomaticRelation(Players: TPlayerList; Source, Target: Byte): TDiplomaticRelation;
asm
  JMP TPlayerList.GetDiplomaticRelation
end;

function TDiplomaticAction.GetRelationModifier(Player, Race: Shortint): Integer;
var Modifier: Integer;
begin
  Result := 0;
  case FActionType of
    daBreakAlliance:
      if (Player = Shortint(FSource)) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) = drAlliance) then
        if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace <> Race then
          Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace)) - 50) * (-40) * 0.01)
        else Result := -40;
    daBreakAllianceWithY:
      if (Player = Shortint(FTarget)) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) = drAlliance) then
        if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).FPlayerRace <> Race then
          Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).FPlayerRace)) - 50) * (-40) * 0.01)
        else Result := -40;
    daDeclareWar:
      if (Player = Shortint(FSource)) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drWar) then
      begin
        if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) = drAlliance then Modifier := -60 else Modifier := -20;
        if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace <> Race then
          Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace)) - 50) * Modifier * 0.01)
        else Result := Modifier;
      end
      else if (Player = Shortint(FTarget)) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drWar) and (TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FPlayerRace = Race) then
        Result := -20;
    daDeclareWarToY:
      if (Player = Shortint(FTarget)) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drWar) then
      begin
        if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) = drAlliance then Modifier := -60 else Modifier := -20;
        if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).FPlayerRace <> Race then
          Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)).FPlayerRace)) - 50) * Modifier * 0.01)
        else Result := Modifier;
      end;    daProposeAlliance:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drAlliance then
      begin
        if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) = drWar then Modifier := 30 else Modifier := 20;
        if Player = Shortint(FSource) then
          if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace <> Race then
            Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace)) - 50) * Modifier * 0.01)
          else Result := Modifier
        else if Player = Shortint(FTarget) then
          if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FPlayerRace <> Race then
            Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FPlayerRace)) - 50) * Modifier * 0.01)
          else Result := Modifier;
      end;
    daOfferPeace:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drPeace then
        if Player = Shortint(FSource) then
          if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace <> Race then
            Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FPlayerRace)) - 50) * 10 * 0.01)
          else Result := 10
        else if Player = Shortint(FTarget) then
          if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FPlayerRace <> Race then
            Result := Round((TRaceList(AoWHSMap.FRaces).GetRace(Race).GetRelationValue(Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FPlayerRace)) - 50) * 10 * 0.01)
          else Result := 10;

  end;
end;

function TDiplomaticAction.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TDiplomaticAction.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

procedure TDiplomaticAction.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FSource), $14);
  Stream.rwByte(Byte(FTarget), $15);
  Stream.rwByte(Byte(FOtherPlayer), $16);
  Stream.rwInteger(FGold, $17);
  Stream.rwInteger(FMana, $18);
  Stream.rwData(FActionType, SizeOf(FActionType), $19);
  Stream.rwData(FReaction, SizeOf(FReaction), $1A);
  Stream.rwStrings(FMessage, $1B);
  Stream.rwInteger(FEscrowGold, $1C);
  Stream.rwInteger(FEscrowMana, $1D);
  Stream.rwInteger(FEventLogID, $1E);
  Stream.rwInteger(FDay, $1F);
end;

procedure TDiplomaticAction.MsgProc(var Msg: TEMsg; Sender: TEObject);
var Ignore: Boolean; Log: TEventLog;
begin
  inherited MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Integer(Msg.Engine) = Shortint(FSource)) and (FReaction = darNone) then
  begin
    Ignore := (FActionType = daOfferPeace) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drPeace);
    Ignore := Ignore or ((FActionType = daBreakAllianceWithY) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drAlliance));
    Ignore := Ignore or ((FActionType = daDeclareWarToY) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drWar));
    Ignore := Ignore or ((FActionType = daProposeAlliance) and (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drAlliance));
    Ignore := Ignore or (FActionType = daMakeTribute);
    if Ignore and
      ((AoWHSMap.FPlayMode <> pmSimultaneous) or (AoWHSMap.FDay > FDay + 1)) then
    begin
      FReaction := darIgnore;
      Log := TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID);




































































      Assert(Log is TDiplomaticActionEventLog);
      TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FEventLogbook).AddEvent(Log);
      TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).SetGems(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FGems + FEscrowGold);
      TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).FMana + FEscrowMana);
      FEscrowGold := 0;
      FEscrowMana := 0;
    end;
  end;
end;

function TDiplomaticAction.CreateEventLog: TDiplomaticActionEventLog;
var Log: TDiplomaticActionEventLog;
begin
  Log := TDiplomaticActionEventLog.Create(nil);
  Log.FDay := AoWHSMap.FDay;
  Log.SetDiplomaticAction(Self);
  Result := Log;
end;

function P5RelationCount(Players: TPlayerList; Player: Byte; Relations: TDiplomaticRelations): Integer;
asm
  JMP TPlayerList.GetDiplomaticRelationCount
end;


procedure TDiplomaticAction.ExecuteAI(Player: Shortint);
var
  Peace, War, Unknown: TByteList;
  IdealPeace, IdealWar: TByteList;
  Relation: TDiplomaticRelation;
  Reaction: TDiplomaticActionReaction;
  Last: TDiplomaticAction;
  Chance: Integer;
  ErrorText: string;
begin
  Reaction := FReaction;
  if Reaction = darNone then
  begin
    Relation := P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget);
    IdealPeace := TByteList.Create;
    IdealWar := TByteList.Create;
    Peace := TByteList.Create;
    War := TByteList.Create;
    Unknown := TByteList.Create;
    TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).ListPeaceWarUnknownPlayers(Peace, War, Unknown);
    TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).ListIdealPeaceWarPlayers(IdealPeace, IdealWar);
    case FActionType of
      daOfferPeace:
      begin
        Last := TDiplomaticActionList(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FDiplomaticActions).FindLastAction(daOfferPeace, darNone, Shortint(FTarget), Shortint(FSource), -1);
        if (IdealPeace.IndexOf(FSource) <> -1) or ((Last <> nil) and (AoWHSMap.FDay - Last.FDay <= 1)) then
        begin
          if TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).CanOfferPeace(FSource) then Accept(ErrorText) else Reject(ErrorText);
        end
        else if TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).CanOfferPeace(FSource) then
        begin
          if P5RelationCount(TPlayerList(AoWHSMap.FPlayers), FSource, [drPeace, drAlliance]) + 1 < P5RelationCount(TPlayerList(AoWHSMap.FPlayers), FSource, [drWar]) then
          begin
            Last := TDiplomaticActionList(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FDiplomaticActions).FindLastAction(daOfferPeace, darReject, Shortint(FSource), Shortint(FTarget), -1);
            if (Last = nil) or (AoWHSMap.FDay - Last.FDay > 8) then
              { Original bug: escrow gold is counted twice. }
              if (AoWHSMap.Random(3) = 1) and (AoWHSMap.Random(250) + 100 < FEscrowGold + FEscrowGold) then Accept(ErrorText) else Reject(ErrorText)
            else Reject(ErrorText);
          end
          else Reject(ErrorText);
        end
        else Reject(ErrorText);
      end;
      daProposeAlliance:
        if TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).CanProposeAlliance(FSource) then
        begin
          RandSeed := (AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + Shortint(FSource) + Shortint(FTarget)) shr 2;
          Chance := (FEscrowGold + FEscrowMana) div 25 + 30;
          if Chance > 60 then Chance := 60;
          if System.Random(100) < Chance then Accept(ErrorText) else Reject(ErrorText);
        end
        else Reject(ErrorText);
      daDeclareWarToY:
        if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) = drWar then Accept(ErrorText)
        else if IdealWar.IndexOf(FOtherPlayer) <> -1 then
          if TAIPlayerControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FAIControl).CanDeclareWar(FOtherPlayer) then
            if (AoWHSMap.Random(5) = 1) and (AoWHSMap.Random(550) + 250 < FEscrowGold + FEscrowMana) then Accept(ErrorText) else Reject(ErrorText)
          else Reject(ErrorText)
        else Reject(ErrorText);
      daMakeTribute:
        if Relation in [drPeace, drAlliance] then Accept(ErrorText)
        else if AoWHSMap.Random(200) + 50 < FGold + FMana then Accept(ErrorText) else Reject(ErrorText);
      daBreakAllianceWithY:
        if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drAlliance then Accept(ErrorText) else Reject(ErrorText);
      daDeclareWar: UpdateAIDiplomaticActionsLog(Player);
    end;
    Peace.Free;
    War.Free;
    Unknown.Free;
    IdealPeace.Free;
    IdealWar.Free;
  end
  else if Reaction in [darReject, darIgnore] then
    case FActionType of
    daOfferPeace: if not (P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) in [drPeace, drWar]) then
  begin
    Last := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).CreateDiplomaticAction(daDeclareWar, Shortint(FTarget), -1);
    if Last <> nil then
    begin
      Last.Send(ErrorText);
      Last.Release;
    end;
  end;
  end;
end;

{ needs: remaining P1 draft return types/parameters; typed tail adapters retain the register ABI. }
procedure P5PlayerSeen(Player: TPlayer; Other: Byte);
asm
  JMP TPlayer.PlayerSeen
end;

procedure P5DefaultDiplomaticMessage(Source, Target, Other: Byte; Action: TDiplomaticActionType; Reaction: TDiplomaticActionReaction; Text: TStrings);
asm
  POP EBP
  JMP DWORD PTR [P5DefaultMsgProc]
end;

procedure P5SetDiplomaticRelation(Players: TPlayerList; Source, Target: Byte; Relation: TDiplomaticRelation);
asm
  POP EBP
  JMP TPlayerList.SetDiplomaticRelation
end;

procedure TDiplomaticAction.ExecuteAccept(TE: TDiplomaticActionTE);
var
  I: Integer;
  Log: TDiplomaticActionEventLog;
  Action: TDiplomaticAction;
begin
  FReaction := darAccept;
  RetrieveDefaultDiplomaticActionMessage(FSource, FTarget, FOtherPlayer, FActionType, FReaction, FMessage);
  TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).SetGems(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FGems + FEscrowGold);
  FEscrowGold := 0;
  TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FMagicControl).FMana + FEscrowMana);
  FEscrowMana := 0;
  AoWHSMap.LockRelationsChanged;
  for I := 0 to TRaceList(AoWHSMap.FRaces).Count - 1 do
  begin
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FSource,
      GetRelationModifier(Shortint(FSource), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FSource));
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FTarget,
      GetRelationModifier(Shortint(FTarget), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FTarget));
  end;
  AoWHSMap.UnlockRelationsChanged;
  case FActionType of
    daOfferPeace:
    begin
      P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget, drPeace);
      Log := CreateEventLog;
      BroadcastDiplomaticEvent(Log, -1);
      if Shortint(FSource) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
      Log.Release;
      Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
      if Log <> nil then Log.SetOwner(nil);
    end;
    daProposeAlliance:
    begin
      P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget, drAlliance);
      Log := CreateEventLog;
      BroadcastDiplomaticEvent(Log, -1);
      if Shortint(FSource) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
      Log.Release;
      Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
      if Log <> nil then Log.SetOwner(nil);
    end;
    daDeclareWarToY:
    begin
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drWar then
      begin
        P5PlayerSeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FOtherPlayer)), FTarget);
        P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer, drWar);
        Action := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).CreateDiplomaticAction(daDeclareWar, Shortint(FOtherPlayer), -1);
        if Action <> nil then
        begin
          Log := Action.CreateEventLog;
          BroadcastDiplomaticEvent(Log, Shortint(FSource));
          if Shortint(FOtherPlayer) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
          Log.Release;
          Action.Release;
        end;
      end;
      Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
      Log.SetDiplomaticAction(Self);
      TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FEventLogbook).AddEvent(Log);
      if Shortint(FSource) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
    end;
    daMakeTribute:
    begin
      Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
      Log.SetDiplomaticAction(Self);
      TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FEventLogbook).AddEvent(Log);
      if Shortint(FSource) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
    end;
    daBreakAllianceWithY:
    begin
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) = drAlliance then
      begin
        P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer, drPeace);
        Action := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).CreateDiplomaticAction(daBreakAlliance, Shortint(FOtherPlayer), -1);
        if Action <> nil then
        begin
          Log := Action.CreateEventLog;
          BroadcastDiplomaticEvent(Log, Shortint(FSource));
          if Shortint(FOtherPlayer) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
          Log.Release;
          Action.Release;
        end;
      end;
      Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
      Log.SetDiplomaticAction(Self);
      TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FEventLogbook).AddEvent(Log);
      if Shortint(FSource) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
    end;

  end;
end;

function TDiplomaticAction.CanAccept(var ErrorText: string): Boolean;
begin Result := True; end;

function TDiplomaticAction.Accept(var ErrorText: string): Boolean;
var TE: TDiplomaticActionTE;
begin
  if CanAccept(ErrorText) and not TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).GetBusy then
  begin
    TE := TDiplomaticActionTE.Create(nil);
    TE.SetDiplomaticAction(Self);
    TE.FOperation := 1;
    TTokenManager(AoWHSMap.FTokenManager).TokenControls[Shortint(FTarget)].AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TDiplomaticAction.UpdateAIDiplomaticActionsLog(Player: Shortint);
var Action: TDiplomaticAction;
begin
  if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FPlayerType in [ptCPU1..ptCPU3, ptCPU4..ptCPU5] then
  begin
    Action := TDiplomaticAction(Copy(AoWEngine));
    Action.FMessage.Clear;
    TEReferenceNode(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FDiplomaticActions).AddChild(Action);
    Action.Release;
  end;
end;

procedure TDiplomaticAction.ExecuteReject(TE: TDiplomaticActionTE);
var Log: TDiplomaticActionEventLog;
begin
  case FActionType of
    daOfferPeace:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drPeace then FReaction := darReject else FReaction := darIgnore;
    daProposeAlliance:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget) <> drAlliance then FReaction := darReject else FReaction := darIgnore;
    daDeclareWarToY:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) <> drWar then FReaction := darReject else FReaction := darIgnore;
    daBreakAllianceWithY:
      if P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FTarget, FOtherPlayer) = drAlliance then FReaction := darReject else FReaction := darIgnore;
  else FReaction := darReject;
  end;
  TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).SetGems(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FGems + FEscrowGold);
  FEscrowGold := 0;
  TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).FMana + FEscrowMana);
  FEscrowMana := 0;
  RetrieveDefaultDiplomaticActionMessage(FSource, FTarget, FOtherPlayer, FActionType, FReaction, FMessage);
  Log := TDiplomaticActionEventLog(TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).FindID(FEventLogID));
  Log.SetDiplomaticAction(Self);
  TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FEventLogbook).AddEvent(Log);
end;

function TDiplomaticAction.CanReject(var ErrorText: string): Boolean;
begin Result := True; end;

function TDiplomaticAction.Reject(var ErrorText: string): Boolean;
var TE: TDiplomaticActionTE;
begin
  if CanReject(ErrorText) and not TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).GetBusy then
  begin
    TE := TDiplomaticActionTE.Create(nil);
    TE.SetDiplomaticAction(Self);
    TE.FOperation := 2;
    TTokenManager(AoWHSMap.FTokenManager).TokenControls[Shortint(FTarget)].AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

procedure TDiplomaticAction.ExecuteSend(TE: TDiplomaticActionTE);
var I: Integer; Log: TDiplomaticActionEventLog;
begin
  if FReaction = darNone then
  begin
    FEscrowGold := FGold;
    TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).SetGems(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FGems - FGold);
    FEscrowMana := FMana;
    TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).FMana - FMana);
    case FActionType of
      daOfferPeace..daMakeTribute, daSendMessageAsY..daDeclareWarToY:
      begin
        P5PlayerSeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)), FSource);
        if Shortint(FSource) = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowMessage(TranslateRStr(P5MessageSentRStr));
        Log := CreateEventLog;
        TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).AddEvent(Log);
        if Shortint(FTarget) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
        Log.Release;
        TEventList(AoWHSMap.FDiplomaticRelationsChangedEvents).TriggerNotifyEvents(Self);
      end;

      daBreakAlliance:
      begin
  AoWHSMap.LockRelationsChanged;
  for I := 0 to TRaceList(AoWHSMap.FRaces).Count - 1 do
  begin
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FSource,
      GetRelationModifier(Shortint(FSource), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FSource));
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FTarget,
      GetRelationModifier(Shortint(FTarget), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FTarget));
  end;
  AoWHSMap.UnlockRelationsChanged;
        P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget, drPeace);
        if Shortint(FSource) = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowMessage(TranslateRStr(P5AllianceBrokenRStr));
        Log := CreateEventLog;
        BroadcastDiplomaticEvent(Log, -1);
        if Shortint(FTarget) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
        Log.Release;
      end;

      daDeclareWar:
      begin
  AoWHSMap.LockRelationsChanged;
  for I := 0 to TRaceList(AoWHSMap.FRaces).Count - 1 do
  begin
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FSource,
      GetRelationModifier(Shortint(FSource), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FSource));
    TRaceList(AoWHSMap.FRaces).GetRace(I).SetPlayerRelationValue(FTarget,
      GetRelationModifier(Shortint(FTarget), Shortint(I)) + TRaceList(AoWHSMap.FRaces).GetRace(I).GetPlayerRelationValue(FTarget));
  end;
  AoWHSMap.UnlockRelationsChanged;
        P5PlayerSeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)), FSource);
        P5SetDiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), FSource, FTarget, drWar);
        if Shortint(FSource) = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowMessage(TranslateRStr(P5WarDeclaredRStr));
        Log := CreateEventLog;
        BroadcastDiplomaticEvent(Log, -1);
        if Shortint(FTarget) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
        Log.Release;
      end;
    end;
  end;
end;

function TDiplomaticAction.CanSend(var ErrorText: string): Boolean;
begin
  if TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FGems >= FGold then
  begin
    if TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).FMana >= FMana then
    begin
      Result := True;
      if (FActionType = daMakeTribute) and (FGold = 0) and (FMana = 0) then
      begin
        ErrorText := TranslateRStr(P5NoGoldManaSpecifiedRStr);
        Result := False;
      end;
    end
    else
    begin
      Result := False;
      ErrorText := TranslateRStr(P5NotEnoughManaRStr);
    end;
  end
  else
  begin
    Result := False;
    ErrorText := TranslateRStr(P5NotEnoughGoldRStr);
  end;
end;

function TDiplomaticAction.Send(var ErrorText: string): Boolean;
var TE: TDiplomaticActionTE;
begin
  if CanSend(ErrorText) and not TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).GetBusy then
  begin
    FDay := AoWHSMap.FDay;
    TE := TDiplomaticActionTE.Create(nil);
    TE.SetDiplomaticAction(Self);
    TE.FOperation := 0;
    TTokenManager(AoWHSMap.FTokenManager).TokenControls[Shortint(FSource)].AddEvent(TE);
    TE.Release;
    Result := True;
  end
  else Result := False;
end;

function TDiplomaticActionList.GetDiplomaticActions(Index: Integer): TDiplomaticAction;
begin Result := TDiplomaticAction(FChildren.List^[Index]); end;

function TDiplomaticActionList.FindLastAction(Action: TDiplomaticActionType;
  Reaction: TDiplomaticActionReaction; Source, Target, Other: Shortint): TDiplomaticAction;
var I: Integer; Candidate: TDiplomaticAction;
begin
  Result := nil;
  I := Count;
  while (Result = nil) and (I <> 0) do
  begin
    Dec(I);
    Candidate := TDiplomaticAction(FChildren.List^[I]);
    if (Candidate.FActionType = Action) and (Candidate.FReaction = Reaction) and
      ((Source = Shortint(Candidate.FSource)) or (Source = -1)) and
      ((Shortint(Candidate.FTarget) = Target) or (Target = -1)) and
      ((Shortint(Candidate.FOtherPlayer) = Other) or (Other = -1)) then Result := Candidate;
  end;
end;

destructor TDiplomaticActionTE.Destroy;
var Action: TDiplomaticAction;
begin
  inherited Destroy;
  Action := FAction;
  if Action <> nil then Action.Release;
end;

class function TDiplomaticActionTE.ClassID: Integer;
begin Result := $21108; end;

procedure TDiplomaticActionTE.SetDiplomaticAction(Action: TDiplomaticAction);
var Old: TDiplomaticAction;
begin
  Old := FAction;
  if Old <> Action then
  begin
    if Old <> nil then Old.Release;
    FAction := Action;
    if FAction <> nil then FAction.AddRef;
  end;
end;

procedure TDiplomaticActionTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FAction), nil, $14);
  Stream.rwInteger(FOperation, $15);
end;

function TDiplomaticActionTE.Execute(TE: TTokenExecuter): TExecuteResult;
var ErrorText: string;
begin
  case FOperation of
    0: if FAction.CanSend(ErrorText) then
       begin
         FAction.ExecuteSend(Self);
         FAction.UpdateAIDiplomaticActionsLog(Shortint(FAction.FSource));
       end;
    1: if FAction.CanAccept(ErrorText) then
       begin
         FAction.ExecuteAccept(Self);
         FAction.UpdateAIDiplomaticActionsLog(Shortint(FAction.FTarget));
       end;
    2: if FAction.CanReject(ErrorText) then
       begin
         FAction.ExecuteReject(Self);
         FAction.UpdateAIDiplomaticActionsLog(Shortint(FAction.FTarget));
       end;
  end;
  Result := erDone;
end;

destructor TDiplomaticActionEventLog.Destroy;
var Action: TDiplomaticAction;
begin
  Action := FAction;
  if Action <> nil then
  begin
    Action.Release;
    FAction := nil;
  end;
  inherited Destroy;
end;

procedure TDiplomaticActionEventLog.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  FAction.MsgProc(Msg, Sender);
end;

procedure TDiplomaticActionEventLog.SetDiplomaticAction(Action: TDiplomaticAction);
var Old: TDiplomaticAction;
begin
  Old := FAction;
  if Old <> Action then
  begin
    if Old <> nil then Old.Release;
    if Action <> nil then FAction := TDiplomaticAction(Action.Copy(AoWEngine)) else FAction := nil;
  end;
end;

class function TDiplomaticActionEventLog.ClassID: Integer;
begin Result := $20113; end;

procedure TDiplomaticActionEventLog.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwCreateEObject(TEObject(FAction), nil, $14);
end;

procedure TDiplomaticActionEventLog.PlayLoggedSFX(A1: TEventLogbook);
begin
  case FAction.FActionType of
    daDeclareWar, daThreatenToAttack, daBreakAlliance: Sound.PlaySample('SFX\EVENTS\MESSAGE.WAV');
    daOfferPeace, daProposeAlliance, daMakeTribute: Sound.PlaySample('SFX\EVENTS\MESSAGE2.WAV');
  else Sound.PlaySample('SFX\EVENTS\MESSAGE.WAV');
  end;
end;

procedure TDiplomaticActionEventLog.NotifyLogged(A1: TEventLogbook);
var Action: TDiplomaticAction;
begin
  inherited NotifyLogged(A1);
  Action := FAction;
  if Action <> nil then Action.FEventLogID := FID;
end;

function TDiplomaticActionEventLog.GetVisible: Boolean;
begin Result := True; end;

function TDiplomaticActionEventLog.GetTextColor: TColor;
var Race: Integer;
begin
  if FAction.FActionType = daSendMessageAsY then
  begin
    if (Shortint(FAction.FOtherPlayer) > 0) and
      (Shortint(FAction.FOtherPlayer) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Race := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FAction.FOtherPlayer)).FPlayerRace
    else Race := 12;
    Result := P5RaceColors[Race];
  end
  else if FAction.FReaction = darAccept then
  begin
    if (Shortint(FAction.FTarget) > 0) and
      (Shortint(FAction.FTarget) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Race := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FAction.FTarget)).FPlayerRace
    else Race := 12;
    Result := P5RaceColors[Race];
  end
  else if AoWHSMap.FSeatedPlayer <> Shortint(FAction.FSource) then
  begin
    if (Shortint(FAction.FSource) > 0) and
      (Shortint(FAction.FSource) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Race := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FAction.FSource)).FPlayerRace
    else Race := 12;
    Result := P5RaceColors[Race];
  end
  else
  begin
    if (Shortint(FAction.FTarget) > 0) and
      (Shortint(FAction.FTarget) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Race := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FAction.FTarget)).FPlayerRace
    else Race := 12;
    Result := P5RaceColors[Race];
  end;
end;

function TDiplomaticActionEventLog.GetText: string;
var Action: TDiplomaticAction;
begin
  Action := FAction;
  case Action.FActionType of
    daDeclareWar: Result := TranslateRStr(P5WarRStr);
    daProposeAlliance:
    begin
      Result := TranslateRStr(P5AllianceProposalRStr);
      if Action.FReaction = darReject then
        Result := P5Format(TranslateRStr(P5XRejectedRStr), [TranslateRStr(P5AllianceProposalRStr)])
      else if Action.FReaction = darAccept then
        if Shortint(Action.FSource) = AoWHSMap.FSeatedPlayer then
          Result := P5Format(TranslateRStr(P5XAcceptedRStr), [TranslateRStr(P5AllianceProposalRStr)])
        else Result := TranslateRStr(P5MadeAllianceRStr)
      else if Action.FReaction = darIgnore then
        Result := P5Format(TranslateRStr(P5XIgnoredRStr), [TranslateRStr(P5AllianceProposalRStr)]);
    end;
    daOfferPeace:
    begin
      if Action.FReaction = darNone then Result := TranslateRStr(P5PeaceOfferRStr)
      else if Action.FReaction = darReject then
        Result := P5Format(TranslateRStr(P5XRejectedRStr), [TranslateRStr(P5PeaceOfferRStr)])
      else if Action.FReaction = darAccept then
        if Shortint(Action.FSource) = AoWHSMap.FSeatedPlayer then
          Result := P5Format(TranslateRStr(P5XAcceptedRStr), [TranslateRStr(P5PeaceOfferRStr)])
        else Result := TranslateRStr(P5PeaceRStr)
      else if Action.FReaction = darIgnore then
        Result := P5Format(TranslateRStr(P5XIgnoredRStr), [TranslateRStr(P5PeaceOfferRStr)]);
    end;
    daMakeTribute:
    begin
      if Action.FReaction = darNone then Result := TranslateRStr(P5TributeRStr)
      else if Action.FReaction = darReject then
        Result := P5Format(TranslateRStr(P5XRejectedRStr), [TranslateRStr(P5TributeRStr)])
      else if Action.FReaction = darAccept then
        Result := P5Format(TranslateRStr(P5XAcceptedRStr), [TranslateRStr(P5TributeRStr)])
      else if Action.FReaction = darIgnore then
        Result := P5Format(TranslateRStr(P5XIgnoredRStr), [TranslateRStr(P5TributeRStr)]);
    end;
    daDeclareWarToY:
    begin
      if Action.FReaction = darNone then Result := TranslateRStr(P5DeclareWarSuggestionRStr)
      else if Action.FReaction = darReject then
        Result := P5Format(TranslateRStr(P5XRejectedRStr), [TranslateRStr(P5DeclareWarRStr)])
      else if Action.FReaction = darAccept then
        Result := P5Format(TranslateRStr(P5XAcceptedRStr), [TranslateRStr(P5DeclareWarRStr)])
      else if Action.FReaction = darIgnore then
        Result := P5Format(TranslateRStr(P5XIgnoredRStr), [TranslateRStr(P5DeclareWarRStr)]);
    end;
    daBreakAllianceWithY:
    begin
      if Action.FReaction = darNone then Result := TranslateRStr(P5BreakAllianceSuggestionRStr)
      else if Action.FReaction = darReject then
        Result := P5Format(TranslateRStr(P5XRejectedRStr), [TranslateRStr(P5BreakAllianceRStr)])
      else if Action.FReaction = darAccept then
        Result := P5Format(TranslateRStr(P5XAcceptedRStr), [TranslateRStr(P5BreakAllianceRStr)])
      else if Action.FReaction = darIgnore then
        Result := P5Format(TranslateRStr(P5XIgnoredRStr), [TranslateRStr(P5BreakAllianceRStr)]);
    end;
    daBreakAlliance: Result := TranslateRStr(P5AllianceBrokenRStr);
    daSendMessage: Result := TranslateRStr(P5MessageRStr);
    daSendMessageAsY: Result := TranslateRStr(P5MessageRStr);
    daThreatenToAttack: Result := TranslateRStr(P5ThreatRStr);
  else Result := 'TDiplomaticActionEventLog';
  end;
end;

function TDiplomaticActionEventLog.GetLeftIcon: Integer;
var Action: TDiplomaticAction;
begin
  Action := FAction;
  if Action.FActionType <> daSendMessageAsY then
  begin
    if (Shortint(Action.FSource) > 0) and
      (Shortint(Action.FSource) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Result := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(Action.FSource)).FPlayerRace
    else Result := -1;
  end
  else
  begin
    if (Shortint(Action.FOtherPlayer) > 0) and
      (Shortint(Action.FOtherPlayer) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Result := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(Action.FOtherPlayer)).FPlayerRace
    else Result := -1;
  end;
end;

function TDiplomaticActionEventLog.GetMiddleIcon: Integer;
asm
  MOV EDX, [EAX+$18]
  MOV CL, [EDX+$13]
  SUB CL, 1
  JB @@War
  SUB CL, 8
  JE @@SuggestedWar
  JMP @@Message
@@War:
  MOV EAX, $15
  RET
@@SuggestedWar:
  CMP BYTE PTR [EDX+$14], 1
  JNE @@Rejected
  MOV EAX, $15
  { DCC32 folds JMP-to-RET; keep the original branch over the 11-byte arms. }
  DB $EB, $0B
@@Rejected:
  MOV EAX, $16
  RET
@@Message:
  MOV EAX, $16
@@Done:
end;

function TDiplomaticActionEventLog.GetRightIcon: Integer;
var Action: TDiplomaticAction;
begin
  Action := FAction;
    if (Shortint(Action.FTarget) > 0) and
      (Shortint(Action.FTarget) < TPlayerList(AoWHSMap.FPlayers).Count) then
      Result := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(Action.FTarget)).FPlayerRace
    else Result := -1;
end;





function P5DiplomaticExecute(Log: TDiplomaticActionEventLog; Immediate: Boolean;
  Trigger: TExecuteTrigger; Data, Done: Pointer): Boolean;
begin
  Result := Trigger = etUser;
  if (Shortint(Log.FAction.FTarget) = AoWHSMap.FSeatedPlayer) or
    (Shortint(Log.FAction.FSource) = AoWHSMap.FSeatedPlayer) then
  begin
    Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
      (wpDiplomacy in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents) and (Trigger = etNewTurn));
    Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
      (wpDiplomacy in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
  end;
  Result := Result and ((Trigger = etUser) or (Log.FAction.FReaction <> darIgnore));
  if Result then
  begin
    AoWHSMap.TriggerExecuteEventLog(Log, Immediate, TExecuteDoneEvent(Pointer(@Done)^));
    Result := True;
  end
  else Result := False;
end;

function TDiplomaticActionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean; var Show: Boolean;
begin Show := Trigger = etUser;
  if (AoWHSMap.FSeatedPlayer = Shortint(FAction.FTarget)) or (AoWHSMap.FSeatedPlayer = Shortint(FAction.FSource)) then begin Show := Show or ((AoWHSMap.FPlayMode = pmTurn) and (wpDiplomacy in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents) and (Trigger = etNewTurn)); Show := Show or ((AoWHSMap.FPlayMode = pmSimultaneous) and (wpDiplomacy in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents)); end;
  Show := Show and ((Trigger = etUser) or (FAction.FReaction <> darIgnore));
  if Show then begin AoWHSMap.TriggerExecuteEventLog(Self, Mode, Done); Result := True; end else Result := False;
end;
procedure RetrieveDefaultDiplomaticActionMessage(Source, Target, Other: Shortint; Action: TDiplomaticActionType; Reaction: TDiplomaticActionReaction; Text: TStrings);
var
  SourceRace, TargetRace, OtherRace: string;
  Relation: TDiplomaticRelation;
  TextControl: TTextControl;
  Alignment: Integer;
begin
  Text.Clear;
  TextControl := AoWHSSet.FTextControl;
  Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(Source, Target);
  SourceRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace]);
  TargetRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Target).FPlayerRace]);
  if Other > 0 then
    OtherRace := TranslateRStr(RaceNamesPluralRStr[AoWHSMap.FPlayers.GetPlayers(Other).FPlayerRace])
  else OtherRace := '';
  if AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace).GetAlignment in [alPureGood, alGood] then Alignment := 0
  else if AoWHSSet.FRaceResources.GetRaceResource(AoWHSMap.FPlayers.GetPlayers(Source).FPlayerRace).GetAlignment in [alEvil, alPureEvil] then Alignment := 2
  else Alignment := 1;
  case Action of
    daDeclareWar:
      begin
        if Relation = drUnknown then TextControl.RetrieveText(Alignment + 151, Text)
        else TextControl.RetrieveText(Alignment + 100, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daOfferPeace:
      if Reaction = darNone then
      begin
        if Relation = drUnknown then TextControl.RetrieveText(Alignment + 103, Text)
        else TextControl.RetrieveText(Alignment + 154, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 127, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 130, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daProposeAlliance:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 106, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 121, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 124, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daBreakAlliance:
      begin
        TextControl.RetrieveText(Alignment + 109, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daThreatenToAttack:
      begin
        TextControl.RetrieveText(Alignment + 112, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end;
    daMakeTribute:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 118, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 133, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 136, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace]);
      end;
    daBreakAllianceWithY:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 160, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace, OtherRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 139, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 142, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end;
    daDeclareWarToY:
      if Reaction = darNone then
      begin
        TextControl.RetrieveText(Alignment + 157, Text);
        Text.Text := Format(Text.Text, [SourceRace, TargetRace, OtherRace]);
      end
      else if Reaction = darAccept then
      begin
        TextControl.RetrieveText(Alignment + 145, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end
      else if Reaction = darReject then
      begin
        TextControl.RetrieveText(Alignment + 148, Text);
        Text.Text := Format(Text.Text, [TargetRace, SourceRace, OtherRace]);
      end;
  end;
end;


constructor TDiplomacyAIPA.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); end;

destructor TDiplomacyAIPA.Destroy;
begin inherited Destroy; end;

class function TDiplomacyAIPA.Priority: Integer;
begin Result := 14; end;

function TDiplomacyAIPA.Activate: Boolean;
begin Result := inherited Activate; FNextPlayer := 0; end;

function TDiplomacyAIPA.CreateDA(Action: TDiplomaticActionType;
  Target, Other: Shortint; MinDays: Integer): TDiplomaticAction;
var Player: Shortint; Last: TDiplomaticAction;
begin
  Player := Shortint(TPlayer(TAIPlayerControl(FControl).FPlayer).FPlayerIndex);
  Last := TDiplomaticActionList(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FDiplomaticActions).FindLastAction(Action, darNone, Player, Target, Other);
  if (Last = nil) or (AoWHSMap.FDay - Last.FDay >= MinDays) then
    Result := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).CreateDiplomaticAction(Action, Target, Other)
  else Result := nil;
end;

function TDiplomacyAIPA.ExecuteDiplomacy(Player: Shortint): Boolean; { Near miss: Player/action register allocation differs after three variants. }
var
  Action: TDiplomaticAction;
  Peace, War, Unknown: TByteList;
  IdealPeace, IdealWar: TByteList;
  Candidates: TDoubleItemList;
  I, J, Index, Score: Integer;
  Source, Candidate: Shortint;
  ErrorText: string;
begin
  { Original bug: the result remains False even when an action is sent. }
  Result := False;
  Action := nil;
  Source := Shortint(TPlayer(TAIPlayerControl(FControl).FPlayer).FPlayerIndex);
  IdealPeace := TByteList.Create;
  IdealWar := TByteList.Create;
  Peace := TByteList.Create;
  War := TByteList.Create;
  Unknown := TByteList.Create;
  TAIPlayerControl(FControl).ListPeaceWarUnknownPlayers(Peace, War, Unknown);
  TAIPlayerControl(FControl).ListIdealPeaceWarPlayers(IdealPeace, IdealWar);
  case P5DiplomaticRelation(TPlayerList(AoWHSMap.FPlayers), Byte(Source), Player) of
    drUnknown:
    begin
      if IdealPeace.IndexOf(Player) <> -1 then
        if TAIPlayerControl(FControl).CanOfferPeace(Player) then Action := CreateDA(daOfferPeace, Player, -1, 10)
        else Action := CreateDA(daDeclareWar, Player, -1, -1);
      if IdealWar.IndexOf(Player) <> -1 then
        if TAIPlayerControl(FControl).CanDeclareWar(Player) then Action := CreateDA(daDeclareWar, Player, -1, -1)
        else Action := CreateDA(daOfferPeace, Player, -1, 10);
    end;
    drPeace:
      if not TAIPlayerControl(FControl).CanOfferPeace(Player) and (IdealWar.IndexOf(Player) <> -1) then
      begin
        RandSeed := AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + Source;
        Index := System.Random(IdealWar.Count);
        if IdealWar[Index] = Player then Action := CreateDA(daDeclareWar, Player, -1, -1);
      end
      else if TAIPlayerControl(FControl).CanProposeAlliance(Player) then
      begin
        RandSeed := (AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + Source) shr 2;
        if System.Random(100) < 30 then Action := CreateDA(daProposeAlliance, Player, -1, 10);
      end;
    drAlliance:
      if not TAIPlayerControl(FControl).CanOfferPeace(Player) and (IdealWar.IndexOf(Player) <> -1) then
      begin
        RandSeed := AoWHSMap.FInitialRandomSeed + AoWHSMap.FDay + Source + 1;
        Index := System.Random(IdealWar.Count);
        if IdealWar[Index] = Player then Action := CreateDA(daBreakAlliance, Player, -1, -1);
      end;
    drWar:
      if not TAIPlayerControl(FControl).CanDeclareWar(Player) then
      begin
        Candidates := TDoubleItemList.Create;
        for I := 0 to IdealPeace.Count - 1 do
        begin
          Candidate := Shortint(IdealPeace[I]);
          if (War.IndexOf(Byte(Candidate)) <> -1) and TAIPlayerControl(FControl).CanOfferPeace(Byte(Candidate)) then
          begin
            Action := TDiplomaticActionList(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Source).FDiplomaticActions).FindLastAction(daOfferPeace, darNone, Source, Candidate, -1);
            if (Action = nil) or (AoWHSMap.FDay - Action.FDay > 12) then
            begin
              Score := -I;
              Dec(Score, P5RelationCount(TPlayerList(AoWHSMap.FPlayers), Byte(Candidate), [drPeace]) * 5);
              Dec(Score, P5RelationCount(TPlayerList(AoWHSMap.FPlayers), Byte(Candidate), [drAlliance]) * 10);
              Candidates.AddAB(Candidate, Score);
            end;
            Action := nil;
          end;
        end;
        if (Candidates.Count = 0) and (War.Count - Peace.Count > 2) then
          for J := 0 to IdealWar.Count - 1 do
          begin
            Candidate := Shortint(IdealWar[J]);
            if War.IndexOf(Byte(Candidate)) <> -1 then
            begin
              Action := TDiplomaticActionList(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Source).FDiplomaticActions).FindLastAction(daOfferPeace, darNone, Source, Candidate, -1);
              if (Action = nil) or (AoWHSMap.FDay - Action.FDay > 12) then
              begin
                Score := J;
                Dec(Score, P5RelationCount(TPlayerList(AoWHSMap.FPlayers), Byte(Candidate), [drPeace]) * 5);
                Dec(Score, P5RelationCount(TPlayerList(AoWHSMap.FPlayers), Byte(Candidate), [drAlliance]) * 10);
                Candidates.AddAB(Candidate, Score);
              end;
              Action := nil;
            end;
          end;
        if Candidates.Count <> 0 then
        begin
          Candidates.SortDescendingItemB;
          if Candidates[0].A = Player then Action := CreateDA(daOfferPeace, Shortint(Candidates[0].A), -1, -1);
        end;
        Candidates.Free;
      end;
  end;
  if Action <> nil then
  begin
    Action.Send(ErrorText);
    Action.Release;
  end;
  Peace.Free;
  War.Free;
  Unknown.Free;
  IdealPeace.Free;
  IdealWar.Free;
end;

procedure TDiplomacyAIPA.ListDebugInfo;
var IdealPeace, IdealWar: TByteList; Player, I: Integer; S: string;
begin
  IdealPeace := TByteList.Create;
  IdealWar := TByteList.Create;
  TAIPlayerControl(FControl).ListIdealPeaceWarPlayers(IdealPeace, IdealWar);
  Player := Shortint(TPlayer(TAIPlayerControl(FControl).FPlayer).FPlayerIndex);
  S := TranslateRStr(RaceNamesPluralRStr[Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FPlayerRace)]);
  S := S + '/' + TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).GetName;
  AoWEngine.OutputDebugMessage(AIDID, 'DIPLOMACY (' + S + ')');
  AoWEngine.OutputDebugMessage(AIDID, 'IDEAL PEACE PLAYERS');
  for I := 0 to IdealPeace.Count - 1 do
  begin
    S := TranslateRStr(RaceNamesPluralRStr[Shortint(TPlayerList(AoWHSMap.FPlayers).GetPlayers(IdealPeace[I]).FPlayerRace)]);
    S := S + '/' + TPlayerList(AoWHSMap.FPlayers).GetPlayers(IdealPeace[I]).GetName;
    AoWEngine.OutputDebugMessage(AIDID, S);
  end;
  AoWEngine.OutputDebugMessage(AIDID, 'IDEAL WAR PLAYERS');
  for I := 0 to IdealWar.Count - 1 do
  begin

    AoWEngine.OutputDebugMessage(AIDID, TPlayerList(AoWHSMap.FPlayers).GetPlayers(IdealWar[I]).GetName);
  end;
  IdealPeace.Free;
  IdealWar.Free;
end;



function TDiplomacyAIPA.Process: Boolean;
begin
  inherited Process;
    if TPlayer(TAIPlayerControl(FControl).FPlayer).FPlayerIndex <> 0 then
    begin
      while (FNextPlayer < TPlayerList(AoWHSMap.FPlayers).Count) and not TPlayer(TAIPlayerControl(FControl).FPlayer).GetBusy do
      begin
        Inc(FNextPlayer);
        while (FNextPlayer < TPlayerList(AoWHSMap.FPlayers).Count) and
          ((P5FirstDaySeen(TPlayer(TAIPlayerControl(FControl).FPlayer), Byte(FNextPlayer)) = -1) or (Shortint(TPlayer(TAIPlayerControl(FControl).FPlayer).FPlayerIndex) = FNextPlayer)) do Inc(FNextPlayer);
        if FNextPlayer < TPlayerList(AoWHSMap.FPlayers).Count then ExecuteDiplomacy(FNextPlayer);
      end;
      Result := FNextPlayer < TPlayerList(AoWHSMap.FPlayers).Count;
    end
    else Result := False;
end;

constructor TAoWMapCampaignSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTransferPointsMax := 1000;
  FTransferGoldMax := 100;
  FTransferManaMax := 100;
  FHeroLevelMax := -1;
  FAlliedVictory := False;
end;

procedure TAoWMapCampaignSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTransferPointsMax, $14);
  Stream.rwInteger(FTransferGoldMax, $15);
  Stream.rwInteger(FTransferManaMax, $16);
  Stream.rwInteger(FHeroLevelMax, $17);
  Stream.rwBool(FAlliedVictory, $18);
end;

constructor TAoWCampaignTransferSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FHeroes := THeroList.Create(nil);
  FItems := TItemList.Create(nil);
  FUnits := TUnitList.Create(nil);
  FSpells := TIntegerList.Create;
  FResearchPercentage := 50;
  FSelectedHeroes := TIntegerList.Create;
  FSelectedItems := TIntegerList.Create;
  FSelectedUnits := TIntegerList.Create;
  FSelectedSpheres := TByteList.Create;
end;

destructor TAoWCampaignTransferSettings.Destroy;
begin
  Clear;
  FHeroes.Free;
  FItems.Free;
  FUnits.Free;
  FSelectedSpheres.Free;
  FSpells.Free;
  { Original bug: the three selected-index lists are never freed. }
  inherited Destroy;
end;

procedure TAoWCampaignTransferSettings.Clear;
begin
  inherited Clear;
  if FLeader <> nil then
  begin
    FLeader.Release;
    FLeader := nil;
  end;
  FHeroes.Clear;
  FItems.Clear;
  FUnits.Clear;
  FSpells.Clear;
end;

procedure TAoWCampaignTransferSettings.ReadWrite(Stream: Engine.TEStorageStream);
var Leader: TLeader;
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FHeroes, $14);
  Stream.rwEObject(FItems, $15);
  Stream.rwEObject(FUnits, $16);
  Stream.rwStreamProc($17, FSpells.LoadFromStream, FSpells.SaveToStream);
  Stream.rwInteger(FResearchSpellID, $18);
  Stream.rwInteger(FResearchPointsLeft, $19);
  Stream.rwInteger(FResearchPercentage, $1A);
  if Stream.StorageMode * [smRead, smTextOnly, smTranslate] = [smRead] then
  begin
    Leader := nil;
    Stream.rwCreateEObject(TEObject(Leader), nil, $1B);
    SetLeader(Leader);
    if Leader <> nil then Leader.Release;
  end
  else Stream.rwCreateEObject(TEObject(FLeader), nil, $1B);
end;

procedure TAoWCampaignTransferSettings.SetLeader(Leader: TLeader);
begin
  if FLeader <> nil then FLeader.Release;
  FLeader := Leader;
  if FLeader <> nil then FLeader.AddRef;
end;

procedure TAoWCampaignTransferSettings.GenerateTransferUnits(Units: TUnitList);
var
  Level, I, Index, MaxUnits: Integer;
  LevelCounts: array[1..4] of Integer;
  Candidates: TList;
  AUnit: TAbstractUnit;
begin
  FUnits.Clear;
  Candidates := TList.Create;
  MaxUnits := 10;
  LevelCounts[1] := 8;
  LevelCounts[2] := 4;
  LevelCounts[3] := 1;
  if AoWEngine.FCampaign.FRaceHistory.Count > 2 then
    LevelCounts[4] := 1
  else LevelCounts[4] := 0;
  for Level := 4 downto 1 do
    if LevelCounts[Level] <> 0 then
    begin
      Candidates.Clear;
      for I := 0 to Units.Count - 1 do
      begin
        AUnit := Units.GetUnit(I);
        if (AUnit.GetUnitLevel = Level) and (FUnits.IndexOf(AUnit) = -1) then
          Candidates.Add(AUnit);
      end;
      { Original bug: the per-level quota is tested but never decremented. }
      while (LevelCounts[Level] <> 0) and (Candidates.Count <> 0) and
        (FUnits.Count <> MaxUnits) do
      begin
        Index := System.Random(Candidates.Count);
        FUnits.AddUnit(Candidates[Index]);
        Candidates.Delete(Index);
      end;
    end;
  Candidates.Free;
end;

procedure TAoWCampaignTransferSettings.Retrieve;
var
  Units: TUnitUserList;
  Player: Shortint;
  I, J: Integer;
  AUnit, NewUnit: TAbstractUnit;
  Hero: THero;
  Item: TItem;
begin
  Clear;
  if AoWHSMap <> nil then
  begin
    Units := TUnitUserList.Create(nil);
    Player := Shortint(TPlayerList(AoWHSMap.FPlayers).FLocalPlayers[0]);
    FLeader := TLeader(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FLeader.Copy(AoWEngine));
    FLeader.RemoveEnchantments;
    FLeader.RemoveHandicaps;
    FLeader.ExecuteCancelCasting;
    for J := FLeader.FInventory.Count - 1 downto 0 do
    begin
      Item := FLeader.FInventory.GetItem(J);
      if Item <> nil then
      begin
        Item := TItem(Item.Copy(AoWEngine));
        Item.SetOwner(FItems);
        Item.FItemID := FLeader.FUnitID;
        Item.Release;
      end;
    end;
    FLeader.FInventory.Clear;
    for J := FLeader.FHeroItems.Count - 1 downto 0 do
    begin
      Item := FLeader.FHeroItems.GetItem(J);
      if Item <> nil then
      begin
        Item := TItem(Item.Copy(AoWEngine));
        Item.SetOwner(FItems);
        Item.FItemID := FLeader.FUnitID;
        Item.Release;
      end;
    end;
    FLeader.FHeroItems.Clear;
    for I := 0 to TUnitControl(AoWHSMap.FUnitControl).GetCount - 1 do
    begin
      AUnit := TUnitControl(AoWHSMap.FUnitControl).GetUnit(I);
      if (AUnit.FPlayer = Player) and (AUnit.GetUnitType <> utMachine) and
        (AUnit.GetMoveTypes * [mtWalking, mtFlying] <> []) and
        not (AUnit is TLeader) and not AUnit.GetAbilityEnabled($9B) then
      begin
        if AUnit is THero then
        begin
          Hero := THero(AUnit.Copy(AoWEngine));
          Hero.SetOwner(FHeroes);
          Hero.RemoveEnchantments;
          Hero.RemoveHandicaps;
          Hero.ExecuteCancelCasting;
          for J := Hero.FInventory.Count - 1 downto 0 do
          begin
            Item := Hero.FInventory.GetItem(J);
            if Item <> nil then
            begin
              Item := TItem(Item.Copy(AoWEngine));
              Item.SetOwner(FItems);
              Item.FItemID := Hero.FUnitID;
              Item.Release;
            end;
          end;
          Hero.FInventory.Clear;
          for J := Hero.FHeroItems.Count - 1 downto 0 do
          begin
            Item := Hero.FHeroItems.GetItem(J);
            if Item <> nil then
            begin
              Item := TItem(Item.Copy(AoWEngine));
              Item.SetOwner(FItems);
              Item.FItemID := Hero.FUnitID;
              Item.Release;
            end;
          end;
          Hero.FHeroItems.Clear;
          Hero.Release;
        end
        else
        begin
          NewUnit := TAbstractUnit(AUnit.Copy(AoWEngine));
          NewUnit.RemoveEnchantments;
          NewUnit.RemoveHandicaps;
          Units.AddUnit(NewUnit);
          NewUnit.Release;
        end;
      end;
    end;
    FResearchPercentage := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchPercentage;
    FSpells.Assign(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FSpells);
    FResearchSpellID := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchSpellID;
    FResearchPointsLeft := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchPointsLeft;
    RandSeed := AoWHSMap.Random($FFFFFF);
    GenerateTransferUnits(Units);
    Units.Free;
  end;
end;

procedure TAoWCampaignTransferSettings.ClearSelection;
begin
  FSelectedHeroes.Clear;
  FSelectedItems.Clear;
  FSelectedUnits.Clear;
  FTransferPointsLeft := FTransferPointsMax;
  FSelectedTransferMana := 0;
  FSelectedTransferGold := 0;
  FSelectedSpheres.Clear;
end;

function TAoWCampaignTransferSettings.AddItem(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < FItems.Count) and
    (FSelectedItems.IndexOf(Index) = -1) and
    (FItems.GetItem(Index).GetCampaignTransferPoints <= FTransferPointsLeft) then
  begin
    Dec(FTransferPointsLeft, FItems.GetItem(Index).GetCampaignTransferPoints);
    FSelectedItems.Add(Index);
    Result := True;
  end
  else Result := False;
end;

function TAoWCampaignTransferSettings.DeleteItem(Index: Integer): Boolean;
begin
  if FSelectedItems.Remove(Index) <> -1 then
  begin
    Inc(FTransferPointsLeft, FItems.GetItem(Index).GetCampaignTransferPoints);
    Result := True;
  end
  else Result := False;
end;

function TAoWCampaignTransferSettings.AddHero(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < FHeroes.Count) and
    (FSelectedHeroes.IndexOf(Index) = -1) and
    (FHeroes.GetHero(Index).GetCampaignTransferPoints <= FTransferPointsLeft) then
  begin
    Dec(FTransferPointsLeft, FHeroes.GetHero(Index).GetCampaignTransferPoints);
    FSelectedHeroes.Add(Index);
    Result := True;
  end
  else Result := False;
end;

function TAoWCampaignTransferSettings.DeleteHero(Index: Integer): Boolean;
begin
  if FSelectedHeroes.Remove(Index) <> -1 then
  begin
    Inc(FTransferPointsLeft, FHeroes.GetHero(Index).GetCampaignTransferPoints);
    Result := True;
  end
  else Result := False;
end;

function TAoWCampaignTransferSettings.AddUnit(Index: Integer): Boolean;
begin
  if (Index >= 0) and (Index < FUnits.Count) and
    (FSelectedUnits.IndexOf(Index) = -1) and
    (FUnits.GetUnit(Index).GetCampaignTransferPoints <= FTransferPointsLeft) then
  begin
    Dec(FTransferPointsLeft, FUnits.GetUnit(Index).GetCampaignTransferPoints);
    FSelectedUnits.Add(Index);
    Result := True;
  end
  else Result := False;
end;

function TAoWCampaignTransferSettings.DeleteUnit(Index: Integer): Boolean;
begin
  if FSelectedUnits.Remove(Index) <> -1 then
  begin
    Inc(FTransferPointsLeft, FUnits.GetUnit(Index).GetCampaignTransferPoints);
    Result := True;
  end
  else Result := False;
end;

procedure TAoWCampaignTransferSettings.SetSelectedTransferGold(Value: Integer);
var Max: Integer;
begin
  Max := FSelectedTransferGold + FTransferPointsLeft;
  if Max > FTransferGoldMax then Max := FTransferGoldMax;
  if Value > Max then Value := Max;
  Dec(FTransferPointsLeft, Value - FSelectedTransferGold);
  FSelectedTransferGold := Value;
end;

procedure TAoWCampaignTransferSettings.SetSelectedTransferMana(Value: Integer);
var Max: Integer;
begin
  Max := FSelectedTransferMana + FTransferPointsLeft;
  if Max > FTransferManaMax then Max := FTransferManaMax;
  if Value > Max then Value := Max;
  Dec(FTransferPointsLeft, Value - FSelectedTransferMana);
  FSelectedTransferMana := Value;
end;

procedure TAoWCampaignTransferSettings.SetupSelection(const FileName: string);
var Map: TAoWHSMap;
begin
  ClearSelection;
  Map := TAoWHSMap(AoWEngine.CreatePreviewHSM(FileName));
  FTransferPointsMax := Map.FCampaignSettings.FTransferPointsMax;
  if AoWEngine.FCampaign.FDifficultyLevel = cdlEasy then
    FTransferPointsMax := Round(FTransferPointsMax * 1.5);
  if AoWEngine.FCampaign.FDifficultyLevel = cdlHard then
    FTransferPointsMax := Round(FTransferPointsMax * 0.5);
  FTransferGoldMax := Map.FCampaignSettings.FTransferGoldMax;
  FTransferManaMax := Map.FCampaignSettings.FTransferManaMax;
  FTransferPointsLeft := FTransferPointsMax;
  Map.Free;
end;

function CompareCampaignTransfer(const Item1, Item2: TQuadItem): Integer;
begin
  Result := Item2.C - Item1.C;
end;

procedure TAoWCampaignTransferSettings.AutoSelect;
var
  I, Points: Integer;
  Done: Boolean;
  Candidates: TQuadItemList;
begin
  ClearSelection;
  Candidates := TQuadItemList.Create;
  Done := False;
  while not Done do
  begin
    Candidates.Clear;
    for I := 0 to FHeroes.Count - 1 do
      if FSelectedHeroes.IndexOf(I) = -1 then
      begin
        Points := FHeroes.GetHero(I).GetCampaignTransferPoints;
        if Points <= FTransferPointsLeft then Candidates.AddABCD(0, I, Points, 0);
      end;
    for I := 0 to FItems.Count - 1 do
      if FSelectedItems.IndexOf(I) = -1 then
      begin
        Points := FItems.GetItem(I).GetCampaignTransferPoints;
        if Points <= FTransferPointsLeft then Candidates.AddABCD(1, I, Points, 0);
      end;
    for I := 0 to FUnits.Count - 1 do
      if FSelectedUnits.IndexOf(I) = -1 then
      begin
        Points := FUnits.GetUnit(I).GetCampaignTransferPoints;
        if Points <= FTransferPointsLeft then Candidates.AddABCD(2, I, Points, 0);
      end;
    Candidates.Sort(CompareCampaignTransfer);
    if Candidates.Count <> 0 then
      case Candidates[0].A of
        0: AddHero(Candidates[0].B);
        1: AddItem(Candidates[0].B);
        2: AddUnit(Candidates[0].B);
      end
    else Done := True;
  end;
  SetSelectedTransferGold(FTransferPointsMax);
  SetSelectedTransferMana(FTransferPointsMax);
  Candidates.Free;
end;

procedure TAoWCampaignTransferSettings.ExecuteSelection;
var
  Player: Shortint;
  I, J: Integer;
  X, Y, L: Shortint;
  Leader: TLeader;
  AUnit: TAbstractUnit;
  Hero: THero;
  Item: TItem;
begin
  if AoWHSMap <> nil then
  begin
    AoWHSMap.SynchroniseBegin;
    TPlayerList(AoWHSMap.FPlayers).Update;
    Player := TPlayerList(AoWHSMap.FPlayers).Count - 1;
    while (Player > 1) and
      (TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FPlayerType <> ptHuman) do
      Dec(Player);
    if AoWEngine.FCampaign.FCompletedScenarios.Count <> 0 then
      TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchPercentage := FResearchPercentage;
    TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchSpellID := FResearchSpellID;
    TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FResearchPointsLeft := FResearchPointsLeft;
    TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FSpells.Assign(FSpells);
    Inc(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FInitialGold, FSelectedTransferGold);
    Inc(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FExternalMana, FSelectedTransferMana);
    Leader := TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FLeader;
    Leader.GetLocation(X, Y, L);
    if FLeader <> nil then
    begin
      Leader.Deactivate;
      Leader.Assign(FLeader, AoWEngine);
      Leader.SetSpherePicksMax(Leader.GetSphereCount + FSelectedSpheres.Count);
      for I := 0 to FSelectedSpheres.Count - 1 do
        Leader.AddSphere(TMagicSphere(FSelectedSpheres[I]));
      for J := FSelectedItems.Count - 1 downto 0 do
      begin
        Item := FItems.GetItem(FSelectedItems[J]);
        if Leader.FUnitID = Item.FItemID then
        begin
          Item := TItem(FItems.GetItem(FSelectedItems[J]).Copy(AoWEngine));
          if Leader.AutoPlaceItem(Item) then FSelectedItems.Delete(J);
          Item.Release;
        end;
      end;
      Leader.FUnitID := -1;
      Leader.SetPlayer(Player);
      Leader.Activate;
    end;
    for I := FSelectedUnits.Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(FUnits.GetUnit(FSelectedUnits[I]).Copy(AoWEngine));
      AUnit.FUnitID := -1;
      AUnit.Place(X, Y, L, Player, [pmScanArea]);
      AUnit.Release;
    end;
    for I := FSelectedHeroes.Count - 1 downto 0 do
    begin
      Hero := THero(FHeroes.GetHero(FSelectedHeroes[I]).Copy(AoWEngine));
      for J := FSelectedItems.Count - 1 downto 0 do
      begin
        Item := FItems.GetItem(FSelectedItems[J]);
        if Hero.FUnitID = Item.FItemID then
        begin
          Item := TItem(FItems.GetItem(FSelectedItems[J]).Copy(AoWEngine));
          if Hero.AutoPlaceItem(Item) then FSelectedItems.Delete(J);
          Item.Release;
        end;
      end;
      Hero.FUnitID := -1;
      Hero.FMode := Hero.FMode + [hmSkipLibraryUpdate];
      Hero.Place(X, Y, L, Player, [pmScanArea]);
      Hero.FMode := Hero.FMode - [hmSkipLibraryUpdate];
      Hero.Release;
    end;
    for I := FSelectedItems.Count - 1 downto 0 do
    begin
      Item := TItem(FItems.GetItem(FSelectedItems[I]).Copy(AoWEngine));
      AoWHSMap.FItemControl.RegisterItem(Item);
      Item.PlaceOnMap(AoWHSMap, X, Y, L);
      Item.Release;
    end;
    AoWHSMap.SynchroniseEnd;
  end;
end;

constructor TAoWCampaignScenario.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

destructor TAoWCampaignScenario.Destroy;
begin inherited Destroy; end;

class function TAoWCampaignScenario.ClassID: Integer;
begin Result := $20204; end;

procedure TAoWCampaignScenario.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FID, 9);
  if not (smTextOnly in Stream.StorageMode) then
  begin
    Stream.rwString(FName, 10);
    Stream.rwString(FFileName, 11);
  end;
end;

function TAoWCampaignScenarioList.GetScenario(Index: Integer): TAoWCampaignScenario;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TAoWCampaignScenario(FChildren.List^[Index])
  else Result := nil;
end;

function TAoWCampaignScenarioList.CreateUniqueID: Integer;
begin
  Result := 1;
  while IndexOfID(Result) <> -1 do Inc(Result);
end;

function TAoWCampaignScenarioList.IndexOfID(ID: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAoWCampaignScenario(FChildren.List^[Result]).FID = ID then Exit;
  end;
  Result := -1;
end;

function TAoWCampaignScenarioList.FindID(ID: Integer): TAoWCampaignScenario;
var Index: Integer;
begin
  Index := IndexOfID(ID);
  if Index <> -1 then Result := TAoWCampaignScenario(FChildren.List^[Index])
  else Result := nil;
end;

constructor TAoWCampaign.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FStream := TMemoryStream.Create;
  FTransferSettings := TAoWCampaignTransferSettings.Create(nil);
  FScenarios := TAoWCampaignScenarioList.Create(nil);
  FCompletedScenarios := TIntegerList.Create;
  FRaceHistory := TByteList.Create;
  FCurrentScenarioID := -1;
  FNextScenarioID := -1;
  FScenarioStarted := False;
  FPlayMode := pmSimultaneous;
  FDifficultyLevel := cdlNormal;
end;

destructor TAoWCampaign.Destroy;
begin
  FStream.Free;
  FTransferSettings.Free;
  FScenarios.Free;
  FCompletedScenarios.Free;
  FRaceHistory.Free;
  inherited Destroy;
end;

procedure TAoWCampaign.Clear;
begin
  inherited Clear;
  FStream.Clear;
  FTransferSettings.Clear;
  FScenarios.Clear;
  FCurrentScenarioID := -1;
  FCompletedScenarios.Clear;
  FRaceHistory.Clear;
end;

function TAoWCampaign.CreateScenario: TAoWCampaignScenario;
begin Result := TAoWCampaignScenario.Create(nil); end;

function TAoWCampaign.AddScenario: TAoWCampaignScenario;
begin
  Result := CreateScenario;
  Result.FID := FScenarios.CreateUniqueID;
  Result.SetOwner(FScenarios);
end;

function TAoWCampaign.GetContainsMap: Boolean;
begin Result := FStream.Size <> 0; end;

procedure TAoWCampaign.ReadWrite(Stream: Engine.TEStorageStream);
var Size, I: Integer;
begin
  inherited ReadWrite(Stream);
  if not (smTextOnly in Stream.StorageMode) then
    if smRead in Stream.StorageMode then
    begin
      Stream.rwInteger(Size, 5);
      FStream.Size := Size;
      Stream.rwData(FStream.Memory^, Size, 6);
    end
    else
    begin
      Size := FStream.Size;
      Stream.rwInteger(Size, 5);
      Stream.rwData(FStream.Memory^, Size, 6);
    end;
  Stream.rwEObject(FTransferSettings, 7);
  Stream.rwEObject(FScenarios, 10);
  Stream.rwString(FName, 12);
  Stream.rwInteger(FCurrentScenarioID, 13);
  Stream.rwStreamProc(14, FCompletedScenarios.LoadFromStream, FCompletedScenarios.SaveToStream);
  Stream.rwBool(FScenarioStarted, 15);
  Stream.rwStreamProc(16, FRaceHistory.LoadFromStream, FRaceHistory.SaveToStream);
  Stream.rwData(FPlayMode, SizeOf(FPlayMode), 17);
  Stream.rwData(FDifficultyLevel, SizeOf(FDifficultyLevel), 19);
  if not (smTextOnly in Stream.StorageMode) and (smRead in Stream.StorageMode) then
    for I := 0 to FScenarios.Count - 1 do
      if FScenarios.GetScenario(I).FID = 0 then
        FScenarios.GetScenario(I).FID := FScenarios.CreateUniqueID;
  if (smRead in Stream.StorageMode) and not (smTextOnly in Stream.StorageMode) and
    (FCompletedScenarios.Count = 0) and not FScenarioStarted then
    FPlayMode := pmSimultaneous;
end;

procedure TAoWCampaign.SelectNextScenario(ID: Integer);
begin FNextScenarioID := ID; end;

procedure TAoWCampaign.ResetNextScenario;
begin FNextScenarioID := -1; end;

procedure TAoWCampaign.StartScenario(ID: Integer; Progress: TProgressEvent);
begin
  FStream.Clear;
  FNextScenarioID := -1;
  FCurrentScenarioID := ID;
end;

procedure TAoWCampaign.SetupScenario; { Near miss: loop registers and stack slots differ after three variants. }
var
  Player: Shortint;
  I, J, Level, R: Integer;
  Spell: TSpell;
  Race: TRace;
  Relation: Byte;
begin
  Player := AoWHSMap.FPlayers.Count - 1;
  while (Player > 1) and (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) do
    Dec(Player);
  Level := 1 + FCompletedScenarios.Count div 4;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> Player then
      for J := 0 to AoWHSSet.FSpellControl.GetCount - 1 do
      begin
        Spell := AoWHSSet.FSpellControl.GetSpell(J);
        if (Spell <> nil) and (Spell.FSpellLevel <= Level) and
          (Spell.FSpellLevel <= AoWHSMap.FPlayers.GetPlayers(I).FLeader.GetSpherePicks(Spell.FMagicSphere)) then
          if AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FSpells.IndexOf(J) = -1 then
            AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FSpells.Add(J);
      end;
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType <> ptHuman) and
      (AoWHSMap.FPlayers.GetDiplomaticRelation(I, Player) <> drAlliance) then
    begin
      if FDifficultyLevel = cdlEasy then
        case AoWHSMap.FPlayers.GetPlayers(I).FPlayerType of
          ptCPU2: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU1;
          ptCPU3: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU2;
          ptCPU4: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU3;
          ptCPU5: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU3;
        end;
      if FDifficultyLevel = cdlHard then
        case AoWHSMap.FPlayers.GetPlayers(I).FPlayerType of
          ptCPU1: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU3;
          ptCPU2: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU4;
          ptCPU3: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU5;
          ptCPU4: AoWHSMap.FPlayers.GetPlayers(I).FPlayerType := ptCPU5;
        end;
    end;
  AoWHSMap.SetupPlayerControl(FPlayMode, pcLocal);
  for R := 0 to AoWHSMap.FRaces.Count - 1 do
    if AoWHSMap.FRaces.GetRace(R) <> nil then
    begin
      Race := AoWHSMap.FRaces.GetRace(R);
      if Race <> nil then
        for I := 0 to 11 do
          if (((FRaceHistory.IndexOf(I) <> -1) or
            (I = AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace)) and
            (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace = R)) or
            (((FRaceHistory.IndexOf(Byte(R)) <> -1) or
            (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace = R)) and
            (I = AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace)) then
          begin
            Relation := Race.FDefaultRelations[I];
            case Relation of
              0: Relation := 3;
              1: Relation := 3;
              2: Relation := 4;
              3: Relation := 4;
            end;
            Race.FDefaultRelations[I] := Relation;
          end;
    end;
  AoWHSMap.FAlliedVictory := AoWHSMap.FCampaignSettings.FAlliedVictory;
  FTransferSettings.ExecuteSelection;
  FScenarioStarted := True;
end;

function TAoWCampaign.GetAutoSaveFileName(Auto: TCampaignAutoSaveType): string;
begin Result := AoWHSMap.FMapName + '.acg'; end;

procedure TAoWCampaign.FinishScenario;
var Player: Shortint; FileName: string;
begin
  FScenarioStarted := False;
  FCompletedScenarios.Add(FCurrentScenarioID);
  FTransferSettings.Retrieve;
  FStream.Clear;
  Player := AoWHSMap.FPlayers.Count - 1;
  while (Player > 1) and (AoWHSMap.FPlayers.GetPlayers(Player).FPlayerType <> ptHuman) do
    Dec(Player);
  if FRaceHistory.IndexOf(Byte(AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace)) = -1 then
    FRaceHistory.Add(Byte(AoWHSMap.FPlayers.GetPlayers(Player).FPlayerRace));
  FileName := GetAutoSaveFileName(casScenarioFinished);
  AoWEngine.SaveCampaign(AoWEngine.StartupDirectory + 'Save\' + FileName);
end;

procedure TAoWCampaign.RestartScenario;
begin
  if FCompletedScenarios.Count <> 0 then
    FCurrentScenarioID := FCompletedScenarios[FCompletedScenarios.Count - 1]
  else FCurrentScenarioID := 0;
  FScenarioStarted := False;
  FStream.Clear;
end;

constructor TSMTPEventLog.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMessage := TStringList.Create;
end;

destructor TSMTPEventLog.Destroy;
begin FMessage.Free; inherited Destroy; end;

class function TRestartGameEventLog.ClassID: Integer;
begin Result := $202F7; end;

function TRestartGameEventLog.GetText: string;
begin Result := TranslateRStr(GameRestartedRStr); end;

function TRestartGameEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  if Trigger <> etNewTurn then Result := inherited Execute(Mode, Trigger, Done)
  else Result := False;
end;

class function TEmailGame.ClassID: Integer;
begin Result := $21700; end;

procedure TEmailGame.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, $14);
  Stream.rwInteger(FUniqueLocalID, $15);
  Stream.rwInteger(FUniqueID, $16);
  Stream.rwString(FEmailAddress, $17);
  Stream.rwInteger(FSecurityID, $18);
end;

function TEmailGameList.GetEmailGames(Index: Integer): TEmailGame;
begin Result := TEmailGame(FChildren.List^[Index]); end;

function TEmailGameList.IndexOfUniqueLocalID(ID: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TEmailGame(FChildren.List^[Result]).FUniqueLocalID = ID then Exit;
  end;
  Result := -1;
end;

constructor TEmailGameControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FGames := TEmailGameList.Create(nil);
end;

destructor TEmailGameControl.Destroy;
begin FGames.Free; inherited Destroy; end;

function TEmailGameControl.CreateUniqueLocalID: Integer;
begin
  Result := 1;
  while FGames.IndexOfUniqueLocalID(Result) <> -1 do Inc(Result);
end;

procedure TEmailGameControl.Load;
var FileName: string;
begin
  FGames.Clear;
  FileName := AoWEngine.StartupDirectory + 'EmailIn\' + 'egames.pfs';
  if FileExists(FileName) then
    if GetFileCRC32(FileName) = AoWEngine.FRegistry.GetEmailGamesCRC then
      AoWEngine.ReadFromFile(FileName, FGames, nil);
end;

procedure TEmailGameControl.Save;
var FileName: string;
begin
  try
    FileName := AoWEngine.StartupDirectory + 'EmailIn\' + 'egames.pfs';
    AoWEngine.WriteToFile(AoWEngine.StartupDirectory + 'EmailIn\' + 'egames.pfs', FGames, nil);
    AoWEngine.FRegistry.SetEmailGamesCRC(GetFileCRC32(FileName));
  except
  end;
end;

function TEmailGameControl.FindEmailGame(Game: TEmailGame): TEmailGame;
var Index: Integer;
begin
  Index := FGames.IndexOfUniqueLocalID(Game.FUniqueLocalID);
  if (Index <> -1) and (Game.FUniqueID <> 0) and
    (FGames.GetEmailGames(Index).FUniqueID = Game.FUniqueID) then
    Result := FGames.GetEmailGames(Index)
  else Result := nil;
end;

function TEmailGameControl.EmailGameRestarted(Game: TEmailGame): Boolean;
var LocalGame: TEmailGame;
begin
  if Game.FSecurityID <> 0 then
  begin
    LocalGame := FindEmailGame(Game);
    Result := (LocalGame = nil) or (Game.FSecurityID <> LocalGame.FSecurityID);
  end
  else Result := False;
end;

function TEmailGameControl.GenerateSecurityID: Integer;
begin Result := System.Random(GetElapsedMilliSeconds and $FFFFFF) + 1; end;

function TEmailGameControl.UpdateGame(Game: TEmailGame): Boolean;
var LocalGame: TEmailGame;
begin
  LocalGame := FindEmailGame(Game);
  if LocalGame <> nil then
  begin
    LocalGame.FLastDay := Game.FLastDay;
    LocalGame.FSecurityID := GenerateSecurityID;
    Game.FSecurityID := LocalGame.FSecurityID;
    Save;
    Result := True;
  end
  else Result := False;
end;

function TEmailGameControl.CreateEmailGame(Name, EmailAddress: string): TEmailGame;
begin
  Result := TEmailGame.Create(nil);
  Result.FEmailAddress := EmailAddress;
  Result.FUniqueLocalID := CreateUniqueLocalID;
  Result.FUniqueID := System.Random(GetElapsedMilliSeconds and $FFFFFF) + 1;
  Result.FSecurityID := GenerateSecurityID;
  Result.FName := Name;
  Result.SetOwner(FGames);
  Save;
end;

procedure TEmailGameControl.ValidateIncommingGame(const FileName: string; var Destination: string); { Near miss: Map/overwrite spills and string temporaries differ after three variants. }
var
  Map, PreviousMap: TAoWHSMap;
  LocalGame: TEmailGame;
  Name: string;
  I: Integer;
  Overwrite: Boolean;
begin
  try
    Destination := '';
    Overwrite := False;
    Map := TAoWHSMap(AoWEngine.CreatePreviewHSM(FileName));
    if (Map <> nil) and (Map.FConnectionType = pcEmail) and
      (Map.FCurrentPlayer > 0) and (Map.FCurrentPlayer < Map.FPlayers.Count) and
      (pbsNewTurn in Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FStatus) then
      if CompareText(Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame.FEmailAddress,
        AoWEngine.FRegistry.GetLocalEmailAddress) = 0 then
      begin
        LocalGame := FindEmailGame(Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame);
        if LocalGame <> nil then
        begin
          if LocalGame.FLastDay < Map.FDay then
          begin
            Name := Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame.FName;
            if FileExists(AoWEngine.StartupDirectory + 'EmailIn\' + Name + '.asg') then
            begin
              PreviousMap := TAoWHSMap(AoWEngine.CreatePreviewHSM(
                AoWEngine.StartupDirectory + 'EmailIn\' + Name + '.asg'));
              if PreviousMap <> nil then
              begin
                { Original bug: the previous map's player is checked against the new map's count. }
                if (PreviousMap.FCurrentPlayer > 0) and
                  (PreviousMap.FCurrentPlayer < Map.FPlayers.Count) then
                  if (PreviousMap.FPlayers.GetPlayers(PreviousMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FUniqueLocalID =
                    Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame.FUniqueLocalID) and
                    (PreviousMap.FPlayers.GetPlayers(PreviousMap.FCurrentPlayer).FPBEMSettings.FEmailGame.FUniqueID =
                    Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame.FUniqueID) then
                    Overwrite := True;
                PreviousMap.Free;
              end;
            end;
          end;
        end
        else Name := Map.FPlayers.GetPlayers(Map.FCurrentPlayer).FPBEMSettings.FEmailGame.FName;
        if Name <> '' then
        begin
          I := 0;
          Destination := AoWEngine.StartupDirectory + 'EmailIn\' + Name + '.asg';
          while not Overwrite and FileExists(Destination) do
          begin
            Inc(I);
            Destination := AoWEngine.StartupDirectory + 'EmailIn\' + Name + IntToStr(I) + '.asg';
          end;
        end;
      end;
    Map.Free;
  except
  end;
end;

