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


var
  TMPDID: Integer; { $558FA054 }

resourcestring
  { needs: P1 NotEnoughGoldRStr (5570719C, string resource 65215). }
  P5NotEnoughGoldRStr = 'Not enough gold.';
  GameRestartedRStr = 'Game Restarted';








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

function TDiplomaticActionEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  POP EBP
  JMP P5DiplomaticExecute
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
    Inc(TPlayerList(AoWHSMap.FPlayers).GetPlayers(Player).FMagicControl.FMana, FSelectedTransferMana);
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

procedure TAoWCampaign.StartScenario(ID: Integer; const FileName: string; Progress: TProgressEvent);
begin
  FStream.Clear;
  FNextScenarioID := -1;
  FCurrentScenarioID := ID;
end;

procedure TAoWCampaign.SetupScenario;
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

procedure TEmailGameControl.ValidateIncommingGame(const FileName: string; var Destination: string);
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

const
  Player2GroupBehaviorTable: array[pbNormal..pbScorcher, 0..9] of TGroupBehavior =
    ((gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal,gbNormal),
     (gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive,gbAggressive),
     (gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive,gbDefensive),
     (gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand,gbExpand),
     (gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch,gbScorch));
  IndependentGroupBehaviorTable: array[TIndependentAIMode, 0..9] of TGroupBehavior =
    ((gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbScout,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbPatrol,gbScout,gbScout,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive,gbPassive),
     (gbPatrol,gbPatrol,gbScout,gbScout,gbSuicidal,gbSuicidal,gbRaid,gbPassive,gbPassive,gbPassive));

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

function TAIPlayerControl.GetRandomGroupBehavior: TGroupBehavior;
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

procedure TAIPlayerControl.ListPeaceWarUnknownPlayers(Peace, War, Unknown: TByteList);
var
  I: Integer;
  Relation: TDiplomaticRelation;
begin
  Peace.Clear;
  War.Clear;
  Peace.Add(FPlayer.FPlayerIndex);
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if I <> FPlayer.FPlayerIndex then
      if (AoWHSMap.FPlayers.GetPlayers(I).FSingleProcessCycle = True) then
      begin
        Relation := AoWHSMap.FPlayers.GetDiplomaticRelation(FPlayer.FPlayerIndex, I);
        if Relation in [drPeace, drAlliance] then Peace.Add(I)
        else if Relation = drWar then War.Add(I)
        else if Relation = drUnknown then
          if FPlayer.GetFirstDaySeen(I) <> -1 then Unknown.Add(I);
      end;
  { Original behavior: Unknown is not cleared before appending. }
end;

procedure TAIPlayerControl.ListIdealPeaceWarPlayers(Peace, War: TByteList);
var
  I: Integer;
  Players: TDoubleItemList;
  Relation: TDiplomaticRelation;
  Priority: Integer;
  RaceRelation: TStatus;
  Days: Integer;
  Action: TDiplomaticAction;
  Item: TDoubleItem;
begin
  Peace.Clear;
  War.Clear;
  Players := TDoubleItemList.Create;
  Players.AddAB(FPlayer.FPlayerIndex, 999);
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
    if (I <> FPlayer.FPlayerIndex) and (AoWHSMap.FPlayers.GetPlayers(I).FSingleProcessCycle = True) then
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
    Item := Players[Players.Count div 2];
    RaceRelation := AoWHSMap.FRaces.GetRace(
      AoWHSMap.FPlayers.GetPlayers(FPlayer.FPlayerIndex).FPlayerRace).
      GetDefaultRaceRelation(AoWHSMap.FPlayers.GetPlayers(Item.A).FPlayerRace);
    if RaceRelation in [sHostile, sWary] then War.Add(Item.A)
    else Peace.Add(Item.A);
  end;
  Players.Free;
end;

function TAIPlayerControl.CanOfferPeace(Player: Byte): Boolean;
var
  IdealPeace, IdealWar, Peace, War, Unknown: TByteList;
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
    if (WarCount < PeaceCount) and
      not ((WarCount = 0) and (PeaceCount = 1) and
        (AoWHSMap.FPlayers.FActivePlayers.Count < 3)) then Result := False
    else Result := True;
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
  IdealPeace, IdealWar, Peace, War, Unknown: TByteList;
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
    if (PeaceCount < WarCount) and
      (FPlayer.FDiplomaticRelations.GetHistory(Shortint(Player)).GetRelationOnDay(0) <> drWar) then
      Result := False
    else Result := True;
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
        if FMoveExecuter.FStatus = mesBusy then Done := FMoveExecuter.Process
        else
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
        end;
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
        if FMoveExecuter.FStatus = mesBusy then Done := FMoveExecuter.Process
        else
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
        end;
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

procedure TGroupControlAIPA.DeactivateGroupControl;
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

procedure TGroupControlLoopAIPA.ActivateGroupControl(Group: TAIGroup);
begin
  DeactivateGroupControl;
  FGroupControl := Group.CreateGroupControl;
  FGroupControl.Activate;
end;

procedure TGroupControlLoopAIPA.DeactivateGroupControl;
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

class function TGroupControlLoopAIPA.SupportedPhases: TAIPlayerProcessPhases;
begin Result := [appLoop]; end;

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
  I, J: Integer;
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
  Budget: TAIBudget;
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
        with FControl.FPlayer.FProductionControls do
          if FProductionIndex < Count then
            UpdateProductions(GetPC(FProductionIndex))
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

function TAIGroupProductionList.GetProductions(Index: Integer): TAIGroupProduction;
begin
  Result := TAIGroupProduction(FChildren.List^[Index]);
end;

function TAIGroupProductionList.GetStrengthMax(DamageTypes: TDamageTypes): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
    Inc(Result, TAIGroupProduction(FChildren.List^[I]).FUnit.GetStrengthMax(DamageTypes));
end;

procedure TAIGroupProductionList.Add(Control: TProductionControl; AUnit: TAbstractUnit);
begin
  with TAIGroupProduction.Create(Self) do
  begin
    FControl := Control;
    FUnit := AUnit;
  end;
end;

procedure TAIGroupProductionList.Delete(Index: Integer);
begin
  GetProductions(Index).Free;
end;

procedure TAIGroupProductionList.DeleteUnit(AUnit: TAbstractUnit);
var
  I: Integer;
begin
  I := IndexOfU(AUnit);
  if I <> -1 then GetProductions(I).Free;
end;

procedure TAIGroupProductionList.ChangeGroup(Index: Integer; Group: TAIGroup);
begin
  with GetProductions(Index) do
  begin
    FControl.FSettings.FGroupID := Group.FGroupID;
    SetOwner(Group.FProductions);
  end;
end;

function TAIGroupProductionList.IndexOfU(AUnit: TAbstractUnit): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if AUnit = TAIGroupProduction(FChildren.List^[Result]).FUnit then Exit;
  end;
  Result := -1;
end;

constructor TAIGroup.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FStatus := [];
  FProductions := TAIGroupProductionList.Create(nil);
  FGroupID := -1;
  FPlayer := -1;
  FIndependentRelation := -1;
  FTransporterID := -1;
  FLeaderID := -1;
  FProcessPriority := 10;
  FRecruitmentPriority := 10;
end;

destructor TAIGroup.Destroy;
begin
  if (AoWHSMap <> nil) and (AoWHSMap.FUnitControl = nil) and (Count <> 0) then
  begin
    { Original diagnostic raises and immediately swallows its exception. }
    try
      raise Exception.Create('oohps');
    except
    end;
  end;
  if agsActivated in FStatus then Deactivate;
  Clear;
  FProductions.Free;
  inherited Destroy;
end;

function TAIGroup.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIGroup.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

class function TAIGroup.ClassID: Integer;
begin Result := $21450; end;

procedure TAIGroup.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGroupID, $14);
  Stream.rwIntegerEx(FTransporterID, -1, $15);
  Stream.rwIntegerEx(FLeaderID, -1, $16);
  Stream.rwInteger(Integer(FTargetXYL), $17);
  Stream.rwData(FTargetType, SizeOf(FTargetType), $18);
  Stream.rwByte(Byte(FPlayer), $19);
  Stream.rwData(FIndependentRelation, SizeOf(FIndependentRelation), $1A);
  Stream.rwByte(FProcessPriority, $1B);
  Stream.rwByte(FRecruitmentPriority, $1C);
  Stream.rwInteger(FGoldBudget, $1D);
  Stream.rwInteger(FManaBudget, $1E);
  Stream.rwInteger(FTargetMovePoints, $1F);
  Stream.rwData(FTargetMode, SizeOf(FTargetMode), $20);
end;

class function TAIGroup.Behavior: TGroupBehavior;
begin Result := gbNone; end;

class function TAIGroup.GroupControlClass: TAIGroupControlClass;
begin
  Result := TAIGroupControl;
end;

procedure TAIGroup.Clear;
var
  Transporter: TAbstractUnit;
begin
  while FChildren.Count <> 0 do
    DeleteUnit(TAbstractUnit(FChildren.List^[FChildren.Count - 1]));
  Transporter := FTransporter;
  if Transporter <> nil then DeleteUnit(Transporter);
  FLeader := nil;
  FLeaderID := -1;
end;

function TAIGroup.CreateGroupControl: TAIGroupControl;
begin
  Result := GroupControlClass.Create(nil);
  Result.FGroup := Self;
  AddRef;
end;

function TAIGroup.GetProcessPriority: Integer;
begin
  Result := Count + (Integer(FProcessPriority) shl 16);
end;

function TAIGroup.GetLoc: Integer;
var
  Location: TXYL;
  Leader: TAbstractUnit;
begin
  Leader := FLeader;
  if Leader <> nil then
  begin
    Leader.GetLocation(Location.X, Location.Y, Location.L);
    Location.Flag := 0;
  end
  else Location.XYL := $FFFFFF;
  Result := Location.XYL;
end;

procedure TAIGroup.GetLocation(var Xhx, Yhx, Lhx: Shortint);
var
  Location: TXYL;
begin
  Location.XYL := GetLoc;
  Xhx := Location.X;
  Yhx := Location.Y;
  Lhx := Location.L;
end;

function TAIGroup.GetAdjacent: Boolean;
var
  Locations: TXYLList;
  I: Integer;
  Location: TXYL;
begin
  Locations := TXYLList.Create;
  for I := Count - 1 downto 0 do
  begin
    GetUnit(I).GetLocation(Location.X, Location.Y, Location.L);
    Locations.Add(PackXYL(Location.X, Location.Y, Location.L));
  end;
  Result := LocationsConnected(Locations);
  Locations.Free;
end;

procedure TAIGroup.SetLeader(AUnit: TAbstractUnit);
begin
  if IndexOf(AUnit) <> -1 then
  begin
    FLeader := AUnit;
    FLeaderID := AUnit.FUnitID;
  end;
end;

function TAIGroup.GetMovePointsMin: Integer;
var
  I: Integer;
begin
  Result := 50;
  for I := Count - 1 downto 0 do
    if Result > GetUnit(I).GetMovePoints then
      Result := GetUnit(I).GetMovePoints;
end;

function TAIGroup.GetMovesMin: Integer;
var
  I: Integer;
begin
  Result := 50;
  for I := Count - 1 downto 0 do
    if Result > GetUnit(I).GetMoves then
      Result := GetUnit(I).GetMoves;
end;

function TAIGroup.GetGoldBudget: Integer;
begin
  Result := FGoldBudget;
end;

function TAIGroup.GetManaBudget: Integer;
begin
  Result := FManaBudget;
end;

procedure TAIGroup.ResetTargetExpense;
begin
  FGoldBudget := 0;
  FManaBudget := 0;
end;

procedure TAIGroup.ReturnTargetExpense;
begin
  if (FGoldBudget > 0) or (FManaBudget > 0) then
  begin
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.ReturnExpense(FGoldBudget, FManaBudget);
    FGoldBudget := 0;
    FManaBudget := 0;
  end;
end;

function TAIGroup.RequestTargetExpense(Gold, Mana: Integer): Boolean;
var
  G, M: Integer;
begin
  G := Gold - FGoldBudget;
  M := Mana - FManaBudget;
  Result := AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.RequestBudgetExpense(
    G, M, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, True);
end;

function TAIGroup.MakeTargetExpense(Gold, Mana: Integer): Boolean;
begin
  if RequestTargetExpense(Gold, Mana) then
  begin
    ReturnTargetExpense;
    Result := AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.BudgetExpenseMade(
      Gold, Mana, AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIBudget.FDefaultBudget, bemPoolThenBudget);
    if Result then
    begin
      FGoldBudget := Gold;
      FManaBudget := Mana;
    end;
  end
  else Result := False;
end;

function TAIGroup.SetupTargetEx(Location: TXYL; MovePoints: Integer;
  TargetType: TAIGroupTargetStatus; Mode: Byte;
  TransporterID, Gold, Mana: Integer): Boolean;
var
  Transporter: TAbstractUnit;
begin
  if Integer(Location) <> $FFFFFF then
  begin
    FTargetXYL := Location;
    FTargetType := TargetType;
    FTargetMovePoints := MovePoints;
    FTargetMode := Mode;
    if TargetType = gtsExecute then Dec(FTargetMovePoints, GetMovePointsMin);
    Result := MakeTargetExpense(Gold, Mana);
  end
  else
  begin
    Integer(FTargetXYL) := $FFFFFF;
    FTargetType := TargetType;
    FTargetMode := Mode;
    FTargetMovePoints := 0;
    ReturnTargetExpense;
    Result := True;
  end;
  if (Integer(Location) <> $FFFFFF) and (TransporterID <> -1) then
    AddTransporter(TUnitControl(AoWHSMap.FUnitControl).FindUnit(TransporterID))
  else
  begin
    Transporter := FTransporter;
    if Transporter <> nil then DeleteUnit(Transporter);
  end;
end;

function TAIGroup.SetupTarget(Target: TAIGroupControlTarget;
  TargetType: TAIGroupTargetStatus; Mode: Byte): Boolean;
var
  Transporter: TAbstractUnit;
begin
  if Target <> nil then
  begin
    FTargetXYL := Target.FLocation;
    FTargetType := TargetType;
    FTargetMovePoints := Target.FMovePoints;
    FTargetMode := Mode;
    if TargetType = gtsExecute then Dec(FTargetMovePoints, GetMovePointsMin);
    Result := MakeTargetExpense(Target.GetTargetGold, Target.GetTargetMana);
  end
  else
  begin
    Integer(FTargetXYL) := $FFFFFF;
    FTargetType := TargetType;
    FTargetMode := Mode;
    FTargetMovePoints := 0;
    ReturnTargetExpense;
    Result := True;
  end;
  if (Target <> nil) and (Target.FTransporterID <> -1) then
    AddTransporter(TUnitControl(AoWHSMap.FUnitControl).FindUnit(Target.FTransporterID))
  else
  begin
    Transporter := FTransporter;
    if Transporter <> nil then DeleteUnit(Transporter);
  end;
end;

procedure TAIGroup.ValidateEmpty;
var
  Empty: Boolean;
begin
  Empty := (Count = 0) and (FTransporterID = -1);
  if Empty and not (agsEmpty in FStatus) then
  begin
    FStatus := FStatus + [agsEmpty];
    Release;
  end
  else if not Empty and (agsEmpty in FStatus) then
  begin
    FStatus := FStatus - [agsEmpty];
    AddRef;
  end;
end;

procedure TAIGroup.AddTransporter(AUnit: TAbstractUnit);
var
  OldTransporter: TAbstractUnit;
  Group: TAIGroup;
begin
  OldTransporter := FTransporter;
  if AUnit <> OldTransporter then
  begin
    if OldTransporter <> nil then
    begin
      OldTransporter.FGroup := nil;
      OldTransporter.FGroupID := 0;
      OldTransporter.Release;
    end;
    Group := AUnit.FGroup;
    if Group <> nil then
    begin
      Group.DeleteUnit(AUnit);
      AUnit.FGroupID := 0;
    end;
    FTransporterID := AUnit.FUnitID;
    FTransporter := AUnit;
    FTransporter.AddRef;
    AUnit.FGroupID := FGroupID;
    AUnit.FGroup := Self;
    ValidateEmpty;
  end;
end;

function TAIGroup.AddUnit(AUnit: TAbstractUnit): Boolean;
var
  Group: TAIGroup;
begin
  if IndexOf(AUnit) = -1 then
  begin
    Group := AUnit.FGroup;
    if Group <> nil then Group.DeleteUnit(AUnit);
    if (AUnit.FUnitID <> FTransporterID) or not AUnit.GetTransporter then
    begin
      AddChild(AUnit);
      if FLeaderID = -1 then SetLeader(AUnit);
    end
    else
    begin
      FTransporter := AUnit;
      FTransporter.AddRef;
    end;
    AUnit.FGroupID := FGroupID;
    AUnit.FGroup := Self;
    FStatus := FStatus + [agsChanged];
    Result := True;
  end
  else Result := False;
  ValidateEmpty;
end;

function TAIGroup.AddUnits(Units: TUnitList): Boolean;
var
  I: Integer;
begin
  AddRef;
  for I := Units.Count - 1 downto 0 do
    AddUnit(Units.GetUnit(I));
  Release;
  Result := True;
end;

function TAIGroup.DeleteUnit(AUnit: TAbstractUnit): Boolean;
var
  I: Integer;
  X1, Y1, L1, X2, Y2, L2: Shortint;
  Leader: TAbstractUnit;
begin
  AUnit.AddRef;
  if RemoveChild(AUnit) <> -1 then
  begin
    AUnit.FGroupID := 0;
    AUnit.FGroup := nil;
    Leader := FLeader;
    if Leader = AUnit then
    begin
      Leader.GetLocation(X1, Y1, L1);
      FLeader := nil;
      FLeaderID := -1;
      I := Count;
      while (I <> 0) and (FLeader = nil) do
      begin
        Dec(I);
        TAbstractUnit(FChildren.List^[I]).GetLocation(X2, Y2, L2);
        if (X1 = X2) and (Y1 = Y2) and (L1 = L2) then
          SetLeader(TAbstractUnit(FChildren.List^[I]));
      end;
      if (FLeader = nil) and (Count <> 0) then
        SetLeader(TAbstractUnit(FChildren.List^[0]));
    end;
    FStatus := FStatus + [agsChanged];
    Result := True;
  end
  else if AUnit = FTransporter then
  begin
    AUnit.FGroupID := 0;
    AUnit.FGroup := nil;
    FTransporterID := -1;
    FTransporter.Release;
    FTransporter := nil;
    FStatus := FStatus + [agsChanged];
    Result := True;
  end
  else Result := False;
  ValidateEmpty;
  AUnit.Release;
end;

procedure TAIGroup.UnitProduced(Control: TProductionControl; AUnit: TAbstractUnit);
var
  X1, Y1, L1, X2, Y2, L2: Shortint;
begin
  if FLeader <> nil then
  begin
    GetLocation(X1, Y1, L1);
    AUnit.GetLocation(X2, Y2, L2);
    if (L1 = L2) and (dHXtoRad(X1, Y1, X2, Y2) <= 2) then
      AddUnit(AUnit);
    FProductions.DeleteUnit(AUnit);
  end;
end;

function TAIGroup.CooperateWithGroup(Group: TAIGroup): Boolean;
begin
  Result := Group.Behavior = Behavior;
end;

function TAIGroup.DefendLocation(Location: Integer): Boolean;
var
  GroupLocation: TXYL;
begin
  GroupLocation.XYL := GetLoc;
  Result := (TXYL(Location).L = GroupLocation.L) and
    (dHXtoRad(TXYL(Location).X, TXYL(Location).Y, GroupLocation.X, GroupLocation.Y) <= 1);
end;

function TAIGroup.GetRecruitableUnits(Phase: Integer; Units, Recruitable: TUnitList): Boolean;
begin Result := False; end;

procedure TAIGroup.Activate;
var
  Player: Shortint;
begin
  Assert(not (agsActivated in FStatus));
  FStatus := FStatus + [agsActivated];
  Player := FPlayer;
  if Player <> -1 then AoWHSMap.FPlayers.GetPlayers(Player).FAIGroups.AddChild(Self);
  FLeader := FindID(FLeaderID);
  Assert((FTransporter <> nil) or (FTransporterID = -1));
end;

procedure TAIGroup.Deactivate;
var
  Player: Shortint;
begin
  Assert(agsActivated in FStatus);
  FStatus := FStatus - [agsActivated];
  Player := FPlayer;
  if Player <> -1 then AoWHSMap.FPlayers.GetPlayers(Player).FAIGroups.RemoveChild(Self);
end;

procedure TAIGroup.SetPlayer(Player: Shortint);
begin
  if Player <> FPlayer then
  begin
    if (agsActivated in FStatus) and (FPlayer <> -1) then
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIGroups.RemoveChild(Self);
    FPlayer := Player;
    if (agsActivated in FStatus) and (FPlayer <> -1) then
      AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIGroups.AddChild(Self);
  end;
end;

procedure TAIGroup.NewTurn(Player: Shortint);
begin
  if Player = FPlayer then FStatus := FStatus - [agsDone];
end;

procedure TAIGroup.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20020002 then NewTurn(Shortint(Integer(Msg.Engine)))
  else if Msg.MsgID = $20000008 then
  begin
    Activate;
    ValidateEmpty;
  end;
end;

function TAIGroupList.GetGroups(Index: Integer): TAIGroup;
begin
  if (Index >= 0) and (Index < Count) then
    Result := TAIGroup(FChildren.List^[Index])
  else Result := nil;
end;

function TAIGroupList.IndexOfID(ID: Integer): Integer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if ID = TAIGroup(FChildren.List^[Result]).FGroupID then Exit;
  end;
  Result := -1;
end;

function TAIGroupList.FindID(ID: Integer): TAIGroup;
var
  I: Integer;
begin
  I := IndexOfID(ID);
  if I <> -1 then Result := TAIGroup(FChildren.List^[I])
  else Result := nil;
end;

function CompareAIGroupProcessPriority(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroup(Item2).GetProcessPriority - TAIGroup(Item1).GetProcessPriority;
  if Result = 0 then Result := TAIGroup(Item2).FGroupID - TAIGroup(Item1).FGroupID;
end;

procedure TAIGroupList.SortOnProcessPriority;
begin
  FChildren.Sort(CompareAIGroupProcessPriority);
end;

constructor TAIGroupManager.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FNextID := 1;
  FRegisteredClasses := TList.Create;
end;

destructor TAIGroupManager.Destroy;
begin
  FRegisteredClasses.Free;
  inherited Destroy;
end;

procedure TAIGroupManager.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwIntegerEx(FNextID, 1, $1E);
end;

procedure TAIGroupManager.RegisterAIGroupClasses(Classes: array of TAIGroupClass);
var
  I: Integer;
begin
  for I := 0 to High(Classes) do
    if FRegisteredClasses.IndexOf(Classes[I]) = -1 then
      FRegisteredClasses.Add(Classes[I]);
end;

procedure TAIGroupManager.UnregisterAIGroupClasses(Classes: array of TAIGroupClass);
var
  I: Integer;
begin
  for I := 0 to High(Classes) do
    FRegisteredClasses.Remove(Classes[I]);
end;

function TAIGroupManager.CreateGroup(Player, Relation: Shortint; Behavior: TGroupBehavior): TAIGroup;
var
  I: Integer;
  Found: Boolean;
begin
  Found := False;
  I := FRegisteredClasses.Count;
  while not Found and (I <> 0) do
  begin
    Dec(I);
    Found := Behavior = TAIGroupClass(FRegisteredClasses[I]).Behavior;
  end;
  if Found then
  begin
    Result := TAIGroupClass(FRegisteredClasses[I]).Create(Self);
    Result.FGroupID := CreateUniqueID;
    Result.FPlayer := Player;
    Result.FIndependentRelation := Relation;
    Result.AddRef;
    Result.Activate;
  end
  else Result := nil;
end;

function TAIGroupManager.CreateUniqueID: Integer;
begin
  Result := FNextID;
  while IndexOfID(Result) <> -1 do
  begin
    Inc(Result);
    if Result > $FFFFFFF then Result := 1;
  end;
  FNextID := Result + 1;
end;

constructor TAIGroupControlTarget.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FTransporterID := -1;
end;

function TAIGroupControlTarget.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIGroupControlTarget.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

function TAIGroupControlTarget.Validate(Control: TAIGroupControl): Boolean;
var
  Data: TAITargetData;
  X: Shortint;
begin
  X := FLocation.X;
  if X <> -1 then
    Result := TAoWMapField(AoWHSMap.MapContainer.GetField(X, FLocation.Y, FLocation.L)).GetAITarget(Control, FInfo, Data)
  else Result := False;
end;

function TAIGroupControlTarget.GetTargetGold: Integer;
begin
  Result := FData.Cost;
end;

function TAIGroupControlTarget.GetTargetMana: Integer;
begin
  Result := 0;
end;

procedure TAIGroupControlTarget.GetDebugInfo(var Text: string);
begin
  Text := 'Target(' + IntToStr(FLocation.X) + ',' + IntToStr(FLocation.Y) +
    ',' + IntToStr(FLocation.L) + '): Prio:' + IntToStr(FData.Priority);
  if FTransporterID <> -1 then
    Text := Text + '/Transporter(' + IntToStr(FTransporterID) + ')';
end;

function TAIGroupControlTargetList.GetTargets(Index: Integer): TAIGroupControlTarget;
begin
  Assert((Index >= 0) and (Index < FChildren.Count));
  Result := TAIGroupControlTarget(FChildren.List^[Index]);
end;

function CompareAIGroupTargetPriority(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroupControlTarget(Item2).FData.Priority - TAIGroupControlTarget(Item1).FData.Priority;
end;

procedure TAIGroupControlTargetList.SortOnPriority;
begin
  FChildren.Sort(CompareAIGroupTargetPriority);
end;

function CompareAIGroupTargetDataB(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroupControlTarget(Item2).FDataB - TAIGroupControlTarget(Item1).FDataB;
end;

procedure TAIGroupControlTargetList.SortOnDataB;
begin
  FChildren.Sort(CompareAIGroupTargetDataB);
end;

procedure TAIGroupControlTargetList.Add(Target: TAIGroupControlTarget);
begin
  AddChild(Target);
end;

procedure TAIGroupControlTargetList.Delete(Index: Integer);
begin
  RemoveChild(GetTargets(Index));
end;

function TAIGroupControlTargetList.Validate: Boolean;
var
  I: Integer;
  Target: TAIGroupControlTarget;
begin
  Result := True;
  AoWHSMap.FAIExecuter.UseProcessTime(Count * 20);
  for I := Count - 1 downto 0 do
  begin
    Target := TAIGroupControlTarget(FChildren.List^[I]);
    if not Target.Validate(FControl) then
    begin
      RemoveChild(Target);
      Result := False;
    end;
  end;
end;

function TAIGroupControlTargetList.IndexOfXYL(Location: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Location = TAIGroupControlTarget(FChildren.List^[Result]).FLocation.XYL then Exit;
  end;
  Result := -1;
end;

constructor TAIRecruitmentGroup.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
end;

destructor TAIRecruitmentGroup.Destroy;
begin
  SetGroup(nil);
  inherited Destroy;
end;

function TAIRecruitmentGroup.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIRecruitmentGroup.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

procedure TAIRecruitmentGroup.SetGroup(Group: TAIGroup);
var
  OldGroup: TAIGroup;
begin
  OldGroup := FGroup;
  if OldGroup <> Group then
  begin
    if OldGroup <> nil then OldGroup.Release;
    FGroup := Group;
    if FGroup <> nil then FGroup.AddRef;
  end;
end;

function TAIRecruitmentGroup.Validate(Control: TAIGroupControl): Boolean;
var
  Location: TXYL;
begin
  if FGroup.Count <> 0 then
  begin
    Location.XYL := FGroup.GetLoc;
    Result := (Location.X = FLocation.X) and (Location.Y = FLocation.Y) and
      (Location.L = FLocation.L) and (FGroup.FPlayer = Control.FGroup.FPlayer);
  end
  else Result := False;
end;

function TAIRecruitmentGroupList.GetRecruitmentGroups(Index: Integer): TAIRecruitmentGroup;
begin
  Assert((Index >= 0) and (Index < FChildren.Count));
  Result := TAIRecruitmentGroup(FChildren.List^[Index]);
end;

function CompareAIRecruitmentGroupMovePoints(Item1, Item2: Pointer): Integer;
begin
  Result := TAIRecruitmentGroup(Item2).FMovePoints - TAIRecruitmentGroup(Item1).FMovePoints;
end;

procedure TAIRecruitmentGroupList.SortOnMovePoints;
begin
  FChildren.Sort(CompareAIRecruitmentGroupMovePoints);
end;

procedure TAIRecruitmentGroupList.OutputDebugInfo;
var
  I: Integer;
  Text: string;
  Group: TAIRecruitmentGroup;
begin
  for I := 0 to Count - 1 do
  begin
    Group := GetRecruitmentGroups(I);
    Text := Group.FGroup.ClassName + '(ID:' + IntToStr(Group.FGroup.FGroupID) + ')';
    Text := Text + '/Loc:(' + IntToStr(Group.FLocation.X) + ',' +
      IntToStr(Group.FLocation.Y) + ',' + IntToStr(Group.FLocation.L) + ')';
    Text := Text + '/MP:' + IntToStr(Group.FMovePoints);
    Text := Text + '/MPBFS:' + IntToStr(Group.FPathStrength);
    AoWEngine.OutputDebugMessage(AIDID, Text);
  end;
end;

procedure TAIRecruitmentGroupList.Add(Group: TAIRecruitmentGroup);
begin
  AddChild(Group);
end;

procedure TAIRecruitmentGroupList.Delete(Index: Integer);
begin
  RemoveChild(GetRecruitmentGroups(Index));
end;

function TAIRecruitmentGroupList.Validate(Control: TAIGroupControl): Boolean;
var
  I: Integer;
  Group: TAIRecruitmentGroup;
begin
  Result := True;
  for I := Count - 1 downto 0 do
  begin
    Group := TAIRecruitmentGroup(FChildren.List^[I]);
    if not Group.Validate(Control) then
    begin
      RemoveChild(Group);
      Result := False;
    end;
  end;
end;

function TAIRecruitmentGroupList.UnitExists(AUnit: TAbstractUnit): Boolean;
var
  I: Integer;
begin
  Result := False;
  I := Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := TAIRecruitmentGroup(FChildren.List^[I]).FGroup.IndexOf(AUnit) <> -1;
  end;
end;

function TAIRecruitmentGroupList.FindUnit(AUnit: TAbstractUnit): TAIRecruitmentGroup;
var
  I: Integer;
begin
  Result := nil;
  I := Count;
  while (Result = nil) and (I <> 0) do
  begin
    Dec(I);
    if TAIRecruitmentGroup(FChildren.List^[I]).FGroup.IndexOf(AUnit) <> -1 then
      Result := TAIRecruitmentGroup(FChildren.List^[I]);
  end;
end;

constructor TAIGroupProductionLocation.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
end;

function TAIGroupProductionLocation.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIGroupProductionLocation.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

function TAIGroupProductionLocation.Validate(Control: TAIGroupControl): Boolean;
begin
  Result := True;
end;

function TAIGroupProductionLocationList.GetProductionLocation(Index: Integer): TAIGroupProductionLocation;
begin
  Assert((Index >= 0) and (Index < FChildren.Count));
  Result := TAIGroupProductionLocation(FChildren.List^[Index]);
end;

function CompareAIProductionLocationMovePoints(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroupProductionLocation(Item2).FMovePoints -
    TAIGroupProductionLocation(Item1).FMovePoints;
end;

procedure TAIGroupProductionLocationList.SortOnMovePoints;
begin
  FChildren.Sort(CompareAIProductionLocationMovePoints);
end;

procedure TAIGroupProductionLocationList.Add(Location: TAIGroupProductionLocation);
begin
  AddChild(Location);
end;

procedure TAIGroupProductionLocationList.Delete(Index: Integer);
begin
  RemoveChild(GetProductionLocation(Index));
end;

function TAIGroupProductionLocationList.IndexOfPC(Control: TProductionControl): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAIGroupProductionLocation(FChildren.List^[Result]).FProductionControl = Control then Exit;
  end;
  Result := -1;
end;

function TAIGroupProductionLocationList.FindPC(Control: TProductionControl): TAIGroupProductionLocation;
var
  I: Integer;
begin
  I := IndexOfPC(Control);
  if I <> -1 then
    Result := TAIGroupProductionLocation(FChildren.List^[I])
  else
    Result := nil;
end;

function TAIGroupProductionLocationList.Validate(Control: TAIGroupControl): Boolean;
var
  I: Integer;
  Location: TAIGroupProductionLocation;
begin
  Result := True;
  for I := Count - 1 downto 0 do
  begin
    Location := TAIGroupProductionLocation(FChildren.List^[I]);
    if not Location.Validate(Control) then
    begin
      RemoveChild(Location);
      Result := False;
    end;
  end;
end;

constructor TAIGroupControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargets := TAIGroupControlTargetList.Create(nil);
  FTargets.FControl := Self;
  FRecruitmentGroups := TAIRecruitmentGroupList.Create(nil);
  FProductionLocations := TAIGroupProductionLocationList.Create(nil);
  FCombatPredictor := TCombatPredictor.Create;
end;

destructor TAIGroupControl.Destroy;
begin
  DeactivatePlugin;
  FCombatPredictor.Free;
  FTargets.Free;
  FRecruitmentGroups.Free;
  FProductionLocations.Free;
  FGroup.Release;
  inherited Destroy;
end;

procedure TAIGroupControl.Done;
begin
  FGroup.FStatus := FGroup.FStatus + [agsDone];
  FState := -1;
end;

function TAIGroupControl.GetStrengthMax(DamageTypes: TDamageTypes): Integer;
var
  DamageType: TDamageType;
begin
  Result := 0;
  for DamageType := Low(TDamageType) to High(TDamageType) do
    if (DamageType in DamageTypes) and (Result < FStrength[DamageType]) then
      Result := FStrength[DamageType];
end;

procedure TAIGroupControl.UpdateGroupChanges;
var
  DamageType: TDamageType;
  AUnit: TAbstractUnit;
  I: Integer;
  MovePointTable: TP2MovePointTable;
begin
  if (agsChanged in FGroup.FStatus) or (FProcessCycles = 1) then
  begin
    FImmunityTypes := dtAll;
    FStrengthMax := 0;
    FillChar(FStrength, SizeOf(FStrength), 0);
    if FGroup.Count <> 0 then
      FillChar(FMovePointTable, SizeOf(FMovePointTable), 1)
    else
      FillChar(FMovePointTable, SizeOf(FMovePointTable), -1);
    for I := FGroup.Count - 1 downto 0 do
    begin
      AUnit := FGroup.GetUnit(I);
      FImmunityTypes := AUnit.GetImmunityTypes * FImmunityTypes;
      AUnit.CreateMovePointTable(MovePointTable);
      MaximizeMovePointTable(FMovePointTable, MovePointTable);
      for DamageType := Low(TDamageType) to High(TDamageType) do
        Inc(FStrength[DamageType], AUnit.GetStrength(DamageType));
      Inc(FStrengthMax, AUnit.GetStrengthMax(dtAll));
    end;
    FGroup.FStatus := FGroup.FStatus - [agsChanged];
  end;
end;

function TAIGroupControl.RetrieveGroupArmy(X, Y, L: Shortint; var Army: TArmy; var Selection: Byte): Boolean;
var
  ArmyHS: TArmyHS;
begin
  ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetArmyHS;
  if ArmyHS <> nil then
  begin
    Army := ArmyHS.FArmy;
    Selection := ArmyHS.FArmy.GetGroupSelection(FGroup.FGroupID);
    Result := True;
  end
  else
  begin
    Selection := 0;
    Army := nil;
    Result := False;
  end;
end;

procedure TAIGroupControl.CombineIdleGroups;
var
  Player: TPlayer;
  Group: TAIGroup;
  I: Integer;
  Location: TXYL;
begin
  Player := TPlayerList(AoWHSMap.FPlayers).GetPlayers(FGroup.FPlayer);
  for I := Player.FAIGroups.Count - 1 downto 0 do
  begin
    Group := Player.FAIGroups.GetGroups(I);
    if (Group <> FGroup) and (Group.ClassID = FGroup.ClassID) and
      (agsDone in Group.FStatus) then
      case Group.FTargetType of
        gtsIdle:
          begin
            Integer(Location) := Group.GetLoc;
            if (FLocation.L = Location.L) and
              (dHXtoRad(Location.X, Location.Y, FLocation.X, FLocation.Y) <= 1) then
              FGroup.AddUnits(Group);
          end;
      end;
  end;
end;

procedure TAIGroupControl.MoveExecuterDone;
begin
  if (FGroup.FTransporter <> nil) and not FMoveExecuter.GetTransporting then
    FGroup.DeleteUnit(FGroup.FTransporter);
  if FMoveExecuter.FStatus = mesInvalidated then
    FState := 0
  else if FMoveExecuter.FStatus = mesFailed then
  begin
    if not (agsSplit in FGroup.FStatus) then
    begin
      if not Split then Done;
    end
    else
      Done;
  end;
end;

procedure TAIGroupControl.ResetME;
begin
  FMoveExecuter.Reset;
  FMoveExecuter.FOnDone := MoveExecuterDone;
end;

procedure TAIGroupControl.SetupME;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  ResetME;
  AUnit := FGroup.FLeader;
  if AUnit <> nil then FMoveExecuter.AddUnit(AUnit);
  for I := 0 to FGroup.Count - 1 do
    if FGroup.GetUnit(I) <> FGroup.FLeader then
      FMoveExecuter.AddUnit(FGroup.GetUnit(I));
  if not FGroup.GetAdjacent then
    FMoveExecuter.FMode := FMoveExecuter.FMode - [memAdjacent];
  AUnit := FGroup.FTransporter;
  if AUnit <> nil then FMoveExecuter.AddTransporter(AUnit);
end;

procedure TAIGroupControl.ExecuteME(X, Y, L: Shortint);
var
  Field: TAoWMapField;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L));
  if (Field.GetPlayer <> -1) and (Field.GetPlayer <> FGroup.FPlayer) then
    FMoveExecuter.FMode := FMoveExecuter.FMode + [memAdjacent, memAttack];
  FMoveExecuter.ExecuteMove(X, Y, L);
end;

procedure TAIGroupControl.ResetCP;
var
  I: Integer;
begin
  FCombatPredictor.DeleteOpponents;
  for I := FCombatPredictor.FSides[0].Count - 1 downto 0 do
    if FGroup.IndexOf(FCombatPredictor.FSides[0].GetUnits(I).FUnit) = -1 then
      FCombatPredictor.DeleteUnit(FCombatPredictor.FSides[0].GetUnits(I).FUnit);
  for I := FGroup.Count - 1 downto 0 do
    if FCombatPredictor.FSides[0].IndexOfUnit(FGroup.GetUnit(I)) = -1 then
      FCombatPredictor.AddUnit(FGroup.GetUnit(I));
end;

procedure TAIGroupControl.SetupCP(Target: TAIGroupControlTarget);
begin
  ResetCP;
  if TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(Target.FLocation))).GetMoveAction(FGroup.FPlayer) <> maNegotiate then
    FCombatPredictor.InitAdjacentOpponents(FGroup.FPlayer, FGroup.FIndependentRelation,
      Target.FLocation.X, Target.FLocation.Y, Target.FLocation.L);
end;

procedure TAIGroupControl.RecruitmentGroupFoundEvent(Sender: TAIGroupControlPlugin; Group: TAIRecruitmentGroup; var SearchDone: Boolean);
begin
  FRecruitmentGroups.Add(Group);
end;

procedure TAIGroupControl.ProductionLocationFoundEvent(Sender: TAIGroupControlPlugin; Location: TAIGroupProductionLocation; var SearchDone: Boolean);
begin
  FProductionLocations.Add(Location);
end;

procedure TAIGroupControl.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
begin
  FTargets.Add(Target);
end;

function TAIGroupControl.Split: Boolean;
var
  I: Integer;
  Group: TAIGroup;
  X, Y, L, UnitX, UnitY, UnitL: Shortint;
  Finished, Found: Boolean;
begin
  Result := False;
  Finished := False;
  while not Finished do
  begin
    I := FGroup.Count;
    Found := False;
    while not Found and (I <> 0) do
    begin
      Dec(I);
      FGroup.GetUnit(I).GetLocation(X, Y, L);
      Found := (X <> FLocation.X) or (Y <> FLocation.Y) or
        (L <> FLocation.L);
    end;
    if Found then
    begin
      Group := TAIGroupManager(AoWHSMap.FAIGroupManager).CreateGroup(
        FGroup.FPlayer, FGroup.FIndependentRelation, FGroup.Behavior);
      Group.FStatus := Group.FStatus + [agsSplit];
      for I := FGroup.Count - 1 downto 0 do
      begin
        FGroup.GetUnit(I).GetLocation(UnitX, UnitY, UnitL);
        if (X = UnitX) and (Y = UnitY) and
          (L = UnitL) then
          Group.AddUnit(FGroup.GetUnit(I));
      end;
      if Group.Count <> 0 then
      begin
        FGroup.FStatus := FGroup.FStatus + [agsSplit];
        Result := True;
      end;
      Group.Release;
    end
    else
      Finished := True;
  end;
end;

procedure TAIGroupControl.Activate;
begin
  FState := 0;
  FMoveExecuter := TPlayerList(AoWHSMap.FPlayers).GetPlayers(FGroup.FPlayer).FAIControl.FMoveExecuter;
  TAIExecuter(AoWHSMap.FAIExecuter).UseProcessTime(100);
  FStatus := FStatus + [gcsActivated];
end;

procedure TAIGroupControl.Deactivate;
begin
  FMoveExecuter.FOnDone := nil;
  FStatus := FStatus - [gcsActivated];
end;

procedure TAIGroupControl.ActivatePlugin(Plugin: TAIGroupControlPlugin);
begin
  DeactivatePlugin;
  FPlugin := Plugin;
  FPlugin.AddRef;
  FPlugin.Activate(Self);
end;

procedure TAIGroupControl.DeactivatePlugin;
begin
  with Self do
    if FPlugin <> nil then
    begin
      FPlugin.Release;
      FPlugin := nil;
    end;
end;

procedure TAIGroupControl.ProcessStates;
begin
  Done;
end;

procedure TAIGroupControl.ProcessStatesLooped;
begin
  Done;
end;

procedure TAIGroupControl.MainProcessStates(Looped: Boolean);
begin
  try
    UpdateGroupChanges;
    if Looped then ProcessStatesLooped else ProcessStates;
  except
    raise;
  end;
end;

function TAIGroupControl.Validate: Boolean;
begin
  if not (agsDone in FGroup.FStatus) then
  begin
    FGroup.GetLocation(FLocation.X, FLocation.Y, FLocation.L);
    if FLocation.X <> -1 then
    begin
      FArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(FLocation))).GetArmyHS;
      RetrieveGroupArmy(FLocation.X, FLocation.Y, FLocation.L, FArmy, FSelection);
      UpdateGroupChanges;
      Result := True;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

function TAIGroupControl.Process(Looped: Boolean): Boolean;
var
  Busy: Boolean;
begin
  Inc(FProcessCycles);
  if Validate then
  begin
    try
      Busy := False;
      while not Busy and not (agsDone in FGroup.FStatus) and
        (TAIExecuter(AoWHSMap.FAIExecuter).GetProcessTimeLeft >= 0) and
        (FMoveExecuter.FStatus <> mesBusy) do
      begin
        if FPlugin <> nil then
        begin
          Busy := FPlugin.MainProcess;
          if not Busy then
          begin
            DeactivatePlugin;
            if (TAIExecuter(AoWHSMap.FAIExecuter).GetProcessTimeLeft >= 0) and
              not (agsDone in FGroup.FStatus) then MainProcessStates(Looped);
          end;
        end
        else
          MainProcessStates(Looped);
      end;
    except
      Done;
    end;
    Result := not (agsDone in FGroup.FStatus);
  end
  else
  begin
    Done;
    Result := False;
  end;
end;

function TAIGroupControl.FindAvailableTransporter: TAbstractUnit;
var
  I, Distance: Integer;
  AUnit: TAbstractUnit;
  List: TDoubleItemList;
  Location: TXYL;
  Player: TPlayer;
begin
  List := TDoubleItemList.Create;
  Player := TPlayerList(AoWHSMap.FPlayers).GetPlayers(FGroup.FPlayer);
  for I := 0 to Player.FArmies.Count - 1 do
  begin
    AUnit := Player.FArmies.GetArmy(I).Transporter($FF);
    if (AUnit <> nil) and ((AUnit.FGroup = nil) or (AUnit.FGroup.ClassID = $21467)) then
    begin
      AUnit.GetLocation(Location.X, Location.Y, Location.L);
      Distance := dHXtoRad(Location.X, Location.Y, FLocation.X, FLocation.Y);
      if (FLocation.L = Location.L) and (Distance < 30) then
        List.AddAB(Integer(AUnit), Distance);
    end;
  end;
  if List.Count <> 0 then
  begin
    List.SortAscendingItemB;
    Result := TAbstractUnit(List[0].A);
  end
  else
    Result := nil;
  List.Free;
end;

constructor TAIGroupControlPlugin.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FState := -1;
end;

function TAIGroupControlPlugin.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIGroupControlPlugin.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

procedure TAIGroupControlPlugin.Validate;
begin
end;

procedure TAIGroupControlPlugin.Done;
begin
  FState := -1;
end;

function TAIGroupControlPlugin.GetBusy: Boolean;
begin
  Result := (gpsActivated in FStatus) and (FState <> -1);
end;

function TAIGroupControlPlugin.Activate(Control: TAIGroupControl): Boolean;
begin
  FProcessCycles := 0;
  FGroupControl := Control;
  FStatus := FStatus + [gpsActivated];
  FState := 0;
  Result := True;
end;

procedure TAIGroupControlPlugin.Deactivate;
begin
  FStatus := FStatus - [gpsActivated];
end;

function TAIGroupControlPlugin.Process: Boolean;
begin
  Done;
  Result := False;
end;

function TAIGroupControlPlugin.MainProcess: Boolean;
var
  Busy: Boolean;
  I: Integer;
begin
  try
    Inc(FProcessCycles);
    Validate;
    Busy := False;
    I := 0;
    while not Busy and (FState <> -1) and
      ((I = 0) or (TAIExecuter(AoWHSMap.FAIExecuter).GetProcessTimeLeft > 0)) do
    begin
      Inc(I);
      Busy := Process;
    end;
  except
    raise Exception.Create(ClassName + ' exception during state (' + IntToStr(FState) + ')');
  end;
  Result := FState <> -1;
end;

constructor THuntAG.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargetUnitIDs := TIntegerList.Create;
end;

destructor THuntAG.Destroy;
begin
  FTargetUnitIDs.Free;
  inherited Destroy;
end;

class function THuntAG.ClassID: Integer;
begin
  Result := $21460;
end;

class function THuntAG.Behavior: TGroupBehavior;
begin
  Result := gbHunt;
end;

class function THuntAG.GroupControlClass: TAIGroupControlClass;
begin
  Result := THuntAGC;
end;

function THuntAG.HuntingPlayer(Player: Shortint): Boolean;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Result := False;
  I := FTargetUnitIDs.Count;
  while I <> 0 do
  begin
    Dec(I);
    AUnit := TUnitControl(AoWHSMap.FUnitControl).FindUnit(FTargetUnitIDs.List^[I]);
    { Original bug: each entry overwrites the result, including earlier matches. }
    Result := (AUnit <> nil) and (Player = AUnit.FPlayer);
  end;
end;

procedure THuntAG.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($1E, FTargetUnitIDs.LoadFromStream, FTargetUnitIDs.SaveToStream);
end;

procedure THuntAGC.TargetFoundEvent(Sender: TAIGroupControlPlugin; Target: TAIGroupControlTarget; var SearchDone: Boolean);
var
  Field: TAoWMapField;
  Army: TArmyHS;
  I: Integer;
  Group: THuntAG;
  Found: Boolean;
begin
  Field := TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(Target.FLocation)));
  if Field.GetPlayer <> FGroup.FPlayer then
  begin
    Army := Field.GetArmyHS;
    if Army <> nil then
    begin
      Group := THuntAG(FGroup);
      Found := False;
      I := Group.FTargetUnitIDs.Count;
      while not Found and (I <> 0) do
      begin
        Dec(I);
        Found := Army.FArmy.IndexOfID(Group.FTargetUnitIDs[I]) <> -1;
      end;
      if Found then
      begin
        SetupCP(Target);
        if FCombatPredictor.Execute in [crVictory, crDefeat, crBothDefeated] then
          if FCombatPredictor.GetEfficiency <> 0 then
          begin
            Target.FData.Priority := 1000 - Target.FMovePoints;
            inherited TargetFoundEvent(Sender, Target, SearchDone);
          end;
      end;
    end;
  end;
end;

procedure THuntAGC.ProcessStates;
var
  I: Integer;
  Finder: TAIGroupTargetFinder;
  Group: THuntAG;
  AUnit: TAbstractUnit;
  NewGroup: TAIGroup;
begin
  case FState of
    0:
      begin
        Group := THuntAG(FGroup);
        for I := Group.FTargetUnitIDs.Count - 1 downto 0 do
        begin
          AUnit := TUnitControl(AoWHSMap.FUnitControl).FindUnit(Group.FTargetUnitIDs[I]);
          if (AUnit = nil) or (AUnit.FPlayer = 0) then Group.FTargetUnitIDs.Delete(I);
        end;
        if Group.FTargetUnitIDs.Count <> 0 then
        begin
          Finder := TAIGroupTargetFinder.Create(nil);
          Finder.Setup(Self);
          Finder.FSelector.FTargetInfo.Mode := tmHunt;
          ActivatePlugin(Finder);
          Finder.Release;
          Inc(FState);
        end
        else
        begin
          NewGroup := TAIGroupManager(AoWHSMap.FAIGroupManager).CreateGroup(
            FGroup.FPlayer, FGroup.FIndependentRelation, gbPatrol);
          NewGroup.AddUnits(FGroup);
          NewGroup.Release;
          Done;
        end;
      end;
    1:
      begin
        if FTargets.Count <> 0 then
        begin
          SetupME;
          ExecuteME(FTargets.GetTargets(0).FLocation.X,
            FTargets.GetTargets(0).FLocation.Y, FTargets.GetTargets(0).FLocation.L);
          FTargets.Delete(0);
        end
        else
          Done;
      end;
  end;
end;

function TGroupControl.Behavior: TGroupBehavior;
begin
  Result := gbNone;
end;

class function TGuardGC.ClassID: Integer;
begin
  Result := $21402;
end;

function TGuardGC.Behavior: TGroupBehavior;
begin
  Result := gbGuard;
end;

class function TPassiveGC.ClassID: Integer;
begin
  Result := $21407;
end;

function TPassiveGC.Behavior: TGroupBehavior;
begin
  Result := gbPassive;
end;

class function TGuardAreaGC.ClassID: Integer;
begin
  Result := $21400;
end;

function TGuardAreaGC.Behavior: TGroupBehavior;
begin
  Result := gbGuardArea;
end;

class function TSuicidalGC.ClassID: Integer;
begin
  Result := $21403;
end;

function TSuicidalGC.Behavior: TGroupBehavior;
begin
  Result := gbSuicidal;
end;

class function TPatrolGC.ClassID: Integer;
begin
  Result := $21401;
end;

function TPatrolGC.Behavior: TGroupBehavior;
begin
  Result := gbPatrol;
end;

class function TScoutGC.ClassID: Integer;
begin
  Result := $21404;
end;

function TScoutGC.Behavior: TGroupBehavior;
begin
  Result := gbScout;
end;

class function TRefugeGC.ClassID: Integer;
begin
  Result := $21410;
end;

function TRefugeGC.Behavior: TGroupBehavior;
begin
  Result := gbRefuge;
end;

constructor TGroupDefenseSelector.Create;
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

function TGroupDefenseSelector.Execute(Group: TAIGroup; X, Y, L: Shortint; Units: TUnitList): Boolean;
begin Result := False; end;

constructor TAIGroupDefenseControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupDefenseControl.Destroy;
begin end;

function TAIGroupDefenseControl.GetBusy: Boolean;
begin Result := False; end;

function TAIGroupDefenseControl.Activate(Control: TAIGroupControl): Boolean;
begin Result := False; end;

function TAIGroupDefenseControl.Process: Boolean;
begin Result := False; end;

constructor TAIGroupTargetFinder.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelector := TAIMoveTargetSelector.Create(nil);
end;

destructor TAIGroupTargetFinder.Destroy;
begin
  FSelector.Free;
  inherited Destroy;
end;

procedure TAIGroupTargetFinder.TargetFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
var
  NewTarget: TAIGroupControlTarget;
begin
  NewTarget := TAIGroupControlTarget.Create(nil);
  NewTarget.FInfo := FSelector.FTargetInfo;
  NewTarget.FData := Target.FData;
  NewTarget.FLocation := Target.FLocation;
  NewTarget.FMovePoints := Target.FMovePoints;
  if tfmCalculateMovepathBFS in FMode then
    NewTarget.FPathStrength := GetMovepathBattleFieldStrength(FControl.FGroup.FPlayer,
      FControl.FGroup.FIndependentRelation, Target.FMovepath, FTargetRange, FRange, FStep);
  if Target.FTransporterID <> -1 then
    NewTarget.FTransporterID := Target.FTransporterID;
  FControl.TargetFoundEvent(Self, NewTarget, SearchDone);
  NewTarget.Release;
end;

procedure TAIGroupTargetFinder.Reset;
begin
  FSelector.Reset;
  with FSelector do
  begin
    FOnTargetFound := TargetFoundEvent;
    FMovePointsMax := 200;
    FMovePointsMin := 150;
  end;
  FDamageTypes := dtAll - [dtWall];
  FRange := 9;
  FTargetRange := 9;
  FStep := 4;
  FMode := [];
end;

function TAIGroupTargetFinder.Setup(Control: TAIGroupControl): Boolean;
begin
  Reset;
  FSelector.FSourceLocation := Control.FLocation;
  FSelector.FMovePointTable := Control.FMovePointTable;
  FSelector.FTargetInfo.Player := Control.FGroup.FPlayer;
  FSelector.FTargetInfo.IndependentRelation := Shortint(Control.FGroup.FIndependentRelation);
  FSelector.FTargetInfo.Mode := tmAttack;
  FSelector.FUnits.AddUnits(Control.FGroup);
  FMode := FMode + [tfmCalculateMovepathBFS];
  Result := True;
end;

function TAIGroupTargetFinder.Activate(Control: TAIGroupControl): Boolean;
begin
  inherited Activate(Control);
  FControl := Control;
  if tfmCalculateMovepathBFS in FMode then
    FSelector.FMode := FSelector.FMode + [tsmCreateMovepaths];
  FSelector.Search(Control);
  Result := True;
end;

function TAIGroupTargetFinder.GetBusy: Boolean;
begin
  Result := FSelector.FStatus = atsSearching;
end;

function TAIGroupTargetFinder.Process: Boolean;
begin
  if FSelector.FStatus = atsSearching then
  begin
    Result := FSelector.Process;
    if not Result then
    begin
      FControl.FTargets.SortOnPriority;
      Done;
    end;
  end
  else
  begin
    Result := False;
    Done;
  end;
end;

constructor TAIRecruitmentGroupFinder.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelector := TAIMoveTargetSelector.Create(nil);
end;

destructor TAIRecruitmentGroupFinder.Destroy;
begin
  FSelector.Free;
  inherited Destroy;
end;

function TAIRecruitmentGroupFinder.GetBusy: Boolean;
begin
  Result := FSelector.FStatus = atsSearching;
end;

procedure TAIRecruitmentGroupFinder.RecruitGroupFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
var
  I: Integer;
  ArmyHS: TArmyHS;
  AUnit: TAbstractUnit;
  Group: TAIRecruitmentGroup;
begin
  ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(Target.FLocation.X,
    Target.FLocation.Y, Target.FLocation.L)).GetArmyHS;
  if ArmyHS <> nil then
    for I := ArmyHS.FArmy.Count - 1 downto 0 do
    begin
      AUnit := ArmyHS.FArmy.GetUnit(I);
      if (AUnit.FGroup <> nil) and (AUnit.FGroup.FLeader = AUnit) and
        (AUnit.FGroup <> FControl.FGroup) then
      begin
        Group := TAIRecruitmentGroup.Create(nil);
        Group.SetGroup(AUnit.FGroup);
        Group.FLocation := Target.FLocation;
        Group.FMovePoints := Target.FMovePoints;
        Group.FTransporterID := Target.FTransporterID;
        if rfmCalculateMovepathBFS in FMode then
          Group.FPathStrength := GetMovepathBattleFieldStrength(FControl.FGroup.FPlayer,
            FControl.FGroup.FIndependentRelation, Target.FMovepath, FTargetRange, FRange, FStep);
        FControl.RecruitmentGroupFoundEvent(Self, Group, SearchDone);
        Group.Release;
      end;
    end;
end;

procedure TAIRecruitmentGroupFinder.Reset;
begin
  FMode := [];
  FSelector.Reset;
  FSelector.FOnTargetFound := RecruitGroupFoundEvent;
  FRange := 8;
  FStep := 1;
  FTargetRange := 5;
end;

function TAIRecruitmentGroupFinder.Setup(Control: TAIGroupControl): Boolean;
begin
  Reset;
  FSelector.FSourceLocation := Control.FLocation;
  FSelector.FMovePointTable := Control.FMovePointTable;
  FSelector.FTargetInfo.Player := Control.FGroup.FPlayer;
  FSelector.FTargetInfo.IndependentRelation := Shortint(Control.FGroup.FIndependentRelation);
  FSelector.FTargetInfo.Mode := tmRecruit;
  FSelector.FMovePointsMax := 75;
  FMode := FMode + [rfmCalculateMovepathBFS];
  Result := True;
end;

function TAIRecruitmentGroupFinder.Activate(Control: TAIGroupControl): Boolean;
begin
  inherited Activate(Control);
  FControl := Control;
  if rfmCalculateMovepathBFS in FMode then
    FSelector.FMode := FSelector.FMode + [tsmCreateMovepaths];
  FSelector.Search(Control);
  Result := True;
end;

function TAIRecruitmentGroupFinder.Process: Boolean;
begin
  if FSelector.FStatus = atsSearching then
    Result := FSelector.Process
  else
    Result := False;
  if not Result then Done;
end;

constructor TAIGroupRecruitControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnits := TUnitUserList.Create(nil);
end;

destructor TAIGroupRecruitControl.Destroy;
begin
  FUnits.Free;
  inherited Destroy;
end;

function TAIGroupRecruitControl.GetRecruitedStrength: Integer;
begin
  Result := FRecruitStrength - FRemainingStrength;
end;

function TAIGroupRecruitControl.GetRecruitStrengthEx(DamageType: TDamageType): Integer;
begin
  Result := FRecruitStrengths[DamageType];
end;

procedure TAIGroupRecruitControl.SetRecruitStrengthEx(DamageType: TDamageType; Value: Integer);
begin
  FRecruitStrengths[DamageType] := Value;
end;

function TAIGroupRecruitControl.GetBusy: Boolean;
begin
  Result := FState <> -1;
end;

function TAIGroupRecruitControl.GetRecruitMoveDays: Integer;
var
  Group: TAIRecruitmentGroup;
  I, Days: Integer;
begin
  Result := -1;
  for I := 0 to FUnits.Count - 1 do
  begin
    Group := FControl.FRecruitmentGroups.FindUnit(FUnits.GetUnit(I));
    if (Group <> nil) and (FUnits.GetUnit(I).GetMoves <> 0) then
    begin
      Days := (Group.FMovePoints - 1) div FUnits.GetUnit(I).GetMoves;
      if Days > Result then Result := Days;
    end;
  end;
end;

function TAIGroupRecruitControl.UsefullRecruitUnit(AUnit: TAbstractUnit): Boolean;
var
  D: TDamageType;
begin
  Result := (AUnit.GetMoves > FMovesMin) and (AUnit.GetMoveTypes * FMoveTypes <> []);
  if Result then
  begin
    Result := (FRemainingStrength > 0) and (AUnit.GetStrengthMax(FDamageTypes) > 0);
    if not Result then
    begin
      for D := Low(TDamageType) to High(TDamageType) do
      begin
        Result := (FRemainingStrengths[D] > 0) and (AUnit.GetStrength(D) > 0);
        if Result then Exit;
      end;
      if not Result and (FSuperiority <> -1) then
        Result := FControl.FCombatPredictor.Usefullness(AUnit) and $800000 <> 0;
    end;
  end;
end;

procedure TAIGroupRecruitControl.UpdateCompletion;
var
  D: TDamageType;
begin
  FComplete := FRemainingStrength <= 0;
  if FComplete then
  begin
    for D := Low(TDamageType) to High(TDamageType) do
      if FRemainingStrengths[D] > 0 then
      begin
        FComplete := False;
        Exit;
      end;
    if FSuperiority <> -1 then
    begin
      FControl.FCombatPredictor.Execute;
      if FControl.FCombatPredictor.GetSuperiority < FSuperiority then
        FComplete := False;
    end;
  end;
end;

procedure TAIGroupRecruitControl.AddRecruitUnit(AUnit: TAbstractUnit);
var
  D: TDamageType;
begin
  FUnits.AddUnit(AUnit);
  for D := Low(TDamageType) to High(TDamageType) do
    Dec(FRemainingStrengths[D], AUnit.GetStrength(D));
  Dec(FRemainingStrength, AUnit.GetStrengthMax(FDamageTypes));
  if FSuperiority <> -1 then
    FControl.FCombatPredictor.AddUnit(AUnit);
  UpdateCompletion;
end;

procedure TAIGroupRecruitControl.DeleteRecruitUnit(AUnit: TAbstractUnit);
var
  D: TDamageType;
begin
  if FUnits.IndexOf(AUnit) <> -1 then
  begin
    for D := Low(TDamageType) to High(TDamageType) do
      Inc(FRemainingStrengths[D], AUnit.GetStrength(D));
    Inc(FRemainingStrength, AUnit.GetStrengthMax(FDamageTypes));
    if FSuperiority <> -1 then
      FControl.FCombatPredictor.DeleteUnit(AUnit);
    FUnits.DeleteUnit(AUnit);
    UpdateCompletion;
  end;
end;

procedure TAIGroupRecruitControl.ExecuteRecruitment;
begin
  FControl.FGroup.AddUnits(FUnits);
end;

function TAIGroupRecruitControl.ValidRecruitmentGroup(Group: TAIRecruitmentGroup): Boolean;
begin
  if Group.FPathStrength <> 0 then
  begin
    Result := Group.FGroup.GetStrengthMax(dtAll - [dtWall]) >=
      Round(Group.FPathStrength * FPathStrengthFactor);
    if not Result then
      if FMode <> rcmForceRecruit then
        Result := Group.FGroup.GetMovePointsMin >= Group.FMovePoints
      else
        Result := Group.FGroup.GetMovePointsMin + 20 >= Group.FMovePoints;
  end
  else
    Result := True;
end;

function TAIGroupRecruitControl.RecruitFromGroup(Group: TAIRecruitmentGroup): Boolean;
var
  Units, Recruitable: TUnitUserList;
  I: Integer;
  AUnit: TAbstractUnit;
begin
  Result := False;
  Units := TUnitUserList.Create(nil);
  for I := Group.FGroup.Count - 1 downto 0 do
    if UsefullRecruitUnit(Group.FGroup.GetUnit(I)) then
      Units.AddUnit(Group.FGroup.GetUnit(I));
  if Units.Count <> 0 then
  begin
    Recruitable := TUnitUserList.Create(nil);
    if FMode <> rcmForceRecruit then
      Group.FGroup.GetRecruitableUnits(Integer(FControl.FGroup), Units, Recruitable)
    else
      Recruitable.AddUnits(Units);
    I := 0;
    while (I < Recruitable.Count) and not FComplete do
    begin
      AUnit := Recruitable.GetUnit(I);
      if UsefullRecruitUnit(AUnit) then
      begin
        AddRecruitUnit(AUnit);
        Result := True;
      end;
      Inc(I);
    end;
    Recruitable.Free;
  end;
  Units.Free;
end;

procedure TAIGroupRecruitControl.Reset;
begin
  FUnits.Clear;
  FState := 0;
  FMovesMin := 0;
  FSuperiority := -1;
  FRecruitStrength := 0;
  FDamageTypes := dtAll - [dtWall];
  { Original bug: clears only the maximum strength, not the per-type array. }
  FillChar(FRecruitStrength, SizeOf(FRecruitStrength), 0);
  FMoveTypes := [mtWalking, mtFlying];
  FPathStrengthFactor := 0.8;
  FComplete := False;
  FMode := rcmAutoRecruit;
end;

function TAIGroupRecruitControl.Setup: Boolean;
begin
  Reset;
  Result := True;
end;

function TAIGroupRecruitControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FControl := Control;
  FRemainingStrength := FRecruitStrength;
  UpdateCompletion;
  Result := True;
end;

function TAIGroupRecruitControl.Process: Boolean;
var
  I: Integer;
begin
  case FState of
    0:
      begin
        AoWHSMap.FAIExecuter.UseProcessTime(500);
        I := 0;
        FControl.FRecruitmentGroups.Validate(FControl);
        while not FComplete and (I <> FControl.FRecruitmentGroups.Count) do
        begin
          if ValidRecruitmentGroup(FControl.FRecruitmentGroups.GetRecruitmentGroups(I)) then
            RecruitFromGroup(FControl.FRecruitmentGroups.GetRecruitmentGroups(I));
          Inc(I);
        end;
        if (FMode in [rcmAutoRecruit, rcmForceRecruit]) or
          ((FMode = rcmCompleteRecruitOnly) and FComplete) then
          ExecuteRecruitment;
        Done;
      end;
  else
    Done;
  end;
  Result := False;
end;

constructor TAIProductionLocationFinder.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelector := TAIMoveTargetSelector.Create(nil);
end;

destructor TAIProductionLocationFinder.Destroy;
begin
  FSelector.Free;
  inherited Destroy;
end;

function TAIProductionLocationFinder.GetBusy: Boolean;
begin
  Result := FSelector.FStatus = atsSearching;
end;

procedure TAIProductionLocationFinder.ProductionLocationFoundEvent(Target: TMoveTarget; var SearchDone: Boolean);
var
  Location: TAIGroupProductionLocation;
  Control: TProductionControl;
begin
  Control := TAoWMapField(AoWHSMap.MapContainer.GetField(Target.FLocation.X,
    Target.FLocation.Y, Target.FLocation.L)).GetProductionControl;
  if FControl.FProductionLocations.IndexOfPC(Control) = -1 then
  begin
    Location := TAIGroupProductionLocation.Create(nil);
    Location.FProductionControl := Control;
    Location.FLocation := Target.FLocation;
    Location.FMovePoints := Target.FMovePoints;
    Location.FTransporterID := Target.FTransporterID;
    if pfmCalculateMovepathBFS in FMode then
      Location.FPathStrength := GetMovepathBattleFieldStrength(FControl.FGroup.FPlayer,
        FControl.FGroup.FIndependentRelation, Target.FMovepath, FTargetRange, FRange, FStep);
    FControl.ProductionLocationFoundEvent(Self, Location, SearchDone);
    Location.Release;
  end;
end;

procedure TAIProductionLocationFinder.Reset;
begin
  FSelector.Clear;
  FSelector.FOnTargetFound := ProductionLocationFoundEvent;
  FMode := [];
  FRange := 8;
  FStep := 1;
  FTargetRange := 5;
end;

function TAIProductionLocationFinder.Setup(Control: TAIGroupControl): Boolean;
begin
  Reset;
  FSelector.FSourceLocation := Control.FLocation;
  FSelector.FMovePointTable := Control.FMovePointTable;
  FSelector.FTargetInfo.Player := Control.FGroup.FPlayer;
  FSelector.FTargetInfo.IndependentRelation := Shortint(Control.FGroup.FIndependentRelation);
  FSelector.FTargetInfo.Mode := tmProduce;
  FSelector.FMovePointsMax := 75;
  FMode := FMode + [pfmCalculateMovepathBFS];
  Result := True;
end;

function TAIProductionLocationFinder.Activate(Control: TAIGroupControl): Boolean;
begin
  inherited Activate(Control);
  FControl := Control;
  if pfmCalculateMovepathBFS in FMode then
    FSelector.FMode := FSelector.FMode + [tsmCreateMovepaths];
  FSelector.Search(Control);
  Result := True;
end;

function TAIProductionLocationFinder.Process: Boolean;
begin
  if FSelector.FStatus = atsSearching then
  begin
    Result := FSelector.Process;
    if not Result then Done;
  end
  else
  begin
    Result := False;
    Done;
  end;
end;

constructor TAIGroupUnitProduction.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
end;

destructor TAIGroupUnitProduction.Destroy;
begin
  SetU(nil);
  SetProductionLocation(nil);
  inherited Destroy;
end;

function TAIGroupUnitProduction.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIGroupUnitProduction.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then Destroy;
end;

procedure TAIGroupUnitProduction.SetU(U: TUnit);
begin
  if U <> FU then
  begin
    if FU <> nil then FU.Release;
    FU := U;
    if FU <> nil then FU.AddRef;
  end;
end;

procedure TAIGroupUnitProduction.SetProductionLocation(Location: TAIGroupProductionLocation);
begin
  if Location <> FProductionLocation then
  begin
    if FProductionLocation <> nil then FProductionLocation.Release;
    FProductionLocation := Location;
    if FProductionLocation <> nil then FProductionLocation.AddRef;
  end;
end;

function TAIGroupUnitProductionList.GetUnitProductions(Index: Integer): TAIGroupUnitProduction;
begin
  Result := TAIGroupUnitProduction(FChildren.EObjects[Index]);
end;

constructor TAIGroupProductionControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FProductions := TAIGroupUnitProductionList.Create(nil);
  FProduceableUnits := TAIGroupUnitProductionList.Create(nil);
end;

destructor TAIGroupProductionControl.Destroy;
begin
  FProductions.Free;
  FProductions := nil;
  FProduceableUnits.Free;
  FProduceableUnits := nil;
  inherited Destroy;
end;

function TAIGroupProductionControl.GetProducedStrength: Integer;
begin
  Result := FProduceStrength - FRemainingStrength;
end;

function TAIGroupProductionControl.GetProduceStrengthEx(DamageType: TDamageType): Integer;
begin
  Result := FProduceStrengths[DamageType];
end;

procedure TAIGroupProductionControl.SetProduceStrengthEx(DamageType: TDamageType; Value: Integer);
begin
  FProduceStrengths[DamageType] := Value;
end;

function TAIGroupProductionControl.GetBusy: Boolean;
begin
  Result := FState <> -1;
end;

function TAIGroupProductionControl.UnitProductionPriority(AUnit: TUnit): Integer;
var
  Usefull: Boolean;
  D: TDamageType;
begin
  Result := -1;
  Usefull := (AUnit.GetMoves > FMovesMin) and (AUnit.GetMoveTypes * FMoveTypes <> []);
  Usefull := Usefull and (AUnit.GetUnitMoraleValue(FControl.FGroup.FPlayer,
    FControl.FGroup.FIndependentRelation) >= 50);
  if Usefull and (FControl.FGroup.FPlayer = 0) then
    Usefull := (FControl.FGroup.FIndependentRelation < 0) or
      (AUnit.GetIndependentRelation < 0) or
      (AUnit.GetIndependentRelation = FControl.FGroup.FIndependentRelation);
  if Usefull then
  begin
    Usefull := (FRemainingStrength > 0) and (AUnit.GetStrengthMax(FDamageTypes) > 0);
    if not Usefull then
    begin
      for D := Low(TDamageType) to High(TDamageType) do
      begin
        Usefull := (FRemainingStrengths[D] > 0) and (AUnit.GetStrength(D) > 0);
        { Original bug: a useful per-type strength returns the initial -1 priority. }
        if Usefull then Exit;
      end;
      if not Usefull and (FSuperiority <> -1) then
      begin
        Usefull := FControl.FCombatPredictor.Usefullness(AUnit) and $800000 <> 0;
        if Usefull then Inc(Result, 50);
      end;
    end;
  end;
  if Usefull then
    Inc(Result, GetUnitIndexAIPriority(AUnit.FUnitResource.UnitResourceIndex,
      FControl.FGroup.FPlayer, FControl.FGroup.FIndependentRelation))
  else
    Result := -1;
end;

function TAIGroupProductionControl.GetCurrentProductionTime: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FProductions.Count - 1 do
    if FProductions.GetUnitProductions(I).FProductionTime > Result then
      Result := FProductions.GetUnitProductions(I).FProductionTime;
end;

function TAIGroupProductionControl.GetCompleteProductionTime: Integer;
begin
  Result := GetCurrentProductionTime;
  if (Result <> -1) and (FRemainingStrength > 0) and (GetProducedStrength > 0) then
    Inc(Result, Trunc(FRemainingStrength / GetProducedStrength * Result + 0.999));
end;

procedure TAIGroupProductionControl.UpdateCompletion;
var
  D: TDamageType;
begin
  FComplete := FRemainingStrength <= 0;
  if FComplete then
  begin
    for D := Low(TDamageType) to High(TDamageType) do
      if FRemainingStrengths[D] > 0 then
      begin
        FComplete := False;
        Exit;
      end;
    if FSuperiority <> -1 then
    begin
      FControl.FCombatPredictor.Execute;
      if FControl.FCombatPredictor.GetSuperiority < FSuperiority then
        FComplete := False;
    end;
  end;
end;

function TAIGroupProductionControl.ExecuteProductions(GroupID: Integer): Boolean;
var
  I: Integer;
  Production: TAIGroupUnitProduction;
  Control: TProductionControl;
begin
  Result := True;
  for I := 0 to FProductions.Count - 1 do
  begin
    Production := FProductions.GetUnitProductions(I);
    Control := Production.FProductionLocation.FProductionControl;
    if not Production.FResearch then
    begin
      if Control.ExecuteAIProduction(Control.FUnitProductions.IndexOf(
        Production.FU.FUnitResource.UnitResourceIndex), GroupID) then
        AoWHSMap.FPlayers.GetPlayers(FControl.FGroup.FPlayer).FAIBudget.ProductionExpenseMade(
          Production.FGold, Production.FGoldUpkeep, Production.FMana, Production.FManaUpkeep)
      else
        Result := False;
    end
    else
      if Control.ExecuteAIResearch(Control.FUnitProductions.IndexOf(
        Production.FU.FUnitResource.UnitResourceIndex)) then
        AoWHSMap.FPlayers.GetPlayers(FControl.FGroup.FPlayer).FAIBudget.ProductionExpenseMade(
          Production.FGold, Production.FGoldUpkeep, Production.FMana, Production.FManaUpkeep);
  end;
end;

procedure TAIGroupProductionControl.AddProduction(Production: TAIGroupUnitProduction);
var
  D: TDamageType;
begin
  FProductions.AddChild(Production);
  Inc(FGold, Production.FGold);
  Inc(FMana, Production.FMana);
  { Original bug: upkeep is based on total costs rather than accumulated upkeep. }
  FGoldUpkeep := FGold + Production.FGoldUpkeep;
  FManaUpkeep := FMana + Production.FManaUpkeep;
  for D := Low(TDamageType) to High(TDamageType) do
    Dec(FRemainingStrengths[D], Production.FU.GetStrength(D));
  Dec(FRemainingStrength, Production.FU.GetStrengthMax(FDamageTypes));
  if FSuperiority <> -1 then
    FControl.FCombatPredictor.AddUnit(Production.FU);
  UpdateCompletion;
end;

procedure TAIGroupProductionControl.DeleteProduction(Index: Integer);
var
  Production: TAIGroupUnitProduction;
  D: TDamageType;
begin
  if (Index >= 0) and (Index < FProductions.Count) then
  begin
    Production := FProductions.GetUnitProductions(Index);
    Dec(FGold, Production.FGold);
    Dec(FMana, Production.FMana);
    Dec(FGoldUpkeep, Production.FGoldUpkeep);
    Dec(FManaUpkeep, Production.FManaUpkeep);
    for D := Low(TDamageType) to High(TDamageType) do
      Inc(FRemainingStrengths[D], Production.FU.GetStrength(D));
    Inc(FRemainingStrength, Production.FU.GetStrengthMax(FDamageTypes));
    if FSuperiority <> -1 then
      FControl.FCombatPredictor.DeleteUnit(Production.FU);
    FProductions.RemoveChild(Production);
    UpdateCompletion;
  end;
end;

procedure TAIGroupProductionControl.Reset;
begin
  FProductions.Clear;
  FState := 0;
  FMovesMin := 0;
  FSuperiority := -1;
  { Original clears the production list twice and leaves the candidate list alone. }
  FProductions.Clear;
  FGold := 0;
  FMana := 0;
  FGoldUpkeep := 0;
  FManaUpkeep := 0;
  FProduceStrength := 0;
  FDamageTypes := dtAll - [dtWall];
  FillChar(FProduceStrengths, SizeOf(FProduceStrengths), 0);
  FMoveTypes := [mtWalking, mtFlying];
  FComplete := False;
  FMode := pcmAutoProduce;
  FMultiple := False;
  FGroupID := 0;
  FMovePointPriority := -5;
  FResearchPriority := -500;
  FAllowResearch := True;
  FPathStrengthFactor := 0.8;
end;

function TAIGroupProductionControl.Setup(Control: TAIGroupControl): Boolean;
begin
  Reset;
  FGroupID := Control.FGroup.FGroupID;
  Result := True;
end;

function TAIGroupProductionControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FControl := Control;
  FRemainingStrength := FProduceStrength;
  UpdateCompletion;
  Result := True;
end;

function TAIGroupProductionControl.ListProduceableUnits(Location: TAIGroupProductionLocation): Boolean;
var
  I: Integer;
  Production: TAIGroupUnitProduction;
  Priority: Integer;
  TestUnit, NewUnit: TUnit;
begin
  Result := False;
  if Location.FProductionControl.FStatus = pcsIdle then
  begin
    TestUnit := TUnit.Create(nil);
    for I := 0 to Location.FProductionControl.FUnitProductions.Count - 1 do
      if Location.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex <> -1 then
      begin
        if Location.FProductionControl.FUnitProductions.GetItem(I).FResearched then
        begin
          if AoWHSMap.FPlayers.GetPlayers(FControl.FGroup.FPlayer).FAIBudget.RequestProductionExpense(
            Location.FProductionControl.UnitProductionGold(I) + FGold,
            Location.FProductionControl.UnitProductionGoldUpkeep(I) + FGoldUpkeep,
            Location.FProductionControl.UnitProductionMana(I) + FMana,
            Location.FProductionControl.UnitProductionManaUpkeep(I) + FManaUpkeep) then
          begin
            TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(
              Location.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex));
            Priority := UnitProductionPriority(TestUnit);
            if Priority <> -1 then
            begin
              NewUnit := TUnit.Create(nil);
              NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(
                Location.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex));
              Production := TAIGroupUnitProduction.Create(nil);
              Production.SetU(NewUnit);
              Production.FGold := Location.FProductionControl.UnitProductionGold(I);
              Production.FMana := Location.FProductionControl.UnitProductionMana(I);
              Production.FGoldUpkeep := Location.FProductionControl.UnitProductionGoldUpkeep(I);
              Production.FManaUpkeep := Location.FProductionControl.UnitProductionManaUpkeep(I);
              Production.SetProductionLocation(Location);
              Production.FPriority := FMovePointPriority * Location.FMovePoints + Priority;
              Production.FResearch := False;
              Production.FProductionTime := Location.FProductionControl.UnitProductionTime(I);
              FProduceableUnits.AddChild(Production);
              Production.Release;
              NewUnit.Release;
              Result := True;
            end;
          end;
        end
        else
          if FAllowResearch then
            if AoWHSMap.FPlayers.GetPlayers(FControl.FGroup.FPlayer).FAIBudget.RequestProductionExpense(
              Location.FProductionControl.UnitResearchGold(I) + FGold, FGoldUpkeep,
              Location.FProductionControl.UnitResearchMana(I) + FMana, FManaUpkeep) then
            begin
              TestUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(
                Location.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex));
              Priority := UnitProductionPriority(TestUnit);
              if Priority <> -1 then
              begin
                NewUnit := TUnit.Create(nil);
                NewUnit.SetUnitResource(AoWHSSet.FUnitResources.GetUnitResource(
                  Location.FProductionControl.FUnitProductions.GetItem(I).FUnitIndex));
                Production := TAIGroupUnitProduction.Create(nil);
                Production.SetU(NewUnit);
                Production.FGold := Location.FProductionControl.UnitResearchGold(I);
                Production.FMana := Location.FProductionControl.UnitResearchMana(I);
                Production.FGoldUpkeep := Location.FProductionControl.UnitProductionGoldUpkeep(I);
                Production.FManaUpkeep := Location.FProductionControl.UnitProductionManaUpkeep(I);
                Production.SetProductionLocation(Location);
                Production.FPriority := FMovePointPriority * Location.FMovePoints + Priority + FResearchPriority;
                Production.FResearch := True;
                FProduceableUnits.AddChild(Production);
                Production.Release;
                NewUnit.Release;
                Result := True;
              end;
            end;
      end;
    TestUnit.Free;
  end;
end;

function TAIGroupProductionControl.ValidProductionLocation(Location: TAIGroupProductionLocation): Boolean;
begin
  if Location.FPathStrength <> 0 then
  begin
    Result := FControl.FGroup.GetStrengthMax(dtAll - [dtWall]) >=
      Round(Location.FPathStrength * FPathStrengthFactor);
    if not Result then
      Result := FControl.FGroup.GetMovePointsMin >= Location.FMovePoints;
  end
  else
    Result := True;
end;

function CompareProduceableUnits(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroupUnitProduction(Item2).FPriority - TAIGroupUnitProduction(Item1).FPriority;
end;

procedure TAIGroupProductionControl.UpdateProduceableUnits;
var
  I: Integer;
begin
  FProduceableUnits.Clear;
  for I := 0 to FControl.FProductionLocations.Count - 1 do
    if ValidProductionLocation(FControl.FProductionLocations.GetProductionLocation(I)) then
      ListProduceableUnits(FControl.FProductionLocations.GetProductionLocation(I));
  FProduceableUnits.FChildren.Sort(CompareProduceableUnits);
end;

function TAIGroupProductionControl.Process: Boolean;
var
  I, Index: Integer;
  Production: TAIGroupUnitProduction;
  Finished: Boolean;
begin
  case FState of
    0:
      begin
        if FControl.FGroup.FProductions.Count = 0 then
        begin
          AoWHSMap.FAIExecuter.UseProcessTime(500);
          Finished := False;
          FControl.FProductionLocations.Validate(FControl);
          while not FComplete and not Finished do
          begin
            UpdateProduceableUnits;
            if FProduceableUnits.Count <> 0 then
            begin
              Index := 0;
              while (FProduceableUnits.Count > Index + 1) and
                (FProduceableUnits.GetUnitProductions(Index + 1).FPriority >
                 FProduceableUnits.GetUnitProductions(0).FPriority - FPriorityRange) do
                Inc(Index);
              { Original passes the last eligible index, not the candidate count. }
              Index := AoWHSMap.Random(Index);
              AddProduction(FProduceableUnits.GetUnitProductions(Index));
              if not FMultiple then Finished := True;
            end
            else
              Finished := True;
          end;
          if ((FProductions.Count <> 0) and (FMode = pcmAutoProduce)) or
            ((FMode = pcmCompleteProduceOnly) and FComplete) then
            ExecuteProductions(FGroupID);
          Done;
        end
        else
        begin
          for I := 0 to FControl.FGroup.FProductions.Count - 1 do
          begin
            Production := TAIGroupUnitProduction.Create(nil);
            Production.SetU(FControl.FGroup.FProductions.GetProductions(I).FControl.FSettings.FUnit);
            if Production.FU <> nil then
            begin
              Production.FGold := 0;
              Production.FMana := 0;
              Production.FGoldUpkeep := 0;
              Production.FManaUpkeep := 0;
              Production.SetProductionLocation(FControl.FProductionLocations.FindPC(
                FControl.FGroup.FProductions.GetProductions(I).FControl));
              Production.FPriority := 0;
              Production.FResearch := False;
              if Production.FProductionLocation <> nil then
                AddProduction(Production);
            end;
            Production.Release;
          end;
          Done;
        end;
      end;
  else
    Done;
  end;
  Result := False;
end;

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

function TAIGroupCooperationControl.GetBusy: Boolean;
begin Result := False; end;

procedure TAIGroupCooperationControl.Setup(A1: Integer; A2: Integer);
begin end;

function TAIGroupCooperationControl.Activate(Control: TAIGroupControl): Boolean;
begin Result := False; end;

procedure TAIGroupCooperationControl.AddCooperationGroup(A1: Integer; A2: Integer);
begin end;

procedure TAIGroupCooperationControl.ValidCooperationGroup(A1: Integer);
begin end;

procedure TAIGroupCooperationControl.ExecuteCooperation(A1: Integer; A2: Integer);
begin end;

function TAIGroupCooperationControl.Process: Boolean;
begin Result := False; end;

constructor TAIGroupTargetSelector.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIGroupTargetSelector.Destroy;
begin end;

function TAIGroupTargetSelector.GetBusy: Boolean;
begin Result := False; end;

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

function TAIGroupTargetSelector.Activate(Control: TAIGroupControl): Boolean;
begin Result := False; end;

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

function TAIGroupTargetSelector.Process: Boolean;
begin Result := False; end;

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

procedure TAIMoveControlSettings.Setup(Army: TArmyHS; Selection: Byte; X, Y, L: Integer);
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

procedure TAIMoveControl.CanMove(Settings: TAIMoveControlSettings);
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

function TMoveTargetList.GetTarget(Index: Integer): TMoveTarget;
begin Result := nil; end;

function TMoveTargetList.IndexOfXYL(Location: Integer): Integer;
begin Result := 0; end;

procedure TMoveTargetList.AddTargetEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMoveTargetList.SortOnMovePoints;
begin end;

procedure TAIMoveExecuterUnit.Initialize(AUnit: TAbstractUnit; X, Y, L: Shortint);
begin end;

function TAIMoveExecuterUnit.Validate: Boolean;
begin Result := False; end;

procedure TAIMoveExecuterUnit.ResetTransporterSettings;
begin end;

function TAIMoveExecuterUnitList.GetUnits(Index: Integer): TAIMoveExecuterUnit;
begin Result := nil; end;

function TAIMoveExecuterUnitList.IndexOfUnitID(ID: Integer): Integer;
begin Result := 0; end;

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

procedure TAIMoveExecuterUnitList.SetTransportStatus(Selection: Byte; Status: TAIMoveExecuterTransportStatus);
begin end;

procedure TAIMoveExecuterUnitList.SetStatus(Selection: Byte; Status: TAIMoveExecuterUnitStatus);
begin end;

constructor TAIMoveExecuterMove.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveExecuterMove.Destroy;
begin end;

procedure TAIMoveExecuterMove.AddUnits(Units: TAIMoveExecuterUnitList; Selection: Byte);
begin end;

procedure TAIMoveExecuterMove.AddUnit;
begin end;

procedure TAIMoveExecuterMove.SetUnitStatus(Status: TAIMoveExecuterUnitStatus);
begin end;

function TAIMoveExecuterMove.RetrieveArmy(var Army: TArmyHS; var Selection: Byte): Boolean;
begin Result := False; end;

function TAIMoveExecuterMoveQueue.GetMoves(Index: Integer): TAIMoveExecuterMove;
begin Result := nil; end;

procedure TAIMoveExecuterMoveQueue.Reset;
begin end;

procedure TAIMoveExecuterMoveQueue.Clear;
begin end;

procedure TAIMoveExecuterArmy.Setup(Transporter: TAIMoveExecuterUnit);
begin end;

function TAIMoveExecuterArmy.CanAdd(UnitEntry: TAIMoveExecuterUnit): Boolean;
begin Result := False; end;

procedure TAIMoveExecuterArmy.RetrieveArmy(Selection: Byte; var Army: TArmyHS; var ArmySelection: Byte);
begin end;

procedure TAIMoveExecuterArmy.ResetTransporterSettings;
begin end;

function TAIMoveExecuterArmy.WaitingForTransport: Boolean;
begin Result := False; end;

procedure TAIMoveExecuterArmy.Moves(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterArmy.MovePoints(A1: Integer; A2: Integer);
begin end;

procedure TAIMoveExecuterArmy.ValidTerrain(A1: Integer; A2: Byte; A3: Integer);
begin end;

function TAIMoveExecuterArmyList.GetArmies(Index: Integer): TAIMoveExecuterArmy;
begin Result := nil; end;

function TAIMoveExecuterArmyList.IndexOf(Army: TArmyHS; Selection: Byte): Integer;
begin Result := 0; end;

procedure TAIMoveExecuterArmyList.IndexOfXYL(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAIMoveExecuterArmyList.IndexOfLoc(A1: Integer; A2: Integer);
begin end;

function TAIMoveExecuterArmyList.IndexOfTransportStatus(Status: TAIMoveExecuterTransportStatus): Integer;
begin Result := 0; end;

procedure TAIMoveExecuterArmyList.SortOnMovePoints;
begin end;

constructor TAIMoveExecuterControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAIMoveExecuterControl.Destroy;
begin end;

function TAIMoveExecuterControl.CreateMove(Army: TAIMoveExecuterArmy; Selection: Byte; X, Y, L: Shortint; Mode: TArmyMoveMode; MoveResult: PByte): TAIMoveExecuterMove;
begin Result := nil; end;

function TAIMoveExecuterControl.CanMoveTo(Army: TAIMoveExecuterArmy; Selection: Byte; X, Y, L: Shortint): Byte;
begin Result := 0; end;

procedure TAIMoveExecuterControl.Activate(Executer: TAIMoveExecuter);
begin end;

procedure TAIMoveExecuterControl.Deactivate;
begin end;

procedure TAIMoveExecuterControl.CalculateMoves;
begin end;

procedure TAIMoveExecuterControl.Done;
begin end;

function TAIMoveExecuterControl.Process: Boolean;
begin Result := False; end;

procedure TDefaultMEC.CalculateMoves;
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

procedure TAdjacentMEC.CalculateMoves;
begin end;

function TTransportMEC.CreateTransporterMove(X, Y, L: Shortint; Queue: Boolean): TAIMoveExecuterMove;
var
  Move: TAIMoveExecuterMove;
  MovePoints, Pos, I: Integer;
  Army: TAIMoveExecuterArmy;
  UnitEntry: TAIMoveExecuterUnit;
  ArmyHS: TArmyHS;
  Settings: TMoveControlSettings;
begin
  Move := nil;
  Army := TAIMoveExecuterArmy.Create(nil);
  Army.Setup(FExecuter.FTransporter);
  for I := 0 to FExecuter.FUnits.Count - 1 do
  begin
    UnitEntry := FExecuter.FUnits.GetUnits(I);
    if Integer(UnitEntry.FLocation) = Integer(FExecuter.FTransporter.FLocation) then
      Army.AddChild(UnitEntry);
  end;
  with FExecuter.FTransporter do
    ArmyHS := TAoWMapField(AoWHSMap.MapContainer.GetField(FLocation.X, FLocation.Y, FLocation.L)).GetArmyHS;
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetupArmy(ArmyHS, $FF);
  Settings.SetDestinationPos(X, Y, L);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
  begin
    MovePoints := ArmyHS.FArmy.MovePoints($FF);
    Pos := Settings.FPath.MovePointsToPos(MovePoints);
    if Pos < Settings.FPath.Count - 1 then
    begin
      while (Pos <> Settings.FPath.Count - 1) and
        (CanMoveTo(Army, $FF, Settings.FPath[Pos].X,
          Settings.FPath[Pos].Y, Settings.FPath[Pos].L) <> $FF) do Inc(Pos);
      if Pos < Settings.FPath.Count - 1 then
      begin
        Move := TAIMoveExecuterMove.Create(nil);
        Move.AddUnits(Army, $FF);
        for I := Pos to Settings.FPath.Count - 1 do
          Move.FPath.Add(Settings.FPath[I]);
        Move.FMovePoints := MovePoints;
        Move.FMoves := ArmyHS.FArmy.Moves($FF);
        Move.FSourceX := ArmyHS.Xhx;
        Move.FSourceY := ArmyHS.Yhx;
        Move.FSourceL := ArmyHS.Lhx;
        Move.FDestinationX := X;
        Move.FDestinationY := Y;
        Move.FDestinationL := L;
        if Queue then
        begin
          Move.Owner := FExecuter.FMoves;
          Move.SetUnitStatus(esQueued);
        end;
      end;
    end;
  end;
  Army.Free;
  Settings.Release;
  Result := Move;
end;

function TTransportMEC.TransportDone: Boolean;
var
  Executer: TAIMoveExecuter;
  I: Integer;
  Done: Boolean;
begin
  Executer := FExecuter;
  I := Executer.FUnits.Count;
  Done := True;
  while (I <> 0) and Done do
  begin
    Dec(I);
    if not (Executer.FUnits.GetUnits(I).FTransportStatus in
      [mtsArriving, mtsGuarding, mtsDumping, mtsDumped, mtsDone]) then Done := False;
  end;
  Result := Done;
end;

procedure TTransportMEC.Done;
var I: Integer;
begin
  if not TransportDone then FExecuter.FStatus := mesOutOfMovePoints;
  for I := FExecuter.FUnits.Count - 1 downto 0 do
    if FExecuter.FUnits.GetUnits(I).FTransportStatus in [mtsGuarding, mtsDumped] then
      FExecuter.FUnits.GetUnits(I).Free;
  FState := -1;
end;

procedure TTransportMEC.DumpTransportUnits(Army: TAIMoveExecuterArmy);
var
  Transporting, Others: Byte;
  Settings: TMoveControlSettings;
  Selection: Byte;
  ArmyHS: TArmyHS;
  Fields: TList;
  I: Integer;
  Field: TAoWMapField;
  Found: Boolean;
begin
  Transporting := 0;
  Others := 0;
  for I := 0 to Army.Count - 1 do
    if Army.GetUnits(I).FUnit.GetTransporting then
      Transporting := Transporting or (1 shl I)
    else Others := Others or (1 shl I);
  if Transporting <> 0 then
  begin
    Settings := TMoveControlSettings.Create(nil);
    Army.RetrieveArmy(Transporting, ArmyHS, Selection);
    Settings.SetupArmy(ArmyHS, Selection);
    Settings.FMovePointsMax := ArmyHS.FArmy.Moves(Selection);
    Settings.FMode := Settings.FMode + [mmLogProcessedMapFields];
    AoWHSMap.FMoveControl.ProcessMove(Settings);
    Fields := Settings.FProcessedMapFields;
    Found := False;
    I := 0;
    Field := nil;
    while not Found and (I <> Fields.Count) do
    begin
      Field := Fields[I];
      if (Army.FLocation.X <> Field.Xhx) or (Army.FLocation.Y <> Field.Yhx) or
        (Army.FLocation.L <> Field.Lhx) then
        Found := CanMoveTo(Army, Transporting, Field.Xhx, Field.Yhx, Field.Lhx) = Transporting;
      if not Found then Inc(I);
    end;
    if Found then
    begin
      if CreateMove(Army, Transporting, Field.Xhx, Field.Yhx, Field.Lhx, [], nil) <> nil then
      begin
        FExecuter.ExecuteMoves;
        Army.SetStatus(Transporting, esDone);
        Army.SetTransportStatus(Transporting, mtsDumped);
      end
      else FExecuter.FStatus := mesOutOfMovePoints;
    end
    else Army.SetTransportStatus(Transporting, mtsGuarding);
    Settings.Release;
  end;
  if (Transporting = 0) and (Others <> 0) then
  begin
    Settings := TMoveControlSettings.Create(nil);
    Army.RetrieveArmy(Others, ArmyHS, Selection);
    Settings.SetupArmy(ArmyHS, Selection);
    Settings.FMovePointsMax := ArmyHS.FArmy.Moves(Selection);
    Settings.FMode := Settings.FMode + [mmLogProcessedMapFields];
    AoWHSMap.FMoveControl.ProcessMove(Settings);
    Field := nil;
    Fields := Settings.FProcessedMapFields;
    Found := False;
    I := 0;
    while not Found and (I <> Fields.Count) do
    begin
      Field := Fields[I];
      if (Army.FLocation.X <> Field.Xhx) or (Army.FLocation.Y <> Field.Yhx) or
        (Army.FLocation.L <> Field.Lhx) then
        Found := CanMoveTo(Army, Others, Field.Xhx, Field.Yhx, Field.Lhx) = Others;
      if not Found then Inc(I);
    end;
    if Found then
    begin
      if CreateMove(Army, Others, Field.Xhx, Field.Yhx, Field.Lhx, [], nil) <> nil then
      begin
        FExecuter.ExecuteMoves;
        Army.SetStatus(Others, esDone);
        Army.SetTransportStatus(Others, mtsDumped);
      end
      else FExecuter.FStatus := mesOutOfMovePoints;
    end
    else Army.SetTransportStatus(Others, mtsGuarding);
    Settings.Release;
  end;
end;

procedure TTransportMEC.UpdateTransportMeetingPoint;
var
  Armies: TAIMoveExecuterArmyList;
  I, J: Integer;
  Found: Boolean;
  Settings: TMoveControlSettings;
  Selection: Byte;
  ArmyHS: TArmyHS;
begin
  Found := False;
  if FExecuter.FMode * [memAdjacent, memAttack] <> [] then
  begin
    Armies := FExecuter.CreateArmies([esReady]);
    I := Armies.Count;
    while not Found and (I <> 0) do
    begin
      Dec(I);
      Found := Armies.GetArmies(I).FTransportStatus in [mtsBoarding, mtsTransporting];
      if Found then FMeetingPoint := Armies.GetArmies(I).FArrivalPoint;
    end;
    if not Found then I := Armies.Count;
    while not Found and (I <> 0) do
    begin
      Dec(I);
      Found := Armies.GetArmies(I).FTransportStatus in [mtsArriving, mtsDone];
      if Found then FMeetingPoint := Armies.GetArmies(I).FLocation;
    end;
    if Found then
    begin
      Settings := TMoveControlSettings.Create(nil);
      Armies.GetArmies(I).RetrieveArmy($FF, ArmyHS, Selection);
      Settings.SetupArmy(ArmyHS, Selection);
      Settings.SetSourcePos(FMeetingPoint.X, FMeetingPoint.Y, FMeetingPoint.L);
      Settings.SetDestinationPos(FExecuter.FDestination.X,
        FExecuter.FDestination.Y, FExecuter.FDestination.L);
      AoWHSMap.FMoveControl.ProcessMove(Settings);
      if Settings.FPath.Count > 4 then FMeetingPoint := Settings.FPath[Settings.FPath.Count - 2];
      for I := 0 to Armies.Count - 1 do
        if Armies.GetArmies(I).FTransportStatus in [mtsBoarding, mtsTransporting, mtsArriving, mtsDone] then
          for J := 0 to Armies.GetArmies(I).Count - 1 do
            Armies.GetArmies(I).GetUnits(J).FArrivalPoint := FMeetingPoint;
      Settings.Release;
    end;
    Armies.Free;
  end;
  if not Found then
  begin
    FMeetingPoint.X := -1;
    FMeetingPoint.Y := -1;
    FMeetingPoint.L := -1;
  end;
end;

procedure TTransportMEC.CalculateTransportPathCallBack(Sender: TObject);
var
  Armies: TAIMoveExecuterArmyList;
  Index, I: Integer;
  Army: TAIMoveExecuterArmy;
  Settings: TAIMoveControlSettings;
  UnitEntry: TAIMoveExecuterUnit;
begin
  Armies := FExecuter.CreateArmies([esReady]);
  Settings := FMoveControl.FSettings;
  Index := Armies.IndexOf(Settings.FArmyHS, Settings.FSelection);
  if Index = -1 then Army := nil else Army := Armies.GetArmies(Index);
  if (Army = nil) or (Settings.FMovePoints = -1) then
    FExecuter.FStatus := mesFailed
  else
    if Settings.FBoardingPoint.X = -1 then
      for I := 0 to Army.Count - 1 do Army.GetUnits(I).FTransportStatus := mtsArriving
    else
    begin
      Index := Settings.FTransportPath.IndexOfXYL(Settings.FBoardingPoint.X,
        Settings.FBoardingPoint.Y, Settings.FBoardingPoint.L);
      while (Index <> Settings.FTransportPath.Count - 1) and
        (CanMoveTo(Army, $FF, Settings.FTransportPath[Index].X,
          Settings.FTransportPath[Index].Y, Settings.FTransportPath[Index].L) <> $FF) do Inc(Index);
      Settings.FBoardingPoint := Settings.FTransportPath[Index];
      Index := Settings.FTransportPath.IndexOfXYL(Settings.FArrivalPoint.X,
        Settings.FArrivalPoint.Y, Settings.FArrivalPoint.L);
      while (Index <> 0) and
        (CanMoveTo(Army, $FF, Settings.FTransportPath[Index].X,
          Settings.FTransportPath[Index].Y, Settings.FTransportPath[Index].L) <> $FF) do Dec(Index);
      Settings.FArrivalPoint := Settings.FTransportPath[Index];
      for I := 0 to Army.Count - 1 do
      begin
        UnitEntry := Army.GetUnits(I);
        if Integer(Army.GetUnits(I).FLocation) = Integer(FExecuter.FTransporter.FLocation) then
          UnitEntry.FTransportStatus := mtsTransporting
        else UnitEntry.FTransportStatus := mtsBoarding;
        UnitEntry.FBoardingPoint := FMoveControl.FSettings.FBoardingPoint;
        UnitEntry.FBoardingPoint.Flag := 0;
        UnitEntry.FArrivalPoint := FMoveControl.FSettings.FArrivalPoint;
        UnitEntry.FArrivalPoint.Flag := 0;
        UnitEntry.FTransportSource := FMoveControl.FSettings.FTransportSource;
        UnitEntry.FTransportSource.Flag := 0;
        UnitEntry.FTransportDestination := FMoveControl.FSettings.FTransportDestination;
        UnitEntry.FTransportDestination.Flag := 0;
      end;
    end;
  Armies.Free;
end;

procedure TTransportMEC.CalculateMoves;
var
  Transporters: TAIMoveExecuterArmyList;
  Armies: TAIMoveExecuterArmyList;
  Settings: TAIMoveControlSettings;
  I, TimeLeft, Index: Integer;
  Selection: Byte;
  ArmyHS: TArmyHS;
  Army: TAIMoveExecuterArmy;
  Move: TAIMoveExecuterMove;
begin
  case FState of
    0:
      begin
        Armies := FExecuter.CreateArmies([esReady, esDone]);
        I := 0;
        TimeLeft := 5;
        while (I < Armies.Count) and (FMoveControl.FStatus <> amsProcessing) and
          (TimeLeft > 2) do
        begin
          if Armies.GetArmies(I).FTransportStatus = mtsIdle then
          begin
            Settings := TAIMoveControlSettings.Create(nil);
            Armies.GetArmies(I).RetrieveArmy($FF, ArmyHS, Selection);
            Settings.Setup(ArmyHS, Selection, FExecuter.FDestination.X,
              FExecuter.FDestination.Y, FExecuter.FDestination.L);
            Settings.FTransporter := FExecuter.FTransporter.FUnit;
            Settings.FOnDone := CalculateTransportPathCallBack;
            Settings.FMoveMode := [mmAI];
            FMoveControl.Reset;
            FMoveControl.CanMove(Settings);
            if FMoveControl.FStatus <> amsProcessing then
              TimeLeft := AoWHSMap.FAIExecuter.GetProcessTimeLeft;
            Settings.Release;
          end;
          Inc(I);
        end;
        Index := Armies.IndexOfTransportStatus(mtsIdle);
        if Index = -1 then
          if not TransportDone then
          begin
            Inc(FState);
            UpdateTransportMeetingPoint;
          end
          else Done;
        Armies.Free;
      end;
    1:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        Index := Armies.IndexOfTransportStatus(mtsArriving);
        if Index <> -1 then
        begin
          with Armies.GetArmies(Index).FArrivalPoint do
            Move := CreateMove(Armies.GetArmies(Index), $FF, X, Y, L, [], nil);
          Armies.GetArmies(Index).SetTransportStatus($FF, mtsDone);
          { The original executes queued moves only when creation returns nil. }
          if Move = nil then FExecuter.ExecuteMoves;
        end
        else Inc(FState);
        Armies.Free;
      end;
    2:
      begin
        Armies := FExecuter.CreateArmies([esReady, esDone]);
        Index := Armies.IndexOfTransportStatus(mtsBoarding);
        if (Index <> -1) and
          (Integer(Armies.GetArmies(Index).FTransportSource) =
            Integer(FExecuter.FTransporter.FLocation)) then
        begin
          I := 0;
          while (I < Armies.Count) and (FMoveControl.FStatus <> amsProcessing) do
          begin
            if Armies.GetArmies(I).FTransportStatus = mtsDumping then
              DumpTransportUnits(Armies.GetArmies(I));
            Inc(I);
          end;
          Index := Armies.IndexOfTransportStatus(mtsDumping);
          if Index = -1 then
            if not TransportDone then Inc(FState)
            else Done;
        end
        else Inc(FState);
        Armies.Free;
      end;
    3:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        Index := Armies.IndexOfTransportStatus(mtsTransporting);
        if (Index <> -1) and
          (Integer(Armies.GetArmies(Index).FTransportDestination) =
            Integer(Armies.GetArmies(Index).FLocation)) then
        begin
          Transporters := FExecuter.CreateArmies([esReady, esDone]);
          I := 0;
          while I <> Transporters.Count do
          begin
            if (Transporters.GetArmies(I).FTransportStatus = mtsDone) and
              (CanMoveTo(Armies.GetArmies(Index), $FF,
                Transporters.GetArmies(I).FLocation.X,
                Transporters.GetArmies(I).FLocation.Y,
                Transporters.GetArmies(I).FLocation.L) = $FF) then Break;
            Inc(I);
          end;
          if I <> Transporters.Count then
          begin
            with Transporters.GetArmies(I) do
              Move := CreateMove(Armies.GetArmies(Index), $FF,
                Transporters.GetArmies(I).FLocation.X,
                Transporters.GetArmies(I).FLocation.Y,
                Transporters.GetArmies(I).FLocation.L, [], nil);
          end
          else
          begin
            with Armies.GetArmies(Index).FArrivalPoint do
              Move := CreateMove(Armies.GetArmies(Index), $FF, X, Y, L, [], nil);
          end;
          if Move = nil then
          begin
            Armies.GetArmies(Index).SetStatus($FF, esDone);
            FExecuter.FTransporter.FStatus := esDone;
          end
          else
          begin
            Armies.GetArmies(Index).SetTransportStatus($FF, mtsDone);
            FExecuter.ExecuteMoves;
          end;
          Transporters.Free;
        end;
        Armies.Free;
        Inc(FState);
      end;
    4:
      begin
        if FExecuter.FTransporter.FStatus = esReady then
        begin
          Armies := FExecuter.CreateArmies([esReady, esDone]);
          Index := Armies.IndexOfTransportStatus(mtsTransporting);
          if Index <> -1 then
          begin
            with Armies.GetArmies(Index).FTransportDestination do
              Move := CreateTransporterMove(X, Y, L, True);
            if Move = nil then
            begin
              Armies.GetArmies(Index).SetStatus($FF, esDone);
              FExecuter.FTransporter.FStatus := esDone;
            end;
          end;
          Armies.Free;
        end;
        Inc(FState);
      end;
    5:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        I := 0;
        TimeLeft := 5;
        while (TimeLeft > 2) and (I <> Armies.Count) do
        begin
          if Armies.GetArmies(I).FTransportStatus = mtsBoarding then
          begin
            Army := Armies.GetArmies(I);
            if (Army.FBoardingPoint.X <> -1) and
              (Integer(Army.FLocation) <> Integer(Army.FBoardingPoint)) then
            begin
              Move := CreateMove(Armies.GetArmies(I), $FF, Army.FBoardingPoint.X,
                Army.FBoardingPoint.Y, Army.FBoardingPoint.L, [], nil);
              if Move = nil then Army.SetStatus($FF, esDone);
              TimeLeft := AoWHSMap.FAIExecuter.GetProcessTimeLeft;
            end;
          end;
          Inc(I);
        end;
        if I = Armies.Count then Inc(FState);
        Armies.Free;
      end;
    6:
      begin
        if FExecuter.FTransporter.FStatus = esReady then
        begin
          Armies := FExecuter.CreateArmies([esReady, esQueued, esDone]);
          Index := Armies.IndexOfTransportStatus(mtsBoarding);
          if Index <> -1 then
          begin
            with Armies.GetArmies(Index) do
              if Integer(FExecuter.FTransporter.FLocation) <> Integer(FTransportSource) then
              begin
                Move := CreateTransporterMove(FTransportSource.X,
                  FTransportSource.Y, FTransportSource.L, True);
                if Move = nil then FExecuter.FTransporter.FStatus := esDone;
              end;
          end;
          Armies.Free;
        end;
        Inc(FState);
      end;
    7:
      begin
        if FExecuter.FTransporter.FStatus = esReady then
        begin
          Armies := FExecuter.CreateArmies([esReady, esQueued, esDone]);
          Index := Armies.IndexOfTransportStatus(mtsBoarding);
          if Index <> -1 then
          begin
            Army := Armies.GetArmies(Index);
            if Army.WaitingForTransport and
              (Integer(FExecuter.FTransporter.FLocation) = Integer(Army.FTransportSource)) then
            begin
              Selection := CanMoveTo(Armies.GetArmies(Index), $FF,
                Army.FTransportSource.X, Army.FTransportSource.Y, Army.FTransportSource.L);
              if Selection <> 0 then
              begin
                Move := CreateMove(Armies.GetArmies(Index), Selection,
                  Army.FTransportSource.X, Army.FTransportSource.Y,
                  Army.FTransportSource.L, [], nil);
                if Move = nil then FExecuter.FTransporter.FStatus := esDone
                else Armies.GetArmies(Index).SetTransportStatus(Selection, mtsTransporting);
              end
              else FExecuter.FTransporter.FStatus := esDone;
            end;
          end;
          Armies.Free;
        end;
        Inc(FState);
      end;
    8:
      if FExecuter.FMoves.Count = 0 then Done
      else
      begin
        FState := 1;
        FExecuter.ExecuteMoves;
      end;
  end;
end;

constructor TAIMoveExecuter.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnits := TAIMoveExecuterUnitList.Create(nil);
  FMoves := TAIMoveExecuterMoveQueue.Create(nil);
  FControlQueue := TIntegerList.Create;
  Clear;
end;

destructor TAIMoveExecuter.Destroy;
begin
  Clear;
  FUnits.Free;
  FUnits := nil;
  FMoves.Free;
  FMoves := nil;
  FControlQueue.Free;
  FControlQueue := nil;
  inherited Destroy;
end;

procedure TAIMoveExecuter.ActivateMEC(ControlClass: TAIMoveExecuterControlClass);
begin
  DeactivateMEC;
  if ControlClass <> nil then
  begin
    FControl := ControlClass.Create(nil);
    FControl.Activate(Self);
  end;
end;

procedure TAIMoveExecuter.DeactivateMEC;
begin
  if FControl <> nil then
  begin
    FControl.Deactivate;
    FControl.Destroy;
    FControl := nil;
  end;
end;

procedure TAIMoveExecuter.Clear;
begin
  inherited Clear;
  DeactivateMEC;
  if FMoves.Count <> 0 then FMoves.Clear;
  if FTransporter <> nil then
  begin
    FTransporter.Free;
    FTransporter := nil;
  end;
  FUnits.Clear;
  FMode := [memAdjacent, memSimultaneous];
end;

function TAIMoveExecuter.AddUnit(AUnit: TAbstractUnit): TAIMoveExecuterUnit;
var
  Location: TXYL;
  UnitEntry: TAIMoveExecuterUnit;
begin
  if FPlayer = -1 then FPlayer := AUnit.FPlayer
  else if FPlayer <> AUnit.FPlayer then raise Exception.Create('Player mismatch!');
  if FUnits.IndexOfUnitID(AUnit.FUnitID) <> -1 then
    raise Exception.Create('Unit already exists! (TAIMoveExecuter)');
  AUnit.GetLocation(Location.X, Location.Y, Location.L);
  UnitEntry := TAIMoveExecuterUnit.Create(nil);
  UnitEntry.Initialize(AUnit, Location.X, Location.Y, Location.L);
  UnitEntry.Owner := FUnits;
  Result := UnitEntry;
end;

procedure TAIMoveExecuter.AddUnits(Units: TUnitList);
var I: Integer;
begin
  for I := Units.Count - 1 downto 0 do AddUnit(Units.GetUnit(I));
end;

procedure TAIMoveExecuter.AddArmy(Army: TArmyHS; Selection: Byte);
var I: Integer;
begin
  for I := 0 to Army.FArmy.Count - 1 do
  begin
    if Selection and 1 <> 0 then AddUnit(Army.FArmy.GetUnit(I));
    Selection := Selection shr 1;
  end;
end;

procedure TAIMoveExecuter.AddTransporter(AUnit: TAbstractUnit);
var
  Location: TXYL;
  Index: Integer;
begin
  if FTransporter <> nil then
    raise Exception.Create('Transporter already exists! (TAIMoveExecuter)');
  Index := FUnits.IndexOfUnitID(AUnit.FUnitID);
  if Index <> -1 then FUnits.GetUnits(Index).Free;
  AUnit.GetLocation(Location.X, Location.Y, Location.L);
  FTransporter := TAIMoveExecuterUnit.Create(nil);
  FTransporter.Initialize(AUnit, Location.X, Location.Y, Location.L);
end;

procedure TAIMoveExecuter.InvalidateMove;
begin
  FStatus := mesInvalidated;
  UpdateMoveResult;
  if Assigned(FOnDone) then FOnDone;
end;

procedure TAIMoveExecuter.Reset;
begin
  Clear;
  FStatus := mesIdle;
  FState := 0;
  FOnDone := nil;
  FControlQueue.Clear;
  FPlayer := -1;
  FMovePointsMax := 200;
end;

function TAIMoveExecuter.Validate: Boolean;
var
  Valid: Boolean;
  I: Integer;
begin
  Valid := True;
  if FTransporter <> nil then Valid := Valid and FTransporter.Validate;
  for I := FUnits.Count - 1 downto 0 do Valid := Valid and FUnits.GetUnits(I).Validate;
  Result := Valid;
end;

function TAIMoveExecuter.CreateArmies(Status: TAIMoveExecuterUnitStatusSet): TAIMoveExecuterArmyList;
var
  Used: TIntegerList;
  Armies: TAIMoveExecuterArmyList;
  I, J: Integer;
  UnitEntry: TAIMoveExecuterUnit;
  Army: TAIMoveExecuterArmy;
begin
  Used := TIntegerList.Create;
  Armies := TAIMoveExecuterArmyList.Create(nil);
  for I := 0 to FUnits.Count - 1 do
    if Used.IndexOf(I) = -1 then
    begin
      UnitEntry := FUnits.GetUnits(I);
      if UnitEntry.FStatus in Status then
      begin
        Used.Add(I);
        Army := TAIMoveExecuterArmy.Create(nil);
        Army.Setup(UnitEntry);
        for J := 0 to FUnits.Count - 1 do
          if Used.IndexOf(J) = -1 then
          begin
            UnitEntry := FUnits.GetUnits(J);
            if (UnitEntry.FStatus in Status) and Army.CanAdd(UnitEntry) then
            begin
              Army.AddChild(UnitEntry);
              Used.Add(J);
            end;
          end;
        Army.Owner := Armies;
      end;
    end;
  Used.Free;
  Result := Armies;
end;

procedure TAIMoveExecuter.FinishMoves;
begin
  FStatus := mesDone;
end;

procedure TAIMoveExecuter.ExecuteMoves;
begin
  if FMoves.Count <> 0 then FState := 1;
end;

procedure TAIMoveExecuter.UnitsMoveDone;
var I: Integer;
begin
  for I := FUnits.Count - 1 downto 0 do
    if FUnits.GetUnits(I).FStatus <> esLost then
      FUnits.GetUnits(I).FUnit.FUnitStatus :=
        FUnits.GetUnits(I).FUnit.FUnitStatus + [usMoveDone];
end;

function TAIMoveExecuter.GetTransporting: Boolean;
var
  Transporting: Boolean;
  I: Integer;
begin
  Transporting := False;
  I := FUnits.Count;
  while not Transporting and (I <> 0) do
  begin
    Dec(I);
    Transporting := FUnits.GetUnits(I).FTransportStatus in [mtsBoarding, mtsTransporting];
  end;
  Result := Transporting;
end;

procedure TAIMoveExecuter.UpdateMoveResult;
var I: Integer;
begin
  if FStatus = mesDone then
  begin
    I := 0;
    while (I <> FUnits.Count) and
      ((Integer(FUnits.GetUnits(I).FLocation) = Integer(FDestination)) or
        (FUnits.GetUnits(I).FMoveResult = 2)) do Inc(I);
    if I <> FUnits.Count then FStatus := mesOutOfMovePoints;
  end;
end;

procedure TAIMoveExecuter.ProcessExecuteMoves;
var
  I: Integer;
  MultiMove: TMultiMoveTE;
  Selection: Byte;
  Army: TArmyHS;
  Move: TArmyDefaultMoveTE;
begin
  if FMoves.Count <> 0 then
  begin
    if (FMoves.Count > 1) and (memSimultaneous in FMode) then
    begin
      MultiMove := TMultiMoveTE.Create(nil);
      MultiMove.FMoveMode := 0;
      for I := FMoves.Count - 1 downto 0 do
        if FMoves.GetMoves(I).RetrieveArmy(Army, Selection) then
        begin
          Move := TArmyDefaultMoveTE.Create(nil);
          if not Move.Setup(Army, Selection, FMoves.GetMoves(I).FPath, []) then
            raise Exception.Create('FAILURE: TAIMoveExecuter.ExecuteMoves');
          FMoves.GetMoves(I).SetUnitStatus(esMoving);
          MultiMove.FEvents.Add(Move);
          Move.Release;
        end;
      AoWHSMap.FTokenManager.GetTokenControl(FPlayer).AddEvent(MultiMove);
      MultiMove.Release;
      FMoves.Clear;
    end
    else
    begin
      if FMoves.GetMoves(0).RetrieveArmy(Army, Selection) then
        if not MoveArmy(Army, Selection, FMoves.GetMoves(0).FPath) then
        begin
          FMoves.GetMoves(0).SetUnitStatus(esFailed);
          FStatus := mesFailed;
        end
        else FMoves.GetMoves(0).SetUnitStatus(esMoving);
      FMoves.GetMoves(0).Destroy;
    end;
  end
  else FState := 0;
end;

procedure TAIMoveExecuter.ProcessMECS;
var TimeLeft: Integer;
begin
  TimeLeft := 5;
  while (TimeLeft > 0) and ((FControl <> nil) or (FControlQueue.Count <> 0)) and
    (FStatus = mesBusy) and (FState = 0) do
  begin
    if FControl <> nil then
    begin
      if not FControl.Process then DeactivateMEC;
      TimeLeft := AoWHSMap.FAIExecuter.GetProcessTimeLeft;
    end;
    if (FControl = nil) and (FControlQueue.Count <> 0) and (FStatus = mesBusy) then
    begin
      case FControlQueue[FControlQueue.Count - 1] of
        0: ActivateMEC(TDefaultMEC);
        1: ActivateMEC(TTransportMEC);
        2: ActivateMEC(TAdjacentMEC);
      end;
      FControlQueue.Delete(FControlQueue.Count - 1);
    end;
  end;
  if (FControl = nil) and (FStatus = mesBusy) and (FState = 0) then FStatus := mesDone;
end;

function TAIMoveExecuter.Process: Boolean;
var Busy: Boolean;
begin
  if Validate then
  try
    if FStatus = mesBusy then
    begin
      Inc(FProcessCycles);
      if FState = 1 then ProcessExecuteMoves;
      if FState = 0 then ProcessMECS;
    end;
  except
    FStatus := mesInvalidated;
  end
  else FStatus := mesInvalidated;
  Busy := FStatus = mesBusy;
  if not Busy then
  begin
    UpdateMoveResult;
    try
      if Assigned(FOnDone) then FOnDone;
    except
      ShowMessage('MoveExecute.OnDone failed');
    end;
  end;
  Result := Busy;
end;

procedure TAIMoveExecuter.SetupTransporter;
var
  Capacity, I: Integer;
  Army: TArmyHS;
  AUnit: TAbstractUnit;
  UnitEntry: TAIMoveExecuterUnit;
begin
  FControlQueue.Add(1);
  Capacity := FTransporter.FUnit.GetTransportCapacity;
  if Capacity > 4 then Capacity := Capacity - 4 else Capacity := 1;
  with FTransporter do
    Army := TAoWMapField(AoWHSMap.MapContainer.GetField(FLocation.X, FLocation.Y, FLocation.L)).GetArmyHS;
  I := 0;
  while (Capacity > 0) and (I <> Army.FArmy.Count) do
  begin
    AUnit := Army.FArmy.GetUnit(I);
    if AUnit <> FTransporter.FUnit then
      if (FUnits.IndexOfUnitID(AUnit.FUnitID) = -1) and not AUnit.GetTransporting then
      begin
        UnitEntry := AddUnit(AUnit);
        UnitEntry.FTransportStatus := mtsGuarding;
        Dec(Capacity);
      end;
    Inc(I);
  end;
  I := 0;
  while I <> Army.FArmy.Count do
  begin
    AUnit := Army.FArmy.GetUnit(I);
    if AUnit <> FTransporter.FUnit then
      if FUnits.IndexOfUnitID(AUnit.FUnitID) = -1 then
      begin
        UnitEntry := AddUnit(AUnit);
        if Capacity > 0 then
        begin
          UnitEntry.FTransportStatus := mtsGuarding;
          Dec(Capacity);
        end
        else UnitEntry.FTransportStatus := mtsDumping;
        { The original revisits the index after adding a unit to the executer. }
        Dec(I);
      end;
    Inc(I);
  end;
  FTransporter.FStatus := esReady;
end;

function TAIMoveExecuter.ExecuteMove(X, Y, L: Shortint): Boolean;
var
  Armies: TAIMoveExecuterArmyList;
  I: Integer;
  Started: Boolean;
begin
  if FStatus <> mesBusy then
  begin
    FState := 0;
    FProcessCycles := 0;
    FDestination.X := X;
    FDestination.Y := Y;
    FDestination.L := L;
    Armies := CreateArmies([esIdle]);
    for I := 0 to Armies.Count - 1 do Armies.GetArmies(I).SetStatus($FF, esReady);
    if Armies.Count <> 0 then
    begin
      if (Armies.Count <> 1) or (Integer(Armies.GetArmies(0).FLocation) <> Integer(FDestination)) then
      begin
        FStatus := mesBusy;
        if (memAdjacent in FMode) and (Armies.Count >= 2) then FControlQueue.Add(2)
        else FControlQueue.Add(0);
        if FTransporter <> nil then SetupTransporter;
        Process;
      end
      else
      begin
        FStatus := mesDone;
        Process;
      end;
      Started := True;
    end
    else
    begin
      FStatus := mesFailed;
      Started := False;
    end;
    Armies.Free;
    Result := Started;
  end
  else Result := False;
end;

constructor TAIMoveTargetSelector.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSettings := TMoveControlSettings.Create(nil);
  FTargets := TMoveTargetList.Create(nil);
  FBufferedTargets := TMoveTargetList.Create(nil);
  FUnits := TUnitUserList.Create(nil);
end;

destructor TAIMoveTargetSelector.Destroy;
begin
  FSettings.Release;
  FTargets.Free;
  FBufferedTargets.Free;
  FUnits.Free;
  inherited Destroy;
end;

procedure TAIMoveTargetSelector.SetTransporter(Transporter: TAbstractUnit);
begin
  if Transporter <> FTransporter then
  begin
    if FTransporter <> nil then FTransporter.Release;
    FTransporter := Transporter;
    if FTransporter <> nil then FTransporter.AddRef;
  end;
end;

procedure TAIMoveTargetSelector.Reset;
begin
  FState := 0;
  FStatus := atsIdle;
  FOnTargetFound := nil;
  FProcessCycles := 0;
  FillChar(FMovePointTable, SizeOf(FMovePointTable), -1);
  FillChar(FTargetInfo, SizeOf(FTargetInfo), 0);
  FTargetInfo.Player := -1;
  FMovePointsMax := 250;
  FMovePointsMin := 100;
  SetTransporter(nil);
  FSourceLocation.XYL := $FFFFFF;
  FTargets.Clear;
  FMode := [];
  FUnits.Clear;
end;

function TAIMoveTargetSelector.SetupArmy(Army: TArmyHS; Selection: Byte): Boolean;
begin
  Reset;
  FSourceLocation.XYL := Army.GetXYL;
  FUnits.AddUnitsEx(Army.FArmy, Selection);
  FTargetInfo.Player := Army.FArmy.FPlayer;
  if FTargetInfo.Player = 0 then FTargetInfo.IndependentRelation := Army.FArmy.FIndependentRelation;
  Army.FArmy.CreateMovePointTable(Selection, FMovePointTable);
  Result := True;
end;

procedure TAIMoveTargetSelector.SetupTransport(Transporter: TAbstractUnit; ResetSettings: Boolean);
begin
  if ResetSettings then Reset;
  SetTransporter(Transporter);
  FMovePointsMax := 0;
end;

procedure TAIMoveTargetSelector.Done;
begin
  FState := -1;
  FStatus := atsDone;
end;

procedure TAIMoveTargetSelector.TriggerTargetFound(Target: TMoveTarget);
var SearchDone: Boolean;
begin
  if Assigned(FOnTargetFound) then
  begin
    SearchDone := False;
    FOnTargetFound(Target, SearchDone);
    if SearchDone then Done;
  end;
end;

function TAIMoveTargetSelector.ProcessBufferedTargets: Boolean;
begin
  if FBufferedTargets.Count <> 0 then
  begin
    TriggerTargetFound(FBufferedTargets.GetTarget(0));
    FTargets.AddChild(FBufferedTargets.GetTarget(0));
    FBufferedTargets.RemoveChild(FBufferedTargets.GetTarget(0));
  end;
  Result := (FBufferedTargets.Count <> 0) and (FState <> -1);
end;

function TAIMoveTargetSelector.ProcessBufferedTransportTargets: Boolean;
var
  Location: TXYL;
  Gaps: TIntegerList;
  Target: TMoveTarget;
  Valid: Boolean;
  I: Integer;
begin
  if FBufferedTargets.Count <> 0 then
  begin
    Gaps := TIntegerList.Create;
    Target := FBufferedTargets.GetTarget(0);
    FTransporter.GetLocation(Location.X, Location.Y, Location.L);
    if ListMovementGaps(AoWHSMap, Target.FMovepath, FMovePointTable, Gaps, nil) <> 0 then
    begin
      FSettings.Reset;
      with FSettings do
      begin
        FPlayer := FTargetInfo.Player;
        FMode := FMode + [mmLogProcessedMapFields, mmAI];
        SetSourcePos(Location.X, Location.Y, Location.L);
      end;
      FSettings.FMovePointsMax := FMovePointsMax;
      FSettings.FMovePointTable := FTransportMovePointTable;
      I := Gaps.Count;
      Valid := True;
      while (I <> 0) and Valid do
      begin
        Dec(I);
        FSettings.ResetState;
        FSettings.SetDestinationPos(Target.FMovepath[Gaps[I]].X,
          Target.FMovepath[Gaps[I]].Y, Target.FMovepath[Gaps[I]].L);
        Valid := AoWHSMap.FMoveControl.CanMove(FSettings, [mmFast]) <> -1;
      end;
    end
    else Valid := True;
    if Valid then
    begin
      TriggerTargetFound(Target);
      FTargets.AddChild(Target);
    end;
    FBufferedTargets.RemoveChild(Target);
    Gaps.Free;
  end;
  Result := (FBufferedTargets.Count <> 0) and (FState <> -1);
end;

function TAIMoveTargetSelector.ProcessStates: Boolean;
var
  Yield, Processing, Found: Boolean;
  I, Terrain, Overlay: Integer;
  Settings: TMoveControlSettings;
  Field: TAoWMapField;
  Target: TMoveTarget;
  Data: TAITargetData;
begin
  Yield := False;
  case FState of
    0:
      begin
        if FMovePointsMax <> 0 then
        begin
          FBufferedTargets.Clear;
          FSettings.Reset;
          with FSettings do
          begin
            FPlayer := FTargetInfo.Player;
            FMode := FMode + [mmLogProcessedMapFields, mmAI];
            SetSourcePos(FSourceLocation.X, FSourceLocation.Y, FSourceLocation.L);
          end;
          FSettings.FMovePointsMax := FMovePointsMax;
          FSettings.FMovePointTable := FMovePointTable;
          FSettings.FUnits.AddUnits(FUnits);
          FState := 1;
        end
        else FState := 10;
        Yield := False;
      end;
    1:
      begin
        AoWHSMap.FMoveControl.Activate(FSettings);
        Processing := True;
        while (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) and Processing do
          Processing := AoWHSMap.FMoveControl.Process;
        Yield := Processing;
        AoWHSMap.FMoveControl.Deactivate;
        if FSettings.FStatus <> mcssProcessing then FState := 2;
      end;
    2:
      begin
        Settings := FSettings;
        Found := False;
        I := Settings.FProcessedMapFields.Count;
        while (I > 0) and not Found do
        begin
          Dec(I);
          Field := Settings.FProcessedMapFields[I];
          if Field.FFieldFlags and $08000000 <> 0 then
            if (FTargets.IndexOfXYL(Field.GetXYL) = -1) and
              Field.GetAITarget(FControl, FTargetInfo, Data) then
            begin
              Target := TMoveTarget.Create(nil);
              Target.FLocation.XYL := Field.GetXYL;
              Target.FMovePoints := Settings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx);
              Target.FTransporterID := -1;
              Target.FData := Data;
              if tsmCreateMovepaths in FMode then
              begin
                Target.FMovepath := TMovepath.Create;
                AoWHSMap.FMoveControl.Activate(FSettings);
                AoWHSMap.FMoveControl.CalculatePathEx(Target.FMovepath,
                  Field.Xhx, Field.Yhx, Field.Lhx);
                if Target.FMovepath.Count <> 0 then FBufferedTargets.AddChild(Target);
                AoWHSMap.FMoveControl.Deactivate;
              end
              else FBufferedTargets.AddChild(Target);
              Target.Release;
              Found := True;
            end;
          Settings.FProcessedMapFields.Delete(I);
        end;
        if FSettings.FProcessedMapFields.Count = 0 then
        begin
          FBufferedTargets.SortOnMovePoints;
          FState := 3;
        end;
        Yield := False;
      end;
    3:
      begin
        if not ProcessBufferedTargets and (FState = 3) then FState := 10;
        Yield := False;
      end;
    10:
      begin
        if (FMovePointsMin > 0) and (FTransporter <> nil) then
        begin
          FBufferedTargets.Clear;
          FSettings.Reset;
          with FSettings do
          begin
            FPlayer := FTargetInfo.Player;
            FMode := FMode + [mmLogProcessedMapFields, mmAI, mmAvoidArmies];
            SetSourcePos(FSourceLocation.X, FSourceLocation.Y, FSourceLocation.L);
          end;
          FSettings.FMovePointsMax := FMovePointsMin;
          FSettings.FMovePointTable := FMovePointTable;
          FSettings.FUnits.AddUnits(FUnits);
          FTransporter.CreateMovePointTable(FTransportMovePointTable);
          for Terrain := 0 to 15 do
            for Overlay := -1 to 11 do
              if (FSettings.FMovePointTable[Terrain, Overlay] = -1) and
                (FTransportMovePointTable[Terrain, Overlay] <> -1) then
                FSettings.FMovePointTable[Terrain, Overlay] := 8;
          FState := 11;
        end
        else Done;
        Yield := False;
      end;
    11:
      begin
        AoWHSMap.FMoveControl.Activate(FSettings);
        while AoWHSMap.FMoveControl.Process and
          (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) do;
        AoWHSMap.FMoveControl.Deactivate;
        if FSettings.FStatus <> mcssProcessing then FState := 12;
      end;
    12:
      begin
        Settings := FSettings;
        Found := False;
        I := Settings.FProcessedMapFields.Count;
        while (I > 0) and not Found do
        begin
          Dec(I);
          Field := Settings.FProcessedMapFields[I];
          if Field.FFieldFlags and $08000000 <> 0 then
            if (FTargets.IndexOfXYL(Field.GetXYL) = -1) and
              Field.GetAITarget(FControl, FTargetInfo, Data) and
              (FMovePointTable[Field.TerrainType, Field.OverlayType] >= 0) then
            begin
              Target := TMoveTarget.Create(nil);
              Target.FLocation.XYL := Field.GetXYL;
              Target.FMovePoints := Settings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx);
              Target.FTransporterID := FTransporter.FUnitID;
              Target.FData := Data;
              Target.FMovepath := TMovepath.Create;
              AoWHSMap.FMoveControl.Activate(FSettings);
              AoWHSMap.FMoveControl.CalculatePathEx(Target.FMovepath,
                Field.Xhx, Field.Yhx, Field.Lhx);
              AoWHSMap.FMoveControl.Deactivate;
              FBufferedTargets.AddChild(Target);
              Target.Release;
              Found := True;
            end;
          Settings.FProcessedMapFields.Delete(I);
        end;
        if FSettings.FProcessedMapFields.Count = 0 then
        begin
          FBufferedTargets.SortOnMovePoints;
          FState := 13;
        end;
        Yield := False;
      end;
    13:
      if not ProcessBufferedTransportTargets and (FState = 13) then Done;
  end;
  Result := Yield;
end;

function TAIMoveTargetSelector.Process: Boolean;
var Yield: Boolean;
begin
  try
    Yield := False;
    while not Yield and (FState <> -1) and (AoWHSMap.FAIExecuter.GetProcessTimeLeft > 0) do
      Yield := ProcessStates;
  except
    FState := -1;
  end;
  Result := FState <> -1;
end;

function TAIMoveTargetSelector.Search(Control: TAIGroupControl): Boolean;
begin
  if (FTargetInfo.Player <> -1) and Assigned(FOnTargetFound) and
    (FSourceLocation.XYL <> $FFFFFF) and ((FMovePointsMax > 0) or
      ((FMovePointsMin > 0) and (FTransporter <> nil))) then
  begin
    if FMovePointsMax > 0 then FState := 0 else FState := 10;
    FProcessCycles := 0;
    FControl := Control;
    FStatus := atsSearching;
    Result := True;
  end
  else Result := False;
end;

constructor TFastCombatCommand.Create(AbilityID: Integer);
begin
  FAbilityID := AbilityID;
end;

function TFastCombatCommand.GetName: string;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(FAbilityID).GetName(nil);
  if FTarget <> nil then Result := Result + ' on ' + FTarget.IDStr;
end;

constructor TFastCombatCommandList.Create(Source: TCombatObject; Combat: TFastCombat; Side: TCombatSide);
begin
  inherited Create;
  FCommands := TList.Create;
  FSource := Source;
  FCombat := Combat;
  FSourceSide := Side;
  if FSourceSide.FSideIndex = 0 then FTargetSide := FCombat.FSides[csDefender]
  else FTargetSide := FCombat.FSides[csAttacker];
end;

destructor TFastCombatCommandList.Destroy;
begin
  Clear;
  FCommands.Free;
  inherited Destroy;
end;

procedure TFastCombatCommandList.Clear;
var I: Integer;
begin
  for I := FCommands.Count - 1 downto 0 do
    TObject(FCommands.List^[I]).Free;
  FCommands.Clear;
end;

function TFastCombatCommandList.GetCommands(Index: Integer): TFastCombatCommand;
begin
  Result := FCommands.List^[Index];
end;

function TFastCombatCommandList.GetCount: Integer;
begin
  Result := FCommands.Count;
end;

procedure TFastCombatCommandList.Add(A1: TFastCombatCommand);
begin
  FCommands.Add(A1);
end;

procedure TFastCombatCommandList.Delete(Index: Integer);
begin
  TObject(FCommands.List^[Index]).Free;
  FCommands.Delete(Index);
end;

function CompareFastCombatCommands(Item1, Item2: Pointer): Integer;
begin
  Result := TFastCombatCommand(Item2).FExpectedDV - TFastCombatCommand(Item1).FExpectedDV;
end;

procedure TFastCombatCommandList.Sort;
begin
  FCommands.Sort(CompareFastCombatCommands);
end;

constructor TFastCombatUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
end;

class function TFastCombatUnit.ClassID: Integer;
begin
  Result := $202CF;
end;

procedure TFastCombatUnit.KillUnit;
var AUnit: TAbstractUnit;
begin
  AUnit := FUnit;
  if (AUnit is THero) and (cExecuting in FCombat.FStatus) then
    with FCombat.FCombatData do THero(AUnit).DropItemsOnMap(AoWHSMap, FX, FY, FL);
  inherited KillUnit;
end;

procedure TFastCombatUnit.SetUnit(AUnit: TAbstractUnit);
begin
  inherited SetUnit(AUnit);
end;

procedure TFastCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FState, SizeOf(FState), $28);
end;

function TFastCombatUnit.CanCastWallSiegeSpell: Boolean;
begin
  Result := FUnit.GetAbilityEnabled($34) and
    TSpellCastingAbility(AoWHSSet.FAbilityControl.GetAbility($34)).CanCastBreachWallSpell(FUnit);
end;

procedure TFastCombatUnit.UpdateWallSiegeObjectRegistration;
var Registered: Boolean;
begin
  Registered := (csActivated in FStatus) and (GetSide = csAttacker) and
    not (csDestroyed in FStatus) and
    ((FWallCombatFeatures * [wcWallBreaching, wcWallPassing] <> []) or CanCastWallSiegeSpell);
  if Registered then
  begin
    if not (fsWallSiegeObjectRegistered in FState) then
    begin
      Inc(TFastCombat(FCombat).FWallSiegeObjectCount);
      FState := FState + [fsWallSiegeObjectRegistered];
    end;
  end
  else if fsWallSiegeObjectRegistered in FState then
  begin
    Dec(TFastCombat(FCombat).FWallSiegeObjectCount);
    FState := FState - [fsWallSiegeObjectRegistered];
  end;
end;

procedure TFastCombatUnit.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin
  if fsOutsideWall in FState then AoWHSSet.FCombatImages[$15].Show(X + 10, Y, Surface);
  inherited Show(Frame, Direction, X, Y, Surface);
end;

function TFastCombatUnit.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin
  if (Direction <> 6) and (fsOutsideWall in FState) then
    AoWHSSet.FCombatImages[$15].Show(X + 10, Y, Surface);
  Result := inherited ShowAttackAnimation(Frame, Direction, X, Y, Surface);
end;

function TFastCombatUnit.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin
  if fsOutsideWall in FState then AoWHSSet.FCombatImages[$15].Show(X + 10, Y, Surface);
  { The original uses the attack animation for this hit-animation override. }
  Result := inherited ShowAttackAnimation(Frame, Direction, X, Y, Surface);
end;

procedure TFastCombatUnit.SetCombatPlayer(Player: Byte);
begin
  inherited SetCombatPlayer(Player);
  UpdateWallSiegeObjectRegistration;
end;

function TFastCombatUnit.fcRoundDistance: Integer;
begin
  Result := FRoundDistance;
  if fsVulnerable in FState then Dec(Result);
end;

procedure TFastCombatUnit.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
var
  AUnit: TAbstractUnit;
  Abilities: TAbilityTypeList;
  Values: TAbilityDamageValues;
  I, Value: Integer;
  Ability: TAbility;
begin
  if not (csDestroyed in FStatus) then
  begin
    AUnit := FUnit;
    CV := 0;
    DV := 0;
    Abilities := AoWHSSet.FAbilityControl.FAbilitiesByType[atCombat];
    for I := Abilities.Count - 1 downto 0 do
    begin
      Ability := Abilities.GetAbility(I);
      if AUnit.GetAbilityEnabled(Ability.FAbilityID) then
      begin
        Ability.fcGetDamageValueEx(Self, Target, wsNone, Values);
        if Values.SourceDamage > 0 then
        begin
          Value := (Values.SourceDamage * Values.SourceDamage) div
            (Values.TargetDamage + Values.SourceDamage);
          if Value <= 0 then Value := 1;
          if Value > CV then CV := Value;
          if Values.SourceDamage > DV then DV := Values.SourceDamage;
        end;
      end;
    end;
    if AUnit.GetAbilityEnabled($34) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility($34);
      Ability.tcGetDamageValueEx(Self, Target, Values);
      if Values.SourceDamage > 0 then
      begin
        Value := (Values.SourceDamage * Values.SourceDamage) div
          (Values.TargetDamage + Values.SourceDamage);
        if Value <= 0 then Value := 1;
        if Value > CV then CV := Value;
        if Values.SourceDamage > DV then DV := Values.SourceDamage;
      end;
    end;
  end
  else
  begin
    CV := 0;
    DV := 0;
  end;
end;

function TFastCombatUnit.GetTargetWallCV(Target: TCombatObject): Integer;
var
  AUnit: TAbstractUnit;
  Best: Integer;
  Wall: TWallSituation;
  Abilities: TAbilityTypeList;
  I, Value: Integer;
  Ability: TAbility;
  Values: TAbilityDamageValues;
begin
  AUnit := FUnit;
  Best := 0;
  if FCombat.FCombatData.FPlayers.GetPlayers(FCombatPlayer).FSideIndex = 1 then
    Wall := wsSource else Wall := wsTarget;
  Abilities := AoWHSSet.FAbilityControl.FAbilitiesByType[atCombat];
  for I := Abilities.Count - 1 downto 0 do
  begin
    Ability := Abilities.GetAbility(I);
    if AUnit.GetAbilityEnabled(Ability.FAbilityID) then
    begin
      Ability.fcGetDamageValueEx(Self, Target, Wall, Values);
      if Values.SourceDamage > 0 then
      begin
        Value := (Values.SourceDamage * Values.SourceDamage) div
          (Values.TargetDamage + Values.SourceDamage);
        if Value <= 0 then Value := 1;
        if Value > Best then Best := Value;
      end;
    end;
  end;
  Result := Best;
end;

function TFastCombatUnit.GetTargetPriority: Integer;
var
  I, CV: Integer;
  Target: TCombatObject;
  Count: Integer;
begin
  if FTargetPriorityInvalid then
  try
    if (FCombat.FCombatData.FWallType = 0) or FCombat.FCombatData.FWallBreached then
    begin
      FTargetPriority := 0;
      Count := 0;
      for I := FTargetedBy.Count - 1 downto 0 do
        if FTargetedBy.List^[I].B = 0 then Inc(Count);
      for I := FTargets.Count - 1 downto 0 do
      begin
        CV := FTargets.List^[I].B;
        if CV <> 0 then
        begin
          Target := TCombatObject(FTargets.List^[I].A);
          CV := Round((CV * CV) / Target.FIncomingCombatValue);
          Inc(FTargetPriority, CV);
        end;
      end;
      FTargetPriority := (Count + 2) * FTargetPriority;
      I := FTargetedBy.Count;
      { The original stores normalized priority in the target-strength field. }
      if I <> 0 then FTargetStrength := FTargetPriority div I else FTargetStrength := 0;
    end
    else
    begin
      FTargetPriority := 0;
      Count := 0;
      for I := FTargetedBy.Count - 1 downto 0 do
        if FTargetedBy.List^[I].C = 0 then Inc(Count);
      for I := FTargets.Count - 1 downto 0 do
      begin
        CV := FTargets.List^[I].C;
        if CV <> 0 then
        begin
          Target := TCombatObject(FTargets.List^[I].A);
          CV := Round((CV * CV) / Target.FIncomingCombatValue);
          Inc(FTargetPriority, CV);
        end;
      end;
      FTargetPriority := (Count + 2) * FTargetPriority;
      I := FTargetedBy.Count;
      if I <> 0 then FTargetStrength := FTargetPriority div I else FTargetStrength := 0;
    end;
    FTargetPriorityInvalid := False;
    Inc(FTargetPriority, CommandingTargetPriority * 2);
  except
  end;
  Result := FTargetPriority;
end;

procedure TFastCombatUnit.Initialize(A1: Integer);
var AUnit: TAbstractUnit;
begin
  inherited Initialize(A1);
  AUnit := FUnit;
  if (AUnit is TLeader) or (AUnit is THero) then FRoundDistance := 8
  else FRoundDistance := 4;
end;

procedure TFastCombatUnit.Activate(A1: Integer);
begin
  inherited Activate(A1);
  if TObject(A1) is TFastCombat then UpdateWallSiegeObjectRegistration;
end;

procedure TFastCombatUnit.Deactivate;
begin
  inherited Deactivate;
  if FCombat is TFastCombat then UpdateWallSiegeObjectRegistration;
end;

procedure TFastCombatUnit.DestroyObject;
begin
  inherited DestroyObject;
  if FCombat is TFastCombat then UpdateWallSiegeObjectRegistration;
end;

function TFastCombatUnit.fcWallInBetween(A1: Byte): Boolean;
begin
  Result := not (fsOutsideWall in FState) and
    TFastCombat(FCombat).GetWallInBetween(FPosition, A1);
end;

function TFastCombatUnit.fcBehindWall: Boolean;
var Position: Byte;
begin
  Result := False;
  if (GetSide = csDefender) and not (fsOutsideWall in FState) then
  begin
    Position := FPosition;
    if (Position and $F < 8) and (Position shr 4 < 8) and
      (FCombat.FCombatData.FParties.GetParty(Position shr 4).FWall <> 0) and
      not (csDestroyed in FCombat.FCombatData.FWall.FStatus) then Result := True;
  end;
end;

function TFastCombatUnit.fcExecute(A1: Integer): Boolean;
var
  Combat: TFastCombat;
  Commands: TFastCombatCommandList;
  AUnit: TAbstractUnit;
  I: Integer;
  Ability: TAbility;
  Action: TFleeCA;
  Executed: Boolean;
begin
  Combat := TFastCombat(FCombat);
  Commands := TFastCombatCommandList.Create(Self, Combat, Combat.FSides[GetSide]);
  AUnit := FUnit;
  for I := AUnit.GetAbilityCount - 1 downto 0 do
    if AUnit.GetAbilityEnabled(I) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility(I);
      Ability.fcPrefetchCombatCommands(Commands);
    end;
  if Commands.GetCount = 0 then
    if fcBehindWall then
      if TFastCombat(FCombat).AttackerCanCrushWall or
        (TFastCombat(FCombat).GetAttackerBalisticCV >
          TFastCombat(FCombat).GetDefenderBalisticCV * 1.5) then
      begin
        FState := FState + [fsOutsideWall];
        AUnit := FUnit;
        for I := AUnit.GetAbilityCount - 1 downto 0 do
          if AUnit.GetAbilityEnabled(I) then
          begin
            Ability := AoWHSSet.FAbilityControl.GetAbility(I);
            Ability.fcPrefetchCombatCommands(Commands);
          end;
        FState := FState - [fsOutsideWall];
      end;
  if (GetSide = csDefender) and (FAttackerCount = 0) and
    not FCombat.FCombatData.GetSideLeaderInvolved(1) then
    for I := Commands.GetCount - 1 downto 0 do
      if Commands.GetCommands(I).FTargetDV >= GetHitPoints * 75 then Commands.Delete(I);
  if Commands.GetCount <> 0 then
  begin
    Commands.Sort;
    if Commands.GetCommands(0).FMoveCost <= A1 then
    begin
      Executed := AoWHSSet.FAbilityControl.GetAbility(Commands.GetCommands(0).FAbilityID).
        fcExecuteCombatCommand(Self, Commands.GetCommands(0));
      if Commands.GetCommands(0).FAbilityID = $34 then UpdateWallSiegeObjectRegistration;
      TurnDone;
    end
    else Executed := False;
  end
  else
    if A1 = 2 then
    begin
      if (FCombatValue = 0) and (FIncomingCombatValue <> 0) and
        (GetSide = csAttacker) and not GetLocked then
      begin
        Action := TFleeCA.Create(nil);
        Action.FObjectID := FID;
        FCombat.ExecuteCombatAction(Action);
        Action.Release;
        Executed := True;
      end
      else Executed := False;
    end
    else Executed := False;
  Commands.Free;
  Result := Executed;
end;

constructor TFastCombat.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TFastCombat.Destroy;
begin end;

class function TFastCombat.ClassID: Integer;
begin Result := 0; end;

function TFastCombat.GetRoundDistance: Integer;
begin Result := 0; end;

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

function TFastCombat.GetWallInBetween(Source, Target: Byte): Boolean;
begin Result := False; end;

function TFastCombat.GetWallSituation(A1, A2: TCombatObject): TWallSituation;
begin Result := wsNone; end;

function TFastCombat.Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Byte; A7: Byte; A8: Integer; A9: Integer; A10: Integer; A11: Boolean): Boolean;
begin Result := False; end;

function TFastCombat.AttackerCanCrushWall: Boolean;
begin Result := False; end;

function TFastCombat.GetAttackerBalisticCV: Integer;
begin Result := 0; end;

function TFastCombat.GetDefenderBalisticCV: Integer;
begin Result := 0; end;

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

procedure TMoveControlSettings.SetupArmy(Army: TArmyHS; Selection: Byte);
begin end;

procedure TMoveControlSettings.SetupLevel(A1: Integer);
begin end;

procedure TMoveControlSettings.SetupMovePointData(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TMoveControlSettings.ClearMovePoints;
begin end;

function TMoveControlSettings.GetMovePoints(A1: Integer; A2: Integer; A3: Integer): Integer;
begin Result := 0; end;

procedure TMoveControlSettings.SetMovePoints(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TMoveControlSettings.GetMovePointLevelData(A1: Integer);
begin end;

function TMoveControlSettings.GetMovePointsXYL(Location: Integer): Integer;
begin Result := 0; end;

procedure TMoveControlSettings.SetMovePointsXYL(A1: Integer; A2: Integer);
begin end;

constructor TMoveControl.Create(AOwner: TAoWHSMap);
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

function TMoveControl.Process: Boolean;
begin Result := False; end;

procedure TMoveControl.CalculatePathEx(Path: TMovepath; X, Y, L: Shortint);
begin end;

procedure TMoveControl.CalculatePath(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TMoveControl.ExploredOnlyMoveOnMovePointProc(A1: Integer; A2: Integer);
begin end;

procedure TMoveControl.Activate(Settings: TMoveControlSettings);
begin end;

procedure TMoveControl.Deactivate;
begin end;

procedure TMoveControl.ProcessMove(A1: TMoveControlSettings);
begin end;

function TMoveControl.CanMove(Settings: TMoveControlSettings; Mode: TCanMoveMode): Integer;
begin Result := 0; end;

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

function TCombatRestoreHotseatEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
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

function TPadControl.CanPlacePad(X, Y, L: Shortint; Size: Integer): Boolean;
begin Result := False; end;

function TPadControl.PlacePad(X, Y, L: Shortint; Size: Integer): TILTerrainMO;
begin Result := nil; end;

{ Unnamed shared helper at $5574AC68; body remains for its owning worker. }
function ExecuteMultiArmyMove(Moves: TMoveSettingsList): Boolean;
begin Result := False; end;

