{ P5: AI, diplomacy, campaign and turn movement. }

type
  { ABI views for the still-unmarked EventLog/P2 override declarations.
    Never instantiated; EventLog size $18, JoinEventLog size $3C. }
  TP5EventLogABI = class(TEObject)
    FReserved: array[0..15] of Byte;
    procedure Slot4C; virtual; abstract;
    procedure Slot50; virtual; abstract;
    procedure Slot54; virtual; abstract;
    procedure Slot58; virtual; abstract;
    procedure Slot5C; virtual; abstract;
    procedure Slot60; virtual; abstract;
    procedure Slot64; virtual; abstract;
    procedure Slot68; virtual; abstract;
    procedure Slot6C; virtual; abstract;
    function Execute(Immediate, Auto: Boolean; Data, Done: Pointer): Boolean;
      virtual; abstract; { $70 }
  end;


resourcestring
  { needs: P1 NotEnoughGoldRStr (5570719C, string resource 65215). }
  P5NotEnoughGoldRStr = 'Not enough gold.';








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
  Stream.rwByte(FPlayer, $23);
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
  Stream.rwByte(FX, $28);
  Stream.rwByte(FY, $29);
  Stream.rwByte(FL, $2A);
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

function TNegotiateRequestEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
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
      if Msg.Param[1] <> 0 then Log.Execute(1, etEvent, nil);
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

{ needs: remaining P1 draft return types/parameters; typed tail adapters retain the register ABI. }
procedure P5PlayerSeen(Player: TPlayer; Other: Byte);
asm
  JMP TPlayer.PlayerSeen
end;

function P5DiplomaticRelation(Players: TPlayerList; Source, Target: Byte): TDiplomaticRelation;
asm
  JMP TPlayerList.GetDiplomaticRelation
end;





function P5FirstDaySeen(Player: TPlayer; Other: Byte): Integer;
asm
  JMP TPlayer.GetFirstDaySeen
end;



const P5DefaultMsgProc: Pointer = @RetrieveDefaultDiplomaticActionMessage;

procedure P5DefaultDiplomaticMessage(Source, Target, Other: Byte; Action: TDiplomaticActionType; Reaction: TDiplomaticActionReaction; Text: TStrings);
asm
  POP EBP
  JMP DWORD PTR [P5DefaultMsgProc]
end;

function P5RelationCount(Players: TPlayerList; Player: Byte; Relations: TDiplomaticRelations): Integer;
asm
  JMP TPlayerList.GetDiplomaticRelationCount
end;


function P5Format(S: string; const Args: array of const): string;
asm
  POP EBP
  JMP Format
end;

resourcestring
  P5DeclareWarRStr = 'Declare war';
  P5OfferPeaceRStr = 'Offer peace';
  P5ProposeAllianceRStr = 'Propose alliance';
  P5SendMessageRStr = 'Send Message';
  P5ThreatenToAttackRStr = 'Threaten to attack';
  P5MakeTributeRStr = 'Make tribute';
  P5BreakAllianceRStr = 'Break alliance';
  P5SendMessageAsXRStr = 'Send message as %s';
  P5SuggestAllianceBreakWithYRStr = 'Suggest alliance break with %s';
  P5SuggestWarWithYRStr = 'Suggest war with %s';
  P5NotEnoughManaRStr = 'Not enough mana.';
  P5NoGoldManaSpecifiedRStr = 'No gold/mana specified';
  P5WarDeclaredRStr = 'War declared';
  P5AllianceBrokenRStr = 'Alliance broken';
  P5MessageSentRStr = 'Message sent';

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
    if (Player.FEndTurn = True) and (I <> Exclude) and
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

procedure P5SetDiplomaticRelation(Players: TPlayerList; Source, Target: Byte; Relation: TDiplomaticRelation);
asm
  POP EBP
  JMP TPlayerList.SetDiplomaticRelation
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
  Stream.rwByte(FSource, $14);
  Stream.rwByte(FTarget, $15);
  Stream.rwByte(FOtherPlayer, $16);
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
      TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).F_PlayerMagicControl_24 + FEscrowMana);
      FEscrowGold := 0;
      FEscrowMana := 0;
    end;
  end;
end;

function TDiplomaticAction.CreateEventLog: TDiplomaticActionEventLog;
var Log: TDiplomaticActionEventLog;
begin
  Log := TDiplomaticActionEventLog.Create(nil);
  Log.F_EventLog_08 := AoWHSMap.FDay;
  Log.SetDiplomaticAction(Self);
  Result := Log;
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
          RandSeed := (AoWHSMap.F_AoWHSMap_22C + AoWHSMap.FDay + Shortint(FSource) + Shortint(FTarget)) shr 2;
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

procedure TDiplomaticAction.ExecuteAccept(TE: TDiplomaticActionTE);
var
  I: Integer;
  Log: TDiplomaticActionEventLog;
  Action: TDiplomaticAction;
begin
  FReaction := darAccept;
  P5DefaultDiplomaticMessage(FSource, FTarget, FOtherPlayer, FActionType, FReaction, FMessage);
  TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).SetGems(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FGems + FEscrowGold);
  FEscrowGold := 0;
  TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FMagicControl).F_PlayerMagicControl_24 + FEscrowMana);
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
  TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).F_PlayerMagicControl_24 + FEscrowMana);
  FEscrowMana := 0;
  P5DefaultDiplomaticMessage(FSource, FTarget, FOtherPlayer, FActionType, FReaction, FMessage);
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
    TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).SetMana(TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).F_PlayerMagicControl_24 - FMana);
    case FActionType of
      daOfferPeace..daMakeTribute, daSendMessageAsY..daDeclareWarToY:
      begin
        P5PlayerSeen(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)), FSource);
        if Shortint(FSource) = AoWHSMap.FSeatedPlayer then AoWHSMap.ShowMessage(TranslateRStr(P5MessageSentRStr));
        Log := CreateEventLog;
        TEventLogbook(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FTarget)).FEventLogbook).AddEvent(Log);
        if Shortint(FTarget) = AoWHSMap.FSeatedPlayer then TP5EventLogABI(Log).Execute(False, False, nil, nil);
        Log.Release;
        TEventList(AoWHSMap.F_AoWHSMap_1E8).TriggerNotifyEvents(Self);
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
    if TPlayerMagicControl(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Shortint(FSource)).FMagicControl).F_PlayerMagicControl_24 >= FMana then
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

const
  P5RaceColors: array[0..12] of TColor = ($00E03430, $0066A4FF, $00AFCB2C, $00FEDA87, $0060EF41, $0015FDFD, $00A5C1E4, $00F7FFFD, $00B370BC, $005050E9, $004266BB, $00797898, $00A8A8A8);

resourcestring
  P5WarRStr = 'War';
  P5PeaceOfferRStr = 'Peace offer';
  P5XRejectedRStr = '%s rejected';
  P5XAcceptedRStr = '%s accepted';
  P5XIgnoredRStr = '%s ignored';
  P5PeaceRStr = 'Peace';
  P5AllianceProposalRStr = 'Alliance proposal';
  P5MadeAllianceRStr = 'Made alliance';
  P5MessageRStr = 'Message';
  P5ThreatRStr = 'Threat';
  P5TributeRStr = 'Tribute';
  P5BreakAllianceSuggestionRStr = 'Break alliance suggestion';
  P5DeclareWarSuggestionRStr = 'Declare war suggestion';





function P5DiplomaticExecute(Log: TDiplomaticActionEventLog; Immediate: Boolean;
  Trigger: TExecuteTrigger; Data, Done: Pointer): Boolean;
begin
  Result := Trigger = etUser;
  if (Shortint(Log.FAction.FTarget) = AoWHSMap.FSeatedPlayer) or
    (Shortint(Log.FAction.FSource) = AoWHSMap.FSeatedPlayer) then
  begin
    Result := Result or ((AoWHSMap.FPlayMode = pmTurn) and
      (wpDiplomacy in TAoWRegistry(AoWEngine.F_AoWEngine_5C).GetClassicWindowPopupEvents) and (Trigger = etNewTurn));
    Result := Result or ((AoWHSMap.FPlayMode = pmSimultaneous) and
      (wpDiplomacy in TAoWRegistry(AoWEngine.F_AoWEngine_5C).GetSimultaneousWindowPopupEvents));
  end;
  Result := Result and ((Trigger = etUser) or (Log.FAction.FReaction <> darIgnore));
  if Result then
  begin
    AoWHSMap.TriggerExecuteEventLog(Log, Immediate, TExecuteDoneEvent(Pointer(@Done)^));
    Result := True;
  end
  else Result := False;
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

procedure TDiplomaticActionEventLog.PlayLoggedSFX(A1: Integer);
begin
  case FAction.FActionType of
    daDeclareWar, daThreatenToAttack, daBreakAlliance: Sound.PlaySample('SFX\EVENTS\MESSAGE.WAV');
    daOfferPeace, daProposeAlliance, daMakeTribute: Sound.PlaySample('SFX\EVENTS\MESSAGE2.WAV');
  else Sound.PlaySample('SFX\EVENTS\MESSAGE.WAV');
  end;
end;

procedure TDiplomaticActionEventLog.NotifyLogged(A1: Integer);
var Action: TDiplomaticAction;
begin
  inherited NotifyLogged(A1);
  Action := FAction;
  if Action <> nil then Action.FEventLogID := F_EventLog_0C;
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

function TDiplomaticActionEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  POP EBP
  JMP P5DiplomaticExecute
end;


constructor TDiplomacyAIPA.Create(AOwner: TECustomNode);
begin inherited Create(AOwner); end;

destructor TDiplomacyAIPA.Destroy;
begin inherited Destroy; end;

procedure TDiplomacyAIPA.Priority;
asm MOV EAX, 14 end;

procedure TDiplomacyAIPA.Activate(A1: Integer; A2: Integer);
begin inherited Activate(A1, A2); FNextPlayer := 0; end;

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

function TDiplomacyAIPA.ExecuteDiplomacy(Player: Shortint): Boolean;
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
        RandSeed := AoWHSMap.F_AoWHSMap_22C + AoWHSMap.FDay + Source;
        Index := System.Random(IdealWar.Count);
        if IdealWar[Index] = Player then Action := CreateDA(daDeclareWar, Player, -1, -1);
      end
      else if TAIPlayerControl(FControl).CanProposeAlliance(Player) then
      begin
        RandSeed := (AoWHSMap.F_AoWHSMap_22C + AoWHSMap.FDay + Source) shr 2;
        if System.Random(100) < 30 then Action := CreateDA(daProposeAlliance, Player, -1, 10);
      end;
    drAlliance:
      if not TAIPlayerControl(FControl).CanOfferPeace(Player) and (IdealWar.IndexOf(Player) <> -1) then
      begin
        RandSeed := AoWHSMap.F_AoWHSMap_22C + AoWHSMap.FDay + Source + 1;
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
    S := TPlayerList(AoWHSMap.FPlayers).GetPlayers(IdealWar[I]).GetName;
    AoWEngine.OutputDebugMessage(AIDID, S);
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
  FNextScenarioID := -1;
  FFlag := False;
end;

procedure TAoWMapCampaignSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FTransferPointsMax, $14);
  Stream.rwInteger(FTransferGoldMax, $15);
  Stream.rwInteger(FTransferManaMax, $16);
  Stream.rwInteger(FNextScenarioID, $17);
  Stream.rwBool(FFlag, $18);
end;

constructor TAoWCampaignTransferSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWCampaignTransferSettings.Destroy;
begin end;

procedure TAoWCampaignTransferSettings.Clear;
begin end;

procedure TAoWCampaignTransferSettings.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWCampaignTransferSettings.SetLeader(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.GenerateTransferUnits(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.Retrieve;
begin end;

procedure TAoWCampaignTransferSettings.ClearSelection;
begin end;

procedure TAoWCampaignTransferSettings.AddItem(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.DeleteItem(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.AddHero(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.DeleteHero(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.AddUnit(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.DeleteUnit(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.SetSelectedTransferGold(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.SetSelectedTransferMana(A1: Integer);
begin end;

procedure TAoWCampaignTransferSettings.SetupSelection(A1: Integer; A2: Integer);
begin end;

procedure TAoWCampaignTransferSettings.AutoSelect;
begin end;

procedure TAoWCampaignTransferSettings.ExecuteSelection;
begin end;

constructor TAoWCampaignScenario.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWCampaignScenario.Destroy;
begin end;

class function TAoWCampaignScenario.ClassID: Integer;
begin Result := 0; end;

procedure TAoWCampaignScenario.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWCampaignScenarioList.GetScenario(A1: Integer);
begin end;

procedure TAoWCampaignScenarioList.CreateUniqueID;
begin end;

procedure TAoWCampaignScenarioList.IndexOfID(A1: Integer);
begin end;

procedure TAoWCampaignScenarioList.FindID;
begin end;

constructor TAoWCampaign.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWCampaign.Destroy;
begin end;

procedure TAoWCampaign.Clear;
begin end;

procedure TAoWCampaign.CreateScenario;
begin end;

procedure TAoWCampaign.AddScenario;
begin end;

procedure TAoWCampaign.GetContainsMap;
begin end;

procedure TAoWCampaign.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAoWCampaign.SelectNextScenario(A1: Integer);
begin end;

procedure TAoWCampaign.ResetNextScenario;
begin end;

procedure TAoWCampaign.StartScenario(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWCampaign.SetupScenario;
begin end;

procedure TAoWCampaign.GetAutoSaveFileName(A1: Integer; A2: Integer);
begin end;

procedure TAoWCampaign.FinishScenario;
begin end;

procedure TAoWCampaign.RestartScenario;
begin end;

constructor TSMTPEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSMTPEventLog.Destroy;
begin end;

class function TRestartGameEventLog.ClassID: Integer;
begin Result := 0; end;

function TRestartGameEventLog.GetText: string;
begin end;

function TRestartGameEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

class function TEmailGame.ClassID: Integer;
begin Result := 0; end;

procedure TEmailGame.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TEmailGameList.GetEmailGames(A1: Integer);
begin end;

procedure TEmailGameList.IndexOfUniqueLocalID(A1: Integer);
begin end;

constructor TEmailGameControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TEmailGameControl.Destroy;
begin end;

procedure TEmailGameControl.CreateUniqueLocalID;
begin end;

procedure TEmailGameControl.Load;
begin end;

procedure TEmailGameControl.Save;
begin end;

procedure TEmailGameControl.FindEmailGame(A1: Integer);
begin end;

procedure TEmailGameControl.EmailGameRestarted(A1: Integer);
begin end;

procedure TEmailGameControl.GenerateSecurityID;
begin end;

procedure TEmailGameControl.UpdateGame(A1: Integer);
begin end;

procedure TEmailGameControl.CreateEmailGame(A1: Integer; A2: Integer);
begin end;

procedure TEmailGameControl.ValidateIncommingGame(A1: Integer; A2: Integer);
begin end;

procedure TAIPlayerAction.SupportedPhases;
begin end;

procedure TAIPlayerAction.Setup(A1: Integer; A2: Integer);
begin end;

function TAIPlayerAction.Process: Boolean;
begin
  Inc(FProcessCycles);
  Result := False;
end;

procedure TAIPlayerAction.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIPlayerAction.Deactivate;
begin end;

procedure TAIPlayerActionList.GetActions(A1: Integer);
begin end;

procedure TAIPlayerActionList.IndexOf;
begin end;

constructor TAIPlayerActionManager.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIPlayerActionManager.Destroy;
begin end;

procedure TAIPlayerActionManager.GetCount;
begin end;

procedure TAIPlayerActionManager.GetRegisteredClasses(A1: Integer);
begin end;

procedure TAIPlayerActionManager.RegisterClasses(A1: Integer; A2: Integer);
begin end;

procedure TAIPlayerActionManager.UnRegisterClasses(A1: Integer; A2: Integer);
begin end;

constructor TAIPlayerControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIPlayerControl.Destroy;
begin end;

procedure TAIPlayerControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAIPlayerControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAIPlayerControl.ListAvailableTransporters(A1: Integer);
begin end;

procedure TAIPlayerControl.UnitIndexToPriority(A1: Integer);
begin end;

procedure TAIPlayerControl.Reset;
begin end;

procedure TAIPlayerControl.SetupProcessPhase(A1: Integer);
begin end;

procedure TAIPlayerControl.GetProcessCyclesMax;
begin end;

procedure TAIPlayerControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIPlayerControl.Deactivate;
begin end;

procedure TAIPlayerControl.GetRandomGroupBehavior;
begin end;

procedure TAIPlayerControl.UpdateSkirmishGroups;
begin end;

procedure TAIPlayerControl.ActivateAction(A1: Integer);
begin end;

procedure TAIPlayerControl.DeactivateAction;
begin end;

procedure TAIPlayerControl.ListPeaceWarUnknownPlayers(Peace, War, Unknown: TByteList);
begin end;

procedure TAIPlayerControl.ListIdealPeaceWarPlayers(Peace, War: TByteList);
begin end;

function TAIPlayerControl.CanOfferPeace(Player: Byte): Boolean;
begin Result := False; end;

function TAIPlayerControl.CanDeclareWar(Player: Byte): Boolean;
begin Result := False; end;

function TAIPlayerControl.CanProposeAlliance(Player: Byte): Boolean;
begin Result := False; end;

procedure TAIPlayerControl.Process(A1: Integer);
begin end;

constructor TAIExecuter.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIExecuter.Destroy;
begin end;

procedure TAIExecuter.RequestProcessTime(A1: Integer);
begin end;

procedure TAIExecuter.GetProcessTimeLeft;
begin end;

procedure TAIExecuter.GetProcessTimeElapsed;
begin end;

procedure TAIExecuter.UseProcessTime(A1: Integer);
begin end;

procedure TAIExecuter.ActivatePlayer(A1: Integer);
begin end;

procedure TAIExecuter.DeactivatePlayer(Player: Shortint);
begin end;

procedure TAIExecuter.TokenControlDoneEvent;
begin end;

procedure TAIExecuter.Lock;
begin end;

procedure TAIExecuter.Unlock;
begin end;

procedure TAIExecuter.CaptureTokenCycles(A1: Integer);
begin end;

procedure TAIExecuter.TokenCyclesCaptured;
begin end;

procedure TAIExecuter.Process(A1: Integer; A2: Integer);
begin end;

procedure TInitializeAIPA.Priority;
begin end;

function TInitializeAIPA.Process: Boolean;
begin Result := False; end;

destructor TEndTurnAIPA.Destroy;
begin end;

procedure TEndTurnAIPA.Priority;
begin end;

function TEndTurnAIPA.Process: Boolean;
begin Result := False; end;

constructor TGroupControlAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TGroupControlAIPA.Destroy;
begin end;

procedure TGroupControlAIPA.Priority;
begin end;

procedure TGroupControlAIPA.ActivateGroupControl(A1: Integer);
begin end;

procedure TGroupControlAIPA.DeactivateGroupControl;
begin end;

function TGroupControlAIPA.Process: Boolean;
begin Result := False; end;

constructor TGroupControlLoopAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TGroupControlLoopAIPA.Destroy;
begin end;

procedure TGroupControlLoopAIPA.Priority;
begin end;

procedure TGroupControlLoopAIPA.SupportedPhases;
begin end;

procedure TGroupControlLoopAIPA.ActivateGroupControl(A1: Integer);
begin end;

procedure TGroupControlLoopAIPA.DeactivateGroupControl;
begin end;

procedure TGroupControlLoopAIPA.Activate(A1: Integer; A2: Integer);
begin end;

function TGroupControlLoopAIPA.Process: Boolean;
begin Result := False; end;

constructor TAutoProduceAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAutoProduceAIPA.Destroy;
begin end;

procedure TAutoProduceAIPA.Priority;
begin end;

procedure TAutoProduceAIPA.UpdateProductions(A1: Integer; A2: Integer);
begin end;

procedure TAutoProduceAIPA.ExecuteProduce(A1: Integer; A2: Integer);
begin end;

procedure TAutoProduceAIPA.ExecuteResearch(A1: Integer; A2: Integer);
begin end;

procedure TAutoProduceAIPA.TransporterPriority;
begin end;

procedure TAutoProduceAIPA.ResearchTransporter(A1: Integer);
begin end;

procedure TAutoProduceAIPA.ProduceTransporter(A1: Integer);
begin end;

procedure TAutoProduceAIPA.FindAvailableTransporter;
begin end;

procedure TAutoProduceAIPA.TransporterProductionControlExists;
begin end;

procedure TAutoProduceAIPA.ProducingTransporter;
begin end;

procedure TAutoProduceAIPA.ResearchingTransporter;
begin end;

function TAutoProduceAIPA.Process: Boolean;
begin Result := False; end;

constructor TProcessEventlogAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TProcessEventlogAIPA.Destroy;
begin end;

procedure TProcessEventlogAIPA.Priority;
begin end;

function TProcessEventlogAIPA.Process: Boolean;
begin Result := False; end;

class function TAIBudget.ClassID: Integer;
begin Result := 0; end;

procedure TAIBudget.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAIBudget.Done;
begin end;

procedure TAIBudget.OutputDebugInfo;
begin end;

procedure TAIBudget.UpdateDayRequirements;
begin end;

procedure TAIBudget.GetReady;
begin end;

procedure TAIBudgetList.GetBudgets(A1: Integer);
begin end;

constructor TAIBudgetManager.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIBudgetManager.Destroy;
begin end;

procedure TAIBudgetManager.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAIBudgetManager.GetBudgetGoldUpkeep;
begin end;

procedure TAIBudgetManager.GetBudgetManaUpkeep;
begin end;

procedure TAIBudgetManager.GetReservedBudgetGold;
begin end;

procedure TAIBudgetManager.GetReservedBudgetMana;
begin end;

procedure TAIBudgetManager.GetRequiredBudgetDayGold;
begin end;

procedure TAIBudgetManager.GetRequiredBudgetDayMana;
begin end;

procedure TAIBudgetManager.UpdateBudgetDayRequirements;
begin end;

procedure TAIBudgetManager.UpdateProductionUpkeep;
begin end;

procedure TAIBudgetManager.GetGroupsGoldBudget;
begin end;

procedure TAIBudgetManager.GetGroupsManaBudget;
begin end;

procedure TAIBudgetManager.ReserveForBudgets(A1: Integer; A2: Integer);
begin end;

procedure TAIBudgetManager.ReturnFromBudgets(A1: Integer; A2: Integer);
begin end;

procedure TAIBudgetManager.ValidateReservations;
begin end;

procedure TAIBudgetManager.OutputDebugInfo;
begin end;

procedure TAIBudgetManager.ValidateManaUpkeep;
begin end;

procedure TAIBudgetManager.UpdateBudgets;
begin end;

procedure TAIBudgetManager.RequestProductionExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIBudgetManager.RequestProductionExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAIBudgetManager.ProductionExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIBudgetManager.RequestBudgetExpense(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIBudgetManager.BudgetExpenseMade(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIBudgetManager.RequestBudgetExpenseEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TAIBudgetManager.BudgetExpenseMadeEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer);
begin end;

procedure TAIBudgetManager.RequestExpense(A1: Integer; A2: Integer);
begin end;

procedure TAIBudgetManager.ExpenseMade(A1: Integer; A2: Integer);
begin end;

procedure TAIBudgetManager.ReturnExpense(A1: Integer; A2: Integer);
begin end;

procedure TAIBudgetManager.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TAISavingsBudget.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAISavingsBudget.ClassID: Integer;
begin Result := 0; end;

constructor TAITransporterBudget.Create(AOwner: Engine.TECustomNode);
begin end;

class function TAITransporterBudget.ClassID: Integer;
begin Result := 0; end;

constructor TBudgetManagerAIPA.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TBudgetManagerAIPA.Destroy;
begin end;

procedure TBudgetManagerAIPA.Priority;
begin end;

function TBudgetManagerAIPA.Process: Boolean;
begin Result := False; end;

procedure TAIGroupProductionList.GetProductions(A1: Integer);
begin end;

procedure TAIGroupProductionList.GetStrengthMax(A1: Word; A2: Integer);
begin end;

procedure TAIGroupProductionList.Add(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupProductionList.Delete(A1: Integer);
begin end;

procedure TAIGroupProductionList.DeleteUnit;
begin end;

procedure TAIGroupProductionList.ChangeGroup(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupProductionList.IndexOfU(A1: Integer);
begin end;

constructor TAIGroup.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroup.Destroy;
begin end;

function TAIGroup.AddRef: Integer;
begin Result := 0; end;

function TAIGroup.Release: Integer;
begin Result := 0; end;

class function TAIGroup.ClassID: Integer;
begin Result := 0; end;

procedure TAIGroup.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAIGroup.Behavior;
begin end;

procedure TAIGroup.GroupControlClass;
begin end;

procedure TAIGroup.Clear;
begin end;

procedure TAIGroup.CreateGroupControl;
begin end;

procedure TAIGroup.GetProcessPriority;
begin end;

procedure TAIGroup.GetLoc(A1: Integer; A2: Integer);
begin end;

procedure TAIGroup.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin end;

procedure TAIGroup.GetAdjacent(A1: Integer; A2: Integer);
begin end;

procedure TAIGroup.SetLeader(A1: Integer);
begin end;

procedure TAIGroup.GetMovePointsMin;
begin end;

procedure TAIGroup.GetMovesMin;
begin end;

procedure TAIGroup.GetGoldBudget;
begin end;

procedure TAIGroup.GetManaBudget;
begin end;

procedure TAIGroup.ResetTargetExpense;
begin end;

procedure TAIGroup.ReturnTargetExpense;
begin end;

procedure TAIGroup.RequestTargetExpense(A1: Integer; A2: Integer);
begin end;

procedure TAIGroup.MakeTargetExpense(A1: Integer; A2: Integer);
begin end;

procedure TAIGroup.SetupTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TAIGroup.SetupTarget(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroup.ValidateEmpty;
begin end;

procedure TAIGroup.AddTransporter(A1: Integer);
begin end;

function TAIGroup.AddUnit(AUnit: TAbstractUnit): Boolean;
begin Result := False; end;

function TAIGroup.AddUnits(Units: TUnitList): Boolean;
begin Result := False; end;

function TAIGroup.DeleteUnit(AUnit: TAbstractUnit): Boolean;
begin Result := False; end;

procedure TAIGroup.UnitProduced(A1: Integer; A2: Integer);
begin end;

procedure TAIGroup.CooperateWithGroup(A1: Integer);
begin end;

procedure TAIGroup.DefendLocation(A1: Integer);
begin end;

procedure TAIGroup.GetRecruitableUnits(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroup.Activate;
begin end;

procedure TAIGroup.Deactivate;
begin end;

procedure TAIGroup.SetPlayer(A1: Integer);
begin end;

procedure TAIGroup.NewTurn(A1: Byte);
begin end;

procedure TAIGroup.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAIGroupList.GetGroups(A1: Integer);
begin end;

procedure TAIGroupList.IndexOfID(A1: Integer);
begin end;

procedure TAIGroupList.FindID;
begin end;

procedure TAIGroupList.SortOnProcessPriority;
begin end;

constructor TAIGroupManager.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupManager.Destroy;
begin end;

procedure TAIGroupManager.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAIGroupManager.RegisterAIGroupClasses(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupManager.UnregisterAIGroupClasses(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupManager.CreateGroup(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TAIGroupManager.CreateUniqueID;
begin end;

constructor TAIGroupControlTarget.Create(AOwner: Engine.TECustomNode);
begin end;

function TAIGroupControlTarget.AddRef: Integer;
begin Result := 0; end;

function TAIGroupControlTarget.Release: Integer;
begin Result := 0; end;

procedure TAIGroupControlTarget.Validate(A1: Integer);
begin end;

procedure TAIGroupControlTarget.GetTargetGold;
begin end;

procedure TAIGroupControlTarget.GetTargetMana;
begin end;

procedure TAIGroupControlTarget.GetDebugInfo(A1: Integer);
begin end;

procedure TAIGroupControlTargetList.GetTargets(A1: Integer);
begin end;

procedure TAIGroupControlTargetList.SortOnPriority;
begin end;

procedure TAIGroupControlTargetList.SortOnDataB;
begin end;

procedure TAIGroupControlTargetList.Add;
begin end;

procedure TAIGroupControlTargetList.Delete(A1: Integer);
begin end;

procedure TAIGroupControlTargetList.Validate;
begin end;

procedure TAIGroupControlTargetList.IndexOfXYL(A1: Integer);
begin end;

constructor TAIRecruitmentGroup.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIRecruitmentGroup.Destroy;
begin end;

function TAIRecruitmentGroup.AddRef: Integer;
begin Result := 0; end;

function TAIRecruitmentGroup.Release: Integer;
begin Result := 0; end;

procedure TAIRecruitmentGroup.SetGroup(A1: Integer);
begin end;

procedure TAIRecruitmentGroup.Validate(A1: Integer; A2: Integer);
begin end;

procedure TAIRecruitmentGroupList.GetRecruitmentGroups(A1: Integer);
begin end;

procedure TAIRecruitmentGroupList.SortOnMovePoints;
begin end;

procedure TAIRecruitmentGroupList.OutputDebugInfo;
begin end;

procedure TAIRecruitmentGroupList.Add;
begin end;

procedure TAIRecruitmentGroupList.Delete(A1: Integer);
begin end;

procedure TAIRecruitmentGroupList.Validate(A1: Integer; A2: Integer);
begin end;

procedure TAIRecruitmentGroupList.UnitExists(A1: Integer);
begin end;

procedure TAIRecruitmentGroupList.FindUnit(A1: Integer);
begin end;

constructor TAIGroupProductionLocation.Create(AOwner: Engine.TECustomNode);
begin end;

function TAIGroupProductionLocation.AddRef: Integer;
begin Result := 0; end;

function TAIGroupProductionLocation.Release: Integer;
begin Result := 0; end;

procedure TAIGroupProductionLocation.Validate;
begin end;

procedure TAIGroupProductionLocationList.GetProductionLocation(A1: Integer);
begin end;

procedure TAIGroupProductionLocationList.SortOnMovePoints;
begin end;

procedure TAIGroupProductionLocationList.Add;
begin end;

procedure TAIGroupProductionLocationList.Delete(A1: Integer);
begin end;

procedure TAIGroupProductionLocationList.IndexOfPC(A1: Integer);
begin end;

procedure TAIGroupProductionLocationList.FindPC;
begin end;

procedure TAIGroupProductionLocationList.Validate(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupControl.Destroy;
begin end;

procedure TAIGroupControl.Done;
begin end;

procedure TAIGroupControl.GetStrengthMax(A1: Word; A2: Integer);
begin end;

procedure TAIGroupControl.UpdateGroupChanges;
begin end;

procedure TAIGroupControl.RetrieveGroupArmy(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAIGroupControl.CombineIdleGroups(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupControl.MoveExecuterDone;
begin end;

procedure TAIGroupControl.ResetME;
begin end;

procedure TAIGroupControl.SetupME(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupControl.ExecuteME(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroupControl.ResetCP;
begin end;

procedure TAIGroupControl.SetupCP(A1: Integer);
begin end;

procedure TAIGroupControl.RecruitmentGroupFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroupControl.ProductionLocationFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroupControl.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIGroupControl.Split;
begin end;

procedure TAIGroupControl.Activate;
begin end;

procedure TAIGroupControl.Deactivate;
begin end;

procedure TAIGroupControl.ActivatePlugin(A1: Integer);
begin end;

procedure TAIGroupControl.DeactivatePlugin;
begin end;

procedure TAIGroupControl.ProcessStates(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupControl.ProcessStatesLooped;
begin end;

procedure TAIGroupControl.MainProcessStates(A1: Integer);
begin end;

procedure TAIGroupControl.Validate;
begin end;

procedure TAIGroupControl.Process(A1: Byte);
begin end;

procedure TAIGroupControl.FindAvailableTransporter;
begin end;

constructor TAIGroupControlPlugin.Create(AOwner: Engine.TECustomNode);
begin end;

function TAIGroupControlPlugin.AddRef: Integer;
begin Result := 0; end;

function TAIGroupControlPlugin.Release: Integer;
begin Result := 0; end;

procedure TAIGroupControlPlugin.Validate;
begin end;

procedure TAIGroupControlPlugin.Done;
begin end;

procedure TAIGroupControlPlugin.GetBusy;
begin end;

procedure TAIGroupControlPlugin.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupControlPlugin.Deactivate;
begin end;

procedure TAIGroupControlPlugin.Process(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupControlPlugin.MainProcess;
begin end;

constructor THuntAG.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THuntAG.Destroy;
begin end;

class function THuntAG.ClassID: Integer;
begin Result := 0; end;

procedure THuntAG.Behavior;
begin end;

procedure THuntAG.GroupControlClass;
begin end;

procedure THuntAG.HuntingPlayer(A1: Integer);
begin end;

procedure THuntAG.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THuntAGC.TargetFoundEvent(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THuntAGC.ProcessStates(A1: Integer; A2: Integer);
begin end;

procedure TGroupControl.Behavior;
begin end;

class function TGuardGC.ClassID: Integer;
begin Result := 0; end;

procedure TGuardGC.Behavior;
begin end;

class function TPassiveGC.ClassID: Integer;
begin Result := 0; end;

procedure TPassiveGC.Behavior;
begin end;

class function TGuardAreaGC.ClassID: Integer;
begin Result := 0; end;

procedure TGuardAreaGC.Behavior;
begin end;

class function TSuicidalGC.ClassID: Integer;
begin Result := 0; end;

procedure TSuicidalGC.Behavior;
begin end;

class function TPatrolGC.ClassID: Integer;
begin Result := 0; end;

procedure TPatrolGC.Behavior;
begin end;

class function TScoutGC.ClassID: Integer;
begin Result := 0; end;

procedure TScoutGC.Behavior;
begin end;

class function TRefugeGC.ClassID: Integer;
begin Result := 0; end;

procedure TRefugeGC.Behavior;
begin end;

procedure TGroupDefenseSelector.Create(A1: Byte);
begin end;

destructor TGroupDefenseSelector.Destroy;
begin end;

procedure TGroupDefenseSelector.GetDefenders(A1: Byte; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TGroupDefenseSelector.EnoughStrength(A1: Integer);
begin end;

procedure TGroupDefenseSelector.UsefullUnit(A1: Integer; A2: Integer);
begin end;

procedure TGroupDefenseSelector.UpdateDefenseLocation(A1: Integer);
begin end;

procedure TGroupDefenseSelector.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TAIGroupDefenseControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupDefenseControl.Destroy;
begin end;

procedure TAIGroupDefenseControl.GetBusy;
begin end;

procedure TAIGroupDefenseControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupDefenseControl.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupTargetFinder.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupTargetFinder.Destroy;
begin end;

procedure TAIGroupTargetFinder.TargetFoundEvent(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetFinder.Reset;
begin end;

procedure TAIGroupTargetFinder.Setup(A1: Integer);
begin end;

procedure TAIGroupTargetFinder.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetFinder.GetBusy;
begin end;

procedure TAIGroupTargetFinder.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIRecruitmentGroupFinder.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIRecruitmentGroupFinder.Destroy;
begin end;

procedure TAIRecruitmentGroupFinder.GetBusy;
begin end;

procedure TAIRecruitmentGroupFinder.RecruitGroupFoundEvent(A1: Integer; A2: Integer);
begin end;

procedure TAIRecruitmentGroupFinder.Reset;
begin end;

procedure TAIRecruitmentGroupFinder.Setup(A1: Integer);
begin end;

procedure TAIRecruitmentGroupFinder.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIRecruitmentGroupFinder.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupRecruitControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupRecruitControl.Destroy;
begin end;

procedure TAIGroupRecruitControl.GetRecruitedStrength;
begin end;

procedure TAIGroupRecruitControl.GetRecruitStrengthEx(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.SetRecruitStrengthEx(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupRecruitControl.GetBusy;
begin end;

procedure TAIGroupRecruitControl.GetRecruitMoveDays;
begin end;

procedure TAIGroupRecruitControl.UsefullRecruitUnit(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.UpdateCompletion;
begin end;

procedure TAIGroupRecruitControl.AddRecruitUnit(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.DeleteRecruitUnit(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.ExecuteRecruitment;
begin end;

procedure TAIGroupRecruitControl.ValidRecruitmentGroup(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.RecruitFromGroup(A1: Integer);
begin end;

procedure TAIGroupRecruitControl.Reset;
begin end;

procedure TAIGroupRecruitControl.Setup;
begin end;

procedure TAIGroupRecruitControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupRecruitControl.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIProductionLocationFinder.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIProductionLocationFinder.Destroy;
begin end;

procedure TAIProductionLocationFinder.GetBusy;
begin end;

procedure TAIProductionLocationFinder.ProductionLocationFoundEvent(A1: Integer; A2: Integer);
begin end;

procedure TAIProductionLocationFinder.Reset;
begin end;

procedure TAIProductionLocationFinder.Setup(A1: Integer);
begin end;

procedure TAIProductionLocationFinder.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIProductionLocationFinder.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupUnitProduction.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupUnitProduction.Destroy;
begin end;

function TAIGroupUnitProduction.AddRef: Integer;
begin Result := 0; end;

function TAIGroupUnitProduction.Release: Integer;
begin Result := 0; end;

procedure TAIGroupUnitProduction.SetU(A1: Integer);
begin end;

procedure TAIGroupUnitProduction.SetProductionLocation(A1: Integer);
begin end;

procedure TAIGroupUnitProductionList.GetUnitProductions(A1: Integer);
begin end;

constructor TAIGroupProductionControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupProductionControl.Destroy;
begin end;

procedure TAIGroupProductionControl.GetProducedStrength;
begin end;

procedure TAIGroupProductionControl.GetProduceStrengthEx(A1: Integer);
begin end;

procedure TAIGroupProductionControl.SetProduceStrengthEx(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupProductionControl.GetBusy;
begin end;

procedure TAIGroupProductionControl.UnitProductionPriority(A1: Integer);
begin end;

procedure TAIGroupProductionControl.GetCurrentProductionTime;
begin end;

procedure TAIGroupProductionControl.GetCompleteProductionTime;
begin end;

procedure TAIGroupProductionControl.UpdateCompletion;
begin end;

procedure TAIGroupProductionControl.ExecuteProductions(A1: Integer);
begin end;

procedure TAIGroupProductionControl.AddProduction(A1: Integer);
begin end;

procedure TAIGroupProductionControl.DeleteProduction(A1: Integer);
begin end;

procedure TAIGroupProductionControl.Reset;
begin end;

procedure TAIGroupProductionControl.Setup(A1: Integer);
begin end;

procedure TAIGroupProductionControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupProductionControl.ListProduceableUnits(A1: Integer);
begin end;

procedure TAIGroupProductionControl.ValidProductionLocation(A1: Integer);
begin end;

procedure TAIGroupProductionControl.UpdateProduceableUnits;
begin end;

procedure TAIGroupProductionControl.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupCooperationControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupCooperationControl.Destroy;
begin end;

procedure TAIGroupCooperationControl.GetCooperateMoveDays(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.GetCooperatedStrength;
begin end;

procedure TAIGroupCooperationControl.GetCooperateStrengthEx(A1: Integer);
begin end;

procedure TAIGroupCooperationControl.SetCooperateStrengthEx(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.UpdateCompletion;
begin end;

procedure TAIGroupCooperationControl.Reset;
begin end;

procedure TAIGroupCooperationControl.GetBusy;
begin end;

procedure TAIGroupCooperationControl.Setup(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.AddCooperationGroup(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.ValidCooperationGroup(A1: Integer);
begin end;

procedure TAIGroupCooperationControl.ExecuteCooperation(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIGroupTargetSelector.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupTargetSelector.Destroy;
begin end;

procedure TAIGroupTargetSelector.GetBusy;
begin end;

procedure TAIGroupTargetSelector.TargetOverlapFound(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetSelector.ValidateTargetOverlap(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetSelector.GetValidTargets;
begin end;

procedure TAIGroupTargetSelector.Reset;
begin end;

procedure TAIGroupTargetSelector.ActivatePlugin(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.DeactivatePlugin;
begin end;

procedure TAIGroupTargetSelector.GetTargetSetupPriority(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetSelector.Setup(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetSelector.TargetProcessed;
begin end;

procedure TAIGroupTargetSelector.GetRequiredSuperiority(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.GetRequiredCombatPredictorSuperiority(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.GetRequiredTargetStrength(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.GetRequiredBattleFieldSuperiority(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.GetRequiredBattleFieldStrength(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.GetRequiredStrength(A1: Integer);
begin end;

procedure TAIGroupTargetSelector.ValidateTargetRequirements(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAIGroupTargetSelector.ValidMultiTarget(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIGroupTargetSelector.Validate;
begin end;

procedure TAIGroupTargetSelector.ShowTargetInfo;
begin end;

procedure TAIGroupTargetSelector.NoTargetsFound;
begin end;

procedure TAIGroupTargetSelector.AllowMultiTargets(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupTargetSelector.Process(A1: Integer; A2: Integer);
begin end;

constructor TAIMoveControlSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveControlSettings.Destroy;
begin end;

procedure TAIMoveControlSettings.Clear;
begin end;

function TAIMoveControlSettings.AddRef: Integer;
begin Result := 0; end;

function TAIMoveControlSettings.Release: Integer;
begin Result := 0; end;

procedure TAIMoveControlSettings.SetSourcePos(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIMoveControlSettings.SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIMoveControlSettings.Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

constructor TAIMoveControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveControl.Destroy;
begin end;

procedure TAIMoveControl.Clear;
begin end;

procedure TAIMoveControl.ProcessingDone(A1: Byte);
begin end;

procedure TAIMoveControl.ProcessCanMove;
begin end;

procedure TAIMoveControl.SelectCombinedTransporterArmyMpT(A1: Integer);
begin end;

procedure TAIMoveControl.CalculateTransportGaps(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveControl.ProcessTransporterCanMove(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveControl.Initialize(A1: Integer);
begin end;

procedure TAIMoveControl.CanMove(A1: Integer);
begin end;

procedure TAIMoveControl.Cancel;
begin end;

procedure TAIMoveControl.Reset;
begin end;

procedure TAIMoveControl.Process;
begin end;

constructor TMoveTarget.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveTarget.Destroy;
begin end;

function TMoveTarget.AddRef: Integer;
begin Result := 0; end;

function TMoveTarget.Release: Integer;
begin Result := 0; end;

procedure TMoveTargetList.GetTarget(A1: Integer);
begin end;

procedure TMoveTargetList.IndexOfXYL(A1: Integer);
begin end;

procedure TMoveTargetList.AddTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMoveTargetList.SortOnMovePoints;
begin end;

procedure TAIMoveExecuterUnit.Initialize(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAIMoveExecuterUnit.Validate;
begin end;

procedure TAIMoveExecuterUnit.ResetTransporterSettings;
begin end;

procedure TAIMoveExecuterUnitList.GetUnits(A1: Integer);
begin end;

procedure TAIMoveExecuterUnitList.IndexOfUnitID(A1: Integer);
begin end;

procedure TAIMoveExecuterUnitList.IndexOfUnit(A1: Integer);
begin end;

procedure TAIMoveExecuterUnitList.FindStatusUnit(A1: Integer);
begin end;

procedure TAIMoveExecuterUnitList.ValidateSelection(A1: Byte);
begin end;

procedure TAIMoveExecuterUnitList.SelectionCount;
begin end;

procedure TAIMoveExecuterUnitList.Transporter(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterUnitList.SetMoveResult(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterUnitList.SetTransportStatus(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterUnitList.SetStatus(A1: Integer; A2: Integer);
begin end;

constructor TAIMoveExecuterMove.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveExecuterMove.Destroy;
begin end;

procedure TAIMoveExecuterMove.AddUnits(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterMove.AddUnit;
begin end;

procedure TAIMoveExecuterMove.SetUnitStatus(A1: Integer);
begin end;

procedure TAIMoveExecuterMove.RetrieveArmy(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterMoveQueue.GetMoves(A1: Integer);
begin end;

procedure TAIMoveExecuterMoveQueue.Reset;
begin end;

procedure TAIMoveExecuterMoveQueue.Clear;
begin end;

procedure TAIMoveExecuterArmy.Setup(A1: Integer);
begin end;

procedure TAIMoveExecuterArmy.CanAdd(A1: Integer);
begin end;

procedure TAIMoveExecuterArmy.RetrieveArmy(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIMoveExecuterArmy.ResetTransporterSettings;
begin end;

procedure TAIMoveExecuterArmy.WaitingForTransport;
begin end;

procedure TAIMoveExecuterArmy.Moves(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterArmy.MovePoints(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterArmy.ValidTerrain(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TAIMoveExecuterArmyList.GetArmies(A1: Integer);
begin end;

procedure TAIMoveExecuterArmyList.IndexOf(A1: Integer; A2: Byte);
begin end;

procedure TAIMoveExecuterArmyList.IndexOfXYL(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIMoveExecuterArmyList.IndexOfLoc(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterArmyList.IndexOfTransportStatus(A1: Integer);
begin end;

procedure TAIMoveExecuterArmyList.SortOnMovePoints;
begin end;

constructor TAIMoveExecuterControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveExecuterControl.Destroy;
begin end;

procedure TAIMoveExecuterControl.CreateMove(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer);
begin end;

procedure TAIMoveExecuterControl.CanMoveTo(A1: Integer; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAIMoveExecuterControl.Activate(A1: Integer);
begin end;

procedure TAIMoveExecuterControl.Deactivate;
begin end;

procedure TAIMoveExecuterControl.CalculateMoves(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterControl.Done;
begin end;

procedure TAIMoveExecuterControl.Process;
begin end;

procedure TDefaultMEC.CalculateMoves(A1: Integer; A2: Integer);
begin end;

constructor TAdjacentArmy.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAdjacentArmy.Destroy;
begin end;

procedure TAdjacentArmy.GetMovementDays;
begin end;

procedure TAdjacentArmyList.GetAdjacentArmies(A1: Integer);
begin end;

procedure TAdjacentArmyList.IndexOfLoc(A1: Integer; A2: Integer);
begin end;

procedure TAdjacentArmyList.GetSlowestArmy;
begin end;

procedure TAdjacentArmyList.GetAdjacent;
begin end;

constructor TAdjacentMEC.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAdjacentMEC.Destroy;
begin end;

procedure TAdjacentMEC.ExecuteSurroundMove;
begin end;

procedure TAdjacentMEC.CalculateMeetingPoint;
begin end;

procedure TAdjacentMEC.ExecuteMeetingPointMove;
begin end;

procedure TAdjacentMEC.CalculateMoves(A1: Integer; A2: Integer);
begin end;

procedure TTransportMEC.CreateTransporterMove(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TTransportMEC.TransportDone;
begin end;

procedure TTransportMEC.Done;
begin end;

procedure TTransportMEC.DumpTransportUnits(A1: Integer);
begin end;

procedure TTransportMEC.UpdateTransportMeetingPoint;
begin end;

procedure TTransportMEC.CalculateTransportPathCallBack;
begin end;

procedure TTransportMEC.CalculateMoves(A1: Integer; A2: Integer);
begin end;

constructor TAIMoveExecuter.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveExecuter.Destroy;
begin end;

procedure TAIMoveExecuter.ActivateMEC(A1: Integer);
begin end;

procedure TAIMoveExecuter.DeactivateMEC;
begin end;

procedure TAIMoveExecuter.Clear;
begin end;

procedure TAIMoveExecuter.AddUnit(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuter.AddUnits(A1: Integer);
begin end;

procedure TAIMoveExecuter.AddArmy(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuter.AddTransporter(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuter.InvalidateMove;
begin end;

procedure TAIMoveExecuter.Reset;
begin end;

procedure TAIMoveExecuter.Validate;
begin end;

procedure TAIMoveExecuter.CreateArmies(A1: Byte);
begin end;

procedure TAIMoveExecuter.FinishMoves;
begin end;

procedure TAIMoveExecuter.ExecuteMoves;
begin end;

procedure TAIMoveExecuter.UnitsMoveDone;
begin end;

procedure TAIMoveExecuter.GetTransporting;
begin end;

procedure TAIMoveExecuter.UpdateMoveResult;
begin end;

procedure TAIMoveExecuter.ProcessExecuteMoves;
begin end;

procedure TAIMoveExecuter.ProcessMECS;
begin end;

procedure TAIMoveExecuter.Process;
begin end;

procedure TAIMoveExecuter.SetupTransporter(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuter.ExecuteMove(A1: Byte; A2: Integer; A3: Integer);
begin end;

constructor TAIMoveTargetSelector.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveTargetSelector.Destroy;
begin end;

procedure TAIMoveTargetSelector.SetTransporter(A1: Integer);
begin end;

procedure TAIMoveTargetSelector.Reset(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveTargetSelector.SetupArmy(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveTargetSelector.SetupTransport(A1: Integer; A2: Byte);
begin end;

procedure TAIMoveTargetSelector.Done;
begin end;

procedure TAIMoveTargetSelector.TriggerTargetFound(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveTargetSelector.ProcessBufferedTargets;
begin end;

procedure TAIMoveTargetSelector.ProcessBufferedTransportTargets(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveTargetSelector.ProcessStates(A1: Integer);
begin end;

procedure TAIMoveTargetSelector.Process(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveTargetSelector.Search(A1: Integer);
begin end;

constructor TFastCombatCommand.Create(A1: Integer);
begin end;

procedure TFastCombatCommand.GetName(A1: Integer);
begin end;

constructor TFastCombatCommandList.Create(A1: Integer; A2: Integer);
begin end;

destructor TFastCombatCommandList.Destroy;
begin end;

procedure TFastCombatCommandList.Clear;
begin end;

procedure TFastCombatCommandList.GetCommands(A1: Integer);
begin end;

procedure TFastCombatCommandList.GetCount;
begin end;

procedure TFastCombatCommandList.Add(A1: TFastCombatCommand);
begin end;

procedure TFastCombatCommandList.Delete(A1: Integer);
begin end;

procedure TFastCombatCommandList.Sort;
begin end;

constructor TFastCombatUnit.Create(AOwner: Engine.TECustomNode);
begin end;

class function TFastCombatUnit.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombatUnit.KillUnit;
begin end;

procedure TFastCombatUnit.SetUnit(AUnit: TAbstractUnit);
begin end;

procedure TFastCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TFastCombatUnit.CanCastWallSiegeSpell;
begin end;

procedure TFastCombatUnit.UpdateWallSiegeObjectRegistration;
begin end;

procedure TFastCombatUnit.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin end;

function TFastCombatUnit.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

function TFastCombatUnit.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

procedure TFastCombatUnit.SetCombatPlayer(Player: Byte);
begin end;

function TFastCombatUnit.fcRoundDistance: Integer;
begin Result := 0; end;

procedure TFastCombatUnit.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
begin end;

function TFastCombatUnit.GetTargetWallCV(Target: TCombatObject): Integer;
begin Result := 0; end;

function TFastCombatUnit.GetTargetPriority: Integer;
begin Result := 0; end;

procedure TFastCombatUnit.Initialize(A1: Integer);
begin end;

procedure TFastCombatUnit.Activate(A1: Integer);
begin end;

procedure TFastCombatUnit.Deactivate;
begin end;

procedure TFastCombatUnit.DestroyObject;
begin end;

function TFastCombatUnit.fcWallInBetween(A1: Byte): Boolean;
begin Result := False; end;

function TFastCombatUnit.fcBehindWall: Boolean;
begin Result := False; end;

function TFastCombatUnit.fcExecute(A1: Integer): Boolean;
begin Result := False; end;

constructor TFastCombat.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFastCombat.Destroy;
begin end;

class function TFastCombat.ClassID: Integer;
begin Result := 0; end;

procedure TFastCombat.GetRoundDistance;
begin end;

procedure TFastCombat.GetRoundDistanceMax;
begin end;

procedure TFastCombat.Initialize;
begin end;

procedure TFastCombat.Activate;
begin end;

procedure TFastCombat.Deactivate;
begin end;

function TFastCombat.CreateCombatUnit: Integer;
begin Result := 0; end;

procedure TFastCombat.GetWallInBetween(A1: Integer; A2: Integer);
begin end;

procedure TFastCombat.GetWallSituation(A1: Integer; A2: Integer);
begin end;

procedure TFastCombat.Setup(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer; A6: Integer; A7: Integer; A8: Integer; A9: Integer; A10: Integer; A11: Integer);
begin end;

procedure TFastCombat.AttackerCanCrushWall;
begin end;

procedure TFastCombat.GetAttackerBalisticCV(A1: Integer; A2: Integer);
begin end;

procedure TFastCombat.GetDefenderBalisticCV(A1: Integer; A2: Integer);
begin end;

procedure TFastCombat.ValidateWallBreaching;
begin end;

procedure TFastCombat.ExecuteCombatRound;
begin end;

function TFastCombat.Execute: Byte;
begin Result := 0; end;

procedure TCombatObjectList.GetObject(A1: Integer);
begin end;

constructor TSubMove.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TSubMove.Destroy;
begin end;

procedure TSubMove.AddMovePointLine;
begin end;

procedure TSubMoveList.GetSubMove(A1: Integer);
begin end;

procedure TSubMoveList.DeleteXYL(A1: Integer);
begin end;

procedure TSubMoveList.Delete(A1: Integer);
begin end;

procedure TSubMoveList.IndexOfXYL(A1: Integer);
begin end;

constructor TMoveControlSettings.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveControlSettings.Destroy;
begin end;

procedure TMoveControlSettings.Clear;
begin end;

function TMoveControlSettings.AddRef: Integer;
begin Result := 0; end;

function TMoveControlSettings.Release: Integer;
begin Result := 0; end;

procedure TMoveControlSettings.ResetState;
begin end;

procedure TMoveControlSettings.Reset;
begin end;

procedure TMoveControlSettings.SetSourcePos(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControlSettings.SetDestinationPos(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControlSettings.SetupArmy(A1: Integer; A2: Integer);
begin end;

procedure TMoveControlSettings.SetupLevel(A1: Integer);
begin end;

procedure TMoveControlSettings.SetupMovePointData(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControlSettings.ClearMovePoints;
begin end;

procedure TMoveControlSettings.GetMovePoints(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControlSettings.SetMovePoints(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMoveControlSettings.GetMovePointLevelData(A1: Integer);
begin end;

procedure TMoveControlSettings.GetMovePointsXYL(A1: Integer; A2: Integer);
begin end;

procedure TMoveControlSettings.SetMovePointsXYL(A1: Integer; A2: Integer);
begin end;

constructor TMoveControl.Create;
begin end;

destructor TMoveControl.Destroy;
begin end;

procedure TMoveControl.Clear;
begin end;

procedure TMoveControl.SetMapL(A1: Integer);
begin end;

procedure TMoveControl.DefaultMoveOnMovePointProc(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.FindSubMoveOrigin(A1: Integer);
begin end;

procedure TMoveControl.CalculateMovePointLine(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControl.ProcessHexagon(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControl.ValidLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControl.ExecuteExternalMove(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControl.SetupMove;
begin end;

procedure TMoveControl.SetupSubMove(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.ProcessSubMove(A1: Integer);
begin end;

procedure TMoveControl.Process;
begin end;

procedure TMoveControl.CalculatePathEx(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TMoveControl.CalculatePath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMoveControl.ExploredOnlyMoveOnMovePointProc(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.Activate(A1: Integer);
begin end;

procedure TMoveControl.Deactivate;
begin end;

procedure TMoveControl.ProcessMove(A1: TMoveControlSettings);
begin end;

procedure TMoveControl.CanMove(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.ValidPath(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.CalculateGaps(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMoveControl.CalculateTurnAroundMovePoints(A1: Integer);
begin end;

procedure TMoveControl.GetMovePointsCostFast(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

class function TSaveGameTE.ClassID: Integer;
begin Result := 0; end;

procedure TSaveGameTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TSaveGameTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TChangePlayerSettingsTE.ClassID: Integer;
begin Result := 0; end;

procedure TChangePlayerSettingsTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TChangePlayerSettingsTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TEndTurnTE.ClassID: Integer;
begin Result := 0; end;

procedure TEndTurnTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TEndTurnTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TMoveTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveTE.Destroy;
begin end;

procedure TMoveTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TMoveTE.GetMapF(A1: Integer; A2: Integer): Integer;
begin Result := 0; end;

procedure TMoveTE.GetDirection(A1: Integer);
begin end;

procedure TMoveTE.GetHT(A1: Integer);
begin end;

procedure TMoveTE.Move;
begin end;

function TMoveTE.Validate: Integer;
begin Result := 0; end;

procedure TMoveTE.InitializeMove;
begin end;

procedure TMoveTE.FinishMove;
begin end;

function TMoveTE.DefaultMove: Byte;
begin Result := 0; end;

function TMoveTE.LastMove(A1: Integer; A2: Byte): Byte;
begin Result := 0; end;

procedure TMoveTE.ProcessMove;
begin end;

function TMoveTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TMoveArmyTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMoveArmyTE.Destroy;
begin end;

class function TMoveArmyTE.ClassID: Integer;
begin Result := 0; end;

procedure TMoveArmyTE.GetNoneMovingArmyHS(A1: Integer);
begin end;

procedure TMoveArmyTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TMoveArmyTE.Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean;
begin Result := False; end;

function TMoveArmyTE.Validate: Integer;
begin Result := 0; end;

procedure TMoveArmyTE.InitializeMove;
begin end;

procedure TMoveArmyTE.FinishMove;
begin end;

procedure TMoveArmyTE.ObserveMove;
begin end;

procedure TMoveArmyTE.MoveVisible(A1: Integer);
begin end;

procedure TMoveArmyTE.ExecuteMove;
begin end;

procedure TMoveArmyTE.Animating;
begin end;

procedure TMoveArmyTE.UpdateAnimation;
begin end;

procedure TMoveArmyTE.CanMoveNext;
begin end;

procedure TMoveArmyTE.SetupNextMove;
begin end;

function TMoveArmyTE.DefaultMove: Byte;
begin Result := 0; end;

class function TArmyDefaultMoveTE.ClassID: Integer;
begin Result := 0; end;

function TArmyDefaultMoveTE.Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean;
begin Result := False; end;

class function TArmyNegotiateMoveTE.ClassID: Integer;
begin Result := 0; end;

function TArmyNegotiateMoveTE.Validate: Integer;
begin Result := 0; end;

procedure TArmyNegotiateMoveTE.CanMoveNext;
begin end;

procedure TArmyNegotiateMoveTE.ExecuteMove;
begin end;

procedure TArmyNegotiateMoveTE.Animating;
begin end;

class function TArmyCombineMoveTE.ClassID: Integer;
begin Result := 0; end;

procedure TArmyCombineMoveTE.ShowCombineFailure(A1: Byte);
begin end;

procedure TArmyCombineMoveTE.CanMoveNext;
begin end;

function TCombatRestoreHotseatEventLog.Execute(Mode: Integer; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin end;

class function TArmyCombatMoveTE.ClassID: Integer;
begin Result := 0; end;

function TArmyCombatMoveTE.Setup(A1: TArmyHS; A2: Byte; A3: TMovepath; A4: TArmyMoveMode): Boolean;
begin Result := False; end;

procedure TArmyCombatMoveTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TArmyCombatMoveTE.Validate: Integer;
begin Result := 0; end;

procedure TArmyCombatMoveTE.InitializeMove;
begin end;

procedure TArmyCombatMoveTE.RequestCombatTypeCallBack(A1: Integer);
begin end;

procedure TArmyCombatMoveTE.RestoreHotseatMode(A1: Integer);
begin end;

procedure TArmyCombatMoveTE.RestoreHotSeatModeCallBack;
begin end;

procedure TArmyCombatMoveTE.ShowHotSeatPlayerCallBack(A1: Integer);
begin end;

procedure TArmyCombatMoveTE.SetupCombat;
begin end;

procedure TArmyCombatMoveTE.CombatExecuted(A1: Integer);
begin end;

procedure TArmyCombatMoveTE.ExecuteCombat;
begin end;

procedure TArmyCombatMoveTE.ExecuteLastMove;
begin end;

procedure TArmyCombatMoveTE.Animating;
begin end;

procedure TArmyCombatMoveTE.CanMoveNext;
begin end;

procedure TArmyCombatMoveTE.ExecuteMove;
begin end;

procedure TArmyCombatMoveTE.ProcessMove;
begin end;

class function TGameOverTE.ClassID: Integer;
begin Result := 0; end;

procedure TGameOverTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TGameOverTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TTerminatePlayerTE.ClassID: Integer;
begin Result := 0; end;

procedure TTerminatePlayerTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TTerminatePlayerTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TMultiMoveTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TMultiMoveTE.Destroy;
begin end;

class function TMultiMoveTE.ClassID: Integer;
begin Result := 0; end;

procedure TMultiMoveTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TMultiMoveTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCheatTE.ClassID: Integer;
begin Result := 0; end;

procedure TCheatTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCheatTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TDisbandUnitTE.ClassID: Integer;
begin Result := 0; end;

procedure TDisbandUnitTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TDisbandUnitTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TCombatFlowControlTE.ClassID: Integer;
begin Result := 0; end;

procedure TCombatFlowControlTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TCombatFlowControlTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TPadControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TPadControl.Destroy;
begin end;

procedure TPadControl.GetPadResource(A1: Integer);
begin end;

procedure TPadControl.SetPadResource(A1: Integer; A2: Integer);
begin end;

procedure TPadControl.RegisterPadResource(Resource: TMapObjectResource; Size: Integer);
begin end;

procedure TPadControl.UnregisterPadResource(Resource: TMapObjectResource; Size: Integer);
begin end;

procedure TPadControl.CanPlacePad(A1: Byte; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TPadControl.PlacePad(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

