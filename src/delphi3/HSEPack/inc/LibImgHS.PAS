{ LibImgHS.PAS: TLibraryImageHS (include file of HSEngine.pas; the original Asserts name
  D:\GEngine\HSENGINE\inc\LibImgHS.PAS) }

{ TLibraryImageHS }

constructor TLibraryImageHS.Create(AOwner: TECustomNode);
begin
  inherited Create(AOwner);
  FStatus := [lsMapIsOwner];
  SetLevel(26);
end;

class function TLibraryImageHS.ClassID: Integer;
begin
  Result := $10153;
end;

procedure TLibraryImageHS.SetVisible(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [lsVisible]
  else
    FStatus := FStatus - [lsVisible];
end;

function TLibraryImageHS.GetVisible: Boolean;
begin
  Result := lsVisible in FStatus;
end;

procedure TLibraryImageHS.MakeVisible(VisibilityList: TVisibilityList);
begin
  if not (lsVisible in FStatus) then
  begin
    FStatus := FStatus + [lsVisible];
    VisibilityList.AddSortChild(Self, GetShowPriority);
  end;
end;

function TLibraryImageHS.GetEditMode: Boolean;
begin
  Result := lsEditMode in FStatus;
end;

procedure TLibraryImageHS.SetEditMode(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [lsEditMode]
  else
    FStatus := FStatus - [lsEditMode];
end;

function TLibraryImageHS.GetMapIsOwner: Boolean;
begin
  Result := lsMapIsOwner in FStatus;
end;

procedure TLibraryImageHS.SetMapIsOwner(Value: Boolean);
begin
  if lsPlacedOnMap in FStatus then OriginalAssert('Cannot change MapIsOwner when places on map (TLibraryImageHS)', 'D:\GEngine\HSENGINE\inc\LibImgHS.PAS', $19E2);
  if Value then
    FStatus := FStatus + [lsMapIsOwner]
  else
    FStatus := FStatus - [lsMapIsOwner];
end;

function TLibraryImageHS.GetDestroyOnShow: Boolean;
begin
  Result := lsDestroyOnShow in FStatus;
end;

procedure TLibraryImageHS.SetDestroyOnShow(Value: Boolean);
begin
  if Value then
    FStatus := FStatus + [lsDestroyOnShow]
  else
    FStatus := FStatus - [lsDestroyOnShow];
end;

procedure TLibraryImageHS.SetLevel(Value: Byte);
begin
  FShowPriority := FShowPriority and $3FFFFFF + Value shl 26;
end;

function TLibraryImageHS.GetLevel: Byte;
begin
  Result := FShowPriority shr 26;
end;

function TLibraryImageHS.GetShowPriority: Integer;
begin
  Result := FYhp shl 13 + FXhp + FShowPriority;
end;

procedure TLibraryImageHS.SetShowPriorityOffset(OffsetX, OffsetY: Integer);
begin
  { both offsets are shifted into the Y part (original) }
  FShowPriority := FShowPriority and Integer($FC000000) + OffsetY shl 13 + OffsetX shl 13;
end;

procedure TLibraryImageHS.SetImage(Value: TLibraryImage);
begin
  if lsPlacedOnMap in FStatus then
    if (Value = nil) or ((FImage.Width <> Value.Width) or (FImage.Height <> Value.Height)) then
      raise Exception.Create('Cannot change image when placed on map (TLibraryImageHS)');
  FImage := Value;
  if FImage <> nil then
    SetShowPriorityOffset(FImage.Width shr 1, FImage.Height shr 1);
end;

procedure TLibraryImageHS.ReadWrite(Stream: TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FStatus, SizeOf(FStatus), 1);
  Stream.rwInteger(FShowPriority, 2);
  Stream.rwInteger(FXhp, 3);
  Stream.rwInteger(FYhp, 4);
  Stream.rwByte(FLhx, 5);
end;

function TLibraryImageHS.CanPlace(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin
  Result := True;
end;

function TLibraryImageHS.Place(Map: TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin
  if CanPlace(Map, Xhp, Yhp, Lhx) then
  begin
    FXhp := Xhp;
    FYhp := Yhp;
    FLhx := Lhx;
    if lsMapIsOwner in FStatus then
      Result := PlaceOnMapEx(Map, Xhp, Yhp, Lhx, FImage.Width, FImage.Height)
    else
      Result := PlaceUserOnMapEx(Map, Xhp, Yhp, Lhx, FImage.Width, FImage.Height);
    if Result then
      FStatus := FStatus + [lsPlacedOnMap];
  end
  else
    Result := False;
end;

function TLibraryImageHS.PlaceHX(Map: TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
var
  Xhp, Yhp: Integer;
begin
  HXtoHP(Xhx, Yhx, Xhp, Yhp);
  Result := Place(Map, FImage.Width shr 2 + Xhp + 16, FImage.Height shr 2 + Yhp + 16, Lhx);
end;

procedure TLibraryImageHS.Remove;
var
  Engine: THSEngine;
begin
  if lsPlacedOnMap in FStatus then
  begin
    if lsMapIsOwner in FStatus then
    begin
      if GetVisible then
      begin
        if GetLevel <= 15 then
        begin
          TVisibilityList(THSMap(TMapContainer(TMapLevel(Owner.Owner).FMapContainer).FMap).FStaticVisibleHS).RemoveChild(Self);
          THSMap(TMapContainer(TMapLevel(Owner.Owner).FMapContainer).FMap).FStaticSceneInvalid := True;
        end
        else
          TVisibilityList(THSMap(TMapContainer(TMapLevel(Owner.Owner).FMapContainer).FMap).FDynamicVisibleHS).RemoveChild(Self);
        SetVisible(False);
      end;
      RemoveFromMapEx(FXhp, FYhp, FImage.Width, FImage.Height);
    end
    else
    begin
      Engine := THSEngine(GetEngine);
      if GetVisible then
      begin
        if GetLevel <= 15 then
        begin
          TVisibilityList(THSMap(Engine.FHSMap).FStaticVisibleHS).RemoveChild(Self);
          THSMap(Engine.FHSMap).FStaticSceneInvalid := True;
        end
        else
          TVisibilityList(THSMap(Engine.FHSMap).FDynamicVisibleHS).RemoveChild(Self);
        SetVisible(False);
      end;
      RemoveUserFromMapEx(TMapContainer(THSMap(Engine.FHSMap).FMapContainer),
        FXhp, FYhp, FLhx, FImage.Width, FImage.Height);
    end;
    FStatus := FStatus - [lsPlacedOnMap];
  end;
end;

procedure TLibraryImageHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: TSurfaceDesc);
begin
  FImage.Show(FXhp - XhpSurf, FYhp - YhpSurf, SurfaceDesc);
  if lsDestroyOnShow in FStatus then
    Destroy;
end;

