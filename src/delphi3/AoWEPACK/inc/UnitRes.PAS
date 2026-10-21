function TAbstractUnitResource.GetEngine: Engine.TEngine;
begin Result := AoWEngine; end;


function TAbstractUnitResource.GetObtainValue: Integer;
begin Result := 0; end;


function TAbstractUnitResource.GetFace: TLibraryImage;
var
  Resource: TUnitGFXResource;
begin
  Resource := AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnitGFXResourceIndex);
  if Resource <> nil then begin Result := Resource.GetFaceImage; Exit; end;
  Result := nil;
end;


function TAbstractUnitResource.GetPreviewImage: TLibraryImage;
var
  Resource: TUnitGFXResource;
begin
  Resource := AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnitGFXResourceIndex);
  if Resource <> nil then begin Result := Resource.GetCellImage; Exit; end;
  Result := nil;
end;


function TAbstractUnitResource.GetCellImage: ImageLib.TLibraryImage;
begin Result := GetPreviewImage; end;


procedure TAbstractUnitResource.SetUnitGFXResourceIndex(Value: Integer);
begin FUnitGFXResourceIndex := Value; end;


procedure TAbstractUnitResource.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FUnitGFXResourceIndex, 8);
end;


function TAbstractUnitResource.DropUnit(Xhx, Yhx, Lhx: Integer): Boolean;
begin Result := False; end;


procedure TAbstractUnitResource.EditDropMsg(var Msg: TEMsg);
var
  Map: TMapContainer;
  Lhx, Xhx, Yhx: Integer;
begin
  Map := TMapContainer(Msg.Param[0]);
  Lhx := Msg.Data[1];
  HPtoHX(Integer(Msg.Engine), Msg.Data[0], Xhx, Yhx);
  if (Xhx >= 0) and (Yhx >= 0) and (Xhx < Map.Width) and (Yhx < Map.Height) and
     DropUnit(Xhx, Yhx, Lhx) then Msg.Result := 0
  else Msg.Result := -1;
end;


class function TAbstractUnitResource.ResourceEditName: string;
begin Result := 'Unit'; end;


procedure TAbstractUnitResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  if Msg.MsgID = $10005 then EditDropMsg(Msg);
  if Msg.MsgID = $10055 then Msg.Result := 8;
end;

constructor TUnitResource.Create(AOwner: Engine.TECustomNode);
var
  Rank: TUnitRank;
begin
  inherited Create(AOwner);
  FDescription := TStringList.Create;
  for Rank := Low(TUnitRank) to High(TUnitRank) do
    FAbilities[Rank] := TUnitResourceAbilityOwner.Create(nil);
  FMoves := 16;
  FHits := 5;
  FAttack := 3;
  FDefense := 3;
  FResistance := 3;
  FDamage := 3;
  FUnitSize := usMedium;
  FBloodType := btRed;
end;


destructor TUnitResource.Destroy;
var
  Rank: TUnitRank;
begin
  FDescription.Free;
  for Rank := Low(TUnitRank) to High(TUnitRank) do FAbilities[Rank].Free;
  inherited Destroy;
end;


function TUnitResource.GetMoveTypes: TMoveTypes;
var
  MoveTypes: TMoveTypes;
begin
  MoveTypes := FAbilities[urNone].GetAbMoveTypesAll;
  Result := MoveTypes;
end;


function TUnitResource.GetTransportCapacity: Byte;
begin
  Result := AoWHSSet.FAbilityControl.GetAbility(50).GetLevel(FAbilities[urNone]);
  if Result < FTransportCapacity then Result := FTransportCapacity;
end;


function TUnitResource.GetUpkeep: Shortint;
begin Result := FLevel + 1; end;


function TUnitResource.GetObtainValue: Integer;
begin Result := FObtainValue; end;


procedure TUnitResource.SetDescription(Value: TStrings);
begin FDescription.Assign(Value); end;


function TUnitResource.ResourceUserClassID: Integer;
begin Result := $20214; end;


function TUnitResource.CreateResourceUser: Engine.TEObject;
begin
  Result := inherited CreateResourceUser;
  if Result <> nil then TUnitHS(Result).SetUnitGFXResourceIndex(FUnitGFXResourceIndex);
end;

procedure UnregisterEnhancementAbilities(Control:TAbilityControl);begin with Control do begin UnregisterAbilityID(120);UnregisterAbilityID(121);UnregisterAbilityID(122);UnregisterAbilityID(123);UnregisterAbilityID(124);UnregisterAbilityID(86);UnregisterAbilityID(87);UnregisterAbilityID(88);UnregisterAbilityID(89);UnregisterAbilityID(90);UnregisterAbilityID(24);UnregisterAbilityID(25);UnregisterAbilityID(30);UnregisterAbilityID(31);UnregisterAbilityID(44);UnregisterAbilityID(45);UnregisterAbilityID(55);UnregisterAbilityID(57);UnregisterAbilityID(58);UnregisterAbilityID(61);UnregisterAbilityID(62);end;end; { $5576F82C }
function TUnitResource.UnitResourceIndex: Integer;
begin Result := Owner.FindChildIndex(Self); end;


class function TUnitResource.ClassID: Integer;
begin Result := $20212; end;


function TUnitResource.GetUnitName: string;
begin
  Result := FName;
  if FNickname <> '' then Result := Result + ' ' + FNickname;
end;

procedure UnregisterTouchAbilities(Control:TAbilityControl);begin with Control do begin UnregisterAbilityID(21);UnregisterAbilityID(118);UnregisterAbilityID(111);UnregisterAbilityID(112);UnregisterAbilityID(113);UnregisterAbilityID(115);UnregisterAbilityID(116);UnregisterAbilityID(119);UnregisterAbilityID(14);UnregisterAbilityID(15);UnregisterAbilityID(16);UnregisterAbilityID(17);UnregisterAbilityID(18);UnregisterAbilityID(19);UnregisterAbilityID(20);end;end; { $55767600 }
procedure TUnitResource.ReadWrite(Stream: Engine.TEStorageStream);
var
  Rank: TUnitRank;
begin
  inherited ReadWrite(Stream);
  Stream.rwString(FName, 10);
  Stream.rwString(FNickname, 11);
  Stream.rwData(FAlignment, 1, 12);
  Stream.rwByte(Byte(FRace), 13);
  Stream.rwByte(Byte(FAttack), 14);
  Stream.rwByte(Byte(FDefense), 15);
  Stream.rwByte(Byte(FDamage), 16);
  Stream.rwByte(Byte(FHits), 17);
  Stream.rwByte(Byte(FMoves), 18);
  Stream.rwByte(Byte(FResistance), 19);
  Stream.rwByte(Byte(FLevel), 20);
  Stream.rwData(FUnitType, 1, 21);
  Stream.rwData(FChampion, 1, 22);
  Stream.rwData(FGender, 1, 23);
  Stream.rwByte(FTransportCapacity, 24);
  Stream.rwEObject(FAbilities[urNone], 25);
  Stream.rwStrings(FDescription, 26);
  Stream.rwInteger(FObtainValue, 27);
  Stream.rwData(FUnitSize, 1, 28);
  Stream.rwData(FBloodType, 1, 29);
  Stream.rwEObject(FAbilities[urSilver], 30);
  Stream.rwEObject(FAbilities[urGold], 31);
  if smRead in Stream.StorageMode then
    for Rank := Low(TUnitRank) to High(TUnitRank) do FAbilities[Rank].ValidateOwnerTypeAbilities;
end;

procedure UnregisterCoreSpells(AEngine:TAoWEngine);var Control:TSpellControl;begin Control:=AEngine.FGameSet.FSpellControl;AEngine.UnregisterEClasses([TSpellTE]);AEngine.UnregisterEClasses([TSpellCastEventLog]);AEngine.UnregisterEClasses([TUnitSpellTE,TUnitSpellCA]);Control.UnregisterAll;end; { $5577BE44 }
function TUnitResource.DropUnit(Xhx, Yhx, Lhx: Integer): Boolean;
var
  Player: Shortint;
  AUnit: TUnit;
begin
  if msEditting in AoWHSMap.Status then
  begin
    Player := TAoWMapField(AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx)).GetPlayer;
    if Player = -1 then Player := AoWHSMap.FEditorPlayer;
  end
  else Player := -1;
  AUnit := TUnit.Create(nil);
  AUnit.SetUnitResource(Self);
  Result := AUnit.Place(Xhx, Yhx, Lhx, Player, []) <> nil;
  AUnit.Release;
end;
procedure UnregisterCoreAbilities(Control:TAbilityControl);begin with Control do begin AoWEngine.UnregisterEClasses([TCosmeticSurgeryEnchantment, TLeadershipAbilityData]);AoWEngine.UnregisterEClasses([TDurationAbilityData, TMultiLevelAbilityData, TRangedAttackCA, TSelfDestructCA, TStrikeCA, TDispelMagicAbilityCA]);AoWEngine.UnregisterEClasses([TUnitEnchantmentAbilityData, TUnitEnchantment, TDispelMagicAbilityTE]);AoWEngine.UnregisterEClasses([TCommandCA, TCommandedAbilityData, TCommandAbilityData, THealingTE, TDispelMagicAbilityData]);AoWEngine.UnregisterEClasses([TPossessCA, TWebCA, THealingCA, TEntangleCA, THealingAbilityData, TInvokeDeathCA]);UnregisterAbilityID(86);UnregisterAbilityID(87);UnregisterAbilityID(88);UnregisterAbilityID(89);UnregisterAbilityID(90);UnregisterAbilityID(114);UnregisterAbilityID(40);UnregisterAbilityID(27);UnregisterAbilityID(65);UnregisterAbilityID(148);UnregisterAbilityID(149);UnregisterAbilityID(28);UnregisterAbilityID(150);UnregisterAbilityID(29);
UnregisterAbilityID(48);UnregisterAbilityID(22);UnregisterAbilityID(47);UnregisterAbilityID(46);UnregisterAbilityID(52);UnregisterAbilityID(38);UnregisterAbilityID(35);UnregisterAbilityID(146);UnregisterAbilityID(147);UnregisterAbilityID(125);UnregisterAbilityID(60);UnregisterAbilityID(117);UnregisterAbilityID(50);UnregisterAbilityID(106);UnregisterAbilityID(107);UnregisterEnhancementAbilities(Control);UnregisterTouchAbilities(Control);end;end; { $557717A4 }
constructor TUnitResourceList.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  SetControlStyle([csSaveLoad, csFixedChild, csArrayMode]);
end;

function TUnitResourceList.GetUnitResource(Index: Integer): TUnitResource;
begin
  if (Index >= 0) and (Index < FChildren.Count) then
    Result := TUnitResource(FChildren.List^[Index])
  else Result := nil;
end;

constructor TUnitIndexList.Create;
begin
  inherited Create;
  Default := -1;
end;

function TUnitIndexList.GetUnitIndex(Index: Integer): Integer;
begin
  if (Index < 0) or (Index >= Count) then Result := Default
  else Result := List^[Index];
end;

procedure TUnitIndexList.VerifyUnits(ShowErrors: Boolean);
var I, U: Integer;
begin
  for I := Count - 1 downto 0 do
  begin
    U := List^[I];
    if (U <> -1) and (AoWHSSet.FUnitResources.GetUnitResource(U) = nil) then
    begin
      if ShowErrors then ShowMessage('Used unit missing (unit index:' + IntToStr(U) + ')');
      List^[I] := Default;
    end;
  end;
end;

procedure TUnitIndexList.SetUnitIndex(Index, Value: Integer);
begin



  Assert(Index >= 0, 'List index out of bounds (TUnitIndexList)');
  if Index >= Count then Count := Index + 1;
  List^[Index] := Value;
end;
function P2CompareUnitIndexes(Item1, Item2: Integer): Integer;
begin
  Assert((AoWHSSet.FUnitResources.GetUnitResource(Item1) <> nil) and
    (AoWHSSet.FUnitResources.GetUnitResource(Item1) <> nil), 'Undefined UnitResource Used!');
  Result := AoWHSSet.FUnitResources.GetUnitResource(Item2).FLevel -
    AoWHSSet.FUnitResources.GetUnitResource(Item1).FLevel;
end;

procedure TUnitIndexList.SortUnits;
begin
  if AoWHSSet <> nil then
  begin
    Pack;
    try
      Sort(P2CompareUnitIndexes);
    except
    end;
  end;
end;

