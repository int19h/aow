{ P2 recovery in original code order. }
var
  { needs: P1 shared var AoWHSMap: TAoWHSMap; original global at $558FA040,
    read by TUnitControl.RegisterUnit at $5577EA49. Replace this local stand-in
    with the shared declaration when P1 assembles the interface. }
  P2AoWHSMap: TAoWHSMap;
  { needs: P1 shared AoWHSSet: TAoWHSSet, original global 558FA044. }
  P2AoWHSSet: TAoWHSSet;

const
  { needs: P1 shared dAlignmentToStatusValue, original 558E8480. }
  P2AlignmentToStatusValue: array[TAlignment, TAlignment] of Shortint =
    ((100,90,30,40,10,0,50), (90,90,40,50,10,10,50),
     (30,40,70,50,40,30,50), (40,50,50,50,50,40,50),
     (10,10,40,50,90,90,50), (0,10,30,40,90,100,50),
     (50,50,50,50,50,50,50));

{ needs: TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit); forward both registers
  to the existing draft method until P1 corrects its declaration. }
procedure P2NotifyUnitDestroyed(Map: TAoWHSMap; AUnit: TAbstractUnit); assembler;
asm
  JMP TAoWHSMap.UnitDestroyed
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

{ needs: P1 StatusValueToStatus(Value: Integer): TStatus; 5577EECE returns AL. }
function P2StatusValueToStatus(Value: Integer): TStatus; assembler;
asm
  JMP StatusValueToStatus
end;

type
  TP2RaceTerrain = record
    Preferred, Disliked: TAoWTerrainTypes;
  end;
const
  { needs: P1 shared RaceTerrain at 558E8394, 12 pairs of two-byte terrain sets. }
  P2RaceTerrain: array[0..11] of TP2RaceTerrain = (
    (Preferred: []; Disliked: []),
    (Preferred: [ttDesert]; Disliked: [ttSnow, ttIce, ttUndergroundIce]),
    (Preferred: [ttWater]; Disliked: [ttDesert, ttWasteland]),
    (Preferred: [ttSnow, ttIce, ttUndergroundIce]; Disliked: [ttDesert]),
    (Preferred: [ttGrass]; Disliked: [ttWasteland]),
    (Preferred: [ttGrass]; Disliked: [ttWasteland]),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: []; Disliked: []),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: []; Disliked: []),
    (Preferred: [ttDirt]; Disliked: []),
    (Preferred: [ttWasteland]; Disliked: [ttGrass]));

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
        else if msEditting in P2AoWHSMap.Status then
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
  FArmy := nil;
  FUnitID := -1;
end;

destructor TAbstractUnit.Destroy;
begin
  if usActivated in FUnitStatus then Deactivate;
  if P2AoWHSMap <> nil then
  begin
    { needs: P1 TAoWHSMap.UnitDestroyed(AUnit: TAbstractUnit),
      EDX is Self at 5577EB8B; keep the argument live across the draft call. }
    P2NotifyUnitDestroyed(P2AoWHSMap, Self);
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

procedure TAbstractUnit.GetAbilitySelectionTypes(A1: Word; A2: Integer);
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
    { needs: TUnitList.GetLocation and P5 TAIGroup.GetLocation take three
      var Shortint coordinates (5577EDB2..5577EDC5). Keep the inherited draft
      signature compatible until P5 can update its override. }
    TUnitList(Owner).GetLocation(Integer(@Xhx), Integer(@Yhx), Integer(@Lhx))
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

function TAbstractUnit.GetRelationValue(Player, IndependentRelation: Shortint): Integer;
var
  Race: Shortint;
begin
  Race := GetRace;
  if Player <> 0 then
  begin
    if (Race <> -1) and not GetAbilityEnabled(107) then
      Result := P2GetPlayerRelationValue(
        P2GetRace(TRaceList(P2AoWHSMap.FRaces), Race), Player)
    else
    begin
      Result := P2AlignmentToStatusValue[GetAlignment, P2GetRaceAlignment(P2GetRaceResource(
        TRaceResourceList(P2AoWHSSet.FRaceResources),
        Shortint(P2GetPlayers(TPlayerList(P2AoWHSMap.FPlayers), Player).FPlayerRace)))];
    end;
  end
  else
    Result := P2AlignmentToStatusValue[GetAlignment, P2IRtoAlignment(IndependentRelation)];
end;

function TAbstractUnit.GetRelation(Player, IndependentRelation: Shortint): TStatus;
begin
  Result := P2StatusValueToStatus(GetRelationValue(Player, IndependentRelation));
end;

function TAbstractUnit.GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer;
{ Register allocation remains different: direct indexing, explicit race index,
  a with-block, a map-field local, and a separate morale local were compared. }
var
  Race: Shortint;
  Xhx, Yhx, Lhx: Shortint;
  TerrainType: TAoWTerrainType;
  Morale: Integer;
begin
  if (Player >= 0) and (GetUnitType <> utMachine) and
     not (msEditting in P2AoWHSMap.Status) then
  begin
    Race := GetRace;
    Morale := GetRelationValue(Player, IndependentRelation);
    if Race <> -1 then
    begin
      GetLocation(Xhx, Yhx, Lhx);
      if Xhx <> -1 then
      begin
        TerrainType := TAoWTerrainType(P2AoWHSMap.MapContainer.GetField(Xhx, Yhx, Lhx).TerrainType);
        if TerrainType in P2RaceTerrain[Race].Disliked then Dec(Morale, 10);
        if TerrainType in P2RaceTerrain[Race].Preferred then Inc(Morale, 10);
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

procedure TAbstractUnit.UnitRelation(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.UpdateMoraleValue;
begin end;

procedure TAbstractUnit.GetMorale;
begin end;

procedure TAbstractUnit.GetUnitSize;
begin end;

function TAbstractUnit.GetObtainValue: Integer;
begin end;

procedure TAbstractUnit.UpdateEnchanted;
begin end;

procedure TAbstractUnit.RemoveEnchantments;
begin end;

procedure TAbstractUnit.RemoveHandicaps;
begin end;

procedure TAbstractUnit.RegisterEnchantments;
begin end;

procedure TAbstractUnit.UnregisterEnchantments;
begin end;

procedure TAbstractUnit.AbilityToEnchantment;
begin end;

procedure TAbstractUnit.CanDispelEnchantment(A1: Integer);
begin end;

procedure TAbstractUnit.ListEnchantments(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.SetPlayer(A1: Integer);
begin end;

procedure TAbstractUnit.GetIndependentRelation;
begin end;

procedure TAbstractUnit.SetOwner(AOwner: Engine.TECustomNode);
begin end;

procedure TAbstractUnit.GetAbilityCount;
begin end;

procedure TAbstractUnit.GetInherentAbility(A1: Integer);
begin end;

procedure TAbstractUnit.GetInherentAbilityLevel(A1: Integer);
begin end;

function TAbstractUnit.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin end;

procedure TAbstractUnit.GetAbilitySet(A1: Integer);
begin end;

procedure TAbstractUnit.GetAbilityName(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.GetAbilityLevel(A1: Integer);
begin end;

procedure TAbstractUnit.GetAbilityOwner(A1: Integer);
begin end;

procedure TAbstractUnit.GetOwnerName(A1: Integer);
begin end;

procedure TAbstractUnit.RemoveAbility(A1: Integer);
begin end;

procedure TAbstractUnit.UpdateDefensiveStrength;
begin end;

procedure TAbstractUnit.UpdateOffensiveStrength;
begin end;

procedure TAbstractUnit.GetStrength(A1: Integer);
begin end;

procedure TAbstractUnit.GetStrengthMax(A1: Word; A2: Integer);
begin end;

procedure TAbstractUnit.GetCombatValue(A1: Integer; A2: Byte);
begin end;

procedure TAbstractUnit.ListAbilityInfo(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.GetDescription;
begin end;

procedure TAbstractUnit.CanActivate;
begin end;

procedure TAbstractUnit.GetExperience;
begin end;

procedure TAbstractUnit.SetExperience(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.GetNextLevelExperience;
begin end;

procedure TAbstractUnit.Activate(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.Deactivate;
begin end;

function TAbstractUnit.GetAlignment: TAlignment;
begin end;

procedure TAbstractUnit.GetUpkeep;
begin end;

procedure TAbstractUnit.GetManaUpkeep;
begin end;

procedure TAbstractUnit.GetUnitLevel;
begin end;

procedure TAbstractUnit.GetTransportCapacity;
begin end;

procedure TAbstractUnit.GetMovePoints;
begin end;

procedure TAbstractUnit.SetMovePoints(A1: Integer);
begin end;

function TAbstractUnit.GetHitPoints: Shortint;
begin end;

procedure TAbstractUnit.SetHitPoints(A1: Integer);
begin end;

procedure TAbstractUnit.GetTransporting(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.UnitKilled;
begin end;

procedure TAbstractUnit.GetTransporter;
begin end;

function TAbstractUnit.GetImmunityTypes: TDamageTypes;
begin end;

function TAbstractUnit.GetProtectionTypes: TDamageTypes;
begin end;

function TAbstractUnit.GetUnitType: TUnitType;
begin end;

procedure TAbstractUnit.GetInherentAttack;
begin end;

procedure TAbstractUnit.GetAttack(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.GetInherentDefense;
begin end;

function TAbstractUnit.GetDefense: Shortint;
begin end;

procedure TAbstractUnit.GetInherentDamage;
begin end;

procedure TAbstractUnit.GetDamage(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.GetInherentResistance;
begin end;

function TAbstractUnit.GetResistance: Shortint;
begin end;

procedure TAbstractUnit.GetHits;
begin end;

procedure TAbstractUnit.GetMoves;
begin end;

procedure TAbstractUnit.GetPowerGeneration;
begin end;

procedure TAbstractUnit.GetCastingPointsMax;
begin end;

procedure TAbstractUnit.GetCastingPoints;
begin end;

procedure TAbstractUnit.SetCastingPoints(A1: Integer);
begin end;

procedure TAbstractUnit.CreateMovePointTable(A1: Integer);
begin end;

procedure TAbstractUnit.GetMoveTypes;
begin end;

procedure TAbstractUnit.GetFace;
begin end;

procedure TAbstractUnit.GetName(A1: Integer);
begin end;

procedure TAbstractUnit.GetPreviewImage;
begin end;

procedure TAbstractUnit.GetUnitGFXResourceIndex;
begin end;

procedure TAbstractUnit.ValidTerrain(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.ExecuteTrailOfDarkness(A1: Integer);
begin end;

procedure TAbstractUnit.PathOfLifeTerrainChange(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.PathOfDecayTerrainChange(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.PathOfFrostTerrainChange(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.PathOfFrostTerrainChanged(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.UpdatePathOfFrost(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.MovedTo(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.ConcealedOnMapF(A1: Integer);
begin end;

procedure TAbstractUnit.ExecuteStormDamage(A1: Byte);
begin end;

procedure TAbstractUnit.MovePointCost(A1: Integer; A2: Byte);
begin end;

procedure TAbstractUnit.GetGender;
begin end;

procedure TAbstractUnit.Killed;
begin end;

procedure TAbstractUnit.Resurrect;
begin end;

procedure TAbstractUnit.Animate;
begin end;

procedure TAbstractUnit.ResetEarthMasteryStoneSkin;
begin end;

procedure TAbstractUnit.SetEarthMasteryStoneSkin;
begin end;

procedure TAbstractUnit.ResetFireMasteryProtection;
begin end;

procedure TAbstractUnit.SetFireMasteryProtection;
begin end;

procedure TAbstractUnit.ResetLifeMasteryBlessing;
begin end;

procedure TAbstractUnit.SetLifeMasteryBlessing;
begin end;

procedure TAbstractUnit.ResetLifeMasteryFear;
begin end;

procedure TAbstractUnit.ExecuteLifeMasteryFearRole;
begin end;

procedure TAbstractUnit.ValidateLifeMastery;
begin end;

procedure TAbstractUnit.ExecuteDeathMasteryCurseRole;
begin end;

procedure TAbstractUnit.ValidateDeathMastery;
begin end;

procedure TAbstractUnit.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.NewTurnDone(A1: Byte);
begin end;

procedure TAbstractUnit.VisibilityRange(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.TrueVisionRange;
begin end;

procedure TAbstractUnit.Changed;
begin end;

procedure TAbstractUnit.CanPlace(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractUnit.Place(A1: Integer; A2: Integer; A3: Integer; A4: Integer; A5: Integer);
begin end;

procedure TAbstractUnit.CanAddToList;
begin end;

procedure TAbstractUnit.NewDay(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.ValidateCrusader;
begin end;

procedure TAbstractUnit.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TAbstractUnit.Show(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAbstractUnit.ShowFace(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.ExecuteDamageRole(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnit.ExecuteResistanceRole(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.ExecuteDamageEffectsRole(A1: Word);
begin end;

procedure TAbstractUnit.ExecuteDamageEffects(A1: Word; A2: Integer);
begin end;

procedure TAbstractUnit.ExecuteCombatDamageEffects(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.OptimalDamageType(A1: Word; A2: Integer);
begin end;

procedure TAbstractUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAbstractUnit.CanJoin(A1: Byte; A2: Integer);
begin end;

procedure TAbstractUnit.JoinAmount(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.OfferToJoin(A1: Integer);
begin end;

procedure TAbstractUnit.GetJoinMessage(A1: Integer; A2: Integer);
begin end;

procedure TAbstractUnit.CanDisband;
begin end;

procedure TAbstractUnit.Disband;
begin end;

class function TUnit.ClassID: Integer;
begin Result := 0; end;

procedure TUnit.GetName(A1: Integer);
begin end;

procedure TUnit.ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

function TUnit.GetObtainValue: Integer;
begin end;

procedure TUnit.GetMovePoints;
begin end;

function TUnit.GetAlignment: TAlignment;
begin end;

procedure TUnit.SetMovePoints(A1: Integer);
begin end;

function TUnit.GetHitPoints: Shortint;
begin end;

procedure TUnit.SetHitPoints(A1: Integer);
begin end;

procedure TUnit.GetUnitSize;
begin end;

function TUnit.GetBloodType: TBloodType;
begin end;

function TUnit.GetUnitType: TUnitType;
begin end;

procedure TUnit.GetGender;
begin end;

procedure TUnit.Killed;
begin end;

procedure TUnit.UnitKilled;
begin end;

procedure TUnit.GetFace;
begin end;

procedure TUnit.GetExperience;
begin end;

procedure TUnit.SetExperience(A1: Integer; A2: Integer);
begin end;

procedure TUnit.GetDescription;
begin end;

procedure TUnit.GetNextLevelExperience;
begin end;

procedure TUnit.GetRank;
begin end;

procedure TUnit.SetRank(A1: Integer);
begin end;

procedure TUnit.GetInherentAttack;
begin end;

procedure TUnit.GetAttack(A1: Integer; A2: Integer);
begin end;

procedure TUnit.GetInherentDefense;
begin end;

function TUnit.GetDefense: Shortint;
begin end;

procedure TUnit.GetInherentDamage;
begin end;

procedure TUnit.GetDamage(A1: Integer; A2: Integer);
begin end;

procedure TUnit.GetInherentResistance;
begin end;

function TUnit.GetResistance: Shortint;
begin end;

procedure TUnit.Changed;
begin end;

procedure TUnit.GetHits;
begin end;

procedure TUnit.GetMoves;
begin end;

procedure TUnit.GetUnitLevel;
begin end;

procedure TUnit.GetPreviewImage;
begin end;

procedure TUnit.GetTransportCapacity;
begin end;

procedure TUnit.GetTransporter;
begin end;

procedure TUnit.SetUnitResource(A1: Integer; A2: Integer);
begin end;

procedure TUnit.GetUnitGFXResourceIndex;
begin end;

procedure TUnit.Activate(A1: Integer; A2: Integer);
begin end;

function TUnit.GetRace: Shortint;
begin end;

procedure TUnit.NewDay(A1: Integer; A2: Integer);
begin end;

procedure TUnit.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TUnitList.RemoveChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

function TUnitList.AddChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure TUnitList.Clear;
begin end;

procedure TUnitList.DestroyAllChildren;
begin end;

procedure TUnitList.CanAddUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitList.CanDeleteUnit(A1: Integer);
begin end;

procedure TUnitList.AddUnit(A1: Integer);
begin end;

procedure TUnitList.AddUnits(A1: Integer);
begin end;

procedure TUnitList.DeleteUnit(A1: Integer);
begin end;

procedure TUnitList.IndexOf;
begin end;

procedure TUnitList.IndexOfID(A1: Integer);
begin end;

procedure TUnitList.IndexOfBehavior(A1: Integer);
begin end;

procedure TUnitList.IndexOfGroup(A1: Integer);
begin end;

procedure TUnitList.IndexOfGroupID(A1: Integer);
begin end;

procedure TUnitList.FindID(A1: Integer);
begin end;

procedure TUnitList.GetUnit(A1: Integer);
begin end;

procedure TUnitList.SetUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitList.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitList.SortUnits;
begin end;

procedure TUnitList.SortOnMoves;
begin end;

procedure TUnitList.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitList.GetPlayer;
begin end;

procedure TUnitList.GetStrength(A1: Integer);
begin end;

procedure TUnitList.GetStrengthMax(A1: Word; A2: Integer);
begin end;

procedure TUnitUserList.Clear;
begin end;

procedure TUnitUserList.AddUnit(A1: Integer);
begin end;

procedure TUnitUserList.DeleteUnit(A1: Integer);
begin end;

procedure TUnitUserList.AddUnitsEx(A1: Integer; A2: Integer);
begin end;

constructor TUnitIndexListCollection.Create;
begin end;

destructor TUnitIndexListCollection.Destroy;
begin end;

procedure TUnitIndexListCollection.LoadFromStream;
begin end;

procedure TUnitIndexListCollection.SaveToStream;
begin end;

procedure TUnitIndexListCollection.GetCollectionCount(A1: Integer);
begin end;

procedure TUnitIndexListCollection.GetCount;
begin end;

procedure TUnitIndexListCollection.GetU(A1: Integer; A2: Integer);
begin end;

procedure TUnitIndexListCollection.AddUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitIndexListCollection.DeleteUnit(A1: Integer; A2: Integer);
begin end;

procedure TUnitIndexListCollection.GetRndCollection;
begin end;

procedure TWallUnit.SetWallType(A1: Integer);
begin end;

function TWallUnit.GetImmunityTypes: TDamageTypes;
begin end;

function TWallUnit.GetDefense: Shortint;
begin end;

function TWallUnit.GetHitPoints: Shortint;
begin end;

procedure TWallUnit.GetHits;
begin end;

procedure TWallUnit.GetName(A1: Integer);
begin end;

function TWallUnit.GetUnitType: TUnitType;
begin end;

constructor TAdjustableUnit.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TAdjustableUnit.MakeDefaultLevelUnit(A1: Byte);
begin end;

procedure TAdjustableUnit.GetAttack(A1: Integer; A2: Integer);
begin end;

function TAdjustableUnit.GetDefense: Shortint;
begin end;

procedure TAdjustableUnit.GetDamage(A1: Integer; A2: Integer);
begin end;

procedure TAdjustableUnit.GetHits;
begin end;

function TAdjustableUnit.GetHitPoints: Shortint;
begin end;

procedure TAdjustableUnit.SetHitPoints(A1: Integer);
begin end;

function TAdjustableUnit.GetResistance: Shortint;
begin end;

function TAdjustableUnit.GetImmunityTypes: TDamageTypes;
begin end;

function TAdjustableUnit.GetProtectionTypes: TDamageTypes;
begin end;

constructor TUnitGFXResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitGFXResource.Destroy;
begin end;

class function TUnitGFXResource.ClassID: Integer;
begin Result := 0; end;

function TUnitGFXResource.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TUnitGFXResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TUnitGFXResource.LinkToIL;
begin end;

procedure TUnitGFXResource.ReleaseIL;
begin end;

procedure TUnitGFXResource.SetFaceImageLibraryName(A1: Integer; A2: Integer);
begin end;

function TUnitGFXResource.AddRef: Integer;
begin Result := 0; end;

function TUnitGFXResource.Release: Integer;
begin Result := 0; end;

procedure TUnitGFXResource.GetFaceImage;
begin end;

function TUnitGFXResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TUnitGFXResource.Show(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TUnitGFXResource.GetIndex;
begin end;

procedure TUnitGFXResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TUnitGFXResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnitGFXResourceList.GetUnitGFXResource(A1: Integer);
begin end;

procedure TUnitGFXResourceList.CreateUnitGFXSelectionList(A1: Integer; A2: Integer);
begin end;

function TUnitShadowHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TUnitShadowHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

constructor TUnitHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitHS.Destroy;
begin end;

class function TUnitHS.ClassID: Integer;
begin Result := 0; end;

procedure TUnitHS.CreateShadow;
begin end;

procedure TUnitHS.DestroyShadow;
begin end;

procedure TUnitHS.MakeVisible(VisibilityList: HSEngine.TVisibilityList);
begin end;

procedure TUnitHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

procedure TUnitHS.SetOwner(AOwner: Engine.TECustomNode);
begin end;

function TUnitHS.GetXhx: Shortint;
begin Result := 0; end;

function TUnitHS.GetYhx: Shortint;
begin Result := 0; end;

function TUnitHS.GetLhx: Shortint;
begin Result := 0; end;

procedure TUnitHS.Select;
begin end;

procedure TUnitHS.Unselect;
begin end;

function TUnitHS.GetSelected: Boolean;
begin Result := False; end;

procedure TUnitHS.SetVisible(Value: Boolean);
begin end;

function TUnitHS.GetVisible: Boolean;
begin Result := False; end;

function TUnitHS.GetEditMode: Boolean;
begin Result := False; end;

procedure TUnitHS.SetEditMode(Value: Boolean);
begin end;

procedure TUnitHS.GetUnitGFXResourceIndex;
begin end;

procedure TUnitHS.SetUnitGFXResourceIndex(A1: Integer);
begin end;

procedure TUnitHS.TimerEvent(Tick: Integer; Sender: Engine.TEObject);
begin end;

function TUnitHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TUnitHS.CalcShowPriority;
begin end;

function TUnitHS.GetShowPriority: Integer;
begin Result := 0; end;

function TUnitHS.GetLevel: Byte;
begin Result := 0; end;

procedure TUnitHS.UpdateFlagID;
begin end;

procedure TUnitHS.Activate;
begin end;

procedure TUnitHS.Deactivate;
begin end;

function TUnitHS.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TUnitHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TUnitHS.Connect;
begin end;

procedure TUnitHS.Disconnect;
begin end;

function TUnitHS.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TUnitHS.RemoveFromMap;
begin end;

procedure TUnitHS.MoveTo(A1: Integer; A2: Integer);
begin end;

procedure TUnitHS.Remove;
begin end;

procedure TUnitHS.PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

function TUnitHS.Place(Map: HSEngine.TMapContainer; Xhp, Yhp, Lhx: Integer): Boolean;
begin Result := False; end;

procedure TUnitHS.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TUnitHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TUnitHS.SetDirection(A1: Integer);
begin end;

procedure TUnitHS.MoveFirst(A1: Integer; A2: Integer);
begin end;

procedure TUnitHS.GetMoveStatus;
begin end;

procedure TUnitHS.SetMoveStatus(A1: Integer);
begin end;

procedure TUnitHS.MoveNext;
begin end;

procedure TUnitHS.Moving;
begin end;

procedure TUnitHS.PauseMove;
begin end;

procedure TUnitHS.CancelMove;
begin end;

function TUnitHS.GetMoveSteps: Integer;
begin Result := 0; end;

procedure TUnitHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

function TAbstractUnitResource.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAbstractUnitResource.GetObtainValue;
begin end;

procedure TAbstractUnitResource.GetFace;
begin end;

procedure TAbstractUnitResource.GetPreviewImage;
begin end;

function TAbstractUnitResource.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TAbstractUnitResource.SetUnitGFXResourceIndex(A1: Integer);
begin end;

procedure TAbstractUnitResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TAbstractUnitResource.DropUnit(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAbstractUnitResource.EditDropMsg(A1: Integer);
begin end;

class function TAbstractUnitResource.ResourceEditName: string;
begin Result := ''; end;

procedure TAbstractUnitResource.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TUnitResourceAbilityOwner.GetAbilitySelectionTypes(A1: Word; A2: Integer);
begin end;

constructor TUnitResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TUnitResource.Destroy;
begin end;

procedure TUnitResource.GetMoveTypes;
begin end;

procedure TUnitResource.GetTransportCapacity;
begin end;

procedure TUnitResource.GetUpkeep;
begin end;

procedure TUnitResource.GetObtainValue;
begin end;

procedure TUnitResource.SetDescription;
begin end;

function TUnitResource.ResourceUserClassID: Integer;
begin Result := 0; end;

function TUnitResource.CreateResourceUser: Engine.TEObject;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TUnitResource.UnitResourceIndex;
begin end;

class function TUnitResource.ClassID: Integer;
begin Result := 0; end;

procedure TUnitResource.GetUnitName(A1: Integer);
begin end;

procedure TUnitResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TUnitResource.DropUnit(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TUnitResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TUnitResourceList.GetUnitResource(A1: Integer);
begin end;

procedure TUnitIndexList.Create(A1: Byte);
begin end;

procedure TUnitIndexList.GetUnitIndex(A1: Integer);
begin end;

procedure TUnitIndexList.VerifyUnits(A1: Byte);
begin end;

procedure TUnitIndexList.SetUnitIndex(A1: Integer; A2: Integer);
begin end;

procedure TUnitIndexList.SortUnits;
begin end;

constructor THeroUpgradeTE.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroUpgradeTE.Destroy;
begin end;

procedure THeroUpgradeTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function THeroUpgradeTE.ClassID: Integer;
begin Result := 0; end;

function THeroUpgradeTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THeroUpgradeTE.Setup(A1: Integer);
begin end;

class function THeroUpgradeEventLog.ClassID: Integer;
begin Result := 0; end;

procedure THeroUpgradeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THeroUpgradeEventLog.GetText(A1: Integer);
begin end;

procedure THeroUpgradeEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THeroUpgradeEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

class function THeroJoinEventLog.ClassID: Integer;
begin Result := 0; end;

procedure THeroJoinEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THeroJoinEventLog.ExecuteAI;
begin end;

procedure THeroJoinEventLog.Accept(A1: Integer; A2: Integer);
begin end;

class function THeroEmergeEventLog.ClassID: Integer;
begin Result := 0; end;

procedure THeroEmergeEventLog.Setup(A1: Integer; A2: Byte);
begin end;

procedure THeroEmergeEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THeroEmergeEventLog.GetText(A1: Integer);
begin end;

procedure THeroEmergeEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure THeroEmergeEventLog.CreateHeroJoinEventLog;
begin end;

procedure THeroEmergeEventLog.ExecuteAI;
begin end;

procedure THeroEmergeEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor THeroInventory.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroInventory.Destroy;
begin end;

procedure THeroInventory.GetFreeSlot(A1: Integer; A2: Integer);
begin end;

function THeroInventory.GetControlStyle: Engine.TEControlStyles;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THeroInventory.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THeroInventory.GetAbilityCount(A1: Integer; A2: Integer);
begin end;

procedure THeroInventory.GetSuperlativeEnabledAbOwner(A1: Integer);
begin end;

procedure THeroInventory.GetAbilityEnabled(A1: Integer);
begin end;

procedure THeroInventory.GetAbilitySet(A1: Integer);
begin end;

procedure THeroInventory.GetSuperlativeAbOwner(A1: Integer);
begin end;

procedure THeroInventory.GetSlot(A1: Integer);
begin end;

constructor THeroItems.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroItems.Destroy;
begin end;

function THeroItems.GetControlStyle: Engine.TEControlStyles;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THeroItems.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure THeroItems.GetAttack;
begin end;

procedure THeroItems.GetDefense;
begin end;

procedure THeroItems.GetDamage;
begin end;

procedure THeroItems.GetResistance;
begin end;

procedure THeroItems.GetMoveTypes(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetImmunityTypes(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetProtectionTypes(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetAbilityCount(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetSuperlativeEnabledAbOwner(A1: Integer);
begin end;

procedure THeroItems.GetSuperlativeAbOwner(A1: Integer);
begin end;

procedure THeroItems.GetAbilityEnabled(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetAbilitySet(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.GetPositionItem(A1: Integer);
begin end;

procedure THeroItems.GetPositionItemType(A1: Byte);
begin end;

procedure THeroItems.GetItemTypePosition(A1: Byte);
begin end;

procedure THeroItems.CanPlaceItem(A1: Integer; A2: Integer);
begin end;

procedure THeroItems.PlaceItem(A1: Integer; A2: Integer);
begin end;

procedure THeroPowerSource.Name(A1: Integer);
begin end;

procedure THeroPowerSource.Power;
begin end;

procedure THeroPowerSource.Select(A1: Integer; A2: Integer);
begin end;

procedure THeroPowerSource.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor THero.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THero.Destroy;
begin end;

function THero.GetCampaignTransferPoints: Integer;
begin end;

procedure THero.GetLibraryName(A1: Integer);
begin end;

procedure THero.UpdateFromLibraryBegin;
begin end;

procedure THero.UpdateFromLibraryEnd;
begin end;

procedure THero.UpdateFromLibrary;
begin end;

procedure THero.GetUnitLevel;
begin end;

procedure THero.SetOwner(AOwner: Engine.TECustomNode);
begin end;

procedure THero.GetNickname(A1: Integer);
begin end;

procedure THero.SetNickname(A1: Integer; A2: Integer);
begin end;

procedure THero.GetAbilitySelectionTypes(A1: Word; A2: Integer);
begin end;

function THero.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THero.GetLibraryHero;
begin end;

procedure THero.ShowEx(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THero.Changed;
begin end;

class function THero.ClassID: Integer;
begin Result := 0; end;

function THero.GetObtainValue: Integer;
begin end;

procedure THero.GetDescription;
begin end;

procedure THero.GetGender;
begin end;

function THero.GetUnitType: TUnitType;
begin end;

procedure THero.NewDay(A1: Integer; A2: Integer);
begin end;

procedure THero.UsedSkillPoints;
begin end;

procedure THero.CanJoin(A1: Byte; A2: Integer);
begin end;

procedure THero.EmergedToPlayer;
begin end;

procedure THero.OfferToJoin(A1: Integer);
begin end;

function THero.GetRace: Shortint;
begin end;

procedure THero.GetName(A1: Integer);
begin end;

procedure THero.GetMoveTypes;
begin end;

function THero.GetImmunityTypes: TDamageTypes;
begin end;

function THero.GetProtectionTypes: TDamageTypes;
begin end;

procedure THero.GetMovePoints;
begin end;

procedure THero.SetMovePoints(A1: Integer);
begin end;

function THero.GetHitPoints: Shortint;
begin end;

procedure THero.SetHitPoints(A1: Integer);
begin end;

function THero.GetAlignment: TAlignment;
begin end;

procedure THero.DropItemsOnMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure THero.Killed;
begin end;

procedure THero.Resurrect;
begin end;

procedure THero.Animate;
begin end;

procedure THero.CanActivate;
begin end;

procedure THero.GetUpkeep;
begin end;

procedure THero.SetPlayer(A1: Integer);
begin end;

procedure THero.CompatibleHero(A1: Integer; A2: Integer);
begin end;

procedure THero.Activate(A1: Integer; A2: Integer);
begin end;

procedure THero.Deactivate;
begin end;

procedure THero.GetUnitGFXResourceIndex;
begin end;

procedure THero.GetSkillPoints;
begin end;

procedure THero.GetSkillPointsMax;
begin end;

procedure THero.GetLevelMax;
begin end;

procedure THero.GetExperience;
begin end;

procedure THero.SetExperience(A1: Integer; A2: Integer);
begin end;

procedure THero.LevelToExperience(A1: Integer);
begin end;

procedure THero.ExperienceToLevel(A1: Integer);
begin end;

procedure THero.GetNextLevelExperience;
begin end;

procedure THero.GetLevel;
begin end;

procedure THero.SetLevel(A1: Integer);
begin end;

procedure THero.GetHeroType;
begin end;

procedure THero.SetUnitAttack(A1: Integer);
begin end;

procedure THero.SetUnitDefense(A1: Integer);
begin end;

procedure THero.SetUnitDamage(A1: Integer);
begin end;

procedure THero.SetUnitHits(A1: Integer);
begin end;

procedure THero.SetUnitMoves(A1: Integer);
begin end;

procedure THero.SetUnitResistance(A1: Integer);
begin end;

procedure THero.LinkToResource;
begin end;

procedure THero.Loaded;
begin end;

procedure THero.ListSpells(A1: Integer);
begin end;

procedure THero.ExecuteUpgradeHeroAI;
begin end;

procedure THero.ValidateHeroUpgrade(A1: Integer; A2: Integer);
begin end;

procedure THero.NewTurn(A1: Integer; A2: Integer);
begin end;

procedure THero.SetAbSet(A1: Integer; A2: Byte);
begin end;

procedure THero.GetAbSet(A1: Integer);
begin end;

procedure THero.GetUnitAbilityEnabled;
begin end;

procedure THero.GetAbilityCount;
begin end;

procedure THero.GetSuperlativeEnabledAbOwner(A1: Integer; A2: Integer);
begin end;

procedure THero.GetSuperlativeAbOwner(A1: Integer; A2: Integer);
begin end;

procedure THero.GetAbilityOwner(A1: Integer);
begin end;

function THero.GetAbilityEnabled(AbilityID: Integer): Boolean;
begin end;

procedure THero.GetAbilitySet(A1: Integer);
begin end;

procedure THero.GetAbilityName(A1: Integer; A2: Integer);
begin end;

procedure THero.GetAbilityLevel(A1: Integer);
begin end;

procedure THero.GetInherentAttack;
begin end;

procedure THero.GetAttack(A1: Integer; A2: Integer);
begin end;

procedure THero.GetInherentDefense;
begin end;

function THero.GetDefense: Shortint;
begin end;

procedure THero.GetInherentDamage;
begin end;

procedure THero.GetDamage(A1: Integer; A2: Integer);
begin end;

procedure THero.GetInherentResistance;
begin end;

function THero.GetResistance: Shortint;
begin end;

procedure THero.GetHits;
begin end;

procedure THero.GetMoves;
begin end;

procedure THero.GetPowerGeneration;
begin end;

procedure THero.GetCastingPointsMax;
begin end;

procedure THero.GetCastingPoints;
begin end;

procedure THero.SetCastingPoints(A1: Integer);
begin end;

procedure THero.GetPreviewImage;
begin end;

procedure THero.ResetSkillPoints;
begin end;

procedure THero.ResetResourceSettings;
begin end;

procedure THero.UpdateSettings;
begin end;

procedure THero.SetRace(A1: Byte; A2: Integer);
begin end;

procedure THero.GetFace;
begin end;

procedure THero.SetFaceIndex(A1: Integer);
begin end;

procedure THero.SetHeroResourceIndex(A1: Integer);
begin end;

procedure THero.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THero.EditDropMsg(A1: Integer);
begin end;

procedure THero.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure THero.CreateHeroUpdateTE;
begin end;

procedure THero.GetItemsOnGround;
begin end;

procedure THero.CanUseItem(A1: Integer; A2: Integer);
begin end;

procedure THero.UseItem;
begin end;

procedure THero.CanPlaceItem(A1: Integer; A2: Byte);
begin end;

procedure THero.CanSwapItem(A1: Integer; A2: Integer);
begin end;

procedure THero.SwapItem(A1: Integer; A2: Integer);
begin end;

procedure THero.PlaceItem(A1: Integer; A2: Integer);
begin end;

procedure THero.ExecuteSwapItem(A1: Integer; A2: Integer);
begin end;

procedure THero.AutoPlaceItem(A1: Integer; A2: Integer);
begin end;

procedure THero.ExecutePlaceItem(A1: Integer; A2: Integer);
begin end;

procedure THero.ExecuteStartCasting(A1: Integer);
begin end;

procedure THero.RemoveCastingReadyEventLog;
begin end;

procedure THero.ExecuteCancelCasting;
begin end;

procedure THero.CastingDone(A1: Integer; A2: Integer);
begin end;

procedure THero.CastingMana(A1: Integer);
begin end;

procedure THero.CastingTurns;
begin end;

procedure THero.Casting;
begin end;

procedure THero.CastingReady;
begin end;

procedure THero.CastingTurnsLeft;
begin end;

procedure THero.CanCastSpellInstantly(A1: Integer; A2: Integer);
begin end;

procedure THero.CanCastSpell(A1: Integer; A2: Integer);
begin end;

procedure THero.CastSpell(A1: Integer; A2: Integer);
begin end;

procedure THero.CanCastCombatSpell(A1: Integer; A2: Integer);
begin end;

procedure THero.CastCombatSpell(A1: Integer; A2: Integer);
begin end;

procedure THero.CancelCasting;
begin end;

procedure THeroUpdateTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

class function THeroUpdateTE.ClassID: Integer;
begin Result := 0; end;

function THeroUpdateTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure THeroResourceAbilityOwner.GetAbilitySelectionTypes(A1: Word; A2: Integer);
begin end;

constructor THeroResource.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroResource.Destroy;
begin end;

class function THeroResource.ClassID: Integer;
begin Result := 0; end;

function THeroResource.ResourceUserClassID: Integer;
begin Result := 0; end;

procedure THeroResource.HeroResourceIndex;
begin end;

procedure THeroResource.UsedSkillPoints;
begin end;

procedure THeroResource.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor THeroResourceList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure THeroResourceList.GetHeroResource(A1: Integer);
begin end;

procedure THeroResourceList.CreateHeroResourceStrings(A1: Byte);
begin end;

procedure THeroResourceList.Find(A1: Integer; A2: Byte);
begin end;

procedure THeroList.FindHero(A1: Integer);
begin end;

procedure THeroList.GetHero(A1: Integer);
begin end;

constructor THeroControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroControl.Destroy;
begin end;

procedure THeroControl.Changed;
begin end;

procedure THeroControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THeroControl.BeginUpdate;
begin end;

procedure THeroControl.EndUpdate;
begin end;

procedure THeroControl.UpdateLibraryHeroes;
begin end;

procedure THeroControl.GetHero(A1: Integer);
begin end;

procedure THeroControl.GetCount;
begin end;

procedure THeroControl.FindID;
begin end;

procedure THeroControl.IndexOf;
begin end;

procedure THeroControl.IndexOfLibraryEx(A1: Integer; A2: Integer);
begin end;

procedure THeroControl.ValidateLibraryHeroes;
begin end;

procedure THeroControl.Activate;
begin end;

procedure THeroControl.Deactivate;
begin end;

procedure THeroControl.RegisterHero(A1: Integer);
begin end;

procedure THeroControl.UnRegisterHero(A1: Integer);
begin end;

procedure THeroControl.HeroChanged;
begin end;

procedure THeroControl.GetAverageFreeHeroLevel(A1: Integer; A2: Integer);
begin end;

procedure THeroControl.GetMinFreeHeroLevel;
begin end;

procedure THeroControl.ListDeadHeroes(A1: Integer);
begin end;

procedure THeroControl.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure THeroLibrary.CreateUniqueLibraryID;
begin end;

function THeroLibrary.AddChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure THeroLibrary.CreateHero;
begin end;

procedure THeroLibrary.GetName(A1: Integer);
begin end;

procedure THeroLibrary.FindLibraryID(A1: Integer);
begin end;

procedure THeroLibrary.LoadFromFile;
begin end;

procedure THeroLibrary.SaveToFile;
begin end;

procedure THeroLibrary.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor THeroLibraryManager.Create(AOwner: Engine.TECustomNode);
begin end;

destructor THeroLibraryManager.Destroy;
begin end;

procedure THeroLibraryManager.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure THeroLibraryManager.GetLibrary(A1: Integer);
begin end;

procedure THeroLibraryManager.GetCount;
begin end;

procedure THeroLibraryManager.ReadUserLibraries;
begin end;

procedure THeroLibraryManager.WriteUserLibraries;
begin end;

procedure THeroLibraryManager.IndexOfLibraryName(A1: Integer);
begin end;

procedure THeroLibraryManager.IndexOfLibrary;
begin end;

procedure THeroLibraryManager.FindHero(A1: Integer; A2: Integer);
begin end;

procedure THeroLibraryManager.CreateLibrary(A1: Integer);
begin end;

procedure THeroLibraryManager.DeleteLibrary(A1: Integer);
begin end;

constructor TLeader.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TLeader.Destroy;
begin end;

procedure TLeader.Changed;
begin end;

class function TLeader.ClassID: Integer;
begin Result := 0; end;

function TLeader.GetUnitMoraleValue(Player, IndependentRelation: Shortint): Integer;
begin end;

procedure TLeader.GetNickname(A1: Integer);
begin end;

procedure TLeader.SetNickname(A1: Integer; A2: Integer);
begin end;

procedure TLeader.GetSpherePicks(A1: Byte);
begin end;

procedure TLeader.GetSpheres(A1: Integer);
begin end;

procedure TLeader.GetSphereCount;
begin end;

procedure TLeader.SetSpherePicksMax(A1: Byte);
begin end;

procedure TLeader.CanAddSphere(A1: Integer);
begin end;

procedure TLeader.AddSphere(A1: Byte; A2: Integer);
begin end;

procedure TLeader.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TLeader.DeleteSphereIndex(A1: Integer);
begin end;

procedure TLeader.DeleteSphere(A1: Byte; A2: Integer);
begin end;

procedure TLeader.ClearSpheres;
begin end;

procedure TLeader.GetPowerGeneration;
begin end;

procedure TLeader.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TLeader.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TLeader.SetHeroResourceIndex(A1: Integer);
begin end;

procedure TLeader.SetPlayer(A1: Integer);
begin end;

procedure TLeader.Killed;
begin end;

procedure TLeader.CanActivate;
begin end;

procedure TLeader.Activate(A1: Integer; A2: Integer);
begin end;

procedure TLeader.Deactivate;
begin end;

procedure TLeader.EditDropMsg(A1: Integer);
begin end;

procedure TLeader.CanDisband;
begin end;

procedure TLeader.GetUpkeep;
begin end;

constructor TArmyID.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArmyID.Destroy;
begin end;

class function TArmyID.ClassID: Integer;
begin Result := 0; end;

procedure TArmyID.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmyID.Valid;
begin end;

procedure TArmyID.RetrieveArmy(A1: Integer; A2: Integer);
begin end;

procedure TArmyView.GetUnitConcealedForPlayer(A1: Integer; A2: Integer);
begin end;

procedure TArmyView.GetConcealedForPlayer(A1: Byte);
begin end;

class function TArmyView.ClassID: Integer;
begin Result := 0; end;

procedure TArmyView.SetConcealedForPlayer(A1: Byte; A2: Integer);
begin end;

procedure TArmyView.SetUnitConcealedForPlayer(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArmyView.Setup(A1: Integer; A2: Byte);
begin end;

procedure TArmyView.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmyView.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmyView.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TArmyEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArmyEventLog.Destroy;
begin end;

class function TArmyEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TArmyEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmyEventLog.GetLeftIcon;
begin end;

procedure TArmyEventLog.SetArmyView;
begin end;

procedure TArmyEventLog.GetText(A1: Integer);
begin end;

procedure TArmyEventLog.LeaderKilled;
begin end;

procedure TArmyEventLog.PartyDestroyed;
begin end;

procedure TArmyEventLog.ValidateGameOver;
begin end;

procedure TArmyEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TArmyEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

constructor TArmyInfoEventLog.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArmyInfoEventLog.Destroy;
begin end;

class function TArmyInfoEventLog.ClassID: Integer;
begin Result := 0; end;

procedure TArmyInfoEventLog.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmyInfoEventLog.SetArmyView;
begin end;

procedure TArmyInfoEventLog.GetText(A1: Integer);
begin end;

procedure TArmyInfoEventLog.ViewLocation(A1: Integer; A2: Integer);
begin end;

procedure TArmyInfoEventLog.Execute(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

constructor TArmy.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArmy.Destroy;
begin end;

procedure TArmy.Kill(A1: Integer);
begin end;

procedure TArmy.GetStrengthEx(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetStrengthMaxEx(A1: Integer; A2: Integer);
begin end;

procedure TArmy.ReturnBattleFieldInfo(A1: Integer; A2: Integer);
begin end;

procedure TArmy.HealUnits(A1: Integer);
begin end;

procedure TArmy.CreateGroupID(A1: Integer);
begin end;

procedure TArmy.GetGroup(A1: Byte);
begin end;

procedure TArmy.SetGroup(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetGroupSelection(A1: Integer);
begin end;

procedure TArmy.GetBehavior;
begin end;

procedure TArmy.SetBehavior(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetOldAIBehavior;
begin end;

procedure TArmy.InitializeGroupBehavior;
begin end;

procedure TArmy.UpdateGroupBehavior(A1: Integer; A2: Integer);
begin end;

procedure TArmy.CreateID(A1: Integer; A2: Integer);
begin end;

class function TArmy.ClassID: Integer;
begin Result := 0; end;

procedure TArmy.GetArmyHS(A1: Integer; A2: Integer);
begin end;

function TArmy.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TArmy.AssignSettings(A1: Integer);
begin end;

procedure TArmy.SetFullyConcealed(A1: Byte);
begin end;

procedure TArmy.GetFullyConcealed;
begin end;

procedure TArmy.UpdateConcealment(A1: Integer; A2: Integer);
begin end;

procedure TArmy.SetXYL(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TArmy.GetRace(A1: Integer);
begin end;

procedure TArmy.GetUpkeep;
begin end;

procedure TArmy.ResetDestinationPos;
begin end;

procedure TArmy.SetDestinationPos(A1: Byte; A2: Byte; A3: Integer);
begin end;

procedure TArmy.ConcealedUnitsCount;
begin end;

procedure TArmy.UpdateConcealedUnits;
begin end;

procedure TArmy.UpdateUpkeep;
begin end;

procedure TArmy.Changed;
begin end;

procedure TArmy.ValidateTerrainEx(A1: Byte; A2: Byte);
begin end;

procedure TArmy.ValidateTerrain;
begin end;

procedure TArmy.Validate;
begin end;

procedure TArmy.UpdateFormation;
begin end;

procedure TArmy.Update;
begin end;

procedure TArmy.TriggerOnUpdateEvent;
begin end;

procedure TArmy.Activate;
begin end;

procedure TArmy.Deactivate;
begin end;

procedure TArmy.ValidateSelection(A1: Byte);
begin end;

procedure TArmy.SelectionCount(A1: Byte);
begin end;

procedure TArmy.ValidateMoveSelection(A1: Integer; A2: Integer);
begin end;

procedure TArmy.Select;
begin end;

procedure TArmy.Unselect;
begin end;

procedure TArmy.GetPlayer;
begin end;

procedure TArmy.GetUnitConcealed(A1: Integer);
begin end;

procedure TArmy.GetUnitConcealedForPlayer(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetUnitsConcealedForPlayer(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetConcealedForPlayer(A1: Byte);
begin end;

procedure TArmy.SetPlayer(A1: Integer);
begin end;

procedure TArmy.ImmunityTypes(A1: Integer);
begin end;

procedure TArmy.ObtainValue(A1: Integer; A2: Integer);
begin end;

procedure TArmy.MovePoints(A1: Integer);
begin end;

procedure TArmy.Moves(A1: Integer);
begin end;

procedure TArmy.MoveTypes(A1: Integer; A2: Integer);
begin end;

procedure TArmy.GetPartyMoves(A1: Byte);
begin end;

procedure TArmy.MoveOnMovePoints(A1: Integer; A2: Byte; A3: Integer);
begin end;

procedure TArmy.CreateMovePointTable(A1: Integer; A2: Integer);
begin end;

procedure TArmy.ValidTerrainEx(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TArmy.ValidTerrain(A1: Byte; A2: Integer);
begin end;

procedure TArmy.CanPlace(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TArmy.MovedTo(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArmy.MaxSize(A1: Integer; A2: Integer);
begin end;

procedure TArmy.Hero(A1: Integer; A2: Byte);
begin end;

procedure TArmy.Leader(A1: Integer);
begin end;

procedure TArmy.Transporter(A1: Integer);
begin end;

procedure TArmy.IndexOfTransporter(A1: Integer);
begin end;

procedure TArmy.UnitsInTransporter;
begin end;

procedure TArmy.UpdateVisibilityRanges(A1: Integer; A2: Integer);
begin end;

procedure TArmy.VisibilityRange;
begin end;

procedure TArmy.TrueVisionRange;
begin end;

procedure TArmy.TurnUnFogOff;
begin end;

procedure TArmy.UpdateExploration;
begin end;

procedure TArmy.UpdateUnfog;
begin end;

procedure TArmy.CanAddUnit(A1: Integer; A2: Integer);
begin end;

procedure TArmy.CanAddUnits(A1: Integer; A2: Integer);
begin end;

procedure TArmy.AddUnits(A1: Integer);
begin end;

procedure TArmy.CanAddUnitSelection(A1: Integer; A2: Integer);
begin end;

procedure TArmy.AddUnitSelection(A1: Integer; A2: Integer);
begin end;

procedure TArmy.CanDeleteUnit(A1: Integer);
begin end;

function TArmy.RemoveChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

function TArmy.AddChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure TArmy.AddUnit(A1: Integer);
begin end;

procedure TArmy.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArmy.SelectionUnit(A1: Byte; A2: Integer);
begin end;

procedure TArmy.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TArmy.MakeIndependent(A1: Integer; A2: Integer);
begin end;

procedure TArmy.UpdateIndependentRelation;
begin end;

procedure TArmy.Desert(A1: Byte);
begin end;

procedure TArmy.GetPartyStatus(A1: Integer);
begin end;

procedure TArmy.UpdateDesertion;
begin end;

procedure TArmy.ValidateCrusaders;
begin end;

procedure TArmy.NewTurn(A1: Byte);
begin end;

procedure TArmy.NewTurnDone(A1: Byte);
begin end;

procedure TArmy.NewDay;
begin end;

procedure TArmy.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TArmy.CanActivate;
begin end;

procedure TArmy.GetMoveAction(A1: Byte; A2: Integer);
begin end;

procedure TArmy.GetCanJoinSelection(A1: Byte; A2: Integer);
begin end;

procedure TArmy.GetJoinSelection(A1: Byte; A2: Integer);
begin end;

procedure TArmy.JoinAmount(A1: Byte; A2: Integer);
begin end;

procedure TArmy.IncommingNegotiateRequest(A1: Integer);
begin end;

procedure TArmy.IncommingNegotiateOffer(A1: Integer);
begin end;

procedure TArmy.TriggerFireDamage;
begin end;

procedure TArmy.RetrieveStormDamageInfo(A1: Byte);
begin end;

procedure TArmy.IncommingStorm(A1: Byte; A2: Integer);
begin end;

procedure TArmy.UpdateAITarget(A1: Integer; A2: Integer);
begin end;

procedure TArmy.AIMovePriority;
begin end;

procedure TArmy.ResetMoveDone;
begin end;

procedure TArmy.CanCombine(A1: Integer; A2: Integer);
begin end;

constructor TArmyHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TArmyHS.Destroy;
begin end;

class function TArmyHS.ClassID: Integer;
begin Result := 0; end;

procedure TArmyHS.GetFogEnabled;
begin end;

procedure TArmyHS.VisibleForSeatedPlayer;
begin end;

function TArmyHS.EditName: string;
begin Result := ''; end;

procedure TArmyHS.Clear;
begin end;

function TArmyHS.PlaceOnMap: Boolean;
begin Result := False; end;

procedure TArmyHS.RemoveFromMap;
begin end;

procedure TArmyHS.Select;
begin end;

procedure TArmyHS.Unselect;
begin end;

function TArmyHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

function TArmyHS.GetSelected: Boolean;
begin Result := False; end;

procedure TArmyHS.ArmyUpdated(A1: Integer);
begin end;

procedure TArmyHS.UpdateFlagID;
begin end;

procedure TArmyHS.UpdateUnitGFXResource;
begin end;

procedure TArmyHS.Activate;
begin end;

procedure TArmyHS.Deactivate;
begin end;

procedure TArmyHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TArmyHS.CanChangeTerrain(const Info: HSEngine.THSSenderInfo): Boolean;
begin Result := False; end;

procedure TArmyHS.TerrainChanged(const Info: HSEngine.THSTerrainInfo);
begin end;

function TArmyHS.CanMoveOver(const Info: HSEngine.THSSenderInfo): Integer;
begin Result := 0; end;

procedure TArmyHS.CanMoveOn(const Info: HSEngine.THSMoveOnInfo; var MoveResult: HSEngine.THSMoveOnResult);
begin end;

procedure TArmyHS.UpdateMapField(const Info: HSEngine.THSMapFieldInfo);
begin end;

procedure TArmyHS.MoveTo(A1: Integer; A2: Integer);
begin end;

procedure TArmyHS.PlaceHX(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TArmyHS.PlacePrivate(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TArmyHS.ShowShadow(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArmyHS.PlayMoveSFX;
begin end;

procedure TArmyHS.ShowEnchantments(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TArmyHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TArmyHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TArmyHS.MapFieldMsgProc(var Msg: HSEngine.TMapFieldMsg);
begin end;

procedure TArmyHS.PlaceEx(A1: Byte; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TArmyHS.MoveFirst(A1: Integer; A2: Integer);
begin end;

function TArmyHS.GetMoveSteps: Integer;
begin Result := 0; end;

procedure TArmyHSList.GetArmyHS(A1: Integer);
begin end;

procedure TSelectedArmy.Create(A1: Byte);
begin end;

destructor TSelectedArmy.Destroy;
begin end;

procedure TSelectedArmy.SetCurrentMove(A1: Integer);
begin end;

procedure TSelectedArmy.AddMoveArmy(A1: Integer; A2: Integer);
begin end;

procedure TSelectedArmy.GetArmyHS;
begin end;

procedure TSelectedArmy.GetSelection;
begin end;

procedure TSelectedArmy.SetSelection(A1: Integer);
begin end;

procedure TSelectedArmy.GetMoveTypes;
begin end;

procedure TSelectedArmy.ShowMovePaths(A1: Integer);
begin end;

procedure TSelectedArmy.ResetSelectedUnitGFX;
begin end;

procedure TSelectedArmy.UpdateSelectedUnitGFX(A1: Integer; A2: Integer);
begin end;

procedure TSelectedArmy.OnDestroyArmy(A1: Integer);
begin end;

procedure TSelectedArmy.RectangleSelectEvent(A1: Integer);
begin end;

procedure TSelectedArmy.ValidMultiMoveSelection(A1: Integer);
begin end;

procedure TSelectedArmy.ValidateSelection(A1: Integer);
begin end;

procedure TSelectedArmy.CalculateMovePath(A1: Integer; A2: Byte; A3: Integer; A4: Integer);
begin end;

procedure TSelectedArmy.SelectPath(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TSelectedArmy.Unselect(A1: Integer; A2: Integer);
begin end;

procedure TSelectedArmy.MouseDownEvent(A1: Integer);
begin end;

procedure TSelectedArmy.ExecuteMove;
begin end;

procedure TSelectedArmy.UpdateMoveCursor;
begin end;

procedure TSelectedArmy.ActivateMoveSelection;
begin end;

procedure TSelectedArmy.Deactivate;
begin end;

procedure TSelectedArmy.DeactivateMoveSelection;
begin end;

procedure TSelectedArmy.Update;
begin end;

procedure TSelectedArmy.OutputGroupInfo;
begin end;

procedure TSelectedArmy.SetArmyHS(A1: Integer);
begin end;

procedure TSelectedArmy.Select(A1: Integer);
begin end;

procedure TSelectedArmy.SelectBuildRoad(A1: Integer);
begin end;

procedure TSelectedArmy.Center;
begin end;

procedure TSelectedArmy.TurnDone;
begin end;

procedure TSelectedArmy.ToggleGuard;
begin end;

class function TItemTE.ClassID: Integer;
begin Result := 0; end;

procedure TItemTE.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

function TItemTE.Execute(TE: NetworkE.TTokenExecuter): NetworkE.TExecuteResult;
begin FillChar(Result, SizeOf(Result), 0); end;

constructor TItem.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItem.Destroy;
begin end;

function TItem.AddRef: Integer;
begin Result := 0; end;

function TItem.Release: Integer;
begin Result := 0; end;

procedure TItem.SetOwner(AOwner: Engine.TECustomNode);
begin end;

procedure TItem.ExecuteUse(A1: Integer);
begin end;

procedure TItem.CanUse(A1: Integer; A2: Integer);
begin end;

procedure TItem.Use(A1: Integer);
begin end;

procedure TItem.SetArrayOwner(AOwner: Engine.TECustomNode; Index: Integer);
begin end;

procedure TItem.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TItem.Activate;
begin end;

procedure TItem.Deactivate;
begin end;

procedure TItem.Changed;
begin end;

class function TItem.ClassID: Integer;
begin Result := 0; end;

procedure TItem.GetCampaignTransferPoints;
begin end;

procedure TItem.GetImage;
begin end;

procedure TItem.GetLibraryItem;
begin end;

procedure TItem.GetLibraryName(A1: Integer);
begin end;

procedure TItem.UpdateFromLibrary;
begin end;

procedure TItem.GetOwnerName(A1: Integer);
begin end;

procedure TItem.GetAbilitySelectionTypes(A1: Word; A2: Integer);
begin end;

procedure TItem.SetItemGFXIndex(A1: Integer);
begin end;

procedure TItem.Show(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TItem.SetItemType(A1: Integer);
begin end;

procedure TItem.GetObtainValue;
begin end;

procedure TItem.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItem.PlaceOnMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TItem.EditDropMsg(A1: Integer);
begin end;

procedure TItem.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

constructor TItemList.Create(AOwner: Engine.TECustomNode);
begin end;

function TItemList.RemoveChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

function TItemList.AddChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure TItemList.DestroyAllChildren;
begin end;

procedure TItemList.MainReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemList.Clear;
begin end;

procedure TItemList.Changed;
begin end;

procedure TItemList.FindItem(A1: Integer; A2: Integer);
begin end;

procedure TItemList.GetItem(A1: Integer);
begin end;

procedure TItemList.Update;
begin end;

procedure TItemList.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TItemList.SortOnName;
begin end;

procedure TItemList.SortOnType;
begin end;

procedure TItemList.RegisterItems;
begin end;

procedure TItemList.LockChanged;
begin end;

procedure TItemList.UnlockChanged;
begin end;

constructor TItemControl.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItemControl.Destroy;
begin end;

procedure TItemControl.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemControl.GetItem(A1: Integer);
begin end;

procedure TItemControl.GetCount;
begin end;

procedure TItemControl.FindItem(A1: Integer);
begin end;

procedure TItemControl.ItemChanged;
begin end;

procedure TItemControl.Changed;
begin end;

procedure TItemControl.BeginUpdate;
begin end;

procedure TItemControl.EndUpdate;
begin end;

procedure TItemControl.CreateUniqueID;
begin end;

procedure TItemControl.ValidateItem(A1: Integer);
begin end;

procedure TItemControl.UpdateLibraryItems;
begin end;

procedure TItemControl.RegisterItem(A1: Integer);
begin end;

procedure TItemControl.UnRegisterItem(A1: Integer);
begin end;

procedure TItemControl.GenerateItem(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TItemControl.GenerateItems(A1: Byte; A2: Integer; A3: Integer);
begin end;

procedure TItemControl.Activate;
begin end;

procedure TItemControl.Deactivate;
begin end;

procedure TItemLibrary.CreateUniqueLibraryID;
begin end;

function TItemLibrary.AddChild(Child: Engine.TEObject): Integer;
begin Result := 0; end;

procedure TItemLibrary.FindLibraryID(A1: Integer);
begin end;

procedure TItemLibrary.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemLibrary.GetName(A1: Integer);
begin end;

procedure TItemLibrary.CreateItem;
begin end;

procedure TItemLibrary.LoadFromFile;
begin end;

procedure TItemLibrary.SaveToFile;
begin end;

constructor TItemLibraryManager.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItemLibraryManager.Destroy;
begin end;

procedure TItemLibraryManager.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemLibraryManager.GetLibrary(A1: Integer);
begin end;

procedure TItemLibraryManager.GetCount;
begin end;

procedure TItemLibraryManager.ReadUserLibraries;
begin end;

procedure TItemLibraryManager.WriteUserLibraries;
begin end;

procedure TItemLibraryManager.IndexOfLibraryName(A1: Integer);
begin end;

procedure TItemLibraryManager.IndexOfLibrary;
begin end;

procedure TItemLibraryManager.FindItem(A1: Integer; A2: Integer);
begin end;

procedure TItemLibraryManager.CreateLibrary(A1: Integer);
begin end;

procedure TItemLibraryManager.DeleteLibrary(A1: Integer);
begin end;

function TItemGFX.GetEngine: Engine.TEngine;
begin FillChar(Result, SizeOf(Result), 0); end;

class function TItemGFX.ClassID: Integer;
begin Result := 0; end;

procedure TItemGFX.ItemGFXIndex;
begin end;

procedure TItemGFX.LinkToIL;
begin end;

procedure TItemGFX.ReleaseIL;
begin end;

procedure TItemGFX.SetImageLibraryName(A1: Integer; A2: Integer);
begin end;

function TItemGFX.AddRef: Integer;
begin Result := 0; end;

function TItemGFX.Release: Integer;
begin Result := 0; end;

function TItemGFX.GetCellImage: ImageLib.TLibraryImage;
begin FillChar(Result, SizeOf(Result), 0); end;

procedure TItemGFX.GetItemImage;
begin end;

procedure TItemGFX.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

constructor TItemGFXList.Create(AOwner: Engine.TECustomNode);
begin end;

procedure TItemGFXList.GetItemGFX(A1: Integer);
begin end;

procedure TItemGFXList.FindItemTypeGFX(A1: Byte);
begin end;

procedure TItemHSList.SetOwner(AOwner: Engine.TECustomNode);
begin end;

procedure TItemHSList.GetLocation(A1: Integer; A2: Integer; A3: Integer);
begin end;

constructor TItemHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TItemHS.Destroy;
begin end;

procedure TItemHS.ItemsChanged;
begin end;

function TItemHS.GetLevel: Byte;
begin Result := 0; end;

function TItemHS.GetShowPriority: Integer;
begin Result := 0; end;

class function TItemHS.ClassID: Integer;
begin Result := 0; end;

function TItemHS.EditName: string;
begin Result := ''; end;

function TItemHS.CanSelect(Xhp, Yhp: Integer): Boolean;
begin Result := False; end;

procedure TItemHS.Activate;
begin end;

procedure TItemHS.Deactivate;
begin end;

procedure TItemHS.ReadWrite(Stream: Engine.TEStorageStream);
begin end;

procedure TItemHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

function TItemHS.CanPlace(Map: HSEngine.TMapContainer; Xhx, Yhx, Lhx: Shortint): Boolean;
begin Result := False; end;

procedure TItemHS.GenerateItems;
begin end;

procedure TItemHS.MsgProc(var Msg: Engine.TEMsg; Sender: Engine.TEObject);
begin end;

procedure TWorldFXHS.Deactivate;
begin end;

constructor TWorldFXHS.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TWorldFXHS.Destroy;
begin end;

procedure TWorldFXHS.Activate;
begin end;

function TWorldFXHS.GetShowPriority: Integer;
begin Result := 0; end;

procedure TWorldFXHS.NewFrame(A1: Integer);
begin end;

procedure TWorldFXHS.Show(XhpSurf: Integer; YhpSurf: Integer; const SurfaceDesc: GFXE.TSurfaceDesc);
begin end;

procedure TTranslateTextStream.TranslateString(var S: string);
begin end;

procedure TTranslateTextStream.TranslateStrings(var Strings: Classes.TStrings);
begin end;

procedure TAoWEngine.TranslateEObject(A1: Integer; A2: Integer);
begin end;

procedure TAoWEngine.TranslateEObjectFromFile(A1: Integer; A2: Integer);
begin end;

procedure TAoWEngine.ExportTextToFile(A1: Integer; A2: Integer);
begin end;

procedure TAoWEngine.TranslateRStr(A1: Integer; A2: Integer);
begin end;

function TAoWEngine.TranslateText(const Text: string): string;
begin Result := ''; end;

constructor TAoWEngine.Create(AOwner: Engine.TECustomNode);
begin end;

destructor TAoWEngine.Destroy;
begin end;

procedure TAoWEngine.UpdateStartupDirectory;
begin end;

class function TAoWEngine.ClassID: Integer;
begin Result := 0; end;

procedure TAoWEngine.GetMajorVersion;
begin end;

procedure TAoWEngine.GetMinorVersion;
begin end;

procedure TAoWEngine.GetBuildNumber;
begin end;

procedure TAoWEngine.SetVersion(A1: Integer; A2: Integer; A3: Integer);
begin end;

procedure TAoWEngine.GetVersionStr(A1: Integer);
begin end;

procedure TAoWEngine.CreateHSSet;
begin end;

procedure TAoWEngine.CloseHSM(AProgress: Engine.TProgressEvent);
begin end;

procedure TAoWEngine.SetHSMap(Value: HSEngine.THSMap);
begin end;

procedure TAoWEngine.RegisteredVersion;
begin end;

procedure TAoWEngine.RegisteredTo(A1: Integer);
begin end;

procedure TAoWEngine.RequestAccess(A1: Integer; A2: Integer);
begin end;

procedure TAoWEngine.CloseCampaign;
begin end;

procedure TAoWEngine.LoadCampaignMap(A1: Integer; A2: Integer; A3: Integer; A4: Integer);
begin end;

procedure TAoWEngine.LoadCampaign(A1: Integer);
begin end;

procedure TAoWEngine.SaveCampaign(A1: Integer);
begin end;

procedure TAoWEngine.NewCampaign(A1: Integer);
begin end;

procedure TExportTextStream.rwString(var S: string; ID: Integer);
begin end;

procedure TExportTextStream.rwStrings(Strings: Classes.TStrings; ID: Integer);
begin end;

class function TAoWMapObjectEditor.EditorClassID: Integer;
begin Result := 0; end;

procedure TAgeOfWondersEngine.SetHSEngine(Value: HSEngine.THSEngine);
begin end;

procedure TAgeOfWondersEngine.CreateEngine;
begin end;

destructor TAgeOfWondersEngine.Destroy;
begin end;

