constructor TTutorialControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FShownMessages := TIntegerList.Create;
end;
destructor TTutorialControl.Destroy;
begin
  FShownMessages.Free;
  inherited Destroy;
end;
procedure TTutorialControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc($14, FShownMessages.LoadFromStream, FShownMessages.SaveToStream);
end;
procedure TTutorialControl.ShowMessage(ID: Integer; Immediate, OnceOnly: Boolean); { Match: the addressable event log retains the original Self register. }
var
  Log: TTutorialMessageEventLog; LogAddress: Pointer;
begin LogAddress := @Log;
  if (AoWHSMap.FGameType = gtTutorial) and (AoWHSMap.FTextControl.FindID(ID) <> nil) then
  begin
    if OnceOnly and (FShownMessages.IndexOf(ID) <> -1) then Exit;
    Log := TTutorialMessageEventLog.Create(nil);
    Log.FMessage.Assign(AoWHSMap.FTextControl.FindID(ID).FText);
    AoWHSMap.TriggerExecuteEventLog(Log, Immediate, nil);
    Log.Release;
    FShownMessages.Add(ID);
  end;
end;
class function TAoWMapField.ClassID: Integer;
begin
  Result := $20012;
end;
function TAoWMapField.GetExplored(Player: Integer): Boolean;
asm
  STC
  MOV ECX, EDX
  MOV EDX, [EAX].FFieldFlags
  RCR EDX, CL
  JC @@Explored
  XOR AL, AL
  RET
@@Explored:
  MOV AL, 1
end;
procedure TAoWMapField.SetExplored(Player: Integer; Value: Boolean);
asm
  { Original tests the entire ECX register for a Boolean passed in CL. }
  TEST ECX, ECX
  JZ @@Clear
  LEA ECX, [EDX-1]
  MOV EDX, 1
  SHL EDX, CL
  OR [EAX].FFieldFlags, EDX
  RET
@@Clear:
  LEA ECX, [EDX-1]
  MOV EDX, 1
  SHL EDX, CL
  NOT EDX
  AND [EAX].FFieldFlags, EDX
end;
procedure TAoWMapField.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwWord(LongRec(FFieldFlags).Lo, 4);
end;
procedure TAoWMapField.FogChanged;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1106;
  SendMapFieldMsg(Msg);
end;
procedure TAoWMapField.SetFogCount(Value: Byte);
begin
  if ((Value = 0) and (WordRec(LongRec(FFieldFlags).Hi).Lo <> 0)) or
    ((Value <> 0) and (WordRec(LongRec(FFieldFlags).Hi).Lo = 0)) then
  begin
    WordRec(LongRec(FFieldFlags).Hi).Lo := Value;
    FogChanged;
  end
  else WordRec(LongRec(FFieldFlags).Hi).Lo := Value;
end;
procedure TAoWMapField.UpdateMapField;
begin
  FFieldFlags := FFieldFlags and $FFFF1FFF;
  inherited UpdateMapField;
end;
function TAoWMapField.GetPlayer: Shortint;
var
  Msg: TMapFieldMsg;
begin
  if FFieldFlags and $02000000 <> 0 then
  begin
    Msg.MsgID := $1100;
    Msg.Result := -1;
    SendMapFieldMsg(Msg);
    Result := Msg.Result;
  end
  else Result := -1;
end;
function TAoWMapField.GetScannerIcon: Integer;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $110C;
  Msg.Param[0] := 0;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0];
end;
function TAoWMapField.GetCombatTerrainTag: Integer;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1122;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;
function TAoWMapField.GetConcealmentActive: Boolean;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1128;
  Msg.Result := 0;
  Msg.Param[0] := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0] <> 0;
end;
function TAoWMapField.GetMagicShieldActive: Boolean;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1129;
  Msg.Result := 0;
  Msg.Param[0] := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Param[0] <> 0;
end;
function TAoWMapField.GetProductionControl: TProductionControl;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1201;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := TProductionControl(Msg.Result);
end;
function TAoWMapField.GetAITarget(Control: TAIGroupControl; const Info: TAITargetInfo; var Data: TAITargetData): Boolean;
var
  Msg: TMapFieldMsg;
begin
  FillChar(Data, SizeOf(Data), 0);
  Data.TargetType := Low(TAITargetType);
  Msg.MsgID := $1200;
  Msg.Param[0] := Integer(@Info);
  Msg.Param[1] := Integer(@Data);
  Msg.Param[2] := Integer(Control);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Data.Priority <> 0;
end;
function TAoWMapField.GetMoveAction(Player: Shortint): TMoveAction;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1101;
  Msg.Param[0] := Player;
  Msg.Param[1] := 0;
  SendMapFieldMsg(Msg);
  Result := TMoveAction(Msg.Param[1]);
end;
function TAoWMapField.GetIndependentRelation: Byte;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1125;
  Msg.Result := -1;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;
function TAoWMapField.GetDefensePriority: Byte;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1126;
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := Msg.Result;
end;
procedure TAoWMapField.GetDefenseRequirements(Player: Shortint; var Requirements: TDefenseRequirements);
var
  Msg: TMapFieldMsg;
begin
  FillChar(Requirements, SizeOf(Requirements), 0);
  Msg.MsgID := $1127;
  Msg.Param[0] := Player;
  Msg.Param[1] := Integer(@Requirements);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
end;
function TAoWMapField.GetWallType: TWallType;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1123;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
  Result := TWallType(Msg.Result);
end;
function TAoWMapField.GetArmyHS: TArmyHS;
begin
  Result := TArmyHS(FindOwnedChild($20217));
end;
procedure TAoWMapField.RestoreTerrain;
var
  Msg: TMapFieldMsg;
begin
  Msg.MsgID := $1132;
  Msg.Param[0] := Integer(Self);
  Msg.Result := 0;
  SendMapFieldMsg(Msg);
end;
class function TAoWMapLevel.ClassID: Integer;
begin
  Result := $20013;
end;
function TAoWMapLevel.MapFieldClass: Engine.TEObjectClass;
begin
  Result := TAoWMapField;
end;
function TAoWMapLevel.FogArea(X, Y, Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets[Walk.X] + FYOffsets[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 1 then Result := True;
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo - 1);
    end;
    WalkToNextHN(Walk);
  end;
end;
function TAoWMapLevel.UnFogArea(X, Y, Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets[Walk.X] + FYOffsets[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := True;
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo + 1);
    end;
    WalkToNextHN(Walk);
  end;
end;
function TAoWMapLevel.UnFogExploreArea(X, Y: Integer; Player: Shortint; Radius: Integer): TFogExplorationChanged;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Assert(Player >= 0, 'Invalid Player Index');
  Result := [];
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets[Walk.X] + FYOffsets[Walk.Y]);
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then Result := Result + [feFog];
      Field.SetFogCount(WordRec(LongRec(Field.FFieldFlags).Hi).Lo + 1);
      if not Field.GetExplored(Player) then
      begin
        Result := Result + [feExploration];
        Field.SetExplored(Player, True);
        if TAbstractAoWHSMap(FMap).FExplorationEnabled and
          (TAbstractAoWHSMap(FMap).FSeatedPlayer = Player) then
          FMap.InvalidateStaticScene(Walk.X, Walk.Y, FLhx);
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

function TAoWMapLevel.ExploreArea(X, Y: Integer; Player: Shortint; Radius: Integer): Boolean;
var
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  Result := False;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < FWidth) and (Walk.Y < FHeight) then
    begin
      Field := TAoWMapField(FXOffsets^[Walk.X] + FYOffsets^[Walk.Y]);
      if not Field.GetExplored(Player) then
      begin
        Field.SetExplored(Player, True);
        if TAbstractAoWHSMap(FMap).FExplorationEnabled and
          (TAbstractAoWHSMap(FMap).FSeatedPlayer = Player) then
          FMap.InvalidateStaticScene(Walk.X, Walk.Y, FLhx);
        Result := True;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;

procedure TAoWMapLevel.ResetFog;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.SetFogCount(0);
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

procedure TAoWMapLevel.ResetUnFog;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.SetFogCount(1);
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

procedure TAoWMapLevel.Reset;
var
  I, N: Integer;
  Field: TAoWMapField;
begin
  N := Count - 1;
  Field := FFields;
  for I := 0 to N do
  begin
    Field.FFieldFlags := 0;
    Field := Pointer(Integer(Field) + FFieldSize);
  end;
end;

constructor TAbstractAoWHSMap.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FShowMessageEvents := TEventList.Create;
  FMapChangedEvents := TEventList.Create;
  FScannerIconsChangedEvents := TEventList.Create;
  FBackHexagonSelector := TCustomFixedVisibleHS.Create(nil);
  FBackHexagonSelector.OnShow := ShowBackHexagonSelector;
  FFrontHexagonSelector := TCustomFixedVisibleHS.Create(nil);
  FFrontHexagonSelector.OnShow := ShowFrontHexagonSelector;
  FHexagonSelectorVisible := False;
  FExplorationEnabled := True;
  FFogEnabled := True;
  FSeatedPlayer := 1;
  FFPS := 30;
end;

destructor TAbstractAoWHSMap.Destroy;
begin
  FShowMessageEvents.Clear;
  FMapChangedEvents.Clear;
  HideHexagonSelector;
  FBackHexagonSelector.Free;
  FFrontHexagonSelector.Free;
  FScannerIconsChangedEvents.Free;
  inherited Destroy;
  FShowMessageEvents.Free;
  FMapChangedEvents.Free;
end;

function TAbstractAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin
  Result := TAbstractAoWHSMapMouse.Create;
end;

procedure TAbstractAoWHSMap.SetFogEnabled(Value: Boolean);
begin
  if Value <> FFogEnabled then
  begin
    FFogEnabled := Value;
    InvalidateMap;
  end;
end;

procedure TAbstractAoWHSMap.SetExplorationEnabled(Value: Boolean);
begin
  if Value <> FExplorationEnabled then
  begin
    FExplorationEnabled := Value;
    StaticSceneInvalid := True;
    InvalidateMap;
  end;
end;

procedure TAbstractAoWHSMap.PlayCenterAnimation(X, Y, L: Shortint);
var
  Animation: TImageSequenceAnimation;
begin
  Animation := TImageSequenceAnimation.Create(nil);
  Animation.SetImageSequence(AoWHSSet.FImageSequences.GetImageSequence(11));
  PlaceHX(Animation, X, Y, L);
  PlaySample('SFX\INT\CENTER.WAV');
end;

procedure TAbstractAoWHSMap.LockMapChangedEvent;
begin
  Inc(FMapChangedLockCount);
end;

procedure TAbstractAoWHSMap.UnlockMapChangedEvent;
begin
  Assert(FMapChangedLockCount <> 0, 'Invalid MapChanged Lock usage');
  Dec(FMapChangedLockCount);
end;
procedure TAbstractAoWHSMap.TriggerTerrainChangedEvent(const R: Windows.TRect; L: Shortint);
begin
  inherited TriggerTerrainChangedEvent(R, L);
  if FMapChangedLockCount = 0 then TriggerMapChangedEvent(R, L);
end;
procedure TAbstractAoWHSMap.MapChanged(const R: TRect; L: Integer);
begin
  if (FMapChangedLockCount = 0) and (msActivated in Status) then
    TriggerTerrainChangedEvent(R, L);
end;

procedure TAbstractAoWHSMap.MapChangedRad(X, Y, L, Radius: Integer);
var
  R: TRect;
  Level: TMapLevel;
begin
  Level := MapContainer.GetMapLevel(L);
  R.Left := X - Radius;
  if R.Left < 0 then R.Left := 0;
  R.Right := X + Radius + 1;
  if R.Right > Level.Width then R.Right := Level.Width;
  R.Top := Y - Radius;
  if R.Top < 0 then R.Top := 0;
  R.Bottom := Y + Radius + 1;
  if R.Bottom > Level.Height then R.Bottom := Level.Height;
  TerrainChanged(R, L);
end;

procedure TAbstractAoWHSMap.InvalidateMap;
var
  R: TRect;
  I: Integer;
begin
  R.Left := 0;
  R.Right := MapContainer.Width;
  R.Top := 0;
  R.Bottom := MapContainer.Height;
  for I := 0 to MapContainer.LevelCount - 1 do MapChanged(R, I);
end;

procedure TAbstractAoWHSMap.TriggerMapChangedEvent(const R: TRect; L: Integer);
var
  Info: TMapChangedInfo;
begin
  Info.Bounds := R;
  Info.Level := L;
  Info.MapLevel := MapContainer.GetMapLevel(L);
  FMapChangedEvents.TriggerNotifyEvents(TObject(@Info));
end;

procedure TAbstractAoWHSMap.LockScannerIconsChangedEvent;
begin
  Inc(FScannerIconsChangedLockCount);
end;

procedure TAbstractAoWHSMap.UnlockScannerIconsChangedEvent;
begin
  Assert(FScannerIconsChangedLockCount <> 0, 'Invalid ScannerIcons Lock usage');
  Dec(FScannerIconsChangedLockCount);
end;
procedure TAbstractAoWHSMap.ScannerIconsChanged(const R: TRect; L: Integer);
begin
  if (FScannerIconsChangedLockCount = 0) and
    ([msActivated, msDestroying] * Status = [msActivated]) then
    TriggerScannerIconsChangedEvent(R, L);
end;
procedure TAbstractAoWHSMap.ScannerIconsChangedRad(Xhx, Yhx, Lhx, Radius: Integer);
var
  R: TRect;
  Level: TMapLevel;
begin
  Level := MapContainer.GetMapLevel(Lhx);
  R.Left := Xhx - Radius;
  if R.Left < 0 then R.Left := 0;
  R.Right := Xhx + Radius + 1;
  if R.Right > Level.Width then R.Right := Level.Width;
  R.Top := Yhx - Radius;
  if R.Top < 0 then R.Top := 0;
  R.Bottom := Yhx + Radius + 1;
  if R.Bottom > Level.Height then R.Bottom := Level.Height;
  ScannerIconsChanged(R, Lhx);
end;
procedure TAbstractAoWHSMap.InvalidateScannerIcons;
var
  R: TRect;
  I: Integer;
begin
  R.Left := 0;
  R.Right := MapContainer.Width;
  R.Top := 0;
  R.Bottom := MapContainer.Height;
  for I := 0 to MapContainer.LevelCount - 1 do ScannerIconsChanged(R, I);
end;
procedure TAbstractAoWHSMap.TriggerScannerIconsChangedEvent(const R: TRect; L: Integer);
var
  Info: TMapChangedInfo;
begin
  Info.Bounds := R;
  Info.Level := L;
  Info.MapLevel := MapContainer.GetMapLevel(L);
  FScannerIconsChangedEvents.TriggerNotifyEvents(TObject(@Info));
end;
procedure TAbstractAoWHSMap.UpdateShowMessage;
var
  Info: TShowMessageInfo;
begin
  if FMessageFrame <> 0 then
  begin
    Dec(FMessageFrame);
    if (((FMessageFrame and $10) = 0) and ((FMessageFrame and $0F) < 7)) or
      (((FMessageFrame and $10) = $10) and ((FMessageFrame and $0F) < 11)) then
    begin
      Info.Text := FMessageText;
      FMessageFrame := FMessageFrame and $F0;
      if (FMessageFrame and $10) = 0 then Info.Color := $353535
      else Info.Color := $FFFFFF;
      FShowMessageEvents.TriggerNotifyEvents(TObject(@Info));
    end;
    if FMessageFrame = 0 then
    begin
      Info.Text := '';
      Info.Color := $FFFFFF;
      FShowMessageEvents.TriggerNotifyEvents(TObject(@Info));
    end;
  end;
end;
procedure TAbstractAoWHSMap.ShowWarning(const Text: string);
var
  Info: TShowMessageInfo;
begin
  if not AoWEngine.FRegistry.GetDebugMode and (Text <> '') then
    PlaySample('SFX\EVENTS\INFO2.WAV');
  Info.Text := Text;
  Info.Color := $FFFFFF;
  FShowMessageEvents.TriggerNotifyEvents(TObject(@Info));
  FMessageText := Text;
  FMessageFrame := $A0;
end;
procedure TAbstractAoWHSMap.ShowMessage(const Text: string);
var
  Info: TShowMessageInfo;
begin
  if not AoWEngine.FRegistry.GetDebugMode and (Text <> '') then
    PlaySample('SFX\EVENTS\INFO1.WAV');
  Info.Text := Text;
  Info.Color := $FFFFFF;
  FShowMessageEvents.TriggerNotifyEvents(TObject(@Info));
  FMessageText := Text;
  FMessageFrame := $80;
end;
procedure TAbstractAoWHSMap.SetSeatedPlayer(A1: Shortint);
begin
  FSeatedPlayer := A1;
end;
procedure TAbstractAoWHSMap.SetCurrentPlayer(A1: Shortint);
begin
  FCurrentPlayer := A1;
end;
function TAbstractAoWHSMap.FogArea(X, Y, Level: Integer; Range: Integer): Boolean;
begin
  Assert(Range <= 15, 'Invalid Unfog Range');
  Result := TAoWMapLevel(MapContainer.GetMapLevel(Level)).FogArea(X, Y, Range);
  if Result and (FMapChangedLockCount = 0) and (FFogEnabled) then
    MapChangedRad(X, Y, Level, Range);
end;
function TAbstractAoWHSMap.UnFogArea(X, Y, Level: Integer; Range: Integer): Boolean;
begin
  Assert(Range <= 15, 'Invalid Unfog Range');
  Result := TAoWMapLevel(MapContainer.GetMapLevel(Level)).UnFogArea(X, Y, Range);
  if Result and (FMapChangedLockCount = 0) and (FFogEnabled) then
    MapChangedRad(X, Y, Level, Range);
end;
function TAbstractAoWHSMap.ExploreArea(X, Y, Level: Integer; Player: Shortint; Range: Integer): Boolean;
begin
  if not (msEditting in Status) then
  begin
    Result := TAoWMapLevel(MapContainer.GetMapLevel(Level)).ExploreArea(X, Y, Player, Range);
    if Result and (FMapChangedLockCount = 0) and (FFogEnabled) then
      MapChangedRad(X, Y, Level, Range);
  end
  else Result := False;
end;
function TAbstractAoWHSMap.UnFogExploreArea(X, Y, Level: Integer; Player: Shortint; Range: Integer): TFogExplorationChanged; type TAssertText = packed record RefCount, Len: Integer; Text: array[0..127] of Char; end; const AssertFile: TAssertText = (RefCount:-1; Len:31; Text:'D:\AoWDev\AoWE\inc\AoWHSMap.PAS'#0); AssertMessage: TAssertText = (RefCount:-1; Len:19; Text:'Invalid Unfog Range'#0); var Radius: Integer; { Preserve the original assertion diagnostic, independent of the build path. }
begin Radius := Range;
  if Radius > 15 then asm MOV ECX,$CB5B; MOV EDX,OFFSET AssertFile + 8; MOV EAX,OFFSET AssertMessage + 8; CALL System.@Assert end;
  { Original leaves Result undefined when a fog-only operation changes nothing. }
  if not (msEditting in Status) then
  begin
    if Player >= 0 then
      Result := TAoWMapLevel(MapContainer.GetMapLevel(Level)).UnFogExploreArea(X, Y, Player, Radius)
    else if TAoWMapLevel(MapContainer.GetMapLevel(Level)).UnFogArea(X, Y, Radius) then
      Result := [feFog];
  end
  else if TAoWMapLevel(MapContainer.GetMapLevel(Level)).UnFogArea(X, Y, Radius) then
    Result := [feFog];
  if (FMapChangedLockCount = 0) and
    (((feFog in Result) and (FFogEnabled)) or
     ((feExploration in Result) and FExplorationEnabled and (Player = FSeatedPlayer))) then
    MapChangedRad(X, Y, Level, Radius);
end;
procedure TAbstractAoWHSMap.DrawGrid(const SurfaceDesc: TSurfaceDesc);
var
  X, Y, MaxX, MaxY, Xhp, Yhp, Step: Integer;
  Level: TMapLevel;
  Field: TAoWMapField;
begin
  Level := MapContainer.GetMapLevel(ViewL);
  Step := Level.FHNOffsets[0, 4];
  MaxX := ViewXhx + ViewWidthHX - 1;
  MaxY := ViewYhx + ViewHeightHX - 1;
  for X := ViewXhx to MaxX do
  begin
    HXtoHP(X, ViewYhx, Xhp, Yhp);
    Xhp := Xhp - ViewXhp - 8;
    Yhp := Yhp - ViewYhp - 4 + 4;
    { Keep the original arithmetic evaluation order. }
    Field := TAoWMapField(Level.GetField(X, ViewYhx));
    for Y := ViewYhx to MaxY do
    begin
      if Smallint(Field.TerrainType) <> 15 then
        AoWHSSet.FFlagControl.FFlags[7].Show(Xhp, Yhp, SurfaceDesc);
      Field := TAoWMapField(Integer(Field) + Step);
      Inc(Yhp, 32);
    end;
  end;
end;
procedure TAbstractAoWHSMap.DrawFog(const SurfaceDesc: TSurfaceDesc);
var
  X, Y, MaxX, MaxY, Xhp, Yhp, Step: Integer;
  Level: TMapLevel;
  Field: TAoWMapField;
begin
  if (FFogEnabled) and (FExplorationEnabled or (AoWHSMap.FSeatedPlayer = -1)) then
  begin
  Level := MapContainer.GetMapLevel(ViewL);
  Step := Level.FHNOffsets[0, 4];
  MaxX := ViewXhx + ViewWidthHX - 1;
  MaxY := ViewYhx + ViewHeightHX - 1;
  for X := ViewXhx to MaxX do
  begin
    HXtoHP(X, ViewYhx, Xhp, Yhp);
    Xhp := Xhp - ViewXhp - 8;
    Yhp := Yhp - ViewYhp - 4;
    Field := TAoWMapField(Level.GetField(X, ViewYhx));
    for Y := ViewYhx to MaxY do
    begin
      if (FSeatedPlayer = -1) or not Field.GetExplored(FSeatedPlayer) then
        AoWHSSet.FGeneralImages[3].Show(Xhp, Yhp, SurfaceDesc)
      else if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then
        AoWHSSet.FGeneralImages[1].Show(Xhp, Yhp, SurfaceDesc);
      Field := TAoWMapField(Integer(Field) + Step);
      Inc(Yhp, 32);
    end;
  end;
  end
  else if (FFogEnabled) and not FExplorationEnabled then
  begin
  Level := MapContainer.GetMapLevel(ViewL);
  Step := Level.FHNOffsets[0, 4];
  MaxX := ViewXhx + ViewWidthHX - 1;
  MaxY := ViewYhx + ViewHeightHX - 1;
  for X := ViewXhx to MaxX do
  begin
    HXtoHP(X, ViewYhx, Xhp, Yhp);
    Xhp := Xhp - ViewXhp - 8;
    Yhp := Yhp - ViewYhp - 4;
    Field := TAoWMapField(Level.GetField(X, ViewYhx));
    for Y := ViewYhx to MaxY do
    begin
      if WordRec(LongRec(Field.FFieldFlags).Hi).Lo = 0 then
        AoWHSSet.FGeneralImages[1].Show(Xhp, Yhp, SurfaceDesc);
      Field := TAoWMapField(Integer(Field) + Step);
      Inc(Yhp, 32);
    end;
  end;
  end
  else if (not FFogEnabled) and (FExplorationEnabled or (AoWHSMap.FSeatedPlayer = -1)) then
  begin
  Level := MapContainer.GetMapLevel(ViewL);
  Step := Level.FHNOffsets[0, 4];
  MaxX := ViewXhx + ViewWidthHX - 1;
  MaxY := ViewYhx + ViewHeightHX - 1;
  for X := ViewXhx to MaxX do
  begin
    HXtoHP(X, ViewYhx, Xhp, Yhp);
    Xhp := Xhp - ViewXhp - 8;
    Yhp := Yhp - ViewYhp - 4;
    Field := TAoWMapField(Level.GetField(X, ViewYhx));
    for Y := ViewYhx to MaxY do
    begin
      if not Field.GetExplored(FSeatedPlayer) then
        AoWHSSet.FGeneralImages[3].Show(Xhp, Yhp, SurfaceDesc);
      Field := TAoWMapField(Integer(Field) + Step);
      Inc(Yhp, 32);
    end;
  end;
  end;
end;
procedure TAbstractAoWHSMap.ShowHexagonSelector;
begin
  if not FHexagonSelectorVisible then
  begin
    FHexagonSelectorVisible := True;
    DynamicFixedVisibleHS.AddChild(FBackHexagonSelector);
    DynamicFixedVisibleHS.AddChild(FFrontHexagonSelector);
    UpdateHexagonSelector;
  end;
end;
procedure TAbstractAoWHSMap.HideHexagonSelector;
begin
  if FHexagonSelectorVisible then
  begin
    DynamicVisibleHS.RemoveChild(FBackHexagonSelector);
    DynamicVisibleHS.RemoveChild(FFrontHexagonSelector);
    DynamicFixedVisibleHS.RemoveChild(FBackHexagonSelector);
    DynamicFixedVisibleHS.RemoveChild(FFrontHexagonSelector);
    FHexagonSelectorVisible := False;
  end;
end;
procedure TAbstractAoWHSMap.ShowBackHexagonSelector(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  if (FSelectorX <> -1) and (FSelectorY <> -1) and
    (AoWHSMap.Mouse.Capture = AoWHSMap.FSelectedArmy) then
  begin
    HXtoHP(FSelectorX, FSelectorY, Xhp, Yhp);
    Xhp := Xhp - XhpSurf - 8;
    Yhp := Yhp - YhpSurf - 32 + 2;
    AoWHSSet.FGeneralImages[7].Show(Xhp, Yhp, SurfaceDesc);
  end;
end;
procedure TAbstractAoWHSMap.ShowFrontHexagonSelector(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
begin
  if (FSelectorX <> -1) and (FSelectorY <> -1) and
    (AoWHSMap.Mouse.Capture = AoWHSMap.FSelectedArmy) then
  begin
    HXtoHP(FSelectorX, FSelectorY, Xhp, Yhp);
    Xhp := Xhp - XhpSurf - 8;
    Yhp := Yhp - YhpSurf - 32 + 2;
    AoWHSSet.FGeneralImages[6].Show(Xhp, Yhp, SurfaceDesc);
  end;
end;
procedure TAbstractAoWHSMap.UpdateHexagonSelector;
var
  Xhp, Yhp: Integer;
  HS: THexagonSprite;
begin
  if FHexagonSelectorVisible then
  begin
    FSelectorX := Mouse.Xhx;
    FSelectorY := Mouse.Yhx;
    if (FSelectorX <> -1) and (FSelectorY <> -1) then
    begin
      HXtoHP(FSelectorX, FSelectorY, Xhp, Yhp);
      HS := MapContainer.GetField(FSelectorX, FSelectorY, ViewL).GetMaxLevelNoneTransparentHS;
      if HS <> nil then
      begin
        if HS.GetShowPriority > $68000000 then
          FFrontHexagonSelector.ShowPriority := HS.GetShowPriority + 100
        else FFrontHexagonSelector.ShowPriority := $68000000 + ((Yhp + 32 + 32) shl 13) + Xhp;
      end
      else FFrontHexagonSelector.ShowPriority := $68000000 + ((Yhp + 32 + 32) shl 13) + Xhp;
      FBackHexagonSelector.ShowPriority := $68000000 + ((Yhp + 32 - 8) shl 13) + Xhp;
    end;
  end
  else FSelectorX := -1;
end;
procedure TAbstractAoWHSMap.UpdateStaticScene;
var
  Level: TMapLevel;
  X, Y, MaxX, MaxY: Integer;
  Field: TAoWMapField;
begin
  if FExplorationEnabled and (FSeatedPlayer <> -1) and not (msEditting in Status) then
  begin
    ResetVisibleStaticHS;
    MaxX := ViewXhx + ViewWidthHX - 1;
    MaxY := ViewYhx + ViewHeightHX - 1;
    Level := MapContainer.GetMapLevel(ViewL);
    for X := ViewXhx to MaxX do
      for Y := MaxY downto ViewYhx do
      begin
        Field := TAoWMapField(Level.GetField(X, Y));
        if Field.GetExplored(FSeatedPlayer) then Field.CopyStaticVisibleHS(StaticVisibleHS);
      end;
    StaticVisibleHS.Sort;
    StaticSceneInvalid := False;
  end
  else inherited UpdateStaticScene;
end;
procedure TAbstractAoWHSMap.UpdateDynamicScene;
var
  Level: TMapLevel;
  X, Y, MaxX, MaxY: Integer;
  Field: TAoWMapField;
begin
  if FExplorationEnabled and not (msEditting in Status) then
  begin
    ResetVisibleDynamicHS;
    MaxX := ViewXhx + ViewWidthHX - 1;
    MaxY := ViewYhx + ViewHeightHX - 1;
    Level := MapContainer.GetMapLevel(ViewL);
    if FSeatedPlayer <> -1 then
    begin
    for X := ViewXhx to MaxX do
      for Y := MaxY downto ViewYhx do
      begin
        Field := TAoWMapField(Level.GetField(X, Y));
        if Field.GetExplored(FSeatedPlayer) then Field.CopyDynamicVisibleHS(DynamicVisibleHS);
      end;
      for X := 0 to DynamicFixedVisibleHS.Count - 1 do
        THexagonSprite(DynamicFixedVisibleHS.GetChild(X)).MakeVisible(DynamicVisibleHS);
      DynamicVisibleHS.Sort;
    end;
    DynamicSceneInvalid := False;
  end
  else inherited UpdateDynamicScene;
end;
procedure TAbstractAoWHSMap.NewFrame;
begin
  inherited NewFrame;
  UpdateShowMessage;
  if FHexagonSelectorVisible then UpdateHexagonSelector;
end;
procedure TAbstractAoWHSMap.UpdateFPS(A1: Integer);
begin
  FFPS := A1;
end;
procedure TAbstractAoWHSMap.DropHeroItem(Hero: THero; Item: TItem);
var
  X, Y, L: Shortint;
begin
  Hero.GetLocation(X, Y, L);
  Item.PlaceOnMap(Self, X, Y, L);
end;
function TAbstractAoWHSMap.GetHeroItemsOnGround(Hero: THero): TItemList;
var
  X, Y, L: Shortint;
  Items: TItemHS;
begin
  Result := nil;
  Hero.GetLocation(X, Y, L);
  if X <> -1 then
  begin
    Items := TItemHS(AoWHSMap.MapContainer.GetField(X, Y, L).FindOwnedChild($20271));
    if Items <> nil then Result := Items.FItems;
  end;
end;

procedure TAbstractAoWHSMap.DrawSelectionRect(XhpSurf, YhpSurf: Integer; const R: TRect; const SurfaceDesc: TSurfaceDesc);
var
  Color: TColor;
begin
  Color := $208FFF;
  if (R.Left > 0) and (R.Top > 0) and (XhpSurf < R.Right) and (YhpSurf < R.Bottom) and
    (R.Right < ViewWidth + XhpSurf) and (R.Bottom < ViewHeight + YhpSurf) then
  begin
    DrawLine(R.Left-XhpSurf, R.Top-YhpSurf, R.Right-XhpSurf, R.Top-YhpSurf, 0, Color, SurfaceDesc);
    DrawLine(R.Right-XhpSurf, R.Top-YhpSurf, R.Right-XhpSurf, R.Bottom-YhpSurf, 0, Color, SurfaceDesc);
    DrawLine(R.Right-XhpSurf, R.Bottom-YhpSurf, R.Left-XhpSurf, R.Bottom-YhpSurf, 0, Color, SurfaceDesc);
    DrawLine(R.Left-XhpSurf, R.Bottom-YhpSurf, R.Left-XhpSurf, R.Top-YhpSurf, 0, Color, SurfaceDesc);
  end;
end;

constructor TAbstractAoWCombatMap.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FCombatStartedEvents := TEventList.Create;
  FAbilityActivatedEvents := TEventList.Create;
end;

destructor TAbstractAoWCombatMap.Destroy;
begin
  inherited Destroy;
  FCombatStartedEvents.Free;
  FAbilityActivatedEvents.Free;
end;

constructor TAoWNewHSMapSettings.Create;
begin
  inherited Create;
  HSMapClassID := $20011;
  MapLevelClassID := $20013;
end;

procedure TAoWHSMapKeyboard.Lock;
begin
  Inc(FLockCount);
end;

procedure TAoWHSMapKeyboard.Unlock;
begin
  Dec(FLockCount);
end;

procedure TAoWHSMapKeyboard.RunDefaultTest;
var
  FileName: string;
begin
  FileName := 'autosave.asg';
  AoWEngine.SaveHSM(AoWEngine.StartupDirectory + 'Save\' + FileName, nil); { Original saves the autosave file. }
end;

procedure TAoWHSMapKeyboard.KeyDown(var Key: Word; Shift: TShiftState);
var
  TranslatedKey: Word;
  I: Integer;
  Prefix, Complete: Boolean;
  Cheat: TCheatTE;
begin
  if FLockCount <> 0 then Exit;
  { Original uses OR between the digit bounds, admitting every key. }
  if ((Key >= $41) and (Key <= $5A)) or (Key >= $30) or (Key <= $39) or
    (Key = $BC) or (Key = $BE) or (Key = $0D) then
    case FMode of
      kmDefault:
        begin
          TranslatedKey := Key;
          case AoWEngine.FLanguage of
            3: case Key of
                 $53: TranslatedKey := $4E;
                 $43: TranslatedKey := $4C;
                 $54: TranslatedKey := $44;
                 $56: TranslatedKey := $43;
                 $44: TranslatedKey := $4D;
               end;
            5: case Key of
                 $56: TranslatedKey := $4E;
                 $45: TranslatedKey := $48;
                 $43: TranslatedKey := $4C;
                 $46: TranslatedKey := $44;
                 $53: TranslatedKey := $47;
                 $54: TranslatedKey := $43;
               end;
            4: case Key of $41: TranslatedKey := $44; end;
          end;
          if not (ssCtrl in Shift) then
            case TranslatedKey of
              $4F:
                begin
                  AoWHSMap.FShowIndependentMoves := not AoWHSMap.FShowIndependentMoves;
                  if AoWHSMap.FShowIndependentMoves then
                    AoWHSMap.ShowMessage(TranslateRStr(ObserveEnabledRStr))
                  else AoWHSMap.ShowMessage(TranslateRStr(ObserveDisabledRStr));
                end;
              $4E, $BC: AoWHSMap.SelectNextArmy;
              $50, $BE: AoWHSMap.SelectPrevArmy;
              $48: AoWHSMap.SelectNextHero;
              $4D: AoWHSMap.FSelectedArmy.ExecuteMove;
              $44: AoWHSMap.FSelectedArmy.TurnDone;
              $47: AoWHSMap.FSelectedArmy.ToggleGuard;
              $4C: AoWHSMap.CenterOnLeader(AoWHSMap.FSeatedPlayer, True, False);
              $43: if not (ssCtrl in Shift) then AoWHSMap.FSelectedArmy.Center;
              $52: if AoWEngine.FDebug then AoWEngine.OutputDebugStr('Random Seed: ' + IntToStr(AoWHSMap.FDefendersSeed));
              $53: if not (ssCtrl in Shift) and AoWEngine.FRegistry.GetDebugMode then RunDefaultTest;
              $41: if AoWEngine.FRegistry.GetDeveloper and
                (AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).FPlayerType <> ptHuman) then
                  AoWHSMap.FAIExecuter.ActivatePlayer(AoWHSMap.FSeatedPlayer);
              $49: if AoWEngine.FDebug then
                AoWHSMap.ShowMessage('Allocated Memory: ' + IntToStr(GetHeapStatus.TotalAllocated));
            end;
          if ssCtrl in Shift then
            case Key of
              $45: AoWHSMap.EndTurn;
              $0D: AoWHSMap.EndTurn;
            end;
        end;
      kmCheat:
        begin
          FCheatText := FCheatText + Char(Key);
          I := 10;
          Complete := False;
          Prefix := False;
          while (I <> 0) and not Complete do
          begin
            Dec(I);
            Prefix := Prefix or (CompareText(FCheatText, System.Copy(CheatNames[I], 1, Length(FCheatText))) = 0);
            Complete := CompareText(FCheatText, CheatNames[I]) = 0;
          end;
          if Complete and (AoWHSMap.FSeatedPlayer <> -1) and
            not AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FSeatedPlayer).GetBusy then
          begin
            Cheat := TCheatTE.Create(nil);
            Cheat.FPlayer := AoWHSMap.FSeatedPlayer;
            Cheat.FCheatID := I;
            AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Cheat);
            Cheat.Release;
            FCheatText := '';
            FMode := kmDefault;
          end
          else if not Prefix then
          begin
            FMode := kmDefault;
            FCheatText := '';
          end;
        end;
    end;
  if (Key = $43) and ([ssShift, ssCtrl] * Shift = [ssShift, ssCtrl]) and
    (CompareText(ParamStr(1), 'beatrix') = 0) and
    (AoWHSMap.FConnectionType <> pcNetwork) and (AoWHSMap.FConnectionType <> pcEmail) and not AoWEngine.FDemo then
  begin
    PlaySample('SFX\ATTACK\MAGICB02.WAV');
    FMode := kmCheat;
    FCheatText := '';
  end;
end;

constructor TAbstractAoWHSMapMouse.Create;
begin
  inherited Create;
  ResetRectangleSelection;
  FRectangleSelectEvents := TEventList.Create;
end;

destructor TAbstractAoWHSMapMouse.Destroy;
begin
  inherited Destroy;
  FRectangleSelectEvents.Free;
end;

procedure TAbstractAoWHSMapMouse.ResetRectangleSelection;
begin
  FSelectionRectangle.Left := -1;
  FSelectionRectangle.Top := -1;
  FSelectionRectangle.Right := -1;
  FSelectionRectangle.Bottom := -1;
end;

function TAbstractAoWHSMapMouse.GetSelectingRectangle: Boolean;
begin
  if (FSelectionRectangle.Left = -1) or
    ((FSelectionRectangle.Left = FSelectionRectangle.Right) and
     (FSelectionRectangle.Top = FSelectionRectangle.Bottom)) then Result := False
  else Result := True;
end;

procedure TAbstractAoWHSMapMouse.StartRectangleSelection(A1: Integer; A2: Integer);
begin
  FSelectionRectangle.Left := A1;
  FSelectionRectangle.Top := A2;
  FSelectionRectangle.Right := A1;
  FSelectionRectangle.Bottom := A2;
end;

procedure TAbstractAoWHSMapMouse.UpdateRectangleSelection(A1: Integer; A2: Integer);
begin
  if Button = mbLeft then
  begin
    if (A1 > 0) and (A2 > 0) then
    begin
      if A1 < FSelectionRectangle.Left - 800 then A1 := FSelectionRectangle.Left - 800;
      if A1 > FSelectionRectangle.Left + 800 then A1 := FSelectionRectangle.Left + 800;
      if A2 < FSelectionRectangle.Top - 600 then A2 := FSelectionRectangle.Top - 600;
      if A2 > FSelectionRectangle.Top + 600 then A2 := FSelectionRectangle.Top + 600;
      FSelectionRectangle.Right := A1;
      FSelectionRectangle.Bottom := A2;
    end;
  end
  else ResetRectangleSelection;
end;

procedure TAbstractAoWHSMapMouse.StopRectangleSelection(A1: Integer; A2: Integer);
var
  R: TRect;
begin
  FSelectionRectangle.Right := A1;
  FSelectionRectangle.Bottom := A2;
  if FSelectionRectangle.Left < FSelectionRectangle.Right then R.Left := FSelectionRectangle.Left
  else R.Left := FSelectionRectangle.Right;
  if FSelectionRectangle.Right > FSelectionRectangle.Left then R.Right := FSelectionRectangle.Right
  else R.Right := FSelectionRectangle.Left;
  if FSelectionRectangle.Top < FSelectionRectangle.Bottom then R.Top := FSelectionRectangle.Top
  else R.Top := FSelectionRectangle.Bottom;
  if FSelectionRectangle.Bottom > FSelectionRectangle.Top then R.Bottom := FSelectionRectangle.Bottom
  else R.Bottom := FSelectionRectangle.Top;
  FSelectionRectangle := R;
  FRectangleSelectEvents.TriggerNotifyEvents(Self);
  ResetRectangleSelection;
end;

procedure TAbstractAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited Down(Button, Shift, X, Y);
  if (Capture = nil) and not (msEditting in HSMap.Status) then
    StartRectangleSelection(HSMap.ViewXhp + X - 2, HSMap.ViewYhp + Y - 3);
end;

procedure TAbstractAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited Up(Button, Shift, X, Y);
  if (Capture = nil) and (FSelectionRectangle.Left <> -1) then
  begin
    if (X <> -1) and (Y <> -1) then
      StopRectangleSelection(HSMap.ViewXhp + X - 2, HSMap.ViewYhp + Y - 3)
    else ResetRectangleSelection;
  end;
end;

procedure TAbstractAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
begin
  inherited Move(Shift, X, Y);
  if Capture = nil then
    UpdateRectangleSelection(HSMap.ViewXhp + X - 2, HSMap.ViewYhp + Y - 3);
end;

function TAoWHSMapMouse.GetCursor: Integer;
var
  CombatMap: TAbstractAoWCombatMap;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then Result := CombatMap.Mouse.GetCursor
  else Result := inherited GetCursor;
end;

procedure TAoWHSMapMouse.Down(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then
    AoWHSMap.FCombatMap.Mouse.Down(Button, Shift, X, Y)
  else
    inherited Down(Button, Shift, X, Y);
  if AoWEngine.FRegistry.GetDebugMode then
    AoWEngine.OutputDebugStr('Location (' + IntToStr(Xhx) + ',' + IntToStr(Yhx) + ') selected');
end;

procedure TAoWHSMapMouse.Up(Button: Controls.TMouseButton; Shift: Classes.TShiftState; X, Y: Integer);
begin
  if AoWHSMap.FCombatMap <> nil then
    AoWHSMap.FCombatMap.Mouse.Up(Button, Shift, X, Y)
  else
    inherited Up(Button, Shift, X, Y);
end;

procedure TAoWHSMapMouse.Move(Shift: Classes.TShiftState; X, Y: Integer);
var
  CombatMap: TAbstractAoWCombatMap;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then CombatMap.Mouse.Move(Shift, X, Y)
  else inherited Move(Shift, X, Y);
end;

procedure TAoWHSMapMouse.DblClick; { Near miss: Three variants retain different global-address caching. }
var
  CombatMap: TAbstractAoWCombatMap;
  SelectStructure: Boolean;
  Structure: TStructure;
begin
  CombatMap := AoWHSMap.FCombatMap;
  if CombatMap <> nil then
  begin
    CombatMap.Mouse.DblClick;
    Exit;
  end;
  SelectStructure := Capture = nil;
  if Capture = AoWHSMap.FSelectedArmy then
    SelectStructure := (AoWHSMap.FSelectedArmy.GetArmyHS <> nil) and
      (AoWHSMap.FSelectedArmy.FMoveSettingsList.Count = 1) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Xhx = Xhx) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Yhx = Yhx) and
      (AoWHSMap.FSelectedArmy.GetArmyHS.Lhx = AoWHSMap.ViewL);
  if SelectStructure and (Xhx <> -1) then
  begin
    Structure := TStructure(AoWHSMap.MapContainer.GetField(Xhx, Yhx, AoWHSMap.ViewL).FindNoneTransparentHS(TStructure));
    if (Structure <> nil) and Structure.CanDblClick then
    begin
      AoWHSMap.Selection.UnselectLocation;
      AoWHSMap.Selection.SelectLocationHS(Structure);
    end;
  end;
  inherited DblClick;
end;

constructor TStartupSongList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  Songs.OnChange := OriginalSongsChanged;
end;

procedure TStartupSongList.OriginalSongsChanged(Sender: TObject);
var
  I: Integer;
  Name: string;
begin
  SongNames.Clear;
  for I := Songs.Count - 1 downto 0 do
  begin
    try
      Name := GetSongName(Songs[I]);
    except
      Name := TranslateRStr(FileNotFoundRStr);
    end;
    SongNames.Insert(0, Name);
  end;
end;

constructor TAoWHSMap.Create(AOwner: Engine.TECustomNode);


begin
  inherited Create(AOwner);
  FItemControl := TItemControl.Create(nil);
  FTokenManager := TAoWTokenManager.Create(AoWEngine);
  FTokenManager.TokenExecuter.OnActivateTC.Add(TokenControlActivatedEvent);
  FTokenManager.TokenExecuter.OnExecuteTokenEvent := OnExecuteTokenEvent;
  FTokenManager.OnMessage := OnTokenManagerMessage;
  FPlayerCommunicator := TPlayerCommunicator.Create(nil);
  FPlayerCommunicator.Engine := AoWEngine;
  FConnectionType := pcLocal;
  FAIExecuter := TAIExecuter.Create(nil);
  FAIGroupManager := TAIGroupManager.Create(nil);
  FAIPlayerActionManager := TAIPlayerActionManager.Create(nil);
  FAIPlayerActionManager.RegisterClasses([TEndTurnAIPA, TGroupControlAIPA,
    TGroupControlLoopAIPA, TInitializeAIPA, TBudgetManagerAIPA, TAutoProduceAIPA,
    TDiplomacyAIPA, TProcessEventlogAIPA, TResearchSpellAIPA, TCastSpellAIPA,
    TStructurePhase1AIPA, TStructurePhase2AIPA]);
  FTokenManager.TokenExecuter.OnEventsExecuted.Add(FAIExecuter.TokenControlDoneEvent);
  FAIGroupManager.RegisterAIGroupClasses([THuntAG]);
  FPlayMode := pmNone;
  FKeyboard := TAoWHSMapKeyboard.Create(nil);
  FTargetSelection := TTargetSelectionControl.Create;
  FEffects := TList.Create;
  FDefendersSeed := 0;
  FHeroCountMax := 5;
  FSelectedArmy := TSelectedArmy.Create;
  TAbstractAoWHSMapMouse(Mouse).FRectangleSelectEvents.Add(FSelectedArmy.RectangleSelectEvent);
  FMoveControl := TMoveControl.Create(Self);
  FGlobalMagicControl := TGlobalMagicControl.Create(nil);
  FMapName := 'noname';
  FAuthor := '';
  FTurnTimerStart := -1;
  FSphereCount := 5;
  FVictoryGold := 5000;
  FVictoryMana := 5000;
  FDescription := TStringList.Create;
  FObjectives := TStringList.Create;
  FIndependentAIMode := iaNormal;
  FPlayers := TPlayerList.Create(nil);
  FRaces := TRaceList.Create(nil);
  FPlayerChangedEvents := TEventList.Create;
  FFixedLeaders := True;
  FAlliedVictory := False;
  FCurrentPlayer := 0;
  FUseTurnTimer := True;
  FExecuteEventLogBuffer := TEventLogList.Create(nil);
  FDebugSave := False;
  FTutorialControl := TTutorialControl.Create(nil);
  FTurnOrderMode := toFixed;
  FTurnOrder := TByteList.Create;
  FDay := 0;
  FGameStatus := gsIdle;
  FGameResult := grNone;
  FSessionName := '';
  FShowUnitShadows := AoWEngine.FRegistry.GetDetailLevel in [dtlNormal, dtlHigh];
  FHeroControl := THeroControl.Create(nil);
  FUnitControl := TUnitControl.Create(nil);
  FStructureControl := TStructureControl.Create(nil);
  FOnLeaderChanged := TEventList.Create;
  FTextControl := TTextControl.Create(nil);
  FNewDayEvents := TEventList.Create;
  FNewTurnEvents := TEventList.Create;
  FEndTurnEvents := TEventList.Create;
  FCurrentPlayerChangedEvents := TEventList.Create;
  FSeatedPlayerChangedEvents := TEventList.Create;
  FArmyChangedEvents := TEventList.Create;
  FStructureChangedEvents := TEventList.Create;
  FTokenControlActivatedEvents := TEventList.Create;
  FUnitChangedEvents := TEventList.Create;


  FUnitChangedEvents.Add(FTargetSelection.UnitChanged);
  FArmyDestroyedEvents := TEventList.Create;
  FArmyDestroyedEvents.Add(FSelectedArmy.OnDestroyArmy);
  FStructureDestroyedEvents := TEventList.Create;
  FUnitDestroyedEvents := TEventList.Create;
  FCombatEvents := TEventList.Create;
  FExecuteEventLogEvents := TEventList.Create;
  FExecuteEventLogCallBacks := TExecuteEventLogCallBackList.Create;
  FCosmeticSurgeryEvents := TEventList.Create;
  FOnActivateAbility := TEventList.Create;
  FStartupSongs := TStartupSongList.Create(nil);
  FGameSongs := TSonglist.Create(nil);
  FPlayerTerminatedEvents := TEventList.Create;
  FGameOverEvents := TEventList.Create;
  FGameTerminatedEvents := TEventList.Create;
  FDiplomaticRelationsChangedEvents := TEventList.Create;
  FUpdateVisibilityEvents := TEventList.Create;
  FCombatMapCreatedEvents := TEventList.Create;
  FCombatMapDestroyedEvents := TEventList.Create;
  FExitEvents := TEventList.Create;
  FCampaignSettings := TAoWMapCampaignSettings.Create(nil);
  Mouse.OnMove.Add(MouseMoved);
end;

destructor TAoWHSMap.Destroy;
var
  I: Integer;
begin
  StopTokenEventLogging;
  LockMapChangedEvent;
  OnViewLevel := nil;
  OnCenterView := nil;
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'GENERAL.ILB');
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'CURSORS.ILB');
  AoWHSSet.ImageLibraryManager.ReleaseIL([icDisk], 'COMBAT.ILB');
  FMoveControl.Free;
  for I := FEffects.Count - 1 downto 0 do
  begin
    DynamicFixedVisibleHS.RemoveChild(TAnimation(FEffects[I]));
    DynamicVisibleHS.RemoveChild(TAnimation(FEffects[I]));
    TObject(FEffects[I]).Free;
  end;
  FEffects.Free;
  FTutorialControl.Free;
  FPlayers.BeginUpdate;
  FArmyChangedEvents.Clear;
  FStructureChangedEvents.Clear;
  FUnitChangedEvents.Clear;
  FSeatedPlayerChangedEvents.Clear;
  FCurrentPlayerChangedEvents.Clear;
  FNewTurnEvents.Clear;
  FNewDayEvents.Clear;
  FOnLeaderChanged.Clear;
  FDescription.Clear;
  FObjectives.Clear;
  FTurnOrder.Clear;
  FStructureDestroyedEvents.Clear;
  FUnitDestroyedEvents.Clear;
  FCombatMapCreatedEvents.Clear;
  FCombatMapDestroyedEvents.Clear;
  FUpdateVisibilityEvents.Clear;
  FDiplomaticRelationsChangedEvents.Clear;
  FCosmeticSurgeryEvents.Clear;
  FOnActivateAbility.Clear;
  FTokenControlActivatedEvents.Clear;
  FPlayerChangedEvents.Clear;
  FExitEvents.Clear;
  Mouse.OnMove.Remove(MouseMoved);
  if FCombat <> nil then DestroyCombat;
  if FCombatMap <> nil then
  begin
    FCombatMap.Free;
    FCombatMap := nil;
  end;
  inherited Destroy;
  FItemControl.Deactivate;
  FGlobalMagicControl.Free;
  FGlobalMagicControl := nil;
  FPlayerCommunicator.Free;
  FTokenManager.Free;
  FTokenManager := nil;
  FCampaignSettings.Free;
  FAIExecuter.Free;
  FSelectedArmy.Free;
  FSeatedPlayerChangedEvents.Free;
  FExecuteEventLogBuffer.Free;
  FNewTurnEvents.Free;
  FEndTurnEvents.Free;
  FCurrentPlayerChangedEvents.Free;
  FNewDayEvents.Free;
  FArmyChangedEvents.Free;
  FStructureChangedEvents.Free;
  FUnitChangedEvents.Free;
  FArmyDestroyedEvents.Free;
  FStructureDestroyedEvents.Free;
  FUnitDestroyedEvents.Free;
  FOnLeaderChanged.Free;
  FDescription.Free;
  FObjectives.Free;
  FTurnOrder.Free;
  FPlayerControl.Free;
  FTextControl.Free;
  FCombatEvents.Free;
  FPlayerChangedEvents.Free;
  FExecuteEventLogEvents.Free;
  FExecuteEventLogCallBacks.Free;
  FCosmeticSurgeryEvents.Free;
  FOnActivateAbility.Free;
  FGameSongs.Free;
  FStartupSongs.Free;
  FExitEvents.Free;
  FItemControl.Free;
  FItemControl := nil;
  FHeroControl.Free;
  FHeroControl := nil;
  FUnitControl.Free;
  FUnitControl := nil;
  FStructureControl.Free;
  FStructureControl := nil;
  FAIGroupManager.Free;
  FAIGroupManager := nil;
  FAIPlayerActionManager.Free;
  FPlayers.Free;
  FRaces.Free;
  FPlayerTerminatedEvents.Free;
  FGameOverEvents.Free;
  FGameTerminatedEvents.Free;
  FTargetSelection.Free;
  FCombatMapCreatedEvents.Free;
  FCombatMapDestroyedEvents.Free;
  FDiplomaticRelationsChangedEvents.Free;
  FKeyboard.Free;
  FUpdateVisibilityEvents.Free;
  FTokenControlActivatedEvents.Free;
  UnlockMapChangedEvent;
end;

procedure TAoWHSMap.StartTokenEventLogging;
begin
  if not FTokenEventLogging and not (msEditting in AoWHSMap.Status) then
  try
    {$I-}
    AssignFile(FTokenEventLog, AoWEngine.StartupDirectory + 'Debug\' +
      'SYNC_LOG' + IntToStr(GetElapsedMilliSeconds) + '.TXT');
    Rewrite(FTokenEventLog);
    WriteLn(FTokenEventLog, 'Map Session: ' + FMapName);
    WriteLn(FTokenEventLog, 'Local Player: ' + IntToStr(AoWHSMap.FPlayers.FLocalHumanPlayers[0]));
    WriteLn(FTokenEventLog, 'Local Race: ' + TranslateRStr(RaceNamesPluralRStr[
      AoWHSMap.FPlayers.GetPlayers(AoWHSMap.FPlayers.FLocalHumanPlayers[0]).FPlayerRace]));
    {$I+}
    FTokenEventLogging := True;
  except
  end;
end;

procedure TAoWHSMap.StopTokenEventLogging;
begin
  if FTokenEventLogging then
  begin
    {$I-} CloseFile(FTokenEventLog); {$I+}
    FTokenEventLogging := False;
  end;
end;

procedure TAoWHSMap.SynchroniseBegin;
begin
  Inc(FSynchroniseCount);
end;

procedure TAoWHSMap.SynchroniseEnd;
begin
  Dec(FSynchroniseCount);
end;

function TAoWHSMap.GetSynchronised: Boolean;
begin
  if (FSynchroniseCount = 0) and not FTokenManager.TokenExecuter.Executing and
    not (msEditting in Status) then Result := False
  else Result := True;
end;

procedure TAoWHSMap.OnExecuteTokenEvent(Event: TTokenEvent);
begin
  if Event.ClassID <> $554 then SetModified;
  if FTokenEventLogging and (FTokenManager.TokenExecuter.ExecuteCount = 0) then
  begin
    {$I-}
    WriteLn(FTokenEventLog, Event.ClassName + ' (P:' +
      IntToStr(FTokenManager.TokenExecuter.ActiveTCIndex) + '/T:' +
      IntToStr(Event.TokenCounter) + '/S:' + IntToStr(FDefendersSeed) +
      '/D:' + IntToStr(AoWHSMap.FDay) + '/AIPC:' +
      IntToStr(AoWHSMap.FAIExecuter.FProcessCycles));
    Flush(FTokenEventLog);
    {$I+}
  end;
end;

procedure TAoWHSMap.PlayerDisconnected(Player: Shortint);
begin
  FPlayerControl.PlayerDisconnected(Player);
end;

procedure TAoWHSMap.PlayerConnectionLost;
begin
  FPlayerControl.ConnectionLost;
end;

procedure TAoWHSMap.OnTokenManagerMessage(Sender: TObject; const Msg: string);
begin
  {$I-} if FTokenEventLogging then WriteLn(FTokenEventLog, Msg); {$I+}
  AoWEngine.OutputDebugStr(Msg);
end;

function TAoWHSMap.GetIndependentAIMode: TIndependentAIMode;
begin
  Result := FIndependentAIMode;
  if not (msEditting in AoWHSMap.Status) and
    (getFireMastery in AoWHSMap.FGlobalMagicControl.FActiveEnchantments) then
    if Result = iaOff then Result := iaNormal
    else Result := iaAggressive;
end;

function TAoWHSMap.SaveGame(FileName: string): Boolean;
var
  Event: TSaveGameTE;
begin
  if AoWHSMap.FSeatedPlayer <> -1 then
  begin
    Event := TSaveGameTE.Create(nil);
    Event.FFileName := ExpandFileName(FileName);
    AoWHSMap.FTokenManager.GetTokenControl(AoWHSMap.FSeatedPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;

function TAoWHSMap.CreateMouse: HSEngine.THSMapMouse;
begin
  Result := TAoWHSMapMouse.Create;
end;

procedure TAoWHSMap.SetSeatedPlayer(A1: Shortint);
begin
  FPlayerControl.SetSeatedPlayer(A1);
end;

function TAoWHSMap.TerrainVisible(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := AoWHSMap.FExplorationEnabled; { Original returns true immediately when exploration is enabled. }
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := Field.GetExplored(AoWHSMap.FSeatedPlayer);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.Visible(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (not AoWHSMap.FFogEnabled)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.WatchingTerrain(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled) and
        Viewing(Walk.X, Walk.Y, L);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.Watching(X, Y, L: Shortint; Radius: Integer): Boolean;
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
begin
  Result := False;
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= Radius) and not Result do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and
      (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (not AoWHSMap.FFogEnabled)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled) and
        Viewing(Walk.X, Walk.Y, L);
    end;
    if not Result then WalkToNextHN(Walk);
  end;
end;

function TAoWHSMap.ValidateTerrainObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean; { Near miss: Three variants retain different parameter/result registers. }
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
  WX: Integer;
begin
  if FShowIndependentMoves and (Player <> AoWHSMap.FSeatedPlayer) then
  begin
    Result := False;
    MapLevel := MapContainer.GetMapLevel(L);
    InitHNWalk(Walk, X, Y, 0);
    while (Walk.Radius <= Radius) and not Result do
    begin
      WX := Walk.X;
      if (WX >= 0) and (Walk.Y >= 0) and (WX < MapLevel.Width) and
        (Walk.Y < MapLevel.Height) then
      begin
        Field := TAoWMapField(MapLevel.GetField(WX, Walk.Y));
        Result := (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
      end;
      if not Result then WalkToNextHN(Walk);
    end;
    if Result then MakeVisible(Walk.X, Walk.Y, L, 3);
  end
  else Result := False;
end;

function TAoWHSMap.ValidateObservation(Player, X, Y, L: Shortint; Radius: Integer): Boolean; { Near miss: Three variants retain different parameter/result registers. }
var
  MapLevel: TMapLevel;
  Field: TAoWMapField;
  Walk: THNWalkData;
  WX: Integer;
begin
  if FShowIndependentMoves and (Player <> AoWHSMap.FSeatedPlayer) then
  begin
    Result := False;
    MapLevel := MapContainer.GetMapLevel(L);
    InitHNWalk(Walk, X, Y, 0);
    while (Walk.Radius <= Radius) and not Result do
    begin
      WX := Walk.X;
      if (WX >= 0) and (Walk.Y >= 0) and (WX < MapLevel.Width) and
        (Walk.Y < MapLevel.Height) then
      begin
        Field := TAoWMapField(MapLevel.GetField(WX, Walk.Y));
        Result := ((WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) or (not AoWHSMap.FFogEnabled)) and
        (Field.GetExplored(AoWHSMap.FSeatedPlayer) or not AoWHSMap.FExplorationEnabled);
      end;
      if not Result then WalkToNextHN(Walk);
    end;
    if Result then MakeVisible(Walk.X, Walk.Y, L, 3);
  end
  else Result := False;
end;

procedure TAoWHSMap.UnlockGameOverEventCallBack;
begin
  UnlockGameOverEvent;
end;

function TAoWHSMap.SelectNextHero: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    Left := Player.FArmies.Count;
    I := Player.FHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    repeat
      Inc(I);
      Dec(Left);
      if I = Player.FArmies.Count then I := 0;
    until (Left = 0) or (Player.FArmies.GetArmy(I).Hero($FF, [htHero, htLeader, htHeroLeader, htMerchant]) <> nil);
    if Player.FArmies.GetArmy(I).Hero($FF, [htHero, htLeader, htHeroLeader, htMerchant]) <> nil then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

function TAoWHSMap.SelectNextArmy: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    Left := Player.FArmies.Count;
    I := Player.FBaseHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    repeat
      Inc(I);
      Dec(Left);
      if I = Player.FArmies.Count then I := 0;
    until (Left = 0) or ((Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []));
    if (Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []) then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FBaseHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

function TAoWHSMap.SelectPrevArmy: Boolean;
var
  Player: TPlayer;
  I, Left: Integer;
  Army: TArmy;
  Xhp, Yhp: Integer;
begin
  Player := FPlayers.GetPlayers(FSeatedPlayer);
  if Player.FArmies.Count <> 0 then
  begin
    I := Player.FBaseHeroJoinDay;
    if (I < 0) or (I >= Player.FArmies.Count) then I := 0;
    Left := Player.FArmies.Count;
    repeat
      Dec(I);
      Dec(Left);
      if I < 0 then I := Player.FArmies.Count - 1;
    until (Left = 0) or ((Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []));
    if (Smallint(Player.FArmies.GetArmy(I).MovePoints($FF)) > 1) and
          (Player.FArmies.GetArmy(I).FUserMode * [aumGuard, aumTurnDone] = []) then
    begin
      Army := FPlayers.GetPlayers(FSeatedPlayer).FArmies.GetArmy(I);
      CenterViewTo(Army.FX, Army.FY, Army.FL);
      Selection.UnselectLocation;
      HXtoHP(Army.FX, Army.FY, Xhp, Yhp);
      Selection.SelectLocation(Xhp, Yhp, Army.FL);
      Player.FBaseHeroJoinDay := I;
    end
    else Selection.UnselectLocation;
  end;
  Result := True;
end;

procedure TAoWHSMap.SeatedPlayerChanged;
var
  Msg: TEMsg;
begin
  Selection.UnselectAll;
  InitMsg(Msg, $20020006, Self);
  MapContainer.SendMsg(Msg, Self);
  InitMsg(Msg, $20020009, Self);
  MapContainer.SendMsg(Msg, Self);
  FSeatedPlayerChangedEvents.TriggerNotifyEvents(AoWHSMap);
  ShowMessage('');
end;

procedure TAoWHSMap.BeginUnitUpdate;
begin
  Inc(FUnitUpdateCount);
end;

procedure TAoWHSMap.EndUnitUpdate;
begin
  Dec(FUnitUpdateCount);
  if FUnitUpdateCount = 0 then UnitChanged(nil);
end;

procedure TAoWHSMap.UnitChanged(AUnit: TAbstractUnit);
begin
  if FUnitUpdateCount = 0 then FUnitChangedEvents.TriggerNotifyEvents(AUnit);
end;

procedure TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit);
begin
  if not (msDestroying in AoWHSMap.Status) then
  FUnitDestroyedEvents.TriggerNotifyEvents(AUnit);
end;

procedure TAoWHSMap.BeginArmyUpdate;
begin
  Inc(FArmyUpdateCount);
end;

procedure TAoWHSMap.EndArmyUpdate;
begin
  Dec(FArmyUpdateCount);
  if FArmyUpdateCount = 0 then ArmyChanged(nil);
end;

procedure TAoWHSMap.ArmyChanged(Army: TArmy);
begin
  if FArmyUpdateCount = 0 then FArmyChangedEvents.TriggerNotifyEvents(Army);
end;

procedure TAoWHSMap.ArmyDestroyed(Army: TArmy);
{ TArmy.Destroy passes its Self pointer at 5578C1C9. }
begin
  FArmyDestroyedEvents.TriggerNotifyEvents(Army);
end;

procedure TAoWHSMap.BeginStructureUpdate;
begin
  Inc(FStructureUpdateCount);
end;

procedure TAoWHSMap.EndStructureUpdate;
begin
  Dec(FStructureUpdateCount);
  if FStructureUpdateCount = 0 then StructureChanged(nil);
end;

procedure TAoWHSMap.StructureChanged(Structure: TStructure);
begin
  if FStructureUpdateCount = 0 then FStructureChangedEvents.TriggerNotifyEvents(Structure);
end;

procedure TAoWHSMap.StructureDestroyed(Structure: TStructure);
begin
  FStructureDestroyedEvents.TriggerNotifyEvents(Structure);
end;

procedure TAoWHSMap.TriggerCombatEvent;
begin
  FCombatEvents.TriggerNotifyEvents(Combat);
end;

procedure TAoWHSMap.TriggerGameTerminatedEvent;
begin
  FGameStatus := gsTerminated;
  FGameOverEvents.TriggerNotifyEvents(Self); { Original dispatches through $1B8. }
end;

procedure TAoWHSMap.ExecuteExitGame;
begin
  FExitPending := True;
  FExitEvents.TriggerNotifyEvents(Self);
end;

procedure TAoWHSMap.ExitGame(Mode: TExitGameMode; Done: TExitGameCallBack);
var
  PlayerControl: TPlayerControl;
begin
  if not FExitPending then
  begin
    PlayerControl := FPlayerControl;
    if PlayerControl <> nil then PlayerControl.ExitGame(Mode, Done)
    else
    begin
      ExecuteExitGame;
      if Assigned(Done) then Done(Mode, True);
    end;
  end
  else if Assigned(Done) then Done(Mode, True);
end;

procedure TAoWHSMap.TriggerEndTurnEvent(Player: Shortint);
begin
  FEndTurnEvents.TriggerNotifyEvents(TObject(Player));
end;

procedure TAoWHSMap.ClearExecuteEventLogBuffer;
begin
  while FExecuteEventLogCallBacks.GetCount > 0 do
  begin
    if Assigned(FExecuteEventLogCallBacks.GetItem(0)^.Done) then
      FExecuteEventLogCallBacks.GetItem(0)^.Done(FExecuteEventLogCallBacks.GetItem(1)^.Log);
      { Original passes the second record's log to the first callback, even for a one-item list. }
    FExecuteEventLogCallBacks.Delete(0);
  end;
end;

procedure TAoWHSMap.ExecuteNextEventLog;
var
  Info: TExecuteEventLogInfo;
begin
  if FExecuteEventLogCallBacks.GetCount <> 0 then
  begin
    Inc(FAILockCount);
    Info := FExecuteEventLogCallBacks.GetItem(0)^;
    Info.Done := ExecuteEventLogDone;
    FExecuteEventLogEvents.TriggerNotifyEvents(TObject(@Info));
  end;
end;

procedure TAoWHSMap.SetExecuteEventLogDelay(Value: Integer);
begin
  if FExecuteEventLogDelay = 0 then
  begin
    FExecuteEventLogDelay := Value;
    LockExecuteEventLog;
  end
  else if Value > FExecuteEventLogDelay then FExecuteEventLogDelay := Value;
end;

procedure TAoWHSMap.UpdateExecuteEventLogDelay;
begin
  if FExecuteEventLogDelay <> 0 then
  begin
    Dec(FExecuteEventLogDelay);
    if FExecuteEventLogDelay = 0 then UnlockExecuteEventLog;
  end;
end;

procedure TAoWHSMap.ExecuteEventLogDone(Log: TEventLog);
var
  Info: TExecuteEventLogInfo;
begin
  if (FExecuteEventLogCallBacks.GetCount > 0) and
    (Log = FExecuteEventLogCallBacks.GetItem(0)^.Log) then
  begin
    Info := FExecuteEventLogCallBacks.GetItem(0)^;
    FExecuteEventLogCallBacks.Delete(0);
    if Assigned(Info.Done) then Info.Done(Info.Log);
    Info.Log.Release;
  end;
  SetExecuteEventLogDelay(2);
  UnlockExecuteEventLog;
end;

procedure TAoWHSMap.LockExecuteEventLog;
begin
  Inc(FAILockCount);
end;

procedure TAoWHSMap.UnlockExecuteEventLog;
begin
  Dec(FAILockCount);
  if FAILockCount = 0 then ExecuteNextEventLog;
end;

procedure TAoWHSMap.TriggerExecuteEventLog(Log: TEventLog; Immediate: Boolean; Done: TExecuteDoneEvent);
var
  Info: TExecuteEventLogInfo;
begin
  Info.Log := Log;
  Info.Done := Done;
  Info.Immediate := Immediate;
  if not Immediate then
  begin
    Log.AddRef;
    FExecuteEventLogCallBacks.Add(Info);
    if FAILockCount = 0 then ExecuteNextEventLog;
  end
  else FExecuteEventLogEvents.TriggerNotifyEvents(TObject(@Info));
end;

procedure TAoWHSMap.TriggerPlayerTerminatedEvent(Player: Integer);
begin
  FPlayerTerminatedEvents.TriggerNotifyEvents(TObject(Player));
end;


procedure TAoWHSMap.GameOverEventHandled(Player: Shortint);
begin
  FPlayerControl.GameOverEventHandled(Player);
end;


procedure TAoWHSMap.ExecuteGameOverEvent(Event: TGameOverEventLog);
var
  I: Integer;
  Player: TPlayer;
  Log: TGameOverEventLog;
begin
  for I := 1 to AoWHSMap.FPlayers.Count - 1 do
  begin
    Player := AoWHSMap.FPlayers.GetPlayers(I);
    if (I = Event.FPlayer) or (Player.FGameOverStatus = goNone) then
    begin
      Log := TGameOverEventLog(Event.Copy(AoWEngine));
      if FGameOverLockCount = 0 then
      begin
        Player.FEventLogbook.AddEvent(Log);
        if I = AoWHSMap.FSeatedPlayer then Log.Execute(False, etEvent, nil);
      end
      else
      begin
        Log.FTargetPlayer := I;
        FExecuteEventLogBuffer.AddEvent(Log);
      end;
      Log.Release;
    end;
  end;
end;


procedure TAoWHSMap.UnlockGameOverEvent;
var
  Player: Shortint;
  Log: TEventLog;
begin
  Dec(FGameOverLockCount);
  if FGameOverLockCount = 0 then
    while FExecuteEventLogBuffer.Count <> 0 do
    begin
      Player := TGameOverEventLog(FExecuteEventLogBuffer.GetEvents(0)).FTargetPlayer;
      Log := TEventLog(FExecuteEventLogBuffer.GetEvents(0).Copy(AoWEngine));
      AoWHSMap.FPlayers.GetPlayers(Player).FEventLogbook.AddEvent(Log);
      if Player = AoWHSMap.FSeatedPlayer then Log.Execute(False, etEvent, nil);
      Log.Release;
      FExecuteEventLogBuffer.RemoveEvent(FExecuteEventLogBuffer.GetEvents(0));
    end;
end;


procedure TAoWHSMap.LockGameOverEvent;
begin
  Inc(FGameOverLockCount);
end;


procedure TAoWHSMap.GameOver(Player: Shortint; Status: TGameOverStatus);
begin
  if (Player > 0) and (msActivated in Self.Status) and
    not (msEditting in Self.Status) and not (msDestroying in Self.Status) then
    FPlayerControl.GameOver(Player, Status);
end;


procedure TAoWHSMap.VerifyAddOnPacks;
begin end;

function TAoWHSMap.ValidateMap(Messages: TStrings): Boolean;
var
  Msg: TEMsg;
begin
  InitMsg(Msg, $20020103, Self);
  Msg.Value := Integer(Messages);
  Msg.Data[0] := 0;
  AoWHSMap.SendMsg(Msg, Self);
  Result := Msg.Data[0] = 0;
  if Result then Messages.Add(TranslateRStr(MapSuccessfullyValidatedRStr))
  else Messages.Add(TranslateRStr(MapValidationFailedRStr));
end;


procedure TAoWHSMap.OnStreamError(Stream: TEStorageStream; const Message: string; var Handled: Boolean);
var
  Answer: Integer;
begin
  if not FIgnoreStreamErrors then
  begin
    Answer := MessageDlg(Message + ' Ignore failure?', mtError,
      [mbYes, mbNo, mbAll], 0);
    Handled := (Answer = mrYes) or (Answer = mrAll);
    FIgnoreStreamErrors := Answer = mrAll;
  end;
end;


procedure TAoWHSMap.NotifyProgress(const Progress: HSEngine.TMapProgress);
var
  DefaultText, Text: string;
  Percent, Total: Integer;
begin
  if Assigned(OnProgress) then
  begin
    DefaultText := TranslateRStr(OneMomentPleaseStr);
    case Progress.ProgressType of
      ptLoading:
        begin
          Total := Progress.Percent + Progress.Level * 100; Percent := Round((Total) / 3 / MapContainer.LevelCount);
          if AoWEngine.FDebug then Text := TranslateRStr(LoadingLevelRStr) + IntToStr(Progress.Level)
          else Text := DefaultText;
          OnProgress(Self, Text, Percent);
        end;
      ptInitializing:
        begin
          Total := Progress.Percent + Progress.Level * 100; Percent := Round((Total) / 4.5 / MapContainer.LevelCount + 100 / 3);
          if AoWEngine.FDebug then Text := TranslateRStr(InitializingLevelRStr) + IntToStr(Progress.Level)
          else Text := DefaultText;
          OnProgress(Self, Text, Percent);
        end;
      ptUpdatingTerrain:
        begin
          Total := Progress.Percent + Progress.Level * 100; Percent := Round((Total) / 4.5 / MapContainer.LevelCount + 500 / 9);
          if AoWEngine.FDebug then Text := TranslateRStr(UpdatingTerrainLevelRStr) + IntToStr(Progress.Level)
          else Text := DefaultText;
          OnProgress(Self, Text, Percent);
        end;
      ptActivating:
        begin
          Total := Progress.Percent + Progress.Level * 100; Percent := Round((Total) / 4.5 / MapContainer.LevelCount + 700 / 9);
          if AoWEngine.FDebug then Text := TranslateRStr(ActivatingLevelRStr) + IntToStr(Progress.Level)
          else Text := DefaultText;
          OnProgress(Self, Text, Percent);
        end;
      ptSaving: OnProgress(Self, TranslateRStr(SavingLevelRStr) + IntToStr(Progress.Level), Progress.Percent);
      ptDestroying: OnProgress(Self, TranslateRStr(DestroyingLevelRStr) + IntToStr(Progress.Level), Progress.Percent);
    end;
  end;
end;


procedure TAoWHSMap.ReadWrite(Stream: Engine.TEStorageStream);
var
  X, Y, L: Integer;
begin
  if (smRead in Stream.StorageMode) and not (smTranslate in Stream.StorageMode) then
    Stream.ShowProgress(Self, TranslateRStr(OneMomentPleaseStr), 0);
  if Stream.StorageMode * [smWrite, smTextOnly] = [smWrite] then ResetModified;
  FIgnoreStreamErrors := False;
  if msEditting in Status then Stream.OnError := OnStreamError;
  Stream.rwData(FConnectionType, SizeOf(FConnectionType), $1F);
  if FConnectionType = pcNetwork then
  begin
    X := FViewXhp; FViewXhp := 0;
    Y := FViewYhp; FViewYhp := 0;
    L := FViewL; FViewL := 0;
  end
  else
  begin
    X := 0; Y := 0; L := 0;
  end;
  inherited ReadWrite(Stream);
  if FConnectionType = pcNetwork then
  begin
    FViewXhp := X; FViewYhp := Y; FViewL := L;
  end;
  Stream.rwString(FAuthor, 7);
  Stream.rwStrings(FDescription, $B);
  Stream.rwStrings(FObjectives, $C);
  Stream.rwData(FIndependentAIMode, SizeOf(FIndependentAIMode), $D);
  Stream.rwByte(Byte(FCurrentPlayer), $10);
  Stream.rwData(FTurnOrderMode, SizeOf(FTurnOrderMode), $11);
  Stream.rwStreamProc($12, FTurnOrder.LoadFromStream, FTurnOrder.SaveToStream);
  Stream.rwInteger(FDay, $13);
  Stream.rwString(FSessionName, $14);
  Stream.rwEObject(FPlayers, $15);
  Stream.rwEObject(FRaces, $16);
  Stream.rwBool(FExplorationEnabled, $17);
  if not (smPreview in Stream.StorageMode) then Stream.rwEObject(FHeroControl, $18);
  Stream.rwString(FMapName, $19);
  Stream.rwBool(FFogEnabled, $1A);
  Stream.rwByte(Byte(FHeroCountMax), $1B);
  Stream.rwInteger(FDefendersSeed, $1C);
  if not (smTextOnly in Stream.StorageMode) and not (smPreview in Stream.StorageMode) and
    not (smCompare in Stream.StorageMode) then Stream.rwEObject(FStartupSongs, $1D);
  Stream.rwEObject(FItemControl, $1E);
  Stream.rwData(FGameStatus, SizeOf(FGameStatus), $22);
  Stream.rwData(FGameResult, SizeOf(FGameResult), $23);
  Stream.rwInteger(FInitialRandomSeed, $24);
  Stream.rwData(FGameType, SizeOf(FGameType), $25);
  Stream.rwEObject(FUnitControl, $26);
  Stream.rwData(FPlayMode, SizeOf(FPlayMode), $27);
  Stream.rwEObject(FGlobalMagicControl, $28);
  Stream.rwIntegerEx(FSphereCount, 5, $29);
  Stream.rwEObject(FTextControl, $2A);
  Stream.rwEObject(FCampaignSettings, $2B);
  Stream.rwEObject(FHeroControl, $2C); { Original stores the hero control twice. }
  Stream.rwData(FVictoryCondition, SizeOf(FVictoryCondition), $2D);
  Stream.rwInteger(FVictoryMana, $2E);
  Stream.rwInteger(FVictoryGold, $2F);
  Stream.rwBool(FFixedLeaders, $30);
  Stream.rwBool(FAlliedVictory, $31);
  Stream.rwEObject(FAIGroupManager, $32);
  Stream.rwInteger(FDayLimit, $33);
  Stream.rwInteger(FTurnTime, $34);
  Stream.rwBool(FUnlimitedMoves, $35);
  Stream.rwEObject(FStructureControl, $36);
  if (smRead in Stream.StorageMode) or (FConnectionType <> pcNetwork) then
    Stream.rwInteger(FTurnTimeElapsed, $37);
  Stream.rwEObject(FTutorialControl, $38);
  if (smRead in Stream.StorageMode) or (FConnectionType <> pcNetwork) then
    Stream.rwInteger(FTurnTimeBeep, $3A);
  Stream.rwBool(FLeadersFixed, $3B);
  if not (smTextOnly in Stream.StorageMode) and not (smPreview in Stream.StorageMode) and
    (FConnectionType <> pcNetwork) then Stream.rwEObject(FGameSongs, $3C);
  Stream.rwBool(FStartingGame, $3D);
  Stream.rwBool(FShowAllPlayers, $3E);
  Stream.rwData(FVictoryMode, SizeOf(FVictoryMode), $3F);
  RandSeed := FDefendersSeed;
end;


procedure TAoWHSMap.MainReadWrite(Stream: Engine.TEStorageStream);
var
  FileName: string;
begin
  inherited MainReadWrite(Stream);
  if (Stream.StorageMode * [smRead, smTextOnly, smPreview, smCompare] = [smRead]) and (FDay = 0) then
  begin
    if FGameType = gtCampaign then FileName := AoWEngine.StartupDirectory + 'Dict\' + 'CampMaps' + '.mld'
    else FileName := AoWEngine.StartupDirectory + 'Dict\' + 'CustMaps' + '.mld';
    if FileExists(FileName) then AoWEngine.TranslateEObjectFromFile(Self, FileName);
  end;
end;


class function TAoWHSMap.ClassID: Integer;
begin
  Result := $20011;
end;


procedure TAoWHSMap.InitializeMapLevel(Level: Shortint);
var
  Control: THexagonControl;
  X, Y: Integer;
begin
  Control := Engine.HSSet.HexagonControl;
  if Level = 0 then
    for X := 6 to MapContainer.Width - 7 do
      for Y := 6 to MapContainer.Height - 7 do
        Control.Place(MapContainer, X, Y, 0, 0)
  else
    for X := 1 to MapContainer.Width - 7 do
      for Y := 1 to MapContainer.Height - 7 do
        Control.Place(MapContainer, X, Y, Level, 7);
  for X := 0 to MapContainer.Width - 1 do
  begin
    for Y := 0 to 5 do Control.Place(MapContainer, X, Y, Level, 15);
    for Y := MapContainer.Height - 6 to MapContainer.Height - 1 do
      Control.Place(MapContainer, X, Y, Level, 15);
  end;
  for Y := 6 to MapContainer.Height - 7 do
  begin
    for X := 0 to 5 do Control.Place(MapContainer, X, Y, Level, 15);
    for X := MapContainer.Width - 6 to MapContainer.Width - 1 do
      Control.Place(MapContainer, X, Y, Level, 15);
  end;
end;


procedure TAoWHSMap.InitializeNewMap; { Original uses a 32-bit map-level loop counter. }
var
  L: Integer;
  I: Integer;
  Obj: TEObject;
begin
  FRaces.Update;
  FPlayers.SetNumberOfPlayers(2);
  FPlayers.ValidateRaces(FRaces);
  for L := 0 to MapContainer.LevelCount - 1 do InitializeMapLevel(L);
  for I := 0 to AoWHSSet.FItemLibraries.FSystemLibrary.Count - 1 do
  begin
    Obj := AoWHSSet.FItemLibraries.FSystemLibrary.GetItem(I).Copy(AoWEngine);
    FItemControl.RegisterItem(TItem(Obj));
    Obj.Release;
  end;
  for I := 0 to AoWHSSet.FHeroLibraries.FSystemLibrary.Count - 1 do
  begin
    Obj := AoWHSSet.FHeroLibraries.FSystemLibrary.GetHero(I).Copy(AoWEngine);
    FHeroControl.RegisterHero(THero(Obj));
    Obj.Release;
  end;
end;


function TAoWHSMap.AddMapLevel: Boolean;
begin
  if (MapContainer.LevelCount < 3) and MapContainer.AddLevel($20013) then
  begin
    InitializeMapLevel(MapContainer.LevelCount - 1);
    Result := True;
  end
  else Result := False;
end;


function TAoWHSMap.CreateNewMap(Settings: HSEngine.TNewHSMapSettings): Boolean;
begin
  Result := inherited CreateNewMap(Settings);
end;


procedure TAoWHSMap.NotifyPlayerChangedEx(X, Y, L, Radius: Integer);
var
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  MapLevel := MapContainer.GetMapLevel(L);
  Msg.MsgID := $110D;
  Msg.Result := 1;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      if WordRec(LongRec(Field.FFieldFlags).Hi).Hi and 1 <> 0 then
      begin
        Msg.Param[0] := Walk.Radius;
        Field.SendMapFieldMsg(Msg);
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;


procedure TAoWHSMap.UpdatePlayerSeen(Player, X, Y, L, SightRadius, Radius: Integer);
var
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Field: TAoWMapField;
  I: Integer;
begin
  MapLevel := MapContainer.GetMapLevel(L);
  Msg.MsgID := $1130;
  Msg.Param[0] := Player;
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.Radius <= SightRadius) or (Walk.Radius <= Radius) do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      if WordRec(LongRec(Field.FFieldFlags).Hi).Hi and 2 <> 0 then
      begin
        Msg.Result := -1;
        if Walk.Radius <= Radius then Msg.Param[1] := 1; { Original leaves the flag uninitialized outside Radius. }
        Field.SendMapFieldMsg(Msg);
        if (Msg.Result <> -1) and (Msg.Result <> Player) then
        begin
          AoWHSMap.FPlayers.GetPlayers(Player).PlayerSeen(Msg.Result);
          for I := 0 to FPlayers.Count - 1 do
            if (I <> Player) and (FPlayers.GetDiplomaticRelation(Player, I) = drAlliance) then
              AoWHSMap.FPlayers.GetPlayers(I).PlayerSeen(Msg.Result);
        end;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;


procedure TAoWHSMap.NotifyPlayerChanged(X, Y, L: Integer);
begin
  NotifyPlayerChangedEx(X, Y, L, 12);
end;


function TAoWHSMap.VisibleForPlayer(X, Y, Level: Integer; Player: Shortint): Boolean;
var
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  MapLevel := MapContainer.GetMapLevel(Level);
  if Player >= 0 then
  begin
    Msg.MsgID := $110A;
    Msg.Result := 0;
    Msg.Param[1] := Player;
    InitHNWalk(Walk, X, Y, 0);
    while (Msg.Result = 0) and (Walk.Radius <= 12) do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
      begin
        Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
        if WordRec(LongRec(Field.FFieldFlags).Lo).Hi and $10 <> 0 then
        begin
          Msg.Param[0] := Walk.Radius;
          Field.SendMapFieldMsg(Msg);
        end;
      end;
      WalkToNextHN(Walk);
    end;
    Result := Msg.Result <> 0;
  end
  else Result := False;
end;


function TAoWHSMap.FoggedForPlayer(X, Y, L: Integer; Player: Shortint): Boolean;
var
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Field: TAoWMapField;
begin
  MapLevel := MapContainer.GetMapLevel(L);
  if not FExplorationEnabled or TAoWMapField(MapLevel.GetField(X, Y)).GetExplored(Player) then
  begin
    if FFogEnabled then
    begin
      if Player <> AoWHSMap.FSeatedPlayer then
      begin
        Msg.MsgID := $110A;
        Msg.Result := 0;
        Msg.Param[1] := Player;
        InitHNWalk(Walk, X, Y, 0);
        while (Msg.Result = 0) and (Walk.Radius <= 12) do
        begin
          if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
          begin
            Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
            if WordRec(LongRec(Field.FFieldFlags).Lo).Hi and $10 <> 0 then
            begin
              Msg.Param[0] := Walk.Radius;
              Field.SendMapFieldMsg(Msg);
            end;
          end;
          WalkToNextHN(Walk);
        end;
        Result := Msg.Result = 0;
      end
      else Result := WordRec(LongRec(TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).FFieldFlags).Hi).Lo = 0;
    end
    else Result := False;
  end
  else Result := True;
end;

procedure TAoWHSMap.MouseMoved(Sender: TObject);
var
  Field: TAoWMapField;
begin
  if (Mouse.Capture = nil) and (Mouse.Xhx <> -1) then
  begin
    Field := TAoWMapField(MapContainer.GetField(Mouse.Xhx, Mouse.Yhx, FViewL));
    if AoWHSMap.FExplorationEnabled and not Field.GetExplored(AoWHSMap.FSeatedPlayer) then Exit;
    if (not AoWHSMap.FFogEnabled) or (WordRec(LongRec(Field.FFieldFlags).Hi).Lo <> 0) then
      if Selection.CanSelectLocation(Mouse.Xhp, Mouse.Yhp, FViewL) and
        not TAbstractAoWHSMapMouse(Mouse).GetSelectingRectangle then Mouse.CursorMode := $101
      else Mouse.CursorMode := 0;
  end;
end;


procedure TAoWHSMap.UpdateCursor;
begin
  case Mouse.CursorMode of
    0: Mouse.Cursor := 0;
    $101: Mouse.Cursor := (Frame shr 2) mod 4 + $34;
    $102: Mouse.Cursor := ((Frame shr 2) and 1) + $31;
    $103: Mouse.Cursor := (Frame shr 2) mod 3 + $3A;
  end;
  Mouse.CursorVisible := Mouse.Cursor <> 0;
end;


procedure TAoWHSMap.ResetSeatedPlayerView; { Read the fallback army once, as in the original. }
var
  Player: TPlayer; Army: TArmy;
  XYL: Integer;
begin
  if FSeatedPlayer <> -1 then
  begin
    Player := FPlayers.GetPlayers(FSeatedPlayer);
    if Shortint(Player.FViewX) > 0 then
    begin
      WordRec(LongRec(XYL).Lo).Lo := Player.FViewX;
      WordRec(LongRec(XYL).Lo).Hi := Player.FViewY;
      WordRec(LongRec(XYL).Hi).Lo := Player.FViewL;
    end
    else
    begin
      Player.GetLeaderLocation(Shortint(WordRec(LongRec(XYL).Lo).Lo), Shortint(WordRec(LongRec(XYL).Lo).Hi), Shortint(WordRec(LongRec(XYL).Hi).Lo));
      if Shortint(WordRec(LongRec(XYL).Lo).Lo) = -1 then
        if Player.FArmies.Count = 0 then
        begin
          WordRec(LongRec(XYL).Lo).Lo := 0;
          WordRec(LongRec(XYL).Lo).Hi := 0;
          WordRec(LongRec(XYL).Hi).Lo := 0;
        end
        else
        begin
          Army := Player.FArmies.GetArmy(0); WordRec(LongRec(XYL).Lo).Lo := Army.FX;
          WordRec(LongRec(XYL).Lo).Hi := Army.FY;
          WordRec(LongRec(XYL).Hi).Lo := Army.FL;
        end;
    end;
    CenterViewTo(Shortint(WordRec(LongRec(XYL).Lo).Lo), Shortint(WordRec(LongRec(XYL).Lo).Hi), Shortint(WordRec(LongRec(XYL).Hi).Lo));
  end;
end;


procedure TAoWHSMap.Select(Sprite: THexagonSprite; Center: Boolean);
begin Sprite := Sprite; { This eliminated copy preserves the original saved registers. }
  Selection.UnselectLocation;
  Selection.SelectLocationHS(Sprite);
  if Center then CenterViewTo(Sprite.GetXhx, Sprite.GetYhx, Sprite.GetLhx);
end;


procedure TAoWHSMap.PlayerChanged;
begin
  FCurrentPlayerChangedEvents.TriggerNotifyEvents(Self);
end;


procedure TAoWHSMap.TokenControlActivatedEvent(Sender: TObject);
var
  Player: Integer;
begin
  if FCombatMap = nil then
  begin
    Player := FTokenManager.TokenExecuter.ActiveTCIndex;
    if Player <> FCurrentPlayer then
    begin
      FCurrentPlayer := Player;
      PlayerChanged;
    end;
  end;
end;


procedure TAoWHSMap.NewFrame; var CombatMap: TAbstractAoWCombatMap;
begin
  inherited NewFrame;
  if msActivated in Status then
  begin
    FPlayerControl.NewFrame;
    FPlayerCommunicator.Process;
    if (FCombatMap = nil) and (FGameStatus <> gsTerminated) then FAIExecuter.Process;
    FTokenManager.Process;
    UpdateCursor;
    UpdateExecuteEventLogDelay;
    UpdateTurnTimeBeep;
    UpdateEffects;
    CombatMap := FCombatMap; if CombatMap <> nil then CombatMap.NewFrame;
  end;
end;


procedure TAoWHSMap.StartNewMap;
var
  I: Integer;
begin
  FTurnOrder.Clear;
  if FTurnOrderMode = toFixed then
    for I := 0 to FPlayers.Count - 1 do FTurnOrder.Add(I);
  if FTurnOrderMode = toRandom then GenerateNewTurnOrder;
  for I := 0 to FPlayers.Count - 1 do
  begin
    FPlayers.GetPlayers(I).SetGems(FPlayers.GetPlayers(I).FInitialGold);
    FPlayers.GetPlayers(I).FMagicControl.SetMana(FPlayers.GetPlayers(I).FMagicControl.FExternalMana);
    case FPlayers.GetPlayers(I).FPlayerType of
      ptCPU4:
        begin
          FPlayers.GetPlayers(I).SetGems(FPlayers.GetPlayers(I).FGems + 250);
          FPlayers.GetPlayers(I).FMagicControl.SetMana(FPlayers.GetPlayers(I).FMagicControl.FMana + 250);
        end;
      ptCPU5:
        begin
          FPlayers.GetPlayers(I).SetGems(FPlayers.GetPlayers(I).FGems + 500);
          FPlayers.GetPlayers(I).FMagicControl.SetMana(FPlayers.GetPlayers(I).FMagicControl.FMana + 500);
        end;
    end;
  end;
  FPlayerControl.StartNewMap;
end;


procedure TAoWHSMap.StartLoadedMap;
begin
  FPlayerControl.StartLoadedMap;
end;


procedure TAoWHSMap.SetupPlayerControl(Mode: TPlayMode; Connection: TPlayerConnectionType);
begin
  case Mode of
    pmTurn:
      if FConnectionType = pcEmail then
      begin
        if not (FPlayerControl is TPBEMPlayerControl) then
        begin
          FPlayerControl.Free;
          FPlayerControl := TPBEMPlayerControl.Create(nil);
        end;
      end
      else
      begin
        { Original tests TPBEMPlayerControl even in the non-email branch. }
        if not (FPlayerControl is TPBEMPlayerControl) then
        begin
          FPlayerControl.Free;
          FPlayerControl := TTurnPlayerControl.Create(nil);
        end;
      end;
    pmSimultaneous:
      begin
        if not (FPlayerControl is TSimultaniousPlayerControl) then FPlayerControl.Free;
        FPlayerControl := TSimultaniousPlayerControl.Create(nil); { Original replaces an existing control without freeing it. }
      end;
  end;
  FConnectionType := Connection;
  FPlayMode := Mode;
  if FPlayerControl <> nil then FPlayerControl.Setup;
end;


procedure TAoWHSMap.Activate;
var
  I: Integer;
begin
  SynchroniseBegin;
  if (FDay = 0) or (FGameSongs.Songs.Count = 0) then
  begin
    FGameSongs.Songs.Clear;
    for I := 0 to AoWHSMap.FStartupSongs.Songs.Count - 1 do
      if CompareText(AoWHSMap.FStartupSongs.SongNames[I], TranslateRStr(FileNotFoundRStr)) <> 0 then
        FGameSongs.Songs.Add(AoWHSMap.FStartupSongs.Songs[I]);
  end;
  FGameStatus := gsPlaying;
  FDebugSave := AoWEngine.FRegistry.GetAutoDebugSave;
  FGlobalMagicControl.Update;
  FPlayers.BeginUpdate;
  FPlayers.EndUpdate;
  for I := 0 to FPlayers.Count - 1 do
    if FPlayers.GetPlayers(I).FBehavior = pbRandom then
      FPlayers.GetPlayers(I).FBehavior := TPlayerBehavior(AoWHSMap.Random(5));
  if FPlayerControl = nil then
  begin
    if FPlayMode = pmNone then FPlayMode := pmTurn;
    if FPlayers.FLocalHumanPlayers.Count > 1 then FPlayMode := pmTurn;
    SetupPlayerControl(FPlayMode, FConnectionType);
  end;
  FTokenManager.Initialize(FPlayerCommunicator);
  inherited Activate;
  if not (msEditting in Status) then
  begin
    if FDay = 0 then StartNewMap else StartLoadedMap;
    ShowMessage('');
  end;
  if AoWEngine.FRegistry.GetLogTokenEvents then StartTokenEventLogging;
  SynchroniseEnd;
end;


procedure TAoWHSMap.ActivateMsg;
begin
  if FDay = 0 then FRaces.ResetDefaultRelations;
  if not (msEditting in Status) and (FDay = 0) then
  begin
    FExplorationEnabled := True;
    FFogEnabled := True;
  end;
end;


function TAoWHSMap.Random(Range: Integer): Integer;
begin
  if not (msDestroying in AoWHSMap.Status) then
  begin
    if GetSynchronised then
    begin
      RandSeed := FDefendersSeed;
      Result := System.Random(Range);
      FDefendersSeed := RandSeed;
    end
    else
    begin
      Dialogs.ShowMessage('Invalid AoWHSMap.Random use');
      Result := 0;
    end;
  end
  else Result := System.Random(Range);
end;


procedure TAoWHSMap.GenerateNewTurnOrder;
var
  I, Index: Integer;
  List: TByteList;
begin
  List := TByteList.Create;
  for I := 1 to FPlayers.Count - 1 do List.Add(I);
  FTurnOrder.Clear;
  FTurnOrder.Add(0);
  while List.Count <> 0 do
  begin
    Index := Random(List.Count);
    FTurnOrder.Add(List[Index]);
    List.Delete(Index);
  end;
  List.Free;
end;


function TryEndPlayerTurn(Player: Shortint): Boolean;
begin
  if (Player <> -1) and not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy and
    not AoWHSMap.FPlayers.GetPlayers(Player).FSingleProcessCycle then Result := EndPlayerTurn(Player)
  else Result := False;
end;

function TAoWHSMap.EndTurn: Boolean;
begin
  if FSeatedPlayer <> -1 then
    if not FRequestCombatType or (FExecuteEventLogCallBacks.GetCount = 0) then
      Result := TryEndPlayerTurn(FSeatedPlayer)
    else Result := False
  else Result := False;
end;

function CancelPlayerTurn(Player: Shortint): Boolean;
var
  Event: TEndTurnTE;
begin
  if not AoWHSMap.FPlayers.GetPlayers(Player).GetBusy and
    AoWHSMap.FPlayers.GetPlayers(Player).FSingleProcessCycle then
  begin
    Event := TEndTurnTE.Create(nil);
    Event.FPlayer := Player;
    Event.FDay := AoWHSMap.FDay;
    Event.FMode := emCancelEndTurn;
    AoWHSMap.FTokenManager.GetTokenControl(Player).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;


function TAoWHSMap.CancelEndTurn: Boolean;
begin
  if FSeatedPlayer <> -1 then Result := CancelPlayerTurn(FSeatedPlayer)
  else Result := False;
end;


procedure TAoWHSMap.LockUpdateVisibility;
begin
  Inc(FUpdateVisibilityLockCount);
end;


procedure TAoWHSMap.UnLockUpdateVisibility;
begin
  Dec(FUpdateVisibilityLockCount);
  if (FUpdateVisibilityLockCount = 0) and FVisibilityChanged then UpdateVisibility;
end;


procedure TAoWHSMap.UpdateVisibility;
var
  Msg: TEMsg;
begin
  if FUpdateVisibilityLockCount = 0 then
  begin
    if not (msDestroying in Status) then
    begin
      LockMapChangedEvent;
      InitMsg(Msg, $20020008, Self);
      AoWHSMap.SendMsg(Msg, Self);
      UnlockMapChangedEvent;
      AoWHSMap.InvalidateMap;
    end;
    FVisibilityChanged := False;
  end
  else FVisibilityChanged := True;
end;


procedure TAoWHSMap.ResetMapLevels;
var
  I: Integer;
begin
  if MapContainer <> nil then
    for I := 0 to MapContainer.LevelCount - 1 do TAoWMapLevel(MapContainer.GetMapLevel(I)).Reset;
end;


procedure TAoWHSMap.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  if Msg.MsgID = $20000008 then
  begin
    SynchroniseBegin;
    FGlobalMagicControl.BeginUpdate;
    FPlayers.BeginUpdate;
    BeginUnitUpdate;
    LockUpdateVisibility;
    FItemControl.Activate;
    FStructureControl.Activate;
    if FDay = 0 then ResetMapLevels;
  end;
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    ActivateMsg;
    EndUnitUpdate;
    FPlayers.EndUpdate;
    FGlobalMagicControl.EndUpdate;
    UnLockUpdateVisibility;
    SynchroniseEnd;
  end
  else if Msg.MsgID = $20020005 then FUpdateVisibilityEvents.TriggerNotifyEvents(Self);
end;


procedure TAoWHSMap.SendMsg(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited SendMsg(Msg, Sender);
  if FGlobalMagicControl <> nil then FGlobalMagicControl.MsgProc(Msg, Sender);
  FPlayers.MsgProc(Msg, Sender);
  FRaces.MsgProc(Msg, Sender);
  FItemControl.MsgProc(Msg, Sender);
  FHeroControl.MsgProc(Msg, Sender);
  FAIGroupManager.MsgProc(Msg, Sender);
  if (Msg.MsgID = $20020002) and (Msg.Value = AoWHSMap.FSeatedPlayer) then
    if FSelectedArmy.GetArmyHS <> nil then FSelectedArmy.Update;
end;


procedure TAoWHSMap.ExecuteNegotiateMove(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAoWHSMap.InitializeCombatMap(A1: TCombat; const FileName: string);
var
  Player: TPlayer;
  X, Y, L: Integer;
begin
  if FCombatMap = nil then
  begin
    if FSeatedPlayer <> -1 then
    begin
      Player := FPlayers.GetPlayers(FSeatedPlayer);
      GetViewCenter(X, Y, L);
      Player.FViewX := X;
      Player.FViewY := Y;
      Player.FViewL := L;
    end;
    FCombatMap := TAbstractAoWCombatMap(AoWEngine.LoadHSMEx(AoWEngine.StartupDirectory + FileName, False, nil));
    FCombatMapCreatedEvents.TriggerNotifyEvents(Self);
  end;
end;


procedure TAoWHSMap.ReleaseCombatMap;
begin
  if FCombatMap <> nil then
  begin
    FCombatMapDestroyedEvents.TriggerNotifyEvents(Self);
    FCombatMap.Free;
    FCombatMap := nil;
    ResetSeatedPlayerView;
  end;
end;


function TAoWHSMap.CreateCombat(AClassID: Integer): TCombat;
begin
  if FCombat = nil then
  begin
    Result := TCombat(AoWEngine.CreateEObject(AClassID, nil));
    FCombat := Result;
    if (FGameType = gtTutorial) and (AClassID = $220110) then FTutorialControl.ShowMessage($35, False, True);
    if AClassID = $220110 then
    begin
      TAbstractAoWHSMapMouse(AoWHSMap.Mouse).ResetRectangleSelection;
      AoWHSMap.Selection.UnselectLocation;
      FTargetSelection.Deactivate;
      DisableTurnTimer;
    end;
  end
  else raise Exception.Create('Combat already created');
end;


procedure TAoWHSMap.ShowSeatedPlayerCallBack(Log: TEventLog);
begin
  SetSeatedPlayer(AoWHSMap.FCurrentPlayer);
  EnableTurnTimer;
end;


procedure TAoWHSMap.DestroyCombat;
var
  Player: Shortint;
  Count: Integer;
  Log: TNewTurnEventLog;
begin
  if FCombat <> nil then
  begin
    AoWHSMap.LockGameOverEvent;
    if cActivated in FCombat.FStatus then FCombat.Deactivate;
    if cExecuting in FCombat.FStatus then
    begin
      FCombat.Finalize;
      Player := FCombat.FCombatData.FPlayers.GetPlayers(FCombat.FCombatData.FAttackerPlayer).FPlayer;
      if (AoWHSMap.FConnectionType = pcNetwork) and (FPlayMode = pmSimultaneous) then
      begin
        Count := AoWHSMap.FPlayers.Count;
        Player := FCombat.FCombatData.FPlayers.GetPlayers(FCombat.FCombatData.FAttackerPlayer).FPlayer;
        while (Count <> 0) and (AoWHSMap.FPlayers.GetPlayers(Player).FStatus <> psPlaying) do
        begin
          Inc(Player);
          if Player = AoWHSMap.FPlayers.Count then Player := 0;
          Dec(Count);
        end;
      end;
      AoWHSMap.FTokenManager.TokenExecuter.ActivateTC(Player);
      if FPlayMode = pmSimultaneous then AoWHSMap.FTokenManager.TokenExecuter.HoldTC := False;
    end;
    if FRequestCombatType and (FCombat.ClassID <> $202B0) and (FCombat.FCombatData.FRound <> 0) and
      (FCombat.FExplorationSite <> 1) and (FPlayers.GetPlayers(FCurrentPlayer).FPlayerType = ptHuman) then
  begin
      LockExecuteEventLog;
      Log := TNewTurnEventLog.Create(nil);
      Log.FTurnPlayer := FCurrentPlayer;
      Log.FMode := ntDialog;
      Log.FDialogStyle := [nsCloseable];
      Log.FText := TranslateRStr(YourTurnContinuesRStr);
      TriggerExecuteEventLog(Log, False, ShowSeatedPlayerCallBack);
      Log.Release;
      UnlockGameOverEvent;
      SetSeatedPlayer(-1);
      UnlockExecuteEventLog;
    end
  else
  begin
      if FCombat.ClassID = $220110 then EnableTurnTimer;
      UnlockGameOverEvent;
    end;
    FCombat.Free;
    FCombat := nil;
  end;
end;


procedure TAoWHSMap.DrawDynamicScene(var SD: GFXE.TSurfaceDesc);
begin
  inherited DrawDynamicScene(SD);
  DrawFog(SD);
  if FShowGrid then DrawGrid(SD);
  FSelectedArmy.ShowMovePaths(SD);
  FTargetSelection.ShowSelection(FViewXhp, FViewYhp, SD);
  if TAbstractAoWHSMapMouse(Mouse).FSelectionRectangle.Left <> -1 then
    DrawSelectionRect(FViewXhp, FViewYhp, TAbstractAoWHSMapMouse(Mouse).FSelectionRectangle, SD);
end;


procedure TAoWHSMap.RetrieveBattleFieldInfo(X, Y, L, Radius: Integer; var Info: TBattleFieldInfo); { Retain addressable snapshots and separate comparison temporaries. }
var
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  Walk: THNWalkData;
  Field: TAoWMapField;
  Enemy, Friendly, KeepEnemy, NewFriendly, OldFriendly: Integer; Spill: Pointer;
begin
  Spill := @Friendly; Spill := @Enemy; Msg.MsgID := $1108;
  Msg.Param[0] := Integer(@Info);
  MapLevel := MapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.Width) and (Walk.Y < MapLevel.Height) then
    begin
      Field := TAoWMapField(MapLevel.GetField(Walk.X, Walk.Y));
      if WordRec(LongRec(Field.FFieldFlags).Hi).Hi and 4 <> 0 then
      begin
        Friendly := Info.FriendlyStrength;
        KeepEnemy := Info.Strength; Enemy := KeepEnemy;
        Field.SendMapFieldMsg(Msg);
        NewFriendly := Info.FriendlyStrength; OldFriendly := Friendly; if OldFriendly > NewFriendly then Info.FriendlyStrength := OldFriendly;
        if KeepEnemy > Info.Strength then Info.Strength := KeepEnemy;
      end;
    end;
    WalkToNextHN(Walk);
  end;
end;


procedure TAoWHSMap.TriggerRelationsChanged;
begin
  if (msActivated in Status) and (FRelationsChangedLockCount = 0) then
  begin
    BeginUnitUpdate;
    FUnitControl.TriggerUnitsChanged;
    FPlayerChangedEvents.TriggerNotifyEvents(Self);
    EndUnitUpdate;
  end;
end;


procedure TAoWHSMap.LockRelationsChanged;
begin
  Inc(FRelationsChangedLockCount);
end;


procedure TAoWHSMap.UnlockRelationsChanged;
begin










  Assert(FRelationsChangedLockCount <> 0, 'Invalid MapChanged Lock usage');
  Dec(FRelationsChangedLockCount);
end;


procedure TAoWHSMap.UpdateTurnTimeBeep;
var
  Seconds: Integer;
begin
  if GetTurnTimerEnabled then
  begin
    Seconds := GetTurnTimeLeft div 1000;
    if (FTurnTimeBeep <> 0) and (Seconds < FTurnTimeBeep) and (FCombatMap = nil) then
    begin
      FTurnTimeBeep := Seconds;
      if FTurnTimeBeep = 0 then PlaySample('SFX\EVENTS\CLOCK.WAV')
      else PlaySample('SFX\EVENTS\CLOCK.WAV');
    end;
  end;
end;


procedure TAoWHSMap.ResetTurnTimer;
begin
  FTurnTimeElapsed := FTurnTime * 1000 * 60;
  FTurnTimeBeep := 11;
  FTurnTimerStart := -1;
end;


function TAoWHSMap.GetTurnTimeLeft: Integer;
var
  Time, Left: Integer;
begin
  Left := FTurnTimeElapsed; Self := TAoWHSMap(Pointer(Self));
  if FTurnTimerStart <> -1 then
  begin
    Time := GetElapsedMilliSeconds;
    if Time >= FTurnTimerStart then Left := Left - (Time - FTurnTimerStart)
    else Left := 0;
  end;
  if Left < 0 then Left := 0;
  Result := Left;
end;


function TAoWHSMap.GetTurnTimerEnabled: Boolean;
begin
  Result := (FTurnTime > 0) and (FTurnTimerStart <> -1);
end;


procedure TAoWHSMap.EnableTurnTimer;
begin
  if (FTurnTimerStart = -1) and (FTurnTime > 0) then FTurnTimerStart := GetElapsedMilliSeconds;
end;


procedure TAoWHSMap.DisableTurnTimer;
var
  Time: Integer;
begin
  Time := GetElapsedMilliSeconds - FTurnTimerStart;
  if Time > 0 then Dec(FTurnTimeElapsed, Time);
  FTurnTimerStart := -1;
end;


procedure TAoWHSMap.ZeroTurnTimer;
begin
  FTurnTimeElapsed := 0;
end;


function TAoWHSMap.ChangeTerrain(MO: Engine.TEObject; X, Y, L, Radius, TerrainType: Integer): Integer;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Result := inherited ChangeTerrain(MO, X, Y, L, Radius, TerrainType);
end;


function TAoWHSMap.ChangeTerrainEx(MO: Engine.TEObject; X, Y, L, Radius: Integer; ChangeTerrainProc: HSEngine.TChangeTerrainProc; TerrainChangedProc: HSEngine.TTerrainChangedProc): Integer;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Result := inherited ChangeTerrainEx(MO, X, Y, L, Radius, ChangeTerrainProc, TerrainChangedProc);
end;


procedure TAoWHSMap.CenterOnLeader(Player: Shortint; Select: Boolean; Animate: Boolean);
var
  X, Y, L: Shortint;
  Army: TArmyHS;
begin
  if AoWHSMap.FPlayers.GetPlayers(Player).FLeader <> nil then
  begin
    AoWHSMap.FPlayers.GetPlayers(Player).FLeader.GetLocation(X, Y, L);
    if X > 0 then { Original excludes X = 0. }
    begin
      AoWHSMap.CenterViewTo(X, Y, L);
      if Animate then AoWHSMap.PlayCenterAnimation(X, Y, L);
      Army := TAoWMapField(AoWHSMap.MapContainer.GetField(X, Y, L)).GetArmyHS;
      if Army <> nil then
      begin
        Selection.UnselectLocation;
        Selection.SelectLocationHS(Army);
      end;
    end;
  end;
end;


procedure TAoWHSMap.PlaceTerrain(X, Y, L, TerrainType, OverlayType: Shortint);
var
  Resources: TEObjectList;
  Candidates: TList;
  Resource: TMapObjectResource;
  I: Integer;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Resources := AoWHSSet.MapObjectResourceList.FChildren;
  if not (OverlayType in [4, 5]) then
  begin
    Candidates := TList.Create;
    Candidates.Clear;
    for I := 0 to Resources.Count - 1 do
    begin
      Resource := TMapObjectResource(Resources.List^[I]);
      if (Resource.ClassID = $20167) and (Resource.TerrainList.UsedTerrain = 1) and
        (Resource.TerrainList.Terrain[0] = TerrainType) and (Resource.TerrainList.Overlay[0] = OverlayType) then
        Candidates.Add(Resource);
    end;
    if Candidates.Count <> 0 then
      TMapObjectResource(Candidates[Random(Candidates.Count)]).PlaceResourceUser(AoWHSMap, X, Y, L);
    Candidates.Free;
  end
  else AoWHSSet.RoadControl.Place(AoWHSMap.MapContainer, X, Y, L, TerrainType);
end;


procedure TAoWHSMap.UpdateEffects;
var
  I: Integer;
  Effect: TWorldFXHS;
begin
  if not (msEditting in Status) then
  begin
    I := 0;
    while I < FEffects.Count do
    begin
      Effect := TWorldFXHS(FEffects[I]);
      if Effect.FDone then
      begin
        DynamicFixedVisibleHS.RemoveChild(Effect);
        DynamicVisibleHS.RemoveChild(Effect);
        Effect.Free;
        FEffects.Delete(I);
      end
      else Inc(I);
    end;
  end;
end;


function TAoWHSMap.AddEffect(EffectType: TworldFXType): TWorldFXHS;
var
  Effect: TWorldFXHS;
begin
  Effect := TWorldFXHS.Create(nil);
  FEffects.Add(Effect);
  Effect.Activate;
  Effect.FEffectType := EffectType;
  DynamicFixedVisibleHS.AddChild(Effect);
  Result := Effect;
end;

