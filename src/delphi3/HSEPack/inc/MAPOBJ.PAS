{ TMapObject }

class function TMapObject.ClassID: Integer;
begin
  Result := $10156;
end;

procedure TMapObject.SetVisible(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [moVisible]
  else if moVisible in FStatus then
    FStatus := FStatus - [moVisible];
end;

function TMapObject.GetLevel: Byte;
begin
  Result := FResource.FLevel;
end;

function TMapObject.EditName: string;
begin
  if FResource.FName = '' then
    Result := FResource.ResourceEditName
  else
    Result := FResource.FName;
end;

function TMapObject.GetVisible: Boolean;
begin
  Result := moVisible in FStatus;
end;

{ Value is not used: the edit mode is only ever switched on }
procedure TMapObject.SetEditMode(Value: Boolean);
begin
  FStatus := FStatus + [moEditMode];
end;

function TMapObject.GetEditMode: Boolean;
begin
  Result := moEditMode in FStatus;
end;

function TMapObject.GetXhx: Shortint;
begin
  Assert(Owner <> nil, 'Owner not set');
  Result := TMapField(Owner).FXhx;
end;

function TMapObject.GetYhx: Shortint;
begin
  Assert(Owner <> nil, 'Owner not set');
  Result := TMapField(Owner).FYhx;
end;

function TMapObject.GetLhx: Shortint;
begin
  Assert(Owner <> nil, 'Owner not set');
  Result := TMapField(Owner).FLhx;
end;

function TMapObject.GetResourceList(AEngine: TEngine): TMapObjectResourceList;
begin
  Result := THSEngine(AEngine).FHSSet.FMapObjectResourceList;
end;

procedure TMapObject.SetResource(Value: TMapObjectResource);
begin
  FResource := Value;
end;

function TMapObject.GetResourceID: Integer;
begin
  if moResourceLinked in FStatus then
    Result := FResource.ResourceID
  else
    Result := Integer(FResource);
end;

procedure TMapObject.SetResourceID(Value: Integer);
begin
  if moResourceLinked in FStatus then
    raise Exception.Create('Cannot set ResourceID when resource is linked!');
  FResource := TMapObjectResource(Value);
end;

function TMapObject.GetResourceLinked: Boolean;
begin
  Result := moResourceLinked in FStatus;
end;

procedure TMapObject.SetResourceLinked(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [moResourceLinked]
  else
    FStatus := FStatus - [moResourceLinked];
end;

function TMapObject.LinkToResource(AEngine: TEngine): Boolean;
var
  R: TEResource;
begin
  if not (moResourceLinked in FStatus) then
  begin
    R := GetResourceList(AEngine).FindResource(Integer(FResource));
    if R <> nil then
    begin
      FResource := TMapObjectResource(R);
      FStatus := FStatus + [moResourceLinked];
    end;
  end;
  Result := moResourceLinked in FStatus;
end;

procedure TMapObject.MakeVisible(VisibilityList: TVisibilityList);
begin
  if not (moVisible in FStatus) then
  begin
    FStatus := FStatus + [moVisible];
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;

function TMapObject.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := (msEditting in FResource.FEngine.FHSMap.FStatus) and
    (FResource.FTerrainList.FCount <> 0) and
    ((FResource.FTerrainList.GetTerrain(0) >= 0) or (FResource.FTerrainList.GetOverlay(0) >= 0));
end;

function TMapObject.GetSelected: Boolean;
begin
  Result := moSelected in FStatus;
end;

function TMapObject.GetTerrain(Index: Integer): Shortint;
begin
  Result := FResource.FTerrainList.GetTerrain(Index);
  if (moEditMode in FStatus) and (Result >= 0) then
    Result := -1;
end;

procedure TMapObject.SetTerrain(Index: Integer; Value: Shortint);
begin
  FResource.FTerrainList.SetTerrain(Index, Value);
end;

function TMapObject.GetTerrainCount: Integer;
begin
  Result := FResource.FTerrainList.FCount;
end;

function TMapObject.GetOverlay(Index: Integer): Shortint;
begin
  Result := FResource.FTerrainList.GetOverlay(Index);
  if (moEditMode in FStatus) and (Result >= 0) then
    Result := -1;
end;

procedure TMapObject.SetOverlay(Index: Integer; Value: Shortint);
begin
  FResource.FTerrainList.SetOverlay(Index, Value);
end;

function TMapObject.GetOverlayCount: Integer;
begin
  Result := FResource.FTerrainList.FCount;
end;

procedure TMapObject.Select;
begin
  FStatus := FStatus + [moSelected];
end;

procedure TMapObject.Unselect;
begin
  inherited Unselect;
  FStatus := FStatus - [moSelected];
end;

{ The object is persisted as the id of its resource (id 1). Reading links it to the resource of
  the stream's engine and raises EMapObjectResourceMissing when there is none. }
procedure TMapObject.ReadWrite(Stream: TEStorageStream);
var
  ID: Integer;
begin
  if Stream.StorageMode * [smText, smCompare] = [] then
    if smRead in Stream.StorageMode then
    begin
      SetResourceLinked(False);
      Stream.rwInteger(Integer(FResource), 1);
      LinkToResource(Stream.Engine);
      if not (moResourceLinked in FStatus) then
        raise EMapObjectResourceMissing.Create('Resource Missing ' + ClassName + ' ' +
          IntToStr(Integer(FResource)));
    end
    else
    begin
      ID := GetResourceID;
      Stream.rwInteger(ID, 1);
    end;
end;

function TMapObject.Place(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  Xhx, Yhx: Integer;
begin
  HPtoHX(Xhp, Yhp, Xhx, Yhx);
  Result := PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

function TMapObject.GetShowPriority: Integer;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(TMapField(Owner).FXhx, TMapField(Owner).FYhx, Xhp, Yhp);
  Result := FResource.FShowPriorityOffset + Yhp shl 13 + Xhp;
end;

procedure TMapObject.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
  R: TMapObjectResource;
begin
  HXtoHP(TMapField(Owner).FXhx, TMapField(Owner).FYhx, Xhp, Yhp);
  if FResource.FImageSequenceList = nil then
    FResource.FImageLibrary.Get(0).Show(Xhp - XhpSurf - 8, Yhp - YhpSurf, SurfaceDesc)
  else
    FResource.ShowComplexImage(Xhp - XhpSurf - 8, Yhp - YhpSurf, SurfaceDesc, 0,
      TMapField(Owner).FXhx + TMapField(Owner).FYhx * 16);
end;

procedure TMapObject.Connect;
begin
  FStatus := FStatus + [moPlacedOnMap];
end;

procedure TMapObject.Disconnect;
begin
  Owner := nil;
  FStatus := FStatus - [moPlacedOnMap];
end;

function TMapObject.Loaded: Boolean;
begin
  Connect;
  Result := True;
end;

function TMapObject.PlaceOnMap: Boolean;
begin
  Connect;
  if (FResource.FTerrainList.GetTerrain(0) >= 0) or (FResource.FTerrainList.GetOverlay(0) >= 0) then
    TMapField(Owner).UpdateTerrain;
  if GetLevel <= 15 then
    with TMapField(Owner) do
      TMapLevel(Owner).FMap.InvalidateStaticScene(FXhx, FYhx, FLhx);
  if not GetEditMode then
    with TMapField(Owner) do
      TMapLevel(Owner).FMap.TerrainChangedRad(FXhx, FYhx, FLhx, 0);
  Result := True;
end;

procedure TMapObject.RemoveFromMap;
var
  MapField: TMapField;
begin
  if moPlacedOnMap in FStatus then
  begin
    if Owner <> nil then
    begin
      MapField := TMapField(Owner);
      Disconnect;
      if not (msDestroying in TMapLevel(MapField.Owner).FMap.FStatus) then
      begin
        if (GetTerrain(0) >= 0) or (GetOverlay(0) >= 0) then
          MapField.UpdateTerrain;
        if (GetLevel <= 15) and GetVisible then
          TMapLevel(MapField.Owner).FMap.FStaticSceneInvalid := True;
      end;
      if not GetEditMode then
        TMapLevel(MapField.Owner).FMap.TerrainChangedRad(MapField.FXhx,
          MapField.FYhx, MapField.FLhx, 0);
    end;
    FStatus := FStatus - [moPlacedOnMap];
  end;
end;

procedure TMapObject.Remove;
var
  MapField: TMapField;
begin
  MapField := TMapField(Owner);
  RemoveFromMap;
  if GetVisible then
  begin
    if GetLevel <= 15 then
      TMapLevel(MapField.Owner).FMapContainer.FMap.FStaticVisibleHS.RemoveChild(Self)
    else
      TMapLevel(MapField.Owner).FMapContainer.FMap.FDynamicVisibleHS.RemoveChild(Self);
    SetVisible(False);
  end;
end;

function TMapObject.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  HS: THexagonSprite;
  MapField: TMapField;
begin
  if (Xhx >= 0) and (Yhx >= 0) and (Lhx >= 0) and (Xhx < MapContainer.FWidth) and
    (Yhx < MapContainer.FHeight) and (Lhx < MapContainer.FLevelCount) then
  begin
    MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
    HS := MapField.GetMaxLevelNoneTransparentHS;
    Result := ((HS = nil) or (HS.GetLevel < 10)) and
      MapField.CanChangeTerrain(Self, GetTerrain(0), GetOverlay(0));
  end
  else
    Result := False;
end;

function TMapObject.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Owner := MapContainer.GetField(Xhx, Yhx, Lhx);
  Result := PlaceOnMap;
end;

procedure TMapObject.Activate;
begin
  FStatus := FStatus + [moActivated];
end;

procedure TMapObject.Deactivate;
begin
  inherited Deactivate;
  FStatus := FStatus - [moActivated];
end;

function TMapObject.MainPlace(MapContainer: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  Xhx, Yhx: Integer;
begin
  if not (moPlacedOnMap in FStatus) then
  begin
    HPtoHX(Xhp, Yhp, Xhx, Yhx);
    if GetEditMode or CanPlace(MapContainer, Xhx, Yhx, Lhx) then
    begin
      Result := PlaceHX(MapContainer, Xhx, Yhx, Lhx);
      if Result then
        Activate
      else
        MainRemove;
    end
    else
      Result := False;
  end
  else
    Result := False;
end;

procedure TMapObject.MainRemove;
begin
  if moSelected in FStatus then
    Unselect;
  if moActivated in FStatus then
    Deactivate;
  if moPlacedOnMap in FStatus then
    Remove;
end;

procedure TMapObject.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if Msg.MsgID = $10 then
    if (GetTerrain(Msg.HN) >= 0) or (Msg.HN = 0) then
      Destroy;
end;

{ TMapObjectResource }

constructor TMapObjectResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FTerrainList := TTerrainList.Create;
  FImageLibrary := TImageLibrary.Create(nil);
  SetLevel(26);
end;

destructor TMapObjectResource.Destroy;
begin
  FTerrainList.Free;
  FImageLibrary.Free;
  if FImageSequenceList <> nil then
    FImageSequenceList.Free;
  inherited Destroy;
end;

function TMapObjectResource.GetEngine: TEngine;
begin
  Result := FEngine;
end;

function TMapObjectResource.ClassVersion: Integer;
begin
  Result := 1;
end;

class function TMapObjectResource.ClassID: Integer;
begin
  Result := $10154;
end;

class function TMapObjectResource.ResourceEditName: string;
begin
  Result := '';
end;

procedure TMapObjectResource.Draw(Canvas: TCanvas; Rect: TRect; Mode: TBltMode; ScaleX, ScaleY: Integer; BkColor, Color: TColor);
var
  I: Integer;
  Image: TLibraryImage;
  Sequence: TImageSequence;
  DrawRect: TRect;
begin
  I := 0;
  Image := nil;
  while (I <> FImageLibrary.Count) and (Image = nil) do
  begin
    Image := FImageLibrary.Get(I);
    Inc(I);
  end;
  if (Image = nil) and (FImageSequenceList <> nil) then
  begin
    I := 0;
    Sequence := nil;
    while (I <> FImageSequenceList.Count) and (Sequence = nil) do
    begin
      Sequence := FImageSequenceList.GetImageSequence(I);
      if Sequence = nil then
        Inc(I);
    end;
    BltImageSequenceEx(Canvas, Sequence, 0, Rect, Mode, ScaleX, ScaleY, BkColor, Color, False, DrawRect);
  end
  else
    BltLibraryImage(Canvas, Image, Rect, Mode, ScaleX, ScaleY, BkColor, Color, False, DrawRect);
end;

function TMapObjectResource.GetCellImage: TLibraryImage;
var
  I: Integer;
begin
  I := 0;
  Result := nil;
  while (I <> FImageLibrary.Count) and (Result = nil) do
  begin
    Result := FImageLibrary.Get(I);
    Inc(I);
  end;
  if (Result = nil) and (FImageSequenceList <> nil) then
    Result := FImageSequenceList.GetPreviewImage;
end;

procedure TMapObjectResource.SetCellImage(Value: TLibraryImage);
begin
  FImageLibrary.SetImage(0, Value);
end;

procedure TMapObjectResource.ReadWrite(Stream: TEStorageStream);
var
  Complex: Boolean;
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FShowPriorityOffset, 4);
  Stream.rwByte(FLevel, 5);
  Stream.rwString(FName, 6);
  Stream.rwStreamProc(7, FTerrainList.LoadFromStream, FTerrainList.SaveToStream);
  FImageLibrary.ReduceCount;
  Stream.rwStreamProc(8, FImageLibrary.LoadFromStream, FImageLibrary.SaveToStream);
  if not (smText in Stream.StorageMode) then
  begin
    if smRead in Stream.StorageMode then
    begin
      Stream.rwBool(Complex, 9);
      if Complex then
      begin
        if FImageSequenceList = nil then
          FImageSequenceList := TImageSequenceList.Create(nil, FImageLibrary);
      end
      else
      begin
        FImageSequenceList.Free;
        FImageSequenceList := nil;
      end;
    end
    else
    begin
      Complex := FImageSequenceList <> nil;
      Stream.rwBool(Complex, 9);
    end;
    if Complex then
      Stream.rwStreamProc(10, FImageSequenceList.LoadFromStream, FImageSequenceList.SaveToStream);
  end;
end;

procedure TMapObjectResource.ShowComplexImage(X, Y: Integer; const SurfaceDesc: TSurfaceDesc; Index: Integer; Offset: Cardinal);
var
  Sequence: TImageSequence;
  Frame: Integer;
begin
  if Index < FImageSequenceList.Count then
    Sequence := TImageSequence(FImageSequenceList.List^[Index])
  else
    Sequence := nil;
  while Sequence <> nil do
  begin
    Frame := Sequence.GetFrameIndex(FEngine.FHSMap.FFrame, Offset);
    if Frame <> -1 then
      Sequence.ImageLibrary.Get(Frame).Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;

function TMapObjectResource.CreateResourceUser: TEObject;
var
  ID: Integer;
  MO: TMapObject;
begin
  ID := ResourceUserClassID;
  if ID <> 0 then
  begin
    MO := TMapObject(FEngine.CreateEObject(ID, nil));
    if MO <> nil then
    begin
      MO.SetResource(Self);
      MO.SetResourceLinked(True);
    end;
  end
  else
    MO := nil;
  Result := MO;
end;

procedure TMapObjectResource.CalcShowPriorityOffset(dX, dY, Level: Integer);
begin
  FShowPriorityOffset := dX + (Level shl 26 + dY shl 13);
end;

procedure TMapObjectResource.SetLevel(Value: Byte);
begin
  FLevel := Value;
  CalcShowPriorityOffset(16, 32, FLevel);
end;

function TMapObjectResource.PlaceResourceUser(HSMap: THSMap; Xhx, Yhx, Lhx: Shortint): TMapObject;
var
  Xhp, Yhp: Integer;
begin
  Result := TMapObject(CreateResourceUser);
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Inc(Xhp, 16);
  Inc(Yhp, 16);
  if not HSMap.Place(Result, Xhp, Yhp, Lhx) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

procedure TMapObjectResource.ClearTerrain(X, Y, Lhx: Integer);
var
  I: Integer;
  Xhx, Yhx: Integer;
begin
  for I := FTerrainList.FCount - 1 downto 0 do
    if FTerrainList.GetTerrain(I) >= 0 then
    begin
      CenterHNtoHX(X, Y, I, Xhx, Yhx);
      FEngine.FHSMap.ClearTerrain(Xhx, Yhx, Lhx, 0, -1);
    end;
end;

{ The resource was dropped on the map (message $10005): fill the hexagons in Param[1] rings around
  the drop point with its users, clearing the terrain first when Param[2] = 1 }
procedure TMapObjectResource.EditDropMsg(var Msg: TEMsg);
var
  MapLevel: TMapLevel;
  Xhx, Yhx: Integer;
  Lhx: Integer;
  Rad: Integer;
  Clear: Boolean;
  Placed: Boolean;
  Walk: THNWalkData;
begin
  Placed := True;
  MapLevel := TMapLevel(Msg.Param[0]);
  Lhx := Msg.Data[1];
  Rad := Msg.Param[1];
  HPtoHX(Msg.Value, Msg.Data[0], Xhx, Yhx);
  Clear := Msg.Param[2] = 1;
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.Radius <= Rad do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
      (Walk.Y < MapLevel.FHeight) then
    begin
      if Clear then
        ClearTerrain(Walk.X, Walk.Y, Lhx);
      Placed := Placed and (PlaceResourceUser(FEngine.FHSMap, Walk.X, Walk.Y, Lhx) <> nil);
    end;
    WalkToNextHN(Walk);
  end;
  if Placed then
    Msg.Result := 0
  else
    Msg.Result := -1;
end;

procedure TMapObjectResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
  begin
    FEngine := THSEngine(Msg.Engine);
    if FImageSequenceList <> nil then
    begin
      FImageSequenceList.FILManager :=
        TImageLibraryManager(FEngine.FHSSet.FImageLibraryManager);
      FImageSequenceList.LinkToIL;
    end;
  end
  else if Msg.MsgID = $10005 then
    EditDropMsg(Msg)
  else if Msg.MsgID = $10055 then
    Msg.Result := 8;
end;

{ TMapObjectResourceList }

function TMapObjectResourceList.GetMOR(Index: Integer): TMapObjectResource;
begin
  Result := TMapObjectResource(FChildren.List^[Index]);
end;

function TMapObjectResourceList.FindMOR(AClassID: Integer; TerrainList: TTerrainList; Mode: TTerrainCompareMode; var List: TList): Boolean;
var
  R: TMapObjectResource;
  I: Integer;
begin
  Result := False;
  for I := 0 to FChildren.Count - 1 do
  begin
    R := TMapObjectResource(FChildren.List^[I]);
    if R.ClassID = AClassID then
      if (TerrainList = nil) or R.FTerrainList.CompareTerrain(TerrainList, Mode) then
      begin
        Result := True;
        List.Add(R);
      end;
  end;
end;

{ TAbstractHexagon }

class function TAbstractHexagon.ClassID: Integer;
begin
  Result := $10170;
end;

function TAbstractHexagon.GetShowPriority: Integer;
var
  MapField: TMapField;
  Xhp, Yhp: Integer;
begin
  MapField := TMapField(Owner);
  Xhp := MapField.FXhx * 32 + 8;
  Yhp := (MapField.FXhx and 1) * 16 + MapField.FYhx * 32;
  Result := Xhp + Yhp shl 13;
end;

function TAbstractHexagon.GetLevel: Byte;
begin
  Result := 0;
end;

procedure TAbstractHexagon.UpdateTransitions;
begin
end;

procedure TAbstractHexagon.SetResource(Value: TMapObjectResource);
begin
  inherited SetResource(Value);
  if moActivated in FStatus then
    UpdateTransitions;
end;

procedure TAbstractHexagon.Activate;
begin
  inherited Activate;
  UpdateTransitions;
end;

procedure TAbstractHexagon.ChangeTerrain(const Msg: THSTerrainInfo);
var
  Control: THexagonControl;
  R: TMapObjectResource;
begin
  if (Msg.HN = 0) and (GetTerrain(0) <> Msg.TerrainType) then
  begin
    Control := TAbstractHexagonResource(FResource).GetHexagonControl;
    if Control <> nil then
    begin
      R := Control.GetRndResource(Msg.TerrainType, FResource.ClassID);
      if R <> nil then
      begin
        SetResource(R);
        UpdateTransitions;
        FResource.FEngine.FHSMap.FMapContainer.FMap.InvalidateStaticScene(GetXhx, GetYhx, GetLhx);
      end
      else
        TAbstractHexagonResource(FResource).GetHexagonControl.Place(TMapContainer(Owner.Owner.Owner),
          GetXhx, GetYhx, GetLhx, Msg.TerrainType);
    end;
  end;
end;

procedure TAbstractHexagon.TerrainChanged(const Msg: THSTerrainInfo);
begin
  ChangeTerrain(Msg);
end;

function TAbstractHexagon.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  MapField: TMapField;
  HS: THexagonSprite;
begin
  if (Xhx >= 0) and (Yhx >= 0) and (Lhx >= 0) and (Xhx < MapContainer.FWidth) and
    (Yhx < MapContainer.FHeight) and (Lhx < MapContainer.FLevelCount) then
  begin
    MapField := MapContainer.GetField(Xhx, Yhx, Lhx);
    HS := MapField.GetMaxLevelNoneTransparentHS;
    Result := (HS = nil) or (((HS.GetLevel < 10) or MapField.CanChangeTerrain(Self, GetTerrain(0),
      GetOverlay(0))) and not (HS is TAbstractBorderHexagon));
  end
  else
    Result := False;
end;

function TAbstractHexagon.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  HS: THexagonSprite;
begin
  HS := MapContainer.GetField(Xhx, Yhx, Lhx).FindOwnedHS(TAbstractHexagon);
  if HS <> nil then
    HS.Destroy;
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
  if Result then
    UpdateTransitions;
end;

procedure TAbstractHexagon.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
  if Msg.MsgID <> $10 then
    inherited MapFieldMsgProc(Msg);
end;

{ TAbstractHexagonResource }

constructor TAbstractHexagonResource.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  SetLevel(0);
end;

function TAbstractHexagonResource.GetHexagonControl: THexagonControl;
begin
  Result := FEngine.FHSSet.FHexagonControl;
end;

procedure TAbstractHexagonResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10014 then
    if GetHexagonControl <> nil then
      GetHexagonControl.RegisterResource(Self);
end;

{ TAbstractBorderHexagon }

class function TAbstractBorderHexagon.ClassID: Integer;
begin
  Result := $10171;
end;

{ TAbstractRoad }

class function TAbstractRoad.ClassID: Integer;
begin
  Result := $10172;
end;

function TAbstractRoad.GetLevel: Byte;
begin
  Result := 10;
end;

function TAbstractRoad.GetShowPriority: Integer;
var
  MapField: TMapField;
  Xhp, Yhp: Integer;
begin
  MapField := TMapField(Owner);
  Xhp := MapField.FXhx * 32 + 8;
  Yhp := (MapField.FXhx and 1) * 16 + MapField.FYhx * 32;
  Result := Xhp + Yhp shl 13 + $28000000;
end;

procedure TAbstractRoad.UpdateTransitions;
begin
end;

procedure TAbstractRoad.Activate;
begin
  UpdateTransitions;
end;

function TAbstractRoad.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  HS: THexagonSprite;
begin
  if (Xhx >= 0) and (Yhx >= 0) and (Lhx >= 0) and (Xhx < MapContainer.FWidth) and
    (Yhx < MapContainer.FHeight) and (Lhx < MapContainer.FLevelCount) and
    (MapContainer.GetField(Xhx, Yhx, Lhx).FTerrainType = FResource.FTerrainList.GetTerrain(0)) then
  begin
    HS := MapContainer.GetField(Xhx, Yhx, Lhx).GetMaxLevelNoneTransparentHS;
    Result := (HS = nil) or (HS.GetLevel < 10) or (HS is TAbstractRoad);
  end
  else
    Result := False;
end;

procedure TAbstractRoad.NeighbourTerrainChanged(HN: Integer; const Msg: THSTerrainInfo);
begin
  UpdateTransitions;
end;

procedure TAbstractRoad.ChangeTerrain(const Msg: THSTerrainInfo);
var
  R: TMapObjectResource;
begin
  if (Msg.HN = 0) and (GetTerrain(0) <> Msg.TerrainType) then
  begin
    R := TAbstractRoadResource(FResource).GetRoadControl.GetRndResource(Msg.TerrainType, FResource.ClassID);
    if R <> nil then
    begin
      SetResource(R);
      UpdateTransitions;
      FResource.FEngine.FHSMap.FMapContainer.FMap.InvalidateStaticScene(GetXhx, GetYhx, GetLhx);
    end
    else if TAbstractRoadResource(FResource).GetRoadControl.Place(TMapContainer(Owner.Owner.Owner),
      GetXhx, GetYhx, GetLhx, Msg.TerrainType) = nil then
      Destroy;
  end;
end;

{ TAbstractRoadResource }

function TAbstractRoadResource.GetRoadControl: TRoadControl;
begin
  Result := FEngine.FHSSet.FRoadControl;
end;

procedure TAbstractRoadResource.MsgProc(var Msg: TEMsg; Sender: TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10014 then
    GetRoadControl.RegisterResource(Self);
  if Msg.MsgID = $10055 then
    Msg.Result := 6;
end;

function TAbstractRoadResource.PlaceResourceUser(HSMap: THSMap; Xhx, Yhx, Lhx: Shortint): TMapObject;
var
  Xhp, Yhp: Integer;
begin
  Result := TMapObject(CreateResourceUser);
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Inc(Xhp, 16);
  Inc(Yhp, 16);
  if not HSMap.Place(Result, Xhp, Yhp, Lhx) then
  begin
    Result.Free;
    Result := nil;
  end;
end;

{ TMultiHexMO }

function TMultiHexMO.GetXhx: Shortint;
begin
  Result := FXhx;
end;

function TMultiHexMO.GetYhx: Shortint;
begin
  Result := FYhx;
end;

function TMultiHexMO.GetXYL: Integer;
begin
  Result := GetLhx shl 16 + (FXhx + FYhx shl 8);
end;

function TMultiHexMO.GetShowPriority: Integer;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  Result := FResource.FShowPriorityOffset + Yhp shl 13 + Xhp;
end;

procedure TMultiHexMO.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FXhx), 3);
  Stream.rwByte(Byte(FYhx), 4);
end;

procedure TMultiHexMO.Show(XhpSurf, YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Xhp, Yhp: Integer;
  R: TMapObjectResource;
begin
  HXtoHP(FXhx, FYhx, Xhp, Yhp);
  if FResource.FImageSequenceList = nil then
    FResource.FImageLibrary.Get(0).Show(Xhp - XhpSurf + TMultiHexMOR(FResource).FdXImage,
      Yhp - YhpSurf + TMultiHexMOR(FResource).FdYImage, SurfaceDesc)
  else
    FResource.ShowComplexImage(Xhp - XhpSurf, Yhp - YhpSurf, SurfaceDesc, 0, Xhp + Yhp);
end;

{ Connect adds the object to the fields of its terrain list around the main hexagon }
procedure TMultiHexMO.Connect;
var
  Count: Integer;
  MapLevel: TMapLevel;
  MapField: TMapField;
  Walk: THNWalkData;
begin
  if not (moPlacedOnMap in FStatus) then
  begin
    FStatus := FStatus + [moPlacedOnMap];
    Count := GetTerrainCount;
    MapLevel := TMapLevel(Owner.Owner);
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while Walk.HN < Count do
    begin
      if ((GetTerrain(Walk.HN) >= -1) or (GetOverlay(Walk.HN) >= -1)) and (Walk.X >= 0) and
        (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      begin
        MapField := MapLevel.GetField(Walk.X, Walk.Y);
        if MapField = Owner then
          MapField.RemoveHS(Self);
        MapField.AddHS(Self, Walk.HN);
      end;
      WalkToNextHN(Walk);
    end;
  end;
end;

procedure TMultiHexMO.Disconnect;
var
  Count: Integer;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
begin
  if moPlacedOnMap in FStatus then
  begin
    Count := GetTerrainCount;
    MapLevel := TMapLevel(Owner.Owner);
    FStatus := FStatus - [moPlacedOnMap];
    InitHNWalk(Walk, FXhx, FYhx, 0);
    while Walk.HN < Count do
    begin
      if ((GetTerrain(Walk.HN) >= -1) or (GetOverlay(Walk.HN) >= -1)) and (Walk.X >= 0) and
        (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
        MapLevel.GetField(Walk.X, Walk.Y).RemoveHS(Self);
      WalkToNextHN(Walk);
    end;
    Owner := nil;
  end;
end;

function TMultiHexMO.PlaceOnMap: Boolean;
var
  Count: Integer;
  MapLevel: TMapLevel;
  Walk: THNWalkData;
begin
  if not (moPlacedOnMap in FStatus) then
  begin
    Connect;
    Count := GetTerrainCount;
    MapLevel := TMapLevel(Owner.Owner);
    if GetLevel <= 15 then
    begin
      InitHNWalk(Walk, FXhx, FYhx, 0);
      while Walk.HN < Count do
      begin
        if ((GetTerrain(Walk.HN) >= -1) or (GetOverlay(Walk.HN) >= -1)) and (Walk.X >= 0) and
          (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
          MapLevel.FMap.InvalidateStaticScene(Walk.X, Walk.Y, TMapField(Owner).FLhx);
        WalkToNextHN(Walk);
      end;
    end;
    if not GetEditMode then
      MapLevel.FMap.TerrainChangedRad(FXhx, FYhx, MapLevel.FLhx, HNtoRad(Count));
  end;
  Result := True;
end;

procedure TMultiHexMO.RemoveFromMap;
var
  Count: Integer;
  MapLevel: TMapLevel;
  MapField: TMapField;
  TerrainType, OverlayType: Shortint;
  Walk: THNWalkData;
begin
  if moPlacedOnMap in FStatus then
  begin
    MapLevel := TMapLevel(Owner.Owner);
    Disconnect;
    if not (msDestroying in MapLevel.FMap.FStatus) then
    begin
      Count := GetTerrainCount;
      InitHNWalk(Walk, FXhx, FYhx, 0);
      while Walk.HN < Count do
      begin
        TerrainType := GetTerrain(Walk.HN);
        OverlayType := GetOverlay(Walk.HN);
        if ((TerrainType >= -1) or (OverlayType >= -1)) and (Walk.X >= 0) and (Walk.Y >= 0) and
          (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
        begin
          MapField := MapLevel.GetField(Walk.X, Walk.Y);
          if (TerrainType >= 0) or (OverlayType >= 0) then
            MapField.UpdateTerrain;
          if GetLevel <= 15 then
            MapLevel.FMap.InvalidateStaticScene(Walk.X, Walk.Y, MapLevel.FLhx);
        end;
        WalkToNextHN(Walk);
      end;
      MapLevel.FMap.TerrainChangedRad(FXhx, FYhx, MapLevel.FLhx, HNtoRad(Count));
    end;
  end;
end;

procedure TMultiHexMO.UpdateTerrain(MapLevel: TMapLevel; Xhx, Yhx: Integer);
var
  Count: Integer;
  Walk: THNWalkData;
begin
  Count := FResource.FTerrainList.FCount;
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN <> Count do
  begin
    if ((GetTerrain(Walk.HN) >= 0) or (GetOverlay(Walk.HN) >= 0)) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      MapLevel.GetField(Walk.X, Walk.Y).UpdateTerrain;
    WalkToNextHN(Walk);
  end;
end;

procedure TMultiHexMO.UpdateMapFields(MapLevel: TMapLevel; Xhx, Yhx: Integer);
var
  Count: Integer;
  Walk: THNWalkData;
begin
  Count := FResource.FTerrainList.FCount;
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN <> Count do
  begin
    if ((GetTerrain(Walk.HN) >= 0) or (GetOverlay(Walk.HN) >= 0)) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      MapLevel.GetField(Walk.X, Walk.Y).UpdateMapField;
    WalkToNextHN(Walk);
  end;
end;

function TMultiHexMO.CanPlaceOnHS(HS: THexagonSprite): Boolean;
begin
  Result := HS.GetLevel < 10;
end;

function TMultiHexMO.CanPlace(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  Count: Integer;
  TerrainType, OverlayType: Shortint;
  HS: THexagonSprite;
  Walk: THNWalkData;
begin
  Result := True;
  Count := FResource.FTerrainList.FCount;
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Result and (Walk.HN < Count) do
  begin
    TerrainType := GetTerrain(Walk.HN);
    OverlayType := GetOverlay(Walk.HN);
    if ((TerrainType >= 0) or (OverlayType >= 0)) and (Walk.X >= 0) and (Walk.Y >= 0) and
      (Walk.X < MapContainer.FWidth) and (Walk.Y < MapContainer.FHeight) then
    begin
      HS := MapContainer.GetField(Walk.X, Walk.Y, Lhx).GetMaxLevelNoneTransparentHS;
      Result := (HS = nil) or CanPlaceOnHS(HS);
    end;
    WalkToNextHN(Walk);
  end;
  Result := Result and MapContainer.FMap.CanChangeTerrain(Self, Xhx, Yhx, Lhx,
    FResource.FTerrainList);
end;

function TMultiHexMO.CanSelect(Xhp, Yhp: Integer): Boolean;
var
  Xhx, Yhx: Integer;
  HN: Integer;
begin
  if msEditting in FResource.FEngine.FHSMap.FStatus then
  begin
    HPtoHX(Xhp, Yhp, Xhx, Yhx);
    HN := dHXtoHN(TMapField(Owner).FXhx, TMapField(Owner).FYhx, Xhx, Yhx);
    Result := (HN < FResource.FTerrainList.FCount) and
      ((FResource.FTerrainList.GetTerrain(HN) >= 0) or (FResource.FTerrainList.GetOverlay(HN) >= 0));
  end
  else
    Result := False;
end;

function TMultiHexMO.PlaceHX(MapContainer: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  FXhx := Xhx;
  FYhx := Yhx;
  Result := inherited PlaceHX(MapContainer, Xhx, Yhx, Lhx);
end;

{ The terrain type that most of the fields under the object have (the counts of Default win ties) }
function TMultiHexMO.GetMostFrequentMapFieldTerrainType(MapLevel: TMapLevel; Xhx, Yhx, Default: Shortint): Shortint;
var
  TerrainList: TTerrainList;
  TerrainType: Shortint;
  Counts: array[0..127] of Byte;
  Walk: THNWalkData;
begin
  Result := Default;
  TerrainList := FResource.FTerrainList;
  if Result < 0 then
    Result := 0;
  FillChar(Counts, SizeOf(Counts), 0);
  InitHNWalk(Walk, Xhx, Yhx, 0);
  while Walk.HN < TerrainList.FCount do
  begin
    if ((TerrainList.GetTerrain(Walk.HN) >= 0) or (GetOverlay(Walk.HN) >= 0)) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
    begin
      TerrainType := MapLevel.GetField(Walk.X, Walk.Y).FTerrainType;
      if TerrainType >= 0 then
      begin
        Inc(Counts[TerrainType]);
        if Counts[TerrainType] > Counts[Result] then
          Result := TerrainType;
      end;
    end;
    WalkToNextHN(Walk);
  end;
  if (Default >= 0) and (Counts[Result] = Counts[Default]) then
    Result := Default;
end;

procedure TMultiHexMO.OverrideTerrain;
var
  Count: Integer;
  MapLevel: TMapLevel;
  MapField: TMapField;
  Terrain: array[0..1] of Shortint;
  Walk: THNWalkData;
begin
  MapLevel := TMapLevel(Owner.Owner);
  Count := GetTerrainCount;
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and
      (Walk.Y < MapLevel.FHeight) then
    begin
      Terrain[0] := GetTerrain(Walk.HN);
      Terrain[1] := GetOverlay(Walk.HN);
      MapField := MapLevel.GetField(Walk.X, Walk.Y);
      if Terrain[0] >= 0 then
        MapField.FTerrainType := Terrain[0];
      if Terrain[1] >= 0 then
        MapField.FOverlayType := Terrain[1];
    end;
    WalkToNextHN(Walk);
  end;
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < Count do
  begin
    if ((GetTerrain(Walk.HN) >= 0) or (GetOverlay(Walk.HN) >= 0)) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      MapLevel.GetField(Walk.X, Walk.Y).TerrainChanged;
    WalkToNextHN(Walk);
  end;
end;

procedure TMultiHexMO.SortMapFields;
var
  MapLevel: TMapLevel;
  Walk: THNWalkData;
begin
  MapLevel := TMapLevel(Owner.Owner);
  InitHNWalk(Walk, FXhx, FYhx, 0);
  while Walk.HN < GetTerrainCount do
  begin
    if ((GetTerrain(Walk.HN) >= 0) or (GetOverlay(Walk.HN) >= 0)) and (Walk.X >= 0) and
      (Walk.Y >= 0) and (Walk.X < MapLevel.FWidth) and (Walk.Y < MapLevel.FHeight) then
      MapLevel.GetField(Walk.X, Walk.Y).Sort;
    WalkToNextHN(Walk);
  end;
end;

{ TMultiHexMOR }

constructor TMultiHexMOR.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  SetdXmainP(16);
  SetdYmainP(32);
end;

class function TMultiHexMOR.ClassID: Integer;
begin
  Result := $10155;
end;

procedure TMultiHexMOR.SetdXmainP(Value: Integer);
begin
  FdXmainP := Value;
  CalcShowPriorityOffset(FdXmainP, FdYmainP, FLevel);
end;

procedure TMultiHexMOR.SetdYmainP(Value: Integer);
begin
  FdYmainP := Value;
  CalcShowPriorityOffset(FdXmainP, FdYmainP, FLevel);
end;

procedure TMultiHexMOR.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FdXImage, 12);
  Stream.rwInteger(FdYImage, 13);
  Stream.rwInteger(FdXmainP, 14);
  Stream.rwInteger(FdYmainP, 15);
end;
