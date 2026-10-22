destructor TCombatTypeRequestEventLog.Destroy;
var Obj: TObject;
begin
  SetTokenEvent(nil);
  Obj := TObject(FArmyID);
  if Obj <> nil then Obj.Free;
  inherited Destroy;
end;

procedure TCombatTypeRequestEventLog.SetTokenEvent(A1: TTokenEvent);
begin
  { Original releases the old token before retaining its replacement. }
  if FTokenEvent <> nil then FTokenEvent.Release;
  FTokenEvent := TEObject(A1);
  if FTokenEvent <> nil then FTokenEvent.AddRef;
end;

function TCombatTypeRequestEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  PUSH EBX
  PUSH DWORD PTR [EBP+$0C]
  PUSH DWORD PTR [EBP+8]
  CALL EventLog.TEventLog.Execute
  POP EBX
end;

procedure TCombatTypeRequestEventLog.Select(A1: TCombatType);
begin FCombatType := A1; end;

procedure TCombatTypeRequestEventLog.SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);
begin
  FX := A1;
  FY := A2;
  FL := A3;
end;

constructor TCombatParty.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FArmy := TArmy.Create(nil); end;

destructor TCombatParty.Destroy;
begin
  FArmy.Deactivate;
  FArmy.Free;
  inherited Destroy;
end;

class function TCombatParty.ClassID: Integer;
begin Result := $202A2; end;

procedure TCombatParty.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(F_CombatParty_0C, $0B);
  Stream.rwInteger(F_CombatParty_10, $0C);
  Stream.rwInteger(F_CombatParty_14, $0D);
  Stream.rwByte(FPlayerIndex, $0E);
  Stream.rwData(FWall, 1, $0F);
  Stream.rwByte(F_CombatParty_19, $10);
end;

procedure TCombatParty.Activate(A1: Integer);
begin
  FArmy.SetPlayer(
    TCombatPlayerList(TCombat(A1).FCombatData.FPlayers).GetPlayers(FPlayerIndex).FPlayer);
end;

procedure TCombatParty.Deactivate(A1: Integer);
begin end;

function TCombatPartyList.GetControlStyle: Engine.TEControlStyles;
begin Result := [csSaveLoad, csArrayMode]; end;

function TCombatPartyList.CreateParty(A1: Integer; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer): TCombatParty;
var P: TCombatParty;
begin
  if GetParty(A2) = nil then
  begin
    P := TCombatParty.Create(nil);
    P.FPlayerIndex := A3;
    P.F_CombatParty_19 := A2;
    P.F_CombatParty_0C := A4;
    P.F_CombatParty_10 := A5;
    P.F_CombatParty_14 := A6;
    P.SetArrayOwner(Self, A2);
    TArmy(P.FArmy).SetXYL(Byte(A4), Byte(A5), A6);
    TArmy(P.FArmy).SetPlayer(
      TCombatPlayerList(TCombatData(TCombat(A1).FCombatData).FPlayers).
        GetPlayers(Shortint(A3)).FPlayer);
    if A7 <> 0 then TArmy(P.FArmy).AssignSettings(TArmy(A7));
    TArmy(P.FArmy).Activate;
  end
  else raise Exception.Create('CombatParty already exists!');
  Result := P;
end;

function TCombatPartyList.GetParty(A1: Byte): TCombatParty;
begin if A1 < FChildren.Count then Result := TCombatParty(FChildren.List^[A1]) else Result := nil; end;

procedure TCombatPartyList.Activate(A1: Integer);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then
      TCombatParty(FChildren.List^[I]).Activate(A1);
end;

procedure TCombatPartyList.Deactivate(A1: Integer);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then
      TCombatParty(FChildren.List^[I]).Deactivate(A1);
end;

class function TCombatPlayer.ClassID: Integer;
begin Result := $202A0; end;

procedure TCombatPlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
  Stream.rwByte(FIndependentRelation, $15);
  Stream.rwData(FSideIndex, 1, $16);
end;

constructor TCombatPlayerList.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

destructor TCombatPlayerList.Destroy;
begin inherited Destroy; end;

function TCombatPlayerList.GetPlayers(A1: Shortint): TCombatPlayer;
begin Result := TCombatPlayer(FChildren.List^[A1]); end;

function TCombatPlayerList.IndexOfPlayer(A1: Byte): Integer; { Near miss: byte comparison restored; item register differs after three variants. }
var P: TCombatPlayer; begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    P := TCombatPlayer(FChildren.List^[Result]); if A1 = Byte(P.FPlayer) then Exit;
  end;
  Result := -1;
end;

function TCombatPlayerList.IndexOf(A1: Byte; A2: Byte): Integer;
var P: TCombatPlayer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    P := TCombatPlayer(FChildren.List^[Result]);
    if (Shortint(A1) = P.FPlayer) and (P.FIndependentRelation = A2) then Exit;
  end;
  Result := -1;
end;

procedure TCombatPlayerList.Delete(A1: Integer);
begin GetPlayers(Shortint(A1)).Free; end;

constructor TCombatData.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPlayers := TCombatPlayerList.Create(nil);
  FParties := TCombatPartyList.Create(nil);
  F_CombatData_34 := Integer(TENode.Create(nil));
  F_CombatData_2C := Integer(TByteList.Create);
  FTurnOrder := TByteList.Create;
  F_CombatData_28 := Integer(TByteList.Create);
end;

destructor TCombatData.Destroy;
begin
  TObject(FParties).Free;
  TObject(FPlayers).Free;
  TObject(F_CombatData_34).Free;
  TObject(F_CombatData_2C).Free;
  TObject(F_CombatData_28).Free;
  TObject(FTurnOrder).Free;
  inherited Destroy;
end;

class function TCombatData.ClassID: Integer;
begin Result := $202A3; end;

procedure TCombatData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FX, $0A);
  Stream.rwInteger(FY, $0B);
  Stream.rwInteger(FL, $0C);
  Stream.rwData(F_CombatData_22, 2, $0D);
  Stream.rwByte(Byte(FAttackerPlayer), $0E);
  Stream.rwByte(Byte(FDefenderPlayer), $0F);
  Stream.rwData(F_CombatData_30, 1, $10);
  Stream.rwInteger(FRound, $11);
  Stream.rwEObject(TEObject(FPlayers), $12);
  Stream.rwEObject(TEObject(F_CombatData_34), $13);
  Stream.rwEObject(TEObject(FParties), $14);
  Stream.rwString(FHeader, $15);
  Stream.rwInteger(FAttackerX, $16);
  Stream.rwInteger(FAttackerY, $17);
  Stream.rwInteger(FAttackerL, $18);
  Stream.rwStreamProc($19, TByteList(F_CombatData_2C).LoadFromStream, TByteList(F_CombatData_2C).SaveToStream);
  Stream.rwStreamProc($1A, TByteList(FTurnOrder).LoadFromStream, TByteList(FTurnOrder).SaveToStream);
  Stream.rwData(FWallType, 1, $1B);
  Stream.rwBool(FWallBreached, $1C);
  Stream.rwStreamProc($1D, TByteList(F_CombatData_28).LoadFromStream, TByteList(F_CombatData_28).SaveToStream);
end;

function TCombatData.GetSideLeaderInvolved(A1: Byte): Boolean;
var I: Integer;
begin
  Result := False;
  I := TByteList(F_CombatData_28).Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := TCombatPlayerList(FPlayers).GetPlayers(Shortint(TByteList(F_CombatData_28)[I])).FSideIndex = A1;
  end;
end;

procedure TCombatData.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  TEObject(F_CombatData_34).MsgProc(Msg, Sender);
  TEObject(FParties).MsgProc(Msg, Sender);
end;

function TCombatData.GetCount: Integer;
begin Result := TP3NodeAccess(F_CombatData_34).ChildrenList.Count; end;

function TCombatData.GetObjects(A1: Integer): TCombatObject;
begin Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[A1]); end;

procedure TCombatData.Clear;
begin
  inherited Clear;
  TByteList(FTurnOrder).Clear;
  TCombatPlayerList(FPlayers).Clear;
  TENode(F_CombatData_34).Clear;
  TCombatPartyList(FParties).Clear;
end;

function TCombatData.IndexOfID(A1: Integer): Integer;
begin
  for Result := TENode(F_CombatData_34).Count - 1 downto 0 do
    if TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[Result]).FID = A1 then Exit;
  Result := -1;
end;

function TCombatData.FindID(A1: Integer): TCombatObject;
var I: Integer;
begin
  I := TP3NodeAccess(F_CombatData_34).ChildrenList.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]).FID = A1 then
    begin
      Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

function TCombatData.FindPosition(A1: Byte): TCombatObject;
var I: Integer;
begin
  Result := nil;
  I := TP3NodeAccess(F_CombatData_34).ChildrenList.Count;
  while (I <> 0) and (Result = nil) do
  begin
    Dec(I);
    if A1 = TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]).FPosition then
      Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]);
  end;
end;

procedure TCombatData.AddObject(A1: TCombatObject);
begin
  Assert((FindID(A1.FID) = nil) and (FindPosition(A1.FPosition) = nil),




























































    'CombatObject Position/ID double defined');
  A1.SetOwner(TENode(F_CombatData_34));
end;

constructor TCombatLogbook.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FActions := TCombatActionList.Create(nil);
  FFinalData := TCombatData.Create(nil);
  FInitialData := TCombatData.Create(nil);
  F_CombatLogbook_19 := False;
end;

destructor TCombatLogbook.Destroy;
begin
  Clear;
  TObject(FActions).Free;
  TObject(FFinalData).Free;
  TObject(FInitialData).Free;
  inherited Destroy;
end;

procedure TCombatLogbook.SetInitialData(Data: TCombatData);
begin FInitialData.Assign(Data,AoWEngine); end;

procedure TCombatLogbook.SetFinalData(Data: TCombatData);
begin FFinalData.Assign(Data,AoWEngine); end;

procedure TCombatLogbook.Clear;
begin
  TEObject(FFinalData).Clear;
  TEObject(FInitialData).Clear;
  TEObject(FActions).Clear;
end;

class function TCombatLogbook.ClassID: Integer;
begin Result := $202A5; end;

function TCombatLogbook.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TCombatLogbook.Release: Integer;
var N: Integer;
begin
  Dec(FRefCount);
  N := FRefCount;
  Result := N;
  if N = 0 then Destroy;
end;

procedure TCombatLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(FInitialData), 5);
  Stream.rwEObject(TEObject(FFinalData), 6);
  Stream.rwEObject(TEObject(FActions), 7);
  Stream.rwBool(F_CombatLogbook_19, 8);
end;

destructor TCombatEventLog.Destroy;
var L: TCombatLogbook;
begin
  L := TCombatLogbook(FLogbook);
  if L <> nil then begin L.Release; FLogbook := nil; end;
  inherited Destroy;
end;

class function TCombatEventLog.ClassID: Integer;
begin Result := $202E2; end;

procedure TCombatEventLog.SetCombatLogbook(Logbook: TCombatLogbook);
var Old: TCombatLogbook;
begin
  Old := FLogbook;
  if Old <> Logbook then
  begin
    if Old <> nil then Old.Release;
    FLogbook := Logbook;
    if FLogbook <> nil then FLogbook.AddRef;
  end;
end;

procedure TCombatEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwCreateEObject(TEObject(FLogbook), nil, $14); end;

function TCombatEventLog.GetTextColor: TColor;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer <> 0 then
    Result := RaceColors[AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer)).FPlayerRace]
  else Result := RaceColors[12];
end;

function TCombatEventLog.GetLeftIcon: Integer;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer <> 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer)).FPlayerRace
  else Result := 12;
end;

function TCombatEventLog.GetMiddleIcon: Integer;
begin Result := $0D; end;

function TCombatEventLog.GetRightIcon: Integer;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer <> 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer)).FPlayerRace
  else Result := 12;
end;

function TCombatEventLog.GetText: string;
begin
  { needs: string result in EventLog's unmarked interface. }
  Result := TCombatData(TCombatLogbook(FLogbook).FFinalData).FHeader;
end;

procedure TCombatEventLog.PlayLoggedSFX(A1: TEventLogbook);
begin
  if TCombatPlayerList(FLogbook.FInitialData.FPlayers).IndexOfPlayer(AoWHSMap.FSeatedPlayer) <> -1 then
    PlaySample('SFX\EVENTS\ROLL.WAV')
  else PlaySample('SFX\EVENTS\NEWEVENT.WAV');
end;

function TCombatEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var ShowCombat: Boolean; Data: TCombatData;
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
        if TCombatPlayerList(FLogbook.FInitialData.FPlayers).IndexOfPlayer(AoWHSMap.FSeatedPlayer) <> -1 then
        begin
          Data := FLogbook.FInitialData;
          ShowCombat := TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer = AoWHSMap.FSeatedPlayer;
          ShowCombat := ShowCombat or (AoWHSMap.FRequestCombatType and
            (AoWHSMap.FConnectionType = pcEmail) and
            (TCombatPlayerList(FLogbook.FInitialData.FPlayers).GetPlayers(FLogbook.FInitialData.FDefenderPlayer).FPlayer = AoWHSMap.FSeatedPlayer));
          ShowCombat := ShowCombat or ((Trigger = etEvent) and (AoWHSMap.FPlayMode = pmTurn) and
            (wpCombat in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
          ShowCombat := ShowCombat or ((Trigger = etEvent) and (AoWHSMap.FPlayMode = pmSimultaneous) and
            (wpCombat in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
          ShowCombat := ShowCombat and (FLogbook.FCombatResult <> crNoDefenders);
        end
        else ShowCombat := False;
        ShowCombat := ShowCombat or FLogbook.F_CombatLogbook_19;
        if ShowCombat then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end
        else Result := False;
      end;
  end;
end;

procedure TCombatEventLog.ViewLocation;
{ needs: EventLog.TEventLog.CenterViewTo has three Byte arguments. }
asm
  MOV EDX, [EAX+$18]
  MOV EDX, [EDX+$10]
  MOV CL, [EDX+$10]
  PUSH ECX
  MOV CL, [EDX+$0C]
  MOV DL, [EDX+8]
  CALL EventLog.TEventLog.CenterViewTo
end;

procedure DistributeCombatEvent(Logbook: TCombatLogbook; Execute: Boolean);
var
  Data: TCombatData;
  I: Integer;
  Event: TCombatEventLog;
begin
  Data := TCombatData(Logbook.FFinalData);
  for I := 1 to AoWHSMap.FPlayers.GetCount - 1 do
    if AoWHSMap.VisibleForPlayer(
      Data.FX, Data.FY, Data.FL, I) or
      (TCombatPlayerList(TCombatData(Logbook.FInitialData).FPlayers).IndexOfPlayer(I) <> -1) then
    begin
      Event := TCombatEventLog.Create(nil);
      Event.SetCombatLogbook(Logbook);
      AoWHSMap.FPlayers.GetPlayers(I).FEventLogbook.AddEvent(Event);
      if Execute and (I = AoWHSMap.FSeatedPlayer) and
        (AoWHSMap.FPlayers.GetPlayers(I).FPlayerType = ptHuman) and
        (TCombatData(Logbook.FFinalData).F_CombatData_30 <> 6) then
        Event.Execute(False, etEvent, nil);
      Event.Release;
    end;
end;

constructor TCombatViewer.Create;
begin
  inherited Create;
  FCombat := TCombat.Create(nil);
  FTime := -1;
  FSpeed := 5;
  FDelay := 5;
end;

destructor TCombatViewer.Destroy;
begin
  if vsInitialized in FStatus then Finalize;
  TObject(FCombat).Free;
  inherited Destroy;
end;

procedure TCombatViewer.Initialize(A1: TCombatLogbook);
begin
  if vsInitialized in FStatus then Finalize;
  FStatus := [vsInitialized];
  FLogbook := A1;
  FLogbook.AddRef;
  FPosition := 0;
  FTime := -1;
  TCombatData(FCombat.FCombatData).Assign(A1.FInitialData, AoWEngine);
  FCombat.Activate;
  FDelay := FSpeed;
end;

procedure TCombatViewer.Finalize;
begin
  if vsInitialized in FStatus then
  begin
    TCombat(FCombat).Deactivate;
    TCombat(FCombat).Clear;
    TCombatLogbook(FLogbook).Release;
    FLogbook := nil;
    FStatus := FStatus - [vsInitialized];
  end;
end;

function TCombatViewer.GetEndPosition: Integer;
begin Result := TCombatActionList(TCombatLogbook(FLogbook).FActions).Count + 1; end;

procedure TCombatViewer.SetSpeed(A1: Byte);
begin if A1 = 0 then A1 := 1; FSpeed := A1; end;

procedure TCombatViewer.SetPosition(A1: Integer);
begin
  if vsInitialized in FStatus then
  begin
    FTime := -1;
    if A1 > GetEndPosition then A1 := GetEndPosition;
    if (A1 > 0) and (A1 <= FLogbook.FActions.Count) then
    begin
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FInitialData, AoWEngine);
      FCombat.Activate;
      FPosition := 0;
      while A1 > FPosition do
      begin
        Inc(FPosition);
        if A1 <> FPosition then FLogbook.FActions.GetCombatActions(FPosition-1).Execute(FCombat);
      end;
    end
    else if A1 = 0 then
    begin
      FPosition := 0;
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FInitialData, AoWEngine);
      FCombat.Activate;
    end
    else
    begin
      FPosition := GetEndPosition;
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FFinalData, AoWEngine);
      FCombat.Activate;
    end;
  end
  else FPosition := A1;
end;

procedure TCombatViewer.Play;
begin FStatus := (FStatus + [vsPlaying]) - [vsPaused]; end;

procedure TCombatViewer.Pause;
begin FStatus := FStatus + [vsPaused]; end;

procedure TCombatViewer.Update;
var Playing: Boolean;
begin
  if (FStatus * [vsInitialized, vsPlaying, vsPaused] = [vsInitialized, vsPlaying]) and
    (GetEndPosition <> FPosition) then
  begin
    Playing := False;
    if FPosition = 0 then
    begin
      Inc(FTime);
      if FTime >= FDelay then
      begin
        FPosition := 1;
        FTime := -1;
      end;
    end;
    while (FPosition > 0) and
      (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) and not Playing do
    begin
      Inc(FTime);
      Playing := TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).Play(Self);
      if not Playing then
      begin
        Inc(FPosition);
        FDelay := FSpeed;
        FTime := -1;
      end;
    end;
    if GetEndPosition = FPosition then SetPosition(GetEndPosition);
  end;
end;

procedure TCombatViewer.ShowObject(A1: TCombatObject; A2: Integer; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if TCombatActionList(TCombatLogbook(FLogbook).FActions).Count >= FPosition then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowObject(Self, TCombatObject(A1), A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFieldObject(A1: TCombatObject; A2: Integer; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if (FPosition > 0) and (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowFieldObject(Self, TCombatObject(A1), A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; const A4: TSurfaceDesc);
begin
  if (FPosition > 0) and
    (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowFightingObjects(Self, A1, A2, A3, A4);
end;

procedure TCombatViewer.DefaultShowFightingObjects(A1: TCombatObject; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if A2 <> nil then
    if TCombatObject(A2).GetSide = csAttacker then ShowObject(A2, A3, 3, A4, A5, A6)
    else ShowObject(A2, A3, 5, A4 + 25, A5, A6);
  if A1 <> nil then
    if TCombatObject(A1).GetSide = csAttacker then ShowObject(A1, A3, 2, A4, A5 + 15, A6)
    else ShowObject(A1, A3, 6, A4 + 25, A5 + 15, A6);
end;

constructor TCombatAction.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FRefCount := 1; end;

function TCombatAction.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TCombatAction.Release: Integer;
var N: Integer;
begin
  Dec(FRefCount);
  N := FRefCount;
  Result := N;
  if N = 0 then Destroy;
end;

function TCombatAction.GetName: string;
begin Result := ClassName; end;

procedure TCombatAction.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
begin end;

function TCombatActionList.GetCombatActions(A1: Integer): TCombatAction;
begin Result := TCombatAction(FChildren.List^[A1]); end;

procedure TSingleTargetCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FSourceID, $0A);
  Stream.rwByte(FTargetID, $0B);
  Stream.rwData(FMode, 1, $0C);
end;

function TSingleTargetCA.GetDefensive: Boolean;
begin Result := smDefensive in FMode; end;

procedure TSingleTargetCA.SetDefensive(A1: Boolean);
begin
  if A1 then FMode := FMode + [smDefensive]
  else FMode := FMode - [smDefensive];
end;

procedure TSingleTargetCA.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if not (smDefensive in FMode) then
  begin
    if TCombatObject(A2).FID = FSourceID then AoWHSSet.FCombatImages[2].Show(A5+15,A6+18,A7);
  end
  else if TCombatObject(A2).FID = FTargetID then AoWHSSet.FCombatImages[2].Show(A5+15,A6+18,A7);
  ShowObject(TCombatViewer(A1),TCombatObject(A2),A3,A4,A5,A6,A7);
  if not (smDefensive in FMode) then
  begin
    if TCombatObject(A2).FID = FTargetID then AoWHSSet.FCombatImages[3].Show(A5+15,A6+18,A7);
  end
  else if TCombatObject(A2).FID = FSourceID then AoWHSSet.FCombatImages[3].Show(A5+15,A6+18,A7);
end;

procedure TSingleTargetCA.ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
var Source, Target: TCombatObject;
begin
  Source := TCombatData(A1.FCombat.FCombatData).FindID(FSourceID);
  Target := TCombatData(A1.FCombat.FCombatData).FindID(FTargetID);
  if not (smDefensive in FMode) then
    A1.DefaultShowFightingObjects(Source,Target,A2,A3,A4,A5)
  else A1.DefaultShowFightingObjects(Target,Source,A2,A3,A4,A5);
end;

class function TDamageCA.ClassID: Integer;
begin Result := $202B1; end;

procedure TDamageCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDamage, $0F);
  Stream.rwData(FEffects, 2, $10);
  Stream.rwData(FDamageTypes, 2, $11);
end;

procedure TDamageCA.Setup(A1: Byte; A2: Byte; A3: Byte; A4: TDamageTypes; A5: TDamageTypes; A6: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FDamage := A3;
  FEffects.Value := A4;
  FDamageTypes.Value := A5;
  if A6 then FMode := FMode + [smDefensive];
end;

procedure TDamageCA.Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes);
var DamageTypes: TDamageTypes absolute A5;
begin
  FSourceID := TCombatObject(A1).FID;
  FTargetID := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRole(Shortint(A3), Shortint(A4), DamageTypes);
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.GenerateEx(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes; A6: Byte);
var DamageTypes: TDamageTypes absolute A5;
begin
  FSourceID := TCombatObject(A1).FID;
  FTargetID := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRoleEx(Shortint(A3), Shortint(A4), DamageTypes, Byte(A6));
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.Execute(A1: TCombat);
var Target, Source: TCombatObject;
begin
  Source := A1.FCombatData.FindID(FSourceID);
  Target := A1.FCombatData.FindID(FTargetID);
  if FDamage <> 0 then FDamageDone := Source.DoDamage(Target, FDamage);
  if FEffects.Value <> [] then Target.ExecuteDamageEffects(FEffects.Value);
end;

function TDamageCA.Play(A1: TCombatViewer): Boolean; { Near miss: Three variants retain an extra cached delay register. }
var HitFrame, Duration, EffectFrames: Integer; Target: TCombatObject;
begin
  if A1.FDelay < 5 then HitFrame := A1.FDelay else HitFrame := 5;
  if HitFrame = A1.FTime then
  begin
    Execute(TCombatViewer(A1).FCombat);
    Target := TCombatData(TCombat(TCombatViewer(A1).FCombat).FCombatData).FindID(FTargetID);
    if FDamageDone <> 0 then
      if not (csDestroyed in Target.FStatus) then Target.PlaySFX(2) else Target.PlaySFX(3);
  end;
  Duration := A1.FDelay * 2;
  if FEffects.Value <> [] then
  begin
    EffectFrames := AoWE.DamageEffectsAnimationFrames(FEffects.Value) + A1.FDelay;
    HitFrame := A1.FDelay * 3;
    if EffectFrames > HitFrame then EffectFrames := HitFrame;
    if Duration < EffectFrames then Duration := EffectFrames;
  end;
  Result := Duration > A1.FTime;
end;

procedure TDamageCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
var HitFrame: Integer;
begin
  if TCombatObject(A2).FID = FSourceID then
    TCombatObject(A2).ShowAttackAnimation(TCombatViewer(A1).FTime, A4, A5, A6, A7)
  else
  begin
    if TCombatViewer(A1).FDelay < 5 then HitFrame := TCombatViewer(A1).FDelay else HitFrame := 5;
    if (TCombatObject(A2).FID = FTargetID) and (FDamageDone <> 0) and (HitFrame <= TCombatViewer(A1).FTime) then
    begin
      TCombatObject(A2).Show(A3, A4, A5, A6, A7);
      if FEffects.Value <> [] then AoWE.ShowDamageEffects(FEffects.Value, A5, A6, TCombatViewer(A1).FTime - HitFrame, A7);
      { needs: P1 ShowDamageIcon has five arguments; DamageTypesToDamageType returns TDamageType. }
      AoWE.ShowDamageIcon(A5, A6, A7, FDamageDone, AoWE.DamageTypesToDamageType(FDamageTypes.Value));
    end
    else TCombatObject(A2).Show(A3, A4, A5, A6, A7);
  end;
end;

function CreateDamageCA(Source, Target: TCombatObject; Damage: Integer; Defensive: Boolean; DamageTypes: TDamageTypes): TDamageCA;
var
  Action: TDamageCA;
begin
  Action := TDamageCA.Create(nil);
  Action.Generate(Source, Target, Shortint(Damage), Shortint(Defensive), DamageTypes);
  Result := Action;
end;

class function TDamageEffectCA.ClassID: Integer;
begin Result := $202B2; end;

procedure TDamageEffectCA.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwData(FDamageType, 1, $0F); end;

procedure TDamageEffectCA.Initialize(A1: Byte; A2: Byte; A3: Byte; A4: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FDamageType := TDamageType(A3);
  if A4 then FMode := FMode + [smDefensive];
end;

procedure TDamageEffectCA.Execute(A1: TCombat);
var Combat: TCombat; Target, Source: TCombatObject;
begin
  Combat := TCombat(A1);
  Target := TCombatData(Combat.FCombatData).FindID(FTargetID);
  if not (csDestroyed in Target.FStatus) then
  begin
    Source := TCombatData(Combat.FCombatData).FindID(FSourceID);
    Target.ExecuteDamageEffects([TDamageType(FDamageType)]);
    if csDestroyed in Target.FStatus then
      with Source do SetExperience(GetExperience + Target.GetLevel);
  end;
end;

function TDamageEffectCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean Play result despite the unmarked P4 overrides. }
asm
  PUSH EBX
  MOV EBX, EDX
  XOR EDX, EDX
  MOV DL, [EBX+$0C]
  ADD EDX, EDX
  CMP EDX, [EBX+$14]
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  ADD EAX, EAX
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

procedure TDamageEffectCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if TCombatObject(A2).FID = FTargetID then
    case FDamageType of
      dtFire:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($7F).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtPoison:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($60).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtCold:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($5F).FImageSequences.Show(1,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtDeath:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($5D).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtHoly:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($62).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
    else TCombatObject(A2).Show(A3,A4,A5,A6,A7);
    end
  else TCombatObject(A2).Show(A3,A4,A5,A6,A7);
end;

class function TUpdateHeaderCA.ClassID: Integer;
begin Result := $202B6; end;

procedure TUpdateHeaderCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(F_UpdateHeaderCA_0C, $14);
end;

procedure TUpdateHeaderCA.Execute(A1: TCombat);
{ conflict: procedure TUpdateHeaderCA.Execute(A1: TCombat; A2: Integer); }
begin TCombatData(TCombat(A1).FCombatData).FHeader := F_UpdateHeaderCA_0C; end;

function TUpdateHeaderCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

class function TNewCombatTurnCA.ClassID: Integer;
begin Result := $202BA; end;

procedure TNewCombatTurnCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(F_NewCombatTurnCA_0C, $14);
end;

procedure TNewCombatTurnCA.Execute(A1: TCombat);
var I: Integer;
begin
  TCombatData(TCombat(A1).FCombatData).FCurrentPlayer := F_NewCombatTurnCA_0C;
  for I := TCombatData(TCombat(A1).FCombatData).GetCount - 1 downto 0 do
    TCombatData(TCombat(A1).FCombatData).GetObjects(I).NewTurn(F_NewCombatTurnCA_0C);
end;

function TNewCombatTurnCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
  begin
    Execute(A1.FCombat);
    PlaySample('SFX\EVENTS\INFO2.WAV');
  end;
  Result := A1.FDelay > A1.FTime;
end;

class function TNewCombatRoundCA.ClassID: Integer;
begin Result := $202BB; end;

procedure TNewCombatRoundCA.Execute(A1: TCombat);
var I: Integer;
begin
  with A1.FCombatData do Inc(FRound);
  for I := A1.FCombatData.GetCount - 1 downto 0 do
    A1.FCombatData.GetObjects(I).NewRound;
end;

function TNewCombatRoundCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  PUSH EBX
  MOV EBX, EDX
  CMP DWORD PTR [EBX+$14], 0
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

class function TCombatObjectTurnDoneCA.ClassID: Integer;
begin Result := $202BC; end;

procedure TCombatObjectTurnDoneCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(F_CombatObjectTurnDoneCA_0C, 1, $14);
end;

procedure TCombatObjectTurnDoneCA.Execute(A1: TCombat);
var Obj: TCombatObject;
begin
  Obj := TCombatData(TCombat(A1).FCombatData).FindID(F_CombatObjectTurnDoneCA_0C);
  Obj.FStatus := Obj.FStatus + [csTurnDone];
end;

function TCombatObjectTurnDoneCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  PUSH EBX
  MOV EBX, EDX
  CMP DWORD PTR [EBX+$14], 0
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

class function TMoveWallCA.ClassID: Integer;
begin Result := $202B7; end;

procedure TMoveWallCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(F_MoveWallCA_0C, 1, $14);
  Stream.rwData(F_MoveWallCA_0D, 1, $15);
end;

procedure TMoveWallCA.Execute(A1: TCombat);
var Obj: TFastCombatUnit;
begin
  Obj := TFastCombatUnit(TCombatData(TCombat(A1).FCombatData).FindID(F_MoveWallCA_0C));
  if F_MoveWallCA_0D = 0 then Obj.FState := Obj.FState + [fsOutsideWall];
  if F_MoveWallCA_0D = 1 then Obj.FState := Obj.FState - [fsOutsideWall];
end;

function TMoveWallCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

class function TFleeCA.ClassID: Integer;
begin Result := $202C0; end;

procedure TFleeCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FObjectID, 1, $14);
end;

procedure TFleeCA.Execute(A1: TCombat);
var Obj: TCombatObject;
begin
  Obj := TCombatData(TCombat(A1).FCombatData).FindID(FObjectID);
  Obj.FStatus := Obj.FStatus + [csFled];
end;

function TFleeCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

