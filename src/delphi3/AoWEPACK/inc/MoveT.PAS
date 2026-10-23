procedure MaximizeMovePointTable(var Table; const Other);
type
  TMoveTable = array[0..15, 0..15] of Shortint;
var
  I, J: Integer;
  OldValue, Value: Shortint;
begin
  for I := 0 to 12 do
    for J := 0 to 15 do
    begin
      OldValue := TMoveTable(Table)[J, I];
      Value := TMoveTable(Other)[J, I];
      if (OldValue <> -1) and
        ((OldValue < Value) or
        (Value = -1)) then
        TMoveTable(Table)[J, I] := Value;
    end;
end;

constructor TSubMove.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMovePointLines := TDoubleItemList.Create;
  FOrigin.XYL := $FFFFFF;
  FLocation.XYL := $FFFFFF;
end;

destructor TSubMove.Destroy;
begin
  FMovePointLines.Free;
  inherited Destroy;
end;

procedure TSubMove.AddMovePointLine(Direction, Count: Integer);
begin
  FMovePointLines.AddAB(Direction, Count);
end;

function TSubMoveList.GetSubMove(Index: Integer): TSubMove;
begin
  Result := FChildren.List^[Index];
end;

function TSubMoveList.DeleteXYL(Location: Integer): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    if Location = TSubMove(FChildren.List^[I]).FLocation.XYL then
    begin
      TSubMove(FChildren.List^[I]).Free;
      Inc(Result);
    end;
end;

procedure TSubMoveList.Delete(Index: Integer);
begin
  TSubMove(FChildren.List^[Index]).Free;
end;

function TSubMoveList.IndexOfXYL(Location: Integer): Integer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if Location = TSubMove(FChildren.List^[Result]).FLocation.XYL then Exit;
  end;
  Result := -1;
end;

constructor TMoveControlSettings.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FProcessedMapFields := TList.Create;
  FPath := TMovepath.Create;
  FSubMoves := TSubMoveList.Create(nil);
  FUnits := TUnitUserList.Create(nil);
  Reset;
end;

destructor TMoveControlSettings.Destroy;
begin
  Clear;
  FProcessedMapFields.Free;
  FSubMoves.Free;
  FPath.Free;
  FUnits.Free;
  inherited Destroy;
end;

procedure TMoveControlSettings.Clear;
var I: Integer;
begin
  FPath.Clear;
  FProcessedMapFields.Clear;
  for I := 0 to FLevelCount - 1 do ReallocMem(FLevelData^[I], 0);
  ReallocMem(FRowOffsets, 0);
  ReallocMem(FLevelData, 0);
  FWidth := 0;
  FHeight := 0;
  FLevelCount := 0;
end;

function TMoveControlSettings.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;

function TMoveControlSettings.Release: Integer;
begin
  Dec(FRefCount);
  Result := FRefCount;
  if FRefCount = 0 then Destroy;
end;

procedure TMoveControlSettings.ResetState;
begin
  FStatus := mcssIdle;
end;

procedure TMoveControlSettings.Reset;
var I: Integer;
begin
  FPath.Clear;
  FSubMoves.Clear;
  FProcessedMapFields.Clear;
  FMovePointsMax := $FFF;
  FillChar(FMovePointTable, SizeOf(FMovePointTable), -1);
  for I := 0 to FLevelCount - 1 do
    if FLevelData^[I] <> nil then
      FillInt(FLevelData^[I]^, FWidth * FHeight, $FFFFFF);
  FMode := [];
  FPlayer := -1;
  FSourceX := -1;
  FSourceY := -1;
  FSourceL := -1;
  FDestinationX := -1;
  FDestinationY := -1;
  FDestinationL := -1;
  FStatus := mcssIdle;
  FUnits.Clear;
end;

procedure TMoveControlSettings.SetSourcePos(X, Y, L: Integer);
begin
  FSourceX := X;
  FSourceY := Y;
  FSourceL := L;
end;

procedure TMoveControlSettings.SetDestinationPos(X, Y, L: Integer);
begin
  FDestinationX := X;
  FDestinationY := Y;
  FDestinationL := L;
end;

procedure TMoveControlSettings.SetupArmy(Army: TArmyHS; Selection: Byte);
begin
  FArmyHS := Army;
  FSelection := Selection;
  FUnits.AddUnitsEx(Army.FArmy, Selection);
  FSourceX := Army.Xhx;
  FSourceY := Army.Yhx;
  FSourceL := Army.Lhx;
  FPlayer := Army.FArmy.FPlayer;
  Army.FArmy.CreateMovePointTable(Selection, FMovePointTable);
  if AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman then FMode := FMode + [mmAI];
end;

procedure TMoveControlSettings.SetupLevel(Level: Integer);
begin
  if FLevelData^[Level] = nil then
  begin
    ReallocMem(FLevelData^[Level], FWidth * FHeight * 4);
    FillInt(FLevelData^[Level]^, FWidth * FHeight, $FFFFFF);
  end;
end;

procedure TMoveControlSettings.SetupMovePointData(Width, Height, LevelCount: Integer);
var
  I, RowSize, Offset: Integer;
begin
  if (Width <> FWidth) or (Height <> FHeight) or (LevelCount <> FLevelCount) then
  begin
    Clear;
    FWidth := Width;
    FHeight := Height;
    FLevelCount := LevelCount;
    FMovePointsClear := True;
    Offset := 0;
    RowSize := Width * 4;
    ReallocMem(FRowOffsets, Height * 4);
    for I := 0 to Height - 1 do
    begin
      FRowOffsets^[I] := Offset;
      Inc(Offset, RowSize);
    end;
    ReallocMem(FLevelData, LevelCount * 4);
    FillChar(FLevelData^, LevelCount * 4, 0);
    for I := 1 to 6 do
    begin
      FEvenOffsets[I] := HNtoXYTable[0, I].X * 4 + HNtoXYTable[0, I].Y * (Width * 4);
      FOddOffsets[I] := HNtoXYTable[1, I].X * 4 + HNtoXYTable[1, I].Y * (Width * 4);
    end;
  end
  else ClearMovePoints;
end;

procedure TMoveControlSettings.ClearMovePoints;
var I: Integer;
begin
  if not FMovePointsClear then
  begin
    for I := 0 to FLevelCount - 1 do
      if FLevelData^[I] <> nil then
        FillInt(FLevelData^[I]^, FWidth * FHeight, $FFFFFF);
    FMovePointsClear := True;
  end;
end;

function TMoveControlSettings.GetMovePoints(X, Y, L: Integer): Integer;
begin
  if FLevelData^[L] <> nil then
    Result := PInteger(FRowOffsets^[Y] + X * 4 + Integer(FLevelData^[L]))^
  else Result := $FFFFFF;
end;

procedure TMoveControlSettings.SetMovePoints(X, Y, L, Value: Integer);
begin
  PInteger(FRowOffsets^[Y] + X * 4 + Integer(FLevelData^[L]))^ := Value;
end;

function TMoveControlSettings.GetMovePointLevelData(Level: Integer): PIntegerArray;
begin
  Result := FLevelData^[Level];
end;

function TMoveControlSettings.GetMovePointsXYL(Location: Integer): Integer;
begin
  if FLevelData^[TXYL(Location).L] <> nil then
    Result := PInteger(FRowOffsets^[TXYL(Location).Y] + TXYL(Location).X * 4 +
      Integer(FLevelData^[TXYL(Location).L]))^
  else Result := $FFFFFF;
end;

procedure TMoveControlSettings.SetMovePointsXYL(Location, Value: Integer);
begin
  PInteger(FRowOffsets^[TXYL(Location).Y] + TXYL(Location).X * 4 +
    Integer(FLevelData^[TXYL(Location).L]))^ := Value;
end;

constructor TMoveControl.Create(AOwner: THSMap);
begin
  inherited Create;
  FMap := AOwner;
  FGapStarts := TXYLList.Create;
  FGapEnds := TXYLList.Create;
  FDirectRoute := TXYLList.Create;
end;

destructor TMoveControl.Destroy;
begin
  FGapStarts.Free;
  FGapEnds.Free;
  FDirectRoute.Free;
  inherited Destroy;
end;

procedure TMoveControl.Clear;
begin
  Deactivate;
  FPlayer := -1;
  FMapLevel := nil;
  FSourceX := -1;
  FSourceY := -1;
  FSourceL := -1;
  FDestinationX := -1;
  FDestinationY := -1;
  FDestinationL := -1;
  FProcessedCount := 0;
  FOnMovePoint := DefaultMoveOnMovePointProc;
  FProcessedMapFields := nil;
end;

procedure TMoveControl.SetMapL(Level: TMapLevel);
begin
  if Level <> FMapLevel then
  begin
    FMapLevel := Level;
    System.Move(FMapLevel.FHNOffsets, FFieldOffsets, SizeOf(FFieldOffsets));
  end;
end;

function TMoveControl.DefaultMoveOnMovePointProc(MapF: TAoWMapField; MoveOverCode: Integer): Integer;
var Overlay, Points: Integer;
begin
  Overlay := MapF.OverlayType;
  Points := FMovePointTable[MapF.TerrainType][Overlay];
  if MapF.FFieldFlags and $4000 <> 0 then Points := MapF.CanMoveOn(Self, Points, MoveOverCode);
  Result := Points;
end;

function TMoveControl.FindSubMoveOrigin(MapF: TAoWMapField): TAoWMapField;
var
  Best, Points, I: Integer;
  SubMove: TSubMove;
  Settings: TMoveControlSettings;
begin
  Best := $FFFFFF;
  Result := nil;
  I := 0;
  Settings := FSettings;
  while I < Settings.FSubMoves.Count do
  begin
    SubMove := Settings.FSubMoves.GetSubMove(I);
    if (MapF.Xhx = SubMove.FLocation.X) and (MapF.Yhx = SubMove.FLocation.Y) and
      (MapF.Lhx = SubMove.FLocation.L) then
    begin
      Points := Settings.GetMovePoints(SubMove.FOrigin.X, SubMove.FOrigin.Y, SubMove.FOrigin.L);
      if Points <= Best then
      begin
        { After pushing L, the original stack slot holds Self, not Result. }
        Result := TAoWMapField(FMap.MapContainer.GetField(
          SubMove.FOrigin.X, SubMove.FOrigin.Y, SubMove.FOrigin.L));
        Best := Points;
      end;
    end;
    Inc(I);
  end;
end;

function TMoveControl.CalculateMovePointLine(MapF: TAoWMapField; Direction, MoveOverCode: Integer): Integer;
var
  Count, Points, OverCode: Integer;
  Data: PInteger;
  Field: TAoWMapField;
  ContinueMove: Boolean;
  Cost: Integer;
begin
  Count := 0;
  ContinueMove := True;
  Field := MapF;
  Data := PInteger(Integer(FSettings.FLevelData^[Field.Lhx]) +
    FSettings.FRowOffsets^[Field.Yhx] + Field.Xhx * 4);
  Points := Data^;
  OverCode := MoveOverCode;
  while ContinueMove do
  begin
    Data := PInteger(FPointOffsets[Integer(Field.Xhx) and 1, Direction] + Integer(Data));
    Field := TAoWMapField(FFieldOffsets[Integer(Field.Xhx) and 1, Direction] + Integer(Field));
    Cost := FOnMovePoint(Field, OverCode);
    if Cost >= 0 then
    begin
      Inc(Points, Cost);
      if (Data^ > Points) and (Points <= FMovePointsLimit) then
      begin
        if (mmLogProcessedMapFields in FMode) and (Data^ = $FFFFFF) then FProcessedMapFields.Add(Field);
        if (Field.Xhx = FDestinationX) and (Field.Yhx = FDestinationY) and
          (Field.Lhx = FDestinationL) then FMovePointsLimit := Points;
        Data^ := Points;
        if Field.FFieldFlags and $2000 = 0 then
        begin
          ContinueMove := True;
          OverCode := 1;
        end
        else
        begin
          OverCode := Field.CanMoveOver(Self);
          ContinueMove := OverCode <> 0;
        end;
        if ContinueMove then Inc(Count);
      end
      else ContinueMove := False;
    end
    else ContinueMove := False;
  end;
  Result := Count;
end;

procedure TMoveControl.ProcessHexagon(MapF: TAoWMapField; Direction, Count: Integer); { Near miss: Direction spill and neighbor evaluation differ after three variants. }
var
  LeftCount, RightCount, OverCode, HT: Integer;
  Next: TAoWMapField;
begin
  Inc(FProcessedCount);
  if MapF.FFieldFlags and $2000 = 0 then OverCode := 1
  else OverCode := MapF.CanMoveOver(Self);
  LeftCount := CalculateMovePointLine(MapF, P5SideDirections[Direction, 0], OverCode);
  RightCount := CalculateMovePointLine(MapF, P5SideDirections[Direction, 1], OverCode);
  if Count and $FF <> 0 then
  begin
    Next := TAoWMapField(FFieldOffsets[Integer(MapF.Xhx) and 1, Direction] + Integer(MapF));
    if OverCode = 2 then ProcessHexagon(Next, Direction, Count + $FF)
    else ProcessHexagon(Next, Direction, Count - 1);
  end;
  if LeftCount <> 0 then
  begin
    HT := P5SideDirections[Direction, 0];
    Next := TAoWMapField(FFieldOffsets[Integer(MapF.Xhx) and 1, HT] + Integer(MapF));
    if OverCode = 2 then ProcessHexagon(Next, HT, LeftCount + $FF)
    else ProcessHexagon(Next, HT, LeftCount - 1);
  end;
  if RightCount <> 0 then
  begin
    HT := P5SideDirections[Direction, 1];
    Next := TAoWMapField(FFieldOffsets[Integer(MapF.Xhx) and 1, HT] + Integer(MapF));
    if OverCode = 2 then ProcessHexagon(Next, HT, RightCount + $FF)
    else ProcessHexagon(Next, HT, RightCount - 1);
  end;
  if Count and $100 <> 0 then
  begin
    HT := P5OppositeDirections[Direction];
    LeftCount := CalculateMovePointLine(MapF, P5SideDirections[HT, 0], OverCode);
    RightCount := CalculateMovePointLine(MapF, P5SideDirections[HT, 1], OverCode);
    if LeftCount <> 0 then
      ProcessHexagon(TAoWMapField(FFieldOffsets[Integer(MapF.Xhx) and 1, P5SideDirections[HT, 0]] + Integer(MapF)),
        P5SideDirections[HT, 0], LeftCount - 1);
    if RightCount <> 0 then
      ProcessHexagon(TAoWMapField(FFieldOffsets[Integer(MapF.Xhx) and 1, P5SideDirections[HT, 1]] + Integer(MapF)),
        P5SideDirections[HT, 1], RightCount - 1);
  end;
  if MapF.FFieldFlags and $8000 <> 0 then MapF.MoveExclusive(Self);
end;

function TMoveControl.ValidLocation(X, Y, L: Integer): Boolean; { Near miss: three variants retain a field temporary or change the method-pointer frame. }
var Field: TAoWMapField;
begin
  Field := TAoWMapField(FMap.MapContainer.GetField(X, Y, L));
  Result := FOnMovePoint(Field, 1) >= 0;
end;

procedure TMoveControl.ExecuteExternalMove(Source, Target: TAoWMapField; MovePoints: Integer);
var
  Points, Previous, Index: Integer;
  SubMove: TSubMove;
begin
  Points := FOnMovePoint(Target, Source.CanMoveOver(Self));
  if Points >= 0 then
  begin
    FSettings.SetupLevel(Target.Lhx);
    if MovePoints = -1 then Inc(Points, FSettings.GetMovePoints(Source.Xhx, Source.Yhx, Source.Lhx))
    else Points := FSettings.GetMovePoints(Source.Xhx, Source.Yhx, Source.Lhx) + MovePoints;
    Previous := FSettings.GetMovePoints(Target.Xhx, Target.Yhx, Target.Lhx);
    if (Points < Previous) and (Points <= FMovePointsLimit) then
    begin
      Index := FSettings.FSubMoves.IndexOfXYL(Target.GetXYL);
      if Index > FSettings.FSubMoveIndex then FSettings.FSubMoves.Delete(Index);
      if (mmLogProcessedMapFields in FMode) and (Previous = $FFFFFF) then FProcessedMapFields.Add(Target);
      FSettings.SetMovePoints(Target.Xhx, Target.Yhx, Target.Lhx, Points);
      if (Target.Xhx = FDestinationX) and (Target.Yhx = FDestinationY) and
        (Target.Lhx = FDestinationL) then FMovePointsLimit := Points;
      if (Target.FFieldFlags and $2000 = 0) or (Target.CanMoveOver(Self) <> 0) then
      begin
        SubMove := SetupSubMove(Target, Source);
        if Target.FFieldFlags and $8000 <> 0 then Target.MoveExclusive(Self);
        SubMove.Owner := FSettings.FSubMoves;
      end
      else
      begin
        SubMove := TSubMove.Create(nil);
        SubMove.FLocation.XYL := Target.GetXYL;
        SubMove.FOrigin.XYL := Source.GetXYL;
        SubMove.Owner := FSettings.FSubMoves;
      end;
    end;
  end;
end;

function TMoveControl.SetupMove: Boolean; { Near miss: Assert operand reuse differs after three variants; line preserved. }
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:28; Text:'D:\AoWDev\AoWE\inc\MoveT.PAS'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:31; Text:'Invalid settings (TMoveControl)'#0); var
  Field: TAoWMapField;
  SubMove: TSubMove;
begin
  FProcessedCount := 0;
  FSettings.ClearMovePoints;
  FSettings.FSubMoves.Clear;
  FSettings.FSubMoveIndex := 0;
  FSettings.FPath.Clear;
  if mmLogProcessedMapFields in FMode then
  begin
    FSettings.FProcessedMapFields.Count := 0;
    FSettings.FProcessedMapFields.Capacity := $1000;
  end;
  { Original bug: the Y bound also uses the map width. }
  if not ((FMapLevel <> nil) and (FSourceX >= 0) and (FSourceX < FMapLevel.Width) and






























































































































































































































































































































































































































































































































































































































































































































































    (FSourceY >= 0) and (FSourceY < FMapLevel.Width)) then asm MOV ECX,$7DBB; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  if ((FSettings.FSourceX <> FSettings.FDestinationX) or
    (FSettings.FSourceY <> FSettings.FDestinationY) or
    (FSettings.FSourceL <> FSettings.FDestinationL)) and
    ((FDestinationX = -1) or ValidLocation(FDestinationX, FDestinationY, FDestinationL)) then
  begin
    FSettings.SetupLevel(FSettings.FSourceL);
    if FSettings.FDestinationL <> -1 then FSettings.SetupLevel(FSettings.FDestinationL);
    if (FSourceL = FDestinationL) and (FMovePointsLimit > 40) and (FDestinationX <> -1) then
    begin
      FMovePointsLimit := GetMovePointsCostFast(FSourceX, FSourceY, FDestinationX, FDestinationY);
      if (FMovePointsLimit = -1) or (FMovePointsLimit > FSettings.FMovePointsMax) then
        FMovePointsLimit := FSettings.FMovePointsMax;
      AoWHSMap.FAIExecuter.UseProcessTime(FMovePointsLimit);
    end;
    FSettings.SetMovePoints(FSourceX, FSourceY, FSourceL, 0);
    Field := TAoWMapField(FMapLevel.GetField(FSourceX, FSourceY));
    if mmLogProcessedMapFields in FMode then FProcessedMapFields.Add(Field);
    SubMove := SetupSubMove(Field, nil);
    if Field.FFieldFlags and $8000 <> 0 then Field.MoveExclusive(Self);
    SubMove.Owner := FSettings.FSubMoves;
    AoWHSMap.FAIExecuter.UseProcessTime(100);
  end
  else
  begin
    FSettings.SetupLevel(FSettings.FSourceL);
    FSettings.SetMovePoints(FSourceX, FSourceY, FSourceL, 0);
    FSettings.FStatus := mcssProcessed;
  end;
  Result := True;
end;

function TMoveControl.SetupSubMove(MapF, Origin: TAoWMapField): TSubMove;
var
  SubMove: TSubMove;
  OverCode, Direction, I, Count, HT: Integer;
begin
  SubMove := TSubMove.Create(nil);
  SubMove.FLocation.XYL := MapF.GetXYL;
  if Origin <> nil then
  begin
    SubMove.FOrigin.XYL := Origin.GetXYL;
    if MapF.FFieldFlags and $2000 = 0 then OverCode := 1
    else OverCode := MapF.CanMoveOver(Self);
  end
  else OverCode := 1;
  if OverCode <> 0 then
  begin
    if FSettings.FDestinationX <> -1 then
    begin
      Direction := dHXtoHT(MapF.Xhx, MapF.Yhx, FSettings.FDestinationX, FSettings.FDestinationY);
      if Direction = 0 then Direction := 1;
    end
    else Direction := 1;
    for I := 0 to 2 do
    begin
      HT := P5OddDirections[Direction, I];
      Count := CalculateMovePointLine(MapF, HT, OverCode);
      if Count <> 0 then SubMove.AddMovePointLine(HT, Count);
    end;
    for I := 0 to 2 do
    begin
      HT := P5EvenDirections[Direction, I];
      Count := CalculateMovePointLine(MapF, HT, OverCode);
      if Count <> 0 then SubMove.AddMovePointLine(HT, Count);
    end;
  end;
  Result := SubMove;
end;

function TMoveControl.ProcessSubMove(SubMove: TSubMove): Boolean;
var
  X, Y, Count, Direction, Processed: Integer;
begin
  if SubMove.FMovePointLines.Count <> 0 then
  begin
    FSettings.SetupLevel(SubMove.FLocation.L);
    SetMapL(FMap.MapContainer.GetMapLevel(SubMove.FLocation.L));
    Direction := SubMove.FMovePointLines[0].A;
    Count := SubMove.FMovePointLines[0].B;
    CenterHNtoHX(SubMove.FLocation.X, SubMove.FLocation.Y, Direction, X, Y);
    SubMove.FMovePointLines.Delete(0);
    Processed := FProcessedCount;
    ProcessHexagon(TAoWMapField(FMapLevel.GetField(X, Y)), Direction, Count - 1);
    Processed := FProcessedCount - Processed;
    AoWHSMap.FAIExecuter.UseProcessTime(Round(Processed / 430 * 1000));
  end;
  Result := SubMove.FMovePointLines.Count = 0;
end;

function TMoveControl.Process: Boolean;
begin






















  Assert(mcsActivated in FStatus);
  case FSettings.FStatus of
    mcssIdle:
      begin
        SetupMove;
        FSettings.FStatus := mcssProcessing;
      end;
    mcssProcessing:
      begin
        if FSettings.FSubMoveIndex < FSettings.FSubMoves.Count then
          if ProcessSubMove(FSettings.FSubMoves.GetSubMove(FSettings.FSubMoveIndex)) then
            Inc(FSettings.FSubMoveIndex);
        if FSettings.FSubMoveIndex >= FSettings.FSubMoves.Count then FSettings.FStatus := mcssProcessed;
      end;
  end;
  Result := (FSettings.FStatus <> mcssProcessed) and (FSettings.FStatus <> mcssFailed);
end;

procedure TMoveControl.CalculatePathEx(Path: TMovepath; X, Y, L: Shortint); { Near miss: Self/field spills and neighbor locals differ after three variants. }
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:28; Text:'D:\AoWDev\AoWE\inc\MoveT.PAS'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:17; Text:'Assertion failure'#0); var
  Field, Previous, Neighbor: TAoWMapField;
  Points, Cost, OverCode, Parity, Direction: Integer;
  Failed, Found: Boolean;
begin










  if not (mcsActivated in FStatus) then asm MOV ECX,$7E4F; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  Path.Clear;
  Neighbor := nil;
  Failed := False;
  if L < FMap.MapContainer.LevelCount then
  begin
    SetMapL(FMap.MapContainer.GetMapLevel(L));
    Field := TAoWMapField(FMapLevel.GetField(X, Y));
    Points := FSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx);
    if Points <> $FFFFFF then
    begin
      while (Field <> nil) and
        ((Field.Xhx <> FSourceX) or (Field.Yhx <> FSourceY) or (Field.Lhx <> FSourceL)) and not Failed do
      begin
        Path.AddXYL(Field.Xhx, Field.Yhx, Field.Lhx);
        Parity := Field.Xhx and 1;
        Cost := FOnMovePoint(Field, 1);
        Found := False;
        Direction := 0;
        while not Found and (Direction <> 6) do
        begin
          Inc(Direction);
          Neighbor := TAoWMapField(FFieldOffsets[Parity, Direction] + Integer(Field));
          if FSettings.GetMovePoints(Neighbor.Xhx, Neighbor.Yhx, Neighbor.Lhx) = Points - Cost then
          begin
            if (Neighbor.Xhx = FSourceX) and (Neighbor.Yhx = FSourceY) and
              (Neighbor.Lhx = FSourceL) then OverCode := 1
            else if Neighbor.FFieldFlags and $2000 = 0 then OverCode := 1
            else OverCode := Neighbor.CanMoveOver(Self);
            if (OverCode <> 0) and ((Field.FFieldFlags and $4000 = 0) or
              (Field.CanMoveOn(Self, Cost, OverCode) <> -1)) then Found := True;
          end;
        end;
        if Found then
        begin
          Points := FSettings.GetMovePoints(Neighbor.Xhx, Neighbor.Yhx, Neighbor.Lhx);
          Previous := Neighbor;
        end
        else
        begin
          Previous := FindSubMoveOrigin(Field);
          if Previous <> nil then
            if Path.IndexOfXYL(Previous.Xhx, Previous.Yhx, Previous.Lhx) = -1 then
            begin
              Points := FSettings.GetMovePoints(Previous.Xhx, Previous.Yhx, Previous.Lhx);
              SetMapL(TMapLevel(Previous.Owner));
              Found := True;
            end;
        end;
        if (Previous <> nil) and Found then
          Path.List^[Path.Count - 1].Flag :=
            FSettings.GetMovePoints(Field.Xhx, Field.Yhx, Field.Lhx) - Points;
        Field := Previous;
        if not Found then Failed := True;
      end;
    end
    else Failed := True;
    if Failed then Path.Clear
    else if (Field <> nil) and (Points = 0) then Path.AddXYL(Field.Xhx, Field.Yhx, Field.Lhx);
    if aesExecuting in AoWHSMap.FAIExecuter.FStatus then AoWHSMap.FAIExecuter.UseProcessTime(Path.Count);
  end;
end;

procedure TMoveControl.CalculatePath(Settings: TMoveControlSettings; Path: TMovepath; X, Y, L: Shortint);
begin
  Activate(Settings);
  CalculatePathEx(Path, X, Y, L);
  Deactivate;
end;

function TMoveControl.ExploredOnlyMoveOnMovePointProc(MapF: TAoWMapField; MoveOverCode: Integer): Integer;
var Points: Integer;
begin
  if MapF.FFieldFlags and FExploredMask <> 0 then
  begin
    Points := FMovePointTable[MapF.TerrainType][MapF.OverlayType];
    if MapF.FFieldFlags and $4000 <> 0 then Points := MapF.CanMoveOn(Self, Points, MoveOverCode);
  end
  else Points := -1;
  Result := Points;
end;

function TMoveControl.Activate(Settings: TMoveControlSettings): Boolean;
type TOriginalAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const OriginalAssertFile: TOriginalAssertText = (RefCount:-1; Len:28; Text:'D:\AoWDev\AoWE\inc\MoveT.PAS'#0); OriginalAssertMessage: TOriginalAssertText = (RefCount:-1; Len:17; Text:'Assertion failure'#0); begin





  if mcsActivated in FStatus then asm MOV ECX,$7EA8; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  if (Settings.FSourceX = -1) or (Settings.FSourceY = -1) or (Settings.FSourceL = -1) then asm MOV ECX,$7EA9; LEA EDX,OriginalAssertFile.Text; LEA EAX,OriginalAssertMessage.Text; CALL System.@Assert end; { Preserve the original assertion diagnostic. }
  if Settings.FStatus <> mcssFailed then
  begin
    FStatus := FStatus + [mcsActivated];
    FSettings := Settings;
    FSettings.AddRef;
    case FSettings.FStatus of
      mcssIdle:
        begin
          with FMap.MapContainer do FSettings.SetupMovePointData(Width, Height, LevelCount);
          FMovePointsLimit := FSettings.FMovePointsMax;
        end;
      mcssProcessing: FMovePointsLimit := FSettings.FMovePointsLimit;
      mcssProcessed: FMovePointsLimit := FSettings.FMovePointsLimit;
    end;
    System.Move(FSettings.FEvenOffsets, FPointOffsets, SizeOf(FPointOffsets));
    FPlayer := FSettings.FPlayer;
    FSourceX := FSettings.FSourceX;
    FSourceY := FSettings.FSourceY;
    FSourceL := FSettings.FSourceL;
    FDestinationX := FSettings.FDestinationX;
    FDestinationY := FSettings.FDestinationY;
    FDestinationL := FSettings.FDestinationL;
    FMovePointTable := FSettings.FMovePointTable;
    FMode := FSettings.FMode;
    FArmyHS := TArmyHS(FSettings.FArmyHS);
    FSelection := FSettings.FSelection;
    FTransporterArmy := FSettings.FTransporterArmy;
    FProcessedMapFields := FSettings.FProcessedMapFields;
    SetMapL(FMap.MapContainer.GetMapLevel(FSourceL));
    if (mmExploredTerrainOnly in FMode) and (FPlayer <> -1) then
    begin
      FOnMovePoint := ExploredOnlyMoveOnMovePointProc;
      FExploredMask := 1 shl (FPlayer - 1);
    end
    else FOnMovePoint := DefaultMoveOnMovePointProc;
    Result := True;
  end
  else Result := False;
end;

procedure TMoveControl.Deactivate;
begin
  if mcsActivated in FStatus then
  begin
    FStatus := FStatus - [mcsActivated];
    if FSettings.FStatus = mcssProcessing then FSettings.FMovePointsLimit := FMovePointsLimit;
    FSettings.Release;
    FSettings := nil;
  end;
end;

procedure TMoveControl.ProcessMove(A1: TMoveControlSettings);
begin
  if (A1.FSourceX <> A1.FDestinationX) or (A1.FSourceY <> A1.FDestinationY) or
    (A1.FSourceL <> A1.FDestinationL) then
  begin
    if Activate(A1) then
    begin



















      Assert(AoWEngine.FDemo or (A1.FStatus <> mcssProcessed));
      repeat until not Process;
      if FDestinationX <> -1 then
      begin
        CalculatePathEx(A1.FPath, FDestinationX, FDestinationY, FDestinationL);
        if A1.FPath.Count = 0 then A1.FStatus := mcssFailed;
      end;
      Deactivate;
    end;
  end
  else
  begin
    A1.FPath.Clear;
    A1.FPath.AddXYL(A1.FSourceX, A1.FSourceY, A1.FSourceL);
    A1.FStatus := mcssProcessed;
  end;
end;

function TMoveControl.CanMove(Settings: TMoveControlSettings; Mode: TCanMoveMode): Integer;
var Points: Integer;
begin
  if (Settings.FSourceX <> Settings.FDestinationX) or
    (Settings.FSourceY <> Settings.FDestinationY) or
    (Settings.FSourceL <> Settings.FDestinationL) then
  begin
    Settings.ResetState;
    if Activate(Settings) then
    begin
      Points := -1;
      if (FDestinationX = -1) or ValidLocation(FDestinationX, FDestinationY, FDestinationL) then
      begin
        if (FSourceL = FDestinationL) and (mmFast in Mode) then
          Points := GetMovePointsCostFast(FSourceX, FSourceY, FDestinationX, FDestinationY);
        if (Points = -1) and (mmExact in Mode) then
        begin
          repeat until not Process;
          Points := FSettings.GetMovePoints(FDestinationX, FDestinationY, FDestinationL);
          if Points = $FFFFFF then Points := -1;
        end;
      end;
      Deactivate;
    end
    else Points := -1;
  end
  else Points := 0;
  Result := Points;
end;

function TMoveControl.ValidPath(Settings: TMoveControlSettings; Path: TMovepath): Boolean;
var
  Valid: Boolean;
  I, Points: Integer;
begin
  Valid := True;
  I := Path.Count - 2;
  Points := 0;
  Settings.FMovePointsMax := Path.PosToMovePoints(0);
  ProcessMove(Settings);
  while (I > 0) and Valid do
  begin
    Inc(Points, Path[I].Flag);
    Valid := Points = Settings.GetMovePoints(Path[I].X, Path[I].Y, Path[I].L);
    Dec(I);
  end;
  Result := Valid;
end;

procedure TMoveControl.CalculateGaps(SourceX, SourceY, DestinationX, DestinationY: Integer);
var
  X, Y, Direction, OverCode: Integer;
  Field: TAoWMapField;
  Clear: Boolean;
  Points: Integer;
begin
  Clear := True;
  FGapStarts.Count := 0;
  FGapEnds.Count := 0;
  FDirectRoute.Count := 0;
  OverCode := 1;
  FDirectRoute.AddXYL(SourceX, SourceY, 0);
  X := 0;
  Y := 0;
  Direction := 0;
  while (SourceX <> DestinationX) or (SourceY <> DestinationY) do
  begin
    if SourceX = DestinationX then
    begin
      if SourceY > DestinationY then
      begin Direction := 1; X := SourceX; Y := SourceY - 1; end
      else if SourceY < DestinationY then
      begin Direction := 4; X := SourceX; Y := SourceY + 1; end;
    end
    else if SourceX and 1 = 0 then
    begin
      if SourceX > DestinationX then
        if SourceY > DestinationY then
        begin Direction := 6; X := SourceX - 1; Y := SourceY - 1; end
        else begin Direction := 5; X := SourceX - 1; Y := SourceY; end
      else if SourceY > DestinationY then
        begin Direction := 2; X := SourceX + 1; Y := SourceY - 1; end
      else begin Direction := 3; X := SourceX + 1; Y := SourceY; end;
    end
    else
    begin
      if SourceX > DestinationX then
        if SourceY < DestinationY then
        begin Direction := 5; X := SourceX - 1; Y := SourceY + 1; end
        else begin Direction := 6; X := SourceX - 1; Y := SourceY; end
      else if SourceY < DestinationY then
        begin Direction := 3; X := SourceX + 1; Y := SourceY + 1; end
      else begin Direction := 2; X := SourceX + 1; Y := SourceY; end;
    end;
    Field := TAoWMapField(FMapLevel.GetField(X, Y));
    Points := FOnMovePoint(Field, OverCode);
    if Points >= 0 then
      if (Field.FFieldFlags and $2000 <> 0) and ((X <> DestinationX) or (Y <> DestinationY)) then
      begin
        OverCode := Field.CanMoveOver(Self);
        if OverCode = 0 then
        begin
          Points := -1;
          OverCode := 1;
        end;
      end
      else OverCode := 1;
    if Points < 0 then
    begin
      if Clear then
      begin
        FGapStarts.AddXYL(SourceX, SourceY, Direction);
        Clear := False;
        OverCode := 1;
      end;
    end
    else if not Clear then
    begin
      FGapEnds.AddXYL(X, Y, -1);
      Clear := True;
    end;
    SourceX := X;
    SourceY := Y;
    FDirectRoute.AddXYL(SourceX, SourceY, Points);
  end;
  if not Clear then FGapEnds.AddXYL(DestinationX, DestinationY, -1);
end;

function TMoveControl.CalculateTurnAroundMovePoints(var GapIndex: Integer): Integer;
type TOffsets = array[0..7] of Integer; POffsets = ^TOffsets; var
  Offsets: POffsets; Done, LeftFound, RightFound, LeftActive, RightActive: Boolean;
  LeftPoints, RightPoints, RightOver, LeftOver: Integer; RightField, LeftField, Next: TAoWMapField;
  RightDirection, LeftDirection: Integer; StartX, StartY: Shortint; Attempts, Points, OverCode, Index: Integer;
begin
  LeftFound := False;
  RightFound := False;
  LeftActive := True;
  RightActive := True;
  StartX := FGapStarts[GapIndex].X;
  StartY := FGapStarts[GapIndex].Y;
  RightField := TAoWMapField(FMapLevel.GetField(FGapStarts[GapIndex].X, FGapStarts[GapIndex].Y));
  LeftField := RightField; RightDirection := FGapStarts[GapIndex].L; LeftDirection := RightDirection;
  LeftPoints := 0;
  RightPoints := 0;
  Done := False;
  RightOver := RightField.CanMoveOver(Self);
  LeftOver := RightOver;
  while not Done do
  begin
    if RightActive then
    begin
      Attempts := 0;
      Offsets := @FFieldOffsets[RightField.Xhx and 1];
      repeat
        Next := TAoWMapField(Offsets^[RightDirection] + Integer(RightField));
        Points := FOnMovePoint(Next, RightOver);
        if Points >= 0 then
          if (Next.FFieldFlags and $2000 <> 0) and
            ((Next.Xhx <> FDestinationX) or (Next.Yhx <> FDestinationY)) then
          begin
            OverCode := Next.CanMoveOver(Self);
            if OverCode = 0 then Points := -1;
          end else OverCode := 1
        else OverCode := 1;
        Inc(RightDirection);
        if RightDirection > 6 then RightDirection := 1;
        Inc(Attempts);
      until (Points >= 0) or (Attempts > 6);
      if RightOver = 2 then Dec(RightDirection, 3)
      else Dec(RightDirection, 2);
      if RightDirection <= 0 then Inc(RightDirection, 6);
      if OverCode = 2 then RightOver := 2 else RightOver := 1;
      Inc(RightPoints, Points);
      RightField := Next;
      if (RightPoints <= FMovePointsLimit) and (Points >= 0) then
      begin
        Index := FGapEnds.IndexOfXY(RightField.Xhx, RightField.Yhx);
        if (Index <> -1) and (Index >= GapIndex) then
        begin
          GapIndex := Index;
          RightFound := True;
          Done := True;
          RightActive := False;
        end;
        if (RightField.Xhx = StartX) and (RightField.Yhx = StartY) then
        begin
          RightActive := False;
          if not LeftActive then Done := True;
        end;
      end
      else
      begin
        RightActive := False;
        if not LeftActive then Done := True;
      end;
    end;
    if LeftActive then
    begin
      Attempts := 0;
      Offsets := @FFieldOffsets[LeftField.Xhx and 1];
      repeat
        Next := TAoWMapField(Offsets^[LeftDirection] + Integer(LeftField));
        Points := FOnMovePoint(Next, LeftOver);
        if Points >= 0 then
          if (Next.FFieldFlags and $2000 <> 0) and
            ((Next.Xhx <> FDestinationX) or (Next.Yhx <> FDestinationY)) then
          begin
            OverCode := Next.CanMoveOver(Self);
            if OverCode = 0 then Points := -1;
          end else OverCode := 1
        else OverCode := 1;
        Dec(LeftDirection);
        if LeftDirection = 0 then LeftDirection := 6;
        Inc(Attempts);
      until (Points >= 0) or (Attempts > 6);
      if LeftOver = 2 then Inc(LeftDirection, 3)
      else Inc(LeftDirection, 2);
      if LeftDirection > 6 then Dec(LeftDirection, 6);
      if OverCode = 2 then LeftOver := 2 else LeftOver := 1;
      Inc(LeftPoints, Points);
      LeftField := Next;
      if (LeftPoints < FMovePointsLimit) and (Points >= 0) then
      begin
        Index := FGapEnds.IndexOfXY(LeftField.Xhx, LeftField.Yhx);
        if (Index <> -1) and (Index >= GapIndex) then
        begin
          GapIndex := Index;
          LeftFound := True;
          Done := True;
          LeftActive := False;
        end;
        if (LeftField.Xhx = StartX) and (LeftField.Yhx = StartY) then
        begin
          LeftActive := False;
          if not RightActive then Done := True;
        end;
      end
      else
      begin
        LeftActive := False;
        if not RightActive then Done := True;
      end;
    end;
  end;
  if LeftFound then Result := LeftPoints
  else if RightFound then Result := RightPoints
  else Result := -1;
end;








function TMoveControl.GetMovePointsCostFast(SourceX, SourceY, DestinationX, DestinationY: Integer): Integer;
var
  I, Points, GapIndex, Cost: Integer;
begin
  I := 1;
  GapIndex := 0;
  Points := 0;
  CalculateGaps(SourceX, SourceY, DestinationX, DestinationY);
  while (I < FDirectRoute.Count) and (Points <> -1) do
  begin
    Cost := FDirectRoute[I].L;
    if Cost < 0 then
    begin
      GapIndex := FGapStarts.IndexOfXY(FDirectRoute[I - 1].X, FDirectRoute[I - 1].Y);
      Cost := CalculateTurnAroundMovePoints(GapIndex);
      if Cost <> -1 then
      begin
        Inc(Points, Cost);
        I := FDirectRoute.IndexOfXY(FGapEnds[GapIndex].X, FGapEnds[GapIndex].Y);
      end
      else Points := -1;
    end
    else Inc(Points, Cost);
    Inc(I);
  end;
  Result := Points;
end;

class function TSaveGameTE.ClassID: Integer;
begin
  Result := $21114;
end;

procedure TSaveGameTE.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FFileName, $F);
end;

function TSaveGameTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin
  inherited Execute(TE);
  if AoWHSMap.FSeatedPlayer = TE.ActiveTCIndex then
    if TE.ExecuteCount = 0 then
    begin
      AoWHSMap.ShowMessage(Format(TranslateRStr(P5SavingGameRStr), [ExtractFileName(FFileName)]));
      Result := erRetry;
    end
    else
    begin
      AoWHSMap.ShowMessage(Format(TranslateRStr(GameSavedRStr), [ExtractFileName(FFileName)]));
      try
        AoWHSMap.DisableTurnTimer;
        if AoWEngine.FCampaign <> nil then
        begin
          AoWEngine.SaveCampaign(FFileName);
          AoWEngine.FCampaign.FFileName := FFileName;
        end
        else
        begin
          AoWEngine.SaveHSM(FFileName, nil);
          AoWHSMap.FileName := FFileName;
        end;
        AoWHSMap.EnableTurnTimer;
      except
        { Original leaves the turn timer disabled after a save failure. }
        AoWHSMap.ShowMessage(Format(TranslateRStr(P5ErrorSavingRStr), [FFileName]));
      end;
      Result := erDone;
    end
  else Result := erDone;
end;

class function TChangePlayerSettingsTE.ClassID: Integer;
begin Result := $21326; end;

procedure TChangePlayerSettingsTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $1E);
  Stream.rwString(FSettings, $1F);
end;

function TChangePlayerSettingsTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  AoWHSMap.FPlayers.GetPlayers(FPlayer).FSettings := FSettings;
  Result := erDone;
end;

class function TEndTurnTE.ClassID: Integer;
begin Result := $21101; end;

procedure TEndTurnTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FDay, $14);
  Stream.rwByte(Byte(FPlayer), $15);
  Stream.rwData(FMode, SizeOf(FMode), $16);
end;

function TEndTurnTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  inherited Execute(TE);
  if AoWHSMap.FDay = FDay then
  begin
    if (FMode = emEndTurn) and
      not AoWHSMap.FPlayers.GetPlayers(FPlayer).FSingleProcessCycle then
    begin
      AoWHSMap.FPlayerControl.EndTurn(FPlayer);
      if (AoWHSMap.FPlayMode = pmSimultaneous) and
        (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace <> -1) then
        AoWHSMap.ShowMessage(TranslateRStr(RaceNamesPluralRStr[
          AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerRace]) + ' ' +
          TranslateRStr(P5FinishedTheirTurnRStr));
    end;
    if FMode = emCancelEndTurn then
      AoWHSMap.FPlayers.GetPlayers(FPlayer).SetEndTurn(False);
    Result := erDone;
  end
  else Result := erDoneHalt;
end;

function EndPlayerTurn(Player: Shortint): Boolean;
var
  Event: TEndTurnTE;
begin
  Event := TEndTurnTE.Create(nil);
  Event.FPlayer := Player;
  Event.FDay := AoWHSMap.FDay;
  Event.FMode := emEndTurn;
  AoWHSMap.FTokenManager.TokenControls[Player].AddEvent(Event);
  Event.Release;
  Result := True;
end;

constructor TMoveTE.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FPath := TMovepath.Create;
  FMoveIndex := 0;
  FStatus := msIdle;
end;

destructor TMoveTE.Destroy;
begin
  FPath.Free;
  inherited Destroy;
end;

procedure TMoveTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($14, FPath.LoadFromStream, FPath.SaveToStream);
end;

function TMoveTE.GetMapF(Location: TXYL): TAoWMapField;
begin
  Result := TAoWMapField(AoWHSMap.MapContainer.GetField(Location.X, Location.Y, Location.L));
end;

function TMoveTE.GetDirection(Index: Integer): Integer;
begin
  if (Index > 0) and (Index < FPath.Count) then
  begin
    if (FPath[Index].L = FPath[Index - 1].L) and
      (dHXtoRad(FPath[Index].X, FPath[Index].Y,
        FPath[Index - 1].X, FPath[Index - 1].Y) = 1) then
      Result := dHXtoHNfast(FPath[Index].X, FPath[Index].Y,
        FPath[Index - 1].X, FPath[Index - 1].Y)
    else Result := 0;
  end
  else Result := 0;
end;

function TMoveTE.GetHT(Index: Integer): Integer;
begin
  if (Index > 0) and (Index < FPath.Count) then
    Result := dHXtoHT(FPath[Index].X, FPath[Index].Y,
      FPath[Index - 1].X, FPath[Index - 1].Y)
  else Result := 0;
end;

function TMoveTE.Move: TMoveStatus;
begin
  Dec(FMoveIndex);
  if FMoveIndex = 0 then Result := msDone
  else Result := msMoving;
end;

function TMoveTE.Validate: Boolean;
begin Result := True; end;

procedure TMoveTE.InitializeMove;
begin FMoveIndex := FPath.Count - 1; end;

procedure TMoveTE.FinishMove;
begin FStatus := msFinished; end;

function TMoveTE.DefaultMove: TMoveStatus;
begin Result := Move; end;

function TMoveTE.LastMove: TMoveStatus;
begin Result := DefaultMove; end;

function TMoveTE.ProcessMove: TMoveStatus;
begin
  if FMoveIndex = 1 then Result := LastMove
  else if (FMoveIndex > 1) and (FMoveIndex < FPath.Count) then
    Result := DefaultMove
  else Result := msDone;
end;

function TMoveTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  inherited Execute(TE);
  if FStatus = msIdle then
  begin
    if Validate then
    begin
      FStatus := msMoving;
      InitializeMove;
      AoWHSMap.Random($FFFFF);
      case FPath.Count of
        0..1: FStatus := msDone;
        2: FStatus := LastMove;
      else FStatus := DefaultMove;
      end;
    end
    else FStatus := msFailed;
  end
  else if FStatus = msMoving then FStatus := ProcessMove;
  if FStatus = msDone then
  begin
    FinishMove;
    Result := erDone;
  end
  else if FStatus = msFailed then
  begin
    FinishMove;
    Result := erDoneHalt;
  end
  else if FStatus = msFinished then Result := erDone
  else Result := erRetry;
end;

constructor TMoveArmyTE.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FUnitIDs := TIntegerList.Create;
end;

destructor TMoveArmyTE.Destroy;
begin
  FUnitIDs.Free;
  inherited Destroy;
end;

class function TMoveArmyTE.ClassID: Integer;
begin Result := $21100; end;

function TMoveArmyTE.GetNoneMovingArmyHS(Field: TMapField): TArmyHS;
var
  I: Integer;
  ArmyHS: TArmyHS;
begin
  Result := nil;
  for I := Field.Count - 1 downto 0 do
  begin
    ArmyHS := TArmyHS(Field.HSList^[I]);
    if (ArmyHS.ClassID = $20217) and (ArmyHS.Owner = Field) and
      not (amMoving in ArmyHS.FArmy.FMode) then
    begin
      Result := ArmyHS;
      Break;
    end;
  end;
end;

procedure TMoveArmyTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($1E, FUnitIDs.LoadFromStream, FUnitIDs.SaveToStream);
  Stream.rwByte(Byte(FPlayer), $1F);
  Stream.rwByte(Byte(FTargetX), $20);
  Stream.rwByte(Byte(FTargetY), $21);
  Stream.rwByte(Byte(FTargetL), $22);
  Stream.rwByte(Byte(FTargetPlayer), $23);
  Stream.rwData(FMode, SizeOf(FMode), $24);
  Stream.rwByte(Byte(FDestinationX), $25);
  Stream.rwByte(Byte(FDestinationY), $26);
  Stream.rwByte(Byte(FDestinationL), $27);
end;

function TMoveArmyTE.Setup(ArmyHS: TArmyHS; Selection: Byte; Path: TMovepath; Mode: TArmyMoveMode): Boolean;
var
  First, Last, I: Integer;
begin
  FPath.Clear;
  First := Path.MovePointsToPos(ArmyHS.FArmy.MovePoints(Selection));
  Last := Path.Count - 1;
  if Last > First then
  begin
    for I := First to Last do FPath.Add(Path[I]);
    FArmyHS := ArmyHS;
    FPlayer := ArmyHS.FArmy.FPlayer;
    FMode := Mode;
    FTargetPlayer := GetMapF(Path[0]).GetPlayer;
    FTargetX := Path[0].X;
    FTargetY := Path[0].Y;
    FTargetL := Path[0].L;
    FSelection := ArmyHS.FArmy.ValidateSelection(Selection);
    for I := 0 to ArmyHS.FArmy.Count - 1 do
      if (1 shl I) and Selection <> 0 then
        FUnitIDs.Add(ArmyHS.FArmy.GetUnit(I).FUnitID);
    FDestinationX := FArmyHS.FArmy.FDestinationX;
    FDestinationY := FArmyHS.FArmy.FDestinationY;
    FDestinationL := FArmyHS.FArmy.FDestinationL;
    Result := True;
  end
  else Result := False;
end;

function TMoveArmyTE.Validate: Boolean; { Near miss: field temporaries and registers differ after three variants. }
var
  I, UnitIndex: Integer;
  Settings: TMoveControlSettings;
  TargetPlayer: Shortint;
begin
  I := FPath.Count - 1;
  Result := True;
  if I < 1 then Result := False
  else
  begin
    FArmyHS := TArmyHS(GetMapF(FPath[I]).FindOwnedChild($20217));
    if FArmyHS = nil then Result := False
    else
    begin
      I := FUnitIDs.Count;
      FSelection := 0;
      while (I <> 0) and Result do
      begin
        Dec(I);
        UnitIndex := FArmyHS.FArmy.IndexOfID(FUnitIDs[I]);
        if UnitIndex <> -1 then FSelection := FSelection or (1 shl UnitIndex);
        Result := FArmyHS.FArmy.IndexOfID(FUnitIDs[I]) <> -1;
      end;
      Settings := TMoveControlSettings.Create(nil);
      Settings.SetupArmy(FArmyHS, FSelection);
      Include(Settings.FMode, mmAI);
      if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman)
        and AoWHSMap.FExplorationEnabled then Include(Settings.FMode, mmExploredTerrainOnly);
      Result := Result and AoWHSMap.FMoveControl.ValidPath(Settings, FPath);
      Result := Result and (FArmyHS.FArmy.FPlayer = FPlayer);
      TargetPlayer := TAoWMapField(AoWHSMap.MapContainer.GetField(
        FTargetX, FTargetY, FTargetL)).GetPlayer;
      Result := Result and ((TargetPlayer = FTargetPlayer) or
        (TargetPlayer = FArmyHS.FArmy.FPlayer));
      if mmBuildRoads in FMode then
        Result := Result and (RoadConstructionCost(FPlayer, FPath,
          FArmyHS.FArmy.MovePoints(FSelection)) <= AoWHSMap.FPlayers.GetPlayers(FPlayer).FGems);
      Settings.Release;
    end;
  end;
  if not Result and (AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType <> ptHuman) and
    (AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.FMoveExecuter.FStatus = mesBusy) then
    AoWHSMap.FPlayers.GetPlayers(FPlayer).FAIControl.FMoveExecuter.InvalidateMove(FArmyHS, FSelection);
end;

procedure TMoveArmyTE.InitializeMove; { Near miss: army temporary and set expression differ after three variants. }
var
  Last: Integer;
  ArmyHS: TArmyHS;
begin
  inherited InitializeMove;
  FAnimate := False;
  Last := FPath.Count - 1;
  FSelection := FArmyHS.FArmy.ValidateSelection(FSelection);
  if FSelection <> FArmyHS.FArmy.ValidateSelection($FF) then
  begin
    ArmyHS := TArmyHS.Create(nil);
    ArmyHS.FArmy.SetPlayer(FArmyHS.FArmy.FPlayer);
    ArmyHS.FArmy.AddUnitSelection(FArmyHS.FArmy, FSelection);
    ArmyHS.PlacePrivate(AoWHSMap.MapContainer, FPath[Last].X, FPath[Last].Y, FPath[Last].L);
    FArmyHS.FArmy.ResetDestinationPos;
    if FArmyHS.GetSelected then
    begin
      AoWHSMap.Selection.UnselectLocation;
      AoWHSMap.Selection.SelectLocationHS(ArmyHS);
      AoWHSMap.FSelectedArmy.DeactivateMoveSelection;
    end;
    FArmyHS := ArmyHS;
    FSelection := $FF;
  end
  else
  begin
    if FArmyHS.GetSelected then AoWHSMap.FSelectedArmy.DeactivateMoveSelection;
  end;
  with FArmyHS.FArmy do
  begin
    Include(FMode, amMoving);
    FDestinationX := Self.FDestinationX;
    FDestinationY := Self.FDestinationY;
    FDestinationL := Self.FDestinationL;
  end;
end;

procedure TMoveArmyTE.FinishMove;
var
  Selected: Boolean;
  Field: TMapField;
  ArmyHS: TArmyHS;
begin
  inherited FinishMove;
  if FArmyHS <> nil then
  begin
    Selected := FArmyHS.GetSelected;
    Field := TMapField(FArmyHS.Owner);
    FArmyHS.SetOwner(nil);
    ArmyHS := GetNoneMovingArmyHS(Field);
    FArmyHS.SetOwner(Field);
    if ArmyHS <> nil then
    begin
      FArmyHS.FArmy.FUserMode := FArmyHS.FArmy.FUserMode * ArmyHS.FArmy.FUserMode;
      ArmyHS.FArmy.AssignSettings(FArmyHS.FArmy);
      ArmyHS.FArmy.AddUnitSelection(FArmyHS.FArmy, $FF);
      FArmyHS := ArmyHS;
      if Selected then
      begin
        AoWHSMap.FSelectedArmy.Select(ArmyHS);
        AoWHSMap.FSelectedArmy.DeactivateMoveSelection;
      end;
    end;
    FArmyHS.FArmy.FMode := FArmyHS.FArmy.FMode - [amMoving];
    FArmyHS.CancelMove;
    if Selected then
    begin
      AoWHSMap.FSelectedArmy.ActivateMoveSelection;
      AoWHSMap.FSelectedArmy.Update;
      if mmSelectEndLocation in FMode then
        AoWHSMap.Selection.SelectLocationHX(FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx);
    end;
  end;
end;

function TMoveArmyTE.ObserveMove(Index: Integer): Boolean; { Match: Boolean stages and event local preserve the original lifetimes. }
var Visible: Boolean; Event: TMultiMoveTE; begin
  Visible := MoveVisible(Index); Result := Visible and AoWHSMap.FShowIndependentMoves and
    ((AoWHSMap.FSeatedPlayer <> FArmyHS.FArmy.FPlayer) or
     (AoWHSMap.FPlayers.GetPlayers(Shortint(PChar(AoWHSMap)[$A5])).FPlayerType <> ptHuman));
  if Result and (AoWHSMap.FTokenManager.TokenExecuter.GetExecutingTokenEvent is TMultiMoveTE) and
    TMultiMoveTE(AoWHSMap.FTokenManager.TokenExecuter.GetExecutingTokenEvent).FSimultaneous then
    begin Event := TMultiMoveTE(AoWHSMap.FTokenManager.TokenExecuter.GetExecutingTokenEvent); Visible := Self = Event.FEvents[0]; Result := Visible; end;
end;

function TMoveArmyTE.MoveVisible(Index: Integer): Boolean;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    Result := AoWHSMap.Visible(FPath[Index].X, FPath[Index].Y, FPath[Index].L, 0);
    if Result and (asFullyConcealed in FArmyHS.FArmy.FStatus) then Result := False;
  end
  else Result := False;
end;

function TMoveArmyTE.ExecuteMove: TMoveStatus;
var
  Field: TAoWMapField;
  Direction: Integer;
begin
  if mmBuildRoads in FMode then ConstructRoad(FArmyHS.FArmy.FPlayer, GetMapF(FPath[FMoveIndex]));
  Dec(FMoveIndex);
  Field := GetMapF(FPath[FMoveIndex]);
  FArmyHS.MoveTo(Field, FPath[FMoveIndex].Flag);
  if Field.FindChildIndex(FArmyHS) <> -1 then
  begin
    Direction := GetDirection(FMoveIndex + 1);
    if Direction = 0 then Direction := GetHT(FMoveIndex + 1);
    if (Direction > 0) and (Direction <= 6) then FArmyHS.SetDirection(Direction)
    else FArmyHS.SetDirection(0);
    if mmBuildRoads in FMode then ConstructRoad(FArmyHS.FArmy.FPlayer, Field);
    Result := ProcessMove;
  end
  else
  begin
    FArmyHS := nil;
    Result := msDone;
  end;
end;

function TMoveArmyTE.Animating: Boolean;
begin
  Result := (FArmyHS.GetMoveStatus < 100) and (FArmyHS.GetMoveStatus <> -1);
end;

procedure TMoveArmyTE.UpdateAnimation;
begin FArmyHS.MoveNext; end;

function TMoveArmyTE.CanMoveNext: Boolean;
var
  Stop: Boolean;
  I: Integer;
  Field: TAoWMapField;
  ArmyHS: TArmyHS;
begin
  Result := False;
  Stop := False;
  I := FMoveIndex;
  while (I <> 0) and not (Stop or Result) do
  begin
    Dec(I);
    Field := GetMapF(FPath[I]);
    Result := Field.GetPlayer = -1;
    if not Result then
    begin
      ArmyHS := GetNoneMovingArmyHS(Field);
      if ArmyHS <> nil then
      begin
        if ArmyHS.FArmy.FPlayer = FArmyHS.FArmy.FPlayer then
          Result := FArmyHS.FArmy.CanCombine(ArmyHS.FArmy, $FF)
        else if AoWHSMap.FPlayers.GetDiplomaticRelation(FArmyHS.FArmy.FPlayer, { Original queries the moving player toward the other army. }
          ArmyHS.FArmy.FPlayer) <> drAlliance then Stop := True;
      end
      else Result := Field.GetPlayer = FArmyHS.FArmy.FPlayer;
    end;
  end;
end;

procedure TMoveArmyTE.SetupNextMove;
var
  Direction: Integer;
  Instant: Boolean;
  Field: TAoWMapField;
begin
  if (MoveVisible(FMoveIndex) or FAnimate) and
    ((FPath[FMoveIndex].L = AoWHSMap.ViewL) or AoWHSMap.FShowIndependentMoves) then
  begin
    FAnimate := True;
    Direction := GetDirection(FMoveIndex);
    if Direction = 0 then
    begin
      Direction := GetHT(FMoveIndex);
      Instant := True;
    end
    else Instant := False;
    FArmyHS.MoveFirst(Direction, Instant);
    if ObserveMove(FMoveIndex - 1) then
    begin
      Field := GetMapF(FPath[FMoveIndex - 1]);
      AoWHSMap.ValidateObservation(FArmyHS.FArmy.FPlayer, Field.Xhx, Field.Yhx, Field.Lhx, 0);
    end;
  end;
end;

function TMoveArmyTE.DefaultMove: TMoveStatus;
begin
  if not FArmyHS.Moving then
  begin
    if CanMoveNext then
    begin
      SetupNextMove;
      if not Animating then Result := ExecuteMove
      else Result := msMoving;
    end
    else Result := msFailed;
  end
  else
  if Animating then
  begin
    UpdateAnimation;
    if (FArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) or
      AoWHSMap.Watching(FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx, 0) then FArmyHS.PlayMoveSFX;
    if not Animating then Result := ExecuteMove
    else Result := msMoving;
  end else Result := msFailed;
end;

class function TArmyDefaultMoveTE.ClassID: Integer;
begin Result := $21104; end;

function TArmyDefaultMoveTE.Setup(ArmyHS: TArmyHS; Selection: Byte; Path: TMovepath; Mode: TArmyMoveMode): Boolean;
begin Result := inherited Setup(ArmyHS, Selection, Path, Mode); end;

class function TArmyNegotiateMoveTE.ClassID: Integer;
begin Result := $21106; end;

function TArmyNegotiateMoveTE.Validate: Boolean;
begin
  Result := inherited Validate and
    (TAoWMapField(AoWHSMap.MapContainer.GetField(FTargetX, FTargetY, FTargetL)).
      GetMoveAction(FArmyHS.FArmy.FPlayer) = maNegotiate);
end;

function TArmyNegotiateMoveTE.CanMoveNext: Boolean;
var Field: TAoWMapField;
begin
  if FMoveIndex = 1 then
  begin
    { Evaluate the map field directly. }
    Result := GetMapF(FPath[0]).GetMoveAction(FArmyHS.FArmy.FPlayer) = maNegotiate; if not Result then Result := inherited CanMoveNext;
    { Otherwise retain the successful negotiation test. }
  end
  else Result := inherited CanMoveNext;
end;

function TArmyNegotiateMoveTE.ExecuteMove: TMoveStatus;
var
  Field: TAoWMapField;
  Direction: Integer;
begin
  if FMoveIndex = 1 then
  begin
    Field := GetMapF(FPath[0]);
    if Field.GetMoveAction(FArmyHS.FArmy.FPlayer) = maNegotiate then
    begin
      Direction := GetDirection(1);
      if Direction = 0 then Direction := GetHT(1);
      if (Direction > 0) and (Direction <= 6) then FArmyHS.SetDirection(Direction)
      else FArmyHS.SetDirection(0);
      NegotiateArmy(FArmyHS.FArmy.FPlayer, FArmyHS, FSelection,
        FPath[0].X, FPath[0].Y, FPath[0].L, FPath[0].Flag);
      Result := msDone;
    end
    else Result := inherited ExecuteMove;
  end
  else Result := inherited ExecuteMove;
end;

function TArmyNegotiateMoveTE.Animating: Boolean;
var Field: TAoWMapField;
begin
  if FMoveIndex = 1 then
  begin
    if FArmyHS.GetMoveStatus <> -1 then
    begin
      { Process the negotiate or ordinary move animation. }
      { Evaluate the map field directly. }
      if GetMapF(FPath[0]).GetMoveAction(FArmyHS.FArmy.FPlayer) = maNegotiate then
        Result := FArmyHS.GetMoveStatus < 50
      else Result := FArmyHS.GetMoveStatus < 100;
    end else Result := False;
  end
  else Result := inherited Animating;
end;

class function TArmyCombineMoveTE.ClassID: Integer;
begin Result := $21103; end;

procedure TArmyCombineMoveTE.ShowCombineFailure(Reason: TAddUnitsResult);
begin
  case Reason of
    arInvalidMoveType: AoWHSMap.ShowMessage(TranslateRStr(P5CannotCombineArmiesRStr));
    arTooManyUnits: AoWHSMap.ShowMessage(TranslateRStr(P5CannotCombineArmiesRStr));
    arMultipleTransporters: AoWHSMap.ShowMessage(TranslateRStr(P5CannotCombineTransportersRStr));
  end;
end;

function TArmyCombineMoveTE.CanMoveNext: Boolean;
var
  ArmyHS: TArmyHS; SourceArmy, TargetArmy: TArmy;
  CombineResult: TAddUnitsResult;
begin
  if (FMoveIndex = 1) and (FPath[0].X = FTargetX) and
    (FPath[0].Y = FTargetY) and (FPath[0].L = FTargetL) and
    (FArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer) then
  begin
    ArmyHS := GetMapF(FPath[0]).GetArmyHS;
    if (ArmyHS <> nil) and (ArmyHS.FArmy.FPlayer = FArmyHS.FArmy.FPlayer) then
    begin
      SourceArmy := FArmyHS.FArmy; TargetArmy := ArmyHS.FArmy;
      CombineResult := TargetArmy.CanAddUnitSelection(SourceArmy, $FF);
      if CombineResult <> arOK then
      begin
        ShowCombineFailure(CombineResult);
        FMode := FMode - [mmSelectEndLocation];
      end;
    end;
  end;
  Result := inherited CanMoveNext;
end;
function TCombatRestoreHotseatEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
begin
  FCombatMove.FCombatMode := cmMoving;
  FCombatMove.RestoreHotseatMode;
  Result := False;
end;

class function TArmyCombatMoveTE.ClassID: Integer;
begin Result := $21102; end;

function TArmyCombatMoveTE.Setup(ArmyHS: TArmyHS; Selection: Byte; Path: TMovepath; Mode: TArmyMoveMode): Boolean;
begin
  Result := inherited Setup(ArmyHS, Selection, Path, Mode);
  if Result and (ArmyHS.FArmy.FPlayer = FTargetPlayer) then Result := False;
  if Result and (ArmyHS.FArmy.FPlayer > 0) and (FTargetPlayer > 0) and
    (AoWHSMap.FPlayers.GetPlayers(ArmyHS.FArmy.FPlayer).FDiplomaticRelations.
      GetDiplomaticRelation(FTargetPlayer) in [drPeace, drAlliance]) then Result := False;
end;

procedure TArmyCombatMoveTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FCombatType, SizeOf(FCombatType), $32);
end;

function TArmyCombatMoveTE.Validate: Boolean;
begin Result := inherited Validate; end;

procedure TArmyCombatMoveTE.InitializeMove;
begin inherited InitializeMove; end;

procedure TArmyCombatMoveTE.RequestCombatTypeCallBack(Log: TEventLog); { Review fix: the new attack move has an empty move-mode set; registers still differ. }
var
  Flow: TCombatFlowControlTE;
  Request: TCombatTypeRequestEventLog;
  Move: TArmyCombatMoveTE;
begin
  Request := TCombatTypeRequestEventLog(Log);
  FCombatType := Request.FCombatType;
  if Request.FCreateNewMove then begin
  if FCombatType <> ctNone then
  begin
    Flow := TCombatFlowControlTE.Create(nil);
    Flow.FMode := [cfmUnlockAIExecuter, cfmActivateTC, cfmEnableTurnTimer];
    if AoWHSMap.FPlayMode = pmSimultaneous then Flow.FMode := Flow.FMode + [cfmSetAutoSwitch];
    Flow.FPlayer := Request.FPlayer;
    AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Flow);
    Flow.Release;
    if Request.FArmyID.RetrieveArmy(FArmyHS, FSelection) then
    begin
      while FPath.Count > 2 do FPath.Delete(2);
      if FPath.Count = 2 then FPath.List^[1].Flag := 0;
      Move := TArmyCombatMoveTE(CreateArmyMoveTE(FArmyHS, FSelection, FPath, maAttack, []));
      if Move <> nil then
      { created combat move }
      begin
        Move.FCombatType := TCombatTypeRequestEventLog(Log).FCombatType;
        AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Move);
        Move.Release;
      end else AoWEngine.OutputDebugStr('Cannot create CombatMoveTE');
    end;
  end
  else
  begin
    if AoWHSMap.FPlayMode = pmSimultaneous then
    begin
      Flow := TCombatFlowControlTE.Create(nil);
      Flow.FMode := [cfmSetAutoSwitch, cfmUnlockAIExecuter, cfmEnableTurnTimer];
      AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Flow);
      Flow.Release;
    end;
  end;
 end else FCombatMode := cmSetupReady;
end;
procedure TArmyCombatMoveTE.RestoreHotseatMode;
var
  Log: TNewTurnEventLog;
begin
  AoWHSMap.SetSeatedPlayer(-1);
  Log := TNewTurnEventLog.Create(nil);
  Log.FTurnPlayer := AoWHSMap.FCurrentPlayer;
  Log.FMode := ntDialog;
  Log.FDialogStyle := [];
  if AoWHSMap.FCurrentPlayer = 0 then Log.FText := TranslateRStr(P5IndependentsAreMovingRStr)
  else Log.FText := Format(TranslateRStr(P5PlayerIsMovingRStr),
    [AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FCurrentPlayer).GetName]);
  AoWHSMap.TriggerExecuteEventLog(Log, True, nil);
  Log.Release;
end;

procedure TArmyCombatMoveTE.RestoreHotSeatModeCallBack(Log: TEventLog);
begin
  AoWHSMap.SynchroniseBegin;
  RestoreHotseatMode;
  AoWHSMap.FAIExecuter.Unlock;
  AoWHSMap.UnlockGameOverEvent;
  FCombatMode := cmMoving;
  AoWHSMap.SynchroniseEnd;
end;

procedure TArmyCombatMoveTE.ShowHotSeatPlayerCallBack(Log: TEventLog); { Near miss: three variants save Self in EBX instead of ESI. }
begin
  AoWHSMap.SetSeatedPlayer(TNewTurnEventLog(Log).FTurnPlayer);
  if FCombatMode = cmSetupHotseat then FCombatMode := cmSetupReady;
end;

procedure TArmyCombatMoveTE.SetupCombat;
var
  Field: TAoWMapField;
  Player: Shortint;
  Combat: TCombat;
  Msg: TMapFieldMsg;
  Request: TCombatTypeRequestEventLog;
  Log: TNewTurnEventLog;
begin
  Field := GetMapF(FPath[0]);
  if FCombatType = ctNone then
  begin
  if AoWHSMap.FRequestCombatType and (AoWHSMap.FConnectionType = pcLocal) then
  begin
    if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysFC then
      begin
        FCombatType := ctFast;
        FCombatMode := cmSetupReady;
      end
      else if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysTC then
      begin
        if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) or
          ((Field.GetPlayer > 0) and
           (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType = ptHuman)) then
          begin FCombatType := ctTactical; FCombatMode := cmSetupReady; end
        else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
        { Set the mode in both branches, as in the original. }
      end
      else FCombatMode := cmRequestingCombatType;
  end
  else if (AoWHSMap.FConnectionType = pcLocal) and
    ((not AoWHSMap.FRequestCombatType and (AoWHSMap.FPlayers.FLocalPlayers.Count = 1)) or
     (AoWHSMap.FRequestCombatType and
      (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman))) then
  begin
    if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysFC then
      begin
        FCombatType := ctFast;
        FCombatMode := cmSetupReady;
      end
      else if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysTC then
      begin
        if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) or
          ((Field.GetPlayer > 0) and
           (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType = ptHuman)) then
          begin FCombatType := ctTactical; FCombatMode := cmSetupReady; end
        else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
        { Set the mode in both branches, as in the original. }
      end
      else FCombatMode := cmRequestingCombatType;
  end
  else if (AoWHSMap.FConnectionType = pcEmail) and
    (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) and
    (Field.GetPlayer >= 0) and
    (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType <> ptHuman) then
  begin
    if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysFC then
      begin
        FCombatType := ctFast;
        FCombatMode := cmSetupReady;
      end
      else if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysTC then
      begin
        if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) or
          ((Field.GetPlayer > 0) and
           (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType = ptHuman)) then
          begin FCombatType := ctTactical; FCombatMode := cmSetupReady; end
        else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
        { Set the mode in both branches, as in the original. }
      end
      else FCombatMode := cmRequestingCombatType;
  end
  else if AoWHSMap.FConnectionType = pcNetwork then { Original tests connection type here, not play mode. }
  begin
    if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) or
      ((Field.GetPlayer > 0) and
       (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType = ptHuman)) then
    begin
      case AoWHSMap.FVictoryMode of
        0: begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
        2: FCombatMode := cmRequestingCombatType; 1:
          if (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman) and
            (Field.GetPlayer > 0) and
            (AoWHSMap.FPlayers.GetPlayers(Field.GetPlayer).FPlayerType = ptHuman) then
            FCombatMode := cmRequestingCombatType
          else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
        { The original tests the always-available case before the human-only case. }
      else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
      end;
    end
    else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
  end
  else begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
  end
  else FCombatMode := cmSetupReady;

  if (FCombatMode = cmRequestingCombatType) or
    ((FCombatType = ctTactical) and (FCombatMode = cmSetupReady)) then
  begin
    Combat := TCombat.Create(nil);
    Combat.Setup(FArmyHS.FArmy.FPlayer, FArmyHS.FArmy.FIndependentRelation,
      FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx,
      Field.GetPlayer, Field.GetIndependentRelation, FPath[0].X, FPath[0].Y, FPath[0].L, False);
    Msg.MsgID := $1107;
    Msg.Param[0] := Integer(Combat);
    Msg.Param[1] := Integer(FArmyHS);
    Msg.Result := 0;
    Field.SendMapFieldMsg(Msg);
    if Msg.Result = 0 then
      Combat.InitDefaultArmies(FArmyHS.FArmy, FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx);
    if not Combat.DefendersAvailable or not Combat.PlayerTypeInvolved([ptHuman]) then
    begin FCombatType := ctFast; FCombatMode := cmSetupReady; end;
    Combat.Free;
  end;
  if (AoWHSMap.FConnectionType = pcNetwork) and (FCombatMode = cmRequestingCombatType) then { Original uses connection type here too. }
  begin
    AoWHSMap.DisableTurnTimer;
    AoWHSMap.FAIExecuter.Lock;
    if AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType = ptHuman then
      Player := FArmyHS.FArmy.FPlayer
    else Player := Field.GetPlayer;
    if AoWHSMap.FTokenManager.GetTokenControl(Player).Local then
      AoWHSMap.FTokenManager.GetTokenControl(Player).ClearEvents;
    AoWHSMap.FTokenManager.TokenExecuter.HoldTC := True;
    AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(Player);
    if AoWHSMap.FSeatedPlayer = Player then
    begin
      Request := TCombatTypeRequestEventLog.Create(nil);
      Request.FPlayer := FArmyHS.FArmy.FPlayer;
      Request.FDefenderPlayer := Field.GetPlayer;
      Request.FX := Field.Xhx;
      Request.FY := Field.Yhx;
      Request.FL := Field.Lhx;
      Request.SetTokenEvent(Self);
      Request.FCreateNewMove := True;
      Request.FArmyID := FArmyHS.FArmy.CreateID(FSelection);
      if AoWEngine.FRegistry.GetCombatResolveMode = crmChoose then
      begin
        if AoWHSMap.FSeatedPlayer <> Request.FPlayer then
          AoWHSMap.CenterViewTo(FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx);
        FinishMove;
        FArmyHS := nil;
        AoWHSMap.TriggerExecuteEventLog(Request, False, RequestCombatTypeCallBack);
      end
      else
      begin
        FinishMove;
        FArmyHS := nil;
        if AoWEngine.FRegistry.GetCombatResolveMode = crmAlwaysTC then Request.Select(ctTactical)
        else Request.Select(ctFast);
        RequestCombatTypeCallBack(Request);
      end;
      Request.Release;
    end
    else
    begin
      FinishMove;
      FArmyHS := nil;
    end;
    FCombatMode := cmCancelCombat;
  end;
  if (FCombatMode = cmRequestingCombatType) and AoWHSMap.FRequestCombatType and
    (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType <> ptHuman) then
  begin
    Log := TNewTurnEventLog.Create(nil);
    Log.FTurnPlayer := Field.GetPlayer;
    Log.FMode := ntDialog;
    Log.FDialogStyle := [nsCloseable];
    Log.FText := TranslateRStr(P5YouAreBeingAttackedRStr);
    AoWHSMap.TriggerExecuteEventLog(Log, False, ShowHotSeatPlayerCallBack);
    Log.Release;
  end
  else if (FCombatMode = cmSetupReady) and (FCombatType = ctTactical) and
    AoWHSMap.FRequestCombatType and
    (AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FPlayerType <> ptHuman) then
  begin
    FCombatMode := cmSetupHotseat;
    Log := TNewTurnEventLog.Create(nil);
    Log.FTurnPlayer := Field.GetPlayer;
    Log.FMode := ntDialog;
    Log.FDialogStyle := [nsCloseable];
    Log.FText := TranslateRStr(P5YouAreBeingAttackedRStr);
    AoWHSMap.TriggerExecuteEventLog(Log, False, ShowHotSeatPlayerCallBack);
    Log.Release;
  end;
  if FCombatMode = cmRequestingCombatType then
  begin
    FArmyHS.PauseMove;
    Request := TCombatTypeRequestEventLog.Create(nil);
    Request.FPlayer := FArmyHS.FArmy.FPlayer;
    Request.FDefenderPlayer := Field.GetPlayer;
    Request.FX := Field.Xhx;
    Request.FY := Field.Yhx;
    Request.FL := Field.Lhx;
    if AoWHSMap.FSeatedPlayer <> Request.FPlayer then
      AoWHSMap.CenterViewTo(FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx);
    AoWHSMap.TriggerExecuteEventLog(Request, False, RequestCombatTypeCallBack);
    Request.Release;
  end;
end;

procedure TArmyCombatMoveTE.CombatExecuted(Combat: TCombat); { Near miss: combat-data argument register differs after three variants. }
var
  ArmyHS: TArmyHS;
  Army: TArmy;
  I: Integer;
  Selection: Byte;
  Move: TMoveArmyTE;
  Field: TAoWMapField;
begin
  if not (Combat is TFastCombat) then
  begin
    if Combat.FCombatResult in [crVictory] then
    begin
      ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(Combat.FCombatData.FAttackerX,
        Combat.FCombatData.FAttackerY, Combat.FCombatData.FAttackerL).FindOwnedChild($20217));
      if ArmyHS <> nil then
      begin
        Army := ArmyHS.FArmy;
        Selection := 0;
        for I := Army.Count - 1 downto 0 do
        begin
          Selection := Selection shl 1;
          if usMoving in Army.GetUnit(I).FUnitStatus then
          begin
            Selection := Selection or 1;
            Army.GetUnit(I).FUnitStatus := Army.GetUnit(I).FUnitStatus - [usMoving];
          end;
        end;
        if Selection <> 0 then
        begin
          Field := TAoWMapField(AoWHSMap.MapContainer.GetField(
            Combat.FCombatData.FX, Combat.FCombatData.FY, Combat.FCombatData.FL));
          if Field.GetPlayer = ArmyHS.FArmy.FPlayer then
            Move := CreateArmyMoveXYLTE(ArmyHS, Selection, Combat.FCombatData.FX,
              Combat.FCombatData.FY, Combat.FCombatData.FL, maNormal, [])
          else
          begin
            Move := CreateArmyMoveXYLTE(ArmyHS, Selection, Combat.FCombatData.FX,
              Combat.FCombatData.FY, Combat.FCombatData.FL, maAttack, []);
            if Move <> nil then TArmyCombatMoveTE(Move).FIgnoreDefenders := True;
          end;
          if Move <> nil then
          begin
            AoWHSMap.FTokenManager.TokenExecuter.AddSystemEvent(Move);
            Move.Release;
          end;
        end;
      end;
    end
    else
    begin
      ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(Combat.FCombatData.FAttackerX,
        Combat.FCombatData.FAttackerY, Combat.FCombatData.FAttackerL).FindOwnedChild($20217));
      if ArmyHS <> nil then
      begin
        for I := ArmyHS.FArmy.Count - 1 downto 0 do
          ArmyHS.FArmy.GetUnit(I).FUnitStatus := ArmyHS.FArmy.GetUnit(I).FUnitStatus - [usMoving];
        if ArmyHS.FArmy.FPlayer = AoWHSMap.FSeatedPlayer then AoWHSMap.FSelectedArmy.Select(ArmyHS);
      end;
    end;
    if AoWHSMap.FRequestCombatType and
      (Combat.FCombatData.FPlayers.GetPlayers(Combat.FCombatData.FAttackerPlayer).FPlayer <>
       AoWHSMap.FSeatedPlayer) then RestoreHotseatMode;
    AoWHSMap.SynchroniseBegin;
    DistributeCombatEvent(Combat.FLogbook, False);
    AoWHSMap.SynchroniseEnd;
  end;
end;

procedure TArmyCombatMoveTE.ExecuteCombat;
var CombatResult: TCombatResult;
  Field, Source: TAoWMapField;
  Defender: Shortint;
  OtherArmyHS, ArmyHS, MovedArmyHS: TArmyHS;
  I: Integer;
  Combat: TCombat;

  Msg: TMapFieldMsg;
  Log: TUserEventLog;
  Anim: TImageSequenceAnimation;
  AUnit: TAbstractUnit;
begin
  Field := GetMapF(FPath[0]);
  Defender := Field.GetPlayer;
  Source := TAoWMapField(FArmyHS.Owner);
  FArmyHS.SetOwner(nil);
  OtherArmyHS := Source.GetArmyHS;
  FArmyHS.SetOwner(Source);
  for I := 0 to FArmyHS.FArmy.Count - 1 do
  begin
    if FSelection and 1 <> 0 then
      FArmyHS.FArmy.GetUnit(I).FUnitStatus := FArmyHS.FArmy.GetUnit(I).FUnitStatus + [usMoving]
    else FArmyHS.FArmy.GetUnit(I).FUnitStatus := FArmyHS.FArmy.GetUnit(I).FUnitStatus - [usMoving];
    FSelection := FSelection shr 1;
  end;
  if OtherArmyHS <> nil then
  begin
    FArmyHS.FArmy.BeginUpdate;
    FArmyHS.FArmy.FMode := FArmyHS.FArmy.FMode + [amDisableTerrainValidation];
    for I := OtherArmyHS.FArmy.Count - 1 downto 0 do
    begin
      AUnit := OtherArmyHS.FArmy.GetUnit(I);
      AUnit.FUnitStatus := AUnit.FUnitStatus - [usMoving];
      FArmyHS.FArmy.AddUnit(AUnit);
    end;
    FArmyHS.FArmy.FMode := FArmyHS.FArmy.FMode - [amDisableTerrainValidation];
    FArmyHS.FArmy.EndUpdate;
  end;
  FArmyHS.CancelMove;
  AoWHSMap.LockGameOverEvent;
  if FCombatType = ctFast then Combat := AoWHSMap.CreateCombat($202B0)
  else Combat := AoWHSMap.CreateCombat($220110);
  Combat.Setup(FArmyHS.FArmy.FPlayer, FArmyHS.FArmy.FIndependentRelation,
    FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx, Field.GetPlayer,
    Field.GetIndependentRelation, FPath[0].X, FPath[0].Y, FPath[0].L, FCombatType = ctFast);
  Combat.FOnExecuted := CombatExecuted;
  Msg.MsgID := $1107;
  Msg.Param[0] := Integer(Combat);
  Msg.Param[1] := Integer(FArmyHS);
  Msg.Result := 0;
  Field.SendMapFieldMsg(Msg);
  if Msg.Result = 0 then
    Combat.InitDefaultArmies(FArmyHS.FArmy, FArmyHS.GetXhx, FArmyHS.GetYhx, FArmyHS.GetLhx);
  Combat.Initialize;
  Combat.Activate;
  CombatResult := Combat.Execute;
  FCombatMode := cmCombatExecuted;
  if CombatResult <> crBusy then
  begin
    Combat.Deactivate;
    Combat.Finalize;
    if Combat is TFastCombat then
    begin
      DistributeCombatEvent(Combat.FLogbook, True);
      if AoWHSMap.FRequestCombatType and (AoWHSMap.FSeatedPlayer = Defender) then
      begin
        Log := TUserEventLog.Create(nil);
        Log.FData := Self;
        AoWHSMap.TriggerExecuteEventLog(Log, False, RestoreHotSeatModeCallBack);
        Log.Release;
        AoWHSMap.FAIExecuter.Lock;
        AoWHSMap.LockGameOverEvent;
        FCombatMode := cmRestoringHotseat;
      end;
    end;
    if (CombatResult <> crNoDefenders) and
      AoWHSMap.VisibleForPlayer(FPath[0].X, FPath[0].Y, FPath[0].L, AoWHSMap.FSeatedPlayer) then
    begin
      Anim := TImageSequenceAnimation.Create(nil);
      Anim.SetImageSequence(AoWHSSet.FImageSequences.ImageSequences[$16]);
      AoWHSMap.PlaceHX(Anim, FPath[0].X, FPath[0].Y, FPath[0].L);
    end;
    AoWHSMap.DestroyCombat;
    AoWHSMap.UnlockGameOverEvent;
    FArmyHS := TArmyHS(GetMapF(FPath[FMoveIndex]).FindOwnedChild($20217));
    if (FArmyHS <> nil) and (CombatResult in [crCannotInflictDamage, crUndecided,
      crCannotBreachWall, crFled]) then
    begin
      FinishMove;
      FArmyHS := nil;
    end;
    if FArmyHS <> nil then
    begin
      FArmyHS.CancelMove;
      FArmyHS.FArmy.BeginUpdate;
      ArmyHS := TArmyHS.Create(nil);
      ArmyHS.FArmy.BeginUpdate;
      ArmyHS.FArmy.AssignSettings(FArmyHS.FArmy);
      ArmyHS.FDirection := FArmyHS.FDirection;
      ArmyHS.FArmy.SetPlayer(FArmyHS.FArmy.FPlayer);
      for I := FArmyHS.FArmy.Count - 1 downto 0 do
        if usMoving in FArmyHS.FArmy.GetUnit(I).FUnitStatus then
        begin
          FArmyHS.FArmy.GetUnit(I).FUnitStatus := FArmyHS.FArmy.GetUnit(I).FUnitStatus - [usMoving];
          ArmyHS.FArmy.AddUnit(FArmyHS.FArmy.GetUnit(I));
        end;
      ArmyHS.FArmy.EndUpdate;
      if ArmyHS.FArmy.Count <> 0 then
      begin
        ArmyHS.PlacePrivate(AoWHSMap.MapContainer, FPath[FMoveIndex].X,
          FPath[FMoveIndex].Y, FPath[FMoveIndex].L);
        if FArmyHS.GetSelected then
        begin
          AoWHSMap.Selection.UnselectLocation;
          AoWHSMap.Selection.SelectLocationHS(ArmyHS);
        end;
        FArmyHS.FArmy.FMode := FArmyHS.FArmy.FMode - [amMoving];
        FArmyHS.FArmy.EndUpdate;
        MovedArmyHS := ArmyHS; FArmyHS := MovedArmyHS;
        MovedArmyHS.FArmy.FMode := MovedArmyHS.FArmy.FMode + [amMoving];
        FSelection := $FF;
        if (CombatResult in [crVictory, crNoDefenders]) or inherited CanMoveNext then
        begin
          FArmyHS.MoveFirst(GetDirection(FMoveIndex), False);
          FArmyHS.SetMoveStatus(50);
        end else begin
          FinishMove; FArmyHS := nil; Exit;
        end;
      end
      else
      begin
        { The original drops the empty new army without freeing it. }
        FArmyHS.FArmy.FMode := FArmyHS.FArmy.FMode - [amMoving];
        FArmyHS.FArmy.EndUpdate;
        FArmyHS := nil;
      end;
    end;
  end
  else
  begin
    AoWHSMap.UnlockGameOverEvent;
    FArmyHS := nil;
    FinishMove;
  end;
end;



function TArmyCombatMoveTE.ExecuteLastMove: TMoveStatus;
begin
  if GetMapF(FPath[FMoveIndex - 1]).FindOwnedChild($20217) = nil then
  begin
    FArmyHS.MoveTo(GetMapF(FPath[FMoveIndex - 1]), FPath[FMoveIndex - 1].Flag);
    FArmyHS := nil;
  end
  else FArmyHS.CancelMove;
  Result := msDone;
end;

function TArmyCombatMoveTE.Animating: Boolean;
var Field: TAoWMapField;
begin
  if (FMoveIndex = 1) and (FCombatMode <> cmCombatExecuted) then
  begin
    if FArmyHS.GetMoveStatus <> -1 then
    begin
      Field := GetMapF(FPath[FMoveIndex - 1]);
      if Field.GetPlayer <> -1 then Result := FArmyHS.GetMoveStatus < 50
      else Result := FArmyHS.GetMoveStatus < 100;
    end
    else Result := False;
  end
  else Result := inherited Animating;
end;

function TArmyCombatMoveTE.CanMoveNext: Boolean;
var Field: TAoWMapField;
begin
  if FMoveIndex = 1 then
  begin
    { Evaluate the field without retaining a second reference. }
    if FArmyHS.FArmy.FPlayer <> GetMapF(FPath[0]).GetPlayer then
    begin
      Result := AoWHSMap.FPlayers.GetPlayers(FArmyHS.FArmy.FPlayer).FGameOverStatus = goNone;
      Exit;
    end;
  end;
  Result := inherited CanMoveNext;
end;

function TArmyCombatMoveTE.ExecuteMove: TMoveStatus;
var
  Field: TAoWMapField;
  Player: Shortint;
  Direction: Integer;
begin
  if (FMoveIndex = 1) and (FCombatMode = cmMoving) then
  begin
    Field := GetMapF(FPath[0]);
    Player := Field.GetPlayer;
    if (Player <> -1) and (Player <> FArmyHS.FArmy.FPlayer) and not FIgnoreDefenders then
    begin
      Direction := GetDirection(FMoveIndex + 1);
      if Direction = 0 then Direction := GetHT(FMoveIndex + 1);
      if (Direction > 0) and (Direction <= 6) then FArmyHS.SetDirection(Direction)
      else FArmyHS.SetDirection(0);
      SetupCombat;
      Result := msMoving;
    end
    else Result := inherited ExecuteMove;
  end
  else Result := inherited ExecuteMove;
end;

function TArmyCombatMoveTE.ProcessMove: TMoveStatus; { Retain Result assignment and place combat execution first. }
begin
  Result := msMoving; Result := Result;
  if FCombatMode = cmRestoringHotseat then begin Result := msMoving; Exit; end;
  if FCombatMode = cmSetupHotseat then Result := msMoving
  else if FCombatMode = cmCancelCombat then Result := msDone
  else if FCombatMode <> cmRequestingCombatType then
  begin
    if FCombatMode <> cmSetupReady then Result := inherited ProcessMove;
    if FCombatMode = cmSetupReady then
    begin
      if FCombatType <> ctNone then
      begin
        ExecuteCombat;
        if FArmyHS = nil then Result := msDone
        else Result := msMoving;
      end else Result := msDone;
    end;
  end;
end;


function CreateArmyMoveTE(Army: TArmyHS; Selection: Byte; Path: TMovepath; Action: TMoveAction; Mode: TArmyMoveMode): TMoveArmyTE;
var
  Move: TMoveArmyTE;
begin
  Result := nil;
  case Action of
    maNormal: Move := TArmyDefaultMoveTE.Create(nil);
    maCombine: Move := TArmyCombineMoveTE.Create(nil);
    maAttack: Move := TArmyCombatMoveTE.Create(nil);
    maNegotiate: Move := TArmyNegotiateMoveTE.Create(nil);
  else Move := nil;
  end;
  if Move <> nil then
    if not Move.Setup(Army, Selection, Path, Mode) then
    begin
      Result := nil;
      Move.Release;
    end
    else Result := Move;
end;

function CreateArmyMoveXYLTE(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Action: TMoveAction; Mode: TArmyMoveMode): TMoveArmyTE;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
    Result := CreateArmyMoveTE(Army, Selection, Settings.FPath, Action, [])
  else Result := nil;
  Settings.Release;
end;

function MoveArmyEx(Army: TArmyHS; Selection: Byte; Path: TMovepath; Mode: TArmyMoveMode; Force: Boolean): Boolean; { Near miss: Three variants retain different local/register allocation. }
var
  Pos: Integer;
  Move: TMoveArmyTE;
  Action: TMoveAction;
  Moved: Boolean;
begin
  Moved := False;
  if Force or not AoWHSMap.FPlayers.GetPlayers(Army.FArmy.FPlayer).GetBusy then
    if Path.Count > 1 then
    begin
      Pos := Path.MovePointsToPos(Army.FArmy.MovePoints(Selection));
      if Pos = 0 then
        Action := TAoWMapField(AoWHSMap.MapContainer.GetField(Path[Pos].X, Path[Pos].Y, Path[Pos].L)).GetMoveAction(Army.FArmy.FPlayer)
      else Action := maNormal;
      if (Action = maAttack) and
        (AoWHSMap.FPlayers.GetPlayers(Army.FArmy.FPlayer).FPlayerType = ptHuman) and
        not AoWHSMap.VisibleForPlayer(Path[0].X, Path[0].Y, Path[0].L, Army.FArmy.FPlayer) then
        Action := maNormal;
      Move := CreateArmyMoveTE(Army, Selection, Path, Action, Mode);
      if Move <> nil then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(Army.FArmy.FPlayer).AddEvent(Move);
        Move.Release;
        Moved := True;
      end;
    end;
  Result := Moved;
end;

function MoveArmy(Army: TArmyHS; Selection: Byte; Path: TMovepath): Boolean;
begin
  Result := MoveArmyEx(Army, Selection, Path, [mmSelectEndLocation], False);
end;

function MoveArmyXYL(Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Force: Boolean): Boolean;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
    Result := MoveArmyEx(Army, Selection, Settings.FPath, [], Force)
  else Result := False;
  Settings.Release;
end;

function MoveArmyXYLEx(Player: Shortint; Army: TArmyHS; Selection: Byte; X, Y, L: Shortint; Action: TMoveAction; Force: Boolean): TMoveArmyTE;
var
  Settings: TMoveControlSettings;
begin
  Settings := TMoveControlSettings.Create(nil);
  Settings.SetSourcePos(Army.GetXhx, Army.GetYhx, Army.GetLhx);
  Settings.FPlayer := Army.FArmy.FPlayer;
  Settings.FArmyHS := Army;
  Settings.FSelection := Selection;
  Settings.SetDestinationPos(X, Y, L);
  Army.FArmy.CreateMovePointTable(Selection, Settings.FMovePointTable);
  AoWHSMap.FMoveControl.ProcessMove(Settings);
  if Settings.FPath.Count <> 0 then
  begin
    if (Force or AoWHSMap.FTokenManager.PlayerReady(Player)) and (Settings.FPath.Count > 1) then
    begin
      Result := CreateArmyMoveTE(Army, Selection, Settings.FPath, Action, []);
      if Result <> nil then
      begin
        AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Result);
        { Original returns the token-event pointer after releasing its reference. }
        Result.Release;
      end
      else Result := nil;
    end
    else Result := nil;
  end
  else Result := nil;
  Settings.Release;
end;

class function TGameOverTE.ClassID: Integer;
begin Result := $21111; end;

procedure TGameOverTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
  Stream.rwData(FGameOverStatus, SizeOf(FGameOverStatus), $15);
end;

function TGameOverTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  AoWHSMap.FPlayerControl.GameOver(FPlayer, FGameOverStatus);
  Result := erDone;
end;

class function TTerminatePlayerTE.ClassID: Integer;
begin Result := $202FC; end;

procedure TTerminatePlayerTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
end;

function TTerminatePlayerTE.Execute(TE: TTokenExecuter): TExecuteResult;
var
  Log: TMessageEventLog;
begin
  AoWHSMap.FPlayers.GetPlayers(FPlayer).FPlayerType := ptCPU3;
  with TRemotePCC(AoWHSMap.FPlayerCommunicator.PCC) do
  begin
    SetConnectionMode(FPlayer, cmGlobal);
    SetSystemID(FPlayer, 0);
  end;
  if not AoWHSMap.FPlayers.GetPlayers(FPlayer).FSingleProcessCycle then
    AoWHSMap.FPlayerControl.EndTurn(FPlayer);
  AoWHSMap.FPlayers.Update;
  if AoWHSMap.FSeatedPlayer <> FPlayer then
  begin
    Log := TMessageEventLog.Create(nil);
    Log.FButtons := mebOk;
    Log.FLayout := melNormal;
    Log.FMessage.Add(Format(TranslateRStr(P5XLeftTheGameRStr),
      [AoWHSMap.FPlayers.GetPlayers(FPlayer).GetName])); { Append the departure message, as in the original. }
    AoWHSMap.TriggerExecuteEventLog(Log, False, nil);
    Log.Release;
  end
  else
  begin
    AoWHSMap.ExecuteExitGame;
    if Assigned(FExitCallBack) then FExitCallBack(FExitMode, True);
  end;
  Result := erDone;
end;

constructor TMultiMoveTE.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FEvents := TTokenEventList.Create(nil);
  FSimultaneous := True;
end;

destructor TMultiMoveTE.Destroy;
begin
  FEvents.Free;
  inherited Destroy;
end;

class function TMultiMoveTE.ClassID: Integer;
begin Result := $21112; end;

procedure TMultiMoveTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(FEvents, $14);
  Stream.rwBool(FSimultaneous, $15);
end;

function TMultiMoveTE.Execute(TE: TTokenExecuter): TExecuteResult;
var
  Events: TTokenEventList;
  Valid: Boolean;
  MoveResult: TExecuteResult;
  I: Integer;
begin
  Events := FEvents;
  if TE.ExecuteCount = 0 then
  begin
    I := Events.Count;
    Valid := True;
    while I <> 0 do
    begin
      Dec(I);
      { The original retains only the final validation result. }
      Valid := TMoveTE(Events[I]).Validate;
    end;
  end
  else Valid := True;
  if Valid then
  begin
    if FSimultaneous then
    begin
      for I := Events.Count - 1 downto 0 do
      begin
        MoveResult := Events[I].Execute(TE);
        if (MoveResult = erDone) or (MoveResult = erDoneHalt) then Events.Delete(I);
      end;
    end
    else
    begin
      MoveResult := erDone;
      while (MoveResult in [erDone, erDoneHalt]) and (FEvents.Count > 0) do
      begin
        MoveResult := Events[0].Execute(TE);
        if (MoveResult = erDone) or (MoveResult = erDoneHalt) then Events.Delete(0);
      end;
    end;
  end;
  if not Valid or (FEvents.Count = 0) then MoveResult := erDone
  else MoveResult := erRetry; Result := MoveResult;
end;

function ValidateMultiArmyMove(Moves: TMoveSettingsList; Index: Integer): Boolean;
var
  UnitCount, Transporters, Capacity: Integer;
  Player: Shortint;
  Settings: TMoveSettings;
  I: Integer;
  Field: TAoWMapField;
  OwnerPlayer: Shortint;
  Location: TXYL;
  ArmyHS: TArmyHS;

  procedure AddArmy(ArmyHS: TArmyHS; Selection: Byte);
  var Transporter: TAbstractUnit;
  begin
    Inc(UnitCount, ArmyHS.FArmy.SelectionCount(Selection));
    Transporter := ArmyHS.FArmy.Transporter(Selection);
    if Transporter <> nil then
    begin
      Inc(Transporters);
      if Transporter.GetTransportCapacity + 1 < Capacity then
        Capacity := Transporter.GetTransportCapacity + 1;
    end;
  end;

begin
  Result := True;
  Player := TArmyHS(Moves.GetMoveSettings(Index).FMoveObject).FArmy.FPlayer;
  Settings := Moves.GetMoveSettings(Index);
  I := Settings.FMovePos;
  while Result and (I <> Settings.FPath.Count) do
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(
      Settings.FPath[I].X, Settings.FPath[I].Y, Settings.FPath[I].L));
    OwnerPlayer := Field.GetPlayer;
    Result := (OwnerPlayer = -1) or (OwnerPlayer = Player);
    Inc(I);
  end;
  if Result then
  begin
    UnitCount := 0;
    Transporters := 0;
    Capacity := 8;
    AddArmy(TArmyHS(Moves.GetMoveSettings(Index).FMoveObject), Moves.GetMoveSettings(Index).FSelection);
    Location := Moves.GetMoveSettings(Index).GetMoveLoc;
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(Location.X, Location.Y, Location.L));
    ArmyHS := TArmyHS(Field.FindOwnedChild($20217));
    if ArmyHS <> nil then AddArmy(ArmyHS, $FF);
    for I := Moves.Count - 1 downto 0 do
      if I <> Index then
      begin
        Settings := Moves.GetMoveSettings(I);
        if Settings.FValid and
          (Moves.GetMoveSettings(Index).GetMovePrio >= Settings.GetMovePrio) and
          (Integer(Settings.GetMoveLoc) = Integer(Moves.GetMoveSettings(Index).GetMoveLoc)) then
          AddArmy(TArmyHS(Settings.FMoveObject), Settings.FSelection);
      end;
    Result := (UnitCount <= Capacity) and (Transporters <= 1);
  end;
end;

function ExecuteMultiArmyMove(Moves: TMoveSettingsList): Boolean;
var
  Multi: TMultiMoveTE;
  Path: TMovepath;
  I, J: Integer;
  Settings: TMoveSettings;
  Move: TArmyDefaultMoveTE;
begin
  if (Moves.Count <> 0) and AoWHSMap.FTokenManager.PlayerReady(
    TArmyHS(Moves.GetMoveSettings(0).FMoveObject).FArmy.FPlayer) then
  begin
    Path := TMovepath.Create;
    Multi := TMultiMoveTE.Create(nil);
    Multi.FSimultaneous := False;
    Moves.CalculateMovePositions(ValidateMultiArmyMove);
    for I := 0 to Moves.Count - 1 do
    begin
      Settings := Moves.GetMoveSettings(I);
      if Settings.FMovePos < Settings.FPath.Count - 1 then
      begin
        Path.Clear;
        for J := Settings.FMovePos to Settings.FPath.Count - 1 do Path.Add(Settings.FPath[J]);
        Move := TArmyDefaultMoveTE.Create(nil);
        AoWEngine.OutputDebugStr('Moving to: ' + IntToStr(Path[0].X) + ',' +
          IntToStr(Path[0].Y) + ',' + IntToStr(Path[0].L));
        if Move.Setup(TArmyHS(Settings.FMoveObject), Settings.FSelection, Path, []) then
          Multi.FEvents.Add(Move);
        Move.Release;
      end;
    end;
    if Multi.FEvents.Count <> 0 then
    begin
      AoWHSMap.FTokenManager.GetTokenControl(
        TArmyHS(Moves.GetMoveSettings(0).FMoveObject).FArmy.FPlayer).AddEvent(Multi);
      Result := True;
    end
    else Result := False;
    Multi.Release;
    Path.Free;
  end
  else Result := False;
end;


class function TCheatTE.ClassID: Integer;
begin Result := $202F5; end;

procedure TCheatTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
  Stream.rwInteger(FCheatID, $15);
end;

function TCheatTE.Execute(TE: TTokenExecuter): TExecuteResult;
var
  I, J: Integer;
begin
  inherited Execute(TE);
  case FCheatID of
    0:
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        AoWHSMap.FPlayers.GetPlayers(I).SetGems(AoWHSMap.FPlayers.GetPlayers(I).FGems + 1000);
    1:
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
        AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.SetMana(
          AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FMana + 1000);
    2:
      begin
        AoWHSMap.SetExplorationEnabled(not AoWHSMap.FExplorationEnabled);
        if AoWHSMap.FExplorationEnabled then
          AoWHSMap.ShowMessage(TranslateRStr(P5ExplorationEnabledRStr))
        else AoWHSMap.ShowMessage(TranslateRStr(P5ExplorationDisabledRStr));
      end;
    3:
      begin
        AoWHSMap.SetFogEnabled(not AoWHSMap.FFogEnabled);
        if AoWHSMap.FFogEnabled then AoWHSMap.ShowMessage(TranslateRStr(P5FogEnabledRStr))
        else AoWHSMap.ShowMessage(TranslateRStr(P5FogDisabledRStr));
      end;
    4:
      begin
        AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.FCheatEnabled :=
          not AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled;
        if AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled then
          AoWHSMap.ShowMessage(TranslateRStr(P5SpellCheatEnabledRStr))
        else AoWHSMap.ShowMessage(TranslateRStr(P5SpellCheatDisabledRStr));
        for I := 1 to AoWHSMap.FPlayers.Count - 1 do
          AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FCheatEnabled :=
            AoWHSMap.FPlayers.GetPlayers(FPlayer).FMagicControl.GetCheatEnabled;
      end;
    5: AoWHSMap.FPlayerControl.GameOver(FPlayer, goWon);
    6:
      begin
        AoWHSMap.FUnlimitedMoves := not AoWHSMap.FUnlimitedMoves;
        if AoWHSMap.FUnlimitedMoves then AoWHSMap.ShowMessage(TranslateRStr(P5FreeMovementEnabledRStr))
        else AoWHSMap.ShowMessage(TranslateRStr(P5FreeMovementDisabledRStr));
      end;
    7:
      for I := AoWHSMap.FPlayers.GetPlayers(0).FStructures.Count - 1 downto 0 do
        if AoWHSMap.FPlayers.GetPlayers(0).FStructures.GetStructure(I).ClassID = $20108 then
          AoWHSMap.FPlayers.GetPlayers(0).FStructures.GetStructure(I).SetPlayer(FPlayer);
    8: AoWHSMap.FPlayerControl.GameOver(FPlayer, goLost);
    9:
      for I := 1 to AoWHSMap.FPlayers.Count - 1 do
      begin
        AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FSpells.Clear;
        for J := 1 to AoWHSSet.FSpellControl.GetCount - 1 do
          if AoWHSSet.FSpellControl.GetSpell(J) <> nil then
            AoWHSMap.FPlayers.GetPlayers(I).FMagicControl.FSpells.Add(J);
      end;
  end;
  PlaySample('SFX\ATTACK\MAGICB01.WAV');
  Result := erDone;
end;

class function TDisbandUnitTE.ClassID: Integer;
begin Result := $21117; end;

procedure TDisbandUnitTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
  Stream.rwInteger(FUnitID, $15);
end;

function TDisbandUnitTE.Execute(TE: TTokenExecuter): TExecuteResult;
var
  AUnit: TAbstractUnit;
  Structure: TPlayerStructure;
  ArmyHS: TArmyHS;
  Behavior: TGroupBehavior;
  I, N: Integer;
  X, Y, L: Shortint;
begin
  AUnit := AoWHSMap.FUnitControl.FindUnit(FUnitID);
  if (AUnit <> nil) and (AUnit.FPlayer = FPlayer) then
  begin
    AUnit.AddRef;
    if (AUnit.GetRace = 5) and (AUnit.FPlayer > 0) and
      (AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FPlayerRace = 5) and
      (AUnit.GetAbilityEnabled($A2) or AUnit.GetAbilityEnabled($A4) or AUnit.GetAbilityEnabled($A5)) then
      AoWHSMap.FPlayers.GetPlayers(AUnit.FPlayer).FHeroEmerging := True;
    if not AUnit.GetAbilityEnabled($9B) then
    begin
      AUnit.GetLocation(X, Y, L);
      Structure := TPlayerStructure(AoWHSMap.MapContainer.GetField(X, Y, L).
        FindNoneTransparentHS(TPlayerStructure));
      if not (AUnit.Owner is TArmy) or (TArmy(AUnit.Owner).Count > 1) or
        ((Structure <> nil) and (Structure.FPlayer > 0)) then
      begin
        AUnit.GetLocation(X, Y, L);
        AUnit.SetOwner(nil);
        ArmyHS := AUnit.Place(X, Y, L, 0, [pmScanArea]);
      end
      else
      begin
        TArmy(AUnit.Owner).SetPlayer(0);
        ArmyHS := TArmy(AUnit.Owner).GetArmyHS;
      end;
      if ArmyHS <> nil then
      begin
        N := AoWHSMap.Random(10);
        if N = 0 then Behavior := gbGuardArea
        else if N < 7 then Behavior := gbScout
        else Behavior := gbRaid;
        I := ArmyHS.FArmy.IndexOfBehavior(Behavior);
        if I = -1 then ArmyHS.FArmy.SetBehavior(1 shl ArmyHS.FArmy.IndexOf(AUnit), Behavior)
        else ArmyHS.FArmy.SetGroup(1 shl ArmyHS.FArmy.IndexOf(AUnit), ArmyHS.FArmy.GetUnit(I).FGroup);
      end;
    end
    else AUnit.Killed;
    AUnit.RemoveEnchantments;
    AUnit.Release;
    if AoWHSMap.FSeatedPlayer = FPlayer then AoWHSMap.FSelectedArmy.Unselect;
    AoWHSMap.FPlayers.GetPlayers(FPlayer).UpdateIncome;
  end;
  Result := erDone;
end;

class function TCombatFlowControlTE.ClassID: Integer;
begin Result := $21118; end;

procedure TCombatFlowControlTE.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FMode, SizeOf(FMode), $1E);
  Stream.rwInteger(FPlayer, $1F);
end;

function TCombatFlowControlTE.Execute(TE: TTokenExecuter): TExecuteResult;
begin
  if cfmSetAutoSwitch in FMode then AoWHSMap.FTokenManager.TokenExecuter.HoldTC := False;
  if cfmLockAIExecuter in FMode then AoWHSMap.FAIExecuter.Lock;
  if cfmUnlockAIExecuter in FMode then AoWHSMap.FAIExecuter.Unlock;
  if cfmActivateTC in FMode then AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(FPlayer);
  if cfmEnableTurnTimer in FMode then AoWHSMap.EnableTurnTimer;
  if cfmDisableTurnTimer in FMode then AoWHSMap.DisableTurnTimer;
  Result := erDone;
end;

constructor TPadControl.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainTypes := TBitList.Create;
  FPadResources := TList.Create;
  SetControlStyle([csFixedChild]);
end;

destructor TPadControl.Destroy;
begin
  FTerrainTypes.Free;
  FPadResources.Free;
  inherited Destroy;
end;

function TPadControl.GetPadResource(Size: Integer): TMapObjectResource;
begin
  if Size < FPadResources.Count then Result := FPadResources.List^[Size]
  else Result := nil;
end;

procedure TPadControl.SetPadResource(Size: Integer; Resource: TMapObjectResource);
begin
  while FPadResources.Count <= Size do FPadResources.Add(nil);
  FPadResources.List^[Size] := Resource;
end;

procedure TPadControl.RegisterPadResource(Resource: TMapObjectResource; Size: Integer);
begin
  if GetPadResource(Size) = nil then SetPadResource(Size, Resource);
end;

procedure TPadControl.UnregisterPadResource(Resource: TMapObjectResource; Size: Integer);
begin
  if Resource = GetPadResource(Size) then SetPadResource(Size, nil);
end;

function TPadControl.CanPlacePad(X, Y, L: Shortint; Size: Integer): Boolean;
var
  Resource: TMapObjectResource;
  Pad: TILTerrainMO;
begin
  Resource := GetPadResource(Size);
  if Resource <> nil then
  begin
    Pad := TILTerrainMO(Resource.CreateResourceUser);
    Result := Pad.CanPlace(AoWHSMap.MapContainer, X, Y, L);
    Pad.Free;
  end
  else Result := False;
end;

function TPadControl.PlacePad(X, Y, L: Shortint; Size: Integer): TILTerrainMO;
var Resource: TMapObjectResource;
begin
  Resource := GetPadResource(Size);
  if Resource <> nil then Result := TILTerrainMO(Resource.PlaceResourceUser(AoWHSMap, X, Y, L))
  else Result := nil;
end;

