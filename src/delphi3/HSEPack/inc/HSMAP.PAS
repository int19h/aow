{ THSMap }

type
  { The layout of TMapField up to its terrain and overlay types, which THSMap.CanChangeTerrain saves
    and restores as one Word (the original reads word ptr [MapF+$14]) }
  TMapFieldTandO = class(TECustomNode)
  private
    FHSList: Pointer;
    FCounts: Integer;
    FXYL: Integer;
    FTandO: Word;
  end;

constructor THSMap.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FMouse := CreateMouse;
  FMouse.FHSMap := Self;
  FSelection := THexagonSpriteSelection.Create(Self);
  FSelection.SetControlStyle([csShared]);
  FStaticVisibleHS := TVisibilityList.Create(Self);
  FStaticVisibleHS.SetControlStyle([csShared]);
  FDynamicVisibleHS := TVisibilityList.Create(Self);
  FDynamicVisibleHS.SetControlStyle([csShared]);
  FStaticFixedVisibleHS := TVisibilityList.Create(Self);
  FStaticFixedVisibleHS.SetControlStyle([csShared]);
  FDynamicFixedVisibleHS := TVisibilityList.Create(Self);
  FDynamicFixedVisibleHS.SetControlStyle([csShared]);
  FTimer := TETimerNode.Create(Self);
  FHSChangedEvents := TEventList.Create;
  FTerrainChangedEvents := TEventList.Create;
  FViewPortChangedEvents := TEventList.Create;
  FNewFrameEvents := TEventList.Create;
  FDestroyEvents := TEventList.Create;
end;

destructor THSMap.Destroy;
var
  Msg: TEMsg;
begin
  LockTerrainChangedEvent;
  FStatus := FStatus + [msDestroying];
  FSelection.FOnSelect.Clear;
  FSelection.FOnDeselect.Clear;
  FSelection.SetControlStyle([csShared]);
  FSelection.UnselectAll;
  FDestroyEvents.TriggerNotifyEvents(Self);
  FHSChangedEvents.Clear;
  FStaticVisibleHS.QuickClear;
  FDynamicVisibleHS.QuickClear;
  FStaticFixedVisibleHS.QuickClear;
  FDynamicFixedVisibleHS.QuickClear;
  InitMsg(Msg, $20010017, Self);
  SendMsg(Msg, Self);
  FNewFrameEvents.Clear;
  inherited Destroy;
  FHSChangedEvents.Free;
  FTerrainChangedEvents.Free;
  FViewPortChangedEvents.Free;
  FNewFrameEvents.Free;
  FMouse.Free;
  FDestroyEvents.Free;
  UnlockTerrainChangedEvent;
end;

class function THSMap.ClassID: Integer;
begin
  Result := $10200;
end;

function THSMap.CreateMouse: THSMapMouse;
begin
  Result := THSMapMouse.Create;
end;

function THSMap.GetControlStyle: TEControlStyles;
begin
  Result := inherited GetControlStyle + [csReserved2];
end;

procedure THSMap.Clear;
begin
  FStaticVisibleHS.QuickClear;
  FDynamicVisibleHS.QuickClear;
  FSelection.QuickClear;
  inherited Clear;
  FMapContainer := nil;
  ClearViewPort;
end;

procedure THSMap.RemoveMapLevel(Index: Integer);
begin
  FMapContainer.RemoveLevel(Index);
end;

function THSMap.AddMapLevel: Boolean;
begin
  Result := FMapContainer.AddLevel($10102);
end;

procedure THSMap.Activate;
begin
  if msActivated in FStatus then
    raise Exception.Create('HSMap already activated');
  FStatus := FStatus + [msActivated];
end;

procedure THSMap.Deactivate;
begin
  if not (msActivated in FStatus) then
    raise Exception.Create('HSMap wasn''t activated');
  FStatus := FStatus - [msActivated];
end;

procedure THSMap.CenterViewTo(Xhx, Yhx, Lhx: Integer);
begin
  if Assigned(FOnCenterView) then
    FOnCenterView(Xhx, Yhx, Lhx);
end;

procedure THSMap.ChangeViewTo(Xhp, Yhp, Lhp: Integer);
begin
  if Assigned(FOnChangeView) then
    FOnChangeView(Xhp, Yhp, Lhp);
end;

{ Tests OnCenterView instead of OnViewLevel (original slip). }
procedure THSMap.ViewLevel(Lhx: Integer);
begin
  if Assigned(FOnCenterView) and (Lhx < FMapContainer.FLevelCount) then
    FOnViewLevel(Lhx);
end;

procedure THSMap.MakeVisible(Xhx, Yhx, Lhx, Radius: Integer);
begin
  if (FViewL <> Lhx) or (Xhx - Radius < FViewXhx) or (Xhx + Radius >= FViewXhx + FViewWidthHX) or
    (Yhx - Radius < FViewYhx) or (Yhx + Radius >= FViewYhx + FViewHeightHX) then
    CenterViewTo(Xhx, Yhx, Lhx);
end;

procedure THSMap.TriggerTerrainChangedEvent(const R: TRect; L: Shortint);
var
  Info: TTerrainChangedInfo;
begin
  Info.Rect := R;
  Info.Level := L;
  Info.MapLevel := FMapContainer.GetMapLevel(L);
  FTerrainChangedEvents.TriggerNotifyEvents(TObject(@Info));
end;

procedure THSMap.TerrainChanged(const R: TRect; L: Shortint);
begin
  if FTerrainChangedLockCounter = 0 then
    TriggerTerrainChangedEvent(R, L);
end;

procedure THSMap.TerrainChangedRad(X, Y, L: Shortint; Radius: Integer);
var
  MapLevel: TMapLevel;
  R: TRect;
begin
  MapLevel := FMapContainer.GetMapLevel(L);
  R.Left := X - Radius;
  if R.Left < 0 then
    R.Left := 0;
  R.Right := X + Radius + 1;
  if R.Right > MapLevel.FWidth then
    R.Right := MapLevel.FWidth;
  R.Top := Y - Radius;
  if R.Top < 0 then
    R.Top := 0;
  R.Bottom := Y + Radius + 1;
  if R.Bottom > MapLevel.FHeight then
    R.Bottom := MapLevel.FHeight;
  TerrainChanged(R, L);
end;

procedure THSMap.LockTerrainChangedEvent;
begin
  Inc(FTerrainChangedLockCounter);
end;

procedure THSMap.UnlockTerrainChangedEvent;
begin
  Assert(FTerrainChangedLockCounter <> 0, 'Invalid TerrainChangedLockCounter');
  Dec(FTerrainChangedLockCounter);
end;

procedure THSMap.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  if Msg.MsgID = $20000008 then
    FEngine := THSEngine(Msg.Engine);
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
    FMouse.Reset;
end;

procedure THSMap.SetModified;
begin
  FStatus := FStatus + [msModified];
end;

procedure THSMap.ResetModified;
begin
  FStatus := FStatus - [msModified];
end;

function THSMap.GetMaxXhp: Integer;
var
  X, Y: Integer;
begin
  with FMapContainer do
    HXtoHP(FWidth - 1, FHeight - 1, X, Y);
  Inc(X, 40);
  Result := X;
end;

function THSMap.GetMaxYhp: Integer;
var
  Y, X: Integer;
begin
  with FMapContainer do
    if FHeight > 1 then
      HXtoHP(1, FHeight - 1, X, Y)
    else
      HXtoHP(0, FHeight - 1, X, Y);
  Inc(Y, 32);
  Result := Y;
end;

procedure THSMap.SetHSSFileName(FileName: string);
begin
  FHSSFileName := ExtractRelativePath(FEngine.StartupDirectory, ExpandFileName(FileName));
end;

procedure THSMap.NotifyProgress(const Progress: TMapProgress);
begin
end;

procedure THSMap.ReadWrite(Stream: TEStorageStream);
var
  B: Shortint;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smPartial] = [smRead, smPartial] then
    FStatus := FStatus + [msPreviewMode];
  if not (smText in Stream.StorageMode) then
    Stream.rwString(FHSSFileName, 2);
  if not (smPartial in Stream.StorageMode) and (smRead in Stream.StorageMode) and
    (FHSSFileName <> '') then
    THSEngine(Stream.Engine).InitializeHSSet(Stream.Engine.StartupDirectory + FHSSFileName,
      Stream.OnProgress);
  B := FVersion;
  Stream.rwByte(Byte(B), 3);
  FVersion := B;
  Stream.rwInteger(FViewXhp, 4);
  Stream.rwInteger(FViewYhp, 5);
  Stream.rwInteger(FViewL, 6);
end;

procedure THSMap.MainReadWrite(Stream: TEStorageStream);
begin
  inherited MainReadWrite(Stream);
  if not (msPreviewMode in FStatus) and
    (Stream.StorageMode * [smRead, smText, smSetupCompare] = [smRead]) then
    FMapContainer.Loaded;
end;

procedure THSMap.InitializeNewMap;
begin
end;

procedure THSMap.FillLevelWithResource(L: Integer; Resource: TMapObjectResource);
var
  X, Y: Integer;
begin
  for Y := 0 to FMapContainer.FHeight - 1 do
    for X := 0 to FMapContainer.FWidth - 1 do
      Resource.PlaceResourceUser(Self, X, Y, L);
end;

{ ChangeTerrain, ChangeTerrainEx and ClearTerrain clip the right edge of the changed rectangle
  into its Left (original slip). }
function THSMap.ChangeTerrain(MO: TMapObject; X, Y, L, Radius, TerrainType: Integer): Integer;
var
  List: TShortIntList;
  Count: Integer;
  MapF: TMapField;
  Walk: THNWalkData;
  R: TRect;
  MapLevel: TMapLevel;
begin
  LockTerrainChangedEvent;
  List := TShortIntList.Create;
  MapLevel := FMapContainer.GetMapLevel(L);
  Count := 0;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
      (Walk.Y < MapLevel.FHeight) then
    begin
      MapF := MapLevel.GetField(Walk.X, Walk.Y);
      List[Walk.HN] := MapF.FTerrainType;
      MapF.FTerrainType := TerrainType;
    end;
    WalkToNextHN(Walk);
  end;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
      (Walk.Y < MapLevel.FHeight) then
    begin
      MapF := MapLevel.GetField(Walk.X, Walk.Y);
      if not MapF.CanChangeTerrainEx(MO) then
      begin
        MapF.FTerrainType := List[Walk.HN];
        List[Walk.HN] := -127;
      end;
    end;
    WalkToNextHN(Walk);
  end;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.Radius <= Radius do
  begin
    if (List[Walk.HN] <> -127) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
    begin
      MapLevel.GetField(Walk.X, Walk.Y).FTerrainType := TerrainType;
      MapLevel.GetField(Walk.X, Walk.Y).TerrainChanged;
      Inc(Count);
    end;
    WalkToNextHN(Walk);
  end;
  UnlockTerrainChangedEvent;
  List.Free;
  if Count <> 0 then
  begin
    R.Left := X - Radius;
    if R.Left < 0 then
      R.Left := 0;
    R.Right := X + Radius + 1;
    if R.Right > MapLevel.FWidth then
      R.Left := MapLevel.FWidth;
    R.Top := Y - Radius;
    if R.Top < 0 then
      R.Top := 0;
    R.Bottom := Y + Radius + 1;
    if R.Bottom > MapLevel.FHeight then
      R.Bottom := MapLevel.FHeight;
    TerrainChanged(R, L);
  end;
  Result := Count;
end;

function THSMap.ChangeTerrainEx(MO: TMapObject; X, Y, L, Radius: Integer;
  ChangeTerrainProc: TChangeTerrainProc; TerrainChangedProc: TTerrainChangedProc): Integer;
var
  OrgList, NewList: TShortIntList;
  Changed: TBitList;
  Count: Integer;
  TerrainType, OverlayType: Shortint;
  MapF: TMapField;
  Walk: THNWalkData;
  R: TRect;
  MapLevel: TMapLevel;
begin
  if Assigned(ChangeTerrainProc) then
  begin
    LockTerrainChangedEvent;
    OrgList := TShortIntList.Create;
    NewList := TShortIntList.Create;
    Changed := TBitList.Create;
    MapLevel := FMapContainer.GetMapLevel(L);
    Count := 0;
    InitHNWalk(Walk, X, Y, 0);
    while Walk.Radius <= Radius do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
        (Walk.Y < MapLevel.FHeight) then
      begin
        MapF := MapLevel.GetField(Walk.X, Walk.Y);
        TerrainType := MapF.FTerrainType;
        OverlayType := MapF.FOverlayType;
        OrgList[Walk.HN * 2] := TerrainType;
        OrgList[Walk.HN * 2 + 1] := OverlayType;
        ChangeTerrainProc(MapF, TerrainType, OverlayType);
        MapF.FTerrainType := TerrainType;
        MapF.FOverlayType := OverlayType;
        NewList[Walk.HN * 2] := TerrainType;
        NewList[Walk.HN * 2 + 1] := OverlayType;
      end;
      WalkToNextHN(Walk);
    end;
    InitHNWalk(Walk, X, Y, 0);
    while Walk.Radius <= Radius do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
        (Walk.Y < MapLevel.FHeight) then
      begin
        MapF := MapLevel.GetField(Walk.X, Walk.Y);
        if not MapF.CanChangeTerrainEx(MO) then
        begin
          MapF.FTerrainType := OrgList[Walk.HN * 2];
          MapF.FOverlayType := OrgList[Walk.HN * 2 + 1];
          Changed[Walk.HN] := False;
        end
        else
          Changed[Walk.HN] := True;
      end;
      WalkToNextHN(Walk);
    end;
    InitHNWalk(Walk, X, Y, 0);
    while Walk.Radius <= Radius do
    begin
      if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
        (Walk.Y < MapLevel.FHeight) then
      begin
        if Changed[Walk.HN] then
        begin
          MapLevel.GetField(Walk.X, Walk.Y).FTerrainType := NewList[Walk.HN * 2];
          MapLevel.GetField(Walk.X, Walk.Y).FOverlayType := NewList[Walk.HN * 2 + 1];
          MapLevel.GetField(Walk.X, Walk.Y).TerrainChanged;
          Inc(Count);
        end;
        if Assigned(TerrainChangedProc) then
          TerrainChangedProc(MapLevel.GetField(Walk.X, Walk.Y), OrgList[Walk.HN * 2],
            OrgList[Walk.HN * 2 + 1]);
      end;
      WalkToNextHN(Walk);
    end;
    UnlockTerrainChangedEvent;
    Changed.Free;
    OrgList.Free;
    NewList.Free;
    if Count <> 0 then
    begin
      R.Left := X - Radius;
      if R.Left < 0 then
        R.Left := 0;
      R.Right := X + Radius + 1;
      if R.Right > MapLevel.FWidth then
        R.Left := MapLevel.FWidth;
      R.Top := Y - Radius;
      if R.Top < 0 then
        R.Top := 0;
      R.Bottom := Y + Radius + 1;
      if R.Bottom > MapLevel.FHeight then
        R.Bottom := MapLevel.FHeight;
      TerrainChanged(R, L);
    end;
    Result := Count;
  end
  else
    Result := 0;
end;

procedure THSMap.ClearTerrain(X, Y, L, Radius, TerrainType: Integer);
var
  Walk: THNWalkData;
  MapLevel: TMapLevel;
  Msg: TMapFieldMsg;
  R: TRect;
begin
  LockTerrainChangedEvent;
  MapLevel := FMapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  Msg.MsgID := $10;
  while Walk.Radius <= Radius do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
      (Walk.Y < MapLevel.FHeight) then
      MapLevel.GetField(Walk.X, Walk.Y).SendMapFieldMsg(Msg);
    WalkToNextHN(Walk);
  end;
  if TerrainType <> -1 then
    ChangeTerrain(nil, X, Y, L, Radius, TerrainType);
  UnlockTerrainChangedEvent;
  R.Left := X - Radius;
  if R.Left < 0 then
    R.Left := 0;
  R.Right := X + Radius + 1;
  if R.Right > MapLevel.FWidth then
    R.Left := MapLevel.FWidth;
  R.Top := Y - Radius;
  if R.Top < 0 then
    R.Top := 0;
  R.Bottom := Y + Radius + 1;
  if R.Bottom > MapLevel.FHeight then
    R.Bottom := MapLevel.FHeight;
  TerrainChanged(R, L);
end;

function THSMap.CanChangeTerrain(MO: TMapObject; X, Y, L: Integer; TerrainList: TTerrainList): Boolean;
var
  Walk: THNWalkData;
  SaveList: TTerrainList;
  MapLevel: TMapLevel;
  MapF: TMapField;
  T: Shortint;
begin
  Result := True;
  SaveList := TTerrainList.Create;
  SaveList.SetCount(TerrainList.FCount);
  MapLevel := FMapContainer.GetMapLevel(L);
  InitHNWalk(Walk, X, Y, 0);
  while Walk.HN < TerrainList.FCount do
  begin
    if TerrainList.GetUsed(Walk.HN) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
    begin
      MapF := MapLevel.GetField(Walk.X, Walk.Y);
      SaveList.SetTandO(Walk.HN, TMapFieldTandO(MapF).FTandO);
      T := TerrainList.GetTerrain(Walk.HN);
      if T >= 0 then
        MapF.FTerrainType := T;
      T := TerrainList.GetOverlay(Walk.HN);
      if T >= 0 then
        MapF.FOverlayType := T;
    end;
    WalkToNextHN(Walk);
  end;
  InitHNWalk(Walk, X, Y, 0);
  while (Walk.HN < TerrainList.FCount) and Result do
  begin
    if TerrainList.GetUsed(Walk.HN) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      Result := MapLevel.GetField(Walk.X, Walk.Y).CanChangeTerrainEx(MO);
    WalkToNextHN(Walk);
  end;
  InitHNWalk(Walk, X, Y, 0);
  while Walk.HN < TerrainList.FCount do
  begin
    if TerrainList.GetUsed(Walk.HN) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      TMapFieldTandO(MapLevel.GetField(Walk.X, Walk.Y)).FTandO := SaveList.GetTandO(Walk.HN);
    WalkToNextHN(Walk);
  end;
  SaveList.Free;
end;

function THSMap.CreateNewMap(Settings: TNewHSMapSettings): Boolean;
begin
  Clear;
  try
    SetHSSFileName(Settings.HSSFileName);
    FEngine.InitializeHSSet(Settings.HSSFileName, nil);
    FMapContainer := TMapContainer(FEngine.CreateEObject(Settings.MapContainerClassID, Self));
    FEngine.ActivateEObject(FMapContainer);
    FMapContainer.New(Settings);
    Result := True;
    InitializeNewMap;
    Activate;
  except
    Clear;
    raise;
  end;
end;

function THSMap.PlaceHX(HS: THexagonSprite; Xhx, Yhx, L: Integer): Boolean;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Result := HS.MainPlace(FMapContainer, Xhp, Yhp, L);
end;

function THSMap.Place(HS: THexagonSprite; Xhp, Yhp, L: Integer): Boolean;
begin
  Result := HS.MainPlace(FMapContainer, Xhp, Yhp, L);
end;

procedure THSMap.Remove(HS: THexagonSprite);
begin
  HS.MainRemove;
end;

procedure THSMap.GetViewCenter(var Xhx, Yhx, Lhx: Integer);
begin
  HPtoHX(FViewXhp + FViewWidth shr 1, FViewYhp + FViewHeight shr 1, Xhx, Yhx);
  Lhx := FViewL;
end;

function THSMap.SetViewPort(Xhp, Yhp, Lhp, Width, Height: Integer): Boolean;
var
  X1, Y1, X2, Y2: Integer;
begin
  if (Xhp <> FViewXhp) or (Yhp <> FViewYhp) or (Lhp <> FViewL) or (Width <> FViewWidth) or
    (Height <> FViewHeight) then
  begin
    ClearViewPort;
    FViewL := Lhp;
    FViewXhp := Xhp;
    FViewWidth := Width;
    FViewYhp := Yhp;
    FViewHeight := Height;
    HPtoHX(FViewXhp - 8, FViewYhp - 16, X1, Y1);
    HPtoHX(FViewXhp + Width - 1 + 8, FViewYhp + Height - 1 + 16, X2, Y2);
    if X2 >= FMapContainer.FWidth then
      X2 := FMapContainer.FWidth - 1;
    if Y2 >= FMapContainer.FHeight then
      Y2 := FMapContainer.FHeight - 1;
    if X1 < 0 then
      X1 := 0;
    if Y1 < 0 then
      Y1 := 0;
    FViewWidthHX := X2 - X1 + 1;
    FViewHeightHX := Y2 - Y1 + 1;
    FViewXhx := X1;
    FViewYhx := Y1;
    Result := True;
    FViewPortChangedEvents.TriggerNotifyEvents(Self);
  end
  else
    Result := False;
end;

procedure THSMap.ClearViewPort;
begin
  ResetVisibleStaticHS;
  ResetVisibleDynamicHS;
  FStaticSceneInvalid := True;
  FDynamicSceneInvalid := True;
  FViewXhp := -1;
  FViewYhp := -1;
  FViewL := -1;
  FViewWidth := 0;
  FViewHeight := 0;
end;

{ Viewing accepts one row below the view port, InvalidateStaticScene does not. }
function THSMap.Viewing(Xhx, Yhx, Lhx: Integer): Boolean;
begin
  Result := (Xhx >= FViewXhx) and (Xhx < FViewXhx + FViewWidthHX) and (Yhx >= FViewYhx) and
    (Yhx <= FViewYhx + FViewHeightHX) and (Lhx = FViewL);
end;

{ The message names ResetVisibleDynamicHS (original slip). }
procedure THSMap.ResetVisibleStaticHS;
var
  I: Integer;
begin
  try
    for I := FStaticVisibleHS.FCount - 1 downto 0 do
      THexagonSprite(FStaticVisibleHS.FItems^[I].Child).SetVisible(False);
    FStaticVisibleHS.QuickClear;
    FStaticVisibleHS.FSorted := False;
  except
    raise Exception.Create('Exception during ResetVisibleDynamicHS');
  end;
end;

procedure THSMap.ResetVisibleDynamicHS;
var
  I: Integer;
begin
  for I := FDynamicVisibleHS.FCount - 1 downto 0 do
    try
      THexagonSprite(FDynamicVisibleHS.FItems^[I].Child).SetVisible(False);
    except
      raise Exception.Create('Exception during ResetVisibleDynamicHS (' +
        FDynamicVisibleHS.FItems^[I].Child.ClassName + ')');
    end;
  FDynamicVisibleHS.QuickClear;
  FDynamicVisibleHS.FSorted := False;
end;

procedure THSMap.UpdateStaticScene;
var
  X, Y, MaxX, MaxY: Integer;
  MapLevel: TMapLevel;
begin
  ResetVisibleStaticHS;
  MaxX := FViewXhx + FViewWidthHX - 1;
  MaxY := FViewYhx + FViewHeightHX - 1;
  MapLevel := FMapContainer.GetMapLevel(FViewL);
  for X := FViewXhx to MaxX do
    for Y := MaxY downto FViewYhx do
      MapLevel.GetField(X, Y).CopyStaticVisibleHS(FStaticVisibleHS);
  for X := 0 to FStaticFixedVisibleHS.FCount - 1 do
    THexagonSprite(FStaticFixedVisibleHS.Children[X]).MakeVisible(FStaticVisibleHS);
  FStaticVisibleHS.Sort;
  FStaticSceneInvalid := False;
end;

procedure THSMap.UpdateDynamicScene;
var
  X, Y, MaxX, MaxY: Integer;
  MapLevel: TMapLevel;
begin
  ResetVisibleDynamicHS;
  MaxX := FViewXhx + FViewWidthHX - 1;
  MaxY := FViewYhx + FViewHeightHX - 1;
  MapLevel := FMapContainer.GetMapLevel(FViewL);
  for X := FViewXhx to MaxX do
    for Y := MaxY downto FViewYhx do
      MapLevel.GetField(X, Y).CopyDynamicVisibleHS(FDynamicVisibleHS);
  for X := 0 to FDynamicFixedVisibleHS.FCount - 1 do
    THexagonSprite(FDynamicFixedVisibleHS.Children[X]).MakeVisible(FDynamicVisibleHS);
  FDynamicVisibleHS.Sort;
  FDynamicSceneInvalid := False;
end;

procedure THSMap.DrawStaticHS(var SD: TSurfaceDesc);
var
  I: Integer;
begin
  if FStaticSceneInvalid then
    raise Exception.Create('Static scene is invalid, call UpdateStaticScene!');
  for I := FStaticVisibleHS.FCount - 1 downto 0 do
    THexagonSprite(FStaticVisibleHS.FItems^[I].Child).Show(FViewXhp, FViewYhp, SD);
end;

procedure THSMap.DrawStaticHSEx(var SD: TSurfaceDesc);
begin
end;

procedure THSMap.DrawStaticScene(var SD: TSurfaceDesc);
begin
  DrawStaticHS(SD);
  DrawStaticHSEx(SD);
end;

procedure THSMap.DrawDynamicHS(var SD: TSurfaceDesc);
var
  I: Integer;
begin
  if FDynamicSceneInvalid then
    raise Exception.Create('Dynamic scene is invalid, call UpdateDynamicScene!');
  for I := FDynamicVisibleHS.FCount - 1 downto 0 do
    THexagonSprite(FDynamicVisibleHS.FItems^[I].Child).Show(FViewXhp, FViewYhp, SD);
end;

procedure THSMap.DrawDynamicHSEx(var SD: TSurfaceDesc);
begin
end;

procedure THSMap.DrawDynamicScene(var SD: TSurfaceDesc);
begin
  DrawDynamicHS(SD);
  DrawDynamicHSEx(SD);
end;

procedure THSMap.InvalidateStaticScene(Xhx, Yhx, Lhx: Integer);
begin
  FStaticSceneInvalid := FStaticSceneInvalid or ((Xhx >= FViewXhx) and
    (Xhx < FViewXhx + FViewWidthHX) and (Yhx >= FViewYhx) and (Yhx < FViewYhx + FViewHeightHX) and
    (Lhx = FViewL));
end;

procedure THSMap.NewFrame;
begin
  Inc(FFrame);
  if FFrame > $FFFFF then
    FFrame := 0;
  FNewFrameEvents.TriggerNotifyEvents(Self);
end;
