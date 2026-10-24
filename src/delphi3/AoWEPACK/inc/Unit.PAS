constructor TUnitControl.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  FUnitTable := TIntegerHashTable256.Create;
  FUnits := TList.Create;
  FNextUnitID := 1;
end;
destructor TUnitControl.Destroy;
begin
  FUnits.Free;
  FUnitTable.Free;
  inherited Destroy;
end;
procedure TUnitControl.ReadWrite(Stream: Engine.TEStorageStream);
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FNextUnitID, 10);
  if FNextUnitID <= 0 then FNextUnitID := 1;
end;
function TUnitControl.GetCount: Integer;
begin
  Result := FUnits.Count;
end;
procedure TUnitControl.TriggerUnitsChanged;
var
  I: Integer;
begin
  for I := FUnits.Count - 1 downto 0 do
    TAbstractUnit(FUnits.List^[I]).Changed;
end;
function TUnitControl.GetUnit(Index: Integer): TAbstractUnit;
begin
  Result := FUnits.List^[Index];
end;
function TUnitControl.FindUnit(ID: Integer): TAbstractUnit;
begin
  Result := TAbstractUnit(FUnitTable.Find(ID));
end;
function TUnitControl.GetFreeID: Integer;
begin
  while FUnitTable.Find(FNextUnitID) <> nil do
  begin
    Inc(FNextUnitID);
    if FNextUnitID > $0FFFFFFF then FNextUnitID := 1;
  end;
  Result := FNextUnitID;
end;
procedure TUnitControl.RegisterUnit(AUnit: TAbstractUnit);
var
  ExistingUnit: TAbstractUnit;
begin
  if not (usRegistered in AUnit.FUnitStatus) then
  begin
    if AUnit.FUnitID = -1 then
    begin
      AUnit.FUnitID := GetFreeID;
      AUnit.FUnitStatus := AUnit.FUnitStatus + [usRegistered];
      FUnitTable.Add(AUnit, AUnit.FUnitID);
      FUnits.Add(AUnit);
    end
    else
    begin
      ExistingUnit := FUnitTable.Find(AUnit.FUnitID);
      if ExistingUnit <> AUnit then
      begin
        FUnits.Add(AUnit);
        AUnit.FUnitStatus := AUnit.FUnitStatus + [usRegistered];
        if ExistingUnit = nil then
          FUnitTable.Add(AUnit, AUnit.FUnitID)
        else if msEditting in AoWHSMap.Status then
        begin
          AUnit.FUnitID := GetFreeID;
          FUnitTable.Add(AUnit, AUnit.FUnitID);
        end
        else
          try
            raise Exception.Create('UnitID Failure');
          except
            AUnit.FUnitID := GetFreeID;
            FUnitTable.Add(AUnit, AUnit.FUnitID);
          end;
      end;
    end;
  end;
end;
procedure TUnitControl.UnRegisterUnit(AUnit: TAbstractUnit);
begin
  if usRegistered in AUnit.FUnitStatus then
  begin
    AUnit.FUnitStatus := AUnit.FUnitStatus - [usRegistered];
    FUnitTable.DeleteSafe(AUnit, AUnit.FUnitID);
    FUnits.Remove(AUnit);
  end;
end;
constructor TAbstractUnit.Create(AOwner: Engine.TECustomNode);
begin
  FRefCount := 1;
  inherited Create(AOwner);
  FGroupID := 0;
  FUnitID := -1;
end;
{ needs: TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit); forward both registers
  to the existing draft method until P1 corrects its declaration. }
procedure P2NotifyUnitDestroyed(Map: TAoWHSMap; AUnit: TAbstractUnit); assembler;
asm
  JMP TAoWHSMap.UnitDestroyed
end;
destructor TAbstractUnit.Destroy;
begin
  if usActivated in FUnitStatus then Deactivate;
  if AoWHSMap <> nil then
  begin
    { needs: P1 TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit),
      EDX is Self at 5577EB8B; keep the argument live across the draft call. }
    P2NotifyUnitDestroyed(AoWHSMap, Self);
  end;
  inherited Destroy;
end;
function TAbstractUnit.GetBloodType: TBloodType;
begin
  Result := btRed;
end;
function TAbstractUnit.GetCampaignTransferPoints: Integer;
begin
  Result := GetObtainValue;
end;
function TAbstractUnit.AddRef: Integer;
begin
  Inc(FRefCount);
  Result := FRefCount;
end;
function TAbstractUnit.Release: Integer;
var
  Count: Integer;
begin
  Dec(FRefCount);
  Count := FRefCount;
  Result := Count;
  if Count = 0 then Destroy;
end;
{ needs: P1 StatisticsToDV(Attack, Damage: Integer; DamageTypes: TDamageTypes;
  Defense, Resistance: Integer; ImmunityTypes, ProtectionTypes: TDamageTypes): Integer.
  The call at 5577EC46 passes CX as a set, four stack arguments, and returns EAX. }
function P2StatisticsToDV(Attack, Damage: Integer; DamageTypes: TDamageTypes;
  Defense, Resistance: Integer; ImmunityTypes, ProtectionTypes: TDamageTypes): Integer;
  assembler;
asm
  { A stack-argument assembler routine gets an EBP frame; remove it before jumping. }
  POP EBP
  JMP StatisticsToDV
end;
procedure TAbstractUnit.RetrieveDamageInfo(Attack, Damage: Shortint;
  DamageTypes: TDamageTypes; var DamageValue, ObtainValue: Integer);
var
  MaxDamage: Integer;
begin
  MaxDamage := GetHitPoints * 100;
  DamageValue := P2StatisticsToDV(Attack, Damage, DamageTypes,
    GetDefense, GetResistance, GetImmunityTypes, GetProtectionTypes);
  if MaxDamage < DamageValue then DamageValue := MaxDamage;
  if (DamageValue > 0) and (GetHitPoints > 0) then
  begin
    if MaxDamage > DamageValue then
      ObtainValue := Round(GetObtainValue * (DamageValue * 0.75 / MaxDamage))
    else
      ObtainValue := GetObtainValue;
  end
  else
    ObtainValue := 0;
end;
function TAbstractUnit.GetAbilitySelectionTypes: TAbilitySelectionTypes;
const
  SelectionTypes: TAbilitySelectionTypes = [astUnit];
asm
  { needs: P1 TAbilityOwner.GetAbilitySelectionTypes: TAbilitySelectionTypes;
    original 5577ECC0 takes no arguments and returns the set in AX. }
  MOV AX, SelectionTypes
end;
function TAbstractUnit.GetWallCombatFeatures: TWallCombatFeatures;
begin
  Result := [];
  if GetAbilityEnabled(1) or GetAbilityEnabled(165) or
     GetAbilityEnabled(36) or GetAbilityEnabled(66) then
    Result := Result + [wcWallPassing, wcParticipate];
  if GetAbilityEnabled(117) or GetAbilityEnabled(24) or
     GetAbilityEnabled(65) or GetAbilityEnabled(44) then
    Result := Result + [wcWallBreaching, wcParticipate];
end;
procedure TAbstractUnit.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin
  if Owner is TUnitList then
    TUnitList(Owner).GetLocation(Xhx, Yhx, Lhx)
  else
  begin
    Xhx := -1;
    Yhx := -1;
    Lhx := -1;
  end;
end;
function TAbstractUnit.GetRace: Shortint;
begin
  Result := -1;
end;
{ needs: P1 result/argument declarations used by GetRelationValue,
  evidenced by 5577EE1A..5577EE64 and 5577EEA1..5577EEAE.
  These tail calls preserve the original register ABI while the drafts are assembled. }
function P2GetRace(List: TRaceList; Index: Integer): TRace; assembler;
asm
  JMP TRaceList.GetRace
end;
function P2GetPlayerRelationValue(Race: TRace; Player: Shortint): Integer; assembler;
asm
  JMP TRace.GetPlayerRelationValue
end;
function P2GetPlayers(List: TPlayerList; Index: Integer): TPlayer; assembler;
asm
  JMP TPlayerList.GetPlayers
end;
function P2GetRaceResource(List: TRaceResourceList; Index: Integer): TRaceResource; assembler;
asm
  JMP TRaceResourceList.GetRaceResource
end;
function P2GetRaceAlignment(Race: TRaceResource): TAlignment; assembler;
asm
  JMP TRaceResource.GetAlignment
end;
function P2IRtoAlignment(Relation: Shortint): TAlignment; assembler;
asm
  JMP IRtoAlignment
end;
function TAbstractUnit.GetRelationValue(Player, IndependentRelation: Shortint): Integer;
var
  Race: Shortint;
begin
  Race := GetRace;
  if Player <> 0 then
  begin
    if (Race <> -1) and not GetAbilityEnabled(107) then
      Result := P2GetPlayerRelationValue(
        P2GetRace(TRaceList(AoWHSMap.FRaces), Race), Player)
    else
    begin
      Result := P2AlignmentToStatusValue[GetAlignment, P2GetRaceAlignment(P2GetRaceResource(
        TRaceResourceList(AoWHSSet.FRaceResources),
        Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers), Player).FPlayerRace)))];
    end;
  end
  else
    Result := P2AlignmentToStatusValue[GetAlignment, P2IRtoAlignment(IndependentRelation)];
end;
{ needs: P1 StatusValueToStatus(Value: Integer): TStatus; 5577EECE returns AL. }
function P2StatusValueToStatus(Value: Integer): TStatus; assembler;
asm
  JMP StatusValueToStatus
end;
function TAbstractUnit.GetRelation(Player, IndependentRelation: Shortint): TStatus;
begin
  Result := P2StatusValueToStatus(GetRelationValue(Player, IndependentRelation));
end;
function TAbstractUnit.GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer;
{ Original reads the shared RaceTerrain table; a private copy misses changes
  to the shared settings even when its initial bytes are identical. }
var
  Race: Shortint;
  Xhx, Yhx, Lhx: Shortint;
  TerrainType: TAoWTerrainType; RawTerrain: Byte; RaceIndex: Integer;
  Morale: Integer;
begin
  if (Player >= 0) and (GetUnitType <> utMachine) and
     not (msEditting in AoWHSMap.Status) then
  begin
    Race := GetRace;
    Morale := GetRelationValue(Player, IndependentRelation);
    if Race <> -1 then
    begin
      GetLocation(Xhx, Yhx, Lhx);
      if Xhx <> -1 then
      begin
        RawTerrain := AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx).TerrainType; RaceIndex := Race; TerrainType := TAoWTerrainType(RawTerrain);
        if Ord(TerrainType) in RaceTerrain[RaceIndex].Penalty then Dec(Morale, 10); { Read the original shared table, not the private copy. }
        if Ord(TerrainType) in RaceTerrain[RaceIndex].Bonus then Inc(Morale, 10);
      end;
    end;
    if GetAbilityEnabled(53) then Dec(Morale, 40);
    if GetAbilityEnabled(108) then Dec(Morale, 80);
    if Morale < 0 then Morale := 0;
    if Morale > 100 then Morale := 100;
  end
  else
    Morale := 50;
  Result := Morale;
end;
{ needs: draft P1 TRace.GetRelation(Race: Shortint): TStatus,
  call 5577F02E takes DL and returns AL. }
function P2RaceRelation(Race: TRace; OtherRace: Shortint): TStatus; assembler;
asm JMP TRace.GetRelation end;
{ needs: draft P1 dAlignmentToStatus(A, B: TAlignment): TStatus;
  call 5577F04B uses AL/DL and returns AL. }
function P2AlignmentRelation(A, B: TAlignment): TStatus; assembler;
asm JMP dAlignmentToStatus end;
function TAbstractUnit.UnitRelation(AUnit: TAbstractUnit): TStatus;
var
  Race, OtherRace: Shortint;
begin
  Race := GetRace;
  OtherRace := AUnit.GetRace;
  if (Race <> -1) and (OtherRace <> -1) then
    Result := P2RaceRelation(P2GetRace(TRaceList(AoWHSMap.FRaces), Race), OtherRace)
  else
    Result := P2AlignmentRelation(GetAlignment, AUnit.GetAlignment);
end;
function TAbstractUnit.UpdateMoraleValue: Shortint;
var
  Player, Value, I: Integer;
  AUnit: TAbstractUnit;
begin
  Player := Shortint(FPlayer);
  Value := GetUnitMoraleValue(Player, GetIndependentRelation);
  if not (msEditting in AoWHSMap.Status) and (GetUnitType <> utMachine) and
     not (Self is TLeader) and (Owner is TArmy) then
  begin
    if (GetUpkeep <> 0) and (Player > 0) and not GetAbilityEnabled(155) then
      Inc(Value, Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers), Player).FMoraleValue));
    for I := TArmy(Owner).Count - 1 downto 0 do
    begin
      AUnit := TAbstractUnit(TP2NodeFields(Owner).Children.List^[I]);
      if AUnit.GetAbilityEnabled(37) and (AUnit <> Self) then
        Inc(Value, 30)
      else if UnitRelation(AUnit) in [sHostile, sWary] then
        Dec(Value, 10);
    end;
  end;
  if Value > 125 then FMoraleValue := 125
  else if Value < -25 then FMoraleValue := -25
  else FMoraleValue := Value;
  Result := FMoraleValue;
end;
{ needs: draft P1 MoraleValueToMorale(Value: Integer): TMorale;
  5577F178 sign extends the morale byte into EAX before the call. }
function P2MoraleValueToMorale(Value: Integer): TMorale; assembler;
asm JMP MoraleValueToMorale end;
function TAbstractUnit.GetMorale: TMorale;
begin
  Result := P2MoraleValueToMorale(Shortint(FMoraleValue));
end;
function TAbstractUnit.GetUnitSize: TUnitSize;
begin
  Result := usMedium;
end;
function TAbstractUnit.GetObtainValue: Integer;
begin
  Result := 0;
end;
{ needs: draft P1 TAbilityTypeList.GetAbility(Index: Integer): TAbility;
  5577F1AB returns a pointer whose +0C ability ID is read at 5577F1B0. }
function P2TypeAbility(List: TAbilityTypeList; Index: Integer): TAbility; assembler;
asm JMP TAbilityTypeList.GetAbility end;
procedure TAbstractUnit.UpdateEnchanted;
var
  I: Integer;
  List: TAbilityTypeList;
  Enchanted: Boolean;
begin
  List := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  Enchanted := False;
  I := List.Count;
  while not Enchanted and (I <> 0) do
  begin
    Dec(I);
    Enchanted := GetAbilityEnabled(P2TypeAbility(List, I).FAbilityID);
  end;
  if Enchanted then FUnitStatus := FUnitStatus + [usEnchanted]
  else FUnitStatus := FUnitStatus - [usEnchanted];
end;
procedure TAbstractUnit.RemoveEnchantments;
var
  Ability: TAbility;
  I: Integer;
  List: TAbilityTypeList;
begin
  AddRef;
  List := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  for I := List.Count - 1 downto 0 do
  begin
    Ability := P2TypeAbility(List, I);
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.FAbilityID) then
      RemoveAbility(Ability.FAbilityID);
  end;
  Release;
end;
procedure TAbstractUnit.RemoveHandicaps;
begin
  AddRef;
  RemoveAbility(93);
  RemoveAbility(98);
  RemoveAbility(53);
  Release;
end;
{ needs: draft P1 TAbilityOwner.GetAbilityData(ID: Integer): TAbilityData;
  calls 5577F2EB/5577F3F1 return a pointer with enchantment at +10. }
function P2AbilityData(AOwner: TAbilityOwner; ID: Integer): TAbilityData; assembler;
asm JMP TAbilityOwner.GetAbilityData end;
procedure TAbstractUnit.RegisterEnchantments;
var
  Ability: TAbility;
  I: Integer;
  List: TAbilityTypeList;
  Data: TUnitEnchantmentAbilityData;
begin
  List := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  for I := List.Count - 1 downto 0 do
  begin
    Ability := P2TypeAbility(List, I);
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.FAbilityID) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.FAbilityID));
      if Shortint(TUnitEnchantment(Data.FEnchantment).FSource) > -1 then
        TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),
          Shortint(TUnitEnchantment(Data.FEnchantment).FSource)).FMagicControl).
          RegisterEnchantment(Data.FEnchantment);
    end;
  end;
end;
procedure TAbstractUnit.UnregisterEnchantments;
var
  Ability: TAbility;
  I: Integer;
  List: TAbilityTypeList;
  Data: TUnitEnchantmentAbilityData;
begin
  List := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  for I := List.Count - 1 downto 0 do
  begin
    Ability := P2TypeAbility(List, I);
    if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.FAbilityID) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.FAbilityID));
      if Shortint(TUnitEnchantment(Data.FEnchantment).FSource) > -1 then
        TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),
          Shortint(TUnitEnchantment(Data.FEnchantment).FSource)).FMagicControl).
          UnregisterEnchantment(Data.FEnchantment);
    end;
  end;
end;
{ needs: draft P1 TAbilityControl.GetAbility(ID: Integer): TAbility;
  5577F3C3 returns the class-tested pointer. }
function P2ControlAbility(Control: TAbilityControl; ID: Integer): TAbility; assembler;
asm JMP TAbilityControl.GetAbility end;
function TAbstractUnit.AbilityToEnchantment(AbilityID: Integer): TUnitEnchantment;
var
  Ability: TAbility;
  Data: TUnitEnchantmentAbilityData;
begin
  Ability := P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID);
  if (Ability is TUnitEnchantmentAbility) and GetAbilityEnabled(Ability.FAbilityID) then
  begin
    Data := TUnitEnchantmentAbilityData(P2AbilityData(Self, Ability.FAbilityID));
    if Data <> nil then Result := TUnitEnchantment(Data.FEnchantment)
    else begin Result := nil; Exit; end;
  end
  else Result := nil;
end;
function TAbstractUnit.CanDispelEnchantment(Player: Shortint): Boolean;
var
  I: Integer;
  List: TAbilityTypeList;
  Enchantment: TUnitEnchantment;
begin
  List := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  I := List.Count;
  Result := False;
  while not Result and (I <> 0) do
  begin
    Dec(I);
    Enchantment := AbilityToEnchantment(P2TypeAbility(List, I).FAbilityID);
    if (Enchantment = nil) or (Player = Shortint(Enchantment.FSource)) then
      Result := False
    else Result := True;
  end;
end;
procedure TAbstractUnit.ListEnchantments(List: TECustomNode);
var
  I: Integer;
  Abilities: TAbilityTypeList;
  Enchantment: TUnitEnchantment;
begin
  Abilities := TP2AbilityControlFields(AoWHSSet.FAbilityControl).Enchantments;
  for I := Abilities.Count - 1 downto 0 do
  begin
    Enchantment := AbilityToEnchantment(P2TypeAbility(Abilities, I).FAbilityID);
    if Enchantment <> nil then List.AddChild(Enchantment);
  end;
end;
procedure TAbstractUnit.SetPlayer(Player: Shortint);
var
  List: TUnitUserList;
begin
  if Player <> Shortint(FPlayer) then
  begin
    AddRef;
    ResetLifeMasteryBlessing;
    ResetLifeMasteryFear;
    ResetEarthMasteryStoneSkin;
    ResetFireMasteryProtection;
    List := TUnitUserList(FGroup);
    if List <> nil then List.DeleteUnit(Self);
    FPlayer := Player;
    Release;
  end;
end;
function P2AlignmentToIR(Alignment: TAlignment): Shortint; assembler;
asm JMP AlignmentToIR end;
function TAbstractUnit.GetIndependentRelation: Shortint;
begin
  if GetRace >= 0 then Result := GetRace
  else Result := P2AlignmentToIR(GetAlignment);
end;
procedure TAbstractUnit.SetOwner(AOwner: Engine.TECustomNode);
begin
  if AOwner <> FOwner then
  begin
    AddRef;
    if FOwner <> nil then FOwner.RemoveChild(Self);
    FOwner := AOwner;
    if FOwner <> nil then
      if FOwner.AddChild(Self) = -1 then FOwner := nil;
    Release;
  end;
end;
function TAbstractUnit.GetAbilityCount: Integer;
begin
  Result := FAbilityCount;
end;
function TAbstractUnit.GetInherentAbility(AbilityID: Integer): Boolean;
begin
  if TP2AbilityCalls(Self).GetAbSet(AbilityID) then
  begin
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID)).AbilityInherent(Self);
    Exit;
  end;
  Result := False;
end;
function TAbstractUnit.GetInherentAbilityLevel(AbilityID: Integer): Integer;
begin
  if TP2AbilityCalls(Self).GetAbSet(AbilityID) then
  begin
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID)).AbilityInherentLevel(Self);
    Exit;
  end;
  Result := 0;
end;
function TAbstractUnit.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin
  if GetAbilitySet(AbilityID) then
  begin
    Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID)).AbilityEnabled(Self);
    Exit;
  end;
  Result := False;
end;
function TAbstractUnit.GetAbilitySet(AbilityID: Integer): Boolean;
asm
  CMP EDX,[EAX].FAbilityCount
  JAE @@Default
  MOV EAX,DWORD PTR [EAX+8]
  BT [EAX],EDX
  SBB EAX,EAX
  AND EAX,1
  RET
@@Default:
  MOV AL,0
  AND EAX,1
end;
function TAbstractUnit.GetAbilityName(AbilityID: Integer): string;
begin
  Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID)).AbilityName(Self);
end;
function TAbstractUnit.GetAbilityLevel(AbilityID: Integer): Integer;
begin
  Result := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), AbilityID)).AbilityLevel(Self);
end;
function TAbstractUnit.GetAbilityOwner(AbilityID: Integer): TAbilityOwner;
begin
  if TP2AbilityCalls(Self).GetAbSet(AbilityID) then
  begin Result := Self; Exit; end;
  Result := nil;
end;
procedure P2TranslateRStr(const Text: string; var Dest: string); assembler;
asm JMP TranslateRStr end;
function TAbstractUnit.GetOwnerName: string;
begin
  { needs: draft ancestor GetOwnerName is a string result; current A1 is its
    hidden result pointer, proved by EDX at 5577F6A2 and 5577F6C2. }
  P2TranslateRStr(P2InherentRStr, Result);
end;
function TAbstractUnit.RemoveAbility(A1: Integer): Boolean;
asm
  { needs: draft P1 TAbilityOwner.RemoveAbility(ID: Integer): Boolean.
    Preserve the returned EAX across Release, as at 5577F703..5577F70C. }
  PUSH EBX
  PUSH ESI
  PUSH EDI
  MOV ESI,EDX
  MOV EDI,EAX
  MOV EAX,EDI
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+28H]
  MOV EDX,ESI
  MOV EAX,EDI
  CALL TAbilityOwner.RemoveAbility
  MOV EBX,EAX
  MOV EAX,EDI
  MOV EDX,[EAX]
  CALL DWORD PTR [EDX+2CH]
  MOV EAX,EBX
  POP EDI
  POP ESI
  POP EBX
end;
procedure TAbstractUnit.UpdateDefensiveStrength;
begin
  FDefensiveStrength := (GetDefense + 10 + GetResistance) * (GetHitPoints + 10);
  if FDefensiveStrength < 0 then FDefensiveStrength := 1;
end;
function P2VMTAbility(List: TAbilityTypeList; Index: Integer): TP2AbilityCalls; assembler;
asm JMP TAbilityTypeList.GetAbility end;
procedure TAbstractUnit.UpdateOffensiveStrength; const AssertFile: string = 'D:\AoWDev\AoWE\inc\Unit.PAS'; { Preserve the original diagnostic; asm references both strings so cleanup stays paired. } { Tried managed local declaration order; hidden managed expression instead of explicit names; still differs. }
var
  DamageType: TDamageType;
  Ability: TP2AbilityCalls;
  DamageTypes: TDamageTypes;
  I, Strength: Integer;
  Abilities: TAbilityTypeList; AssertMessage, AssertName: string;
begin
  Abilities := TP2AbilityControlFields(AoWHSSet.FAbilityControl).CombatAbilities;
  FMaxOffensiveStrength := 0;
  FillChar(FOffensiveStrength, SizeOf(FOffensiveStrength), 0);
  for I := Abilities.Count - 1 downto 0 do
  begin
    Ability := P2VMTAbility(Abilities, I);
    if GetAbilityEnabled(Ability.AbilityID) then
    begin
      Ability.OffensiveStrength(Self, Strength, DamageTypes);
      if Strength > 255 then Strength := 255;
      if DamageTypes = [] then begin AssertName := Ability.AbilityName(nil); AssertMessage := 'Ability: ' + AssertName; asm LEA EAX,AssertName; MOV ECX,$E2B4; MOV EDX,AssertFile; MOV EAX,AssertMessage; CALL System.@Assert end end;
      if DamageTypes <> [] then
      begin
        if FMaxOffensiveStrength < Strength then FMaxOffensiveStrength := Strength;
        for DamageType := Low(TDamageType) to High(TDamageType) do
          if DamageType in DamageTypes then
            if FOffensiveStrength[DamageType] < Strength then
              FOffensiveStrength[DamageType] := Strength;
      end;
    end;
  end;
end;
function TAbstractUnit.GetStrength(DamageType: TDamageType): Integer;
begin
  if not (usActivated in FUnitStatus) then
  begin UpdateDefensiveStrength; UpdateOffensiveStrength; end;
  Result := FOffensiveStrength[DamageType];
  if Result <> 0 then Result := (Result + 10) * FDefensiveStrength;
end;
function TAbstractUnit.GetStrengthMax(DamageTypes: TDamageTypes): Integer;
const
  AllDamageTypes: TDamageTypes = [Low(TDamageType)..High(TDamageType)];
var
  DamageType, BestType: TDamageType;
begin
  if not (usActivated in FUnitStatus) then
  begin UpdateDefensiveStrength; UpdateOffensiveStrength; end;
  if DamageTypes <> AllDamageTypes then
  begin
    Result := 0;
    for DamageType := Low(TDamageType) to High(TDamageType) do
      if DamageType in DamageTypes then
        if Result < FOffensiveStrength[DamageType] then
        begin
          BestType := DamageType;
          Result := FOffensiveStrength[DamageType];
        end;
    if Result <> 0 then Result := (Result + 10) * FDefensiveStrength;
  end
  else if FMaxOffensiveStrength <> 0 then
    Result := (FMaxOffensiveStrength + 10) * FDefensiveStrength
  else Result := 0;
end;
function TAbstractUnit.GetCombatValue(Target: TAbstractUnit; Mode: Byte): Integer;
var
  I, Value: Integer;
  Abilities: TAbilityTypeList;
  Ability: TAbility;
  Info: TAbilityDamageValues;
begin
  Result := 0;
  Abilities := AoWHSSet.FAbilityControl.FAbilitiesByType[atCombat];
  for I := Abilities.Count - 1 downto 0 do
  begin
    Ability := Abilities.GetAbility(I);
    if GetAbilityEnabled(Ability.FAbilityID) then
    begin
      Ability.GetDamageValueEx(Self, Target, TWallSituation(Mode), Info);
      if Info.SourceDamage > 0 then
      begin
        Value := Info.SourceDamage * Info.SourceDamage div (Info.TargetDamage + Info.SourceDamage);

        if Value <= 0 then Value := 1;
        if Value > Result then Result := Value;
      end;
    end;
  end;
end;
procedure TAbstractUnit.ListAbilityInfo(Names, Types, Sources: TStrings);
var
  I: Integer;
  AOwner: TAbilityOwner;
  Ability: TP2AbilityCalls;

  Name, Source: string;
begin
  Names.Clear;
  if Sources <> nil then Sources.Clear;
  for I := 0 to GetAbilityCount - 1 do
    if GetAbilitySet(I) then
    begin
      AOwner := GetAbilityOwner(I);
      Ability := TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), I));
      Name := Ability.AbilityName(AOwner);
      if Name <> '' then Names.AddObject(Name, TObject(I));
      if Types <> nil then
      begin
        Types.AddObject(TranslateRStr(TAbilityTypeRStr[TP2AbilityCalls(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl), I)).AbilityType]),
          TObject(I));
      end;
      Source := Ability.SourceName(AOwner);
      if Sources <> nil then Sources.AddObject(Source, TObject(I));
    end;
end;
function TAbstractUnit.GetDescription: TStrings;
begin
  Result := nil;
end;
function TAbstractUnit.CanActivate: Boolean;
begin
  Result := True;
end;
function TAbstractUnit.GetExperience: Integer;
begin
  Result := 0;
end;
procedure TAbstractUnit.SetExperience(Value: Integer);
begin end;
function TAbstractUnit.GetNextLevelExperience: Integer;
begin
  Result := 0;
end;
{ needs: draft P5 TAIGroupList.FindID(ID: Integer): TAIGroup;
  5577FBD9..5577FBE6 passes saved group ID in EDX and uses returned object. }
function P2FindGroup(List: TAIGroupList; ID: Integer): TAIGroup; assembler;
asm JMP TAIGroupList.FindID end;
procedure TAbstractUnit.Activate;
var
  Group: TAIGroup;
begin
  FUnitStatus := FUnitStatus + [usActivated];
  TUnitControl(AoWHSMap.FUnitControl).RegisterUnit(Self);
  if (FGroupID <> 0) and (FPlayer >= 0) then
  begin
    Group := P2FindGroup(TAIGroupList(AoWHSMap.FAIGroupManager), FGroupID);
    if Group <> nil then Group.AddUnit(Self)
    else FGroupID := 0;
  end
  else FGroupID := 0;
  RegisterEnchantments;
  Changed;
end;
procedure TAbstractUnit.Deactivate;
var
  Group: TUnitUserList;
begin
  Group := FGroup;
  if Group <> nil then Group.DeleteUnit(Self);
  TUnitControl(AoWHSMap.FUnitControl).UnRegisterUnit(Self);
  FUnitStatus := FUnitStatus - [usActivated];
  UnregisterEnchantments;
end;
function TAbstractUnit.GetAlignment: TAlignment;
begin
  Result := alNeutral;
end;
function TAbstractUnit.GetUpkeep: Byte;
begin
  if not GetAbilityEnabled(155) then
  begin Result := (GetUnitLevel + 1) * 2; Exit; end;
  Result := 0;
end;
function TAbstractUnit.GetManaUpkeep: Integer;
var
  Enchantment: TEnchantment;
begin
  if GetAbilityEnabled(155) then
  begin
    Enchantment := TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,155)).FEnchantment);
    if Enchantment <> nil then Result := Enchantment.FUpkeep
    else begin Result := 0; Exit; end;
  end
  else Result := 0;
end;
function TAbstractUnit.GetUnitLevel: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetTransportCapacity: Byte;
begin
  Result := 0;
end;
function TAbstractUnit.GetMovePoints: Shortint;
begin
  Result := 0;
end;
procedure TAbstractUnit.SetMovePoints(Value: Shortint);
begin end;
function TAbstractUnit.GetHitPoints: Shortint;
begin
  Result := 0;
end;
procedure TAbstractUnit.SetHitPoints(Value: Shortint);
begin
  UpdateDefensiveStrength;
end;
function TAbstractUnit.GetTransporting: Boolean;
var
  Xhx, Yhx, Lhx: Shortint;
  MapField: TMapField;
begin
  GetLocation(Xhx,Yhx,Lhx);
  if Xhx <> -1 then
  begin
    MapField := AoWHSMap.MapContainer.GetField(Xhx,Yhx,Lhx);
    Result := not ValidTerrain(MapField.TerrainType, MapField.OverlayType);
  end
  else Result := False;
end;
procedure TAbstractUnit.UnitKilled;
begin end;
function TAbstractUnit.GetTransporter: Boolean;
begin
  Result := GetTransportCapacity <> 0;
end;
function P2AbImmunity(AOwner: TAbilityOwner): TDamageTypes; assembler;
asm JMP TAbilityOwner.GetAbImmunityTypesAll end;
function TAbstractUnit.GetImmunityTypes: TDamageTypes;
begin
  Result := P2AbImmunity(Self) + [dtWall];
end;
function P2AbProtection(AOwner: TAbilityOwner): TDamageTypes; assembler;
asm JMP TAbilityOwner.GetAbProtectionTypesAll end;
function TAbstractUnit.GetProtectionTypes: TDamageTypes;
begin
  Result := P2AbProtection(Self);
end;
function TAbstractUnit.GetUnitType: TUnitType;
begin
  Result := utHumanoid;
end;
function TAbstractUnit.GetInherentAttack: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetAttack: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetInherentDefense: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetDefense: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetInherentDamage: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetDamage: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetInherentResistance: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetResistance: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetHits: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetMoves: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetPowerGeneration: Integer;
begin
  Result := 0;
end;
function TAbstractUnit.GetCastingPointsMax: Shortint;
begin
  Result := 0;
end;
function TAbstractUnit.GetCastingPoints: Shortint;
begin
  Result := 0;
end;
procedure TAbstractUnit.SetCastingPoints(Value: Shortint);
begin end;
function P2MoveTypesToInt(MoveTypes: TMoveTypes): Integer; assembler;
asm JMP MoveTypesToInt end;
procedure TAbstractUnit.CreateMovePointTable(var Table: TP2MovePointTable);
var
  Moves: TMoveTypes;
  Terrain, Overlay: Integer;
  { Integer loop indexes retain the original table walk. }
  Points: Integer; Value: Shortint;
  Faster, Slower: Boolean;
begin
  Moves := GetMoveTypes;
  if AoWHSMap.FCombat <> nil then Moves := Moves - [mtTunneling];
  Table := MovePointTables[P2MoveTypesToInt(Moves)];
  if FPlayer > 0 then
  begin
    if (petEnchantedRoads in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FActiveEnchantments) then
      for Terrain := 0 to 15 do
        if Table[Terrain,4] <> -1 then Table[Terrain,4] := 2;
    if GetAbilityEnabled(23) or GetAbilityEnabled(1) or GetAbilityEnabled(165) then
    begin
      Faster := (petAirMastery in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FActiveEnchantments);
      Slower := Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FEnemyEnchantments) and 4 <> 0;
      if Faster and not Slower then
      begin
        for Overlay := -1 to 11 do
          for Terrain := 0 to 15 do
            begin Value := Table[Terrain,Overlay]; if Smallint(Value) > 2 then
              Table[Terrain,Overlay] := (Integer(Value) + 1) shr 1; end;
      end
      else if not Faster and Slower then
        for Overlay := -1 to 11 do
          for Terrain := 0 to 15 do
            if Table[Terrain,Overlay] >= 1 then Table[Terrain,Overlay] := Table[Terrain,Overlay] * 2;
    end;
    if GetAbilityEnabled(152) then
      for Overlay := -1 to 11 do
        for Terrain := 0 to 15 do
        begin
          Points := Table[Terrain,Overlay];
          if Points > 2 then
          begin
            Dec(Points);
            { Original retains this redundant lower bound after Points > 2. }
            if Points < 2 then Points := 2;
          end;
          Table[Terrain,Overlay] := Points;
        end;
    if GetAbilityEnabled(132) then
      for Overlay := -1 to 11 do
        for Terrain := 0 to 15 do
          begin Points := Table[Terrain,Overlay]; if Points > 0 then Table[Terrain,Overlay] := Points + 2; end;
  end;
end;
function TAbstractUnit.GetMoveTypes: TMoveTypes;
begin
  Result := GetAbMoveTypesAll;
end;
function TAbstractUnit.GetFace: TLibraryImage;
begin
  Result := nil;
end;
function TAbstractUnit.GetName: string;
begin
  Result := '';
end;
function TAbstractUnit.GetPreviewImage: TLibraryImage;
begin
  Result := nil;
end;
function TAbstractUnit.GetUnitGFXResourceIndex: Integer;
begin
  Result := -1;
end;
function TAbstractUnit.ValidTerrain(TerrainType, OverlayType: Shortint): Boolean;
var
  Moves: TMoveTypes;
  Cost: Shortint;
begin
  { Original retrieves the movement set twice and retains the first dead store. }
  Moves := GetMoveTypes;
  Cost := MovePointTables[P2MoveTypesToInt(GetMoveTypes)][TerrainType,OverlayType];
  if (Cost = -1) or (Cost > GetMoves) then Result := False
  else Result := True;
end;
{ needs: draft P1 return types; call sites 5578011B/5578012A/55780149. }
function P2DiplomaticRelation(Relations: TPlayerDiplomaticRelations; Player: Integer): TDiplomaticRelation; assembler;
asm JMP TPlayerDiplomaticRelations.GetDiplomaticRelation end;
function P2Explored(MapField: TAoWMapField; Player: Integer): Boolean; assembler;
asm JMP TAoWMapField.GetExplored end;
function P2VisibleForPlayer(Map: TAoWHSMap; X,Y,L,Player: Integer): Boolean; assembler;
asm POP EBP; JMP TAoWHSMap.VisibleForPlayer end;
procedure TAbstractUnit.ExecuteTrailOfDarkness(MapField: TMapField); { Keep Field and MapField addressable. }
var
  Level: TMapLevel;
  Walk: THNWalkData;
  Field: TAoWMapField;
  Player: Integer; Spill: Pointer;
begin
  Spill := @Field; Spill := @MapField; Level := TMapLevel(MapField.Owner);
  InitHNWalk(Walk,MapField.Xhx,MapField.Yhx,0);
  while Walk.Radius <= 1 do
  begin
    if (Walk.X >= 0) and (Walk.X < Level.Width) and
       (Walk.Y >= 0) and (Walk.Y < Level.Height) then
    begin
      Field := TAoWMapField(Level.GetField(Walk.X,Walk.Y));
      if Smallint(Field.TerrainType) <> Ord(ttBorder) then
        for Player := 1 to TPlayerList(AoWHSMap.FPlayers).Count - 1 do
          if (Player <> FPlayer) and
             (P2DiplomaticRelation(TPlayerDiplomaticRelations(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FDiplomaticRelations),Player) = drWar) and
             P2Explored(Field,Player) and
             not P2VisibleForPlayer(AoWHSMap,Walk.X,Walk.Y,MapField.Lhx,Player) then
            Field.SetExplored(Player,False);
    end;
    WalkToNextHN(Walk);
  end;
  AoWHSMap.MapChangedRad(MapField.Xhx,MapField.Yhx,MapField.Lhx,1);
end;
procedure TAbstractUnit.PathOfLifeTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
begin
  if (Smallint(TerrainType) <> Ord(ttIce)) and (Smallint(TerrainType) <> Ord(ttWater)) and (MapField.Lhx = 0) then
    TerrainType := Ord(ttGrass);
end;
procedure TAbstractUnit.PathOfDecayTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
begin
  if (Smallint(TerrainType) <> Ord(ttIce)) and (Smallint(TerrainType) <> Ord(ttWater)) and (MapField.Lhx = 0) then
    TerrainType := Ord(ttWasteland);
end;
procedure TAbstractUnit.PathOfFrostTerrainChange(MapField: TMapField; var TerrainType, OverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if (Smallint(TerrainType) = Ord(ttWater)) or (Smallint(TerrainType) = Ord(ttUndergroundWater)) then
  begin
    if Smallint(TerrainType) = Ord(ttWater) then TerrainType := Ord(ttIce)
    else TerrainType := Ord(ttUndergroundIce);
  end
  else if TerrainType in [6,13] then
  begin
    Ice := TFrozenWaterHS(MapField.FindOwnedHS(TFrozenWaterHS));
    if Ice <> nil then
    begin Ice.FDaysRemaining := 2; Ice.FCasterPlayer := FPlayer; end;
  end
  else if (TerrainType in [1,2,4,5]) and (MapField.Lhx = 0) then
    TerrainType := Ord(ttSnow);
end;
procedure TAbstractUnit.PathOfFrostTerrainChanged(MapField: TMapField; OriginalTerrainType, OriginalOverlayType: Shortint);
var
  Ice: TFrozenWaterHS;
begin
  if (MapField.TerrainType in [6,13]) and not (OriginalTerrainType in [6,13]) then
  begin
    Ice := TFrozenWaterHS(MapField.FindOwnedHS(TFrozenWaterHS));
    if Ice = nil then
    begin
      Ice := TFrozenWaterHS.Create(nil);
      AoWHSMap.PlaceHX(Ice,MapField.Xhx,MapField.Yhx,MapField.Lhx);
    end;
    Ice.FDaysRemaining := 2;
    Ice.FCasterPlayer := FPlayer;
  end;
end;
procedure TAbstractUnit.UpdatePathOfFrost;
var
  Xhx,Yhx,Lhx: Shortint;
  Field: TMapField;
  Ice: TFrozenWaterHS;
begin
  GetLocation(Xhx,Yhx,Lhx);
  if Xhx > -1 then
  begin
    Field := AoWHSMap.MapContainer.GetField(Xhx,Yhx,Lhx);
    if Field.TerrainType in [6,13] then
    begin
      Ice := TFrozenWaterHS(Field.FindOwnedHS(TFrozenWaterHS));
      if Ice <> nil then
      begin Ice.FDaysRemaining := 2; Ice.FCasterPlayer := FPlayer; end;
    end;
  end;
end;
procedure TAbstractUnit.MovedTo(OldField, NewField: TMapField; MaxCost: Integer);
var
  Cost: Integer; Transported: Boolean;
  Army: TEObject;
begin
  Cost := MovePointCost(NewField.TerrainType,NewField.OverlayType);
  if Cost < 0 then Cost := MaxCost else if Cost > MaxCost then Cost := MaxCost;
  if not AoWHSMap.FUnlimitedMoves or (P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FPlayerType <> ptHuman) then
  begin
    if Cost > GetMovePoints then SetMovePoints(0)
    else SetMovePoints(GetMovePoints - Cost);
  end;
  if Smallint(NewField.TerrainType) = Ord(ttEarth) then
    AoWHSMap.ChangeTerrain(nil,NewField.Xhx,NewField.Yhx,NewField.Lhx,0,Ord(ttDirt));
  if OldField <> nil then
  begin
    Army := Owner;
    Transported := (Army is TArmy) and (TArmy(Army).Transporter($FF) <> nil); if not Transported then
    begin
      if OldField.Lhx = 0 then
      begin
        if GetAbilityEnabled(69) then
          AoWHSMap.ChangeTerrainEx(nil,OldField.Xhx,OldField.Yhx,OldField.Lhx,1,PathOfLifeTerrainChange,nil)
        else if GetAbilityEnabled(68) then
          AoWHSMap.ChangeTerrainEx(nil,OldField.Xhx,OldField.Yhx,OldField.Lhx,1,PathOfDecayTerrainChange,nil);
      end;
      if GetAbilityEnabled(109) then
        AoWHSMap.ChangeTerrainEx(nil,OldField.Xhx,OldField.Yhx,OldField.Lhx,1,PathOfFrostTerrainChange,PathOfFrostTerrainChanged);
    end;
    if GetAbilityEnabled(26) then ExecuteTrailOfDarkness(OldField);
  end;
end;
function P2ConcealmentActive(Field: TAoWMapField): Boolean; assembler;
asm JMP TAoWMapField.GetConcealmentActive end;
function TAbstractUnit.ConcealedOnMapF(Field: TAoWMapField): Boolean;
begin
  if not GetAbilityEnabled(54) and not Field.GetConcealmentActive then
  begin
    Result := GetAbilityEnabled(139) and (Field.Lhx <> 0);
    if (Smallint(Field.OverlayType) <> 1) or not (GetAbilityEnabled(145) or GetAbilityEnabled(162)) then
      begin

      { Original terrain branches overwrite the underground concealment result. }
      case Smallint(Field.TerrainType) of
        1: Result := GetAbilityEnabled(140);
        3: Result := GetAbilityEnabled(141);
        2: Result := GetAbilityEnabled(142);
        5: Result := GetAbilityEnabled(143);
        0,10: Result := GetAbilityEnabled(144);
        4: Result := GetAbilityEnabled(138);
      end; end else Result := True;
  end
  else Result := True;
end;
function TAbstractUnit.ExecuteStormDamage(Storm: TStormType; Distance: Integer): Integer;
var
  Terrain: Shortint;
  Overlay: Shortint;
  Moves: TMoveTypes;
  Xhx,Yhx,Lhx: Shortint;
  Field: TMapField;
  DoubleDamage: Boolean;
  Attack: Integer;
begin
  Moves := GetMoveTypes;
  DoubleDamage := GetAbilityEnabled(23);
  if not DoubleDamage and (mtFlying in Moves) then
  begin
    GetLocation(Xhx,Yhx,Lhx);
    if Xhx <> -1 then
    begin
      Field := AoWHSMap.MapContainer.GetField(Xhx,Yhx,Lhx);
      Terrain := Field.TerrainType;
      Overlay := Field.OverlayType;
      Moves := Moves - [mtFlying];
      DoubleDamage := MovePointTables[P2MoveTypesToInt(Moves)][Terrain,Overlay] = 0;
    end;
  end;
  case Storm of
    stIce: begin Attack := 7; Result := 5; end;
    stLightning: begin Attack := 8; Result := 7; end;
    stDeath: begin Attack := 7; Result := 4; end;
    stHoly: begin Attack := 7; Result := 5; end;
    stFire: begin Attack := 7; Result := 5; end;
    stPestilence: begin Attack := 4; Result := 3; end;
  else Attack := 0; Result := 0;
  end;
  if DoubleDamage then Result := Result * 2;
  Result := ExecuteDamageRole(Attack,Result,[StormDamageType[Storm]]);
  if Result > GetHitPoints then Result := GetHitPoints;
  if Result > 0 then
    case Storm of
      stDeath: ExecuteDamageEffects([dtDeath]);
      stPestilence: ExecuteDamageEffects([dtPoison]);
    end;
  SetHitPoints(GetHitPoints - Result);
  { Result is the final damage. }
end;
function TAbstractUnit.MovePointCost(TerrainType, OverlayType: Shortint): Integer;
var
  Table: TP2MovePointTable;
begin
  CreateMovePointTable(Table);
  Result := Table[TerrainType,OverlayType];
end;
function TAbstractUnit.GetGender: TUnitGender;
begin
  Result := ugNeutral;
end;
procedure TAbstractUnit.Killed;
var
  Group: TUnitUserList;
begin
  FUnitStatus := FUnitStatus + [usKilled];
  ResetLifeMasteryBlessing;
  ResetLifeMasteryFear;
  ResetEarthMasteryStoneSkin;
  ResetFireMasteryProtection;
  UnregisterEnchantments;
  Group := FGroup;
  if Group <> nil then Group.DeleteUnit(Self);
  SetPlayer(-1);
  Changed;
end;
procedure TAbstractUnit.Resurrect;
begin
  TP2OwnerCalls(Self).Expand(128);
  FUnitStatus := FUnitStatus - [usKilled];
  SetHitPoints(1);
  SetPlayer(0);
end;
procedure TAbstractUnit.Animate;
begin
  TP2OwnerCalls(Self).Expand(129);
  FUnitStatus := FUnitStatus - [usKilled];
  SetHitPoints(1);
  SetPlayer(0);
end;
procedure TAbstractUnit.ResetEarthMasteryStoneSkin;
begin
  if GetAbilityEnabled(153) then
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,153)).FEnchantment).FSource) = -2 then
      RemoveAbility(153);
end;
function P2Spell(Control: TSpellControl; ID: Integer): TSpell; assembler;
asm JMP TSpellControl.GetSpell end;
procedure TAbstractUnit.SetEarthMasteryStoneSkin;
var
  Enchantment: TP2EnchantmentCalls;
begin
  if (GetUnitType <> utMachine) and not GetAbilityEnabled(153) then
    if TP2OwnerCalls(Self).Expand(153) then
    begin
      Enchantment := TP2EnchantmentCalls(TUnitEnchantmentAbilityData(P2AbilityData(Self,153)).FEnchantment);
      Enchantment.SetUpkeep(0);
      Enchantment.SetSource(-2);
      Enchantment.Duration := TP2SpellFields(P2Spell(TSpellControl(AoWHSSet.FSpellControl),17)).Duration;
    end;
end;
procedure TAbstractUnit.ResetFireMasteryProtection;
begin
  if GetAbilityEnabled(167) then
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,167)).FEnchantment).FSource) = -2 then
      RemoveAbility(167);
end;
procedure TAbstractUnit.SetFireMasteryProtection;
var
  Enchantment: TP2EnchantmentCalls;
begin
  if not GetAbilityEnabled(71) and not GetAbilityEnabled(167) then
    if TP2OwnerCalls(Self).Expand(167) then
    begin
      Enchantment := TP2EnchantmentCalls(TUnitEnchantmentAbilityData(P2AbilityData(Self,167)).FEnchantment);
      Enchantment.SetUpkeep(0);
      Enchantment.SetSource(-2);
      Enchantment.Duration := 7;
    end;
end;
procedure TAbstractUnit.ResetLifeMasteryBlessing;
begin
  if GetAbilityEnabled(158) then
    if Shortint(TEnchantment(TUnitEnchantmentAbilityData(P2AbilityData(Self,158)).FEnchantment).FSource) = -2 then
      RemoveAbility(158);
end;
procedure TAbstractUnit.SetLifeMasteryBlessing;
var
  Enchantment: TP2EnchantmentCalls;
begin
  if not GetAbilityEnabled(158) then
    if TP2OwnerCalls(Self).Expand(158) then
    begin
      Enchantment := TP2EnchantmentCalls(TUnitEnchantmentAbilityData(P2AbilityData(Self,158)).FEnchantment);
      Enchantment.SetUpkeep(0);
      Enchantment.SetSource(-2);
      Enchantment.Duration := TP2SpellFields(P2Spell(TSpellControl(AoWHSSet.FSpellControl),56)).Duration;
    end;
end;
procedure TAbstractUnit.ResetLifeMasteryFear;
begin
  if GetAbilityEnabled(53) then
    if TUnitEnchantmentAbilityData(P2AbilityData(Self,53)).FEnchantment = TUnitEnchantment(1) then
      RemoveAbility(53);
end;
function P2HitRole(Value: Integer): Boolean; assembler;
asm JMP HitRole end;
procedure TAbstractUnit.ExecuteLifeMasteryFearRole;
var
  Data: TDurationAbilityData;
begin
  if not GetAbilityEnabled(53) and (GetAlignment in [alEvil,alPureEvil]) and
     not GetAbilityEnabled(67) and not GetAbilityEnabled(46) and
     P2HitRole(4 - GetResistance) then
    if TP2OwnerCalls(Self).Expand(53) then
    begin
      Data := TDurationAbilityData(P2AbilityData(Self,53));
      Data.FSource := 1;
      Data.FDuration := 0;
    end;
end;
procedure TAbstractUnit.ValidateLifeMastery;
var
  Player: Shortint;
begin
  Player := FPlayer;
  if Player > 0 then
  begin
    if not (petLifeMastery in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).FMagicControl).FActiveEnchantments) then
      ResetLifeMasteryBlessing;
    if Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FEnemyEnchantments) and 16 = 0 then
      ResetLifeMasteryFear;
  end;
end;
procedure TAbstractUnit.ExecuteDeathMasteryCurseRole;
var
  Data: TDurationAbilityData;
begin
  if not GetAbilityEnabled(93) and (GetAlignment in [alPureGood,alGood]) and
     P2HitRole(6 - GetResistance) then
    if TP2OwnerCalls(Self).Expand(93) then
    begin
      Data := TDurationAbilityData(P2AbilityData(Self,93));
      Data.FSource := 1;
    end;
end;
procedure TAbstractUnit.ValidateDeathMastery;
var
  Player: Shortint;
begin
  Player := FPlayer;
  if Player > 0 then
    if Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).FMagicControl).FEnemyEnchantments) and 32 = 0 then
      if GetAbilityEnabled(93) then
        if TDurationAbilityData(P2AbilityData(Self,93)).FSource = 1 then
          RemoveAbility(93);
end;
procedure TAbstractUnit.NewTurn(Player: Shortint);
var
  Heal: Shortint;
begin
  if Player = FPlayer then
  begin
    SetMovePoints(GetMoves);
    if (GetHits <> GetHitPoints) and not GetAbilityEnabled(93) then
    begin
      if not GetAbilityEnabled(49) then
      begin
        Heal := Round(GetHits * 0.1);
        if Heal = 0 then Heal := 1;
      end
      else Heal := GetHits;
      SetHitPoints(GetHitPoints + Heal);
    end;
    if GetAbilityEnabled(109) then UpdatePathOfFrost;
  end;
end;
procedure TAbstractUnit.NewTurnDone(Player: Shortint);
begin
  if (Player = FPlayer) and (FPlayer > 0) then
  begin
    if (petFireMastery in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FActiveEnchantments) then
      SetFireMasteryProtection;
    if (petEarthMastery in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FActiveEnchantments) then
      SetEarthMasteryStoneSkin;
    if (petLifeMastery in TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FActiveEnchantments) then
      SetLifeMasteryBlessing;
    if Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FEnemyEnchantments) and 16 <> 0 then
      ExecuteLifeMasteryFearRole;
    if Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FEnemyEnchantments) and 32 <> 0 then
      ExecuteDeathMasteryCurseRole;
  end;
end;
function TAbstractUnit.VisibilityRange: Integer;
var
  Level: Integer;
  Xhx,Yhx,Lhx: Shortint;
begin
  Level := GetAbilityLevel(64);
  if Level <> 0 then Result := Level * 2 + 4 else Result := 4;
  GetLocation(Xhx,Yhx,Lhx);
  if ((Lhx <> 0) and not GetAbilityEnabled(39)) or
     ((Lhx = 0) and (FPlayer > 0) and
       (Byte(TPlayerMagicControl(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer).FMagicControl).FEnemyEnchantments) and 8 <> 0)) then
    Result := (Result + 1) shr 1;
end;
function TAbstractUnit.TrueVisionRange: Integer;
begin
  if GetAbilityEnabled(41) then begin Result := VisibilityRange; Exit; end;
  Result := 1;
end;
procedure P2UnitChanged(Map: TAoWHSMap; AUnit: TAbstractUnit); assembler;
asm JMP TAoWHSMap.UnitChanged end;
procedure TAbstractUnit.Changed;


begin
  if usActivated in FUnitStatus then
  begin
    UpdateMoraleValue;
    UpdateOffensiveStrength;
    UpdateDefensiveStrength;
    UpdateEnchanted;
    if AoWHSMap <> nil then P2UnitChanged(AoWHSMap,Self);
  end;

  if (Owner <> nil) and (Owner is TUnitList) then TUnitList(Owner).Changed;
end;
function P2FieldPlayer(Field: TAoWMapField): Shortint; assembler;
asm JMP TAoWMapField.GetPlayer end;
function TAbstractUnit.CanPlace(X,Y,L: Integer; Player: Shortint; Mode: TUnitPlaceMode): Boolean;
var
  Field: TAoWMapField;
  ArmyHS: TArmyHS;
  FieldPlayer: Shortint;
begin
  if (X >= 0) and (Y >= 0) and (X < AoWHSMap.MapContainer.Width) and (Y < AoWHSMap.MapContainer.Height) then
  begin
    Field := TAoWMapField(AoWHSMap.MapContainer.GetField(X,Y,L));
    FieldPlayer := P2FieldPlayer(Field);
    if (pmNeglectEmptyPlayerLocation in Mode) or (FieldPlayer = Player) or (FieldPlayer = -1) or (Player = -1) then
    begin
      ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(X,Y,L).FindOwnedChild($20217));
      if ArmyHS <> nil then
      begin
        if (pmCreateNewArmy in Mode) or
           ((Player <> -1) and (Shortint(ArmyHS.FArmy.FPlayer) <> Player)) or
           not TP2AbilityCalls(ArmyHS.FArmy).CanAddUnit(Self) then Result := False
        else Result := True;
      end
      else Result := ValidTerrain(Field.TerrainType,Field.OverlayType);
    end
    else Result := False;
  end
  else Result := False;
end;
function TAbstractUnit.Place(X,Y,L: Integer; Player: Shortint; Mode: TUnitPlaceMode): TArmyHS;
var
  Walk: THNWalkData;
  ArmyHS: TArmyHS;
begin
  Result := nil;
  InitHNWalk(Walk,X,Y,0);
  while (Result = nil) and ((Walk.Radius = 0) or (pmScanArea in Mode)) and (Walk.Radius < 30) do
  begin
    if CanPlace(Walk.X,Walk.Y,L,Player,Mode) then
    begin
      ArmyHS := TArmyHS(AoWHSMap.MapContainer.GetField(Walk.X,Walk.Y,L).FindOwnedChild($20217));
      if ArmyHS = nil then
      begin
        ArmyHS := TArmyHS.Create(nil);
        if Player <> -1 then ArmyHS.FArmy.SetPlayer(Player);
        if not TP2AbilityCalls(ArmyHS.FArmy).AddUnit(Self) or not AoWHSMap.PlaceHX(ArmyHS,Walk.X,Walk.Y,L) then
        begin ArmyHS.Free; ArmyHS := nil; end;
        Result := ArmyHS;
      end
      else if TP2AbilityCalls(ArmyHS.FArmy).AddUnit(Self) then Result := ArmyHS
      else Result := nil;
    end;
    if Result = nil then WalkToNextHN(Walk);
  end;
end;
function TAbstractUnit.CanAddToList(AList: TUnitList): Boolean;
begin
  Result := True;
end;
procedure TAbstractUnit.NewDay;
begin end;
procedure TAbstractUnit.ValidateCrusader; { Retain the identity Self cast for allocation. }
var
  Data: TDurationAbilityData;
begin
  Self := TAbstractUnit(Pointer(Self)); Data := TDurationAbilityData(GetAbilityData(101));
  if Data <> nil then
    if Data.FDuration <= 0 then Killed;
end;
procedure TAbstractUnit.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject); { Tried Self identity, Pointer identity, typed with; base sender cast; still differs. }
begin
  inherited MsgProc(Msg,Sender);
  if Msg.MsgID = $20020002 then
  begin NewTurn(Shortint(Msg.Value)); Exit; end
  else if Msg.MsgID = $20020003 then NewTurnDone(Shortint(Msg.Value))
  else if Msg.MsgID = $20020001 then NewDay
  else if Msg.MsgID = $20020100 then ValidateLifeMastery
  else if Msg.MsgID = $20020101 then ValidateDeathMastery;
end;
procedure TAbstractUnit.Show(X,Y: Integer; const SD: TSurfaceDesc);
var
  Info: TP2UnitShowInfo;
begin
  Info.Direction := 3;
  Info.Overlays := [uoHitPoints,uoRank];
  Info.Animation := uaStandStill;
  Info.Frame := 0;
  Info.Looped := False;
  ShowEx(X,Y,SD,Info);
end;
function P2HitPercent(HitPoints, Hits: Shortint): Byte; assembler;
asm JMP HitPointsToHitPcnt end;
procedure P2ShowHitPercent(X,Y: Integer; const SD: TSurfaceDesc; Percent: Byte); assembler;
asm POP EBP; JMP ShowHitPcnt end;
function TAbstractUnit.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer; { Tried Self identity, Pointer identity, typed with; still differs. }
var
  Sequence: TImageSequence;
  Frame, TotalFrames, ResourceIndex: Integer;
begin
  Result := 0;
  ResourceIndex := GetUnitGFXResourceIndex;
  TUnitGFXResourceList(AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).AddRef;
  if Info.Animation <> uaNone then
  begin
    Sequence := TImageSequence(TUnitGFXResourceList(AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).FSequences.List^[Ord(Info.Animation) * 6 + Info.Direction - 1]);
    if Sequence <> nil then
    begin
      if not Info.Looped then
      begin
        TotalFrames := Sequence.GetTotalSequenceFrames;
        Frame := Sequence.GetUnloopedFrameIndex(Info.Frame);
        if Frame >= 0 then
          Sequence.ImageLibrary[Frame].Show(X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD)
        else
          TUnitGFXResourceList(AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).Show(Info.Direction,X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD);
        if TotalFrames - Info.Frame > Result then Result := TotalFrames - Info.Frame;
      end
      else
      begin
        Frame := Sequence.GetFrameIndex(Info.Frame,(Integer(Self) shr 2) and $FFFF);
        if Frame >= 0 then
          Sequence.ImageLibrary[Frame].Show(X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD);
        Result := 1;
      end;
      Sequence := Sequence.Next;
      while Sequence <> nil do
      begin
        Frame := Sequence.GetFrameIndex(Info.Frame,0);
        if Frame >= 0 then
          Sequence.ImageLibrary[Frame].Show(X + Sequence.dXshift + 16,Y + Sequence.dYshift + 20,SD);
        Sequence := Sequence.Next;
      end;
    end
    else Result := -1;
  end
  else Result := -1;
  if GetAbilityEnabled(96) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),96).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),96).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(98) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),98).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),98).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if GetAbilityEnabled(93) then
    if Info.Looped then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),93).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),93).FImageSequences).Show(0,X+32,Y+32,4,SD);
  if uoHitPoints in Info.Overlays then
    P2ShowHitPercent(X,Y,SD,P2HitPercent(GetHitPoints,GetHits));
  if uoCombat in Info.Overlays then
  begin
    if GetHitPoints = 0 then
      TCustomImageLibrary(AoWHSSet.FCombatImages)[4].Show(X+18,Y+10,SD);
    if GetAbilityEnabled(48) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),48).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(150) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),150).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(149) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),149).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(97) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),97).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(92) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),92).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(95) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),95).FImageSequences).ShowLooped(0,X+32,Y+32,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(94) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),94).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(127) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),127).FImageSequences).ShowLooped(0,X+32,Y+35,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(107) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),107).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
    if GetAbilityEnabled(34) then
      TImageSequenceList(P2ControlAbility(TAbilityControl(AoWHSSet.FAbilityControl),34).FImageSequences).ShowLooped(0,X+32,Y+40,AoWHSMap.Frame,SD);
  end;
  if usEnchanted in FUnitStatus then
    if Info.Looped then
      TImageSequenceList(AoWHSSet.FImageSequences).ShowLooped(70,X+32,Y+40,AoWHSMap.Frame,SD)
    else
      TImageSequenceList(AoWHSSet.FImageSequences).Show(70,X+32,Y+40,5,SD);
  TUnitGFXResourceList(AoWHSSet.FUnitGFXResources).GetUnitGFXResource(ResourceIndex).Release;
end;
procedure TAbstractUnit.ShowFace(const R: TRect; const SD: TSurfaceDesc);
var
  Image: TLibraryImage;
begin
  Image := GetFace;
  if Image <> nil then Image.ShowStretched(R,SD);
  if GetAbilityEnabled(129) then
    if AoWHSMap <> nil then
      if TCustomImageLibrary(AoWHSSet.FGeneralImages)[45] <> nil then
        TCustomImageLibrary(AoWHSSet.FGeneralImages)[45].ShowStretched(R,SD);
end;
function P2DamageRole(Damage, DC: Integer): Integer; assembler;
asm JMP ExecuteDamageRole end;
function TAbstractUnit.ExecuteDamageRole(Attack, Damage: Integer; DamageTypes: TDamageTypes): Integer;
var
  Active: TDamageTypes; DC: Integer;
begin
  Result := 0;
  Active := DamageTypes - GetImmunityTypes;
  if Active <> [] then
  begin
    DC := Attack - GetDefense; Result := P2DamageRole(Damage, DC);
    if Active - GetProtectionTypes = [] then Result := (Result + 1) div 2;
  end;
end;
function TAbstractUnit.ExecuteResistanceRole(Attack: Integer; DamageType: TDamageType): Boolean;
begin
  if not (DamageType in GetImmunityTypes) then
  begin
    if DamageType in GetProtectionTypes then Dec(Attack,2);
    Result := P2HitRole(Attack - GetResistance);
  end
  else Result := False;
end;
function TAbstractUnit.ExecuteDamageEffectsRole(DamageTypes: TDamageTypes): TDamageTypes;
var
  Active, Protection: TDamageTypes;
  Resistance, EffectiveResistance: Integer;
begin
  Result := [];
  Active := DamageTypes - GetImmunityTypes;
  if Active <> [] then
  begin
    Resistance := GetResistance;
    Protection := GetProtectionTypes;
    if (dtFire in Active) and not GetAbilityEnabled(7) then
    begin
      if dtFire in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(4 - EffectiveResistance) then
        Result := Result + [dtFire];
    end;
    if (dtLightning in Active) and (GetUnitType <> utMachine) and not GetAbilityEnabled(9) then
    begin
      if dtLightning in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(6 - EffectiveResistance) then
        Result := Result + [dtLightning];
    end;
    if (dtPoison in Active) and not GetAbilityEnabled(10) then
    begin
      if dtPoison in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(3 - EffectiveResistance) then
        Result := Result + [dtPoison];
    end;
    if (dtDeath in Active) and not GetAbilityEnabled(11) then
    begin
      if dtDeath in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(4 - EffectiveResistance) then
        Result := Result + [dtDeath];
    end;
    if (dtHoly in Active) and not GetAbilityEnabled(12) then
    begin
      if dtHoly in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(3 - EffectiveResistance) and (GetUnitType <> utMachine) then
        Result := Result + [dtHoly];
    end;
    if (dtCold in Active) and not GetAbilityEnabled(8) then
    begin
      if dtCold in Protection then EffectiveResistance := Resistance + 2
      else EffectiveResistance := GetResistance;
      if P2HitRole(2 - EffectiveResistance) then
        Result := Result + [dtCold];
    end;
  end;
end;
function TAbstractUnit.ExecuteDamageEffects(DamageTypes: TDamageTypes): TDamageTypes;
var
  Active: TDamageTypes;
begin
  Result := [];
  Active := DamageTypes - GetImmunityTypes;
  Active := Active; { Preserve EBX allocation and byte membership tests. } if Active <> [] then
  begin
    if (dtPoison in Active) and TP2OwnerCalls(Self).Expand(96) then
      Result := Result + [dtPoison];
    if (dtDeath in Active) and TP2OwnerCalls(Self).Expand(93) then
      Result := Result + [dtDeath];
    if (dtHoly in Active) and TP2OwnerCalls(Self).Expand(98) then
      Result := Result + [dtHoly];
  end;
end;
function TAbstractUnit.ExecuteCombatDamageEffects(Combat: TCombat; DamageTypes: TDamageTypes): TDamageTypes; { Retain the eliminated Active assignment for allocation. }
var
  Active: TDamageTypes;
  Data: TUnitEnchantmentAbilityData;
begin
  Result := [];
  Active := DamageTypes - GetImmunityTypes;
  Active := Active; if Active <> [] then
  begin
    if (dtFire in Active) and TP2OwnerCalls(Self).Expand(127) then
    begin RemoveAbility(95); Result := Result + [dtFire]; end;
    if (dtCold in Active) and TP2OwnerCalls(Self).Expand(95) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self,95));
      if Data <> nil then Data.FEnchantmentPlayerIndex := TP2CombatTurnFields(Combat.FCombatData).Turn;
      RemoveAbility(127);
      Result := Result + [dtCold];
    end;
    if (dtLightning in Active) and TP2OwnerCalls(Self).Expand(92) then
    begin
      Data := TUnitEnchantmentAbilityData(P2AbilityData(Self,92));
      if Data <> nil then TDurationAbilityData(Data).FPlayerIndex := TP2CombatTurnFields(Combat.FCombatData).Turn;
      Result := Result + [dtLightning];
    end;
    if (dtPoison in Active) and TP2OwnerCalls(Self).Expand(96) then
      Result := Result + [dtPoison];
    if (dtDeath in Active) and TP2OwnerCalls(Self).Expand(93) then
      Result := Result + [dtDeath];
    if (dtHoly in Active) and TP2OwnerCalls(Self).Expand(98) then
      Result := Result + [dtHoly];
  end;
end;
function TAbstractUnit.OptimalDamageType(DamageTypes: TDamageTypes): TDamageType;
var
  Active, Protection: TDamageTypes;
begin
  Result := dtNone;
  Active := DamageTypes - GetImmunityTypes;
  if Active <> [] then
  begin
    Protection := GetProtectionTypes;
    if (Protection = []) or (Active - Protection = []) then
      while not (Result in Active) do Dec(Result)
    else
      while not (Result in Active) or (Result in Protection) do Dec(Result);
  end;
end;
procedure TAbstractUnit.ReadWrite(Stream: Engine.TEStorageStream);
var
  Legacy: TEObject;
begin
  inherited ReadWrite(Stream);
  Stream.rwInteger(FGroupID,4);
  Stream.rwIntegerEx(FUnitID,-1,5);
  Stream.rwByte(Byte(FMoraleValue),6);
  Stream.rwByte(Byte(FPlayer),47);
  if Stream.StorageMode * [smRead,smTextOnly,smCompare] = [smRead] then
  begin
    try
      Legacy := nil;
      Stream.rwCreateEObject(Legacy,nil,48);
      if Legacy <> nil then F_AbstractUnit_38 := TP2LegacyBehaviorCalls(Legacy).Behavior
      else F_AbstractUnit_38 := 0;
      { Original retains the obsolete object loaded for behavior conversion. }
    except
    end;
  end
  else F_AbstractUnit_38 := 0;
end;
{ needs: P1 draft TRace.GetPlayerRelation(Player: Shortint): TStatus,
  DL argument and AL comparison at 55782276. }
function P2RacePlayerRelation(Race: TRace; Player: Shortint): TStatus; assembler;
asm JMP TRace.GetPlayerRelation end;
{ needs: P1 draft dAlignmentToDiplomaticRelation(A, B: TAlignment):
  TDiplomaticRelation, AL/DL at 5578222D. }
function P2AlignmentDiplomaticRelation(A, B: TAlignment): TDiplomaticRelation; assembler;
asm JMP dAlignmentToDiplomaticRelation end;
{ needs: P5 draft THuntAG.HuntingPlayer(Player: Shortint): Boolean,
  DL argument and AL test at 5578230B. }
function P2HuntingPlayer(Group: THuntAG; Player: Shortint): Boolean; assembler;
asm JMP THuntAG.HuntingPlayer end;
function TAbstractUnit.CanJoin(Player: Shortint): Boolean;
var
  Alignment: TAlignment;
  Relation: TDiplomaticRelation;

  I: Integer;
begin

  if (FGroup = nil) or not (FGroup.Behavior in [gbGuard,gbGuardArea]) then
  begin
    if GetRace = -1 then
    begin
      Alignment := P2GetRaceAlignment(P2GetRaceResource(TRaceResourceList(AoWHSSet.FRaceResources),
        Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).FPlayerRace)));
      if GetAlignment <> alNone then
      begin
        Relation := P2AlignmentDiplomaticRelation(GetAlignment,Alignment);
        if (Relation = drUnknown) and (Self is TUnit) then
        begin
          Result := False;
          I := TRaceList(AoWHSMap.FRaces).Count;
          while not Result and (I <> 0) do
          begin
            Dec(I);
            Result := (P2RacePlayerRelation(P2GetRace(TRaceList(AoWHSMap.FRaces),I),Player) >= sPolite) and
              (TIntegerList(P2GetRaceResource(TRaceResourceList(AoWHSSet.FRaceResources),I).FUnitIndexes).
                IndexOf(TUnitResource(TUnit(Self).FUnitResource).UnitResourceIndex) <> -1);
          end;
        end
        else Result := Relation = drPeace;
      end
      else Result := True;
    end
    else Result := P2RacePlayerRelation(P2GetRace(TRaceList(AoWHSMap.FRaces),GetRace),Player) >= sPolite;
    if Result and (FGroup <> nil) and (FGroup.Behavior = gbHunt) and
      P2HuntingPlayer(THuntAG(FGroup),Player) then Result := False;
  end
  else Result := False;
end;
function TAbstractUnit.JoinAmount(Player: Shortint): Integer;
var
  Group: TUnitUserList;
begin
  Group := FGroup;
  if (Group <> nil) and (TP2AbilityCalls(Group).GroupBehavior = gbRefuge) then Result := 0
  else Result := Round(GetObtainValue * 0.75);
end;
function TAbstractUnit.OfferToJoin(Player: Shortint): Boolean;
var
  Group: TUnitUserList;
  Alignment: TAlignment;
begin
  if CanJoin(Player) then
    if GetRace <> -1 then
      Result := P2RacePlayerRelation(P2GetRace(TRaceList(AoWHSMap.FRaces),GetRace),Player) >= sPolite
    else
    begin
      Group := FGroup;
      if (Group <> nil) and (TP2AbilityCalls(Group).GroupBehavior = gbRefuge) then
      begin
        Alignment := P2GetRaceAlignment(P2GetRaceResource(TRaceResourceList(AoWHSSet.FRaceResources),
          Shortint(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),Player).FPlayerRace)));
        if ((GetAlignment <> alNone) or (GetUnitType = utMachine)) and
          (P2AlignmentDiplomaticRelation(GetAlignment,Alignment) <> drPeace) then Result := False
        else Result := True;
      end
      else Result := False;
    end
  else Result := False;
end;
function P2Translate(const Text: string): string; assembler;
asm JMP TranslateRStr end;
{ needs: P1 draft Format(const Text: string; const Args: array of const):
  string, open-array call and hidden result at 55782521. }
function P2Format(const Text: string; const Args: array of const): string; assembler;
asm POP EBP; JMP Format end;
procedure TAbstractUnit.GetJoinMessage(Player: Shortint; Count, Amount: Integer; Mode: TJoinMode; Messages: TStrings);
var
  Group: TUnitUserList;
begin
  Messages.Clear;
  case Mode of
    jmDefault:
      begin
        Group := FGroup;
        if (Group <> nil) and (TP2AbilityCalls(Group).GroupBehavior = gbRefuge) and (Amount = 0) then
          if Count = 0 then Messages.Text := P2Translate(P2RefugeJoinRStr)
          else Messages.Text := P2Translate(P2RefugeesJoinRStr)
        else
          if Count = 0 then Messages.Text := P2Format(P2Translate(P2BribeUnitJoinRStr),[IntToStr(Amount)])
          else Messages.Text := P2Format(P2Translate(P2BribeUnitsJoinRStr),[IntToStr(Amount)]);
      end;
  end;
end;
function TAbstractUnit.CanDisband(var Reason: string): Boolean;
begin
  Result := TP2MapPlayerFields(AoWHSMap).Player = FPlayer;
  if Result and GetTransporter and (Owner is TArmy) then
    Result := TArmy(Owner).UnitsInTransporter = 0;
end;
{ needs: P1 draft TPlayer.GetBusy: Boolean, AL test at 5578263D. }
function P2PlayerBusy(Player: TPlayer): Boolean; assembler;
asm JMP TPlayer.GetBusy end;
function TAbstractUnit.Disband: Boolean;
var
  Reason: string;
  Event: TDisbandUnitTE;
begin
  if CanDisband(Reason) and not P2PlayerBusy(P2GetPlayers(TPlayerList(AoWHSMap.FPlayers),FPlayer)) then
  begin
    Event := TDisbandUnitTE.Create(nil);
    Event.FUnitID := FUnitID;
    Event.FPlayer := FPlayer;
    TTokenManager(AoWHSMap.FTokenManager).GetTokenControl(FPlayer).AddEvent(Event);
    Event.Release;
    Result := True;
  end
  else Result := False;
end;
class function TUnit.ClassID: Integer;
begin Result := $20213; end;
function TUnit.GetName: string;
begin Result := FUnitResource.GetUnitName; end;
function TUnit.ShowEx(X,Y: Integer; const SD: TSurfaceDesc; const Info: TP2UnitShowInfo): Integer;
begin
  Result := inherited ShowEx(X,Y,SD,Info);
  if uoRank in Info.Overlays then
    case GetRank of
      urSilver: TCustomImageLibrary(AoWHSSet.FCombatImages)[5].Show(X+33,Y+12,SD);
      urGold: TCustomImageLibrary(AoWHSSet.FCombatImages)[6].Show(X+33,Y+12,SD);
    end;
end;
function TUnit.GetObtainValue: Integer;
begin Result := FUnitResource.FObtainValue; end;
function TUnit.GetMovePoints: Shortint;
begin Result := FMovePoints; end;
function TUnit.GetAlignment: TAlignment;
begin
  if GetAbilityEnabled(107) then begin Result := alPureEvil; Exit; end;
  Result := FUnitResource.FAlignment;
end;
procedure TUnit.SetMovePoints(Value: Shortint);
begin
  if Value > GetMoves then Value := GetMoves;
  if Value < 0 then Value := 0;
  FMovePoints := Value;
end;
function TUnit.GetHitPoints: Shortint;
begin Result := FHitPoints; end;
procedure TUnit.SetHitPoints(Value: Shortint);
begin
  if Value > GetHits then Value := GetHits;
  if Value < 0 then Value := 0;
  FHitPoints := Value;
  UpdateDefensiveStrength;
end;
function TUnit.GetUnitSize: TUnitSize;
begin Result := FUnitResource.FUnitSize; end;
function TUnit.GetBloodType: TBloodType;
begin Result := FUnitResource.FBloodType; end;
function TUnit.GetUnitType: TUnitType;
begin Result := FUnitResource.FUnitType; end;
function TUnit.GetGender: TUnitGender;
begin Result := FUnitResource.FGender; end;
procedure TUnit.Killed;
begin
  inherited Killed;
  Deactivate;
  SetOwner(nil);
end;
procedure TUnit.UnitKilled;
begin end;
{ needs: P1 draft TFaceResourceList.GetFaceResource(Index: Integer):
  TFaceResource, pointer test at 5578288D. }
function P2FaceResource(List: TFaceResourceList; Index: Integer): TFaceResource; assembler;
asm JMP TFaceResourceList.GetFaceResource end;
function TUnit.GetFace: TLibraryImage;
var
  FaceIndex: Integer;
begin
  if not GetAbilityEnabled(126) then
  begin
    Result := TUnitGFXResourceList(AoWHSSet.FUnitGFXResources).GetUnitGFXResource(FUnitResource.FUnitGFXResourceIndex).GetFaceImage;
    Exit;
  end;
  FaceIndex := TP2FaceEnchantmentFields(TUnitEnchantmentAbilityData(P2AbilityData(Self,126)).FEnchantment).FaceIndex;
  if P2FaceResource(TFaceResourceList(AoWHSSet.FFaceResources),FaceIndex) <> nil then
    Result := P2FaceResource(TFaceResourceList(AoWHSSet.FFaceResources),FaceIndex).GetCellImage
  else Result := nil;
end;
function TUnit.GetExperience: Integer;
begin Result := FExperience; end;
procedure TUnit.SetExperience(Value: Integer);
var
  OldRank, NewRank, Rank: TUnitRank;
begin
  OldRank := GetRank;
  if Value > 255 then Value := 255;
  FExperience := Value;
  NewRank := GetRank; if OldRank <> NewRank then
    for Rank := Succ(OldRank) to NewRank do
      UpdateDefaultAbilities(FUnitResource.FAbilities[Rank]);
  Changed;
end;
function TUnit.GetDescription: TStrings;
begin Result := FUnitResource.FDescription; end;
function TUnit.GetNextLevelExperience: Integer;
var Level: Integer; begin
  Level := FUnitResource.FLevel; if FExperience >= Level * 2 then
    if FExperience >= Level * 6 then Result := 0
    else begin Result := Level * 6; Exit; end
  else Result := Level * 2;
end;
function TUnit.GetRank: TUnitRank;
begin
  if FExperience >= FUnitResource.FLevel * 2 then
    if FExperience >= FUnitResource.FLevel * 6 then Result := urGold
    else begin Result := urSilver; Exit; end
  else Result := urNone;
end;
procedure TUnit.SetRank(Value: TUnitRank);
begin
  if Value <> GetRank then
    case Value of
      urNone: FExperience := 0;
      urSilver: SetExperience(FUnitResource.FLevel * 2);
      urGold: SetExperience(FUnitResource.FLevel * 6);
    end;
end;
function TUnit.GetInherentAttack: Shortint;
begin Result := P2RankAttack[GetRank] + FUnitResource.FAttack; end;
function TUnit.GetAttack: Shortint;
begin
  Result := P2RankAttack[GetRank] + (FUnitResource.FAttack + FAbAttack);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;
function TUnit.GetInherentDefense: Shortint;
begin Result := P2RankDefense[GetRank] + FUnitResource.FDefense; end;
function TUnit.GetDefense: Shortint;
begin
  Result := P2RankDefense[GetRank] + (FUnitResource.FDefense + FAbDefense) + P2MoraleDefense[GetMorale];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;
function TUnit.GetInherentDamage: Shortint;
begin Result := P2RankDamage[GetRank] + FUnitResource.FDamage; end;
function TUnit.GetDamage: Shortint;
begin
  Result := P2RankDamage[GetRank] + (FUnitResource.FDamage + FAbDamage);
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;
function TUnit.GetInherentResistance: Shortint;
begin Result := FUnitResource.FResistance; end;
function TUnit.GetResistance: Shortint;
begin
  Result := P2MoraleResistance[GetMorale] + (FUnitResource.FResistance + FAbResistance) + P2RankResistance[GetRank];
  if Smallint(Result) < 1 then Result := 1;
  if Smallint(Result) > 10 then Result := 10;
end;
{ needs: P1 draft ability totals return Shortint, read into AL at
  55782B3E, 55782B48, 55782B52 and 55782B5C. }
function P2AbAttack(Owner: TAbilityOwner): Shortint; assembler;
asm JMP TAbilityOwner.GetAbAttackAll end;
function P2AbDefense(Owner: TAbilityOwner): Shortint; assembler;
asm JMP TAbilityOwner.GetAbDefenseAll end;
function P2AbResistance(Owner: TAbilityOwner): Shortint; assembler;
asm JMP TAbilityOwner.GetAbResistanceAll end;
function P2AbDamage(Owner: TAbilityOwner): Shortint; assembler;
asm JMP TAbilityOwner.GetAbDamageAll end;
procedure TUnit.Changed;
begin
  inherited Changed;
  FAbAttack := P2AbAttack(Self);
  FAbDefense := P2AbDefense(Self);
  FAbResistance := P2AbResistance(Self);
  FAbDamage := P2AbDamage(Self);
end;
function TUnit.GetHits: Shortint;
begin Result := P2RankHits[GetRank] + FUnitResource.FHits; end;
function TUnit.GetMoves: Shortint;
begin Result := FUnitResource.FMoves; end;
function TUnit.GetUnitLevel: Shortint;
begin Result := FUnitResource.FLevel; end;
function TUnit.GetPreviewImage: TLibraryImage;
begin Result := FUnitResource.GetPreviewImage; end;
function TUnit.GetTransportCapacity: Byte;
begin
  Result := GetAbilityLevel(50);
  if Result < FUnitResource.GetTransportCapacity then Result := FUnitResource.GetTransportCapacity;
end;
function TUnit.GetTransporter: Boolean;
begin Result := FUnitResource.GetTransportCapacity <> 0; end;
procedure TUnit.SetUnitResource(Resource: TUnitResource);
var
  Rank: TUnitRank;
begin
  if Resource <> FUnitResource then
  begin
    inherited Clear;
    FUnitResource := Resource;
    if FUnitResource <> nil then
    begin
      UpdateMoraleValue;
      for Rank := urNone to GetRank do
        UpdateDefaultAbilities(FUnitResource.FAbilities[Rank]);
      FHitPoints := GetHits;
      FMovePoints := GetMoves;
    end;
  end;
end;
function TUnit.GetUnitGFXResourceIndex: Integer;
begin Result := FUnitResource.FUnitGFXResourceIndex; end;
procedure TUnit.Activate;
begin
  if FUnitResource <> nil then begin inherited Activate; Exit; end;
  AddRef;
  AddRef;
  AddRef;
  Destroy;
end;
function TUnit.GetRace: Shortint;
begin Result := FUnitResource.FRace; end;
procedure TUnit.NewDay;
var
  Rank: TUnitRank;
begin
  inherited NewDay;
  if AoWHSMap.FDay = 1 then
  begin
    SetAbCount(0);
    for Rank := urNone to GetRank do
      UpdateDefaultAbilities(FUnitResource.FAbilities[Rank]);
  end;
end;
procedure TUnit.ReadWrite(Stream: Engine.TEStorageStream); { Tried untyped resource result; store lookup in field before named local; still differs. }
var
  ResourceIndex: Smallint;
  Resource: TUnitResource;
begin
  inherited ReadWrite(Stream);
  Stream.rwByte(FExperience,7);
  Stream.rwByte(Byte(FMovePoints),8);
  Stream.rwByte(Byte(FHitPoints),9);
  if Stream.StorageMode * [smTextOnly] = [] then
    if smCompare in Stream.StorageMode then
    begin
      ResourceIndex := FUnitResource.UnitResourceIndex;
      Stream.rwWord(Word(ResourceIndex),10);
    end
    else if smRead in Stream.StorageMode then
    begin
      Stream.rwWord(Word(ResourceIndex),10);
      Resource := TUnitResourceList(AoWHSSet.FUnitResources).GetUnitResource(ResourceIndex);
      FUnitResource := Resource;
      if Resource = nil then raise Exception.Create('unit resource missing (' + IntToStr(ResourceIndex) + ')');
    end
    else
    begin
      Resource := FUnitResource;
      if Resource <> nil then ResourceIndex := Resource.UnitResourceIndex
      else ResourceIndex := -1;
      Stream.rwWord(Word(ResourceIndex),10);
    end;
end;
function TUnitList.RemoveChild(Child: Engine.TEObject): Integer;
begin
  Result := inherited RemoveChild(Child);
  if Result <> -1 then Child.Release;
end;
function TUnitList.AddChild(Child: Engine.TEObject): Integer;
begin
  with TAbstractUnit(Child) do
    if Self.CanAddUnit(TAbstractUnit(Child)) then
    begin
      AddRef;
      Result := inherited AddChild(Child);
    end
    else Result := -1;
end;
procedure TUnitList.Clear;
var I: Integer;
begin
  for I := Count - 1 downto 0 do
    TEObject(FChildren.List^[I]).SetOwner(nil);
  FChildren.Clear;
end;
procedure TUnitList.DestroyAllChildren;
begin
  Clear;
end;
function TUnitList.CanAddUnit(AUnit: TAbstractUnit): Boolean;
begin
  Result := AUnit.CanAddToList(Self);
end;
function TUnitList.CanDeleteUnit(AUnit: TAbstractUnit): Boolean;
begin
  Result := True;
end;
function TUnitList.AddUnit(AUnit: TAbstractUnit): Boolean;
begin
  AUnit.SetOwner(Self);
  Result := AUnit.Owner = Self;
end;
function TUnitList.AddUnits(Units: TUnitList): Boolean;
var
  I: Integer;
begin
  for I := Units.Count - 1 downto 0 do AddUnit(Units.GetUnit(I));
  Result := True;
end;
function TUnitList.DeleteUnit(AUnit: TAbstractUnit): Boolean;
begin
  if CanDeleteUnit(AUnit) then
  begin
    Result := True;
    AUnit.SetOwner(nil);
  end
  else Result := False;
end;
function TUnitList.IndexOf(AUnit: TAbstractUnit): Integer;
begin
  Result := FChildren.IndexOf(AUnit);
end;
function TUnitList.IndexOfID(ID: Integer): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAbstractUnit(FChildren.List^[Result]).FUnitID = ID then Exit;
  end;
  Result := -1;
end;
function TUnitList.IndexOfBehavior(Behavior: TGroupBehavior): Integer;
var Group: TAIGroup;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    Group := TAbstractUnit(FChildren.List^[Result]).FGroup;
    if (Group <> nil) and (Group.Behavior = Behavior) then Exit;
  end;
  Result := -1;
end;
function TUnitList.IndexOfGroup(Group: TAIGroup): Integer;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    if TAbstractUnit(FChildren.List^[Result]).FGroup = Group then Exit;
  end;
  Result := -1;
end;
function TUnitList.IndexOfGroupID(ID: Integer): Integer;
var Group: TAIGroup;
begin
  Result := Count;
  while Result <> 0 do
  begin
    Dec(Result);
    Group := TAbstractUnit(FChildren.List^[Result]).FGroup;
    if (Group <> nil) and (Group.FGroupID = ID) then Exit;
  end;
  Result := -1;
end;
function TUnitList.FindID(ID: Integer): TAbstractUnit;
var I: Integer;
begin
  I := Count;
  while I <> 0 do
  begin
    Dec(I);
    Result := TAbstractUnit(FChildren.List^[I]);
    if Result.FUnitID = ID then Exit;
  end;
  Result := nil;
end;
function TUnitList.GetUnit(A1: Integer): TAbstractUnit;
begin
  { Original accepts negative indexes and reads the backing array directly. }
  if A1 < Count then
  begin
    Result := TAbstractUnit(FChildren.List^[A1]);
    Exit;
  end;
  Result := nil;
end;
procedure TUnitList.SetUnit(Index: Integer; AUnit: TAbstractUnit);
begin
  while Index >= Count do FChildren.Add(nil);
  if FChildren.List^[Index] <> nil then TEObject(FChildren.List^[Index]).Release;
  FChildren.List^[Index] := AUnit;
  if UpdateCount = 0 then Changed;
end;
procedure TUnitList.MainReadWrite(Stream: Engine.TEStorageStream);
var I: Integer;
begin
  inherited MainReadWrite(Stream);
  if Stream.StorageMode * [smRead, smTextOnly, smCompare] = [smRead] then
    for I := 0 to FChildren.Count - 1 do TEObject(FChildren.List^[I]).Release;
end;
function P2CompareUnits(Item1, Item2: Pointer): Integer;
var S1, S2: Integer;
begin
  with TAbstractUnit(Item1) do
  begin
    S1 := GetUnitLevel;
    if GetTransporter then Inc(S1, 500);
    if TAbstractUnit(Item1) is THero then
    begin
      Inc(S1, 50);
      if TAbstractUnit(Item1) is TLeader then Inc(S1, 100);
    end;
  end;
  with TAbstractUnit(Item2) do
  begin
    S2 := GetUnitLevel;
    if GetTransporter then Inc(S2, 500);
    if TAbstractUnit(Item2) is THero then
    begin
      Inc(S2, 50);
      if TAbstractUnit(Item2) is TLeader then Inc(S2, 100);
    end;
  end;
  Result := S2 - S1;
  if Result = 0 then
  begin
    if usEnchanted in TAbstractUnit(Item1).FUnitStatus then S1 := 1 else S1 := 0;
    if usEnchanted in TAbstractUnit(Item2).FUnitStatus then S2 := 1 else S2 := 0;
    Result := S2 - S1;
  end;
  if Result = 0 then
  begin
    Result := TAbstractUnit(Item2).GetUnitGFXResourceIndex -
      TAbstractUnit(Item1).GetUnitGFXResourceIndex;
    if Result = 0 then Result := TAbstractUnit(Item2).FUnitID - TAbstractUnit(Item1).FUnitID;
  end;
end;
procedure TUnitList.SortUnits;
begin
  BeginUpdate;
  FChildren.Pack;
  FChildren.Sort(P2CompareUnits);
  EndUpdate;
end;
function P2CompareUnitMoves(Item1, Item2: Pointer): Integer;
begin
  Result := TAbstractUnit(Item2).GetMoves - TAbstractUnit(Item1).GetMoves;
end;
procedure TUnitList.SortOnMoves;
begin
  BeginUpdate;
  FChildren.Pack;
  FChildren.Sort(P2CompareUnitMoves);
  EndUpdate;
end;
procedure TUnitList.GetLocation(var Xhx, Yhx, Lhx: Shortint);
begin
  Xhx := -1;
  Yhx := -1;
  Lhx := -1;
end;
function TUnitList.GetPlayer: Shortint;
begin
  Result := -1;
end;
function TUnitList.GetStrength(DamageType: TDamageType): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrength(DamageType));
end;
function TUnitList.GetStrengthMax(DamageTypes: TDamageTypes): Integer;
var I: Integer;
begin
  Result := 0;
  for I := FChildren.Count - 1 downto 0 do
    Inc(Result, TAbstractUnit(FChildren.List^[I]).GetStrengthMax(DamageTypes));
end;
procedure TUnitUserList.Clear;
var I: Integer;
begin
  for I := Count - 1 downto 0 do TEObject(FChildren.List^[I]).Release;
  FChildren.Clear;
end;
function TUnitUserList.AddUnit(AUnit: TAbstractUnit): Boolean;
begin
  if CanAddUnit(AUnit) then
  begin
    AddChild(AUnit);
    Result := True;
    Exit;
  end;
  Result := False;
end;
function TUnitUserList.DeleteUnit(AUnit: TAbstractUnit): Boolean;
begin
  if CanDeleteUnit(AUnit) then
  begin
    RemoveChild(AUnit);
    Result := True;
    Exit;
  end;
  Result := False;
end;
procedure TUnitUserList.AddUnitsEx(Units: TUnitList; Selection: Byte);
var
  I: Integer;
begin
  for I := 0 to Units.Count - 1 do
    if ((1 shl I) and Selection) <> 0 then AddUnit(Units.GetUnit(I));
end;
constructor TUnitIndexListCollection.Create;
begin
  inherited Create;
  FUnits := TUnitIndexList.Create;
  FCollectionSize := 8;
end;
destructor TUnitIndexListCollection.Destroy;
begin
  inherited Destroy;
  FUnits.Free;
end;
procedure TUnitIndexListCollection.LoadFromStream(Stream: TStream);
begin
  FUnits.LoadFromStream(Stream);
end;
procedure TUnitIndexListCollection.SaveToStream(Stream: TStream);
begin
  FUnits.SaveToStream(Stream);
end;
function TUnitIndexListCollection.GetCollectionCount(Index: Integer): Integer;
var
  I, Last: Integer;
begin
  Result := 0;
  I := Index * FCollectionSize;
  Last := FCollectionSize + I;
  if Last > FUnits.Count then Last := FUnits.Count;
  while (I < Last) and (FUnits[I] <> -1) do
  begin
    Inc(I);
    Inc(Result);
  end;
end;
function TUnitIndexListCollection.GetCount: Integer;
begin
  Result := (FUnits.Count + (FCollectionSize - 1)) div FCollectionSize;
end;
function TUnitIndexListCollection.GetU(Collection, Index: Integer): Integer;
begin
  Result := FUnits[Index + Collection * FCollectionSize];
end;
function TUnitIndexListCollection.AddUnit(Collection, UnitIndex: Integer): Boolean;
var
  N: Integer;
begin
  N := GetCollectionCount(Collection);
  if N < FCollectionSize then
  begin
    FUnits[N + Collection * FCollectionSize] := UnitIndex;
    Result := True;
  end
  else Result := False;
end;
procedure TUnitIndexListCollection.DeleteUnit(Collection, Index: Integer);
var
  N, Offset, UnitIndex: Integer;
begin
  N := GetCollectionCount(Collection);
  if Index < N then
  begin
    Offset := Collection * FCollectionSize; UnitIndex := Offset + Index; FUnits.Delete(UnitIndex);
    FUnits.Insert(Offset + N - 1, -1);
  end;
end;
function TUnitIndexListCollection.GetRndCollection: Integer;
var
  Index, Tries: Integer;
begin
  Tries := 10;
  repeat
    Index := Random(GetCount);
    Dec(Tries);
  until (GetCollectionCount(Index) <> 0) or (Tries = 0);
  if GetCollectionCount(Index) = 0 then
  begin
    Index := 0;
    while (Index < GetCount) and (GetCollectionCount(Index) = 0) do Inc(Index);
    if GetCollectionCount(Index) = 0 then Index := -1;
  end;
  Result := Index;
end;
procedure TWallUnit.SetWallType(Value: TWallType);
var
  WallType: TWallType;
begin
  WallType := Value;
  FWallType := Value;
  if FWallType = wtStone then FHits := 10 else FHits := 5;
  FHitPoints := FHits;
end;
function TWallUnit.GetImmunityTypes: TDamageTypes;
const
  AllDamageTypes: TDamageTypes = [Low(TDamageType)..High(TDamageType)];
  WallDamageTypes: TDamageTypes = [dtWall];
begin
  Result := AllDamageTypes - WallDamageTypes;
end;
function TWallUnit.GetDefense: Shortint;
begin
  Result := 0;
end;
function TWallUnit.GetHitPoints: Shortint;
begin
  Result := FHitPoints;
end;
function TWallUnit.GetHits: Shortint;
begin
  Result := FHits;
end;
function TWallUnit.GetName: string;
begin
  case FWallType of
    wtWood: Result := TranslateRStr(P2WoodenWallRStr);
    wtStone: Result := TranslateRStr(P2StoneWallRStr);
    wtNone: Result := TranslateRStr(P2UndefinedWallRStr);
  end;
end;
function TWallUnit.GetUnitType: TUnitType;
begin
  Result := utMachine;
end;
constructor TAdjustableUnit.Create(AOwner: Engine.TECustomNode);
begin
  inherited Create(AOwner);
  MakeDefaultLevelUnit(1);
end;
procedure TAdjustableUnit.MakeDefaultLevelUnit(Level: Shortint);
begin
  { Original retains protection from an earlier, higher-level setup. }
  case Level of
    1:
      begin
        FAttack := 4;
        FDefense := 2;
        FResistance := 3;
        FDamage := 3;
        FHits := 5;
        SetAbSet(21, 1);
        SetAbSet(0, 1);
        FImmunityTypes := [dtWall];
      end;
    2:
      begin
        FAttack := 5;
        FDefense := 3;
        FResistance := 3;
        FDamage := 3;
        FHits := 8;
        SetAbSet(21, 1);
        SetAbSet(0, 1);
        FImmunityTypes := [dtWall];
      end;
    3:
      begin
        FAttack := 6;
        FDefense := 3;
        FResistance := 4;
        FDamage := 7;
        FHits := 15;
        SetAbSet(21, 1);
        SetAbSet(0, 1);
        FImmunityTypes := [dtWall];
        FProtectionTypes := [dtPhysical];
      end;
    else
      begin
        FAttack := 6;
        FDefense := 3;
        FResistance := 4;
        FDamage := 7;
        FHits := 20;
        FImmunityTypes := [dtPhysical, dtWall];
        SetAbSet(21, 1);
        SetAbSet(0, 1);
      end;
  end;
  FHitPoints := FHits;
end;
function TAdjustableUnit.GetAttack: Shortint;
begin Result := FAttack; end;
function TAdjustableUnit.GetDefense: Shortint;
begin Result := FDefense; end;
function TAdjustableUnit.GetDamage: Shortint;
begin Result := FDamage; end;
function TAdjustableUnit.GetHits: Shortint;
begin Result := FHits; end;
function TAdjustableUnit.GetHitPoints: Shortint;
begin Result := FHitPoints; end;
procedure TAdjustableUnit.SetHitPoints(Value: Shortint);
begin FHitPoints := Value; end;
function TAdjustableUnit.GetResistance: Shortint;
begin Result := FResistance; end;
function TAdjustableUnit.GetImmunityTypes: TDamageTypes;
begin Result := FImmunityTypes; end;
function TAdjustableUnit.GetProtectionTypes: TDamageTypes;
begin Result := FProtectionTypes; end;
