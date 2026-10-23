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
  { Reach the leader through its field. }
  if FLeader <> nil then
  begin
    FLeader.GetLocation(Location.X, Location.Y, Location.L);
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
  X, Y, L: Shortint;
begin
  Locations := TXYLList.Create;
  for I := Count - 1 downto 0 do
  begin
    GetUnit(I).GetLocation(X, Y, L);
    Locations.Add(PackXYL(X, Y, L));
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
function TAIGroup.SetupTarget(Target: TAIGroupControlTarget; { Near miss: register or temporary allocation differs after three variants. }
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
  if OldTransporter <> AUnit then
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
function TAIGroup.CooperateWithGroup(Group: TAIGroup; Target: TAIGroupControlTarget): Boolean;
begin
  Result := Group.Behavior = Behavior;
end;
function TAIGroup.DefendLocation(Location: Integer; Priority: TDefensePriority): Boolean;
var
  GroupLocation: TXYL;
begin
  GroupLocation.XYL := GetLoc;
  if (TXYL(Location).L = GroupLocation.L) and
    (dHXtoRad(TXYL(Location).X, TXYL(Location).Y, GroupLocation.X, GroupLocation.Y) <= 1) then
    Result := True
  else Result := False;
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

procedure TAIGroup.Deactivate; { Review fix: retain the original assertion filename and line. }
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:30; Text:'D:\AoWDev\AoWE\inc\AIGroup.pas'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:17; Text:'Assertion failure'#0); var
  Player: Shortint;
begin
  if not (agsActivated in FStatus) then asm MOV ECX,$5E1E; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
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

procedure TAIGroupControl.MoveExecuterDone(Sender: TObject);
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
        if FCombatPredictor.Execute in [crVictory, crDefeat, crNoDefenders] then
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
begin
  inherited Create;
  FDefenders := TUnitUserList.Create(nil);
end;

destructor TGroupDefenseSelector.Destroy;
begin
  FDefenders.Free;
  inherited Destroy;
end;

function TGroupDefenseSelector.GetDefenders(Player, X, Y, L: Shortint;
  Units: TUnitList): Boolean;
var
  Priority: TDefensePriority;
  Location: Integer;
  P: TPlayer;
  I: Integer;
  Group: TAIGroup;
begin
  Result := False;
  Location := Integer(HSEngine.PackXYL(X, Y, L));
  Priority := TDefensePriority(TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetDefensePriority);
  P := AoWHSMap.FPlayers.GetPlayers(Player);
  for I := P.FAIGroups.Count - 1 downto 0 do
  begin
    Group := P.FAIGroups.GetGroups(I);
    if Group.DefendLocation(Location, Priority) then
    begin
      Units.AddUnits(Group);
      Result := True;
    end;
  end;
end;

function TGroupDefenseSelector.EnoughStrength(var Strengths: TDamageStrengths): Boolean;
var
  DamageType: TDamageType;
begin
  for DamageType := Low(TDamageType) to High(TDamageType) do
  begin
    Result := Strengths[DamageType] <= 0;
    if not Result then Break;
  end;
end;

function TGroupDefenseSelector.UsefullUnit(AUnit: TAbstractUnit;
  var Strengths: TDamageStrengths): Boolean;
var
  DamageType: TDamageType;
begin
  for DamageType := Low(TDamageType) to High(TDamageType) do
  begin
    Result := (Strengths[DamageType] > 0) and (AUnit.GetStrength(DamageType) > 0);
    if Result then Break;
  end;
end;

procedure TGroupDefenseSelector.UpdateDefenseLocation(MapF: TAoWMapField);
begin
  if (Integer(FDefenseLocation) = $FFFFFF) or (MapF.FindOwnedHS(TStructure) <> nil) then
    FDefenseLocation.XYL := MapF.GetXYL;
end;

function CompareDefenseUnits(Item1, Item2: Pointer): Integer;
var
  In1, In2: Boolean;
begin
  Result := TAbstractUnit(Item1).FGroup.FRecruitmentPriority -
    TAbstractUnit(Item2).FGroup.FRecruitmentPriority;
  if Result = 0 then begin
    Result := TAbstractUnit(Item1).FGroupID - TAbstractUnit(Item2).FGroupID;
  if (Result = 0) and (TAbstractUnit(Item1).FGroupID = DefenseSortGroupID) then
  begin
    if DefenseSortUnits <> nil then
    begin
      In1 := DefenseSortUnits.FChildren.IndexOf(Item1) <> -1;
      In2 := DefenseSortUnits.FChildren.IndexOf(Item2) <> -1;
      if In1 and not In2 then Result := 1
      else if In2 and not In1 then Result := -1;
    end;
    if Result = 0 then
      Result := TAbstractUnit(Item1).GetStrengthMax(dtAll) -
        TAbstractUnit(Item2).GetStrengthMax(dtAll);
  end; end;
end;

function TGroupDefenseSelector.Execute(Group: TAIGroup; X, Y, L: Shortint;
  Units: TUnitList): Boolean;
var
  Candidates: TUnitUserList;
  Start, I: Integer;
  Level: TMapLevel;
  AUnit: TAbstractUnit;
  MapF: TAoWMapField;
  DamageType: TDamageType;
  Strengths: TDefenseRequirements;
  Walk: THNWalkData;
begin
  FDefenders.Clear;
  Level := AoWHSMap.MapContainer.GetMapLevel(L);
  FDefenseLocation.XYL := $FFFFFF;
  Candidates := TUnitUserList.Create(nil);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= 1) and (FDefenders.Count <> Group.Count) do
  begin
    MapF := TAoWMapField(Level.GetField(Walk.X, Walk.Y));
    if MapF.GetPlayer = Group.FPlayer then
    begin
      Candidates.Clear;
      MapF.GetDefenseRequirements(Group.FPlayer, Strengths);
      if not EnoughStrength(Strengths.DamageStrengths) then
      begin
        UpdateDefenseLocation(MapF);
        GetDefenders(Group.FPlayer, Walk.X, Walk.Y, L, Candidates);
        DefenseSortGroupID := Group.FGroupID;
        DefenseSortUnits := Units;
        Candidates.FChildren.Sort(CompareDefenseUnits);
        I := 0;
        while (Candidates.Count <> I) and
          (Candidates.GetUnit(I).FGroupID <> Group.FGroupID) do
        begin
          AUnit := Candidates.GetUnit(I);
          for DamageType := Low(TDamageType) to High(TDamageType) do
            Dec(Strengths.DamageStrengths[DamageType], AUnit.GetStrength(DamageType));
          Inc(I);
        end;
        Start := I;
        for I := 0 to FDefenders.Count - 1 do
        begin
          AUnit := FDefenders.GetUnit(I);
          for DamageType := Low(TDamageType) to High(TDamageType) do
            Dec(Strengths.DamageStrengths[DamageType], AUnit.GetStrength(DamageType));
        end;
        I := Start;
        while not EnoughStrength(Strengths.DamageStrengths) and (Candidates.Count > I) and
          (Candidates.GetUnit(I).FGroupID = Group.FGroupID) do
        begin
          AUnit := Candidates.GetUnit(I);
          if (FDefenders.FChildren.IndexOf(AUnit) = -1) and UsefullUnit(AUnit, Strengths.DamageStrengths) then
          begin
            FDefenders.AddUnit(AUnit);
            for DamageType := Low(TDamageType) to High(TDamageType) do
              Dec(Strengths.DamageStrengths[DamageType], AUnit.GetStrength(DamageType));
          end;
          Inc(I);
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
  Candidates.Free;
  if Units <> nil then
  begin
    Result := True;
    I := Units.Count;
    while Result and (I <> 0) do
    begin
      Dec(I);
      if FDefenders.IndexOf(Units.GetUnit(I)) <> -1 then Result := False;
    end;
  end
  else Result := FDefenders.Count = 0;
  AoWHSMap.FAIExecuter.UseProcessTime(30);
end;

constructor TAIGroupDefenseControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSelector := TGroupDefenseSelector.Create;
  FMode := [];
  FDefendMode := gdmWait;
  FState := 0;
end;

destructor TAIGroupDefenseControl.Destroy;
begin
  FSelector.Free;
  inherited Destroy;
end;

function TAIGroupDefenseControl.GetBusy: Boolean;
begin
  Result := (FState <> -1) and (gpsActivated in FStatus);
end;

function TAIGroupDefenseControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FGroupControl := Control;
  FState := 0;
  Result := True;
end;

function TAIGroupDefenseControl.Process: Boolean;
var
  Units: TUnitUserList;
  Index: Integer;
  Group: TAIGroup;
begin
  case FState of
    0:
      begin
        with FGroupControl do
          FSelector.Execute(FGroup, FLocation.X, FLocation.Y, FLocation.L, nil);
        if FSelector.FDefenders.Count <> 0 then
        begin
          case FDefendMode of
            gdmSplit:
              begin
                Units := TUnitUserList.Create(nil);
                with FGroupControl do
                  FSelector.GetDefenders(FGroup.FPlayer, FLocation.X, FLocation.Y, FLocation.L, Units);
                Index := Units.IndexOfBehavior(gbPassive);
                if Index = -1 then
                begin
                  Group := AoWHSMap.FAIGroupManager.CreateGroup(FGroupControl.FGroup.FPlayer,
                    FGroupControl.FGroup.FIndependentRelation, gbPassive);
                  Group.AddUnits(FSelector.FDefenders);
                  Group.SetupTargetEx(FGroupControl.FLocation, 0, gtsNone, 2, -1, 0, 0);
                  Group.Release;
                end
                else
                begin
                  Group := Units.GetUnit(Index).FGroup;
                  Group.AddUnits(FSelector.FDefenders);
                end;
                Units.Free;
                Done;
              end;
            gdmWait:
              begin
                FGroupControl.Done;
                if gdmProduce in FMode then FState := 1;
              end;
            gdmCustom:
              begin
                FGroupControl.FState := FCustomState;
                Done;
              end;
          end;
        end
        else Done;
      end;
    1: Done;
  end;
  Result := False;
end;

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

function TAIGroupRecruitControl.Setup(Control: TAIGroupControl): Boolean;
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
var Count: Integer; begin
  Dec(FRefCount);
  Count := FRefCount; Result := Count;
  if Count = 0 then Destroy;
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
begin
  inherited Create(AOwner);
  FGroups := TAIRecruitmentGroupList.Create(nil);
end;

destructor TAIGroupCooperationControl.Destroy;
begin
  FGroups.Free;
  inherited Destroy;
end;

function TAIGroupCooperationControl.GetCooperateMoveDays: Integer;
var
  I, Moves, Days: Integer;
begin
  Result := -1;
  { Original bug: the first cooperation group is skipped. }
  for I := 1 to FGroups.Count - 1 do
  begin
    Moves := FGroups.GetRecruitmentGroups(I).FGroup.GetMovesMin;
    if Moves > 0 then
    begin
      Days := (FGroups.GetRecruitmentGroups(I).FMovePoints - 1) div Moves;
      if Result < Days then Result := Days;
    end;
  end;
end;

function TAIGroupCooperationControl.GetCooperatedStrength: Integer;
begin
  Result := FCooperateStrength - FRemainingStrength;
end;

function TAIGroupCooperationControl.GetCooperateStrengthEx(DamageType: TDamageType): Integer;
begin
  Result := FCooperateStrengths[DamageType];
end;

procedure TAIGroupCooperationControl.SetCooperateStrengthEx(DamageType: TDamageType; Value: Integer);
begin
  FCooperateStrengths[DamageType] := Value;
end;

procedure TAIGroupCooperationControl.UpdateCompletion;
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

procedure TAIGroupCooperationControl.Reset;
begin
  FGroups.Clear;
  FComplete := False;
  FMode := ccmNone;
  FTarget := nil;
  FCooperateStrength := 0;
  FDamageTypes := dtAll - [dtWall];
  FillChar(FCooperateStrengths, SizeOf(FCooperateStrengths), 0);
  FSuperiority := 120;
  FPathStrengthFactor := 0.8;
  FState := 0;
end;

function TAIGroupCooperationControl.GetBusy: Boolean;
begin
  Result := FState <> -1;
end;

function TAIGroupCooperationControl.Setup(Control: TAIGroupControl;
  Target: TAIGroupControlTarget): Boolean;
begin
  Reset;
  FTarget := Target;
  Result := True;
end;

function TAIGroupCooperationControl.Activate(Control: TAIGroupControl): Boolean;
begin
  FControl := Control;
  FRemainingStrength := FCooperateStrength;
  UpdateCompletion;
  Result := True;
end;

procedure TAIGroupCooperationControl.AddCooperationGroup(Group: TAIRecruitmentGroup);
var
  I: Integer;
  AUnit: TAbstractUnit;
  D: TDamageType;
begin
  FGroups.AddChild(Group);
  for I := Group.FGroup.Count - 1 downto 0 do
  begin
    AUnit := Group.FGroup.GetUnit(I);
    Dec(FRemainingStrength, AUnit.GetStrengthMax(FDamageTypes));
    for D := Low(TDamageType) to High(TDamageType) do
      Dec(FRemainingStrengths[D], AUnit.GetStrength(D));
    if FSuperiority <> -1 then FControl.FCombatPredictor.AddUnit(AUnit);
  end;
  UpdateCompletion;
end;

function TAIGroupCooperationControl.ValidCooperationGroup(Group: TAIRecruitmentGroup): Boolean; { Review fix: cache the second move-point result; register allocation still differs. }
var
  Strength1, Strength2, Strength, Location, Advantage1, Advantage2, Moves, OtherMoves: Integer;
begin
  if (Group.FGroup.FTransporterID = -1) and
    (((Integer(Group.FGroup.FTargetXYL) = Integer(FTarget.FLocation)) and
      (Group.FGroup.FTargetType = gtsSetup)) or
      (Group.FGroup.FTargetType in [gtsNone, gtsIdle])) and
    Group.FGroup.CooperateWithGroup(FControl.FGroup, FTarget) then
  begin
    if Group.FPathStrength <> 0 then
    begin
      Location := Group.FGroup.GetLoc;
      Strength1 := Group.FGroup.GetStrengthMax(dtAll - [dtWall]);
      with Group.FGroup do
        Advantage1 := -GetBattleFieldStrengthAdvantage(Location, FPlayer,
          FIndependentRelation, Group.FGroup, 1, 10, dtAll - [dtWall]);
      Location := FControl.FGroup.GetLoc;
      Strength2 := FControl.FGroup.GetStrengthMax(dtAll - [dtWall]);
      with FControl.FGroup do
        Advantage2 := -GetBattleFieldStrengthAdvantage(Location, FPlayer,
          FIndependentRelation, FControl.FGroup, 1, 10, dtAll - [dtWall]);
      if Strength1 < Strength2 then Strength := Strength1 else Strength := Strength2;
      { Original bug: compares the first advantage with itself. }
      if Advantage1 < Advantage1 then Advantage1 := Advantage1 else Advantage1 := Advantage2;
      if (Strength < Round(Group.FPathStrength * FPathStrengthFactor)) and
        (Strength >= Advantage1) then
      begin
        Moves := Group.FGroup.GetMovePointsMin;
        OtherMoves := FControl.FGroup.GetMovePointsMin; if Moves > OtherMoves then
          Moves := OtherMoves;
        Result := Moves >= Group.FMovePoints;
      end
      else Result := True;
    end
    else Result := True;
  end
  else Result := False;
end;

procedure TAIGroupCooperationControl.ExecuteCooperation;
var
  I, J: Integer;
  Group: TAIGroup;
  Leader: TAbstractUnit;
begin
  for I := FGroups.Count - 1 downto 0 do
  begin
    Group := FGroups.GetRecruitmentGroups(I).FGroup;
    if (Group.FTargetType = gtsSetup) and (FTarget.FMovePoints > Group.FTargetMovePoints) then
      Leader := Group.FLeader
    else Leader := FControl.FGroup.FLeader;
    for J := Group.FProductions.Count - 1 downto 0 do
      Group.FProductions.ChangeGroup(J, FControl.FGroup);
    FControl.FGroup.AddUnits(Group);
    FControl.FGroup.SetLeader(Leader);
  end;
end;

function TAIGroupCooperationControl.Process: Boolean;
var
  I: Integer;
begin
  case FState of
    0:
      begin
        AoWHSMap.FAIExecuter.UseProcessTime(500);
        FControl.FRecruitmentGroups.Validate(FControl);
        I := 0;
        while not FComplete and (I <> FControl.FRecruitmentGroups.Count) do
        begin
          if ValidCooperationGroup(FControl.FRecruitmentGroups.GetRecruitmentGroups(I)) then
            AddCooperationGroup(FControl.FRecruitmentGroups.GetRecruitmentGroups(I));
          Inc(I);
        end;
        if ((FGroups.Count <> 0) and (FMode = ccmAutoCooperate)) or
          ((FMode = ccmCompleteCooperateOnly) and FComplete) then ExecuteCooperation;
        Done;
      end;
  end;
  Result := False;
end;

constructor TAIGroupTargetSelector.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRecruitment := TAIGroupRecruitControl.Create(nil);
  FProduction := TAIGroupProductionControl.Create(nil);
  FCooperation := TAIGroupCooperationControl.Create(nil);
  FPrioritySettings := TAIGroupTargetPrioritySettings.Create;
  FSpareUnits := TUnitUserList.Create(nil);
end;

destructor TAIGroupTargetSelector.Destroy;
begin
  DeactivatePlugin;
  FPrioritySettings.Free;
  FRecruitment.Release;
  FProduction.Release;
  FCooperation.Release;
  FSpareUnits.Free;
  inherited Destroy;
end;

function TAIGroupTargetSelector.GetBusy: Boolean;
begin
  Result := FState <> -1;
end;

function TAIGroupTargetSelector.TargetOverlapFound(Target: TAIGroupControlTarget;
  IgnoreGroup: TAIGroup): Boolean;
var
  Player: TPlayer;
  I: Integer;
  Group: TAIGroup;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(FGroupControl.FGroup.FPlayer);
  I := Player.FAIGroups.Count;
  Result := False;
  while (I <> 0) and not Result do
  begin
    Dec(I);
    Group := Player.FAIGroups.GetGroups(I);
    Result := (Group <> IgnoreGroup) and (Group.FTargetType = gtsExecute) and
      (Target.FLocation.L = Group.FTargetXYL.L) and
      (dHXtoRad(Group.FTargetXYL.X, Group.FTargetXYL.Y, Target.FLocation.X,
        Target.FLocation.Y) <= 1);
  end;
end;

function TAIGroupTargetSelector.ValidateTargetOverlap(Group: TAIGroup;
  Target: TAIGroupControlTarget): Boolean;
var
  I, Moves, Points, OtherDays, Days: Integer;
  Player: TPlayer;
  Other: TAIGroup;
begin
  Player := AoWHSMap.FPlayers.GetPlayers(FGroupControl.FGroup.FPlayer);
  I := Player.FAIGroups.Count;
  Result := True;
  while (I <> 0) and Result do
  begin
    Dec(I);
    Other := Player.FAIGroups.GetGroups(I);
    if (Other <> Group) and (Other.FTargetType = gtsExecute) and
      (Other.FTargetXYL.L = Target.FLocation.L) and
      (dHXtoRad(Other.FTargetXYL.X, Other.FTargetXYL.Y,
        Target.FLocation.X, Target.FLocation.Y) <= 1) then
    begin
      Moves := Other.GetMovesMin;
      Points := Other.FTargetMovePoints;
      if not (agsDone in Other.FStatus) then Dec(Points, Other.GetMovePointsMin);
      OtherDays := Points div Moves;
      if Points mod Moves <> 0 then Inc(OtherDays);
      Moves := Group.GetMovesMin;
      Points := Target.FMovePoints - Group.GetMovePointsMin;
      if Points > 0 then
      begin
        Days := Points div Moves;
        if Points mod Moves <> 0 then Inc(Days);
      end
      else Days := 0;
      Result := Days + 1 <= OtherDays;
    end;
  end;
end;

function TAIGroupTargetSelector.GetValidTargets: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FGroupControl.FTargets.Count - 1 downto 0 do
    if gtsValid in FGroupControl.FTargets.GetTargets(I).FStatus then Inc(Result);
end;

procedure TAIGroupTargetSelector.Reset;
begin
  FState := 0;
  FTargetStatus := tssIdle;
  FSuperiority := 1.5;
  FNearSuperiority := 1.25;
  FMultiTargetFactor := 1.25;
  FMoveDayFactor := 0.1;
  FSpareUnits.Clear;
  FMode := [tsmMultiTargets, tsmCooperate, tsmRecruit, tsmProduce];
  FDamageTypes := dtAll - [dtWall];
  FBattleFieldFactor := 1;
  FCurrentBattleFieldFactor := 0.8;
  FBattleFieldMoveFactor := 0;
  FBattleFieldRadius := 10;
  FValidTargetLimit := 5;
  FPathStrengthFactor := 1;
  FCurrentPathStrengthFactor := 0.8;
  FAllowTransport := False;
  FTargetLimit := 100;
  with FPrioritySettings do
  begin
    FTargetFactor := 1;
    FImmediateBonus := 500;
    FSetupBonus := 25;
    FExecuteBonus := 75;
    FTransportPenalty := -100;
    FPartialRecruitmentPenalty := 0;
    FCompleteRecruitmentPenalty := -50;
    FCompleteCooperationPenalty := -25;
    FPartialCooperationPenalty := -50;
    FMoveDayPenalty := -25;
    FProductionDayPenalty := -25;
    FPartialProductionPenalty := -10;
    FFarOverlapPenalty := -199;
    FNearOverlapPenalty := -50;
  end;
end;

procedure TAIGroupTargetSelector.ActivatePlugin(Plugin: TAIGroupControlPlugin);
begin
  DeactivatePlugin;
  FPlugin := Plugin;
  FPlugin.AddRef;
  FPlugin.Activate(FGroupControl);
end;

procedure TAIGroupTargetSelector.DeactivatePlugin;
begin
  if FPlugin <> nil then
  begin
    FPlugin.Release;
    FPlugin := nil;
  end;
end;

function TAIGroupTargetSelector.GetTargetSetupPriority(Target: TAIGroupControlTarget): Integer;
var
  Group: TAIGroup;
  Days, Priority: Integer;
begin
  Priority := Round(Target.FData.Priority * FPrioritySettings.FTargetFactor);
  Days := (Target.FMovePoints - 1) div FGroupControl.FGroup.GetMovesMin;
  if Days > 0 then Inc(Priority, Round(FPrioritySettings.FMoveDayPenalty * Days));
  if Target.FTransporterID <> -1 then Inc(Priority, FPrioritySettings.FTransportPenalty);
  Group := FGroupControl.FGroup;
  if Integer(Group.FTargetXYL) = Integer(Target.FLocation) then
  begin
    if Group.FTargetType = gtsExecute then Inc(Priority, FPrioritySettings.FExecuteBonus)
    else if Group.FTargetType = gtsSetup then Inc(Priority, FPrioritySettings.FSetupBonus);
  end;
  if TargetOverlapFound(Target, Group) then
    if Target.FMovePoints <= FMovesMin then Inc(Priority, FPrioritySettings.FNearOverlapPenalty)
    else Inc(Priority, FPrioritySettings.FFarOverlapPenalty);
  Result := Priority;
end;

function TAIGroupTargetSelector.Setup(Control: TAIGroupControl): Boolean; { Near miss: signature ends before default case target; three variants differ. }
begin
  Reset;
  case Ord(AoWHSMap.FPlayers.GetPlayers(Control.FGroup.FPlayer).FPlayerType) of
    Ord(ptCPU1): FValidTargetLimit := 5;
    Ord(ptCPU2): FValidTargetLimit := 7;
    Ord(ptCPU3), Ord(ptCPU4), Ord(ptCPU5): FValidTargetLimit := 10;
  else FValidTargetLimit := 5;
  end;
  Result := True;
end;

function CompareTargetSetupPriority(Item1, Item2: Pointer): Integer;
begin
  Result := TAIGroupControlTarget(Item2).FDataA - TAIGroupControlTarget(Item1).FDataA;
end;

function TAIGroupTargetSelector.Activate(Control: TAIGroupControl): Boolean;
var
  Target: TAIGroupControlTarget;
  Valid: Boolean;
  I: Integer;
begin
  FGroupControl := Control;
  FGroupControl.FTargets.Validate;
  FMovesMin := 50;
  for I := FGroupControl.FGroup.Count - 1 downto 0 do
    if FGroupControl.FGroup.GetUnit(I).GetMoves < FMovesMin then
      FMovesMin := FGroupControl.FGroup.GetUnit(I).GetMoves;
  for I := FGroupControl.FTargets.Count - 1 downto 0 do
  begin
    Target := FGroupControl.FTargets.GetTargets(I);
    Valid := ValidateTargetOverlap(FGroupControl.FGroup, Target); Valid := Valid and
      ((Target.FData.TargetType <> attNegotiate) or
        FGroupControl.FGroup.RequestTargetExpense(Target.GetTargetGold, Target.GetTargetMana));
    Valid := Valid and ((Target.GetTargetGold <= 0) or
      (AoWHSMap.FPlayers.GetPlayers(FGroupControl.FGroup.FPlayer).FGems >= Target.GetTargetGold));
    Valid := Valid and ((Target.GetTargetMana <= 0) or
      (AoWHSMap.FPlayers.GetPlayers(FGroupControl.FGroup.FPlayer).FMagicControl.FMana >= Target.GetTargetMana));
    if Valid then
    begin
      Target.FDataA := GetTargetSetupPriority(FGroupControl.FTargets.GetTargets(I));
      Target.FStatus := [];
    end
    else Target.FStatus := [gtsDone];
  end;
  FGroupControl.FTargets.FChildren.Sort(CompareTargetSetupPriority);
  for I := FGroupControl.FTargets.Count - 1 downto FTargetLimit + 1 do
    FGroupControl.FTargets.Delete(I);
  FTarget := nil;
  FTargetStatus := tssBusy;
  Result := True;
end;

procedure TAIGroupTargetSelector.TargetProcessed;
begin
  FTarget.FDataA := FPriority;
  FTarget.FStatus := FTarget.FStatus + [gtsDone];
  FTarget := nil;
  FState := 0;
end;

function TAIGroupTargetSelector.GetRequiredSuperiority(Target: TAIGroupControlTarget): Single;
var
  Days: Integer;
begin
  if Target.FData.TargetType <> attNegotiate then
  begin
    with FGroupControl.FGroup do
      if ((Integer(FTargetXYL) = Integer(Target.FLocation)) and (FTargetType = gtsExecute)) or
        (GetMovesMin >= Target.FMovePoints) then Result := FNearSuperiority
      else Result := FSuperiority;
    if FGroupControl.FGroup.GetMovesMin > 0 then
    begin
      Days := (Target.FMovePoints - 1) div FGroupControl.FGroup.GetMovesMin;
      Result := Result + Round(Days * FMoveDayFactor);
    end;
  end
  else Result := 0;
end;

function TAIGroupTargetSelector.GetRequiredCombatPredictorSuperiority(Target: TAIGroupControlTarget): Integer;
begin
  Result := Round(GetRequiredSuperiority(Target) * 100);
end;

function TAIGroupTargetSelector.GetRequiredTargetStrength(Target: TAIGroupControlTarget): Integer;
var
  Strengths: TDefenseRequirements;
  Info: TBattleFieldInfo;
begin
  if Target.FData.TargetType <> attNegotiate then
  begin
    SetupBattleFieldInfo(Info, FGroupControl.FGroup.FPlayer,
      FGroupControl.FGroup.FIndependentRelation, [], FDamageTypes);
    Info.FriendlyRelations := [];
    AoWHSMap.RetrieveBattleFieldInfo(Target.FLocation.X, Target.FLocation.Y,
      Target.FLocation.L, 1, Info);
    Result := Round(GetRequiredSuperiority(Target) * Info.Strength);
    TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(Target.FLocation))).
      GetDefenseRequirements(FGroupControl.FGroup.FPlayer, Strengths);
    Inc(Result, StrengthInfoMax(Strengths) div 2);
  end
  else Result := 0;
end;

function TAIGroupTargetSelector.GetRequiredBattleFieldSuperiority(Target: TAIGroupControlTarget): Single;
begin
  if (Integer(Target.FLocation) = Integer(FGroupControl.FGroup.FTargetXYL)) and
    (FGroupControl.FGroup.FTargetType = gtsExecute) then Result := FCurrentBattleFieldFactor
  else Result := FBattleFieldFactor;
  Result := Result + Round(Target.FMovePoints * FBattleFieldMoveFactor);
end;

function TAIGroupTargetSelector.GetRequiredBattleFieldStrength(Target: TAIGroupControlTarget): Integer;
var
  Info: TBattleFieldInfo;
  PathStrength: Integer;
begin
  if ((FBattleFieldFactor > 0) or (FCurrentBattleFieldFactor > 0)) and
    (Target.FData.TargetType <> attNegotiate) then
  begin
    SetupBattleFieldInfo(Info, FGroupControl.FGroup.FPlayer,
      FGroupControl.FGroup.FIndependentRelation, [], FDamageTypes);
    Info.Units := FGroupControl.FGroup;
    Info.Requests := Info.Requests + [bfrIgnorePassiveIndependents];
    AoWHSMap.RetrieveBattleFieldInfo(Target.FLocation.X, Target.FLocation.Y,
      Target.FLocation.L, FBattleFieldRadius, Info);
    Result := Round(GetRequiredBattleFieldSuperiority(Target) * (Info.Strength - Info.FriendlyStrength));
  end
  else Result := 0;
  with FGroupControl.FGroup do
    if (Integer(FTargetXYL) = Integer(Target.FLocation)) and (FTargetType = gtsExecute) then
      PathStrength := Round(Target.FPathStrength * FCurrentPathStrengthFactor)
    else PathStrength := Round(Target.FPathStrength * FPathStrengthFactor);
  if Result < PathStrength then Result := PathStrength;
end;

function TAIGroupTargetSelector.GetRequiredStrength(Target: TAIGroupControlTarget): Integer;
var
  BattleFieldStrength: Integer;
begin
  Result := GetRequiredTargetStrength(Target);
  BattleFieldStrength := GetRequiredBattleFieldStrength(Target);
  if BattleFieldStrength > Result then Result := BattleFieldStrength;
  AoWHSMap.FAIExecuter.UseProcessTime(250);
end;

function TAIGroupTargetSelector.ValidateTargetRequirements(Units: TUnitList;
  Target: TAIGroupControlTarget; Required, Optional: TUnitList;
  MinimumStrength: Integer): Boolean;
var
  Strength: Integer;
  Predictor: TCombatPredictor;
  RequiredUnits, OptionalUnits: TUnitUserList;
  I, Superiority: Integer;
  AUnit: TAbstractUnit;
begin
  Predictor := TCombatPredictor.Create;
  RequiredUnits := TUnitUserList.Create(nil);
  OptionalUnits := TUnitUserList.Create(nil);
  Predictor.AddUnits(Units);
  if TAoWMapField(AoWHSMap.MapContainer.GetFieldXYL(Integer(Target.FLocation))).
    GetMoveAction(FGroupControl.FGroup.FPlayer) <> maNegotiate then
    Predictor.InitAdjacentOpponents(FGroupControl.FGroup.FPlayer,
      FGroupControl.FGroup.FIndependentRelation, Target.FLocation.X,
      Target.FLocation.Y, Target.FLocation.L);
  Superiority := GetRequiredCombatPredictorSuperiority(Target);
  Predictor.Execute;
  Result := Predictor.GetSuperiority > Superiority;
  Predictor.ListRequiredUnits(RequiredUnits, Superiority);
  if RequiredUnits.Count <> Units.Count then
    for I := Units.Count - 1 downto 0 do
      if RequiredUnits.IndexOf(Units.GetUnit(I)) = -1 then OptionalUnits.AddUnit(Units.GetUnit(I));
  if (OptionalUnits.Count <> 0) or Result then
  begin
    Strength := GetRequiredStrength(Target);
    if Strength < MinimumStrength then Strength := MinimumStrength;
    Dec(Strength, RequiredUnits.GetStrengthMax(FDamageTypes));
    while (Strength > 0) and (OptionalUnits.Count <> 0) do
    begin
      AUnit := OptionalUnits.GetUnit(OptionalUnits.Count - 1);
      Dec(Strength, AUnit.GetStrengthMax(FDamageTypes));
      RequiredUnits.AddUnit(AUnit);
      OptionalUnits.DeleteUnit(AUnit);
    end;
    Result := Result and (Strength <= 0);
  end;
  if Required <> nil then Required.AddUnits(RequiredUnits);
  if Optional <> nil then Optional.AddUnits(OptionalUnits);
  OptionalUnits.Free;
  RequiredUnits.Free;
  Predictor.Free;
end;

function TAIGroupTargetSelector.ValidMultiTarget(Units: TUnitList;
  Target: TAIGroupControlTarget; Required, Optional: TUnitList): Boolean;
begin
  if not TargetOverlapFound(FNextTarget, nil) and
    ((FTarget.FLocation.L <> Target.FLocation.L) or
      (dHXtoRad(FTarget.FLocation.X, FTarget.FLocation.Y,
        Target.FLocation.X, Target.FLocation.Y) > 1)) then
  begin
    Result := ValidateTargetRequirements(FSpareUnits, FNextTarget, Required, Optional, FMinimumStrength);
    Result := Result and FGroupControl.FGroup.RequestTargetExpense(
      FTarget.GetTargetGold + Target.GetTargetGold, FTarget.GetTargetMana + Target.GetTargetMana);
  end
  else Result := False;
end;

procedure TAIGroupTargetSelector.Validate;
var
  I: Integer;
  AUnit: TAbstractUnit;
begin
  for I := FSpareUnits.Count - 1 downto 0 do
  begin
    AUnit := FSpareUnits.GetUnit(I);
    if FGroupControl.FGroup.IndexOf(AUnit) = -1 then FSpareUnits.DeleteUnit(AUnit);
  end;
  FGroupControl.FTargets.Validate;
  if (FState <> 21) and (FTarget <> nil) then
    if FGroupControl.FTargets.FChildren.IndexOf(FTarget) = -1 then
    begin
      FTarget := nil;
      if (FState > 0) and (FState < 10) then FState := 0;
      if FState > 10 then FState := 10;
    end;
end;

procedure TAIGroupTargetSelector.ShowTargetInfo;
var
  Text: string;
  I: Integer;
  Target: TAIGroupControlTarget;
begin
  AoWEngine.OutputDebugMessage(AIDID,
    'Targets for Group (ID:' + IntToStr(FGroupControl.FGroup.FGroupID) + ')');
  for I := 0 to FGroupControl.FTargets.Count - 1 do
  begin
    Target := FGroupControl.FTargets.GetTargets(I);
    Target.GetDebugInfo(Text);
    Text := Text + '/TS_Prio:' + IntToStr(Target.FDataA);
    Text := Text + '/MPBFS:' + IntToStr(Target.FPathStrength);
    Text := Text + '/TG:' + IntToStr(Target.GetTargetGold);
    Text := Text + '/MP:' + IntToStr(Target.FMovePoints);
    Text := Text + '/Status:';
    if gtsCooperate in Target.FStatus then Text := Text + 'c';
    if gtsRecruit in Target.FStatus then Text := Text + 'r';
    if gtsProduce in Target.FStatus then Text := Text + 'p';
    if gtsValid in Target.FStatus then Text := Text + 'v';
    if gtsDone in Target.FStatus then Text := Text + 'd';
    AoWEngine.OutputDebugMessage(AIDID, Text);
  end;
end;

procedure TAIGroupTargetSelector.NoTargetsFound;
begin
  FTargetStatus := tssNoTargetsFound;
  FGroupControl.FGroup.FTargetXYL.XYL := -1;
  FGroupControl.FGroup.FTargetType := gtsNone;
  if FGroupControl.FGroup.FTransporter <> nil then
    FGroupControl.FGroup.DeleteUnit(FGroupControl.FGroup.FTransporter);
end;

function TAIGroupTargetSelector.AllowMultiTargets(Target: TAIGroupControlTarget): Boolean;
begin
  Result := tsmMultiTargets in FMode;
  Result := Result and (Target.FStatus * [gtsRecruit, gtsProduce] = []);
  Result := Result and
    (FGroupControl.FStrengthMax >= GetRequiredStrength(Target) * FMultiTargetFactor);
  Result := Result and (FGroupControl.FStrengthMax >= FMinimumStrength);
  Result := Result and ((Target.FData.TargetType <> attNegotiate) or
    (Target.FMovePoints >= FGroupControl.FGroup.GetMovePointsMin));
end;

function TAIGroupTargetSelector.Process: Boolean; { Near miss: result register and truncated case-table extent differ after three variants. }
var
  I, Strength, Superiority, Time: Integer;
  Busy: Boolean;
  Plugin: TAIGroupControlPlugin;
  Optional, Required: TUnitUserList;
  Group: TAIGroup;
  Location: TXYL;
begin
  Plugin := FPlugin;
  if Plugin <> nil then
  begin
    Busy := Plugin.MainProcess;
    if not Busy then DeactivatePlugin;
  end
  else Busy := False;
  if not Busy then
  begin
    Result := False;
    case FState of
      0:
        begin
          I := 0;
          while (I <> FGroupControl.FTargets.Count) and
            (gtsDone in FGroupControl.FTargets.GetTargets(I).FStatus) do Inc(I);
          if (I < FGroupControl.FTargets.Count) and
            (GetValidTargets < FValidTargetLimit) then
          begin
            FTarget := FGroupControl.FTargets.GetTargets(I);
            FPriority := FTarget.FDataA;
            Strength := GetRequiredStrength(FTarget);
            Superiority := GetRequiredCombatPredictorSuperiority(FTarget);
            AoWHSMap.FAIExecuter.UseProcessTime(100);
            Busy := FGroupControl.FStrengthMax < Strength;
            if not Busy then
            begin
              FGroupControl.SetupCP(FTarget);
              FGroupControl.FCombatPredictor.Execute;
              Busy := Busy or
                (FGroupControl.FCombatPredictor.FResult in [2, 4, 8]);
              Busy := Busy or
                (FGroupControl.FCombatPredictor.GetSuperiority < Superiority);
            end;
            if Busy then
            begin
              if FMode * [tsmCooperate, tsmRecruit, tsmProduce] <> [] then
              begin
                FGroupControl.SetupCP(FTarget);
                if tsmCooperate in FMode then
                begin
                  FCooperation.Setup(FGroupControl, FTarget);
                  FCooperation.FSuperiority := Superiority;
                  FCooperation.FCooperateStrength := Strength - FGroupControl.FStrengthMax;
                  FCooperation.FMode := ccmNone;
                  ActivatePlugin(FCooperation);
                  FState := 1;
                end
                else if tsmRecruit in FMode then FState := 2
                else if tsmProduce in FMode then FState := 4
                else TargetProcessed;
              end
              else TargetProcessed;
            end
            else
            begin
              FTarget.FStatus := FTarget.FStatus + [gtsValid];
              if FTarget.FMovePoints < FGroupControl.FGroup.GetMovePointsMin then
                Inc(FPriority, FPrioritySettings.FImmediateBonus);
              TargetProcessed;
            end;
          end
          else
          begin
            FGroupControl.FTargets.FChildren.Sort(CompareTargetSetupPriority);
            FState := 10;
          end;
        end;
      1:
        if FCooperation.FComplete then
        begin
          FTarget.FStatus := FTarget.FStatus + [gtsValid, gtsCooperate];
          Inc(FPriority, FPrioritySettings.FCompleteCooperationPenalty);
          if (FCooperation.GetCooperateMoveDays = 0) and
            (FTarget.FMovePoints < FGroupControl.FGroup.GetMovePointsMin) then
            Inc(FPriority, FPrioritySettings.FImmediateBonus);
          TargetProcessed;
        end
        else
        begin
          if FCooperation.FGroups.Count <> 0 then
          begin
            FTarget.FStatus := FTarget.FStatus + [gtsValid, gtsCooperate];
            Inc(FPriority, FPrioritySettings.FPartialCooperationPenalty);
          end;
          if tsmRecruit in FMode then FState := 2
          else if tsmProduce in FMode then FState := 4
          else TargetProcessed;
        end;
      2:
        begin
          FRecruitment.Setup(FGroupControl);
          FRecruitment.FSuperiority := GetRequiredCombatPredictorSuperiority(FTarget);
          FRecruitment.FRecruitStrength := GetRequiredStrength(FTarget) - FGroupControl.FStrengthMax;
          if gtsCooperate in FTarget.FStatus then
            Dec(FRecruitment.FRecruitStrength, FCooperation.GetCooperatedStrength);
          FRecruitment.FMode := rcmNone;
          ActivatePlugin(FRecruitment);
          FState := 3;
        end;
      3:
        if FRecruitment.FComplete then
        begin
          FTarget.FStatus := FTarget.FStatus + [gtsValid, gtsRecruit];
          Inc(FPriority, FPrioritySettings.FCompleteRecruitmentPenalty);
          TargetProcessed;
        end
        else
        begin
          if FRecruitment.FUnits.Count <> 0 then
          begin
            FTarget.FStatus := FTarget.FStatus + [gtsRecruit];
            Inc(FPriority, FPrioritySettings.FPartialRecruitmentPenalty);
          end;
          if tsmProduce in FMode then FState := 4 else TargetProcessed;
        end;
      4:
        begin
          FProduction.Setup(FGroupControl);
          FProduction.FSuperiority := GetRequiredCombatPredictorSuperiority(FTarget);
          FProduction.FProduceStrength := GetRequiredStrength(FTarget) - FGroupControl.FStrengthMax;
          if gtsCooperate in FTarget.FStatus then
            Dec(FProduction.FProduceStrength, FCooperation.GetCooperatedStrength);
          if gtsRecruit in FTarget.FStatus then
            Dec(FProduction.FProduceStrength, FRecruitment.GetRecruitedStrength);
          FProduction.FMode := pcmNone;
          ActivatePlugin(FProduction);
          FState := 5;
        end;
      5:
        begin
          if FProduction.FComplete then
          begin
            FTarget.FStatus := FTarget.FStatus + [gtsValid, gtsProduce];
            Time := FProduction.GetCompleteProductionTime;
            if Time > 0 then Inc(FPriority, Round(FPrioritySettings.FProductionDayPenalty * Time));
          end
          else if FProduction.FProductions.Count <> 0 then
          begin
            FTarget.FStatus := FTarget.FStatus + [gtsValid, gtsProduce];
            Inc(FPriority, FPrioritySettings.FPartialProductionPenalty);
            Time := FProduction.GetCompleteProductionTime;
            if Time > 0 then Inc(FPriority, FPrioritySettings.FProductionDayPenalty * Time);
          end;
          TargetProcessed;
        end;
      10:
        begin
          I := 0;
          while (I <> FGroupControl.FTargets.Count) and
            not (gtsValid in FGroupControl.FTargets.GetTargets(I).FStatus) do Inc(I);
          if I = FGroupControl.FTargets.Count then
          begin
            NoTargetsFound;
            Done;
          end
          else
          begin
            FTarget := FGroupControl.FTargets.GetTargets(I);
            if FTarget.FStatus * [gtsRecruit, gtsProduce, gtsCooperate] <> [] then
            begin
              FGroupControl.SetupCP(FTarget);
              if gtsCooperate in FTarget.FStatus then
              begin
                FCooperation.Setup(FGroupControl, FTarget);
                FCooperation.FSuperiority := GetRequiredCombatPredictorSuperiority(FTarget);
                FCooperation.FCooperateStrength := GetRequiredStrength(FTarget) - FGroupControl.FStrengthMax;
                FCooperation.FMode := ccmAutoCooperate;
                ActivatePlugin(FCooperation);
                FState := 11;
              end
              else if gtsRecruit in FTarget.FStatus then FState := 12
              else if gtsProduce in FTarget.FStatus then FState := 14
              else FState := 20;
            end
            else
            begin
              FTarget.FStatus := FTarget.FStatus + [gtsReady];
              FState := 20;
            end;
          end;
        end;
      11:
        if FCooperation.FComplete then
        begin
          FTarget.FStatus := FTarget.FStatus + [gtsReady];
          FState := 20;
        end
        else
          if gtsRecruit in FTarget.FStatus then FState := 12
          else if gtsProduce in FTarget.FStatus then FState := 14
          else FState := 20;
      12:
        begin
          FRecruitment.Setup(FGroupControl);
          FRecruitment.FSuperiority := GetRequiredCombatPredictorSuperiority(FTarget);
          FRecruitment.FRecruitStrength := GetRequiredStrength(FTarget) - FGroupControl.FStrengthMax;
          FRecruitment.FMode := rcmAutoRecruit;
          ActivatePlugin(FRecruitment);
          Inc(FState);
        end;
      13:
        if FRecruitment.FComplete then
        begin
          FTarget.FStatus := FTarget.FStatus + [gtsReady];
          FState := 20;
        end
        else if gtsProduce in FTarget.FStatus then FState := 14
        else FState := 20;
      14:
        begin
          FProduction.Setup(FGroupControl);
          FProduction.FSuperiority := GetRequiredCombatPredictorSuperiority(FTarget);
          FProduction.FProduceStrength := GetRequiredStrength(FTarget) - FGroupControl.FStrengthMax;
          FProduction.FMode := pcmAutoProduce;
          ActivatePlugin(FProduction);
          FState := 20;
        end;
      20:
        if gtsReady in FTarget.FStatus then
        begin
          if FTarget.FTransporterID <> -1 then
            FGroupControl.FGroup.AddTransporter(AoWHSMap.FUnitControl.FindUnit(FTarget.FTransporterID))
          else
            with FGroupControl.FGroup do
              if FTransporter <> nil then DeleteUnit(FTransporter);
          if AllowMultiTargets(FTarget) then FState := 30
          else
          begin
            FGroupControl.FGroup.SetupTarget(FTarget, gtsExecute, 0);
            FGroupControl.SetupME;
            FGroupControl.ExecuteME(FTarget.FLocation.X, FTarget.FLocation.Y, FTarget.FLocation.L);
            Result := True;
            FState := 21;
          end;
        end
        else if FGroupControl.FGroup.FProductions.Count <> 0 then
        begin
          FGroupControl.FGroup.FProductions.GetProductions(0).FControl.GetLocation(
            Location.X, Location.Y, Location.L);
          FGroupControl.SetupME;
          FGroupControl.ExecuteME(Location.X, Location.Y, Location.L);
          Result := True;
          FState := 22;
        end
        else
        begin
          FGroupControl.FProductionLocations.SortOnMovePoints;
          if (FGroupControl.FProductionLocations.Count = 0) or
            (FGroupControl.FProductionLocations.GetProductionLocation(0).FMovePoints > 31) then
          begin
            FGroupControl.SetupME;
            FGroupControl.ExecuteME(FGroupControl.FLocation.X,
              FGroupControl.FLocation.Y, FGroupControl.FLocation.L);
            Result := True;
            FState := 22;
          end
          else
          begin
            FGroupControl.SetupME;
            FGroupControl.ExecuteME(
              FGroupControl.FProductionLocations.GetProductionLocation(0).FLocation.X,
              FGroupControl.FProductionLocations.GetProductionLocation(0).FLocation.Y,
              FGroupControl.FProductionLocations.GetProductionLocation(0).FLocation.L);
            Result := True;
            FState := 22;
          end;
        end;
      21:
        begin
          if FGroupControl.FTargets.FChildren.IndexOf(FTarget) = -1 then
          begin
            FGroupControl.FGroup.ResetTargetExpense;
            FTargetStatus := tssTargetConquered;
            Done;
          end
          else
          begin
            FTargetStatus := tssExecutingTarget;
            Done;
          end;
        end;
      22:
        begin
          FGroupControl.FGroup.SetupTarget(FTarget, gtsSetup, 0);
          FTargetStatus := tssSettingupTarget;
          Done;
        end;
      30:
        begin
          ValidateTargetRequirements(FGroupControl.FGroup, FTarget, nil, FSpareUnits, FMinimumStrength);
          if FSpareUnits.Count <> 0 then
          begin
            FTarget.FStatus := FTarget.FStatus - [gtsValid];
            FNextTarget := nil;
            FState := 31;
          end
          else FState := 32;
        end;
      31:
        begin
          I := FGroupControl.FTargets.FChildren.IndexOf(FNextTarget);
          while (I < FGroupControl.FTargets.Count) and
            ((I = -1) or (FGroupControl.FTargets.GetTargets(I).FTransporterID <> -1) or
              not (gtsValid in FGroupControl.FTargets.GetTargets(I).FStatus)) do Inc(I);
          if I < FGroupControl.FTargets.Count then
          begin
            Required := TUnitUserList.Create(nil);
            Optional := TUnitUserList.Create(nil);
            FNextTarget := FGroupControl.FTargets.GetTargets(I);
            if ValidMultiTarget(FSpareUnits, FNextTarget, Required, Optional) then
            begin
              with FGroupControl.FGroup do
                Group := AoWHSMap.FAIGroupManager.CreateGroup(FPlayer, FIndependentRelation, Behavior);
              Group.AddUnits(Required);
              Group.SetupTarget(FNextTarget, gtsExecute, 0);
              Group.Release;
              FSpareUnits.Clear;
              FSpareUnits.AddUnits(Optional);
              if FSpareUnits.Count = 0 then FState := 32;
            end;
            FNextTarget.FStatus := FNextTarget.FStatus - [gtsValid];
            Optional.Free;
            Required.Free;
          end
          else FState := 32;
        end;
      32:
        begin
          FGroupControl.FGroup.SetupTarget(FTarget, gtsExecute, 0);
          FGroupControl.SetupME;
          FGroupControl.ExecuteME(FTarget.FLocation.X, FTarget.FLocation.Y, FTarget.FLocation.L);
          FState := 21;
          Result := True;
        end;
      40:
        begin
          NoTargetsFound;
          Done;
        end;
    end;
  end
  else Result := True;
end;

constructor TAIMoveControlSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTransportPath := TMovepath.Create;
  FRefCount := 1;
  Clear;
end;

destructor TAIMoveControlSettings.Destroy;
begin
  FTransportPath.Free;
  inherited Destroy;
end;

procedure TAIMoveControlSettings.Clear;
begin
  inherited Clear;
  FMovePointsMax := 175;
  FQuickMovePointsMax := 300;
  FBoardingPoint.X := -1;
  FArrivalPoint.X := -1;
  FTransportSource.X := -1;
  { Original bug: clears the destination Y coordinate instead of X. }
  FTransportDestination.Y := -1;
  FMovePoints := -1;
  FTransportPath.Clear;
  FDestinationX := -1;
  FDestinationY := -1;
  FDestinationL := -1;
  FSelection := 0;
  FProcessCycles := 0;
end;

function TAIMoveControlSettings.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TAIMoveControlSettings.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

procedure TAIMoveControlSettings.SetSourcePos(X, Y, L: Integer);
begin
  FSourceX := X;
  FSourceY := Y;
  FSourceL := L;
end;

procedure TAIMoveControlSettings.SetDestinationPos(X, Y, L: Integer);
begin
  FDestinationX := X;
  FDestinationY := Y;
  FDestinationL := L;
end;

procedure TAIMoveControlSettings.Setup(Army: TArmyHS; Selection: Byte; X, Y, L: Integer);
begin
  SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  SetDestinationPos(X, Y, L);
  FArmyHS := Army;
  FSelection := Selection;
  FPlayer := Army.FArmy.FPlayer;
  Army.FArmy.CreateMovePointTable(Selection, FMovePointTable);
end;

constructor TAIMoveControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPathSettings := TMoveControlSettings.Create(nil);
  Clear;
end;

destructor TAIMoveControl.Destroy;
begin
  Clear;
  FPathSettings.Release;
  inherited Destroy;
end;

procedure TAIMoveControl.Clear;
var
  Settings: TAIMoveControlSettings;
begin
  Settings := FSettings;
  if Settings <> nil then
  begin
    Settings.Release;
    FSettings := nil;
  end;
  FStatus := amsIdle;
  FProcessCycles := 0;
  FPathSettings.Reset;
  FPathSettings.FMode := FPathSettings.FMode + [mmAI];
end;

procedure TAIMoveControl.ProcessingDone(Status: TAIMoveControlStatus);
begin
  if FSettings <> nil then
  begin
    FStatus := Status;
    FSettings.FStatus := Status;
    if Assigned(FSettings.FOnDone) then FSettings.FOnDone(Self);
  end;
end;

procedure TAIMoveControl.ProcessCanMove;
var
  Points: Integer;
begin
  case FState of
    0:
      begin
        FPathSettings.FMovePointsMax := FSettings.FQuickMovePointsMax;
        Points := AoWHSMap.FMoveControl.CanMove(FPathSettings, [mmFast]);
        FSettings.FMovePoints := Points;
        if Points <> -1 then ProcessingDone(amsDone)
        else
        begin
          Inc(FState);
          if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 6 then ProcessCanMove;
        end;
      end;
    1:
      begin
        FPathSettings.FMovePointsMax := FSettings.FMovePointsMax;
        FSettings.FMovePoints := AoWHSMap.FMoveControl.CanMove(FPathSettings, [mmExact]);
        FSettings.FTransportPath.Assign(FPathSettings.FPath);
        ProcessingDone(amsDone);
      end;
  end;
end;

procedure TAIMoveControl.SelectCombinedTransporterArmyMpT; { Near miss: table-load temporary differs after three variants. }
var
  Terrain, Overlay: Integer;
  Points: Shortint;
begin
  for Terrain := 0 to 15 do
    for Overlay := -1 to 11 do
    begin
      Points := FMovePointTable[Terrain, Overlay];
      if Points = -1 then
        if FTransportMovePointTable[Terrain, Overlay] <> -1 then Points := 8;
      FPathSettings.FMovePointTable[Terrain, Overlay] := Points;
    end;
end;

function TAIMoveControl.CalculateTransportGaps(Path: TMovepath;
  const Table: TMovePointTable): Boolean;
var
  I, FirstGap, LastGap, Gaps: Integer;
  InGap: Boolean;
  MapF: TAoWMapField;
begin
  Gaps := 0;
  FirstGap := -1;
  LastGap := -1;
  I := Path.Count - 1;
  InGap := False;
  while I > 1 do
  begin
    Dec(I);
    MapF := TAoWMapField(AoWHSMap.MapContainer.GetField(Path[I].X, Path[I].Y, Path[I].L));
    if Table[MapF.TerrainType, MapF.OverlayType] = -1 then
    begin
      if not InGap then
      begin
        if FirstGap = -1 then FirstGap := I;
        Inc(Gaps);
        InGap := True;
      end;
    end
    else if InGap then
    begin
      LastGap := I + 1;
      InGap := False;
    end;
  end;
  if InGap then LastGap := 1;
  if Gaps <> 0 then
  begin
    FSettings.FBoardingPoint := Path[FirstGap + 1];
    FSettings.FTransportSource := Path[FirstGap];
    FSettings.FArrivalPoint := Path[LastGap - 1];
    FSettings.FTransportDestination := Path[LastGap];
    Result := True;
    FMultipleTransportGaps := Gaps > 1;
  end
  else Result := False;
end;

procedure TAIMoveControl.ProcessTransporterCanMove; { Review fix: run virtual ProcessMove, not Activate; settings registers still differ. }
var
  Points: Integer;
  Location: TXYL;
begin
  case FState of
    0:
      begin
        FPathSettings.FMovePointTable := FMovePointTable;
        FPathSettings.FMovePointsMax := FSettings.FQuickMovePointsMax;
        Points := AoWHSMap.FMoveControl.CanMove(FPathSettings, [mmFast]);
        FSettings.FMovePoints := Points;
        if Points = -1 then
        begin
          Inc(FState);
          if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 6 then ProcessTransporterCanMove;
        end
        else ProcessingDone(amsDone);
      end;
    1:
      begin
        SelectCombinedTransporterArmyMpT;
        FPathSettings.FMovePointsMax := FSettings.FMovePointsMax;
        FPathSettings.FMode := FSettings.FMoveMode + [mmAvoidArmies];
        AoWHSMap.FMoveControl.ProcessMove(FPathSettings);
        if FPathSettings.FPath.Count <> 0 then
        begin
          FSettings.FMovePoints := FPathSettings.GetMovePoints(
            FPathSettings.FPath[0].X, FPathSettings.FPath[0].Y, FPathSettings.FPath[0].L);
          FSettings.FTransportPath.Assign(FPathSettings.FPath);
          if CalculateTransportGaps(FPathSettings.FPath, FMovePointTable) then
          begin
            FState := 2;
            FPathSettings.FMovePointTable := FTransportMovePointTable;
            FSettings.FTransporter.GetLocation(Location.X, Location.Y, Location.L);
            FPathSettings.SetSourcePos(Location.X, Location.Y, Location.L);
            with FSettings.FTransportSource do FPathSettings.SetDestinationPos(X, Y, L);
            if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 1 then ProcessTransporterCanMove;
          end
          else ProcessingDone(amsDone);
        end
        else ProcessingDone(amsDone);
      end;
    2:
      begin
        FPathSettings.FMovePointsMax := FSettings.FQuickMovePointsMax;
        Points := AoWHSMap.FMoveControl.CanMove(FPathSettings, [mmFast]);
        if Points = -1 then
        begin
          FState := 3;
          if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 6 then ProcessTransporterCanMove;
        end
        else
        begin
          Inc(FSettings.FMovePoints, Points);
          if FMultipleTransportGaps then
          begin
            { Original repeats the first gap source before continuing. }
            with FSettings.FTransportSource do FPathSettings.SetDestinationPos(X, Y, L);
            FMultipleTransportGaps := False;
            if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 1 then ProcessTransporterCanMove;
          end
          else ProcessingDone(amsDone);
        end;
      end;
    3:
      begin
        FPathSettings.FMovePointTable := FTransportMovePointTable;
        FPathSettings.FMovePointsMax := FSettings.FMovePointsMax;
        Points := AoWHSMap.FMoveControl.CanMove(FPathSettings, [mmExact]);
        if Points = -1 then
        begin
          FSettings.FMovePoints := -1;
          ProcessingDone(amsDone);
        end
        else
        begin
          Inc(FSettings.FMovePoints, Points);
          if FMultipleTransportGaps then
          begin
            with FSettings.FTransportDestination do FPathSettings.SetDestinationPos(X, Y, L);
            FMultipleTransportGaps := False;
            FState := 2;
            if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 1 then ProcessTransporterCanMove;
          end
          else ProcessingDone(amsDone);
        end;
      end;
  end;
end;

procedure TAIMoveControl.Initialize(Settings: TAIMoveControlSettings);
var
  OldSettings: TAIMoveControlSettings;
  Transporter: TAbstractUnit;
begin
  OldSettings := FSettings;
  if OldSettings <> nil then OldSettings.Release;
  FSettings := Settings;
  if FSettings <> nil then
  begin
    FSettings.AddRef;
    FSettings.FMovePoints := -1;
    FSettings.FTransportSource.X := -1;
    FSettings.FTransportDestination.X := -1;
    FSettings.FBoardingPoint.X := -1;
    FSettings.FArrivalPoint.X := -1;
    FSettings.FStatus := amsProcessing;
    FMovePointTable := FSettings.FMovePointTable;
    Transporter := FSettings.FTransporter;
    if Transporter <> nil then
      FTransportMovePointTable := MovePointTables[MoveTypesToInt(Transporter.GetMoveTypes)];
  end;
end;

function TAIMoveControl.CanMove(Settings: TAIMoveControlSettings): Boolean;
begin
  Reset;
  Initialize(Settings);
  FStatus := amsProcessing;
  FPathSettings.Reset;
  with FSettings do FPathSettings.SetSourcePos(FSourceX, FSourceY, FSourceL);
  FPathSettings.FPlayer := FSettings.FPlayer;
  FPathSettings.SetDestinationPos(FSettings.FDestinationX, FSettings.FDestinationY, FSettings.FDestinationL);
  FPathSettings.FMovePointsMax := FSettings.FMovePointsMax;
  FPathSettings.FArmyHS := FSettings.FArmyHS;
  FPathSettings.FSelection := FSettings.FSelection;
  FPathSettings.FMode := FSettings.FMoveMode;
  if FSettings.FTransporter = nil then
  begin
    FMode := mcsCanMove;
    FPathSettings.FMovePointTable := FMovePointTable;
    if FSettings.FSourceL = FSettings.FDestinationL then
    begin
      FState := 0;
      if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 1 then ProcessCanMove;
    end
    else FState := 1;
    Result := True;
  end
  else
  begin
    FMode := mcsTransporterCanMove;
    FPathSettings.FTransporterArmy := TArmy(FSettings.FTransporter.FOwner).GetArmyHS;
    if FSettings.FSourceL = FSettings.FDestinationL then
    begin
      FState := 0;
      if AoWHSMap.FAIExecuter.GetProcessTimeLeft > 1 then ProcessTransporterCanMove;
    end
    else FState := 1;
    Result := True;
  end;
end;

procedure TAIMoveControl.Cancel;
begin
  if FStatus = amsProcessing then ProcessingDone(amsCanceled);
end;

procedure TAIMoveControl.Reset;
begin
  Cancel;
  Clear;
end;

function TAIMoveControl.Process: Boolean;
begin
  if FStatus = amsProcessing then
  begin
    Inc(FProcessCycles);
    case FMode of
      mcsCanMove: ProcessCanMove;
      mcsTransporterCanMove: ProcessTransporterCanMove;
    end;
  end;
  Result := FStatus = amsProcessing;
end;

constructor TMoveTarget.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
end;

destructor TMoveTarget.Destroy;
begin
  if FMovepath <> nil then FMovepath.Free;
  inherited Destroy;
end;

function TMoveTarget.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TMoveTarget.Release: Integer; { Near miss: result register differs after three variants. }
begin
  Dec(FRefCount);
  Result := FRefCount;
  if Result = 0 then Destroy;
end;

function TMoveTargetList.GetTarget(Index: Integer): TMoveTarget;
begin
  Result := TMoveTarget(FChildren.List^[Index]);
end;

function TMoveTargetList.IndexOfXYL(Location: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Integer(TMoveTarget(FChildren.List^[Result]).FLocation) = Location then Exit;
  end;
  Result := -1;
end;

procedure TMoveTargetList.AddTargetEx(Location: Integer; MovePoints,
  TransporterID: Integer; const Data: TAITargetData);
var
  Target: TMoveTarget;
begin
  Target := TMoveTarget.Create(nil);
  Integer(Target.FLocation) := Location;
  Target.FMovePoints := MovePoints;
  Target.FTransporterID := TransporterID;
  Target.FData := Data;
  AddChild(Target);
  Target.Release;
end;

function CompareMoveTargets(Item1, Item2: Pointer): Integer;
begin
  Result := TMoveTarget(Item1).FMovePoints - TMoveTarget(Item2).FMovePoints;
end;

procedure TMoveTargetList.SortOnMovePoints;
begin
  FChildren.Sort(CompareMoveTargets);
end;

procedure TAIMoveExecuterUnit.Initialize(AUnit: TAbstractUnit; X, Y, L: Shortint);
begin
  FUnit := AUnit;
  FUnitID := FUnit.FUnitID;
  FLocation.X := X;
  FLocation.Y := Y;
  FLocation.L := L;
  FLocation.Flag := 0;
  FOrigin.X := X;
  FOrigin.Y := Y;
  FOrigin.L := L;
  FOrigin.Flag := 0;
  FDestination.X := -1;
  FDestination.Y := -1;
  FDestination.L := -1;
  FDestination.Flag := 0;
  ResetTransporterSettings;
  FStatus := esIdle;
  FMoveResult := 0;
end;

function TAIMoveExecuterUnit.Validate: Boolean;
begin
  Result := TUnitControl(AoWHSMap.FUnitControl).FindUnit(FUnitID) = FUnit;
  if Result and not (usKilled in FUnit.FUnitStatus) then
  begin
    if FStatus = esMoving then
    begin
      FUnit.GetLocation(FLocation.X, FLocation.Y, FLocation.L);
      FStatus := esReady;
    end;
  end
  else
  begin
    { Original returns the identity check even for a killed unit. }
    FUnit := nil;
    FStatus := esLost;
  end;
end;

procedure TAIMoveExecuterUnit.ResetTransporterSettings;
begin
  FBoardingPoint.X := -1;
  FArrivalPoint.X := -1;
  FTransportSource.X := -1;
  FTransportDestination.X := -1;
end;

function TAIMoveExecuterUnitList.GetUnits(Index: Integer): TAIMoveExecuterUnit;
begin
  Result := TAIMoveExecuterUnit(FChildren.List^[Index]);
end;

function TAIMoveExecuterUnitList.IndexOfUnitID(ID: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAIMoveExecuterUnit(FChildren.List^[Result]).FUnitID = ID then Exit;
  end;
  Result := -1;
end;

function TAIMoveExecuterUnitList.IndexOfUnit(AUnit: TAbstractUnit): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAIMoveExecuterUnit(FChildren.List^[Result]).FUnit = AUnit then Exit;
  end;
  Result := -1;
end;

function TAIMoveExecuterUnitList.FindStatusUnit(Status: TAIMoveExecuterUnitStatus): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAIMoveExecuterUnit(FChildren.List^[Result]).FStatus = Status then Exit;
  end;
  Result := -1;
end;

function TAIMoveExecuterUnitList.ValidateSelection(Selection: Byte): Byte;
var
  N: Integer;
begin
  N := FChildren.Count;
  if N > 8 then N := 8;
  Result := Selection and ArmySelectionMasks[N];
end;

function TAIMoveExecuterUnitList.SelectionCount(Selection: Byte): Integer;
begin
  Selection := ValidateSelection(Selection);
  Result := 0;
  while Selection <> 0 do
  begin
    if Selection and 1 <> 0 then Inc(Result);
    Selection := Selection shr 1;
  end;
end;

function TAIMoveExecuterUnitList.Transporter(Selection: Byte): TAIMoveExecuterUnit;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      if TAIMoveExecuterUnit(FChildren.List^[I]).FUnit.GetTransporter then
      begin
        Result := TAIMoveExecuterUnit(FChildren.List^[I]);
        Break;
      end;
    Selection := Selection shr 1;
  end;
end;

procedure TAIMoveExecuterUnitList.SetMoveResult(Selection, MoveResult: Byte);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      TAIMoveExecuterUnit(FChildren.List^[I]).FMoveResult := MoveResult;
    Selection := Selection shr 1;
  end;
end;

procedure TAIMoveExecuterUnitList.SetTransportStatus(Selection: Byte;
  Status: TAIMoveExecuterTransportStatus);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      TAIMoveExecuterUnit(FChildren.List^[I]).FTransportStatus := Status;
    Selection := Selection shr 1;
  end;
end;

procedure TAIMoveExecuterUnitList.SetStatus(Selection: Byte; Status: TAIMoveExecuterUnitStatus);
var
  I: Integer;
begin
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      TAIMoveExecuterUnit(FChildren.List^[I]).FStatus := Status;
    Selection := Selection shr 1;
  end;
end;

constructor TAIMoveExecuterMove.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TMovepath.Create;
end;

destructor TAIMoveExecuterMove.Destroy;
begin
  { Original retains this empty exception frame when the path is already nil. }
  if FPath = nil then
    try
    except
      ShowMessage('Path already destroyed!?!');
      { Original handler consumes the exception after showing the message. }
    end;
  FPath.Free;
  FPath := nil;
  inherited Destroy;
end;

procedure TAIMoveExecuterMove.AddUnits(Units: TAIMoveExecuterUnitList; Selection: Byte);
var
  I: Integer;
begin
  for I := 0 to Units.Count - 1 do
  begin
    if Selection and 1 <> 0 then AddChild(Units.GetUnits(I));
    Selection := Selection shr 1;
  end;
end;

procedure TAIMoveExecuterMove.AddUnit(UnitEntry: TAIMoveExecuterUnit);
begin
  AddChild(UnitEntry);
end;

procedure TAIMoveExecuterMove.SetUnitStatus(Status: TAIMoveExecuterUnitStatus);
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do
    TAIMoveExecuterUnit(FChildren.List^[I]).FStatus := Status;
end;

function TAIMoveExecuterMove.RetrieveArmy(var Army: TArmyHS; var Selection: Byte): Boolean;
var
  I, Index: Integer;
begin
  Army := TAoWMapField(AoWHSMap.MapContainer.GetField(FSourceX, FSourceY, FSourceL)).GetArmyHS;
  if Army <> nil then
  begin
    Selection := 0;
    for I := Count - 1 downto 0 do
    begin
      Index := Army.FArmy.FindChildIndex(GetUnits(I).FUnit);
      if Index <> -1 then Selection := Selection or (1 shl Index)
      else raise Exception.Create('Unit missing!');
    end;
    Result := True;
  end
  else
  begin
    Selection := 0;
    Army := nil;
    Result := False;
  end;
end;

function TAIMoveExecuterMoveQueue.GetMoves(Index: Integer): TAIMoveExecuterMove;
begin
  Result := TAIMoveExecuterMove(FChildren.List^[Index]);
end;

procedure TAIMoveExecuterMoveQueue.Reset;
var
  I: Integer;
begin
  for I := FChildren.Count - 1 downto 0 do
    TAIMoveExecuterMove(FChildren.List^[I]).SetStatus($FF, esReady);
  Clear;
end;

procedure TAIMoveExecuterMoveQueue.Clear;
begin
  inherited Clear;
end;

procedure TAIMoveExecuterArmy.Setup(Transporter: TAIMoveExecuterUnit);
begin
  FLocation.X := Transporter.FLocation.X;
  FLocation.Y := Transporter.FLocation.Y;
  FLocation.L := Transporter.FLocation.L;
  FLocation.Flag := 0;
  FDestination.X := Transporter.FDestination.X;
  FDestination.Y := Transporter.FDestination.Y;
  FDestination.L := Transporter.FDestination.L;
  FDestination.Flag := 0;
  FGrouped := False;
  FPlayer := Transporter.FUnit.FPlayer;
  FTransportStatus := Transporter.FTransportStatus;
  FBoardingPoint := Transporter.FBoardingPoint;
  FArrivalPoint := Transporter.FArrivalPoint;
  FTransportSource := Transporter.FTransportSource;
  FTransportDestination := Transporter.FTransportDestination;
  AddChild(Transporter);
end;

function TAIMoveExecuterArmy.CanAdd(UnitEntry: TAIMoveExecuterUnit): Boolean;
begin
  Result := (Integer(FLocation) = Integer(UnitEntry.FLocation)) and
    (Integer(FDestination) = Integer(UnitEntry.FDestination)) and
    (FTransportStatus = UnitEntry.FTransportStatus) and
    ((FTransportStatus = mtsDone) or
      ((Integer(FBoardingPoint) = Integer(UnitEntry.FBoardingPoint)) and
       (Integer(FArrivalPoint) = Integer(UnitEntry.FArrivalPoint)) and
       (Integer(FTransportSource) = Integer(UnitEntry.FTransportSource)) and
       (Integer(FTransportDestination) = Integer(UnitEntry.FTransportDestination))));
end;

procedure TAIMoveExecuterArmy.RetrieveArmy(Selection: Byte; var Army: TArmyHS;
  var ArmySelection: Byte);
var
  I, Index: Integer;
begin
  Army := TAoWMapField(AoWHSMap.MapContainer.GetField(
    FLocation.X, FLocation.Y, FLocation.L)).GetArmyHS;
  if Army <> nil then
  begin
    ArmySelection := 0;
    for I := 0 to Count - 1 do
    begin
      if Selection and 1 <> 0 then
      begin
        Index := Army.FArmy.FindChildIndex(GetUnits(I).FUnit);
        if Index <> -1 then ArmySelection := ArmySelection or (1 shl Index)
        else raise Exception.Create('Unit missing!');
      end;
      Selection := Selection shr 1;
    end;
  end
  else
  begin
    ArmySelection := 0;
    Army := nil;
  end;
end;

procedure TAIMoveExecuterArmy.ResetTransporterSettings;
var
  I: Integer;
begin
  for I := Count - 1 downto 0 do GetUnits(I).ResetTransporterSettings;
end;

function TAIMoveExecuterArmy.WaitingForTransport: Boolean;
begin
  Result := Integer(FLocation) = Integer(FBoardingPoint);
end;

function TAIMoveExecuterArmy.Moves(Selection: Byte): Integer;
var
  I: Integer;
begin
  Result := $FFFF;
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      if Result > GetUnits(I).FUnit.GetMoves then Result := GetUnits(I).FUnit.GetMoves;
    Selection := Selection shr 1;
  end;
  if Result = $FFFF then Result := -1;
end;

function TAIMoveExecuterArmy.MovePoints(Selection: Byte): Integer;
var
  I: Integer;
begin
  Result := $FFFF;
  for I := 0 to Count - 1 do
  begin
    if Selection and 1 <> 0 then
      if Result > GetUnits(I).FUnit.GetMovePoints then Result := GetUnits(I).FUnit.GetMovePoints;
    Selection := Selection shr 1;
  end;
  if Result = $FFFF then Result := -1;
end;

function TAIMoveExecuterArmy.ValidTerrain(Selection: Byte; TerrainType,
  OverlayType: Shortint): Byte;
var
  I: Integer;
  All: Boolean;
begin
  Result := 0;
  All := True;
  for I := 0 to Count - 1 do
    if (1 shl I) and Selection <> 0 then
      if not GetUnits(I).FUnit.ValidTerrain(TerrainType, OverlayType) then All := False
      else Result := Result or (1 shl I);
  if All then Result := Selection;
end;

function TAIMoveExecuterArmyList.GetArmies(Index: Integer): TAIMoveExecuterArmy;
begin
  Result := TAIMoveExecuterArmy(FChildren.List^[Index]);
end;

function TAIMoveExecuterArmyList.IndexOf(Army: TArmyHS; Selection: Byte): Integer;
var
  FoundSelection: Byte; I: Integer;
  Entry: TAIMoveExecuterArmy;
  FoundArmy: TArmyHS;
  { byte local precedes the pointer local }
begin
  I := Count;
  while I <> 0 do
  begin
    Dec(I);
    Entry := TAIMoveExecuterArmy(FChildren.List^[I]);
    if (Army.GetXhx = Entry.FLocation.X) and
      (Army.GetYhx = Entry.FLocation.Y) and (Army.GetLhx = Entry.FLocation.L) then
    begin
      Entry.RetrieveArmy($FF, FoundArmy, FoundSelection);
      if (Army = FoundArmy) and (FoundSelection = Selection) then
      begin
        Result := I;
        Exit;
      end;
    end;
  end;
  Result := -1;
end;

function TAIMoveExecuterArmyList.IndexOfXYL(X, Y, L: Shortint): Integer;
var
  I: Integer;
  Army: TAIMoveExecuterArmy;
begin
  I := Count;
  while I <> 0 do
  begin
    Dec(I);
    Army := TAIMoveExecuterArmy(FChildren.List^[I]);
    if (X = Army.FLocation.X) and (Army.FLocation.Y = Y) and
      (Army.FLocation.L = L) then
    begin
      Result := I;
      Exit;
    end;
  end;
  Result := -1;
end;

function TAIMoveExecuterArmyList.IndexOfLoc(Location: TXYL): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Integer(TAIMoveExecuterArmy(FChildren.List^[Result]).FLocation) = Integer(Location) then Exit;
  end;
  Result := -1;
end;

function TAIMoveExecuterArmyList.IndexOfTransportStatus(Status: TAIMoveExecuterTransportStatus): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAIMoveExecuterArmy(FChildren.List^[Result]).FTransportStatus = Status then Exit;
  end;
  Result := -1;
end;

function CompareExecuterArmies(Item1, Item2: Pointer): Integer;
begin
  Result := TAIMoveExecuterArmy(Item1).MovePoints($FF) -
    TAIMoveExecuterArmy(Item2).MovePoints($FF);
end;

procedure TAIMoveExecuterArmyList.SortOnMovePoints;
begin
  FChildren.Sort(CompareExecuterArmies);
end;

constructor TAIMoveExecuterControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMoveControl := TAIMoveControl.Create(nil);
end;

destructor TAIMoveExecuterControl.Destroy;
begin
  FMoveControl.Free;
  inherited Destroy;
end;

function TAIMoveExecuterControl.CreateMove(Army: TAIMoveExecuterArmy; { Near miss: locals and registers differ after three variants. }
  Selection: Byte; X, Y, L: Shortint; Mode: TCreateMoveMode;
  MoveResult: PByte): TAIMoveExecuterMove;
var
  Settings: TMoveControlSettings;
  Move: TAIMoveExecuterMove;
  Candidates: TDoubleItemList;
  ArmySelection: Byte;
  I, Position, Points: Integer;
  MapF: TAoWMapField;
  ArmyHS: TArmyHS;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  Move := nil;
  Army.RetrieveArmy(Selection, ArmyHS, ArmySelection);
  Settings := TMoveControlSettings.Create(nil);
  if cmmSurroundEx in Mode then
  begin
    Settings.FMovePointsMax := Army.MovePoints($FF);
    Settings.SetupArmy(ArmyHS, ArmySelection);
    AoWHSMap.FMoveControl.ProcessMove(Settings);
    Level := AoWHSMap.MapContainer.GetMapLevel(L);
    Candidates := TDoubleItemList.Create;
    InitHNWalk(Walk, X, Y, 1);
    while Walk.Radius <= 1 do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and
        (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      begin
        Points := Settings.GetMovePoints(Walk.X, Walk.Y, L);
        MapF := TAoWMapField(AoWHSMap.MapContainer.GetField(Walk.X, Walk.Y, L));
        if (Points <> $FFFFFF) and
          ((MapF.GetPlayer = -1) or (MapF.GetPlayer = Army.FPlayer)) then
          if CanMoveTo(Army, Selection, Walk.X, Walk.Y, L) = Selection then
            Candidates.AddAB(Integer(PackXYL(Walk.X, Walk.Y, L)), Points);
      end;
      WalkToNextHN(Walk);
    end;
    if Candidates.Count <> 0 then
    begin
      Candidates.SortAscendingItemB;
      X := TXYL(Candidates[0].A).X;
      Y := TXYL(Candidates[0].A).Y;
      L := TXYL(Candidates[0].A).L;
      AoWHSMap.FMoveControl.CalculatePath(Settings, Settings.FPath, X, Y, L);
    end;
    Candidates.Free;
  end
  else
  begin
    Settings.FMovePointsMax := FExecuter.FMovePointsMax;
    Settings.SetupArmy(ArmyHS, ArmySelection);
    Settings.SetDestinationPos(X, Y, L);
    AoWHSMap.FMoveControl.ProcessMove(Settings);
  end;
  if Settings.FPath.Count <> 0 then
  begin
    Points := ArmyHS.FArmy.MovePoints(ArmySelection);
    Position := Settings.FPath.MovePointsToPos(Points);
    if not (cmmSurround in Mode) and
      (Settings.FPath[Position].X = FExecuter.FDestination.X) and
      (Settings.FPath[Position].Y = FExecuter.FDestination.Y) and
      (Settings.FPath[Position].L = FExecuter.FDestination.L) then
      Army.SetMoveResult(Selection, 2);
    if MoveResult <> nil then
      if Position = 0 then MoveResult^ := 2 else MoveResult^ := 0;
    if (cmmSurround in Mode) and (Position = 0) then Inc(Position);
    if Position < Settings.FPath.Count - 1 then
    begin
      while (Position <> Settings.FPath.Count - 1) and
        (CanMoveTo(Army, Selection, Settings.FPath[Position].X,
          Settings.FPath[Position].Y, Settings.FPath[Position].L) <> Selection) do
      begin
        Inc(Position);
        if MoveResult <> nil then
          if MoveResult^ = 2 then MoveResult^ := 1;
      end;
      if Position < Settings.FPath.Count - 1 then
      begin
        Move := TAIMoveExecuterMove.Create(nil);
        Move.AddUnits(Army, Selection);
        for I := Position to Settings.FPath.Count - 1 do Move.FPath.Add(Settings.FPath[I]);
        Move.FMovePoints := Points;
        Move.FMoves := ArmyHS.FArmy.Moves(ArmySelection);
        Move.FSourceX := ArmyHS.GetXhx;
        Move.FSourceY := ArmyHS.GetYhx;
        Move.FSourceL := ArmyHS.GetLhx;
        Move.FDestinationX := X;
        Move.FDestinationY := Y;
        Move.FDestinationL := L;
        if not (cmmDontQueue in Mode) then
        begin
          Move.SetOwner(FExecuter.FMoves);
          Move.SetUnitStatus(esQueued);
        end;
      end;
    end;
  end
  else
  begin
    if MoveResult <> nil then
      if (Army.FLocation.X = X) and (Army.FLocation.Y = Y) and
        (Army.FLocation.L = L) then MoveResult^ := 2 else MoveResult^ := 3;
    if (FExecuter.FDestination.X = Settings.FSourceX) and
      (FExecuter.FDestination.Y = Settings.FSourceY) and
      (FExecuter.FDestination.L = Settings.FSourceL) then
    begin
      Army.SetMoveResult(Selection, 2);
      Army.SetStatus(Selection, esDone);
    end;
  end;
  Settings.Release;
  Result := Move;
end;

function TAIMoveExecuterControl.CanMoveTo(Army: TAIMoveExecuterArmy;
  Selection: Byte; X, Y, L: Shortint): Byte;
var
  TransporterCount, UnitCount, Capacity, I, Index, Excess: Integer;
  AUnit: TAbstractUnit;
  Allowed: Boolean;
  ArmyHS: TArmyHS;
  MapF: TAoWMapField;
  Move: TAIMoveExecuterMove; ExistingArmy: TArmy;
  Transporter: TAIMoveExecuterUnit;
begin
  UnitCount := 0;
  TransporterCount := 0;
  Capacity := 8;
  Allowed := True;
  MapF := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L));
  ArmyHS := MapF.GetArmyHS;
  Result := 0;
  if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = Army.FPlayer) then
  begin
    ExistingArmy := ArmyHS.FArmy; for I := 0 to ExistingArmy.Count - 1 do
    begin
      AUnit := ArmyHS.FArmy.GetUnit(I);
      Index := FExecuter.FUnits.IndexOfUnitID(AUnit.FUnitID);
      if (Index = -1) or (FExecuter.FUnits.GetUnits(Index).FStatus <> esQueued) then
      begin
        Inc(UnitCount);
        if AUnit.GetTransporter then
        begin
          Inc(TransporterCount);
          if AUnit.GetTransportCapacity + 1 < Capacity then
            Capacity := AUnit.GetTransportCapacity + 1;
        end;
      end;
    end;
  end
  else if ((FExecuter.FDestination.X <> X) or
    (FExecuter.FDestination.Y <> Y) or (FExecuter.FDestination.L <> L)) and
    (MapF.GetPlayer <> -1) and (MapF.GetPlayer <> Army.FPlayer) then Allowed := False;
  if Allowed then
  begin
    for I := 0 to FExecuter.FMoves.Count - 1 do
    begin
      Move := FExecuter.FMoves.GetMoves(I);
      if (Move.FPath[0].X = X) and (Move.FPath[0].Y = Y) and (Move.FPath[0].L = L) then
      begin
        Inc(UnitCount, Move.Count);
        Transporter := Move.Transporter($FF);
        if Transporter <> nil then
        begin
          Inc(TransporterCount);
          if Transporter.FUnit.GetTransportCapacity + 1 < Capacity then
            Capacity := Transporter.FUnit.GetTransportCapacity + 1;
        end;
      end;
    end;
    Transporter := Army.Transporter(Selection);
    if (Transporter = nil) or (TransporterCount = 0) then
    begin
      if Transporter <> nil then
        if Transporter.FUnit.GetTransportCapacity + 1 < Capacity then
          Capacity := Transporter.FUnit.GetTransportCapacity + 1;
      Excess := Army.SelectionCount(Selection) + UnitCount - Capacity;
      if Excess > 0 then
        if Transporter = nil then
        begin
          I := 8;
          Selection := Army.ValidateSelection(Selection);
          Result := Selection;
          while (Excess <> 0) and (Result <> 0) do
          begin
            Dec(I);
            if Selection and $80 <> 0 then
            begin
              Result := Result and not (1 shl I);
              Dec(Excess);
            end;
            Selection := (Selection and $7F) shl 1;
          end;
        end
        else Result := 0
      else Result := Selection;
    end
    else Result := 0;
  end;
  if not Allowed then Result := 0;
end;

procedure TAIMoveExecuterControl.Activate(Executer: TAIMoveExecuter);
begin
  FExecuter := Executer;
  FState := 0;
end;

procedure TAIMoveExecuterControl.Deactivate;
begin
end;

procedure TAIMoveExecuterControl.CalculateMoves;
begin
  Done;
end;

procedure TAIMoveExecuterControl.Done;
begin
  FState := -1;
end;

function TAIMoveExecuterControl.Process: Boolean;
var
  TimeLeft: Integer;
begin
  TimeLeft := 5;
  if FMoveControl.FStatus = amsProcessing then FMoveControl.Process;
  while (FMoveControl.FStatus <> amsProcessing) and (TimeLeft > 0) and
    (FExecuter.FStatus = mesBusy) and (FExecuter.FState = 0) and
    (FState <> -1) do
  begin
    CalculateMoves;
    TimeLeft := AoWHSMap.FAIExecuter.GetProcessTimeLeft;
  end;
  Result := FState <> -1;
end;

procedure TDefaultMEC.CalculateMoves;
var
  I: Integer;
  Armies: TAIMoveExecuterArmyList;
  Move: TAIMoveExecuterMove;
  MoveResult: Byte;
  Mode: TCreateMoveMode;
  CannotMove: Boolean;
begin
  case FState of
    0:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        if Armies.Count <> 0 then
        begin
          if memAttack in FExecuter.FMode then Mode := [cmmSurround] else Mode := [];
          Move := CreateMove(Armies.GetArmies(0), $FF,
            FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L, Mode, @MoveResult);
          if Move <> nil then
          begin
            if not (memSimultaneous in FExecuter.FMode) or
              ((memAttack in FExecuter.FMode) and (MoveResult = 2)) then FExecuter.ExecuteMoves;
          end
          else Armies.GetArmies(0).SetStatus($FF, esDone);
        end
        else if FExecuter.FMoves.Count <> 0 then
        begin
          FExecuter.ExecuteMoves;
          if memAttack in FExecuter.FMode then FState := 1 else FState := 2;
        end;
        if (FExecuter.FMoves.Count = 0) and (Armies.Count = 0) then
          if memAttack in FExecuter.FMode then FState := 1 else Done;
        Armies.Free;
      end;
    1:
      begin
        I := 0;
        CannotMove := True;
        Armies := FExecuter.CreateArmies([esReady, esDone]);
        while CannotMove and (I <> Armies.Count) do
        begin
          Move := CreateMove(Armies.GetArmies(I), $FF,
            FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L,
              [cmmDontQueue, cmmSurround], @MoveResult);
          CannotMove := MoveResult <> 0;
          if Move <> nil then Move.Free;
          Inc(I);
        end;
        if CannotMove then
        begin
          I := 0;
          Move := nil;
          while (Move = nil) and (I <> Armies.Count) do
          begin
            Move := CreateMove(Armies.GetArmies(I), $FF,
              FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L, [], @MoveResult);
            if Move <> nil then FExecuter.ExecuteMoves;
            Inc(I);
          end;
        end;
        Armies.Free;
        Done;
      end;
    2: Done;
  end;
end;

constructor TAdjacentArmy.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TMovepath.Create;
end;

destructor TAdjacentArmy.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

function TAdjacentArmy.GetMovementDays: Single;
var
  Points: Integer;
begin
  if FMoves <> 0 then
  begin
    Points := FPath.GetMovePoints;
    if Points > FMovePoints then Result := (Points - FMovePoints) / FMoves + 1
    else if Points <> 0 then Result := Points / FMovePoints
    else Result := 0;
  end
  else Result := 99;
end;

function TAdjacentArmyList.GetAdjacentArmies(Index: Integer): TAdjacentArmy;
begin
  Result := TAdjacentArmy(FChildren.List^[Index]);
end;

function TAdjacentArmyList.IndexOfLoc(Location: TXYL): Integer;
begin
  Result := Count;
  Location.Flag := 0;
  while Result <> 0 do
  begin
    Dec(Result);
    if Integer(TAdjacentArmy(FChildren.List^[Result]).FLocation) = Integer(Location) then Exit;
  end;
  Result := -1;
end;

function TAdjacentArmyList.GetSlowestArmy: Integer;
var
  I: Integer;
  MaxDays, Days: Single;
begin
  MaxDays := -1;
  Result := -1;
  for I := 0 to Count - 1 do
  begin
    Days := GetAdjacentArmies(I).GetMovementDays;
    if Days > MaxDays then
    begin
      Result := I;
      MaxDays := Days;
    end;
  end;
end;

function TAdjacentArmyList.GetAdjacent: Boolean;
var
  I: Integer;
  Locations: TXYLList;
begin
  Locations := TXYLList.Create;
  for I := 0 to Count - 1 do Locations.Add(GetAdjacentArmies(I).FLocation);
  Result := LocationsConnected(Locations);
  Locations.Free;
end;

constructor TAdjacentMEC.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FAdjacentArmies := TAdjacentArmyList.Create(nil);
end;

destructor TAdjacentMEC.Destroy;
begin
  FAdjacentArmies.Free;
  inherited Destroy;
end;

function TAdjacentMEC.ExecuteSurroundMove: Boolean;
var
  I, Index: Integer;
  Armies: TAIMoveExecuterArmyList;
  Sorted: TDoubleItemList;
  Army: TAIMoveExecuterArmy;
  MoveResult: Byte;
  Location: TXYL;
begin
  Result := True;
  Armies := FExecuter.CreateArmies([esReady, esDone]);
  Sorted := TDoubleItemList.Create;
  for I := 0 to FAdjacentArmies.Count - 1 do
    Sorted.AddAB(Integer(FAdjacentArmies.GetAdjacentArmies(I)),
      Round(FAdjacentArmies.GetAdjacentArmies(I).GetMovementDays * 100));
  Sorted.SortDescendingItemB;
  Location := TAdjacentArmy(Sorted[0].A).FPath[1];
  I := 0;
  while Result and (I < Sorted.Count) do
  begin
    Index := Armies.IndexOfLoc(TAdjacentArmy(Sorted[I].A).FLocation);
    if Index <> -1 then
    begin
      Army := Armies.GetArmies(Index);
      if (Army.FLocation.L = FExecuter.FDestination.L) and
        (dHXtoRad(Army.FLocation.X, Army.FLocation.Y,
          FExecuter.FDestination.X, FExecuter.FDestination.Y) > 1) then
      begin
        CreateMove(Army, $FF, FExecuter.FDestination.X, FExecuter.FDestination.Y,
          FExecuter.FDestination.L, [cmmSurroundEx], @MoveResult);
        Result := (MoveResult <> 0) and (MoveResult <> 3);
      end;
    end;
    Inc(I);
  end;
  if FExecuter.FMoves.Count <> 0 then
    if Result then FExecuter.ExecuteMoves else FExecuter.FMoves.Reset;
  Sorted.Free;
  Armies.Free;
end;

function TAdjacentMEC.CalculateMeetingPoint: Integer; { Near miss: result and loop registers differ after three variants. }
var
  I, Points, Reserve, Index, Position: Integer;
  Armies: TAIMoveExecuterArmyList;
  Adjacent: TAdjacentArmy;
  Army: TAIMoveExecuterArmy;
begin
  Armies := FExecuter.CreateArmies([esReady, esDone]);
  Result := $FFFFFF;
  I := FAdjacentArmies.GetSlowestArmy;
  if I <> -1 then
    if (FAdjacentArmies.GetAdjacentArmies(I).GetMovementDays > 1) or
      not (memAttack in FExecuter.FMode) then
    begin
      Points := FAdjacentArmies.GetAdjacentArmies(I).FMovePoints;
      if memAttack in FExecuter.FMode then
      begin
        Reserve := Round(Points * 0.75);
        if Reserve > FAdjacentArmies.GetAdjacentArmies(I).FPath.GetMovePoints - Points then
          Points := FAdjacentArmies.GetAdjacentArmies(I).FPath.GetMovePoints - Reserve;
      end;
      Adjacent := FAdjacentArmies.GetAdjacentArmies(I);
      Index := Armies.IndexOfLoc(FAdjacentArmies.GetAdjacentArmies(I).FLocation);
      if Index <> -1 then
      begin
        Army := Armies.GetArmies(Index);
        Position := Adjacent.FPath.MovePointsToPos(Points);
        while (Position > 1) and
          (CanMoveTo(Army, $FF, Adjacent.FPath[Position].X,
            Adjacent.FPath[Position].Y, Adjacent.FPath[Position].L) <> $FF) do Dec(Position);
        Result := Integer(FAdjacentArmies.GetAdjacentArmies(I).FPath[Position]);
      end;
    end;
  Armies.Free;
end;

function TAdjacentMEC.ExecuteMeetingPointMove: Boolean; { Near miss: register or temporary allocation differs after three variants. }
var
  I, Index: Integer;
  Armies: TAIMoveExecuterArmyList;
  Sorted: TDoubleItemList;
  MoveResult: Byte;
  Location: TXYL;
begin
  Result := True;
  Integer(Location) := CalculateMeetingPoint;
  if Integer(Location) = $FFFFFF then
    with FExecuter.FDestination do Location := PackXYL(X, Y, L);
  Armies := FExecuter.CreateArmies([esReady]);
  Sorted := TDoubleItemList.Create;
  for I := 0 to FAdjacentArmies.Count - 1 do
    Sorted.AddAB(Integer(FAdjacentArmies.GetAdjacentArmies(I)),
      Round(FAdjacentArmies.GetAdjacentArmies(I).GetMovementDays * 100));
  Sorted.SortDescendingItemB;
  for I := 0 to Sorted.Count - 1 do
  begin
    Index := Armies.IndexOfLoc(TAdjacentArmy(Sorted[I].A).FLocation);
    if Index <> -1 then
    begin
      CreateMove(Armies.GetArmies(Index), $FF,
        Location.X, Location.Y, Location.L, [], @MoveResult);
      if MoveResult = 0 then Result := False;
    end;
  end;
  if FExecuter.FMoves.Count <> 0 then FExecuter.ExecuteMoves;
  Sorted.Free;
  Armies.Free;
end;

procedure TAdjacentMEC.CalculateMoves;
var
  Index, Ready, Failed, J, I: Integer;
  Armies: TAIMoveExecuterArmyList;
  MoveResult: Byte;
  Settings: TMoveControlSettings;
  ArmySelection: Byte;
  ArmyHS: TArmyHS;
  Adjacent: TAdjacentArmy;
  Move: TAIMoveExecuterMove;
  Mode: TCreateMoveMode; CanMove: Boolean;
begin
  case FState of
    0:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        I := 0;
        while (Armies.Count <> I) and
          (FAdjacentArmies.IndexOfLoc(Armies.GetArmies(I).FLocation) <> -1) do Inc(I);
        if I < Armies.Count then
        begin
          Settings := TMoveControlSettings.Create(nil);
          try
            Armies.GetArmies(I).RetrieveArmy($FF, ArmyHS, ArmySelection);
          except
            { Original suppresses a RetrieveArmy exception. }
          end;
          { Original uses transporter IDs as visited markers during adjacent moves. }
          for J := Armies.GetArmies(I).Count - 1 downto 0 do
            Armies.GetArmies(I).GetUnits(J).FTransporterID := 0;
          Settings.Reset;
          Settings.FMovePointsMax := FExecuter.FMovePointsMax;
          Settings.SetupArmy(ArmyHS, ArmySelection);
          Settings.SetDestinationPos(FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L);
          AoWHSMap.FMoveControl.ProcessMove(Settings);
          Adjacent := TAdjacentArmy.Create(FAdjacentArmies);
          Adjacent.FPath.Assign(Settings.FPath);
          Adjacent.FMoves := ArmyHS.FArmy.Moves(ArmySelection);
          Adjacent.FMovePoints := ArmyHS.FArmy.MovePoints(ArmySelection);
          Adjacent.FLocation := Armies.GetArmies(I).FLocation;
          Settings.Release;
        end
        else
        begin
          I := FAdjacentArmies.Count - 1;
          while (I >= 0) and (FAdjacentArmies.GetAdjacentArmies(I).FPath.Count > 0) do Dec(I);
          if I = -1 then Inc(FState) else FState := 4;
        end;
        Armies.Free;
      end;
    1:
      begin
        if FAdjacentArmies.GetAdjacent then
        begin
          if (FAdjacentArmies.GetAdjacentArmies(FAdjacentArmies.GetSlowestArmy).GetMovementDays <= 1.25) and
            (memAttack in FExecuter.FMode) then
          begin
            if ExecuteSurroundMove then FState := 5
            else
            begin
              FMeetingPoint := FExecuter.FDestination;
              FState := 2;
            end;
          end
          else
          begin
            FMeetingPoint := FExecuter.FDestination;
            FState := 2;
          end;
        end
        else
          if (FAdjacentArmies.GetAdjacentArmies(FAdjacentArmies.GetSlowestArmy).GetMovementDays <= 1) and
            (memAttack in FExecuter.FMode) then
          begin
            if ExecuteSurroundMove then FState := 5 else FState := 3;
          end
          else
          begin
            ExecuteMeetingPointMove;
            FState := 3;
          end;
      end;
    2:
      begin
        Armies := FExecuter.CreateArmies([esReady]);
        Armies.SortOnMovePoints;
        if Armies.Count <> 0 then
        begin
          if FExecuter.FMoves.Count = 0 then
          begin
            Index := 0;
            while (Index < Armies.Count) and
              (Armies.GetArmies(Index).GetUnits(0).FTransporterID = 1) do Inc(Index);
            if Index < Armies.Count then
            begin
              for J := Armies.GetArmies(Index).Count - 1 downto 0 do
                Armies.GetArmies(Index).GetUnits(J).FTransporterID := 1;
              if memAttack in FExecuter.FMode then Mode := [cmmDontQueue, cmmSurround]
              else Mode := [cmmDontQueue];
              Move := CreateMove(Armies.GetArmies(Index), $FF, FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L, Mode, @MoveResult);
              if Move = nil then
              begin
                if MoveResult = 1 then FState := 3
                else if MoveResult = 3 then
                begin
                  FExecuter.FStatus := mesFailed;
                  FState := 3;
                end
                else if MoveResult <> 2 then FState := 3;
              end
              else
              begin
                Move.SetOwner(FExecuter.FMoves);
                Move.SetUnitStatus(esQueued);
                if MoveResult = 0 then FMeetingPoint := Move.FPath[0]
                else FMeetingPoint := FExecuter.FDestination;
              end;
            end
            else
            begin
              FExecuter.FControlQueue.Add(0);
              FState := 3;
            end;
          end
          else
          begin
            if (Integer(FMeetingPoint) = Integer(FExecuter.FDestination)) and
              (memAttack in FExecuter.FMode) then Mode := [cmmDontQueue, cmmSurround]
            else Mode := [cmmDontQueue];
            Move := CreateMove(Armies.GetArmies(0), $FF,
              FMeetingPoint.X, FMeetingPoint.Y, FMeetingPoint.L, Mode, @MoveResult);
            if Move <> nil then
            begin
              if MoveResult = 0 then
              begin
                if FExecuter.FMoves.Count <> 0 then FExecuter.FMoves.Reset;
                Move.Free;
              end
              else
              begin
                Move.SetOwner(FExecuter.FMoves);
                Move.SetUnitStatus(esQueued);
              end;
            end
            else if (MoveResult = 1) or (MoveResult = 2) then
              Armies.GetArmies(0).SetStatus($FF, esDone)
            else if MoveResult = 3 then
            begin
              FExecuter.FStatus := mesFailed;
              FExecuter.FMoves.Reset;
              FState := 3;
            end
            else
            begin
              FExecuter.FMoves.Reset;
              FState := 3;
            end;
          end;
        end
        else
        begin
          FExecuter.ExecuteMoves;
          FState := 3;
        end;
        Armies.Free;
      end;
    3: Done;
    4:
      begin
        if memAttack in FExecuter.FMode then
        begin
          I := FAdjacentArmies.Count - 1;
          while (I >= 0) and (FAdjacentArmies.GetAdjacentArmies(I).FPath.Count <> 2) do Dec(I);
          if I <> -1 then FState := 5
          else
          begin
            FExecuter.FStatus := mesFailed;
            FState := 3;
          end;
        end
        else
        begin
          FExecuter.FStatus := mesFailed;
          FState := 3;
        end;
      end;
    5:
      begin
        I := 0;
        Ready := 0;
        Failed := 0;
        Armies := FExecuter.CreateArmies([esReady, esDone]);
        while Armies.Count <> I do
        begin
          Move := CreateMove(Armies.GetArmies(I), $FF, FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L,
              [cmmDontQueue, cmmSurround], @MoveResult);
          CanMove := (MoveResult <> 0) or
            ((dHXtoRad(FExecuter.FDestination.X, FExecuter.FDestination.Y,
              Armies.GetArmies(I).FLocation.X, Armies.GetArmies(I).FLocation.Y) = 1) and
             (Armies.GetArmies(I).FLocation.L = FExecuter.FDestination.L)); if CanMove then Inc(Ready)
          else Inc(Failed);
          if Move <> nil then Move.Free;
          Inc(I);
        end;
        Armies.Free;
        if (Ready > 4) or (Failed = 0) then
        begin
          I := 0;
          Move := nil;
          Armies := FExecuter.CreateArmies([esReady, esDone]);
          while (Move = nil) and (Armies.Count <> I) do
          begin
            Move := CreateMove(Armies.GetArmies(I), $FF, FExecuter.FDestination.X, FExecuter.FDestination.Y, FExecuter.FDestination.L, [], @MoveResult);
            if Move <> nil then FExecuter.ExecuteMoves;
            Inc(I);
          end;
          Armies.Free;
        end;
        Done;
      end;
  end;
end;




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
  Fields, OtherFields: TList;
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
      Field := Fields.List^[I];
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
    OtherFields := Settings.FProcessedMapFields;
    Found := False;
    I := 0;
    while not Found and (I <> OtherFields.Count) do
    begin
      Field := OtherFields.List^[I];
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

procedure TTransportMEC.UpdateTransportMeetingPoint; { Keep the Boolean addressable for the original local layout. }
var
  Armies: TAIMoveExecuterArmyList;
  Settings: TMoveControlSettings;
  Selection: Byte;
  I, J: Integer;
  Found: Boolean; Spill: Pointer;
  ArmyHS: TArmyHS;
begin Spill := @Found; { Addressability survives elimination of this assignment. }
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
  UnitEntry: TAIMoveExecuterUnit;
begin
  Armies := FExecuter.CreateArmies([esReady]);
  Index := Armies.IndexOf(FMoveControl.FSettings.FArmyHS, FMoveControl.FSettings.FSelection);
  if Index <> -1 then Army := Armies.GetArmies(Index) else Army := nil;
  if (Army <> nil) and (FMoveControl.FSettings.FMovePoints <> -1) then
    if FMoveControl.FSettings.FBoardingPoint.X <> -1 then
    with FMoveControl.FSettings do begin
      Index := FTransportPath.IndexOfXYL(FBoardingPoint.X,
        FBoardingPoint.Y, FBoardingPoint.L);
      while (Index <> FTransportPath.Count - 1) and
        (CanMoveTo(Army, $FF, FTransportPath[Index].X,
          FTransportPath[Index].Y, FTransportPath[Index].L) <> $FF) do Inc(Index);
      FBoardingPoint := FTransportPath[Index];
      Index := FTransportPath.IndexOfXYL(FArrivalPoint.X,
        FArrivalPoint.Y, FArrivalPoint.L);
      while (Index <> 0) and
        (CanMoveTo(Army, $FF, FTransportPath[Index].X,
          FTransportPath[Index].Y, FTransportPath[Index].L) <> $FF) do Dec(Index);
      FArrivalPoint := FTransportPath[Index];
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
    end else for I := 0 to Army.Count - 1 do Army.GetUnits(I).FTransportStatus := mtsArriving
  else FExecuter.FStatus := mesFailed;
  Armies.Free;
end;






procedure TTransportMEC.CalculateMoves; { Near miss: Timer/settings allocation and state layout differ after three variants. }
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

procedure TAIMoveExecuter.InvalidateMove(Army: TArmyHS; Selection: Byte);
begin
  FStatus := mesInvalidated;
  UpdateMoveResult;
  if Assigned(FOnDone) then FOnDone(Self);
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
      MultiMove.FSimultaneous := False;
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
        2: ActivateMEC(TAdjacentMEC);
        1: ActivateMEC(TTransportMEC);
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
      if Assigned(FOnDone) then FOnDone(Self);
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
        if (memAdjacent in FMode) and (Armies.Count > 1) then FControlQueue.Add(2)
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
  else Started := False; Result := Started;
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

function TAIMoveTargetSelector.ProcessStates: Boolean; { Review fix: use unchecked processed-field loads, as in the original. }
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
          Field := TAoWMapField(Settings.FProcessedMapFields.List^[I]);
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
          Field := TAoWMapField(Settings.FProcessedMapFields.List^[I]);
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
  Best: Integer;
  Wall: TWallSituation;
  AUnit: TAbstractUnit;
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
      FTargetPriority := FTargetPriority * (Count + 2);
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
      FTargetPriority := FTargetPriority * (Count + 2);
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
  Ability: array[0..0] of TAbility; { Keep the selected ability in its original stack slot. }
  Action: TFleeCA;
  Executed: Boolean;
begin
  Combat := TFastCombat(FCombat);
  Commands := TFastCombatCommandList.Create(Self, Combat, Combat.FSides[GetSide]);
  AUnit := FUnit;
  for I := AUnit.GetAbilityCount - 1 downto 0 do
    if AUnit.GetAbilityEnabled(I) then
    begin
      Ability[0] := AoWHSSet.FAbilityControl.GetAbility(I);
      Ability[0].fcPrefetchCombatCommands(Commands);
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
            Ability[0] := AoWHSSet.FAbilityControl.GetAbility(I);
            Ability[0].fcPrefetchCombatCommands(Commands);
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
begin
  inherited Create(AOwner);
end;

destructor TFastCombat.Destroy;
begin
  inherited Destroy;
end;

class function TFastCombat.ClassID: Integer;
begin
  Result := $202B0;
end;

function TFastCombat.GetRoundDistance: Integer;
var Distance: Integer;
begin
  Distance := (FCombatData.FRound - 1) * 2;
  with FCombatData do
  begin
    if FPlayers.GetPlayers(FCurrentPlayer).FSideIndex = 0 then Inc(Distance);
  end;
  Result := Distance;
end;

function TFastCombat.GetRoundDistanceMax: Integer;
var
  I: Integer;
  Obj: TCombatObject;
begin
  Result := 0;
  I := FCombatData.GetCount;
  while I <> 0 do
  begin
    Dec(I);
    Obj := FCombatData.GetObjects(I);
    if Obj.GetEnabled then
      if Result < Obj.fcRoundDistance then Result := Obj.fcRoundDistance;
  end;
end;

procedure TFastCombat.Initialize;
begin
  inherited Initialize;
end;

procedure TFastCombat.Activate;
begin
  inherited Activate;
end;

procedure TFastCombat.Deactivate;
begin
  inherited Deactivate;
end;

function TFastCombat.CreateCombatUnit: TCombatUnit;
begin
  Result := TFastCombatUnit.Create(nil);
end;

function TFastCombat.GetWallInBetween(Source, Target: Byte): Boolean;
begin
  if ((Source and $F) <= 7) and ((Target and $F) <= 7) and
    (FCombatData.FWall <> nil) and not (csDestroyed in FCombatData.FWall.FStatus) then
  begin
    Source := Source shr 4;
    Target := Target shr 4;
    if (Source < 7) and (Target < 7) then
      Result := (FCombatData.FParties.GetParty(Source).FWall <> 0) xor
        (FCombatData.FParties.GetParty(Target).FWall <> 0)
    else Result := False;
  end
  else Result := False;
end;

function TFastCombat.GetWallSituation(A1, A2: TCombatObject): TWallSituation;
begin
  if GetWallInBetween(A1.FPosition, A2.FPosition) then
    if A1.GetSide = csDefender then Result := wsSource
    else Result := wsTarget
  else Result := wsNone;
end;

function TFastCombat.Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Byte; A7: Byte; A8: Integer; A9: Integer; A10: Integer; A11: Boolean): Boolean;
begin
  Result := inherited Setup(A1, A2, A3, A4, A5, A6, A7, A8, A9, A10, A11);
end;

function TFastCombat.AttackerCanCrushWall: Boolean;
var
  Side: TCombatSide;
  I: Integer;
  CanCrush: Boolean;
begin
  Side := FSides[csAttacker];
  I := Side.Count;
  CanCrush := False;
  while (I <> 0) and not CanCrush do
  begin
    Dec(I);
    CanCrush := not (csDestroyed in Side.GetObjects(I).FStatus) and
      (wcWallBreaching in Side.GetObjects(I).WallCombatFeatures);
  end;
  Result := CanCrush;
end;

function TFastCombat.GetAttackerBalisticCV: Integer;
var
  CV: Integer;
  Side: TCombatSide;
  I: Integer;
begin
  CV := 0;
  Side := FSides[csAttacker];
  for I := 0 to Side.Count - 1 do
    if not (csDestroyed in Side.GetObjects(I).FStatus) and
      Side.GetObjects(I).SupportCombatMode([cmMediumRange, cmLongRange]) then
      Inc(CV, Side.GetObjects(I).FCombatValue);
  Result := CV;
end;

function TFastCombat.GetDefenderBalisticCV: Integer;
var
  CV: Integer;
  Side: TCombatSide;
  I: Integer;
begin
  CV := 0;
  Side := FSides[csDefender];
  for I := 0 to Side.Count - 1 do
    if not (csDestroyed in Side.GetObjects(I).FStatus) and
      Side.GetObjects(I).SupportCombatMode([cmMediumRange, cmLongRange]) then
      Inc(CV, Side.GetObjects(I).FCombatValue);
  Result := CV;
end;

function TFastCombat.ValidateWallBreaching: Boolean;
var Wall: TCombatWall;
begin
  Wall := FCombatData.FWall;
  if (Wall <> nil) and not (csDestroyed in Wall.FStatus) and (FWallSiegeObjectCount = 0) then
  begin
    FCombatResult := crCannotBreachWall;
    Result := False;
  end
  else Result := True;
end;

procedure TFastCombat.ExecuteCombatRound;
var
  Idle: Boolean;
  PlayerIndex, I, MoveCost: Integer;
  Objects: TCombatObjectList;
  Obj: TCombatObject;
begin
  NewRound;
  Idle := True;
  Objects := TCombatObjectList.Create;
  SetLogbookHeader(Format(TranslateRStr(P5RoundXRStr), [IntToStr(GetRound)]));
  for PlayerIndex := 0 to FCombatData.FTurnOrder.Count - 1 do
  begin
    NewTurn(FCombatData.FTurnOrder[PlayerIndex]);
    Objects.Clear;
    for I := FCombatData.GetCount - 1 downto 0 do
    begin
      Obj := FCombatData.GetObjects(I);
      if (Obj.FCombatPlayer = Shortint(FCombatData.FCurrentPlayer)) and Obj.GetEnabled and
        not Obj.GetLocked and not (csTurnDone in Obj.FStatus) then Objects.Add(Obj);
    end;
    MoveCost := 0;
    repeat
      I := Objects.Count;
      while I <> 0 do
      begin
        Dec(I);
        if Objects.GetObject(I).GetEnabled then
          if Objects.GetObject(I).fcExecute(MoveCost) then
          begin
            Idle := False;
            Objects.Delete(I);
          end;
      end;
      Inc(MoveCost);
    until MoveCost >= 3;
  end;
  if Idle then
    if GetRound > GetRoundDistanceMax then Terminate;
  Objects.Free;
end;

function TFastCombat.Execute: TCombatResult;
var
  Header: string;
  Side: TCombatSide;
begin
  inherited Execute;
  FCombatResult := crBusy;
  if ValidateWallBreaching then
  begin
    if FSides[csDefender].GetUndestroyedConquerObjects <> 0 then
    begin
      Side := FSides[csDefender];
      if Side.Count > Side.FConquerCount then
      begin
        while not FTerminated do
        begin
          if ValidateWallBreaching then ExecuteCombatRound
          else Terminate;
          CheckTerminate;
        end;
        UpdateStatus;
        Header := GetCombatResultText;
        SetLogbookHeader(Header);
      end
      else
      begin
        FCombatResult := crCannotInflictDamage;
        Header := TranslateRStr(CannotInflictDamageRStr);
        SetLogbookHeader(Header);
      end;
    end
    else FCombatResult := crNoDefenders;
  end
  else
  begin
    Header := TranslateRStr(CannotBreachWallRStr);
    SetLogbookHeader(Header);
    FCombatResult := crCannotBreachWall;
  end;
  Result := FCombatResult;
end;

function TCombatObjectList.GetObject(Index: Integer): TCombatObject;
begin
  Result := List^[Index];
end;


