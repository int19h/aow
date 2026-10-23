constructor TCombatPredictorUnit.Create;
begin inherited Create; FRoundTargets := TQuadItemList.Create; end;

destructor TCombatPredictorUnit.Destroy;
var Obj: TObject; U: TAbstractUnit;
begin
  TObject(FRoundTargets).Free;
  Obj := TObject(FTargets);
  if Obj <> nil then begin Obj.Free; FTargets := nil; end;
  Obj := TObject(FWallTargets);
  if Obj <> nil then begin Obj.Free; FWallTargets := nil; end;
  U := TAbstractUnit(FUnit);
  if U <> nil then begin U.Release; FUnit := nil; end;
  inherited Destroy;
end;

procedure TCombatPredictorUnit.Setup(A1: TAbstractUnit; A2: Integer; A3: Byte);
var Predictor: TCombatPredictor absolute A2; P: TCombatPredictor; U: TAbstractUnit;
begin
  U := TAbstractUnit(A1);
  FUnit := U;
  U.AddRef;
  P := Predictor;
  FPredictor := P;
  FCPUID := P.CreateUniqueCPUID;
  FSide := A3;
  { needs: P2 GetHitPoints returns Shortint; MOVSX AL at $5572A61F. }
  FInitialHitPoints := TAbstractUnit(FUnit).GetHitPoints * 100;
  FEnabled := 1;
  FTargetsInvalid := 1;
  FWallTargetsInvalid := 1;
  if FSide = 0 then FOpponents := TCombatPredictor(FPredictor).FSides[1]
  else FOpponents := TCombatPredictor(FPredictor).FSides[0];
end;

procedure TCombatPredictorUnit.SetEnabled(A1: Byte);
begin
  if A1 <> FEnabled then
  begin
    FEnabled := A1;
    TCombatPredictor(FPredictor).FInvalid := 1;
  end;
end;

procedure TCombatPredictorUnit.UpdateTargets;
var I, J, V: Integer; U: TCombatPredictorUnit;
begin
  if FTargets = nil then FTargets := TQuadItemList.Create;
  for I := TQuadItemList(FTargets).Count - 1 downto 0 do
  begin
    J := TCombatPredictorUnitList(FOpponents).IndexOfCPUID(TQuadItemList(FTargets).List^[I].C);
    if J = -1 then
    begin
      TQuadItemList(FTargets).Delete(I);
      { Original reads the shifted entry after deletion. }
      Dec(FCombatValue, TQuadItemList(FTargets).List^[I].B);
    end;
  end;
  if TQuadItemList(FTargets).Count <> 0 then
    for I := TCombatPredictorUnitList(FOpponents).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnitList(FOpponents).GetUnits(I);
      J := TQuadItemList(FTargets).IndexOfItemC(U.FCPUID);
      if J = -1 then
      begin
        Inc(TCombatPredictor(FPredictor).FWork);
        V := TAbstractUnit(FUnit).GetCombatValue(TAbstractUnit(U.FUnit), 0);
        if V < 0 then V := 0;
        TQuadItemList(FTargets).AddABCD(Integer(U), V, U.FCPUID, 0);
        Inc(FCombatValue, V);
      end;
    end
  else
  begin
    FCombatValue := 0;
    for I := TCombatPredictorUnitList(FOpponents).Count - 1 downto 0 do
    begin
      Inc(TCombatPredictor(FPredictor).FWork);
      U := TCombatPredictorUnit(TCombatPredictorUnitList(FOpponents).List^[I]);
      V := TAbstractUnit(FUnit).GetCombatValue(TAbstractUnit(U.FUnit), 0);
      if V < 0 then V := 0;
      TQuadItemList(FTargets).AddABCD(Integer(U), V, U.FCPUID, 0);
      Inc(FCombatValue, V);
    end;
  end;
  FTargetsInvalid := 0;
end;

procedure TCombatPredictorUnit.UpdateWallTargets;
var I, J, V: Integer; U: TCombatPredictorUnit; Passing: Boolean; Mode: Byte;
begin
  Passing := wcWallPassing in TAbstractUnit(FUnit).GetWallCombatFeatures;
  if FWallTargets = nil then FWallTargets := TQuadItemList.Create;
  for I := TQuadItemList(FWallTargets).Count - 1 downto 0 do
  begin
    J := TCombatPredictorUnitList(FOpponents).IndexOfCPUID(TQuadItemList(FWallTargets).List^[I].C);
    if J = -1 then
    begin
      TQuadItemList(FWallTargets).Delete(I);
      { Original reads the shifted entry after deletion. }
      Dec(FWallCombatValue, TQuadItemList(FWallTargets).List^[I].B);
    end;
  end;
  if TQuadItemList(FWallTargets).Count <> 0 then
    for I := TCombatPredictorUnitList(FOpponents).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TCombatPredictorUnitList(FOpponents).List^[I]);
      J := TQuadItemList(FWallTargets).IndexOfItemC(U.FCPUID);
      if J = -1 then
      begin
        if not Passing then
          if FBehindWall <> 0 then
            if U.FBehindWall = 0 then Mode := 1 else Mode := 0
          else if U.FBehindWall <> 0 then Mode := 2 else Mode := 0
        else Mode := 0;
        Inc(TCombatPredictor(FPredictor).FWork);
        V := TAbstractUnit(FUnit).GetCombatValue(TAbstractUnit(U.FUnit), Mode);
        if V < 0 then V := 0;
        TQuadItemList(FWallTargets).AddABCD(Integer(U), V, 0, 0);
        Inc(FWallCombatValue, V);
      end;
    end
  else
  begin
    FWallCombatValue := 0;
    for I := TCombatPredictorUnitList(FOpponents).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TCombatPredictorUnitList(FOpponents).List^[I]);
      if not Passing then
        if FBehindWall <> 0 then
          if U.FBehindWall = 0 then Mode := 1 else Mode := 0
        else if U.FBehindWall <> 0 then Mode := 2 else Mode := 0
      else Mode := 0;
      Inc(TCombatPredictor(FPredictor).FWork);
      V := TAbstractUnit(FUnit).GetCombatValue(TAbstractUnit(U.FUnit), Mode);
      if V < 0 then V := 0;
      { Original initializes both C and D to zero in the wall cache. }
      TQuadItemList(FWallTargets).AddABCD(Integer(U), V, 0, 0);
      Inc(FWallCombatValue, V);
    end;
  end;
  FWallTargetsInvalid := 0;
end;

procedure TCombatPredictorUnit.InvalidateTargets;
begin FTargetsInvalid := 1; FWallTargetsInvalid := 1; end;

procedure TCombatPredictorUnit.ResetCombat;
begin
  FHitPoints := FInitialHitPoints;
  FCombatRounds := 0;
  FStatus := [];
end;

procedure TCombatPredictorUnit.ResetRoundTargets;
begin
  TQuadItemList(FRoundTargets).Clear;
  FCombatValueTotal := 0;
  FIncomingCombatValue := 0;
  FIneffectiveAttackers := 0;
end;

procedure TCombatPredictorUnit.SetupRoundTargets(A1: Byte);
var I, V: Integer; U: TCombatPredictorUnit; Q: TQuadItemList;
begin
  if FEnabled <> 0 then
  begin
    if A1 <> 0 then
    begin
      if FWallTargetsInvalid <> 0 then UpdateWallTargets;
      TQuadItemList(FRoundTargets).Assign(TQuadItemList(FWallTargets));
    end
    else
    begin
      if FTargetsInvalid <> 0 then UpdateTargets;
      TQuadItemList(FRoundTargets).Assign(TQuadItemList(FTargets));
    end;
    for I := TQuadItemList(FRoundTargets).Count - 1 downto 0 do
    begin
      { Read the round list directly. }
      U := TCombatPredictorUnit(TQuadItemList(FRoundTargets).List^[I].A);
      if U.FEnabled <> 0 then
      begin
        V := TQuadItemList(FRoundTargets).List^[I].B;
        if V > 0 then
        begin
          Inc(U.FIncomingCombatValue, V);
          Inc(FCombatValueTotal, V);
        end
        else
        begin
          Inc(U.FIneffectiveAttackers);
          TQuadItemList(FRoundTargets).Delete(I);
        end;
      end
      else TQuadItemList(FRoundTargets).Delete(I);
    end;
  end;
end;

procedure TCombatPredictorUnit.UpdateRoundTargetPriority;
var I: Integer;
begin
  if FEnabled <> 0 then
  begin
    FTargetPriority := 0;
    for I := TQuadItemList(FRoundTargets).Count - 1 downto 0 do
      Inc(FTargetPriority, TCombatPredictorUnit(TQuadItemList(FRoundTargets).List^[I].A).FIneffectiveAttackers);
  end
  else FTargetPriority := 0;
end;

function P3CompareRoundTargets(const A, B: TQuadItem): Integer;
begin Result := A.D - B.D; end;

procedure TCombatPredictorUnit.SortRoundTargets;
var I, V, Priority: Integer; U: TCombatPredictorUnit;
begin
  for I := TQuadItemList(FRoundTargets).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TQuadItemList(FRoundTargets).List^[I].A);
    V := TQuadItemList(FRoundTargets).List^[I].B;
    if U.FCombatValueTotal <> 0 then
      Priority := (V * 100 * 1000) div U.FIncomingCombatValue + U.FTargetPriority * 100 + V
    else Priority := 0;
    TQuadItemList(FRoundTargets).List^[I].D := Priority;
  end;
  TQuadItemList(FRoundTargets).Sort(P3CompareRoundTargets);
end;

function TCombatPredictorUnit.ExecuteRound: Boolean;
var I: Integer; U: TCombatPredictorUnit;
begin
  I := TQuadItemList(FRoundTargets).Count;
  Result := False;
  if I <> 0 then Inc(FCombatRounds);
  while (I <> 0) and not Result do
  begin
    Dec(I);
    U := TCombatPredictorUnit(TQuadItemList(FRoundTargets).List^[I].A);
    if U.FHitPoints > 0 then
    begin
      Dec(U.FHitPoints, TQuadItemList(FRoundTargets).List^[I].B);
      Result := True;
    end
    else TQuadItemList(FRoundTargets).Delete(I);
  end;
end;

procedure TCombatPredictorUnit.FinishCombat;
begin if FHitPoints <= 0 then FStatus := FStatus + [usDestroyed]; end;

function TCombatPredictorUnitList.GetUnits(A1: Integer): TCombatPredictorUnit;
begin Result := TCombatPredictorUnit(List^[A1]); end;

function TCombatPredictorUnitList.IndexOfUnit(A1: TAbstractUnit): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TCombatPredictorUnit(List^[Result]).FUnit = A1 then Exit;
  end;
  Result := -1;
end;

function TCombatPredictorUnitList.IndexOfCPUID(A1: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TCombatPredictorUnit(List^[Result]).FCPUID = A1 then Exit;
  end;
  Result := -1;
end;

procedure TCombatPredictorSide.Reset;
begin FillChar(FStrength, SizeOf(FStrength), 0); end;

function TCombatPredictorSide.GetStrength(A1: TDamageType): Integer;
begin Result := FStrength[A1]; end;

function TCombatPredictorSide.GetStrengthMax(A1: TDamageTypes): Integer;
var D: TDamageType;
begin
  Result := 0;
  for D := Low(TDamageType) to High(TDamageType) do
    if (D in A1) and (Result < FStrength[D]) then Result := FStrength[D];
end;

constructor TCombatPredictor.Create;
begin
  inherited Create;
  FAllUnits := TCombatPredictorUnitList.Create;
  FActiveUnits := TCombatPredictorUnitList.Create;
  FSides[0] := TCombatPredictorSide.Create;
  FSides[1] := TCombatPredictorSide.Create;
end;

destructor TCombatPredictor.Destroy;
begin
  Reset;
  TObject(FAllUnits).Free;
  TObject(FActiveUnits).Free;
  TObject(FSides[0]).Free;
  TObject(FSides[1]).Free;
  inherited Destroy;
end;

procedure TCombatPredictor.Reset;
var I: Integer;
begin
  for I := TList(FAllUnits).Count - 1 downto 0 do TObject(TList(FAllUnits).List^[I]).Free;
  FWall := nil;
  TList(FAllUnits).Count := 0;
  TList(FActiveUnits).Count := 0;
  TList(FSides[0]).Count := 0;
  TList(FSides[1]).Count := 0;
  FSuperiority := -1;
  FEfficiency := -1;
  FNextCPUID := 0;
end;

function TCombatPredictor.CreateUniqueCPUID: Integer;
begin Result := FNextCPUID; Inc(FNextCPUID); end;

procedure TCombatPredictor.EnableAllUnits; { Near miss: item register and common-load reuse differ after three variants. }
var I: Integer;
begin
  for I := TList(FAllUnits).Count - 1 downto 0 do
    if TCombatPredictorUnit(TList(FAllUnits).List^[I]).FEnabled = 0 then
    begin
      TCombatPredictorUnit(TList(FAllUnits).List^[I]).FEnabled := 1;
      FInvalid := 1;
    end;
end;

procedure TCombatPredictor.Validate;
begin if FInvalid <> 0 then Execute; end;

procedure TCombatPredictor.ResetCombat;
var I: Integer;
begin
  FInvalid := 1;
  FSuperiority := -1;
  FEfficiency := -1;
  FRound := 0;
  for I := TList(FAllUnits).Count - 1 downto 0 do TCombatPredictorUnit(TList(FAllUnits).List^[I]).ResetCombat;
end;

procedure TCombatPredictor.SetupCombat(A1: Byte);
var I: Integer; U: TCombatPredictorUnit;
begin
  TList(FActiveUnits).Clear;
  if TCombatPredictorSide(FSides[0]).F_CombatPredictorSide_10[0] <> 0 then
  begin
    for I := TList(FSides[1]).Count - 1 downto 0 do TCombatPredictorUnit(TList(FSides[1]).List^[I]).InvalidateTargets;
    TCombatPredictorSide(FSides[0]).F_CombatPredictorSide_10[0] := 0;
  end;
  if TCombatPredictorSide(FSides[1]).F_CombatPredictorSide_10[0] <> 0 then
  begin
    for I := TList(FSides[0]).Count - 1 downto 0 do TCombatPredictorUnit(TList(FSides[0]).List^[I]).InvalidateTargets;
    TCombatPredictorSide(FSides[1]).F_CombatPredictorSide_10[0] := 0;
  end;
  for I := TList(FAllUnits).Count - 1 downto 0 do TCombatPredictorUnit(TList(FAllUnits).List^[I]).ResetRoundTargets;
  for I := TList(FAllUnits).Count - 1 downto 0 do TCombatPredictorUnit(TList(FAllUnits).List^[I]).SetupRoundTargets(Byte(A1));
  for I := TList(FAllUnits).Count - 1 downto 0 do TCombatPredictorUnit(TList(FAllUnits).List^[I]).UpdateRoundTargetPriority;
  for I := TList(FAllUnits).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FAllUnits).List^[I]);
    if (U.FEnabled <> 0) and (TQuadItemList(U.FRoundTargets).Count <> 0) then
    begin
      U.SortRoundTargets;
      TList(FActiveUnits).Add(U);
    end;
  end;
end;

function TCombatPredictor.ExecuteCombatRound: Boolean;
var U: TCombatPredictorUnit; I: Integer;
begin
  Result := False;
  for I := TList(FActiveUnits).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FActiveUnits).List^[I]);
    if not U.ExecuteRound then TList(FActiveUnits).Delete(I)
    else Result := True;
  end;
  for I := TList(FActiveUnits).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FActiveUnits).List^[I]);
    if U.FHitPoints <= 0 then TList(FActiveUnits).Delete(I);
  end;
  if Result then Inc(FRound);
end;

function TCombatPredictor.CanPassWall: Boolean;
var I: Integer;
begin
  try
    Result := False;
    I := TList(FAllUnits).Count;
    while not Result and (I <> 0) do
    begin
      Dec(I);
      if TCombatPredictorUnitList(FAllUnits).GetUnits(I).FUnit <> nil then
        Result := wcWallPassing in TAbstractUnit(TCombatPredictorUnitList(FAllUnits).GetUnits(I).FUnit).GetWallCombatFeatures;
    end;
  except
    Result := False;
  end;
end;

procedure TCombatPredictor.FinishCombat;
var Wall: TCombatPredictorUnit; I: Integer; Surviving, Hits: array[0..1] of Integer; U: TCombatPredictorUnit;
begin
  FillChar(Surviving, SizeOf(Surviving), 0);
  FillChar(Hits, SizeOf(Hits), 0);
  for I := TList(FAllUnits).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FAllUnits).List^[I]);
    U.FinishCombat;
    if not (usDestroyed in U.FStatus) then Inc(Surviving[U.FSide]);
    Inc(Hits[U.FSide], U.FHitPoints);
  end;
  if (Surviving[1] = 0) and (Surviving[0] = 0) then
    if Hits[0] >= Hits[1] then FResult := 3 else FResult := 4
  else if Surviving[1] = 0 then FResult := 3
  else
  begin
    Wall := TCombatPredictorUnit(FWall);
    if (Wall <> nil) and (Wall.FHitPoints > 0) then
      if (Surviving[1] = 1) and CanPassWall then FResult := 3 else FResult := 8
    else if Surviving[0] = 0 then FResult := 4 else FResult := 2;
  end;
  TList(FActiveUnits).Clear;
end;

function TCombatPredictor.Execute: TCombatResult;
begin
  if FWall <> nil then
  begin
    ResetCombat;
    SetupCombat(1);
    while (TCombatPredictorUnit(FWall).FHitPoints > 0) and ExecuteCombatRound do;
    if TCombatPredictorUnit(FWall).FHitPoints <= 0 then
    begin
      SetupCombat(0);
      while ExecuteCombatRound do;
    end;
    FinishCombat;
  end
  else
  begin
    ResetCombat;
    SetupCombat(0);
    while ExecuteCombatRound do;
    FinishCombat;
  end;
  AoWHSMap.FAIExecuter.UseProcessTime(FWork * 58);
  Result := TCombatResult(FResult);
  FInvalid := 0;
end;

procedure TCombatPredictor.DeleteUnit(A1: TAbstractUnit);
var I, J: Integer; U: TCombatPredictorUnit; D: TDamageType;
begin
  I := TCombatPredictorUnitList(FAllUnits).IndexOfUnit(A1);
  if I <> -1 then
  begin
    U := TCombatPredictorUnitList(FAllUnits).GetUnits(I);
    J := TCombatPredictorUnitList(FSides[U.FSide]).IndexOfUnit(A1);
    if J <> -1 then
    begin
      if TCombatPredictorUnitList(FSides[U.FSide]).GetUnits(J) = FWall then FWall := nil;
      TList(FSides[U.FSide]).Delete(J);
      TCombatPredictorSide(FSides[U.FSide]).F_CombatPredictorSide_10[0] := 1;
      { Original adds strength when deleting a unit. }
      for D := Low(TDamageType) to High(TDamageType) do
        Inc(TCombatPredictorSide(FSides[U.FSide]).FStrength[D], TAbstractUnit(A1).GetStrength(D));
    end;
    FInvalid := 1;
    TList(FAllUnits).Delete(I);
    U.Free;
  end;
end;

function TCombatPredictor.AddUnitEx(A1: TAbstractUnit; A2: Byte; A3: Byte): TCombatPredictorUnit;
var U: TCombatPredictorUnit; D: TDamageType;
begin
  U := TCombatPredictorUnit.Create;
  U.Setup(A1, Integer(Self), A2);
  U.FBehindWall := A3;
  TList(FAllUnits).Add(U);
  TList(FSides[A2]).Add(U);
  TCombatPredictorSide(FSides[A2]).F_CombatPredictorSide_10[0] := 1;
  for D := Low(TDamageType) to High(TDamageType) do
    Inc(TCombatPredictorSide(FSides[A2]).FStrength[D], TAbstractUnit(A1).GetStrength(D));
  FInvalid := 1;
  Result := U;
end;

procedure TCombatPredictor.AddUnit(A1: TAbstractUnit);
begin AddUnitEx(A1, 0, 0); end;

procedure TCombatPredictor.AddUnits(A1: TUnitList);
var I: Integer;
begin
  for I := 0 to TUnitList(A1).Count - 1 do
    AddUnit(TUnitList(A1).GetUnit(I));
end;

procedure TCombatPredictor.AddOpponent(A1: TAbstractUnit; A2: Byte);
begin AddUnitEx(A1, 1, Byte(A2)); end;

procedure TCombatPredictor.AddOpponents(A1: Integer; A2: Byte);
var I: Integer;
begin
  for I := 0 to TUnitList(A1).Count - 1 do
    AddOpponent(TUnitList(A1).GetUnit(I), A2);
end;

procedure TCombatPredictor.AddWall(A1: TWallType);
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:38; Text:'D:\AoWDev\AoWE\inc\CombatPredictor.pas'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:23; Text:'Use DeleteWall instead!'#0); var Wall: TWallUnit; UnitObj: TCombatPredictorUnit;
begin













































































































































































  if A1 = wtNone then asm MOV ECX,$47D7; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  UnitObj := TCombatPredictorUnit(FWall);
  if UnitObj = nil then
  begin
    Wall := TWallUnit.Create(nil);
    Wall.SetWallType(A1);
    Inc(Wall.FHits, 5);
    Inc(Wall.FHitPoints, 5);
    FWall := AddUnitEx(Wall, 1, 0);
    Wall.Release;
  end
  else TWallUnit(UnitObj.FUnit).SetWallType(A1);
end;

procedure TCombatPredictor.DeleteWall;
var Wall: TCombatPredictorUnit;
begin
  Wall := TCombatPredictorUnit(FWall);
  if Wall <> nil then
  begin
    DeleteUnit(Wall.FUnit);
    FWall := nil;
  end;
end;

procedure TCombatPredictor.DeleteUnits;
var I: Integer;
begin
  for I := TList(FSides[0]).Count - 1 downto 0 do
    DeleteUnit(TCombatPredictorUnitList(FSides[0]).GetUnits(I).FUnit);
end;

procedure TCombatPredictor.DeleteOpponents;
var I: Integer;
begin
  for I := TList(FSides[1]).Count - 1 downto 0 do
    DeleteUnit(TCombatPredictorUnitList(FSides[1]).GetUnits(I).FUnit);
end;

procedure TCombatPredictor.InitAdjacentArmies(A1: TArmyHS; A2, A3, A4: Shortint);
var Level: TMapLevel; ArmyHS: TArmyHS; U: TAbstractUnit;
    Defender, Player, Relation, DefenderRelation: Byte; Side: TCombatSideIndex;
    Field: TMapField; I: Integer; Msg: TMapFieldMsg; Walk: THNWalkData;
begin
  AddUnits(A1.FArmy);
  Level := AoWHSMap.MapContainer.GetMapLevel(A4);
  with A1.FArmy do
  begin
    Player := FPlayer;
    Relation := FIndependentRelation;
  end;
  Defender := TAoWMapField(Level.GetField(A2, A3)).GetPlayer;
  DefenderRelation := TAoWMapField(Level.GetField(A2, A3)).GetIndependentRelation;
  if Defender <> $FF then
  begin
    Msg.MsgID := $1123;
    Msg.Param[0] := Integer(Level.GetField(A2, A3));
    Msg.Result := 0;
    Level.GetField(A2, A3).SendMapFieldMsg(Msg);
    if TWallType(Msg.Result) <> wtNone then AddWall(TWallType(Msg.Result));
    InitHNWalk(Walk, A2, A3, 0);
    while Walk.Radius <= 1 do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      begin
        ArmyHS := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
        if (ArmyHS <> nil) and (ArmyHS <> A1) then
        begin
          Side := GetCombatSide(Player, Relation, Defender, DefenderRelation, ArmyHS.FArmy.FPlayer, ArmyHS.FArmy.FIndependentRelation);
          if Side <> csNeutral then
          begin
            Field := Level.GetField(A2, A3);
            Msg.MsgID := $1123;
            Msg.Param[0] := Integer(Level.GetField(Walk.X, Walk.Y));
            Msg.Result := 0;
            Field.SendMapFieldMsg(Msg);
            for I := 0 to ArmyHS.FArmy.Count - 1 do
            begin
              U := ArmyHS.FArmy.GetUnit(I);
              if U.ValidTerrain(Field.TerrainType, Field.OverlayType) then
                AddUnitEx(U, Ord(Side), Ord(TWallType(Msg.Result) <> wtNone));
            end;
          end;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end;
end;

procedure TCombatPredictor.InitAdjacentOpponents(A1, A2: Byte; A3, A4, A5: Shortint);
var Level: TMapLevel; ArmyHS: TArmyHS; U: TAbstractUnit;
    DefenderRelation, Defender: Byte; Side: TCombatSideIndex;
    Field: TMapField; I: Integer; Msg: TMapFieldMsg; Walk: THNWalkData;
begin
  Level := AoWHSMap.MapContainer.GetMapLevel(A5);
  Defender := TAoWMapField(Level.GetField(A3, A4)).GetPlayer;
  DefenderRelation := TAoWMapField(Level.GetField(A3, A4)).GetIndependentRelation;
  if Defender <> $FF then
  begin
    Msg.MsgID := $1123;
    Msg.Param[0] := Integer(Level.GetField(A3, A4));
    Msg.Result := 0;
    Level.GetField(A3, A4).SendMapFieldMsg(Msg);
    if TWallType(Msg.Result) <> wtNone then AddWall(TWallType(Msg.Result));
    InitHNWalk(Walk, A3, A4, 0);
    while Walk.Radius <= 1 do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
      begin
        ArmyHS := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
        if ArmyHS <> nil then
        begin
          Side := GetCombatSide(A1, A2, Defender, DefenderRelation, ArmyHS.FArmy.FPlayer, ArmyHS.FArmy.FIndependentRelation);
          if Side = csDefender then
          begin
            Field := Level.GetField(A3, A4);
            Msg.MsgID := $1123;
            Msg.Param[0] := Integer(Level.GetField(Walk.X, Walk.Y));
            Msg.Result := 0;
            Field.SendMapFieldMsg(Msg);
            for I := 0 to ArmyHS.FArmy.Count - 1 do
            begin
              U := ArmyHS.FArmy.GetUnit(I);
              if U.ValidTerrain(Field.TerrainType, Field.OverlayType) then
                AddUnitEx(U, Ord(Side), Ord(TWallType(Msg.Result) <> wtNone));
            end;
          end;
        end;
      end;
      WalkToNextHN(Walk);
    end;
  end;
end;

function TCombatPredictor.GetSuperiority: Integer;
var U: TCombatPredictorUnit; I, Total, Left, Value: Integer;
begin
  if FSuperiority = -1 then
    if FResult = 3 then
    begin
      Total := 0; Left := 0;
      for I := TList(FSides[0]).Count - 1 downto 0 do
      begin
        U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
        Value := U.FCombatValueTotal;
        Inc(Total, Value);
        if U.FHitPoints > 0 then Inc(Left, U.FHitPoints * Value div U.FInitialHitPoints);
      end;
      if Total = Left then FSuperiority := 999
      else if Left > 0 then FSuperiority := Total * 100 div (Total - Left)
      else FSuperiority := 100;
    end
    else if FResult in [2, 4, 8] then
    begin
      Total := 0; Left := 0;
      for I := TList(FSides[1]).Count - 1 downto 0 do
      begin
        U := TCombatPredictorUnit(TList(FSides[1]).List^[I]);
        Value := U.FCombatValueTotal;
        Inc(Total, Value);
        if U.FHitPoints > 0 then Inc(Left, U.FHitPoints * Value div U.FInitialHitPoints);
      end;
      if Total = 0 then FSuperiority := 0
      else if Left > 0 then FSuperiority := (Total - Left) * 100 div Total
      else FSuperiority := 100;
    end
    else if FResult = 6 then FSuperiority := 200
    else FSuperiority := 0;
  Result := FSuperiority;
end;

function TCombatPredictor.GetEfficiency: Integer;
var Lost: array[0..1] of Integer; Side: Byte; I: Integer; U: TCombatPredictorUnit;
begin
  if FEfficiency = -1 then
  begin
    for Side := 0 to 1 do
    begin
      Lost[Side] := 0;
      for I := TList(FSides[Side]).Count - 1 downto 0 do
      begin
        U := TCombatPredictorUnit(TList(FSides[Side]).List^[I]);
        if usDestroyed in U.FStatus then
          Inc(Lost[Side], TAbstractUnit(U.FUnit).GetObtainValue)
        else if U.FHitPoints < U.FInitialHitPoints then
          Inc(Lost[Side], Round((TAbstractUnit(U.FUnit).GetObtainValue * U.FHitPoints) / (U.FInitialHitPoints * 2)));
      end;
    end;
    if Lost[0] <> 0 then FEfficiency := Lost[1] * 100 div Lost[0]
    else if (Lost[1] <> 0) or (TList(FSides[1]).Count = 0) then FEfficiency := 999
    else FEfficiency := 100;
  end;
  Result := FEfficiency;
end;

function P3CompareRequiredUnits(const A, B: TDoubleItem): Integer;
begin Result := B.B - A.B; end;

procedure TCombatPredictor.ListRequiredUnitsEx(A1, A2, A3: TUnitList; A4: Integer);
var List: TDoubleItemList; I, Total, Score, Budget: Integer; U: TCombatPredictorUnit;
    Maximum, Minimum, Count, Previous: Integer; Done: Boolean;
begin
  EnableAllUnits;
  Validate;
  if (GetSuperiority > A4) and (TList(FSides[0]).Count <> 0) then
  begin
    List := TDoubleItemList.Create;
    Total := 0;
    for I := TList(FSides[0]).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
      if U.FIncomingCombatValue <> 0 then
        Score := U.FCombatValueTotal * 100 div U.FIncomingCombatValue
      else Score := 9999;
      Inc(Total, U.FCombatValueTotal);
      List.AddAB(Integer(U), Score);
    end;
    List.Sort(P3CompareRequiredUnits);
    Minimum := 1;
    Maximum := List.Count;
    if (A4 <> 0) and (GetSuperiority <> 0) then
    begin
      Budget := Round((100 / A4 - 100 / GetSuperiority) * (Total * 0.65));
      Count := List.Count;
      while (Count > 1) and (Budget > 0) do
      begin
        Dec(Count);
        Dec(Budget, TCombatPredictorUnit(List[Count].A).FCombatValueTotal);
      end;
      if Count < Minimum then Count := Minimum;
      if Count >= Maximum then Count := Maximum - 1;
    end
    else Count := Maximum - 1;
    Previous := Maximum;
    Done := List.Count <= 1;
    while not Done do
    begin
      for I := Count - 1 downto 0 do TCombatPredictorUnit(List.List^[I].A).SetEnabled(1);
      for I := List.Count - 1 downto Count do TCombatPredictorUnit(List.List^[I].A).SetEnabled(0);
      Execute;
      if GetSuperiority >= A4 then
      begin
        Previous := Count;
        Done := Minimum = Previous;
        if not Done then
        begin
          Dec(Count);
          if (Count > Minimum) and (GetSuperiority - A4 > 300 div List.Count) then Dec(Count);
          if (Count > Minimum) and (GetSuperiority - A4 > 600 div List.Count) then Dec(Count);
        end;
      end
      else if GetSuperiority < A4 then
      begin
        Minimum := Count + 1;
        Done := Previous = Minimum;
        if not Done then
        begin
          Inc(Count);
          if (Count + 1 <> Previous) and (A4 - GetSuperiority > 300 div List.Count) then Inc(Count);
          if (Count + 1 <> Previous) and (A4 - GetSuperiority > 600 div List.Count) then Inc(Count);
        end;
      end;
    end;
    if A1 <> nil then
      for I := 0 to Minimum - 1 do A1.AddUnit(TAbstractUnit(TCombatPredictorUnit(List.List^[I].A).FUnit));
    if A2 <> nil then
      for I := List.Count - 1 downto Minimum do A2.AddUnit(TAbstractUnit(TCombatPredictorUnit(List.List^[I].A).FUnit));
    if A3 <> nil then
      for I := List.Count - 1 downto Minimum do
      begin
        U := TCombatPredictorUnit(List.List^[I].A);
        if U.FCombatValueTotal <= 0 then A3.AddUnit(TAbstractUnit(U.FUnit));
      end;
    List.Free;
  end
  else
    for I := TList(FSides[0]).Count - 1 downto 0 do
    begin
      U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
      if U.FCombatValueTotal = 0 then
      begin
        if A3 <> nil then A3.AddUnit(TAbstractUnit(U.FUnit));
      end
      else if A1 <> nil then A1.AddUnit(TAbstractUnit(U.FUnit));
    end;
end;

procedure TCombatPredictor.ListRequiredUnits(A1: TUnitList; A2: Integer);
begin ListRequiredUnitsEx(TUnitList(A1), nil, nil, A2); end;

procedure TCombatPredictor.ListOptionalUnits(A1: Integer; A2: Integer);
begin ListRequiredUnitsEx(nil, TUnitList(A1), nil, A2); end;

procedure TCombatPredictor.ListUselessUnits(A1: Integer);
var I: Integer; U: TCombatPredictorUnit;
begin
  for I := TList(FSides[0]).Count - 1 downto 0 do
  begin
    U := TCombatPredictorUnit(TList(FSides[0]).List^[I]);
    if U.FCombatValueTotal <= 0 then TUnitList(A1).AddUnit(TAbstractUnit(U.FUnit));
  end;
end;

function TCombatPredictor.Usefullness(A1: TAbstractUnit): Integer;
var Wall, U, Target: TCombatPredictorUnit; I: Integer; AllDead, Useful: Boolean;
begin
  EnableAllUnits;
  Validate;
  U := TCombatPredictorUnit.Create;
  U.Setup(A1, Integer(Self), 0);
  Wall := TCombatPredictorUnit(FWall);
  if (Wall <> nil) and (Wall.FHitPoints > 0) then
  begin
    U.UpdateWallTargets;
    Result := U.FWallCombatValue;
    Useful := False;
    I := TQuadItemList(U.FWallTargets).Count;
    while (I <> 0) and not Useful do
    begin
      Dec(I);
      if TQuadItemList(U.FWallTargets).List^[I].B > 0 then
      begin
        Target := TCombatPredictorUnit(TQuadItemList(U.FWallTargets).List^[I].A);
        Useful := (Target = TCombatPredictorUnit(FWall)) and (Target.FHitPoints > 0);
      end;
    end;
    if Useful then Result := Result or $800000;
  end
  else
  begin
    U.UpdateTargets;
    Result := U.FCombatValue;
    I := TList(FSides[0]).Count;
    AllDead := True;
    while (I <> 0) and AllDead do
    begin
      Dec(I);
      AllDead := usDestroyed in TCombatPredictorUnitList(FSides[0]).GetUnits(I).FStatus;
    end;
    Useful := False;
    I := TQuadItemList(U.FTargets).Count;
    while (I <> 0) and not Useful do
    begin
      Dec(I);
      if TQuadItemList(U.FTargets).List^[I].B > 0 then
      begin
        Target := TCombatPredictorUnit(TQuadItemList(U.FTargets).List^[I].A);
        Useful := (Target <> TCombatPredictorUnit(FWall)) and
          ((Target.FHitPoints > 0) or (FResult = 3) or AllDead);
      end;
    end;
    if Useful then Result := Result or $800000;
  end;
  U.Free;
end;








