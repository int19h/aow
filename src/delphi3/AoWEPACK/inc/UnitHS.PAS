constructor TUnitGFXResource.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FSequences := TImageSequenceList.Create(nil, nil);
  FRefCount := 0;
  FSFXLibraries[0] := TSFXLibrary.Create(nil);
  FSFXLibraries[1] := TSFXLibrary.Create(nil);
  FSFXLibraries[2] := TSFXLibrary.Create(nil);
  FSFXLibraries[3] := TSFXLibrary.Create(nil);
  FSFXLibraries[4] := TSFXLibrary.Create(nil);
end;
destructor TUnitGFXResource.Destroy;
begin
  if FRefCount <> 0 then ReleaseIL;
  FSequences.Free;
  FSFXLibraries[0].Free;
  FSFXLibraries[1].Free;
  FSFXLibraries[2].Free;
  FSFXLibraries[3].Free;
  FSFXLibraries[4].Free;
  inherited Destroy;
end;
class function TUnitGFXResource.ClassID: Integer;
begin
  Result := $20210;
end;
function TUnitGFXResource.GetEngine: Engine.TEngine;
begin
  Result := AoWEngine;
end;
procedure TUnitGFXResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $20000008 then
    FSequences.FILManager := THSEngine(Msg.Engine).HSSet.ImageLibraryManager;
end;
procedure TUnitGFXResource.LinkToIL;
begin
  FSequences.LinkToIL;
  if FFaceImageLibraryName <> '' then
  begin
    FFaceImageLibrary := FSequences.ILManager.LinkToIL([icDisk], FFaceImageLibraryName);
    Exit;
  end;
  FFaceImageLibrary := nil;
end;
procedure TUnitGFXResource.ReleaseIL;
begin
  FSequences.ReleaseIL;
  if FFaceImageLibrary <> nil then
  begin
    if FFaceImageLibraryName <> '' then
      FSequences.ILManager.ReleaseIL([icDisk], FFaceImageLibraryName);
    FFaceImageLibrary := nil;
  end;
end;
procedure TUnitGFXResource.SetFaceImageLibraryName(Value: string);
begin
  if FFaceImageLibraryName <> '' then
    FSequences.ILManager.ReleaseIL([icDisk], FFaceImageLibraryName);
  FFaceImageLibraryName := Value;
  { Original releases the old library even when no reference is held. }
  if (FFaceImageLibraryName <> '') and (FRefCount <> 0) then
    FFaceImageLibrary := FSequences.ILManager.LinkToIL([icDisk], FFaceImageLibraryName);
end;
function TUnitGFXResource.AddRef: Integer;
begin
  if FRefCount = 0 then LinkToIL;
  Inc(FRefCount);
  Result := FRefCount;
end;
function TUnitGFXResource.Release: Integer;
begin
  Dec(FRefCount);
  if (FRefCount = 0) and not (ssEditting in AoWHSSet.Status) and
     ((AoWHSMap = nil) or not (msEditting in AoWHSMap.Status)) then
    ReleaseIL;
  Result := FRefCount;
end;
function TUnitGFXResource.GetFaceImage: TLibraryImage;
begin
  AddRef;
  if FFaceImageLibrary <> nil then
    Result := FFaceImageLibrary.GetSafe(FFaceIndex)
  else Result := nil;
  Release;
end;
function TUnitGFXResource.GetCellImage: ImageLib.TLibraryImage;
begin
  AddRef;
  if FSequences.GetImageSequence(2) <> nil then
    Result := FSequences.GetImageSequence(2).GetPreviewImage
  else Result := nil;
  if Result = nil then Result := FSequences.GetPreviewImage;
  Release;
end;
procedure TUnitGFXResource.Show(Direction,X,Y: Integer; const SD: TSurfaceDesc);
var
  Sequence: TImageSequence;
  Index: Integer;
begin
  AddRef;
  Sequence := FSequences.List^[Direction - 1];
  while Sequence <> nil do
  begin
    Index := Sequence.GetFrameIndex(1, 0);
    if Index <> -1 then Sequence.ImageLibrary[Index].Show(X, Y, SD);
    Sequence := Sequence.Next;
  end;
  Release;
end;
function TUnitGFXResource.GetIndex: Integer;
begin
  Result := EditIndex;
end;
procedure TUnitGFXResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwStreamProc(5, FSequences.LoadFromStream, FSequences.SaveToStream);
  if not (smText in Stream.StorageMode) then
  begin
    Stream.rwString(FFaceImageLibraryName, 6);
    Stream.rwString(FName, 7);
  end;
  Stream.rwInteger(FFaceIndex, 8);
  Stream.rwData(F_UnitGFXResource_30, 1, 10);
  Stream.rwEObject(FSFXLibraries[0], 15);
  Stream.rwEObject(FSFXLibraries[1], 16);
  Stream.rwEObject(FSFXLibraries[2], 17);
  Stream.rwEObject(FSFXLibraries[3], 18);
  Stream.rwEObject(FSFXLibraries[4], 19);
end;
constructor TUnitGFXResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csKeepIndex]);
end;
function TUnitGFXResourceList.GetUnitGFXResource(Index: Integer): TUnitGFXResource;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := FChildren.List^[Index]
  else Result := nil;
end;
procedure TUnitGFXResourceList.CreateUnitGFXSelectionList(List: TStrings);
var
  I: Integer;
begin
  List.Clear;
  for I := 0 to Count - 1 do
    if FChildren.List^[I] <> nil then
      List.AddObject(TUnitGFXResource(Children[I]).FName, TObject(I));
end;
function TUnitShadowHS.GetShowPriority: Integer;
begin
  Result := (FUnitHS.GetShowPriority and $03FFFFFF) + $64000000;
end;
procedure TUnitShadowHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin
  FUnitHS.ShowShadow(XhpSurf, YhpSurf, SurfaceDesc);
end;
constructor TUnitHS.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FMoveStep := -1;
  FDirection := 3;
  FShowPriority := $68000000;
end;
destructor TUnitHS.Destroy;
begin
  DestroyShadow;
  SetUnitGFXResourceIndex(-1);
  inherited Destroy;
end;
class function TUnitHS.ClassID: Integer;
begin Result := $20214; end;
procedure TUnitHS.CreateShadow;
begin
  if FShadow <> nil then DestroyShadow;
  if AoWHSMap.FShowUnitShadows then
  begin
    FShadow := TUnitShadowHS.Create(nil);
    FShadow.FUnitHS := Self;
  end;
end;
procedure TUnitHS.DestroyShadow;
begin
  if FShadow <> nil then
  begin
    if GetVisible then
      TMapLevel(Owner.Owner).Map.DynamicVisibleHS.RemoveChild(FShadow);
    FShadow.Free;
    FShadow := nil;
  end;
end;
procedure TUnitHS.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
var
  Shadow: TUnitShadowHS;
begin
  if (FStatus and 1) = 0 then
  begin
    FStatus := FStatus or 1;
    VisibilityList.AddSortChild(Self, FShowPriority);
    Shadow := FShadow;
    if Shadow <> nil then
      VisibilityList.AddSortChild(Shadow, Shadow.GetShowPriority);
  end;
end;
procedure TUnitHS.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDirection, 9);
  if not (smSetupCompare in Stream.StorageMode) and (FDirection = 0) then FDirection := 3;
end;
procedure TUnitHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin
  inherited TerrainChanged(Info);
  CalcShowPriority;
end;
procedure TUnitHS.SetOwner(AOwner: Engine.TECustomNode);
begin
  if AOwner <> FOwner then
  begin
    if FOwner <> nil then FOwner.RemoveChild(Self);
    FOwner := AOwner;
    if FOwner <> nil then FOwner.AddChild(Self);
  end;
end;
function TUnitHS.GetXhx: Shortint;
begin Result := TMapField(Owner).Xhx; end;
function TUnitHS.GetYhx: Shortint;
begin Result := TMapField(Owner).Yhx; end;
function TUnitHS.GetLhx: Shortint;
begin



































































































































































































































































































































  Assert(Owner <> nil, 'Onwer isn''t defined');
  Result := TMapField(Owner).Lhx;
end;
procedure TUnitHS.Select;
begin FStatus := FStatus or 4; end;
procedure TUnitHS.Unselect;
begin
  FStatus := FStatus and $FB;
  inherited Unselect;
end;
function TUnitHS.GetSelected: Boolean;
begin Result := (FStatus and 4) <> 0; end;
procedure TUnitHS.SetVisible(Value: Boolean);
begin
  if Value then FStatus := FStatus or 1
  else FStatus := FStatus and $FE;
end;
function TUnitHS.GetVisible: Boolean;
begin Result := (FStatus and 1) <> 0; end;
function TUnitHS.GetEditMode: Boolean;
begin Result := (FStatus and 2) <> 0; end;
procedure TUnitHS.SetEditMode(Value: Boolean);
begin
  if Value then FStatus := FStatus or 2
  else FStatus := FStatus and $FD;
end;

function TUnitHS.GetUnitGFXResourceIndex: Integer;
var
  Resource: TUnitGFXResource;
begin
  Resource := FUnitGFXResource;
  if FUnitGFXResource <> nil then begin Result := FUnitGFXResource.GetIndex; Exit; end;
  Result := -1;
end;


procedure TUnitHS.SetUnitGFXResourceIndex(Value: Integer);
var
  Resource, Old: TUnitGFXResource;
begin Self := Self; { This eliminated copy preserves the original saved registers. }
  Resource := FUnitGFXResource;
  if (Resource = nil) or (Value <> Resource.GetIndex) then
  begin
    Old := FUnitGFXResource;
    if Old <> nil then Old.Release;
    Resource := AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Value);
    FUnitGFXResource := Resource;
    if Resource <> nil then Resource.AddRef;
  end;
end;


procedure TUnitHS.TimerEvent(Tick: Integer; Sender: Engine.TEObject);
begin end;

function TUnitHS.CanSelect(Xhp, Yhp: Integer): Boolean;
var
  X, Y: Integer;
begin
  if not Moving then
  begin
    HPtoHX(Xhp, Yhp, X, Y);
    if (TMapField(Owner).Xhx <> X) or (TMapField(Owner).Yhx <> Y) then Result := False
    else Result := True;
  end
  else Result := False;
end;


procedure TUnitHS.CalcShowPriority;
var
  Field: TMapField;
  HS: THexagonSprite;
  X, Y: Integer;
begin
  Field := TMapField(Owner);
  if Moving and (FDirection in [3..5]) then
  begin
    CenterHNtoHX(TMapField(Owner).Xhx, TMapField(Owner).Yhx, FDirection, X, Y);
    Field := TMapLevel(Owner.Owner).GetField(X, Y);
    HXtoHP(X, Y, X, Y);
  end
  else HXtoHP(Field.Xhx, Field.Yhx, X, Y);
  HS := Field.GetMaxLevelNoneTransparentHS;
  FShowPriority := $68000000 + ((Y + 34 + 6) shl 13) + (X + 16);
  if (HS <> Self) and (HS <> nil) and (HS.GetShowPriority >= FShowPriority) then
    FShowPriority := HS.GetShowPriority + 2;
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, X, Y);
  SortMapFieldEx(TMapLevel(Owner.Owner).Map.MapContainer, X - 18, Y - 32,
    TMapField(Owner).Lhx, 64, 64);
end;


function TUnitHS.GetShowPriority: Integer;
begin Result := FShowPriority; end;


function TUnitHS.GetLevel: Byte;
begin Result := 26; end;


procedure TUnitHS.UpdateFlagID;
begin FFlagID := 32; end;


procedure TUnitHS.Activate;
begin
  inherited Activate;
  CreateShadow;
  UpdateFlagID;
end;


procedure TUnitHS.Deactivate;
begin
  DestroyShadow;
  inherited Deactivate;
end;


function TUnitHS.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin
  if Info.HN = 0 then begin Result := 0; Exit; end;
  Result := 1;
end;


procedure TUnitHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin
  if Info.HN <= 7 then TAoWMapField(Info.MapField).FFieldFlags :=
    TAoWMapField(Info.MapField).FFieldFlags or $2000;
end;


procedure TUnitHS.Connect;
var
  Field: TMapField;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  CalcShowPriority;
  Field := TMapField(Owner);
  Field.RemoveChild(Self);
  Level := TMapLevel(Field.Owner);
  InitHNWalk(Walk, Field.Xhx, Field.Yhx, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.X < Level.Width) and
       (Walk.Y >= 0) and (Walk.Y < Level.Height) then
    begin
      Level.GetField(Walk.X, Walk.Y).AddHS(Self, Walk.HN);
      Level.GetField(Walk.X, Walk.Y).UpdateMapField;
    end;
    WalkToNextHN(Walk);
  end;
end;


procedure TUnitHS.Disconnect; { Near miss: owner pointer register allocation after three variants. }
var
  Field: TMapField;
  Level: TMapLevel;
  Walk: THNWalkData;
begin
  if Owner <> nil then
  begin
    Field := TMapField(Owner);
    Level := TMapLevel(Field.Owner);
    InitHNWalk(Walk, Field.Xhx, Field.Yhx, 0);
    while Walk.Radius <= 1 do
    begin
      if (Walk.X >= 0) and (Walk.X < Level.Width) and
         (Walk.Y >= 0) and (Walk.Y < Level.Height) then
      begin
        Level.GetField(Walk.X, Walk.Y).RemoveHS(Self);
        Level.GetField(Walk.X, Walk.Y).UpdateMapField;
      end;
      WalkToNextHN(Walk);
    end;
    SetOwner(nil);
  end;
end;


function TUnitHS.PlaceOnMap: Boolean;
begin
  Connect;
  TAbstractAoWHSMap(TMapLevel(Owner.Owner).Map).ScannerIconsChangedRad(
    TMapField(Owner).Xhx, TMapField(Owner).Yhx, TMapField(Owner).Lhx, 0);
  Result := True;
end;


procedure TUnitHS.RemoveFromMap;
var
  Field: TMapField;
begin
  if Owner <> nil then
  begin
    Field := TMapField(Owner);
    if Moving then CancelMove;
    Disconnect;
    Field.UpdateMapField;
    TAbstractAoWHSMap(TMapLevel(Field.Owner).Map).ScannerIconsChangedRad(Field.Xhx, Field.Yhx, Field.Lhx, 0);
  end;
end;


function TUnitHS.MoveTo(Field: TMapField; MoveCost: Integer): Boolean;
begin
  if Owner <> nil then RemoveFromMap;
  FOwner := Field;
  CalcShowPriority;
  PlaceOnMap;
  Field.RemoveChild(Self);
  FOwner := nil;
  SetOwner(Field);
  Result := True;
end;


procedure TUnitHS.Remove;
var
  Field: TMapField;
begin
  Field := TMapField(Owner);
  RemoveFromMap;
  if GetVisible then
  begin
    TMapLevel(Field.Owner).Map.DynamicVisibleHS.RemoveChild(Self);
    SetVisible(False);
  end;
end;


function TUnitHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean; { Near miss: Self/field/result allocation differs after three variants. }
var
  Field: TMapField;
  Success: Boolean;
begin
  Field := Map.GetField(Xhx, Yhx, Lhx);
  FOwner := Field;
  CalcShowPriority;
  Success := PlaceOnMap;
  Field.RemoveChild(Self);
  FOwner := nil;
  SetOwner(Field);
  Result := Success;
end;


function TUnitHS.Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
var
  X, Y: Integer;
begin
  HPtoHX(Xhp, Yhp, X, Y);
  Result := PlaceHX(Map, X, Y, Lhx);
end;


procedure TUnitHS.ShowShadow(X, Y: Integer; const SurfaceDesc: TSurfaceDesc);
var
  Sequence: TImageSequence;
  Index: Integer;
  Progress: Single;
  Xhp, Yhp, DX, DY: Integer;
begin
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  X := Xhp - X;
  Y := Yhp - Y;
  if FMoveStep <> -1 then
  begin
    HNtoHP(FDirection, DX, DY);
    Progress := FMoveStep / GetMoveSteps;
    Inc(X, Round(DX * Progress));
    Inc(Y, Round(DY * Progress));
  end;
  if FDirection = 0 then Sequence := FUnitGFXResource.FSequences.GetImageSequence(27)
  else Sequence := FUnitGFXResource.FSequences.GetImageSequence(FDirection + 23);
  while Sequence <> nil do
  begin
    Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
    Sequence.ImageLibrary[Index].Show(X + Sequence.dXshift, Y + Sequence.dYshift, SurfaceDesc);
    Sequence := Sequence.Next;
  end;
end;


procedure TUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
var
  Sequence: TImageSequence;
  Index: Integer;
  Xhp, Yhp, DX, DY: Integer;
  Progress: Single;
begin
  Assert(FDirection < FUnitGFXResource.FSequences.Count, 'Invalid Unit Index');
  HXtoHP(TMapField(Owner).Xhx, TMapField(Owner).Yhx, Xhp, Yhp);
  XhpSurf := Xhp - XhpSurf;
  YhpSurf := Yhp - YhpSurf;
  if FMoveStep <> -1 then
  begin
    HNtoHP(FDirection, DX, DY);
    if FStatus and $10 = 0 then
    begin
      Progress := FMoveStep / GetMoveSteps;
      Inc(XhpSurf, Round(DX * Progress));
      Inc(YhpSurf, Round(DY * Progress));
    end;
    if FStatus and 8 = 0 then
    begin
      Sequence := FUnitGFXResource.FSequences.List^[FDirection + 5];
      if (Sequence <> nil) and GetSelected then
      begin
        Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
        if Sequence.SpeedCount = Sequence.SequenceSpeed then { $30 sound timing gate }
          FUnitGFXResource.FSFXLibraries[1].Play(Index mod 100);














      end;
    end
    else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1];
  end
  else Sequence := FUnitGFXResource.FSequences.List^[FDirection - 1];
  if not GetSelected or (AoWHSMap.Frame and 6 <> 6) then
    while Sequence <> nil do
    begin
      Index := Sequence.GetFrameIndex(AoWHSMap.Frame, (Integer(Self) shr 2) and $FFFF);
      if Index <> -1 then
        Sequence.ImageLibrary[Index].Show(XhpSurf + Sequence.dXshift, YhpSurf + Sequence.dYshift, SurfaceDesc);
      Sequence := Sequence.Next;
    end;
end;
procedure TUnitHS.SetDirection(Value: Byte);
begin
  if Value <> FDirection then
  begin
    if Moving then CancelMove;
    FDirection := Value;
  end;
end;
function TUnitHS.MoveFirst(Direction: Integer; Instant: Boolean): Shortint;
begin
  if FMoveStep <> -1 then CancelMove;
  FStatus := FStatus and $E7;
  if Instant then FStatus := FStatus or $10;
  FDirection := Direction;
  FMoveStep := 0;
  CalcShowPriority;
  Result := 0;
end;
function TUnitHS.GetMoveStatus: Shortint;
begin
  if FMoveStep >= 0 then
    if FMoveStep < GetMoveSteps then Result := Round(FMoveStep * 100 / GetMoveSteps)
    else Result := 100
  else Result := -1;
end;


procedure TUnitHS.SetMoveStatus(Value: Shortint);
begin
  if Value >= 0 then
  begin
    FMoveStep := (GetMoveSteps * Value + 50) div 100;
    if FMoveStep > GetMoveSteps then begin FMoveStep := GetMoveSteps; Exit; end;
  end
  else FMoveStep := -1;
end;


function TUnitHS.MoveNext: Shortint;
begin
  if FMoveStep >= 0 then
  begin
    FStatus := FStatus and $F7;
    if FMoveStep < GetMoveSteps then
    begin
      Inc(FMoveStep);
      Result := Round(FMoveStep * 100 / GetMoveSteps);
    end
    else Result := 100;
  end
  else Result := -1;
end;


function TUnitHS.Moving: Boolean;
begin Result := FMoveStep <> -1; end;


procedure TUnitHS.PauseMove;
begin FStatus := FStatus or 8; end;


procedure TUnitHS.CancelMove;
begin
  if FMoveStep <> -1 then
  begin
    FMoveStep := -1;
    FStatus := FStatus and $E7;
  end;
end;


function TUnitHS.GetMoveSteps: Integer;
begin
  case FUnitGFXResource.F_UnitGFXResource_30 of
    0: begin Result := 12; Exit; end;
    1: begin Result := 10; Exit; end;
    2: begin Result := 8; Exit; end;
    3: begin Result := 6; Exit; end;
  else Result := 8;
  end;
end;


procedure TUnitHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin
  inherited MapFieldMsgProc(Msg);
  if (Msg.MsgID = $10) and (Msg.HN = 0) and (msEditting in AoWHSMap.Status) then Destroy;
end;


