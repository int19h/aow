{ P3 combat implementation. }
resourcestring
  BattleWonRStr = 'Battle Won';
  BattleLostRStr = 'Battle Lost';
  BattleDrawnRStr = 'Battle Drawn';
  CannotBreachWallRStr = 'Cannot breach wall';
  CannotInflictDamageRStr = 'Cannot inflict damage';
const
  RaceColors: array[0..12] of TColor = ($E03430, $66A4FF, $AFCB2C, $FEDA87,
    $60EF41, $15FDFD, $A5C1E4, $F7FFFD, $B370BC, $5050E9, $4266BB, $797898, $A8A8A8);
type
  PP3String = ^string;
  TP3NodeAccess = class(TENode)
  public
    property ChildrenList: TEObjectList read FChildren;
  end;
var
  P3HitProbabilities: array[0..19] of Single;
  CombatDID: Integer; { $558FA04C }

constructor TCombatUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FControlMode := [cmConquerObject];
  FUnitGFXResourceIndex := -1;
end;

destructor TCombatUnit.Destroy;
begin
  SetUnit(nil);
  inherited Destroy;
end;

class function TCombatUnit.ClassID: Integer;
begin Result := $202A1; end;

procedure TCombatUnit.Setup(A1: Byte; A2: Byte; A3: TAbstractUnit; A4: Byte; A5: Byte);
begin
  FID := A1;
  FPosition := A4;
  SetCombatPlayer(A5);
  SetUnit(TAbstractUnit(A3));
end;

function TCombatUnit.GetVisibilityRange: Integer;
var
  Level: Integer;
  U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then
  begin
    Level := TAbstractUnit(U).GetAbilityLevel($40);
    if Level <> 0 then
      Result := Level * 2 + 4
    else
      Result := 4;
    if (TCombat(FCombat).FExplorationSite = 1) and
       not TAbstractUnit(FUnit).GetAbilityEnabled($27) then
      Result := (Result + 1) div 2;
  end
  else Result := 0;
end;

procedure TCombatUnit.NewTurn(A1: Byte);
var
  U: TAbstractUnit;
begin
  inherited NewTurn(A1);
  U := FUnit;
  if U <> nil then U.TriggerNewCombatTurn(Self, A1);
end;

procedure TCombatUnit.NewRound;
begin inherited NewRound; end;

procedure TCombatUnit.CombatDone;
var
  U: TAbstractUnit;
begin
  inherited CombatDone;
  U := FUnit;
  if U <> nil then U.TriggerCombatDone(Self);
end;

function TCombatUnit.GetEnabled: Boolean;
begin
  Result := (FUnit <> nil) and ([csDestroyed, csFled] * FStatus = []) and
    not FDisabled;
end;

function TCombatUnit.GetLocked: Boolean;
begin
  Result := TAbstractUnit(FUnit).GetAbilityEnabled($5F) or
    TAbstractUnit(FUnit).GetAbilityEnabled($61) or
    TAbstractUnit(FUnit).GetAbilityEnabled($5C) or
    TAbstractUnit(FUnit).GetAbilityEnabled($5E) or
    TAbstractUnit(FUnit).GetAbilityEnabled($22);
end;

function TCombatUnit.WallCombatFeatures: TWallCombatFeatures;
begin Result := FWallCombatFeatures; end;

function TCombatUnit.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin
  Result := FUnit.ExecuteCombatDamageEffects(TCombat(FCombat), A1);
end;

function TCombatUnit.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin
  Result := FUnit.ExecuteDamageEffectsRole(A1);
end;

procedure TCombatUnit.UpdateWallCombatFeatures;
var U: TAbstractUnit;
begin
  U := FUnit;
  if (U <> nil) and not (csDestroyed in FStatus) then
  begin
    FWallCombatFeatures := U.GetWallCombatFeatures;
    if FUnit.GetAbilityEnabled($34) and
      TSpellCastingAbility(AoWHSSet.FAbilityControl.GetAbility($34)).CanCastBreachWallSpell(FUnit) then
      FWallCombatFeatures := FWallCombatFeatures + [wcWallBreaching];
  end
  else FWallCombatFeatures := [];
end;

procedure TCombatUnit.Activate(A1: Integer);
begin
  inherited Activate(A1);
  UpdateParty;
  UpdateWallCombatFeatures;
  UpdateUnitGFXResource;
end;

procedure TCombatUnit.Deactivate;
begin
  inherited Deactivate;
  UpdateParty;
  ReleaseUnitGFXResource;
end;

procedure TCombatUnit.Initialize(A1: Integer);
begin
  inherited Initialize(A1);
  if FUnit is TLeader then
    TByteList(TCombatData(TCombat(A1).FCombatData).F_CombatData_28).Add(FCombatPlayer);
end;

procedure TCombatUnit.Finalize(A1: TFinalizeMode);
var Party: TCombatParty; Placed: TArmyHS;
begin
  if not (csDestroyed in FStatus) and not FUnit.GetAbilityEnabled($82) and not FUnit.GetAbilityEnabled($83) then
  begin
    if A1 <> fmAll then
    begin
      if FPosition and $F <= 7 then
      begin
        Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_3C).GetParty(FPosition shr 4);
        if (Party <> nil) and (Party.F_CombatParty_1A = FCombatPlayer) then
        begin
          if AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGameOverStatus = goLost then
          begin
            Placed := FUnit.Place(Party.F_CombatParty_0C, Party.F_CombatParty_10, Party.F_CombatParty_14, 0, [pmNeglectEmptyPlayerLocation]);
          end
          else Placed := FUnit.Place(Party.F_CombatParty_0C, Party.F_CombatParty_10, Party.F_CombatParty_14, GetPlayer, [pmNeglectEmptyPlayerLocation]);
          if Placed <> nil then Destroy;
        end;
      end;
    end
    else
    begin
      if FPosition and $F <= 7 then
        Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_3C).GetParty(FPosition shr 4)
      else Party := nil;
      if (Party = nil) or (Party.F_CombatParty_0C <> -1) then
      begin
        if AoWHSMap.FPlayers.GetPlayers(GetPlayer).FGameOverStatus = goLost then
          FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_08,
            TCombatData(TCombat(FCombat).FCombatData).F_CombatData_0C,
            TCombatData(TCombat(FCombat).FCombatData).F_CombatData_10, 0, [pmScanArea])
        else
          FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_08,
            TCombatData(TCombat(FCombat).FCombatData).F_CombatData_0C,
            TCombatData(TCombat(FCombat).FCombatData).F_CombatData_10, GetPlayer, [pmScanArea]);
        Destroy;
      end
      else if (Party <> nil) and (Party.F_CombatParty_1A <> FCombatPlayer) then
        FUnit.Place(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_08,
          TCombatData(TCombat(FCombat).FCombatData).F_CombatData_0C,
          TCombatData(TCombat(FCombat).FCombatData).F_CombatData_10, GetPlayer, [pmScanArea]);
    end;
  end
  else Destroy;
end;

procedure TCombatUnit.PlaySFX(A1: Byte);
begin
  case A1 of
    0: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[2].Play(0);
    1: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[2].Play(1);
    2: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[3].Play(0);
    3: AoWHSSet.FUnitGFXResources.GetUnitGFXResource(FUnit.GetUnitGFXResourceIndex).FSFXLibraries[4].Play(0);
  end;
end;

function TCombatUnit.GetMoves: Integer;
begin Result := TAbstractUnit(FUnit).GetMoves; end;

function TCombatUnit.GetAlignment: TAlignment;
begin Result := TAbstractUnit(FUnit).GetAlignment; end;

function TCombatUnit.GetAbilityOwner: TAbilityOwner;
begin Result := FUnit; end;

function TCombatUnit.GetAbilityEnabled(A1: Integer): Boolean;
begin
  if FUnit <> nil then Result := TAbstractUnit(FUnit).GetAbilityEnabled(A1) else Result := False;
end;

procedure TCombatUnit.SetAbilityEnabled(A1: Integer; A2: Boolean);
begin FUnit.SetAbSet(A1, Byte(A2)); end;

function TCombatUnit.GetAbilityLevel(A1: Integer): Integer;
begin Result := TAbstractUnit(FUnit).GetAbilityLevel(A1); end;

function TCombatUnit.GetAbilityCount: Integer;
begin
  if FUnit <> nil then Result := TAbstractUnit(FUnit).GetAbilityCount else Result := 0;
end;

function TCombatUnit.GetHits: Byte;
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then Result := FUnit.GetHits else Result := 0;
end;

function TCombatUnit.GetHitPoints: Shortint;
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then Result := FUnit.GetHitPoints else Result := 0;
end;

procedure TCombatUnit.SetHitPoints(A1: Byte);
var U: TAbstractUnit;
begin
  U := TAbstractUnit(FUnit);
  if U <> nil then FUnit.SetHitPoints(A1);
end;

procedure TCombatUnit.SetParty(Party: TCombatParty);
var P: TCombatParty;
begin
  if Party <> FParty then
  begin
    if (FParty <> nil) and (FUnit <> nil) then FUnit.SetOwner(nil);
    FParty := Party;
    P := FParty;
    if (P <> nil) and (FUnit <> nil) then
    begin
      FUnit.SetOwner(TArmy(P.F_CombatParty_08));
      TArmy(FParty.F_CombatParty_08).UpdateFormation;
    end;
  end;
end;

procedure TCombatUnit.UpdateParty;
var Party: TCombatParty;
begin
  if csActivated in FStatus then
  begin
    Party := TCombatPartyList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_3C).GetParty(FPosition shr 4);
    if (FCombatPlayer <> Party.F_CombatParty_1A) or (csDestroyed in FStatus) then Party := nil;
  end
  else Party := nil;
  SetParty(Party);
end;

procedure TCombatUnit.UpdateUnitGFXResource;
var Index: Integer; U: TAbstractUnit;
begin
  U := FUnit;
  if U <> nil then Index := U.GetUnitGFXResourceIndex else Index := -1;
  if Index <> FUnitGFXResourceIndex then
  begin
    ReleaseUnitGFXResource;
    if Index <> -1 then
    begin
      AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).AddRef;
      FUnitGFXResourceIndex := Index;
    end;
  end;
end;

procedure TCombatUnit.ReleaseUnitGFXResource;
var Index: Integer;
begin
  Index := FUnitGFXResourceIndex;
  if Index <> -1 then
  begin
    AoWHSSet.FUnitGFXResources.GetUnitGFXResource(Index).Release;
    FUnitGFXResourceIndex := -1;
  end;
end;

procedure TCombatUnit.SetUnit(AUnit: TAbstractUnit);
var U: TAbstractUnit; Party: TCombatParty;
begin
  U := FUnit;
  if U <> AUnit then
  begin
    if U <> nil then
    begin
      Party := FParty;
      if (Party <> nil) and (FUnit.Owner = TArmy(Party.F_CombatParty_08)) then FUnit.SetOwner(nil);
      FUnit.Release;
    end;
    FUnit := AUnit;
    U := FUnit;
    if U <> nil then
    begin
      U.AddRef;
      Party := FParty;
      if (Party <> nil) and not (csDestroyed in FStatus) then TArmy(Party.F_CombatParty_08).AddUnit(FUnit);
    end;
  end;
  if csActivated in FStatus then UpdateUnitGFXResource;
end;

procedure TCombatUnit.ReadWrite(Stream: Engine.TEStorageStream);
var U: TAbstractUnit;
begin
  inherited ReadWrite(Stream);
  if Stream.StorageMode * [smRead, smTranslate] = [smRead] then
  begin
    Stream.rwCreateEObject(TEObject(U), nil, $14);
    SetUnit(U);
    if U <> nil then U.Release;
  end
  else Stream.rwCreateEObject(TEObject(FUnit), nil, $14);
  Stream.rwBool(FDisabled, $15);
end;

procedure TCombatUnit.ObjectDestroyed(A1: Integer);
var C: TCombatUnit; U: TAbstractUnit;
begin
  inherited ObjectDestroyed(A1);
  if FDisabled and (TObject(A1) is TCombatUnit) then
  begin
    C := TCombatUnit(A1);
    U := C.FUnit;
    if (U <> nil) and U.GetTransporter and (C.FPosition shr 4 = FPosition shr 4) then DestroyObject;
  end;
end;

procedure TCombatUnit.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
var U: TAbstractUnit; Abilities: TAbilityTypeList; Values: TP1DamageValues;
  I, V: Integer; Ability: TAbility;
begin
  if not (csDestroyed in FStatus) then
  begin
    U := FUnit;
    CV := 0;
    DV := 0;
    Abilities := AoWHSSet.FAbilityControl.FAbilitiesByType[atCombat];
    for I := Abilities.Count - 1 downto 0 do
    begin
      Ability := Abilities.GetAbility(I);
      if U.GetAbilityEnabled(Ability.FAbilityID) then
      begin
        Ability.tcGetDamageValueEx(Self, Target, TAbilityDamageValues(Values));
        if Values.Damage > 0 then
        begin
          V := (Values.Damage * Values.Damage) div (Values.Experience + Values.Damage);
          if V <= 0 then V := 1;
          if V > CV then CV := V;
          if Values.Damage > DV then DV := Values.Damage;
        end;
      end;
    end;
    if U.GetAbilityEnabled($34) then
    begin
      Ability := AoWHSSet.FAbilityControl.GetAbility($34);
      Ability.tcGetDamageValueEx(Self, Target, TAbilityDamageValues(Values));
      if Values.Damage > 0 then
      begin
        V := (Values.Damage * Values.Damage) div (Values.Experience + Values.Damage);
        if V <= 0 then V := 1;
        if V > CV then CV := V;
        if Values.Damage > DV then DV := Values.Damage;
      end;
    end;
  end
  else
  begin CV := 0; DV := 0; end;
end;

function TCombatUnit.GetTargetWallCV(Target: TCombatObject): Integer;
begin
  if (Target is TCombatUnit) and not (csDestroyed in Target.FStatus) then
    if TCombatPlayerList(FCombat.FCombatData.FPlayers).GetPlayers(FCombatPlayer).F_CombatPlayer_0A = 1 then
      Result := FUnit.GetCombatValue(TCombatUnit(Target).FUnit, 1)
    else Result := FUnit.GetCombatValue(TCombatUnit(Target).FUnit, 2)
  else Result := 0;
end;

function TCombatUnit.GetAttack: Shortint;
begin Result := TAbstractUnit(FUnit).GetAttack; end;

function TCombatUnit.GetDefense: Shortint;
begin Result := TAbstractUnit(FUnit).GetDefense; end;

function TCombatUnit.GetResistance: Shortint;
begin Result := TAbstractUnit(FUnit).GetResistance; end;

function TCombatUnit.GetDamage: Shortint;
begin Result := TAbstractUnit(FUnit).GetDamage; end;

function TCombatUnit.GetImmunityTypes: TDamageTypes;
begin Result := TAbstractUnit(FUnit).GetImmunityTypes + TCombatData(TCombat(FCombat).FCombatData).F_CombatData_22; end;

function TCombatUnit.GetProtectionTypes: TDamageTypes;
begin Result := TAbstractUnit(FUnit).GetProtectionTypes; end;

function TCombatUnit.GetExperience: Integer;
begin Result := TAbstractUnit(FUnit).GetExperience; end;

procedure TCombatUnit.SetExperience(A1: Integer);
begin FUnit.SetExperience(A1); end;

function TCombatUnit.GetLevel: Byte;
begin Result := TAbstractUnit(FUnit).GetUnitLevel; end;

function TCombatUnit.IDStr: string;
begin
  if TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Shortint(FCombatPlayer)).F_CombatPlayer_0A = 0 then Result := 'A'
  else Result := 'D';
  if FUnit <> nil then Result := Result + '(' + IntToStr(FPosition) + ')=' + FUnit.GetName
  else Result := Result + '(' + IntToStr(FPosition) + ')';
end;

function TCombatUnit.SupportCombatMode(Modes: TCombatModes): Boolean;
var U: TAbstractUnit; I: Integer;
begin
  U := FUnit;
  if (U <> nil) and (U.GetHitPoints > 0) then
  begin
    Result := False;
    I := FUnit.GetAbilityCount;
    while (I <> 0) and not Result do
    begin
      Dec(I);
      Result := FUnit.GetAbilityEnabled(I) and
        (AoWHSSet.FAbilityControl.GetAbility(I).GetCombatMode(FUnit) in Modes);
    end;
  end
  else Result := False;
end;

procedure TCombatUnit.SetStatus(Status: TCombatObjectStatus);
begin
  if (csFled in Status) and not (csFled in FStatus) then
  begin
    FStatus := Status;
    TCombat(FCombat).CheckTerminate;
  end
  else FStatus := Status;
end;

procedure TCombatUnit.KillUnit;
begin FUnit.Killed; end;

procedure TCombatUnit.DestroyObject;
var U: TAbstractUnit; I: Integer;
begin
  if GetHitPoints <> 0 then SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  U := FUnit;
  if U <> nil then
    for I := U.GetAbilityCount - 1 downto 0 do
      if FUnit.GetAbilityEnabled(I) then
        AoWHSSet.FAbilityControl.GetAbility(I).CombatObjectDestroyed(Self);
  if csDestroyed in FStatus then
  begin
    ResetTargets;
    if FUnit is TLeader then TByteList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_2C).Add(FCombatPlayer);
    TCombat(FCombat).ObjectDestroyed(Integer(Self));
    if FUnit <> nil then KillUnit;
  end;
end;

procedure TCombatUnit.Surrender;
begin
  if GetHitPoints <> 0 then SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  ResetTargets;
  if FUnit is TLeader then TByteList(TCombatData(TCombat(FCombat).FCombatData).F_CombatData_2C).Add(FCombatPlayer);
  TCombat(FCombat).ObjectDestroyed(Integer(Self));
  if FUnit <> nil then KillUnit;
end;

function TCombatUnit.GetTargetPriority: Integer;
begin
  if FTargetPriorityInvalid then
  begin
    inherited GetTargetPriority;
    Inc(FTargetPriority, CommandingTargetPriority);
    Result := FTargetPriority;
    Exit;
  end;
  Result := FTargetPriority;
end;

function TCombatUnit.GetTargetStrength: Integer;
begin
  if FTargetStrengthInvalid then
  begin
    inherited GetTargetStrength;
    Inc(FTargetStrength, CommandingTargetStrength);
    Result := FTargetStrength;
    Exit;
  end;
  Result := FTargetStrength;
end;

function TCombatUnit.CommandingTargetPriority: Integer;
var I: Integer; Data: TCommandAbilityData;
const CommandAbilityIDs: array[0..2] of Integer = (29, 28, 148);
begin
  Result := 0;
  for I := 0 to 2 do
    if GetAbilityEnabled(CommandAbilityIDs[I]) then
    begin
      Data := TCommandAbilityData(FUnit.GetAbilityData(CommandAbilityIDs[I]));
      if Data <> nil then Inc(Result, Data.CommandingTargetPriority(TCombat(FCombat)));
    end;
end;

function TCombatUnit.CommandingTargetStrength: Integer;
var I: Integer; Data: TCommandAbilityData;
const CommandAbilityIDs: array[0..2] of Integer = (29, 28, 148);
begin
  Result := 0;
  for I := 0 to 2 do
    if GetAbilityEnabled(CommandAbilityIDs[I]) then
    begin
      Data := TCommandAbilityData(FUnit.GetAbilityData(CommandAbilityIDs[I]));
      if Data <> nil then Inc(Result, Data.CommandingTargetStrength(TCombat(FCombat)));
    end;
end;

procedure TCombatUnit.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaStandStill;
    if FStatus * [csDestroyed, csFled] <> [] then
    begin
      Info.Frame := 0;
      Info.Looped := False;
    end
    else
    begin
      Info.Frame := Frame;
      Info.Looped := True;
    end;
    U.ShowEx(X,Y,Surface,Info);
    if csFled in FStatus then AoWHSSet.FCombatImages[7].Show(X+18,Y+10,Surface);
  end;
end;

function TCombatUnit.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaAttack;
    Info.Frame := Frame;
    Info.Looped := False;
    Result := U.ShowEx(X,Y,Surface,Info);
  end
  else Result := -1;
end;

function TCombatUnit.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
var U: TAbstractUnit; Info: TP2UnitShowInfo;
begin
  U := FUnit;
  if U <> nil then
  begin
    Info.Direction := Byte(Direction);
    Info.Overlays := [uoHitPoints, uoRank, uoCombat];
    Info.Animation := uaHit;
    Info.Frame := Frame;
    Info.Looped := False;
    Result := U.ShowEx(X,Y,Surface,Info);
  end
  else Result := -1;
end;

constructor TCombatWall.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPosition := $80;
  FControlMode := [];
end;

destructor TCombatWall.Destroy;
begin inherited Destroy; end;

class function TCombatWall.ClassID: Integer;
begin Result := $202AF; end;

function TCombatWall.GetTargetPriority: Integer;
var I, Count: Integer; Obj: TCombatObject;
begin
  if FTargetPriorityInvalid then
  begin
    Count := 0;
    for I := TQuadItemList(FTargetedBy).Count - 1 downto 0 do
      if TQuadItemList(FTargetedBy).List^[I].B = 0 then Inc(Count);
    FTargetPriority := 0;
    for I := TCombatSide(TCombat(FCombat).FSides[csDefender]).Count - 1 downto 0 do
    begin
      Obj := TCombatSide(TCombat(FCombat).FSides[csDefender]).GetObjects(I);
      Inc(FTargetPriority, Obj.FIncomingCombatValue - Obj.FIncomingWallCombatValue);
    end;
    FTargetPriority := (Count + 2) * FTargetPriority;
    FTargetPriorityInvalid := False;
  end;
  Result := FTargetPriority;
end;

function TCombatWall.GetTargetStrength: Integer;
begin
  if not FLocked then
    if not TCombatData(TCombat(FCombat).FCombatData).FWallBreached then Result := 10
    else Result := 1
  else Result := 0;
end;

function TCombatWall.fcRoundDistance: Integer;
begin Result := 0; end;

procedure TCombatWall.Setup(A1: Byte; A2: Byte; A3: Integer);
begin
  FID := A1;
  FWallType := A2;
  FHitPoints := GetHits;
  SetCombatPlayer(Byte(A3));
end;

procedure TCombatWall.Activate(A1: Integer);
begin
  inherited Activate(A1);
  TCombatData(TCombat(A1).FCombatData).F_CombatData_50 := Integer(Self);
end;

procedure TCombatWall.Deactivate;
begin
  TCombatData(TCombat(FCombat).FCombatData).F_CombatData_50 := 0;
  inherited Deactivate;
end;

procedure TCombatWall.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(FWallType, 1, $14);
  Stream.rwByte(FHitPoints, $15);
end;

function TCombatWall.GetDefense: Shortint;
begin Result := 0; end;

function TCombatWall.GetResistance: Shortint;
begin Result := 3; end;

function TCombatWall.IDStr: string;
begin Result := 'Wall'; end;

function TCombatWall.GetHits: Byte;
begin if FWallType = 2 then Result := 10 else Result := 5; end;

function TCombatWall.GetHitPoints: Shortint;
begin Result := FHitPoints; end;

function TCombatWall.GetImmunityTypes: TDamageTypes;
begin
  Result := [dtWall];
  Result := [Low(TDamageType)..High(TDamageType)] - Result;
end;

function TCombatWall.GetLocked: Boolean;
begin Result := FLocked; end;

procedure TCombatWall.SetHitPoints(A1: Byte);
begin FHitPoints := A1; end;

procedure TCombatWall.DestroyObject;
begin
  inherited DestroyObject;
  TCombatData(TCombat(FCombat).FCombatData).FWallBreached := True;
end;

procedure TCombatWall.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin
  case FWallType of
    1: AoWHSSet.FCombatImages[21].Show(X+15,Y+5,Surface);
    2: AoWHSSet.FCombatImages[22].Show(X+15,Y+5,Surface);
  end;
  ShowHitPcnt(X,Y-10,Surface,HitPointsToHitPcnt(FHitPoints,GetHits));
end;

function TCombatWall.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Show(Frame,Direction,X,Y,Surface); Result := 0; end;

function TCombatWall.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Show(Frame,Direction,X,Y,Surface); Result := 0; end;

constructor TCombatObject.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FTargets := TQuadItemList.Create;
  FTargetedBy := TQuadItemList.Create;
  FCombatPlayer := $FF;
end;

destructor TCombatObject.Destroy;
begin
  if csActivated in FStatus then Deactivate;
  FTargets.Free;
  FTargetedBy.Free;
  inherited Destroy;
end;

procedure TCombatObject.TargetsChanged;
begin FTargetPriorityInvalid := True; FTargetStrengthInvalid := True; end;

procedure TCombatObject.AddTarget(Target: TCombatObject; CV, WallCV, DV: Integer);
begin
  Assert(FTargets.IndexOfItemA(Integer(Target)) = -1, 'target already exists use update target');
  Inc(FCombatValue, CV);
  Inc(FWallCombatValue, WallCV);
  FTargets.AddABCD(Integer(Target), CV, WallCV, DV);
  Target.FTargetedBy.AddABCD(Integer(Self), CV, WallCV, DV);
  Inc(Target.FIncomingCombatValue, CV);
  Inc(Target.FIncomingWallCombatValue, WallCV);
  if CV > 0 then
  begin Inc(FTargetCount); Inc(Target.FAttackerCount); end;
  if WallCV > 0 then
  begin Inc(FWallTargetCount); Inc(Target.FWallAttackerCount); end;
  TargetsChanged;
  Target.TargetsChanged;
end;

procedure TCombatObject.DeleteTarget(Index: Integer);
var Target: TCombatObject; CV, DV: Integer;
begin
  if Index <> -1 then
  begin
    Target := TCombatObject(FTargets.List^[Index].A);
    CV := FTargets.List^[Index].B;
    DV := FTargets.List^[Index].C;
    Dec(FCombatValue, CV);
    Dec(FWallCombatValue, DV);
    FTargets.Delete(Index);
    if CV > 0 then Dec(FTargetCount);
    if DV > 0 then Dec(FWallTargetCount);
    TargetsChanged;
    Index := Target.FTargetedBy.IndexOfItemA(Integer(Self));
    if Index <> -1 then
    begin
      Dec(Target.FIncomingCombatValue, Target.FTargetedBy.List^[Index].B);
      { Original bug: FIncomingWallCombatValue is not decremented. }
      Target.FTargetedBy.Delete(Index);
      if CV > 0 then Dec(Target.FAttackerCount);
      if DV > 0 then Dec(Target.FWallAttackerCount);
      Target.TargetsChanged;
    end;
  end;
end;

procedure TCombatObject.RemoveTarget(Target: TCombatObject);
begin DeleteTarget(FTargets.IndexOfItemA(Integer(Target))); end;

procedure TCombatObject.ResetTargets;
var I: Integer;
begin
  for I := FTargets.Count - 1 downto 0 do DeleteTarget(I);
end;

procedure TCombatObject.GetTargetCVDV(Target: TCombatObject; var CV, DV: Integer);
begin CV := 0; DV := 0; end;

function TCombatObject.GetTargetWallCV(Target: TCombatObject): Integer;
begin Result := 0; end;

function TCombatObject.GetTargetPriority: Integer;
var I, CV: Integer; Target: TCombatObject; Count: Integer;
begin
  if FTargetPriorityInvalid then
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
    FTargetPriority := (Count + 2) * FTargetPriority;
    I := FTargetedBy.Count;
    { Original bug: the normalized priority is stored in FTargetStrength. }
    if I <> 0 then FTargetStrength := FTargetPriority div I
    else FTargetStrength := 0;
    FTargetPriorityInvalid := False;
  end;
  Result := FTargetPriority;
end;

function TCombatObject.GetTargetStrength: Integer;
var I: Integer;
begin
  if FTargetStrengthInvalid then
  begin
    FTargetStrength := 0;
    for I := TQuadItemList(FTargets).Count - 1 downto 0 do
      Inc(FTargetStrength, TQuadItemList(FTargets).List^[I].D);
    if FTargetStrength <> 0 then FTargetStrength := FTargetStrength div TQuadItemList(FTargets).Count;
    FTargetStrengthInvalid := False;
    Result := FTargetStrength;
    Exit;
  end;
  Result := FTargetStrength;
end;

procedure TCombatObject.SetupTargets;
var I, CV, DV, WallCV: Integer; Target: TCombatObject; Side: TCombatSide;
begin
  Side := FCombat.FSides[GetOpponentSide];
  for I := Side.Count - 1 downto 0 do
  begin
    Target := Side.GetObjects(I);
    if not (csDestroyed in Target.FStatus) then
    begin
      GetTargetCVDV(Target, CV, DV);
      if TCombatData(FCombat.FCombatData).FWallType <> 0 then WallCV := GetTargetWallCV(Target)
      else WallCV := 0;
      AddTarget(Target, CV, WallCV, DV);
    end;
  end;
end;

procedure TCombatObject.ObjectSideChanged(A1: Integer);
var CV, DV, WallCV: Integer;
begin
  if TCombatObject(A1).GetSide <> GetSide then
  begin
    GetTargetCVDV(TCombatObject(A1), CV, DV);
    if TCombatData(FCombat.FCombatData).FWallType <> 0 then WallCV := GetTargetWallCV(TCombatObject(A1))
    else WallCV := 0;
    AddTarget(TCombatObject(A1), CV, WallCV, DV);
  end
  else RemoveTarget(TCombatObject(A1));
end;

function TCombatObject.fcExecute(A1: Integer): Boolean;
begin Result := False; end;

function TCombatObject.fcBehindWall: Boolean;
begin Result := False; end;

function TCombatObject.fcWallInBetween(A1: Byte): Boolean;
begin Result := False; end;

function TCombatObject.fcRoundDistance: Integer;
begin Result := 0; end;

function TCombatObject.GetVisibilityRange: Integer;
begin Result := 0; end;

procedure TCombatObject.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FPosition, $A);
  Stream.rwByte(Byte(FCombatPlayer), $C);
  Stream.rwData(FStatus, 1, $D);
  Stream.rwData(FID, 1, $E);
  if smRead in Stream.StorageMode then FStatus := FStatus - [csActivated];
end;

function TCombatObject.WallCombatFeatures: TWallCombatFeatures;
begin Result := []; end;

function TCombatObject.GetEnabled: Boolean;
begin Result := [csDestroyed, csFled] * FStatus = []; end;

function TCombatObject.GetSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(FCombatPlayer);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Player).F_CombatPlayer_0A)
  else Result := csNeutral;
end;

function TCombatObject.GetOpponentSide: TCombatSideIndex;
var Player: Shortint;
begin
  Player := Shortint(FCombatPlayer);
  if Player <> -1 then
    Result := TCombatSideIndex(TCombatPlayerList(TCombatData(TCombat(FCombat).FCombatData).FPlayers).GetPlayers(Player).F_CombatPlayer_0A xor 1)
  else Result := csNeutral;
end;

procedure TCombatObject.NewTurn(A1: Byte);
begin if A1 = FCombatPlayer then FStatus := FStatus - [csTurnDone]; end;

procedure TCombatObject.NewRound;
begin end;

procedure TCombatObject.CombatDone;
begin end;

procedure TCombatObject.TurnDone;
var A: TCombatObjectTurnDoneCA;
begin
  A := TCombatObjectTurnDoneCA.Create(nil);
  A.F_CombatObjectTurnDoneCA_0C := FID;
  TCombat(FCombat).ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombatObject.Activate(A1: Integer);
var Player: Byte; Combat: TCombat;
begin
  FCombat := TCombat(A1);
  FStatus := FStatus + [csActivated];
  Player := FCombatPlayer;
  if Player <> $FF then
  begin
    Combat := FCombat;
    Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(Player).F_CombatPlayer_0A)].AddChild(Self);
  end;
end;

procedure TCombatObject.Deactivate;
var Player: Byte; Combat: TCombat;
begin
  FStatus := FStatus - [csActivated];
  Player := FCombatPlayer;
  if Player <> $FF then
  begin
    Combat := FCombat;
    Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(Player).F_CombatPlayer_0A)].RemoveChild(Self);
  end;
end;

procedure TCombatObject.Initialize(A1: Integer);
begin FCombat := TCombat(A1); end;

procedure TCombatObject.Finalize(A1: TFinalizeMode);
begin Destroy; end;

procedure TCombatObject.PlaySFX(A1: Byte);
begin end;

function TCombatObject.GetLocked: Boolean;
begin Result := False; end;

procedure TCombatObject.SetCombatPlayer(Player: Byte);
var ChangedSide: Boolean; Combat: TCombat;
begin
  if csActivated in FStatus then
  begin
    ChangedSide := (Player <> $FF) and
      (TCombatSideIndex(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).F_CombatPlayer_0A) <> GetSide);
    if FCombatPlayer <> $FF then
    begin
      Combat := FCombat;
      Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(FCombatPlayer).F_CombatPlayer_0A)].RemoveChild(Self);
    end;
    FCombatPlayer := Player;
    if FCombatPlayer <> $FF then
    begin
      Combat := FCombat;
      Combat.FSides[TCombatSideIndex(TCombatPlayerList(TCombatData(Combat.FCombatData).FPlayers).GetPlayers(FCombatPlayer).F_CombatPlayer_0A)].AddChild(Self);
    end;
    if ChangedSide then
    begin
      ResetTargets;
      SetupTargets;
      FCombat.ObjectSideChanged(Integer(Self));
    end;
  end
  else FCombatPlayer := Player;
end;

function TCombatObject.GetAttack: Shortint;
begin Result := 0; end;

function TCombatObject.GetDefense: Shortint;
begin Result := 0; end;

function TCombatObject.GetResistance: Shortint;
begin Result := 0; end;

function TCombatObject.GetDamage: Shortint;
begin Result := 0; end;

function TCombatObject.GetImmunityTypes: TDamageTypes;
begin Result := []; end;

function TCombatObject.GetProtectionTypes: TDamageTypes;
begin Result := []; end;

function TCombatObject.GetMoves: Integer;
begin Result := 0; end;

function TCombatObject.GetHits: Byte;
begin Result := 0; end;

procedure TCombatObject.SetHitPoints(A1: Byte);
begin end;

function TCombatObject.GetHitPoints: Shortint;
begin Result := 0; end;

function TCombatObject.GetExperience: Integer;
begin Result := 0; end;

procedure TCombatObject.SetExperience(A1: Integer);
begin end;

function TCombatObject.GetLevel: Byte;
begin Result := 0; end;

function TCombatObject.IDStr: string;
begin Result := 'TCombatObject'; end;

function TCombatObject.GetAlignment: TAlignment;
begin Result := alNone; end;

function TCombatObject.GetAbilityOwner: TAbilityOwner;
begin Result := nil; end;

function TCombatObject.GetAbilityEnabled(A1: Integer): Boolean;
begin Result := False; end;

procedure TCombatObject.SetAbilityEnabled(A1: Integer; A2: Boolean);
begin end;

function TCombatObject.GetAbilityLevel(A1: Integer): Integer;
begin Result := 0; end;

function TCombatObject.GetAbilityCount: Integer;
begin Result := 0; end;

function TCombatObject.GetPlayer: Shortint;
var Player: Byte;
begin
  Player := FCombatPlayer;
  if Player <> $FF then Result := Shortint(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).FPlayer)
  else Result := -1;
end;

function TCombatObject.GetPlayerIR: Shortint;
var Player: Byte;
begin
  Player := FCombatPlayer;
  if Player <> $FF then Result := Shortint(TCombatPlayerList(TCombatData(FCombat.FCombatData).FPlayers).GetPlayers(Player).FIndependentRelation)
  else Result := -1;
end;

procedure TCombatObject.ObjectDestroyed(A1: Integer);
begin
  if TCombatObject(A1).GetSide <> GetSide then RemoveTarget(TCombatObject(A1));
end;

function TCombatObject.SupportCombatMode(Modes: TCombatModes): Boolean;
begin Result := False; end;

function TCombatObject.GetOptimalDamageType(Types: TDamageTypes): TDamageType;
var Available, Protection: TDamageTypes;
begin
  Result := dtNone;
  Available := Types - GetImmunityTypes;
  if Available <> [] then
  begin
    Protection := GetProtectionTypes;
    if (Protection = []) or (Available - Protection = []) then
      while not (Result in Available) do Dec(Result)
    else
      while not (Result in Available) or (Result in Protection) do Dec(Result);
  end;
end;

function TCombatObject.ExecuteDamageRole(A1: Integer; A2: Integer; A3: TDamageTypes): Integer;
var Types: TDamageTypes; Attack: Integer;
begin
  Result := 0;
  Types := A3 - GetImmunityTypes;
  if Types <> [] then
  begin
    Attack := A1 - GetDefense;
    Result := AoWE.ExecuteDamageRole(A2, Attack);
    if Types - GetProtectionTypes = [] then Result := (Result + 1) div 2;
  end;
end;

function TCombatObject.ExecuteDamageRoleEx(A1: Integer; A2: Integer; A3: TDamageTypes; A4: Byte): Integer;
var Types: TDamageTypes; Attack: Integer;
begin
  Result := 0;
  Types := A3 - GetImmunityTypes;
  if Types <> [] then
  begin
    if A4 = 1 then Attack := A1 - GetResistance else Attack := A1 - GetDefense;
    Result := AoWE.ExecuteDamageRole(A2, Attack);
    if Types - GetProtectionTypes = [] then Result := (Result + 1) div 2;
  end;
end;

function TCombatObject.ExecuteDamageEffects(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

function TCombatObject.ExecuteDamageEffectsRole(A1: TDamageTypes): TDamageTypes;
begin Result := []; end;

function TCombatObject.DoDamage(A1: TCombatObject; A2: Integer): Integer;
begin
  if (A2 <> 0) and TCombatObject(A1).GetEnabled then
  begin
    Result := TCombatObject(A1).ExecuteDamage(A2);
    if (csDestroyed in TCombatObject(A1).FStatus) and
      not TCombatObject(A1).GetAbilityEnabled($81) and
      not TCombatObject(A1).GetAbilityEnabled($80) then
      SetExperience(GetExperience + TCombatObject(A1).GetLevel);
  end
  else Result := 0;
end;

procedure TCombatObject.DestroyObject;
var I: Integer;
begin
  SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  for I := GetAbilityCount - 1 downto 0 do
    if GetAbilityEnabled(I) then AoWHSSet.FAbilityControl.GetAbility(I).CombatObjectDestroyed(Self);
  if csDestroyed in FStatus then
  begin
    ResetTargets;
    FCombat.ObjectDestroyed(Integer(Self));
  end;
end;

procedure TCombatObject.Surrender;
begin
  SetHitPoints(0);
  FStatus := FStatus + [csDestroyed];
  ResetTargets;
  FCombat.ObjectDestroyed(Integer(Self));
end;

function TCombatObject.ExecuteDamage(A1: Integer): Integer;
var Hits: Integer;
begin
  Assert((A1 >= 0) and (A1 < 50), 'Invalid Damage Value (TCombatUnit.ExecuteDamage)');
  Hits := GetHitPoints;
  if A1 > Hits then Result := Hits else Result := A1;
  SetHitPoints(Hits - Result);
  if A1 <> 0 then FStatus := FStatus + [csDamaged];
  if (Result <> 0) and (GetHitPoints = 0) then DestroyObject;
end;

procedure TCombatObject.Show(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc);
begin end;

function TCombatObject.ShowAttackAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

function TCombatObject.ShowHitAnimation(Frame: Integer; Direction: Integer; X, Y: Integer; const Surface: TSurfaceDesc): Integer;
begin Result := 0; end;

constructor TCombatSide.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

procedure TCombatSide.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); end;

destructor TCombatSide.Destroy;
begin inherited Destroy; end;

function TCombatSide.GetObjects(A1: Integer): TCombatObject;
begin Result := TCombatObject(FChildren.List^[A1]); end;

function TCombatSide.IndexOfID(A1: Integer): Integer;
begin
  for Result := Count - 1 downto 0 do
    if TCombatObject(FChildren.List^[Result]).FID = A1 then Exit;
  Result := -1;
end;

function TCombatSide.GetDestroyedObjects: Integer;
var I: Integer;
begin
  Result := 0;
  for I := Count - 1 downto 0 do
    if csDestroyed in TCombatObject(FChildren.List^[I]).FStatus then Inc(Result);
end;

function TCombatSide.GetUndestroyedConquerObjects: Integer;
var I: Integer; Obj: TCombatObject;
begin
  Result := 0;
  for I := Count - 1 downto 0 do
  begin
    Obj := TCombatObject(FChildren.List^[I]);
    if ([csDestroyed, csFled] * Obj.FStatus = []) and
      (cmConquerObject in Obj.FControlMode) then Inc(Result);
  end;
end;

procedure TCombatSide.OutputDebugInfo;
var I: Integer; S: string;
begin
  if FSideIndex = 0 then AoWEngine.OutputDebugMessage(CombatDID, '--- Combat Side Attacker ---')
  else AoWEngine.OutputDebugMessage(CombatDID, '--- Combat Side Defender ---');
  for I := 0 to FChildren.Count - 1 do
  begin
    S := '(' + IntToStr(I) + '):' + GetObjects(I).IDStr + ' (Priority:' +
      IntToStr(GetObjects(I).GetTargetPriority) + '/Strength:' +
      IntToStr(GetObjects(I).GetTargetStrength) + ')';
    AoWEngine.OutputDebugMessage(CombatDID, S);
  end;
end;

procedure TCombatSide.UpdateSettings;
var I, N: Integer; Obj: TCombatObject;
begin
  FStrength := 0;
  FConquerCount := 0;
  for I := FChildren.Count - 1 downto 0 do
  begin
    Obj := TCombatObject(FChildren.List^[I]);
    N := TQuadItemList(Obj.FTargets).Count;
    if N > 0 then Inc(FStrength, Obj.FCombatValue div N);
    if (TQuadItemList(Obj.FTargetedBy).Count > 0) and
      (Obj.FAttackerCount = 0) then Inc(FConquerCount);
  end;
end;

constructor TCombat.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FExecutedEvents := TEventList.Create;
  FSides[csAttacker] := TCombatSide.Create(nil);
  FSides[csDefender] := TCombatSide.Create(nil);
  TCombatSide(FSides[csAttacker]).FSideIndex := 0;
  TCombatSide(FSides[csDefender]).FSideIndex := 1;
  TCombatSide(FSides[csAttacker]).FOpponent := TCombatSide(FSides[csDefender]);
  TCombatSide(FSides[csDefender]).FOpponent := TCombatSide(FSides[csAttacker]);
  FCombatData := TCombatData.Create(nil);
  FLogbook := TCombatLogbook.Create(nil);
  Clear;
end;

destructor TCombat.Destroy;
begin
  if cActivated in FStatus then Deactivate;
  if cExecuting in FStatus then Finalize;
  TObject(FExecutedEvents).Free;
  TObject(FSides[csAttacker]).Free;
  TObject(FSides[csDefender]).Free;
  TObject(FCombatData).Free;
  TCombatLogbook(FLogbook).Release;
  inherited Destroy;
end;

function TCombat.GetLogCombatActions: Boolean;
begin Result := cLogCombatActions in FStatus; end;

procedure TCombat.SetLogCombatActions(A1: Byte);
begin
  if A1 <> 0 then FStatus := FStatus + [cLogCombatActions]
  else FStatus := FStatus - [cLogCombatActions];
end;

procedure TCombat.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(FSides[csAttacker]), $0A);
  Stream.rwEObject(TEObject(FSides[csDefender]), $0B);
  Stream.rwCreateEObject(TEObject(FLogbook), nil, $0C);
  Stream.rwEObject(TEObject(FCombatData), $0D);
end;

function TCombat.GetRound: Integer;
begin Result := TCombatData(FCombatData).F_CombatData_44; end;

procedure TCombat.ExecuteCombatAction(A1: TCombatAction);
begin
  if cLogCombatActions in FStatus then TCombatActionList(TCombatLogbook(FLogbook).FActions).AddChild(TCombatAction(A1));
  TCombatAction(A1).Execute(Self);
end;

function TCombat.PlayerTypeInvolved(Types: TPlayerTypes): Boolean;
var I: Integer;
begin
  Result := False;
  for I := 0 to TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).Count - 1 do
    if TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).GetParty(I) <> nil then
      if AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(TCombatData(FCombatData).FPlayers).GetPlayers(
        Shortint(TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).GetParty(I).F_CombatParty_1A)).FPlayer)).FPlayerType in Types then Result := True;
end;

function TCombat.CreateUniqueCOID: Byte;
begin Result := FNextCOID; Inc(FNextCOID); end;

procedure TCombat.Clear;
begin
  inherited Clear;
  TCombatLogbook(FLogbook).Clear;
  FNextCOID := 1;
  TCombatData(FCombatData).Clear;
  FStatus := [];
end;

function TCombat.Setup(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer; A6: Byte; A7: Byte; A8: Integer; A9: Integer; A10: Integer; A11: Boolean): Boolean;
var Data: TCombatData;
begin
  Clear;
  if A11 then FStatus := FStatus + [cLogCombatActions]
  else FStatus := FStatus - [cLogCombatActions];
  Data := FCombatData;
  Data.F_CombatData_08 := A8;
  Data.F_CombatData_0C := A9;
  Data.F_CombatData_10 := A10;
  Data.F_CombatData_14 := A3;
  Data.F_CombatData_18 := A4;
  Data.F_CombatData_1C := A5;
  Data.FAttackerPlayer := AddCombatPlayer(A1, A2, csAttacker);
  Data.FDefenderPlayer := AddCombatPlayer(A6, A7, csDefender);
  Data.F_CombatData_20[0] := AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).TerrainType;
  Data.F_CombatData_20[1] := AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).OverlayType;
  Result := True;
end;

function TCombat.CreateCombatUnit: Integer;
begin
  Result := Integer(TFastCombatUnit.Create(nil));
  TCombatUnit(Result).FID := CreateUniqueCOID;
end;

procedure TCombat.NewRound;
var A: TNewCombatRoundCA;
begin
  A := TNewCombatRoundCA.Create(nil);
  ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombat.UpdateSidesSettings;
begin TCombatSide(FSides[csAttacker]).UpdateSettings; TCombatSide(FSides[csDefender]).UpdateSettings; end;

procedure TCombat.NewTurn(A1: Byte);
var A: TNewCombatTurnCA;
begin
  A := TNewCombatTurnCA.Create(nil);
  A.F_NewCombatTurnCA_0C := A1;
  ExecuteCombatAction(A);
  A.Release;
  UpdateSidesSettings;
end;

procedure TCombat.NextTurn;
var I: Integer;
begin
  if TByteList(TCombatData(FCombatData).F_CombatData_40).Count <> 0 then
  begin
    I := TByteList(TCombatData(FCombatData).F_CombatData_40).IndexOf(TCombatData(FCombatData).FCurrentPlayer) + 1;
    if I >= TByteList(TCombatData(FCombatData).F_CombatData_40).Count then I := 0;
    NewTurn(TByteList(TCombatData(FCombatData).F_CombatData_40)[I]);
  end;
end;

procedure TCombat.Terminate;
begin
  if not FTerminated then
  begin
    FTerminated := True;
    if Assigned(FOnTerminated) then FOnTerminated(Self);
  end;
end;

procedure TCombat.CheckTerminate;
begin
  if not FTerminated then
    if (TCombatSide(FSides[csAttacker]).GetUndestroyedConquerObjects = 0) or
      (TCombatSide(FSides[csDefender]).GetUndestroyedConquerObjects = 0) or
      (TByteList(TCombatData(FCombatData).F_CombatData_2C).Count <> 0) then Terminate;
end;

procedure TCombat.ObjectSideChanged(A1: Integer);
var I: Integer;
begin
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    if not (csDestroyed in TCombatObject(A1).FStatus) then
      TCombatData(FCombatData).GetObjects(I).ObjectSideChanged(A1);
  CheckTerminate;
end;

procedure TCombat.ObjectDestroyed(A1: Integer);
var I: Integer;
begin
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).ObjectDestroyed(A1);
  TEventList(FExecutedEvents).TriggerNotifyEvents(Self);
  CheckTerminate;
end;

procedure TCombat.SetLogbookHeader(A1: string);
var A: TUpdateHeaderCA;
begin
  A := TUpdateHeaderCA.Create(nil);
  A.F_UpdateHeaderCA_0C := A1;
  ExecuteCombatAction(A);
  A.Release;
end;

procedure TCombat.AddAdjacentArmies;
var Data: TCombatData; Level: TMapLevel; Walk: THNWalkData;
    ArmyHS: TArmyHS; Side: TCombatSideIndex;
begin
  Data := FCombatData;
  Level := AoWHSMap.MapContainer.GetMapLevel(Data.F_CombatData_10);
  InitHNWalk(Walk, Data.F_CombatData_08, Data.F_CombatData_0C, 0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.Y >= 0) and (Walk.X < Level.Width) and (Walk.Y < Level.Height) then
    begin
      ArmyHS := TArmyHS(Level.GetField(Walk.X, Walk.Y).FindOwnedChild($20217));
      if ArmyHS <> nil then
      begin
        if Walk.HN <> 0 then
          Side := GetCombatSide(
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FIndependentRelation,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
            TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
            ArmyHS.FArmy.FPlayer, ArmyHS.FArmy.FIndependentRelation)
        else Side := csDefender;
        if Side <> csNeutral then
          AddArmy(ArmyHS.FArmy, Side, Walk.X, Walk.Y, Data.F_CombatData_10);
      end
      else if Walk.HN = 0 then
        AddEmptyArmy(
          TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
          TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
          Walk.X, Walk.Y, Data.F_CombatData_10);
    end;
    WalkToNextHN(Walk);
  end;
end;

function TCombat.GetPartyPosition(X, Y, Layer: Integer): Byte;
var Data: TCombatData;
begin
  Data := TCombatData(FCombatData);
  if (Layer = Data.F_CombatData_10) and (dHXtoRad(Data.F_CombatData_08,Data.F_CombatData_0C,X,Y) <= 1) then
    Result := dHXtoHNfast(Data.F_CombatData_08,Data.F_CombatData_0C,X,Y)
  else Result := 7;
end;

function TCombat.CreateCombatPlayer: Integer;
begin Result := Integer(TCombatPlayer.Create(nil)); end;

function TCombat.AddCombatPlayer(A1: Byte; A2: Byte; A3: TCombatSideIndex): Byte;
var Player: TCombatPlayer;
begin
  Player := TCombatPlayer(CreateCombatPlayer);
  Player.SetOwner(TCombatPlayerList(FCombatData.FPlayers));
  Player.FPlayer := A1;
  Player.FIndependentRelation := A2;
  Player.F_CombatPlayer_0A := Ord(A3);
  Result := TCombatPlayerList(FCombatData.FPlayers).Count - 1;
end;

function TCombat.AddArmy(A1: TArmy; A2: TCombatSideIndex; A3: Integer; A4: Integer; A5: Integer): TCombatParty;
var Party: TCombatParty; Valid, Transport: Boolean; Player, Position: Byte;
    Index, I: Integer; UnitObj: TCombatUnit; Msg: TMapFieldMsg; Data: TCombatData;
    Transporter: TAbstractUnit;
begin
  A1.BeginUpdate;
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1.FPlayer, A1.FIndependentRelation);
  if Player = $FF then Player := AddCombatPlayer(A1.FPlayer, A1.FIndependentRelation, A2);
  Position := GetPartyPosition(A3, A4, A5);
  Party := TCombatPartyList(FCombatData.F_CombatData_3C).CreateParty(Integer(Self), Position, Player, A3, A4, A5, Integer(A1));
  Transporter := A1.Transporter($FF);
  Transport := (Transporter <> nil) and Transporter.ValidTerrain(FCombatData.F_CombatData_20[0], FCombatData.F_CombatData_20[1]);
  Index := 0;
  for I := A1.Count - 1 downto 0 do
  begin
    Valid := A1.GetUnit(I).ValidTerrain(FCombatData.F_CombatData_20[0], FCombatData.F_CombatData_20[1]);
    if Valid or Transport then
    begin
      UnitObj := TCombatUnit(CreateCombatUnit);
      UnitObj.Setup(CreateUniqueCOID, Ord(A2), A1.GetUnit(I), (Position shl 4) + Index, Player);
      if not Valid then
      begin
        UnitObj.FDisabled := True;
        UnitObj.FControlMode := UnitObj.FControlMode - [cmConquerObject];
      end;
      FCombatData.AddObject(UnitObj);
      Inc(Index);
    end;
  end;
  if A3 <> -1 then
  begin
    Msg.MsgID := $1123;
    Msg.Param[0] := Integer(AoWHSMap.MapContainer.GetField(A3, A4, A5));
    Msg.Result := 0;
    Data := FCombatData;
    AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).SendMapFieldMsg(Msg);
    if Msg.Result <> 0 then Party.F_CombatParty_18 := Msg.Result;
  end;
  A1.EndUpdate;
  Result := Party;
end;

function TCombat.AddArmyEx(A1: TArmy; A2: TCombatSideIndex; A3: Integer; A4: Integer; A5: Integer; A6: Byte): TCombatParty;
var Party: TCombatParty; Player: Byte; Index, I: Integer; UnitObj: TCombatUnit;
begin
  A1.BeginUpdate;
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1.FPlayer, A1.FIndependentRelation);
  if Player = $FF then Player := AddCombatPlayer(A1.FPlayer, A1.FIndependentRelation, A2);
  Party := TCombatPartyList(FCombatData.F_CombatData_3C).CreateParty(Integer(Self), A6, Player, A3, A4, A5, Integer(A1));
  Index := 0;
  for I := A1.Count - 1 downto 0 do
  begin
    UnitObj := TCombatUnit(CreateCombatUnit);
    UnitObj.Setup(CreateUniqueCOID, Ord(A2), A1.GetUnit(I), (A6 shl 4) + Index, Player);
    FCombatData.AddObject(UnitObj);
    Inc(Index);
  end;
  A1.EndUpdate;
  Result := Party;
end;

procedure TCombat.AddEmptyArmy(A1: Byte; A2: Byte; A3: Integer; A4: Integer; A5: Integer);
var Data: TCombatData; Position, Player: Byte; Side: TCombatSideIndex; Party: TCombatParty; Msg: TMapFieldMsg;
begin
  Data := FCombatData;
  Position := GetPartyPosition(A3, A4, A5);
  Side := GetCombatSide(
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FIndependentRelation,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
    TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
    A1, A2);
  Player := TCombatPlayerList(FCombatData.FPlayers).IndexOf(A1, A2);
  if Player = $FF then Player := AddCombatPlayer(A1, A2, Side);
  Party := TCombatPartyList(FCombatData.F_CombatData_3C).CreateParty(Integer(Self), Position, Player, A3, A4, A5, 0);
  Msg.MsgID := $1123;
  Msg.Param[0] := Integer(AoWHSMap.MapContainer.GetField(A3, A4, A5));
  Msg.Result := 0;
  AoWHSMap.MapContainer.GetField(A3, A4, A5).SendMapFieldMsg(Msg);
  if Msg.Result <> 0 then Party.F_CombatParty_18 := Msg.Result;
end;

procedure TCombat.InitDefaultArmies(Army: TArmy; X, Y, L: Integer);
var Data: TCombatData; ArmyHS: TArmyHS;
begin
  Data := FCombatData;
  if GetPartyPosition(X, Y, L) = 7 then
  begin
    FExplorationSite := 2;
    AddArmy(Army, csAttacker, X, Y, L);
    ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).FindOwnedChild($20217));
    if ArmyHS <> nil then
      AddArmy(ArmyHS.FArmy, csDefender, Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10)
    else
      AddEmptyArmy(
        TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer,
        TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FIndependentRelation,
        Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10);
  end
  else AddAdjacentArmies;
end;

procedure TCombat.Initialize;
var I, J: Integer; Wall: TCombatWall; WallType, Player: Byte;
begin
  LockExecuted;
  FStatus := FStatus + [cExecuting];
  WallType := 0;
  J := 0;
  while (WallType = 0) and (J <> TCombatPartyList(FCombatData.F_CombatData_3C).Count) do
  begin
    if TCombatPartyList(FCombatData.F_CombatData_3C).GetParty(J) <> nil then
      WallType := TCombatPartyList(FCombatData.F_CombatData_3C).GetParty(J).F_CombatParty_18;
    Inc(J);
  end;
  if WallType <> 0 then
  begin
    Wall := TCombatWall.Create(nil);
    Wall.Setup(CreateUniqueCOID, WallType, FCombatData.FDefenderPlayer);
    FCombatData.AddObject(Wall);
  end;
  if TCombatPartyList(FCombatData.F_CombatData_3C).GetParty(0) <> nil then
    FCombatData.FWallType := TCombatPartyList(FCombatData.F_CombatData_3C).GetParty(0).F_CombatParty_18;
  TByteList(FCombatData.F_CombatData_40).Add(FCombatData.FDefenderPlayer);
  for I := 0 to TCombatPlayerList(FCombatData.FPlayers).Count - 1 do
  begin
    Player := I;
    if (TByteList(FCombatData.F_CombatData_40).IndexOf(Player) = -1) and
      (TCombatPlayerList(FCombatData.FPlayers).GetPlayers(Player).F_CombatPlayer_0A = 1) then
      TByteList(FCombatData.F_CombatData_40).Add(Player);
  end;
  TByteList(FCombatData.F_CombatData_40).Add(FCombatData.FAttackerPlayer);
  for I := 0 to TCombatPlayerList(FCombatData.FPlayers).Count - 1 do
  begin
    Player := I;
    if (TByteList(FCombatData.F_CombatData_40).IndexOf(Player) = -1) and
      (TCombatPlayerList(FCombatData.FPlayers).GetPlayers(Player).F_CombatPlayer_0A = 0) then
      TByteList(FCombatData.F_CombatData_40).Add(Player);
  end;
  for I := FCombatData.GetCount - 1 downto 0 do FCombatData.GetObjects(I).Initialize(Integer(Self));
  TCombatLogbook(FLogbook).SetInitialData(FCombatData);
end;

procedure TCombat.Finalize;
var I, PlayerIndex, ArmyIndex, UnitIndex: Integer; Player: TPlayer;
    Alive: Boolean; Mode: TFinalizeMode; Data: TCombatData; Msg: TMapFieldMsg;
begin
  Assert(FStatus * [cExecuting, cActivated] = [cExecuting], 'Combat Finalize Failure');
  for I := 0 to TByteList(FCombatData.F_CombatData_2C).Count - 1 do
  begin
    Data := FCombatData;
    AoWHSMap.GameOver(TCombatPlayerList(Data.FPlayers).GetPlayers(TByteList(Data.F_CombatData_2C)[I]).FPlayer, goLost);
    TCombatLogbook(FLogbook).F_CombatLogbook_19 := True;
  end;
  TCombatLogbook(FLogbook).SetFinalData(FCombatData);
  FStatus := FStatus - [cExecuting];
  Data := FCombatData;
  for I := Data.GetCount - 1 downto 0 do FCombatData.GetObjects(I).CombatDone;
  for Mode := fmOriginal to fmAll do
    for I := Data.GetCount - 1 downto 0 do FCombatData.GetObjects(I).Finalize(Mode);
  TCombatLogbook(FLogbook).FFinalData.FHeader := GetCombatResultText;
  TCombatLogbook(FLogbook).FFinalData.F_CombatData_30 := Ord(FCombatResult);
  PlayerIndex := TCombatPlayerList(FCombatData.FPlayers).Count;
  while (PlayerIndex <> 0) and not TCombatLogbook(FLogbook).F_CombatLogbook_19 do
  begin
    Dec(PlayerIndex);
    Player := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(FCombatData.FPlayers).GetPlayers(PlayerIndex).FPlayer));
    ArmyIndex := Player.FArmies.Count;
    Alive := False;
    while (ArmyIndex <> 0) and not Alive do
    begin
      Dec(ArmyIndex);
      UnitIndex := Player.FArmies.GetArmy(ArmyIndex).Count;
      while not Alive and (UnitIndex <> 0) do
      begin
        Dec(UnitIndex);
        Alive := Player.FArmies.GetArmy(ArmyIndex).GetUnit(UnitIndex).GetHitPoints <> 0;
      end;
    end;
    TCombatLogbook(FLogbook).F_CombatLogbook_19 := not Alive;
  end;
  Data := FCombatData;
  if Data.F_CombatData_08 <> -1 then
  begin
    Msg.MsgID := $1110;
    Msg.Param[0] := Integer(Self);
    Msg.Result := 0;
    AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).SendMapFieldMsg(Msg);
  end;
  UnlockExecuted;
end;

procedure TCombat.LockExecuted;
begin Inc(FExecutedLock); end;

procedure TCombat.UnlockExecuted;
begin
  Dec(FExecutedLock);
  if (FExecutedLock = 0) and Assigned(FOnExecuted) then FOnExecuted(Self);
end;

procedure TCombat.Activate;
var I: Integer;
begin
  Assert(not (cActivated in FStatus), 'Combat already activated');
  FStatus := FStatus + [cActivated];
  TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).Activate(Integer(Self));
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Activate(Integer(Self));
  if cExecuting in FStatus then
  begin
    for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
      TCombatData(FCombatData).GetObjects(I).SetupTargets;
    UpdateSidesSettings;
  end;
end;

procedure TCombat.Deactivate;
var I: Integer;
begin
  Assert(cActivated in FStatus, 'Combat Failure during Deactivating');
  FStatus := FStatus - [cActivated];
  for I := TCombatData(FCombatData).GetCount - 1 downto 0 do
    TCombatData(FCombatData).GetObjects(I).Deactivate;
  TCombatPartyList(TCombatData(FCombatData).F_CombatData_3C).Deactivate(Integer(Self));
end;

function TCombat.Execute: Byte;
begin
  RandSeed := AoWHSMap.Random($FFFFFF);
  Result := 0;
end;

procedure TCombat.UpdateStatus;
var Attackers, Defenders, I: Integer;
begin
  Attackers := FSides[csAttacker].GetUndestroyedConquerObjects;
  Defenders := FSides[csDefender].GetUndestroyedConquerObjects;
  if (Attackers <> 0) and (Defenders = 0) then FCombatResult := crVictory
  else if (Attackers = 0) and (Defenders <> 0) then FCombatResult := crDefeat
  else if (Attackers = 0) and (Defenders = 0) then FCombatResult := crBothDefeated
  else if (Attackers <> 0) and (Defenders <> 0) and (Ord(FCombatResult) <> 7) then
    FCombatResult := crCannotInflictDamage;
  case Ord(FCombatResult) of
    4..5:
      for I := FCombatData.GetCount - 1 downto 0 do
        if csFled in FCombatData.GetObjects(I).FStatus then FCombatResult := crFled;
  end;
end;

function TCombat.GetCombatResultText: string;
var Data: TCombatData; Msg: TMapFieldMsg;
begin
  Result := '';
  Msg.MsgID := $1109;
  Msg.Result := Integer(@Result);
  Msg.Param[0] := Integer(Self);
  Data := FCombatData;
  AoWHSMap.MapContainer.GetField(Data.F_CombatData_08, Data.F_CombatData_0C, Data.F_CombatData_10).SendMapFieldMsg(Msg);
  if Result = '' then
    if FCombatResult = crVictory then Result := TranslateRStr(BattleWonRStr)
    else if FCombatResult = crDefeat then Result := TranslateRStr(BattleLostRStr)
    else if FCombatResult = crCannotBreachWall then Result := TranslateRStr(CannotBreachWallRStr)
    else if FCombatResult = crCannotInflictDamage then Result := TranslateRStr(CannotInflictDamageRStr)
    else Result := TranslateRStr(BattleDrawnRStr);
end;

function TCombat.DefendersAvailable: Boolean;
var I: Integer; Obj: TCombatObject;
begin
  Result := False;
  I := 0;
  while not Result and (I <> TCombatData(FCombatData).GetCount) do
  begin
    Obj := TCombatData(FCombatData).GetObjects(I);
    Result := (Obj.FCombatPlayer <> $FF) and
      (TCombatPlayerList(TCombatData(FCombatData).FPlayers).GetPlayers(Shortint(Obj.FCombatPlayer)).F_CombatPlayer_0A = 1) and
      not (csDestroyed in Obj.FStatus);
    Inc(I);
  end;
end;

destructor TCombatTypeRequestEventLog.Destroy;
var Obj: TObject;
begin
  SetTokenEvent(0);
  Obj := TObject(F_CombatTypeRequestEventLog_28);
  if Obj <> nil then Obj.Free;
  inherited Destroy;
end;

procedure TCombatTypeRequestEventLog.SetTokenEvent(A1: Integer);
begin
  { Original releases the old token before retaining its replacement. }
  if FTokenEvent <> nil then FTokenEvent.Release;
  FTokenEvent := TEObject(A1);
  if FTokenEvent <> nil then FTokenEvent.AddRef;
end;

function TCombatTypeRequestEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
asm
  PUSH EBX
  PUSH DWORD PTR [EBP+$0C]
  PUSH DWORD PTR [EBP+8]
  CALL EventLog.TEventLog.Execute
  POP EBX
end;

procedure TCombatTypeRequestEventLog.Select(A1: TCombatType);
begin FCombatType := A1; end;

procedure TCombatTypeRequestEventLog.SetCenterLocation(A1: Byte; A2: Byte; A3: Integer);
begin
  F_CombatTypeRequestEventLog_1B := A1;
  F_CombatTypeRequestEventLog_1C := A2;
  F_CombatTypeRequestEventLog_1D := A3;
end;

constructor TCombatParty.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); F_CombatParty_08 := Integer(TArmy.Create(nil)); end;

destructor TCombatParty.Destroy;
begin
  TArmy(F_CombatParty_08).Deactivate;
  TArmy(F_CombatParty_08).Free;
  inherited Destroy;
end;

class function TCombatParty.ClassID: Integer;
begin Result := $202A2; end;

procedure TCombatParty.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(F_CombatParty_0C, $0B);
  Stream.rwInteger(F_CombatParty_10, $0C);
  Stream.rwInteger(F_CombatParty_14, $0D);
  Stream.rwByte(F_CombatParty_1A, $0E);
  Stream.rwData(F_CombatParty_18, 1, $0F);
  Stream.rwByte(F_CombatParty_19, $10);
end;

procedure TCombatParty.Activate(A1: Integer);
begin
  TArmy(F_CombatParty_08).SetPlayer(
    TCombatPlayerList(TCombat(A1).FCombatData.FPlayers).GetPlayers(F_CombatParty_1A).FPlayer);
end;

procedure TCombatParty.Deactivate(A1: Integer);
begin end;

function TCombatPartyList.GetControlStyle: Engine.TEControlStyles;
begin Result := [csSaveLoad, csArrayMode]; end;

function TCombatPartyList.CreateParty(A1: Integer; A2: Byte; A3: Byte; A4: Integer; A5: Integer; A6: Integer; A7: Integer): TCombatParty;
var P: TCombatParty;
begin
  if GetParty(A2) = nil then
  begin
    P := TCombatParty.Create(nil);
    P.F_CombatParty_1A := A3;
    P.F_CombatParty_19 := A2;
    P.F_CombatParty_0C := A4;
    P.F_CombatParty_10 := A5;
    P.F_CombatParty_14 := A6;
    P.SetArrayOwner(Self, A2);
    TArmy(P.F_CombatParty_08).SetXYL(Byte(A4), Byte(A5), A6);
    TArmy(P.F_CombatParty_08).SetPlayer(
      TCombatPlayerList(TCombatData(TCombat(A1).FCombatData).FPlayers).
        GetPlayers(Shortint(A3)).FPlayer);
    if A7 <> 0 then TArmy(P.F_CombatParty_08).AssignSettings(TArmy(A7));
    TArmy(P.F_CombatParty_08).Activate;
  end
  else raise Exception.Create('CombatParty already exists!');
  Result := P;
end;

function TCombatPartyList.GetParty(A1: Byte): TCombatParty;
begin if A1 < FChildren.Count then Result := TCombatParty(FChildren.List^[A1]) else Result := nil; end;

procedure TCombatPartyList.Activate(A1: Integer);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then
      TCombatParty(FChildren.List^[I]).Activate(A1);
end;

procedure TCombatPartyList.Deactivate(A1: Integer);
var I: Integer;
begin
  for I := 0 to FChildren.Count - 1 do
    if FChildren.List^[I] <> nil then
      TCombatParty(FChildren.List^[I]).Deactivate(A1);
end;

class function TCombatPlayer.ClassID: Integer;
begin Result := $202A0; end;

procedure TCombatPlayer.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(Byte(FPlayer), $14);
  Stream.rwByte(FIndependentRelation, $15);
  Stream.rwData(F_CombatPlayer_0A, 1, $16);
end;

constructor TCombatPlayerList.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); end;

destructor TCombatPlayerList.Destroy;
begin inherited Destroy; end;

function TCombatPlayerList.GetPlayers(A1: Shortint): TCombatPlayer;
begin Result := TCombatPlayer(FChildren.List^[A1]); end;

function TCombatPlayerList.IndexOfPlayer(A1: Byte): Integer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TCombatPlayer(FChildren.List^[Result]).FPlayer = A1 then Exit;
  end;
  Result := -1;
end;

function TCombatPlayerList.IndexOf(A1: Byte; A2: Byte): Integer;
var P: TCombatPlayer;
begin
  Result := FChildren.Count;
  while Result <> 0 do
  begin
    Dec(Result);
    P := TCombatPlayer(FChildren.List^[Result]);
    if (P.FPlayer = A1) and (P.FIndependentRelation = A2) then Exit;
  end;
  Result := -1;
end;

procedure TCombatPlayerList.Delete(A1: Integer);
begin GetPlayers(Shortint(A1)).Free; end;

constructor TCombatData.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FPlayers := TCombatPlayerList.Create(nil);
  F_CombatData_3C := Integer(TCombatPartyList.Create(nil));
  F_CombatData_34 := Integer(TENode.Create(nil));
  F_CombatData_2C := Integer(TByteList.Create);
  F_CombatData_40 := Integer(TByteList.Create);
  F_CombatData_28 := Integer(TByteList.Create);
end;

destructor TCombatData.Destroy;
begin
  TObject(F_CombatData_3C).Free;
  TObject(FPlayers).Free;
  TObject(F_CombatData_34).Free;
  TObject(F_CombatData_2C).Free;
  TObject(F_CombatData_28).Free;
  TObject(F_CombatData_40).Free;
  inherited Destroy;
end;

class function TCombatData.ClassID: Integer;
begin Result := $202A3; end;

procedure TCombatData.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(F_CombatData_08, $0A);
  Stream.rwInteger(F_CombatData_0C, $0B);
  Stream.rwInteger(F_CombatData_10, $0C);
  Stream.rwData(F_CombatData_22, 2, $0D);
  Stream.rwByte(Byte(FAttackerPlayer), $0E);
  Stream.rwByte(Byte(FDefenderPlayer), $0F);
  Stream.rwData(F_CombatData_30, 1, $10);
  Stream.rwInteger(F_CombatData_44, $11);
  Stream.rwEObject(TEObject(FPlayers), $12);
  Stream.rwEObject(TEObject(F_CombatData_34), $13);
  Stream.rwEObject(TEObject(F_CombatData_3C), $14);
  Stream.rwString(FHeader, $15);
  Stream.rwInteger(F_CombatData_14, $16);
  Stream.rwInteger(F_CombatData_18, $17);
  Stream.rwInteger(F_CombatData_1C, $18);
  Stream.rwStreamProc($19, TByteList(F_CombatData_2C).LoadFromStream, TByteList(F_CombatData_2C).SaveToStream);
  Stream.rwStreamProc($1A, TByteList(F_CombatData_40).LoadFromStream, TByteList(F_CombatData_40).SaveToStream);
  Stream.rwData(FWallType, 1, $1B);
  Stream.rwBool(FWallBreached, $1C);
  Stream.rwStreamProc($1D, TByteList(F_CombatData_28).LoadFromStream, TByteList(F_CombatData_28).SaveToStream);
end;

function TCombatData.GetSideLeaderInvolved(A1: Byte): Boolean;
var I: Integer;
begin
  Result := False;
  I := TByteList(F_CombatData_28).Count;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Result := TCombatPlayerList(FPlayers).GetPlayers(Shortint(TByteList(F_CombatData_28)[I])).F_CombatPlayer_0A = A1;
  end;
end;

procedure TCombatData.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin
  inherited MsgProc(Msg, Sender);
  TEObject(F_CombatData_34).MsgProc(Msg, Sender);
  TEObject(F_CombatData_3C).MsgProc(Msg, Sender);
end;

function TCombatData.GetCount: Integer;
begin Result := TP3NodeAccess(F_CombatData_34).ChildrenList.Count; end;

function TCombatData.GetObjects(A1: Integer): TCombatObject;
begin Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[A1]); end;

procedure TCombatData.Clear;
begin
  inherited Clear;
  TByteList(F_CombatData_40).Clear;
  TCombatPlayerList(FPlayers).Clear;
  TENode(F_CombatData_34).Clear;
  TCombatPartyList(F_CombatData_3C).Clear;
end;

function TCombatData.IndexOfID(A1: Integer): Integer;
begin
  for Result := TENode(F_CombatData_34).Count - 1 downto 0 do
    if TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[Result]).FID = A1 then Exit;
  Result := -1;
end;

function TCombatData.FindID(A1: Integer): TCombatObject;
var I: Integer;
begin
  I := TP3NodeAccess(F_CombatData_34).ChildrenList.Count;
  while I <> 0 do
  begin
    Dec(I);
    if TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]).FID = A1 then
    begin
      Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]);
      Exit;
    end;
  end;
  Result := nil;
end;

function TCombatData.FindPosition(A1: Byte): TCombatObject;
var I: Integer;
begin
  Result := nil;
  I := TP3NodeAccess(F_CombatData_34).ChildrenList.Count;
  while (I <> 0) and (Result = nil) do
  begin
    Dec(I);
    if A1 = TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]).FPosition then
      Result := TCombatObject(TP3NodeAccess(F_CombatData_34).ChildrenList.List^[I]);
  end;
end;

procedure TCombatData.AddObject(A1: TCombatObject);
begin
  Assert((FindID(A1.FID) = nil) and (FindPosition(A1.FPosition) = nil),
    'CombatObject Position/ID double defined');
  A1.SetOwner(TENode(F_CombatData_34));
end;

constructor TCombatLogbook.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FRefCount := 1;
  FActions := TCombatActionList.Create(nil);
  FFinalData := TCombatData.Create(nil);
  FInitialData := TCombatData.Create(nil);
  F_CombatLogbook_19 := False;
end;

destructor TCombatLogbook.Destroy;
begin
  Clear;
  TObject(FActions).Free;
  TObject(FFinalData).Free;
  TObject(FInitialData).Free;
  inherited Destroy;
end;

procedure TCombatLogbook.SetInitialData(Data: TCombatData);
begin FInitialData.Assign(Data,AoWEngine); end;

procedure TCombatLogbook.SetFinalData(Data: TCombatData);
begin FFinalData.Assign(Data,AoWEngine); end;

procedure TCombatLogbook.Clear;
begin
  TEObject(FFinalData).Clear;
  TEObject(FInitialData).Clear;
  TEObject(FActions).Clear;
end;

class function TCombatLogbook.ClassID: Integer;
begin Result := $202A5; end;

function TCombatLogbook.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TCombatLogbook.Release: Integer;
var N: Integer;
begin
  Dec(FRefCount);
  N := FRefCount;
  Result := N;
  if N = 0 then Destroy;
end;

procedure TCombatLogbook.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwEObject(TEObject(FInitialData), 5);
  Stream.rwEObject(TEObject(FFinalData), 6);
  Stream.rwEObject(TEObject(FActions), 7);
  Stream.rwBool(F_CombatLogbook_19, 8);
end;

destructor TCombatEventLog.Destroy;
var L: TCombatLogbook;
begin
  L := TCombatLogbook(FLogbook);
  if L <> nil then begin L.Release; FLogbook := nil; end;
  inherited Destroy;
end;

class function TCombatEventLog.ClassID: Integer;
begin Result := $202E2; end;

procedure TCombatEventLog.SetCombatLogbook(Logbook: TCombatLogbook);
var Old: TCombatLogbook;
begin
  Old := FLogbook;
  if Old <> Logbook then
  begin
    if Old <> nil then Old.Release;
    FLogbook := Logbook;
    if FLogbook <> nil then FLogbook.AddRef;
  end;
end;

procedure TCombatEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwCreateEObject(TEObject(FLogbook), nil, $14); end;

function TCombatEventLog.GetTextColor: TColor;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer <> 0 then
    Result := RaceColors[AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer)).FPlayerRace]
  else Result := RaceColors[12];
end;

function TCombatEventLog.GetLeftIcon: Integer;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer <> 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer)).FPlayerRace
  else Result := 12;
end;

function TCombatEventLog.GetMiddleIcon: Integer;
begin Result := $0D; end;

function TCombatEventLog.GetRightIcon: Integer;
var Data: TCombatData;
begin
  Data := FLogbook.FFinalData;
  if TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer <> 0 then
    Result := AoWHSMap.FPlayers.GetPlayers(Shortint(TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FDefenderPlayer).FPlayer)).FPlayerRace
  else Result := 12;
end;

function TCombatEventLog.GetText: string;
begin
  { needs: string result in EventLog's unmarked interface. }
  Result := TCombatData(TCombatLogbook(FLogbook).FFinalData).FHeader;
end;

procedure TCombatEventLog.PlayLoggedSFX(A1: Integer);
begin
  if TCombatPlayerList(FLogbook.FInitialData.FPlayers).IndexOfPlayer(AoWHSMap.FSeatedPlayer) <> -1 then
    PlaySample('SFX\EVENTS\ROLL.WAV')
  else PlaySample('SFX\EVENTS\NEWEVENT.WAV');
end;

function TCombatEventLog.Execute(Mode: Boolean; Trigger: TExecuteTrigger; Done: TExecuteDoneEvent): Boolean;
var ShowCombat: Boolean; Data: TCombatData;
begin
  Result := False;
  case Trigger of
    etUser:
      begin
        AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
        Result := True;
      end;
    etEvent, etNewTurn:
      begin
        if TCombatPlayerList(FLogbook.FInitialData.FPlayers).IndexOfPlayer(AoWHSMap.FSeatedPlayer) <> -1 then
        begin
          Data := FLogbook.FInitialData;
          ShowCombat := TCombatPlayerList(Data.FPlayers).GetPlayers(Data.FAttackerPlayer).FPlayer = Byte(AoWHSMap.FSeatedPlayer);
          ShowCombat := ShowCombat or (AoWHSMap.FRequestCombatType and
            (Ord(AoWHSMap.FConnectionType) = Ord(tcaAlways)) and
            (TCombatPlayerList(FLogbook.FInitialData.FPlayers).GetPlayers(FLogbook.FInitialData.FDefenderPlayer).FPlayer = Byte(AoWHSMap.FSeatedPlayer)));
          ShowCombat := ShowCombat or ((Trigger = etEvent) and (AoWHSMap.FPlayMode = pmTurn) and
            (wpCombat in TAoWRegistry(AoWEngine.FRegistry).GetClassicWindowPopupEvents));
          ShowCombat := ShowCombat or ((Trigger = etEvent) and (AoWHSMap.FPlayMode = pmSimultaneous) and
            (wpCombat in TAoWRegistry(AoWEngine.FRegistry).GetSimultaneousWindowPopupEvents));
          ShowCombat := ShowCombat and (FLogbook.FCombatResult <> crNoDefenders);
        end
        else ShowCombat := False;
        ShowCombat := ShowCombat or FLogbook.F_CombatLogbook_19;
        if ShowCombat then
        begin
          AoWHSMap.TriggerExecuteEventLog(Self, False, Done);
          Result := True;
        end
        else Result := False;
      end;
  end;
end;

procedure TCombatEventLog.ViewLocation;
{ needs: EventLog.TEventLog.CenterViewTo has three Byte arguments. }
asm
  MOV EDX, [EAX+$18]
  MOV EDX, [EDX+$10]
  MOV CL, [EDX+$10]
  PUSH ECX
  MOV CL, [EDX+$0C]
  MOV DL, [EDX+8]
  CALL EventLog.TEventLog.CenterViewTo
end;

constructor TCombatViewer.Create;
begin
  inherited Create;
  FCombat := TCombat.Create(nil);
  FTime := -1;
  FSpeed := 5;
  FDelay := 5;
end;

destructor TCombatViewer.Destroy;
begin
  if vsInitialized in FStatus then Finalize;
  TObject(FCombat).Free;
  inherited Destroy;
end;

procedure TCombatViewer.Initialize(A1: TCombatLogbook);
begin
  if vsInitialized in FStatus then Finalize;
  FStatus := [vsInitialized];
  FLogbook := A1;
  FLogbook.AddRef;
  FPosition := 0;
  FTime := -1;
  TCombatData(FCombat.FCombatData).Assign(A1.FInitialData, AoWEngine);
  FCombat.Activate;
  FDelay := FSpeed;
end;

procedure TCombatViewer.Finalize;
begin
  if vsInitialized in FStatus then
  begin
    TCombat(FCombat).Deactivate;
    TCombat(FCombat).Clear;
    TCombatLogbook(FLogbook).Release;
    FLogbook := nil;
    FStatus := FStatus - [vsInitialized];
  end;
end;

function TCombatViewer.GetEndPosition: Integer;
begin Result := TCombatActionList(TCombatLogbook(FLogbook).FActions).Count + 1; end;

procedure TCombatViewer.SetSpeed(A1: Byte);
begin if A1 = 0 then A1 := 1; FSpeed := A1; end;

procedure TCombatViewer.SetPosition(A1: Integer);
begin
  if vsInitialized in FStatus then
  begin
    FTime := -1;
    if A1 > GetEndPosition then A1 := GetEndPosition;
    if (A1 > 0) and (A1 <= FLogbook.FActions.Count) then
    begin
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FInitialData, AoWEngine);
      FCombat.Activate;
      FPosition := 0;
      while A1 > FPosition do
      begin
        Inc(FPosition);
        if A1 <> FPosition then FLogbook.FActions.GetCombatActions(FPosition-1).Execute(FCombat);
      end;
    end
    else if A1 = 0 then
    begin
      FPosition := 0;
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FInitialData, AoWEngine);
      FCombat.Activate;
    end
    else
    begin
      FPosition := GetEndPosition;
      FCombat.Deactivate;
      TCombatData(FCombat.FCombatData).Assign(FLogbook.FFinalData, AoWEngine);
      FCombat.Activate;
    end;
  end
  else FPosition := A1;
end;

procedure TCombatViewer.Play;
begin FStatus := (FStatus + [vsPlaying]) - [vsPaused]; end;

procedure TCombatViewer.Pause;
begin FStatus := FStatus + [vsPaused]; end;

procedure TCombatViewer.Update;
var Playing: Boolean;
begin
  if (FStatus * [vsInitialized, vsPlaying, vsPaused] = [vsInitialized, vsPlaying]) and
    (GetEndPosition <> FPosition) then
  begin
    Playing := False;
    if FPosition = 0 then
    begin
      Inc(FTime);
      if FTime >= FDelay then
      begin
        FPosition := 1;
        FTime := -1;
      end;
    end;
    while (FPosition > 0) and
      (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) and not Playing do
    begin
      Inc(FTime);
      Playing := TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).Play(Self);
      if not Playing then
      begin
        Inc(FPosition);
        FDelay := FSpeed;
        FTime := -1;
      end;
    end;
    if GetEndPosition = FPosition then SetPosition(GetEndPosition);
  end;
end;

procedure TCombatViewer.ShowObject(A1: TCombatObject; A2: Integer; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if TCombatActionList(TCombatLogbook(FLogbook).FActions).Count >= FPosition then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowObject(Self, TCombatObject(A1), A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFieldObject(A1: TCombatObject; A2: Integer; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if (FPosition > 0) and (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowFieldObject(Self, TCombatObject(A1), A2, A3, A4, A5, A6)
  else TCombatObject(A1).Show(A2, A3, A4, A5, A6);
end;

procedure TCombatViewer.ShowFightingObjects(A1: Integer; A2: Integer; A3: Integer; const A4: TSurfaceDesc);
begin
  if (FPosition > 0) and
    (FPosition <= TCombatActionList(TCombatLogbook(FLogbook).FActions).Count) then
    TCombatActionList(TCombatLogbook(FLogbook).FActions).GetCombatActions(FPosition - 1).ShowFightingObjects(Self, A1, A2, A3, A4);
end;

procedure TCombatViewer.DefaultShowFightingObjects(A1: TCombatObject; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; const A6: TSurfaceDesc);
begin
  if A2 <> nil then
    if TCombatObject(A2).GetSide = csAttacker then ShowObject(A2, A3, 3, A4, A5, A6)
    else ShowObject(A2, A3, 5, A4 + 25, A5, A6);
  if A1 <> nil then
    if TCombatObject(A1).GetSide = csAttacker then ShowObject(A1, A3, 2, A4, A5 + 15, A6)
    else ShowObject(A1, A3, 6, A4 + 25, A5 + 15, A6);
end;

constructor TCombatAction.Create(AOwner: Engine.TECustomNode);
begin inherited Create(AOwner); FRefCount := 1; end;

function TCombatAction.AddRef: Integer;
begin Inc(FRefCount); Result := FRefCount; end;

function TCombatAction.Release: Integer;
var N: Integer;
begin
  Dec(FRefCount);
  N := FRefCount;
  Result := N;
  if N = 0 then Destroy;
end;

function TCombatAction.GetName: string;
begin Result := ClassName; end;

procedure TCombatAction.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  TCombatObject(A2).Show(A3, A4, A5, A6, A7);
end;

procedure TCombatAction.ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
begin end;

function TCombatActionList.GetCombatActions(A1: Integer): TCombatAction;
begin Result := TCombatAction(FChildren.List^[A1]); end;

procedure TSingleTargetCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FSourceID, $0A);
  Stream.rwByte(FTargetID, $0B);
  Stream.rwData(FMode, 1, $0C);
end;

function TSingleTargetCA.GetDefensive: Boolean;
begin Result := smDefensive in FMode; end;

procedure TSingleTargetCA.SetDefensive(A1: Byte);
begin
  if A1 <> 0 then FMode := FMode + [smDefensive]
  else FMode := FMode - [smDefensive];
end;

procedure TSingleTargetCA.ShowFieldObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if not (smDefensive in FMode) then
  begin
    if TCombatObject(A2).FID = FSourceID then AoWHSSet.FCombatImages[2].Show(A5+15,A6+18,A7);
  end
  else if TCombatObject(A2).FID = FTargetID then AoWHSSet.FCombatImages[2].Show(A5+15,A6+18,A7);
  ShowObject(TCombatViewer(A1),TCombatObject(A2),A3,A4,A5,A6,A7);
  if not (smDefensive in FMode) then
  begin
    if TCombatObject(A2).FID = FTargetID then AoWHSSet.FCombatImages[3].Show(A5+15,A6+18,A7);
  end
  else if TCombatObject(A2).FID = FSourceID then AoWHSSet.FCombatImages[3].Show(A5+15,A6+18,A7);
end;

procedure TSingleTargetCA.ShowFightingObjects(A1: TCombatViewer; A2: Integer; A3: Integer; A4: Integer; const A5: TSurfaceDesc);
var Source, Target: TCombatObject;
begin
  Source := TCombatData(A1.FCombat.FCombatData).FindID(FSourceID);
  Target := TCombatData(A1.FCombat.FCombatData).FindID(FTargetID);
  if not (smDefensive in FMode) then
    A1.DefaultShowFightingObjects(Source,Target,A2,A3,A4,A5)
  else A1.DefaultShowFightingObjects(Target,Source,A2,A3,A4,A5);
end;

class function TDamageCA.ClassID: Integer;
begin Result := $202B1; end;

procedure TDamageCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FDamage, $0F);
  Stream.rwData(FEffects, 2, $10);
  Stream.rwData(FDamageTypes, 2, $11);
end;

procedure TDamageCA.Setup(A1: Byte; A2: Byte; A3: Byte; A4: TDamageTypes; A5: TDamageTypes; A6: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FDamage := A3;
  FEffects.Value := A4;
  FDamageTypes.Value := A5;
  if A6 then FMode := FMode + [smDefensive];
end;

procedure TDamageCA.Generate(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes);
var DamageTypes: TDamageTypes absolute A5;
begin
  FSourceID := TCombatObject(A1).FID;
  FTargetID := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRole(Shortint(A3), Shortint(A4), DamageTypes);
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.GenerateEx(A1, A2: TCombatObject; A3, A4: Shortint; A5: TDamageTypes; A6: Byte);
var DamageTypes: TDamageTypes absolute A5;
begin
  FSourceID := TCombatObject(A1).FID;
  FTargetID := TCombatObject(A2).FID;
  FDamage := TCombatObject(A2).ExecuteDamageRoleEx(Shortint(A3), Shortint(A4), DamageTypes, Byte(A6));
  if FDamage <> 0 then FEffects.Value := TCombatObject(A2).ExecuteDamageEffectsRole(DamageTypes)
  else FEffects.Value := [];
  FDamageTypes.Value := DamageTypes - TCombatObject(A2).GetImmunityTypes;
end;

procedure TDamageCA.Execute(A1: TCombat);
var Target, Source: TCombatObject;
begin
  Source := TCombatData(TCombat(A1).FCombatData).FindID(FSourceID);
  Target := TCombatData(TCombat(A1).FCombatData).FindID(FTargetID);
  if FDamage <> 0 then FDamageDone := Source.DoDamage(Target, FDamage);
  if FEffects.Value <> [] then Target.ExecuteDamageEffects(FEffects.Value);
end;

function TDamageCA.Play(A1: TCombatViewer): Boolean;
var HitFrame, Duration, EffectFrames: Integer; Target: TCombatObject;
begin
  if A1.FDelay < 5 then HitFrame := A1.FDelay else HitFrame := 5;
  if HitFrame = A1.FTime then
  begin
    Execute(TCombatViewer(A1).FCombat);
    Target := TCombatData(TCombat(TCombatViewer(A1).FCombat).FCombatData).FindID(FTargetID);
    if FDamageDone <> 0 then
      if not (csDestroyed in Target.FStatus) then Target.PlaySFX(2) else Target.PlaySFX(3);
  end;
  Duration := A1.FDelay * 2;
  if FEffects.Value <> [] then
  begin
    EffectFrames := AoWE.DamageEffectsAnimationFrames(FEffects.Value) + A1.FDelay;
    HitFrame := A1.FDelay * 3;
    if EffectFrames > HitFrame then EffectFrames := HitFrame;
    if Duration < EffectFrames then Duration := EffectFrames;
  end;
  Result := Duration > A1.FTime;
end;

procedure TDamageCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
var HitFrame: Integer;
begin
  if TCombatObject(A2).FID = FSourceID then
    TCombatObject(A2).ShowAttackAnimation(TCombatViewer(A1).FTime, A4, A5, A6, A7)
  else
  begin
    if TCombatViewer(A1).FDelay < 5 then HitFrame := TCombatViewer(A1).FDelay else HitFrame := 5;
    if (TCombatObject(A2).FID = FTargetID) and (FDamageDone <> 0) and (HitFrame <= TCombatViewer(A1).FTime) then
    begin
      TCombatObject(A2).Show(A3, A4, A5, A6, A7);
      if FEffects.Value <> [] then AoWE.ShowDamageEffects(PWord(@FEffects.Value)^, A5, A6, TCombatViewer(A1).FTime - HitFrame, A7);
      { needs: P1 ShowDamageIcon has five arguments; DamageTypesToDamageType returns TDamageType. }
      AoWE.ShowDamageIcon(A5, A6, A7, FDamageDone, AoWE.DamageTypesToDamageType(FDamageTypes.Value));
    end
    else TCombatObject(A2).Show(A3, A4, A5, A6, A7);
  end;
end;

class function TDamageEffectCA.ClassID: Integer;
begin Result := $202B2; end;

procedure TDamageEffectCA.ReadWrite(Stream: Engine.TEStorageStream);
begin inherited ReadWrite(Stream); Stream.rwData(FDamageType, 1, $0F); end;

procedure TDamageEffectCA.Initialize(A1: Byte; A2: Byte; A3: Byte; A4: Boolean);
begin
  FSourceID := A1;
  FTargetID := A2;
  FDamageType := TDamageType(A3);
  if A4 then FMode := FMode + [smDefensive];
end;

procedure TDamageEffectCA.Execute(A1: TCombat);
var Combat: TCombat; Target, Source: TCombatObject;
begin
  Combat := TCombat(A1);
  Target := TCombatData(Combat.FCombatData).FindID(FTargetID);
  if not (csDestroyed in Target.FStatus) then
  begin
    Source := TCombatData(Combat.FCombatData).FindID(FSourceID);
    Target.ExecuteDamageEffects([TDamageType(FDamageType)]);
    if csDestroyed in Target.FStatus then
      with Source do SetExperience(GetExperience + Target.GetLevel);
  end;
end;

function TDamageEffectCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean Play result despite the unmarked P4 overrides. }
asm
  PUSH EBX
  MOV EBX, EDX
  XOR EDX, EDX
  MOV DL, [EBX+$0C]
  ADD EDX, EDX
  CMP EDX, [EBX+$14]
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  ADD EAX, EAX
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

procedure TDamageEffectCA.ShowObject(A1: TCombatViewer; A2: TCombatObject; A3: Integer; A4: Integer; A5: Integer; A6: Integer; const A7: TSurfaceDesc);
begin
  if TCombatObject(A2).FID = FTargetID then
    case FDamageType of
      dtFire:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($7F).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtPoison:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($60).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtCold:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($5F).FImageSequences.Show(1,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtDeath:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($5D).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
      dtHoly:
        begin
          TCombatObject(A2).Show(A3,A4,A5,A6,A7);
          AoWHSSet.FAbilityControl.GetAbility($62).FImageSequences.Show(0,A5+32,A6+32,TCombatViewer(A1).FTime,A7);
        end;
    else TCombatObject(A2).Show(A3,A4,A5,A6,A7);
    end
  else TCombatObject(A2).Show(A3,A4,A5,A6,A7);
end;

class function TUpdateHeaderCA.ClassID: Integer;
begin Result := $202B6; end;

procedure TUpdateHeaderCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwString(F_UpdateHeaderCA_0C, $14);
end;

procedure TUpdateHeaderCA.Execute(A1: TCombat);
{ conflict: procedure TUpdateHeaderCA.Execute(A1: TCombat; A2: Integer); }
begin TCombatData(TCombat(A1).FCombatData).FHeader := F_UpdateHeaderCA_0C; end;

function TUpdateHeaderCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

class function TNewCombatTurnCA.ClassID: Integer;
begin Result := $202BA; end;

procedure TNewCombatTurnCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(F_NewCombatTurnCA_0C, $14);
end;

procedure TNewCombatTurnCA.Execute(A1: TCombat);
var I: Integer;
begin
  TCombatData(TCombat(A1).FCombatData).FCurrentPlayer := F_NewCombatTurnCA_0C;
  for I := TCombatData(TCombat(A1).FCombatData).GetCount - 1 downto 0 do
    TCombatData(TCombat(A1).FCombatData).GetObjects(I).NewTurn(F_NewCombatTurnCA_0C);
end;

function TNewCombatTurnCA.Play(A1: TCombatViewer): Boolean;
begin
  if A1.FTime = 0 then
  begin
    Execute(A1.FCombat);
    PlaySample('SFX\EVENTS\INFO2.WAV');
  end;
  Result := A1.FDelay > A1.FTime;
end;

class function TNewCombatRoundCA.ClassID: Integer;
begin Result := $202BB; end;

procedure TNewCombatRoundCA.Execute(A1: TCombat);
var I: Integer;
begin
  with TCombatData(TCombat(A1).FCombatData) do Inc(F_CombatData_44);
  for I := TCombatData(TCombat(A1).FCombatData).GetCount - 1 downto 0 do
    TCombatData(TCombat(A1).FCombatData).GetObjects(I).NewRound;
end;

function TNewCombatRoundCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  PUSH EBX
  MOV EBX, EDX
  CMP DWORD PTR [EBX+$14], 0
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

class function TCombatObjectTurnDoneCA.ClassID: Integer;
begin Result := $202BC; end;

procedure TCombatObjectTurnDoneCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(F_CombatObjectTurnDoneCA_0C, 1, $14);
end;

procedure TCombatObjectTurnDoneCA.Execute(A1: TCombat);
var Obj: TCombatObject;
begin
  Obj := TCombatData(TCombat(A1).FCombatData).FindID(F_CombatObjectTurnDoneCA_0C);
  Obj.FStatus := Obj.FStatus + [csTurnDone];
end;

function TCombatObjectTurnDoneCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  PUSH EBX
  MOV EBX, EDX
  CMP DWORD PTR [EBX+$14], 0
  JNE @@Playing
  MOV EDX, [EBX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
@@Playing:
  XOR EAX, EAX
  MOV AL, [EBX+$0C]
  CMP EAX, [EBX+$14]
  SETG AL
  POP EBX
end;

class function TMoveWallCA.ClassID: Integer;
begin Result := $202B7; end;

procedure TMoveWallCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(F_MoveWallCA_0C, 1, $14);
  Stream.rwData(F_MoveWallCA_0D, 1, $15);
end;

procedure TMoveWallCA.Execute(A1: TCombat);
var Obj: TFastCombatUnit;
begin
  Obj := TFastCombatUnit(TCombatData(TCombat(A1).FCombatData).FindID(F_MoveWallCA_0C));
  if F_MoveWallCA_0D = 0 then Obj.FState := Obj.FState + [fsOutsideWall];
  if F_MoveWallCA_0D = 1 then Obj.FState := Obj.FState - [fsOutsideWall];
end;

function TMoveWallCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

class function TFleeCA.ClassID: Integer;
begin Result := $202C0; end;

procedure TFleeCA.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwData(F_FleeCA_0C, 1, $14);
end;

procedure TFleeCA.Execute(A1: TCombat);
var Obj: TCombatObject;
begin
  Obj := TCombatData(TCombat(A1).FCombatData).FindID(F_FleeCA_0C);
  Obj.FStatus := Obj.FStatus + [csFled];
end;

function TFleeCA.Play(A1: TCombatViewer): Boolean;
{ needs: Boolean result; unmarked P4 Play overrides retain procedure drafts. }
asm
  MOV EDX, [EDX+8]
  MOV ECX, [EAX]
  CALL DWORD PTR [ECX+$50]
  XOR EAX, EAX
end;

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
      Q := TQuadItemList(FRoundTargets);
      U := TCombatPredictorUnit(Q.List^[I].A);
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
      else Q.Delete(I);
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

procedure TCombatPredictor.EnableAllUnits;
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

procedure TCombatPredictor.AddUnits(A1: Integer);
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
var Wall: TWallUnit; UnitObj: TCombatPredictorUnit;
begin
  Assert(A1 <> wtNone, 'Use DeleteWall instead!');
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
  AddUnits(Integer(A1.FArmy));
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

procedure TCombatPredictor.ListRequiredUnits(A1: Integer; A2: Integer);
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

procedure P3InitializeHitProbabilities;
var I: Integer;
begin
  for I := 0 to 19 do P3HitProbabilities[I] := (20 - I) * 0.05;
end;

function P3LimitedDamage(Attack, Defense, Damage: Integer): Integer;
begin
  if Defense > 10 then Defense := 10;
  Result := (Attack * Defense * Damage) div 2;
end;

class function TCombatWall.LinkP3Helpers(Index: Integer): Pointer;
begin
  if Index = 0 then Result := @P3InitializeHitProbabilities
  else Result := @P3LimitedDamage;
end;
