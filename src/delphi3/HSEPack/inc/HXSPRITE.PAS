{ HXSPRITE.PAS: THexagonSprite, THPBasedHS, TSingleHS, TFixedVisibleHS, TCustomFixedVisibleHS
  (include file of HSEngine.pas; the original Asserts name D:\GEngine\HSENGINE\inc\HXSPRITE.PAS) }

{ THexagonSprite }

destructor THexagonSprite.Destroy;
begin
  MainRemove;
  inherited Destroy;
end;

class function THexagonSprite.ClassID: Integer;
begin
  Result := $10150;
end;

function THexagonSprite.EditName: string;
begin
  Result := 'Hexagon Sprite';
end;

procedure THexagonSprite.UpdateMapField(const Info: THSMapFieldInfo);
begin
end;

procedure THexagonSprite.MapFieldMsgProc(var Msg: TMapFieldMsg);
begin
end;

procedure THexagonSprite.CanMoveOn(const Info: THSMoveOnInfo; var MoveResult: THSMoveOnResult);
begin
end;

function THexagonSprite.CanMoveOver(const Info: THSSenderInfo): Integer;
begin
  Result := 1;
end;

procedure THexagonSprite.MoveExclusive(const Info: THSSenderInfo);
begin
end;

procedure THexagonSprite.SetVisible(Value: Boolean);
begin
end;

function THexagonSprite.GetVisible: Boolean;
begin
  Result := False;
end;

function THexagonSprite.GetLevel: Byte;
begin
  raise Exception.Create('No HexagonSprite Level defined');
end;

function THexagonSprite.CanSelect(Xhp, Yhp: Integer): Boolean;
begin
  Result := (Owner <> nil) and
    (msEditting in THSMap(THSEngine(TMapLevel(TMapField(Owner).Owner).FEngine).FHSMap).FStatus);
end;

procedure THexagonSprite.Changed;
var
  MapF: TMapField;
begin
  MapF := TMapField(Owner);
  if MapF <> nil then
    TEventList(THSMap(THSEngine(TMapLevel(MapF.Owner).FEngine).FHSMap).FHSChangedEvents).TriggerNotifyEvents(Self);
end;

function THexagonSprite.GetSelected: Boolean;
begin
  Result := False;
end;

class function THexagonSprite.ControlMode: TControlMode;
begin
  Result := [];
end;

procedure THexagonSprite.GetBaseHX(var XYL: Integer);
begin
  XYL := TMapField(Owner).FXhx + TMapField(Owner).FYhx shl 8 + TMapLevel(TMapField(Owner).Owner).FLhx shl 16;
end;

function THexagonSprite.GetXhx: Shortint;
begin
  Result := Shortint(TMapField(Owner).FXhx);
end;

function THexagonSprite.GetYhx: Shortint;
begin
  Result := Shortint(TMapField(Owner).FYhx);
end;

function THexagonSprite.GetLhx: Shortint;
begin
  Result := TMapLevel(TMapField(Owner).Owner).FLhx;
end;

function THexagonSprite.GetXYL: Integer;
begin
  Result := GetXhx + GetYhx shl 8 + GetLhx shl 16;
end;

procedure THexagonSprite.Select;
begin
end;

procedure THexagonSprite.Unselect;
begin
  THexagonSpriteSelection(THSMap(TMapLevel(TMapField(Owner).Owner).FMap).FSelection).Unselect(Self);
end;

function THexagonSprite.GetTerrain(HN: Integer): Shortint;
begin
  Result := -2;
end;

procedure THexagonSprite.SetTerrain(HN: Integer; Value: Shortint);
begin
end;

function THexagonSprite.GetTerrainCount: Integer;
begin
  Result := 0;
end;

function THexagonSprite.GetOverlay(HN: Integer): Shortint;
begin
  Result := -2;
end;

procedure THexagonSprite.SetOverlay(HN: Integer; Value: Shortint);
begin
end;

function THexagonSprite.GetOverlayCount: Integer;
begin
  Result := 0;
end;

procedure THexagonSprite.MakeVisible(VisibilityList: TVisibilityList);
begin
  if not GetVisible then
  begin
    SetVisible(True);
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;

function THexagonSprite.GetEditMode: Boolean;
begin
  Result := False;
end;

procedure THexagonSprite.SetEditMode(Value: Boolean);
begin
end;

function THexagonSprite.GetShowPriority: Integer;
begin
  Result := $7F000000;
end;

function THexagonSprite.CanChangeTerrain(const Info: THSSenderInfo): Boolean;
begin
  Result := True;
end;

procedure THexagonSprite.ChangeTerrain(const Info: THSTerrainInfo);
begin
end;

procedure THexagonSprite.TerrainChanged(const Info: THSTerrainInfo);
begin
end;

procedure THexagonSprite.NeighbourTerrainChanged(HN: Integer; const Info: THSTerrainInfo);
begin
end;

function THexagonSprite.Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin
  Result := PlaceOnMap;
end;

procedure THexagonSprite.Connect;
begin
end;

procedure THexagonSprite.Disconnect;
begin
end;

function THexagonSprite.PlaceOnMap: Boolean;
begin
  Connect;
  Result := True;
end;

procedure THexagonSprite.RemoveFromMap;
begin
  Disconnect;
end;

procedure THexagonSprite.Remove;
begin
  RemoveFromMap;
end;

function THexagonSprite.Loaded: Boolean;
begin
  Connect;
  Result := True;
end;

function THexagonSprite.PlaceOnMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer): Boolean;
var
  X, Y, Xmin, YminOdd, YminEven, Xmax, YmaxOdd, YmaxEven: Integer;
  MapL: TMapLevel;
begin
  HPtoHX(Xhp - 8, Yhp, Xmin, YminOdd);
  HPtoHX(Xhp - 8 + 32, Yhp, X, Y);
  if not Odd(Xmin) then
  begin
    YminEven := YminOdd;
    YminOdd := Y;
  end
  else
    YminEven := Y;
  Y := Yhp + Height - 1;
  HPtoHX(Width + Xhp + 8 - 1, Y, Xmax, YmaxOdd);
  HPtoHX(Width + Xhp + 8 - 1 + 32, Y, X, Y);
  if not Odd(Xmax) then
  begin
    YmaxEven := YmaxOdd;
    YmaxOdd := Y;
  end
  else
    YmaxEven := Y;
  if (Xmax >= 0) and (Map.Width > Xmin) and ((YmaxEven >= 0) or (YmaxOdd >= 0)) and
    ((Map.Height > YminEven) or (Map.Height > YminOdd)) then
  begin
    if Xmin < 0 then
      Xmin := 0;
    if Xmax >= Map.Width then
      Xmax := Map.Width - 1;
    if YminEven < 0 then
    begin
      YminEven := 0;
      if YmaxEven < 0 then
        YmaxEven := 0;
    end;
    if YmaxEven >= Map.Height then
    begin
      YmaxEven := Map.Height - 1;
      if YminEven >= Map.Height then
        YminEven := Map.Height - 1;
    end;
    if YminOdd < 0 then
    begin
      YminOdd := 0;
      if YmaxOdd < 0 then
        YmaxOdd := 0;
    end;
    if YmaxOdd >= Map.Height then
    begin
      YmaxOdd := Map.Height - 1;
      if YminOdd >= Map.Height then
        YminOdd := Map.Height - 1;
    end;
    MapL := Map.GetMapLevel(Lhx);
    X := (Xmin + Xmax) shr 1;
    if not Odd(X) then
      Y := (YminEven + YmaxEven) shr 1
    else
      Y := (YminOdd + YmaxOdd) shr 1;
    FOwner := MapL.GetField(X, Y);
    for X := Xmin to Xmax do
      if not Odd(X) then
        for Y := YminEven to YmaxEven do
          MapL.GetField(X, Y).AddHS(Self, 1)
      else
        for Y := YminOdd to YmaxOdd do
          MapL.GetField(X, Y).AddHS(Self, 1);
    TMapField(FOwner).SetHNofHS(Self, 0);
    Result := True;
  end
  else
    Result := False;
end;

procedure THexagonSprite.RemoveFromMapEx(Xhp, Yhp, Width, Height: Integer);
var
  X, Y, Xmin, YminOdd, YminEven, Xmax, YmaxOdd, YmaxEven: Integer;
  MapL: TMapLevel;
begin
  MapL := TMapLevel(FOwner.Owner);
  HPtoHX(Xhp - 8, Yhp, Xmin, YminOdd);
  HPtoHX(Xhp - 8 + 32, Yhp, X, Y);
  if not Odd(Xmin) then
  begin
    YminEven := YminOdd;
    YminOdd := Y;
  end
  else
    YminEven := Y;
  Y := Yhp + Height - 1;
  HPtoHX(Width + Xhp + 8 - 1, Y, Xmax, YmaxOdd);
  HPtoHX(Width + Xhp + 8 - 1 + 32, Y, X, Y);
  if not Odd(Xmax) then
  begin
    YmaxEven := YmaxOdd;
    YmaxOdd := Y;
  end
  else
    YmaxEven := Y;
  if (Xmax >= 0) and (Xmin < MapL.Width) and ((YmaxEven >= 0) or (YmaxOdd >= 0)) and
    ((MapL.Height > YminEven) or (MapL.Height > YminOdd)) then
  begin
    if Xmin < 0 then
      Xmin := 0;
    if Xmax >= MapL.Width then
      Xmax := MapL.Width - 1;
    if YminEven < 0 then
    begin
      YminEven := 0;
      if YmaxEven < 0 then
        YmaxEven := 0;
    end;
    if YmaxEven >= MapL.Height then
    begin
      YmaxEven := MapL.Height - 1;
      if YminEven >= MapL.Height then
        YminEven := MapL.Height - 1;
    end;
    if YminOdd < 0 then
    begin
      YminOdd := 0;
      if YmaxOdd < 0 then
        YmaxOdd := 0;
    end;
    if YmaxOdd >= MapL.Height then
    begin
      YmaxOdd := MapL.Height - 1;
      if YminOdd >= MapL.Height then
        YminOdd := MapL.Height - 1;
    end;
    for X := Xmin to Xmax do
      if not Odd(X) then
        for Y := YminEven to YmaxEven do
          MapL.GetField(X, Y).RemoveHS(Self)
      else
        for Y := YminOdd to YmaxOdd do
          MapL.GetField(X, Y).RemoveHS(Self);
  end;
  FOwner := nil;
end;

function THexagonSprite.PlaceUserOnMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer): Boolean;
var
  X, Y, Xmin, YminOdd, YminEven, Xmax, YmaxOdd, YmaxEven: Integer;
  MapL: TMapLevel;
begin
  HPtoHX(Xhp - 8, Yhp, Xmin, YminOdd);
  HPtoHX(Xhp - 8 + 32, Yhp, X, Y);
  if not Odd(Xmin) then
  begin
    YminEven := YminOdd;
    YminOdd := Y;
  end
  else
    YminEven := Y;
  Y := Yhp + Height - 1;
  HPtoHX(Width + Xhp + 8 - 1, Y, Xmax, YmaxOdd);
  HPtoHX(Width + Xhp + 8 - 1 + 32, Y, X, Y);
  if not Odd(Xmax) then
  begin
    YmaxEven := YmaxOdd;
    YmaxOdd := Y;
  end
  else
    YmaxEven := Y;
  if (Xmax >= 0) and (Map.Width > Xmin) and ((YmaxEven >= 0) or (YmaxOdd >= 0)) and
    ((Map.Height > YminEven) or (Map.Height > YminOdd)) then
  begin
    if Xmin < 0 then
      Xmin := 0;
    if Xmax >= Map.Width then
      Xmax := Map.Width - 1;
    if YminEven < 0 then
    begin
      YminEven := 0;
      if YmaxEven < 0 then
        YmaxEven := 0;
    end;
    if YmaxEven >= Map.Height then
    begin
      YmaxEven := Map.Height - 1;
      if YminEven >= Map.Height then
        YminEven := Map.Height - 1;
    end;
    if YminOdd < 0 then
    begin
      YminOdd := 0;
      if YmaxOdd < 0 then
        YmaxOdd := 0;
    end;
    if YmaxOdd >= Map.Height then
    begin
      YmaxOdd := Map.Height - 1;
      if YminOdd >= Map.Height then
        YminOdd := Map.Height - 1;
    end;
    MapL := Map.GetMapLevel(Lhx);
    for X := Xmin to Xmax do
      if not Odd(X) then
        for Y := YminEven to YmaxEven do
          MapL.GetField(X, Y).AddHS(Self, 1)
      else
        for Y := YminOdd to YmaxOdd do
          MapL.GetField(X, Y).AddHS(Self, 1);
    Result := True;
  end
  else
    Result := False;
end;

procedure THexagonSprite.RemoveUserFromMapEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer);
var
  X, Y, Xmin, YminOdd, YminEven, Xmax, YmaxOdd, YmaxEven: Integer;
  MapL: TMapLevel;
begin
  MapL := Map.GetMapLevel(Lhx);
  HPtoHX(Xhp - 8, Yhp, Xmin, YminOdd);
  HPtoHX(Xhp - 8 + 32, Yhp, X, Y);
  if not Odd(Xmin) then
  begin
    YminEven := YminOdd;
    YminOdd := Y;
  end
  else
    YminEven := Y;
  Y := Yhp + Height - 1;
  HPtoHX(Width + Xhp + 8 - 1, Y, Xmax, YmaxOdd);
  HPtoHX(Width + Xhp + 8 - 1 + 32, Y, X, Y);
  if not Odd(Xmax) then
  begin
    YmaxEven := YmaxOdd;
    YmaxOdd := Y;
  end
  else
    YmaxEven := Y;
  if (Xmax >= 0) and (Xmin < MapL.Width) and ((YmaxEven >= 0) or (YmaxOdd >= 0)) and
    ((MapL.Height > YminEven) or (MapL.Height > YminOdd)) then
  begin
    if Xmin < 0 then
      Xmin := 0;
    if Xmax >= MapL.Width then
      Xmax := MapL.Width - 1;
    if YminEven < 0 then
    begin
      YminEven := 0;
      if YmaxEven < 0 then
        YmaxEven := 0;
    end;
    if YmaxEven >= MapL.Height then
    begin
      YmaxEven := MapL.Height - 1;
      if YminEven >= MapL.Height then
        YminEven := MapL.Height - 1;
    end;
    if YminOdd < 0 then
    begin
      YminOdd := 0;
      if YmaxOdd < 0 then
        YmaxOdd := 0;
    end;
    if YmaxOdd >= MapL.Height then
    begin
      YmaxOdd := MapL.Height - 1;
      if YminOdd >= MapL.Height then
        YminOdd := MapL.Height - 1;
    end;
    for X := Xmin to Xmax do
      if not Odd(X) then
        for Y := YminEven to YmaxEven do
          MapL.GetField(X, Y).RemoveHS(Self)
      else
        for Y := YminOdd to YmaxOdd do
          MapL.GetField(X, Y).RemoveHS(Self);
  end;
end;

procedure THexagonSprite.SortMapFieldEx(Map: TMapContainer; Xhp, Yhp, Lhx, Width, Height: Integer);
var
  X, Y, Xmin, YminOdd, YminEven, Xmax, YmaxOdd, YmaxEven: Integer;
  MapL: TMapLevel;
begin
  MapL := Map.GetMapLevel(Lhx);
  HPtoHX(Xhp - 8, Yhp, Xmin, YminOdd);
  HPtoHX(Xhp - 8 + 32, Yhp, X, Y);
  if not Odd(Xmin) then
  begin
    YminEven := YminOdd;
    YminOdd := Y;
  end
  else
    YminEven := Y;
  Y := Yhp + Height - 1;
  HPtoHX(Width + Xhp + 8 - 1, Y, Xmax, YmaxOdd);
  HPtoHX(Width + Xhp + 8 - 1 + 32, Y, X, Y);
  if not Odd(Xmax) then
  begin
    YmaxEven := YmaxOdd;
    YmaxOdd := Y;
  end
  else
    YmaxEven := Y;
  if (Xmax >= 0) and (Xmin < MapL.Width) and ((YmaxEven >= 0) or (YmaxOdd >= 0)) and
    ((MapL.Height > YminEven) or (MapL.Height > YminOdd)) then
  begin
    if Xmin < 0 then
      Xmin := 0;
    if Xmax >= MapL.Width then
      Xmax := MapL.Width - 1;
    if YminEven < 0 then
    begin
      YminEven := 0;
      if YmaxEven < 0 then
        YmaxEven := 0;
    end;
    if YmaxEven >= MapL.Height then
    begin
      YmaxEven := MapL.Height - 1;
      if YminEven >= MapL.Height then
        YminEven := MapL.Height - 1;
    end;
    if YminOdd < 0 then
    begin
      YminOdd := 0;
      if YmaxOdd < 0 then
        YmaxOdd := 0;
    end;
    if YmaxOdd >= MapL.Height then
    begin
      YmaxOdd := MapL.Height - 1;
      if YminOdd >= MapL.Height then
        YminOdd := MapL.Height - 1;
    end;
    for X := Xmin to Xmax do
      if not Odd(X) then
        for Y := YminEven to YmaxEven do
          MapL.GetField(X, Y).Sort
      else
        for Y := YminOdd to YmaxOdd do
          MapL.GetField(X, Y).Sort;
  end;
end;

procedure THexagonSprite.Activate;
begin
end;

procedure THexagonSprite.Deactivate;
begin
  if GetSelected then
    Unselect;
end;

function THexagonSprite.MainPlace(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin
  Result := Place(Map, Xhp, Yhp, Lhx);
  if Result then
  try
    Activate;
  except
    Result := False;
    Deactivate;
  end;
end;

procedure THexagonSprite.MainRemove;
begin
  Deactivate;
  Remove;
  Assert(not GetVisible, 'Hexagon Sprite Still Visible!');
end;

function THexagonSprite.MainLoaded: Boolean;
begin
  Result := Loaded;
end;

{ THPBasedHS }

constructor THPBasedHS.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FXhp := Integer($80000000);
  FYhp := Integer($80000000);
  FLhx := -1;
end;

class function THPBasedHS.ClassID: Integer;
begin
  Result := $10152;
end;

procedure THPBasedHS.SetVisible(Value: Boolean);
begin
  FVisible := Value;
end;

function THPBasedHS.GetVisible: Boolean;
begin
  Result := FVisible;
end;

procedure THPBasedHS.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FXhp, 4);
  Stream.rwInteger(FYhp, 5);
  Stream.rwByte(Byte(FLhx), 6);
end;

function THPBasedHS.Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin
  FXhp := Xhp;
  FYhp := Yhp;
  FLhx := Lhx;
  Result := True;
end;

{ TSingleHS }

procedure TSingleHS.SetVisible(Value: Boolean);
begin
  if Value then FStatus := FStatus or 1
  else FStatus := FStatus and $FE;
end;

function TSingleHS.GetVisible: Boolean;
begin
  Result := FStatus and 1 <> 0;
end;

procedure TSingleHS.MakeVisible(VisibilityList: TVisibilityList);
begin
  if FStatus and 1 = 0 then
  begin
    FStatus := FStatus or 1;
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;

function TSingleHS.GetEditMode: Boolean;
begin
  Result := FStatus and 2 <> 0;
end;

procedure TSingleHS.SetEditMode(Value: Boolean);
begin
  if Value then FStatus := FStatus or 2
  else FStatus := FStatus and $FD;
end;

procedure TSingleHS.Select;
begin
  inherited Select;
  FStatus := FStatus or 4;
end;

procedure TSingleHS.Unselect;
begin
  inherited Unselect;
  FStatus := FStatus and $FB;
end;

function TSingleHS.GetSelected: Boolean;
begin
  Result := FStatus and 4 <> 0;
end;

procedure TSingleHS.Activate;
begin
  FStatus := FStatus or 8;
end;

procedure TSingleHS.Deactivate;
begin
  inherited Deactivate;
  FStatus := FStatus and $F7;
end;

function TSingleHS.Activated: Boolean;
begin
  Result := FStatus and 8 <> 0;
end;

procedure TSingleHS.Connect;
begin
end;

procedure TSingleHS.Disconnect;
begin
  SetOwner(nil);
end;

function TSingleHS.GetShowPriority: Integer;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(Shortint(TMapField(Owner).FXhx), Shortint(TMapField(Owner).FYhx), Xhp, Yhp);
  Result := GetLevel shl 26 + (Yhp + 32) shl 13 + (Xhp + 16);
end;

procedure TSingleHS.Remove;
var
  MapF: TMapField;
begin
  if Owner <> nil then
  begin
    MapF := TMapField(Owner);
    RemoveFromMap;
    if GetVisible then
    begin
      if GetLevel <= 15 then
      begin
        TVisibilityList(THSMap(TMapContainer(TMapLevel(MapF.Owner).FMapContainer).FMap).FStaticVisibleHS).RemoveChild(Self);
        THSMap(TMapContainer(TMapLevel(MapF.Owner).FMapContainer).FMap).FStaticSceneInvalid := True;
      end
      else
        TVisibilityList(THSMap(TMapContainer(TMapLevel(MapF.Owner).FMapContainer).FMap).FDynamicVisibleHS).RemoveChild(Self);
    end;
    SetVisible(False);
  end;
end;

function TSingleHS.CanPlace(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  Result := (Xhx >= 0) and (Yhx >= 0) and (Lhx >= 0) and (Xhx < Map.FWidth) and
    (Yhx < Map.FHeight) and (Lhx < Map.FLevelCount);
end;

function TSingleHS.Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  Xhx, Yhx: Integer;
begin
  HPtoHX(Xhp, Yhp, Xhx, Yhx);
  Result := PlaceHX(Map, Xhx, Yhx, Lhx);
end;

function TSingleHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin
  if GetEditMode or CanPlace(Map, Xhx, Yhx, Lhx) then
  begin
    Remove;
    SetOwner(TECustomNode(Map.GetField(Xhx, Yhx, Lhx)));
    Result := PlaceOnMap;
  end
  else Result := False;
end;

{ TFixedVisibleHS }

procedure TFixedVisibleHS.SetVisible(Value: Boolean);
begin
  if Value then FStatus := FStatus or 1
  else FStatus := FStatus and $FE;
end;
function TFixedVisibleHS.GetVisible: Boolean;
begin
  Result := FStatus and 1 <> 0;
end;
procedure TFixedVisibleHS.MakeVisible(VisibilityList: TVisibilityList);
begin
  if FStatus and 1 = 0 then
  begin
    FStatus := FStatus or 1;
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;
function TFixedVisibleHS.GetShowPriority: Integer;
begin
  Result := GetLevel shl 26;
end;
procedure TFixedVisibleHS.MainRemove;
begin
  Deactivate;
  Remove;
  Assert(not GetVisible, 'FixedVisibleHS still in VisibilityList!!!');
end;

{ TCustomFixedVisibleHS }

function TCustomFixedVisibleHS.GetShowPriority: Integer;
begin
  Result := FShowPriority;
end;

procedure TCustomFixedVisibleHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  if Assigned(FOnShow) then
    FOnShow(XhpSurf, YhpSurf, SurfaceDesc);
end;

